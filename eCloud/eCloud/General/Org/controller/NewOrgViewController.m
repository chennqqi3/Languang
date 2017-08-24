//
//  NewOrgViewController.m
//  DTNavigationController
//
//  Created by Pain on 14-11-4.
//  Copyright (c) 2014年 Darktt. All rights reserved.
//

#import "NewOrgViewController.h"

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#endif

#ifdef _XINHUA_FLAG_
#import "XINHUAUserInfoViewControllerArc.h"
#endif

#ifdef _BGY_FLAG_
#import "RootDeptCellARC.h"
#endif

#ifdef _LANGUANG_FLAG_
#import "LGRootChooseMemberViewController.h"
#import "LGOrgViewController.h"
#import "LGRootOrgViewController.h"
#import "LGGroupViewController.h"
#endif

#import "conn.h"
#import "SettingItem.h"

#import "newDeptCell.h"
#import "OrgDeptCell.h"
#import "Dept.h"
#import "mainViewController.h"
#import "Emp.h"

#import "eCloudDAO.h"
#import "PSOrgViewUtil.h"
#import "PSListViewController.h"
#import "PublicServiceDAO.h"
#import "UserDisplayUtil.h"
//#import "EmpCell.h"
#import "SearchDeptCell.h"
#import "PermissionModel.h"
#import "PermissionUtil.h"
//#import "DeptCell.h"
#import "UIAdapterUtil.h"

#import "specialChooseMemberViewController.h"
#import "NewChooseMemberViewController.h"
#import "talkSessionViewController.h"
#import "eCloudDefine.h"
#import "userInfoViewController.h"
#import "personInfoViewController.h"

#import "NewDeptCell.h"
#import "NewEmpCell.h"
#import "DeptInMemory.h"
#import "Conversation.h"
#import "NewGroupCell.h"

#import "CommonDeptViewController.h"
#import "CommonEmpViewController.h"
#import "SystemGroupViewController.h"
#import "CommonGroupViewController.h"

#import "UserDataDAO.h"
#import "userDataConn.h"
#import "contactViewController.h"

#import "StatusConn.h"
#import "StatusDAO.h"
#import "ConvNotification.h"
#import "MLNavigationController.h"
#import "UserTipsUtil.h"
#import "DAOverlayView.h"
#import "OrgSizeUtil.h"
#import "RobotDAO.h"
#import "UserDefaults.h"
#import "ScannerViewController.h"
#ifdef _XIANGYUAN_FLAG_
#import "WaterMarkViewARC.h"
#import "KxMenu.h"
#import "PersonInformationViewController.h"
#endif

@interface NewOrgViewController ()<menuCellDelegate, MGSwipeTableCellDelegate>

@property (nonatomic,retain) NSMutableArray *orgItemArray;

@end

@implementation NewOrgViewController
{
    eCloudDAO *_ecloud;
    conn *_conn;
    
    UITableView *orgTable;
    UIButton *backgroudButton;
    UISearchBar *_searchBar;
    UIButton *searchCancelBtn;
    UITextView *searchTextView;
    //    BOOL isSearch;
    int searchDeptAndEmpTag;
    
    UserDataDAO *userData;
    UserDataConn *userDataConn;
    
    StatusConn *_statusConn;
    StatusDAO *statusDAO;
    
    UISearchDisplayController * searchdispalyCtrl;
}
@synthesize orgItemArray;

@synthesize contentOffSetYArray;
@synthesize itemArray;
@synthesize groupArray;
@synthesize deptArray;
@synthesize searchResults;
@synthesize searchTimer;
@synthesize searchStr;

- (void)dealloc
{
    self.orgItemArray = nil;
    
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    [self removeObserver];
    //	add by shisp 取消组织结构变动通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:ORG_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BACK_TO_CONTACTVIEW_FROM_NEWORG object:nil];
    //取消app语言变化通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:REFREASH_CONACTS_LANGUAGE object:nil];
    
    self.searchStr = nil;
//    self.searchTimer = nil;
    
    [self.itemArray removeAllObjects];
    self.itemArray = nil;
    self.groupArray = nil;
    
    [self.deptArray removeAllObjects];
    self.deptArray = nil;
    
    [self.searchResults removeAllObjects];
    self.searchResults = nil;
    
    [self.contentOffSetYArray removeAllObjects];
    self.contentOffSetYArray = nil;
    
    self.removeIndexPath = nil;
    
    self.cellDisplayingMenuOptions = nil;
    self.overlayView = nil;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef _BGY_FLAG_
    // 展示左边侧边栏
    [UIAdapterUtil setupLeftIconItem:self];
#endif
    
    [self addObserver];
    
    _ecloud = [eCloudDAO getDatabase];
    _conn = [conn getConn];
    _statusConn = [StatusConn getConn];
    statusDAO = [StatusDAO getDatabase];
    
    userData = [UserDataDAO getDatabase];
    userDataConn = [UserDataConn getConn];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];

#ifdef _LANGUANG_FLAG_
    
    self.title = [StringUtil getAppLocalizableString:@"main_cont"];
    
#else
    
    self.title = [StringUtil getLocalizableString:@"main_contacts"];
    
#endif
    
    
    self.itemArray = [NSMutableArray array];
    self.groupArray = [NSMutableArray array];
    
    self.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
//    //右边按钮
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake(0, 0, 44, 44);
//    [addButton setBackgroundImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"add_ios" andType:@"png"]] forState:UIControlStateNormal];
//    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
	
    //右边按钮
    UIButton *addButton = [UIAdapterUtil setRightButtonItemWithImageName:@"add_ios.png" andTarget:self andSelector:@selector(addButtonPressed:)];

    
    [self initSearchBar];

    int tableH = self.view.frame.size.height - 20 - 84 - 44;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
    
    //组织架构展示table
    orgTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, _searchBar.frame.size.height, self.view.frame.size.width, tableH-4.0-4.0) style:UITableViewStylePlain]; //调整searchbar不挡住table后 －4
    [UIAdapterUtil setPropertyOfTableView:orgTable];
    [orgTable setDelegate:self];
    [orgTable setDataSource:self];
    orgTable.scrollsToTop = YES;
    orgTable.backgroundColor=[UIColor clearColor];
    orgTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:orgTable];
    [orgTable release];
    
    [self addLeftNavigationBar];
    
    backgroudButton=[[UIButton alloc]initWithFrame:CGRectMake(orgTable.frame.origin.x, orgTable.frame.origin.y, orgTable.frame.size.width, orgTable.frame.size.height)];
    backgroudButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backgroudButton];
    backgroudButton.hidden=YES;
    [backgroudButton release];
    [self getRootItem];
    [orgTable reloadData];
    
    [UIAdapterUtil setExtraCellLineHidden:orgTable];
    [UIAdapterUtil setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
    
    //add by shisp  注册组织架构信息变动通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCancel) name:BACK_TO_CONTACTVIEW_FROM_NEWORG object:nil];
    
    //刷新通讯录语言
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLanguage) name:REFREASH_CONACTS_LANGUAGE object:nil];
    
    if ([UIAdapterUtil isTAIHEApp]) {
        
        if (self.orgItemArray) {
            
            SettingItem *_item = [self getItemByIndexPath:0];
            [self processTableViewDidSelect:_item.dataObject];
        }
    }
    
#ifdef _XIANGYUAN_FLAG_
    
    // 添加水印
    [WaterMarkViewARC waterMarkView:self.view];
    
#endif
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
//    self.title = [StringUtil getLocalizableString:@"main_contacts"];

    _statusConn.curViewController = self;
    [_statusConn getStatus];

	_searchBar.placeholder=[StringUtil getLocalizableString:@"chats_search"];
    if (!searchDeptAndEmpTag) {
        [self displayTabBar];
    }
    else{
        [self hideTabBar];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    
    [self reCalculateFrame];
    
}


-(void)handleCmd:(NSNotification *)notification
{
    if (![self isDept]) {
        return;
    }
    [UserTipsUtil hideLoadingView];
    eCloudNotification *_notification = [notification object];
    if(_notification != nil)
    {
        int cmdId = _notification.cmdId;
        switch (cmdId) {
            case update_user_data_success:
            {
                Dept *dept = [self.itemArray objectAtIndex:self.removeIndexPath.row];
                
                if ([userData isCommonDept:dept.dept_id]) {
                    [userData removeCommonDept:dept.dept_id];
                    
                    for (Dept *dept in self.itemArray) {
                        NSLog(@"%@",dept.dept_name);
                    }
                    
                    //如果是常用部门里删除 则从table中移除
                    for(Dept *groupDept in self.deptArray){
                        if (groupDept.dept_type == type_dept_common_dept) {
                            [self.itemArray removeObjectAtIndex:self.removeIndexPath.row];
                        }
                        
                    }
                    
                   
                }else
                {
                    [userData addCommonDept:[NSArray arrayWithObject:[StringUtil getStringValue:dept.dept_id]]];
                }
                // 执行一次    点击完添加或删除后 第一次点击不会无响应
                if (self.cellDisplayingMenuOptions !=nil) {
                    [self hideMenuOptionsAnimated:YES];
                }
                
                [orgTable reloadData];
            }
                break;
            case update_user_data_fail:
            {
                NSString *msgBody = nil;
                if ([self isAddCommonDept]) {
                    msgBody = [StringUtil getLocalizableString:@"me_common_departments_add_failure"];
                }
                else
                {
                    msgBody = [StringUtil getLocalizableString:@"me_common_departments_remove_failure"];
                }
                [UserTipsUtil showAlert:msgBody];
            }
                break;
            case update_user_data_timeout:
            {
                NSString *msgBody = nil;
                if ([self isAddCommonDept]) {
                    msgBody = [StringUtil getLocalizableString:@"me_common_departments_add_timeout"];
                }
                else
                {
                    msgBody = [StringUtil getLocalizableString:@"me_common_departments_remove_timeout"];
                }
                [UserTipsUtil showAlert:msgBody];
            }
                break;
            default:
                break;
        }
    }
}

