//
//  chatMessageViewController.m
//  eCloud
//
//  Created by  lyong on 13-2-21.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "chatMessageViewController.h"
#import "eCloudConfig.h"
#import "UserInterfaceUtil.h"
#import "Conversation.h"
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#import "HuaXiaUserInterfaceDefine.h"
#endif

#ifdef _LANGUANG_FLAG_
#import "LGRootChooseMemberViewController.h"
#endif

#import "CreateGroupUtil.h"

#import "mainViewController.h"
#import "FunctionEntranceModel.h"
#import "FunctionEntranceButton.h"

#import "FileAssistantViewController.h"

#import "ChatBackgroundUtil.h"
#import "UIRoundedRectImage.h"

#import <QuartzCore/QuartzCore.h>

#import "eCloudDefine.h"
#import "conn.h"
#import "specialChooseMemberViewController.h"
#import "NewChooseMemberViewController.h"
#import "chatBackgroudViewController.h"

#ifdef _XINHUA_FLAG_
#import "XINHUAOrgSelectedViewControllerArc.h"
#endif


#import "ReceiptMsgViewController.h"

#import "talkRecordDetailViewController.h"
#import "talkSessionViewController.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
#import "eCloudUser.h"
#import "eCloudDAO.h"
#import "ImageSet.h"
#import "userInfoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UserDisplayUtil.h"
#import "PermissionModel.h"
#import "PermissionUtil.h"
#import "UIAdapterUtil.h"
#import "StatusConn.h"
#import "UserDataConn.h"
#import "UserDataDAO.h"
#import "ImageUtil.h"
#import "UserTipsUtil.h"
#import "SettingItem.h"

#import "Emp.h"
#import "modifyGroupNameViewController.h"

#import "NewOrgViewController.h"
#import "MLNavigationController.h"

#import "NotificationUtil.h"

#import "ChatHistorySearchView.h"

#import "EmpLogoConn.h"
#import "LoginConn.h"
#import "Conversation.h"
#import "DisplayPicViewController.h"
#import "LCLLoadingView.h"


#define rcv_msg_flag_tag (100)
#define common_group_flag_tag (101)

//群组成员按钮上的imageview tag
#define icon_button_sub_imageview_tag (100)

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
@interface chatMessageViewController () <ChooseMemberDelegate,HuaXiaOrgProtocol>
#else
@interface chatMessageViewController () <ChooseMemberDelegate>
#endif

//@property (nonatomic, retain) UIScrollView *detailview;
@property(nonatomic,retain)UIButton *expandButton;
@property(nonatomic,retain)UIImageView *expandimageview;
@property(nonatomic,retain)NSMutableArray *settingArray;

//    设置为常用联系人的 indexPath
@property (nonatomic,retain) NSIndexPath *setCommonEmpIndexPath;

@property (nonatomic, strong) NSMutableArray *titleArray;

//    设置新消息提醒的 indexPath
@property (nonatomic,retain) NSIndexPath *setRcvMsgFlagIndexPath;

@end

@implementation chatMessageViewController
{
	eCloudDAO *db;
    
//是否刷新
	bool isFresh;
	
//	超时timer
	NSTimer *timeoutTimer;
    
//    消息屏蔽标识
    UIImageView *rcvFlagView;
    
    StatusConn *_statusConn;
    
    UserDataDAO *userDataDAO;
    
    UserDataConn *userDataConn;
    
//    是否固定群组
    BOOL isSystemGroup;
    
//    用户是否固定群组的管理员
    BOOL isSystemGroupAdmin;
    
//    add by shisp 头像的宽度，通过高度计算出来
    float iconViewWidth;
    
//    每行显示的个数 需要根据屏幕的宽度计算出来
    int perRowCount;
    
// 需要根据显示的个数 ，屏幕的宽度，等计算出来
    float spaceX;
    
//    退出按钮
    UIView *exitButtonView;
    
    UIButton *deleteButton;
    
    //    增加 table view 的 headerview的父view
    UIView *tableHeaderParentView;
    
    //    群组名称cell
    UITableViewCell *groupNameCell;
    
    //    群组名称cell下面的分割线
    UIView *groupNameSeperateLine;
    
    //    群组名称对应的item
    SettingItem *groupNameItem;
    
    //    增加显示 程序入口的父view
    UIView *functionEntranceParentView;
    
    //显示群组成员的父view
    UIView *memberParentView;
    
    //    默认的table的contentOffset的y值
    float defaultTableContentOffsetY;
    
    //    新增的 显示 加号和减号的 独立的view
    UIButton *flagParentView;
    UIButton *addMemberButton;
    UILabel *addMemberLabel;
    UIButton *delMemberButton;
    UILabel *delMemberLabel;
    
    
    //
    UIButton *memberScroll;
    
    
    UITableView *actionTable;
    int talkType;
    conn *_conn;
    UIScrollView *detailview;
}
@synthesize talkType;
@synthesize convId;
@synthesize titleStr;
@synthesize predelegete;
@synthesize dataArray;
@synthesize isVirGroup;
@synthesize create_emp_id;
@synthesize start_Delete;
@synthesize last_msg_id;
@synthesize deleteIndex;

@synthesize setCommonEmpIndexPath;
@synthesize setRcvMsgFlagIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [exitButtonView release];
    exitButtonView = nil;

    self.setRcvMsgFlagIndexPath = nil;
    self.setCommonEmpIndexPath = nil;
    
    self.expandimageview = nil;
    self.expandButton = nil;
	self.convId = nil;
	self.titleStr = nil;
	self.predelegete = nil;
	self.dataArray = nil;
    self.settingArray = nil;
    self.emp = nil;
	[super dealloc];
	NSLog(@"%s",__FUNCTION__);
}
-(void)externDoAction:(id)sender4
{
    if (self.expandButton.tag==0)
    {
        self.expandButton.tag=1;
        [self.expandButton setTitle:[StringUtil getLocalizableString:@"chatmessage_pack_up"] forState:UIControlStateNormal];
        [self.expandButton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"arrow_1" andType:@"png"]] forState:UIControlStateNormal];
        
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        
        [self performSelector:@selector(showMemberScrollow) withObject:nil afterDelay:1];
    }
    else
    {
        self.expandButton.tag=0;
        [self.expandButton setTitle:[StringUtil getLocalizableString:@"chatmessage_more"] forState:UIControlStateNormal];
        [self.expandButton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"arrow_2" andType:@"png"]] forState:UIControlStateNormal];
        actionTable.contentOffset = CGPointMake(0, -64);
        [self showMemberScrollow];
    }
}
- (void)viewDidLoad
{
	NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];

    //        群组成员头像的高度 根据宽度计算出来 不使用固定值
    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
    
    iconViewWidth = (iconViewHeight * _size.width) / _size.height;
    
    [self setMemberViewLayout];
    
    _statusConn = [StatusConn getConn];
    userDataDAO = [UserDataDAO getDatabase];
    userDataConn = [UserDataConn getConn];
	isFresh = false;
	self.start_Delete=NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
 
    if (self.talkType==singleType) {
        self.title=[StringUtil getLocalizableString:@"chatmessage_chat_messages"];
        self.emp = [self.dataArray objectAtIndex:0];
    }else
    {
        self.title=[NSString stringWithFormat:@"%@(%lu)",[StringUtil getLocalizableString:@"chatmessage_chat_messages"],(unsigned long)[self.dataArray count]];
//        isSystemGroup = [userDataDAO isSystemGroup:self.convId];
//        if (isSystemGroup) {
//            isSystemGroupAdmin = [userDataDAO isAdminOfConv:self.convId];
//        }
    }
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    db = [eCloudDAO getDatabase];
    _conn = [conn getConn];
	
	int tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
//	if (IOS7_OR_LATER) {
//        tableH = SCREEN_HEIGHT;
//        if ([UIAdapterUtil isCsairApp]) {
//            tableH -= (STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT);
//        }
//    }
    
//    tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    actionTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,tableH) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:actionTable];
    [actionTable setDelegate:self];
    [actionTable setDataSource:self];
    actionTable.backgroundView = nil;
    actionTable.backgroundColor=[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
    [self.view addSubview:actionTable];
    [actionTable release];
    actionTable.backgroundColor=[UIColor clearColor];
    
    if ([self isTableHeaderViewIncludeFunctionEntrance]) {
        [self addFunctionEntranceView];
    }

//    增加显示聊天成员的相关view
    [self addGroupMemberView];
    
    exitButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 65 )];
    exitButtonView.backgroundColor = [UIColor clearColor];
    
    deleteButton = [UIAdapterUtil setNewButton:[StringUtil getLocalizableString:@"chatmessage_delete_exit"] andBackgroundImage:[StringUtil getImageByResName:@"exit_button.png"]];

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    //    bf0008
    [deleteButton setBackgroundImage:nil forState:UIControlStateNormal];
    [deleteButton setBackgroundColor:HX_DARK_RED_COLOR];
