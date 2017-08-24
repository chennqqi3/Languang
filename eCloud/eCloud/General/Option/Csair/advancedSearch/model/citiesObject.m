//
//  citiesObject.m
//  eCloud
//
//  Created by  lyong on 13-12-19.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "citiesObject.h"

@implementation citiesObject

@synthesize some_cities;
@synthesize some_cityid;
-(void)dealloc
{
	self.some_cityid = nil;
    self.some_cities = nil;
	[super dealloc];
}
-(id)init
{
	self = [super init];
	if(self)
	{   self.some_cityid = @"";
        self.some_cities = @"";
	}
	return self;
}
@end
