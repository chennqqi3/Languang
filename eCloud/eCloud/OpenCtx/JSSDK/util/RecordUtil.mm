//
//  RecordUtil.m
//  eCloud
//  录音 接口
//  Created by shisuping on 16/3/21.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "RecordUtil.h"
#import "JSONKit.h"

#import "DownloadFileObject.h"
#import "DownloadFileUtil.h"

#import "UploadFileObject.h"
#import "UploadFileUtil.h"

#import "ASIFormDataRequest.h"
#import "eCloudUser.h"
#import "FileAssistantConn.h"
#import "conn.h"
#import "UploadFileModel.h"
#import "LogUtil.h"
#import "UserDefaults.h"
#import <AVFoundation/AVFoundation.h>
#import "UserTipsUtil.h"
#import "StringUtil.h"



#import "AudioPlayForIOS6.h"

#import "CL_VoiceEngine.h"
#import "amrToWavMothod.h"
#import "VoiceConverter.h"

static RecordUtil *recordUtil;

@interface RecordUtil () <UploadFileDelegate,DownloadFileDelegate>

@property (nonatomic,retain) NSString *curAudioName;
@property (nonatomic,retain) NSString *curAudioNameOfAmr;

@property (nonatomic,assign) int secondValue;

@property (nonatomic,retain) NSString *recordToken;

@end

@implementation RecordUtil
{
    BOOL canRecord;
    
    CL_AudioRecorder *audioRecoder;
    
    NSOperationQueue *recordQueue;

    NSTimer *secondTimer;
    
    //    播放语音
    AudioPlayForIOS6 *audioplayios6;
    
    amrToWavMothod *amrtowav;

    UploadFileUtil *uploadFileUtil;
    
    DownloadFileUtil *downloadFileUtil;
}

@synthesize delegate;
@synthesize curAudioNameOfAmr;
@synthesize curAudioName;
@synthesize secondValue;
@synthesize recordToken;

- (id)init
{
    self = [super init];
    if (self) {
        recordQueue = [[NSOperationQueue alloc]init];
        
//        播放录音 初始化
        audioplayios6 = [[AudioPlayForIOS6 alloc]init];
        
        //    录音初始化
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        //        检测 用户是插着耳机 还是 拔出了 耳机
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                         audioRouteChangeListenerCallback,
                                         self);
        
        audioRecoder = [[CL_AudioRecorder alloc]init];
        
//        语音停止播放通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];

        self.curAudioName = [UserDefaults getCurrentRecordName];
    }
    return self;
}

+ (RecordUtil *)getUtil
{
    if (!recordUtil) {
        recordUtil = [[super alloc]init];
    }
    return recordUtil;
}

//检查 是否有录音权限，如果有开始luy
- (BOOL)startRecord
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession  performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                //                可以录音
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startRecording];
                });
            }else {
                //                没有录音权限
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"chats_talksession_record_hint"]];
                });
            }
        }];
    }
    else{
        //        可以录音
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startRecording];
        });
    }
    return YES;
}

