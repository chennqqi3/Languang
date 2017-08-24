//
//  LGSettingCell.m
//  eCloud
//
//  Created by Alex-L on 2017/5/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGSettingCellArc.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"

#define LOGOUT_LABEL_W 200
#define cellH 51

@interface LGSettingCellArc ()

@end

@implementation LGSettingCellArc

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13.5, 24, 24)];
        [self.contentView addSubview:self.icon];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 14, 160, cellH-28.5)];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:self.titleLabel];
        
        
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 11.5, 45, 45)];
        [self.logoView.layer setMasksToBounds:YES];
        [self.logoView.layer setCornerRadius:24];
        [self.contentView addSubview:self.logoView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(69.5, 19, SCREEN_WIDTH-120, 30)];
        [self.nameLabel setFont:[UIFont fontWithName:@"PingFangHK-Medium" size:17]];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.nameLabel];
                
        self.logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - LOGOUT_LABEL_W)/2, 0, LOGOUT_LABEL_W, cellH)];
        self.logoutLabel.textColor = [UIColor redColor];
        self.logoutLabel.textAlignment = NSTextAlignmentCenter;
        self.logoutLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.logoutLabel];
        
        //self.arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH -26.5, 19.5, 12, 12)];
//        self.arrowImage.image = [StringUtil getImageByResName:@"btn_right_arrow.png"];
        //[self.contentView addSubview:self.arrowImage];
    }
    
    return self;
}

@end
