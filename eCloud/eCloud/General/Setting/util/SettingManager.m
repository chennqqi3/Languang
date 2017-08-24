//
//  SettingArrayManager.m
//  eCloud
//
//  Created by lidianchao on 2017/8/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "SettingManager.h"
static SettingManager *instance = nil;
@implementation SettingManager
+ (SettingManager *)sharedManager
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[SettingManager alloc] init];
    });
    return instance;
}
- (void)getSettingItemArray:(GetSettingArrayCallback)getSettingArrayCallback
{
    NSMutableArray *settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    
    NSMutableArray *items1 = [NSMutableArray array];
    NSMutableArray *items2 = [NSMutableArray array];
    NSMutableArray *items3 = [NSMutableArray array];
    

    //    消息提醒设置
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_notification"];
    
    _item.clickSelector = @selector(openNotificationSetting);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [items1 addObject:_item];
    [_item release];
    
    
    //    通用设置
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_usual"];
    
    _item.clickSelector = @selector(openUsualSetting);
    _item.customCellSelector = @selector(customCellOfUsual:);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [items1 addObject:_item];
    [_item release];
    
#if defined(_XIANGYUAN_FLAG_) || defined(_BGY_FLAG_)
    
    
#else
    
    if ([eCloudConfig getConfig].supportCollection)
    {
        if (![UIAdapterUtil isLANGUANGApp]) {
            
            //    收藏
            _item = [[SettingItem alloc]init];
            _item.itemName = [StringUtil getLocalizableString:@"my_collections"];
            
            _item.clickSelector = @selector(openMyCollections);
            
            _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            _item.selectionStyle = UITableViewCellSelectionStyleGray;
            
            [settingItemArray addObject:[NSArray arrayWithObject:_item]];
            [_item release];
        }
    }
    
#endif
    
    
    //    关于
    _item = [[SettingItem alloc]init];
//    _item.itemName = [StringUtil getLocalizableString:@"settings_about"];
    _item.itemName = [StringUtil getLocalizableString:@"settings_about"];
    
    _item.clickSelector = @selector(openAbout);
    _item.customCellSelector = @selector(customCellOfAbout:);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [items2 addObject:_item];
    [_item release];
    
    //    意见反馈
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"settings_feedback"];
    
    _item.clickSelector = @selector(openIdeaFeedback);
    _item.customCellSelector = @selector(customCellOfAbout:);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [items2 addObject:_item];
    [_item release];
    
    //    清除缓存
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_clear_cache"];
    
    _item.clickSelector = @selector(clearDateView);
    _item.customCellSelector = @selector(customCellOfAbout:);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [items3 addObject:_item];
    [_item release];
    [settingItemArray addObject:items1];
    [settingItemArray addObject:items2];
    [settingItemArray addObject:items3];
    getSettingArrayCallback(settingItemArray);
}
@end
