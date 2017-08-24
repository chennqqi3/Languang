//
//  VirGroupObj.h
//  eCloud
//
//  Created by  lyong on 13-5-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirGroupObj : NSObject
{
    NSString *virgroup_id;
    NSString *virgroup_name;
    NSString *virgroup_updatetime;
    int virgroup_usernum;
    BOOL isExtended;
    int virgroup_level;
}
@property(retain)NSString *virgroup_id;
@property(retain)NSString *virgroup_name;
@property(retain)NSString *virgroup_updatetime;
@property (assign) int virgroup_usernum;
@property (assign) int virgroup_level;
@property (assign) BOOL isExtended;
@end
