//
//  GOMEEmailUtil.m
//  eCloud
//
//  Created by Alex-L on 2017/4/20.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "GOMEEmailUtilArc.h"
#import "GOMEMailDefine.h"
#import "UserDefaults.h"
#import "eCloudDAO.h"
#import "GOMEEmailWarningViewControllerArc.h"
#import "NotificationsViewController.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "StringUtil.h"
#import "RemindModel.h"
#import "NotificationUtil.h"

#import "ASIHTTPRequest.h"
#import "AESCipher.h"
#import "StringUtil.h"
#import "JSONKit.h"

#import "AppDelegate.h"

#import "eCloudDefine.h"
#import "ServerConfig.h"

#define EMAIL_SERVICE_PATH @"/EmailService/ExchangeService"
#define EMAIL_SERVICE_PORT (9110)
#define GOME_AES_KEY @"gome123456789100"


static GOMEEmailUtilArc *timerUtil;

@interface GOMEEmailUtilArc ()
{
    BOOL _isAuto;
}
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSString *mailAccount;
@property (nonatomic, strong) NSString *mailPassword;

@end


@implementation GOMEEmailUtilArc

+ (GOMEEmailUtilArc *)getEmailUtil
{
    if (timerUtil == nil)
    {
        timerUtil = [[GOMEEmailUtilArc alloc] init];
    }
    
    return timerUtil;
}

- (void)startEmailTimer
{
    [self stopEmailTimer];
    
    self.mailAccount = [GOMEUserDefaults getGOMEEmailAccount];
    self.mailPassword = [GOMEUserDefaults getGOMEEmailPassword];
    
    if (self.mailAccount.length && self.mailPassword.length)
    {
        NSString *status = [GOMEUserDefaults getGOMEEmailStatus];
        
        if ([status isEqualToString:@"success"]){
            [LogUtil debug:[NSString stringWithFormat:@"%s 打开获取邮件未读数定时器",__FUNCTION__]];
            
            self.timer = [NSTimer timerWithTimeInterval:300 target:self selector:@selector(getNewMailCountAsync) userInfo:nil repeats:YES];
            
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            
            [self.timer fire];
        }
        
//        dispatch_queue_t _queue = dispatch_queue_create("get new mail timer", NULL);
//        dispatch_async(_queue, ^{
////            self.timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(getNewMailCount) userInfo:nil repeats:YES];
//            
//            self.timer = [NSTimer timerWithTimeInterval:300 target:self selector:@selector(getNewMailCount) userInfo:nil repeats:YES];
////            首先执行一次
//            [self.timer fire];
//            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//            [[NSRunLoop currentRunLoop] run];
//            
//        });
    }
}

- (void)stopEmailTimer
{
    if (self.timer && [self.timer isValid]) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 停止获取邮件未读数定时器",__FUNCTION__]];
        [self.timer invalidate];
    }
    self.timer = nil;
}

/** 获取邮件未读数的URL，检查用户名和密码是否正确的url相同 */
- (NSString *)getNewMailCountUrlWithEmail:(NSString *)email andPassword:(NSString *)password{
    return [self getCheckEmailAndPasswordUrlWithEmail:email andPassword:password];
}

/** 同步获取邮件未读数 */
- (void)getNewMailCount{
    if (self.mailAccount.length && self.mailPassword.length) {
        NSString *urlStr = [self getNewMailCountUrlWithEmail:self.mailAccount andPassword:self.mailPassword];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        
        NSString *resultStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        [LogUtil debug:[NSString stringWithFormat:@"%s 开始获取邮件未读数 resultStr is %@",__FUNCTION__,resultStr]];
        
        if (resultStr.length) {
            [self saveEmailInfo:resultStr];
        }
    }
}

//异步获取邮件未读数
- (void)getNewMailCountAsync{
    dispatch_queue_t _queue = dispatch_queue_create("get new mail count async", NULL);
    dispatch_async(_queue, ^{
        [self getNewMailCount];
    });
}


