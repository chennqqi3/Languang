//
//  personInfoViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "personInfoViewController.h"
#import "UserDisplayUtil.h"
#import "eCloudNotification.h"
#import "talkSessionViewController.h"
#import "UIRoundedRectImage.h"
#import "Emp.h"
#import "FGalleryViewController.h"
#import "talkSessionUtil.h"
#import "eCloudDefine.h"

#import "LogUtil.h"
#import "ServerConfig.h"
//#import "AFHTTPRequestOperationManager.h"

#import "IOSSystemDefine.h"
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>

#import "SettingItem.h"

#import "RobotDAO.h"

#import "ImageSet.h"
#import "eCloudDAO.h"
#import <QuartzCore/QuartzCore.h>
#import "PermissionModel.h"
#import "PermissionUtil.h"
#import "conn.h"
#import "contactViewController.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "NewOrgViewController.h"

#import "UserDataDAO.h"

#import  "StatusConn.h"

#import "UserDataConn.h"

#import "UserTipsUtil.h"

#import "LCLLoadingView.h"
#import "ImageUtil.h"
#import "myCell.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import <MessageUI/MessageUI.h>
#import<MessageUI/MFMailComposeViewController.h>
#import "QuartzCore/QuartzCore.h"
#import "LanUtil.h"
#import "LCLLoadingView.h"
#import "UserDefaults.h"

#ifdef _XIANGYUAN_FLAG_
#import "WaterMarkViewARC.h"
#endif

#define BOTTOM_BAR_HEIGHT (55.0)

#define detail_width (SCREEN_WIDTH-99)
#define row_height (51)
#define detail_font (18.0)
#define btnIconWidth  (30.0)

#define myCellHeight 216
//文件助手ID
#define file_id 490000
@interface personInfoViewController ()<ABNewPersonViewControllerDelegate,MFMailComposeViewControllerDelegate,CNContactViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,FGalleryViewControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property(nonatomic,retain) NSMutableString *numberStr1;
@property(nonatomic,retain) NSMutableString *numberStr2;

@property(nonatomic,retain) NSMutableArray *locationArr;
@property(nonatomic,retain) NSMutableArray *lengthArr;
@end
static UIWebView *phoneCallWebView;
@implementation personInfoViewController
{
    NSString *titleStr;
    UITableView*   personTable;
    talkSessionViewController *talkSession;
    int sexType;
    Emp *emp;
    UIImageView *personImageView;
    //	异步下载头像请求
    ASIHTTPRequest *logoRequest;
    //预览图片
    FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
    NSString *preImageFullPath;
    
    UIAlertView *recordAlert;
    UIAlertView *repeatAlert;
    UIAlertView *mailAlert;

	eCloudDAO *db;
    UserDataDAO *userDataDAO;
    
    CGSize tempCellSize;
    CGSize deptSize;
    CGSize postCellSize;
    CGSize homeNumCellSize;
    CGSize addCellSize;
    CGSize emailCellSize;
    
    StatusConn *_statusConn;
    UserDataConn *_userDataConn;
    
    //    是否是机器人
    BOOL isRobot;
    
    //    数据项数组
    NSMutableArray *settingItemArray;
    
    UIView *bottomNavibar;
    
    UIButton *sendMsgBtn;
    UILabel *sendLabel;
    UIButton *addPersonBtn;
    UILabel *addLabel;
    
    ABRecordID repeatPersonId;
    
    NSInteger index;
}
@synthesize sendMsgButton;
@synthesize titleStr;
@synthesize sexType;
@synthesize emp;
@synthesize delegate;
@synthesize preImageFullPath;
-(void)dealloc
{
    [settingItemArray release];
    settingItemArray = nil;

    [[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];

	self.titleStr = nil;
	self.emp = nil;
	self.delegate = nil;
    self.preImageFullPath = nil;
    self.sendMsgButton = nil;
    if (phoneCallWebView != nil)
    {
        [phoneCallWebView release];
        phoneCallWebView = nil;
    }
    self.numberStr1 = nil;
    self.numberStr2 = nil;
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	db = [eCloudDAO getDatabase];
    userDataDAO = [UserDataDAO getDatabase];
    
    _statusConn = [StatusConn getConn];
	_userDataConn = [UserDataConn getConn];
    
    //	背景
    [UIAdapterUtil setBackGroundColorOfController:self];
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    //	标题
    self.title=[StringUtil getLocalizableString:@"personInfo_details"];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    //	添加常用联系人按钮
//    [UIAdapterUtil setRightButtonItemWithImageName:@"add_connet.png" andTarget:self andSelector:@selector(addButtonPressed:)];
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake(0, 0, 44, 44);
//    [addButton setBackgroundImage:[StringUtil getImageByResName:@"add_connet.png"] forState:UIControlStateNormal];
//    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
//	[addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
//    self.navigationItem.rightBarButtonItem= rightItem;
//    [rightItem release];
    /*
    UIView *topView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 133-44)];
    //	用户头像
	personImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 63-44, person_info_logo_size, person_info_logo_size)];
	personImageView.layer.masksToBounds=YES;
	personImageView.layer.cornerRadius=3.0;
    //	personImageView.layer.borderWidth=1.0;
    //	personImageView.layer.borderColor=[[UIColor grayColor] CGColor];
    personImageView.layer.masksToBounds = YES;//设为NO去试试
    [topView addSubview:personImageView];
    [personImageView release];
    personImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showbigimage)];
    [personImageView addGestureRecognizer:singleTap];
    [singleTap release];
    
    UILabel *namelabel=[[UILabel alloc] initWithFrame:CGRectMake(10 + person_info_logo_size + 18, 63-44, 60, 30)];
	namelabel.tag = 10;
    namelabel.backgroundColor=[UIColor clearColor];
    namelabel.font=[UIFont boldSystemFontOfSize:18];
    [topView addSubview:namelabel];
    [namelabel release];
    
    UILabel *signatureLabel=[[UILabel alloc] initWithFrame:CGRectMake(10 + person_info_logo_size + 18, 90-44, 250, 30)];
    signatureLabel.backgroundColor=[UIColor clearColor];
    signatureLabel.tag=12;
    signatureLabel.textColor=[UIColor grayColor];
    signatureLabel.textAlignment=UITextAlignmentLeft;
    signatureLabel.font=[UIFont systemFontOfSize:12];
    [topView addSubview:signatureLabel];
    [signatureLabel release];
    
    //	增加性别展示
	UIImageView *sexView = [[UIImageView alloc]initWithFrame:CGRectMake(10 + person_info_logo_size + 18 + 60, 69.5-44, 13.5, 13)];
	sexView.tag = 11;
	[topView addSubview:sexView];
	[sexView release];
	
    //	增加显示公司名称
	NSString *compName = [db getCompanyNameBy:[StringUtil getStringValue:emp.comp_id]];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10 + person_info_logo_size + 18, 93-44, 240, 30)];
	label.text = compName;
    label.textAlignment=UITextAlignmentLeft;
	label.font = [UIFont systemFontOfSize:15];
	label.textColor = [UIColor grayColor];// [StringUtil colorWithHexString:@"#8f8f8f"];
	label.backgroundColor = [UIColor clearColor];
	[topView addSubview:label];
	[label release];
    
	int tableH = 460-45;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
    personTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStyleGrouped];
    [personTable setDelegate:self];
    [personTable setDataSource:self];
    personTable.backgroundView = nil;
    personTable.backgroundColor = [UIColor clearColor];
    personTable.tableHeaderView=topView;
    personTable.showsHorizontalScrollIndicator = NO;
    personTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:personTable];
    [personTable release];
    [topView release];
    */
    
    float tableH = (self.view.frame.size.height + self.view.frame.origin.y) - ([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height) - BOTTOM_BAR_HEIGHT;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s self.view is %@ navigation is %@ statusbar is %@",__FUNCTION__,NSStringFromCGRect(self.view.frame),NSStringFromCGRect(self.navigationController.navigationBar.frame),NSStringFromCGRect([UIApplication sharedApplication].statusBarFrame)]];
//    
//    if (!self.navigationController.navigationBar.frame.origin.y) {
//        tableH = tableH
//    }
    
    personTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,tableH) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:personTable];
    [personTable setDelegate:self];
    [personTable setDataSource:self];
    personTable.backgroundView = nil;
    personTable.backgroundColor = [UIColor clearColor];
    personTable.showsHorizontalScrollIndicator = NO;
    personTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:personTable];
    [personTable release];
    /*
    UIView *buttonview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 58)];
    
    UIButton *sendButton = [UIAdapterUtil setNewButton:@"发送消息" andBackgroundImage:[StringUtil getImageByResName:@"login_button_new"]];
    
    sendButton.frame=CGRectMake(10, 0, 300, 45);
    
    [sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonview addSubview:sendButton];
    
    self.sendMsgButton = buttonview;
    
    personTable.tableFooterView=buttonview;
     */
    
//    [buttonview release];
	// Do any additional setup after loading the view.
    //	接收 聊天界面发出的 退回到会话窗口时发出的通知，关闭自己

//    CGFloat bottomNavHeight = 50.0;
//    NSLog(@"%f",self.view.frame.size.height-bottomNavHeight);
//    UIView *bottomNav = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-bottomNavHeight-88, self.view.frame.size.width, bottomNavHeight)];
//    [bottomNav setBackgroundColor:[UIColor redColor]];
//    [self.view addSubview:bottomNav];
//    [bottomNav release];

//    int toolbarY = self.view.frame.size.height - 44-44-5;
//    if (IOS7_OR_LATER)
//    {
//        toolbarY = toolbarY - 20-5;
//    }
/*
    float toolbarY = personTable.frame.size.height;
    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY, self.view.frame.size.width, BOTTOM_BAR_HEIGHT)];
    //    [UIAdapterUtil customLightNavigationBar:bottomNavibar];
    bottomNavibar.backgroundColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat spaceWidth = 7;
//    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, viewWidth, 1)];
//    lineLab.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
//    [bottomNavibar addSubview:lineLab];
//    [lineLab release];
    
    
    sendMsgBtn = [[UIButton alloc] init];
    
    sendMsgBtn.frame = CGRectMake(spaceWidth+2, spaceWidth, viewWidth*0.5-(spaceWidth*1.5)-8, BOTTOM_BAR_HEIGHT-(spaceWidth*2));
    [sendMsgBtn addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sendMsgBtn setBackgroundImage:[StringUtil getImageByResName:@"sendMsg_button"] forState:UIControlStateNormal];
    [sendMsgBtn setBackgroundImage:[StringUtil getImageByResName:@"sendMsg_button_press"] forState:UIControlStateHighlighted];
    sendMsgBtn.layer.masksToBounds = YES;
    sendMsgBtn.layer.cornerRadius = 4.8;
    [bottomNavibar addSubview:sendMsgBtn];
    [sendMsgBtn release];
    
    CGFloat iconX = 8.0;
    CGFloat iconY = 7.0;
    CGFloat iconWidth = 27.0;
    CGFloat iconHeight = 27.0;
    UIImageView *msgIconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY,iconWidth,iconHeight )];
    msgIconView.image = [StringUtil getImageByResName:@"icon_message"];
    
    [sendMsgBtn addSubview:msgIconView];
    [msgIconView release];
    
    sendLabel = [[UILabel alloc]init] ;
    if ([LanUtil isChinese]) {
        sendLabel.frame = CGRectMake(iconX+iconWidth, iconY, CGRectGetWidth(sendMsgBtn.frame)-14-22, iconHeight);   // 96
    }else {
        sendLabel.frame = CGRectMake(iconX+iconWidth, iconY, CGRectGetWidth(sendMsgBtn.frame)-18-22, iconHeight);
    }
    sendLabel.text = [StringUtil getLocalizableString:@"personinfo_send"];
    sendLabel.font = [UIFont systemFontOfSize:16.6];
    [sendLabel setTextColor:[UIColor whiteColor]];
    sendLabel.backgroundColor = [UIColor clearColor];
    sendLabel.textAlignment = UITextAlignmentCenter;
    sendLabel.adjustsFontSizeToFitWidth = YES;
    [sendMsgBtn addSubview:sendLabel];
    if ([UIAdapterUtil isGOMEApp])
    {
        sendMsgBtn.backgroundColor = [UIColor colorWithRed:2/255.0 green:139/255.0 blue:230/255.0 alpha:1];
        [sendMsgBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [sendMsgBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
        sendMsgBtn.frame = CGRectMake(spaceWidth+2, spaceWidth - 10, viewWidth*0.5-(spaceWidth*1.5)-8, BOTTOM_BAR_HEIGHT-(spaceWidth*2) + 10);
        
        msgIconView.frame = CGRectMake(iconX, iconY+5,iconWidth,iconHeight );
        sendLabel.frame = CGRectMake(iconX+iconWidth, sendLabel.frame.origin.y+5, CGRectGetWidth(sendMsgBtn.frame)-14-22, iconHeight);
    }
    [sendLabel release];
    
    
    
    addPersonBtn = [[UIButton alloc] init];
    addPersonBtn.frame = CGRectMake(viewWidth*0.5+(spaceWidth*0.5)+5, spaceWidth, CGRectGetWidth(sendMsgBtn.frame), CGRectGetHeight(sendMsgBtn.frame));
    [addPersonBtn setBackgroundImage:[StringUtil getImageByResName:@"addPerson_button"] forState:UIControlStateNormal];
    [addPersonBtn setBackgroundImage:[StringUtil getImageByResName:@"addPerson_button_press"] forState:UIControlStateHighlighted];
    
    [addPersonBtn addTarget:self action:@selector(savePersonBtnClick) forControlEvents:UIControlEventTouchUpInside];
    addPersonBtn.layer.masksToBounds = YES;
    addPersonBtn.layer.cornerRadius = 4.8;
    [bottomNavibar addSubview:addPersonBtn];
    [addPersonBtn release];
    
    UIImageView *addIconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY,iconWidth,iconHeight)];
    addIconView.image = [StringUtil getImageByResName:@"icon_people"];
    [addPersonBtn addSubview:addIconView];
    [addIconView release];
    
    
    addLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconX+iconWidth, iconY, CGRectGetWidth(sendMsgBtn.frame)-14-22, iconHeight)];
   
    addLabel.text = [StringUtil getLocalizableString:@"personinfo_save_to_contacts"];
    addLabel.font = [UIFont systemFontOfSize:16.6];
    addLabel.textAlignment = UITextAlignmentCenter;
    addLabel.backgroundColor = [UIColor clearColor];
    [addLabel setTextColor:[UIColor whiteColor]];
    addLabel.adjustsFontSizeToFitWidth = YES;
    [addPersonBtn addSubview:addLabel];
    [addLabel release];
    if ([UIAdapterUtil isGOMEApp])
    {
        addPersonBtn.backgroundColor = [UIColor colorWithRed:2/255.0 green:139/255.0 blue:230/255.0 alpha:1];
        [addPersonBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [addPersonBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
        addPersonBtn.frame = CGRectMake(viewWidth*0.5+(spaceWidth*0.5)+5, spaceWidth-10, viewWidth*0.5-(spaceWidth*1.5)-8, BOTTOM_BAR_HEIGHT-(spaceWidth*2) + 10);
        addIconView.frame = CGRectMake(iconX, iconY+5,iconWidth,iconHeight);
        addLabel.frame = CGRectMake(iconX+iconWidth, iconY+5, CGRectGetWidth(sendMsgBtn.frame)-14-22, iconHeight);
    }
*/
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];

    isRobot = [[RobotDAO getDatabase]isRobotUser:self.emp.emp_id];

    [self downloadEmpLogoIfNeed];
    
    [self refreshData];
    
    //如果是系统服务
    if (([UIAdapterUtil isTAIHEApp] && self.emp.isAppNoticeAccount) || ([UIAdapterUtil isLANGUANGApp] && self.emp.isAppNoticeAccount)) {
        
        addPersonBtn.hidden = YES;
        sendMsgBtn.hidden = YES;
        
    }

