//
//  ServerConfig.m
//  eCloud
//
//  Created by robert on 12-12-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "ServerConfig.h"
#import "eCLoudUser.h"
#import "Emp.h"

#import "StringUtil.h"
#import "conn.h"
#import "client.h"
#import "ApplicationManager.h"
#import "AppDelegate.h"
#import "CRCUtil.h"
#import "UserDefaults.h"
#import "UIAdapterUtil.h"

#import "eCloudConfig.h"

#import "eCloudDefine.h"


@implementation ServerConfig

//@synthesize primaryServer = _primaryServer;
//@synthesize primaryPort = _primaryPort;
//@synthesize secondServer = _secondServer;
//@synthesize secondPort = _secondPort;
//@synthesize fileServer = _fileServer;
//@synthesize fileServerPort = _fileServerPort;
//@synthesize fileServerUrl = _fileServerUrl;

static ServerConfig *_ServerConfig;

+(ServerConfig *)shareServerConfig
{
	if(_ServerConfig == nil)
	{
		_ServerConfig = [[self alloc] init];
	}
	return _ServerConfig;
}
-(void)dealloc
{
	self.primaryServer = nil;
	self.secondServer = nil;
	self.fileServer = nil;
	self.fileServerUrl = nil;
	[super dealloc];
}

-(BOOL)isGPRS
{
    return NO;
    
	int netType = [ApplicationManager getManager].netType;
	if(netType == type_gprs)
	{
		return YES;
	}
	return NO;
}
-(NSString *)getFileServer
{
//    快钱使用的文件服务器和im的服务器保持一致，这个同时兼容万达的版本 add by shisp
    
    if ([[eCloudConfig getConfig]needSwitchFileServer]) {
        return [UserDefaults getCurrentServer];
    }
    else
    {
        return self.fileServer;
    }
//    return default_file_server;
//	if([self isGPRS])
//	{
//		return gprs_file_server_ip;
//	}
//	else
//	{
//		return self.fileServer;
//	}
}
-(NSString*)getApplistRequestUrl:(NSString *)userid andUserCode:(NSString *)userCode
{
    return [NSString stringWithFormat:@"%@//%@:%d/FilesService/appuser?userid=%@&usercode=%@&compid=%d&logintype=%d",[self getProtocol],[self getFileServer],self.fileServerPort,userid,userCode,[UserDefaults getCompId],TERMINAL_IOS];
}
#pragma mark 其中：type=0表示下载原始图；type=1表示下载略缩图。key的值就是上传时返回的字符串
-(NSString*)getPicUploadUrl
{
 	return [NSString stringWithFormat:@"http://%@:%d/image/upload",[self getFileServer],self.fileServerPort];
}
-(NSString*)getPicDownloadUrl
{
	return [NSString stringWithFormat:@"http://%@:%d/image/download?type=0&key=",[self getFileServer],self.fileServerPort];
}
-(NSString*)getSmallPicDownloadUrl
{
	return [NSString stringWithFormat:@"http://%@:%d/image/download?type=1&key=",[self getFileServer],self.fileServerPort];
}

#pragma mark - 新版图片下载URL
-(NSString*)getNewPicDownloadUrl
{
    return [NSString stringWithFormat:@"%@//%@:%d/FilesService/download/?type=1&token=",[self getProtocol],[self getFileServer],self.fileServerPort];
}

-(NSString*)getNewSmallPicDownloadUrl
{
    return [NSString stringWithFormat:@"%@//%@:%d/FilesService/download/?type=2&token=",[self getProtocol],[self getFileServer],self.fileServerPort];
}

#pragma mark 录音的上传，下载和头像的相同
-(NSString*)getAudioFileUploadUrl
{
	return [NSString stringWithFormat:@"http://%@:%d%@fileupload",[self getFileServer],self.fileServerPort,self.fileServerUrl];
}

