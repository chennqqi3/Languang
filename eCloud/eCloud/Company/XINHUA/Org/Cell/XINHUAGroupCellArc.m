//
//  XINHUAGroupCellArc.m
//  eCloud
//
//  Created by Alex-L on 2017/5/23.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAGroupCellArc.h"

@implementation XINHUAGroupCellArc

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.groupLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 45, 45)];
        [self.contentView addSubview:self.groupLogo];
        self.groupLogo.layer.cornerRadius = 4;
        self.groupLogo.clipsToBounds = YES;
        
        self.groupName = [[UILabel alloc] initWithFrame:CGRectMake(77, 18, self.frame.size.width-100, 25)];
        self.groupName.textColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1];
        [self.groupName setFont:[UIFont systemFontOfSize:16]];
        [self.contentView addSubview:self.groupName];
        
        CGFloat height = 1.0/[UIScreen mainScreen].scale;
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 59, [UIScreen mainScreen].bounds.size.width, height)];
        view1.backgroundColor = [UIColor colorWithWhite:.9f alpha:1];
        [self.contentView addSubview:view1];
    }
    
    return self;
}

@end
