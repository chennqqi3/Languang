//
//  LocationMsgUtil.h
//  eCloud
//  和获取显示当前位置有关的工具栏
//  Created by shisuping on 16/5/26.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MAP_ZOOM_LEVEL (17.5)

#define REDPIN_TAG (123321)

@class LocationModel;

@interface LocationMsgUtil : NSObject

/** 获取位置对应图片 */
+ (NSString *)getLocationImagePath:(LocationModel *)model;

/** 获取位置对应路径 */
+ (UIImage *)getLocationImage:(LocationModel *)model;

/** 获取红色大头针的imageview */
+ (UIImageView *)getRedPinImageView;

@end
