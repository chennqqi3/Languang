//
//  eCloudNotification.h
//  eCloud
//
//  Created by robert on 12-10-22.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface eCloudNotification : NSObject
{
    /** 通知命令标识码 （具体代表的含义查看NotificationDefine.h文件中的conv_cmd_type枚举）*/
	int _cmdId;
    /** 通知字典内容 */
	NSDictionary *_info;
}
@property(nonatomic,retain)NSDictionary *info;
@property(nonatomic,assign)int cmdId;
@end
