//
//  CollectFileCell.m
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "CollectFileCell.h"
#import "StringUtil.h"

#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)

#define IMGVIEW_X 12
#define IMGVIEW_Y 12
#define IMGVIEW_WIRTH 45
#define IMGVIEW_HEIGHT 45

#define FILENAME_X 67
#define FILENAME_Y 15
#define FILENAME_WIDTH 196
#define FILENAME_HEIGHT 21
#define FILENAME_FONT 15

#define FILESIZE_X 67
#define FILESIZE_Y 42
#define FILESIZE_WIRTH 55
#define FILESIZE_HEIGHT 14
#define FILESIZE_FONT 10

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 144

#define BACKGROUND_X 12
#define BACKGROUND_Y 55
#define BACKGROUND_HEIGHT 69

@implementation CollectFileCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self addCommonView];
        
        UIImageView *backgroup = [[UIImageView alloc] initWithFrame:CGRectMake(BACKGROUND_X, BACKGROUND_Y, KSCREEN_SIZE.width - BACKGROUND_X*2, BACKGROUND_HEIGHT)];
        backgroup.tag = 515;
        backgroup.backgroundColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
        backgroup.layer.cornerRadius = 3;
        backgroup.layer.borderWidth = 0.5;
        backgroup.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
        
        backgroup.image = [StringUtil getImageByResName:@"frameCircle.png"];
        self.fileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(IMGVIEW_X, IMGVIEW_Y, IMGVIEW_WIRTH, IMGVIEW_HEIGHT)];
        self.fileImgView.tag = 525;
        
        self.fileName = [[UILabel alloc] initWithFrame:CGRectMake(FILENAME_X, FILENAME_Y, FILENAME_WIDTH, FILENAME_HEIGHT)];
        self.fileName.tag = 526;
        [self.fileName setFont:[UIFont systemFontOfSize:FILENAME_FONT]];
        
        self.fileSize = [[UILabel alloc] initWithFrame:CGRectMake(FILESIZE_X, FILESIZE_Y, FILESIZE_WIRTH, FILESIZE_HEIGHT)];
        self.fileSize.tag = 527;
        [self.fileSize setFont:[UIFont systemFontOfSize:FILESIZE_FONT]];
        [self.fileSize setTextColor:[UIColor grayColor]];
        
        // 调整editingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
        
        [self addSubview:backgroup];
        [backgroup addSubview:self.fileImgView];
        [backgroup addSubview:self.fileName];
        [backgroup addSubview:self.fileSize];
    }
    
    return self;
}

@end
