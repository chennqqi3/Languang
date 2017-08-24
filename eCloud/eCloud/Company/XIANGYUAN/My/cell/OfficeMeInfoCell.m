//
//  MeInfoCell.m
//  WanDaOA
//
//  Created by hfchenc on 14-6-26.
//  Copyright (c) 2014年 李文龙. All rights reserved.
//

#import "OfficeMeInfoCell.h"
#import "IOSSystemDefine.h"
#import "TTTAttributedLabel.h"

#define kCellLineHeight 0.8

@implementation OfficeMeInfoCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
//    _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height-kCellLineHeight, kScreenWidth, kCellLineHeight)];
//    _lineImageView.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.000];
//    [self addSubview:_lineImageView];
    
    self.titleLabel.textColor = [UIColor colorWithRed:119/255.0 green:128/255.0 blue:143/255.0 alpha:1];
//    self.subTitleLabel.textColor = kTextColor(@"#595959");
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //[self.subTitleLabel sizeToFit];
    
    CGRect _frame = self.subTitleLabel.frame;
    _frame.origin.x = 65;
    _frame.origin.y = self.subTitleLabel.frame.origin.y;
    _frame.size.width = SCREEN_WIDTH - 70;
    self.subTitleLabel.frame = _frame;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (id)loadFromXib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"OfficeMeInfoCell" owner:self options:nil] objectAtIndex:0];
}


@end
