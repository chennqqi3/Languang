//
//  RecentGroup.m
//  eCloud
//
//  Created by  lyong on 13-12-10.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "RecentGroup.h"

@implementation RecentGroup
@synthesize type_id = _type_id;
@synthesize type_name = _type_name;
@synthesize ftype_name = _ftype_name;
@synthesize type_parent = _type_parent;
@synthesize type_comp_id = _type_comp_id;
@synthesize isChecked = _isChecked;
@synthesize isExtended = _isExtended;
@synthesize type_level=_type_level;
@synthesize display = _display;
@synthesize firstExend = _firstExtend;
@synthesize totalNum;
@synthesize onlineNum;
@synthesize type_tel=_type_tel;
@synthesize conv_id=_conv_id;
-(void)dealloc
{
	self.type_name = nil;
    self.ftype_name = nil;
	self.type_tel = nil;
	[super dealloc];
}
@end