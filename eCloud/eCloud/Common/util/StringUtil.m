
//  StringUtil.m
//  eCloud
//
//  Created by robert on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "StringUtil.h"

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#endif

#ifdef _BGY_FLAG_
#import "BGYMoreViewControllerARC.h"
#endif

#import "IOSSystemDefine.h"
#import "CrashLogger.h"
#import "ASIHTTPRequest.h"
#import "eCloudDefine.h"
#import "eCloudUser.h"
#import "ConvRecord.h"
#import "JSONKit.h"

#import "ApplicationManager.h"
#import "LocationMsgUtil.h"

#import "UserDisplayUtil.h"
#import "UserDefaults.h"

#import "JSONKit.h"
#import "AppDelegate.h"
#import "ImageSet.h"
#import "eCloudDAO.h"
#import "LanUtil.h"
#import "ImageUtil.h"
#import "talkSessionUtil.h"
#import <CommonCrypto/CommonDigest.h>

#import "eCloudDAO.h"
#import "ConvNotification.h"
#import "conn.h"
#import "UserDefaults.h"

//#import "AFHTTPRequestOperationManager.h"
// 获取当前设备可用内存及所占内存的头文件
#import <sys/sysctl.h>
#import <mach/mach.h>

#import "ZipArchive.h"
#import "EmpLogoConn.h"

#import "Conversation.h"

#import <sys/utsname.h>

#import "md5.h"

#ifdef _TAIHE_FLAG_
#import "AESCipher.h"
#endif

#ifdef _LANGUANG_FLAG_

#import "RedPacketModelArc.h"
#import "LANGUANGAppMsgModelARC.h"

#endif
#define FileHashDefaultChunkSizeForReadingData 1024*8
#define DEFAULT_VOID_COLOR [UIColor whiteColor]

//百度地图龙湖测试环境
#define LONG_FOR_TEST_BAIDU_MAP_APPKEY @"0GEOrPD21G3X81IADHaBVAaxzFbD3L0m"

//百度地图龙湖正式正式环境
#define LONG_FOR_BAIDU_MAP_APPKEY @"1VruF3CkXvBiuFywS8ypHEL2vUYvN4AF"

//百度地图泰禾
#define TAI_HE_BAIDU_MAP_APPKEY @"GpTP0eMdsyK37Sq1xYPl1jNNooos6GbU"

//百度地图泰禾测试
#define TAI_HE_TEST_BAIDU_MAP_APPKEY @"iCs9c60hlfLKhmdAfay2uNVeLOozPaRS"

//百度地图蓝光正式
#define LAN_GUANG_BAIDU_MAP_APPKEY @"05mlFHDDS4g9sHzS02GCYu4xFIVOyHIx"

//百度地图蓝光测试
#define LAN_GUANG_TEST_BAIDU_MAP_APPKEY @"ygDpZKmnSeeLEhB93RDVoRNHCxsvpLSg"

//龙湖友盟key
#define LONG_FOR_U_M_SDK_APPKEY @"58257346766613069900008a"


#define ITEM_COUNT (IS_IPHONE_5 ? 5:(IS_IPHONE_6 ? 6:6))

@implementation StringUtil

static NSBundle *appBundle;

+ (NSString *)getHomeDir
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
}

//获取临时文件路径
+ (NSString *)getTempDir
{
    NSString *tmpDir = NSTemporaryDirectory();
    return tmpDir;
    
}

+ (NSString *)getGuideImagePath
{
    NSString *imagePath = [self getHomeDir];
    NSString *rcvFilePath = [imagePath stringByAppendingPathComponent:rcv_file_path];
    if([self createFolderForPath:rcvFilePath])
        return rcvFilePath;
    return imagePath;
}
#pragma mark日志文件的名称及路径
+(NSString*)getLogFilePath
{
	return [[self getHomeDir]stringByAppendingPathComponent:@"eCloud.log"];
}

+(NSString*)getFileDir
{
	NSString *appPath = [StringUtil getHomeDir];
	conn *_conn = [conn getConn];
    NSString *filePath = [appPath stringByAppendingPathComponent:_conn.userId];
	return filePath;
}

+(NSString*)getMapPath:(NSString*)latitude withLongitude:(NSString*)longitude
{
    NSString *filePath = [self newRcvFilePath];
    NSString *mapPath = [NSString stringWithFormat:@"%@/%@-%@.png",filePath,latitude,longitude];
    
    return mapPath;
}

//增加获取数据库路径的方法
+ (NSString *)getDataDbFilePath
{
    NSString *dbPath = [[self getFileDir]stringByAppendingPathComponent:ecloud_db];
    return dbPath;
}

//下载ecloud_user数据库 后的保存路径
+ (NSString *)getDownloadecloudUserDbPath
{
    NSString *dbPath = [[self getFileDir]stringByAppendingPathComponent:ecloud_user_db];
    return dbPath;
}

