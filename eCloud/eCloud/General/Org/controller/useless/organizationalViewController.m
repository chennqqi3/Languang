//
//  organizationalViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//
#import "organizationalViewController.h"
#import "conn.h"
#import "Dept.h"
#import "Emp.h"
#import "eCloudDAO.h"
#import "PSOrgViewUtil.h"
#import "PSListViewController.h"
#import "PublicServiceDAO.h"
#import "UserDisplayUtil.h"
#import "EmpCell.h"
#import "SearchDeptCell.h"
#import "PermissionModel.h"
#import "PermissionUtil.h"
#import "DeptCell.h"
#import "UIAdapterUtil.h"

#import "specialChooseMemberViewController.h"
#import "talkSessionViewController.h"
#import "eCloudDefine.h"
#import "userInfoViewController.h"
#import "personInfoViewController.h"

@interface organizationalViewController ()

@end

@implementation organizationalViewController
{
	eCloudDAO *_ecloud ;
	BOOL hasService;
}
@synthesize itemArray ;
@synthesize searchTimer;
@synthesize searchStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.searchStr = nil;
    self.searchTimer = nil;
    self.itemArray = nil;
    [super dealloc];
}

//收到组织架构通知后，进行处理，如果是第一次加载，那么关闭对话框，否则从数据库中获取组织架构并刷新
-(void)refreshOrg:(NSNotification*)notification
{
	eCloudNotification *cmd = notification.object;
	switch (cmd.cmdId) {
		case first_load_org:
        case refresh_org:
			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
			[self getRootItem];
			[organizationalTable reloadData];
			break;
		default:
			break;
	}
}

#pragma mark - 显示或隐藏tabar
-(void)displayTabBar
{
    /*
	//	add by shisp 2013.6.16
	//	在隐藏的情况下，显示出来，并且
	if(self.tabBarController && self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上减去tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		//NSLog(@"tabbar height is %.0f",_tabBar.frame.size.height);
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height - _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		self.tabBarController.tabBar.hidden = NO;
		
	}
     */
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}
-(void)hideTabBar
{
	/*
	//	add by shisp 2013.6.16
	//	如果tabbar是显示的状态那么
	if(self.tabBarController && 	!self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上加上tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height + _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		//NSLog(@"height is %.0f",contentView.frame.size.height);
		
		//		隐藏UITabBar
		self.tabBarController.tabBar.hidden = YES;
		
	}
     */
    
    [UIAdapterUtil hideTabBar:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title = [StringUtil getLocalizableString:@"main_contacts"];
	[super viewWillAppear:animated];
    _searchBar.placeholder=[StringUtil getLocalizableString:@"chats_search"];
	//		组织架构不显示服务号
	//	int serviceCount = [[PublicServiceDAO getDatabase] getServiceCount];
	//	hasService = YES;
	//	if(serviceCount == 0)
	//		hasService = NO;

    
	hasService = NO;
	
	[self displayTabBar];

//    if (noflushTag==1) {
//        noflushTag=0;
//        return;
//    }
	//如果是第一次加载组织架构，显示提示框
//	if(_conn.isFirstGetUserDeptList)
//	{
//		[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
//		[[LCLLoadingView currentIndicator]show];
//	}
//    if (_searchBar!=nil) {
//        _searchBar.text = @"";
//    }
//    searchDeptAndEmpTag=0;
    
//    update by shisp 不在appeare里从数据库加载数据，而是在didload里加载一次，以后都是读内存
//	[self getRootItem];
//	[organizationalTable reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	[searchTextView resignFirstResponder];
}
-(void)setTopAction:(id)sender
{
    organizationalTable.contentOffset=CGPointMake(0, 0);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	_conn = [conn getConn];
	_ecloud = [eCloudDAO getDatabase];
    
//	设置背景
    [UIAdapterUtil setBackGroundColorOfController:self];
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil processController:self];
    
//	右边按钮
    [UIAdapterUtil setRightButtonItemWithImageName:@"add_ios.png" andTarget:self andSelector:@selector(addButtonPressed:)];
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake(0, 0, 44, 44);
//    [addButton setBackgroundImage:[UIImage imageNamed:@"add_ios.png"] forState:UIControlStateNormal];
//    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];

    UIButton *setTopButton=[[UIButton alloc]initWithFrame:CGRectMake(130, 2, 60, 40)];
    [setTopButton addTarget:self action:@selector(setTopAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:setTopButton];
    [setTopButton release];
//	查询bar
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getLocalizableString:@"chats_search"];
	//searchTextView = [[_searchBar subviews] lastObject];
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
	
	_searchBar.keyboardType = UIKeyboardTypeDefault;
	_searchBar.backgroundColor=[UIColor colorWithRed:210/255.0 green:215/255.0 blue:220/255.0 alpha:1];

    [self.view addSubview:_searchBar];
	
	[_searchBar release];
	
//	组织架构展示table
	int tableH = 332;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
     organizationalTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, tableH) style:UITableViewStylePlain];
    [organizationalTable setDelegate:self];
    [organizationalTable setDataSource:self];
    organizationalTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:organizationalTable];
	
    backgroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, tableH)];
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    [organizationalTable addSubview:backgroudButton];
    backgroudButton.hidden=YES;
	
	//	add by shisp  注册组织架构信息变动通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
    
    [self getRootItem];
	[organizationalTable reloadData];
    [UIAdapterUtil setExtraCellLineHidden:organizationalTable];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
	self.itemArray = nil;
	
	if(_searchText)
		[_searchText release];
	
	//	add by shisp 取消组织结构变动通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:ORG_NOTIFICATION object:nil];
}
-(void)dismissKeybordByClickBackground
{
    [_searchBar resignFirstResponder];
     backgroudButton.hidden=YES;
}

