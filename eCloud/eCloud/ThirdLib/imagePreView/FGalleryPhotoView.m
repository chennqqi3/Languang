//
//  FGalleryPhotoView.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "FGalleryPhotoView.h"

@interface FGalleryPhotoView (Private)
- (UIImage*)createHighlightImageWithFrame:(CGRect)rect;
- (void)killActivityIndicator;
- (void)startTapTimer;
- (void)stopTapTimer;
@end



@implementation FGalleryPhotoView
@synthesize photoDelegate;
@synthesize imageView;
@synthesize nailImageView = _nailImageView;
@synthesize activity = _activity;
@synthesize button = _button;
@synthesize progressView = _progressView;
@synthesize progressLab = _progressLab;
@synthesize expectedContentLength = _expectedContentLength;
@synthesize currentContentLength = _currentContentLength;

- (void)dealloc {
	[self stopTapTimer];
	
	[_button release];
	_button = nil;
	
	[self killActivityIndicator];
	
	[imageView release];
	imageView = nil;
    
    [_nailImageView release];
    _nailImageView = nil;
    
	[_progressView removeFromSuperview];
    [_progressView release];
    _progressView = nil;
    
    [_progressLab removeFromSuperview];
    [_progressLab release];
    _progressLab = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	self.userInteractionEnabled = YES;
	self.clipsToBounds = YES;
	self.delegate = self;
	self.contentMode = UIViewContentModeCenter;
	self.maximumZoomScale = 3.0;
	self.minimumZoomScale = 1.0;
	self.decelerationRate = .85;
	self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
	
    //小图
    _nailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 120.0)];
	_nailImageView.contentMode = UIViewContentModeScaleAspectFit;
//    _nailImageView.layer.borderWidth = 4.0;
//    _nailImageView.layer.cornerRadius = 4.0;
//    _nailImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _nailImageView.backgroundColor = [UIColor clearColor];
    _nailImageView.hidden = YES;
	[self addSubview:_nailImageView];
    
	// create the image view
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [imageView setClipsToBounds:YES];
	[self addSubview:imageView];
	
	// create an activity inidicator
	_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[_nailImageView addSubview:_activity];
	
    [self addDownloadProgressView];
    
	return self;
}


- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
	self = [self initWithFrame:frame];
	
	// fit them images!
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	// disable zooming
	self.minimumZoomScale = 1.0;
	self.maximumZoomScale = 1.0;
	
	// allow buttons to be clicked
	[self setUserInteractionEnabled:YES];
	
	// but don't allow zooming/panning
	self.scrollEnabled = NO;
	
	// create button
	_button = [[UIButton alloc] initWithFrame:CGRectZero];
	[_button setBackgroundColor:[UIColor clearColor]];
	[_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_button];
	
	// create outline
	[self.layer setBorderWidth:1.0];
	[self.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.25] CGColor]];
	
	return self;
}

- (void)resetZoom
{
	_isZoomed = NO;
	[self stopTapTimer];
	[self setZoomScale:self.minimumZoomScale animated:NO];
	[self zoomToRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height ) animated:NO];
	self.contentSize = CGSizeMake(self.frame.size.width * self.zoomScale, self.frame.size.height * self.zoomScale );
}

- (void)setFrame:(CGRect)theFrame
{
	// store position of the image view if we're scaled or panned so we can stay at that point
	CGPoint imagePoint = imageView.frame.origin;
	
	[super setFrame:theFrame];
	
	// update content size
	self.contentSize = CGSizeMake(theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale );
	
	// resize image view and keep it proportional to the current zoom scale
	imageView.frame = CGRectMake( imagePoint.x, imagePoint.y, theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale);
	
	// center the activity indicator
	//[_activity setCenter:CGPointMake(theFrame.size.width * .5, theFrame.size.height * .5)];
	
    _progressView.center = CGPointMake(theFrame.size.width * .5, theFrame.size.height * .5);
    _progressLab.center = CGPointMake(theFrame.size.width * .5, theFrame.size.height * .5 - 20.0);
    _nailImageView.center = CGPointMake(theFrame.size.width * .5, theFrame.size.height * .5 - 110.0);
    
    [_activity setCenter:CGPointMake(_nailImageView.frame.size.width * .5, _nailImageView.frame.size.height * .5)];
	// update button
	if( _button )
	{
		// resize the button
		_button.frame = CGRectMake(0, 0, theFrame.size.width, theFrame.size.height);
		
		// create a fresh image for button highlight state
		[_button setImage:[self createHighlightImageWithFrame:theFrame] forState:UIControlStateHighlighted];
	}
}


