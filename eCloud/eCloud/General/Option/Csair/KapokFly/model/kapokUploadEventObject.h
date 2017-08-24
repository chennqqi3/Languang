//
//  kapokUploadEventObject.h
//  eCloud
//
//  Created by  lyong on 14-5-6.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface kapokUploadEventObject : NSObject
{
    NSString *upload_id;
    NSString *selected_date;
    NSString *create_time;
    NSString *flight_num;
    NSString *start_airport;
    NSString *boarding_num;
    NSString *emp_code;
    NSString *show_str;
    int upload_state;
}
@property(assign)int upload_state;
@property(retain) NSString *upload_id;
@property(retain) NSString *selected_date;
@property(retain) NSString *create_time;
@property(retain) NSString *flight_num;
@property(retain) NSString *start_airport;
@property(retain) NSString *boarding_num;
@property(retain) NSString *emp_code;
@property(retain) NSString *show_str;
@end
