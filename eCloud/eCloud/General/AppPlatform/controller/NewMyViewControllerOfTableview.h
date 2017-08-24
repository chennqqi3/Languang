// 我的 界面
//  NewMyViewController.h
//  eCloud
//
//  Created by SH on 14-9-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KapokHistoryViewController;
@interface NewMyViewControllerOfTableview : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    KapokHistoryViewController *kapokHistory ;
}

@end
