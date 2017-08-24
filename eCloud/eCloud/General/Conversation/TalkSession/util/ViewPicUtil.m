//
//  ViewPicUtil.m
//  eCloud
//
//  Created by shisuping on 15/11/30.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ViewPicUtil.h"
#import "StringUtil.h"
#import "EncryptFileManege.h"

#import "ServerConfig.h"

@implementation ViewPicUtil

//图片的名字
+ (NSString *)getPicNameWithMsgBody:(NSString *)msgBody andPicType:(int)picType
{
    NSString *imageName = [NSString stringWithFormat:@"small%@.png",msgBody];
    if (picType == pic_type_square) {
        imageName = [NSString stringWithFormat:@"square_%@.png",msgBody];
    }else if (picType == pic_type_origin)
    {
        imageName = [NSString stringWithFormat:@"%@.png",msgBody];
    }
    
    return imageName;
}

//图片的路径
+ (NSString *)getPicPathWithMsgBody:(NSString *)msgBody andPicType:(int)picType
{
    return [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[self getPicNameWithMsgBody:msgBody andPicType:picType]];
}

//图片
+ (UIImage *)getPicWithMsgBody:(NSString *)msgBody andPicType:(int)picType
{
    NSData *imageData = [EncryptFileManege getDataWithPath:[self getPicPathWithMsgBody:msgBody andPicType:picType]];
    return [UIImage imageWithData:imageData];
}

//把UIImage转成NSData保存到文件
+ (NSData *)convertImageToData:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image,0.5);
    return imageData;
}

//获取下载原图的URL

+ (NSString *)getPicDownloadUrl:(NSString *)msgBody andPicType:(int)picType
{
    NSString *urlStr = @"";
    
    if (picType == pic_type_origin) {
        urlStr = [NSString stringWithFormat:@"%@%@%@",[[ServerConfig shareServerConfig]getNewPicDownloadUrl],msgBody,[StringUtil getResumeDownloadAddStr]];
    }else{
        urlStr = [NSString stringWithFormat:@"%@%@%@",[[ServerConfig shareServerConfig]getNewSmallPicDownloadUrl],msgBody,[StringUtil getResumeDownloadAddStr]];
    }
    return urlStr;
}

@end
