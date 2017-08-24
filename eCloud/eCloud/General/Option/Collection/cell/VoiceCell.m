//
//  VoiceCell.m
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "VoiceCell.h"
#import "StringUtil.h"
#import "UIImageOfCrop.h"

#define AUDIO_PLAY_X 12.5
#define AUDIO_PLAY_Y 9.5
#define AUDIO_PLAY_WIRTH 15
#define AUDIO_PLAY_HEIGHT 18

#define AUDIO_TIME_X 42
#define AUDIO_TIME_Y 11.5
#define AUDIO_TIME_WIRTH 20
#define AUDIO_TIME_HEIGHT 14
#define AUDIO_TIME_FONT 10

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 112

#define VOICE_ORG_X 12
#define VOICE_WIDTH 63
#define VOICE_ORG_Y 55
#define VOICE_HEIGHT 37


@implementation VoiceCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self addCommonView];
        

        
       
        self.greenBackground = [[UIView alloc] initWithFrame:CGRectMake(VOICE_ORG_X, VOICE_ORG_Y, VOICE_WIDTH + VOICE_WIDTH/15*(self.voiceLength-1), VOICE_HEIGHT)];
        self.greenBackground.layer.cornerRadius = 4;
        self.greenBackground.layer.masksToBounds = YES;
        self.greenBackground.layer.borderWidth = 0.5;
        self.greenBackground.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
        self.greenBackground.tag = 115;
        self.greenBackground.backgroundColor =  [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
        [self addSubview:self.greenBackground];
        
        self.audio_play = [[UIImageView alloc] initWithFrame:CGRectMake(AUDIO_PLAY_X, AUDIO_PLAY_Y, AUDIO_PLAY_WIRTH, AUDIO_PLAY_HEIGHT)];
        
        self.audio_play.image = [StringUtil getImageByResName:@"voice_rcv_default.png"];
        
        self.audio_time = [[UILabel alloc] initWithFrame:CGRectMake(AUDIO_TIME_X, AUDIO_TIME_Y, AUDIO_TIME_WIRTH, AUDIO_TIME_HEIGHT)];
        self.audio_time.textAlignment = NSTextAlignmentLeft;
        self.audio_time.font = [UIFont systemFontOfSize:AUDIO_TIME_FONT];
        [self.greenBackground addSubview:self.audio_play];
        [self.greenBackground addSubview:self.audio_time];
        
        
        // 调整edtingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    
    return self;
}

@end
