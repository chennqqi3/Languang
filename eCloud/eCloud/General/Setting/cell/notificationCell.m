//
//  dataCell.m
//  eCloud
//
//  Created by SH on 14-8-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "notificationCell.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "GYFrame.h"
#import "IOSSystemDefine.h"

@implementation notificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self configUI];
    }
    return self;
}
- (void)configUI
{
    [UIAdapterUtil customSelectBackgroundOfCell:self];
    //        float nameY = [UIAdapterUtil isLANGUANGApp]? 0:5;
    CGRect nameLabelRect = CGRectMake(12, 14.5, SCREEN_WIDTH-82-12, 22);
    self.nameLable = [[UILabel alloc] initWithFrame:[GYFrame myRect:nameLabelRect]];
    self.nameLable.backgroundColor = [UIColor clearColor];
    self.nameLable.textColor= UIColorFromRGB(0x333333);
    self.nameLable.font=[UIFont systemFontOfSize:kGetCurrentValue(17)];
    self.nameLable.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.nameLable];
    //        float labelY = [UIAdapterUtil isLANGUANGApp]? 0:5;
    CGRect inOpenLabelRect = CGRectMake(self.nameLable.frame.size.width + self.nameLable.frame.origin.x + 22-54, 14.5, 100, 22);
    self.inOpenLable = [[UILabel alloc]initWithFrame:[GYFrame myRect:inOpenLabelRect]];
    self.inOpenLable.backgroundColor = [UIColor clearColor];
    self.inOpenLable.textColor=UIColorFromRGB(0xA3A3A3);
    self.inOpenLable.font=[UIFont systemFontOfSize:kGetCurrentValue(17)];
    self.inOpenLable.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.inOpenLable];
    
    CGRect switchRect = CGRectMake(self.nameLable.frame.size.width + self.nameLable.frame.origin.x + 22, 10, 0, 0);
    self.switchBtn = [[UISwitch alloc] initWithFrame:[GYFrame myRect:switchRect]];
    self.switchBtn.onTintColor = UIColorFromRGB(0x2481FC);
    [self.switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switchBtn];
}
- (void)switchAction:(UISwitch *)sender
{
    self.switchActionCallBack(sender);
}
- (void)showSwitch
{
    self.switchBtn.hidden = NO;
    self.inOpenLable.hidden = YES;
}
- (void)showIsOpenLabel
{
    self.switchBtn.hidden = YES;
    self.inOpenLable.hidden = NO;
}
-(void)dealloc
{
    self.nameLable = nil;
    self.inOpenLable = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
