//
//  LANGUANGShareView.m
//  eCloud
//
//  Created by Ji on 17/6/4.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGShareView.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "talkSessionViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "EncryptFileManege.h"
#import "eCloudUser.h"
#import "eCloudDefine.h"

@interface LANGUANGShareView ()

@property(nonatomic,retain)UIView *infoView;
@property(nonatomic,retain)UIButton *MessageButton;

@end

@implementation LANGUANGShareView

static LANGUANGShareView *shareView;

+(LANGUANGShareView *)getShareView
{
    if(shareView == nil)
    {
        shareView = [[self alloc]init];
    }
    return shareView;
}

- (UIView *)shareView
{

    self.infoView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT,SCREEN_WIDTH,100)];
    self.infoView.backgroundColor = [UIColor whiteColor];
    
    UIButton *friendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    friendButton.frame = CGRectMake(20, 10, 60, 60);
    [friendButton setBackgroundImage:[StringUtil getImageByResName:@"umsocial_wechat.png"]forState:UIControlStateNormal];
    [friendButton setTitle:@"微信好友" forState:UIControlStateNormal];
    //friendButton.backgroundColor = [UIColor redColor];
    [friendButton addTarget:self action:@selector(shareFriends)forControlEvents:UIControlEventTouchUpInside];
    friendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [friendButton setTitleEdgeInsets:UIEdgeInsetsMake(70 ,0, 0,0)];
    [friendButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    friendButton.titleLabel.font = [UIFont systemFontOfSize: 11.0];
    
    
    UIButton *CircleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    CircleButton.frame = CGRectMake(110, 10, 60, 60);
    [CircleButton setBackgroundImage:[StringUtil getImageByResName:@"umsocial_wechat_timeline.png"]forState:UIControlStateNormal];
    [CircleButton setTitle:@"微信朋友圈" forState:UIControlStateNormal];
    //friendButton.backgroundColor = [UIColor redColor];
    [CircleButton addTarget:self action:@selector(shareCircleButton)forControlEvents:UIControlEventTouchUpInside];
    CircleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [CircleButton setTitleEdgeInsets:UIEdgeInsetsMake(70 ,0, 0,0)];
    [CircleButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    CircleButton.titleLabel.font = [UIFont systemFontOfSize: 11.0];
    
    [self.infoView addSubview:friendButton];
    [self.infoView addSubview:CircleButton];
    
    [self.infoView release];
    return self.infoView;
}


- (void)shareFriends{
    
    [[talkSessionViewController getTalkSession]setInfoViewFrame:NO];
    
    if(self.editRecord && self.editRecord.msg_type == type_text)
    {
        [self ShareIsText:YES isFriend:YES];
        
    }else{
        
        [self ShareIsText:NO isFriend:YES];
    }
 
}

- (void)shareCircleButton{
    
    [[talkSessionViewController getTalkSession]setInfoViewFrame:NO];
    
    if(self.editRecord && self.editRecord.msg_type == type_text)
    {
        [self ShareIsText:YES isFriend:NO];
        
    }else{
        
        [self ShareIsText:NO isFriend:NO];
    }
    
}

- (void)ShareIsText:(BOOL)isText isFriend:(BOOL)isFriend{
    
    if (![WXApi isWXAppInstalled]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getAlertTitle] message:@"您未安装微信客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往下载", nil];
        
        [alert show];
    }
    
    /** 如果是YES，是文本消息 */
    if (isText) {
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = YES; /** 指定为发送文本 */
        req.text = self.editRecord.msg_body;
        /** 选择发送到会话(WXSceneSession)或者朋友圈(WXSceneTimeline) */
        if (isFriend) {
            req.scene = WXSceneSession;  /** 会话 */
        }else{
            req.scene =  WXSceneTimeline;  /** 朋友圈 */
        }

        [WXApi sendReq:req];
        [req release];
    }
    /** 图片类型 */
    else{
        
        
        NSString *copyStr = self.editRecord.msg_body;
        NSString *fileName = [NSString stringWithFormat:@"%@.png",copyStr];
        NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
//        NSData *imageData = [EncryptFileManege getDataWithPath:filePath];
//        UIImage *img = [UIImage imageWithData:imageData];
        //            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
//        if (img!=nil)
//        {
//
//            copyStr = filePath;
//        }
//        else
//        {
//            copyStr = @"";
//            
//            [[talkSessionViewController getTalkSession] downloadResumeFile:self.editRecord.msgId andCell:nil];
//            
//        }
        
        WXMediaMessage *message = [WXMediaMessage message];
        
        WXImageObject *imageObject = [WXImageObject object];
        
        
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        NSData *data = UIImagePNGRepresentation(image);
        imageObject.imageData = data;//[NSData dataWithContentsOfFile:filePath];
        message.mediaObject = imageObject;
        
        /** 缩略图 */
        UIImage *thumbImage = [self compressedImageFiles:image imageKB:30];
        //NSData *data2 = UIImagePNGRepresentation(thumbImage);
        [message setThumbImage:thumbImage];
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
        req.bText = NO;
        req.message = message;
        if (isFriend) {
            req.scene = WXSceneSession;  /** 会话 */
        }else{
            req.scene =  WXSceneTimeline;  /** 朋友圈 */
        }
        [WXApi sendReq:req];
        [req release];
    }
    
}

