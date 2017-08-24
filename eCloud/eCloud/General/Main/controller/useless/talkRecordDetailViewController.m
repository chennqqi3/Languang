#import "talkRecordDetailViewController.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "eCloudDAO.h"
#import "talkSessionUtil.h"

#import "ImageUtil.h"
#import "openWebViewController.h"
#import "conn.h"
#import "timeZoneObject.h"
#import "ChatCustomCell.h"
#import "messageView.h"
#import "Conversation.h"
#import "ConvRecord.h"
#import "eCloudUser.h"
#import "UserInfo.h"

//1、为单例对象实现一个静态实例，并初始化，然后设置成nil，
static talkRecordDetailViewController *sharedObj;
@implementation talkRecordDetailViewController
{
	eCloudDAO *db;
	UIButton *sessionButton;
}

@synthesize curRecordPath;
@synthesize isAudioPause;
@synthesize conv;
@synthesize convId = _convId;
@synthesize convName = _convName;
@synthesize itemArray;
@synthesize convType = _convType;
@synthesize isVirGroup;

@synthesize editMsgId;
@synthesize editRecord;
@synthesize editRow;
@synthesize isDeleteAction;
@synthesize preImageFullPath;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)init
{
	return sharedObj;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return sharedObj;
}


//3、重写allocWithZone方法，用来保证其他人直接使用alloc和init试图获得一个新实力的时候不产生一个新实例，
+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized (self)
	{
        if (sharedObj == nil)
		{
            sharedObj = [super allocWithZone:zone];
            return sharedObj;
        }
		return sharedObj;
    }
	//    return nil;
}
//4、适当实现allocWitheZone，copyWithZone，release和autorelease。
- (id) copyWithZone:(NSZone *)zone //第四步
{
    return self;
}

- (id) retain
{
    return self;
}

- (unsigned) retainCount
{
    return UINT_MAX;
}

- (oneway void) release
{
}

- (id) autorelease
{
    return self;
}