#ifdef _XIANGYUAN_FLAG_
    
    // 添加水印
    [WaterMarkViewARC waterMarkView:self.view];
    
#endif
}

-(void)addButtonPressed:(id)sender
{
    if ([userDataDAO isCommonEmp:self.emp.emp_id]) {
//        [self showAlert:[NSString stringWithFormat:[StringUtil getLocalizableString:@"personinfo_someone_is_already_common_emp"],self.emp.emp_name]];
        // 这里做成添加与删除开关类型
        
        if ([userDataDAO isDefaultCommonEmp:self.emp.emp_id]) {
            [UserTipsUtil showAlert:@"缺省联系人，不允许删除" autoDimiss:YES];
            return;
        }
        
        BOOL ret = [_userDataConn sendModiRequestWithDataType:user_data_type_emp andUpdateType:user_data_update_type_delete andData:[NSArray arrayWithObject:[NSNumber numberWithInt:self.emp.emp_id]]];
        
        if (ret) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        }
    }
    else
    {
        BOOL ret = [_userDataConn sendModiRequestWithDataType:user_data_type_emp andUpdateType:user_data_update_type_insert andData:[NSArray arrayWithObject:[StringUtil getStringValue:self.emp.emp_id]]];
        
        if (ret) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        }
    }
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
     
     //		NSLog(@"height is %.0f",contentView.frame.size.height);
     
     //		隐藏UITabBar
     self.tabBarController.tabBar.hidden = YES;
     
     }
     */
    [UIAdapterUtil hideTabBar:self];
}

- (void)displayBigImage
{
    FGalleryViewController *localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    [self.navigationController pushViewController:localGallery animated:YES];
    [localGallery release];
}

-(void)showbigimage
{
	NSString *empLogo = self.emp.emp_logo;
	if(empLogo && empLogo.length > 0)
	{
        //	预览图片
        
		NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
//        NSLog(@"%@",bigLogoPath);
		if([[NSFileManager defaultManager]fileExistsAtPath:bigLogoPath])
		{//大图存在
            
            self.preImageFullPath=bigLogoPath;
            [self displayBigImage];
		}
		else
		{
//            查看是否有小图，如果有小图，那么可以下载大图，否则不下载
            NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
            if([[NSFileManager defaultManager]fileExistsAtPath:logoPath])
            {
                [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
                
                /*
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                [manager.requestSerializer setValue:@"netsense" forHTTPHeaderField:@"netsense"];
                // 默认传输的数据类型
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                NSString *bigurl = [[ServerConfig shareServerConfig]getBigLogoUrlByEmpId:[StringUtil getStringValue:self.emp.emp_id]];
                [manager GET:bigurl parameters:nil success:^(IM_AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSData *bigImageData = responseObject;
                    if (bigImageData!=nil)
                    {
                        [bigImageData writeToFile:bigLogoPath atomically:YES];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UserTipsUtil hideLoadingView];
                        if (bigImageData)
                        {
                            //                        生成并保存小头像
                            UIImage *curImage = [UIImage imageWithData:bigImageData];
                            //
                            [StringUtil createAndSaveMicroLogo:curImage andEmpId:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
                            
                            [StringUtil createAndSaveSmallLogo:curImage andEmpId:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];

                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:self.emp.emp_id],@"emp_id",empLogo,@"emp_logo", nil];
                            [StringUtil sendUserlogoChangeNotification:dic];

                            self.preImageFullPath = bigLogoPath;
                            
                            [personTable reloadData];
                            
                            [self displayBigImage];
                            
                        }
                        else
                        {
                            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"userInfo_download_fail"]];
                        }
                    });
                    
                } failure:^(IM_AFHTTPRequestOperation *operation, NSError *error) {
                    
                    NSLog(@"下载大头像失败%@", error);
                }];
                */
                
                
              //  /*
                dispatch_queue_t queue = dispatch_queue_create("download.bigpic", NULL);
                dispatch_async(queue, ^{
                    NSURL *bigurl = [NSURL URLWithString:[[ServerConfig shareServerConfig]getBigLogoUrlByEmpId:[StringUtil getStringValue:self.emp.emp_id]]];
                    NSData *bigImageData = [NSData dataWithContentsOfURL:bigurl];
                    if (bigImageData.length > 0) {
                        [bigImageData writeToFile:bigLogoPath atomically:YES];
                        
                        //                        生成并保存小头像
                        UIImage *curImage = [UIImage imageWithData:bigImageData];
                        //
                        [StringUtil createAndSaveMicroLogo:curImage andEmpId:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
                        
                        [StringUtil createAndSaveSmallLogo:curImage andEmpId:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UserTipsUtil hideLoadingView];
                        if (bigImageData.length > 0)
                        {
//                            [personTable beginUpdates];
//                            [personTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                            [personTable endUpdates];
                            self.preImageFullPath = bigLogoPath;
                            [self displayBigImage];
//                            [self refreshData];
                        }
                        else
                        {
                            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"userInfo_download_fail"]];
                        }
                    });
                });
                dispatch_release(queue);
                // */
            }
        }
	}
}
- (void)viewDidUnload
{
    [super viewDidUnload];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	
}
-(UIImage*)getDefaultLogo
{
	UIImage *_image;
	if(self.emp.emp_sex == 0)
	{
		_image = [StringUtil getImageByResName:@"female.png"];
	}
	else
	{
		_image = [StringUtil getImageByResName:@"male.png"];
	}
	return _image;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
//    _statusConn.curViewController = self;
//    [_statusConn getStatus];
//    self.numberStr1 = @"";
//    self.numberStr2 = @"";
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    
	[self hideTabBar];
    [self.navigationController setNavigationBarHidden:NO];
//    [self refreshData];

}

-(CGSize)configCellSize:(NSString*)contentStr
{
    if (contentStr.length > 0) {
        
            
        tempCellSize = [contentStr sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(detail_width, 300.0f) lineBreakMode:UILineBreakModeWordWrap];
        
        if (tempCellSize.height < row_height) {
            
            if (tempCellSize.height > 30) {
                
                tempCellSize.height = tempCellSize.height +30;
                
            }else{
                
                tempCellSize.height = row_height;
            }
        }
        else
        {
            tempCellSize.height = tempCellSize.height + 30;
        }
    }
    else
    {
        tempCellSize = CGSizeMake(detail_width, row_height);
    }
    return tempCellSize;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getEmpInfo];
}

