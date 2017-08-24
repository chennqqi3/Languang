//
//  helperObject.m
//  eCloud
//
//  Created by  lyong on 13-10-20.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "helperObject.h"
#import "Emp.h"

@implementation helperObject
@synthesize group_id = _group_id;
@synthesize helper_id = _helper_id;
@synthesize ring_type=_ring_type;
@synthesize helper_name=_helper_name;
@synthesize helper_detail=_helper_detail;
@synthesize create_emp_id=_create_emp_id;
@synthesize create_emp_name=_create_emp_name;
@synthesize create_time=_create_time;
@synthesize start_time=_start_time;
@synthesize end_time=_end_time;
@synthesize empArray=_empArray;
@synthesize start_date=_start_date;
@synthesize ring_str=_ring_str;
@synthesize unread=_unread;
@synthesize show_week=_show_week;
@synthesize is_read=_is_read;
@synthesize is_now=_is_now;
@synthesize is_group=_is_group;
-(void)dealloc
{
	self.group_id = nil;
	self.helper_id = nil;
	self.helper_name = nil;
	self.helper_detail = nil;
	self.create_time = nil;
    self.start_time=nil;
    self.end_time=nil;
    self.empArray=nil;
    self.start_date=nil;
    self.ring_str=nil;
    self.create_emp_name=nil;
	[super dealloc];
}
@end
