//
//  talkRecordViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chooseMemberViewController.h"
#import "personInfoViewController.h"
#import "personGroupViewController.h"
#import "talkRecordDetailViewController.h"
//UISearchBarDelegate,
@interface talkRecordViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
//    id delegete;
    UITableView *personTable;
    chooseMemberViewController *chooseMember;
    personInfoViewController *personInfo;
    personGroupViewController *personGroup;
 	
	int totalCount;//总记录数
	int curPage;//当前页
	int totalPage;//总页数
	
	NSMutableArray * _itemArray ;
	
//	UITextView *searchTextView;

	conn *_conn;
/*	
	BOOL isSearch;
	NSMutableArray	*oldItemArray;
	NSString *_searchText;
	*/
	
	NSString *deleteConvId;
	int deleteRow;
	
	
}
//@property(nonatomic,retain)id delegete;
@property(nonatomic,retain)NSMutableArray * itemArray;


@end
