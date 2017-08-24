//
//  talkSessionViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//
#import "talkSessionViewController.h"

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "AudioReceiverModeUtil.h"
#endif

#ifdef _HUAXIA_FLAG_
#import "HuaXiaConfUtil.h"
#import "HuaXiaUserInterfaceDefine.h"
#endif

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

#ifdef _XIANGYUAN_FLAG_
#import "WaterMarkViewARC.h"
#import "FileAssistantRecordDOA.h"
#endif


#import "AESCipher.h"
static int recyle = 0;
#define download_file_tag (100)
#define download_file_msg_id_tag (101)
#define upload_video_tag (200)

/** 华夏创建网络会议的提示 */
#define create_huaxia_conf_alert_tag (201)

#define mapview_tag (10000)

@interface talkSessionViewController () <BMKMapViewDelegate,ForwardingDelegate>
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

//把talkSessionViewController设置成单例模式
//声明静态实例
//在objective-c中要实现一个单例类，至少需要做以下四个步骤：
//1、为单例对象实现一个静态实例，并初始化，然后设置成nil，
static talkSessionViewController *sharedObj;
@implementation talkSessionViewController
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
+(talkSessionViewController*)getTalkSession
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
            
#ifdef _XIANGYUAN_FLAG_
            
            // 添加水印
            [WaterMarkViewARC waterMarkView:sharedObj.view];
#endif
            
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
    //			检查一下是否有未读消息，并且记录数> 0，如果是，则显示，并且置为已读
    if (self.talkType == singleType || self.talkType == mutiableType || self.talkType == rcvMassType) {
        NSArray *notReadMsgIds =  [_ecloud getNotReadMsgId:self.convId];
        
        for(NSString *notReadMsgId in notReadMsgIds)
        {
            NSLog(@"显示未读的消息，msgid is %@",notReadMsgId);
            [self displayMsg:notReadMsgId];
        }
        
        NSMutableString *origin = [StringUtil getAppLocalizableString:@"main_chats"];
        if (self.fromType == talksession_from_chatRecordView) {
            origin = [StringUtil getLocalizableString:@"back"];
        }
        [PSBackButtonUtil showNoReadNum:nil andButton:backButton andBtnTitle:origin];
    }
    //    如果是显示在会话列表里的服务器，返回按钮需要显示数量，如果是显示在服务号里面的则没有必要吧 by shisp
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        [PSBackButtonUtil showNoReadNum:nil andButton:backButton];
    }
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
    if (isEditingConvRecord) {
        return;
    }
    NSString *urlStr = notification.object;
    
    NSLog(@"---urlstr-- %@",urlStr);
    // 泰禾  聊天界面的超链接在访问时要加上鉴权前缀
#ifdef _TAIHE_FLAG_
    urlStr = [[ServerConfig shareServerConfig]getAuthPreUrl:urlStr];
    NSLog(@"鉴权之后的url为:%@",urlStr);
#endif
    //    如果url中包含了龙湖轻应用的域名，那么以打开待办的方式打开url，并且要附加token 换成在方法里面进行判断
    [NewMyViewControllerOfCustomTableview openLongHuHtml5:urlStr withController:self];
}

-(void)shortAudioType:(NSNotification *)notification
{
    
    NSLog(@"---urlstr-- shortAudioType");
    picButton.tag=1;
    
    int index=talkButton.tag;
    
    if (index==1) {
        
        talkButton.tag=2;
        [talkSessionUtil2 setKeyboardIcon:talkButton];
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
        [talkSessionUtil2 setAudioIcon:talkButton];
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
    rcvFlagView = nil;
    if (self.talkType == mutiableType)
    {
        //    add by shisp 如果群组设置了消息不提醒，那么现实这个图标
        if([_ecloud getRcvMsgFlagOfConvByConvId:self.convId])
        {
            UIImage *noAlarmImage = [ImageUtil getNoAlarmImage:1];
            rcvFlagView = [[[UIImageView alloc]initWithImage:noAlarmImage]autorelease];
            
            CGRect _frame = rcvFlagView.frame;
            _frame.origin = CGPointMake(self.view.frame.size.width - 44 - noAlarmImage.size.width - 12, (44 - noAlarmImage.size.height)/2);
            rcvFlagView.frame = _frame;
            
            rcvFlagView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            [self.navigationController.navigationBar addSubview:rcvFlagView];
        }
    }
}


#pragma mark 一呼百应的处理
- (void)initYhby
{
    if (addScrollview!=nil) {
        [[eCloudUser getDatabase]getPurviewValue];
        isCanHundred=[[eCloudUser getDatabase]isCanHundred];
        
        //        [self showAddScrollow];
    }
    //    [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
    
    //    默认一呼百应是关闭的 并且修改群组名称按钮也是关闭的
    receiptMsgFlagButton.hidden = YES;
    receiptMsgFlag = conv_status_normal;
    
    [self hideModifyGroupNameButton];
    
    if ([self supportHuizhiMsg]) {//一呼万应消息 不用这个标志 回执消息状态不会一直保存，返回到会话列表里时，就取消了
        receiptMsgFlag = [_receiptDAO getConvStatus:self.convId];
        if(receiptMsgFlag == conv_status_receipt)
        {
            NSLog(@"%s 此时是一呼百应模式，需要显示为一呼百应模式",__FUNCTION__);
            [receiptMsgFlagButton setTitle:[StringUtil getLocalizableString:@"change_conv_status_to_normal_0"] forState:UIControlStateNormal];
            receiptMsgFlagButton.hidden = NO;
            [self hideModifyGroupNameButton];
        }
        else
        {
            receiptMsgFlagButton.hidden = YES;
            [self showModifyGroupNameButton];
        }
    }
}

#pragma mark 初始化textfield
- (void)initTextField
{
    //    update by shisp 已经没有必要
    return;
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
    [[NSNotificationCenter defaultCenter]addObserver:[RobotDisplayUtil getUtil] selector:@selector(processDownloadRobotFile:) name:DOWNLOAD_ROBOT_FILE__RESULT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(empStatusChange:) name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    
    //	监听离线消息收取
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcvOfflineMsgFinish) name:RCV_OFFLINE_MSG_NOTIFICATION object:nil];
    
    //监听登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
    // 没有连接通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noConnect:) name:NO_CONNECT_NOTIFICATION object:nil];
    
    //	被踢通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noConnect:) name: USER_NOTICE_OFFLINE object: nil];
    
    //正在连接通知，显示正在连接
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connecting) name:CONNECTING_NOTIFICATION object:nil];
    //打开网页
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openWebUrl:) name:OPEN_WEB_NOTIFICATION object:nil];
    //录音片，长录音
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shortAudioType:) name:SHORT_AUDIO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(longAudioType:) name:LONG_AUDIO_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
    
    if (!self.isHaveBeingHere) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processRecallMsgResult:) name:RECALL_MSG_RESULT_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reCalculateFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processGetUserInfoFromHX:) name:GET_USER_INFO_FROM_HX_NOTIFICATION object:nil];
        //监听输入框消息
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(handleCmd:)
                                                    name:CONVERSATION_NOTIFICATION
                                                  object:nil];
        //        增加接收群组名称修改通知
        //        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];
        
        self.isHaveBeingHere=YES;
        
    }
}

- (void)initConnStatus
{
    //    upate by shisp
    return;
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
    if (self.talkType == singleType || self.talkType == mutiableType || self.talkType == rcvMassType)
    {
        [[ReceiptMsgUtil getUtil]getNewPinMsgs];
        [[ReceiptMsgUtil getUtil]displayRecentPinMsg];
        
        self.unReadMsgCount = [_ecloud updateTextMessageToReadState:self.convId];
    }
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        [[PSMsgDspUtil getUtil]makeReadIfExistUnread];
    }
    
    //    不清楚为什么要赋值为nil by shisp
    //    self.navigationController.navigationItem.leftBarButtonItem=nil;
    
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
                    int all_num = [_ecloud getAllConvEmpNumByConvId:self.convId];
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
        
        NSString *tempString = [NSString stringWithFormat:@"%@(%d)",self.titleStr,all_num];
        
        strLabel.text = tempString;
#ifdef _BGY_FLAG_
        strLabel.textColor = [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:1];
#else
        strLabel.textColor = [UIAdapterUtil isLANGUANGApp]?[UIColor blackColor]:[ApplicationManager getManager].navigationTitleViewFontColor;// [UIColor whiteColor];
#endif
        strLabel.font = [ApplicationManager getManager].navigationTitleViewFont;// [UIFont boldSystemFontOfSize:20.0];
        strLabel.textAlignment = UITextAlignmentCenter;
        strLabel.backgroundColor = [UIColor clearColor];
        strLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        UIView *groupTitleView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, 120,44)];
        [groupTitleView addSubview:strLabel];
        [strLabel release];
        
        self.navigationItem.titleView = groupTitleView;
        
        [groupTitleView release];
        
        if (!listenModeViewNav) {
            if ([self.navigationController.topViewController isKindOfClass:[talkSessionViewController class]]) {
                listenModeViewNav = [contactViewController addListenModeView:self];
            }
        }
        [contactViewController setListenModeViewFrame:listenModeViewNav andTitleWidth:strLabel.frame.size.width];
        
    }
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        self.title = self.serviceModel.serviceName;
    }
    else
    {
        self.title = self.titleStr;
        
        CGSize _size = [self.titleStr sizeWithFont:[UIFont boldSystemFontOfSize:17]];
        
        if (!listenModeViewNav) {
            if ([self.navigationController.topViewController isKindOfClass:[talkSessionViewController class]]) {
                listenModeViewNav = [contactViewController addListenModeView:self];
            }
        }
        [contactViewController setListenModeViewFrame:listenModeViewNav andTitleWidth:_size.width];
        
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
    if (self.sendFileAssistantForwardMsgFlag) {
        //文件助手批量转发
        self.sendFileAssistantForwardMsgFlag = NO;
        [self sendFileAssistantForwardMsgs];
    }
    
    if (self.needUpdateTag==1)
    {
        isEditingConvRecord = NO;
        
        //		需要加载页面
        self.needUpdateTag=0;
        
        //        设置未加载的记录为空
        self.unloadQueryResultArray = [NSMutableArray array];
        
        //        如果是从查询结果打开会话列表界面，并且需要定位
        if (self.fromType == talksession_from_conv_query_result_need_position)
        {
            //            update by shisp 不再这里 remove 而是放在viewwillappear的开始
            //            if(self.convRecordArray.count > 0)
            //                [self.convRecordArray removeAllObjects];
            [self loadSearchResults:self.fromConv];
        }
        else
        {
            //            update by shisp 不再这里 remove 而是放在viewwillappear的开始
            //            if(self.convRecordArray.count > 0)
            //                [self.convRecordArray removeAllObjects];
            
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
    // 强行将状态栏文字颜色改为黑色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self refresh];
}

-(void)sendEnable
{
    //    是否能够发送消息 查看群组资料
    if(self.talkType == mutiableType){
        sendMsgEnable = [_ecloud userExistInConvEmp:self.convId];
    }
}

//设置聊天背景
- (void)setChatBackground
{
    if (self.talkType == singleType || self.talkType == mutiableType) {
        _conn.curConvId = self.convId;
        chatBackgroudView.image = [ChatBackgroundUtil getBackgroundOfConv:self.convId];
        [self displayModifyGroupNameButton];
    }
    else
    {
        chatBackgroudView.image = [ChatBackgroundUtil getDefaultBackground];
    }
}

-(void)createSingleConversation
{
    [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:self.convId andTitle:self.titleStr];
}

#pragma mark - 隐藏或显示
- (void)showAndHideRecordBtn{
    if (showAndHideRecord) {
        ServiceMenuModel *menuList = [[PublicServiceDAO getDatabase] getPSMenuListByPlatformid:serviceModel.serviceId];
        // 公众号状态且菜单不为0，才加载底部的菜单工具栏
        if((self.talkType == publicServiceMsgDtlConvType && menuList.platformid != 0) || ([self isTalkWithiRobot] && self.robotMenuArray.count > 0)){
            messageTextField_x = 80.0;
            record_x = 45;
            // 若二级子菜单已弹出，将其隐藏
            [menuView hiddenItemTable];
            if (!backFlag) {
                [self loadMenuView];
            }
            
        }else{
            // 去掉底部工具栏上的菜单按钮和菜单选择按钮
            [muneButton removeFromSuperview];
            muneButton = nil;
            
            [menuView removeFromSuperview];
            menuView = nil;
            UIImageView *lineImageView = (UIImageView *)[subfooterView viewWithTag:4000];
            [lineImageView removeFromSuperview];
            
            //            self.messageTextField.hidden = NO;
            self.textView.hidden = NO;
            iconButton.hidden = NO;
            picButton.hidden = NO;
            talkButton.hidden = NO;
            messageTextField_x = input_text_x;
            record_x = talk_button_x;
            messageParsex = 0;
        }
        
        //加2更好显示13个字
        if(IOS7_OR_LATER)
        {
            messageTextField_width = input_text_width - messageParsex;
        }
        else
        {
            messageTextField_width = self.view.frame.size.width-122 - messageParsex;
        }
    }
    else{
        talkButton.hidden = YES;
        messageTextField_x = 10.0;
        messageTextField_width = self.view.frame.size.width-100 - messageParsex;
        //        if ([self.messageTextField isHidden]) {
        if ([self.textView isHidden]) {
            //如果前一个会话是显示录音按钮，当前会话是不显示录音按钮的
            [self talkAction:talkButton];
        }
    }
    
    CGRect frame = self.messageTextField.frame;
    frame.origin.x = messageTextField_x;
    frame.origin.y = input_text_y; // 将文本框下调两个像素，使得上下间距一致
    frame.size.width = messageTextField_width;
    
    //    [self.messageTextField setFrame:frame];
    [self setTextViewFrame:frame];
    
    //    NSLog(@"pressButtonFrame = %@",NSStringFromCGRect(pressButton.frame));
    
    CGRect talkFrame = talkButton.frame;
    talkFrame.origin.x = record_x;
    [talkButton setFrame:talkFrame];
    
    // 0730 update by yanlei “按住说话”按钮在普通会话和服务号会话中切换frame的变化
    [pressButton setFrame:frame];
}
#pragma mark 退出聊天界面
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    BMKMapView *mapView = [self.view viewWithTag:mapview_tag];
    [mapView viewWillDisappear];
    
    _statusConn.curViewController = nil;
    
    [listenModeViewNav removeFromSuperview];
    listenModeViewNav = nil;
    
    if (rcvFlagView) {
        [rcvFlagView removeFromSuperview];
    }
    if(self.talkType == publicServiceMsgDtlConvType)
    {
        backFlag = YES;
        menuView.selectedBottomIndex = -1;
    }
    [self showAndHideRecordBtn];
    
    [[NSNotificationCenter defaultCenter] removeObserver:[RobotDisplayUtil getUtil] name:DOWNLOAD_ROBOT_FILE__RESULT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];
    
    //	监听系统菜单显示，隐藏
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    
    //	离线消息接收完毕通知，不再显示提示
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RCV_OFFLINE_MSG_NOTIFICATION object:nil];
    
    //    没有连接通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NO_CONNECT_NOTIFICATION object:nil];
    //	被踢通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:USER_NOTICE_OFFLINE object:nil];
    //	连接中通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CONNECTING_NOTIFICATION object:nil];
    //登录通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:LOGIN_NOTIFICATION object:nil];
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    //    // 键盘高度变化通知，ios5.0新增的
    //#ifdef __IPHONE_5_0
    //    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    //    if (version >= 5.0) {
    //		[[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    //    }
    //#endif
    
    // 把键盘隐藏
    if (iconButton.tag == 2)
    {
        [self moodIconAction:iconButton];
    }
    [self.messageTextField resignFirstResponder];
}

#pragma mark 展示一条聊天消息
-(void)displayMsg:(NSString *)msgId
{
    ConvRecord *record = [self  getConvRecordByMsgId:msgId];
    
    if([record.conv_id isEqualToString:self.convId] && (record.read_flag == 1 || record.msg_flag == send_msg))
    {
        [self addOneRecord:record andScrollToEnd:false];
        
        NSLog(@"是当前会话的消息，并且显示");
        
        if (self.chatTableView.contentOffset.y<self.chatTableView.contentSize.height-(self.view.frame.size.height-110)-300) {
            NSLog(@"－－－－－不刷新，不置底部");
            if ([self isTalkWithiRobot] || record.locationModel){
                [self scrollToEnd];
            }
        }else{
            [self scrollToEnd];
        }
        if(record.read_flag == 1 && (self.talkType == singleType || self.talkType == mutiableType))
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
        case receive_msg_read_notify:
        {
            NSDictionary *dic = cmd.info;
            
            if (dic) {
                [PSBackButtonUtil showNoReadNum:nil andButton:backButton andBtnTitle:[StringUtil getAppLocalizableString:@"main_chats"]];
            }
        }
            break;
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
                        [LogUtil debug:[NSString stringWithFormat:@"%s 收到了消息已读的通知",__FUNCTION__]];
                        if (convRecord.isMiLiaoMsg) {
                            convRecord.miLiaoMsgLeftTime = MILIAO_MSG_LIVE_TIME;
                        }
                        [self.convRecordArray replaceObjectAtIndex:i withObject:convRecord];
                        [self reloadRow:i + 1];
                        break;
                    }
                }
            }
        }
            break;
        case open_encrypt_msg:
        {
            //            打开了密聊消息
            NSDictionary *dic = cmd.info;
            NSString *msgId = [dic objectForKey:@"MSG_ID"];
            ConvRecord *convRecord = [self getConvRecordByMsgId:msgId];
            NSString *convId = convRecord.conv_id;
            
            if([convId isEqualToString:self.convId])
            {
                int _index = [self getArrayIndexByMsgId:msgId.intValue];
                if (_index >= 0) {
                    ConvRecord *oldConvRecord = self.convRecordArray[_index];
                    oldConvRecord.msg_type = convRecord.msg_type;
                    oldConvRecord.msg_body = convRecord.msg_body;
                    oldConvRecord.receiptTips = convRecord.receiptTips;
                    oldConvRecord.isMiLiaoMsgOpen = convRecord.isMiLiaoMsgOpen;
                    
                    [talkSessionUtil setPropertyOfConvRecord:oldConvRecord];
                    
                    [self reloadTableData];
                    /** 如果是文本类型的消息，那么马上发出已读 */
                    if (convRecord.msg_type == type_text) {
                        [talkSessionUtil sendReadNoticeByHand:convRecord];
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
                
                int index = 0;
                for(int i = self.convRecordArray.count - 1;i>=0;i--)
                {
                    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
                    if(_convRecord.origin_msg_id == _originMsgId)
                    {
                        if (_convRecord.isMiLiaoMsg) {
                            _convRecord.miLiaoMsgLeftTime = MILIAO_MSG_LIVE_TIME;
                            switch (_convRecord.msg_type) {
                                case type_record:{
                                    _convRecord.miLiaoMsgLeftTime = MILIAO_MSG_LIVE_TIME + _convRecord.file_size.intValue;
                                }
                                    break;
                                    //                                case type_video:{
                                    //                                    _convRecord.miLiaoMsgLeftTime = MILIAO_MSG_LIVE_TIME;// + _convRecord.videoSeconds;
                                    //                                }
                                    //                                    break;
                                    
                                default:
                                    break;
                            }
                        }
                        _convRecord.readNoticeFlag = 1;
                        _convRecord.receiptTips = [_receiptDAO getReadStateOfMsg:_convRecord];
                        hasFind = YES;
                        index = i;
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
                if (hasFind) {
                    if ([eCloudConfig getConfig].autoSendMsgReadOfHuizhiMsg) {
                        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:index]];
                        cell.backgroundColor = [UIColor whiteColor];
                        [self performSelector:@selector(reloadTableData) withObject:nil afterDelay:0.8];
                    }else{
                        [self reloadTableData];
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
                        if(self.talkType == singleType || self.talkType == mutiableType)
                        {
                            NSString *msgId = _notice.msgId;
                            NSLog(@"收到通知,msgId is %@",msgId);
                            [self displayMsg:msgId];
                        }
                    }
                    else if (_notice.msgType == ps_new_msg_type)
                    {
                        [[PSMsgDspUtil getUtil]displayRcvPsMsg:_notice];
                    }
                    else if(_notice.msgType == mass_reply_msg_type)
                    {
                        if(self.talkType == massType)
                        {
                            NSString *convId = _notice.convId;
                            if([convId isEqualToString:self.convId])
                            {
                                NSString *msgId = _notice.msgId;
                                
                                int index = [self getArrayIndexByMsgId:msgId.intValue];
                                if(index > 0)
                                {
                                    ConvRecord *_convRecord = [self getConvRecordByMsgId:msgId];
                                    
                                    ConvRecord *convRecord = [self.convRecordArray objectAtIndex:index];
                                    convRecord.mass_reply_emp_count = _convRecord.mass_reply_emp_count;
                                    [self.chatTableView reloadData];
                                }
                            }
                        }
                        return;
                    }
                    
                    [self showNoReadNum];
                }
            }
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
            if(msgId && (self.talkType == singleType || self.talkType == mutiableType || self.talkType == rcvMassType))
            {
                //				参数是0，表示发送成功
                [self updateStatus:msgId andStatus:@"0"];
            }
            
            NSLog(@"send success");
        }
            break;
        case send_msg_failure:
        {
            NSLog(@"send failure");
            NSDictionary *dic = cmd.info;
            int resultCode = [dic[@"result_code"]intValue];
            if (resultCode == RESULT_VIRGTOUP_OUTOF_SVC) {
                //                提示用户 人工服务不在线
                [[talkSessionUtil2 getTalkSessionUtil]createTipsRecordOfVirtualUser:self.convId];
            }
            
        }
            break;
        case create_group_success:
        {
            [[LCLLoadingView currentIndicator]hiddenForcibly:true];
            
            NSDictionary *_dic = cmd.info;
            NSString *convId = [_dic valueForKey:@"CONV_ID"];
            
            [UserDefaults removeModifyGroupNameFlag:convId];
            
            if(![convId isEqualToString:self.convId])
                return;
            
            NSLog(@"分组创建成功");
            NSLog(@"多人会话：%@ ",self.convId);
            
            //            不用修改title,目前不再根据第一条消息做为群组名称
            //			if(self.firstMsgType == type_text)
            //			{
            //				self.titleStr = [[MessageView getMessageView] replaceFaceStrWithText:self.firstMsgStr];
            //			}
            //			else if(self.firstMsgType == type_pic)
            //			{
            //
            //				self.titleStr = [StringUtil getLocalizableString:@"msg_type_pic"];
            //			}else if(self.firstMsgType == type_record)
            //			{
            //				self.titleStr = [StringUtil getLocalizableString:@"msg_type_record"];
            //			}
            //			else if(self.firstMsgType == type_long_msg)
            //			{
            //				self.titleStr = self.firstFileName;
            //			}
            
            //群组创建成功后，发送第一条消息，为了和群组创建的时间区分开，所以这里增加了1
            int nowtimeInt=[_conn getCurrentTime]+1;
            //            要再群组创建时间的基础上+1
            NSNumber *_number = [_dic valueForKey:@"group_create_time"];
            if (_number)
            {
                nowtimeInt = [_number intValue] + 1;
            }
            
            NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
            
            if (self.last_msg_id==-1)
            {
                //                helperObject *hobject=[_ecloud getTheDateScheduleByGroupID:self.convId];
                //                if (hobject==nil) {
                //                    [_ecloud updateConvInfo:self.convId andType:0 andNewValue:self.titleStr];
                //                    if (self.talkType == mutiableType) {
                //                        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
                //                        self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],self.titleStr,all_num];
                //                    }else
                //                    {
                //                        self.title=self.titleStr;
                //                    }
                //                }
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
                
                self.titleStr = [_dic valueForKey:@"group_name"];
                //                update by shisp 在聊天界面显示群组通知时，会自动更新title
                //				self.titleStr = [_dic valueForKey:@"group_name"];
                //                if (self.talkType == mutiableType) {
                //                    int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
                //                    self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],self.titleStr,all_num];
                //                }else
                //                {
                //                    self.title=self.titleStr;
                //                }
            }
        }
            break;
        case group_member_change:
        {
            //            取出 群组id，如果和本会话id相同，则需要做一些操作
            
            NSDictionary *dic = notification.userInfo;
            if (dic) {
                NSString *rcvConvId = [dic valueForKey:@"conv_id"];
                if ([rcvConvId isEqualToString:self.convId])
                {
                    [self sendEnable];
                    [self setRightBtn];
                }
                
                //                update by shisp 在聊天界面显示群组通知时，会自动更新title
                //                [self initTitle];
            }
        }
        default:
            break;
    }
    
}

- (void)changeArrowsImg
{
    UIImageView *arrowsImg = [knowledgeBtn viewWithTag:501];
    [arrowsImg setImage:[StringUtil getImageByResName:@"knowledge_down52-32.png"]];
}

#pragma mark 查看会话资料
-(void)chatMessageAction:(id)sender
{
    //释放
    [KxMenu dismissMenu];
    
    if (_conn.userStatus == status_online && self.talkType==mutiableType && self.convId.length > 0) {
        if (![[UserDataDAO getDatabase]isSystemGroup:self.convId]) {
            [_conn getGroupInfo:self.convId];
        }
    }
    if (self.talkType == singleType || self.talkType == mutiableType) {
        if ([self isTalkWithiRobot]) {
            
            knowledgeBtn = sender;
            UIImageView *arrowsImg = [(UIView *)sender viewWithTag:501];
            [arrowsImg setImage:[StringUtil getImageByResName:@"knowledge_up52-32.png"]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeArrowsImg) name:@"changeArrowsNotification" object:nil];
            
            [[RobotDisplayUtil getUtil]openKnowledgeBase];
        }else{
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
                
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
                /** 如果是华夏，那么登录用户显示在第一个位 */
                if (chatMessage.dataArray.count == 2) {
                    Emp *_emp = chatMessage.dataArray[0];
                    if (_emp.emp_id == _conn.userId.intValue) {
                        //                        已经是第一个
                    }else{
                        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:chatMessage.dataArray];
                        [tempArray removeObject:_emp];
                        [tempArray addObject:_emp];
                        chatMessage.dataArray = tempArray;
                    }
                }
#endif
                
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
        }
    }
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        [[PSMsgDspUtil getUtil]viewServiceInfo:self andServiceModel:self.serviceModel];
    }
}

#pragma mark —— 获取联系人联系方式
-(void)getContactInformation
{
    Emp *emp = [_ecloud getEmployeeById:self.convId];
    [PhoneUtil showPopView:self andTargetButton:telButton andEmp:emp];
}

-(void)dealloc {
    NSLog(@"%s",__FUNCTION__);
    
    self.serviceModel = nil;
    
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
    
    
    [footerView release];
    [personInfo release];
    
    [manyFilesArray release];
    manyFilesArray = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@""];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark ------viewdidload-----here----
- (void)viewDidLoad
{
    NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    _psDAO = [PublicServiceDAO getDatabase];
    _receiptDAO = [ReceiptDAO getDataBase];
    massDAO = [MassDAO getDatabase];
    queryDAO = [QueryDAO getDatabase];
    
    _statusConn = [StatusConn getConn];
    
}

