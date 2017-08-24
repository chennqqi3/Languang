//
//  StringUtil.h
//  eCloud
//
//  Created by robert on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Emp.h"

// 保存头像的时候 取时间戳为0；获取头像的时候也使用时间戳0获取
#define default_emp_logo @"0"
//不加密的数据库 只包含了组织架构相关的库
//#define zip_db_name @"eCloud.zip"
// 南航要求 的 数据库 压缩 文件的名字
#define csair_encrypt_zip_db_name @"contactdb_ios.zip"
// 加密的数据库 压缩文件的名字
#define encrypt_zip_db_name @"eCloud_encrypt.zip"
// 万达二期数据库文件名字
#define wanda2_encrypt_zip_db_name @"eCloud_encrypt_wanda2.zip"
// 不加密的数据库 但是zip里包含了两个数据库文件
#define not_encrypt_zip_db_name @"eCloud_not_encrypt.zip"
// 数据库解压密码
//#define zip_db_password @"123456"
#define zip_db_password @"WDWangXin889"
// 头像文件夹名称
#define logo_path @"logo"
// 接收的文件的文件夹名称
#define rcv_file_path @"receiveFile"
// 接收文件的临时文件夹名称
#define rcv_file_temp_path @"receiveTempFile"
// 版本更新说明文件夹名称
#define update_info_file_path @"updateInfo"
// 木棉同飞文件夹名称
#define kapok_file_path @"kapokFile"
// 轻应用图标文件夹名称
#define app_icon_path @"appIcons"
// 聊天背景文件文件夹名称
#define chat_backgroud_file_path @"chatBackgroud"

#define md5_password @"wanxin@`!321^&*"


@class Conversation;

@interface StringUtil : NSObject

/**
 获取应用Documents目录

 @return home路径字符串
 */
+ (NSString *)getHomeDir;

/**
 获取receiveFile目录

 @return 路径字符串
 */
+ (NSString *)getGuideImagePath;

/**
 获取临时文件路径

 @return 路劲字符串
 */
+ (NSString *)getTempDir;

/**
 日志文件的名称及路径

 @return 路径字符串
 */
+(NSString*)getLogFilePath;

/**
 获取文件保存的路径

 @return 路径字符串
 */
+(NSString*)getFileDir;

/**
 根据头像字符串，获取头像所在路径

 @param empLogo 员工头像字符串

 @return 路径字符串
 */
+(NSString*)getEmpLogoPath:(NSString*)empLogo;

/**
 获取位置图片路径

 @param latitude  纬度
 @param longitude 经度

 @return 路径字符串
 */
+(NSString*)getMapPath:(NSString*)latitude withLongitude:(NSString*)longitude;

/**
 异步下载头像，下载成功后，保存在本地，增加一个参数是否保存头像url

 @param empId       员工id
 @param logo        时间戳，这里用"0"
 @param needSaveUrl 是否需要保存
 */
+(void)downloadUserLogo:(NSString*)empId andLogo:(NSString*)logo andNeedSaveUrl:(bool)needSaveUrl;

/**
 头像下载成功后，发出头像修改通知 add by shisp

 @param dic 通知字典内容
 */
+ (void)sendUserlogoChangeNotification:(NSDictionary *)dic;

/**
 删除文件

 @param filePath 文件路径
 */
+(void)deleteFile:(NSString*)filePath;

/**
 创建指定路径的文件夹

 @param path 文件夹路径

 @return YES: 成功 NO: 失败
 */
+ (bool)createFolderForPath:(NSString *)path;

/**
 判断用户输入的是字母、数字、汉字或其他

 @param searchStr 用户输入的查询条件
 @return 返回条件类型
 */
+ (int)getSearchStrType:(NSString *)searchStr;

/**
 返回int值对应的string add by shisp

 @param value 整形

 @return 整形对应的字符串
 */
+(NSString *)getStringValue:(int)value;

/**
 获取当前时间

 @return 时间戳字符串
 */
+(NSString *)currentTime;

/**
 获取显示给用户的日期

 @param interval 时间戳

 @return 格式化后的日期字符串（年-月-日 星期）
 */
+(NSString*)getDisplayTime_day:(NSString*)interval;

/**
 获取显示给用户的日期

 @param interval 时间戳

 @return 格式化后的日期字符串（小时-分钟）
 */
+(NSString*)getDisplayTime_time:(NSString*)interval;

/**
 木棉童飞

 @return 路径字符串
 */
