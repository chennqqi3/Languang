//
//  FGalleryViewController.h
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FGalleryPhotoView.h"
#import "FGalleryPhoto.h"
#import "ConvRecord.h"


typedef enum
{
	FGalleryPhotoSizeThumbnail,
	FGalleryPhotoSizeFullsize
} FGalleryPhotoSize;

typedef enum
{
	FGalleryPhotoSourceTypeNetwork,
	FGalleryPhotoSourceTypeLocal
} FGalleryPhotoSourceType;

@protocol FGalleryViewControllerDelegate;

@interface FGalleryViewController : UIViewController <UIScrollViewDelegate,FGalleryPhotoDelegate,FGalleryPhotoViewDelegate,UIActionSheetDelegate> {
	
	BOOL _isActive;
	BOOL _isFullscreen;
	BOOL _isScrolling;
	BOOL _isThumbViewShowing;
	
	UIStatusBarStyle _prevStatusStyle;
	CGFloat _prevNextButtonSize;
	CGRect _scrollerRect;
	NSString *galleryID;
	NSInteger _currentIndex;
	
	UIView *_container; // used as view for the controller
	UIView *_innerContainer; // sized and placed to be fullscreen within the container
	UIToolbar *_toolbar;
	UIScrollView *_thumbsView;
	UIScrollView *_scroller;
	UIView *_captionContainer;
	UILabel *_caption;
	
	NSMutableDictionary *_photoLoaders;
	NSMutableArray *_barItems;
	NSMutableArray *_photoThumbnailViews;
	NSMutableArray *_photoViews;
	
	NSObject <FGalleryViewControllerDelegate> *_photoSource;
    
	UIBarButtonItem *_nextButton;
	UIBarButtonItem *_prevButton;
    NSString *imagePath;
    BOOL is_from_chatbackgroud;
    NSString *one_chat_imagename;
    id predelegete;
    
    
    float startContentOffsetX;  //拖动前的起始坐标
    float willEndContentOffsetX; //将要停止前的坐标
    
//    切换到图片缩略图的按钮
    UIButton *_switchButton;
}

- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc;
- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc withCurrentIndex:(NSInteger) currentIndex;
- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc barItems:(NSArray*)items;

- (void)next;
- (void)previous;
- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeImageAtIndex:(NSUInteger)index;
- (void)reloadGallery;
- (FGalleryPhoto*)currentPhoto;

#pragma mark =======转发提示=========
- (void)showTransferTips;

@property NSInteger currentIndex;
@property NSInteger startingIndex;
@property (nonatomic,assign) NSObject<FGalleryViewControllerDelegate> *photoSource;
//转发的聊天记录
@property(nonatomic,retain) NSString *convId;
@property (nonatomic,retain) ConvRecord *forwardRecord;
@property (nonatomic,readonly) UIToolbar *toolBar;
@property (nonatomic,readonly) UIView* thumbsView;
@property (nonatomic,retain) NSString *galleryID;
@property (nonatomic) BOOL useThumbnailView;
@property (nonatomic) BOOL beginsInThumbnailView;
@property (nonatomic) BOOL hideTitle;
@property(nonatomic,retain)  NSString *imagePath;
@property (assign)  BOOL is_from_chatbackgroud;
@property(nonatomic,retain)NSString *one_chat_imagename;
@property(assign)id predelegete;

//是否需要显示切换到缩略图的按钮 默认是不需要的
@property (nonatomic,assign) BOOL needDisplaySwitchButton;



@end


@protocol FGalleryViewControllerDelegate

@required
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery;
- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index;

@optional
- (NSString*)photoGallery:(FGalleryViewController*)gallery captionForPhotoAtIndex:(NSUInteger)index;

// the photosource must implement one of these methods depending on which FGalleryPhotoSourceType is specified 
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index;
- (NSString*)photoGallery:(FGalleryViewController*)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index;

- (NSString*)photoGalleryClickOnBackBtn:(FGalleryViewController*)gallery;//返回刷新会话列表
- (NSString*)photoGallery:(FGalleryViewController*)gallery netWorkReachable:(BOOL)isReachable;

@end
