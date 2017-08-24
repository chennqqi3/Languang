
//服务器配置 add by shisp

#import <Foundation/Foundation.h>

@interface ServerConfig : NSObject
{
	NSString *_primarServer;
	int _primarPort;

	NSString *_secondServer;
	int _secondPort;
    
    NSString *_otherServer;
    int _otherPort;
	
	NSString *_fileServer;
	int _fileServerPort;
	NSString *_fileServerUrl;
}

/** 主服务器地址 */
@property (nonatomic,retain) NSString *primaryServer;
/** 主服务器端口 */
@property (nonatomic,assign) int primaryPort;
/** 次服务器地址 */
@property (nonatomic,retain) NSString *secondServer;
/** 次服务器端口 */
@property (nonatomic,assign) int secondPort;
/** 其他服务器地址 */
@property (nonatomic,retain) NSString *otherServer;
/** 其他服务器端口 */
@property (nonatomic,assign) int otherPort;
/** 文件服务器地址 */
@property (nonatomic,retain) NSString *fileServer;
/** 文件服务器端口 */
@property (nonatomic,assign) int fileServerPort;
/** 文件服务器路径 */
@property (nonatomic,retain) NSString *fileServerUrl;
/** 鉴权url（泰禾使用） */
@property (nonatomic,retain) NSString *SSOServerUrl;
/** OA服务器地址（暂未用到） */
@property (nonatomic,retain) NSString *OAServerUrl;


/**
 获取ServerConfig实例

 @return ServerConfig实例对象
 */
+(ServerConfig*)shareServerConfig;

/**
 同步轻应用的请求url

 @param userid   用户id
 @param userCode 用户code

 @return 拼接后的同步轻应用url字符串
 */
-(NSString*)getApplistRequestUrl:(NSString *)userid andUserCode:(NSString *)userCode;

/**
 获取图片上传url

 @return 拼接后的图片上传url字符串
 */
-(NSString*)getPicUploadUrl;

/**
 获取图片下载url
 
 @return 拼接后的图片下载url字符串
 */
-(NSString*)getPicDownloadUrl;

/**
 获取图片小图下载url
 
 @return 拼接后的图片小图下载url字符串
 */
-(NSString*)getSmallPicDownloadUrl;

/**
 获取新版原图下载url
 
 @return 拼接后的新版原图下载url字符串
 */
-(NSString*)getNewPicDownloadUrl;

/**
 获取新版缩略图下载url
 
 @return 拼接后的新版缩略图下载url字符串
 */
-(NSString*)getNewSmallPicDownloadUrl;

/**
 获取录音上传url
 
 @return 拼接后的录音上传url字符串
 */
-(NSString*)getAudioFileUploadUrl;

/**
 获取录音下载url
 
 @return 拼接后的录音下载url字符串
 */
-(NSString*)getAudioFileDownloadUrl;

/**
 获取文件下载token url

 @return 拼接后的文件下载token的url字符串
 */
-(NSString*)getFileUploadTokenUrl;

/**
 获取文件上传url

 @return 拼接后的文件上传url字符串
 */
- (NSString*)getFileUploadUrl;

/**
 获取文件下载url
 
 @return 拼接后的文件下载url字符串
 */
-(NSString*)getFileDownloadUrl;

/**
 获取头像文件下载url
 
 @return 拼接后的头像文件下载url字符串
 */
-(NSString*)getLogoFileDownloadUrl;

/**
 获取头像文件上传url
 
 @return 拼接后的头像文件上传url字符串
 */
-(NSString*)getLogoFileUploadUrl;

/**
 获取头像大图下载url
 
 @return 拼接后的头像大图下载url字符串
 */
-(NSString*)getBigLogoFileDownloadUrl;

/**
 获取长消息的下载url

 @return 长消息的下载url字符串
 */
-(NSString*)getLongMsgDownloadUrl;

/**
 获取长消息的上传url
 
 @return 长消息的上传url字符串
 */
-(NSString*)getLongMsgUploadUrl;