- (void)refreshData
{
//    self.emp.titleName = @"职位职位职位职位职位职位职位职位职位职位职位职位职位职位职位";
//    self.emp.deptName = @"部门部门部门部门部门部门部门部门部门部门部门部门部门部门";
//    self.emp.emp_tel = @"123456789,0987654321";
//    self.emp.emp_mobile = @"123456789,0987654321,456789";
//    self.emp.empAddress = @"地址地址地址地址地址地址地址地址地址地址地址地址地址地址地址";

    self.titleStr = self.emp.emp_name;
    self.sexType = self.emp.emp_sex;
    
    //    如果用户设置了部分资料隐藏或全部资料隐藏，或用户所在部门设置了隐藏，只显示工号，姓名，性别，签名，部门等信息
    if(self.emp.permission.isHidePartInfo)
    {
        self.emp.emp_mobile = nil;
        self.emp.emp_mail = nil;
        self.emp.emp_hometel = nil;
        self.emp.emp_emergencytel = nil;
        self.emp.titleName = nil;
        self.emp.emp_tel = nil;
    }
    
    //    计算需要多行现在的cellSize
    if (self.emp) {
        postCellSize = [self configCellSize:self.emp.titleName];
        deptSize = [self configCellSize:self.emp.deptName];
        homeNumCellSize = [self configCellSize:self.emp.emp_tel];
        emailCellSize = [self configCellSize:self.emp.emp_mail];
        addCellSize = [self configCellSize:self.emp.empAddress];
    }
    
    if(emp.permission.canSendMsg)
    {
        personTable.tableFooterView = self.sendMsgButton;
    }
    else
    {
        personTable.tableFooterView = nil;
    }
    
    if ([UIAdapterUtil isTAIHEApp]) {
        
        [self prepareTAIHESettingItems];
    }else{
#ifdef _XIANGYUAN_FLAG_
        
        [self prepareXIANGYUANItems];
#else
        [self prepareSettingItems];

#endif
            }
	[personTable reloadData];
    
    return;
    
     //显示用户头像
    /*
    UIImage *tempLogo;
    NSString *empLogo = self.emp.emp_logo;
    int empID=self.emp.emp_id;
    if(empLogo && empLogo.length > 0)
    {
        NSString *picPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:empID] andLogo:empLogo];
        tempLogo = [UIImage imageWithContentsOfFile:picPath];
        if(tempLogo == nil)
        {
            tempLogo = [self getDefaultLogo];
            //			下载小图
            dispatch_queue_t queue = dispatch_queue_create("download user logo", NULL);
            dispatch_async(queue, ^{
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLogoFileDownloadUrl],empLogo]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                UIImage *imge = [UIImage imageWithData:imageData];
                if (imge!=nil) {
                    //					保存之前，先删除原来的数据
                    [StringUtil deleteUserLogoIfExist:[StringUtil getStringValue:empID]];
                    
                    BOOL success= [imageData writeToFile:picPath atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(success)
                        {
                            if(empID==self.emp.emp_id)
                                personImageView.image=imge;
                        }
                    });
                    
                    //					同时生成离线头像
                    UIImage *offlineimage=[ImageSet setGrayWhiteToImage:imge];
                    NSString *offlinepicPath = [StringUtil getOfflineLogoFilePathBy:[StringUtil getStringValue:empID] andLogo:empLogo];
                    NSData *dataObj = UIImageJPEGRepresentation(offlineimage, 1.0);
                    [dataObj writeToFile:offlinepicPath atomically:YES];
                }
            });
        }
        //下载大图
        NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
        
        if(![[NSFileManager defaultManager]fileExistsAtPath:bigLogoPath])
        {
            dispatch_queue_t queue = dispatch_queue_create("download.bigpic", NULL);
            dispatch_async(queue, ^{
                NSURL *bigurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getBigLogoFileDownloadUrl],empLogo]];
                NSData *BigImageData = [NSData dataWithContentsOfURL:bigurl];
                if (BigImageData!=nil) {
                    [BigImageData writeToFile:bigLogoPath atomically:YES];
                }
            });
        }
    }
    else
    {
        tempLogo = [self getDefaultLogo];
    }
    */
    
    
    //显示用户头像
	
	UIImage *tempLogo;
	NSString *empLogo = self.emp.emp_logo;
    int empID=self.emp.emp_id;
	if(empLogo && empLogo.length > 0)
	{
		NSString *picPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:empID] andLogo:empLogo];
		tempLogo = [UIImage imageWithContentsOfFile:picPath];
        NSData *imageData;
		if(tempLogo == nil)
		{
			tempLogo = [self getDefaultLogo];
            //    add by shisp 如果已经获取了用户资料那么下载用户头像
            if (self.emp.info_flag)
            {
                //			下载小图 万达版本现在已经有小图和大图
                dispatch_queue_t queue = dispatch_queue_create("download small user logo", NULL);
                dispatch_async(queue, ^{
                    
                    NSURL *url = [NSURL URLWithString:[[ServerConfig shareServerConfig]getLogoUrlByEmpId:[StringUtil getStringValue:empID]]];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    
                    if (imageData) {
                        
                        //					保存之前，先删除原来的数据
                        [StringUtil deleteUserLogoIfExist:[StringUtil getStringValue:empID]];
                        
//                        UIImage *tempImage = [UIImage imageWithData:imageData];
                        
//                        NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
//                        
//                        [imageData writeToFile:bigLogoPath atomically:YES];
                        
//                        CGSize _size = [talkSessionUtil getLogoImageSize:tempImage];
//                        
//                        UIImage *logoImage = nil;
//                        if (_size.width >0 && _size.height>0)
//                        {
//                            logoImage = [ImageUtil scaledImage:tempImage  toSize:_size withQuality:kCGInterpolationHigh];
//                        }
//                        else
//                        {
//                            logoImage = tempImage;
//                        }
                        
                        BOOL success= [UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1.0) writeToFile:picPath atomically:YES];
                        
                        if (success) {
                            [StringUtil sendUserlogoChangeNotification:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:empID],@"emp_id",empLogo,@"emp_logo", nil]];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(success)
                            {
                                if(empID == self.emp.emp_id)
                                    [personTable reloadData];
//                                    personImageView.image=imge;
                            }
                        });
                        
                        //					同时生成离线头像
                        /*
                        UIImage *offlineimage=[ImageSet setGrayWhiteToImage:logoImage];
                        NSString *offlinepicPath = [StringUtil getOfflineLogoFilePathBy:[StringUtil getStringValue:empID] andLogo:empLogo];
                        NSData *dataObj = UIImageJPEGRepresentation(offlineimage, 1.0);
                        [dataObj writeToFile:offlinepicPath atomically:YES];
                         */
                    }
                });
            }
		}
        
        if (self.emp.info_flag)
        {
            [StringUtil downloadBigUserLogoByEmpId:[StringUtil getStringValue:self.emp.emp_id] andEmpLogo:empLogo];
        }
	}
	else
	{
		tempLogo = [self getDefaultLogo];
	}
    
//	personImageView.image=tempLogo;
	
//    personImageView.image = [ImageUtil getOnlineEmpLogo:self.emp];
    
//    [self configNameAndSex];
    
    /*
	if (self.emp.signature!=nil&&[self.emp.signature length]>0) {
        UILabel *signatureLabel=(UILabel *)[self.view viewWithTag:12];
        signatureLabel.hidden=NO;
        signatureLabel.text=self.emp.signature;
    }else
    {
        UILabel *signatureLabel=(UILabel *)[self.view viewWithTag:12];
        signatureLabel.hidden=YES;
    }
    */
     

}
/*
- (void)configNameAndSex
{
    UILabel *namelabel=(UILabel*)[self.view viewWithTag:10];
    namelabel.lineBreakMode = UILineBreakModeTailTruncation;
    namelabel.text=self.titleStr;
	
    //    nameLabel和sexType所占的总宽度为
    float totalWidth = 300 - person_info_logo_size - 18;
    //13.5是sexview的宽度，2是名字和sexview的间隔
    float sexWidth = 13.5;
    float cellPad = 2;
    float maxNameWidth = totalWidth - sexWidth - cellPad;
    
    [namelabel sizeToFit];
    
    CGRect _frame;
    if (namelabel.frame.size.width > maxNameWidth)
    {
        _frame = namelabel.frame;
        _frame.size.width = maxNameWidth;
        namelabel.frame = _frame;
    }
    
	UIImageView *sexView = (UIImageView *)[self.view viewWithTag:11];
	if(self.sexType == 0)
	{
		sexView.image = [StringUtil getImageByResName:@"small_female.png"];
	}
	else
    {
		sexView.image = [StringUtil getImageByResName:@"small_male.png"];
	}
    _frame = sexView.frame;
    
    _frame.origin.x = namelabel.frame.origin.x + namelabel.frame.size.width + cellPad;
    _frame.origin.y = namelabel.frame.origin.y + (namelabel.frame.size.height - sexView.frame.size.height) / 2;
    sexView.frame = _frame;
    
    //       NSLog(@"%@,%@",namelabel,sexView);
    
}*/
- (void)getEmpInfo
{
    //    如果还没有获取用户资料，又要求显示全部资料，那么先去获取资料
    if (!self.emp.info_flag && !self.emp.permission.isHidePartInfo)
    {
        NSLog(@"用户资料还没有获取，并且要求显示全部资料，所以需要从服务器端取数据");
        conn *_conn = [conn getConn];
		bool ret = [_conn getUserInfo:emp.emp_id];
		if(ret)
		{
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"loading"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
		}
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
//    _statusConn.curViewController = nil;
    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];
}


-(void)dismissSelf:(NSNotification *)notification
{
	
	[self dismissModalViewControllerAnimated:NO];
	[[NSNotificationCenter defaultCenter]postNotificationName:PERSON_INFO_DISMISS_NOTIFICATION object:nil userInfo:nil];
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    
	[self.navigationController popViewControllerAnimated:YES];
}

-(void) sendButtonPressed:(id) sender
{
    if (self.isComeFromChooseView || self.isComeFromContactView) {
        
        talkSession = [talkSessionViewController getTalkSession];
        talkSession.talkType = singleType;
        talkSession.titleStr = self.emp.emp_name;
        talkSession.needUpdateTag = 1;
        talkSession.convId = [NSString stringWithFormat:@"%d",self.emp.emp_id];
        talkSession.convEmps = [NSArray arrayWithObject:self.emp];
        
        if (self.isComeFromChooseView){
            [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
            [self dismissModalViewControllerAnimated:NO ];
        }
        else{
//            [self.navigationController pushViewController:talkSession animated:YES];
//            [UIAdapterUtil openConversation:self andEmp:self.emp];
            [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
            [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWORG object:nil];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    else
    {
        [UIAdapterUtil openConversation:self andEmp:self.emp];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return settingItemArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section

    NSArray *_array = [settingItemArray objectAtIndex:section];
    return _array.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (isRobot && indexPath.section == 1) {
//        return [self getRobotUserCellHeightOfIndexpath:indexPath];
//    }
    if (indexPath.section==0 && indexPath.row == 0) {
        return myCellHeight;
    }else{
        SettingItem *_item = [self getSettingItemByIndexPath:indexPath];

        CGSize detailValueSize = _item.detailValueSize;
        if (detailValueSize.height) {
            return detailValueSize.height;
        }
        return DEFAULT_ROW_HEIGHT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) return 0.01;
    
    return 12;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //	if(section == 2) return 18;
    return 0.01;
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    if (section ==0 && indexPath.row == 0)
    {
        return [self getUserInfoCell];
    }

    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        UILabel *tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(12, 0, 63, 51)];
        tipLabel.tag=1;
        tipLabel.backgroundColor=[UIColor clearColor];
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.font  = [UIFont systemFontOfSize:17];
        
        [cell addSubview:tipLabel];
        [tipLabel release];
        
        UILabel *tipDetailLabel=[[UILabel alloc]initWithFrame:CGRectMake(87, 0, detail_width, DEFAULT_ROW_HEIGHT)];
        tipDetailLabel.tag=2;
        tipDetailLabel.backgroundColor=[UIColor clearColor];
        tipDetailLabel.font = [UIFont systemFontOfSize:17];
        tipDetailLabel.numberOfLines = 0;
        [cell addSubview:tipDetailLabel];
        [tipDetailLabel release];
        
//        UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40,(row_height-btnIconWidth)*0.5, btnIconWidth, btnIconWidth)];
//        rightView.tag = 3;
//        [cell addSubview:rightView];
//        [rightView release];

    }
    
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    
    UILabel *tipLabel=(UILabel *)[cell viewWithTag:1];
    UILabel *tipDetailLabel=(UILabel *)[cell viewWithTag:2];
    UIImageView *rightView = (UIImageView *)[cell viewWithTag:3];
    
    tipLabel.text=_item.itemName;
    
    tipDetailLabel.text = _item.itemValue;
    tipDetailLabel.textColor = _item.detailValueColor;

    if (_item.detailValueSize.height) {
        CGRect _frame = tipDetailLabel.frame;
        _frame.size = _item.detailValueSize;
        _frame.origin.y = 0;
        tipDetailLabel.frame = _frame;
        
#ifdef _XIANGYUAN_FLAG_
        if (indexPath.row == 0) {
            
            if (tipDetailLabel.text.length) {
                tipDetailLabel.textColor = [UIColor grayColor];
                tipDetailLabel.font = [UIFont systemFontOfSize:13];

                [self changeLineSpaceForLabel:tipDetailLabel WithSpace:0];

                CGFloat labelHeight = [tipDetailLabel sizeThatFits:CGSizeMake(detail_width+5, MAXFLOAT)].height;
                NSNumber *count = @((labelHeight) / tipDetailLabel.font.lineHeight);
                postCellSize.height = ([count integerValue]) * 18.2 + 20;
    
                _item.detailValueSize = postCellSize;
                CGRect _frame = tipDetailLabel.frame;
                _frame.size.height = postCellSize.height;
                _frame.origin.y = 10;
                tipDetailLabel.frame = _frame;
                

                
            }
        }
#endif
    }

    if ([UIAdapterUtil isTAIHEApp]) {
        
        CGRect _frame = tipLabel.frame;
        _frame.size.height = tipDetailLabel.frame.size.height -5;
        tipLabel.frame = _frame;
    }
    
    if (_item.customCellSelector) {
        [self performSelector:_item.customCellSelector withObject:cell];
    }
    
    return cell;
}


- (UITableViewCell *)getUserInfoCell
{
    myCell *mCell = [[myCell alloc] init];
    
    mCell.nameLable.text = self.emp.emp_name;
    [self configNameAndSex:mCell];
    
//    mCell.deptLable.font =[UIFont systemFontOfSize:13.0];
    
    mCell.deptLable.text = self.emp.empCode;
    if ([UIAdapterUtil isCsairApp]) {
        mCell.deptLable.text = self.emp.signature;
    }
    
    mCell.ModifyView.hidden = YES;
//    mCell.deptLable.frame = CGRectMake(deptX, deptY-7, deptMAXWidth, 40);
    mCell.iconView.image = [ImageUtil getOnlineEmpLogo:self.emp];
    if ([mCell.iconView.image isEqual:default_logo_image]) {
        NSDictionary *mDic = [UserDisplayUtil getUserDefinedLogoDicOfEmp:emp];
        [UserDisplayUtil setUserDefinedLogo:mCell.iconView andLogoDic:mDic];
    } else {
        [UserDisplayUtil hideLogoText:mCell.iconView];
    }

#define buttonWidth 36
#define labelWidth 100
    
    mCell.iconView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showbigimage)];
    [mCell.iconView addGestureRecognizer:singleTap];
    [singleTap release];
    
    UIButton *savaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    savaButton.frame = CGRectMake(SCREEN_WIDTH /2 - buttonWidth/2, 136, buttonWidth, buttonWidth);
    [savaButton setImage:[StringUtil getImageByResName:@"btn_contact_datum_save"] forState:UIControlStateNormal];
    [savaButton setImage:[StringUtil getImageByResName:@"btn_contact_datum_save_pressed"] forState:UIControlStateHighlighted];
    [savaButton addTarget:self action:@selector(savePersonBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [mCell addSubview:savaButton];
    [savaButton release];
    
    UILabel *savaLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH /2 - labelWidth/2, savaButton.frame.origin.y + savaButton.frame.size.height + 6, labelWidth, 20)];
    savaLabel.text = @"保存联系人";
    savaLabel.font = [UIFont systemFontOfSize:13];
    [savaLabel setTextAlignment:NSTextAlignmentCenter];
    savaLabel.textColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
    [mCell addSubview:savaLabel];
    [savaLabel release];
    
    
    UIButton *msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    msgBtn.frame = CGRectMake(SCREEN_WIDTH /4 - buttonWidth/2, 136, buttonWidth, buttonWidth);
    [msgBtn setImage:[StringUtil getImageByResName:@"btn_contact_datum_message"] forState:UIControlStateNormal];
    [msgBtn setImage:[StringUtil getImageByResName:@"btn_contact_datum_message copy"] forState:UIControlStateHighlighted];
    [msgBtn addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mCell addSubview:msgBtn];
    [msgBtn release];
    
    UILabel *msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH /4 - labelWidth/2, msgBtn.frame.origin.y + savaButton.frame.size.height + 6, labelWidth, 20)];
    msgLabel.text = @"发送消息";
    msgLabel.font = [UIFont systemFontOfSize:13];
    [msgLabel setTextAlignment:NSTextAlignmentCenter];
    msgLabel.textColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
    [mCell addSubview:msgLabel];
    [msgLabel release];
    

    UIButton *addCommonIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    addCommonIcon.frame = CGRectMake(msgBtn.frame.origin.x*3 + buttonWidth, 136, buttonWidth, buttonWidth);
    if ([userDataDAO isCommonEmp:self.emp.emp_id]) {
        [addCommonIcon setImage:[StringUtil getImageByResName:@"addContact_click"] forState:UIControlStateNormal];
    }else{
        [addCommonIcon setImage:[StringUtil getImageByResName:@"addContact"] forState:UIControlStateNormal];
    }
    [addCommonIcon addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mCell addSubview:addCommonIcon];
    [addCommonIcon release];
    
    UILabel *CommonLabel = [[UILabel alloc]initWithFrame:CGRectMake(msgLabel.frame.origin.x*3 + labelWidth+5, msgBtn.frame.origin.y + savaButton.frame.size.height + 6, labelWidth, 20)];
    NSString *string = @"添加常用联系人";
    UIColor *_color = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
    if ([userDataDAO isCommonEmp:self.emp.emp_id]) {
        string = @"移除常用联系人";
        _color = [UIColor colorWithRed:255/255.0 green:150/255.0 blue:0/255.0 alpha:1/1.0];
    }
    CommonLabel.text = string;
    CommonLabel.font = [UIFont systemFontOfSize:13];
    [CommonLabel setTextAlignment:NSTextAlignmentCenter];
    CommonLabel.textColor = _color;
    [mCell addSubview:CommonLabel];
    [CommonLabel release];
    
    addCommonIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *addCommonEmp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addButtonPressed:)];
    [addCommonIcon addGestureRecognizer:addCommonEmp];
    [addCommonEmp release];
    
    //}
    
    mCell.accessoryType = UITableViewCellAccessoryNone;
    mCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return [mCell autorelease];
}

