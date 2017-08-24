//
//  rankChooseViewController.h
//  eCloud
//
//  Created by  lyong on 13-12-16.
//  Copyright (c) 2013年  lyong. All rights reserved.
//
#import <UIKit/UIKit.h>

@class conn;
@class talkSessionViewController;
@interface rankChooseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
	talkSessionViewController *talkSession;
    int typeTag;
    id delegete;
	
	conn *_conn;
	NSString *_convId;
	
	NSArray *newMemberArray;
	
	UITextView *searchTextView;
	
	BOOL isSearch;
	NSString *_searchText;
	
    
	bool isGroupCreate;
    

	int maxGroupNum;
    
    NSMutableArray *chooseArray;
    UIView *chooseView;
    UITableView *chooseTable;
}
@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;


@property (nonatomic , retain) id delegete;
@property(assign)int typeTag;
@property (nonatomic , retain) NSMutableArray * chooseArray ;

//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus;
-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus;
-(void)selectAction:(id)sender;
@end