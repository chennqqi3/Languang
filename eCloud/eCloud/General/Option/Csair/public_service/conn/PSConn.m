//
//  PSConn.m
//  eCloud
//
//  Created by Richard on 13-10-29.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

//CMD_ECWX_SYNC_REQ, /** 网信客户端同步公众账号请求, 97. */
//CMD_ECWX_SYNC_RSP, /** 网信客户端同步公众账号响应, 98. */
//CMD_ECWX_SMSG_REQ, /** 网信客户端向公众账号上行消息请求, 99. */
//CMD_ECWX_SMSG_RSP, /** 网信客户端向公众账号推送消息响应, 100. */
//CMD_ECWX_PACC_NOT, /** 公众平台下行消息至网信客户端通知, 101. */

#import "PSConn.h"
#import "LogUtil.h"
#import "eCloudDAO.h"
#import "PublicServiceDAO.h"
#import "Emp.h"
#import "PSSyncResXmlParser.h"
#import "PSUtil.h"
#import "PSMsgJsonParser.h"
#import "ServiceMessage.h"
#import "NewMsgNotice.h"
#import "GzipUtil.h"
#import "ServiceMenuModel.h"
#import "ServiceModel.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"
#import "eCloudDefine.h"

#import "MsgNotice.h"

#import "eCloudConfig.h"

@implementation PSConn

#define ps_timestamp_key @"ps_timestamp_key"


+(void)psSyncRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser
{
    if (![[eCloudConfig getConfig]supportPublicService]) {
        return;
    }
    
	eCloudDAO *db = [eCloudDAO getDatabase];
	Emp *_emp = [db getEmployeeById:fromUser];
	
	char* cFromUser = (char*)[_emp.empCode cStringUsingEncoding:NSUTF8StringEncoding];
	
	int toUser = 0;
	
	NSString *msgType = @"sync";
	char *cMsgType = (char*)[msgType cStringUsingEncoding:NSUTF8StringEncoding];
	
	int oldTimestamp = 0;
	
	char *cText = nil;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *psTimeStamp = [defaults objectForKey:[NSString stringWithFormat:@"%@_%@",ps_timestamp_key,fromUser]];
	if(psTimeStamp && psTimeStamp.length > 0)
	{
		oldTimestamp = psTimeStamp.intValue;
	}
    
//    oldTimestamp = 0;
	
//	IM_API int   CLIENT_ecwx_up(PCONNCB pConnCB, char* fromUser,int toUser, char* msgType, char* text, int sequence, int cmd);

	int ret = CLIENT_ecwx_up(_conncb,
							 		cFromUser,
							 		toUser,
									cMsgType,
							 		cText,
							 		oldTimestamp,
							 		CMD_ECWX_SYNC_REQ
								);
	if(ret != RESULT_SUCCESS)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s, fail",__FUNCTION__]];
	}
}

//保存同步账号
+(void)parseAndSavePS:(NSString*)resStr andFromUser:(NSString *)fromUser
{
	if(resStr && resStr.length > 0)
	{
		PSSyncResXmlParser *_parser = [[PSSyncResXmlParser alloc]init];
		bool result = [_parser parse:resStr];
		if(result)
		{
			//		保存服务号
			PublicServiceDAO *db = [PublicServiceDAO getDatabase];
			BOOL saveSuccess = [db savePublicService:_parser.accounts];
			
			
//			给每个服务号创建自己的资源目录
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *rootPath = [StringUtil getFileDir];
			NSString *dirName;
			NSError *error;
			for(ServiceModel *model in _parser.accounts)
			{
				dirName = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"ps_%d",model.serviceId]];
				BOOL isDirectory;
				BOOL isExist = [fileManager fileExistsAtPath:dirName isDirectory:&isDirectory];
				if(!isExist || !isDirectory)
				{
					if([fileManager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:error])
					{
//						[LogUtil debug:[NSString stringWithFormat:@"%s create dir success",__FUNCTION__]];
					}
					else
					{
						[LogUtil debug:[NSString stringWithFormat:@"%s create dir fail:%@",__FUNCTION__,error.description]];
					}
				}
			}
			
			//		保存时间戳
			if(saveSuccess)
			{
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:[StringUtil getStringValue:_parser.sequence] forKey:[NSString stringWithFormat:@"%@_%@",ps_timestamp_key,fromUser]];				
			}
			

			//		异步下载保存公众号的logo
			for(ServiceModel *serviceModel in _parser.accounts)
			{
				[PSUtil downloadPSLogo:serviceModel];
			}
		}
		[_parser release];
	}
    
}