-(void)configNameAndSex:(myCell *) mCell
{
    [mCell.nameLable sizeToFit];
    float sexWidth = 16;//sexView的宽度
    float cellPad = 8;//namelable与sexView的间隔
    
    float maxNameWidth = 188 - sexWidth - cellPad;
    
    CGRect _frame = CGRectMake(nameX, nameY, mCell.nameLable.frame.size.width, mCell.nameLable.frame.size.height);
    
    if (mCell.nameLable.frame.size.width > maxNameWidth)
    {
        _frame = mCell.nameLable.frame;
        _frame.size.width = maxNameWidth;
    }
  
    mCell.nameLable.frame = _frame;
//    NSLog(@"%@",NSStringFromCGRect(mCell.nameLable.frame));
    UIImageView *sexView = [[UIImageView alloc] initWithFrame:CGRectMake(_frame.origin.x+mCell.nameLable.frame.size.width+cellPad, nameY+2, 16, 16)];
//    NSLog(@"%@",NSStringFromCGRect(sexView.frame));
    if(self.sexType == 0)
    {
        sexView.image = [StringUtil getImageByResName:@"ic_contact_datum_ woman"];
    }
    else
    {
        sexView.image = [StringUtil getImageByResName:@"ic_contact_datum_man"];
    }
    [mCell.contentView addSubview:sexView];
    
    if ([UIAdapterUtil isTAIHEApp]) {
        
        mCell.deptLable.hidden = YES;
        mCell.nameLable.frame = CGRectMake(nameX, (myCellHeight/2) - (mCell.nameLable.frame.size.height/2) , mCell.nameLable.frame.size.width, mCell.nameLable.frame.size.height);
        sexView.frame = CGRectMake(mCell.nameLable.frame.size.width + mCell.nameLable.frame.origin.x + cellPad , mCell.nameLable.frame.origin.y+2, sexWidth+1, 18);
    }
#ifdef _XIANGYUAN_FLAG_
    
    mCell.deptLable.hidden = YES;
    mCell.nameLable.frame = CGRectMake(nameX, (myCellHeight/2) - (mCell.nameLable.frame.size.height/2) , mCell.nameLable.frame.size.width, mCell.nameLable.frame.size.height);
    sexView.frame = CGRectMake(mCell.nameLable.frame.size.width + mCell.nameLable.frame.origin.x + cellPad , mCell.nameLable.frame.origin.y+2, sexWidth+1, 18);
    
#endif
    
#ifdef _LANGUANG_FLAG_
    
    mCell.deptLable.hidden = YES;
    mCell.nameLable.frame = CGRectMake(SCREEN_WIDTH/2 - mCell.nameLable.frame.size.width/2, (myCellHeight/2) - (mCell.nameLable.frame.size.height/2) , mCell.nameLable.frame.size.width, mCell.nameLable.frame.size.height);
    sexView.frame = CGRectMake(mCell.nameLable.frame.size.width + mCell.nameLable.frame.origin.x + cellPad , mCell.nameLable.frame.origin.y+5, 16 ,16);
    
#endif
    
    [sexView release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    index = indexPath.row;
    if (_item.clickSelector) {
        [self performSelector:(_item.clickSelector)];
    }
}
// 0907
- (void)presentMailSheet{
    
    NSString *string = nil;
    if ([UIAdapterUtil isTAIHEApp]) {
        
        if (index == 2){
            if (emp.emp_mail == nil || [emp.emp_mail isEqualToString:@""]) {
                return;
            }
            string = emp.emp_mail;
            
        }else if (index == 5){
            if (emp.signature == nil || [emp.signature isEqualToString:@""] ) {
                return;
            }
            
            string = emp.signature;
            
        }else if (index == 6){
            
            if (emp.empAddress == nil || [emp.empAddress isEqualToString:@""]) {
                return;
            }
            
            string = emp.empAddress;
        }
    }else{
        
        if (emp.emp_mail == nil || [emp.emp_mail isEqualToString:@""]) {
            return;
        }
        
        string = emp.emp_mail;
    }
    UIActionSheet *mailSheet = [[UIActionSheet alloc]initWithTitle:string delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:[StringUtil getLocalizableString:@"copy"],nil];
    if (![UIAdapterUtil isTAIHEApp]) {
        
        mailSheet.tag = 907;
    }
    
    [mailSheet showInView:self.view];
}



#pragma mark 调用系统通讯录的代理方法 用来保存联系人和返回
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark 调用系统发送邮件的代理方法 用来发送完邮件和返回
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
    [self dismissModalViewControllerAnimated:YES];
    if(error == nil)
    {
//        if(result == MFMailComposeResultSent)
//        {
//            [self showAlert:@"发送成功"];
//        }else
            if (result == MFMailComposeResultFailed)
        {
            [self showAlert:@"发送失败,请检查邮箱"];
        }
    }
    else
    {
        NSLog(@"-------%@",error);
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == repeatAlert) {
        // 覆盖保存
        if (buttonIndex == 1) {
            
            [self insertOneRecord];
            
        }
        
    }
    if (alertView == mailAlert) {
        // 覆盖保存
        if (buttonIndex == 1) {
            
            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
            if (!mailClass) {
                [self showAlert:@"当前系统版本不支持应用内发送邮件功能"];
                return;
            }
            if (![mailClass canSendMail]) {
                [self showAlert:@"用户没有设置邮箱账户"];
                return;
            }
            [self displayMailPicker];
            
        }
        
    }
    
    /*
    else
    {
        //        第一次保存
        if (buttonIndex == 1)
        {
            [self insertOneRecord];
            //            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            ////                第一次访问通讯录
            //                if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            //                    //ios6.0以上访问通讯录需要授权
            //                    ABAddressBookRef addressBook = ABAddressBookCreate();
            //                    if (addressBook) {
            //                        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            //                            if (granted) {
            //                                //查询所有
            //                                [self afterGranted];
            //                                NSLog(@"允许访问通讯录");
            //                            }
            //                            else
            //                            {
            //                                NSLog(@"不允许访问通讯录");
            //                            }
            //
            //                        });
            //                        CFRelease(addressBook);
            //                    }
            //                }
            ////                拒绝访问通讯录
            //                else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
            //                {
            //                    [self showCanNotAccessContacts];
            //                }
            //                else
            //                {
            //                    [self insertOneRecord];
            //                }
            //            }
            //            else
            //            {
            //                [self insertOneRecord];
            //            }
        }
    }
     */
}