#pragma mark 根据会话类型显示不同的图片
-(void)setRightBtn
{
    if ([self isTalkWithiRobot])
    {
        self.navigationItem.rightBarButtonItems = nil;
        UIButton *_button = [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"chats_talksession_right_btn_title_of_irobot"] andTarget:self andSelector:@selector(chatMessageAction:)];
        
        UIImageView *arrowsImg = [[UIImageView alloc] initWithImage:[StringUtil getImageByResName:@"knowledge_down52-32.png"]];
        arrowsImg.frame = CGRectMake(_button.frame.size.width - 21, 13, 15, 20);
        arrowsImg.tag = 501;
        [_button addSubview:arrowsImg];
        _button.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
        
        return;
    }
    self.navigationItem.rightBarButtonItems = self.rightBtnItems;
    
    telButton.hidden = YES;
    telButton.enabled = NO;
    if (self.talkType == singleType)
    {
        /** 如果不是密聊则显示电话 */
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
            Emp *emp =  [_ecloud getEmployeeById:[[MiLiaoUtilArc getUtil]getEmpIdWithMiLiaoConvId:self.convId]];
            if (!emp.info_flag) {
                [_ecloud getUserInfoAndDownloadLogo:[[MiLiaoUtilArc getUtil]getEmpIdWithMiLiaoConvId:self.convId]];
            }
        }else{
            //        update by shisp 这里只是判断 是否有电话号码 ，所以代码需要优化
            Emp *emp =  [_ecloud getEmployeeById:self.convId];
            if (!emp.info_flag) {
                [_ecloud getUserInfoAndDownloadLogo:self.convId];
            }
            
            if ([PhoneUtil needDisplayPhoneButton:emp]) {
                if (![self.convId isEqualToString:File_ID]) {
                    
                    telButton.hidden = NO;
                    telButton.enabled = YES;
                }
            }
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
        
        if(self.talkType==singleType || self.talkType == publicServiceMsgDtlConvType)
        {
            if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
                addButton.hidden = YES;
                return;
            }
            if ([self isTalkWithiRobot]) {
                [addButton setBackgroundImage:nil forState:UIControlStateNormal];
                [addButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_right_btn_title_of_irobot"] forState:UIControlStateNormal];
            }else{
                [addButton setBackgroundImage:[StringUtil getImageByResName:@"SingleMember"] forState:UIControlStateNormal];
                [addButton setBackgroundImage:[StringUtil getImageByResName:@"SingleMember_hl"] forState:UIControlStateHighlighted];
            }
            if ([self.convId isEqualToString:File_ID] || [self.convId isEqualToString:SECRETARY_ID] ||[self.convId isEqualToString:MEETING_ID] || [self.convId isEqualToString:MEETING_ID_TEST]) {
                
                    addButton.hidden = YES;
                    addButton.enabled = NO;
                
            }else{
                
                addButton.enabled = YES;
            }
        }
        else if(self.talkType == mutiableType)
        {
            //			if([_ecloud userExistInConvEmp:self.convId])
            if(sendMsgEnable)
            {
                //				NSLog(@"用户在群里，可以查看群组信息");
                [addButton setBackgroundImage:[StringUtil getImageByResName:@"GroupMember"] forState:UIControlStateNormal];
                [addButton setBackgroundImage:[StringUtil getImageByResName:@"GroupMember_hl"] forState:UIControlStateHighlighted];
                addButton.enabled = YES;
            }
            else
            {
                NSLog(@"用户不在群里，禁止查看群组信息");
                [addButton setBackgroundImage:[StringUtil getImageByResName:@"ic_actbar_chat_group_disable"] forState:UIControlStateNormal];
                
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
    //    默认是 图片 拍照 文件 ，如果是单聊 群聊 收到的一呼万应消息 并且有一呼百应权限 才可以
    
    int sumnum = functionArray.count;
    
    int numberOfIconEachLine = 4;
    //    if ( IS_IPHONE_6P) {
    //        numberOfIconEachLine = 5;
    //    }
    
    float buttonSize = 60.0;
    float labelHeight = 20.0;
    
    int page = sumnum / numberOfIconEachLine + (sumnum % numberOfIconEachLine ? 1 : 0);
    
    float paddingX = (addScrollview.frame.size.width - numberOfIconEachLine * buttonSize) / (numberOfIconEachLine + 1);
    float paddingY = 15;
    
    addScrollview.pagingEnabled = YES;
    addScrollview.scrollEnabled = YES;
    addScrollview.contentSize = CGSizeMake(addScrollview.frame.size.width, (paddingY + buttonSize + labelHeight) * page);
    
    for (int i = 0; i < sumnum; i++) {
        
        FunctionButtonModel *_model = [functionArray objectAtIndex:i];
        
        int row = i / numberOfIconEachLine;
        int col = i % numberOfIconEachLine;
        
        UIButton *iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(paddingX + (buttonSize + paddingX) * col,paddingY + (paddingY + buttonSize + labelHeight) * row ,buttonSize,buttonSize)];
        
        iconbutton.backgroundColor=[UIColor clearColor];
        if (_model.clickSelector) {
            [iconbutton addTarget:self action:_model.clickSelector forControlEvents:UIControlEventTouchUpInside];
        }
        if (i == 0) {
            [LogUtil addLongPressToButton1:iconbutton];
        }else if (i == 1){
            [LogUtil addLongPressToButton2:iconbutton];
        }else if (i == 2){
            [LogUtil addLongPressToButton3:iconbutton];
        }else if (i == 3){
            [LogUtil addLongPressToButton4:iconbutton];
        }else if (i == 4){
            [LogUtil addLongPressToButton5:iconbutton];
        }
        [iconbutton setImage:[StringUtil getImageByResName:_model.imageName]forState:UIControlStateNormal];
        [iconbutton setImage:[StringUtil getImageByResName:_model.hlImageName] forState:UIControlStateSelected];
        [iconbutton setImage:[StringUtil getImageByResName:_model.hlImageName] forState:UIControlStateHighlighted];
        
        [addScrollview addSubview:iconbutton];
        [iconbutton release];
        
        UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, buttonSize, buttonSize, labelHeight)];
        nameLabel.text = _model.functionName;
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont systemFontOfSize:12];
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.textAlignment=UITextAlignmentCenter;
        [iconbutton addSubview:nameLabel];
        [nameLabel release];
    }
}
#pragma mark - pic
- (void)photosLibraryManager:(photosLibraryManager *)manager error:(NSError *)error
{
    [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
}

- (void)photosLibraryManager:(photosLibraryManager *)manager pictureInfo:(NSArray *)pictures
{
    long long end = [StringUtil currentMillionSecond];
    [LogUtil debug:[NSString stringWithFormat:@"%s 从点击到获取图片完毕需要时间%lld,获取图片张数为%d",__FUNCTION__,(end - selectPicStart),pictures.count]];
    
    selectPicStart = end;
    
    [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
    
    LCLShareThumbController*assetTable		=	[[LCLShareThumbController alloc]initWithNibName:nil bundle:nil];
    ELCImagePickerController *elcPicker		=	[[ELCImagePickerController alloc] initWithRootViewController:assetTable];
    assetTable.pre_delegete=self;
    [assetTable setParent:elcPicker];
    [assetTable preparePhotos:pictures];
    [elcPicker setDelegate:self];
    
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
        [self presentViewController:elcPicker animated:YES completion:^{
            
        }];
    }else{
        [UIAdapterUtil presentVC:elcPicker];
    }
    //    [self presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [assetTable release];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s ,从取完图片到打开图片界面需要时间%lld",__FUNCTION__,[StringUtil currentMillionSecond] - selectPicStart]];
    
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)resetReceiptButton
{
    receiptMsgFlagButton.backgroundColor = defaultBgColorOfReceiptButton;
}
-(void)changeConvStatusAction
{
    if (!receiptMsgFlagButton.hidden) {
        
        receiptMsgFlagButton.hidden=YES;
        [self showModifyGroupNameButton];
        
        [[ReceiptMsgUtil getUtil]displayRecentPinMsg];
        
        receiptMsgFlag = conv_status_normal;
        [_receiptDAO setConvStatus:self.convId andStatus:receiptMsgFlag];
        
        
        
        //        picButton.tag=1;
        //
        //        tableBackGroudButton.hidden=YES;
        //        if(self.messageTextField.isFirstResponder)
        //        {
        //            [self.messageTextField resignFirstResponder];
        //        }
        //        else
        //        {
        //            [self autoMovekeyBoard:0];
        //        }
        NSLog(@"%s,切换为正常模式状态",__FUNCTION__);
    }
}
#pragma mark 初始化聊天界面需要的UI控件
-(void)initControls
{
    isEditingConvRecord = NO;
    
    recordQueue = [[NSOperationQueue alloc]init];
    
    //    聊天背景
    chatBackgroudView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height)];
    chatBackgroudView.clipsToBounds = YES;
    chatBackgroudView.contentMode = UIViewContentModeScaleAspectFill;
    chatBackgroudView.userInteractionEnabled = YES;
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchActions)];
    //    [chatBackgroudView addGestureRecognizer:tap];
    [self.view addSubview:chatBackgroudView];
    [chatBackgroudView release];
    
    NSLog(@"--here--initControls");
    
    //    播放录音 录音文件转换
    //add amr to wav
    amrtowav=[[amrToWavMothod alloc]init];
    audioplayios6=[[AudioPlayForIOS6 alloc]init];
    
    //    播放录音的动画
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
    
    //    不处理一呼百应
    //    [[eCloudUser getDatabase]getPurviewValue];
    //    isCanHundred=[[eCloudUser getDatabase]isCanHundred];
    
    //    UIImage *image = [StringUtil getImageByResName:@"001.png"];
    //    CGImageRef imageRef = [image CGImage];
    //    faceWidth = CGImageGetWidth(imageRef);
    //    faceHeight = CGImageGetHeight(imageRef);
    
    
    //    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    //    self.messageString = tempStr;
    //    [tempStr release];
    
    //
    //	NSDate   *tempDate = [[NSDate alloc] init];
    //	self.lastTime = tempDate;
    //	[tempDate release];
    
    
    // 初始化表情集合
    [self loadFaceArray];
    //    准备表情数组
    [self prepareFaceArray];
    
    int tableH = self.view.frame.size.height-input_area_height-44;
    if (IOS7_OR_LATER)
    {
        tableH -= 20;
    }
    //    if(iPhone5)
    //        tableH = tableH + i5_h_diff;
    
    self.chatTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableH) style:UITableViewStyleGrouped]autorelease];
    
    [self.chatTableView setDelegate:self];
    [self.chatTableView setDataSource:self];
    
    //self.chatTableView.backgroundView.backgroundColor=[UIColor clearColor];
    self.chatTableView.backgroundView = nil;
    if ([UIAdapterUtil isGOMEApp])
    {
        self.chatTableView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    }
    else
    {
        self.chatTableView.backgroundColor = [UIColor clearColor];
    }
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
    
    tableBackGroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableH)];
    tableBackGroudButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    // tableBackGroudButton.backgroundColor=[UIColor lightGrayColor];
    [tableBackGroudButton addTarget:self action:@selector(tableBackGroudAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:tableBackGroudButton];
    tableBackGroudButton.hidden=YES;
    
    tableBackGroudButtonForHiddenSubMenu=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableH)];
    tableBackGroudButtonForHiddenSubMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    // tableBackGroudButton.backgroundColor=[UIColor lightGrayColor];
    [tableBackGroudButtonForHiddenSubMenu addTarget:self action:@selector(hiddenSubMenuAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:tableBackGroudButtonForHiddenSubMenu];
    tableBackGroudButtonForHiddenSubMenu.hidden=YES;
    
    defaultBgColorOfReceiptButton = [[talkSessionUtil getBgColorOfReceiptModelColor]retain];// [[UIColor alloc]initWithRed:54/255.0  green:54/255.0  blue:54/255.0  alpha:0.7];
    highlightBgColorOfReceiptButton = [[talkSessionUtil getHLBgColorOfReceiptModelColor]retain]; //[[UIColor alloc]initWithRed:37/255.0 green:157/255.0 blue:29/255.0 alpha:0.7];
    
    //    update by shisp
    receiptMsgFlagButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    receiptMsgFlagButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    receiptMsgFlagButton.hidden=YES;
    receiptMsgFlagButton.backgroundColor= defaultBgColorOfReceiptButton;
    [receiptMsgFlagButton addTarget:self action:@selector(changeConvStatusAction) forControlEvents:UIControlEventTouchUpInside];
    //    初始化控件时不需要设置初始值
    NSString *tempStr = @"";
    [receiptMsgFlagButton setTitle:tempStr forState:UIControlStateNormal];
    receiptMsgFlagButton.titleLabel.font=[UIFont systemFontOfSize:14];
    
    [receiptMsgFlagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [receiptMsgFlagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [receiptMsgFlagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.view addSubview:receiptMsgFlagButton];
    [receiptMsgFlagButton release];
    
    //听筒模式
    listenModeView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    listenModeView.backgroundColor= [[UIColor alloc]initWithRed:54/255.0  green:54/255.0  blue:54/255.0  alpha:0.5];// defaultBgColorOfReceiptButton;
    [self.view addSubview:listenModeView];
    listenModeView.alpha=0;
    UIImageView *type_image_view=[[UIImageView alloc]initWithFrame:CGRectMake(5, (listenModeView.frame.size.height - 30) * 0.5, 30, 30)];
    type_image_view.tag=1;
    type_image_view.image=[StringUtil getImageByResName:@"listen_mode_er_now.png"];
    [listenModeView addSubview:type_image_view];
    [type_image_view release];
    UILabel *modetipLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 2.5, listenModeView.frame.size.width - 75, 35)];
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
    // changed by toxicanty 适配
    loadingIndic.frame=CGRectMake(self.view.frame.size.width/2 - 5,5, 30.0f,30.0f);
    
    loadingIndic.hidden = YES;
    isLoading = false;
    
    //	标题栏
    //    update by shisp 界面显示时会更新title，这里不用初始化
    //    if (self.talkType == mutiableType) {
    //        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
    //        self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],self.titleStr,all_num];
    //    }else
    //    {
    //        self.title=self.titleStr;
    //    }
    
    //	手动连接按钮相关代码
    //	self.topactivity=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //    self.topactivity.frame=CGRectMake(65, 10, 30, 30);
    //	[self.navigationController.navigationBar addSubview:self.topactivity];
    
    //    返回按钮
    backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    // Do any additional setup after loading the view from its nib.
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 0, 28,28);
    [addButton addTarget:self action:@selector(chatMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 在导航栏增加一个打电话按钮
    telButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [telButton setBackgroundImage:[StringUtil getImageByResName:@"tel"] forState:UIControlStateNormal];
    [telButton setBackgroundImage:[StringUtil getImageByResName:@"tel_hl"] forState:UIControlStateHighlighted];
    telButton.frame = CGRectMake(0, 0, 28,28);
    [telButton addTarget:self action:@selector(getContactInformation) forControlEvents:UIControlEventTouchUpInside];
//#ifdef _LANGUANG_FLAG_
//    
//    telButton.frame = CGRectMake(0, 0, 46,25);
//    addButton.frame = CGRectMake(0, 0, 25,25);
//    
//#endif
    //        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    //        self.navigationItem.rightBarButtonItem= rightItem;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    UIBarButtonItem *telItem = [[UIBarButtonItem alloc]initWithCustomView:telButton];
    
    self.rightBtnItems = [NSMutableArray array];
    if (IOS7_OR_LATER) {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];

        //space.width = -12.0f;
        self.rightBtnItems = @[addItem,telItem];

        [space release];
    }else
    {
        self.rightBtnItems = @[addItem,telItem];
    }
    self.navigationItem.rightBarButtonItems = self.rightBtnItems;
    [addItem release];
    [telItem release];
    
    //-------------底部栏---------------
    //	底部栏的y值为
    int footerY =SCREEN_HEIGHT - input_area_height - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    
    //	if(iPhone5)
    //		footerY = footerY + i5_h_diff;
    footerView = [[UIView alloc]initWithFrame:CGRectMake(0, footerY, self.view.frame.size.width, input_area_height)];
    footerView.layer.borderWidth = 0.5;
    footerView.layer.borderColor = [StringUtil colorWithHexString:@"#E4E4E4"].CGColor;// [[UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0] CGColor];
    //    footerView.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    footerView.backgroundColor = [StringUtil colorWithHexString:@"#F7F7F7"];// [UIColor colorWithRed:242.0/255 green:245.0/255 blue:241.0/255 alpha:1.0];
    //    [self.view addSubview:footerView];
    
    subfooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 260)];
    subfooterView.backgroundColor=[UIColor clearColor];
    // 从数据库获取菜单数据
    ServiceMenuModel *menuList = [[PublicServiceDAO getDatabase] getPSMenuListByPlatformid:serviceModel.serviceId];
    if(self.talkType == publicServiceMsgDtlConvType && menuList.platformid != 0){
        [self loadMenuView];
    }else{
        // 普通的会话，保持原来的处理操作
        record_x = talk_button_x;
        messageParsex = 0;
    }
    
    [footerView addSubview:subfooterView];
    [subfooterView release];
    [self.view addSubview:footerView];
    [footerView release];
    
    [self addBottomBar];
    
    //	录音按钮
    talkButton=[[UIButton alloc]initWithFrame:CGRectMake(talk_button_x, talk_button_y, talk_button_size, talk_button_size)];
    talkButton.tag=1;
    talkButton.backgroundColor = [UIColor clearColor];
    // 原按钮 speaking_ico.png
    [talkSessionUtil2 setAudioIcon:talkButton];
    
    [talkButton addTarget:self action:@selector(talkAction:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:talkButton];
    
    messageTextField_x = CGRectGetMaxX(talkButton.frame);
    messageTextField_width = self.view.frame.size.width-100 - messageParsex;
    
    //	文本框 父view
    self.textView = [[UIView alloc] initWithFrame:CGRectMake(messageTextField_x,5, input_text_width, input_text_height)];
    self.textView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:self.textView];
    
    self.textView.layer.cornerRadius = 2;
    self.textView.clipsToBounds = YES;
    self.textView.layer.borderColor = [StringUtil colorWithHexString:@"#E4E4E4"].CGColor;
    self.textView.layer.borderWidth = 0.5;
    
    //    定向回复消息label
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, REPLY_MSG_LABEL_Y, self.textView.frame.size.width-10, REPLY_MSG_LABEL_HEIGHT)];
    [self.messageLabel setFont:[UIFont systemFontOfSize:16]];
    self.messageLabel.hidden = YES;
    self.messageLabel.layer.cornerRadius = 5;
    self.messageLabel.clipsToBounds = YES;
    self.messageLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    self.messageLabel.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    [self.textView addSubview:self.messageLabel];
    
    //    用户输入框
    self.messageTextField=[[InputTextView alloc]initWithFrame:CGRectMake(0, 0, input_text_width, input_text_height)];
    self.messageTextField.scrollsToTop = NO;
    //    self.messageTextField.backgroundColor = [UIColor orangeColor];
    //    self.messageTextField.layer.borderColor = [UIAdapterUtil isGOMEApp] ? [UIColor colorWithWhite:0.85 alpha:1].CGColor : [UIColor grayColor].CGColor;
    //    self.messageTextField.layer.borderWidth =1.0;
    //    self.messageTextField.layer.cornerRadius =5.0;
    self.messageTextField.font=[UIFont systemFontOfSize:17]; // 0914 和消息系统字体一致
    self.messageTextField.copypic=false;
    self.messageTextField.contentSize=CGSizeMake(input_text_width - 10.0, input_text_height);
    self.messageTextField.delegate=self;
    self.messageTextField.returnKeyType= UIReturnKeySend;
    [self.textView addSubview:self.messageTextField];
    
    // self.messageTextField.editable=NO;
    //   [menuController setMenuVisible: YES animated: YES];
    //	录音按钮
    pressButton=[[UIButton alloc] init];
    [pressButton setFrame:CGRectMake(press_btn_x,press_btn_y,press_btn_width, press_btn_height)];
    pressButton.hidden=YES;
    
    [pressButton setBackgroundImage:[ImageUtil createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [pressButton setBackgroundImage:[ImageUtil createImageWithColor:[StringUtil colorWithHexString:@"#D9D9D9"]] forState:UIControlStateHighlighted];
    [pressButton setBackgroundImage:[ImageUtil createImageWithColor:[StringUtil colorWithHexString:@"#D9D9D9"]] forState:UIControlStateSelected];
    [pressButton setBackgroundImage:[ImageUtil createImageWithColor:[StringUtil colorWithHexString:@"#D9D9D9"]] forState:UIControlStateDisabled];
    [pressButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [pressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [pressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    //
    [pressButton addTarget:self action:@selector(recordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [pressButton addTarget:self action:@selector(recordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [pressButton addTarget:self action:@selector(recordTouchDown:) forControlEvents:UIControlEventTouchDown];
    [pressButton addTarget:self action:@selector(recordTouchDragOutside:) forControlEvents: UIControlEventTouchDragOutside];
    [pressButton addTarget:self action:@selector(recordTouchDragIn:) forControlEvents: UIControlEventTouchDragInside];
    
    pressButton.layer.cornerRadius = self.textView.layer.cornerRadius;
    pressButton.layer.borderColor = self.textView.layer.borderColor;
    pressButton.layer.borderWidth = self.textView.layer.borderWidth;
    pressButton.clipsToBounds = YES;
    
    [footerView addSubview:pressButton];
    [pressButton release];
    
    iconButton =[[UIButton alloc]initWithFrame:CGRectMake(face_button_x, face_button_y, face_button_size, face_button_size)];
    iconButton.tag=1;
    [talkSessionUtil2 setFaceIcon:iconButton];
    
    [iconButton addTarget:self action:@selector(moodIconAction:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:iconButton];
    
    
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 206, self.view.frame.size.width, 30)];
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1/1.0];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:135.0/255 green:135.0/255 blue:135.0/255 alpha:1.0];
    
    pageControl.backgroundColor = [UIColor whiteColor];
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [subfooterView addSubview:pageControl];
    [pageControl release];
    
    //	发送按钮
    sendButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-44, subfooterView.frame.size.height - 24, 45,25)];
#ifdef _HUAXIA_FLAG_
    sendButton.backgroundColor = HX_DARK_RED_COLOR;
    sendButton.layer.cornerRadius = 3;
#else
    //    36 129 252
    
    
//    sendButton.layer.cornerRadius = 3;
//    sendButton.clipsToBounds = YES;
    
    [sendButton setBackgroundImage:[ImageUtil createImageWithColor:[StringUtil colorWithHexString:@"#2481FC"]] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [sendButton setBackgroundImage:[ImageUtil createImageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    [sendButton setTitleColor:[StringUtil colorWithHexString:@"#A3A3A3"] forState:UIControlStateDisabled];

#endif
    [sendButton setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];
    
    
    sendButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [sendButton addTarget:self action:@selector(sendMessage_Click:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:sendButton];
    [sendButton release];
    
    
    //	图片选择按钮
    picButton=[[UIButton alloc]initWithFrame:CGRectMake(function_btn_x, function_btn_y, function_btn_size,function_btn_size)];
    
    picButton.tag=1;
    [talkSessionUtil2 setPlusIcon:picButton];
    [picButton addTarget:self action:@selector(chooseItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:picButton];
    [picButton release];
    
    //	分割线
    line1=[[UIImageView alloc]initWithFrame:CGRectMake(0, input_area_height, self.view.frame.size.width, 1)];
    //line1.image=[StringUtil getImageByResName:@"Layer_line.png"];
    line1.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
    
    [subfooterView addSubview:line1];
    [line1 release];
    
    
    //长语音
    longAudioView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 53)];
    longAudioView.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    longAudioView.hidden=YES;
    [footerView addSubview:longAudioView];
    [longAudioView release];
    
    longAudioImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 37/2.0, 51/2.0)];
    longAudioImageView.image = [StringUtil getImageByResName:@"long_audio_play_0.png"];
    longAudioImageView.animationImages = [NSArray arrayWithObjects:[StringUtil getImageByResName:@"long_audio_play_1.png"],[StringUtil getImageByResName:@"long_audio_play_2.png"],[StringUtil getImageByResName:@"long_audio_play_3.png"],[StringUtil getImageByResName:@"long_audio_play_0.png"], nil];
    longAudioImageView.animationDuration = 1;
    longAudioImageView.animationRepeatCount = 0;
    
    longAudioPlayButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-180, 5, 75/2.0, 75/2.0)];
    [longAudioPlayButton setImage:[StringUtil getImageByResName:@"long_audio_up.png"] forState:UIControlStateNormal];
    longAudioPlayButton.tag=1;
    [longAudioPlayButton addTarget:self action:@selector(longAudioPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    
    longAudioCloseButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-10-24, 10, 24, 24)];
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
    faceScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 46, self.view.frame.size.width, 170)];
    faceScrollview.pagingEnabled=YES;
    faceScrollview.delegate=self;
    faceScrollview.scrollsToTop = NO;
    faceScrollview.showsHorizontalScrollIndicator=NO;
    faceScrollview.showsVerticalScrollIndicator=NO;
    faceScrollview.backgroundColor=[UIColor whiteColor];
    [subfooterView addSubview:faceScrollview];
    [self updateScrollview];
    
    addScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 46, self.view.frame.size.width, self.view.frame.size.width-60-46)];
    addScrollview.scrollsToTop = NO;
    addScrollview.pagingEnabled=YES;
    addScrollview.delegate=self;
    addScrollview.showsHorizontalScrollIndicator=NO;
    addScrollview.showsVerticalScrollIndicator=NO;
    addScrollview.backgroundColor=[UIColor clearColor];
    //    addScrollview.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    addScrollview.backgroundColor=[UIColor colorWithRed:250.0/255 green:250.0/255 blue:250.0/255 alpha:1.0];
    [subfooterView addSubview:addScrollview];
    //    [self showAddScrollow];
    //	录音按钮
    float talkViewY = ((SCREEN_HEIGHT - 64) - 120) / 2;
    talkIconView=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-131)/2.0, talkViewY, 131, 120)];
    talkIconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
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
    talkIconWarningView=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-131)/2.0, talkViewY, 131, 120)];
    talkIconWarningView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
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
    
    
    talkIconCancelView=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-131)/2.0, talkViewY, 131, 120)];
    talkIconCancelView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
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
    
    //	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:ADMIN_MEMBER_DISMISS_NOTIFICATION object:nil];
    //
    
    //	//网络未链接，重新连接
    //    self.reLinkView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    //
    //	UIImageView *_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,320,40)];
    //	_imageView.image = [StringUtil getImageByResName:@"no-connect-bj.png"];
    //    _imageView.alpha=0.4;
    //	[self.reLinkView addSubview:_imageView];
    //	[_imageView release];
    //
    //	UIButton*reLinkButton=[[UIButton alloc]initWithFrame:CGRectMake(240, 5, 60, 30)];
    //    [reLinkButton setTitle:@"重新连接" forState:UIControlStateNormal];
    //    [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    //    [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    //    [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    //    reLinkButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    //    [reLinkButton addTarget:self action:@selector(reLinkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //    [self.reLinkView addSubview:reLinkButton];
    //    [reLinkButton release];
    //    [self.view addSubview:self.reLinkView];
    //    self.reLinkView.hidden=YES;
    
    self.curOfflineMsgs = [[NSMutableArray alloc]init];
    
    self.convRecordArray = [[NSMutableArray alloc]init];
    
    //    NSLog(@"%s,%d",__FUNCTION__,[StringUtil currentMillionSecond] - start);
    
    [self initModifyGroupNameButton];
    
    [[ReceiptMsgUtil getUtil]addPinMsgButton];
}