#endif

    
    deleteButton.frame=CGRectMake(10, 5, self.view.frame.size.width-20, 45);
        
    [deleteButton addTarget:self action:@selector(deleteAndExitGroup:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
    [exitButtonView addSubview:deleteButton];
    
    
    if ([UIAdapterUtil isGOMEApp])
    {
        deleteButton.layer.cornerRadius = 5;
        deleteButton.clipsToBounds = YES;
        [deleteButton setBackgroundImage:nil forState:UIControlStateNormal];
        [deleteButton setBackgroundColor:[UIColor colorWithRed:2/255.0 green:139/255.0 blue:230/255.0 alpha:1]];
    }
#ifdef _LANGUANG_FLAG_
    
    deleteButton.frame=CGRectMake(-5, 12, self.view.frame.size.width+5, 45);
    [deleteButton setBackgroundImage:nil forState:UIControlStateNormal];
    deleteButton.layer.cornerRadius = 0;
    deleteButton.layer.borderColor = [[StringUtil colorWithHexString:@"#E4E4E4"] CGColor];//[[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1] CGColor];
    deleteButton.layer.borderWidth = 0.5f;//设置边框颜色
    [deleteButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize: 17.0];
    
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isSuccess:) name:XIANGYUAN_COMMON_GROUP object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    _statusConn.curViewController = self;
    [_statusConn getStatus];
    
    actionTable.tableFooterView = nil;
    
    if(self.talkType == mutiableType)
    {
        self.title = [NSString stringWithFormat:@"%@(%lu)",[StringUtil getLocalizableString:@"chatmessage_chat_messages"],(unsigned long)[self.dataArray count]];

        isSystemGroup = [userDataDAO isSystemGroup:self.convId];
        if (isSystemGroup) {
            isSystemGroupAdmin = [userDataDAO isAdminOfConv:self.convId];
        }
        
        ( (talkSessionViewController*)self.predelegete).titleStr=self.titleStr;
        
        [LogUtil debug:[NSString stringWithFormat:@"%s self.titleStr is %@ dataarray count is %lu",__FUNCTION__,self.titleStr,(unsigned long)self.dataArray.count]];
        
        if (!isSystemGroup) {
            //    add by shisp 如果群组设置了消息不提醒，那么现实这个图标
            UIImage *noAlarmImage = [ImageUtil getNoAlarmImage:1];
            rcvFlagView = [[[UIImageView alloc]initWithImage:noAlarmImage]autorelease];
            
            CGRect _frame = rcvFlagView.frame;
            _frame.origin = CGPointMake(self.view.frame.size.width - noAlarmImage.size.width - 10, (44 - noAlarmImage.size.height)/2);
            rcvFlagView.frame = _frame;
            
            [self.navigationController.navigationBar addSubview:rcvFlagView];
            
            rcvFlagView.hidden = YES;
            if([db getRcvMsgFlagOfConvByConvId:self.convId])
            {
                rcvFlagView.hidden = NO;
            }
            actionTable.tableFooterView = exitButtonView;
        }
    }
    
    [self addObserver];
    
    if ([self isTableHeaderViewIncludeFunctionEntrance]) {
        [self reCalculateTableHeaderViewFrame];
    }
    
    [self loadData];

    [self showMemberScrollow];
}

- (void)loadData
{
    [self prepareSettingItems];
    
    [actionTable reloadData];
}

- (void)addObserver
{
    //    [self showMemberScrollow];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(empStatusChange:) name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processSetRcvMsgFlag:) name:SET_CONV_RCV_MSG_FLAG_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
    //	接收分组成员修改通知
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleCmd:)
                                                name:MODIFYMEBER_NOTIFICATION
                                              object:nil];
    //	分组成员修改 超时通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:QUIT_GROUP_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];

}
- (void)addGroupMemberView
{
    //    显示群组成员头像 由三部分组成 一个是显示群组成员头像的scrollview , 一个是是否展开的view，一个是显示添加和删除按钮的view
    
    //    父view
    memberParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    [memberParentView setBackgroundColor:[UIColor whiteColor]];
//    update by shisp
    if ([self isTableHeaderViewIncludeFunctionEntrance]) {
        [tableHeaderParentView addSubview:memberParentView];
    }else{
        actionTable.tableHeaderView = memberParentView;
    }
    [memberParentView release];
    
    //    显示群组成员的view
    memberScroll=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    memberScroll.backgroundColor=[UIColor clearColor];
    [memberScroll addTarget:self action:@selector(cancelDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    [memberParentView addSubview:memberScroll];
    [memberScroll release];
    
    //    展开收起群组成员的按钮
    self.expandButton= [[[UIButton  alloc]initWithFrame:CGRectMake(self.view.frame.size.width - expandButtonWidth,20,expandButtonWidth,expandButtonHeight)]autorelease];
    self.expandButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.expandButton.tag=0;
    [self.expandButton addTarget:self action:@selector(externDoAction:)forControlEvents:UIControlEventTouchDown];
    [self.expandButton setTitle:[StringUtil getLocalizableString:@"chatmessage_more"] forState:UIControlStateNormal];
//    #1087f7
    UIColor *_color = [UIColor colorWithRed:(16/255.0) green:(135.0/255.0) blue:(247.0/255.0) alpha:1];
    [self.expandButton setTitleColor:_color forState:UIControlStateNormal];
//    [self.expandButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.expandButton.titleLabel.font=[UIFont systemFontOfSize:12];
    [self.expandButton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"arrow_2" andType:@"png"]] forState:UIControlStateNormal];

    [self.expandButton setBackgroundColor:[UIColor clearColor]];
    
    float flagViewSpaceY = 10;

    //    新增的增加和删除按钮
    flagParentView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,iconViewHeight + 3 * flagViewSpaceY )];
    [flagParentView setBackgroundColor:[UIColor clearColor]];
#ifdef _XIANGYUAN_FLAG_
    [flagParentView addSubview:self.expandButton];
#else
    [memberParentView addSubview:self.expandButton];
#endif
    [memberParentView addSubview:flagParentView];
    [flagParentView release];
    
    
    [flagParentView addTarget:self action:@selector(cancelDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    
    
    //    加号按钮
    addMemberButton = [[UIButton alloc]initWithFrame:CGRectMake(x0, flagViewSpaceY, 45, 45)];
    [addMemberButton setBackgroundImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"addmember" andType:@"png"]] forState:UIControlStateNormal];
    
    //        增加点击事件
    [addMemberButton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
    addMemberButton.tag = -1;
    
    [flagParentView addSubview:addMemberButton];
    [addMemberButton release];
    
    //加号label
    addMemberLabel = [[UILabel alloc]initWithFrame:CGRectMake(x0-7.5, addMemberButton.frame.size.height + addMemberButton.frame.origin.y + 5, 60, 18)];
    addMemberLabel.text = @"添加成员";
    UIColor *nameColor = [UIAdapterUtil getCustomGrayFontColor];
    addMemberLabel.textColor = nameColor;
    [addMemberLabel setTextAlignment:NSTextAlignmentCenter];
    addMemberLabel.font = [UIFont systemFontOfSize:12];
    [flagParentView addSubview:addMemberLabel];
    [addMemberLabel release];
    
    
    //    减号按钮
    delMemberButton = [[UIButton alloc]initWithFrame:CGRectMake(x0 + perItemWidth + spaceX, flagViewSpaceY, 45, 45)];
    [delMemberButton setBackgroundImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"deleteGroupMember" andType:@"png"]] forState:UIControlStateNormal];
    //        增加点击事件
    [delMemberButton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
    delMemberButton.tag = -2;
    
    [flagParentView addSubview:delMemberButton];
    [delMemberButton release];
    
    delMemberLabel = [[UILabel alloc]initWithFrame:CGRectMake(x0 + perItemWidth + spaceX-7.5, delMemberButton.frame.size.height + delMemberButton.frame.origin.y + 5, 60, 18)];
    delMemberLabel.text = @"删除成员";
    delMemberLabel.textColor = nameColor;
    [delMemberLabel setTextAlignment:NSTextAlignmentCenter];
    delMemberLabel.font = [UIFont systemFontOfSize:12];
    [flagParentView addSubview:delMemberLabel];
    [delMemberLabel release];
    
//    [self showMemberScrollow];
}

-(void)cancelDeleteStatus{
    //点击操作内容
    if ( self.start_Delete)
    {
        self.start_Delete=NO;
        [self showMemberScrollow];
    }
   
}
-(void)deleteAndExitGroup:(id)sender
{
    NSLog(@"-------deleteAndExitGroup");
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"chatmessage_long_prompt"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"],nil];
    alert.tag=2;
    [alert show];
    [alert release];
    
}

