//
//  LANGUANGMeetingListViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGMeetingListViewControllerARC.h"
#import "LGMettingDetailViewControllerArc.h"

#import "IOSSystemDefine.h"
#import "LANGUANGMeetingModelARC.h"
#import "ASIFormDataRequest.h"
#import "LogUtil.h"
#import "JSONKit.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "LANGUANGMeetingCellARC.h"
#import "MJRefresh.h"
#import "WXRefreshHeader.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "Emp.h"
#import "UserDefaults.h"
#import "LGMettingDefine.h"
#import "LGMettingUtilARC.h"

//查询下级会议（10将开，11正在开，12已开）、查询重要会议（20将开，21正在开，22已开）、查询本人会议（30将开，31正在开，32已开）

typedef enum{
    reload_my_will = 30,
    reload_my_Is = 31,
    reload_my_end = 32,
    reload_lower_will = 10,
    reload_lower_Is = 11,
    reload_lower_end = 12
}reloadTypeEnum;

@interface LANGUANGMeetingListViewControllerARC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *tempArray;
    NSMutableArray  * repArr;
    NSString *MeetingType;
    NSInteger reloadType;
    conn *_conn;
    eCloudDAO *db;
 
}

@property(nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) NSArray *markArray;

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *allTimeArr;

@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, assign) NSInteger page;
@property(strong,nonatomic) Emp *emp;
@end

@implementation LANGUANGMeetingListViewControllerARC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会议";
    
    tempArray = [NSMutableArray array];
    _markArray = [NSArray array];
    _btnArray = [NSMutableArray array];
    _allTimeArr = [NSMutableArray array];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    MeetingType = @"我的会议";
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
    self.emp = [db getEmpInfo:_conn.userId];
    
    [self initViews];
}
-(void)initViews{
 
    self.page = 1;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT-105) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
    _tableView.sectionHeaderHeight = 30;
    [UIAdapterUtil setExtraCellLineHidden:_tableView];
    [self.view addSubview:_tableView];
    
    __weak typeof(self) weak = self;
   
    weak.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        self.page = 1;
        [self getData:reloadType page:self.page];
    }];
    
    weak.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^ {

        self.page++;
        [self getData:reloadType page:self.page];
//        _tableView.mj_footer.state = MJRefreshStateNoMoreData;

    }];
    
//    [weak.tableView.mj_header beginRefreshing];
    NSArray *items = @[@"我的会议", @"下属的会议"];
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:items];
    segment.frame = CGRectMake(SCREEN_WIDTH/2-100, 10, 200, 35);
    segment.layer.masksToBounds = YES;               //    默认为no，不设置则下面一句无效
    segment.layer.cornerRadius = 18;               //    设置圆角大小，同UIView
    segment.layer.borderWidth = 1;                   //    边框宽度，重新画边框，若不重新画，可能会出现圆角处无边框的情况
    // 主题颜色
    UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
    segment.layer.borderColor = _color.CGColor; //     边框颜色
    // 设置选择的Item
    segment.selectedSegmentIndex = 0;
    
    
    segment.tintColor = _color;
    
    // 添加事件
    [segment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:segment];
    
    _markArray = @[@"即将开", @"正在开", @"已结束"];
    
    CGFloat width = SCREEN_WIDTH / 3;
    CGFloat height = 50;
//    if (IS_IPHONE_6) {
//        
//        height = 45;
//    }
//    if (IS_IPHONE_5) {
//        
//        height = 40;
//    }
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - 50, SCREEN_WIDTH, 50)];
    buttonView.backgroundColor = [UIColor colorWithRed:0xef/255.0 green:0xeb/255.0 blue:0xed/255.0 alpha:1];
    [self.view addSubview:buttonView];
    
    for (int row=0; row<3; row++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(row*width, 0, width-1, height);
        //btn.backgroundColor = [UIColor colorWithRed:188/255.0f green:188/255.0f blue:188/255.0f alpha:1.0f];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitle:_markArray[row] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(button1BackGroundNormal:) forControlEvents:UIControlEventTouchUpInside];
        btn.clipsToBounds = YES;
        btn.tag = row;
        [self.btnArray addObject:btn];
        [buttonView addSubview:btn];
        
        if (row == 0) {
            
            [btn setTitleColor:[UIColor colorWithRed:0 green:0x88/255.0 blue:0xc8/255.0 alpha:1] forState:UIControlStateNormal];
//            btn.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xf7/255.0 alpha:1];
            btn.selected = YES;
            
            self.selectedBtn = btn;
            
        }
    }
    
    reloadType = reload_my_will;
    [self getData:reloadType page:self.page];
    
}

