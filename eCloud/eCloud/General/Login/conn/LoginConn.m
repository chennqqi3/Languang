//
#import "LoginConn.h"

#include <sys/types.h>
#include <sys/sysctl.h>

#include <sys/socket.h>
#include <sys/sockio.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <arpa/inet.h>

#import "APPPlatformDOA.h"
#import "eCloudDefine.h"
#import "conn.h"
#import "StringUtil.h"
#import "UserDefaults.h"

#import "eCloudDAO.h"
#import "eCloudUser.h"
#import "JSONKit.h"
#import "Emp.h"

#import "AuthModel.h"

#import "UserInfoDisplayModel.h"
#import "UserInfoEditModel.h"
#import "LanguageDisplayModel.h"

#import "ConnResult.h"

#import "LogUtil.h"

#import "ServerConfig.h"

#import "ImageUtil.h"

#import "EmpLogoConn.h"

#import "NotificationUtil.h"

#import "OrgConn.h"

#import "DownloadGuideImage.h"

#import "TabbarUtil.h"

#ifdef _LANGUANG_FLAG_

#import "LANGUANGAppViewControllerARC.h"
#import "LGMettingUtilARC.h"

#endif

#ifdef _XIANGYUAN_FLAG_

#import "XIANGYUANAppViewControllerARC.h"
#import "GetXYConfigUtil.h"
#endif

#import "UserDataDAO.h"

typedef enum
{
    download_db_file_status_fail = -1,
    download_db_file_status_downloading = 0,
    download_db_file_status_success = 1,
    /** 不需要下载 */
    download_db_file_status_no_need = 2
}download_db_file_status;


static LoginConn *loginConn;

@implementation LoginConn
{
    eCloudDAO *db;
    eCloudUser *userDb;
    int downloadDbFileStatus;
    
    int downloadDbFileStartTime;
}


@synthesize tempEmp;

+ (LoginConn *)getConn
{
    if (loginConn == nil) {
        loginConn = [[LoginConn alloc]init];
    }
    return loginConn;
}

- (void)dealloc
{
    self.tempEmp = nil;
    [super dealloc];
}

-(id)init
{
	id _id = [super init];
    db = [eCloudDAO getDatabase];
    userDb = [eCloudUser getDatabase];

    return _id;
}

- (void)processLoginAck:(LOGINACK *)info
{
 //   [self testDevice];
    conn *_conn = [conn getConn];

    [_conn stopTimeoutTimer];
	_conn.isLoginCmd = false;
    
    _conn.isInvalidPassword = NO;
	
    int loginResult = info->ret;
    
    if (loginResult != RESULT_SUCCESS) {
        
        if (loginResult == RESULT_FORBIDDENUSER || loginResult == RESULT_SSO_USER_FORBID_ERR || loginResult == RESULT_INVALIDUSER) {
            _conn.isDisable = YES;
        }
        if (loginResult == RESULT_INVALIDPASSWD || loginResult == RESULT_SSO_USER_OR_PASSWD_ERR) {
            _conn.isInvalidPassword = YES;
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"登录返回失败，停止收消息线程 %d",loginResult]];
		_conn.connStatus = not_connect_type;

        /** 返回的错误信息 */
        LV255 lv255 = info->tRetDesc;
        NSString *retStr = [StringUtil getStringByCString:lv255.value];
        
        ConnResult *result = [[ConnResult alloc]init];
        result.resultCode = loginResult;
        result.serverRetMsg = retStr;
        
        NSMutableDictionary *mResult = [NSMutableDictionary dictionary];
        [mResult setObject:result forKey:@"RESULT"];
        [result release];

        /** 客储需求，密码错误给提示 */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:retStr forKey:@"errorMessage"];
        [defaults synchronize];
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = login_failure;
        _notificationObject.info = mResult;
        
        [[NotificationUtil getUtil]sendNotificationWithName:LOGIN_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

        /**  添加发出通知 */
        [_conn sendWandaLoginNotification:loginResult];
        
    }
    else
    {

        /** 客储需求，密码错误给提示 */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:@"errorMessage"];
        [defaults synchronize];
        
        [UserDefaults saveUserIsExit:NO];

        /** 判断是否更换了用户 */
        /** 用户id */
        int userId = info->uUserId;
        
        [self saveTempEmp:info];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s user id is %d",__FUNCTION__,userId]];

        _conn.userId = [StringUtil getStringValue:userId];

        NSString *lastUserId = [UserDefaults getLastUserId];
        if (lastUserId && lastUserId.intValue != userId)
        {
            /** 首先判断下数据库是否是打开的，并且id和lastUserId保持一致 */
            if (db.lastUserId && [db.lastUserId isEqualToString:lastUserId])
            {
                [LogUtil debug:@"更换了用户，关闭之前用户的数据库"];
                [db closeSqliteDatabase];
                db.lastUserId = nil;
                
                [[conn getConn].onlineEmpCountArray removeAllObjects];
                [[conn getConn].allEmpArray removeAllObjects];
            }
        }

        /** 保存到userDb中 */
        [userDb saveCurUser];

        /** 创建应用程序目录 */
        [StringUtil createFolderForPath:[StringUtil getFileDir]];

        /** 尝试打开当前登录用户打开数据库 */
        /** 如果要去下载数据库文件，并且是用户第一次登录，那么就不打开数据库，其它情况需要先打开数据库 */
        if ([[eCloudConfig getConfig]needDownloadOrgDB] && [userDb needDownloadOrgDb]) {
            
            /** 等下载完了或者下载失败了才打开 */
        }else{

            /** 不需要下载数据库的情况，可以直接在发出通知前就打开 */
            [self openLoginUserDB];
        }

        /** 根据用户是否第一次登录判断是否需要修改密码  泰禾专用 */
        _conn.isNeetModifyPwd = info->cModifyPersonalAuditPeriod == 0 ? YES : NO;
        
