//
//  APPPushDetailViewController.m
//  eCloud
//
//  Created by Pain on 14-6-24.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPPushDetailViewController.h"
#import "APPListDetailViewController.h"
#import "Conversation.h"
#import "APPPushNotification.h"
#import "APPBackButtonUtil.h"
#import "APPPlatformDOA.h"
#import "APPPushListTableViewCell.h"
#import "DateCell.h"
#import "ConvRecord.h"
#import "UIAdapterUtil.h"
#import "eCloudDAO.h"
#import "NewMsgNotice.h"
#import "eCloudDefine.h"

@interface APPPushDetailViewController (){
    
}
@property (nonatomic,retain) NSIndexPath *editIndexPath;
@end

@implementation APPPushDetailViewController
{
    APPPlatformDOA *db;
    //	加载历史记录时用到的indicatorView
	UIActivityIndicatorView *loadingIndic;
	BOOL isLoading;
	//	会话的总记录个数
	int totalCount;
	//	已经加载的记录个数
	int loadCount;
	//	查询会话时用到的参数
	int limit;
	int offset;
    
//    需要刷新
    BOOL needRefresh;
}
@synthesize appPushArr;
@synthesize editIndexPath;

- (id)initWithConversation:(Conversation *)_conv;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        conv = [_conv retain];
    }
    return self;
}

-(void)dealloc
{
//    self.tableView = nil;
    [conv release];
    conv = nil;
	self.appPushArr = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    needRefresh = YES;
    
	db = [APPPlatformDOA getDatabase];
    
	UIImage *backImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ChatBackground" ofType:@"jpg"]];
	UIImageView *backView = [[UIImageView alloc]initWithImage:backImage];
	self.tableView.backgroundView = backView;
	[backView release];
    
    //适配ios7UIViewController的变化
    [UIAdapterUtil processController:self];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setExtraCellLineHidden:self.tableView];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1.0]];
	self.title = conv.conv_title;
	[self setLeftBtn];
    
    [self initIndicator];
    
    //在tableview上增加长按显示菜单功能
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(myHandleTableviewCellLongPressed:)];
    longPress.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPress];
    [longPress release];
    
    //监听消息变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [view release];
}

#pragma mark 初始化indicator view
- (void)initIndicator
{
    CGRect rect = CGRectMake(145,5, 30.0f,30.0f);
	loadingIndic = [[UIActivityIndicatorView alloc]initWithFrame:rect];
	loadingIndic.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	loadingIndic.hidden = YES;
	isLoading = NO;
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    int allUnReadCount = [[eCloudDAO getDatabase] getAllNumNotReadedMessge];
    int curUnReadCount = [db getAllNewPushNotiCountWithAppid:conv.conv_id];
    
    NSString *backBtnTitle = nil;
    if (allUnReadCount > curUnReadCount) {
        int unReadCount = allUnReadCount - curUnReadCount;
        backBtnTitle = [NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"back"],unReadCount];
    }
    
    [UIAdapterUtil setLeftButtonItemWithTitle:backBtnTitle andTarget:self andSelector:@selector(backButtonPressed:)];
}

-(void)backButtonPressed:(id)sender
{
    //将该应用的所有未读信息置为已读
    [[APPPlatformDOA getDatabase] updateReadFlagOfAPPNoti:conv.conv_id];
    
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
        
    
	[self getAppNotiList];
}

