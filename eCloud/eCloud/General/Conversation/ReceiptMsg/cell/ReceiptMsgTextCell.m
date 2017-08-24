//
//  ReceiptMsgTextCell.m
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgTextCell.h"

#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)

#define TIME_LABEL_X 20
#define TIME_LABEL_Y 10
#define TIME_LABEL_WIDTH 70
#define TIME_LABEL_HEIGHT 20

#define UNREAD_COUNTS_Y 10
#define UNREAD_COUNTS_WIDTH 70
#define UNREAD_COUNTS_HEIGHT 20

#define TEXT_MSG_LABEL_X 20
#define TEXT_MSG_LABEL_Y 30
#define TEXT_MSG_LABEL_HEIGHT 45


#define TIME_LABEL_FONT 11
#define UNREAD_COUNTS_FONT 11
#define TEXT_MSG_FONT 17

@implementation ReceiptMsgTextCell

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
        
        self.textMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_MSG_LABEL_X, TEXT_MSG_LABEL_Y, KSCREEN_SIZE.width - 20*2, TEXT_MSG_LABEL_HEIGHT)];
        [self.textMsgLabel setFont:[UIFont systemFontOfSize:TEXT_MSG_FONT]];
        self.textMsgLabel.numberOfLines = 0;
        
        [self addSubview:self.timeLabel];
        [self addSubview:self.unreadCounts];
        [self addSubview:self.textMsgLabel];
    }
    return self;
}

@end