//触摸关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[searchTextView resignFirstResponder];
}

//获取一级部门
-(void)getRootItem
{
	searchDeptAndEmpTag = 0;
    _searchBar.text = @"";
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSArray *allDept = [_ecloud getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
    self.itemArray = [NSMutableArray arrayWithArray:allDept];
	[pool release];
}



#pragma mark------UISearchBarDelegate-----

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	isSearch	=	YES;
    backgroudButton.hidden=NO;
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    NSLog(@"%s",__FUNCTION__);
    self.searchStr = [StringUtil trimString:searchBar.text];
	if([self.searchStr length] == 0)
	{    searchDeptAndEmpTag=0;
		[self getRootItem];
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
        
        searchDeptAndEmpTag=1;
        
        NSString *_searchStr = [NSString stringWithString:self.searchStr];
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        NSMutableArray *dataarray=[NSMutableArray array];
        
		NSArray *emparray= [_ecloud getEmpsByNameOrPinyin:_searchStr andType:_type];

        if (![_searchStr isEqualToString:self.searchStr]) {
            NSLog(@"1 查询条件有变化");
            [pool release];
            return;
        }
 		NSArray *deptarray = [_ecloud getDeptByNameOrPinyin:_searchStr andType:_type];
        
        [dataarray addObjectsFromArray:emparray];
        [dataarray addObjectsFromArray:deptarray];
        
        self.itemArray=dataarray;
        
		[pool release];
        
        if (![_searchStr isEqualToString:self.searchStr]) {
            NSLog(@"2 查询条件有变化");
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [organizationalTable reloadData];
        });

    });
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//	现在已经不是search按钮了，而是done按钮
	[searchBar resignFirstResponder];
     backgroudButton.hidden=YES;
}

