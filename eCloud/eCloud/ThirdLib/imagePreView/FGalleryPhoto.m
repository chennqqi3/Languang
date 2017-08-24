//
//  FGalleryPhoto.m
//  FGallery
//
//  Created by Grant Davis on 5/20/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "FGalleryPhoto.h"
#import "PictureUtil.h"

#import "StringUtil.h"
#import "talkSessionUtil.h"
#import "ImageUtil.h"
#import "EncryptFileManege.h"

//收到的公众号图片消息 点击后 查看下载大图
#import "PSMsgDspUtil.h"
#import "PSMsgUtil.h"
#import "ConvRecord.h"

@interface FGalleryPhoto (Private)

// delegate notifying methods
- (void)willLoadThumbFromUrl;
- (void)willLoadFullsizeFromUrl;
- (void)willLoadThumbFromPath;
- (void)willLoadFullsizeFromPath;
- (void)didLoadThumbnail;
- (void)didLoadFullsize;

// loading local images with threading
- (void)loadFullsizeInThread;
- (void)loadThumbnailInThread;

// cleanup
- (void)killThumbnailLoadObjects;
- (void)killFullsizeLoadObjects;
@end


@implementation FGalleryPhoto
@synthesize tag;
@synthesize thumbnail = _thumbnail;
@synthesize fullsize = _fullsize;
@synthesize delegate = _delegate;
@synthesize isFullsizeLoading = _isFullsizeLoading;
@synthesize hasFullsizeLoaded = _hasFullsizeLoaded;
@synthesize isThumbLoading = _isThumbLoading;
@synthesize hasThumbLoaded = _hasThumbLoaded;
@synthesize thumbConnectionResponseStatusCode = _thumbConnectionResponseStatusCode;
@synthesize fullsizeConnectionResponseStatusCode = _fullsizeConnectionResponseStatusCode;

- (id)initWithThumbnailUrl:(NSString*)thumb fullsizeUrl:(NSString*)fullsize delegate:(NSObject<FGalleryPhotoDelegate>*)delegate
{
	self = [super init];
	_useNetwork = YES;
	_thumbUrl = [thumb retain];
	_fullsizeUrl = [fullsize retain];
	_delegate = delegate;
	return self;
}

- (id)initWithThumbnailPath:(NSString*)thumb fullsizePath:(NSString*)fullsize delegate:(NSObject<FGalleryPhotoDelegate>*)delegate
{
	self = [super init];
	
	_useNetwork = NO;
	_thumbUrl = [thumb retain];
	_fullsizeUrl = [fullsize retain];
	_delegate = delegate;
	return self;
}

#pragma mark - 从本地加载图片

- (UIImage *)getLocalThumbImage{
    
//    如果缩略图url是空，那么不处理 by shisp
    if (!_thumbUrl || _thumbUrl.length == 0) {
        return nil;
    }
    
    
    if (!_thumbnailPhotoName) {
//        _thumbnailPhotoName = [[NSString alloc] initWithFormat:@"small%@.png",[StringUtil getKeyStrOfPicUrl:_thumbUrl] [[_thumbUrl componentsSeparatedByString:@"="] lastObject]];
        
        _thumbnailPhotoName = [[NSString alloc] initWithFormat:@"small%@.png",[StringUtil getKeyStrOfPicUrl:_thumbUrl]];

    }
    
    //NSLog(@"local__thumbnailPhotoName------------%@",_thumbnailPhotoName);
    //从本地取图片
    if (!_thumbnail) {
        NSData *data = [EncryptFileManege getDataWithPath:[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_thumbnailPhotoName]];
        _thumbnail = [[UIImage alloc] initWithData:data];
//        _thumbnail = [[UIImage alloc] initWithContentsOfFile:[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_thumbnailPhotoName]];
    }
    
    return _thumbnail;
}