-(void)refreshLanguage
{
    [self getRootItem];
//    for (NSArray *_array in self.orgItemArray) {
//        for (id _id in _array) {
//            if ([_id isKindOfClass:[SettingItem class]]) {
//                SettingItem *_item = (SettingItem *)_id;
//                if (_item.dataObject && [_item.dataObject isKindOfClass:[Dept class]]) {
//                    Dept *groupDept = (Dept *)_item.dataObject;
//                    switch (groupDept.dept_type) {
//                        case type_dept_common_contact:
//                            groupDept.dept_name = [StringUtil getLocalizableString:@"me_common_contacts"];
//                            break;
//                            
//                        case type_dept_common_dept:
//                            groupDept.dept_name = [StringUtil getLocalizableString:@"me_common_departments"];
//                            break;
//                            
//                        case type_dept_my_group:
//                            groupDept.dept_name = [StringUtil getLocalizableString:@"me_custom_groups"];
//                            break;
//                            
//                        case type_dept_regular_group:
//                            groupDept.dept_name = [StringUtil getLocalStringRelatedWithAppNameByKey:@"me_ecloud_groups"];
//                            break;
//                            
//                        case type_dept_orgization:
//                        {
//                            groupDept.dept_name = [StringUtil getAppLocalizableString:@"me_my_organization"];
//                        }
//                            break;
//                            
//                        case type_dept_my_computer:
//                        {
//                            groupDept.dept_name = [StringUtil getAppLocalizableString:@"me_my_computer"];
//                        }
//                            break;
//                    }
//                }
//                
//            }
//        }
//    }
    
    Dept *contactDept = self.deptArray[0];
    contactDept.dept_name = [StringUtil getLocalizableString:@"main_contacts"];
    
    [self refreshNaviBar];
    [orgTable reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    _statusConn.curViewController = nil;

	[searchTextView resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    
    if (self.cellDisplayingMenuOptions !=nil) {
        [self hideMenuOptionsAnimated:YES];
    }

}

-(void)searchCancel
{
    [self.searchDisplayController setActive:NO animated:NO];
}

//获取一级部门
-(void)getRootItem
{
    if ([self displayRootOrg]) {
        //获取根部门
        searchDeptAndEmpTag = 0;
        
#ifdef _XIANGYUAN_FLAG_
       
        [self prepareXIANGYUANOrgItems];
        
#else
        
        if ([UIAdapterUtil isCsairApp])
        {
            [self prepareCsairOrgItems];
        }
        else if ([UIAdapterUtil isBGYApp])
        {
            [self prepareBGYOrgItems];
        }
        else
        {
            [self prepareOrgItems];
        }
        
#endif
        
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//        NSArray *allDept = [_ecloud getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
//        
//        [self.itemArray removeAllObjects];
//        [self.itemArray addObjectsFromArray:allDept];
//        [self getCustomGroup];
//        [pool release];
        NSLog(@"%s 获取所有的一级部门，获取所有常用联系人，常用讨论组",__FUNCTION__);
    }
    else{
        searchDeptAndEmpTag = 0;
        id temp= [self.deptArray lastObject];
        if ([temp isKindOfClass:[Dept class]]) {
            //获取子部门
            Dept *dept = (Dept *)temp;
            switch (dept.dept_type) {
                case type_dept_normal:
                {
                    //普通部门
                    int level=dept.dept_level+1;
                    
                    NSMutableArray *allArray=[[NSMutableArray alloc] init];
                    NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:1];
                    NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id andLevel:level];
                    
//                    add by shisp 如果本部门有员工，那么获取这个部门的人员状态
                    if (tempEpArray.count > 0)
                    {
                        if ([statusDAO needGetStatus:[StringUtil getStringValue:dept.dept_id] andType:status_type_dept])
                        {
                            [_statusConn getDeptStatus:dept.dept_id];
                        }
                    }
                    
                    [allArray addObjectsFromArray:tempEpArray];
                    [allArray addObjectsFromArray:tempDeptArray];
                    
                    [self.itemArray removeAllObjects];
                    [self.itemArray addObjectsFromArray:allArray];
                    [allArray release];
                    
                    NSLog(@"%s 普通部门",__FUNCTION__);
                }
                    break;
                case type_dept_common_contact:
                {
                    //常联系人
                    NSArray *tempEpArray = [userData getAllCommonEmp];
                    [self.itemArray removeAllObjects];
                    [self.itemArray addObjectsFromArray:tempEpArray];
                    NSLog(@"%s 常用联系人",__FUNCTION__);

                }
                    break;
                case type_dept_common_dept:
                {
                    //常用部门
                    NSArray *tempDeptArray = [userData getAllCommonDept];
                    [self.itemArray removeAllObjects];
                    [self.itemArray addObjectsFromArray:tempDeptArray];
                    NSLog(@"%s 常用部门",__FUNCTION__);

                }
                    break;
                case type_dept_my_group:
                {
                    //我的群组
                    NSArray *tempDeptArray = [userData getALlCommonGroup];
                    [self.itemArray removeAllObjects];
                    [self.itemArray addObjectsFromArray:tempDeptArray];
                    NSLog(@"%s 常用讨论组",__FUNCTION__);

                }
                    break;
                case type_dept_regular_group:
                {
                     //固定群组
                    NSArray *tempDeptArray = [userData getALlSystemGroup];
                    [self.itemArray removeAllObjects];
                    [self.itemArray addObjectsFromArray:tempDeptArray];
                    NSLog(@"%s 固定群组",__FUNCTION__);

                }
                    break;
                    case type_dept_my_computer:
                {
                     [self.itemArray removeAllObjects];
                    Emp *emp = [_ecloud getEmpInfoByUsercode:USERCODE_OF_FILETRANSFER];
                    if (emp) {
                        [self.itemArray addObject:emp];                        
                    }
                }
                    break;
                    case type_dept_orgization:
                {
                    NSArray *allDept = [_ecloud getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
                    
                    [self.itemArray removeAllObjects];
                   
                    int myComputerDeptId = [_ecloud getDeptIdOfMyComputerDept];
                    if (myComputerDeptId < 0) {
//                        不用过滤了
                        [self.itemArray addObjectsFromArray:allDept];
                    }else{
                        for (Dept *_dept in allDept) {
                            if (_dept.dept_id == myComputerDeptId) {
//                                我的电脑 不显示 在一级部门列表中
                            }else{
                                [self.itemArray addObject:_dept];
                            }
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)getCustomGroup{
    NSMutableArray *tempArr = [NSMutableArray array];
    //常联系人
    Dept *tempDept = [[Dept alloc] init];
    tempDept.dept_type = type_dept_common_contact;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_contacts"]];
    [tempArr addObject:tempDept];
    [tempDept release];
    
    //常用部门
    Dept *tempDept2 = [[Dept alloc] init];
    tempDept2.dept_type = type_dept_common_dept;
    tempDept2.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_departments"]];
    [tempArr addObject:tempDept2];
    [tempDept2 release];
    
//    update by shisp 先显示固定群组
    //固定群组
    Dept *tempDept4 = [[Dept alloc] init];
    tempDept4.dept_type = type_dept_regular_group;
    tempDept4.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"me_ecloud_groups"]];
    [tempArr addObject:tempDept4];
    [tempDept4 release];

    //我的群组
    Dept *tempDept3 = [[Dept alloc] init];
    tempDept3.dept_type = type_dept_my_group;
    tempDept3.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_custom_groups"]];
    [tempArr addObject:tempDept3];
    [tempDept3 release];
    
    [self.groupArray removeAllObjects];
    [self.groupArray addObjectsFromArray:tempArr];
}


#pragma mark - 显示或隐藏tabar
-(void)displayTabBar
{
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}

-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}

#pragma mark - 添加组织架构导航栏
- (void)addLeftNavigationBar{
    
    if (!self.deptArray) {
        //根部门
        Dept *rootDept = [[Dept alloc] init];
        rootDept.dept_id = 0;
        rootDept.dept_level = 0;
        rootDept.dept_name = [StringUtil getLocalizableString:@"main_contacts"];
        self.deptArray = [NSMutableArray arrayWithObject:rootDept];
        [rootDept release];
    }
    
    float heigh = orgTable.frame.size.height;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, orgTable.frame.origin.y, [OrgSizeUtil getLeftScrollViewWidth], heigh)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.backgroundColor = [UIColor whiteColor];
    float xx = [OrgSizeUtil getLeftScrollViewHeight];
    scrollView.contentSize = CGSizeMake([OrgSizeUtil getLeftScrollViewWidth], ([OrgSizeUtil getLeftScrollViewHeight]+1)*[self.deptArray count]);
    [scrollView setShowsVerticalScrollIndicator:NO];
//    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    scrollView.scrollsToTop = NO;
    [scrollView release];
    
    [self refreshNaviBar];
}

- (void)refreshNaviBar{
    if (!self.deptArray) {
        //根部门
        Dept *rootDept = [[Dept alloc] init];
        rootDept.dept_id = 0;
        rootDept.dept_level = 0;
        self.deptArray = [NSMutableArray arrayWithObject:rootDept];
        [rootDept release];
        
        NSLog(@"%s 初始化 self.deptArray",__FUNCTION__);
    }
    
    for (UIView *subView in scrollView.subviews) {
        if (subView.tag >= 11) {
            [subView removeFromSuperview];
        }
    }
    NSLog(@"%s 删除tag大于11的subview",__FUNCTION__);

    scrollView.contentSize = CGSizeMake([OrgSizeUtil getLeftScrollViewWidth], [OrgSizeUtil getLeftScrollViewHeight]*[self.deptArray count]);
    NSLog(@"%s 设置scrollView的size",__FUNCTION__);
    
    
    int deptNavCount = [self.deptArray count];
    for (int i = 0; i < deptNavCount; i ++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(1.0, [OrgSizeUtil getLeftScrollViewHeight]*i, [OrgSizeUtil getLeftScrollViewWidth]-2, [OrgSizeUtil getLeftScrollViewHeight])];
        btn.backgroundColor = [UIColor clearColor];

        CGRect _frame = btn.frame;
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(2.0, 0.0, [OrgSizeUtil getLeftScrollViewWidth]-4, _frame.size.height-2.0)];
        lab.backgroundColor = [UIColor clearColor];
        [btn addSubview:lab];
        [lab release];
        
        NSString *title = @"";
        id temp = [self.deptArray objectAtIndex:i];
        if ([temp isKindOfClass:[Dept class]]) {
            title = [NSString stringWithFormat:@"%@",[[self.deptArray objectAtIndex:i] dept_name]];
            NSLog(@"%s 部门类型，部门名称是%@",__FUNCTION__,[[self.deptArray objectAtIndex:i] dept_name]);
        }
        else if([temp isKindOfClass:[Conversation class]]){
            title = [NSString stringWithFormat:@"%@",[[self.deptArray objectAtIndex:i] conv_title]];
            NSLog(@"%s 会话类型，会话标题是%@",__FUNCTION__,[[self.deptArray objectAtIndex:i] conv_title]);
        }
        
        NSMutableString *titleStr = @"";
        if ([title length] > 4) {
            titleStr = [[NSMutableString alloc] initWithString:[title substringToIndex:4]];
        }
        else{
            titleStr = [[NSMutableString alloc] initWithString:title] ;
        }
        
        int lenth = [titleStr length];
        for (int i = 0; i < lenth-1; i ++) {
             [titleStr insertString:@"\n" atIndex:2*i+1];
        }
        
        lab.text = titleStr;
        lab.numberOfLines = 4;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        lab.font = [UIFont systemFontOfSize:[OrgSizeUtil getFontSizeOfDeptNav]];
        
#ifdef _LANGUANG_FLAG_
        /** 蓝光要求 选中的部门 显示为蓝色背景 */
        [lab setTextColor:[UIColor colorWithRed:143.0/255 green:148.0/255 blue:159.0/255 alpha:1.0]];
        
        /** 第一项的显示 */
        if (i == 0) {
            if (deptNavCount == 1) {
                /** 只有一项 显示蓝色长方形 */
                [lab setTextColor:[UIColor whiteColor]];
                [btn setBackgroundImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"] forState:UIControlStateNormal];
            }
            else{
                /** 有多项 第一项显示显示白色 下面有三角的背景 */
                [btn setBackgroundImage:[StringUtil getImageByResName:@"deptNavBtn2.png"] forState:UIControlStateNormal];
            }
        }
        else{
            if (i == deptNavCount-1 ) {
                /** 最后一个显示为蓝色长方形 */
                [lab setTextColor:[UIColor whiteColor]];
                [btn setBackgroundImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"] forState:UIControlStateNormal];
            }
            else{
                /** 其它显示为 白色三角行政 */
                [btn setBackgroundImage:[StringUtil getImageByResName:@"deptNavBtn2.png"] forState:UIControlStateNormal];
            }
        }
        
        if (i == (deptNavCount - 2)) {
            /** 倒数第二个有一个背景view 蓝色的 长方形 */
            UIImageView *exBgView = [[[UIImageView alloc]initWithImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]]autorelease];
            CGRect _frame = btn.frame;
            _frame = CGRectMake(_frame.origin.x, _frame.origin.y + 2, _frame.size.width, _frame.size.height - 2);
            exBgView.frame = _frame;
            exBgView.tag = 1000;
            [scrollView addSubview:exBgView];
        }
        
#else
        if (i == 0) {
            [lab setTextColor:[UIColor whiteColor]];
            if (deptNavCount == 1) {
                [btn setBackgroundImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"] forState:UIControlStateNormal];
            }
            else{
                [btn setBackgroundImage:[StringUtil getImageByResName:@"rootDeptBtn2.png"] forState:UIControlStateNormal];
            }
        }
        else{
            [lab setTextColor:[UIColor colorWithRed:143.0/255 green:148.0/255 blue:159.0/255 alpha:1.0]];
            if (i == deptNavCount-1 ) {
                [btn setBackgroundImage:[StringUtil getImageByResName:@"deptNavBtn1.png"] forState:UIControlStateNormal];
                if ([UIAdapterUtil isGOMEApp])
                {
                    [lab setTextColor:GOME_BLUE_COLOR];
                }
            }
            else{
                [btn setBackgroundImage:[StringUtil getImageByResName:@"deptNavBtn2.png"] forState:UIControlStateNormal];
                if ([UIAdapterUtil isGOMEApp])
                {
                    [lab setTextColor:[UIColor colorWithRed:143.0/255 green:148.0/255 blue:159.0/255 alpha:1.0]];
                }
            }
        }

#endif
        
            btn.tag = i+11;
        NSLog(@"%s button tag is %d",__FUNCTION__,btn.tag);
        
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btn];
        [btn release];
    }
    
    //分割线
    UILabel  *lineBreak = [[UILabel alloc] initWithFrame:CGRectMake([OrgSizeUtil getLeftScrollViewWidth]-1.5, 0.0, 1.0, orgTable.frame.size.height)];
    lineBreak.tag = 100;
    lineBreak.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    [scrollView addSubview:lineBreak];
    [lineBreak release];
    
    id temp = [self.deptArray lastObject];
    if ([temp isKindOfClass:[Dept class]]) {
        Dept *dept = (Dept *)temp;
        self.title = [NSString stringWithFormat:@"%@",[dept dept_name]];
        [self setTabBarItemTitle];
    }
    else if([temp isKindOfClass:[Conversation class]]){
        Conversation *conv = (Conversation *)temp;
        self.title = [NSString stringWithFormat:@"%@",[conv conv_title]];
        [self setTabBarItemTitle];
    }
    
    //确保最后的部门显示出来
    float contentHeight = scrollView.contentSize.height;
    float frameHeight = scrollView.frame.size.height;
    if (contentHeight > frameHeight) {
        [scrollView setContentOffset:CGPointMake(0.0, contentHeight-frameHeight)];
    }
}


- (void)btnAction:(UIButton *)sender{
    NSLog(@"-----------%i",sender.tag);
//    int index = [self.navigationController.childViewControllers  count] - [self.navArray count] + sender.tag;
//    [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:index] animated:YES];
    
    NSLog(@"%s button tag is %d",__FUNCTION__,sender.tag);
    int count = [self.deptArray count];
    int index = sender.tag-11;
    if (index<count-1) {
        [self.deptArray removeObjectsInRange:NSMakeRange(index+1, count-index-1)];
        
        [self getRootItem];
        [self refreshNaviBar];
        [orgTable setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        [orgTable reloadData];
        
        NSNumber *conttentOffSetY = self.contentOffSetYArray[index];
        CGPoint point = CGPointMake(0, [conttentOffSetY doubleValue]);
        orgTable.contentOffset = point;
    }
}

#pragma mark - 添加联系人
-(void) addButtonPressed:(id) sender{
    [searchTextView resignFirstResponder];
	
#ifdef _XIANGYUAN_FLAG_
    
    NSMutableArray *menuItems = [NSMutableArray array];
    
    KxMenuItem *shortCutMenuItem1 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_create_new_chat"]
                                                   image:[StringUtil getImageByResName:@"faqihuihua.png"]
                                                  target:self
                                                  action:@selector(selectMenuItem1)];
    
    KxMenuItem *shortCutMenuItem2 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"scan_the_code"]
                                                   image:[StringUtil getImageByResName:@"jiqiren.png"]
                                                  target:self
                                                  action:@selector(scanAction)];
    
    KxMenuItem *shortCutMenuItem3 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_FileTransfer"]
                                                   image:[StringUtil getImageByResName:@"wenjianzhushou.png"]
                                                  target:self
                                                  action:@selector(selectMenuItem3)];
    
    [menuItems addObject:shortCutMenuItem1];
    [menuItems addObject:shortCutMenuItem2];
    [menuItems addObject:shortCutMenuItem3];
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 30, 0, 0, 0) menuItems:menuItems];
#else
    

    id temp= [self.deptArray lastObject];
    if ([temp isKindOfClass:[Dept class]]) {
        //获取自部门
        Dept *dept = (Dept *)temp;
        
        //创建会话
        NSMutableArray *deptNavArray = [NSMutableArray arrayWithArray:self.deptArray];
        
//        NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
//        _controller.typeTag = type_create_conversation;
//        _controller.deptNavArray = deptNavArray;
//        [self hideTabBar];
//        [self.navigationController pushViewController:_controller animated:YES];
//        [_controller release];
        
        NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
        UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:_controller];
        _controller.typeTag = type_create_conversation;
        _controller.deptNavArray = deptNavArray;
        
        _controller.contentOffSetYArray[self.deptArray.count - 1] = @(orgTable.contentOffset.y);

        [self hideTabBar];
        [UIAdapterUtil presentVC:navController];
