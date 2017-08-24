//
//  chatRecordViewController.m
//  eCloud
//
//  Created by shinehey on 15/1/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "chatRecordViewController.h"
#import "ServiceMessage.h"
#import "ServiceModel.h"
#import "PublicServiceDAO.h"

#ifdef _NANHANG_FLAG_
#import "AttentionViewController.h"
#endif

#import "GXViewController.h"

#import "contactViewController.h"

#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "QueryResultCell.h"
#import "talkSessionViewController.h"
#import "broadcastListViewController.h"
#import "LCLLoadingView.h"
#import "chatRecordSearchCell.h"
#import "IMActionButton.h"
#import "ConvNotification.h"

#ifdef _LANGUANG_FLAG_

#import "MiLiaoUtilArc.h"

#endif

@interface chatRecordViewController ()
{
    eCloudDAO *db;
    UITableView *chatRecordTable;
    UILabel *pageLabel;
    UISearchBar * searchBar;
    UISearchDisplayController *searchDisplayController;
    
    IMActionButton *fastpreButton;
    IMActionButton *preButton;
    IMActionButton *nextButton;
    IMActionButton *fastnextButton;
    
    BOOL firstLoad;
    
    int totalCount;
    int totalPage;
    int curPage;
    //删除的时候用来检测 总页数是否变化了
    int totalPageBeforeDelete;
    
    BOOL needRollToTop;
    
    UIView *bottomNavibar;
    
    CGFloat buttonWidth;
}
@property (nonatomic,retain) NSMutableArray *itemArray;
@property (nonatomic,retain) NSMutableArray *searchResults;
@property (nonatomic,retain) NSIndexPath *deleteIndexPath;
@property (nonatomic,retain) NSIndexPath *selectIndexPath;
@end

@implementation chatRecordViewController

-(void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    
    self.itemArray = nil;
    self.searchResults = nil;
    self.deleteIndexPath = nil;
    self.selectIndexPath = nil;
    [searchDisplayController release];
    searchDisplayController = nil;
    [super dealloc];
}

- (void)initSearch
{
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];

    searchBar.delegate = self;
    
    [UIAdapterUtil removeBorderOfSearchBar:searchBar];
    
    [self.view addSubview:searchBar];
    
    [searchBar release];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.delegate = self;
    
    searchDisplayController.searchResultsDelegate=self;
    
    searchDisplayController.searchResultsDataSource = self;
    
    [UIAdapterUtil setExtraCellLineHidden:searchDisplayController.searchResultsTableView];
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:searchDisplayController.searchResultsTableView];
    [UIAdapterUtil setPropertyOfTableView:searchDisplayController.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
}

-(void) initBottomView
{
    int toolbarY = self.view.frame.size.height - 44-44-5;
    if (IOS7_OR_LATER)
    {
        toolbarY = toolbarY - 20;
    }
    CGFloat bottomNaviBarheight = 50;
    toolbarY = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - bottomNaviBarheight;
    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY, self.view.frame.size.width, bottomNaviBarheight)];
    bottomNavibar.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    bottomNavibar.autoresizingMask = UIViewAutoresizingFlexibleWidth;//|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    CGFloat fastpreX = 0;
    CGFloat preButtonX = 60;
    CGFloat buttonY = 10;
    buttonWidth = 40;
    CGFloat buttonHeight = 30;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    fastpreButton=[[IMActionButton alloc]initWithFrame:CGRectMake(fastpreX, buttonY, buttonWidth, buttonHeight)];
    fastpreButton.tag = first_btn_tag;
    [fastpreButton addTarget:self action:@selector(fastpreAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:fastpreButton];
    [fastpreButton release];
    
    preButton=[[IMActionButton alloc]initWithFrame:CGRectMake(preButtonX, buttonY, buttonWidth, buttonHeight)];
    preButton.tag = pre_btn_tag;
    [preButton addTarget:self action:@selector(preAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:preButton];
    [preButton release];
    
    nextButton=[[IMActionButton alloc]initWithFrame:CGRectMake(viewWidth-buttonWidth-preButtonX, buttonY, buttonWidth, buttonHeight)];
    nextButton.tag = next_btn_tag;
    [nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:nextButton];
    [nextButton release];
    
    fastnextButton=[[IMActionButton alloc]initWithFrame:CGRectMake(viewWidth-buttonWidth-fastpreX, buttonY, buttonWidth, buttonHeight)];
    fastnextButton.tag = last_btn_tag;
    [fastnextButton addTarget:self action:@selector(fastnextAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:fastnextButton];
    [fastnextButton release];
    
    pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,viewWidth-preButtonX-buttonWidth-(viewWidth - nextButton.frame.origin.x), bottomNaviBarheight)];
    pageLabel.center = CGPointMake(viewWidth*0.5,bottomNaviBarheight*0.5);
    pageLabel.backgroundColor = [UIColor clearColor];// [UIColor redColor];
    [pageLabel setFont:[UIFont systemFontOfSize:17]];
    pageLabel.textAlignment = UITextAlignmentCenter;
    pageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [bottomNavibar addSubview: pageLabel];
    [pageLabel release];
    
    [GXViewController displaySubViewOfView:bottomNavibar andLevel:0];
}

