//
//  UIProgressLabel.m
//  eCloud
//
//  Created by Richard on 13-12-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "UIProgressLabel.h"

@implementation UILabel(UIProgressLabel)

- (void)setProgress:(float)newProgress
{
	int percent = (newProgress * 100);
//	NSLog(@"%d%%",percent);
	self.text = [NSString stringWithFormat:@"%d%%",percent];
}

@end