//        [self.navigationController presentViewController:navController animated:YES completion:nil];
//        [self.navigationController presentModalViewController:navController animated:YES];
        [_controller release];
        
        /*
        switch (dept.dept_type) {
            case type_dept_normal:
            case type_dept_my_group:
            case type_dept_regular_group:
            {
                //创建会话
                NSMutableArray *deptNavArray = [NSMutableArray arrayWithArray:self.deptArray];
                NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
                _controller.typeTag = type_create_conversation;
                _controller.deptNavArray = deptNavArray;
                [self hideTabBar];
                [self.navigationController pushViewController:_controller animated:YES];
                [_controller release];
            }
                break;
            case type_dept_common_contact:
            {
                //添加常联系人
                NSMutableArray *deptNavArray = [NSMutableArray arrayWithArray:self.deptArray];
                NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
                _controller.typeTag=type_add_common_emp;
                 _controller.deptNavArray = deptNavArray;
                [self hideTabBar];
                [self.navigationController pushViewController:_controller animated:YES];
                [_controller release];
            }
                break;
            case type_dept_common_dept:
            {
                //常用部门
                NSMutableArray *deptNavArray = [NSMutableArray arrayWithArray:self.deptArray];
                NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
                _controller.typeTag=type_add_common_dept;
                 _controller.deptNavArray = deptNavArray;
                [self hideTabBar];
                [self.navigationController pushViewController:_controller animated:YES];
                [_controller release];
            }
                break;
            default:
                break;
        }
         */
    }
    
