//
//  broadcastListViewController.h
//  eCloud
//
//  Created by  lyong on 13-4-15.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface broadcastListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
	NSMutableArray * _itemArray ;
	UILabel *titleLabel;
    UITableView *personTable;
    NSString *deleteConvId;
	int deleteRow;
    broadcastListViewController *broadcastListView;
}
//@property(nonatomic,retain)id delegete;
@property(nonatomic,retain)NSMutableArray *itemArray;
@property(nonatomic,retain)NSString *convId;
@property(nonatomic,assign)int broadcastType;

@end
