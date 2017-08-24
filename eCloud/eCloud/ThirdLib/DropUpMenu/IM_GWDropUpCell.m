//
//  GWDropUpCell.m
//  guwen
//
//  Created by 王刚 on 14/9/16.
//  Copyright (c) 2014年 ccid. All rights reserved.
//

#import "IM_GWDropUpCell.h"

@implementation IM_GWDropUpCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.lineImageView];
    }
    return self;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor darkGrayColor];
        _nameLabel.numberOfLines = 1;
    }
    _nameLabel.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    return _nameLabel;
}
- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _lineImageView.backgroundColor = [UIColor colorWithRed:202/255.0f green:202/255.0f blue:202/255.0f alpha:1.0f];
    }
    _lineImageView.frame = CGRectMake(10, 39, self.frame.size.width-20, 0.5);
    return _lineImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