- (UIImage *)compressedImageFiles:(UIImage *)image
                     imageKB:(CGFloat)fImageKBytes

{
    CGFloat fImageBytes = fImageKBytes * 1024;//需要压缩的字节Byte
    
    __block NSData *uploadImageData = nil;
    
    uploadImageData = UIImagePNGRepresentation(image);
    NSLog(@"图片压前缩成 %fKB",uploadImageData.length/1024.0);
    CGSize size = image.size;
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    
    if (uploadImageData.length > fImageBytes && fImageBytes >0) {
        
            /* 宽高的比例 **/
            CGFloat ratioOfWH = imageWidth/imageHeight;
            /* 压缩率 **/
            CGFloat compressionRatio = fImageBytes/uploadImageData.length;
            /* 宽度或者高度的压缩率 **/
            CGFloat widthOrHeightCompressionRatio = sqrt(compressionRatio);
            
            CGFloat dWidth   = imageWidth *widthOrHeightCompressionRatio;
            CGFloat dHeight  = imageHeight*widthOrHeightCompressionRatio;
            if (ratioOfWH >0) { /* 宽 > 高,说明宽度的压缩相对来说更大些 **/
                dHeight = dWidth/ratioOfWH;
            }else {
                dWidth  = dHeight*ratioOfWH;
            }
            
            UIGraphicsBeginImageContext(CGSizeMake(dWidth, dHeight));
            [image drawInRect:CGRectMake(0, 0, dWidth, dHeight)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            uploadImageData = UIImagePNGRepresentation(image);
            
            NSLog(@"当前的图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            //微调
            NSInteger compressCount = 0;
            /* 控制在 1M 以内**/
            while (fabs(uploadImageData.length - fImageBytes) > 1024) {
                /* 再次压缩的比例**/
                CGFloat nextCompressionRatio = 0.9;
                
                if (uploadImageData.length > fImageBytes) {
                    dWidth = dWidth*nextCompressionRatio;
                    dHeight= dHeight*nextCompressionRatio;
                }else {
                    dWidth = dWidth/nextCompressionRatio;
                    dHeight= dHeight/nextCompressionRatio;
                }
                
                UIGraphicsBeginImageContext(CGSizeMake(dWidth, dHeight));
                [image drawInRect:CGRectMake(0, 0, dWidth, dHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                uploadImageData = UIImagePNGRepresentation(image);
                
                /*防止进入死循环**/
                compressCount ++;
                if (compressCount == 10) {
                    break;
                }
                
            }
            
            NSLog(@"图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            image = [[UIImage alloc] initWithData:uploadImageData];
            
        }
    
    return image;
}

/* 根据 dWidth dHeight 返回一个新的image**/
- (UIImage *)drawWithWithImage:(UIImage *)imageCope width:(CGFloat)dWidth height:(CGFloat)dHeight{
    
    UIGraphicsBeginImageContext(CGSizeMake(dWidth, dHeight));
    [imageCope drawInRect:CGRectMake(0, 0, dWidth, dHeight)];
    imageCope = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCope;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex != 0) {
        
        //https://itunes.apple.com/cn/app/%E5%BE%AE%E4%BF%A1/id414478124?mt=8
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/wechat/id414478124?mt=8"]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
