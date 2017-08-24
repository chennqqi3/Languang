//
//  ViewController.h
//  GOME_DEMO
//
//  Created by Alex L on 16/11/29.
//  Copyright © 2016年 Alex L. All rights reserved.
//

#import <UIKit/UIKit.h>

//国美内购会的应用id
#define GOME_PURCHASE_APP_ID (128)

@class APPListModel;

@interface GOMEAppViewController : UIViewController

/** 如果成功打开某一个微应用界面返回YES，否则返回NO*/
+ (BOOL)openGomeApp:(APPListModel *)appModel andCurVC:(UIViewController *)curVC;

@end

