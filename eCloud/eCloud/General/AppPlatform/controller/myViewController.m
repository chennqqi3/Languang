//
//  myViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "myViewController.h"
#import "eCloudNotification.h"

#import "eCloudUser.h"
#import "TabbarUtil.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "ImageUtil.h"
#import "ImageSet.h"
#import <QuartzCore/QuartzCore.h>
//#import "contactListViewController.h"
#import "MonthHelperViewController.h"
#import "PSMsgDtlViewController.h"
#import "PublicServiceDAO.h"
#import "PSListViewController.h"
#import "NewMsgNotice.h"
#import "NewMsgNumberUtil.h"
#import "MassDAO.h"
#import "broadcastViewController.h"
#import "KapokHistoryViewController.h"

#import "APPListViewController.h"
#import "APPListDetailViewController.h"
#import "APPIntroViewController.h"
#import "AppListBtnModel.h"
#import "APPListModel.h"
#import "AppListImageView.h"
#import "APPPlatformDOA.h"
#import "NewAPPTagUtil.h"
#import "JsObjectCViewController.h"
#import "DownloadZipAndUnzip.h"
#import "CommonDeptViewController.h"

#import "userInfoViewController.h"
#import "KapokHistoryViewController.h"

@interface myViewController ()
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

@implementation myViewController
{
    PublicServiceDAO *_psDAO;
    NSMutableArray *appListArr;//应用数组
    BOOL start_Delete;//是否显示删除按钮
    AppListImageView *currentAppListView;//当前选中删除的应用
}

@synthesize servce_id;