+(NSString*)getEmpLogoPath:(NSString*)empLogo
{
	NSString* picpath = [[self newLogoPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",empLogo]];
	return picpath;
}
//更换背景图片
+(NSString*)newChatBackgroudPath
{
	NSString *filePath = [self getFileDir];
	NSString *chatBackGroudFilePath = [filePath stringByAppendingPathComponent:chat_backgroud_file_path];
	if([self createFolderForPath:chatBackGroudFilePath])
		return chatBackGroudFilePath;
	return chatBackGroudFilePath;
}
#pragma mark 异步下载头像，下载成功后，保存在本地
/*
+(BOOL)downloadUserLogo:(NSString*)empId andLogo:(NSString*)logo andNeedSaveUrl:(bool)needSaveUrl
{

    __block BOOL downloadSuccess = NO;
	//	判断本地是否有头像，如果没有就下载
	if(logo && logo.length > 0)
	{
		NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:logo];
		UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
		if(img == nil)
		{
			dispatch_queue_t _queue = dispatch_queue_create("download_emp_logo", NULL);
			dispatch_async(_queue, ^{
                ServerConfig *serverConfig = [ServerConfig shareServerConfig];

				NSURL *url = [NSURL URLWithString:[serverConfig getLogoUrlByEmpId:empId]];
                // [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLogoFileDownloadUrl],logo]];
                
				NSData *imageData = [NSData dataWithContentsOfURL:url];
				if(imageData != nil && imageData.length > 0)
				{
					//				先删除原来的头像
					[StringUtil deleteUserLogoIfExist:empId];
					
					if([imageData writeToFile:logoPath atomically:YES])
					{
						UIImage *offlineimage=[ImageSet setGrayWhiteToImage:[UIImage imageWithData:imageData]];
						NSString *offlinepicPath = [StringUtil getOfflineLogoFilePathBy:empId andLogo:logo];
						NSData *dataObj = UIImageJPEGRepresentation(offlineimage, 1.0);
						[dataObj writeToFile:offlinepicPath atomically:YES];
 
						NSLog(@"头像下载成功保存成功，%@",logo);
						if(needSaveUrl)
						{
							//		修改用户的头像url
							eCloudDAO *db = [eCloudDAO getDatabase];
							[db updateEmpLogo:empId andLogo:logo];
						}
                        
                        [self sendUserlogoChangeNotification:empId];
                        
                        downloadSuccess = YES;
 					}
					else
					{
						NSLog(@"头像下载成功保存失败，%@",logo);
					}
				}
				else
				{
					NSLog(@"头像下载失败%@",logo);
				}
			} );
		}
	}
    return downloadSuccess;
}
*/
//因为通用的下载头像的方法 增加了一个状态的判断，所以登录成功后，下载当前登录用户的头像，就要提供一个单独的方法
+ (void)downloadCurUserLogo
{
    conn *_conn = [conn getConn];
    NSString *empId = _conn.userId;
    NSString *logo = default_emp_logo;
    
    /*
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"netsense" forHTTPHeaderField:@"netsense"];
    // 默认传输的数据类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    ServerConfig *serverConfig = [ServerConfig shareServerConfig];
    // 如果已经启动了下载，就不再发起下载
    [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
    
    // 先删除原来的头像
    [StringUtil deleteUserLogoIfExist:empId];
    NSString *url = [serverConfig getLogoUrlByEmpId:empId];
    [manager GET:url parameters:nil success:^(IM_AFHTTPRequestOperation *operation, id responseObject) {
        
        id info = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"info=========%@",info);
        UIImage *curImage = [UIImage imageWithData:responseObject];
        //                        保存头像缩略图
        NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:logo];
        
        BOOL success= [UIImageJPEGRepresentation(curImage, 1.0) writeToFile:logoPath atomically:YES];
        
        if(success)
        {
            // 生成小图
            [self createAndSaveMicroLogo:curImage andEmpId:empId andLogo:logo];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",logo,@"emp_logo", nil];
            [self sendUserlogoChangeNotification:dic];
            
            // 下载大图
            [self downloadBigUserLogoByEmpId:empId andEmpLogo:logo];
            [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];
        }
        
    } failure:^(IM_AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"当前用户头像下载失败%@",error);
    }];
    
    */
    
    
    
    
 //   /*
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
//    不去下载和保存
//    [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"EMP_ID", nil];
//    UIImage *empLogo = [[HuaXiaOrgUtil getUtil]getHXEmpLogoByEmpId:empId.intValue withUserInfo:userInfo withCompleteHandler:^(UIImage *empLogo, NSDictionary *userInfo) {
//        NSString *temp = userInfo[@"EMP_ID"];
//        if (empLogo) {
//            [self saveUserLogo:empLogo andUser:temp];
//        }
//    } ];
//    if (empLogo) {
//        [self saveUserLogo:empLogo andUser:empId];
//    };
#else
    dispatch_queue_t _queue = dispatch_queue_create("download current user logo", NULL);
    dispatch_async(_queue, ^{
        ServerConfig *serverConfig = [ServerConfig shareServerConfig];
        NSURL *url = [NSURL URLWithString:[serverConfig getLogoUrlByEmpId:empId]];
        
        //    如果已经启动了下载，就不再发起下载
        [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        if(imageData != nil && imageData.length > 0)
        {
            UIImage *curImage = [UIImage imageWithData:imageData];
            //                        保存头像缩略图
            NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:logo];
            
            BOOL success= [UIImageJPEGRepresentation(curImage, 1.0) writeToFile:logoPath atomically:YES];
            
            if(success)
            {
                NSLog(@"%s 当前用户头像下载成功保存成功，emp is %@ ,emp logo is %@ logo size is %@ and %@",__FUNCTION__,empId,logo,[StringUtil getDisplayFileSize:imageData.length],NSStringFromCGSize(curImage.size));
                
                //                    生成小图
                [self createAndSaveMicroLogo:curImage andEmpId:empId andLogo:logo];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",logo,@"emp_logo", nil];
                [self sendUserlogoChangeNotification:dic];
                
                
                [[NSNotificationCenter defaultCenter]postNotificationName:GET_CURUSERICON_NOTIFICATION object:nil userInfo:nil];
                
                //                        下载大图
                [self downloadBigUserLogoByEmpId:empId andEmpLogo:logo];
                [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];
            }
            else
            {
                NSLog(@"当前用户头像下载成功保存失败，%@",logo);
            }
        }
        else
        {
            NSLog(@"当前用户头像下载失败%@",logo);
        }
    });
    
    dispatch_release(_queue);
#endif
}

+(void)downloadUserLogo:(NSString*)empId andLogo:(NSString*)logo andNeedSaveUrl:(bool)needSaveUrl
{
//    万达版本，头像对应的emplogo一律默认为 default_emp_logo
//    不用保存emp_logo的值
    needSaveUrl = false;
    logo = default_emp_logo;
    
    if ([[EmpLogoConn getConn] isDownloadLogoFailEmp:empId]) {
//        NSLog(@"已经发起过下载头像%@",empId);
        return;
    }

    conn *_conn = [conn getConn];
    if(_conn.userStatus == status_online && _conn.connStatus == normal_type)
    {
        //	判断本地是否有头像，如果没有就下载
        if(logo && logo.length > 0)
        {
            NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:logo];
            //        NSLog(@"%@",logoPath);
            UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
            
            /*
            if (img == nil)
            {
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                
                [manager.requestSerializer setValue:@"netsense" forHTTPHeaderField:@"netsense"];
                // 默认传输的数据类型
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                
                ServerConfig *serverConfig = [ServerConfig shareServerConfig];
                // 如果已经启动了下载，就不再发起下载
                [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
                
                //				先删除原来的头像
                [StringUtil deleteUserLogoIfExist:empId];
                
                NSString *url = [serverConfig getLogoUrlByEmpId:empId];
                [manager GET:url parameters:nil success:^(IM_AFHTTPRequestOperation *operation, id responseObject) {
                    
                    UIImage *curImage = [UIImage imageWithData:responseObject];
                    // 保存头像缩略图
                    BOOL success= [UIImageJPEGRepresentation(curImage, 1.0) writeToFile:logoPath atomically:YES];
                    if(success)
                    {
                        [self createAndSaveMicroLogo:curImage andEmpId:empId andLogo:logo];
                        
                        NSLog(@"头像下载成功保存成功，emp is %@ ,emp logo is %@",empId,logo);
                        if(needSaveUrl)
                        {
                            //		修改用户的头像url
                            eCloudDAO *db = [eCloudDAO getDatabase];
                            [db updateEmpLogo:empId andLogo:logo];
                        }
                        
                        if ([empId isEqualToString:[conn getConn].userId])
                        {
                            [self downloadBigUserLogoByEmpId:empId andEmpLogo:logo];
                            [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];
                        }
                        //                        else
                        //                        {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",logo,@"emp_logo", nil];
                        [self sendUserlogoChangeNotification:dic];
                        //                        }
                        
                    }
                    
                    
                } failure:^(IM_AFHTTPRequestOperation *operation, NSError *error) {
                    
                    NSLog(@"头像下载失败%@",error);
                }];
            }
            */
            
            ///*
            if(img == nil)
            {
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
//                不去下载和保存
//                [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
//                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"EMP_ID", nil];
//                UIImage *empLogo = [[HuaXiaOrgUtil getUtil]getHXEmpLogoByEmpId:empId.intValue withUserInfo:userInfo withCompleteHandler:^(UIImage *empLogo, NSDictionary *userInfo) {
//                    NSString *temp = userInfo[@"EMP_ID"];
//                    if (empLogo) {
//                        [self saveUserLogo:empLogo andUser:temp];
//                    }
//                } ];
//                if (empLogo) {
//                    [self saveUserLogo:empLogo andUser:empId];
//                };
#else
                dispatch_queue_t _queue = dispatch_queue_create("download_emp_logo", NULL);
                dispatch_async(_queue, ^{
                    ServerConfig *serverConfig = [ServerConfig shareServerConfig];
                    
                    NSURL *url = [NSURL URLWithString:[serverConfig getLogoUrlByEmpId:empId]];
                    
                    //    如果已经启动了下载，就不再发起下载
                    [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    
                    if(imageData != nil && imageData.length > 0)
                    {
                        //				先删除原来的头像
                        [StringUtil deleteUserLogoIfExist:empId];
                        
                        UIImage *curImage = [UIImage imageWithData:imageData];
                        NSLog(@"%s,empid is %@, image size is %@ image frame is %@",__FUNCTION__,empId,[StringUtil getDisplayFileSize:imageData.length],NSStringFromCGSize(curImage.size));
                        
                        //                        保存头像缩略图
                        BOOL success= [UIImageJPEGRepresentation(curImage, 1.0) writeToFile:logoPath atomically:YES];
                        
                        if(success)
                        {
                            [self createAndSaveMicroLogo:curImage andEmpId:empId andLogo:logo];
                            
                            NSLog(@"头像下载成功保存成功，emp is %@ ,emp logo is %@",empId,logo);
                            if(needSaveUrl)
                            {
                                //		修改用户的头像url
                                eCloudDAO *db = [eCloudDAO getDatabase];
                                [db updateEmpLogo:empId andLogo:logo];
                            }
                            
                            if ([empId isEqualToString:[conn getConn].userId])
                            {
                                [self downloadBigUserLogoByEmpId:empId andEmpLogo:logo];
                                [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];
                            }
                            //                        else
                            //                        {
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",logo,@"emp_logo", nil];
                            [self sendUserlogoChangeNotification:dic];
                            //                        }
                            
                        }
                        else
                        {
                            NSLog(@"头像下载成功保存失败，%@",logo);
                        }
                    }
                    else
                    {
                        NSLog(@"头像下载失败%@",logo);
                    }
                } );
                
                dispatch_release(_queue);
#endif

                
                
            }
           //  */
        }
    }
}

//add by shisp 头像下载成功后，发出头像修改通知
+ (void)sendUserlogoChangeNotification:(NSDictionary *)dic
{
    //    add by shisp 保存了头像后，同时发出通知，便于会话界面单聊用户的头像刷新
    eCloudDAO *db = [eCloudDAO getDatabase];
    
//    [db processWhenLogoChangeWithEmpId:[dic valueForKey:@"emp_id"]];
    
    [db sendNewConvNotification:dic andCmdType:user_logo_changed];
}

+(void)deleteFile:(NSString*)filePath
{
	NSFileManager   *_file  =   [NSFileManager defaultManager];
    NSError         *errors =   nil;
	if([_file fileExistsAtPath:filePath])
	{
		[_file removeItemAtPath:filePath error:&errors];
	}
	if(errors)
	{
		NSLog(@"error is %@",[errors domain]);
	}

}

+ (bool)createFolderForPath:(NSString *)path
{
    NSFileManager   *_file  =   [NSFileManager defaultManager];
    NSError         *errors =   nil;
    //如果不存在创建对应的文件夹
    if(NO == [_file fileExistsAtPath:path])
    {               
        [_file createDirectoryAtPath:path 
         withIntermediateDirectories:YES 
                          attributes:nil 
                               error:&errors];
        
        //如果创建发生了错误，则返回NO
        if(errors)
        {
			NSLog(@"创建应用程序目录失败");
            return false;
        }
    }
    //创建成功或者指定路经的文件夹已经存在，则返回YES
    return true;
}

+(NSString *)getStringValue:(int)value
{
	return [NSString stringWithFormat:@"%d",value];
}
+(NSString *)currentTime
{
	return [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
}

/**
 *得到本机现在用的语言
 * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
 */
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

//获取显示给用户的日期
//格式为年-月-日 星期

//	如果时间是当天，那么只显示 分：秒
//	如果时间是昨天，那么显示 昨天：分秒
//	如果时间是本周内，那么显示 星期 分：秒
//	否则显示年月日 分：秒
+(NSString*)getDisplayTime_day:(NSString*)interval
{
	NSDate *_msgDate = [NSDate dateWithTimeIntervalSince1970:[interval intValue]];
	NSDate *_now = [NSDate date];
	
//	年 月 日 星期
	int _unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekCalendarUnit;
	
	NSLocale *zh_Locale = [[NSLocale alloc] initWithLocaleIdentifier:[self getPreferredLanguage]];
	
	NSCalendar *_cal = [NSCalendar currentCalendar];
	[_cal setLocale:zh_Locale];
	
	
	NSDateComponents *_msgDc = [_cal components:_unitFlags fromDate:_msgDate];
//	NSLog(@"%s,year is %d,mongth is %d,day is %d,week is %d",__FUNCTION__, _msgDc.year,_msgDc.month,_msgDc.day,_msgDc.week);
	
	NSDateComponents *_nowDc = [_cal components:_unitFlags fromDate:_now];
	
//	如果年，月，日都和今天相同，那么只显示时分
	NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
	[formatter setLocale:zh_Locale];

	NSString *formatStr = @"yyyy-MM-dd HH:mm";
    
    BOOL isYesterday = NO;
	if(_msgDc.year == _nowDc.year && _msgDc.month == _nowDc.month && _msgDc.day == _nowDc.day)
	{
		formatStr = @"HH:mm";		
	}
//	如果年，月相同，日期少一天，那么显示昨天，时分
	else if(_msgDc.year == _nowDc.year && _msgDc.month == _nowDc.month && (_nowDc.day - _msgDc.day) == 1)
	{
        isYesterday = YES;
		formatStr = @"HH:mm";
	}
//	如果年相同，星期相同，那么显示星期，时分
	else if(_msgDc.year == _nowDc.year && _msgDc.week == _nowDc.week)
	{
		formatStr = @"EEE HH:mm";
	}
	
	[formatter setDateFormat:formatStr];
	
	NSString *dateStr=[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[interval intValue]]];
	
    if (isYesterday) {
        dateStr = [NSString stringWithFormat:@"%@ %@",[StringUtil getLocalizableString:@"time_yesterday"],dateStr];
    }
	[formatter release];
    [zh_Locale release];
	return dateStr;
}

//获取显示给用户的日期
//格式为 小时-分钟
+(NSString*)getDisplayTime_time:(NSString*)interval
{
	NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"HH:mm:ss";
	//	formatter.dateStyle = NSDateFormatterLongStyle;
	
	NSString *dateStr=[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[interval intValue]]];
	
	[formatter release];
	return dateStr;
}

//获取显示给用户的日期
+(NSString*)getDisplayTime:(NSString*)interval
{
	NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//	formatter.dateStyle = NSDateFormatterLongStyle;
	
	NSString *dateStr=[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[interval intValue]]];
	//NSLog(@"--5555--dateStr-%@",dateStr);;
	[formatter release];
	return dateStr;
}
#pragma mark 参考微信，优化最后一条消息的时间
+(NSString*)getLastMessageDisplayTime:(NSString*)interval
{
	NSDate *_msgDate = [NSDate dateWithTimeIntervalSince1970:[interval intValue]];
	NSDate *_now = [NSDate date];
	
	//	年 月 日 星期
	int _unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekCalendarUnit;
	
	NSLocale *zh_Locale = [[NSLocale alloc] initWithLocaleIdentifier:[self getPreferredLanguage]];
	
	NSCalendar *_cal = [NSCalendar currentCalendar];
	[_cal setLocale:zh_Locale];
	
	
	NSDateComponents *_msgDc = [_cal components:_unitFlags fromDate:_msgDate];
	//	NSLog(@"%s,year is %d,mongth is %d,day is %d,week is %d",__FUNCTION__, _msgDc.year,_msgDc.month,_msgDc.day,_msgDc.week);
	
	NSDateComponents *_nowDc = [_cal components:_unitFlags fromDate:_now];
	
	//	如果年，月，日都和今天相同，那么只显示时分
	NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
	[formatter setLocale:zh_Locale];
	
	NSString *formatStr = @"yy-M-d";
    BOOL isYesterday = NO;
	if(_msgDc.year == _nowDc.year && _msgDc.month == _nowDc.month && _msgDc.day == _nowDc.day)
	{
		formatStr = @"HH:mm";
	}
	//	如果年，月相同，日期少一天，那么显示昨天
	else if(_msgDc.year == _nowDc.year && _msgDc.month == _nowDc.month && (_nowDc.day - _msgDc.day) == 1)
	{
        isYesterday = YES;
	}
	//	如果年相同，星期相同，那么显示星期
	else if(_msgDc.year == _nowDc.year && _msgDc.week == _nowDc.week)
	{
		formatStr = @"EEE";
	}
    //	年相同，非一星期之内的，显示月日
    else if (_msgDc.year == _nowDc.year)
    {
        formatStr = @"M-d";
    }
	
	NSString *dateStr;
    if (isYesterday)
    {
        dateStr = [StringUtil getLocalizableString:@"time_yesterday"];
    }
    else
    {
        [formatter setDateFormat:formatStr];
        dateStr=[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[interval intValue]]];
    }
	
	[formatter release];
    [zh_Locale release];
	return dateStr;
}

#pragma mark 一呼百应消息已读时间显示
+(NSString*)getDisplayTimeOfMsgRead:(int)interval
{
    return [self getLastMessageDisplayTime:[self getStringValue:interval]];
//	return [self getDisplayTime_day:[self getStringValue:interval]];
}

