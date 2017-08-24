//
//  DownloadFileModel.h
//  eCloud
//
//  Created by Pain on 14-12-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    state_download_unknow = 0, //未点击下载
    state_download_success , //下载成功
    state_download_waiting,     //等待
    state_downloading,   //正在下载
    state_download_failure,      //失败
    state_download_stop,     //暂停
    state_download_nonexistent      //文件不存在
}download_state;

@interface DownloadFileModel : NSObject{
    
}
@property (nonatomic,retain) NSString *download_id; //消息记录id
@property(assign) int download_state;//上传状态

@end
