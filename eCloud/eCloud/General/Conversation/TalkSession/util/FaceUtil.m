//
//  FaceUtil.m
//  OpenCtx2017
//  和表情有关的util
//  Created by shisuping on 17/6/9.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "FaceUtil.h"
#import "faceDefine.h"
#import "eCloudConfig.h"

@implementation FaceUtil

/** 根据表情字符串返回表情图标的名称 */

+ (NSString *)getFaceIconNameWithFaceMsg:(NSString *)faceMsg{
    
    NSString *imageName;
    NSString *tempName = [faceMsg substringWithRange:NSMakeRange(2, faceMsg.length - 3)];
    if([tempName hasPrefix:@"r_"])
    {
        tempName = [tempName substringFromIndex:2];
        imageName = [NSString stringWithFormat:@"rtx_face_%@.gif",tempName];
    }
    else
    {
        
        if ([eCloudConfig getConfig].useNewFaceDefine) {
            int faceIndex = [faceValueDef indexOfObject:tempName];
            if (faceIndex < 0 || faceIndex >= faceIconNameDef.count) {
                faceIndex = 0;
            }
            imageName = [NSString stringWithFormat:@"%@.png",faceIconNameDef[faceIndex]];
            
        }else{
            imageName = [NSString stringWithFormat:@"%@_%@.png",[eCloudConfig getConfig].facePrefix,tempName];
        }
    }
    return imageName;
}

@end
