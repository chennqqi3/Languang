//
//  VIPhotoView.h
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VIPhotoDelegate <NSObject>

- (void)popToLastController;

@end

@interface VIPhotoView : UIScrollView

@property (nonatomic, assign) id<VIPhotoDelegate>photoDelegate;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@end