-(void)removeSubviewFromScrollowView
{
     for (UIView *eachView in [memberScroll subviews])
    {
        [eachView removeFromSuperview];
        eachView = nil;
    }
}
//- (void)setDataArray:(NSArray *)dataArray
//{
//    self.dataArray = [dataArray copy];
//    NSLog(@"%lu",(unsigned long)dataArray.count);
//}
-(void)showMemberScrollow
{
    [self removeSubviewFromScrollowView];

//    显示成员的view的高度
    float scrollViewHeight;
    
//    item总数
    int totalMemberCount = (int)self.dataArray.count;
    
    [self setTitleWithMemberCount:totalMemberCount];
   
    int totalCount = totalMemberCount;
    
    //    是否需要显示 + -
    BOOL displayAdd = NO;
    BOOL displayMinus = NO;
    
    //    加减号是否和member一起展示
    BOOL displayWithMember = NO;
    
    //    是否需要显示展开符号
    BOOL displayExpand = NO;
    
//    当前是否为展开状态
    BOOL isExpand = NO;
    if (self.expandButton.tag == 1)
    {
        isExpand = YES;
    }
    
    //    如果是固定群组那么不显示加号和减号
    //    如果不是固定群组，那么显示加号，如果创建人不是自己，那么不显示减号
    if (self.talkType == singleType && self.dataArray.count == 2)
    {
        //        单聊 只显示加号
        displayAdd = YES;
        totalCount++;
        
        displayWithMember = YES;
        
//        只显示一行
        scrollViewHeight = perItemHeight + 2 * spaceY;
    }
    else // if (self.talkType == mutiableType)
    {
//        是否显示所有成员
        BOOL displayAllMember = NO;
        
        if (!isSystemGroup)
        {
            //            普通群组 显示加号
            displayAdd = YES;
            totalCount++;
            
//             && !self.start_Delete
//            update by shisp 只要是用户
            if (self.create_emp_id == [_conn.userId intValue])
            {
                //                登录用户是群组创建人，显示减号
//                并且不是删除状态 才能显示减号
                displayMinus = YES;
                totalCount++;
            }
            
            if (totalCount <= 3 * perRowCount)
            {
                //              不超过3行 12个，符号和头像一起显示
                displayWithMember = YES;
                
//                显示所有
                displayAllMember = YES;
            }
            else
            {
                //                超过了3行，那么符号和头像分开显示
                totalCount--;
                if (displayMinus)
                {
//                    群组创建人是当前用户，并且不是删除状态
                    totalCount--;
                }
                
                if (totalMemberCount > 3 * perRowCount)
                {
                    //                    需要显示展开
                    displayExpand = YES;
                }
//                判断下是展开状态 还是收起状态，如果是收起状态，则只显示3行，如果是展开状态，则显示所有
                if (isExpand)
                {
                    displayAllMember = YES;
                }
                else
                {
                    displayAllMember = NO;
                }
            }
        }
        else
        {
            //            固定群组
            if (totalMemberCount > 3 * perRowCount)
            {
                displayExpand = YES;
                if (isExpand)
                {
                    displayAllMember = YES;
                }
                else
                {
                    displayAllMember = NO;
                }
            }
            else
            {
                displayAllMember = YES;
            }
        }
        
        if (displayAllMember)
        {
            int row = totalCount / perRowCount;
            if (totalCount % perRowCount > 0)
            {
                row++;
            }
            //                需要按照实际行数显示
            scrollViewHeight = row * (perItemHeight + spaceY);
        }
        else
        {
            //                需要显示满3行
            scrollViewHeight = 3 * (perItemHeight + spaceY);
        }
    }
    
//    修改scrollView的frame
    CGRect scrollViewFrame = memberScroll.frame;
    scrollViewFrame.size.height = scrollViewHeight;
    memberScroll.frame = scrollViewFrame;

    //    member父view的高度
    float parentMemberViewHeight = scrollViewHeight;
    
    //    默认不显示 收起扩展按钮
    self.expandButton.hidden = YES;
    if (displayExpand)
    {
        self.expandButton.hidden = NO;
        
        if (![UIAdapterUtil isXIANGYUANApp]) {
            
            parentMemberViewHeight += self.expandButton.frame.size.height;
            
            CGRect expandViewFrame = self.expandButton.frame;
            expandViewFrame.origin.y = scrollViewFrame.origin.y + scrollViewFrame.size.height;
            self.expandButton.frame = expandViewFrame;
        }
        
    }
    
    //    默认不显示 独立的加减号view
    flagParentView.hidden = YES;
    if ((displayAdd || displayMinus) && !displayWithMember)
    {
        //        如果需要显示加减号，而且又不是和成员一起显示，那么独立的显示加减号的view就不能隐藏
        flagParentView.hidden = NO;
        parentMemberViewHeight += flagParentView.frame.size.height;
        
        CGRect flagParentViewFrame = flagParentView.frame;
        flagParentViewFrame.origin.y = parentMemberViewHeight - flagParentViewFrame.size.height;
        flagParentView.frame = flagParentViewFrame;
        
//        如果已经是删除状态，那么不显示减号
        
        if (displayMinus)
        {
            delMemberButton.hidden = NO;
            delMemberLabel.hidden = NO;
        }
        else
        {
            delMemberButton.hidden = YES;
            delMemberLabel.hidden = YES;
        }
    }
    
    CGRect parentMemberViewFrame = memberParentView.frame;
    parentMemberViewFrame.size.height = parentMemberViewHeight;
    memberParentView.frame = parentMemberViewFrame;
    
    if ([self isTableHeaderViewIncludeFunctionEntrance]) {
        [self reCalculateTableHeaderViewFrame];
    }else{
        actionTable.tableHeaderView = memberParentView;
    }
    
    for (int i = 0; i < totalCount; i ++ )
    {
//        item所在的行数 从0开始
        int rowNumber = i / perRowCount;
        
        if (displayExpand && !isExpand && rowNumber == 3)
        {
            //            如果需要显示扩展按钮,并且是收起状态 并且等于3行,不再显示
            break;
        }
//        item所在的列数 从0开始
        int colNumber = i % perRowCount;
        
//        item的X值和Y值
        float itemX = x0 + colNumber * (perItemWidth + spaceX);
        float itemY = y0 + rowNumber * (perItemHeight + spaceY);
       
//        scroll view 每一个项的view 需要包括头像 nameLabel等
        CGRect _frame = CGRectMake(itemX, itemY, perItemWidth, perItemHeight);
        UIView *itemView = [[UIView alloc]initWithFrame:_frame];
        itemView.backgroundColor = [UIColor clearColor];
        [memberScroll addSubview:itemView];
        [itemView release];

        //        用户头像按钮
        _frame = CGRectMake((perItemWidth - iconViewWidth)/2.0, deleteGroupMemberButtonSize/2.0, iconViewWidth, iconViewHeight);
#ifdef _LANGUANG_FLAG_
  
        _frame = CGRectMake((perItemWidth - iconViewWidth)/2.0, deleteGroupMemberButtonSize/2.0, 45, 45);
#endif
        UIButton *iconbutton = [[UIButton alloc]initWithFrame:_frame];
        iconbutton.backgroundColor = [UIColor clearColor];
        [itemView addSubview:iconbutton];
        [iconbutton release];
        
//        增加点击事件
//        如果不是删除状态，那么点击头像可以查看用户资料，如果是删除状态，则点击头像是删除
        if (!self.start_Delete) {
            [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
        }
 
        
        if (i < totalMemberCount)
        {
//            如果显示的群组成员
            Emp *emp = [self.dataArray objectAtIndex:i];

            iconbutton.tag = i;
            
            [self setEmpLogoWith:emp andIconButton:iconbutton];
            
            [self setEmpStatusWithEmp:emp andIconButton:iconbutton];

            [self setDeleteMemberBtnWithEmp:emp andIndex:i andIconButton:iconbutton andItemView:itemView];
            
            [self setEmpNameWithEmp:emp andIconButton:iconbutton andItemView:itemView];
        }
        else if(i == totalMemberCount)
        {
//            是+号
            [iconbutton setBackgroundImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"addmember" andType:@"png"]] forState:UIControlStateNormal];
            iconbutton.tag = -1;
            [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
//            Emp *emp = [self.dataArray objectAtIndex:2];
            Emp *emp = [[Emp alloc] init];
            emp.emp_name = @"添加成员";
            [self setEmpNameWithEmp:emp andIconButton:iconbutton andItemView:itemView];
        }
        else if(i == totalMemberCount + 1)
        {
//            是-号
            [iconbutton setBackgroundImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"deleteGroupMember" andType:@"png"]] forState:UIControlStateNormal];
            iconbutton.tag = -2;
            
            [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
            Emp *emp = [[Emp alloc] init];
            if (self.start_Delete)
            {
                emp.emp_name = @"完成";
            }
            else
            {
                emp.emp_name = @"删除成员";
            }
            [self setEmpNameWithEmp:emp andIconButton:iconbutton andItemView:itemView];
        }
    }
    
    [UserTipsUtil hideLoadingView];
 }

//根据人数显示标题
- (void)setTitleWithMemberCount:(int)totalMemberCount
{
    if (totalMemberCount > 2)
    {
        self.title=[NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"chatmessage_chat_messages"],totalMemberCount];
    }
    else
    {
        self.title=[StringUtil getLocalizableString:@"chatmessage_chat_messages"];
    }
}

//设置头像左上角的删除按钮
- (void)setDeleteMemberBtnWithEmp:(Emp *)emp andIndex:(int)i andIconButton:(UIButton *)iconbutton andItemView:(UIView *)itemView
{
    if (emp.emp_id != [_conn.userId intValue] && self.start_Delete)
    {
        //            删除成员按钮
        CGRect _frame = CGRectMake(iconbutton.frame.origin.x - deleteGroupMemberButtonSize/2.0, iconbutton.frame.origin.y - deleteGroupMemberButtonSize/2.0, deleteGroupMemberButtonSize, deleteGroupMemberButtonSize);
        UIButton *deletebutton=[[UIButton alloc]initWithFrame:_frame];
        
        deletebutton.tag = i;
        [deletebutton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"red_delete" andType:@"png"]] forState:UIControlStateNormal];
        [deletebutton addTarget:self action:@selector(deleteGroupMemberAction:) forControlEvents:UIControlEventTouchUpInside];
        [itemView addSubview:deletebutton];
        [deletebutton release];
        
