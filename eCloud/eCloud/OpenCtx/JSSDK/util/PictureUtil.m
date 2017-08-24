//
//  PictureUtil.m
//  eCloud
//
//  Created by shisuping on 16/6/14.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "PictureUtil.h"
#import "FGalleryViewController.h"

#import "eCloudUser.h"

#import "DownloadFileObject.h"
#import "DownloadFileUtil.h"

#import "UploadFileModel.h"
#import "UploadFileObject.h"

#import "UploadFileUtil.h"
#import "UserTipsUtil.h"

#import "talkSessionViewController.h"
#import "PictureManager.h"
#import "LCLShareThumbController.h"
#import "ELCImagePickerController.h"
#import "LogUtil.h"

#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "talkSessionUtil.h"
#import "ImageUtil.h"

@interface PictureUtil () <UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,photosLibraryManagerDelegate,UploadFileDelegate,DownloadFileDelegate,FGalleryViewControllerDelegate>

@property (nonatomic,retain) NSMutableArray *imageArray;
@property (nonatomic,retain) PictureManager *pictureManager;
@property (nonatomic,retain) NSMutableArray *previewImageArray;

//要下载的图片token数组
@property (nonatomic,retain) NSArray *imageTokenArray;
@end

static PictureUtil *pictureUtil;

@implementation PictureUtil
{
    UploadFileUtil *uploadFileUtil;
    DownloadFileUtil *downloadFileUtil;
    
    FGalleryViewController *gallery;
    
}
@synthesize imageArray;
@synthesize pictureManager;
@synthesize imageTokenArray;
@synthesize previewImageArray;

- (id)init
{
    self = [super init];
    if (self) {
        self.imageArray = [NSMutableArray array];
        self.pictureManager = [[PictureManager alloc]init];
    }
    return self;
}

+ (PictureUtil *)getUtil
{
    if (pictureUtil == nil) {
        pictureUtil = [[super alloc] init];
    }
    return pictureUtil;
}

//弹出拍照还是从图库选择提示框
- (void)presentSheet:(UIViewController *)curVC
{
    if (IOS8_OR_LATER && IS_IPHONE) {
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"chatBackground_take_photo"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //            拍照
            [self getCameraPicture];
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *choosePhotoAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"chatBackground_choose_photos"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //            选择照片
            [self selectExistingPicture];
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertCtl addAction:takePhotoAction];
        [alertCtl addAction:choosePhotoAction];
        [alertCtl addAction:cancelAction];
        
        [UIAdapterUtil presentVC:alertCtl];
        //        [self presentViewController:alertCtl animated:YES completion:nil];
    }else{
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:nil
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString:@"chatBackground_take_photo"], [StringUtil getLocalizableString:@"chatBackground_choose_photos"], nil];
        [menu showInView:curVC.view];
    }
}

//相机拍摄图片
-(void) getCameraPicture {
    
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

    if(authStatus ==AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        // The user has explicitly denied permission for media capture.
        NSLog(@"Denied");     //应该是这个，如果不允许的话
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
        
        }
        //判断是否支持摄像头
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"chatBackground_warning"]
                                                            message: [StringUtil getLocalizableString:@"chatBackground_warning_message"]
                                                           delegate:nil
                                                  cancelButtonTitle: [StringUtil getLocalizableString:@"confirm"]
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
            
        }
        UIImagePickerController *pickCtl = [[UIImagePickerController alloc]init];
        pickCtl.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickCtl.delegate = self;
        [UIAdapterUtil presentVC:pickCtl];
        [pickCtl release];
    
}
#pragma mark navigation delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imageArray removeAllObjects];
    
    UIImage *_image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:_image];
    if(_size.width > 0 && _size.height > 0)
    {
        _image = [ImageUtil scaledImage:_image  toSize:_size withQuality:kCGInterpolationMedium];
    }
    
    UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);//存入相册
    
    //		拍照后再压缩成jpeg格式？
    NSData *data=UIImageJPEGRepresentation(_image,0.5);
    
    NSString *currenttimeStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
    
    //存入本地
    NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
    BOOL success = [data writeToFile:picpath atomically:YES];
    
    if (success) {
        [self.imageArray addObject:picpath];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPicture:)]) {
            [self.delegate didSelectPicture:self.imageArray];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//多选图片
- (void)selectExistingPicture
{
    if (IOS_VERSION_BEFORE_6) {
        [self.pictureManager obtainPicturesFrom:fromLibrary delegate:self];
    }else{
        //用户手动取消授权
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
            [talkSessionViewController showCanNotAccessPhotos];
            return;
        }
        else {
            //其他情况下都去请求访问图片库
            [(PictureManager *)pictureManager obtainPicturesFrom:fromLibrary delegate:self];
        }
    }
}

