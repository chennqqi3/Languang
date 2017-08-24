//
//  BizConfVideoSDKSettings.h
//  BizConfSDK
//
//  Created by bizconf on 16/12/26.
//  Copyright © 2016年 bizconf. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BizConfVideoSDKSettings : NSObject

+ (instancetype)shared;


//获取加入会议前麦克风静音状态
- (BOOL)muteAudioWhenJoinMeeting;

//麦克风自动静音
- (void)setMuteAudioWhenJoinMeeting:(BOOL)muted;


@end
