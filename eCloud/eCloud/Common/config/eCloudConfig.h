//
//  eCloudConfig.h
//  TestConfig
//  读取、解析配置文件的程序
//  Created by shisuping on 15-8-11.
//  Copyright (c) 2015年 mimsg. All rights reserved.
//

#import <Foundation/Foundation.h>

//默认的config文件的名字 包含了默认的配置
#define default_config_name @"DefaultConfig"

//每个应用相关的config文件的名字 如果和默认配置不同，则需要在appConfig里配置
#define app_config_name @"AppConfig"

//用户也可在客户端修改服务器地址和端口，修改后保存在沙盒里 deprecated
#define user_config_name @"UserConfig"

//南航要求对plist文件进行加密 这是加密的默认config文件的名字
#define encrypt_default_config_name @"JMDefaultConfig"
//南航要求对plist文件加密，这是默认的南航应用的config文件的名字
#define encrypt_app_config_name @"JMAppConfig"

//服务器 相关配置 对应的key

#define KEY_SERVER_CONFIG @"ServerConfig"

//主服务器地址
#define KEY_PRIMARY_SERVER_URL @"PrimaryServerUrl"
//主服务器ip deprecated
#define KEY_PRIMARY_SERVER_IP @"PrimaryServerIp"
//主服务器端口
#define KEY_PRIMARY_SERVER_PORT @"PrimaryServerPort"

//次服务器地址
#define KEY_SECOND_SERVER_URL @"SecondServerUrl"
//次服务器ip deprecated
#define KEY_SECOND_SERVER_IP @"SecondServerIP"
//次服务器端口
#define KEY_SECOND_SERVER_PORT @"SecondServerPort"

//其它服务器地址 比如机器人服务器等
#define KEY_OTHER_SERVER_URL @"OtherServerUrl"
//其它服务器ip deprecated
#define KEY_OTHER_SERVER_IP @"OtherServerIP"
//其它服务器端口
#define KEY_OTHER_SERVER_PORT @"OtherServerPort"

//文件服务器地址
#define KEY_FILE_SERVER_URL @"FileServerUrl"
//文件服务器端口
#define KEY_FILE_SERVER_PORT @"FileServerPort"
//文件服务器路径
#define KEY_FILE_SERVER_PATH @"FileServerPath"

//是否在移动网络下使用ip连接服务器 deprecated
#define KEY_NEED_CONNECT_BY_IP_IF_GPRS @"NeedConnectByIpIfGPRS"

//是否在登录界面显示 导航栏按钮，可以打开配置服务器界面 deprecated
#define KEY_DISPLAY_SERVER_CONFIG_BUTTON @"DisplayServerConfigButton"

#pragma mark ====业务相关定义====
//引擎 相关的key定义
#define KEY_ENGINE @"Engine"

//是否需要首次登录下载通讯录文件
#define KEY_NEED_DOWNLOAD_ORG_DB @"NeedDownloadOrgDB"
//是否需要同步应用列表
#define KEY_NEED_APPLIST @"NeedApplist"

#define KEY_NEED_SWITCH_FILE_SERVER @"NeedSwitchFileServer"
#define KEY_NEED_ENCRYPTDB @"NeedEncryptDB"

#define KEY_SUPPORT_PUBLIC_SERVICE @"SupportPublicService"

#define KEY_SEARCH_TEXT_MIN_LEN @"SearchTextMinLen"
#define KEY_FACE_PREFIX @"FacePrefix"

#define KEY_MYVIEW_MODE_TYPE @"MyViewModeType"

//头像圆角弧度
#define KEY_USER_LOGO_ROUND_ARC @"UserLogoRoundArc"

//头像上传尺寸定义
#define KEY_UPLOAD_USER_LOGO_WIDTH @"UploadUserLogoWidth"
#define KEY_UPLOAD_USER_LOGO_HEIGTH @"UploadUserLogoHeight"

//是否可以修改用户资料
#define KEY_CAN_MODIFY_USER_INFO @"CanModifyUserInfo"


//是否支持一呼百应功能
#define KEY_SUPPORT_YHBY @"SupportYHBY"

