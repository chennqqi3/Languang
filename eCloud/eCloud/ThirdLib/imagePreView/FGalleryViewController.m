    //
//  FGalleryViewController.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "FGalleryViewController.h"
#import "GXViewController.h"
#import "PictureUtil.h"
#import "eCloudDefine.h"
#import "personInfoViewController.h"
#import "DisplayPicViewController.h"

#import "ChatBackgroundUtil.h"

#import "UserDefaults.h"

#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "talkSessionViewController.h"
#import "chatBackgroudViewController.h"
#import "StringUtil.h"
#import "ConvRecord.h"
#import "eCloudDAO.h"
#import "ForwardingRecentViewController.h"
#import "AppDelegate.h"
#import "UserTipsUtil.h"

#define kThumbnailSize 75
#define kThumbnailSpacing 4
#define kCaptionPadding 3
#define kToolbarHeight 40


@interface FGalleryViewController (Private)<ForwardingDelegate>
// general
- (void)buildViews;
- (void)destroyViews;
- (void)layoutViews;
- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation;
- (void)updateTitle;
- (void)updateButtons;
- (void)layoutButtons;
- (void)updateScrollSize;
- (void)updateCaption;
- (void)resizeImageViewsWithRect:(CGRect)rect;
- (void)resetImageViewZoomLevels;

- (void)enterFullscreen;
- (void)exitFullscreen;
- (void)enableApp;
- (void)disableApp;

- (void)positionInnerContainer;
- (void)positionScroller;
- (void)positionToolbar;
- (void)resizeThumbView;

// thumbnails
- (void)toggleThumbnailViewWithAnimation:(BOOL)animation;
- (void)showThumbnailViewWithAnimation:(BOOL)animation;
- (void)hideThumbnailViewWithAnimation:(BOOL)animation;
- (void)buildThumbsViewPhotos;

- (void)arrangeThumbs;
- (void)loadAllThumbViewPhotos;

- (void)preloadThumbnailImages;
- (void)unloadFullsizeImageWithIndex:(NSUInteger)index;

- (void)scrollingHasEnded;

- (void)handleSeeAllTouch:(id)sender;
- (void)handleThumbClick:(id)sender;

- (FGalleryPhoto*)createGalleryPhotoForIndex:(NSUInteger)index;

- (void)loadThumbnailImageWithIndex:(NSUInteger)index;
- (void)loadFullsizeImageWithIndex:(NSUInteger)index;

@end



@implementation FGalleryViewController{
    eCloudDAO *_ecloud ;
    
    DisplayPicViewController *displayPic;
    
//    是否显示导航栏
    BOOL displayNavigationBar;
    
}
@synthesize needDisplaySwitchButton;
@synthesize galleryID;
@synthesize photoSource = _photoSource;
@synthesize forwardRecord;
@synthesize currentIndex = _currentIndex;
@synthesize thumbsView = _thumbsView;
@synthesize toolBar = _toolbar;
@synthesize useThumbnailView = _useThumbnailView;
@synthesize startingIndex = _startingIndex;
@synthesize beginsInThumbnailView = _beginsInThumbnailView;
@synthesize hideTitle = _hideTitle;
@synthesize imagePath;
@synthesize is_from_chatbackgroud;
@synthesize one_chat_imagename;
@synthesize predelegete;
#pragma mark - Public Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if((self = [super initWithNibName:nil bundle:nil])) {
	
		// init gallery id with our memory address
		self.galleryID						= [NSString stringWithFormat:@"%p", self];

        // configure view controller
		//self.hidesBottomBarWhenPushed		= YES;
        
        // set defaults
        _useThumbnailView                   = YES;
