//
//  AudioPlayForIOS6.h
//  eCloud
//
//  Created by  lyong on 12-12-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQPlayer.h"

@interface AudioPlayForIOS6 : NSObject
{
     AQPlayer*	player;
     BOOL playbackWasPaused;
    UIImageView *autogif;
}
@property (readonly)AQPlayer *player;
@property (nonatomic, retain) UIImageView *autogif;
-(void)setAutoGif:(UIImageView *)viewgif;
- (void)playAudio:(NSString *)audiopath;
-(bool)stopPlayAudio;
//add by shisp 暂停
- (bool)pausePlayAudio;

//新的支持 语音暂停后 可以继续播放的方法
- (void)playAudioSupportResume:(NSString *)audiopath;

@end
