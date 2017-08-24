//
//  talkSessionViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//
#import "ChatHistoryView.h"
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "AudioReceiverModeUtil.h"
#endif

#ifdef _HUAXIA_FLAG_
#import "HuaXiaConfUtil.h"
#endif

#import "userInfoViewController.h"
#import "WXOrgUtil.h"
#import "WXReplyOneMsgUtil.h"
#import "RobotUtil.h"
#import "NewImgTxtMsgCell.h"
#import "WXReplyToOneMsgCellTableViewCellArc.h"

#ifdef _XINHUA_FLAG_
#import "SystemMsgModelArc.h"
#import "NewsCellARC.h"
#endif
#import "MiLiaoUtilArc.h"
#import "RobotFileUtil.h"
#import "Emp.h"

#import "ServiceModel.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"
#import "conn.h"
#import "UserInfo.h"
#import "eCloudUser.h"
#import "Conversation.h"
#import "helperObject.h"
#import <CommonCrypto/CommonDigest.h>
#import "ApplicationManager.h"
#import "LCLLoadingView.h"
#import "eCloudNotification.h"

#import "contactViewController.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>  //引入地图功能所有的头文件
#import "LocationModel.h"
#import "LocationMsgUtil.h"

#import "sendMapViewController.h"

#import "ServiceMessage.h"
#import "JSONKit.h"
#import "CustomQLPreviewController.h"
#import "AudioViewController.h"
//#import "AFHTTPRequestOperationManager.h"

#import "NewMyViewControllerOfCustomTableview.h"

#import "mainViewController.h"

#import "ReceiptMsgUtil.h"
#import "RobotMenuParser.h"

#import "RobotDisplayUtil.h"
#import "MsgConn.h"

#import "FunctionButtonModel.h"

#import "ChatBackgroundUtil.h"

#import "eCloudConfig.h"
#import "faceDefine.h"

#import "IOSSystemDefine.h"
#import "UITableViewCell+getCellContentWidth.h"

#import "PublicServiceDAO.h"
#import "PSMsgDspUtil.h"

#import "RobotDAO.h"
#import "CollectionDAO.h"

#import "UserDefaults.h"
#import "ConvNotification.h"

#import "PhoneUtil.h"
#import "EncryptFileManege.h"

#import "ImageUtil.h"
#import "ReceiptMsgDetailViewController.h"
#import "openWebViewController.h"
#import "InputTextView.h"
#import "chatMessageViewController.h"
#import "talkRecordDetailViewController.h"
#import "modifyGroupNameViewController.h"
#import "timeZoneObject.h"
#import "eCloudDefine.h"
#import "MessageView.h"
#import "personInfoViewController.h"
#import "settingRemindController.h"
#import "UIRoundedRectImage.h"
#import "showPreImageViewController.h"
#import "Reachability.h"
#import "ConvRecord.h"
#import "broadcastRecordMemberViewController.h"
#import "chooseTipViewController.h"

#import "NormalTextMsgCell.h"
#import "FaceTextMsgCell.h"
#import "LinkTextMsgCell.h"
#import "AudioMsgCell.h"
#import "PicMsgCell.h"
#import "FileMsgCell.h"
#import "GroupInfoMsgCell.h"
#import "LocationMsgCell.h"
#import "HyperlinkCell.h"
#import "WXReplyToOneMsgCellTableViewCellArc.h"

#import "receiveMapViewController.h"
#import "broadcastViewController.h"
#import "AppDelegate.h"
#import "eCloudDAO.h"
#import "talkSessionUtil.h"
#import "NewMsgNotice.h"
#import "VoiceConverter.h"
#import "FileRecord.h"
#import "MonthHelperViewController.h"
#import "ReceiptMsgReadStatViewController.h"
#import "ReceiptDAO.h"
#import "audioTypeChooseViewController.h"
#import "FPPopoverController.h"
#import "LCLShareThumbController.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "QueryDAO.h"

#import "talkSessionUtil2.h"
#import "MassDAO.h"
#import "MassTextCell.h"
#import "GroupInfoCell.h"
#import "DateCell.h"

#import "MassConn.h"
#import "MassPicCell.h"
#import "MassRecordCell.h"
#import "LongMsgCell.h"
#import "ForwardingRecentViewController.h"

#import "PermissionModel.h"
#import "PermissionUtil.h"

#import "UIAdapterUtil.h"
#import "PSBackButtonUtil.h"
#import "KxMenu.h"

#import "StatusConn.h"

#import "NewFileMsgCell.h"

#import "UserDefaults.h"
#import "folderSizeAndList.h"

#import "UserDataDAO.h"

#import "UserTipsUtil.h"
#import "CloudFileDOA.h"
#import "UploadFileModel.h"
#import "DownloadFileModel.h"
#import "FileAssistantDOA.h"
#import "FileAssistantConn.h"
#import "CRCUtil.h"
#import "FileListViewController.h"
#import "FileAssistantUtil.h"
#import "ServiceMenuModel.h"
#import "IM_MenuView.h"
#import "AgentListViewController.h"
#import "NewOrgViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DisplayVideoViewController.h"
#import "VideoMsgCell.h"
#import "RobotResponseXmlParser.h"
#import "RobotResponseModel.h"
#import "ImgtxtMsgCell.h"
#import "AudioToTextView.h"
#import "TextLinkView.h"
#import "AudioTxtDAO.h"
#import "VirtualGroupDAO.h"
#import "CloudFileModel.h"
#import "CloudFileUtil.h"
#import "CollectionConn.h"

#ifdef _LANGUANG_FLAG_
#import "RedPacketViewControllerARC.h"
#import "RedpacketMessageCell.h"
#import "RedpacketConfig.h"
#import "RedPacketModelArc.h"
#import "LANGUANGShareView.h"
#import "LANGUANGAppMsgModelARC.h"
#import "LGNewsCellARC.h"
#import "LGNewsMdelARC.h"
#import "LANGUANGAgentViewControllerARC.h"
#endif

#import "AESCipher.h"
static int recyle = 0;
#define download_file_tag (100)
#define download_file_msg_id_tag (101)
#define upload_video_tag (200)

/** 华夏创建网络会议的提示 */
#define create_huaxia_conf_alert_tag (201)

#define mapview_tag (10000)


//把talkSessionViewController设置成单例模式
//声明静态实例
//在objective-c中要实现一个单例类，至少需要做以下四个步骤：
//1、为单例对象实现一个静态实例，并初始化，然后设置成nil，
static ChatHistoryView *sharedObj;
@interface ChatHistoryView () <ForwardingDelegate,BMKMapViewDelegate>
{
    UIButton *knowledgeBtn;
    
    //    编辑状态
    BOOL isEditingConvRecord;
    //    编辑聊天记录的toolbar
    UIView *bottomToolBar;
    UIActionSheet *deleteConvRecordsActionSheet;
    
    int lastTextViewLength;
    
    UIImageView *listenModeViewNav;
}
//    导航栏右侧按钮组合
@property (nonatomic,retain) NSArray *rightBtnItems;
@property (nonatomic,retain) UIView *textView;
@property (nonatomic,retain) UILabel *messageLabel;
/** 蓝光分享菜单 */
@property (nonatomic,retain) UIView *infoView;
@property (nonatomic,retain) UIView *bgView;

// 位置消息对应的convrecord
@property (nonatomic,retain) ConvRecord *curLocationRecord;
@property (atomic, assign) BOOL canceled;

@end


@implementation ChatHistoryView
{
    //    增加记录 打开 图片库 的 时间点
    long long selectPicStart;
    
    eCloudDAO *_ecloud ;
    int previewFileIndex;
    FPPopoverController *popover;
    ReceiptDAO *_receiptDAO;
    int receiptMsgFlag;
    UIButton *receiptMsgFlagButton;
    UIColor *defaultBgColorOfReceiptButton;
    UIColor *highlightBgColorOfReceiptButton;
    MassDAO *massDAO;
    bool isCanHundred;
    
    UIImageView *rcvFlagView;
    
    //    显示查询结果使用到的变量
    QueryDAO *queryDAO;
    
    StatusConn *_statusConn;
    
    //显示或隐藏录音切换按钮
    BOOL showAndHideRecord;
    float record_x;
    float messageTextField_x;
    float messageTextField_width;
    
    UIButton *sendButton;
    float messageParsex;
    
    NSOperationQueue *recordQueue;
    
    
    float maxSendFileSize;//文件上传，这个返回21 用新的，20则用老的
    //能否发送消息 以及查看群组资料
    BOOL sendMsgEnable;
    //能否返回按钮
    BOOL backFlag;
    
    //    增加一个按钮，当群组还未创建时，显示这个按钮，提醒用户修改群组名称
    UIButton *modifyGroupNameButton;
    
    //    int talkBusType; // 会话类型，决定底部工具栏的显示
    PublicServiceDAO *_psDAO;
    
    //    功能按钮数组
    NSMutableArray *functionArray;
    
    // 发送视频时相关dic
    NSMutableDictionary *sendVideoDic;
    // 视频录制的时长
    CGFloat maxVideoDuration;
    
    //    记录键盘高度
    float keyboardHeight;
    
    // 小万回复model
    RobotResponseModel *robotModel;
    
    // 调用小万语音转文本接口的字符串
    NSString *audioMessage;
    
    UIImageView *line1;
    int inputType;
    
    /** 蓝光马赛克图片 */
    UIImageView *_MosaicImageView;
    
    UITapGestureRecognizer *tapGesture;
    
}
@synthesize curLocationRecord;

@synthesize robotMenuArray;

@synthesize serviceModel;

@synthesize unloadQueryResultArray;

@synthesize fromConv;
@synthesize forwardRecord = _forwardRecord;
@synthesize fromType;
@synthesize massTotalEmpCount;
@synthesize editIndexPath;

@synthesize isAudioPause;
@synthesize convRecordArray;
@synthesize picOrAudio_MsgID = picOrAudio_MsgID;
@synthesize curRecordPath = _curRecordPath;
@synthesize secondValue;
@synthesize needUpdateTag;
@synthesize delegete;
@synthesize  updateTimeValue;
@synthesize titleStr;
@synthesize talkType;
@synthesize phraseArray=_phraseArray;
@synthesize chatArray = _chatArray;
@synthesize messageString = _messageString;
@synthesize messageTextField = _messageTextField;
@synthesize lastTime = _lastTime;
@synthesize chatTableView = _chatTableView;
@synthesize phraseString = _phraseString;

@synthesize convEmps = _convEmps;
@synthesize convId = _convId;
@synthesize searchStr = _searchStr;

@synthesize firstMsgId = _firstMsgId;
@synthesize firstMsgStr = _firstMsgStr;
@synthesize firstMsgType = _firstMsgType;
@synthesize firstFileName = _firstFileName;
@synthesize firstFileSize = _firstFileSize;
@synthesize isVirGroup = _isVirGroup;
@synthesize last_msg_id;
@synthesize message_len;
//add by shisp
@synthesize isHaveBeingHere = _isHaveBeingHere;

@synthesize reLinkView;
@synthesize topactivity;

@synthesize editMsgId;

@synthesize  curOfflineMsgs;

@synthesize unReadMsgCount;
@synthesize editRecord;
@synthesize editRow;
@synthesize isDeleteAction;

@synthesize curAudioName;
//预览图片
@synthesize preImageFullPath;

@synthesize forwardRecordsArray;
@synthesize firstMenuArray;
@synthesize subMenuArray;
@synthesize sendFileAssistantForwardMsgFlag;

//2、实现一个实例构造方法检查上面声明的静态实例是否为nil，如果是则新建并返回一个本类的实例，

+(ChatHistoryView*)getTalkSession
{
//	NSLog(@"%s",__FUNCTION__);
	@synchronized(self)
	{
		if(sharedObj == nil)
		{
			sharedObj = [[self alloc]init];
			[sharedObj initControls];
		}
	}
	return sharedObj;
}
- (id)init
{
//	NSLog(@"%s",__FUNCTION__);
//
//    @synchronized(self) {
//        [super init];//往往放一些要初始化的变量.
//        return self;
//    }
	return sharedObj;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//	NSLog(@"%s",__FUNCTION__);
	
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//		[self initControls];
//    }
    return sharedObj;
}


//3、重写allocWithZone方法，用来保证其他人直接使用alloc和init试图获得一个新实力的时候不产生一个新实例，
+ (id) allocWithZone:(NSZone *)zone
{
//	NSLog(@"%s",__FUNCTION__);

    @synchronized (self)
	{
        if (sharedObj == nil)
		{
            sharedObj = [super allocWithZone:zone];
			[sharedObj initControls];
            return sharedObj;
        }
		return sharedObj;
    }
//    return nil;
}
//4、适当实现allocWitheZone，copyWithZone，release和autorelease。
- (id) copyWithZone:(NSZone *)zone //第四步
{
//	NSLog(@"%s",__FUNCTION__);

    return self;
}

- (id) retain
{
//	NSLog(@"%s",__FUNCTION__);

    return self;
}

- (unsigned) retainCount
{
    return UINT_MAX;
}

- (oneway void) release
{
//	NSLog(@"%s",__FUNCTION__);

}

- (id) autorelease
{
//	NSLog(@"%s",__FUNCTION__);

    return self;
}

#pragma mark 获取并显示未读记录数
-(void)showNoReadNum
{
	NSString *origin = [StringUtil getAppLocalizableString:@"main_chats"];
    
	int count=[_ecloud getAllNumNotReadedMessge];
	
    if (count > 0) {
		//			检查一下是否有未读消息，并且记录数> 0，如果是，则显示，并且置为已读
		NSArray *notReadMsgIds =  [_ecloud getNotReadMsgId:self.convId];
		
		for(NSString *notReadMsgId in notReadMsgIds)
		{
			NSLog(@"显示未读的消息，msgid is %@",notReadMsgId);
			[self displayMsg:notReadMsgId];
		}
    }
    [PSBackButtonUtil showNoReadNum:nil andButton:backButton andBtnTitle:origin];
}

#pragma mark 显示状态栏
-(void)displayStatusBar
{
	UIApplication* application = [UIApplication sharedApplication];
	if(application.statusBarHidden)
	{
		application.statusBarHidden = NO;
	}
}
#pragma mark 隐藏状态栏
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

-(void)openWebUrl:(NSNotification *)notification
{
    NSLog(@"---urlstr-- %@",notification.object);
    openWebViewController *openweb=[[openWebViewController alloc]init];
    openweb.urlstr=notification.object;
    [self.navigationController pushViewController:openweb animated:YES];
    [openweb release];
}

-(void)shortAudioType:(NSNotification *)notification
{
    
    NSLog(@"---urlstr-- shortAudioType");
    picButton.tag=1;
    
    int index=talkButton.tag;
    
    if (index==1) {
        
        talkButton.tag=2;
        [talkButton setImage:[StringUtil getImageByResName:@"Writting_ico.png"] forState:UIControlStateNormal];
        pressButton.hidden=NO;
        self.messageTextField.hidden=YES;
        if(self.messageTextField.isFirstResponder)
        {
            [self.messageTextField resignFirstResponder];
            
        }else
        {
            [self autoMovekeyBoard:0];
        }
        
    }else
    {
        talkButton.tag=1;
        [talkButton setImage:[StringUtil getImageByResName:@"speaking_ico.png"] forState:UIControlStateNormal];
        pressButton.hidden=YES;
        self.messageTextField.hidden=NO;
        [self.messageTextField becomeFirstResponder];
    }
    
    if (popover) {
        [popover dismissPopoverAnimated:YES];
    }
}

-(void)longAudioType:(NSNotification *)notification
{
    if (popover) {
        [popover dismissPopoverAnimated:YES];
    }
    NSLog(@"---urlstr-- longAudioType");
    longAudioView.hidden=NO;
    if(self.messageTextField.isFirstResponder)
    {
        [self.messageTextField resignFirstResponder];
        
    }else
    {
        [self autoMovekeyBoard:0];
    }
}
#pragma mark 长语音－－－－限时发送－－2013-12-27
-(void)sendAudioByTime
{
	self.secondValue++;
    updateLongTimeLabel.text=[NSString stringWithFormat:[StringUtil getLocalizableString:@"second"],self.secondValue];
    NSLog(@"---now-- %@",updateLongTimeLabel.text);
    if (self.secondValue>59) {//录音限制60秒
        [self recordTouchUpInside:nil];
        [self performSelector:@selector(beginRecordNext) withObject:nil afterDelay:1];
	}
}
-(void)beginRecordNext
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if([self startToRecord])
    {
        self.secondValue=1;
        updateLongTimeLabel.text=[NSString stringWithFormat:[StringUtil getLocalizableString:@"second"],1];
        updateLongTimeLabel.hidden=NO;
        secondTimer=	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendAudioByTime) userInfo:nil repeats:YES];
    }
}
#pragma mark ----长语音 action
-(void)longAudioPlayAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    if (button.tag==1) {
        [longAudioPlayButton setImage:[StringUtil getImageByResName:@"long_audio_down.png"] forState:UIControlStateNormal];
        button.tag=2;
        [longAudioImageView startAnimating];
        backButton.enabled=NO;
        addButton.enabled=NO;
        self.chatTableView.userInteractionEnabled=NO;
         [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        if([self startToRecord])
        {
            self.secondValue=1;
            updateLongTimeLabel.text=[NSString stringWithFormat:[StringUtil getLocalizableString:@"second"],1];
            updateLongTimeLabel.hidden=NO;
            secondTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendAudioByTime) userInfo:nil repeats:YES];
        }
    }else
    {
        backButton.enabled=YES;
        addButton.enabled=YES;
        self.chatTableView.userInteractionEnabled=YES;
        [longAudioPlayButton setImage:[StringUtil getImageByResName:@"long_audio_up.png"] forState:UIControlStateNormal];
        button.tag=1;
        [longAudioImageView stopAnimating];
        updateLongTimeLabel.hidden=YES;
        if (self.secondValue>=1)
        {
            [self endRecordAndSend];
            
        }else
        {
        [self endRecord];
        }
        if (secondTimer!=nil) {
            [secondTimer invalidate];
            secondTimer=nil;
        }
    }
    
}
-(void)longAudioCloseAction:(id)sender
{
    [longAudioImageView stopAnimating];
    longAudioView.hidden=YES;
    backButton.enabled=YES;
    addButton.enabled=YES;
    self.chatTableView.userInteractionEnabled=YES;
    
    if (secondTimer!=nil) {
        [secondTimer invalidate];
        secondTimer=nil;
        if (self.secondValue>=1)
        {
            [self endRecordAndSend];
            
        }else
        {
            [self endRecord];
        }
    }
	[longAudioPlayButton setImage:[StringUtil getImageByResName:@"long_audio_up.png"] forState:UIControlStateNormal];
    longAudioPlayButton.tag=1;
    updateLongTimeLabel.hidden=YES;
}
#pragma mark 新消息提醒
- (void)initRcvFlagView
{
    //    add by shisp 如果群组设置了消息不提醒，那么现实这个图标
    UIImage *noAlarmImage = [ImageUtil getNoAlarmImage:1];
    rcvFlagView = [[[UIImageView alloc]initWithImage:noAlarmImage]autorelease];
    
    CGRect _frame = rcvFlagView.frame;
    _frame.origin = CGPointMake(self.view.frame.size.width - 44 - noAlarmImage.size.width - 5, (44 - noAlarmImage.size.height)/2);
    rcvFlagView.frame = _frame;
    
    [self.navigationController.navigationBar addSubview:rcvFlagView];
    
    rcvFlagView.hidden = YES;
    if([_ecloud getRcvMsgFlagOfConvByConvId:self.convId])
    {
        rcvFlagView.hidden = NO;
    }
}

#pragma mark 一呼百应的处理
- (void)initYhby
{
    if (addScrollview!=nil) {
        
        [[eCloudUser getDatabase]getPurviewValue];
        isCanHundred=[[eCloudUser getDatabase]isCanHundred];
        
        [self showAddScrollow];
        
    }
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
	
	if(self.talkType == massType)
	{
		receiptMsgFlagButton.hidden = YES;
	}
	else
	{//一呼万应消息 不用这个标志
		receiptMsgFlag = [_receiptDAO getConvStatus:self.convId];
		if(receiptMsgFlag == conv_status_receipt)
		{
			receiptMsgFlagButton.hidden = NO;
		}
		else
		{
			receiptMsgFlagButton.hidden = YES;
		}
	}
}

#pragma mark 初始化textfield
- (void)initTextField
{    
//    if (self.messageTextField!=nil&&self.messageTextField.text!=nil&&self.messageTextField.text.length>0) {
//        
//        [self.messageTextField becomeFirstResponder];
//    }
    //	复制图片
	self.messageTextField.copypic=false;
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	NSRange copyrange=[pasteboard.string rangeOfString:@".png"];
    if (copyrange.location!=NSNotFound) {
		self.messageTextField.copypic=true;
    }
}

- (void)initObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(empStatusChange:) name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];

     //监听键盘高度的变换
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
     */
    
    //    // 键盘高度变化通知，ios5.0新增的
    //#ifdef __IPHONE_5_0
    //    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    //    if (version >= 5.0) {
    //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //    }
    //#endif
	
    //	监听系统菜单显示，隐藏
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuDisplay) name:UIMenuControllerWillShowMenuNotification object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuHide) name:UIMenuControllerWillHideMenuNotification object:nil];
	
    /*
    //	监听离线消息收取
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcvOfflineMsgFinish) name:RCV_OFFLINE_MSG_NOTIFICATION object:nil];
	
	//监听登录
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
	// 没有连接通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noConnect:) name:NO_CONNECT_NOTIFICATION object:nil];
	
	//	被踢通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noConnect:) name: @"noctiveOFFLINE" object: nil];
    
	//正在连接通知，显示正在连接
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connecting) name:CONNECTING_NOTIFICATION object:nil];
    */
    //打开网页
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openWebUrl:) name:OPEN_WEB_NOTIFICATION object:nil];
    //录音片，长录音
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shortAudioType:) name:SHORT_AUDIO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(longAudioType:) name:LONG_AUDIO_NOTIFICATION object:nil];
    
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];

    if (!self.isHaveBeingHere) {
        //监听输入框消息
//        [[NSNotificationCenter defaultCenter]addObserver:self
//                                                selector:@selector(handleCmd:)
//                                                    name:CONVERSATION_NOTIFICATION
//                                                  object:nil];
        self.isHaveBeingHere=YES;
        
    }
}

-(void)initNavigationButton
{
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
//    NSString * rightBtnImageName = nil;
//    if (self.talkType == singleType) {
//        rightBtnImageName = @"SingleMember";
//    }else
//    {
//        rightBtnImageName = @"GroupMember";
//    }
//    UIButton * Button =  [UIAdapterUtil setRightButtonItemWithImageName:rightBtnImageName andTarget:self andSelector:@selector(rightButtonPress:)];
//    Button.frame = CGRectMake(0, 0, 25,25);
    
}

- (void)initConnStatus
{
    switch(_conn.connStatus)
	{
		case not_connect_type:
		{
 			[self.topactivity stopAnimating];
            self.reLinkView.hidden=YES;
		}
			break;
		case linking_type:
		{
			[self.topactivity startAnimating];
			self.reLinkView.hidden = YES;
		}
			break;
		case download_org:
		{
			[self.topactivity startAnimating];
			self.reLinkView.hidden = YES;
		}
			break;
		case rcv_type:
		{
			[self.topactivity startAnimating];
			self.reLinkView.hidden = YES;
		}
			break;
		case normal_type:
		{
			[self.topactivity stopAnimating];
			self.reLinkView.hidden = YES;
		}
			break;
	}
}
#pragma mark - 初始化navigationItem
- (void)initBar
{
    //	add by shisp 状态栏有时被隐藏
	[self displayStatusBar];
	
    //	add by shisp 在显示之前先查询未读记录数
	self.unReadMsgCount = [_ecloud updateTextMessageToReadState:self.convId];
    self.unReadMsgCount = 0;
    
    self.navigationController.navigationItem.leftBarButtonItem=nil;
	[self hideTabBar];
    
	[self showNoReadNum];
}
- (void)initConversation
{
    NSString *nowTime =[_conn getSCurrentTime];
    if(self.talkType == mutiableType || self.talkType == massType)
	{
        //        如果还未创建群组，那么就先在本地创建群组
        if(self.convId == nil || self.convId.length == 0)
        {
//            在创建新群组之前，查看是否有相同成员的自己创建的讨论组存在，如果存在，那么就复用
            Conversation *oldConv = nil;
            if (self.talkType == mutiableType) {
                oldConv = [_ecloud searchConvsationByConvEmps:self.convEmps];
            }
            
            if (!oldConv)
            {
                self.titleStr = [talkSessionUtil2 getDefaultTitle:self.talkType andConvEmpArray:self.convEmps];
                if (self.talkType == mutiableType) {
                    int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
                    self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],self.titleStr,all_num];
                }else
                {
                    self.title=self.titleStr;
                }
                
                self.convId = [talkSessionUtil2 getNewConvIdByNowTime:nowTime];
                //			会根据类型，自动创建普通群组会话或群发会话
                [talkSessionUtil2 createConversation:self.talkType andConvId:self.convId andTitle:self.titleStr andCreateTime:nowTime andConvEmpArray:self.convEmps andMassTotalEmpCount:self.massTotalEmpCount];
                
                self.firstMsgStr = self.titleStr;
                self.firstMsgType = type_text;
                self.last_msg_id=-1;
            }
            else
            {
                self.titleStr = oldConv.conv_title;
                self.title = oldConv.conv_title;
                self.convId = oldConv.conv_id;
                self.needUpdateTag = 1;
                self.last_msg_id=oldConv.last_msg_id;
            }
			
        }else
        {
            if (self.talkType == mutiableType && self.last_msg_id==-1) {
                //	只有群组聊天可以增加成员
                NSMutableArray *tempArray = [NSMutableArray array];
                NSDictionary *dic;
                for(Emp *_emp in self.convEmps)
                {
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",[StringUtil getStringValue:_emp.emp_id ],@"emp_id", nil];
                    [tempArray addObject:dic];
                }
                NSDictionary *_dic = [_ecloud addConvEmp:tempArray];
                
                //				你邀请xx加入群聊
				//			在这里增加一个群组创建消息 你邀请谁加入群聊
				//			//群聊中除自己以外的人员的名称
				NSMutableString *otherNames = [NSMutableString stringWithString:@""];
				
				for(Emp *_emp in self.convEmps)
				{
					if([_dic valueForKey:[StringUtil getStringValue:_emp.emp_id]])
					{
						[otherNames appendString:[_emp getEmpName]];
						[otherNames appendString:@","];
					}
				}
				
				if(otherNames.length > 1)
				{
					[otherNames deleteCharactersInRange:NSMakeRange(otherNames.length-1, 1)];
					
					
					NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_invite_x_join_group"],otherNames];
					//	保存到数据库中
					
					[_conn saveGroupNotifyMsg:self.convId andMsg:msgBody andMsgTime:[_conn getSCurrentTime]];
                    
				}
            }
        }
    }
}

- (void)initTitle
{
    self.navigationItem.titleView = nil;
    //add by ly 2014-02-11 群组显示在线人数，总人数
    if (self.talkType == mutiableType) {
        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
        
        
        UIColor *_color = [UIColor colorWithRed:40/255.0 green:83/255.0 blue:142/255.0 alpha:1];
        
        UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(-13, 0, 160, 44)];
        
        NSString *tempString = [NSString stringWithFormat:@"%@(%d)",self.convName,all_num];
        
        NSUInteger len = [self lenghtWithString:self.convName];
        
        int finalLocation = 0;
        if (len>8)
        {
            int tempInter = 0;
            
            for (int i =0; i<tempString.length; i++)
            {
                NSString *tempChar = [tempString substringWithRange:NSMakeRange(i, 1)];
                int abc = [self lenghtWithString:tempChar];
                tempInter = tempInter +abc;
                if (tempInter >8) {
                    finalLocation = i;
                    break;
                }
            }
        }
        
        if(finalLocation>3)
        {
            tempString = [NSString stringWithFormat:@"%@...(%d)",[tempString substringToIndex:finalLocation],all_num];
        }
        
        strLabel.text = tempString;
        strLabel.textColor = [UIColor blackColor];//[ApplicationManager getManager].navigationTitleViewFontColor;
        strLabel.font = [ApplicationManager getManager].navigationTitleViewFont;
        strLabel.textAlignment = UITextAlignmentCenter;
        strLabel.backgroundColor = [UIColor clearColor];// _color;
        
        UIView *groupTitleView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, 120,44)];
        [groupTitleView addSubview:strLabel];
        [strLabel release];
        
        self.navigationItem.titleView = groupTitleView;
        
        [groupTitleView release];
        
    }
    else
    {
        self.title=self.convName;
    }
}


-(NSUInteger) lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    //    NSLog(@"%s,%d",__FUNCTION__,numMatch);
    //字符算一个 汉字算两个
    return len +   numMatch;
}


- (void)initData
{
    //    long long start = [StringUtil currentMillionSecond];
    if (self.sendForwardMsgFlag)
    {
        self.sendForwardMsgFlag = NO;
        [self sendForwardMsg];
    }
    
    if (self.needUpdateTag==1)
    {
        //		需要加载页面
        self.needUpdateTag=0;
        
        //        设置未加载的记录为空
        self.unloadQueryResultArray = [NSMutableArray array];
        
        //        如果是从查询结果打开会话列表界面，并且需要定位
        if (self.fromType == talksession_from_conv_query_result_need_position)
        {
            if(self.convRecordArray.count > 0)
                [self.convRecordArray removeAllObjects];
            [self loadSearchResults:self.fromConv];
        }
        else
        {
            if(self.convRecordArray.count > 0)
                [self.convRecordArray removeAllObjects];
            
            [self.chatTableView reloadData];
            
            //		获取当前会话对应的聊天记录
            [self getRecordsByConvId];
        }
    }
    
    maxSendFileSize = [UserDefaults getMaxSendFileSize];
    
    //    NSLog(@"%s,需要时间%d",__FUNCTION__,[StringUtil currentMillionSecond] - start);
}
#pragma mark 展示聊天界面
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    _statusConn.curViewController = self;
    [_statusConn getStatus];
    
    [self initObserver];
 
    [self initTextField];
    
    [self initRcvFlagView];

    [self initYhby];
    
    [self initConnStatus];
	
    [self initBar];
    
	self.curRecordPath = nil;

    isWifi=[self IsEnableWIFI];

    [self initConversation];

//	[self setRightBtn];
	
    [self initData];

    [self initTitle];
    
    [self refreshViews];
    
    [self initNavigationButton];
    
    showAndHideRecord = YES;//!showAndHideRecord;
    [self showAndHideRecordBtn];
   
    [self setChatBackground];
    
    //表情发送按钮的中英文变化
    [sendButton setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];

}


-(void)createSingleConversation
{
    [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:self.convId andTitle:self.titleStr];
}

#pragma mark - 隐藏或显示
- (void)showAndHideRecordBtn{
    if (showAndHideRecord) {
        talkButton.hidden = NO;
        messageTextField_x = 40.0;
//        messageTextField_width = 190.0;
        //加2更好显示13个字
        if(IOS7_OR_LATER)
        {
            messageTextField_width = 192;
        }
        else
        {
            messageTextField_width = 198;
        }
    }
    else{
        talkButton.hidden = YES;
        messageTextField_x = 10.0;
        messageTextField_width = 220.0;
        if ([self.messageTextField isHidden]) {
            //如果前一个会话是显示录音按钮，当前会话是不显示录音按钮的
            [self talkAction:talkButton];
        }
    }
    
    CGRect frame = self.messageTextField.frame;
    frame.origin.x = messageTextField_x;
    frame.size.width = messageTextField_width;
    [self.messageTextField setFrame:frame];
}

#pragma mark 退出聊天界面
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    _statusConn.curViewController = nil;
    
    [rcvFlagView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];

	//	监听系统菜单显示，隐藏
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
	/*
//	离线消息接收完毕通知，不再显示提示
	[[NSNotificationCenter defaultCenter]removeObserver:self name:RCV_OFFLINE_MSG_NOTIFICATION object:nil];

//    没有连接通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:NO_CONNECT_NOTIFICATION object:nil];
//	被踢通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"noctiveOFFLINE" object:nil];
//	连接中通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:CONNECTING_NOTIFICATION object:nil];
//登录通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:LOGIN_NOTIFICATION object:nil];
     */
//获取用户资料通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];
   
    [[NSNotificationCenter defaultCenter]removeObserver:self name:OPEN_WEB_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SHORT_AUDIO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:LONG_AUDIO_NOTIFICATION object:nil];
    
	[self stopPlayAudio];
   	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playbackQueueStopped" object:nil];
    [self.messageTextField resignFirstResponder];
   
    NSString *lastinputstr=@"";
	if (self.messageTextField.text!=nil) {
        lastinputstr=self.messageTextField.text;
    }
    NSString*last_str=[self getLastInputMsgByConvId:self.convId];
        
    if (![last_str isEqualToString:lastinputstr]) {
        if(self.talkType == singleType)
		{
			[self createSingleConversation];
		}
        [self updateLastInputMsgByConvId:self.convId LastInputMsg:lastinputstr];
        if (lastinputstr.length > 0)
        {
            [self updateLastInputMsgTimeByConvId:self.convId];
        }
    }
//    NSLog(@"-----lastinputstr-%@",lastinputstr);
   //	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"showNoReadNum" object:nil];
	
	//监听键盘高度的变换
    /*
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
     */
    
//    // 键盘高度变化通知，ios5.0新增的
//#ifdef __IPHONE_5_0
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (version >= 5.0) {
//		[[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
//    }
//#endif

}

#pragma mark 展示一条聊天消息
-(void)displayMsg:(NSString *)msgId
{
	ConvRecord *record = [self  getConvRecordByMsgId:msgId];

	if([record.conv_id isEqualToString:self.convId] && (record.read_flag == 1 || record.msg_flag == send_msg))
	{
		[self addOneRecord:record andScrollToEnd:false];
		
		NSLog(@"是当前会话的消息，并且显示");
		
		if (self.chatTableView.contentOffset.y<self.chatTableView.contentSize.height-370-300) {
			NSLog(@"－－－－－不刷新，不置底部");
		}else{
			[self scrollToEnd];
		}
		if(record.read_flag == 1 && self.talkType != massType)
		{
			[_ecloud updateReadStatusByMsgId:msgId sendRead:0];			
		}
        
        if(record.msg_type == type_group_info)
        {
            [self refreshTitle];
        }
	}
}
#pragma mark 离线消息收取完毕通知
-(void)rcvOfflineMsgFinish
{
	if(_conn.userStatus == status_online)
	{
		[self performSelectorOnMainThread:@selector(setTipOk) withObject:nil waitUntilDone:YES];		
	}
}
-(void)setTipOk
{
	[self.topactivity stopAnimating];
//	收到离线消息收取完毕通知后，显示下未读消息数
	[self showNoReadNum];
}