-(void)dealloc
{
	self.curRecordPath = nil;
	self.conv = nil;
	self.editMsgId = nil;
	self.editRecord = nil;
	self.convId = nil;
	self.convName = nil;
	self.itemArray = nil;
	[super dealloc];
	NSLog(@"%s",__FUNCTION__);
}
- (void)viewDidLoad
{
	NSLog(@"%s",__FUNCTION__);

    [super viewDidLoad];
    //add amr to wav
    amrtowav=[[amrToWavMothod alloc]init];
	audioplayios6=[[AudioPlayForIOS6 alloc]init];
	
	isWifi=[self IsEnableWIFI];
    _conn = [conn getConn];
	db = [eCloudDAO getDatabase];
    
//	self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    //适配ios7UIViewController的变化
    if ([self respondsToSelector:@selector(extendedLayoutIncludesOpaqueBars)]) {
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    }
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 7.5, 50, 30);
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_botton.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateHighlighted];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateSelected];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem*leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem= leftItem;
    [leftItem release];
    
    //	会话按钮
	sessionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sessionButton.frame = CGRectMake(320-50-5, 7.5, 50,30);
    [sessionButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [sessionButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [sessionButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [sessionButton setTitle:@"会话" forState:UIControlStateNormal];
    sessionButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [sessionButton addTarget:self action:@selector(sendTalk:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:sessionButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    [rightItem release];
	
	
	int tableH = self.view.frame.size.height  - 60;
    talkTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
	 
    [talkTable setDelegate:self];
    [talkTable setDataSource:self];
    talkTable.backgroundView=[[[UIImageView alloc]initWithImage:[StringUtil getImageByResName:@"ChatBackground_1.jpg"]]autorelease];
    talkTable.separatorStyle=UITableViewCellSeparatorStyleNone;

	//创建长按手势 复制
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(myHandleTableviewCellLongPressed:)];
    
    longPress.minimumPressDuration = 0.5;
    //将长按手势添加到需要实现长按操作的视图里
    [talkTable addGestureRecognizer:longPress];
	
    [longPress release];
	
	//	为表格增加双击的手势
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapTableViewListener:)];
	doubleTap.numberOfTapsRequired = 2;
	[talkTable addGestureRecognizer:doubleTap];
	[doubleTap release];
	
    [self.view addSubview:talkTable];
    
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, tableH-44, 320, 60)];
    footerView.backgroundColor=[UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1];
    [self.view addSubview:footerView];
    UIButton *fastpreButton=[[UIButton alloc]initWithFrame:CGRectMake(20, 5, 40, 40)];
    [fastpreButton setImage:[StringUtil getImageByResName:@"fastpre.png"] forState:UIControlStateNormal];
    [fastpreButton addTarget:self action:@selector(fastpreAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:fastpreButton];
    
    UIButton *preButton=[[UIButton alloc]initWithFrame:CGRectMake(80, 5, 40, 40)];
    [preButton setImage:[StringUtil getImageByResName:@"pre.png"] forState:UIControlStateNormal];
    [preButton addTarget:self action:@selector(preAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:preButton];
    
    UIButton *nextButton=[[UIButton alloc]initWithFrame:CGRectMake(140, 5, 40, 40)];
    [nextButton setImage:[StringUtil getImageByResName:@"next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:nextButton];
    
    
    UIButton *fastnextButton=[[UIButton alloc]initWithFrame:CGRectMake(200, 5, 40, 40)];
    [fastnextButton setImage:[StringUtil getImageByResName:@"fastnext.png"] forState:UIControlStateNormal];
    [fastnextButton addTarget:self action:@selector(fastnextAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:fastnextButton];
    
    UIButton *deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(260, 5, 40, 40)];
    [deleteButton setImage:[StringUtil getImageByResName:@"delete.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:deleteButton];
	[footerView release];
	
	float sendX = 20;
	float sendY = 8;
	float sendWidth = 12.5;
	float sendHeight = 18.5;
	sendVoicePlayView = [[UIImageView alloc]initWithFrame:CGRectMake(sendX, sendY, sendWidth, sendHeight)];
	sendVoicePlayView.image = [StringUtil getImageByResName:@"voice_send_default.png"];
	sendVoicePlayView.animationImages = [NSArray arrayWithObjects:[StringUtil getImageByResName:@"voice_send_play_1.png"],[StringUtil getImageByResName:@"voice_send_play_2.png"],[StringUtil getImageByResName:@"voice_send_play_3.png"],[StringUtil getImageByResName:@"voice_send_default.png"], nil];
	sendVoicePlayView.animationDuration = 1;
	sendVoicePlayView.animationRepeatCount = 0;
	
	
	float rcvX = 20;
	float rcvY = 8;
	float rcvWidth = 12.5;
	float rcvHeight = 18.5;
	rcvVoicePlayView = [[UIImageView alloc]initWithFrame:CGRectMake(rcvX, rcvY, rcvWidth, rcvHeight)];
	rcvVoicePlayView.image = [StringUtil getImageByResName:@"voice_rcv_default.png"];
	rcvVoicePlayView.animationImages = [NSArray arrayWithObjects:[StringUtil getImageByResName:@"voice_rcv_play_1.png"],[StringUtil getImageByResName:@"voice_rcv_play_2.png"],[StringUtil getImageByResName:@"voice_rcv_play_3.png"],[StringUtil getImageByResName:@"voice_rcv_default.png"], nil];
	rcvVoicePlayView.animationDuration = 1;
	rcvVoicePlayView.animationRepeatCount = 0;

}

-(void)openWebUrl:(NSNotification *)notification
{
    NSLog(@"---urlstr-- %@",notification.object);
    openWebViewController *openweb=[[openWebViewController alloc]init];
    openweb.urlstr=notification.object;
    openweb.fromtype=1;
    [self.navigationController pushViewController:openweb animated:YES];
    [openweb release];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:OPEN_WEB_NOTIFICATION object:nil];

	//	监听系统菜单显示，隐藏
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
	//	监听系统菜单显示，隐藏
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuDisplay) name:UIMenuControllerWillShowMenuNotification object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuHide) name:UIMenuControllerWillHideMenuNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
    //打开网页
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openWebUrl:) name:OPEN_WEB_NOTIFICATION object:nil];

    if (watchPreImageTag==1) {
        watchPreImageTag=0;
        return;
    }
	
    uinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];
    [db updateConvInfoToIsReaded:self.convId sendReadLimt:uinfo.sendreadFlag];
    
	totalCount = [db getConvRecordCountBy:self.convId];
	if((totalCount % perpage_conv_detail) == 0)
	{
		totalPage = totalCount/perpage_conv_detail;
	}
	else
	{
		totalPage = (totalCount / perpage_conv_detail) + 1;
	}
	curPage = totalPage;
	
	[self getRecords];
 }

-(void)getRecords
{
	if (self.isVirGroup)
	{
		self.itemArray = [NSMutableArray arrayWithArray:[db getVirGroupConvRecordListBy:self.convId andPage: curPage]];
    }
	else
	{
		self.itemArray = [NSMutableArray arrayWithArray:[db getConvRecordListBy:self.convId andPage: curPage]];
    }	
	self.title=[NSString stringWithFormat:@"%@[%d/%d]",[self getFormatConvName],curPage,totalPage];
    [self formatAndDisplay];
}

-(void) fastpreAction:(id) sender{
	if(curPage == 1) return;
	curPage = 1;
    
	[self getRecords];
}
-(void) preAction:(id) sender{
	if(curPage == 1)
		return;
	curPage--;
	[self getRecords];
}
-(void) nextAction:(id) sender{
	if(curPage == totalPage)
		return;
	curPage++;
	[self getRecords];
}
-(void) fastnextAction:(id) sender{
	if(curPage == totalPage) return;
	curPage = totalPage;
	[self getRecords];
}

