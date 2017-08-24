//
//  specialChooseMemberViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-10.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "specialChooseMemberViewController.h"
#import "eCloudDefine.h"

#import "Conversation.h"
#import "eCloudUser.h"
#import "organizationalViewController.h"
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
#import "EmpSelectCell.h"
#import "DeptSelectCell.h"
#import "DeptCell.h"
#import "GroupSelectCell.h"
#import "UIAdapterUtil.h"

#import "PermissionUtil.h"
#import "PermissionModel.h"

#import "JsObjectCViewController.h"
#import "APPListDetailViewController.h"

#import "userInfoViewController.h"

#import "UserDataDAO.h"

#import "DeptInMemory.h"

#import "UserTipsUtil.h"
#import "UserDataConn.h"

#import "talkSessionUtil2.h"
#import "Emp.h"
#import "Dept.h"
#import "ConvRecord.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "AdvancedSearchViewController.h"
#import "rankChooseViewController.h"
#import "businessChooseViewController.h"
#import "zoneChooseViewController.h"

@interface specialChooseMemberViewController ()
{
    
}
//添加常用联系人使用到的员工id数组
@property (nonatomic,retain) NSMutableArray *commonEmpIdArray;
@end
@implementation specialChooseMemberViewController
{
	eCloudDAO *_ecloud ;
    UIScrollView *changeScrollview;
    AdvanceQueryDAO *advanceQueryDAO;
     bool isCanHundred;
    UserDataDAO *userDataDAO;
    
    UserDataConn *userDataConn;
    
//    是否需要设置已经选择的人员的状态
    BOOL needUnselectEmp;
}
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

-(void)dealloc
{
	NSLog(@"%s",__FUNCTION__);
    [titleview release];
    self.rankLabel = nil;
    self.bussinesslLabel = nil;

    self.newConvId = nil;
    self.newConvTitle = nil;
    
    self.forwardRecord = nil;

    self.commonEmpIdArray = nil;
    
    self.mOldEmpDic = nil;
    
    self.searchStr = nil;
    self.searchTimer = nil;
    
	self.nowSelectedEmpArray=nil;
	self.oldEmpIdArray = nil;
	self.delegete = nil;
	self.itemArray = nil;
	self.employeeArray = nil;
	
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
			self.employeeArray =  [NSMutableArray arrayWithArray:[_conn getAllEmpInfoArray]];
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
            [userDataDAO addCommonEmp:self.commonEmpIdArray andIsDefault:NO];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case update_user_data_fail:
            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"specialChoose_addCommonContacts_fail"]];
            break;
        case update_user_data_timeout:
            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"specialChoose_addCommonContacts_timeout"]];
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
           
            
            [self showTransferToGroupTips];
           
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
    isAdvancedSearch=YES;
    [self.navigationController pushViewController:advancedSearch animated:YES];
    [advancedSearch release];
}
-(void)chooseButtonPressed:(id)sender
{
    leftButton.hidden=NO;
    self.title=[StringUtil getLocalizableString:@"specialChoose_filter"];
    isAdvancedSearch=YES;
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
    
    changeScrollview.contentOffset=CGPointMake(320, 0);
    
    
}
-(void)toLeftPressed:(id)sender
{
    leftButton.hidden=YES;
    self.title=[StringUtil getLocalizableString:@"specialChoose_choose_contacts"];
    
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
    self.bussinesslLabel.text=[StringUtil getLocalizableString:@"specialChoose_business"];
    self.rankLabel.text=[StringUtil getLocalizableString:@"specialChoose_level"];
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
    
    userDataDAO = [UserDataDAO getDatabase];
    userDataConn = [UserDataConn getConn];
    
    self.typeArray=[_ecloud getTypeArray];
    isSearch=NO;
    isExpand=YES;
    isNeedSearchAgain=NO;
    isDetailAction=NO;
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
           
    self.title=[StringUtil getLocalizableString:@"specialChoose_choose_contacts"];
//    [self.navigationController.t]
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    //	组织架构展示table
	int tableH = 460 - 84 - 44;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    changeScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320, tableH+84)];
    changeScrollview.showsHorizontalScrollIndicator = YES;
    changeScrollview.showsVerticalScrollIndicator = YES;
    [self.view addSubview:changeScrollview];
    [changeScrollview release];

    [[eCloudUser getDatabase]getPurviewValue];
    isCanHundred=[[eCloudUser getDatabase]isCanHundred];
    
    //	查询bar
    float searchBarW = self.view.frame.size.width;
    float searchBarH = 40;
    if (isCanHundred) {
        searchBarW = searchBarW - 55;
    }
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, searchBarW, searchBarH)];
	_searchBar.delegate=self;
