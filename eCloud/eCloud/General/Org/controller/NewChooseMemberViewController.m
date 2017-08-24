//
//  NewChooseMemberViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-10.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "NewChooseMemberViewController.h"
#import "CreateGroupDefine.h"
#import "NotificationUtil.h"
#import "OpenCtxDefine.h"

#import "SettingItem.h"

#import "eCloudUser.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "AdvancedSearchViewController.h"
#import "rankChooseViewController.h"
#import "businessChooseViewController.h"
#import "zoneChooseViewController.h"

#ifdef _BGY_FLAG_
#import "RootDeptCellARC.h"
#endif

#import "ApplicationManager.h"
#import "ForwardMsgUtil.h"

#import "ForwardingRecentViewController.h"

#import "UserDefaults.h"

#import "AppDelegate.h"

#import "NewOrgViewController.h"
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
#import "UserDisplayUtil.h"
//#import "EmpSelectCell.h"
//#import "DeptSelectCell.h"
#import "DeptCell.h"
#import "GroupSelectCell.h"
#import "UIAdapterUtil.h"

#import "PermissionUtil.h"
#import "PermissionModel.h"

#import "JsObjectCViewController.h"
#import "APPListDetailViewController.h"

#import "userInfoViewController.h"
#import "personInfoViewController.h"

#import "UserDataDAO.h"

#import "DeptInMemory.h"

#import "UserTipsUtil.h"
#import "UserDataConn.h"

#import "talkSessionUtil2.h"

#import "NewDeptSelectCell.h"
#import "NewEmpSelectCell.h"
#import "Conversation.h"
#import "NewGroupCell.h"

#import "StatusConn.h"
#import "StatusDAO.h"
#import "ConvNotification.h"

#import "chatHistoryView.h"
#import "OrgSizeUtil.h"

#import "Emp.h"
#import "Dept.h"
#import "ConvRecord.h"

#import "eCloudDefine.h"

#ifdef _GOME_FLAG_
#define BOTTOM_BAR_HEIGHT (80.0)
#else
#define BOTTOM_BAR_HEIGHT (66.0)
#endif

#define RECEIVE_MAP_VIEW_CONTROLLER @"receiveMapViewController"
#define DISMISS @"dismiss"
@interface NewChooseMemberViewController ()
{
    
}
//添加常用联系人使用到的员工id数组
@property (nonatomic,retain) NSMutableArray *commonEmpIdArray;
@property (nonatomic,retain) NSMutableArray *selectedDepts;

@property (nonatomic,retain) NSMutableArray *orgItemArray;

@end
@implementation NewChooseMemberViewController
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
//    BOOL isAdvancedSearch;
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
    
    UIScrollView *scrollView;
    BOOL isSelectAll;
    NSInteger deptEmpCount;
    
    CGPoint bottomOffset;
    UIButton *rightBtn;
    
    UIView *bottomNavibar;
    BOOL firstSearch; //首次搜索
    
	eCloudDAO *_ecloud ;
    UIScrollView *changeScrollview;
    AdvanceQueryDAO *advanceQueryDAO;
     bool isCanHundred;
    UserDataDAO *userDataDAO;
    
    UserDataConn *userDataConn;
    
//    是否需要设置已经选择的人员的状态
//    BOOL needUnselectEmp;
    
    StatusConn *_statusConn;
    StatusDAO *statusDAO;
    
    UISearchDisplayController * searchdispalyCtrl;

}
@synthesize defaultSelectedUserAccounts;

@synthesize orgItemArray;

@synthesize chooseMemberDelegate;

@synthesize isSingleSelect;

@synthesize transferFromType;

@synthesize commonEmpIdArray;
@synthesize mOldEmpDic;

@synthesize searchStr;
@synthesize searchTimer;

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

@synthesize forwardRecord;
@synthesize newConvId;
@synthesize newConvTitle;
@synthesize newConvType;

@synthesize deptNavArray;
@synthesize groupArray;
@synthesize selectedDepts;

@synthesize searchResults;

@synthesize forwardRecordsArray;
@synthesize isComeFromFileAssistant;

@synthesize contentOffSetYArray;

-(void)dealloc
{
    self.defaultSelectedUserAccounts = nil;
    
    self.orgItemArray = nil;
    
	NSLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MODIFYMEBER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];

    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    [titleview release];
    self.rankLabel = nil;
    self.bussinesslLabel = nil;

    self.newConvId = nil;
    self.newConvTitle = nil;
    
    self.forwardRecord = nil;

    self.commonEmpIdArray = nil;
    
    self.contentOffSetYArray = nil;
    
    self.mOldEmpDic = nil;
    
    self.searchStr = nil;
    self.searchTimer = nil;
    
	self.nowSelectedEmpArray=nil;
	self.oldEmpIdArray = nil;
	self.delegete = nil;
	self.itemArray = nil;
	self.employeeArray = nil;
	self.selectedDepts = nil;
    
    self.deptNavArray = nil;
    self.groupArray = nil;
    
    [self.searchResults removeAllObjects];
    self.searchResults = nil;
    
    //当前页面销毁的时候设置未选中状态
    [_conn setAllEmpNotSelect];
    [_conn setAllDeptsNotSelect];
    
	//	add by shisp 取消组织结构变动通知
	[[NSNotificationCenter defaultCenter]removeObserver:self name:ORG_NOTIFICATION object:nil];
	
	[[NSNotificationCenter defaultCenter]removeObserver:self name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NEW_CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];

    
	[super dealloc];
	
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
    }
    return self;
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
			self.employeeArray =  [NSMutableArray arrayWithArray:[_conn getAllEmpInfoArray]];
			[self getRootItem];
			[organizationalTable reloadData];
			
			break;
		case refresh_org:
		{
            [self getRootItem];
            [organizationalTable reloadData];
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
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"specialChoose_addMember_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
			break;
		case cmd_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"specialChoose_Communication_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
			break;
        case update_user_data_success:
            if (self.typeTag == type_add_common_dept) {
                [userDataDAO addCommonDept:self.selectedDepts];
            }else if (self.typeTag == type_add_common_emp){
               [userDataDAO addCommonEmp:self.commonEmpIdArray andIsDefault:NO];
            }
//            [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController dismissModalViewControllerAnimated:YES];
            break;
        case update_user_data_fail:
            if (self.typeTag == type_add_common_dept) {
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_departments_add_failure"]];
            }else if (self.typeTag == type_add_common_emp){
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"specialChoose_addCommonContacts_fail"]];
            }
            break;
        case update_user_data_timeout:
            if (self.typeTag == type_add_common_dept) {
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_departments_add_timeout"]];
            }else if (self.typeTag == type_add_common_emp){
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"specialChoose_addCommonContacts_timeout"]];
            }
            break;
        
        case create_group_success:
        {
            //              服务器端已经创建成功，本地也创建，然后提示用户是否转发
            //在本地创建群组
//            首先判断下群组是否已经存在，如果存在，那么就不用创建了
            if ([_ecloud searchConversationBy:self.newConvId] == nil)
            {
                [talkSessionUtil2 createConversation:mutiableType andConvId:self.newConvId andTitle:self.newConvTitle andCreateTime:[_conn getSCurrentTime] andConvEmpArray:self.nowSelectedEmpArray andMassTotalEmpCount:0];
                
                //		修改last_msg_id标志为0，-1表示没有创建
                [_ecloud setGroupCreateFlag:self.newConvId];
            }
           
//            群组创建成功
//            如果是转发
            if(self.typeTag == type_create_conversation)
            {
                talkSession = [talkSessionViewController getTalkSession];
                
                //	创建多人会话
                talkSession.convId = self.newConvId;
                //                在打开聊天窗口之前，先设置一个标志 需要显示 修改群组名称的按钮
                [UserDefaults saveModifyGroupNameFlag:self.newConvId];

                talkSession.titleStr = self.newConvTitle;
                talkSession.talkType = mutiableType;
                talkSession.convEmps = self.nowSelectedEmpArray;
                talkSession.needUpdateTag = 1;
                talkSession.last_msg_id = 0;
                
                [self hideAndNotifyOpenTalkSession:talkSession];
            }
            else if (self.typeTag == type_transfer_msg_create_new_conversation)
            {
                [self showTransferToGroupTips];
            }
            //                如果是添加群组成员，并且找到了可以复用的群组
            else if (self.typeTag == type_add_conv_emp)
            {
                talkSession = [talkSessionViewController getTalkSession];
                
                talkSession.convId = self.newConvId;
                //                在打开聊天窗口之前，先设置一个标志 需要显示 修改群组名称的按钮
                [UserDefaults saveModifyGroupNameFlag:self.newConvId];

                talkSession.talkType = mutiableType;
                talkSession.titleStr = self.newConvTitle;
                talkSession.convEmps = self.nowSelectedEmpArray;
                talkSession.needUpdateTag = 1;
                [talkSession refresh];
                
                chatMessageViewController *chatMessage = (chatMessageViewController *)(self.delegete);
                chatMessage.convId = self.newConvId;
                
                chatMessage.start_Delete = NO;
                chatMessage.dataArray= self.nowSelectedEmpArray;//talkSession.convEmps;
                chatMessage.talkType = mutiableType;
                chatMessage.titleStr = self.newConvTitle;
                [chatMessage showMemberScrollow];
                //	[self.navigationController popViewControllerAnimated:YES];
                [self.navigationController dismissModalViewControllerAnimated:YES];
            }
        }
        break;
		case create_group_timeout:
		{
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"group_creat_group_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            [alertView release];
		}
        break;
        case create_group_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"group_creat_group_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        break;

		default:
			break;
	}
}
-(void)highButtonPressed:(id)sender
{
    advancedSearch=[[AdvancedSearchViewController alloc]init];
    advancedSearch.delegete=self;
    self.isAdvancedSearch=YES;
    [self.navigationController pushViewController:advancedSearch animated:YES];
    [advancedSearch release];
}
-(void)chooseButtonPressed:(id)sender
{
//    leftButton.hidden=NO;
    self.title=[StringUtil getLocalizableString:@"specialChoose_filter"];
    self.isAdvancedSearch=YES;
    [searchTextView resignFirstResponder];
     backgroudButton.hidden=YES;
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
    
    changeScrollview.contentOffset=CGPointMake(self.view.frame.size.width, 0);
    
    
}
-(void)toLeftPressed:(id)sender
{
//    leftButton.hidden=YES;
    self.title=[StringUtil getLocalizableString:@"specialChoose_choose_contacts"];
    
    self.isAdvancedSearch=NO;
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
    self.bussinesslLabel.text=[StringUtil getLocalizableString:@"specialChoose_business"];
    self.rankLabel.text=[StringUtil getLocalizableString:@"specialChoose_level"];
    self.rank_list_str=nil;
    self.business_list_str=nil;
    [chooseTable reloadData];
    
}

- (void)initSubView
{
//    _searchbar放到scrollView中时 在ipad上无法正常运行，因此基础版本要把searchBar放到self.view中
//    只有南航需要一呼万应的功能
    if ([UIAdapterUtil isCsairApp]) {
        
        float searchBarW = self.view.frame.size.width;
        float searchBarH = 44;
        if (isCanHundred) {
            searchBarW = searchBarW - 55;
        }
        
        //初始化 searchBar
        [self initSearchBarWithFrame:CGRectMake(0, 0, searchBarW, searchBarH)];
        
        //	组织架构展示table
        int tableH = self.view.frame.size.height-20 - 84 - 44;
        if (!IOS7_OR_LATER) {
            tableH += 20;
        }
        
        changeScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, tableH+84)];
        changeScrollview.scrollsToTop = NO;
        changeScrollview.showsHorizontalScrollIndicator = YES;
        changeScrollview.showsVerticalScrollIndicator = YES;
        changeScrollview.userInteractionEnabled = YES;
        changeScrollview.backgroundColor = [UIColor clearColor];
        changeScrollview.autoresizingMask = self.view.autoresizingMask;
        [self.view addSubview:changeScrollview];
        [changeScrollview release];
        
        //    把searchbar 加到 view中
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.backgroundImage = nil;
        [changeScrollview addSubview:_searchBar];
        
        organizationalTable= [[UITableView alloc] initWithFrame:CGRectMake(0, _searchBar.frame.size.height, _searchBar.frame.size.width, tableH-20.0-4.0) style:UITableViewStylePlain];  //调整searchbar不挡住table后 －6
        [organizationalTable setDelegate:self];
        [organizationalTable setDataSource:self];
        organizationalTable.backgroundColor=[UIColor clearColor];
        [changeScrollview addSubview:organizationalTable];
        [organizationalTable release];
        
        if (isCanHundred) {
            //        宽度是searchBar余下的，高度和searchBar相同
            UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            chooseButton.frame = CGRectMake(searchBarW, 0, 55, searchBarH);
            [chooseButton addTarget:self action:@selector(chooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            chooseButton.backgroundColor = [UIAdapterUtil getSearchBarColor];
            if (IOS7_OR_LATER) {
                chooseButton.layer.borderWidth = 1.0;
                chooseButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            }
            
            //        NSLog(@"%@,%@,%@,%@",_searchBar.backgroundImage,_searchBar.backgroundColor,_searchBar.tintColor,_searchBar.barTintColor);
            
            //        增加一个title
            UILabel *buttontitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, searchBarH)];
            buttontitle.text=[StringUtil getLocalizableString:@"specialChoose_filter"];
            buttontitle.textAlignment = NSTextAlignmentCenter;
            buttontitle.font=[UIFont systemFontOfSize:14];
            buttontitle.textColor=[UIColor whiteColor];
            buttontitle.backgroundColor=[UIColor clearColor];
            
            //       增加一条竖线
            UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1, searchBarH+4)];
            lineimage.image=[StringUtil getImageByResName:@"line_left.png"];
            [buttontitle addSubview:lineimage];
            [lineimage release];
            
            UIImageView *rightimage=[[UIImageView alloc]initWithFrame:CGRectMake(40,(searchBarH - 15)/2, 15, 15)];
            rightimage.image=[StringUtil getImageByResName:@"small_right.png"];
            [buttontitle addSubview:rightimage];
            [rightimage release];
            
            [chooseButton addSubview:buttontitle];
            
            [buttontitle release];
            //[chooseButton setTitle:@"筛选" forState:UIControlStateNormal];
            [changeScrollview addSubview:chooseButton];
        }
        
        //-------筛选－－－－－－－
        self.zoneArray = [NSMutableArray array];
        advanceQueryDAO = [AdvanceQueryDAO getDataBase];
        self.chooseArray= [NSMutableArray array];
        
        //    leftButton = [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"specialChoose_contacts"] andTarget:self andSelector:@selector(toLeftPressed:)];
        //    leftButton.hidden=YES;
        
        
        chooseTable= [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, tableH+40) style:UITableViewStylePlain];
        [chooseTable setDelegate:self];
        [chooseTable setDataSource:self];
        chooseTable.scrollsToTop = NO;
        chooseTable.backgroundColor=[UIColor clearColor];
        [changeScrollview addSubview:chooseTable];
        [chooseTable release];
        
        self.rankLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 20)];
        self.rankLabel.backgroundColor=[UIColor clearColor];
        self.rankLabel.font=[UIFont systemFontOfSize:14];
        self.rankLabel.textColor=[UIColor blackColor];
        
        self.bussinesslLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 20)];
        self.bussinesslLabel.backgroundColor=[UIColor clearColor];
        self.bussinesslLabel.font=[UIFont systemFontOfSize:14];
        self.bussinesslLabel.textColor=[UIColor blackColor];
        
        self.bussinesslLabel.text=[StringUtil getLocalizableString:@"specialChoose_business"];
        self.rankLabel.text=[StringUtil getLocalizableString:@"specialChoose_level"];
        
        titleview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        titleview.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
        
        UIButton *titleButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        [titleButton setImage:[StringUtil getImageByResName:@"sereach_up.png"] forState:UIControlStateNormal];
        titleButton.backgroundColor=[UIColor lightGrayColor];
        titleButton.tag=1;
        [titleButton addTarget:self action:@selector(expendAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILabel *taglabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 40,100 , 20)];
        taglabel.text=[StringUtil getLocalizableString:@"specialChoose_filter_results"];
        taglabel.backgroundColor=[UIColor clearColor];
        taglabel.font=[UIFont systemFontOfSize:14];
        
        numlabel=[[UILabel alloc]initWithFrame:CGRectMake(210, 40,100, 20)];
        numlabel.textAlignment=NSTextAlignmentCenter;
        numlabel.backgroundColor=[UIColor clearColor];
        numlabel.font=[UIFont systemFontOfSize:14];
        
        titleview.layer.masksToBounds=YES;
        
        [titleview addSubview:titleButton];
        [titleButton release];
        
        [titleview addSubview:taglabel];
        [taglabel release];
        
        [titleview addSubview:numlabel];
        [numlabel release];
        
