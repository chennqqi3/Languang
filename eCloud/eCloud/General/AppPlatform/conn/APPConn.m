//
//  APPConn.m
//  eCloud
//
//  Created by Pain on 14-6-23.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

typedef struct LightAppUrl
{
    /** 待办总条数 */
    unsigned int        m_nTotal;
    
    /** URL信息 */
    char				aszUrl[200];
    
    /** Title */
    char				szTitle[200];
    
}LightAppUrl;

#import "APPConn.h"
#import "ApplicationManager.h"

#import "RemindModel.h"
#import "OpenCtxDefine.h"

#import "UIAdapterUtil.h"

#import "UserDefaults.h"
#import "Emp.h"
#import "eCloudNotification.h"
#import "eCloudUser.h"
#import "NotificationsViewController.h"

#import "JSONKit.h"
#import "APPJsonParser.h"
#import "eCloudDAO.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "APPPushNotification.h"
#import "NotificationUtil.h"
#import "APPUtil.h"
#import "NewMsgNotice.h"
#import "APPStateRecord.h"
#import "APPToken.h"
#import "MassConn.h"
#import "MsgNotice.h"
#import "conn.h"
#import "DownloadGuideImage.h"

@interface APPConn ()

/** 同步轻应用的响应数据 */
@property (nonatomic,retain) NSMutableData *dataForApp;

@property (nonatomic,retain) APPConn *appConn;
@end

@implementation APPConn


#pragma mark - 同步应用请求
+(void)appSyncRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser{
//    eCloudDAO *db = [eCloudDAO getDatabase];
//	Emp *_emp = [db getEmployeeById:fromUser];
//	char* cFromUser = (char*)[_emp.empCode cStringUsingEncoding:NSUTF8StringEncoding];
//	
//    //构造消息体
//    NSMutableArray *appuptimes = [[NSMutableArray alloc] init];
//    NSArray *appListArr = [[APPPlatformDOA getDatabase] getAPPList];
//    for (APPListModel *appModel in appListArr) {
//        NSDictionary *appDic = [[NSDictionary alloc] initWithObjectsAndKeys:appModel.appid,@"appid",appModel.uptime,@"uptime",nil];
//        [appuptimes addObject:appDic];
//        [appDic release];
//    }
//    
//    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:_emp.empCode,@"usercode",appuptimes,@"appuptimes", nil];
//    NSString *dicStr = [dic JSONString];
//    
//    
//    NSLog(@"_emp.empCode--------%@",_emp.empCode);
//    NSLog(@"dicStr--------%@",dicStr);
//    
//    
//    char *_msg = (char*)[dicStr cStringUsingEncoding:NSUTF8StringEncoding];
//    [appuptimes release];
//    
//    
//    int ret = 0;//CLIENT_app_up(_conncb, cFromUser, _msg, CMD_APP_SYNC_REQ);
//    
//    NSLog(@"ret-------%i",ret);
//    
//	if(ret != RESULT_SUCCESS)
//	{
//		[LogUtil debug:[NSString stringWithFormat:@"%s, fail",__FUNCTION__]];
//	}
}