#ifdef _XIANGYUAN_FLAG_
        [[GetXYConfigUtil getUtil]getXYOAToken];
#endif

        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = login_success;
        
        [[NotificationUtil getUtil]sendNotificationWithName:LOGIN_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

#ifdef _LANGUANG_FLAG_
        
        [self getLGUserPermissions];
        
#endif
        
        /** 添加发出通知 */
        [_conn sendWandaLoginNotification:loginResult];

        [self saveUserToken:info];

        /** 泰禾要求第一次登陆进入到修改密码界面，通过cModifyPersonalAuditPeriod  0:第一次登陆    1:不是第一次登陆 */
        if ([UIAdapterUtil isTAIHEApp] && info->cModifyPersonalAuditPeriod == 0) {
            
            return ;
        }

        [[EmpLogoConn getConn] clearAllDownloadLogoFailEmp];
        
        _conn.isFirstProcessUserStateList = YES;
        
        _conn.lastGetUserStateListTime = [_conn getCurrentTime];
        
        _conn.lastSendCheckTimeCmdTime = [_conn getCurrentTime];
        
        
        _conn.userStatus = status_online;
        
        [UserDefaults setLastUserId:_conn.userId];
        [UserDefaults setLastUserAccount:[UserDefaults getUserAccount]];
        
        // 下载启动页图片 lyan
//        if ([eCloudConfig getConfig].supportGuidePages) {
//            [[DownloadGuideImage shareDownloadGuideImageSingle] downloadGuideImage];
//        }
        
        /** 如果不需要下载数据库那么直接运行，否则进行判断 */
        if (![[eCloudConfig getConfig]needDownloadOrgDB] || CREATE_ORG_DATABASE_FILE) {
            [self afterDownloadDbFile:info];
            return;
        }
        
        if ([userDb needDownloadOrgDb])
        {
            if ([UIAdapterUtil isCsairApp]) {
                if ([[eCloudConfig getConfig].primaryServerUrl rangeOfString:@"fxapp.csair.com" options:NSCaseInsensitiveSearch].length == 0) {
                    [self afterDownloadDbFile:info];
                    return;
                }
            }
            if ([UIAdapterUtil isCsairApp] && START_CSAIR_HIDE_ORG) {
                int rankId = info->cMobileMaxSendFileSize;
                [LogUtil debug:[NSString stringWithFormat:@"%s 当前用户的级别是%d，如果小于3那么直接同步",__FUNCTION__,rankId]];
                if (rankId < 3) {
                    [self afterDownloadDbFile:info];
                    return;
                }
            }
            downloadDbFileStatus = download_db_file_status_downloading;

            /** 下载文件，并且在下载完毕后，进行后续处理 */
            [self downloadOrgDb];
        }
        else
        {
            downloadDbFileStatus = download_db_file_status_no_need;
        }
        
        while (downloadDbFileStatus == download_db_file_status_downloading)
        {
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"%s 对应的时间戳数据库文件还未下载 ",__FUNCTION__);
        }

        /** 如果下载失败了，那么在用户在线的情况下继续后面的操作，防止意外网络断开或超时引起的，这样不用继续处理 */
        if (downloadDbFileStatus == download_db_file_status_fail) {
            if (_conn.userStatus == status_online) {

                /** 后续处理 */
                [self afterDownloadDbFile:info];
            }
        }
        else
        {
            /** 后续处理 */
            [self afterDownloadDbFile:info];
        }
    }
}

