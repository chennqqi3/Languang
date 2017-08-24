//
//  VoiceCell.h
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionParentCell.h"

@interface VoiceCell : CollectionParentCell

@property (nonatomic, strong) UIImageView *audio_play;
@property (nonatomic, strong) UILabel *audio_time;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, assign) CGFloat voiceLength;
@property (nonatomic,strong) UIView *greenBackground;
@end