#pragma mark - 刷新中英文
- (void)refreshViews{
    [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio"] forState:UIControlStateNormal];
    [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio_click"] forState:UIControlStateSelected];
    [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio_click"] forState:UIControlStateHighlighted];
    [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio_click"] forState:UIControlStateFocused];
    
    [(UILabel *)[talkIconView viewWithTag:11] setText:[StringUtil getLocalizableString:@"chats_talksession_message_audio_cancel"]];
    [(UILabel *)[talkIconWarningView viewWithTag:11] setText:[StringUtil getLocalizableString:@"chats_talksession_message_audio_too_short"]];
    
    //表情发送按钮的中英文变化
    [sendButton setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];
    
    [self prepareFunctionButtons];
    [self showAddScrollow];
}

-(void)dismissListenMode
{
    
    listenModeView.alpha=0;
    
}

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

- (void)pageTurn:(UIPageControl *)PageControl
{
    
    int secondPage = [PageControl currentPage];
    faceScrollview.contentOffset=CGPointMake(SCREEN_WIDTH*secondPage, 0);
    
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
    [talkSessionUtil2 setFaceIcon:iconButton];
    float height=footerView.frame.size.height;
    NSLog(@"%f height",height);
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    //    //  pboard.string = self.text;
    //    NSLog(@"---here--textViewDidChange--- %@",pboard.string);
    
}

- (void)checkMessage:(UITextView *)textView
{
    //    NSString *string = [self getLastInputMsgByConvId:self.convId];
    //    if (string.length == 0 || [string isEqualToString:textView.text] == NO) {
    
    // 说明正在删除
    BOOL isDelete = textView.text.length < lastTextViewLength;
    lastTextViewLength = (int)textView.text.length;
    if (isDelete)
    {
        return;
    }
    
    if (textView.text==nil||textView.text.length==0) {
        
    }else{
        
        if (self.talkType != mutiableType) {
            return;
        }
        
        NSRange range = textView.selectedRange;
        if (range.location == 0) {
            return;
        }
        NSString *endstr = [textView.text substringWithRange:NSMakeRange(range.location-1, 1)];
        if (range.location >= (unsigned long)2) {
            NSString *type_str = [textView.text substringWithRange:NSMakeRange(range.location-2, 2)];
            inputType = [StringUtil getStringType:type_str];
            //可以连续@人
            
            if ([endstr isEqualToString:@"@"]&&(inputType != letter_type && inputType != number_type)) {
                chooseTipViewController *chooseTip=[[chooseTipViewController alloc]init];
                chooseTip.predelegate=self;
                chooseTip.dataArray=[_ecloud getChooseTipEmp:self.convId];
                chooseTip.range = range;
                [textView resignFirstResponder];
                if ([[[self.navigationController topViewController] class] isSubclassOfClass:[chooseTipViewController class]]) {
                    return;
                }
                [self.navigationController pushViewController:chooseTip animated:NO];
                [chooseTip release];
                return;
            }
        }else{
            
            inputType = 2;
        }
        //        NSLog(@"type == %d",inputType);
        //        NSLog(@"message_len====%d",self.message_len);
        //        NSLog(@"textView====%lu",(unsigned long)textView.text.length);
        if ([endstr isEqualToString:@"@"]&&self.message_len<=textView.text.length&&inputType == 2) {
            self.message_len=textView.text.length;
            chooseTipViewController *chooseTip=[[chooseTipViewController alloc]init];
            chooseTip.predelegate=self;
            chooseTip.dataArray=[_ecloud getChooseTipEmp:self.convId];
            chooseTip.range = range;
            [textView resignFirstResponder];
            if ([[[self.navigationController topViewController] class] isSubclassOfClass:[chooseTipViewController class]]) {
                return;
            }
            [self.navigationController pushViewController:chooseTip animated:NO];
            [chooseTip release];
        }
    }
    //}
    
}
- (void)textViewDidChange:(UITextView *)textView
{
    //	NSLog(@"%s,%@",__FUNCTION__,NSStringFromCGSize(textView.contentSize));
    
    if (textView.text==nil||textView.text.length==0) {
        textView.text=@" ";
        sendButton.enabled = NO;
    }else{
        if ([StringUtil trimString:textView.text].length == 0) {
            sendButton.enabled = NO;
        }else{
            sendButton.enabled = YES;
        }
    }
    //    NSString *endstr=[textView.text substringFromIndex:textView.text.length-1];
    //    NSLog(@"%s,%@",__FUNCTION__,endstr);
    
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
            NSLog(@"--colom--%d-----height--%.0f theight is %.0f ",colomNumber,contentHeight,theight);
            float height=footerView.frame.size.height;
            float width=footerView.frame.size.width;
            float fx=footerView.frame.origin.x;
            float fy=footerView.frame.origin.y;
            
            footerView.frame=CGRectMake(fx, fy-(contentHeight-theight), width, height+(contentHeight-theight));
            
            subfooterView.frame=CGRectMake(0, suby+(contentHeight-theight), width, 260);
            
            [self setTextViewFrame:CGRectMake(messageTextField_x,input_text_y, messageTextField_width, contentHeight)];
            
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
        //                NSLog(@"----footerView.frame--x--%f --y-%f --width--%f ---height--%f",footerView.frame.origin.x,footerView.frame.origin.y,footerView.frame.size.width,footerView.frame.size.height);
        //                NSLog(@"----subfooterView--x--%f --y-%f --width--%f ---height--%f",subfooterView.frame.origin.x,subfooterView.frame.origin.y,subfooterView.frame.size.width,subfooterView.frame.size.height);
        //                NSLog(@"----self.messageTextField----------height- %f",self.messageTextField.frame.size.height);
        float fy=footerView.frame.origin.y;
        if(fy==(200 - [self getReplyMsgLabelHeight]))
        {
            fy=(200 - [self getReplyMsgLabelHeight])+7;
        }
        else
        {
            if (subfooterView.frame.origin.y!=(36 + [self getReplyMsgLabelHeight]))
            {
                fy=fy-(36-subfooterView.frame.origin.y + [self getReplyMsgLabelHeight]);
            }
        }
        
        footerView.frame=CGRectMake(0, fy, self.view.frame.size.width, 346 + [self getReplyMsgLabelHeight]);
        subfooterView.frame=CGRectMake(0, 36 + [self getReplyMsgLabelHeight], self.view.frame.size.width, 260);
        
        [self setTextViewFrame:CGRectMake(messageTextField_x,input_text_y, messageTextField_width, 70)];
        
        float textfieldX = self.messageTextField.frame.origin.x;
        [self.messageTextField setContentOffset:CGPointMake(0.0, contentHeight-78) animated:NO];
    }
    
    
    if ([textView.text isEqualToString:@" "]) {
        textView.text=@"";
    }
    self.message_len = textView.text.length;
}


#pragma mark 下拉加载历史记录
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{//顶部下拉
    
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
    pageControl.currentPage=scrollView.contentOffset.x/self.view.frame.size.width;
    
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
    
    NSArray *recordList = [self getConvRecordBy:self.convId andLimit:limit andOffset:offset];
    //    NSArray *recordList = [_ecloud getConvRecordBy:self.convId andLimit:limit andOffset:offset];
    
    
    
    int count=[recordList count];
    
    for (int i=count-1; i>=0; i--)
    {
        //        ConvRecord *record =[recordList objectAtIndex:i];
        [self.convRecordArray insertObject:[recordList objectAtIndex:i] atIndex:0];
    }
    for(int i = 0;i<recordList.count;i++){
        id _convRecord = [recordList objectAtIndex:i];
        if ([_convRecord isKindOfClass:[ConvRecord class]]) {
            [talkSessionUtil setPropertyOfConvRecord:_convRecord];
            [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
            [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
            [self setTimeDisplay:_convRecord andIndex:i];
        }
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
    //    如果是单聊，那么看下是否机器人，如果是机器人，那么插入问候语，或修改问候语的时间
    if (self.talkType == singleType) {
        if ([[RobotDAO getDatabase]isRobotUser:self.convId.intValue])
        {
            [[RobotDAO getDatabase]initGreetingsWithRobotId:self.convId.intValue andRobotName:self.titleStr];
        }
        // 如果单聊为虚拟组，那么插入提示语，或修改提示语的时间 by yanlei
        else if ([[VirtualGroupDAO getDatabase] isVirtualGroupUser:self.convId.intValue])
        {
            [[VirtualGroupDAO getDatabase]initGreetingsWithUserId:self.convId.intValue andTitle:self.titleStr];
        }
    }
    
    totalCount = [self getConvRecordCountBy:self.convId];
    if(totalCount > num_convrecord)
    {
        int unreadMsgCount = [ReceiptMsgUtil getUtil].unreadMsgNumber;
        if (unreadMsgCount > num_convrecord && [ReceiptMsgUtil getUtil].pinMsgArray.count > 0) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 新消息条数 大于 10条，需要取出所有的新消息",__FUNCTION__]];
            limit = unreadMsgCount;
        }else{
            limit = num_convrecord;
        }
        offset = totalCount - limit;
    }
    else {
        limit = totalCount;
        offset = 0;
    }
    NSArray *recordList= [self getConvRecordBy:self.convId andLimit:limit andOffset:offset];
    [self.convRecordArray addObjectsFromArray:recordList];
    
    //    long long start = [StringUtil currentMillionSecond];
    for(int i=0;i<self.convRecordArray.count;i++)
    {
        //        可能是convrecord类型，也可能是公众号消息类型，所以这里要进行判断
        //		ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
        id _convRecord = [self.convRecordArray objectAtIndex:i];
        if ([_convRecord isKindOfClass:[ConvRecord class]]) {
            [talkSessionUtil setPropertyOfConvRecord:_convRecord];
            [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
            [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
            [self setTimeDisplay:_convRecord andIndex:i];
        }
    }
    //    NSLog(@"%s,处理聊天记录 需要时间:%d",__FUNCTION__,[StringUtil currentMillionSecond] - start);
    
    int count=[recordList count];
    //	start = [StringUtil currentMillionSecond];
    [self.chatTableView reloadData];
    //    NSLog(@"%s,加载聊天记录 需要时间:%d",__FUNCTION__,[StringUtil currentMillionSecond] - start);
    
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
        else if (self.talkType == publicServiceMsgDtlConvType)
        {
            [[PSMsgDspUtil getUtil]scrollToEnd];
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
    NSString * tempStrLen = [self getLastInputMsgByConvId:self.convId];
    self.message_len = (int *)tempStrLen.length ;
    self.messageTextField.text = tempStrLen;
    if (self.message_len>0 && ![self.messageTextField isHidden]) {
        [self.messageTextField becomeFirstResponder];
    }
    //	[self textViewDidChange:self.messageTextField];
    [self setFooterView];
    
    //    NSLog(@"%s self.view.frame is %@",__FUNCTION__,NSStringFromCGRect(self.view.frame));
    [self reCalculateFrame];
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
-(void)hiddenSubMenuAction:(id)sender
{
    tableBackGroudButtonForHiddenSubMenu.hidden=YES;
    
    [self showAndHideRecordBtn];
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
    //    if (h) {
    //        NSLog(@"打开键盘");
    //    }
    //    else
    //    {
    //        NSLog(@"关闭键盘");
    //    }
    
    keyboardHeight = h;
    
    //  NSLog(@"%s, h is %.0f",__FUNCTION__,h);
    if (h>0) {
        tableBackGroudButton.hidden=NO;
    }else
    {
        tableBackGroudButton.hidden=YES;
    }
    
    
    //    NSLog(@"%s,self.view.frame.size.height is %.0f",__FUNCTION__,self.view.frame.size.height);
    
    float footerY = [self getSelfViewHeight] - 45 - h - (self.textView.frame.size.height-input_text_height);
    
    if (self.textView.hidden) {
        footerY = [self getSelfViewHeight] - input_area_height - h;// (float)(480.0-h-108.0+44-
    }
    
    //	if(iPhone5)
    //		footerY = footerY + i5_h_diff;
    
    //	if(self.tabBarController && 	!self.tabBarController.tabBar.hidden)
    //	{
    //		NSLog(@"self.tabBarController && 	!self.tabBarController.tabBar.hidden");
    //		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
    //		footerY = footerY + _tabBar.frame.size.height;
    //	}
    int tableH = footerY + 15;
    //    if(iPhone5)
    //        tableH = tableH + i5_h_diff;
    if (isEmtiom) {
        isEmtiom = NO;
    }
    else{
        footerView.frame = CGRectMake(0.0f, footerY, self.view.frame.size.width, 260.0f+input_area_height+[self getReplyMsgLabelHeight]);
        if (!self.textView.hidden) {
            CGRect _frame = subfooterView.frame;
            _frame.origin.y = (self.textView.frame.size.height-input_text_height);
            subfooterView.frame = _frame;
        }
        
        self.chatTableView.frame=CGRectMake(0, 0, self.view.frame.size.width,tableH);
        
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
    // update 0805 by yanlei 表情的适配
    // 首先先计算一行能放置几个表情
    CGFloat screenWidth = [UIAdapterUtil getDeviceMainScreenWidth];
    int rowCount = 8;   // 每行的个数
    int spacing = 10;
    
    if (IS_IPHONE) {
        //        if (IS_IPHONE_6P) {
        //            rowCount = 9;
        //            spacing = 15;
        //        }else if (IS_IPHONE_6){
        //            spacing = 15;
        //        }
    }else if (IS_IPAD){
        //        竖屏显示10个；横屏一行显示14个
        if (SCREEN_WIDTH < SCREEN_HEIGHT) {
            rowCount = 10;
        }else{
            rowCount = 14;
        }
        
        spacing = (SCREEN_WIDTH - 30 * rowCount) / (rowCount + 1);
    }
    CGFloat spacingX = (screenWidth - 30*rowCount - spacing*(rowCount-1))/2;   // 表情距离左右两边的间距 第一个表情的x值
    int y=0;
    
    int bint=[self.phraseArray count]; //表情总数
    int rownum=0; //根据每行显示个数 计算出 显示所有表情需要多少行
    if (bint%rowCount!=0) {
        rownum=bint/rowCount+1;
    }else {
        rownum=bint/rowCount;
    }
    int sumindex=bint;//表情总数
    
    float faceBtnWidth = (SCREEN_WIDTH - 15.0) / rowCount;
    float faceBtnHeight = 55;
    
    for (int r=0; r<rownum; r++) {
        
        
        int row=r; //行数
        int arrayindex=row*rowCount; //表情对应的下标
        
        y=faceBtnHeight*(r%3)+10; //表情的y值 第一行是10
        
        //UITextField *imageview;
        UIImageView *imgv;
        UIButton *iconBtn;
        for (int i=0; i<rowCount; i++) {
            
            if (arrayindex<sumindex) {
                //------------------------------------------------------------------------
                //                CGRect imageValueRect=CGRectMake(screenWidth * (r/4) + spacingX + (30+spacing) * i,y, 30,30);
                
                CGRect imageValueRect=CGRectMake(screenWidth * (r/3) + 10 + faceBtnWidth * i,y, faceBtnWidth,faceBtnHeight);
                
                iconBtn=[[UIButton alloc]initWithFrame:imageValueRect];
                //                iconBtn.backgroundColor = [UIColor redColor];
                [iconBtn addTarget:self action:@selector(choosefacePic:)  forControlEvents:UIControlEventTouchUpInside];
                iconBtn.titleLabel.text=@"0";
                iconBtn.tag=arrayindex;
                // NSDictionary *item=[picArray objectAtIndex:arrayindex];
                CGRect imageValueRect1=CGRectMake((faceBtnWidth - 30) / 2, (faceBtnHeight - 30) / 2, 30, 30);
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
    if (rownum%3!=0) {
        page=rownum/3+1;
    }else {
        page=rownum/3;
    }
    [faceScrollview setContentSize:CGSizeMake(page * screenWidth, y+10)];
    
    
    pageControl.currentPage=0;
    pageControl.numberOfPages=page;
}

#pragma mark －－－－－－－－－－－选择表情
-(void)choosefacePic:(id)sender
{
    //  if ([self.messageTextField.text length]>0) {
    self.messageString =[NSMutableString stringWithFormat:@"%@",self.messageTextField.text];
    // }
    
    int everNum = 32;   // 在6plus之前一页显示32个表情
    
    if (IS_IPHONE_6P) {
        everNum = 36;   // 在6plus上一页显示36个表情
    }
    
    UIButton *tempbtn = (UIButton *)sender;
    
    BOOL clearClick = NO;
    
    NSMutableDictionary *tempdic = [self.phraseArray objectAtIndex:tempbtn.tag];
    NSArray *temparray = [tempdic allKeys];
    if (temparray.count == 0) {
        return;
    }
    NSString *faceStr= [NSString stringWithFormat:@"%@",[temparray objectAtIndex:0]];
    if ([faceStr isEqualToString:@"[/sc]"]) {
        clearClick = YES;
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
    // 取消定向回复
    if (self.messageTextField.text.length == 0 && text.length == 0 && range.location == 0 && range.length == 0)
    {
        if (!self.messageLabel.hidden)
        {
            [self cancelReplyMessage];
            
            return YES;
        }
    }
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage_Click:nil];
        return NO;
    }
    
    // 不是多人聊天
    if (self.talkType != mutiableType) {
        return YES;
    }
    
    
    if ([text isEqualToString:@"@"])
    {
        NSMutableString *mStr = [NSMutableString stringWithString:textView.text];
        [mStr replaceCharactersInRange:range withString:text];
        int firstChar = [mStr characterAtIndex:range.location-1];
        // 如果前面不是"字母"也不是"数字"
        if (![StringUtil isLetter:firstChar] && ![StringUtil isNumber:firstChar])
        {
            chooseTipViewController *chooseTip=[[chooseTipViewController alloc]init];
            chooseTip.predelegate=self;
            chooseTip.dataArray=[_ecloud getChooseTipEmp:self.convId];
            chooseTip.range = range;
            
            Class ctlClass = [self.navigationController.topViewController class];
            if (![ctlClass isEqual:[chooseTipViewController class]])
            {
                [self.navigationController pushViewController:chooseTip animated:NO];
            }
            [chooseTip release];
        }
    }
    
    
    //    if (range.length == 1 && [text isEqualToString:@"@"] && self.talkType == mutiableType) {
    //        chooseTipViewController *chooseTip=[[chooseTipViewController alloc]init];
    //        chooseTip.predelegate=self;
    //        chooseTip.dataArray=[_ecloud getChooseTipEmp:self.convId];
    //        [self.navigationController pushViewController:chooseTip animated:NO];
    //        [chooseTip release];
    //    }
    return YES;
}
#pragma  mark 表情切换
-(void)moodIconAction:(id)sender
{
    //    NSLog(@"开始切换表情");
    addScrollview.hidden=YES;
    talkButton.tag=1;
    picButton.tag=1;
    [talkSessionUtil2 setAudioIcon:talkButton];
    pressButton.hidden=YES;
    //    self.messageTextField.hidden=NO;
    self.textView.hidden = NO;
    UIButton * button=(UIButton *)sender;
    int index=button.tag;
    if (index==1) {
        //        NSLog(@"表情按钮tag 是1");
        button.tag=2;
        [talkSessionUtil2 setKeyboardIcon:button];
        
        if ([self.messageTextField  isFirstResponder]) {
            isEmtiom = YES;
            [self.messageTextField resignFirstResponder];
        }
        
        int footerY =  [self getSelfViewHeight] - 216 - 45 -  (self.textView.frame.size.height-input_text_height);
        //		if(iPhone5)
        //			footerY = footerY + i5_h_diff;
        footerView.frame=CGRectMake(0,footerY, self.view.frame.size.width, 260+input_area_height+[self getReplyMsgLabelHeight]);
        
        tableBackGroudButton.hidden=NO;
        int tableH = footerY + 15;//154;
        //        if(iPhone5)
        //            tableH = tableH + i5_h_diff;
        
        self.chatTableView.frame=CGRectMake(0, 0, self.view.frame.size.width, tableH);
        if ([self.convRecordArray count]>0) {
            [self scrollToEnd];
        }
        [self textViewDidChange:self.messageTextField];
        [self.messageTextField setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];//设置UITextView的内边距
        [self.messageTextField setTextAlignment:NSTextAlignmentLeft];//并设置左对齐
        
    }else
    {
        //        NSLog(@"表情按钮tag是2");
        button.tag=1;
        [button setImage:[StringUtil getImageByResName:@"facepic_ico.png"] forState:UIControlStateNormal];
        [self.messageTextField becomeFirstResponder];
        [self textViewDidChange:self.messageTextField];
    }
}


#pragma  mark 选择 照片，拍照，日程，等等
-(void)chooseItemAction:(id)sender
{
    //    NSLog(@"启动选择功能按钮界面");
    addScrollview.hidden=NO;
    talkButton.tag=1;
    [talkSessionUtil2 setAudioIcon:talkButton];
    pressButton.hidden=YES;
    //    self.messageTextField.hidden=NO;
    self.textView.hidden = NO;
    
    //    点击后 都变成表情按钮
    [talkSessionUtil2 setFaceIcon:iconButton];
    iconButton.tag = 1;
    UIButton * button=(UIButton *)sender;
    int index=button.tag;
    if (index==1) {
        //        NSLog(@"功能按钮tag式1");
        button.tag=2;
        
        if ([self.messageTextField  isFirstResponder]) {
            isEmtiom = YES;
            [self.messageTextField resignFirstResponder];
        }
        
        int footerY =  [self getSelfViewHeight] - 216 - 45 -  (self.textView.frame.size.height-input_text_height);
        
        footerView.frame=CGRectMake(0,footerY, self.view.frame.size.width, 260+input_area_height+[self getReplyMsgLabelHeight]);
        tableBackGroudButton.hidden=NO;
        
        int tableH = footerY + 15;//154;
        //        if(iPhone5)
        //            tableH = tableH + i5_h_diff;
        
        
        self.chatTableView.frame=CGRectMake(0, 0, self.view.frame.size.width, tableH);
        if ([self.convRecordArray count]>0) {
            [self scrollToEnd];
        }
        [self textViewDidChange:self.messageTextField];
        [self.messageTextField setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];//设置UITextView的内边距
        [self.messageTextField setTextAlignment:NSTextAlignmentLeft];//并设置左对齐
        
        
    }else
    {
        //        NSLog(@"功能按钮tag是2");
        button.tag=1;
        [self.messageTextField becomeFirstResponder];
        [self textViewDidChange:self.messageTextField];
    }
    
}



#pragma mark ----发送文本消息
-(IBAction)sendMessage_Click:(id)sender
{
    //自己已被群组移除后 发送消息时的提示
    //    if( self.talkType == mutiableType && ![_ecloud userExistInConvEmp:self.convId] ){
    //        [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"chats_talksession_group_remove_notice"] autoDimiss:NO];
    //        return;
    //    }
    if(!sendMsgEnable)
    {
        [UserTipsUtil sendMsgForbidden];
        return;
    }
    
    if (self.talkType == publicServiceMsgDtlConvType) {
        [[PSMsgDspUtil getUtil]sendPSMessage];
        [self performSelector:@selector(clearUpText) withObject:nil afterDelay:0.1];
        return;
    }
    
    //    普通会话消息
    int tempMaxLen = MSG_MAXLEN - 10 ;
    
    //    一呼万应
    if (self.talkType == massType) {
        tempMaxLen = MSG_MAXBROADLEN - 10;
    }
    //	长消息的最多字符个数是15000个
    NSString *message = self.messageTextField.text;
    
    if (audioMessage && ![audioMessage isEqualToString:@""]) {
        message = audioMessage;
        audioMessage = nil;
    }else if (!self.messageLabel.hidden)
    {
        message = [[WXReplyOneMsgUtil getUtil] formatReplyMsg:message];
    }
    //	NSLog(@"------ message   %@",message);
    //	文本消息长度超过780，就按照长消息发送
    //    万达版本 根据消息最大长度 来确定是否发送长消息
    //    最多10000个字符
    int msgLen = [StringUtil getMsgLen:message];
#ifdef _LANGUANG_FLAG_
    
    tempMaxLen = MSG_MAXLEN - 100;
    
#endif
    if(msgLen > (tempMaxLen))
    {
#ifdef _LANGUANG_FLAG_
        
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
            
            [UserTipsUtil showAlert:@"发送的消息太长"];
            //        [self performSelector:@selector(clearUpText) withObject:nil afterDelay:0.1];
            
            return;
        }
#endif
        
        if (!self.messageLabel.hidden) {
            /** 提示超长 */
            [UserTipsUtil showAlert:@"您要发送的消息太长啦"];
            return;
        }
        int longMsgMaxLen = 10000;
        if(message.length > longMsgMaxLen)
        {
            message = [message substringToIndex:longMsgMaxLen];
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
    [self cancelReplyMessage];
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
                if (self.talkType == singleType && [[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:conv_status_huizhi],@"receipt_msg_flag", nil];
                }else{
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:receiptMsgFlag],@"receipt_msg_flag", nil];
                }
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
                    if ([messageStr rangeOfString:@"您的问题："].length > 0 ) {
                        messageStr = [messageStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        messageStr = [messageStr stringByReplacingOccurrencesOfString:@"您的问题：" withString:@""];
                    }
                    [_conn sendMsg:self.convId andConvType:self.talkType andMsgType:type_text andMsg:messageStr andMsgId:[sendMsgId longLongValue]  andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
                    
                    //                发送完消息后，关闭回执状态
                    if (receiptMsgFlag == conv_status_huizhi)
                    {
                        NSLog(@"%s,发送完消息后，回执模式切换为正常模式",__FUNCTION__);
                        [self changeConvStatusAction];
                    }
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
                    
                    if (_convRecord.receiptMsgFlag == conv_status_huizhi)
                    {
                        [self changeConvStatusAction];
                    }
                }
                else
                {
                    //		如果是录音或图片，存在这种情况，还未上传成功，就退出，进入其他会话，这时convId就不同了，所以发送非图片消息时，会话id是消息对应的会话id
                    ConvRecord *_convRecord = [self  getConvRecordByMsgId:oldMsgId];
                    sendMsgId = [NSString stringWithFormat:@"%lld",_convRecord.origin_msg_id];
                    NSString * convIdOfMsg = _convRecord.conv_id;
                    
                    [_conn sendMsg:convIdOfMsg andConvType:_convRecord.conv_type andMsgType:iMsgType andFileSize:fsize andFileName:_convRecord.file_name andFileUrl:_convRecord.msg_body andMsgId:[sendMsgId longLongValue] andTime:nowtimeInt andReceiptMsgFlag:_convRecord.receiptMsgFlag];
                    
                    if (_convRecord.receiptMsgFlag == conv_status_huizhi)
                    {
                        [self changeConvStatusAction];
                    }
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
            else if(iMsgType == type_video)
            {
                messageStr = [StringUtil getLocalizableString:@"msg_type_video"];
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
            
            //            不使用第一条消息作为群组名称，而是使用默认的群组名称或者是用户修改过的群组名称
            if(![_conn createConversation:self.convId andName:self.titleStr andEmps:self.convEmps])
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
-(NSString *)addMediaRecord:(int)iMsgType message:(NSString *)messageStr filesize:(int)fsize filename:(NSString *)fname andReceiptMsgFlag:(int)iReceiptMsgFlag
{
    //    如果是公众号，则不支持发送 语音 图片 长消息 文件等
    if (self.talkType == publicServiceMsgDtlConvType)
    {
        return nil;
    }
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
        if (self.talkType == singleType && [[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
            /** 密聊按照回执消息发送 */
            dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:fsize],@"file_size",fname,@"file_name", [StringUtil getStringValue:conv_status_huizhi],@"receipt_msg_flag",nil];
            
        }else{
            dic = [NSDictionary dictionaryWithObjectsAndKeys:self.convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",messageStr,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:fsize],@"file_size",fname,@"file_name", [StringUtil getStringValue:iReceiptMsgFlag],@"receipt_msg_flag",nil];
        }
        
        _dic =  [_ecloud addConvRecord:[NSArray arrayWithObject:dic]];
    }
    NSString * msgId = nil;
    if(_dic)
    {
        msgId = [_dic valueForKey:@"msg_id"];
    }
    return msgId;
}

- (NSString *)addMediaRecord:(int)iMsgType message:(NSString *)messageStr filesize:(int)fsize filename:(NSString *)fname{
    return [self addMediaRecord:iMsgType message:messageStr filesize:fsize filename:fname andReceiptMsgFlag:receiptMsgFlag];
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
#pragma mark - 切换菜单模式
- (void)menuAction:(id)sender{
    if(!muneButton.selected){
        talkButton.hidden = YES;
        [self hideTextView];
        iconButton.hidden = YES;
        picButton.hidden = YES;
        pressButton.hidden = YES;
        
        menuView.hidden = NO;
        // 隐藏照片、拍照、一呼百应等功能菜单
        //        BOOL flag = tableBackGroudButton.hidden;
        [self tableBackGroudAction:nil];
    }else{
        talkButton.hidden = NO;
        if (talkButton.tag == 2) {
            pressButton.hidden = NO;
        }else{
            [self showTextView];
        }
        iconButton.hidden = NO;
        picButton.hidden = NO;
        
        menuView.hidden = YES;
        // 若二级子菜单已弹出，将其隐藏
        [menuView hiddenItemTable];
    }
    muneButton.selected = !muneButton.selected;
}
#pragma mark 切换到录音聊天方式
-(void)talkAction:(id)sender
{
    picButton.tag=1;
    UIButton * button=(UIButton *)sender;
    int index=button.tag;
    //    如果是一呼百应消息，那么有长语音功能
    if (receiptMsgFlag == conv_status_receipt) {
        if (!receiptMsgFlagButton.hidden&&index==1) {
            [self popover:sender];
            return;
        }
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
        [talkSessionUtil2 setKeyboardIcon:button];
        pressButton.hidden=NO;
        [self hideTextView];
        [self autoMovekeyBoard:0];
        
        //这时左边是键盘键 输入框右侧按钮变成表情键
        [talkSessionUtil2 setFaceIcon:iconButton];
        iconButton.tag = 1;
        
    }else
    {
        button.tag=1;
        [button setImage:[StringUtil getImageByResName:@"btn_chat_voice_normal.png"] forState:UIControlStateNormal];
        pressButton.hidden=YES;
        [self showTextView];
    }
}

//返回 按钮
-(void) backButtonPressed:(id) sender
{
    [self cancelSomeStatus];
    _conn.curConvId = nil;
    //释放
    [KxMenu dismissMenu];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECALL_MSG_RESULT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_USER_INFO_FROM_HX_NOTIFICATION object:nil];
    
    self.isHaveBeingHere=NO;
    if (!longAudioView.hidden) {//取消 长语音
        [self longAudioCloseAction:nil];
    }
    
    
    //    if (self.fromType == 3)
    //    {
    //        //从第三方应用直接进入返回
    //        self.fromType = 0;
    //        [self.navigationController popViewControllerAnimated:YES];
    //        return;
    //    }
    //
    //    if (self.fromType == 4)
    //    {
    //        //从第三方应用选人发起会话返回
    //        self.fromType = 0;
    //        int index = 0;
    //        if ([[self.navigationController childViewControllers] count] > 2) {
    //            index = [[self.navigationController childViewControllers] count]-3;
    //        }
    //        [self.navigationController popToViewController:[[self.navigationController childViewControllers] objectAtIndex:index] animated:YES];
    //        return;
    //    }
    if(self.fromType == talksession_from_chatRecordView)
    {
        self.fromType = 0;
        [self.navigationController popViewControllerAnimated:YES];
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
        [self popToContactVC];
        //        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter ]postNotificationName:AUTO_SELECT_CONVERSATION_NOTIFICATION object:nil userInfo:nil];
    }
    else if(self.talkType == mutiableType && [[self.convId substringToIndex:1] isEqualToString:@"g"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.talkType == publicServiceMsgDtlConvType) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(self.talkType == singleType || self.talkType == mutiableType)
    {
        if (self.fromType == talksession_from_conv_query_result_need_not_position || self.fromType == talksession_from_conv_query_result_need_position)
        {
            //        从会话的查询结果来的，所以只需要返回到上级界面即可
            self.fromType = 0;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        //        else if(self.fromType == talksession_from_chatRecordView)
        //        {
        //            self.fromType = 0;
        //            [self.navigationController popViewControllerAnimated:YES];
        //            return;
        //        }
        else
        {
            [self popToContactVC];
            //            [self.navigationController popToRootViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter ]postNotificationName:AUTO_SELECT_CONVERSATION_NOTIFICATION object:nil userInfo:nil];
        }
    }
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        
#ifdef _LANGUANG_FLAG_
        [self findSubView:self.view];
        [_MosaicImageView release];
        [_MosaicImageView removeFromSuperview];
        _MosaicImageView = nil;
        [self setInfoViewFrame:NO];
        [self.view removeGestureRecognizer:tapGesture];
#endif
    }
    
}

-(void)findSubView:(UIView*)view
{
    
    for (int i = 0; i < view.subviews.count; i++) {
        
        UIView *subView = view.subviews[i];
        if (subView.tag == 70001) {
            
            [subView removeFromSuperview];
            subView = view.subviews[i-1];
            [subView removeFromSuperview];
            
        }
    }
    
}
//回到会话界面
- (void)popToContactVC
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[contactViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ------------------隐藏或显示文本框的处理------------------
- (void)hideTextView{
    //    self.messageTextField.hidden=YES;
    self.textView.hidden = YES;
    [self.messageTextField resignFirstResponder];
    [self setFooterView];
}

- (void)showTextView{
    //    self.messageTextField.hidden=NO;
    self.textView.hidden = NO;
    [self setFooterView];
    [self.messageTextField becomeFirstResponder];
}

- (void)setFooterView{
    if ([self.textView isHidden]) {
        float footerY = footerView.frame.origin.y;
        
        if (self.textView.frame.size.height > (input_text_height + [self getReplyMsgLabelHeight])) {
            footerY = footerY + self.textView.frame.size.height-(input_text_height + [self getReplyMsgLabelHeight]);
        }
        
        footerView.frame=CGRectMake(0, footerY, self.view.frame.size.width, input_area_height);
        subfooterView.frame=CGRectMake(0, 0, self.view.frame.size.width, 260);
        
        [self setTextViewFrame:CGRectMake(messageTextField_x,input_text_y, messageTextField_width, input_text_height)];
        CGRect messageFrame = CGRectMake(messageTextField_x,input_text_y, messageTextField_width, input_text_height);
        //        messageFrame.origin.y = 6;
        pressButton.frame = messageFrame;
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        return [[PSMsgDspUtil getUtil]getNumberOfSection];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.talkType == massType)
    {
        return 1;
    }
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        return [[PSMsgDspUtil getUtil]getRowCountOfSection:section];
    }
    return [self.convRecordArray count] + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.talkType == massType)
    {
        if(indexPath.section == 0)
        {
            if (offset == 0){
                return 1;
            }
            
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        return [[PSMsgDspUtil getUtil]getHeightOfIndexPath:indexPath];
    }
    //	//	update by shisp	  第一行显示加载提示框
    
    if(indexPath.row == 0)
    {
        if (offset == 0) {
            return 1;
        }
        return 40;
    }
    
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
    //
    //    NSLog(@"%s %@ %.0f",__FUNCTION__,_convRecord.msg_body,cellHeight);
    return cellHeight ;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.talkType == singleType || self.talkType == mutiableType)
    {
        int row = indexPath.row;
        if(row > 0 && self.convRecordArray.count > 0 && (row < self.convRecordArray.count))
        {
            ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:row-1];
            
            if (_convRecord.downloadRequest) {
                [_convRecord.downloadRequest setDownloadProgressDelegate:nil];
            }
            if (_convRecord.uploadRequest){
                [_convRecord.uploadRequest setUploadProgressDelegate:nil];
            }
            
            //            if(_convRecord.isDownLoading && _convRecord.downloadRequest)
            //            {
            //                if(_convRecord.msg_type == type_pic || _convRecord.msg_type == type_file)
            //                {
            //                    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,@"正在下载，需要解除DownloadProgressDelegate"]];
            //                    [_convRecord.downloadRequest setDownloadProgressDelegate:nil];
            //                }
            //            }
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        [[PSMsgDspUtil getUtil]processWhenCellWillDisplay:tableView andCell:cell andIndexPath:indexPath];
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        return [[PSMsgDspUtil getUtil]getHeaderHeightOfSection:section];
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        return [[PSMsgDspUtil getUtil]getHeaderViewOfSection:section];
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IOS_VERSION_BEFORE_6 && (self.talkType == singleType || self.talkType == mutiableType))
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
                        if(_convRecord.msg_type == type_pic || _convRecord.msg_type == type_file || _convRecord.msg_type == type_video)
                        {
                            [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,@"正在下载，需要解除DownloadProgressDelegate"]];
                            [_convRecord.downloadRequest setDownloadProgressDelegate:nil];
                        }
                    }
                }
            }
        }
    }
    
    if (self.talkType == publicServiceMsgDtlConvType) {
        return [[PSMsgDspUtil getUtil]getCellOfTableView:tableView andIndexPath:indexPath];
    }
    
    //		add by shisp第一行显示为加载提示框
    if((self.talkType == massType && indexPath.section == 0) || ((self.talkType == singleType || self.talkType == mutiableType || self.talkType == rcvMassType) && indexPath.row == 0))
    {
        UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        loadingIndic.frame=CGRectMake(SCREEN_WIDTH / 2 - 5,5, 30.0f,30.0f);
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
        [[ReceiptMsgUtil getUtil]deletePinMsg:_convRecord];
        
        _convRecord.isEdit = isEditingConvRecord;
        
        UITableViewCell *cell = [self getMsgCell:tableView andRecord:_convRecord];// nil;
        
        [talkSessionUtil configureCell:cell andConvRecord:_convRecord];
        
        //	状态按钮
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
        UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
        
        //		如果是发送的消息，并且发送状态是上传成功后发送中或上传中，那么显示正在发送
        if(_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading || _convRecord.send_flag == send_upload_waiting || _convRecord.download_flag == state_downloading))
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
            //发送失败
            if (_convRecord.msg_type == type_file) {
                //                if (maxSendFileSize == 20) {
                //                    UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
                //                    failBtn.hidden=NO;
                //                }
            }
            else{
                failButton.hidden=NO;
            }
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
                    if (_convRecord.downloadRequest && _convRecord.download_flag == state_downloading) {
                        //配置下载参数
                        UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:file_progressview_tag];
                        [talkSessionUtil displayProgressView:_progressView];
                        _convRecord.downloadRequest.downloadProgressDelegate = _progressView;
                        _convRecord.downloadRequest.delegate = self;
                        [_convRecord.downloadRequest setDidFinishSelector:@selector(downloadFileComplete:)];
                        [_convRecord.downloadRequest setDidFailSelector:@selector(downloadFileFail:)];
                    }
                }
                else{
                    if (_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading)) {
                        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
                        [talkSessionUtil displayProgressView:_progressView];
                        
                        if (_convRecord.uploadRequest) {
                            if (maxSendFileSize == 20) {
                                [_convRecord.uploadRequest setUploadProgressDelegate:_progressView];
                            }
                            else{// if(maxSendFileSize == 21){
                                //配置文件上传参数
                                _convRecord.uploadRequest.uploadProgressDelegate = self;
                                //                                _convRecord.uploadRequest.delegate = self;
                                //                                [_convRecord.uploadRequest setDidFinishSelector:@selector(uploadFileComplete:)];
                                //                                [_convRecord.uploadRequest setDidFailSelector:@selector(uploadFileFail:)];
                            }
                        }
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
                        }else{
                            [talkSessionUtil sendReadNotice:_convRecord];
                        }
                    }
                }
                else{
                    [talkSessionUtil sendReadNotice:_convRecord];
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
                    if(_convRecord.msg_flag == rcv_msg && _convRecord.is_set_redstate == 1 && _convRecord.msg_type == type_record)
                    {
                        UIImageView *readImage=(UIImageView *)[cell.contentView viewWithTag:status_audio_tag];
                        readImage.hidden = NO;
                    }else if(_convRecord.msg_type == type_video){
                        if (_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading)) {
                            if (maxSendFileSize == 20) {
                            }
                            else{// if(maxSendFileSize == 21){
                                //配置文件上传参数
                                _convRecord.uploadRequest.uploadProgressDelegate = self;
                            }
                        }
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
                            //                            [self downloadFile:_convRecord.msgId andCell:cell];
                            if (maxSendFileSize == 20) {
                                [self downloadFile:_convRecord.msgId andCell:cell];
                            }
                            else{
                                [self downloadResumeFile:_convRecord.msgId andCell:cell];
                            }
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
                //                NSLog(@"%s msg body is %@",__FUNCTION__,_convRecord.msg_body);
                
                NSArray *arr = [_convRecord.msg_body componentsSeparatedByString:@"-+-"];
                if (arr.count > 1) {
                    
                    HyperlinkCell *hyperlinkCell = (HyperlinkCell *)cell;
                    hyperlinkCell.title = [arr firstObject];
                    hyperlinkCell.URL = [arr lastObject];
                }
                else if (_convRecord.locationModel) {
                    if (!_convRecord.imageDisplay) {
                        //                        下载
                        self.curLocationRecord = _convRecord;
                        
                        LocationMsgCell *locationCell = (LocationMsgCell *)cell;
                        
                        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[locationCell.contentView viewWithTag:location_load_indicator_view_tag];
                        [indicator startAnimating];
                        
                        BMKMapView *mapView = [self.view viewWithTag:mapview_tag];
                        mapView.centerCoordinate = CLLocationCoordinate2DMake(_convRecord.locationModel.lantitude, _convRecord.locationModel.longtitude);
                        NSArray *_array = mapView.annotations;
                        if (_array.count) {
                            BMKPointAnnotation *an = (BMKPointAnnotation *)_array[0];
                            an.coordinate = mapView.centerCoordinate;
                            
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:locationCell,@"location_cell",_convRecord,@"location_convrecord", nil];
                            [self performSelector:@selector(snapShot:) withObject:dic afterDelay:2];
                        }
                        
                        //                        [locationCell createLocationPic:_convRecord];
                    }
                }else if (_convRecord.isRobotFileMsg){
                    failButton.hidden = YES;
                    if (_convRecord.isDownLoading && _convRecord.downloadRequest) {
                        [spinner startAnimating];
                    }
                    
                    [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
                }else if (_convRecord.isRobotImgTxtMsg){
                    //                    什么都不用做
                }
#ifdef _XINHUA_FLAG_
                else if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VIDEO] || [_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VOICE])
                {
                    [self downloadNewsVideo:_convRecord.msgId withCell:cell];
                }
#endif
                else if (_convRecord.isRobotPicMsg){
                    if (_convRecord.isDownLoading && _convRecord.downloadRequest) {
                        [spinner startAnimating];
                    }
                }else{
                    // 接收小万用户点击的文字选项
                    // 接收小万用户点击的文字选项
                    TextLinkView* linkView = (TextLinkView*)[cell.contentView viewWithTag:link_text_tag];
                    if ([self isTalkWithiRobot] && linkView){
                        [linkView setRobotClickTextBlock:^(NSString *selectText, bool isAgent) {
                            if (isAgent && selectText != nil && ![selectText isEqualToString:@""]) {
                                // 打开对应的人工服务账号的会话
                                if (!_ecloud) {
                                    _ecloud = [eCloudDAO getDatabase];
                                }
                                Emp *agentEmp = [_ecloud getEmpInfoByEmpName:selectText];
                                
                                talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                                
                                if ([self.navigationController.topViewController isKindOfClass:[talkSessionViewController class]]) {
                                    if ([talkSession.convId isEqualToString:[NSString stringWithFormat:@"%d",agentEmp.emp_id]]) {
                                        return;
                                    }
                                }
                                
                                talkSession.talkType = singleType;
                                talkSession.titleStr = agentEmp.emp_name;
                                talkSession.needUpdateTag = 1;
                                talkSession.convId = [NSString stringWithFormat:@"%d",agentEmp.emp_id];
                                talkSession.convEmps = [NSArray arrayWithObject:agentEmp];
                                
                                [self.navigationController popViewControllerAnimated:NO];
                                [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_ROBOT object:talkSession];
                                [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWORG object:nil];
                                
                            }else{
                                // 将选中的标签文字发送出去
                                audioMessage = selectText;
                                [self sendMessage_Click:nil];
                            }
                        }];
                    }
                }
                [talkSessionUtil sendReadNotice:_convRecord];
            }
                break;
            case type_imgtxt:
            {
                [talkSessionUtil sendReadNotice:_convRecord];
            }
                break;
            case type_wiki:
            {
                [talkSessionUtil sendReadNotice:_convRecord];
            }
                break;
        }
        
        //	如果是自己发送的一呼百应可以查看已读情况统计
        UIImageView *receiptView = (UIImageView*)[cell.contentView viewWithTag:receipt_tag];
        if (_convRecord.isReceiptMsg || _convRecord.isHuizhiMsg) {
            if (_convRecord.msg_flag == send_msg) {
                if(self.talkType == mutiableType)
                {
                    receiptView.userInteractionEnabled = YES;
                }
                else if(self.talkType == singleType)
                {
                    receiptView.userInteractionEnabled = NO;
                }
            }
            else if (_convRecord.msg_flag == rcv_msg)
            {
                if (_convRecord.readNoticeFlag == 0) {
                    receiptView.userInteractionEnabled = YES;
                }
                else
                {
                    receiptView.userInteractionEnabled = NO;
                }
            }
        }
        else
        {
            receiptView.userInteractionEnabled = NO;
        }
        //        NSLog(@"cell ========================== %@",NSStringFromCGRect(cell.frame));
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s 点击了 %@",__FUNCTION__,indexPath);
    //		点击后关闭键盘
    [self.messageTextField resignFirstResponder];
    if (self.talkType == publicServiceMsgDtlConvType) {
        [[PSMsgDspUtil getUtil]didSelectRowAtIndexPath:indexPath];
    }
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    if (isEditingConvRecord)
    {
        if (_convRecord) {
            _convRecord.isSelect = !_convRecord.isSelect;
            [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{
        if (_convRecord.isMiLiaoMsg && !_convRecord.isMiLiaoMsgOpen) {
            [talkSessionUtil sendReadNoticeByHand:_convRecord];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark===========================复制文本消息功能==================================
-(void)menuDisplay
{
    if (self.talkType == publicServiceMsgDtlConvType) {
        [[PSMsgDspUtil getUtil]menuDisplay];
    }
    else if(self.editMsgId && (self.talkType == singleType || self.talkType == mutiableType))
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        [[PSMsgDspUtil getUtil]menuHide];
    }
    else
    {
        if(self.editMsgId && !self.isDeleteAction)
        {
            UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.editRow inSection:0]];
            UIView *bodyView = [cell.contentView viewWithTag:body_tag];
            
            if (self.editRecord.msg_type == type_record) {
                [AudioMsgCell deactiveCell:cell andConvRecord:self.editRecord];
            }else if (self.editRecord.msg_type == type_file){
                [NewFileMsgCell deactiveCell:cell andConvRecord:self.editRecord];
            }else{
                
                if (self.editRecord.msg_flag == send_msg) {
                    bodyView.backgroundColor = send_msg_bg_color;
                }else{
                    bodyView.backgroundColor = rcv_msg_bg_color;
                }
            }
            
            
//            UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
//            if(bubbleView.hidden)
//            {
//                bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
//            }
//            bubbleView.highlighted = NO;
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
    if (isEditingConvRecord) {
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
        
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        if ([window isKeyWindow] == NO)
        {
            [window becomeKeyWindow];
            [window makeKeyAndVisible];
        }
        
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
        else if (self.talkType == publicServiceMsgDtlConvType)
        {
            if(indexPath.section == 0)
                return;
            self.editIndexPath = indexPath;
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
        //		[cell becomeFirstResponder];
        [self becomeFirstResponder];
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
        
        float menuX = [longClickCell getCellContentWidth] / 2;
        
        NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
        int menuY=[pointY intValue]-longClickCell.frame.origin.y;
        UIMenuController * menu = [UIMenuController sharedMenuController];
        [UIAdapterUtil dismissMenu];
        
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"copy"] action:@selector(copyAction:)];
        UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"delete"] action:@selector(deleteAction:)];
        UIMenuItem *menuItem4 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"paste"] action:@selector(pasteAction:)];
        
        [menu setMenuItems:[NSArray arrayWithObjects:menuItem,menuItem2,menuItem4,nil]];
        
        [menu setTargetRect: CGRectMake(menuX , menuY, 1, 1) inView: longClickCell];
        [menu setMenuVisible: YES animated: YES];
    }
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        [[PSMsgDspUtil getUtil]showMenu:dic];
    }
    else
    {
        UIView *bubbleView = [longClickCell.contentView viewWithTag:body_tag];
//        UIImageView *bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_send_tag];
//        if(bubbleView.hidden)
//        {
//            bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_rcv_tag];
//        }
//#ifdef _LANGUANG_FLAG_
//        
//        if (self.editRecord.redPacketModel) {
//            
//            bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:body_tag];
//        }
//#endif
        NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
        float copyX;
        if (self.editRecord.msg_type == type_record) {
            [AudioMsgCell activeCell:longClickCell andConvRecord:self.editRecord];
        } else if (self.editRecord.msg_type == type_file) {
            [NewFileMsgCell activeCell:longClickCell andConvRecord:self.editRecord];
        }else{
            if(self.editRecord.msg_flag == rcv_msg)
            {
                bubbleView.backgroundColor = rcv_msg_active_bg_color;
            }
            else{
                bubbleView.backgroundColor = send_msg_active_bg_color;
            }
        }
        if(self.editRecord.msg_flag == rcv_msg)
        {
            copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width / 2 + 5;
        }
        else
        {
            copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width/2 - 5;
        }
        
        int copyY=[pointY intValue]-longClickCell.frame.origin.y;
#ifdef _LANGUANG_FLAG_
        
        if ([self.editRecord.redPacketModel.type isEqualToString:@"redPacketAction"]) {
            
            copyX = SCREEN_WIDTH / 2;
            
        }
#endif
        UIMenuController * menu = [UIMenuController sharedMenuController];
        
        [UIAdapterUtil dismissMenu];
        
        
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"copy"] action:@selector(copyAction:)];
        UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"delete"] action:@selector(deleteAction:)];
        UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"forward"] action:@selector(Forwarding:)];
        UIMenuItem *menuItem4 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"paste"] action:@selector(pasteAction:)];
        UIMenuItem *menuItem5 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"download"] action:@selector(downloadAction:)];
        UIMenuItem *menuItem6 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"collect"] action:@selector(collectAction)];
        //        消息召回
        UIMenuItem *menuItem7 = [[[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"msg_recall"] action:@selector(msgRecallAction)]autorelease];
        UIMenuItem *menuItem8 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"audioToTxt"] action:@selector(audioToTxtAction)];
        
        UIMenuItem *menuItem9 = [[[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"menu_more"] action:@selector(editConvRecord)]autorelease];
        //"saved_to_the_cloud_disk"
        
        UIMenuItem *menuItem10 = [[[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"saved_to_the_cloud_disk"] action:@selector(savedTocloud)]autorelease];
        
        UIMenuItem *menuItem11 = [[[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"menu_reply"] action:@selector(replyAction)]autorelease];
        
        UIMenuItem *menuItem12 = [[[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"share"] action:@selector(shareToOtherApp)]autorelease];
        
        //        UIMenuItem *menuItem11 = [[[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_preview"] action:@selector(clounFilePreView)]autorelease];
        
        [menu setMenuItems:[NSArray arrayWithObjects:menuItem,menuItem2,menuItem7,menuItem3,menuItem4,menuItem5,menuItem6,menuItem11,menuItem8,menuItem12,menuItem10,menuItem9,nil]];
        
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        UIMenuItem *menuItemAudio = [[[UIMenuItem alloc] initWithTitle:[[AudioReceiverModeUtil getUtil] getPopMenuText] action:@selector(audioAction)]autorelease];
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:menu.menuItems];
        [mArray insertObject:menuItemAudio atIndex:0];
        menu.menuItems = mArray;
#endif
        
        [menuItem release];
        [menuItem2 release];
        [menuItem3 release];
        [menuItem4 release];
        [menuItem5 release];
        [menuItem6 release];
        [menuItem8 release];
        
        [menu setTargetRect: CGRectMake(copyX , copyY, 1, 1) inView: longClickCell];
        [menu setMenuVisible: YES animated: YES];
    }
}