/** 保存公司id */
- (void)saveCompId:(LOGINACK *)info
{
    [UserDefaults setCompId:info->dwCompID];
}

/** 打开当前用户的数据库 */
- (void)openLoginUserDB
{
    /** 初始化数据库 */
    if(db.lastUserId == nil || db.lastUserId.intValue != [conn getConn].userId.intValue || [db getDbHandle] == nil)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s %@",__FUNCTION__,[conn getConn].userId]];
        [db initDatabase:[conn getConn].userId];
    }
}

/** 保存登录用户资料 */
- (void)saveCurUser:(LOGINACK *)info
{
    conn *_conn = [conn getConn];
    
    [self openLoginUserDB];

    if (downloadDbFileStatus == download_db_file_status_success)
    {
        [_conn sendRefreshOrgNotification];
    }

    /** 用户姓名 */
    LV128 lv128 = info->tCnUserName;
    NSString *userName = [StringUtil getStringByCString:lv128.value];
    
    lv128 = info->tEnUserName;
    NSString *engUserName = [StringUtil getStringByCString:lv128.value];

    /** ???目前服务器返回的有问题，username没有返回，所以才从数据库获取 */
    NSDictionary *dic = [db searchEmp:_conn.userId];
    if (!userName || userName.length == 0)  {
        if (dic) {
            userName = [dic valueForKey:@"emp_name"];
            engUserName = [dic valueForKey:@"emp_name_eng"];
        }
    }
    /** 获取工号 */
    if (_conn.user_code == nil || ![_conn.user_code isEqualToString:dic[@"emp_code"]]) {
        if (dic) {
            _conn.user_code = dic[@"emp_code"];
        }
    }

    /** 用户性别 */
    int sex = info->sex;

    /** 保存到db中 */
    Emp *_emp = [[Emp alloc]init];
    _emp.emp_id = _conn.userId.intValue;
    _emp.emp_sex = sex;
    _emp.emp_name = userName;
    _emp.empNameEng = engUserName;
    _emp.emp_status = status_online;

    /** 保存登录用户的名字 */
    _conn.userName = _emp.emp_name;

    [db saveCurUserBriefInfo:_emp];
    [_emp release];

    [self saveMsgSyncFlag:info];
    
    [self saveAuthority:info];
}

/** 消息同步 */
- (void)saveMsgSyncFlag:(LOGINACK *)info
{
    conn *_conn = [conn getConn];

    _conn.userRcvMsgFlag = info->cMsgSynType;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s %d",__FUNCTION__,info->cMsgSynType]];
}

/** 权限 */
- (void)saveAuthority:(LOGINACK *)info
{
    conn *_conn = [conn getConn];
    
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
    AuthModel *authModel = [AuthModel getModel];

    /** 2字节的权限值 */
    int authority = info->wPurview;
    authModel.auth = authority;
    NSString *user_idStr = [StringUtil getStringValue:info->uUserId];
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    
    for(int i=0;i<MAX_PURVIEW;i++)
    {
        EMPLOYEE_PURVIEW mp = (info->mPurview)[i];
        NSString *keystr=[StringUtil getStringValue:mp.dwID];
        NSString *valuestr=[StringUtil getStringValue:mp.dwParameter];
        [mDic setObject:valuestr forKey:keystr];
    }
    [_defaults setObject:mDic forKey:@"wPurviewDic"];
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取到的权限dic is %@",__FUNCTION__,[mDic description]]];
    
    authModel.authDic = mDic;

    /** update by shisp 发起群组的最大人数 发送文件最大值 从这里获取 */
    [UserDefaults setMaxGroupMember:[mDic[@"1"]intValue]];
    _conn.maxGroupMember = [UserDefaults getMaxGroupMember];
    [UserDefaults setMaxSendFileSize:[mDic[@"2"]intValue]];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 一呼百应:%@,  一呼万应:%@  最大人数:%d 木棉童飞:%@",__FUNCTION__,([authModel canYHBY]?@"YES":@"NO"),([authModel canYHWY]?@"YES":@"NO"),[authModel maxYHWY],([authModel canMMTF]?@"YES":@"NO")]];

    /** 将权限保存到数据库中 */
    NSString *wPurview_str=[NSString stringWithFormat:@"%d",authority];
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取到的权限字符串:%@",__FUNCTION__,wPurview_str]];
    
    // 将权限字符串转成对应的2进制
//    NSString *binary_str=[self toBinary:authority];
    
    /** 将权限保存到数据库中 */
    [userDb saveCurUserPurview:user_idStr andPurview:wPurview_str];
}

