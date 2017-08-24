//
//  FilesOfTime.m
//  eCloud
//
//  Created by shisuping on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "FilesOfTime.h"

@implementation FilesOfTime

@synthesize curTime;
@synthesize filesArray;

@synthesize isExtend;

- (void)dealloc
{
    self.curTime = nil;
    self.filesArray = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isExtend = YES;
    }
    return self;
}

@end
