//
//  APPToken.m
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPToken.h"

@implementation APPToken

@synthesize usercode;
@synthesize token;

- (void)dealloc{
    self.usercode = nil;
    self.token = nil;
    
    [super dealloc];
}

@end