- (void)saveSysParam:(LOGINACK *)info
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];

    /** 用户资料显示参数 */
    UserInfoDisplayModel *userInfoDisplayModel = [UserInfoDisplayModel getModel];
    userInfoDisplayModel.iDisplay = info->dwPersonalDisplay;

    /**  用户资料编辑参数 */
    UserInfoEditModel *userInfoEditModel = [UserInfoEditModel getModel];
    userInfoEditModel.iEdit = info->dwPersonalEdit;

    /** 中英文显示参数 */
    LanguageDisplayModel *lanModel = [LanguageDisplayModel getModel];
    lanModel.iLanDisplay = info->cDeptUserLanguageDisplay;

    /** 关于状态的参数 3个 */
    [UserDefaults setGetStatusTimeInterval:info->cMobileGetStatusInterval];
    
    [UserDefaults setMaxGetStatusEmpNumber:info->wGetStatusMaxNum];
    
    [UserDefaults setMaxGetStatusEmpNumberInContactList:info->wMobileUploadRecentContact];

//    其它系统参数 update by shisp
//    [UserDefaults setMaxGroupMember:info->wGroupMaxMemberNum];
//    _conn.maxGroupMember = [UserDefaults getMaxGroupMember];
//    
//    [UserDefaults setMaxSendFileSize:info->cMobileMaxSendFileSize];
    
    [UserDefaults setAliveInterval:info->wMobileAliveMaxInterval];
    CLIENT_SetAliveTime(_conncb,[UserDefaults getAliveInterval]);
    
    [UserDefaults setServerValidTime:info->cMobileServiceExpiry];
    
    [UserDefaults setModifyUserInfoAuditPeriod:info->cModifyPersonalAuditPeriod];
    
}

/** 保存服务器时间 */
- (void)saveServerTime:(LOGINACK *)info
{
    conn *_conn = [conn getConn];

    /** 时间戳 */
    TUpdateTimeStamp tUpdateTime = info->tTimeStamp;

    /** 系统时间 */
    _conn.nServerCurrentTime = tUpdateTime.nServerCurrentTime;
    _conn.dTime=[[NSDate date]timeIntervalSince1970];
}