+(NSString*)newKapokPath;

/**
 更换背景图片

 @return 背景路径字符串
 */
+(NSString*)newChatBackgroudPath;

/**
 获取应用图标路径

 @param appid 应用id

 @return 路径字符串
 */
+(NSString*)newAppIconPathWithAppid:(NSString *)appid;

/**
 获取显示给用户的日期

 @param interval 时间戳

 @return 格式化后的日期字符串
 */
+(NSString*)getDisplayTime:(NSString*)interval;

/**
 参考微信，优化最后一条消息的时间

 @param interval 时间戳

 @return 格式化后的日期字符串
 */
+(NSString*)getLastMessageDisplayTime:(NSString*)interval;

/**
 判断是否是邮箱格式的字符串

 @param value 需处理的字符串

 @return YES: 是 NO: 否
 */
+ (BOOL)isEmail:(NSString *)value;

/**
 根据服务端的状态更改为客户端的状态

 @param serverStatus 服务器端状态值 0 离线 1 在线 2 离开 3 退出

 @return 客户端端状态：0 在线 1 离开 2 离线 3 退出
 */
+(NSString*)getClientStatusByServerStatus:(int)serverStatus;

/**
 根据客户端的状态得到服务器端对应状态的值

 @param clientStatus 客户端状态（参考eCloudDefine.h中的userStatus枚举）

 @return 服务器的状态值
 */
+(int)getServerStatusByClientStatus:(int)clientStatus;

/**
 取得显示的文件大小 add by shisp

 @param fileSize 文件大小

 @return xxB、xxK、xxM、xxG的字符串
 */
+(NSString *)getDisplayFileSize:(int)fileSize;

/**
 分割消息

 @param message 消息字符串
 @param array   消息分割后保存在数组
 */
+(void)seperateMsg:(NSString *)message andImageArray:(NSMutableArray *)array;

/**
 16进制字符串转颜色 #2597d9

 @param stringToConvert 16进制字符串

 @return 颜色值
 */
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

/**
 计算消息长度，包括字体部分

 @param msg 消息字符串

 @return 消息字符串的长度
 */
+(int)getMsgLen:(NSString *)msg;

/**
 判断用户输入的是字母，数字还是中文

 @param str 需处理的字符串

 @return 类别(具体含义参考eCloudDefine.h中的textType枚举)
 */
+(int)getStringType:(NSString*)str;

/**
 查看用户的头像有没有下载下来，如果有就先删除

 @param empId 员工id
 */
+(void)deleteUserLogoIfExist:(NSString*)empId;

/**
 根据用户id，用户头像url，获取头像路径
 
 @param empId 员工id
 @param logo  头像时间戳，这里用"0"
 
 @return 头像路径
 */
+(NSString*)getLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo;
#pragma mark

/**
 根据用户id，用户头像url，获取大头像路径

 @param empId 员工id
 @param logo  头像时间戳，这里用"0"

 @return 头像路径
 */
+(NSString*)getBigLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo;

/**
 根据用户id，用户头像url，获取离线头像路径

 @param empId 员工id
 @param logo  头像时间戳，这里用"0"

 @return 头像路径
 */
+(NSString*)getOfflineLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo;

/**
 获取资源路径

 @param name 资源名称
 @param type 资源类型

 @return 资源路径对应的字符串
 */
+(NSString *)getResPath:(NSString*)name andType:(NSString*)type;

/**
 去掉字符串两边的空格

 @param str 原始字符串

 @return 处理后的字符串
 */
+(NSString*)trimString:(NSString*)str;

/**
 一呼百应消息已读时间显示

 @param interval 时间戳

 @return 格式后的日期字符串
 */
+(NSString*)getDisplayTimeOfMsgRead:(int)interval;

/**
 根据时间，返回一个日期值，用于单个图文推送信息的日期显示

 @param interval 时间戳

 @return "MM月dd日"格式的字符串
 */
+(NSString*)getSinglePsMsgDate:(int)interval;

/**
 遍历文件目录，如果是头像文件，那么移到头像目录下，如果是其他文件则移到收到的文件目录下，首先需要创建目录
 */
+(void)transferFileToNewDir;

/**
 用户头像的路径

 @return 头像路径字符串
 */
+(NSString*)newLogoPath;

/**
 接收的文件路径

 @return 路径字符串
 */
+(NSString*)newRcvFilePath;

/**
 文件缓存路径

 @return 路径字符串
 */
