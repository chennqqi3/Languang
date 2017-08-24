//在主线程上发出通知

#define notification_name @"notification_name"
#define notification_object @"notification_object"
#define notification_userinfo @"notification_userinfo"

#import <Foundation/Foundation.h>
@class eCloudNotification;

@interface NotificationUtil : NSObject

/**
 获取NotificationUtil实例

 @return NotificationUtil实例对象
 */
+ (NotificationUtil *)getUtil;

/**
 在主线程上执行sendNotification方法

 @param dic 内容字典
 */
- (void)sendNotificationOnMainThread:(NSDictionary *)dic;

/**
 自定义封装发送通知的字典内容

 @param _name     通知名称
 @param _object   eCloudNotification实例对象
 @param _userInfo 字典内容
 */
- (void)sendNotificationWithName:(NSString *)_name andObject:(eCloudNotification *)_object andUserInfo:(NSDictionary *)_userInfo;

@end
