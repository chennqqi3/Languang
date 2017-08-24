//
//  contactViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "ForwardingRecentViewController.h"
#import "CreateGroupUtil.h"

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#endif

#ifdef _LANGUANG_FLAG_
#import "LGRootChooseMemberViewController.h"
#endif

#ifdef _XINHUA_FLAG_
#import "XINHUAOrgSelectedViewControllerArc.h"
#import "UserDataDAO.h"
#endif

#import "ConvNotification.h"
#import "Emp.h"

#import "eCloudNotification.h"

#import "ApplicationManager.h"

#import "ForwardMsgUtil.h"

#import "conn.h"

#import "eCloudDAO.h"

#import "NewChooseMemberViewController.h"
#import "specialChooseMemberViewController.h"
#import "ConvRecord.h"
#import "Conversation.h"

#import "talkSessionUtil2.h"

#import "UIAdapterUtil.h"

#import "UserTipsUtil.h"

#import "NewGroupCell.h"

#import "talkSessionViewController.h"

#import "chatHistoryView.h"
#import "AppDelegate.h"
#import "UserDefaults.h"
#define RECEIVE_MAP_VIEW_CONTROLLER @"receiveMapViewController"
#define DISMISS @"dismiss"


#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
@interface ForwardingRecentViewController () <ChooseMemberDelegate,HuaXiaOrgProtocol>
#else
@interface ForwardingRecentViewController () <ChooseMemberDelegate>
#endif

@property (nonatomic,retain) NSTimer *searchTimer;

@property (nonatomic,retain) NSMutableArray *searchResults;

@end

@implementation ForwardingRecentViewController
{
	eCloudDAO *_ecloud ;
    
    UISearchDisplayController * searchdispalyCtrl;
    
    conn *_conn;
    BOOL isSearch;
    
    UISearchBar *_searchBar;
    UIButton *backgroudButton;
    
    UIAlertView *sendAlert;
}

@synthesize fromType;
@synthesize fromVC;

@synthesize searchResults;
@synthesize itemArray;
@synthesize forwardRecordsArray;
@synthesize searchText;
@synthesize personTable;
@synthesize forwardRecord;
@synthesize forwardConv;
@synthesize searchTimer;
@synthesize isComeFromFileAssistant;


-(void)dealloc
{
    
    NSLog(@"%s,remove observer",__FUNCTION__);
    self.searchResults = nil;
    
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    self.forwardConv = nil;
    self.forwardRecord = nil;
    self.itemArray = nil;
    
    self.personTable = nil;
    self.searchText = nil;
    
    self.searchTimer = nil;
    
    if (sendAlert)
    {
        [sendAlert release];
        sendAlert = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:FORWARD_TO_EXIST_GROUP object:nil];
    
    [super dealloc];
}

- (id)initWithConvRecord:(ConvRecord *)convRecord
{
    self = [super init];
    if(self)
    {
        self.forwardRecord = convRecord;
        if (convRecord) {
            self.forwardRecordsArray = [NSArray arrayWithObject:convRecord];
        }
    }
    return self;
}

-(void)refreshData
{
	self.itemArray = [NSMutableArray array];

	NSArray *array = [_ecloud getRecentConvForTransMsg];
    if (array)
    {
        [self.itemArray addObjectsFromArray:array];
    }
    
	[self.personTable reloadData];
}

-(void)backButtonPressed:(id)sender
{
    if ([_fromWhere isEqualToString:RECEIVE_MAP_VIEW_CONTROLLER]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DISMISS object:self];
        [self dismissModalViewControllerAnimated:YES];

    }else{
        
        [self dismissModalViewControllerAnimated:YES];
    }
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_conn = [conn getConn];
    _ecloud = [eCloudDAO getDatabase];
	
   //设置背景
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    self.title = [StringUtil getLocalizableString:@"forward"];
    
//    先初始化搜索框
    [self initSearch];
 	
//最近会话展示窗口
	
	int tableH = SCREEN_HEIGHT - 20 - 44 - _searchBar.frame.size.height;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
