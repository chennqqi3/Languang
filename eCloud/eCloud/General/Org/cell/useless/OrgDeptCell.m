//
//  OrgDeptCell.m
//  eCloud
//
//  Created by Alex L on 16/8/25.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "OrgDeptCell.h"
#import "OrgSizeUtil.h"
#import "UIAdapterUtil.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define name_font_size (17.0)

@interface OrgDeptCell ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation OrgDeptCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        CGFloat LeftScrollVieWidth = [OrgSizeUtil getLeftScrollViewWidth];
        NSLog(@"LeftScrollVieWidth %f", LeftScrollVieWidth);
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(LeftScrollVieWidth+10, 0, SCREEN_WIDTH-58-50, 45)];
        [self.nameLabel setTextColor: [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor]];
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.font = [UIFont systemFontOfSize:name_font_size];
        self.nameLabel.backgroundColor = [UIColor whiteColor];
        self.nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)addRightButton
{
    self.button = nil;
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.button setTitle:@"设为常用联系人" forState:UIControlStateNormal];
    self.button.frame = CGRectMake(0, 0, 114, 40);
    self.rightButtons = @[self.button];
}

- (void)setOptionButtonTitle:(NSString *)optionButtonTitle
{
    _optionButtonTitle = optionButtonTitle;
    [self.button setTitle:optionButtonTitle forState:UIControlStateNormal];
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = _name;
}

@end