-(NSString*)getAudioFileDownloadUrl
{
    return [NSString stringWithFormat:@"http://%@:%d%@filedown?key=",[self getFileServer],self.fileServerPort,self.fileServerUrl];

//	return [NSString stringWithFormat:@"http://%@:%d%@file/",[self getFileServer],self.fileServerPort,self.fileServerUrl];
}

-(NSString*)getFileUploadTokenUrl{
    //获取文件下载token url
    return [NSString stringWithFormat:@"%@//%@:%d%@FilesService/",[self getProtocol],[self getFileServer],self.fileServerPort,self.fileServerUrl];
}

- (NSString*)getFileUploadUrl{
    //获取文件上传地址
    return [NSString stringWithFormat:@"%@//%@:%d%@FilesService/upload/",[self getProtocol],[self getFileServer],self.fileServerPort,self.fileServerUrl];
}

- (NSString*)getFileDownloadUrl{
    //获取文件下载地址
    return [NSString stringWithFormat:@"%@//%@:%d%@FilesService/download/",[self getProtocol],[self getFileServer],self.fileServerPort,self.fileServerUrl];
}

-(NSString*)getLogoFileDownloadUrl
{
    return [NSString stringWithFormat:@"http://%@:%d%@album?type=1&key=",[self getFileServer],self.fileServerPort,self.fileServerUrl];
}
-(NSString*)getBigLogoFileDownloadUrl
{
    return [NSString stringWithFormat:@"http://%@:%d%@album?type=0&key=",[self getFileServer],self.fileServerPort,self.fileServerUrl];
}
-(NSString*)getLogoFileUploadUrl
{
	return [self getAudioFileUploadUrl];
}
#pragma mark add by shisp 获取长消息的上传和下载url
-(NSString*)getLongMsgDownloadUrl
{
	return [self getAudioFileDownloadUrl];
}
-(NSString*)getLongMsgUploadUrl
{
	return [self getAudioFileUploadUrl];
}

-(NSString *)getUpdateInfoUrl
{
    conn *_conn = [conn getConn];
    
    return [NSString stringWithFormat:@"http://%@:%d%@ios_%@.txt",[self getFileServer],self.fileServerPort,self.fileServerUrl,_conn.updateVersion];
}

-(NSString *)getUpdateUrl
{
    conn *_conn = [conn getConn];
    
    return [NSString stringWithFormat:@"http://%@:%d%@",[self getFileServer],self.fileServerPort,self.fileServerUrl];
//    return [NSString stringWithFormat:@"http://%@:%d%@iphone.html",[self getFileServer],self.fileServerPort,self.fileServerUrl];
}

//add by shisp 根据empId得到头像的下载路径
//URL:host:port/FilesService/headdown/?srcid=121&type=0&rc=xad&dstid=111
//下载小图 type = 1
-(NSString*)getLogoUrlByEmpId:(NSString *)empId
//{
//    NSString *logoFileName = [NSString stringWithFormat:@"small%@.jpg",empId];//@"ecloud_%@.png"
//    NSString *tempStr = [[NSString stringWithFormat:@"http://%@:%d%@albumt",[self getFileServer],self.fileServerPort,self.fileServerUrl]stringByAppendingPathComponent:logoFileName];
//
//    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,tempStr]];
//
//    return tempStr;
//}
{
    conn *_conn = [conn getConn];
    if (_conn.userId)
    {
        NSString *crcStr = [CRCUtil getCrc8:[NSString stringWithFormat:@"%@%@",_conn.userId,empId]];
        NSString *tempStr = [NSString stringWithFormat:@"%@//%@:%d%@FilesService/headdown?srcid=%@&type=1&rc=%@&dstid=%@",[self getProtocol],[self getLogoServer],[self getLogoServerPort],[self getLogoServerUrl],_conn.userId,crcStr,empId];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,tempStr]];
        
        return tempStr;
    }
    return @"";
}