- (void)saveUpdateTime:(LOGINACK *)info
{
    conn *_conn = [conn getConn];

    /** 时间戳 */
    TUpdateTimeStamp tUpdateTime = info->tTimeStamp;

    /** 公司，部门，员工，员工部门 */
    _conn.compUpdateTime = [StringUtil getStringValue:tUpdateTime.dwCompUpdateTime];
    _conn.deptUpdateTime = [StringUtil getStringValue:tUpdateTime.dwDeptUpdateTime];
    _conn.empUpdateTime = [StringUtil getStringValue:tUpdateTime.dwUserUpdateTime];
    _conn.empDeptUpdateTime = [StringUtil getStringValue:tUpdateTime.dwDeptUserUpdateTime];

    /** 固定组 */
    _conn.VgroupTime=[StringUtil getStringValue:tUpdateTime.dwRegularGroupUpdateTime];

    /** 黑白名单 */
    int specialTime = tUpdateTime.dwSpecialListUpdatetime;
    int whiteTime = tUpdateTime.dwSpecialWhiteListUpdatetime;
    _conn.newBlacklistUpdateTime = [NSString stringWithFormat:@"%d|%d",specialTime,whiteTime];

    /** 缺省常用联系人 */
    _conn.newDefaultCommonEmpUpdateTime = tUpdateTime.dwGlobalCommonContactUpdateTime;

    /** 常用联系人 */
    _conn.newCommonEmpUpdateTime = tUpdateTime.dwPersonalCommonContactUpdateTime;

    /** 常用部门 */
    _conn.newCommonDeptUpdateTime = tUpdateTime.dwPersonalCommonDeptUpdateTime;

    /** 当前登录用户资料及头像 */
    _conn.newCurUserInfoUpdateTime = tUpdateTime.dwPersonalInfoUpdateTime;
    _conn.newCurUserLogoUpdateTime = tUpdateTime.dwPersonalAvatarUpdateTime;

    /** 其它人头像 */
    _conn.newEmpLogoUpdateTime = tUpdateTime.dwOthersAvatarUpdateTime;
    
    _conn.newRankUpdateTime = tUpdateTime.dwUserRankUpdateTime;
    _conn.newProfUpdateTime = tUpdateTime.dwUserProUpdateTime;
    _conn.newAreaUpdateTime = tUpdateTime.dwUserAreaUpdateTime;

    /** 机器人时间戳 */
    _conn.newRobotUpdateTime = info->dwRobotInfoUpdatetime;

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
//    华夏不同步用户资料
    _conn.deptUpdateTime = [StringUtil getStringValue:SERVER_INIT_TIMESTAMP];
    _conn.empUpdateTime = [StringUtil getStringValue:SERVER_INIT_TIMESTAMP];
    _conn.empDeptUpdateTime = [StringUtil getStringValue:SERVER_INIT_TIMESTAMP];
    
    [[eCloudDAO getDatabase]saveHXDefaultDept];
#endif

 }


/*
 功能描述
 判断登录用户用户资料时间戳，是否与本地时间戳不同，如果不同那么去获取，如果相同，那么就从数据库获取当前登录用户信息
 如果需要同步应用信息，则开启异步获取应用列表线程
 */
- (void)syncCurUserInfo
{
    conn *_conn = [conn getConn];
    _conn.curUser = [db getEmpInfo:_conn.userId];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,old time is %d, new time is %d",__FUNCTION__,_conn.oldCurUserInfoUpdateTime,_conn.newCurUserInfoUpdateTime]];
    
    if (_conn.oldCurUserInfoUpdateTime < _conn.newCurUserInfoUpdateTime) {
        [_conn getUserInfoAuto:_conn.userId.intValue];
    }else{
        //  同步组织架构前 同步应用
        if ([eCloudConfig getConfig].needApplist) {
            //同步应用列表
            dispatch_queue_t _queue = dispatch_queue_create("Sync App List", NULL);
            dispatch_async(_queue, ^{
                [_conn syncAppList];
            });
        }
    }
}

/** 判断登录用户 用户头像时间戳是否和本地不同，如果不同，那么就去获取新的头像并且保存 */
- (void)syncCurUserLogo
{
    conn *_conn = [conn getConn];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,old time is %d, new time is %d",__FUNCTION__,_conn.oldCurUserLogoUpdateTime,_conn.newCurUserLogoUpdateTime]];
    
    if (_conn.newCurUserLogoUpdateTime == 0 || (_conn.oldCurUserLogoUpdateTime < _conn.newCurUserLogoUpdateTime))
    {

        [StringUtil deleteUserLogoIfExist:_conn.userId];
//        emplogo统一为0
        NSLog(@"当前登录用户的头像时间戳有变化，启动下载");
        [StringUtil downloadCurUserLogo];
    }
}


#pragma mark ===========下载组织架构数据库相关===========

#define key_download_type @"download_type"
#define download_ecloud @"download_ecloud"
#define download_ecloud_user @"download_ecloud_user"

- (void)downloadOrgDb
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//    NSLog(@"需要下载通讯录数据库");

    /** 先关闭之前的数据库 */
    [db closeSqliteDatabase];
    db.lastUserId = nil;
    
    downloadDbFileStartTime = [[conn getConn]getCurrentTime];
    
    NSString *dbPath = [StringUtil getDataDbFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:dbPath isDirectory:NO])
    {
        NSLog(@"删除旧的数据库文件");
        [[NSFileManager defaultManager]removeItemAtPath:dbPath error:nil];
    }
    
    conn *_conn = [conn getConn];
    
    _conn.connStatus = download_org;
    _conn.downloadOrgTips = [StringUtil getAppLocalizableString:@"conn_download_org"];

    
    NSString *orgDbDownloadUrl = [[ServerConfig shareServerConfig]getOrgDbDownloadUrl];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:orgDbDownloadUrl]];
    
    [request setDelegate:self];
    [request setDownloadDestinationPath:[StringUtil getZipDbFilePath]];
    [request setAllowCompressedResponse:NO];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:download_ecloud,key_download_type, nil]];
    [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    request.downloadProgressDelegate = self;
    request.showAccurateProgress = YES;
    [request startSynchronous];
    [request release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,request.responseStatusMessage]];
