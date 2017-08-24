//
//  ServiceMessageDetail.h
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceMessageDetail : NSObject
{
	
}
@property(nonatomic,assign)int msgId;
@property(nonatomic,assign)int serviceMsgId;
@property(nonatomic,retain) NSString *msgBody;
@property(nonatomic,retain) NSString *msgUrl;
@property(nonatomic,retain) NSString *msgLink;

//对应的serviceId
@property(nonatomic,assign) int serviceId;

//所在行
@property(nonatomic,assign)int row;
//对应图片是否存在
@property(nonatomic,assign)BOOL isPicExists;
//图片正在下载
@property(nonatomic,assign)BOOL isPicDownloading;

@end