//
//        
//        UIButton *titleButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
//        [titleButton setImage:[StringUtil getImageByResName:@"sereach_up.png"] forState:UIControlStateNormal];
//        titleButton.backgroundColor=[UIColor lightGrayColor];
//        titleButton.tag=1;
//        [titleButton addTarget:self action:@selector(expendAction:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UILabel *taglabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 40,100 , 20)];
//        taglabel.text=[StringUtil getLocalizableString:@"specialChoose_filter_results"];
//        taglabel.backgroundColor=[UIColor clearColor];
//        taglabel.font=[UIFont systemFontOfSize:14];
//        
//        numlabel=[[UILabel alloc]initWithFrame:CGRectMake(210, 40,100, 20)];
//        numlabel.textAlignment=NSTextAlignmentCenter;
//        numlabel.backgroundColor=[UIColor clearColor];
//        numlabel.font=[UIFont systemFontOfSize:14];
//        
//        titleview.layer.masksToBounds=YES;
//        
//        [titleview addSubview:titleButton];
//        [titleButton release];
//        
//        [titleview addSubview:taglabel];
//        [taglabel release];
//        
//        [titleview addSubview:numlabel];
//        [numlabel release];
//        
//        titleview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
//        titleview.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];


    }else{
        
        [self initAndAddSearchBar];
        
        //	组织架构展示table
        int tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - _searchBar.frame.size.height - BOTTOM_BAR_HEIGHT;
        
        organizationalTable= [[UITableView alloc] initWithFrame:CGRectMake(0, _searchBar.frame.size.height, _searchBar.frame.size.width, tableH) style:UITableViewStylePlain];  //调整searchbar不挡住table后 －6
        [UIAdapterUtil setPropertyOfTableView:organizationalTable];
        [organizationalTable setDelegate:self];
        [organizationalTable setDataSource:self];
        organizationalTable.backgroundColor=[UIColor clearColor];
        [self.view addSubview:organizationalTable];
        [organizationalTable release];

    }
    
    [self addLeftNavigationBar];
    [self addBottomBar];
    [self addBackGround];
    
    [UIAdapterUtil setExtraCellLineHidden:organizationalTable];
    [UIAdapterUtil setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
    
    
    NSNumber *conttentOffSetY = self.contentOffSetYArray[self.deptNavArray.count - 1];
    CGPoint point = CGPointMake(0, [conttentOffSetY doubleValue]);
    organizationalTable.contentOffset = point;
    NSLog(@"contentOffsetY = %@",conttentOffSetY);

}
- (void)addBackGround
{
    backgroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, _searchBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - _searchBar.frame.size.height - BOTTOM_BAR_HEIGHT)];
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    backgroudButton.autoresizingMask = organizationalTable.autoresizingMask;
    [self.view addSubview:backgroudButton];
    [backgroudButton release];
    backgroudButton.hidden=YES;

    backgroudButton.backgroundColor = [UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:0.5];
}

- (void)viewDidLoad
{
    NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
    _conn = [conn getConn];
    _ecloud = [eCloudDAO getDatabase];
    _statusConn = [StatusConn getConn];
    statusDAO = [StatusDAO getDatabase];
    userDataDAO = [UserDataDAO getDatabase];
    userDataConn = [UserDataConn getConn];
    
    self.itemArray = [NSMutableArray array];
    self.groupArray = [NSMutableArray array];
    self.typeArray=[_ecloud getTypeArray];
    
    isSelectAll = NO;
    isSearch=NO;
    isExpand=YES;
    isNeedSearchAgain=NO;
    isDetailAction=NO;
    firstSearch = YES;
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    self.title=[StringUtil getLocalizableString:@"specialChoose_choose_contacts"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:) andDisplayLeftButtonImage:NO];
    
    if (self.typeTag != type_add_common_dept){
        rightBtn = [UIAdapterUtil setRightButtonItemWithTitle:nil andTarget:self andSelector:@selector(selectAllBtnPressed:)];
        [self setSelectAllBtn:rightBtn];
    }
    else{
        self.title= [StringUtil getLocalizableString:@"me_common_departments_select_title"];
    }
    
    [self getRootItem];
    

//
    [self initSubView];
    
//    [self getRootItem];
    
    [self addObservers];
}

- (void)addObservers
{
    //	add by shisp  注册组织架构信息变动通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
    
    //    update by shisp 当和会话列表相关的表有更新时，会发出通知，在这里接收通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];
    
    //    add by shisp 接收用户状态修改通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(empStatusChange:) name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];
    
    //	接收分组成员修改通知
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleCmd:)
                                                name:MODIFYMEBER_NOTIFICATION
                                              object:nil];
    //	分组成员修改 超时通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
}

- (void)addBottomBar{
    //自定义底部导航栏
    int toolbarY = self.view.frame.size.height - 44-44;
    if (IOS7_OR_LATER)
    {
        toolbarY = toolbarY - 20;
    }
    
    toolbarY = (SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT) - BOTTOM_BAR_HEIGHT;// _searchBar.frame.size.height + organizationalTable.frame.size.height;
    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY, self.view.frame.size.width, BOTTOM_BAR_HEIGHT)];
    
//    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY-21, self.view.frame.size.width, 66.0)];
    bottomNavibar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    //分割线
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, bottomNavibar.frame.size.width, 1.0)];
    lineLab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
    [bottomNavibar addSubview:lineLab];
    [lineLab release];

    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    float btnWidth = 60;
    float btnHeight = 35;
    addButton.frame = CGRectMake(SCREEN_WIDTH - btnWidth - 10, (BOTTOM_BAR_HEIGHT - btnHeight) * 0.5, btnWidth, btnHeight);
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:addButton];
    addButton.enabled=NO;
    addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [addButton setTitle:[StringUtil getLocalizableString:@"confirm"] forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    addButton.layer.cornerRadius = 3.0;

#if defined(_GOME_FLAG_)
    addButton.backgroundColor = GOME_BLUE_COLOR;
#elif defined(_LANGUANG_FLAG_)
//    白底，字和边框颜色是0088c8
    addButton.backgroundColor = [UIColor whiteColor];
    addButton.layer.borderWidth = 1.0;
    addButton.layer.borderColor = [UIColor colorWithRed:0 green:0x88/255.0 blue:0xc8/255.0 alpha:1].CGColor;
    [addButton setTitleColor:[UIColor colorWithRed:0 green:0x88/255.0 blue:0xc8/255.0 alpha:1] forState:UIControlStateNormal];
#else
//    49 93 155 深蓝色
    addButton.backgroundColor = [UIColor colorWithRed:49/255.0 green:93/255.0 blue:155/255.0 alpha:1];
#endif
    
    bottomScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - addButton.frame.size.width - 20, BOTTOM_BAR_HEIGHT)];
    bottomScrollview.scrollsToTop = NO;
    bottomScrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [bottomNavibar addSubview:bottomScrollview];
    bottomScrollview.pagingEnabled = NO;
    bottomScrollview.showsHorizontalScrollIndicator = YES;
    bottomScrollview.showsVerticalScrollIndicator = YES;
    [bottomScrollview release];
    
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
    
    if (self.rank_list_str==nil&&self.business_list_str==nil&&city_list_str==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"specialChoose_no_choose_filter_condition"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    isNeedSearchAgain=NO;
    // self.chooseArray=[advanceQueryDAO getChooseArrayByRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    [advanceQueryDAO createTempDepts:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    self.chooseArray=[advanceQueryDAO getTempDeptInfoWithLevel:@"0" andLevel:0 andSelected:false];
    int num=[advanceQueryDAO getAllNumFromResult:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    numlabel.text=[NSString stringWithFormat:@"%d",num];
    [chooseTable reloadData];
  
    
}

-(void)bottomScrollviewShow
{
//    首先删除已有的view
    for(UIView *view in [bottomScrollview subviews])
    {
        [view removeFromSuperview];
        view = nil;
    }
    
//    设置确定按钮
    NSMutableArray *selectArray = [NSMutableArray arrayWithArray:self.nowSelectedEmpArray];
    
    //    确定按钮
    if ([selectArray count]==0) {
        addButton.enabled=NO;
        [addButton setTitle:[StringUtil getLocalizableString:@"confirm"] forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        
    }else
    {
        addButton.enabled=YES;
//    蓝光要求不显示用户自己
        int _count = (int)selectArray.count;
       
#ifdef _LANGUANG_FLAG_
        Emp *_emp = selectArray[0];
        if (_emp.emp_id == _conn.curUser.emp_id) {
            _count--;
        }
        NSString *titlestr=[NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"confirm"],_count];
        if (_count == 0) {
            titlestr = [StringUtil getLocalizableString:@"confirm"];
        }
#else
        NSString *titlestr=[NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"confirm"],_count];
   
#endif
        [addButton setTitle:titlestr forState:UIControlStateNormal];
        if ([UIAdapterUtil isGOMEApp]) {
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
        }else{
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
            if ([selectArray count]>80) {
                addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
            }
        }
    }
    
//    头像的显示frame
//    头像高度固定
    float iconHeight = 40;

    //    默认头像的尺寸
    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
//    计算出头像显示的宽度
    float iconWidth = (iconHeight * _size.width) / _size.height;

//    头像两边的空白是5
    float iconViewSpace = 5;
    if ([UIAdapterUtil isGOMEApp]) {
        iconViewSpace = 10;
    }
    
    float iconViewX = 5;
    float iconViewY = 0; // 需要计算 要和名字一起居中放在parentView中
    
    //    用户名字label 也 放在parentView中 比图标宽了6像素
    float nameLabelWidth = iconWidth + 6;
//    因为nameLableHeight已经定义了，所以这里可以直接使用
//    float nameLabelHeight = 20;//固定值
    float nameLabelX = 2;//因为比头像宽，所以x值要小一些，文字要居中对齐
    float nameLabelY = 0;//需要计算 要在iconview的y值基础上再加上iconview的高度

    
//    头像和label放在一个父view里，再把这个父view放到scrollview中，这个父view的高度和scrollview保持一致；在父view中的位置的x值是不断变化的，头像的宽度 再加上两边的间隔5，就是父view的宽度了
    float parentViewWidth = iconWidth + 2 *  iconViewSpace;
    float parentViewHeight = bottomScrollview.frame.size.height;
    float parentViewY = 0;//固定值
    float parentViewX = 0;//需要计算，每个view都不一样
    
//   scrollView的宽度是所以parentView的宽度加起来
    
    for (int i=0; i<[selectArray count]; i++)
    {
//        计算父view x值
        parentViewX = i * parentViewWidth;
        UIView *parentView = [[UIView alloc]initWithFrame:CGRectMake(parentViewX, parentViewY, parentViewWidth, parentViewHeight)];
        
//        计算头像y值
        iconViewY = (parentViewHeight - (iconHeight + nameLabelHeight)) / 2;
        UIButton *iconbutton = [[UIButton alloc]initWithFrame:CGRectMake(iconViewX,iconViewY,iconWidth,iconHeight)];
        
        Emp *emp = [selectArray objectAtIndex:i];
        
        UIImage *image = [self getEmpLogo:emp];

        UIImageView *logo = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, iconbutton.bounds.size.width, iconbutton.bounds.size.height)]autorelease];
        [UIAdapterUtil setCornerPropertyOfView:logo];
        logo.image = image;
        [iconbutton addSubview:logo];

        iconbutton.tag=i;
        
        iconbutton.backgroundColor=[UIColor clearColor];
        [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
        
        [parentView addSubview:iconbutton];
        [iconbutton release];
        
//        计算nameY值
        nameLabelY = iconbutton.frame.origin.y + iconbutton.frame.size.height;
        
        UILabel* nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabelX, nameLabelY , nameLabelWidth, nameLabelHeight)];
        nameLabel.text=emp.emp_name;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment=UITextAlignmentCenter;
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        nameLabel.font=[UIFont boldSystemFontOfSize:12];
        [parentView addSubview:nameLabel];
        [nameLabel release];
        
#ifdef _LANGUANG_FLAG_
        /** 蓝光要求不显示自己 */
        if (emp.emp_id == _conn.curUser.emp_id) {
            parentView.hidden = YES;
        }
#endif
        
        [bottomScrollview addSubview:parentView];
        
//        [parentView setBackgroundColor:[UIColor blueColor]];
        [parentView release];
    }
    
//    bottomScrollview.backgroundColor = [UIColor redColor];
    
//    scrollView的宽度需要计算
    float scrollViewContentWidth = parentViewWidth * selectArray.count;
    
    bottomScrollview.contentSize = CGSizeMake(scrollViewContentWidth,bottomScrollview.frame.size.height);
    bottomOffset = CGPointMake(bottomScrollview.contentSize.width - bottomScrollview.frame.size.width,0);
    [bottomScrollview setContentOffset:bottomOffset animated:NO];
}