//		_prevStatusStyle					= [[UIApplication sharedApplication] statusBarStyle];
        _hideTitle                          = NO;
		
		// create storage objects
		_currentIndex						= 0;
        _startingIndex                      = 0;
		_photoLoaders						= [[NSMutableDictionary alloc] init];
		_photoViews							= [[NSMutableArray alloc] init];
		_photoThumbnailViews				= [[NSMutableArray alloc] init];
		_barItems							= [[NSMutableArray alloc] init];
        
        /*
         // debugging: 
         _container.layer.borderColor = [[UIColor yellowColor] CGColor];
         _container.layer.borderWidth = 1.0;
         
         _innerContainer.layer.borderColor = [[UIColor greenColor] CGColor];
         _innerContainer.layer.borderWidth = 1.0;
         
         _scroller.layer.borderColor = [[UIColor redColor] CGColor];
         _scroller.layer.borderWidth = 2.0;
         */
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self != nil) {
		self.galleryID						= [NSString stringWithFormat:@"%p", self];
		
        // configure view controller
		//self.hidesBottomBarWhenPushed		= YES;
        
        // set defaults
        _useThumbnailView                   = YES;
//		_prevStatusStyle					= [[UIApplication sharedApplication] statusBarStyle];
        _hideTitle                          = NO;
		
		// create storage objects
		_currentIndex						= 0;
        _startingIndex                      = 0;
		_photoLoaders						= [[NSMutableDictionary alloc] init];
		_photoViews							= [[NSMutableArray alloc] init];
		_photoThumbnailViews				= [[NSMutableArray alloc] init];
		_barItems							= [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc withCurrentIndex:(NSInteger) currentIndex{
    if((self = [self initWithNibName:nil bundle:nil])) {
		_currentIndex = currentIndex;
        _startingIndex = _currentIndex;
		_photoSource = photoSrc;
        displayNavigationBar = NO;
        if ([photoSrc isKindOfClass:[PictureUtil class]]) {
            displayNavigationBar = YES;
        }
	}
	return self;
}

- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc
{
	if((self = [self initWithNibName:nil bundle:nil])) {
		
		_photoSource = photoSrc;
	}
	return self;
}


- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc barItems:(NSArray*)items
{
	if((self = [self initWithPhotoSource:photoSrc])) {
		
		[_barItems addObjectsFromArray:items];
	}
	return self;
}


- (void)loadView
{
    // create public objects first so they're available for custom configuration right away. positioning comes later.
    _container							= [[UIView alloc] initWithFrame:CGRectZero];
    _innerContainer						= [[UIView alloc] initWithFrame:CGRectZero];
    _scroller							= [[UIScrollView alloc] initWithFrame:CGRectZero];
    _thumbsView							= [[UIScrollView alloc] initWithFrame:CGRectZero];
    _toolbar							= [[UIToolbar alloc] initWithFrame:CGRectZero];
    _toolbar.hidden = YES;
    _captionContainer					= [[UIView alloc] initWithFrame:CGRectZero];
    _caption							= [[UILabel alloc] initWithFrame:CGRectZero];
    
    _toolbar.barStyle					= UIBarStyleBlackTranslucent;
    _container.backgroundColor			= [UIColor blackColor];
    
    // listen for container frame changes so we can properly update the layout during auto-rotation or going in and out of fullscreen
    [_container addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    // setup scroller
    _scroller.delegate							= self;
    _scroller.tag = 2;
    _scroller.pagingEnabled						= YES;
    _scroller.showsVerticalScrollIndicator		= NO;
    _scroller.showsHorizontalScrollIndicator	= NO;
    _scroller.decelerationRate = 1.0;
    _scroller.alwaysBounceHorizontal = YES;
    // setup caption
    _captionContainer.backgroundColor			= [UIColor colorWithWhite:0.0 alpha:.35];
    _captionContainer.hidden					= YES;
    _captionContainer.userInteractionEnabled	= NO;
    _captionContainer.exclusiveTouch			= YES;
    _caption.font								= [UIFont systemFontOfSize:14.0];
    _caption.textColor							= [UIColor whiteColor];
    _caption.backgroundColor					= [UIColor clearColor];
    _caption.textAlignment						= NSTextAlignmentCenter;
    _caption.shadowColor						= [UIColor blackColor];
    _caption.shadowOffset						= CGSizeMake( 1, 1 );
    
    // make things flexible
    _container.autoresizesSubviews				= NO;
    _innerContainer.autoresizesSubviews			= NO;
    _scroller.autoresizesSubviews				= NO;
    _container.autoresizingMask					= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // setup thumbs view
    _thumbsView.backgroundColor					= [UIColor whiteColor];
    _thumbsView.hidden							= YES;
    _thumbsView.contentInset					= UIEdgeInsetsMake( kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing);
    
	// set view
	self.view                                   = _container;
	
	// add items to their containers
	[_container addSubview:_innerContainer];
	[_container addSubview:_thumbsView];
	
	[_innerContainer addSubview:_scroller];
	[_innerContainer addSubview:_toolbar];
	
	[_toolbar addSubview:_captionContainer];
	[_captionContainer addSubview:_caption];
	
	// create buttons for toolbar
	UIImage *leftIcon = [StringUtil getImageByResName:@"photo-gallery-left.png"];
	UIImage *rightIcon = [StringUtil getImageByResName:@"photo-gallery-right.png"];
	_nextButton = [[UIBarButtonItem alloc] initWithImage:rightIcon style:UIBarButtonItemStylePlain target:self action:@selector(next)];
	_prevButton = [[UIBarButtonItem alloc] initWithImage:leftIcon style:UIBarButtonItemStylePlain target:self action:@selector(previous)];
	
	// add prev next to front of the array
	[_barItems insertObject:_nextButton atIndex:0];
	[_barItems insertObject:_prevButton atIndex:0];
	
	_prevNextButtonSize = leftIcon.size.width;
	
	// set buttons on the toolbar.
	[_toolbar setItems:_barItems animated:NO];
    
    if (self.needDisplaySwitchButton) {
        //    增加switchButton
        _switchButton = [[[UIButton alloc]initWithFrame:CGRectZero]autorelease];
        [_switchButton setImage:[StringUtil getImageByResName:@"switch_to_thumb_list.png"] forState:UIControlStateNormal];
        [_switchButton addTarget:self action:@selector(switchPicView:) forControlEvents:UIControlEventTouchUpInside];
        [_container addSubview:_switchButton];
    }
    
    // build stuff
    [self reloadGallery];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        //适配ios7 UIScrollView
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _ecloud = [eCloudDAO getDatabase] ;
}

- (void)viewDidUnload {
    
    [self destroyViews];
    
    [_barItems release], _barItems = nil;
    [_nextButton release], _nextButton = nil;
    [_prevButton release], _prevButton = nil;
    [_container release], _container = nil;
    [_innerContainer release], _innerContainer = nil;
    [_scroller release], _scroller = nil;
    [_thumbsView release], _thumbsView = nil;
    [_toolbar release], _toolbar = nil;
    [_captionContainer release], _captionContainer = nil;
    [_caption release], _caption = nil;
    
    [super viewDidUnload];
}


- (void)destroyViews {
    // remove previous photo views
    for (UIView *view in _photoViews) {
        [view removeFromSuperview];
    }
    [_photoViews removeAllObjects];
    
    // remove previous thumbnails
    for (UIView *view in _photoThumbnailViews) {
        [view removeFromSuperview];
    }
    [_photoThumbnailViews removeAllObjects];
    
    // remove photo loaders
    NSArray *photoKeys = [_photoLoaders allKeys];
    for (int i=0; i<[photoKeys count]; i++) {
        FGalleryPhoto *photoLoader = [_photoLoaders objectForKey:[photoKeys objectAtIndex:i]];
        photoLoader.delegate = nil;
        [photoLoader unloadFullsize];
        [photoLoader unloadThumbnail];
    }
    [_photoLoaders removeAllObjects];
}


- (void)reloadGallery
{
    _isThumbViewShowing = NO;
    
    // remove the old
    [self destroyViews];
    
    // build the new
    if ([_photoSource numberOfPhotosForPhotoGallery:self] > 0) {
        // create the image views for each photo
        [self buildViews];
        
        // create the thumbnail views
        [self buildThumbsViewPhotos];
        
        // start loading thumbs
        //[self preloadThumbnailImages];
        
        // start on first image
        [self gotoImageByIndex:_currentIndex animated:NO];
        
        // layout
        [self layoutViews];
    }
}

- (FGalleryPhoto*)currentPhoto
{
    return [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", _currentIndex]];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (displayPic) {
        if (displayPic.selectedIndex || displayPic.selectedIndex == 0) {
            self.currentIndex = displayPic.selectedIndex;
        }
    }
    if (self.photoSource && ([self.photoSource isKindOfClass:[talkSessionViewController class]] || [self.photoSource isKindOfClass:[DisplayPicViewController class]]|| [self.photoSource isKindOfClass:[personInfoViewController class]])) {
        [[UIApplication sharedApplication] setStatusBarHidden: YES];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }

#ifdef _XIANGYUAN_FLAG_
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
#endif
    
//    
//    [self.navigationController setNavigationBarHidden:YES];
	
    _isActive = YES;
    
    self.useThumbnailView = _useThumbnailView;
	
    // toggle into the thumb view if we should start there
    if (_beginsInThumbnailView && _useThumbnailView) {
        [self showThumbnailViewWithAnimation:NO];
        [self loadAllThumbViewPhotos];
    }
    
	[self layoutViews];
	
	// update status bar to be see-through
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
	
	// init with next on first run.
	if( _currentIndex == -1 ){
        [self next];
    }
	else {
        [self gotoImageByIndex:_currentIndex animated:NO];
    }
    if ([UIAdapterUtil isHongHuApp]){
        
        [UIAdapterUtil hideTabBar:self];
    }
#ifdef _LONGHU_FLAG_
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = 1;
#endif
    
#ifdef _XIANGYUAN_FLAG_
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    _isActive = YES;
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
	_isActive = NO;

//	[[UIApplication sharedApplication] setStatusBarStyle:_prevStatusStyle animated:animated];
}


- (void)resizeImageViewsWithRect:(CGRect)rect
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	float dx = 0;
	for (i = 0; i < count; i++) {
		FGalleryPhotoView * photoView = [_photoViews objectAtIndex:i];
		photoView.frame = CGRectMake(dx, 0, rect.size.width, rect.size.height );
		dx += rect.size.width;
	}
}


- (void)resetImageViewZoomLevels
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView * photoView = [_photoViews objectAtIndex:i];
		[photoView resetZoom];
	}
}


