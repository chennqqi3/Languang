//
//  broadcastChooseMemberViewController.h
//  eCloud
//
//  Created by  lyong on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class zoneChooseViewController;
@class businessChooseViewController;
@class rankChooseViewController;
@class AdvancedSearchViewController;
@class LCLLoadingView;
@class conn;
@class talkSessionViewController;
@interface addContactPersonToBeOffen : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIAlertViewDelegate>
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
    
    NSMutableArray *typeArray ;
    AdvancedSearchViewController *advancedSearch;
    BOOL isAdvancedSearch;
    BOOL isDetailAction;
    //筛选
    NSMutableArray *chooseArray;
    UIView *chooseView;
    UITableView *chooseTable;
    rankChooseViewController *rankChoose;
    businessChooseViewController*businessChoose;
    zoneChooseViewController *zoneChoose;
    UILabel *rankLabel;
    UILabel *bussinesslLabel;
    
    NSMutableArray *zoneArray;
    NSString *rank_list_str;
    NSString *business_list_str;
    NSString *city_list_str;
    BOOL isExpand;
    BOOL isNeedSearchAgain;
    UIView *titleview;
    UILabel *numlabel;
    UIButton*  leftButton;
    UIButton *resultButton;
    UIButton *backgroudButton;
    NSString *searchStr;
    NSTimer *searchTimer;
}
@property(nonatomic,retain) NSString *rank_list_str;
@property(nonatomic,retain) NSString *business_list_str;
@property(nonatomic,retain) UILabel *rankLabel;
@property(nonatomic,retain) UILabel *bussinesslLabel;
@property (nonatomic , retain) NSMutableArray * chooseArray ;
@property(nonatomic,retain) NSMutableArray *zoneArray;

@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;
@property(nonatomic,retain) NSMutableArray *oldEmpIdArray;

@property (nonatomic , retain) id delegete;
@property(assign)int typeTag;
@property(assign)BOOL isAdvancedSearch;
@property (nonatomic , retain) NSMutableArray * itemArray;
@property (nonatomic , retain) NSMutableArray * typeArray ;
@property (nonatomic , retain) NSMutableArray * employeeArray ;
@property (nonatomic , retain) NSMutableArray *deptArray;

@property(nonatomic,retain)NSString *searchStr;
@property(nonatomic,retain) NSTimer *searchTimer;
//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus;
-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus;
-(void)selectAction:(id)sender;
@end