//是否支持回执消息
#define KEY_SUPPORT_RECEIPT_MSG @"SupportReceiptMsg"

//是否需要启动时延迟
#define KEY_DELAY_WHEN_LAUNCH @"DelayWhenLaunch"

//设置背景图片的数量 0915
#define KEY_BACKGROUND_PIC_NUM @"BackgroundPicNum"

//是否支持收藏功能
#define KEY_SUPPORT_COLLECTION @"SupportCollection"

//是否支持广告页功能
#define KEY_SUPPORT_GUIDEPAGES @"SupportGuidePages"

//是否支持保存密码功能
#define KEY_SUPPORT_SAVEPASSWORD @"SupportSavePassword"

//是否支持语音转文字页功能
#define KEY_SUPPORT_AUDIOTOTXT @"SupportAudioToTxt"

//是否支持发送视频功能
#define KEY_SUPPORT_VIDEO @"SupportVideo"

//是否支持消息召回功能
#define KEY_SUPPORT_RECALLMSG @"SupportRecallMsg"

//是否支持位置功能
#define KEY_SUPPORT_SEND_LOCATION @"SupportSendLocation"

/** 是否支持红包功能 */
#define KEY_SUPPORT_SEND_RED_PACKET @"SupportSendRedPacket"

//是否支持分享扩展
#define KEY_SUPPORT_SHARE_EXTENSION @"SupportShareExtension"

//可选升级是否需要弹框提示
#define KEY_NEED_SHOW_ALERT_WHEN_OPTION_UPDATE @"NeedShowAlertWhenOptionUpdate"

//会话列表 导航栏 右键 点击模式
#define KEY_CONTACT_LIST_RIGHT_BTN_CLICK_MODE @"ContactListRightBtnClickMode"
#define KEY_CHAT_MESSAGE_DISPLAY_RECEIPT_MSG_ENTRANCE @"ChatMessageDisplayReceiptMsgEntrance"
#define KEY_CHAT_MESSAGE_DISPLAY_PIC_MSG_ENTRANCE @"ChatMessageDisplayPicMsgEntrance"
#define KEY_CHAT_MESSAGE_DISPLAY_FILE_MSG_ENTRANCE @"ChatMessageDisplayFileMsgEntrance"

//是否需要修复安全漏洞
#define KEY_NEED_FIX_SECURITY_GAP @"NeedFixSecurityGap"

//回执消息是否需要自动发送已读
#define KEY_AUTO_SEND_MSG_READ_OF_HUIZHI_MSG @"AutoSendMsgReadOfHuizhiMsg"

//是否使用约束进行布局
#define KEY_USE_CONSTRAINTS @"UseConstraints"

#define KEY_NEED_IMPORTANT_MSG_SET_TOP @"NeedImportantMsgSetTop"

//是否显示用户状态
#define KEY_NEED_DISPLAY_USER_STATUS @"NeedDisplayUserStatus"

//需要同步部门显示配置
#define KEY_NEED_SYNC_DEPT_SHOW_CONFIG @"NeedSyncDeptShowConfig"

#pragma mark ====组织架构 相关定义====

//组织架构相关
//部门
#define KEY_NEED_CALCULATE_DEPT_SUB_DEPT @"NeedCalculateDeptSubDept"
#define KEY_NEED_CALCULATE_DEPT_PARENT_DEPT @"NeedCalculateDeptParentDept"
#define KEY_NEED_CALCULATE_DEPT_EMP_COUNT @"NeedCalculateDeptEmpCount"
#define KEY_NEED_GET_DEPT_SUB_DEPT_TO_MEMORY @"NeedGetDeptSubDeptToMemory"
#define KEY_NEED_GET_DEPT_PARENT_DEPT_TO_MEMORY @"NeedGetDeptParentDeptToMemory"
#define KEY_NEED_CREATE_DEPT_PINYIN_BY_DEPTNAME @"NeedCreateDeptPinyinByDeptName"

