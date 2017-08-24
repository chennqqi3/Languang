//
//  UIView+Common.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/18.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSALoadingView;

@interface UIView (Common)

@property (nonatomic, strong) GSALoadingView *loadingView;

- (void)beginLoading;
- (void)endLoading;

@end

@interface GSALoadingView : UIView

@property (nonatomic, strong) UIImageView *loopView;
@property (nonatomic, strong) UIImageView *beeView;
@property (nonatomic, assign, readonly) BOOL isLoading;

- (void)startAnimating;
- (void)stopAnimating;

@end