-(void)iconbuttonAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    Emp *emp=[self.nowSelectedEmpArray objectAtIndex:index];
    
    
    if (_conn.userId) {
        if (emp.emp_id == _conn.userId.intValue)
        {
//            如果是用户自己则不能删除
            return;
        }
    }
    
    
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
    
    if ([self.searchResults count]) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    
    //    显示在底部
    [self bottomScrollviewShow];
    
    [self refreshSelectBtn];
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
			image=img;
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
-(void)keepAdvancedSearchView
{
    changeScrollview.contentOffset=CGPointMake(self.view.frame.size.width, 0);
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processGetUserInfo:) name:GETUSERINFO_NOTIFICATION object:nil];

    
    //    add by shisp 接收用户状态修改通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(empStatusChange:) name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];

    maxGroupNum = _conn.maxGroupMember;
  
    [[eCloudUser getDatabase]getPurviewValue];
    isCanHundred=[[eCloudUser getDatabase]isCanHundred];
    [bottomScrollview setContentOffset:bottomOffset animated:NO];
    
//    CGPoint point =  bottomScrollview.contentOffset;
    
    if (isDetailAction) {
        isDetailAction=NO;
        return;
    }
    
    if (self.isAdvancedSearch) {//高级搜索返回
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
        if (isNeedSearchAgain&&(self.rank_list_str!=nil||self.business_list_str!=nil||city_list_str!=nil)) {
            
            [self resultPressed:nil];
            
        }
        if (bottomScrollview!=nil) {
            [self bottomScrollviewShow];
        }
        
        [self performSelector:@selector(keepAdvancedSearchView) withObject:nil afterDelay:0.1];
        [chooseTable reloadData];
        return;
    }
    
    isSearch=NO;
    /** 华夏幸福 和 正荣 不能选择的人员通过参数传过来 */
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    
#else
    self.oldEmpIdArray = [NSMutableArray array];
#endif

	self.nowSelectedEmpArray = [NSMutableArray array];
    
    if (_conn==nil) {
        _conn = [conn getConn];
    }
	if(self.typeTag == type_create_conversation || self.typeTag == type_add_miliao_conv ||self.typeTag == type_LG_news_share)
	{
        if (_conn.curUser) {
//            万达需求 人数提示不正确 如果是创建会话，那么应该把自己先添加进来
            [self.nowSelectedEmpArray addObject:_conn.curUser];
//            [self.oldEmpIdArray addObject:_conn.curUser];
        }
        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];

 	}
    else if(self.typeTag == type_transfer_msg_create_new_conversation)
    {
//        wanda需求 默认包含自己
        if (_conn.curUser) {
            [self.nowSelectedEmpArray addObject:_conn.curUser];
//            [self.oldEmpIdArray addObject:_conn.curUser];
        }
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];

    }
	else if(self.typeTag == type_add_conv_emp)
	{
		[self.oldEmpIdArray addObjectsFromArray:((chatMessageViewController*)(self.delegete)).dataArray];
        
        if (((chatMessageViewController*)(self.delegete)).talkType == singleType) {
//            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
        }
	}
    else if(self.typeTag == type_app_open_contacts){
        //html5 邀请并发起会话,默认把自己加入到会话，把已经选择的用户加入到已选数组
        if (_conn.curUser) {
            [self.oldEmpIdArray addObject:_conn.curUser];            
        }
        [self.nowSelectedEmpArray addObjectsFromArray:((APPListDetailViewController*)(self.delegete)).dataArray];
    }
    else if(self.typeTag == type_schedule)
    {
        [self.oldEmpIdArray addObjectsFromArray: ((addScheduleViewController*)self.delegete).dataArray];
    }
    else if(self.typeTag == type_add_common_emp)
    {
//        那么已经是常用联系人的和缺省常用联系人的，要排除在外
//        需要设置最大联系人数量
        maxGroupNum = ROAMINGDATA_FRE_CON;
        NSArray *commonEmps = [userDataDAO getAllCommonEmp];
        self.oldEmpIdArray = [NSMutableArray arrayWithArray:commonEmps];
        if (_conn.curUser) {
            [self.oldEmpIdArray addObject:_conn.curUser];
        }
    }else if (self.typeTag == type_app_select_contacts){
//什么也不做 可能是单选 也可能是多选
        NSLog(@"龙湖轻应用选择联系人接口，不需要把自己加到已选择联系人中");
        if (self.defaultSelectedUserAccounts.length) {
            NSArray *defaultSelected = [self.defaultSelectedUserAccounts componentsSeparatedByString:@","];
            if (defaultSelected.count) {
                for (NSString *empCode in defaultSelected) {
                    Emp *_emp = [_conn getEmpByEmpCode:empCode];
                    if (!_emp) {
                        [LogUtil debug:[NSString stringWithFormat:@"%s 用户没找到 账号为%@",__FUNCTION__,empCode]];
                    }else{
                        [self.nowSelectedEmpArray addObject:_emp];
                        _emp.isSelected = YES;
                    }
                }
            }
        }
    }else if (self.typeTag == type_app_select_contact_gome){
//        什么都不做
    }
    
    self.mOldEmpDic = [NSMutableDictionary dictionaryWithCapacity:self.oldEmpIdArray.count];
    for (Emp *_emp in self.oldEmpIdArray) {
        [self.mOldEmpDic setObject:_emp forKey:[StringUtil getStringValue:_emp.emp_id]];
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
	//maxGroupNum = 80;// 80;
	
	NSLog(@"本次选中的最多人数为%d",(maxGroupNum - self.oldEmpIdArray.count));
    //	if(_conn.isFirstGetUserDeptList)
    //	{
    //		[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
    //		[[LCLLoadingView currentIndicator]show];
    //	}
	
//    update by shisp typetag为4时，应用平台中已经选择了一部分人员，所以不能设置为未选中
//    if (self.typeTag != type_app_create_conversation) {
//        [_conn setAllEmpNotSelect];
//    }
	
	self.employeeArray =  [NSMutableArray arrayWithArray:[_conn getAllEmpInfoArray]];
    self.typeArray=[_ecloud getTypeArray];
	//	如果原来是查询状态，那么维持之前的状态
	[self getRootItem];
	[organizationalTable reloadData];
    
    //	接收分组成员修改通知
//    [[NSNotificationCenter defaultCenter]addObserver:self
//											selector:@selector(handleCmd:)
//												name:MODIFYMEBER_NOTIFICATION
//											  object:nil];
    //	分组成员修改 超时通知
//	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];

//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    
    if (bottomScrollview!=nil) {
        [self bottomScrollviewShow];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];

    //    取消用户状态修改通知
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];

//    if (needUnselectEmp) {
////        for (Emp *_emp in self.nowSelectedEmpArray) {
////            _emp.isSelected = false;
////        }
//        [_conn setAllEmpNotSelect];
//        [_conn setAllDeptsNotSelect];
//    }
// update by shisp
    //    if (!isAdvancedSearch) {//不是 高级搜索返回
//        _searchBar.text = @"";
//    }
    [_searchBar resignFirstResponder];
     backgroudButton.hidden=YES;

//    [[NSNotificationCenter defaultCenter]removeObserver:self name:MODIFYMEBER_NOTIFICATION object:nil];
//	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    
    [bottomScrollview setContentOffset:bottomOffset animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)getRootItem
{
//    默认deptEmpCount为0 这样可以控制全选按钮不显示
    deptEmpCount = 0;
    if ([self displayRootOrg]) {
        
#ifdef _XIANGYUAN_FLAG_
      
        [self prepareLANGUANGItems];
        
#else
        
        //获取根部门
        if ([UIAdapterUtil isCsairApp]) {
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
            }
//    if ([self.deptNavArray count] < 2) {
//        //根据公司id和上级部门id，获取直接子部门
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//        NSMutableArray *allDept = [NSMutableArray arrayWithArray:[_ecloud getLocalNextDeptInfoWithSelected:@"0" andLevel:0 andSelected:false]];
//        deptEmpCount = 0;
//        [self.itemArray removeAllObjects];
//        [self.itemArray addObjectsFromArray:allDept];
//        [self getCustomGroup];
//        [pool release];
//    }
    else{
        id temp = [self.deptNavArray lastObject];
        if (self.typeTag ==type_add_common_dept) {
            //常联系部门
            if ([temp isKindOfClass:[Dept class]]) {
                Dept *dept = (Dept *)temp;
                int level=dept.dept_level+1;
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked];
                
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
                [allArray addObjectsFromArray:tempDeptArray];
                [pool release];
                
                if ([allArray count]) {
                    [self.itemArray removeAllObjects];
                    [self.itemArray addObjectsFromArray:allArray];
                }
                else{
                    [self.deptNavArray removeLastObject];
                }
                [allArray release];
            }
        }
        else{
            //获取子部门
            if ([temp isKindOfClass:[Dept class]]) {
                Dept *dept = (Dept *)temp;
                int level=dept.dept_level+1;
                switch (dept.dept_type) {
                    case type_dept_normal:
                    {
                        //普通部门
                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                        NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked];
                        NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id  andLevel:level];
                        
                        //                    add by shisp 如果本部门有员工，那么获取这个部门的人员状态
                        if (tempEpArray.count > 0)
                        {
                            if ([statusDAO needGetStatus:[StringUtil getStringValue:dept.dept_id] andType:status_type_dept])
                            {
                                [_statusConn getDeptStatus:dept.dept_id];
                            }
                        }
                        
                        Dept *dept1;
                        Dept *dept2;
                        for (int i=0; i<[tempDeptArray count]; i++) {
                            dept1=[tempDeptArray objectAtIndex:i];
                            DeptInMemory *_dept = [_conn getDeptInMemoryByDeptId:dept1.dept_id];
                            if (_dept) {
                                dept1.isChecked = _dept.isChecked;
                            }
                        }
                        
                        deptEmpCount = [tempEpArray count];
                        NSMutableArray *allArray=[[NSMutableArray alloc]init];
                        [allArray addObjectsFromArray:tempEpArray];
                        [allArray addObjectsFromArray:tempDeptArray];
                        [pool release];
                        
                        [self.itemArray removeAllObjects];
                        [self.itemArray addObjectsFromArray:allArray];
                        [allArray release];
                    }
                        break;
                    case type_dept_common_contact:
                    {
                        //常联系人
                        NSArray *tempEpArray = [userDataDAO getAllCommonEmp];
                        deptEmpCount = [tempEpArray count];
                        Emp *tempEmp;
                        Emp *tempEmp1;
                        for (int i = 0; i < deptEmpCount ; i ++) {
                            tempEmp=[tempEpArray objectAtIndex:i];
                            tempEmp1 = [self getEmpInSelectArrayByEmptId:tempEmp.emp_id];
                            if (tempEmp1) {
                                tempEmp.isSelected = tempEmp1.isSelected;
                            }
                        }
                        
                        [self.itemArray removeAllObjects];
                        [self.itemArray addObjectsFromArray:tempEpArray];
                    }
                        break;
                    case type_dept_common_dept:
                    {
                        //常用部门
                        NSArray *tempDeptArray = [userDataDAO getAllCommonDept];
                        [self.itemArray removeAllObjects];
                        [self.itemArray addObjectsFromArray:tempDeptArray];
                    }
                        break;
                    case type_dept_my_group:
                    {
                        //我的群组
                        NSArray *tempDeptArray = [userDataDAO getALlCommonGroup];
                        [self.itemArray removeAllObjects];
                        [self.itemArray addObjectsFromArray:tempDeptArray];
                    }
                        break;
                    case type_dept_regular_group:
                    {
                        //固定群组
                        NSArray *tempDeptArray = [userDataDAO getALlSystemGroup];
                        [self.itemArray removeAllObjects];
                        [self.itemArray addObjectsFromArray:tempDeptArray];
                    }
                        break;
                    case type_dept_my_computer:
                    {
                        [self.itemArray removeAllObjects];
                        Emp *emp = [_ecloud getEmpInfoByUsercode:USERCODE_OF_FILETRANSFER];
                        if (emp) {
                            Emp *temp = [self getEmpInSelectArrayByEmptId:emp.emp_id];
                            if (temp) {
                                emp.isSelected = YES;
                            }
                            
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
            else if ([temp isKindOfClass:[Conversation class]]) {
                //获取群组成员
                Conversation *conv = (Conversation *)temp;
                NSArray *tempEpArray = [_ecloud getAllConvEmpBy:conv.conv_id];
                deptEmpCount = [tempEpArray count];
                Emp *tempEmp;
                Emp *tempEmp1;
                for (int i = 0; i < deptEmpCount ; i ++) {
                    tempEmp=[tempEpArray objectAtIndex:i];
                    tempEmp1 = [self getEmpInSelectArrayByEmptId:tempEmp.emp_id];
                    if (tempEmp1) {
                        tempEmp.isSelected = tempEmp1.isSelected;
                    }
                }
                
                [self.itemArray removeAllObjects];
                [self.itemArray addObjectsFromArray:tempEpArray];
            }
        }
    }
    
    isSearch=NO;
    isSelectAll = [self isCurrentEmpsSelected];
    
    if (deptEmpCount && !isSingleSelect) {
        rightBtn.hidden = NO;
    }
    else{
        rightBtn.hidden = YES;
    }
}

- (Emp *)getEmpInSelectArrayByEmptId:(int)empid{
    for (Emp *tempEmp in self.nowSelectedEmpArray) {
        if (tempEmp.emp_id == empid) {
            return tempEmp;
        }
    }
    return nil;
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

//    update by shisp 先显示固定群组，再显示常用讨论组
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

#pragma mark - 添加组织架构导航栏
- (void)addLeftNavigationBar{
    if (!self.deptNavArray) {
        //根部门
        Dept *rootDept = [[Dept alloc] init];
        rootDept.dept_id = 0;
        rootDept.dept_level = 0;
        rootDept.dept_name = [StringUtil getLocalizableString:@"main_contacts"];
        self.deptNavArray = [NSMutableArray arrayWithObject:rootDept];
        [rootDept release];
    }
    
    float heigh = organizationalTable.frame.size.height;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, organizationalTable.frame.origin.y, [OrgSizeUtil getLeftScrollViewWidth], heigh)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.scrollsToTop = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake([OrgSizeUtil getLeftScrollViewWidth], ([OrgSizeUtil getLeftScrollViewHeight]+1)*[self.deptNavArray count]);
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    [scrollView release];

    [self refreshNaviBar];
}

- (void)refreshNaviBar{
    if (!self.deptNavArray) {
        //根部门
        Dept *rootDept = [[Dept alloc] init];
        rootDept.dept_id = 0;
        rootDept.dept_level = 0;
        self.deptNavArray = [NSMutableArray arrayWithObject:rootDept];
        [rootDept release];
    }
    
    for (UIView *subView in scrollView.subviews) {
        if (subView.tag >= 11) {
            [subView removeFromSuperview];
        }
    }
    
    scrollView.contentSize = CGSizeMake([OrgSizeUtil getLeftScrollViewWidth], [OrgSizeUtil getLeftScrollViewHeight]*[self.deptNavArray count]);
    
    int deptNavCount = [self.deptNavArray count];
    for (int i = 0; i < deptNavCount; i ++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(1.0, [OrgSizeUtil getLeftScrollViewHeight]*i, [OrgSizeUtil getLeftScrollViewWidth]-2, [OrgSizeUtil getLeftScrollViewHeight])];
        btn.backgroundColor = [UIColor clearColor];
        
        CGRect _frame = btn.frame;
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(2.0, 0.0, [OrgSizeUtil getLeftScrollViewWidth]-4, _frame.size.height-2.0)];
        lab.backgroundColor = [UIColor clearColor];
        [btn addSubview:lab];
        [lab release];
        
        NSString *title = @"";
        id temp = [self.deptNavArray objectAtIndex:i];
        if ([temp isKindOfClass:[Dept class]]) {
            title = [NSString stringWithFormat:@"%@",[[self.deptNavArray objectAtIndex:i] dept_name]];
        }
        else if([temp isKindOfClass:[Conversation class]]){
            title = [NSString stringWithFormat:@"%@",[[self.deptNavArray objectAtIndex:i] conv_title]];
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
        
//        [btn setBackgroundColor:[UIColor blueColor]];
        
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
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btn];
        [btn release];
    }
    
    //分割线
    UILabel  *lineBreak = [[UILabel alloc] initWithFrame:CGRectMake([OrgSizeUtil getLeftScrollViewWidth]-1.5, 0.0, 1.0, organizationalTable.frame.size.height)];
    lineBreak.tag = 100;
    lineBreak.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    lineBreak.autoresizingMask = scrollView.autoresizingMask;
    [scrollView addSubview:lineBreak];
    [lineBreak release];
    
    [self refreshSelectBtn];
    
    id temp = [self.deptNavArray lastObject];
    if ([temp isKindOfClass:[Dept class]]) {
        Dept *dept = (Dept *)temp;
        self.title = [NSString stringWithFormat:@"%@",[dept dept_name]];
    }
    else if([temp isKindOfClass:[Conversation class]]){
        Conversation *conv = (Conversation *)temp;
        self.title = [NSString stringWithFormat:@"%@",[conv conv_title]];
    }

    //确保最后的部门显示出来
    float contentHeight = scrollView.contentSize.height;
    float frameHeight = scrollView.frame.size.height;
    if (contentHeight > frameHeight) {
        [scrollView setContentOffset:CGPointMake(0.0, contentHeight-frameHeight)];
    }
}

