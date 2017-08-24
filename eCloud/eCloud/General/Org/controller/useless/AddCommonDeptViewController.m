//
//  specialChooseMemberViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-10.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "AddCommonDeptViewController.h"
#import "eCloudUser.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "UserDisplayUtil.h"
#import "DeptSelectCell.h"
#import "DeptCell.h"
#import "EmpCell.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"

#import "Emp.h"
#import "Dept.h"

#import "PermissionUtil.h"
#import "PermissionModel.h"
#import "UserDataDAO.h"
#import "ImageUtil.h"
#import "UserDataConn.h"
#import "UserTipsUtil.h"
#import "DeptInMemory.h"
@interface AddCommonDeptViewController ()

@property (nonatomic,retain) NSMutableArray *selectedDepts;
@end

@implementation AddCommonDeptViewController
{
	eCloudDAO *_ecloud ;
    UIScrollView *changeScrollview;
    
    UserDataDAO *userDataDAO;
    UserDataConn *userDataConn;
    NSMutableDictionary *deptDic;
    
    //    是否需要设置已经选择的部门的状态
    BOOL needUnselectDept;

}
@synthesize selectedDepts;

@synthesize mOldEmpDic;

@synthesize searchStr;
@synthesize searchTimer;

@synthesize nowSelectedEmpArray;
@synthesize oldEmpIdArray;
@synthesize itemArray ;

@synthesize employeeArray;
@synthesize  deptArray;
@synthesize typeTag;
@synthesize delegete;
@synthesize isAdvancedSearch;

-(void)dealloc
{
    self.selectedDepts = nil;
    
	NSLog(@"%s",__FUNCTION__);
    self.mOldEmpDic = nil;
    
    self.searchStr = nil;
    self.searchTimer = nil;
    
	self.nowSelectedEmpArray=nil;
	self.oldEmpIdArray = nil;
	self.delegete = nil;
	self.itemArray = nil;
	self.employeeArray = nil;
	self.deptArray = nil;
	
	//	add by shisp 取消组织结构变动通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:ORG_NOTIFICATION object:nil];
	
	[[NSNotificationCenter defaultCenter]removeObserver:self name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
    
	[super dealloc];
	
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark 刷新组织架构
-(void)refreshOrg:(NSNotification*)notification
{
	eCloudNotification *cmd = notification.object;
	switch (cmd.cmdId) {
		case first_load_org:
			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
			
			[_conn setAllEmpNotSelect];
			
			
			[self getRootItem];
			[organizationalTable reloadData];
			
			break;
		case refresh_org:
		{
            //			[self getRootItem];
            //			[organizationalTable reloadData];
		}
			break;
		default:
			break;
	}
}

-(void)toLeftPressed:(id)sender
{
    
}

- (void)viewDidLoad
{
    
	NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
	_conn = [conn getConn];
	_ecloud = [eCloudDAO getDatabase];
    
    userDataDAO = [UserDataDAO getDatabase];
    userDataConn = [UserDataConn getConn];
    deptDic=[userDataDAO getAllCommonDeptDic];
    isSearch=NO;
    isExpand=YES;
    isNeedSearchAgain=NO;
    
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    self.title= [StringUtil getLocalizableString:@"me_common_departments_select_title"];
    
    UIButton *leftButton = [UIAdapterUtil setLeftButtonItemWithTitle:@"常用部门" andTarget:self andSelector:@selector(backButtonPressed:)];
    leftButton.hidden=YES;
    
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    //	组织架构展示table
	int tableH = 460 - 84 - 44;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    changeScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320, tableH+84)];
    changeScrollview.showsHorizontalScrollIndicator = YES;
    changeScrollview.showsVerticalScrollIndicator = YES;
    [self.view addSubview:changeScrollview];
    
    [[eCloudUser getDatabase]getPurviewValue];
    //	查询bar
    float searchBarW = self.view.frame.size.width;
    float searchBarH = 40;
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, searchBarW, searchBarH)];
	_searchBar.delegate=self;
	_searchBar.placeholder=[StringUtil getLocalizableString:@"me_common_departments_search"];
    //	_searchBar.backgroundColor=[UIColor colorWithRed:210/255.0 green:215/255.0 blue:220/255.0 alpha:1];
	_searchBar.keyboardType = UIKeyboardTypeDefault;
	
    float r = 232/255.0;
    
    
	//searchTextView = [[_searchBar subviews]lastObject];
    for (UIView *searchBarSubview in [_searchBar subviews]) {
        if ( [searchBarSubview isKindOfClass:[UITextField class] ] ) {
            // ios 6 and earlier
            searchTextView = (UITextField *)searchBarSubview;
        } else {
            // for ios 7 what we need is nested inside another container
            for (UIView *subSubView in [searchBarSubview subviews]) {
                if ( [subSubView isKindOfClass:[UITextField class] ] ) {
                    searchTextView = (UITextField *)subSubView;
                }
            }
        }
    }
    
    
	[searchTextView setReturnKeyType:UIReturnKeyDone];
	
	[changeScrollview addSubview: _searchBar];
	[_searchBar release];
    
    
    organizationalTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, tableH) style:UITableViewStylePlain];
    [organizationalTable setDelegate:self];
    [organizationalTable setDataSource:self];
    organizationalTable.backgroundColor=[UIColor clearColor];
    [changeScrollview addSubview:organizationalTable];
    
    backgroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, tableH)];
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    [organizationalTable addSubview:backgroudButton];
    backgroudButton.hidden=YES;
    
	//	add by shisp  注册组织架构信息变动通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
    
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	
    //	自定义导航栏
	int toolbarY = self.view.frame.size.height - 44-44;
    if (IOS7_OR_LATER)
    {
        toolbarY = toolbarY - 20;
    }
    UINavigationBar *bottomNavibar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, toolbarY, 320, 45)];
