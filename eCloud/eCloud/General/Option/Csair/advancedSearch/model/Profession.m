//
//  Profession.m
//  eCloud
//
//  Created by Richard on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "Profession.h"

@implementation Profession
@synthesize profId;
@synthesize profName;
@synthesize isChecked;
-(void)dealloc
{
	self.profName = nil;
	[super dealloc];
}
-(id)init
{
	self = [super init];
	if(self)
	{
		self.profId = 0;
		self.profName = @"";
        self.isChecked=false;
	}
	return self;
}
@end
