//
//  LGMettingDetailViewControllerArc.m
//  mettingDetail
//
//  Created by Alex-L on 2017/5/26.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import "LGMettingDetailViewControllerArc.h"

#import "LGMeetingDetailCellArc.h"
#import "LGMeetingDetailEmpCellArc.h"
#import "LGMeetingDetailNormalCellArc.h"

#import "UIAdapterUtil.h"

#import "SettingItem.h"

#import "ASIHTTPRequest.h"

#import "JSONKit.h"

#import "StringUtil.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "Emp.h"
#import "UserDefaults.h"
#import "ScannerViewController.h"
#import "LGMettingDefine.h"
#import "LGMettingUtilARC.h"
#import "WXMsgDialog.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface LGMettingDetailViewControllerArc ()<UITextViewDelegate, LGMeetingDetailEmpCellArcDelegate, UITableViewDataSource, UITableViewDelegate>

{
    BOOL _isShowMoreEmp;
    ASIHTTPRequest *request;
    NSDictionary *dataDic;
    conn *_conn;
    eCloudDAO *db;
    UIImageView *logaView;
    UIButton *signButton;
    CGFloat cellHeight;
    UIView *headerView;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSArray *empArray;

@property (nonatomic, strong) NSMutableArray *detailsArr;
@property(strong,nonatomic) Emp *emp;

@end

@implementation LGMettingDetailViewControllerArc

static LGMettingDetailViewControllerArc *_lgMettingDetailViewControllerArc;

+(LGMettingDetailViewControllerArc *)getLGMettingDetailViewControllerArc
{
    if(_lgMettingDetailViewControllerArc == nil)
    {
        _lgMettingDetailViewControllerArc = [[self alloc]init];
    }
    return _lgMettingDetailViewControllerArc;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIAdapterUtil hideTabBar:self];
    
    Emp *emp = [conn getConn].curUser;
    NSString *empID = [NSString stringWithFormat:@"%@",emp.empCode];
    NSDictionary *dict = [UserDefaults getLanGuangMeetingSign:self.idNum];
    
    
    NSString *buttonStr;
    if (dict == nil) {
        
        buttonStr = @"签到";
        
    }else{
        
        
        if ([dict[@"data"]isEqualToString:@"0"]) {
            
            signButton.hidden = YES;
            
        }else{
            
            buttonStr = @"签退";
        }
        
    }
    
    [signButton setTitle:buttonStr forState:UIControlStateNormal];
}

- (void)HTTPRequestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"请求出错");
}

- (void)HTTPRequestSucceeded:(ASIHTTPRequest *)request
{
    NSDictionary *dic = [request.responseString objectFromJSONString];
    dataDic = dic[@"data"];
    NSLog(@"dataDic %@", dataDic);

    NSMutableArray *mArr = [NSMutableArray array];
    
    SettingItem *item = nil;
    
//    item = [[SettingItem alloc] init];
//    item.itemName = dataDic[@"confName"];
//    [mArr addObject:item];
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"主持人";
//    if (dataDic[@"hostName"]) {
//        
//        Emp *emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:dataDic[@"hostName"]];
//        Emp *emp = [[eCloudDAO getDatabase] getEmpFromMemoryByEmpCode:dataDic[@"hostName"]];
    
    //}
    item.itemValue = dataDic[@"hostName"];
    [mArr addObject:item];
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"会议时间";
   
//    NSString *hours =[self intervalFromLastDate:dataDic[@"startTime"] toTheDate:dataDic[@"endtime"]];
//    NSString *time = [NSString stringWithFormat:@"%@   %@",dataDic[@"starttime"],hours];
    item.itemValue = [NSString stringWithFormat:@"%@   %@",dataDic[@"startTime"]?:@"",dataDic[@"duration"]?:@""];
    [mArr addObject:item];
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"会议地点";
    item.itemValue = dataDic[@"location"];
    [mArr addObject:item];
    
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"会议室";
    item.itemValue = dataDic[@"meetingRoom"];
    [mArr addObject:item];
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"会议内容";
    item.itemValue = dataDic[@"content"];
    [mArr addObject:item];
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"会议链接";
    BOOL isHost = [self isHost:dataDic[@"hostName"]];
    NSString *link = dataDic[@"protocolJoinUrl"];
    if (isHost && [dataDic[@"confType"]intValue] == 1) {
        
        link = dataDic[@"protocolHostStartUrl"];
    }
    item.itemValue = link;
    [mArr addObject:item];
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"会议号";
    item.itemValue = dataDic[@"confNumber"];
    [mArr addObject:item];
    
    item = [[SettingItem alloc] init];
    item.itemName  = @"会议密码";
    item.itemValue = dataDic[@"confPassword"];
    [mArr addObject:item];
    
    
    self.empArray = dataDic[@"mbrArray"];
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSDictionary *dict in self.empArray) {
        
        [string appendFormat:@"%@、",dict[@"logname"]];
        
    }
    item = [[SettingItem alloc] init];
    item.itemName = @"参会人员";
    item.itemValue = string;
    [mArr addObject:item];
    
    _dataArray = [mArr copy];
    
    // 回到主界面更新界面
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        self.tableView.tableHeaderView = [self customHeaderView];
    });
}


- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
        self.emp = [db getEmpInfo:_conn.userId];
//
//        http://222.209.223.92:9013/middleware/conference/getMeetingById?md5key=d5fe3f61b50ae4ac1f6a26000e82978b&timeStamp=1497514715036&account=lhai&access_token=4e28350c093e4035bbe16745e86ea6c8&id=1434426483


        Emp *emp = [conn getConn].curUser;
        NSString *curTime = [[conn getConn] getSCurrentTime];
        NSString *empID = [NSString stringWithFormat:@"%@",emp.empCode];
        NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%@%@",empID,curTime,LGmd5_password]];
        NSString *oaToken = [UserDefaults getLoginToken];
        NSString *OAurl = [NSString stringWithFormat:@"%@/middleware/conference/getMeetingById?",[LGMettingUtilARC get9013Url]];
        NSString *string = [NSString stringWithFormat:@"%@account=%@&md5key=%@4&access_token=%@&id=%@",OAurl,empID,md5Str,oaToken,self.idNum];
        NSURL *url = [NSURL URLWithString:string];
        
        if (request == nil)
        {
            request = [[ASIHTTPRequest alloc] initWithURL:url];
            [request setDelegate:self];
            [request setDidFailSelector:@selector(HTTPRequestFailed:)];
            [request setDidFinishSelector:@selector(HTTPRequestSucceeded:)];
            [request startAsynchronous];
        }
    }

    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [UIAdapterUtil processController:self];
//    [UIAdapterUtil setBackGroundColorOfController:self];
    
    self.title = @"会议详情";
    
    _detailsArr = [NSMutableArray array];
    signButton = [UIAdapterUtil setRightButtonItemWithTitle:@"签到" andTarget:self andSelector:@selector(signIn)];
    signButton.hidden = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-20) style:(UITableViewStylePlain)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.tableHeaderView = [self customHeaderView];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LGMeetingDetailCellArc" bundle:nil] forCellReuseIdentifier:@"LGMeetingDetailCellArc"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LGMeetingDetailEmpCellArc" bundle:nil] forCellReuseIdentifier:@"LGMeetingDetailEmpCellArc"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LGMeetingDetailNormalCellArc" bundle:nil] forCellReuseIdentifier:@"LGMeetingDetailNormalCellArc"];
    
    [UIAdapterUtil removeLeftSpaceOfTableViewCellSeperateLine:self.tableView];
    
    logaView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 20, 100, 100)];
    logaView.image = [StringUtil getImageByResName:@"end.png"];
    logaView.hidden = YES;
    [self.tableView addSubview:logaView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popTip:) name:METTING_POP_TIP object:nil];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
}

- (void)signIn
{
    ScannerViewController *scanner = [[ScannerViewController alloc]init];
    scanner.processType = 1;
    scanner.delegate = self;
    [self.navigationController pushViewController:scanner animated:YES];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0)
