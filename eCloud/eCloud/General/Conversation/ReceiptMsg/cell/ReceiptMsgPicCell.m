//
//  ReceiptMsgPicCell.m
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgPicCell.h"

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

#define PICTURE_X 20
#define PICTURE_Y 30
#define PICTURE_WIDTH 160

@implementation ReceiptMsgPicCell

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
        
        self.unreadCounts = [[UILabel alloc] initWithFrame:CGRectMake(KSCREEN_SIZE.width - UNREAD_COUNTS_WIDTH - 20, UNREAD_COUNTS_Y, UNREAD_COUNTS_WIDTH, UNREAD_COUNTS_HEIGHT)];
        [self.unreadCounts setFont:[UIFont systemFontOfSize:UNREAD_COUNTS_FONT]];
        self.unreadCounts.textAlignment = NSTextAlignmentRight;
        
        self.picture = [[UIImageView alloc] initWithFrame:CGRectMake(PICTURE_X, PICTURE_Y, PICTURE_WIDTH, 150 - PICTURE_Y -10)];
        
        [self addSubview:self.timeLabel];
        [self addSubview:self.unreadCounts];
        [self addSubview:self.picture];
    }
    return self;
}

@end