- (void)removeImageAtIndex:(NSUInteger)index
{
	// remove the image and thumbnail at the specified index.
	FGalleryPhotoView *imgView = [_photoViews objectAtIndex:index];
 	FGalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:index];
	FGalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i",index]];
	
	[photo unloadFullsize];
	[photo unloadThumbnail];
	
	[imgView removeFromSuperview];
	[thumbView removeFromSuperview];
	
	[_photoViews removeObjectAtIndex:index];
	[_photoThumbnailViews removeObjectAtIndex:index];
	[_photoLoaders removeObjectForKey:[NSString stringWithFormat:@"%i",index]];
	
	[self layoutViews];
	[self updateButtons];
    [self updateTitle];
}


- (void)next
{
	NSUInteger numberOfPhotos = [_photoSource numberOfPhotosForPhotoGallery:self];
	NSUInteger nextIndex = _currentIndex+1;
	
	// don't continue if we're out of images.
	if( nextIndex <= numberOfPhotos )
	{
		[self gotoImageByIndex:nextIndex animated:NO];
	}
}



- (void)previous
{
	NSUInteger prevIndex = _currentIndex-1;
	[self gotoImageByIndex:prevIndex animated:NO];
}



- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated
{
	NSUInteger numPhotos = [_photoSource numberOfPhotosForPhotoGallery:self];
	
	// constrain index within our limits
    if( index >= numPhotos ) index = numPhotos - 1;
	
	if( numPhotos == 0 ) {
		
		// no photos!
		_currentIndex = -1;
	}
	else {
		
		// clear the fullsize image in the old photo
		[self unloadFullsizeImageWithIndex:_currentIndex];
		
		_currentIndex = index;
		[self moveScrollerToCurrentIndexWithAnimation:animated];
		[self updateTitle];
		
		if( !animated )	{
//            [self loadFullsizeImageWithIndex:index];
			//[self preloadThumbnailImages];
            [self preLoadFullSizeImage];
		}
	}
	[self updateButtons];
	[self updateCaption];
}


- (void)layoutViews
{
	[self positionInnerContainer];
	[self positionScroller];
	[self resizeThumbView];
    if (self.needDisplaySwitchButton) {
        [self positionSwitchButton];        
    }
	[self positionToolbar];
	[self updateScrollSize];
	[self updateCaption];
	[self resizeImageViewsWithRect:_scroller.frame];
	[self layoutButtons];
	[self arrangeThumbs];
	[self moveScrollerToCurrentIndexWithAnimation:NO];
}


/*
- (void)setUseThumbnailView:(BOOL)useThumbnailView
{
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back", @"") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    
    _useThumbnailView = useThumbnailView;
    if( self.navigationController ) {
        if (_useThumbnailView) {
            UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", @"") style:UIBarButtonItemStyleDone target:self action:@selector(handleSaveTouch:)] autorelease];
            [self.navigationItem setRightBarButtonItem:btn animated:YES];
        }
        else {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
    }
}
*/

