//
//  talkSessionViewController.h
//  eCloud
//  聊天界面类 发送消息、接收消息、展示消息
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "CL_VoiceEngine.h"
//#import "ChatCustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ASINetworkQueue.h"
#import <AVFoundation/AVFoundation.h>
#import "amrToWavMothod.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <QuickLook/QLPreviewController.h>
#import "PictureManager.h"
#import "FGalleryViewController.h"
#import "LocaLFilesViewController.h"
#import "FileListViewController.h"
#import "IM_MenuView.h"

//下载图片tag
#define  downloadImgeTag 111111110
//显示图片tag
#define  showImageTag 111111111
#define  showTipTag 111111112
#define  showAudioTag 111111113
#define  showFailButtonTag 111111114
#define  picPathTag 111111115
#define  fileNameTag 111111116
#define  progressTag 111111117
#define MsgIdTag 111111118
#define msgFlagTag 111111119
#define playaudioFlagTag 111111120
#define rowIDFlagTag 111111121
#define activityTag 111111122

//add by shisp
//增加一个长消息的路径tag
#define longMsgPathTag 111111123

/** 打开聊天界面时的类型定义 */
typedef enum
{
    //    talksession_from_appplatform_direct = 3,
    //    talksession_fromtype_appplatform_choose_first = 4,
    /** 从会话搜索结果的二级界面进入会话，需要对搜索结果定位 */
    talksession_from_conv_query_result_need_position = 5,
    /** 从会话搜索结果界面进入会话，不需要定位到某一条消息 */
    talksession_from_conv_query_result_need_not_position = 2,
    /** deprecated */
    talksession_from_chatRecordView = 6,
    //    从万达app直接过来
    /** deprecated */
    talksession_from_wandaapp = 11,
}talksession_fromtype;

@class ServiceModel;

@class UserInfo;
@class eCloudNotification;
@class ConvRecord;
@class conn;
@class InputTextView;
@class Conversation;
@class personInfoViewController;
//@class CL_AudioRecorder;
@class AudioPlayForIOS6;
@class talkRecordDetailViewController;

#define transPercentKey	@"_percent"
#define transStatusKey	@"_status"
#define kRecorderDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]  stringByAppendingPathComponent:@"Recorders"]

@interface talkSessionViewController : UIViewController<ASIProgressDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVAudioPlayerDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,QLPreviewControllerDataSource,photosLibraryManagerDelegate,ELCImagePickerControllerDelegate,FGalleryViewControllerDelegate,LocaLFilesViewControllerDelegate,FileListViewControllerDelegate,MenuViewDelegate>
{
//	局部变量
//	NSArray *bqStrArray;
	UIView *footerView;
    UIView *subfooterView;
    UIButton *pressButton;
	UIButton *iconButton;
    UIButton *picButton;
    UIScrollView *faceScrollview;
    UIScrollView *addScrollview;
    UIPageControl *pageControl;
    UIImageView * talkIconView;
    UIImageView * talkIconWarningView;
    UIImageView * talkIconCancelView;
    UIImageView *chatBackgroudView;
	 int message_len;
//	属性
    NSString *titleStr;
   
    int talkType;

    NSMutableArray            *_phraseArray;
    NSMutableArray		       *_chatArray;
	
    NSMutableString            *_messageString;
   // UITextView               *_messageTextField;
	InputTextView *_messageTextField;
    NSDate                     *_lastTime;
    UITableView                *_chatTableView;
    NSString                   *_phraseString;

	//	add by shisp 会话人员数组，如果是单人会话，那么数组中只保存一名成员
	NSArray *_convEmps;
	
	//	会话id
	NSString* _convId;
	id delegete;
	
	//	着重显示的字符串
	NSString *_searchStr;

    int needUpdateTag;//从联系人，组织架构等界面进入，需要刷新，其他界面返回无须刷新

	//	当前正在播放的录音的路径
	NSString *_curRecordPath;
	
//第一条消息id
	NSString *_firstMsgId;
	//	第一条消息内容
	NSString *_firstMsgStr;
	//	第一条消息类型
	int _firstMsgType;
	
	//	如果第一条消息是录音或图片，那么记录文件的名字和大小
	int _firstFileSize;
	NSString *_firstFileName;

	BOOL _isVirGroup;

   //-------------------------
    CL_AudioRecorder* audioRecoder;
    BOOL              m_isRecording;
	personInfoViewController *  personInfo;

