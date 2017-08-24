//
//  NewMyViewControllerOfCustomTableview.m
//  eCloud
//
//  Created by yanlei on 15/8/27.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "NewMyViewControllerOfCustomTableview.h"
#import "ServerConfig.h"
#import "ApplicationManager.h"
#import "eCloudNotification.h"
#import "openWebViewController.h"

#import "UserTipsUtil.h"
#import "TabbarUtil.h"

#import "conn.h"
#import "LoginConn.h"
#import "AppConn.h"

#import "CustomMyCell.h"
#import "eCloudDAO.h"
#import "ImageUtil.h"
#import "UIAdapterUtil.h"
#import "userInfoViewController.h"
#import "FileAssistantViewController.h"
#import "APPListViewController.h"

#import "APPListModel.h"
#import "APPPlatformDOA.h"
#import "UserDefaults.h"
#import "myCutomCell.h"
#import "AgentListViewController.h"
#import "EmailViewController.h"
#import "AsiForWebServiceViewController.h"

@interface NewMyViewControllerOfCustomTableview ()

@property(nonatomic,retain) NSMutableArray *userDataTextArray;
@property(retain,nonatomic) Emp *emp;

@property(nonatomic,assign)int value;
@property(nonatomic,assign)int isHaveNewWorkO;
@end

@implementation NewMyViewControllerOfCustomTableview
{
    conn *_conn;
    eCloudDAO *db;
    UITableView *myTableView;
    /** 是否需要自动打开 代办界面 */
    BOOL needAutoOpenAgent;
    /** 是否需要等待loginToken */
    BOOL isWaitingForLoginToken;
}

@synthesize appInfo;

- (void)dealloc{
    self.appInfo = nil;
    
    self.userDataTextArray = nil;
    self.emp = nil;
    [_conn removeObserver:self forKeyPath:@"connStatus"];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APPLIST_RECUNREAD_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APPLIST_GOTOAGENTDETAIL_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ModifyThePicture" object:nil];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
        
        [_conn addObserver:self forKeyPath:@"connStatus" options:NSKeyValueObservingOptionNew context:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processLoginAck:) name:LOGIN_NOTIFICATION object:nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleRecUnreadCmd:) name:APPLIST_RECUNREAD_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleGotoAgentDetailCmd:) name:APPLIST_GOTOAGENTDETAIL_NOTIFICATION object:nil];
    //刷新头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:@"ModifyThePicture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reCalculateFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    self.userDataTextArray = [NSMutableArray array];
    
    myTableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:myTableView];
//    myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundView = nil;
    myTableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:myTableView];
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height);
    [myTableView release];
    needAutoOpenAgent = NO;
    if (([ApplicationManager getManager].needOpenAgent)) {
        self.appInfo =  [ApplicationManager getManager].appInfo;
        needAutoOpenAgent = YES;

        [ApplicationManager getManager].needOpenAgent = NO;
        [ApplicationManager getManager].appInfo = nil;
    }
    
    [self getAppListInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}

/**
 获取当前用户信息实体
 */
- (void)getUserInfo
{
    self.emp = [db getEmpInfo:_conn.userId];
    
    if (self.emp == nil) {
        self.emp = [LoginConn getConn].tempEmp;
    }
    
//    [myTableView reloadData];
     NSLog(@"%s 获取到当前用户资料需要刷新",__FUNCTION__);
}


/**
 获取轻应用列表
 */
- (void)getAppListInfo
{
    // 保存完同步的轻应用发出的通知，刷新整个页面
    if (self.userDataTextArray != nil && [self.userDataTextArray count]) {
        [self.userDataTextArray removeAllObjects];
    }
    self.userDataTextArray = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self getUserInfo];
    
    [self displayTabBar];
    
//    [self reCalculateFrame];
    
    self.title = [StringUtil getAppLocalizableString:@"main_my"];
    
    [self reloadDataAndDisplayNewMsgNumber];
    
    // 访问263邮箱的webservice服务
    [self unReadForEmailOption];
    // 获取所有的轻应用的未读消息个数
    [self unReadForAllApp];
    // 获取轻应用客储消息未读数
    [self unReadForGuest];
    // 获取工作圈消息未读数
    [[self class] unReadForWorkWorld];

    // 是否需要打开轻应用
    if (needAutoOpenAgent) {
        needAutoOpenAgent = NO;
        [self autoOpenAgentList];
    }

}


/**
 自动打开轻应用
 */
- (void)autoOpenAgentList
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    isWaitingForLoginToken = NO;
    
    switch (_conn.userStatus) {
        case status_online:
        {
            [self findAndOpenAgentList];
        }
            break;
        default:
            //                提示请稍候.. 如果用户登录成功了，那么就可以关闭提示框了
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
            isWaitingForLoginToken = YES;
            break;
    }
}

