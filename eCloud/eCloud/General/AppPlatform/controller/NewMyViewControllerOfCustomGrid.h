//
//  NewMyViewControllerOfCustomGrid.h
//  eCloud
//
//  Created by yanlei on 15/8/26.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KapokHistoryViewController;
@interface NewMyViewControllerOfCustomGrid : UIViewController<UIAlertViewDelegate>
{
    int servce_id;
    KapokHistoryViewController *kapokHistory ;
}
@property(assign)int servce_id;

- (void)loadMyView;
@end