-(void)savePersonBtnClick
{
    
    //        如果是ios6以上，那么需要判断是否可以访问通讯录，第一次时提示用户是否允许
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        //                第一次访问通讯录
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRef addressBook = ABAddressBookCreate();
            if (addressBook) {
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    if (granted) {
                        //查询所有
                        [self afterGranted];
                    }
                });
                CFRelease(addressBook);
            }
            return;
        }
        //                拒绝访问通讯录
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
        {
            [self showCanNotAccessContacts];
            return;
        }
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 检查联系人是否已经保存 之前",__FUNCTION__]];
    BOOL is_repeat=[self checkIsRepeatPerson];
    if (is_repeat) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 检查联系人是否已经保存 之后 联系人已经存在",__FUNCTION__]];
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"%s 检查联系人是否已经保存 之后 联系人不存在",__FUNCTION__]];
    }
    
    if (is_repeat) {
        
        NSString *sure_str;
        if ([UIAdapterUtil isTAIHEApp]) {
            
            sure_str = [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@",[StringUtil getLocalizableString:@"personInfo_name"],emp.emp_name,[StringUtil getLocalizableString:@"personInfo_position"],emp.titleName,[StringUtil getLocalizableString:@"personInfo_mobile"],emp.emp_mobile,[StringUtil getLocalizableString:@"personInfo_tel"],emp.emp_tel,[StringUtil getLocalizableString:@"personInfo_Email"],emp.emp_mail];
            
        }else{
            
            sure_str = [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@",[StringUtil getLocalizableString:@"personInfo_name"],emp.emp_name,[StringUtil getLocalizableString:@"personInfo_department"],emp.deptName,[StringUtil getLocalizableString:@"personInfo_position"],emp.titleName,[StringUtil getLocalizableString:@"personInfo_employee_id"],emp.empCode,[StringUtil getLocalizableString:@"personInfo_mobile"],emp.emp_mobile,[StringUtil getLocalizableString:@"personInfo_tel"],emp.emp_tel,[StringUtil getLocalizableString:@"personInfo_Email"],emp.emp_mail];
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 联系人已经存在 str is %@",__FUNCTION__,sure_str]];
        
        
        if (IOS8_OR_LATER) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[StringUtil getLocalizableString:@"personinfo_contact_already_exists"] message:sure_str preferredStyle:UIAlertControllerStyleAlert];
            
            //            取消按钮
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"personinfo_no"] style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            //            确认按钮
            UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"personinfo_yes"] style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self insertOneRecord];
                                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  }];
            [alert addAction:cancelAction];
            [alert addAction:confirmAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
            repeatAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"personinfo_contact_already_exists"] message:sure_str delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"personinfo_no"] otherButtonTitles:[StringUtil getLocalizableString:@"personinfo_yes"], nil];
            [repeatAlert show];
            [repeatAlert release];
        }
        
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 完成弹框",__FUNCTION__]];
    }
    //第一次添加
    else
    {
        if (IOS9_OR_LATER) {
            [self addNewContactInIOS9];
        }else{
            [self addNewContact];
        }
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    printf("User Pressed Button %d\n", buttonIndex);
    
    if (actionSheet.tag ==102) {
        if (buttonIndex==1) {//
            [personInfoViewController callNumber:self.numberStr2];
        }else if(buttonIndex==0)
        {
            [personInfoViewController callNumber:self.numberStr1];
        }
    }else if(actionSheet.tag == 907){ // 0907
        
        if (0 == buttonIndex) {
//            // 调用系统邮件功能
//            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
//            if (!mailClass) {
//                    [self showAlert:@"当前系统版本不支持应用内发送邮件功能"];
//                    return;
//                }
//                if (![mailClass canSendMail]) {
//                    [self showAlert:@"用户没有设置邮箱账户"];
//                    return;   
//                }
            //[self displayMailPicker];
            
            // 复制邮件到剪贴板
            [self copyMailAddr:emp.emp_mail];
            
            
        }else if(1 == buttonIndex){
            
            NSLog(@"取消复制");
        }
        
    }else if ([UIAdapterUtil isTAIHEApp]){
        if (index == 5) {
            
            if (buttonIndex == 0) {
                
                [self copyMailAddr:emp.signature];
            }else{
                
                NSLog(@"取消复制");
            }
            
        }
        if (index == 6) {
            
            if (buttonIndex == 0) {
                
                [self copyMailAddr:emp.empAddress];
            }else{
                
                NSLog(@"取消复制");
            }
            
        }
        if (index == 2) {
            
            if (buttonIndex == 0) {
                
                [self copyMailAddr:emp.emp_mail];
            }else{
                
                NSLog(@"取消复制");
            }
            
        }
    }
    else{
    
    if (buttonIndex==1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",emp.emp_mobile]]];
    }else if(buttonIndex==0)
    {
        [personInfoViewController callNumber:emp.emp_mobile];
    }
    
    else if(buttonIndex==100)
    {
        //        如果是ios6以上，那么需要判断是否可以访问通讯录，第一次时提示用户是否允许
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            //                第一次访问通讯录
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
                ABAddressBookRef addressBook = ABAddressBookCreate();
                if (addressBook) {
                    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                        if (granted) {
                            //查询所有
                            [self afterGranted];
                        }
                    });
                    CFRelease(addressBook);
                }
                return;
            }
            //                拒绝访问通讯录
            else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
            {
                [self showCanNotAccessContacts];
                return;
            }
        }
        
        NSString *sure_str;
        if ([UIAdapterUtil isTAIHEApp]) {
            
            sure_str=[NSString stringWithFormat:@"姓名:%@\n职务:%@\n手机:%@\n座机:%@\n邮箱:%@",emp.emp_name,emp.titleName,emp.emp_mobile,emp.emp_tel,emp.emp_mail];
            
        }else{
           
            sure_str=[NSString stringWithFormat:@"姓名:%@\n部门:%@\n职务:%@\n账号:%@\n手机:%@\n座机:%@\n邮箱:%@",emp.emp_name,emp.deptName,emp.titleName,emp.empCode,emp.emp_mobile,emp.emp_tel,emp.emp_mail];
        }
        
        BOOL is_repeat=[self checkIsRepeatPerson];
        if (is_repeat) {
                repeatAlert=[[UIAlertView alloc]initWithTitle:@"联系人已存在，是否覆盖" message:sure_str delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                [repeatAlert show];
                [repeatAlert release];
        }
        //第一次添加
        else
        {
            [self addNewContact];
        }
    
        /*
        BOOL is_repeat=[self checkIsRepeatPerson];
        if (is_repeat) {
            if (repeatAlert==nil) {
                repeatAlert=[[UIAlertView alloc]initWithTitle:@"联系人已存在，是否覆盖" message:sure_str delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                
            }
            else
            {
                [repeatAlert setMessage:sure_str];
            }
            [repeatAlert show];
            return;
        }
        
        if (recordAlert==nil) {
            recordAlert=[[UIAlertView alloc]initWithTitle:@"是否保存到手机通讯录" message:sure_str delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            
        }
        else
        {
            [recordAlert setMessage:sure_str];
        }
        [recordAlert show];
         */
    }
    }
    [actionSheet release];
}

// 0907 复制消息到剪贴板
- (void)copyMailAddr:(NSString*)empMail{
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:empMail];
//    
//    LCLLoadingView * indicatorView = [[[LCLLoadingView alloc]init]autorelease];
//    [[LCLLoadingView currentIndicator] setCenterMessage:@"复制成功"];
//    [[LCLLoadingView currentIndicator]  showSpinner];
//    [[LCLLoadingView currentIndicator]  show];
}

- (void) presentSheet
{
    //    NSString *title_str=[NSString stringWithFormat:@"联系人:“%@”",emp.emp_name];
    
    if (IOS8_OR_LATER && IS_IPHONE) {
        
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:emp.emp_mobile message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *callAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"personinfo_call"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //            拨打电话
            [[self class] callNumber:emp.emp_mobile];
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *sendMsgAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"personinfo_message"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //            发送消息
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",emp.emp_mobile]]];
            [alertCtl dismissViewControllerAnimated:YES completion:nil];

        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertCtl addAction:callAction];
        [alertCtl addAction:sendMsgAction];
        [alertCtl addAction:cancelAction];
        
        [UIAdapterUtil presentVC:alertCtl];
//        [self presentViewController:alertCtl animated:YES completion:nil];
        
    }else {
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle: emp.emp_mobile
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString:@"personinfo_call"],[StringUtil getLocalizableString:@"personinfo_message"], nil];
        [menu showInView:self.view];
    }
}

#pragma mark 添加新的联系人
-(void)addNewContact
{
    ABNewPersonViewController *picker = [[[ABNewPersonViewController alloc] init]autorelease] ;
    picker.newPersonViewDelegate = self;
    
    //创建新的person
    ABRecordRef person= ABPersonCreate();
    UIImage *img=[ImageUtil getOnlineEmpLogo:self.emp];
    //通讯录头像
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    
    NSString *firstName = emp.emp_name;
    
    // 电话号码数组以及对应的名称  emp.emp_mobile emp.emp_tel emp.emp_hometel emp.emp_emergencytel
    NSArray *phones = [NSArray arrayWithObjects:emp.emp_mobile,emp.emp_tel,nil];
    NSArray *labels = [NSArray arrayWithObjects:@"手机",@"办公",nil];
    
    //邮箱
    NSString *mailStr = emp.emp_mail;
    NSString *mailLab = @"邮箱";
    
    //职务
    NSString *jobName = emp.titleName;
    
    if (![UIAdapterUtil isTAIHEApp]) {
        
        //工号
        NSString *jobID = emp.empCode;
        //部门
        NSString *department =emp.deptName;
        
        //部门
        ABRecordSetValue(person, kABPersonDepartmentProperty,(CFStringRef)department, NULL);
        //公司
        ABRecordSetValue(person, kABPersonOrganizationProperty,(CFStringRef)jobID, NULL);
    }
  
    //设置头像
    ABPersonSetImageData(person, (CFDataRef)data , NULL);
    //职务
    ABRecordSetValue(person, kABPersonJobTitleProperty,(CFStringRef)jobName, NULL);
    
    // 保存到联系人对象中，每个属性都对应一个宏，例如：kABPersonFirstNameProperty kABPersonNicknameProperty;
    
    
    // 设置LastName属性  姓氏
    ABRecordSetValue(person, kABPersonLastNameProperty,(CFStringRef)firstName, NULL);
    
    // 设置birthday属性
    
    // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
    ABMultiValueRef mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加电话号码与其对应的名称内容
    for (int i = 0; i < [phones count]; i ++) {
        ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv,(CFStringRef)[phones objectAtIndex:i], (CFStringRef)[labels objectAtIndex:i], &mi);
    }
    
    // 设置phone属性
    ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
    
    // 释放该数组
    if (mv) {
        CFRelease(mv);
    }
    
    //设置邮箱
    ABMultiValueRef mailvm =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加邮箱与其对应的名称内容
    ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mailvm,(CFStringRef)mailStr, (CFStringRef)mailLab, &mi);
    ABRecordSetValue(person, kABPersonEmailProperty, mailvm, NULL);
    CFRelease(mailvm);
    
    picker.displayedPerson = person;
    UINavigationController *navigationController = [[[UINavigationController alloc]                                                                 initWithRootViewController:picker]autorelease];
    [UIAdapterUtil presentVC:navigationController];;
    //    [self.navigationController presentModalViewController:navigationController animated:YES];
    //    [self.navigationController presentModalViewController:picker animated:YES];
    
    //    [picker release];
    //    [navigationController release];
    CFRelease(person);
}

#pragma mark 发送邮件
-(void)displayMailPicker
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    
    mailViewController.mailComposeDelegate = self;
    [mailViewController setToRecipients:[NSArray arrayWithObject:self.emp.emp_mail]];
   // self.navigationItem.backBarButtonItem = [[[UIBarButtonItemalloc]initWithTitle:@""style:UIBarButtonSystemItemDonetarget:nilaction:nil]autorelease];
    mailViewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [UIAdapterUtil presentVC:mailViewController];
//    [self.navigationController presentModalViewController:mailViewController animated:YES];

    [mailViewController release];
}

-(void)afterGranted
{
    return;
    BOOL is = NO;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person;
    // 获取通讯录中所有的联系人
    NSArray *array = (NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并修改指定的联系人
    for (id obj in array) {
        person = (ABRecordRef)obj;
        
        ABMultiValueRef mv = ABRecordCopyValue(person,kABPersonPhoneProperty);
        NSArray *phones = (NSArray*)ABMultiValueCopyArrayOfAllValues(mv);
        // 由于获得到的电话号码不符合标准，所以要先将其格式化再比较是否存在
        
        for (NSString *p in phones) {
            //红色代码处，我添加了一个类别（给NSString扩展了一个方法），该类别的这个方法主要是用于将电话号码中的"("、")"、""、"-"过滤掉
            if ([p isEqualToString:emp.emp_mobile]) {
                is = YES;
                break;
            }
        }
        
        if (is) {
            
            break;
        }
    }
    
    if (!is) {
        person = ABPersonCreate();
    }
    
    
    // 新建一个联系人
    // ABRecordRef是一个属性的集合，相当于通讯录中联系人的对象
    // 联系人对象的属性分为两种：
    // 只拥有唯一值的属性和多值的属性。
    // 唯一值的属性包括：姓氏、名字、生日等。
    // 多值的属性包括:电话号码、邮箱等。
    
    
    UIImage *img=personImageView.image;
    //通讯录头像
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    
    NSString *firstName = emp.emp_name;
    NSString *lastName = @" ";
    //工号
    NSString *jobID = emp.empCode;
    
    // 电话号码数组以及对应的名称  emp.emp_mobile emp.emp_tel emp.emp_hometel emp.emp_emergencytel
    NSArray *phones = [NSArray arrayWithObjects:emp.emp_mobile,emp.emp_tel,nil];
    NSArray *labels = [NSArray arrayWithObjects:@"手机",@"办公",nil];
    
    //邮箱
    NSString *mailStr = emp.emp_mail;
    NSString *mailLab = @"邮箱";
    
    //职务
    NSString *jobName = emp.titleName;
    //部门
    NSString *department =emp.deptName;
    
    
    //设置头像
    ABPersonSetImageData(person, (CFDataRef)data , NULL);
    //职务
    ABRecordSetValue(person, kABPersonJobTitleProperty,(CFStringRef)jobName, NULL);
    //部门
    ABRecordSetValue(person, kABPersonDepartmentProperty,(CFStringRef)department, NULL);
    //公司
    ABRecordSetValue(person, kABPersonOrganizationProperty,(CFStringRef)jobID, NULL);
    
    // 保存到联系人对象中，每个属性都对应一个宏，例如：kABPersonFirstNameProperty
    // 设置firstName属性
    ABRecordSetValue(person, kABPersonFirstNameProperty,(CFStringRef)firstName, NULL);
    // 设置lastName属性
    ABRecordSetValue(person, kABPersonLastNameProperty, (CFStringRef)lastName, NULL);
    // 设置birthday属性
    
    // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
    ABMultiValueRef mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加电话号码与其对应的名称内容
    for (int i = 0; i < [phones count]; i ++) {
        ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv,(CFStringRef)[phones objectAtIndex:i], (CFStringRef)[labels objectAtIndex:i], &mi);
    }
    
    // 设置phone属性
    ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
    
    // 释放该数组
    if (mv) {
        CFRelease(mv);
    }
    
    //设置邮箱
    ABMultiValueRef mailvm =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加邮箱与其对应的名称内容
    ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mailvm,(CFStringRef)mailStr, (CFStringRef)mailLab, &mi);
    ABRecordSetValue(person, kABPersonEmailProperty, mailvm, NULL);
    if (mailvm) {
        CFRelease(mailvm);
    }
    