#pragma mark - 获取工作圈消息未读数 并且设置设置界面 tabbar 上的显示
+ (void)unReadForWorkWorld
{
//    if (![[APPPlatformDOA getDatabase]isExistAppByAppId:LONGHU_WORK_APP_ID]) {
//        [UserDefaults saveAppUnreadWithAppId:LONGHU_WORK_APP_ID andUnread:0];
//        [UserDefaults saveRedDotOfAppId:LONGHU_WORK_APP_ID andRedDot:NO];
//        return;
//    }
    
    dispatch_queue_t queue = dispatch_queue_create("unread of work world", NULL);
    
    dispatch_async(queue, ^{
        // 获取工作圈消息未读数
        NSMutableArray * wsParas = [[[NSMutableArray alloc] initWithObjects:
                                     @"usercode",[UserDefaults getUserAccount],
                                     nil]autorelease];
        
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserDefaults getUserAccount],@"usercode", nil];
//        NSString *jsonStr = [dict JSONString];
//        NSMutableArray * wsParas = [[[NSMutableArray alloc] initWithObjects:
//                                     @"jsonInput",jsonStr,
//                                     nil]autorelease];
        
        NSString *testService = @"http://114.251.168.251:8080/worko/services/";
        NSString *productService = @"http://worko.longfor.com:59650/worko/services/";
        //http://worko.longfor.com:59650/worko/services/WorkoNotice?wsdl
        NSString *serviceStr = testService;
        if ([[ServerConfig shareServerConfig].primaryServer rangeOfString:@"mop.longfor.com"].length > 0) {
            serviceStr = productService;
        }
        NSString * theResponse = [AsiForWebServiceViewController getSOAP11WebServiceResponse:serviceStr
                                                                              webServiceFile:@"WorkoNotice"
                                                                                xmlNameSpace:@"http://webservice.worko.com"
                                                                              webServiceName:@"notice"
                                                                                wsParameters:wsParas];
        
        //接下来的代码就是检查errMsg有没有内容
        //对theResponse响应字符串的解析了
        NSRange totalStartRange = [theResponse rangeOfString:@"<ns:return>"];
        NSRange totalEndRange = [theResponse rangeOfString:@"</ns:return>"];
        if (totalStartRange.length > 0 && totalEndRange.length > 0) {
            
            totalStartRange.location = totalStartRange.location+totalStartRange.length;
            totalStartRange.length = totalEndRange.location - totalStartRange.location;
            
            //            {"status":"0", "msg":"成功！", "data":{"isHaveNewWorkO":false, "notice":0}}
//            返回结果判断逻辑。
//            如果 notice>0 则显示notice的数目;
//            如果notice==0 且 isHaveNewWorkO为true，则显示小红点：
            NSString *totalCount = [theResponse substringWithRange:totalStartRange];
            [LogUtil debug:[NSString stringWithFormat:@"%s 工作圈消息未读数是%@",__FUNCTION__,totalCount]];
            
            NSData* jsonData = [totalCount dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [jsonData objectFromJSONData];
            
            NSString *status = dic[@"status"];
            if ([status isEqualToString:@"0"]) {
                NSDictionary *unreadDic = dic[@"data"];
                NSLog(@"unreadDic===%@",unreadDic);
                        //                    appid101

                int _value = [unreadDic[@"notice"]intValue];
                int _isHaveNewWorkO = [unreadDic[@"isHaveNewWorkO"]intValue];
                int appId = LONGHU_WORK_APP_ID;
                
                if (_value > 0) {
                    [UserDefaults saveAppUnreadWithAppId:LONGHU_WORK_APP_ID andUnread:_value];
                }else if (_value == 0 && _isHaveNewWorkO == 0){
                    [UserDefaults saveRedDotOfAppId:LONGHU_WORK_APP_ID andRedDot:NO];
                    [UserDefaults saveAppUnreadWithAppId:LONGHU_WORK_APP_ID andUnread:_value];
                }else{
                    [UserDefaults saveRedDotOfAppId:LONGHU_WORK_APP_ID andRedDot:YES];
                    [UserDefaults saveAppUnreadWithAppId:LONGHU_WORK_APP_ID andUnread:_value];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([UIAdapterUtil isHongHuApp]) {
                        //工作圈消息提醒
                        if (_value > 0) {
                            //显示数字
                            [TabbarUtil setTabbarBage:[NSString stringWithFormat:@"%d",_value] andTabbarIndex:[eCloudConfig getConfig].settingIndex];
                            //                        [UserDefaults saveWorkWorldIsreload:@"YES"];
                            
                        }else if (_value == 0 && _isHaveNewWorkO == 1){
                            //显示红点
                            [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].settingIndex];
                            //                        [UserDefaults saveWorkWorldIsreload:@"YES"];
                        }else{
                            //什么都不显示
                            [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].settingIndex];
                            //                        [UserDefaults saveWorkWorldIsreload:@"NO"];
                            
                        }
                    }
                    
                });
            }
        }
    });
    dispatch_release(queue);
}
#pragma mark - 获取轻应用客储消息未读数
- (void)unReadForGuest{
    
    if (![[APPPlatformDOA getDatabase]isExistAppByAppId:LONGHU_GUSET_APP_ID]) {
        [UserDefaults saveAppUnreadWithAppId:LONGHU_GUSET_APP_ID andUnread:0];
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("unread of guest", NULL);
    
    dispatch_async(queue, ^{
        // 获取客储消息未读数
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserDefaults getUserAccount],@"usercode",@"110",@"appids", nil];
        NSString *jsonStr = [dict JSONString];
        NSMutableArray * wsParas = [[[NSMutableArray alloc] initWithObjects:
                                     @"jsonInput",jsonStr,
                                     nil]autorelease];
        
        NSString *testService = @"http://customer.demo.longhu.net:8080/LHService/services/";
        NSString *productService = @"http://customer.longhu.net:17427/LHService/services/";
        
        NSString *serviceStr = testService;
        if ([[ServerConfig shareServerConfig].primaryServer rangeOfString:@"mop.longfor.com"].length > 0) {
            serviceStr = productService;
        }
        NSString * theResponse = [AsiForWebServiceViewController getSOAP11WebServiceResponse:serviceStr
                                                                              webServiceFile:@"LHServerWebService"
                                                                                xmlNameSpace:@"http://impl.server.webservice.lh.com"
                                                                              webServiceName:@"getAppMessageNum"
                                                                                wsParameters:wsParas];
        
        //接下来的代码就是检查errMsg有没有内容
        //对theResponse响应字符串的解析了
        NSRange totalStartRange = [theResponse rangeOfString:@"<ns:return>"];
        NSRange totalEndRange = [theResponse rangeOfString:@"</ns:return>"];
        if (totalStartRange.length > 0 && totalEndRange.length > 0) {
            
            totalStartRange.location = totalStartRange.location+totalStartRange.length;
            totalStartRange.length = totalEndRange.location - totalStartRange.location;
            
            //            {"status":"1","data":{"appid110":"3"},"msg":"ok"}
            
            NSString *totalCount = [theResponse substringWithRange:totalStartRange];
            [LogUtil debug:[NSString stringWithFormat:@"%s 客储轻应用的未读数是%@",__FUNCTION__,totalCount]];
            
            NSData* jsonData = [totalCount dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [jsonData objectFromJSONData];
            BOOL needRefresh = NO;
            NSString *status = dic[@"status"];
            if ([status isEqualToString:@"1"]) {
                NSDictionary *unreadDic = dic[@"data"];
                NSArray *keys = [unreadDic allKeys];
                for (NSString *_key in keys) {
                    if (_key.length > 5) {
                        
                        int _value = [unreadDic[_key] intValue];
                        //                    appid101
                        int appId = [[_key substringFromIndex:5]intValue];
                        if ([UserDefaults getAppUnreadWithAppId:appId] != _value) {
                            [UserDefaults saveAppUnreadWithAppId:appId andUnread:_value];
                            needRefresh = YES;
                        }
                        
                        NSLog(@"%s appid is %d unread is %d",__FUNCTION__,appId,_value);
                        
                    }
                }
            }
            if (needRefresh) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadDataAndDisplayNewMsgNumber];
                });
            }
        }
    });
    
    dispatch_release(queue);
}
#pragma mark - 获取所有的轻应用的未读消息个数
- (void)unReadForAllApp{
    NSMutableString *appIdsNeedDspUnread = [NSMutableString string];
    
    for (int i = 0; i < self.userDataTextArray.count; i++) {
        NSArray *tempArray = self.userDataTextArray[i];
        for (int j = 0; j < tempArray.count; j++) {
            APPListModel *appModel = tempArray[j];
            NSString *appHomePage = appModel.apphomepage;
            if ([appHomePage rangeOfString:SHOW_COUNT_NUM options:NSCaseInsensitiveSearch].length > 0) {
                if (appIdsNeedDspUnread.length > 0) {
                    [appIdsNeedDspUnread appendString:[NSString stringWithFormat:@",%d",appModel.appid]];
                }else{
                    [appIdsNeedDspUnread appendString:[NSString stringWithFormat:@"%d",appModel.appid]];
                }
            }
        }
    }

    [LogUtil debug:[NSString stringWithFormat:@"%s appIdsNeedDspUnread is %@",__FUNCTION__,appIdsNeedDspUnread]];
    if (appIdsNeedDspUnread.length == 0) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("unread of all app", NULL);
    
    dispatch_async(queue, ^{
        // 获取代办未读个数
        NSMutableArray * wsParas = [[[NSMutableArray alloc] initWithObjects:
                                    @"USERCODE",[UserDefaults getUserAccount],
                                    nil]autorelease];
        
        NSString *testService = @"http://114.251.168.251:8080/lhydsp/services/";
        NSString *productService = @"http://moapproval.longfor.com:39649/moapproval/services/";
        
        NSString *serviceStr = testService;
        if ([[ServerConfig shareServerConfig].primaryServer rangeOfString:@"mop.longfor.com"].length > 0) {
            serviceStr = productService;
        }
        
        NSString * theResponse = [AsiForWebServiceViewController getSOAP11WebServiceResponse:serviceStr
                                                                              webServiceFile:@"AppCountService"
                                                                                xmlNameSpace:@"http://webservice.lh.com"
                                                                              webServiceName:@"AppCount"
                                                                                wsParameters:wsParas];
        
        //接下来的代码就是检查errMsg有没有内容
        //对theResponse响应字符串的解析了
        NSRange totalStartRange = [theResponse rangeOfString:@"<ns:return>"];
        NSRange totalEndRange = [theResponse rangeOfString:@"</ns:return>"];
        if (totalStartRange.length > 0 && totalEndRange.length > 0) {
            
            totalStartRange.location = totalStartRange.location+totalStartRange.length;
            totalStartRange.length = totalEndRange.location - totalStartRange.location;
            
//            {"status":"0","msg":"成功。","data":{"appid101":51}}
            
            NSString *totalCount = [theResponse substringWithRange:totalStartRange];
            [LogUtil debug:[NSString stringWithFormat:@"%s 取到的轻应用的未读数是%@",__FUNCTION__,totalCount]];
            
            NSData* jsonData = [totalCount dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *dic = [jsonData objectFromJSONData];
            
            BOOL needRefresh = NO;
            
            NSString *status = dic[@"status"];
            if ([status isEqualToString:@"0"]) {
                NSDictionary *unreadDic = dic[@"data"];
                NSArray *keys = [unreadDic allKeys];
                for (NSString *_key in keys) {
                    if (_key.length > 5) {
                    int _value = [unreadDic[_key] intValue];
//                    appid101
                    int appId = [[_key substringFromIndex:5]intValue];
                    if ([UserDefaults getAppUnreadWithAppId:appId] != _value) {
                        [UserDefaults saveAppUnreadWithAppId:appId andUnread:_value];
                        needRefresh = YES;
                    }
                    NSLog(@"%s appid is %d unread is %d",__FUNCTION__,appId,_value);
                      }
                }
            }
            if (needRefresh) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadDataAndDisplayNewMsgNumber];
                });
            }
        }
    });
    
    dispatch_release(queue);
}

