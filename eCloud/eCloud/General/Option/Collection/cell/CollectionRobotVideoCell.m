//
//  CollectionRobotVideoCell.m
//  OpenCtx
//
//  Created by Alex L on 16/3/9.
//  Copyright © 2016年 mimsg. All rights reserved.
//

#import "CollectionRobotVideoCell.h"

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 105

@implementation CollectionRobotVideoCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self addCommonView];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(12, 42, [UIScreen mainScreen].bounds.size.width - 57, 70)];
        contentView.tag = 535;
        [self addSubview:contentView];
        
        self.typeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 10, 45, 45)];
        [contentView addSubview:self.typeImgView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, [UIScreen mainScreen].bounds.size.width - 110, 50)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:13]];
        self.titleLabel.numberOfLines = 0;
        [contentView addSubview:self.titleLabel];
        
        self.fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 40, 100, 25)];
        [self.fileSizeLabel setFont:[UIFont systemFontOfSize:12]];
        [contentView addSubview:self.fileSizeLabel];
        
        // 调整edtingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    
    return self;
}

@end