//	_searchBar.placeholder=[StringUtil getLocalizableString:@"chats_search"];
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
//    _searchBar.showsCancelButton = isCanHundred;
//    for(id cc in [_searchBar subviews])
//    {
//        if([cc isKindOfClass:[UIButton class]])
//        {
//            UIButton *btn = (UIButton *)cc;
//            [btn setTitle:@"筛选"  forState:UIControlStateNormal];
//            btn.hidden=YES;
//        }
//    }
    //   [_searchBar becomeFirstResponder];
    
	[searchTextView setReturnKeyType:UIReturnKeyDone];
	
	[changeScrollview addSubview: _searchBar];
	[_searchBar release];
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

    organizationalTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, tableH) style:UITableViewStylePlain];
    [organizationalTable setDelegate:self];
    [organizationalTable setDataSource:self];
    organizationalTable.backgroundColor=[UIColor clearColor];
    [changeScrollview addSubview:organizationalTable];
    [organizationalTable release];
    
    backgroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, tableH)];
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    [organizationalTable addSubview:backgroudButton];
    [backgroudButton release];
    backgroudButton.hidden=YES;
    //-------筛选－－－－－－－
    self.zoneArray = [NSMutableArray array];
    advanceQueryDAO = [AdvanceQueryDAO getDataBase];
    self.chooseArray= [NSMutableArray array];
    
    leftButton = [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"specialChoose_contacts"] andTarget:self andSelector:@selector(toLeftPressed:)];
    leftButton.hidden=YES;
    
    
    chooseTable= [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, tableH+40) style:UITableViewStylePlain];
    [chooseTable setDelegate:self];
    [chooseTable setDataSource:self];
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
    
    titleview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    titleview.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    UIButton *titleButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
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
    
    
	//	add by shisp  注册组织架构信息变动通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
    
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	
    //	自定义导航栏
	int toolbarY = self.view.frame.size.height - 44-44;
    if (IOS7_OR_LATER)
    {
        toolbarY = toolbarY - 20;
    }
    
    UIView *bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY-21, 320, 66)];