    UILabel *updateTimeLabel;
    UILabel *updateLongTimeLabel;
    float updateTimeValue;
	
	conn *_conn;

//	表情的高和宽
	int faceWidth;
	int faceHeight;
	
	//	会话的总记录个数
	int totalCount;
//	已经加载的记录个数
	int loadCount;
	//	查询会话时用到的参数
	int limit;
	int offset;
	
	UIActivityIndicatorView *loadingIndic;
	
	bool isLoading;
    
    UIActivityIndicatorView *tabelIndicator;
 
    UIImagePickerController *pickerPic;
    
    UIImagePickerController *pickerVideo;
    BOOL isWifi;
    UIImageView *audioImageview;
	
//	收到的和发送的声音的播放动画
	UIImageView *sendVoicePlayView;
	UIImageView *rcvVoicePlayView;

    AVAudioPlayer* audioPlayer;
    UIActionSheet *choosePicMenu;
	
   // add by lyong 2012-11-22
    amrToWavMothod *amrtowav;
    NSString *copyTextStr;
    NSString *copyPicPath;
    NSString *copyMsg_id;
    int copyRow;
    int copyType;//0-text 1-pic 2-aduio
	
    UIButton *talkButton;
    
    // 聊天bar中增加菜单和服务选项
    UIButton *muneButton;
    IM_MenuView *menuView;
    
    int	secondValue;
    NSTimer*  secondTimer;
    UIButton *tableBackGroudButton;
    
    UIButton *tableBackGroudButtonForHiddenSubMenu;

    AudioPlayForIOS6 *audioplayios6;
	
    UIButton *addButton;
    UIButton *backButton;
    UIButton *telButton;
    
    NSString *_picOrAudio_MsgID;//纪录 pic，audio 发送时的id  －1，为文本消息
    UserInfo *uinfo;
	
    UIAlertView *reSendAlert;
	
    BOOL _isHaveBeingHere;
	
    int last_msg_id;
    UIAlertView *picCopyAlert;
    UIImageView *picCopyImageView;
    NSString *notificationName;//通知名称
	eCloudNotification *notificationObject;//通知带的对象
    
    //长语音控件
    UIView *longAudioView;
    UIImageView *longAudioImageView;
    UIButton *longAudioPlayButton;
    UIButton *longAudioCloseButton;
    
    //多选 图片
     PictureManager *pictureManager;
     NSTimer *manypicTimer;
     NSMutableArray *manyPicArray;
     int pic_index;
    //预览图片
    FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
    NSString *preImageFullPath;
    
    //2014-3-6   pain  会话页面可以查看多张大图
    NSMutableArray *networkThumbnailImagesArr;
    NSMutableArray *networkImagesArr;
    
    //上传文件
    NSTimer *manyFileTimer;
    NSMutableArray *manyFilesArray;
    int file_index;
    
    ConvRecord *_forwardRecord;
    
    //听筒模式
    UIView *listenModeView;
    UserInfo* userinfo_new;
    NSTimer *listenModeTimer;
    
    
    BOOL isEmtiom;  //判断键盘收起的时候需不需要改变FootView高度
    
    __block  BOOL recordPermissionUndetermined;  //判断录音是否授权
    __block BOOL isFingureUp;  //判断录音按钮的手指是否松开
}
/** 公众号消息的显示界面和普通单聊群聊的显示界面是共用的，这个是对应的公众号的模型 */
@property (nonatomic,retain) ServiceModel *serviceModel;

/** deprecated */
@property(nonatomic,retain)  NSString *preImageFullPath;

/** 和聊天记录对应的数组 */
@property(nonatomic,retain) NSMutableArray *convRecordArray;

/** deprecate */
@property(nonatomic,retain)     NSString *picOrAudio_MsgID;

/** 当前正在播放的录音文件的路径 */
@property (nonatomic,retain)	NSString *curRecordPath;

/** deprecated */
@property(assign)int message_len;

/** 在ios6及以上播放录音文件时，无法区分是暂停播放，还是播放完成后自动停止，所以增加一个标志，加以区分，如果是暂停播放，就不会继续播放下一个，否则可以连续播放下一个未读录音 */
@property(nonatomic,assign) bool isAudioPause;

/** 当前的录音文件的名字 */
@property(nonatomic,retain) NSString *curAudioName;

/** 当前会话的最后一条消息的消息id */
@property int		last_msg_id;

