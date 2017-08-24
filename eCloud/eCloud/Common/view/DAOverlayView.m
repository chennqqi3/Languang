//
//  DAOverlayView.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/25/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAOverlayView.h"

@implementation DAOverlayView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.delegate overlayView:self didHitTest:point withEvent:event];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(4_0)
{
    [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
}
@end