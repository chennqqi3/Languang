//
//  FilesOfTime.h
//  eCloud
//  某一时间段内的文件列表
//  Created by shisuping on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilesOfTime : NSObject

@property (nonatomic,retain) NSString *curTime;
@property (nonatomic,retain) NSMutableArray *filesArray;

//是展开的还是收起的，默认是展开 yes是展开 no是收起
@property (nonatomic,assign) BOOL isExtend;

@end
