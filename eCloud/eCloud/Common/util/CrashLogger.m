//
//  CrashLogger.m
//  eCloud
//
//  Created by yanlei on 2017/2/20.
//  Copyright © 2017年 深圳市网信科技有限公司. All rights reserved.
//

#import "CrashLogger.h"
#import "LogUtil.h"

@implementation CrashLogger

+ (void)initCrashLogs{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}
void UncaughtExceptionHandler(NSException *exception){
    if (exception ==nil)return;
    // 异常信息
    NSArray *array = [exception callStackSymbols]; // 调用栈信息（错误来源于哪个方法）
    NSString *reason = [exception reason]; // 异常描述（报错理由）
    NSString *name  = [exception name];  // 异常名字
    NSString *exceptionTime = [[NSDate date] my_formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDictionary *dict = @{@"exceptiontime":exceptionTime,@"appException":@{@"exceptioncallStachSymbols":array,@"exceptionreason":reason,@"exceptionname":name}};
    
    if([CrashLogger writeCrashFileOnDocumentsException:dict]){
        // 弹出提示框 按需要弹出提示框
//        [CrashLogger handle];
    }
}

NSString * const SDCrashFileDirectory = @"CrashFileDirectory";
+ (NSString *)sd_getCachesPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}


/*
 功能描述
 删除多余的异常日志文件
 */
+ (void)clearExpLogFile
{
    NSString *crashPath = [[self sd_getCachesPath] stringByAppendingPathComponent:SDCrashFileDirectory];

    
    NSArray *fileArray = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:crashPath error:Nil];
    
    int maxFileCount = 7;
    int logFileCount = (int)fileArray.count;
    
    if (logFileCount > maxFileCount)
    {
        [LogUtil debug:[NSString stringWithFormat:@"日志文件个数%d",logFileCount]];
        for (int i = 0; i < logFileCount - maxFileCount; i++)
        {
            [LogUtil debug:[NSString stringWithFormat:@"remove %@",[fileArray objectAtIndex:i]]];
            [[NSFileManager defaultManager]removeItemAtPath:[crashPath stringByAppendingPathComponent:[fileArray objectAtIndex:i]] error:nil];
        }
    }
    //    }
}


/*
 功能说明
 获取当前异常日志文件的路径
 */
+ (NSString *)getCurExpLogFilePath
{
    NSString *time = [[NSDate date] my_formattedDateWithFormat:@"yyyyMMdd" locale:[NSLocale currentLocale]];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *crashname = [NSString stringWithFormat:@"%@_%@Crashlog.log",time,infoDictionary[@"CFBundleName"]];
    NSString *crashPath = [[self sd_getCachesPath] stringByAppendingPathComponent:SDCrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filepath = [crashPath stringByAppendingPathComponent:crashname];
    return filepath;
}

// 写入
+ (BOOL)writeCrashFileOnDocumentsException:(NSDictionary *)exception{
    NSString *time = [[NSDate date] my_formattedDateWithFormat:@"yyyyMMdd" locale:[NSLocale currentLocale]];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *crashname = [NSString stringWithFormat:@"%@_%@Crashlog.log",time,infoDictionary[@"CFBundleName"]];
    NSString *crashPath = [[self sd_getCachesPath] stringByAppendingPathComponent:SDCrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    //设备信息
    NSMutableDictionary *deviceInfos = [NSMutableDictionary dictionary];
    [deviceInfos setObject:[infoDictionary objectForKey:@"DTPlatformVersion"] forKey:@"DTPlatformVersion"];
    [deviceInfos setObject:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"CFBundleShortVersionString"];
//    [deviceInfos setObject:[infoDictionary objectForKey:@"UIRequiredDeviceCapabilities"] forKey:@"UIRequiredDeviceCapabilities"];
    BOOL isSuccess = [manager createDirectoryAtPath:crashPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (isSuccess) {
        NSString *filepath = [crashPath stringByAppendingPathComponent:crashname];
        NSMutableDictionary *logs = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
        if (!logs) {
            logs = [[NSMutableDictionary alloc] init];
        }
        //日志信息
        NSDictionary *infos = @{@"Exception":exception,@"DeviceInfo":deviceInfos};
        
        NSData *infoData = [NSJSONSerialization dataWithJSONObject:infos options:NSJSONWritingPrettyPrinted error:nil];
        if (![manager fileExistsAtPath:filepath]) {
            [manager createFileAtPath:filepath contents:nil attributes:nil];
        }
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filepath];
        [handle seekToEndOfFile];
        
        [handle writeData:infoData];
        [handle closeFile];
        handle = nil;
        [LogUtil debug:[NSString stringWithFormat:@"崩溃日志采集成功:\n时间:%@\n路径:%@",exception[@"exceptiontime"],crashPath]];
        return YES;
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"崩溃日志采集失败,时间：%@",exception[@"exceptiontime"]]];
        return NO;
    }
}
// 读取崩溃日志
+ (nullable NSArray *)sd_getCrashLogs{
    NSString *crashPath = [[self sd_getCachesPath] stringByAppendingPathComponent:SDCrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:crashPath error:nil];
    NSMutableArray *result = [NSMutableArray array];
    if (array.count == 0) return nil;
    for (NSString *name in array) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[crashPath stringByAppendingPathComponent:name]];
        [result addObject:dict];
    }
    return result;
}
// 清除崩溃日志
+ (BOOL)sd_clearCrashLogs{
    NSString *crashPath = [[self sd_getCachesPath] stringByAppendingPathComponent:SDCrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:crashPath]) return YES; //如果不存在,则默认为删除成功
    NSArray *contents = [manager contentsOfDirectoryAtPath:crashPath error:NULL];
    if (contents.count == 0) return YES;
    NSEnumerator *enums = [contents objectEnumerator];
    NSString *filename;
    BOOL success = YES;
    while (filename = [enums nextObject]) {
        if(![manager removeItemAtPath:[crashPath stringByAppendingPathComponent:filename] error:NULL]){
            success = NO;
            break;
        }
    }
    return success;
}

+ (void)handle
{
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 8)
    {
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"异常退出" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alterView show];
    }
    else
    {
        // ios 8以后使用新的弹出框
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"出现异常" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // 退出程序
            exit(0);
        }]];
        
        [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alertCtrl animated:YES completion:nil];
    }
    // 程序崩溃后，runloop已经被释放掉了，要新建一个
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 退出程序
    exit(0);
}
@end

#pragma mark - 增加NSDate的分类的一个方法
@implementation NSDate(myformatter)
- (NSString *)my_formattedDateWithFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

- (NSString *)my_formattedDateWithFormat:(NSString *)format locale:(NSLocale *)locale{
    return [self my_formattedDateWithFormat:format timeZone:[NSTimeZone systemTimeZone] locale:locale];
}

- (NSString *)my_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    
    [formatter setDateFormat:format];
    [formatter setTimeZone:timeZone];
    [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}
@end