//        如果是删除状态，那么点击头像也是删除成员
        [iconbutton addTarget:self action:@selector(deleteGroupMemberAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}


//设置nameLabel
- (void)setEmpNameWithEmp:(Emp *)emp andIconButton:(UIButton *)iconbutton andItemView:(UIView *)itemView
{

    CGRect _frame = CGRectMake(0, iconbutton.frame.size.height + iconbutton.frame.origin.y, perItemWidth, nameLabelHeight);
    
#ifdef _LANGUANG_FLAG_
    
    _frame = CGRectMake(-7.5, iconbutton.frame.size.height + iconbutton.frame.origin.y + 4, 60, 18);
    
#endif

    UILabel *nameLabel=[[UILabel alloc]initWithFrame:_frame];
    nameLabel.text=emp.emp_name;
    nameLabel.tag = iconbutton.tag + 10000;
    nameLabel.backgroundColor=[UIColor clearColor];
    nameLabel.font=[UIFont systemFontOfSize:12];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    
//    if (emp.emp_status==status_online||emp.emp_status==status_leave)
//    {
//        nameLabel.textColor=[UIColor blueColor];
//    }
//    else
//    {
//        nameLabel.textColor=[UIColor blackColor];
//    }
//    讨论组创建者的姓名使用这种颜色:FF8C00
    UIColor *nameColor = [UIAdapterUtil getCustomGrayFontColor];
    nameLabel.textColor = nameColor;// [UIColor colorWithRed:97.0/255 green:96.0/255 blue:96.0/255 alpha:1.0];
    [itemView addSubview:nameLabel];
    [nameLabel release];
    
    CGPoint _center = nameLabel.center;
    _center.x = iconbutton.center.x;
    nameLabel.center = _center;
}

//显示emp的状态
- (void)setEmpStatusWithEmp:(Emp *)emp andIconButton:(UIButton *)iconbutton
{
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
// 华夏和正荣查看资料界面显示状态
#else
    if (![eCloudConfig getConfig].needDisplayUserStatus) {
        return;
    }
#endif
//    默认是离线
    NSString *statusImageName = @"offline_icon";
    //            显示成员状态
    if([UserDisplayUtil isLoginWithCellPhone:emp])
    {
        statusImageName = @"cell_phone";
    }else if(emp.emp_status == status_leave)
    {
        statusImageName = @"status_leave";
    }else if ([UserDisplayUtil isLoginWithPC:emp])
    {
        statusImageName = @"pc_login";
    }
    
//    UIImageView *cellPhoneImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:statusImageName andType:@"png"]]];
    UIImageView *cellPhoneImageView = [[UIImageView alloc]initWithImage:[StringUtil getImageByResName:statusImageName]];
    
    //        定义状态图标的frame 因为 头像的高度 可能会不同 ，所以这里的y值，要根据头像的高度来计算
    float statusSize = 15;

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    statusSize = 10;
#endif

    cellPhoneImageView.frame = CGRectMake(iconbutton.frame.size.width,iconbutton.frame.size.height,statusSize,statusSize);//(37,45,15,15);;
    CGPoint _center = [UserDisplayUtil getStatusCenterWithLogoView:iconbutton];// CGPointMake(iconbutton.frame.size.width - 5, iconbutton.frame.size.height - 5);
    cellPhoneImageView.center = _center;
    
    [iconbutton addSubview:cellPhoneImageView];
    [cellPhoneImageView release];
}

//获取及下载emp的头像
- (void)setEmpLogoWith:(Emp *)emp andIconButton:(UIButton *)iconbutton
{
    //            用户头像还没有下载，那么自动下载
    UIImage *image;
    
//    用户头像的logo统一默认为默认的logo
    NSString *empLogo = default_emp_logo;// emp.emp_logo;
    NSString *empId = [StringUtil getStringValue:emp.emp_id];
    NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:empLogo];
    image = [UIImage imageWithContentsOfFile:logoPath];
    
    if(image == nil)
    {
        image = [ImageUtil getDefaultLogo:emp];
        
        if (![[EmpLogoConn getConn] isDownloadLogoFailEmp:empId]) {
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
//            不去下载，不去保存
//            [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
//            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"EMP_ID",iconbutton,@"ICON_BUTTON", nil];
//            UIImage *empLogo = [[HuaXiaOrgUtil getUtil]getHXEmpLogoByEmpId:empId.intValue withUserInfo:userInfo withCompleteHandler:^(UIImage *empLogo, NSDictionary *userInfo) {
//                NSString *temp = userInfo[@"EMP_ID"];
//                if (empLogo) {
//                    [StringUtil saveUserLogo:empLogo andUser:temp];
//                    
//                    UIButton *iconButton = userInfo[@"ICON_BUTTON"];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [iconButton setBackgroundImage:empLogo forState:UIControlStateNormal];
//                    });
//                }
//            } ];
//            if (empLogo) {
//                [StringUtil saveUserLogo:empLogo andUser:empId];
//                image = empLogo;
//            };
#else
            dispatch_queue_t queue = dispatch_queue_create("download_userlogo", NULL);
            dispatch_async(queue, ^{
                ServerConfig *serverConfig = [ServerConfig shareServerConfig];
                
                NSURL *url = [NSURL URLWithString:[serverConfig getLogoUrlByEmpId:empId]];
                //    如果已经启动了下载，就不再发起下载
                [[EmpLogoConn getConn] saveDownloadLogoFailEmp:empId];
                
                
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                
                if(imageData)
                {
                    //						保存头像之前，先删除原来的头像
                    [StringUtil deleteUserLogoIfExist:empId];
                    
                    //                                压缩成功，保存小图
                    UIImage *curImage = [UIImage imageWithData:imageData];
                    BOOL success= [UIImageJPEGRepresentation(curImage, 1.0) writeToFile:logoPath atomically:YES];
                    
                    if (success)
                    {
                        [StringUtil createAndSaveMicroLogo:curImage andEmpId:empId andLogo:empLogo];
                        
                        //                    在发送图片变化通知时，增加conv_id这个参数，那么这个群组的头像会重新生成下
                        //                    这样处理，如果头像变化了，群组头像会刷新，否则不会刷新，因此打算在chatMessageView返回的时候，发一个通知出来，便于会话列表刷新头像
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",empLogo,@"emp_logo",nil];
                        [StringUtil sendUserlogoChangeNotification:dic];
                        
                        //                                    保存成功 刷新
                        if(!isFresh)
                        {
                            isFresh = true;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *_image = [UIImage imageWithData:imageData];
//                            //                            _image = [UIImage createRoundedRectImage:_image size:CGSizeZero];
//                            [iconbutton setBackgroundImage:_image forState:UIControlStateNormal];
//
                            UIImageView *logoView = (UIImageView *)[iconbutton viewWithTag:icon_button_sub_imageview_tag];
                            if (logoView) {
                                logoView.image = _image;
                                [UserDisplayUtil hideLogoText:logoView];
                            }
                        });
                    }
                }
            });
            dispatch_release(queue);
#endif
        }
    }
    
    UIImageView *logoView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, iconbutton.frame.size.width, iconbutton.frame.size.height)]autorelease];
    [UserDisplayUtil addLogoTextLabelToLogoView:logoView];
    [UIAdapterUtil setCornerPropertyOfView:logoView];
    
    if ([eCloudConfig getConfig].useOriginUserLogo) {
        logoView.contentMode = UIViewContentModeScaleAspectFit;
    }
#ifdef _ZHENGRONG_FLAG_
    //    默认是正方形头像，但是老头像是长方形
    logoView.contentMode = UIViewContentModeScaleAspectFit;
#endif
    if ([image isEqual:default_logo_image]) {
        NSDictionary *mDic = [UserDisplayUtil getUserDefinedChatMessageLogoDicOfEmp:emp];
        [UserDisplayUtil setUserDefinedLogo:logoView andLogoDic:mDic];
    }else{
        logoView.image = image;
        [UserDisplayUtil hideLogoText:logoView];
    }
    logoView.tag = icon_button_sub_imageview_tag;
    [iconbutton addSubview:logoView];
}


-(void)deleteGroupMemberAction:(id)sender
{
    
    if (self.dataArray.count == 3) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"chatmessage_no_less_than_three"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    
    NSLog(@"%s,index is %d",__FUNCTION__,index);
    Emp *emp=[self.dataArray objectAtIndex:index];
    if (self.last_msg_id==-1)
	{
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"chatmessage_deleting"]];
    
       [db deleteGroupMember:self.convId empid:emp.emp_id];
		
		NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_remove_x_from_group"],[emp getEmpName]];
		//	保存到数据库中
		[_conn saveGroupNotifyMsg:self.convId andMsg:msgBody andMsgTime:[_conn getSCurrentTime]];
        NSMutableArray *temparray=[NSMutableArray arrayWithArray:self.dataArray];
        [temparray removeObjectAtIndex:index];
        self.dataArray=temparray;
      // self.dataArray=[db getAllConvEmpBy:self.convId];
//		[self showMemberScrollow];
        if(!isFresh)
        {
            isFresh = true;
        }