- (UIImage *)getLocalFullImage{
    
//    如果是以public_service_message_flag为前缀，那么属于公众号收到的图片消息，那么可以从URL中得到路径
    if ([_fullsizeUrl hasPrefix:public_service_message_flag]) {
        ConvRecord *_convRecord = [[PSMsgDspUtil getUtil]getConvRecordFromPSMsgImgUrl:_fullsizeUrl];
        if (_convRecord) {
            if (!_fullPhotoName) {
                _fullPhotoName = [[NSString alloc]initWithString:[PSMsgUtil getPSPicMsgName:_convRecord]];
            }
            if (!_fullsize) {
                _fullsize =  [[UIImage alloc] initWithData:[EncryptFileManege getDataWithPath:[PSMsgUtil getPSPicMsgImagePath:_convRecord]]];
//                [[UIImage alloc] initWithContentsOfFile:[PSMsgUtil getPSPicMsgImagePath:_convRecord]];
            }
        }
        return _fullsize;
    }else if ([_fullsizeUrl hasPrefix:preview_h5_image_prefix]){
        //        根据URL得到文件名字
        if (!_fullPhotoName) {
            NSString *imageName = [[PictureUtil getUtil]getPreviewImageLocalName:_fullsizeUrl];
            if (!imageName) {
                return nil;
            }
            _fullPhotoName = [[NSString alloc]initWithString:imageName];
        }
        if (!_fullsize) {
            _fullsize =  [[UIImage alloc] initWithData:[EncryptFileManege getDataWithPath:[[PictureUtil getUtil] getPreviewImageLocalPath:_fullPhotoName]]];
            //                [[UIImage alloc] initWithContentsOfFile:[PSMsgUtil getPSPicMsgImagePath:_convRecord]];
        }
        return _fullsize;
        
    }
    
    
    if (!_fullPhotoName) {
//        _fullPhotoName = [[NSString alloc] initWithFormat:@"%@.png",[[_fullsizeUrl componentsSeparatedByString:@"="] lastObject]];
        _fullPhotoName = [[NSString alloc] initWithFormat:@"%@.png",[StringUtil getKeyStrOfPicUrl:_fullsizeUrl]];

    }
    //NSLog(@"local_fullsize------------");
    
    if (!_fullsize) {
        NSData *data = [EncryptFileManege getDataWithPath:[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_fullPhotoName]];
//        _fullsize = [UIImage imageWithData:data];
        _fullsize = [[UIImage alloc] initWithData:data];
//        _fullsize = [[UIImage alloc] initWithContentsOfFile:[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_fullPhotoName]];
    }
    
    return _fullsize;
}


