//
//  ELCImagePreViewViewController.m
//  eCloud
//
//  Created by Pain on 14-4-18.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "ELCImagePreViewViewController.h"
#import "ELCAsset.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"

@interface ELCImagePreViewViewController ()

@end

@implementation ELCImagePreViewViewController
@synthesize photoSource = _photoSource;

- (id)initWithIndex:(NSInteger)_index;
{
    self = [super init];
    if (self) {
        // Custom initialization
        _currentIndex = _index;
        _hideTitle = NO;
        _photoViews	= [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title	=	[StringUtil getLocalizableString:@"chats_talksession_message_photo_preview"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(back:)];
    
    selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(0, 0,  44.0, 44.0);
    
    if (_photoSource && [_photoSource respondsToSelector:@selector(imagePreViewViewController:ELCAssetAtIndex:)]) {
        ELCAsset *asset = (ELCAsset*)[_photoSource imagePreViewViewController:self  ELCAssetAtIndex:_currentIndex];
        BOOL isSelect = [asset selected];
       
        selectBtn = [UIAdapterUtil setRightButtonItemWithImageName:nil andTarget:self andSelector:@selector(clickOnSelectBtn:)];
        if (isSelect) {
            //选中
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateNormal];
        }
        else{
            //未选择
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateNormal];
        }
    }
    
    [selectBtn addTarget:self action:@selector(clickOnSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:selectBtn] autorelease];
    
    //
    [self loadScrollerView];
    
	[self layoutViews];
	
	// update status bar to be see-through
#ifdef _LANGUANG_FLAG_
    
#else
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
    
#endif
	
	// init with next on first run.
	if( _currentIndex == -1 ){
        [self next];
    }
	else {
        [self gotoImageByIndex:_currentIndex animated:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        //适配ios7 UIScrollView
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 按钮方法实现
- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickOnSelectBtn:(id)sender{
    if (_photoSource && [_photoSource respondsToSelector:@selector(imagePreViewViewController:didSelectAtIndex:)]) {
        BOOL isSelect = [_photoSource imagePreViewViewController:self didSelectAtIndex:_currentIndex];
        NSLog(@"isSelect-----------%i",isSelect);
        if (isSelect) {
            //选中
            [sender setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateNormal];
            [sender setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateHighlighted];
            [sender setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateSelected];
        }
        else{
            //未选择
            [sender setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateNormal];
            [sender setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateHighlighted];
            [sender setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateSelected];
        }
    }
}

-(void)selectCurrentImage{
    //选中当前图片
    [self clickOnSelectBtn:selectBtn];
}

- (void)next:(id)sender
{
    NSLog(@"2112422422255");
}

#pragma mark - 加载图片预览
- (void)loadScrollerView
{
    // create public objects first so they're available for custom configuration right away. positioning comes later.
    _container							= [[UIView alloc] initWithFrame:CGRectZero];
    _innerContainer						= [[UIView alloc] initWithFrame:CGRectZero];
    _scroller							= [[UIScrollView alloc] initWithFrame:CGRectZero];
    _container.backgroundColor			= [UIColor blackColor];
    
    // listen for container frame changes so we can properly update the layout during auto-rotation or going in and out of fullscreen
    [_container addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    // setup scroller
    _scroller.delegate							= self;
    _scroller.tag = 2;
    _scroller.pagingEnabled						= YES;
    _scroller.showsVerticalScrollIndicator		= NO;
    _scroller.showsHorizontalScrollIndicator	= NO;
    
    // make things flexible
    _container.autoresizesSubviews				= NO;
    _innerContainer.autoresizesSubviews			= NO;
    _scroller.autoresizesSubviews				= NO;
    _container.autoresizingMask					= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	// set view
	self.view                                   = _container;
    _container.userInteractionEnabled = YES;
    
	// add items to their containers
	[_container addSubview:_innerContainer];
	
	[_innerContainer addSubview:_scroller];
    // build stuff
    [self reloadGallery];
}


- (void)viewDidUnload {
    
    [self destroyViews];
    
    [_container release], _container = nil;
    [_innerContainer release], _innerContainer = nil;
    [_scroller release], _scroller = nil;
    
    [super viewDidUnload];
}


- (void)destroyViews {
    // remove previous photo views
    for (UIView *view in _photoViews) {
        [view removeFromSuperview];
    }
    [_photoViews removeAllObjects];
}


- (void)reloadGallery
{
    
    // remove the old
    [self destroyViews];
    
    // build the new
    NSInteger numberOfPhotos = 0;
    if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
        numberOfPhotos = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
    }
    
    if (numberOfPhotos > 0) {
        // create the image views for each photo
        [self buildViews];
        [self gotoImageByIndex:_currentIndex animated:NO];
        
        // layout
        [self layoutViews];
    }
}


- (void)resizeImageViewsWithRect:(CGRect)rect
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	float dx = 0;
	for (i = 0; i < count; i++) {
		ELCImagePreView * photoView = [_photoViews objectAtIndex:i];
		photoView.frame = CGRectMake(dx, 0, rect.size.width, rect.size.height );
		dx += rect.size.width;
	}
}

- (void)next
{
	NSUInteger numberOfPhotos = 0;
    if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
        numberOfPhotos = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
    }
    
	NSUInteger nextIndex = _currentIndex+1;
	
	// don't continue if we're out of images.
	if( nextIndex <= numberOfPhotos )
	{
		[self gotoImageByIndex:nextIndex animated:NO];
	}
}
#pragma mark - 重设图片大小
- (void)resetImageViewZoomLevels
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	for (i = 0; i < count; i++) {
		ELCImagePreView * photoView = [_photoViews objectAtIndex:i];
		[photoView resetZoom];
	}
}