//下载原图 type = 0
-(NSString*)getBigLogoUrlByEmpId:(NSString *)empId
//{
//    NSString *logoFileName = [NSString stringWithFormat:@"%@.jpg",empId];//@"ecloud_%@.png"
//    return [[NSString stringWithFormat:@"http://%@:%d%@album",[self getFileServer],self.fileServerPort,self.fileServerUrl]stringByAppendingPathComponent:logoFileName];
//}
{
    conn *_conn = [conn getConn];
    if (_conn.userId)
    {
        NSString *crcStr = [CRCUtil getCrc8:[NSString stringWithFormat:@"%@%@",_conn.userId,empId]];
        NSString *tempStr = [NSString stringWithFormat:@"%@//%@:%d%@FilesService/headdown?srcid=%@&type=0&rc=%@&dstid=%@",[self getProtocol],[self getLogoServer],[self getLogoServerPort],[self getLogoServerUrl],_conn.userId,crcStr,empId];
        
                [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,tempStr]];
        
        return tempStr;
    }
    return @"";
}

//add by shisp 新的上传头像的url
//http://host:port//FilesService/headupload/??userid=111&t=1212121212&rc=xad
- (NSString *)getWandaLogoUploadUrlWithNewTimestamp:(int)newTimestamp
{
    conn *_conn = [conn getConn];
    if (_conn.userId)
    {
        NSString *crc = [CRCUtil getCrc8:[NSString stringWithFormat:@"%@%d",_conn.userId,newTimestamp]];
        NSString *tempStr = [NSString stringWithFormat:@"%@//%@:%d%@FilesService/headupload?userid=%@&t=%d&rc=%@",[self getProtocol],[self getLogoServer],[self getLogoServerPort],[self getLogoServerUrl],_conn.userId,newTimestamp,crc];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,tempStr]];
        
        return tempStr;
    }
    return @"";
}

- (NSString *)getLogoServer
{
    return [self getFileServer];
//    return @"124.238.219.85";
}

- (int)getLogoServerPort
{
    return self.fileServerPort;
//    return 80;
}

- (NSString *)getLogoServerUrl
{
    return self.fileServerUrl;
//    return @"/";
}

//获取数据库文件的下载地址
- (NSString *)getOrgDbDownloadUrl
{
    NSString *url = [NSString stringWithFormat:@"%@//%@:%d%@download/%@",[self getProtocol],[self getFileServer],self.fileServerPort,self.fileServerUrl,[StringUtil getZipDbName]];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,url is %@",__FUNCTION__,url]];
    
    return url;
}

//获取数据库文件eCloud_user的下载地址
- (NSString *)getOrgUserDbDownloadUrl
{
    NSString *url = [NSString stringWithFormat:@"http://%@:%d%@download/%@",[self getFileServer],self.fileServerPort,self.fileServerUrl,ecloud_user_db];
    [LogUtil debug:[NSString stringWithFormat:@"%s,url is %@",__FUNCTION__,url]];
    return url;
}

#pragma mark ========返回配置文件中服务器相关的配置==========
- (NSString *)primaryServer
{
    return [eCloudConfig getConfig].primaryServerUrl;
}

- (int)primaryPort
{
    return [eCloudConfig getConfig].primaryServerPort.intValue;
}

- (NSString *)secondServer
{
    return [eCloudConfig getConfig].secondServerUrl;
}

- (int)secondPort
{
    return [eCloudConfig getConfig].secondServerPort.intValue;
}

- (NSString *)otherServer
{
    return [eCloudConfig getConfig].otherServerUrl;
}

- (int)otherPort
{
    return [eCloudConfig getConfig].otherServerPort.intValue;
}

- (NSString *)fileServer
{
    return [eCloudConfig getConfig].fileServerUrl;
}

- (int)fileServerPort
{
    return [eCloudConfig getConfig].fileServerPort.intValue;
}

- (NSString *)fileServerUrl
{
    return [eCloudConfig getConfig].fileServerPath;
}