#pragma mark - 从网络加载图片
- (void)loadThumbnail
{
    //    如果缩略图url是空，那么不处理 by shisp
    if (!_thumbUrl || _thumbUrl.length == 0) {
        return;
    }
	if( _isThumbLoading || _hasThumbLoaded ) return;
	
	// load from network
	if( _useNetwork )
	{
		// notify delegate
		if (!_thumbnailPhotoName) {
//            _thumbnailPhotoName = [[NSString alloc] initWithFormat:@"small%@.png",[[_thumbUrl componentsSeparatedByString:@"="] lastObject]];
            _thumbnailPhotoName = [[NSString alloc] initWithFormat:@"small%@.png",[StringUtil getKeyStrOfPicUrl:_thumbUrl]];

        }
        
        [self willLoadThumbFromUrl];
		
		_isThumbLoading = YES;
        
        NSMutableURLRequest *request = [NSMutableURLRequest
         requestWithURL:[NSURL URLWithString:_thumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
        
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        [urlCache setMemoryCapacity:1*1024*1024];
        
        NSCachedURLResponse *response =
        [urlCache cachedResponseForRequest:request];
        
        //判断是否有缓存
        if (response != nil){
            NSLog(@"如果有缓存输出，从缓存中获取数据");
            [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        }
		
		_thumbConnection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
		_thumbData = [[NSMutableData alloc] init];
	}
	
	// load from disk
	else {
		
		// notify delegate
		[self willLoadThumbFromPath];
		
		_isThumbLoading = YES;
		
		// spawn a new thread to load from disk
		[NSThread detachNewThreadSelector:@selector(loadThumbnailInThread) toTarget:self withObject:nil];
	}
}


- (void)loadFullsize
{
	if( _isFullsizeLoading || _hasFullsizeLoaded)
        return;
	
	if( _useNetwork )
	{
        NSString *localImageUrl = [NSString stringWithString:_fullsizeUrl];
//        判断是否是公众号图片
        if ([_fullsizeUrl hasPrefix:public_service_message_flag]) {
            ConvRecord *_convRecord = [[PSMsgDspUtil getUtil]getConvRecordFromPSMsgImgUrl:_fullsizeUrl];
            if (_convRecord) {
                localImageUrl = [NSString stringWithString:_convRecord.msg_body];
                
                if (!_fullPhotoName) {
                    _fullPhotoName = [[NSString alloc]initWithString:[PSMsgUtil getPSPicMsgName:_convRecord]];
                }
            }
        }else if ([_fullsizeUrl hasPrefix:preview_h5_image_prefix]){
            localImageUrl = [[PictureUtil getUtil]getRealImageUrl:_fullsizeUrl];
            if (localImageUrl.length == 0) {
                return;
            }
            if (!_fullPhotoName) {
                NSString *realName = [[PictureUtil getUtil]getPreviewImageLocalName:_fullsizeUrl];
                if (!realName) {
                    return;
                }
                _fullPhotoName = [[NSString alloc]initWithString:realName];
            }
        }
        else
        {
            if (!_fullPhotoName) {
                //            _fullPhotoName = [[NSString alloc] initWithFormat:@"%@.png",[[_fullsizeUrl componentsSeparatedByString:@"="] lastObject]];
                _fullPhotoName = [[NSString alloc] initWithFormat:@"%@.png",[StringUtil getKeyStrOfPicUrl:_fullsizeUrl]];
            }
        }
        
		// notify delegate
		[self willLoadFullsizeFromUrl];
		
		_isFullsizeLoading = YES;
        
        NSLog(@"_fullsizeUrl---------%@",_fullsizeUrl);
        //_fullsizeUrl = @"http://120.132.153.6:8080/image/download?type=0&key=J3ia785x2";
		//NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_fullsizeUrl]];
        //[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        
        NSString *tmpStr = [localImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:[NSURL URLWithString:tmpStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
        
        [request setValue:@"netsense" forHTTPHeaderField:@"netsense"];
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        [urlCache setMemoryCapacity:1*1024*1024];
        NSCachedURLResponse *response =
        [urlCache cachedResponseForRequest:request];
        //判断是否有缓存
        if (response != nil){
            NSLog(@"如果有缓存输出，从缓存中获取数据");
            [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        }
        
		//_fullsizeConnection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
        _fullsizeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
		_fullsizeData = [[NSMutableData alloc] init];
	}
	else
	{
		[self willLoadFullsizeFromPath];
		
		_isFullsizeLoading = YES;
		
		// spawn a new thread to load from disk
		[NSThread detachNewThreadSelector:@selector(loadFullsizeInThread) toTarget:self withObject:nil];
	}
}

#pragma mark - 从本地加载图片
- (void)loadFullsizeInThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *path;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:_fullsizeUrl])
        {
            path = _fullsizeUrl;
        }
        else {
            path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _fullsizeUrl];
        }
			
	_fullsize = [[UIImage imageWithContentsOfFile:path] retain];
	
	_hasFullsizeLoaded = YES;
	_isFullsizeLoading = NO;

	[self performSelectorOnMainThread:@selector(didLoadFullsize) withObject:nil waitUntilDone:YES];
	
	[pool release];
}


- (void)loadThumbnailInThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *path;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:_thumbUrl])
        {
            path = _thumbUrl;
        }
        else {
            path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _thumbUrl];
        }
		
	_thumbnail = [[UIImage imageWithContentsOfFile:path] retain];
	
	_hasThumbLoaded = YES;
	_isThumbLoading = NO;
	
	[self performSelectorOnMainThread:@selector(didLoadThumbnail) withObject:nil waitUntilDone:YES];
	
	[pool release];
}

#pragma mark - 取消下载
- (void)unloadFullsize
{
	[_fullsizeConnection cancel];
	[self killFullsizeLoadObjects];
	
	_isFullsizeLoading = NO;
	_hasFullsizeLoaded = NO;
	
	[_fullsize release];
	_fullsize = nil;
}

- (void)unloadThumbnail
{
	[_thumbConnection cancel];
	[self killThumbnailLoadObjects];
	
	_isThumbLoading = NO;
	_hasThumbLoaded = NO;
	
	[_thumbnail release];
	_thumbnail = nil;
}