- (void)removeImageAtIndex:(NSUInteger)index
{
	// remove the image and thumbnail at the specified index.
	ELCImagePreView *imgView = [_photoViews objectAtIndex:index];
    
	[imgView removeFromSuperview];
	
	[_photoViews removeObjectAtIndex:index];
	
	[self layoutViews];
    [self updateTitle];
    [self updateSelectBtn];
}




- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated
{
	NSUInteger numPhotos = 0;
	if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
       numPhotos = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
    }
	// constrain index within our limits
    if( index >= numPhotos ) index = numPhotos - 1;
	
	if( numPhotos == 0 ) {
		
		// no photos!
		_currentIndex = -1;
	}
	else {
		
		// clear the fullsize image in the old photo
		_currentIndex = index;
		[self moveScrollerToCurrentIndexWithAnimation:animated];
		[self updateTitle];
        [self updateSelectBtn];
		
		if( !animated )	{
//            [self loadFullsizeImageWithIndex:index];
            [self preLoadFullSizeImage];
		}
	}
}


- (void)layoutViews
{
	[self positionInnerContainer];
	[self positionScroller];
	[self updateScrollSize];
	[self resizeImageViewsWithRect:_scroller.frame];
	[self moveScrollerToCurrentIndexWithAnimation:NO];
}


#pragma mark - Private Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"frame"])
	{
		[self layoutViews];
	}
}


//- (void)positionInnerContainer
//{
//	CGRect screenFrame = [[UIScreen mainScreen] bounds];
//    
//	CGRect innerContainerRect;
//    
//	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
//	{
//        //portrait
//        if (IOS7_OR_LATER) {
//            innerContainerRect = CGRectMake( 0.0,(_container.frame.size.height-screenFrame.size.height)/2, _container.frame.size.width,screenFrame.size.height);
//        }
//        else{
//            if (screenFrame.size.height - _container.frame.size.height == 44.0) {
//                innerContainerRect = CGRectMake( 0.0,0.0, _container.frame.size.width,screenFrame.size.height);
//            }
//            else{
//                innerContainerRect = CGRectMake( 0.0,(_container.frame.size.height-screenFrame.size.height)/2-10.0, _container.frame.size.width,screenFrame.size.height);
//            }
//        }
//	}
//	else
//	{
//        // landscape
//		innerContainerRect = CGRectMake( 0, _container.frame.size.height - screenFrame.size.width, _container.frame.size.width, screenFrame.size.width );
//	}
//	
//	_innerContainer.frame = innerContainerRect;
//}

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
    