//    {
//        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        SettingItem *item = self.dataArray[indexPath.row];
//        UIColor *_color;
//        self.type = dataDic[@"grade"];
//        if ([self.type isEqualToString:@"非正式"]) {
//            //string = @"一般";
//            _color = [UIColor blueColor];
//        }else{
//            //string = @"重要";
//            _color = [UIColor redColor];
//        }
//        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"[%@]%@",self.type,item.itemName?:@""]];
//        
//        [AttributedStr addAttribute:NSForegroundColorAttributeName
//         
//                              value:_color
//         
//                              range:NSMakeRange(1, self.type.length)];
//        
//        cell.textLabel.attributedText = AttributedStr;
//        
//        return cell;
//    }
//    if (indexPath.row == 3)
//    {
//        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
//        
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 8, 100, 25)];
//        SettingItem *item = self.dataArray[indexPath.row];
//        titleLabel.text = item.itemName;
//        [cell.contentView addSubview:titleLabel];
//        
//        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(22, 40, SCREEN_WIDTH-22*2, 70)];
//        self.textView.delegate = self;
//        self.textView.text = item.itemValue;
//        [self.textView setFont:[UIFont systemFontOfSize:15]];
//        self.textView.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1];
//        [cell.contentView addSubview:self.textView];
//        
//        
//        return cell;
//    }
    if (indexPath.row == 5)
    {
        LGMeetingDetailCellArc *cell = [tableView dequeueReusableCellWithIdentifier:@"LGMeetingDetailCellArc"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dict = dataDic;
        cell.idNum = self.idNum;
        SettingItem *item = self.dataArray[indexPath.row];
        cell.titleLabel.text = item.itemName;
        cell.valueLabel.text = item.itemValue?:@"";
        cell.attendConfBtn.tag = indexPath.row;
        

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *endTime = [dateFormatter dateFromString:dataDic[@"endTime"]];
        BOOL isEnd = [self compareOneDay:[self getCurrentTime] withAnotherDay:endTime];

        if (isEnd) {
            
            logaView.hidden = NO;
            logaView.frame = CGRectMake(SCREEN_WIDTH-132, headerView.frame.size.height + 12, 120, 120);
            
        }else{
            
            signButton.hidden = NO;
        }
        BOOL isHost =  [self isHost:dataDic[@"hostName"]];
        NSString *buttonName = @"立即入会";
        if ([dataDic[@"confType"]intValue] == 0) {
            
            cell.attendConfBtn.userInteractionEnabled=NO;
            
        }else if ([dataDic[@"confType"]intValue] == 2){
            
            if ([dataDic[@"display"] intValue] !=0) {
                
                buttonName = @"加入会议";
                [cell.attendConfBtn setTitle:@"加入会议" forState:(UIControlStateNormal)];
                [self isShow:cell.attendConfBtn ishidden:NO];
                if (isEnd) {
                    [self isShow:cell.attendConfBtn ishidden:YES];
                }
            }
        }else{
            
            
            if (isHost && [dataDic[@"confType"]intValue] == 1) {
                
                buttonName = @"发起会议";
            }
            
            if (indexPath.row == 5)
            {
                if (isHost) {
                    
                    NSString *protocolHostStartUrl = dataDic[@"protocolHostStartUrl"];
                    
                    if (protocolHostStartUrl.length) {
                        
                        [cell.attendConfBtn setTitle:buttonName forState:(UIControlStateNormal)];
                        [self isShow:cell.attendConfBtn ishidden:NO];
                        if (isEnd) {
                            [self isShow:cell.attendConfBtn ishidden:YES];
                        }
                    }
                    
                }else{
                    
                    NSString *protocolJohnUrl = dataDic[@"protocolJoinUrl"];
                    if (protocolJohnUrl.length) {
                        
                        [cell.attendConfBtn setTitle:buttonName forState:(UIControlStateNormal)];
                        [self isShow:cell.attendConfBtn ishidden:NO];
                        if (isEnd) {
                            [self isShow:cell.attendConfBtn ishidden:YES];
                        }
                    }
                }
                //[cell.attendConfBtn setTitle:buttonName forState:(UIControlStateNormal)];
            }
            
            
        }
        [UIAdapterUtil alignHeadIconAndCellSeperateLine:self.tableView withOriginX:cell.valueLabel.frame.origin.x];
        return cell;
    }
    else if (indexPath.row == 6)
    {
        LGMeetingDetailCellArc *cell = [tableView dequeueReusableCellWithIdentifier:@"LGMeetingDetailCellArc"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dict = dataDic;
        cell.idNum = self.idNum;
        SettingItem *item = self.dataArray[indexPath.row];
        cell.titleLabel.text = item.itemName;
        cell.valueLabel.text = item.itemValue?:@"";
        
        cell.attendConfBtn.tag = indexPath.row;
        [cell.attendConfBtn.layer setMasksToBounds:YES];
        [cell.attendConfBtn.layer setCornerRadius:3];
        
        if ([dataDic[@"confType"]intValue] == 1) {
            
            NSString *tel = dataDic[@"confNumber"];
            if (tel) {
                
                [cell.attendConfBtn setTitle:@"电话入会" forState:(UIControlStateNormal)];
                [self isShow:cell.attendConfBtn ishidden:NO];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSDate *endTime = [dateFormatter dateFromString:dataDic[@"endTime"]];
                BOOL isEnd = [self compareOneDay:[self getCurrentTime] withAnotherDay:endTime];
                
                if (isEnd) {
                    [self isShow:cell.attendConfBtn ishidden:YES];
                }
                
            }
        }else{
            
            cell.valueLabel.text = @"";
            cell.attendConfBtn.hidden = YES;

        }
        
        [UIAdapterUtil alignHeadIconAndCellSeperateLine:self.tableView withOriginX:cell.valueLabel.frame.origin.x];
        return cell;
    }

//    else if (indexPath.row == (self.dataArray.count-1))
//    {
//        LGMeetingDetailEmpCellArc *cell = [tableView dequeueReusableCellWithIdentifier:@"LGMeetingDetailEmpCellArc"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.showDelegate = self;
//        
//        cell.empArray = self.empArray;
//        SettingItem *item = self.dataArray[indexPath.row];
//        cell.titleLabel.text = item.itemName;
//        
//        return cell;
//    }
    else
    {
        LGMeetingDetailNormalCellArc *cell = [tableView dequeueReusableCellWithIdentifier:@"LGMeetingDetailNormalCellArc"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        SettingItem *item = self.dataArray[indexPath.row];
        cell.titleLabel.text = item.itemName;
        cell.valueLabel.text = item.itemValue?:@"";
        
        if (indexPath.row == (self.dataArray.count-1)){
            
//            CGRect _frame = cell.titleLabel.frame;
//            _frame.size.height = 46;
//            cell.titleLabel.frame = _frame;
            cell.titleLabel.text = [NSString stringWithFormat:@"%@\r(%lu人)",item.itemName,(unsigned long)self.empArray.count];
            
        }
//        if (indexPath.row == 3) {
//            
//            CGFloat labelHeight = [cell.valueLabel sizeThatFits:CGSizeMake(cell.valueLabel.frame.size.width, MAXFLOAT)].height;
//            NSNumber *count = @((labelHeight) / cell.valueLabel.font.lineHeight);
//            
//            NSLog(@"共 %td 行", [count integerValue] -1);
//        }
        [UIAdapterUtil alignHeadIconAndCellSeperateLine:self.tableView withOriginX:cell.valueLabel.frame.origin.x];
        return cell;
    }
    
    return nil;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == (self.dataArray.count-1))
//    {
//        return [StringUtil getHeightWithItemCount:_empArray.count isShowMoreEmp:_isShowMoreEmp];
//    }
//    if (indexPath.row == 3)
//    {
//        return 120;
//    }
//    36
    SettingItem *item = self.dataArray[indexPath.row];
    
    CGSize size = [self sizeWithLabelWidth:SCREEN_WIDTH-128 font:17 text:item.itemValue];
    
    /** 会议地点有换行符。单独处理 */
    if (indexPath.row == 3) {
        
        LGMeetingDetailNormalCellArc * cell = (LGMeetingDetailNormalCellArc *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
 ;
        CGFloat labelHeight = [cell.valueLabel sizeThatFits:CGSizeMake(cell.valueLabel.frame.size.width, MAXFLOAT)].height;
//        NSNumber *count = @((labelHeight) / cell.valueLabel.font.lineHeight);
//        
//        cellHeight = ([count integerValue] -0) * cell.valueLabel.font.lineHeight;
        cellHeight = labelHeight;
        if (cellHeight <= cell.valueLabel.font.lineHeight+2 ) {
            
            cellHeight = 51;
            
        }else{
            
            cellHeight = cellHeight + 36;
            
        }
        return cellHeight;
    }
    
    if (size.height <= 51) {
        
        cellHeight = 51;
        
    }else{
  
        cellHeight = size.height + 36;
        
    }
    if (indexPath.row == (self.dataArray.count-1)){
        
        if (cellHeight <= 69) {
            
            cellHeight = 69;
        }
        
    }
    /** 5和6不需要换行 */
    if (indexPath.row == 5 ||indexPath.row == 6) {
        
        cellHeight = 51;
    }                   
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 12;
    }
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textView resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textView resignFirstResponder];
}

