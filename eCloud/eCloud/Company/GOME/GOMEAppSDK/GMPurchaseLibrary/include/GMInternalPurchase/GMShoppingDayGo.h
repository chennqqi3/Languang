//
//  GMShoppingDayGo.h
//  UMSocialDemo
//
//  Created by song on 2017/2/16.
//  Copyright © 2017年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface GMShoppingDayGo : NSObject

//传人当前(含有navi)UIViewController userID --默认push 进入
//当前userId是测试id 

+(void)goShoppingDayWithUserID:(UIViewController *)vc userID:(NSString *)userID;

//得到当前未读内购会数量
+(void)getUnReadInternalPurchaseNum:(NSString *)userID complete:(void (^)(NSString *countNum))complete;
@end
