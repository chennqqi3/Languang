//
//  EmpHeadViewCell.m
//  eCloud
//
//  Created by Alex-L on 2017/4/13.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "XINHUAEmpHeadViewCellArc.h"

@interface XINHUAEmpHeadViewCellArc ()

@property (nonatomic, strong) UILabel *theTitleLabel;

@end

@implementation XINHUAEmpHeadViewCellArc

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier])
    {
//        self.backgroundColor = [UIColor colorWithWhite:.6f alpha:0.6];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.theTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 22)];
        self.theTitleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        [self.theTitleLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:self.theTitleLabel];
        
        
        CGFloat height = 1.0/[UIScreen mainScreen].scale;
//        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
//        view1.backgroundColor = [UIColor colorWithWhite:.9f alpha:1];
//        [self addSubview:view1];
        
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 21, [UIScreen mainScreen].bounds.size.width, height)];
        view2.backgroundColor = [UIColor colorWithWhite:.9f alpha:1];
        [self addSubview:view2];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.theTitleLabel.text = _title;
}

@end
