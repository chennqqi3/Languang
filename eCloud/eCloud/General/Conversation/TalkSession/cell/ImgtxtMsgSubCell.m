//
//  ImgtxtMsgSubCell.m
//  eCloud
//
//  Created by yanlei on 15/11/8.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ImgtxtMsgSubCell.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"

@implementation ImgtxtMsgSubCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self titleLabel];
        [self picUrlImageView];
        [self descriptionLabel];
        [self separatorLine];
    }
    return self;
}

#pragma mark - 懒加载
// 图文标题
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH-40-70-5, 20)];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}
// 图文图片
- (UIImageView *)picUrlImageView{
    if (!_picUrlImageView) {
        _picUrlImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(_titleLabel.frame)+5, 54, 54)];
        _picUrlImageView.image = [StringUtil getImageByResName:@"delete"];
        _picUrlImageView.contentMode = UIViewContentModeScaleToFill;
        _picUrlImageView.clipsToBounds = YES;
        [self addSubview:_picUrlImageView];
    }
    return _picUrlImageView;
}
// 图文描述
- (UILabel *)descriptionLabel{
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_picUrlImageView.frame)+5, CGRectGetMaxY(_titleLabel.frame)+5, SCREEN_WIDTH-40-70-60-5, 60)];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.font = [UIFont systemFontOfSize:14];
        _descriptionLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_descriptionLabel];
    }
    return _descriptionLabel;
}
// 图文分割线
- (UIImageView *)separatorLine{
    if (!_separatorLine) {
        _separatorLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_picUrlImageView.frame)+4, SCREEN_WIDTH-40-70, 1)];
        _separatorLine.backgroundColor = [StringUtil colorWithHexString:@"#f2f2f2"];
        _separatorLine.hidden = YES;
        [self addSubview:_separatorLine];
    }
    return _separatorLine;
}

@end
