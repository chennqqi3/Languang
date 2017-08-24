//
//  ServiceMessage.h
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceMessage : NSObject
{
	
}
@property (nonatomic,assign) int msgId;
@property(nonatomic,assign) int serviceId;
@property(nonatomic,assign)int msgTime;

@property(nonatomic,retain) NSString *msgBody;
@property(nonatomic,retain) NSString *msgUrl;
@property(nonatomic,retain) NSString *msgLink;

@property(nonatomic,assign) int msgType;
@property(nonatomic,assign) int msgFlag;
@property(nonatomic,assign) int readFlag;
@property(nonatomic,retain) NSArray *detail;

//是否显示时间
@property(nonatomic,assign) bool isTimeDisplay;

@property(nonatomic,retain) NSString *msgTimeDisplay;

@property(nonatomic,assign)int sendFlag;
@property(nonatomic,assign)int fileSize;
@property(nonatomic,assign)int redDotFlag;

//增加一个时间，用来显示单条图文信息的日期
@property(nonatomic,retain) NSString *singlePsMsgDate;
@end