- (void)showSelectedPic:(NSArray *)selectImages
{
    [self.imageArray removeAllObjects];
    [self.imageArray addObjectsFromArray:selectImages];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadPicFinished" object:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPicture:)]) {
        [self.delegate didSelectPicture:self.imageArray];
    }

}

//获取照片成功返回
- (void)photosLibraryManager:(photosLibraryManager *)manager pictureInfo:(NSArray *)pictures
{
    LCLShareThumbController*assetTable		=	[[LCLShareThumbController alloc]initWithNibName:nil bundle:nil];
    ELCImagePickerController *elcPicker		=	[[ELCImagePickerController alloc] initWithRootViewController:assetTable];
    assetTable.pre_delegete=self;
    [assetTable setParent:elcPicker];
    [assetTable preparePhotos:pictures];
    [elcPicker setDelegate:self];
    
    [UIAdapterUtil presentVC:elcPicker];
    //    [self presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [assetTable release];

}
//操作完成且不发生错误是调用
- (void)photosLibraryManagerDidFinished:(photosLibraryManager *)manager
{
    NSLog(@"%s",__FUNCTION__);
}
//当操作发生错误时调用
- (void)photosLibraryManager:(photosLibraryManager *)manager error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    NSLog(@"%s",__FUNCTION__);
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark 上传图片
- (void)uploadImage
{
    if (!self.imageArray || self.imageArray.count == 0) {
        [UserTipsUtil showAlert:@"请先选择图片"];
        return;
    }
    NSMutableArray *mArr = [NSMutableArray array];
    long long curMilliSecond = [StringUtil currentMillionSecond];

    for (id _id in self.imageArray) {
        UploadFileObject *uploadFileObject = [[[UploadFileObject alloc]init]autorelease];
        if ([_id isKindOfClass:[NSString class]]) {
            uploadFileObject.uploadFilePath = _id;
            
        }else if ([_id isKindOfClass:[WoALAsset class]]){
            WoALAsset *_asset = (WoALAsset *)_id;
            
            CGImageRef imageRef;
            
            ALAsset *asset=[_asset asset];
            ALAssetRepresentation* rep = [asset defaultRepresentation];
            imageRef = [rep fullScreenImage];
            
            if(imageRef)
            {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
                if(_size.width > 0 && _size.height > 0)
                {
                    image = [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
                }
                NSData * data =UIImageJPEGRepresentation(image, 0.5);
                NSLog(@"-----------------picdata--: %d",data.length);
                
                NSString *picName = [NSString stringWithFormat:@"%lld.jpg",(curMilliSecond++)];
                
                //存入本地
                NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:picName];
                BOOL success = [data writeToFile:picpath atomically:YES];
                
                if (success) {
                    uploadFileObject.uploadFilePath = picpath;
                }
            }
        }
        if (uploadFileObject.uploadFilePath) {
            uploadFileObject.uploadFileType = type_upload_pic;
            [mArr addObject:uploadFileObject];
            
        }
    }
    if (mArr.count) {
        if (!uploadFileUtil) {
            uploadFileUtil = [[UploadFileUtil alloc]init];
            uploadFileUtil.delegate = self;
        }
        [uploadFileUtil upload:mArr];
    }
}
#pragma mark upload file delegate
- (void)uploadFinish:(UploadFileUtil *)uploadFileUtil andResult:(NSArray *)uploadFinishArray
{
    NSLog(@"%s %@",__FUNCTION__,uploadFinishArray);

    NSMutableArray *mArray = [NSMutableArray array];
    NSMutableArray *urlArray = [NSMutableArray array];
    
    for (UploadFileObject *_object in uploadFinishArray) {
        NSString *tokenStr = [_object getFileToken];
        if (tokenStr) {
            [mArray addObject:tokenStr];
            
            NSString *_url = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig]getNewPicDownloadUrl],tokenStr,[StringUtil getResumeDownloadAddStr]];
            [urlArray addObject:_url];
        }
    }
    self.imageTokenArray = mArray;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUploadPictureFinish:)]) {
        [self.delegate didUploadPictureFinish:urlArray];
    }
}

#pragma mark 下载图片
- (void)downloadImage:(NSArray *)tokenArray
{
    if (tokenArray.count) {
        self.imageTokenArray = tokenArray;
    }
    if (self.imageTokenArray.count) {
        if (!downloadFileUtil) {
            downloadFileUtil = [[DownloadFileUtil alloc]init];
            downloadFileUtil.delegate = self;
        }
        
        NSMutableArray *mArray = [NSMutableArray array];
        for (NSString *tokenStr in self.imageTokenArray) {
            DownloadFileObject *_object = [[[DownloadFileObject alloc]init]autorelease];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",tokenStr];
            NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
            _object.downloadFilePath = filePath;
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getNewPicDownloadUrl],tokenStr,[StringUtil getResumeDownloadAddStr]];
            _object.downloadUrl = urlStr;
            [mArray addObject:_object];
        }
        
        
        [downloadFileUtil downloadFile:mArray];
    }else{
        [UserTipsUtil showAlert:@"请先上传图片"];
    }
}