//获取语音转文本的URL http://ctx.wanda.cn:8090/USCService/usc
- (NSString *)getAudioToTxtURL
{
    return [NSString stringWithFormat:@"http://%@:%d/USCService/usc",[self otherServer],[self otherPort]];
}

//获取小万菜单的URL
- (NSString *)getRobotMenuURL
{
    return [NSString stringWithFormat:@"http://%@:%d/USCService/robotmenu/?",[self otherServer],[self otherPort]];
}

//获取小万每日主题的URL
- (NSString *)getRobotTopicURL
{
    return [NSString stringWithFormat:@"http://%@:%d/USCService/topic/?",[self otherServer],[self otherPort]];
}

- (NSString *)getProtocol
{
    if ([UIAdapterUtil isCsairApp]) {
        return @"https:";
    }
    return @"http:";
}

- (NSString *)getShareName{
    
    NSString *string = [[NSBundle mainBundle]bundleIdentifier];
    if ([string isEqualToString:@"www.longfor.UniXin"]) {
        return @"group.longFor";
    }else{
        return @"group.longfor.UniXin";
    }
}
// 泰禾获取登录界面或首页的广告接口url
// http://im2.tahoecn.com:8080/FilesService/getAdsInfo?type=0
// http://im2.tahoecn.com:8080/FilesService/getAdsInfo?type=1
-(NSString*)getLoginADInfoUrl:(int)typeVal{
    // 0:登录页   1:首页
    return [NSString stringWithFormat:@"%@//%@:%d/FilesService/getAdsInfo?type=%d",[self getProtocol],[self getFileServer],self.fileServerPort,typeVal];
}
// 泰禾后续配置一个鉴权url前缀
- (NSString *)getAuthPreUrl:(NSString *)url{
    NSString *authPre = [NSString stringWithFormat:@"%@?username=", [self getSSOServerUrl]];//@"http://im2.tahoecn.com:9010/TaiheServer/DataService?username=";
    NSString *newAuthUrl = nil;
#ifdef _TAIHE_FLAG_
    newAuthUrl = [NSString stringWithFormat:@"%@%@&url=%@",authPre,[StringUtil encryptStr],url];
#endif
    return newAuthUrl;
}

// 泰禾 第一次登陆 修改密码界面url
- (NSString *)getFirstModifyPwdUrl{
    //http://oa01.tahoecn.com:8080/ekp/taihe/app/welcome.jsp
    
    NSString *oaUrl = [self getOAServerUrl];
    
    NSString *firstModifyPwdUrl = [NSString stringWithFormat:@"%@/taihe/app/welcome.jsp",[self getOAServerUrl]];//@"http://oa01.tahoecn.com:8080/ekp/taihe/app/welcome.jsp";
    
    return [self getAuthPreUrl:firstModifyPwdUrl];
}
// 泰禾 修改密码界面url
- (NSString *)getModifyPwdUrl{
    
    ///taihe/app/changePwd.jsp
    //http://oa01.tahoecn.com:8080/ekp/taihe/app/changeSuccess.jsp

    NSString *oaUrl = [self getOAServerUrl];
    
    NSString *modifyPwdUrl = [NSString stringWithFormat:@"%@/taihe/app/changePwd.jsp",[self getOAServerUrl]];//@"http://oa01.tahoecn.com:8080/ekp/taihe/app/changePwd.jsp";
    
    
    return [self getAuthPreUrl:modifyPwdUrl];
}

- (NSString *)getGomeAppBannerUrl{
    return [NSString stringWithFormat:@"%@//%@:%d/FilesService/getAppInfo?userid=%@&usercode=%@&compid=%d&logintype=%d&appid=0&action=playimg",[self getProtocol],[self getFileServer],self.fileServerPort,[conn getConn].userId,[conn getConn].curUser.empCode,[UserDefaults getCompId],TERMINAL_IOS];
   
}

