//
//  LookFileViewController.h
//  OpenCtx
//
//  Created by lyan on 15-5-29.
//  Copyright (c) 2015年 mimsg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileRecord.h"

@interface LookFileViewController : UIViewController
/**
 *  要进行展示的文件的沙盒路径
 */
@property (nonatomic,retain)FileRecord *fileRecord;

@property (nonatomic,retain)NSString *filePath;

@end