//     ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init] ;                       picker.newPersonViewDelegate = self;
//    
//    ABRecordSetValue(person, kABPersonFirstNameProperty,(CFStringRef)firstName, NULL);
//    picker.displayedPerson = person;                                  UINavigationController *navigationController = [[UINavigationController alloc]                                                                 initWithRootViewController:picker];
//    [self.navigationController presentModalViewController:navigationController animated:YES];
//    [picker release];
//    [navigationController release];
    
//    if (!is) {
//        // 将新建的联系人添加到通讯录中
//        ABAddressBookAddRecord(addressBook, person, NULL);
//    }
//    // 保存通讯录数据
//    ABAddressBookSave(addressBook, NULL);
    
    CFRelease(person);
    CFRelease(addressBook);
}
#pragma mark - 插入某条通讯录
- (void)insertOneRecord{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 && ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
    {
        [self showCanNotAccessContacts];
    }
    else
    {
        [self insertAddressBook_start];
//        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"personinfo_saving_user_info"]];
//        [[LCLLoadingView currentIndicator]showSpinner];
//        [[LCLLoadingView currentIndicator]show];
//        [self performSelector:@selector(insertAddressBook_start) withObject:nil afterDelay:0.5];
    }
}

-(BOOL)checkIsRepeatPerson{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s name is %@ empcode is %@ tel is %@ mobile is %@",__FUNCTION__,self.emp.emp_name,self.emp.empCode,self.emp.emp_tel,self.emp.emp_mobile]];
    
    repeatPersonId = nil;
    
    BOOL is = NO;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person;
    // 获取通讯录中所有的联系人
    NSArray *array = (NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并修改指定的联系人
    //
    BOOL isFind = NO;
    for (id obj in array) {
        person = (ABRecordRef)obj;
        repeatPersonId =  ABRecordGetRecordID (person);
        
        CFStringRef empCodeRef = ABRecordCopyValue(person, kABPersonOrganizationProperty);
        NSString *empCodeStr = (NSString *)empCodeRef;
        if (![UIAdapterUtil isHongHuApp]) {
            
            if (empCodeStr.length) {
                //            匹配工号是否相同
                if ([empCodeStr compare:self.emp.empCode] == NSOrderedSame) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s 找到工号相同的记录",__FUNCTION__]];
                    isFind = YES;
                    break;
                }
            }
            CFStringRef empNameRef = ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSString *empNameStr = (NSString *)empNameRef;
            if (empNameStr.length) {
                if ([empNameStr compare:self.emp.emp_name] == NSOrderedSame) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s 找到名字相同的记录",__FUNCTION__]];
                    isFind = YES;
                    break;
                }
            }
            
        }
        ABMultiValueRef mv = ABRecordCopyValue(person,kABPersonPhoneProperty);
        NSArray *phones = (NSArray*)ABMultiValueCopyArrayOfAllValues(mv);
        // 由于获得到的电话号码不符合标准，所以要先将其格式化再比较是否存在
        
        for (NSString *p in phones) {
            //红色代码处，我添加了一个类别（给NSString扩展了一个方法），该类别的这个方法主要是用于将电话号码中的"("、")"、""、"-"过滤掉
            //                if (self.emp.emp_mobile) {
            //
            //                }
            if (emp.emp_mobile.length) {
                NSString *strNum = [p stringByReplacingOccurrencesOfString:@" " withString:@""];
                strNum = [strNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
                if ([strNum isEqualToString:emp.emp_mobile]) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s 找到手机号码相同的记录",__FUNCTION__]];
                    isFind = YES;
                    break;
                }
            }
            if (![UIAdapterUtil isHongHuApp]) {
                if (emp.emp_tel.length)
                {
                    if ([p isEqualToString:emp.emp_tel]) {
                        [LogUtil debug:[NSString stringWithFormat:@"%s 找到电话号码相同的记录",__FUNCTION__]];
                        isFind = YES;
                        break;
                    }
                }
            }
        }
        
    }
    
    if (!isFind) {
        repeatPersonId = nil;
    }
    CFRelease(array);
    CFRelease(addressBook);
    
    return isFind;
}

-(void)insertAddressBook_start
{
    
    BOOL is = YES;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person;
    
    if (repeatPersonId) {
        person = ABAddressBookGetPersonWithRecordID (addressBook, repeatPersonId);
    }
    if (!person) {
        person = ABPersonCreate();
        is = NO;
    }
    //    ABAddressBookRef addressBook = ABAddressBookCreate();
    //    ABRecordRef person;
    //    // 获取通讯录中所有的联系人
    //    NSArray *array = (NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    //    // 遍历所有的联系人并修改指定的联系人
    //    for (id obj in array) {
    //        person = (ABRecordRef)obj;
    //
    //        ABMultiValueRef mv = ABRecordCopyValue(person,kABPersonPhoneProperty);
    //        NSArray *phones = (NSArray*)ABMultiValueCopyArrayOfAllValues(mv);
    //        // 由于获得到的电话号码不符合标准，所以要先将其格式化再比较是否存在
    //
    //        for (NSString *p in phones) {
    //            //红色代码处，我添加了一个类别（给NSString扩展了一个方法），该类别的这个方法主要是用于将电话号码中的"("、")"、""、"-"过滤掉
    //            if ([p isEqualToString:emp.emp_mobile]) {
    //                is = YES;
    //                break;
    //            }
    //        }
    //
    //        if (is) {
    //
    //            break;
    //        }
    //    }
    //
    //    if (!is) {
    //        person = ABPersonCreate();
    //    }
    
    
    // 新建一个联系人
    // ABRecordRef是一个属性的集合，相当于通讯录中联系人的对象
    // 联系人对象的属性分为两种：
    // 只拥有唯一值的属性和多值的属性。
    // 唯一值的属性包括：姓氏、名字、生日等。
    // 多值的属性包括:电话号码、邮箱等。
    
    UIImage *img=[ImageUtil getOnlineEmpLogo:self.emp];
    //    UIImage *img= personImageView.image;
    //通讯录头像
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    
    NSString *firstName = emp.emp_name;
    //工号
    NSString *jobID = emp.empCode;
    
    // 电话号码数组以及对应的名称  emp.emp_mobile emp.emp_tel emp.emp_hometel emp.emp_emergencytel
    NSArray *phones = [NSArray arrayWithObjects:emp.emp_mobile,emp.emp_tel,nil];
    NSArray *labels = [NSArray arrayWithObjects:@"手机",@"办公",nil];
    
    //邮箱
    NSString *mailStr = emp.emp_mail;
    NSString *mailLab = @"邮箱";
    
    //职务
    NSString *jobName = emp.titleName;
    //部门
    NSString *department =emp.deptName;
    
    
    //设置头像
    ABPersonSetImageData(person, (CFDataRef)data , NULL);
    //职务
    ABRecordSetValue(person, kABPersonJobTitleProperty,(CFStringRef)jobName, NULL);
    //部门
    ABRecordSetValue(person, kABPersonDepartmentProperty,(CFStringRef)department, NULL);
    //公司
    ABRecordSetValue(person, kABPersonOrganizationProperty,(CFStringRef)jobID, NULL);
    
    // 保存到联系人对象中，每个属性都对应一个宏，例如：kABPersonFirstNameProperty
    // 设置firstName属性
    //    ABRecordSetValue(person, kABPersonFirstNameProperty,(CFStringRef)firstName, NULL);
    // 设置lastName属性
    ABRecordSetValue(person, kABPersonLastNameProperty, (CFStringRef)firstName, NULL);
    // 设置birthday属性
    
    // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
    ABMultiValueRef mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加电话号码与其对应的名称内容
    for (int i = 0; i < [phones count]; i ++) {
        ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv,(CFStringRef)[phones objectAtIndex:i], (CFStringRef)[labels objectAtIndex:i], &mi);
    }
    
    // 设置phone属性
    ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
    
    // 释放该数组
    if (mv) {
        CFRelease(mv);
    }
    
    //设置邮箱
    ABMultiValueRef mailvm =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加邮箱与其对应的名称内容
    ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mailvm,(CFStringRef)mailStr, (CFStringRef)mailLab, &mi);
    ABRecordSetValue(person, kABPersonEmailProperty, mailvm, NULL);
    if (mailvm) {
        CFRelease(mailvm);
    }
    
    if (!is) {
        // 将新建的联系人添加到通讯录中
        ABAddressBookAddRecord(addressBook, person, NULL);
        CFRelease(person);
    }
    // 保存通讯录数据
    ABAddressBookSave(addressBook, NULL);
    CFRelease(addressBook);
    
    //    if (addressBook) {
    //        CFRelease(addressBook);
    //    }
    
    //    [UserTipsUtil hideLoadingView];
    [self performSelectorOnMainThread:@selector(showTip) withObject:nil waitUntilDone:YES];
    //    [self performSelector:@selector(showTip) withObject:nil afterDelay:1];
}
-(void)showTip
{
    [UserTipsUtil showForwardTips:[StringUtil getLocalizableString:@"personinfo_save_success"]];
//
//    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"personinfo_save_success"]];
    
    [self performSelector:@selector(dissmisLabel) withObject:nil afterDelay:1];
}
-(void)dissmisLabel
{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
}
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    [[actionSheet layer] setBackgroundColor:[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1].CGColor];
    
}
-(void)phoneActon:(id)sender
{
    //    NSLog(@"-----phoneActon");
    UIButton *button=(UIButton *)sender;
	int talkNum=[button.titleLabel.text intValue];
    //	NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",emp.emp_mobile];
    //	NSString *num = [[NSString alloc] initWithFormat:@"telprompt://%@",emp.emp_mobile];
    //	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    NSURL *phoneURL;
	if (talkNum==1) { //手机call
        phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",emp.emp_mobile]];
    }else if (talkNum==2)
    {//电话
        phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",emp.emp_tel]];
    }
    else if (talkNum==3)
    {//电话
        phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.emp.emp_hometel]];
    }
    else if (talkNum==4)
    {//电话
        phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.emp.emp_emergencytel]];
    }
	UIWebView *phoneCallWebView = [[[UIWebView alloc] initWithFrame:CGRectZero]autorelease];// 这个webView只是一个后台的容易 不需要add到页面上来  效果跟方法二一样 但是这个方法是合法的
	[phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
}

-(void)boxActon:(id)sender
{
    NSLog(@"-----boxActon----%@",emp.emp_mobile);
	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",emp.emp_mobile]]];
}

#pragma mark - FGalleryViewControllerDelegate Methods
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
	return 1;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeLocal;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption;
    if( gallery == localGallery ) {
        caption = @"112 ";
    }
    else if( gallery == networkGallery ) {
        caption =@"343";
    }
	return @" ";
}
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return self.preImageFullPath;
}
- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return nil;
}
- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}
- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}


-(void)handleCmd:(NSNotification *)notification
{
    [UserTipsUtil hideLoadingView];
	eCloudNotification *_notification = [notification object];
	if(_notification != nil)
	{
		int cmdId = _notification.cmdId;
		switch (cmdId) {
			case get_user_info_success_new:
			{
				NSLog(@"get user info success new");
                
				NSString* empId = [_notification.info objectForKey:@"EMP_ID"];
                if (empId.intValue == self.emp.emp_id)
                {
                    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
                    Emp *_emp = [_ecloud getEmpInfo:empId];
                    self.emp = _emp;
                    [self refreshData];
                }
  			}
				break;
			case get_user_info_timeout_new:
			{
				NSLog(@"get user info timeout new ");
				
                [self showAlert:[StringUtil getLocalizableString:@"personinfo_get_user_info_timeout"]];
 			}
				break;
                
			case get_user_info_failure_new:
			{
				NSLog(@"get user info failure new ");
                [self showAlert:[StringUtil getLocalizableString:@"personinfo_get_user_info_fail"]];
			}
				break;
            case update_user_data_success:
//                [userDataDAO addOneCommonEmp:self.emp.emp_id andIsDefault:NO];
//                [self showAlert:[NSString stringWithFormat:[StringUtil getLocalizableString:@"personinfo_get_add_someone_as_common_emp_success"],self.emp.emp_name]];
                if ([userDataDAO isCommonEmp:self.emp.emp_id])
                {
                    [userDataDAO removeCommonEmp:self.emp.emp_id];
                    
                    [self showAlert:[NSString stringWithFormat:[StringUtil getLocalizableString:@"personinfo_remove_someone_from_common_emp"],self.emp.emp_name] autoDimiss:YES];
                }
                else
                {
                    [userDataDAO addCommonEmp:[NSArray arrayWithObject:[NSNumber numberWithInt:self.emp.emp_id]] andIsDefault:NO];
                    
                    [self showAlert:[NSString stringWithFormat:[StringUtil getLocalizableString:@"personinfo_get_add_someone_as_common_emp_success"],self.emp.emp_name] autoDimiss:YES];
                }
                [personTable reloadData];
                
                eCloudNotification *_notification = [[[eCloudNotification alloc]init]autorelease];
                _notification.cmdId = refresh_org;
                [[NSNotificationCenter defaultCenter] postNotificationName:ORG_NOTIFICATION object:_notification];
                
                break;
            case update_user_data_fail:
                [self showAlert:[StringUtil getLocalizableString:@"personinfo_get_add_someone_as_common_emp_fail"] autoDimiss:YES];
                break;
            case update_user_data_timeout:
                [self showAlert:[StringUtil getLocalizableString:@"personinfo_get_add_someone_as_common_emp_timeout"] autoDimiss:YES];
                break;
			default:
				break;
		}
	}
}