//新增的方法，开始录音 by shisp
- (BOOL)startRecording
{
    if (audioRecoder.audioRecorder.isRecording) {
        [UserTipsUtil showAlert:@"正在录音"];
        return NO;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    
    //            设置 category
    if ([audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
    {
        //                激活
        if ([audioSession setActive:YES error:&error])
        {
            //        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        }
        else
        {
            NSLog(@"Failed to set audio session category: %@", error);
            [UserTipsUtil showAlert:@"Failed to setActive"];
            return NO;
        }
    }
    else
    {
        NSLog(@"Failed to set audio session category: %@", error);
        [UserTipsUtil showAlert:@"Failed to setCategory"];
        return NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willStartRecord)]) {
        [self.delegate performSelector:@selector(willStartRecord)];
    }

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride),&audioRouteOverride);
    
    
    NSString *nowTime = [StringUtil currentTime];
    
#if  TARGET_IPHONE_SIMULATOR
    self.curAudioName =[NSString stringWithFormat:@"%@.caf",nowTime];
#else
    self.curAudioName =[NSString stringWithFormat:@"%@.wav",nowTime];
#endif
    
    NSLog(@"%s,开始录音,name is %@",__FUNCTION__,self.curAudioName);
    
//    保存这次录音的名字
    [UserDefaults saveCurrentRecordName:self.curAudioName];
    
    //        设置 录音文件 保存的路径
    NSString *recordAudioFullPath = [self getCurRecordPath];
    audioRecoder.recorderingPath = recordAudioFullPath;
    [audioRecoder startRecord];
    //         [VoiceConverter changeStu];
    
    //    wav 转为 amr
    [VoiceConverter setRecordStatus:YES];
    
    //    //启动计时器 wav转为amr，是从wav里读，再向amr文件里写
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(wavToAmrBtnPressed) object:nil];
    [recordQueue addOperation:operation];
    [operation release];
    
    self.secondValue = 0;
    //    updateTimeLabel.text=[NSString stringWithFormat:@"0秒"];
    //        第一次0.5s后，secondValue就可以+1
    secondTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showSecond) userInfo:nil repeats:NO];
    
    return YES;
}

- (void)showSecond
{
    self.secondValue++;
    
    if (self.secondValue == 1) {
        //        如果已经是1s了，那么开启一个循环的timer,间隔是1s
        secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showSecond) userInfo:nil repeats:YES];
    }
    
    NSLog(@"%s second is %d",__FUNCTION__,self.secondValue);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordTime:)]) {
        [self.delegate performSelector:@selector(recordTime:) withObject:[NSNumber numberWithInt:self.secondValue]];
    }
}

- (BOOL)stopRecord
{
    if (![self isRecording]) {
        return NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willStopRecord)] ) {
        [self.delegate performSelector:@selector(willStopRecord)];
    }
    
    dispatch_queue_t stopQueue = dispatch_queue_create("stopQueue", NULL);
    dispatch_async(stopQueue, ^(void){
        //run in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [audioRecoder stopRecord];
            //            [VoiceConverter changeStu];
            [VoiceConverter setRecordStatus:NO];
            
            if (secondTimer!=nil) {
                [secondTimer invalidate];
                secondTimer=nil;
            }
        });
    });
    dispatch_release(stopQueue);
    return YES;
}

- (BOOL)playVoice
{
    NSString *recordPath = [self getCurRecordPath];
    BOOL isExist = [[NSFileManager defaultManager]fileExistsAtPath:recordPath];
    if (!isExist)
    {
        [UserTipsUtil showAlert:@"录音文件不存在"];
        return NO;
    }
    
    //是否插入耳机播放
    BOOL Headset=[self hasHeadset];
    if (Headset) {

    }else
    {
//        扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPlayVoice)]) {
        [self.delegate performSelector:@selector(willPlayVoice)];
    }
    
    [self addSensorMoniter];
    

    NSRange range = [recordPath rangeOfString:@".amr"];
    
    if (range.length > 0)
    {//需要转换
        NSString * docFilePath        = [[StringUtil getHomeDir] stringByAppendingPathComponent:@"amrAudio.wav"];
        if (amrtowav == nil) {
            amrtowav = [[amrToWavMothod alloc] init];
        }
        
        [amrtowav startAMRtoWAV:recordPath tofile:docFilePath];
        
        [audioplayios6 playAudioSupportResume:docFilePath];
    }else{
        [audioplayios6 playAudioSupportResume:recordPath];
    }
    
    return YES;
}

//停止播放语音
- (BOOL)stopVoice
{
    [self removeSensorMoniter];
    
    [audioplayios6 stopPlayAudio];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willStopVoice)]) {
        [self.delegate performSelector
            :@selector(willStopVoice)];
    }
    [[AVAudioSession sharedInstance] setActive:NO error:nil];

    return YES;
}

