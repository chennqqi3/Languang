//
//  massConversationObject.h
//  eCloud
//
//  Created by  lyong on 14-1-13.
//  Copyright (c) 2014年  lyong. All rights reserved.
//
#import <Foundation/Foundation.h>
@class Emp;
@class ConvRecord;

@interface massConversationObject : NSObject
{
    NSString *conv_id;
    NSString *conv_title;
    int create_emp_id;
    NSString *create_time;
    int last_msg_id;
    NSString *lastmsg_body;
    NSString *last_msg_body;
    NSString *last_msg_time;
    int last_emp_id;
    int last_msg_type;
    int emp_count;
    int unread;
    
}
@property(assign)int create_emp_id;
@property(assign)int last_msg_id;
@property(assign)int last_emp_id;
@property(assign)int last_msg_type;
@property(assign)int emp_count;
@property(retain)NSString *conv_id;
@property(retain)NSString *conv_title;
@property(retain)NSString *create_time;
@property(retain)NSString *lastmsg_body;
@property(retain)NSString *last_msg_body;
@property(retain)NSString *last_msg_time;
@property(assign) int unread;
@end