- (void)showAlert:(NSString *)message
{
    [UserTipsUtil showAlert:message];
}

- (void)showAlert:(NSString *)message autoDimiss:(BOOL)autoDimiss
{
    [UserTipsUtil showAlert:message autoDimiss:autoDimiss];
}

+ (void)callNumber:(NSString *)number
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    if (phoneCallWebView == nil) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    //    phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];  这个webView只是一个后台的容易 不需要add到页面上来  效果跟方法二一样 但是这个方法是合法的
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
}


- (void)callHomeNumber:(NSString *)number
{
    NSMutableString *numberStr = [StringUtil trimString:number];
    numberStr = [numberStr stringByReplacingOccurrencesOfString:@"," withString:@" "];
    numberStr = [numberStr stringByReplacingOccurrencesOfString:@";" withString:@" "];
    numberStr = [numberStr stringByReplacingOccurrencesOfString:@"，" withString:@" "];
    numberStr = [numberStr stringByReplacingOccurrencesOfString:@"；" withString:@" "];
    NSLog(@"%@",numberStr);
    
    int numberLen = [numberStr length];
    int i=0;
    self.numberStr1 = @"";
    for (i; i<numberLen; i++) {
        NSString *numberChar = [numberStr substringWithRange:NSMakeRange(i, 1)];
        if ([personInfoViewController isPureInt:numberChar])
        {
            self.numberStr1 = [NSString stringWithFormat:@"%@%@",self.numberStr1,numberChar];
        }else
            break;
    }
    
    numberStr = [numberStr substringWithRange:NSMakeRange(i, (numberStr.length-i))];
    numberStr = [StringUtil trimString:numberStr];
    self.numberStr2 = @"";
    for (int j=0; j<numberStr.length; j++) {
        NSString *numberChar = [numberStr substringWithRange:NSMakeRange(j, 1)];
        if ([personInfoViewController isPureInt:numberChar]) {
            self.numberStr2 = [NSString stringWithFormat:@"%@%@",self.numberStr2,numberChar];
        }else
        {
            break;
        }
    }
    
    if(self.numberStr2.length == 0){
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.numberStr1]];
        if (phoneCallWebView == nil) {
            phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        }
        //    phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];  这个webView只是一个后台的容易 不需要add到页面上来  效果跟方法二一样 但是这个方法是合法的
        [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    }else
    {
        [self presentHomeTelSheet:self.numberStr1 and:self.numberStr2];
    }
    
}

- (void) presentHomeTelSheet:(NSString *)numberStr1 and:(NSString *)numberStr2
{
    //    NSString *title_str=[NSString stringWithFormat:@"联系人:“%@”",emp.emp_name];
    if (IOS8_OR_LATER && IS_IPHONE) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:emp.emp_name message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *number1Action = [UIAlertAction actionWithTitle:self.numberStr1 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [personInfoViewController callNumber:self.numberStr1];
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *number2Action = [UIAlertAction actionWithTitle:self.numberStr2 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [personInfoViewController callNumber:self.numberStr2];
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:number1Action];
        [alert addAction:number2Action];
        [alert addAction:cancelAction];
        
        [UIAdapterUtil presentVC:alert];
//        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle: emp.emp_name
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:self.numberStr1,self.numberStr2,nil];
        menu.tag = 102;
        [menu showInView:self.view];
    }
}

//+ (BOOL)isNumText:(NSString *)str{
//    NSString * regex        = @"(/^[0-9]*$/)";
//    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    BOOL isMatch            = [pred evaluateWithObject:str];
//    if (isMatch) {
//        return YES;
//    }else{
//        return NO;
//    }
//    
//}

+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return([scan scanInt:&val] && [scan isAtEnd])||[string isEqualToString:@"-"]||[string isEqualToString:@"+"];
}

- (void)showCanNotAccessContacts
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"personinfo_contact_permission"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}


- (float)getRobotUserCellHeightOfIndexpath:(NSIndexPath *)indexPath
{
    float height = row_height;
    switch (indexPath.row) {
            //                介绍 放在 地址这个数学里
        case 0:
            height = addCellSize.height;
            break;
            //                座机
        case 1:
            height = homeNumCellSize.height;
            break;
            //                手机
        case 2:
            break;
            //                传真
        case 3:
            break;
            //                邮箱
        case 4:
            height = emailCellSize.height;
            break;
        default:
            break;
    }
    
    return height;
}

- (void)configRobotUserCellOfIndexPath:(NSIndexPath *)indexPath andCell:(UITableViewCell *)cell
{
    UILabel *tipLabel=(UILabel *)[cell viewWithTag:1];
    UILabel *tipDetailLabel=(UILabel *)[cell viewWithTag:2];
    UIImageView *rightView = (UIImageView *)[cell viewWithTag:3];
    tipDetailLabel.textColor=[UIColor blackColor];
    
    switch (indexPath.row) {
            //                介绍 放在 地址这个数学里
        case 0:
        {
            tipLabel.text=[StringUtil getLocalizableString:@"personInfo_introduce"];
            tipDetailLabel.text = self.emp.empAddress;
            CGRect _frame = tipDetailLabel.frame;
            _frame.size = addCellSize;
            _frame.origin.y = 0;
            tipDetailLabel.frame = _frame;
            
        }
            break;
            //                座机
        case 1:
        {
            tipLabel.text=[StringUtil getLocalizableString:@"personInfo_home_tel"];
            tipDetailLabel.text = self.emp.emp_tel;
            
            if(emp.emp_tel && emp.emp_tel.length > 0)
            {
                [rightView setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"homeTel" andType:@"png"]]];
                tipDetailLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
                
                CGRect _frame = tipDetailLabel.frame;
                _frame.size = homeNumCellSize;
                _frame.origin.y = 0;
                tipDetailLabel.frame = _frame;
                cell.selectionStyle = UITableViewCellSelectionStyleGray ;
            }
        }
            break;
            //                手机
        case 2:
        {
            tipLabel.text=[StringUtil getLocalizableString:@"personInfo_mobile"];
            tipDetailLabel.text=self.emp.emp_mobile;
            
            if(emp.emp_mobile && emp.emp_mobile.length > 0)
            {
                [rightView setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"mobile" andType:@"png"]]];
                
                UIImageView *smView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width-80,(row_height-btnIconWidth)*0.5, btnIconWidth, btnIconWidth)];
                [smView setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"shortMsg" andType:@"png"]]];
                [cell addSubview:smView];
                [smView release];
                
                tipDetailLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
                cell.selectionStyle = UITableViewCellSelectionStyleGray ;
            }
        }
            break;
            //                传真
        case 3:
        {
            if ([UIAdapterUtil isTAIHEApp]) {
                
                tipLabel.text=[StringUtil getLocalizableString:@"userInfo_duty"];
                tipDetailLabel.text=self.emp.signature;
            }else{
                
                tipLabel.text=[StringUtil getLocalizableString:@"personInfo_Fax"];
                tipDetailLabel.text=self.emp.empFax;
            }
            
        }
            break;
            //                邮箱
        case 4:
        {
            tipLabel.text=[StringUtil getLocalizableString:@"personInfo_Email"];
            tipDetailLabel.text=self.emp.emp_mail;
            
            CGRect _frame = tipDetailLabel.frame;
            _frame.size = emailCellSize;
            _frame.origin.y = 0;
            tipDetailLabel.frame = _frame;
        }
            break;
        default:
            break;
    }
}

- (void)configRobotUserDidSelectRowOfIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            //                介绍 放在 地址这个数学里
        case 0:
            break;
            //                座机
        case 1:
            //座机
            if(emp.emp_tel && emp.emp_tel.length)
            {
                [self callHomeNumber:emp.emp_tel];
            }
            break;
            //                手机
        case 2:
            //手机
            if(emp.emp_mobile && emp.emp_mobile.length > 0)
            {
                [self presentSheet];
            }
            break;
            //                传真
        case 3:
            break;
            //                邮箱
        case 4:
            break;
        default:
            break;
    }
}

#pragma mark ========准备设置项数组=========
- (void)prepareTAIHESettingItems{
    
    settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    
    if (self.emp.isAppNoticeAccount || self.emp.emp_id == file_id) {
        //系统服务号介绍
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_introduce"];
        _item.itemValue = self.emp.empAddress;
        _item.detailValueSize = addCellSize;
        [settingItemArray addObject:_item];
        [_item release];
    }else{
        //    电话
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_home_tel"];
        _item.itemValue = self.emp.emp_tel;
        _item.detailValueSize = homeNumCellSize;
        if (self.emp.emp_tel.length > 0) {
            _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
            _item.selectionStyle = UITableViewCellSelectionStyleGray;
            
            _item.customCellSelector = @selector(customTel:);
            _item.clickSelector = @selector(clickTel);
        }
        [settingItemArray addObject:_item];
        [_item release];
        
        //    手机
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_mobile"];
        _item.itemValue = self.emp.emp_mobile;
        if (self.emp.emp_mobile.length > 0) {
            _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
            _item.selectionStyle = UITableViewCellSelectionStyleGray;
            _item.customCellSelector = @selector(customMobile:);
            _item.clickSelector = @selector(presentSheet);
        }
        [settingItemArray addObject:_item];
        [_item release];
        
        //    邮箱
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_Email"];
        _item.itemValue = self.emp.emp_mail;
        _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
        _item.detailValueSize = emailCellSize;
        _item.clickSelector = @selector(presentMailSheet);
        [settingItemArray addObject:_item];
        [_item release];
        
        //    职务
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_position"];
        _item.itemValue = self.emp.titleName;
        _item.detailValueSize = postCellSize;
        [settingItemArray addObject:_item];
        [_item release];
        
        //    部门
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_department"];
        _item.itemValue = self.emp.deptName;
        _item.detailValueSize = deptSize;
        [settingItemArray addObject:_item];
        [_item release];
        
        //工作职责
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"userInfo_work_duty"];
        _item.itemValue = self.emp.signature;
        _item.clickSelector = @selector(presentMailSheet);
        [settingItemArray addObject:_item];
        [_item release];
        
        //    地址
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"userInfo_address_and_zip_code"];
        _item.itemValue = self.emp.empAddress;
        _item.detailValueSize = addCellSize;
        _item.clickSelector = @selector(presentMailSheet);
        [settingItemArray addObject:_item];
        [_item release];
        
    }
}

