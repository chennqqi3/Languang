//
//  memberDetailViewController.h
//  eCloud
//
//  Created by  lyong on 14-1-8.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class conn;
@interface memberDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
 UITableView *chooseTable;
 NSMutableArray *chooseArray;
 conn *_conn;
    
NSString *emp_id_list;

}
@property (nonatomic , retain) NSMutableArray * chooseArray ;
@property(nonatomic,retain) NSString *emp_id_list;

@end