//        [UIAdapterUtil customLightNavigationBar:bottomNavibar];
    
//    bottomNavibar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    
    UIColor *_color = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    UIImage *bgImage = [ImageUtil imageWithColor:_color];
    [bottomNavibar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    //分割线
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, bottomNavibar.frame.size.width, 1.0)];
    lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
    [bottomNavibar addSubview:lineLab];
    [lineLab release];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(260, 7.5, 50, 30);
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    //    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    //    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [addButton setTitle:[StringUtil getLocalizableString:@"confirm"] forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:addButton];
    addButton.enabled=NO;
    
    
    bottomScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 260, 45)];
    // bottomScrollview.backgroundColor=[UIColor greenColor];
    [bottomNavibar addSubview:bottomScrollview];
    bottomScrollview.pagingEnabled = NO;
    bottomScrollview.showsHorizontalScrollIndicator = YES;
    bottomScrollview.showsVerticalScrollIndicator = YES;
    bottomScrollview.scrollsToTop = NO;
    [bottomScrollview release];
    
    [UIAdapterUtil setExtraCellLineHidden:organizationalTable];
}

-(void)dismissKeybordByClickBackground
{
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
}
-(void)resultPressed:(id)sender
{
    if (!isNeedSearchAgain) {
        
        return;
    }
    
    
    isNeedSearchAgain=NO;
    // self.chooseArray=[advanceQueryDAO getChooseArrayByRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    
    
    
}

-(void)dismissSelf:(NSNotification *)notification
{
	
	[self dismissModalViewControllerAnimated:NO];
}
-(void)keepAdvancedSearchView
{
    changeScrollview.contentOffset=CGPointMake(320, 0);
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    needUnselectDept = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    

    if (_conn==nil) {
        _conn = [conn getConn];
    }
     [_conn setAllDeptsNotSelect];
	   
	//	如果原来是查询状态，那么维持之前的状态
	[self getRootItem];
	[organizationalTable reloadData];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    
    if (needUnselectDept) {
        [_conn setAllDeptsNotSelect];
    }
    // update by shisp
    //    if (!isAdvancedSearch) {//不是 高级搜索返回
    //        _searchBar.text = @"";
    //    }
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
}
-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYMEBER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)getRootItem
{
    //根据公司id和上级部门id，获取直接子部门
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    self.itemArray = [NSMutableArray arrayWithArray:[_ecloud getLocalNextDeptInfoWithSelected:@"0" andLevel:0 andSelected:false]];
	[pool release];
}