#pragma mark 手动连接按钮
-(void)reLinkButtonAction
{
	NSLog(@"%s",__FUNCTION__);

    if([ApplicationManager getManager].isNetworkOk)
	{
		[self.topactivity startAnimating];
		self.reLinkView.hidden = YES;
		
		[NSThread detachNewThreadSelector:@selector(reLink) toTarget:self withObject:nil];
    }
	else
    {
        UIAlertView *linkalert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"contact_noConnection"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        [linkalert show];
        [linkalert release];
    }
}
-(void)reLink
{
	NSLog(@"%s",__FUNCTION__);
	if(_conn.connStatus == linking_type)
	{
		return;
	}
	if(![_conn initConn] || ![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
	{
		[self performSelectorOnMainThread:@selector(notLink) withObject:nil waitUntilDone:YES];
	}
}

#pragma mark 正在连接
-(void)connecting
{
	NSLog(@"%s",__FUNCTION__);
	[self performSelectorOnMainThread:@selector(link) withObject:nil waitUntilDone:YES];
}
-(void)link
{
	NSLog(@"%s",__FUNCTION__);
	
	[self.topactivity startAnimating];
	self.reLinkView.hidden = YES;
}

- (void)notifyMessage:(NSDictionary *)message
{
	[self performSelectorOnMainThread:@selector(sendNotificationMessage:)  withObject:message waitUntilDone:YES];
}

- (void)sendNotificationMessage:(NSDictionary *)message
{
	[[NSNotificationCenter defaultCenter ]postNotificationName:notificationName object:notificationObject userInfo:message];
}

#pragma mark 没有连接的情况
-(void)noConnect:(NSNotification *)notification
{
	[self performSelectorOnMainThread:@selector(notLink) withObject:nil waitUntilDone:YES];
}
-(void)notLink
{
	NSLog(@"%s",__FUNCTION__);
	[self.topactivity stopAnimating];
    self.reLinkView.hidden=YES;
}

#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
  	eCloudNotification	*cmd					=	(eCloudNotification *)[notification object]; //NSLog(@"--－－－－--cmd.cmdId--%d",cmd.cmdId);
	switch (cmd.cmdId)
	{
		case login_timeout:
		{
			NSLog(@"%s,登录超时",__FUNCTION__);
			[self.topactivity stopAnimating];
            self.reLinkView.hidden=YES;
		}
			break;
		case login_failure:
		{
			NSLog(@"登录失败");
			[self.topactivity stopAnimating];
            self.reLinkView.hidden=YES;
		}
			break;
		case login_success:
		{
			NSLog(@"loginSuccess");
//			[self.topactivity stopAnimating];
             self.reLinkView.hidden=YES;
		}
			break;
		case msg_read_notice:
		{
			NSDictionary *dic = cmd.info;
			NSString *msgId = [dic objectForKey:@"MSG_ID"];
			ConvRecord *convRecord = [self getConvRecordByMsgId:msgId];
			NSString *convId = convRecord.conv_id;
			
			if([convId isEqualToString:self.convId])
			{
				for(int i = self.convRecordArray.count - 1;i>=0;i--)
				{
					ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
					if(_convRecord.msgId == convRecord.msgId)
					{
						[self.convRecordArray replaceObjectAtIndex:i withObject:convRecord];
						[self reloadRow:i + 1];
                        break;
					}
				}
			}
		}
			break;
        case receipt_msg_send_read_success:
        {
            NSDictionary *dic = cmd.info;
			NSString *msgId = [dic objectForKey:@"MSG_ID"];
			ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
			NSString *convId = convRecord.conv_id;
			
			if([convId isEqualToString:self.convId])
			{
                NSString *originMsgId = [dic valueForKey:@"origin_msg_id"];
                long long _originMsgId = originMsgId.longLongValue;
                
                BOOL hasFind = NO;
                
				for(int i = self.convRecordArray.count - 1;i>=0;i--)
				{
					ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
					if(_convRecord.origin_msg_id == _originMsgId)
					{
						_convRecord.readNoticeFlag = 1;
                        hasFind = YES;
					}
                    else
                    {
                        if(hasFind)
                        {//如果已经匹配成功过，那么就不再继续查找
                            break;
                        }
                        else
                        {//如果还没有匹配成功过，那么继续查找
                            continue;
                        }
                            
                    }
				}
			}
        }
            break;

		case offline_msgs://处理接收离线消息
		{
			NSDictionary *dic = notification.userInfo;
			[self.curOfflineMsgs removeAllObjects];
			NSArray *offlineMsgs = [dic valueForKey:@"offline_msgs"];
			for(NSDictionary *dic in offlineMsgs)
			{
				NSString *convId = [dic valueForKey:@"conv_id"];
				if([convId isEqualToString:self.convId])
				{
					NSString *msgId = [dic valueForKey:@"msg_id"];
//					NSLog(@"离线消息，当前会话，msgId is %@",msgId);
					[self.curOfflineMsgs addObject:msgId];
				}
			}
			NSLog(@"当前会话的离线消息条数：%d",[self.curOfflineMsgs count]);
//			如果当前会话的离线消息数量超过10，那么只显示最后10条，效果就如刚进入会话界面相同，只显示最近的10条
			if(self.curOfflineMsgs.count > default_offline_msgs_display_num)
			{
				//					先把所有的置为已读
				for(int i = 0;i<self.curOfflineMsgs.count;i++)
				{
					//				置为已读
					NSString *msgId = [self.curOfflineMsgs objectAtIndex:i];
					//					第二个参数已经没有用到
					[_ecloud updateReadStatusByMsgId:msgId sendRead:0];
				}
				
				[self.convRecordArray removeAllObjects];
				
				[self.chatTableView reloadData];
				
				//		获取当前会话对应的聊天记录
				[self getRecordsByConvId];

				//					可以查看历史记录
				offset = 1;
				
			}
			else
			{
				for(NSString *msgId in self.curOfflineMsgs)
				{
					[self displayMsg:msgId];
				}
			}
			[self.curOfflineMsgs removeAllObjects];
		}
			break;
		case rev_msg://处理接收消息
		{
            NSDictionary *_userInfo = notification.userInfo;
            if (_userInfo)
            {
                NewMsgNotice *_notice = [_userInfo valueForKey:@"msg_notice"];
                if (_notice)
                {
                    if(_notice.msgType == normal_new_msg_type)
                    {
                        if(self.talkType != massType)
                        {
                            NSString *msgId = _notice.msgId;
                            NSLog(@"收到通知,msgId is %@",msgId);
                            [self displayMsg:msgId];
                        }
                    }
                    [self showNoReadNum];
                }
            }
			
//			if(_notice.msgType == mass_reply_msg_type)
//			{
//				if(self.talkType == massType)
//				{
//					NSString *convId = _notice.convId;
//					if([convId isEqualToString:self.convId])
//					{
//						NSString *msgId = _notice.msgId;
//						
//						int index = [self getArrayIndexByMsgId:msgId.intValue];
//						if(index > 0)
//						{
//							ConvRecord *_convRecord = [self getConvRecordByMsgId:msgId];
//							
//					  	ConvRecord *convRecord = [self.convRecordArray objectAtIndex:index];
//							convRecord.mass_reply_emp_count = _convRecord.mass_reply_emp_count;
//							[self.chatTableView reloadData];
//						}
//					}
//					return;
//				}
//				else
//				{
//					return;
//				}
//			}
			
//            [self showNoReadNum];
		}
			break;
        case send_msg_success:
        {
			NSDictionary *dic = cmd.info;
			NSString *massMsgId = [dic valueForKey:@"mass_msg_id"];
		
			if(massMsgId && self.talkType == massType)
			{
				[self updateStatus:massMsgId andStatus:@"0"];
			}
			
			NSString *msgId = [dic objectForKey:@"MSG_ID"];
			if(msgId && self.talkType != massType)
			{
//				参数是0，表示发送成功
				[self updateStatus:msgId andStatus:@"0"];
			}
            talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
            talkSession.needUpdateTag = 1;
            //如果是自己的页面 转发完毕后 到最下面
//            if(self.rollToEnd)
//            {
//                int _index = [self.convRecordArray count] ;
//                
//                [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]
//                                          atScrollPosition: UITableViewScrollPositionBottom
//                                                  animated:NO];
//                self.rollToEnd = NO;
//            }
            
			NSLog(@"send success");
        }
			break;
        case send_msg_failure:
        {
			NSLog(@"send failure");
		}
			break;
        case create_group_success:
        {
			[[LCLLoadingView currentIndicator]hiddenForcibly:true];

            NSDictionary *_dic = cmd.info;
            NSString *convId = [_dic valueForKey:@"CONV_ID"];
            if(![convId isEqualToString:self.convId])
                return;
            
            NSLog(@"分组创建成功");
			NSLog(@"多人会话：%@ ",self.convId);

			if(self.firstMsgType == type_text)
			{
				self.titleStr = [[MessageView getMessageView] replaceFaceStrWithText:self.firstMsgStr];
			}
			else if(self.firstMsgType == type_pic)
			{

				self.titleStr = [StringUtil getLocalizableString:@"msg_type_pic"];
			}else if(self.firstMsgType == type_record)
			{
				self.titleStr = [StringUtil getLocalizableString:@"msg_type_record"];
			}
			else if(self.firstMsgType == type_long_msg)
			{
				self.titleStr = self.firstFileName;
			}
//群组创建成功后，发送第一条消息，为了和群组创建的时间区分开，所以这里增加了1
            int nowtimeInt=[_conn getCurrentTime]+1;
           
            NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
            
            if (self.last_msg_id==-1)
			{
                helperObject *hobject=[_ecloud getTheDateScheduleByGroupID:self.convId];
                if (hobject==nil) {
                    [_ecloud updateConvInfo:self.convId andType:0 andNewValue:self.titleStr];
                    if (self.talkType == mutiableType) {
                        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
                        self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],self.titleStr,all_num];
                    }else
                    {
                        self.title=self.titleStr;
                    }
                }
                self.last_msg_id=0;
            }
			
//            可以发送第一条消息
			NSDictionary *dic=nil;
			//		信息类型为发送信息
			NSString *msgFlag = [StringUtil getStringValue:send_msg];
			//		发送状态为正在发送
			NSString *sendFlag = [StringUtil getStringValue:sending];

			//	新增会话记录
//			如果是文本消息，那么需要添加到数据库
//			如果是录音或图片消息，则聊天记录已经添加到数据库，并且也已上传成功，只需要发送消息即可
			NSString *msgId = self.firstMsgId;
			NSString *sendMsgId = nil;

			if(msgId == nil)
			{                
				dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",[StringUtil getStringValue:self.firstMsgType],@"msg_type",self.firstMsgStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:receiptMsgFlag],@"receipt_msg_flag", nil];
//				NSLog(@"%@",[dic description]);
				//				入库，得到消息id和发送id
				NSDictionary *_dic = [_ecloud addConvRecord:[NSArray arrayWithObject:dic]];
				if(_dic)
				{
					msgId = [_dic valueForKey:@"msg_id"];
					sendMsgId = [_dic valueForKey:@"origin_msg_id"];
				}
			}

			if(msgId != nil)
			{
				//			发送消息 ，创建群组成功后，发送第一条消息
//				第一条消息为文本消息
				if(self.firstMsgType == type_text)
				{
					
//					如果是文本消息，不会显示发送失败按钮，无论发成功与否，都显示正在发送，对于发送失败的会自动重发
					
					[self addAndDisplayTextMessage:self.firstMsgStr andMsgId:msgId.intValue];
					[_conn sendMsg:self.convId andConvType:mutiableType andMsgType:type_text andMsg:self.firstMsgStr andMsgId:sendMsgId.longLongValue  andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
				}
//				增加长消息处理
				else if(self.firstMsgType == type_long_msg)
				{
					ConvRecord *_convRecord = [self  getConvRecordByMsgId:msgId];
					
					sendMsgId = [NSString stringWithFormat:@"%lld",_convRecord.origin_msg_id];
					NSString * convIdOfMsg = _convRecord.conv_id;
					NSString *messageHead = _convRecord.file_name;
					[_conn sendLongMsg:convIdOfMsg andConvType:self.talkType andMsgType:self.firstMsgType andFileSize:self.firstFileSize andMessageHead:messageHead andFileUrl:self.firstMsgStr andMsgId:[sendMsgId longLongValue] andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
				}
				else
				{
					//		如果是录音或图片，存在这种情况，还未上传成功，就退出，进入其他会话，这时convId就不同了，所以发送非图片消息时，会话id是消息对应的会话id
					ConvRecord *_convRecord = [self  getConvRecordByMsgId:msgId];
					sendMsgId = [NSString stringWithFormat:@"%lld",_convRecord.origin_msg_id];
					NSString * convIdOfMsg = _convRecord.conv_id;

					//					多人会话 发送图片或录音
					[_conn sendMsg:convIdOfMsg andConvType:mutiableType andMsgType:self.firstMsgType andFileSize:self.firstFileSize andFileName:self.firstFileName andFileUrl:self.firstMsgStr andMsgId:sendMsgId.longLongValue  andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
				}
				
//				if(!result)
//				{
//                    
//					UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//					[alert show];
//					[alert release];
//					return;
//				}
//				NSLog(@"%s,分组创建成功处理完毕",__FUNCTION__);

			}
        }
			break;
		case create_group_timeout:
		{
            NSDictionary *dic = cmd.info;
            NSString *convId = [dic valueForKey:@"CONV_ID"];
            if(![convId isEqualToString:self.convId])
                return;

			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"group_creat_group_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            [alertView release];
		}
			break;
        case create_group_failure:
        {
            NSDictionary *dic = cmd.info;
            NSString *convId = [dic valueForKey:@"CONV_ID"];
            if(![convId isEqualToString:self.convId])
                return;

			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"group_creat_group_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            [alertView release];
              
        }
			break;
		case get_user_info_success_new:
		{
			NSLog(@"get user info success");
            if (self.talkType==singleType) {
                [self setRightBtn];
            }
		}
			break;
//			群组成员变化通知
		case group_name_modify:
		{
			NSDictionary *_dic = notification.userInfo;
			if(_dic && [[_dic valueForKey:@"conv_id"] isEqualToString:self.convId])
			{
//				self.titleStr = [_dic valueForKey:@"group_name"];
                if (self.talkType == mutiableType) {
                    int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
                    self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],self.titleStr,all_num];
                }else
                {
                    self.title=self.titleStr;
                }
			}
		}
			break;
			
		default:
			break;
	}
	
}

#pragma mark 查看会话资料
-(void)chatMessageAction:(id)sender
{
    //释放
    [KxMenu dismissMenu];
    
    if (_conn.userStatus==status_online&&self.talkType==mutiableType&&(self.convId!=nil &&self.convId.length >0)) {
//		在这里打印时间会话表里的两个时间
//		if([_ecloud isGroupModify:self.convId])
//		{
//			NSLog(@"需要获取资料");
        if (![[UserDataDAO getDatabase]isSystemGroup:self.convId]) {
			[_conn getGroupInfo:self.convId];
        }
//		}
//		else
//		{
//			NSLog(@"不需要获取");
//		}
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    chatMessageViewController*   chatMessage=[[chatMessageViewController alloc]init];
    chatMessage.talkType=self.talkType;
    chatMessage.titleStr=self.titleStr;
    chatMessage.convId=self.convId;
    chatMessage.predelegete=self;
    chatMessage.isVirGroup=self.isVirGroup;
      if (self.talkType==singleType)
      {
      
          if(self.convEmps.count == 2)
          {
              chatMessage.dataArray=self.convEmps;
          }
          else if(self.convEmps.count == 1)
          {
              NSMutableArray *temp = [NSMutableArray arrayWithCapacity:2];
              [temp addObjectsFromArray:self.convEmps];
              [temp addObject:[_ecloud getEmpInfo:_conn.userId]];
              chatMessage.dataArray=temp;
          }

      }else
      {
//       chatMessage.dataArray=self.convEmps;
		  chatMessage.dataArray = [_ecloud getAllConvEmpBy:self.convId];
          chatMessage.create_emp_id=[_ecloud getConvCreateEmpIdByConvId:self.convId];
          chatMessage.last_msg_id=self.last_msg_id;
		  chatMessage.convId = self.convId;
      }
    [self.navigationController pushViewController:chatMessage animated:YES];
//    [self presentModalViewController:chatMessage animated:YES];
    
    [chatMessage release];
    
    [pool release];

}

#pragma mark —— 获取联系人联系方式
-(void)getContactInformation
{
    Emp *emp = [_ecloud getEmpInfo:self.convId];
    [PhoneUtil showPopView:self andTargetButton:telButton andEmp:emp];
}

-(void)dealloc {
	NSLog(@"%s",__FUNCTION__);

    [recordQueue release];
    self.fromConv = nil;
    self.forwardRecord = nil;
	self.editIndexPath = nil;
	
	[defaultBgColorOfReceiptButton release];
	defaultBgColorOfReceiptButton = nil;
	
	[highlightBgColorOfReceiptButton release];
	highlightBgColorOfReceiptButton = nil;
	self.curAudioName = nil;
	self.convRecordArray = nil;
	self.curOfflineMsgs = nil;
	self.editMsgId = nil;
	self.editRecord = nil;
//	self.tempTextView = nil;
	self.picOrAudio_MsgID = nil;
	self.curRecordPath = nil;
	
	self.delegete = nil;
	self.titleStr = nil;
	
    self.bqStrArray = nil;
	self.phraseArray = nil;
	self.phraseString = nil;
	
	self.messageString = nil;
	self.messageTextField = nil;

	self.lastTime = nil;
	self.chatTableView = nil;
	
	self.convEmps = nil;
	self.convId = nil;
	self.searchStr = nil;
	
	self.firstMsgStr = nil;
	self.firstFileName = nil;
	
	self.reLinkView = nil;
	self.topactivity = nil;
    
    self.convName = nil;
    
    [footerView release];
	[personInfo release];
	
//	[[NSNotificationCenter defaultCenter]removeObserver:self name:ADMIN_MEMBER_DISMISS_NOTIFICATION object:nil];

    [super dealloc];
}
#pragma mark ------viewdidload-----here----
- (void)viewDidLoad
{
	NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
	_receiptDAO = [ReceiptDAO getDataBase];
	massDAO = [MassDAO getDatabase];
    queryDAO = [QueryDAO getDatabase];
    
    _statusConn = [StatusConn getConn];
}

#pragma mark 根据会话类型显示不同的图片
-(void)setRightBtn
{
    telButton.hidden = YES;
    telButton.enabled = NO;
    if (self.talkType == singleType)
    {
        Emp *emp =  [_ecloud getEmpInfo:self.convId];
        if ([PhoneUtil needDisplayPhoneButton:emp]) {
            telButton.hidden = NO;
            telButton.enabled = YES;
        }
    }

	if (addButton!=nil)
	{
		addButton.hidden = NO;
		
		NSRange range = [self.convId rangeOfString:@"|"];
		if(range.length > 0)
		{
			addButton.hidden = YES;
			return;
		}
		
		if(self.talkType==singleType)
		{
			[addButton setBackgroundImage:[StringUtil getImageByResName:@"SingleMember.png"] forState:UIControlStateNormal];
			addButton.enabled = YES;
 		}
		else if(self.talkType == mutiableType)
		{
			if([_ecloud userExistInConvEmp:self.convId])
			{
//				NSLog(@"用户在群里，可以查看群组信息");
				[addButton setBackgroundImage:[StringUtil getImageByResName:@"GroupMember.png"] forState:UIControlStateNormal];
				addButton.enabled = YES;
			}
			else
			{
				NSLog(@"用户不在群里，禁止查看群组信息");
				[addButton setBackgroundImage:[StringUtil getImageByResName:@"ic_actbar_chat_group_disable.png"] forState:UIControlStateNormal];
				addButton.enabled = NO;
			}
		}
		else if(self.talkType == massType || self.talkType == rcvMassType)//群发时不显示此按钮
		{
			addButton.hidden = YES;
		}
	}
}
#pragma mark 相册，照相，日程，等等
-(void)removeSubviewFromScrollowView
{
    
    for (UIView *eachView in [addScrollview subviews])
    {
        [eachView removeFromSuperview];
        //[eachView release];
    }
    
}
-(void)showAddScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
    
    /*
     //2014-5-15 以前的 代码有点乱,用更简单的方法
    int showiconNum=4;
	int sumnum=3;
    if (isCanHundred) {
        sumnum=4;
    }
	int pagenum=0;
	if (sumnum%showiconNum!=0) {
		pagenum=sumnum/showiconNum+1;
	}else {
		pagenum=sumnum/showiconNum;
	}
    
	addScrollview.pagingEnabled = NO;
    addScrollview.contentSize = CGSizeMake(addScrollview.frame.size.width , addScrollview.frame.size.height* pagenum);
    
    //  musicFirstSrollview.delegate = self;
    
    
	UIButton *pageview;
	
	int nowindex=0;
	
	
    UIView *itemview;
	UIButton *iconbutton;
    UIButton *deletebutton;
    
    UILabel* nameLabel;
    
	int x;
	int y;
	int cx;
	int cy;
    
	pageview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, addScrollview.frame.size.width, addScrollview.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
    
	x=0;
	y=0;
	cx=0;
	cy=0;
	
    int row=0;
	for (int j=0; j<sumnum; j++) {
		
		
		nowindex=j;
        
		if (j/4==row) {
            
            
            cx=cx+80;
            if (j==0) {
                cx=0;
                cy=1;
            }
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx,y+cy,80,80)];
            //itemview.layer.cornerRadius = 3;//设置那个圆角的有多圆
//            itemview.layer.borderWidth = 0.5;//设置边框的宽度，当然可以不要
//            itemview.layer.borderColor = [[UIColor lightGrayColor] CGColor];//设置边框的颜色
			
		}else if (j/4!=row) {
        	
            cx=0;
            cy=cy+80;
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx,y+cy,80,80)];
            // itemview.layer.cornerRadius = 3;//设置那个圆角的有多圆
//            itemview.layer.borderWidth = 0.5;//设置边框的宽度，当然可以不要
//            itemview.layer.borderColor = [[UIColor lightGrayColor] CGColor];//设置边框的颜色
		}
        
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake((80-60)/2.0,(80-60)/2.0,60,60)];
        
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 60, 60, 20)];
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont systemFontOfSize:12];
        nameLabel.textColor=[UIColor whiteColor];
        nameLabel.textAlignment=UITextAlignmentCenter;
        [itemview addSubview:iconbutton];
        [iconbutton addSubview:nameLabel];
        [nameLabel release];
        
		row=j/4;
		iconbutton.tag=nowindex;
		iconbutton.backgroundColor=[UIColor clearColor];
		[iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
		[pageview addSubview:itemview];
		[iconbutton release];
        
		if (j==0) {
            nameLabel.text=@"照片";
            [iconbutton setImage:[StringUtil getImageByResName:@"chat_picture_icon.png"] forState:UIControlStateNormal];
        }else if(j==1) {
            nameLabel.text=@"拍照";
            [iconbutton setImage:[StringUtil getImageByResName:@"chat_camera_icon.png"] forState:UIControlStateNormal];
        }else if(j==2) {
            nameLabel.text=@"日程";
            [iconbutton setImage:[StringUtil getImageByResName:@"schedule_icon_menu.png"] forState:UIControlStateNormal];
        }else if(j==3) {
            nameLabel.text=@"一呼百应";
            [iconbutton setImage:[StringUtil getImageByResName:@"receipt_msg_icon.png"] forState:UIControlStateNormal];
        }

        
	}
	pageview.frame=CGRectMake(0, 0,addScrollview.frame.size.width,y+cy+115);
    [addScrollview addSubview:pageview];
	addScrollview.contentSize = CGSizeMake(addScrollview.frame.size.width, y+cy+115);
	//self.memberScroll.frame=CGRectMake(0, 217/2.0, 320, y+cy+115);
	[pageview release];
    */
    int showiconNum=4;
	int sumnum=5;
    if (isCanHundred) {
        //一呼百应
        sumnum = 6;
    }
    
    int page = 1;
    page = sumnum/4 + (sumnum%4 ? 1:0);
    //NSLog(@"sumnum---------%i",sumnum);
    
	addScrollview.pagingEnabled = YES;
    addScrollview.scrollEnabled = YES;
    addScrollview.contentSize = CGSizeMake(addScrollview.frame.size.width, 100.0*page);
    
    int i;
    for (i = 0; i < sumnum; i++) {
        UIButton *iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(11.0+80.0*(i%4),10.0+94.0*(i/4),60,60)];
        iconbutton.tag= i;
		iconbutton.backgroundColor=[UIColor clearColor];
		[iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
		[addScrollview addSubview:iconbutton];
		[iconbutton release];
        
        UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 60, 60, 20)];
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont systemFontOfSize:12];
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.textAlignment=UITextAlignmentCenter;
        [iconbutton addSubview:nameLabel];
        [nameLabel release];
        
		if (i==0) {
            nameLabel.text = [StringUtil getLocalizableString:@"chats_talksession_message_photo"];
            [iconbutton setImage:[StringUtil getImageByResName:@"chat_picture_icon.png"] forState:UIControlStateNormal];
        }else if(i==1) {
            nameLabel.text=[StringUtil getLocalizableString:@"chats_talksession_message_camera"];
            [iconbutton setImage:[StringUtil getImageByResName:@"chat_camera_icon.png"] forState:UIControlStateNormal];
        }
//        else if(i==2) {
//            nameLabel.text=[StringUtil getLocalizableString:@"chats_talksession_message_schedule"];
//            [iconbutton setImage:[StringUtil getImageByResName:@"schedule_icon_menu.png"] forState:UIControlStateNormal];
//        }
        else if (i==2){
            nameLabel.text=[StringUtil getLocalizableString:@"chats_talksession_message_file"];
            [iconbutton setImage:[StringUtil getImageByResName:@"chat_file_icon.png"] forState:UIControlStateNormal];
            if(self.talkType == massType)
            {
                iconbutton.enabled = NO;
            }
        }
        else if (i==3){
            nameLabel.text=[StringUtil getLocalizableString:@"chats_talksession_message_receipt"];
            [iconbutton setImage:[StringUtil getImageByResName:@"chat_receipt_icon.png"] forState:UIControlStateNormal];
            if(self.talkType == massType)
            {
                iconbutton.enabled = NO;
            }
        }
        
        /*
        else if(i==4) {
            if (isCanHundred) {
                nameLabel.text=@"一呼百应";
                [iconbutton setImage:[StringUtil getImageByResName:@"receipt_msg_icon.png"] forState:UIControlStateNormal];
                if(self.talkType == massType)
                {
                    iconbutton.enabled = NO;
                }
            }else
            {
                nameLabel.text=[StringUtil getLocalizableString:@"chats_talksession_message_video"];
                [iconbutton setImage:[StringUtil getImageByResName:@"vedio_icon.png"] forState:UIControlStateNormal];
                
            }
            
        }else if(i==5) {
            nameLabel.text=[StringUtil getLocalizableString:@"chats_talksession_message_video"];
            [iconbutton setImage:[StringUtil getImageByResName:@"vedio_icon.png"] forState:UIControlStateNormal];
            
        }*/
        
    }
}
#pragma mark 发送视频
-(void)uploadVedio:(NSMutableDictionary *)dic
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSData *data = [NSData dataWithContentsOfFile:[dic objectForKey:@"fileFullPath"]];
    
    if([data length])
    {
        NSLog(@"-----------------picdata--: %d",data.length);
        [self displayAndUploadLocalFile:data withDic: dic];
    }
    
    [pool drain];
    
}
#pragma mark - pic
- (void)photosLibraryManager:(photosLibraryManager *)manager error:(NSError *)error
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
}

- (void)photosLibraryManager:(photosLibraryManager *)manager pictureInfo:(NSArray *)pictures
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
	
	LCLShareThumbController*assetTable		=	[[LCLShareThumbController alloc]initWithNibName:nil bundle:nil];
	ELCImagePickerController *elcPicker		=	[[ELCImagePickerController alloc] initWithRootViewController:assetTable];
    assetTable.pre_delegete=self;
    [assetTable setParent:elcPicker];
    [assetTable preparePhotos:pictures];
	[elcPicker setDelegate:self];
	
    [self presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [assetTable release];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}
-(void)iconbuttonAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    NSLog(@"click here %d",button.tag);
    int tagindex=button.tag;
    if (tagindex==0) {//照片
     // [self selectExistingPicture];
        if(nil == pictureManager)
        {
            pictureManager	=	[[PictureManager alloc]init];
        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0){
            //用户手动取消授权
            if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
                [self showCanNotAccessPhotos];

                return;
            }
            else {
                //其他情况下都去请求访问图片库
                [(PictureManager *)pictureManager obtainPicturesFrom:fromLibrary delegate:self];
            }
        }
        else
        {
             [(PictureManager *)pictureManager obtainPicturesFrom:fromLibrary delegate:self];
        }
    }else if(tagindex==1) {//拍照
      [self getCameraPicture];
    }
    else if(tagindex==2) {
        /*
        //日程
        NSLog(@"-----addAction");
        addScheduleViewController *addSchedule=[[addScheduleViewController alloc]init];
        addSchedule.title= [StringUtil getLocalizableString:@"chats_talksession_message_schedule_add"];
        NSDate*destDate=[NSDate date];
        addSchedule.is_from_group=true;
        if (self.talkType==singleType)
        {
            
            if(self.convEmps.count == 2)
            {
                addSchedule.dataArray=self.convEmps;
            }
            else if(self.convEmps.count == 1)
            {
                NSMutableArray *temp = [NSMutableArray arrayWithCapacity:2];
                [temp addObjectsFromArray:self.convEmps];
                [temp addObject:[_ecloud getEmpInfo:_conn.userId]];
                addSchedule.dataArray=temp;
            }
            
        }else
        {
            addSchedule.dataArray=[_ecloud getAllConvEmpBy:self.convId];
        }
        
        addSchedule.startDate=destDate;
        addSchedule.endDate=[destDate dateByAddingTimeInterval:2*60*60];
        //addSchedule.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:addSchedule animated:YES];
        [addSchedule release];
         */
        
        //文件
        LocaLFilesViewController *ctr = [[LocaLFilesViewController alloc] init];
        ctr.locaLFilesDelegate = self;
        [self.navigationController pushViewController:ctr animated:YES];
        
        
    }
    else if(tagindex==3){
        //回执
        NSLog(@"---------回执");
        
    }
//    else if(tagindex==4)
//	{   if(isCanHundred)
//    {
//        //一呼百应
//		if(receiptMsgFlag == conv_status_normal)
//		{
//			receiptMsgFlagButton.hidden=NO;
//			receiptMsgFlag = conv_status_receipt;
//			[_receiptDAO setConvStatus:self.convId andStatus:receiptMsgFlag];
//		}
//		else
//		{
//            //			高亮显示一呼百应
//			receiptMsgFlagButton.backgroundColor = highlightBgColorOfReceiptButton;
//			[self performSelector:@selector(resetReceiptButton) withObject:nil afterDelay:0.8];
//		}
//    }else
//    {
//        NSLog(@"---这里是视频－_－");
//        videoListViewController *videoController=[[videoListViewController alloc] init];
//        videoController.delegete=self;
//        [self.navigationController pushViewController:videoController animated:YES];
//        [videoController release];
//        
//    }
//    }else if(tagindex==5)
//	{
//        NSLog(@"---这里是视频－_－");
//        videoListViewController *videoController=[[videoListViewController alloc] init];
//        videoController.delegete=self;
//        [self.navigationController pushViewController:videoController animated:YES];
//        [videoController release];
//    }
}
-(void)resetReceiptButton
{
	receiptMsgFlagButton.backgroundColor = defaultBgColorOfReceiptButton;
}
-(void)changeConvStatusAction
{
    receiptMsgFlagButton.hidden=YES;
	receiptMsgFlag = conv_status_normal;
	[_receiptDAO setConvStatus:self.convId andStatus:receiptMsgFlag];

    picButton.tag=1;
	
    tableBackGroudButton.hidden=YES;
    if(self.messageTextField.isFirstResponder)
    {
        [self.messageTextField resignFirstResponder];
    }
	else
    {
        [self autoMovekeyBoard:0];
    }
    NSLog(@"取消一呼百应");
}
#pragma mark 初始化聊天界面需要的UI控件
-(void)initControls
{
    recordQueue = [[NSOperationQueue alloc]init];
    
    chatBackgroudView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height)];
    chatBackgroudView.clipsToBounds = YES;
    chatBackgroudView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:chatBackgroudView];
    [chatBackgroudView release];
    NSLog(@"--here--initControls");
	//add amr to wav
    amrtowav=[[amrToWavMothod alloc]init];
    audioplayios6=[[AudioPlayForIOS6 alloc]init];
	
	float sendX = 20;
	float sendY = 8;
	float sendWidth = 12.5;
	float sendHeight = 18.5;
	sendVoicePlayView = [[UIImageView alloc]initWithFrame:CGRectMake(sendX, sendY, sendWidth, sendHeight)];
	sendVoicePlayView.image = [StringUtil getImageByResName:@"voice_send_default.png"];
	sendVoicePlayView.animationImages = [NSArray arrayWithObjects:[StringUtil getImageByResName:@"voice_send_play_1.png"],[StringUtil getImageByResName:@"voice_send_play_2.png"],[StringUtil getImageByResName:@"voice_send_play_3.png"],[StringUtil getImageByResName:@"voice_send_default.png"], nil];
	sendVoicePlayView.animationDuration = 1;
	sendVoicePlayView.animationRepeatCount = 0;
	
	
	float rcvX = 20;
	float rcvY = 8;
	float rcvWidth = 12.5;
	float rcvHeight = 18.5;
	rcvVoicePlayView = [[UIImageView alloc]initWithFrame:CGRectMake(rcvX, rcvY, rcvWidth, rcvHeight)];
	rcvVoicePlayView.image = [StringUtil getImageByResName:@"voice_rcv_default.png"];
	rcvVoicePlayView.animationImages = [NSArray arrayWithObjects:[StringUtil getImageByResName:@"voice_rcv_play_1.png"],[StringUtil getImageByResName:@"voice_rcv_play_2.png"],[StringUtil getImageByResName:@"voice_rcv_play_3.png"],[StringUtil getImageByResName:@"voice_rcv_default.png"], nil];
	rcvVoicePlayView.animationDuration = 1;
	rcvVoicePlayView.animationRepeatCount = 0;
	
    [UIAdapterUtil setBackGroundColorOfController:self];
    
	_ecloud = [eCloudDAO getDatabase] ;
    
	_conn = [conn getConn];
	
    [[eCloudUser getDatabase]getPurviewValue];
    isCanHundred=[[eCloudUser getDatabase]isCanHundred];
    
	UIImage *image = [StringUtil getImageByResName:@"001.png"];
	CGImageRef imageRef = [image CGImage];
	faceWidth = CGImageGetWidth(imageRef);
	faceHeight = CGImageGetHeight(imageRef);
	
	
    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    self.messageString = tempStr;
    [tempStr release];
    
	NSDate   *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
	[tempDate release];
    

    /*
	bqStrArray = [NSArray arrayWithObjects:@"wx",@"han",@"am",@"by",@"bs",@"bz",@"bx",@"dk",@"dx",@"tx",
				  @"baib",@"gz2",@"heng",@"yhh",@"hxiao",@"hy",@"je",@"jy",@"jl",
				  @"ku",@"lhan",@"llei",@"shh",@"tc",@"xia",@"xu",@"yx",@"zhk",
				  @"tu",@"tp",@"ex",@"nu",@"gg",@"hxiu",@"hx",@"jk",@"ka",
				  @"kl",@"kun",@"lh",@"ng",@"girl",@"wq",@"qq",@"se",@"shuai",
				  @"yun",@"zhu",@"yw",@"fd",@"fdou",@"qd",@"money",@"huiy",@"ws",@"gz1",@"ok",@"bq",@"cj",@"lh2",@"sl",@"yb",@"coffee",@"xh",@"xs",@"ax",
                  @"ppq",@"dao",@"zq",@"ndshu",@"nlhai",@"nnguo",@"ngirl",@"nyb",
				  @"ndd",@"ndl",@"ngl",@"nheng",@"njr",@"njiong",@"ndk",@"nku",@"nkun",@"nmg",
                  @"nsx",@"ncs",@"nsh",@"ntc",@"ntx",@"nwq",@"nzd",
				  @"nok",@"nno",@"ncc",@"ndy",@"ndnfz",@"nds",@"ndbq",@"nfd",@"nfdn",@"nfn",
				  @"nhxiu",@"nhx",@"njy",@"nkj",@"nlei",@"nnlmm",@"nnb",@"ntq",@"ntqiu",@"nxx",
				  @"nxhnf",@"nxw",@"nyw",@"nzan",@"nzxr",@"nzk",
                  @"dh",@"dsj",@"email",@"jiub",@"lw",@"music",@"pj",@"sj",@"xg",@"yaow",
                  @"fjding",@"fjdy",@"fjfw",@"fjhang",@"fjku",@"fjrz",@"fjwq",@"fjwx",@"fjyun",nil ];
     */
    /*
    self.bqStrArray = [NSArray arrayWithObjects:@"wx",@"han",@"am",@"by",@"bs",@"bz",@"bx",@"dk",@"dx",@"tx",
				  @"baib",@"gz2",@"heng",@"yhh",@"hxiao",@"hy",@"je",@"jy",@"jl",
				  @"ku",@"lhan",@"llei",@"shh",@"tc",@"xia",@"xu",@"yx",@"zhk",
				  @"tu",@"tp",@"ex",@"sc",@"nu",
                  
                  @"gg",@"hxiu",@"hx",@"jk",@"ka",
				  @"kl",@"kun",@"lh",@"ng",@"girl",@"wq",@"qq",@"se",@"shuai",
            @"yun",@"zhu",@"yw",@"fd",@"fdou",@"qd",@"money",@"huiy",@"ws",@"gz1",@"ok",@"bq",@"cj",@"lh2",@"sl",@"yb",@"sc",@"coffee",@"xh",
                       
                  @"xs",@"ax",@"ppq",@"dao",@"zq",@"ndshu",@"nlhai",@"nnguo",@"ngirl",@"nyb",
				  @"ndd",@"ndl",@"ngl",@"nheng",@"njr",@"njiong",@"ndk",@"nku",@"nkun",@"nmg",
                  @"nsx",@"ncs",@"nsh",@"ntc",@"ntx",@"nwq",@"nzd",
				  @"nok",@"nno",@"sc",@"ncc",
                       
                  @"ndy",@"ndnfz",@"nds",@"ndbq",@"nfd",@"nfdn",@"nfn",
				  @"nhxiu",@"nhx",@"njy",@"nkj",@"nlei",@"nnlmm",@"nnb",@"ntq",@"ntqiu",@"nxx",
				  @"nxhnf",@"nxw",@"nyw",@"nzan",@"nzxr",@"nzk",
                  @"dh",@"dsj",@"email",@"jiub",@"lw",@"music",@"pj",@"sc",
                  @"sj",@"xg",@"yaow",
                  @"fjding",@"fjdy",@"fjfw",@"fjhang",@"fjku",@"fjrz",@"fjwq",@"fjwx",@"fjyun",nil ];
    
	             
    //聊天表情相关
    NSMutableArray *temp = [[NSMutableArray alloc] init];
	NSString *faceName = @"";
	
    for (int i = 0;i<[self.bqStrArray count];i++){
		//		 表情名字
		faceName = [NSString stringWithFormat:@"face_%@.png", [self.bqStrArray objectAtIndex:i]];

		//        表情对应的image对象
		UIImage *face = [StringUtil getImageByResName:faceName];// [NSString stringWithFormat:@"%03d.png",i+1]];
		//        生成一个dic，key是[/bqStr]，value是一个表情对象
		NSMutableDictionary *dicFace = [NSMutableDictionary dictionary];
        [dicFace setValue:face forKey:[NSString stringWithFormat:@"[/%@]",[self.bqStrArray objectAtIndex:i]]];// [NSString stringWithFormat:@"[/%03d]",i+1]];
        [temp addObject:dicFace];
    }
    self.phraseArray = temp;
	[temp release];
    */
    
	int tableH = 370;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    self.chatTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  CGRectGetHeight(self.view.frame)-40.0)style:UITableViewStyleGrouped]autorelease];
	
    
    [self.chatTableView setDelegate:self];
    [self.chatTableView setDataSource:self];
    
	//self.chatTableView.backgroundView.backgroundColor=[UIColor clearColor];
    self.chatTableView.backgroundView = nil;
    self.chatTableView.backgroundColor = [UIColor clearColor];
	//self.chatTableView.backgroundView = [[[UIImageView alloc]initWithImage:[StringUtil getImageByResName:@"ChatBackground.jpg"]]autorelease];
	//    self.chatTableView.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
   self.chatTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //新增隐藏按钮
      
	//	增加长按功能
	//创建长按手势监听
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(myHandleTableviewCellLongPressed:)];
    
    //代理
    longPress.minimumPressDuration = 0.5;
    //将长按手势添加到需要实现长按操作的视图里
    [self.chatTableView addGestureRecognizer:longPress];
	
    [longPress release];
	