//保存同步消息
+(NewMsgNotice*)savePSMsg:(NSString*)psMsg
{
	NewMsgNotice *_notice = nil;

	PSMsgJsonParser *_parser = [[PSMsgJsonParser alloc]init];
	if(psMsg && psMsg.length > 0)
	{
		
//		psMsg = [GzipUtil uncompressZippedData:psMsg];
//		NSLog(@"after uncompress,psMsg is %@",psMsg);
		
		ServiceMessage *_msg = [_parser parsePsMsg:psMsg];
//		如果是新闻消息但没有明细，那么属于非正常消息，不用提示用户
		if(_msg.msgType == -1)
		{
			[LogUtil debug:[NSString stringWithFormat:@"%s,收到了图文消息，但解析失败",__FUNCTION__]];
		}
		else
		{
			PublicServiceDAO *db = [PublicServiceDAO getDatabase];
			if([db saveServiceMessage:_msg])
			{
				_notice = [[[NewMsgNotice alloc]init]autorelease];
				_notice.msgType = ps_new_msg_type;
				_notice.serviceId = _msg.serviceId;
				_notice.serviceMsgId = _msg.msgId;
				
//				增加生成本地通知
				[self createLocalNotification:_msg];
			}
			else
			{
				[LogUtil debug:[NSString stringWithFormat:@"%s,收到了图文消息，但保存失败",__FUNCTION__]];				
			}
		}
	}
	[_parser release];
	
	return _notice;
}