/** deprecated */
@property BOOL isVirGroup;

/** 录音的秒数 */
@property(nonatomic,assign) int		secondValue;

/** 是否需要重新获取数据刷新界面 */
@property(assign) int needUpdateTag;

/** deprecated */
@property (nonatomic , retain) id delegete;
/** deprecated */
@property (nonatomic,assign)float updateTimeValue;

/** 会话标题 */
@property(nonatomic,retain) NSString *titleStr;

/** 会话类型 比如单聊/群聊 */
@property(nonatomic, assign)  int talkType;

/** 表情对应的字符串数组  对应了faceDefine中表情数组的定义*/
@property(nonatomic,retain) NSMutableArray *bqStrArray;

/** 表情对应的文件的名字*/
@property(nonatomic,retain) NSMutableArray *faceIconArray;


/** 表情图片，表情所代表的文字的对应关系组成的数组 每一个元素是是一个字典 key:[/xxx] value是xxx对应的表情image 在聊天界面显示表情使用*/
@property (nonatomic, retain) NSMutableArray  *phraseArray;

/** 用户选择的表情对应的文字 */
@property (nonatomic, retain) NSString               *phraseString;

/** deprecated */
@property (nonatomic, retain) NSMutableArray *chatArray;

/** 聊天界面文本框的内容 */
@property (nonatomic, retain) NSMutableString  *messageString;

/** 聊天界面 文本数据库 对象 */
@property (nonatomic, retain) IBOutlet InputTextView  *messageTextField;

/** deprecated */
@property (nonatomic, retain) NSDate                 *lastTime;

/** 聊天界面对应的UITableView */
@property (nonatomic, retain) IBOutlet UITableView   *chatTableView;

/** 当前聊天界面对应的成员 */
@property(nonatomic,retain) NSArray *convEmps;

/** 当前聊天界面对应的会话id */
@property(nonatomic,retain) NSString *convId;

/** deprecated */
@property(retain) NSString* searchStr;

/** 第一条消息id deprecated */
@property(nonatomic,retain) NSString *firstMsgId;

/** 第一条消息内容 deprecated */
@property(nonatomic,retain)  NSString *firstMsgStr;

/** 第一条消息类型 deprecated */
@property(nonatomic,assign) int firstMsgType;

/** deprecated */
@property(nonatomic,assign) int firstFileSize;

/** deprecated */
@property(nonatomic,retain) NSString *firstFileName;

/** 返回到会话列表时 这个参数设置为NO 这时不再接收会话通知 */
@property (nonatomic,assign) BOOL isHaveBeingHere;

/** deprecated */
@property(nonatomic,retain)UIView *reLinkView;

/** deprecated */
@property(nonatomic,retain)UIActivityIndicatorView *topactivity;

/** 复制或删除消息的消息id */
@property(nonatomic,retain)NSString *editMsgId;

/** 复制或删除对应的消息记录 */
@property(nonatomic,retain)ConvRecord *editRecord;

/** 编辑的记录的行号 */
@property(nonatomic,assign)int editRow;

/** 是否是删除，如果是那么就不用恢复原来的显示 */
@property(nonatomic,assign)bool isDeleteAction;

/** 加载当前会话的离线消息 */
@property(nonatomic,retain)NSMutableArray *curOfflineMsgs;

/** 未读记录数 add by shisp 2013.8.12，首次进入会话列表时使用，确定界面停留在哪个位置 deprecated */
@property(nonatomic,assign)int unReadMsgCount;

/** 群发人员总数 deprecated*/
@property(nonatomic,assign) int massTotalEmpCount;

/** 复制或删除的行对应的indexPath对象 */
@property(retain) NSIndexPath *editIndexPath;

/** 是从那个界面打开聊天界面的，确定返回的时候回到哪个界面 */
@property(assign) int fromType;

/** 暂时保存转发的聊天记录 */
@property(nonatomic,retain) ConvRecord *forwardRecord;

/** 从查询会话结果界面到达聊天界面需要一个Conversation类型的参数，经过查询，方便定位在对应的匹配的那条聊天记录上 */
@property(nonatomic,retain) Conversation *fromConv;

/** 发送转发消息标志 */
@property (nonatomic,assign) BOOL sendForwardMsgFlag;

