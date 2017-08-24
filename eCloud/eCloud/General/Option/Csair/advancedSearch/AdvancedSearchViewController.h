//
//  AdvancedSearchViewController.h
//  eCloud
//
//  Created by  lyong on 13-12-16.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

//
#import <UIKit/UIKit.h>
@class zoneChooseViewController;
@class businessChooseViewController;
@class rankChooseViewController;
@class AdvancedSearchViewController;
@class LCLLoadingView;
@class conn;
@class talkSessionViewController;
@interface AdvancedSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    NSMutableArray *employeeArray;
    NSMutableArray *deptArray;
	talkSessionViewController *talkSession;
    int typeTag;
    id delegete;
	
	conn *_conn;
	NSString *_convId;
	
	NSArray *newMemberArray;
	
	BOOL isSearch;
	NSString *_searchText;
	
    
	bool isGroupCreate;
    
    UIScrollView *bottomScrollview;
    UIButton *addButton;
	
	int maxGroupNum;
  
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
}
@property(nonatomic,retain) NSString *rank_list_str;
@property(nonatomic,retain) NSString *business_list_str;
@property(nonatomic,retain) UILabel *rankLabel;
@property(nonatomic,retain) UILabel *bussinesslLabel;
@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;
@property(nonatomic,retain) NSMutableArray *oldEmpIdArray;
@property(nonatomic,retain) NSMutableArray *zoneArray;
@property (nonatomic , retain) id delegete;
@property(assign)int typeTag;
@property (nonatomic , retain) NSMutableArray * chooseArray ;
@property (nonatomic , retain) NSMutableArray * employeeArray ;
@property (nonatomic , retain) NSMutableArray *deptArray;
//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus;
-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus;
-(void)selectAction:(id)sender;
@end