/** 检测邮箱账号和密码是否正确的Url地址 参数都是明文的账号和密码 */
- (NSString *)getCheckEmailAndPasswordUrlWithEmail:(NSString *)email andPassword:(NSString *)password{
    NSString *enryptAccountStr = [self encryptEmailAccount:email];
    NSString *enryptPasswordtStr = [self encryptEmailPassword:password];
    
    NSString *baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(
                                                                                         kCFAllocatorDefault,                                                                                   (CFStringRef)enryptPasswordtStr,
                                                                                         NULL,
                                                                                         CFSTR(":/?#[]@!$&’()*+,;="),                                                 kCFStringEncodingUTF8);
    
    NSString *str = [NSString stringWithFormat:@"http://%@:%d%@?username=%@&password=%@&userid=%@",[[ServerConfig shareServerConfig] getFileServer],EMAIL_SERVICE_PORT, EMAIL_SERVICE_PATH, enryptAccountStr, baseString,[conn getConn].userId];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,str]];
    
    return str;
}

/** 根据应答结果，判断邮箱账号和密码是否正确 */
- (BOOL)isEmailAndPasswordCorrect:(NSDictionary *)dic
{
    NSString *status = [dic objectForKey:@"status"];
    if ([status isEqualToString:@"success"]){
        [GOMEUserDefaults saveGOMEEmailStatus:status];
        return YES;
    }
    return NO;
}

/** 在定时获取邮件未读数时，发现用户名和密码不对了，那么停止获取，并且提示用户 */
- (void)showEmailWarningView
{
    [self stopEmailTimer];
    
    [GOMEUserDefaults saveGOMEEmailStatus:@"error"];
    
    [self performSelectorOnMainThread:@selector(showEmailWarningViewOnMainThread) withObject:nil waitUntilDone:YES];
    
}

- (void)showEmailWarningViewOnMainThread{
    GOMEEmailWarningViewControllerArc *activateMailCV = [[GOMEEmailWarningViewControllerArc alloc] initWithNibName:@"GOMEEmailWarningViewControllerArc" bundle:nil];
    activateMailCV.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    [window addSubview:activateMailCV.view];
    [window.rootViewController addChildViewController:activateMailCV];
}

//样板数据
//{
//    address = "huanglinzhang@q-clouds.com";
//    content = "\U53d1\U4ef6\U4eba: Customer & Partner Experience [cpexp@microsoft.com] \U53d1\U9001\U65f6\U95f4: 2017\U5e744\U670818\U65e5 4:53 \U6536\U4ef6\U4eba: bibo(\U7535\U5b50\U5546\U52a1.\U6bd5\U535a) \U4e3b\U9898: \U8bf7\U544a\U8bc9\U6211\U4eec\U60a8\U5bf9\U5fae\U8f6f\U7684\U4f53\U9a8c \U60a8\U7684\U610f\U89c1\U5bf9\U6211\U4eec\U6765\U8bf4\U81f3\U5173\U91cd\U8981 \U6211\U4eec\U4e4b\U6240\U4ee5\U5411\U60a8\U53d1\U9001\U6b64\U8c03\U67e5\U9080\U8bf7\Uff0c\U662f\U4e3a\U4e86\U786e\U4fdd\U60a8\U80fd\U4eab\U53d7\U5230\U6700\U4f73\U7684\U5fae\U8f6f\U4f53\U9a8c\U3002 \U901a\U8fc7\U5b8c\U6210\U4e0b\U65b9\U8c03\U67e5\Uff0c\U60a8\U53ef\U4ee5\U5e2e\U52a9\U6211\U4eec\U4e86\U89e3\U6211\U4eec\U54ea\U4e9b\U5730\U65b9\U505a\U5f97\U5c1a\U53ef\Uff0c\U54ea\U4e9b\U5730\U65b9\U9700\U8981\U6539\U5584\U3002 \U60a8\U7684\U53cd\U9988\U81f3\U5173\U91cd\U8981\Uff0c\U53ef\U4ee5\U5e2e\U52a9\U6211\U4eec\U8d4b\U4e88\U5168\U7403\U6240\U6709\U4e2a\U4eba\U53ca\U7ec4\U7ec7\U53d6\U5f97\U66f4\U5927\U6210\U529f\U7684\U80fd\U529b\U3002 \U672c\U6b21\U8c03\U67e5\U5c06\U5360\U7528\U60a8\U4e0d\U8d85\U8fc7 10 \U5206\U949f\U7684\U65f6\U95f4\U00a0 \U8bf7\U5728 2017 \U5e74 5 \U6708 5 \U65e5\U00a0\U524d\U5b8c\U6210 \U63a5\U53d7\U8c03\U67e5\U00a0\U00a0 \U8877\U5fc3\U611f\U8c22\U60a8\U7684\U65f6\U95f4\U548c\U53cd\U9988\Uff01 Jean-Philippe Courtois \U6267\U884c\U526f\U603b\U88c1 \U5fae\U8f6f\U516c\U53f8\U00a0 \U5982\U679c\U4e0a\U65b9\U7684\U94fe\U63a5\U65e0\U6cd5\U6253\U5f00\Uff0c\U8bf7\U5c06\U4ee5\U4e0b\U94fe\U63a5\U590d\U5236\U5e76\U7c98\U8d34\U5230\U60a8\U7684\U6d4f\U89c8\U5668\U4e2d\U3002 https://www.ksrsurvey.com/wix/p3082291179.aspx?r=674692&s=IEMKXSQL\U00a0 \U5fae\U8f6f\U5df2\U59d4\U6258\U4e00\U5bb6\U72ec\U7acb\U5e02\U573a\U8c03\U7814\U516c\U53f8 KS&R \U5f00\U5c55\U6b64\U6b21\U5ba2\U6237\U53ca\U5408\U4f5c\U4f19\U4f34\U4f53\U9a8c\U8c03\U67e5\U3002\U00a0 \U5fae\U8f6f\U81f4\U529b\U4e8e\U4fdd\U62a4\U60a8\U7684\U9690\U79c1\U3002 \U8981\U60f3\U67e5\U770b\U672c\U8ba1\U5212\U7684\U9690\U79c1\U58f0\U660e\Uff0c\U8bf7 \U00a0\U70b9\U51fb\U6b64\U5904\U3002\U00a0 \U5982\U679c\U60a8\U4e0d\U5e0c\U671b\U518d\U6b21\U63a5\U6536\U5ba2\U6237\U53ca\U5408\U4f5c\U4f19\U4f34\U4f53\U9a8c\U8c03\U67e5\Uff0c\U8bf7 \U00a0\U70b9\U51fb\U6b64\U5904\U3002\U00a0 Microsoft Corporation | One Microsoft Way | Redmond, WA 98052 | USA | +1 425-882-8080\U00a0";
//    name = huanglinzhang;
//    sendtime = 1492586280000;
//    status = success;
//    subject = "fw:\U8f6c\U53d1: \U8bf7\U544a\U8bc9\U6211\U4eec\U60a8\U5bf9\U5fae\U8f6f\U7684\U4f53\U9a8c";
//    unreadcount = 9;
//}