//        删除时提示用户正在删除，刷新完成后，关闭提示框
        [self performSelector:@selector(showMemberScrollow) withObject:nil afterDelay:0.05];
        return;
    }
    
    self.deleteIndex=index;
    
    if ([UserTipsUtil checkNetworkAndUserstatus]) {
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"chatmessage_deleting"]];
        [[LCLLoadingView currentIndicator]show];
        
        if(![_conn modifyGroupMember:self.convId andEmps:[NSArray arrayWithObject:emp] andOperType:1])
        {
            [[LCLLoadingView currentIndicator]hiddenForcibly:true];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"chatmessage_delete_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
}
-(void)handleCmd:(NSNotification *)notification
{
	eCloudNotification *cmd = [notification object];
	if(cmd != nil)
	{
        NSDictionary *tempDic = cmd.info;
        //                操作类型 0是增加 1是删除
        int operType = [tempDic[@"oper_type"]intValue];

		int cmdId = cmd.cmdId;
        
        [LogUtil debug:[NSString stringWithFormat:@"%s cmd id is %d operType is %d",__FUNCTION__,cmd.cmdId,operType]];

		switch (cmdId) {
            case modify_group_success:
            {
//                update by shisp 这里先不关闭提示框，等刷新完毕后才关闭
//               [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                
                if (operType == 1) {
                    Emp *emp=[self.dataArray objectAtIndex:self.deleteIndex];
                    [db deleteGroupMember:self.convId empid:emp.emp_id];
                    
                    NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_remove_x_from_group"],[emp getEmpName]];
                    //	保存到数据库中
                    [_conn saveGroupNotifyMsg:self.convId andMsg:msgBody andMsgTime:[_conn getSCurrentTime]];
                    
                    self.dataArray=[db getAllConvEmpBy:self.convId];
                    
                    if (!isFresh) {
                        isFresh = true;
                    }
                    [self showMemberScrollow];
                }
            }break;
            case modify_group_failure:
            {
                if (operType == 1) {
                    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                    UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"chatmessage_delete_member_fail"]delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                }
                // self.start_Delete=NO;
            }
                break;
            case cmd_timeout:
            {
                if (operType == 1) {
                    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"chatmessage_delete_member_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];
                }
            }
                break;
				
            case get_group_info_success:
            {
                if (self.talkType==mutiableType) {
                    self.dataArray = nil;
                  self.dataArray=[db getAllConvEmpBy:self.convId];
                    self.title=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chatmessage_chat_messages_d"],[self.dataArray count]];
                     [self showMemberScrollow];
                    ((talkSessionViewController *)self.predelegete).convEmps=self.dataArray;
                    NSLog(@"----here------get_group_info_success");
                    
                }
                
            }
                break;
            case quit_group_success:
            {
                 if (self.talkType==mutiableType) {
                    [db deleteConvAndConvRecordsBy:self.convId];
                    [db deleteOffenGroupFromVirGroup:self.convId];
//                    ((talkSessionViewController*)self.predelegete).needUpdateTag=1;
                    [self.navigationController popViewControllerAnimated:NO];
                    [((talkSessionViewController*)self.predelegete) backButtonPressed:nil];
                }
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
            }
                break;
            case quit_group_failure:
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"chatmessage_exit_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
            }
                break;
            case quit_group_timeout:
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"chatmessage_exit_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
            }
                break;
            case update_user_data_success:
            {
                    
                if(timeoutTimer && [timeoutTimer isValid])
                {
                    [timeoutTimer invalidate];
                    timeoutTimer = nil;
                }
                [UserTipsUtil hideLoadingView];
                
                if ([userDataDAO isCommonEmp:self.emp.emp_id])
                {
                    [userDataDAO removeCommonEmp:self.emp.emp_id];
                    
                    [UserTipsUtil showAlert:[NSString stringWithFormat:[StringUtil getLocalizableString:@"personinfo_remove_someone_from_common_emp"],self.emp.emp_name]];

                }
                else
                {
                    [userDataDAO addCommonEmp:[NSArray arrayWithObject:[NSNumber numberWithInt:self.emp.emp_id]] andIsDefault:NO];
                    
                    [UserTipsUtil showAlert:[NSString stringWithFormat:[StringUtil getLocalizableString:@"personinfo_get_add_someone_as_common_emp_success"],self.emp.emp_name]];
                }
                
                
            }
                break;
            case update_user_data_fail:
            {
                if(timeoutTimer && [timeoutTimer isValid])
                {
                    [timeoutTimer invalidate];
                    timeoutTimer = nil;
                }
                [UserTipsUtil hideLoadingView];
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"personinfo_get_add_someone_as_common_emp_fail"]];
                
                [actionTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.setCommonEmpIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                break;
            case update_user_data_timeout:
            {
                if(timeoutTimer && [timeoutTimer isValid])
                {
                    [timeoutTimer invalidate];
                    timeoutTimer = nil;
                }
                [UserTipsUtil hideLoadingView];
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"personinfo_get_add_someone_as_common_emp_timeout"]];
                
                [actionTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.setCommonEmpIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                break;
                
		}
	}
    
#ifdef _XINHUA_FLAG_
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self loadData];
    });
#endif
    
}

- (NSArray *)getEmpArray
{
    NSString *currentChar = @"";
    
    NSMutableArray *titleArr = [NSMutableArray array];
    [titleArr addObject:@"{search}"];
    NSMutableArray *empArr = [NSMutableArray array];
    
    NSArray *arr = [[UserDataDAO getDatabase] getAllEmp];
    NSMutableArray * allEmpArr = [NSMutableArray arrayWithArray:arr];
    // 按照拼音排序
    [allEmpArr sortUsingComparator:^NSComparisonResult(Emp *emp1, Emp *emp2) {
        
        return [emp1.empPinyin compare:emp2.empPinyin];
    }];
    for (Emp *emp in allEmpArr)
    {
        NSString *initial = [emp.empPinyin substringToIndex:1];
        // 把首字母转换成大写的
        initial = [initial uppercaseString];
        if (initial != nil && ![initial isEqualToString:currentChar])
        {
            NSMutableArray *arr = [NSMutableArray array];
            [empArr addObject:arr];
            
            // 把该索引加入索引数组
            [titleArr addObject:initial];
        }
        
        [[empArr lastObject] addObject:emp];
        
        currentChar = initial;
    }
    
    self.titleArray = [NSMutableArray arrayWithArray:titleArr];
    
    return empArr;
}

-(void)iconbuttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int index = button.tag;
    if (index == -1)
    {
#ifdef _XINHUA_FLAG_
        
        XINHUAOrgSelectedViewControllerArc *orgSelectedVc = [[XINHUAOrgSelectedViewControllerArc alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:orgSelectedVc];
        orgSelectedVc.empArray = [self getEmpArray];
        orgSelectedVc.delegate = self;
        orgSelectedVc.originArray = self.dataArray;
        orgSelectedVc.titleArray = self.titleArray;
        
        [self presentViewController:navi animated:YES completion:nil];
        
        return;
        
#endif
        
        /** 如果人数已经达到上限，那么就提示用户 */
        int maxUserCount = (int)([conn getConn].maxGroupMember - self.dataArray.count);
        if (maxUserCount <= 0) {
            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"key_group_member_out_of_limit"]];
            return;
        }

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        [HuaXiaOrgUtil getUtil].maxUserCount = maxUserCount;
        
        NSMutableArray *mArray = [NSMutableArray array];
        for (Emp *_emp in self.dataArray) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_emp.emp_id],EMP_ID_KEY, nil];
            [mArray addObject:dic];
        }
        [HuaXiaOrgUtil getUtil].disableSelectUserArray = mArray;
        
        [HuaXiaOrgUtil getUtil].orgDelegate = self;
        [HuaXiaOrgUtil getUtil].orgOpenType = org_open_type_present;
        [HuaXiaOrgUtil getUtil].openVC = self;

        [[HuaXiaOrgUtil getUtil]openSelectHXUserVC];
#elif defined(_LANGUANG_FLAG_)
        LGRootChooseMemberViewController *vc = [[[LGRootChooseMemberViewController alloc]init]autorelease];
        vc.chooseMemberDelegate = self;
        vc.maxSelectCount = maxUserCount;
        vc.oldEmpIdArray = [NSArray arrayWithArray:self.dataArray];
        UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:vc];
        [self presentViewController:navController animated:YES completion:^{
            
        }];

#else
        NewChooseMemberViewController *chooseMember = [[NewChooseMemberViewController alloc]init];
        UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:chooseMember];
        
        chooseMember.typeTag = type_add_conv_emp;
        chooseMember.delegete = self;
        chooseMember.chooseMemberDelegate = self;
        
        [UIAdapterUtil presentVC:navController];
        //        [self.navigationController presentModalViewController:navController animated:YES];
        [chooseMember release];
#endif
    }
    else if(index == -2)
    {

//        如果已经是删除状态，那么应该修改为非删除状态
        if (self.start_Delete) {
            self.start_Delete = NO;
            delMemberLabel.text = @"删除成员";
        }
        else
        {
            self.start_Delete = YES;
            delMemberLabel.text = @"完成";
        }
        [self showMemberScrollow];
//        self.start_Delete=YES;
        
    }
    else
    {
        Emp *emp = [self.dataArray objectAtIndex:index];
        
        
        [NewOrgViewController openUserInfoById:[StringUtil getStringValue:emp.emp_id] andCurController:self];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    _statusConn.curViewController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];

	[[NSNotificationCenter defaultCenter]removeObserver:self name:SET_CONV_RCV_MSG_FLAG_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYMEBER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:QUIT_GROUP_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    
    [rcvFlagView removeFromSuperview];
}

//为了方便群组头像刷新，这里返回时增加一个通知
- (void)sendRefreshGroupLogoNotification
{
    if (self.convId)
    {
        NSDictionary *_dic = [NSDictionary dictionaryWithObject:self.convId forKey:@"conv_id"];
        
        [db asynCreateMergedLogoWithConvId:self.convId andConvTitle:self.titleStr];
        
        eCloudNotification *_notification = [[[eCloudNotification alloc]init]autorelease];
        _notification.cmdId = group_member_change;
        
        [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notification andUserInfo:_dic];
    }
}


//返回 按钮
-(void) backButtonPressed:(id) sender
{
    if (sender)
    {
//        因为退出时也调用了这个方法，这时候不需要刷新
        [self sendRefreshGroupLogoNotification];
    }
    
//	如果头像下载了，那么需要刷新会话界面
     ((talkSessionViewController*)self.predelegete).convEmps=self.dataArray;
	if(isFresh)
		((talkSessionViewController*)self.predelegete).needUpdateTag=1;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.settingArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef _LANGUANG_FLAG_

    return 51;
    
#endif
    return DEFAULT_ROW_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    }
    
    SettingItem *item = [self getSettingItemByIndexPath:indexPath];
//    cell.textColor = item.detailValueColor;
//    cell.textLabel.text = item.itemName;
    cell.accessoryType = item.accessoryType;
    cell.selectionStyle = item.selectionStyle;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-80, 51)];
    label.text = item.itemName;
    [cell addSubview:label];
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:actionTable withOriginX:label.frame.origin.x];
    if (cell.selectionStyle == UITableViewCellSelectionStyleGray) {
        [UIAdapterUtil customSelectBackgroundOfCell:cell];
    }
    
    if (item.customCellSelector) {
        [self performSelector:(item.customCellSelector) withObject:cell];
    }
    
    return cell;
}

-(void)setConvTop{
//    Conversation *conv = [db getConversationByConvId:self.convId];
//    if(conv.isSetTop)
    BOOL isSetTop = [db isSetTopWithConvId:self.convId];
    if (isSetTop)
    {
        [db SetTopFlag:0 andConv:self.convId];
    }
    else
    {
        int setTopTime = [db SetTopFlag:1 andConv:self.convId];
    }
}

