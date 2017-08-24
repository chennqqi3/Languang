//
//  UIImageOfCrop.h
//  eCloud
//
//  Created by Richard on 13-12-31.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(UIImageOfCrop)
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