- (void)refreshSelectBtn{
    isSelectAll = [self isCurrentEmpsSelected];
    if (isSelectAll) {
        [self setUnSelectAllBtn:rightBtn];
    }
    else{
        [self setSelectAllBtn:rightBtn];
    }
}

- (void)btnAction:(UIButton *)sender{
    NSLog(@"-----------%i",[self.navigationController.childViewControllers count]);
    //    int index = [self.navigationController.childViewControllers  count] - [self.navArray count] + sender.tag;
    //    [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:index] animated:YES];
    
    
    int count = [self.deptNavArray count];
    int index = sender.tag-11;
    if (index<count-1) {
        [self.deptNavArray removeObjectsInRange:NSMakeRange(index+1, count-index-1)];
        
        [self getRootItem];
        [self refreshNaviBar];
        [organizationalTable setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        [organizationalTable reloadData];
        
        NSNumber *conttentOffSetY = self.contentOffSetYArray[index];
        CGPoint point = CGPointMake(0, [conttentOffSetY doubleValue]);
        organizationalTable.contentOffset = point;
    }
}

#pragma mark------UISearchBarDelegate-----
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    backgroudButton.hidden=NO;
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchStr = [StringUtil trimString:searchBar.text];
 	if([self.searchStr length] == 0)
	{
        isSearch=NO;
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
	}
	else
	{
//        if (self.searchTimer && [self.searchTimer isValid])
//        {
////            NSLog(@"searchTimer is valid");
//            [self.searchTimer invalidate];
//        }
//        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchOrg) userInfo:nil repeats:NO];
	}
}

- (void)searchOrg
{
    dispatch_queue_t queue = dispatch_queue_create("search org", NULL);
    
    dispatch_async(queue, ^{
        int _type = [StringUtil getStringType:self.searchStr];
        
        if(_type != other_type){
            NSString *_searchStr = [NSString stringWithString:self.searchStr];
//            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            NSMutableArray *dataarray=[NSMutableArray array];
            
            if (self.typeTag != type_add_common_dept) {
                [_ecloud setLimitWhenSearchUser:YES];
                NSArray *emparray= [_ecloud getEmpsByNameOrPinyin:_searchStr andType:_type];
                [dataarray addObjectsFromArray:emparray];
            }
            
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:dataarray];
            
            //            增加搜索部门
            if ([eCloudConfig getConfig].needSearchDept) {
                NSArray *tempDeptArray = [_ecloud getDeptByNameOrPinyin:_searchStr andType:_type];
                [self.searchResults addObjectsFromArray:tempDeptArray];
            }

//            [pool release];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            isSearch = YES;
            [self.view bringSubviewToFront:bottomNavibar];
            
            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
            
            [self.searchDisplayController.searchResultsTableView reloadData];
            self.searchDisplayController.searchResultsTableView.contentOffset = CGPointMake(0, 0);
            if (![self.searchResults count]) {
                [self setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"]];
            }
            NSLog(@"%s,%d",__FUNCTION__,self.searchResults.count);
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

//返回 按钮
-(void) backButtonPressed:(id) sender{
//    needUnselectEmp = YES;
    
    if (self.typeTag == type_schedule) {
        self.navigationController.navigationBarHidden = NO;
    }
    else if ([_fromWhere isEqualToString:RECEIVE_MAP_VIEW_CONTROLLER]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DISMISS object:self];
        [self dismissModalViewControllerAnimated:YES];
        
    }
    else if (self.typeTag == type_app_create_conversation || self.typeTag == type_app_select_contact_gome || self.typeTag == type_add_miliao_conv ||self.typeTag == type_LG_news_share)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

//隐藏查询输入框的键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[searchTextView resignFirstResponder];
}

#pragma mark 提醒用户选择人数已经超过最大值
-(void)showGroupNumExceedAlert{
    NSString *titlestr=[NSString stringWithFormat:[StringUtil getLocalizableString:@"specialChoose_max_members"],maxGroupNum];

    if (self.typeTag == type_add_common_emp) {
//     如果是添加常用联系人，给不同提示
        titlestr=[NSString stringWithFormat:[StringUtil getLocalizableString:@"specialChoose_max_common_contacts"],maxGroupNum];

    }
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:titlestr delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
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
    memberDetail.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"specialChoose_choosed_contacts"],count_num];
    memberDetail.emp_id_list=emp_id_list;
    
    [self.navigationController pushViewController:memberDetail animated:YES];
    [memberDetail release];
    NSLog(@"---here---emp_id_list %@",emp_id_list);
}

#pragma mark - 全选或取消当前员工
- (void)selectAllBtnPressed:(UIButton *)sender{
    isSelectAll = !isSelectAll;
    if (isSelectAll) {
        //全选
        int nowcount= [self.nowSelectedEmpArray count];

        if([self needShowAlert]){
            isSelectAll = NO;
            return;
        }
        int deselectCount = [self getCurrentDesSelectedEmpCount];
        if ((nowcount+deselectCount)>(maxGroupNum - self.oldEmpIdArray.count)){
            [self showGroupNumExceedAlert];
            isSelectAll = NO;
            return;
        }
        [self setUnSelectAllBtn:rightBtn];
    }
    else{
        [self setSelectAllBtn:rightBtn];
    }
    
    [self setCurrentEmpSelected:isSelectAll];
    [organizationalTable reloadData];
    [self bottomScrollviewShow];
}

- (int)getCurrentDesSelectedEmpCount{
    //获取当前列表为选中人员数
    int deselectCount = 0;

    for (id temp in self.itemArray) {
        if ([temp isKindOfClass:[Emp class]]) {
            Emp *tempEmp = (Emp*)temp;
            if (!tempEmp.isSelected) {
                deselectCount ++;
            }
        }
    }
    return deselectCount;
}

- (void)setCurrentEmpSelected:(BOOL)selected{
    for (id temp in self.itemArray) {
        if ([temp isKindOfClass:[Emp class]]) {
            Emp *emp = (Emp *)temp;
//            if (![self isEmpInOldEmpIdArray:emp]) {
//                emp.isSelected = selected;
//                [self selectByEmployee:emp.emp_id status:emp.isSelected];
//            }
            if (emp.emp_id != _conn.curUser.emp_id) {
                emp.isSelected = selected;
                [self selectByEmployee:emp.emp_id status:emp.isSelected];
            }
        }
    }
}

- (BOOL)isEmpInOldEmpIdArray:(Emp *)emp{
    BOOL isExist = NO;
    for (Emp *temp in self.oldEmpIdArray) {
        if (temp.emp_id == emp.emp_id) {
            isExist = YES;
            break;
        }
    }
    return isExist;
}

- (BOOL)isCurrentEmpsSelected{
    BOOL isSelected = NO;
    
    for (id temp in self.itemArray) {
        if ([temp isKindOfClass:[Emp class]]) {
            Emp *emp = (Emp *)temp;
            if (!emp.isSelected) {
                isSelected = NO;
                break;
            }
            else{
                isSelected = YES;
            }
        }
    }
    
    return isSelected;
}

#pragma mark 选择后确定
-(void)addButtonPressed:(id) sender
{
    [searchTextView resignFirstResponder];

    if (self.typeTag == type_add_miliao_conv) {
        if (self.chooseMemberDelegate && [self.chooseMemberDelegate respondsToSelector:@selector(didFinishSelectContacts:)]) {
            
//            for (Emp *_emp in self.nowSelectedEmpArray) {
//                
//            }
            
            [self backButtonPressed:nil];
            [self.chooseMemberDelegate didFinishSelectContacts:self.nowSelectedEmpArray];
        }
        return;
    }
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)

    if (self.chooseMemberDelegate && [self.chooseMemberDelegate respondsToSelector:@selector(didFinishSelectContacts:)]) {
        
        NSMutableArray *userArray = [NSMutableArray array];
        
        for (Emp *_emp in self.nowSelectedEmpArray) {
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            mDic[EMP_ID_KEY] = [NSNumber numberWithInt:_emp.emp_id];
            mDic[EMP_NAME_KEY] = _emp.emp_name;
            mDic[EMP_SEX_KEY] =  [NSNumber numberWithInt:_emp.emp_sex];
            mDic[EMP_CODE_EKY] = _emp.empCode;
            [userArray addObject:mDic];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self.chooseMemberDelegate performSelector:@selector(didFinishSelectContacts:) withObject:userArray];
    }
    [self backButtonPressed:nil];
#else
    //    needUnselectEmp = YES;
    //	关闭键盘
    
    if ((self.typeTag == type_app_select_contact_gome)) {
        [self returnSelectUserOfGOME1];
        return;
    }
    if (self.typeTag == type_app_select_contacts) {
        Emp *_emp = self.nowSelectedEmpArray[0];
        NSMutableString *retStr = [NSMutableString stringWithFormat:@"%@",_emp.empCode];
        
        for (int i = 1; i < self.nowSelectedEmpArray.count; i++) {
            Emp *_emp = self.nowSelectedEmpArray[i];
            [retStr appendFormat:@",%@",_emp.empCode];
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"需要把选择的用户传给轻应用 %@",retStr]];
        
        if (self.chooseMemberDelegate && [self.chooseMemberDelegate respondsToSelector:@selector(didSelectContacts:)]) {
            [self.chooseMemberDelegate performSelector:@selector(didSelectContacts:) withObject:retStr];
        }
        [self backButtonPressed:nil];
        return;
    }
    if (self.typeTag == type_transfer_msg_create_new_conversation || self.typeTag == type_LG_news_share) {
        [self createConvWhenTransferMsg];
        return;
    }
    
    if (self.typeTag == type_add_common_dept) {
        //添加常用部门
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
        return;
    }
    
    if (self.typeTag == type_add_common_emp)
    {
        //添加常联系人
        self.commonEmpIdArray = [NSMutableArray arrayWithCapacity:self.nowSelectedEmpArray.count];
        
        // 发送数据到服务器，同步应答，成功后才入库
        NSMutableString *empNameStr = [NSMutableString stringWithString:@""];
        for (Emp *_emp in self.nowSelectedEmpArray) {
            [empNameStr appendString:[NSString stringWithFormat:@"%@,",_emp.emp_name]];
            [self.commonEmpIdArray addObject:[StringUtil getStringValue:_emp.emp_id]];
        }
        NSLog(@"选择的常用联系人包括:%@",empNameStr);
        
        BOOL ret = [userDataConn sendModiRequestWithDataType:user_data_type_emp andUpdateType:user_data_update_type_insert andData:self.commonEmpIdArray];
        
        if (ret) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        }
        return;
    }
    if (self.typeTag == type_app_open_contacts) {
        //第三方应用访问通讯录
        if([self needShowAlert])
            return;
        
        //判断选中的人员数量
        if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count) )
        {
            [self showGroupNumExceedAlert];
            return;
        }
        [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
        
        NSMutableArray *name_array=[[NSMutableArray alloc]init];
        for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
            Emp*emp=[self.nowSelectedEmpArray objectAtIndex:i];
            //需要返回的用户信息
            NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
            [userInfoDic setObject:emp.empCode forKey:@"usercode"];
            [userInfoDic setObject:[NSNumber numberWithInt:emp.emp_id] forKey:@"userid"];
            
            if ([emp.emp_mail length]) {
                [userInfoDic setObject:emp.emp_mail forKey:@"email"];
            }
            else{
                [userInfoDic setObject:@"" forKey:@"email"];
            }
            
            [userInfoDic setObject:emp.emp_name forKey:@"username"];
            [name_array addObject:userInfoDic];
            [userInfoDic release];
            
        }
        [[NSNotificationCenter defaultCenter ]postNotificationName:js_choose_NOTIFICATION object:name_array userInfo:nil];
        [name_array release];
        
        [self backButtonPressed:nil];
        return;
    }
    
    if (self.typeTag == type_app_create_conversation) {
        //从第三方应用进入会话页面
        if(talkSession == nil)
            talkSession=[[talkSessionViewController alloc]init];
        
        if ([self.nowSelectedEmpArray count]==1)
        { //单聊
            Emp *emp = [self.nowSelectedEmpArray objectAtIndex:0];
            talkSession.titleStr=emp.emp_name;
            talkSession.talkType=singleType;
            talkSession.fromType = 4;
            
            [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
            
            talkSession.convEmps = self.nowSelectedEmpArray;
            //如果是群聊，则不设置convId
            talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
            talkSession.needUpdateTag = 1;
        }
        else
        {
            
            if([self needShowAlert])
                return;
            
            //判断选中的人员数量
            if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count) )
            {
                [self showGroupNumExceedAlert];
                return;
            }
            
            //创建多人会话
            talkSession.titleStr=[StringUtil getLocalizableString:@"specialChoose_multi_session"];
            talkSession.talkType=mutiableType;
            talkSession.convId=nil;
            talkSession.fromType = 4;
            [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
            
            talkSession.convEmps = self.nowSelectedEmpArray;
            talkSession.needUpdateTag = 1;
        }
        
        //打开会话窗口
        [self.navigationController pushViewController:talkSession animated:YES];
        return;
    }
    
    //	typeTag 为0，表示是选中人员，创建会话，否则是从成员管理界面而来，是添加成员
    if(self.typeTag == type_create_conversation)
    {
        //    万达要求先选择成员后，先创建群组
        talkSession = [talkSessionViewController getTalkSession];
        //		创建单聊
        //        因为默认包含了自己，所以要总数是2时，才可以算作单聊
        if (self.nowSelectedEmpArray.count <= 1)
        {
            return;
        }
        
        if ([self.nowSelectedEmpArray count] == 2)
        { //单聊
            Emp *emp = [self.nowSelectedEmpArray objectAtIndex:1];
            
            talkSession.titleStr=emp.emp_name;
            talkSession.talkType=singleType;
            
            [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
            
            talkSession.convEmps = self.nowSelectedEmpArray;
            //			如果是群聊，则不设置convId
            talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
            talkSession.needUpdateTag = 1;
            
            [self hideAndNotifyOpenTalkSession:talkSession];
        }
        else
        {
            if([self needShowAlert])
                return;
            
            //			判断选中的人员数量
            if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count) )
            {
                [self showGroupNumExceedAlert];
                return;
            }
            
            [self createConv];
        }
    }
    //	{
    //		if(talkSession == nil)
    //			talkSession=[[talkSessionViewController alloc]init];
    //        //		创建单聊
    ////        因为默认包含了自己，所以要总数是2时，才可以算作单聊
    //        if (self.nowSelectedEmpArray.count <= 1)
    //        {
    //            return;
    //        }
    //		if ([self.nowSelectedEmpArray count] == 2)
    //		{ //单聊
    //			Emp *emp = [self.nowSelectedEmpArray objectAtIndex:1];
    //
    //			talkSession.titleStr=emp.emp_name;
    //			talkSession.talkType=singleType;
    //
    //			[self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
    //
    //			talkSession.convEmps = self.nowSelectedEmpArray;
    ////			如果是群聊，则不设置convId
    //			talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
    //			talkSession.needUpdateTag = 1;
    //		}
    //		else
    //		{
    //            if([self needShowAlert])
    //                return;
    //
    //            //			判断选中的人员数量
    //			if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count) )
    //			{
    //				[self showGroupNumExceedAlert];
    //				return;
    //			}
    //
    //            //	创建多人会话
    //			talkSession.titleStr=[StringUtil getLocalizableString:@"specialChoose_multi_session"];
    //			talkSession.talkType=mutiableType;
    //			talkSession.convId=nil;
    //			[self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
    //			talkSession.convEmps = self.nowSelectedEmpArray;
    //			talkSession.needUpdateTag = 1;
    //		}
    //        //		打开会话窗口
    ////       		[self.navigationController pushViewController:talkSession animated:YES];
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
    //
    //        [self dismissModalViewControllerAnimated:NO];
    //
    //	}
    else  if(self.typeTag == type_add_conv_emp)
    {
        _convId = ((chatMessageViewController*)self.delegete).convId;
        //		把从成员列表页面带过来的convId保存起来
        if(((chatMessageViewController*)self.delegete).talkType == singleType)
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
        
        if([self needShowAlert])
            return;
        
        //				判断群组成员数量
        if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count))
        {
            [self showGroupNumExceedAlert];
            return;
        }
        if(isGroupCreate)
        {
            if ([UserTipsUtil checkNetworkAndUserstatus]) {
                [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
                [[LCLLoadingView currentIndicator]show];
                
                if(![_conn modifyGroupMember:((chatMessageViewController*)self.delegete).convId andEmps:self.nowSelectedEmpArray andOperType:0])
                {
                    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"specialChoose_request_failed"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];
                }
            }
        }
        else
        {
            [self createConv];
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
#endif
}
#pragma mark 从聊天信息界面选择添加成员，添加成功后，刷新聊天信息界面
-(void)addMemberSuccess
{
	talkSession = ((talkSessionViewController*)((chatMessageViewController*)self.delegete).predelegete);
	if(((chatMessageViewController*)self.delegete).talkType == singleType)
	{
        //原来是单人聊天
		talkSession.convId = nil;
		talkSession.titleStr=[StringUtil getLocalizableString:@"specialChoose_multi_session"];
		talkSession.talkType= mutiableType;
		((chatMessageViewController*)self.delegete).convId = nil;
	}
    
	
	[self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
	talkSession.convEmps = self.nowSelectedEmpArray;
	talkSession.needUpdateTag = 1;
	[talkSession refresh];
	
    ((chatMessageViewController*)self.delegete).start_Delete = NO;
	((chatMessageViewController*)self.delegete).dataArray= self.nowSelectedEmpArray;//talkSession.convEmps;
	[((chatMessageViewController*)self.delegete) showMemberScrollow];
//	[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==organizationalTable) {
        if ([self displayRootOrg]) {
            if ([UIAdapterUtil isBGYApp])
            {
                return 1;
            }
            else
            {
                
                return self.orgItemArray.count;
            }
        }
        return 1;
    }
    else if(tableView == self.searchDisplayController.searchResultsTableView){
        return 1;
    }
    else {
        
        return 2;
    }
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==organizationalTable) {
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
    else if(tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"%s,%d",__FUNCTION__,self.searchResults.count);
        return self.searchResults.count;
    }
    else {
        
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
    if (tableView==organizationalTable || tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
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
    if (tableView==organizationalTable || tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self displayRootOrg] && section > 0) {
            //
            SettingItem *_item = [self getItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            
            if (_item && _item.headerHight) {
                return _item.headerHight;
            }
            return 20.0;
        }
        
//        if (section == 1) {
//            return 20.0;
//        }
//        else if (section == 2) {
//            if (self.typeTag == type_create_conversation || self.typeTag == type_transfer_msg_create_new_conversation) {
//                return GROUP_SECTION_HEADER_HEIGHT;
//            }
//            return 20.0;
//        }
        return 0.0;
    }else
    {
        if(section==0)
        {
            
            return 0;
        }
        else
        {
            if ([self.chooseArray count]==0) {
                return 40;
            }
            return 60;
        }
    }
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView==organizationalTable || tableView == self.searchDisplayController.searchResultsTableView) {
        
        if ([self displayRootOrg] && section > 0) {
            SettingItem *_item = [self getItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            if (_item.headerView) {
                return _item.headerView;
            }
        }
        return nil;
//        
//        UIView *headBgView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,GROUP_SECTION_HEADER_HEIGHT)];
//        headBgView.backgroundColor = [UIColor clearColor];
//
//        if ((self.typeTag == type_create_conversation || self.typeTag == type_transfer_msg_create_new_conversation) && section == 2) {
//            
//            UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake([OrgSizeUtil getLeftScrollViewWidth] + 10,0.0, SCREEN_WIDTH - [OrgSizeUtil getLeftScrollViewWidth] - 10, GROUP_SECTION_HEADER_HEIGHT)];
//            //        titlelabel.backgroundColor = [UIColor colorWithRed:244.0/255 green:246.0/255 blue:249.0/255 alpha:1.0];
//            titlelabel.backgroundColor = [UIColor clearColor];
//
//            titlelabel.numberOfLines = 2;
//            titlelabel.lineBreakMode = NSLineBreakByTruncatingTail;
//            titlelabel.font = [UIFont systemFontOfSize:13.5];
//            titlelabel.textColor = [UIColor colorWithRed:156.0/255 green:156.0/255 blue:156.0/255 alpha:1.0];
//            titlelabel.textAlignment = UITextAlignmentLeft;
//            titlelabel.text = [NSString stringWithFormat:@"\n%@",[StringUtil getLocalStringRelatedWithAppNameByKey:@"select_custom_groups_tip"]];
//            [headBgView addSubview:titlelabel];
//            [titlelabel release];
//            
//        }
//        return [headBgView autorelease];
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
        if ([self displayRootOrg]) {
            if ([UIAdapterUtil isBGYApp])
            {
                return emp_row_height;
            }
            
            return dept_row_height;
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
//        
//        id temp;
//        if ([indexPath section] == 0) {
//            temp=[self.itemArray objectAtIndex:indexPath.row];
//        }
//        else{
//            temp=[self.groupArray objectAtIndex:indexPath.row+2*(indexPath.section-1)];
//        }
//        if ([temp isKindOfClass:[Dept class]]) {
//            return dept_row_height;
//        }
//        else {
//            return emp_row_height;
//        }
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        id temp=[self.searchResults objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[Dept class]]) {
            return dept_row_height;
        }
        else {
            return emp_row_height;
        }
    }
    else
    {
        if (indexPath.section==0) {
            
            return 50;
            
        }else
        {
            id temp=[self.chooseArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[RecentMember class]]) {
                return 45;
            }// Configure the cell.
            else {
                if ([temp isKindOfClass:[Dept class]]) {
                    return dept_row_height;
                }// Configure the cell.
                else {
                    return 58;
                }
            }
        }
        
    }
    
}
#pragma mark 获取员工的显示方式
-(NewEmpSelectCell *)getEmpWithDeptCell:(NSIndexPath*)indexPath
{
    static NSString *empCellID = @"empSearchDeptCellID";
	NewEmpSelectCell *empCell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil){
		empCell = [[[NewEmpSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
//        [self addGesture:empCell];
	}
    
    UIButton *selectButton = (UIButton*)[empCell viewWithTag:emp_select_tag];
    selectButton.hidden=NO;
	Emp *emp = [self.searchResults objectAtIndex:indexPath.row];
    if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]] || emp.emp_id == _conn.curUser.emp_id) {
        selectButton.hidden = YES;
    }

    UIButton *infoButton = (UIButton*)empCell.infoView;
    infoButton.tag = [indexPath row];
    [infoButton addTarget:self action:@selector(clickOnSearchInfoButton:) forControlEvents:UIControlEventTouchUpInside];
    
	[empCell configureWithDeptCell:emp];
	return empCell;
}