-(void)setCommonEmp:(id)sender
{
    UISwitch *_switch = (UISwitch*)sender;
    if (_switch.isOn) {

        BOOL ret = [userDataConn sendModiRequestWithDataType:user_data_type_emp andUpdateType:user_data_update_type_insert andData:[NSArray arrayWithObject:[NSNumber numberWithInt:self.emp.emp_id]]];
        
        if (ret) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        }else
        {
            [actionTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.setCommonEmpIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else
    {
        if([userDataDAO isDefaultCommonEmp:self.emp.emp_id]){
            [UserTipsUtil showAlert:@"缺省联系人，不允许删除" autoDimiss:YES];
            [_switch setOn:YES];
            return;
        }
        
        BOOL ret = [userDataConn sendModiRequestWithDataType:user_data_type_emp andUpdateType:user_data_update_type_delete andData:[NSArray arrayWithObject:[NSNumber numberWithInt:self.emp.emp_id]]];
        
        if (ret) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        }else
        {
            [actionTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.setCommonEmpIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }

}

-(void)setCommonGroupFlag:(id)sender
{
    
    UISwitch *_switch = (UISwitch*)sender;
    if (_switch.isOn) {
        
#ifdef _LANGUANG_FLAG_
        
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        NSArray *arr = [userDataDAO getALlCommonGroup];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSMutableArray *dataArr = [NSMutableArray array];
        for (int i = 0 ; i < arr.count; i++) {
            
            Conversation *conv = arr[i];
            NSString *str = [NSString stringWithFormat:@"chatid=%@,subject=%@",conv.conv_id,conv.conv_title];
            [dataArr addObject:str];
            
        }
        NSString *str = [NSString stringWithFormat:@"chatid=%@,subject=%@",self.convId,self.titleStr];
        
        [dataArr addObject:str];
        
        [dict setObject:dataArr forKey:@"data"];
        [dict setObject:_conn.userId forKey:@"userid"];
        [userDataConn getLGCommonGroup:dict];
        [userDataDAO addOneCommonGroup:self.convId];
        [userDataDAO getALlCommonGroup];

#else
        [userDataDAO addOneCommonGroup:self.convId];
        [userDataDAO getALlCommonGroup];
#endif
        
    }else
    {
#ifdef _LANGUANG_FLAG_
        
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        NSArray *arr = [userDataDAO getALlCommonGroup];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSMutableArray *dataArr = [NSMutableArray array];
        for (int i = 0 ; i < arr.count; i++) {
            
            Conversation *conv = arr[i];
            if ([conv.conv_id isEqualToString:self.convId]) {
                
                continue;
            }
            NSString *str = [NSString stringWithFormat:@"chatid=%@,subject=%@",conv.conv_id,conv.conv_title];
            [dataArr addObject:str];
            
        }
        
        [dict setObject:dataArr forKey:@"data"];
        [dict setObject:_conn.userId forKey:@"userid"];
        [userDataConn getLGCommonGroup:dict];
        [userDataDAO removeOneCommonGroup:self.convId];
#else
        [userDataDAO removeOneCommonGroup:self.convId];
#endif
    }
    

    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    if (_item.clickSelector) {
        [self performSelector:(_item.clickSelector)];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (SettingItem *)getSettingItemByIndexPath:(NSIndexPath *)indexPath
{
    int section=[indexPath section];
    int row = [indexPath row];
    
    NSArray *_array = [self.settingArray objectAtIndex:section];
    SettingItem *_item = [_array objectAtIndex:row];
    return _item;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#ifdef _LANGUANG_FLAG_
    return 12;
#endif
    if(section == 0){
//        if (self.talkType == singleType || isSystemGroup){
//          return 0;
//        }
        return 18;
    }
	return 9;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
#ifdef _LANGUANG_FLAG_
    return 0.01;
#endif
	return 9;
}

-(void)showIndicator
{
	[[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
	[[LCLLoadingView currentIndicator]show];
}

#pragma mark alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==2) {
        if(buttonIndex == 1) //ok
        {        
            if (self.last_msg_id==-1)
            {
            [db deleteConvAndConvRecordsBy:self.convId];
            [db deleteOffenGroupFromVirGroup:self.convId];
            ((talkSessionViewController*)self.predelegete).needUpdateTag=1;
            [self.navigationController popViewControllerAnimated:NO];
            [((talkSessionViewController*)self.predelegete) backButtonPressed:nil];
                return;
            }
			[self performSelectorOnMainThread:@selector(showIndicator) withObject:nil waitUntilDone:YES];
//            [[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
//            [[LCLLoadingView currentIndicator]show];
            
            if(![_conn quitGroup:self.convId])
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"chatmessage_exit_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            }
        }
    }else{
	 if(buttonIndex == 1)
	 {
		[db deleteConvRecordBy:self.convId];
		( (talkSessionViewController*)self.predelegete).needUpdateTag=1;

		[self.navigationController popViewControllerAnimated:YES];
		//[self dismissModalViewControllerAnimated:NO];
        //[self.predelegete dismissModalViewControllerAnimated:YES];
       
	 }
    }
}

-(void) deleteAction{
    //	删除对话、删除聊天记录提示：确定删除该群聊的聊天记录吗？/确定删除和唐承良的聊天记录吗？/确定要清除全部聊天记录吗？
	NSString *tips=@"";
	if(self.talkType == singleType)
	{
		tips = [NSString stringWithFormat:[StringUtil getLocalizableString:@"chatmessage_sure_to_delete_x_chatRecord"]	,self.titleStr];
	}
	else
	{
		tips = [StringUtil getLocalizableString:@"chatmessage_sure_to_delete_group_chatRecord"];
	}
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAppLocalizableString:@"main_chats"] message:tips delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
	[alert dismissWithClickedButtonIndex:1 animated:YES];
	[alert show];
	[alert release];
}

//屏蔽群组消息
-(void)setConvRcvFlag:(id)sender
{
    UISwitch *_switch = (UISwitch*)sender;

    if ([UserTipsUtil checkNetworkAndUserstatus]) {
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
        
        NSLog(@"%d",_switch.isOn?0:1);

        if(![_conn setRcvFlagOfConv:self.convId andRcvMsgFlag:_switch.isOn?0:1])
        {
            [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
            [_switch setOn:!_switch.isOn];
        }
        else
        {
            NSString *operType = @"set_conv_rcv_flag";
            NSDictionary *dic = [NSDictionary dictionaryWithObject:operType forKey:@"oper_type"];
            timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(processTimeout:) userInfo:dic repeats:NO];
        }
    }
    else
    {
        [_switch setOn:!_switch.isOn];
    }
}

#pragma mark 通讯超时
-(void)processTimeout:(NSDictionary *)info
{
//	超时，恢复原来的值
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
    UISwitch *_switch = (UISwitch*)[[actionTable cellForRowAtIndexPath:self.setRcvMsgFlagIndexPath] viewWithTag:rcv_msg_flag_tag];
    
	[_switch setOn:(!_switch.isOn)];

	[self showError:[StringUtil getLocalizableString:@"request_timeout"]];
	timeoutTimer = nil;
}

#pragma mark 设置屏蔽群组消息结果
-(void)processSetRcvMsgFlag:(NSNotification*)notification
{
	if(timeoutTimer && [timeoutTimer isValid])
	{
		[timeoutTimer invalidate];
		timeoutTimer = nil;
	}
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
	NSDictionary *dic = notification.userInfo;
	NSString *convId = [dic valueForKey:@"conv_id"];
	int resultCode = [[dic valueForKey:@"result_code"]intValue];
//	NSLog(@"convId is %@,resultCode is %d",convId,resultCode);
    UISwitch *_switch = (UISwitch*)[[actionTable cellForRowAtIndexPath:self.setRcvMsgFlagIndexPath] viewWithTag:rcv_msg_flag_tag];
    
	if(resultCode == RESULT_SUCCESS)
	{
		[db updateRcvMsgFlagOfConvByConvId:self.convId andRcvMsgFlag:(_switch.isOn?0:1)];
        if(_switch.isOn)
        {
            rcvFlagView.hidden = YES;
        }
        else
        {
            rcvFlagView.hidden = NO;
        }
	}
	else
	{
		[_switch setOn:(!_switch.isOn)];
		[self showError:[StringUtil getLocalizableString:@"set_conv_rcv_flag_error"]];
	}
}
-(void)showError:(NSString*)errMsg
{
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:errMsg delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}

#pragma mark ===========用户状态变化，需要刷新状态变化用户的状态=============
- (void)empStatusChange:(NSNotification *)_notification
{
    if (self.talkType == singleType || self.talkType == mutiableType)
    {
        NSDictionary *dic = _notification.userInfo;
        if (dic)
        {
            BOOL needReload = NO;
            NSArray *statusChangeArray = [dic valueForKey:key_status_change_array];
            
            for (NSDictionary *dic in statusChangeArray)
            {
                int curEmpId = [[dic valueForKey:@"emp_id"]intValue];
                int empStatus = [[dic valueForKey:@"emp_status"]intValue];
                int loginType = [[dic valueForKey:@"emp_login_type"]intValue];
                
                for (Emp *emp in self.dataArray)
                {
                    if (emp.emp_id == curEmpId) {
                        emp.emp_status = empStatus;
                        emp.loginType = loginType;
                        if (!needReload) {
                            needReload = YES;
//                            [LogUtil debug:@"chat msg 发现一个用户状态变化了"];
                        }
                        break;
                    }
              }
            }
            if (needReload)
            {
                [self performSelectorOnMainThread:@selector(showMemberScrollow) withObject:nil waitUntilDone:YES];
            }
        }
    }
}

#pragma mark ========单聊、群组、临时讨论组等显示不同的设置==========

- (void)prepareSettingItems
{
    //        初始化数组
    self.settingArray = [NSMutableArray array];
    
    //        临时数组
    NSMutableArray *tempArray = [NSMutableArray array];
    
    SettingItem *_item = nil;
    
    //        =======section 0 =======
    
    //        如果是临时讨论组显示群组名称
    if (self.talkType == mutiableType && !isSystemGroup)
    {
        // 讨论组名称
        _item = [[[SettingItem alloc]init]autorelease];
//        _item.itemName = [StringUtil getLocalizableString:@"chatmessage_groupname"];
        _item.itemName = [StringUtil getLocalizableString:@"群组名称"];
        _item.customCellSelector = @selector(customGroupName:);
        _item.clickSelector = @selector(discussionGroupNameSetting);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //       按照万达的原型把群组名称显示在群组成员上面
        if ([self isTableHeaderViewIncludeFunctionEntrance]) {
            groupNameItem = [_item retain];
            [self addGroupNameView];
        }else{
            [tempArray addObject:_item];
        }
    }
    
    if (tempArray.count) {
        [self.settingArray addObject:tempArray];
    }
    
    //        =======section 1=======
    
    tempArray = [NSMutableArray array];
    
    // 置顶改聊天
    _item = [[[SettingItem alloc]init]autorelease];
    _item.itemName = [StringUtil getAppLocalizableString:@"chatmessage_chat_set_top"];
    _item.customCellSelector = @selector(chatSetTopSwitch:);
    
    //        单聊、群聊、临时讨论组 都显示置顶功能
    [tempArray addObject:_item];
    
    //        单聊 有 设置为常用联系人功能
    if (self.talkType == singleType) {
        /** 华夏幸福不需要设为常用联系人 */
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_) || defined(_XINHUA_FLAG_)

#else
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [StringUtil getLocalizableString:@"chatmessage_set_common_emp"];
        _item.customCellSelector = @selector(customSetCommonEmpCell:);
        [tempArray addObject:_item];
        
        self.setCommonEmpIndexPath = [NSIndexPath indexPathForRow:tempArray.count-1 inSection:self.settingArray.count];
        
#endif
    }
    
    //        临时讨论组 有 新消息提醒功能 设为常用讨论组功能
    if (self.talkType == mutiableType && !isSystemGroup) {
        // 新消息提醒
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [StringUtil getLocalizableString:@"chatmessage_new_message_remind"];
        _item.customCellSelector = @selector(newMessageRemindSwitch:);
        [tempArray addObject:_item];
        
        self.setRcvMsgFlagIndexPath = [NSIndexPath indexPathForRow:tempArray.count-1 inSection:self.settingArray.count];
        
        /** 华夏幸福屏蔽 设为常用讨论组 */
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        
#else
        // 设为常用讨论组
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [StringUtil getAppLocalizableString:@"chatmessage_set_common_group"];
        _item.customCellSelector = @selector(setCommonGroupSwitch:);
        
        [tempArray addObject:_item];
#endif
    }
    
    if (tempArray.count) {
        [self.settingArray addObject:tempArray];
    }
 
    //        ==section  3 ===
    tempArray = [NSMutableArray array];
    
    // 设置聊天背景
    if (![UIAdapterUtil isGOMEApp])
    {
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [StringUtil getLocalizableString:@"chatmessage_set_current_background"];
        _item.clickSelector = @selector(setCurrentBackground);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [tempArray addObject:_item];
    }
    
    
    // 查找聊天记录 功能按钮 固定包含 搜索，所以这里就不包含了
    if ([self isTableHeaderViewIncludeFunctionEntrance]) {
        
    }else{
        
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [StringUtil getLocalizableString:@"chatmessage_view_chat_record"];
        _item.clickSelector = @selector(viewChatRecord);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [tempArray addObject:_item];
        
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [StringUtil getLocalizableString:@"chatmessage_view_chat_pics"];
        _item.clickSelector = @selector(viewPictures);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [tempArray addObject:_item];
        
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [StringUtil getLocalizableString:@"chatmessage_view_chat_files"];
        _item.clickSelector = @selector(viewFileList);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [tempArray addObject:_item];
#endif

    }
    
    // 清空聊天记录
    _item = [[[SettingItem alloc]init]autorelease];
    _item.itemName = [StringUtil getLocalizableString:@"chatmessage_empty_chat_record"];
    _item.clickSelector = @selector(emptyChatRecord);
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [tempArray addObject:_item];
    
    if (tempArray.count) {
        [self.settingArray addObject:tempArray];
    }
}

//定义 置顶聊天 cell
- (void)chatSetTopSwitch:(UITableViewCell *)cell
{
    UISwitch *_switch = [[UISwitch alloc]init];
#ifdef _LANGUANG_FLAG_
    _switch.onTintColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1];
#endif

    BOOL isSetTop = [db isSetTopWithConvId:self.convId];
    if (isSetTop) {
        [_switch setOn:YES];
    }else
    {
        [_switch setOn:NO];
    }
    
    [_switch addTarget:self action:@selector(setConvTop) forControlEvents:UIControlEventValueChanged];
    
    [cell addSubview:_switch];
    [_switch release];
    [UIAdapterUtil positionSwitch:_switch ofCell:cell];
    CGRect _frame;
    _frame = _switch.frame;
    _frame.origin.y = (51-_frame.size.height) /2;
    _switch.frame = _frame;
    
}

//定义 新消息提醒cell
- (void)newMessageRemindSwitch:(UITableViewCell *)cell
{
    UISwitch *_switch = [[UISwitch alloc]init];
#ifdef _LANGUANG_FLAG_
    _switch.onTintColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1];
#endif
    _switch.tag = rcv_msg_flag_tag;
    
    BOOL _flag = [db getRcvMsgFlagOfConvByConvId:self.convId];
    if(_flag)
    {
        [_switch setOn:NO];
    }
    else
    {
        [_switch setOn:YES];
    }
    [_switch addTarget:self action:@selector(setConvRcvFlag:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:_switch];
    [_switch release];
    [UIAdapterUtil positionSwitch:_switch ofCell:cell];
    CGRect _frame;
    _frame = _switch.frame;
    _frame.origin.y = (51-_frame.size.height) /2;
    _switch.frame = _frame;
}

//定制设置为常用讨论组cell
- (void)setCommonGroupSwitch:(UITableViewCell *)cell
{
    UISwitch *_switch = [[UISwitch alloc]init];
    
#ifdef _LANGUANG_FLAG_
    _switch.onTintColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1];
#endif
    BOOL _flag1 = [userDataDAO isCommonGroup:self.convId];
    //
    if(_flag1)
    {
        [_switch setOn:YES];
    }
    else
    {
        [_switch setOn:NO];
    }
    [_switch addTarget:self action:@selector(setCommonGroupFlag:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:_switch];
    [_switch release];
    [UIAdapterUtil positionSwitch:_switch ofCell:cell];
    CGRect _frame = _switch.frame;
    _frame.origin.y = 10;
    _switch.frame = _frame;
}

- (void)customGroupName:(UITableViewCell *)cell
{
    UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(150, 0, self.view.frame.size.width - 200, DEFAULT_ROW_HEIGHT)];
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textColor=[UIColor grayColor];
    titlelabel.font=cell.textLabel.font;

    titlelabel.text = self.titleStr;
    titlelabel.textAlignment=NSTextAlignmentRight;
    [cell addSubview:titlelabel];
    [titlelabel release];

}

//定义设置为常用联系人cell
- (void)customSetCommonEmpCell:(UITableViewCell *)cell
{
    UISwitch *_switch = [[UISwitch alloc]init];
#ifdef _LANGUANG_FLAG_
    _switch.onTintColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1];
#endif
    [UIAdapterUtil positionSwitch:_switch ofCell:cell];

    CGRect _frame = _switch.frame;
    _frame.origin.y = 10;
    _switch.frame = _frame;
    
    BOOL _flag = [userDataDAO isCommonEmp:self.emp.emp_id];
    
    if(_flag)
    {
        [_switch setOn:YES];
    }
    else
    {
        [_switch setOn:NO];
    }
    
    [_switch addTarget:self action:@selector(setCommonEmp:) forControlEvents:UIControlEventValueChanged];
    
    [cell addSubview:_switch];
    [_switch release];
}