+ (void)appSyncRequestOption:(CONNCB *)_conncb andFromUser:(NSString*)fromUser{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    if (CREATE_ORG_DATABASE_FILE) {
        /** 如果是生成数据库文件，那么暂时不同步轻应用 */
        return;
    }
    
    if ([UIAdapterUtil isGOMEApp]) {
        NSString *appBannerStr = [[ServerConfig shareServerConfig]getGomeAppBannerUrl];
        NSURL *appBannerUrl = [NSURL URLWithString:appBannerStr];
        
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
            [LogUtil debug:[NSString stringWithFormat:@"%s 获取banner配置 %@",__FUNCTION__,appBannerUrl]];

            NSData *result = [NSData dataWithContentsOfURL:appBannerUrl];
            if (result.length) {
                NSDictionary *_dic = [result objectFromJSONData];
                [LogUtil debug:[NSString stringWithFormat:@"%s 获取到的banner配置如下 %@",__FUNCTION__,[_dic description]]];
//                样板数据
//                {
//                    data =     {
//                        appid = 0;
//                        compid = 5;
//                        playimage = "http://imweb.corp.gome.com.cn/download/banner1.jpg|http://imweb.corp.gome.com.cn/download/banner2.jpg";
//                        playinterval = 4;
//                    };
//                    message = 10000;
//                    status = success;
//                }
                
                NSString *status = _dic[@"status"];
                if ([status isEqualToString:@"success"]) {
                    NSDictionary *dataDic = _dic[@"data"];
                    NSString *playImage = dataDic[@"playimage"];
                    
//                    playImage = @"http://imweb.corp.gome.com.cn/images/ios_code.png|http://imweb.corp.gome.com.cn/images/logo.png|http://u1.img.mobile.sina.cn/public/files/image/600x150_img58b2eebbcc17c.png";
                    
                    NSArray *playImageArray = [playImage componentsSeparatedByString:@"|"];
                    
                    if (playImageArray.count) {
                        [UserDefaults saveGomeAppBanner:playImageArray];
                    }
                    
                    NSNumber *playInterval = dataDic[@"playinterval"];
                    if (playInterval) {
                        [UserDefaults saveGomeAppBannerInterval:playInterval];
                    }
                    /** 发出通知 */
                    [[NotificationUtil getUtil]sendNotificationWithName:GOME_APP_BANNER_UPDATE_NOTIFICATION andObject:nil andUserInfo:nil];
                }
            }
//        });
    }
    
    /*
    // 异步实现老是没有响应数据
    self.dataForApp = [[NSMutableData alloc]init];
//    // 组合一个搜索字符串
    NSString *urlStr = [NSString stringWithFormat:@"http://mop.longfor.com:8080/FilesService/appuser?userid=%d&usercode=shaomx&compid=5&logintype=1", 1];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    //发起请求，定义代理
    [NSURLConnection connectionWithRequest:request delegate:self];
    */
    
    // http://mop.longfor.com:8080/FilesService/appuser?userid=1&usercode=shaomx&compid=5&logintype=1
    
//    这里采用同步方式 同步 保存 轻应用 数据，异步方式可能会引起 死锁 add by shisp
//    dispatch_queue_t queue = dispatch_queue_create("applist request", NULL);
//    
//    dispatch_async(queue, ^{
        //同步请求
//        NSString *urlStr = [NSString stringWithFormat:@"http://mop.longfor.com:8080/FilesService/appuser?userid=%d&usercode=shaomx&compid=5&logintype=2", 101];
    
        eCloudDAO *db = [eCloudDAO getDatabase];
        Emp *_emp = [db getEmployeeById:fromUser];
        NSString *urlStr = [[[eCloudUser getDatabase]getServerConfig] getApplistRequestUrl:fromUser andUserCode:_emp.empCode];
        NSURL * URL = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
        NSURLRequest * request = [[[NSURLRequest alloc]initWithURL:URL]autorelease];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (data == nil) {
            [LogUtil debug:[NSString stringWithFormat:@"%s,获取轻应用的信息失败",__FUNCTION__]];
            return ;
        }
        NSArray *dicArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!error) {
            [LogUtil debug:[NSString stringWithFormat:@"%s,获取到的轻应用同步信息 = %@",__FUNCTION__,dicArr]];

            /** 将返回的json数据放入model中 */
            APPJsonParser  *paser = [[[APPJsonParser alloc] init]autorelease];
            NSMutableArray *resultArr = [[[NSMutableArray alloc]init]autorelease];
            
            for (NSDictionary *dic in dicArr) {
                APPListModel *appModel = [paser getAPPListModelFromDictionary:dic];
//                [LogUtil debug:[NSString stringWithFormat:@"%s appid is %d appname is %@ updatetype is %d",__FUNCTION__,appModel.appid,appModel.appname,appModel.updatetype]];
                
                /** 用『文件助手』的apphomepage当做广告页链接 by yanlei */
                if ([UIAdapterUtil isHongHuApp]) {
                    if (appModel.appid == 103 && [eCloudConfig getConfig].supportGuidePages) {
                        [[DownloadGuideImage shareDownloadGuideImageSingle] downloadGuideImage:appModel.apphomepage];
        
                        if (appModel.status == nil) {
                            
                            appModel.status = @"1";

                        }
                        [UserDefaults setGuideImageStatus:[NSString stringWithFormat:@"%@",appModel.status]];
                        
                    }
                    
                    /** 办公页面过滤掉工作圈 */
                    if (appModel.appid != 111) {
                        
                        [resultArr addObject:appModel];
                    }
                }else{

                    [resultArr addObject:appModel];
                }
                
//                if (appModel.appid == 502) {
//                    
//                    [[DownloadGuideImage shareDownloadGuideImageSingle] downloadGuideImage:appModel.apphomepage];
//                }

            }
            
            if ([resultArr count]) {
                /** 获取数据库中的应用列表 */
                NSArray *appListArr = [[APPPlatformDOA getDatabase] getAPPList];
                for (APPListModel *localAppModel in appListArr) {
                    for (int i = 0;i < resultArr.count;i++) {
                        APPListModel *appModel = resultArr[i];
                        if (localAppModel.appid == appModel.appid) {
                            break;
                        }
                        if (i == resultArr.count-1) { // && localAppModel.appauthtype == 0
                            
                            /** 代表返回的应用数组中不在包含本地的应用，进行删除标识 */
                            [[APPPlatformDOA getDatabase] deleteAPPModelUpdatetype:localAppModel];
                        }
                    }
                }
            
                /** 保存应用到数据库 */
                bool success = [[APPPlatformDOA getDatabase] saveAPPListInfo:resultArr];
                NSLog(@"%s save success APPListInfo %i",__FUNCTION__,success);
                
                eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                _notificationObject.cmdId = refresh_app_list;
                [[NotificationUtil getUtil]sendNotificationWithName:APPLIST_UPDATE_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
                
                /** 异步下载应用图标 */
                for(APPListModel *appModel in resultArr){
                    if (appModel.logopath && ![appModel.logopath isEqualToString:@""] && appModel.updatetype != 3) {
        
                        /** 下载完最后一张带有logo的图片后，发出通知刷新界面 */
                        [APPUtil downloadMyAPPLogo:appModel];
                        
//                        [APPUtil webCacheWithAPPModel:appModel];
//                        [APPUtil downloadAPPSummaryPics:appModel];
                    }
                }
            }
        }else{
            [LogUtil debug:[NSString stringWithFormat:@"%s,error = %@",__FUNCTION__,[error localizedDescription]]];
        }
//    });
//    
//    dispatch_release(queue);

}


