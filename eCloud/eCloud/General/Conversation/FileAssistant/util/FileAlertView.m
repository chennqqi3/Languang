//
//  FileAlertView.m
//  eCloud
//
//  Created by 风影 on 15/2/9.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "FileAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FileAlertView

- (void)dealloc{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)_title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.backgroundColor = [[UIColor blackColor] CGColor];
        self.alpha = 0.8;
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [[UIColor colorWithRed:103.0/255 green:103.0/255 blue:103.0/255 alpha:1.0] CGColor];
        
        UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0, frame.size.width, frame.size.height)];
        sourceLabel.backgroundColor = [UIColor clearColor];
        sourceLabel.textColor=[UIColor whiteColor];
        sourceLabel.font=[UIFont systemFontOfSize:14.0];
        sourceLabel.text = _title;
        sourceLabel.textAlignment = NSTextAlignmentCenter;
        sourceLabel.numberOfLines = 2;
        [self addSubview:sourceLabel];
        [sourceLabel release];
    }
    return self;
}

- (void)showFileAlertViewInView:(UIView *)showView{
    if ([self superview] != showView){
        [showView addSubview:self];
    }
    
    [showView bringSubviewToFront:self];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.7];
    
    [self layoutIfNeeded];
}

- (void)dismiss{
    [self removeFromSuperview];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
}


@end