#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if( connection == _thumbConnection )
	{
		[self unloadThumbnail];
	}
    else if( connection == _fullsizeConnection )
	{
		[self unloadFullsize];
	}
	
	// turn off data indicator
	if( !_isFullsizeLoading && !_isThumbLoading )
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(galleryPhoto:didFailWithError:)]) {
        [_delegate galleryPhoto:self didFailWithError:error];
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse =(NSHTTPURLResponse*)response;
    
	if( conn == _thumbConnection ){
        _thumbConnectionResponseStatusCode = [httpResponse statusCode];
       // NSLog(@"_thumbConnectionResponseStatusCode---------%i",_thumbConnectionResponseStatusCode);
        [_thumbData setLength:0];
    }
    else if( conn == _fullsizeConnection )
    {
        _fullsizeConnectionResponseStatusCode = [httpResponse statusCode];
        //NSLog(@"_fullsizeConnectionResponseStatusCode---------%i",_fullsizeConnectionResponseStatusCode);
        [_fullsizeData setLength:0];
        _expectedContentLength = [response  expectedContentLength];
        //NSLog(@"_expectedContentLength----------%i",_expectedContentLength);
        if (_delegate && [_delegate respondsToSelector:@selector(galleryPhoto:didReceiveResponse:)]) {
            [_delegate galleryPhoto:self didReceiveResponse:httpResponse];
        }
    }
	
    NSLog(@"[response statusCode]----------%i",[httpResponse statusCode]);
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}



- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data 
{
	if( conn == _thumbConnection )
		[_thumbData appendData:data];
	
    else if( conn == _fullsizeConnection )
    {
        [_fullsizeData appendData:data];
        _currentContentLength = [_fullsizeData length];
        //NSLog(@"currentContentLength----------%i",_currentContentLength);
        if (_delegate && [_delegate respondsToSelector:@selector(galleryPhoto:didReceiveDataCurrentContentLength:)]) {
            [_delegate galleryPhoto:self didReceiveDataCurrentContentLength:_currentContentLength];
        }
    }
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}



- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
	if( conn == _thumbConnection )
	{
		_isThumbLoading = NO;
		_hasThumbLoaded = YES;
		
		// create new image with data
		_thumbnail = [[UIImage alloc] initWithData:_thumbData];
        
        //保存图片到本地
        NSString *picPath = [NSString stringWithFormat:@"%@",[[StringUtil newRcvFilePath] stringByAppendingPathComponent:_thumbnailPhotoName]];
        //NSLog(@"picPath-%@",picPath);
//        BOOL success= [_thumbData writeToFile:picPath atomically:YES];
        BOOL success = [EncryptFileManege saveFileWithPath:picPath withData:_thumbData];
        if(!success){
            NSLog(@"保存失败");
		}
        
		// cleanup 
		[self killThumbnailLoadObjects];
		
		// notify delegate
		if( _delegate ) 
			[self didLoadThumbnail];
	}
    else if(conn == _fullsizeConnection)
	{
		_isFullsizeLoading = NO;
		_hasFullsizeLoaded = YES;
		
		// create new image with data
        
        /*
        NSMutableData *dataObj;
        if ([_fullsizeData length] > 1024*1024*2) {
          dataObj = UIImageJPEGRepresentation([UIImage imageWithData:_fullsizeData],0.5);
        }
        else{
            dataObj = _fullsizeData;
        }
        */
        
        if (_fullsizeConnectionResponseStatusCode == 200) {
            //服务器文件存在时才保存
            _fullsize = [[UIImage alloc] initWithData:_fullsizeData];
            
            NSString *picPath = @"";
            UIImage *img = _fullsize;
            
//            add by shisp 如果是公众号图片下载 那么保存路径需要特殊处理
            if ([_fullsizeUrl hasPrefix:public_service_message_flag]) {
                ConvRecord *_convRecord = [[PSMsgDspUtil getUtil]getConvRecordFromPSMsgImgUrl:_fullsizeUrl];
                if (_convRecord) {
                    picPath = [PSMsgUtil getPSPicMsgImagePath:_convRecord];
                }
            }else if ([_fullsizeUrl hasPrefix:preview_h5_image_prefix]){
                picPath = [[PictureUtil getUtil]getPreviewImageLocalPath:_fullPhotoName];
            }
            else
            {
                picPath = [NSString stringWithFormat:@"%@",[[StringUtil newRcvFilePath] stringByAppendingPathComponent:_fullPhotoName]];

                //检查图片的尺寸，看是否需要裁剪
                CGSize _size = [talkSessionUtil getImageSizeAfterCrop:img];
                if(_size.width > 0 && _size.height>0)
                {
                    img= [ImageUtil scaledImage:img  toSize:_size withQuality:kCGInterpolationHigh];
                }
            }
            
            NSData *imageData=UIImageJPEGRepresentation(img,1);
//            BOOL success= [imageData writeToFile:picPath atomically:YES];
            BOOL success = [EncryptFileManege saveFileWithPath:picPath withData:imageData];
            if(!success){
                NSLog(@"保存失败");
            }
            
            //cleanup
            [self killFullsizeLoadObjects];
            
            
            if (_delegate && [_delegate respondsToSelector:@selector(galleryPhotoDidFinishLoadingData:)]) {
                [_delegate galleryPhotoDidFinishLoadingData:self];
            }
            
            if( _delegate )
                [self didLoadFullsize];
        }
        else{
            //服务器文件不存在，按照报错处理
            [self unloadFullsize];
            
            NSError *error = nil;
            if (_delegate && [_delegate respondsToSelector:@selector(galleryPhoto:didFailWithError:)]) {
                [_delegate galleryPhoto:self didFailWithError:error];
            }
        }
	}
	
	// turn off data indicator
	if( !_isFullsizeLoading && !_isThumbLoading ) 
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark Delegate Notification Methods