-(void)displayTabBar
{
    /*
	//	add by shisp 2013.6.16
	//	在隐藏的情况下，显示出来，并且
	if(self.tabBarController && self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上减去tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		//NSLog(@"tabbar height is %.0f",_tabBar.frame.size.height);
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height - _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		self.tabBarController.tabBar.hidden = NO;
		
	}
     */
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}
-(void)hideTabBar
{
	
    /*
	//	add by shisp 2013.6.16
	//	如果tabbar是显示的状态那么
	if(self.tabBarController && 	!self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上加上tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height + _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		//NSLog(@"height is %.0f",contentView.frame.size.height);
		
		//		隐藏UITabBar
		self.tabBarController.tabBar.hidden = YES;
		
	}
     */
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
			NewMsgNotice *_notice = notification.userInfo;
			if(_notice.msgType == ps_new_msg_type)
			{
				int serviceId = _notice.serviceId;
                int rdnum=0;
				if(serviceId == self.servce_id)
				{
					rdnum=[_psDAO getUnreadMsgCountOfPS:serviceId];
                    [NewMsgNumberUtil displayNewMsgNumber:self.redHotNewsButton andNewMsgNumber:rdnum];
                    
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
                /*
                else
                {
                    rdnum=[_psDAO getUnreadMsgCountOfPS:self.servce_id];
                    int count=[self.db getUnreadHelperNum];
                    int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
                    //                    [NewMsgNumberUtil displayNewMsgNumber:self.redServeNewsButton andNewMsgNumber:server_count];
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
                 */
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
                [NewMsgNumberUtil displayNewMsgNumber:self.massButton andNewMsgNumber:wcount];
                
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
            [NewMsgNumberUtil displayNewMsgNumber:self.redHotNewsButton andNewMsgNumber:rdnum];
			
			int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
            //					[NewMsgNumberUtil displayNewMsgNumber:self.redServeNewsButton andNewMsgNumber:server_count];
            
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
    self.title = [StringUtil getLocalizableString:@"main_my"];
    if (self.signaturelabel!=nil) {
        // 是否有 一呼万应 权限

        [[eCloudUser getDatabase]getPurviewValue];
        self.isCanKapod=[[eCloudUser getDatabase]isCanKapod];
        self.isCanMass=[[eCloudUser getDatabase]isCanMass];
        [self showMemberScrollow];
        
        NSString* userid=self._conn.userId;
        self.emp= [self.db getEmpInfo:userid];
        
        self.namelabel.text=self.emp.emp_name;
        [self.signaturelabel setTitle:self.emp.signature forState:UIControlStateNormal];
        
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
    [self displayTabBar];
    
    NSString *dateRecordFolder = [self dateFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:dateRecordFolder error:nil];
    NSLog(@"---dateRecordFolder --  %@",dateRecordFolder);
    //	显示未读会话个数
    
    if (self.redButton!=nil) {
        int count=[self.db getUnreadHelperNum];
        [NewMsgNumberUtil displayNewMsgNumber:self.redButton andNewMsgNumber:count];
        
        int serviceId = [_psDAO getServiceIdByName:redian_name];
        int rdnum=0;
        if (serviceId!=-1) {
            rdnum=[_psDAO getUnreadMsgCountOfPS:serviceId];
            [NewMsgNumberUtil displayNewMsgNumber:self.redHotNewsButton andNewMsgNumber:rdnum];
            
        }
        int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
        int wcount=0;
        if (self.isCanMass) {
            wcount=[self.massDAO getAllUnReadNum];
            [NewMsgNumberUtil displayNewMsgNumber:self.massButton andNewMsgNumber:wcount];
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
    [NewMsgNumberUtil displayNewMsgNumber:self.redButton andNewMsgNumber:count];
    
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
    
    /*
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(helperCmd:) name:HELPER_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppRefresh) name:APP_PUSH_REFRESH_NOTIFICATION object:nil];
    
    
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
    
    self.memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    self.memberScroll.backgroundColor=[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    self.memberScroll.showsHorizontalScrollIndicator = NO;
    self.memberScroll.showsVerticalScrollIndicator = NO;
    self.memberScroll.scrollsToTop = NO;
    [self.view addSubview:self.memberScroll];
    [self showMemberScrollow];
    
    UIButton *headerButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 66)];
    // [headerButton setImage:[StringUtil getImageByResName:@"my_backgroup.png"] forState:UIControlStateNormal];
    [headerButton setImage:[StringUtil getImageByResName:@"bj1.png"] forState:UIControlStateNormal];
    [headerButton setImage:[StringUtil getImageByResName:@"bj2.png"] forState:UIControlStateSelected];
    [headerButton setImage:[StringUtil getImageByResName:@"bj2.png"] forState:UIControlStateHighlighted];
    headerButton.backgroundColor=[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    [headerButton addTarget:self action:@selector(userInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headerButton];
    [headerButton release];
    
    self.iconImageview=[[UIImageView alloc]initWithFrame:CGRectMake(10,(66-50)/2, 50,50)];
    [self.view addSubview:self.iconImageview];
    self.iconImageview.backgroundColor=[UIColor whiteColor];
    self.iconImageview.layer.cornerRadius = 3;//设置那个圆角的有多圆
    self.iconImageview.layer.masksToBounds = YES;//设为NO去试试
    self.iconImageview.layer.borderColor=[UIColor colorWithRed:129/255.0 green:186/255.0 blue:253/255.0 alpha:1].CGColor;
    self.iconImageview.layer.borderWidth=1;
    
    
    self.namelabel=[[UILabel alloc]initWithFrame:CGRectMake(70, 5, 200, 20)];
    self.namelabel.backgroundColor=[UIColor clearColor];
    [headerButton addSubview:self.namelabel];
    self.namelabel.text=self.emp.emp_name;
    self.namelabel.font=[UIFont boldSystemFontOfSize:18];
    self.namelabel.textColor=[UIColor blackColor];
    
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
     */
}

- (void)loadMyView{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(helperCmd:) name:HELPER_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppRefresh) name:APP_PUSH_REFRESH_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewApp) name:APP_NEW_NOTIFICATION object:nil];
    
    
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
    
    self.memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    self.memberScroll.backgroundColor=[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    self.memberScroll.showsHorizontalScrollIndicator = NO;
    self.memberScroll.showsVerticalScrollIndicator = NO;
    self.memberScroll.scrollsToTop = NO;
    [self.view addSubview:self.memberScroll];
    [self showMemberScrollow];
    
    UIButton *headerButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 66)];
    // [headerButton setImage:[StringUtil getImageByResName:@"my_backgroup.png"] forState:UIControlStateNormal];
    [headerButton setImage:[StringUtil getImageByResName:@"bj1.png"] forState:UIControlStateNormal];
    [headerButton setImage:[StringUtil getImageByResName:@"bj2.png"] forState:UIControlStateSelected];
    [headerButton setImage:[StringUtil getImageByResName:@"bj2.png"] forState:UIControlStateHighlighted];
    headerButton.backgroundColor=[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    [headerButton addTarget:self action:@selector(userInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headerButton];
    [headerButton release];
    
    self.iconImageview=[[UIImageView alloc]initWithFrame:CGRectMake(10,(66-50)/2, 50,50)];
    [self.view addSubview:self.iconImageview];
    self.iconImageview.backgroundColor=[UIColor whiteColor];
    self.iconImageview.layer.cornerRadius = 3;//设置那个圆角的有多圆
    self.iconImageview.layer.masksToBounds = YES;//设为NO去试试
    self.iconImageview.layer.borderColor=[UIColor colorWithRed:129/255.0 green:186/255.0 blue:253/255.0 alpha:1].CGColor;
    self.iconImageview.layer.borderWidth=1;
    
    
    self.namelabel=[[UILabel alloc]initWithFrame:CGRectMake(70, 5, 200, 20)];
    self.namelabel.backgroundColor=[UIColor clearColor];
    [headerButton addSubview:self.namelabel];
    self.namelabel.text=self.emp.emp_name;
    self.namelabel.font=[UIFont boldSystemFontOfSize:18];
    self.namelabel.textColor=[UIColor blackColor];
    
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
        [NewMsgNumberUtil displayNewMsgNumber:self.redButton andNewMsgNumber:count];
        
        int serviceId = [_psDAO getServiceIdByName:redian_name];
        int rdnum=0;
        if (serviceId!=-1) {
            //服务号
            rdnum=[_psDAO getUnreadMsgCountOfPS:serviceId];
            [NewMsgNumberUtil displayNewMsgNumber:self.redHotNewsButton andNewMsgNumber:rdnum];
        }
        int server_count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
        int wcount=0;
        if (self.isCanMass) {
            //一呼万应
            wcount=[self.massDAO getAllUnReadNum];
            [NewMsgNumberUtil displayNewMsgNumber:self.massButton andNewMsgNumber:wcount];
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
    
//    //刷新列表
//    [self showMemberScrollow];
}


#pragma mark - 加载应用列表
-(void)showMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加

    /*
    int showiconNum=3;
	int sumnum=9;
	int pagenum=0;
	if (sumnum%showiconNum!=0) {
		pagenum=sumnum/showiconNum+1;
	}else {
		pagenum=sumnum/showiconNum;
	}
    
	self.memberScroll.pagingEnabled = NO;
    self.memberScroll.contentSize = CGSizeMake(self.memberScroll.frame.size.width , self.memberScroll.frame.size.height* pagenum);
    
    //  musicFirstSrollview.delegate = self;
    
    
	UIButton *pageview;
	
	int nowindex=0;
	
	
    UIImageView *itemview;
	UIButton *iconbutton;
    UIButton *deletebutton;
    
    UILabel* nameLabel;
    
	int x;
	int y;
	int cx;
	int cy;
    
	pageview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.memberScroll.frame.size.width, self.memberScroll.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
    
	x=0;
	y=0;
	cx=0;
	cy=0;
	
    int row=0;
	for (int j=0; j<sumnum; j++) {
		
		
		nowindex=j;
        
		if (j/3==row) {
            
            
            cx=cx+107;
            if (j==0) {
                cx=0;
                cy=66;
            }
            itemview=[[UIImageView alloc]initWithFrame:CGRectMake(x+cx,y+cy,107.5,103)];
            //itemview.layer.cornerRadius = 3;//设置那个圆角的有多圆
            //            itemview.layer.borderWidth = 0.5;//设置边框的宽度，当然可以不要
            //            itemview.layer.borderColor = [[UIColor lightGrayColor] CGColor];//设置边框的颜色
			
		}else if (j/3!=row) {
        	
            cx=0;
            cy=cy+100;
            itemview=[[UIImageView alloc]initWithFrame:CGRectMake(x+cx,y+cy,107.5,103)];
            // itemview.layer.cornerRadius = 3;//设置那个圆角的有多圆
            //            itemview.layer.borderWidth = 0.5;//设置边框的宽度，当然可以不要
            //            itemview.layer.borderColor = [[UIColor lightGrayColor] CGColor];//设置边框的颜色
		}
        itemview.userInteractionEnabled=YES;
        itemview.image=[StringUtil getImageByResName:@"myitem2.png"];
        //  itemview.backgroundColor=[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake((107-50)/2.0,(100-50)/2.0,50,50)];
        
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 20)];
        
        
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont systemFontOfSize:12];
        nameLabel.textAlignment=UITextAlignmentCenter;
        [itemview addSubview:iconbutton];
        [iconbutton addSubview:nameLabel];
        [nameLabel release];
        
		row=j/3;
		iconbutton.tag=nowindex;
		iconbutton.backgroundColor=[UIColor clearColor];
		[iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
		[pageview addSubview:itemview];
		[iconbutton release];
        
        if (j==0) {
            nameLabel.text=@"联系人";
            [iconbutton setImage:[StringUtil getImageByResName:@"lianxiren.png"] forState:UIControlStateNormal];
        }else if(j==1) {
            nameLabel.text=@"服务号";
            [iconbutton setImage:[StringUtil getImageByResName:@"ps_logo.png"] forState:UIControlStateNormal];
            self.redServeNewsButton=iconbutton;
            int count= 0;//[[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
            //            [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
            //            [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
        }else if(j==2) {
            nameLabel.text=@"日程";
            [iconbutton setImage:[StringUtil getImageByResName:@"schedule_icon_menu.png"] forState:UIControlStateNormal];
            self.redButton=iconbutton;
            [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
            int  count=[self.db getUnreadHelperNum];
            [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
            
        }else if (j==3)
        {
            nameLabel.text=redian_name;
            [iconbutton setImage:[StringUtil getImageByResName:@"nanhangredian.png"] forState:UIControlStateNormal];
            self.redHotNewsButton=iconbutton;
            [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
            int serviceId = [_psDAO getServiceIdByName:redian_name];
            if (serviceId!=-1) {
                int count=[_psDAO getUnreadMsgCountOfPS:serviceId];
                [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
            }
        }
        else if (j==4)
        {
            if (self.isCanKapod) {

            nameLabel.text=@"木棉童飞";
            [iconbutton setImage:[StringUtil getImageByResName:@"kapok_fly_icon.png"] forState:UIControlStateNormal];
             self.kapodButton=iconbutton;
             if (self.isCanKapod) {
                self.kapodButton.hidden=NO;
             }else
             {
                self.kapodButton.hidden=YES;
             }
                
             }
            else if(self.isCanMass)
            {
                nameLabel.text=@"一呼万应";
                [iconbutton setImage:[StringUtil getImageByResName:@"yihuwanying.png"] forState:UIControlStateNormal];
                self.massButton=iconbutton;
                [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
                int count=[self.massDAO getAllUnReadNum];
                [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
                if (self.isCanMass) {
                    self.massButton.hidden=NO;
                }else
                {
                    self.massButton.hidden=YES;
                }
            }
            else{
                nameLabel.text = NSLocalizedString(@"application_plaform", @"应用汇");
                [iconbutton setImage:[StringUtil getImageByResName:@"yihuwanying.png"] forState:UIControlStateNormal];
                self.appPlatformButton=iconbutton;
                [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
//                int count=[self.massDAO getAllUnReadNum];
//                [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
                if (self.isCanAppPlatform) {
                    self.appPlatformButton.hidden=NO;
                }else
                {
                    self.appPlatformButton.hidden=YES;
                }
                
            }
            
        }
        else if (j==5){
            if (self.isCanKapod) {
                //一乎万应
                nameLabel.text=@"一呼万应";
                [iconbutton setImage:[StringUtil getImageByResName:@"yihuwanying.png"] forState:UIControlStateNormal];
                self.massButton=iconbutton;
                [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
                int count=[self.massDAO getAllUnReadNum];
                [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
                if (self.isCanMass) {
                    self.massButton.hidden=NO;
                }else
                {
                    self.massButton.hidden=YES;
                }
            }
            else if(self.isCanMass){
                nameLabel.text = NSLocalizedString(@"application_plaform", @"应用汇");
                [iconbutton setImage:[StringUtil getImageByResName:@"yihuwanying.png"] forState:UIControlStateNormal];
                self.appPlatformButton=iconbutton;
                [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
                //                int count=[self.massDAO getAllUnReadNum];
                //                [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
                if (self.isCanAppPlatform) {
                    self.appPlatformButton.hidden=NO;
                }else
                {
                    self.appPlatformButton.hidden=YES;
                }
            }
        }
        else if(self.isCanMass && j==6){
            nameLabel.text = NSLocalizedString(@"application_plaform", @"应用汇");
            [iconbutton setImage:[StringUtil getImageByResName:@"yihuwanying.png"] forState:UIControlStateNormal];
            self.appPlatformButton=iconbutton;
            [NewMsgNumberUtil addNewMsgNumberView:iconbutton];
            //                int count=[self.massDAO getAllUnReadNum];
            //                [NewMsgNumberUtil displayNewMsgNumber:iconbutton andNewMsgNumber:count];
            if (self.isCanAppPlatform) {
                self.appPlatformButton.hidden=NO;
            }else
            {
                self.appPlatformButton.hidden=YES;
            }
        }
	}
	pageview.frame=CGRectMake(0, 0,self.memberScroll.frame.size.width,y+cy+160);
    [self.memberScroll addSubview:pageview];
	self.memberScroll.contentSize = CGSizeMake(self.memberScroll.frame.size.width, self.view.frame.size.height+1);
	//self.memberScroll.frame=CGRectMake(0, 217/2.0, 320, y+cy+115);
	[pageview release];
    */
    
    
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
            AppListImageView *image = [[AppListImageView alloc] initWithFrame:CGRectMake(0.0+107.0*(i%3),66+101.0*(i/3), 107.5, 103.0)];
            image.tag = i;
            image.parent = self;
            image.appBtnModel = [appListArr objectAtIndex:i];
            [image configureListImageView];
            [self.memberScroll addSubview:image];
            [image release];
            
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
                    [NewMsgNumberUtil displayNewMsgNumber:image.iconbutton andNewMsgNumber:count];
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
                        [NewMsgNumberUtil displayNewMsgNumber:image.iconbutton andNewMsgNumber:count];
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
                    [NewMsgNumberUtil displayNewMsgNumber:image.iconbutton andNewMsgNumber:count];
                }
                    break;
                    
                case 10:
                {
                    //第三方应用
                    NSString *appid = image.appBtnModel.appModel.appid;
                    int unred = [[APPPlatformDOA getDatabase] getAllNewPushNotiCountWithAppid:appid];
                    [NewMsgNumberUtil addNewMsgNumberView:image.iconbutton];
                    [NewMsgNumberUtil displayNewMsgNumber:image.iconbutton andNewMsgNumber:unred];
                }
                    break;
            }
        }
        else{
            //补齐行数
            AppListImageView *image = [[AppListImageView alloc] initWithFrame:CGRectMake(0.0+107.0*(i%3),66+101.0*(i/3), 107.5, 103.0)];
            image.tag = i;
            [image hideAllBtn];
            [self.memberScroll addSubview:image];
            [image release];
        }
        
    }
    
    UILongPressGestureRecognizer *lpgr = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressGestureRecognizer:)] autorelease];
    [self.memberScroll addGestureRecognizer:lpgr];
    
    UITapGestureRecognizer *tapGestureTel2 = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TwoPressGestureRecognizer:)]autorelease];
    [tapGestureTel2 setNumberOfTapsRequired:2];
    [tapGestureTel2 setNumberOfTouchesRequired:1];
    [self.memberScroll addGestureRecognizer:tapGestureTel2];
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
    
    //应用汇
    AppListBtnModel *appBtnModel = [[AppListBtnModel alloc] init];
    appBtnModel.appname = @"应用汇";
    appBtnModel.apptype = 1;
    appBtnModel.appicon = @"add_app_ios.png";
    [appListArr addObject:appBtnModel];
    [appBtnModel release];
    
    //联系人
    AppListBtnModel *contactBtnModel = [[AppListBtnModel alloc] init];
    contactBtnModel.appname = @"联系人";
    contactBtnModel.apptype = 2;
    contactBtnModel.appicon = @"lianxiren.png";
    [appListArr addObject:contactBtnModel];
    [contactBtnModel release];
    
    //服务号
    AppListBtnModel *psBtnModel = [[AppListBtnModel alloc] init];
    psBtnModel.appname = @"服务号";
    psBtnModel.apptype = 3;
    psBtnModel.appicon = @"ps_logo.png";
    [appListArr addObject:psBtnModel];
    [psBtnModel release];
    
    //日程
    AppListBtnModel *scheduleBtnModel = [[AppListBtnModel alloc] init];
    scheduleBtnModel.appname = @"日程";
    scheduleBtnModel.apptype = 4;
    scheduleBtnModel.appicon = @"schedule_icon_menu.png";
    [appListArr addObject:scheduleBtnModel];
    [scheduleBtnModel release];
    
    //南航热点
    AppListBtnModel *hotBtnModel = [[AppListBtnModel alloc] init];
    hotBtnModel.appname = redian_name;
    hotBtnModel.apptype = 5;
    hotBtnModel.appicon = @"nanhangredian.png";
    [appListArr addObject:hotBtnModel];
    [hotBtnModel release];
    
    if (self.isCanKapod) {
        //木棉童飞
        AppListBtnModel *kapokBtnModel = [[AppListBtnModel alloc] init];
        kapokBtnModel.appname = @"木棉童飞";
        kapokBtnModel.apptype = 6;
        kapokBtnModel.appicon = @"kapok_fly_icon.png";
        [appListArr addObject:kapokBtnModel];
        [kapokBtnModel release];
    }
    
    if (self.isCanMass) {
        //一呼万应
        AppListBtnModel *kapokBtnModel = [[AppListBtnModel alloc] init];
        kapokBtnModel.appname = @"一呼万应";
        kapokBtnModel.apptype = 7;
        kapokBtnModel.appicon = @"yihuwanying.png";
        [appListArr addObject:kapokBtnModel];
        [kapokBtnModel release];
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

-(void)TwoPressGestureRecognizer:(UIGestureRecognizer *)gr
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
    //根据应用类型进行处理 1.应用汇 2.联系人 3.服务号 4.日程 5.南航热点  6.木棉童飞 7.一呼万应  10.第三方应用
    switch (sender.appBtnModel.apptype) {
        case 1:
        {
            //应用汇
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_NEW_DEFAULT];
            
            APPListViewController *ctr=[[APPListViewController alloc]init];
            [self hideTabBar];
            [self.navigationController pushViewController:ctr animated:YES];
            [ctr release];
            
        }
            break;
        case 2:
        {
//            //联系人
//            contactListViewController *contactlist=[[contactListViewController alloc]init];
//            contactlist.title=@"常用联系人";
//            //contactlist.hidesBottomBarWhenPushed = YES;
//            [self hideTabBar];
//            [self.navigationController pushViewController:contactlist animated:YES];
//            [contactlist release];
            
            //常用部门
            CommonDeptViewController *contactlist=[[CommonDeptViewController alloc]init];
            contactlist.title=@"常用部门";
            //contactlist.hidesBottomBarWhenPushed = YES;
            [self hideTabBar];
            [self.navigationController pushViewController:contactlist animated:YES];
            [contactlist release];
        }
            break;
        case 3:
        {
            //服务号
            PSListViewController *controller = [[PSListViewController alloc]initWithStyle:UITableViewStylePlain];
            //		controller.hidesBottomBarWhenPushed = YES;
            [self hideTabBar];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
            break;
        case 4:
        {
            //日程
            NSLog(@"----helper date");
            MonthHelperViewController *mainVC = [[MonthHelperViewController alloc] initWithNibName:nil bundle:nil];
            mainVC.title=@"日程助手";
            //        self.mainVC.hidesBottomBarWhenPushed = YES;
            [self hideTabBar];
            [self.navigationController pushViewController: mainVC animated:YES];
            [mainVC release];
        }
            break;
        case 5:
        {
            //南航热点
            int serviceId = [_psDAO getServiceIdByName:redian_name];
            if (serviceId==-1) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"暂无内容" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            PSMsgDtlViewController *controller = [PSMsgDtlViewController getPSMsgDtlViewController];
            controller.needRefresh = YES;
            controller.serviceModel = [_psDAO getServiceByServiceId:serviceId];
            
            //			controller.hidesBottomBarWhenPushed = YES;
            [self hideTabBar];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 6:
        {
//            //木棉童飞
//            if (kapokHistory==nil) {
//                kapokHistory = [[KapokHistoryViewController alloc] initWithNibName:nil bundle:nil];
//                kapokHistory.title=@"木棉童飞";
//                
//            }
//            [self hideTabBar];
//            [self.navigationController pushViewController: kapokHistory animated:YES];
            
            DownloadZipAndUnzip *download_zip=[DownloadZipAndUnzip getInitDownloadZipAndUnzip];
           // [download_zip unZipClick];
             [download_zip doAES_Action];
        }
            break;
        case 7:
        {
            //一呼万应
            broadcastViewController *broadcast=[[broadcastViewController alloc]init];
            [self hideTabBar];
            [self.navigationController pushViewController:broadcast animated:YES];
            [broadcast release];
        }
            break;
        case 10:
        {
            if (sender.appBtnModel.start_Delete) {
                //从我的主页移除应用
                [self deleteGroupMemberAction:sender];
            }
            else {
                //进入第三方应用
                NSString *appid = sender.appBtnModel.appModel.appid;
                int apptype = sender.appBtnModel.appModel.apptype;
                NSString *serverurl = sender.appBtnModel.appModel.serverurl;
                NSString *appname = sender.appBtnModel.appModel.appname;
                //将对应应用推送消息设置为已读
                [[APPPlatformDOA getDatabase] updateReadFlagOfAPPNoti:appid];
                
                if (1 == sender.appBtnModel.appModel.downloadFlag) {
                    //应用已经下载，直接进入到应用页面
                    if (apptype == 1) {
                        //HTML5 应用
                        NSString *url_str=[NSString stringWithFormat:@"%@",serverurl];
                        NSLog(@"url_str------%@",url_str);
                        
                        APPListDetailViewController *ctr = [[APPListDetailViewController alloc] initWithAppID:appid];
                        ctr.customTitle = appname;
                        ctr.urlstr=url_str;
                        [self hideTabBar];
                        [self.navigationController pushViewController:ctr animated:YES];
                        [ctr release];
                    }
                    else{
                        //原生应用,打开下载地址
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:serverurl]];
                    }
                }
                else{
                    //进入应用简介
                    APPIntroViewController *ctr = [[APPIntroViewController alloc] initWithAppID:sender.appBtnModel.appModel.appid];
                    [self hideTabBar];
                    [self.navigationController pushViewController:ctr animated:YES];
                    [ctr release];
                }
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
    
    NSString *alertStr = [NSString stringWithFormat:@"%@将被移除",sender.appBtnModel.appname];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:alertStr message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
    alert.tag  = 1;
    [alert show];
    [alert release];
    
    /*
    //删除
    NSString *appid = sender.appBtnModel.appModel.appid;
    [[APPPlatformDOA getDatabase] updateHasAddedOfAPPModel:appid withAppShowflag:0];
    
    [self showMemberScrollow];
     */
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == alertView.tag) {
        if (1 == buttonIndex) {
            //删除
            NSString *appid = currentAppListView.appBtnModel.appModel.appid;
            [[APPPlatformDOA getDatabase] updateHasAddedOfAPPModel:appid withAppShowflag:0];
            
            [self showMemberScrollow];
        }
    }
}

/*
-(void)iconbuttonAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    NSLog(@"click here %d",button.tag);
    int tagindex=button.tag;
    if (tagindex==0) {//联系人
        contactListViewController *contactlist=[[contactListViewController alloc]init];
        contactlist.title=@"常用联系人";
        //contactlist.hidesBottomBarWhenPushed = YES;
        [self hideTabBar];
        [self.navigationController pushViewController:contactlist animated:YES];
        [contactlist release];
    }else if(tagindex==1) {//服务号
        PSListViewController *controller = [[PSListViewController alloc]initWithStyle:UITableViewStylePlain];
        //		controller.hidesBottomBarWhenPushed = YES;
        [self hideTabBar];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
    }
    else if(tagindex==2) {//日程
        NSLog(@"----helper date");
        MonthHelperViewController *mainVC = [[MonthHelperViewController alloc] initWithNibName:nil bundle:nil];
        mainVC.title=@"日程助手";
        //        self.mainVC.hidesBottomBarWhenPushed = YES;
        [self hideTabBar];
        [self.navigationController pushViewController: mainVC animated:YES];
        [mainVC release];
    }else if(tagindex==3)
    {
        int serviceId = [_psDAO getServiceIdByName:redian_name];
        if (serviceId==-1) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"暂无内容" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        PSMsgDtlViewController *controller = [PSMsgDtlViewController getPSMsgDtlViewController];
        controller.needRefresh = YES;
        controller.serviceModel = [_psDAO getServiceByServiceId:serviceId];
        
        //			controller.hidesBottomBarWhenPushed = YES;
        [self hideTabBar];
		
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if(tagindex==4){//日程
        if (self.isCanKapod) {
            if (kapokHistory==nil) {
                kapokHistory = [[KapokHistoryViewController alloc] initWithNibName:nil bundle:nil];
                kapokHistory.title=@"木棉童飞";
                
            }
            [self hideTabBar];
            [self.navigationController pushViewController: kapokHistory animated:YES];
        }else if(self.isCanMass)
        {
            if(self.isCanMass) {
                broadcastViewController *broadcast=[[broadcastViewController alloc]init];
                [self hideTabBar];
                [self.navigationController pushViewController:broadcast animated:YES];
                [broadcast release];
            }
        
        }
        else if(self.isCanAppPlatform){
            //应用平台
            APPListViewController *ctr=[[APPListViewController alloc]init];
            [self hideTabBar];
            [self.navigationController pushViewController:ctr animated:YES];
            [ctr release];
        }
    }
    else if(tagindex==5)
    {
        if (self.isCanKapod) {
            if(self.isCanMass) {
                broadcastViewController *broadcast=[[broadcastViewController alloc]init];
                [self hideTabBar];
                [self.navigationController pushViewController:broadcast animated:YES];
                [broadcast release];
            }
        }
        else if(self.isCanMass){
            if (self.isCanAppPlatform) {
                //应用平台
                APPListViewController *ctr=[[APPListViewController alloc]init];
                [self hideTabBar];
                [self.navigationController pushViewController:ctr animated:YES];
                [ctr release];
            }
        }
    }
    else if(self.isCanMass && tagindex==6){
        if(self.isCanAppPlatform){
            //应用平台
            APPListViewController *ctr=[[APPListViewController alloc]init];
            [self hideTabBar];
            [self.navigationController pushViewController:ctr animated:YES];
            [ctr release];
        }
    }
    
    
}
 */



@end
