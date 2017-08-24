//
//  broadcastContentViewController.h
//  eCloud
//
//  Created by SH on 14-7-29.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface broadcastContentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *broadcastContentView;
}

@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,retain)NSString *messageString;
@property(nonatomic,retain)NSString *msgId;
//广播在会话表里的id
@property(nonatomic,retain)NSString *convId;
@property(nonatomic,assign)int broadcastType;

@end