//人员
#define KEY_NEED_CREATE_EMP_PINYIN_BY_EMPNAME @"NeedCreateEmpPinyinByEmpName"
#define KEY_NEED_GET_EMP_SIMPLE_PINYIN_TO_MEMORY @"NeedGetEmpSimplePinyinToMemory"
#define KEY_NEED_GET_EMP_ALL_PINYIN_TO_MEMORY @"NeedGetEmpAllPinyinToMemory"
#define KEY_SEARCH_EMP_BY_LETTER @"SearchEmpByLetter"
#define KEY_SEARCH_EMP_BY_NUMBER @"SearchEmpByNumber"
#define KEY_SEARCH_EMP_BY_SPECIAL_CHAR @"SearchEmpBySpecialChar"
#define KEY_DSP_USERCODE_WHEN_SEARCH_ORG @"DspUserCodeWhenSearchOrg"


//tab bar 定义
#define KEY_TABBAR_DEFINE @"TabBarDefine"
#define KEY_CONVERSATION_INDEX @"ConversationIndex"
#define KEY_ORG_INDEX @"OrgIndex"
#define KEY_MY_INDEX @"MyIndex"
#define KEY_SETTING_INDEX @"SettingIndex"
#define KEY_HOMEPAGE_INDEX @"HomepageIndex"

//设置定义
//是否支持更换语言
#define KEY_SUPPORT_LANGUAGE_SETTING @"SupportLanguageSetting"
//是否支持更换字体
#define KEY_SUPPORT_FONTSTYLE_SETTING @"SupportFontStyleSetting"


@interface eCloudConfig : NSObject

#pragma mark ========服务器========

//主IM服务器域名
@property (nonatomic,retain) NSString *primaryServerUrl;

//主IM服务器IP deprecated
@property (nonatomic,retain) NSString *primaryServerIp;

//主IM服务器端口
@property (nonatomic,retain) NSNumber *primaryServerPort;

//备IM服务器域名
@property (nonatomic,retain) NSString *secondServerUrl;

//备IM服务器IP deprecated
@property (nonatomic,retain) NSString *secondServerIp;

//被IM服务器端口
@property (nonatomic,retain) NSNumber *secondServerPort;

//其它服务器域名
@property (nonatomic,retain) NSString *otherServerUrl;

//其它服务器IP deprecated
@property (nonatomic,retain) NSString *otherServerIp;

//其它服务器端口
@property (nonatomic,retain) NSNumber *otherServerPort;

//文件服务器域名
@property (nonatomic,retain) NSString *fileServerUrl;

//文件服务器端口
@property (nonatomic,retain) NSNumber *fileServerPort;

//文件服务器web路径 默认是/
@property (nonatomic,retain) NSString *fileServerPath;

//使用移动网络时是否 尝试使用ip连接服务器 deprecated
@property (nonatomic,assign) BOOL needConnectByIpIfGPRS;

//是否在登录界面 导航栏右侧 显示 服务器配置按钮
@property (nonatomic,assign) BOOL displayServerConfigButton;

#pragma mark ========引擎========

//第一次登录是否需要下载通讯录文件 默认值NO
@property (nonatomic,assign) BOOL needDownloadOrgDB;

//是否需要同步应用列表 默认值NO
@property (nonatomic,assign) BOOL needApplist;

//是否需要切换文件服务器 有的公司im服务器和文件服务器部署了两套，文件服务器和im服务器保持一致 默认值NO
@property (nonatomic,assign) BOOL needSwitchFileServer;

//是否需要加密数据库 默认值NO
@property (nonatomic,assign) BOOL needEncryptDB;

//是否支持公众号 默认值NO
@property (nonatomic,assign) BOOL supportPublicService;

//搜索会话通讯录时需要输入的字符个数的最小值 默认值1
@property (nonatomic,retain) NSNumber *searchTextMinLen;

//表情前缀 因为不同公司可能使用不同的表情 可以使用不同的表情前缀来区分 默认是face
@property (nonatomic,retain) NSString *facePrefix;

//我的界面的显示方式 默认是0 ,具体可以看 eCloudDefine中 myview_type 的定义
@property (nonatomic,retain) NSNumber *myViewModeType;

