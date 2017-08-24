//
//  DisplayImgtxtTableView.h
//  eCloud
//
//  Created by yanlei on 15/11/8.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayImgtxtTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSMutableArray *dataArray;
@end
