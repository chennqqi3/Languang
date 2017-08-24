//
//  LocationMsgUtil.m
//  eCloud
//
//  Created by shisuping on 16/5/26.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "LocationMsgUtil.h"

#import "StringUtil.h"
#import "LocationModel.h"

@implementation LocationMsgUtil

//获取位置对应图片
+ (NSString *)getLocationImagePath:(LocationModel *)model
{
    NSString *lantitude = [[NSNumber numberWithDouble:model.lantitude]stringValue];
    NSString *longitude = [[NSNumber numberWithDouble:model.longtitude]stringValue];
    return [StringUtil getMapPath:lantitude withLongitude:longitude];
}

//获取位置对应路径
+ (UIImage *)getLocationImage:(LocationModel *)model
{
    NSString *mapPath = [LocationMsgUtil getLocationImagePath:model];
    UIImage *image = [UIImage imageWithContentsOfFile:mapPath];
    return image;
}

+ (UIImageView *)getRedPinImageView
{
    UIImageView *redPin = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource:@"mapapi" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:@"/images/pin_red@2x.png"];
    redPin.image = [UIImage imageWithContentsOfFile:imagePath];
    redPin.tag = REDPIN_TAG;
#ifdef _LANGUANG_FLAG_
    redPin.image = [StringUtil getImageByResName:@"ic_map_gps_target"];
#endif
    return [redPin autorelease];
}
@end