//	if(iPhone5)
//		tableH = tableH + i5_h_diff;
	
	self.personTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, _searchBar.frame.size.height, SCREEN_WIDTH, tableH) style:UITableViewStylePlain]autorelease];
    [UIAdapterUtil setPropertyOfTableView:self.personTable];
    self.personTable.backgroundColor=[UIColor clearColor];
    [self.personTable setDelegate:self];
    [self.personTable setDataSource:self];
    [self.view addSubview:self.personTable];

    [UIAdapterUtil alignHeadIconAndCellSeperateLine:self.personTable];
    [UIAdapterUtil setExtraCellLineHidden:self.personTable];
//
    backgroudButton=[[[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH)]autorelease];
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    [self.personTable addSubview:backgroudButton];
    backgroudButton.hidden=YES;
    
    [self refreshData];
    
    
    //监听转发选择现有群组
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forwardToExistGroup:) name:FORWARD_TO_EXIST_GROUP object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];
}

//隐藏查询bar输入框键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[searchTextView resignFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [UserDefaults setWhereStartFrom:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

-(void)dismissKeybordByClickBackground
{
   [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
}

#pragma mark - 监听转发选择现有群组
- (void)forwardToExistGroup:(NSNotification *)notification{
    if (sendAlert==nil){
        sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:@"" delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
    }
    
    Conversation *conv= (Conversation*)[notification object];
    self.forwardConv = conv;
//    sendAlert.message = conv.conv_title;
    [self setAlertViewTitleAndMessage];
    [sendAlert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma  mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    
    if (section==0)
    {
        
        if ([UIAdapterUtil isHongHuApp] && [UserDefaults getWhereStartFrom] != nil) {
            return 2;
        }else{
            return 1;
        }
    }
    else
    {
        return [self.itemArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return GroupCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self getQueryResultGroupCell:indexPath];
    }
    else
    {
        if ([UIAdapterUtil isHongHuApp] && [UserDefaults getWhereStartFrom] != nil ) {
            
            if (indexPath.section == 0 && indexPath.row == 0)
            {
                UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                //            不使用系统的label
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 250, GroupCellHeight)];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
                nameLabel.text = [StringUtil getLocalizableString:@"saved_to_the_cloud_disk"];
                [cell.contentView addSubview:nameLabel];
                [nameLabel release];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            if (indexPath.section == 0 && indexPath.row == 1)
            {
                UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                //            不使用系统的label
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 250, GroupCellHeight)];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
                nameLabel.text = [StringUtil getLocalizableString:@"chats_new_chat"];
                [cell.contentView addSubview:nameLabel];
                [nameLabel release];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            
        }else{
            
            if (indexPath.section == 0 && indexPath.row == 0)
            {
                UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                //            不使用系统的label
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 250, GroupCellHeight)];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
                nameLabel.text = [StringUtil getLocalizableString:@"chats_new_chat"];
                [cell.contentView addSubview:nameLabel];
                [nameLabel release];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
        }
        return [self getGroupCell:indexPath];
    }
}
//查询结果
- (NewGroupCell *)getQueryResultGroupCell:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"groupCellID";
    NewGroupCell *groupCell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (groupCell == nil)
    {
        groupCell = [[[NewGroupCell alloc]initForTransferWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    Conversation *conv = (Conversation *)[self.searchResults objectAtIndex:indexPath.row];
    
    [groupCell configCell:conv];
    
    return groupCell;
}

//最近聊天
- (NewGroupCell *)getGroupCell:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"groupCellID";
    NewGroupCell *groupCell = [self.personTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (groupCell == nil)
    {
        groupCell = [[[NewGroupCell alloc]initForTransferWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    Conversation *conv = (Conversation *)[self.itemArray objectAtIndex:indexPath.row];
    
    [groupCell configCell:conv];

    return groupCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    
    if (section==0)
    {
       return 0;
    }else
    {
       return 40;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    if (section==0) {//搜索结果
        return nil;
    }
    else
    {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        headerView.backgroundColor = self.view.backgroundColor;
        
        UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(7, 20, SCREEN_WIDTH-10, 20)];
        titlelabel.backgroundColor = [UIColor clearColor];
        titlelabel.font=[UIFont systemFontOfSize:14];
        titlelabel.textColor = [UIColor grayColor];
        titlelabel.text= [StringUtil getLocalizableString:@"specialChoose_recent_contact"];
        [headerView addSubview:titlelabel];
        [titlelabel release];
        return [headerView autorelease];
    }
 
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	[searchTextView resignFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
	
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        
        Conversation* conv=[self.searchResults objectAtIndex:indexPath.row];
        if(conv.conv_type == mutiableType && ![_ecloud userExistInConvEmp:conv.conv_id])
        {
            [UserTipsUtil sendMsgForbidden];
            return;
        }
        if (sendAlert==nil)
        {
            sendAlert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:@"" delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        }
        
//        Conversation* conv=[self.searchResults objectAtIndex:indexPath.row];
        
//        记录转发到的会话对象
        
        self.forwardConv = conv;
//        if(conv.conv_type == mutiableType)
//        {
//            int all_num= [_ecloud getAllConvEmpNumByConvId:conv.conv_id];
//            sendAlert.message=[NSString stringWithFormat:[StringUtil getLocalizableString:@"chats_forward_to"],conv.conv_title,all_num];
//        }
//        else
//        {
            [self setAlertViewTitleAndMessage];
//        }
        sendAlert.tag=indexPath.row;
        [sendAlert show];
    }
    else
    {
        if ([UIAdapterUtil isHongHuApp] && [UserDefaults getWhereStartFrom] != nil) {
            
            if (indexPath.section==0 && indexPath.row == 0){
                
//                ConvRecord *model = self.forwardRecordsArray[0];
//                NSLog(@"保存到云盘");
//                NSLog(@"======%@",model.file_name);
                [[talkSessionViewController getTalkSession]externalSavedTocloud:self.forwardRecordsArray];
            }
            else if (indexPath.section==0 && indexPath.row == 1) {
                
                [self newChooseMembe];
            }
            else{
                
                Conversation* conv=[self.itemArray objectAtIndex:indexPath.row];
                if(conv.conv_type == mutiableType && ![_ecloud userExistInConvEmp:conv.conv_id])
                {
                    [UserTipsUtil sendMsgForbidden];
                    return;
                }
                if (sendAlert==nil)
                {
                    sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:@"" delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
                    
                }
                self.forwardConv = conv;
                [self setAlertViewTitleAndMessage];
                sendAlert.tag = indexPath.row;
                [sendAlert show];
            }
        }else{
            
            if (indexPath.section==0)
            {
                [self newChooseMembe];
            }
            else
            {
                Conversation* conv=[self.itemArray objectAtIndex:indexPath.row];
                if(conv.conv_type == mutiableType && ![_ecloud userExistInConvEmp:conv.conv_id])
                {
                    [UserTipsUtil sendMsgForbidden];
                    return;
                }
                if (sendAlert==nil)
                {
                    sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:@"" delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
                    
                }
                self.forwardConv = conv;
                [self setAlertViewTitleAndMessage];
                sendAlert.tag = indexPath.row;
                [sendAlert show];
            }
        }
    }
}

//创建新的会
- (void)newChooseMembe{
   
#ifdef _XINHUA_FLAG_
    
    XINHUAOrgSelectedViewControllerArc *orgSelectedVc = [[XINHUAOrgSelectedViewControllerArc alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:orgSelectedVc];
    orgSelectedVc.delegate = self;
    
    [self presentViewController:navi animated:YES completion:nil];
    
    [orgSelectedVc release];
    
    return;
    
    
#endif
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    [HuaXiaOrgUtil getUtil].maxUserCount = [conn getConn].maxGroupMember - 1;
    NSMutableArray *mArray = [NSMutableArray array];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[conn getConn].curUser.emp_id],EMP_ID_KEY, nil];
    [mArray addObject:dic];
    [HuaXiaOrgUtil getUtil].disableSelectUserArray = mArray;

    [HuaXiaOrgUtil getUtil].orgDelegate = self;
    [HuaXiaOrgUtil getUtil].orgOpenType = org_open_type_push;
    [HuaXiaOrgUtil getUtil].openVC = self;

    [[HuaXiaOrgUtil getUtil]openSelectHXUserVC];
    
#elif defined(_LANGUANG_FLAG_)
    LGRootChooseMemberViewController *vc = [[[LGRootChooseMemberViewController alloc]init]autorelease];
    vc.chooseMemberDelegate = self;
    vc.maxSelectCount = [conn getConn].maxGroupMember - 1;;
    vc.oldEmpIdArray = [NSArray arrayWithObject:[conn getConn].curUser];
    UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:vc];
    [self presentViewController:navController animated:YES completion:^{
        
    }];
#else
    NewChooseMemberViewController *_controller=[[NewChooseMemberViewController alloc]init];
    
    _controller.forwardingDelegate = self.forwardingDelegate;
    _controller.chooseMemberDelegate = self;
    
    _controller.transferFromType = self.fromType;
    _controller.fromWhere = RECEIVE_MAP_VIEW_CONTROLLER;
    _controller.forwardRecord = self.forwardRecord;
    //         可能是转发多个 add by shisp
    _controller.forwardRecordsArray = self.forwardRecordsArray;
    if (self.fromType == transfer_from_news) {
        
        _controller.typeTag = type_LG_news_share;
        _controller.isSingleSelect = YES;
        
    }else{
        
        _controller.typeTag = type_transfer_msg_create_new_conversation;
    }
    
    _controller.isComeFromChatHistory = self.isComeFromChatHistory;
    
    if (self.isComeFromFileAssistant) {
        //文件助手批量转发
        _controller.isComeFromFileAssistant = self.isComeFromFileAssistant;
        //             _controller.forwardRecordsArray = self.forwardRecordsArray;
    }
    
    [self.navigationController pushViewController:_controller animated:YES];
    [_controller release];

#endif
}
//如果群组还没有创建那么要先创建群组
- (void)createConv
{
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
    [[LCLLoadingView currentIndicator]show];
    
    //    标题
//    NSString *convTitle = [[talkSessionUtil2 getTalkSessionUtil]getTitleStrByConvRecord:self.forwardRecord];
    
    NSArray *convEmps = [_ecloud getAllConvEmpBy:self.forwardConv.conv_id];
    
    NSString *convTitle = self.forwardConv.conv_title;
    
    if(![_conn createConversation:self.forwardConv.conv_id andName:convTitle andEmps:convEmps])
    {
        //        提示不能创建群聊
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"group_creat_group_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel Button Pressed");
            break;
        case 1:
             {
//                 如果是单人聊天，那么首先创建会话
                 if (self.forwardConv.conv_type == singleType) {
                     [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:self.forwardConv.conv_id andTitle:self.forwardConv.conv_title];
                 }
//                 update by shisp
                if (self.forwardConv.last_msg_id == -1)
                 {
                     NSLog(@"群组还没有创建，需要先创建群组");
                     [self createConv];
                 }
                 else
                 {
                     [self transferMsg];
                 }
             }
            break;
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    
}

//保存和转发消息
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
            _convRecord.conv_id = self.forwardConv.conv_id;
            _convRecord.conv_type = self.forwardConv.conv_type;
        }
    }
//    如果没有转发的记录 直接关闭
    if (self.forwardRecordsArray.count == 0) {
        [self dismissModalViewControllerAnimated:YES];
    }else{
        //如果转发的会话id和原来的会话id相同，那么需要刷新界面
        if ([self.forwardConv.conv_id isEqualToString:talkSession.convId])
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
//    //保存要转发的消息
//    BOOL saveSuccess = [talkSession saveForwardMsg];
//    
//    if (!saveSuccess){
//        //保存失败，直接关闭当前的窗口
//        [self dismissModalViewControllerAnimated:YES];
//        return NO;
//    }
//    else{
//        //如果转发的会话id和原来的会话id相同，那么需要刷新界面
//        if ([self.forwardConv.conv_id isEqualToString:talkSession.convId])
//        {
//            talkSession.needUpdateTag = 1;
//        }
//        
//        [talkSession sendForwardMsg];
//        
//        //            talkSession.sendForwardMsgFlag = YES;
//        // 关闭当前界面
//        [self dismissModalViewControllerAnimated:YES];
//        
//        return YES;
//    }
//}
- (void)transferMsg
{
//    保存新的会话id和会话类型
//    self.forwardRecord.conv_id = self.forwardConv.conv_id;
//    self.forwardRecord.conv_type = self.forwardConv.conv_type;
    for (ConvRecord *_convRecord in  self.forwardRecordsArray) {
        _convRecord.conv_id = self.forwardConv.conv_id;
        _convRecord.conv_type = self.forwardConv.conv_type;
    }

//    if (self.fromType == transfer_from_image_preview || self.fromType == transfer_from_collection || self.fromType == transfer_from_talksession) {
    
//        来自图片预览界面 或 聊天界面的转发
        if ([self saveAndSendForwardMsg]) {
            if ([_fromWhere isEqualToString:RECEIVE_MAP_VIEW_CONTROLLER]) {

                [[NSNotificationCenter defaultCenter] postNotificationName:DISMISS object:self];
                [self dismissModalViewControllerAnimated:YES];
            }
            if (self.isComeFromFileAssistant){
                
                talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                talkSession.talkType = self.forwardConv.conv_type;
                talkSession.titleStr = self.forwardConv.conv_title;
                talkSession.convId = self.forwardConv.conv_id;
                talkSession.needUpdateTag = 1;
                
                talkSession.convEmps = [self.forwardConv getConvEmps];

                //刷新文件助手页面
                [[NSNotificationCenter defaultCenter] postNotificationName:FILE_ASSISTANT_REFRESH object:nil];
                
                // 关闭当前界面
                [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];

                [self dismissModalViewControllerAnimated:YES];
                
                return;

            }
            
            if (self.forwardingDelegate && [self.forwardingDelegate respondsToSelector:@selector(showTransferTips)]) {
                [self.forwardingDelegate showTransferTips];
            }
        }
//        return;
//    }
    
//    //查看聊天信息的转发
//    if (self.isComeFromChatHistory) {
//        //来自会话纪录的转发
//        ChatHistoryView *chatHistoryView = [ChatHistoryView getTalkSession];
//        BOOL saveSuccess = [chatHistoryView saveForwardMsg];
//        
//        if (!saveSuccess)
//        {
//            //        保存失败，直接关闭当前的窗口
//            [self dismissModalViewControllerAnimated:YES];
//        }
//        else
//        {
//            //        如果转发的会话id和原来的会话id相同，那么需要刷新界面
//            //       转发页面不刷新
//            if ([self.forwardConv.conv_id isEqualToString:chatHistoryView.convId])
//            {
//                chatHistoryView.rollToEnd = YES;
//            }
//            
//            chatHistoryView.sendForwardMsgFlag = YES;
//            //        关闭当前界面
//            [self dismissModalViewControllerAnimated:YES];
//        }
//    }
//    else if (self.isComeFromFileAssistant){
//        //文件助手的转发
//        for (ConvRecord *_convRecord in  self.forwardRecordsArray) {
//            _convRecord.conv_id = self.forwardConv.conv_id;
//            _convRecord.conv_type = self.forwardConv.conv_type;
//        }
//        
//        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
//        
//        //保存要转发的消息
//        BOOL saveSuccess = [talkSession saveFileAssistantForwardMsgsArray:self.forwardRecordsArray];
//        
//        if (!saveSuccess){
//            //保存失败，直接关闭当前的窗口
//            [self dismissModalViewControllerAnimated:YES];
//        }
//        else{
//            talkSession.sendFileAssistantForwardMsgFlag = YES;
//            talkSession.talkType = self.forwardConv.conv_type;
//            talkSession.titleStr = self.forwardConv.conv_title;
//            talkSession.convId = self.forwardConv.conv_id;
//            talkSession.needUpdateTag = 1;
//            
//            talkSession.convEmps = [self.forwardConv getConvEmps];
//
//            //刷新文件助手页面
//            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_ASSISTANT_REFRESH object:nil];
//            
//            // 关闭当前界面
//            [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
//            
//            [self dismissModalViewControllerAnimated:YES];
//        }
//    }
}

#pragma mark - 流量提醒
- (void)setAlertViewTitleAndMessage{
    Conversation *conv = self.forwardConv;
    int netType = [ApplicationManager getManager].netType;
    if(netType == type_gprs)
    {
        if (self.isComeFromFileAssistant){
            sendAlert.title = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"group_sure_sendTo"],conv.conv_title];
            sendAlert.message = [NSString stringWithFormat:[StringUtil getLocalizableString:@"forward_gprs_tips"],[[self class]getForwardFilesTotalSize:self.forwardRecordsArray]];
        }
        else if (self.forwardRecord.msg_type == type_file){
            sendAlert.title = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"group_sure_sendTo"],conv.conv_title];
            NSString *fileSize = [StringUtil getDisplayFileSize:[forwardRecord.file_size intValue]];
            sendAlert.message = [NSString stringWithFormat:[StringUtil getLocalizableString:@"forward_gprs_tips"],fileSize];
        }
        else{
            sendAlert.title = [StringUtil getLocalizableString:@"group_sure_sendTo"];
            sendAlert.message = conv.conv_title;
        }
    }
    else{
        sendAlert.title = [StringUtil getLocalizableString:@"group_sure_sendTo"];
        sendAlert.message = conv.conv_title;
    }
}

