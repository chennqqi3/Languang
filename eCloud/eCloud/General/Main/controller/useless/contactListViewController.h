//
//  contactListViewController.h
//  eCloud
//
//  Created by  lyong on 13-3-19.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class conn;
@class OffenGroup;
@class userInfoViewController;
@class VirGroupObj;
@class personInfoViewController;
@class Emp;
@class conn;
@class talkSessionViewController;

//#import "addContactPersonToBeOffen.h"
@interface contactListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
 UITableView *personTable;
 NSMutableArray * itemArray;
conn *_conn;
 personInfoViewController *personInfo;
 talkSessionViewController *_talkSession;
 UILabel *tiplabel;
 userInfoViewController *userInfo;
    int candeleteTag;
    int noflushTag;
  // addContactPersonToBeOffen*chooseContact;
}
@property (nonatomic , retain) NSMutableArray * itemArray;
@property(nonatomic,retain) talkSessionViewController *talkSession;
@end
