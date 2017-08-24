//
//  AudioReceiverModeUtil.m
//  OpenCtx2017
//
//  Created by shisuping on 17/5/25.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "AudioReceiverModeUtil.h"
#import "eCloudUser.h"
#import "conn.h"
#import "UserInfo.h"
#import "StringUtil.h"
#import "LogUtil.h"

static AudioReceiverModeUtil *audioUtil;

@implementation AudioReceiverModeUtil

+ (AudioReceiverModeUtil *)getUtil{
    if (!audioUtil) {
        audioUtil = [[super alloc]init];
    }
    return audioUtil;
}

/** 获取音频播放模式 */
- (int)getAudioReceiverMode{
    UserInfo *userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:[conn getConn].userId];
    return userinfo.receiver_model_Flag;
}

/** 获取当前音频播放模式提示 */
- (NSString *)getAudioReceiverTips{
    int temp = [self getAudioReceiverMode];
    if (temp == audio_receiver_mode_headphone) {
        return [StringUtil getLocalizableString:@"handset_model"];
    }else{
        return [StringUtil getLocalizableString:@"cur_audio_receiver_mode_loudspeaker"];
    }
}

/** 获取语音提示菜单名称 */
- (NSString *)getPopMenuText{
    int temp = [self getAudioReceiverMode];
    if (temp == audio_receiver_mode_headphone) {
        return [StringUtil getLocalizableString:@"menu_loudspeaker"];
    }else{
        return [StringUtil getLocalizableString:@"menu_headphone"];
    }
}
/** 切换语音播放模式 */
- (void)changeAudioMode{
    int temp = [self getAudioReceiverMode];
    if (temp == audio_receiver_mode_headphone) {
        [[eCloudUser getDatabase] updateReceiverModeState:audio_receiver_mode_loudspeaker :[[conn getConn].userId intValue]];
    }else{
        [[eCloudUser getDatabase] updateReceiverModeState:audio_receiver_mode_headphone :[[conn getConn].userId intValue]];
    }
}

@end