#pragma mark - 获取263未读邮件的个数
- (void)unReadForEmailOption{
    if (![[APPPlatformDOA getDatabase]isExistAppByAppId:LONGHU_MAIL_APP_ID]) {
        [UserDefaults saveAppUnreadWithAppId:LONGHU_MAIL_APP_ID andUnread:0];
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("unread of email", NULL);
    
    dispatch_async(queue, ^{
        NSString *domain = @"longfor.com";
        NSString *account = @"longfor.com";
        NSString *uid = [UserDefaults getUserAccount];
        NSString *passwd = @"abc";
        NSInteger crypttype = @11;
        NSString *signString = [NSString stringWithFormat:@"%@longfor.comUi87HewT2Z",uid];
        NSString *sign = [StringUtil getMD5Str:signString];
        
        
        //创建WebService的调用参数
        NSMutableArray * wsParas = [[NSMutableArray alloc] initWithObjects:
                                    @"userid",uid,@"domain",domain,@"passwd",passwd,@"crypttype",crypttype,@"account",account,@"sign",sign,
                                    nil];
        
        //调用WebService，获取响应
        NSString * theResponse = [AsiForWebServiceViewController getSOAP11WebServiceResponseWithNTLM:@"http://macom.263.net/axis/"
                                                                                      webServiceFile:@"xmapi"
                                                                                        xmlNameSpace:@"http://macom.263.net/axis/xmapi"
                                                                                      webServiceName:@"getDirInfo_New"
                                                                                        wsParameters:wsParas
                                                                                            userName:@"test"
                                                                                            passWord:@"74rzMgVBSlmMc1Nw"];
        
       //检查响应中是否包含错误
        //    NSString * errMsg = [AsiForWebServiceViewController checkResponseError:theResponse];
        
        //接下来的代码就是检查errMsg有没有内容
        //对theResponse响应字符串的解析了
        NSRange totalStartRange = [theResponse rangeOfString:@"<getDirInfo_NewReturn>"];
        NSRange totalEndRange = [theResponse rangeOfString:@"</getDirInfo_NewReturn>"];
        if (totalStartRange.length > 0 && totalEndRange.length > 0) {

            totalStartRange.location = totalStartRange.location+totalStartRange.length;
            totalStartRange.length = totalEndRange.location - totalStartRange.location;
            NSString *totalCount = [theResponse substringWithRange:totalStartRange];
            
            if ([UserDefaults getAppUnreadWithAppId:LONGHU_MAIL_APP_ID] == totalCount.intValue) {
                //                没有改变
            }else{
                [UserDefaults saveAppUnreadWithAppId:LONGHU_MAIL_APP_ID andUnread:totalCount.intValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadDataAndDisplayNewMsgNumber];
                });
            }
        }
        [wsParas release];
    });
    
    dispatch_release(queue);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 轻应用会进行分组，除了分组后的轻应用还要增加一个组显示用户信息
    return self.userDataTextArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    NSArray *arrModels = self.userDataTextArray[section-1];
    return arrModels.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 15;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section ==0) {
        return 10;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        return myCellHeight;
    }
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    if (section ==0)
    {
        return [self getUserInfoCell];
    }
    
    static NSString *CellIdentifier = @"Cell1";
    
    CustomMyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[CustomMyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (section > 0 && self.userDataTextArray.count) {
        NSArray *modelArr = self.userDataTextArray[indexPath.section-1];
        APPListModel *appModel = modelArr[indexPath.row];
        
        if ([appModel.apphomepage rangeOfString:SHOW_COUNT_NUM options:NSCaseInsensitiveSearch].length > 0 || appModel.appid == LONGHU_MAIL_APP_ID || appModel.appid == LONGHU_GUSET_APP_ID) {
            appModel.unread = [UserDefaults getAppUnreadWithAppId:appModel.appid];
        }else{
//            NSMutableDictionary *dict = [UserDefaults getAppId];
//            NSString *string = [NSString stringWithFormat:@"%d",appModel.appid];
//            if ([dict[string] isEqualToString:@"YES"]) {
            if ([UserDefaults getRedDotOfAppId:appModel.appid]) {
                appModel.unread = -1;
            }else{
                appModel.unread = 0;
            }
        }

        if (appModel.appid == LONGHU_WORK_APP_ID) {
            
            int _value = [UserDefaults getAppUnreadWithAppId:appModel.appid];
            if (_value > 0) {
                appModel.unread = _value;
            }else{
                if ([UserDefaults getRedDotOfAppId:appModel.appid]) {
                    appModel.unread = -1;
                }else{
                    appModel.unread = 0;
                }
            }

            
        }

        [cell configCellWithDataModel:appModel];
    }
    return cell;
}


