//
//  FGalleryPhotoView.h
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol FGalleryPhotoViewDelegate;

//@interface FGalleryPhotoView : UIImageView {
@interface FGalleryPhotoView : UIScrollView <UIScrollViewDelegate> {
	
	UIImageView *imageView;
    UIImageView *_nailImageView;
	UIActivityIndicatorView *_activity;
	UIButton *_button;
	BOOL _isZoomed;
	NSTimer *_tapTimer;
	NSObject <FGalleryPhotoViewDelegate> *photoDelegate;
    
    UIProgressView *_progressView;
    UILabel *_progressLab;
    NSInteger _expectedContentLength;
    NSInteger _currentContentLength;
}

- (void)killActivityIndicator;

// inits this view to have a button over the image
- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

- (void)resetZoom;

@property (nonatomic,assign) NSObject <FGalleryPhotoViewDelegate> *photoDelegate;
@property (nonatomic,readonly) UIImageView *imageView;
@property (nonatomic,readonly) UIImageView *nailImageView;
@property (nonatomic,readonly) UIButton *button;
@property (nonatomic,readonly) UIActivityIndicatorView *activity;
@property (nonatomic,readonly) UIProgressView *progressView;
@property (nonatomic,readonly) UILabel *progressLab;
@property (nonatomic) NSInteger expectedContentLength;
@property (nonatomic) NSInteger currentContentLength;

- (void)addDownloadProgressView;
- (void)showProgrossView;
- (void)hideProgrossView;
- (void)showNailImageView;
- (void)hideNailImageView;

- (void)setThumbnailImageViewFrame;
- (void)setFullsizeImageViewFrame;
@end



@protocol FGalleryPhotoViewDelegate

// indicates single touch and allows controller repsond and go toggle fullscreen
- (void)didTapPhotoView:(FGalleryPhotoView*)photoView;

@end