+(NSString*)newRcvFileTemPath;

/**
 新建目录，保存版本的更新说明  add by shisp

 @return 目录路径字符串
 */
+(NSString*)getUpdateInfoFilePath;

/**
 下载更新信息  add by shisp
 */
+(void)downloadUpdateInfo;

/**
 获取应用名称  add by shisp

 @return 应用名称字符串
 */
+ (NSString *)getAppName;

/**
 截取文件名

 @param NSString 文件名

 @return 文件名字符串
 */
+ (NSString *)getProperFileName:(NSString *)filenane;

/**
 把一个整形值转换为2进制字符串，后面是字节数  add by shisp

 @param input 整形
 @param count 1：8位显示   2：16位显示

 @return 2进行字符串
 */
+ (NSString *)toBinaryStr:(int)input andByteCount:(int)count;

/**
 c字符串转oc字符串

 @param data c字符串

 @return oc字符串
 */
+(NSString*)getStringByCString:(char*)data;

/**
 oc字符串转c字符串

 @param str oc字符串

 @return c字符串
 */
+ (char *)getCStringByString:(NSString *)str;

/**
 获取文件路径的md5
 
 @param path 文件路径
 
 @return md5字符串
 */
+(NSString*)getFileMD5WithPath:(NSString*)path;

/**
 获取超时时长

 @return wifi下:30   gprs下:60
 */
+ (int)getRequestTimeout;

/**
 获取Localizable.strings文件中指定key的值

 @param key key值

 @return key值对应的value字符串
 */
+(NSString *)getLocalizableString:(NSString *) key;

/**
 字符串长度

 @param string 需要处理的字符串

 @return 字符串的长度（中文占3个字符长度）
 */
+(NSUInteger) lenghtWithString:(NSString *)string;

/**
 获取新的群组名称
 注：grpName里有汉字也有其他字符，如果是汉字要占用3个长度，否则只占一个长度，总长度要小于等于grpName的总长度

 @param grpName 群组名称

 @return 不超过群组名称最大限制长度的新的群组名称
 */
+ (NSString *)getNewGrpName:(NSString *)grpName;

/**
 获取plist文件中CFBundleShortVersionString的值

 @return CFBundleShortVersionString对应的value字符串
 */
+ (NSString *)getAppVersion;

/**
 获取plist文件中AppReleaseDate的值

 @return AppReleaseDate对应的value字符串
 */
+ (NSString *)getAppReleaseDate;

/*********************当前可用内存 本应用已使用内存 相关方法  start***********************/
/**
 获取当前设备可用内存(单位：MB）
 */
+ (void)availableMemory;

/**
 获取当前任务所占用的内存（单位：MB）
 */
+ (void)usedMemory;

/**
 下载大头像

 @param empId   员工id
 @param empLogo 头像时间戳，这里用"0"
 */
+ (void)downloadBigUserLogoByEmpId:(NSString *)empId andEmpLogo:(NSString *)empLogo;

/**
 获取文件默认图片

 @param fileName 文件名称

 @return 图像
 */
+(UIImage *)getFileDefaultImage:(NSString *)fileName;
/*********************当前可用内存 本应用已使用内存  end***********************/

/*********************下载 包含通讯录的数据库文件 相关方法  start***********************/
/**
 获取数据库路径的方法

 @return 路径字符串
 */
+ (NSString *)getDataDbFilePath;

/**
 下载ecloud_user数据库 后的保存路径

 @return 路径字符串
 */
+ (NSString *)getDownloadecloudUserDbPath;
/*********************下载 包含通讯录的数据库文件 相关方法  end***********************/

/*********************数据库压缩，解压缩相关  start***********************/
/**
 压缩数据库
 */
+ (void)zipDb;

/**
 解压缩数据库文件

 @return YES: 解压成功 NO:解压失败
 */
+ (BOOL)unzipDb;

/**
 获取压缩数据库文件的路径

 @return 路径字符串
 */
+ (NSString *)getZipDbFilePath;
/*********************数据库压缩，解压缩相关  end***********************/

/*********************用户微头像 群组合成头像  start***********************/
/**
 获取微头像的路径的方法  add by shisp

 @param empId 员工id
 @param logo  头像时间戳，这里用"0"

 @return 头像的本地文件路径字符串
 */
+ (NSString*)getMicroLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo;

/**
 生成并保存微头像

 @param curImage 当前图像
 @param empId    员工id
 @param logo     头像时间戳，这里用"0"
 */