#pragma mark - <UITextViewDelegate>
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

#pragma mark - <LGMeetingDetailEmpCellArcDelegate>
- (void)showMoreEmp:(BOOL)isShow
{
    _isShowMoreEmp = isShow;
    
    [self.tableView reloadData];
}

- (BOOL)isHost:(NSString *)loginName
{
    BOOL isYES;

    if ([self.emp.empCode isEqualToString:loginName]) {
        
        isYES = YES;
    }

    return isYES;
}

- (NSDate *)getCurrentTime{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateTime=[formatter stringFromDate:[NSDate date]];
    NSDate *date = [formatter dateFromString:dateTime];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    return localeDate;
}

- (BOOL )compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    BOOL isEnd;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];

    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: dateB];
    NSDate *localeDate = [dateB  dateByAddingTimeInterval: interval];
    
    NSComparisonResult result = [dateA compare:localeDate];

    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        isEnd = YES;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        isEnd = NO;
    }else{
        isEnd = YES;
    }
    //NSLog(@"Both dates are the same");
    return isEnd;
    
}

- (NSString *)intervalFromLastDate: (NSString *) dateString1  toTheDate:(NSString *) dateString2
{
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
    NSLog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *d1=[date dateFromString:dateString1];
    
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    NSDate *d2=[date dateFromString:dateString2];
    
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
    NSString *min=@"";
    NSString *sen=@"";
    
    //sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    //        min = [min substringToIndex:min.length-7];
    //    秒
    sen=[NSString stringWithFormat:@"%@", sen];
    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    //        min = [min substringToIndex:min.length-7];
    //    分
    min=[NSString stringWithFormat:@"%@", min];
    //    小时
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    //        house = [house substringToIndex:house.length-7];
    house=[NSString stringWithFormat:@"%@", house];
    if ([house isEqualToString:@"0"]) {
        
        timeString=[NSString stringWithFormat:@"%@分钟",min];
        
    }else if ([min isEqualToString:@"0"])
    {
        timeString=[NSString stringWithFormat:@"%@小时",house];
        
    }else{
        
        timeString=[NSString stringWithFormat:@"%@小时%@分",house,min];
    }
    

    return timeString;
}

