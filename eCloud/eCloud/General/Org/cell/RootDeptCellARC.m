//
//  RootDeptCellARC.m
//  eCloud
//
//  Created by Alex-L on 2017/7/16.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "RootDeptCellARC.h"
#import "Dept.h"
#import "StringUtil.h"

@interface RootDeptCellARC ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation RootDeptCellARC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(60, 7, 45, 45)];
        [self.contentView addSubview:self.icon];
        
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 18, [UIScreen mainScreen].bounds.size.width-30-115, 25)];
        [self.nameLabel setFont:[UIFont systemFontOfSize:17]];
        self.nameLabel.textColor = [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:1];
        [self.contentView addSubview:self.nameLabel];
        
    }
    
    return self;
}

- (void)setItem:(SettingItem *)item
{
    _item = item;
    
    id dataObject = _item.dataObject;
    if ([dataObject isKindOfClass:[Dept class]])
    {
        Dept *tempDept = (Dept *)dataObject;
        self.nameLabel.text = tempDept.dept_name;
    }
    
    self.icon.image = [StringUtil getImageByResName:_item.imageName];
}

@end