/**
 获取第一个组的自定义个人信息cell

 @return 自定义cell对象
 */
- (UITableViewCell *)getUserInfoCell
{
    myCutomCell *mCell = [[myCutomCell alloc] init];
    
    mCell.nameLable.text = self.emp.emp_name;
    mCell.iconView.image = [ImageUtil getOnlineEmpLogo:self.emp];
    if (_conn.hasNewVersion) {  // 是否存在新版本
        // 重新计算升级按钮frame
        CGFloat width = [NewMyViewControllerOfCustomTableview widthOfString:mCell.nameLable.text font:mCell.nameLable.font height:mCell.nameLable.frame.size.height];
        CGRect _frame = mCell.newButton.frame;
        _frame.origin.x = mCell.nameLable.frame.origin.x + width + 10;
        _frame.origin.y = mCell.nameLable.frame.origin.y +5;
        mCell.newButton.frame = _frame;
        // 在tabbar上的办公按钮右上角显示红点
        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }else{
        // 隐藏升级按钮
        mCell.newButton.hidden = YES;
    }
    
    return [mCell autorelease];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *topVC = self.navigationController.topViewController;
    if (![topVC isKindOfClass:[self class]]) {
        return;
    }
    if (indexPath.section== 0 && indexPath.row == 0)
    {

//        JsObjectCViewController *userInfoView = [[JsObjectCViewController alloc] init];

          userInfoViewController *userInfoView = [[userInfoViewController alloc] init];

        [self hideTabBar];
        [self.navigationController pushViewController:userInfoView animated:YES];
        [userInfoView release];
    }
    else if(indexPath.section > 0)
    {
        if (self.userDataTextArray.count) {
            NSArray *modelArr = self.userDataTextArray[indexPath.section-1];
            APPListModel *appModel = modelArr[indexPath.row];
            //            if (appModel.appid == 101) {
            //                [self openAgent:appModel];
            //            }else
            if(appModel.appid == 102){
                //邮件
                EmailViewController *emailVC = [[EmailViewController alloc]init];
                [self hideTabBar];
                
                NSString *cid = @"ff8080814f4e2b57014f62ce26df027c";
                NSString *key = @"R6e4Bn8uM14Kw";
                NSString *domain = @"longfor.com";
                NSString *uid = [UserDefaults getUserAccount];
                NSString *paramString = [NSString stringWithFormat:@"cid=%@&domain=%@&uid=%@&key=%@",cid,domain,uid,key];
                NSString *sign = [StringUtil getMD5Str:paramString];
                
                emailVC.urlstr = [NSString stringWithFormat:@"%@cid=%@&domain=%@&uid=%@&sign=%@",appModel.apphomepage,cid,domain,uid,sign];//&isSkip=1
                [self.navigationController pushViewController:emailVC animated:YES];
                [emailVC release];
            }else if (appModel.appid == 103){
                // 文件助手
                FileAssistantViewController *fileVC = [[FileAssistantViewController alloc]init];
                [self hideTabBar];
                [self.navigationController pushViewController:fileVC animated:YES];
                [fileVC release];
            }else{
                [self openAgent:appModel];
            }
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 隐藏tabbar
 */
-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}

/**
 显示tabbar
 */
-(void)displayTabBar
{
    [UIAdapterUtil showTabar:self];
    self.navigationController.navigationBarHidden = NO;
}

/**
 显示未读消息数
 */
- (void)reloadDataAndDisplayNewMsgNumber
{
    [myTableView reloadData];
    [self displayNewMsgNumber];
}

/**
 显示未读消息数
 */
- (void)displayNewMsgNumber
{
    //    是否需要显示红点
    BOOL needTabbarDspRedDot = NO;

    for (NSArray *modelArr in self.userDataTextArray) {
        for (APPListModel *_model in modelArr) {
            
//            NSLog(@"%s appid is %d unread is %d appname is %@",__FUNCTION__,_model.appid,_model.unread,_model.appname);
            
            if ([_model.apphomepage rangeOfString:SHOW_COUNT_NUM options:NSCaseInsensitiveSearch].length > 0 || _model.appid == LONGHU_MAIL_APP_ID) {
                if ([UserDefaults getAppUnreadWithAppId:_model.appid] > 0) {
                    needTabbarDspRedDot = YES;
                }
            }else{
//                需要显示红点
//                NSMutableDictionary *dict = [UserDefaults getAppId];
//                NSString *string = [NSString stringWithFormat:@"%d",_model.appid];
//                if ([dict[string] isEqualToString:@"YES"]) {
                if ([UserDefaults getRedDotOfAppId:_model.appid]){
                    needTabbarDspRedDot = YES;
                }
            }
        }
    }
    
    //    我的标签显示红点
    if (self.userDataTextArray.count > 0 && needTabbarDspRedDot) {
        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
    else
    {
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
}

#pragma mark - 办公界面通知的处理
/**
 *  同步轻应用伴随的通知处理
 */
- (void)handleCmd:(NSNotification *)notif{
    eCloudNotification	*notifObj = (eCloudNotification *)[notif object];
    if (notifObj.cmdId == refresh_app_list) {
        
        [self getUserInfo];
        [self getAppListInfo];
        [self reloadDataAndDisplayNewMsgNumber];
        
        // 访问263邮箱的webservice服务
        [self unReadForEmailOption];
        [self unReadForAllApp];
        [self unReadForGuest];

        [[self class] unReadForWorkWorld];
        
    }else if(notifObj.cmdId == refresh_app_section){
        // 下载完成logopath进行对应section的刷新
        NSDictionary *dic = notifObj.info;
        if ([dic count] == 1) {
            // 取出通知中userinfo中的APPListModel
            APPListModel * refreshAppModel = [dic allValues][0];
            for (NSInteger i = 0; i < self.userDataTextArray.count; i++) {
                for (APPListModel *tmpModel in self.userDataTextArray[i]) {
                    if (refreshAppModel.appid == [tmpModel appid]) {
                        // 刷新指定section
                        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:i+1];
                        [myTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                }
            }
        }
    }
}
/**
 *  有新待办时未读数的通知处理
 */
- (void)handleRecUnreadCmd:(NSNotification *)notif{
    eCloudNotification	*notifObj = (eCloudNotification *)[notif object];

    if (notifObj.cmdId == rcv_app_agentunread) {
//        增加获取其它轻应用的未读数
        
        // 访问263邮箱的webservice服务
        [self unReadForEmailOption];

        // 访问待办审批的webservice服务
        [self unReadForAllApp];
        [self unReadForGuest];
        [[self class] unReadForWorkWorld];
        [self reloadDataAndDisplayNewMsgNumber];
    }
}
/**
 *  点击待办通知进入到代办详情的通知处理
 */
- (void)handleGotoAgentDetailCmd:(NSNotification *)notif{
    NSDictionary *dic = notif.userInfo;
    if (dic)
    {
        [self findAndOpenAgentList];
    }
}


/**
 查看是否存在点击系统通知的轻应用实体
    若通知中存在链接则直接打开；
    若通知中不存在链接，只存在轻应用id，则跳转到该轻应用的首页
 */
- (void)findAndOpenAgentList
{
    if (!self.appInfo) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 点击通知启动应用时，和通知相关的userinfo为nil",__FUNCTION__]];
        return;
    }
    NSString *appUrl = self.appInfo[KEY_NOTIFICATION_APP_URL];
    if (appUrl.length) {    // 轻应用链接不为空
        [LogUtil debug:[NSString stringWithFormat:@"%s 点击通知启动应用时，包括了具体的url:%@",__FUNCTION__,appUrl]];
        int appId = [self.appInfo[KEY_NOTIFICATION_APP_ID]intValue];
        if (appId > 0) {
            [self removeRedDotOfAppId:appId];
        }
//        直接打开
        [self openAppUrl:appUrl];
    }else{  // 轻应用链接为空，跳转到对应轻应用的首页
        int appId = [self.appInfo[KEY_NOTIFICATION_APP_ID]intValue];
        if (appId > 0) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 点击通知启动应用时，和通知相关的appid为%d",__FUNCTION__,appId]];
            
            BOOL hasAgent = NO;
            
            for (NSArray *modelArr in self.userDataTextArray) {
                for (APPListModel *appModel in modelArr) {
                    if (appModel.appid == appId) {
                        [self openAgent:appModel];
                        hasAgent = YES;
                        break;
                    }
                }
            }
            if (!hasAgent) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 点击通知启动应用时，没有找到对应appid的应用",__FUNCTION__]];
            }
        }
    }
    self.appInfo = nil;
}

/**
 消除某个应用的红点记录

 @param appId 指定轻应用id
 */
- (void)removeRedDotOfAppId:(int)appId
{
    [UserDefaults saveRedDotOfAppId:appId andRedDot:NO];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults getAppId]];
//    NSString *appid = [NSString stringWithFormat:@"%d",appId];
//    [dict setObject:@"NO" forKey:appid];
//    [UserDefaults saveAppId:dict];
}