#pragma mark alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
		[db deleteConvRecordBy:self.convId];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(void) deleteAction:(id) sender{
//	删除对话、删除聊天记录提示：确定删除该群聊的聊天记录吗？/确定删除和唐承良的聊天记录吗？/确定要清除全部聊天记录吗？
	NSString *tips=@"";
	if(self.convType == singleType)
	{
		tips = [NSString stringWithFormat:@"确定删除和%@的聊天记录吗？"	,self.convName];
	}
	else
	{
		tips = @"确定删除该群聊的聊天记录吗？";
	}
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"会话" message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
	[alert dismissWithClickedButtonIndex:1 animated:YES];
	[alert show];
	[alert release];
}
-(void)sendTalk:(id)sender
{
    for(UIViewController *controller in self.navigationController.viewControllers)
	{
		if([controller isKindOfClass:[talkSessionViewController class]])
		{
			[self.navigationController popToViewController:controller animated:YES];
			return;
		}
	}

	talkSessionViewController *talkSession = [[talkSessionViewController alloc]init];
	talkSession.talkType = self.convType;
	talkSession.titleStr = self.convName;
	talkSession.convId = self.convId;
	talkSession.needUpdateTag=1;
//	if (self.convType==singleType)
//	{
//		talkSession.convEmps = [NSArray arrayWithObject:self.conv.emp];
//	}else
//	{
		talkSession.convEmps =[db getAllConvEmpBy:self.convId];
//	}
	
	[self.navigationController pushViewController:talkSession animated:YES];
}

//返回 按钮
-(void) backButtonPressed:(id) sender
{
	[self stopPlayAudio];
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma  table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.itemArray count];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:indexPath.row];
	
	float cellHeight = [talkSessionUtil getMsgBodyHeight:_convRecord];
	return cellHeight ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"chatCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		cell = [talkSessionUtil tableViewCellWithReuseIdentifier:CellIdentifier];
	}
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:indexPath.row];
	
	[talkSessionUtil configureCell:cell andConvRecord:_convRecord];
	
	//	状态按钮
	UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	[spinner stopAnimating];

	UIButton *failButton = (UIButton*)[cell.contentView viewWithTag:status_failBtn_tag];
	
	//		如果是发送的消息，并且发送状态是上传成功后发送中或上传中，那么显示正在发送
	if(_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading || _convRecord.send_flag == send_upload_fail))
	{
		failButton.hidden=NO;
	}
		
	//	消息内容
	switch(_convRecord.msg_type)
	{
		case type_pic:
		{
			UIImageView *showPicView = (UIImageView*)[cell.contentView viewWithTag:pic_tag];
			//添加手势
			showPicView.userInteractionEnabled=YES;
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
			[showPicView addGestureRecognizer:singleTap];
			[singleTap release];
			
			if(!_convRecord.isBigPicExist)
			{
				if(!_convRecord.isSmallPicExist)
				{
					if(!_convRecord.isDownLoading)
					{
						_convRecord.isDownLoading = true;
						[self autoDownloadSmallPic:cell andConvRecord:_convRecord];
					}
					else
					{
						[spinner startAnimating];
					}
				}
			}
		}
			break;
		case type_record:
		{
			if(_convRecord.isAudioExist)
			{
				UIButton *clickButton = (UIButton*)[cell.contentView viewWithTag:audio_tag];
				
				UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayAudio:)];
				[clickButton addGestureRecognizer:singleTap];
				[singleTap release];
				//	如果是收到的消息，如果已经下载，并且还未读，那么显示红点，未读标志
				if(_convRecord.msg_flag == rcv_msg && _convRecord.is_set_redstate == 1 )
				{
					UIImageView *readImage=(UIImageView *)[cell viewWithTag:status_audio_tag];
					readImage.hidden = NO;
				}
			}
			else
			{
				if(_convRecord.send_flag == -1)
				{
					//					如果文件不存在，那么就不再下载
				}
				else
				{
					if(_convRecord.isDownLoading)
					{
						[spinner startAnimating];
					}
					else
					{
						_convRecord.isDownLoading = true;
						[self downloadFile:_convRecord.msgId andCell:cell];
					}
				}
			}
		}
			break;
		case type_long_msg:
		{
			if(!_convRecord.isLongMsgExist)
			{
				if(_convRecord.send_flag == -1)
				{
					//					如果文件不存在，那么就不再下载
				}
				else
				{
					if(_convRecord.isDownLoading)
					{
						[spinner startAnimating];
					}
					else
					{
						_convRecord.isDownLoading = true;
						[self downloadFile:_convRecord.msgId andCell:cell];
					}
				}
			}
		}
			break;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark===========================复制文本消息功能==================================
-(void)menuDisplay
{
	if(self.editMsgId)
	{
		self.isDeleteAction = false;
		UITableViewCell *cell = [talkTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.editRow inSection:0]];
		UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
		if(bubbleView.hidden)
		{
			bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
		}
		bubbleView.highlighted = YES;
	}
}
-(void)menuHide
{
	if(self.editMsgId && !self.isDeleteAction)
	{
		UITableViewCell *cell = [talkTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.editRow inSection:0]];
		UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
		if(bubbleView.hidden)
		{
			bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
		}
		bubbleView.highlighted = NO;
		self.editRecord = nil;
		self.editMsgId = nil;
	}
}