#pragma mark 获取员工的显示方式
-(NewEmpSelectCell *)getEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	NewEmpSelectCell *empCell = [organizationalTable dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil){
		empCell = [[[NewEmpSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID] autorelease];
//        [self addGesture:empCell];
	}
    UIButton *selectButton = (UIButton*)[empCell viewWithTag:emp_select_tag];
    selectButton.hidden=NO;
	Emp *emp = [self.itemArray objectAtIndex:indexPath.row];
    if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]] || emp.emp_id == _conn.curUser.emp_id) {
        selectButton.hidden = YES;
    }
    
    UIButton *infoButton = (UIButton*)empCell.infoView;
    infoButton.tag = [indexPath row];
    [infoButton addTarget:self action:@selector(clickOnInfoButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [empCell configureCell:emp];
    
	return empCell;
}

- (void)clickOnSearchInfoButton:(UIButton *)sender{
    //打开用户资料
    Emp *emp = (Emp *)[self.searchResults objectAtIndex:sender.tag];
    isDetailAction = YES;
    NSString *empid = [NSString stringWithFormat:@"%i",emp.emp_id ];
    [NewOrgViewController openUserInfoById:empid andCurController:self];
}

- (void)clickOnInfoButton:(UIButton *)sender{
    //打开用户资料
    Emp *emp = (Emp *)[self.itemArray objectAtIndex:sender.tag];
    isDetailAction = YES;
    NSString *empid = [NSString stringWithFormat:@"%i",emp.emp_id ];
    [NewOrgViewController openUserInfoById:empid andCurController:self];
}

#pragma mark 最近联系 获取员工的显示方式
-(NewEmpSelectCell *)getTypeEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	NewEmpSelectCell *empCell = [organizationalTable dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil)
	{
		empCell = [[[NewEmpSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
        [self addGesture:empCell];
	}
	UIButton *selectButton = (UIButton*)[empCell viewWithTag:emp_select_tag];
    selectButton.hidden=NO;
	Emp *emp = [self.typeArray objectAtIndex:indexPath.row];
	[empCell configureCell:emp];

    if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
        selectButton.hidden = YES;
    }
    
	return empCell;
}

#pragma mark 筛选 获取员工的显示方式
-(NewEmpSelectCell *)getSearchEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	NewEmpSelectCell *empCell = [chooseTable dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil)
	{
		empCell = [[[NewEmpSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
        [self addGesture:empCell];
	}
	UIButton *selectButton = (UIButton*)[empCell viewWithTag:emp_select_tag];
    selectButton.hidden=NO;
	Emp *emp = [self.chooseArray objectAtIndex:indexPath.row];
	[empCell configureCell:emp];
    
    if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
        selectButton.hidden = YES;
    }
    
	return empCell;
}

#pragma mark 查询和展开的部门的cell
- (NewDeptSelectCell *)getDeptSelectCell:(NSIndexPath *)indexPath search:(BOOL)isSearch
{
    static NSString *deptSelectCellID = @"deptSelectCellID";
    Dept *dept =[self.itemArray objectAtIndex:indexPath.row];
    NewDeptSelectCell *deptCell = [organizationalTable dequeueReusableCellWithIdentifier:deptSelectCellID];
    if (deptCell == nil) {
        deptCell = [[[NewDeptSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        
        UIButton *selectButton=(UIButton *)[deptCell viewWithTag:dept_select_btn_tag] ;
        [selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIButton *selectButton=(UIButton *)[deptCell viewWithTag:dept_select_btn_tag];
    selectButton.titleLabel.text = [StringUtil getStringValue:indexPath.row];
    if (dept.dept_parent == 0) {
        selectButton.hidden = YES;
    }
    else if (self.typeTag == type_add_common_dept){
         selectButton.hidden = NO;
    }
    else{
        selectButton.hidden = YES;
    }
    
    [deptCell configCell:dept search:isSearch];
    
    return deptCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
// 下面的代码没有必要
//    if (tableView==organizationalTable){
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
//            cell.backgroundColor = [UIColor clearColor];
//        }
//    }
//    else if(tableView == self.searchDisplayController.searchResultsTableView){
//        id temp=[self.searchResults objectAtIndex:indexPath.row];
//        
//        if ([temp isKindOfClass:[Dept class]]){
//            cell.backgroundColor = [UIColor whiteColor];
//        }
//        else{
//            cell.backgroundColor = [UIColor clearColor];
//        }
//    }
}

#pragma mark 只优化了一部分，主要针对组织架构部门做了展示优化，解决部门名称过长，覆盖在线人数或选择框的问题
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;

        if (tableView==chooseTable) {
            if (indexPath.section==0) {
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                
                UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 20)];
                titleLabel.tag=2;
                titleLabel.backgroundColor=[UIColor clearColor];
                titleLabel.font=[UIFont systemFontOfSize:14];
                [cell.contentView addSubview:titleLabel];
                [titleLabel release];
                
            }else{
                UIButton *selectView=[[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)]autorelease];
                selectView.tag=5;
                selectView.backgroundColor=[UIColor clearColor];
                cell.accessoryView=selectView;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            }
        }
    }
    
    if (tableView==organizationalTable) {
        //        通讯录首页
        if ([self displayRootOrg]) {
            SettingItem *_item = [self getItemByIndexPath:indexPath];
            
            
#ifdef _BGY_FLAG_
            RootDeptCellARC *deptCell = [[[RootDeptCellARC alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil] autorelease];
            deptCell.item = _item;
            return deptCell;
            
#else
            id dataObject = _item.dataObject;
            if ([dataObject isKindOfClass:[Dept class]]) {
                Dept *tempDept = (Dept *)dataObject;
                
                NewDeptSelectCell *deptCell = [[[NewDeptSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                
                UIButton *selectButton=(UIButton *)[deptCell viewWithTag:dept_select_btn_tag];
                //                selectButton.titleLabel.text = [StringUtil getStringValue:indexPath.row];
                selectButton.hidden = YES;
                
                [deptCell configCell:tempDept search:NO];
                
                return deptCell;
            }
#endif
            return nil;
        }else{
            id temp=[self.itemArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]){
                return [self getDeptSelectCell:indexPath search:NO];
            }
            else if([temp isKindOfClass:[Emp class]]){
                return [self getEmpCell:indexPath];
            }
            else{
                return [self getGroupCell:indexPath];
            }
        }
    }
    else if(tableView == self.searchDisplayController.searchResultsTableView){
        id temp = [searchResults objectAtIndex:[indexPath row]];
        if ([eCloudConfig getConfig].needSearchDept) {
            if ([temp isKindOfClass:[Dept class]])
            {
                Dept *tempDept = (Dept *)temp;
                
                NewDeptSelectCell *deptCell = [[[NewDeptSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                
                [deptCell configCell:tempDept search:YES];
                
                return deptCell;
            }
        }

        if ([temp isKindOfClass:[Emp class]]) {
            return [self getEmpWithDeptCell:indexPath];
        }
    }
    else{
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
                titlelabel.text=[StringUtil getLocalizableString:@"specialChoose_region"];
                // detaillabel.text=@"全部地域";
                
            }else
            {
                id temp=[self.zoneArray objectAtIndex:indexPath.row-3];
                citiesObject *city=(citiesObject *)temp;
                titlelabel.text=city.some_cities;                cell.accessoryType=UITableViewCellAccessoryNone;
                
            }
            
        }
        else{
            UILabel *onlineLabel=[[UILabel alloc]initWithFrame:CGRectMake(210, 5, 90, 30)];
            onlineLabel.backgroundColor=[UIColor clearColor];
            onlineLabel.tag=1;
            onlineLabel.hidden=YES;
            onlineLabel.textAlignment=UITextAlignmentCenter;
            onlineLabel.font=[UIFont systemFontOfSize:12];
            [cell.contentView addSubview:onlineLabel];
            [onlineLabel release];

            UIButton *selectButton=(UIButton *)cell.accessoryView;
            selectButton.tag=indexPath.row;
            selectButton.hidden=NO;
            cell.textLabel.font=[UIFont systemFontOfSize:17];
            id temp=[self.chooseArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                Dept *dept = (Dept *)temp;
                
                if (dept.isExtended) {
                    cell.imageView.image=[StringUtil getImageByResName:@"arrow_down.png"];
                }else
                {
                    cell.imageView.image=[StringUtil getImageByResName:@"arrow_right.png"];
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
                cell.textLabel.text=dept.dept_name;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                onlineLabel.hidden=NO;
                onlineLabel.text=[NSString stringWithFormat:@"%d",dept.totalNum];
            }
            else if([temp isKindOfClass:[Emp class]])
            {
                selectButton.hidden=YES;
                return [self getSearchEmpCell:indexPath];
            }
        }
    }
    return cell;
}

#pragma mark - 我的群组，固定群组
- (NewGroupCell *)getGroupCell:(NSIndexPath*)indexPath{
    static NSString *CellIdentifier = @"Cell";
    NewGroupCell *groupCell = [organizationalTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (groupCell == nil) {
        groupCell = [[[NewGroupCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        groupCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Conversation *emp = (Conversation *)[self.itemArray objectAtIndex:indexPath.row];
    
    [groupCell configCell:emp];
    
    UIView *imageLogo = [groupCell viewWithTag:logo_view_tag];
    CGRect _frame = imageLogo.frame;
    _frame.origin.y = (GroupCellHeight - chatview_logo_size)*0.5;
    imageLogo.frame = _frame;
    
    UIView *label = [groupCell viewWithTag:group_name_tag];
    CGPoint _center = label.center;
    _center.y = GroupCellHeight*0.5;
    label.center = _center;
    return groupCell;
}

#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //纪录当前tableview的contentOffSet.y,返回时让tableview回到刚才位置
    NSNumber *currentContentOffSetY = [[NSNumber alloc] initWithDouble:tableView.contentOffset.y];
    self.contentOffSetYArray[self.deptNavArray.count - 1] = currentContentOffSetY;
    
    [searchTextView resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView==organizationalTable) {
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
    else if(tableView == self.searchDisplayController.searchResultsTableView){
        id temp=[self.searchResults objectAtIndex:indexPath.row];
        if ([eCloudConfig getConfig].needSearchDept) {
            if ([temp isKindOfClass:[Dept class]]) {
                Dept *tempDept = (Dept *)temp;
                
                NSArray *tempEpArray=[_ecloud getEmpsByDeptID:tempDept.dept_id  andLevel:0];
                NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithSelected:[NSString stringWithFormat:@"%d",tempDept.dept_id] andLevel:0 andSelected:false];
                
                [self.searchResults removeAllObjects];
                [self.searchResults addObjectsFromArray:tempEpArray];
                [self.searchResults addObjectsFromArray:tempDeptArray];
                
                [self.searchDisplayController.searchResultsTableView reloadData];
                self.searchDisplayController.searchResultsTableView.contentOffset = CGPointMake(0, 0);
                return;
            }
        }
        [self processTableViewDidSelect:temp];
    }
    else if (tableView==chooseTable){
        
        if (indexPath.section==0) {
            isNeedSearchAgain=YES;
            if (indexPath.row==0) {
                //if (rankChoose==nil) {
                    rankChoose=[[rankChooseViewController alloc]init];
                    rankChoose.delegete=self;
             //   }
                [self.navigationController pushViewController:rankChoose animated:YES];
                [rankChoose release];
                
            }else if(indexPath.row==1) {
                
               // if (businessChoose==nil) {
                    businessChoose=[[businessChooseViewController alloc]init];
                    businessChoose.delegete=self;
              //  }
                [self.navigationController pushViewController:businessChoose animated:YES];
                [businessChoose release];
            }else if(indexPath.row==2) {
                
               // if (zoneChoose==nil) {
                    zoneChoose=[[zoneChooseViewController alloc]init];
                    zoneChoose.delegete=self;
               // }
                [self.navigationController pushViewController:zoneChoose animated:YES];
                [zoneChoose release];
            }
            
        }else
        {
            id temp=[self.chooseArray objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Emp class]])
            {
                int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];

                //	取出对应行的对象是一个部门还是一个员工
                
                //       选中的是员工
                Emp *emp=(Emp *)temp;
                BOOL isOldMember=FALSE;
                if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
                    isOldMember = true;
                }
                
                if (isOldMember) {
                    return;
                }
                
                if(!emp.permission.canSendMsg)
                {
                    return;
                }
                
                if (emp.isSelected) { //不选中
                    emp.isSelected=false;
                   
                }else   //选中
                {
                    if([self needShowAlert])
                        return;

                    if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
                        [self showGroupNumExceedAlert];
                        return;
                    }
                    emp.isSelected=true;
                }
                [self selectByEmployee:emp.emp_id status:emp.isSelected];
                [chooseTable reloadData];
                //    显示在底部
                [self bottomScrollviewShow];
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
                    
                    if (isExtendedPoint<noworigin) {
                        float offsetvalue=noworigin-sumnum;
                        if (offsetvalue<0) {
                            offsetvalue=noworigin;
                        }
                        tableView.contentOffset=CGPointMake(0,offsetvalue-58);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                    }else{
                        tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                    }
                    
                    
                    
                    //			[LogUtil debug:[NSString stringWithFormat:@"tableView.contentOffset %.0f", tableView.contentOffset.y]];
                    
                    
                    /*自动收起*///---------------------------------------------------------------end------------//
                    //            NSLog(@"---cell.offset-- %0.0f",tableView.contentOffset.y);
                }
                [tableView reloadData] ;
            }
        }
    }
}

#pragma mark - 打开群组会话
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
            
            [self hideAndNotifyOpenTalkSession:talkSession];
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
        [self bottomScrollviewShow];
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
        
    }
}


-(void)iconAction:(id)sender
{
    
}

-(void)selectTypeAction:(id)sender
{
    int nowcount= [self.nowSelectedEmpArray count];
    UIButton *button = (UIButton *)sender;
    int row = button.titleLabel.text.intValue;
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
            if([self needShowAlert])
                return;

            NSArray *tempEpArray=[_ecloud getRecentEmpInfoWithSelected:[NSString stringWithFormat:@"%d",recent.type_id]  andLevel:1 andSelected:recent.isChecked];
            int nowcount= [self.nowSelectedEmpArray count];
            if (nowcount+[tempEpArray count]>(maxGroupNum - self.oldEmpIdArray.count)) {
                [self showGroupNumExceedAlert];
                return;
            }
            
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
        [self bottomScrollviewShow];
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
            if([self needShowAlert])
                return;
            NSArray *tempEpArray=[_ecloud getRecentGroupMemberWithSelected:[NSString stringWithFormat:@"%d",recent.type_id] andLevel:2 andSelected:recent.isChecked andConvId:recent.conv_id];
            int nowcount= [self.nowSelectedEmpArray count];
            if (nowcount+[tempEpArray count]>(maxGroupNum - self.oldEmpIdArray.count)) {
                [self showGroupNumExceedAlert];
                return;
            }
            
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
        [self bottomScrollviewShow];
        
        
    }
}
-(void)selectAction:(id)sender
{
    [searchTextView resignFirstResponder];
	int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
    
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
        
        //设置部门，部门的子部门，部门员工，子部门员工的选中状态
        [self selectByDept:dept.dept_id status:dept.isChecked];
        
        /*
        //把选中状态呈现在界面上
        for (int i=row+1; i<[self.itemArray count]; i++) {
            id temp1 = [self.itemArray objectAtIndex:i];
            if([temp1 isKindOfClass:[Emp class]])
            {
                if (((Emp *)temp1).emp_level<=dept.dept_level) {
                    break;
                }
                //                如果不能发送消息或者是隐藏，则不选中
                Emp *_emp = (Emp *)temp1;
                
                if (_emp.permission.isHidden) {
                    NSLog(@"%@是隐藏的",_emp.emp_name);
                    continue;
                }
                
                if (!_emp.permission.canSendMsg) {
                    NSLog(@"%@不能发消息",_emp.emp_name);
                    continue;
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
        */
        addButton.enabled=YES;
        [organizationalTable reloadData];
        
    }else
    {
        //       选中的是员工
        Emp *emp=(Emp *)temp;
        
        if(!emp.permission.canSendMsg)
        {
            [PermissionUtil showAlertWhenCanNotSendMsg:emp];
            return;
        }

        if (emp.isSelected) { //不选中
            emp.isSelected=false;
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
            
        }else   //选中
        {
            if([self needShowAlert])
            {
                return;
            }
            if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
                [self showGroupNumExceedAlert];
                return;
            }
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            
            emp.isSelected=true;
        }
        [self selectByEmployee:emp.emp_id status:emp.isSelected];
        [organizationalTable reloadData];
        
        //显示在底部
        [self bottomScrollviewShow];
    }
}
//选中或未选中
//-(void)selectByDept:(int)dept_id status:(bool)selectedStatus
//{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//    //部门id
//    NSString *dept_id_str=[NSString stringWithFormat:@"%d",dept_id];
//    //部门的子部门
//    NSArray *tempArray=[_ecloud getChildDepts:dept_id_str];
//    Emp *emp;
//    NSString *deptId;
//    
//    //    设置子部门下的员工的选中状态
//    for (int i=0; i<[self.employeeArray count]; i++) {
//        
//        emp=[self.employeeArray objectAtIndex:i];
//        for (int j=0;j<[tempArray count]; j++) {
//            
//            deptId=[tempArray objectAtIndex:j];
//            if (emp.emp_dept==[deptId intValue])
//			{
//				bool isOldMember = false;
//                if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
//                    isOldMember = true;
//                }
//
//				if(isOldMember)
//					continue;
//                if (emp.permission.isHidden) {
//                    NSLog(@"%@是隐藏的",emp.emp_name);
//                    continue;
//                }
//				if(!emp.permission.canSendMsg)
//                {
//                    NSLog(@"%@不能发送消息",emp.emp_name);
//                    continue;
//                }
//                
//                emp.isSelected=selectedStatus;
//				[self updateNowSelectedEmp:emp];
//				break;
//            }
//        }
//    }
//	[self displayNowSelectedEmp];
//    
//    for (int j=0; j<[tempArray count] ;j++) {
//        
//        deptId=[tempArray objectAtIndex:j];
//        DeptInMemory *_dept = [_conn getDeptInMemoryByDeptId:deptId.intValue];
//        if (_dept) {
//            _dept.isChecked = selectedStatus;
//        }
//    }
//
//    [pool release];
//}

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


//最近联系 选中或未选中
-(void)selectByType:(int)type_id status:(bool)selectedStatus
{
    
    NSArray *tempEpArray=[_ecloud getRecentEmpInfoWithSelected:[NSString stringWithFormat:@"%d",type_id]  andLevel:1 andSelected:selectedStatus];
    
    NSString *deptId;
    
    for (int j=0;j<[tempEpArray count]; j++) {
        
        Emp *emp=[tempEpArray objectAtIndex:j];
        if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
            continue;
        }

        NSArray *empArray = [_conn getEmpByEmpId:emp.emp_id];
        for (Emp *_emp in empArray)
        {
            _emp.isSelected = selectedStatus;
            [self updateNowSelectedEmp:_emp];
        }
    }
	[self displayNowSelectedEmp];
    
}
//最近讨论组 选中或未选中
-(void)selectByGroupType:(int)type_id status:(bool)selectedStatus andConvId:(NSString *)conv_id
{
    
    NSArray *tempEpArray=[_ecloud getRecentGroupMemberWithSelected:[NSString stringWithFormat:@"%d",type_id] andLevel:2 andSelected:selectedStatus andConvId:conv_id];
    
    NSString *deptId;
    
    for (int j=0;j<[tempEpArray count]; j++) {
        
        Emp *emp=[tempEpArray objectAtIndex:j];
        
        if (emp.emp_id != _conn.userId.intValue)
        {
            if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
                continue;
            }
            NSArray *empArray = [_conn getEmpByEmpId:emp.emp_id];
            for (Emp *_emp in empArray)
            {
                _emp.isSelected = selectedStatus;
                [self updateNowSelectedEmp:_emp];
            }
        }
    }
    [self displayNowSelectedEmp];
    
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
        
		if(!isNowSelected && ![self isEmpInOldEmpIdArray:emp])
		{
            if ((self.typeTag == type_app_select_contacts || self.typeTag == type_app_select_contact_gome || self.typeTag == type_add_miliao_conv) && self.isSingleSelect) {
                
                for (Emp *_emp in self.nowSelectedEmpArray) {
                    NSArray *empArray = [_conn getEmpByEmpId:_emp.emp_id];
                    for (Emp *_emp in empArray)
                    {
                        _emp.isSelected = false;
                    }
                }
                [LogUtil debug:[NSString stringWithFormat:@"%s 是单选，需要先删除原来的",__FUNCTION__]];
                [self.nowSelectedEmpArray removeAllObjects];
                
                for (id _id in self.itemArray) {
                    if ([_id isKindOfClass:[Emp class]]) {
                        Emp *tempEmp = (Emp *)_id;
                        if (tempEmp.emp_id == emp.emp_id) {
                            tempEmp.isSelected = true;
                        }else{
                            tempEmp.isSelected = false;
                        }
                    }
                }
            }
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
//	for(Emp * _emp in self.nowSelectedEmpArray)
//	{
////		NSLog(@"%@",_emp.emp_name);
//	}
}