#pragma mark------UISearchBarDelegate-----
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	
    backgroudButton.hidden=NO;
	return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchStr = [StringUtil trimString:searchBar.text];
 	if([self.searchStr length] == 0)
	{
		[self getRootItem];
        isSearch=NO;
        [organizationalTable reloadData];
	}
	else
	{
        if (self.searchTimer && [self.searchTimer isValid])
        {
            //            NSLog(@"searchTimer is valid");
            [self.searchTimer invalidate];
        }
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchOrg) userInfo:nil repeats:NO];
	}
}

- (void)searchOrg
{
    dispatch_queue_t queue = dispatch_queue_create("search org", NULL);
    
    dispatch_async(queue, ^{
        int _type = [StringUtil getStringType:self.searchStr];
		if(_type == other_type)
			return;
        
        NSString *_searchStr = [NSString stringWithString:self.searchStr];
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        NSMutableArray *dataarray=[NSMutableArray array];
        
		//NSArray *emparray= [_ecloud getEmpsByNameOrPinyin:_searchStr andType:_type];
        
        if (![_searchStr isEqualToString:self.searchStr]) {
            NSLog(@"1 查询条件有变化");
            [pool release];
            return;
        }
 		NSArray *deptarray = [_ecloud getDeptByNameOrPinyin:_searchStr andType:_type];
        
        // [dataarray addObjectsFromArray:emparray];
        [dataarray addObjectsFromArray:deptarray];
        
        self.itemArray=dataarray;
        
		[pool release];
        
        if (![_searchStr isEqualToString:self.searchStr]) {
            NSLog(@"2 查询条件有变化");
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            isSearch = YES;
            [organizationalTable reloadData];
        });
        
    });
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
    needUnselectDept = YES;
    
	[self.navigationController popViewControllerAnimated:YES];
}

//隐藏查询输入框的键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[searchTextView resignFirstResponder];
}

#pragma mark 选择后确定
-(void) addButtonPressed:(id) sender{
    //	关闭键盘
	[searchTextView resignFirstResponder];
    if ([self.selectedDepts count]>0) {
        
        BOOL ret = [userDataConn sendModiRequestWithDataType:user_data_type_dept andUpdateType:user_data_update_type_insert andData:self.selectedDepts];
        
        if (ret) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        }
        
     }else
    {
        UIAlertView *dept_alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"me_common_departments_no_selected"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        [dept_alert show];
        [dept_alert release];
    }
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==organizationalTable) {
        
        return 1;
        
    }else {
        
        return 2;
    }
    
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            return [self.itemArray count];
        }else
        {
            
            return [self.itemArray count];
            
        }
    }
    return 0;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleNone;
    
}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                int indentation=0;
                indentation=((Dept *)temp).dept_level;
                
                return indentation;
            }
            else
            {
                int indentation=0;
                indentation=((Emp *)temp).emp_level;
                
                return indentation;
                
            }
        }else
        {
            
            //组织架构
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                int indentation=0;
                indentation=((Dept *)temp).dept_level;
                
                return indentation;
            }
            else
            {
                int indentation=0;
                indentation=((Emp *)temp).emp_level;
                
                return indentation;
                
            }
            
            
        }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            return 0;
        }else
        {
            return 20;
        }
        
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            return nil;
        }else
        {
            UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
            titlelabel.backgroundColor=[UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
            titlelabel.font=[UIFont systemFontOfSize:14];
            titlelabel.text=[StringUtil getLocalizableString:@"specialChoose_organizational_structure"];
            
            return titlelabel;
        }
    }
    return nil;
}

-(void)titleButtonAction:(id)sender
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                return dept_row_height;
            }
            else {
                return emp_row_height;
            }
        }
        else
        {
            //组织架构
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                return dept_row_height;
            }// Configure the cell.
            else {
                return emp_row_height;
            }
            
            
        }
    }
    return 1;
}


