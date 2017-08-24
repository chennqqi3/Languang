//
//  FLTGroupListViewController.h
//  eCloud
//
//  Created by Richard on 13-11-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTGroupListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)NSMutableArray *itemArray;
@end