-(void)loadData
{
    totalPage = [self getNowPageCount];
    
    if(totalCount != 0)
    {
        if (firstLoad) {
            curPage = totalPage;
            firstLoad = NO;

        }else {
            // 删除会话记录导致 总页数发生变化
            if (totalPageBeforeDelete > totalPage) {
                if(curPage > totalPage)
                {
                    curPage = totalPage;
                }
                else if(curPage>1 && curPage < totalPage)
                {
                    //如果是中间页 总页数减少的时候 当前页数需要－1
                    curPage--;
                }
            }
        }
#ifdef _LANGUANG_FLAG_
        
        self.itemArray = [self filterMILIAOMsg];
#else
        self.itemArray = [db getConvsOfPage:curPage andAllPageNum:totalPage];
#endif
   
        [chatRecordTable reloadData];
        [self setPageLabelText];
        [self setButtonEnable];
    }else
    {
        curPage = 0;
        totalPage = 0;
        [self setPageLabelText];
        [self setButtonEnable];
        self.itemArray = [NSMutableArray array];
        [chatRecordTable reloadData];
    }
}

-(int)getNowPageCount
{
    totalCount = [db getAllConvCount];
    int tempCount = 0;
    if (totalCount % perpage_conv != 0) {
        tempCount = totalCount / perpage_conv +1;
    }else {
        tempCount = totalCount / perpage_conv;
    }
    return tempCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.itemArray = [NSMutableArray array];
    
    db = [eCloudDAO getDatabase];
    
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    self.title = [StringUtil getLocalizableString:@"conv_records"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPress:)];
    
    [self initSearch];
    
    [self initBottomView];
    
    int tableH = self.view.frame.size.height - 20 - 44 - 44 - 40-8;
