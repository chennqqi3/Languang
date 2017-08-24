//
//  chooseTipViewController.h
//  eCloud
//
//  Created by  lyong on 14-4-2.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chooseTipViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *dataArray;
    UITableView*   personGroupTable;
    id predelegate;
}
@property(nonatomic,retain)NSArray *dataArray;
@property(assign)id predelegate;
@property(nonatomic , assign)NSRange range;
@end
