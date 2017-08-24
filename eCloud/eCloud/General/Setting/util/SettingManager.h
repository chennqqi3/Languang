//
//  SettingArrayManager.h
//  eCloud
//
//  Created by lidianchao on 2017/8/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingItem.h"
#import "StringUtil.h"
#import "eCloudConfig.h"
#import "UIAdapterUtil.h"
typedef void(^GetSettingArrayCallback)(NSArray *settingArray);

@interface SettingManager : NSObject
+ (SettingManager *)sharedManager;
- (void)getSettingItemArray:(GetSettingArrayCallback)getSettingArrayCallback;
@end