/**
 获取ios版本更新说明对应的URL

 @return ios版本更新说明对应的URL字符串
 */
-(NSString *)getUpdateInfoUrl;

//（已废弃）add by shisp
-(NSString *)getUpdateUrl;

/**
 获取根据指定empid下载头像的url

 @param empId 员工id字符串

 @return empId对应的头像的下载路径
 */
-(NSString*)getLogoUrlByEmpId:(NSString *)empId;

/**
 获取根据指定empid下载头像原图的url
 
 @param empId 员工id字符串  （type = 0）
 
 @return empId对应的头像原图的下载路径
 */
-(NSString*)getBigLogoUrlByEmpId:(NSString *)empId;

/**
 获取新的上传头像的url

 @param newTimestamp 当前服务器时间戳

 @return 新的上传头像的url字符串
 */
- (NSString *)getWandaLogoUploadUrlWithNewTimestamp:(int)newTimestamp;

/**
 获取数据库文件的下载地址

 @return 数据库文件下载的地址
 */
- (NSString *)getOrgDbDownloadUrl;

/**
 获取数据库文件eCloud_user的下载地址

 @return 获取数据库文件eCloud_user的下载地址
 */
- (NSString *)getOrgUserDbDownloadUrl;

/**
 获取语音转文字访问地址

 @return 获取语音转文本的URL字符串
 */
- (NSString *)getAudioToTxtURL;

/**
 获取小万菜单的URL

 @return 小万菜单url字符串
 */
- (NSString *)getRobotMenuURL;

/**
 获取小万每日主题的URL

 @return 小万每日主题的url字符串
 */
- (NSString *)getRobotTopicURL;

/**
 根据当前bundleid获取分享拓展名称

 @return 根据当前bundleid获取分享拓展名称
 */
- (NSString *)getShareName;

/** （泰禾）
 获取登录界面广告接口url

 @param typeVal  0:登录页   1:首页

 @return 登录界面广告接口url字符串
 */
-(NSString*)getLoginADInfoUrl:(int)typeVal;

/** （泰禾）
 拼接鉴权url前缀、加密后的用户信息、常规路径url

 @param url 正常的访问路径

 @return 拼接鉴权url前缀、加密后的用户信息、常规路径url之后的url字符串
 */
- (NSString *)getAuthPreUrl:(NSString *)url;

/** （泰禾）
 获取 第一次登陆 修改密码界面url

 @return 第一次登录修改密码的url字符串
 */
- (NSString *)getFirstModifyPwdUrl;

/** （泰禾）
 修改密码界面url

 @return 修改密码的url字符串
 */
- (NSString *)getModifyPwdUrl;

/** （泰禾）
 获取sso鉴权url（通过bundleid区分测试环境和生产环境）

 @return sso鉴权url字符串
 */
- (NSString *)getSSOServerUrl;

/** （泰禾）
 获取oa地址url（通过bundleid区分测试环境和生产环境）
 
 @return oa地址url字符串
 */
- (NSString *)getOAServerUrl;

/**（国美）
 获取国美工作界面 轮播图 配置url

 @return 工作界面轮播图配置url字符串
 */
- (NSString *)getGomeAppBannerUrl;

/** 获取文件服务器 */
-(NSString *)getFileServer;

/** 文件服务器协议 http或者https */
- (NSString *)getProtocol;

/** 祥源 获取部门配置权限 url */
- (NSString *)getXYDeptShowConfigUrl;

/** 祥源 获取OA token URL */
- (NSString *)getXYOATokenUrl;

/** 祥源 获取OA 首页 URL */
- (NSString *)getXYOAUrl;

/** 祥源 获取待办URL */
- (NSString *)getXYDAIBANUrl;

/** 祥源 获取祥源修改密码url */
- (NSString *)getXYpassWordUrl;

/** 祥源 通告URL */
- (NSString *)getXYNoticeUrl;

/** 祥源 修改密码成功加载的url*/
- (NSString *)getXYChangePasswordUrl;
@end
