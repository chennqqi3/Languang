//
//  onlineStateViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserInfo;
@class conn;
@class LCLLoadingView;
@class defineReplyViewController;

@interface onlineStateViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView*  onlineTable;
    NSArray *stateArray;
    NSArray *goArray;
    NSIndexPath *oldindexpath;
    NSIndexPath *otheroldindexpath;
    defineReplyViewController *defineReply;
   
    NSString *userid;
    UserInfo* userinfo;
	
	conn * _conn;
}
@property(nonatomic,retain)NSString *userid;
@end
