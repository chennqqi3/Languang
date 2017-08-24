//
//  AudioPlayForIOS6.m
//  eCloud
//
//  Created by  lyong on 12-12-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "AudioPlayForIOS6.h"

@implementation AudioPlayForIOS6
@synthesize player;
@synthesize autogif;
- (void)playAudio:(NSString *)audiopath
{
    
    if (player==nil) {
        player = new AQPlayer();
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
    }
    //    NSBundle *myBundle = [NSBundle mainBundle];
    //    NSString *path=[myBundle pathForAuxiliaryExecutable:@"y2QJvy.aac"];
    //    NSLog(@"---path----%@",path);
    // dispose the previous playback queue
    player->DisposeQueue(true);
    CFStringRef pathstr=(CFStringRef)audiopath;
    player->CreateQueueForFile(pathstr);
    
    if (player->IsRunning())
    {
        OSStatus result =player->StopQueue();
        if (result == noErr)
            [autogif stopAnimating];
        
        result = player->StartQueue(false);
        if (result == noErr)
            [autogif startAnimating];
        
    }
    else
    {
        OSStatus result = player->StartQueue(false);
        if (result == noErr)
            [autogif startAnimating];
        
    }
}

-(void)setAutoGif:(UIImageView *)viewgif
{
    autogif=viewgif;
}
# pragma mark Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
	  [autogif stopAnimating];
}
-(bool)stopPlayAudio
{
    if (player&&player->IsRunning())
	{
        OSStatus result =player->StopQueue();
        if (result == noErr)
            [autogif stopAnimating];
        return true;//表示还在播放录音中，但是中途停止了
	}
    return false;
}

//add by shisp 暂停
- (bool)pausePlayAudio
{
    if (player&&player->IsRunning())
    {
        OSStatus result =player->PauseQueue();
        if (result == noErr)
            [autogif stopAnimating];
        return true;//表示还在播放录音中，但是中途停止了
    }
    return false;
}

//新的支持 语音暂停后 可以继续播放的方法
- (void)playAudioSupportResume:(NSString *)audiopath
{
    if (player==nil) {
        player = new AQPlayer();
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
    }
    //    NSBundle *myBundle = [NSBundle mainBundle];
    //    NSString *path=[myBundle pathForAuxiliaryExecutable:@"y2QJvy.aac"];
    //    NSLog(@"---path----%@",path);
    // dispose the previous playback queue
    CFStringRef pathstr=(CFStringRef)audiopath;
    CFStringRef oldPathStr = player->GetFilePath();
    
    if (CFEqual(pathstr, oldPathStr) && player->IsRunning()) {
        //        如果这次路径和上次路径，并且录音还未播放完成，那么可以继续播放
        //        继续播放录音
        OSStatus result = player->StartQueue(true);
        if (result == noErr)
            [autogif startAnimating];

    }else{
        //        否则重新开始播放
        player->DisposeQueue(true);
        player->CreateQueueForFile(pathstr);
        
        OSStatus result = player->StartQueue(false);
        if (result == noErr)
            [autogif startAnimating];
    }
}
@end
