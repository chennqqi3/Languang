//
//  photosLibraryManager.m
//  PhotoSea
//
//  Created by  lyong on 13-5-14.
//  Copyright (c) 2013年 lyong. All rights reserved.
//

#import "PictureManager.h"
#import "UIAdapterUtil.h"

@implementation photosLibraryManager
@synthesize hasScanPhotoLibrary;
@synthesize selectedItems;
@synthesize items;
- (void)dealloc
{
    if(NULL != assetSemaphore)
    {
        dispatch_release(assetSemaphore);
    }
    [selectedItems removeAllObjects];
    [selectedItems release];
    [items removeAllObjects];
    [items release];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    [_library release];
    [super dealloc];
}

- (id)init
{
    self    =   [super init];
    if(self)
    {
        hasScanPhotoLibrary =   NO;
        items               =   [[NSMutableArray array]retain];
        selectedItems       =   [[NSMutableArray array]retain];;
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(enterBackground:)
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
        //从新开始获取图片信息
        _library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

//程序进入后台
- (void)enterBackground:(NSNotification *)notification
{
    hasScanPhotoLibrary =   NO;
}

- (void)sendMessageBackToMainThread
{
    
}

- (void)obtainItemFromPhotoLibraryWithFilter:(ALAssetsFilter *)filter
{
    
    NSMutableArray  *pictures   =   [NSMutableArray array];
    //从新开始获取图片信息
    
    ALAssetsLibraryGroupsEnumerationResultsBlock groupEnumBlock = ^(ALAssetsGroup *group, BOOL *stop){
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        //获取所有分组
        //如果没有任何数据或者数据获取完毕时，group为nil
        if (group == nil)
        {
            [self complete:pictures];
            if (assetSemaphore != NULL)
            {
                dispatch_semaphore_signal(assetSemaphore);
            }
            return;
        }
        //设置过滤模式，只获取图片信息
        //[group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group setAssetsFilter:filter];
        //获取改组所有图片
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
         {
             if(result == nil)
             {
                 return;
             }
             NSAutoreleasePool *assetPool = [[NSAutoreleasePool alloc] init];
             WoALAsset *wo  =   [[WoALAsset alloc]init];
             wo.asset       =   result;
             [pictures addObject:wo];
             //[pictures insertObject:wo atIndex:0];
             [wo release];
             [assetPool drain];
         }];
        [pool drain];
        
    };
    
    // create semaphore(信号量)
    if(NULL != assetSemaphore)
    {
        dispatch_release(assetSemaphore);
        assetSemaphore  =   NULL;
    }
    assetSemaphore = dispatch_semaphore_create(0);
    
    //如果获取的过程中发生错误调用
    ALAssetsLibraryAccessFailureBlock errorBlock = ^(NSError *error)
    {
        if (assetSemaphore != NULL)
        {
            dispatch_semaphore_signal(assetSemaphore);
        }
        [self failed:error];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^()
                   {
                       [_library enumerateGroupsWithTypes: ALAssetsGroupSavedPhotos
                                               usingBlock: groupEnumBlock
                                             failureBlock: errorBlock];
                   });
    //    [_library enumerateGroupsWithTypes: ALAssetsGroupSavedPhotos
    //                            usingBlock: groupEnumBlock
    //                          failureBlock: errorBlock];
    
    // wait to complete the enumeration action
    dispatch_semaphore_wait(assetSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)complete:(NSArray *)array
{
    
}

- (void)failed:(NSError *)error
{
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^()
                   {
                       if(_delegate && [_delegate respondsToSelector:@selector(photosLibraryManager:error:)])
                       {
                           [_delegate photosLibraryManager:self error:error];
                       }
                   });
}

//- (BOOL)copyAsset:(ALAsset *)asset ToPath:(NSString *)path
//{
//    if(nil == asset)
//    {
//        return NO;
//    }
//    
//    if(nil == path || [path length] <= 0 )
//    {
//        return NO;
//    }
//    
//    ALAssetRepresentation* rep = [asset defaultRepresentation];
//    int size = [rep size];
//    const int bufferSize = 8192;
//    
//    FILE* f = fopen([path UTF8String], "wb+");
//    if (f)
//    {
//        unsigned char *buffer = new unsigned char[bufferSize];
//        int read = 0, offset = 0, written = 0;
//        NSError* err;
//        if (size != 0)
//        {
//            do {
//                read = [rep getBytes:buffer
//                          fromOffset:offset
//                              length:bufferSize
//                               error:&err];
//                written = fwrite(buffer, sizeof(char), read, f);
//                offset += read;
//                
//            } while (read != 0);
//        }
//        
//        fclose(f);
//        delete [] buffer;
//        
//        return YES;
//    }
//    return NO;
//}

@end

@implementation PictureManager
@synthesize sourceType;
- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}