#pragma mark 查询和展开的部门的cell
- (DeptSelectCell *)getDeptSelectCell:(NSIndexPath *)indexPath search:(BOOL)isSearch
{
    static NSString *deptSelectCellID = @"deptSelectCellID";
    
    Dept *dept =[self.itemArray objectAtIndex:indexPath.row];
    
    DeptSelectCell *deptCell = [organizationalTable dequeueReusableCellWithIdentifier:deptSelectCellID];
    if (deptCell == nil) {
        deptCell = [[[DeptSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deptSelectCellID]autorelease];
        
        UIButton *selectButton=(UIButton *)[deptCell viewWithTag:dept_select_btn_tag] ;
        [selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIButton *selectButton=(UIButton *)[deptCell viewWithTag:dept_select_btn_tag] ;
    selectButton.titleLabel.text = [StringUtil getStringValue:indexPath.row];
    NSString *dept_id_str=[NSString stringWithFormat:@"%d",dept.dept_id];
    NSString *is_old_dept=[deptDic objectForKey:dept_id_str];
   // NSLog(@"----is_old_dept--%@",is_old_dept);
    if (is_old_dept!=nil&&[is_old_dept isEqualToString:@"YES"]) {
        selectButton.hidden=YES;
    }else
    {
        selectButton.hidden=NO;
    }
    [deptCell configCell:dept search:isSearch];
    
    return deptCell;
}

#pragma mark 只优化了一部分，主要针对组织架构部门做了展示优化，解决部门名称过长，覆盖在线人数或选择框的问题
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    if (tableView==organizationalTable) {
        //        add by shisp 优化开始
        if (isSearch)
        {
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]])
            {
                //                无论是查询还是直接显示组织架构，都按照正常的组织架构展示
                return [self getDeptSelectCell:indexPath search:NO];
            }
            else
            {
                
            }
        }else
        {
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]])
            {
                return [self getDeptSelectCell:indexPath search:NO];
            }
            else
            {
                
            }
            
        }
    }
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [searchTextView resignFirstResponder];
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            if ([self.itemArray count]==0) {
                return;
            }
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if([temp isKindOfClass:[Dept class]])
            {
                Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
                int level=dept.dept_level+1;
                if (dept.isExtended) { //收起展示
                    dept.isExtended=false;
                    int remvoecount=0;
                    for (int i=indexPath.row+1; i<[self.itemArray count]; i++) {
                        
                        
                        id temp1 = [self.itemArray objectAtIndex:i];
                        
                        if([temp1 isKindOfClass:[Emp class]])
                        {
                            if (((Emp *)temp1).emp_level<=dept.dept_level) {
                                break;
                            }
                        }
                        
                        if([temp1 isKindOfClass:[Dept class]])
                        {
                            if (((Dept *)temp1).dept_level<=dept.dept_level) {
                                break;
                            }
                            
                        }
                        remvoecount++;
                    }
                    if (remvoecount!=0) {
                        NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                        [self.itemArray removeObjectsInRange:range];
                    }
                    
                }else   //显示子部门及人员
                {
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                    
                    NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level];
                    // NSArray *tempEpArray=[_ecloud getDeptEmpInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked];
                    
                    //  NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id  andLevel:level];
                    
                    Dept *dept1;
                    Dept *dept2;
                    for (int i=0; i<[tempDeptArray count]; i++) {
                        
                        dept1=[tempDeptArray objectAtIndex:i];
                        DeptInMemory *_dept = [_conn getDeptInMemoryByDeptId:dept1.dept_id];
                       
                        if (_dept) {
                            dept1.isChecked = _dept.isChecked;
                        }

                    }
                    
                    NSMutableArray *allArray=[[NSMutableArray alloc]init];
                    // [allArray addObjectsFromArray:tempEpArray];
                    [allArray addObjectsFromArray:tempDeptArray];
                    
                    [pool release];
                    
                    NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                    [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                    dept.isExtended=true;
                    
                    [allArray release];
                    
                    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                    float noworigin=cell.frame.origin.y;
                    
                    /*自动收起---------------------------------------------------------------bigen------------*/
                    float isExtendedPoint=0;
                    float sumnum=0;
                    for (int i=0; i<[self.itemArray count]; i++) {
                        id temp1 = [self.itemArray objectAtIndex:i];
                        if([temp1 isKindOfClass:[Dept class]])
                        {   Dept*extendedDept=((Dept *)temp1);
                            if (extendedDept.dept_id!=dept.dept_id&&extendedDept.dept_level==dept.dept_level&&extendedDept.isExtended) {
                                NSIndexPath *tempindexpath=[NSIndexPath indexPathForRow:i inSection:0];
                                UITableViewCell *tempcell=[tableView cellForRowAtIndexPath:tempindexpath];
                                isExtendedPoint=tempcell.frame.origin.y;
                                
                                extendedDept.isExtended=false;
                                int remvoecount=0;
                                float emplen=0;
                                float deptlen=0;
                                for (int nowindex=i+1; nowindex<[self.itemArray count]; nowindex++) {
                                    
                                    
                                    id temp1 = [self.itemArray objectAtIndex:nowindex];
                                    
                                    if([temp1 isKindOfClass:[Emp class]])
                                    {
                                        if (((Emp *)temp1).emp_level<=extendedDept.dept_level) {
                                            break;
                                        }
                                        emplen+=58;
                                    }
                                    
                                    if([temp1 isKindOfClass:[Dept class]])
                                    {
                                        if (((Dept *)temp1).dept_level<=extendedDept.dept_level) {
                                            break;
                                        }
                                        deptlen+=42;
                                    }
                                    remvoecount++;
                                }
                                if (remvoecount!=0) {
                                    NSRange range =NSMakeRange(i+1,remvoecount);
                                    [self.itemArray removeObjectsInRange:range];
                                }
                                sumnum=deptlen+emplen;
                                break;
                            }
                            
                        }
                    }
                    
                    [tableView reloadData];
                    
                                       if (isExtendedPoint<noworigin) {
                                            float offsetvalue=noworigin-sumnum;
                                           if (offsetvalue<0) {
                                                offsetvalue=noworigin;
                                            }
                                            tableView.contentOffset=CGPointMake(0,offsetvalue);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                                        }else{
                                            tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                                       }
                    /*自动收起*///---------------------------------------------------------------end------------//
                    
                }
                
                [tableView reloadData] ;
            }
            return;
        }
        
        //－－－－－－－－－－－－－－－－－－－－－－－－－－－组织架构－－－－－－－－－－－－－－－－－－－－－－－－－－－
        id temp=[self.itemArray objectAtIndex:indexPath.row];
        if([temp isKindOfClass:[Dept class]])
        {
            Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
            int level=dept.dept_level+1;
            if (dept.isExtended) { //收起展示
                dept.isExtended=false;
                int remvoecount=0;
                for (int i=indexPath.row+1; i<[self.itemArray count]; i++) {
                    
                    
                    id temp1 = [self.itemArray objectAtIndex:i];
                    
                    if([temp1 isKindOfClass:[Emp class]])
                    {
                        if (((Emp *)temp1).emp_level<=dept.dept_level) {
                            break;
                        }
                    }
                    
                    if([temp1 isKindOfClass:[Dept class]])
                    {
                        if (((Dept *)temp1).dept_level<=dept.dept_level) {
                            break;
                        }
                        
                    }
                    remvoecount++;
                }
                if (remvoecount!=0) {
                    NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                    [self.itemArray removeObjectsInRange:range];
                }
                
            }else   //显示子部门及人员
            {
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                
                NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level];
                // NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id  andLevel:level];
                Dept *dept1;
                Dept *dept2;
                for (int i=0; i<[tempDeptArray count]; i++) {
                    
                    dept1=[tempDeptArray objectAtIndex:i];
                    
                    DeptInMemory *_dept = [_conn getDeptInMemoryByDeptId:dept1.dept_id];
                    if (_dept) {
                        dept1.isChecked = _dept.isChecked;
                    }
                }
                
                NSMutableArray *allArray=[[NSMutableArray alloc]init];
                // [allArray addObjectsFromArray:tempEpArray];
                [allArray addObjectsFromArray:tempDeptArray];
                
                [pool release];
                
                NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                dept.isExtended=true;
                
                [allArray release];
                
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                float noworigin=cell.frame.origin.y;
                
                /*自动收起---------------------------------------------------------------bigen------------*/
                float isExtendedPoint=0;
                float sumnum=0;
                for (int i=0; i<[self.itemArray count]; i++) {
                    id temp1 = [self.itemArray objectAtIndex:i];
                    if([temp1 isKindOfClass:[Dept class]])
                    {   Dept*extendedDept=((Dept *)temp1);
                        if (extendedDept.dept_id!=dept.dept_id&&extendedDept.dept_level==dept.dept_level&&extendedDept.isExtended) {
                            NSIndexPath *tempindexpath=[NSIndexPath indexPathForRow:i inSection:0];
                            UITableViewCell *tempcell=[tableView cellForRowAtIndexPath:tempindexpath];
                            isExtendedPoint=tempcell.frame.origin.y;
                            
                            extendedDept.isExtended=false;
                            int remvoecount=0;
                            float emplen=0;
                            float deptlen=0;
                            for (int nowindex=i+1; nowindex<[self.itemArray count]; nowindex++) {
                                
                                
                                id temp1 = [self.itemArray objectAtIndex:nowindex];
                                
                                if([temp1 isKindOfClass:[Emp class]])
                                {
                                    if (((Emp *)temp1).emp_level<=extendedDept.dept_level) {
                                        break;
                                    }
                                    emplen+=58;
                                }
                                
                                if([temp1 isKindOfClass:[Dept class]])
                                {
                                    if (((Dept *)temp1).dept_level<=extendedDept.dept_level) {
                                        break;
                                    }
                                    deptlen+=42;
                                }
                                remvoecount++;
                            }
                            if (remvoecount!=0) {
                                NSRange range =NSMakeRange(i+1,remvoecount);
                                [self.itemArray removeObjectsInRange:range];
                            }
                            sumnum=deptlen+emplen;
                            break;
                        }
                        
                    }
                }
                
                [tableView reloadData];
                
                                if (isExtendedPoint<noworigin) {
                                    float offsetvalue=noworigin-sumnum;
                                    if (offsetvalue<0) {
                                        offsetvalue=noworigin;
                                   }
                                    tableView.contentOffset=CGPointMake(0,offsetvalue-20);
                                }else{
                                    tableView.contentOffset=CGPointMake(0,noworigin);
                                }
                /*自动收起*///---------------------------------------------------------------end------------//
                
            }
            
            [tableView reloadData] ;
        }
        
        
        
    }
}

