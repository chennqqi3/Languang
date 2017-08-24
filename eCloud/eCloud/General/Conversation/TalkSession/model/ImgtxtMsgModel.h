//
//  ImgtxtMsgModel.h
//  eCloud
//
// 图文类型消息模型
//  Created by shisuping on 16/8/18.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_IMGTXTMSG_TYPE @"imgtxtmsg";
#define KEY_IMGTXTMSG_TITLE @"title"
#define KEY_IMGTXTMSG_SUBTITLE @"subtitle"
#define KEY_IMGTXTMSG_URL @"url"
#define KEY_IMGTXTMSG_IMGURL @"imgurl"
#define KEY_IMGTXTMSG_FROMWHERE @"fromwhere"

@interface ImgtxtMsgModel : NSObject

//图文类型标题
@property (nonatomic,retain) NSString *title;

//图文类型副标题
@property (nonatomic,retain) NSString *subTitle;

//图文类型图片URL
@property (nonatomic,retain) NSString *imgUrl;

//图文类型连接
@property (nonatomic,retain) NSString *url;

//图文类型来自哪里
@property (nonatomic,retain) NSString *fromWhere;

@end
