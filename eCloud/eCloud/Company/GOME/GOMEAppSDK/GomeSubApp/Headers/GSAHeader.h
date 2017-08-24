//
//  GSAHeader.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/25.
//  Copyright © 2016年 Gome. All rights reserved.
//

#ifndef GSAHeader_h
#define GSAHeader_h
//头文件引用
#import "Masonry.h"
#import <UIKit/UIKit.h>
#import "UIColor+Hex.h"
#import "NSDate+GetNeededTime.h"
#import "UILabel+SetStatus.h"
#import "NSObject+Information.h"

//常用的Define
#define kBaseBackgroundColor [UIColor colorWithHexString:@"#f9f9f9"]
#define kScreenOrigin [UIScreen mainScreen].bounds.origin
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScale kScreenWidth/375 //以6系列的尺寸为基准

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#endif /* GSAHeader_h */