- (void)setUseThumbnailView:(BOOL)useThumbnailView
{
    _useThumbnailView = useThumbnailView;
    if( self.navigationController ) {
        if (_useThumbnailView) {
            self.view.backgroundColor=[UIColor blackColor];
            
            [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
            
            if (self.is_from_chatbackgroud) {
            [UIAdapterUtil setRightButtonItemWithTitle:@"使用" andTarget:self andSelector:@selector(handleSaveTouch:)];
            }else
            {
            [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_save"]andTarget:self andSelector:@selector(handleSaveTouch:)];
            }
            
            
        }
        else {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
    }
}

-(void)backButtonPressed:(id)sender
{
    if (_photoSource && [_photoSource respondsToSelector:@selector(photoGalleryClickOnBackBtn:)]) {
        [_photoSource photoGalleryClickOnBackBtn:self];
    }
    
    [self.navigationController popViewControllerAnimated: YES];
}


- (void)switchPicView:(id)sender
{
    if (displayPic) {
        [displayPic release];
        displayPic = nil;
    }
    displayPic = [[DisplayPicViewController alloc]init];
    displayPic.convId = self.convId;
    displayPic.selectedIndex = self.currentIndex;
    
    [self exitFullscreen];
    UINavigationController *navigation = [[[UINavigationController alloc]initWithRootViewController:displayPic]autorelease];
    [UIAdapterUtil presentVC:navigation];
//    [self.navigationController presentViewController:navigation animated:YES completion:^{
//        NSLog(@"%s",__FUNCTION__);
//    }];
}


#pragma mark - Private Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"frame"]) 
	{
		[self layoutViews];
	}
}


- (void)positionInnerContainer
{
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect innerContainerRect;
	
	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{//portrait
		innerContainerRect = CGRectMake( 0, _container.frame.size.height - screenFrame.size.height, _container.frame.size.width, screenFrame.size.height );
	}
	else 
	{// landscape
		innerContainerRect = CGRectMake( 0, _container.frame.size.height - screenFrame.size.width, _container.frame.size.width, screenFrame.size.width );
	}
	
//	_innerContainer.frame = innerContainerRect;
    _innerContainer.frame = screenFrame;
}


- (void)positionScroller
{
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect scrollerRect;
	
	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{//portrait
		scrollerRect = CGRectMake( 0, 0, screenFrame.size.width, screenFrame.size.height );
	}
	else
	{//landscape
		scrollerRect = CGRectMake( 0, 0, screenFrame.size.height, screenFrame.size.width );
	}
	
//	_scroller.frame = scrollerRect;
    _scroller.frame = screenFrame;
}


- (void)positionToolbar
{
	_toolbar.frame = CGRectMake( 0, _scroller.frame.size.height-kToolbarHeight, _scroller.frame.size.width, kToolbarHeight );
}

//定义switchbutton的位置
- (void)positionSwitchButton
{
//    NSLog(@"%s container is %@",__FUNCTION__,NSStringFromCGRect(_container.frame));
    
    _switchButton.frame = CGRectMake(_container.frame.size.width - 90, _container.frame.size.height - 60, 90, 60);
}

- (void)resizeThumbView
{
    int barHeight = 0;
    if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent) {
        barHeight = self.navigationController.navigationBar.frame.size.height;
    }
	_thumbsView.frame = CGRectMake( 0, barHeight, _container.frame.size.width, _container.frame.size.height-barHeight );
}


- (void)enterFullscreen
{
    if (!_isThumbViewShowing && !displayNavigationBar)
    {
        _isFullscreen = YES;
        
        /*
        [self disableApp];
        
        UIApplication* application = [UIApplication sharedApplication];
        if ([application respondsToSelector: @selector(setStatusBarHidden:withAnimation:)]) {
            [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation: UIStatusBarAnimationFade]; // 3.2+
        } else {
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarHidden: YES animated:YES]; // 2.0 - 3.2
    #pragma GCC diagnostic warning "-Wdeprecated-declarations"
        }
        
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        //[self.navigationController.navigationBar setFrame:CGRectMake(0.0, -80.0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
        
        
        [UIView beginAnimations:@"galleryOut" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(enableApp)];
        [UIView setAnimationDuration:0.6];
//        _toolbar.alpha = 0.0;
//        _captionContainer.alpha = 0.0;
        //[_innerContainer setFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [UIView commitAnimations];
         */
        
        [[UIApplication sharedApplication] setStatusBarHidden: YES];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}



- (void)exitFullscreen
{
	_isFullscreen = NO;
    
    /*
	[self disableApp];
    
	UIApplication* application = [UIApplication sharedApplication];
	if ([application respondsToSelector: @selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; // 3.2+
	} else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO]; // 2.0 - 3.2
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
	}

	[self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self.navigationController.navigationBar setFrame:CGRectMake(0.0, [UIApplication sharedApplication].statusBarFrame.size.height, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
	[UIView beginAnimations:@"galleryIn" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(enableApp)];
    [UIView setAnimationDuration:0.6];
//	_toolbar.alpha = 1.0;
//	_captionContainer.alpha = 1.0;
    //[_innerContainer setFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	[UIView commitAnimations];
    */
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}



- (void)enableApp
{
  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void)disableApp
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


- (void)didTapPhotoView:(FGalleryPhotoView*)photoView
{
	// don't change when scrolling
	if( _isScrolling || !_isActive ) return;
	
	// toggle fullscreen.
//	if( _isFullscreen == NO ) {
//		
//		[self enterFullscreen];
//	}
//	else {
//		
//		[self exitFullscreen];
//	}
    
    [self exitFullscreen];
    [self dimissFGalleryViewController];
    photoView.photoDelegate = nil;
}


- (void)updateCaption
{
	if([_photoSource numberOfPhotosForPhotoGallery:self] > 0 )
	{
		if([_photoSource respondsToSelector:@selector(photoGallery:captionForPhotoAtIndex:)])
		{
			NSString *caption = [_photoSource photoGallery:self captionForPhotoAtIndex:_currentIndex];
			
			if([caption length] > 0 )
			{
				float captionWidth = _container.frame.size.width-kCaptionPadding*2;
				CGSize textSize = [caption sizeWithFont:_caption.font];
				NSUInteger numLines = ceilf( textSize.width / captionWidth );
				NSInteger height = ( textSize.height + kCaptionPadding ) * numLines;
				
				_caption.numberOfLines = numLines;
				_caption.text = caption;
				
				NSInteger containerHeight = height+kCaptionPadding*2;
				_captionContainer.frame = CGRectMake(0, -containerHeight, _container.frame.size.width, containerHeight );
				_caption.frame = CGRectMake(kCaptionPadding, kCaptionPadding, captionWidth, height );
				
				// show caption bar
				_captionContainer.hidden = NO;
			}
			else {
				
				// hide it if we don't have a caption.
				_captionContainer.hidden = YES;
			}
		}
	}
}


- (void)updateScrollSize
{
	float contentWidth = _scroller.frame.size.width * [_photoSource numberOfPhotosForPhotoGallery:self];
	[_scroller setContentSize:CGSizeMake(contentWidth, _scroller.frame.size.height)];
}


- (void)updateTitle
{
    if (!_hideTitle){
        if ([_photoSource numberOfPhotosForPhotoGallery:self] > 1) {
            [self setTitle:[NSString stringWithFormat:@"%i %@ %i", _currentIndex+1, NSLocalizedString(@"/", @"") , [_photoSource numberOfPhotosForPhotoGallery:self]]];
        }
        else{
            [self setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_preview"]];  if (self.is_from_chatbackgroud) {[self setTitle:@""];}
        }
    }else{
        [self setTitle:@""];
    }
}


- (void)updateButtons
{
	_prevButton.enabled = ( _currentIndex <= 0 ) ? NO : YES;
	_nextButton.enabled = ( _currentIndex >= [_photoSource numberOfPhotosForPhotoGallery:self]-1 ) ? NO : YES;
}


- (void)layoutButtons
{
	NSUInteger buttonWidth = roundf( _toolbar.frame.size.width / [_barItems count] - _prevNextButtonSize * .5);
	
	// loop through all the button items and give them the same width
	NSUInteger i, count = [_barItems count];
	for (i = 0; i < count; i++) {
		UIBarButtonItem *btn = [_barItems objectAtIndex:i];
		btn.width = buttonWidth;
	}
	[_toolbar setNeedsLayout];
}


- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation
{
	int xp = _scroller.frame.size.width * _currentIndex;
	[_scroller scrollRectToVisible:CGRectMake(xp, 0, _scroller.frame.size.width, _scroller.frame.size.height) animated:animation];
	_isScrolling = animation;
}


// creates all the image views for this gallery
- (void)buildViews
{
	NSUInteger i, count = [_photoSource numberOfPhotosForPhotoGallery:self];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView *photoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero];
		photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		photoView.autoresizesSubviews = YES;
		photoView.photoDelegate = self;
        
        UILongPressGestureRecognizer *longPgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longForSavePicture:)];
        longPgr.minimumPressDuration = 0.5f;
        
        longPgr.numberOfTouchesRequired = 1;
        [photoView addGestureRecognizer:longPgr];
        [longPgr release];
		[_scroller addSubview:photoView];
		[_photoViews addObject:photoView];
		[photoView release];
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    [[actionSheet layer] setBackgroundColor:[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1].CGColor];
}

- (void)longForSavePicture:(UILongPressGestureRecognizer *)longPgr{
    if (longPgr.state == UIGestureRecognizerStateBegan) {
        if (IOS8_OR_LATER && IS_IPHONE) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *savePicAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"save_image"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self savePicToAlbum];
            }];
            
            UIAlertAction *sendPicToSomeoneAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"send_to_someone"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self sendPicToSomeone];
            }];
            
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            }];
            
            [alert addAction:savePicAction];
            [alert addAction:sendPicToSomeoneAction];
            [alert addAction:cancelAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIActionSheet *menu = [[UIActionSheet alloc]
                                   initWithTitle:nil
                                   delegate:self
                                   cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                                   destructiveButtonTitle:nil
                                   otherButtonTitles:[StringUtil getLocalizableString:@"save_image"],[StringUtil getLocalizableString:@"send_to_someone"], nil];
            [menu showInView:self.view];
        }
    }
}

