//
//  FunctionButtonModel.m
//  eCloud
//
//  Created by shisuping on 15-10-8.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "FunctionButtonModel.h"

@implementation FunctionButtonModel

@synthesize functionName;
@synthesize imageName;
@synthesize hlImageName;

- (void)dealloc
{
    self.functionName = nil;
    self.imageName = nil;
    self.hlImageName = nil;
    
    [super dealloc];
}
@end