//判断是否是邮箱格式的字符串
+ (BOOL)isEmail:(NSString *)value
{
	//正则表达式
    NSString *regexStr  =   [NSString stringWithString:@"^[_\\.0-9a-zA-Z-]+@([0-9a-zA-Z][0-9a-zA-Z-]+\\.)+[a-zA-Z]{2,4}$"];
    NSRange range       =   [value rangeOfString:regexStr options:NSRegularExpressionSearch];
    if(NSNotFound == range.location)
    {
        return NO;
    }
    return YES;
}
//提供一个方法进行根据服务端的状态更改为客户端的状态
+(NSString*)getClientStatusByServerStatus:(int)serverStatus
{
	int ret;
	if(serverStatus == 0){
		ret = status_offline; //离线
	}
	else if(serverStatus == 1) 
	{
		ret = status_online;//在线
	}
	else if(serverStatus == 2)
	{
		ret = status_leave;//离开
	}
	else
	{
		ret = status_offline;	
	}
		
	return [self getStringValue:ret];
}

//提供一个方法进行根据客户端的状态得到服务器端对应状态的值
+(int)getServerStatusByClientStatus:(int)clientStatus
{
	int ret;
	if(clientStatus == status_online)
	{
		ret = 1;
	}
	else if(clientStatus == status_leave)
	{
		ret = 2;
	}
	else if(clientStatus == status_offline)
	{
		ret = 0;
	}
	else
	{
		ret = 3;	
	}
	return ret;
}

//add by shisp 取得显示的文件大小
+(NSString *)getDisplayFileSize:(int)fileSize
{
	if(fileSize < 1024)//小于1K，显示为xxxB
	{
		return [NSString stringWithFormat:@"%dB",fileSize];
	}
	else if(fileSize < 1024 * 1024)//小于1M，显示为xxx.yyK
	{
		return [NSString stringWithFormat:@"%.2fK",byteToK(fileSize)];
	}
	else if(fileSize < 1024 * 1024 * 1024)//小于1G,显示为xxx.yyM
	{
		return [NSString stringWithFormat:@"%.2fM",byteToM(fileSize)];		
	}
	else {//显示为xxx.yyG
		
		return [NSString stringWithFormat:@"%.2fG",byteToG(fileSize)];		
	}
}
+(void)seperateMsg:(NSString *)message andImageArray:(NSMutableArray *)array
{
	NSRange range=[message rangeOfString:PC_CROP_PIC_START];
    NSRange range1;
	
	if(range.length > 0)
	{//找到的起始位置
		NSRange searchRange = NSMakeRange(range.location + range.length, (message.length - (range.location + range.length)));
		range1 = [message rangeOfString:PC_CROP_PIC_END options:nil range:searchRange];
//		从起始位置的后面开始找终止位置
		if(range1.length > 0)
		{
//			找到了终止位置
			if(range.location > 0)
			{
				[array addObject:[message substringToIndex:range.location]];//开始标志前的字符				
			}
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];//开始标识，表情和结束标识
            NSString *str=[message substringFromIndex:range1.location+1];//结束标识后的字符串
			if(str.length > 0)
			{
				[self seperateMsg:str andImageArray:array];//解析结束标识后的字符串
			}
			else
			{
				return;
			}
  		}
		else
		{
//			没有找到终止位置
			[array addObject:message];
			return;
		}
	}
	else
	{
		//	没有找到起始位置
		[array addObject:message];
		return;
	}
}

//翻译


//16进制字符串转颜色 #2597d9
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	
    if ([cString length] < 6) 
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"]) 
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6) 
        return DEFAULT_VOID_COLOR;
	
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
	
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
	
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

#pragma mark 计算消息长度，包括字体部分
+(int)getMsgLen:(NSString *)msg
{
	const char *cMsg = [msg cStringUsingEncoding:NSUTF8StringEncoding];
//	int len = strlen(cMsg)+10;
//	NSLog(@"%s,msg len is %d",__FUNCTION__,len);
//	MSG_MAXLEN
	return strlen(cMsg);
}

+(bool)isHanzi:(int)firstChar
{
	//	如果第一个字符是汉字，则认为是汉字
	if( firstChar > 0x4e00 && firstChar < 0x9fff)
	{
		//		NSLog(@"is hanzi");
		return true;
	}
	return false;
}
+(bool)isLetter:(int)firstChar
{
	if((firstChar >= 'a' && firstChar <= 'z') || (firstChar >= 'A' && firstChar <= 'Z'))
	{
		//		NSLog(@"is letter");
		return true;
	}
	return false;
}

+(bool)isNumber:(int)firstChar
{
	if(firstChar >= '0' && firstChar <= '9')
	{
		return true;
	}
	return false;
}

/** 判断用户输入的是字母、数字、汉字或其他 */
+ (int)getSearchStrType:(NSString *)searchStr{
    int firstChar = [searchStr characterAtIndex:0];
    int searchType = special_char_type;
    
    if ([StringUtil isHanzi:firstChar]) {
        searchType = hanzi_type;
    }else if ([StringUtil isLetter:firstChar]){
        searchType = letter_type;
    }else if ([StringUtil isNumber:firstChar]){
        searchType = number_type;
    }
    return searchType;
}

#pragma mark 判断用户输入的是字母，数字还是中文
+(int)getStringType:(NSString*)_str
{
    if (_str == nil || _str.length == 0) {
        NSLog(@"_str is nil or '' ");
        return other_type;
    }
    
    NSString *str = [NSString stringWithString:_str];
	int minLen = [eCloudConfig getConfig].searchTextMinLen.intValue;
	//	如果雇员个数大于1000，那么至少输入两个才开始查询
//	conn *_conn = [conn getConn];
//	[_conn getAllEmpArray];
//	if(_conn.allEmpArray && _conn.allEmpArray.count > 1000)
//	{
//		minLen = 2;
//	}
    
	int firstChar = [str characterAtIndex:0];
    
//    输入至少2个字符才开始查询，无论是中文还是其它字符
//    不判断数字类型，如果是字母就按照简拼和账号查询，否则按照名字查询
	if(str.length >= minLen)
	{
        if([self isHanzi:firstChar])
            return hanzi_type;
        
//        判断是否声母 update by shisp 
//		if([self isShengMu:str])
//			return letter_type;
        
		if([self isLetter:firstChar])
			return letter_type;
        
		if([self isNumber:firstChar])
			return number_type;
        
        return special_char_type;
	}

//    update by shisp 默认按照工号来查询
	return other_type;
}

+ (BOOL)isShengMu:(NSString *)str
{
    //    判断是否声母
    NSString *shengmuStr = @"aoebpmfdtnlgkhjqxzcsryw";
    NSString *firstCharStr = [str substringToIndex:1];
    NSRange range = [shengmuStr rangeOfString:firstCharStr options:NSCaseInsensitiveSearch];
    if (range.length > 0) {
//        NSLog(@"is shengmu");
        return YES;
    }
    else
    {
//        NSLog(@"no shengmu");
        return NO;
    }
}

#pragma mark 查看用户的头像有没有下载下来，如果有就先删除
+(void)deleteUserLogoIfExist:(NSString*)empId
{
	NSDirectoryEnumerator *dirEnum =
    [[NSFileManager defaultManager] enumeratorAtPath:[self newLogoPath]];
	
	NSString *file;
	while ((file = [dirEnum nextObject]))
	{
//        用户头像更新后，需要删除旧的头像，下载新的头像，要删除用户的大小微头像，还要删除包含该用户的群组头像
		if(file && ([file hasPrefix:empId]) && [[file pathExtension] isEqualToString:@"png"])
		{
			[[NSFileManager defaultManager] removeItemAtPath:[[self newLogoPath]stringByAppendingPathComponent:file] error:nil] ;
		}
	}
}

#pragma mark 根据用户id，用户头像url，获取头像路径
+(NSString*)getLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo
{
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    /** 华夏和正荣 取到人员的头像后，不保存在本地，取到就要，没取到就不用 */
    return nil;
#else
    logo = default_emp_logo;
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.png",empId,logo];
    return [[self newLogoPath]stringByAppendingPathComponent:fileName];
#endif
}

#pragma mark 根据用户id，用户头像url，获取大头像路径
+(NSString*)getBigLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo
{
    logo = default_emp_logo;

	NSString *fileName = [NSString stringWithFormat:@"%@_big_%@.png",empId,logo];
	return [[self newLogoPath]stringByAppendingPathComponent:fileName];
}

#pragma mark 根据用户id，用户头像url，获取离线头像头像路径
// 万达不显示处理过的离线头像，都显示正常的头像，离线用头像右下角加一个离线的状态小图标表示 这里返回logo的路径
+(NSString*)getOfflineLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo
{
//	NSString *fileName = [NSString stringWithFormat:@"%@_offline_%@.png",empId,logo];
//	return [[self newLogoPath]stringByAppendingPathComponent:fileName];
    return [self getLogoFilePathBy:empId andLogo:logo];
}

//获取资源路径
+(NSString *)getResPath:(NSString*)name andType:(NSString*)type
{
	return [[self getBundle]pathForResource:name ofType:type];
}

//去掉字符串两边的空格
+(NSString*)trimString:(NSString*)str
{
	NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
	return [str stringByTrimmingCharactersInSet:whitespace];
}

//增加一个方法，根据时间，返回一个日期值，用于单个图文推送信息的日期显示
+(NSString*)getSinglePsMsgDate:(int)interval
{
	NSDate *_msgDate = [NSDate dateWithTimeIntervalSince1970:interval];
	NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
	
	NSString *formatStr = @"MM月dd日";
	[formatter setDateFormat:formatStr];
	
	NSString *dateStr=[formatter stringFromDate:_msgDate];
	
	[formatter release];
	return dateStr;
}

#pragma mark 遍历文件目录，如果是头像文件，那么移到头像目录下，如果是其他文件则移到收到的文件目录下，首先需要创建目录
+(void)transferFileToNewDir
{
    if([StringUtil isFilePathExist])
    {
        NSLog(@"文件目录已经存在");
        return;
    }
	NSString *newLogoPath = [self newLogoPath];

	NSString *newRcvFilePath = [self newRcvFilePath];
	
    NSString *fileRootPath = [self getFileDir];
    
	NSDirectoryEnumerator *dirEnum =
    [[NSFileManager defaultManager] enumeratorAtPath:fileRootPath];
    [dirEnum skipDescendants];
	
	NSString *fileName;
    NSString *filePath;
    
    NSError *_error;
    
    NSString *curDirectory = @"";
    
	while ((fileName = [dirEnum nextObject]))
	{
//        NSLog(@"%@",fileName);
        
        filePath = [fileRootPath stringByAppendingPathComponent:fileName];
        
        BOOL isDirectory;
        
        if([[NSFileManager defaultManager]fileExistsAtPath:filePath isDirectory:&isDirectory])
        {
            if(isDirectory)
            {
                curDirectory = [fileName stringByAppendingPathComponent:@""];
                continue;
            }
            else
            {
                if(curDirectory.length > 0 && [fileName hasPrefix:curDirectory])
                {
                    continue;
                }
                else
                {
                    curDirectory = @"";
                    NSLog(@"move %@",fileName);

                    if([fileName rangeOfString:@"_"].length > 0 && [[fileName pathExtension] isEqualToString:@"png"])
                    {
                        //			移到新的路径下
                        [[NSFileManager defaultManager]moveItemAtPath:filePath
                                                               toPath:[newLogoPath stringByAppendingPathComponent:fileName] error:&_error];
                    }
                    else if(![fileName hasPrefix:ecloud_db])
                    {
                        [[NSFileManager defaultManager]moveItemAtPath:filePath
                                                               toPath:[newRcvFilePath stringByAppendingPathComponent:fileName] error:&_error];
                    }
                    if(_error)
                    {
                        //                NSLog(@"%s,%@,%@",__FUNCTION__,_error.domain,_error.description);
                    }
                }
            }
        }
	}
}

//用户头像的路径
+(NSString*)newLogoPath
{
	NSString *filePath = [self getFileDir];
	NSString *logoPath = [filePath stringByAppendingPathComponent:logo_path];
	if([self createFolderForPath:logoPath])
		return logoPath;
	return filePath;
}

+(NSString*)newRcvFilePath{
	NSString *filePath = [self getFileDir];
	NSString *rcvFilePath = [filePath stringByAppendingPathComponent:rcv_file_path];
	if([self createFolderForPath:rcvFilePath])
		return rcvFilePath;
	return filePath;
}

