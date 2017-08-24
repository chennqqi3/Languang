//
//  organizationalViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class personInfoViewController;
@class talkSessionViewController;
@class specialChooseMemberViewController;
@class userInfoViewController;
@class conn;

@interface organizationalViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    
    UITableView *organizationalTable;
    NSMutableArray * itemArray ;
    specialChooseMemberViewController *chooseMember;
    userInfoViewController *userInfo;
	personInfoViewController *  personInfo;
	
	UITextView *searchTextView;
	
	conn *_conn;
	int selectedIndex;//选中的用户

	BOOL isSearch;
	NSString *_searchText;
	
	UISearchBar *_searchBar;
    int noflushTag;
    UIButton *backgroudButton;
    int searchDeptAndEmpTag;

}

@property (nonatomic , retain) NSMutableArray * itemArray ;
@property (nonatomic,retain) NSTimer *searchTimer;
@property (nonatomic,retain) NSString *searchStr;

+ (void)openUserInfoById:(NSString *)empIdStr andCurController:(UIViewController *)curController;

@end
