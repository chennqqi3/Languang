//
//  BGYSettingViewController.h
//  eCloud
//
//  Created by Alex-L on 2017/7/6.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MORE_VIEW_WIDTH (SCREEN_WIDTH*(3.0/4.0))

@interface BGYMoreViewControllerARC : UIViewController

@property (nonatomic, strong) UIView *backgrounpView;
@property (nonatomic, strong) UIView *moreView;

+ (BGYMoreViewControllerARC *)getMoreViewController;

- (void)showMoreViewController;
- (void)hideMoreVC;

@end