//处理未读数
#define EMAIL_ADDRESS_KEY @"address"
#define EMAIL_NAME_KEY @"name"
#define EMAIL_CONTENT_KEY @"content"
#define EMAIL_SENDTIME_KEY @"sendtime"
#define EMAIL_SUBJECT_KEY @"subject"
#define EMAIL_UNREADCOUNT_KEY @"unreadcount"


/**
 收到获取邮件未读数应答后，保存到数据库，并刷新界面

 @param resultString 获取邮件未读数应答String
 */
- (void)saveEmailInfo:(NSString *)resultString
{
    NSInteger nowUnreadEmail = [[APPPlatformDOA getDatabase]getUnreadAppMsgCount:[StringUtil getStringValue:GOME_EMAIL_APP_ID]];
    
    NSDictionary *dic = [resultString objectFromJSONString];
    if ([self isEmailAndPasswordCorrect:dic]) {
        int unreadCount = [dic[EMAIL_UNREADCOUNT_KEY]intValue];
        
        NSString *tempStr = [UserDefaults getGomeMailUnreadResult];
        if ([tempStr isEqualToString:resultString] && nowUnreadEmail == unreadCount) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 本次获取和上次获取一致",__FUNCTION__]];
            
            return;
        }
        
        if (unreadCount == 0){
            //    把之前的通知首先设置为已读
            [[APPPlatformDOA getDatabase]setAppMsgReadOfApp:[StringUtil getStringValue:GOME_EMAIL_APP_ID]];
            
        }else{
            [[APPPlatformDOA getDatabase]deleteAllMsgOfApp:[StringUtil getStringValue:GOME_EMAIL_APP_ID]];
        }
        
        
        [UserDefaults saveGomeMailUnreadResult:resultString];
        
        
        if (unreadCount > 0) {
        
            NSString *title = dic[EMAIL_SUBJECT_KEY];
            
            NSString *address = dic[EMAIL_ADDRESS_KEY];
            
            NSString *name = dic[EMAIL_NAME_KEY];
            
            title = [NSString stringWithFormat:@"%@(%@)%@",address,name,title];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 组合后的title是%@",__FUNCTION__,title]];

            
            NSNumber *sendTime = dic[EMAIL_SENDTIME_KEY];
            
            
            //    把毫秒数转换为秒数
            long lSendTime = [sendTime longValue] / 1000;
            
            sendTime = [NSNumber numberWithLong:lSendTime];
            
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            mDic[@"sender_id"] = [StringUtil getStringValue:GOME_EMAIL_APP_ID];
            mDic[@"recver_id"] = [conn getConn].userId;
            mDic[@"sendtime"] = [sendTime stringValue];
            //    设置一个常量 可能这个都没有使用到
            mDic[@"msglen"] = @"100";
            mDic[@"asz_titile"] = title;
            mDic[@"asz_message"] = dic[EMAIL_CONTENT_KEY];
            mDic[@"broadcast_type"] = [NSNumber numberWithInt:appNotice_broadcast];
            
        
            if (unreadCount > 1) {
                for (int i = 0; i < unreadCount - 1; i++) {
                    NSString *msgId = [[conn getConn]getSNewMsgId];
                    mDic[@"msg_id"] = msgId;
                    [[eCloudDAO getDatabase]saveBroadcastToDB:mDic];
                }
            }
            NSString *msgId = [[conn getConn]getSNewMsgId];
            mDic[@"msg_id"] = msgId;
            [[eCloudDAO getDatabase]saveBroadcast:[NSArray arrayWithObject:mDic]];

            UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];
            
            /** 如果是国美的app，并且不是激活状态，并且用户设置了接收通知 那么在保存成功后，显示本地通知 */
            if (appState != UIApplicationStateActive && [NotificationsViewController needAlertWhenRcvMsg]) {
                if ([[eCloudDAO getDatabase] isBroadcastSaved:msgId]) {
                    APPListModel *_model = [[APPPlatformDOA getDatabase] getAPPModelByAppid:GOME_EMAIL_APP_ID];
                    NSString *appName = _model.appname;
                    if (appName.length == 0) {
                        appName = [StringUtil getAppName];
                    }
                    //            应用未读消息数 + 1
                    [UIApplication sharedApplication].applicationIconBadgeNumber =  [UIApplication sharedApplication].applicationIconBadgeNumber + unreadCount;
                    
                    NSString *msgBody = [NSString stringWithFormat:@"%@",title];
                    
                    /** 如果已经成功保存了，那么生成本地通知提醒用户 */
                    UILocalNotification *noti = [[UILocalNotification alloc]init];
                    noti.alertBody = msgBody;
                    noti.alertTitle = appName;
                    
                    if ([NotificationsViewController isNotificationNeedSound]) {
                        noti.soundName = UILocalNotificationDefaultSoundName;
                    }
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
                }
            }
            
            /** 保存提醒后，发出新提醒通知 */
            RemindModel *_model = [[eCloudDAO getDatabase]getRemindByMsgId:msgId];
            if (_model) {
                [[NotificationUtil getUtil]sendNotificationWithName:NEW_REMIND_NOTIFICATION andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:_model forKey:NEW_REMIND_KEY]];
                [LogUtil debug:[NSString stringWithFormat:@"%s 发出新提醒通知",__FUNCTION__]];
            }
        }
    }else{
        [self showEmailWarningView];
    }
}

/** 加密账号 */
- (NSString *)encryptEmailAccount:(NSString *)mail{
    return [AESCipher encryptAES:mail key:GOME_AES_KEY];
}
/** 加密密码 */
- (NSString *)encryptEmailPassword:(NSString *)password{
    return [AESCipher encryptAES:password key:GOME_AES_KEY];
}

/** 解密账号 */
- (NSString *)decryptEmailAccount:(NSString *)encryptMail
{
    NSString *account = [AESCipher decryptAES:encryptMail key:GOME_AES_KEY];
    return account;
}

/** 解密密码 */
- (NSString *)decryptEmailPassword:(NSString *)encryptPassword
{
    NSString *password = [AESCipher decryptAES:encryptPassword key:GOME_AES_KEY];
    return password;
}

@end