#pragma mark - 保存应用列表
+(void)parseAndSaveAPPListInfo:(NSString*)resStr{
    if ([resStr length]) {
        APPJsonParser  *paser = [[[APPJsonParser alloc] init]autorelease];
        NSMutableArray *resultArr = [paser parseAPPListModel:resStr];
        
        if ([resultArr count]) {
            /** 保存应用到数据库 */
            bool success = [[APPPlatformDOA getDatabase] saveAPPListInfo:resultArr];
            NSLog(@"%s save success APPListInfo %i",__FUNCTION__,success);
            
            /** 异步下载应用图标 */
            for(APPListModel *appModel in resultArr){
                if (appModel.updatetype != 3) {
                    [APPUtil getAPPLogo:appModel];
                    [APPUtil webCacheWithAPPModel:appModel];
                    [APPUtil downloadAPPSummaryPics:appModel];
                }
            }
        }
    }
}

#pragma mark - 保存应用平台推送消息
+(NewMsgNotice*)saveAPPMsg:(NSString*)psMsg
{
	NewMsgNotice *_notice = nil;
    
	APPJsonParser *_parser = [[[APPJsonParser alloc]init]autorelease];
	if(psMsg && psMsg.length > 0)
	{
        
		APPPushNotification *_msg = [_parser parseAPPPushNotificationModel:psMsg];
		APPPlatformDOA *db = [APPPlatformDOA getDatabase];
        if([db saveAPPPushNotification:_msg])
        {
            _notice = [[[NewMsgNotice alloc]init]autorelease];
            _notice.msgType = app_new_msg_type;
            _notice.appid = _msg.appid;
            _notice.appMsgId = _msg.msgId;

            /** 增加生成本地通知 */
            [self createLocalNotification:_msg];
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,收到了第三方应用推送消息，但保存失败",__FUNCTION__]];
        }
	}
	
	return _notice;
}

