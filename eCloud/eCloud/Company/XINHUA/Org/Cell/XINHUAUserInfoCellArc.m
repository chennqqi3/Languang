//
//  XINHUAUserInfoCell.m
//  eCloud
//
//  Created by Alex-L on 2017/5/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAUserInfoCellArc.h"

#import "FGalleryViewController.h"

#import "UserTipsUtil.h"
#import "StringUtil.h"
#import "ServerConfig.h"

@interface XINHUAUserInfoCellArc ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIImageView *empLogo;

@end

@implementation XINHUAUserInfoCellArc

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.empLogo = [[UIImageView alloc] initWithFrame:CGRectMake(100, 7, 36, 36)];
        self.empLogo.layer.cornerRadius = 3;
        self.empLogo.userInteractionEnabled = YES;
        self.empLogo.clipsToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage)];
        [self.empLogo addGestureRecognizer:tap];
        
        [self.contentView addSubview:self.empLogo];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 110, 25)];
        self.titleLabel.textColor = [UIColor colorWithRed:0X14/255.0 green:0X14/255.0 blue:0X14/255.0 alpha:1];
        [self.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.contentView addSubview:self.titleLabel];
        
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 13, [UIScreen mainScreen].bounds.size.width-120, 25)];
        self.valueLabel.textColor = [UIColor colorWithRed:0X99/255.0 green:0X99/255.0 blue:0X99/255.0 alpha:1];
        [self.valueLabel setFont:[UIFont systemFontOfSize:16]];
        [self.contentView addSubview:self.valueLabel];
    }
    
    return self;
}

- (void)showBigImage
{
    if (self.logoDelegate && [self.logoDelegate respondsToSelector:@selector(showBigLogo)])
    {
        [_logoDelegate showBigLogo];
    }
}

- (void)setDic:(NSDictionary *)dic
{
    _dic = dic;
    
    self.titleLabel.text = [dic objectForKey:@"title"];
    id value = [dic objectForKey:@"value"];
    if ([value isKindOfClass:[UIImage class]])
    {
        self.empLogo.image = value;
    }
    else
    {
        self.valueLabel.text = value;
    }
}

@end