//    [UIAdapterUtil customLightNavigationBar:bottomNavibar];
    bottomNavibar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    //分割线
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, bottomNavibar.frame.size.width, 1.0)];
    lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
    [bottomNavibar addSubview:lineLab];
    [lineLab release];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(260, 19, 50, 30);
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
//    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
//    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    
    [addButton setTitle:[StringUtil getLocalizableString:@"confirm"] forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:addButton];
    addButton.enabled=NO;
    
    
    bottomScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 260, 66)];
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
    for(UIView *view in [bottomScrollview subviews])
    {
        [view removeFromSuperview];
        view = nil;
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
    
    if ([selectArray count]==0) {
        addButton.enabled=NO;
        [addButton setTitle:[StringUtil getLocalizableString:@"confirm"] forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        
    }else
    {
        addButton.enabled=YES;
        NSString *titlestr=[NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"confirm"],[selectArray count]];
        [addButton setTitle:titlestr forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        if ([selectArray count]>80) {
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
        }
    }
    for (int i=0; i<[selectArray count]; i++) {
        cx=cx+iconSize + 15;
        if (i==0) {
            cx=0;
        }
        emp=[selectArray objectAtIndex:i];
        //		update by shisp icon大小设为30，否则和文字重叠
//        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+3,iconSize,iconSize)];
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+3,iconSize+4.5,iconSize+16)];
        
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(-1, iconSize+14 , iconSize+7, 55 - iconSize - 6)];
//        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(-5, iconSize , iconSize, 45 - iconSize - 6)];
        nameLabel.text=emp.emp_name;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment=UITextAlignmentCenter;
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont boldSystemFontOfSize:12];
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
    pageview.frame=CGRectMake(0, 0,x+cx+70,66);
	pageview.backgroundColor=[UIColor clearColor];
	[bottomScrollview addSubview:pageview];
    [pageview release];
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
    [self bottomScrollviewShow];
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
-(void)keepAdvancedSearchView
{
    changeScrollview.contentOffset=CGPointMake(320, 0);
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    needUnselectEmp = NO;
    
    maxGroupNum = _conn.maxGroupMember;
  
    [[eCloudUser getDatabase]getPurviewValue];
    isCanHundred=[[eCloudUser getDatabase]isCanHundred];
    
    if (isDetailAction) {
        isDetailAction=NO;
        return;
    }
    if (isAdvancedSearch) {//高级搜索返回
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
	self.oldEmpIdArray = [NSMutableArray array];
	self.nowSelectedEmpArray = [NSMutableArray array];
    
    if (_conn==nil) {
        _conn = [conn getConn];
    }
	if(self.typeTag == type_create_conversation)
	{
        if (_conn.curUser) {
            [self.oldEmpIdArray addObject:_conn.curUser];
        }
 	}
    else if(self.typeTag == type_transfer_msg_create_new_conversation)
    {
        
        if (_conn.curUser) {
            [self.oldEmpIdArray addObject:_conn.curUser];
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];

    }
	else if(self.typeTag == type_add_conv_emp)
	{
		[self.oldEmpIdArray addObjectsFromArray:((chatMessageViewController*)(self.delegete)).dataArray];
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
    [[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(handleCmd:)
												name:MODIFYMEBER_NOTIFICATION
											  object:nil];
    //	分组成员修改 超时通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];
   
    if (bottomScrollview!=nil) {
        [self bottomScrollviewShow];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if (needUnselectEmp) {
//        for (Emp *_emp in self.nowSelectedEmpArray) {
//            _emp.isSelected = false;
//        }
        [_conn setAllEmpNotSelect];
        [_conn setAllDeptsNotSelect];
    }
// update by shisp
    //    if (!isAdvancedSearch) {//不是 高级搜索返回
//        _searchBar.text = @"";
//    }
    [_searchBar resignFirstResponder];
     backgroudButton.hidden=YES;

    [[NSNotificationCenter defaultCenter]removeObserver:self name:MODIFYMEBER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];

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
    needUnselectEmp = YES;
    
    if (self.typeTag == type_schedule) {
        self.navigationController.navigationBarHidden = NO;
    }
	[self.navigationController popViewControllerAnimated:YES];
}

//隐藏查询输入框的键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[searchTextView resignFirstResponder];
}
#pragma mark 提醒用户选择人数已经超过最大值
-(void)showGroupNumExceedAlert
{
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
#pragma mark 选择后确定
-(void) addButtonPressed:(id) sender{
    needUnselectEmp = YES;
    //	关闭键盘
	[searchTextView resignFirstResponder];

    if (self.typeTag == type_transfer_msg_create_new_conversation) {
        [self createConvWhenTransferMsg];
        return;
    }
    if (self.typeTag == type_add_common_emp)
    {
        self.commonEmpIdArray = [NSMutableArray arrayWithCapacity:self.nowSelectedEmpArray.count];
        
//        发送数据到服务器，同步应答，成功后才入库
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
        
        //			判断选中的人员数量
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
//			如果是群聊，则不设置convId
			talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
			talkSession.needUpdateTag = 1;
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
            
            //	创建多人会话
			talkSession.titleStr=[StringUtil getLocalizableString:@"specialChoose_multi_session"];
			talkSession.talkType=mutiableType;
			talkSession.convId=nil;
			[self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
			talkSession.convEmps = self.nowSelectedEmpArray;
			talkSession.needUpdateTag = 1;
		}
        //		打开会话窗口
		[self.navigationController pushViewController:talkSession animated:YES];
        //		[self presentModalViewController:talkSession animated:YES];
		
	}
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
	if(((chatMessageViewController*)self.delegete).talkType == singleType)
	{
        //		原来是单人聊天
		talkSession.convId = nil;
		talkSession.titleStr=[StringUtil getLocalizableString:@"specialChoose_multi_session"];
		talkSession.talkType= mutiableType;
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
                return 40;
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
            UILabel *titlelabel=[[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)]autorelease];
            titlelabel.backgroundColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
            titlelabel.font=[UIFont systemFontOfSize:14];
            if (section==1) {
                titlelabel.text=[StringUtil getLocalizableString:@"specialChoose_organizational_structure"];
            }else
            {
                titlelabel.text=[StringUtil getLocalizableString:@"specialChoose_recent_contact"];
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
            if (indexPath.section==1) {//组织架构
                id temp=[self.itemArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[Dept class]]) {
                    return dept_row_height;
                }// Configure the cell.
                else {
                    return emp_row_height;
                }
            }
            else
            {
                id temp=[self.typeArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[Emp class]]) {
                    return emp_row_height;
                }
                else if ([temp isKindOfClass:[RecentGroup class]]) {
                    
                    return GroupCellHeight;
                }
                else
                {
                    return dept_row_height;
                }
                
            }
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
-(EmpSelectCell *)getEmpWithDeptCell:(NSIndexPath*)indexPath
{
    static NSString *empCellID = @"empDeptCellID";
	
	EmpSelectCell *empCell = [organizationalTable dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil)
	{
		empCell = [[[EmpSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
        [self addGesture:empCell];
	}
    UIButton *selectButton = (UIButton*)[empCell viewWithTag:emp_select_tag];
    selectButton.hidden=NO;
	Emp *emp = [self.itemArray objectAtIndex:indexPath.row];
    if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
        selectButton.hidden = YES;
    }

	[empCell configureWithDeptCell:emp];
	return empCell;

}
#pragma mark 获取员工的显示方式
-(EmpSelectCell *)getEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpSelectCell *empCell = [organizationalTable dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil)
	{
		empCell = [[[EmpSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
        [self addGesture:empCell];
	}
    UIButton *selectButton = (UIButton*)[empCell viewWithTag:emp_select_tag];
    selectButton.hidden=NO;
	Emp *emp = [self.itemArray objectAtIndex:indexPath.row];
    if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
        selectButton.hidden = YES;
    }
	[empCell configureCell:emp];
	return empCell;
}
#pragma mark 最近联系 获取员工的显示方式
-(EmpSelectCell *)getTypeEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpSelectCell *empCell = [organizationalTable dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil)
	{
		empCell = [[[EmpSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
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
-(EmpSelectCell *)getSearchEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpSelectCell *empCell = [chooseTable dequeueReusableCellWithIdentifier:empCellID];
    
	if(empCell == nil)
	{
		empCell = [[[EmpSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
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
- (DeptSelectCell *)getDeptSelectCell:(NSIndexPath *)indexPath search:(BOOL)isSearch
{
    static NSString *deptSelectCellID = @"deptSelectCellID";

    Dept *dept =[self.itemArray objectAtIndex:indexPath.row];
    
    DeptSelectCell *deptCell = [organizationalTable dequeueReusableCellWithIdentifier:deptSelectCellID];
    if (deptCell == nil) {
        deptCell = [[[DeptSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        
        UIButton *selectButton=(UIButton *)[deptCell viewWithTag:dept_select_btn_tag] ;
        [selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIButton *selectButton=(UIButton *)[deptCell viewWithTag:dept_select_btn_tag] ;
    selectButton.titleLabel.text = [StringUtil getStringValue:indexPath.row];
    if (dept.dept_parent == 0) {
        selectButton.hidden = YES;
    }
    [deptCell configCell:dept search:isSearch];
    
    return deptCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==organizationalTable)
    {
        //搜索结果
        if (isSearch)
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
        else//最近 ＋ 组织框架
        {
            if (indexPath.section == 0)
            {
                id temp=[self.typeArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[Emp class]]) {
                    cell.backgroundColor = [UIColor clearColor];
                }
                else
                {
                    cell.backgroundColor = [UIColor whiteColor];
                }
            }
            else
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
        }
    }
}

#pragma mark 只优化了一部分，主要针对组织架构部门做了展示优化，解决部门名称过长，覆盖在线人数或选择框的问题 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;

        if (tableView==organizationalTable) {
            
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
                UIButton *selectView=[[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)]autorelease];
                selectView.tag=5;
                selectView.backgroundColor=[UIColor clearColor];
                cell.accessoryView=selectView;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            }
            
        }
        
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
                return [self getEmpWithDeptCell:indexPath];
            }
        }else
        {
            
            if (indexPath.section==1)
            {
                id temp=[self.itemArray objectAtIndex:indexPath.row];
                if ([temp isKindOfClass:[Dept class]])
                {
                    return [self getDeptSelectCell:indexPath search:NO];
                }
                else
                {
                    return [self getEmpCell:indexPath];
                }
//                优化结束
            }
            else
            {
//                优化显示 最近讨论组，最近联系人，分别处理
//                RecentMember *typeObject = [[RecentMember alloc]init];
//                typeObject.type_name=@"最近讨论组";
//                typeObject.type_level=0;
//                typeObject.type_parent=0;
//                typeObject.type_id=1;
//                typeObject.isExtended=false;
//                typeObject.isChecked=false;
//                [types addObject:typeObject];
//                [typeObject release];
//                
//                RecentMember *typeObject1 = [[RecentMember alloc]init];
//                typeObject1.type_name=@"最近联系人";
//                typeObject1.type_level=0;
//                typeObject1.type_parent=0;
//                typeObject1.type_id=2;
//                typeObject1.isExtended=false;
//                typeObject1.isChecked=false;
//                [types addObject:typeObject1];
//                [typeObject1 release];
                
#define recent_font_size (17.0)
#define select_btn_size (40.0)
                
                id temp=[self.typeArray objectAtIndex:indexPath.row];
                
                if ([temp isKindOfClass:[RecentMember class]])
                {
                    RecentMember *itemobject=(RecentMember *)temp;
                    
                    //                展示最近讨论组条目
                    if (itemobject.type_id == 1)
                    {
                        UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                        
                        cell.textLabel.font=[UIFont systemFontOfSize:recent_font_size];
                        
                        [DeptSelectCell setImageView:cell.imageView andIsExtend:itemobject.isExtended];
                        
                        cell.textLabel.text=itemobject.type_name;
                        
                        return cell;
                    }
                    else if(itemobject.type_id == 2)
                    {
                        //                展示最近联系人
                        UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                        
                        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                        cell.textLabel.font=[UIFont systemFontOfSize:recent_font_size];
                        
                        [DeptSelectCell setImageView:cell.imageView andIsExtend:itemobject.isExtended];
                        
                        cell.textLabel.text=itemobject.type_name;
                        
                        //                        增加选择框
                        float w = cell.frame.size.width - select_btn_size;
                        float y = (cell.frame.size.height - select_btn_size) / 2;
                        UIButton *selectButton=[[UIButton alloc]initWithFrame:CGRectMake(w, y, select_btn_size, select_btn_size)];
                        selectButton.backgroundColor=[UIColor clearColor];
                        selectButton.titleLabel.text = [StringUtil getStringValue:[indexPath row]];
                        [cell.contentView addSubview:selectButton];
                        [selectButton release];
                        
                        [selectButton addTarget:self action:@selector(selectTypeAction:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [EmpSelectCell selectBtn:selectButton andSelected:itemobject.isChecked];
                        
                        return cell;
                    }
                }
                //展示最近讨论组明细下面的员工条目
                //展示最近联系人下面的员工条目
                else if([temp isKindOfClass:[Emp class]])
                {
                    return [self getTypeEmpCell:indexPath];
                    
                }
                //展示最近讨论组下面的明细条目
                else if([temp isKindOfClass:[RecentGroup class]])
                {
                    //                    可以复用
                    static NSString *recentGroupCellID = @"recentGroupCellID";
                    
                    GroupSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:recentGroupCellID];
                    if (!cell)
                    {
                        cell = [[[GroupSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recentGroupCellID]autorelease];
                        
                        UIButton *selectButton= [cell getSelectButton];
                        [selectButton addTarget:self action:@selector(selectTypeAction:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    RecentGroup *itemobject=(RecentGroup *)temp;
                    [cell configCell:itemobject];
                    
                    UIButton *selectButton= [cell getSelectButton];
                    selectButton.titleLabel.text = [StringUtil getStringValue:[indexPath row]];
                    
                    return cell;
                }
//                
//                
//                
//                UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
//                selectView.tag=5;
//                selectView.backgroundColor=[UIColor clearColor];
//                cell.accessoryView=selectView;
//                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
//                
//                UIButton *selectButton=(UIButton *)cell.accessoryView;
//                selectButton.tag=indexPath.row;
//                selectButton.hidden=NO;
//                [selectButton addTarget:self action:@selector(selectTypeAction:) forControlEvents:UIControlEventTouchUpInside];
//                selectButton.userInteractionEnabled=YES;
//                cell.textLabel.font=[UIFont systemFontOfSize:17];
//                
//                if ([temp isKindOfClass:[RecentMember class]]) {
//                    RecentMember *itemobject=(RecentMember *)temp;
//                    selectButton.userInteractionEnabled=NO;
//                    if (itemobject.type_id==2) {//最近联系人
//                        selectButton.userInteractionEnabled=YES;
//                        if (itemobject.isChecked) { //选中
//                            //                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
//                            //                        }else   //未选择
//                            {
//                                [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
//                                [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
//                                [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
//                                
//                            }
//                        }
//                        
//                        if (itemobject.isExtended) {
//                            cell.imageView.image=[StringUtil getImageByResName:@"arrow_down.png"];
//                        }else
//                        {
//                            cell.imageView.image=[StringUtil getImageByResName:@"arrow_right.png"];
//                        }
//                        
//                        cell.textLabel.text=itemobject.type_name;
//                        
//                    }else if([temp isKindOfClass:[Emp class]])
//                    {
//                        selectButton.hidden=YES;
//                        return [self getTypeEmpCell:indexPath];
//                        
//                    }else if([temp isKindOfClass:[RecentGroup class]])
//                    {
//                        cell.imageView.image=[StringUtil getImageByResName:@"Group_ios_40.png"];
//                        RecentGroup *itemobject=(RecentGroup *)temp;
//                        if (itemobject.isChecked) { //选中
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
//                        }else   //未选择
//                        {
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
//                            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
//                            
//                        }
//                        cell.textLabel.text=itemobject.type_name;
//                    }
//                
//                
//                
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
                titlelabel.text=[StringUtil getLocalizableString:@"specialChoose_region"];
                // detaillabel.text=@"全部地域";
                
            }else
            {
                id temp=[self.zoneArray objectAtIndex:indexPath.row-3];
                citiesObject *city=(citiesObject *)temp;
                titlelabel.text=city.some_cities;                cell.accessoryType=UITableViewCellAccessoryNone;
                
            }
            
        }else
        {
            
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
                    
                    NSArray *tempDeptArray=[_ecloud getLocalNextDeptInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked];
                   // NSArray *tempEpArray=[_ecloud getDeptEmpInfoWithSelected:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked];
                   
                    NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id  andLevel:level];
                    
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
                    
                    if (isExtendedPoint<noworigin) {
                        float offsetvalue=noworigin-sumnum;
                        if (offsetvalue<0) {
                            offsetvalue=noworigin;
                        }
                        tableView.contentOffset=CGPointMake(0,offsetvalue-20);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                    }else{
                        tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                    }
                    /*自动收起*///---------------------------------------------------------------end------------//
                    
                }
                
                [tableView reloadData] ;
            }
            else
            {
                int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
                
                //	找到复选框所在的行
                int row =indexPath.row;
                //	取出对应行的对象是一个部门还是一个员工
                id temp=[self.itemArray objectAtIndex:row];
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
                
                [organizationalTable reloadData];
                //    显示在底部
                [self bottomScrollviewShow];
            }
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
                            [self setEmp:emp1.emp_id andSelected:emp1.isSelected];
                        }
                        
                        NSMutableArray *allArray=[[NSMutableArray alloc]init];
                        [allArray addObjectsFromArray:tempEpArray];
//                        [pool release];
                        
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
//                        [pool release];
                        
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
                //	取出对应行的对象是一个部门还是一个员工
                id temp=[self.typeArray objectAtIndex:row];
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
                
                [organizationalTable reloadData];
                //    显示在底部
                [self bottomScrollviewShow];
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
                        [self setEmp:emp1.emp_id andSelected:emp1.isSelected];
                    }
                    
                    NSMutableArray *allArray=[[NSMutableArray alloc]init];
                    [allArray addObjectsFromArray:tempEpArray];
//                    [pool release];
                    
                    NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                    [self.typeArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                    
                    [allArray release];
                    [pool release];
                    
                    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                    float noworigin=cell.frame.origin.y;
                    /*自动收起---------------------------------------------------------------bigen------------*/
                    float isExtendedPoint=0;
                    float sumnum=0;
                    for (int i=0; i<[self.typeArray count]; i++) {
                        id temp1 = [self.typeArray objectAtIndex:i];
                        if([temp1 isKindOfClass:[RecentGroup class]])
                        {
                            RecentGroup*extendedDept=((RecentGroup *)temp1);
                            if (![extendedDept.conv_id isEqualToString:recent.conv_id]&&extendedDept.isExtended) {
                                NSIndexPath *tempindexpath=[NSIndexPath indexPathForRow:i inSection:0];
                                UITableViewCell *tempcell=[tableView cellForRowAtIndexPath:tempindexpath];
                                isExtendedPoint=tempcell.frame.origin.y;
                                
                                extendedDept.isExtended=false;
                                int remvoecount=0;
                                float emplen=0;
                                float deptlen=0;
                                for (int nowindex=i+1; nowindex<[self.itemArray count]; nowindex++) {
                                    
                                    
                                    id temp1 = [self.typeArray objectAtIndex:nowindex];
                                    
                                    if([temp1 isKindOfClass:[Emp class]])
                                    {
                                        if (((Emp *)temp1).emp_level<=extendedDept.type_level) {
                                            break;
                                        }
                                        emplen+=58;
                                    }
                                    
                                    if([temp1 isKindOfClass:[RecentGroup class]])
                                    {
                                        if (((RecentGroup *)temp1).type_level<=extendedDept.type_level) {
                                            break;
                                        }
                                        deptlen+=42;
                                    }
                                    if([temp1 isKindOfClass:[RecentMember class]])
                                    {
                                        if (((RecentMember *)temp1).type_level<=extendedDept.type_level) {
                                            break;
                                        }
                                        deptlen+=42;
                                    }
                                    remvoecount++;
                                }
                                if (remvoecount!=0) {
                                    NSRange range =NSMakeRange(i+1,remvoecount);
                                    [self.typeArray removeObjectsInRange:range];
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
                        tableView.contentOffset=CGPointMake(0,offsetvalue-20);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                    }else{
                        tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                    }
                    /*自动收起*///---------------------------------------------------------------end------------//
                    
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
                NSArray *tempEpArray=[_ecloud getEmpsByDeptID:dept.dept_id  andLevel:level];
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
        else
        {
            int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
            
            //	找到复选框所在的行
            int row =indexPath.row;
            //	取出对应行的对象是一个部门还是一个员工
            id temp=[self.itemArray objectAtIndex:row];
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
            
            [organizationalTable reloadData];
            //    显示在底部
            [self bottomScrollviewShow];
        }
        
    }else if (tableView==chooseTable)
    {
        
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
            if([self needShowAlert])
                return;
            
            if ((nowcount+dept.totalNum)>(maxGroupNum - self.oldEmpIdArray.count))
            {
				[self showGroupNumExceedAlert];
                return;
            }
            
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            dept.isChecked=true;
        }
        //		设置部门，部门的子部门，部门员工，子部门员工的选中状态
        [self selectByDept:dept.dept_id status:dept.isChecked];
        
        //		把选中状态呈现在界面上
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
        
    }
    //    显示在底部
    [self bottomScrollviewShow];
}
//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //	部门id
    NSString *dept_id_str=[NSString stringWithFormat:@"%d",dept_id];
    //	部门的子部门
    NSArray *tempArray=[_ecloud getChildDepts:dept_id_str];
    Emp *emp;
    NSString *deptId;
    
    //    设置子部门下的员工的选中状态
    for (int i=0; i<[self.employeeArray count]; i++) {
        
        emp=[self.employeeArray objectAtIndex:i];
        for (int j=0;j<[tempArray count]; j++) {
            
            deptId=[tempArray objectAtIndex:j];
            if (emp.emp_dept==[deptId intValue])
			{
				bool isOldMember = false;
                if ([self.mOldEmpDic valueForKey:[StringUtil getStringValue:emp.emp_id]]) {
                    isOldMember = true;
                }

				if(isOldMember)
					continue;
                if (emp.permission.isHidden) {
                    NSLog(@"%@是隐藏的",emp.emp_name);
                    continue;
                }
				if(!emp.permission.canSendMsg)
                {
                    NSLog(@"%@不能发送消息",emp.emp_name);
                    continue;
                }
                
                emp.isSelected=selectedStatus;
				[self updateNowSelectedEmp:emp];
				break;
            }
        }
    }
	[self displayNowSelectedEmp];
    
    for (int j=0; j<[tempArray count] ;j++) {
        
        deptId=[tempArray objectAtIndex:j];
        DeptInMemory *_dept = [_conn getDeptInMemoryByDeptId:deptId.intValue];
        if (_dept) {
            _dept.isChecked = selectedStatus;
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

- (void)addGesture:(EmpSelectCell *)empCell
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
    
    [organizationalViewController openUserInfoById:empIdStr andCurController:self];
}

//用户点击取消或者确定后，要把选中的人员的状态，设置为非选中

#pragma mark ======转发消息时 新建会话=========
-(void) createConvWhenTransferMsg{
    //	关闭键盘
	[searchTextView resignFirstResponder];
    
    //    update by shisp
    if ([self.nowSelectedEmpArray count] == 1)
    {//单聊
        Emp *emp=[self.nowSelectedEmpArray objectAtIndex:0];
        self.newConvId = [StringUtil getStringValue:emp.emp_id];
        self.newConvTitle = emp.emp_name;
        self.newConvType = singleType;
        
        UIAlertView *sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:emp.emp_name delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
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
        //    标题
        self.newConvTitle = [[talkSessionUtil2 getTalkSessionUtil]getTitleStrByConvRecord:self.forwardRecord];
        //    要加上自己
        [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];

        self.newConvId = nil;

//        首先检查下是否有可用的群组，如果有再判断下这个群组是否已经创建，如果已经创建则直接使用，否则发起创建
        BOOL needCreate = YES;
        
        Conversation *oldConv = [_ecloud searchConvsationByConvEmps:self.nowSelectedEmpArray];
        if (oldConv) {
            self.newConvId = oldConv.conv_id;
            if (oldConv.last_msg_id == -1)
            {
                //                    群组已经存在并且还没有真正创建，需要发起创建
            }
            else
            {
                needCreate = NO;
                //                    群组已经存在并且已经创建，只需要发送即可
                [self showTransferToGroupTips];
            }
        }

        if (needCreate) {
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
                [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:self.newConvId andTitle:self.newConvTitle];
            }
            
            self.forwardRecord.conv_id = self.newConvId;
            self.forwardRecord.conv_type = self.newConvType;
            
            talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
            BOOL saveSuccess = [talkSession saveForwardMsg];
            
            if(!saveSuccess)
            {
                [self dismissModalViewControllerAnimated:YES];
            }
            else
            {
                //            如果会话id和当前的会话id相同，那么需要刷新聊天界面
                if ([self.newConvId isEqualToString:talkSession.convId])
                {
                    talkSession.needUpdateTag = 1;
                }
                talkSession.sendForwardMsgFlag = YES;
                //            关闭当前页面
                [self dismissModalViewControllerAnimated:YES];
            }
            return;
        }
        break;
        default:
        break;
    }
    
}

// add by shisp 提示是否需要转发到群组
- (void)showTransferToGroupTips
{
    UIAlertView *sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:[NSString stringWithFormat:[StringUtil getLocalizableString:@"group_groupChats_d"],[self.nowSelectedEmpArray count]] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
    [sendAlert show];
    [sendAlert release];
}
@end
