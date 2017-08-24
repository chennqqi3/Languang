//
//  FileAssistantRecordDOA.h
//  eCloud
//
//  Created by Dave William on 2017/7/15.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "eCloud.h"

@interface FileAssistantRecordDOA : eCloud

+(id)getFileDatabase;

//增加一条文件消息记录
-(void)addOneFileRecord:(NSDictionary *)dict;

//删除一条
-(void)deleteFileRecordOneMsg:(NSString *)msgid;

//更新
-(void)updateTheFileRecordMsgID:(NSString *)msgBody withOldMsgBody:(NSString *)oldMsg;





@end
