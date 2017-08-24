
#import "LogUtil.h"
#import "logger.h"
#import "conn.h"
#import "StringUtil.h"
#import "CrashLogger.h"

#import "talkSessionViewController.h"

@implementation LogUtil
+(void)debug:(NSString*)logStr
{
    //    NSLog(@"%@",logStr);
    //  		LOGGER_DEBUG("%s\n",[logStr cStringUsingEncoding:NSUTF8StringEncoding]);
    if (logStr == nil || logStr.length == 0) {
        return;
    }
    conn *_conn = [conn getConn];
    if ([logStr cStringUsingEncoding:NSUTF8StringEncoding]) {
        BOOL ret = [_conn debug:[NSString stringWithFormat:@"%@\n",logStr]];
        if(!ret)
        {
            LOGGER_DEBUG("%s\n",[logStr cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
}

//给功能按钮增加长按事件 发送当天日志
+ (void)addLongPressToButton1:(UIButton *)button
{
    UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processLongPress1:)]autorelease];
    longPress.minimumPressDuration = 1; //1s 定义按的时间
    [button addGestureRecognizer:longPress];
}
//给功能按钮增加长按事件 发送昨天日志
+ (void)addLongPressToButton2:(UIButton *)button
{
    UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processLongPress2:)]autorelease];
    longPress.minimumPressDuration = 1; //1s 定义按的时间
    [button addGestureRecognizer:longPress];
}

//给功能按钮增加长按事件 发送前天日志
+ (void)addLongPressToButton3:(UIButton *)button
{
    UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processLongPress3:)]autorelease];
    longPress.minimumPressDuration = 1; //1s 定义按的时间
    [button addGestureRecognizer:longPress];
}

//给功能按钮增加长按事件 发送eCloud.log
+ (void)addLongPressToButton4:(UIButton *)button
{
    UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processLongPress4:)]autorelease];
    longPress.minimumPressDuration = 1; //1s 定义按的时间
    [button addGestureRecognizer:longPress];
}

//给功能按钮增加长按事件 发送异常日志
+ (void)addLongPressToButton5:(UIButton *)button
{
    UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processLongPress5:)]autorelease];
    longPress.minimumPressDuration = 1; //1s 定义按的时
    [button addGestureRecognizer:longPress];
}

//发送日志，参数是文件名字
+ (void)sendLog:(NSString *)logFilePath
{
    NSData * logData = nil;
    
//    NSString *logFilePath = [[StringUtil getHomeDir]stringByAppendingPathComponent:logFileName];
    
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:logFilePath])
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s 发送日志%@",__FUNCTION__,logFilePath]];
        NSString *logFileName = [logFilePath lastPathComponent];
        
        NSString *logExt = [logFileName pathExtension];
        if ([logExt isEqualToString:@"log"]) {
            NSString *txtLogFileName = [logFileName stringByReplacingOccurrencesOfString:@".log" withString:@".txt"];
            NSString *txtLogFilePath = [[StringUtil getHomeDir]stringByAppendingPathComponent:txtLogFileName];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:txtLogFilePath]) {
                [[NSFileManager defaultManager]removeItemAtPath:txtLogFilePath error:nil];
            }
            BOOL success = [[NSFileManager defaultManager]copyItemAtPath:logFilePath toPath:txtLogFilePath error:nil];
            if (!success) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 把.log文件复制一份为.txt文件失败",__FUNCTION__]];
            }else{
                logData = [NSData dataWithContentsOfFile:txtLogFilePath];
                logFileName = [NSString stringWithString:txtLogFileName];
            }
        }
        if (!logData) {
            logData = [NSData dataWithContentsOfFile:logFilePath];
        }
        [[talkSessionViewController getTalkSession]displayAndUploadLocalFile:logData withDic:[NSMutableDictionary dictionaryWithObject:logFileName forKey:@"fileName"]];
    }
}

//长按第一个功能按钮 可以 发送当天的日志文件
+(void)processLongPress1:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        //        找到当天的日志文件
        NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr=[formatter stringFromDate:[NSDate date]];
        [formatter release];
        
        NSString *logFileName = [NSString stringWithFormat:@"client%@.log",dateStr];
    
        NSString *logFilePath = [[StringUtil getHomeDir]stringByAppendingPathComponent:logFileName];
        
        [[self class]sendLog:logFilePath];
    }
}

//长按第一个功能按钮 可以 发送昨天的日志文件
+(void)processLongPress2:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        int currentTime =  [[NSDate date] timeIntervalSince1970];
        int yesterday = currentTime - 60 * 60 * 24;
        
        NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSince1970:yesterday];
        
        //        找到前一天的日志文件
        NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr=[formatter stringFromDate:yesterdayDate];
        [formatter release];
        
        NSString *logFileName = [NSString stringWithFormat:@"client%@.log",dateStr];
        NSString *logFilePath = [[StringUtil getHomeDir]stringByAppendingPathComponent:logFileName];
        
        [[self class]sendLog:logFilePath];
    }
}

//长按第一个功能按钮 可以 发送前天的日志文件
+(void)processLongPress3:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        int currentTime =  [[NSDate date] timeIntervalSince1970];
        int yesterday = currentTime - 60 * 60 * 24 * 2;
        
        NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSince1970:yesterday];
        
        //        找到前一天的日志文件
        NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr=[formatter stringFromDate:yesterdayDate];
        [formatter release];
        
        NSString *logFileName = [NSString stringWithFormat:@"client%@.log",dateStr];
        NSString *logFilePath = [[StringUtil getHomeDir]stringByAppendingPathComponent:logFileName];
        
        [[self class]sendLog:logFilePath];
    }
}

//长按第一个功能按钮 可以 发送eCloud.log
+(void)processLongPress4:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        NSString *logFileName = [NSString stringWithFormat:@"eCloud.log"];
        NSString *logFilePath = [[StringUtil getHomeDir]stringByAppendingPathComponent:logFileName];
        
        [[self class]sendLog:logFilePath];
    }
}

//长按第五个功能按钮 可以 发送异常日志
+(void)processLongPress5:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        NSString *logFilePath = [CrashLogger getCurExpLogFilePath];
        
        [[self class]sendLog:logFilePath];
    }
}

@end