#pragma mark 双击复制功能
-(void)doubleTapTableViewListener:(UITapGestureRecognizer *)gesture
{
	CGPoint p = [gesture locationInView:talkTable];
	[self prepareToShowCopyMenu:p];
}
#pragma mark 长按复制功能
- (void) myHandleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
 	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) 
	{
		CGPoint p = [gestureRecognizer locationInView:talkTable]; 
		[self prepareToShowCopyMenu:p];
    }
}

-(void)prepareToShowCopyMenu:(CGPoint)p
{
	NSIndexPath *indexPath = [talkTable indexPathForRowAtPoint:p];
	
	NSString *pointY=[NSString stringWithFormat:@"%0.0f",p.y];

	if(indexPath)
	{
		//		点击位置对应的记录下标
		int _index = [indexPath row];		
		ConvRecord *_convRecord = [self.itemArray objectAtIndex:_index];
		
		self.editMsgId = [StringUtil getStringValue:_convRecord.msgId];
		self.editRecord = _convRecord;
		self.editRow = _index;
		
		UITableViewCell *cell = [talkTable cellForRowAtIndexPath:indexPath];
		[cell becomeFirstResponder];
		[self performSelector:@selector(showCopyMenu:)withObject:[NSDictionary dictionaryWithObjectsAndKeys:cell,@"LONG_CLICK_CELL",pointY,@"pointY", nil] afterDelay:0.05f];
	}
}

#pragma mark  长按或双击可以复制消息文本功能
- (void)showCopyMenu:(id)dic 
{
	UITableViewCell *longClickCell =  (UITableViewCell*)[(NSDictionary *)dic objectForKey:@"LONG_CLICK_CELL"];
	
	UIImageView *bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_send_tag];
	if(bubbleView.hidden)
	{
		bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_rcv_tag];
	}
    NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
	float copyX;
	if(self.editRecord.msg_flag == rcv_msg)
	{
		copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width / 2 + 5;
	}
	else
	{
		copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width/2 - 5;
	}
	
    int copyY=[pointY intValue]-longClickCell.frame.origin.y;
    UIMenuController * menu = [UIMenuController sharedMenuController];
    [menu setTargetRect: CGRectMake(copyX , copyY, 1, 1) inView: longClickCell];
    [menu setMenuVisible: YES animated: YES];
}