+(void)createLocalNotification:(APPPushNotification*)_msg
{
	UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];
	if(appState != UIApplicationStateActive)
	{

        /** 应用名称:内容标题 */
		APPPlatformDOA *appDAO = [APPPlatformDOA getDatabase];
		APPListModel *appModel = [appDAO getAPPModelByAppid:_msg.appid];
		NSString *appName = appModel.appname;
		NSString *title = _msg.title;
        
		if(appName.length > 0 && title.length > 0)
		{
			NSString *newMsg = [NSString stringWithFormat:@"%@:%@",appName,title];
			
			UILocalNotification *noti = [[UILocalNotification alloc]init];
			noti.alertBody = newMsg;
			noti.soundName = UILocalNotificationDefaultSoundName;
            if (![UIAdapterUtil isCombineApp]) {
                [UIApplication sharedApplication].applicationIconBadgeNumber++;                
            }
			[[UIApplication sharedApplication] presentLocalNotificationNow:noti];
			[noti release];
		}
	}
}

#pragma mark - 保存应用平台token通知
+ (void)saveAppToken:(NSString *)appTokenStr{
    NSLog(@"appTokenStr---------%@",appTokenStr);
    APPJsonParser *_parser = [[[APPJsonParser alloc]init]autorelease];
	if(appTokenStr && appTokenStr.length > 0)
	{
        
		APPToken *appToken = [_parser parseAPPTokenModel:appTokenStr];
        NSString *tokenStr = [NSString stringWithFormat:@"%@",appToken.token];
        [[NSUserDefaults standardUserDefaults] setObject:tokenStr forKey:APP_TOKEN];
    }
}


#pragma mark - 统计上报
+(void)sendAPPStateRecordRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser  andAPPStateRecord:(APPStateRecord*)appStateRec{
    eCloudDAO *db = [eCloudDAO getDatabase];
	Emp *_emp = [db getEmployeeById:fromUser];
	char* cFromUser = (char*)[_emp.empCode cStringUsingEncoding:NSUTF8StringEncoding];
	
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:appStateRec.appid,@"appid",[NSString stringWithFormat:@"%i",appStateRec.optype],@"optype",appStateRec.optime,@"optime", nil];
    NSString *dicStr = [dic JSONString];
    
    NSLog(@"_emp.empCode--------%@",_emp.empCode);
    NSLog(@"dicStr--------%@",dicStr);
    
    char *_msg = (char*)[dicStr cStringUsingEncoding:NSUTF8StringEncoding];
    int ret = 0;//CLIENT_app_up(_conncb, cFromUser, _msg, CMD_APP_DATA_REPORT);
    
    NSLog(@"ret-------%i",ret);
	if(ret != RESULT_SUCCESS)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s, fail",__FUNCTION__]];
	}
    else{
        /** 保存数据统计记录 */
        [[APPPlatformDOA getDatabase] saveOneAPPStateRecord:appStateRec];
    }
}

