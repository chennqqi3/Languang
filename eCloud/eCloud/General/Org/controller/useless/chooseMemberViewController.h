//
//  chooseMemberViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class conn;
@class talkSessionViewController;
@interface chooseMemberViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    
    UITableView *organizationalTable;
    NSMutableArray * itemArray ;
    chooseMemberViewController *chooseMember;
    NSMutableArray *employeeArray;
    NSMutableArray *deptArray;
	talkSessionViewController *talkSession;
    int typeTag;
    id delegete;
	
	conn *_conn;
	NSString *_convId;
	
	NSArray *newMemberArray;
	
	UITextView *searchTextView;
	
	BOOL isSearch;
	NSString *_searchText;
	UISearchBar *_searchBar;

	bool isGroupCreate;
    
    UIScrollView *bottomScrollview;
    UIButton *addButton;
	
	int maxGroupNum;

}
@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;
@property(nonatomic,retain) NSMutableArray *oldEmpIdArray;

@property (nonatomic , retain) id delegete;
@property(assign)int typeTag;
@property (nonatomic , retain) NSMutableArray * itemArray ;
@property (nonatomic , retain) NSMutableArray * employeeArray ;
@property (nonatomic , retain) NSMutableArray *deptArray;
//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus;
-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus;
-(void)selectAction:(id)sender;
@end