#pragma mark 只提供复制功能
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	if(action == @selector(copy:))
	{
		if(self.editRecord != nil && (self.editRecord.msg_type == type_text || self.editRecord.msg_type == type_long_msg || self.editRecord.msg_type == type_pic))
		{
			return YES;
		}else
		{
			return NO;
		}
    }
    else if(action == @selector(delete:))
	{
		if(self.editRecord && self.editRecord.msg_type == type_group_info)
			return NO;
        return YES;
    }
	return NO;
}
#pragma mark 把文本消息复制到剪贴板，便于粘贴到文本框
- (void)copy:(id)sender
{
	if(self.editRecord)
	{
		NSString *copyStr = self.editRecord.msg_body;
		if(self.editRecord.msg_type == type_long_msg)
		{
			NSString *fileName = [NSString stringWithFormat:@"%@.txt",copyStr];
			NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
			copyStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
		}
		else if(self.editRecord.msg_type == type_pic)
		{
			NSString *fileName = [NSString stringWithFormat:@"%@.png",copyStr];
			NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
			
			UIImage *img = [UIImage imageWithContentsOfFile:filePath];
			if (img!=nil)
			{
				copyStr = filePath;
			}
			else
			{
				copyStr = @"";
				UIAlertView *tempalert=[[UIAlertView alloc]initWithTitle:@"不能复制" message:@"此图片未下载，请先点击下载" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
				[tempalert show];
				[tempalert release];
			}
		}
		
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:copyStr];
	}
}
-(void)delete:(id)sender
{
	self.isDeleteAction = true;
	
    [db deleteOneMsg:self.editMsgId];
	
	int _index = [self getArrayIndexByMsgId:self.editMsgId.intValue];
	if(_index >= 0)
	{
		[self.itemArray removeObjectAtIndex:_index];
		[talkTable beginUpdates];
		[talkTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		[talkTable endUpdates];
	}
}
#pragma mark===========================录音消息相关代码==================================
#pragma mark 点击播放 录音 2011-11-15 add by lyong
-(void)startPlayAudio:(UITapGestureRecognizer *)gestureRecognizer
{
	CGPoint p = [gestureRecognizer locationInView:talkTable];
	NSIndexPath *indexPath = [talkTable indexPathForRowAtPoint:p];
	
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:indexPath.row];
	
	UIButton * button=(UIButton *)(((UITapGestureRecognizer*)gestureRecognizer).view);
    button.alpha=0.5;
    [self performSelector:@selector(setAlphaToView:) withObject:button afterDelay:0.3];
	
	if(!_convRecord.isAudioExist)
		return;
	
	NSString *pathStr=[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
	
	self.isAudioPause = false;
	if(self.curRecordPath && [pathStr isEqualToString:self.curRecordPath])
	{
		self.isAudioPause = true;
		if([self stopPlayAudio])
			return;
	}
	
	[self stopPlayAudio];
	
	[self playAudioAtIndexPath:indexPath];
}

#pragma mark 播放某一行的录音文件，播放单个录音和连续播放录音时调用 add by shisp
-(void)playAudioAtIndexPath:(NSIndexPath*)indexPath
{
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:indexPath.row];
	UITableViewCell *cell = [talkTable cellForRowAtIndexPath:indexPath];
	UIImageView *playaudioview=(UIImageView *)[cell.contentView viewWithTag:audio_playImageView_tag];
	NSString *pathStr=[[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
	self.curRecordPath = pathStr;
    
	if(_convRecord.msg_flag == send_msg)
	{
		playaudioview.image = sendVoicePlayView.image;
		playaudioview.animationRepeatCount = sendVoicePlayView.animationRepeatCount;
		playaudioview.animationImages = sendVoicePlayView.animationImages;
		playaudioview.animationDuration = sendVoicePlayView.animationDuration;
	}
	else
	{
		playaudioview.image = rcvVoicePlayView.image;
		playaudioview.animationRepeatCount = rcvVoicePlayView.animationRepeatCount;
		playaudioview.animationImages = rcvVoicePlayView.animationImages;
		playaudioview.animationDuration = rcvVoicePlayView.animationDuration;
		
		int redstate=_convRecord.is_set_redstate;
		if (redstate==1)
		{
			UIImageView *readlabel=(UIImageView *)[cell.contentView viewWithTag:status_audio_tag];
			readlabel.hidden=YES;
			[db updateMessageToReadState:[StringUtil getStringValue:_convRecord.msgId]];
			_convRecord.is_set_redstate = 0;
        }
	}
	[playaudioview startAnimating];
	
    NSRange range=[pathStr rangeOfString:@".amr"];
	
    if (range.length > 0)
	{//需要转换
        NSString * docFilePath        = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:@"amrAudio.wav"];
        [amrtowav startAMRtoWAV:pathStr tofile:docFilePath];
		[self performSelector:@selector(playAudio:) withObject:docFilePath afterDelay:1];
        return;
    }
	[self playAudio:pathStr];
}
#pragma mark 停止播放音频播放动画 add by shisp
-(int)stopAudioPlayImage
{
	if(self.curRecordPath)
	{
		NSRange range = [self.curRecordPath rangeOfString:@"/" options:NSBackwardsSearch];
		if(range.length > 0)
		{
			NSString *filePath = [self.curRecordPath substringFromIndex:range.location + 1];
			for(int i = self.itemArray.count - 1;i>=0;i--)
			{
				ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
				if(_convRecord.msg_type == type_record && [_convRecord.file_name isEqualToString:filePath])
				{
					UITableViewCell *cell = [talkTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
					UIImageView *playImageView = (UIImageView*)[cell.contentView viewWithTag:audio_playImageView_tag];
					[playImageView stopAnimating];
					
					return i;
				}
			}
		}
	}
	return self.itemArray.count - 1;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放结束时执行的动作
    NSLog(@"------------播放结束时执行的动作");
 
	int curAudioIndex = [self stopAudioPlayImage];
	self.curRecordPath = nil;
	
	[self playNextAudio:curAudioIndex];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
    NSLog(@"------------解码错误执行的动作");
	[self stopAudioPlayImage];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
    NSLog(@"------------处理中断的代码");
}
- (void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
    NSLog(@"------------处理中断结束的代码");
}

#pragma mark 获得硬件版本
-(float)deviceVersion
{
	return [[[UIDevice currentDevice] systemVersion] floatValue];
}

#pragma mark 停止播放录音
-(bool)stopPlayAudio
{
	[self stopAudioPlayImage];
	
    if ([self deviceVersion] >= 6.0)//ios6 播放 aac
    {
        self.isAudioPause=[audioplayios6 stopPlayAudio];
         [[AVAudioSession sharedInstance] setActive:NO error:nil];
		return true;
    }
	else if (audioPlayer!=nil) 
	{
        [audioPlayer stop];//停止
        [audioPlayer release];
		audioPlayer = nil;
         [[AVAudioSession sharedInstance] setActive:NO error:nil];
		return true;
    }
	return false;
}
/*监测是否插入耳机*/
- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
}
#pragma mark 播放录音
-(void)playAudio:(NSString*)pathStr
{
    //是否插入耳机播放
    BOOL Headset=[self hasHeadset];
    if (Headset) {
        
    }else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
	//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
	if ([self deviceVersion] >= 6.0)//ios6 播放 aac
    {
        [audioplayios6 playAudio:pathStr];
        return;
    }
	else
	{
		NSError* err;
//		NSLog(@"---audio path---%@",pathStr);
		audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:pathStr] error:&err ];//使用本地URL创建
		if(err)
		{
			[self stopAudioPlayImage];
			NSLog(@"err msg is %@",err.localizedDescription);
			return;
		}
		audioPlayer.volume = 1.0;
		audioPlayer.delegate=self;
		[audioPlayer prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
		[audioPlayer play];//播放
	}
}
# pragma mark ios6 播放录音完成后，发出以下通知
- (void)playbackQueueStopped:(NSNotification *)note
{
	//    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
	int curAudioIndex = [self stopAudioPlayImage];
	self.curRecordPath = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
//	if(!self.isAudioPause)
//	{
//		[self playNextAudio:curAudioIndex];
//	}
}
#pragma remark 播放下一个连续未读录音文件
-(void)playNextAudio:(int)curAudioIndex
{
	for(int i = curAudioIndex + 1;i<self.itemArray.count;i++)
	{
		ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
		if(_convRecord.msg_type == type_record && _convRecord.isAudioExist && _convRecord.is_set_redstate == 1)
		{
			[self playAudioAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			break;
		}
	}
}

#pragma mark============================图片消息相关方法===========================
#pragma mark 自动下载缩率图
- (void)autoDownloadSmallPic:(UITableViewCell*)cell andConvRecord:(ConvRecord *)recordObject
{
	UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	[activity startAnimating];
	
	dispatch_queue_t queue;
	queue = dispatch_queue_create("download small pic", NULL);
	dispatch_async(queue, ^{
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getSmallPicDownloadUrl],recordObject.msg_body]];
		NSData *imageData = [NSData dataWithContentsOfURL:url];
		UIImage *image = [UIImage imageWithData:imageData];
		recordObject.isDownLoading = false;
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (image!=nil)
			{
				[activity stopAnimating];
				
				NSString *smallpicname = [NSString stringWithFormat:@"small%@.png",recordObject.msg_body];
				NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:smallpicname];
				BOOL success= [imageData writeToFile:picpath atomically:YES];
				if(!success)
				{
					NSLog(@"图片缩略图保存失败");
				}
				else
				{
					int _index = [self getArrayIndexByMsgId:recordObject.msgId];
					if(_index >=0 )
					{						
						[self reloadRow:_index];
					}
				}
			}
			else
			{
				[activity stopAnimating];
			}
		});
	});
}

