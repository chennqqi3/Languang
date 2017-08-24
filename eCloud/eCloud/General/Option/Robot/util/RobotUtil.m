//
//  RobotUtil.m
//  eCloud
//
//  Created by shisuping on 16/12/27.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "RobotUtil.h"
#import "ConvRecord.h"
#import "RobotResponseModel.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "APPUtil.h"
#import "LogUtil.h"

#ifdef _XINHUA_FLAG_
#import "SystemMsgModelArc.h"
#endif

@implementation RobotUtil

/*
 功能描述
 根据机器人的回复类型，设置显示在界面上的消息类型
 
 */
+ (int)getIMMsgTypeOfRobotRecord:(ConvRecord *)convRecord{
    int msgType = convRecord.msg_type;
    
    if (convRecord.robotModel) {
        switch (convRecord.robotModel.msgType) {
            case type_text:
            {
                convRecord.msg_body = [StringUtil formatXiaoWanMsg:convRecord.robotModel.content];
            }
                break;
            case type_pic:
            {
                msgType = type_pic;
            }
                break;
            case type_video:
            {
                msgType = type_file;
                convRecord.msg_body = @"";
            }
                break;
            case type_record:
            {
                msgType = type_file;
                convRecord.msg_body = @"";
            }
                break;
            case type_imgtxt:
            {
                msgType = type_imgtxt;
            }
                break;
            case type_wiki:
            {
                msgType = type_wiki;
            }
                break;
                
            default:
                break;
        }
    }
    return msgType;
}

+ (NSString *)getDownloadFileNameByFileUrl:(NSString *)urlStr{
    
    NSString *fileName = @"";
    
    if (urlStr.length) {
        
        NSString *extension = [urlStr pathExtension];
        
        NSString *urlKey = [APPUtil keyForURL:[NSURL URLWithString:urlStr]];
        
        fileName = [urlKey stringByAppendingPathExtension:extension];
    }

    [LogUtil debug:[NSString stringWithFormat:@"%s fileName is %@",__FUNCTION__,fileName]];

    return fileName;
}

+ (NSString *)getDownloadFilePathWithConvRecord:(ConvRecord *)_convRecord{
    NSString *filePath = [StringUtil getRobotFilePath];
    NSString *fileName = @"";
    
    if (_convRecord.isRobotFileMsg) {
        fileName = _convRecord.robotModel.msgFileName;
    }else if (_convRecord.isRobotImgTxtMsg){
        NSDictionary *dic = _convRecord.robotModel.imgtxtArray[0];
        NSString *picUrl = dic[@"PicUrl"];
        fileName = [self getDownloadFileNameByFileUrl:picUrl];
    }else if (_convRecord.isRobotPicMsg){
        NSString *picUrl = _convRecord.robotModel.msgFileDownloadUrl;
        fileName = [self getDownloadFileNameByFileUrl:picUrl];
    }
    #ifdef _XINHUA_FLAG_
    else if (_convRecord.systemMsgModel)
    {
        NSString *picUrl = _convRecord.systemMsgModel.msgBody;
        fileName = [self getDownloadFileNameByFileUrl:picUrl];
    }
    #endif
    if (filePath.length && fileName.length > 0) {
        return [filePath stringByAppendingPathComponent:fileName];
    }
    return @"";
}

@end