+ (void)createAndSaveMicroLogo:(UIImage *)curImage andEmpId:(NSString *)empId andLogo:(NSString *)logo;

/**
 根据大头像生成并保存小头像，大头像下载后，同时生成小头像，避免大小头像不一致的情况

 @param curImage 当前图像
 @param empId    员工id
 @param logo     头像时间戳，这里用"0"
 */
+ (void)createAndSaveSmallLogo:(UIImage *)curImage andEmpId:(NSString *)empId andLogo:(NSString *)logo;

/**
 根据名字删除群组合成头像

 @param logoName 头像名称
 */
+ (void)deleteMergedGroupLogoByName:(NSString *)logoName;

/**
 根据名字得到群组合成头像的路径

 @param logoName 头像名称

 @return 头像路径
 */
+ (NSString *)getMergedGroupLogoPathWithName:(NSString *)logoName;

/**
 群组合成头像的名字，按照一定的规则生成合成头像的名字，包括每个小头像的id，以及是默认头像还是用户自己的头像

 @param conv 会话

 @return 头像名称字符串
 */
+ (NSString *)getDetailMergedGroupLogoName:(Conversation *)conv;

/**
 因为通用的下载头像的方法 增加了一个状态的判断，所以登录成功后，下载当前登录用户的头像，就要提供一个单独的方法
 */
+ (void)downloadCurUserLogo;
/*********************用户微头像 群组合成头像  end***********************/

/**
 获取设备硬件类型

 @return 硬件名称
 */
+ (NSString *)machineName;

/*********************上传用到  start***********************/
/**
 原有的URL后面增加：
 uid:用户ID
 t: 客户端校正后的时间戳，自1970年的到现在的秒
 guid:客户端生成的唯一ID,32位字符串
 沟通后改为：1970年到现在的毫秒
 文件名保留老的：上传方式
 mdkey:各字段拼成字符串，进行MD5加密
 md5(文件名+uid+t+guid+密钥key)  小写32字符的md5串
 密钥:wanxin@`!321^&*
 例如：filename=abc.jpg
 oldurl&uid=11221&t=141212112&guid=12345&mdkey= 845656cb19676583a7936537604803f1

 @param fileName 文件名称

 @return 拼接后的参数如：&uid=11221&t=141212112&guid=12345&mdkey= 845656cb19676583a7936537604803f1
 */
+ (NSString *)getUploadAddStr:(NSString *)fileName;
/*********************上传用到  end***********************/

/*********************下载用到  start***********************/
/**
 原有的URL后面增加：
 uid:发请求的用户ID
 t: 客户端校正后的时间戳，自1970年的的秒
 guid:客户端生成的唯一ID
 沟通后改为：1970年到现在的毫秒
 mdkey:md5(文件key+uid+t+guid+密钥key)  小写32字符的md5串
 原有文件的key：例如 2uyaee
 密钥:wanxin@`!321^&*
 例如：
 oldurl&uid=11221&t=141212112&guid=12345&mdkey= 75b9341d2cce6baa9d86a915ee0895d3

 @param fileURL 文件url字符串

 @return 拼接后的参数如：&uid=11221&t=141212112&guid=12345&mdkey= 75b9341d2cce6baa9d86a915ee0895d3
 */
+ (NSString *)getDownloadAddStr:(NSString *)fileURL;
/*********************下载用到  end***********************/

/**
 从图片的URL中得到图片对应的key

 @param picUrl 图片url字符串

 @return key字符串
 */
+ (NSString *)getKeyStrOfPicUrl:(NSString *)picUrl;

/**
 本地时间毫秒数

 @return 毫秒数
 */
+(long long)currentMillionSecond;

/**
 （暂时未用）
 解析full_dept_201502021513.txt文件中的部门信息
 将
  部门ID|父部门ID|部门中文名称|部门英文名称|更新类型|部门排序|部门电话
 放到字典进而放入数组中
 */
+ (void)parseOrgData;

/**
 判断是否有网络

 @return YES:有网络 NO:无网络
 */
+ (BOOL)isNetworkOK;

/**
 拼接文件上传需要的一些参数

 @return 部分参数字符串
 */
+ (NSString *)getResumeUploadAddStr;

/**
 拼接文件下载需要的一些参数

 @return 部分参数字符串
 */
+ (NSString *)getResumeDownloadAddStr;

/**
 删除多余的日志文件
 */
+ (void)clearLogFile;