/**
 打开代办界面

 @param appModel 轻应用实体
 */
- (void)openAgent:(APPListModel *)appModel
{
    [self hideTabBar];
    
    [self removeRedDotOfAppId:appModel.appid];
    
    NSString *agentUrl = nil;
    
    if ([appModel.apphomepage rangeOfString:@"?"].length > 0) {
        agentUrl = [NSString stringWithFormat:@"%@&token=%@&usercode=%@",appModel.apphomepage,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
    }else{
        agentUrl = [NSString stringWithFormat:@"%@?token=%@&usercode=%@",appModel.apphomepage,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,agentUrl]];
    AgentListViewController *agentListVC = [[AgentListViewController alloc]init];
    
    // 测试用的token：8633bfe9-792a-4eb1-b4a3-5a9d0261ab05
    // 外网域名：http://moapproval.longfor.com:8080/moapproval/list.html
    
    agentListVC.urlstr = agentUrl;
    
    [self.navigationController pushViewController:agentListVC animated:YES];
    [agentListVC release];
}

/**
 点击轻应用通知启动程序，如果通知里带来对应的URL，那么需要能直接打开

 @param appUrl 轻应用链接
 */
- (void)openAppUrl:(NSString *)appUrl
{
    // 测试用的token：8633bfe9-792a-4eb1-b4a3-5a9d0261ab05
    // 外网域名：http://moapproval.longfor.com:8080/moapproval/list.html
    
    NSString *agentUrl = nil;
    if ([appUrl rangeOfString:@"?"].length > 0) {
        agentUrl = [NSString stringWithFormat:@"%@&token=%@&usercode=%@",appUrl,[UserDefaults getLoginToken],[UserDefaults getUserAccount]] ;
    }else{
        agentUrl = [NSString stringWithFormat:@"%@?token=%@&usercode=%@",appUrl,[UserDefaults getLoginToken],[UserDefaults getUserAccount]] ;
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,agentUrl]];
    [self hideTabBar];
    
    AgentListViewController *agentListVC = [[AgentListViewController alloc]init];
    
    agentListVC.urlstr = agentUrl;
    agentListVC.interceptAll = NO;
    
    [self.navigationController pushViewController:agentListVC animated:YES];
    [agentListVC release];
}
#pragma mark =============处理登录应答=================
- (void)processLoginAck:(NSNotification *)notification
{
    if (!isWaitingForLoginToken) {
        return;
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    isWaitingForLoginToken = NO;
    [UserTipsUtil hideLoadingView];
    
    eCloudNotification	*cmd	 =	(eCloudNotification *)[notification object];
    switch (cmd.cmdId) {
        case login_success:
        {
            [self findAndOpenAgentList];
        }
            break;
        case login_failure:
        {
            [UserTipsUtil showAlert:@"登录失败" autoDimiss:YES];
        }
            break;
        case login_timeout:
        {
            [UserTipsUtil showAlert:@"登录超时" autoDimiss:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark =============修改会话列表界面的标题=================
// 监听conn.connStatus值的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!isWaitingForLoginToken)
        return;
    [LogUtil debug:[NSString stringWithFormat:@"%s connstatus is %d userstatus is %d",__FUNCTION__,_conn.connStatus,_conn.userStatus]];
    
    if (_conn.connStatus == not_connect_type) {   // 未连接时的一些操作
        isWaitingForLoginToken = NO;
        [UserTipsUtil hideLoadingView];
        [UserTipsUtil showAlert:@"连接失败" autoDimiss:YES];
    }else{
        if (_conn.userStatus == status_online) {   // 在线状态下的一些操作
            isWaitingForLoginToken = NO;
            [UserTipsUtil hideLoadingView];
            [self findAndOpenAgentList];    // 打开点击通知后的轻应用处理
        }
    }
}


/**
 状态栏发生变化时，重新计算tableview的frame
 */
- (void)reCalculateFrame
{
    myTableView.frame = CGRectMake(0, 0, self.view.frame.size.width , SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight] - self.tabBarController.tabBar.frame.size.height);
}


/**
 打开指定url网页

 @param openUrl       网页链接
 @param curController 当前操作的控制器对象
 */
+ (void)openLongHuHtml5:(NSString *)openUrl withController:(UIViewController *)curController
{
    if ([openUrl rangeOfString:LONGHU_HTML5_DOMAIN].length > 0 && [openUrl rangeOfString:KEY_AIGUANHUAI].length == 0 && [openUrl rangeOfString:KEY_INTERVIEW_PLATFORM].length == 0 && [openUrl rangeOfString:KEY_JUXIAN].length == 0) {
        // 链接url包含龙湖轻应用域名且不包含"爱关怀"、"面试官"、"我要推荐"第三方url
        AgentListViewController *agentListVC = [[AgentListViewController alloc]init];
        
        // 测试用的token：8633bfe9-792a-4eb1-b4a3-5a9d0261ab05
        // 外网域名：http://moapproval.longfor.com:8080/moapproval/list.html
        
        conn *_conn = [conn getConn];
        NSString *agentUrl = nil;
        // 链接url增加token参数
        if ([openUrl rangeOfString:@"?"].length > 0) {
            agentUrl = [NSString stringWithFormat:@"%@&token=%@",openUrl,[UserDefaults getLoginToken]];
        }else{
            agentUrl = [NSString stringWithFormat:@"%@?token=%@",openUrl,[UserDefaults getLoginToken]] ;
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,agentUrl]];
        
        agentListVC.urlstr = agentUrl;
        
        [curController.navigationController pushViewController:agentListVC animated:YES];
        [agentListVC release];
    }else{
        openWebViewController *openweb=[[openWebViewController alloc]init];
        openweb.urlstr=openUrl;
        [curController.navigationController pushViewController:openweb animated:YES];
        [openweb release];
    }
}

/**
 刷新用户头像
 */
- (void)Picture
{
    [self getUserInfo];
    
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = myTableView.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    myTableView.frame = _frame;
    
    [myTableView reloadData];
}

+ (CGFloat)widthOfString:(NSString *)string font:(UIFont *)font height:(CGFloat)height
{
    NSDictionary * dict=[NSDictionary dictionaryWithObject: font forKey:NSFontAttributeName];
    CGRect rect=[string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width;
}
@end
