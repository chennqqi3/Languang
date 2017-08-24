//
//  NewMyViewControllerOfCustomGrid.m
//  eCloud
//
//  Created by yanlei on 15/8/26.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "NewMyViewControllerOfCustomGrid.h"
#import "KapokHistoryViewController.h"
#import "eCloudDefine.h"

#import "TabbarUtil.h"
#import "eCloudUser.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "ImageUtil.h"
#import "ImageSet.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonEmpViewController.h"
#import "MonthHelperViewController.h"
#import "PSMsgDtlViewController.h"
#import "PublicServiceDAO.h"
#import "PSListViewController.h"
#import "NewMsgNotice.h"
#import "NewMsgNumberUtil.h"
#import "MassDAO.h"
#import "broadcastViewController.h"
#import "KapokHistoryViewController.h"
#import "AgentListViewController.h"
#import "EmailViewController.h"

#import "APPListViewController.h"
#import "APPListDetailViewController.h"
#import "APPIntroViewController.h"
#import "AppListBtnModel.h"
#import "APPListModel.h"
#import "AppListImageView.h"
#import "APPPlatformDOA.h"
#import "NewAPPTagUtil.h"
#import "JsObjectCViewController.h"
#import "userInfoViewController.h"
#import "talkSessionViewController.h"
#import "FileAssistantViewController.h" //0810

@interface NewMyViewControllerOfCustomGrid ()
@property(nonatomic,retain)conn *_conn;
@property(nonatomic,retain)eCloudDAO *db;
@property(nonatomic,retain)Emp *emp;
@property(nonatomic,retain)MassDAO *massDAO;
@property(nonatomic,retain)UIImageView *iconImageview;
@property(nonatomic,retain)UILabel *namelabel;
@property(nonatomic,retain)UIButton *signaturelabel;
@property(nonatomic,retain)UIScrollView *memberScroll;
@property(nonatomic,retain)UIButton *redButton;
@property(nonatomic,retain)UIButton *redHotNewsButton;
@property(nonatomic,retain)UIButton *redServeNewsButton;
@property(nonatomic,retain)UIButton *massButton;
@property(nonatomic,retain)UIButton *kapodButton;
@property(nonatomic,retain)UIButton *appPlatformButton;
@property(assign)bool isCanMass;
@property(assign)bool isCanKapod;

@end

@implementation NewMyViewControllerOfCustomGrid
{
    PublicServiceDAO *_psDAO;
    NSMutableArray *appListArr;//应用数组
    BOOL start_Delete;//是否显示删除按钮
    AppListImageView *currentAppListView;//当前选中删除的应用
    CGFloat screenW;
}

@synthesize servce_id;

