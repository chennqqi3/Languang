//
//  Rank.m
//  eCloud
//
//  Created by Richard on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "Rank.h"

@implementation Rank
@synthesize rankId;
@synthesize rankName;
@synthesize isChecked;
-(void)dealloc
{
	self.rankName = nil;
	[super dealloc];
}
-(id)init
{
	self = [super init];
	if(self)
	{
		self.rankId = 0;
		self.rankName = @"";
        self.isChecked=false;
	}
	return self;
}
@end
