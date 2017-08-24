//
//  photosLibraryManager.h
//  PhotoSea
//
//  Created by  lyong on 13-5-14.
//  Copyright (c) 2013年 lyong. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ELCImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAssetTablePicker.h"


/*本地图片相关操作类*/
enum pictureError
{
    pic_noError =   10,
    pic_sourceType_unknow,      //图像源未知
    pic_sourceUnAvailable       //图像源不可用
};

enum mPictureSourceType
{
    fromCamera  =   0,  //源来自照相机
    fromLibrary,        	  //源来自iphoto Library
    fromLibraryOwn      //源来自自定以库
};
typedef int pictureSourceType;

@class photosLibraryManager;
@protocol photosLibraryManagerDelegate <NSObject>
@optional
//获取照片成功返回
- (void)photosLibraryManager:(photosLibraryManager *)manager pictureInfo:(NSArray *)pictures;
//操作完成且不发生错误是调用
- (void)photosLibraryManagerDidFinished:(photosLibraryManager *)manager;
//当操作发生错误时调用
- (void)photosLibraryManager:(photosLibraryManager *)manager error:(NSError *)error;
@end


@interface WoALAsset : NSObject
{
	BOOL			selectToPreview;	//当前单个选中预览内容
	
    ALAsset 	*asset;
    BOOL    		isSelected; //判断是否被选中
    int     		index;
	
	UIImage	*_thumb;	//缩略图,如果asset不为空，则该字段为空
}
@property							BOOL		selectToPreview;
@property(nonatomic)        BOOL 	isSelected;
@property(nonatomic,retain) ALAsset *asset;
@property(nonatomic,retain) UIImage	*_thumb;	//缩略图
@property                   int index;
@end




@interface photosLibraryManager : NSObject
{
    /*标志是否已经扫描过系统的图片库,值为NO时需要重新扫描
     如果为当前app为第一次登录，值为NO
     如果当前app进入后台，值为NO，当app从后台进入前端是需要扫描
     */
    BOOL            hasScanPhotoLibrary;
    
    id<photosLibraryManagerDelegate>_delegate;
    //存储所有资源的信息
    NSMutableArray  *items;
    /*记录所有选中的资源*/
    NSMutableArray  *selectedItems;
    ALAssetsLibrary *_library;
    dispatch_semaphore_t assetSemaphore;
}
@property(nonatomic,readonly)BOOL hasScanPhotoLibrary;
@property(nonatomic,readonly)NSMutableArray *selectedItems;
@property(nonatomic,retain) NSMutableArray  *items;
- (void)obtainItemFromPhotoLibraryWithFilter:(ALAssetsFilter *)filter;
//所有子类需要重载的方法
- (void)complete:(NSArray *)array;
- (void)failed:(NSError *)error;
- (void)sendMessageBackToMainThread;

/***
 将asset复制至指定path的文件夹，path为包含文件名，例如:./file/img001.png(v001.mp4)
 ***/
//- (BOOL)copyAsset:(ALAsset *)asset ToPath:(NSString *)path;
@end



@interface PictureManager : photosLibraryManager<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ELCImagePickerControllerDelegate>
{
    int             sourceType;
}
@property(nonatomic,readonly)int  sourceType;
- (void)launchCamera;
//显示所有缩略图
- (void)showThumbnail:(NSArray *)thumbnails aboveController:(UIViewController *)controller;
- (void)obtainPicturesFrom:(pictureSourceType)type delegate:(id<photosLibraryManagerDelegate>)target;

/***
 将指定path的图片文件复制至图片库,并且返回图片库的保存该图片的路径,失败则返回空值
 ***/
- (NSString *)saveImageFromFile:(NSString *)path;

@end



@interface VideoManager : photosLibraryManager
{
    
}
- (void)obtainVideoWithdelegate:(id<photosLibraryManagerDelegate>)target;
/***
 将指定path的视频文件复制至图片库,并且返回图片库的保存该视频的路径,失败则返回空值
 ***/
- (NSString *)saveVideoFromFile:(NSString *)path;
@end



@interface LCLAllPhotoLibraryManager : photosLibraryManager

- (void)obtainAllPhotoLibraryWithdelegate:(id<photosLibraryManagerDelegate>)target;
@end

