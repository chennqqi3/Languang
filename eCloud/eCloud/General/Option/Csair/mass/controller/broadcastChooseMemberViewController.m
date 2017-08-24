//
//  specialChooseMemberViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-10.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "broadcastChooseMemberViewController.h"
#import "talkSessionViewController.h"
#import "chatMessageViewController.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "addScheduleViewController.h"
#import "RecentMember.h"
#import "RecentGroup.h"
#import "AdvanceQueryDAO.h"
#import "citiesObject.h"
#import "memberDetailViewController.h"
#import "UIAdapterUtil.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "AdvancedSearchViewController.h"
#import "rankChooseViewController.h"
#import "businessChooseViewController.h"
#import "zoneChooseViewController.h"
#import "Emp.h"
#import "Dept.h"

@implementation broadcastChooseMemberViewController
{
	eCloudDAO *_ecloud ;
    UIScrollView *changeScrollview;
    AdvanceQueryDAO *advanceQueryDAO;
}
@synthesize nowSelectedEmpArray;
@synthesize oldEmpIdArray;
@synthesize itemArray ;
@synthesize typeArray;

@synthesize employeeArray;
@synthesize  deptArray;
@synthesize typeTag;
@synthesize delegete;
@synthesize isAdvancedSearch;

@synthesize chooseArray;
@synthesize rankLabel;
@synthesize bussinesslLabel;
@synthesize zoneArray;
@synthesize rank_list_str;
@synthesize business_list_str;
-(void)dealloc
{
	NSLog(@"%s",__FUNCTION__);
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
			self.employeeArray =  [NSMutableArray arrayWithArray:_conn.allEmpArray];
			self.deptArray=[NSMutableArray arrayWithArray:[_ecloud getDeptList]];
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

#pragma mark 处理信息
- (void)handleCmd:(NSNotification *)notification
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:true];
	
  	eCloudNotification	*cmd					=	(eCloudNotification *)[notification object];
	switch (cmd.cmdId)
	{
        case modify_group_success:
        {
			//				增加会话成员
			NSMutableArray *tempArray = [NSMutableArray array];
			NSDictionary *dic;
			
			NSMutableString *newMemberName = [NSMutableString string];
			for(Emp *_emp in self.nowSelectedEmpArray)
			{
				dic = [NSDictionary dictionaryWithObjectsAndKeys:_convId,@"conv_id",[StringUtil getStringValue:_emp.emp_id ],@"emp_id", nil];
				[tempArray addObject:dic];
				[newMemberName appendString:[_emp getEmpName]];
				[newMemberName appendString:@","];
			}
			[_ecloud addConvEmp:tempArray];
			
			if(newMemberName.length > 1)
			{
				[newMemberName deleteCharactersInRange:NSMakeRange(newMemberName.length - 1, 1)];
                
				NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_invite_x_join_group"],newMemberName];
				[_conn saveGroupNotifyMsg:_convId andMsg:msgBody andMsgTime:[_conn getSCurrentTime]];
			}
			
			NSLog(@"添加成员成功");
			[self addMemberSuccess];
        }
			break;
        case modify_group_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"添加成员失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
			break;
		case cmd_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"通讯超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
			break;
		default:
			break;
	}
}
-(void)highButtonPressed:(id)sender
{
    if (advancedSearch==nil) {
        advancedSearch=[[AdvancedSearchViewController alloc]init];
        advancedSearch.delegete=self;
    }
    isAdvancedSearch=YES;
    [self.navigationController pushViewController:advancedSearch animated:YES];
}
-(void)chooseButtonPressed:(id)sender
{
    leftButton.hidden=NO;
    self.title=@"筛选";
    isAdvancedSearch=YES;
    [searchTextView resignFirstResponder];
    CATransition *animation = [CATransition animation];
    
    animation.delegate = self;
    // 设定动画时间
    animation.duration =0.5;
    // 设定动画快慢(开始与结束时较慢)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // 12种类型
    // animation.type = @"rippleEffect";
    animation.type = kCATransitionPush;
    
    animation.subtype = kCATransitionFromRight;
    // 动画开始
    [[changeScrollview layer] addAnimation:animation forKey:@"animation"];
    
    changeScrollview.contentOffset=CGPointMake(320, 0);
  
    
}
-(void)toLeftPressed:(id)sender
{
    leftButton.hidden=YES;
    self.title=@"选择联系人";
    isAdvancedSearch=NO;
    CATransition *animation = [CATransition animation];
    
    animation.delegate = self;
    // 设定动画时间
    animation.duration =0.5;
    // 设定动画快慢(开始与结束时较慢)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // 12种类型
    // animation.type = @"rippleEffect";
    animation.type = kCATransitionPush;
    
    animation.subtype = kCATransitionFromLeft;
    // 动画开始
    [[changeScrollview layer] addAnimation:animation forKey:@"animation"];
    
    changeScrollview.contentOffset=CGPointMake(0, 0);
    
    self.zoneArray = [NSMutableArray array];
    
    self.chooseArray= [NSMutableArray array];
    self.bussinesslLabel.text=@"业务";
    self.rankLabel.text=@"级别";
    self.rank_list_str=nil;
    self.business_list_str=nil;
    [chooseTable reloadData];
    
}

- (void)viewDidLoad
{
    
	NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
	_conn = [conn getConn];
	_ecloud = [eCloudDAO getDatabase];
    self.typeArray=[_ecloud getTypeArray];
    isSearch=NO;
    isExpand=YES;
    isNeedSearchAgain=NO;
    isDetailAction=NO;
    select_emp_sum=0;
    all_result_sum=0;
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    self.title=@"选择联系人";
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    //	组织架构展示table
	int tableH = 460 - 84 - 44;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    changeScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320, tableH+84)];
    changeScrollview.showsHorizontalScrollIndicator = YES;
    changeScrollview.showsVerticalScrollIndicator = YES;
    [self.view addSubview:changeScrollview];

    //	查询bar
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
	_searchBar.delegate=self;
	_searchBar.placeholder=@"输入姓名,拼音,工号进行查询";
	_searchBar.backgroundColor=[UIColor colorWithRed:210/255.0 green:215/255.0 blue:220/255.0 alpha:1];
	_searchBar.keyboardType = UIKeyboardTypeDefault;
	
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
    _searchBar.showsCancelButton = YES;
    for(id cc in [_searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"筛选"  forState:UIControlStateNormal];
            btn.hidden=YES;
        }
    }
    //   [_searchBar becomeFirstResponder];
    
	[searchTextView setReturnKeyType:UIReturnKeyDone];
	
	[changeScrollview addSubview: _searchBar];
	[_searchBar release];
    
    UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseButton.frame = CGRectMake(320-55, 0, 50, 30);
    [chooseButton addTarget:self action:@selector(chooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    chooseButton.backgroundColor=[UIColor clearColor];
    
    UILabel *buttontitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
    buttontitle.text=@" 筛选";
    buttontitle.font=[UIFont systemFontOfSize:14];
    buttontitle.textColor=[UIColor whiteColor];
     buttontitle.backgroundColor=[UIColor clearColor];
    UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, 40)];
    lineimage.image=[StringUtil getImageByResName:@"line_left.png"];
    [buttontitle addSubview:lineimage];
    [lineimage release];
    UIImageView *rightimage=[[UIImageView alloc]initWithFrame:CGRectMake(35,12.5, 15, 15)];
    rightimage.image=[StringUtil getImageByResName:@"small_right.png"];
    [buttontitle addSubview:rightimage];
    [rightimage release];
    [chooseButton addSubview:buttontitle];
    //[chooseButton setTitle:@"筛选" forState:UIControlStateNormal];
    [changeScrollview addSubview:chooseButton];
    //[chooseButton release];
    
    
    
    organizationalTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, tableH) style:UITableViewStylePlain];
    [organizationalTable setDelegate:self];
    [organizationalTable setDataSource:self];
    organizationalTable.backgroundColor=[UIColor clearColor];
    [changeScrollview addSubview:organizationalTable];
    
    //-------筛选－－－－－－－
    self.zoneArray = [NSMutableArray array];
    advanceQueryDAO = [AdvanceQueryDAO getDataBase];
    self.chooseArray= [NSMutableArray array];
    
    leftButton =  [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"联系人"] andTarget:self andSelector:@selector(toLeftPressed:)];
    leftButton.hidden=YES;
    
    
    chooseTable= [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, tableH+40) style:UITableViewStylePlain];
    [chooseTable setDelegate:self];
    [chooseTable setDataSource:self];
    chooseTable.backgroundColor=[UIColor clearColor];
    [changeScrollview addSubview:chooseTable];
    
    self.rankLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 20)];
    self.rankLabel.backgroundColor=[UIColor clearColor];
    self.rankLabel.font=[UIFont systemFontOfSize:14];
    self.rankLabel.textColor=[UIColor blackColor];
    
    self.bussinesslLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 20)];
    self.bussinesslLabel.backgroundColor=[UIColor clearColor];
    self.bussinesslLabel.font=[UIFont systemFontOfSize:14];
    self.bussinesslLabel.textColor=[UIColor blackColor];
    
    self.bussinesslLabel.text=@"业务";
    self.rankLabel.text=@"级别";
    
    titleview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    titleview.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    UIButton *titleButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [titleButton setImage:[StringUtil getImageByResName:@"sereach_up.png"] forState:UIControlStateNormal];
    titleButton.backgroundColor=[UIColor lightGrayColor];
    titleButton.tag=1;
    [titleButton addTarget:self action:@selector(expendAction:) forControlEvents:UIControlEventTouchUpInside];
   
    
    UILabel *taglabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 30,100 , 30)];
    taglabel.text=@" 筛选结果";
    taglabel.backgroundColor=[UIColor clearColor];
    taglabel.font=[UIFont systemFontOfSize:14];
    numlabel=[[UILabel alloc]initWithFrame:CGRectMake(210, 30,100, 30)];
    
    numlabel.textAlignment=NSTextAlignmentCenter;
    numlabel.backgroundColor=[UIColor clearColor];
    numlabel.font=[UIFont systemFontOfSize:14];
    titleview.layer.masksToBounds=YES;
    [titleview addSubview:titleButton];
    [titleview addSubview:taglabel];
    [titleview addSubview:numlabel];
    //[numlabel release];
    [taglabel release];
    
    resultButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resultButton.frame = CGRectMake(320-55, 0, 45, 30);
    [resultButton setBackgroundImage:[StringUtil getImageByResName:@"s_up.png"] forState:UIControlStateNormal];