//头像圆角弧度 默认是0.1
@property (nonatomic,retain) NSNumber *userLogoRoundArc;

//上传头像的宽度 默认是300
@property (nonatomic,retain) NSNumber *uploadUserLogoWidth;

//上传头像的高度 默认是400
@property (nonatomic,retain) NSNumber *uploadUserLogoHeight;

//是否允许修改用户资料 默认值NO
@property (nonatomic,assign) BOOL canModifyUserInfo;

//是否支持一呼百应功能 deprecated
@property (nonatomic,assign) BOOL supportYHBY;

//是否支持回执消息 默认值NO
@property (nonatomic,assign) BOOL supportReceiptMsg;

//程序启动时是否需要延迟 默认值NO
@property (nonatomic,assign) BOOL delayWhenLaunch;

//是否支持收藏功能 默认值NO
@property (nonatomic,assign) BOOL supportCollection;

//是否支持广告页 默认值No
@property (nonatomic,assign) BOOL supportGuidePages;

//是否支持保存密码 默认值NO
@property (nonatomic,assign) BOOL supportSavePassword;

//是否支持语音转文字 默认值NO
@property (nonatomic,assign) BOOL supportAudioToTxt;

//是否支持视频消息 默认值NO
@property (nonatomic,assign) BOOL supportVideo;

//是否支持发送我的位置 默认值NO
@property (nonatomic,assign) BOOL supportSendLocation;

//是否支持发送我的位置 默认值NO
@property (nonatomic,assign) BOOL supportSendRedPacket;

//是否支持扩展分享 默认值NO
@property (nonatomic,assign) BOOL supportShareExtension;

//是否支持回执消息
@property (nonatomic,assign) BOOL supportRecallMsg;

//可选升级的时候是否每次都提示用户
@property (nonatomic,assign) BOOL needShowAlertWhenOptionUpdate;

//会话列表界面 导航栏 右侧按钮 点击操作 模式
@property (nonatomic,assign) int contactListRightBtnClickMode;

//聊天资料界面是否显示回执消息入口 deprecated
@property (nonatomic,assign) BOOL chatMessageDisplayReceiptMsgEntrance;

//聊天资料界面是否显示图片消息入口 万达使用
@property (nonatomic,assign) BOOL chatMessageDisplayPicMsgEntrance;
//聊天资料界面是否显示文件类型消息入口 万达使用
@property (nonatomic,assign) BOOL chatMessageDisplayFileMsgEntrance;

//是否需要修复安全问题 南航修复了安全问题
@property (nonatomic,assign) BOOL needFixSecurityGap;

//对于回执消息是手动点击发送回执，还是自动发送回执
@property (nonatomic,assign) BOOL autoSendMsgReadOfHuizhiMsg;

//deprecated
@property (nonatomic,assign) BOOL useContraints;

//未读的回执消息、@消息是否置顶
@property (nonatomic,assign) BOOL needImportantMsgSetTop;

//是否显示用户状态 默认是YES
@property (nonatomic,assign) BOOL needDisplayUserStatus;

@property (nonatomic,assign) BOOL needSyncDeptShowConfig;

#pragma mark ========组织架构========

//是否计算部门的子部门
@property (nonatomic,assign) BOOL needCalculateDeptSubDept;

//是否需要计算部门的父部门
@property (nonatomic,assign) BOOL needCalculateDeptParentDept;

//是否需要计算部门的人数
@property (nonatomic,assign) BOOL needCalculateDeptEmpCount;

//是否需要把部门的子部门获取到内存
@property (nonatomic,assign) BOOL needGetDeptSubDeptToMemory;

//是否需要把部门的父部门获取到内存
@property (nonatomic,assign) BOOL needGetDeptParentDeptToMemory;

//是否需要根据部门名称生成部门拼音
@property (nonatomic,assign) BOOL needCreateDeptPinyinByDeptName;

//是否需要根据人员名称生成人员拼音
@property (nonatomic,assign) BOOL needCreateEmpPinyinByEmpName;