/** 处理收到的新代办的通知 龙湖 */
+ (void)processBroadcastNotice:(BROADCASTNOTICE*)info
{
    if ([UIAdapterUtil isCsairApp])
    {
        [self processCsairAppBroadcastNotice:info];
    }else if ([UIAdapterUtil isHongHuApp]){
        [self processLongHuBroadcastNotice:info];
    }
    else
    {
        [self processOtherAppBroadcastNotice:info];
    }
}
+ (void)processCsairAppBroadcastNotice:(BROADCASTNOTICE*)info
{
    /** 发送者 */
    NSString *senderID = [StringUtil getStringValue: info->dwSenderID];

    /** 接收者 */
    NSString *recverID = [StringUtil getStringValue: info->dwRecverID];

    /** 发送时间 */
    NSString *sendTime = [StringUtil getStringValue:info->dwSendTime];

    /** 消息id */
    NSString *msgID = [NSString stringWithFormat:@"%lld",info->dwMsgID];// [StringUtil getStringValue:info->dwMsgID];

    /** 推送类型 对于南航来说 为提醒的推送类型 具体含义由南航自己定义 */
    int appPushType = info->cMsgType;

    /** 消息长度 */
    NSString *msgLen=[StringUtil getStringValue:info->dwMsgLen];

    /** 标题 */
    NSString *title = [StringUtil getStringByCString:info->aszTitile];

    /** 是否已经保存过该条广播 */
    if ([[eCloudDAO getDatabase] isBroadcastSaved:msgID]) {
        [LogUtil debug:[NSString stringWithFormat:@"%s broadcast has saved",__FUNCTION__]];
        return;
    }

    /** 取出结构体内的参数 */
    LightAppUrl *lightAppUrl = (LightAppUrl *)info->aszMessage;
    
    NSString *tempUrl = [StringUtil getStringByCString:lightAppUrl->aszUrl];
    NSString *tempTitle = [StringUtil getStringByCString:lightAppUrl->szTitle];
    int unread = lightAppUrl->m_nTotal;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,APP_PUSH_URL,tempTitle,APP_PUSH_DETAIL,[NSNumber numberWithInt:unread],APP_PUSH_UNREAD,[NSNumber numberWithInt:appPushType],APP_PUSH_TYPE,nil];
    
    NSString *message = [dic JSONString];
    
    int broadcastType = info->cAllReply;
    
    dic = [NSDictionary dictionaryWithObjectsAndKeys:senderID,@"sender_id",recverID,@"recver_id",msgID,@"msg_id",sendTime,@"sendtime",msgLen,@"msglen",title,@"asz_titile",message,@"asz_message",[NSNumber numberWithInt:broadcastType],@"broadcast_type", nil];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s %@",__FUNCTION__,[dic description]]];
    
    [[eCloudDAO getDatabase] saveBroadcast:[NSArray arrayWithObject:dic]];

    /** 保存提醒后，发出新提醒通知 */
    RemindModel *_model = [[eCloudDAO getDatabase]getRemindByMsgId:msgID];
    if (_model) {
        [[NotificationUtil getUtil]sendNotificationWithName:NEW_REMIND_NOTIFICATION andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:_model forKey:NEW_REMIND_KEY]];
        [LogUtil debug:[NSString stringWithFormat:@"%s 发出新提醒通知",__FUNCTION__]];
    }
}