//修改内存里员工的选中状态 udate by shisp 原来是遍历数组的方式，现在修改为dic方式
- (void)setEmp:(int)emp_id andSelected:(bool)selectedStatus
{
    NSArray *empArray = [_conn getEmpByEmpId:emp_id];
    for (Emp *_emp in empArray)
    {
        _emp.isSelected = selectedStatus;
    }
}

-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus
{
    NSArray *empArray = [_conn getEmpByEmpId:emp_id];
    
    for (Emp *_emp in empArray)
    {
        _emp.isSelected = selectedStatus;
        [self updateNowSelectedEmp:_emp];
    }
	[self displayNowSelectedEmp];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_searchBar resignFirstResponder];
     backgroudButton.hidden=YES;
}

//如果群组的总人数已经超过了最大数，则不能再添加
- (BOOL)needShowAlert
{
    if(maxGroupNum < self.oldEmpIdArray.count)
    {
        [self showGroupNumExceedAlert];
        return YES;
    }
    return NO;
}




#pragma mark ===========点击头像可以打开用户资料===========

- (void)addGesture:(NewEmpSelectCell *)empCell
{
    UIImageView *logoView = (UIImageView *)[empCell viewWithTag:emp_logo_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openPersonInfo:)];
    [logoView addGestureRecognizer:singleTap];
    [singleTap release];
}

