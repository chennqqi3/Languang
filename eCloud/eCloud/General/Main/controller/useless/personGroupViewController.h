//
//  personGroupViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class userInfoViewController;
@class conn;
@class talkSessionViewController;
@class personInfoViewController;

@interface personGroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSString *titleStr;
    UITableView*   personGroupTable;
    talkSessionViewController*talkSession;
    personInfoViewController*personInfo;
    NSArray *dataArray;
    NSString *conv_id;
	
	conn *_conn;
}
@property(nonatomic,retain) NSString *titleStr;
@property(nonatomic,retain) NSArray *dataArray;
@property(nonatomic,retain) NSString *conv_id;
@end
