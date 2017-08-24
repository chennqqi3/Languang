//
//  AccessConn.m
//  eCloud
//
//  Created by shisuping on 14-9-23.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "AccessConn.h"
#import "ApplicationManager.h"
#import "conn.h"
#import "AppDelegate.h"
#import "ServerConfig.h"
#import "UserDefaults.h"
#import "LogUtil.h"
#import "StringUtil.h"


/** 连接超时 */
#define conn_timeout (8)

/** 接收数据超时 */
#define rcv_timeout (8)

/** 连接接入管理服务的返回值 */
typedef enum
{
    /** 连接成功 */
    access_ret_type_success = 0,
    
    /** 连接失败 */
    access_ret_type_fail,
    
    /** 过载保护 */
    access_ret_type_overload,
    
    /** 黑名单 */
    access_ret_type_blacklist
    
}access_ret_type;

static AccessConn *accessConn;

@implementation AccessConn

@synthesize isUserExist;
@synthesize displayLinkingStatusTime;
@synthesize errCode;
@synthesize errMsg;

+ (AccessConn *)getConn
{
    if (accessConn == nil) {
        accessConn = [[AccessConn alloc]init];
        accessConn.isUserExist = YES;
    }
    return accessConn;
}

- (void)dealloc
{
    self.errMsg = nil;
    [super dealloc];
}