//    万达需求 取消双击
	//	为表格增加双击的手势
//	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapTableViewListener:)];
//	doubleTap.numberOfTapsRequired = 2;
//	[self.chatTableView addGestureRecognizer:doubleTap];
//	[doubleTap release];
	[self.view addSubview:self.chatTableView];
    
    tableBackGroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, tableH)];
    // tableBackGroudButton.backgroundColor=[UIColor lightGrayColor];
    [tableBackGroudButton addTarget:self action:@selector(tableBackGroudAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:tableBackGroudButton];
    tableBackGroudButton.hidden=YES;
    
	defaultBgColorOfReceiptButton = [[UIColor alloc]initWithRed:54/255.0  green:54/255.0  blue:54/255.0  alpha:0.7];
	highlightBgColorOfReceiptButton = [[UIColor alloc]initWithRed:37/255.0 green:157/255.0 blue:29/255.0 alpha:0.7];
	
    receiptMsgFlagButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    receiptMsgFlagButton.hidden=YES;
    receiptMsgFlagButton.backgroundColor= defaultBgColorOfReceiptButton;
    [receiptMsgFlagButton addTarget:self action:@selector(changeConvStatusAction) forControlEvents:UIControlEventTouchUpInside];
    [receiptMsgFlagButton setTitle:[StringUtil getLocalizableString:@"change_conv_status_to_normal"] forState:UIControlStateNormal];
    receiptMsgFlagButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:receiptMsgFlagButton];
	[receiptMsgFlagButton release];
	
    //听筒模式
    listenModeView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    listenModeView.backgroundColor= defaultBgColorOfReceiptButton;
    [self.view addSubview:listenModeView];
    listenModeView.hidden=YES;
    UIImageView *type_image_view=[[UIImageView alloc]initWithFrame:CGRectMake(5, (listenModeView.frame.size.height - 30) * 0.5, 30, 30)];
    type_image_view.tag=1;
    type_image_view.image=[StringUtil getImageByResName:@"listen_mode_er_now.png"];
    [listenModeView addSubview:type_image_view];
    [type_image_view release];
    UILabel *modetipLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 5, 220, 35)];
    modetipLabel.tag=2;
    modetipLabel.backgroundColor=[UIColor clearColor];
    modetipLabel.textColor=[UIColor whiteColor];
    [listenModeView addSubview:modetipLabel];
    [modetipLabel release];
    UIButton *close_mode_button=[[UIButton alloc]initWithFrame:CGRectMake(listenModeView.frame.size.width - 30 - 5, 5, 30, 30)];
    [close_mode_button setImage:[StringUtil getImageByResName:@"listen_mode_close.png"] forState:UIControlStateNormal];
    [close_mode_button addTarget:self action:@selector(dismissListenMode) forControlEvents:UIControlEventTouchUpInside];
    [listenModeView addSubview:close_mode_button];
    [close_mode_button release];
	[listenModeView release];
    
    
	//	update by shisp 加载历史记录提示框放到表格的第一行
	loadingIndic =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	loadingIndic.frame=CGRectMake(145,5, 30.0f,30.0f);
	
	loadingIndic.hidden = YES;
	isLoading = false;
    
	//	标题栏
    /*
    if (self.talkType == mutiableType) {
        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
        self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],self.titleStr,all_num];
    }else
    {
        self.title=self.titleStr;
    }
     
    //	手动连接按钮相关代码
	self.topactivity=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.topactivity.frame=CGRectMake(65, 10, 30, 30);
	[self.navigationController.navigationBar addSubview:self.topactivity];
	*/
    //    返回按钮
//    backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    // Do any additional setup after loading the view from its nib.
    
    
    
    personInfo=[[personInfoViewController alloc]init];
    personInfo.delegate = self;
    
    //	文本框  复制粘贴需要 self.messageTextField.copypic
    self.messageTextField=[[InputTextView alloc]init];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:ADMIN_MEMBER_DISMISS_NOTIFICATION object:nil];
    
    /*
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(275, 0, 44,44);
    [addButton addTarget:self action:@selector(chatMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 在导航栏增加一个打电话按钮
    telButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [telButton setImage:[StringUtil getImageByResName:@"tel.png"] forState:UIControlStateNormal];
    telButton.frame = CGRectMake(425, 0, 44,44);
    [telButton addTarget:self action:@selector(getContactInformation) forControlEvents:UIControlEventTouchUpInside];
    
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
//    self.navigationItem.rightBarButtonItem= rightItem;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    UIBarButtonItem *telItem = [[UIBarButtonItem alloc]initWithCustomView:telButton];
    NSArray *rightBtnItems = nil;
    if (IOS7_OR_LATER) {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = -12.0f;
        rightBtnItems = @[space,addItem,telItem];
        [space release];
    }else
    {
        rightBtnItems = @[addItem,telItem];
    }
    self.navigationItem.rightBarButtonItems = rightBtnItems;
    [addItem release];
    [telItem release];
	*/
	//-------------底部栏---------------
//	底部栏的y值为
    /*
	int footerY =self.view.frame.size.height - 50 -44;
    if (IOS7_OR_LATER)
    {
        footerY = footerY - 20;
    }
    
    
//	if(iPhone5)
//		footerY = footerY + i5_h_diff;
    footerView=[[UIView alloc]initWithFrame:CGRectMake(0, footerY, 320, 50)];
    footerView.layer.borderWidth = 1.0;
    footerView.layer.borderColor = [[UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0] CGColor];
//    footerView.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    footerView.backgroundColor=[UIColor colorWithRed:242.0/255 green:245.0/255 blue:241.0/255 alpha:1.0];
    [self.view addSubview:footerView];
    
    subfooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 260)];
    subfooterView.backgroundColor=[UIColor clearColor];
    [footerView addSubview:subfooterView];
    
    
	//	录音按钮
    talkButton=[[UIButton alloc]initWithFrame:CGRectMake(5, 5+2, 30, 30)];
    talkButton.tag=1;
    [talkButton setImage:[StringUtil getImageByResName:@"speaking_ico.png"] forState:UIControlStateNormal];
    [talkButton addTarget:self action:@selector(talkAction:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:talkButton];
    
    messageTextField_x = 10.0;
    messageTextField_width = 220.0;
    
	//	文本框
    self.messageTextField=[[InputTextView alloc]initWithFrame:CGRectMake(messageTextField_x,5, messageTextField_width, 34)];
	self.messageTextField.layer.borderColor = [UIColor grayColor].CGColor;
	self.messageTextField.layer.borderWidth =1.0;
	self.messageTextField.layer.cornerRadius =5.0;
    self.messageTextField.font=[UIFont systemFontOfSize:14];
    self.messageTextField.copypic=false;
    self.messageTextField.contentSize=CGSizeMake(messageTextField_width-10.0, 33);
    self.messageTextField.delegate=self;
    self.messageTextField.returnKeyType= UIReturnKeySend;
    [footerView addSubview:self.messageTextField];
   // self.messageTextField.editable=NO;
  //   [menuController setMenuVisible: YES animated: YES];
	//	录音按钮
    pressButton=[[UIButton alloc] init];
    if (IOS7_OR_LATER) {
        [pressButton setFrame:CGRectMake(40,5, 180+12, 34)];
    }else
    {
        [pressButton setFrame:CGRectMake(40,5, 180+18, 34)];
    }
    pressButton.hidden=YES;

    [pressButton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button.png"] forState:UIControlStateNormal];
    [pressButton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button_click.png"] forState:UIControlStateHighlighted];
	[pressButton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button_click.png"] forState:UIControlStateSelected];
    [pressButton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button_click.png"] forState:UIControlStateDisabled];
    [pressButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [pressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	
	//
	[pressButton addTarget:self action:@selector(recordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	[pressButton addTarget:self action:@selector(recordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[pressButton addTarget:self action:@selector(recordTouchDown:) forControlEvents:UIControlEventTouchDown];
	[pressButton addTarget:self action:@selector(recordTouchDragOutside:) forControlEvents: UIControlEventTouchDragOutside];
    [pressButton addTarget:self action:@selector(recordTouchDragIn:) forControlEvents: UIControlEventTouchDragInside];
	
    [footerView addSubview:pressButton];
    [pressButton release];
	
	//	表情选择按钮
    if(IOS7_OR_LATER)
    {
        iconButton =[[UIButton alloc]initWithFrame:CGRectMake(235+4, 5+2, 30, 30)];
    }else
    {
        iconButton = [[UIButton alloc]initWithFrame:CGRectMake(235+8, 5+2, 30, 30)];
    }
    iconButton.tag=1;
    [iconButton setImage:[StringUtil getImageByResName:@"facepic_ico.png"] forState:UIControlStateNormal];
    [iconButton addTarget:self action:@selector(moodIconAction:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:iconButton];
	
	//	图片选择按钮
    picButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 5+2, 50,30)];
    picButton.tag=1;
    [picButton setImage:[StringUtil getImageByResName:@"type_select_btn_nor.png"] forState:UIControlStateNormal];
//	[picButton setImage:[StringUtil getImageByResName:@"type_select_btn_pressed.png"] forState:UIControlStateHighlighted];
//	[picButton setImage:[StringUtil getImageByResName:@"type_select_btn_pressed.png"] forState:UIControlStateSelected];
    [picButton addTarget:self action:@selector(chooseItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:picButton];
    [picButton release];
    
	//	分割线
    UIImageView *line1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 320, 1)];
    line1.image=[StringUtil getImageByResName:@"Layer_line.png"];
    [subfooterView addSubview:line1];
    [line1 release];
    
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(20, 230, 280, 20)];
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:135.0/255 green:135.0/255 blue:135.0/255 alpha:1.0];
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
	[subfooterView addSubview:pageControl];
	[pageControl release];
    
	//	发送按钮
    sendButton=[[UIButton alloc]initWithFrame:CGRectMake(250, 220, 60,30)];
    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [sendButton setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];
    sendButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [sendButton addTarget:self action:@selector(sendMessage_Click:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:sendButton];
    [sendButton release];
    
    //长语音
    longAudioView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 53)];
    longAudioView.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    longAudioView.hidden=YES;
    [footerView addSubview:longAudioView];
    [longAudioView release];
    
    longAudioImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 37/2.0, 51/2.0)];
    longAudioImageView.image = [StringUtil getImageByResName:@"long_audio_play_0.png"];
	longAudioImageView.animationImages = [NSArray arrayWithObjects:[StringUtil getImageByResName:@"long_audio_play_1.png"],[StringUtil getImageByResName:@"long_audio_play_2.png"],[StringUtil getImageByResName:@"long_audio_play_3.png"],[StringUtil getImageByResName:@"long_audio_play_0.png"], nil];
	longAudioImageView.animationDuration = 1;
	longAudioImageView.animationRepeatCount = 0;
    
    longAudioPlayButton=[[UIButton alloc]initWithFrame:CGRectMake(140, 5, 75/2.0, 75/2.0)];
    [longAudioPlayButton setImage:[StringUtil getImageByResName:@"long_audio_up.png"] forState:UIControlStateNormal];
    longAudioPlayButton.tag=1;
    [longAudioPlayButton addTarget:self action:@selector(longAudioPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    
    longAudioCloseButton=[[UIButton alloc]initWithFrame:CGRectMake(320-10-24, 10, 24, 24)];
    [longAudioCloseButton setImage:[StringUtil getImageByResName:@"long_audio_close.png"] forState:UIControlStateNormal];
    [longAudioCloseButton addTarget:self action:@selector(longAudioCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [longAudioView addSubview:longAudioImageView];
    [longAudioView addSubview:longAudioPlayButton];
    [longAudioView addSubview:longAudioCloseButton];
    
    updateLongTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 100, 20)];
    updateLongTimeLabel.textAlignment=UITextAlignmentLeft;
    updateLongTimeLabel.backgroundColor=[UIColor clearColor];
    updateLongTimeLabel.textColor=[UIColor whiteColor];
    [longAudioView addSubview:updateLongTimeLabel];
	//	表情
    faceScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 53, 320, 170)];
    faceScrollview.pagingEnabled=YES;
    faceScrollview.delegate=self;
    faceScrollview.showsHorizontalScrollIndicator=NO;
    faceScrollview.showsVerticalScrollIndicator=NO;
    faceScrollview.backgroundColor=[UIColor clearColor];
    [subfooterView addSubview:faceScrollview];
    [self updateScrollview];
    
    addScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 53, 320, 260-53)];
    addScrollview.pagingEnabled=YES;
    addScrollview.delegate=self;
    addScrollview.showsHorizontalScrollIndicator=NO;
    addScrollview.showsVerticalScrollIndicator=NO;
    addScrollview.backgroundColor=[UIColor clearColor];
//    addScrollview.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    addScrollview.backgroundColor=[UIColor colorWithRed:250.0/255 green:250.0/255 blue:250.0/255 alpha:1.0];
    [subfooterView addSubview:addScrollview];
    [self showAddScrollow];
	//	录音按钮
    talkIconView=[[UIImageView alloc]initWithFrame:CGRectMake((320-131)/2.0, 200, 131, 120)];
    talkIconView.image=[StringUtil getImageByResName:@"speak_Layer_bj.png"];
    [self.view addSubview:talkIconView];
    talkIconView.hidden=YES;
    UIImageView *talkimageview=[[UIImageView alloc]initWithFrame:CGRectMake(131/4.0, 5, 131/2.0, 120/2)];
	//  talkimageview.image=[StringUtil getImageByResName:@"Microphone_ico.png"];
    talkimageview.animationImages = [NSArray arrayWithObjects:
									 [StringUtil getImageByResName:@"Microphone_ico01.png"],
									 [StringUtil getImageByResName:@"Microphone_ico02.png"],
									 [StringUtil getImageByResName:@"Microphone_ico03.png"],nil];
	
	// all frames will execute in 1.75 seconds
	talkimageview.animationDuration = 1;
	// repeat the annimation forever
	talkimageview.animationRepeatCount = 0;
	// start animating
	[talkimageview startAnimating];
    [talkIconView addSubview:talkimageview];
    [talkimageview release];
    updateTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 65, 131/2.0, 20)];
    
    updateTimeLabel.textAlignment=UITextAlignmentCenter;
    updateTimeLabel.backgroundColor=[UIColor clearColor];
    [talkimageview addSubview:updateTimeLabel];
    UILabel *tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 90, 131, 20)];
//    tipLabel.text=@"滑动到此可以取消发送";
    tipLabel.tag = 11;
    tipLabel.textAlignment=UITextAlignmentCenter;
    tipLabel.font=[UIFont systemFontOfSize:12];
    tipLabel.backgroundColor=[UIColor clearColor];
	[talkIconView addSubview:tipLabel];
    [tipLabel release];
    
    //录音不播放提示。
    talkIconWarningView=[[UIImageView alloc]initWithFrame:CGRectMake((320-131)/2.0, 200, 131, 120)];
    talkIconWarningView.image=[StringUtil getImageByResName:@"speak_Layer_bj1.png"];
    [self.view addSubview:talkIconWarningView];
    talkIconWarningView.hidden=YES;
    UILabel *warningtipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 90, 131, 20)];
//    warningtipLabel.text=@"说话时间太短";
    warningtipLabel.tag = 11;
    warningtipLabel.textColor=[UIColor whiteColor];
    warningtipLabel.textAlignment=UITextAlignmentCenter;
    warningtipLabel.font=[UIFont systemFontOfSize:12];
    warningtipLabel.backgroundColor=[UIColor clearColor];
	[talkIconWarningView addSubview:warningtipLabel];
    [warningtipLabel release];
    
    
    talkIconCancelView=[[UIImageView alloc]initWithFrame:CGRectMake((320-131)/2.0, 200, 131, 120)];
    talkIconCancelView.image=[StringUtil getImageByResName:@"speak_Layer_bj.png"];
    UIImageView*imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 131, 120)];
    imageview.image=[StringUtil getImageByResName:@"cancel_audio.png"];
    [talkIconCancelView addSubview:imageview];
    [self.view addSubview:talkIconCancelView];
    [imageview release];
    talkIconCancelView.hidden=YES;
    
    UILabel *cancelLabel=[[UILabel alloc]initWithFrame:CGRectMake(6.0, 90, 119.0, 26.0)];
    cancelLabel.tag = 11;
    cancelLabel.textAlignment=UITextAlignmentCenter;
    cancelLabel.textColor = [UIColor whiteColor];
    cancelLabel.font=[UIFont systemFontOfSize:13.0];
    cancelLabel.backgroundColor=[UIColor redColor];
	[talkIconCancelView addSubview:cancelLabel];
    [cancelLabel release];
    
    
    
 	// Do any additional setup after loading the view.
    //----------------------------------录音-------------------------------------------------------
    m_isRecording = NO;
	
	
	//网络未链接，重新连接
    self.reLinkView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
	
	UIImageView *_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,320,40)];
	_imageView.image = [StringUtil getImageByResName:@"no-connect-bj.png"];
    _imageView.alpha=0.4;
	[self.reLinkView addSubview:_imageView];
	[_imageView release];
	
	UIButton*reLinkButton=[[UIButton alloc]initWithFrame:CGRectMake(240, 5, 60, 30)];
    [reLinkButton setTitle:@"重新连接" forState:UIControlStateNormal];
    [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    reLinkButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [reLinkButton addTarget:self action:@selector(reLinkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.reLinkView addSubview:reLinkButton];
    [reLinkButton release];
    [self.view addSubview:self.reLinkView];
    self.reLinkView.hidden=YES;

	self.tempTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, MAX_WIDTH, 0)];
	self.tempTextView.font = [UIFont systemFontOfSize:message_font];
	[self.view addSubview:self.tempTextView];
	
	self.curOfflineMsgs = [NSMutableArray array];
	
	self.convRecordArray = [NSMutableArray array];
     */
}

#pragma mark - 刷新中英文
- (void)refreshViews{
    [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio"] forState:UIControlStateNormal];
    [(UILabel *)[talkIconView viewWithTag:11] setText:[StringUtil getLocalizableString:@"chats_talksession_message_audio_cancel"]];
    [(UILabel *)[talkIconWarningView viewWithTag:11] setText:[StringUtil getLocalizableString:@"chats_talksession_message_audio_too_short"]];
}

-(void)dismissListenMode
{

    listenModeView.hidden=YES;

}
/*
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueS,
                                       const void                *inPropertyValue
                                       ) {
    
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    // Determines the reason for the route change, to ensure that it is not
    //      because of a category change.
    CFDictionaryRef routeChangeDictionary = inPropertyValue;
    
    CFNumberRef routeChangeReasonRef =
    CFDictionaryGetValue (routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        NSLog(@"－－－－拨出耳机");
    }
}
*/
- (void)pageTurn:(UIPageControl *)PageControl
{
   
    int secondPage = [PageControl currentPage];
    faceScrollview.contentOffset=CGPointMake(320*secondPage, 0);
    
}
-(void)dismissSelf:(NSNotification *)notification
{
	NSLog(@"talk session dismiss");
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark 文字消息处理
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"---here--textViewDidBeginEditing");
    iconButton.tag=1;
    picButton.tag=1;
    [iconButton setImage:[StringUtil getImageByResName:@"facepic_ico.png"] forState:UIControlStateNormal];
    float height=footerView.frame.size.height;
    NSLog(@"%f height",height);

}
- (void)textViewDidEndEditing:(UITextView *)textView
{
//    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
//    //  pboard.string = self.text;
//    NSLog(@"---here--textViewDidChange--- %@",pboard.string);

}
/*
- (void)textViewDidChange:(UITextView *)textView
{
//	NSLog(@"%s,%@",__FUNCTION__,NSStringFromCGSize(textView.contentSize));
  
    if (textView.text==nil||textView.text.length==0) {
        textView.text=@" ";
       
    }
    NSString *endstr=[textView.text substringFromIndex:textView.text.length-1];
//    NSLog(@"%s,%@",__FUNCTION__,endstr);
    if (self.talkType==mutiableType&&[endstr isEqualToString:@"@"]&&self.message_len<textView.text.length) {
         self.message_len=textView.text.length;
        chooseTipViewController *chooseTip=[[chooseTipViewController alloc]init];
        chooseTip.predelegate=self;
        chooseTip.dataArray=[_ecloud getChooseTipEmp:self.convId];
        [self.navigationController pushViewController:chooseTip animated:YES];
        [chooseTip release];
    }
    CGSize size = [[textView text] sizeWithFont:[textView font]];
//    footerView.backgroundColor=[UIColor redColor];
//    subfooterView.backgroundColor=[UIColor greenColor];
//    NSLog(@"--footerView-heigh %0.0f --subfooterView %0.0f",footerView.frame.origin.y,subfooterView.frame.origin.y);
    // 2. 取出文字的高度
    int length = size.height;
    
    float contentHeight = [talkSessionUtil measureHeightOfUITextView:textView];
    
    //3. 计算行数
    int colomNumber = contentHeight/length;
 
    if (colomNumber<4) {
        
        float theight=self.messageTextField.frame.size.height;
        float suby=subfooterView.frame.origin.y;
        if (theight!=contentHeight) {
            NSLog(@"--colom--%d-----height--%f ",colomNumber,contentHeight);
			float height=footerView.frame.size.height;
            float width=footerView.frame.size.width;
            float fx=footerView.frame.origin.x;
            float fy=footerView.frame.origin.y;
            footerView.frame=CGRectMake(fx, fy-(contentHeight-theight), width, height+(contentHeight-theight));

            subfooterView.frame=CGRectMake(0, suby+(contentHeight-theight), width, 260);
            self.messageTextField.frame=CGRectMake(messageTextField_x,5, messageTextField_width, contentHeight);
            
            if (colomNumber==3) {
                self.messageTextField.contentSize=CGSizeMake(messageTextField_width, contentHeight+1);
            }
			
		}
    }else if(colomNumber>3)
    {
//        NSLog(@"----footerView.frame--x--%f --y-%f --width--%f ---height--%f",footerView.frame.origin.x,footerView.frame.origin.y,footerView.frame.size.width,footerView.frame.size.height);
//        NSLog(@"----subfooterView--x--%f --y-%f --width--%f ---height--%f",subfooterView.frame.origin.x,subfooterView.frame.origin.y,subfooterView.frame.size.width,subfooterView.frame.size.height);
//        NSLog(@"----self.messageTextField----------height- %f",self.messageTextField.frame.size.height);
      
         float fy=footerView.frame.origin.y;
        if(fy==200)
        {
			fy=200-70+34;
		}
        else
		{
			if (subfooterView.frame.origin.y!=36)
			{
				fy=fy-(36-subfooterView.frame.origin.y);
			}
        }
        footerView.frame=CGRectMake(0, fy, 320, 346);
        subfooterView.frame=CGRectMake(0, 36, 320, 260);
        self.messageTextField.frame=CGRectMake(messageTextField_x,5, messageTextField_width, 70);

        
        if(IOS8_OR_LATER)
        {
            float textfieldX = self.messageTextField.frame.origin.x;
            [self.messageTextField setContentOffset:CGPointMake(0.0, contentHeight-78) animated:NO];
        }

        
        float textFieldX = self.messageTextField.frame.origin.x;
//        CGPointMake(textFieldX, contentHeight-70.0)
        [self.messageTextField setContentOffset:CGPointMake(0.0, contentHeight-70.0) animated:YES];

    }
    
    if ([textView.text isEqualToString:@" "]) {
        textView.text=@"";
        
    }
    self.message_len = textView.text.length;
}
*/

