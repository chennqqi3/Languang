//
//  CurrentLocationUtil.h
//  eCloud
//  获取当前位置工具类 使用的是百度地图SDK
//  Created by Ji on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMLocationDelegate <NSObject>

/*
 功能说明
 获取到用户位置 回调
 
 locationStr:一个json字符串，包括了经度、纬度、位置
 */
- (void)didGetCurrentLocation:(NSString *)locationStr;

@end

@interface CurrentLocation : NSObject

@property (nonatomic,assign) id<IMLocationDelegate> delegate;

+ (CurrentLocation *)getUtil;

//获取用户位置
- (void)getUSerLocation;

@end