//    NSLog(@"%s,%@",__FUNCTION__,request.responseStatusMessage);
    
    if (request.responseStatusCode == 200)
    {
        NSDictionary *dic = request.userInfo;
        if (dic)
        {
            NSString *dbPath = request.downloadDestinationPath;
            if ([[NSFileManager defaultManager]fileExistsAtPath:dbPath isDirectory:NO])
            {
                NSLog(@"数据库文件已经下载%@",dbPath);
                
                NSString *downloadType = [dic valueForKey:key_download_type];
                if ([downloadType isEqualToString:download_ecloud])
                {
                    int endTime = [[conn getConn]getCurrentTime];
                    
                    [LogUtil debug:[NSString stringWithFormat:@"下载通讯录数据库文件需要时间:%d",(endTime - downloadDbFileStartTime)]];
                    
                    if ([StringUtil unzipDb])
                    {
                        /**  因为把 组织架构对应的数据库文件 和 保存时间戳的数据库文件 放在了一个压缩包里，所以下载下来后，一解压两个数据库文件都有了，所以可以直接保存时间戳 */
                        [userDb saveUpdateTimeFromDownloadUserDb];
                        downloadDbFileStatus = download_db_file_status_success;

                        [self openLoginUserDB];

                        /** 通讯录文件里可能同步保存了应用app，这里删除 */
                        [[APPPlatformDOA getDatabase]removeAllApp];

                        /** 下载时间戳数据库文件 */
//                        [self downloadOrgUserDb];
                        return;
                    }
                }
                else if ([downloadType isEqualToString:download_ecloud_user])
                {

                    /** 更新时间戳 */
                    [userDb saveUpdateTimeFromDownloadUserDb];
                    downloadDbFileStatus = download_db_file_status_success;
                    return;
                }
            }
        }
    }
    
    downloadDbFileStatus = download_db_file_status_fail;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,request.responseStatusMessage]];
//   NSLog(@"%s,%@",__FUNCTION__,request.responseStatusMessage);
    NSDictionary *dic = request.userInfo;
    if (dic)
    {
        NSString *downloadType = [dic valueForKey:key_download_type];
        if ([downloadType isEqualToString:download_ecloud])
        {
            [LogUtil debug:@"下载数据库文件失败"];
        }
        else if ([downloadType isEqualToString:download_ecloud_user])
        {
            [LogUtil debug:@"下载user db 文件失败"];
        }
    }
    
    downloadDbFileStatus = download_db_file_status_fail;
}

- (void)setProgress:(float)newProgress
{
    if (isnan(newProgress))
        return;

    float _progress = (100 * newProgress);
    [LogUtil debug:[NSString stringWithFormat:@"下载数据库文件进度%.0f",_progress]];
    conn *_conn = [conn getConn];
    _conn.downloadOrgTips = [NSString stringWithFormat:@"%@%.0f%%",[StringUtil getAppLocalizableString:@"conn_download_org"],_progress];
}


- (void)downloadOrgUserDb
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//    NSLog(@"下载ecloud_user数据库");
    
    NSString *dbPath = [StringUtil getDownloadecloudUserDbPath];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:dbPath isDirectory:NO])
    {
        NSLog(@"删除旧的ecloud_user数据库文件");
        [[NSFileManager defaultManager]removeItemAtPath:dbPath error:nil];
    }
    
    NSString *orgUserDbDownloadUrl = [[ServerConfig shareServerConfig]getOrgUserDbDownloadUrl];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:orgUserDbDownloadUrl]];
    
    [request setDelegate:self];
    [request setDownloadDestinationPath:dbPath];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:download_ecloud_user,key_download_type,nil]];
    [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    [request startSynchronous];
    [request release];
}