+(NSString*)newRcvFileTemPath
{
    NSString *filePath = [self getFileDir];
    NSString *rcvFilePath = [filePath stringByAppendingPathComponent:rcv_file_temp_path];
    if([self createFolderForPath:rcvFilePath])
        return rcvFilePath;
    return filePath;
}

+(NSString*)newKapokPath
{
	NSString *filePath = [self getFileDir];
	NSString *kapokFilePath = [filePath stringByAppendingPathComponent:kapok_file_path];
	if([self createFolderForPath:kapokFilePath])
		return kapokFilePath;
	return kapokFilePath;
}

+(NSString*)newAppIconPathWithAppid:(NSString *)appid
{
	NSString *filePath = [self getFileDir];
	NSString *kapokFilePath = [[filePath stringByAppendingPathComponent:app_icon_path] stringByAppendingPathComponent:appid];
	if([self createFolderForPath:kapokFilePath])
		return kapokFilePath;
	return kapokFilePath;
}


//判断用户文件目录是否存在，如果已经存在，那么不用迁移文件
+ (BOOL)isFilePathExist
{
    NSString *filePath = [self getFileDir];
	NSString *rcvFilePath = [filePath stringByAppendingPathComponent:rcv_file_path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if([fileManager fileExistsAtPath:rcvFilePath isDirectory:&isDir] && isDir)
    {
        return YES;
    }
    return NO;
}

//add by shisp 新建目录，保存版本的更新说明，同时返回当前路径
+(NSString*)getUpdateInfoFilePath
{
	NSString *filePath = [self getHomeDir];
	NSString *updateInfoFilePath = [filePath stringByAppendingPathComponent:update_info_file_path];
	if([self createFolderForPath:updateInfoFilePath])
    {
        conn *_conn = [conn getConn];
        updateInfoFilePath = [updateInfoFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"ios_%@.txt",_conn.updateVersion]];
		return updateInfoFilePath;
    }
	return filePath;
}

+(void)downloadUpdateInfo
{
    conn *_conn = [conn getConn];
    eCloudUser *userDb = [eCloudUser getDatabase];
    
    NSString *localVersion = [userDb getVersion:app_version_type];
    
    if([localVersion compare:_conn.updateVersion] == NSOrderedAscending)
    {
        NSString *updateInfoFilePath = [StringUtil getUpdateInfoFilePath];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isExist = [manager fileExistsAtPath:updateInfoFilePath];
        if(!isExist)
        {
            ServerConfig *serverConfig = [ServerConfig shareServerConfig];
            NSURL *url = [NSURL URLWithString:[serverConfig getUpdateInfoUrl]];
            
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
            [request setDelegate:_conn];
            [request setDownloadDestinationPath:updateInfoFilePath];
            [request setDidFinishSelector:@selector(saveUpdateInfo:)];
            [request setDidFailSelector:@selector(downloadUpdateInfoFail:)];
            request.shouldContinueWhenAppEntersBackground = YES;
            [request startAsynchronous];
            [request release];
        }
        else
        {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            _conn.updateInfo = [NSString stringWithContentsOfFile:updateInfoFilePath encoding:gbkEncoding error:nil];
         }
    }
}
+ (NSString *)getAppName
{
    NSString *temp;
    temp = [[LanUtil bundle]localizedStringForKey:@"CFBundleDisplayName" value:nil table:@"InfoPlist"];
    
    if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
        return @"南航E家";
    }
    
    return temp;
}

+ (NSString *)getAlertTitle
{
    if ([UIAdapterUtil isTAIHEApp]) {
        return @"泰信提醒";
    }
    
    return [self getAppName];
}

#pragma mark - 截取文件名
+ (NSString *)getProperFileName:(NSString *)filenane
{
    //过滤文件名
	NSString *file_Ext = nil;
	NSString *originFileName = filenane;
    
    
	NSRange _range = [originFileName rangeOfString:@"." options:NSBackwardsSearch];
    NSRange _range1 = [originFileName rangeOfString:@"_" options:NSBackwardsSearch];
    
    //    NSLog(@"_range1-----111%i",_range1.location);
    //    NSLog(@"_range-----%i",_range.location);
    //
	if(_range.location > _range1.location )
	{
		//file_Ext = [originFileName substringFromIndex:_range.location+1];
        
        file_Ext = [originFileName stringByReplacingCharactersInRange:NSMakeRange(_range1.location, _range.location-_range1.location) withString:@""];
        return file_Ext;
        
	}
    
    return filenane;
}

#pragma mark ---转成2进制字符串---
+ (NSString *)toBinaryStr:(int)input
{
    if (input == 1 || input == 0)
    {
        return [NSString stringWithFormat:@"%d", input];
    }
    else
    {
        return [NSString stringWithFormat:@"%@%d", [self toBinaryStr:input/2], input%2];
    }
}

+ (NSString *)toBinaryStr:(int)input andByteCount:(int)count
{
    NSString *result = [StringUtil toBinaryStr:input];
    int len = result.length;
    
    NSMutableString *mStr = [NSMutableString stringWithString:@""];
    //    NSMutableString *mStr = NSMuta;
    if(count == 1)
    {
        len = 8 - len;
    }
    else if(count == 2)
    {
        len = 16 - len;
    }
    else
    {
        len = 0;
    }
    for(int i = 0; i<len; i++)
    {
        [mStr appendString:@"0"];
    }
    
    NSString *temp = [NSString stringWithFormat:@"%@%@",mStr,result];
    return temp;
}


+(NSString*)getStringByCString:(char*)data
{
    if (data == NULL)
        return @"";
    
	NSString *str =  [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
	if(str)
		return str;
	return @"";
}

+ (char *)getCStringByString:(NSString *)str
{
    return [str cStringUsingEncoding:NSUTF8StringEncoding];
}

+(NSString*)getFileMD5WithPath:(NSString*)path
{
    return (NSString *)FileMD5HashCreateWithPath((CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}


+ (int)getRequestTimeout
{
    int timeout = 30;
    if([ApplicationManager getManager].netType == type_gprs)
    {
        timeout = 60;
    }
    return timeout;
}

+(NSString *)getLocalizableString:(NSString *) key
{
    return [[LanUtil bundle]localizedStringForKey: key value:nil table:@"Localizable"];
}

+(NSUInteger) lenghtWithString:(NSString *)string
{
    char *cStr = [StringUtil getCStringByString:string];
    int len = strlen(cStr);
    return len;
//
//    NSUInteger len = string.length;
//    // 汉字字符集
//    NSString * pattern  = @"[\u4e00-\u9fa5]";
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
//    // 计算中文字符的个数
//    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
//    //    NSLog(@"%s,%d",__FUNCTION__,numMatch);
//    
//    return len + 2 * numMatch;
}

//grpName里有汉字也有其他字符，如果是汉字要占用3个长度，否则只占一个长度，总长度要小于等于grpName的总长度
+ (NSString *)getNewGrpName:(NSString *)grpName
{
    if (!grpName || grpName.length <= 0) {
        return nil;
    }
//    如果总长度没有超过最大长度，则直接返回，否则截取后返回
    int msgLen = [self getMsgLen:grpName];
    if (msgLen <= GROUPNAME_MAXLEN - 2) {
        return grpName;
    }
    
    int _index = 0;
    int len = 0;
    for (int i = 0; i < grpName.length; i++) {
        int curChar = [grpName characterAtIndex:i];
        if ([self isHanzi:curChar]) {
            len += 3;
        }
        else
        {
            len += 1;
        }
        if (len > GROUPNAME_MAXLEN - 2) {
            break;
        }
        else
        {
            _index = i + 1;
        }
    }
    
    NSString *newGroupName = [grpName substringToIndex:_index];
    return newGroupName;
}

+ (NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

+ (NSString *)getAppReleaseDate
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *tempStr = [infoDictionary objectForKey:@"AppReleaseDate"];
    return tempStr;
}

#pragma mark =============当前可用内存 本应用已使用内存==============

// 获取当前设备可用内存(单位：MB）
+ (void)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
//        return NSNotFound;
    }
    
    double _memory = ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
    NSLog([NSString stringWithFormat:@"当前可用内存为:%.0f",_memory]);
}

// 获取当前任务所占用的内存（单位：MB）
+ (void)usedMemory
{
    return;
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
//        return NSNotFound;
    }
    
    double _memory = taskInfo.resident_size / 1024.0 / 1024.0;
    
    NSLog([NSString stringWithFormat:@"当前应用使用的内存为:%.0f",_memory]);
}

#pragma mark - 获取文件默认图片
+(UIImage *)getFileDefaultImage:(NSString *)fileName{
    UIImage *img;
    NSString *fileExtension = [fileName pathExtension];
    if (fileExtension) {
        fileExtension = [fileExtension lowercaseString];
    }
    if ([fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"jpg"] || [fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"bmp"] || [fileExtension isEqualToString:@"tiff"] || [fileExtension isEqualToString:@"psd"] || [fileExtension isEqualToString:@"swf"]) {
        //图片
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_image" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"pdf"]){
        //pdf文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_pdf" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"xls"] || [fileExtension isEqualToString:@"xlsx"] || [fileExtension isEqualToString:@"xlsm"]){
        //excel文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_excel" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"docx"] || [fileExtension isEqualToString:@"doc"]){
        //word文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_word" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"ppt"] || [fileExtension isEqualToString:@"pptx"]){
        //ppt文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_ppt" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"zip"] || [fileExtension isEqualToString:@"rar"]){
        //zip文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_zip" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"txt"] || [fileExtension isEqualToString:@"rtf"]){
        //txt文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_txt" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"html"] || [fileExtension isEqualToString:@"htm"] || [fileExtension isEqualToString:@"xml"] || [fileExtension isEqualToString:@"xhtml"] || [fileExtension isEqualToString:@"asp"] || [fileExtension isEqualToString:@"aspx"] || [fileExtension isEqualToString:@"php"]){
        //html文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_html" andType:@"png"]];
    }
    else if ([fileExtension isEqualToString:@"mp3"] || [fileExtension isEqualToString:@"ram"] || [fileExtension isEqualToString:@"au"] || [fileExtension isEqualToString:@"aif"] || [fileExtension isEqualToString:@"aac"] || [fileExtension isEqualToString:@"wav"]){
        //music文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_music" andType:@"png"]];
    }
    else if ([self isVideoFile:fileExtension]){
        //video文件
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_video" andType:@"png"]];
    }
    else{
        img = [UIImage imageWithContentsOfFile:[self getResPath:@"chat_files_unknow" andType:@"png"]];
    }
    
    
    return img;
}


//增加一个下载大头像的方法
+ (void)downloadBigUserLogoByEmpId:(NSString *)empId andEmpLogo:(NSString *)empLogo
{
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
//    不去下载
#else
    //下载大图
    NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:empId andLogo:empLogo];
    NSURL *bigurl = [NSURL URLWithString:[[ServerConfig shareServerConfig]getBigLogoUrlByEmpId:empId]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:bigurl];
    // 添加请求头,如果没有设置就没有下载权限
    [request addRequestHeader:@"netsense" value:@"netsense"];
    [request setDownloadDestinationPath:bigLogoPath];
    [request startAsynchronous];
    
#endif
    
}

#pragma mark ==========数据库压缩，解压缩相关==============
//压缩数据库
+ (void)zipDb
{
    ZipArchive *zipArchive = [[ZipArchive alloc]init];
    
    NSString *zipDbPath = [self getZipDbFilePath];
    
    [zipArchive CreateZipFile2:zipDbPath Password:zip_db_password];
    
    NSString *dbPath = [self getDataDbFilePath];
    BOOL zipResult = [zipArchive addFileToZip:dbPath newname:ecloud_db];
    
    if(zipResult)
    {
//        把对应的时间戳文件也放到压缩文件中 update by shisp
        NSString *userDbPath = [[self getHomeDir]stringByAppendingPathComponent:ecloud_user_db];
        zipResult = [zipArchive addFileToZip:userDbPath newname:ecloud_user_db];
    }
        
    if (zipResult) {
        NSLog(@"压缩数据库文件成功");
        
    }
    [zipArchive CloseZipFile2];
    [zipArchive release];
}

//获取压缩数据库文件的路径
+ (NSString *)getZipDbFilePath
{
    NSString *zipDbPath = [[self getFileDir]stringByAppendingPathComponent:[StringUtil getZipDbName]];
    return zipDbPath;
}

