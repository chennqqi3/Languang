//
//  ReceiptMsgRecordCell.m
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgRecordCell.h"

#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)

#define TIME_LABEL_X 20
#define TIME_LABEL_Y 10
#define TIME_LABEL_WIDTH 70
#define TIME_LABEL_HEIGHT 20

#define UNREAD_COUNTS_Y 10
#define UNREAD_COUNTS_WIDTH 70
#define UNREAD_COUNTS_HEIGHT 20

#define TIME_LABEL_FONT 11
#define UNREAD_COUNTS_FONT 11

#define PLAY_BUTTON_X 20
#define PLAY_BUTTON_Y 35
#define PLAY_BUTTON_HEIGHT 40

#define RECORD_IMAGE_X 10
#define RECORD_IMAGE_Y 10
#define RECORD_IMAGE_WIDTH 40
#define RECORD_IMAGE_HEIGHT 40

#define DURATION_LABEL_X 50
#define DURATION_LABEL_Y 20
#define DURATION_LABEL_WIDTH 50
#define DURATION_LABEL_HEIGHT 20


@implementation ReceiptMsgRecordCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TIME_LABEL_X, TIME_LABEL_Y, TIME_LABEL_WIDTH, TIME_LABEL_HEIGHT)];
        [self.timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
        
        self.unreadCounts = [[UILabel alloc] initWithFrame:CGRectMake(KSCREEN_SIZE.width - UNREAD_COUNTS_WIDTH - 10, UNREAD_COUNTS_Y, UNREAD_COUNTS_WIDTH, UNREAD_COUNTS_HEIGHT)];
        [self.unreadCounts setFont:[UIFont systemFontOfSize:UNREAD_COUNTS_FONT]];
        self.unreadCounts.textAlignment = NSTextAlignmentRight;
        
        self.playOrPauseBtn = [[UILabel alloc] initWithFrame:CGRectMake(PLAY_BUTTON_X, PLAY_BUTTON_Y, KSCREEN_SIZE.width - 20*2, PLAY_BUTTON_HEIGHT)];
        UIImageView *recordImg = [[UIImageView alloc] initWithFrame:CGRectMake(RECORD_IMAGE_X, RECORD_IMAGE_Y, RECORD_IMAGE_WIDTH, RECORD_IMAGE_HEIGHT)];
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(DURATION_LABEL_X, DURATION_LABEL_Y, DURATION_LABEL_WIDTH, DURATION_LABEL_HEIGHT)];
        [self.playOrPauseBtn addSubview:recordImg];
        [self.playOrPauseBtn addSubview:self.durationLabel];
        
        [self addSubview:self.playOrPauseBtn];
        [self addSubview:self.timeLabel];
        [self addSubview:self.unreadCounts];
    }
    return self;
}

@end