+(void)createLocalNotification:(ServiceMessage*)_msg
{
	UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];
	if(appState != UIApplicationStateActive)
	{
//		公众号名称:内容标题
		PublicServiceDAO *psDAO = [PublicServiceDAO getDatabase];
		ServiceModel *serviceModel = [psDAO getServiceByServiceId:_msg.serviceId];
		NSString *serviceName = serviceModel.serviceName;
		NSString *msgBody = @"";
		if(_msg.msgType == ps_msg_type_news)
		{
			if(_msg.detail.count > 0)
			{
				msgBody = [[_msg.detail objectAtIndex:0]msgBody];
			}
		}
		else if (_msg.msgType == ps_msg_type_text)
		{
			msgBody = _msg.msgBody;
		}
        else if (_msg.msgType == ps_msg_type_pic)
        {
//            图片消息
            msgBody = [StringUtil getLocalizableString:@"msg_type_pic"];
        }
		if(serviceName.length > 0 && msgBody.length > 0)
		{
			NSString *newMsg = [NSString stringWithFormat:@"%@:%@",serviceName,msgBody];
			
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

#pragma mark 向公众号发送消息
+(BOOL)sendPSMsg:(CONNCB *)_conncb andFromUser:(NSString*)fromUser andServiceMessage:(ServiceMessage*)message
{
	eCloudDAO *db = [eCloudDAO getDatabase];
	Emp *_emp = [db getEmployeeById:fromUser];
	
	char* cFromUser = (char*)[_emp.empCode cStringUsingEncoding:NSUTF8StringEncoding];
	
	int toUser = message.serviceId;
	
	NSString *msgType = @"upMessage";
	char *cMsgType = (char*)[msgType cStringUsingEncoding:NSUTF8StringEncoding];
	
	int oldTimestamp = 0;
	
	char *cText = [message.msgBody cStringUsingEncoding:NSUTF8StringEncoding];
	
	int ret = CLIENT_ecwx_up(_conncb,
							 cFromUser,
							 toUser,
							 cMsgType,
							 cText,
							 oldTimestamp,
							 CMD_ECWX_SYNC_REQ
							 );
	if(ret != RESULT_SUCCESS)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s, fail",__FUNCTION__]];
		return NO;
	}
	return YES;
}

#pragma mark - 同步公众号菜单
+(void)psMenuListSyncRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser{
    
    eCloudDAO *db = [eCloudDAO getDatabase];
	Emp *_emp = [db getEmployeeById:fromUser];
	
	char* cFromUser = (char*)[_emp.empCode cStringUsingEncoding:NSUTF8StringEncoding];
	
	int toUser = 0;
	
	NSString *msgType = @"updateMenu";
	char *cMsgType = (char*)[msgType cStringUsingEncoding:NSUTF8StringEncoding];
	
	int oldTimestamp = 0;
	
    //构造消息体
    NSMutableArray *appuptimes = [[NSMutableArray alloc] init];
    
    
    NSArray *serviceArr  = [[PublicServiceDAO getDatabase] getAllService:service_type_all];
//    NSLog(@"%s all service is %@",__FUNCTION__,serviceArr);
    
    for (ServiceModel *serviceModel in serviceArr) {
        ServiceMenuModel *menuModel = [[PublicServiceDAO getDatabase] getPSMenuListByPlatformid:serviceModel.serviceId];
        if (menuModel.platformid) {
            NSDictionary *appDic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",menuModel.platformid],@"platformid",[NSString stringWithFormat:@"%@",menuModel.createtime],@"updatetime",nil];
            [appuptimes addObject:appDic];
            [appDic release];
        }
        else{
//            NSLog(@"%s service id is %d",__FUNCTION__,serviceModel.serviceId);
            NSDictionary *appDic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",serviceModel.serviceId],@"platformid",[NSString stringWithFormat:@"%i",0],@"updatetime",nil];
            [appuptimes addObject:appDic];
            [appDic release];
        }
    }
    
    char *cText = NULL;
    if ([appuptimes count]) {
        NSString *dicStr = [appuptimes JSONString];
        NSLog(@"_emp.empCode--------%@",_emp.empCode);
        NSLog(@"dicStr--------%@",dicStr);
        cText = (char*)[dicStr cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    [appuptimes release];
    //	IM_API int   CLIENT_ecwx_up(PCONNCB pConnCB, char* fromUser,int toUser, char* msgType, char* text, int sequence, int cmd);
    
	int ret = CLIENT_ecwx_up(_conncb,
                             cFromUser,
                             toUser,
                             cMsgType,
                             cText,
                             oldTimestamp,
                             CMD_ECWX_SYNC_REQ
                             );
	if(ret != RESULT_SUCCESS)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s, fail",__FUNCTION__]];
	}
}

+(void)parseAndSavePSMenuList:(NSString*)resStr andFromUser:(NSString*)fromUser{
    if ([resStr length]) {
        PSMsgJsonParser  *paser = [[PSMsgJsonParser alloc] init];
        NSMutableArray *resultArr = [paser parsePSMenuList:resStr];
        
        if ([resultArr count]) {
            //保存应用到数据库
            bool success = [[PublicServiceDAO getDatabase] savePSMenuListInfo:resultArr];
            NSLog(@"%s save success APPListInfo %i",__FUNCTION__,success);
        }
    }
}

#pragma mark - 发送菜单命令
+(BOOL)sendPSMenuMsg:(CONNCB *)_conncb andFromUser:(NSString*)fromUser andServiceMessage:(ServiceMessage*)message{
    eCloudDAO *db = [eCloudDAO getDatabase];
	Emp *_emp = [db getEmployeeById:fromUser];
	
	char* cFromUser = (char*)[_emp.empCode cStringUsingEncoding:NSUTF8StringEncoding];
	
	int toUser = message.serviceId;
	
	NSString *msgType = @"menuMessage";
	char *cMsgType = (char*)[msgType cStringUsingEncoding:NSUTF8StringEncoding];
	
	int oldTimestamp = 0;
	
	char *cText = [message.msgBody cStringUsingEncoding:NSUTF8StringEncoding];
	
	int ret = CLIENT_ecwx_up(_conncb,
							 cFromUser,
							 toUser,
							 cMsgType,
							 cText,
							 oldTimestamp,
							 CMD_ECWX_SYNC_REQ
							 );
	if(ret != RESULT_SUCCESS)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s, fail",__FUNCTION__]];
		return NO;
	}
	return YES;
}

//add by shisp 把公众号的推送消息 由一个结构体 转换为 一个对象
+ (MsgNotice*)getMsgNoticeObject:(ECWX_PUSH_NOTICE *)psPushNotice
{
    MsgNotice *_msg = [[[MsgNotice alloc]init]autorelease];
    
     NSString *psMsg = [StringUtil getStringByCString:psPushNotice->aszContent];
    [LogUtil debug:[NSString stringWithFormat:@"receive ps msg is %@",psMsg]];
    
    //    消息内容
    _msg.msgBody = psMsg;
    
//    是否离线消息
    _msg.isOffline = psPushNotice->cIsOfflineMsg;
    
//    离线消息条数
    _msg.offMsgTotal = psPushNotice->wOfflineTotal;
    
//消息id
    _msg.msgId = psPushNotice->ddwMsgID;
    
//    消息网元Id
    _msg.netID = psPushNotice->dwNetID;
    
    return _msg;
}


@end