- (NSString *)saveImageFromFile:(NSString *)path
{
    if(nil == path || [path length] <= 0)
    {
        return nil;
    }

    __block NSString* url  = nil;
    UIImage* image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
    //UIImage *image  =   [UIImage imageWithData:[[LCLFileManager shareFileManager]contentOfPath:path]];
    ALAssetsLibraryWriteImageCompletionBlock block = ^(NSURL *assetURL, NSError *error)
    {
        if(nil == error)
        {
            url = [[assetURL absoluteString] retain];
        }
        
        dispatch_semaphore_signal(assetSemaphore);
    };
    
    if(NULL != assetSemaphore)
    {
        dispatch_release(assetSemaphore);
    }
    assetSemaphore = dispatch_semaphore_create(0);
    
    [_library writeImageToSavedPhotosAlbum:[image CGImage]
                               orientation:(ALAssetOrientation)[image imageOrientation]
                           completionBlock:block];
    
    dispatch_semaphore_wait(assetSemaphore, DISPATCH_TIME_FOREVER);
    
    NSString *result    = (nil == url)?nil:[NSString stringWithString:url];
    [url release];
    return result;
}

- (void)obtainPicturesFrom:(pictureSourceType)type delegate:(id<photosLibraryManagerDelegate>)target
{
    _delegate    =   target;
    sourceType   =   type;
    
    [NSThread detachNewThreadSelector:@selector(obtain) toTarget:self withObject:nil];
}