//    if(iPhone5)
//        tableH = tableH + i5_h_diff;
    
    chatRecordTable = [[UITableView alloc] initWithFrame:CGRectMake(0, searchBar.frame.size.height, CGRectGetWidth(self.view.frame), tableH) style:UITableViewStylePlain];
    
    [UIAdapterUtil setPropertyOfTableView:chatRecordTable];
    
    chatRecordTable.delegate = self;
    chatRecordTable.dataSource = self;
    chatRecordTable.showsHorizontalScrollIndicator = NO;
    chatRecordTable.showsVerticalScrollIndicator = NO;
    chatRecordTable.backgroundView = nil;
    chatRecordTable.backgroundColor=[UIColor clearColor];
    [UIAdapterUtil setExtraCellLineHidden:chatRecordTable];
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:chatRecordTable];
    
    chatRecordTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;//|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:chatRecordTable];
    [chatRecordTable release];
    
    firstLoad = YES;
    needRollToTop = YES;
    
    [self loadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.selectIndexPath)
    {
#ifdef _LANGUANG_FLAG_
        
        self.itemArray = [self filterMILIAOMsg];
#else
        self.itemArray = [db getConvsOfPage:curPage andAllPageNum:totalPage];
#endif
        
        [chatRecordTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        self.selectIndexPath = nil;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [chatRecordTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    return [self.itemArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return conv_row_height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    chatRecordSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[[chatRecordSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        [cell initSubView];
    }
    cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
    
    Conversation *conv;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        conv = [self.searchResults objectAtIndex:indexPath.row];
        conv.displayTime = YES;
        conv.displayRcvMsgFlag = YES;
        conv.specialStr = searchBar.text;
        
        [cell configCell:conv andSearchStr:searchBar.text];
    }else
    {
        conv = [self.itemArray objectAtIndex:indexPath.row];
        conv.displayTime = YES;
        conv.displayRcvMsgFlag = YES;
        [cell configCell:conv];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation *conv;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        conv = (Conversation *)[self.searchResults objectAtIndex:indexPath.row];
    }else
    {
        conv = (Conversation *)[self.itemArray objectAtIndex:indexPath.row];
    }
    //点击的会话未读计数大于0 记录后刷新
    if(conv.unread >0){
        self.selectIndexPath = indexPath;
    }

    [contactViewController openConversation:conv andVC:self];
    
//    [self openConversation:conv];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.searchDisplayController.searchResultsTableView ) {
        return YES;
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.deleteIndexPath = nil;
        self.deleteIndexPath = indexPath;
        Conversation *conv = (Conversation *)[self.itemArray objectAtIndex:indexPath.row];
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:conv.conv_title message:[StringUtil getLocalizableString:@"usual_chat_records_delete"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        [alter show];
        [alter release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //获取删除前的pageCount
        totalPageBeforeDelete = [self getNowPageCount];

        Conversation *conv = (Conversation *)[self.itemArray objectAtIndex:self.deleteIndexPath.row];
        
        //如果删除有未读计数的会话 则tabbar的总计数需要刷新
        BOOL unReadCountRefresh = NO;
        if (conv.unread > 0) {
            unReadCountRefresh = YES;
        }
        //如果是固定组 只删除消息记录
        if (conv.groupType == system_group_type) {
            [db deleteConvRecordBy:conv.conv_id];
        }else if(conv.conv_type == broadcastConvType){
             //先看有没有未读的广播 再删除广播消息
            if([db getAllNoReadBroadcastNum:normal_broadcast]>0)
            {
                [db setAllBroadcastToRead:normal_broadcast];
                
                NSNumber *unReadCount = [NSNumber numberWithInt:0];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv.conv_id,@"conv_id",unReadCount,@"unread_msg_count",nil];
                [db sendNewConvNotification:dic andCmdType:update_broadcast_read_flag];
            }
            [db deleteAllBroadcast:normal_broadcast];
            [db deleteConvOnly:conv.conv_id];

        }else if(conv.conv_type == imNoticeBroadcastConvType){
            //先看有没有未读的广播 再删除广播消息
            if([db getAllNoReadBroadcastNum:imNotice_broadcast]>0)
            {
                [db setAllBroadcastToRead:imNotice_broadcast];
                
                NSNumber *unReadCount = [NSNumber numberWithInt:0];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv.conv_id,@"conv_id",unReadCount,@"unread_msg_count",nil];
                [db sendNewConvNotification:dic andCmdType:update_broadcast_read_flag];
            }
            [db deleteAllBroadcast:imNotice_broadcast];
            
            [db deleteConvOnly:conv.conv_id];
        }else if(conv.conv_type == appNoticeBroadcastConvType){
            //先看有没有未读的广播 再删除广播消息
            if([db getAllNoReadBroadcastNum:appNotice_broadcast]>0)
            {
                [db setAllBroadcastToRead:appNotice_broadcast];
                
                NSNumber *unReadCount = [NSNumber numberWithInt:0];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv.conv_id,@"conv_id",unReadCount,@"unread_msg_count",nil];
                [db sendNewConvNotification:dic andCmdType:update_broadcast_read_flag];
            }
            [db deleteAllBroadcast:appNotice_broadcast];
            
            [db deleteConvOnly:conv.conv_id];
        }
        else {
            if (conv.conv_type == singleType || conv.conv_type == mutiableType) {
                [db deleteConvAndConvRecordsBy:conv.conv_id];
            }else{
                if (conv.conv_type == serviceConvType) {
                    int serviceId = [conv.conv_id intValue];
                    [[PublicServiceDAO getDatabase]removeAllRecordsOfService:serviceId];
//                    删除公众号 所有 收发 的 消息
                    [db deleteConvOnly:conv.conv_id];
                }else if (conv.conv_type == serviceNotInConvType){
                    
                    NSLog(@"%s 服务号类型",__FUNCTION__);
                    
                    NSArray *allService = [[PublicServiceDAO getDatabase] getAllService:service_type_in_ps];
                    
                    int serviceId;
                    for(ServiceModel *_service in allService)
                    {
                        serviceId = _service.serviceId;
                        
                        [[PublicServiceDAO getDatabase]removeAllRecordsOfService:serviceId];
                    }
                    //                    删除公众号 所有 收发 的 消息
                    [db deleteConvOnly:conv.conv_id];
                }else{
                    NSLog(@"%s 还未来得及处理",__FUNCTION__);
                    
                    return;
                }
            }
        }
        
        if (unReadCountRefresh) {
            contactViewController *contactView = [UIAdapterUtil getContactViewController:self];
            [contactView showNoReadNum];
        }
        //删除了的都先移除 只是删除了记录没有删除会话本身的也先移除
//        [self.itemArray removeObjectAtIndex:self.deleteIndexPath.row];
        
        //删除数据之后 从新计算总数 如果有上一页的话 上一页的第一条数据会补到删除页的最后一条 不会出现删除后翻页漏看的情况
        //删除之后更新下面的页数和当前页
        needRollToTop = NO;

        [self loadData];
    }
}

-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [StringUtil getLocalizableString:@"delete"];
}

