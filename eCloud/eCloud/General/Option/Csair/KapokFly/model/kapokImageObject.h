//
//  kapokImageObject.h
//  eCloud
//
//  Created by  lyong on 14-5-13.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface kapokImageObject : NSObject
{
    NSString *image_path;
    NSString *image_token;
    NSString *image_name;
    int upload_start_index;
}
@property(retain) NSString *image_path;
@property(retain) NSString *image_token;
@property(retain) NSString *image_name;
@property(assign) int upload_start_index;
@end