//长按保存图片
- (void)savePicToAlbum
{
    // 保存到相册中
    UIImage *image = [[_photoViews objectAtIndex:_currentIndex] imageView].image;
    if (image != nil) {
        UIImageWriteToSavedPhotosAlbum([[_photoViews objectAtIndex:_currentIndex] imageView].image, self,nil, nil);//存入相册
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_save_success"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    }
    else{
        //本地图片不存在
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"图片未下载,保存失败" message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
}

//长按转发图片
- (void)sendPicToSomeone
{
    ConvRecord *_convRecord = nil;
    
    FGalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)_currentIndex]];
    UIImage *image = [photo getLocalFullImage];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,image is %@,image size is %@",__FUNCTION__,image,NSStringFromCGSize(image.size)]];
    
    //首先把当前正在浏览的图片保存到文件目录下，然后创造一个临时的ConvRecord，把这个作为要转发的记录发送出去
    NSString *currenttimeStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
    
    //存入本地
    NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    if (imageData) {
        BOOL success = [imageData writeToFile:picpath atomically:YES];
        if (success) {
            _convRecord = [[ConvRecord alloc]init];
            _convRecord.msg_type = type_pic;
            _convRecord.msg_body = currenttimeStr;
            self.forwardRecord = _convRecord;
            [_convRecord release];
        }
    }
    if (_convRecord) {
        [self openRecentContacts];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self savePicToAlbum];
    }else if(buttonIndex == 1){
        [self sendPicToSomeone];
    }
    [actionSheet release];
}

#pragma mark - 发送给朋友（借用转发功能）
//打开最近的联系人，用来转发
- (void)openRecentContacts
{
    ForwardingRecentViewController *forwarding=[[ForwardingRecentViewController alloc]initWithConvRecord:self.forwardRecord];
    forwarding.fromType = transfer_from_image_preview;
    forwarding.forwardingDelegate = self;
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:forwarding];
    [forwarding release];
    nav.navigationBar.tintColor=[UIColor blackColor];
    [UIAdapterUtil presentVC:nav];
//    [self presentModalViewController:nav animated:YES];
    [nav release];
}

#pragma mark =======转发提示=========
- (void)showTransferTips
{
    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}

- (void)showForwardTips
{
    [UserTipsUtil showForwardTips];
}

- (void)dismissLoadingView
{
    [UserTipsUtil hideLoadingView];
}

- (void)buildThumbsViewPhotos
{
	NSUInteger i, count = [_photoSource numberOfPhotosForPhotoGallery:self];
	for (i = 0; i < count; i++) {
		
		FGalleryPhotoView *thumbView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero target:self action:@selector(handleThumbClick:)];
		[thumbView setContentMode:UIViewContentModeScaleAspectFill];
		[thumbView setClipsToBounds:YES];
		[thumbView setTag:i];
		[_thumbsView addSubview:thumbView];
		[_photoThumbnailViews addObject:thumbView];
		[thumbView release];
	}
}



- (void)arrangeThumbs
{
	float dx = 0.0;
	float dy = 0.0;
	// loop through all thumbs to size and place them
	NSUInteger i, count = [_photoThumbnailViews count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:i];
		[thumbView setBackgroundColor:[UIColor grayColor]];
		
		// create new frame
		thumbView.frame = CGRectMake( dx, dy, kThumbnailSize, kThumbnailSize);
		
		// increment position
		dx += kThumbnailSize + kThumbnailSpacing;
		
		// check if we need to move to a different row
		if( dx + kThumbnailSize + kThumbnailSpacing > _thumbsView.frame.size.width - kThumbnailSpacing )
		{
			dx = 0.0;
			dy += kThumbnailSize + kThumbnailSpacing;
		}
	}
	
	// set the content size of the thumb scroller
	[_thumbsView setContentSize:CGSizeMake( _thumbsView.frame.size.width - ( kThumbnailSpacing*2 ), dy + kThumbnailSize + kThumbnailSpacing )];
}


- (void)toggleThumbnailViewWithAnimation:(BOOL)animation
{
    if (_isThumbViewShowing) {
        [self hideThumbnailViewWithAnimation:animation];
    }
    else {
        [self showThumbnailViewWithAnimation:animation];
    }
}


- (void)showThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = YES;
    
    [self arrangeThumbs];
    [self.navigationItem.rightBarButtonItem setTitle:[StringUtil getLocalizableString:@"Close"]];
    
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"uncurl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:_thumbsView cache:YES];
        [_thumbsView setHidden:NO];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}


- (void)hideThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = NO;
    [self.navigationItem.rightBarButtonItem setTitle:[StringUtil getLocalizableString:@"save"]];
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"curl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:_thumbsView cache:YES];
        [_thumbsView setHidden:YES];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}