- (void)obtain
{
    NSAutoreleasePool   *pool   =   [[NSAutoreleasePool alloc]init];
    NSString    *errorDomain    =   nil;
    int         errorType       =   pic_noError;
    
    //设置源
    switch (sourceType) {
        case fromCamera:
        {
            //判断当前源在当前设备是否可用
            if(NO == [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                errorType   =   pic_sourceUnAvailable;
                errorDomain =  @"输入源不可用";
            }
            else
            {
                [self launchCamera];
            }
        }
            break;
        case fromLibrary:
        {
            
            if(hasScanPhotoLibrary)
            {
                [self sendMessageBackToMainThread];
            }
            //判断当前源在当前设备是否可用
            else if(NO == [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                errorType   =   pic_sourceUnAvailable;
                errorDomain =  @"输入源不可用";
            }
            else
            {
                [self obtainItemFromPhotoLibraryWithFilter:[ALAssetsFilter allPhotos]];
            }
        }
            break;
        case fromLibraryOwn:
        {
            
        }
            break;
            //当前源为未知
        default:
        {
            errorType   =   pic_sourceType_unknow;
            errorDomain =  @"图片源未知";
        }
            break;
    }
    
    //如果发生了错误，则发送错误消息，返回
    if(pic_noError != errorType)
    {
        NSError *error  =   [NSError errorWithDomain:errorDomain
                                                code:errorType
                                            userInfo:nil];
        [self failed:error];
    }
    
    [pool drain];
}


- (void)showThumbnail:(NSArray *)thumbnails aboveController:(UIViewController *)controller
{
    if(nil == thumbnails || [thumbnails count] <= 0)
    {
        return;
    }
    ELCAssetTablePicker *assetTable     = [[ELCAssetTablePicker alloc]initWithNibName:nil bundle:nil];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:assetTable];
    
    [assetTable setParent:elcPicker];
    [assetTable preparePhotos:thumbnails];
	[elcPicker setDelegate:controller];
    
    [UIAdapterUtil presentVC:elcPicker];
//    [controller presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [assetTable release];
}

- (void)launchCamera
{
    UIImagePickerController *picker =   [[UIImagePickerController alloc] init];
    picker.delegate                 =   self;
    picker.allowsEditing            =   YES;
    picker.sourceType               =   UIImagePickerControllerSourceTypeCamera;
    
    UIWindow   *window  =   [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window.rootViewController presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)sendMessageBackToMainThread
{
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^()
                   {
                       if(_delegate && [_delegate respondsToSelector:@selector(photosLibraryManager:pictureInfo:)])
                       {
                           [_delegate photosLibraryManager:self pictureInfo:items];
                       }
                   });
    
}

- (void)complete:(NSArray *)array
{
    //清楚所有记录
    [selectedItems removeAllObjects];
    [items removeAllObjects];
    
    [items addObjectsFromArray:array];
    for (int i = 0; i < (int)[items count]; i++)
    {
        ((WoALAsset *)[items objectAtIndex:i]).index    =   i;
    }
    [self sendMessageBackToMainThread];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [selectedItems removeAllObjects];
    [selectedItems addObjectsFromArray:info];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark –
#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    //UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}


@end


@implementation VideoManager

- (void)obtainVideoWithdelegate:(id<photosLibraryManagerDelegate>)target
{
    _delegate   =   target;
    [NSThread detachNewThreadSelector:@selector(obtain) toTarget:self withObject:nil];
}

- (void)obtain
{
    NSAutoreleasePool *pool =   [[NSAutoreleasePool alloc]init];
    [self obtainItemFromPhotoLibraryWithFilter:[ALAssetsFilter allVideos]];
    [pool drain];
}

- (void)complete:(NSArray *)array
{
    //清楚所有记录
    [selectedItems removeAllObjects];
    [items removeAllObjects];
    
    [items addObjectsFromArray:array];
    [self sendMessageBackToMainThread];
}

- (void)sendMessageBackToMainThread
{
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^()
                   {
                       if(_delegate && [_delegate respondsToSelector:@selector(photosLibraryManager:pictureInfo:)])
                       {
                           [_delegate photosLibraryManager:self pictureInfo:items];
                       }
                   });
    
}


- (NSString *)saveVideoFromFile:(NSString *)path
{
    if(nil == path || [path length] <= 0)
    {
        return nil;
    }
    
    __block NSString * _url = nil;
    
    ALAssetsLibraryWriteVideoCompletionBlock block = ^(NSURL *assetURL, NSError *error)
    {
        if(nil == error)
        {
            _url    =   [[assetURL absoluteString] retain];
        }
        
        dispatch_semaphore_signal(assetSemaphore);
    };
    
    NSURL* url = [NSURL fileURLWithPath:path isDirectory:YES];
    
    if(NULL != assetSemaphore)
    {
        dispatch_release(assetSemaphore);
    }
    assetSemaphore = dispatch_semaphore_create(0);
    BOOL flag = [_library videoAtPathIsCompatibleWithSavedPhotosAlbum:url];
    
    if (flag == TRUE)
    {
        [_library writeVideoAtPathToSavedPhotosAlbum:url
                                     completionBlock:block];
        
        dispatch_semaphore_wait(assetSemaphore, DISPATCH_TIME_FOREVER);
    }
    
    NSString *result    = (nil == _url)?nil:[NSString stringWithString:_url];
    [_url release];
    
    return result;
}

@end

@implementation LCLAllPhotoLibraryManager

- (void)obtainAllPhotoLibraryWithdelegate:(id<photosLibraryManagerDelegate>)target
{
    _delegate   =   target;
    [NSThread detachNewThreadSelector:@selector(obtain) toTarget:self withObject:nil];
}

- (void)obtain
{
    NSAutoreleasePool *pool =   [[NSAutoreleasePool alloc]init];
    [self obtainItemFromPhotoLibraryWithFilter:[ALAssetsFilter allAssets]];
    [pool drain];
}

- (void)complete:(NSArray *)array
{
    //清楚所有记录
    [selectedItems removeAllObjects];
    [items removeAllObjects];
    
    [items addObjectsFromArray:array];
    [self sendMessageBackToMainThread];
}

- (void)sendMessageBackToMainThread
{
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^()
                   {
                       if(_delegate && [_delegate respondsToSelector:@selector(photosLibraryManager:pictureInfo:)])
                       {
                           [_delegate photosLibraryManager:self pictureInfo:items];
                       }
                   });
    
}

@end

@implementation WoALAsset
@synthesize isSelected;
@synthesize asset;
@synthesize index;
@synthesize _thumb;
@synthesize selectToPreview;
- (void)dealloc
{
	[_thumb release];
    [asset release];
    [super dealloc];
}
@end