//    _innerContainer.frame = innerContainerRect;

    _innerContainer.frame = screenFrame;
//    NSLog(@"%s _innerContainer %@",__FUNCTION__,NSStringFromCGRect(_innerContainer.frame));

}

- (void)positionScroller
{
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect scrollerRect;
	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{//portrait
		scrollerRect = CGRectMake( 0.0, 0.0, screenFrame.size.width, screenFrame.size.height);
	}
	else
	{//landscape
		scrollerRect = CGRectMake( 0, 0, screenFrame.size.height, screenFrame.size.width );
	}
    
    _scroller.frame = screenFrame;// scrollerRect;

//    NSLog(@"%s _scroller %@",__FUNCTION__,NSStringFromCGRect(_scroller.frame));
}





- (void)enterFullscreen
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
    [self.navigationController.toolbar setHidden:YES];
}



- (void)exitFullscreen
{
	_isFullscreen = NO;

    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.toolbar setHidden:NO];
}



- (void)enableApp
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void)disableApp
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


#pragma mark - 点击图片
- (void)didTapELCImagePreView:(ELCImagePreView*)photoView
{
	// don't change when scrolling
	if( _isScrolling ) return;
	
	// toggle fullscreen.
	if( _isFullscreen == NO ) {
		
		[self enterFullscreen];
	}
	else {
		
		[self exitFullscreen];
	}
    
}


#pragma mark - 更新
- (void)updateScrollSize
{
    NSInteger numberOfPhotos = 0;
    if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
        numberOfPhotos = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
    }
    
	float contentWidth = _scroller.frame.size.width * numberOfPhotos;
	[_scroller setContentSize:CGSizeMake(contentWidth, _scroller.frame.size.height)];
}


- (void)updateTitle
{
    if (!_hideTitle){
        NSInteger numberOfPhotos = 0;
        if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
            numberOfPhotos = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
        }
        
        if (numberOfPhotos > 1) {
            [self setTitle:[NSString stringWithFormat:@"%i %@ %i", _currentIndex+1, NSLocalizedString(@"/", @"") , numberOfPhotos]];
        }
        else{
            [self setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_preview"]];
        }
    }else{
        [self setTitle:@""];
    }
}

- (void)updateSelectBtn{
    if (_photoSource && [_photoSource respondsToSelector:@selector(imagePreViewViewController:ELCAssetAtIndex:)]) {
        ELCAsset *asset = (ELCAsset*)[_photoSource imagePreViewViewController:self  ELCAssetAtIndex:_currentIndex];
        BOOL isSelect = [asset selected];
        if (isSelect) {
            //选中
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateNormal];
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateHighlighted];
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateSelected];
        }
        else{
            //未选择
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateNormal];
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateHighlighted];
            [selectBtn setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateSelected];
        }
    }
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
	NSUInteger i;
    NSUInteger count = 0;
    if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
        count = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
    }
    
	for (i = 0; i < count; i++) {
		ELCImagePreView *photoView = [[ELCImagePreView alloc] initWithFrame:CGRectZero];
		photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		photoView.autoresizesSubviews = NO;
		photoView.photoDelegate = self;
		[_scroller addSubview:photoView];
		[_photoViews addObject:photoView];
		[photoView release];
	}
}

- (void)scrollingHasEnded {
	
	_isScrolling = NO;
	
	NSUInteger newIndex = floor( _scroller.contentOffset.x / _scroller.frame.size.width );
	
	// don't proceed if the user has been scrolling, but didn't really go anywhere.
	if( newIndex == _currentIndex)
		return;
    NSUInteger numberOfPhotos = 0;
    if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
        numberOfPhotos = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
    }
    
    if (newIndex == -1) {
        newIndex = 0;
    }
    else if(newIndex > numberOfPhotos){
        newIndex = numberOfPhotos - 1;
    }
    
    // clear previous
    [self resizeImageViewAtIndex:_currentIndex];
    
    _currentIndex = newIndex;
    [self updateTitle];
    [self updateSelectBtn];