- (void)handleSaveTouch:(id)sender
{
    /*
    //2014-3-6以前的
	// show thumb view
	[self toggleThumbnailViewWithAnimation:YES];
	
	// tell thumbs that havent loaded to load
	[self loadAllThumbViewPhotos];
     */
    if (self.is_from_chatbackgroud) {
        //存入本地
        NSString *picpath = [ChatBackgroundUtil getCommonBackgroundPath];
        if (self.one_chat_imagename.length>0) {
            picpath = [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:self.one_chat_imagename];
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSLog(@"imagePath : %@ \n  picpath: %@",self.imagePath,picpath);
        BOOL success1 = [fileManager fileExistsAtPath:picpath];
        if (success1) {
        if ([fileManager removeItemAtPath:picpath error:&error] != YES)
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        if ([fileManager moveItemAtPath:self.imagePath toPath:picpath error:&error] != YES)
        {
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
        }
        
        NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
        [accountDefaults setBool:YES forKey:@"is_chat_backgroud_change"];
      // [self.navigationController popViewControllerAnimated: YES];
       
        if (self.one_chat_imagename.length>0) {
            
            //从图片库中选择聊天背景时，把和会话对应的背景对应的value设置为-1 否则还是显示为某一个被选中
            [UserDefaults setConvBackgroundSelected:[[talkSessionViewController getTalkSession] getConvid] andSelectTag:-1];

            [self.parentViewController dismissModalViewControllerAnimated:YES];
            [((chatBackgroudViewController*)self.predelegete) backToTalkSession];
        }else
        {
             //从图片库中选择聊天背景时，把和默认背景对应的value设置为-1 否则还是显示为某一个被选中
            [UserDefaults setBackgroundSelected:-1];
         [self.parentViewController dismissModalViewControllerAnimated:YES];
        }

        return;
    }
    
    
    UIImage *image = [[_photoViews objectAtIndex:_currentIndex] imageView].image;
    if (image != nil) {
        UIImageWriteToSavedPhotosAlbum([[_photoViews objectAtIndex:_currentIndex] imageView].image, self,nil, nil);//存入相册
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_save_success"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    }
    else{
        //本地图片不存在
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"图片未下载,保存失败" message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}


- (void)handleThumbClick:(id)sender
{
	FGalleryPhotoView *photoView = (FGalleryPhotoView*)[(UIButton*)sender superview];
	[self hideThumbnailViewWithAnimation:YES];
	[self gotoImageByIndex:photoView.tag animated:NO];
}


#pragma mark - Image Loading


- (void)preloadThumbnailImages
{
	NSUInteger index = _currentIndex;
	NSUInteger count = [_photoViews count];
    
	// make sure the images surrounding the current index have thumbs loading
	NSUInteger nextIndex = index + 1;
	NSUInteger prevIndex = index - 1;
	
	// the preload count indicates how many images surrounding the current photo will get preloaded.
	// a value of 2 at maximum would preload 4 images, 2 in front of and two behind the current image.
	NSUInteger preloadCount = 1;
	
	FGalleryPhoto *photo;
	
	// check to see if the current image thumb has been loaded
	photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", index]];
	
	if(!photo)
	{
		[self loadThumbnailImageWithIndex:index];
		photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", index]];
	}
	
	if(!photo.hasThumbLoaded && !photo.isThumbLoading)
	{
		[photo loadThumbnail];
	}
	
	NSUInteger curIndex = prevIndex;
	while( curIndex > -1 && curIndex > prevIndex - preloadCount )
	{
		photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", curIndex]];
		
		if( !photo) {
			[self loadThumbnailImageWithIndex:curIndex];
			photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", curIndex]];
		}
		
		if( !photo.hasThumbLoaded && !photo.isThumbLoading )
		{
			[photo loadThumbnail];
		}
		
		curIndex--;
	}
	
	curIndex = nextIndex;
	while( curIndex < count && curIndex < nextIndex + preloadCount )
	{
		photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", curIndex]];
		
		if( !photo) {
			[self loadThumbnailImageWithIndex:curIndex];
			photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", curIndex]];
		}
		
		if( !photo.hasThumbLoaded && !photo.isThumbLoading)
		{
			[photo loadThumbnail];
		}
		
		curIndex++;
	}
}


- (void)loadAllThumbViewPhotos
{
	NSUInteger i, count = [_photoSource numberOfPhotosForPhotoGallery:self];
	for (i=0; i < count; i++) {
		
		[self loadThumbnailImageWithIndex:i];
	}
}


- (void)loadThumbnailImageWithIndex:(NSUInteger)index
{
	FGalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", index]];

	if( photo == nil )
		photo = [self createGalleryPhotoForIndex:index];
	FGalleryPhotoView *photoView = [_photoViews objectAtIndex:index];
    UIImage *image = [photo getLocalThumbImage];
    if (image) {
        // if the gallery photo hasn't loaded the fullsize yet, set the thumbnail as its image.
        if( !photo.hasFullsizeLoaded ){
            photoView.nailImageView.image = image;
        }
    }
    else{
        //从网络下载小图
        [photo loadThumbnail];
    }
}


- (void)loadFullsizeImageWithIndex:(NSUInteger)index
{
	FGalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", index]];
	
	if( photo == nil )
		photo = [self createGalleryPhotoForIndex:index];
    
    UIImage *image = [photo getLocalFullImage];
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:index];
    if (image) {
        //从本地加载大图片
        if (!photoView.imageView.image) {
            photoView.imageView.image = image;
        }
    }
    else{
        //从网络下载
        if (_currentIndex == index) {
            [photo loadFullsize];
        }
    }
}


- (void)unloadFullsizeImageWithIndex:(NSUInteger)index
{
    /*
	if (index < [_photoViews count]) {
		FGalleryPhoto *loader = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", index]];
		[loader unloadFullsize];
		
		FGalleryPhotoView *photoView = [_photoViews objectAtIndex:index];
        //使用小图
		photoView.imageView.image = loader.thumbnail;
	}
     */
}


- (FGalleryPhoto*)createGalleryPhotoForIndex:(NSUInteger)index
{
	FGalleryPhotoSourceType sourceType = [_photoSource photoGallery:self sourceTypeForPhotoAtIndex:index];
	FGalleryPhoto *photo;
	NSString *thumbPath;
	NSString *fullsizePath;
	
	if( sourceType == FGalleryPhotoSourceTypeLocal )
	{
		thumbPath = [_photoSource photoGallery:self filePathForPhotoSize:FGalleryPhotoSizeThumbnail atIndex:index];
		fullsizePath = [_photoSource photoGallery:self filePathForPhotoSize:FGalleryPhotoSizeFullsize atIndex:index];
		photo = [[[FGalleryPhoto alloc] initWithThumbnailPath:thumbPath fullsizePath:fullsizePath delegate:self] autorelease];
	}
	else if( sourceType == FGalleryPhotoSourceTypeNetwork )
	{
		thumbPath = [_photoSource photoGallery:self urlForPhotoSize:FGalleryPhotoSizeThumbnail atIndex:index];
		fullsizePath = [_photoSource photoGallery:self urlForPhotoSize:FGalleryPhotoSizeFullsize atIndex:index];
        
		photo = [[[FGalleryPhoto alloc] initWithThumbnailUrl:thumbPath fullsizeUrl:fullsizePath delegate:self] autorelease];
	}
	else 
	{
		// invalid source type, throw an error.
		[NSException raise:@"Invalid photo source type" format:@"The specified source type of %d is invalid", sourceType];
	}
    
	// assign the photo index
	photo.tag = index;
	
	// store it
	[_photoLoaders setObject:photo forKey: [NSString stringWithFormat:@"%i", index]];
	
	return photo;
}


#pragma mark - 预先加载5张图片
- (void)preLoadFullSizeImage{
    [self loadFullsizeImageWithIndex:_currentIndex];
    
    if (_currentIndex -1 >= 0) {
        [self loadFullsizeImageWithIndex:_currentIndex-1];
    }
    if (_currentIndex -2 >= 0) {
        [self loadFullsizeImageWithIndex:_currentIndex-2];
    }
    
    NSUInteger numberOfPhotos = [_photoSource numberOfPhotosForPhotoGallery:self];
    if (_currentIndex +1 <  numberOfPhotos) {
        [self loadFullsizeImageWithIndex:_currentIndex+1];
    }
    if (_currentIndex +2 < numberOfPhotos) {
        [self loadFullsizeImageWithIndex:_currentIndex+2];
    }
}

#pragma mark - 重设大小
- (void)resizeImageViewAtIndex:(NSInteger)index{
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:index];
    [photoView resetZoom];
}


#pragma mark - FGalleryPhoto Delegate Methods


- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadThumbnailFromPath:(NSString*)path
{
	// show activity indicator for large photo view
	FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
	[photoView.activity startAnimating];
	
	// show activity indicator for thumbail 
	if( _isThumbViewShowing ) {
		FGalleryPhotoView *thumb = [_photoThumbnailViews objectAtIndex:photo.tag];
		[thumb.activity startAnimating];
	}
}


- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadThumbnailFromUrl:(NSString*)url
{
	// show activity indicator for large photo view
	FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
	[photoView.activity startAnimating];
	
	// show activity indicator for thumbail 
	if( _isThumbViewShowing ) {
		FGalleryPhotoView *thumb = [_photoThumbnailViews objectAtIndex:photo.tag];
		[thumb.activity startAnimating];
	}
}

- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadFullsizeFromUrl:(NSString*)url{
    
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
    if (photoView.nailImageView.image) {
        photoView.nailImageView.image = nil;
    }
    
    //显示小图
    [self loadThumbnailImageWithIndex:photo.tag];
    [photoView showNailImageView];
    
    //显示进度条
    [photoView showProgrossView];
}


- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadThumbnail:(UIImage*)image
{
	// grab the associated image view
	FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
	
	// if the gallery photo hasn't loaded the fullsize yet, set the thumbnail as its image.
	if( !photo.hasFullsizeLoaded ){
        NSLog(@"----------%i",photo.thumbConnectionResponseStatusCode);
        photoView.nailImageView.image = photo.thumbnail;
        /*
        if (photo.fullsizeConnectionResponseStatusCode == 200){
            photoView.nailImageView.image = photo.thumbnail;
        }
        else{
            //小图下载失败，用默认图显示
            photoView.nailImageView.image = [StringUtil getImageByResName:@"nonexistentPhoto.jpg"];
        }
         */
    }

	[photoView.activity stopAnimating];
	/*
	// grab the thumbail view and set its image
	FGalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:photo.tag];
	thumbView.imageView.image = image;
	[thumbView.activity stopAnimating];
     */
}



- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadFullsize:(UIImage*)image
{
	// only set the fullsize image if we're currently on that image
	if( _currentIndex == photo.tag)
	{
        FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
        FGalleryPhotoSourceType sourceType = [_photoSource photoGallery:self sourceTypeForPhotoAtIndex:index];
        if( sourceType == FGalleryPhotoSourceTypeLocal )
        {
            photoView.imageView.image = photo.fullsize;
            [photoView hideProgrossView];
            [photoView hideNailImageView];
        }
        else if( sourceType == FGalleryPhotoSourceTypeNetwork )
        {
            /*
            if (photo.fullsizeConnectionResponseStatusCode == 404 ) {
                //文件过期
                [photoView showNailImageView];
                photoView.imageView.image = nil;
                photoView.nailImageView.image = [StringUtil getImageByResName:@"nonexistentPhoto.jpg"];
            }
            else if (photo.fullsizeConnectionResponseStatusCode != 200){
                //其他错误
                [photoView showNailImageView];
                photoView.imageView.image = nil;
                photoView.nailImageView.image = [StringUtil getImageByResName:@"nonexistentPhoto.jpg"];
            }
            else{
                photoView.imageView.image = photo.fullsize;
            }
            */
            
            if (photo.fullsize) {
                 photoView.imageView.image = photo.fullsize;
            }
            else{
                [photoView showNailImageView];
                photoView.imageView.image = nil;
                photoView.nailImageView.image = [StringUtil getImageByResName:@"nonexistentPhoto.jpg"];
            }
        }
        
        
        /*
		FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
        if (photo.fullsizeConnectionResponseStatusCode == 404 ) {
            //文件过期
            [photoView showNailImageView];
            photoView.imageView.image = nil;
            photoView.nailImageView.image = [StringUtil getImageByResName:@"nonexistentPhoto.jpg"];
        }
        else if (photo.fullsizeConnectionResponseStatusCode != 200){
            //其他错误
            [photoView showNailImageView];
            photoView.imageView.image = nil;
            photoView.nailImageView.image = [StringUtil getImageByResName:@"nonexistentPhoto.jpg"];
        }
        else{
            photoView.imageView.image = photo.fullsize;
        }
         */
	}
	else {
        // otherwise, we don't need to keep this image around
        [photo unloadFullsize];
    }
}


#pragma mark - 进度跟踪协议方法
- (void)galleryPhoto:(FGalleryPhoto*)photo didReceiveResponse:(NSHTTPURLResponse *)response{
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
    photoView.expectedContentLength = [response  expectedContentLength];
    photoView.progressLab.text = [NSString stringWithFormat:@"正在下载%@/%@",[StringUtil getDisplayFileSize:0],[StringUtil getDisplayFileSize:photoView.expectedContentLength]];
}

- (void)galleryPhoto:(FGalleryPhoto*)photo didReceiveDataCurrentContentLength:(NSInteger)currentContentLength{
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
    //NSLog(@"currentContentLength-----------%f",currentContentLength);
    [photoView.progressView setProgress:(1.0*currentContentLength)/photoView.expectedContentLength animated:YES];
    photoView.progressLab.text = [NSString stringWithFormat:@"正在下载%@/%@",[StringUtil getDisplayFileSize:currentContentLength],[StringUtil getDisplayFileSize:photoView.expectedContentLength]];
}

- (void)galleryPhotoDidFinishLoadingData:(FGalleryPhoto*)photo{
    //下载完成，隐藏进度条
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
    [photoView hideProgrossView];
    [photoView hideNailImageView];
}

- (void)galleryPhoto:(FGalleryPhoto*)photo  didFailWithError:(NSError *)error{
    //下载失败处理
//    NSLog(@"error----------%@",error);
//    NSLog(@"error.code----------%d",[error code]);
    
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
    [photoView.activity stopAnimating];
    [photoView hideProgrossView];
    photoView.nailImageView.image = [StringUtil getImageByResName:@"nonexistentPhoto.jpg"];
}

#pragma mark - UIScrollView Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    startContentOffsetX = scrollView.contentOffset.x;
    
#ifdef _XIANGYUAN_FLAG_
    
#else
    
    if (scrollView.tag == 2) {
        if (!_isFullscreen) {
            [self enterFullscreen];
        }
    }
    
#endif
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2) {
        _isScrolling = YES;
    }
}
 

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //将要停止前的坐标
    willEndContentOffsetX = scrollView.contentOffset.x;
    if (scrollView.tag == 2) {
        if( !decelerate )
        {
            [self scrollingHasEnded];
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2) {
        [self scrollingHasEnded];
    }
}