/*
 功能描述
 保存用户资料
 保存公司id
 保存服务器时间
 保存系统参数
 保存最新的时间戳到内存
 获取本地保存的各种资料时间戳
 设置连接状态
 自动同步登录用户的资料
 自动同步登录用户的头像
 开启同步组织架构
 */

- (void)afterDownloadDbFile:(LOGINACK *)info
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
 
//    NSLog(@"%s",__FUNCTION__);
    
    conn *_conn = [conn getConn];
    [self saveCurUser:info];

    [self saveCompId:info];
    
    [self saveServerTime:info];
    
    [self saveSysParam:info];
    
    [self saveUpdateTime:info];
    
    [[eCloudDAO getDatabase]updateSendFlagToUploadFailIfUploading];

    /** 获取本地保存的各类时间戳 */
    [_conn getOrgInfo];

    /** 处理 用户级别是否变化，是否需要重新下载组织架构 */
    [self processCurrentUserRank:info];
    
    [_conn setCurConnStatus];
    //        _conn.notificationObject.cmdId = login_success;
    //        [_conn notifyMessage:nil];
    
    [self syncCurUserInfo];
    
    [self syncCurUserLogo];

    /** 设置手动刷新通讯录属性为NO */
    _conn.isRefreshOrgByHand = NO;
    
//    _conn.oldDeptUpdateTime = @"1423519720";
//    _conn.oldEmpDeptUpdateTime = @"1423519721";
//
//    [[OrgConn getConn]getOrgSyncType];
    [_conn getDeptInfo:nil];
}

/*
 功能描述
 保存用户的token，用户单点登录
 */
- (void)saveUserToken:(LOGINACK *)info
{
    /** 返回的token */
    [UserDefaults saveLoginToken:[StringUtil getStringByCString:info->tAuthToken.value]];
#ifdef _LANGUANG_FLAG_
    
    //[LANGUANGAppViewControllerARC getDaiBanCount];
    
#endif
    
    if ([UIAdapterUtil isGOMEApp])
    {
        NSString *token = [UserDefaults getLoginToken];
        NSArray *arr = [token componentsSeparatedByString:@","];
        if (arr.count>1)
        {
            [UserDefaults saveGOMEToken:[arr lastObject]];
//            [UserDefaults saveGOMEEmpId:[arr firstObject]];
//            保存真正的用户id
            [UserDefaults saveGOMEEmpId:[conn getConn].userId];
        }
//        update by shisp 2017年2月20日 保存用户名字
        
        NSString *empName = [StringUtil getStringByCString:info->tCnUserName.value];
        [UserDefaults saveGOMEEmpName:empName];
    }
    
    
    [LogUtil debug:[NSString stringWithFormat:@"%s token is %@",__FUNCTION__,[UserDefaults getLoginToken]]];
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        [TabbarUtil refreshFoundInterface];
        
    }
    
}
- (void)saveTempEmp:(LOGINACK *)info
{
    Emp *_emp = [[Emp alloc]init];
    _emp.emp_id = info->uUserId;
    _emp.emp_name = [StringUtil getStringByCString:info->tCnUserName.value];
    _emp.empNameEng = [StringUtil getStringByCString:info->tEnUserName.value];
    _emp.empCode = [UserDefaults getUserAccount];
    _emp.emp_sex = info->sex;
    self.tempEmp = _emp;
    [conn getConn].curUser = _emp;
    [_emp release];
    
}

/** 南航版本的特殊处理 */
- (void)processCurrentUserRank:(LOGINACK *)info
{
    if ([UIAdapterUtil isCsairApp] && START_CSAIR_HIDE_ORG) {
    
        /** 如果是南航版本 那么cMobileMaxSendFileSize保存了用户真正的级别，如果这个值 和 用户原有的级别不同，那么需要重新同步员工与部门关系 */
        
        int rankId = [UserDefaults getCurrentUserRank];
        if (rankId < 0) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 启用隐藏部分人员功能，有必要更新组织架构",__FUNCTION__]];
        }
        int newRank = info->cMobileMaxSendFileSize;
        [LogUtil debug:[NSString stringWithFormat:@"%s newRank is %d oldRank is %d",__FUNCTION__,newRank,rankId]];

        /** 如果不同，那么就把时间戳设置为0，把员工与部门关系表删除。接下来就会重新同步 */
        if (rankId < 0) {
//
        }else{
            if (rankId == newRank) {
                /** 没有变化 */
            }else{
                [[eCloudDAO getDatabase]clearEmpDeptData];
            }
        }
        [UserDefaults saveCUrrentUserRank:newRank];
    }

}