-(void)setAlphaToView:(UIView *)tempview
{
    tempview.alpha=1;
}
#pragma mark 点击图片消息，对于收到的消息，如果未下载，点击后开始下载，否则预览图片，如果是发送的消息，那么点击后可预览图片
-(void)onClickImage:(UIGestureRecognizer*)gestureRecognizer
{
	CGPoint p = [gestureRecognizer locationInView:talkTable];
	NSIndexPath *indexPath = [talkTable indexPathForRowAtPoint:p];
	UITableViewCell *cell = [talkTable cellForRowAtIndexPath:indexPath];

	ConvRecord *_convRecord = [self.itemArray objectAtIndex:indexPath.row];
	
    UIImageView*tempimageView=((UIImageView*)((UITapGestureRecognizer*)gestureRecognizer).view);
    tempimageView.alpha=0.5;
    [self performSelector:@selector(setAlphaToView:) withObject:tempimageView afterDelay:0.3];
	
	if(_convRecord.isBigPicExist)
	{
		NSString *fileName = [NSString stringWithFormat:@"%@.png",_convRecord.msg_body];
		NSString *pathstr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:fileName];
		
		//		如果有原图，就显示原图
//		UIImage *originImg = [UIImage imageWithContentsOfFile:pathstr];
//		CGSize _size = [talkSessionUtil getImageSizeAfterCrop:originImg];
//		if(_size.width > 0 && _size.height > 0)
//		{
////			是裁剪不成功的图片，如果有缩率图，则显示缩略图，否则滑动很慢
//			NSString *smallpicname=[NSString stringWithFormat:@"small%@.png",_convRecord.msg_body];
//			NSString *smallpicpath = [[StringUtil getFileDir] stringByAppendingPathComponent:smallpicname];
//			if([[NSFileManager defaultManager] fileExistsAtPath:smallpicpath])
//			{
//				pathstr = smallpicpath;
//			}
//		}

        watchPreImageTag = 1;
        //	预览图片
        self.preImageFullPath=pathstr;
        localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        localGallery.imagePath=pathstr;
        [self.navigationController pushViewController:localGallery animated:YES];
        //  self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
        [localGallery release];
		return;
	}
	else
	{
		//		缩率图存在时，可以下载原图，否则不下载
		if(_convRecord.isSmallPicExist)
		{
			if(_convRecord.isDownLoading)
			{
				//		显示进度条
				UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
				[talkSessionUtil displayProgressView:progressview];
			}
			else
			{
				[self downloadFile:_convRecord.msgId andCell:nil];
			}
		}
	}
}

#pragma mark==============================常用代码封装==============================
#pragma mark 如果会话主题比较长，那么只显示一部分
-(NSString*)getFormatConvName
{
	NSString * _nameStrPart=self.convName;
    if (self.convName.length>4) {
        _nameStrPart=[NSString stringWithFormat:@"%@...",[self.convName substringToIndex:4]];
    }
	return _nameStrPart;
}