-(void) addButtonPressed:(id) sender{
    [searchTextView resignFirstResponder];
	
    specialChooseMemberViewController *_controller = [[specialChooseMemberViewController alloc]init];
    _controller.typeTag=0;
    [self hideTabBar];
	[self.navigationController pushViewController:_controller animated:YES];
    [_controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)phoneActon:(id)sender
{
    UIButton *button=(UIButton *)sender;
    [personInfoViewController callNumber:button.titleLabel.text];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(hasService && searchDeptAndEmpTag==0)
		return 2;
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0 && hasService && searchDeptAndEmpTag==0)
		return 1;
    return [self.itemArray count];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	公众服务号
	if(indexPath.section == 0 && hasService && searchDeptAndEmpTag==0)
		return 0;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	公众服务号
	if(indexPath.section == 0 && hasService && searchDeptAndEmpTag==0)
		return ps_row_height;
	
    if (searchDeptAndEmpTag==1) {
        //部门搜索
     
//        if ([[self tableView:tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[SearchDeptCell class]]) {
//             return emp_row_height+5;
//        }
//        else{
//            EmpCell *empCell = (EmpCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        return emp_row_height;

    }else{
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[Dept class]]) {
        return dept_row_height;
    }// Configure the cell.
	else {
        return emp_row_height;
	}
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(hasService && searchDeptAndEmpTag==0 && section == 1)
	{
		return org_header_view_height;
	}
	return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(hasService && searchDeptAndEmpTag==0)
		return [PSOrgViewUtil orgViewForHeaderInSection:section];
	return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    
    if ([temp isKindOfClass:[Dept class]])
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	NSLog(@"%s,searchDeptAndEmpTag is %d",__FUNCTION__, searchDeptAndEmpTag);
	//	公众平台服务号
    
	if(hasService && searchDeptAndEmpTag==0 && indexPath.section == 0)
	{
		static NSString *MyIdentifier = @"public_service";
		UITableViewCell *cell = [PSOrgViewUtil pSTableViewCellWithReuseIdentifier:MyIdentifier];
		return cell;
	}
	
	
    if (searchDeptAndEmpTag==1)
	{
        id temp=[self.itemArray objectAtIndex:indexPath.row];
		
        if ([temp isKindOfClass:[Dept class]])
		{
			static NSString *searchDeptCellID = @"searchDeptCellID";
			
			SearchDeptCell *searchDeptCell = [tableView dequeueReusableCellWithIdentifier:searchDeptCellID];
			if(searchDeptCell == nil)
			{
				searchDeptCell = [[[SearchDeptCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchDeptCellID]autorelease];
				UIButton *phoneButton = (UIButton*)[searchDeptCell viewWithTag:phone_button_tag];
				[phoneButton addTarget:self action:@selector(phoneActon:) forControlEvents:UIControlEventTouchUpInside];
			}
			
			Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
  			[searchDeptCell configureCell:dept];
			
			return searchDeptCell;
        }
		else
        {
			return [self getEmpWithDeptCell:indexPath];
        }
    }
	else
	{
		id temp=[self.itemArray objectAtIndex:indexPath.row];
		if ([temp isKindOfClass:[Dept class]])
		{
			static NSString *deptCellID = @"deptCellID";
            DeptCell *deptCell = [tableView dequeueReusableCellWithIdentifier:deptCellID];
 			if (deptCell == nil)
			{
				deptCell = [[[DeptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deptCellID] autorelease];
			}
			Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
			[deptCell configCell:dept];
			return deptCell;
		}
		else
		{
			return [self getEmpCell:indexPath];
		}
    }
}

#pragma mark 获取员工的显示方式
-(EmpCell *)getEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpCell *empCell = [organizationalTable dequeueReusableCellWithIdentifier:empCellID];
	if(empCell == nil)
	{
		empCell = [[[EmpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
        
        [self addGesture:empCell];
		
//		UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
//		[detailButton addTarget:self action:@selector(DetailAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	Emp *emp = [self.itemArray objectAtIndex:indexPath.row];
	[empCell configureCell:emp];
	
//	UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
//	detailButton.titleLabel.text = [StringUtil getStringValue:indexPath.row];
	return empCell;
}

- (void)addGesture:(EmpCell *)empCell
{
    UIImageView *logoView = (UIImageView *)[empCell viewWithTag:emp_logo_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openPersonInfo:)];
    [logoView addGestureRecognizer:singleTap];
    [singleTap release];
}

#pragma mark 获取员工的显示方式
-(EmpCell *)getEmpWithDeptCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpCell *empCell = [organizationalTable dequeueReusableCellWithIdentifier:empCellID];
	if(empCell == nil)
	{
		empCell = [[[EmpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
		[self addGesture:empCell];

//		UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
//		[detailButton addTarget:self action:@selector(DetailAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	Emp *emp = [self.itemArray objectAtIndex:indexPath.row];
	[empCell configureWithDeptCell:emp];
	
//	UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
//	detailButton.titleLabel.text = [StringUtil getStringValue:indexPath.row];
	return empCell;
}
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//	公众平台
	if(hasService && searchDeptAndEmpTag==0 && indexPath.section == 0 && indexPath.row == 0)
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		PSListViewController *controller = [[PSListViewController alloc]initWithStyle:UITableViewStylePlain];
//		controller.hidesBottomBarWhenPushed = YES;
        [self hideTabBar];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
		
		return;
	}
	
	
    if (searchDeptAndEmpTag==1) {
        //		如果用户点击的是具体的员工，那么就打开与该员工进行会话的窗口
        id temp=[self.itemArray objectAtIndex:indexPath.row];
		if([temp isKindOfClass:[Emp class]])
		{
            if ([_conn.userId intValue]==((Emp *)temp).emp_id) {
                [self hideTabBar];
                [organizationalViewController openUserInfoById:_conn.userId andCurController:self];
                return;
            }
            
            if(!((Emp*)temp).permission.canSendMsg)
            {
                NSLog(@"没有给对方发消息的权限");
                [PermissionUtil showAlertWhenCanNotSendMsg:(Emp*)temp];
                return;
            }
//            [UIAdapterUtil openConversation:self andEmp:(Emp*)temp];
            NSString *empIdStr = [NSString stringWithFormat:@"%i",((Emp *)temp).emp_id];
            [organizationalViewController openUserInfoById:empIdStr andCurController:self];
		}else
        { Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
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
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                float noworigin=cell.frame.origin.y;
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level];
               // NSArray *tempEpArray=[_ecloud getDeptEmpInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level];
                NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id andLevel:level];
                NSMutableArray *allArray=[[NSMutableArray alloc]init];
                [allArray addObjectsFromArray:tempEpArray];
                [allArray addObjectsFromArray:tempDeptArray];
                
				[pool release];
                NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
				[allArray release];
				
                dept.isExtended=true;
                 
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
                                    emplen+=emp_row_height;
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
                    tableView.contentOffset=CGPointMake(0,offsetvalue);
					//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                }else{
                    tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                }
                /*自动收起*///---------------------------------------------------------------end------------//
            }

            [tableView reloadData] ;
        
        }
    }else{
	[searchTextView resignFirstResponder];
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
            UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            float noworigin=cell.frame.origin.y;
			
			NSMutableArray *allArray=[[NSMutableArray alloc]init];
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level];
           // NSArray *tempEpArray=[_ecloud getDeptEmpInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level];
             NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id andLevel:level];
             [allArray addObjectsFromArray:tempEpArray];
            [allArray addObjectsFromArray:tempDeptArray];
			[pool release];
            NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
            [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
			[allArray release];
			
            dept.isExtended=true;
            
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
                                 emplen+=emp_row_height;
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
        
//			[LogUtil debug:[NSString stringWithFormat:@" noworigin is %.0f isExtendedPoint is %.0f ,sumnum is %.0f",noworigin,isExtendedPoint,sumnum]];
			
            if (isExtendedPoint<noworigin) {
                float offsetvalue=noworigin-sumnum;
                if (offsetvalue<0) {
                    offsetvalue=noworigin;
                }
             tableView.contentOffset=CGPointMake(0,offsetvalue);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
            }else{
            tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
            }
			
			if(hasService)
			{
				CGPoint _point = tableView.contentOffset;
				_point.y = _point.y - (org_header_view_height + ps_row_height);
				tableView.contentOffset = _point;
			}
			
//			[LogUtil debug:[NSString stringWithFormat:@"tableView.contentOffset %.0f", tableView.contentOffset.y]];


            /*自动收起*///---------------------------------------------------------------end------------//
//            NSLog(@"---cell.offset-- %0.0f",tableView.contentOffset.y);
        }
    
        [tableView reloadData] ;
    }

	else {
//		如果用户点击的是具体的员工，那么就打开与该员工进行会话的窗口
		if([temp isKindOfClass:[Emp class]])
		{
             if ([_conn.userId intValue]==((Emp *)temp).emp_id) {
                 [self hideTabBar];
                [organizationalViewController openUserInfoById:_conn.userId andCurController:self];
                return;
            }
            
            if(!((Emp*)temp).permission.canSendMsg)
            {
                [PermissionUtil showAlertWhenCanNotSendMsg:(Emp*)temp];
                NSLog(@"没有给对方发消息的权限");
                return;
            }
//            [UIAdapterUtil openConversation:self andEmp:(Emp*)temp];
        NSString *empIdStr = [NSString stringWithFormat:@"%i",((Emp *)temp).emp_id];
        [organizationalViewController openUserInfoById:empIdStr andCurController:self];
		}
	 }
    }
}