- (void)textViewDidChange:(UITextView *)textView
{
    //	NSLog(@"%s,%@",__FUNCTION__,NSStringFromCGSize(textView.contentSize));
    
    if (textView.text==nil||textView.text.length==0) {
        textView.text=@" ";
        
    }
    NSString *endstr=[textView.text substringFromIndex:textView.text.length-1];
    //    NSLog(@"%s,%@",__FUNCTION__,endstr);
    if (self.talkType==mutiableType&&[endstr isEqualToString:@"@"]&&self.message_len<textView.text.length) {
        self.message_len=textView.text.length;
        chooseTipViewController *chooseTip=[[chooseTipViewController alloc]init];
        chooseTip.predelegate=self;
        chooseTip.dataArray=[_ecloud getChooseTipEmp:self.convId];
        [self.navigationController pushViewController:chooseTip animated:NO];
        [chooseTip release];
    }
    CGSize size = [[textView text] sizeWithFont:[textView font]];
    //    footerView.backgroundColor=[UIColor redColor];
    //    subfooterView.backgroundColor=[UIColor greenColor];
    //    NSLog(@"--footerView-heigh %0.0f --subfooterView %0.0f",footerView.frame.origin.y,subfooterView.frame.origin.y);
    // 2. 取出文字的高度
    float length = size.height;
    
    float contentHeight = [talkSessionUtil measureHeightOfUITextView:textView];
    
    //3. 计算行数
    int colomNumber = contentHeight/length;
    
    if (colomNumber<4) {
        
        float theight=self.messageTextField.frame.size.height;
        float suby=subfooterView.frame.origin.y;
        if (theight!=contentHeight) {
            NSLog(@"--colom--%d-----height--%f ",colomNumber,contentHeight);
            float height=footerView.frame.size.height;
            float width=footerView.frame.size.width;
            float fx=footerView.frame.origin.x;
            float fy=footerView.frame.origin.y;
        
                footerView.frame=CGRectMake(fx, fy-(contentHeight-theight), width, height+(contentHeight-theight));
                
                subfooterView.frame=CGRectMake(0, suby+(contentHeight-theight), width, 260);
                self.messageTextField.frame=CGRectMake(messageTextField_x,5, messageTextField_width, contentHeight);
            
            if(colomNumber == 2 )
            {
                float textfieldX = self.messageTextField.frame.origin.x;
                [self.messageTextField setContentOffset:CGPointMake(0.0, contentHeight-50) animated:NO];
                self.messageTextField.contentSize=CGSizeMake(messageTextField_width, contentHeight-1);

            }
            if (colomNumber==3)
            {
                float textfieldX = self.messageTextField.frame.origin.x;
                [self.messageTextField setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
                self.messageTextField.contentSize=CGSizeMake(messageTextField_width, contentHeight+1);
            }
        }
    }else if(colomNumber>3)
    {
        //        NSLog(@"----footerView.frame--x--%f --y-%f --width--%f ---height--%f",footerView.frame.origin.x,footerView.frame.origin.y,footerView.frame.size.width,footerView.frame.size.height);
        //        NSLog(@"----subfooterView--x--%f --y-%f --width--%f ---height--%f",subfooterView.frame.origin.x,subfooterView.frame.origin.y,subfooterView.frame.size.width,subfooterView.frame.size.height);
        //        NSLog(@"----self.messageTextField----------height- %f",self.messageTextField.frame.size.height);
        
        float fy=footerView.frame.origin.y;
        if(fy==200)
        {
            fy=200-70+34;
        }
        else
        {
            if (subfooterView.frame.origin.y!=36)
            {
                fy=fy-(36-subfooterView.frame.origin.y);
            }
        }
        footerView.frame=CGRectMake(0, fy, 320, 346);
        subfooterView.frame=CGRectMake(0, 36, 320, 260);
        self.messageTextField.frame=CGRectMake(messageTextField_x,5, messageTextField_width, 70);
        
        float textfieldX = self.messageTextField.frame.origin.x;
        [self.messageTextField setContentOffset:CGPointMake(0.0, contentHeight-78) animated:NO];
    }

    
    if ([textView.text isEqualToString:@" "]) {
        textView.text=@"";
    }
    self.message_len = textView.text.length;
}


#pragma mark 下拉加载历史记录
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {//顶部下拉
    
    //    如果已经加载的记录和总记录数相同，则返回
    if (scrollView.contentOffset.y < 0) {
        if(self.convRecordArray.count + self.unloadQueryResultArray.count >= totalCount)
        {
            return;
        }
        //offset为0，表示已经没有历史记录，那么不处理;
        //	NSLog(@"%s,offset is %d",__FUNCTION__,offset);
        if(offset == 0) {
            return;
        }
        //	NSLog(@"%.0f",scrollView.contentOffset.y);
        if (scrollView.contentOffset.y<0 && !isLoading ) {
            isLoading = true;
            loadingIndic.hidden = NO;
            [loadingIndic startAnimating];
            [self performSelector:@selector(getHistoryRecord) withObject:nil afterDelay:0.5];
            return;
        }
    }
    else
    {
        //    从没有加载的数据列加载一部分数据到数据源
        if (self.unloadQueryResultArray.count > 0)
        {
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            
            if (offset.y + bounds.size.height - inset.bottom - inset.top > size.height && !isLoading) {
                
                NSLog(@"加载没有加载的聊天记录");
                isLoading = true;
                
                //    这里不加载所有的，只加载一部分，每次加载条数，并且记录未加载的记录
                int _count = self.unloadQueryResultArray.count;
                
                NSArray *thisLoadArray;
                
                if (_count > num_of_load_search_result) {
                    thisLoadArray = [self.unloadQueryResultArray subarrayWithRange:NSMakeRange(0, num_of_load_search_result)];
                    self.unloadQueryResultArray = [NSMutableArray arrayWithArray:[self.unloadQueryResultArray subarrayWithRange:NSMakeRange(num_of_load_search_result, _count - num_of_load_search_result)]];
                }
                else
                {
                    thisLoadArray = [NSArray arrayWithArray:self.unloadQueryResultArray];
                    [self.unloadQueryResultArray removeAllObjects];
                }
                
                //            原有的记录数
                int loadCount = self.convRecordArray.count;
                
                [self.convRecordArray addObjectsFromArray:thisLoadArray];
                
                for (int _index = loadCount; _index < self.convRecordArray.count; _index ++) {
                    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
                    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
                    [self setTimeDisplay:_convRecord andIndex:_index];
                }
                
                [self.chatTableView reloadData];
                
                isLoading = false;
            }
        }
    }
}

-(void)hideLoadingCell
{
	loadingIndic.hidden = YES;
	[loadingIndic stopAnimating];
	isLoading = false;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{//底部上拖
	pageControl.currentPage=scrollView.contentOffset.x/320;
 
}

- (void)getHistoryRecord
{
    
    //	总数量
    totalCount =  [self getConvRecordCountBy:self.convId];
    //已经加载数量
    loadCount = self.convRecordArray.count + self.unloadQueryResultArray.count;
    
    if(totalCount > (loadCount + num_convrecord))
    {
        limit = num_convrecord;
        offset = totalCount - (loadCount + num_convrecord);
    }
    else
    {
        limit =totalCount - loadCount;
        offset = 0;
    }
    //	NSLog(@"%s,totalCount is %d,loadCount is %d",__FUNCTION__,totalCount,loadCount);
    //	NSLog(@"get history record limit is %d,offset is %d",limit,offset);
    
    NSArray *recordList = [_ecloud getConvRecordBy:self.convId andLimit:limit andOffset:offset];
    
    
    
    int count=[recordList count];
    
    for (int i=count-1; i>=0; i--)
    {
        ConvRecord *record =[recordList objectAtIndex:i];
        [self.convRecordArray insertObject:record atIndex:0];
    }
    for(int i = 0;i<recordList.count;i++)
    {
        ConvRecord *_convRecord = [recordList objectAtIndex:i];
        [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
        [self setTimeDisplay:_convRecord andIndex:i];
    }
    
    float oldh = self.chatTableView.contentSize.height;
    
    [self.chatTableView reloadData];
    
    [self hideLoadingCell];
    float newh=self.chatTableView.contentSize.height;
    self.chatTableView.contentOffset=CGPointMake(0, newh-oldh-20);
}

#pragma mark 获取该会话的聊天记录
-(void)getRecordsByConvId
{
	totalCount = [self getConvRecordCountBy:self.convId];
	if(totalCount > num_convrecord)
	{
		limit = num_convrecord;
		offset = totalCount - num_convrecord;
	}
	else {
		limit = totalCount;
		offset = 0;
	}
    NSArray *recordList= [self getConvRecordBy:self.convId andLimit:limit andOffset:offset];
	[self.convRecordArray addObjectsFromArray:recordList];
	for(int i=0;i<self.convRecordArray.count;i++)
	{
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
		[talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
        [self setTimeDisplay:_convRecord andIndex:i];
	}
    int count=[recordList count];
	
	[self.chatTableView reloadData];
//    每屏显示记录数
	int recordCountOfPage = 5;
	
    if (count>0)
	{
//		默认是最下面
		int _index = [self.convRecordArray count] ;
		if(self.unReadMsgCount >= 10)
		{
//			显示第一条
			_index = 0;
		}
		else if(self.unReadMsgCount >= recordCountOfPage)
		{
//			定位在未读的记录
			_index = _index - (self.unReadMsgCount - recordCountOfPage);
		}
		
//		NSLog(@"%s,_index is %d",__FUNCTION__,_index);
		if(self.talkType == massType)
		{
			[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]
									  atScrollPosition: UITableViewScrollPositionBottom
											  animated:NO];

		}
		else
		{
			[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]
									  atScrollPosition: UITableViewScrollPositionBottom
											  animated:NO];			
		}
    }
    [self initDraft];
}

- (void)initDraft
{
    self.messageTextField.text = [self getLastInputMsgByConvId:self.convId];
    self.message_len=self.messageTextField.text.length;
    if (self.message_len>0 && ![self.messageTextField isHidden]) {
        [self.messageTextField becomeFirstResponder];
    }
//	[self textViewDidChange:self.messageTextField];
    [self setFooterView];
}


-(void)tableBackGroudAction:(id)sender
{
    tableBackGroudButton.hidden=YES;
    picButton.tag=1;
   
    if(self.messageTextField.isFirstResponder){
        [self.messageTextField resignFirstResponder];
    }
    else{
     [self autoMovekeyBoard:0];
    }
 }

#pragma mark ==============================键盘处理========================================
- (void)keyboardWillShow:(NSNotification *)notification {
    
 //   NSLog(@"---keyboardWillShow");
      /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    copyType=-1;
    //[self autoMovekeyBoard:keyboardRect.size.height];
    NSString *heightstr=[NSString stringWithFormat:@"%0.0f",keyboardRect.size.height];
    [self performSelector:@selector(latershow:) withObject:heightstr afterDelay:0.2];
}
-(void)latershow:(NSString *)keyboardRect
{
     [self autoMovekeyBoard:keyboardRect.floatValue];
}

- (void)keyboardWillHide:(NSNotification *)notification {
//     NSLog(@"---keyboardWillHide");
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    copyType=-1;
    [self autoMovekeyBoard:0];
 
}

-(void) autoMovekeyBoard: (float) h{
    //  NSLog(@"%s, h is %.0f",__FUNCTION__,h);
    if (h>0) {
        tableBackGroudButton.hidden=NO;
    }else
    {
        tableBackGroudButton.hidden=YES;
    }
    
    int tableH = 370;
    if(iPhone5)
        tableH = tableH + i5_h_diff;
    
    
    //    NSLog(@"%s,self.view.frame.size.height is %.0f",__FUNCTION__,self.view.frame.size.height);
    
    float footerY = self.view.frame.size.height - 45 - h - (self.messageTextField.frame.size.height-34);// (float)(480.0-h-108.0+44-(self.messageTextField.frame.size.height-34));
    //	if(iPhone5)
    //		footerY = footerY + i5_h_diff;
    
    //	if(self.tabBarController && 	!self.tabBarController.tabBar.hidden)
    //	{
    //		NSLog(@"self.tabBarController && 	!self.tabBarController.tabBar.hidden");
    //		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
    //		footerY = footerY + _tabBar.frame.size.height;
    //	}
    
    if (isEmtiom) {
        isEmtiom = NO;
    }
    else{
        footerView.frame = CGRectMake(0.0f, footerY, 320.0f, 260.0f+50);
        self.chatTableView.frame=CGRectMake(0, 0, 320,tableH-h);
        
        NSLog(@"%s,footerView.frame.y is %.0f",__FUNCTION__, footerView.frame.origin.y);
        if([self.convRecordArray count] > 1)
        {
            [self scrollToEnd];
        }
    }
}

#pragma mark ======================================================================

-(void)removeSubViewFromShowViewContext
{
	NSArray *viewsToRemove = [faceScrollview subviews];
	for (UIView *v in viewsToRemove) {
		[v removeFromSuperview];
		//[v release];
	}
	
	
}

-(void)updateScrollview
{
    [self removeSubViewFromShowViewContext];
    int y=0;
	
    int bint=[self.phraseArray count];
    int rownum=0;
    if (bint%8!=0) {
        rownum=bint/8+1;
    }else {
        rownum=bint/8;
    }
	int sumindex=bint;
    for (int r=0; r<rownum; r++) {
        
		
		int row=r;
		int arrayindex=row*8;
		
		y=40*(r%4)+10;
        
		//UITextField *imageview;
        UIImageView *imgv;
        UIButton *iconBtn;
		for (int i=0; i<8; i++) {
			
			if (arrayindex<sumindex) {
                //------------------------------------------------------------------------
                CGRect imageValueRect=CGRectMake(320*(r/4)+5+40*i,y, 30,30);
                iconBtn=[[UIButton alloc]initWithFrame:imageValueRect];
                [iconBtn addTarget:self action:@selector(choosefacePic:)  forControlEvents:UIControlEventTouchUpInside];
                iconBtn.titleLabel.text=@"0";
                iconBtn.tag=arrayindex;
               // NSDictionary *item=[picArray objectAtIndex:arrayindex];
				CGRect imageValueRect1=CGRectMake(0, 0, 30, 30);
				imgv=[[UIImageView alloc]initWithFrame:imageValueRect1];
				//imgv.contentMode=UIViewContentModeScaleAspectFit;
               // NSString *str=[NSString stringWithFormat:@"%d.png",arrayindex];
				
                NSMutableDictionary *tempdic = [self.phraseArray objectAtIndex:arrayindex];
                
                UIImage *tempImage = [tempdic valueForKey:[NSString stringWithFormat:@"[/%@]",[self.bqStrArray objectAtIndex:arrayindex]]];// [NSString stringWithFormat:@"[/%03d]",arrayindex+1]];
                imgv.image=tempImage;
               // imgv.image=[StringUtil getImageByResName:str];
                //imgv.image=[UIImage imageWithData:[item objectForKey:@"pic"]];
                [iconBtn addSubview:imgv];
                [faceScrollview addSubview:iconBtn];
                [imgv release];
                [iconBtn release];
			}
			
			arrayindex++;
		}
    }
	
    int page=0;
    if (rownum%4!=0) {
        page=rownum/4+1;
    }else {
        page=rownum/4;
    }
	[faceScrollview setContentSize:CGSizeMake(page*320, y+10)];

   
	pageControl.currentPage=0;
	pageControl.numberOfPages=page;
}

#pragma mark －－－－－－－－－－－选择表情
-(void)choosefacePic:(id)sender
{
  //  if ([self.messageTextField.text length]>0) {
       self.messageString =[NSMutableString stringWithFormat:@"%@",self.messageTextField.text];
   // }
   
    
    UIButton *tempbtn = (UIButton *)sender;
    
    BOOL clearClick = NO;
    int bqPage = (self.bqStrArray.count)/32;
    
    for (int i=0; i<bqPage;i++) {
        if (tempbtn.tag == (31+32*i)) {
            clearClick = YES;
        }
    }
    
    if (clearClick)
    {
        if (self.messageString.length>0) {
            NSString *tempStr = [self.messageString substringFromIndex:self.messageString.length-1];
            
            //表情的结尾@"]"
            if ([tempStr isEqualToString:@"]"])
                {
                
                //从末尾检索表情的开始@"[/"
                NSRange range =  [self.messageString rangeOfString:@"[/" options:NSBackwardsSearch];
                    
                if (range.location != NSNotFound )
                {
                    //截取@"[/"与@"]"之间的字符串
                    NSString *tempMessageString = [self.messageString substringWithRange:NSMakeRange(range.location+2, self.messageString.length-range.location-3)];
                    BOOL isMyBQ = NO;
                    
                    for (NSMutableString *bqStr in self.bqStrArray)
                    {
                        if ([bqStr isEqualToString:tempMessageString])
                        {
                            self.messageString = [self.messageString substringToIndex:range.location];
                            isMyBQ = YES;
                        }
                    }
                    if (!isMyBQ)
                    {
                        self.messageString = [self.messageString substringToIndex:(self.messageString.length-1)];
                    }
                }
                else
                {
                    self.messageString = [self.messageString substringToIndex:(self.messageString.length-1)];
                }
                
            }
            else
            {
                self.messageString = [self.messageString substringToIndex:(self.messageString.length-1)];
            }
        }

    }else
    {
        NSMutableDictionary *tempdic = [self.phraseArray objectAtIndex:tempbtn.tag];
        NSArray *temparray = [tempdic allKeys];
        NSString *faceStr= [NSString stringWithFormat:@"%@",[temparray objectAtIndex:0]];
        
        self.phraseString = faceStr;
        [self.messageString appendString:self.phraseString];
  
    }
    self.messageTextField.text=self.messageString;
    self.messageTextField.selectedRange = NSMakeRange([self.messageString length],0);
    [self textViewDidChange:self.messageTextField];
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    pageControl.currentPage=scrollView.contentOffset.x/320;
//    
//}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage_Click:nil];
      //  footerView.frame=CGRectMake(0, 415, 320, 50);
       // [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self sendMessage_Click:nil];
//    footerView.frame=CGRectMake(0, 415, 320, 50);
//    [textField resignFirstResponder];
//    return YES;
//}
//-(void)othertextFieldDidChange:(id)sender
//{
//  
//    footerView.frame=CGRectMake(0, 200, 320, 260);
//    iconButton.tag=1;
//    [iconButton setImage:[StringUtil getImageByResName:@"facepic_ico.png"] forState:UIControlStateNormal];
//}
#pragma  mark 表情切换
-(void)moodIconAction:(id)sender
{
    addScrollview.hidden=YES;
    talkButton.tag=1;
     picButton.tag=1;
    [talkButton setImage:[StringUtil getImageByResName:@"speaking_ico.png"] forState:UIControlStateNormal];
    pressButton.hidden=YES;
    self.messageTextField.hidden=NO;
    UIButton * button=(UIButton *)sender;
    int index=button.tag;
    if (index==1) {
        button.tag=2;
        [button setImage:[StringUtil getImageByResName:@"Keyboard_ios.png"] forState:UIControlStateNormal];
        
        if ([self.messageTextField  isFirstResponder]) {
            isEmtiom = YES;
            [self.messageTextField resignFirstResponder];
        }
		
		int footerY =  self.view.frame.size.height - 216 - 45 -  (self.messageTextField.frame.size.height-34);//200-(self.messageTextField.frame.size.height-34);
//		if(iPhone5)
//			footerY = footerY + i5_h_diff;
        footerView.frame=CGRectMake(0,footerY, 320, 260+50);
		
        tableBackGroudButton.hidden=NO;
		int tableH = 154;
		if(iPhone5)
			tableH = tableH + i5_h_diff;
		
        self.chatTableView.frame=CGRectMake(0, 0, 320, tableH);
        if ([self.convRecordArray count]>0) {
			[self scrollToEnd];
        }
        [self textViewDidChange:self.messageTextField];
        [self.messageTextField setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];//设置UITextView的内边距
        [self.messageTextField setTextAlignment:NSTextAlignmentLeft];//并设置左对齐

    }else
    {
        button.tag=1;
        [button setImage:[StringUtil getImageByResName:@"facepic_ico.png"] forState:UIControlStateNormal];
       //footerView.frame=CGRectMake(0, 415, 320, 50);
        [self.messageTextField becomeFirstResponder];
        [self textViewDidChange:self.messageTextField];
    }
}


#pragma  mark 选择 照片，拍照，日程，等等
-(void)chooseItemAction:(id)sender
{
    addScrollview.hidden=NO;
    talkButton.tag=1;
    [talkButton setImage:[StringUtil getImageByResName:@"speaking_ico.png"] forState:UIControlStateNormal];
    pressButton.hidden=YES;
    self.messageTextField.hidden=NO;
    
//    点击后 都变成表情按钮
    [iconButton setImage:[StringUtil getImageByResName:@"facepic_ico.png"] forState:UIControlStateNormal];
    iconButton.tag = 1;
    UIButton * button=(UIButton *)sender;
    int index=button.tag;
    if (index==1) {
        button.tag=2;
       
        if ([self.messageTextField  isFirstResponder]) {
            isEmtiom = YES;
            [self.messageTextField resignFirstResponder];
        }
		
//		int footerY =  self.view.frame.size.height - 216 -(addScrollview.contentSize.height-110.0)- 45 -  (self.messageTextField.frame.size.height-34);//200-(self.messageTextField.frame.size.height-34);
//        //		if(iPhone5)
//        //			footerY = footerY + i5_h_diff;
//        footerView.frame=CGRectMake(0,footerY+100, 320, 260+50);
//		
//        tableBackGroudButton.hidden=NO;
//		int tableH = 154+100;
//		if(iPhone5)
//			tableH = tableH + i5_h_diff-(addScrollview.contentSize.height-110.0);

        
        
//        		if(iPhone5)
//        			footerY = footerY + i5_h_diff;

        int footerY =  self.view.frame.size.height - 216 - 45 -  (self.messageTextField.frame.size.height-34);//200-(self.messageTextField.frame.size.height-34);
        //		if(iPhone5)
        //			footerY = footerY + i5_h_diff;

        footerView.frame=CGRectMake(0,footerY, 320, 260+50);
        
        tableBackGroudButton.hidden=NO;


        int tableH = 154;
        if(iPhone5)
            tableH = tableH + i5_h_diff;
     

        self.chatTableView.frame=CGRectMake(0, 0, 320, tableH);
        if ([self.convRecordArray count]>0) {
			[self scrollToEnd];
        }
        [self textViewDidChange:self.messageTextField];
        [self.messageTextField setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];//设置UITextView的内边距
        [self.messageTextField setTextAlignment:NSTextAlignmentLeft];//并设置左对齐
        

    }else
    {
        button.tag=1;
        //footerView.frame=CGRectMake(0, 415, 320, 50);
        [self.messageTextField becomeFirstResponder];
        [self textViewDidChange:self.messageTextField];
    }

}



#pragma mark ----发送文本消息
-(IBAction)sendMessage_Click:(id)sender
{
//	长消息的最多字符个数是15000个
	NSString *message = self.messageTextField.text;
//	NSLog(@"------ message   %@",message);
//	文本消息长度超过780，就按照长消息发送
	int msgLen = [StringUtil getMsgLen:message];
	if(msgLen > 780)
	{
		if(message.length > 15000)
		{
			message = [message substringToIndex:15000];
		}
		[self displayAndUploadLongMsg:message];
	}
	else
	{		
		[self sendMessage:type_text message:message filesize:-1 filename:nil andOldMsgId:nil];
	}

     NSString *lastinputstr=@"";
    [self updateLastInputMsgByConvId:self.convId LastInputMsg:lastinputstr];
}

#pragma mark - ----重置输入框
-(void)resetInput
{
    CGRect messageRect = self.messageTextField.frame;
    CGFloat messageSizeY = messageRect.size.height;
    CGFloat changeSizeY = messageSizeY - 34;
    
    self.messageTextField.frame = CGRectMake(messageTextField_x, 4, self.messageTextField.frame.size.width, 34);
    
    float theight=self.messageTextField.frame.size.height;
    float suby=subfooterView.frame.origin.y;
//    if (theight!=self.messageTextField.contentSize.height) {
        float height=footerView.frame.size.height;
        float width=footerView.frame.size.width;
        float fx=footerView.frame.origin.x;
        float fy=footerView.frame.origin.y;
        footerView.frame=CGRectMake(fx, fy+changeSizeY, width, height-changeSizeY);
        
        subfooterView.frame=CGRectMake(0, suby-changeSizeY, width, 260);
//    }
    
}

#pragma mark 文本消息发送给服务器后，显示在聊天界面中
-(void)addAndDisplayTextMessage:(NSString *)message andMsgId:(int)msgId
{
	ConvRecord *convRecord = [self getConvRecordByMsgId:[StringUtil getStringValue:msgId]];
	[self addOneRecord:convRecord andScrollToEnd:true];
    
    self.messageTextField.text = @" ";
    //    [self textViewDidChange:self.messageTextField];
    //    self.messageTextField.text = @"";
    [self performSelector:@selector(clearUpText) withObject:nil afterDelay:0.1];
}
-(void)clearUpText
{
    [self textViewDidChange:self.messageTextField];
    self.messageTextField.text = @"";
}
#pragma mark 输入文本信息，单击发送，以及图片或录音传输成功后，通过此方法，发出消息，主要是数据库操作和发送到服务器

-(void)sendMessage:(int)iMsgType message:(NSString *)messageStr filesize:(int)fsize filename:(NSString *)fname andOldMsgId:(NSString*)oldMsgId
{
//    把两边的空格去掉先
    if (messageStr)
    {
        messageStr = [StringUtil trimString:messageStr];
    }
//	判断消息是否为空
    if (messageStr == nil || [messageStr length] ==0)
    {
		return;
    }
	
	bool result = true;
	
	NSDictionary *dic;
	
    int nowtimeInt= [_conn getCurrentTime];
	NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
	
	//		信息类型
	NSString *msgType = [StringUtil getStringValue:iMsgType];
	
	//		信息类型为发送信息
	NSString *msgFlag = [StringUtil getStringValue:send_msg];
	
	//		发送状态为正在发送
	NSString *sendFlag = [StringUtil getStringValue:sending];
	
	//		如果是单人会话 或者 是已经创建的多人会话 或者是群发会话或者是收到的一呼万应消息
	if(self.talkType == singleType || (self.talkType == mutiableType && self.last_msg_id != -1) || self.talkType == massType || self.talkType == rcvMassType)
	{
		if(self.talkType == singleType)
		{
			[self createSingleConversation];
		}
		
//		增加会话记录到会话表
        NSString * msgId = oldMsgId;
//		如果是文本消息那么要发送到服务器的消息id，是通过addConvRecord得到的
//		如果是图片消息，那么这个msgid，是需要查询出来的
		NSString *sendMsgId = nil;
        if (oldMsgId == nil)
		{
			NSDictionary *_dic;
//			文本消息
			if(self.talkType == massType)
			{
				dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",nil];
				_dic = [massDAO addConvRecord:dic];
			}
			else
			{
				dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:receiptMsgFlag],@"receipt_msg_flag", nil];
				_dic =[_ecloud addConvRecord:[NSArray arrayWithObject:dic]];
				
			}

         	if(_dic)
			{
//				添加数据库成功
				msgId = [_dic valueForKey:@"msg_id"];
				sendMsgId = [_dic valueForKey:@"origin_msg_id"];
			}
			else
			{
				msgId = nil;
			}
        }

		if(msgId != nil)
		{
			if(self.talkType == massType)//发送一呼万应消息
			{
				//				发送文本消息，无论发送成功与否，都提示正在发送
				if(iMsgType == type_text)
				{
					[self addAndDisplayTextMessage:messageStr andMsgId:msgId.intValue];
				}
					
				ConvRecord *_convRecord = [self getConvRecordByMsgId:msgId];
				NSLog(@"%@",_convRecord);
				[_conn sendMassMsg:self.convEmps andConvRecord:_convRecord];
			}
			else
			{
				if(iMsgType == type_text)
				{
					//				发送文本消息，无论发送成功与否，都提示正在发送
					[self addAndDisplayTextMessage:messageStr andMsgId:msgId.intValue];
					[_conn sendMsg:self.convId andConvType:self.talkType andMsgType:type_text andMsg:messageStr andMsgId:[sendMsgId longLongValue]  andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
				}
				//			需要增加一个长消息类型
				else if(iMsgType == type_long_msg)
				{
					//				查询数据库，发出长消息，长消息的头保存在数据库的文件名称列
					ConvRecord *_convRecord = [self  getConvRecordByMsgId:oldMsgId];
					sendMsgId = [NSString stringWithFormat:@"%lld",_convRecord.origin_msg_id];
					NSString * convIdOfMsg = _convRecord.conv_id;
					NSString *messageHead = _convRecord.file_name;
					[_conn sendLongMsg:convIdOfMsg andConvType:_convRecord.conv_type andMsgType:iMsgType andFileSize:fsize andMessageHead:messageHead andFileUrl:messageStr andMsgId:[sendMsgId longLongValue] andTime:nowtimeInt andReceiptMsgFlag:_convRecord.receiptMsgFlag];
				}
				else
				{
					//		如果是录音或图片，存在这种情况，还未上传成功，就退出，进入其他会话，这时convId就不同了，所以发送非图片消息时，会话id是消息对应的会话id
					ConvRecord *_convRecord = [self  getConvRecordByMsgId:oldMsgId];
					sendMsgId = [NSString stringWithFormat:@"%lld",_convRecord.origin_msg_id];
					NSString * convIdOfMsg = _convRecord.conv_id;
					
					[_conn sendMsg:convIdOfMsg andConvType:_convRecord.conv_type andMsgType:iMsgType andFileSize:fsize andFileName:_convRecord.file_name andFileUrl:_convRecord.msg_body andMsgId:[sendMsgId longLongValue] andTime:nowtimeInt andReceiptMsgFlag:_convRecord.receiptMsgFlag];
				}
			}
		}
	}
	else
	{
		if(self.talkType == mutiableType && self.last_msg_id==-1)
		{
			//				首先创建群组，成功后再发送消息
			[[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
			[[LCLLoadingView currentIndicator]show];
			
			self.firstMsgId = oldMsgId;
			self.firstMsgStr = messageStr;
			self.firstMsgType = iMsgType;
			self.firstFileSize = fsize;
			self.firstFileName = fname;
			
			if(iMsgType == type_pic)
			{
				messageStr = [StringUtil getLocalizableString:@"msg_type_pic"];
			}
			else if(iMsgType == type_record)
			{
				messageStr = [StringUtil getLocalizableString:@"msg_type_record"];
			}
			else if(iMsgType == type_long_msg)
			{
//				长消息对应的消息头
				ConvRecord *_convRecord = [self  getConvRecordByMsgId:oldMsgId];
				messageStr = _convRecord.file_name;
//				便于显示title
				self.firstFileName = messageStr;
			}
			else
			{
				messageStr = [[MessageView getMessageView] replaceFaceStrWithText:messageStr] ;
                
                helperObject *hobject=[_ecloud getTheDateScheduleByGroupID:self.convId];
                if (hobject) {
                    messageStr=hobject.helper_name;
                }
                
//                messageStr 作为群组名称，长度不能超过群组名称的最大长度
                NSString *newGrpName = [StringUtil getNewGrpName:messageStr];
                messageStr = [NSString stringWithFormat:@"%@",newGrpName];
                NSLog(@"---here-messagestr--- %@",messageStr);
//                if (messageStr.length>15) {
//                    messageStr=[messageStr substringToIndex:15];
//                }
			}
           
			if(![_conn createConversation:self.convId andName:messageStr andEmps:self.convEmps])
			{
				result = false;
			}
		}
	}
	
	if(!result)
	{
		[[LCLLoadingView currentIndicator]hiddenForcibly:true];
	}
}
#pragma mark 对图片，录音的特殊处理
-(NSString *)addMediaRecord:(int)iMsgType message:(NSString *)messageStr filesize:(int)fsize filename:(NSString *)fname
{
    //	判断消息是否为空
    if (messageStr == nil || [messageStr length] ==0)
    {
		return nil;
    }
	
	if(self.talkType == singleType)
	{		
		[self createSingleConversation];
	}
	NSDictionary *dic;
    int nowtimeInt= [_conn getCurrentTime];
	NSString *nowTime =[NSString stringWithFormat:@"%d",nowtimeInt];
	
	//		信息类型
	NSString *msgType = [StringUtil getStringValue:iMsgType];
	
	//		信息类型为发送信息
	NSString *msgFlag = [StringUtil getStringValue:send_msg];
	
	//		发送状态为正在上传
	NSString *sendFlag = [StringUtil getStringValue:send_uploading];
	
	NSDictionary *_dic;
	if(self.talkType == massType)//群发消息
	{
		dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:fsize],@"file_size",fname,@"file_name",nil];
		
		_dic = [massDAO addConvRecord:dic];
	}
	else
	{
		dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:fsize],@"file_size",fname,@"file_name", [StringUtil getStringValue:receiptMsgFlag],@"receipt_msg_flag",nil];
		_dic =  [_ecloud addConvRecord:[NSArray arrayWithObject:dic]];
	}
	NSString * msgId = nil;
	if(_dic)
	{
		msgId = [_dic valueForKey:@"msg_id"];
	}
	return msgId;
}


#pragma mark 获取图片的方式
-(void)picAction:(id)sender
{
//    if(_conn.userStatus == status_offline)
//	{
//		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"现在处于离线状态\n请设置为上线后再操作" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//		[alert show];
//		[alert release];
//		//return;
//	}
    [self.messageTextField resignFirstResponder];
    [self presentPicSheet];
  
    
}
- (void) presentPicSheet
{
  
        choosePicMenu = [[UIActionSheet alloc]
                         initWithTitle: @" "
                         delegate:self
                         cancelButtonTitle:@"取消"
                         destructiveButtonTitle:nil
                         otherButtonTitles:@"拍照", @"从手机相册选择", nil];
  
   
    [choosePicMenu showInView:self.view];
}
-(void)popover:(id)sender
{
    //the controller we want to present as a popover
    audioTypeChooseViewController *controller = [[audioTypeChooseViewController alloc]init];
    if (popover==nil) {
        popover = [[FPPopoverController alloc] initWithViewController:controller];
        [controller release];
    }
    
    //popover.arrowDirection = FPPopoverArrowDirectionAny;
    popover.tint = FPPopoverLightGrayTint;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popover.contentSize = CGSizeMake(300, 500);
    }
    popover.arrowDirection = FPPopoverArrowDirectionDown;
    
    //sender is the UIButton view
    [popover presentPopoverFromView:sender];
}


- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
    [visiblePopoverController autorelease];
}
#pragma mark 切换到录音聊天方式
-(void)talkAction:(id)sender
{
    picButton.tag=1;
    UIButton * button=(UIButton *)sender;
    int index=button.tag;
    if (!receiptMsgFlagButton.hidden&&index==1) {
        [self popover:sender];
        return;
    }
    
    if (index==1) {
//        if(_conn.userStatus == status_offline)
//        {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"现在处于离线状态\n请设置为上线后再操作" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//            [alert release];
//           // return;
//        }
        button.tag=2;
//        [button setImage:[StringUtil getImageByResName:@"Writting_ico.png"] forState:UIControlStateNormal];
        // 统一切换到键盘的图标
        [button setImage:[StringUtil getImageByResName:@"Keyboard_ios.png"] forState:UIControlStateNormal];
        pressButton.hidden=NO;
        [self hideTextView];
        [self autoMovekeyBoard:0];
        
        //这时左边是键盘键 输入框右侧按钮变成表情键
        [iconButton setImage:[StringUtil getImageByResName:@"facepic_ico.png"] forState:UIControlStateNormal];
        iconButton.tag = 1;
        
    }else
    {
        button.tag=1;
        [button setImage:[StringUtil getImageByResName:@"speaking_ico.png"] forState:UIControlStateNormal];
        pressButton.hidden=YES;
        [self showTextView];
    }
    
    
}

//返回 按钮
/*
-(void) backButtonPressed:(id) sender
{
    _conn.curConvId = nil;
        //释放
    [KxMenu dismissMenu];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    self.isHaveBeingHere=NO;
    if (!longAudioView.hidden) {//取消 长语音
        [self longAudioCloseAction:nil];
    }
    
	if (self.fromType == 2)
    {
//        从会话的查询结果来的，所以只需要返回到上级界面即可
        self.fromType = 0;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.fromType == 3)
    {
        //从第三方应用直接进入返回
        self.fromType = 0;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.fromType == 4)
    {
        //从第三方应用选人发起会话返回
        self.fromType = 0;
        int index = 0;
        if ([[self.navigationController childViewControllers] count] > 2) {
            index = [[self.navigationController childViewControllers] count]-3;
        }
        [self.navigationController popToViewController:[[self.navigationController childViewControllers] objectAtIndex:index] animated:YES];
        return;
    }
    
	if(self.talkType == massType || self.fromType == 1)
	{//回到一呼万应的会话列表界面
		self.fromType = 0;
		for(UIViewController *controller in self.navigationController.viewControllers)
		{
			if([controller isKindOfClass:[broadcastViewController class]])
			{
				[self.navigationController popToViewController:controller animated:YES];
			}
		}
		return;
	}
	NSRange range = [self.convId rangeOfString:@"|"];
	if(range.length > 0)
	{
//		一呼万应的回复
		[self.navigationController popToRootViewControllerAnimated:YES];
		[[NSNotificationCenter defaultCenter ]postNotificationName:AUTO_SELECT_CONVERSATION_NOTIFICATION object:nil userInfo:nil];
	}
	else if(self.talkType == mutiableType && [[self.convId substringToIndex:1] isEqualToString:@"g"])
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
    
	else if(self.talkType == singleType || self.talkType == mutiableType)
	{
		[self.navigationController popToRootViewControllerAnimated:YES];
		[[NSNotificationCenter defaultCenter ]postNotificationName:AUTO_SELECT_CONVERSATION_NOTIFICATION object:nil userInfo:nil];
	}

}
*/

-(void) backButtonPressed:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)rightButtonPress:(id)sender
{
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *subViewController in array) {
        if ([subViewController isKindOfClass:[chatMessageViewController class]]) {
            [self.navigationController popToViewController:subViewController animated:YES];
        }
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ------------------隐藏或显示文本框的处理------------------
- (void)hideTextView{
    self.messageTextField.hidden=YES;
    [self.messageTextField resignFirstResponder];
    [self setFooterView];
}

- (void)showTextView{
    self.messageTextField.hidden=NO;
    [self setFooterView];
    [self.messageTextField becomeFirstResponder];
}

- (void)setFooterView{
    if ([self.messageTextField isHidden]) {
        float footerY = footerView.frame.origin.y;
        
        if (self.messageTextField.frame.size.height > 34) {
            footerY = footerY + self.messageTextField.frame.size.height-34;
        }
        
        footerView.frame=CGRectMake(0, footerY, 320, 50);
        subfooterView.frame=CGRectMake(0, 0, 320, 260);
        self.messageTextField.frame=CGRectMake(messageTextField_x,5, messageTextField_width, 34);
    }
    else{
        [self textViewDidChange:self.messageTextField];
    }
}


#pragma mark -----------------------------

#pragma mark =====table delegate======
//add by lyong  2012-6-19
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(self.talkType == massType)
	{
		return self.convRecordArray.count + 1;
	}
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(self.talkType == massType)
	{
		return 1;
	}
	return [self.convRecordArray count] + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.talkType == massType)
	{
		if(indexPath.section == 0)
		{
			return 40;
		}
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:indexPath.section - 1];
		if(_convRecord.msg_type == type_group_info)
		{
			return [GroupInfoCell cellHeight:_convRecord];
		}
		if(_convRecord.msg_type == type_pic)
		{
			return [MassPicCell cellHeight:_convRecord];
		}
		if(_convRecord.msg_type == type_record)
		{
			return [MassRecordCell cellHeight:_convRecord];
		}
		if(_convRecord.msg_type == type_long_msg)
		{
			return [LongMsgCell cellHeight:_convRecord];
		}
		return [MassTextCell cellHeight:_convRecord];
	}
//	//	update by shisp	  第一行显示加载提示框
	if(indexPath.row == 0)
		return 40;
	
	int row = [indexPath row] - 1;
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:row];
	
	float cellHeight = [talkSessionUtil getMsgBodyHeight:_convRecord];
    
    //    如果下一条消息需要显示时间，那么就增加多一些，否则少一些
    if (row == (self.convRecordArray.count - 1)) {
        cellHeight = cellHeight + msg_to_msg_space_of_same_time;
    }else{
        _convRecord = self.convRecordArray[row + 1];
        if (_convRecord.isTimeDisplay) {
            cellHeight = cellHeight + msg_to_msg_space_of_diff_time;
        }else{
            cellHeight = cellHeight + msg_to_msg_space_of_same_time;
        }
    }

    
	return cellHeight ;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.talkType != massType)
	{
		int row = indexPath.row;
		if(row > 0 && self.convRecordArray.count > 0 && (row < self.convRecordArray.count))
		{
			ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:row-1];
			if(_convRecord.isDownLoading && _convRecord.downloadRequest)
			{
				if(_convRecord.msg_type == type_pic || _convRecord.msg_type == type_file)
				{
					[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,@"正在下载，需要解除DownloadProgressDelegate"]];
					[_convRecord.downloadRequest setDownloadProgressDelegate:nil];
				}
			}
		}
	}
}

//不显示默认的背景
- (void)removeBackground:(UITableViewCell *)cell
{
    [UIAdapterUtil removeBackground:cell];
}