/** 增加一个可变数组 点击搜索结果 定位在某一行，不一次性加载所有的，而是先加载一部分，拉到底的时候，再从没有加载的数据里再取一部分,这个变量就是保存还未加载的查询结果 */
@property (nonatomic,retain) NSMutableArray *unloadQueryResultArray;

/** 暂时保存文件助手转发的消息 */
@property (nonatomic,retain) NSMutableArray *forwardRecordsArray;
/** 文件助手转发标识 */
@property (nonatomic,assign) BOOL sendFileAssistantForwardMsgFlag;

/** 公众号的服务菜单 数据 */
@property (nonatomic, retain) NSMutableArray *allUpDatas;

/** 存放一级菜单 */
@property (nonatomic, retain) NSMutableArray *firstMenuArray;
/** 存放二级菜单 */
@property (nonatomic, retain) NSMutableArray *subMenuArray;

/** 机器人菜单数组 */
@property (nonatomic,retain) NSArray *robotMenuArray;

/** 获取单例 */
+(talkSessionViewController*)getTalkSession;

/**
 显示并且上传图片

 @param data 图片类型的data
 */
-(void)displayAndUploadPic:(NSData *)data;

#pragma mark 发送，接收录音2012-11-15 fromType(NO-上传 YES-下载)

/**
 重新获取数据，刷新界面
 */
-(void)refresh;

/**
 复制图片后，粘贴图片，弹出提示

 @param image 保存在pasteboard里的image对象
 */
-(void)alertSendCopyPic:(UIImage *)image;

/**
 返回 按钮 事件处理

 @param sender 返回按钮
 */
-(void) backButtonPressed:(id) sender;

#pragma mark 多图 发送

/**
 在选择图片界面选好图片后，调用此方法发送图片

 @param picArray 选择的图片数组
 */
-(void)uploadManyPics:(NSMutableArray *)picArray;


/**
 显示和发送文件
 目前长按照片按钮发送日志就是使用的这个方法完成的

 @param data 文件data
 @param dic 包括了fileName
 */
-(void)displayAndUploadLocalFile:(NSData *)data withDic:(NSMutableDictionary *)dic;

#pragma mark 保存转发的消息
/** deprecated */
- (BOOL)saveForwardMsg;

#pragma mark 发送转发的消息
/** deprecated */
- (void)sendForwardMsg;

#pragma mark =================文件断点续传相关=========================
/**
 文件助手批量转发

 @param forwardRecordsArray 待转发的消息记录数组
 @return YES
 */
- (BOOL)saveFileAssistantForwardMsgsArray:(NSArray *)forwardRecordsArray;


/**
 准备上传聊天model里的文件

 @param _convRecord 要上传的聊天记录
 */
-(void)prepareUploadFileWithFileRecord:(ConvRecord*)_convRecord;

/**
 不再接收会话通知
 */
- (void)removeConvNotification;

/**
 获取下拉加载历史记录用到的indicator

 @return 下拉加载历史消息时用的UIActivityIndicatorView类型的view
 */
- (UIActivityIndicatorView *)getIndicatorView;

#pragma mark 滑动到表格最下面的数据

/**
 滑动到表格最下面的数据
 */
-(void)scrollToEnd;

/**
 根据消息id，得到数组下标

 @param msgId 
 @return 这个消息对应的消息记录在数组中的下标 如果没有则返回-1
 */
-(int)getArrayIndexByMsgId:(int)msgId;

/**
 聊天记录修改后，局部刷新

 @param _index 需要刷新的聊天记录的在数组中的下标
 */
-(void)reloadRow:(int)_index;

#pragma mark 点击图片消息，对于收到的消息，如果未下载，点击后开始下载，否则预览图片，如果是发送的消息，那么点击后可预览图片

/**
 给图片消息增加点击事件

 @param cell 图片消息所在cell
 */
-(void)addSingleTapToPicViewOfCell:(UITableViewCell*)cell;


/**
 提示消息已转发、已发送，1s后自动消失
 */
- (void)showTransferTips;

// 0915 取得会话id

/**
 返回当前会话的convId

 @return 当前会话的convId
 */
-(NSString *)getConvid;

#pragma mark 播放录音

/**
 播放录音

 @param pathStr 录音文件路径
 */
-(void)playAudio:(NSString*)pathStr;

#pragma mark 停止播放录音

/**
 停止播放语音文件

 @return true 停止成功 false停止失败
 */
-(bool)stopPlayAudio;

