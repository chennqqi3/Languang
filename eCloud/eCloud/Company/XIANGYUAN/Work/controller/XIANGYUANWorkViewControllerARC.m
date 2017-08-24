//
//  XIANGYUANWorkViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANWorkViewControllerARC.h"
#import "Emp.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "APPPlatformDOA.h"
#import "XIANGYUANWorkCellARC.h"
#import "APPListModel.h"
#import "UserDefaults.h"
#import "APPConn.h"
#import "XIANGYUANAgentViewControllerARC.h"
#import "eCloudDefine.h"
#import "JSONKit.h"
#import "ServerConfig.h"


@interface XIANGYUANWorkViewControllerARC ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSMutableArray *userDataTextArray;
@property(nonatomic,strong) NSMutableArray *repArr;
@property (nonatomic, strong) NSMutableArray *allGroupIdArr;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property(retain,nonatomic) Emp *emp;

@end

@implementation XIANGYUANWorkViewControllerARC
{
    conn *_conn;
    eCloudDAO *db;
    
    UITableView *myTableView;
}

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    self.title= [StringUtil getAppLocalizableString:@"main_app"];
    [UIAdapterUtil showTabar:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _allGroupIdArr = [NSMutableArray array];
    self.repArr = [NSMutableArray array];
    self.dataSource = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    self.userDataTextArray = [NSMutableArray array];
    
    myTableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , SCREEN_HEIGHT-NAVIGATIONBAR_HEIGHT-TABBAR_HEIGHT-STATUSBAR_HEIGHT) style:UITableViewStylePlain];
    [UIAdapterUtil setPropertyOfTableView:myTableView];
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundView = nil;
    myTableView.backgroundColor=[UIColor clearColor];
    [myTableView  setSeparatorColor:[UIColor colorWithRed:0xd9/255.0 green:0xd9/255.0 blue:0xd9/255.0 alpha:1]];
    myTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:myTableView];

    [self getAppListInfo];
    
}

- (void)getAppListInfo
{
    // 保存完同步的轻应用发出的通知，刷新整个页面
    if (self.userDataTextArray != nil && [self.userDataTextArray count]) {
        [self.userDataTextArray removeAllObjects];
    }
    self.userDataTextArray = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
    if (self.allGroupIdArr != nil && [self.allGroupIdArr count]) {
        [self.allGroupIdArr removeAllObjects];
    }
    if (self.dataSource != nil && [self.dataSource count]) {
        [self.dataSource removeAllObjects];
    }
    for (int i = 0 ; i < self.userDataTextArray.count; i++) {
        
        NSArray *arr = self.userDataTextArray[i];
        for (APPListModel *model in arr) {
            
            [self.allGroupIdArr addObject:[NSString stringWithFormat:@"%d",model.groupId]];

        }
        
    }
    self.repArr = [self arrayWithMemberIsOnly:self.allGroupIdArr];
    NSArray *result = [self.repArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {

            return [obj1 compare:obj2];
     
    }];
  
    for (NSString *nowTim in result) {
        
        NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
        
        for (int i = 0 ; i < self.userDataTextArray.count; i++) {
            
            NSArray *arr = self.userDataTextArray[i];

            for (APPListModel *model in arr) {

                NSString *twoTim = [NSString stringWithFormat:@"%d",model.groupId];
                
                if([twoTim isEqualToString:nowTim]){

                    [tmpArr addObject:model];
                    
                }
            }
            
        }
        
        [self.dataSource addObject:tmpArr];

    }
    [myTableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *arrModels = self.dataSource[section];
    return arrModels.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    if (section == 0){
        
        return 15;
    }
    else
        return 18;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    static NSString *CellIdentifier = @"Cell1";
    
    XIANGYUANWorkCellARC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[XIANGYUANWorkCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (self.dataSource.count) {
        NSArray *modelArr = self.dataSource[indexPath.section];
        APPListModel *appModel = modelArr[indexPath.row];
        
        [cell configCellWithDataModel:appModel];
        
//        if (indexPath.section == self.dataSource.count-1) {
//            
//            cell._label.textColor = [UIColor colorWithRed:0x6e/255.0 green:0x6e/255.0 blue:0x6e/255.0 alpha:1];
//        }
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.count) {
        NSArray *modelArr = self.dataSource[indexPath.section];
        APPListModel *appModel = modelArr[indexPath.row];
        XIANGYUANAgentViewControllerARC *agent = [[XIANGYUANAgentViewControllerARC alloc]init];
        if (appModel.appid == XIANGYUAN_BAOBIAO_APP_ID) {
            
            NSString *urlStr = [NSString stringWithFormat:@"%@&fr_username=%@&fr_password=%@",appModel.apphomepage,[UserDefaults getUserAccount],[UserDefaults getUserPassword]];
            agent.urlstr = urlStr;
            
        }else if(appModel.appid == XIANGYUAN_ZHIDU_APP_ID){
            
            NSString *jsonToekn = [[UserDefaults getXIANGYUANAppToken] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData* jsonData = [jsonToekn dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [jsonData objectFromJSONData];
            NSString *token = resultDict[@XIANGYUAN_FANWEI_TOKEN_KEY];
            NSString *urlStr = [[NSString stringWithFormat:@"%@?usercode=%@&token=%@",appModel.apphomepage,[UserDefaults getUserAccount],token]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            agent.urlstr= urlStr;
            
        }else{
            
            if(appModel.appid == XIANGYUAN_DAIBAN_APP_ID){
                
                agent.isWorkDAIBAN = YES;
                
            }
            NSString *usercode = [UserDefaults getUserAccount];
            NSString *token = [UserDefaults getXIANGYUANAppToken];
            NSString *urlStr = [[NSString stringWithFormat:@"%@?usercode=%@&token=%@",appModel.apphomepage,usercode,token ]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            agent.urlstr = urlStr;
        }
        
        [self.navigationController pushViewController:agent animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{

    view.tintColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
    
}

- (void)handleCmd:(NSNotification *)notif{
    eCloudNotification	*notifObj = (eCloudNotification *)[notif object];
    if (notifObj.cmdId == refresh_app_list) {
    
        [self getAppListInfo];
    }
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

- (void)returnString:(NSString *)string{
    
    if ([string isEqualToString:@"todo"]) {
        
        NSString *urlString = [[ServerConfig shareServerConfig]getXYDAIBANUrl];
        XIANGYUANAgentViewControllerARC *agent = [[XIANGYUANAgentViewControllerARC alloc]init];
        NSString *usercode = [UserDefaults getUserAccount];
        NSString *token = [UserDefaults getXIANGYUANAppToken];
        NSString *urlStr = [[NSString stringWithFormat:@"%@?usercode=%@&token=%@",urlString,usercode,token]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        agent.urlstr = urlStr;
        [self.navigationController pushViewController:agent animated:NO];
        
    }
    
}

@end
