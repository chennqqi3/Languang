//
//  ELCImagePreView.h
//  eCloud
//
//  Created by Pain on 14-4-21.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol ELCImagePreViewDelegate;

@interface ELCImagePreView : UIScrollView<UIScrollViewDelegate>{
    UIImageView *imageView;
    UIButton *_button;
    BOOL _isZoomed;
	NSTimer *_tapTimer;
    NSObject <ELCImagePreViewDelegate> *photoDelegate;
}
@property (nonatomic,readonly) UIImageView *imageView;
@property (nonatomic,assign) NSObject <ELCImagePreViewDelegate> *photoDelegate;

- (void)resetZoom;

@end

@protocol ELCImagePreViewDelegate

- (void)didTapELCImagePreView:(ELCImagePreView*)photoView;

@end