+ (NSString *)getForwardFilesTotalSize:(NSArray *)forwardRecordsArray{
    NSString *fileSize;
    int _size = 0;
    for (ConvRecord *_convRecord in forwardRecordsArray) {
        if(_convRecord.send_flag == send_upload_nonexistent){
            //失效的文件，不再计算大小
            continue;
        }
        else{
            _size += [_convRecord.file_size intValue];
        }
    }
    if (_size == 0) {
        return nil;
    }
    fileSize = [StringUtil getDisplayFileSize:_size];
    return fileSize;
}

#pragma mark ========转发选择最近会话界面搜索===========

- (void)initSearch
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    _searchBar.delegate = self;
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    [self.view addSubview:_searchBar];
    [_searchBar release];
    
    [UIAdapterUtil setSearchColorForTextBarAndBackground:_searchBar];
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchdispalyCtrl.active = NO;
    searchdispalyCtrl.delegate = self;
    searchdispalyCtrl.searchResultsDelegate=self;
    searchdispalyCtrl.searchResultsDataSource = self;
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:searchdispalyCtrl.searchResultsTableView];
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];
    [UIAdapterUtil setExtraCellLineHidden:searchdispalyCtrl.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
}

#pragma mark - ========UISearchDisplayDelegate协议方法========
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.personTable.scrollsToTop = NO;
    controller.searchResultsTableView.scrollsToTop = YES;
    [UIAdapterUtil customCancelButton:self];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    self.personTable.scrollsToTop = YES;
    controller.searchResultsTableView.scrollsToTop = NO;
    isSearch = NO;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [UserTipsUtil setSearchResultsTitle:@"" andCurrentViewController:self];
}

