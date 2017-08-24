//
//  AudioUtil.h
//  eCloud
//  和播放mp3等音乐文件相关的工具类
//  Created by Alex L on 16/4/8.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioUtil : NSObject

/**
 *  播放音乐
 *
 *  @param filename 音乐的文件名
 */
+ (AVAudioPlayer *)playMusic:(NSString *)filename;
/**
 *  暂停音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)pauseMusic:(NSString *)filename;
/**
 *  停止音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)stopMusic:(NSString *)filename;

/**
 *  播放音效
 *
 *  @param filename 音效的文件名
 */
+ (void)playSound:(NSString *)filename;
/**
 *  销毁音效
 *
 *  @param filename 音效的文件名
 */
+ (void)disposeSound:(NSString *)filename;


//获取音频长度
+ (NSTimeInterval)getAudioDuration:(NSString *)filePath;

@end
