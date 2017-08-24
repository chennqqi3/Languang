//
//  helperObject.h
//  eCloud
//
//  Created by  lyong on 13-10-20.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Emp;
@interface helperObject : NSObject
{
NSString * _group_id;
NSString * _helper_id;
int _ring_type;
NSString *_helper_name;
NSString *_helper_detail;
int _create_emp_id;
NSString *_create_emp_name;
NSString *_create_time;
NSString *_start_time;
NSString *_end_time;
NSArray *empArray;
NSString *_start_date;
NSString *_ring_str;
BOOL show_week;
int unread;
int is_read;
BOOL is_now;
BOOL is_group;
}
@property (retain) NSString * group_id;
@property (retain) NSString * helper_id;
@property(assign) int ring_type;
@property(assign) int unread;
@property(assign) int is_read;
@property(assign) BOOL show_week;
@property(assign) BOOL is_now;
@property(assign) BOOL is_group;
@property(retain) NSString *helper_name;
@property(retain) NSString *helper_detail;
@property(assign) int create_emp_id;
@property(retain) NSString *create_emp_name;
@property(retain) NSString * create_time;
@property(retain)  NSString *start_time;
@property(retain)  NSString *end_time;
@property(retain)  NSArray *empArray;
@property(retain)  NSString *start_date;
@property(retain)  NSString *ring_str;
@end