- (void)scrollingHasEnded {
	
	_isScrolling = NO;
	
	NSUInteger newIndex = floor( _scroller.contentOffset.x / _scroller.frame.size.width );
	
	// don't proceed if the user has been scrolling, but didn't really go anywhere.
	if( newIndex == _currentIndex){
        if (_currentIndex == 0 && startContentOffsetX > willEndContentOffsetX) {
            [self exitFullscreen];
            [self dimissFGalleryViewController];
            //向左滑动
//            [self performSelector:@selector(dimissFGalleryViewController) withObject:nil afterDelay:0.01];
        }
        return;
    }
    
    NSUInteger numberOfPhotos = [_photoSource numberOfPhotosForPhotoGallery:self];
    
    if (newIndex == -1) {
        newIndex = 0;
    }
    else if(newIndex > numberOfPhotos){
        newIndex = numberOfPhotos - 1;
    }
    
    // clear previous
    [self unloadFullsizeImageWithIndex:_currentIndex];
    [self resizeImageViewAtIndex:_currentIndex];
    
    _currentIndex = newIndex;
    //[self updateCaption];
    [self updateTitle];
    //[self updateButtons];
    //[self preloadThumbnailImages];
    
    //    [self loadFullsizeImageWithIndex:_currentIndex];
    
    [self preLoadFullSizeImage];
}

