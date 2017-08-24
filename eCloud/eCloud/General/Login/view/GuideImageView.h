//
//  GuideImageView.h
//  GuideImageDemo
//
//  Created by Alex L on 17/1/11.
//  Copyright © 2017年 Alex L. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GUIDE_IMAGE_KEY @"isFirstTimeLogin"

@interface GuideImageView : UIView

- (instancetype)initWithImages:(NSArray *)images;

@property (nonatomic, strong) NSArray *images;

@end