//解压缩数据库文件
+ (BOOL)unzipDb
{
    ZipArchive *zipArchive = [[ZipArchive alloc]init];
    
    NSString *zipDbPath = [self getZipDbFilePath];
    
    BOOL unzipResult = [zipArchive UnzipOpenFile:zipDbPath Password:zip_db_password];
    if (unzipResult)
    {
        unzipResult = [zipArchive UnzipFileTo:[self getFileDir] overWrite:YES];
        if (unzipResult) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 解压数据库文件成功",__FUNCTION__]];
        }
        [zipArchive CloseZipFile2];
    }
    
    [zipArchive release];
    
    if (unzipResult) {
        [[NSFileManager defaultManager]removeItemAtPath:zipDbPath error:nil];
        [LogUtil debug:[NSString stringWithFormat:@"%s 删除压缩文件",__FUNCTION__]];
    }
    return unzipResult;
}

#pragma mark =========用户微头像 群组合成头像==========

//add by shisp 增加一个获取微头像的路径的方法
+(NSString*)getMicroLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo
{
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    /** 华夏和正荣 取到人员的头像后，不保存在本地，取到就要，没取到就不用 */
    return nil;
#else
    logo = default_emp_logo;
    
    NSString *fileName = [NSString stringWithFormat:@"%@_micro_%@.png",empId,logo];
    return [[self newLogoPath]stringByAppendingPathComponent:fileName];    
#endif
}

+(NSString*)getProcessLogoFilePathBy:(NSString*)empId andLogo:(NSString*)logo
{
    logo = default_emp_logo;
    
    NSString *fileName = [NSString stringWithFormat:@"%@_process_%@.png",empId,logo];
    return [[self newLogoPath]stringByAppendingPathComponent:fileName];
}

//生成并保存微头像
+ (void)createAndSaveMicroLogo:(UIImage *)curImage andEmpId:(NSString *)empId andLogo:(NSString *)logo
{
    //                            增加保存显示在群组头像里的微头像
    //                            微头像size
    float microLogoWidth = 30.0;
    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
    float microLogoHeight = (microLogoWidth * _size.height) / _size.width;
    
    if ([eCloudConfig getConfig].useOriginUserLogo) {
        microLogoHeight = (microLogoWidth * curImage.size.height) / curImage.size.width;
    }

#ifdef _ZHENGRONG_FLAG_
    microLogoHeight = (microLogoWidth * curImage.size.height) / curImage.size.width;
#endif
    
    UIImage *microLogoImage = [ImageUtil scaledImage:curImage toSize:CGSizeMake(microLogoWidth, microLogoHeight) withQuality:kCGInterpolationHigh];
    
    
    if (microLogoImage) {
        NSString *microLogoPath = [self getMicroLogoFilePathBy:empId andLogo:logo];
        BOOL success = [UIImageJPEGRepresentation(microLogoImage,1.0) writeToFile:microLogoPath atomically:YES];
        if (!success) {
            NSLog(@"保存微头像失败");
        }
    }
    else
    {
        NSLog(@"生成微头像失败");
    }
    
    
#ifdef _LANGUANG_FLAG_
//    不再生成马赛克图片
    return;
    UIImage *processImage = [ImageUtil imageProcess:curImage];
    if (processImage) {
        NSString *processLogoPath = [self getProcessLogoFilePathBy:empId andLogo:logo];
        BOOL success = [UIImageJPEGRepresentation(processImage,1.0) writeToFile:processLogoPath atomically:YES];
        if (!success) {
            NSLog(@"保存马赛克图片失败");
        }
    }
    else
    {
        NSLog(@"生成马赛克图片失败");
    }
#endif
    
}

//根据大头像生成并保存小头像，大头像下载后，同时生成小头像，避免大小头像不一致的情况
+ (void)createAndSaveSmallLogo:(UIImage *)curImage andEmpId:(NSString *)empId andLogo:(NSString *)logo
{
    float smallLogoWidth = 90.0;
    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
    float smallLogoHeight = (smallLogoWidth * _size.height) / _size.height;
    
    UIImage *smallLogoImage = [ImageUtil scaledImage:curImage toSize:CGSizeMake(smallLogoWidth, smallLogoHeight) withQuality:kCGInterpolationHigh];
    
    if (smallLogoImage) {
        NSString *smallLogoPath = [self getLogoFilePathBy:empId andLogo:logo];
        BOOL success = [UIImageJPEGRepresentation(smallLogoImage,0.5) writeToFile:smallLogoPath atomically:YES];
        if (!success) {
            NSLog(@"根据大头像保存小头像失败");
        }
    }
    else
    {
        NSLog(@"根据大头像生成小头像失败");
    }
}

//根据名字删除群组合成头像
+ (void)deleteMergedGroupLogoByName:(NSString *)logoName
{
    [[NSFileManager defaultManager] removeItemAtPath:[[self newLogoPath]stringByAppendingPathComponent:logoName] error:nil] ;
}

//根据名字得到群组合成头像的路径
+ (NSString *)getMergedGroupLogoPathWithName:(NSString *)logoName
{
    return [[self newLogoPath]stringByAppendingPathComponent:logoName];
}

//群组合成头像的名字，按照一定的规则生成合成头像的名字，包括每个小头像的id，以及是默认头像还是用户自己的头像
+ (NSString *)getDetailMergedGroupLogoName:(Conversation *)conv
{
//    合成头像的名字 就是群组id
    if (conv.conv_id) {
        return [NSString stringWithFormat:@"%@.png",conv.conv_id];
    }
    return @"";
}

+ (NSString *)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

#pragma mark ========上传，下载校验=========

//原有的URL后面增加：
//uid:用户ID
//t: 客户端校正后的时间戳，自1970年的到现在的秒
//guid:客户端生成的唯一ID,32位字符串
//沟通后改为：1970年到现在的毫秒
//文件名保留老的：上传方式
//mdkey:各字段拼成字符串，进行MD5加密
//md5(文件名+uid+t+guid+密钥key)  小写32字符的md5串
//密钥:wanxin@`!321^&*
//例如：filename=abc.jpg
//oldurl&uid=11221&t=141212112&guid=12345&mdkey= 845656cb19676583a7936537604803f1

//上传用到的
+ (NSString *)getUploadAddStr:(NSString *)fileName
{
//    return @"";
    conn *_conn = [conn getConn];
//    校正过的时间
    int ts = [_conn getCurrentTime];
    
//    客户端自己的时间 毫秒数
    NSString *tms = [NSString stringWithFormat:@"%.0f",([[NSDate date] timeIntervalSince1970] * 1000)];
    
// 准备生成MD5的字符串
    NSString *strForMD5 = [NSString stringWithFormat:@"%@%d%@%@",_conn.userId,ts,tms,md5_password];
    
//    生成md5
    NSString *md5 = [self getMD5Str:strForMD5];
    
//    得到最后的附件串
    NSString *addStr = [NSString stringWithFormat:@"?uid=%@&t=%d&guid=%@&mdkey=%@",_conn.userId,ts,tms,md5];
    
    return addStr;
}

//
//原有的URL后面增加：
//uid:发请求的用户ID
//t: 客户端校正后的时间戳，自1970年的的秒
//guid:客户端生成的唯一ID
//沟通后改为：1970年到现在的毫秒
//mdkey:md5(文件key+uid+t+guid+密钥key)  小写32字符的md5串
//原有文件的key：例如 2uyaee
//密钥:wanxin@`!321^&*
//例如：
//oldurl&uid=11221&t=141212112&guid=12345&mdkey= 75b9341d2cce6baa9d86a915ee0895d3

//下载用到的
+ (NSString *)getDownloadAddStr:(NSString *)fileURL
{
//    return @"";
    
    conn *_conn = [conn getConn];
    //    校正过的时间
    int ts = [_conn getCurrentTime];
    
    //    客户端自己的时间 毫秒数
    NSString *tms = [NSString stringWithFormat:@"%.0f",([[NSDate date] timeIntervalSince1970] * 1000)];
    
    // 准备生成MD5的字符串
    NSString *strForMD5 = [NSString stringWithFormat:@"%@%@%d%@%@",fileURL,_conn.userId,ts,tms,md5_password];
    
    //    生成md5
    NSString *md5 = [self getMD5Str:strForMD5];
    
    //    得到最后的附件串
    NSString *addStr = [NSString stringWithFormat:@"&uid=%@&t=%d&guid=%@&mdkey=%@",_conn.userId,ts,tms,md5];
    
    return addStr;
}

+ (NSString *)getMD5Str:(NSString *)strForMD5
{
    unsigned char *srcData = [StringUtil getCStringByString:strForMD5];
    int len = strlen(srcData);
    unsigned char out[33] = "";
    
    Create32Md5(srcData, len, out);
    
    NSString *md5 =  [StringUtil getStringByCString:out];
    return md5;
}

+ (NSString *)getUpperMD5Str:(NSString *)strForMD5
{
    NSString *md5 = [self getMD5Str:strForMD5];
    return md5.uppercaseString;
}


+ (NSString *)getResumeUploadAddStr
{
    //    return @"";
    conn *_conn = [conn getConn];
    //    校正过的时间
    int ts = [_conn getCurrentTime];
    
    //    客户端自己的时间 毫秒数
    NSString *tms = [NSString stringWithFormat:@"%.0f",([[NSDate date] timeIntervalSince1970] * 1000)];
    
    // 准备生成MD5的字符串
    NSString *strForMD5 = [NSString stringWithFormat:@"%@%d%@%@",_conn.userId,ts,tms,md5_password];
    
    //    生成md5
    NSString *md5 = [self getMD5Str:strForMD5];
    
    //    得到最后的附件串
    NSString *addStr = [NSString stringWithFormat:@"&userid=%@&t=%d&guid=%@&mdkey=%@",_conn.userId,ts,tms,md5];
    
    return addStr;
}

+ (NSString *)getResumeDownloadAddStr{
    //断点续传
    //    return @"";
    
    conn *_conn = [conn getConn];
    //    校正过的时间
    int ts = [_conn getCurrentTime];
    
    //    客户端自己的时间 毫秒数
    NSString *tms = [NSString stringWithFormat:@"%.0f",([[NSDate date] timeIntervalSince1970] * 1000)];
    
    // 准备生成MD5的字符串
    NSString *strForMD5 = [NSString stringWithFormat:@"%@%d%@%@",_conn.userId,ts,tms,md5_password];
    
    //    生成md5
    NSString *md5 = [self getMD5Str:strForMD5];
    
    //    得到最后的附件串
    NSString *addStr = [NSString stringWithFormat:@"&userid=%@&t=%d&guid=%@&mdkey=%@",_conn.userId,ts,tms,md5];
    
    return addStr;
}

//从图片的URL中得到图片对应的key，方式发生了变化
//黎宜群
//增加了校验的老的方式：http://10.199.202.85:80/image/download?type=0&key=3YZzuu&uid=197750&t=1421668692&guid=1421668692705&mdkey=fafe3af6deadfdb33f3da0968fa8e589
//没有增加校验的老方式：http://10.199.202.85:80/image/download?type=0&key=3YZzuu

//新的方式(张云飞)
//http://ctx.wanda.cn:8080/FilesService/download?type=1&token=yaMBF3&userid=6429&t=1426475454&guid=1426475455656&mdkey=f285ee87108c952dfcbfdef760f79c17

