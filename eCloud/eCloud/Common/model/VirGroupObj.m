//
//  VirGroupObj.m
//  eCloud
//
//  Created by  lyong on 13-5-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "VirGroupObj.h"

@implementation VirGroupObj
@synthesize virgroup_id;
@synthesize virgroup_name;
@synthesize virgroup_updatetime;
@synthesize virgroup_usernum;
@synthesize isExtended;
@synthesize virgroup_level;

-(void)dealloc
{
	self.virgroup_id = nil;
	self.virgroup_name = nil;
	self.virgroup_updatetime = nil;
	self.isExtended = nil;
	[super dealloc];
}
@end