- (BOOL)pauseVoice
{
    [audioplayios6 pausePlayAudio];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPauseVoice)]) {
        [self.delegate performSelector
         :@selector(willPauseVoice)];
    }
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    return YES;
}


//上传语音
- (BOOL)uploadVoice
{
    NSString *filePath = [self getCurRecordPathOfAmr];
    BOOL isExist = [[NSFileManager defaultManager]fileExistsAtPath:filePath];
    if (!isExist) {
        [UserTipsUtil showAlert:@"请先录音"];
        return NO;
    }
    if (!uploadFileUtil) {
        uploadFileUtil = [[UploadFileUtil alloc]init];
        uploadFileUtil.delegate = self;
    }
    
    UploadFileObject *uploadFileObject = [[[UploadFileObject alloc]init]autorelease];
    uploadFileObject.uploadFilePath = filePath;
    uploadFileObject.uploadFileType = type_upload_file;
    
    [uploadFileUtil upload:[NSArray arrayWithObjects:uploadFileObject, nil]];
    
    return YES;
}

- (BOOL)downloadVoice
{
    if (!self.recordToken) {
        [UserTipsUtil showAlert:@"没有token"];
        return NO;
    }
    DownloadFileObject *downloadFileObject = [[DownloadFileObject alloc]init];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],self.recordToken,[StringUtil getResumeDownloadAddStr]];
    downloadFileObject.downloadUrl = urlStr;
    
    NSString *fileName = [NSString stringWithFormat:@"%@.amr",self.recordToken];
    NSString *pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
    downloadFileObject.downloadFilePath = pathStr;

    if (!downloadFileUtil) {
        downloadFileUtil = [[DownloadFileUtil alloc]init];
        downloadFileUtil.delegate = self;
    }
    
    [downloadFileUtil downloadFile:[NSArray arrayWithObjects:downloadFileObject,nil]];
    
    return YES;
}

//下载语音
- (BOOL)downloadVoice:(NSString *)tokenStr
{
    if (!tokenStr) {
        return NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil showLoadingView:@"下载中..."];
    });
    
    dispatch_queue_t queue = dispatch_queue_create("download record ...", NULL);
    dispatch_async(queue, ^{
        NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],tokenStr,[StringUtil getResumeDownloadAddStr]];
        
        //    保存路径
        NSString *fileName = [NSString stringWithFormat:@"%@.amr",tokenStr];
        NSString *pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
        NSString *tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",fileName]];
        
        NSURL *downloadUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:downloadUrl];
        // 添加请求头
        [request addRequestHeader:DOWNLOAD_FROM_FILESERVER_ADD_HEADER_KEY_NAME value:DOWNLOAD_FROM_FILESERVER_ADD_HEADER_KEY_VALUE];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,urlStr]];
        
        [request setDelegate:self];
        
        [request setDownloadDestinationPath:pathStr];
        
        //设置文件缓存路径
        [request setTemporaryFileDownloadPath:tempPath];
        
        [request setDidFinishSelector:@selector(downloadFileComplete:)];
        [request setDidFailSelector:@selector(downloadFileFail:)];
        [request setAllowResumeForFileDownloads:YES];
        
        //传参数，文件传输完成后，根据参数进行不同的处理
        //    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:msgId],@"MSG_ID",nil]];
        
        [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
        [request setNumberOfTimesToRetryOnTimeout:3];
        request.shouldContinueWhenAppEntersBackground = YES;
        
        [request startAsynchronous];
        
        [request release];
    });
    
    dispatch_release(queue);
        
  return YES;
}

#pragma mark 红外线感应 手机是否放到了耳朵旁边
//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
//        听筒模式
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
//        扬声器模式
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark 语音播放完毕时回调的方法
- (void)playbackQueueStopped:(NSNotification *)note
{
    [self stopVoice];
}

