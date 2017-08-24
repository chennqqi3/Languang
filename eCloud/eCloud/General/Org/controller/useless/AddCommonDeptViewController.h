//
//  broadcastChooseMemberViewController.h
//  eCloud
//
//  Created by  lyong on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "conn.h"
#import "LCLLoadingView.h"
@class talkSessionViewController;


@interface AddCommonDeptViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    
    UITableView *organizationalTable;
    NSMutableArray * itemArray ;
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
    UIButton *detailButton;
	
	int maxGroupNum;
    UIButton* backgroudButton;
    BOOL isExpand;
    BOOL isNeedSearchAgain;
}

@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;
@property(nonatomic,retain) NSMutableArray *oldEmpIdArray;
@property(nonatomic,retain) NSMutableDictionary *mOldEmpDic;

@property (nonatomic , retain) id delegete;
@property(assign)int typeTag;
@property(assign)BOOL isAdvancedSearch;
@property (nonatomic , retain) NSMutableArray * itemArray;


@property (nonatomic , retain) NSMutableArray * employeeArray ;
@property (nonatomic , retain) NSMutableArray *deptArray;

@property (nonatomic,retain) NSTimer *searchTimer;
@property (nonatomic,retain) NSString *searchStr;

//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus;

-(void)selectAction:(id)sender;
@end