//  button1普通状态下的背景色
- (void)button1BackGroundNormal:(UIButton *)sender
{

    NSLog(@"点击了%@", sender.titleLabel.text);
    if (!sender.isSelected) {
        
        self.selectedBtn.selected = !self.selectedBtn.selected;

        [sender setTitleColor:[UIColor colorWithRed:0 green:0x88/255.0 blue:0xc8/255.0 alpha:1] forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xf7/255.0 alpha:1];
        sender.selected = !sender.selected;
        
        [self.selectedBtn setTitleColor:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1] forState:UIControlStateNormal];
        self.selectedBtn.backgroundColor = [UIColor whiteColor];
        self.selectedBtn = sender;
        
    }else{
        
        sender.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xf7/255.0 alpha:1];
        return;
    }
//    self.selectedBtn = sender;
//    
//    sender.selected = !sender.selected;
//    
//    for (NSInteger j = 0; j < [self.btnArray count]; j++) {
//        UIButton *btn = self.btnArray[j] ;
//        if (sender.tag == j) {
//            btn.selected = sender.selected;
//        } else {
//            btn.selected = NO;
//        }
//        btn.backgroundColor = [UIColor colorWithRed:188/255.0f green:188/255.0f blue:188/255.0f alpha:1.0f];
//    }
//    
//    UIButton *btn = self.btnArray[sender.tag];
//    if (btn.selected) {
//        btn.backgroundColor = [UIColor whiteColor];
//    } else {
//        btn.backgroundColor = [UIColor colorWithRed:188/255.0f green:188/255.0f blue:188/255.0f alpha:1.0f];
//    }
    
    if ([MeetingType isEqualToString:@"我的会议"]) {
        
        if ([sender.titleLabel.text isEqualToString:@"即将开"]) {
            
            reloadType = reload_my_will;
            
        }else if ([sender.titleLabel.text isEqualToString:@"正在开"]){
            
            reloadType = reload_my_Is;
            
        }else if ([sender.titleLabel.text isEqualToString:@"已结束"]){
            
            reloadType = reload_my_end;
        }
    }else{
        
        if ([sender.titleLabel.text isEqualToString:@"即将开"]) {
            
            reloadType = reload_lower_will;
            
        }else if ([sender.titleLabel.text isEqualToString:@"正在开"]){
            
            reloadType = reload_lower_Is;
            
        }else if ([sender.titleLabel.text isEqualToString:@"已结束"]){
            
            reloadType = reload_lower_end;
        }
    }
    
    self.page = 1;
    [self getData:reloadType page:self.page];
}

- (void)segmentValueChanged:(UISegmentedControl *)segment
{
    
    NSString *selectedIndexTitle = [segment titleForSegmentAtIndex:segment.selectedSegmentIndex];
    if ([selectedIndexTitle isEqualToString:@"我的会议"]) {
        
        MeetingType = @"我的会议";
        self.page = 1;
 
        if (self.selectedBtn.tag == 0) {
            
            reloadType = reload_my_will;
            
        }else if(self.selectedBtn.tag ==1){
            
            reloadType = reload_my_Is;
            
        }else if (self.selectedBtn.tag ==2){
            
            reloadType = reload_my_end;
        }
        [self getData:reloadType page:self.page];
    }
    else{
        
        MeetingType = @"下属的会议";
        if (self.selectedBtn.tag == 0) {
            
            reloadType = reload_lower_will;
            
        }else if(self.selectedBtn.tag ==1){
            
            reloadType = reload_lower_Is;
            
        }else if (self.selectedBtn.tag ==2){
            
            reloadType = reload_lower_end;
        }
        self.page = 1;
        
        [self getData:reloadType page:self.page];
        
    }
}