- (void)customCellBackground:(UITableView *)tableView andCell:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    [UIAdapterUtil customCellBackground:tableView andCell:cell andIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%s, section is %d , row is %d , count is %d ",__FUNCTION__,indexPath.section,indexPath.row,self.convRecordArray.count);
//    update by shisp
    if (self.talkType == massType)
    {
        if (IOS7_OR_LATER)
        {
//            都不显示背景
            [self removeBackground:cell];
//                对于mass消息，需要定制背景
            if (indexPath.section > 0 && indexPath.section <= self.convRecordArray.count)
            {
                ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:indexPath.section - 1];
                if(_convRecord.msg_type == type_group_info)
                {
                    
                }
                else
                {
                    [self customCellBackground:tableView andCell:cell andIndexPath:indexPath];
                }
            }
        }
        else
        {
//第一个section显示的是加载提示，不需要背景
            if (indexPath.section == 0)
            {
                [self removeBackground:cell];
            }
            else
            {
//                如果是分组通知消息，不需要背景
                if (indexPath.section > 0 && indexPath.section <= self.convRecordArray.count)
                {
                    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:indexPath.section - 1];
                    if(_convRecord.msg_type == type_group_info)
                    {
                        [self removeBackground:cell];
                    }
                }
//                其他消息采用默认的背景
            }
        }
        
    }
//    因为和普通的聊天界面同用一个类，所以如果是普通的聊天界面，则不显示背景，也不需要添加定制其他的背景
    else
    {
        [self removeBackground:cell];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(self.talkType == massType)
	{
		if(section == 0) return 0;
		if(section > 0 && section <= self.convRecordArray.count)
		{
			ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:section - 1];
			if(_convRecord.msg_type == type_group_info)
			{
				return 0;
			}
			return 30;
		}
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(self.talkType == massType)
	{
		if(section == 0) return nil;
		if(section > 0 && section <= self.convRecordArray.count)
		{
			ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:section - 1];
			if(_convRecord.msg_type == type_group_info)
			{
				return nil;
			}
			if(_convRecord.isTimeDisplay)
			{
				DateCell *dateCell = [[[DateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
				[dateCell configureCell:_convRecord];
				return dateCell.contentView;
			}
			return nil;
		}
	}
	return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(IOS_VERSION_BEFORE_6 && self.talkType != massType)
	{
		NSArray *indexPaths = [tableView indexPathsForVisibleRows];
		int count = indexPaths.count;
		if(count > 1)
		{
			int minIndex = [[indexPaths objectAtIndex:0]row] - 1;
			int maxIndex = [[indexPaths objectAtIndex:(count - 1)]row] - 1;
			for(int i = self.convRecordArray.count - 1;i>=0;i--)
			{
				if(i > maxIndex || i < minIndex)
				{
					ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
					if(_convRecord.isDownLoading && _convRecord.downloadRequest)
					{
						if(_convRecord.msg_type == type_pic || _convRecord.msg_type == type_file)
						{
							[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,@"正在下载，需要解除DownloadProgressDelegate"]];
							[_convRecord.downloadRequest setDownloadProgressDelegate:nil];
						}
					}
				}
			}
		}
	}
	
	//		add by shisp第一行显示为加载提示框
	if((self.talkType == massType && indexPath.section == 0) || (self.talkType != massType && indexPath.row == 0))
	{
		UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
		[cell addSubview:loadingIndic];
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	if(self.talkType == massType)
	{
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:indexPath.section - 1];
		if(_convRecord.msg_type == type_group_info)
		{
            static NSString *group_info_cell_id = @"group_info_cell_id";
            GroupInfoCell *cell = (GroupInfoCell*)[tableView dequeueReusableCellWithIdentifier:group_info_cell_id];
            if(cell == nil)
            {
                cell = [[[GroupInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:group_info_cell_id]autorelease];
            }
            [cell configureCell:_convRecord];
			return cell;
		}
		else if(_convRecord.msg_type == type_text)
		{
			static NSString *mass_text_cell_id = @"mass_text_cell_id";
			MassTextCell *cell = [tableView dequeueReusableCellWithIdentifier:mass_text_cell_id];
			if(cell == nil)
			{
				cell = [[[MassTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mass_text_cell_id]autorelease];
				[self addSingleTapToReplyLabelOfCell:cell];
			}
			
			[cell configureCell:_convRecord];
			[self processSpinnerOfCell:cell andConvRecord:_convRecord];
			return cell;
		}
		else if(_convRecord.msg_type == type_pic)
		{
			static NSString *mass_pic_cell_id = @"mass_pic_cell_id";
			MassPicCell *cell = [tableView dequeueReusableCellWithIdentifier:mass_pic_cell_id];
			if(cell == nil)
			{
				cell = [[MassPicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mass_pic_cell_id];
				[self addSingleTapToReplyLabelOfCell:cell];
				[self addSingleTapToPicViewOfCell:cell];
			}
			[cell configureCell:_convRecord];
			[self processSpinnerOfCell:cell andConvRecord:_convRecord];
			return cell;
		}
		else if(_convRecord.msg_type == type_record)
		{
			static NSString *mass_record_msg_id = @"mass_record_msg_id";
			MassRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:mass_record_msg_id];
			if(cell == nil)
			{
				cell = [[MassRecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mass_record_msg_id];
				[self addSingleTapToReplyLabelOfCell:cell];
				[self addPlayAudioToCell:cell];
			}
			[cell configureCell:_convRecord];
			return cell;
		}
		else if(_convRecord.msg_type == type_long_msg)
		{
			static NSString *long_msg_cell_id = @"long_msg_cell_id";
			LongMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:long_msg_cell_id];
			if(cell == nil)
			{
				cell = [[LongMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:long_msg_cell_id];
				[self addSingleTapToReplyLabelOfCell:cell];
			}
			[cell configureCell:_convRecord];
			return cell;
		}
	}
	
	{
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:indexPath.row - 1];
        
        UITableViewCell *cell = [self getMsgCell:tableView andRecord:_convRecord];// nil;
         		
		[talkSessionUtil configureCell:cell andConvRecord:_convRecord];
		
		//	状态按钮
		UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
		UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
		
		//		如果是发送的消息，并且发送状态是上传成功后发送中或上传中，那么显示正在发送
		if(_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading))
		{
			spinner.hidden = NO;
			[spinner startAnimating];
		}
		else
		{
			[spinner stopAnimating];
		}
		
		//		如果是发送的消息，并且发送状态是上传失败，那么显示发送失败按钮，点击后可以重新发送
		if(_convRecord.msg_flag == send_msg && _convRecord.send_flag == send_upload_fail)
		{
			//			发送失败
			failButton.hidden=NO;
		}
        else
        {
            failButton.hidden = YES;
        }
		
		//	消息内容
		switch(_convRecord.msg_type)
		{
			case type_file:
			{
                if(!_convRecord.isFileExists)
                {
                    //下载文件
                    if(_convRecord.isDownLoading)
                    {
                        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
                        [talkSessionUtil displayProgressView:_progressView];
                        if(_convRecord.downloadRequest)
                        {
                            [_convRecord.downloadRequest setDownloadProgressDelegate:_progressView];
                        }						
                    }
                }
                else{
                    if (_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading)) {
                        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
                        [talkSessionUtil displayProgressView:_progressView];
                    }
                }
                
                [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
			}
				break;
			case type_pic:
			{
				if(!_convRecord.isBigPicExist)
				{
					if(!_convRecord.isSmallPicExist)
					{
						if(!_convRecord.isDownLoading)
						{
							_convRecord.isDownLoading = true;
							[self autoDownloadSmallPic:cell andConvRecord:_convRecord];
						}
						else
						{
							[spinner startAnimating];
						}
					}
					else
					{
						UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
						if(_convRecord.isDownLoading)
						{
							[talkSessionUtil displayProgressView:progressview];
							if(_convRecord.downloadRequest)
							{
								[_convRecord.downloadRequest setDownloadProgressDelegate:progressview];
							}
						}
					}
				}
                else{
                    if (_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading)) {
                        UILabel *_progressView = [cell.contentView  viewWithTag:pic_progress_Label_tag];
                        _progressView.hidden = NO;
                    }
                }
			}
				break;
            case type_video:
            {
                [talkSessionUtil sendReadNotice:_convRecord];
                
                if(!_convRecord.isVideoExist)
                {
                    if(_convRecord.isDownLoading)
                    {
                        [spinner startAnimating];
                    }
                    else
                    {
                        _convRecord.isDownLoading = true;
                        [self downloadResumeFile:_convRecord.msgId andCell:cell];
                        
                    }
                    if (_convRecord.downloadRequest && _convRecord.download_flag == state_downloading) {
                        //配置下载参数
                        UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:video_progress_tag];
                        [talkSessionUtil displayProgressView:_progressView];
                        _convRecord.downloadRequest.downloadProgressDelegate = _progressView;
                    }
                }
                else{
                    if (_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading)) {
                        if (_convRecord.uploadRequest) {
                            UIProgressView *_progressView = [cell.contentView  viewWithTag:video_progress_tag];
                            [talkSessionUtil displayProgressView:_progressView];
                            _convRecord.uploadRequest.uploadProgressDelegate = self;
                        }
                    }
                }
            }
                break;
			case type_record:
			{
				if(_convRecord.isAudioExist)
				{
//					[self addPlayAudioToCell:cell];
					//	如果是收到的消息，如果已经下载，并且还未读，那么显示红点，未读标志
					if(_convRecord.msg_flag == rcv_msg && _convRecord.is_set_redstate == 1 )
					{
						UIImageView *readImage=(UIImageView *)[cell.contentView viewWithTag:status_audio_tag];
						readImage.hidden = NO;
					}
				}
				else
				{
					if(_convRecord.send_flag == -1)
					{
						//					如果文件不存在，那么就不再下载
					}
					else
					{
						if(_convRecord.isDownLoading)
						{
							[spinner startAnimating];
						}
						else
						{
							_convRecord.isDownLoading = true;
                            if (maxSendFileSize == 20) {
                                [self downloadFile:_convRecord.msgId andCell:cell];
                            }
                            else{
                                [self downloadResumeFile:_convRecord.msgId andCell:cell];
                            }
						}
					}
				}
			}
				break;
			case type_long_msg:
			{
				if(!_convRecord.isLongMsgExist)
				{
					if(_convRecord.send_flag == -1)
					{
						//					如果文件不存在，那么就不再下载
					}
					else
					{
						if(_convRecord.isDownLoading)
						{
							[spinner startAnimating];
						}
						else
						{
							_convRecord.isDownLoading = true;
							[self downloadFile:_convRecord.msgId andCell:cell];
						}
					}
				}
				else
				{
					[talkSessionUtil sendReadNotice:_convRecord];
				}
			}
				break;
			case type_text:
			{
				[talkSessionUtil sendReadNotice:_convRecord];
			}
				break;
		}
		
		//	如果是自己发送的一呼百应可以查看已读情况统计
		UIImageView *receiptView = (UIImageView*)[cell.contentView viewWithTag:receipt_tag];
		if(_convRecord.msg_flag == send_msg && _convRecord.isReceiptMsg)
		{
			if(self.talkType == mutiableType)
			{
				receiptView.userInteractionEnabled = YES;
			}
			else if(self.talkType == singleType)
			{
				receiptView.userInteractionEnabled = NO;			
			}
		}
		else
		{
			receiptView.userInteractionEnabled = NO;		
		}
        
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//		点击后关闭键盘
	[self.messageTextField resignFirstResponder];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark===========================复制文本消息功能==================================
-(void)menuDisplay
{
	if(self.editMsgId && self.talkType != massType)
	{
		self.isDeleteAction = false;
		UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.editRow inSection:0]];
		UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
		if(bubbleView.hidden)
		{
			bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
		}
		bubbleView.highlighted = YES;
	}
}
-(void)menuHide
{
	if(self.talkType == massType)
	{
		if(self.editIndexPath && !self.isDeleteAction)
		{
			//		弹出菜单隐藏的时候，设置cell background color 为 clearcolor
			UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:self.editIndexPath];
            
            if (!IOS7_OR_LATER)
            {
                float r = 247/255.0;
                UIColor *_color = [UIColor colorWithRed:r green:r blue:r alpha:1];
                cell.backgroundColor = _color;
            }
		}
	}
	else
	{
		if(self.editMsgId && !self.isDeleteAction)
		{
			UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.editRow inSection:0]];
			UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
			if(bubbleView.hidden)
			{
				bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
			}
			bubbleView.highlighted = NO;
			self.editRecord = nil;
		}
	}
	self.editIndexPath = nil;
	self.editMsgId = nil;
	self.editRecord = nil;
	self.isDeleteAction = false;
}

#pragma mark 双击复制功能
-(void)doubleTapTableViewListener:(UITapGestureRecognizer *)gesture
{
	CGPoint p = [gesture locationInView:self.chatTableView];
	[self prepareToShowCopyMenu:p];
}
#pragma mark 长按复制功能
- (void) myHandleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
 	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) 
	{
		CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
		[self prepareToShowCopyMenu:p];
    }
}

-(void)prepareToShowCopyMenu:(CGPoint)p
{
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    NSString *pointY=[NSString stringWithFormat:@"%0.0f",p.y];
	if(indexPath)
	{
		if(self.talkType == massType)
		{
            if(indexPath.section == 0)
                return;
			self.editIndexPath = indexPath;
			self.editRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
		}
		else
		{
			//		点击位置对应的记录下标
			int _index = [indexPath row];
            if(_index == 0) return;
			ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index-1];
			
			self.editMsgId = [StringUtil getStringValue:_convRecord.msgId];
			self.editRecord = _convRecord;
			self.editRow = _index;
		}
		
		UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
		[cell becomeFirstResponder];
		[self performSelector:@selector(showCopyMenu:)withObject:[NSDictionary dictionaryWithObjectsAndKeys:cell,@"LONG_CLICK_CELL",pointY,@"pointY", nil] afterDelay:0.05f];
	}
}

#pragma mark  长按或双击可以复制消息文本功能
- (void)showCopyMenu:(id)dic
{
 	UITableViewCell *longClickCell =  (UITableViewCell*)[(NSDictionary *)dic objectForKey:@"LONG_CLICK_CELL"];

    /*
	if(self.talkType == massType)
	{
        if (!IOS7_OR_LATER)
        {
            float r = 239/255.0;
            UIColor *_color = [UIColor colorWithRed:r green:r blue:r alpha:1];
            longClickCell.backgroundColor = _color;
        }
	
		float menuX = 160;
		
		NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
		int menuY=[pointY intValue]-longClickCell.frame.origin.y;
		UIMenuController * menu = [UIMenuController sharedMenuController];
//        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(Forwarding:)];
//        [menu setMenuItems:[NSArray arrayWithObjects:menuItem,nil]];
//        [menuItem release];
		[menu setTargetRect: CGRectMake(menuX , menuY, 1, 1) inView: longClickCell];
		[menu setMenuVisible: YES animated: YES];
	}
	else
	{
		UIImageView *bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_send_tag];
		if(bubbleView.hidden)
		{
			bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_rcv_tag];
		}
		NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
		float copyX;
		if(self.editRecord.msg_flag == rcv_msg)
		{
			copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width / 2 + 5;
		}
		else
		{
			copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width/2 - 5;
		}
		
		int copyY=[pointY intValue]-longClickCell.frame.origin.y;
		UIMenuController * menu = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"forward"] action:@selector(Forwarding:)];
        [menu setMenuItems:[NSArray arrayWithObjects:menuItem,nil]];
        [menuItem release];
		[menu setTargetRect: CGRectMake(copyX , copyY, 1, 1) inView: longClickCell];
		[menu setMenuVisible: YES animated: YES];
	}
     */
    
    
    if(self.talkType == massType)
	{
        if (!IOS7_OR_LATER)
        {
            float r = 239/255.0;
            UIColor *_color = [UIColor colorWithRed:r green:r blue:r alpha:1];
            longClickCell.backgroundColor = _color;
        }
        
		float menuX = 160;
		
		NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
		int menuY=[pointY intValue]-longClickCell.frame.origin.y;
		UIMenuController * menu = [UIMenuController sharedMenuController];
  
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"copy"] action:@selector(copyAction:)];
        UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"delete"] action:@selector(deleteAction:)];
        UIMenuItem *menuItem4 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"paste"] action:@selector(pasteAction:)];
        
        [menu setMenuItems:[NSArray arrayWithObjects:menuItem,menuItem2,menuItem4,nil]];
        
		[menu setTargetRect: CGRectMake(menuX , menuY, 1, 1) inView: longClickCell];
		[menu setMenuVisible: YES animated: YES];
	}
	else
	{
		UIImageView *bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_send_tag];
		if(bubbleView.hidden)
		{
			bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_rcv_tag];
		}
		NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
		float copyX;
		if(self.editRecord.msg_flag == rcv_msg)
		{
			copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width / 2 + 5;
		}
		else
		{
			copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width/2 - 5;
		}
		
		int copyY=[pointY intValue]-longClickCell.frame.origin.y;
		UIMenuController * menu = [UIMenuController sharedMenuController];
        
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"copy"] action:@selector(copyAction:)];
        UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"delete"] action:@selector(deleteAction:)];
        UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"forward"] action:@selector(Forwarding:)];
        UIMenuItem *menuItem4 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"paste"] action:@selector(pasteAction:)];
        UIMenuItem *menuItem5 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"download"] action:@selector(downloadAction:)];
        
        [menu setMenuItems:[NSArray arrayWithObjects:menuItem,menuItem2,menuItem3,menuItem4,menuItem5,nil]];
        [menuItem release];
        [menuItem2 release];
        [menuItem3 release];
        [menuItem4 release];
        [menuItem5 release];
        
		[menu setTargetRect: CGRectMake(copyX , copyY, 1, 1) inView: longClickCell];
		[menu setMenuVisible: YES animated: YES];
	}
}

#pragma mark 只提供复制功能
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;
    
    if (action == @selector(Forwarding:))
    {
        // 图片和文本
        if(self.editRecord && (self.editRecord.msg_type == type_text || self.editRecord.msg_type == type_long_msg || self.editRecord.msg_type == type_pic || editRecord.msg_type == type_file))
        {
            retValue = YES;
        }
        else
        {
            retValue = NO;
        }
#ifdef _LANGUANG_FLAG_
        
        if (self.editRecord.redPacketModel) {
            
            return NO;
        }
        
#endif
    }
    else if (action == @selector(sendCopyPic:))
    {
       retValue = NO;
    }
    else if (action == @selector(copyAction:))
    {
//		图片和文本
        if(self.editRecord && (self.editRecord.msg_type == type_text || self.editRecord.msg_type == type_long_msg || self.editRecord.msg_type == type_pic))
        {
           retValue = YES;
        }else
        {
           retValue = NO;
        }
#ifdef _LANGUANG_FLAG_
        if (self.editRecord.redPacketModel) {
            return NO;
        }
#endif
    }
    else if(action == @selector(deleteAction:))
	{
		if(self.editRecord && self.editRecord.msg_type != type_group_info)
		{
			return YES;
		}
		else
		{
			return NO;
		}  
    }
	else if(action == @selector(pasteAction:))
    {
         retValue = NO;
    }
    else if(action == @selector(downloadAction:))
    {
        if(self.editRecord && self.editRecord.msg_type == type_file)
        {
            if (self.editRecord.isFileExists) {
                 retValue = NO;
            }
            else if(self.editRecord.isDownLoading) {
                 retValue = NO;
            }
            else{
                 retValue = YES;
            }
        }
        else{
           retValue = NO;
        }
    }
    else
    {
//        retValue = [super canPerformAction:action withSender:sender];
         retValue = NO;
    }
    
    return retValue;
}


- (void)willPresentAlertView:(UIAlertView *)alertView
{
    CGRect frame = alertView.frame;
    if( alertView==picCopyAlert )
    {
        frame.origin.y = 120;
        frame.size.height =200;
        alertView.frame = frame;
        for( UIView * view in alertView.subviews )
        {
            //列举alertView中所有的对象
            if( ![view isKindOfClass:[UILabel class]] )
            {
                //若不UILable则另行处理
                if (view.tag==1)
                {
                    //处理第一个按钮，也就是 CancelButton
                    CGRect btnFrame1 =CGRectMake(30, frame.size.height-65, 105, 40);
                    view.frame = btnFrame1;
                    
                } else if (view.tag==2){
                    //处理第二个按钮，也就是otherButton 
                    CGRect btnFrame2 =CGRectMake(142, frame.size.height-65, 105, 40);
                    view.frame = btnFrame2; 
                }
            }
        }
    }
}

#pragma mark 如果复制的是图片，那么需要弹框预览图片
-(void)alertSendCopyPic:(UIImage *)image
{
    if (image==nil) {
        return;
    }
    //    先对图片进行压缩
    CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
    if(_size.width > 0 && _size.height > 0)
    {
        image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
    }
    
    Class alertClass = NSClassFromString(@"UIAlertController");
    
    //    如果是ios8则使用新的方式显示复制的图片
    if (alertClass)
    {
        NSString *msg = @"\n\n\n\n\n\n\n\n";
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"复制图片" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIImageView *copyImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(80, 60, 120, 120)]autorelease];
        copyImageView.contentMode=UIViewContentModeScaleAspectFit;
        copyImageView.image = image;
        [controller.view addSubview:copyImageView];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //                                                                  do nothing
                                                             }];
        [controller addAction:cancelAction];
        
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //                                                                  发送图片
                                                                  if (image)
                                                                  {
                                                                      NSData *data = UIImageJPEGRepresentation(image,0.5);
                                                                      [self displayAndUploadPic:data];
                                                                  }
                                                              }];
        [controller addAction:confirmAction];
        
        [self presentViewController:controller animated:YES completion:nil];
        
        return;
    }
    
    if (picCopyAlert==nil)
    {
        picCopyAlert=[[UIAlertView alloc]initWithTitle:@"复制图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
        picCopyImageView=[[[UIImageView alloc]initWithFrame:CGRectMake(80, 10, 120, 120)]autorelease];
        picCopyImageView.contentMode=UIViewContentModeScaleAspectFit;
        
        if([self deviceVersion] < 7.0)
        {
            [picCopyAlert setTitle:nil];
            [picCopyAlert addSubview:picCopyImageView];
        }
        else
        {
            [picCopyAlert setValue:picCopyImageView forKey:@"accessoryView"];
        }
    }
    picCopyImageView.image=image;
    
    [picCopyAlert show];
    
}

//估计已经没有使用
-(void)pasteAction:(id)sender
{
//    NSLog(@"---here--paste--");
    //if (copyType==1) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"  " message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
        [alert show];
        [alert release];
   // }
}
#pragma mark 转发
-(void)Forwarding:(id)sender //转发
{
    if(self.editRecord)
	{
		self.messageTextField.copypic=false;
		BOOL isForwarding=YES;
		NSString *copyStr = self.editRecord.msg_body;
		if(self.editRecord.msg_type == type_long_msg)
		{
			NSString *fileName = [NSString stringWithFormat:@"%@.txt",copyStr];
			NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
			copyStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
		}
		else if(self.editRecord.msg_type == type_pic)
		{
			NSString *fileName = [NSString stringWithFormat:@"%@.png",copyStr];
			NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
			
			UIImage *img = [UIImage imageWithContentsOfFile:filePath];
			if (img!=nil)
			{
				self.messageTextField.copypic=true;
				copyStr = filePath;
			}
			else
			{
				copyStr = @"";
//				UIAlertView *tempalert=[[UIAlertView alloc]initWithTitle:@"不能转发" message:@"此图片未下载，请先点击下载" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//				[tempalert show];
//				[tempalert release];
                [self downloadFile:self.editRecord.msgId andCell:nil];
                self.forwardRecord = self.editRecord;
//                [self enterLargePhotoesViewWithCurrentConvRecord:self.editRecord];
                isForwarding=NO;
			}
		}
        else if(self.editRecord.msg_type == type_file)
		{
            
            float maxSendFileSize = [UserDefaults getMaxSendFileSize];
            float fileSize = [self.editRecord.file_size integerValue]/(1024.0*1024);
            
            if (fileSize > maxSendFileSize &&  maxSendFileSize > 0) {
                //大于文件最大允许发送时提示
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil  getLocalizableString:@"file_send_max_size"] delegate:nil cancelButtonTitle:[StringUtil  getLocalizableString:@"confirm"] otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            
            
            NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:self.editRecord]];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                self.messageTextField.copypic=true;
				copyStr = filePath;
            }
            else if(self.editRecord.isDownLoading) {
                isForwarding=NO;
            }
            else{
                copyStr = @"";
//				UIAlertView *tempalert=[[UIAlertView alloc]initWithTitle:@"不能转发" message:@"此文件未下载，请先点击下载" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//				[tempalert show];
//				[tempalert release];

                [self downloadFile:self.editRecord.msgId andCell:nil];
                self.forwardRecord = self.editRecord;
                isForwarding=NO;
            }
		}
		
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setString:copyStr];
        if (isForwarding) {
            //转发，使用
            self.forwardRecord = self.editRecord;
            [self menuHide];
            [self openRecentContacts];
        }
	}
}

- (void)copyAction:(id)sender
{
//    update by shisp 如果复制的是文本或者长消息，那么把文本放到pasteboard；如果是图片，那么把图片放到pasteboard中
	if(self.editRecord)
	{
		self.messageTextField.copypic=false;
		
		NSString *copyStr = self.editRecord.msg_body;
		if(self.editRecord.msg_type == type_long_msg)
		{
			NSString *fileName = [NSString stringWithFormat:@"%@.txt",copyStr];
			NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
			copyStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
		}
		else if(self.editRecord.msg_type == type_pic)
		{
			NSString *fileName = [NSString stringWithFormat:@"%@.png",copyStr];

			NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
			
			UIImage *img = [UIImage imageWithContentsOfFile:filePath];
			if (img!=nil)
			{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setImage:img];
 				self.messageTextField.copypic=true;
 			}
			else
			{
                copyStr = @"";
//				UIAlertView *tempalert=[[UIAlertView alloc]initWithTitle:@"不能复制" message:@"此图片未下载，请先点击下载" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//				[tempalert show];
//				[tempalert release];
                [self enterLargePhotoesViewWithCurrentConvRecord:self.editRecord];
			}
		}
//        如果是复制图片，已经把图片放到了粘贴板中，当不是复制图片时，才保存文本到粘贴板中 update by shisp
        
        if (!self.messageTextField.copypic) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:copyStr];
        }
        
 	}
}

-(void)deleteAction:(id)sender
{
	self.isDeleteAction = true;
	
	NSString *deleteMsgId = [StringUtil getStringValue:self.editRecord.msgId];
	if(self.talkType == massType)
	{
		[massDAO deleteOneMsg:deleteMsgId];
	}
	else
	{
		[_ecloud deleteOneMsg:deleteMsgId];
        
//        如果有文件在下载，那么从文件列表中移除，并且取消下载
        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:deleteMsgId.intValue];

	}
 
	int _index = [self getArrayIndexByMsgId:deleteMsgId.intValue];
	if(_index >= 0)
	{
		[self.convRecordArray removeObjectAtIndex:_index];
		[self.chatTableView reloadData];
	}
}

- (void)downloadAction:(id)sender{
    if(self.editRecord)
    {
       ConvRecord *_convRecord = self.editRecord;
        
        self.messageTextField.copypic=false;
        NSString *copyStr = self.editRecord.msg_body;
        if(_convRecord.msg_type == type_file){
            if(_convRecord.isDownLoading){
                return;
            }
            
            int netType = [ApplicationManager getManager].netType;
            if(netType == type_gprs && [_convRecord.file_size intValue] > 1024*1024)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[NSString stringWithFormat:@"%@【%@】?", [StringUtil  getLocalizableString:@"confirm_to_download_file"],_convRecord.fileNameAndSize] delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
                alert.tag = download_file_tag;
                UILabel *msgIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                msgIdLabel.text = [NSString stringWithFormat:@"%d",_convRecord.msgId];
                msgIdLabel.tag = download_file_msg_id_tag;
                [alert addSubview:msgIdLabel];
                
                [msgIdLabel release];
                
                [alert show];
                [alert release];
            }
            else
            {
                [self downloadFile:_convRecord.msgId andCell:nil];
            }
        }
    }
}

#pragma mark===========================录音消息相关代码==================================
-(void)addPlayAudioToCell:(UITableViewCell*)cell
{
	UIButton *clickButton = (UIButton*)[cell.contentView viewWithTag:audio_tag];
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayAudio:)];
	[clickButton addGestureRecognizer:singleTap];
	[singleTap release];
}

#pragma mark 录音按钮相关事件 按住说话
-(IBAction)recordTouchDragOutside:(id)sender
{
//    NSLog(@"%s",__FUNCTION__);

     if (!recordPermissionUndetermined) {
         talkIconView.hidden=YES;
         talkIconCancelView.hidden=NO;
         pressButton.selected = YES;
         [(UILabel *)[talkIconCancelView viewWithTag:11] setText:[StringUtil getLocalizableString:@"chats_talksession_message_audio_cancel_tips"]];
     }
}
-(IBAction)recordTouchDragIn:(id)sender
{
//    NSLog(@"%s",__FUNCTION__);

    if (!recordPermissionUndetermined) {
        talkIconView.hidden=NO;
        talkIconCancelView.hidden=YES;
        pressButton.selected = NO;
    }
}
#pragma mark 按下录音按钮，开始录音
- (IBAction)recordTouchDown:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
    self.secondValue = 0;

//    /*
    recordPermissionUndetermined = YES;
    isFingureUp = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession  performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                NSLog(@"granted is yes");
                recordPermissionUndetermined = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startRecording];
                });
            }
            else {
                NSLog(@"granted is no");
                dispatch_async(dispatch_get_main_queue(), ^{
                    recordPermissionUndetermined = YES;
                    [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"chats_talksession_record_hint"]];
                });
            }
        }];
    }
    else{
        //不需要授权验证
        recordPermissionUndetermined = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startRecording];
        });
    }
}

//新增的方法，开始录音 by shisp
- (void)startRecording
{
    [self stopPlayAudio];

    if (!isFingureUp)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        backButton.enabled=NO;
        addButton.enabled=NO;
        picButton.enabled=NO;
        iconButton.enabled=NO;
        self.chatTableView.userInteractionEnabled=NO;
        
        talkIconView.hidden=NO;
        
        if([self startToRecord])
        {
            self.secondValue = 0;
            updateTimeLabel.text=[NSString stringWithFormat:@"0秒"];
            //        第一次0.5s后，secondValue就可以+1
            secondTimer=	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showSencond) userInfo:nil repeats:NO];
            NSLog(@"start second timer ");
        }
    }
    else
    {
        
    }

    NSLog(@"%s",__FUNCTION__);
}

#pragma mark 松开录音按钮，开始发送录音
- (IBAction)recordTouchUpInside:(id)sender
{
    isFingureUp = YES;
     if (!recordPermissionUndetermined) {
         talkIconCancelView.hidden=YES;
         backButton.enabled=YES;
         addButton.enabled=YES;
         picButton.enabled=YES;
         iconButton.enabled=YES;
         self.chatTableView.userInteractionEnabled=YES;
         
         talkIconView.hidden=YES;
         if (self.secondValue>=1)
         {
             [self endRecordAndSend];
             pressButton.selected = NO;
             
         }else
         {
             talkIconWarningView.hidden=NO;
             pressButton.userInteractionEnabled = NO;
             pressButton.selected = YES;
             [self performSelector:@selector(dismissTalkWarningAction:) withObject:nil afterDelay:1.0];
             [self endRecord];
         }
         
         [secondTimer invalidate];
         secondTimer=nil;
         
         NSLog(@"%s secondValue is %d",__FUNCTION__,self.secondValue);

     }
}

-(void)dismissTalkWarningAction:(id)sender{
    talkIconWarningView.hidden=YES;
    pressButton.userInteractionEnabled = YES;
    pressButton.selected = NO;
}

#pragma mark 取消录音
- (IBAction)recordTouchUpOutside:(id)sender
{
    NSLog(@"%s",__FUNCTION__);

    isFingureUp = YES;
    if (!recordPermissionUndetermined) {
        talkIconCancelView.hidden=YES;
        backButton.enabled=YES;
        addButton.enabled=YES;
        picButton.enabled=YES;
        iconButton.enabled=YES;
        pressButton.selected = NO;
        self.chatTableView.userInteractionEnabled=YES;
        
        talkIconView.hidden=YES;
        [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio"] forState:UIControlStateNormal];
        [self endRecord];
        [secondTimer invalidate];
        secondTimer=nil;
    }
}

#pragma mark 录音－－－－显示秒－－2012-12-5
-(void)showSencond
{
	self.secondValue++;
//    updateTimeLabel.text=[NSString stringWithFormat:@"%d秒",self.secondValue];
    updateTimeLabel.text = [NSString stringWithFormat:[StringUtil getLocalizableString:@"second"],self.secondValue];
    
    if (self.secondValue>59) {//录音限制60秒
        [self recordTouchUpInside:nil];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio_tips"] message:[StringUtil getLocalizableString:@"chats_talksession_message_audio_tips_title"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        [alert show];
        [alert release];
	}
    if (self.secondValue == 1) {
        //        如果已经是1s了，那么开启一个循环的timer,间隔是1s
        secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showSencond) userInfo:nil repeats:YES];
    }
}

