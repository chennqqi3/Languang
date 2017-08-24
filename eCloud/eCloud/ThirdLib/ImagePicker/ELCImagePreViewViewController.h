//
//  ELCImagePreViewViewController.h
//  eCloud
//
//  Created by Pain on 14-4-18.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAsset.h"
#import "ELCImagePreView.h"

@protocol ELCImagePreViewViewControllerDelegate;

@interface ELCImagePreViewViewController : UIViewController<UIScrollViewDelegate,ELCImagePreViewDelegate>{
    UIView *_container;
	UIView *_innerContainer;
    UIScrollView *_scroller;
    NSMutableArray *_photoViews;
    UIButton *selectBtn;
    UIButton *sendbutton;
    NSInteger _currentIndex;
    
    NSObject <ELCImagePreViewViewControllerDelegate> *_photoSource;
    
    BOOL _isFullscreen;
    BOOL _isScrolling;
    BOOL _hideTitle;
}
- (id)initWithIndex:(NSInteger)_index;

@property (nonatomic,assign) NSObject<ELCImagePreViewViewControllerDelegate> *photoSource;

- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeImageAtIndex:(NSUInteger)index;
- (void)reloadGallery;

- (void)selectCurrentImage;//选中当前图片
@end



@protocol ELCImagePreViewViewControllerDelegate

@required
- (NSInteger)numberOfPhotosForELCImagePreViewViewController:(ELCImagePreViewViewController*)ELCImagePreViewViewController;
- (ELCAsset *)imagePreViewViewController:(ELCImagePreViewViewController*)ELCImagePreViewViewController ELCAssetAtIndex:(NSInteger *)index;

@optional
- (NSString*)imagePreViewViewController:(ELCImagePreViewViewController*)ELCImagePreViewViewController captionForPhotoAtIndex:(NSUInteger)index;
- (BOOL)imagePreViewViewController:(ELCImagePreViewViewController*)ELCImagePreViewViewController didSelectAtIndex:(NSInteger)index;

@end