//    [resultButton setBackgroundImage:[StringUtil getImageByResName:@"s_down.png"] forState:UIControlStateHighlighted];
//    [resultButton setBackgroundImage:[StringUtil getImageByResName:@"s_down.png"] forState:UIControlStateSelected];
    [resultButton addTarget:self action:@selector(resultPressed:) forControlEvents:UIControlEventTouchUpInside];
    [titleview addSubview:resultButton];
    
    
	//	add by shisp  注册组织架构信息变动通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
    
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	
    //	自定义导航栏
	int toolbarY = self.view.frame.size.height - 44-44;
    //	if(iPhone5)
    //		toolbarY = toolbarY + i5_h_diff;
    UINavigationBar *bottomNavibar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, toolbarY, 320, 45)];
    bottomNavibar.tintColor=[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0];
    [self.view addSubview:bottomNavibar];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(260, 7.5, 50, 30);
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [addButton setTitle:@"确定" forState:UIControlStateNormal];
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
}
-(void)resultPressed:(id)sender
{
    if (!isNeedSearchAgain) {
        
        return;
    }
    if (self.rank_list_str==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请选择级别" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
//    if (self.business_list_str==nil) {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请选择业务" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//        [alert release];
//        return;
//    }
    
    city_list_str=nil;
    for (int i=0; i<[self.zoneArray count]; i++) {
        id temp=[self.zoneArray objectAtIndex:i];
        if ([temp isKindOfClass:[citiesObject class]])
        {
            citiesObject *city=   (citiesObject *)temp;
            
            if (city_list_str==nil) {
                city_list_str=city.some_cityid;
            }else
            {
                city_list_str=[NSString stringWithFormat:@"%@,%@",city_list_str,city.some_cityid];
            }
            
        }
    }
    isNeedSearchAgain=NO;
    // self.chooseArray=[advanceQueryDAO getChooseArrayByRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    [advanceQueryDAO createTempDepts:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    self.chooseArray=[advanceQueryDAO getTempDeptInfoWithLevel:@"0" andLevel:0 andSelected:false];
    int num=[advanceQueryDAO getAllNumFromResult:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    numlabel.text=[NSString stringWithFormat:@"%d",num];
    [chooseTable reloadData];
    //    if ([self.chooseArray count]>3) {
    //        [chooseTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
    //                           atScrollPosition: UITableViewScrollPositionTop
    //                                   animated:NO];
    //    }
    
}
-(void)bottomScrollviewShow
{
    
    for(UIView *view in [bottomScrollview subviews])
    {
        [view removeFromSuperview];
    }
    
	UITableViewCell *pageview;
	
	int nowindex=0;
	
	int iconSize = 30;
	
	UIButton *iconbutton;
    
    UILabel* nameLabel;
    
	int x;
	int y;
	int cx;
	int cy;
    x=0;
	y=0;
	cx=5;
	cy=0;
	pageview=[[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, bottomScrollview.frame.size.width, bottomScrollview.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
    Emp *emp;
    NSString *empLogo;
    NSMutableArray *selectArray = [NSMutableArray arrayWithArray:self.nowSelectedEmpArray];
	
	
    //	如果有选中的那么加到selectArray中
    //    for (int i=0; i<[self.employeeArray count]; i++) {
    //        emp=[self.employeeArray objectAtIndex:i];
    //        if (emp.isSelected) {
    //            [selectArray addObject:emp];
    //                   }
    //    }
    
    if ([selectArray count]==0) {
        addButton.enabled=NO;
        [addButton setTitle:@"确定" forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        
    }else
    {
        
        addButton.enabled=YES;
        NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",[selectArray count]];
        [addButton setTitle:titlestr forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        if ([selectArray count]>80) {
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
        }
    }
    for (int i=0; i<[selectArray count]; i++) {
        cx=cx+iconSize + 5;
        if (i==0) {
            cx=0;
        }
        emp=[selectArray objectAtIndex:i];
        //		update by shisp icon大小设为30，否则和文字重叠
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+3,iconSize,iconSize)];
        
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, iconSize , iconSize, 45 - iconSize - 6)];
        nameLabel.text=emp.emp_name;
        nameLabel.textAlignment=UITextAlignmentCenter;
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont boldSystemFontOfSize:9];
        [iconbutton addSubview:nameLabel];
        [nameLabel release];
        empLogo = emp.emp_logo;
        
        //	获取圆角的用户头像
        UIImage *image = [self getEmpLogo:emp];
        
        [iconbutton setBackgroundImage:image forState:UIControlStateNormal];
        iconbutton.tag=i;
        
        iconbutton.backgroundColor=[UIColor clearColor];
        [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
        // backView.image=[StringUtil getImageByResName:@"setting.png"];
        //[pageview addSubview:backView];
        [pageview addSubview:iconbutton];
        
        
        [iconbutton release];
        
    }
    pageview.frame=CGRectMake(0, 0,x+cx+45,45);
	pageview.backgroundColor=[UIColor clearColor];
	[bottomScrollview addSubview:pageview];
	bottomScrollview.contentSize = CGSizeMake(x+cx+45,45);
    CGPoint bottomOffset = CGPointMake(bottomScrollview.contentSize.width - bottomScrollview.bounds.size.width,0);
    [bottomScrollview setContentOffset:bottomOffset animated:NO];
    
}
-(void)iconbuttonAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    Emp *emp=[self.nowSelectedEmpArray objectAtIndex:index];
    NSLog(@"--删除成员－－index %d  emp %@",index,emp);
    emp.isSelected=false;
    [self selectByEmployee:emp.emp_id status:emp.isSelected];
    
    for (int i=0; i<[self.itemArray count]; i++) {
        id temp1 = [self.itemArray objectAtIndex:i];
        if([temp1 isKindOfClass:[Emp class]])
        {
            Emp *emp1=(Emp *)temp1;
            if (emp1.emp_id==emp.emp_id) {
                emp1.isSelected=false;
            }
        }
        
    }
    
    [organizationalTable reloadData];
    //    显示在底部
  //  [self bottomScrollviewShow];
}

-(UIImage *)getEmpLogo:(Emp*)emp
{
	UIImage *image = nil;
	NSString *empLogo = emp.emp_logo;
	if(empLogo && [empLogo length] > 0)
	{
		NSString *picPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
		UIImage *img = [UIImage imageWithContentsOfFile:picPath];
        if (img)
		{
			image=[UIImage createRoundedRectImage:img size:CGSizeZero];
		}
	}
	if(image == nil)
	{
		if (emp.emp_sex==0)
		{//女
			image=[StringUtil getImageByResName:@"female.png"];
		}
		else
		{
			image=[StringUtil getImageByResName:@"male.png"];
		}
	}
	return image;
}
-(void)dismissSelf:(NSNotification *)notification
{
	
	[self dismissModalViewControllerAnimated:NO];
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
   
    
    
    if (isDetailAction) {
        isDetailAction=NO;
        return;
    }
    if (isAdvancedSearch) {//高级搜索返回
        
//        if (bottomScrollview!=nil) {
//            [self bottomScrollviewShow];
//        }
        changeScrollview.contentOffset=CGPointMake(320, 0);
        [chooseTable reloadData];
        return;
    }
    if (isNeedSearchAgain&&(self.rank_list_str!=nil||self.business_list_str!=nil||city_list_str!=nil)) {
        
        [self resultPressed:nil];
        
    }
    isSearch=NO;
	self.oldEmpIdArray = [NSMutableArray array];
	self.nowSelectedEmpArray = [NSMutableArray array];
    
    if (_conn==nil) {
        _conn = [conn getConn];
    }
	if(self.typeTag == 0)
	{   Emp*emp=[_ecloud getEmpInfo:_conn.userId];
        
		[self.oldEmpIdArray addObject:emp];
	}
	else if(self.typeTag == 1)
	{
		[self.oldEmpIdArray addObjectsFromArray:((chatMessageViewController*)(self.delegete)).dataArray];
	}else
    {
        [self.oldEmpIdArray addObjectsFromArray: ((addScheduleViewController*)self.delegete).dataArray];
    }
	
    //	int wpurview=_conn.wPurview;
    //    int groupNumFlag=wpurview%2;//0表示 没有权限 1表示有权限
    //    if (groupNumFlag==0)
    //	{
    //		maxGroupNum=[[_conn.wPurviewDic objectForKey:@"1"]intValue];
    //	}
    //	else
    //	{
    //		maxGroupNum = 100;
    //	}
	maxGroupNum = 80;
	
	NSLog(@"本次选中的最多人数为%d",(maxGroupNum - self.oldEmpIdArray.count));
    //	if(_conn.isFirstGetUserDeptList)
    //	{
    //		[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
    //		[[LCLLoadingView currentIndicator]show];
    //	}
	
	[_conn setAllEmpNotSelect];
	
	self.employeeArray =  [NSMutableArray arrayWithArray:_conn.allEmpArray];
	self.deptArray=[NSMutableArray arrayWithArray:[_ecloud getDeptList]];
    
	//	如果原来是查询状态，那么维持之前的状态
	[self getRootItem];
	[organizationalTable reloadData];
    
    //	接收分组成员修改通知
    [[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(handleCmd:)
												name:MODIFYMEBER_NOTIFICATION
											  object:nil];
    //	分组成员修改 超时通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
    
//    if (bottomScrollview!=nil) {
//        [self bottomScrollviewShow];
//    }
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if (!isAdvancedSearch) {//不是 高级搜索返回
        _searchBar.text = @"";
    }
    [_searchBar resignFirstResponder];
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if([searchText length] == 0)
	{
		[self getRootItem];
        isSearch=NO;
	}
	else
	{
		int _type = [StringUtil getStringType:searchBar.text];
		if(_type == other_type)
			return;
        isSearch=YES;
		self.itemArray = [NSMutableArray arrayWithArray:[_ecloud getEmpsByNameOrPinyin:searchBar.text andType:_type]];
	}
	[organizationalTable reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
    if (self.typeTag==2) {
        self.navigationController.navigationBarHidden = NO;
    }
	[self.navigationController popViewControllerAnimated:YES];
    select_emp_sum=0;
    all_result_sum=0;
    addButton.enabled=NO;
    [addButton setTitle:@"确定" forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
}

//隐藏查询输入框的键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[searchTextView resignFirstResponder];
}
#pragma mark 提醒用户选择人数已经超过最大值
-(void)showGroupNumExceedAlert
{
	NSString *titlestr=[NSString stringWithFormat:@"群组的成员个数最多为%d个",maxGroupNum];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:titlestr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}
-(void)detailButtonPressed:(id)sender
{
    isDetailAction=YES;
    // [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
    NSString *emp_id_list=nil;
    int count_num=[self.nowSelectedEmpArray count];
    for (int i=0; i<count_num; i++) {
        
        Emp *emp=[self.nowSelectedEmpArray objectAtIndex:i];
        if (i==0) {
            emp_id_list=[NSString stringWithFormat:@"%d",emp.emp_id];
        }else
        {
            emp_id_list=[NSString stringWithFormat:@"%@,%d",emp_id_list,emp.emp_id];
        }
    }
    [advanceQueryDAO createTempDeptsByEmpIdList:emp_id_list];
    
    memberDetailViewController *memberDetail=[[memberDetailViewController alloc]init];
    memberDetail.title=[NSString stringWithFormat:@"选中联系人(%d)",count_num];
    memberDetail.emp_id_list=emp_id_list;
    
    [self.navigationController pushViewController:memberDetail animated:YES];
    [memberDetail release];
    NSLog(@"---here---emp_id_list %@",emp_id_list);
    
}
#pragma mark 选择后确定
-(void) addButtonPressed:(id) sender{
    //	关闭键盘
	[searchTextView resignFirstResponder];
	
    NSMutableArray *dept_emp_array=[NSMutableArray array];
    Dept *dept;
    for (int i=0; i<[self.deptArray count]; i++) {
        
        dept=[self.deptArray objectAtIndex:i];
        if (dept.isChecked) {
            [dept_emp_array addObject:dept];
        }
    }
    [dept_emp_array addObjectsFromArray:self.nowSelectedEmpArray];
    NSLog(@"dept_emp_array ----  %@",[dept_emp_array description]);
    
    return;
    //	typeTag 为0，表示是选中人员，创建会话，否则是从成员管理界面而来，是添加成员
	if(self.typeTag == 0)
	{
		if(talkSession == nil)
			talkSession=[[talkSessionViewController alloc]init];
        //		创建单聊
		if ([self.nowSelectedEmpArray count]==1)
		{ //单聊
			Emp *emp = [self.nowSelectedEmpArray objectAtIndex:0];
			talkSession.titleStr=emp.emp_name;
			talkSession.talkType=singleType;
			
			[self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
            
			talkSession.convEmps = self.nowSelectedEmpArray;
			talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
			talkSession.needUpdateTag = 1;
		}
		else
		{
            //			判断选中的人员数量
//			if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count) )
//			{
//				[self showGroupNumExceedAlert];
//				return;
//			}
            
            //	创建多人会话
			talkSession.titleStr=@"多人会话";
//			talkSession.talkType=mutiableType;
			talkSession.talkType = massType;
			talkSession.convId=nil;
			[self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
			talkSession.convEmps = self.nowSelectedEmpArray;
			talkSession.needUpdateTag = 1;
		}
        //		打开会话窗口
		[self.navigationController pushViewController:talkSession animated:YES];
        //		[self presentModalViewController:talkSession animated:YES];
		
	}
	else  if(self.typeTag==1)
	{
		_convId = ((chatMessageViewController*)self.delegete).convId;
        //		把从成员列表页面带过来的convId保存起来
		if(self.oldEmpIdArray.count == 2)
		{
			isGroupCreate = false;
		}
		else
		{
			if(_convId == nil || _convId.length == 0)
			{
				isGroupCreate = false;
			}
			else
			{
				isGroupCreate =[_ecloud isGroupCreate:_convId];
			}
		}
		
		//				判断群组成员数量
//		if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count))
//		{
//			[self showGroupNumExceedAlert];
//			return;
//		}
		if(isGroupCreate)
		{
			[[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
			[[LCLLoadingView currentIndicator]show];
			
			if(![_conn modifyGroupMember:((chatMessageViewController*)self.delegete).convId andEmps:self.nowSelectedEmpArray andOperType:0])
			{
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
			}
		}
		else
		{
			[self addMemberSuccess];
		}
	}else//日程助手
    {
        
        NSLog(@"-----日程助手");
        
        self.navigationController.navigationBarHidden = NO;
        //((addScheduleViewController*)self.delegete).dataArray=self.nowSelectedEmpArray;
        [((addScheduleViewController*)self.delegete).dataArray addObjectsFromArray:self.nowSelectedEmpArray];
        [((addScheduleViewController*)self.delegete) showMemberScrollow];
        [self.navigationController popViewControllerAnimated:YES];
    }
	return;
}

#pragma mark 从聊天信息界面选择添加成员，添加成功后，刷新聊天信息界面
-(void)addMemberSuccess
{
	talkSession = ((talkSessionViewController*)((chatMessageViewController*)self.delegete).predelegete);
	if(self.oldEmpIdArray.count == 2)
	{
        //		原来是单人聊天
		talkSession.convId = nil;
		talkSession.titleStr=@"多人会话";
//		talkSession.talkType=mutiableType;
		talkSession.talkType = massType;
		((chatMessageViewController*)self.delegete).convId = nil;
	}
    
	
	[self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
	talkSession.convEmps = self.nowSelectedEmpArray;
	talkSession.needUpdateTag = 1;
	[talkSession refresh];
	
	((chatMessageViewController*)self.delegete).dataArray= self.nowSelectedEmpArray;//talkSession.convEmps;
	[((chatMessageViewController*)self.delegete) showMemberScrollow];
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            return 1;
        }else//最近 ＋ 组织框架
        {
            return 2;
        }
        
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
            if (section==1) {//组织架构
                return [self.itemArray count];
            }else
            {
                return [self.typeArray count];
            }
        }
    }else {
        
        if (section==1) {
            return [self.chooseArray count];
        }else
        {
            if (isExpand) {
                return 3+[self.zoneArray count];
            }else
            {
                return 0;
            }
            
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==chooseTable) {
        
        if (indexPath.section==0&&indexPath.row>2) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView==chooseTable) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.zoneArray removeObjectAtIndex:indexPath.row-3];
            // Delete the row from the data source.
            [chooseTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
        else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==chooseTable) {
        
        if (indexPath.section==0&&indexPath.row>2) {
            return UITableViewCellEditingStyleDelete;
        }
        return UITableViewCellEditingStyleNone;
    }
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
            
            if (indexPath.section==1) {//组织架构
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
            else
            {
                id temp=[self.typeArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[RecentGroup class]]) {
                    int indentation=0;
                    indentation=((RecentGroup *)temp).type_level;
                    
                    return indentation;
                }
                else if ([temp isKindOfClass:[Emp class]])
                {
                    int indentation=0;
                    indentation=((Emp *)temp).emp_level;
                    
                    return indentation;
                    
                }
                return 0;
            }
        }
    }else
    {
        if (indexPath.section==1) {
            id temp=[self.chooseArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Emp class]])
            {
                int indentation=0;
                indentation=((Emp *)temp).emp_level;
                
                return indentation;
            }else if([temp isKindOfClass:[Dept class]])
            {
                int indentation=0;
                indentation=((Dept *)temp).dept_level;
                
                return indentation;
            }
            
        }
        return 0;
    }
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
        
    }else
    {
        if(section==0)
        {
            
            return 0;
        }
        else
        {
            if ([self.chooseArray count]==0) {
                return 30;
            }
            return 60;
        }
    }
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            return nil;
        }else
        {
            UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
            titlelabel.backgroundColor=[UIColor lightGrayColor];
            titlelabel.font=[UIFont systemFontOfSize:14];
            if (section==1) {
                titlelabel.text=@" 组织架构";
            }else
            {
                titlelabel.text=@" 最近联系";
            }
            return titlelabel;
        }
    }else
    {
        if (section==0) {
            
            return nil;
        }else
        {
            
            return titleview;
        }
        
    }
}
-(void)expendAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    if (button.tag==1) {
        isExpand=NO;
        button.tag=2;
        
        [button setImage:[StringUtil getImageByResName:@"sereach_down.png"] forState:UIControlStateNormal];
    }else
    {
        isExpand=YES;
        button.tag=1;
        
        [button setImage:[StringUtil getImageByResName:@"sereach_up.png"] forState:UIControlStateNormal];
    }
    [chooseTable reloadData];
}
-(void)titleButtonAction:(id)sender
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==organizationalTable) {
        if (isSearch) {//搜索结果
            return 58;
        }else
        {
            if (indexPath.section==1) {//组织架构
                id temp=[self.itemArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[Dept class]]) {
                    return 45;
                }// Configure the cell.
                else {
                    return 58;
                }
            }
            else
            {
                return 45;
                
            }
        }
    }
    else
    {
        if (indexPath.section==0) {
            
            return 40;
            
        }else
        {
            id temp=[self.chooseArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[RecentMember class]]) {
                return 45;
            }// Configure the cell.
            else {
                if ([temp isKindOfClass:[Dept class]]) {
                    return 42;
                }// Configure the cell.
                else {
                    return 58;
                }
            }
        }
        
    }
    
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        UILabel *onlineLabel=[[UILabel alloc]initWithFrame:CGRectMake(210, 5, 90, 30)];
        onlineLabel.backgroundColor=[UIColor clearColor];
        onlineLabel.tag=1;
        onlineLabel.hidden=YES;
        onlineLabel.textAlignment=UITextAlignmentCenter;
        onlineLabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:onlineLabel];
        [onlineLabel release];
        if (tableView==organizationalTable) {
            UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            selectView.tag=5;
            selectView.backgroundColor=[UIColor clearColor];
            cell.accessoryView=selectView;
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            
        }else
        {
            if (indexPath.section==0) {
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                
                UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 20)];
                titleLabel.tag=2;
                titleLabel.backgroundColor=[UIColor clearColor];
                titleLabel.font=[UIFont systemFontOfSize:14];
                [cell.contentView addSubview:titleLabel];
                [titleLabel release];
                
            }else{
                UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
                selectView.tag=5;
                selectView.backgroundColor=[UIColor clearColor];
                cell.accessoryView=selectView;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            }
            
        }
        
    }
    if (tableView==organizationalTable) {
        
        if (isSearch) {//搜索结果
            UIButton *selectButton=(UIButton *)cell.accessoryView;
            selectButton.tag=indexPath.row;
            [selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.userInteractionEnabled=NO;
            cell.textLabel.font=[UIFont systemFontOfSize:17];
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Emp class]]) {
                
                Emp *emp=(Emp *)temp;
                
                for(Emp *_emp in self.oldEmpIdArray)
                {
                    if(_emp.emp_id == emp.emp_id)
                    {
                        selectButton.hidden = YES;
                        break;
                    }
                }
                if(!selectButton.hidden)
                {
                    if (emp.isSelected) { //选中
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                    }else   //未选择
                    {
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                    }
                }
                
                if(_conn.userStatus == status_online)
                {
                    if (emp.emp_status==status_online) {//在线
                        if (emp.emp_sex==0) {//女
                            cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_40.png"];
                        }else
                        {
                            cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_40.png"];
                        }
                    }else if(emp.emp_status==status_leave)//离开
                    {
                        if (emp.emp_sex==0) {//女
                            cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_leave.png"];
                        }else
                        {
                            cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_leave.png"];
                        }
                    }else//离线，或离开
                    {
                        cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                    }
                }
                else {
                    cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                }
                cell.imageView.userInteractionEnabled=YES;
                //            UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
                //            iconview.tag=indexPath.row;
                //            iconview.userInteractionEnabled=NO;
                //            [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
                //            [cell.imageView addSubview:iconview];
                //            [iconview release];
                
                cell.textLabel.text=emp.emp_name;
                UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                onlineLabel.hidden=YES;
            }
            
        }else
        {
            
            if (indexPath.section==1) {
                
                UIButton *selectButton=(UIButton *)cell.accessoryView;
                selectButton.tag=indexPath.row;
                [selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.textLabel.font=[UIFont systemFontOfSize:17];
                id temp=[self.itemArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[Dept class]]) {
                    selectButton.userInteractionEnabled=YES;
                    Dept *dept = (Dept *)temp;
                    if (dept.isChecked) { //选中
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                    }else   //未选择
                    {
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                        
                    }
                    
                    
                    if (dept.isExtended) {
                        cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic02.png"];
                    }else
                    {
                        cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic01.png"];
                    }
                    cell.textLabel.text=dept.dept_name;//[NSString stringWithFormat:@"%@ [5/9]",dept.dept_name];;
                    
                    UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                    onlineLabel.hidden=NO;
                    onlineLabel.text=[NSString stringWithFormat:@"[%d/%d]",dept.onlineNum,dept.totalNum];
                }else
                {
                    Emp *emp=(Emp *)temp;
                    
                    for(Emp *_emp in self.oldEmpIdArray)
                    {
                        if(_emp.emp_id == emp.emp_id)
                        {
                            selectButton.hidden = YES;
                            break;
                        }
                    }
                    selectButton.userInteractionEnabled=NO;
                    if(!selectButton.hidden)
                    {
                        if (emp.isSelected) { //选中
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                        }else   //未选择
                        {
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                        }
                    }
                    
                    if(_conn.userStatus == status_online)
                    {
                        if (emp.emp_status==status_online) {//在线
                            if (emp.emp_sex==0) {//女
                                cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_40.png"];
                            }else
                            {
                                cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_40.png"];
                            }
                        }else if(emp.emp_status==status_leave)//离开
                        {
                            if (emp.emp_sex==0) {//女
                                cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_leave.png"];
                            }else
                            {
                                cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_leave.png"];
                            }
                        }else//离线，或离开
                        {
                            cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                        }
                    }
                    else {
                        cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                    }
                    cell.imageView.userInteractionEnabled=YES;
                    //        UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
                    //        iconview.tag=indexPath.row;
                    //        iconview.userInteractionEnabled=NO;
                    //        [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
                    //        [cell.imageView addSubview:iconview];
                    //        [iconview release];
                    
                    cell.textLabel.text=emp.emp_name;
                    UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                    onlineLabel.hidden=YES;
                }
                
            }
            else
            {
                UIButton *selectButton=(UIButton *)cell.accessoryView;
                selectButton.tag=indexPath.row;
                [selectButton addTarget:self action:@selector(selectTypeAction:) forControlEvents:UIControlEventTouchUpInside];
                selectButton.userInteractionEnabled=YES;
                cell.textLabel.font=[UIFont systemFontOfSize:17];
                id temp=[self.typeArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[RecentMember class]]) {
                    RecentMember *itemobject=(RecentMember *)temp;
                    
                    if (itemobject.type_id==2) {//最近联系人
                        
                        if (itemobject.isChecked) { //选中
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                        }else   //未选择
                        {
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                            
                        }
                    }
                    
                    if (itemobject.isExtended) {
                        cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic02.png"];
                    }else
                    {
                        cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic01.png"];
                    }
                    
                    cell.textLabel.text=itemobject.type_name;
                    
                }else if([temp isKindOfClass:[Emp class]])
                {
                    Emp *emp=(Emp *)temp;
                    
                    for(Emp *_emp in self.oldEmpIdArray)
                    {
                        if(_emp.emp_id == emp.emp_id)
                        {
                            selectButton.hidden = YES;
                            break;
                        }
                    }
                    if(!selectButton.hidden)
                    {
                        if (emp.isSelected) { //选中
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                        }else   //未选择
                        {
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                        }
                    }
                    selectButton.userInteractionEnabled=NO;
                    if(_conn.userStatus == status_online)
                    {
                        if (emp.emp_status==status_online) {//在线
                            if (emp.emp_sex==0) {//女
                                cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_40.png"];
                            }else
                            {
                                cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_40.png"];
                            }
                        }else if(emp.emp_status==status_leave)//离开
                        {
                            if (emp.emp_sex==0) {//女
                                cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_leave.png"];
                            }else
                            {
                                cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_leave.png"];
                            }
                        }else//离线，或离开
                        {
                            cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                        }
                    }
                    else {
                        cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                    }
                    cell.imageView.userInteractionEnabled=YES;
                    //            UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
                    //            iconview.tag=indexPath.row;
                    //            iconview.userInteractionEnabled=NO;
                    //            [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
                    //            [cell.imageView addSubview:iconview];
                    //            [iconview release];
                    
                    cell.textLabel.text=emp.emp_name;
                    UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                    onlineLabel.hidden=YES;
                }else if([temp isKindOfClass:[RecentGroup class]])
                {
                    cell.imageView.image=[StringUtil getImageByResName:@"Group_ios_40.png"];
                    RecentGroup *itemobject=(RecentGroup *)temp;
                    if (itemobject.isChecked) { //选中
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                    }else   //未选择
                    {
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                        
                    }
                    cell.textLabel.text=itemobject.type_name;
                }
                
                
                
            }
        }
    }else
    {
        
        if (indexPath.section==0) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray ;
            UILabel *titlelabel=(UILabel *)[cell.contentView viewWithTag:2];
            //  UILabel *detaillabel=(UILabel *)[cell.contentView viewWithTag:3];
            if (indexPath.row==0) {
                // titlelabel.text=@"级别";
                [cell.contentView addSubview:self.rankLabel];
                
            }else if(indexPath.row==1)
            {
                //  titlelabel.text=@"业务";
                
                [cell.contentView addSubview:self.bussinesslLabel];
            }else if(indexPath.row==2)
            {
                titlelabel.text=@"地域";
                // detaillabel.text=@"全部地域";
                
            }else
            {
                id temp=[self.zoneArray objectAtIndex:indexPath.row-3];
                citiesObject *city=(citiesObject *)temp;
                titlelabel.text=city.some_cities;
                cell.accessoryType=UITableViewCellAccessoryNone;
                
            }
            
        }else
        {
            UIButton *selectButton=(UIButton *)cell.accessoryView;
            selectButton.tag=indexPath.row;
            
            cell.textLabel.font=[UIFont systemFontOfSize:17];
            id temp=[self.chooseArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                Dept *dept = (Dept *)temp;
                
                if (dept.isExtended) {
                    cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic02.png"];
                }else
                {
                    cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic01.png"];
                }
                if(!selectButton.hidden)
                {
                    if (dept.isChecked) { //选中
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                    }else   //未选择
                    {
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                    }
                }
                [selectButton addTarget:self action:@selector(selectChooseAction:) forControlEvents:UIControlEventTouchUpInside];
                selectButton.userInteractionEnabled=YES;
                cell.textLabel.text=dept.dept_name;//[NSString stringWithFormat:@"%@ [5/9]",dept.dept_name];;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                onlineLabel.hidden=NO;
                onlineLabel.text=[NSString stringWithFormat:@"%d",dept.totalNum];
            }
            else if([temp isKindOfClass:[Emp class]])
            {
                Emp *emp=(Emp *)temp;
                
                for(Emp *_emp in self.oldEmpIdArray)
                {
                    if(_emp.emp_id == emp.emp_id)
                    {
                        selectButton.hidden = YES;
                        break;
                    }
                }
                if(!selectButton.hidden)
                {
                    if (emp.isSelected) { //选中
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                    }else   //未选择
                    {
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                        [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                    }
                }
                selectButton.userInteractionEnabled=NO;
                if(_conn.userStatus == status_online)
                {
                    if (emp.emp_status==status_online) {//在线
                        if (emp.emp_sex==0) {//女
                            cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_40.png"];
                        }else
                        {
                            cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_40.png"];
                        }
                    }else if(emp.emp_status==status_leave)//离开
                    {
                        if (emp.emp_sex==0) {//女
                            cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_leave.png"];
                        }else
                        {
                            cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_leave.png"];
                        }
                    }else//离线，或离开
                    {
                        cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                    }
                }
                else {
                    cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                }
                cell.imageView.userInteractionEnabled=YES;
                UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
                iconview.tag=indexPath.row;
                iconview.userInteractionEnabled=NO;
                [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.imageView addSubview:iconview];
                [iconview release];
                
                cell.textLabel.text=emp.emp_name;
                UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                onlineLabel.hidden=YES;
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
            
            int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
            
            //	找到复选框所在的行
            int row =indexPath.row;
            UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            UIButton *button=(UIButton *)[cell viewWithTag:5];
            //	取出对应行的对象是一个部门还是一个员工
            id temp=[self.itemArray objectAtIndex:row];
            //       选中的是员工
            Emp *emp=(Emp *)temp;
            BOOL isOldMember=FALSE;
            for(Emp *_emp in self.oldEmpIdArray)
            {
                if(_emp.emp_id == emp.emp_id)
                {
                    isOldMember = true;
                    NSLog(@"%@是已有成员",emp.emp_name);
                    break;
                }
            }
            if (isOldMember) {
                return;
            }
            
            if (emp.isSelected) { //不选中
                emp.isSelected=false;
                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            }else   //选中
            {
//                if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
//                    [self showGroupNumExceedAlert];
//                    return;
//                }
                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                emp.isSelected=true;
            }
            [self selectByEmployee:emp.emp_id status:emp.isSelected];
            [organizationalTable reloadData];
            
            if (all_result_sum<=0) {
                select_emp_sum=0;
                all_result_sum=0;
                addButton.enabled=NO;
                [addButton setTitle:@"确定" forState:UIControlStateNormal];
                addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
            }else
            {
                addButton.enabled=YES;
                NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",all_result_sum];
                [addButton setTitle:titlestr forState:UIControlStateNormal];
                addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
                if (all_result_sum>80) {
                    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
                }
            }
            //    显示在底部
        //    [self bottomScrollviewShow];
            
            
            return;
        }
        
        //最近联系
        if (indexPath.section==0) {
            
            
            id temp=[self.typeArray objectAtIndex:indexPath.row];
            if([temp isKindOfClass:[RecentMember class]])
            {
                RecentMember *recent=(RecentMember *)temp;
                if (recent.type_id==2) {//最近联系人
                    
                    int level=recent.type_level+1;
                    if (recent.isExtended) { //收起展示
                        recent.isExtended=false;
                        int remvoecount=0;
                        for (int i=indexPath.row+1; i<[self.typeArray count]; i++) {
                            
                            
                            id temp1 = [self.typeArray objectAtIndex:i];
                            
                            if([temp1 isKindOfClass:[Emp class]])
                            {
                                if (((Emp *)temp1).emp_level<=recent.type_level) {
                                    break;
                                }
                            }
                            
                            if([temp1 isKindOfClass:[RecentMember class]])
                            {
                                if (((RecentMember *)temp1).type_level<=recent.type_level) {
                                    break;
                                }
                                
                            }
                            remvoecount++;
                        }
                        if (remvoecount!=0) {
                            NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                            [self.typeArray removeObjectsInRange:range];
                        }
                        [tableView reloadData];
                    }else
                    {
                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                        recent.isExtended=true;
                        NSArray *tempEpArray=[_ecloud getRecentEmpInfoWithSelected:[NSString stringWithFormat:@"%d",recent.type_id]  andLevel:level andSelected:recent.isChecked];
                        Emp *emp1;
                        Emp *emp2;
                        for (int i=0; i<[tempEpArray count]; i++) {
                            
                            emp1=[tempEpArray objectAtIndex:i];
                            
                            for (int j=0; j<[self.employeeArray count];j++) {
                                
                                emp2=[self.employeeArray objectAtIndex:j];
                                if (emp1.emp_id==emp2.emp_id) {
                                    emp1.isSelected=emp2.isSelected;
                                    break;
                                }
                            }
                        }
                        
                        NSMutableArray *allArray=[[NSMutableArray alloc]init];
                        [allArray addObjectsFromArray:tempEpArray];
                        [pool release];
                        
                        NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                        [self.typeArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                        
                        [allArray release];
                        [pool release];
                        [tableView reloadData];
                    }
                }else //最新讨论组
                {
                    int level=recent.type_level+1;
                    if (recent.isExtended) { //收起展示
                        recent.isExtended=false;
                        int remvoecount=0;
                        for (int i=indexPath.row+1; i<[self.typeArray count]; i++) {
                            
                            
                            id temp1 = [self.typeArray objectAtIndex:i];
                            
                            if([temp1 isKindOfClass:[RecentGroup class]])
                            {
                                if (((RecentGroup *)temp1).type_level<=recent.type_level) {
                                    break;
                                }
                            }
                            
                            if([temp1 isKindOfClass:[RecentMember class]])
                            {
                                if (((RecentMember *)temp1).type_level<=recent.type_level) {
                                    break;
                                }
                                
                            }
                            remvoecount++;
                        }
                        if (remvoecount!=0) {
                            NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                            [self.typeArray removeObjectsInRange:range];
                        }
                        [tableView reloadData];
                    }else
                    {
                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                        recent.isExtended=true;
                        NSArray *tempGroupArray=[_ecloud getGroupArray];
                        
                        
                        NSMutableArray *allArray=[[NSMutableArray alloc]init];
                        [allArray addObjectsFromArray:tempGroupArray];
                        [pool release];
                        
                        NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                        [self.typeArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                        
                        [allArray release];
                        [pool release];
                        [tableView reloadData];
                    }
                    
                }
            }
            else if ([temp isKindOfClass:[Emp class]])
            {
                int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
                
                //	找到复选框所在的行
                int row =indexPath.row;
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                UIButton *button=(UIButton *)[cell viewWithTag:5];
                //	取出对应行的对象是一个部门还是一个员工
                id temp=[self.typeArray objectAtIndex:row];
                //       选中的是员工
                Emp *emp=(Emp *)temp;
                BOOL isOldMember=FALSE;
                for(Emp *_emp in self.oldEmpIdArray)
                {
                    if(_emp.emp_id == emp.emp_id)
                    {
                        isOldMember = true;
                        NSLog(@"%@是已有成员",emp.emp_name);
                        break;
                    }
                }
                if (isOldMember) {
                    return;
                }
                
                if (emp.isSelected) { //不选中
                    emp.isSelected=false;
                    [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                }else   //选中
                {
//                    if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
//                        [self showGroupNumExceedAlert];
//                        return;
//                    }
                    [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                    emp.isSelected=true;
                }
                [self selectByEmployee:emp.emp_id status:emp.isSelected];
                [organizationalTable reloadData];
                
                if (all_result_sum<=0) {
                    select_emp_sum=0;
                    all_result_sum=0;
                    addButton.enabled=NO;
                    [addButton setTitle:@"确定" forState:UIControlStateNormal];
                    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
                }else
                {
                    addButton.enabled=YES;
                    NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",all_result_sum];
                    [addButton setTitle:titlestr forState:UIControlStateNormal];
                    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
                    if (all_result_sum>80) {
                        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
                    }
                }
                
                //    显示在底部
               // [self bottomScrollviewShow];
            }else if ([temp isKindOfClass:[RecentGroup class]])
            {
                RecentGroup *recent=(RecentGroup *)temp;
                int level=recent.type_level+1;
                if (recent.isExtended) { //收起展示
                    recent.isExtended=false;
                    int remvoecount=0;
                    for (int i=indexPath.row+1; i<[self.typeArray count]; i++) {
                        
                        
                        id temp1 = [self.typeArray objectAtIndex:i];
                        
                        if([temp1 isKindOfClass:[Emp class]])
                        {
                            if (((Emp *)temp1).emp_level<=recent.type_level) {
                                break;
                            }
                        }
                        
                        if([temp1 isKindOfClass:[RecentMember class]])
                        {
                            if (((RecentMember *)temp1).type_level<=recent.type_level) {
                                break;
                            }
                            
                        }
                        if([temp1 isKindOfClass:[RecentGroup class]])
                        {
                            if (((RecentGroup *)temp1).type_level<=recent.type_level) {
                                break;
                            }
                            
                        }
                        remvoecount++;
                    }
                    if (remvoecount!=0) {
                        NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                        [self.typeArray removeObjectsInRange:range];
                    }
                    [tableView reloadData];
                }else
                {
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                    recent.isExtended=true;
                    NSArray *tempEpArray=[_ecloud getRecentGroupMemberWithSelected:[NSString stringWithFormat:@"%d",recent.type_id] andLevel:level andSelected:recent.isChecked andConvId:recent.conv_id];
                    Emp *emp1;
                    Emp *emp2;
                    for (int i=0; i<[tempEpArray count]; i++) {
                        
                        emp1=[tempEpArray objectAtIndex:i];
                        
                        for (int j=0; j<[self.employeeArray count];j++) {
                            
                            emp2=[self.employeeArray objectAtIndex:j];
                            if (emp1.emp_id==emp2.emp_id) {
                                emp1.isSelected=emp2.isSelected;
                                break;
                            }
                        }
                    }
                    
                    NSMutableArray *allArray=[[NSMutableArray alloc]init];
                    [allArray addObjectsFromArray:tempEpArray];
                    [pool release];
                    
                    NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                    [self.typeArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                    
                    [allArray release];
                    [pool release];
                    [tableView reloadData];
                }
                
                
                
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
                
                NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked];
                NSArray *tempEpArray=[_ecloud getDeptEmpInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked];
                
                Dept *dept1;
                Dept *dept2;
                for (int i=0; i<[tempDeptArray count]; i++) {
                    
                    dept1=[tempDeptArray objectAtIndex:i];
                    
                    for (int j=0; j<[self.deptArray count];j++) {
                        
                        dept2=[self.deptArray objectAtIndex:j];
                        if (dept1.dept_id==dept2.dept_id) {
                            dept1.isChecked=dept2.isChecked;
                            break;
                        }
                        
                    }
                }
                
//                Emp *emp1;
//                Emp *emp2;
//                for (int i=0; i<[tempEpArray count]; i++) {
//                    
//                    emp1=[tempEpArray objectAtIndex:i];
//                    
//                    for (int j=0; j<[self.employeeArray count];j++) {
//                        
//                        emp2=[self.employeeArray objectAtIndex:j];
//                        if (emp1.emp_id==emp2.emp_id) {
//                            emp1.isSelected=emp2.isSelected;
//                            break;
//                        }
//                    }
//                }
                
                
                NSMutableArray *allArray=[[NSMutableArray alloc]init];
                [allArray addObjectsFromArray:tempEpArray];
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
                
//                if (isExtendedPoint<noworigin) {
//                    float offsetvalue=noworigin-sumnum;
//                    if (offsetvalue<0) {
//                        offsetvalue=noworigin;
//                    }
//                    tableView.contentOffset=CGPointMake(0,offsetvalue);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
//                }else{
//                    tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
//                }
                /*自动收起*///---------------------------------------------------------------end------------//
                
            }
            
            [tableView reloadData] ;
        }
//        else
//        {
//            int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
//            
//            //	找到复选框所在的行
//            int row =indexPath.row;
//            UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
//            UIButton *button=(UIButton *)[cell viewWithTag:5];
//            //	取出对应行的对象是一个部门还是一个员工
//            id temp=[self.itemArray objectAtIndex:row];
//            //       选中的是员工
//            Emp *emp=(Emp *)temp;
//            BOOL isOldMember=FALSE;
//            for(Emp *_emp in self.oldEmpIdArray)
//            {
//                if(_emp.emp_id == emp.emp_id)
//                {
//                    isOldMember = true;
//                    NSLog(@"%@是已有成员",emp.emp_name);
//                    break;
//                }
//            }
//            if (isOldMember) {
//                return;
//            }
//            
//            if (emp.isSelected) { //不选中
//                emp.isSelected=false;
//                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
//                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
//                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
//            }else   //选中
//            {
////                if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
////                    [self showGroupNumExceedAlert];
////                    return;
////                }
//                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
//                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
//                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
//                emp.isSelected=true;
//            }
//            [self selectByEmployee:emp.emp_id status:emp.isSelected];
//            [organizationalTable reloadData];
//            
//            
//            //    显示在底部
//          //  [self bottomScrollviewShow];
//        }
        
    }else if (tableView==chooseTable)
    {
        
        if (indexPath.section==0) {
            isNeedSearchAgain=YES;
            if (indexPath.row==0) {
                if (rankChoose==nil) {
                    rankChoose=[[rankChooseViewController alloc]init];
                    rankChoose.delegete=self;
                }
                [self.navigationController pushViewController:rankChoose animated:YES];
                
            }else if(indexPath.row==1) {
                
                if (businessChoose==nil) {
                    businessChoose=[[businessChooseViewController alloc]init];
                    businessChoose.delegete=self;
                }
                [self.navigationController pushViewController:businessChoose animated:YES];
            }else if(indexPath.row==2) {
                
                if (zoneChoose==nil) {
                    zoneChoose=[[zoneChooseViewController alloc]init];
                    zoneChoose.delegete=self;
                }
                [self.navigationController pushViewController:zoneChoose animated:YES];
            }
            
        }else
        {
            id temp=[self.chooseArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Emp class]])
            {
                int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
                
                //	找到复选框所在的行
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                UIButton *button=(UIButton *)[cell viewWithTag:5];
                //	取出对应行的对象是一个部门还是一个员工
                
                //       选中的是员工
                Emp *emp=(Emp *)temp;
                BOOL isOldMember=FALSE;
                for(Emp *_emp in self.oldEmpIdArray)
                {
                    if(_emp.emp_id == emp.emp_id)
                    {
                        isOldMember = true;
                        NSLog(@"%@是已有成员",emp.emp_name);
                        break;
                    }
                }
                if (isOldMember) {
                    return;
                }
                
                if (emp.isSelected) { //不选中
                    emp.isSelected=false;
                    [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
                }else   //选中
                {
//                    if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
//                        [self showGroupNumExceedAlert];
//                        return;
//                    }
                    [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                    [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                    emp.isSelected=true;
                }
                [self selectByEmployee:emp.emp_id status:emp.isSelected];
                [chooseTable reloadData];
                if (all_result_sum<=0) {
                    select_emp_sum=0;
                    all_result_sum=0;
                    addButton.enabled=NO;
                    [addButton setTitle:@"确定" forState:UIControlStateNormal];
                    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
                }else
                {
                    addButton.enabled=YES;
                    NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",all_result_sum];
                    [addButton setTitle:titlestr forState:UIControlStateNormal];
                    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
                    if (all_result_sum>80) {
                        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
                    }
                }
                //    显示在底部
            //    [self bottomScrollviewShow];
            }else if ([temp isKindOfClass:[Dept class]])
            {
                Dept *dept = (Dept *)temp;
                int level=dept.dept_level+1;
                if (dept.isExtended) { //收起展示
                    dept.isExtended=false;
                    int remvoecount=0;
                    for (int i=indexPath.row+1; i<[self.chooseArray count]; i++) {
                        
                        
                        id temp1 = [self.chooseArray objectAtIndex:i];
                        
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
                        [self.chooseArray removeObjectsInRange:range];
                    }
                    
                    
                }else   //显示子部门及人员
                {
                    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                    float noworigin=cell.frame.origin.y;
                    
                    NSMutableArray *allArray=[[NSMutableArray alloc]init];
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                    NSArray *tempDeptArray=[advanceQueryDAO getTempDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked];
                    if ([dept.subDeptsStr isEqualToString:@"0"]) {
                        NSArray *tempEpArray=[advanceQueryDAO getTempDeptEmpInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked andRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
                        [allArray addObjectsFromArray:tempEpArray];
                    }
                    
                    [allArray addObjectsFromArray:tempDeptArray];
                    [pool release];
                    NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                    [self.chooseArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                    [allArray release];
                    
                    dept.isExtended=true;
                    
                    /*自动收起---------------------------------------------------------------bigen------------*/
                    float isExtendedPoint=0;
                    float sumnum=0;
                    for (int i=0; i<[self.chooseArray count]; i++) {
                        id temp1 = [self.chooseArray objectAtIndex:i];
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
                                for (int nowindex=i+1; nowindex<[self.chooseArray count]; nowindex++) {
                                    
                                    
                                    id temp1 = [self.chooseArray objectAtIndex:nowindex];
                                    
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
                                    [self.chooseArray removeObjectsInRange:range];
                                }
                                sumnum=deptlen+emplen;
                                break;
                            }
                            
                        }
                    }
                    
                    [tableView reloadData];
                    
                    //			[LogUtil debug:[NSString stringWithFormat:@" noworigin is %.0f isExtendedPoint is %.0f ,sumnum is %.0f",noworigin,isExtendedPoint,sumnum]];
                    
//                    if (isExtendedPoint<noworigin) {
//                        float offsetvalue=noworigin-sumnum;
//                        if (offsetvalue<0) {
//                            offsetvalue=noworigin;
//                        }
//                        tableView.contentOffset=CGPointMake(0,offsetvalue);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
//                    }else{
//                        tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
//                    }
                    
                    
                    
                    //			[LogUtil debug:[NSString stringWithFormat:@"tableView.contentOffset %.0f", tableView.contentOffset.y]];
                    
                    
                    /*自动收起*///---------------------------------------------------------------end------------//
                    //            NSLog(@"---cell.offset-- %0.0f",tableView.contentOffset.y);
                }
                
                [tableView reloadData] ;
            }
            
        }
        
        
    }
}
//筛选结果
-(void)selectChooseAction:(id)sender
{
    int nowcount= [self.nowSelectedEmpArray count];
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    //	取出对应行的对象是一个部门还是一个员工
    id temp=[self.chooseArray objectAtIndex:row];
    //	如果是部门
    if([temp isKindOfClass:[Dept class]])
    {
        NSLog(@"----maxGroupNum--%d",maxGroupNum);
        //			判断选中的人员数量
        Dept *dept = (Dept *)temp;
        if (dept.isChecked) { //不选中
            dept.isChecked=false;
            [button setImage:[StringUtil getImageByResName:@"unselected.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"unselected.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"unselected.png"] forState:UIControlStateSelected];
        }else   //选中
        {
            //            if ( nowcount+dept.totalNum>(maxGroupNum - self.oldEmpIdArray.count)) {
            //				[self showGroupNumExceedAlert];
            //                return;
            //            }
            [button setImage:[StringUtil getImageByResName:@"selected.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"selected.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"selected.png"] forState:UIControlStateSelected];
            dept.isChecked=true;
        }
        //		设置部门，部门的子部门，部门员工，子部门员工的选中状态
        //  [self selectByDept:dept.dept_id status:dept.isChecked];
        NSString *deptid=[NSString stringWithFormat:@"%d",dept.dept_id];
        NSArray *emp_array=[advanceQueryDAO getTempDeptEmpByParent:deptid andSelected:dept.isChecked andRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
        for (int i=0; i<[emp_array count]; i++) {
            Emp *emp=[emp_array objectAtIndex:i];
            // [self updateNowSelectedEmp:emp];
            [self selectByEmployee:emp.emp_id status:emp.isSelected];
        }
      //  [self bottomScrollviewShow];
        //		把选中状态呈现在界面上
        for (int i=row+1; i<[self.chooseArray count]; i++) {
            id temp1 = [self.chooseArray objectAtIndex:i];
            if([temp1 isKindOfClass:[Emp class]])
            {
                if (((Emp *)temp1).emp_level<=dept.dept_level) {
                    break;
                }
                ((Emp *)temp1).isSelected=dept.isChecked;
            }
            
            if([temp1 isKindOfClass:[Dept class]])
            {
                if (((Dept *)temp1).dept_level<=dept.dept_level) {
                    break;
                }
                ((Dept *)temp1).isChecked=dept.isChecked;
            }
        }
        
        [chooseTable reloadData];
        
        if (all_result_sum<=0) {
            select_emp_sum=0;
            all_result_sum=0;
            addButton.enabled=NO;
            [addButton setTitle:@"确定" forState:UIControlStateNormal];
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        }else
        {
            addButton.enabled=YES;
            NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",all_result_sum];
            [addButton setTitle:titlestr forState:UIControlStateNormal];
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
            if (all_result_sum>80) {
                addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
            }
        }

    }
}


-(void)iconAction:(id)sender
{
}

-(void)selectTypeAction:(id)sender
{
    int nowcount= [self.nowSelectedEmpArray count];
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    //	取出对应行的对象是一个部门还是一个员工
    id temp=[self.typeArray objectAtIndex:row];
    if([temp isKindOfClass:[RecentMember class]])
    {
        RecentMember *recent=(RecentMember *)temp;
        if (recent.isChecked) { //不选中
            recent.isChecked=false;
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
        }else   //选中
        {
            //            if ( nowcount+dept.totalNum>(maxGroupNum - self.oldEmpIdArray.count)) {
            //				[self showGroupNumExceedAlert];
            //                return;
            //            }
            
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            recent.isChecked=true;
        }
        [self selectByType:recent.type_id status:recent.isChecked];
        //		把选中状态呈现在界面上
        for (int i=row+1; i<[self.typeArray count]; i++) {
            id temp1 = [self.typeArray objectAtIndex:i];
            if([temp1 isKindOfClass:[Emp class]])
            {
                if (((Emp *)temp1).emp_level<=recent.type_level) {
                    break;
                }
                ((Emp *)temp1).isSelected=recent.isChecked;
            }
        }
        [organizationalTable reloadData];
        //    显示在底部
     //   [self bottomScrollviewShow];
    }else if ([temp isKindOfClass:[RecentGroup class]])
    {
        RecentGroup *recent=(RecentGroup *)temp;
        if (recent.isChecked) { //不选中
            recent.isChecked=false;
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
        }else   //选中
        {
            //            if ( nowcount+dept.totalNum>(maxGroupNum - self.oldEmpIdArray.count)) {
            //				[self showGroupNumExceedAlert];
            //                return;
            //            }
            
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            recent.isChecked=true;
        }
        [self selectByGroupType:recent.type_id status:recent.isChecked andConvId:recent.conv_id];
        //		把选中状态呈现在界面上
        for (int i=row+1; i<[self.typeArray count]; i++) {
            id temp1 = [self.typeArray objectAtIndex:i];
            if([temp1 isKindOfClass:[Emp class]])
            {
                if (((Emp *)temp1).emp_level<=recent.type_level) {
                    break;
                }
                ((Emp *)temp1).isSelected=recent.isChecked;
            }
        }
        [organizationalTable reloadData];
        //    显示在底部
   //     [self bottomScrollviewShow];
        
        
    }
    if (all_result_sum<=0) {
        select_emp_sum=0;
        all_result_sum=0;
        addButton.enabled=NO;
        [addButton setTitle:@"确定" forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
    }else
    {
        addButton.enabled=YES;
        NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",all_result_sum];
        [addButton setTitle:titlestr forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        if (all_result_sum>80) {
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
        }
    }

}
-(void)selectAction:(id)sender
{
    [searchTextView resignFirstResponder];
	int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
    
    //	找到复选框所在的行
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    
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
//            if ( nowcount+dept.totalNum>(maxGroupNum - self.oldEmpIdArray.count)) {
//				[self showGroupNumExceedAlert];
//                return;
//            }
            
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            dept.isChecked=true;
        }
 
        //		设置部门，部门的子部门，部门员工，子部门员工的选中状态
        [self selectByDept:dept.dept_id status:dept.isChecked];
        
        if (all_result_sum<=0) {
            select_emp_sum=0;
            all_result_sum=0;
            addButton.enabled=NO;
            [addButton setTitle:@"确定" forState:UIControlStateNormal];
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        }else
        {
            addButton.enabled=YES;
            NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",all_result_sum];
            [addButton setTitle:titlestr forState:UIControlStateNormal];
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
            if (all_result_sum>80) {
                addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
            }
        }
        NSString *deptId;
        if (!dept.isChecked) {
        NSString *dept_id_str=[NSString stringWithFormat:@"%d",dept.dept_id];
        NSArray *ParentArray=[_ecloud getParentDepts:dept_id_str];
        for (int j=0; j<[ParentArray count]; j++) {
            deptId=[ParentArray objectAtIndex:j];
             for (int i=0; i<row; i++) {
                id temp1 = [self.itemArray objectAtIndex:i];
                if (((Dept *)temp1).dept_id==[deptId intValue]) {
                    ((Dept *)temp1).isChecked=dept.isChecked;
                    break;
                }
            }
                   
           }
        }
        
        //		把选中状态呈现在界面上
        for (int i=row+1; i<[self.itemArray count]; i++) {
            id temp1 = [self.itemArray objectAtIndex:i];
            if([temp1 isKindOfClass:[Emp class]])
            {
                if (((Emp *)temp1).emp_level<=dept.dept_level) {
                    break;
                }
                ((Emp *)temp1).isSelected=dept.isChecked;
            }
            
            if([temp1 isKindOfClass:[Dept class]])
            {
                if (((Dept *)temp1).dept_level<=dept.dept_level) {
                    break;
                }
                ((Dept *)temp1).isChecked=dept.isChecked;
            }
        }
        
        [organizationalTable reloadData];
        
    }else
    {
        //       选中的是员工
        Emp *emp=(Emp *)temp;
        
        if (emp.isSelected) { //不选中
            emp.isSelected=false;
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
            
        }else   //选中
        {
//            if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
//                [self showGroupNumExceedAlert];
//                return;
//            }
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            
            emp.isSelected=true;
        }
        [self selectByEmployee:emp.emp_id status:emp.isSelected];
        [organizationalTable reloadData];
        
    }
    //    显示在底部
  //  [self bottomScrollviewShow];
}
//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus
{
    //	部门id
    NSString *dept_id_str=[NSString stringWithFormat:@"%d",dept_id];
    //	部门的子部门
    NSArray *tempArray=[_ecloud getChildDepts:dept_id_str];
     NSArray *ParentArray=[_ecloud getParentDepts:dept_id_str];
    Emp *emp;
    NSString *deptId;
    
    //    设置子部门下的员工的选中状态
//    for (int i=0; i<[self.employeeArray count]; i++) {
//        
//        emp=[self.employeeArray objectAtIndex:i];
//        for (int j=0;j<[tempArray count]; j++) {
//            
//            deptId=[tempArray objectAtIndex:j];
//            if (emp.emp_dept==[deptId intValue])
//			{
//				bool isOldMember = false;
//				for(Emp *_emp in self.oldEmpIdArray)
//				{
//					if(_emp.emp_id == emp.emp_id)
//					{
//						isOldMember = true;
//						NSLog(@"%@是已有成员",emp.emp_name);
//						break;
//					}
//				}
//				if(isOldMember)
//					continue;
//				
//                emp.isSelected=selectedStatus;
//				[self updateNowSelectedEmp:emp];
//				break;
//            }
//        }
//    }
//	[self displayNowSelectedEmp];
    Dept *dept;
    //    设置子部门的选中状态
    select_emp_sum=0;
    all_result_sum=0;
   
    for (int i=0; i<[self.deptArray count]; i++) {
        dept=[self.deptArray objectAtIndex:i];

        for (int j=0;j<[tempArray count]; j++) {
            
            deptId=[tempArray objectAtIndex:j];
            if (dept.dept_id==[deptId intValue]) {
                dept.isChecked=selectedStatus;
				break;
            }
        }

        for (int j=0;j<[ParentArray count]; j++) {
            
            deptId=[ParentArray objectAtIndex:j];
            if (!selectedStatus&&dept.dept_id==[deptId intValue]) {
                dept.isChecked=selectedStatus;
				break;
            }
        }
        
        
        if ([tempArray count]>1) {
            if (dept_id==dept.dept_id) {
                dept.isChecked=false;
//                NSArray *tempEpArray=[_ecloud getDeptEmpInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked];
            }
            if (dept.isChecked) {
                select_emp_sum=select_emp_sum+dept.totalNum;
            }

        }else
        {
            if (dept.isChecked) {
                select_emp_sum=select_emp_sum+dept.totalNum;
            }
        }
        
        
    }

    BOOL isInDept=NO;
    int emp_num=0;
    for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
        emp=[self.nowSelectedEmpArray objectAtIndex:i];
        isInDept=NO;
        for (int j=0; j<[self.deptArray count]; j++) {
            dept=[self.deptArray objectAtIndex:j];
            if (emp.emp_dept==dept.dept_id&&dept.isChecked) {
                isInDept=YES;
                break;
            }
        }
        if (!isInDept) {
            emp_num++;
        }
    }
    all_result_sum=select_emp_sum+emp_num;
}
//最近联系 选中或未选中
-(void)selectByType:(int)type_id status:(bool)selectedStatus
{
    
    NSArray *tempEpArray=[_ecloud getRecentEmpInfoWithSelected:[NSString stringWithFormat:@"%d",type_id]  andLevel:1 andSelected:selectedStatus];
    
    Emp *emp;
    NSString *deptId;
    
    for (int j=0;j<[tempEpArray count]; j++) {
        
        Emp *temp=[tempEpArray objectAtIndex:j];
        
        for (int i=0; i<[self.employeeArray count]; i++) {
            emp=[self.employeeArray objectAtIndex:i];
            if (emp.emp_id==temp.emp_id) {
                emp.isSelected=selectedStatus;
                [self updateNowSelectedEmp:emp];
                break;
            }
        }
    }
	[self displayNowSelectedEmp];
    BOOL isInDept=NO;
    Dept *dept;
    int emp_num=0;
    
    for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
        emp=[self.nowSelectedEmpArray objectAtIndex:i];
        isInDept=NO;
        for (int j=0; j<[self.deptArray count]; j++) {
            dept=[self.deptArray objectAtIndex:j];
            if (emp.emp_dept==dept.dept_id&&dept.isChecked) {
                isInDept=YES;
                break;
            }
        }
        if (!isInDept) {
            emp_num++;
        }
    }
    all_result_sum=select_emp_sum+emp_num;
    
}
//最近讨论组 选中或未选中
-(void)selectByGroupType:(int)type_id status:(bool)selectedStatus andConvId:(NSString *)conv_id
{
    
    NSArray *tempEpArray=[_ecloud getRecentGroupMemberWithSelected:[NSString stringWithFormat:@"%d",type_id] andLevel:2 andSelected:selectedStatus andConvId:conv_id];
    
    Emp *emp;
    NSString *deptId;
    
    for (int j=0;j<[tempEpArray count]; j++) {
        
        Emp *temp=[tempEpArray objectAtIndex:j];
        
        for (int i=0; i<[self.employeeArray count]; i++) {
            emp=[self.employeeArray objectAtIndex:i];
            if (emp.emp_id==temp.emp_id) {
                emp.isSelected=selectedStatus;
                [self updateNowSelectedEmp:emp];
                break;
            }
        }
    }
	[self displayNowSelectedEmp];
    BOOL isInDept=NO;
    int emp_num=0;
    Dept *dept;
    for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
        emp=[self.nowSelectedEmpArray objectAtIndex:i];
        isInDept=NO;
        for (int j=0; j<[self.deptArray count]; j++) {
            dept=[self.deptArray objectAtIndex:j];
            if (emp.emp_dept==dept.dept_id&&dept.isChecked) {
                isInDept=YES;
                break;
            }
        }
        if (!isInDept) {
            emp_num++;
        }
    }
    all_result_sum=select_emp_sum+emp_num;
}
#pragma mark 选中或反选一个emp时，修改现在选中的emp的数组
-(void)updateNowSelectedEmp:(Emp *)emp
{
	if(emp.isSelected)
	{
		bool isNowSelected = false;
		for(Emp *_emp in self.nowSelectedEmpArray)
		{
			if(_emp.emp_id == emp.emp_id)
			{
				isNowSelected = true;
				NSLog(@"%@已经选中",_emp.emp_name);
				break;
			}
		}
		if(!isNowSelected)
		{
			[self.nowSelectedEmpArray addObject:emp];
		}
	}
	else
	{
		//[self.nowSelectedEmpArray removeObject:emp];
        for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
            Emp *deleteEmp=[self.nowSelectedEmpArray objectAtIndex:i];
            if (deleteEmp.emp_id==emp.emp_id) {
                [self.nowSelectedEmpArray removeObject:deleteEmp];
            }
        }
	}
}
-(void)displayNowSelectedEmp
{
	NSLog(@"选中个数：%d",self.nowSelectedEmpArray.count);
	for(Emp * _emp in self.nowSelectedEmpArray)
	{
		NSLog(@"%@",_emp.emp_name);
	}
}

-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus
{
    Emp *emp;
    Dept *dept;
    for (int i=0; i<[self.employeeArray count]; i++) {
        emp=[self.employeeArray objectAtIndex:i];
        if (emp.emp_id==emp_id) {
            emp.isSelected=selectedStatus;
			[self updateNowSelectedEmp:emp];
			break;
        }
    }
    BOOL isInDept=NO;
    int emp_num=0;
    for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
         emp=[self.nowSelectedEmpArray objectAtIndex:i];
         isInDept=NO;
        for (int j=0; j<[self.deptArray count]; j++) {
            dept=[self.deptArray objectAtIndex:j];
            if (emp.emp_dept==dept.dept_id&&dept.isChecked) {
                isInDept=YES;
                break;
            }
        }
        if (!isInDept) {
            emp_num++;
        }
    }
     all_result_sum=select_emp_sum+emp_num;
	[self displayNowSelectedEmp];
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //NSLog(@"-----scrollViewDidScroll");
    //    if (!backgroudButton) {
    //         [_searchBar resignFirstResponder];
    //        backgroudButton.hidden=YES;
    //    }
    
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //    NSLog(@"-----scrollViewDidEndDragging");
    [_searchBar resignFirstResponder];
    
    
}

@end