//打开会话
- (void)openConversation:(Conversation *)conv
{
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    if (conv.recordType == normal_conv_type)
    {
        if(conv.conv_type==singleType)
        {
            talkSession.talkType = singleType;
            talkSession.titleStr = [conv.emp getEmpName];
            talkSession.convId =conv.conv_id;
            talkSession.convEmps = [NSArray arrayWithObject:conv.emp];
            //         talkSession.delegete=self;
            talkSession.needUpdateTag=1;
            talkSession.fromType = talksession_from_chatRecordView;
            [self.navigationController pushViewController:talkSession animated:YES];
        }
        else if (conv.conv_type == mutiableType)
        {
            talkSession.talkType = mutiableType;
            talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
            talkSession.convId = conv.conv_id;
            talkSession.needUpdateTag=1;
            talkSession.convEmps =[db getAllConvEmpBy:conv.conv_id];
            talkSession.last_msg_id=conv.last_msg_id;
            talkSession.fromType = talksession_from_chatRecordView;
            [self.navigationController pushViewController:talkSession animated:YES];
        }
        else if(conv.conv_type == broadcastConvType){
            //广播消息消息
            broadcastListViewController *broadcastList=[[broadcastListViewController alloc]init];
            //广播在会话表里的id
            broadcastList.convId = conv.conv_id;
            broadcastList.broadcastType = normal_broadcast;
            [self.navigationController pushViewController:broadcastList animated:YES];
            [broadcastList release];
        }
        else if(conv.conv_type == imNoticeBroadcastConvType){
            //广播消息消息
            broadcastListViewController *broadcastList=[[broadcastListViewController alloc]init];
            //广播在会话表里的id
            broadcastList.convId = conv.conv_id;
            broadcastList.broadcastType = imNotice_broadcast;
            [self.navigationController pushViewController:broadcastList animated:YES];
            [broadcastList release];
        }
        else if(conv.conv_type == appNoticeBroadcastConvType){
//            打开的是南航做的界面
#ifdef _NANHANG_FLAG_            
            AttentionViewController *vc = [[[AttentionViewController alloc]init]autorelease];
            [self.navigationController pushViewController:vc animated:YES];
#endif
        }

    }
}

