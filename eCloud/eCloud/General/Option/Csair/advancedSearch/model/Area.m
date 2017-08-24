//
//  Area.m
//  eCloud
//
//  Created by Richard on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "Area.h"

@implementation Area

@synthesize areaId;
@synthesize areaName;
@synthesize parentArea;
@synthesize isChecked;
-(void)dealloc
{
	self.areaName = nil;
	[super dealloc];
}
-(id)init
{
	self = [super init];
	if(self)
	{
		self.areaId = 0;
		self.areaName = @"";
		self.parentArea = 0;
        self.isChecked=false;
	}
	return self;
}


@end