//泰禾sso地址
- (NSString *)getSSOServerUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    NSString *SSOUrl;
    if ([primaryServerUrl isEqualToString:@"im2.tahoecn.com"]) {
        
        SSOUrl = @"http://im2.tahoecn.com:9010/TaiheServer/DataService1";
        
        return SSOUrl;
    }else{
        
        SSOUrl = @"http://im.tahoecn.com:9010/TaiheServer/DataService1";
        
        return SSOUrl;
    }
}

//泰禾oa地址
- (NSString *)getOAServerUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    NSString *OAUrl;
    if ([primaryServerUrl isEqualToString:@"im2.tahoecn.com"]) {
        
        OAUrl = @"http://oa01.tahoecn.com:8080/ekp";
        
        return OAUrl;
    }else{
        
        OAUrl = @"http://oa.tahoecn.com/ekp";
        
        return OAUrl;
    }
}

/** 祥源 获取部门配置权限 url */
- (NSString *)getXYDeptShowConfigUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    if ([primaryServerUrl isEqualToString:@"im1.sunriver.cn"]) {
        
        return [NSString stringWithFormat:@"%@//%@/rest/rule/findByTime",[self getProtocol],[self getFileServer]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@//%@:%d/rest/rule/findByTime",[self getProtocol],[self getFileServer],self.otherPort];
    }
    
}

/** 祥源 获取OA token URL */
- (NSString *)getXYOATokenUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    if ([primaryServerUrl isEqualToString:@"im1.sunriver.cn"]) {
        
        return [NSString stringWithFormat:@"%@//%@/rest/sso/getToken",[self getProtocol],[self getFileServer]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@//%@:%d/rest/sso/getToken",[self getProtocol],[self getFileServer],self.otherPort];
    }
    
}

/** 祥源 获取OA 首页 URL */
- (NSString *)getXYOAUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    if ([primaryServerUrl isEqualToString:@"im1.sunriver.cn"]) {
     
        return [NSString stringWithFormat:@"%@//%@/app/flow/index",[self getProtocol],[self getFileServer]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@//%@:%d/app/flow/index",[self getProtocol],[self getFileServer],self.otherPort];
    }
    
}

/** 祥源 获取待办URL */
- (NSString *)getXYDAIBANUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    if ([primaryServerUrl isEqualToString:@"im1.sunriver.cn"]) {
        
        return [NSString stringWithFormat:@"%@//%@/app/flow/todo",[self getProtocol],[self getFileServer]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@//%@:%d/app/flow/todo",[self getProtocol],[self getFileServer],self.otherPort];
    }
}

/** 祥源 获取祥源修改密码url */
- (NSString *)getXYpassWordUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    if ([primaryServerUrl isEqualToString:@"im1.sunriver.cn"]) {
        
        return [NSString stringWithFormat:@"%@//%@/app/sso/reset",[self getProtocol],[self getFileServer]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@//%@:%d/app/sso/reset",[self getProtocol],[self getFileServer],self.otherPort];
    }
    
}

/** 祥源 通告URL */
- (NSString *)getXYNoticeUrl{
    
//    http://61.191.30.195:8090/app/flow/notice?
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    if ([primaryServerUrl isEqualToString:@"im1.sunriver.cn"]) {
        
        return [NSString stringWithFormat:@"%@//%@/app/flow/notice",[self getProtocol],[self getFileServer]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@//%@:%d/app/flow/notice",[self getProtocol],[self getFileServer],self.otherPort];
    }
    
}

/** 祥源 修改密码成功加载的url*/
- (NSString *)getXYChangePasswordUrl{
    
//        http://61.191.30.195:8090/app/sso/success
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    if ([primaryServerUrl isEqualToString:@"im1.sunriver.cn"]) {
        
        return [NSString stringWithFormat:@"%@//%@/app/sso/success",[self getProtocol],[self getFileServer]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@//%@:%d/app/sso/success",[self getProtocol],[self getFileServer],self.otherPort];
    }
}
@end
