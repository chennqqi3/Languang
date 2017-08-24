//
//  AudioUtil.m
//  eCloud
//
//  Created by Alex L on 16/4/8.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "AudioUtil.h"

@implementation AudioUtil

+ (void)initialize
{
    // 音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // 设置会话类型（播放类型、播放模式,会自动停止其他音乐的播放）
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 激活会话
    [session setActive:YES error:nil];
}

/**
 *  存放所有的音效ID
 */
static NSMutableDictionary *_soundIDs;
+ (NSMutableDictionary *)soundIDs
{
    if (!_soundIDs) {
        _soundIDs = [NSMutableDictionary dictionary];
    }
    return _soundIDs;
}

/**
 *  存放所有的音乐播放器
 */
static NSMutableDictionary *_musicPlayers;
+ (NSMutableDictionary *)musicPlayers
{
    if (!_musicPlayers) {
        _musicPlayers = [NSMutableDictionary dictionary];
    }
    return _musicPlayers;
}

/**
 *  播放音乐
 *
 *  @param filename 音乐的文件名
 */
+ (AVAudioPlayer *)playMusic:(NSString *)filename
{
    if (!filename) return nil;
    
    // 1.取出对应的播放器
    AVAudioPlayer *player = [self musicPlayers][filename];
    
    // 2.播放器没有创建，进行初始化
    if (!player) {
        // 音频文件的URL
        NSURL *url = [NSURL fileURLWithPath:filename];
        if (!url) return nil;
        
        // 创建播放器(一个AVAudioPlayer只能播放一个URL)
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        //        player.enableRate = YES;
        //        player.rate = 5.0;
        
        // 缓冲
        if (![player prepareToPlay]) return nil;
        
        // 存入字典
        [self musicPlayers][filename] = player;
    }
    
    // 3.播放
    if (!player.isPlaying) {
        [player play];
    }
    
    // 正在播放
    return player;
}

/**
 *  暂停音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)pauseMusic:(NSString *)filename
{
    if (!filename) return;
    
    // 1.取出对应的播放器
    AVAudioPlayer *player = [self musicPlayers][filename];
    
    // 2.暂停
    if (player.isPlaying) {
        [player pause];
    }
}

/**
 *  停止音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)stopMusic:(NSString *)filename
{
    if (!filename) return;
    
    // 1.取出对应的播放器
    AVAudioPlayer *player = [self musicPlayers][filename];
    
    // 2.停止
    [player stop];
    
    // 3.将播放器从字典中移除
    [[self musicPlayers] removeObjectForKey:filename];
}

/**
 *  播放音效
 *
 *  @param filename 音效的文件名
 */
+ (void)playSound:(NSString *)filename
{
    if (!filename) return;
    
    // 1.取出对应的音效ID
    SystemSoundID soundID = [[self soundIDs][filename] unsignedLongValue];
    
    // 2.初始化
    if (!soundID) {
        // 音频文件的URL
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (!url) return;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        
        // 存入字典
        [self soundIDs][filename] = @(soundID);
    }
    
    // 3.播放
    AudioServicesPlaySystemSound(soundID);
}

/**
 *  销毁音效
 *
 *  @param filename 音效的文件名
 */
+ (void)disposeSound:(NSString *)filename
{
    if (!filename) return;
    
    // 1.取出对应的音效ID
    SystemSoundID soundID = [[self soundIDs][filename] unsignedLongValue];
    
    // 2.销毁
    if (soundID) {
        AudioServicesDisposeSystemSoundID(soundID);
        
        [[self soundIDs] removeObjectForKey:filename];
    }
}


//获取音频长度
+ (NSTimeInterval)getAudioDuration:(NSString *)filePath
{
    NSURL *audioFileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:audioFileURL options:nil];
    
    CMTime audioDuration = audioAsset.duration;
    
    return CMTimeGetSeconds(audioDuration);
}
@end