//预览图片
- (FGalleryViewController *)previewImages:(NSArray *)imageUrlArray andCurUrl:(NSString *)curUrl
{
    self.previewImageArray = [NSMutableArray array];
    for (NSString *imageUrl in imageUrlArray) {
        NSString *temp = [NSString stringWithFormat:@"%@|%@",preview_h5_image_prefix,[imageUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self.previewImageArray addObject:temp];
    }
    if (self.previewImageArray.count == 0) {
        return nil;
    }
    
    int curIndex = 0;
    
    if (curUrl.length > 0) {
        int tmpIndex = 0;
        for (NSString *_imageUrl in imageUrlArray) {
            if ([_imageUrl compare:curUrl options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                break;
            }
            tmpIndex++;
        }
        curIndex = tmpIndex;
    }
    
    gallery = [[FGalleryViewController alloc] initWithPhotoSource:self withCurrentIndex:curIndex];
    gallery.needDisplaySwitchButton = NO;
    return [gallery autorelease];
}
#pragma mark FGallery Delegate
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery
{
    return self.previewImageArray.count;
}
- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index{
    return FGalleryPhotoSourceTypeNetwork;
}
- (NSString*)photoGallery:(FGalleryViewController*)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index{
    if (size == FGalleryPhotoSizeThumbnail) {
        return nil;
    }
    return self.previewImageArray[index];
}

//去除前缀得到真实地URL
- (NSString *)getRealImageUrl:(NSString *)previewImageUrl
{
    if (previewImageUrl.length > 0) {
        NSArray *tmp = [previewImageUrl componentsSeparatedByString:@"|"];
        if (tmp.count == 2) {
            NSString *realUrl = tmp[1];
            return realUrl;
        }
    }
    return nil;
}

- (NSString *)getPreviewImageLocalName:(NSString *)previewImageUrl
{
    if (previewImageUrl.length > 0 ) {
        NSArray *tmp = [previewImageUrl componentsSeparatedByString:@"|"];
        if (tmp.count == 2) {
            NSString *realUrl = tmp[1];
            NSString *imageName = [realUrl lastPathComponent];
            NSRange _range = [imageName rangeOfString:@"."];
            if (_range.length == 0) {
                imageName = [NSString stringWithFormat:@"%@.png",imageName];
            }
            return imageName;
        }
    }
    return nil;
}

//返回 预览图片的 图片 的 本地保存路径
- (NSString *)getPreviewImageLocalPath:(NSString *)imageName
{
    NSString *imagePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:imageName];
    return imagePath;
}

//上传图片至客储服务器

- (void)uploadImageInGuest{
    
    if (!self.imageArray || self.imageArray.count == 0) {
        [UserTipsUtil showAlert:@"请先选择图片"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil showLoadingView:@"上传中..."];
    });
    
    dispatch_queue_t queue = dispatch_queue_create("get token and upload ...", NULL);
    dispatch_async(queue, ^{
        
        NSString *urlStr  = @"http://customer.demo.longhu.net:8080/LHService/uploadImgCommon/uploadFile";
        
        NSURL *dataurl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *datarequest = [[ASIFormDataRequest alloc] initWithURL:dataurl];
        [datarequest setDelegate:self];
        
        WoALAsset *_asset = (WoALAsset *)self.imageArray[0];
        
        CGImageRef imageRef;
        
        ALAsset *asset=[_asset asset];
        ALAssetRepresentation* rep = [asset defaultRepresentation];
        imageRef = [rep fullScreenImage];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        NSData *mydata=UIImageJPEGRepresentation(image , 0.5);
        NSString *pictureDataString= [mydata base64Encoding];
        [datarequest setPostValue:pictureDataString forKey:@"base64File"];
        [datarequest setPostValue:@"" forKey:@"base64FileIcon"];
        [datarequest setPostValue:@"wulin3" forKey:@"loginName"];
    
        [datarequest setDidFinishSelector:@selector(uploadResumeFileComplete:)];
        [datarequest setDidFailSelector:@selector(uploadResumeFileFail:)];
        
        [datarequest startAsynchronous];
        [datarequest release];
        
        
    });
    dispatch_release(queue);
}

#pragma mark - 上传成功
-(void)uploadResumeFileComplete:(ASIHTTPRequest *)request{
    
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
    
    [UserTipsUtil hideLoadingView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUploadPictureFinish:)]) {
        [self.delegate didUploadPictureFinish:response];
    }
}

#pragma mark - 上传失败
-(void)uploadResumeFileFail:(ASIHTTPRequest *)request{
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUploadPictureFinish:)]) {
        [self.delegate didUploadPictureFinish:@"上传失败"];
    }
    [UserTipsUtil hideLoadingView];
}


@end