// 讨论组名称
- (void)discussionGroupNameSetting
{
    modifyGroupNameViewController*  modifyGroup=[[modifyGroupNameViewController alloc]init];
    modifyGroup.convId=self.convId;
    modifyGroup.delegete=self;
    
    modifyGroup.oldGroupName = self.titleStr;
    modifyGroup.last_msg_id=self.last_msg_id;
    [self.navigationController pushViewController:modifyGroup animated:YES];
    //        [self presentModalViewController:modifyGroup animated:YES];
    [modifyGroup release];
}

// 打开回执消息列表
- (void)TheReceiptOfMessage
{
    ReceiptMsgViewController *receiptMsgCtl = [[[ReceiptMsgViewController alloc] init] autorelease];
    receiptMsgCtl.convID = self.convId;
    [self.navigationController pushViewController:receiptMsgCtl animated:YES];
}

// 设置聊天背景
- (void)setCurrentBackground
{
    chatBackgroudViewController *chatBackgroud =[[chatBackgroudViewController alloc]init];
    chatBackgroud.one_chat_imagename=[ChatBackgroundUtil getCustomBackgroundNameOfConv:self.convId];
    [self.navigationController pushViewController:chatBackgroud animated:YES];
    [chatBackgroud release];
}

// 查找聊天记录
- (void)viewChatRecord
{
    ChatHistorySearchView *chatHistorySearch = [[ChatHistorySearchView alloc] init];
    chatHistorySearch.convId = self.convId;
    chatHistorySearch.convName = self.titleStr;
    chatHistorySearch.talkType = self.talkType;
    [self.navigationController pushViewController:chatHistorySearch animated:NO];
    [chatHistorySearch release];
}

// 清空聊天记录
- (void)emptyChatRecord
{
    [self deleteAction];
}

// 查看图片
- (void)viewPictures
{
    DisplayPicViewController *chatPic =[[DisplayPicViewController alloc]init];
    chatPic.convId = self.convId;
    [self.navigationController pushViewController:chatPic animated:YES];
    [chatPic release];
}

//查看文件列表
- (void)viewFileList
{
    FileAssistantViewController *_controller = [[[FileAssistantViewController alloc]init]autorelease];
    _controller.convId = self.convId;
    _controller.fileDisplayType = file_display_type_group_by_time;
    [self.navigationController pushViewController:_controller animated:YES];
}

