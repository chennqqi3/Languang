// 

#import "EmpLogoConn.h"
#import "ServerConfig.h"

#import "conn.h"
#import "UserDefaults.h"
#import "LogUtil.h"
#import "StringUtil.h"
#import "eCloudUser.h"
#import "Emp.h"
#import "WandaNotificationNameDefine.h"
#import "talkSessionUtil.h"
#import "ImageUtil.h"
#import "NotificationUtil.h"
#import "eCloudDAO.h"

@interface EmpLogoConn ()

@property (nonatomic,retain) NSMutableArray *updateEmpLogoArray;

@property (atomic,retain) NSMutableArray *downloadLogoFailEmpArray;
@end

static EmpLogoConn *empLogoConn;

@implementation EmpLogoConn
{
    int empLogoPage;
    eCloudUser *userDb;
    eCloudDAO *db;

    pthread_mutex_t add_mutex;
}
@synthesize updateEmpLogoArray;
@synthesize downloadLogoFailEmpArray;

- (void)dealloc
{
    self.updateEmpLogoArray = nil;
    self.downloadLogoFailEmpArray = nil;
    
    pthread_mutex_destroy(&add_mutex);

    [super dealloc];
}
+ (EmpLogoConn *)getConn
{
    if (empLogoConn == nil) {
        empLogoConn = [[EmpLogoConn alloc]init];
    }
    return empLogoConn;
}

- (id)init
{
    id _id = [super init];
    userDb = [eCloudUser getDatabase];
    db = [eCloudDAO getDatabase];

    pthread_mutex_init(&add_mutex, NULL);
    self.downloadLogoFailEmpArray = [NSMutableArray array];

    return _id;
}

/** 同步头像 */
- (BOOL)syncEmpLogo
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];

    [LogUtil debug:[NSString stringWithFormat:@"%s,old time is %d, new time is %d",__FUNCTION__,_conn.oldEmpLogoUpdateTime,_conn.newEmpLogoUpdateTime]];
    
    if (_conn.newEmpLogoUpdateTime == SERVER_INIT_TIMESTAMP) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 现在不更新头像",__FUNCTION__]];
        return NO;
    }
    
    if (_conn.oldEmpLogoUpdateTime == 0) {
        [userDb saveEmpLogoUpdateTime];
    }
    else
    {
        if (_conn.oldEmpLogoUpdateTime < _conn.newEmpLogoUpdateTime) {
            int ret = CLIENT_GetUserHeadIconList(_conncb,_conn.oldEmpLogoUpdateTime,TERMINAL_IOS);
            if (ret == 0) {
                self.updateEmpLogoArray = [NSMutableArray array];
                empLogoPage = 0;
                NSLog(@"同步联系人头像");
                return YES;
            }
        }
    }

    
    return NO;
}

/** 处理头像变化 */
- (void)processEmpLogoSyncAck:(TGetUserHeadIconListAck *)info
{
    if(info->result == RESULT_SUCCESS)
    {
        empLogoPage++;
        
//        NSLog(@"收到联系人头像同步应答 %d",empLogoPage);
        
        int num = info->wCurrNum;
        unsigned int startPos = 0;
        TUserHeadIconList _list;
        int iCount = 0;

        /** 解析过程中是否出错 */
        bool hasError = false;
   
        /** 解析是否完成 */
        bool finish = false;
        while (!finish)
        {
            int ret = CLIENT_ParseUserHeadIconList(info->strPacketBuff, &startPos, &_list);
            switch(ret)
            {
                case EIMERR_PARSE_FINISHED:
                {
                    /** 正常结束 */
                    finish = true;
                }
                    break;
                case EIMERR_SUCCESS:
                {
                    /** 解析数据并且保存 */
                    NSString *empId = [StringUtil getStringValue:_list.dwUserID];
                    [self.updateEmpLogoArray addObject:empId];
                    iCount++;
                }
                    break;
                case EIMERR_INVALID_PARAMTER:
                {
                    /** 异常结束，参数有错 */
                    [LogUtil debug:[NSString stringWithFormat:@"Parameter error"]];
                    hasError = true;
                    finish = true;
                }
                    break;
                case EIMERR_PACKAGE_ERROR:
                {
                    /** 异常结束，报文有错 */
                    [LogUtil debug:[NSString stringWithFormat:@"Package error"]];
                    hasError = true;
                    finish = true;
                }
                    break;
            }
        }
        
        if(hasError)
        {
            [LogUtil debug:[NSString stringWithFormat:@"解析错误"]];
        }
        else
        {
            if(num != iCount)
            {
                [LogUtil debug:[NSString stringWithFormat:@"解析完成，但数据不一致"]];
            }
            else
            {

                /** 保存信息更新时间 */
                if(info->wCurrPage == 0)
                {
                    /** 下载保存头像 */
                    [self saveEmpLogo];
                }
            }
        }
    }
    else
    {
        [LogUtil debug:[NSString stringWithFormat:@"联系人头像同步失败"]];
    }
}

