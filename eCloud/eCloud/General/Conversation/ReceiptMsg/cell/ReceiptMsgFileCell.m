//
//  ReceiptMsgFileCell.m
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgFileCell.h"

@implementation ReceiptMsgFileCell

#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)

#define TIME_LABEL_X 20
#define TIME_LABEL_Y 10
#define TIME_LABEL_WIDTH 70
#define TIME_LABEL_HEIGHT 20

#define UNREAD_COUNTS_Y 10
#define UNREAD_COUNTS_WIDTH 70
#define UNREAD_COUNTS_HEIGHT 20

#define IMGVIEW_X 20
#define IMGVIEW_Y 35
#define IMGVIEW_WIRTH 43
#define IMGVIEW_HEIGHT 43

#define FILENAME_X 68
#define FILENAME_Y 35
#define FILENAME_HEIGHT 20

#define FILESIZE_X 68
#define FILESIZE_Y 60
#define FILESIZE_WIRTH 70
#define FILESIZE_HEIGHT 20

#define TIME_LABEL_FONT 11
#define UNREAD_COUNTS_FONT 11

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
        
        self.fileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(IMGVIEW_X, IMGVIEW_Y, IMGVIEW_WIRTH, IMGVIEW_HEIGHT)];
        self.fileName = [[UILabel alloc] initWithFrame:CGRectMake(FILENAME_X, FILENAME_Y, KSCREEN_SIZE.width - FILENAME_X - 2, FILENAME_HEIGHT)];
        [self.fileName setFont:[UIFont systemFontOfSize:13]];
        self.fileSize = [[UILabel alloc] initWithFrame:CGRectMake(FILESIZE_X, FILESIZE_Y, FILESIZE_WIRTH, FILESIZE_HEIGHT)];
        [self.fileSize setFont:[UIFont systemFontOfSize:12]];
        [self.fileSize setTextColor:[UIColor grayColor]];
        
        [self addSubview:self.timeLabel];
        [self addSubview:self.unreadCounts];
        
        [self addSubview:self.fileImgView];
        [self addSubview:self.fileName];
        [self addSubview:self.fileSize];
    }
    return self;
}

@end