#endif
}


#pragma mark------UISearchBarDelegate-----

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //	isSearch	=	YES;
    backgroudButton.hidden=NO;
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    NSLog(@"%s",__FUNCTION__);
    self.searchStr = [StringUtil trimString:searchBar.text];
	if([self.searchStr length] == 0)
	{
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
	}
	else
	{
        /*
        if (self.searchTimer && [self.searchTimer isValid])
        {
            // NSLog(@"searchTimer is valid");
            [self.searchTimer invalidate];
        }
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchOrg) userInfo:nil repeats:NO];
         */
	}
}

- (void)searchOrg
{
    dispatch_queue_t queue = dispatch_queue_create("search org", NULL);
    
    dispatch_async(queue, ^{
        int _type = [StringUtil getStringType:self.searchStr];
        
        if(_type != other_type){
            searchDeptAndEmpTag=1;
            
            NSString *_searchStr = [NSString stringWithString:self.searchStr];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            NSMutableArray *dataarray=[NSMutableArray array];
            
            [_ecloud setLimitWhenSearchUser:YES];
            NSArray *emparray= [_ecloud getEmpsByNameOrPinyin:_searchStr andType:_type];
            [dataarray addObjectsFromArray:emparray];
            
            [self.searchResults removeAllObjects];
            [self.searchResults  addObjectsFromArray:dataarray];
            //            增加搜索部门
            if ([eCloudConfig getConfig].needSearchDept) {
                NSArray *tempDeptArray = [_ecloud getDeptByNameOrPinyin:_searchStr andType:_type];
                [self.searchResults addObjectsFromArray:tempDeptArray];
            }
            [pool release];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
            self.searchDisplayController.searchResultsTableView.contentOffset = CGPointMake(0, 0);
            if (![self.searchResults count]) {
                [self setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"]];
            }
            
            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
    dispatch_release(queue);
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchStr length] < [eCloudConfig getConfig].searchTextMinLen.intValue) {
        [self showSearchTip:[StringUtil getLocalizableString:@"search_tip"]];
        return;
    }
    
	[searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    
    //搜索提示
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    [[LCLLoadingView currentIndicator] show];
    
    [self searchOrg];
}

#pragma mark =======table view delegate===========
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }

    if ([self displayRootOrg]) {
        if ([UIAdapterUtil isBGYApp]) {
            return 1;
        }
        return self.orgItemArray.count;
    }
    NSLog(@"%s section 个数为 %d",__FUNCTION__,1);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return self.searchResults.count;
    }
    
//    左侧只显示一个按钮的时候
    if ([self displayRootOrg]) {
        if ([UIAdapterUtil isBGYApp])
        {
            int _row = self.orgItemArray.count;
            return _row;
        }
        else
        {
            NSArray *_array = self.orgItemArray[section];
            int _row = _array.count;
            return _row;
        }
    }
    
    return [self.itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self displayRootOrg] && section > 0) {
//        
        SettingItem *_item = [self getItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        
        if (_item && _item.headerHight) {
            return _item.headerHight;
        }
        return 20.0;
    }
//    if (section == 1) {
//        return 20.0;
//    }
//    else if (section == 2) {
//        return GROUP_SECTION_HEADER_HEIGHT;
//    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([eCloudConfig getConfig].needSearchDept) {
            id temp = [self.searchResults objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                return dept_row_height;
            }
        }
        return emp_row_height;
    }else
    {
        if ([self displayRootOrg]) {
            if ([UIAdapterUtil isBGYApp])
            {
                // 人员和群组
                return emp_row_height;
            }
            else
            {
                return dept_row_height;
            }
        }else{
            id temp = [self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
//                部门
                return dept_row_height;
            }else{
//                人员和群组
                return emp_row_height;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView != self.searchDisplayController.searchResultsTableView){
        cell.backgroundColor = [UIColor whiteColor];
//        下面代码 没什么意义
//        id temp;
//        if (indexPath.section == 0) {
//            temp=[self.itemArray objectAtIndex:indexPath.row];
//        }
//        else{
//            temp=[self.groupArray objectAtIndex:indexPath.row+2*(indexPath.section-1)];
//        }
//        
//        if ([temp isKindOfClass:[Dept class]]){
//            cell.backgroundColor = [UIColor whiteColor];
//        }
//        else{
//            cell.backgroundColor = [UIColor whiteColor];
//        }
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        id temp=[self.searchResults objectAtIndex:indexPath.row];
        if ([eCloudConfig getConfig].needSearchDept) {
            if ([temp isKindOfClass:[Dept class]])
            {
                Dept *tempDept = (Dept *)temp;
                
                NewDeptCell *deptCell = [[[NewDeptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
                deptCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                [deptCell configSearchResultCell:tempDept];
                
                return deptCell;
            }
        }

        if ([temp isKindOfClass:[Emp class]])
        {
            return [self getEmpWithDeptCell:indexPath];
        }
        else{
            return nil;
        }
    }
	else
	{
//        通讯录首页
        if ([self displayRootOrg]) {
            SettingItem *_item = [self getItemByIndexPath:indexPath];
            
            if ([UIAdapterUtil isBGYApp])
            {
#ifdef _BGY_FLAG_

                RootDeptCellARC *deptCell = [[[RootDeptCellARC alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil] autorelease];
                deptCell.item = _item;
                return deptCell;
#endif
            }
            else
            {
                
                id dataObject = _item.dataObject;
                if ([dataObject isKindOfClass:[Dept class]]) {
                    Dept *tempDept = (Dept *)dataObject;
                    
                    NewDeptCell *deptCell = [[[NewDeptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
                    deptCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    [deptCell configCell:tempDept];
                    
                    return deptCell;
                }
            }
            return nil;
        }else{
            //组织架构
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]])
            {
                static NSString *deptCellID = @"deptCellID";
                /*
                NewDeptCell *deptCell = [tableView dequeueReusableCellWithIdentifier:nil];
                if (deptCell == nil)
                {
                    deptCell = [[[NewDeptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deptCellID] autorelease];
                    deptCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
                [deptCell configCell:dept];
                if ([self canLeftSlideByIndexPath:indexPath]) {
                    [deptCell configContextMenuView];
                }
                //                NSLog(@"Cell recursive description:\n\n%@\n\n", [deptCell performSelector:@selector(recursiveDescription)]);
                deptCell.delegate = self;
                */
                
                OrgDeptCell *deptCell = [tableView dequeueReusableCellWithIdentifier:deptCellID];
                if (deptCell == nil)
                {
                    deptCell = [[[OrgDeptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deptCellID]autorelease];
                    deptCell.delegate = self;
                }
                
                Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
                deptCell.name = dept.dept_name;
                
                // 是否本部门
                BOOL isMyDept;
                if ([UIAdapterUtil isCsairApp])
                {
                    eCloudDAO *db = [eCloudDAO getDatabase];
                    NSArray *deptsArray = [db getUserDeptsArray];
                    
                    for (NSString *deptID in deptsArray) {
                        if (dept.dept_id == [deptID intValue]) {
                            isMyDept = YES;
                        }
                    }
                }
                // 设置右边的按钮
                if (![self canLeftSlideByIndexPath:indexPath] || ([UIAdapterUtil isCsairApp] && isMyDept))
                {
                    deptCell.rightButtons = nil;
                }
                else
                {
                    [deptCell addRightButton];
                    // 设置optionButtonTitle
                    id temp=[self.itemArray objectAtIndex:indexPath.row];
                    if ([temp isKindOfClass:[Dept class]]) {
                        Dept *tempDept = (Dept*) temp;
                        if ([userData isCommonDept:tempDept.dept_id]) {
                            
                            deptCell.optionButtonTitle = [StringUtil getLocalizableString:@"delete_common_dept"];
                        }else
                        {
                            deptCell.optionButtonTitle = [StringUtil getLocalizableString:@"add_common_dept"];
                        }
                    }
                }
                
                NSLog(@"%s section0 部门",__FUNCTION__);
                return deptCell;
            }
            else if ([temp isKindOfClass:[Emp class]])
            {
                NSLog(@"%s section0 员工",__FUNCTION__);
                return [self getEmpCell:indexPath];
                
            }
            else{
                NSLog(@"%s section0 群组",__FUNCTION__);
                
                return [self getGroupCell:indexPath];
            }

        }
    }
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    [self contextMenuCellDidSelectDeleteOption:cell];
    
    return YES;
}

/*
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemArray.count >0 && indexPath.row < self.itemArray.count) {
        id temp=[self.itemArray objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[Dept class]]) {
            
            Dept *tempDept = (Dept*) temp;
            
            //如果是常用部门 只有顶级部门才有删除
            for(Dept *groupDept in self.deptArray){
                if (groupDept.dept_type == type_dept_common_dept) {
                    if (tempDept.dept_level == 0) {
                        return YES;
                    }else
                    {
                        return NO;
                    }
                }
            }
            
            //普通部门时 级别大于0的允许添加常用部门
            if (tempDept.dept_level >0) {
                return YES;
            }
            return NO;
            
        }
        return NO;
    }
}
*/

/*
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[Dept class]]) {
        Dept *tempDept = (Dept*) temp;
        if ([userData isCommonDept:tempDept.dept_id]) {
            return [StringUtil getLocalizableString:@"delete_common_dept"];
        }else
        {
            return [StringUtil getLocalizableString:@"add_common_dept"];
        }
    }
}
 */

/*
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Dept *tempDept = self.itemArray[indexPath.row];
        BOOL isCommonDept = [userData isCommonDept:tempDept.dept_id];
        BOOL ret = NO;
        self.removeIndexPath = indexPath;
        if (isCommonDept)
        {
            //删除
            ret = [userDataConn sendModiRequestWithDataType:user_data_type_dept andUpdateType:user_data_update_type_delete andData:[NSArray arrayWithObject:[StringUtil getStringValue:tempDept.dept_id]]];
            
        }else
        {
            //添加
            ret = [userDataConn sendModiRequestWithDataType:user_data_type_dept andUpdateType:user_data_update_type_insert andData:[NSArray arrayWithObject:[StringUtil getStringValue:tempDept.dept_id]]];
        }
        
        if (ret) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"me_loading_tip"]];
        }
    }
}
*/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self displayRootOrg] && section > 0) {
        SettingItem *_item = [self getItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        if (_item.headerView) {
            return _item.headerView;
        }
    }
    return nil;
    
//    UIView *headBgView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,GROUP_SECTION_HEADER_HEIGHT)];
//    headBgView.backgroundColor = [UIColor clearColor];
//
//    if (section == 2) {
//        UILabel *titlelabel = [[[UILabel alloc]initWithFrame:CGRectMake([OrgSizeUtil getLeftScrollViewWidth] + 10,0.0, SCREEN_WIDTH - [OrgSizeUtil getLeftScrollViewWidth] - 10, GROUP_SECTION_HEADER_HEIGHT)]autorelease];
//        titlelabel.backgroundColor = [UIColor clearColor];
//        titlelabel.numberOfLines = 2;
//        titlelabel.lineBreakMode = NSLineBreakByTruncatingTail;
//        titlelabel.font = [UIFont systemFontOfSize:13.5];
//        titlelabel.textColor = [UIColor colorWithRed:156.0/255 green:156.0/255 blue:156.0/255 alpha:1.0];
//        titlelabel.textAlignment = UITextAlignmentLeft;
//        titlelabel.text = [NSString stringWithFormat:@"\n%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"select_custom_groups_tip"]];
//        [headBgView addSubview:titlelabel];
//    }
//    return [headBgView autorelease];
}

#pragma mark 获取员工的显示方式
-(NewEmpCell *)getEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	NewEmpCell *empCell = [orgTable dequeueReusableCellWithIdentifier:empCellID];
	if(empCell == nil)
	{
		empCell = [[[NewEmpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
//        [self addGesture:empCell];
	}
	
	Emp *emp = [self.itemArray objectAtIndex:indexPath.row];
	[empCell configureCell:emp];
	return empCell;
}

- (void)addGesture:(NewEmpCell *)empCell
{
    UIImageView *logoView = (UIImageView *)[empCell viewWithTag:emp_logo_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openPersonInfo:)];
    [logoView addGestureRecognizer:singleTap];
    [singleTap release];
}

#pragma mark 获取员工的显示方式
-(NewEmpCell *)getEmpWithDeptCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	NewEmpCell *empCell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:empCellID];
	if(empCell == nil)
	{
		empCell = [[[NewEmpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
		[self addGesture:empCell];
	}
	
	Emp *emp = [self.searchResults objectAtIndex:indexPath.row];
	[empCell configureWithDeptCell:emp];
	return empCell;
}

#pragma mark - 我的群组，固定群组
- (NewGroupCell *)getGroupCell:(NSIndexPath*)indexPath{
    static NSString *CellIdentifier = @"Cell";
    NewGroupCell *groupCell = [orgTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (groupCell == nil) {
        groupCell = [[[NewGroupCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        groupCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Conversation *emp = (Conversation *)[self.itemArray objectAtIndex:indexPath.row];
    
    [groupCell configCell:emp];
//    
//    UIView *imageLogo = [groupCell viewWithTag:logo_view_tag];
//    CGRect _frame = imageLogo.frame;
//    _frame.origin.y = (GroupCellHeight - chatview_logo_size)*0.5;
//    imageLogo.frame = _frame;
//    
//    UIView *label = [groupCell viewWithTag:group_name_tag];
//    CGPoint _center = label.center;
//    _center.y = GroupCellHeight*0.5;
//    label.center = _center;
    return groupCell;
}

//打开常联系人
- (void)openCommonEmp
{
    Dept *dept = self.groupArray[0];
    //常联系人
    [self.deptArray addObject:dept];
    [self getRootItem];
    [self refreshNaviBar];
    [orgTable reloadData];
}

//打开常用部门
- (void)openCommonDept
{
    //常用部门
    Dept *dept = self.groupArray[1];
    [self.deptArray addObject:dept];
    [self getRootItem];
    [self refreshNaviBar];
    [orgTable reloadData];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //记下当前tableview的contentOffSet
    NSNumber *contentOffsetY = [NSNumber numberWithDouble:tableView.contentOffset.y];
    self.contentOffSetYArray[self.deptArray.count - 1] = contentOffsetY;
    
    [searchTextView resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
       id temp=[self.searchResults objectAtIndex:indexPath.row];
        if ([eCloudConfig getConfig].needSearchDept) {
            if ([temp isKindOfClass:[Dept class]]) {
                Dept *tempDept = (Dept *)temp;
                NSMutableArray *allArray=[NSMutableArray array];
                NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithLevel:[NSString stringWithFormat:@"%d",tempDept.dept_id]  andLevel:0];
                NSArray *tempEpArray=[_ecloud getEmpsByDeptID:tempDept.dept_id andLevel:0];
                [self.searchResults removeAllObjects];
                [self.searchResults addObjectsFromArray:tempEpArray];
                [self.searchResults addObjectsFromArray:tempDeptArray];
                [self.searchDisplayController.searchResultsTableView reloadData];
                self.searchDisplayController.searchResultsTableView.contentOffset = CGPointMake(0, 0);
                return;
            }
        }
//        只有员工
        [self processTableViewDidSelect:temp];
    }else{
        if ([self displayRootOrg]) {
//            通讯录首页 可以是一级部门，也可以是常用联系人、常用部门等
            SettingItem *_item = [self getItemByIndexPath:indexPath];
            [self processTableViewDidSelect:_item.dataObject];
        }else{
//            类型有部门、员工和会话
            id temp = [self.itemArray objectAtIndex:indexPath.row];
            [self processTableViewDidSelect:temp];
        }
    }
}

#pragma mark - 当前页面打开会话
- (void)openConversation:(Conversation *)conv{
    if (conv.recordType == normal_conv_type)
    {
        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
        
        if(conv.conv_type==singleType)
        {
            talkSession.talkType = singleType;
            talkSession.titleStr = [conv.emp getEmpName];
            talkSession.convId =conv.conv_id;
            talkSession.convEmps = [NSArray arrayWithObject:conv.emp];
            talkSession.needUpdateTag=1;
            [self hideTabBar];
            [self.navigationController pushViewController:talkSession animated:YES];
            
        }
        else if(conv.conv_type == rcvMassType)
        {
            BOOL needMerge = NO;
            if(needMerge)
            {
                talkSession.talkType = singleType;
                talkSession.titleStr = [conv.emp getEmpName];
                talkSession.convId = [StringUtil getStringValue:conv.emp.emp_id]  ;
            }
            else
            {
                talkSession.talkType = rcvMassType;
                talkSession.titleStr = [conv.emp getEmpName];
                talkSession.convId =conv.conv_id;
            }
            
            talkSession.convEmps = [NSArray arrayWithObject:conv.emp];
            talkSession.needUpdateTag=1;
            [self hideTabBar];
            [self.navigationController pushViewController:talkSession animated:YES];
        }
        else
        {
            talkSession.talkType = mutiableType;
            talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
            talkSession.convId = conv.conv_id;
            talkSession.needUpdateTag=1;
            talkSession.convEmps =[_ecloud getAllConvEmpBy:conv.conv_id];
            talkSession.last_msg_id=conv.last_msg_id;
            
            [self hideTabBar];
//            [self.navigationController pushViewController:talkSession animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
        }
    }
}


-(void)openPersonInfo:(UIGestureRecognizer*)gesture
{
    UIImageView *logoView = gesture.view;
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    NSString *empIdStr = empIdLabel.text;
    
    [self hideTabBar];
    
    [[self class] openUserInfoById:empIdStr andCurController:self];
}

+(void)openUserInfoById:(NSString *)empId andCurController:(UIViewController *)curController
{
    
#ifdef _XINHUA_FLAG_
    
    XINHUAUserInfoViewControllerArc *userInfoCtl = [[XINHUAUserInfoViewControllerArc alloc] init];
    
    eCloudDAO *_ecloud1 = [eCloudDAO getDatabase];
    Emp *emp1 = [_ecloud1 getEmpInfo:empId];
    userInfoCtl.emp = emp1;
    [curController.navigationController pushViewController:userInfoCtl animated:YES];
    [userInfoCtl release];
    
    return;
#endif
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    [[HuaXiaOrgUtil getUtil]openHXUserInfoById:empId.intValue andCurController:curController];
#else
    conn *_conn = [conn getConn];
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    if (empId.intValue ==  _conn.userId.intValue)
    {
#ifdef _XIANGYUAN_FLAG_
      
        PersonInformationViewController *userInfo=[[PersonInformationViewController alloc]init];
        [curController.navigationController pushViewController:userInfo animated:YES];
        [userInfo release];
#else
        
        userInfoViewController *userInfo=[[userInfoViewController alloc]init];
        userInfo.tagType=1;
        [curController.navigationController pushViewController:userInfo animated:YES];
        [userInfo release];
        
#endif
        
    }
    else        
    {
        personInfoViewController *personInfo=[[personInfoViewController alloc]init];
        personInfo.emp = [_ecloud getEmpInfo:empId];
        if([curController isKindOfClass:[NewOrgViewController class]])
        {
            personInfo.isComeFromContactView = YES;
        }else if([curController isKindOfClass:[NewChooseMemberViewController class]]){
            personInfo.isComeFromChooseView = YES;
        }
        
#ifdef _LANGUANG_FLAG_
        else if([curController isKindOfClass:[LGRootOrgViewController class]]){
            personInfo.isComeFromContactView = YES;
        }else if([curController isKindOfClass:[LGRootChooseMemberViewController class]]){
            personInfo.isComeFromChooseView = YES;
        }
#endif

        [curController.navigationController pushViewController:personInfo animated:YES];
        [personInfo release];
    }
#endif
}

//触摸关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[searchTextView resignFirstResponder];
}

-(void)dismissKeybordByClickBackground
{
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
			[orgTable reloadData];
			break;
		default:
			break;
	}
}

-(void)phoneActon:(id)sender
{
    UIButton *button=(UIButton *)sender;
    [userInfoViewController callNumber:button.titleLabel.text];
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
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

- (void)initSearchBar
{
    //查询bar
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getLocalizableString:@"chats_search"];
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    
    //    注释by shisp 通讯录和选择联系人界面 搜索框 点击取消搜索按钮，会引起搜索框焦点重新获取，引起键盘跳动
    
//    for (UIView *searchBarSubview in [_searchBar subviews]) {
//        if ( [searchBarSubview isKindOfClass:[UITextField class] ] ) {
//            // ios 6 and earlier
//            searchTextView = (UITextField *)searchBarSubview;
//        } else {
//            // for ios 7 what we need is nested inside another container
//            for (UIView *subSubView in [searchBarSubview subviews]) {
//                if ( [subSubView isKindOfClass:[UITextField class] ] ) {
//                    searchTextView = (UITextField *)subSubView;
//                }
//            }
//        }
//    }
//	[searchTextView setReturnKeyType:UIReturnKeySearch];
//    
//    for (UIView *searchBarSubview in [_searchBar subviews]) {
//        if ( [searchBarSubview isKindOfClass:[UIButton class] ] ) {
//            // ios 6 and earlier
//            searchTextView = (UITextField *)searchBarSubview;
//        } else {
//            // for ios 7 what we need is nested inside another container
//            for (UIView *subSubView in [searchBarSubview subviews]) {
//                if ( [subSubView isKindOfClass:[UITextField class] ] ) {
//                    searchTextView = (UITextField *)subSubView;
//                }
//            }
//        }
//    }
//    
    
//	_searchBar.keyboardType = UIKeyboardTypeDefault;
//	_searchBar.backgroundColor=[UIColor colorWithRed:210/255.0 green:215/255.0 blue:220/255.0 alpha:1];
    
    [self.view addSubview:_searchBar];
	[_searchBar release];
    
    
//    CGRect frame = searchTextView.frame;
//    frame.size.width -= 40.0;
//    searchTextView.frame = frame;
//    searchTextView.backgroundColor = [UIColor redColor];
    
    
//     _searchBar.showsCancelButton = YES;
//    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    searchBtn.backgroundColor = [UIColor clearColor];
//    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
//    searchBtn.titleLabel.font=[UIFont boldSystemFontOfSize:18];
//    searchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [searchBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    searchBtn.frame = CGRectMake(_searchBar.frame.size.width-70.0, 0.0, 70.0, 40.0);
//    [searchBtn setBackgroundImage:[StringUtil getImageByResName:nil] forState:UIControlStateNormal];
//    [searchBtn addTarget:self action:@selector(clickOnSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [_searchBar addSubview:searchBtn];
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchdispalyCtrl.active = NO;
    searchdispalyCtrl.delegate = self;
    searchdispalyCtrl.searchResultsDelegate=self;
    searchdispalyCtrl.searchResultsDataSource = self;
    
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
}

- (void)clickOnSearchBtn:(UIButton *)sender{
    NSLog(@"clickOnSearchBtn--------");
}

#pragma mark - UISearchDisplayDelegate协议方法
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    orgTable.scrollsToTop = NO;
    controller.searchResultsTableView.scrollsToTop = YES;
    
    if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
//        南航融合版本不需要隐藏tabbar
    }else{
        [self hideTabBar];
    }
    [UIAdapterUtil customCancelButton:self];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    orgTable.scrollsToTop = YES;
    controller.searchResultsTableView.scrollsToTop = NO;

    searchDeptAndEmpTag = 0;
    [self displayTabBar];
    backgroudButton.hidden=YES;
}


- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [self setSearchResultsTitle:@""];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
     if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
//         南航融合版本 搜索纪录 被盖住了，隐藏修改尺寸
         CGRect _frame = CGRectMake(0, 0, tableView.frame.size.width, SCREEN_HEIGHT - 108);
         tableView.frame = _frame;
     }
}

#pragma mark - 搜索提示
- (void)setSearchResultsTitle:(NSString *)title{
    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:title];
        }
    }
}

- (void)showSearchTip:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
    [alert show];
}

