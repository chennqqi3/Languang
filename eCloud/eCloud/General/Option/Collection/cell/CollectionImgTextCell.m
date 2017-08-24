//
//  CollectionImgTextCell.m
//  OpenCtx
//
//  Created by Alex L on 16/3/9.
//  Copyright © 2016年 mimsg. All rights reserved.
//

#import "CollectionImgTextCell.h"
#import "StringUtil.h"

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 80

@implementation CollectionImgTextCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self addCommonView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17, 40, 150, 36)];
        label.text = [StringUtil getLocalizableString:@"msg_type_robotImgtxt"];
        [label setFont:[UIFont systemFontOfSize:16]];
        label.tag = 105;
        [self addSubview:label];
        
        /*
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(12, 47, [UIScreen mainScreen].bounds.size.width - 57, 70)];
        contentView.tag = 105;
        [self addSubview:contentView];
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 25, 45, 45)];
        [contentView addSubview:self.imgView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, -5, 250, 35)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [contentView addSubview:self.titleLabel];
        
        self.desLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 23, [UIScreen mainScreen].bounds.size.width - 80, 50)];
        self.desLabel.numberOfLines = 0;
        [self.desLabel setTextColor:[UIColor grayColor]];
        [self.desLabel setFont:[UIFont systemFontOfSize:13]];
        [contentView addSubview:self.desLabel];
        */
         
        // 调整edtingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    
    return self;
}

@end
