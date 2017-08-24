//
//  APPStateRecord.h
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

//----统计数据上报------//

#import <Foundation/Foundation.h>

@interface APPStateRecord : NSObject{
    
}
@property (assign) int recordid;     //记录id
@property (nonatomic,retain) NSString *appid; //应用编号
@property(assign) int  optype;//操作类型：1 访问 2 安装 3 卸载
@property(nonatomic,retain) NSString *optime; //时间 格式: yyyymmdd

@end
