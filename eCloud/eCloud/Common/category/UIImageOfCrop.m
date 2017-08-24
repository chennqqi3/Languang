//
//  UIImageOfCrop.m
//  eCloud
//
//  Created by Richard on 13-12-31.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "UIImageOfCrop.h"
@implementation UIImage(UIImageOfCrop)
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
//	宽和高的比例是268 / 150
	float targetAspect = targetSize.width / targetSize.height;
	
    UIImage *sourceImage = self;
    CGSize imageSize = sourceImage.size;
	CGFloat srcWidth = imageSize.width;
    CGFloat srcHeight = imageSize.height;
	
	float srcAspect = srcWidth / srcHeight;
	
	CGFloat targetX;
	CGFloat targetY;
	
	CGFloat targetWidth;
	CGFloat targetHeight;
	
	if(targetAspect > srcAspect)
	{
//		需要垂直方向截取一部分
		targetWidth = srcWidth;
		targetHeight = srcWidth / targetAspect;
		
		targetX = 0;
		targetY = (srcHeight - targetHeight)/2;
		
	}
	else if(targetAspect < srcAspect)
	{
//		需要水平方向截取一部分
		
		targetHeight = srcHeight;
		targetWidth = srcHeight * targetAspect;
		targetX = (srcWidth - targetWidth)/2;
		targetY = 0;
	}
	else
	{
		return self;
	}
	
	CGRect rect = CGRectMake(targetX, targetY, targetWidth, targetHeight);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [self drawInRect:drawRect];
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
	
	return croppedImage;
}
@end
