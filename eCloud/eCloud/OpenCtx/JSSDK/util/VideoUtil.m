//
//  VideoUtil.m
//  eCloud
//
//  Created by Ji on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "VideoUtil.h"
#import "StringUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "JsObjectCViewController.h"
#import "PlayVideoViewController.h"
#import "eCloudDefine.h"




@interface VideoUtil()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *_pickerVideo;

}

@end

static VideoUtil *videoUtil;

@implementation VideoUtil

+ (VideoUtil *)getUtil{
    
    if (videoUtil == nil) {
        
        videoUtil = [[super alloc]init];
        
    }
    return videoUtil;
}

- (void)startVideo{
    
    //判断是否支持摄像头
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_camera_not_support_warning"]
                                                        message:[StringUtil getLocalizableString:@"chats_talksession_message_camera_not_support"]
                                                       delegate:nil
                                              cancelButtonTitle: [StringUtil getLocalizableString:@"confirm"]
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
        
    }

    _pickerVideo=[[UIImagePickerController alloc]init];
    _pickerVideo.delegate=self;//设置代理，检测操作
    _pickerVideo.sourceType=UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
    _pickerVideo.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
    _pickerVideo.mediaTypes=@[(NSString *)kUTTypeMovie];
    _pickerVideo.videoQuality=UIImagePickerControllerQualityTypeMedium;// UIImagePickerControllerQualityTypeIFrame1280x720;
    _pickerVideo.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
    _pickerVideo.allowsEditing=YES;//允许编辑
    [UIAdapterUtil presentVC:_pickerVideo];
    //    [self presentViewController:pickerVideo animated:YES completion:nil];
    [_pickerVideo release];


}

#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
        
    }
    [_pickerVideo dismissViewControllerAnimated:YES completion:nil];

}
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:videoPath forKey:@"videoPath"];
    }
    
    
}

- (void)playVideo
{
    PlayVideoViewController *play = [[[PlayVideoViewController alloc]init]autorelease];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:play];
    [UIAdapterUtil presentVC:nv];

}
@end
