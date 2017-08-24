//
//  CBNavigationController.m
//  eCloud
//
//  Created by shisuping on 14-12-21.
//  Copyright (c) 2014年  lyong. All rights reserved.
//


#import "CBNavigationController.h"


@implementation CBNavigationController
- (void)viewDidLoad
{
    __weak CBNavigationController *weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        
        self.delegate = weakSelf;
        
    }
}

// Hijack the push method to disable the gesture
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]&&animated==YES){
        // 防止在push下一个界面动画过程中，用户左侧手势返回，手势冲突造成的crash，先将侧滑关闭
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]&&animated==YES){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return  [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    return [super popToViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController

       didShowViewController:(UIViewController *)viewController

                    animated:(BOOL)animate
{
    
    // Enable the gesture again once the new controller is shown
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        // 页面加载完成后，将侧滑手势打开
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer==self.interactivePopGestureRecognizer) {
        
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}
@end