#pragma mark =======万达二期要求的聊天资料界面变化=========

//回执消息入口、图片消息入口、文件消息入口、搜索入口等

//生成消息入口的uiview

#define FUNCTION_ENTRANCE_BUTTON_HIGHT (80.0)

- (void)addFunctionEntranceView
{
    tableHeaderParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    actionTable.tableHeaderView = tableHeaderParentView;
    
    functionEntranceParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    functionEntranceParentView.backgroundColor = [UIColor whiteColor];
    
    NSArray *entranceArray = [self getFunctionArray];
    
//    每行的button个数
    int perRowCount = 4;
    if (IS_IPHONE_6P) {
        perRowCount = 5;
    }
    
    //按钮总个数
    int totalCount = entranceArray.count;
//    按钮所占行数
    int totalRow = totalCount / perRowCount + (totalCount % perRowCount == 0 ? 0 : 1);
    
//    如果只显示一行，那么总数就是每行显示的数
    if (totalRow == 1) {
        perRowCount = totalCount;
    }

//    每个按钮的宽度 和 高度
    float buttonWidth = functionEntranceParentView.frame.size.width / perRowCount;
    float buttonHeight = FUNCTION_ENTRANCE_BUTTON_HIGHT;
    
    for (int i = 0; i < entranceArray.count; i ++) {
        
        int row = i / perRowCount;
        int col = i % perRowCount;
        
        CGRect frame = CGRectMake(buttonWidth * col, buttonHeight * row, buttonWidth, buttonHeight);
        FunctionEntranceModel *model = entranceArray[i];
        model.frame = frame;
        
        UIButton *button = [self createButtonWithModel:model];
        
        [functionEntranceParentView addSubview:button];
    }
    
//    设置父view的高度
    CGRect _frame = functionEntranceParentView.frame;
    _frame.size.height = totalRow * buttonHeight;
    functionEntranceParentView.frame = _frame;
    
//    把入口加到 tableheader父view中
    [tableHeaderParentView addSubview:functionEntranceParentView];
    [functionEntranceParentView release];
}

- (NSArray *)getFunctionArray
{
    NSMutableArray *entranceArray = [NSMutableArray array];
    
    //    回执入口 不再需要
//    FunctionEntranceModel *model = [[[FunctionEntranceModel alloc]init]autorelease];
//    model.title = [StringUtil getLocalizableString:@"chatmessage_function_entrance_receipt_msg"];
//    model.normalImageName = @"icon_mine_click.png";
//    
//    [entranceArray addObject:model];
    
    //    图片消息入口
    FunctionEntranceModel *model = [[[FunctionEntranceModel alloc]init]autorelease];
    model.title = [StringUtil getLocalizableString:@"chatmessage_function_entrance_pic_msg"];
    model.normalImageName = @"tupian.png";
    model.clickSelector = @selector(viewPictures);
    
    [entranceArray addObject:model];
    
    //    文件消息入口
    model = [[[FunctionEntranceModel alloc]init]autorelease];
    model.title = [StringUtil getLocalizableString:@"chatmessage_function_entrance_file_msg"];
    model.normalImageName = @"wenjian.png";
    model.clickSelector = @selector(viewFileList);
    
    [entranceArray addObject:model];
    
    
    //    查询消息入口
    model = [[[FunctionEntranceModel alloc]init]autorelease];
    model.title = [StringUtil getLocalizableString:@"chatmessage_function_entrance_search_msg"];
    model.normalImageName = @"sousuo.png";
    model.clickSelector = @selector(viewChatRecord);
    [entranceArray addObject:model];
    
    return entranceArray;
}

//tableView的headerview只是群组成员，还是像像万达版本，增加快捷入口等
- (BOOL)isTableHeaderViewIncludeFunctionEntrance
{
    if ([[eCloudConfig getConfig]chatMessageDisplayPicMsgEntrance]) {
        return YES;
    }
    return NO;
}

//设置 tableHeaderView及其子view的frame
- (void)reCalculateTableHeaderViewFrame
{
    float height1 = functionEntranceParentView.frame.size.height;
    float height2 = 20;
    float height3 = 0.0;
    
    if (groupNameCell) {
//        group name 和 分割线
        height3 = DEFAULT_ROW_HEIGHT + 1;
    }
    float height4 = memberParentView.frame.size.height;
    
    CGRect _frame = tableHeaderParentView.frame;
    _frame.size.height = height1 + height2 + height3 + height4;
    tableHeaderParentView.frame = _frame;
    
    if (groupNameCell) {
        _frame = groupNameCell.frame;
        _frame.origin.y = height1 + height2;
        groupNameCell.frame = _frame;
        
//        分割线的y值
        _frame = groupNameSeperateLine.frame;
        _frame.origin.y = height1 + height2 + DEFAULT_ROW_HEIGHT;
        groupNameSeperateLine.frame = _frame;
    }
    
    _frame = memberParentView.frame;
    _frame.origin.y = height1 + height2 + height3;
    memberParentView.frame = _frame;
    
    actionTable.tableHeaderView = tableHeaderParentView;
}

//群组名称cell
- (void)addGroupNameView
{
    if (groupNameCell) {
        [groupNameCell removeFromSuperview];
    }

    groupNameCell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    groupNameCell.frame = CGRectMake(0, 0, self.view.frame.size.width,DEFAULT_ROW_HEIGHT);
    
    [tableHeaderParentView addSubview:groupNameCell];
    
    groupNameCell.backgroundColor = [UIColor whiteColor];

    groupNameCell.textLabel.text = groupNameItem.itemName;
    groupNameCell.accessoryType = groupNameItem.accessoryType;
    groupNameCell.selectionStyle = groupNameItem.selectionStyle;
    
    if (groupNameItem.customCellSelector) {
        [self performSelector:(groupNameItem.customCellSelector) withObject:groupNameCell];
    }
    if (groupNameItem.clickSelector) {
        groupNameCell.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:self action:groupNameItem.clickSelector]autorelease];
        
        [groupNameCell addGestureRecognizer:singleTap];
    }
    
    groupNameSeperateLine = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)]autorelease];
    groupNameSeperateLine.backgroundColor = [UIColor whiteColor];
    [tableHeaderParentView addSubview:groupNameSeperateLine];
    
    UIView *lineView = [[[UIView alloc]initWithFrame:CGRectMake(10, 0, groupNameSeperateLine.frame.size.width - 10, 1)]autorelease];
    lineView.backgroundColor = self.view.backgroundColor;
    [groupNameSeperateLine addSubview:lineView];
}

//生成一个按钮
- (UIButton *)createButtonWithModel:(FunctionEntranceModel *)model
{
    FunctionEntranceButton *button = [FunctionEntranceButton buttonWithType:UIButtonTypeCustom];
    
    //    button.tag = tag;
    
    button.frame = model.frame;
    
    [button setImage:[StringUtil getImageByResName:model.normalImageName] forState:UIControlStateNormal];
    //    [button setImage:[StringUtil getImageByResName:model.highlightImageName] forState:UIControlStateHighlighted];
    //    [button setImage:[StringUtil getImageByResName:model.highlightImageName] forState:UIControlStateSelected];
    
    [button setTitle:model.title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIAdapterUtil getCustomGrayFontColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:model.clickSelector forControlEvents:UIControlEventTouchDown];
    
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    return button;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = CGRectZero;
    _frame = actionTable.frame;
    
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = self.view.frame.size.height;// SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    actionTable.frame = _frame;
    
    [actionTable reloadData];
    
//    exitButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 58*2)];
    _frame = deleteButton.frame;
    _frame.size.width = SCREEN_WIDTH - _frame.origin.x * 2;
    deleteButton.frame = _frame;
    
    _frame = memberScroll.frame;
    _frame.size.width = SCREEN_WIDTH;
    memberScroll.frame = _frame;
    
    _frame = self.expandButton.frame;
    _frame.origin.x = SCREEN_WIDTH - expandButtonWidth;
    self.expandButton.frame = _frame;
    
    _frame = flagParentView.frame;
    _frame.size.width = SCREEN_WIDTH;
    flagParentView.frame = _frame;

    [self setMemberViewLayout];
    
    [self showMemberScrollow];
    
    [GXViewController displaySubViewOfView:actionTable andLevel:0];
}

- (void)setMemberViewLayout
{
    perRowCount = 4;
    if (IS_IPHONE_6P)
    {
        perRowCount = 5;
    }
    
    if (IS_IPAD) {
        if ([UIAdapterUtil isLandscap]) {
            perRowCount = 13;
        }else{
            perRowCount = 10;
        }
    }
    
    spaceX = (SCREEN_WIDTH - x0 * 2 - perRowCount * perItemWidth) / (perRowCount - 1);
}

#pragma =====chooseMemberDelegate======
- (void)didFinishSelectContacts:(NSArray *)userArray
{
    [CreateGroupUtil getUtil].currentVC = self;
    [CreateGroupUtil getUtil].typeTag = type_add_conv_emp;
    
    [[CreateGroupUtil getUtil]addConvEmp:userArray];
}


#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
- (void)didSelectHXUsers:(NSArray *)usersArray{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    [CreateGroupUtil getUtil].currentVC = self;
    [CreateGroupUtil getUtil].typeTag = type_add_conv_emp;
    
    [[CreateGroupUtil getUtil]addConvEmp:usersArray];
}
#endif

- (void)isSuccess:(NSNotification *)notification{
    
    [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
    NSString *urlStr = notification.userInfo[XIANGYUAN_STATUS];
    if ([urlStr isEqualToString:@"失败"]) {
        
        UISwitch *_switch = (UISwitch*)[[actionTable cellForRowAtIndexPath:self.setRcvMsgFlagIndexPath] viewWithTag:rcv_msg_flag_tag];
        
        [_switch setOn:(!_switch.isOn)];
        [self showError:@"修改常用讨论组失败"];
    }


}

@end
