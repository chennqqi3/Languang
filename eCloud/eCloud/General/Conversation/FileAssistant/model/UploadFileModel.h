//
//  UploadFileModel.h
//  WebViewCache
//
//  Created by Pain on 14-11-20.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    type_upload_pic = 1, //图片
    type_upload_file     //文件
}upload_type;


typedef enum {
    state_success = 0, //上传成功
    state_waiting,     //等待
    state_uploading,   //正在在上传
    state_failure,      //失败
    state_stop      //暂停
}upload_state;

@interface UploadFileModel : NSObject{
    
}

@property (nonatomic,retain) NSString *upload_id; //消息记录id
@property (nonatomic,retain) NSString *userid; //用户id
@property (nonatomic,retain) NSString *filemd5; //待发文件内容的MD5
@property (nonatomic,retain) NSString *filename; //文件名字
@property (nonatomic,retain) NSString *filepath; //文件路径
@property(assign) int filesize;//文件大小,字节
@property(assign) int type;//类型,1发送的为图片;2发送的为文件
@property(nonatomic,retain) NSString *rc; //16进制(crc8校验(userid字符串+md5串))
@property(nonatomic,retain) NSString *token; //16进制(crc8校验(userid字符串+md5串))
@property(assign) int upload_start_index;//该文件服务器已有大小
@property(assign) int upload_state;//上传状态

@end