//比较通用的保存应用消息的方法
+ (void)processOtherAppBroadcastNotice:(BROADCASTNOTICE*)info
{
    /** 发送者 */
    NSString *senderID = [StringUtil getStringValue: info->dwSenderID];

    /** 接收者 */
    NSString *recverID = [StringUtil getStringValue: info->dwRecverID];

    /** 发送时间 */
    NSString *sendTime = [StringUtil getStringValue:info->dwSendTime];

    /** 消息id */
    NSString *msgID = [NSString stringWithFormat:@"%llu",info->dwMsgID];// [StringUtil getStringValue:info->dwMsgID];

    /** 推送类型 对于南航来说 为提醒的推送类型 具体含义由南航自己定义 */
    int appPushType = info->cMsgType;

    /** 消息长度 */
    NSString *msgLen=[StringUtil getStringValue:info->dwMsgLen];

    /** 标题 */
    NSString *title = [StringUtil getStringByCString:info->aszTitile];

    /** 把前面10个空的字节去掉，不然转换成NSString时转换不成功 */
    char *content = info->aszMessage;
    content += 10;
    NSString *message = [StringUtil getStringByCString:content];

    int broadcastType = info->cAllReply;
    
//    测试代码
//    broadcastType = broadcast_msg_type_agent_notice;
//    
//    NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"会议通知内容 %@",sendTime],@"MsgContent",[NSString stringWithFormat:@"会议通知扩展 %@",sendTime],@"Ext",nil];
//    
//    message = [_dic JSONString];
//    senderID = title;
//    
//    title = [NSString stringWithFormat:@"会议通知标题 %@",sendTime];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:senderID,@"sender_id",recverID,@"recver_id",msgID,@"msg_id",sendTime,@"sendtime",msgLen,@"msglen",title,@"asz_titile",message,@"asz_message",[NSNumber numberWithInt:broadcastType],@"broadcast_type", nil];

    /** 是否已经保存过该条广播 */
    if ([[eCloudDAO getDatabase] isBroadcastSaved:msgID]) {
        [LogUtil debug:[NSString stringWithFormat:@"%s broadcast has saved",__FUNCTION__]];
        return;
    }

    [[eCloudDAO getDatabase] saveBroadcast:[NSArray arrayWithObject:dic]];
    
    UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];

    /** 如果是国美的app，并且不是激活状态，并且用户设置了接收通知 那么在保存成功后，显示本地通知 */
    if ([UIAdapterUtil isGOMEApp] && appState != UIApplicationStateActive && [NotificationsViewController needAlertWhenRcvMsg]) {
        if ([[eCloudDAO getDatabase] isBroadcastSaved:msgID]) {
            APPListModel *_model = [[APPPlatformDOA getDatabase] getAPPModelByAppid:senderID.integerValue];
            NSString *appName = _model.appname;
            if (appName.length == 0) {
                appName = [StringUtil getAppName];
            }
            //            应用未读消息数 + 1
            [UIApplication sharedApplication].applicationIconBadgeNumber =  [UIApplication sharedApplication].applicationIconBadgeNumber + 1;

            NSString *msgBody = [NSString stringWithFormat:@"%@",title];

            /** 如果已经成功保存了，那么生成本地通知提醒用户 */
            UILocalNotification *noti = [[UILocalNotification alloc]init];
            noti.alertBody = msgBody;
            noti.alertTitle = appName;
            
            if ([NotificationsViewController isNotificationNeedSound]) {
                noti.soundName = UILocalNotificationDefaultSoundName;
            }
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
            [noti release];

        }
    }

    /** 保存提醒后，发出新提醒通知 */
    RemindModel *_model = [[eCloudDAO getDatabase]getRemindByMsgId:msgID];
    if (_model) {
        [[NotificationUtil getUtil]sendNotificationWithName:NEW_REMIND_NOTIFICATION andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:_model forKey:NEW_REMIND_KEY]];
        [LogUtil debug:[NSString stringWithFormat:@"%s 发出新提醒通知",__FUNCTION__]];
    }
}
     