- (void)popTip:(NSNotification *)notif{
    
  [WXMsgDialog toastCenter:@"会议未到开始时间，请稍后再试" onView:self.view delay:2.0f];
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}

- (UIView *)customHeaderView{
    
    UIColor *_color;
    self.type = dataDic[@"grade"];
    if ([self.type isEqualToString:@"非正式"]) {
        
        _color = [UIColor blueColor];
    }else{
        
        _color = [UIColor redColor];
    }
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"[%@]%@",self.type?:@"",dataDic[@"confName"]?:@""]];
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName
     
                          value:_color
     
                          range:NSMakeRange(1, self.type.length)];
    
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:17];
    //    label.text = @"[正式]2017年半年度工作总结暨下半年经营部署会2017年半年度工作总结暨下半年经营部署会";
    label.attributedText = AttributedStr;
    CGSize titleSize = [self sizeWithLabelWidth:SCREEN_WIDTH-24 font:17 text:label.text];
    
    [headerView addSubview:label];
    
    CGRect _frame = label.frame;
    _frame.size = titleSize;
    _frame.origin.x = 12;
    _frame.origin.y = 18;
    label.frame = _frame;
    
    _frame = headerView.frame;
    _frame.size.height = titleSize.height + 36;
    headerView.frame = _frame;

    return headerView;
    
}

- (CGSize)sizeWithLabelWidth:(CGFloat)width font:(float )font text:(NSString *)text{
    
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
    
    return titleSize;
}


- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:METTING_POP_TIP object:nil];
    
}

//返回 按钮
-(void) backButtonPressed:(id) sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)isShow:(UIButton *)btn ishidden:(BOOL)ishidden{
    
    UIButton *button = btn;
    if (ishidden) {
        
        button.userInteractionEnabled=NO;//交互关闭
        [button setTitleColor:[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1/1.0]forState:UIControlStateNormal];
        button.layer.cornerRadius = 5.0;
        button.layer.borderColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1/1.0].CGColor;
        button.layer.borderWidth = 1.0f;
//        button.alpha=0.4;//透明度
//        button.backgroundColor = [UIColor grayColor];
        
    }else{
        
        [button setTitleColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]forState:UIControlStateNormal];
        button.layer.cornerRadius = 5.0;
        button.layer.borderColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0].CGColor;
        button.layer.borderWidth = 1.0f;
    }
}
@end