-(void)openPersonInfo:(UIGestureRecognizer*)gesture
{
    UIImageView *logoView = gesture.view;
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    NSString *empIdStr = empIdLabel.text;
    
    [self hideTabBar];
    
    [organizationalViewController openUserInfoById:empIdStr andCurController:self];
}

+ (void)openUserInfoById:(NSString *)empId andCurController:(UIViewController *)curController
{
    conn *_conn = [conn getConn];
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    if (empId.intValue ==  _conn.userId.intValue)
    {
        userInfoViewController *userInfo=[[userInfoViewController alloc]init];
        userInfo.tagType=1;
        [curController.navigationController pushViewController:userInfo animated:YES];
        [userInfo release];
    }
    else
    {
        personInfoViewController *personInfo=[[personInfoViewController alloc]init];
        personInfo.emp = [_ecloud getEmpInfo:empId];
        [curController.navigationController pushViewController:personInfo animated:YES];
        [personInfo release];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
  //  NSLog(@"-----scrollViewDidScroll");
//    if (!backgroudButton) {
//         [_searchBar resignFirstResponder];
//        backgroudButton.hidden=YES;
//    }

    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
//    NSLog(@"-----scrollViewDidEndDragging");
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    for (UIView *possibleButton in _searchBar.subviews)
	{
		if ([possibleButton isKindOfClass:[UIButton class]])
		{
			UIButton *cancelButton = (UIButton*)possibleButton;
			cancelButton.enabled = YES;
			break;
		}
	}
}
@end