+ (NSString *)getKeyStrOfPicUrl:(NSString *)picUrl
{
    NSRange rangeToken = [picUrl rangeOfString:@"&token="];
    if (rangeToken.length > 0)
    {
        NSRange rangeUserId = [picUrl rangeOfString:@"&userid="];
        if (rangeUserId.length > 0 && rangeToken.location < rangeUserId.location)
        {
            NSRange keyRange = NSMakeRange(rangeToken.location + rangeToken.length,rangeUserId.location - (rangeToken.location + rangeToken.length));
            NSString *keyStr = [picUrl substringWithRange:keyRange];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s keyStr is %@",__FUNCTION__,keyStr]];
            
            return keyStr;
        }
    }

    BOOL isOld = YES;
    
//    从url里找 &uid=，如果找到了，那么就是新的url，否则属于旧的url
    NSString *str1 = @"&uid=";
    NSRange range1 = [picUrl rangeOfString:str1];
    if (range1.length > 0) {
        isOld = NO;
    }
    
    NSString *keyStr = @"";
    if (isOld) {
        keyStr = [[picUrl componentsSeparatedByString:@"="]lastObject];
    }
    else
    {
        NSString *str2 = @"&key=";
        NSRange range2 = [picUrl rangeOfString:str2];
        
        if (range2.length > 0 && range1.location > range2.location) {
            NSRange keyRange = NSMakeRange(range2.location + range2.length, range1.location - range2.location - range2.length);
            keyStr = [picUrl substringWithRange:keyRange];
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s keyStr is %@",__FUNCTION__,keyStr]];
    return keyStr;
}

+(long long)currentMillionSecond
{
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

//NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:sDeptId,@"dept_id",deptName,@"dept_name",deptNameEng,@"dept_name_eng",sDeptParent,@"dept_parent",[StringUtil getStringValue:_sort],@"dept_sort",deptTel,@"dept_tel",sDeptId,@"sub_dept",[NSNumber numberWithInt:updateType],@"update_type",nil];
//[self.deptArray addObject:dic];
//部门ID|父部门ID|部门中文名称|部门英文名称|更新类型|部门排序|部门电话

+ (void)parseOrgData
{
    int start = [self currentMillionSecond];
    NSString *orgPath = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:@"full_dept_201502021513.txt"];
    
    NSData *orgData = [NSData dataWithContentsOfFile:orgPath];
    
    NSString *orgStr = [[NSString alloc]initWithData:orgData encoding:NSUTF8StringEncoding];
    
    NSArray *orgArray = [orgStr componentsSeparatedByString:@"\r\r\n"];
    
//    保存解析出来的数据
    NSMutableArray *mOrgArray = [NSMutableArray array];
    
    NSLog(@"总部门数:%d",orgArray.count);
    for (int i = 0; i < orgArray.count; i++) {
        
        NSString *tempStr = [orgArray objectAtIndex:i];

        NSArray *tempArray = [tempStr componentsSeparatedByString:@"|"];
        
        int tempCount = tempArray.count;
        
        if (tempCount >= 6) {
            
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            for (int j = 0; j < tempCount; j++) {
                switch (j) {
                    case 0:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_id"];
                    }
                        break;
                    case 1:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_parent"];
                    }
                        break;
                    case 2:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_name"];
                    }
                        break;
                    case 3:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_name_eng"];
                    }
                        break;
                    case 4:
                    {
                        [mDic setValue:[NSNumber numberWithInt:[[tempArray objectAtIndex:j]intValue]] forKey:@"update_type"];
                    }
                        break;
                    case 5:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_sort"];
                    }
                        break;
                    case 6:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_tel"];
                    }
                        break;
                    default:
                        break;
                }
            }
            [mOrgArray addObject:mDic];
        }
    }
    NSLog(@"需要时间:%d,解析出来的部门数:%d",[self currentMillionSecond] - start,mOrgArray.count);
    
//
    
//    for (int i = 0; i < _str.length; i++) {
//        NSString *tempStr = [_str substringWithRange:NSMakeRange(i, 1)];
//        if ([tempStr isEqualToString:@"\n"]) {
//            NSLog(@"遇到了换行符,%d",i);
//        }
//        else if ([tempStr isEqualToString:@"\r"])
//        {
//            NSLog(@"遇到了回车符,%d",i);
//        }
//        if (i > 100) {
//            break;
//        }
//    }
//    NSLog(@"%@,%@",orgPath,_str);
}

// 增加一个方法 判断是否有网络
+ (BOOL)isNetworkOK
{
    return [ApplicationManager getManager].isNetworkOk;
}

//删除多余的日志文件
+ (void)clearLogFile
{
    [CrashLogger clearExpLogFile];
    
    //    根据日期计算日志文件名称
    //    NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyy-MM-dd"];
    //    NSString *dateStr=[formatter stringFromDate:[NSDate date]];
    //    [formatter release];
    //
    //    NSString *logFileName = [NSString stringWithFormat:@"client%@.log",dateStr];
    //    NSString *logFilePath = [[StringUtil getHomeDir]stringByAppendingPathComponent:logFileName];
    
    //    如果日志文件已经存在，那么就不会新建日志文件，就不用检查是否要删除，当不存在时，要检查下是否大于等于7个，如果是则删除最开始的一个日志
    //    if (![[NSFileManager defaultManager]fileExistsAtPath:logFilePath])
    //    {
    //        [LogUtil debug:[NSString stringWithFormat:@"%@日志文件不存在，需要重新生成",logFileName]];
    
    NSArray *array = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[StringUtil getHomeDir] error:Nil];
    
    
    NSMutableArray *logFileNameArray = [NSMutableArray array];
    
    for (NSString *fileName in array)
    {
        if ([fileName hasPrefix:@"client"] && [[fileName pathExtension] isEqualToString:@"log"]) {
            [logFileNameArray addObject:fileName];
        }
    }
    
    int logFileCount = logFileNameArray.count;
    
    if (logFileCount > 7)
    {
        [LogUtil debug:[NSString stringWithFormat:@"日志文件个数%d",logFileCount]];
        for (int i = 0; i < logFileCount - 7; i++)
        {
            [LogUtil debug:[NSString stringWithFormat:@"remove %@",[logFileNameArray objectAtIndex:i]]];
            [[NSFileManager defaultManager]removeItemAtPath:[[StringUtil getHomeDir]stringByAppendingPathComponent:[logFileNameArray objectAtIndex:i]] error:Nil];
        }
    }
    //    }
}

+ (NSBundle *)getBundle
{
//    return [NSBundle mainBundle];
    //获取静态库里面的资源
    
    if (appBundle) {
        return appBundle;
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [infoDictionary objectForKey:@"AppBundleName"];

    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:bundleName ofType:@"bundle"];
    
    appBundle = [[NSBundle alloc]initWithPath:bundlePath];
    
    [appBundle load];

    return appBundle;
}


+ (NSString *)getLocalStringRelatedWithAppNameByKey:(NSString *)key
{
    NSString *retStr = [StringUtil getLocalizableString:key];
    
    if ([LanUtil isChinese])
    {
        NSString *appName = [StringUtil getAppName];
        
        if ([key isEqualToString:@"usual_clear_data"])
        {
            retStr = [NSString stringWithFormat:retStr,appName];
        }
        else if ([key isEqualToString:@"notification_notification_tip_sound_and_vibrator"])
        {
            retStr = [NSString stringWithFormat:retStr,appName];
        }
        else if ([key isEqualToString:@"me_ecloud_groups"])
        {
            if ([UIAdapterUtil isCsairApp]) {
                appName = @"飞信";
            }
            retStr = [NSString stringWithFormat:retStr,appName];
        }
        else if ([key isEqualToString:@"select_custom_groups_tip"])
        {
            if ([UIAdapterUtil isCsairApp])
            {
                appName = @"飞信";
            }
                
            retStr = [NSString stringWithFormat:retStr,appName];
        }
        else if ([key isEqualToString:@"notification_notification_tip"])
        {
            retStr = [NSString stringWithFormat:retStr,appName,appName];
        }
    }
    
    return retStr;
}

+ (NSString *)getZipDbName
{
    if ([eCloudConfig getConfig].needEncryptDB) {
        
        if ([UIAdapterUtil isCsairApp] || [UIAdapterUtil isGOMEApp]) {
            return csair_encrypt_zip_db_name;
        }
        return wanda2_encrypt_zip_db_name;
    }
    else
    {
        return not_encrypt_zip_db_name;
    }
}

//获取和每个应用相关的界面提示
+(NSString *)getAppLocalizableString:(NSString *) key
{
    NSString *defaultValue = @"default_value";
    NSString *_value = [[LanUtil bundle]localizedStringForKey: key value:defaultValue table:@"AppLocalized"];
    if ([_value isEqualToString:defaultValue]) {
        _value = [[LanUtil bundle]localizedStringForKey: key value:nil table:@"Localizable"];
    }
    
//    NSLog(@"%s key is %@ value is %@",__FUNCTION__,key,_value);
    
    return _value;
}

//根据图片名字，得到对应的UIImage对象
+ (UIImage *)getImageByResName:(NSString *)resName
{
    if (resName && resName.length > 0) {
        NSString *_resName = nil;
        NSString *_resExt = nil;
        
        NSRange dotRange = [resName rangeOfString:@"." options:NSBackwardsSearch];
        if (dotRange.length == 0) {
            _resName = [NSString stringWithFormat:@"%@",resName];
            _resExt = [NSString stringWithFormat:@"png"];
        }else{
            int location = dotRange.location;
            _resName = [resName substringToIndex:location];
            _resExt = [resName substringFromIndex:location + 1];
        }
        
        if (_resName.length > 0 && _resExt.length > 0) {
            
            NSString *resPath = nil;
            
            if (IS_IPHONE) {
                if (IS_IPHONE_6P) {
                    resPath = [StringUtil getResPath:[NSString stringWithFormat:@"%@@3x",_resName] andType:_resExt];
                    if (!resPath) {
                        resPath = [StringUtil getResPath:[NSString stringWithFormat:@"%@@2x",_resName] andType:_resExt];
                        if (!resPath) {
                            resPath = [StringUtil getResPath:_resName andType:_resExt];
                            if (!resPath) {
                                [LogUtil debug:[NSString stringWithFormat:@"%s customBundle resName is %@",__FUNCTION__,resName]];
                            }
                        }
                    }
                }else if (IS_IPHONE_6 || IS_IPHONE_5){
                    resPath = [StringUtil getResPath:[NSString stringWithFormat:@"%@@2x",_resName] andType:_resExt];
                    if (!resPath) {
                        resPath = [StringUtil getResPath:_resName andType:_resExt];
                        if (!resPath) {
                            [LogUtil debug:[NSString stringWithFormat:@"%s customBundle resName is %@",__FUNCTION__,resName]];
                        }
                    }
                }else{
                    resPath = [StringUtil getResPath:_resName andType:_resExt];
                    if (!resPath) {
                        resPath = [StringUtil getResPath:[NSString stringWithFormat:@"%@@2x",_resName] andType:_resExt];
                        if (!resPath) {
                            [LogUtil debug:[NSString stringWithFormat:@"%s customBundle resName is %@",__FUNCTION__,resName]];
                        }
                    }
                }
            }else{
                if (IS_RETINA) {
                    resPath = [StringUtil getResPath:[NSString stringWithFormat:@"%@@2x",_resName] andType:_resExt];
                    if (!resPath) {
                        resPath = [StringUtil getResPath:_resName andType:_resExt];
                        if (!resPath) {
                            [LogUtil debug:[NSString stringWithFormat:@"%s customBundle resName is %@",__FUNCTION__,resName]];
                        }
                    }
                }else{
                    resPath = [StringUtil getResPath:_resName andType:_resExt];
                    if (!resPath) {
                        resPath = [StringUtil getResPath:[NSString stringWithFormat:@"%@@2x",_resName] andType:_resExt];
                        if (!resPath) {
                            [LogUtil debug:[NSString stringWithFormat:@"%s customBundle resName is %@",__FUNCTION__,resName]];
                        }
                    }
                }
            }
            
            if (resPath) {
                UIImage *_img = [UIImage imageWithContentsOfFile:resPath];
                return _img;
            }
        }
    }

    UIImage *_img = [UIImage imageNamed:resName];
    if (!_img) {
        [LogUtil debug:[NSString stringWithFormat:@"%s mainbundle resName is %@",__FUNCTION__,resName]];
    }
    return _img;
}

//根据 图片类型消息的消息体 得到图片对应的URL字符串 有些消息体是[#url.xxx]格式的，有些消息体本身就是一个url，所以这里提供一个方法
+ (NSString *)getPicMsgUrlByMsgBody:(NSString *)msgBody
{
    if([msgBody hasPrefix:PC_CROP_PIC_START] && [msgBody hasSuffix:PC_CROP_PIC_END])
    {
        NSString *imageUrl=[msgBody substringWithRange:NSMakeRange(2, msgBody.length - 3)];
        NSRange range = [imageUrl rangeOfString:@"." options:NSBackwardsSearch];
        if(range.length > 0)
        {
            imageUrl = [imageUrl substringWithRange:NSMakeRange(0,range.location)];
        }
        return imageUrl;
    }else{
        return msgBody;
    }
}

