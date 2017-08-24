//
//  RemindModel.m
//  eCloud
//
//  Created by shisuping on 16/8/24.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "RemindModel.h"

@implementation RemindModel

@synthesize fromSystem;
@synthesize remindDetail;
@synthesize remindTime;
@synthesize remindTitle;
@synthesize remindType;
@synthesize remindURL;
@synthesize remindMsgId;

- (void)dealloc
{
    self.fromSystem = nil;
    self.remindURL = nil;
    self.remindDetail = nil;
    self.remindTitle = nil;
    self.remindMsgId = nil;
    [super dealloc];
}

@end