#pragma mark ===========用户状态变化，刷新=============
- (void)empStatusChange:(NSNotification *)_notificatio
{
    if (self.deptArray.count >= 2)
    {
        id temp= [self.deptArray lastObject];
        if ([temp isKindOfClass:[Dept class]])
        {
            Dept *dept = (Dept *)temp;
            if (dept.dept_type == type_dept_normal)
            {
                [orgTable reloadData];
            }
        }
    }
}

-(void)processNewConvNotification:(NSNotification *)notification
{
	eCloudNotification *_notification = [notification object];
	if(_notification != nil)
	{
		int cmdId = _notification.cmdId;
		switch (cmdId) {
            case user_logo_changed:
            {
                NSDictionary *dic = _notification.info;
                
                int empId = [[dic valueForKey:@"emp_id"]intValue];
                NSString *empLogo = [dic valueForKey:@"emp_logo"];
                
                if (self.searchDisplayController.active)
                {
                    for (int i = 0; i < self.searchResults.count; i++)
                    {
                        Emp *_emp = [self.searchResults objectAtIndex:i];
                        if (_emp.emp_id == empId)
                        {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                            [self.searchDisplayController.searchResultsTableView beginUpdates];
                            [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            [self.searchDisplayController.searchResultsTableView endUpdates];
                            break;
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < self.itemArray.count; i++)
                    {
                        id _id = [self.itemArray objectAtIndex:i];
                        if ([_id isKindOfClass:[Dept class]])
                        {
                            break;
                        }
                        else if ([_id isKindOfClass:[Emp class]]) {
                            Emp *_emp = (Emp *)_id;
                            if (_emp.emp_id == empId)
                            {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                                [orgTable beginUpdates];
                                [orgTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                [orgTable endUpdates];
                                break;
                            }
                        }
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)addObserver
{
    //    add by shisp 接收用户状态修改通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(empStatusChange:) name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];

    //    update by shisp 当和会话列表相关的表有更新时，会发出通知，在这里接收通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];

}

- (void)removeObserver
{
    //    取消用户状态修改通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NEW_CONVERSATION_NOTIFICATION object:nil];
}

//tableview左滑手势冲突解决
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
//        return YES;
//    }
//    return NO;
//}


-(BOOL)canLeftSlideByIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemArray.count >0 && indexPath.row < self.itemArray.count) {
        id temp=[self.itemArray objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[Dept class]]) {
            
            Dept *tempDept = (Dept*) temp;
            
            //如果是常用部门 只有顶级部门才有删除
            for(Dept *groupDept in self.deptArray){
                if (groupDept.dept_type == type_dept_common_dept) {
                    if (tempDept.dept_level == 0) {
                        return YES;
                    }else
                    {
                        return NO;
                    }
                }
            }
            
            //普通部门时 级别大于0的允许添加常用部门
            if (tempDept.dept_level >0) {
                return YES;
            }
            return NO;
            
        }
    }
    return NO;
}

#pragma mark - Private

- (void)hideMenuOptionsAnimated:(BOOL)animated
{
    __block NewOrgViewController *weakSelf = self;
    [self.cellDisplayingMenuOptions setMenuOptionsViewHidden:YES animated:animated completionHandler:^{
        weakSelf.customEditing = NO;
    }];
}

- (void)setCustomEditing:(BOOL)customEditing
{
    if (_customEditing != customEditing) {
        _customEditing = customEditing;
        orgTable.scrollEnabled = !customEditing;
        if (customEditing) {
            if (!_overlayView) {
                _overlayView = [[DAOverlayView alloc] initWithFrame:self.view.bounds];
                _overlayView.backgroundColor = [UIColor clearColor];
                _overlayView.delegate = self;
                
            }
            self.overlayView.frame = self.view.bounds;
            [self.view addSubview:_overlayView];
            
            if (self.shouldDisableUserInteractionWhileEditing) {
                for (UIView *view in orgTable.subviews) {
                    if ((view.gestureRecognizers.count == 0) && view != self.cellDisplayingMenuOptions && view != self.overlayView) {
                        view.userInteractionEnabled = NO;
                    }
                }
            }
        } else {
            self.cellDisplayingMenuOptions = nil;
            [self.overlayView removeFromSuperview];
            
            for (UIView *view in orgTable.subviews) {
                if ((view.gestureRecognizers.count == 0) && view != self.cellDisplayingMenuOptions && view != self.overlayView) {
                    view.userInteractionEnabled = YES;
                }
            }
        }
    }
}

- (void)contextMenuCellDidSelectDeleteOption:(UITableViewCell *)cell
{
    
    NSIndexPath *indexPath = [orgTable indexPathForCell:cell];
    
    Dept *tempDept = self.itemArray[indexPath.row];
    BOOL isCommonDept = [userData isCommonDept:tempDept.dept_id];
    BOOL ret = NO;
    self.removeIndexPath = indexPath;
    if (isCommonDept)
    {
        //删除
        ret = [userDataConn sendModiRequestWithDataType:user_data_type_dept andUpdateType:user_data_update_type_delete andData:[NSArray arrayWithObject:[StringUtil getStringValue:tempDept.dept_id]]];
        
    }else
    {
        //添加
        ret = [userDataConn sendModiRequestWithDataType:user_data_type_dept andUpdateType:user_data_update_type_insert andData:[NSArray arrayWithObject:[StringUtil getStringValue:tempDept.dept_id]]];
    }
    
    if (ret) {
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"me_loading_tip"]];
    }
}
- (void)contextMenuDidHideInCell:(UITableViewCell *)cell
{
    self.customEditing = NO;
    self.customEditingAnimationInProgress = NO;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

}
- (void)contextMenuDidShowInCell:(UITableViewCell *)cell
{
    self.cellDisplayingMenuOptions = cell;
    self.customEditing = YES;
    self.customEditingAnimationInProgress = NO;
    
    NSIndexPath *indexPath = [orgTable indexPathForCell:cell];
    
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    
    NewDeptCell *tempcell = (NewDeptCell *) cell;
    if ([temp isKindOfClass:[Dept class]]) {
        Dept *tempDept = (Dept*) temp;
        if ([userData isCommonDept:tempDept.dept_id]) {
            
            tempcell.deleteButtonTitle = [StringUtil getLocalizableString:@"delete_common_dept"];
        }else
        {
            tempcell.deleteButtonTitle = [StringUtil getLocalizableString:@"add_common_dept"];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)contextMenuWillHideInCell:(UITableViewCell *)cell
{
    self.customEditingAnimationInProgress = YES;
}
- (void)contextMenuWillShowInCell:(UITableViewCell *)cell
{
    self.customEditingAnimationInProgress = YES;
}

- (BOOL)shouldShowMenuOptionsViewInCell:(UITableViewCell *)cell
{
    return self.customEditing && !self.customEditingAnimationInProgress;
}


#pragma mark * DAOverlayView delegate

- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL shouldIterceptTouches = YES;
    CGPoint location = [self.view convertPoint:point fromView:view];
    CGRect rect = [orgTable convertRect:self.cellDisplayingMenuOptions.frame toView:view];
    shouldIterceptTouches = CGRectContainsPoint(rect, location);
    if (!shouldIterceptTouches) {
        
        [self hideMenuOptionsAnimated:YES];
    }
    return (shouldIterceptTouches) ? [self.cellDisplayingMenuOptions hitTest:point withEvent:event] : view;
}

#pragma mark * UITableView delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath] == self.cellDisplayingMenuOptions) {
        [self hideMenuOptionsAnimated:YES];
        return NO;
    }
    return YES;
}

//判断是删除常用部门还是添加常用部门
- (BOOL)isAddCommonDept
{
    Dept *dept = [self.itemArray objectAtIndex:self.removeIndexPath.row];
    
    if ([userData isCommonDept:dept.dept_id])
    {
        return NO;
    }
    return YES;
}

//判断是否部门
- (BOOL)isDept
{
    Dept *dept = [self.itemArray objectAtIndex:self.removeIndexPath.row];
    if ([dept isKindOfClass:[Dept class]]) {
        return YES;
    }
    return NO;
}

- (void)reCalculateFrame
{
//    NSLog(@"重新计算通讯录tableview的高度 self.view.frame is %@ searchbar frame is %@ tabbar frame is %@",NSStringFromCGRect(self.view.frame),NSStringFromCGRect(_searchBar.frame),NSStringFromCGRect(self.tabBarController.tabBar.frame));
    if (!self.searchDisplayController.isActive) {
        int tableH = SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight] - _searchBar.frame.size.height - self.tabBarController.tabBar.frame.size.height;
        orgTable.frame = CGRectMake(0.0, _searchBar.frame.size.height, self.view.frame.size.width, tableH);
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = scrollView.frame;
    if (_frame.size.height == orgTable.frame.size.height) {
        return;
    }
    _frame.size.height = orgTable.frame.size.height;
    scrollView.frame = _frame;
    
    UILabel *lineBreak = (UILabel *)[scrollView viewWithTag:100];
    _frame = lineBreak.frame;
    _frame.size.height = scrollView.frame.size.height;
    lineBreak.frame = _frame;
}

#pragma mark =============================SDK新增方法===================================
- (UIButton *)rightBarButton
{
    UIImage *image = [StringUtil getImageByResName:@"add_ios.png"];
    
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, 46, 44);
    [_button setBackgroundImage:image forState:UIControlStateNormal];
    
    return _button;
}

- (void)onRightBarButton
{
    [self addButtonPressed:nil];
}

#pragma mark ========可以根据不同公司显示不同的通讯录首页===========


- (void)prepareXIANGYUANOrgItems
{
    NSArray *tempArray = [[self class]getXIANGYUANRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}

+ (NSArray *)getXIANGYUANRootOrgItems
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSMutableArray *_array = [NSMutableArray array];
    SettingItem *_item;
    
    //    所有根部门
    NSArray *allDept = [[eCloudDAO getDatabase] getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
    
    if (allDept.count) {
        
        for (Dept *_dept in allDept) {
            
            if ([_dept.dept_name isEqualToString:@"我的电脑"]) {
                
                continue;
            }
            _item = [[[SettingItem alloc]init]autorelease];
            _item.dataObject = _dept;
            
            [_array addObject:_item];
        }
        
        [tempArray addObject:_array];
    }

    Dept *tempDept = nil;

    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_regular_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"me_ecloud_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_my_computer;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_my_computer"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    
    //    常用联系人 常用部门  临时群
    _array = [NSMutableArray array];
    
    //常联系人
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_contact;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_contacts"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    //    常用部门
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_dept;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_departments"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];

    //    常用讨论组
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_my_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getAppLocalizableString:@"me_custom_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    [tempArray addObject:_array];
    
    
    //固定群组
//    _array = [NSMutableArray array];
//    
//    tempDept = [[[Dept alloc] init]autorelease];
//    tempDept.dept_type = type_dept_regular_group;
//    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"me_ecloud_groups"]];
//    
//    _item = [[[SettingItem alloc]init]autorelease];
//    _item.dataObject = tempDept;
//    
//    [_array addObject:_item];
//    [tempArray addObject:_array];
    
    //    我的电脑
//    _array = [NSMutableArray array];
//    
//    tempDept = [[[Dept alloc] init]autorelease];
//    tempDept.dept_type = type_dept_my_computer;
//    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_my_computer"]];
//    
//    _item = [[[SettingItem alloc]init]autorelease];
//    _item.dataObject = tempDept;
//    
//    [_array addObject:_item];
    
    //[tempArray addObject:_array];
    
    return tempArray;
}
- (void)prepareCsairOrgItems
{
    NSArray *tempArray = [[self class]getCsairRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}

+ (NSArray *)getCsairRootOrgItems
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSMutableArray *_array;
    SettingItem *_item;
    
    Dept *tempDept = nil;
    
    //    我的电脑
    _array = [NSMutableArray array];
    
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_my_computer;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_my_computer"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    [tempArray addObject:_array];
    
    //    常用联系人 常用部门 固定群 临时群
    _array = [NSMutableArray array];
    
    //常联系人
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_contact;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_contacts"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    //    常用部门
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_dept;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_departments"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    //固定群组
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_regular_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getAppLocalizableString:@"me_ecloud_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    //    常用讨论组
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_my_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getAppLocalizableString:@"me_custom_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    [tempArray addObject:_array];
    
    
    //    组织架构
    _array = [NSMutableArray array];
    
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_orgization;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_my_organization"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    [tempArray addObject:_array];
    
    //    //    所有根部门
    //    NSArray *allDept = [[eCloudDAO getDatabase] getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
    //
    //    if (allDept.count) {
    //        _array = [NSMutableArray array];
    //
    //        for (Dept *_dept in allDept) {
    //
    //            _item = [[[SettingItem alloc]init]autorelease];
    //            _item.dataObject = _dept;
    //            if (_array.count == 0) {
    //                _item.headerView = [[self class] getBlankHeaderView];
    //            }
    //            [_array addObject:_item];
    //        }
    //
    //        [tempArray addObject:_array];
    //    }
    return tempArray;
}

- (void)prepareBGYOrgItems
{
    NSArray *tempArray = [[self class]getBGYRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}

+ (NSArray *)getBGYRootOrgItems
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    SettingItem *_item;
    
    Dept *tempDept = nil;
    
    
    //    所有根部门
    NSArray *allDept = [[eCloudDAO getDatabase] getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
    
    if (allDept.count) {
        
        for (Dept *_dept in allDept) {
            
            if ([_dept.dept_name isEqualToString:@"我的电脑"]) {
                
                continue;
            }
            _item = [[[SettingItem alloc]init]autorelease];
            _item.dataObject = _dept;
            if ([_dept.dept_name containsString:@"测试"])
            {
                _item.imageName = @"org_test_bloc";
            }
            else
            {
                _item.imageName = @"org_bloc";
            }
            [tempArray addObject:_item];
        }
    }
    
    
    //    我的电脑
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_my_computer;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_my_computer"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    _item.imageName = @"org_PC";
    [tempArray addObject:_item];
    
    //    常用联系人 常用部门 固定群 临时群
    
    //常联系人
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_contact;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_contacts"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    _item.imageName = @"org_contacts";
    [tempArray addObject:_item];
    
    //    常用部门
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_dept;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_departments"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    _item.imageName = @"org_department";
    [tempArray addObject:_item];
    
    
    //    常用讨论组
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_my_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getAppLocalizableString:@"me_custom_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    _item.imageName = @"org_panel";
    [tempArray addObject:_item];
    
    
    //固定群组
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_regular_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"me_ecloud_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    _item.imageName = @"org_group";
    [tempArray addObject:_item];
    
    
    return tempArray;
}

- (void)prepareOrgItems
{
    NSArray *tempArray = [[self class]getRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}

+ (NSArray *)getRootOrgItems
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSMutableArray *_array;
    SettingItem *_item;
    
    //    所有根部门
    NSArray *allDept = [[eCloudDAO getDatabase] getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
    
    if (allDept.count) {
        _array = [NSMutableArray array];
        
        for (Dept *_dept in allDept) {
            
            _item = [[[SettingItem alloc]init]autorelease];
            _item.dataObject = _dept;
            
            [_array addObject:_item];
        }
        
        [tempArray addObject:_array];
    }
    
    Dept *tempDept = nil;
    
    //    常用联系人 常用部门
    _array = [NSMutableArray array];
    
    //常联系人
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_contact;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_contacts"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    _item.headerView = [[self class] getBlankHeaderView];
    
    [_array addObject:_item];
    
    //    常用部门
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_common_dept;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_common_departments"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    [tempArray addObject:_array];
    
    //    [self getCustomGroup];
    
    //    固定群、常用讨论组
    
    _array = [NSMutableArray array];
    
    //固定群组
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_regular_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"me_ecloud_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    //    设置header view
    _item.headerHight = GROUP_SECTION_HEADER_HEIGHT;
    _item.headerView = [[self class] getHeaderViewOfGroup];
    
    [_array addObject:_item];
    
    //    常用讨论组
    tempDept = [[[Dept alloc] init]autorelease];
    tempDept.dept_type = type_dept_my_group;
    tempDept.dept_name = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_custom_groups"]];
    
    _item = [[[SettingItem alloc]init]autorelease];
    _item.dataObject = tempDept;
    
    [_array addObject:_item];
    
    [tempArray addObject:_array];
    
    return tempArray;
}
//展开部门
- (void)extendDept:(Dept *)dept
{
    [self.deptArray addObject:dept];
    [self getRootItem];
    [self refreshNaviBar];
    [orgTable reloadData];
}

//处理tableView的select事件
- (void)processTableViewDidSelect:(id)temp
{
    if([temp isKindOfClass:[Dept class]]){
        Dept *dept = (Dept *)temp;
//        dept.dept_type = type_dept_normal;
        [self extendDept:dept];
    }else if ([temp isKindOfClass:[Emp class]]){
        //打开用户资料
        if ([_conn.userId intValue]==((Emp *)temp).emp_id) {
            // [self hideTabBar];
            [[self class] openUserInfoById:_conn.userId andCurController:self];
            return;
        }
        
        if(!((Emp*)temp).permission.canSendMsg)
        {
            [PermissionUtil showAlertWhenCanNotSendMsg:(Emp*)temp];
            NSLog(@"没有给对方发消息的权限");
            return;
        }
        NSString *empIdStr = [NSString stringWithFormat:@"%i",((Emp *)temp).emp_id];
        [[self class] openUserInfoById:empIdStr andCurController:self];
    }
    else if ([temp isKindOfClass:[Conversation class]]){
        [self openConversation:temp];
    }
}

//判断是否显示通讯录首页
- (BOOL)displayRootOrg
{
    if (self.deptArray.count == 1) {
        return YES;
    }
    return NO;
}

//根据indexPath获取item
- (SettingItem *)getItemByIndexPath:(NSIndexPath *)indexPath
{
    if ([UIAdapterUtil isBGYApp])
    {
        SettingItem *_item = self.orgItemArray[indexPath.row];
        return _item;
    }
    else
    {
        NSArray *_array = self.orgItemArray[indexPath.section];
        SettingItem *_item = _array[indexPath.row];
        return _item;
    }
}

//群组section header view
+ (UIView *)getHeaderViewOfGroup
{
    UIView *headBgView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,GROUP_SECTION_HEADER_HEIGHT)];
    headBgView.backgroundColor = [UIColor clearColor];
    
    UILabel *titlelabel = [[[UILabel alloc]initWithFrame:CGRectMake([OrgSizeUtil getLeftScrollViewWidth] + 10,0.0, SCREEN_WIDTH - [OrgSizeUtil getLeftScrollViewWidth] - 10, GROUP_SECTION_HEADER_HEIGHT)]autorelease];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.numberOfLines = 2;
    titlelabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titlelabel.font = [UIFont systemFontOfSize:13.5];
    titlelabel.textColor = [UIColor colorWithRed:156.0/255 green:156.0/255 blue:156.0/255 alpha:1.0];
    titlelabel.textAlignment = UITextAlignmentLeft;
    titlelabel.text = [NSString stringWithFormat:@"\n%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"select_custom_groups_tip"]];
    [headBgView addSubview:titlelabel];
    
    return [headBgView autorelease];
}

//常用联系人section header view
+ (UIView *)getBlankHeaderView
{
    UIView *headBgView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,GROUP_SECTION_HEADER_HEIGHT)];
    headBgView.backgroundColor = [UIColor clearColor];
    return [headBgView autorelease];
}
//设置通讯录所在标签的item
- (void)setTabBarItemTitle
{
    self.tabBarItem.title = [StringUtil getLocalizableString:@"main_contacts"];
}

// 点击发起群聊
- (void)selectMenuItem1
{
    NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
    _controller.typeTag = type_create_conversation;
    
    _controller.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
    
    UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:_controller];
    
    [UIAdapterUtil presentVC:navController];
    
}

- (void)scanAction{
    
    ScannerViewController *scanner = [[ScannerViewController alloc]init];
    scanner.processType = 0;
    scanner.delegate = self;
    [self.navigationController pushViewController:scanner animated:YES];

}

- (void)selectMenuItem3{
    
    Emp *emp = [_ecloud getEmpInfoByUsercode:USERCODE_OF_FILETRANSFER];
    if (!emp) {
        return;
    }
    Conversation *conv = [[Conversation alloc] init] ;
    conv.emp = emp;
    conv.conv_id = [StringUtil getStringValue:emp.emp_id];
    conv.conv_type = singleType;
    conv.recordType = normal_conv_type;
    [contactViewController openConversation:conv andVC:self];
}
@end
