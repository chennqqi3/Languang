//
//  OffenGroup.h
//  eCloud
//
//  Created by  lyong on 13-8-22.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OffenGroup : NSObject
{
    // 级别
    int group_level;
    NSString *group_id;
    NSString *group_title;
}
@property(nonatomic,retain) NSString *group_id;
@property(nonatomic,retain)  NSString *group_title;
@property(assign)int group_level;
@end
