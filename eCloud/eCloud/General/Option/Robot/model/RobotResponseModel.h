//
//  RobotResponseModel.h
//  eCloud
//
//  Created by yanlei on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RobotResponseModel : NSObject

//@property(nonatomic,assign) int serviceId;
//@property(nonatomic,retain) NSString *serviceCode;
@property (nonatomic,retain) NSString *type;

@property (nonatomic,retain) NSString *content;

@property (nonatomic,retain) NSMutableArray *argsArray;

@property (nonatomic,retain) NSMutableArray *imgtxtArray;

@property (nonatomic,retain) NSString *nameString;

//消息类型
@property (nonatomic,assign) int msgType;

//文件的下载URL
@property (nonatomic,retain) NSString *msgFileDownloadUrl;

//文件的名称
@property (nonatomic,retain) NSString *msgFileName;

//文件的大小
@property (nonatomic,retain) NSString *msgFileSize;
@end