//    [self loadFullsizeImageWithIndex:_currentIndex];
    [self preLoadFullSizeImage];
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
    
    NSUInteger numberOfPhotos = 0;
    if (_photoSource && [_photoSource respondsToSelector:@selector(numberOfPhotosForELCImagePreViewViewController:)]) {
        numberOfPhotos = [_photoSource numberOfPhotosForELCImagePreViewViewController:self];
    }
    
    
    if (_currentIndex +1 <  numberOfPhotos) {
        [self loadFullsizeImageWithIndex:_currentIndex+1];
    }
    if (_currentIndex +2 < numberOfPhotos) {
        [self loadFullsizeImageWithIndex:_currentIndex+2];
    }
}

#pragma mark - 加载图片
- (void)loadFullsizeImageWithIndex:(NSUInteger)index
{
    ELCImagePreView *photoView = [_photoViews objectAtIndex:index];
    if (!photoView.imageView.image) {
        if (_photoSource && [_photoSource respondsToSelector:@selector(imagePreViewViewController:ELCAssetAtIndex:)]) {
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
            
            CGImageRef imageRef;
            ALAsset *asset = [[(ELCAsset*)[_photoSource imagePreViewViewController:self  ELCAssetAtIndex:index] asset] asset];
            ALAssetRepresentation* rep = [asset defaultRepresentation];
            imageRef = [rep fullScreenImage];
            UIImage *image = nil;
            
            if(imageRef)
            {
                image = [UIImage imageWithCGImage:imageRef];
            }
            photoView.imageView.image = image;
            [pool drain];
        }
    }
}

#pragma mark - 重设大小
- (void)resizeImageViewAtIndex:(NSInteger)index{
    ELCImagePreView *photoView = [_photoViews objectAtIndex:index];
    [photoView resetZoom];
}


#pragma mark - UIScrollView Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    if (scrollView.tag == 2) {
//        if (!_isFullscreen) {
//            [self enterFullscreen];
//        }
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 2) {
        _isScrolling = YES;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
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

#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    
	NSLog(@"[FGalleryViewController] didReceiveMemoryWarning! clearing out cached images...");
	// unload fullsize and thumbnail images for all our images except at the current index.
    
	NSUInteger i, count = [_photoViews count];
    for (i = 0; i < count; i++)
    {
        if( i != _currentIndex )
        {
            // unload main image thumb
            ELCImagePreView *photoView = [_photoViews objectAtIndex:i];
            photoView.imageView.image = nil;
        }
    }
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
//    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGRect(self.navigationController.toolbar.frame));
    
    for (UIView *_view in self.navigationController.toolbar.subviews) {
        if ([_view isKindOfClass:[UIButton class]]) {
            if (!_view.hidden) {
                UIButton *sendButton = (UIButton *)_view;
                CGRect _frame = sendButton.frame;
                if (_frame.origin.x == (SCREEN_WIDTH - 74)) {
                    return;
                }
                _frame.origin.x = SCREEN_WIDTH - 74;
                sendButton.frame = _frame;
                return;
            }
        }
    }
    
//    CGRect _frame = sendbutton.frame;
}


- (void)dealloc {
	
	// remove KVO listener
	[_container removeObserver:self forKeyPath:@"frame"];
	
    
	// Cancel all photo loaders in progress

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	_photoSource = nil;
	
    [_container release];
    _container = nil;
	
    [_innerContainer release];
    _innerContainer = nil;
	
	
    [_scroller release];
    _scroller.delegate = nil;
    _scroller = nil;
	
	[_photoViews removeAllObjects];
    [_photoViews release];
    _photoViews = nil;
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
	if([self.visibleViewController isKindOfClass:[ELCImagePreViewViewController class]])
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
	if([self.visibleViewController isKindOfClass:[ELCImagePreViewViewController class]])
	{
		ELCImagePreViewViewController *galleryController = (ELCImagePreViewViewController*)self.visibleViewController;
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
        if([navController.visibleViewController isKindOfClass:[ELCImagePreViewViewController class]])
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
		if([navController.visibleViewController isKindOfClass:[ELCImagePreViewViewController class]])
		{
			ELCImagePreViewViewController *galleryController = (ELCImagePreViewViewController*)navController.visibleViewController;
			[galleryController resetImageViewZoomLevels];
		}
	}
}

 
@end