//查询所有服务号
-(void)getAppNotiList
{
    if (!needRefresh)
    {
        return;
    }
    NSLog(@"conv.conv_id----------%@",conv.conv_id);
    totalCount = [db getMsgCountByAppId:conv.conv_id];
    if(totalCount > num_convrecord)
	{
		limit = num_convrecord;
		offset = totalCount - num_convrecord;
	}
	else {
		limit = totalCount;
		offset = 0;
	}
    
    self.appPushArr = [db getAPPPushNotificationWithAppid:conv.conv_id andLimit:limit andOffset:offset];
    
    for (int i = 0; i < self.appPushArr.count; i++) {
        APPPushNotification *appPush = [self.appPushArr objectAtIndex:i];
        [self setTimeDisplay:appPush andIndex:i];
    }
    
//    NSLog(@"self.appPushArr.count----------%i",[self.appPushArr count]);
    
    [self.tableView reloadData];
    
    [self scrollToEnd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 监听消息变化
- (void)handleCmd:(NSNotification *)notification{
    eCloudNotification	*cmd =	(eCloudNotification *)[notification object];
	switch (cmd.cmdId)
	{
		case rev_msg:
		{
			NewMsgNotice *_notice = notification.userInfo;
			if(_notice.msgType == app_new_msg_type){
                if ([_notice.appid isEqualToString:conv.conv_id] ) {
                    //刷新当前消息列表
                    [self getAppNotiList];
                }
            }
        }
            break;
    }
    
    [self setLeftBtn];

}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 40;
    }
    return row_height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int _index = section - 1;
    if (_index < self.appPushArr.count)
    {
            APPPushNotification *appPush = (APPPushNotification *)[self.appPushArr objectAtIndex:_index];
        if (appPush.needDisplayTime)
        {
            return 30;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section == 0) return nil;
    int _index = section - 1;
    if (_index < self.appPushArr.count)
    {
        APPPushNotification *appPush = (APPPushNotification *)[self.appPushArr objectAtIndex:_index];
        if (appPush.needDisplayTime)
        {
            DateCell *dateCell = [[[DateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
            ConvRecord *_convRecord = [[ConvRecord alloc]init];
            _convRecord.isTimeDisplay = YES;
            _convRecord.msgTimeDisplay = [StringUtil getDisplayTime_day:[StringUtil getStringValue:appPush.notitime]];
            [dateCell configureCell:_convRecord];
            [_convRecord release];
            return dateCell.contentView;
        }
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.appPushArr.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(void)tableView:(UITableView*)tableView  willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundView = nil;
    cell.selectedBackgroundView = nil;
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
	{
		UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
		[cell.contentView addSubview:loadingIndic];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
    
    int _index = indexPath.section - 1;
    if (_index < self.appPushArr.count)
    {
        static NSString *CellIdentifier = @"Cell";
        
        APPPushListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[[APPPushListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        
        APPPushNotification *appPush = (APPPushNotification *)[self.appPushArr objectAtIndex:_index];
        [cell configureCellWith:appPush];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        return;
    }
    
    needRefresh = YES;
    
    int _index = indexPath.section - 1;
    if (_index < self.appPushArr.count)
    {
        APPPushNotification *appPush = (APPPushNotification *)[self.appPushArr objectAtIndex:_index];
        //设置为已读
        [db updateReadFlagOfAPPPushNotification:appPush];
        
        NSString *pushurl = [NSString stringWithFormat:@"%@",appPush.pushurl];
        NSLog(@"url_str------%@",pushurl);
        
        if ([pushurl length]) {
            APPListDetailViewController *ctr = [[APPListDetailViewController alloc] initWithAppID:conv.conv_id];
            ctr.customTitle = conv.conv_title;
            ctr.urlstr=pushurl;
            [self.navigationController pushViewController:ctr animated:YES];
            [ctr release];
        }
    }
}

#pragma mark 下拉加载历史记录
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//顶部下拉
	//offset为0，表示已经没有历史记录，那么不处理;
    //		NSLog(@"%s,offset is %d",__FUNCTION__,offset);
	if(offset == 0) {
		return;
	}
    //		NSLog(@"%.0f",scrollView.contentOffset.y);
	if (scrollView.contentOffset.y<0 && !isLoading ) {
		isLoading = true;
		loadingIndic.hidden = NO;
		[loadingIndic startAnimating];
		[self performSelector:@selector(getHistoryRecord) withObject:nil afterDelay:0.5];
	}
}

#pragma mark 获取历史记录，加载历史记录
- (void)getHistoryRecord
{
	//	总数量
	totalCount = [db getMsgCountByAppId:conv.conv_id];
	//已经加载数量
	loadCount = self.appPushArr.count;
	
	if(totalCount > (loadCount + num_convrecord))
	{
		limit = num_convrecord;
		offset = totalCount - (loadCount + num_convrecord);
	}
	else
	{
		limit =totalCount - loadCount;
		offset = 0;
	}

	@autoreleasepool
	{
        NSArray *historyList = [db getAPPPushNotificationWithAppid:conv.conv_id andLimit:limit andOffset:offset];
		int count=[historyList count];
		
		//	把历史消息记录添加到现有的数据列表里
		for (int i=count-1; i>=0; i--)
		{
			APPPushNotification *appPush =[historyList objectAtIndex:i];
			[self.appPushArr insertObject:appPush atIndex:0];
		}
		
		//	设置时间是否显示，设置一些属性，例如消息对应的图片是否存在
		for(int i = 0;i<historyList.count;i++)
		{
            APPPushNotification *appPush = [historyList objectAtIndex:i];
            [self setTimeDisplay:appPush andIndex:i];
		}
	}
	
	
    float oldh=self.tableView.contentSize.height;
	[self.tableView reloadData];
	
	[self hideLoadingCell];
	
    float newh=self.tableView.contentSize.height;
	self.tableView.contentOffset=CGPointMake(0, newh-oldh-20);
}

-(void)hideLoadingCell
{
	loadingIndic.hidden = YES;
	[loadingIndic stopAnimating];
	isLoading = false;
}

#pragma mark 滑动到最底部
-(void)scrollToEnd
{
	int section = self.appPushArr.count;
	int row = 0;
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                          atScrollPosition: UITableViewScrollPositionBottom
                                  animated:NO];
}

#pragma mark 确定本条记录是否显示时间
-(void)setTimeDisplay:(APPPushNotification *)appPush  andIndex:(int)_index
{
	if(_index == 0)
	{
		appPush.needDisplayTime = true;
		return;
	}
	
	bool isDisplay = true;
	
	int lastDisplayMsgIndex = [self getLastDisplayTimeMsg:_index];
	
	if(lastDisplayMsgIndex < 0)
	{
		appPush.needDisplayTime = true;
		return;
	}
	
	APPPushNotification *tempAppPush = [self.appPushArr objectAtIndex:lastDisplayMsgIndex];
	//			如果当前的时间和第一条的时间在3分钟之内，那么就不用显示,有两种情况，一个是小于msg_time_sec,一个是小于0，防止下面消息的显示时间比上面消息的显示时间早的情况 fabs(
	NSTimeInterval _diff = appPush.notitime - tempAppPush.notitime;
	if(_diff < 0 || (_diff >= 0 && _diff <= msg_time_sec))
	{
		isDisplay = false;
	}
	appPush.needDisplayTime = isDisplay;
}

#pragma mark 找到最近的一条显示时间的消息，从_index开始向前找
-(int)getLastDisplayTimeMsg:(int)_index
{
	for(int i= _index;i>=0;i--)
	{
		APPPushNotification *appPush = [self.appPushArr objectAtIndex:i];
		if(appPush.needDisplayTime)
			return i;
	}
	return -1;
}

#pragma mark =======删除单条记录功能=========
- (void) myHandleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
 	if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
	{
		CGPoint p = [gestureRecognizer locationInView:self.tableView];
		[self prepareToShowCopyMenu:p];
    }
}

-(void)prepareToShowCopyMenu:(CGPoint)p
{
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    NSString *pointY=[NSString stringWithFormat:@"%0.0f",p.y];
	if(indexPath)
	{
        if(indexPath.section == 0)
            return;
        self.editIndexPath = indexPath;
     
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[cell becomeFirstResponder];
		[self performSelector:@selector(showCopyMenu:)withObject:[NSDictionary dictionaryWithObjectsAndKeys:cell,@"LONG_CLICK_CELL",pointY,@"pointY", nil] afterDelay:0.05f];
	}
}

#pragma mark  长按或双击可以复制消息文本功能
- (void)showCopyMenu:(id)dic
{
 	UITableViewCell *longClickCell =  (UITableViewCell*)[(NSDictionary *)dic objectForKey:@"LONG_CLICK_CELL"];
    
    float menuX = 160;
    
    NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
    int menuY=[pointY intValue]-longClickCell.frame.origin.y;
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect: CGRectMake(menuX , menuY, 1, 1) inView: longClickCell];
    [menu setMenuVisible: YES animated: YES];
}

#pragma mark 只提供复制功能
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;

    if(action == @selector(delete:))
	{
        retValue = YES;
    }
    else
    {
        retValue = [super canPerformAction:action withSender:sender];
    }
    
    return retValue;
}


-(void)delete:(id)sender
{
    if (self.editIndexPath.section > 0 && self.editIndexPath.section <= self.appPushArr.count )
    {
        NSLog(@"delete");
        APPPushNotification *item = [self.appPushArr objectAtIndex:self.editIndexPath.section - 1];
        [db deleteAPPPushNotification:item];
        [self.appPushArr removeObjectAtIndex:(self.editIndexPath.section - 1)];
        [self.tableView reloadData];
    }
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
