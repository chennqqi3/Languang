//
//  VideoCell.m
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "VideoCellARC.h"
#import "StringUtil.h"

#define PICTURECELL_PICTURE_X 12
#define PICTURECELL_PICTURE_Y 55
#define PICTURECELL_PICTURE_WIDTH 160
#define PICTURECELL_PICTURE_HEIGHT 90

#define PLAYIMAGE_X 60
#define PLAYIMAGE_Y 25
#define PLAYIMAGE_WIDTH 40
#define PLAYIMAGE_HEIGHT 40

#define durationLabel_X 120
#define DURATIONLABEL_Y 72
#define DURATIONLABEL_WIDTH 34
#define DURATIONLABEL_HEIGHT 14
#define DURATIONLABEL_FONT 10

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 165

@implementation VideoCellARC

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addCommonView];
        
        self.picture = [[UIImageView alloc] init];
        self.picture.tag = 105;
        self.picture.frame = CGRectMake(PICTURECELL_PICTURE_X, PICTURECELL_PICTURE_Y, PICTURECELL_PICTURE_WIDTH, PICTURECELL_PICTURE_HEIGHT);
        self.picture.layer.cornerRadius = 3;
        self.picture.clipsToBounds = YES;
        [self addSubview:self.picture];
        
        UIImageView *playImgView = [[UIImageView alloc]initWithFrame:CGRectMake(PLAYIMAGE_X, PLAYIMAGE_Y, PLAYIMAGE_WIDTH, PLAYIMAGE_HEIGHT)];
        playImgView.image = [StringUtil getImageByResName:@"message_video_play@2x.png"];
        [self.picture addSubview:playImgView];
        
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(durationLabel_X, DURATIONLABEL_Y, DURATIONLABEL_WIDTH, DURATIONLABEL_HEIGHT)];
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.textAlignment = NSTextAlignmentCenter;
        [self.durationLabel setFont:[UIFont systemFontOfSize:DURATIONLABEL_FONT]];
        self.durationLabel.tag = 535;
        [self.picture addSubview:self.durationLabel];
        
        // 调整edtingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    return self;
}

@end