#pragma mark 当拔掉耳机时 声音就会外放
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueS,
                                       const void                *inPropertyValue
                                       ) {
    
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    // Determines the reason for the route change, to ensure that it is not
    //      because of a category change.
//    取出 dic参数
    CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
//    取出原因
    CFNumberRef routeChangeReasonRef =
    (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
//        切换为扬声器模式
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        NSLog(@"－－－－拨出耳机");
    }
}

#pragma mark 监测是否插入耳机
- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
}

#pragma mark ===增加近距离传感器监听====
- (void)addSensorMoniter
{
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
}

#pragma mark ===删除近距离传感器监听====
- (void)removeSensorMoniter
{
    //删除近距离事件监听
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark ===启动wav转amr====
- (void)wavToAmrBtnPressed{
    NSString *recordPath = [self getCurRecordPath];
    NSString *amrPath = [self getCurRecordPathOfAmr];
    int success=[VoiceConverter wavToAmr:recordPath amrSavePath:amrPath];
}

#pragma mark ========
- (NSString *)getCurRecordPath
{
    //    如果为空 那么取上一次的；如果还未取到，那么返回nil
    if (!self.curAudioName) {
        return nil;
    }
    NSString *recordPath = [kRecorderDirectory stringByAppendingPathComponent:self.curAudioName];
    [LogUtil debug:[NSString stringWithFormat:@"%s recordPath is %@",__FUNCTION__,recordPath]];
    return recordPath;
}

//根据wav文件的名字得到amr录音文件的名字
- (NSString *)getAmrRecordNameByWavRecordName:(NSString *)wavRecordName
{
    if (!wavRecordName) {
        return nil;
    }
    NSRange range = [wavRecordName rangeOfString:@"." options:NSBackwardsSearch];
    NSString *nowTime = [wavRecordName substringToIndex:range.location];
    NSString *amrName=[NSString stringWithFormat:@"%@.amr",nowTime];
    return amrName;
}
//获取 录音 对应的 amr文件 的名字
- (NSString *)getCurRecordPathOfAmr
{
    NSString *amrName = [self getAmrRecordNameByWavRecordName:self.curAudioName];
    if (amrName) {
        NSString *amrPath = [kRecorderDirectory stringByAppendingPathComponent:amrName];
        return amrPath;
    }
    return nil;
}

#pragma mark 判断是否已经在录音
- (BOOL)isRecording
{
    if (!audioRecoder) return NO;
    if (!audioRecoder.audioRecorder.isRecording) return NO;
    return YES;
}

#pragma mark -- 下载成功
- (void)downloadFileComplete:(ASIHTTPRequest *)request{
    
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil hideLoadingView];
        
        if (statuscode == 200) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0)
            {
                //            下载成功
                [UserTipsUtil showAlert:[NSString stringWithFormat:@"下载成功 路径:%@",request.downloadDestinationPath]];
            }else{
                //            下载失败
                [UserTipsUtil showAlert:[NSString stringWithFormat:@"下载失败 空文件"]];
            }
        }else{
            //下载失败
            [UserTipsUtil showAlert:[NSString stringWithFormat:@"下载失败 statuscode is %d",statuscode]];
        }
    });
}
#pragma mark -- 下载失败
-(void)downloadFileFail:(ASIHTTPRequest*)request{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil hideLoadingView];
        //        下载失败
        [UserTipsUtil showAlert:[NSString stringWithFormat:@"下载失败 %@",[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    });

}
#pragma mark upload file delegate

- (void)uploadFinish:(UploadFileUtil *)uploadFileUtil andResult:(NSArray *)uploadFinishArray
{
    if (uploadFinishArray.count) {
        UploadFileObject *uploadFileObject = uploadFinishArray[0];
        NSString *fileToken = [uploadFileObject getFileToken];
        if (fileToken) {
            self.recordToken = fileToken;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadFinished:)]) {
        [self.delegate uploadFinished:uploadFinishArray];
    }
}
@end