#pragma mark 格式化数据并且显示
-(void)formatAndDisplay
{
	[self stopPlayAudio];
	
    int count=[self.itemArray count];
    for (int i=0; i<count; i++) {
        
        ConvRecord *_convRecord =[self.itemArray objectAtIndex:i];
		[self setTimeDisplay:_convRecord andIndex:i];
		[talkSessionUtil setPropertyOfConvRecord:_convRecord];

    }
	[talkTable reloadData];
	
    if (count>0) {
        [talkTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.itemArray count]-1 inSection:0]
                                  atScrollPosition: UITableViewScrollPositionBottom
                                          animated:NO];
    }
}

// 是否wifi
- (BOOL) IsEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}
-(BOOL) canBecomeFirstResponder{
    return YES;
}

#pragma mark 封装下载文件方法
-(void)downloadFile:(int)msgId andCell:(UITableViewCell*)_cell
{
	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,msgId]];
	int _index = [self getArrayIndexByMsgId:msgId];
	if(_index < 0) return;
	
	UITableViewCell *cell = [talkTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
	if(cell == nil)
	{
		cell = _cell;
	}
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:_index];
	
	UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	
	_convRecord.isDownLoading = true;
	int msgType = _convRecord.msg_type;
	
	//		准备文件下载url，准备下载
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getPicDownloadUrl],_convRecord.msg_body]];
	
	switch (msgType) {
		case type_pic:
		{
			//		显示进度条
			UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
			[talkSessionUtil displayProgressView:progressview];
		}
			break;
		case type_record:
		{
			url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getAudioFileDownloadUrl],_convRecord.msg_body]];
		}
			break;
		case type_long_msg:
		{
			url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLongMsgDownloadUrl],_convRecord.msg_body]];
		}
			break;
		default:
			break;
	}
	
 	ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
	
	[request setDelegate:self];
	
	NSString *pathStr;
	
	switch (msgType) {
		case type_pic:
		{
			//		显示进度条
			UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
			pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",_convRecord.msg_body]];
			//设置文件保存路径
			[request setDownloadDestinationPath:pathStr];
			[request setDownloadProgressDelegate:progressview];
		}
			break;
		case type_record:
		{
			[spinner startAnimating];
			
			pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_convRecord.file_name];
			[request setDownloadDestinationPath:pathStr];
		}
			break;
		case type_long_msg:
		{
			[spinner startAnimating];
			
			pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_convRecord.msg_body]];
			[request setDownloadDestinationPath:pathStr];
		}
			break;
		default:
			break;
	}
	
	[request setDidFinishSelector:@selector(downloadFileComplete:)];
	[request setDidFailSelector:@selector(downloadFileFail:)];
	
	//		传参数，文件传输完成后，根据参数进行不同的处理
	[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:_convRecord.msgId],@"MSG_ID",nil]];
	[request setTimeOutSeconds:30];
	[request startAsynchronous];
	[request release];
}

