//
//  eCloudNotification.m
//  eCloud
//
//  Created by robert on 12-10-22.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "eCloudNotification.h"

#import "LogUtil.h"

@implementation eCloudNotification
@synthesize cmdId = _cmdId;
@synthesize info = _info;

-(void)dealloc
{
    self.info = nil;
    [super dealloc];
}

- (NSString *)description
{
//    [LogUtil debug:[NSString stringWithFormat:@"%d,%@",self.cmdId,(self.info?[self.info description]:@"")]];
    return @"";
}
@end