- (void)testDevice{
    //    [[UIDevice currentDevice] systemName]; // 系统名
    //    [[UIDevice currentDevice] systemVersion]; //版本号
    //    [[UIDevice currentDevice] model]; //类型，模拟器，真机
    //    [[UIDevice currentDevice] uniqueIdentifier]; //唯一识别码
    //    [[UIDevice currentDevice] name]; //设备名称
    //    [[UIDevice currentDevice] localizedModel]; // 本地模式
    //设备相关信息的获取
    NSString *strName = [[UIDevice currentDevice] name];
    NSLog(@"设备名称：%@", strName);//e.g. "My iPhone"
    
    NSUUID *strId = [[UIDevice currentDevice] identifierForVendor];
    NSLog(@"设备唯一标识：%@", strId.UUIDString);//UUID,5.0后不可用
    
    NSString *strSysName = [[UIDevice currentDevice] systemName];
    NSLog(@"系统名称：%@", strSysName);// e.g. @"iOS"
    
    NSString *strSysVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"系统版本号：%@", strSysVersion);// e.g. @"4.0"
    
    NSString *strModel = [[UIDevice currentDevice] model];
    NSLog(@"设备模式：%@", strModel);// e.g. @"iPhone", @"iPod touch"
    
    NSString *strLocModel = [[UIDevice currentDevice] localizedModel];
    NSLog(@"本地设备模式：%@", strLocModel);// localized version of model //地方型号  （国际化区域名称）
    
    //获取系统当前语言版本(中文zh-Hans,英文en)
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
  
    NSString *systemLan = [languages objectAtIndex:0];
    
    NSLog(@"系统语言:%@",systemLan);
    //手机型号。
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    NSLog(@"手机型号%@",platform);
    
    [self getDeviceIPIpAddresses];
}

- (NSString *)getDeviceIPIpAddresses

{
    
    int sockfd =socket(AF_INET,SOCK_DGRAM, 0);
    
    //    if (sockfd <</span> 0) return nil;
    
    NSMutableArray *ips = [NSMutableArray array];
    
    
    
    int BUFFERSIZE =4096;
    
    struct ifconf ifc;
    
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd,SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            
            int len =sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                
                len = ifr->ifr_addr.sa_len;
                
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            
            if (ifr->ifr_addr.sa_family !=AF_INET) continue;
            
            if ((cptr = (char *)strchr(ifr->ifr_name,':')) != NULL) *cptr =0;
            
            if (strncmp(lastname, ifr->ifr_name,IFNAMSIZ) == 0)continue;
            
            memcpy(lastname, ifr->ifr_name,IFNAMSIZ);
            
            ifrcopy = *ifr;
            
            ioctl(sockfd,SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags &IFF_UP) == 0)continue;
            
            
            
            NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            
            [ips addObject:ip];
            
        }
        
    }
    
    close(sockfd);
    
    
    
    
    
    NSString *deviceIP =@"";
    
    for (int i=0; i < ips.count; i++)
        
    {
        
        if (ips.count >0)
            
        {
            
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
            
            
            
        }
        
    }
    
    NSLog(@"deviceIP========%@",deviceIP);
    return deviceIP;
    
}

- (void)getLGUserPermissions
{
    Emp *emp = [conn getConn].curUser;
    NSString *userId = [NSString stringWithFormat:@"%d",emp.emp_id];
#ifdef _LANGUANG_FLAG_
    
    NSString *httpPath = [NSString stringWithFormat:@"%@/FilesService/getUserPowerExtInfo?userid=%@",[LGMettingUtilARC getInterfaceUrl],userId];

    
    NSDictionary *dict = [StringUtil getHtmlText:httpPath];
    if ([dict[@"status"]intValue] == 0) {
        [UserDefaults setLanGuangModifyHead:dict[@"album"]];
        [UserDefaults setLanGuangSecret:dict[@"secret"]];
        [UserDefaults setLanGuangRecallTime:dict[@"recalltime"]];
        
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取用户头像修改权限和发起密聊权限 == %@",__FUNCTION__,dict]];
    
#endif
}

@end
