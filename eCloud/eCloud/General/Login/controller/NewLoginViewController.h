//
//  NewLoginViewController.h
//  eCloud
//
//  Created by Richard on 13-11-23.
//  Copyright (c) 2013年  lyong. All rights reserved.
//  类功能:登录界面控制器(除国美、泰禾之外的其他公司在用的登录界面)

#import <UIKit/UIKit.h>

/** 一个结构体：goToMainView这个结构体的一个函数名称 */
typedef struct _util{
    /** 登录成功之后设置window的根控制器 */
    void (*goToMainView)(UIViewController *curVc);
}NewLoginViewController_t ;

/** 为创建单例结构体定义一个宏 */
#define _NewLoginViewController ([NewLoginViewController sharedUtil])

@interface NewLoginViewController : UIViewController
/**
 获取一个单例结构体对象

 @return 单例结构体对象
 */
+ (NewLoginViewController_t *)sharedUtil;

@end


//@interface NewLoginViewController : UIViewController<CheckBoxDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
//
//+ (void)goToMainView:(UIViewController *)curVc;
//
//@end
