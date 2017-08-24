//
//  UIRoundedRectImage.h
//  eCloud
//
//  Created by robert on 12-11-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
//设置UIImage圆角
@interface UIImage(UIRoundedRectImage)
+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size;
@end