//
//  SettingItem.m
//  eCloud
//
//  Created by shisuping on 15-9-6.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "SettingItem.h"
#import "UIAdapterUtil.h"

@implementation SettingItem

@synthesize itemValue;
@synthesize cellHeight;

@synthesize itemName;
@synthesize imageName;

@synthesize accessoryType;
@synthesize selectionStyle;

@synthesize clickSelector;

@synthesize headerHight;

@synthesize headerView;

@synthesize customCellSelector;

@synthesize detailValueColor;
@synthesize detailValueSize;

@synthesize dataObject;

@synthesize logoDic;

- (void)dealloc
{
    self.dataObject = nil;
    
    self.detailValueColor = nil;
    self.itemValue = nil;
    self.headerView = nil;
    self.itemName = nil;
    
    self.logoDic = nil;
    self.searchContent = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.detailValueColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

@end
