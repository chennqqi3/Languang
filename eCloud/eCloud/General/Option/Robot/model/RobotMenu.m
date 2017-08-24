//
//  RobotMenu.m
//  eCloud
//
//  Created by shisuping on 15/11/9.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "RobotMenu.h"

@implementation RobotMenu

@synthesize menuKey;
@synthesize menuName;
@synthesize menuOrder;
@synthesize subMenu;
@synthesize isSelected;

- (void)dealloc
{
    self.subMenu = nil;
    self.menuName = nil;
    self.menuKey = nil;
    [super dealloc];
}

@end
