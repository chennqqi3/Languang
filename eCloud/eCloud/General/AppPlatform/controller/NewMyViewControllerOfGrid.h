// 我的 界面
//  NewMyViewController.h
//  eCloud
//
//  Created by SH on 14-9-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KapokHistoryViewController;
@interface NewMyViewControllerOfGrid : UIViewController<UIAlertViewDelegate>
{
    int servce_id;
    KapokHistoryViewController *kapokHistory ;
}
@property(assign)int servce_id;

- (void)loadMyView;
@end