-(void)reloadData
{
#ifdef _LANGUANG_FLAG_
    
    self.itemArray = [self filterMILIAOMsg];
#else
    self.itemArray = [db getConvsOfPage:curPage andAllPageNum:totalPage];
#endif
    [chatRecordTable reloadData];
    
    if(self.itemArray.count > 0 && needRollToTop == YES){
        [chatRecordTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }else
    {
        needRollToTop = YES;
    }
}

-(void) fastpreAction:(id) sender
{
    curPage = 1;
    [self reloadData];
    [self setPageLabelText];
    
    fastpreButton.enabled = NO;
    preButton.enabled = NO;
    nextButton.enabled = YES;
    fastnextButton.enabled = YES;
}

-(void) preAction:(id) sender
{
    curPage--;
    [self reloadData];
    
    [self setPageLabelText];
    [self setButtonEnable];
}
-(void) nextAction:(id) sender
{
    curPage++;
    [self reloadData];
    
    [self setPageLabelText];
    [self setButtonEnable];
}
-(void) fastnextAction:(id) sender
{
    curPage = totalPage;
    [self reloadData];
    
    [self setPageLabelText];
    fastpreButton.enabled = YES;
    preButton.enabled = YES;
    nextButton.enabled = NO;
    fastnextButton.enabled = NO;
}

-(void)backButtonPress:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setPageLabelText
{
    pageLabel.text = [NSString stringWithFormat:@"%d/%d",curPage,totalPage];
}

-(void)setButtonEnable
{
    if(curPage>1 && curPage<totalPage){
        fastpreButton.enabled = YES;
        preButton.enabled = YES;
        nextButton.enabled = YES;
        fastnextButton.enabled = YES;
    }else if (curPage == 1 && curPage<totalPage)
    {
        fastpreButton.enabled = NO;
        preButton.enabled = NO;
        nextButton.enabled = YES;
        fastnextButton.enabled = YES;
    }else if (curPage>1 && curPage == totalPage)
    {
        fastpreButton.enabled = YES;
        preButton.enabled = YES;
        nextButton.enabled = NO;
        fastnextButton.enabled = NO;
    }else if (curPage == 1 && curPage == totalPage)
    {
        fastpreButton.enabled = NO;
        preButton.enabled = NO;
        nextButton.enabled = NO;
        fastnextButton.enabled = NO;
    }else if (totalCount == 0){
        //没有任何记录的时候
        fastpreButton.enabled = NO;
        preButton.enabled = NO;
        nextButton.enabled = NO;
        fastnextButton.enabled = NO;
    }
}

#pragma mark =======UISearchDisplayDelegate协议方法========

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
    return YES;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [UIAdapterUtil customCancelButton:self];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [self setSearchResultsTitle:@""];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //        self.searchStr = [StringUtil trimString:searchBar.text];
    if([searchBar.text length] == 0)
    {
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
        
    }
    else
    {
        
    }
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    //搜索提示
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    [[LCLLoadingView currentIndicator] show];
    
    [self searchChatRecords];
}

-(void)searchChatRecords
{
    dispatch_queue_t queue = dispatch_queue_create("search chatRecords", NULL);
    
    dispatch_async(queue, ^{
        
        NSString *_searchStr = [NSString stringWithFormat:@"%@",searchBar.text];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        self.searchResults = [db searchChatRecordByConvName:_searchStr];
        [pool release];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
            if (![self.searchResults count]) {
                [self setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"]];
            }
            
            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
    dispatch_release(queue);
}

#pragma mark - 搜索提示
- (void)setSearchResultsTitle:(NSString *)title{
    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:title];
        }
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = CGRectZero;
    
    _frame = bottomNavibar.frame;
    
    float bottomBarY = (SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT) - bottomNavibar.frame.size.height;
    
    if (bottomBarY == _frame.origin.y) {
        NSLog(@"不需要重新布局");
        return;
    }
    _frame.origin.y = bottomBarY;
    bottomNavibar.frame = _frame;
    
    _frame = fastnextButton.frame;
    _frame.origin.x = SCREEN_WIDTH - buttonWidth;
    fastnextButton.frame = _frame;
    
    _frame = nextButton.frame;
    _frame.origin.x = fastnextButton.frame.origin.x - buttonWidth - 20;
    nextButton.frame = _frame;

    _frame = chatRecordTable.frame;
    _frame.size.height = bottomBarY - searchBar.frame.size.height;
    chatRecordTable.frame = _frame;
    
    [chatRecordTable reloadData];
    
    if (self.searchDisplayController.isActive) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (NSMutableArray *)filterMILIAOMsg{

    NSArray *arr = [db getConvsOfPage:curPage andAllPageNum:totalPage];
    
    for (Conversation *conv in arr) {
#ifdef _LANGUANG_FLAG_
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:conv.conv_id]) {
           
            continue;
        }
#endif 
        [self.itemArray addObject:conv];
    }

    
    return self.itemArray;

}
@end
