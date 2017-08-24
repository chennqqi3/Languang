//
//  APPStateRecord.m
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPStateRecord.h"

@implementation APPStateRecord
@synthesize recordid;
@synthesize appid;
@synthesize optype;
@synthesize optime;


- (void)dealloc{
    self.appid = nil;
    self.optime = nil;
    
    [super dealloc];
}
@end
