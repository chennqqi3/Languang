//
//  FGalleryPhoto.h
//  FGallery
//
//  Created by Grant Davis on 5/20/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol FGalleryPhotoDelegate;

@interface FGalleryPhoto : NSObject {
	
	// value which determines if the photo was initialized with local file paths or network paths.
	BOOL _useNetwork;
	
	BOOL _isThumbLoading;
	BOOL _hasThumbLoaded;
	
	BOOL _isFullsizeLoading;
	BOOL _hasFullsizeLoaded;
	
	NSMutableData *_thumbData;
	NSMutableData *_fullsizeData;
	
	NSURLConnection *_thumbConnection;
	NSURLConnection *_fullsizeConnection;
	
	NSString *_thumbUrl;
	NSString *_fullsizeUrl;
	
	UIImage *_thumbnail;
	UIImage *_fullsize;
	
	NSObject <FGalleryPhotoDelegate> *_delegate;
	
	NSUInteger tag;
    
    //图片名字
    NSString *_fullPhotoName;
    NSString *_thumbnailPhotoName;
    
    NSInteger _expectedContentLength;
    NSInteger _currentContentLength;
    
    NSInteger _thumbConnectionResponseStatusCode;
    NSInteger _fullsizeConnectionResponseStatusCode;
}


- (id)initWithThumbnailUrl:(NSString*)thumb fullsizeUrl:(NSString*)fullsize delegate:(NSObject<FGalleryPhotoDelegate>*)delegate;
- (id)initWithThumbnailPath:(NSString*)thumb fullsizePath:(NSString*)fullsize delegate:(NSObject<FGalleryPhotoDelegate>*)delegate;

- (void)loadThumbnail;
- (void)loadFullsize;

- (void)unloadFullsize;
- (void)unloadThumbnail;

- (UIImage *)getLocalThumbImage;
- (UIImage *)getLocalFullImage;

@property NSUInteger tag;

@property (readonly) BOOL isThumbLoading;
@property (readonly) BOOL hasThumbLoaded;

@property (readonly) BOOL isFullsizeLoading;
@property (readonly) BOOL hasFullsizeLoaded;

@property (nonatomic,readonly) UIImage *thumbnail;
@property (nonatomic,readonly) UIImage *fullsize;

@property (nonatomic,readonly) NSInteger thumbConnectionResponseStatusCode;
@property (nonatomic,readonly) NSInteger fullsizeConnectionResponseStatusCode;

@property (nonatomic,assign) NSObject<FGalleryPhotoDelegate> *delegate;

@end


@protocol FGalleryPhotoDelegate

@required
- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadThumbnail:(UIImage*)image;
- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadFullsize:(UIImage*)image;

@optional
- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadThumbnailFromUrl:(NSString*)url;
- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadFullsizeFromUrl:(NSString*)url;

- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadThumbnailFromPath:(NSString*)path;
- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadFullsizeFromPath:(NSString*)path;

//进度条显示
- (void)galleryPhoto:(FGalleryPhoto*)photo didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)galleryPhoto:(FGalleryPhoto*)photo didReceiveDataCurrentContentLength:(NSInteger)currentContentLength;
- (void)galleryPhotoDidFinishLoadingData:(FGalleryPhoto*)photo;
- (void)galleryPhoto:(FGalleryPhoto*)photo  didFailWithError:(NSError *)error;

@end