#pragma mark 下载文件成功
- (void)downloadFileComplete:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,statuscode]];
	
	NSDictionary *dic=[request userInfo];
	NSString *_msgId = [dic objectForKey:@"MSG_ID"];
	int _index = [self getArrayIndexByMsgId:_msgId.intValue];
	
	
	if(_index < 0)
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0)
		{
			ConvRecord *_convRecord = [db getConvRecordByMsgId:_msgId];
			if(_convRecord.msg_type == type_pic)
			{
				UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
				[talkSessionUtil hideProgressView:progressView];

				NSString *picPath = [request downloadDestinationPath];
				
				//		检查图片的尺寸，看是否需要裁剪
				UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
				
				CGSize _size = [talkSessionUtil getImageSizeAfterCrop:img];
				
				if(_size.width > 0 && _size.height>0)
				{
					img= [ImageUtil scaledImage:img  toSize:_size withQuality:kCGInterpolationHigh];
				}
				NSData *imageData=UIImageJPEGRepresentation(img,1);
				BOOL success= [imageData writeToFile:picPath atomically:YES];
				if(!success)
					NSLog(@"保存失败");
			}
		}
		return;
	}
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:_index];
	_convRecord.isDownLoading = false;
	
	UITableViewCell *cell = [talkTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
	
 	UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	[spinner stopAnimating];
	
	int msgType = _convRecord.msg_type;
	if(statuscode == 404)
	{//文件不存在
		//		记录至数据库中，下次不再加载
		[db updateSendFlagByMsgId:_msgId andSendFlag:-1];
		_convRecord.send_flag = -1;
		if(msgType == type_pic)
		{
			UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
			[talkSessionUtil hideProgressView:progressView];
		}
		else if(msgType == type_long_msg)
		{
			[[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
		}
	}
	else if(statuscode != 200)
	{//下载失败
		[self downloadFileFail:request];
	}
	else
	{//下载成功,如果文件存在，并且size大于0，显示给用户，否则按照文件不存在处理
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0)
		{
			if(msgType == type_pic)
			{
				UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
				[talkSessionUtil hideProgressView:progressView];

				NSString *picPath = [request downloadDestinationPath];
				
				//		检查图片的尺寸，看是否需要裁剪
				UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
				CGSize _size = [talkSessionUtil getImageSizeAfterCrop:img];
				if(_size.width>0 && _size.height>0)
				{
					img= [ImageUtil scaledImage:img  toSize:_size withQuality:kCGInterpolationHigh];
				}
				NSData *imageData=UIImageJPEGRepresentation(img,1);
				BOOL success= [imageData writeToFile:picPath atomically:YES];
				if(!success)
				{
					NSLog(@"保存失败");
				}
				else
				{
					UIViewController *topController = [self.navigationController topViewController];
					//				[LogUtil debug:[NSString stringWithFormat:@"%@",topController]];
					if([topController isKindOfClass:[self class]])
					{
						//	预览图片
                        watchPreImageTag = 1;
                        //	预览图片
                        self.preImageFullPath=picPath;
                        localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
                        localGallery.imagePath=picPath;
                        [self.navigationController pushViewController:localGallery animated:YES];
                        //  self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
                        [localGallery release];
					}
				}
			}
			[self reloadRow:_index];
		}
		else
		{
			[db updateSendFlagByMsgId:_msgId andSendFlag:-1];
			_convRecord.send_flag = -1;
			if(msgType == type_pic)
			{
				UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
				[talkSessionUtil hideProgressView:progressView];
			}
		}
	}
}

#pragma mark 下载文件失败
-(void)downloadFileFail:(ASIHTTPRequest*)request
{
	[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
	NSDictionary *dic=[request userInfo];
	NSString* _msgId = [dic objectForKey:@"MSG_ID"];
	int _index = [self getArrayIndexByMsgId:_msgId.intValue];
	
	if(request.error.code == ASIRequestTimedOutErrorType)
	{
		if(_index >= 0)
		{
			ConvRecord *_convRecord = [self.itemArray objectAtIndex:_index];
			_convRecord.tryCount++;
			if(_convRecord.tryCount < max_try_count)
			{//继续尝试下载，否则报错
				[self downloadFile:_msgId.intValue andCell:nil];
				return;
			}
		}
	}
	
	[[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
	
	if(_index < 0) return;
	
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:_index];
	_convRecord.isDownLoading = false;
	
	_convRecord.tryCount = 0;
	
	UITableViewCell *cell = [talkTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
	
	UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
	[spinner stopAnimating];
	
	UIButton *failBtn =(UIButton *)[cell.contentView viewWithTag:status_failBtn_tag];
	failBtn.titleLabel.text = _msgId;
	[failBtn addTarget:self action:@selector(reDownloadFile_click:) forControlEvents:UIControlEventTouchUpInside];
	failBtn.hidden = NO;
}

#pragma mark 重新下载文件 点击事件
-(void)reDownloadFile_click:(id)sender
{
	UIButton *failBtn = sender;
	failBtn.hidden = YES;
	NSString *msgId = failBtn.titleLabel.text;
	[self downloadFile:msgId.intValue andCell:nil];
}


#pragma mark 根据msgId找到对应的下标
-(int)getArrayIndexByMsgId:(int)msgId
{
	for(int i = self.itemArray.count - 1;i>=0;i--)
	{
		ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
		if(_convRecord.msgId == msgId)
		{
			return i;
		}
	}
	return -1;
}


#pragma mark 聊天记录修改后，局部刷新
-(void)reloadRow:(int)_index
{
	ConvRecord *_convRecord = [self.itemArray objectAtIndex:_index];
	[talkSessionUtil setPropertyOfConvRecord:_convRecord];
	
	[talkTable beginUpdates];
	[talkTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_index inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
	[talkTable endUpdates];
}

#pragma mark 确定本条记录是否显示时间
-(void)setTimeDisplay:(ConvRecord*)_convRecord  andIndex:(int)_index
{
	if(_index == 0)
	{
		_convRecord.isTimeDisplay = true;
		return;
	}
	
	bool isDisplay = true;
	
	int lastDisplayMsgIndex = [self getLastDisplayTimeMsg:_index];
	ConvRecord *tempConvRecord = [self.itemArray objectAtIndex:lastDisplayMsgIndex];
	//			如果当前的时间和第一条的时间在3分钟之内，那么就不用显示,有两种情况，一个是小于msg_time_sec,一个是小于0，防止下面消息的显示时间比上面消息的显示时间早的情况 fabs(
	NSTimeInterval _diff = _convRecord.msg_time.intValue - tempConvRecord.msg_time.intValue;
	if(_diff < 0 || (_diff >= 0 && _diff <= msg_time_sec))
	{
		isDisplay = false;
	}
	_convRecord.isTimeDisplay = isDisplay;
}

#pragma mark 找到最近的一条显示时间的消息，从_index开始向前找
-(int)getLastDisplayTimeMsg:(int)_index
{
	for(int i= _index;i>=0;i--)
	{
		ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
		if(_convRecord.isTimeDisplay)
			return i;
	}
	return 0;
}


#pragma mark - FGalleryViewControllerDelegate Methods
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
	return 1;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeLocal;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption;
    if( gallery == localGallery ) {
        caption = @"112 ";
    }
    else if( gallery == networkGallery ) {
        caption =@"343";
    }
	return @" ";
}
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return self.preImageFullPath;
}
- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return nil;
}
- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}
- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}
@end