#pragma mark ========UISearchBarDelegate实现========
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    backgroudButton.hidden=NO;
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //	NSLog(@"%s,searchText is %@",__FUNCTION__,searchText);
    //搜索框的文本有变化，但文本框没有内容时，显示所有内容，当有内容时则显示
    self.searchText = [StringUtil trimString:searchBar.text];;
    if([self.searchText length] == 0)
    {
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)searchConv
{
    dispatch_queue_t queue = dispatch_queue_create("search Conv", NULL);
    
    dispatch_async(queue, ^{
        
        isSearch = YES;
        
        if ([UIAdapterUtil isTAIHEApp]) {
            NSArray *convArray = [_ecloud getConversationBy:self.searchText];
            
            //        看看查到的会话里有多少个单聊，如果已经在查询结果里了，那么就不再以联系人的身份重复出现
            
            //        生成一个字典保存查到的单聊
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            for (Conversation *_conv in convArray) {
                if (_conv.conv_type == singleType) {
                    [mDic setValue:@"1" forKey:_conv.conv_id];
                }
            }
            
            NSMutableArray *tempResult = [NSMutableArray arrayWithArray:convArray];
            
            int _type = [StringUtil getStringType:self.searchText];
            
            if(_type != other_type){
                
                [_ecloud setLimitWhenSearchUser:YES];
                NSArray *empArray = [_ecloud getEmpsByNameOrPinyin:self.searchText andType:_type];
                for (Emp *_emp in empArray) {
                    if (![mDic valueForKey:[StringUtil getStringValue:_emp.emp_id]]) {
                        Conversation *tempConv = [[[Conversation alloc]init]autorelease];
                        tempConv.conv_id = [StringUtil getStringValue:_emp.emp_id];
                        tempConv.conv_type = singleType;
                        tempConv.conv_title = _emp.emp_name;
                        tempConv.emp = _emp;
                        [tempResult addObject:tempConv];
                    }
                }
            }
            
            self.searchResults = [NSMutableArray arrayWithArray:tempResult];

        }else{
            self.searchResults = [NSMutableArray arrayWithArray:[_ecloud getConversationBy:self.searchText]];

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.searchDisplayController.searchResultsTableView reloadData];
            
            if (![self.searchResults count])
            {
                [UserTipsUtil setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"] andCurrentViewController:self];
            }
            
            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
    dispatch_release(queue);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchText length] < [eCloudConfig getConfig].searchTextMinLen.intValue) {
        [UserTipsUtil showSearchTip];
        return;
    }
    
    [searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    
    //搜索提示
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    [[LCLLoadingView currentIndicator] show];
    
    [self searchConv];
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//	//	点击了cancel按钮，那么隐藏cancel按钮，并且显示所有记录
//	[self refreshData];
//	[searchBar setShowsCancelButton:NO animated:YES];
//	[searchBar resignFirstResponder];
//	searchBar.text = @"";
//	backgroudButton.hidden=YES;
//	isSearch	=	NO;
//}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = self.personTable.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - _searchBar.frame.size.height;
    self.personTable.frame = _frame;
    
    [self.personTable reloadData];
    
    backgroudButton.frame = self.personTable.frame;
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
                
//                只处理查询结果的头像刷新 泰和要求搜索时也能够搜索到人员
                if (self.searchDisplayController.active)
                {
                    for (int i = 0; i < self.searchResults.count; i++)
                    {
                        Conversation *_conv = [self.searchResults objectAtIndex:i];
                        if (_conv.conv_type == singleType && _conv.emp.emp_id == empId)
                        {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                            [self.searchDisplayController.searchResultsTableView beginUpdates];
                            [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            [self.searchDisplayController.searchResultsTableView endUpdates];
                            break;
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

#pragma mark =========
- (void)didFinishSelectContacts:(NSArray *)userArray{
    [CreateGroupUtil getUtil].typeTag = type_transfer_msg_create_new_conversation;
    [CreateGroupUtil getUtil].forwardRecordsArray = self.forwardRecordsArray;
    [CreateGroupUtil getUtil].forwardingDelegate = self.forwardingDelegate;
    [CreateGroupUtil getUtil].isComeFromFileAssistant = self.isComeFromFileAssistant;
    
    [[CreateGroupUtil getUtil] forwardRecordsToUsers:userArray];
    
}


#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
- (void)didSelectHXUsers:(NSArray *)usersArray{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
    [CreateGroupUtil getUtil].typeTag = type_transfer_msg_create_new_conversation;
    [CreateGroupUtil getUtil].forwardRecordsArray = self.forwardRecordsArray;
    [CreateGroupUtil getUtil].forwardingDelegate = self.forwardingDelegate;
    [CreateGroupUtil getUtil].isComeFromFileAssistant = self.isComeFromFileAssistant;
    [CreateGroupUtil getUtil].currentVC = self;
    [[CreateGroupUtil getUtil] forwardRecordsToUsers:usersArray];
}
#endif


@end