- (void)saveEmpLogo
{
    [userDb saveEmpLogoUpdateTime];
    
    NSDictionary *allChatEmps = nil;
    
    if (self.updateEmpLogoArray.count) {
        allChatEmps = [[eCloudDAO getDatabase]getAllChatEmps];
    }
    
    for (NSString *empId in self.updateEmpLogoArray)
    {
        if (empId.intValue == [conn getConn].userId.intValue)
        {
            continue;
        }
        
        if (allChatEmps[empId]) {
            [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,empId]];
            
            /** 先删除原来的头像，再下载新的头像 */
            [StringUtil deleteUserLogoIfExist:empId];
            [StringUtil downloadUserLogo:empId andLogo:nil andNeedSaveUrl:true];
        }
    }
}
//{
////    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,self.updateEmpLogoArray]];
//    conn *_conn = [conn getConn];
//    NSDirectoryEnumerator *dirEnum =
//    [[NSFileManager defaultManager] enumeratorAtPath:[StringUtil newLogoPath]];
//    
//    for (NSString *empId in self.updateEmpLogoArray)
//    {
//        [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,empId]];
//    }
//
//    NSString *file;
//    while ((file = [dirEnum nextObject]))
//    {
//        if (file && [[file pathExtension] isEqualToString:@"png"]) {
//            for (NSString *empId in self.updateEmpLogoArray)
//            {
//                if (empId.intValue == _conn.userId.intValue)
//                {
//                    continue;
//                }
//                /** 需要增加判断条件，否则每一个下载过头像的要下载两遍，应该是只要下载过小头像就重新下载 */
//                if([file hasPrefix:empId] && [file rangeOfString:@"_big_"].length == 0)
//                {
//                    NSLog(@"用户%@已经下载过头像，需要重新下载",empId);
//
//                    /** 先删除原来的头像，再下载新的头像 */
//                    [StringUtil deleteUserLogoIfExist:empId];
//                    [StringUtil downloadUserLogo:empId andLogo:[StringUtil getStringValue:_conn.newEmpLogoUpdateTime] andNeedSaveUrl:true];
//                }
//            }
//        }
//    }
//    
//    [userDb saveEmpLogoUpdateTime];
//}


#pragma mark ==========头像下载失败处理===========
/** 头像下载失败后保存起来，下载前判断是否下载失败过，如果失败，则先不尝试，重新登录后再尝试 */
/** 如果头像下载失败则保存起来 */
- (void)saveDownloadLogoFailEmp:(NSString *)empId
{
    if (!empId) return;

    pthread_mutex_lock(&add_mutex);
    [self.downloadLogoFailEmpArray addObject:empId];
    pthread_mutex_unlock(&add_mutex);

//    NSLog(@"%s,%@",__FUNCTION__,empId);
}

/** 下载前看看是否下载失败过 */
- (BOOL)isDownloadLogoFailEmp:(NSString *)empId
{
    if (!empId) return NO;
    
    if (self.downloadLogoFailEmpArray.count > 0) {

        pthread_mutex_lock(&add_mutex);
        NSArray *tempArray = [NSArray arrayWithArray:self.downloadLogoFailEmpArray];
        pthread_mutex_unlock(&add_mutex);
        
        for (NSString *_empId in tempArray)
        {
            if ([_empId isEqualToString:empId]) {
                return YES;
            }
        }
    }
//    NSLog(@"%s,%@ yes",__FUNCTION__,empId);
    return NO;
}

/** 清空列表 */
- (void)clearAllDownloadLogoFailEmp
{
    pthread_mutex_lock(&add_mutex);
    [self.downloadLogoFailEmpArray removeAllObjects];
    pthread_mutex_unlock(&add_mutex);
//    NSLog(@"%s",__FUNCTION__);
}

#pragma mark ==================

- (Emp *)getEmpByUerAccount:(NSString *)userAccount
{
    Emp *_emp = [[conn getConn] getEmpByEmpCode:userAccount];
    
    if (!_emp) {
        int empId = [userDb getUserIdByUserAccount:userAccount];
        if (empId > 0) {
            _emp = [[[Emp alloc]init]autorelease];
            _emp.emp_id = empId;
        }
        else
        {
            empId = [db getEmpIdByUserAccount:userAccount];
            if (empId > 0) {
                _emp = [[[Emp alloc]init]autorelease];
                _emp.emp_id = empId;
            }
        }
    }
    
    return _emp;
}

//获取头像的下载路径
/*
 userAccount 账号
 type 0 是小图
 type 1 是大图
 找不到账号时或者用户还没有登陆成功 返回nil
 */