#pragma mark - 看到本会话的第一张图片后，再左滑能返回到会话界面
- (void)dimissFGalleryViewController{
    if (_photoSource && [_photoSource respondsToSelector:@selector(photoGalleryClickOnBackBtn:)]) {
        [_photoSource photoGalleryClickOnBackBtn:self];
    }
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	
	NSLog(@"[FGalleryViewController] didReceiveMemoryWarning! clearing out cached images...");
	// unload fullsize and thumbnail images for all our images except at the current index.
	NSArray *keys = [_photoLoaders allKeys];
	NSUInteger i, count = [keys count];
    if (_isThumbViewShowing==YES) {
        for (i = 0; i < count; i++)
        {
            FGalleryPhoto *photo = [_photoLoaders objectForKey:[keys objectAtIndex:i]];
            [photo unloadFullsize];
            
            // unload main image thumb
            FGalleryPhotoView *photoView = [_photoViews objectAtIndex:i];
            photoView.imageView.image = nil;
        }
    } else {
        for (i = 0; i < count; i++)
        {
            if( i != _currentIndex )
            {
                FGalleryPhoto *photo = [_photoLoaders objectForKey:[keys objectAtIndex:i]];
                [photo unloadFullsize];
                [photo unloadThumbnail];
                
                // unload main image thumb
                FGalleryPhotoView *photoView = [_photoViews objectAtIndex:i];
                photoView.imageView.image = nil;
                
                // unload thumb tile
                photoView = [_photoThumbnailViews objectAtIndex:i];
                photoView.imageView.image = nil;
            }
        }
    }
}


- (void)dealloc {
	
    self.forwardRecord = nil;
    if (displayPic) {
        [displayPic release];
        displayPic = nil;
    }
	// remove KVO listener
	[_container removeObserver:self forKeyPath:@"frame"];
	
    
	// Cancel all photo loaders in progress
	NSArray *keys = [_photoLoaders allKeys];
	NSUInteger i, count = [keys count];
	for (i = 0; i < count; i++) {
		FGalleryPhoto *photo = [_photoLoaders objectForKey:[keys objectAtIndex:i]];
		photo.delegate = nil;
		[photo unloadThumbnail];
		[photo unloadFullsize];
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	self.galleryID = nil;
	
	_photoSource = nil;
	
    [_caption release];
    _caption = nil;
	
    [_captionContainer release];
    _captionContainer = nil;
	
    [_container release];
    _container = nil;
	
    [_innerContainer release];
    _innerContainer = nil;
	
    [_toolbar release];
    _toolbar = nil;
	
    [_thumbsView release];
    _thumbsView = nil;
	
    [_scroller release];
    _scroller.delegate = nil;
    _scroller = nil;
	
	[_photoLoaders removeAllObjects];
    [_photoLoaders release];
    _photoLoaders = nil;
	
	[_barItems removeAllObjects];
	[_barItems release];
	_barItems = nil;
	
	[_photoThumbnailViews removeAllObjects];
    [_photoThumbnailViews release];
    _photoThumbnailViews = nil;
	
	[_photoViews removeAllObjects];
    [_photoViews release];
    _photoViews = nil;
	
    [_nextButton release];
    _nextButton = nil;
	
    [_prevButton release];
    _prevButton = nil;
	
#ifdef _LONGHU_FLAG_
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = 0;
#endif
    [super dealloc];
}

@end


/**
 *	This section overrides the auto-rotate methods for UINaviationController and UITabBarController 
 *	to allow the tab bar to rotate only when a FGalleryController is the visible controller. Sweet.
 */

@implementation UINavigationController (FGallery)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if([self.visibleViewController isKindOfClass:[FGalleryViewController class]]) 
	{
        return YES;
	}

	// To preserve the UINavigationController's defined behavior,
	// walk its stack.  If all of the view controllers in the stack
	// agree they can rotate to the given orientation, then allow it.
	BOOL supported = YES;
	for(UIViewController *sub in self.viewControllers)
	{
		if(![sub shouldAutorotateToInterfaceOrientation:interfaceOrientation])
		{
			supported = NO;
			break;
		}
	}	
	if(supported)
		return YES;
	
	// we need to support at least one type of auto-rotation we'll get warnings.
	// so, we'll just support the basic portrait.
	return ( interfaceOrientation == UIInterfaceOrientationPortrait ) ? YES : NO;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// see if the current controller in the stack is a gallery
	if([self.visibleViewController isKindOfClass:[FGalleryViewController class]])
	{
		FGalleryViewController *galleryController = (FGalleryViewController*)self.visibleViewController;
		[galleryController resetImageViewZoomLevels];
	}
}


@end




@implementation UITabBarController (FGallery)


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // only return yes if we're looking at the gallery
    if( [self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController*)self.selectedViewController;
        
        // see if the current controller in the stack is a gallery
        if([navController.visibleViewController isKindOfClass:[FGalleryViewController class]])
        {
            return YES;
        }
    }
	
	// we need to support at least one type of auto-rotation we'll get warnings.
	// so, we'll just support the basic portrait.
	return ( interfaceOrientation == UIInterfaceOrientationPortrait ) ? YES : NO;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if([self.selectedViewController isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *navController = (UINavigationController*)self.selectedViewController;
		
		// see if the current controller in the stack is a gallery
		if([navController.visibleViewController isKindOfClass:[FGalleryViewController class]])
		{
			FGalleryViewController *galleryController = (FGalleryViewController*)navController.visibleViewController;
			[galleryController resetImageViewZoomLevels];
		}
	}
}

@end