/**
 获取静态库里面的资源bundle

 @return budle
 */
+ (NSBundle *)getBundle;

//add by shisp
//目前有很多公司在试用，试用公司会要求修改应用名称，所以应用名称不能写死，而是应该获取打包时的应用的名称
//界面上有些地方使用到了应用的名称，所以这些地方不能写死在localizable.strings里，现在提供一个方法返回在界面上显示的内容
+ (NSString *)getLocalStringRelatedWithAppNameByKey:(NSString *)key;

+ (NSString *)getZipDbName;

/**
 获取和每个应用相关的界面提示

 @param key AppLocalized.strings或Localizable.strings中对应的key值

 @return key值对应的value
 */
+(NSString *)getAppLocalizableString:(NSString *) key;

/**
 根据图片名字，得到对应的UIImage对象

 @param resName 图片名称

 @return 图像
 */
+ (UIImage *)getImageByResName:(NSString *)resName;

/**
 根据视频url,得到视频名称
 
 @param videoUrl 视频url
 
 @return 视频
 */
+ (NSString *)getVideoNameByVideoUrl:(NSString *)videoUrl;

/**
 根据音频URL，得到音频名称
 
 @param audioUrl 音频url
 
 @return 音频
 */
+ (NSString *)getAudioNameByAudioUrl:(NSString *)audioUrl;

/**
 根据 图片类型消息的消息体 得到图片对应的URL字符串 有些消息体是[#url.xxx]格式的，有些消息体本身就是一个url，所以这里提供一个方法
 
 @param msgBody 消息类型
 
 @return url
 */
+ (NSString *)getPicMsgUrlByMsgBody:(NSString *)msgBody;

/**
 根据图片url，得到图片名称
 
 @param picUrl 图片url
 
 @return 图片名称
 */
+ (NSString *)getPicNameByPicUrl:(NSString *)picUrl;

/**
 判断一个字符串是否一个URL

 @param str 目标字符串

 @return YES:是url NO:不是url
 */
+ (BOOL)isURL:(NSString *)str;

/**
 如果urlStr没有带http:// 或 https://则附加上http://

 @param strUrl 目标url链接

 @return 带有http:// 或 https://的url字符串
 */
+ (NSString *)formatUrlStr:(NSString *)strUrl;

/**
 判断是否excel文件
 
 @param fileName 文件名字
 
 @return yes or no
 */
+ (BOOL)isExcelFile:(NSString *)fileName;

/**
 （暂时未用到）
 */
+ (void)testJailbreak;

/**
 （暂时未用到）
 递归遍历parentView的子view列表

 @param parentView 目标view
 */
+ (void)listSubView:(UIView *)parentView;

/**
 得到本机现在用的语言

 @return en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
 */
+ (NSString*)getPreferredLanguage;

/**
 获取 小万菜单 和 小万主题时 附加的URL

 @return url字符串
 */
+ (NSString *)getRobotUrlAddStr;

/**
 语音转义测试

 @param fileName 文件名称

 @return 参数拼接
 */
+ (NSString *)getUploadAudioTest:(NSString *)fileName;

/**
 判断是否为音频文件

 @param fileExtensionStr 文件拓展名

 @return YES:是音频文件 NO:不是音频文件
 */
+ (BOOL)isAudioFile:(NSString *)fileExtensionStr;

//

/**
 判断是否为视频文件

 @param fileExtensionStr 文件拓展名

 @return YES:是视频文件 NO:不是视频文件
 */
+ (BOOL)isVideoFile:(NSString *)fileExtensionStr;

/**
 根据消息类型 消息内容 返回显示给用户的提示

 @param msgType 消息类型
 @param msg     消息内容

 @return 提示字符串
 */
+ (NSString *)getUserTipsWithMsgType:(int)msgType andMsg:(NSString *)msg;

/**
 判断消息内容里是否是@用户自己

 @param msgBody 消息内容

 @return YES:包含 NO:不包含
 */
+ (BOOL)isAtLoginUser:(NSString *)msgBody;

/**
 判断消息内容里是否包含了 @all

 @param msgBody 消息内容

 @return YES:包含 NO:不包含
 */
+ (BOOL)isAtAllMsg:(NSString *)msgBody;

//从获取到的结构体里获取群组名称
//+ (NSString *)getGrpNameFromGroupInfo:(GETGROUPINFOACK *)info;

/**
 获取结构体中的群组名称

 @param cGroupName GETGROUPINFOACKe结构体的aszGroupName属性

 @return 群组名称
 */