#pragma mark 只提供复制功能
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.talkType == publicServiceMsgDtlConvType) {
        return [[PSMsgDspUtil getUtil]canPerformAction:action withSender:sender];
    }
    BOOL retValue = NO;
    if (self.editRecord.isMiLiaoMsg) {
        return retValue;
    }
    if (action == @selector(Forwarding:))
    {
        // 图片和文本
        if(self.editRecord && (self.editRecord.msg_type == type_text || self.editRecord.msg_type == type_long_msg || self.editRecord.msg_type == type_pic || self.editRecord.msg_type == type_video || (editRecord.msg_type == type_file && editRecord.download_flag != state_download_nonexistent) || self.editRecord.msg_type == type_imgtxt))
        {
            retValue = YES;
        }
#ifdef _LANGUANG_FLAG_
        
        if (self.editRecord.redPacketModel) {
            
            return NO;
        }
        
#endif
    }else if (action == @selector(editConvRecord)){
        if (self.editRecord && CAN_EDIT_CONVRECORD && self.editRecord.msg_type != type_group_info) {
            retValue = YES;
        }
        
#ifdef _LANGUANG_FLAG_
        
        if (self.editRecord.redPacketModel) {
            if ([self.editRecord.redPacketModel.type isEqualToString:@"redPacketAction"]) {
                
                return NO;
                
            }
        }
#endif
        
    }
    else if (action == @selector(copyAction:))
    {
        //		图片和文本
        if(self.editRecord && ((self.editRecord.msg_type == type_text && (!self.editRecord.isRobotFileMsg && !self.editRecord.isRobotPicMsg && !self.editRecord.isRobotImgTxtMsg))  || self.editRecord.msg_type == type_long_msg || self.editRecord.msg_type == type_pic))
        {
            retValue = YES;
            //云文件类型，不显示复制
            if (self.editRecord.cloudFileModel) {
                return NO;
            }
#ifdef _LANGUANG_FLAG_
            if (self.editRecord.redPacketModel) {
                return NO;
            }
#endif
        }
    }
    else if(action == @selector(deleteAction:))
    {
        if(self.editRecord && self.editRecord.msg_type != type_group_info)
        {
            retValue = YES;
        }
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
            else if (editRecord.download_flag == state_download_nonexistent){
                //文件不存在，不显示下载快捷菜单
                retValue = NO;
            }
            else{
                retValue = YES;
            }
        }
    }
    else if(action == @selector(replyAction))
    {
#ifdef _LANGUANG_FLAG_
        /** 把用户长按的消息记录暂存起来 固定群组才有定向回复 收到的消息可以定向回复 红包没有定向回复*/
        retValue = NO;
        if (self.talkType == mutiableType && [[UserDataDAO getDatabase]isSystemGroup:self.convId] && self.editRecord.msg_flag == rcv_msg) {
            if (self.editRecord.redPacketModel) {
                
            }else{
                [WXReplyOneMsgUtil getUtil].sendConvRecord = self.editRecord;
                retValue = YES;
            }
       }
#endif
    }
    else if(action == @selector(collectAction))
    {
        if ([eCloudConfig getConfig].supportCollection  && self.editRecord && (self.editRecord.msg_type != type_group_info || self.editRecord.msg_type != type_recall_msg || self.editRecord.locationModel || self.editRecord.newsModel)){
            retValue = YES;
        }
#ifdef _LANGUANG_FLAG_
        
        if (self.editRecord.redPacketModel) {
            return NO;
        }
#endif
    }
    else if (action == @selector(msgRecallAction))
    {
        //        如果是通知消息 则不显示撤回菜单
        if([eCloudConfig getConfig].supportRecallMsg && self.editRecord.msg_flag == send_msg  && self.editRecord.send_flag == send_success)
        {
            if (self.editRecord.msg_type == type_group_info) {
                retValue = NO;
            }else{
                int msgTime = [self.editRecord.msg_time intValue];
                int nowTime = [_conn getCurrentTime];
                
                int time = 180;
                
#ifdef _LANGUANG_FLAG_
                
                NSNumber *recallTime = [UserDefaults getLanGuangRecallTime];
                time = [recallTime intValue]*60;
#endif
                
                if (nowTime - msgTime <= time) {//3分钟内的可以撤回
                    retValue = YES;
                }
            }
        }
#ifdef _LANGUANG_FLAG_
        
        if (self.editRecord.redPacketModel) {
            return NO;
        }
#endif
    }
    else if(action == @selector(audioToTxtAction))
    {
        if (self.editRecord && self.editRecord.msg_type == type_record && [eCloudConfig getConfig].supportAudioToTxt) {
            retValue = YES;
        }
        
    }else if(action == @selector(savedTocloud))
    {
        if ([UIAdapterUtil isHongHuApp]) {
            if ((self.editRecord && self.editRecord.cloudFileModel) || (self.editRecord && self.editRecord.msg_type == type_file) ) {
                
                NSString *file_id =  [[CloudFileDOA getDatabase] isCloudFile:self.editRecord.msg_body];
                if ([file_id isEqualToString:@"NO"]) {
                    retValue = YES;
                }else{
                    retValue = NO;
                }
                
            }
        }
    }
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    else if (action == @selector(audioAction)){
        if (self.editRecord.msg_type == type_record) {
            retValue = YES;
        }
    }
#endif
    
#ifdef _LANGUANG_FLAG_
    else if (action == @selector(shareToOtherApp)){
        //		图片和文本
        if(self.editRecord && ((self.editRecord.msg_type == type_text && (!self.editRecord.isRobotFileMsg && !self.editRecord.isRobotPicMsg && !self.editRecord.isRobotImgTxtMsg))  || self.editRecord.msg_type == type_long_msg || self.editRecord.msg_type == type_pic))
        {
            retValue = YES;
        }
        if (self.editRecord.redPacketModel || self.editRecord.replyOneMsgModel || self.editRecord.locationModel || self.editRecord.newsModel) {
            
            retValue = NO;
        }
        if (self.talkType == singleType && [[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
            
            retValue = NO;
        }
    }
#endif
    //    else if(action == @selector(clounFilePreView))
    //    {
    //        if ([UIAdapterUtil isHongHuApp]) {
    //            if ((self.editRecord && self.editRecord.cloudFileModel) || (self.editRecord && self.editRecord.msg_type == type_file) ) {
    //
    //                NSString *file_id =  [[CloudFileDOA getDatabase] isCloudFile:self.editRecord.msg_body];
    //                if ([file_id isEqualToString:@"NO"]) {
    //                    retValue = NO;
    //                }else{
    //                    retValue = YES;
    //                }
    //
    //            }
    //        }
    //    }
    
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
            //            copyStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSData *data = [EncryptFileManege getDataWithPath:filePath];
            copyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        else if(self.editRecord.msg_type == type_pic)
        {
            NSString *fileName = [NSString stringWithFormat:@"%@.png",copyStr];
            NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
            
            NSData *imageData = [EncryptFileManege getDataWithPath:filePath];
            UIImage *img = [UIImage imageWithData:imageData];
            //            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
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
                if (maxSendFileSize == 20) {
                    [self downloadFile:self.editRecord.msgId andCell:nil];
                }
                else{
                    [self downloadResumeFile:self.editRecord.msgId andCell:nil];
                }
                self.forwardRecord = self.editRecord;
                //                [self enterLargePhotoesViewWithCurrentConvRecord:self.editRecord];
                isForwarding=NO;
            }
        }
        else if(self.editRecord.msg_type == type_video)
        {
            self.forwardRecord = self.editRecord;
            isForwarding=YES;
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
            
            /*
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
             
             //                [self downloadFile:self.editRecord.msgId andCell:nil];
             [self downloadResumeFile:self.editRecord.msgId andCell:nil];
             self.forwardRecord = self.editRecord;
             isForwarding=NO;
             }
             */
            
            //不去下载，直接跳转转发选人页面
            self.forwardRecord = self.editRecord;
            isForwarding=YES;
        }else if (self.editRecord.robotModel && self.editRecord.robotModel.msgType == type_text)
        {
            //            如果是小万的文本消息，那么需要把一些字符去掉再转发
            self.editRecord.msg_body = [StringUtil formatXiaoWanMsg:self.editRecord.msg_body];
            copyStr = self.editRecord.msg_body;
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
    if (self.talkType == publicServiceMsgDtlConvType) {
        [[PSMsgDspUtil getUtil]copy:sender];
        return;
    }
    //    update by shisp 如果复制的是文本或者长消息，那么把文本放到pasteboard；如果是图片，那么把图片放到pasteboard中
    if(self.editRecord)
    {
        self.messageTextField.copypic=false;
        
        NSString *copyStr = self.editRecord.msg_body;
        if(self.editRecord.msg_type == type_long_msg)
        {
            NSString *fileName = [NSString stringWithFormat:@"%@.txt",copyStr];
            NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
            NSData *data = [EncryptFileManege getDataWithPath:filePath];
            copyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //            copyStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        else if(self.editRecord.msg_type == type_pic)
        {
            NSString *fileName = [NSString stringWithFormat:@"%@.png",copyStr];
            
            NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
            
            //            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
            
            NSData *data = [EncryptFileManege getDataWithPath:filePath];
            UIImage *img = [UIImage imageWithData:data];
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
        }else if (self.editRecord.robotModel && self.editRecord.robotModel.msgType == type_text){
            copyStr = [StringUtil formatXiaoWanMsg:self.editRecord.msg_body];
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
    if (self.talkType == publicServiceMsgDtlConvType) {
        [[PSMsgDspUtil getUtil]delete:sender];
        return;
    }
    self.isDeleteAction = true;
    
    NSString *deleteMsgId = [StringUtil getStringValue:self.editRecord.msgId];
    if(self.talkType == massType)
    {
        [massDAO deleteOneMsg:deleteMsgId];
    }
    else
    {
        [_ecloud deleteOneMsg:deleteMsgId];
        
        //如果有文件在下载，那么从文件列表中移除，并且取消下载
        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:deleteMsgId.intValue];
        //如果有文件在上传，那么从文件列表中移除，并且取消上传
        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromUploadList:deleteMsgId.intValue];
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
                //                [self downloadFile:_convRecord.msgId andCell:nil];
                //                [self downloadResumeFile:_convRecord.msgId andCell:nil];
                if (maxSendFileSize == 20) {
                    [self downloadFile:_convRecord.msgId andCell:nil];
                }
                else{// if(maxSendFileSize == 21){
                    [self downloadResumeFile:_convRecord.msgId andCell:nil];
                }
            }
        }
    }
}

- (void)collectAction
{
    ConvRecord *convRecord = [[ConvRecord alloc] init];
    convRecord.msg_body = self.editRecord.msg_body;
    convRecord.file_name = self.editRecord.file_name;
    convRecord.file_size = self.editRecord.file_size;
    convRecord.msg_type = self.editRecord.msg_type;
    // 获取新的originID
    convRecord.origin_msg_id = [[conn getConn] getNewMsgId];
    convRecord.msg_time = self.editRecord.msg_time;
    convRecord.emp_id = self.editRecord.emp_id;
    convRecord.conv_id = self.editRecord.conv_id;
    convRecord.conv_type = self.editRecord.conv_type;
    convRecord.locationModel = self.editRecord.locationModel;
    convRecord.newsModel = self.editRecord.newsModel;
    convRecord.msg_type = self.editRecord.msg_type;
    convRecord.locationModel = self.editRecord.locationModel;
    convRecord.newsModel = self.editRecord.newsModel;

    if (convRecord.conv_type == 1)
    {
        convRecord.conv_title = self.editRecord.conv_title ? self.editRecord.conv_title :[[eCloudDAO getDatabase]getConvTitleByConvId:self.editRecord.conv_id];
    }
    else
    {
        convRecord.conv_title = [StringUtil getLocalizableString:@"personal"];
    }
    convRecord.msg_flag = self.editRecord.msg_flag;
    //    如果是本地收藏，也要判断是否是小万消息，如果是小万消息那么就要在解析后才能知道真正的类型
    convRecord.realMsgType = self.editRecord.msg_type;
    
    
    ConvRecord *_convRecord = [_ecloud getConvRecordByMsgId:[StringUtil getStringValue:self.editRecord.msgId]];
    NSString *tempMsgBody = _convRecord.msg_body;
    if ([[CollectionDAO shareDatabase]isXiaoWanMsg:tempMsgBody]) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 这是一条小万消息",__FUNCTION__]];
        convRecord.msg_body = _convRecord.msg_body;
        convRecord.msg_type = type_text;
    }
    
    
    // 去掉小万普通消息的的标签
    //    if ([[RobotDAO getDatabase] getRobotId] == convRecord.emp_id && convRecord.realMsgType == type_text)
    //    {
    //        convRecord.msg_body = [[talkSessionViewController getTalkSession] changeMsgBody:convRecord];
    //    }
    
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"operationType"] = @(1);
    dic[@"editRecord"] = convRecord;
    
    _conn = [conn getConn];
    dic[@"time"] = [NSString stringWithFormat:@"%d",[_conn getCurrentTime]];
    
    
    // 保存收藏到服务器
    [[CollectionConn getConn] sendModiRequestWithMsg:dic];
    
    // 收藏成功提示框
    [self performSelectorOnMainThread:@selector(showCollectTips:) withObject:[StringUtil getLocalizableString:@"already_collected"] waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}


#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
- (void)audioAction{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    [[AudioReceiverModeUtil getUtil]changeAudioMode];
    
    [listenModeViewNav removeFromSuperview];
    listenModeViewNav = nil;
    
    [self initTitle];
    
    listenModeView.alpha=1;
    UILabel *title_label=(UILabel *)[listenModeView viewWithTag:2];
    title_label.text = [[AudioReceiverModeUtil getUtil]getAudioReceiverTips];
    
    listenModeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissListenModeLater) userInfo:nil repeats:NO];
}
#endif

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
    if(!sendMsgEnable)
    {
        [UserTipsUtil sendMsgForbidden];
        return;
    }
    NSLog(@"%s",__FUNCTION__);
    
    
    // 在window上加一个view，让录音时不能点击
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-42)];
    [window addSubview:backView];
    
    // 关闭键盘按钮交互使能，让它不能点击
    talkButton.userInteractionEnabled = NO;
    
    
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
        //        addButton.enabled=NO;
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
    // 把window上让录音时不能点击的view去掉
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    [[window.subviews lastObject] removeFromSuperview];
    
    // 恢复键盘按钮交互使能
    talkButton.userInteractionEnabled = YES;
    
    
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
    // 把window上让录音时不能点击的view去掉
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    [[window.subviews lastObject] removeFromSuperview];
    
    // 恢复键盘按钮交互使能
    talkButton.userInteractionEnabled = YES;
    
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
        [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio_click"] forState:UIControlStateSelected];
        [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio_click"] forState:UIControlStateHighlighted];
        [pressButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio_click"] forState:UIControlStateFocused];
        
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
    
    NSRange range = [self.curAudioName rangeOfString:@"." options:NSBackwardsSearch];
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
        
        if (self.talkType == publicServiceMsgDtlConvType) {
            //            如果是公众号消息，那么保存到公众号消息表里
            [[PSMsgDspUtil getUtil]saveMediaPsMsg:type_record message:nowTime filesize:second filename:amr_name];
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
                if (maxSendFileSize == 20) {
                    [self uploadFile:convRecord];
                }
                else{
                    // 若是给小万发送的语音不需要上传，直接调用语音转文本接口[[RobotDAO getDatabase]isRobotUser:self.convId.intValue]
                    if ([self isTalkWithiRobot]) {
                        if ([UIAdapterUtil isGOMEApp]) {
                            [self prepareUploadFileWithFileRecord:convRecord];
                        }else{
                            [self uploadFileForAudioToTxt:convRecord];
                        }
                    }else{
                        [self prepareUploadFileWithFileRecord:convRecord];
                    }
                }
                
            }else
            {
                NSLog(@"amr not exsit");
            }
        }
    }
}

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
    
    if (isEditingConvRecord) {
        _convRecord.isSelect = !_convRecord.isSelect;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    
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
        [talkSessionUtil sendReadNotice:_convRecord];
        if (redstate==1)
        {
            UIImageView *readlabel=(UIImageView *)[cell.contentView viewWithTag:status_audio_tag];
            readlabel.hidden=YES;
            [_ecloud updateMessageToReadState:[StringUtil getStringValue:_convRecord.msgId]];
            _convRecord.is_set_redstate = 0;
        }
    }
    [playaudioview startAnimating];
    
    NSString *playPathStr = pathStr;
    
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        NSString *newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Temp_%@",_convRecord.file_name]];
        
        NSData *data = [EncryptFileManege getDataWithPath:pathStr];
        BOOL success = [data writeToFile:newPath atomically:YES];
        
        if (success)
        {
            NSLog(@"EncryptSuccess");
        }
        playPathStr = newPath;
    }
    
    
    NSRange range=[playPathStr rangeOfString:@".amr"];
    
    if (range.length > 0)
    {//需要转换
        NSString * docFilePath        = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:@"amrAudio.wav"];
        
        [amrtowav startAMRtoWAV:playPathStr tofile:docFilePath];
        if ([eCloudConfig getConfig].needFixSecurityGap)
        {
            [[NSFileManager defaultManager] removeItemAtPath:playPathStr error:docFilePath];
        }
        
        [self playAudio:docFilePath];
        //[self performSelector:@selector(playAudio:) withObject:docFilePath afterDelay:1];
        return;
    }
    [self playAudio:playPathStr];
    
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
    CFStringRef route = nil;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == nil) || (CFStringGetLength(route) == 0)){
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
        listenModeView.alpha=1;
        title_label.text= [StringUtil getLocalizableString:@"handset_to_speakers"];
        
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        listenModeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissListenModeLater) userInfo:nil repeats:NO];
    }
    
    
}
#pragma mark 确定发送文件消息后，显示在聊天界面，并且开始传输
- (void)dismissListenModeLater{
    [listenModeTimer invalidate];
    listenModeTimer=nil;
    
    [UIView animateWithDuration:1 animations:^{
        
        listenModeView.alpha=0;
    }];
    //    listenModeView.hidden=YES;
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
        listenModeView.alpha=1;
        
        title_label.text=[StringUtil getLocalizableString:@"handset_model"];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        listenModeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismissListenModeLater) userInfo:nil repeats:NO];
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
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[StringUtil getLocalizableString:@"please_open_the_setting-privacy-camera_and_allow_the_program_open_the_camera"]
                                                       delegate:nil
                                              cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"]
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    
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
    
    
    //    if (pickerPic==nil) {
    pickerPic = [[UIImagePickerController alloc] init];
    pickerPic.delegate = self;
    [pickerPic.navigationBar setTintColor:[UIColor colorWithRed:46.0/255.0 green:127.0/255.0 blue:255.0/255.0 alpha:1]];
    //    }
   	pickerPic.sourceType = UIImagePickerControllerSourceTypeCamera;
    //pickerPic.showsCameraControls=YES;
    pickerPic.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
    pickerPic.cameraFlashMode=UIImagePickerControllerCameraFlashModeOff;
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
        [self presentViewController:pickerPic animated:YES completion:^{
            
        }];
    }else{
        [UIAdapterUtil presentVC:pickerPic];
    }
    [pickerPic release];
    //    [self presentModalViewController:pickerPic animated:NO];
}

- (void)goToMiLiao
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    self.talkType = singleType;
    self.needUpdateTag = 1;
    Emp *emp = self.convEmps.firstObject;
    self.titleStr = emp.emp_name;
    self.convId = [[MiLiaoUtilArc getUtil]getMiLiaoConvIdWithEmpId:emp.emp_id];
    self.convEmps = [NSArray arrayWithObject:emp];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_TO_MILIAO object:nil];
    
    
    
    [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:self.convId andTitle:self.titleStr];
    
    
    NSLog(@"开始密聊");
}

- (void)getCameraVideo
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
    
    ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied)
    {
        //无权限
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[StringUtil getLocalizableString:@"please_open_the_setting-privacy-photos_and_allow_the_program_open_the_photos"]
                                                       delegate:nil
                                              cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"]
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    //    if (!pickerVideo) {
    pickerVideo=[[UIImagePickerController alloc]init];
    pickerVideo.delegate=self;//设置代理，检测操作
    //    }
    pickerVideo.sourceType=UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
    pickerVideo.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
    pickerVideo.mediaTypes=@[(NSString *)kUTTypeMovie];
    pickerVideo.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;//UIImagePickerControllerQualityTypeMedium;//
    pickerVideo.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
    pickerVideo.allowsEditing=YES;//允许编辑
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
        [self presentViewController:pickerVideo animated:YES completion:^{
            
        }];
    }else{
        [UIAdapterUtil presentVC:pickerVideo];
    }
    //    [self presentViewController:pickerVideo animated:YES completion:nil];
    [pickerVideo release];
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
    }else if (deleteConvRecordsActionSheet == actionSheet){
        if (buttonIndex == 0) {
            [self deleteSelectedConvRecords];
        }else{
            [self cancelEditConvRecord];
        }
    }
}
-(void)setAlphaToView:(UIView *)tempview
{
    tempview.alpha=1;
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

#pragma mark 点击超链接打开网址
- (void)addSingleTapToHyperlink:(UITableViewCell *)cell
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickHyperlink:)];
    [cell addGestureRecognizer:singleTap];
    [singleTap release];
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

- (void)onClickHyperlink:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    
    NSArray *arr = [_convRecord.msg_body componentsSeparatedByString:@"-+-"];
    NSString *urlStr = [arr lastObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_WEB_NOTIFICATION object:urlStr userInfo:nil];
}

- (void)onClickVideoImage:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    
    if (isEditingConvRecord) {
        NSLog(@"%s 正在编辑状态，不打开视频，选择或者取消选择当前记录",__FUNCTION__);
        _convRecord.isSelect = !_convRecord.isSelect;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    
    //    NSString *videoname=[NSString stringWithFormat:@"%@.mp4",_convRecord.msg_body];
    NSString *videoname = _convRecord.file_name;
#ifdef _XINHUA_FLAG_
    if (_convRecord.systemMsgModel)
    {
        videoname = [talkSessionUtil getNewsVideoName:_convRecord];
    }
#endif
    NSString *videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:videoname];
    
    DisplayVideoViewController *videoCtrl = [[[DisplayVideoViewController alloc]init]autorelease];
    videoCtrl.message = videopath;
    [self.navigationController pushViewController:videoCtrl animated:YES];
    
    //    UINavigationController *navigation = [[[UINavigationController alloc]initWithRootViewController:videoCtrl]autorelease];
    //    [UIAdapterUtil presentVC:navigation];
    //    [self presentViewController:navigation animated:YES completion:nil];
}

-(void)onClickImage:(UIGestureRecognizer*)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    
    if (isEditingConvRecord) {
        NSLog(@"%s 编辑状态 不打开图片 选择或者取消选择当前聊天记录",__FUNCTION__);
        _convRecord.isSelect = !_convRecord.isSelect;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    //    公众号消息 点击查看图片
    if (self.talkType == publicServiceMsgDtlConvType) {
        [self enterLargePhotoesViewWithCurrentConvRecord:_convRecord];
        return;
    }
#ifdef _XINHUA_FLAG_
    if (_convRecord.isRobotPicMsg || _convRecord.systemMsgModel) {
        //        直接显示这张图片即可
        [[RobotDisplayUtil getUtil]onClickRobotImage:_convRecord];
        return;
    }
#endif
    UIImageView *tempimageView=((UIImageView*)((UITapGestureRecognizer*)gestureRecognizer).view);
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
        }else{
            [self enterLargePhotoesViewWithCurrentConvRecord:_convRecord];
        }
    }
}

#pragma mark 多图 发送
#define KEY_PIC_ARRAY @"PIC_ARRAY"
#define KEY_RECEIPT_MSG_FLAG @"RECEIPT_MSG_FLAG"
#define KEY_PIC_DATA @"PIC_DATA"
-(void)uploadManyPics:(NSMutableArray *)picArray
{
    //    当用户发送多个图片时 需要标示是普通消息 还是钉消息，因此在这里要记住钉消息的状态
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:picArray,KEY_PIC_ARRAY,[NSNumber numberWithInt:receiptMsgFlag],KEY_RECEIPT_MSG_FLAG, nil];
    manyPicArray=[[NSArray alloc]initWithObjects:dic, nil];// [picArray copy];
    //    manyPicArray=[picArray copy];
    pic_index=0;
    // update by shisp 不用休眠1s，图片名称使用ms就不会有问题
    //    manypicTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doUploadManyPicsAction) userInfo:nil repeats:YES];
    
    manypicTimer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(doUploadManyPicsAction) userInfo:nil repeats:YES];
}

-(void)doUploadManyPicsAction
{
    NSArray *picArray = [manyPicArray[0] valueForKey:KEY_PIC_ARRAY];
    
    if (pic_index < [picArray count]){
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        CGImageRef imageRef;
        ALAsset *asset=[[picArray objectAtIndex:pic_index] asset];
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
            NSNumber *iReceiptMsgFlag = [manyPicArray[0] valueForKey:KEY_RECEIPT_MSG_FLAG];
            [self displayAndUploadPic:[NSDictionary dictionaryWithObjectsAndKeys:iReceiptMsgFlag,KEY_RECEIPT_MSG_FLAG,data,KEY_PIC_DATA, nil]];
            
        }
        
        [pool drain];
        
        pic_index++;
    }
    
    if (pic_index==[picArray count]) {
        [manypicTimer invalidate];
        manypicTimer=nil;
        [manyPicArray release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadPicFinished" object:nil];
        return;
    }
}

#pragma mark 确定发送图片消息后，显示在聊天界面，并且开始传输
-(void)displayAndUploadPic:(id)picData
{
    //  默认是聊天界面记录的状态
    NSNumber *iReceiptMsgFlag = [NSNumber numberWithInt:receiptMsgFlag];
    
    NSData *data = nil;
    if ([picData isKindOfClass:[NSData class]]) {
        data = (NSData *)picData;
    }else if ([picData isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)picData;
        data = dic[KEY_PIC_DATA];
        iReceiptMsgFlag = dic[KEY_RECEIPT_MSG_FLAG];
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // 文件的临时名称，此处文件类型怎么不是jpeg类型，因为压缩时是按照jpeg类型压缩的
    //    update by shisp 使用毫秒
    //    NSString *currenttimeStr=[StringUtil currentTime];
    NSString *currenttimeStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
    
    //存入本地
    NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
    NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
    
    BOOL success = NO;
    success = [data writeToFile:picpath atomically:YES];
    
    if (!success) {
        [pool release];
        return;
    }
    if (self.talkType == publicServiceMsgDtlConvType) {
        [[PSMsgDspUtil getUtil]saveMediaPsMsg:type_pic message:currenttimeStr filesize:data.length filename:pictempname];
        
        [pool release];
        [pickerPic dismissModalViewControllerAnimated:YES];
        pickerPic = nil;
        
        return;
    }
    NSString *msgId = [self addMediaRecord:type_pic message:currenttimeStr filesize:data.length filename:pictempname andReceiptMsgFlag:iReceiptMsgFlag.intValue];
    if(msgId)
    {
        ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
        [self addOneRecord:convRecord andScrollToEnd:true];
        
        if (maxSendFileSize == 20) {
            [self uploadFile:convRecord];
        }
        else{
            [self prepareUploadFileWithFileRecord:convRecord];
        }
    }
    
    [pool release];
    [pickerPic dismissModalViewControllerAnimated:YES];
    pickerPic = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissModalViewControllerAnimated:YES];
    pickerPic = nil;
}

#pragma mark - 拍照或选择图片后，对图片进行裁剪，预览
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
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
    // 视频
    else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            maxVideoDuration = [talkSessionUtil getVideoDuration:info[UIImagePickerControllerMediaURL]];
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_prepare"]];
            [[LCLLoadingView currentIndicator]show];
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
    }
    //	拍照
    else if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImage *newImage = image;
        CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
        if(_size.width > 0 && _size.height > 0)
        {
            newImage = [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationMedium];
        }
        
        ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied || author == kCLAuthorizationStatusNotDetermined)
        {
            
        }else{
            
            UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);//存入相册
        }
        //		拍照后再压缩成jpeg格式？
        //        NSData *data=UIImageJPEGRepresentation(image,0.5);
        NSData *newData = UIImageJPEGRepresentation(newImage, 0.5);
        
        //        NSLog(@"%s data-len is %d new data len is %d imagesize is %@ newimagesize is %@",__FUNCTION__,data.length,newData.length,NSStringFromCGSize(image.size),NSStringFromCGSize(newImage.size));
        
        [self performSelector:@selector(displayAndUploadPic:) withObject:newData afterDelay:1];
    }
    [pool release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {}

#pragma mark - 视频保存后的处理
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        
        [self videoWithUrl:url withFileName:nil];
        
        
        //        // 截取出文件名
        //        NSArray *videoTempname = [videoPath componentsSeparatedByString:@"/tmp/"];
        //        NSData  *myData = [[NSData  alloc] initWithContentsOfURL:url];
        //        NSString *msgId = [self addMediaRecord:type_video message:videoTempname[1] filesize:myData.length filename:videoTempname[1]];
        //        if(msgId)
        //        {
        //            ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
        //            [self addOneRecord:convRecord andScrollToEnd:true];
        //
        //        }
        
        //        [pickerVideo dismissModalViewControllerAnimated:YES];
    }
}

// 将原始视频的URL转化为NSData数据,写入沙盒
- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName
{
    //    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *currenttimeStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *videotempname = [NSString stringWithFormat:@"%@.mp4",currenttimeStr];
    
    //存入本地
    NSString *videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:videotempname];
    
    /*ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     if (url) {*/
    /*// 第一种方法
     [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
     ALAssetRepresentation *rep = [asset defaultRepresentation];
     NSString * videoPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
     char const *cvideoPath = [videoPath UTF8String];
     FILE *file = fopen(cvideoPath, "a+");
     if (file) {
     const int bufferSize = 11024 * 1024;
     // 初始化一个1M的buffer
     Byte *buffer = (Byte*)malloc(bufferSize);
     NSUInteger read = 0, offset = 0, written = 0;
     NSError* err = nil;
     if (rep.size != 0)
     {
     do {
     read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
     written = fwrite(buffer, sizeof(char), read,file);
     offset += read;
     } while (read != 0 && !err);//没到结尾，没出错，ok继续
     }
     // 释放缓冲区，关闭文件
     free(buffer);
     buffer = NULL;
     fclose(file);
     file = NULL;
     }
     } failureBlock:nil];*/
    
    
    // 第二种方式
    /*[assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) // substitute YOURURL with your url of video
     {
     ALAssetRepresentation *rep = [asset defaultRepresentation];
     Byte *buffer = (Byte*)malloc(rep.size);
     NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
     NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
     [data writeToFile:videopath atomically:YES]; //you can remove this if only nsdata needed
     }failureBlock:^(NSError *err) {
     NSLog(@"Error: %@",[err localizedDescription]);
     }];*/
    
    // 第三种方法
    
    /*BOOL success= [myData writeToFile:videopath atomically:YES];
     if (!success) {
     return;
     }
     }
     });*/
    
    // 视频类型由MOV转换为mp4
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        // AVAssetExportPresetHighestQuality 高清转码
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        exportSession.outputURL = [NSURL fileURLWithPath:videopath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        //        CMTime start = CMTimeMakeWithSeconds(1.0, 100000);
        //
        //        CMTime duration = CMTimeMakeWithSeconds(maxVideoDuration, 100000);
        //
        //        CMTimeRange range = CMTimeRangeMake(start, duration);
        //
        //        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"转换操作失败，失败原因为: %@", [[exportSession error] localizedDescription]);
                    
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"转换操作取消");
                    
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                        NSData *myData=[NSData dataWithContentsOfFile:videopath];
                        
                        sendVideoDic = [[NSMutableDictionary alloc]init];
                        [sendVideoDic setValue:currenttimeStr forKey:@"message"];
                        [sendVideoDic setValue:[NSNumber numberWithInt:myData.length] forKey:@"filesize"];
                        //                        [sendVideoDic setValue:[NSNumber numberWithInt:maxVideoDuration] forKey:@"filesize"];
                        [sendVideoDic setValue:videotempname forKey:@"filename"];
                        //                        sendVideoDic = @{@"message":currenttimeStr,@"filesize":[NSNumber numberWithInt:myData.length],@"filename":videotempname};
                        // 弹出转换后的大小提示框
                        UIAlertView *alertViewForVideo = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"视频压缩后文件大小为%dK,确定要发送吗?",myData.length/1024] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"send"], nil];
                        alertViewForVideo.tag = upload_video_tag;
                        [alertViewForVideo show];
                        [alertViewForVideo release];
                    });
                    
                    
                }
                    break;
                default:
                    NSLog(@"Export status: %d", [exportSession status]);
                    break;
                    
            }
            
            [exportSession release];
            //            [pool release];
        }];
        
    }
    
}

#pragma mark 自动下载缩率图
- (void)autoDownloadSmallPic:(UITableViewCell*)cell andConvRecord:(ConvRecord *)recordObject
{
    UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [activity startAnimating];
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("download small pic", NULL);
    dispatch_async(queue, ^{
        //		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getSmallPicDownloadUrl],recordObject.msg_body]];
        NSURL *url;
        if (maxSendFileSize == 20){
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig]getSmallPicDownloadUrl],recordObject.msg_body,[StringUtil getDownloadAddStr:recordObject.msg_body]]];
        }
        else{
            //            if (recordObject.robotModel && recordObject.robotModel.msgType == type_pic ) {
            ////                小万图片消息的URL
            //                url = [NSURL URLWithString:recordObject.robotModel.msgFileDownloadUrl];
            //            }else{
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig]getNewSmallPicDownloadUrl],recordObject.msg_body,[StringUtil getResumeDownloadAddStr]]];
            //            }
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,url]];
        
        
        /*
         
         AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         [manager.requestSerializer setValue:@"netsense" forHTTPHeaderField:@"netsense"];
         // 默认传输的数据类型
         manager.responseSerializer = [AFHTTPResponseSerializer serializer];
         NSString *urlStr = [NSString stringWithFormat:@"%@", url];
         [manager GET:urlStr parameters:nil success:^(IM_AFHTTPRequestOperation *operation, id responseObject) {
         
         
         UIImage *image = [UIImage imageWithData:responseObject];
         recordObject.isDownLoading = false;
         dispatch_async(dispatch_get_main_queue(), ^{
         
         if (image!=nil)
         {
         [activity stopAnimating];
         
         NSString *smallpicname = [NSString stringWithFormat:@"small%@.png",recordObject.msg_body];
         if ([[RobotDAO getDatabase]isRobotUser:recordObject.conv_id.intValue] && recordObject.robotModel != nil) {
         smallpicname = [NSString stringWithFormat:@"small%@",recordObject.file_name];
         }
         NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:smallpicname];
         //                BOOL success= [imageData writeToFile:picpath atomically:YES];
         BOOL success = [EncryptFileManege saveFileWithPath:picpath withData:responseObject];
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
         
         } failure:^(IM_AFHTTPRequestOperation *operation, NSError *error) {
         
         }];
         
         */
        // /*
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        recordObject.isDownLoading = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (image!=nil)
            {
                [activity stopAnimating];
                
                NSString *smallpicname = [NSString stringWithFormat:@"small%@.png",recordObject.msg_body];
                //                if ([[RobotDAO getDatabase]isRobotUser:recordObject.conv_id.intValue] && recordObject.robotModel != nil) {
                //                    smallpicname = [NSString stringWithFormat:@"small%@",recordObject.file_name];
                //                }
                NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:smallpicname];
                //                BOOL success= [imageData writeToFile:picpath atomically:YES];
                BOOL success = [EncryptFileManege saveFileWithPath:picpath withData:imageData];
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
        
        //  */
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
        [_progressView setProgress:1.0 animated:YES];
        [talkSessionUtil hideProgressView:_progressView];
        
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        
        //更新上传状态
        NSInteger uploadstate =  send_success;
        NSString *upload_id = [NSString stringWithFormat:@"%d",_convRecord.msgId];
        [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
    }
    else if (_convRecord.msg_type == type_video) {
        UIView *view = (UIView *)[cell.contentView viewWithTag:body_tag];
        UIProgressView *_progressView=(UIProgressView*)[view viewWithTag:video_progress_tag];
        //        [_progressView setProgress:1.0 animated:YES];
        [talkSessionUtil hideProgressView:_progressView];
        
        //更新上传状态
        NSInteger uploadstate =  send_success;
        NSString *upload_id = [NSString stringWithFormat:@"%d",_convRecord.msgId];
        [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
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
    if (isEditingConvRecord) {
        NSLog(@"%s 正在编辑状态，不支持头像长按",__FUNCTION__);
        return;
    }
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
    if (isEditingConvRecord) {
        NSLog(@"%s 现在是编辑状态，不打开个人资料界面 选择或者取消选择当前记录",__FUNCTION__);
        _convRecord.isSelect = !_convRecord.isSelect;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    
    NSString *empId = [StringUtil getStringValue:_convRecord.emp_id];
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
        //        如果是密聊，就不能查看人员资料
        return;
    }
    
    if ([self.convId isEqualToString:SECRETARY_ID] || [self.convId isEqualToString:File_ID] || [self.convId isEqualToString:MEETING_ID] || [self.convId isEqualToString:MEETING_ID_TEST]) {
   
        
    }else{
        
        [NewOrgViewController openUserInfoById:empId andCurController:self];
    }
    
}

#pragma mark 根据msgId找到对应的下标
-(int)getArrayIndexByMsgId:(int)msgId{
    for(int i = self.convRecordArray.count - 1;i>=0;i--)
    {
        id _convRecord = [self.convRecordArray objectAtIndex:i];
        
        if ([_convRecord isKindOfClass:[ConvRecord class]]) {
            if(((ConvRecord*)_convRecord).msgId == msgId)
            {
                return i;
            }
        }
    }
    return -1;
}

- (void)saveAndSendVideoMsg
{
    NSLog(@"upload_video_tag.....%@",[sendVideoDic description]);
    NSNumber *filesizeNum = [sendVideoDic valueForKey:@"filesize"];
    
    NSString *msgId = [self addMediaRecord:type_video message:[sendVideoDic valueForKey:@"message"] filesize:[filesizeNum intValue] filename:[sendVideoDic valueForKey:@"filename"]];
    if(msgId)
    {
        ConvRecord *convRecord = [self getConvRecordByMsgId:msgId];
        [self addOneRecord:convRecord andScrollToEnd:true];
        
        if (maxSendFileSize == 20) {
            [self uploadFile:convRecord];
        }
        else{
            [self prepareUploadFileWithFileRecord:convRecord];
        }
    }
}
- (void)cancelSendVideoMsg
{
    // 删除转码后的mp4文件
    [talkSessionUtil delFileFromPath:[[StringUtil newRcvFilePath] stringByAppendingPathComponent:[sendVideoDic valueForKey:@"filename"]]];
}

#pragma mark 重发提示框处理
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
#ifdef _HUAXIA_FLAG_
    if (alertView.tag == create_huaxia_conf_alert_tag && buttonIndex == 1) {
        
        NSString *createConfUser = [_ecloud getEmpInfo:_conn.userId].empCode;
        
        NSMutableArray *participants = [NSMutableArray array];
        
        for (Emp *_emp in self.convEmps) {
            if (_emp.emp_id != [conn getConn].userId.intValue) {
                [participants addObject:_emp.empCode];
            }
        }
        
        if (participants.count) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 调用createConfWithCreateUser方法
                [[HuaXiaConfUtil getUtil] createConfWithCreateUser:createConfUser andParticipants:participants andOpenVC:self];
            });
        }
        return;
    }