/**
 当有子菜单时 显示背景，这样点击背景可以使子菜单消失
 */
- (void)displayTableBackGroudButtonForHiddenSubMenu;

/**
 给机器人发送一条文本消息

 @param msg 要发送的消息
 */
- (void)sendMsgToRobot:(NSString *)msg;

#pragma 根据数组的下标，得到indexPath

/**
 根据消息在数组中的位置获取对应的cell indexpath

 @param index 数组的下标
 @return 这个下标的消息对应的表格中的indexPath
 */
-(NSIndexPath*)getIndexPathByIndex:(int)index;

//

/**
 准备要预览的图片信息 如果参数不为空，那么需要返回所在的位置，否则返回-1

 @param convRecord 用户点击的某一条图片消息
 @return 这条图片消息在所有图片消息中的位置
 */
- (int)prepareGalleryData:(ConvRecord *)convRecord;


/**
 转发文件消息 首先判断文件在服务器端是否有效，如果无效则从本地上传，如果本地也没有，就发送失败

 @param _convRecord 要转发的文件消息
 */
- (void)sendForwardFileMsg:(ConvRecord *)_convRecord;


/**
 从数据库获取聊天记录时，是分次获取的，如果大于0，那么就还有没有显示的消息，如果等于0，就是已经显示所有消息

 @return 0 已经显示所有消息，大于0，还有消息未显示
 */
- (int)getOffset;

#pragma mark 输入文本信息，单击发送，以及图片或录音传输成功后，通过此方法，发出消息，主要是数据库操作和发送到服务器

/**
 发出消息，对于文本消息，是先保存到数据库再发送给服务器 对于其他类型消息，比如图片、主要是数据库操作和发送到服务器

 @param iMsgType 消息类型 可以是文本、图片、语音、长消息、文件
 @param messageStr 对于文本消息，是要发送的文本内容；对于其它类型，则是上传到文件服务器后对应的url
 @param fsize 文件大小，对于语音是指录音秒数；对于其它文件类型，是指文件的大小
 @param fname 文件的名称 对于图片是xxx.png 对应语音是xxx.amr 对于长文件是xxx.txt 对于文件则是真正的文件的名字
 @param oldMsgId 对于文本消息为空；对于其它类型消息，则传保存在数据库时的id，因为其它类型消息都是先保存再上传，上传成功后再发送的，所以传这个id，是为了从数据库找到这条消息，发送给服务器
 */
-(void)sendMessage:(int)iMsgType message:(NSString *)messageStr filesize:(int)fsize filename:(NSString *)fname andOldMsgId:(NSString*)oldMsgId;

#pragma mark 自动下载缩率图

/**
 自动下载图片的小图

 @param cell 小图所在cell
 @param recordObject 图片消息对应的消息model
 */
- (void)autoDownloadSmallPic:(UITableViewCell*)cell andConvRecord:(ConvRecord *)recordObject;


/**
 如果用户设置了隐私，不允许访问图片库，那么用户想发送图片时，就会提示用户
 */
+ (void)showCanNotAccessPhotos;

//在界面上增加一条记录

/**
 显示一条消息在聊天界面里

 @param _convRecord 消息模型
 @param isScrollToEnd 是否滑动到最后
 */
-(void)addOneRecord:(ConvRecord*)_convRecord andScrollToEnd:(bool)isScrollToEnd;


/**
 外部文件保存到云盘

 @param _convRecord 先把外部文件保存到消息模型里，然后保存到云盘
 */
- (void)externalSavedTocloud:(NSMutableArray *)_convRecord;

/**
 根据indexPath找到消息对应的model的下标

 @param indexPath cell的indexPath
 @return indexpath对应cell的对应模型的下标
 */
-(int)getIndexByIndexPath:(NSIndexPath*)indexPath;


/**
 预览云文件

 @param url 云文件对应的url
 */
- (void)previewTheCloudFile:(NSString *)url;

/**
 获取消息总数量

 @param convId 会话id
 @return 此会话收发的消息总数量
 */
-(int)getConvRecordCountBy:(NSString*)convId;

#pragma mark 确定本条记录是否显示时间
-(void)setTimeDisplay:(ConvRecord*)_convRecord  andIndex:(int)_index;

- (void)setInfoViewFrame:(BOOL)isDown;

/** 回到普通消息状态 蓝光红包的位置消息不需要回执功能*/
- (void)setConvStatusToNormal;

@end
