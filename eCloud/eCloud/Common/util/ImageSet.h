//
//  ImageSet.h
//  MaskDemo
//
//  Created by shinren Pan on 2011/1/3.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageSet : NSObject {

}
+(UIImage *)colorizeImage:(UIImage *)baseImage withColor:(UIColor *)theColor;
+(UIImage *)maskImage:(UIImage *)baseImage withImage:(UIImage *)theMaskImage;
+(UIImage *)setGrayWhiteToImage:(UIImage *)baseImage;
@end