#endif
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == upload_video_tag) {
        if (buttonIndex == 1) {
            [self saveAndSendVideoMsg];
            //            [self performSelector:@selector(saveAndSendVideoMsg) withObject:nil afterDelay:0.05];
        }else{
            [self cancelSendVideoMsg];
            //            [self performSelector:@selector(cancelSendVideoMsg) withObject:nil afterDelay:0.05];
        }
        [pickerVideo dismissViewControllerAnimated:NO completion:^{
            NSLog(@"录制视频界面已经消失");
        }];
        return;
    }
    if(alertView.tag == download_file_tag)
    {
        if(buttonIndex == 1)
        {
            UILabel *msgIdLabel = (UILabel*)[alertView viewWithTag:download_file_msg_id_tag];
            int msgId = msgIdLabel.text.intValue;
            //			[self downloadFile:msgId andCell:nil];
            //            [self downloadResumeFile:msgId andCell:nil];
            if (maxSendFileSize == 20) {
                [self downloadFile:msgId andCell:nil];
            }
            else{// if(maxSendFileSize == 21){
                [self downloadResumeFile:msgId andCell:nil];
            }
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
            
            //			[self uploadFile:_record];
            
            //区分文件消息和其他类型消息上传
            if (_record.msg_type == type_file) {
                [self sendForwardFileMsg:_record];
            }
            else if (_record.msg_type == type_pic || _record.msg_type == type_record || _record.msg_type == type_long_msg || _record.msg_type == type_video){
                if (maxSendFileSize == 20) {
                    [self uploadFile:_record];
                }
                else{
                    [self prepareUploadFileWithFileRecord:_record];
                }
            }
            //            else{
            //                [self uploadFile:_record];
            //            }
        }
    }
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)refresh
{
    [self initMapView];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self hideTabBar];
    
    if (self.needUpdateTag == 1) {
        [self.convRecordArray removeAllObjects];
        
        if ([self isTalkWithiRobot]) {
            [self initRobotMenu];
            //            初始化选中的知识库
            NSArray *knowledgeArray = [[RobotDisplayUtil getUtil]getKnowledgeArray];
            if (knowledgeArray.count > 0) {
                [RobotDisplayUtil getUtil].selectRobotMenu = knowledgeArray[0];
            }
        }
        
        [self initYhby];
    }
    
    //    long long start = [StringUtil currentMillionSecond];
    
    //    获取状态 可以异步去获取
    _statusConn.curViewController = self;
    dispatch_queue_attr_t _queue = dispatch_queue_create("get conv status", NULL);
    dispatch_async(_queue, ^(){
        [_statusConn getStatus];
    });
    dispatch_release(_queue);
    
    sendMsgEnable = YES;
    backFlag = NO;
    
    //    增加通知
    [self initObserver];
    
    [self initTextField];
    
    [self initRcvFlagView];
    
    //    华夏提出了一个问题，就是@人之后，回执会自动消失，所以代码调到了上面
    //    [self initYhby];
    
    [self initConnStatus];
    
    [self initBar];
    
    self.curRecordPath = nil;
    
    [self initConversation];
    
    [self sendEnable];
    
    [self setRightBtn];
    
    [self initData];
    
    [self initTitle];
    
    [self refreshViews];
    
    showAndHideRecord = YES;//!showAndHideRecord;
    [self showAndHideRecordBtn];
    
    [self setChatBackground];
    
    //    NSLog(@"%s 需要时间%d",__FUNCTION__,[StringUtil currentMillionSecond] - start);
    if ([UIAdapterUtil isHongHuApp]) {
        
        if (IS_IPHONE) {
            
            NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
            
        }
    }
    
#ifdef _LANGUANG_FLAG_
    
    if (self.talkType == singleType && [[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
        /** 密聊title加个马赛克图片 */
        UIImage *mosaicImage  = [StringUtil getImageByResName:@"Mosaic"];
        _MosaicImageView = [[UIImageView alloc]initWithImage:mosaicImage];
        _MosaicImageView.center = self.navigationItem.titleView.center;
        self.navigationItem.titleView = _MosaicImageView;
        
    }
    
#endif
}

#pragma mark 滑动到表格最下面的数据
-(void)scrollToEnd
{
    if (self.talkType == publicServiceMsgDtlConvType)
    {
        [[PSMsgDspUtil getUtil]scrollToEnd];
        return;
    }
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
    //    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //    BOOL success = [EncryptFileManege saveFileWithPath:tempPath withData:data];
    BOOL success= [message writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:&_error];
    if (!success) {
        //        NSLog(@"%s,error is %@",__FUNCTION__,_error.domain);
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
        
        if (maxSendFileSize == 20) {
            [self uploadFile:convRecord];
        }
        else{
            [self prepareUploadFileWithFileRecord:convRecord];
        }
        
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
    if (_convRecord == nil) {
        [LogUtil debug:[NSString stringWithFormat:@"%s _convRecord is nil",__FUNCTION__]];
        return;
    }
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

#pragma mark ===============文件下载====================
#pragma mark - 封装下载文件方法
-(void)downloadFile:(int)msgId andCell:(UITableViewCell*)_cell{
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
    
    NSString *fileUrl = _convRecord.msg_body;
    
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
                
                fileUrl = [_convRecord.msg_body substringToIndex:range.location];
                
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
    
    NSString *oldUrlStr = request.url.absoluteString;
    NSString *newUrlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getDownloadAddStr:fileUrl]];
    NSURL *newURL = [NSURL URLWithString:newUrlStr];
    request.url = newURL;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,file url is %@, new url is %@",__FUNCTION__,fileUrl,newUrlStr]];
    
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

#pragma mark ==================================================================

#pragma mark - 聊天记录修改后，局部刷新
-(void)reloadRow:(int)_index
{
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index-1];
    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
    [self performSelectorOnMainThread:@selector(reloadTableViewData) withObject:nil waitUntilDone:NO];
}

- (void)reloadTableViewData
{
    [self.chatTableView reloadData];
    
}

#pragma mark ========一呼百应消息已读情况统计==========
//如果是发送的消息是显示已读统计
//如果是收到的消息则点击后，发送回执
-(void)viewReadStat:(UITapGestureRecognizer *)gestureRecognizer
{
    if (isEditingConvRecord) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    if(_convRecord.isReceiptMsg || _convRecord.isHuizhiMsg)
    {
        if (_convRecord.msg_flag == send_msg) {
            ReceiptMsgDetailViewController *_controller = [[ReceiptMsgDetailViewController alloc]init];
            _controller.msgId = _convRecord.msgId;
            _controller.convRecord = _convRecord;
            [self.navigationController pushViewController:_controller animated:YES];
            [_controller release];
        }
        else if (_convRecord.msg_flag == rcv_msg)
        {
            if (_convRecord.readNoticeFlag == 0) {
                if (_convRecord.isHuizhiMsg && ![eCloudConfig getConfig].autoSendMsgReadOfHuizhiMsg) {
                    [talkSessionUtil sendReadNoticeByHand:_convRecord];
                }
            }
        }
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        return [_psDAO getServiceMsgCountByServiceId:self.serviceModel.serviceId];
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        recordList = [_psDAO getServiceMessageByServiceId:self.serviceModel.serviceId andLimit:limit andOffset:offset];
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        return self.serviceModel.lastInputMsg;
    }
    else
    {
        return [_ecloud getLastInputMsgByConvId:convId];
    }
}

#pragma 根据cell的indexpath得到数据数组的下标
-(int)getIndexByIndexPath:(NSIndexPath*)indexPath
{
    if(self.talkType == massType || self.talkType == publicServiceMsgDtlConvType)
    {
        return indexPath.section - 1;
    }
    return indexPath.row - 1;
}

#pragma 根据数组的下标，得到indexPath
-(NSIndexPath*)getIndexPathByIndex:(int)index
{
    if(self.talkType == massType || self.talkType == publicServiceMsgDtlConvType)
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
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        [_psDAO saveLastInputMsgOfService:self.serviceModel.serviceId andLastInputMsg:lastInputMsg];
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

//准备预览的数据 如果参数不为空，那么需要返回所在的位置，否则返回-1
- (int)prepareGalleryData:(ConvRecord *)convRecord
{
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
    
    NSMutableArray *recordList;
    
    if(self.talkType == massType)
    {
        recordList= [NSMutableArray arrayWithArray:[massDAO getPicConvRecordBy:self.convId]];
    }
    else if (self.talkType == publicServiceMsgDtlConvType)
    {
        recordList = [NSMutableArray arrayWithArray:[_psDAO getPicConvRecordBy:self.serviceModel.serviceId]];
    }
    else
    {
        recordList= [NSMutableArray arrayWithArray:[_ecloud getPicConvRecordBy:self.convId]];
    }
    
    NSLog(@"recordList------%i",[recordList count]);
    
    NSInteger currIndex = -1;
    int i = 0;
    
    //筛选当前会话记录中所有图片的
    for (ConvRecord *_convRecord in recordList) {
        if (self.talkType == publicServiceMsgDtlConvType && _convRecord.msg_flag == rcv_msg) {
            //            update by shisp 发送的照片 和 普通消息一样处理 收到的图片才特殊处理
            [networkImagesArr addObject:[[PSMsgDspUtil getUtil]getPSMsgImageUrl:_convRecord]];
            [networkThumbnailImagesArr addObject:@""];
        }
        else
        {
            NSString *urlStr;
            //大图url，准备下载
            //            NSString *urlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig] getPicDownloadUrl],_convRecord.msg_body];
            if (maxSendFileSize == 20){
                urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getPicDownloadUrl],_convRecord.msg_body,[StringUtil getDownloadAddStr:_convRecord.msg_body]];
            }
            else{
                urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getNewPicDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
            }
            
            [networkImagesArr addObject:urlStr];
            //            NSLog(@"%s urlStr is %@",__FUNCTION__,urlStr);
            
            //缩略图url
            //            NSString *ThumbnailUrlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase] getServerConfig] getSmallPicDownloadUrl],_convRecord.msg_body];
            NSString *ThumbnailUrlStr;
            if (maxSendFileSize == 20){
                ThumbnailUrlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase] getServerConfig] getSmallPicDownloadUrl],_convRecord.msg_body,[StringUtil getDownloadAddStr:_convRecord.msg_body]];
            }
            else{
                ThumbnailUrlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase] getServerConfig] getNewSmallPicDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
            }
            
            [networkThumbnailImagesArr addObject:ThumbnailUrlStr];
            
        }
        if (_convRecord && convRecord.msgId == _convRecord.msgId) {
            currIndex = i;
        }
        i ++ ;
    }
    return currIndex;
}

- (void)enterLargePhotoesViewWithCurrentConvRecord:(ConvRecord *)convRecord{
    int currIndex = [self prepareGalleryData:convRecord];
    
    //NSLog(@"currIndex-------%i",currIndex);
    
    networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self withCurrentIndex:currIndex];
    networkGallery.needDisplaySwitchButton = YES;
    //self.title = @"返回";
    self.navigationController.delegate = self;
    networkGallery.convId = self.convId;
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
    NSString *pathStr;
    if (size == FGalleryPhotoSizeThumbnail) {
        pathStr = [networkThumbnailImagesArr objectAtIndex:index];
    }
    else {
        
        pathStr = [networkImagesArr objectAtIndex:index];
    }
    //    NSLog(@"%s pathStr is %@",__FUNCTION__,pathStr);
    return pathStr;
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
-(void)displayAndUploadLocalFile:(NSData *)data withDic:(NSMutableDictionary *)dic
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //    后面附加一个_,用来区分是本地发送的文件，还是收到或同步过来的文件
    NSString *currenttimeStr=[StringUtil currentTime];
    NSString *fullFileName = [dic valueForKey:@"fileName"];
    
    NSRange _range = [fullFileName rangeOfString:@"." options:NSBackwardsSearch];
    if (_range.length > 0) {
        NSString *ext = [fullFileName substringFromIndex:_range.location + 1];
        NSString *fileName = [fullFileName substringToIndex:_range.location];
        
        NSString *tempFileName = [NSString stringWithFormat:@"%@_%@.%@",fileName,currenttimeStr,ext];
        NSString *tempFilePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:tempFileName];
        
        BOOL success= [data writeToFile:tempFilePath atomically:YES];
        if (!success) {
            return;
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"%s filepath is %@ msgbody is %@ filename is %@",__FUNCTION__,tempFilePath,currenttimeStr,fullFileName]];
        
        NSString *msgId = [self addMediaRecord:type_file message:currenttimeStr filesize:data.length filename:fullFileName];
        if(msgId)
        {
            ConvRecord *convRecord = [self  getConvRecordByMsgId:msgId];
            [self addOneRecord:convRecord andScrollToEnd:true];
            if (maxSendFileSize == 20) {
                [self uploadFile:convRecord];
            }
            else{
                [self prepareUploadFileWithFileRecord:convRecord];
            }
        }
    }
}

- (void)fileListViewControllerClickOnBackBtn:(FileListViewController *)localFilesCtr withSelectFiles:(NSMutableArray *)filesArr{
    //NSLog(@"filesArr------%@",filesArr);
    if (!manyFilesArray) {
        manyFilesArray = [[NSMutableArray alloc] init];
    }
    
    [manyFilesArray removeAllObjects];
    
    //单聊的先创建再保存消息
    if(self.talkType == singleType){
        [self createSingleConversation];
    }
    
    for (ConvRecord *_convRecord in filesArr) {
        _convRecord.conv_id = self.convId;
        _convRecord.conv_type = self.talkType;
        _convRecord.receiptMsgFlag = receiptMsgFlag;
        
        //保存转发的文件消息
        [self saveMsgWithConvRecord:_convRecord toArray:manyFilesArray];
    }
    
    file_index=0;
    manyFileTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doUploadManyFilesAction) userInfo:nil repeats:YES];
}

- (void)doUploadManyFilesAction{
    if (file_index==[manyFilesArray count]) {
        [manyFileTimer invalidate];
        manyFileTimer=nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadFilesFinished" object:nil];
        self.needUpdateTag = 1;
        return;
    }
    
    ConvRecord *_convRecord = [manyFilesArray objectAtIndex:file_index];
    [self sendForwardFileMsg:_convRecord];
    file_index++;
}


#pragma 上传文件，根据类型不同，进行不同上传
-(void)uploadFile:(ConvRecord*)_convRecord
{
    int msgType = _convRecord.msg_type;
    NSURL *url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig] getPicUploadUrl]];
    
    switch(msgType)
    {
        case type_pic:
        {
        }
            break;
        case type_record:
        {
            url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig] getAudioFileUploadUrl]];
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
    
    //    文件名称 计算md5时使用
    NSString *fileName = _convRecord.file_name;
    
    if(msgType == type_long_msg)
    {
        fileName = [NSString stringWithFormat:@"%@.txt",_convRecord.msg_body];
        filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
    }
    else if (msgType == type_file){
        filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
        //发送文件，显示进度条
        int _index = [self getArrayIndexByMsgId:_convRecord.msgId];
        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
        [talkSessionUtil displayProgressView:_progressView];
        [request setUploadProgressDelegate:_progressView];
        request.showAccurateProgress = YES;
        
        //更改上传状态
        [self updateSendFlagByMsgId:[StringUtil getStringValue:_convRecord.msgId] andSendFlag:send_uploading];
        _convRecord.send_flag = send_uploading;
        
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
    
    NSURL *oldUrl = request.url;
    NSString *oldUrlStr = oldUrl.absoluteString;
    NSString *newUrlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getUploadAddStr:fileName]];
    NSURL *newUrl = [NSURL URLWithString:newUrlStr];
    request.url = newUrl;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s filename is %@, new url is %@",__FUNCTION__,fileName,newUrlStr]];
    
    [request addFile:filePath withFileName:nil andContentType:@"multipart/form-data" forKey:@"body"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:[StringUtil getStringValue:_convRecord.msgId] forKey:@"MSG_ID"]];
    
    [request setDidFinishSelector:@selector(uploadFileComplete:)];
    [request setDidFailSelector:@selector(uploadFileFail:)];
    [request setTimeOutSeconds:[self getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    [request startAsynchronous];
    [request release];
    
    
    if (msgType == type_file){
        //纪录文件上传事件
        [[talkSessionUtil2 getTalkSessionUtil] addRecordToUploadList:_convRecord];
    }
}
//{
//    int msgType = _convRecord.msg_type;
//    NSURL *url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getPicUploadUrl]];
//
//    switch(msgType)
//    {
//        case type_pic:
//        {
//        }
//            break;
//        case type_record:
//        {
//            url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getAudioFileUploadUrl]];
//        }
//            break;
//        case type_long_msg:
//        {
//            url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getLongMsgUploadUrl]];
//        }
//            break;
//        case type_file:
//        {
//            url = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getAudioFileUploadUrl]];
//        }
//            break;
//    }
//
//    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
//    [request setDelegate:self];
//
//    NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
//
//    if(msgType == type_long_msg)
//    {
//        filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
//    }
//    else if (msgType == type_file){
//        //发送文件，显示进度条
//        int _index = [self getArrayIndexByMsgId:_convRecord.msgId];
//        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
//        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
//        [talkSessionUtil displayProgressView:_progressView];
//        [request setUploadProgressDelegate:_progressView];
//        request.showAccurateProgress = YES;
//
//        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
//    }
//    else if (msgType == type_pic){
//        //发送图片，显示进度条
//        int _index = [self getArrayIndexByMsgId:_convRecord.msgId];
//        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
//        UILabel *_progressView = (UILabel *)[cell.contentView  viewWithTag:pic_progress_Label_tag];
//        _progressView.hidden = NO;
//        [request setUploadProgressDelegate:_progressView];
//        request.showAccurateProgress = YES;
//    }
//
//    [request addFile:filePath withFileName:nil andContentType:@"multipart/form-data" forKey:@"body"];
//    [request setUserInfo:[NSDictionary dictionaryWithObject:[StringUtil getStringValue:_convRecord.msgId] forKey:@"MSG_ID"]];
//
//    [request setDidFinishSelector:@selector(uploadFileComplete:)];
//    [request setDidFailSelector:@selector(uploadFileFail:)];
//    [request setTimeOutSeconds:[self getRequestTimeout]];
//    [request setNumberOfTimesToRetryOnTimeout:3];
//    request.shouldContinueWhenAppEntersBackground = YES;
//    [request startAsynchronous];
//    [request release];
//}

//#pragma mark 上传文件成功处理
//-(void)uploadFileComplete:(ASIHTTPRequest *)request
//{
//    int statuscode=[request responseStatusCode];
//
//    NSString* response = [request responseString];
//    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
//
//    NSDictionary *dic=[request userInfo];
//    NSString *msgId = [dic valueForKey:@"MSG_ID"];
//    NSString *token = [dic valueForKey:@"Token"];
//    int _index = [self getArrayIndexByMsgId:msgId.intValue];
//
//    ConvRecord *_convRecord;
//    if(_index < 0)
//    {
//        _convRecord = [self  getConvRecordByMsgId:msgId];
//    }
//    else
//    {
//        _convRecord =[self.convRecordArray objectAtIndex:_index];
//    }
//
//    int msgType = _convRecord.msg_type;
//
//    if(statuscode == 200 && [response length] == 0)
//    {
//        NSLog(@"上传文件，状态正常，返回空");
//        [self uploadFile:_convRecord];
//        return;
//    }
//
//    if (statuscode!=200)
//    {
//        [self uploadFile:_convRecord];
//        return;
//    }
//
//    NSString *oldName = _convRecord.file_name;
//    NSString *oldPath;
//
//    NSString *newName;
//    NSString *newPath;
//
//    switch(msgType)
//    {
//        case type_pic:
//        {
//            newName=[NSString stringWithFormat:@"%@.png",response];
//        }
//            break;
//        case type_record:
//        {
//            NSRange range=[oldName rangeOfString:@"." options:NSBackwardsSearch];
//            NSString *ext = [oldName substringFromIndex:range.location + 1];
//            newName = [NSString stringWithFormat:@"%@.%@",response,ext];
//        }
//            break;
//        case type_long_msg:
//        {
//            newName=[NSString stringWithFormat:@"%@.txt",response];
//            oldName = [NSString stringWithFormat:@"%@.txt", _convRecord.msg_body];
//        }
//            break;
//        case type_file:
//        {
//
//        }
//            break;
//    }
//    if (msgType == type_file) {
//        //        不做处理
//    }
//    else{
//        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:oldName];
//        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:newName];
//
//        NSFileManager *fileMgr = [NSFileManager defaultManager];
//        [fileMgr moveItemAtPath:oldPath toPath:newPath error:nil];
//    }
//
//    //		从新路径下取出文件数据，并且保存新路径
//    NSString *sendbody=[NSString stringWithFormat:@"%@",response];
//
//    if(msgType == type_file)
//    {
//        NSString *oldMsgbody = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
//        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
//
//        _convRecord.msg_body = [NSString stringWithFormat:@"%@",sendbody];
//
//        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
//
//        if (![oldPath isEqualToString:newPath]) {
//            [LogUtil debug:[NSString stringWithFormat:@"%s oldPath is %@ newPath is %@",__FUNCTION__,oldPath,newPath]];
//
//            NSFileManager *fileMgr = [NSFileManager defaultManager];
//            BOOL secces = [fileMgr moveItemAtPath:oldPath toPath:newPath error:nil];
//
//            [self updateConvFileRecordWithOLdMSG:oldMsgbody andMSG:sendbody];
//        }
//
//        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromUploadList:msgId.intValue];
//    }
//    else
//    {
//        _convRecord.msg_body = sendbody;
//    }
//
//    NSString *fileName = nil;
//    //	if(msgType != type_long_msg)
//    //	{
//    //        fileName = newName;
//    //		_convRecord.file_name = newName;
//    //	}
//
//    if(msgType == type_pic || msgType == type_record)
//    {
//        fileName = newName;
//        _convRecord.file_name = newName;
//    }
//    else if(msgType == type_file)
//    {
//        fileName = oldName;
//    }
//
//    if(self.talkType == massType)
//    {
//        [massDAO updateConvRecord:msgId andMSG:sendbody andFileName:fileName andMsgType:msgType];
//    }
//    else
//    {
//        [_ecloud updateConvRecord:msgId andMSG:sendbody andFileName:fileName andNewTime:0 andConvId:nil andMsgType:msgType];
//    }
//
//    _convRecord.send_flag = sending;
//
//    [self sendMessage:msgType message:sendbody filesize:_convRecord.file_size.intValue filename:fileName andOldMsgId:msgId];
//
//    if(_index >= 0)
//    {
//        [self reloadRow:_index+1];
//    }
//}

#pragma mark - 上传语音转文字
-(void)uploadFileForAudioToTxt:(ConvRecord*)_convRecord
{
    //    文件名称 计算md5时使用
    NSString *fileName = _convRecord.file_name;
    NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
    
    //    NSString *newUrlStr = [NSString stringWithFormat:@"%@%@",@"http://ctx.wanda.cn:8090/USCService/usc",[StringUtil getUploadAudioTest:fileName]];
    NSString *newUrlStr = [NSString stringWithFormat:@"%@%@",[[ServerConfig shareServerConfig]getAudioToTxtURL],[StringUtil getUploadAudioTest:fileName]];
    [LogUtil debug:[NSString stringWithFormat:@"%s filename is %@, new url is %@",__FUNCTION__,fileName,newUrlStr]];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:newUrlStr]];
    [request setDelegate:self];
    
    // 要是带路径的不行，就用下面的形式
    /*?userid=2&filemd5=c63e432bc70a4a028536f0f54ba6e367&filename=test.zip&filesize=16169826&type=2&t=现在时间&guid=121212&mdkey=md5()*/
    //    NSString *tmpStr = [StringUtil getUploadAudioTest:fileName];
    //    NSArray *tmpArr = [tmpStr componentsSeparatedByString:@","];
    //    NSArray *paramNameArr = @[@"userid",@"filemd5",@"filename",@"filesize",@"type",@"t",@"guid",@"mdkey"];
    //
    //    for (int i = 0;i < paramNameArr.count;i++) {
    //        [request setPostValue:tmpArr[i] forKey:paramNameArr[i]];
    //    }
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    int filesize = [data length];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d",filesize]];
    [request addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
    //    [request addFile:filePath withFileName:nil andContentType:@"multipart/form-data" forKey:@"body"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:[StringUtil getStringValue:_convRecord.msgId] forKey:@"MSG_ID"]];
    request.requestMethod = @"POST";
    
    [request setPostBody:data];
    [request setDidFinishSelector:@selector(uploadFileComplete:)];
    [request setDidFailSelector:@selector(uploadFileFail:)];
    [request setTimeOutSeconds:[self getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    
    [request startAsynchronous];
    
    //输入返回的信息
    NSLog(@"response\n%@",[request responseString]);
    [request release];
    
    
    //    if (msgType == type_file){
    //        //纪录文件上传事件
    //        [[talkSessionUtil2 getTalkSessionUtil] addRecordToUploadList:_convRecord];
    //    }
}

#pragma mark 上传文件成功处理
-(void)uploadFileComplete:(ASIHTTPRequest *)request
{
    int statuscode = [request responseStatusCode];
    NSString* response = [request responseString];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
    if (statuscode != 200) {
        return;
    }
    
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    NSDictionary *dic=[request userInfo];
    NSString *msgId = [dic valueForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    
    NSMutableDictionary *audioTxtDic = [NSMutableDictionary dictionary];
    [audioTxtDic setValue:self.convId forKey:@"conv_id"];
    [audioTxtDic setValue:msgId forKey:@"msg_id"];
    [audioTxtDic setValue:[NSString stringWithFormat:@"%d",_conn.curUser.emp_id] forKey:@"user_id"];
    int nowtimeInt= [_conn getCurrentTime];
    NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
    [audioTxtDic setValue:nowTime forKey:@"msg_time"];
    [audioTxtDic setValue:[responseDic valueForKey:@"result"] forKey:@"message"];
    
    // 将语音服务器返回的语音文本保存到数据库中
    [[AudioTxtDAO getDatabase]saveAudioTxtInfo:audioTxtDic];
    
    // add 增加对语音文本的处理 by yanlei [[RobotDAO getDatabase]isRobotUser:self.convId.intValue]
    if ([self isTalkWithiRobot]) {
        // 语音上传完成后，调用语音转文本
        //        [self uploadFileForAudioToTxt:self.editRecord];
        if(_index < 0)
        {
            //用户已经切换到了别的会话，此时应该修改数据库，记录上传失败的状态
            [self updateSendFlagByMsgId:msgId andSendFlag:save_location];
            return;
        }
        
        ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
        if (_convRecord.msg_type == type_record && _convRecord.msg_flag == send_msg) {
            _convRecord.send_flag = save_location;
            [self updateSendFlagByMsgId:msgId andSendFlag:save_location];
            
            //            convRecord.tryCount = 0;
            
            UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
            
            UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
            [spinner stopAnimating];
        }
        audioMessage = [NSString stringWithFormat:@"您的问题：\"%@\"",[[AudioTxtDAO getDatabase]getMessage:self.convId andMsgId:[msgId intValue]]];
        [self sendMessage_Click:nil];
    }else{// if([dic valueForKey:@"语音文本内容类型"]){
        // add 普通会话语音转文字,将转换后的文本保存到数据库中，并弹出转换后的文本lyan
        AudioToTextView *txtView = (AudioToTextView *)[[[UIApplication sharedApplication]keyWindow] viewWithTag:5520];
        if (txtView) {
            // 隐藏取消按钮
            [txtView.txtLoadingTxt stopAnimating];
            txtView.txtLoadingLabel.hidden = YES;
            txtView.txtLoadingTxt.hidden = YES;
            txtView.txtCancelBtn.hidden = YES;
            txtView.txtLabel.hidden = NO;
            
            // 从数据库中获取到刚才存储的记录
            
            txtView.txtLabel.text = [[AudioTxtDAO getDatabase]getMessage:self.convId andMsgId:[msgId intValue]];
            
            // 增加一个动画效果将返回的文本，一个字一个字的显示出来
            //            dispatch_async(dispatch_get_main_queue(), ^{
            ////                for (int i = i ; i < [txtView.txtLabel.text length]; i++) {
            //                    [UIView animateWithDuration:0.2f animations:^{
            ////                        txtView.txtLabel.text = [NSString stringWithFormat:@"%@",[strtmp substringToIndex:i]];
            //                        txtView.txtLabel.frame = [[UIApplication sharedApplication]keyWindow].bounds;
            //                    }];
            ////                }
            //            });
            // 为txtlabel增加触摸时间
            UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(romoveAudioToTxtViewAction)];
            [txtView.txtLabel addGestureRecognizer:tapG];
            [tapG release];
        }
        return;
    }
    
    //    NSString *msgId = [dic valueForKey:@"MSG_ID"];
    //    NSString *token = [dic valueForKey:@"Token"];
    //    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    //
    //    ConvRecord *_convRecord;
    //    if(_index < 0)
    //    {
    //        _convRecord = [self  getConvRecordByMsgId:msgId];
    //    }
    //    else
    //    {
    //        _convRecord =[self.convRecordArray objectAtIndex:_index];
    //    }
    //
    //    if(statuscode == 200 && [response length] == 0)
    //    {
    //        NSLog(@"上传文件，状态正常，返回空");
    //        [self uploadFile:_convRecord];
    //        return;
    //    }
    //
    //    if (statuscode!=200)
    //    {
    //        [self uploadFile:_convRecord];
    //        return;
    //    }
}

#pragma mark 上传文件失败处理
-(void)uploadFileFail:(ASIHTTPRequest *)request
{
    NSDictionary *userdic=[request userInfo];
    NSString *msgId=[userdic objectForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    if(_index < 0)
    {
        //用户已经切换到了别的会话，此时应该修改数据库，记录上传失败的状态
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
            //            [self uploadFile:_convRecord];
            //            if (_convRecord.msg_type == type_file) {
            //                if (maxSendFileSize == 20) {
            //                    [self uploadFile:_convRecord];
            //                }
            //                else if(maxSendFileSize == 21){
            //                    [self prepareUploadFileWithFileRecord:_convRecord];
            //                }
            //            }
            //            else{
            [self uploadFile:_convRecord];
            //            }
            return;
        }
    }
    
    _convRecord.tryCount = 0;
    
    [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
    
    _convRecord.send_flag = send_upload_fail;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    if (_convRecord.msg_type == type_file) {
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        //更新上传状态
        NSInteger uploadstate =  state_failure;
        [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:msgId withState:uploadstate];
    }
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    if (_convRecord.msg_type == type_file) {
        //        if (maxSendFileSize == 20) {
        //            UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
        //            failBtn.hidden=NO;
        //        }
        //        else if (maxSendFileSize == 21){
        //            //文件下载失败,显示失败按钮
        //            [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        //        }
        
        //文件下载失败,显示失败按钮
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else{
        UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
        failBtn.hidden=NO;
    }
}

#pragma mark ============================================================


#pragma mark =================文件断点续传相关=========================
//- (void)initASIQueue{
//    ASIQueue = [[ASINetworkQueue alloc] init];
//    [ASIQueue reset];
//    [ASIQueue setMaxConcurrentOperationCount:10];
//    [ASIQueue setShowAccurateProgress:YES];
//    [ASIQueue go];
//}

-(void)prepareUploadFileWithFileRecord:(ConvRecord*)_convRecord{
    [LogUtil debug:[NSString stringWithFormat:@"%s 看本地是否保存了上传记录，如果已经保存那么就获取token和上传位置，如果已经全部上传就直接发送，否则继续上传；如果本地没有保存上传记录，那么获取token和上传位置保存到数据库，并且开始上传",__FUNCTION__]];
    //准备上传
    NSString *upload_id = [NSString stringWithFormat:@"%i",_convRecord.msgId];
    __block UploadFileModel *fileMode = [[FileAssistantDOA getDatabase] getUploadFileWithUploadid:upload_id];
    __block int uploadstate =  state_waiting;
    if (fileMode.upload_id && fileMode.filemd5.length > 0) {
        //数据库已存在上传记录，重新获取token和文件上传起始位置
        //        在这里增加引用计数
        [fileMode retain];
        dispatch_queue_t queue;
        queue = dispatch_queue_create("get token code 1", NULL);
        dispatch_async(queue, ^{
            NSDictionary *dic = [FileAssistantConn getUploadFileToken:fileMode];
            //            用完之后 减少引用计数
            [fileMode release];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[dic objectForKey:@"result"] isEqualToString:@"success"]) {
                    NSString *token = [NSString stringWithFormat:@"%@",[dic objectForKey:@"token"]];
                    int upload_start_index = [[dic objectForKey:@"uploadsize"] intValue];
                    
                    [[FileAssistantDOA getDatabase] updateUploadFileModelWithUploadid:upload_id withToken:token withStartIndex:upload_start_index];
                    [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
                }
                else{
                    uploadstate =  state_failure;
                    [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
                    [self uploadFileFailWithConvRecord:_convRecord];
                    return;
                }
                
                UploadFileModel *uploadFileMode = [[FileAssistantDOA getDatabase] getUploadFileWithUploadid:upload_id];
                //判断起始位置是否和文件长度一致，如果是一致，直接发送消息
                int filesize = [_convRecord.file_size intValue];
                if (filesize == uploadFileMode.upload_start_index) {
                    [self sendMsgWithConvRecord:_convRecord];
                }
                else{
                    [self uploadFileWithUploadFileModel:uploadFileMode];
                }
            });
        });
        
        dispatch_release(queue);
    }
    else{
        //数据库无记录，创建一条新的上传记录
        //        NSString *filename = [talkSessionUtil getFileName:_convRecord];
        //        NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
        //        int type = 2;
        
        dispatch_queue_t queue;
        queue = dispatch_queue_create("get token code 2", NULL);
        dispatch_async(queue, ^{
            NSString *filename = @"";
            NSString *filePath = @"";
            int type ;
            
            switch (_convRecord.msg_type) {
                case type_pic:
                {
                    filename = _convRecord.file_name;
                    filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:filename];
                    type = 1;
                }
                    break;
                case type_record:
                {
                    filename = _convRecord.file_name;
                    filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:filename];
                    type = 2;
                }
                    break;
                case type_file:
                {
                    filename = [talkSessionUtil getFileName:_convRecord];
                    filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
                    type = 2;
                }
                    break;
                case type_long_msg:
                {
                    filename = [NSString stringWithFormat:@"%@.txt",_convRecord.msg_body];
                    filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
                    type = 2;
                }
                    break;
                case type_video:
                {
                    filename = _convRecord.file_name;
                    filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_convRecord.file_name];
                    type = 2;
                }
                    break;
                default:
                    break;
            }
            
            NSString *md5Str=[StringUtil getFileMD5WithPath:filePath];
            NSString *userid = [NSString stringWithFormat:@"%i",_convRecord.emp_id];
            NSString *filemd5 = md5Str;
            int filesize;
            
            if (_convRecord.msg_type == type_record) {
                NSData *data=[NSData dataWithContentsOfFile:filePath];
                filesize = [data length];
            }
            else{
                filesize = [_convRecord.file_size intValue];
            }
            
            
            int upload_start_index = 0;
            
            fileMode = [[UploadFileModel alloc] init];
            fileMode.userid = userid;
            fileMode.filemd5 = filemd5;
            fileMode.filename = filename;
            fileMode.filesize = filesize;
            fileMode.type = type;
            
            NSDictionary *dic = [FileAssistantConn getUploadFileToken:fileMode];
            [fileMode release];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([[dic objectForKey:@"result"] isEqualToString:@"success"]) {
                    NSString *token = [NSString stringWithFormat:@"%@",[dic objectForKey:@"token"]];
                    int upload_start_index = [[dic objectForKey:@"uploadsize"] intValue];
                    
                    //往数据添加上传记录
                    NSMutableDictionary *uploadEvent = [[NSMutableDictionary alloc] init];
                    [uploadEvent setObject:upload_id forKey:@"upload_id"];
                    [uploadEvent setObject:userid forKey:@"userid"];
                    [uploadEvent setObject:filemd5 forKey:@"filemd5"];
                    [uploadEvent setObject:filename forKey:@"filename"];
                    [uploadEvent setObject:[NSNumber numberWithInt:filesize] forKey:@"filesize"];
                    [uploadEvent setObject:[NSNumber numberWithInt:type] forKey:@"type"];
                    [uploadEvent setObject:token forKey:@"token"];
                    [uploadEvent setObject:[NSNumber numberWithInt:upload_start_index] forKey:@"upload_start_index"];
                    [uploadEvent setObject:[NSNumber numberWithInt:uploadstate] forKey:@"upload_state"];
                    
                    [LogUtil debug:[NSString stringWithFormat:@"%s 保存上传记录到数据库:%@",__FUNCTION__,uploadEvent]];
                    
                    [[FileAssistantDOA getDatabase] addOneFileUploadRecord:uploadEvent];
                    [uploadEvent release];
                }
                else{
                    uploadstate =  state_failure;
                    [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
                    [self uploadFileFailWithConvRecord:_convRecord];
                    return;
                }
                
                UploadFileModel *uploadFileMode = [[FileAssistantDOA getDatabase] getUploadFileWithUploadid:upload_id];
                if (filesize == uploadFileMode.upload_start_index) {
                    [self sendMsgWithConvRecord:_convRecord];
                }
                else{
                    [self uploadFileWithUploadFileModel:uploadFileMode];
                }
            });
        });
        
        dispatch_release(queue);
    }
}