-(void)openPersonInfo:(UIGestureRecognizer*)gesture
{
    isDetailAction = YES;
    UIImageView *logoView = gesture.view;
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    NSString *empIdStr = empIdLabel.text;
    
    [NewOrgViewController openUserInfoById:empIdStr andCurController:self];
}

//用户点击取消或者确定后，要把选中的人员的状态，设置为非选中

#pragma mark ======转发消息时 新建会话=========
-(void) createConvWhenTransferMsg{
    //	关闭键盘
	[searchTextView resignFirstResponder];
    
    if (self.nowSelectedEmpArray.count <= 1) {
        return;
    }
    
    //    update by shisp
    if ([self.nowSelectedEmpArray count] == 2)
    {
        //单聊
        Emp *emp=[self.nowSelectedEmpArray objectAtIndex:1];
        self.newConvId = [StringUtil getStringValue:emp.emp_id];
        self.newConvTitle = emp.emp_name;
        self.newConvType = singleType;
        
        UIAlertView *sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:emp.emp_name delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
        [self setAlertViewTitleAndMessage:sendAlert];
        
        [sendAlert dismissWithClickedButtonIndex:0 animated:YES];
        
        [sendAlert show];
        [sendAlert release];
    }
    else
    {
        self.newConvType = mutiableType;
        [self createConv];
    }
}
    
- (void)createConv
    {
        //标题
//        if (isComeFromFileAssistant) {
//            //文件助手批量转发群聊标题
//            ConvRecord *_convRecord = [self.forwardRecordsArray objectAtIndex:0];
//            self.newConvTitle = [[talkSessionUtil2 getTalkSessionUtil]getTitleStrByConvRecord:_convRecord];
//        }
//        else{
////            self.newConvTitle = [[talkSessionUtil2 getTalkSessionUtil]getTitleStrByConvRecord:self.forwardRecord];
//        }
        
        //    标题
//        self.newConvTitle = [[talkSessionUtil2 getTalkSessionUtil]getTitleStrByConvRecord:self.forwardRecord];
        //    要加上自己
        [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
        
//        要获取
        self.newConvTitle = [talkSessionUtil2 getDefaultTitle:mutiableType andConvEmpArray:self.nowSelectedEmpArray];

        self.newConvId = nil;

//        首先检查下是否有可用的群组，如果有再判断下这个群组是否已经创建，如果已经创建则直接使用，否则发起创建
        BOOL needCreate = YES;
        
        Conversation *oldConv = [_ecloud searchConvsationByConvEmps:self.nowSelectedEmpArray];
        if (oldConv) {
            self.newConvId = oldConv.conv_id;
            if (oldConv.last_msg_id == -1)
            {
                //                    群组已经存在并且还没有真正创建，需要发起创建
//                群组已经存在，但没有创建，这时标题是
                self.newConvTitle = oldConv.conv_title;
            }
            else
            {
                needCreate = NO;
                
//                找到可复用的群组，并且已经创建
                
//                如果是转发类型，则提示是否转发
                if (self.typeTag == type_transfer_msg_create_new_conversation) {
                    //                    群组已经存在并且已经创建，只需要发送即可
                    [self showTransferToGroupTips];
                }
                //                如果是创建会话，则直接进入可复用会话的聊天界面
                else if (self.typeTag == type_create_conversation)
                {
                    talkSession = [talkSessionViewController getTalkSession];
                    //	创建多人会话
                    talkSession.titleStr = oldConv.conv_title;
                    talkSession.talkType = mutiableType;
                    talkSession.convId = oldConv.conv_id;
                    talkSession.convEmps = self.nowSelectedEmpArray;
                    talkSession.needUpdateTag = 1;
                    talkSession.last_msg_id = oldConv.last_msg_id;
                    
                    [self hideAndNotifyOpenTalkSession:talkSession];
                }
//                如果是添加群组成员，并且找到了可以复用的群组
                else if (self.typeTag == type_add_conv_emp)
                {
                    talkSession = [talkSessionViewController getTalkSession];
                    
                    talkSession.convId = oldConv.conv_id;
                    talkSession.talkType = mutiableType;
                    talkSession.titleStr = oldConv.conv_title;
                    talkSession.convEmps = self.nowSelectedEmpArray;
                    talkSession.needUpdateTag = 1;
                    [talkSession refresh];
                    
                    chatMessageViewController *chatMessage = (chatMessageViewController *)(self.delegete);
                    chatMessage.convId = oldConv.conv_id;
                    chatMessage.titleStr = oldConv.conv_title;
                    chatMessage.talkType = mutiableType;
                    chatMessage.start_Delete = NO;
                    chatMessage.dataArray= self.nowSelectedEmpArray;//talkSession.convEmps;
                    [chatMessage showMemberScrollow];
                    //	[self.navigationController popViewControllerAnimated:YES];
                    [self.navigationController dismissModalViewControllerAnimated:YES];
                }
            }
        }

        if (needCreate) {
            
            if ([UserTipsUtil checkNetworkAndUserstatus]) {
                [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
                [[LCLLoadingView currentIndicator]show];
                
                //    会话id
                if (self.newConvId == nil) {
                    self.newConvId = [talkSessionUtil2 getNewConvIdByNowTime:[_conn getSCurrentTime]];
                }
                
                if(![_conn createConversation:self.newConvId andName:self.newConvTitle andEmps:self.nowSelectedEmpArray])
                {
                    //        提示不能创建群聊
                    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                    UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"group_creat_group_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                }
            }
        }

    }

    
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
        NSLog(@"Cancel Button Pressed");
        break;
        case 1:
        {
            //            update by shisp
            if (self.newConvType == singleType)
            {
                //                检查本地是否存在此单聊会话
                Emp *emp=[self.nowSelectedEmpArray objectAtIndex:0];
                [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:self.newConvId andTitle:self.newConvTitle];
            }
            
            for (ConvRecord *_convRecord in  self.forwardRecordsArray) {
                _convRecord.conv_id = self.newConvId;
                _convRecord.conv_type = self.newConvType;
            }
            
//            if (self.transferFromType == transfer_from_talksession || self.transferFromType == transfer_from_image_preview) {
                //        来自图片预览界面 或 聊天界面的转发
                if ([self saveAndSendForwardMsg]) {
                    if ([_fromWhere isEqualToString:RECEIVE_MAP_VIEW_CONTROLLER]) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:DISMISS object:self];
                        [self dismissModalViewControllerAnimated:YES];
                    }
                    if (self.isComeFromFileAssistant){
                        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                        talkSession.talkType = self.newConvType;
                        talkSession.titleStr = self.newConvTitle;
                        talkSession.convId = self.newConvId;
                        talkSession.needUpdateTag = 1;
                        
                        // 关闭当前界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
                        
                        //刷新文件助手页面
                        [[NSNotificationCenter defaultCenter] postNotificationName:FILE_ASSISTANT_REFRESH object:nil];

                    }
                    if (self.forwardingDelegate && [self.forwardingDelegate respondsToSelector:@selector(showTransferTips)]) {
                        [self.forwardingDelegate showTransferTips];
                    }
                }
                return;
//            }
            
//            //查看聊天信息的转发
//            if (self.isComeFromChatHistory) {
//                //历史消息转发
//                ChatHistoryView *chatHistoryView = [ChatHistoryView getTalkSession];
//                BOOL saveSuccess = [chatHistoryView saveForwardMsg];
//                
//                if (!saveSuccess)
//                {
//                    //        保存失败，直接关闭当前的窗口
//                    [self dismissModalViewControllerAnimated:YES];
//                }
//                else
//                {
//                    //        如果转发的会话id和原来的会话id相同，那么需要刷新界面
//                    //       转发页面不刷新
//                    if ([self.newConvId isEqualToString:chatHistoryView.convId])
//                    {
//                        chatHistoryView.rollToEnd = YES;
//                    }
//                    
//                    chatHistoryView.sendForwardMsgFlag = YES;
//                    //        关闭当前界面
//                    [self dismissModalViewControllerAnimated:YES];
//                }
//            }
//            else if (self.isComeFromFileAssistant){
//                //文件助手的转发
//                for (ConvRecord *_convRecord in  self.forwardRecordsArray) {
//                    _convRecord.conv_id = self.newConvId;
//                    _convRecord.conv_type = self.newConvType;
//                }
//
//                talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
//                
//                //保存要转发的消息
//                BOOL saveSuccess = [talkSession saveFileAssistantForwardMsgsArray:self.forwardRecordsArray];
//                
//                if (!saveSuccess){
//                    //保存失败，直接关闭当前的窗口
//                    [self dismissModalViewControllerAnimated:YES];
//                }
//                else{
//                    talkSession.sendFileAssistantForwardMsgFlag = YES;
//                    talkSession.talkType = self.newConvType;
//                    talkSession.titleStr = self.newConvTitle;
//                    talkSession.convId = self.newConvId;
//                    talkSession.needUpdateTag = 1;
//                   
//                    // 关闭当前界面
//                    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
//                    
//                    //刷新文件助手页面
//                    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_ASSISTANT_REFRESH object:nil];
//
//                    [self dismissModalViewControllerAnimated:YES];
//                }
//            }
        }
        break;
        default:
        break;
    }
}

- (BOOL)saveAndSendForwardMsg
{
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    //    把转发一条记录当成转发多条记录的一种情况
    if (self.forwardRecord) {
        self.forwardRecordsArray = [NSArray arrayWithObject:self.forwardRecord];
    }else{
        //        修改转发记录的convid和convtype
        for (int i = 0; i < self.forwardRecordsArray.count; i ++) {
            ConvRecord *_convRecord = self.forwardRecordsArray[i];
            _convRecord.conv_id = self.newConvId;
            _convRecord.conv_type = self.newConvType;
        }
    }
    //    如果没有转发的记录 直接关闭
    if (self.forwardRecordsArray.count == 0) {
        [self dismissModalViewControllerAnimated:YES];
    }else{
        //如果转发的会话id和原来的会话id相同，那么需要刷新界面
        if ([self.newConvId isEqualToString:talkSession.convId])
        {
            talkSession.needUpdateTag = 1;
        }
        //     保存并转发多个
        [[ForwardMsgUtil getUtil]saveAndSendForwardMsgArray:self.forwardRecordsArray];
        
        [self dismissModalViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}
//{
//    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
//    
//    talkSession.forwardRecord = self.forwardRecord;
//    //    保存要转发的消息
//    BOOL saveSuccess = [talkSession saveForwardMsg];
//    
//    if (!saveSuccess)
//    {
//        //        保存失败，直接关闭当前的窗口
//        [self dismissModalViewControllerAnimated:YES];
//        return NO;
//    }
//    else
//    {
//        //        如果转发的会话id和原来的会话id相同，那么需要刷新界面
//        if ([self.newConvId isEqualToString:talkSession.convId])
//        {
//            talkSession.needUpdateTag = 1;
//        }
//        //                    talkSession.sendForwardMsgFlag = YES;
//        //        关闭当前界面
//        [self dismissModalViewControllerAnimated:YES];
//        
//        [talkSession sendForwardMsg];
//        return YES;
//    }
//}

// add by shisp 提示是否需要转发到群组
- (void)showTransferToGroupTips
{
    UIAlertView *sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:[NSString stringWithFormat:[StringUtil getLocalizableString:@"group_groupChats_d"],[self.nowSelectedEmpArray count]] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];

    [self setAlertViewTitleAndMessage:sendAlert];
    
    [sendAlert show];
    [sendAlert release];
}

#pragma mark - 流量提醒
- (void)setAlertViewTitleAndMessage:(UIAlertView *)sendAlert{
    int netType = [ApplicationManager getManager].netType;
    
    NSString *conv_title = @"";
    if ([self.nowSelectedEmpArray count] == 2)
    {
        //单聊
        Emp *emp=[self.nowSelectedEmpArray objectAtIndex:1];
        conv_title = [NSString stringWithFormat:@"%@",emp.emp_name];
    }
    else{
        conv_title = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_groupChats_d"],[self.nowSelectedEmpArray count]];
    }
    
    if(netType == type_gprs)
    {
        if (self.isComeFromFileAssistant){
            sendAlert.title = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"group_sure_sendTo"],conv_title];
            sendAlert.message = [NSString stringWithFormat:[StringUtil getLocalizableString:@"forward_gprs_tips"],[ForwardingRecentViewController getForwardFilesTotalSize:self.forwardRecordsArray]];
        }
        else if (self.forwardRecord.msg_type == type_file){
            sendAlert.title = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"group_sure_sendTo"],conv_title];
            NSString *fileSize = [StringUtil getDisplayFileSize:[forwardRecord.file_size intValue]];
            sendAlert.message = [NSString stringWithFormat:[StringUtil getLocalizableString:@"forward_gprs_tips"],fileSize];
        }
        else{
            sendAlert.title = [StringUtil getLocalizableString:@"group_sure_sendTo"];
            sendAlert.message = conv_title;
        }
    }
    else{
        sendAlert.title = [StringUtil getLocalizableString:@"group_sure_sendTo"];
        sendAlert.message = conv_title;
    }
}