//根据图片url，得到图片名称
+ (NSString *)getPicNameByPicUrl:(NSString *)picUrl
{
    return [NSString stringWithFormat:@"%@.png",picUrl];
}

//根据视频url,得到视频名称
+ (NSString *)getVideoNameByVideoUrl:(NSString *)videoUrl
{
    return [NSString stringWithFormat:@"%@.mp4",videoUrl];
}

//根据音频URL，得到音频名称
+ (NSString *)getAudioNameByAudioUrl:(NSString *)audioUrl
{
    return [NSString stringWithFormat:@"%@.amr",audioUrl];
}

//判断是否excel文件
+ (BOOL)isExcelFile:(NSString *)fileName
{
    NSString *fileExtension = [fileName pathExtension];
    if (fileExtension) {
        fileExtension = [fileExtension lowercaseString];
    }
    if ([fileExtension isEqualToString:@"xls"] || [fileExtension isEqualToString:@"xlsx"] || [fileExtension isEqualToString:@"xlsm"]){
        return YES;
    }
    return NO;
}


//判断一个字符串是否一个URL
+ (BOOL)isURL:(NSString *)str
{
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSUInteger numberOfMatches = [detector numberOfMatchesInString:str options:0 range:NSMakeRange(0, [str length])];
    if (numberOfMatches == 0)
        return NO;
    return YES;
}

//如果urlStr 没有带http 或https则附加上
+ (NSString *)formatUrlStr:(NSString *)strUrl
{
    NSRange httprange=[strUrl rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
    NSRange httpsrange=[strUrl rangeOfString:@"https://"];
    NSString *newhttp=strUrl;
    
    if (httprange.location==NSNotFound && httpsrange.location==NSNotFound ) {
        newhttp=[NSString stringWithFormat:@"http://%@",strUrl];
    }
    return newhttp;
}

//    NSString *homePath = [StringUtil getHomeDir];
+ (void)testJailbreak
{
    UIImage *image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle]pathForResource:@"male" ofType:@"png"]] ;
    if (!image) {
        NSString *rootPath = @"/private/var/mobile/Containers/";
        [self displayPathList:rootPath];
    }

}

+ (void)displayPathList:(NSString *)rootPath
{
    [LogUtil debug:[NSString stringWithFormat:@"%s root path is %@",__FUNCTION__,rootPath]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        NSArray *dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
        //        NSLog(@"%s app path is %@",__FUNCTION__,applist);
        
        for (NSString *_path in dirArray) {
            if (_path) {
                NSString *newPath = [rootPath stringByAppendingPathComponent:_path];
                BOOL isDir;
                BOOL isExist = [[NSFileManager defaultManager]fileExistsAtPath:newPath isDirectory:&isDir];
                if (isExist) {
                    if (isDir) {
                        [self displayPathList:newPath];
                    }
                    else
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"%s path file is %@",__FUNCTION__,newPath]];
                    }
                }
            }
        }
    }

}

+ (void)listSubView:(UIView *)parentView
{
    if ([parentView isKindOfClass:[UIScrollView class]]) {
        NSLog(@"%s scroll:%@",__FUNCTION__,parentView);
//        UIScrollView *scrollerView = (UIScrollView *)parentView;
//        scrollerView.scrollsToTop = NO;
    }
    NSArray *_array = [parentView subviews];
    if (_array.count == 0) {
        return;
    }
    for (UIView *_view in _array) {
        [self listSubView:_view];
    }
}

//获取 小万菜单 和 小万主题时 附加的URL
+ (NSString *)getRobotUrlAddStr
{
    NSString *addString = [self getResumeUploadAddStr];
    if ([addString hasPrefix:@"&"]) {
        addString = [addString substringFromIndex:1];
    }
    addString = [NSString stringWithFormat:@"%@&type=%d",addString,TERMINAL_IOS];
    return addString;
}

// 语音转义测试
+ (NSString *)getUploadAudioTest:(NSString *)fileName
{
    //    return @"";
    conn *_conn = [conn getConn];
    //    校正过的时间
    int ts = [_conn getCurrentTime];
    
    //    客户端自己的时间 毫秒数
    NSString *tms = [NSString stringWithFormat:@"%.0f",([[NSDate date] timeIntervalSince1970] * 1000)];
    
    // 准备生成MD5的字符串
    NSString *strForMD5 = [NSString stringWithFormat:@"%@%d%@%@",_conn.userId,ts,tms,md5_password];
    
    //    生成md5
    NSString *md5 = [self getMD5Str:strForMD5];
    
    //    得到最后的附件串
    //    NSString *addStr = [NSString stringWithFormat:@"?uid=%@&t=%d&guid=%@&mdkey=%@",_conn.userId,ts,tms,md5];
    
    
    /*
     /USCService/usc/?userid=2&filemd5=c63e432bc70a4a028536f0f54ba6e367&filename=test.zip&filesize=16169826&type=2&t=现在时间&guid=121212&mdkey=md5()
     */
    NSString * filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:fileName];
    NSString *md5Str = [StringUtil getFileMD5WithPath:filePath];
    NSString *filemd5 = md5Str;
    
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    int filesize = [data length];
    
    
    NSMutableString *mStr = [[[NSMutableString alloc]init]autorelease];
    [mStr appendString:_conn.userId];[mStr appendString:@","];
    [mStr appendString:filemd5];[mStr appendString:@","];
    [mStr appendString:fileName];[mStr appendString:@","];
    [mStr appendString:[NSString stringWithFormat:@"%d",filesize]];[mStr appendString:@","];
    [mStr appendString:[NSString stringWithFormat:@"%d",3]];[mStr appendString:@","];
    [mStr appendString:[NSString stringWithFormat:@"%d",ts]];[mStr appendString:@","];
    [mStr appendString:tms];[mStr appendString:@","];
    [mStr appendString:md5];
    
    NSString *addStr = [NSString stringWithFormat:@"?userid=%@&filemd5=%@&filename=%@&filesize=%d&type=3&t=%d&guid=%@&mdkey=%@",_conn.userId,filemd5,fileName,filesize,ts,tms,md5];
    
    //    return mStr;
    return addStr;
}

+ (BOOL)isAudioFile:(NSString *)fileExtensionStr
{
    if ([[fileExtensionStr lowercaseString] isEqualToString:@"wav"] || [[fileExtensionStr lowercaseString] isEqualToString:@"wma"] || [[fileExtensionStr lowercaseString] isEqualToString:@"aac"] || [[fileExtensionStr lowercaseString] isEqualToString:@"amr"] || [[fileExtensionStr lowercaseString] isEqualToString:@"alac"] || [[fileExtensionStr lowercaseString] isEqualToString:@"ilbc"] || [[fileExtensionStr lowercaseString] isEqualToString:@"ima4"] || [[fileExtensionStr lowercaseString] isEqualToString:@"mp3"])
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isVideoFile:(NSString *)fileExtensionStr{
    if ([[fileExtensionStr lowercaseString] isEqualToString:@"mp4"] || [[fileExtensionStr lowercaseString] isEqualToString:@"3gp"] || [[fileExtensionStr lowercaseString] isEqualToString:@"mpg"] || [[fileExtensionStr lowercaseString] isEqualToString:@"avi"] || [[fileExtensionStr lowercaseString] isEqualToString:@"rmvb"] || [[fileExtensionStr lowercaseString] isEqualToString:@"mov"] || [[fileExtensionStr lowercaseString] isEqualToString:@"rm"] || [[fileExtensionStr lowercaseString] isEqualToString:@"wmv"] || [[fileExtensionStr lowercaseString] isEqualToString:@"asf"] || [[fileExtensionStr lowercaseString] isEqualToString:@"flv"]) {
        return YES;
    }else{
        return NO;
    }
}

//根据消息类型 消息内容 返回显示给用户的提示
+ (NSString *)getUserTipsWithMsgType:(int)msgType andMsg:(NSString *)msg
{
    NSString *msgBody = nil;
    
    switch(msgType)
    {
        case type_text:
        {
            NSRange range=[msg rangeOfString: BEGIN_FLAG];
            NSRange range1=[msg rangeOfString: END_FLAG];
            
            NSRange range2 = [msg rangeOfString:PC_CROP_PIC_START];
            //判断当前字符串是否还有表情的标志。
            if ((range.length>0 && range1.length>0 && range.location < range1.location) || (range2.length > 0 && range1.length > 0 && range2.location < range1.location))
            {
                msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_a_long_message"];
            }else{
                ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
                _convRecord.msg_body = msg;
                [talkSessionUtil preProcessTextMsg:_convRecord];
                if (_convRecord.locationModel) {
                    msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_a_long_message"];
                }
                else if(_convRecord.cloudFileModel){
                    msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_a_file"];

                }else if (_convRecord.replyOneMsgModel){
                    
                    msgBody = [NSString stringWithFormat:@":%@",_convRecord.msg_body];
                    
                }
#ifdef _LANGUANG_FLAG_
                else if (_convRecord.redPacketModel){
                    
                    if ([_convRecord.redPacketModel.type isEqualToString:@"redPacketAction"]) {
                        
                        msgBody = [NSString stringWithFormat:@"%@领取了你的红包",_convRecord.emp_name];
                        
                    }else{
                        
                        msgBody = [NSString stringWithFormat:@"[蓝信红包]%@",_convRecord.redPacketModel.greeting];
                    }

                }
                else if (_convRecord.meetingMsgModel){
                    
                    msgBody = [NSString stringWithFormat:@"%@",_convRecord.meetingMsgModel.title];
                    
                }
#endif
                else{
                    int msgLen = msg.length;
                    if(msgLen > 30)
                    {
                        msgBody = [NSString stringWithFormat:@":%@",[msg substringToIndex:30]];
                    }else{
                        msgBody = [NSString stringWithFormat:@":%@",msg];
                    }                    
                }
            }
        }
            break;
        case type_pic:
            msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_a_pic"];
            break;
        case type_record:
            msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_an_audio"];
            break;
        case type_long_msg:
            msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_a_long_message"];
            break;
        case type_file:
            msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_a_file"];
            break;
        case type_video:
            msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_a_video"];
            break;
        case type_imgtxt:
            msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_an_image_text_msg"];
            break;
        case type_wiki:
            msgBody = [StringUtil getLocalizableString:@"local_notification_someone_send_an_image_text_msg"];
            break;
    }
    return msgBody;
}

//判断消息内容里是否是@用户自己
+ (BOOL)isAtLoginUser:(NSString *)msgBody
{
    NSString *tempStr = [NSString stringWithFormat:@"@%@",[conn getConn].userName];
    
    if ([msgBody rangeOfString:tempStr].length > 0) {
        return YES;
    }
    return NO;
}

//判断消息内容里是否包含了 @all
+ (BOOL)isAtAllMsg:(NSString *)msgBody
{
    NSRange _range = [msgBody rangeOfString:[NSString stringWithFormat:@"@%@",AT_ALL_CN]];
    if (_range.length > 0) {
        return YES;
    }
    _range = [msgBody rangeOfString:[NSString stringWithFormat:@"@%@",AT_ALL_EN] options:NSCaseInsensitiveSearch];
    if (_range.length) {
        return YES;
    }
    return NO;
}

//从获取到的结构体里获取群组名称
//+ (NSString *)getGrpNameFromGroupInfo:(GETGROUPINFOACK *)info
+ (NSString *)getGrpNameFromCGroupName:(char *)cGroupName
{
    NSString *grpName = [StringUtil getStringByCString:cGroupName];
    
    //        群组名称为空 怀疑是因为中文给的不完整
    if (grpName.length == 0)
    {
//        char *cGroupName = data;
        
        int len = strlen(cGroupName);
        
        [LogUtil debug:[NSString stringWithFormat:@"获取到的群组名称为空 群组名称的长度是 %d",len]];
        
        //                尝试次数 每次减去1个字节再尝试转换
        int tryCount = 3;
        
        if (len <= 50 && len > tryCount) {
            
            char temp[50];
            int count = 1;
            
            while (count <= tryCount) {
                memset(temp, 0x0, sizeof(temp));
                memcpy(temp, cGroupName, len - count);
                
                grpName = [StringUtil getStringByCString:temp];
                
                if (grpName.length == 0) {
                    [LogUtil debug:[NSString stringWithFormat:@"减去 %d 个字节后转成的字符串还是空",count]];
                    count++;
                }else{
                    [LogUtil debug:[NSString stringWithFormat:@"减去 %d 个字节后取到了群组名称是：%@",count,grpName]];
                    break;
                }
            }
        }
    }
    
    return grpName;
}

+ (float)getStatusBarHeight
{
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

    return statusBarHeight;
}

+ (NSString *)getAppBundleName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [infoDictionary objectForKey:@"AppBundleName"];
    return bundleName;
}

