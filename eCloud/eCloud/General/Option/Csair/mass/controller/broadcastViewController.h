//
//  broadcastViewController.h
//  eCloud
//
//  Created by  lyong on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
// 一呼万应消息的 列表界面

#import <UIKit/UIKit.h>
@class chooseForSepcialViewController;
@class broadcastChooseMemberViewController;

@interface broadcastViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIView* footerView;
    broadcastChooseMemberViewController *broadcastChoose;
    UITableView *broadcastListTable;
    chooseForSepcialViewController *chooseSpcial;
}
@end