- (void)willLoadThumbFromUrl
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadThumbnailFromUrl:)])
		[_delegate galleryPhoto:self willLoadThumbnailFromUrl:_thumbUrl];
}


- (void)willLoadFullsizeFromUrl
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadFullsizeFromUrl:)])
		[_delegate galleryPhoto:self willLoadFullsizeFromUrl:_fullsizeUrl];
}


- (void)willLoadThumbFromPath
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadThumbnailFromPath:)])
		[_delegate galleryPhoto:self willLoadThumbnailFromPath:_thumbUrl];
}


- (void)willLoadFullsizeFromPath
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadFullsizeFromPath:)])
		[_delegate galleryPhoto:self willLoadFullsizeFromPath:_fullsizeUrl];
}


- (void)didLoadThumbnail
{
//	FLog(@"gallery phooto did load thumbnail!");
	if([_delegate respondsToSelector:@selector(galleryPhoto:didLoadThumbnail:)])
		[_delegate galleryPhoto:self didLoadThumbnail:_thumbnail];
}


- (void)didLoadFullsize
{
//	FLog(@"gallery phooto did load fullsize!");
	if([_delegate respondsToSelector:@selector(galleryPhoto:didLoadFullsize:)])
		[_delegate galleryPhoto:self didLoadFullsize:_fullsize];
}


#pragma mark -
#pragma mark Memory Management


- (void)killThumbnailLoadObjects
{
	
	[_thumbConnection release];
	[_thumbData release];
	_thumbConnection = nil;
	_thumbData = nil;
}



- (void)killFullsizeLoadObjects
{
	
	[_fullsizeConnection release];
	[_fullsizeData release];
	_fullsizeConnection = nil;
	_fullsizeData = nil;
}



- (void)dealloc
{
//	NSLog(@"FGalleryPhoto dealloc");
	
	[_delegate release];
	_delegate = nil;
	
	[_fullsizeConnection cancel];
	[_thumbConnection cancel];
	[self killFullsizeLoadObjects];
	[self killThumbnailLoadObjects];
	
	[_thumbUrl release];
	_thumbUrl = nil;
	
	[_fullsizeUrl release];
	_fullsizeUrl = nil;
	
	[_thumbnail release];
	_thumbnail = nil;
	
	[_fullsize release];
	_fullsize = nil;
	
    [_fullPhotoName release];;
    _fullPhotoName = nil;
    
    [_thumbnailPhotoName release];
    _thumbnailPhotoName = nil;
	[super dealloc];
}


@end