+ (void)processLongHuBroadcastNotice:(BROADCASTNOTICE*)info
{
    /** 无论是前台运行还是后台运行，我的界面都要能收通知 */
    /** 判断用户是否在前台运行，如果是，那么查看未读条数，如果大于0，那么发出通知，我的界面接收通知，显示有新的代办 */
    /** 如果是在后台运行，那么就需要生成本地通知， */
    
    NSString *_title = [StringUtil getStringByCString:info->aszTitile];
//    _title = @"123";
    int appId = info->dwSenderID;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s title is %@ appId is %d ",__FUNCTION__,_title,info->dwSenderID]];
    
    UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];
    if(_title.length > 0){
        
        NSString *msgBody = [NSString stringWithFormat:@"%@",_title];
        
        int appId = info->dwSenderID;
        APPListModel *_model = [[APPPlatformDOA getDatabase] getAPPModelByAppid:appId];
        NSString *appName = _model.appname;
        if (appName.length == 0) {
            appName = [StringUtil getAppName];
        }
        LightAppUrl *lightAppUrl = (LightAppUrl *)info->aszMessage;
        char *tempChar = lightAppUrl->aszUrl;
        NSString *tempUrl = [StringUtil getStringByCString:tempChar];

        /** 如果这里收到的广播的内容和用户点击启动应用的通知一样，那么就不再继续处理了 */
        if ([ApplicationManager getManager].notificationUserInfo) {
            int tempNotiAppId = [[ApplicationManager getManager].notificationUserInfo[KEY_NOTIFICATION_APP_ID] intValue];
            NSString *tempNotiUrl = [ApplicationManager getManager].notificationUserInfo[KEY_NOTIFICATION_APP_URL];
            NSString *tempNotiMessage = [ApplicationManager getManager].notificationUserInfo[KEY_NOTIFICATION_MESSAGE];
            
            if (appId == tempNotiAppId && [tempUrl isEqualToString:tempNotiUrl] && [msgBody isEqualToString:tempNotiMessage]) {
                [LogUtil debug:[NSString stringWithFormat:@"%s appid 一样 url一样 消息内容一样 不再弹出自定义的通知",__FUNCTION__]];
                return;
            }
        }
        
        NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:info->dwSenderID],KEY_NOTIFICATION_APP_ID,[NSNumber numberWithInt:notification_agent_msg],KEY_NOTIFICATION_MSG_TYPE,tempUrl,KEY_NOTIFICATION_APP_URL,msgBody,KEY_NOTIFICATION_MESSAGE,appName,KEY_NOTIFICATION_TITLE, nil];

        if ((_model && [_model.apphomepage rangeOfString:SHOW_COUNT_NUM options:NSCaseInsensitiveSearch].length > 0) || _model.appid == LONGHU_MAIL_APP_ID) {
            
        }else{
            [UserDefaults saveRedDotOfAppId:appId andRedDot:YES];
//            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults getAppId]];
//            [dict setValue:@"YES" forKey:[NSString stringWithFormat:@"%d",appId]];
//            [UserDefaults saveAppId:dict];
        }
        if ([NotificationsViewController needAlertWhenRcvMsg]) {
            
            if (appState == UIApplicationStateActive) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 用户在前台运行",__FUNCTION__]];
                [[conn getConn] performSelectorOnMainThread:@selector(presentNotificationWhenAppActive:) withObject:_dic waitUntilDone:YES];
            }else{
                UILocalNotification *noti = [[UILocalNotification alloc]init];
                noti.alertBody = msgBody;
                
                noti.alertTitle = appName;
                
                if ([NotificationsViewController isNotificationNeedSound]) {
                    noti.soundName = UILocalNotificationDefaultSoundName;
                }
                
                //            增加保存 appid
                noti.userInfo = _dic;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
                [noti release];
            }
        }

        /** 刷新界面 */
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = rcv_app_agentunread;
        
        [[NotificationUtil getUtil]sendNotificationWithName:APPLIST_RECUNREAD_NOTIFICATION andObject:_notificationObject andUserInfo:_dic];
    }
}

#pragma mark - 请求链接代理
// 分批返回数据
/*
- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)data {
    [self.dataForApp appendData:data];
    NSLog(@"%@", self.dataForApp);
}

// 数据完全返回完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *dataString =  [[NSString alloc] initWithData:self.dataForApp encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.dataForApp options:NSJSONReadingMutableContainers error:&error];
    
    if (!error) {
        [LogUtil debug:[NSString stringWithFormat:@"%s,获取到的轻应用同步信息 = %@",__FUNCTION__,dic]];
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"%s,error = %@",__FUNCTION__,[error localizedDescription]]];
    }
    NSLog(@"%@", dataString);
}
*/
@end
