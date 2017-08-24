//
//  talkPreImageViewController.h
//  eCloud
//
//  Created by  lyong on 12-11-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FGalleryViewController;

#define kImagePreviewDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]  stringByAppendingPathComponent:@"ImagePreview"]
#define preimagename @"preImage.png"

@interface talkPreImageViewController : UIViewController
{
FGalleryViewController *localGallery;
FGalleryViewController *networkGallery;
UIImage *imageData;
UIImageView *imageView;
id delegete;
NSString *preImageFullPath;
UINavigationController *naviController;
}
@property(nonatomic,retain) UIImage *imageData;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) id delegete;
@property(nonatomic,retain)  NSString *preImageFullPath;
@end