#pragma mark ----开始录音－－－－－ record function
/*
- (bool)startToRecord
{
    if (audioRecoder==nil) {

	AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     self);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || UIUserInterfaceIdiomPad)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *error;
		
		if ([audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
		{
			if ([audioSession setActive:YES error:&error])
			{
				//        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
			}
			else
			{
				NSLog(@"Failed to set audio session category: %@", error);
			}
		}
		else
		{
			NSLog(@"Failed to set audio session category: %@", error);
		}
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride),&audioRouteOverride);
    }
        audioRecoder = [[CL_AudioRecorder alloc]init];
   
    }
    
     if (m_isRecording == NO)
    {

        m_isRecording = YES;
		
		NSString *nowTime = [StringUtil currentTime];
#if  TARGET_IPHONE_SIMULATOR
		self.curAudioName =[NSString stringWithFormat:@"%@.caf",nowTime];
#else
		self.curAudioName =[NSString stringWithFormat:@"%@.wav",nowTime];
#endif
        NSLog(@"%s,开始录音,name is %@",__FUNCTION__,self.curAudioName);
        
       NSString *recordAudioFullPath = [kRecorderDirectory stringByAppendingPathComponent:self.curAudioName];
        audioRecoder.recorderingPath = recordAudioFullPath;
        [audioRecoder startRecord];
//         [VoiceConverter changeStu];
        [VoiceConverter setRecordStatus:YES];
        
        //启动计时器
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(wavToAmrBtnPressed) object:nil];
        [recordQueue addOperation:operation];
        [operation release];
        
		return true;
    }
	else
	{
        NSLog(@"%s,没有启动录音",__FUNCTION__);

		return false;
	}
}
#pragma mark - wav转amr
- (void)wavToAmrBtnPressed{
    
    NSString *recordPath = [kRecorderDirectory stringByAppendingPathComponent:self.curAudioName];
    
    NSRange range = [self.curAudioName rangeOfString:@"." options:nil];
	NSString *nowTime = [self.curAudioName substringToIndex:range.location];
    NSString *amr_name=[NSString stringWithFormat:@"%@.amr",nowTime];
    NSString *audiopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:amr_name];
    int success=[VoiceConverter wavToAmr:recordPath amrSavePath:audiopath];
//    NSLog(@"%s,%@,%@",__FUNCTION__,recordPath,audiopath);

}
#pragma mark 录音结束，开始发送录音到文件服务器
- (void)endRecordAndSend
{
    m_isRecording = NO;
    dispatch_queue_t stopQueue;
    stopQueue = dispatch_queue_create("stopQueue", NULL);
    dispatch_async(stopQueue, ^(void){
        //run in main thread 
        dispatch_async(dispatch_get_main_queue(), ^{
  			NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:self.curAudioName,@"cur_audio_name",[StringUtil getStringValue:self.secondValue],@"cur_audio_second", nil];
 			[self performSelector:@selector(recordAudioForUpload:) withObject:_dic afterDelay:0.5];
          [audioRecoder stopRecord];
//          [VoiceConverter changeStu];
            [VoiceConverter setRecordStatus:NO];
            
        NSLog(@"%s",__FUNCTION__);

        });
    });
    dispatch_release(stopQueue);
    
}
#pragma mark 结束录音，但不发送
- (void)endRecord
{
    m_isRecording = NO;
    dispatch_queue_t stopQueue;
    stopQueue = dispatch_queue_create("stopQueue", NULL);
    dispatch_async(stopQueue, ^(void){
        //run in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [audioRecoder stopRecord];
//            [VoiceConverter changeStu];
            [VoiceConverter setRecordStatus:NO];
            NSLog(@"%s",__FUNCTION__);
        });
    });
    dispatch_release(stopQueue);
}

//#pragma mark 获取录音并上传录音 2012-11-15
//-(void)recordAudioForUpload:(NSDictionary*)_dic
//{
//    NSString *audioName = [NSString stringWithFormat:@"%@",[_dic valueForKey:@"cur_audio_name"]];
//	NSRange range = [audioName rangeOfString:@"." options:nil];
//	NSString *nowTime = [audioName substringToIndex:range.location];
//	
//	int second = [[_dic valueForKey:@"cur_audio_second"]intValue];
//	
//	NSString *recordPath = [kRecorderDirectory stringByAppendingPathComponent:audioName];
//	
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	if([fileManager fileExistsAtPath:recordPath] && [[NSData dataWithContentsOfFile:recordPath]length] > 0)
//	{
//		//		文件存在才增加消息记录并且上传
//		//	先保存录音消息，然后延迟上传
//		NSString *msgId = [self addMediaRecord:type_record message:nowTime filesize:second filename:audioName];
//		if(msgId)
//		{
//			//		生成录音view
//			ConvRecord *convRecord = [_ecloud getConvRecordByMsgId:msgId];
//			[self addOneRecord:convRecord andScrollToEnd:true];
//			
//			NSString *audiopath = [[StringUtil getFileDir] stringByAppendingPathComponent:audioName];
//			
//			NSError *error;
//			NSFileManager *fileMgr = [NSFileManager defaultManager];
//			if ([fileMgr moveItemAtPath:recordPath toPath:audiopath error:&error] != YES)
//			{
//				NSLog(@"Unable to move file: %@", [error localizedDescription]);
//			}
//			else
//			{
//				[self uploadFile:convRecord];
//			}
//		}
//	}
//}

-(void)recordAudioForUpload:(NSDictionary*)_dic
{
    NSString *audioName = [NSString stringWithFormat:@"%@",[_dic valueForKey:@"cur_audio_name"]];
	NSRange range = [audioName rangeOfString:@"." options:nil];
	NSString *nowTime = [audioName substringToIndex:range.location];
	
	int second = [[_dic valueForKey:@"cur_audio_second"]intValue];
	
	NSString *recordPath = [kRecorderDirectory stringByAppendingPathComponent:audioName];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:recordPath] && [[NSData dataWithContentsOfFile:recordPath]length] > 0)
	{
//		文件存在才增加消息记录并且上传
		//	先保存录音消息，然后延迟上传
        NSString *amr_name=[NSString stringWithFormat:@"%@.amr",nowTime];
        NSString *audiopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:amr_name];
        
        // 录音文件小于200b 提示用户重新发送
        folderSizeAndList *_fsl = [[folderSizeAndList alloc]init];
        long long fileByte = [_fsl fileSizeAtPath:audiopath];
        [_fsl release];
        
        if (fileByte < 200)
        {
            [fileManager removeItemAtPath:audiopath error:nil];
            NSLog(@"%s,audiopath is %@,file size is %llu",__FUNCTION__,audiopath,fileByte);
            
            return;
        }
        
		NSString *msgId = [self addMediaRecord:type_record message:nowTime filesize:second filename:amr_name];
		if(msgId)
		{
			//		生成录音view
			ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
			[self addOneRecord:convRecord andScrollToEnd:true];
			NSFileManager *fileMgr = [NSFileManager defaultManager];
	       if ([fileMgr fileExistsAtPath:audiopath]) {
             [self uploadFile:convRecord];
           }else
           {
              NSLog(@"amr not exsit");
           }
        }
	}
}
*/
#pragma mark 点击播放 录音 2011-11-15 add by lyong
-(void)startPlayAudio:(UITapGestureRecognizer *)gestureRecognizer
{
	CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
	 NSLog(@"CGPoint--x %f y %f--- row  %d",p.x,p.y,indexPath.row);
	
	int _index = indexPath.row - 1;
	if(self.talkType == massType)
	{
		_index = indexPath.section - 1;
	}
	
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];

	UIButton * button=(UIButton *)(((UITapGestureRecognizer*)gestureRecognizer).view);
    button.alpha=0.5;
    [self performSelector:@selector(setAlphaToView:) withObject:button afterDelay:0.3];
	
	if(!_convRecord.isAudioExist)
		return;
	
	NSString *pathStr=[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
	
	self.isAudioPause = false;
   
	if(self.curRecordPath && [pathStr isEqualToString:self.curRecordPath])
	{
		self.isAudioPause = true;
        
		if([self stopPlayAudio])
			return;
	}
	
	[self stopPlayAudio];
	
	[self playAudioAtIndexPath:indexPath];
}

#pragma mark 播放某一行的录音文件，播放单个录音和连续播放录音时调用 add by shisp
-(void)playAudioAtIndexPath:(NSIndexPath*)indexPath
{
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
	UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
	UIImageView *playaudioview=(UIImageView *)[cell.contentView viewWithTag:audio_playImageView_tag];
	NSString *pathStr=[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
	self.curRecordPath = pathStr;
    NSLog(@"self.curRecordPath-- %@ --- row  %d",pathStr,indexPath.row);
	if(_convRecord.msg_flag == send_msg)
	{
		if(self.talkType == massType)
		{
			playaudioview.image = rcvVoicePlayView.image;
			playaudioview.animationRepeatCount = rcvVoicePlayView.animationRepeatCount;
			playaudioview.animationImages = rcvVoicePlayView.animationImages;
			playaudioview.animationDuration = rcvVoicePlayView.animationDuration;
		}
		else
		{
			playaudioview.image = sendVoicePlayView.image;
			playaudioview.animationRepeatCount = sendVoicePlayView.animationRepeatCount;
			playaudioview.animationImages = sendVoicePlayView.animationImages;
			playaudioview.animationDuration = sendVoicePlayView.animationDuration;			
		}
	}
	else
	{
		playaudioview.image = rcvVoicePlayView.image;
		playaudioview.animationRepeatCount = rcvVoicePlayView.animationRepeatCount;
		playaudioview.animationImages = rcvVoicePlayView.animationImages;
		playaudioview.animationDuration = rcvVoicePlayView.animationDuration;
		
		int redstate=_convRecord.is_set_redstate;
		if (redstate==1)
		{
			[talkSessionUtil sendReadNotice:_convRecord];
			UIImageView *readlabel=(UIImageView *)[cell.contentView viewWithTag:status_audio_tag];
			readlabel.hidden=YES;
			[_ecloud updateMessageToReadState:[StringUtil getStringValue:_convRecord.msgId]];
			_convRecord.is_set_redstate = 0;
        }
	}
	[playaudioview startAnimating];
	
    NSRange range=[pathStr rangeOfString:@".amr"];
	
    if (range.length > 0)
	{//需要转换
        NSString * docFilePath        = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:@"amrAudio.wav"];
        [amrtowav startAMRtoWAV:pathStr tofile:docFilePath];
        
        [self playAudio:docFilePath];
		//[self performSelector:@selector(playAudio:) withObject:docFilePath afterDelay:1];
        return;
    }
	[self playAudio:pathStr];
}
#pragma mark 停止播放音频播放动画 add by shisp
-(int)stopAudioPlayImage
{
	if(self.curRecordPath)
	{
		NSRange range = [self.curRecordPath rangeOfString:@"/" options:NSBackwardsSearch];
		if(range.length > 0)
		{
			NSString *filePath = [self.curRecordPath substringFromIndex:range.location + 1];
			for(int i = self.convRecordArray.count - 1;i>=0;i--)
			{
				ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
				if(_convRecord.msg_type == type_record && [_convRecord.file_name isEqualToString:filePath])
				{
					UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:i]];
					UIImageView *playImageView = (UIImageView*)[cell.contentView viewWithTag:audio_playImageView_tag];
					[playImageView stopAnimating];
					
					return i;
				}
			}
		}
	}
   
	return self.convRecordArray.count - 1;
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放结束时执行的动作
    NSLog(@"------------播放结束时执行的动作");
	int curAudioIndex = [self stopAudioPlayImage];
	self.curRecordPath = nil;
	
	[self playNextAudio:curAudioIndex];
     [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
     NSLog(@"------------解码错误执行的动作");
	[self stopAudioPlayImage];
     [[AVAudioSession sharedInstance] setActive:NO error:nil];
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
     NSLog(@"------------处理中断的代码");
}
- (void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
      NSLog(@"------------处理中断结束的代码");
}

#pragma mark 获得硬件版本
-(float)deviceVersion
{
	return [[[UIDevice currentDevice] systemVersion] floatValue];
}

#pragma mark 停止播放录音
-(bool)stopPlayAudio
{
    //删除近距离事件监听
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];


	[self stopAudioPlayImage];
	
    if ([self deviceVersion] >= 6.0)//ios6 播放 aac
    {
		self.isAudioPause=[audioplayios6 stopPlayAudio];
         [[AVAudioSession sharedInstance] setActive:NO error:nil];
		return true;
    }
	else if (audioPlayer!=nil) 
	{
        [audioPlayer stop];//停止
        [audioPlayer release];
		audioPlayer = nil;
         [[AVAudioSession sharedInstance] setActive:NO error:nil];
		return true;
    }
	return false;
}
/*监测是否插入耳机*/
- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
}
#pragma mark 红外线感应
//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    userinfo_new= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];
    if (userinfo_new.receiver_model_Flag==1)//听筒模式
    {
        return;
    }
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        
        UILabel *title_label=(UILabel *)[listenModeView viewWithTag:2];
        listenModeView.hidden=NO;
        title_label.text= [StringUtil getLocalizableString:@"handset_to_speakers"];
       
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        listenModeTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissListenModeLater) userInfo:nil repeats:NO];
    }
    

}
#pragma mark 确定发送文件消息后，显示在聊天界面，并且开始传输
- (void)dismissListenModeLater{
    [listenModeTimer invalidate];
    listenModeTimer=nil;
    listenModeView.hidden=YES;
}
#pragma mark 播放录音
-(void)playAudio:(NSString*)pathStr
{
    //是否插入耳机播放
    BOOL Headset=[self hasHeadset];
    if (Headset) {
        
    }else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    userinfo_new= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];
    if (userinfo_new.receiver_model_Flag==1)
    {//听筒模式
        UILabel *title_label=(UILabel *)[listenModeView viewWithTag:2];
        listenModeView.hidden=NO;
        title_label.text=[StringUtil getLocalizableString:@"handset_model"];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        listenModeTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissListenModeLater) userInfo:nil repeats:NO];
    }else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
	if ([self deviceVersion] >= 6.0)//ios6 播放 aac
    {
        [audioplayios6 playAudio:pathStr];
        return;
    }
	else
	{
//		[self stopPlayAudio];
		
		NSError* err;
		NSLog(@"---audio path---%@",pathStr);
		audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:pathStr] error:&err ];//使用本地URL创建
		if(err)
		{
			[self stopAudioPlayImage];
			NSLog(@"err msg is %@",err.localizedDescription);
			return;
		}
		audioPlayer.volume = 1.0;
		audioPlayer.delegate=self;
		[audioPlayer prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
		[audioPlayer play];//播放
	}	
}
# pragma mark ios6 播放录音完成后，发出以下通知
- (void)playbackQueueStopped:(NSNotification *)note
{
    int curAudioIndex = [self stopAudioPlayImage];
    self.curRecordPath = nil;
     [[AVAudioSession sharedInstance] setActive:NO error:nil];
//屏蔽 连播
//	if(!self.isAudioPause)
//	{
//		[self playNextAudio:curAudioIndex];
//	}
}
#pragma remark 播放下一个连续未读录音文件
-(void)playNextAudio:(int)curAudioIndex
{
	for(int i = curAudioIndex + 1;i<self.convRecordArray.count;i++)
	{
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
		if(_convRecord.msg_type == type_record && _convRecord.isAudioExist && _convRecord.is_set_redstate == 1)
		{
			[self playAudioAtIndexPath:[self getIndexPathByIndex:i]];
			break;
		}
	}
}
#pragma mark============================图片消息相关方法===========================
-(void)selectExistingPicture
{
    //从相册选择图片
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		//启动相册界面
		if (pickerPic==nil) {
            pickerPic = [[UIImagePickerController alloc] init];
            pickerPic.delegate =self;
		}
        [pickerPic.navigationBar setTintColor:[UIColor colorWithRed:46.0/255.0 green:127.0/255.0 blue:255.0/255.0 alpha:1]];
        
		pickerPic.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		//picker.allowsEditing=YES;
		
		[self presentModalViewController:pickerPic animated:YES];
		
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [StringUtil getLocalizableString:@"photo_album_access_error"]
														message: [StringUtil getLocalizableString:@"photo_album_not_support"]
													   delegate:nil
											  cancelButtonTitle: [StringUtil getLocalizableString:@"confirm"]
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
    
}
-(void)getCameraPicture
{
    //判断是否支持摄像头
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_camera_not_support_warning"]
														message:[StringUtil getLocalizableString:@"chats_talksession_message_camera_not_support"]
													   delegate:nil
											  cancelButtonTitle: [StringUtil getLocalizableString:@"confirm"]
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
		
	}
	
	if (pickerPic==nil) {
        pickerPic = [[UIImagePickerController alloc] init];
        pickerPic.delegate = self;
		[pickerPic.navigationBar setTintColor:[UIColor colorWithRed:46.0/255.0 green:127.0/255.0 blue:255.0/255.0 alpha:1]];
	}
   	pickerPic.sourceType = UIImagePickerControllerSourceTypeCamera;
    //pickerPic.showsCameraControls=YES;
    pickerPic.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
    pickerPic.cameraFlashMode=UIImagePickerControllerCameraFlashModeOff;
	[self presentModalViewController:pickerPic animated:NO];
}

#pragma mark 发送图片-拍照 ,相册 发送失败-重发
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (choosePicMenu==actionSheet)
	{
        if (buttonIndex==0)
		{//拍照
            [self getCameraPicture];
        }
		else if(buttonIndex==1)
        {
            [self selectExistingPicture];
        }
    }
}
-(void)setAlphaToView:(UIView *)tempview
{
    tempview.alpha=1;
}


#pragma mark 点击视频消息，对于收到的消息，如果未下载，点击开始下载，否则播放视频，如果是发送的消息，点击可播放视频
- (void)addSingleTapToVideoOfCell:(UITableViewCell *)cell
{
    UIImageView *showVideoImageView = (UIImageView *)[cell.contentView viewWithTag:video_tag];
    
    // 添加手势
    showVideoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickVideoImage:)];
    [showVideoImageView addGestureRecognizer:singleTap];
    [singleTap release];
}
- (void)onClickVideoImage:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    
    //    NSString *videoname=[NSString stringWithFormat:@"%@.mp4",_convRecord.msg_body];
    NSString *videoname = _convRecord.file_name;
    NSString *videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:videoname];
    
    DisplayVideoViewController *videoCtrl = [[[DisplayVideoViewController alloc]init]autorelease];
    videoCtrl.message = videopath;
    [self.navigationController pushViewController:videoCtrl animated:YES];
}


#pragma mark 点击图片消息，对于收到的消息，如果未下载，点击后开始下载，否则预览图片，如果是发送的消息，那么点击后可预览图片
-(void)addSingleTapToPicViewOfCell:(UITableViewCell*)cell
{
	UIImageView *showPicView = (UIImageView*)[cell.contentView viewWithTag:pic_tag];
	//添加手势
	showPicView.userInteractionEnabled=YES;
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
	[showPicView addGestureRecognizer:singleTap];
	[singleTap release];

}

-(void)onClickImage:(UIGestureRecognizer*)gestureRecognizer
{
	CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
	
	UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
	
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
	
    UIImageView*tempimageView=((UIImageView*)((UITapGestureRecognizer*)gestureRecognizer).view);
    tempimageView.alpha=0.5;
    [self performSelector:@selector(setAlphaToView:) withObject:tempimageView afterDelay:0.3];
	
	if(_convRecord.isBigPicExist)
	{
		[talkSessionUtil sendReadNotice:_convRecord];
		NSString *fileName = [NSString stringWithFormat:@"%@.png",_convRecord.msg_body];
		NSString *pathstr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
        /*
		//	预览图片
        self.preImageFullPath=pathstr;
        localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        localGallery.imagePath=pathstr;
        localGallery.view.backgroundColor=[UIColor blackColor];
        localGallery.navigationController.navigationItem.backBarButtonItem=nil;
        [self.navigationController pushViewController:localGallery animated:YES];
        //self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
        [localGallery release];
         */
        //进入多张图片浏览
        [self enterLargePhotoesViewWithCurrentConvRecord:_convRecord];
		return;
	}
	else
	{
		//		缩率图存在时，可以下载原图，否则不下载
		if(_convRecord.isSmallPicExist)
		{
			if(_convRecord.isDownLoading)
			{
				//		显示进度条
				UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
				[talkSessionUtil displayProgressView:progressview];
			}
			else
			{
				//[self downloadFile:_convRecord.msgId andCell:nil];
                
                //进入多张图片浏览
                [self enterLargePhotoesViewWithCurrentConvRecord:_convRecord];
			}
		}
	}
}
#pragma mark 多图 发送
-(void)uploadManyPics:(NSMutableArray *)picArray
{
   manyPicArray=[picArray copy];
   pic_index=0;
   manypicTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doUploadManyPicsAction) userInfo:nil repeats:YES];
}

-(void)doUploadManyPicsAction
{
    if (pic_index < [manyPicArray count]){
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        CGImageRef imageRef;
        ALAsset *asset=[[manyPicArray objectAtIndex:pic_index] asset];
        ALAssetRepresentation* rep = [asset defaultRepresentation];
        imageRef = [rep fullScreenImage];
        
        if(imageRef)
        {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
            if(_size.width > 0 && _size.height > 0)
            {
                image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
            }
            NSData * data =UIImageJPEGRepresentation(image, 0.5);
            NSLog(@"-----------------picdata--: %d",data.length);
            [self displayAndUploadPic:data];
            
        }
        
        [pool drain];
        
        pic_index++;
    }
    
    if (pic_index==[manyPicArray count]) {
        [manypicTimer invalidate];
        manypicTimer=nil;
        [manyPicArray release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadPicFinished" object:nil];
        return;
    }
}

#pragma mark 确定发送图片消息后，显示在聊天界面，并且开始传输
-(void)displayAndUploadPic:(NSData *)data
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // 文件的临时名称，此处文件类型怎么不是jpeg类型，因为压缩时是按照jpeg类型压缩的
    NSString *currenttimeStr=[StringUtil currentTime];
    NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
	
    //存入本地
    NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
    NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
    BOOL success= [data writeToFile:picpath atomically:YES];
    if (!success) {
		[pool release];
        return;
    }
    
	NSString *msgId = [self addMediaRecord:type_pic message:currenttimeStr filesize:data.length filename:pictempname];
	if(msgId)
	{
		ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
		[self addOneRecord:convRecord andScrollToEnd:true];
		[self uploadFile:convRecord];
	}

    [pool release];
    [pickerPic dismissModalViewControllerAnimated:YES];
}

#pragma mark - 拍照或选择图片后，对图片进行裁剪，预览

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
		
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	//	从图片库中获取图片
    if (picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary) {
        CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
        if(_size.width > 0 && _size.height > 0)
        {
            image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
        }
		//		预览图片
        showPreImageViewController *showPre=[[showPreImageViewController alloc]init];
        showPre.imageData=image;
        showPre.delegete=self;
        
        [picker pushViewController:showPre animated:YES];
        [showPre release];
        
    }
	//	拍照
	else if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
        if(_size.width > 0 && _size.height > 0)
        {
            image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
        }
//        float rate=image.size.height/image.size.width;
//        float height=320*rate;
//        CGSize size = CGSizeMake(320, height);
//        image= [ImageUtil scaledImage:image  toSize:size withQuality:kCGInterpolationMedium];
        
		UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);//存入相册
        
		//		拍照后再压缩成jpeg格式？
        NSData *data=UIImageJPEGRepresentation(image,0.5);
		//NSLog(@"-----------------picdata--: %d",data.length);
        [self performSelector:@selector(displayAndUploadPic:) withObject:data afterDelay:1];
    }
    [pool release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {}

#pragma mark 自动下载缩率图
- (void)autoDownloadSmallPic:(UITableViewCell*)cell andConvRecord:(ConvRecord *)recordObject
{
	UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	[activity startAnimating];
	
	dispatch_queue_t queue;
	queue = dispatch_queue_create("download small pic", NULL);
	dispatch_async(queue, ^{
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig]getNewSmallPicDownloadUrl],recordObject.msg_body,[StringUtil getResumeDownloadAddStr]]];
		NSData *imageData = [NSData dataWithContentsOfURL:url];
		UIImage *image = [UIImage imageWithData:imageData];
		recordObject.isDownLoading = false;
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (image!=nil)
			{
				[activity stopAnimating];
				
				NSString *smallpicname = [NSString stringWithFormat:@"small%@.png",recordObject.msg_body];
				NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:smallpicname];
				BOOL success= [imageData writeToFile:picpath atomically:YES];
				if(!success)
				{
					NSLog(@"图片缩略图保存失败");
				}
				else
				{
					[talkSessionUtil sendReadNotice:recordObject];

					int _index = [self getArrayIndexByMsgId:recordObject.msgId];
					if(_index >=0)
					{
						[self reloadRow:_index+1];
					}
				}
			}
			else
			{
				[activity stopAnimating];
				
			}
		});
	});
    dispatch_release(queue);
}

#pragma mark 检查图片是否需要裁减，如果需要则返回裁减后的图片
-(bool)cropImage:(UIImage*)image
{
	float width = image.size.width;
	float height = image.size.height;
	
	float aspect = width/height;
	int maxWidth = 640;
	int maxHeight = 960;
	if(iPhone5)
		maxHeight = 1136;
	
	bool needCrop = false;
	
	if(aspect > 1)
	{//横向图片
		if(width > maxWidth)
		{
			width = maxWidth;
			height = maxWidth / aspect;
			needCrop = true;
		}
	}
	else
	{//纵向图片
		if(height > maxHeight)
		{
			height = maxHeight;
			width = maxHeight * aspect;
			needCrop = true;
		}
	}
	
	if(needCrop)
	{
		CGSize size = CGSizeMake(width, height);
		image= [ImageUtil scaledImage:image  toSize:size withQuality:kCGInterpolationLow];
		return true;
	}
	return false;
}

#pragma mark==============================文件消息==============================

#pragma mark -
#pragma mark QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller;
{
	return 1;
}
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:previewFileIndex];
	FileRecord *_fileRecord = [[FileRecord alloc]init];
	_fileRecord.convRecord = _convRecord;
	return [_fileRecord autorelease];
}
-(void)onClickFile:(UITapGestureRecognizer*)gesture
{
	CGPoint p = [gesture locationInView:self.chatTableView];
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
	if(_convRecord.isFileExists)
	{
		[talkSessionUtil sendReadNotice:_convRecord];
		previewFileIndex = indexPath.row - 1;
		QLPreviewController* previewController=[[CustomQLPreviewController alloc] init];
		previewController.dataSource=self;
		if([self deviceVersion]<7)
		{
			[self presentModalViewController:previewController animated:YES];
		}
		else
		{
			[self.navigationController pushViewController:previewController animated:YES];
		}
		[previewController release];
	}
	else
	{
		if(_convRecord.isDownLoading)
		{
			return;
		}
        [self downloadByHand:_convRecord];
        
	}
}

#pragma mark==============================常用代码封装==============================

#pragma mark 更新发送消息的状态
-(void)updateStatus:(NSString *)msgId andStatus:(NSString*)status
{
	int _index = [self getArrayIndexByMsgId:msgId.intValue];
	if(_index < 0)return;
	
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
	if([status isEqualToString:@"0"])
	{
		_convRecord.send_flag = send_success;
	}
	UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
	UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	[spinner stopAnimating];
    if (_convRecord.msg_type == type_file) {
        UIProgressView *_progressView = (UIProgressView*)[cell viewWithTag:file_progressview_tag];
        [talkSessionUtil hideProgressView:_progressView];
        
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else if (_convRecord.msg_type == type_pic){
        UILabel *_progressView = (UILabel*)[cell viewWithTag:pic_progress_Label_tag];
        _progressView.hidden = YES;
    }
}

#pragma mark 点击头像查看用户资料
-(void)processHeadImage:(UITableViewCell*)cell
{
	UIImageView *headView = (UIImageView*)[cell.contentView viewWithTag:head_tag];
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewUserInfo:)];
	[headView addGestureRecognizer:singleTap];
	[singleTap release];

    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(iconLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [headView addGestureRecognizer:longPress];
    [longPress release];
}

#pragma mark 长按@某人
-(void)iconLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (self.talkType != mutiableType)
    {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long press Ended");
    }
    else {
        NSLog(@"Long press detected.");
        CGPoint p = [gesture locationInView:self.chatTableView];
        NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
        NSLog(@"--row-- %d  px-- %f  py--%f",indexPath.row,p.x,p.y);
        if (indexPath.row==0) {
            return;
        }
        ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
        NSString *empId = [StringUtil getStringValue:_convRecord.emp_id];
        Emp *emp=[_ecloud getEmployeeById:empId];
        
        if(empId.intValue == [_conn.userId intValue])
        {
            return;
        }
        NSString *tipname=[NSString stringWithFormat:@"@%@",emp.emp_name];
        if ([self.messageTextField.text rangeOfString:tipname].location==NSNotFound) {
            
            self.messageTextField.text=[NSString stringWithFormat:@"%@@%@ ",self.messageTextField.text,emp.emp_name];   
        }
         [self.messageTextField becomeFirstResponder];
    }
    
    
}

#pragma mark 查看用户资料
-(void)viewUserInfo:(UITapGestureRecognizer *)gesture
{
	CGPoint p = [gesture locationInView:self.chatTableView];
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
	NSString *empId = [StringUtil getStringValue:_convRecord.emp_id];
	Emp *emp=[_ecloud getEmployeeById:empId];

	if(empId.intValue == [_conn.userId intValue])
	{
		//		打开用户自己的资料
		userInfoViewController *userInfo = [[userInfoViewController alloc]init];
		userInfo.tagType=1;
		userInfo.emp=emp;
		userInfo.titleStr=emp.emp_name;
		[self.navigationController pushViewController:userInfo animated:YES];
		[userInfo release];
		return;
	}
	
	personInfo.emp= [_ecloud getEmpInfo:[StringUtil getStringValue:emp.emp_id]];
    if(personInfo.emp.permission.isHidden)
    {
        [PermissionUtil showAlertWhenCanNotSee:emp];
    }
    else
    {
        [self.navigationController pushViewController:personInfo animated:YES];
    }
}

#pragma mark 根据msgId找到对应的下标
-(int)getArrayIndexByMsgId:(int)msgId
{
	for(int i = self.convRecordArray.count - 1;i>=0;i--)
	{
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
		if(_convRecord.msgId == msgId)
		{
			return i;
		}
	}
	return -1;
}

#pragma mark 重发提示框处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == download_file_tag)
	{
		if(buttonIndex == 1)
		{
			UILabel *msgIdLabel = (UILabel*)[alertView viewWithTag:download_file_msg_id_tag];
			int msgId = msgIdLabel.text.intValue;
			[self downloadFile:msgId andCell:nil];
		}
		return;
	}
    
    if (picCopyAlert==alertView) {
//
        if (buttonIndex==1)
        {
//            复制图片的时候，已经把图片保存在了固定的位置，选择发送图片时，只需要从这个固定的目录下读取这个图片即可 update by shisp
            
            UIImageView *imageView;
            if([self deviceVersion] < 7.0)
            {
                NSArray *subViewArray = [picCopyAlert subviews];
                for (UIView *subView in subViewArray) {
                    if ([subView isKindOfClass:[UIImageView class]]) {
                        imageView  = (UIImageView *)subView;
                    }
                }
            }
            else
            {
                imageView = [picCopyAlert valueForKey:@"accessoryView"];
            }
            if (imageView) {
                
                UIImage *img =  imageView.image;
                NSData *data = UIImageJPEGRepresentation(img,0.5);
                if (img) {
                    [self displayAndUploadPic:data];
                }
            }
        }
        return;
    }
    
    if (_conn.userStatus==status_offline) {
        return;
    }
//	重新上传图片等文件
    if (buttonIndex==1)
	{
		UILabel *tiplabel=(UILabel *)[alertView viewWithTag:tipMsgIDTag];
		NSString *msgId = tiplabel.text;
		
		int _index = [self getArrayIndexByMsgId:msgId.intValue];
		if(_index >= 0)
		{
			ConvRecord *_record = [self.convRecordArray objectAtIndex:_index];
            //            修改数据库和内存里这条记录的状态
            [self updateSendFlagByMsgId:msgId andSendFlag:send_uploading];
            _record.send_flag = send_uploading;

			UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
			
			UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
			failButton.hidden=YES;
			
			UIActivityIndicatorView *activity=( UIActivityIndicatorView *)[cell.contentView viewWithTag:status_spinner_tag];
			[activity startAnimating];
			
			[self uploadFile:_record];
		}
	}
}

// 是否wifi
- (BOOL) IsEnableWIFI
{
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}


-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)refresh
{
	[self setRightBtn];
	
	if (self.needUpdateTag==1) {
        self.needUpdateTag=0;

		[self.convRecordArray removeAllObjects];

        [self.chatTableView reloadData];
		[self performSelector:@selector(getRecordsByConvId) withObject:nil afterDelay:0.001];
    }
   
	/*
    if (self.talkType == mutiableType) {
        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
        self.title=[NSString stringWithFormat:@"%@(%d人)",self.titleStr,all_num];
    }else
    {
        self.title=self.titleStr;
    }
     */
}
#pragma mark 滑动到表格最下面的数据
-(void)scrollToEnd
{
	//	udpate by shisp 在还有历史记录的情况下，表格的行数和chatarray的行数相差1个，这里需要判断调整
	int _index = [self.convRecordArray count] - 1;
    
	[self.chatTableView scrollToRowAtIndexPath:[self getIndexPathByIndex:_index]
								  atScrollPosition: UITableViewScrollPositionBottom
										  animated:NO];
     
}

#pragma mark chatArray里增加一条记录后，局部刷新聊天界面
-(void)addAndRefresh
{
	int _index = [self.convRecordArray count] - 1 ;
	
	//	发送一条文本消息，修改为局部刷新
	[self.chatTableView beginUpdates];
	if(self.talkType == massType)
	{
		[self.chatTableView insertSections:[NSIndexSet indexSetWithIndex:_index] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		[self.chatTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_index+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	}
	[self.chatTableView endUpdates];
}

#pragma mark ===========长消息相关代码=============

#pragma mark 如果是长消息，那么先把消息保存到文件中，保存在本地，然后再再上传
-(void)displayAndUploadLongMsg:(NSString *)message
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *currenttimeStr=[StringUtil currentTime];
    NSString *tempName = [NSString stringWithFormat:@"%@.txt",currenttimeStr];
	
    //长消息存入本地，存入成功才发送
    NSString *tempPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:tempName];
	NSError *_error;
    BOOL success= [message writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:&_error];
    if (!success) {
		NSLog(@"%s,error is %@",__FUNCTION__,_error.domain);
		[pool release];
        return;
    }
//    数据库中增加一条长消息，文件大小即消息字节数，默认消息内容为当前时间，文件名称传长消息的头部
	NSString *messageHead = [message substringToIndex:16];
	NSString *msgId = [self addMediaRecord:type_long_msg message:currenttimeStr filesize:[StringUtil getMsgLen:message] filename:messageHead];
	if(msgId)
	{
		ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
		[self addOneRecord:convRecord andScrollToEnd:true];
		[self uploadFile:convRecord];

		self.messageTextField.text = @" ";
		[self textViewDidChange:self.messageTextField];
		self.messageTextField.text = @"";
	}
	
    [pool release];
}

#pragma mark 确定本条记录是否显示时间
-(void)setTimeDisplay:(ConvRecord*)_convRecord  andIndex:(int)_index
{
	if(_convRecord.recordType == mass_conv_record_type && _convRecord.msg_type == type_group_info)
	{
		_convRecord.isTimeDisplay = false;
		return;
	}

	if(_index == 0)
	{
		_convRecord.isTimeDisplay = true;
		return;
	}
    //    红包消息类型不显示时间
    if (_convRecord.redPacketModel) {
        if ([_convRecord.redPacketModel.type isEqualToString:@"redPacketAction"]){
            _convRecord.isTimeDisplay = false;
            return;
        }
    }
	
	bool isDisplay = true;
	
	int lastDisplayMsgIndex = [self getLastDisplayTimeMsg:_index];
	
	if(lastDisplayMsgIndex < 0)
	{
		_convRecord.isTimeDisplay = true;
		return;
	}
	
	ConvRecord *tempConvRecord = [self.convRecordArray objectAtIndex:lastDisplayMsgIndex];
	//			如果当前的时间和第一条的时间在3分钟之内，那么就不用显示,有两种情况，一个是小于msg_time_sec,一个是小于0，防止下面消息的显示时间比上面消息的显示时间早的情况 fabs(
	NSTimeInterval _diff = _convRecord.msg_time.intValue - tempConvRecord.msg_time.intValue;
	if(_diff < 0 || (_diff >= 0 && _diff <= msg_time_sec))
	{
		isDisplay = false;
	}
	_convRecord.isTimeDisplay = isDisplay;
}

#pragma mark 找到最近的一条显示时间的消息，从_index开始向前找
-(int)getLastDisplayTimeMsg:(int)_index
{
	for(int i= _index;i>=0;i--)
	{
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
		if(_convRecord.isTimeDisplay)
			return i;
	}
	return -1;
}

#pragma mark 增加显示一条消息
-(void)addOneRecord:(ConvRecord*)_convRecord andScrollToEnd:(bool)isScrollToEnd
{
	[self.convRecordArray addObject:_convRecord];
    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
	[self setTimeDisplay:_convRecord andIndex:self.convRecordArray.count - 1];
	[self.chatTableView reloadData];
//	[self addAndRefresh];
	if(isScrollToEnd)
	{
		[self scrollToEnd];
	}
}

