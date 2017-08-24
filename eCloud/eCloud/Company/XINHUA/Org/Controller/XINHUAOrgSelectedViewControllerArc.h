//
//  XINHUAOrgSelectedViewControllerArc.h
//  eCloud
//
//  Created by Alex-L on 2017/4/18.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewChooseMemberViewController.h"

@interface XINHUAOrgSelectedViewControllerArc : UIViewController

/** 所有供选择的成员 */
@property (nonatomic, strong) NSMutableArray *empArray;

/** 索引数组 */
@property (nonatomic, strong) NSMutableArray *titleArray;

/** 原来已经有了的成员 */
@property (nonatomic, strong) NSMutableArray *originArray;

@property (nonatomic, assign) id<ChooseMemberDelegate>delegate;

@end
