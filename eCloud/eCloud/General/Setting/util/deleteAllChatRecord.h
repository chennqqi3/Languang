//
//  deleteAllChatRecord.h
//  eCloud
//
//  Created by SH on 14-7-15.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class eCloudDAO;

@interface deleteAllChatRecord : NSObject<UIAlertViewDelegate>
{
    eCloudDAO *db;
}
/** 删除聊天数据 */
-(void)deleteAction;
@end
