
#import <UIKit/UIKit.h>
@class conn;
@class Area;

@interface provinceChooseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
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
     NSIndexPath *oldindexpath;
    int country_id;
    Area *selectedArea;
}
@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;
@property (nonatomic , retain) Area *selectedArea;
@property (assign)int country_id;
@property (nonatomic , retain) id delegete;
@property(assign)int typeTag;
@property (nonatomic , retain) NSMutableArray * chooseArray ;

//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus;
-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus;
-(void)selectAction:(id)sender;
-(void)updateShowData;
@end