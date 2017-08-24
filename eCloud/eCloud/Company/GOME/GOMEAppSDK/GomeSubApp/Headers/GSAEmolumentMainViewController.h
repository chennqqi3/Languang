//
//  GSAEmolumentMainViewController.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/18.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import "GSAViewHeader.h"

typedef NS_ENUM(NSInteger, GSAEmolumentMainType) {
    GSAEmolumentMainNormal = 0, //正常进入
    GSAEmolumentMainForgetSecret //忘记密码进入
};

@interface GSAEmolumentMainViewController : GSARootViewController

@property (nonatomic, assign) GSAEmolumentMainType type;

@end
