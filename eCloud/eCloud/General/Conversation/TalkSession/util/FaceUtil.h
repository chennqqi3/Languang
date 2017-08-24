//
//  FaceUtil.h
//  OpenCtx2017
//  和表情有关的util
//  Created by shisuping on 17/6/9.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaceUtil : NSObject

/** 根据表情字符串返回表情图标的名称 比如[/wx] 返回 face_wx.png*/

+ (NSString *)getFaceIconNameWithFaceMsg:(NSString *)faceMsg;

@end
