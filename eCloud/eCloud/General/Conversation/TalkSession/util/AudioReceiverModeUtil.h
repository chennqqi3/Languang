//
//  AudioReceiverModeUtil.h
//  OpenCtx2017
//
//  Created by shisuping on 17/5/25.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    /** 扬声器模式 */
    audio_receiver_mode_loudspeaker = 0,
    /** 听筒模式 */
    audio_receiver_mode_headphone
}audio_receiver_mode_def;

@interface AudioReceiverModeUtil : NSObject

/** 获取单例 */
+ (AudioReceiverModeUtil *)getUtil;

/** 获取音频播放模式 */
- (int)getAudioReceiverMode;

/** 获取当前音频播放模式提示 */
- (NSString *)getAudioReceiverTips;

/** 返回弹出菜单的内容 */
- (NSString *)getPopMenuText;

/** 切换语音播放模式 */
- (void)changeAudioMode;

@end
