//
//  ServiceMenuModel.m
//  1244
//
//  Created by Pain on 14-8-25.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import "ServiceMenuModel.h"

@implementation ServiceMenuModel
@synthesize platformid;
@synthesize createtime;
@synthesize button;
- (void)dealloc{
    self.button = nil;
    self.createtime = nil;
    [super dealloc];
}



@end