- (UIImage*)createHighlightImageWithFrame:(CGRect)rect
{
	if( rect.size.width == 0 || rect.size.height == 0 ) return nil;
	
	// create a tint layer for the selected state of the button
	UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
	CALayer *blankLayer = [CALayer layer];
	[blankLayer setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	[blankLayer setBackgroundColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:.4] CGColor]];
	[blankLayer renderInContext: UIGraphicsGetCurrentContext()];
	UIImage *clearImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return clearImg;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	
	if (touch.tapCount == 2) {
		[self stopTapTimer];
		
		if( _isZoomed ) 
		{
			_isZoomed = NO;
			[self setZoomScale:self.minimumZoomScale animated:YES];
		}
		else {
			
			_isZoomed = YES;
			
			// define a rect to zoom to. 
			CGPoint touchCenter = [touch locationInView:self];
			CGSize zoomRectSize = CGSizeMake(self.frame.size.width / self.maximumZoomScale, self.frame.size.height / self.maximumZoomScale );
			CGRect zoomRect = CGRectMake( touchCenter.x - zoomRectSize.width * .5, touchCenter.y - zoomRectSize.height * .5, zoomRectSize.width, zoomRectSize.height );
			
			// correct too far left
			if( zoomRect.origin.x < 0 )
				zoomRect = CGRectMake(0, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
			
			// correct too far up
			if( zoomRect.origin.y < 0 )
				zoomRect = CGRectMake(zoomRect.origin.x, 0, zoomRect.size.width, zoomRect.size.height );
			
			// correct too far right
			if( zoomRect.origin.x + zoomRect.size.width > self.frame.size.width )
				zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
			
			// correct too far down
			if( zoomRect.origin.y + zoomRect.size.height > self.frame.size.height )
				zoomRect = CGRectMake( zoomRect.origin.x, self.frame.size.height - zoomRect.size.height, zoomRect.size.width, zoomRect.size.height );
			
			// zoom to it.
			[self zoomToRect:zoomRect animated:YES];
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([[event allTouches] count] == 1 ) {
		UITouch *touch = [[event allTouches] anyObject];
		if( touch.tapCount == 1 ) {
			
			if(_tapTimer ) [self stopTapTimer];
			[self startTapTimer];
		}
	}
}

- (void)startTapTimer
{
	_tapTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:.5] interval:.5 target:self selector:@selector(handleTap) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:_tapTimer forMode:NSDefaultRunLoopMode];
	
}
- (void)stopTapTimer
{
	if([_tapTimer isValid])
		[_tapTimer invalidate];
	
	[_tapTimer release];
	_tapTimer = nil;
}

- (void)handleTap
{
	// tell the controller
	if(photoDelegate && [photoDelegate respondsToSelector:@selector(didTapPhotoView:)])
		[photoDelegate didTapPhotoView:self];
}

- (void)killActivityIndicator
{
	[_activity stopAnimating];
	[_activity removeFromSuperview];
	[_activity release];
	_activity = nil;
}

#pragma mark - 下载进度条
- (void)addDownloadProgressView{
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 100.0)];
    _progressView.progress = 0.0;
    _progressView.hidden = YES;
    _progressView.progressViewStyle = UIProgressViewStyleDefault;
    _progressView.progressTintColor = [UIColor colorWithRed:41.0/255 green:163.0/255 blue:230.0/255 alpha:1.0];
    _progressView.trackTintColor = [UIColor whiteColor];
    [self  addSubview:_progressView];
    
    _progressLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 20.0)];
    _progressLab.backgroundColor = [UIColor clearColor];
    _progressLab.textColor = [UIColor whiteColor];
    _progressLab.hidden = YES;
    _progressLab.text = @"正在下载0k/0k";
    _progressLab.font = [UIFont systemFontOfSize:12.0];
    _progressLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_progressLab];
}

- (void)showProgrossView{
    _progressView.hidden = NO;
    _progressLab.hidden = NO;
    _nailImageView.hidden = NO;
}

- (void)hideProgrossView{
    _progressView.hidden = YES;
    _progressLab.hidden = YES;
    _progressView.progress = 0.0;
    _progressLab.text = @"正在下载0k/0k";
}

- (void)showNailImageView{
    if ([_nailImageView isHidden]) {
        _nailImageView.hidden = NO;
    }
}

- (void)hideNailImageView{
    _nailImageView.image = nil;
    if (![_nailImageView isHidden]) {
        _nailImageView.hidden = YES;
    }
}


- (void)setThumbnailImageViewFrame{
    [imageView setFrame:CGRectMake(0, 0, 200.0, 260.0)];
    imageView.center = CGPointMake(160.0, 200.0);
}

- (void)setFullsizeImageViewFrame{
    [imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}


#pragma mark - UIScrollViewDelegate 协议方法
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //[self resetZoom];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	if( self.zoomScale == self.minimumZoomScale ) _isZoomed = NO;
	else _isZoomed = YES;
}


@end
