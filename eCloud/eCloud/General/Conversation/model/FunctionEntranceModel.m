//
//  FunctionEntranceModel.m
//  eCloud
//
//  Created by shisuping on 15/11/17.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "FunctionEntranceModel.h"

@implementation FunctionEntranceModel

@synthesize frame;
@synthesize clickSelector;
@synthesize normalImageName;
@synthesize highlightImageName;
@synthesize title;

- (void)dealloc
{
    self.normalImageName = nil;
    self.highlightImageName = nil;
    self.title = nil;
    
    [super dealloc];
}

@end