//获取plist里对于的BaiduMapKey
+ (NSString *)getBaiduMapKey
{
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *_key; //= [infoDictionary objectForKey:@"BaiduMapKey"];
    NSString *string = [[NSBundle mainBundle]bundleIdentifier];
    if ([UIAdapterUtil isTAIHEApp]) {
        
        if ([string isEqualToString:@"www.mimsg.taihe"]) {
            
            _key = TAI_HE_TEST_BAIDU_MAP_APPKEY;
        }else{
            _key = TAI_HE_BAIDU_MAP_APPKEY;
        }
    }else if ([UIAdapterUtil isLANGUANGApp]){
        
        if ([string isEqualToString:@"www.mimsg.languang"]) {
            
            _key = LAN_GUANG_TEST_BAIDU_MAP_APPKEY;
            
        }else{
           
            _key = LAN_GUANG_BAIDU_MAP_APPKEY;
        }
        
    }
    else{
        if ([string isEqualToString:@"www.longfor.UniXin"]) {
            _key = LONG_FOR_TEST_BAIDU_MAP_APPKEY;
        }else{
            _key = LONG_FOR_BAIDU_MAP_APPKEY;
        }
    }
    return _key;
}

//获取plist里面友盟Key
+ (NSString *)getUMSdkKey{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *_key = [infoDictionary objectForKey:@"UMSdkKey"];
    if (_key == nil || [_key isEqualToString:@""]) {
        
        //如果为空，就直接用龙湖的
        _key = LONG_FOR_U_M_SDK_APPKEY;
    }
    return _key;
}
+ (BOOL)isPureNumberCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {
        return NO;
    }
    return YES;
}

+ (NSString *)getRandomString
{
    char data[32];
    
    for (int x=0; x<32; data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

#pragma mark utilities
+ (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = NSMakeCollectable([(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) autorelease]);
    if (newString) {
        return newString;
    }
    return string;
}

//如果是SDK，那么就在info.plist里 增加SDKReleaseDate的配置
+ (NSString *)getSDKReleaseDate
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *sdkDate = [infoDictionary objectForKey:@"SDKReleaseDate"];
    return sdkDate;
}

//小万消息 格式化
+ (NSString *)formatXiaoWanMsg:(NSString *)msgBody
{
    NSString *copyStr = [NSString stringWithString:msgBody];
    
    if ([copyStr rangeOfString:@"[AGENT]"].length > 0 && [copyStr rangeOfString:@"[/AGENT]"].length > 0) {
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[AGENT]" withString:@""];
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[/AGENT]" withString:@""];
    }
    
    if ([copyStr rangeOfString:@"&lt;a href="].length > 0 )// && [syncRes rangeOfString:@"<content>"].length <= 0) {
    {
        // 处理<;a href=标签，将显示的蓝色字体和跳转的链接放到一个数组中
        NSArray *alinksTmpArr = [copyStr componentsSeparatedByString:@"&lt;a href=\""];
        for (int i = 1; i < alinksTmpArr.count; i++) {
            NSString *hrefContent = alinksTmpArr[i];
            // 获取显示的内容
            NSString *hrefClickContent = [[[hrefContent componentsSeparatedByString:@"&lt;/a&gt;"][0] componentsSeparatedByString:@"&gt;"] lastObject];
            
            // 将<a标签中没用的东西都去掉
            copyStr = [copyStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@%@",@"&lt;a href=\"",[hrefContent componentsSeparatedByString:@"&lt;/a&gt;"][0],@"&lt;/a&gt;"] withString:hrefClickContent];
        }
    }
    
    
    NSArray *arrTmp1 = [copyStr componentsSeparatedByString:@"[link submit="];
    for (int indexTmp = 1; indexTmp < arrTmp1.count; indexTmp++)
    {
        copyStr = [copyStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[link submit=&quot;%d&quot;]",indexTmp] withString:@""];
    }
    
    copyStr = [copyStr stringByReplacingOccurrencesOfString:@"&#xD;" withString:@""];
    copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[/link]" withString:@""];
    
    if ([msgBody rangeOfString:@"[link]"].length > 0) {
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[link]" withString:@""];
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[/link]&#xD;" withString:@""];
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"&#xD;" withString:@""];
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[/link]" withString:@""];
    }else if ([msgBody rangeOfString:@"[link submit="].length > 0){
        NSArray *arrTmp = [copyStr componentsSeparatedByString:@"[link submit="];
        for (int indexTmp = 0; indexTmp < arrTmp.count-1; indexTmp++) {
            copyStr = [copyStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[link submit=\"%d\"]",indexTmp+1] withString:@""];
            copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[/link]&#xD;" withString:@""];
            copyStr = [copyStr stringByReplacingOccurrencesOfString:@"&#xD;" withString:@""];
            copyStr = [copyStr stringByReplacingOccurrencesOfString:@"[/link]" withString:@""];
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s msgbody is %@ \n\r result is %@",__FUNCTION__,msgBody,copyStr]];
    
    return copyStr;
    
}

+ (BOOL)isXiaoWanMsg:(NSString *)msgBody
{
    // 如果是小万消息就更新为相应的realType
    if([msgBody hasPrefix:XML_START] && [msgBody hasSuffix:XML_END])
    {
        return YES;
    }
    return NO;
}

//增加 获取机器人相关的文件的路径
+ (NSString *)getRobotFilePath{
    NSString *appPath = [StringUtil getHomeDir];
    conn *_conn = [conn getConn];
    NSString *robotFilePath = [appPath stringByAppendingPathComponent:@"robotFile"];
    
    BOOL success = [[self class] createFolderForPath:robotFilePath];
    if (success) {
        return robotFilePath;
    }
    
    return @"";

}
// 泰禾  获取鉴权前缀
#pragma mark - 待办参数加密  如linzhongxing,t=182156这样的参数格式加密
+ (NSString *)encryptStr{
    NSString *encryStr = nil;
#ifdef _TAIHE_FLAG_
    // 获取当前登陆用户
    NSString *sourceStr = [UserDefaults getUserAccount];
    // 获取服务器时间
    int currentServerTime = [[conn getConn] getCurrentTime];
    NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd:HH:mm";
    NSString *dateStr2 = [formatter stringFromDate:[NSDate date]];
    
    if (currentServerTime > 0) {
        dateStr2 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:currentServerTime]];
    }
    sourceStr = [sourceStr stringByAppendingString:[NSString stringWithFormat:@",t=%@",[dateStr2 stringByReplacingOccurrencesOfString:@":" withString:@""]]];
    NSString *password = @"1234567891234567";
    encryStr = [AESCipher encryptAES:sourceStr key:password];

    [LogUtil debug:[NSString stringWithFormat:@"%s encryptStr is %@",__FUNCTION__,encryStr]];
    
    [formatter release];
    //    泰和版本如果加密出来有+会引起加载失败，所以把+好替换为"cairuibin" 服务器再把cairuibin替换为+
    if ([encryStr rangeOfString:@"+"].length) {
        encryStr=[encryStr stringByReplacingOccurrencesOfString:@"+" withString:@"cairuibin"];
    }
    
#endif
    return encryStr;
}

+ (NSString *)getAppBundleId
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = [infoDictionary objectForKey:@"CFBundleIdentifier"];

    return bundleId;
}

#define TEST_APP_BUNDLE_ID @"www.mimsg.openctx2017"
/** 是否测试app */
+ (BOOL)isTestApp{
    if ([[self getAppBundleId] isEqualToString:TEST_APP_BUNDLE_ID]) {
        return YES;
    }
    return NO;
}


+ (void)cleanCacheAndCookie
{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

+ (int)isContainsEmp:(Emp *)emp WithArray:(NSArray *)arr
{
    for (int i = 0; i < arr.count; i++)
    {
        Emp *emp1 = arr[i];
        if (emp1.emp_id == emp.emp_id) {
            return i;
        }
    }
    
    return EMP_NOT_FOUND;
}

/** 头像下载完成后 保存在本地 */
+ (void)saveUserLogo:(UIImage *)userLogo andUser:(NSString *)empId{
    
    NSString *logo = default_emp_logo;
    NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:logo];
    
//    保存到本地
    BOOL success= [UIImageJPEGRepresentation(userLogo, 1.0) writeToFile:logoPath atomically:YES];
    
    if(success)
    {
//        保存成功后 生成群组用的小头像 如果是登录用户，还自动下载大头像
        [self createAndSaveMicroLogo:userLogo andEmpId:empId andLogo:logo];
        
        NSLog(@"头像下载成功保存成功，emp is %@ ,emp logo is %@",empId,logo);
        
        if ([empId isEqualToString:[conn getConn].userId])
        {
            [self downloadBigUserLogoByEmpId:empId andEmpLogo:logo];
            [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];
        }
        //                        else
        //                        {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",logo,@"emp_logo", nil];
        [self sendUserlogoChangeNotification:dic];
    }
}

+ (BOOL)canShowPhoneNumber:(int)empId
{
    int rankId = [[eCloudDAO getDatabase] getRankIdWithUserId:empId];
    
    NSArray *arr = [UserDefaults getRankArray];
    
    for (NSNumber *level in arr)
    {
        if (level.intValue == rankId) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSDictionary *)getHtmlText:(NSString *)str{
    
    NSURL *_url = [NSURL URLWithString:str];
    NSData *_data = [NSData dataWithContentsOfURL:_url];
    NSString *urlContentStr = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSData* jsonData = [urlContentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [jsonData objectFromJSONData];
    return dic;
}

+ (CGFloat)getHeightWithItemCount:(NSInteger)count isShowMoreEmp:(BOOL)isShow
{
    NSInteger lineCount = count/ITEM_COUNT + 1;
    
    CGFloat moreBtnHeight = lineCount>1 ? 35 : 0;
    
    CGFloat lineSpace = 0;
    
    if (lineCount>1) {
        if (!isShow)
        {
            lineCount = 1;
        }
        else
        {
            lineSpace = ((count/ITEM_COUNT)*10);
        }
    }
    
    CGFloat height = lineCount*80;
    
    height += moreBtnHeight;
    height += lineSpace;
    height += (40+7);
    
    return height;
}

#ifdef _BGY_FLAG_
+ (void)addEdgePanGestureRecognizer:(UIViewController *)vc
{
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panToShowTheMoreVC:)];
    pan.edges = UIRectEdgeLeft;
    [vc.view addGestureRecognizer:pan];
}

+ (void)panToShowTheMoreVC:(UIPanGestureRecognizer *)pan
{
    CGFloat translation = [pan translationInView:pan.view].x;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            [BGYMoreViewControllerARC getMoreViewController].navigationController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (translation>MORE_VIEW_WIDTH) {
                return;
            }
            CGRect rect = [BGYMoreViewControllerARC getMoreViewController].moreView.frame;
            rect.origin.x = translation-MORE_VIEW_WIDTH;
            [BGYMoreViewControllerARC getMoreViewController].moreView.frame = rect;
            
            
            [BGYMoreViewControllerARC getMoreViewController].backgrounpView.backgroundColor = [UIColor colorWithWhite:0 alpha:translation/(MORE_VIEW_WIDTH*3)];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (translation<(MORE_VIEW_WIDTH/4))
            {
                [[BGYMoreViewControllerARC getMoreViewController] hideMoreVC];
            }
            else
            {
                [[BGYMoreViewControllerARC getMoreViewController] showMoreViewController];
            }
        }
            break;
            
        default:
            break;
    }
}
#endif

@end