-(void)uploadFileWithUploadFileModel:(UploadFileModel *)_fileMode{
    [LogUtil debug:[NSString stringWithFormat:@"%s 设置好上传参数开始上传，并且修改消息记录状态，设置进度delegate，保存上传request",__FUNCTION__]];
    int uploadstate =  state_uploading;
    NSString *userid = _fileMode.userid;
    NSString *token = _fileMode.token;
    int type = _fileMode.type;
    //    NSString *rc = [CRCUtil getCrc8:[NSString stringWithFormat:@"%@%@",userid,token]];
    int start_upload_index = _fileMode.upload_start_index;
    
    NSString *msgid = _fileMode.upload_id;
    
    NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_fileMode.filename];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *totaLength = [NSString stringWithFormat:@"%d",data.length];
    NSLog(@"原始文件长度%d filePath is %@",data.length,filePath);
    
    if (start_upload_index <= 0) {
        start_upload_index = 0;
    }
    else{
        data =[data subdataWithRange:NSMakeRange(start_upload_index, data.length-start_upload_index)];
    }
    
    NSString *data_len=[NSString stringWithFormat:@"%d",data.length];
    NSString *upload_start_index=[NSString stringWithFormat:@"%d",start_upload_index];
    NSLog(@"开始上传位置==== %@",upload_start_index);
    
    //    NSString *urlStr  = [NSString stringWithFormat:@"%@?userid=%@&token=%@&rc=%@",[[[eCloudUser getDatabase] getServerConfig] getFileUploadUrl],userid,token,rc];
    //    URL:http://host:port/FilesService/upload/?userid=2&token=01c63e432bc70a4a028536f0f54ba6e367.zip&t=1433232233&guid=12312312312312323&mdkey=1234567890abcdef1234567890abcdef
    
    NSString *urlStr  = [NSString stringWithFormat:@"%@?token=%@%@&type=%d",[[[eCloudUser getDatabase] getServerConfig] getFileUploadUrl],token,[StringUtil getResumeUploadAddStr],type];
    
    NSURL *dataurl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *datarequest = [[ASIFormDataRequest alloc] initWithURL:dataurl];
    [datarequest setDelegate:self];
    [datarequest addRequestHeader:@"Content-Length" value:data_len];
    [datarequest addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
    [datarequest addRequestHeader:@"Content-Offset" value:upload_start_index];
    [datarequest setRequestMethod:@"POST"];
    
    NSDictionary *data_dic=[NSDictionary dictionaryWithObjectsAndKeys:msgid,@"MSG_ID",upload_start_index,@"Start_Index",totaLength,@"Total_length",token,@"Token",nil];
    
    [datarequest setUserInfo:data_dic];
    [datarequest setPostBody:data];
    [datarequest setTimeOutSeconds:[StringUtil getRequestTimeout]];
    [datarequest setNumberOfTimesToRetryOnTimeout:1];
    datarequest.shouldContinueWhenAppEntersBackground = YES;
    
    //发送文件，显示进度条
    int _index = [self getArrayIndexByMsgId:[_fileMode.upload_id intValue]];
    
    ConvRecord *_convRecord;
    if(_index < 0){
        _convRecord = [self  getConvRecordByMsgId:_fileMode.upload_id];
    }
    else{
        _convRecord =[self.convRecordArray objectAtIndex:_index];
    }
    
    //更改上传状态
    [self updateSendFlagByMsgId:msgid andSendFlag:send_uploading];
    _convRecord.send_flag = send_uploading;
    
    if (_convRecord.msg_type == type_file) {
        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
        [talkSessionUtil displayProgressView:_progressView];
        [datarequest setUploadProgressDelegate:self];
        datarequest.showAccurateProgress = YES;
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else if (_convRecord.msg_type == type_video) {
        //        把视频的进度条 设置为 uploadProgressDelegate
        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
        UIProgressView *_progressView=(UIProgressView*)[cell.contentView viewWithTag:video_progress_tag];
        
        NSLog(@"video progress 进度 %.0f",_progressView.progress);
        
        float progress = [upload_start_index floatValue]/[data_len floatValue];
        [_progressView setProgress:progress animated:NO];
        
        [talkSessionUtil displayProgressView:_progressView];
        
        [datarequest setUploadProgressDelegate:_progressView];
        datarequest.showAccurateProgress = YES;
    }
    else if (_convRecord.msg_type == type_pic){
        //发送图片，显示进度条
        int _index = [self getArrayIndexByMsgId:_convRecord.msgId];
        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
        UILabel *_progressView = (UILabel *)[cell.contentView  viewWithTag:pic_progress_Label_tag];
        _progressView.hidden = NO;
        [datarequest setUploadProgressDelegate:_progressView];
        datarequest.showAccurateProgress = YES;
    }
    
    [datarequest setDidFinishSelector:@selector(uploadResumeFileComplete:)];
    [datarequest setDidFailSelector:@selector(uploadResumeFileFail:)];
    [datarequest startAsynchronous];
    _convRecord.uploadRequest = datarequest;
    [datarequest release];
    
    
    //    文件和视频都是在聊天界面上传的，所以要加到队列中 但是图片，语音，长消息都是在聊天界面上传的，为什么单单把文件加到队列里呢
    if (_convRecord.msg_type == type_file || _convRecord.msg_type == type_video){
        [[talkSessionUtil2 getTalkSessionUtil] addRecordToUploadList:_convRecord];
        [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:msgid withState:uploadstate];
    }
}

- (void)sendMsgWithConvRecord:(ConvRecord*)_convRecord{
    NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    UploadFileModel *uploadFileMode = [[FileAssistantDOA getDatabase] getUploadFileWithUploadid:msgId];
    
    NSString *sendbody = [NSString stringWithFormat:@"%@",uploadFileMode.token];
    
    int msgType = _convRecord.msg_type;
    
    NSString *oldName = @"";
    NSString *oldPath = @"";
    
    NSString *newName = @"";
    NSString *newPath = @"";
    
    //    对于文件来说 文件的路径 是在真正的文件名字后附加上msg_body再加上扩展名
    if (msgType == type_file) {
        oldName = _convRecord.file_name;
        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
        //        文件助手数据库
#ifdef _XIANGYUAN_FLAG_
        NSString * oldBody = _convRecord.msg_body;
        [[FileAssistantRecordDOA getFileDatabase]updateTheFileRecordMsgID:sendbody withOldMsgBody:oldBody];
#endif
        
        _convRecord.msg_body = [NSString stringWithFormat:@"%@",sendbody];
        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
        
        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromUploadList:msgId.intValue];
    }else
    {
        oldName = _convRecord.file_name;
        if (msgType == type_long_msg) {
            oldName = [NSString stringWithFormat:@"%@.txt",_convRecord.msg_body];
        }
        
        NSRange range=[oldName rangeOfString:@"." options:NSBackwardsSearch];
        NSString *ext = [oldName substringFromIndex:range.location + 1];
        newName = [NSString stringWithFormat:@"%@.%@",sendbody,ext];
        
        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:oldName];
        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:newName];
        
        _convRecord.msg_body = sendbody;
        
        if (msgType == type_video) {
            //        如果是视频 则从uploadlist中remove掉
            [[talkSessionUtil2 getTalkSessionUtil]removeRecordFromUploadList:msgId.intValue];
        }
    }
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:newPath]) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 文件token对应的文件已经存在",__FUNCTION__]];
        [[NSFileManager defaultManager]removeItemAtPath:oldPath error:nil];
    }else
    {
        NSData *data = [NSData dataWithContentsOfFile:oldPath];
        [EncryptFileManege saveFileWithPath:newPath withData:data];
        
        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s , oldName is %@,newName is %@",__FUNCTION__,oldName,newName]];
    
    NSString *fileName = nil;
    if(msgType == type_file)
    {
        fileName = oldName;
    }else if (msgType == type_long_msg){
        //        长消息 filename保存的是摘要信息，不用修改
    }
    else{
        
        fileName = newName;
        _convRecord.file_name = fileName;
    }
    
    if(self.talkType == massType){
        [massDAO updateConvRecord:msgId andMSG:sendbody andFileName:fileName andMsgType:msgType];
    }
    else{
        
        [_ecloud updateConvRecord:msgId andMSG:sendbody andFileName:fileName andNewTime:0 andConvId:nil andMsgType:msgType];
    }
    
    _convRecord.send_flag = sending;
    
    [self sendMessage:msgType message:sendbody filesize:_convRecord.file_size.intValue filename:fileName andOldMsgId:msgId];
    
    if(_index >= 0)
    {
        ConvRecord *curConvRecord = [self.convRecordArray objectAtIndex:_index];
        curConvRecord.msg_body = _convRecord.msg_body;
        curConvRecord.file_name = _convRecord.file_name;
        
        [self reloadRow:_index+1];
    }
}

-(void)uploadFileFailWithConvRecord:(ConvRecord*)_convRecord{
    NSString *msgId=[NSString stringWithFormat:@"%i",_convRecord.msgId];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    if(_index < 0)
    {
        //用户已经切换到了别的会话，此时应该修改数据库，记录上传失败的状态
        [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
        return;
    }
    _convRecord.tryCount = 0;
    
    [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
    
    _convRecord.send_flag = send_upload_fail;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    if (_convRecord.msg_type == type_file) {
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        //更新上传状态
        NSInteger uploadstate =  state_failure;
        [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:msgId withState:uploadstate];
    }
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    if (_convRecord.msg_type == type_file) {
        //文件下载失败,显示失败按钮
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else{
        UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
        failBtn.hidden=NO;
    }
}

#pragma mark - 断点续传相关协议
-(void)uploadResumeFileComplete:(ASIHTTPRequest *)request{
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
    
    //获取文件上传结果
    NSDictionary *responseDic = [response objectFromJSONString];
    NSString *resultStr = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"result"]];
    NSString *sendbody=[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"token"]];
    
    NSDictionary *dic=[request userInfo];
    NSString *msgId = [dic valueForKey:@"MSG_ID"];
    NSString *token = [dic valueForKey:@"Token"];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    
    ConvRecord *_convRecord;
    if(_index < 0){
        _convRecord = [self getConvRecordByMsgId:msgId];
    }
    else
    {
        _convRecord =[self.convRecordArray objectAtIndex:_index];
    }
    
    int msgType = _convRecord.msg_type;
    
    //上传失败，自动上传
    if (![resultStr isEqualToString:@"success"]) {
        [self uploadFileFailWithConvRecord:_convRecord];
        return;
    }
    
    [self sendMsgWithConvRecord:_convRecord];
    
    //    NSString *oldName;
    //    NSString *oldPath;
    //
    //    NSString *newName;
    //    NSString *newPath;
    //
    //    NSString *oldMsgbody = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
    //    if (msgType == type_file) {
    //        oldName = _convRecord.file_name;
    //        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
    //
    //        _convRecord.msg_body = [NSString stringWithFormat:@"%@",sendbody];
    //        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
    //
    //        if (![oldPath isEqualToString:newPath]) {
    //            [LogUtil debug:[NSString stringWithFormat:@"%s oldPath is %@ newPath is %@",__FUNCTION__,oldPath,newPath]];
    //
    //            NSFileManager *fileMgr = [NSFileManager defaultManager];
    //            [fileMgr moveItemAtPath:oldPath toPath:newPath error:nil];
    //
    //
    //            //修改数据库里面的文件
    //            [self updateConvFileRecordWithOLdMSG:oldMsgbody andMSG:sendbody];
    //        }
    //
    //        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromUploadList:msgId.intValue];
    //    }
    //    else if (_convRecord.msg_type == type_pic){
    //        oldName = _convRecord.file_name;
    //        newName=[NSString stringWithFormat:@"%@.png",sendbody];
    //
    //        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:oldName];
    //        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:newName];
    //
    //        NSFileManager *fileMgr = [NSFileManager defaultManager];
    //        [fileMgr moveItemAtPath:oldPath toPath:newPath error:nil];
    //
    //        _convRecord.msg_body = sendbody;
    //    }
    //    else if (_convRecord.msg_type == type_long_msg){
    //        newName=[NSString stringWithFormat:@"%@.txt",sendbody];
    //        oldName = [NSString stringWithFormat:@"%@.txt", _convRecord.msg_body];
    //
    //        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:oldName];
    //        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:newName];
    //
    //        NSFileManager *fileMgr = [NSFileManager defaultManager];
    //        [fileMgr moveItemAtPath:oldPath toPath:newPath error:nil];
    //
    //        _convRecord.msg_body = sendbody;
    //    }
    //    else if (_convRecord.msg_type == type_record || _convRecord.msg_type == type_video){
    //        oldName = _convRecord.file_name;
    //
    //        NSRange range=[oldName rangeOfString:@"." options:NSBackwardsSearch];
    //        NSString *ext = [oldName substringFromIndex:range.location + 1];
    //        newName = [NSString stringWithFormat:@"%@.%@",sendbody,ext];
    //
    //        oldPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:oldName];
    //        newPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:newName];
    //
    //        NSFileManager *fileMgr = [NSFileManager defaultManager];
    //        [fileMgr moveItemAtPath:oldPath toPath:newPath error:nil];
    //
    //        _convRecord.msg_body = sendbody;
    //    }
    //
    //    NSString *fileName = nil;
    //    if(msgType == type_file){
    //        fileName = oldName;
    //    }
    //    else if (msgType == type_pic || msgType == type_record || msgType == type_video){
    //        fileName = newName;
    //        _convRecord.file_name = newName;
    //    }
    //
    //    if(self.talkType == massType){
    //        [massDAO updateConvRecord:msgId andMSG:sendbody andFileName:fileName andMsgType:msgType];
    //    }
    //    else{
    //        [_ecloud updateConvRecord:msgId andMSG:sendbody andFileName:fileName andNewTime:0 andConvId:nil andMsgType:msgType];
    //    }
    //
    //    _convRecord.send_flag = sending;
    //
    //    [self sendMessage:msgType message:sendbody filesize:_convRecord.file_size.intValue filename:fileName andOldMsgId:msgId];
    //
    //    if(_index >= 0){
    //        [self reloadRow:_index+1];
    //    }
}

-(void)uploadResumeFileFail:(ASIHTTPRequest *)request{
    NSDictionary *userdic=[request userInfo];
    NSString *msgId=[userdic objectForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    if(_index < 0){
        //用户已经切换到了别的会话，此时应该修改数据库，记录上传失败的状态
        [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
        return;
    }
    
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:_index];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    if(request.error.code == ASIRequestTimedOutErrorType){
        _convRecord.tryCount = _convRecord.tryCount + 1;
        if(_convRecord.tryCount < max_try_count){
            if (_convRecord.msg_type == type_file) {
                [self prepareUploadFileWithFileRecord:_convRecord];
            }
            return;
        }
    }
    
    _convRecord.tryCount = 0;
    
    [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
    
    _convRecord.send_flag = send_upload_fail;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    if (_convRecord.msg_type == type_file) {
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        //更新上传状态
        NSInteger uploadstate =  state_failure;
        [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:msgId withState:uploadstate];
    }
    
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    if (_convRecord.msg_type == type_file) {
        //文件下载失败,显示失败按钮
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    else{
        UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
        failBtn.hidden=NO;
    }
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
    //文件发送进度显示
    NSLog(@"bytes-------｜｜｜｜%lld",bytes);
    
    if (bytes) {
        NSString* response = [request responseString];
        NSDictionary *dic=[request userInfo];
        NSString *msgId = [dic valueForKey:@"MSG_ID"];
        NSString *token = [dic valueForKey:@"Token"];
        int currentIndex = [[dic valueForKey:@"Start_Index"] integerValue];
        
        
        NSString *upload_start_index = [NSString stringWithFormat:@"%d",currentIndex + (int)bytes];
        NSString *total_length = [dic valueForKey:@"Total_length"];
        NSDictionary *data_dic=[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"MSG_ID",upload_start_index,@"Start_Index",total_length,@"Total_length",token,@"Token",nil];
        [request setUserInfo:data_dic];
        
        //发送文件，显示进度条
        int _index = [self getArrayIndexByMsgId:[msgId intValue]];
        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
        
        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
        //    [talkSessionUtil displayProgressView:_progressView];
        
        float progress = [upload_start_index floatValue]/[total_length floatValue];
        
        [_progressView setProgress:progress animated:YES];
        
        NSLog(@"upload_start_index-------%@",upload_start_index);
        NSLog(@"total_length-------%@",total_length);
        NSLog(@"progress-------%f",progress);
    }
}

//update by shisp 因为视频也是按照文件发送的，所以视频文件上传成功后，也要响应的修改内存和数据库里的数据
//这个代码 没有使用到 但在 万达版本里 用到了
-(void)updateConvFileRecordWithOLdMSG:(NSString *)old_msg_body andMSG:(NSString*)msg_body andConvRecord:(ConvRecord *)_convRecord{
    //修改数据库里面的文件
    [_ecloud updateConvFileRecordWithOLdMSG:old_msg_body andMSG:msg_body andConvRecord:_convRecord];
    
    _convRecord.msg_body = msg_body;
    //    for (ConvRecord *_convRecord in self.convRecordArray) {
    //        if ([_convRecord.msg_body isEqualToString:old_msg_body] && _convRecord.msg_type == type_file) {
    //            _convRecord.msg_body = msg_body;
    //        }
    //    }
    [self.chatTableView reloadData];
}

- (void)updateConvFileRecordWithUrl:(NSString *)url{
    //修改内存标记
    for (ConvRecord *_convRecord in self.convRecordArray) {
        if (_convRecord.msg_type == type_file && [_convRecord.msg_body isEqualToString:url]) {
            [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        }
    }
    
    [self.chatTableView reloadData];
}

-(void)setConvRecordsHasExpiredWithUrl:(NSString *)url{
    //修改数据库标记
    [_ecloud setConvRecordsHasExpiredWithUrl:url];
    
    //修改内存标记
    for (ConvRecord *_convRecord in self.convRecordArray) {
        if (_convRecord.msg_type == type_file && [_convRecord.msg_body isEqualToString:url]) {
            _convRecord.send_flag = send_upload_nonexistent;
        }
    }
    
    [self.chatTableView reloadData];
}

/**
 下载系统推送的视频
 */
#ifdef _XINHUA_FLAG_
- (void)downloadNewsVideo:(int)msgId withCell:(UITableViewCell *)_cell
{
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
    if (_convRecord.isDownLoading || _convRecord.download_flag == state_download_success) {
        
        return;
    }
    _convRecord.isDownLoading = true;
    _convRecord.download_flag = state_downloading;
    
    
    NSURL *url = nil;
    if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VIDEO])
    {
        url = [NSURL URLWithString:_convRecord.systemMsgModel.urlStr];
    }
    else if ([_convRecord.systemMsgModel.msgType isEqualToString:TYPE_VOICE])
    {
        url = [NSURL URLWithString:_convRecord.systemMsgModel.msgBody];
    }
    
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    // 添加请求头
    [request addRequestHeader:@"netsense" value:@"netsense"];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,url]];
    [request setDelegate:self];
    
    //设置文件进度
    //    UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
    //    [talkSessionUtil displayProgressView:_progressView];
    //    [request setDownloadProgressDelegate:_progressView];
    [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    
    //设置保存路径
    NSString *pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getNewsVideoName:_convRecord]];
    [request setDownloadDestinationPath:pathStr];
    
    //设置文件缓存路径
    //    [request setTemporaryFileDownloadPath:@"tempPath"];
    
    [request setDidFinishSelector:@selector(downloadVideoComplete:)];
    [request setDidFailSelector:@selector(downloadVideoFail:)];
    [request setAllowResumeForFileDownloads:YES];
    
    //传参数，文件传输完成后，根据参数进行不同的处理
    //    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:msgId],@"MSG_ID",nil]];
    [request setTimeOutSeconds:[self getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    
    [request startAsynchronous];
    
    _convRecord.downloadRequest = request;
    [request release];
}
#endif

- (void)downloadVideoComplete:(ASIHTTPRequest *)request
{
    NSLog(@"adsfsuccess %@", request.responseString);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_chatTableView reloadData];
    });
}

