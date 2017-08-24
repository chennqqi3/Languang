// ios 系统版本及系统适配相关的定义
  
#ifndef eCloud_IOSSystemDefine_h
#define eCloud_IOSSystemDefine_h

//ios6以前的系统
#define IOS_VERSION_BEFORE_6 ([[[UIDevice currentDevice]systemVersion]floatValue] < 6.0)

//ios7及以后
//#define IOS7_OR_LATER	 ( [[[[UIDevice currentDevice] systemVersion]floatValue] compare:@"7.0"] != NSOrderedAscending )

#define IOS7_OR_LATER	 ( [[[UIDevice currentDevice] systemVersion]floatValue] >= 7.0 )

//ios8及以后
//#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0 )

//ios9及以后
#define IOS9_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 )

//ios10及以后
#define IOS10_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] floatValue] >=  10.0 )

//========5c 适配========
#pragma mark add by shisp 4英寸屏幕
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define i5_h_diff 88

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IPHONE_5S_OR_LESS (SCREEN_HEIGHT <= 568)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define STATUSBAR_HEIGHT ([[UIApplication sharedApplication]statusBarFrame].size.height)

#define NAVIGATIONBAR_HEIGHT (44.0)

#define TABBAR_HEIGHT (44.0)

/** 用于搜索框与下面视图分割的间距 */
#define SEARCHBAR_SPACE (1.0)
#endif
