//
//  AudioViewController.h
//  eCloud
//
//  Created by Alex L on 16/4/8.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConvRecord.h"

@interface AudioViewController : UIViewController

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) ConvRecord *convRecord;

// 更新锁屏状态的信息
- (void)updateLockedScreenMusic;

@end