+ (NSString *)getGrpNameFromCGroupName:(char *)cGroupName;

/**
 获取状态栏的高度

 @return 高度
 */
+ (float)getStatusBarHeight;

/**
 获取plist文件中AppBundleName对应的值

 @return    AppBundleName对应的字符串
 */
+ (NSString *)getAppBundleName;

/**
 获取plist里对于的BaiduMapKey

 @return key字符串
 */
+ (NSString *)getBaiduMapKey;

/**
 获取plist里面对于友盟Key

 @return key字符串
 */
+ (NSString *)getUMSdkKey;

/**
 判断是否为规则数字

 @param string 原始字符串信息

 @return YES:为数字  NO:不是纯数字
 */
+ (BOOL)isPureNumberCharacters:(NSString *)string;

/**
 获取一个随机数字符串

 @return 随机数字符串
 */
+ (NSString *)getRandomString;

/**
 对字符串进行encode处理

 @param string 原始字符串信息

 @return encode之后的字符串
 */
+ (NSString*)encodeURL:(NSString *)string;

/**
 如果是SDK，那么就在info.plist里 增加SDKReleaseDate的配置

 @return plist文件中的SDKReleaseDate对应的value值
 */
+ (NSString *)getSDKReleaseDate;

/**
 判断是否为汉字
 
 @param firstChar 第一个字符
 
 @return YES : 是汉字  NO : 不是汉字
 */
+(bool)isHanzi:(int)firstChar;

/**
 判断是否为字母

 @param firstChar 第一个字符

 @return YES : 字母  NO : 不是字母
 */
+(bool)isLetter:(int)firstChar;

/**
 判断是否为数字

 @param firstChar 第一个字符

 @return YES : 数字  NO : 不是数字
 */
+(bool)isNumber:(int)firstChar;

/**
 小万消息 格式化 去掉 不能在界面上显示的内容

 @param msgBody 会话内容

 @return 格式化处理之后的消息内容
 */
+ (NSString *)formatXiaoWanMsg:(NSString *)msgBody;

/**
 判断是否小万的消息

 @param msgBody 会话内容

 @return YES : 小万信息  NO : 不是小万信息
 */
+ (BOOL)isXiaoWanMsg:(NSString *)msgBody;

/**
 获取机器人相关的文件的路径

 @return 机器人文件路径字符串
 */
+ (NSString *)getRobotFilePath;

/**
 泰禾获取加密前缀

 @return 加密后的参数字符串
 */
+ (NSString *)encryptStr;

/**
 清除网页缓存
 */
+ (void)cleanCacheAndCookie;

/**
 泰禾提醒的title
 
 @return 如果是泰禾，改为泰信提醒
 */
+ (NSString *)getAlertTitle;

/** 是否测试app */
+ (BOOL)isTestApp;

/**
 数组中是否包含该emp

 @param emp Emp对象
 @param arr 要查询的数组
 @return 如果包含就返回下标，没有就返回 -1
 */
+ (int)isContainsEmp:(Emp *)emp WithArray:(NSArray *)arr;


/**
 获取密聊头像

 @param empId 用户ID
 @param logo 传 0
 @return 头像路径
 */
+(NSString*)getProcessLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo;

/** 头像下载完成后 保存在本地 */
+ (void)saveUserLogo:(UIImage *)userLogo andUser:(NSString *)empId;

/** 根据字符串获取MD5 */
+ (NSString *)getMD5Str:(NSString *)strForMD5;


/**
 是否显示电话

 @param empId 用户ID
 @return 是否能显示
 */
+ (BOOL)canShowPhoneNumber:(int)empId;

/**
 功能描述
 根据url获取网页内容
 
 参数 str 需要获取内容的url
 返回值 字典
 */
+ (NSDictionary *)getHtmlText:(NSString *)str;


/**
 获取cell高度

 @param count 元素个数
 @param isShow 是否显示更多按钮
 @return cell高度
 */
+ (CGFloat)getHeightWithItemCount:(NSInteger)count isShowMoreEmp:(BOOL)isShow;


/**
 获取大写的32位MD5字符串

 @param strForMD5 要加密的字符串
 @return 大写的32位MD5字符串
 */
+ (NSString *)getUpperMD5Str:(NSString *)strForMD5;

/**
 添加从左边滑出“更多”按钮的手势
 */
+ (void)addEdgePanGestureRecognizer:(UIViewController *)vc;

@end