-(void)displayTabBar
{
    [UIAdapterUtil showTabar:self];
    self.navigationController.navigationBarHidden = NO;
}
-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark 处理会话通知
-(void)handleCmd:(NSNotification*)notification
{
    eCloudNotification	*cmd =	(eCloudNotification *)[notification object];
    switch (cmd.cmdId)
    {
        case rev_msg:
        {
            NSDictionary *_userInfo = notification.userInfo;
            NewMsgNotice *_notice = [_userInfo valueForKey:@"msg_notice"];
            //            NewMsgNotice *_notice = notification.userInfo;
            if(_notice.msgType == ps_new_msg_type)
            {
                int serviceId = _notice.serviceId;
                int rdnum=0;
                if(serviceId == self.servce_id)
                {
                    rdnum=[_psDAO getUnreadMsgCountOfPS:serviceId];
                    [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redHotNewsButton andNewMsgNumber:rdnum];
                    
                    int count=[self.db getUnreadHelperNum];
                    int server_count= 0;// [[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
                    int wcount=0;
                    if (self.isCanMass) {
                        wcount=[self.massDAO getAllUnReadNum];
                    }
                    
                    int apppush = 0;
                    apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
                    
                    if (count+rdnum+server_count+wcount+apppush > 0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
                        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
                    }else
                    {
                        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
                    }
                }
            }
            
            if(_notice.msgType == mass_reply_msg_type)
            {
                int wcount=0;
                if (self.isCanMass) {
                    wcount=[self.massDAO getAllUnReadNum];
                }
                int count=[self.db getUnreadHelperNum];
                int server_count= 0;// [[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
                int rdnum=[_psDAO getUnreadMsgCountOfPS:self.servce_id];
                [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.massButton andNewMsgNumber:wcount];
                
                int apppush = 0;
                apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
                
                if (count+rdnum+server_count+wcount+apppush>0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
                    [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
                }else
                {
                    [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
                }
            }
            
            if (_notice.msgType == app_new_msg_type) {
                
                int wcount=0;
                if (self.isCanMass) {
                    wcount=[self.massDAO getAllUnReadNum];
                }
                int count=[self.db getUnreadHelperNum];
                int server_count= 0;
                int rdnum=[_psDAO getUnreadMsgCountOfPS:self.servce_id];
                
                int apppush = 0;
                apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
                
                if (count+rdnum+server_count+wcount+apppush > 0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
                    [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
                }
                else{
                    [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
                }
                
                //刷新列表
                [self showMemberScrollow];
            }
        }
            break;
        case ps_msg_read:
        {
            int rdnum=0;
            rdnum=[_psDAO getUnreadMsgCountOfPS:self.servce_id];
            [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redHotNewsButton andNewMsgNumber:rdnum];
            
            int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
            //					[NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redServeNewsButton andNewMsgNumber:server_count];
            
            int count=[self.db getUnreadHelperNum];
            int wcount=0;
            if (self.isCanMass) {
                wcount=[self.massDAO getAllUnReadNum];
            }
            
            int apppush = 0;
            apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
            
            if (count+rdnum+server_count+wcount+apppush>0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
                [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
            }else
            {
                [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
            }
            
        }
            break;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    //隐藏删除按钮
    [self hideAppsDeleteBtn];
    
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title = [StringUtil getAppLocalizableString:@"main_my"];
    if (self.signaturelabel!=nil) {
        // 是否有 一呼万应 权限
        
        [[eCloudUser getDatabase]getPurviewValue];
        self.isCanKapod=[[eCloudUser getDatabase]isCanKapod];
        self.isCanMass=[[eCloudUser getDatabase]isCanMass];
        [self showMemberScrollow];
        
        NSString* userid=self._conn.userId;
        self.emp= [self.db getEmpInfo:userid];
        
        self.namelabel.text=self.emp.emp_name;
        [self.signaturelabel setTitle:self.emp.empCode forState:UIControlStateNormal];
        
        UIImage *image;
        NSString *empLogo = self.emp.emp_logo;
        if(empLogo && empLogo.length > 0)
        {
            image = [ImageUtil getLogo:self.emp];
            if(image == nil)
            {
                //                image = [ImageUtil getDefaultLogo:self.emp];
                //                dispatch_queue_t queue = dispatch_queue_create("download_userlogo", NULL);
                //                dispatch_async(queue, ^{
                //                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLogoFileDownloadUrl],empLogo]];
                //                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                //                    UIImage *downloadImage = [UIImage imageWithData:imageData];
                //                    if(downloadImage)
                //                    {
                //                        //						保存头像之前，先删除原来的头像
                //                        [StringUtil deleteUserLogoIfExist:[StringUtil getStringValue:self.emp.emp_id]];
                //
                //                        NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id ] andLogo:empLogo];
                //                        BOOL success= [imageData writeToFile:logoPath atomically:YES];
                //                        if(!success)
                //                        {
                //                            NSLog(@"save user logo fail");
                //                        }
                //
                //                        UIImage *offlineimage=[ImageSet setGrayWhiteToImage:downloadImage];
                //                        NSString *offlinepicPath = [StringUtil getOfflineLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
                //                        NSData *dataObj = UIImageJPEGRepresentation(offlineimage, 1.0);
                //                        BOOL offlinesuccess= [dataObj writeToFile:offlinepicPath atomically:YES];
                //                        if(!offlinesuccess)
                //                        {
                //                            NSLog(@"save user offline logo fail");
                //                        }
                //
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //                            if(self._conn.userStatus == status_online)
                //                            {
                //                                if (self.emp.emp_status==status_online||self.emp.emp_status==status_leave)
                //                                {
                //
                //                                    self.iconImageview.image=downloadImage;
                //                                }
                //                                else
                //                                {
                //
                //                                    self.iconImageview.image=offlineimage;
                //                                }
                //                            }
                //                            else
                //                            {
                //                                self.iconImageview.image=offlineimage;
                //
                //                            }
                //                        });
                //                    }
                //                });
                self.iconImageview.image = [ImageUtil getOnlineEmpLogo:self.emp];
            }
            else
            {
                self.iconImageview.image=image;
            }
            
        }
        else
        {
            image = [ImageUtil getDefaultLogo:self.emp];
            self.iconImageview.image=image;
        }
        
    }
    [self displayTabBar];
    
    NSString *dateRecordFolder = [self dateFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:dateRecordFolder error:nil];
    NSLog(@"---dateRecordFolder --  %@",dateRecordFolder);
    //	显示未读会话个数
    
    //if (self.redButton!=nil) {
    int count=[self.db getUnreadHelperNum];
    [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redButton andNewMsgNumber:count];
    
    int serviceId = [_psDAO getServiceIdByName:redian_name];
    int rdnum=0;
    if (serviceId!=-1) {
        rdnum=[_psDAO getUnreadMsgCountOfPS:serviceId];
        [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redHotNewsButton andNewMsgNumber:rdnum];
        
    }
    int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
    int wcount=0;
    if (self.isCanMass) {
        wcount=[self.massDAO getAllUnReadNum];
        [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.massButton andNewMsgNumber:wcount];
    }
    
    int apppush = 0;
    apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
    
    if (count+rdnum+server_count+wcount+apppush>0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
    else
    {
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
    // }

    
}

- (NSString *)dateFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"JBCalendarData"];
}
-(void)userInfo:(id)sender
{
    userInfoViewController *userInfo=[[userInfoViewController alloc]init];
    userInfo.tagType = 0;
    [self hideTabBar];
    [self.navigationController pushViewController:userInfo animated:YES];
    [userInfo release];
}

-(void)dealloc
{
    NSLog(@"%s,remove observer",__FUNCTION__);
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:HELPER_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APP_PUSH_REFRESH_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APP_NEW_NOTIFICATION object:nil];
    
    [appListArr removeAllObjects];
    appListArr = nil;
    
    [super dealloc];
}

-(void)helperCmd:(NSNotification *)notification
{
    int count=[self.db getUnreadHelperNum];
    [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redButton andNewMsgNumber:count];
    
    int rdnum=0;
    
    rdnum=[_psDAO getUnreadMsgCountOfPS:self.servce_id];
    int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
    
    int wcount=0;
    if (self.isCanMass) {
        wcount=[self.massDAO getAllUnReadNum];
    }
    int apppush = 0;
    apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
    
    if (count+rdnum+server_count+wcount+apppush>0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }else
    {
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIAdapterUtil processController:self];
    [self loadMyView];
}

- (void)loadMyView{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(helperCmd:) name:HELPER_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppRefresh) name:APP_PUSH_REFRESH_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewApp) name:APP_NEW_NOTIFICATION object:nil];
    
    screenW = self.view.frame.size.width;
    self.view.backgroundColor=[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    self._conn = [conn getConn];
    self.db = [eCloudDAO getDatabase];
    _psDAO=[PublicServiceDAO getDatabase];
    self.servce_id = [_psDAO getServiceIdByName:redian_name];
    self.massDAO = [MassDAO getDatabase];
    NSString* userid=self._conn.userId;
    self.emp= [self.db getEmpInfo:userid];
    // 是否有 一呼万应 权限
    [[eCloudUser getDatabase]getPurviewValue];
    self.isCanKapod=[[eCloudUser getDatabase]isCanKapod];
    self.isCanMass=[[eCloudUser getDatabase]isCanMass];
    start_Delete = NO;
    
    // changed by toxicanty 0803 适配
    self.memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.memberScroll.backgroundColor=[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    self.memberScroll.showsHorizontalScrollIndicator = NO;
    self.memberScroll.showsVerticalScrollIndicator = NO;
    self.memberScroll.scrollsToTop = NO;
    [self.view addSubview:self.memberScroll];
    [self showMemberScrollow];
    
    // changed by toxicanty 0803
    UIButton *headerButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 66)];
    // [headerButton setImage:[StringUtil getImageByResName:@"my_backgroup.png"] forState:UIControlStateNormal];
    
    // change by toxicanty 0803 适配 改setImage为setBackgroundImage
    [headerButton setBackgroundImage:[StringUtil getImageByResName:@"bj1.png"] forState:UIControlStateNormal];
    [headerButton setBackgroundImage:[StringUtil getImageByResName:@"bj2.png"] forState:UIControlStateSelected];
    [headerButton setBackgroundImage:[StringUtil getImageByResName:@"bj2.png"] forState:UIControlStateHighlighted];
    headerButton.backgroundColor=[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    [headerButton addTarget:self action:@selector(userInfo:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"self.view === %@",self.view);
    [self.view addSubview:headerButton];
    [headerButton release];
    
    self.iconImageview = [[UIImageView alloc]initWithFrame:CGRectMake(10,(66-50)/2, 50,50)];
    [self.view addSubview:self.iconImageview];
    
    
    self.namelabel=[[UILabel alloc]initWithFrame:CGRectMake(70, 5, 200, 20)];
    self.namelabel.backgroundColor=[UIColor clearColor];
    [headerButton addSubview:self.namelabel];
    self.namelabel.text=self.emp.emp_name;
    self.namelabel.font=[UIFont boldSystemFontOfSize:18];
    self.namelabel.textColor=[UIColor blackColor];
    
    // 姓名拼音label
    self.signaturelabel=[[UIButton alloc]initWithFrame:CGRectMake(70,25, 320-217/2.0-10, 20)];
    self.signaturelabel.backgroundColor=[UIColor clearColor];
    self.signaturelabel.enabled=NO;
    // [self.signaturelabel setBackgroundImage:[StringUtil getImageByResName:@"mytitle_backgroup.png"] forState:UIControlStateNormal];
    [self.signaturelabel setTitle:self.emp.signature forState:UIControlStateNormal];
    [self.signaturelabel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [headerButton addSubview:self.signaturelabel];
    self.signaturelabel.titleLabel.font=[UIFont systemFontOfSize:12];
    [self.signaturelabel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    
    UIImage *image;
    NSString *empLogo = self.emp.emp_logo;
    if(empLogo && empLogo.length > 0)
    {
        image = [ImageUtil getLogo:self.emp];
        if(image == nil)
        {
            image = [ImageUtil getDefaultLogo:self.emp];
            dispatch_queue_t queue = dispatch_queue_create("download_userlogo", NULL);
            dispatch_async(queue, ^{
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLogoFileDownloadUrl],empLogo]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                UIImage *downloadImage = [UIImage imageWithData:imageData];
                if(downloadImage)
                {
                    //						保存头像之前，先删除原来的头像
                    [StringUtil deleteUserLogoIfExist:[StringUtil getStringValue:self.emp.emp_id]];
                    
                    NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id ] andLogo:empLogo];
                    BOOL success= [imageData writeToFile:logoPath atomically:YES];
                    if(!success)
                    {
                        NSLog(@"save user logo fail");
                    }
                    
                    UIImage *offlineimage=[ImageSet setGrayWhiteToImage:downloadImage];
                    NSString *offlinepicPath = [StringUtil getOfflineLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
                    NSData *dataObj = UIImageJPEGRepresentation(offlineimage, 1.0);
                    BOOL offlinesuccess= [dataObj writeToFile:offlinepicPath atomically:YES];
                    if(!offlinesuccess)
                    {
                        NSLog(@"save user offline logo fail");
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(self._conn.userStatus == status_online)
                        {
                            if (self.emp.emp_status==status_online||self.emp.emp_status==status_leave)
                            {
                                
                                self.iconImageview.image=downloadImage;
                            }
                            else
                            {
                                
                                self.iconImageview.image=offlineimage;
                            }
                        }
                        else
                        {
                            self.iconImageview.image=offlineimage;
                            
                        }
                    });
                }
            });
        }
        else
        {
            self.iconImageview.image=image;
        }
        
    }
    else
    {
        image = [ImageUtil getDefaultLogo:self.emp];
        self.iconImageview.image=image;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 应用平台刷新消息中心
- (void)handleAppRefresh{
    
    if (self.redButton!=nil) {
        int count=[self.db getUnreadHelperNum];
        [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redButton andNewMsgNumber:count];
        
        int serviceId = [_psDAO getServiceIdByName:redian_name];
        int rdnum=0;
        if (serviceId!=-1) {
            //服务号
            rdnum=[_psDAO getUnreadMsgCountOfPS:serviceId];
            [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.redHotNewsButton andNewMsgNumber:rdnum];
        }
        int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
        int wcount=0;
        if (self.isCanMass) {
            //一呼万应
            wcount=[self.massDAO getAllUnReadNum];
            [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:self.massButton andNewMsgNumber:wcount];
        }
        
        int apppush = 0;
        apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
        
        if (count+rdnum+server_count+wcount+apppush>0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
            [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
        }
        else
        {
            [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
        }
    }
}

#pragma mark - 有新应用
- (void)handleNewApp{
    //新应用提示
    int wcount=0;
    if (self.isCanMass) {
        wcount=[self.massDAO getAllUnReadNum];
    }
    int count=[self.db getUnreadHelperNum];
    int server_count= 0;
    int rdnum=[_psDAO getUnreadMsgCountOfPS:self.servce_id];
    
    int apppush = 0;
    apppush = [[APPPlatformDOA getDatabase] getAllNewPushNotiCount];
    
    if (count+rdnum+server_count+wcount+apppush > 0 || [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
    else{
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
    
    //新应用提示
    int newPushCount = 0;
    newPushCount = [[APPPlatformDOA getDatabase] getAllNewPushNotiCountOutOfMine];
    
    if (newPushCount) {
        [NewAPPTagUtil addAppTagView:self.appPlatformButton];
        [NewAPPTagUtil displayaddAppTagView:self.appPlatformButton withText:@"Push"];
    }
    else{
        int newAppCount = 0;
        newAppCount = [[APPPlatformDOA getDatabase] getAllNewAppsCount];
        
        if (newAppCount > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
            //有新应用
            [NewAPPTagUtil addAppTagView:self.appPlatformButton];
            [NewAPPTagUtil displayaddAppTagView:self.appPlatformButton withText:@"new"];
        }
        else {
            [NewAPPTagUtil addAppTagView:self.appPlatformButton];
            [NewAPPTagUtil displayaddAppTagView:self.appPlatformButton withText:@""];
        }
    }
    
    //    //刷新列表
    //    [self showMemberScrollow];
}


#pragma mark - 加载应用列表
-(void)showMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
    
    [self getAppListInMyView];
    
    int showiconNum=3;
    int sumnum= [appListArr count];
    int pagenum=0;
    if (sumnum%showiconNum!=0) {
        pagenum=sumnum/showiconNum+1;
    }else {
        pagenum=sumnum/showiconNum;
    }
    
    self.memberScroll.pagingEnabled = NO;
    self.memberScroll.contentSize = CGSizeMake(self.memberScroll.frame.size.width ,154.0+103.0*pagenum);
    
    for (int i = 0; i < 3*pagenum; i++) {
        if (i < sumnum) {
            
            AppListImageView *image = [[AppListImageView alloc] initWithFrame:CGRectMake(0.0+screenW/3*(i%3),66+(screenW-20)/3*(i/3), screenW, (screenW-40)/3)];
            image.tag = i;
            image.parent = self;
            image.appBtnModel = [appListArr objectAtIndex:i];
            [image configureListImageView];
            [self.memberScroll addSubview:image];
            
            switch (image.appBtnModel.apptype) {
                case 1: 
                {
                    //应用汇
                    self.appPlatformButton = image.iconbutton;
                    
                    //新应用提示
                    int newPushCount = 0;
                    newPushCount = [[APPPlatformDOA getDatabase] getAllNewPushNotiCountOutOfMine];
                    
                    if (newPushCount) {
                        [NewAPPTagUtil addAppTagView:image.iconbutton];
                        [NewAPPTagUtil displayaddAppTagView:image.iconbutton withText:@"Push"];
                    }
                    else{
                        int newAppCount = 0;
                        newAppCount = [[APPPlatformDOA getDatabase] getAllNewAppsCount];
                        
                        if (newAppCount > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
                            //有新应用
                            [NewAPPTagUtil addAppTagView:image.iconbutton];
                            [NewAPPTagUtil displayaddAppTagView:image.iconbutton withText:@"new"];
                        }
                        else {
                            [NewAPPTagUtil addAppTagView:image.iconbutton];
                            [NewAPPTagUtil displayaddAppTagView:image.iconbutton withText:@""];
                        }
                    }
                }
                    break;
                case 2:
                {
                    //联系人
                    
                }
                    break;
                case 3:
                {
                    //服务号
                    self.redServeNewsButton = image.iconbutton;
                }
                    break;
                case 4:
                {
                    //日程
                    self.redButton = image.iconbutton;
                    [NewMsgNumberUtil addNewMsgNumberView:image.iconbutton];
                    int  count=[self.db getUnreadHelperNum];
                    [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:image.iconbutton andNewMsgNumber:count];
                }
                    break;
                case 5:
                {
                    //南航热点
                    self.redHotNewsButton=image.iconbutton;
                    [NewMsgNumberUtil addNewMsgNumberView:image.iconbutton];
                    int serviceId = [_psDAO getServiceIdByName:redian_name];
                    if (serviceId!=-1) {
                        int count=[_psDAO getUnreadMsgCountOfPS:serviceId];
                        [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:image.iconbutton andNewMsgNumber:count];
                    }
                }
                    break;
                case 6:
                {
                    //木棉童飞
                    
                }
                    break;
                case 7:
                {
                    //一呼万应
                    self.massButton=image.iconbutton;
                    [NewMsgNumberUtil addNewMsgNumberView:image.iconbutton];
                    int count=[self.massDAO getAllUnReadNum];
                    [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:image.iconbutton andNewMsgNumber:count];
                }
                    break;
                case 8: //0810
                {
                    // 文件助手
                    self.massButton=image.iconbutton;
                    [NewMsgNumberUtil addNewMsgNumberView:image.iconbutton];
                    int count=[self.massDAO getAllUnReadNum];
                    [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:image.iconbutton andNewMsgNumber:count];
                }
                    break;
                    
                case 10:
                {
                    //第三方应用
                    NSString *appid = image.appBtnModel.appModel.appid;
//                    int unred = [[APPPlatformDOA getDatabase] getAllNewPushNotiCountWithAppid:appid];
                    int unred = 5;
                    [NewMsgNumberUtil addNewMsgNumberView:image.iconbutton];
                    [NewMsgNumberUtil displayNewMsgNumberForMyViewCtrl:image.iconbutton andNewMsgNumber:unred];
                }
                    break;
            }
            
            [image release];
        }
        else{
            //补齐行数
            AppListImageView *image = [[AppListImageView alloc] initWithFrame:CGRectMake(0.0+screenW/3*(i%3),66+(screenW-20)/3*(i/3), screenW/3, 103.0)];
            image.tag = i;
            [image hideAllBtn];
            [self.memberScroll addSubview:image];
            [image release];
        }
        
    }
    for (id cls in self.memberScroll.subviews){
        
        if (![cls isKindOfClass:[AppListImageView class]]) {
            
            UILongPressGestureRecognizer *lpgr = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressGestureRecognizer:)] autorelease];
            [self.memberScroll addGestureRecognizer:lpgr];
            
            UITapGestureRecognizer *tapGestureTel2 = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneTapGestureRecognizer:)]autorelease];
            [tapGestureTel2 setNumberOfTapsRequired:1];
            [tapGestureTel2 setNumberOfTouchesRequired:1];
            [self.memberScroll addGestureRecognizer:tapGestureTel2];
        }

    }
}

-(void)removeSubviewFromScrollowView
{
    
    for (UIView *eachView in [self.memberScroll subviews])
    {
        [eachView removeFromSuperview];
        //[eachView release];
    }
    
}

#pragma mark - 获取所有应用信息
- (void)getAppListInMyView{
    if (appListArr == nil) {
        appListArr = [[NSMutableArray alloc] init];
    }
    
    if ([appListArr count]) {
        [appListArr removeAllObjects];
    }

    //第三方添加到我的主页的应用
    NSMutableArray *temArr = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
    if ([temArr count]) {
        for (APPListModel *appModel in temArr) {
            AppListBtnModel *thirdpartBtnModel = [[AppListBtnModel alloc] init];
            thirdpartBtnModel.appname = appModel.appname;
            thirdpartBtnModel.start_Delete = start_Delete;
            thirdpartBtnModel.apptype = 10;
            thirdpartBtnModel.appModel = appModel;
            if (appModel.appid == 101) {
                thirdpartBtnModel.appicon = @"agent_icon.png";
            }else if (appModel.appid == 102) {
                thirdpartBtnModel.appicon = @"mail_icon.png";
            }else if (appModel.appid == 103) {
                thirdpartBtnModel.appicon = @"file_icon.png";
            }
            [appListArr addObject:thirdpartBtnModel];
            [thirdpartBtnModel release];
        }
    }
}

#pragma mark - 手势方法实现
- (void)LongPressGestureRecognizer:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        //显示删除按钮
        [self showAppsDeleteBtn];
    }
}

-(void)oneTapGestureRecognizer:(UIGestureRecognizer *)gr
{
    //隐藏删除按钮
    [self hideAppsDeleteBtn];
}

- (void)showAppsDeleteBtn{
    start_Delete = YES;
    for (AppListImageView *subView in self.memberScroll.subviews)
    {
        if (10 == subView.appBtnModel.apptype) {
            subView.appBtnModel.start_Delete = start_Delete;
            subView.deletebutton.hidden = NO;
        }
    }
}

- (void)hideAppsDeleteBtn{
    start_Delete = NO;
    for (AppListImageView *subView in self.memberScroll.subviews)
    {
        if (10 == subView.appBtnModel.apptype) {
            //第三方应用
            subView.appBtnModel.start_Delete = start_Delete;
            subView.deletebutton.hidden = YES;
        }
    }
}

- (void)iconbuttonAction:(AppListImageView *)sender{
    //根据应用类型进行处理 1.代办审批 2.邮件 8.文件助手
    switch (sender.appBtnModel.apptype) {
        case 10:
        {
            if (sender.appBtnModel.start_Delete) {
                //从我的主页移除应用
                [self deleteGroupMemberAction:sender];
            }
            else {
                //进入第三方应用
                NSString *appid = sender.appBtnModel.appModel.appid;
                if (appid == 101) {
                    //代办审批
                    AgentListViewController *agentListVC=[[AgentListViewController alloc]init];
                    [self hideTabBar];
                    agentListVC.urlstr = sender.appBtnModel.appModel.apphomepage;
                    [self.navigationController pushViewController:agentListVC animated:YES];
                    [agentListVC release];
                }else if(appid == 102){
                    //邮件
                    EmailViewController *emailVC=[[EmailViewController alloc]init];
                    [self hideTabBar];
                    
                    NSString *cid=@"ff8080814f4e2b57014f62ce26df027c";
                    NSString *key=@"R6e4Bn8uM14Kw";
                    NSString *domain=@"longfor.com";
                    NSString *uid =self._conn.user_code;
                    NSString *paramString = [NSString stringWithFormat:@"cid=%@&domain=%@&uid=%@&key=%@",cid,domain,uid,key];
                    NSString *sign = [StringUtil getMD5Str:paramString];
                    
                    emailVC.urlstr = [NSString stringWithFormat:@"%@cid=%@&domain=%@&uid=%@&sign=%@",sender.appBtnModel.appModel.apphomepage,cid,domain,uid,sign];//&isSkip=1
                    [self.navigationController pushViewController:emailVC animated:YES];
                    [emailVC release];
                }else if (appid == 103){
                    // 文件助手
                    FileAssistantViewController *fileVC=[[FileAssistantViewController alloc]init];
                    [self hideTabBar];
                    [self.navigationController pushViewController:fileVC animated:YES];
                    [fileVC release];
                }
                
//                //进入应用简介
//                APPIntroViewController *ctr = [[APPIntroViewController alloc] initWithAppID:sender.appBtnModel.appModel.appid];
//                [self hideTabBar];
//                [self.navigationController pushViewController:ctr animated:YES];
//                [ctr release];
            }
        }
            break;
        default:
            break;
    }
}

- (void)deleteGroupMemberAction:(AppListImageView *)sender{
    NSLog(@"iconbuttonAction----sender----%i",sender.tag);
    currentAppListView = sender;
    
    //删除
    NSString *appid = currentAppListView.appBtnModel.appModel.appid;
    [[APPPlatformDOA getDatabase] updateHasAddedOfAPPModel:appid withAppShowflag:0];
    
    [self showMemberScrollow];
}

@end