//是否需要把人员简拼取到内存
@property (nonatomic,assign) BOOL needGetEmpSimplePinyinToMemory;

//是否需要把人员全拼取到内存
@property (nonatomic,assign) BOOL needGetEmpAllPinyinToMemory;

//如果查询条件以字母开头，那么查询时匹配哪些属性
@property (nonatomic,retain) NSNumber *searchEmpByLetter;

//如果查询条件以数字开头，那么查询时匹配哪些属性
@property (nonatomic,retain) NSNumber *searchEmpByNumber;


//如果查询条件以特殊字符开头，那么查询时匹配哪些属性
@property (nonatomic,retain) NSNumber *searchEmpBySpecialChar;

//搜索通讯录时是否在名字后面加上人员的账号
@property (nonatomic,assign) BOOL dspUserCodeWhenSearchOrg;

/** 是否搜索部门 */
#define KEY_NEED_SEARCH_DEPT @"NeedSearchDept"
@property (nonatomic,assign) BOOL needSearchDept;

/** 是否支持手机号搜索人员 */
#define KEY_SUPPORT_SEARCH_BY_PHONE @"SupportSearchByPhone"
@property (nonatomic,assign) BOOL supportSearchByPhone;

/** 是否支持职位搜索人员 */
#define KEY_SUPPORT_SEARCH_BY_TITLE @"SupportSearchByTitle"
@property (nonatomic,assign) BOOL supportSearchByTitle;

/** 没有头像时，是否使用名字作为头像 */
#define KEY_USE_NAME_AS_LOGO @"UseNameAsLogo"
@property (nonatomic,assign) BOOL useNameAsLogo;

/** 使用用户原始头像 不拉伸 */
#define KEY_USE_ORIGIN_USER_LOGO @"UseOriginUserLogo"

@property (nonatomic,assign) BOOL useOriginUserLogo;


#pragma mark ========Tabbar 相关==========

//会话列表界面的tabbarIndex 默认是0
@property (nonatomic,assign) int conversationIndex;

//通讯录界面的tabbarIndex 默认是1
@property (nonatomic,assign) int orgIndex;

//应用界面的tabbarIndex 默认是2
@property (nonatomic,assign) int myIndex;

//设置界面的tabbarIndex 默认是3
@property (nonatomic,assign) int settingIndex;

//设置界面的tabbarIndex 默认是4
@property (nonatomic,assign) int homepageIndex;

#pragma mark ========设置 相关========
//是否支持语言设置
@property (nonatomic,assign) BOOL supportLanguageSetting;
//是否支持字体设置 deprecated
@property (nonatomic,assign) BOOL supportFontStyleSetting;

//默认聊天背景图片的张数 默认是2张
@property (nonatomic,retain) NSNumber *backgroundPicNum;


#pragma mark ========UI相关=========
/** 是否显示水印 */
#define KEY_NEED_WATERMARK @"NeedWaterMark"
@property (nonatomic,assign) BOOL needWaterMark;

/** 是否使用圆形头像 UserLogoRoundArc 这个属性的值如果是0.5 则代表使用的是圆形头像*/
@property (nonatomic,assign) BOOL isUserLogoCircle;

/** 在其它端登录后是否回到登录页 */
#define KEY_BACK_TO_LOGIN_WHEN_LOGIN_OTHER_TERMINAL @"BackToLoginWhenLoginOtherTerminal"
@property (nonatomic,assign) BOOL backToLoginWhenLoginOtherTerminal;

/** 被禁用后，是否回到登录页 */
#define KEY_BACK_TO_LOGIN_WHEN_FORBIDDEN @"BackToLoginWhenForbidden"
@property (nonatomic,assign) BOOL backToLoginWhenForbidden;

/** 是否使用 新的表情配置 如果facePrefix 配置为 newface 那么就是要新的表情 */
@property (nonatomic,assign) BOOL useNewFaceDefine;

+ (eCloudConfig *)getConfig;

- (void)loadConfig;

//提供一个方法 用户编辑了服务器配置后，保存在用户目录下的配置文件里
- (void)saveUserConfig:(NSDictionary *)dic;

@end