- (void)getData:(NSInteger )type page:(NSInteger )page{
    
    NSLog(@"type========%ld",type);
    Emp *emp = [conn getConn].curUser;
    NSString *curTime = [[conn getConn] getSCurrentTime];
    NSString *empID = [NSString stringWithFormat:@"%@",emp.empCode];
    NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%@%@",empID,curTime,LGmd5_password]];
    NSString *oaToken = [UserDefaults getLoginToken];
    
    dispatch_queue_t queue = dispatch_queue_create("get data", NULL);
    
    dispatch_async(queue, ^{
        //http://222.209.223.92:9013/middleware/conference/getMeetingList?md5key=12edcdad36dc6e86c1853c6b587a50f5&timeStamp=1497513114085&account=lhai&access_token=4e28350c093e4035bbe16745e86ea6c8&type=30&page=1
        
        NSString *url = [NSString stringWithFormat:@"%@/middleware/conference/getMeetingList?",[LGMettingUtilARC get9013Url]];

        NSString *urlString = [NSString stringWithFormat:@"%@account=%@&md5key=%@&timeStamp%@&access_token=%@&type=%ld&page=%ld",url,empID,md5Str,curTime,oaToken,(long)type,(long)page];

        ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        
        [requestForm startSynchronous];
        
   
        //输入返回的信息
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取会议列表 %@",__FUNCTION__,[requestForm responseString]]];
        NSString *jsonString = [requestForm responseString];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [jsonData objectFromJSONData];
        NSArray *jsonArr = resultDict[@"data"];

        if (self.page == 1) {
            
            [tempArray removeAllObjects];
            
        }
        [_allTimeArr removeAllObjects];
        for (NSDictionary *listDic in jsonArr) {
            
            //1.取出所有出现得时间
            [_allTimeArr addObject:[listDic[@"startTime"] substringToIndex:10]];
        }
        
        repArr = [self arrayWithMemberIsOnly:_allTimeArr];
        
        /** 判断日期是否相等  相等存入小数组中,不相等将小数组存入大数组中 */
        for (NSString *nowTim in repArr) {
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (NSDictionary *listDicTwo in jsonArr) {
                
                NSString *twoTim = [listDicTwo[@"startTime"] substringToIndex:10];
                if([twoTim isEqualToString:nowTim]){
                    //2.将每个字典保存在模型数组中
                    LANGUANGMeetingModelARC *model = [[LANGUANGMeetingModelARC alloc]init];
                    [model setValuesForKeysWithDictionary:listDicTwo];
                    [arr addObject:model];
                    
                }
                
            }

            [tempArray addObject:arr];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
        [self endRefresh];
        [_tableView reloadData];
            
        });
        
        
    });
    
    

}

// 告诉TableView对应的Section要显示几行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *arr = tempArray[section];
    
    return  arr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    LANGUANGMeetingCellARC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[LANGUANGMeetingCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSArray *arr = tempArray[indexPath.section];
    LANGUANGMeetingModelARC *cellModel = arr[indexPath.row];
    //cell.textLabel.text = cellModel.title;
    [cell configCellWithDataModel:cellModel];
    
    return cell;
}

// 返回分组（Section）数 Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tempArray.count;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, headerView.bounds.size.width,30)];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [headerLabel setTextColor:[UIColor colorWithRed:188/255.0f green:188/255.0f blue:188/255.0f alpha:1.0f]];
    [headerLabel setBackgroundColor:[UIColor whiteColor]];
    [headerView addSubview: headerLabel];
    
//    NSArray *arr = tempArray[section];
//    LANGUANGMeetingModelARC *model = arr[section];
    
    //ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:section - 1];
    
    NSString *str;
    for (LANGUANGMeetingModelARC *model in tempArray[section]) {

        str=model.startTime;
    }
    NSString *weekStr = [self weekdayStringFromDate:[str substringToIndex:10]];
    NSString *tmpStr = [str substringWithRange:NSMakeRange(5,5)];
    NSString *dayStr = [NSString stringWithFormat:@"    %@ %@",tmpStr,weekStr];
    headerLabel.text = dayStr;
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 29, headerView.bounds.size.width, 1)];
    lineLabel.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
    [headerView addSubview: lineLabel];
    
    return headerView;
}
// 返回组头部的Title
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *string = repArr[section];
//    return [NSString stringWithFormat:@"%@",string];
//}
// 返回组头部（段头）的高度
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
//去除数组中重复的
-(NSMutableArray *)arrayWithMemberIsOnly:(NSArray *)array
{
    NSMutableArray *categoryArray =[[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [array count]; i++) {
        @autoreleasepool {
            if ([categoryArray containsObject:[array objectAtIndex:i]]==NO) {
                [categoryArray addObject:[array objectAtIndex:i]];
            }
        }
    }
    return categoryArray;
}

- (NSString*)weekdayStringFromDate:(NSString *)dayString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *endDate = [formatter dateFromString:dayString];
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null],@"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:endDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = tempArray[indexPath.section];
    LANGUANGMeetingModelARC *model = arr[indexPath.row];
    
    LGMettingDetailViewControllerArc *confDetailCtl = [[LGMettingDetailViewControllerArc alloc] init];
    confDetailCtl.idNum = model.congfId;
    confDetailCtl.type = model.type;
    [self.navigationController pushViewController:confDetailCtl animated:YES];
    
}

-(void)endRefresh{
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
