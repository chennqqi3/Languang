//
//  PictureUtil.h
//  eCloud
//  和图片相关的接口 通过此程序，h5应用可以拍照，可以从图库选择多张图片，上传至我们的文件服务器，其它应用根据url去下载图片
//  Created by shisuping on 16/6/14.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

//h5可以调用我们的接口预览图片，需要定义一个标识，用来标识这时一个 h5 传过来的url
#define preview_h5_image_prefix @"PreviewH5ImageUrl"

@class FGalleryViewController;

@protocol PictureDelegate <NSObject>

/*
 功能说明
 用户选择了图片或者拍了照片的回调
 
 参数
 imageArray:用户选择的图片的路径数组
 */
- (void)didSelectPicture:(NSArray *)imageArray;

/*
 功能说明
 上传图片完成后的回调
 
 参数
 imageUrlArray:图片上传成功后 下载url的数组
 */
- (void)didUploadPictureFinish:(NSArray *)imageUrlArray;

//预览图片

@end

@interface PictureUtil : NSObject

@property (nonatomic,assign) id<PictureDelegate> delegate;

+ (PictureUtil *)getUtil;

//弹出拍照还是从图库选择提示框
- (void)presentSheet:(UIViewController *)curVC;

//显示用户选择的图片
- (void)showSelectedPic:(NSArray *)selectImages;

//上传图片
- (void)uploadImage;

//从我们的文件服务器下载图片 参数是图片对应的token数组
- (void)downloadImage:(NSArray *)tokenArray;

//上传图片到客户的服务器
- (void)uploadImageInGuest;

/*
 功能描述
 下载预览图片，可以下载预览多张图片
 
 参数
 imageUrlArray：要预览的图片下载url数组
 curUrl：当前要预览的图片下载Url
 */
- (FGalleryViewController *)previewImages:(NSArray *)imageUrlArray andCurUrl:(NSString *)curUrl;

//根据url获取图片名字
- (NSString *)getPreviewImageLocalName:(NSString *)previewImageUrl;

//返回 预览图片的 图片 的 本地保存路径
- (NSString *)getPreviewImageLocalPath:(NSString *)imageName;

//去除前缀得到真实地URL
- (NSString *)getRealImageUrl:(NSString *)previewImageUrl;

//相机拍摄图片
-(void) getCameraPicture;

//多选图片
- (void)selectExistingPicture;



@end