#pragma mark - UISearchDisplayDelegate协议方法
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    NSLog(@"%s",__FUNCTION__);
    organizationalTable.scrollsToTop = NO;
    controller.searchResultsTableView.scrollsToTop = YES;
    
    self.searchDisplayController.searchBar.showsCancelButton = YES;
    UIButton *cancelButton = nil;
    
    if(IOS7_OR_LATER){
        
        UIView *topView = self.searchDisplayController.searchBar.subviews[0];
        for (UIView *subView in topView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                cancelButton = (UIButton*)subView;
            }
        }
        
        if (cancelButton) {
            [cancelButton setTitle: [StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        }
    }else
    {
        for (UIView *subView in self.searchDisplayController.searchBar.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                cancelButton = (UIButton*)subView;
            }
        }
        
        if (cancelButton) {
            [cancelButton setTitle: [StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
            
        }
    }
    
    
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    NSLog(@"%s",__FUNCTION__);

    isSearch = NO;
    backgroudButton.hidden=YES;
    organizationalTable.scrollsToTop = YES;
    controller.searchResultsTableView.scrollsToTop = NO;

}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    NSLog(@"%s",__FUNCTION__);

    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"%s",__FUNCTION__);
    
    [self setSearchResultsTitle:@""];
    
    //    if (firstSearch) {
    //        CGRect searchFrame = self.searchDisplayController.searchResultsTableView.frame;
    //        searchFrame.size.height -= 66.0;
    //        self.searchDisplayController.searchResultsTableView.frame = searchFrame;
    //
    //        firstSearch = NO;
    //    }
    
    CGRect frame = bottomNavibar.frame;
    frame.origin.y = SCREEN_HEIGHT - STATUSBAR_HEIGHT - BOTTOM_BAR_HEIGHT;
    //    frame.origin.y += 44.0;
    bottomNavibar.frame = frame;
    
    //    if (firstSearch) {
    CGRect searchFrame = self.searchDisplayController.searchResultsTableView.frame;
    
    searchFrame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - BOTTOM_BAR_HEIGHT;
    
    self.searchDisplayController.searchResultsTableView.frame = searchFrame;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"%s",__FUNCTION__);

    CGRect frame = bottomNavibar.frame;
    frame.origin.y = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - BOTTOM_BAR_HEIGHT;
    bottomNavibar.frame = frame;
    backgroudButton.hidden=YES;
}

#pragma mark - 搜索提示
- (void)setSearchResultsTitle:(NSString *)title{
    NSLog(@"%s",__FUNCTION__);

    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:title];
        }
    }
}

- (void)showSearchTip:(NSString *)title{
    NSLog(@"%s",__FUNCTION__);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
    [alert show];
}

#pragma mark ===========用户状态变化，刷新=============
- (void)empStatusChange:(NSNotification *)_notificatio
{
    if (self.deptNavArray.count >= 2)
    {
        id temp= [self.deptNavArray lastObject];
        if ([temp isKindOfClass:[Dept class]])
        {
            Dept *dept = (Dept *)temp;
            if (dept.dept_type == type_dept_normal)
            {
                [organizationalTable reloadData];
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
                                [organizationalTable beginUpdates];
                                [organizationalTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                [organizationalTable endUpdates];
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

- (void)initSearchBarWithFrame:(CGRect)_frame
{
    //查询bar
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getLocalizableString:@"chats_search"];
    
//    _searchBar.backgroundColor = [UIColor redColor];
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchdispalyCtrl.active = NO;
    searchdispalyCtrl.delegate = self;
    searchdispalyCtrl.searchResultsDelegate=self;
    searchdispalyCtrl.searchResultsDataSource = self;
    
    self.searchResults = [NSMutableArray array];
}

//增加一个方法，隐藏选择联系人的界面，并通知会话列表界面，打开一个会话
- (void)hideAndNotifyOpenTalkSession:(talkSessionViewController *)talkSession
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

//add by shisp 检查网络是否正常
//+ (BOOL)checkNetworkAndUserstatus
//{
//    conn *_conn = [conn getConn];
//    
//    if (!((AppDelegate*)[UIApplication sharedApplication].delegate).isNetworkOk) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"check_network"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
//        return NO;
//    }
//    else if (_conn.userStatus != status_online)
//    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"user_is_offline"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
//        return NO;
//    }
//    return YES;
//}


//把searchBar加到self.view中
- (void)initAndAddSearchBar
{
    //查询bar
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getLocalizableString:@"chats_search"];
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    [self.view addSubview:_searchBar];
    [_searchBar release];
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchdispalyCtrl.active = NO;
    searchdispalyCtrl.delegate = self;
    searchdispalyCtrl.searchResultsDelegate=self;
    searchdispalyCtrl.searchResultsDataSource = self;
    
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
}

//是否支持横竖屏

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"%s main screen is %@",__FUNCTION__,NSStringFromCGRect( [UIScreen mainScreen].bounds));
    
    CGRect _frame = bottomNavibar.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        NSLog(@"%s 不需要重新布局",__FUNCTION__);
        return;
    }
    NSLog(@"%s 需要重新布局",__FUNCTION__);
    
    _frame = organizationalTable.frame;
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - _searchBar.frame.size.height - BOTTOM_BAR_HEIGHT;
    organizationalTable.frame = _frame;
    
    _frame = scrollView.frame;
    _frame.size.height = organizationalTable.frame.size.height;
    scrollView.frame = _frame;
    
    UILabel *lineBreak = (UILabel *)[scrollView viewWithTag:100];
    _frame = lineBreak.frame;
    _frame.size.height = scrollView.frame.size.height;
    lineBreak.frame = _frame;
    
    _frame.size.width = SCREEN_WIDTH;
    _frame.origin.y = _searchBar.frame.size.height + organizationalTable.frame.size.height;
    bottomNavibar.frame = _frame;
    
    [self bottomScrollviewShow];
    
//    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY-21, self.view.frame.size.width, 66.0)];
//    bottomNavibar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
//    [self.view addSubview:bottomNavibar];
//    [bottomNavibar release];
}


#pragma mark ========可以根据不同公司显示不同的通讯录首页===========

- (void)prepareLANGUANGItems
{
    NSArray *tempArray = [NewOrgViewController getXIANGYUANRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}
- (void)prepareCsairOrgItems
{
    NSArray *tempArray = [NewOrgViewController getCsairRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}

- (void)prepareBGYOrgItems
{
    NSArray *tempArray = [NewOrgViewController getBGYRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}


- (void)prepareOrgItems
{
    NSArray *tempArray = [NewOrgViewController getRootOrgItems];
    self.orgItemArray = [NSMutableArray arrayWithArray:tempArray];
}

//判断是否显示通讯录首页
- (BOOL)displayRootOrg
{
    if (self.deptNavArray.count == 1) {
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

//展开部门
- (void)extendDept:(Dept *)dept
{
    [self.deptNavArray addObject:dept];
    [self getRootItem];
    [self refreshNaviBar];
    [organizationalTable setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    [organizationalTable reloadData];
}

//处理tableView的select事件
- (void)processTableViewDidSelect:(id)temp
{
    if([temp isKindOfClass:[Dept class]]){
        Dept *dept = (Dept *)temp;
        [self extendDept:dept];
    }else if([temp isKindOfClass:[Emp class]]){
        
        int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
//        //	找到复选框所在的行
//        int row =indexPath.row;
//        //	取出对应行的对象是一个部门还是一个员工
//        id temp=[self.itemArray objectAtIndex:row];
        //       选中的是员工
        Emp *emp=(Emp *)temp;
        BOOL isOldMember=FALSE;
        if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]] ||  emp.emp_id == _conn.curUser.emp_id) {
            isOldMember = true;
        }
        if (isOldMember) {
            return;
        }
        
        if(!emp.permission.canSendMsg)
        {
            [PermissionUtil showAlertWhenCanNotSendMsg:emp];
            return;
        }
        
        if (emp.isSelected) { //不选中
            emp.isSelected=false;
            
        }else   //选中
        {
            
            if([self needShowAlert])
                return;
            
            if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
                [self showGroupNumExceedAlert];
                return;
            }
            
            emp.isSelected=true;
        }
        [self selectByEmployee:emp.emp_id status:emp.isSelected];
        
//        如果现在是搜索状态，那么需要刷新搜索结果view
        if (self.searchDisplayController.isActive) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        }else{
            [organizationalTable reloadData];
        }
        //显示在底部
        [self bottomScrollviewShow];
        
        [self refreshSelectBtn];
    }
    else if([temp isKindOfClass:[Conversation class]]){
        if (self.typeTag == type_create_conversation ){
            //创建新会话点击固定群组或我的群组 直接发起会话
            Conversation *_conv = (Conversation *)temp;
            [self openConversation:_conv];
        }
        else if (self.typeTag == type_transfer_msg_create_new_conversation){
            //转发点击固定群组或我的群组 直接转发到会话
            [self.navigationController popViewControllerAnimated:YES];
            Conversation *_conv = (Conversation *)temp;
            [[NSNotificationCenter defaultCenter] postNotificationName:FORWARD_TO_EXIST_GROUP object:_conv];
        }
        else{
            Conversation *conv = (Conversation *)temp;
            [self.deptNavArray addObject:conv];
            [self getRootItem];
            [self refreshNaviBar];
            [organizationalTable setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
            [organizationalTable reloadData];
        }
    }
}


#pragma mark =====获取用户资料应答========
- (void)returnSelectUserOfGOME1
{
    Emp *_emp = self.nowSelectedEmpArray[0];
    _emp = [_ecloud getEmpInfo:[StringUtil getStringValue:_emp.emp_id]];

    //    如果还没有获取用户资料，又要求显示全部资料，那么先去获取资料
    if (_emp.info_flag){
//        发送通知
        [self returnSelectUserOfGOME2:_emp];
    }else{
        NSLog(@"用户资料还没有获取，并且要求显示全部资料，所以需要从服务器端取数据");
        if ([UserTipsUtil checkNetworkAndUserstatus]) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"loading"]];
            [[conn getConn] getUserInfo:_emp.emp_id];
        }
    }
}

/*
 功能描述
 国美选人接口
 
 返回值是一个数组，数组里只有一个字典
 empId：取empCode的值
 empName：取empName的值
 deptName：取部门的名称
 position：取职位的名称
 
 通知名称是：SEND_USER_TO_GOME_APP_NOTIFICATION
 */

- (void)returnSelectUserOfGOME2:(Emp *)_emp{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
    if (!_emp.empCode.length) {
        _emp.empCode = @"";
    }
    if (!_emp.emp_name.length) {
        _emp.emp_name = @"";
    }
    if (!_emp.deptName.length) {
        _emp.deptName = @"";
    }
    if (!_emp.titleName.length) {
        _emp.titleName = @"";
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    
    NSString *tempEmpCode = _emp.empCode;
    NSRange _range = [tempEmpCode rangeOfString:@"a" options:NSCaseInsensitiveSearch];
    if (_range.length) {
        tempEmpCode = [tempEmpCode substringToIndex:_range.location];
    }
    
    [mDic setValue:tempEmpCode forKey:@"empId"];
    [mDic setValue:_emp.emp_name forKey:@"empName"];
    [mDic setValue:_emp.deptName forKey:@"deptName"];
    [mDic setValue:_emp.titleName forKey:@"position"];
    
    [[NotificationUtil getUtil]sendNotificationWithName:@"SEND_USER_TO_GOME_APP_NOTIFICATION" andObject:nil andUserInfo:mDic];
    
    [self backButtonPressed:nil];

}

- (void)processGetUserInfo:(NSNotification *)notification{
    [UserTipsUtil hideLoadingView];
    eCloudNotification *_notification = [notification object];
    if(_notification != nil)
    {
        int cmdId = _notification.cmdId;
        switch (cmdId) {
            case get_user_info_success_new:
            {
                NSLog(@"get user info success new");
                
                Emp *_emp = self.nowSelectedEmpArray[0];

                NSString* empId = [_notification.info objectForKey:@"EMP_ID"];
//                如果是用户选择的用户，那么就发出通知给国美
                if (empId.intValue == _emp.emp_id)
                {
                    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
                    _emp = [_ecloud getEmpInfo:empId];
                    [self returnSelectUserOfGOME2:_emp];
                }
            }
                break;
            case get_user_info_timeout_new:
            {
                NSLog(@"get user info timeout new ");
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"personinfo_get_user_info_timeout"]];
            }
                break;
                
            case get_user_info_failure_new:
            {
                NSLog(@"get user info failure new ");
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"personinfo_get_user_info_fail"]];
            }
                break;
        }
    }
}

//设置全选按钮
- (void)setUnSelectAllBtn:(UIButton *)rightButton
{
    if ([UIAdapterUtil isGOMEApp]) {
        [rightBtn setTitle:[StringUtil getAppLocalizableString:@"un_select_all"] forState:UIControlStateNormal];
    }else{
        [rightBtn setBackgroundImage:[StringUtil getImageByResName:@"deselectallBtn.png"] forState:UIControlStateNormal];
    }

}
//设置反选按钮
- (void)setSelectAllBtn:(UIButton *)rightButton
{
    if ([UIAdapterUtil isGOMEApp]) {
        [rightBtn setTitle:[StringUtil getAppLocalizableString:@"select_all"] forState:UIControlStateNormal];

    }else{
        [rightBtn setBackgroundImage:[StringUtil getImageByResName:@"selectallBtn.png"] forState:UIControlStateNormal];
    }

}

@end