- (void)downloadVideoFail:(ASIHTTPRequest *)request
{
    NSLog(@"asdfile %@", request.responseString);
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
            //            if ([self isTalkWithiRobot]){
            //                urlStr = _convRecord.robotModel.argsArray[0];
            //                pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.file_name]];
            //                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.png.zip",msgId,_convRecord.file_name]];
            //            }else{
            
            token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
            urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getNewPicDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
            pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.msg_body]];
            tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.png.zip",msgId,_convRecord.msg_body]];
            //            }
        }
            break;
        case type_video:
        case type_record:
        {
            //  [[RobotDAO getDatabase]isRobotUser:self.convId.intValue]
            //            if ([self isTalkWithiRobot]){
            //                urlStr = _convRecord.robotModel.argsArray[3];
            //            }else{
            
            NSRange range = [_convRecord.msg_body rangeOfString:@"_"];
            if(range.length > 0){
                token = [NSString stringWithFormat:@"%@",[_convRecord.msg_body substringToIndex:range.location]];
            }
            else{
                token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
            }
            urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
            //            }
            pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
            tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,_convRecord.file_name]];
        }
            break;
        case type_file:
        {
            // [[RobotDAO getDatabase]isRobotUser:self.convId.intValue]
            //            if ([self isTalkWithiRobot]){
            //                urlStr = _convRecord.robotModel.argsArray[0];
            //                pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_convRecord.file_name];
            //                tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[_convRecord.file_name stringByDeletingPathExtension]]];
            //            }else{
            
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
            //            }
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
    // 添加请求头
    [request addRequestHeader:@"netsense" value:@"netsense"];
    
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
                [self performSelectorOnMainThread:@selector(openRecentContacts) withObject:nil waitUntilDone:YES];
                //                [self openRecentContacts];
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


-(void)onClickFileToStop:(UITapGestureRecognizer*)gesture
{
    CGPoint p = [gesture locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
    NSLog(@"msgId------%@",msgId);
    
    if (_convRecord.isRobotFileMsg) {
        
        if (_convRecord.isDownLoading && _convRecord.downloadRequest) {
            [[RobotFileUtil getUtil]removeRecordFromDownloadList:_convRecord];
            _convRecord.download_flag = state_download_unknow;
            _convRecord.isDownLoading = false;
            [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
            
            UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
            [spinner stopAnimating];
        }else{
            [[RobotDisplayUtil getUtil]onClickRobotFile:_convRecord];
        }
        return;
    }
    
    if (_convRecord.msg_flag == send_msg){
        //发送的消息
        switch (_convRecord.send_flag) {
            case send_uploading:
            {
                //发现正在上传，则暂停
                [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromUploadList:_convRecord.msgId];
                _convRecord.send_flag = send_upload_stop;
                
                [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_stop];
                UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
                [spinner stopAnimating];
            }
                break;
            case send_upload_fail:
            {
                //发现失败，则再次上传
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
                break;
            case send_upload_stop:
            {
                //发现暂停，则开始上传
                UIActivityIndicatorView *activity=( UIActivityIndicatorView *)[cell.contentView viewWithTag:status_spinner_tag];
                [activity startAnimating];
                if (maxSendFileSize == 20) {
                    [self uploadFile:_convRecord];
                }
                else{// if(maxSendFileSize == 21){
                    [self  prepareUploadFileWithFileRecord:_convRecord];
                }
                
                _convRecord.send_flag = send_uploading;
            }
                break;
            default:
                break;
        }
    }
    else{
        
        switch (_convRecord.download_flag) {
            case state_download_success:
            {
                //文件下载成功
            }
                break;
            case state_downloading:
            {
                //如果有文件在下载，那么从文件列表中移除，并且取消下载
                [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_convRecord.msgId];
                int uploadstate = state_download_stop;
                _convRecord.download_flag = uploadstate;
                [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:msgId withState:uploadstate];
                
                UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
                [spinner stopAnimating];
            }
                break;
            case state_download_failure:
            {
                //下载失败,重新发送
                //                [self downloadResumeFile:_convRecord.msgId andCell:nil];
                int netType = [ApplicationManager getManager].netType;
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
                else{
                    if (maxSendFileSize == 20) {
                        [self downloadFile:_convRecord.msgId andCell:nil];
                    }
                    else{// if(maxSendFileSize == 21){
                        [self downloadResumeFile:_convRecord.msgId andCell:nil];
                    }
                }
            }
                break;
            case state_download_stop:
            {
                //当前为暂停状态，则开始下载
                //                [self downloadResumeFile:_convRecord.msgId andCell:nil];
                int netType = [ApplicationManager getManager].netType;
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
                else{
                    if (maxSendFileSize == 20) {
                        [self downloadFile:_convRecord.msgId andCell:nil];
                    }
                    else{// if(maxSendFileSize == 21){
                        [self downloadResumeFile:_convRecord.msgId andCell:nil];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    
    [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
}

-(void)onClickFile:(UITapGestureRecognizer*)gesture
{
    CGPoint p = [gesture locationInView:self.chatTableView];
    NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:[self getIndexByIndexPath:indexPath]];
    
    
    //    if (_convRecord.cloudFileModel && !isEditingConvRecord) {
    
    if (isEditingConvRecord) {
        NSLog(@"%s 编辑状态，不打开文件 选中或者取消选中记录 ",__FUNCTION__);
        _convRecord.isSelect = !_convRecord.isSelect;
        [self.chatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        return;
    }
    if (_convRecord.isRobotFileMsg) {
        [[RobotDisplayUtil getUtil]onClickRobotFile:_convRecord];
        return;
    }
    
    if (_convRecord.cloudFileModel) {
        
        openWebViewController *openweb=[[openWebViewController alloc]init];
        NSString *urlStr = [NSString stringWithFormat:@"%@&custom_token=%@",_convRecord.cloudFileModel.fileUrl,[UserDefaults getLoginToken]];
        openweb.urlstr = urlStr;
        [self.navigationController pushViewController:openweb animated:YES];
        [openweb release];
        return;
    }
    if(_convRecord.isFileExists)
    {
        [talkSessionUtil sendReadNotice:_convRecord];
        
        if ([StringUtil isAudioFile:[_convRecord.file_name pathExtension]])
        {
            NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
            if ([eCloudConfig getConfig].needFixSecurityGap)
            {
                NSString *tmpDir = NSTemporaryDirectory();
                NSString *newPath = [tmpDir stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:newPath])
                {
                    NSData *data = [EncryptFileManege getDataWithPath:[[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]]];
                    
                    [data writeToFile:newPath atomically:YES];
                }
                filePath = [NSString stringWithString:newPath];
            }
            
            [[RobotDisplayUtil getUtil]playMusic:_convRecord.file_name andFilePath:filePath andConvRecord:_convRecord andCurVC:self];
            
        }
        else
        {
            previewFileIndex = indexPath.row - 1;
            //                ios10下查看文件内容时，左边导航栏按钮无法隐藏 add by shisp
            self.title = nil;
            
            [[RobotDisplayUtil getUtil]openNormalFile:self andCurVC:self];
        }
    }
    else
    {
        if(_convRecord.isDownLoading || _convRecord.download_flag == state_download_nonexistent || _convRecord.send_flag == send_upload_nonexistent){
            return;
        }
        
        int netType = [ApplicationManager getManager].netType;
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
            //			[self downloadFile:_convRecord.msgId andCell:nil];
            //            [self downloadResumeFile:_convRecord.msgId andCell:nil];
            if (maxSendFileSize == 20) {
                [self downloadFile:_convRecord.msgId andCell:nil];
            }
            else{// if(maxSendFileSize == 21){
                [self downloadResumeFile:_convRecord.msgId andCell:nil];
            }
        }
    }
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
#pragma mark ========================================================

#pragma mark =========转发一条聊天记录到其他的会话===========
//打开最近的联系人，用来转发
- (void)openRecentContacts
{
    ForwardingRecentViewController *forwarding=[[ForwardingRecentViewController alloc]init];
    forwarding.forwardingDelegate = self;
    forwarding.fromType = transfer_from_talksession;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:forwarding];
    [forwarding release];
    nav.navigationBar.tintColor=[UIColor blackColor];
    if (isEditingConvRecord) {
        NSArray *selectedRecords = [self getSelectedRecords];
        forwarding.forwardRecordsArray = selectedRecords;
    }else{
        forwarding.forwardRecord = self.forwardRecord;
        forwarding.forwardRecordsArray = [NSArray arrayWithObject:self.forwardRecord];
    }
    [UIAdapterUtil presentVC:nav];
    //    [self presentModalViewController:nav animated:YES];
    [nav release];
    [self cancelEditConvRecord];
}

//保存转发的记录
- (BOOL)saveForwardMsg
{
    ConvRecord *forwardRecord = self.forwardRecord;
    
    if (!self.convId) {
        self.convId = self.forwardRecord.conv_id;
        self.talkType = self.forwardRecord.conv_type;
    }
    
    NSString *nowTime = [_conn getSCurrentTime];
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
    
    [mDic setValue:forwardRecord.conv_id forKey:@"conv_id"];
    
    [mDic setValue:_conn.userId forKey:@"emp_id"];
    
    [mDic setValue:[StringUtil getStringValue:forwardRecord.msg_type] forKey:@"msg_type"];
    
    [mDic setValue:nowTime forKey:@"msg_time"];
    
    [mDic setValue:@"0" forKey:@"read_flag"];
    
    [mDic setValue:[StringUtil getStringValue:send_msg] forKey:@"msg_flag"];
    
    if (forwardRecord.msg_type == type_text){
        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        [mDic setValue:[StringUtil getStringValue:sending] forKey:@"send_flag"];
    }
    else if (forwardRecord.msg_type == type_file || forwardRecord.msg_type == type_video){
        [mDic setValue:[StringUtil getStringValue:send_upload_waiting] forKey:@"send_flag"];
    }
    else if (forwardRecord.msg_type == type_imgtxt){
        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        [mDic setValue:[StringUtil getStringValue:sending] forKey:@"send_flag"];
    }
    else{
        [mDic setValue:[StringUtil getStringValue:send_uploading] forKey:@"send_flag"];
    }
    
    [mDic setValue:[StringUtil getStringValue:conv_status_normal] forKey:@"receipt_msg_flag"];
    
    if (forwardRecord.msg_type == type_pic){
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        NSString *currenttimeStr=[StringUtil currentTime];
        NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
        //存入本地
        NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
        
        NSData *data = [EncryptFileManege getDataWithPath:[talkSessionUtil getBigPicPath:forwardRecord]];
        //        NSData *data = [NSData dataWithContentsOfFile:[talkSessionUtil getBigPicPath:forwardRecord]];
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
            
            NSString *file_size = [NSString stringWithFormat:@"%i",[data length]];
            [mDic setValue:file_size forKey:@"file_size"];
        }
        [pool release];
        
        //
        //        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        //        [mDic setValue:forwardRecord.file_name forKey:@"file_name"];
        //        [mDic setValue:forwardRecord.file_size forKey:@"file_size"];
    }
    else if (forwardRecord.msg_type == type_long_msg)
    {
        /*
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
         */
        //
        //        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        //        [mDic setValue:forwardRecord.file_name forKey:@"file_name"];
        //        [mDic setValue:forwardRecord.file_size forKey:@"file_size"];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        NSString *currenttimeStr=[StringUtil currentTime];
        NSString *pictempname = [NSString stringWithFormat:@"%@.txt",currenttimeStr];
        //存入本地
        NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
        //        NSData *data = [NSData dataWithContentsOfFile:[talkSessionUtil getLongMsgPath:forwardRecord]];
        NSData *data = [EncryptFileManege getDataWithPath:[talkSessionUtil getLongMsgPath:forwardRecord]];
        BOOL success= [data writeToFile:picpath atomically:YES];
        if (!success)
        {
            // 复制文件失败
            [pool release];
            return NO;
        }
        else
        {
            [mDic setValue:currenttimeStr forKey:@"msg_body"];
            
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //            NSString *message = [NSString stringWithContentsOfFile:[talkSessionUtil getLongMsgPath:forwardRecord] encoding:NSUTF8StringEncoding error:nil];
            NSString *messageHead = [message substringToIndex:16];
            [mDic setValue:messageHead forKey:@"file_name"];
            
            NSString *file_size = [NSString stringWithFormat:@"%i",[data length]];
            [mDic setValue:file_size forKey:@"file_size"];
        }
        [pool release];
    }
    else if (forwardRecord.msg_type == type_file || forwardRecord.msg_type == type_video)
    {
        NSString *token = [self getTokenFromString:forwardRecord.msg_body];
        NSString *msg_body = [NSString stringWithFormat:@"%@",token];
        [mDic setValue:msg_body forKey:@"msg_body"];
        
        [mDic setValue:forwardRecord.file_name forKey:@"file_name"];
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

#pragma mark =============================转发相关=============================

#pragma mark - 发送转发的消息
- (void)sendForwardMsg
{
    ConvRecord *forwardRecord = self.forwardRecord;
    if (forwardRecord.msg_type == type_text || forwardRecord.msg_type == type_imgtxt)
    {
        [_conn sendMsg:forwardRecord.conv_id andConvType:forwardRecord.conv_type andMsgType:type_text andMsg:forwardRecord.msg_body andMsgId:forwardRecord.origin_msg_id andTime:forwardRecord.msg_time.intValue andReceiptMsgFlag:conv_status_normal];
    }
    else
    {
        
        //        [self uploadFile:forwardRecord];
        if (forwardRecord.msg_type == type_file) {
            //            [self prepareUploadFileWithFileRecord:forwardRecord];
            [self sendForwardFileMsg:forwardRecord];
        }
        else if (forwardRecord.msg_type == type_pic || forwardRecord.msg_type == type_record || forwardRecord.msg_type == type_long_msg || forwardRecord.msg_type == type_video){
            if (maxSendFileSize == 20) {
                [self uploadFile:forwardRecord];
            }
            else{
                [self prepareUploadFileWithFileRecord:forwardRecord];
            }
        }
        else{
            [self uploadFile:forwardRecord];
        }
    }
}

- (void)refreshTitle
{
    //    update by shsip 换成新的方式更新title
    [self initTitle];
    //    if (self.talkType == mutiableType)
    //    {
    //        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
    //        self.title=[NSString stringWithFormat:@"%@(%d人)",self.titleStr,all_num];
    //    }
}

#pragma mark - 文件助手批量转发
- (BOOL)saveFileAssistantForwardMsgsArray:(NSArray *)forwardRecordsArray{
    if (!self.forwardRecordsArray) {
        self.forwardRecordsArray = [NSMutableArray array];
    }
    [self.forwardRecordsArray removeAllObjects];
    
    for (ConvRecord *_convRecord in forwardRecordsArray) {
        //保存转发的文件消息
        [self saveMsgWithConvRecord:_convRecord toArray:self.forwardRecordsArray];
    }
    
    return YES;
}

- (void)saveMsgWithConvRecord:(ConvRecord *)_convRecord toArray:(NSArray *)sendMsgArray{
    NSString *nowTime = [_conn getSCurrentTime];
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    [mDic setValue:_convRecord.conv_id forKey:@"conv_id"];
    [mDic setValue:_conn.userId forKey:@"emp_id"];
    [mDic setValue:[StringUtil getStringValue:_convRecord.msg_type] forKey:@"msg_type"];
    [mDic setValue:nowTime forKey:@"msg_time"];
    [mDic setValue:@"0" forKey:@"read_flag"];
    [mDic setValue:[StringUtil getStringValue:send_msg] forKey:@"msg_flag"];
    [mDic setValue:[StringUtil getStringValue:send_upload_waiting] forKey:@"send_flag"];
    if (_convRecord.receiptMsgFlag) {
        [mDic setValue:[StringUtil getStringValue:_convRecord.receiptMsgFlag] forKey:@"receipt_msg_flag"];
    }else{
        [mDic setValue:[StringUtil getStringValue:conv_status_normal] forKey:@"receipt_msg_flag"];
    }
    //    NSString *currenttimeStr=[NSString stringWithFormat:@"%@_",[StringUtil currentTime]];
    //    [mDic setValue:currenttimeStr forKey:@"msg_body"];
    
    NSString *token = [self getTokenFromString:_convRecord.msg_body];
    NSString *msg_body = [NSString stringWithFormat:@"%@",token];
    [mDic setValue:msg_body forKey:@"msg_body"];
    
    //    [mDic setValue:_convRecord.msg_body forKey:@"msg_body"];
    [mDic setValue:_convRecord.file_name forKey:@"file_name"];
    
    
    //    NSString *token = [self getTokenFromString:_convRecord.msg_body];
    //    NSString *msg_body = [NSString stringWithFormat:@"%@_",token];
    //    [mDic setValue:msg_body forKey:@"msg_body"];
    //    _convRecord.msg_body = msg_body;
    //
    //    NSString *fileName = [talkSessionUtil getFileName:_convRecord];
    //    [mDic setValue:fileName forKey:@"file_name"];
    
    
    [mDic setValue:_convRecord.file_size forKey:@"file_size"];
    
    NSDictionary *dic = [_ecloud addConvRecord:[NSArray arrayWithObject:mDic]];
    [mDic release];
    
    if(!dic){
        NSLog(@"保存失败");
    }
    
    NSString *msgId = [dic valueForKey:@"msg_id"];
    ConvRecord *convRecord = [self getConvRecordByMsgId:msgId];
    
    [sendMsgArray addObject:convRecord];
}

- (void)sendFileAssistantForwardMsgs{
    file_index=0;
    manyFileTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendFileAssistantForwardMsg) userInfo:nil repeats:YES];
}

- (void)sendFileAssistantForwardMsg{
    if (file_index== [self.forwardRecordsArray count]) {
        [manyFileTimer invalidate];
        manyFileTimer=nil;
        return;
    }
    
    ConvRecord *_convRecord = [self.forwardRecordsArray objectAtIndex:file_index];
    [self sendForwardFileMsg:_convRecord];
    file_index++;
}

- (void)sendForwardFileMsg:(ConvRecord *)_convRecord{
    /*
     服务器文件有效性验证客户端处理：
     1.本件不存在地文，服务器返回200        转发token
     2.本地文件不存在，服务器返回404        本地标记过期
     3.本地文件存在，服务器返回200          转发token
     4.本地文件存在，服务器返回404          重新上传文件
     5.本地文件存在或者不存在，服务器返回其他代码  本地标记为转发失败
     */
    
    //转发的时候，先判断服务器文件是否存在，如果存在，则直接转发文件token，否则 提示用户
    dispatch_queue_t queue;
    queue = dispatch_queue_create("get status code", NULL);
    dispatch_async(queue, ^{
        NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
        NSString *token = [self getTokenFromString:_convRecord.msg_body];
        //    NSString *userid = _conn.userId;
        
        NSString *qStr;
        NSString *urlStr;
        
        qStr = [StringUtil getResumeDownloadAddStr];
        urlStr  = [NSString stringWithFormat:@"%@?token=%@&act=q%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,qStr];
        
        int statusCode  = [FileAssistantConn getStatusCodeOfValidatingFileWithURLString:urlStr];
        
        if (statusCode == 400){// && [_convRecord.msg_body isEqualToString:@"FromOtherApp"]) {
            statusCode = 404;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (200 == statusCode) {
                int msgType = _convRecord.msg_type;
                NSString *sendbody = token;
                NSString *fileName = _convRecord.file_name;
                
                [_ecloud updateConvRecord:msgId andMSG:sendbody andFileName:fileName andNewTime:0 andConvId:nil andMsgType:msgType];
                _convRecord.send_flag = sending;
                
                int _index = [self getArrayIndexByMsgId:msgId.intValue];
                if(_index >= 0){
                    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
                    UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
                    if ([cell isKindOfClass:[VideoMsgCell class]]) {
                        _progressView = (UIProgressView*)[cell.contentView viewWithTag:video_progress_tag];
                    }
                    [talkSessionUtil displayProgressView:_progressView];
                    [_progressView setProgress:1.0 animated:YES];
                    
                    [self reloadRow:_index+1];
                }
                
                [self sendMessage:msgType message:sendbody filesize:_convRecord.file_size.intValue filename:fileName andOldMsgId:msgId];
                
            }
            else if(404 == statusCode){
                NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
                
                [LogUtil debug:[NSString stringWithFormat:@"%s 要上传的文件路径是%@",__FUNCTION__,filePath]];
                
                if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                    //服务器文件过期，本地存在文件，则需要从本地上传文件
                    if (maxSendFileSize == 20) {
                        [self uploadFile:_convRecord];
                    }
                    else{// if (maxSendFileSize == 21){
                        [self prepareUploadFileWithFileRecord:_convRecord];
                    }
                }
                else{
                    [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_nonexistent];
                    _convRecord.send_flag = send_upload_nonexistent;
                    
                    //该文件对应的所有消息记录设置为过期
                    [self setConvRecordsHasExpiredWithUrl:_convRecord.msg_body];
                    
                    int _index = [self getArrayIndexByMsgId:msgId.intValue];
                    
                    if(_index >= 0){
                        UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
                        UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
                        [spinner stopAnimating];
                        
                        //文件下载失败,显示失败按钮
                        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
                        
                        [FileAssistantUtil showFileNonexistViewInView:self.view inTalkSession:YES];
                    }
                }
            }
            else{
                //其他原因
                [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
                _convRecord.send_flag = send_upload_fail;
                
                int _index = [self getArrayIndexByMsgId:msgId.intValue];
                
                if(_index >= 0){
                    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
                    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
                    [spinner stopAnimating];
                    
                    //文件下载失败,显示失败按钮
                    [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
                }
            }
        });
    });
    dispatch_release(queue);
}

- (NSString *)getTokenFromString:(NSString *)_msgbody{
    NSString *token;
    NSRange _range = [_msgbody rangeOfString:@"_" options:NSBackwardsSearch];
    if(_range.length > 0){
        //        token = [NSString stringWithFormat:@"%@",[_msgbody substringToIndex:_range.location]];
        token = [NSString stringWithFormat:@"%@",[_msgbody stringByReplacingOccurrencesOfString:@"_" withString:@""]];
    }
    else{
        token = _msgbody;
    }
    return token;
}

#pragma mark ==========================================================

#pragma mark 加载查询结果，位置停在相应的位置上，并且可以查看前后的记录
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
    
    self.convRecordArray = [[NSMutableArray alloc]initWithArray:thisLoadArray];
    
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
                if ([model.msgType isEqualToString:TYPE_NEWS])
                {
                    static NSString *newImgTxtCellID = @"NEWSCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:newImgTxtCellID];
                    if (cell == nil) {
                        cell = [[[NewsCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newImgTxtCellID]autorelease];
                        [[RobotDisplayUtil getUtil] addImgTxtViewGesture:cell];
                        [self addCommonGesture:cell];
                    }
                }
                else if ([model.msgType isEqualToString:TYPE_VIDEO])
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
                else if ([model.msgType isEqualToString:TYPE_PIC])
                {
                    cell = [[RobotDisplayUtil getUtil]getPicMsgCell];
                }
                else if ([model.msgType isEqualToString:TYPE_VOICE])
                {
                    static NSString *audioMsgCellID = @"xinhuaAudioMsgCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:audioMsgCellID];
                    if (cell == nil) {
                        cell = [[[AudioMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:audioMsgCellID]autorelease];
                        //                增加录音消息点击事件
                        [self addPlayAudioToCell:cell];
                        [self addCommonGesture:cell];
                    }
                }
                else
                {
                    cell = [self getNormalTextCell:tableView andRecord:_convRecord];
                }
            }
#endif
            //            WXReplyToOneMsgCellTableViewCellArc
            else if (_convRecord.replyOneMsgModel)
            {
                static NSString *replyToCellID = @"replyToCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:replyToCellID];
                if (cell == nil) {
                    cell = [[[WXReplyToOneMsgCellTableViewCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                    
                    [[WXReplyOneMsgUtil getUtil] addJumpToViewGesture:cell];
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

                if (cell == nil) {

                    LGNewsCellARC *NewCell = [[[LGNewsCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                    
                    //[NewCell configCellWithDataModel:_convRecord.newsModel];
                    cell = NewCell;
                    //点击头像
                    [self addCommonGesture:cell];
                    [self addOpenNews:cell];
                    
                }
            }
#endif
//            else if (_convRecord.replyOneMsgModel){
//                static NSString *replyToOneMsgCellID = @"replyToOneMsgCellID";
//                cell = [tableView dequeueReusableCellWithIdentifier:replyToOneMsgCellID];
//                if (cell == nil) {
//                    cell = [[[WXReplyToOneMsgCellTableViewCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyToOneMsgCellID]autorelease];
//                    //                    [[RobotDisplayUtil getUtil] addImgTxtViewGesture:cell];
//                    [self addCommonGesture:cell];
//                }
//            }
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
                        cell = [[[FaceTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
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
            cell = [[RobotDisplayUtil getUtil]getPicMsgCell];
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
            cell = [[RobotDisplayUtil getUtil]getNewFileMsgCell];
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
        case type_imgtxt:
        case type_wiki:
        {
            if (_convRecord.isLinkText) {
                //                static NSString *linkTextCellID = @"linkTextCellID";
                //                cell = [tableView dequeueReusableCellWithIdentifier:linkTextCellID];
                //                if (cell == nil) {
                //                    cell = [[[LinkTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:linkTextCellID]autorelease];
                //                    [self addCommonGesture:cell];
                //                }
                static NSString *imgtxtCellId = @"imgtxtSubcellId";
                cell = [tableView dequeueReusableCellWithIdentifier:imgtxtCellId];
                if (cell == nil) {
                    cell = [[[ImgtxtMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imgtxtCellId]autorelease];
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
    
    //    LocationMsgCell *cell = [_chatTableView cellForRowAtIndexPath:indexPath];
    //    NSDictionary *dic = cell.locationDic[@"location"];
    //
    //    receiveMapViewController *mapViewCtl = [[receiveMapViewController alloc] init];
    //    mapViewCtl.latitude = [dic[@"latitude"] floatValue];
    //    mapViewCtl.longitude = [dic[@"longitude"] floatValue];
    //    NSString *address = dic[@"address"];
    //    NSArray *addressArr = [address componentsSeparatedByString:@"-"];
    //    mapViewCtl.buildingName = addressArr[0];
    //    mapViewCtl.address = addressArr[1];
    //
    //    [self.navigationController pushViewController:mapViewCtl animated:YES];
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

+ (void)showCanNotAccessPhotos
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
        //区分文件类型消息和其他类型消息
        if (maxSendFileSize == 20) {
            [self downloadFile:_convRecord.msgId andCell:nil];
        }
        else{// if(maxSendFileSize == 21){
            //            if (_convRecord.msg_type == type_file) {
            [self downloadResumeFile:_convRecord.msgId andCell:nil];
            //            }
            //            else{
            //                [self downloadFile:_convRecord.msgId andCell:nil];
            //            }
        }
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

//不再接收会话通知
- (void)removeConvNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_USER_INFO_FROM_HX_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    self.isHaveBeingHere=NO;
}

#pragma mark =========提醒用户修改群名相关==========

//初始化按钮
- (void)initModifyGroupNameButton
{
    return;
    float width = self.view.frame.size.width;
    float height = [UIAdapterUtil isGOMEApp] ? 46.0 : 44.0;
    
    modifyGroupNameButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    modifyGroupNameButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    邹林杨提供的颜色值 #f3f5f2
    UIColor *bgColor = [UIColor colorWithRed:0xf3/255.0 green:0xf5/255.0 blue:0xf2/255.0 alpha:1];
    modifyGroupNameButton.backgroundColor = [talkSessionUtil getBgColorOfModifyGroupNameButton];// bgColor;
    [modifyGroupNameButton addTarget:self action:@selector(openModifyGroupNameVC) forControlEvents:UIControlEventTouchUpInside];
    [modifyGroupNameButton setTitle:[StringUtil getLocalizableString:@"modifyGroupName_modify_groupName"] forState:UIControlStateNormal];
    modifyGroupNameButton.titleLabel.font=[UIFont systemFontOfSize: [UIAdapterUtil isGOMEApp] ? 17 : 14];
    UIColor *nameColor = [UIAdapterUtil isGOMEApp] ? GOME_BLUE_COLOR : [UIColor darkGrayColor];
    [modifyGroupNameButton setTitleColor:nameColor forState:UIControlStateNormal];
    
    
    [self.view addSubview:modifyGroupNameButton];
    [modifyGroupNameButton release];
    
    //    增加一个箭头图片
    NSString *imagePath = [UIAdapterUtil isGOMEApp] ? [StringUtil getResPath:@"blue_left_arrow" andType:@"png"] : [StringUtil getResPath:@"left_arrow" andType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *leftArrow = [[UIImageView alloc]initWithImage:image];
    leftArrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    CGRect _frame = CGRectMake(width - 20 - image.size.width, (height - image.size.height)/2.0, image.size.width, image.size.height);
    leftArrow.frame = _frame;
    [modifyGroupNameButton addSubview:leftArrow];
    [leftArrow release];
}

//点击按钮打开修改群组名称界面
- (void)openModifyGroupNameVC
{
    if (isEditingConvRecord) {
        return;
    }
    //    return;
    modifyGroupNameViewController *modifyGroup=[[modifyGroupNameViewController alloc]init];
    modifyGroup.convId = self.convId;
    modifyGroup.oldGroupName = self.titleStr;
    modifyGroup.last_msg_id=self.last_msg_id;
    [self.navigationController pushViewController:modifyGroup animated:YES];
    [modifyGroup release];
}

//是否显示修改群组名称按钮
- (void)displayModifyGroupNameButton
{
    //    return;
    if (receiptMsgFlagButton.hidden)
    {
        [self showModifyGroupNameButton];
    }
}
// update by shisp 不需要接收此通知 否则就重复了
//-(void)processNewConvNotification:(NSNotification *)notification
//{
////    return;
//    eCloudNotification *_notification = [notification object];
//    if(_notification != nil)
//    {
//        int cmdId = _notification.cmdId;
//        switch (cmdId) {
//            case update_conv_title:
//            {
//                NSDictionary *dic = _notification.info;
//                NSString *convId = [dic valueForKey:@"conv_id"];
//                NSString *convTitle = [dic valueForKey:@"conv_title"];
//                if ([convId isEqualToString:self.convId])
//                {
//                    self.titleStr = convTitle;
//                    [self refreshTitle];
//                }
//            }
//                break;
//            default:
//                break;
//        }
//    }
//}

- (void)showModifyGroupNameButton
{
    //    return;
    modifyGroupNameButton.hidden = YES;
    //    如果是群聊，并且需要显示修改群组名称按钮
    if (self.talkType == mutiableType && [UserDefaults isGroupNameModify:self.convId]) {
        modifyGroupNameButton.hidden = NO;
        [modifyGroupNameButton setTitle:[StringUtil getLocalizableString:@"modifyGroupName_modify_groupName"] forState:UIControlStateNormal];
    }
}

- (void)hideModifyGroupNameButton
{
    //    return;
    if (!modifyGroupNameButton.hidden)
    {
        modifyGroupNameButton.hidden = YES;
    }
}

//增加一个方法 如果是回执状态，则修改为正常状态，如果显示了修改群组名称，则取消显示群组名称
- (void)cancelSomeStatus
{
    if (self.talkType == mutiableType)
    {
        //        取消 显示群组名称修改 按钮
        if ([UserDefaults isGroupNameModify:self.convId]) {
            [UserDefaults removeModifyGroupNameFlag:self.convId];
        }
    }
    [self cancelReplyMessage];
}

- (void)setConvId:(NSString *)convId
{
    if (_convId) {
        if (![_convId isEqualToString:convId]) {
            [self cancelSomeStatus];
            [_convId release];
            _convId = [convId retain];
        }
    }
    else
    {
        _convId = [convId retain];
    }
}

//获取下拉加载历史记录用到的indicator
- (UIActivityIndicatorView *)getIndicatorView
{
    return loadingIndic;
}
#pragma mark - 公众号的菜单
- (void)loadMenuView{
    // 菜单按钮
    if (!muneButton) {
        muneButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 5+2, 39, 30)];
        muneButton.tag=31;
        muneButton.imageView.contentMode = UIViewContentModeCenter;
        [muneButton setImage:[StringUtil getImageByResName:@"Mode_texttolist.png"] forState:UIControlStateNormal];
        [muneButton setImage:[StringUtil getImageByResName:@"Mode_listtotext.png"] forState:UIControlStateSelected];
        [muneButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
        muneButton.selected = NO;
        [subfooterView addSubview:muneButton];
        [muneButton release];
        
        // 左部菜单右侧加一条竖线
        UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 0, 0.5, 50)];
        lineImageView.backgroundColor = [UIColor colorWithRed:202/255.0f green:202/255.0f blue:202/255.0f alpha:1.0f];
        lineImageView.tag = 4000;
        [subfooterView addSubview:lineImageView];
        [lineImageView release];
    }
    
    // 菜单服务
    if (!menuView) {
        menuView = [[IM_MenuView alloc]init];
        menuView.frame = CGRectMake(40, 0, self.view.frame.size.width-40, 50);
        
        menuView.backgroundColor = [UIColor clearColor];
        menuView.displayView = self.view;
        
        menuView.delegate = self;
        menuView.hidden = YES;
        menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [subfooterView addSubview:menuView];
        
        [menuView release];
    }
    
    if ([self isTalkWithiRobot] && self.robotMenuArray.count > 0) {
        menuView.delegate = [RobotDisplayUtil getUtil];
        [[RobotDisplayUtil getUtil] setTopMenuForRobot:menuView];
        record_x = 45;
        messageParsex = 40;
    }else{
        menuView.delegate = self;
        // 从数据库获取菜单数据
        ServiceMenuModel *menuList = [[PublicServiceDAO getDatabase] getPSMenuListByPlatformid:serviceModel.serviceId];
        if (menuList)
        {
            NSArray *menuArrays = menuList.button;
            if (!self.firstMenuArray)
            {
                self.firstMenuArray = [NSMutableArray array];
            }
            else
            {
                [self.firstMenuArray removeAllObjects];
            }
            if (!self.subMenuArray)
            {
                self.subMenuArray = [NSMutableArray array];
            }
            else
            {
                [self.subMenuArray removeAllObjects];
            }
            // 解析一级菜单
            for (int i = 0;i < menuArrays.count;i++) {
                NSDictionary *firstDictionary = menuArrays[i];
                // 处理子菜单
                if (firstDictionary[@"sub_button"] != nil)
                {
                    NSMutableArray *tmpArr = [[NSMutableArray alloc]init];
                    NSMutableArray *subMenuArrays = firstDictionary[@"sub_button"];
                    for (int j = 0;j < subMenuArrays.count;j++) {
                        NSDictionary *subDictionary = subMenuArrays[j];
                        
                        [tmpArr addObject:subDictionary];
                    }
                    
                    [self.subMenuArray addObject:tmpArr];
                }
                else
                {
                    [self.subMenuArray addObject:[NSArray array]];
                }
                // 有无子菜单都要添加
                [self.firstMenuArray addObject:firstDictionary];
            }
            
        }
        
        
        NSMutableArray *firstMenuNameArray = [NSMutableArray array];
        for (NSDictionary *firstMenuDic in self.firstMenuArray) {
            [firstMenuNameArray addObject:firstMenuDic[@"name"]];
        }
        
        [menuView setBottomItems:firstMenuNameArray];
        // 解析获取二级子菜单名称集合
        if (self.allUpDatas) {
            [self.allUpDatas removeAllObjects];
        }else{
            self.allUpDatas = [NSMutableArray array];
        }
        for (int i = 0; i < self.subMenuArray.count; i++) {
            NSArray *subMenuArr = self.subMenuArray[i];
            if (subMenuArr.count == 0) {
                // 若当前第一级菜单不存在子菜单，就放一个空数组
                [self.allUpDatas addObject:[NSArray array]];
                // 将显示的一级菜单左部图片隐藏
                UIButton *bootomBtn = (UIButton *)[menuView viewWithTag:5678+i];
                [bootomBtn setImage:nil forState:UIControlStateNormal];
                continue;
            }
            NSMutableArray *subMenuNameArray = [NSMutableArray array];
            for (NSDictionary *subMenuDic in subMenuArr) {
                [subMenuNameArray addObject:subMenuDic[@"name"]];
            }
            [self.allUpDatas addObject:subMenuNameArray];
        }
        //        self.allUpDatas = subMenusNameArray;
        record_x = 45;
        messageParsex = 40;
    }
}
#pragma mark  - MenuView的代理
#pragma mark - delegate methods
- (void)clickOrKeyAction:(NSInteger)ksel{
    NSDictionary *selectIndexFromFirstMenu = self.firstMenuArray[ksel];
    [self menuActionBySelected:selectIndexFromFirstMenu];
}
- (NSArray *)upMenuItemsAtBottomIndex:(NSInteger)index {
    if (index >= self.allUpDatas.count) {
        return nil;
    }
    NSInteger indexss = menuView.selectedBottomIndex;
    tableBackGroudButtonForHiddenSubMenu.hidden = NO;
    return self.allUpDatas[index];
}

- (void)selectedUpMenuItemAtIndex:(NSInteger)upItemIndex bottomIndex:(NSInteger)bottomIndex {
    NSLog(@"bottom index is : %ld, up index is : %ld", (long)bottomIndex, (long)upItemIndex);
    
    NSDictionary *selectIndexFromSubMenuDic = self.subMenuArray[bottomIndex][upItemIndex];
    [self menuActionBySelected:selectIndexFromSubMenuDic];
}
#pragma mark - 事件处理
- (void)menuActionBySelected:(NSDictionary *)selectedMenuDic{
    NSLog(@"selectedMenuDic = %@",selectedMenuDic);
    NSString *type = [selectedMenuDic objectForKey:@"type"];
    if ([type isEqualToString:@"view"]) {
        NSString *urlStr = [selectedMenuDic objectForKey:@"url"];
        if ([urlStr length]) {
            [self openWebUrlForService:[StringUtil trimString:urlStr]];
        }
    }
    else if ([type isEqualToString:@"click"]){
        NSString *inputMsg = [selectedMenuDic objectForKey:@"key"];
        if(inputMsg.length == 0 )
            return;
        ServiceMessage *message = [[ServiceMessage alloc]init];
        message.msgBody = inputMsg;
        message.msgFlag = send_msg;
        message.msgTime = [_conn getCurrentTime];
        message.msgType = ps_msg_type_text;
        message.serviceId = self.serviceModel.serviceId;
        message.sendFlag = sending;
        [self sendClickCommand:message];
        [message release];
    }
}
#pragma mark 打开超链接
-(void)openWebUrlForService:(NSString *)urlStr
{
    openWebViewController *openweb=[[openWebViewController alloc]init];
    openweb.customTitle = self.serviceModel.serviceName;
    openweb.urlstr=urlStr;
    openweb.fromtype=1;
    openweb.needUserInfo = YES;
    
    [self.navigationController pushViewController:openweb animated:YES];
    [openweb release];
}
- (void)sendClickCommand:(ServiceMessage *)message{
    BOOL sendResult = [_conn sendPSMenuMsg:message];
}

#pragma mark - 初始化表情集合
- (void)loadFaceArray{
    
    if (self.bqStrArray == nil || self.bqStrArray.count == 0) {
        // 加载表情数据
        if ([eCloudConfig getConfig].useNewFaceDefine) {
            self.bqStrArray = faceValueDef;
            self.faceIconArray = faceIconNameDef;
        }else{
            self.bqStrArray = faceAfterName;
        }
        int rowCount = 8;   // 一行显示的表情个数
        
        //        if (IS_IPHONE) {
        //            if (IS_IPHONE_6P) {
        //                rowCount = 9;
        //            }
        //        }else if (IS_IPAD){
        //            if (SCREEN_WIDTH < SCREEN_HEIGHT) {
        //                rowCount = 10;
        //            }else{
        //                rowCount = 14;
        //            }
        //        }
        
        int pageCount = self.bqStrArray.count/(rowCount*3); // 表情的总的页数
        
#ifdef _XIANGYUAN_FLAG_
        
        if (self.bqStrArray.count < (rowCount*4*(pageCount+1)) - pageCount) {
            for (int i = self.bqStrArray.count; i < ((rowCount*4*(pageCount+1)) - pageCount)-1; i++) {
                
                [self.bqStrArray addObject:@""];
            }
        }
#endif
        
        
        // 为表情的每一页的最后添加一个删除表情
        for (int i = 0; i < pageCount+1; i++) {
            int scIndex = 3*rowCount*(i+1)-1;
            if (i == pageCount) {
                //#ifdef _XIANGYUAN_FLAG_
                //
                //#else
                //                return;
                //#endif
                
                // 0911 最后一页不显示删除按钮
                //scIndex = self.bqStrArray.count-1;
            }else if(i == 0){
                scIndex = (3*rowCount-1)*(i+1);
            }
            if ([eCloudConfig getConfig].useNewFaceDefine) {
                [self.bqStrArray insertObject:@"sc" atIndex:scIndex];
                [self.faceIconArray insertObject:@"sc" atIndex:scIndex];
            }else{
                [self.bqStrArray insertObject:@"sc" atIndex:scIndex];
            }
            
        }
    }
}
//当前会话是否支持回执消息 或 一呼百应消息 单聊/群聊/收到的一呼万应消息是否支持不确定
- (BOOL)supportHuizhiMsg
{
    if (self.talkType == singleType || self.talkType == mutiableType || self.talkType == rcvMassType) {
        return YES;
    }
    return NO;
}

#pragma mark =======转发提示=========
- (void)showTransferTips
{
    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}

- (void)showCollectTips:(NSString *)message
{
    [self performSelectorOnMainThread:@selector(showMyCollectTips:) withObject:message waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1.5];
}

- (void)showForwardTips
{
    [UserTipsUtil showForwardTips];
}

- (void)showMyCollectTips:(NSString *)message
{
    [UserTipsUtil showForwardTips:message];
}

- (void)dismissLoadingView
{
    [UserTipsUtil hideLoadingView];
}

#pragma mark =======传递会话id=========

-(NSString *)getConvid{
    NSString *convid = self.convId;
    return convid;
}

#pragma mark =====功能按钮相关程序======
- (void)prepareFunctionButtons
{
    functionArray = [[NSMutableArray alloc]init];
    
    FunctionButtonModel *_button = nil;
    
    //    照片按钮
    _button = [[FunctionButtonModel alloc]init];
    _button.functionName = [StringUtil getLocalizableString:@"chats_talksession_message_photo"];
    _button.imageName = @"chat_picture_icon.png";
    _button.hlImageName = @"chat_picture_icon_hl.png";
    _button.clickSelector = @selector(openSelectPictureController);
    [functionArray addObject:_button];
    [_button release];
    
    //    拍照按钮
    _button = [[FunctionButtonModel alloc]init];
    _button.functionName = [StringUtil getLocalizableString:@"chats_talksession_message_camera"];
    _button.imageName = @"chat_camera_icon.png";
    _button.hlImageName = @"chat_camera_icon_hl.png";
    _button.clickSelector = @selector(getCameraPicture);
    [functionArray addObject:_button];
    [_button release];
    
    //    视频按钮
    if ([eCloudConfig getConfig].supportVideo) {
        _button = [[FunctionButtonModel alloc]init];
        _button.functionName = [StringUtil getLocalizableString:@"chats_talksession_message_video"];
        _button.imageName = @"chat_video_icon.png";
        _button.hlImageName = @"chat_video_icon_hl.png";
        _button.clickSelector = @selector(getCameraVideo);
        [functionArray addObject:_button];
        [_button release];
    }
    
    if (self.talkType == singleType && [[MiLiaoUtilArc getUtil]isMiLiaoConv:self.convId]) {
        /** 密聊没有发送文件等其它功能 */
        return;
    }
    //     位置按钮
    if ([eCloudConfig getConfig].supportSendLocation)
    {
        _button = [[FunctionButtonModel alloc]init];
        _button.functionName = [StringUtil getLocalizableString:@"location"];
        _button.imageName = @"chat_location_icon.png";
        _button.hlImageName = @"chat_location_icon_hl.png";
        _button.clickSelector = @selector(getPosition);
        [functionArray addObject:_button];
        [_button release];
    }
    
    /** 红包按钮 */
#ifdef _LANGUANG_FLAG_
    if ([eCloudConfig getConfig].supportSendRedPacket && ![self.convId isEqualToString:File_ID])
    {
        if (![self.convId isEqualToString:SECRETARY_ID]) {
            
            _button = [[FunctionButtonModel alloc]init];
            _button.functionName = [StringUtil getLocalizableString:@"chats_talksession_message_red_packet"];
            _button.imageName = @"chat_red_icon.png";
            _button.hlImageName = @"chat_red_icon_hl.png";
            _button.clickSelector = @selector(getRedPacket);
            [functionArray addObject:_button];
            [_button release];
        }
    }
#endif
    // 如果是单聊 群聊 或者 是 收到的一呼万应 消息，那么显示文件功能；如果支持回执则显示回执按钮；如果支持一呼百应，则显示一呼百应按钮
    if(self.talkType == singleType || self.talkType == mutiableType || self.talkType == rcvMassType)
    {
#ifdef _BGY_FLAG_
        
#else
        _button = [[FunctionButtonModel alloc]init];//文件
        _button.functionName = [StringUtil getLocalizableString:@"chats_talksession_message_file"];
        _button.imageName = @"chat_file_icon.png";
        _button.hlImageName = @"chat_file_icon_hl.png";
        _button.clickSelector = @selector(openSelectFileController);
        [functionArray addObject:_button];
        [_button release];
#endif
        
        if ([[eCloudConfig getConfig]supportReceiptMsg] && ![self.convId isEqualToString:File_ID]){//回执
            
            if (![self.convId isEqualToString:SECRETARY_ID]) {
                _button = [[FunctionButtonModel alloc]init];
                _button.functionName = [StringUtil getAppLocalizableString:@"chats_talksession_message_receipt_1"];
                _button.imageName = @"chat_receipt_icon.png";
                _button.hlImageName = @"chat_receipt_icon_hl.png";
                _button.clickSelector = @selector(switchReceiptMsgMode);
                [functionArray addObject:_button];
                [_button release];
            }
        }
        
        if ([[eCloudConfig getConfig]supportYHBY] && isCanHundred) {//一呼百应
            _button = [[FunctionButtonModel alloc]init];
            _button.functionName = [StringUtil getLocalizableString:@"chats_talksession_message_receipt_0"];
            _button.imageName = @"chat_yhby_icon.png";
            _button.hlImageName = @"chat_yhby_icon_hl.png";
            _button.clickSelector = @selector(switchYHBYMsgMode);
            [functionArray addObject:_button];
            [_button release];
        }
    }
#ifdef _LANGUANG_FLAG_
    //    密聊按钮
    if(self.talkType == singleType){
        
        if ([UserDefaults getLanGuangSecret]) {
            
            _button = [[FunctionButtonModel alloc]init];
            _button.functionName = [StringUtil getLocalizableString:@"密聊"];
            _button.imageName = @"chat_miliao_icon.png";
            _button.hlImageName = @"chat_miliao_icon_hl.png";
            _button.clickSelector = @selector(goToMiLiao);
            [functionArray addObject:_button];
            [_button release];
            
        }
    }
#endif
    
#ifdef _HUAXIA_FLAG_
    if(self.talkType == singleType || (self.talkType == mutiableType)){
        _button = [[FunctionButtonModel alloc]init];
        _button.functionName = [StringUtil getLocalizableString:@"chats_talksession_message_start_conf"];
        _button.imageName = @"chat_create_conf.png";
        _button.hlImageName = @"chat_create_conf_hl.png";
        _button.clickSelector = @selector(startHXConf);
        [functionArray addObject:_button];
        [_button release];
    }
#endif
}

#ifdef _HUAXIA_FLAG_
- (void)startHXConf{
    NSString *tips = nil;
    if (self.talkType == singleType) {
        tips = [NSString stringWithFormat:[StringUtil getAppLocalizableString:@"create_conf_tips_single"],self.title];
    }else{
        tips = [StringUtil getAppLocalizableString:@"create_conf_tips_group"];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAppName] message:tips delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
    alert.tag = create_huaxia_conf_alert_tag;
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert show];
    [alert release];
}

#endif

//打开选择图片界面
- (void)openSelectPictureController
{
    ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied)
    {
        //无权限
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[StringUtil getLocalizableString:@"please_open_the_setting-privacy-photos_and_allow_the_program_open_the_photos"]
                                                       delegate:nil
                                              cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"]
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    selectPicStart = [StringUtil currentMillionSecond];
    
    if(nil == pictureManager)
    {
        pictureManager	=	[[PictureManager alloc]init];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0){
        //用户手动取消授权
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
            [[self class] showCanNotAccessPhotos];
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
}

//打开选择文件界面
- (void)openSelectFileController
{
    FileListViewController *ctr = [[FileListViewController alloc] init];
    ctr.locaLFilesDelegate = self;
    [self.navigationController pushViewController:ctr animated:YES];
    [ctr release];
}

//切换到回执消息状态
- (void)switchReceiptMsgMode
{
    [self hideModifyGroupNameButton];
    
    [receiptMsgFlagButton setTitle:[StringUtil getAppLocalizableString:@"change_conv_status_to_normal_1"] forState:UIControlStateNormal];
    
    receiptMsgFlagButton.hidden=NO;
    
    [[ReceiptMsgUtil getUtil]hidePinMsgButton];
    
    if(receiptMsgFlag == conv_status_normal || receiptMsgFlag == conv_status_receipt)
    {
        NSLog(@"%s,从正常模式或一呼百应模式切换为回执模式",__FUNCTION__);
    }
    else
    {
        NSLog(@"%s,高亮显示回执模式",__FUNCTION__);
        //			高亮显示 提示用户现在已经是回执消息模式 (这里是提示用户呢，还是转换为普通消息模式呢？)
        receiptMsgFlagButton.backgroundColor = highlightBgColorOfReceiptButton;
        [self performSelector:@selector(resetReceiptButton) withObject:nil afterDelay:0.8];
    }
    
    receiptMsgFlag = conv_status_huizhi;
}

//切换到一呼百应消息状态
- (void)switchYHBYMsgMode
{
    [self hideModifyGroupNameButton];
    
    [receiptMsgFlagButton setTitle:[StringUtil getLocalizableString:@"change_conv_status_to_normal_0"] forState:UIControlStateNormal];
    receiptMsgFlagButton.hidden=NO;
    
    //一呼百应
    if(receiptMsgFlag == conv_status_normal || receiptMsgFlag == conv_status_huizhi)
    {
        NSLog(@"%s 从正常模式或回执模式切换为 一呼百应模式",__FUNCTION__);
        receiptMsgFlag = conv_status_receipt;
    }
    else
    {
        NSLog(@"%s 高亮显示一呼百应模式",__FUNCTION__);
        receiptMsgFlagButton.backgroundColor = highlightBgColorOfReceiptButton;
        [self performSelector:@selector(resetReceiptButton) withObject:nil afterDelay:0.8];
    }
    receiptMsgFlag = conv_status_receipt;
    [_receiptDAO setConvStatus:self.convId andStatus:receiptMsgFlag];
}

//==========消息撤回功能==========
- (void)msgRecallAction
{
    if (self.editRecord) {
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"msg_recalling"]];
        BOOL ret = [[MsgConn getConn]recallMsg:self.editRecord];
        if (!ret) {
            [UserTipsUtil hideLoadingView];
        }
    }
}

#pragma mark - 语音转文字
- (void)audioToTxtAction{
    ConvRecord *_convRecord = self.editRecord;
    
    // lyan
    // 查询数据库该文本是否转换过
    BOOL isExisteflag = [[AudioTxtDAO getDatabase]isExistAudioTxt:_convRecord.conv_id andMsgId:_convRecord.msgId];
    
    // 初始化语音文本界面
    AudioToTextView *txtView = [[AudioToTextView alloc]initWithFrame:[[UIApplication sharedApplication]keyWindow].bounds];
    txtView.tag = 5520;
    if (isExisteflag) {
        NSString *messageStr = [[AudioTxtDAO getDatabase]getMessage:_convRecord.conv_id andMsgId:_convRecord.msgId];
        txtView.txtLabel.hidden = NO;
        if (messageStr) {
            txtView.txtLabel.text = messageStr;
        }else{
            txtView.txtLabel.text = @"已经转换过，但从数据库中获取文本失败";
        }
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(romoveAudioToTxtViewAction)];
        [txtView.txtLabel addGestureRecognizer:tapG];
        [tapG release];
    }else{
        // 未转换的调用语音转换文本接口
        [self uploadFileForAudioToTxt:_convRecord];
        txtView.txtLoadingTxt.hidden = NO;
        [txtView.txtLoadingTxt startAnimating];
        txtView.txtLoadingLabel.hidden = NO;
        txtView.txtCancelBtn.hidden = NO;
        [txtView.txtCancelBtn addTarget:self action:@selector(cancelAudioToTxtViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    [[[UIApplication sharedApplication]keyWindow]addSubview:txtView];
    [txtView release];
}

- (void)romoveAudioToTxtViewAction{
    AudioToTextView *txtView = (AudioToTextView *)[[[UIApplication sharedApplication]keyWindow] viewWithTag:5520];
    
    [txtView removeFromSuperview];
}

- (void)cancelAudioToTxtViewAction{
    AudioToTextView *txtView = (AudioToTextView *)[[[UIApplication sharedApplication]keyWindow] viewWithTag:5520];
    [txtView.txtLoadingTxt stopAnimating];
    [txtView removeFromSuperview];
}

- (void)processRecallMsgResult:(NSNotification *)notification
{
    [UserTipsUtil hideLoadingView];
    
    eCloudNotification *_object = notification.object;
    int cmdId = _object.cmdId;
    switch (cmdId) {
        case recall_msg_success:
        {
            NSDictionary *dic = _object.info;
            NSString *msgId = [dic valueForKey:KEY_RECALL_MSG_ID];
            int index = [self getArrayIndexByMsgId:msgId.intValue];
            if (index < 0) return;
            
            ConvRecord *convRecord = [self getConvRecordByMsgId:msgId];
            [self.convRecordArray replaceObjectAtIndex:index withObject:convRecord];
            [self reloadRow:index + 1];
        }
            break;
        case recall_msg_fail:
        {
            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"msg_recall_fail"] autoDimiss:YES];
        }
            break;
        case recall_msg_timeout:
        {
            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"msg_recall_timeout"] autoDimiss:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)reCalculateFrame
{
    [LogUtil debug:[NSString stringWithFormat:@"%s self.view.frame is %@ screen height is %.0f text height is %.0f keyboardHeight is %.0f ",__FUNCTION__,NSStringFromCGRect(self.view.frame),SCREEN_HEIGHT,self.messageTextField.frame.size.height,keyboardHeight]];
    
    if (picButton.tag == 2 || iconButton.tag == 2) {
        //        NSLog(@"停留在表情选择界面 或 功能选择界面");
        
        CGRect _frame = footerView.frame;
        
        int footerY =  SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight]  - 216 - 45 -  (self.textView.frame.size.height-input_text_height);
        
        if (_frame.origin.y != footerY) {
            footerView.frame=CGRectMake(0,footerY, self.view.frame.size.width, 260+input_area_height+[self getReplyMsgLabelHeight]);
        }
        
        _frame = self.chatTableView.frame;
        int tableH = footerY + 15;
        if (_frame.size.height != tableH) {
            self.chatTableView.frame=CGRectMake(0, 0, self.view.frame.size.width, tableH);
        }
    }
    else
    {
        //        if (keyboardHeight) {
        //            NSLog(@"键盘是打开的");
        //        }
        //        else
        //        {
        //            NSLog(@"键盘是关闭的");
        //        }
        float footerY = SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight] - 45 - keyboardHeight - (self.textView.frame.size.height-input_text_height);
        int tableH = footerY + 15;
        
        CGRect _frame = footerView.frame;
        if (_frame.origin.y != footerY) {
            footerView.frame = CGRectMake(0.0f, footerY, self.view.frame.size.width, 260.0f+input_area_height+[self getReplyMsgLabelHeight]);
        }
        _frame = self.chatTableView.frame;
        if (_frame.size.height != tableH) {
            self.chatTableView.frame=CGRectMake(0, 0, self.view.frame.size.width,tableH);
        }
    }
    [self.chatTableView reloadData];
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

- (void)initRobotMenu
{
    self.robotMenuArray = [[RobotDisplayUtil getUtil]getMenuArray];
}

//当有子菜单时 显示背景按钮，这样点击背景可以使子菜单消失
- (void)displayTableBackGroudButtonForHiddenSubMenu
{
    tableBackGroudButtonForHiddenSubMenu.hidden = NO;
}

//给机器人发送一条文本消息
- (void)sendMsgToRobot:(NSString *)msg
{
    if ([self isTalkWithiRobot]) {
        [self sendMessage:type_text message:msg filesize:-1 filename:nil andOldMsgId:nil];
    }
}

- (int)getOffset
{
    //    NSLog(@"%s offset is %d",__FUNCTION__,offset);
    return offset;
}

#pragma mark =====支持横屏=======
//准备表情数组
- (void)prepareFaceArray{
    //聊天表情相关
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    NSString *faceName = @"";
    
    for (int i = 0;i<[self.bqStrArray count];i++){
        if ([eCloudConfig getConfig].useNewFaceDefine) {
            //		 表情名字
            faceName = [NSString stringWithFormat:@"%@.png", [self.faceIconArray objectAtIndex:i]];
            //        表情对应的image对象
            UIImage *face = [StringUtil getImageByResName:faceName];// [NSString stringWithFormat:@"%03d.png",i+1]];
            //        生成一个dic，key是[/bqStr]，value是一个表情对象
            NSMutableDictionary *dicFace = [NSMutableDictionary dictionary];
            [dicFace setValue:face forKey:[NSString stringWithFormat:@"[/%@]",[self.bqStrArray objectAtIndex:i]]];// [NSString stringWithFormat:@"[/%03d]",i+1]];
            [temp addObject:dicFace];
        }else{
            //		 表情名字
            faceName = [NSString stringWithFormat:@"%@_%@.png", [eCloudConfig getConfig].facePrefix,[self.bqStrArray objectAtIndex:i]];
            //        表情对应的image对象
            UIImage *face = [StringUtil getImageByResName:faceName];// [NSString stringWithFormat:@"%03d.png",i+1]];
            //        生成一个dic，key是[/bqStr]，value是一个表情对象
            NSMutableDictionary *dicFace = [NSMutableDictionary dictionary];
            [dicFace setValue:face forKey:[NSString stringWithFormat:@"[/%@]",[self.bqStrArray objectAtIndex:i]]];// [NSString stringWithFormat:@"[/%03d]",i+1]];
            [temp addObject:dicFace];
        }
    }
    self.phraseArray = temp;
    [temp release];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //    其实有些subview可以使用autoresizeingmask属性来设置
    if (IS_IPAD) {
        CGRect _frame = CGRectZero;
        
        //        通过检查功能按钮的位置是否已经摆放正确 确定是否需要重新布局
        //    功能选择按钮
        _frame = picButton.frame;
        
        if (_frame.origin.x == SCREEN_WIDTH - _frame.size.width) {
            NSLog(@"%s 不需要重新布局",__FUNCTION__);
            return;
        }
        
        NSLog(@"%s 需要重新布局",__FUNCTION__);
        _frame.origin.x = SCREEN_WIDTH - _frame.size.width;
        picButton.frame = _frame;
        
        _frame = footerView.frame;
        _frame.size.width = SCREEN_WIDTH;
        footerView.frame = _frame;
        
        _frame = subfooterView.frame;
        _frame.size.width = SCREEN_WIDTH;
        subfooterView.frame = _frame;
        
        
        //    表情选择按钮
        _frame = iconButton.frame;
        _frame.origin.x = picButton.frame.origin.x - _frame.size.width;
        iconButton.frame = _frame;
        
        if(IOS7_OR_LATER)
        {
            messageTextField_width = SCREEN_WIDTH - 128 - messageParsex;
        }
        else
        {
            messageTextField_width = SCREEN_WIDTH - 122 - messageParsex;
        }
        _frame = self.messageTextField.frame;
        _frame.size.width = messageTextField_width;
        self.messageTextField.frame = _frame;
        
        //        发送语音按钮
        _frame = pressButton.frame;
        _frame.size.width = self.messageTextField.frame.size.width;
        pressButton.frame = _frame;
        
        //长语音按钮
        _frame = longAudioView.frame;
        _frame.size.width = SCREEN_WIDTH;
        longAudioView.frame = _frame;
        
        //       表情和消息输入框之间的分割线
        _frame = line1.frame;
        _frame.size.width = SCREEN_WIDTH;
        line1.frame = _frame;
        
        //    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(20, 230, self.view.frame.size.width-40, 20)];
        _frame = pageControl.frame;
        _frame.size.width = SCREEN_WIDTH - _frame.origin.x * 2;
        pageControl.frame = _frame;
        
        //    faceScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 53, self.view.frame.size.width, 170)];
        _frame = faceScrollview.frame;
        _frame.size.width = SCREEN_WIDTH;
        faceScrollview.frame = _frame;
        
        //        获取表情原来的页数 屏幕切换后 也自动选择为相同页
        float oldFaceCurPage = [pageControl currentPage];
        
        [self.bqStrArray removeAllObjects];
        self.bqStrArray = nil;
        [self loadFaceArray];
        [self prepareFaceArray];
        
        [self updateScrollview];
        
        if (oldFaceCurPage < pageControl.numberOfPages) {
            pageControl.currentPage = oldFaceCurPage;
            faceScrollview.contentOffset=CGPointMake(SCREEN_WIDTH*pageControl.currentPage, 0);
        }else{
            pageControl.currentPage = pageControl.numberOfPages - 1;
            faceScrollview.contentOffset=CGPointMake(SCREEN_WIDTH*pageControl.currentPage, 0);
        }
        //        pageControl.numberOfPages
        //         faceScrollview.contentOffset=CGPointMake(0, 0);
        
        //           sendButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 220, 60,30)];
        
        //        发送消息按钮
        _frame = sendButton.frame;
        _frame.origin.x = SCREEN_WIDTH - 70;
        sendButton.frame = _frame;
        
        //            addScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 53, self.view.frame.size.width, self.view.frame.size.width-60-53)];
        
        _frame = addScrollview.frame;
        _frame.size.width = SCREEN_WIDTH;
        addScrollview.frame = _frame;
        
        [self showAddScrollow];
        
        _frame = chatBackgroudView.frame;
        _frame.size.width = SCREEN_WIDTH;
        _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - 45;
        chatBackgroudView.frame = _frame;
        
        
        //       聊天记录table frame 和 recalculate里的代码基本一致
        if (picButton.tag == 2 || iconButton.tag == 2) {
            //        NSLog(@"停留在表情选择界面 或 功能选择界面");
            int footerY =  SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight]  - 216 - 45 -  (self.messageTextField.frame.size.height-input_text_height);
            
            footerView.frame=CGRectMake(0,footerY, SCREEN_WIDTH, 260+input_area_height);
            
            int tableH = footerY + 15;
            self.chatTableView.frame=CGRectMake(0, 0, SCREEN_WIDTH, tableH);
        }
        else
        {
            //        if (keyboardHeight) {
            //            NSLog(@"键盘是打开的");
            //        }
            //        else
            //        {
            //            NSLog(@"键盘是关闭的");
            //        }
            float footerY = SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight] - 45 - keyboardHeight - (self.messageTextField.frame.size.height-input_text_height);
            int tableH = footerY + 15;
            footerView.frame = CGRectMake(0.0f, footerY, SCREEN_WIDTH, 260.0f+input_area_height);
            self.chatTableView.frame=CGRectMake(0, 0, SCREEN_WIDTH,tableH);
        }
        
        [self.chatTableView reloadData];
        
        [self scrollToEnd];
    }
    //    if ([UIAdapterUtil isHongHuApp]) {
    //
    //        if (IS_IPHONE) {
    //
    //            CGRect _frame = self.chatTableView.frame;
    //            if (_frame.size.width == SCREEN_WIDTH) {
    //
    //                return;
    //            }
    //
    //        }
    //
    //
    //    }
    
}

- (float)getSelfViewHeight
{
    return SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
}

// 获取并发送用户位置
- (void)getPosition
{
    sendMapViewController *sendMapViewCtl = [[[sendMapViewController alloc] init] autorelease];
    [self.navigationController pushViewController:sendMapViewCtl animated:YES];
}


#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    NSString *AnnotationViewID = @"RedPin";
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID]autorelease];
        // 设置颜色
        annotationView.pinColor = BMKPinAnnotationColorRed;
    }
    return annotationView;
}

- (void)initMapView
{
    //   增加一个mapview 当收到位置类型消息时，使用此地图生成地图图片
    BMKMapView *mapView = [self.view viewWithTag:mapview_tag];
    if (!mapView) {
        float mapHeight = (LOCATION_PIC_HEIGHT * SCREEN_WIDTH) / LOCATION_PIC_WIDTH;
        mapView = [[[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, mapHeight)]autorelease];
        mapView.logoPosition = BMKLogoPositionRightTop;
        mapView.userInteractionEnabled = NO;
        mapView.delegate = self;
        
        [mapView setZoomLevel:MAP_ZOOM_LEVEL]; // 缩放大小
        mapView.tag = mapview_tag;
        
        [self.view addSubview:mapView];
        mapView.hidden = YES;
        
        // 添加红色大头针
        BMKPointAnnotation *item = [[[BMKPointAnnotation alloc]init]autorelease];;
        item.coordinate = mapView.centerCoordinate;
        [mapView addAnnotation:item];
    }
    [mapView viewWillAppear];
}

- (void)snapShot:(NSDictionary *)dic
{
    if (dic) {
        LocationMsgCell *locationCell = [dic valueForKey:@"location_cell"];
        ConvRecord *_convRecord = [dic valueForKey:@"location_convrecord"];
        if (locationCell && _convRecord) {
            NSString *strLat =  [[NSNumber numberWithDouble:_convRecord.locationModel.lantitude]stringValue];
            NSString *strLong = [[NSNumber numberWithDouble:_convRecord.locationModel.longtitude]stringValue];
            
            BMKMapView *mapView = [self.view viewWithTag:mapview_tag];
            if (([UIApplication sharedApplication].applicationState == UIApplicationStateActive) && self.curLocationRecord.locationModel.longtitude == _convRecord.locationModel.longtitude && self.curLocationRecord.locationModel.lantitude == _convRecord.locationModel.lantitude) {
                
                NSLog(@"%s 可以生成截图",__FUNCTION__);
                
                //截图
                UIImage *mapImage = [mapView takeSnapshot:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
                
                NSData *mapData = UIImagePNGRepresentation(mapImage);
                NSString *mapPath = [StringUtil getMapPath:strLat withLongitude:strLong];
                [mapData writeToFile:mapPath atomically:YES];
                _convRecord.imageDisplay = mapImage;
                
                UIImageView *locationPicView = [locationCell.contentView viewWithTag:location_pic_view_tag];
                locationPicView.image = mapImage;
                
                UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[locationCell.contentView viewWithTag:location_load_indicator_view_tag];
                [indicator stopAnimating];
                
            }else{
                NSLog(@"%s 不能生成截图",__FUNCTION__);
            }
        }
    }
}

//增加bottom tool bar 用来批量删除
- (void)addBottomBar
{
    if (CAN_EDIT_CONVRECORD) {
        bottomToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50.0)];
        bottomToolBar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
        bottomToolBar.hidden = YES;
        [footerView addSubview:bottomToolBar];
        [bottomToolBar release];
        
        //分割线
//        UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 1.0)];
//        lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
//        [bottomToolBar addSubview:lineLab];
//        [lineLab release];
        
        //        按钮
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,1,SCREEN_WIDTH/2,49.0)];
//        editBtn.backgroundColor = [UIColor clearColor];
        //        editBtn.tag = file_edit_button_tag + i;
        //        [editBtn setImage:[StringUtil getImageByResName:@"delete_normal.png"] forState:UIControlStateNormal];
        //        [editBtn setImage:[StringUtil getImageByResName:@"delete_pressed.png"] forState:UIControlStateHighlighted];
        
        [editBtn setTitleColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

        [editBtn setBackgroundImage:[ImageUtil createImageWithColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]] forState:UIControlStateHighlighted];
        
        
        editBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [editBtn addTarget:self action:@selector(clickBottomButton:) forControlEvents:UIControlEventTouchUpInside];
        [editBtn setTitle:[StringUtil getLocalizableString:@"delete"] forState:UIControlStateNormal];
        [bottomToolBar addSubview:editBtn];
        [editBtn release];
        
        UIButton *forwardEditBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2,1,SCREEN_WIDTH/2,49.0)];
//        forwardEditBtn.backgroundColor = [UIColor clearColor];
        //        editBtn.tag = file_edit_button_tag + i;
        //        [editBtn setImage:[StringUtil getImageByResName:@"delete_normal.png"] forState:UIControlStateNormal];
        //        [editBtn setImage:[StringUtil getImageByResName:@"delete_pressed.png"] forState:UIControlStateHighlighted];
        
        [forwardEditBtn setTitleColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]forState:UIControlStateNormal];
        [forwardEditBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [forwardEditBtn setBackgroundImage:[ImageUtil createImageWithColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]] forState:UIControlStateHighlighted];
        
        forwardEditBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
        [forwardEditBtn addTarget:self action:@selector(forwardEditBtn:) forControlEvents:UIControlEventTouchUpInside];
        [forwardEditBtn setTitle:[StringUtil getLocalizableString:@"forward"] forState:UIControlStateNormal];
        [bottomToolBar addSubview:forwardEditBtn];
        [forwardEditBtn release];
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 1, 1, 49.0)];
//        label.backgroundColor = [UIColor grayColor];
//        [bottomToolBar addSubview:label];
    }
}

- (NSArray *)getSelectedRecords
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (ConvRecord *_convRecord in self.convRecordArray) {
        if (_convRecord.isSelect && _convRecord.msg_type != type_group_info) {
            
            NSLog(@"%lld",_convRecord.origin_msg_id);
            [tempArray addObject:_convRecord];
        }
    }
    return tempArray;
}
//批量转发
- (void)forwardEditBtn:(id)sender
{
    NSArray *selectedRecords = [self getSelectedRecords];
    for (ConvRecord *_convRecord in selectedRecords) {
        if (_convRecord.msg_type == type_record) {
            
            UIAlertView *linkalert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"selected_message_voice_message_cannot_be_forwarded"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [linkalert show];
            [linkalert release];
            return;
        }if (_convRecord.msg_type == type_pic && !_convRecord.isBigPicExist) {
            
            [talkSessionUtil setPropertyOfConvRecord:_convRecord];
            
            if (!_convRecord.isBigPicExist) {
                
                UIAlertView *linkalert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"selected_news_not_download_figure_cannot_be_forwarded"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
                [linkalert show];
                [linkalert release];
                return;
            }
        }
#ifdef _LANGUANG_FLAG_
        
        if (_convRecord.msg_type == type_text) {
            
            if (_convRecord.redPacketModel) {
                
                UIAlertView *linkalert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"selected_news_not_red_packet_cannot_be_forwarded"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
                [linkalert show];
                [linkalert release];
                return;
            }
            
        }
#endif
    }
    
    [self openRecentContacts];
    
}

//删除选择的记录
- (void)clickBottomButton:(id)sender
{
    NSArray *selectedRecords = [self getSelectedRecords];
    if (selectedRecords.count) {
        //    弹出提示
        [self showDeleteTips];
    }
}

- (void)deleteSelectedConvRecords
{
    NSArray *selectedRecords = [self getSelectedRecords];
    
    for (ConvRecord *_convRecord in selectedRecords) {
        [[eCloudDAO getDatabase]deleteOneMsg:[StringUtil getStringValue:_convRecord.msgId]];
        [self.convRecordArray removeObject:_convRecord];
    }
    [self cancelEditConvRecord];
}

- (void)showDeleteTips
{
    if (IOS8_OR_LATER && IS_IPHONE) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"delete"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            [self deleteSelectedConvRecords];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [self cancelEditConvRecord];
        }];
        
        [alert addAction:deleteAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        if (!deleteConvRecordsActionSheet) {
            deleteConvRecordsActionSheet = [[UIActionSheet alloc]
                                            initWithTitle:nil
                                            delegate:self
                                            cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                                            destructiveButtonTitle:[StringUtil getLocalizableString:@"delete"]
                                            otherButtonTitles:nil, nil];
        }
        [deleteConvRecordsActionSheet showInView:self.view];
    }
}

//打开编辑状态
- (void)editConvRecord
{
    // 修改导航栏左侧按钮为取消按钮
    //    要记录当前为编辑状态
    //
    if (self.editRecord) {
        NSLog(@"%s 开启编辑状态",__FUNCTION__);
        
        //        显示批量删除按钮
        bottomToolBar.hidden = NO;
        [footerView bringSubviewToFront:bottomToolBar];
        
        //        设置当前记录已经选择
        self.editRecord.isSelect = YES;
        
        //        记录状态
        isEditingConvRecord = YES;
        //        设置左侧按钮
        backButton = nil;

        UIButton *leftButton = [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(cancelEditConvRecord) andDisplayLeftButtonImage:NO];
        [leftButton setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        //        隐藏右侧按钮
        [self.navigationItem setRightBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItems:nil];
        
        [self.chatTableView reloadData];
    }
}

//关闭编辑状态
- (void)cancelEditConvRecord
{
    NSLog(@"%s 取消编辑状态",__FUNCTION__);
    bottomToolBar.hidden = YES;
    
    isEditingConvRecord = NO;
    
    for (ConvRecord *_convRecord in self.convRecordArray) {
        if (_convRecord.isSelect) {
            _convRecord.isSelect = NO;
        }
    }
    backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    [self showNoReadNum];
    
    [self setRightBtn];
    
    [self.chatTableView reloadData];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

//外部保存到云盘
- (void)externalSavedTocloud:(NSMutableArray *)_convRecord{
    if (_convRecord.count >0) {
        
        self.editRecord = _convRecord[0];
        self.editRecord.isFileExists = YES;
        
        [self savedTocloud];
    }
    
}
//预览云文件
- (void)clounFilePreView
{
    [CloudFileUtil clounFilePreView:self.editRecord];
}

- (void)previewTheCloudFile:(NSString *)url{
    
    AgentListViewController *AgentListController = [[[AgentListViewController alloc]init]autorelease];
    AgentListController.delegete = self;
    AgentListController.urlstr = url;
    [self.navigationController pushViewController:AgentListController animated:YES];
}
//保存到云盘
- (void)savedTocloud
{
    
    [CloudFileUtil savedTocloud:self.editRecord];
    
}

/** 定向回复功能 回复某条消息时 需要对文本框进行改造 */
- (void)setTextViewFrame:(CGRect)_frame{
    //    if (!self.textView.hidden) {
    if (self.messageLabel.hidden){
        self.textView.frame = _frame;
        _frame.origin = CGPointMake(0,0);
        self.messageTextField.frame = _frame;
    }else{
        CGRect tempFrame = _frame;
        tempFrame.size.height = _frame.size.height + (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
        self.textView.frame = tempFrame;
        _frame.origin = CGPointMake(0,(REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT));
        self.messageTextField.frame = _frame;
    }
    //    }
}

/** 获取定向回复消息显示的高度 如果隐藏就是0 */
- (float)getReplyMsgLabelHeight{
    if (self.textView.hidden) {
        return 0.0;
    }
    if (self.messageLabel.hidden){
        return 0.0;
    }else{
        return (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
    }
}

- (void)replyAction
{
    if ([self.textView isHidden]) {
        [self talkAction:talkButton];
    }
    
    NSLog(@"editRecord %d %@", self.editRecord.msg_type, self.editRecord.msg_body);
    
    NSString *replyStr = @"“";
    switch (self.editRecord.msg_type) {
        case type_text:
        {
            replyStr = self.editRecord.msg_body;// [NSString stringWithFormat:@"“ %@",self.editRecord.msg_body];
            if (self.editRecord.locationModel) {
                replyStr = [StringUtil getLocalizableString:@"msg_type_location"];// @"“ [位置]";
            }
        }
            break;
        case type_pic:
        {
            replyStr = [StringUtil getLocalizableString:@"msg_type_pic"];//@"“ [图片]";
        }
            break;
        case type_record:
        {
            replyStr = [StringUtil getLocalizableString:@"msg_type_record"];//@"“ [语音]";
        }
            break;
        case type_video:
        {
            replyStr = [StringUtil getLocalizableString:@"msg_type_video"];//@"“ [视频]";
        }
            break;
        case type_file:
        {
            replyStr = [StringUtil getLocalizableString:@"msg_type_file"];//@"“ [文件]";
        }
            break;
        case type_long_msg:
        {
            replyStr = [StringUtil getLocalizableString:@"msg_type_long_msg"];
        }
            break;
            
        default:
            break;
    }
    if (replyStr.length) {
        replyStr = [NSString stringWithFormat:@"“%@",replyStr];
    }
    
    //    NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithString:replyStr] autorelease];
    //    [attrStr addAttribute:NSFontAttributeName
    //                    value:[UIFont systemFontOfSize:27.0f]
    //                    range:NSMakeRange(0, 1)];
    //    [attrStr addAttribute:NSBaselineOffsetAttributeName
    //                    value:@(-10)   // 正值上偏 负值下偏
    //                    range:NSMakeRange(0, 1)];
    //
    //    self.messageLabel.attributedText = attrStr;
    self.messageLabel.text = replyStr;
    
    if (self.messageLabel.hidden) {
        self.messageLabel.hidden = NO;
        
        CGRect rect1 = self.messageTextField.frame;
        rect1.origin.y = REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT;
        self.messageTextField.frame = rect1;
        
        CGRect rect2 = self.textView.frame;
        rect2.size.height = self.messageTextField.frame.size.height + self.messageTextField.frame.origin.y;
        self.textView.frame = rect2;
        
        CGRect rect3 = footerView.frame;
        rect3.origin.y -= (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
        rect3.size.height += (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
        footerView.frame = rect3;
        
        self.chatTableView.frame=CGRectMake(0, 0, self.view.frame.size.width,footerView.frame.origin.y + 15);
        
        CGRect rect4 = subfooterView.frame;
        rect4.origin.y += (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
        subfooterView.frame=rect4;
    }
    
    [self.messageTextField becomeFirstResponder];
}

- (void)cancelReplyMessage
{
    if (!self.messageLabel.hidden) {
        self.messageLabel.hidden = YES;
        
        CGRect rect1 = self.messageTextField.frame;
        rect1.origin.y = 0;
        self.messageTextField.frame = rect1;
        
        CGRect rect2 = self.textView.frame;
        rect2.size.height = self.messageTextField.frame.size.height + self.messageTextField.frame.origin.y;
        self.textView.frame = rect2;
        
        CGRect rect3 = footerView.frame;
        rect3.origin.y += (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
        rect3.size.height -= (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
        footerView.frame = rect3;
        
        self.chatTableView.frame=CGRectMake(0, 0, self.view.frame.size.width,footerView.frame.origin.y + 15);
        
        CGRect rect4 = subfooterView.frame;
        rect4.origin.y -= (REPLY_MSG_LABEL_Y + REPLY_MSG_LABEL_HEIGHT);
        subfooterView.frame=rect4;
    }
}

- (void)getRedPacket
{
#ifdef _LANGUANG_FLAG_
    [[redpacketViewControllerARC getRedpacketViewController] addRedPacket:self andConvType:self.talkType convEmps:self.convEmps];
#endif
}

- (void)shareToOtherApp
{
#ifdef _LANGUANG_FLAG_
    
    if(self.editRecord.msg_type == type_pic)
    {
        NSString *copyStr = self.editRecord.msg_body;
        NSString *fileName = [NSString stringWithFormat:@"%@.png",copyStr];
        NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
        
        NSData *imageData = [EncryptFileManege getDataWithPath:filePath];
        UIImage *img = [UIImage imageWithData:imageData];
        //            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        if (img!=nil)
        {
            self.messageTextField.copypic=true;
            copyStr = filePath;
        }
        else
        {
            copyStr = @"";
            
            if (maxSendFileSize == 20) {
                [self downloadFile:self.editRecord.msgId andCell:nil];
            }
            else{
                [self downloadResumeFile:self.editRecord.msgId andCell:nil];
            }
            
        }
    }
    
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.bgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3];
    
    self.infoView = [[LANGUANGShareView getShareView]shareView];
    [LANGUANGShareView getShareView].editRecord = self.editRecord;
    [self.bgView addSubview:self.infoView];
    
    [self.view addSubview:self.bgView];
    [self.bgView release];
    [self setInfoViewFrame:YES];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturedDetected:)];
    [self.bgView addGestureRecognizer:tapGesture];
    
#endif
}
-(void)tapGesturedDetected:(UITapGestureRecognizer *)gestureRecognizer
{
    [self setInfoViewFrame:NO];
    [self.view removeGestureRecognizer:gestureRecognizer];
    
}

/** 自定义分享菜单 */
- (void)setInfoViewFrame:(BOOL)isDown{
    
    
    if(isDown == NO) {
        
        [UIView beginAnimations:nil context:nil];
        
        [UIView setAnimationDuration:0.4];
        [_infoView setFrame:CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width,100)];
        [self.bgView removeFromSuperview];
        self.bgView = nil;
        [UIView commitAnimations];
        
    }else {
        
        [UIView beginAnimations:nil context:nil];
        
        [UIView setAnimationDuration:0.4];
        [_infoView setFrame:CGRectMake(0,self.view.frame.size.height-100,self.view.frame.size.width,100)];
        [UIView commitAnimations];
        
    }
}
#pragma mark 获取到用户资料后怎么更新当前界面
- (void)processGetUserInfoFromHX:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *convId = userInfo[@"conv_id"];
    Emp *_emp = userInfo[@"EMP"];
    if (convId.length && _emp) {
        //        如果和当前聊天界面的会话id一致，那么修改内存里的内容，包括人员名字，人员性别，还有会话标题，群组通知内容
        if ([convId isEqualToString:self.convId]) {
            BOOL needRefresh = NO;
            for (ConvRecord *_convRecord in self.convRecordArray) {
                if (_convRecord.msg_type == type_group_info) {
                    NSString *msgBody = _convRecord.msg_body;
                    msgBody = [msgBody stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\'%d\'",_emp.emp_id] withString:_emp.emp_name];
                    needRefresh = YES;
                    _convRecord.msg_body = msgBody;
                }else{
                    if (_convRecord.emp_id == _emp.emp_id) {
                        _convRecord.emp_name = _emp.emp_name;
                        _convRecord.emp_sex = _emp.emp_sex;
                        _convRecord.emp_code = _emp.empCode;
                        needRefresh = YES;
                    }
                }
            }
            if (needRefresh) {
                [self reloadTableData];
            }
            if (self.talkType == singleType) {
                self.titleStr = _emp.emp_name;
            }
            [self initTitle];
        }
    }
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
    agent.isNews = YES;
    [self.navigationController pushViewController:agent animated:YES];
    [agent release];
#endif
    
}

/** 回到普通消息状态 蓝光红包的位置消息不需要回执功能*/
- (void)setConvStatusToNormal{
    receiptMsgFlagButton.hidden = YES;
    receiptMsgFlag = conv_status_normal;
}

@end
@implementation UIImagePickerController (LandScapeImagePicker)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS10_OR_LATER && self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:NO block:^(NSTimer * timer) {
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
        }];
    }
}
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    if ([UIAdapterUtil isLandscap])
        return UIInterfaceOrientationMaskLandscape;
    return UIInterfaceOrientationPortrait;
}

@end