#pragma mark 封装下载文件方法
-(void)downloadFile:(int)msgId andCell:(UITableViewCell*)_cell
{
    if(![ApplicationManager getManager].isNetworkOk)
    {
        return;
    }

//	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,msgId]];
	int _index = [self getArrayIndexByMsgId:msgId];

	if(_index < 0) return;
	
	UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
	if(cell == nil)
	{
		cell = _cell;
	}
    UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
    failButton.hidden = YES;
    
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
	
	UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];

	_convRecord.isDownLoading = true;
	int msgType = _convRecord.msg_type;
	
	//		准备文件下载url，准备下载
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getPicDownloadUrl],_convRecord.msg_body]];
	
	switch (msgType) {
		case type_pic:
		{
			UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
			[talkSessionUtil displayProgressView:progressview];
		}
			break;
//			文件和录音的下载url一致
		case type_record:
		case type_file:
		{
//            判断是否是本地发送出去的文件，如果是那么如果本地没有了
            NSRange range = [_convRecord.msg_body rangeOfString:@"_"];
            if(range.length > 0)
            {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getAudioFileDownloadUrl],[_convRecord.msg_body substringToIndex:range.location]]];

            }
            else
            {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getAudioFileDownloadUrl],_convRecord.msg_body]];
            }
		}
			break;
		case type_long_msg:
		{
			url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLongMsgDownloadUrl],_convRecord.msg_body]];
		}
			break;
		default:
			break;
	}
	
 	ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
	
	[request setDelegate:self];
	
	NSString *pathStr;
	
	switch (msgType) {
		case type_pic:
		{
			//		显示进度条
			UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
			pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.msg_body]];
			//设置文件保存路径
			[request setDownloadDestinationPath:pathStr];
			[request setDownloadProgressDelegate:progressview];
		}
			break;
		case type_file:
		{
			UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
            [talkSessionUtil displayProgressView:_progressView];
			[request setDownloadProgressDelegate:_progressView];
            
            [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
            
			pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
			[request setDownloadDestinationPath:pathStr];
		}
			break;
		case type_record:
		{
			[spinner startAnimating];

			pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
			[request setDownloadDestinationPath:pathStr];
		}
			break;
		case type_long_msg:
		{
			[spinner startAnimating];

			pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
			[request setDownloadDestinationPath:pathStr];
		}
			break;
		default:
			break;
	}
	
	[request setDidFinishSelector:@selector(downloadFileComplete:)];
	[request setDidFailSelector:@selector(downloadFileFail:)];

	//		传参数，文件传输完成后，根据参数进行不同的处理
	[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:_convRecord.msgId],@"MSG_ID",nil]];
	[request setTimeOutSeconds:[self getRequestTimeout]];
	[request setNumberOfTimesToRetryOnTimeout:3];
	request.shouldContinueWhenAppEntersBackground = YES;

	[request startAsynchronous];
	
	_convRecord.downloadRequest = request;
	[request release];
	
    [[talkSessionUtil2 getTalkSessionUtil] addRecordToDownloadList:_convRecord];
}

-(int)getRequestTimeout
{
	int timeout = 30;
	if([ApplicationManager getManager].netType == type_gprs)
	{
		timeout = 60;
	}
	return timeout;
}

#pragma mark 聊天记录修改后，局部刷新
-(void)reloadRow:(int)_index
{
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index-1];
	[talkSessionUtil setPropertyOfConvRecord:_convRecord];
	
	[self.chatTableView reloadData];
}

#pragma mark ========一呼百应消息已读情况统计==========
-(void)viewReadStat:(UITapGestureRecognizer *)gestureRecognizer
{
	CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
	if(_convRecord.isReceiptMsg && _convRecord.msg_flag == send_msg)
	{
		ReceiptMsgReadStatViewController *_controller = [[ReceiptMsgReadStatViewController alloc]init];
		_controller.msgId = _convRecord.msgId;
        _controller.convRecord = _convRecord;
		[self.navigationController pushViewController:_controller animated:YES];
		[_controller release];		
	}
}

#pragma mark ==========普通消息/群发消息相关的方法===========

#pragma mark 根据消息id，得到消息记录
-(ConvRecord*)getConvRecordByMsgId:(NSString*)msgId
{
	ConvRecord *convRecord;
	if(self.talkType == massType)
	{
		convRecord = [massDAO getConvRecordByMsgId:msgId];
	}
	else
	{
		convRecord = [_ecloud getConvRecordByMsgId:msgId];		
	}
	return convRecord;
}

-(int)getConvRecordCountBy:(NSString*)convId
{
	if(self.talkType == massType)
	{
		return [massDAO getConvRecordCountBy:convId];
	}
	else
	{
		return [_ecloud getConvRecordCountBy:convId];
	}
}

-(NSArray*)getConvRecordBy:(NSString*)convId andLimit:(int)_limit andOffset:(int)_offset
{
	NSArray *recordList;
	if(self.talkType == massType)
	{
		recordList = [massDAO getConvRecordBy:convId andLimit:limit andOffset:offset];
	}
	else
	{
		if(self.isVirGroup)
		{
			recordList=[_ecloud getConvRecordByVirGroup:convId andLimit:limit andOffset:offset];
		}
		else
		{
			recordList=[_ecloud getConvRecordBy:convId andLimit:limit andOffset:offset];
		}
	}
	return recordList;
}
-(NSString*)getLastInputMsgByConvId:(NSString*)convId
{
	if(self.talkType == massType)
	{
		return [massDAO getLastInputMsgByConvId:convId];
	}
	else
	{
		return [_ecloud getLastInputMsgByConvId:convId];
	}
}

#pragma 根据cell的indexpath得到数据数组的下标
-(int)getIndexByIndexPath:(NSIndexPath*)indexPath
{
	if(self.talkType == massType)
	{
		return indexPath.section - 1;
	}
	return indexPath.row - 1;
}

#pragma 根据数组的下标，得到indexPath
-(NSIndexPath*)getIndexPathByIndex:(int)index
{
	if(self.talkType == massType)
	{
		return [NSIndexPath indexPathForRow:0 inSection:index+1];
	}
	return [NSIndexPath indexPathForRow:index+1 inSection:0];
}

-(void)updateSendFlagByMsgId:(NSString*)msgId andSendFlag:(int)flag
{
	if(self.talkType == massType)
	{
		[massDAO updateSendFlagByMsgId:msgId andSendFlag:flag];
	}
	else
	{
		[_ecloud updateSendFlagByMsgId:msgId andSendFlag:flag];
	}
}

-(void)updateLastInputMsgByConvId:(NSString*)convId LastInputMsg:(NSString *)lastInputMsg
{
	if(self.talkType == massType)
	{
		[massDAO updateLastInputMsgByConvId:convId LastInputMsg:lastInputMsg];
	}
	else
	{
		[_ecloud updateLastInputMsgByConvId:convId LastInputMsg:lastInputMsg];
	}
}

-(void)updateLastInputMsgTimeByConvId:(NSString*)convId
{
    int nowtimeInt= [_conn getCurrentTime];
	NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
	if(self.talkType == massType)
	{
		[massDAO updateLastInputMsgTimeByConvId:convId nowTime:nowTime];
	}
	else
	{
		[_ecloud updateLastInputMsgTimeByConvId:convId nowTime:nowTime];
	}
}

#pragma mark ====群发=====

-(void)addSingleTapToReplyLabelOfCell:(UITableViewCell*)cell
{
	UIButton *replyButton = (UIButton*)[cell.contentView viewWithTag:reply_bg_btn_tag];
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewReplyDetail:)];
	[replyButton addGestureRecognizer:singleTap];
	[singleTap release];
}

-(void)viewReplyDetail:(UITapGestureRecognizer *)gestureRecognizer
{
	[[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"loading"]];
	[[LCLLoadingView currentIndicator]showSpinner];
	[[LCLLoadingView currentIndicator]show];
	CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
	
	[self performSelector:@selector(viewReply:) withObject:indexPath afterDelay:0.05];
}
-(void)viewReply:(NSIndexPath *)indexPath
{
	if(indexPath && indexPath.section > 0 && indexPath.section <= self.convRecordArray.count )
	{
		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:indexPath.section-1];
		
		broadcastRecordMemberViewController *broadcastRecordMember=[[broadcastRecordMemberViewController alloc]init];
		broadcastRecordMember.conv_id=_convRecord.conv_id;
		broadcastRecordMember.msg_id=_convRecord.msgId;
		[self.navigationController pushViewController:broadcastRecordMember animated:YES];
		[broadcastRecordMember release];
	}
	else
	{
		[[LCLLoadingView currentIndicator]hiddenForcibly:true];
	}
}

-(void)processSpinnerOfCell:(UITableViewCell*)cell andConvRecord:(ConvRecord*)_convRecord
{
	UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	if(_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading))
	{
		[spinner startAnimating];
	}
	else
	{
		[spinner stopAnimating];
	}
}

#pragma mark==============================图片预览==============================
#pragma mark - 2013-4-16 pain  进入图片大图页面

- (void)enterLargePhotoesViewWithCurrentConvRecord:(ConvRecord *)convRecord{
    if (networkImagesArr == nil) {
        networkImagesArr = [[NSMutableArray alloc] init];
    }
    else{
        [networkImagesArr removeAllObjects];
    }
    
    if (networkThumbnailImagesArr == nil) {
        networkThumbnailImagesArr = [[NSMutableArray alloc] init];
    }
    else{
        [networkThumbnailImagesArr removeAllObjects];
    }
    
    NSInteger currIndex = 0;
    int i = 0;
    
    NSMutableArray *recordList;
    
    if(self.talkType == massType)
	{
        recordList= [NSMutableArray arrayWithArray:[massDAO getPicConvRecordBy:self.convId]];
	}
	else
	{
        recordList= [NSMutableArray arrayWithArray:[_ecloud getPicConvRecordBy:self.convId]];
    }
    
    NSLog(@"recordList------%i",[recordList count]);
    
    //筛选当前会话记录中所有图片的
    for (ConvRecord *_convRecord in recordList) {
        if (_convRecord.msg_type == type_pic) {
            //大图url，准备下载
            NSString *urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getNewPicDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
            [networkImagesArr addObject:urlStr];
            //NSLog(@"urlStr----- --------%@",urlStr);
            
            //缩略图url
            NSString *ThumbnailUrlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase] getServerConfig] getNewSmallPicDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
            [networkThumbnailImagesArr addObject:ThumbnailUrlStr];
            
            if (convRecord.msgId == _convRecord.msgId) {
                currIndex = i;
            }
            i ++ ;
        }
    }
    //NSLog(@"currIndex-------%i",currIndex);
    
    networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self withCurrentIndex:currIndex];
    //self.title = @"返回";
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:networkGallery animated:YES];
    [networkGallery release];
}


#pragma mark - FGalleryViewControllerDelegate Methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    int num = 0;
    if( gallery == networkGallery ) {
        num = [networkImagesArr count];
    }
	return num;
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption = @"";
    
	return caption;
}


- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return @"";
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    if (size == FGalleryPhotoSizeThumbnail) {
        return [networkThumbnailImagesArr objectAtIndex:index];
    }
    else {
        return [networkImagesArr objectAtIndex:index];
    }
}

- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}


- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}

- (NSString*)photoGalleryClickOnBackBtn:(FGalleryViewController*)gallery{
    [self.chatTableView reloadData];
    return @"";
}

#pragma mark==============================发送文件==============================
#pragma mark - LocaLFilesViewControllerDelegate 协议方法
- (void)locaLFilesViewControllerClickOnBackBtn:(LocaLFilesViewController*)localFilesCtr withSelectFiles:(NSMutableArray *)filesArr{
    //NSLog(@"filesArr------%@",filesArr);
    
    //manyFilesArray=[filesArr copy];
    manyFilesArray = [[NSMutableArray alloc] initWithArray:filesArr];
    file_index=0;
    manyFileTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doUploadManyFilesAction) userInfo:nil repeats:YES];
}

#pragma mark 确定发送文件消息后，显示在聊天界面，并且开始传输
- (void)doUploadManyFilesAction{
    if (file_index==[manyFilesArray count]) {
        [manyFileTimer invalidate];
        manyFileTimer=nil;
        [manyFilesArray release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadFilesFinished" object:nil];
        return;
    }
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableDictionary *dic = [manyFilesArray objectAtIndex:file_index];
    NSData *data = [NSData dataWithContentsOfFile:[dic objectForKey:@"fileFullPath"]];
    
    if([data length])
    {
        NSLog(@"-----------------picdata--: %d",data.length);
        [self displayAndUploadLocalFile:data withDic: dic];
    }
    
    [pool drain];
    
    file_index++;
}


-(void)displayAndUploadLocalFile:(NSData *)data withDic:(NSMutableDictionary *)dic
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    后面附加一个_,用来区分是本地发送的文件，还是收到或同步过来的文件
    NSString *currenttimeStr=[NSString stringWithFormat:@"%@_",[StringUtil currentTime]];
    NSString *fileName = [dic valueForKey:@"fileName"];
//    
//    不需要再复制一份文件
////    把文件名字去掉了扩展名
//    NSString *pictempname = [NSString stringWithFormat:@"%@",[StringUtil getProperFileName:[dic objectForKey:@"fileName"]]];
//    
//    //fileName = [NSString stringWithFormat:@"%@_%@.%@",file_name,msgBody,file_Ext];
////    生成了一个新的文件
//    //存入本地
//    NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.%@",[NSString stringWithFormat:@"%@",[pictempname stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[pictempname pathExtension]] withString:@""]],currenttimeStr,[pictempname pathExtension]]];
//    
//    //NSLog(@"picpath---------%@",picpath);
//    NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
//    
//    BOOL success= [data writeToFile:picpath atomically:YES];
//    if (!success) {
//		[pool release];
//        return;
//    }
    
	NSString *msgId = [self addMediaRecord:type_file message:currenttimeStr filesize:data.length filename:fileName];
	if(msgId)
	{
		ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
		[self addOneRecord:convRecord andScrollToEnd:true];
		[self uploadFile:convRecord];
	}
    
    [pool release];
}

#pragma 上传文件，根据类型不同，进行不同上传
-(void)uploadFile:(ConvRecord*)_convRecord
{
    int msgType = _convRecord.msg_type;
    NSURL *url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getPicUploadUrl]];
    
    switch(msgType)
    {
        case type_pic:
        {
        }
            break;
        case type_record:
        {
            url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getAudioFileUploadUrl]];
        }
            break;
        case type_long_msg:
        {
            url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getLongMsgUploadUrl]];
        }
            break;
        case type_file:
        {
            url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getAudioFileUploadUrl]];
        }
            break;
    }
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request setDelegate:self];
    
    NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
    
    if(msgType == type_long_msg)
    {
        filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
    }
    else if (msgType == type_file){
        //发送文件，显示进度条
        int _index = [self getArrayIndexByMsgId:_convRecord.msgId];
        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
        [talkSessionUtil displayProgressView:_progressView];
        [request setUploadProgressDelegate:_progressView];
        request.showAccurateProgress = YES;
        
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else if (msgType == type_pic){
        //发送图片，显示进度条
        int _index = [self getArrayIndexByMsgId:_convRecord.msgId];
        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
        UILabel *_progressView = (UILabel *)[cell.contentView  viewWithTag:pic_progress_Label_tag];
        _progressView.hidden = NO;
        [request setUploadProgressDelegate:_progressView];
        request.showAccurateProgress = YES;
    }
    
    [request addFile:filePath withFileName:nil andContentType:@"multipart/form-data" forKey:@"body"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:[StringUtil getStringValue:_convRecord.msgId] forKey:@"MSG_ID"]];
    
    [request setDidFinishSelector:@selector(uploadFileComplete:)];
    [request setDidFailSelector:@selector(uploadFileFail:)];
    [request setTimeOutSeconds:[self getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    [request startAsynchronous];
    [request release];
}

#pragma mark 上传文件成功处理
-(void)uploadFileComplete:(ASIHTTPRequest *)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    NSDictionary *dic=[request userInfo];
    NSString *msgId = [dic valueForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    
    ConvRecord *_convRecord;
    if(_index < 0)
    {
        _convRecord = [self  getConvRecordByMsgId:msgId];
    }
    else
    {
        _convRecord =[self.convRecordArray objectAtIndex:_index];
    }
    
    int msgType = _convRecord.msg_type;
    
    if(statuscode == 200 && [response length] == 0)
    {
        NSLog(@"上传文件，状态正常，返回空");
        [self uploadFile:_convRecord];
        return;
    }
    
    if (statuscode!=200)
    {
        [self uploadFile:_convRecord];
        return;
    }
    
    NSString *oldName = _convRecord.file_name;
    NSString *oldPath;
    
    NSString *newName;
    NSString *newPath;
    
    switch(msgType)
    {
        case type_pic:
        {
            newName=[NSString stringWithFormat:@"%@.png",response];
        }
            break;
        case type_record:
        {
            NSRange range=[oldName rangeOfString:@"." options:NSBackwardsSearch];
            NSString *ext = [oldName substringFromIndex:range.location + 1];
            newName = [NSString stringWithFormat:@"%@.%@",response,ext];
        }
            break;
        case type_long_msg:
        {
            newName=[NSString stringWithFormat:@"%@.txt",response];
            oldName = [NSString stringWithFormat:@"%@.txt", _convRecord.msg_body];
        }
            break;
        case type_file:
        {
            
        }
            break;
    }
    if (msgType == type_file) {
        //        不做处理
    }
    else{
        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:oldName];
        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:newName];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr moveItemAtPath:oldPath toPath:newPath error:nil];
    }
    
    //		从新路径下取出文件数据，并且保存新路径
    NSString *sendbody=[NSString stringWithFormat:@"%@",response];
    
    if(msgType == type_file)
    {
        //        如果是文件，后面附加一个_
        _convRecord.msg_body = [NSString stringWithFormat:@"%@_",sendbody];
    }
    else
    {
        _convRecord.msg_body = sendbody;
    }
    
    NSString *fileName = nil;
    //	if(msgType != type_long_msg)
    //	{
    //        fileName = newName;
    //		_convRecord.file_name = newName;
    //	}
    
    if(msgType == type_pic || msgType == type_record)
    {
        fileName = newName;
        _convRecord.file_name = newName;
    }
    else if(msgType == type_file)
    {
        fileName = oldName;
    }
    
    if(self.talkType == massType)
    {
        [massDAO updateConvRecord:msgId andMSG:sendbody andFileName:fileName andMsgType:msgType];
    }
    else
    {
        [_ecloud updateConvRecord:msgId andMSG:sendbody andFileName:fileName andNewTime:0 andConvId:nil andMsgType:msgType];
    }
    
    _convRecord.send_flag = sending;
    
    [self sendMessage:msgType message:sendbody filesize:_convRecord.file_size.intValue filename:fileName andOldMsgId:msgId];
    
    if(_index >= 0)
    {
        [self reloadRow:_index+1];
    }
}
#pragma mark 上传文件失败处理
-(void)uploadFileFail:(ASIHTTPRequest *)request
{
    NSDictionary *userdic=[request userInfo];
    NSString *msgId=[userdic objectForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    if(_index < 0)
    {
        //		用户已经切换到了别的会话，此时应该修改数据库，记录上传失败的状态
        [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
        return;
    }
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    if(request.error.code == ASIRequestTimedOutErrorType)
    {
        _convRecord.tryCount = _convRecord.tryCount + 1;
        if(_convRecord.tryCount < max_try_count)
        {
            [self uploadFile:_convRecord];
            return;
        }
    }
    
    _convRecord.tryCount = 0;
    
    [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
    
    _convRecord.send_flag = send_upload_fail;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    if (_convRecord.msg_type == type_file) {
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
    failBtn.hidden=NO;
}

-(void)openRedRedpacket:(UITapGestureRecognizer*)gesture
{
    //    1 =     {
    //        ID = 70912443172127104;
    //        "is_money_msg" = 1;
    //        "money_greeting" = "\U606d\U559c\U53d1\U8d22\Uff0c\U5927\U5409\U5927\U5229\Uff01";
    //        "money_receiver_id" = 4410;
    //        "money_sender" = "\U989c\U78ca";
    //        "money_sender_id" = 4421;
    //        "money_sponsor_name" = "\U4e91\U8d26\U6237\U7ea2\U5305";
    //        "money_type_special" = "";
    //        "special_money_receiver_id" = 4410;
    //    };
    //
    //    ID = 70912443172127104;
    //    "is_money_msg" = 1;
    //    "money_greeting" = "\U606d\U559c\U53d1\U8d22\Uff0c\U5927\U5409\U5927\U5229\Uff01";
    //    "money_receiver_id" = 4410;
    //    "money_sender" = "\U989c\U78ca";
    //    "money_sender_id" = 4421;
    //    "money_sponsor_name" = "\U4e91\U8d26\U6237\U7ea2\U5305";
    //    "money_type_special" = "";
#ifdef _LANGUANG_FLAG_
    
    CGPoint p = [gesture locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    
    if (isEditingConvRecord) {
        
        _convRecord.isSelect = !_convRecord.isSelect;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        return;
    }
    
    NSData* jsonData = [_convRecord.msg_body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [jsonData objectFromJSONData];
    //    NSDictionary *redpacketDic = [resultDict valueForKey:@"1"];
    //    if (redpacketDic) {
    NSMutableDictionary * mDict = [NSMutableDictionary dictionaryWithDictionary:resultDict];
    NSString *key = @"brcredpacket9384";
    NSString *redPackId = [AESCipher decryptAES:resultDict[@"redPacketId"] key:key];
    NSString *receiver_id = _conn.userId;//[NSString stringWithFormat:@"%d",_convRecord.emp_id];
    eCloudDAO* db=[eCloudDAO getDatabase];
    Emp *emp = [db getEmployeeById:resultDict[@"userId"]];
    NSString *sender = emp.emp_name;
    
    [mDict setObject:redPackId forKey:@"ID"];
    [mDict setObject:resultDict[@"greeting"] forKey:@"money_greeting"];
    [mDict setObject:receiver_id forKey:@"money_receiver_id"];
    [mDict setObject:resultDict[@"userId"] forKey:@"money_sender_id"];
    [mDict setObject:sender forKey:@"money_sender"];
    [mDict setObject:@"1" forKey:@"is_money_msg"];
    //[mDict setObject:@"" forKey:@"money_type_special"];
    //[mDict setObject:receiver_id forKey:@"special_money_receiver_id"];
    //[mDict setObject:@"云账户红包" forKey:@"money_sponsor_name"];
    
    [mDict removeObjectForKey:@"greeting"];
    [mDict removeObjectForKey:@"userId"];
    [mDict removeObjectForKey:@"redPacketId"];
    [mDict removeObjectForKey:@"type"];
    
    
    
    [[redpacketViewControllerARC getRedpacketViewController]redpacketTouched:self redpacketDic:mDict];
#endif
    //    }else {
    //        return;
    //    }
    
    
    
}

#pragma mark ============================================================
#pragma mark =========转发一条聊天记录到其他的会话===========

//打开最近的联系人，用来转发
- (void)openRecentContacts
{
    ForwardingRecentViewController *forwarding=[[ForwardingRecentViewController alloc]initWithConvRecord:self.forwardRecord];
    forwarding.forwardingDelegate = self;
    forwarding.isComeFromChatHistory = YES;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:forwarding];
    [forwarding release];
    nav.navigationBar.tintColor=[UIColor blackColor];
    [UIAdapterUtil presentVC:nav];
//    [self presentModalViewController:nav animated:YES];
    [nav release];
}
//保存转发的记录
- (BOOL)saveForwardMsg
{
    ConvRecord *forwardRecord = self.forwardRecord;
    
    NSString *nowTime = [_conn getSCurrentTime];
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
    
    [mDic setValue:forwardRecord.conv_id forKey:@"conv_id"];
    
    [mDic setValue:_conn.userId forKey:@"emp_id"];
    
    [mDic setValue:[StringUtil getStringValue:forwardRecord.msg_type] forKey:@"msg_type"];
    
    [mDic setValue:nowTime forKey:@"msg_time"];
    
    [mDic setValue:@"0" forKey:@"read_flag"];
    
    [mDic setValue:[StringUtil getStringValue:send_msg] forKey:@"msg_flag"];
    
    if (forwardRecord.msg_type == type_text)
    {
        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        [mDic setValue:[StringUtil getStringValue:sending] forKey:@"send_flag"];
    }
    else
    {
        [mDic setValue:[StringUtil getStringValue:send_uploading] forKey:@"send_flag"];
    }
    
    [mDic setValue:[StringUtil getStringValue:conv_status_normal] forKey:@"receipt_msg_flag"];
    
    if (forwardRecord.msg_type == type_pic)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        NSString *currenttimeStr=[StringUtil currentTime];
        NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
        //存入本地
        NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
        
        NSData *data = [NSData dataWithContentsOfFile:[talkSessionUtil getBigPicPath:forwardRecord]];
        BOOL success= [data writeToFile:picpath atomically:YES];
        if (!success)
        {
            //            复制文件失败
            [pool release];
            return NO;
        }
        else
        {
            [mDic setValue:currenttimeStr forKey:@"msg_body"];
            [mDic setValue:pictempname forKey:@"file_name"];
            [mDic setValue:forwardRecord.file_size forKey:@"file_size"];
        }
        [pool release];
    }
    else if (forwardRecord.msg_type == type_long_msg)
    {
        NSString *message = [NSString stringWithContentsOfFile:[talkSessionUtil getLongMsgPath:forwardRecord] encoding:NSUTF8StringEncoding error:nil];
        
        NSString *currenttimeStr=[StringUtil currentTime];
        NSString *tempName = [NSString stringWithFormat:@"%@.txt",currenttimeStr];
        //长消息存入本地，存入成功才发送
        NSString *tempPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:tempName];
        NSError *_error;
        BOOL success= [message writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:&_error];
        if (!success)
        {
            return NO;
        }
        else
        {
            [mDic setValue:currenttimeStr forKey:@"msg_body"];
            [mDic setValue:forwardRecord.file_name forKey:@"file_name"];
            [mDic setValue:forwardRecord.file_size forKey:@"file_size"];
        }
    }
    else if (forwardRecord.msg_type == type_file)
    {
        NSString *currenttimeStr=[NSString stringWithFormat:@"%@_",[StringUtil currentTime]];
        [mDic setValue:currenttimeStr forKey:@"msg_body"];
        
        NSString *fileName = [talkSessionUtil getFileName:forwardRecord];
        
        [mDic setValue:fileName forKey:@"file_name"];
        [mDic setValue:forwardRecord.file_size forKey:@"file_size"];
    }
    
    NSDictionary *dic = [_ecloud addConvRecord:[NSArray arrayWithObject:mDic]];
    if(!dic)
    {
        NSLog(@"保存失败");
        return NO;
    }

    NSString *msgId = [dic valueForKey:@"msg_id"];
    
    self.forwardRecord = [self getConvRecordByMsgId:msgId];

    return YES;
}

#pragma mark 发送转发的消息
- (void)sendForwardMsg
{
    ConvRecord *forwardRecord = self.forwardRecord;
    if (forwardRecord.msg_type == type_text)
    {
        [_conn sendMsg:forwardRecord.conv_id andConvType:forwardRecord.conv_type andMsgType:type_text andMsg:forwardRecord.msg_body andMsgId:forwardRecord.origin_msg_id andTime:forwardRecord.msg_time.intValue andReceiptMsgFlag:conv_status_normal];
    }
    else
    {
        [self uploadFile:forwardRecord];
    }

    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:0.5];
}

#pragma mark =======转发提示=======
- (void)showTransferTips
{
    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}

- (void)showForwardTips
{
    [UserTipsUtil showForwardTips];
}

- (void)dismissLoadingView
{
    [UserTipsUtil hideLoadingView];
}

- (void)refreshTitle
{
    if (self.talkType == mutiableType)
    {
        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
        self.title=[NSString stringWithFormat:@"%@(%d人)",self.titleStr,all_num];
    }
}

#pragma mark 加载查询结果，位置停在相应的位置上，并且可以查看前后的记录
//- (void)loadSearchResults:(NSString *)convId :(int )msgId
- (void)loadSearchResults:(Conversation *)fromConv
{
    NSDictionary *dic = [queryDAO getConvRecordListByConversation:fromConv];
    totalCount = [[dic valueForKey:@"total_count"]intValue];
    
    //    可以查看历史记录
    offset = 1;
    
    NSArray *results = [dic valueForKey:@"result_array"];
    
    NSArray *thisLoadArray;
    
    //    这里不加载所有的，只加载一部分，每次加载条数，并且记录未加载的记录
    int _count = results.count;
    if (_count > num_of_load_search_result) {
        thisLoadArray = [results subarrayWithRange:NSMakeRange(0, num_of_load_search_result)];
        self.unloadQueryResultArray = [NSMutableArray arrayWithArray:[results subarrayWithRange:NSMakeRange(num_of_load_search_result, _count - num_of_load_search_result)]];
    }
    else
    {
        thisLoadArray = [NSArray arrayWithArray:results];
    }
    
    self.convRecordArray = [NSMutableArray arrayWithArray:thisLoadArray];
    
    int tableRowOffset = 0;
    
    int _index = 0;
    for(ConvRecord *_convRecord in self.convRecordArray)
    {
        [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [self setTimeDisplay:_convRecord andIndex:_index];
        _index++;
        if (_convRecord.msgId == fromConv.last_record.msgId) {
            tableRowOffset = _index;
        }
    }
    
    [self.chatTableView reloadData];
    
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tableRowOffset inSection:0]
                              atScrollPosition: UITableViewScrollPositionTop
                                      animated:NO];
    [self initDraft];
}


- (NSDictionary *)getConvRecordListByConversation:(NSString *)convId1 :(int )msgId1
{
    conn *_conn = [conn getConn];
    int start = [_conn getCurrentTime];
    NSString *convId = convId1;
    int msgId = msgId1;
    
    //    查询当前会话，当前聊天记录之前一共有多少条聊天记录
    NSString *sql = [NSString stringWithFormat:@"select count(id) as _count from %@ where conv_id = '%@' and id < %d",table_conv_records,convId,msgId];
    
    NSMutableArray *result = [queryDAO querySql:sql];
    
    int count1 = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
    
    int offset;
    
    int _offset;
    
    //    剩下的聊天记录比一次加载的多
    if(count1 > num_convrecord)
    {
        offset = count1 - num_convrecord;
        _offset = num_convrecord;
    }
    else
    {
        offset = 0;
        _offset = count1;
    }
    
    //    查询当前会话，当前聊天记录以后还有多少条聊天记录
    sql = [NSString stringWithFormat:@"select count(id) as _count from %@ where conv_id = '%@' and id >= %d",table_conv_records,convId,msgId];
    result = [queryDAO querySql:sql];
    int count2 = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
    
    int limit = _offset + count2;
    
    int totalCount = count1 + count2;
    
    eCloudDAO *ecloudDAO = [eCloudDAO getDatabase];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[ecloudDAO getConvRecordBy:convId andLimit:limit andOffset:offset],@"result_array",[StringUtil getStringValue:_offset],@"offset",[StringUtil getStringValue:totalCount],@"total_count", nil];
    int end = [_conn getCurrentTime];
    //    NSLog(@"%s,end - start is %d",__FUNCTION__,(end - start));
    return dic;
}