-(void)iconAction:(id)sender
{
}


-(void)selectAction:(id)sender
{
    [searchTextView resignFirstResponder];
    
    //	找到复选框所在的行
    UIButton *button = (UIButton *)sender;
    int row = button.titleLabel.text.intValue;// button.tag;
    
    //	取出对应行的对象是一个部门还是一个员工
    id temp=[self.itemArray objectAtIndex:row];
 	
    //	如果是部门
    if([temp isKindOfClass:[Dept class]])
    {
        NSLog(@"----maxGroupNum--%d",maxGroupNum);
        //			判断选中的人员数量
        Dept *dept = (Dept *)temp;
        if (dept.isChecked) { //不选中
            dept.isChecked=false;
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
        }else   //选中
        {
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            dept.isChecked=true;
        }
        //		设置部门，部门的子部门，部门员工，子部门员工的选中状态
        [self selectByDept:dept.dept_id status:dept.isChecked];
        
        //        //		把选中状态呈现在界面上
        //        for (int i=row+1; i<[self.itemArray count]; i++) {
        //            id temp1 = [self.itemArray objectAtIndex:i];
        //
        //            if([temp1 isKindOfClass:[Dept class]])
        //            {
        //                if (((Dept *)temp1).dept_level<=dept.dept_level) {
        //                    break;
        //                }
        //                ((Dept *)temp1).isChecked=dept.isChecked;
        //            }
        //        }
        
        [organizationalTable reloadData];
        
    }
    addButton.enabled=YES;
    //    显示在底部
    //[self bottomScrollviewShow];
}
//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];

    DeptInMemory *_dept = [_conn getDeptInMemoryByDeptId:dept_id];
    if (_dept) {
        _dept.isChecked = selectedStatus;
        
        if (self.selectedDepts==nil) {
            self.selectedDepts=[NSMutableArray array];
        }
        if (selectedStatus) {
            [self.selectedDepts addObject:[NSString stringWithFormat:@"%d",dept_id]];
        }else
        {
             [self.selectedDepts removeObject:[NSString stringWithFormat:@"%d",dept_id]];
        }
        
    }

    [pool release];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
}


#pragma mark ===========handleCmd=============

-(void)handleCmd:(NSNotification *)notification
{
    [UserTipsUtil hideLoadingView];
	eCloudNotification *_notification = [notification object];
	if(_notification != nil)
	{
		int cmdId = _notification.cmdId;
		switch (cmdId) {
            case update_user_data_success:
            {
                [userDataDAO addCommonDept:self.selectedDepts];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case update_user_data_fail:
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_departments_add_failure"]];
                break;
            case update_user_data_timeout:
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_departments_add_timeout"]];
                break;
			default:
				break;
        }
    }
}
@end