- (void)prepareXIANGYUANItems
{
    settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    
    //    如果是南航那么需要把工号显示在这里 签名显示在上面
    if ([UIAdapterUtil isCsairApp]) {
        //        工号
        //    职务
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_employee_id"];
        _item.itemValue = self.emp.empCode;
        [settingItemArray addObject:_item];
        [_item release];
    }
    
    
    if (isRobot) {
        //        机器人介绍
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_introduce"];
        _item.itemValue = self.emp.empAddress;
        _item.detailValueSize = addCellSize;
        [settingItemArray addObject:_item];
        [_item release];
    }else{
        //    职务
        if (self.emp.titleName.length) {
            
            eCloudDAO *_ecloud = [eCloudDAO getDatabase];
            NSString *titleName = [self.emp.titleName substringToIndex:[self.emp.titleName length] - 1];
            NSArray *tempArr=[titleName componentsSeparatedByString:@";"];
            NSMutableString *nameStr = [NSMutableString string];
            self.locationArr = [NSMutableArray array];
            self.lengthArr = [NSMutableArray array];
            for (int i = 0; i < tempArr.count; i++) {
                
                NSString *string = tempArr[i];
                NSArray *arr = [string componentsSeparatedByString:@":"];
                if (arr.count == 2) {
                    
                    NSDictionary *dic = [_ecloud searchDept:[NSString stringWithFormat:@"%@",arr[1]]];
                    NSString *deptParent = [dic valueForKey:@"dept_name_contain_parent"];
//                    if (tempArr.count >2) {
//                        
//                        deptParent = [NSString stringWithFormat:@"%@\n",deptParent];
//                    }
                    if (i == 0) {
                        
                        NSString *str = [NSString stringWithFormat:@"%@\r%@\r",arr[0],deptParent];
                        [nameStr appendFormat:@"%@", str];
                        
                    }else if(i == tempArr.count){
                        
                        [nameStr appendFormat:@"\r%@\r%@",arr[0],deptParent];
                    }else{
                        
                        [nameStr appendFormat:@"\r%@\r%@\r",arr[0],deptParent];
                    }
                    NSRange range;
                    
                    range = [nameStr rangeOfString:arr[0]];
                    
                    if (range.location != NSNotFound) {
                        
                        [self.locationArr addObject:[NSString stringWithFormat:@"%lu",range.location]];
                        [self.lengthArr addObject:[NSString stringWithFormat:@"%lu",range.length]];
                    }
                    
                }
            }

            self.emp.titleName = nameStr;
        }
        
        
        postCellSize = [self configCellSize:self.emp.titleName];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_position"];
        _item.itemValue = self.emp.titleName;
        _item.detailValueSize = postCellSize;
        [settingItemArray addObject:_item];
        [_item release];
        
        //    部门
//        _item = [[SettingItem alloc]init];
//        _item.itemName = [StringUtil getLocalizableString:@"personInfo_department"];
//        _item.itemValue = self.emp.deptName;
//        _item.detailValueSize = deptSize;
//        [settingItemArray addObject:_item];
//        [_item release];
        
        //    电话
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_home_tel"];
        _item.itemValue = self.emp.emp_tel;
        _item.detailValueSize = homeNumCellSize;
        if (self.emp.emp_tel.length > 0) {
            _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
            _item.selectionStyle = UITableViewCellSelectionStyleGray;
            
            _item.customCellSelector = @selector(customTel:);
            _item.clickSelector = @selector(clickTel);
        }
        [settingItemArray addObject:_item];
        [_item release];
        
        
        //    手机
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_mobile"];
        _item.itemValue = self.emp.emp_mobile;
#if defined(_XIANGYUAN_FLAG_) || defined(_ZHENGRONG_FLAG_)
        if (self.emp.emp_mobile.length)
        {
            BOOL canShow = [StringUtil canShowPhoneNumber:self.emp.emp_id];
            _item.itemValue =  canShow ? self.emp.emp_mobile : @"********";
        }
#endif
        
        if (self.emp.emp_mobile.length > 0) {
            _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
            _item.selectionStyle = UITableViewCellSelectionStyleGray;
            _item.customCellSelector = @selector(customMobile:);
            _item.clickSelector = @selector(presentSheet);
        }
        [settingItemArray addObject:_item];
        [_item release];
        
        //    传真  泰禾需求，传真改为职责
        if ([UIAdapterUtil isTAIHEApp]) {
            
            _item = [[SettingItem alloc]init];
            _item.itemName = [StringUtil getLocalizableString:@"userInfo_duty"];
            _item.itemValue = self.emp.signature;
            [settingItemArray addObject:_item];
            [_item release];
            
        }else{
            
            _item = [[SettingItem alloc]init];
            _item.itemName = [StringUtil getLocalizableString:@"personInfo_Fax"];
            _item.itemValue = self.emp.empFax;
            [settingItemArray addObject:_item];
            [_item release];
        }
        
        //    邮箱
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_Email"];
        _item.itemValue = self.emp.emp_mail;
        _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
        _item.detailValueSize = emailCellSize;
        _item.clickSelector = @selector(presentMailSheet);
        [settingItemArray addObject:_item];
        [_item release];
        
        //    地址
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_address"];
        _item.itemValue = self.emp.empAddress;
        _item.detailValueSize = addCellSize;
        [settingItemArray addObject:_item];
        [_item release];
    }

}
#pragma mark ========准备设置项数组=========
- (void)prepareSettingItems
{
    settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    
    if (isRobot) {
        
        NSMutableArray *arr1 = [NSMutableArray array];
        //    登录用户资料
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@""];
        //    _item.clickSelector = @selector(openUserInfo);
        [arr1 addObject:_item];
        [_item release];
        
//        机器人介绍
        NSMutableArray *arr2 = [NSMutableArray array];
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_introduce"];
        _item.itemValue = self.emp.empAddress;
        _item.detailValueSize = addCellSize;
        [arr2 addObject:_item];
        [_item release];
        
        [settingItemArray addObject:arr1];
        [settingItemArray addObject:arr2];
        
    }else{
        
        NSMutableArray *arr1 = [NSMutableArray array];
        //    登录用户资料
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@""];
        //    _item.clickSelector = @selector(openUserInfo);
        [arr1 addObject:_item];
        [_item release];
        
        NSMutableArray *arr2 = [NSMutableArray array];
        if (self.emp.titleName.length) {
            
        //    职务
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_position"];
        _item.itemValue = self.emp.titleName;
        _item.detailValueSize = postCellSize;
        [arr2 addObject:_item];
        [_item release];
            
        }
        
        if (self.emp.deptName.length) {
            //    部门
            _item = [[SettingItem alloc]init];
            _item.itemName = [StringUtil getLocalizableString:@"personInfo_department"];
            _item.itemValue = self.emp.deptName;
            _item.detailValueSize = deptSize;
            [arr2 addObject:_item];
            [_item release];
        }
        
        NSMutableArray *arr3 = [NSMutableArray array];
        
        if (self.emp.emp_mobile.length) {
        //    手机
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_mobile"];
        _item.itemValue = self.emp.emp_mobile;
        _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        _item.clickSelector = @selector(presentSheet);
        [arr3 addObject:_item];
        [_item release];
        }
        
        if (self.emp.emp_tel.length) {
        //    座机
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_home_tel"];
        _item.itemValue = self.emp.emp_tel;
        _item.detailValueSize = homeNumCellSize;
        _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        _item.customCellSelector = @selector(customTel:);
        _item.clickSelector = @selector(clickTel);
        [arr3 addObject:_item];
        [_item release];
        }
        
        if (self.emp.empFax.length) {
        //    传真
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_Fax"];
        _item.itemValue = self.emp.empFax;
        _item.clickSelector = @selector(modifyFax);
        _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
        [arr3 addObject:_item];
        [_item release];
        }
        
        if (self.emp.emp_mail.length) {

        //    邮箱
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_Email"];
        _item.itemValue = self.emp.emp_mail;
        _item.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor blueColor];
        _item.detailValueSize = emailCellSize;
        _item.clickSelector = @selector(presentMailSheet);
        [arr3 addObject:_item];
        [_item release];
        }
        
         if (self.emp.empAddress.length) {
        //    地址
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"personInfo_address"];
        _item.itemValue = self.emp.empAddress;
        _item.detailValueSize = addCellSize;
        [arr3 addObject:_item];
        [_item release];
         }
        [settingItemArray addObject:arr1];
        [settingItemArray addObject:arr2];
        [settingItemArray addObject:arr3];
    }
}

- (void)modifyFax{
    

}

// 电话号码
- (void)customTel:(UITableViewCell *)cell
{
    UIImageView *rightView = (UIImageView *)[cell viewWithTag:3];
    [rightView setImage:[StringUtil getImageByResName:@"homeTel.png"]];
}

- (void)clickTel
{
    [self callHomeNumber:emp.emp_tel];;
}
//手机号码
- (void)customMobile:(UITableViewCell *)cell
{
    UIImageView *rightView = (UIImageView *)[cell viewWithTag:3];
    [rightView setImage:[StringUtil getImageByResName:@"mobile.png"]];
    
    UIImageView *smView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80,(row_height-btnIconWidth)*0.5, btnIconWidth, btnIconWidth)];
    [smView setImage:[StringUtil getImageByResName:@"shortMsg.png"]];
    [cell addSubview:smView];
    [smView release];
    

}
- (SettingItem *)getSettingItemByIndexPath:(NSIndexPath *)indexPath
{

    int section=[indexPath section];
    int row = [indexPath row];
    
    NSArray *_array = [settingItemArray objectAtIndex:section];
    SettingItem *_item = [_array objectAtIndex:row];
    return _item;

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = personTable.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - BOTTOM_BAR_HEIGHT;
    personTable.frame = _frame;
    
    [personTable reloadData];
    
    _frame = bottomNavibar.frame;
    _frame.origin.y = personTable.frame.size.height;
    bottomNavibar.frame = _frame;
    
    _frame = sendMsgBtn.frame;
    _frame.size.width = (SCREEN_WIDTH - 40) * 0.5;
    sendMsgBtn.frame = _frame;
    
    _frame = sendLabel.frame;
    _frame.size.width = sendMsgBtn.frame.size.width - _frame.origin.x;
    sendLabel.frame = _frame;
    
    _frame = addPersonBtn.frame;
    _frame.size.width = sendMsgBtn.frame.size.width;
    _frame.origin.x = sendMsgBtn.frame.origin.x + sendMsgBtn.frame.size.width + 20;
    addPersonBtn.frame = _frame;
    
    _frame = addLabel.frame;
    _frame.size.width = addPersonBtn.frame.size.width - addLabel.frame.origin.x;
    addLabel.frame = _frame;
    
}


- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 添加新的联系人
- (void)addNewContactInIOS9
{
    //1.创建Contact对象，必须是可变的
    CNMutableContact *contact = [[[CNMutableContact alloc] init]autorelease];
    //2.为contact赋值，这块比较恶心，很混乱，setValue4Contact中会给出常用值的对应关系
    [self setValue4Contact:contact];
    //3.创建新建好友页面
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
    //代理内容根据自己需要实现
    controller.delegate = self;
    //4.跳转
    UINavigationController *navigation = [[[UINavigationController alloc] initWithRootViewController:controller]autorelease];
    navigation.navigationBar.tintColor =  [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
    [self presentViewController:navigation animated:YES completion:nil];
}

///设置要保存的contact对象
- (void)setValue4Contact:(CNMutableContact *)contact{
    //    名字
    contact.familyName = self.emp.emp_name;
    
    //通讯录头像
    UIImage *img=[ImageUtil getOnlineEmpLogo:self.emp];
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    contact.imageData = data;
    
    //  职位
    contact.jobTitle = self.emp.titleName;
    
    if (![UIAdapterUtil isTAIHEApp]) {
        
        //    部门
        contact.departmentName = self.emp.deptName;
        
        //工号
        contact.organizationName = self.emp.empCode;
    }
  
    //    手机 办公电话
    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:@"手机" value:[CNPhoneNumber phoneNumberWithStringValue:self.emp.emp_mobile]];
    CNLabeledValue *telNumber = [CNLabeledValue labeledValueWithLabel:@"电话" value:[CNPhoneNumber phoneNumberWithStringValue:self.emp.emp_tel]];
    //    if (!exist) {
    contact.phoneNumbers = @[phoneNumber,telNumber];
    
    //    邮箱
    CNLabeledValue *mail = [CNLabeledValue labeledValueWithLabel:@"邮箱" value:self.emp.emp_mail];
    contact.emailAddresses = @[mail];
}

- (void)downloadEmpLogoIfNeed
{
    UIImage *image = [ImageUtil getOnlineLogo:emp];
    if(image == nil)
    {
        NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:self.emp.emp_logo];
        
        dispatch_queue_t queue = dispatch_queue_create("download.smallpic", NULL);
        dispatch_async(queue, ^{
            NSURL *_url = [NSURL URLWithString:[[ServerConfig shareServerConfig]getLogoUrlByEmpId:[StringUtil getStringValue:self.emp.emp_id]]];
            NSData *imageData = [NSData dataWithContentsOfURL:_url];
            if (imageData.length > 0) {
                [imageData writeToFile:logoPath atomically:YES];
                [LogUtil debug:[NSString stringWithFormat:@"%s 小头像已经下载下来 刷新界面",__FUNCTION__]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    显示下载下来的头像
                    [personTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        });
        dispatch_release(queue);
    }

}

- (void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space {
    
    NSString *labelText = label.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];

    for (int i = 0 ; i < self.locationArr.count; i++) {
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([self.locationArr[i] intValue],[self.lengthArr[i] intValue])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange([self.locationArr[i] intValue],[self.lengthArr[i] intValue])];
    }
    label.attributedText = attributedString;
    [label sizeToFit];
    
}

//计算UILabel的高度(带有行间距的情况)
-(CGSize)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 0;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, NSIntegerMax) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size;
}

@end