#pragma mark -----消息cell优化------
- (UITableViewCell *)getMsgCell:(UITableView *)tableView andRecord:(ConvRecord *)_convRecord
{
    UITableViewCell *cell = nil;
    
    int msgType = _convRecord.msg_type;
    
    switch (msgType) {
        case type_text:
        {
            NSArray *arr = [_convRecord.msg_body componentsSeparatedByString:@"-+-"];
            
            if (_convRecord.locationModel) {
                //                证明是位置信息
                LocationMsgCell *locationCell = [[[LocationMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
                [self addMapViewGesture:locationCell];
                [self addCommonGesture:locationCell];
                cell = locationCell;
            }
#ifdef _XINHUA_FLAG_
            else if (_convRecord.systemMsgModel)
            {
                SystemMsgModelArc *model = _convRecord.systemMsgModel;
                if ([model.msgType isEqualToString:TYPE_TEXT]) {
                    
                    cell = [self getNormalTextCell:tableView andRecord:_convRecord];
                }
                else if ([model.msgType isEqualToString:TYPE_NEWS])
                {
                    static NSString *newImgTxtCellID = @"NEWSCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:newImgTxtCellID];
                    if (cell == nil) {
                        cell = [[[NewsCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newImgTxtCellID]autorelease];
                        [[RobotDisplayUtil getUtil] addImgTxtViewGesture:cell];
                        [self addCommonGesture:cell];
                    }
                }
            }
#endif
            //            WXReplyToOneMsgCellTableViewCellArc
            else if (_convRecord.replyOneMsgModel)
            {
                static NSString *replyToCellID = @"replyToCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:replyToCellID];
                if (cell == nil) {
                    cell = [[[WXReplyToOneMsgCellTableViewCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyToCellID]autorelease];
                    
                    [[WXReplyOneMsgUtil getUtil] addSearchJumpToViewGesture:cell];
                    //点击头像
                    [self addCommonGesture:cell];
                }
            }
            else if (_convRecord.cloudFileModel){
                
                static NSString *fileMsgCellID = @"cloudFileMsgCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:fileMsgCellID];
                if (cell == nil) {
                    cell = [[[NewFileMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileMsgCellID]autorelease];
                    //                增加文件消息点击事件
                    [self addGestureToFile:cell];
                    
                    //点击头像
                    [self addCommonGesture:cell];
                }
            }
#ifdef _LANGUANG_FLAG_
            else if (_convRecord.redPacketModel){
                
                static NSString *redPacketCellID = @"redPacketMsgCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:redPacketCellID];
                if (cell == nil) {
                    
                    NSData* jsonData = [_convRecord.msg_body dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *resultDict = [jsonData objectFromJSONData];
                    cell = [[RedpacketConfig sharedConfig] cellForRedpacketMessageDict:resultDict];
                    
                    //                    [[RedpacketConfig sharedConfig]showView:cell.contentView];
                    //                增加拆红包事件
                    [self addOpenRedRedpacket:cell];
                    
                    //点击头像
                    [self addCommonGesture:cell];
                }
            }
            else if (_convRecord.newsModel){
                
                static NSString *newMsgCellID = @"newMsgCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:newMsgCellID];
                if (cell == nil) {
                    LGNewsCellARC *NewCell = [[[LGNewsCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newMsgCellID]autorelease];
                    
                    [NewCell configCellWithDataModel:_convRecord.newsModel];
                    cell = NewCell;
                    //点击头像
                    [self addCommonGesture:cell];
                    [self addOpenNews:cell];
                    
                }
            }
#endif
            else if (_convRecord.replyOneMsgModel){
                static NSString *replyToOneMsgCellID = @"replyToOneMsgCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:replyToOneMsgCellID];
                if (cell == nil) {
                    cell = [[[WXReplyToOneMsgCellTableViewCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyToOneMsgCellID]autorelease];
                    //                    [[RobotDisplayUtil getUtil] addImgTxtViewGesture:cell];
                    [self addCommonGesture:cell];
                }
            }
            else if (_convRecord.isRobotImgTxtMsg){
                
                static NSString *newImgTxtCellID = @"NewImgTxtCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:newImgTxtCellID];
                if (cell == nil) {
                    cell = [[[NewImgTxtMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newImgTxtCellID]autorelease];
                    [[RobotDisplayUtil getUtil] addImgTxtViewGesture:cell];
                    [self addCommonGesture:cell];
                }
            }else if (_convRecord.isRobotFileMsg){
                cell = [[RobotDisplayUtil getUtil]getNewFileMsgCell];
            }else if (_convRecord.isRobotPicMsg){
                //                机器人图片消息
                cell = [[RobotDisplayUtil getUtil]getPicMsgCell];
            }else
            {
                if (arr.count > 1)  //(_convRecord.isHyperlink)
                {
                    static NSString *hyperlinkCellID = @"hyperlinkCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:hyperlinkCellID];
                    if (cell == nil) {
                        cell = [[HyperlinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hyperlinkCellID];
                        [self addSingleTapToHyperlink:cell];
                        [self addCommonGesture:cell];
                    }
                }
                else if (_convRecord.isLinkText) {
                    static NSString *linkTextCellID = @"linkTextCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:linkTextCellID];
                    if (cell == nil) {
                        cell = [[[LinkTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:linkTextCellID]autorelease];
                        [self addCommonGesture:cell];
                    }
                }
                else if(_convRecord.isTextPic)
                {
                    static NSString *faceTextCellID = @"faceTextCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:faceTextCellID];
                    if (cell == nil) {
                        cell = [[[FaceTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:faceTextCellID]autorelease];
                        [self addCommonGesture:cell];
                    }
                }
                else
                {
                    cell = [self getNormalTextCell:tableView andRecord:_convRecord];
                }
            }
        }
            break;
        case type_long_msg:
        {
            //                长消息和普通的文本消息使用同一个cell
            cell = [self getNormalTextCell:tableView andRecord:_convRecord];
        }
            break;
        case type_record:
        {
            static NSString *audioMsgCellID = @"audioMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:audioMsgCellID];
            if (cell == nil) {
                cell = [[[AudioMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:audioMsgCellID]autorelease];
                //                增加录音消息点击事件
                [self addPlayAudioToCell:cell];
                [self addCommonGesture:cell];
            }
        }
            break;
        case type_pic:
        {
            static NSString *picMsgCellID = @"picMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:picMsgCellID];
            if (cell == nil) {
                cell = [[[PicMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:picMsgCellID]autorelease];
                //                增加图片消息点击事件
                [self addSingleTapToPicViewOfCell:cell];
                [self addCommonGesture:cell];
            }
        }
            break;
        case type_video:
        {
            static NSString *videoMsgCellID = @"videoMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:videoMsgCellID];
            if (cell == nil) {
                cell = [[[VideoMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoMsgCellID]autorelease];
                //                增加图片消息点击事件
                [self addSingleTapToVideoOfCell:cell];
                [self addCommonGesture:cell];
            }
        }
            break;
        case type_file:
        {
            static NSString *fileMsgCellID = @"fileMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:fileMsgCellID];
            if (cell == nil) {
                cell = [[[NewFileMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileMsgCellID]autorelease];
                //                增加文件消息点击事件
                [self addGestureToFile:cell];
                [self addCommonGesture:cell];
            }
        }
            break;
        case type_group_info:
        {
            static NSString *groupInfoMsgCellID = @"groupInfoMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:groupInfoMsgCellID];
            if(cell == nil)
            {
                cell = [[[GroupInfoMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupInfoMsgCellID]autorelease];
            }
        }
            break;
        default:
            break;
    }
    return cell;
}
- (UITableViewCell *)getNormalTextCell:(UITableView *)tableView andRecord:(ConvRecord *)_convRecord
{
    static NSString *normalTextCellID = @"normalTextCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalTextCellID];
    if (cell == nil) {
        cell = [[[NormalTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalTextCellID]autorelease];
        [self addCommonGesture:cell];
    }
    return cell;
}
- (void)addMapViewGesture:(UITableViewCell *)cell
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMapView:)];
    UIView *view = [cell viewWithTag:location_pic_view_tag];
    [view addGestureRecognizer:tap];
    [tap release];
}

- (void)openMapView:(UIGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:_chatTableView];
    NSIndexPath *indexPath = [_chatTableView indexPathForRowAtPoint:point];
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    if (isEditingConvRecord) {
        _convRecord.isSelect = !_convRecord.isSelect;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    
    if (_convRecord.locationModel) {
        receiveMapViewController *mapViewCtl = [[[receiveMapViewController alloc] init]autorelease];
        mapViewCtl.latitude = _convRecord.locationModel.lantitude;
        mapViewCtl.longitude = _convRecord.locationModel.longtitude;
        NSString *address = _convRecord.locationModel.address;
        NSArray *addressArr = [address componentsSeparatedByString:@"-"];
        if (addressArr.count == 1) {
            mapViewCtl.buildingName = addressArr[0];
            mapViewCtl.address = addressArr[0];
        }else{
            mapViewCtl.buildingName = addressArr[0];
            mapViewCtl.address = addressArr[1];
        }
        mapViewCtl.forwardRecord = _convRecord;
        
        [self.navigationController pushViewController:mapViewCtl animated:YES];
    }
}
- (void)addCommonGesture:(UITableViewCell *)cell
{
    //	头像
    [self processHeadImage:cell];
    [self addGestureToReceipt:cell];
    [self addGestureToFailButtonView:cell];
}

- (void)addGestureToReceipt:(UITableViewCell *)cell
{
    UIImageView *receiptView = (UIImageView*)[cell.contentView viewWithTag:receipt_tag];
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewReadStat:)];
    [receiptView addGestureRecognizer:singleTap1];
    [singleTap1 release];
}

- (void)addGestureToFile:(UITableViewCell *)cell
{
    UIView *fileView = (UIView*)[cell.contentView viewWithTag:file_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickFile:)];
    [fileView addGestureRecognizer:singleTap];
    [singleTap release];
}
- (void)addOpenRedRedpacket:(UITableViewCell *)cell
{
    UIView *fileView = (UIView*)[cell.contentView viewWithTag:red_pecket_view_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openRedRedpacket:)];
    [fileView addGestureRecognizer:singleTap];
    [singleTap release];
}

- (void)addOpenNews:(UITableViewCell *)cell
{
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openNews:)];
    [contentView addGestureRecognizer:singleTap];
    [singleTap release];
}
- (void)addGestureToStopFileDownload:(UITableViewCell *)cell
{
    //添加取消下载的按钮
    UIImageView *fileView = (UIImageView *)[cell.contentView viewWithTag:file_download_cancel_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickFileToStop:)];
    [fileView addGestureRecognizer:singleTap];
    [singleTap release];
}

- (void)showCanNotAccessPhotos
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"chats_talksession_message_photo_no_access"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

//当上传/下载图片、文件、录音失败时需要显示上传或下载失败的按钮，并且点击后可以重新下载，上传，原来是以UIButton的形式显示，滑动聊天记录是，button无法正常显示，所以改为UIImageview
- (void)addGestureToFailButtonView:(UITableViewCell *)cell
{
    UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
    failBtn.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reUploadOrDownload:)];
    [failBtn addGestureRecognizer:singleTap];
    [singleTap release];
    
}

- (void)reUploadOrDownload:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
	NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
	ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    
    //发送消息，并且是上传失败，那么可以重新上传
    if (_convRecord.msg_flag == send_msg && _convRecord.send_flag == send_upload_fail) {
        if(reSendAlert==nil)
        {
            reSendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_retransmit"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
            UILabel *tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
            tiplabel.backgroundColor=[UIColor clearColor];
            tiplabel.tag=tipMsgIDTag;
            [reSendAlert addSubview:tiplabel];
            [tiplabel release];
        }
        UILabel *tiplabel=(UILabel *)[reSendAlert viewWithTag:tipMsgIDTag];
        tiplabel.text=[StringUtil getStringValue:_convRecord.msgId];
        [reSendAlert show];
    }
    else if(_convRecord.msg_flag == rcv_msg)
    {
        [self downloadFile:_convRecord.msgId andCell:nil];
    }
}

#pragma mark ===========用户状态变化，需要刷新状态变化用户的状态=============
- (void)empStatusChange:(NSNotification *)_notification
{
    if (self.talkType == singleType || self.talkType == mutiableType)
    {
        NSDictionary *dic = _notification.userInfo;
        if (dic)
        {
            BOOL needReload = NO;
            NSArray *statusChangeArray = [dic valueForKey:key_status_change_array];
            
            for (NSDictionary *dic in statusChangeArray)
            {
                int curEmpId = [[dic valueForKey:@"emp_id"]intValue];
                int empStatus = [[dic valueForKey:@"emp_status"]intValue];
                int loginType = [[dic valueForKey:@"emp_login_type"]intValue];
                
                for (ConvRecord *_convRecord in self.convRecordArray) {
                    if (curEmpId == _convRecord.emp_id)
                    {
                        _convRecord.empStatus = empStatus;
                        _convRecord.empLoginType = loginType;
                        if (!needReload) {
                            needReload = YES;
//                            [LogUtil debug:@"talk session 发现一个用户状态变化了"];
                        }
                    }
                }
            }
            if (needReload)
            {
                [self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:YES];
                
            }
        }
    }
}
- (void)reloadTableData
{
    [self.chatTableView reloadData];
}

//设置聊天背景
- (void)setChatBackground
{
    if (self.talkType == singleType || self.talkType == mutiableType) {
        _conn.curConvId = self.convId;
        chatBackgroudView.image = [ChatBackgroundUtil getBackgroundOfConv:self.convId];
    }
    else
    {
        chatBackgroudView.image = [ChatBackgroundUtil getDefaultBackground];
    }
}



- (void)downloadByHand:(ConvRecord *)_convRecord
{
    int netType = [ApplicationManager getManager].netType;
    //    int netType = [[NetManger getManger] netType];
    if(netType == type_gprs)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[NSString stringWithFormat:@"%@【%@】?", [StringUtil  getLocalizableString:@"confirm_to_download_file"],_convRecord.fileNameAndSize] delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
        alert.tag = download_file_tag;
        UILabel *msgIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        msgIdLabel.text = [NSString stringWithFormat:@"%d",_convRecord.msgId];
        msgIdLabel.tag = download_file_msg_id_tag;
        [alert addSubview:msgIdLabel];
        
        [msgIdLabel release];
        
        [alert show];
        [alert release];
    }
    else
    {
        [self downloadResumeFile:_convRecord.msgId andCell:nil];
    }
}

#pragma mark - 文件下载
- (void)downloadResumeFile:(int)msgId andCell:(UITableViewCell*)_cell{
    if(![ApplicationManager getManager].isNetworkOk){
        
        return;
    }
    
    int _index = [self getArrayIndexByMsgId:msgId];
    
    if(_index < 0) return;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    if(cell == nil){
        cell = _cell;
    }
    
    UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
    failButton.hidden = YES;
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    _convRecord.isDownLoading = true;
    _convRecord.download_flag = state_downloading;
    int msgType = _convRecord.msg_type;
    
    NSString *urlStr;
    NSURL *url;
    
    NSString *rc = [StringUtil getUploadAddStr:@""];
    
    NSString *pathStr = @"";
    NSString *tempPath = @"";
    NSString *token = @"";
    switch (msgType) {
        case type_pic:
        {
            //  [[RobotDAO getDatabase]isRobotUser:self.convId.intValue]
            if ([self isTalkWithiRobot]){
                urlStr = _convRecord.robotModel.argsArray[0];
                pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.file_name]];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.png.zip",msgId,_convRecord.file_name]];
            }else{
                token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
                urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getNewPicDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
                pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.msg_body]];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.png.zip",msgId,_convRecord.msg_body]];
            }
        }
            break;
        case type_video:
        case type_record:
        {
            //  [[RobotDAO getDatabase]isRobotUser:self.convId.intValue]
            if ([self isTalkWithiRobot]){
                urlStr = _convRecord.robotModel.argsArray[3];
            }else{
                NSRange range = [_convRecord.msg_body rangeOfString:@"_"];
                if(range.length > 0){
                    token = [NSString stringWithFormat:@"%@",[_convRecord.msg_body substringToIndex:range.location]];
                }
                else{
                    token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
                }
                urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
            }
            pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
            tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,_convRecord.file_name]];
        }
            break;
        case type_file:
        {
            // [[RobotDAO getDatabase]isRobotUser:self.convId.intValue]
            if ([self isTalkWithiRobot]){
                urlStr = _convRecord.robotModel.argsArray[0];
                pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_convRecord.file_name];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[_convRecord.file_name stringByDeletingPathExtension]]];
            }else{
                //判断是否是本地发送出去的文件，如果是那么如果本地没有了
                NSRange range = [_convRecord.msg_body rangeOfString:@"_"];
                
                if(range.length > 0){
                    NSString *token = [NSString stringWithFormat:@"%@",[_convRecord.msg_body substringToIndex:range.location]];
                    if (maxSendFileSize == 20) {
                        //兼容旧版的url
                        NSString *oldUrlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase] getServerConfig] getAudioFileDownloadUrl],token];
                        urlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getDownloadAddStr:token]];
                    }
                    else{
                        urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
                    }
                    
                    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                else{
                    NSString *token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
                    if (maxSendFileSize == 20) {
                        //兼容旧版的url
                        NSString *oldUrlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase] getServerConfig] getAudioFileDownloadUrl],token];
                        urlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getDownloadAddStr:token]];
                    }
                    else{
                        urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
                    }
                }
                
                pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[talkSessionUtil getFileName:_convRecord]]];
            }
        }
            break;
        case type_long_msg:
        {
            token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
            urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
            
            pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
            tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.txt.zip",msgId,_convRecord.msg_body]];
        }
            break;
        default:
            break;
    }
    
    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],@"12111111212.zip"];
    //    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    @"http://124.238.219.85:80/FilesService/download/?token=beiIZj04158044&&userid=164411&t=1423099196&guid=1423099196392&mdkey=ec47583a5fafac33ec0cb1dea15e1342"
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,urlStr]];
    [request setDelegate:self];
    
    if (msgType == type_file) {
        //设置文件进度
        UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
        [talkSessionUtil displayProgressView:_progressView];
        [request setDownloadProgressDelegate:_progressView];
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else if (msgType == type_pic){
        //		显示进度条
        //UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
        UILabel *_progressView=(UILabel *)[cell.contentView viewWithTag:pic_progress_Label_tag];
        _progressView.hidden = NO;
        [request setDownloadProgressDelegate:_progressView];
    }
    //设置保存路径
    //    NSString *pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
    [request setDownloadDestinationPath:pathStr];
    
    //设置文件缓存路径
    //    NSString *tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[talkSessionUtil getFileName:_convRecord]]];
    [request setTemporaryFileDownloadPath:tempPath];
    
    //[request addRequestHeader:@"Range" value:@"bytes=0-"];
    [request setDidFinishSelector:@selector(downloadFileComplete:)];
    [request setDidFailSelector:@selector(downloadFileFail:)];
    [request setAllowResumeForFileDownloads:YES];
    
    //传参数，文件传输完成后，根据参数进行不同的处理
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:msgId],@"MSG_ID",nil]];
    [request setTimeOutSeconds:[self getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    
    [request startAsynchronous];
    [spinner startAnimating];
    
    _convRecord.downloadRequest = request;
    [request release];
    
    
    DownloadFileModel *fileMode = [[FileAssistantDOA getDatabase] getDownloadFileWithUploadid:[StringUtil getStringValue:msgId]];
    int uploadstate =  state_downloading;
    if (fileMode.download_id) {
        [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:[StringUtil getStringValue:msgId] withState:uploadstate];
    }
    else{
        //往数据添加上传记录
        NSMutableDictionary *downEvent = [[NSMutableDictionary alloc] init];
        [downEvent setObject:[StringUtil getStringValue:msgId] forKey:@"download_id"];
        [downEvent setObject:[NSNumber numberWithInt:uploadstate] forKey:@"download_state"];
        [[FileAssistantDOA getDatabase] addOneFileDownloadRecord:downEvent];
        [downEvent release];
    }
    
    if (msgType == type_file) {
        [[talkSessionUtil2 getTalkSessionUtil] addRecordToDownloadList:_convRecord];
    }
    
    
    
    //以下是ASI断点续传的原理，增加了请求的Range
    // Should this request resume an existing download?
    //    [self updatePartialDownloadSize];
    //    if ([self partialDownloadSize]) {
    //        [self addRequestHeader:@"Range" value:[NSString stringWithFormat:@"bytes=%llu-",[self partialDownloadSize]]];
    //    }
    
    
    
}

- (void)downloadFileComplete:(ASIHTTPRequest *)request{
    int statuscode=[request responseStatusCode];
    [LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,statuscode]];
    
    NSDictionary *dic=[request userInfo];
    NSString *_msgId = [dic objectForKey:@"MSG_ID"];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    [EncryptFileManege encryptExistFile:request.downloadDestinationPath];
    
    int _index = [self getArrayIndexByMsgId:_msgId.intValue];
    
    if(_index < 0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0){
            ConvRecord *_convRecord = [self getConvRecordByMsgId:_msgId];
            [talkSessionUtil transferFile:_convRecord];
            if(_convRecord.msg_type == type_pic){
                UILabel *progressView =(UILabel*)request.downloadProgressDelegate;
                progressView.hidden = YES;
                
                NSString *picPath = [request downloadDestinationPath];
                
                //		检查图片的尺寸，看是否需要裁剪
                NSData *data = [EncryptFileManege getDataWithPath:request.downloadDestinationPath];
                UIImage *img = [UIImage imageWithData:data];
                
                CGSize _size = [talkSessionUtil getImageSizeAfterCrop:img];
                
                if(_size.width > 0 && _size.height>0)
                {
                    img= [ImageUtil scaledImage:img  toSize:_size withQuality:kCGInterpolationHigh];
                }
                NSData *imageData=UIImageJPEGRepresentation(img,1);
                //                BOOL success= [imageData writeToFile:picPath atomically:YES];
                BOOL success = [EncryptFileManege saveFileWithPath:picPath withData:imageData];
                if(!success)
                    NSLog(@"保存失败");
            }
            else if( _convRecord.msg_type == type_file){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
            }
        }
        return;
    }
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    [talkSessionUtil transferFile:_convRecord];
    
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    int msgType = _convRecord.msg_type;
    if(statuscode == 404)
    {
        //文件不存在
        //记录至数据库中，下次不再加载
        [self updateSendFlagByMsgId:_msgId andSendFlag:-1];
        _convRecord.send_flag = -1;
        [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath error:nil];
        if(msgType == type_pic)
        {
            UILabel *progressView =(UILabel*)request.downloadProgressDelegate;
            progressView.hidden = YES;
        }
        else if (msgType == type_file){
            //文件不存在
            [self updateSendFlagByMsgId:_msgId andSendFlag:send_upload_nonexistent];
            _convRecord.send_flag = send_upload_nonexistent;
            
            //该文件对应的所有消息记录设置为过期
            [self setConvRecordsHasExpiredWithUrl:_convRecord.msg_body];
            
            int uploadstate = state_download_nonexistent;
            _convRecord.download_flag = uploadstate;
            [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
            
            UIProgressView *progressView = (UIProgressView*)request.downloadProgressDelegate;
            [talkSessionUtil hideProgressView:progressView];
            [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
            
            //提示文件过期
            [FileAssistantUtil showFileNonexistViewInView:self.view inTalkSession:YES];
        }
        else if (msgType == type_record || msgType ==type_long_msg || msgType == type_video){
            int uploadstate = state_download_nonexistent;
            _convRecord.download_flag = uploadstate;
            [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
        }
    }
    else if(statuscode != 200)
    {
        //下载失败
        [self downloadFileFail:request];
    }
    else
    {
        //下载成功,如果文件存在，并且size大于0，显示给用户，否则按照文件不存在处理
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0)
        {
            if(msgType == type_pic)
            {
                UILabel *progressView =(UILabel*)request.downloadProgressDelegate;
                progressView.hidden = YES;
                
                NSString *picPath = [request downloadDestinationPath];
                
                //		检查图片的尺寸，看是否需要裁剪
                //                UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
                NSData *data = [EncryptFileManege getDataWithPath:request.downloadDestinationPath];
                UIImage *img = [UIImage imageWithData:data];
                
                CGSize _size = [talkSessionUtil getImageSizeAfterCrop:img];
                
                if(_size.width > 0 && _size.height>0)
                {
                    img= [ImageUtil scaledImage:img  toSize:_size withQuality:kCGInterpolationHigh];
                }
                NSData *imageData=UIImageJPEGRepresentation(img,1);
                //                BOOL success= [imageData writeToFile:picPath atomically:YES];
                
                BOOL success = [EncryptFileManege saveFileWithPath:picPath withData:imageData];
                
                if(!success)
                {
                    NSLog(@"保存失败");
                }
                
                //更新下载状态为成功
                int uploadstate =  state_download_success;
                [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
                
                _convRecord.download_flag = uploadstate;
            }
            else if( _convRecord.msg_type == type_file){
                UIProgressView *progressView = (UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
                
                //更新下载状态为成功
                int uploadstate =  state_download_success;
                [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
                
                _convRecord.download_flag = uploadstate;
                
                [self updateConvFileRecordWithUrl:_convRecord.msg_body];
            }
            else if (msgType == type_record || msgType ==type_long_msg || msgType == type_video){
                //更新下载状态为成功
                int uploadstate =  state_download_success;
                [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
                
                _convRecord.download_flag = uploadstate;
            }
            
            [self reloadRow:_index+1];
            //            add by shisp 如果用户选择了转发文件或图片，那么在文件或图片下载成功后，应该打开选择联系人的界面
            //目前文件直接转发ulr了，所以转发的时候不去下载，而是判断服务器文件有没有，所以这里排除文件消息类型
            if (self.forwardRecord && (self.forwardRecord.msgId == _convRecord.msgId && self.forwardRecord.msg_type != type_file)) {
                [self openRecentContacts];
            }
        }
        else
        {
            
            [self updateSendFlagByMsgId:_msgId andSendFlag:-1];
            _convRecord.send_flag = -1;
            if(msgType == type_pic){
                UILabel *progressView =(UILabel*)request.downloadProgressDelegate;
                progressView.hidden = YES;
            }
            else if( _convRecord.msg_type == type_file){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
            }
        }
    }
}

-(void)downloadFileFail:(ASIHTTPRequest*)request{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    NSDictionary *dic=[request userInfo];
    NSString* _msgId = [dic objectForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:_msgId.intValue];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    if(request.error.code == ASIRequestTimedOutErrorType)
    {
        if(_index >= 0)
        {
            ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
            _convRecord.tryCount++;
            if(_convRecord.tryCount < max_try_count)
            {
                //继续尝试下载，否则报错
                //                [self downloadFile:_msgId.intValue andCell:nil];
                if (maxSendFileSize == 20) {
                    [self downloadFile:_msgId.intValue andCell:nil];
                }
                else {
                    if (_convRecord.msg_type == type_file || _convRecord.msg_type == type_record || _convRecord.msg_type ==type_long_msg || _convRecord.msg_type == type_pic || _convRecord.msg_type == type_video) {
                        [self downloadResumeFile:_msgId.intValue andCell:nil];
                    }
                    else{
                        [self downloadFile:_msgId.intValue andCell:nil];
                    }
                }
                return;
            }
        }
    }
    
    [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
    
    if(_index < 0) return;
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    _convRecord.tryCount = 0;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    if (_convRecord.msg_type == type_file || _convRecord.msg_type == type_record || _convRecord.msg_type ==type_long_msg || _convRecord.msg_type == type_pic || _convRecord.msg_type == type_video) {
        int uploadstate = state_download_failure;
        [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
        _convRecord.download_flag = uploadstate;
    }
    
    if (_convRecord.msg_type == type_file){
        //文件下载失败,显示失败按钮
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else{
        UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
        failBtn.hidden = NO;
    }
}

- (BOOL)isTalkWithiRobot
{
    if (self.talkType == singleType && self.convEmps.count > 0) {
        Emp *_emp = self.convEmps[0];
        if (_emp.empCode.length && [_emp.empCode compare:USERCODE_OF_IROBOT options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSLog(@"%s 是和机器人的对话",__FUNCTION__);
            
            return YES;
        }
    }
    return NO;
}


- (void)openNews:(UITapGestureRecognizer*)gesture{
    
#ifdef _LANGUANG_FLAG_
    
    LANGUANGAgentViewControllerARC *agent = [[LANGUANGAgentViewControllerARC alloc]init];
    CGPoint p = [gesture locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    //    NSArray *array = [_convRecord.newsModel.url componentsSeparatedByString:@"?"];
    //    if (array) {
    //
    //        agent.urlstr = array[0];
    //    }
    agent.urlstr = _convRecord.newsModel.url;
    [self.navigationController pushViewController:agent animated:YES];
    [agent release];
#endif
    
}

/*
#pragma mark - 文件下载
- (void)downloadResumeFile:(int)msgId andCell:(UITableViewCell*)_cell
{
    if(((AppDelegate *)[UIApplication sharedApplication].delegate).isNetworkOk)
    {
        return;
    }
    
    int _index = [self getArrayIndexByMsgId:msgId];
    
    if(_index < 0) return;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    if(cell == nil){
        cell = _cell;
    }
    
    UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
    failButton.hidden = YES;
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    _convRecord.isDownLoading = true;
    _convRecord.download_flag = state_downloading;
    int msgType = _convRecord.msg_type;
    
    NSString *urlStr;
    NSURL *url;
    
    NSString *rc = [StringUtil getUploadAddStr:@""];
    
    NSString *pathStr = @"";
    NSString *tempPath = @"";
    NSString *token = @"";
    switch (msgType) {
        case type_pic:
        {
            if ([self isTalkWithiRobot]){
                urlStr = _convRecord.robotModel.argsArray[0];
                pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.file_name]];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.png.zip",msgId,_convRecord.file_name]];
            }else{
                token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
                
                urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getNewPicDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
                
                pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.msg_body]];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.png.zip",msgId,_convRecord.msg_body]];
            }
        }
            break;
        case type_video:
        case type_record:
        {
            if ([self isTalkWithiRobot]){
                urlStr = _convRecord.robotModel.argsArray[3];
            }else{
                NSRange range = [_convRecord.msg_body rangeOfString:@"_"];
                if(range.length > 0){
                    token = [NSString stringWithFormat:@"%@",[_convRecord.msg_body substringToIndex:range.location]];
                }
                else{
                    token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
                }
                urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
            }
            
            pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
            tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,_convRecord.file_name]];
            
        }
            break;
        case type_file:
        {
            if ([self isTalkWithiRobot]){
                urlStr = _convRecord.robotModel.argsArray[0];
                pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_convRecord.file_name];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[_convRecord.file_name stringByDeletingPathExtension]]];
            }else{
                //判断是否是本地发送出去的文件，如果是那么如果本地没有了
                NSRange range = [_convRecord.msg_body rangeOfString:@"_"];
                
                if(range.length > 0){
                    NSString *token = [NSString stringWithFormat:@"%@",[_convRecord.msg_body substringToIndex:range.location]];
                    if (maxSendFileSize == 20) {
                        //兼容旧版的url
                        NSString *oldUrlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase] getServerConfig] getAudioFileDownloadUrl],token];
                        urlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getDownloadAddStr:token]];
                    }
                    else{
                        urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
                    }
                    
                    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                else{
                    NSString *token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
                    if (maxSendFileSize == 20) {
                        //兼容旧版的url
                        NSString *oldUrlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase] getServerConfig] getAudioFileDownloadUrl],token];
                        urlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getDownloadAddStr:token]];
                    }
                    else{
                        urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
                    }
                }
                
                pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[talkSessionUtil getFileName:_convRecord]]];
            }
        }
            break;
        case type_long_msg:
        {
            token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
            urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
            
            pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
            tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.txt.zip",msgId,_convRecord.msg_body]];
        }
            break;
        default:
            break;
    }
    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],@"12111111212.zip"];
    //    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    @"http://124.238.219.85:80/FilesService/download/?token=beiIZj04158044&&userid=164411&t=1423099196&guid=1423099196392&mdkey=ec47583a5fafac33ec0cb1dea15e1342"
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,urlStr]];
    [request setDelegate:self];
    
    if (msgType == type_file) {
        //设置文件进度
        UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
        [talkSessionUtil displayProgressView:_progressView];
        [request setDownloadProgressDelegate:_progressView];
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }else if (msgType == type_video)
    {
        //设置视频下载  进度
        UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:video_progress_tag];
        [talkSessionUtil displayProgressView:_progressView];
        [request setDownloadProgressDelegate:_progressView];
    }
    else if (msgType == type_pic){
        //		显示进度条
        //UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
        UILabel *_progressView=(UILabel *)[cell.contentView viewWithTag:pic_progress_Label_tag];
        _progressView.hidden = NO;
        [request setDownloadProgressDelegate:_progressView];
    }
    
    //设置保存路径
    //    NSString *pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
    [request setDownloadDestinationPath:pathStr];
    
    //设置文件缓存路径
    //    NSString *tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[talkSessionUtil getFileName:_convRecord]]];
    [request setTemporaryFileDownloadPath:tempPath];
    
    //[request addRequestHeader:@"Range" value:@"bytes=0-"];
    [request setDidFinishSelector:@selector(downloadFileComplete:)];
    [request setDidFailSelector:@selector(downloadFileFail:)];
    [request setAllowResumeForFileDownloads:YES];
    
    //传参数，文件传输完成后，根据参数进行不同的处理
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:msgId],@"MSG_ID",nil]];
    [request setTimeOutSeconds:[self getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    
    [request startAsynchronous];
    [spinner startAnimating];
    
    _convRecord.downloadRequest = request;
    [request release];
    
    
    DownloadFileModel *fileMode = [[FileAssistantDOA getDatabase] getDownloadFileWithUploadid:[StringUtil getStringValue:msgId]];
    int uploadstate =  state_downloading;
    if (fileMode.download_id) {
        [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:[StringUtil getStringValue:msgId] withState:uploadstate];
    }
    else{
        //往数据添加上传记录
        NSMutableDictionary *downEvent = [[NSMutableDictionary alloc] init];
        [downEvent setObject:[StringUtil getStringValue:msgId] forKey:@"download_id"];
        [downEvent setObject:[NSNumber numberWithInt:uploadstate] forKey:@"download_state"];
        [[FileAssistantDOA getDatabase] addOneFileDownloadRecord:downEvent];
        [downEvent release];
    }
    
    if (msgType == type_file) {
        [[talkSessionUtil2 getTalkSessionUtil] addRecordToDownloadList:_convRecord];
    }
    
    
    //以下是ASI断点续传的原理，增加了请求的Range
    // Should this request resume an existing download?
    //    [self updatePartialDownloadSize];
    //    if ([self partialDownloadSize]) {
    //        [self addRequestHeader:@"Range" value:[NSString stringWithFormat:@"bytes=%llu-",[self partialDownloadSize]]];
    //    }
    
    
    
}

#pragma mark 下载文件成功
- (void)downloadFileComplete:(ASIHTTPRequest *)request
{
    int statuscode=[request responseStatusCode];
    [LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,statuscode]];
    
    NSDictionary *dic=[request userInfo];
    NSString *_msgId = [dic objectForKey:@"MSG_ID"];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    int _index = [self getArrayIndexByMsgId:_msgId.intValue];
    
    if(_index < 0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0){
            ConvRecord *_convRecord = [self getConvRecordByMsgId:_msgId];
            [talkSessionUtil transferFile:_convRecord];
            if(_convRecord.msg_type == type_pic){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
                
                NSString *picPath = [request downloadDestinationPath];
                
                //		检查图片的尺寸，看是否需要裁剪
                UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
                
                CGSize _size = [talkSessionUtil getImageSizeAfterCrop:img];
                
                if(_size.width > 0 && _size.height>0)
                {
                    img= [ImageUtil scaledImage:img  toSize:_size withQuality:kCGInterpolationHigh];
                }
                NSData *imageData=UIImageJPEGRepresentation(img,1);
                BOOL success= [imageData writeToFile:picPath atomically:YES];
                if(!success)
                    NSLog(@"保存失败");
            }
            else if( _convRecord.msg_type == type_file){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
            }
        }
        return;
    }
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    [talkSessionUtil transferFile:_convRecord];
    
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    int msgType = _convRecord.msg_type;
    if(statuscode == 404)
    {//文件不存在
        //		记录至数据库中，下次不再加载
        [self updateSendFlagByMsgId:_msgId andSendFlag:-1];
        _convRecord.send_flag = -1;
        if(msgType == type_pic)
        {
            [talkSessionUtil hideProgressView:((UIProgressView*)request.downloadProgressDelegate)];
        }
        //		else if(msgType == type_long_msg)
        //		{
        [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
        //		}
    }
    else if(statuscode != 200)
    {//下载失败
        [self downloadFileFail:request];
    }
    else
    {//下载成功,如果文件存在，并且size大于0，显示给用户，否则按照文件不存在处理
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0)
        {
            if(msgType == type_pic)
            {
                [talkSessionUtil hideProgressView:((UIProgressView*)request.downloadProgressDelegate)];
                NSString *picPath = [request downloadDestinationPath];
                
                //		检查图片的尺寸，看是否需要裁剪
                UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
                
                CGSize _size = [talkSessionUtil getImageSizeAfterCrop:img];
                
                if(_size.width > 0 && _size.height>0)
                {
                    img= [ImageUtil scaledImage:img  toSize:_size withQuality:kCGInterpolationHigh];
                }
                NSData *imageData=UIImageJPEGRepresentation(img,1);
                BOOL success= [imageData writeToFile:picPath atomically:YES];
                if(!success)
                {
                    NSLog(@"保存失败");
                }
                //				UIViewController *topController = [self.navigationController topViewController];
                //				//				[LogUtil debug:[NSString stringWithFormat:@"%@",topController]];
                //				if([topController isKindOfClass:[self class]])
                //				{
                //					[talkSessionUtil sendReadNotice:_convRecord];
                //					//	预览图片
                //                    self.preImageFullPath=picPath;
                //                    localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
                //                    localGallery.imagePath=picPath;
                //                    [self.navigationController pushViewController:localGallery animated:YES];
                //                  //  self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
                //                    [localGallery release];
                //				}
            }
            else if( _convRecord.msg_type == type_file){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
            }
            
            [self reloadRow:_index+1];
            //            add by shisp 如果用户选择了转发文件，那么在文件下载成功后，应该打开选择联系人的界面
            if (self.forwardRecord && (self.forwardRecord.msgId == _convRecord.msgId)) {
                [self openRecentContacts];
            }
            
        }
        else
        {
            
            [self updateSendFlagByMsgId:_msgId andSendFlag:-1];
            _convRecord.send_flag = -1;
            if(msgType == type_pic)
            {
                [talkSessionUtil hideProgressView:((UIProgressView*)request.downloadProgressDelegate)];
            }
            else if( _convRecord.msg_type == type_file){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
            }
        }
    }
}

#pragma mark 下载文件失败
-(void)downloadFileFail:(ASIHTTPRequest*)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    NSDictionary *dic=[request userInfo];
    NSString* _msgId = [dic objectForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:_msgId.intValue];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    if(request.error.code == ASIRequestTimedOutErrorType)
    {
        if(_index >= 0)
        {
            ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
            _convRecord.tryCount++;
            if(_convRecord.tryCount < max_try_count)
            {//继续尝试下载，否则报错
                [self downloadFile:_msgId.intValue andCell:nil];
                return;
            }
        }
    }
    
    [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
    
    if(_index < 0) return;
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    
    _convRecord.tryCount = 0;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
    failBtn.hidden = NO;
}
*/
@end