- (NSString *)getPortrailtDownloadUrlWithUserAccount:(NSString *)userAccount andLogoType:(int)type
{
    Emp *_emp = [self getEmpByUerAccount:userAccount];
    
    if (_emp && [conn getConn].userId) {
        ServerConfig *serverConfig = [[eCloudUser getDatabase]getServerConfig];
        
        NSString *resultStr = nil;
        if (type == 0) {
            resultStr = [serverConfig getLogoUrlByEmpId:[StringUtil getStringValue:_emp.emp_id]];
        }else if (type == 1)
        {
            resultStr = [serverConfig getBigLogoUrlByEmpId:[StringUtil getStringValue:_emp.emp_id]];
        }
        
        if (resultStr.length == 0) {
            return nil;
        }
        return resultStr;
    }
    return nil;
}

/** 提供一个新下载头像的接口，参数是userAccout,异步下载完成后，发送通知出去，并且带上路径 */
- (void)downloadLogoByUserAccount:(NSString *)userAccount
{
    [LogUtil debug:[NSString stringWithFormat:@"%s userAccount is %@",__FUNCTION__,userAccount]];
    
    conn *_conn = [conn getConn];
    
    Emp *_emp = [self getEmpByUerAccount:userAccount];
    
    //    Emp *_emp = nil;
    //    if ([userAccount isEqualToString:[UserDefaults getUserAccount]])
    //    {
    //        [LogUtil debug:[NSString stringWithFormat:@"%s 账号和当前登录用户一致",__FUNCTION__]];
    //
    //        if (_conn.userId)
    //        {
    //            [LogUtil debug:[NSString stringWithFormat:@"%s 账号对于用户id是 %@",__FUNCTION__,_conn.userId]];
    //           _emp = [[[Emp alloc]init]autorelease];
    //            _emp.emp_id = _conn.userId.intValue;
    //        }
    //    }
    //    else
    //    {
    //        _emp = [_conn getEmpByEmpCode:userAccount];
    //    }
    
    if (_emp && _conn.userId) {
        NSString *empId = [StringUtil getStringValue:_emp.emp_id];
        NSString *logo = default_emp_logo;// _emp.emp_logo;
        NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:logo];
        UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
        if (img)
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s 用户头像已经存在 logoPath is %@",__FUNCTION__,logoPath]];

            /** 用户头像已经存在 直接发送广播出去 */
            [[NotificationUtil getUtil]sendNotificationWithName:com_wanda_ecloud_im_getportrait andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@|%@",logoPath,userAccount] forKey:key_logo_path]];
        }
        else
        {
            if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 本地还没有此用户的头像，直接返回空",__FUNCTION__]];
                [[NotificationUtil getUtil]sendNotificationWithName:com_wanda_ecloud_im_getportrait andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@|%@",@"",userAccount] forKey:key_logo_path]];
            }else{
                dispatch_queue_t _queue = dispatch_queue_create("download_emp_logo", NULL);
                dispatch_async(_queue, ^{
                    
                    ServerConfig *serverConfig = [[eCloudUser getDatabase]getServerConfig];
                    NSURL *url = [NSURL URLWithString:[serverConfig getLogoUrlByEmpId:empId]];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    
                    if(imageData && imageData.length > 0)
                    {

                        /** 先删除原来的头像 */
                        [StringUtil deleteUserLogoIfExist:empId];
                        
                        BOOL success = [UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1.0) writeToFile:logoPath atomically:YES];
                        
                        if(success)
                        {
                            [LogUtil debug:[NSString stringWithFormat:@"%s,头像下载成功保存成功 logopath is %@",__FUNCTION__,logoPath]];
                            
                            /** 发送通知出去 */
                            [[NotificationUtil getUtil]sendNotificationWithName:com_wanda_ecloud_im_getportrait andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@|%@",logoPath,userAccount] forKey:key_logo_path]];
                        }
                        else
                        {
                            [LogUtil debug:[NSString stringWithFormat:@"%s,头像下载成功保存失败",__FUNCTION__]];
                            [[NotificationUtil getUtil]sendNotificationWithName:com_wanda_ecloud_im_getportrait andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@|%@",@"",userAccount] forKey:key_logo_path]];
                        }
                    }
                    else
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"%s,头像下载失败",__FUNCTION__]];
                        [[NotificationUtil getUtil]sendNotificationWithName:com_wanda_ecloud_im_getportrait andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@|%@",@"",userAccount] forKey:key_logo_path]];
                    }
                });
                dispatch_release(_queue);
            }
        }
    }
    else
    {
        NSString *userLogoPath = [UserDefaults getUserLogoPath:userAccount];
        [LogUtil debug:[NSString stringWithFormat:@"%s,没有找到用户，返回之前保存的路径(%@)",__FUNCTION__,userLogoPath]];
        [[NotificationUtil getUtil]sendNotificationWithName:com_wanda_ecloud_im_getportrait andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@|%@",userLogoPath,userAccount] forKey:key_logo_path]];
    }
}



@end