- (int)connectServer
{
    int nRet = -1;
	if(![ApplicationManager getManager].isNetworkOk)
    {
        return nRet;
    }
    
    nRet = [self connectToAccessServer];
    return nRet;
    
    
    int netType = [ApplicationManager getManager].netType;
    
    NSString *lastConnIp = [UserDefaults getLastConnIp];
    if (lastConnIp.length > 0) {
        [LogUtil debug:[NSString stringWithFormat:@"本地保存了接入服务ip：%@",lastConnIp]];
        
        if ([lastConnIp hasPrefix:@"10"])
        {
            switch (netType) {
                case type_gprs:
                {
                    return [self connectToAccessServer];
                }
                    break;
                case type_wifi:
                {
                    return [self connectToServer];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        else
        {
            switch (netType)
            {
                case type_wifi:
                {
                    return [self connectToServer];
                }
                    break;
                case type_gprs:
                {
                    return [self connectToServer];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    return [self connectToAccessServer];
}

/**
 功能描述
 连接接入管理服务器方法
 
 */
- (int)connectToAccessServer
{
    [LogUtil debug:[NSString stringWithFormat:@"连接入管理服务器 当前程序版本是%@ 发布日期为%@",[StringUtil getAppVersion],[StringUtil getAppReleaseDate]]];

    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    
    ServerConfig *serverConfig = [ServerConfig shareServerConfig];
    
    NSString *primaryIp = serverConfig.primaryServer;
    int primaryPort = serverConfig.primaryPort;
    
    char *connectIp = [StringUtil getCStringByString:primaryIp];
    int connectPort = primaryPort;
    
    char *userAccount = [StringUtil getCStringByString:[UserDefaults getUserAccount]];
    
    char *newVersion = [StringUtil getCStringByString:[UserDefaults getNewAppVersion]];
    
    int connectTimeout = [self getConnectTimeout];
    int rcvTimeout = connectTimeout;
    
    int connectType = 0;
    
//    NSString *failIp = [UserDefaults getFailConnIp];
//    if (failIp.length > 0) {
//        connectType = 1;
//    }
    char *failServer = nil;//[StringUtil getCStringByString:failIp];
    int failPort = 0;// = [UserDefaults getFailConnPort];
    
    int nRet =   CLIENT_Connect(_conncb,  connectIp, connectPort, userAccount, connectType, newVersion, TERMINAL_IOS, connectTimeout, rcvTimeout, failServer, failPort);
    //
    [LogUtil debug:[NSString stringWithFormat:@"%s 连接主服务器,%@,%d,ret is %d",__FUNCTION__,primaryIp,primaryPort,nRet]];
    
    /** 万达的版本 只需要尝试连一个接入管理服务器 快钱的有接入服务器 */
    if (nRet == 0)
    {
        [self processAccessAck];
        [UserDefaults setCurrentServer:primaryIp];
    }
    else
    {
        /** 如果失败了，那么就尝试连接备用服务器 */
        NSString *secondServer = serverConfig.secondServer;
        int secondPort = serverConfig.secondPort;
        
        connectIp = [StringUtil getCStringByString:secondServer];
        connectPort = secondPort;
        
        nRet =   CLIENT_Connect(_conncb,  connectIp, connectPort, userAccount, connectType, newVersion, TERMINAL_IOS, connectTimeout, rcvTimeout, failServer, failPort);
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 连接备服务器,%@,%d,ret is %d",__FUNCTION__,secondServer,secondPort,nRet]];
        
        if (nRet == 0)
        {
            [self processAccessAck];
            
            [UserDefaults setCurrentServer:secondServer];
        }
    }
    
    /** 如果连接成功了 那么设置为0 */
    if (nRet == 0) {
        self.displayLinkingStatusTime = 0;
    }
    
    self.isUserExist = YES;

    if (nRet != 0) {
        self.errMsg = nil;
        self.errCode = nRet;
        
        switch (nRet) {

            /** 服务器提供的一些错误码 */
            case EIMERR_SOCKETFD_SOCKET:
            case EIMERR_GETHOSTNAME_SOCKET:
            case EIMERR_CONNECT_TIMEOUT_SOCKET:
                
            case EIMERR_SOCKET_GETOPT_SOCKET:
            case EIMERR_SENDSOCKET_EWOULDBLOCK_SOCKET:
            case EIMERR_RECV_DATA_SOCKET:
                
            case EIMERR_SENDSOCKET_SOCKET:
            case EIMERR_RECV_TIMEOUT_SOCKET:
            case EIMERR_SOCKETCLOSE_SOCKET:
                
            case EIMERR_GETHOSTNAME_SERVICE_SOCKET:
            case EIMERR_CONNECT_SERVICE_TIMEOUT_SOCKET:
            {
                
                /** 如果已经尝试了5次，那么就需要显示未连接 */
                self.displayLinkingStatusTime++;
                if (self.displayLinkingStatusTime == 5) {
                    self.displayLinkingStatusTime = 0;
                }

                /** 需要重新连接 */
                [LogUtil debug:[NSString stringWithFormat:@"%s 不显示未连接，显示连接中 %d",__FUNCTION__,self.displayLinkingStatusTime]];
            }
                break;
                

            case EIMERR_NO_USER:
            {
                [LogUtil debug:[NSString stringWithFormat:@"%s 用户不存在 未连接 不需要显示成 连接中",__FUNCTION__]];
                self.isUserExist = NO;
                self.displayLinkingStatusTime = 0;
                self.errMsg = [StringUtil getLocalizableString:@"user_is_not_exist"];
            }
                break;
                
            default:
                break;
        }
    }
    
    if (nRet == 0) {
        return 0;
    }
    return -1;
//    return nRet;
}

- (void)processAccessAck
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    
    LOGINACCESSACK loginAccessAck;
    CLIENT_GetConnectRspInfo(_conncb, &loginAccessAck);
    
    int ret = loginAccessAck.ret;
    self.errCode = ret;
    
    LV255 retDesc = loginAccessAck.tRetDesc;
    NSString *retMsg = [StringUtil getStringByCString:retDesc.value];
    
    self.errMsg = retMsg;

    [LogUtil debug:[NSString stringWithFormat:@"%s retcode is %d retMsg is %@",__FUNCTION__,self.errCode,self.errMsg]];

    int tryTime = 0;
    if (ret == access_ret_type_overload) {
        tryTime = loginAccessAck.iTryTime;
    }
    [UserDefaults setOverloadAutoConnectTime:tryTime];

    LV64 serverAddr = loginAccessAck.tServiceAddr;
    NSString *connIp = [StringUtil getStringByCString:serverAddr.value];
    
    int connPort = loginAccessAck.uPort;
    
    if (ret == access_ret_type_success) {
        [UserDefaults setLastConnIp:connIp];
        [UserDefaults setLastConnPort:connPort];
        [UserDefaults setLastConnTime:[[StringUtil currentTime]intValue]];
        
        NSString *newVersion = [StringUtil getStringByCString:loginAccessAck.szLatestVer];
        
        LV255 updateUrl = loginAccessAck.tUpgradeFileUrl;
        LV255 versionDesc = loginAccessAck.tLatestVerDesc;
        
        NSString *newVersionUrl = [StringUtil getStringByCString:updateUrl.value];
        NSString *newVersionTipUrl = [StringUtil getStringByCString:versionDesc.value];
       
        int upateFlag = loginAccessAck.UpgradeType;
        
        //    测试数据
        //    upateFlag = update_flag_option_update;
        //    newVersionUrl = @"itms-services://?action=download-manifest&url=https://mop.longfor.com/plist/lhdc_27.plist";
        //    newVersionUrl = @"http://www.q-clouds.com";
        
        switch (upateFlag) {
            case update_flag_no_update:
            {
                [LogUtil debug:@"没有更新"];
                _conn.forceUpdate = NO;
                _conn.hasNewVersion = NO;
                
                NSString *appVersion = [StringUtil getAppVersion];
                NSString *newVersion = [UserDefaults getNewAppVersion];
                if ([appVersion compare:newVersion] == NSOrderedAscending) {
                    [LogUtil debug:@"有可选版本"];
                    _conn.hasNewVersion = YES;
                    _conn.updateUrl = [UserDefaults getNewVersionUrl];
                    _conn.updateVersion = newVersion;

                }
            }
                break;
            case update_flag_option_update:
            {
                [LogUtil debug:@"可选更新"];
                _conn.forceUpdate = NO;
                _conn.hasNewVersion = YES;
                
                _conn.updateVersion = newVersion;
                _conn.updateUrl = newVersionUrl;
                
                [UserDefaults setNewAppVersion:newVersion];
                [UserDefaults setNewVersionUrl:newVersionUrl];
                [UserDefaults setNewVersionTipUrl:newVersionTipUrl];
                
            }
                break;
            case update_flag_must_update:
            {
                [LogUtil debug:@"强制更新"];
                _conn.forceUpdate = YES;
                _conn.hasNewVersion = YES;
                
                _conn.updateVersion = newVersion;
                _conn.updateUrl = newVersionUrl;
                
                [UserDefaults setNewAppVersion:@""];
                [UserDefaults setNewVersionUrl:@""];
                [UserDefaults setNewVersionTipUrl:newVersionTipUrl];
                
            }
                break;
                
            default:
                break;
        }
            [LogUtil debug:[NSString stringWithFormat:@"new version is %@ updateFlag is %d update url is %@",_conn.updateVersion,upateFlag,_conn.updateUrl]];

    }else{
        
        /** 如果连接服务器失败了，那么提示没有新版本、没有升级 */
        _conn.forceUpdate = NO;
        _conn.hasNewVersion = NO;
    }
}

/**
 功能描述
 如果本地保存了接入服务器地址，并且在有效期内，那么需要根据网络类型判断是直接连接接入，还是连接接入管理

 */
- (int)connectToServer
{
    [LogUtil debug:@"直接连接入服务器"];
    
    /** 取出上次的连接时间 */
    int lastConnectTime = [UserDefaults getLastConnTime];

    /** 取出接入服务的有效时间 */
    int serverValidTime = [UserDefaults getServerValidTime] * 3600;
    
    int curTime = [[StringUtil currentTime]intValue];
    
    if ((curTime - lastConnectTime) > serverValidTime) {
        [LogUtil debug:@"接入服务器已经超过了有效期，直接连接入管理"];
        return [self connectToAccessServer];
    }
    else
    {
        conn *_conn = [conn getConn];
        CONNCB *_conncb = [_conn getConnCB];
        char *serverIp = [StringUtil getCStringByString:[UserDefaults getLastConnIp]];
        int serverPort = [UserDefaults getLastConnPort];
        
        int nRet = CLIENT_ConnectService(_conncb,serverIp,serverPort,[self getConnectTimeout]);
        
        if (nRet != 0)
        {
            [UserDefaults setFailConnIp:[UserDefaults getLastConnIp]];
            [UserDefaults setFailConnPort:[UserDefaults getLastConnPort]];
            
            [UserDefaults setLastConnIp:@""];
            [UserDefaults setLastConnPort:0];
            
            nRet = [self connectToAccessServer];
        }
        return nRet;
    }
}

- (void)removeLastConnectData
{
    [UserDefaults setLastConnIp:@""];
    [UserDefaults setLastConnPort:0];
    [UserDefaults setLastConnTime:0];
}

/**
 功能描述
 根据网络类型设置超时时间

 */
- (int)getConnectTimeout
{
    int netType = [ApplicationManager getManager].netType;
    if (netType == type_gprs) {
        return 10;
    }
    else
    {
        return 5;
    }
}

@end
