//
//  settingRemindController.h
//  eCloud
//
//  Created by  lyong on 12-10-29.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
@class UserInfo;

@interface settingRemindController : NSObject
{
  UserInfo* userinfo;
	double curtime;
	double oldtime;
}
@property (nonatomic,assign) int soundFlag;

+(id)initSettingRemind;
- (void)checkRemindType;
- (void)initSound;
-(void)sayHello;

@end
