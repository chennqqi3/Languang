//
//  showPreImageViewController.h
//  eCloud
//
//  Created by  lyong on 12-11-13.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class talkSessionViewController;
@interface showPreImageViewController : UIViewController
{
    UIImage *imageData;
    UIImageView *imageView;
    id delegete;
}
@property(nonatomic,retain) UIImage *imageData;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) id delegete;
@end
