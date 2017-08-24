//
//  myViewController.h
//  eCloud
//
//  Created by  lyong on 13-12-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//


#import <UIKit/UIKit.h>

@class KapokHistoryViewController;

@interface myViewController : UIViewController<UIAlertViewDelegate>
{
    int servce_id;
    KapokHistoryViewController *kapokHistory ;
}
@property(assign)int servce_id;

- (void)loadMyView;

@end
