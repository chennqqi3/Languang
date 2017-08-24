
#import "PSMsgDtlViewController.h"
#import "eCloudDAO.h"
#import "PublicServiceDAO.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"
#import "eCloudDefine.h"
#import "LogUtil.h"
#import "ConvRecord.h"
#import "talkSessionUtil.h"
#import "PSMsgUtil.h"
#import "openWebViewController.h"
#import "InputTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "PSUtil.h"
#import "userInfoViewController.h"
#import "PSDetailViewController.h"
#import "NewMsgNotice.h"
#import "MessageView.h"
#import "PSBackButtonUtil.h"
#import "UIImageOfCrop.h"
#import "ImageSet.h"
#import "Emp.h"
#import "UIAdapterUtil.h"
#import "KxMenu.h"
#import "ServiceMenuModel.h"

#import "ServiceModel.h"
#import "conn.h"


//	底部控件栏的高度
#define origin_footer_h (50)

//	发送消息按钮的宽度和高度
#define send_msg_button_w (60)
#define send_msg_button_h (34)

//	文本输入框的高度，宽度和x值
#define origin_textfield_w (320 - 30 - send_msg_button_w)
#define origin_textfield_h (34)

@interface PSMsgDtlViewController ()

@end

static NSString *chatCellId = @"ChatCell";
static NSString *MsgCellId = @"MsgCell";
static NSString *SingleMsgCellId = @"SingleMsgCell";

//消息时间
static NSString *headerCellId = @"headerView";

static PSMsgDtlViewController *sharedObj;
@implementation PSMsgDtlViewController
{
	PublicServiceDAO *_psDAO;
	conn *_conn;
	
	NSMutableArray *msgList;
	
	UITableView *msgTable;
	
//	覆盖在msgTable上的button，用来点击隐藏键盘
	UIButton *tableBackGroudButton;

//	左边返回按钮
	UIButton *backButton;
	
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
	
//	输入文本框
	InputTextView  *messageTextField;
//	输入框所在的view
	UIView *footerView;
//	发送消息按钮
	UIButton *sendButton;
//	目前键盘高度
	float keyboardH;
}
@synthesize serviceModel;
@synthesize editIndexPath;
@synthesize needRefresh;
@synthesize hasListMenu = _hasListMenu;

+(PSMsgDtlViewController*)getPSMsgDtlViewController
{
	//	NSLog(@"%s",__FUNCTION__);
	@synchronized(self)
	{
		if(sharedObj == nil)
		{
			sharedObj = [[self alloc]init];
//			sharedObj.hidesBottomBarWhenPushed = YES;
		}
	}
	return sharedObj;
}

-(void)dealloc
{
	self.editIndexPath = nil;
	if(msgList)
	{
		[msgList release];
		msgList = nil;
	}
	self.serviceModel = nil;
    
    if (menuBtns) {
        [menuBtns release];
        menuBtns = nil;
    }
    
	[super dealloc];
}


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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_psDAO = [PublicServiceDAO getDatabase];
	
	_conn = [conn getConn];

    [UIAdapterUtil processController:self];
    
	CGRect rect = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-44);
	
	msgTable = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    msgTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	[msgTable setDelegate:self];
	[msgTable setDataSource:self];
	UIImage *backImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ChatBackground" ofType:@"jpg"]];
	UIImageView *backView = [[UIImageView alloc]initWithImage:backImage];
	msgTable.backgroundView = backView;
	[backView release];
				
//	增加长按删除功能
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 0.5;
    //将长按手势添加到需要实现长按操作的视图里
    [msgTable addGestureRecognizer:longPress];
	[longPress release];
	

	msgTable.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
	[self.view addSubview:msgTable];
	[msgTable release];
	
	tableBackGroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, msgTable.frame.size.height)];
	[tableBackGroudButton addTarget:self action:@selector(tableBackGroudAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:tableBackGroudButton];
    tableBackGroudButton.hidden=YES;
	[tableBackGroudButton release];
	
	rect = CGRectMake(145,5, 30.0f,30.0f);
	loadingIndic = [[UIActivityIndicatorView alloc]initWithFrame:rect];
	loadingIndic.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	loadingIndic.hidden = YES;
	isLoading = NO;
	
//	初始化
	[self initFootView];
	
	[self setRightBtn];
	
	[self setLeftBtn];
}

#pragma mark ----------------------------------初始化footerView----------------------------------
-(void)initFootView
{
	int footerY = self.view.frame.size.height - 44 - origin_footer_h;
	footerView=[[UIView alloc]initWithFrame:CGRectMake(0, footerY, 320, origin_footer_h)];
    footerView.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    [self.view addSubview:footerView];
	[footerView release];
    
    [self addListMenuView];
    
    subfooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50.0)];
    subfooterView.backgroundColor=[UIColor clearColor];
    [footerView addSubview:subfooterView];
    [subfooterView release];
    
    //切换菜单
    hideListMenuBtn=[[UIButton alloc]initWithFrame:CGRectMake(2.0, 0.0, 44.0,50.0)];
    [hideListMenuBtn setBackgroundImage:[UIImage imageNamed:@"ps_menulist_btn.png"] forState:UIControlStateNormal];
    hideListMenuBtn.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    hideListMenuBtn.hidden = YES;
    [hideListMenuBtn addTarget:self action:@selector(clickOnListMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:hideListMenuBtn];
    [hideListMenuBtn release];
    
    linebreakView = [[UIView alloc] initWithFrame:CGRectMake(49.0, 0.0, 1.0, 50.0)];
    linebreakView.backgroundColor = [UIColor colorWithRed:46.0/255 green:51.0/255 blue:67.0/255 alpha:1.0];
    [footerView addSubview:linebreakView];
    [linebreakView release];
    
	//	文本框
	int textX = 5;
    messageTextField=[[InputTextView alloc]initWithFrame:CGRectMake(10,(origin_footer_h - origin_textfield_h)/2, origin_textfield_w, origin_textfield_h)];
	messageTextField.layer.borderColor = [UIColor grayColor].CGColor;
	messageTextField.layer.borderWidth =1.0;
	messageTextField.layer.cornerRadius =5.0;
    messageTextField.font=[UIFont systemFontOfSize:14];
    messageTextField.copypic=false;
	// messageTextField.borderStyle=UITextBorderStyleRoundedRect;
    //[messageTextField addTarget:self action:@selector(othertextFieldDidChange:) forControlEvents:UIControlEventEditingDidBegin];
    messageTextField.delegate=self;
    messageTextField.returnKeyType = UIReturnKeySend;
    [footerView addSubview:messageTextField];
	[messageTextField release];
	
	//	发送按钮
    sendButton=[[UIButton alloc]initWithFrame:CGRectMake(320 - send_msg_button_w - 10 , 10.0, send_msg_button_w,send_msg_button_h)];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [sendButton setTitle:NSLocalizedString(@"send", @"发送") forState:UIControlStateNormal];
    sendButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];    
    [sendButton addTarget:self action:@selector(sendPSMessage:) forControlEvents:UIControlEventTouchUpInside];
    [subfooterView addSubview:sendButton];
	[sendButton release];
}

- (void)addListMenuView{
    listMenu = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    listMenu.backgroundColor = [UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    listMenu.hidden  = YES;
    [footerView addSubview:listMenu];
    [listMenu release];
    
    //切换菜单
    UIButton *showListMenuBtn=[[UIButton alloc]initWithFrame:CGRectMake(2.0, 0.0, 44.0,50.0)];
    [showListMenuBtn setBackgroundImage:[UIImage imageNamed:@"ps_menulist_up_btn.png"] forState:UIControlStateNormal];
    showListMenuBtn.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [showListMenuBtn addTarget:self action:@selector(clickOnListMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    [listMenu addSubview:showListMenuBtn];
    [showListMenuBtn release];
    
    UIView *linebreak = [[UIView alloc] initWithFrame:CGRectMake(49.0, 0.0, 1.0, 50.0)];
    linebreak.backgroundColor = [UIColor colorWithRed:46.0/255 green:51.0/255 blue:67.0/255 alpha:1.0];
    [listMenu addSubview:linebreak];
    [linebreak release];
}

- (void)refreshFooterView{
    if (self.hasListMenu) {
        if ([messageTextField isHidden]) {
            listMenu.hidden = NO;
        }
        
        if ([listMenu isHidden]) {
            hideListMenuBtn.hidden = NO;
        }
        
        if (![messageTextField isHidden] && messageTextField.frame.size.width > 180.0) {
            CGRect rect = messageTextField.frame;
            rect.origin.x += 50.0;
            rect.size.width -= 40.0;
            messageTextField.frame = rect;
        }
        linebreakView.hidden = NO;
        [self addListBtnMenu];
    }
    else{
        linebreakView.hidden = YES;
        hideListMenuBtn.hidden = YES;
        
        if ([messageTextField isHidden]) {
            messageTextField.hidden = NO;
            subfooterView.hidden = NO;
            listMenu.hidden = YES;
        }
    }
}

- (void)addListBtnMenu{
    for (UIButton *btn in listMenu.subviews) {
        if (btn.tag > 2) {
            [btn removeFromSuperview];
        }
    }
    
    int count = [menuBtns count];
    for (int i = 0; i < count; i++) {
        UIButton *menuBtn=[[UIButton alloc]initWithFrame:CGRectMake(49.0+(320.0-50.0)/count*i, 0.0, (320.0-50.0)/count+1,50.0)];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"ps_menu_btn.png"] forState:UIControlStateNormal];
        [menuBtn setTitle:[NSString stringWithFormat:@"%@",[[menuBtns objectAtIndex:i] objectForKey:@"name"]] forState:UIControlStateNormal];
        menuBtn.titleLabel.font=[UIFont boldSystemFontOfSize:14];
        menuBtn.tag = 3+i;
        [menuBtn addTarget:self action:@selector(clickOnMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
        [listMenu addSubview:menuBtn];
        [menuBtn release];
        
        NSArray *subtnArr = [[menuBtns objectAtIndex:i] objectForKey:@"sub_button"];
        if ([subtnArr count]) {
            //有二级菜单显示
            float showMenuListx = menuBtn.frame.size.width - 18.0;
            float showMenuListy = menuBtn.frame.size.height - 18.0;
            UIImageView *showMenuList = [[UIImageView alloc]initWithFrame:CGRectMake(showMenuListx, showMenuListy, 18.0, 18.0)];
            showMenuList.image = [UIImage imageNamed:@"showMenuList.png"];
            [menuBtn addSubview:showMenuList];
            [showMenuList release];
        }
    }
}

#pragma mark - 按钮方法实现
- (void)clickOnListMenuBtn:(UIButton *)sender{
    if ([listMenu isHidden]) {
        [self showListMenuAnimations];
    }
    else{
        [self hideListMenuAnimations];
    }
}

#pragma mark - 菜单隐藏或显示动画
- (void)showListMenuAnimations{
    CGRect rect = footerView.frame;
    [UIView beginAnimations:@"showListMenu" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showListMenu)];
    [UIView setAnimationDuration:0.2];
    rect.origin.y += 50.0;
    [footerView setFrame:rect];
    [UIView commitAnimations];
}

- (void)showListMenu{
    listMenu.hidden = NO;
    subfooterView.hidden = YES;
    linebreakView.hidden = YES;
    CGRect rect = footerView.frame;
    rect.origin.y -= 50.0;
    [footerView setFrame:rect];
    
    [self hideTextView];
    [self autoMovekeyBoard:0];
}


- (void)hideListMenuAnimations{
    CGRect rect = footerView.frame;
    [UIView beginAnimations:@"hideListMenu" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideListMenu)];
    [UIView setAnimationDuration:0.2];
    rect.origin.y += 50.0;
    [footerView setFrame:rect];
    [UIView commitAnimations];
}

- (void)hideListMenu{
    listMenu.hidden = YES;
    subfooterView.hidden = NO;
    linebreakView.hidden = NO;
    CGRect rect = footerView.frame;
    rect.origin.y -= 50.0;
    [footerView setFrame:rect];
    [self showTextView];
}

- (void)clickOnMenuBtn:(UIButton *)sender{
    
    NSArray *subtnArr = [[menuBtns objectAtIndex:sender.tag-3] objectForKey:@"sub_button"];
    
    if ([subtnArr count]) {
        //二级菜单
        NSMutableArray *menuItems = [NSMutableArray array];
        for (NSDictionary *dic in subtnArr) {
            KxMenuItem *item = [KxMenuItem menuItem:[NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]]
                                              image:[UIImage imageNamed:@""]
                                             target:self
                                             action:@selector(pushMenuItem:)];
            item.infoDictionary = dic;
            [menuItems addObject:item];
        }
        
        [KxMenu setTitleFont:[UIFont systemFontOfSize:16.0]];
        CGRect rect = sender.frame;
        rect.origin.y = footerView.frame.origin.y;
        
        [KxMenu showMenuInView:self.view
                      fromRect:rect
                     menuItems:menuItems];
    }
    else{
        NSDictionary *dic = [menuBtns objectAtIndex:sender.tag-3];
        NSString *type = [dic objectForKey:@"type"];
        if ([type isEqualToString:@"view"]) {
            NSString *urlStr = [dic objectForKey:@"url"];
            if ([urlStr length]) {
                [self openWebUrl:[StringUtil trimString:urlStr]];
            }
        }
        else if ([type isEqualToString:@"click"]){
            NSString *inputMsg = [dic objectForKey:@"key"];
            if(inputMsg.length == 0 )
                return;
            ServiceMessage *message = [[ServiceMessage alloc]init];
            message.msgBody = inputMsg;
            message.msgFlag = send_msg;
            message.msgTime = [_conn getCurrentTime];
            message.msgType = ps_msg_type_text;
            message.serviceId = self.serviceModel.serviceId;
            message.sendFlag = sending;
            [self sendClickCommand:message];
            [message release];
        }
    }
    
    /*
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Check"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Check"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Reload"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Search"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    [KxMenu setTitleFont:[UIFont systemFontOfSize:16.0]];
    
    CGRect rect = sender.frame;
    rect.origin.y = footerView.frame.origin.y;
    
    [KxMenu showMenuInView:self.view
                  fromRect:rect
                 menuItems:menuItems];
     */
}

- (void) pushMenuItem:(KxMenuItem *)sender
{
    NSLog(@"-----%@", sender.infoDictionary);
    //二级菜单
    NSDictionary *dic = sender.infoDictionary;
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"view"]) {
        NSString *urlStr = [dic objectForKey:@"url"];
        if ([urlStr length]) {
            [self openWebUrl:[StringUtil trimString:urlStr]];
        }
    }
    else if ([type isEqualToString:@"click"]){
        //发送指令
        NSLog(@"发送指令-----");
        NSString *inputMsg = [dic objectForKey:@"key"];
        if(inputMsg.length == 0 )
            return;
        ServiceMessage *message = [[ServiceMessage alloc]init];
        message.msgBody = inputMsg;
        message.msgFlag = send_msg;
        message.msgTime = [_conn getCurrentTime];
        message.msgType = ps_msg_type_text;
        message.serviceId = self.serviceModel.serviceId;
        message.sendFlag = sending;
        [self sendClickCommand:message];
        [message release];
    }
}

- (void)sendClickCommand:(ServiceMessage *)message{
    BOOL sendResult = [_conn sendPSMenuMsg:message];
    NSLog(@"sendResult----------%i",sendResult);
}

#pragma mark --------------------------------------------------------------------
#pragma mark ------------------隐藏或显示文本框的处理------------------
- (void)hideTextView{
    messageTextField.hidden=YES;
    [messageTextField resignFirstResponder];
    [self setFooterView];
}

- (void)showTextView{
    messageTextField.hidden=NO;
//    [messageTextField becomeFirstResponder];
    [self setFooterView];
}

- (void)setFooterView{
    if ([messageTextField isHidden]) {
        float footerY = footerView.frame.origin.y;
        
        if (messageTextField.frame.size.height > 34) {
            footerY = footerY + messageTextField.frame.size.height-34;
        }
        
        footerView.frame=CGRectMake(0, footerY, 320, 50);
        subfooterView.frame=CGRectMake(0, 0, 320, 260);
        messageTextField.frame=CGRectMake(60.0,5, 180, 34);
    }
    else{
        [self textViewDidChange:messageTextField];
    }
}


#pragma mark -----------------------------

#pragma mark - 获取自定义菜单
- (void)getPSMenuList{
    if (!menuBtns) {
        menuBtns = [[NSMutableArray alloc] init];
    }
    
    if ([menuBtns count]) {
        [menuBtns removeAllObjects];
    }
    
   ServiceMenuModel *menuList = [[PublicServiceDAO getDatabase] getPSMenuListByPlatformid:self.serviceModel.serviceId];
    if (menuList) {
        [menuBtns addObjectsFromArray:menuList.button];
    }
    
    if ([menuBtns count]) {
        self.hasListMenu = YES;
    }
    else{
        self.hasListMenu = NO;
    }
}

#pragma mark 发送消息
-(void)sendPSMessage:(id)sender
{
	NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
	
	NSString *inputMsg = messageTextField.text;
	inputMsg = [inputMsg stringByTrimmingCharactersInSet:whitespace];
	if(inputMsg.length == 0 )
		return;
	ServiceMessage *message = [[ServiceMessage alloc]init];
	message.msgBody = inputMsg;
	message.msgFlag = send_msg;
	message.msgTime = [_conn getCurrentTime];
	message.msgType = ps_msg_type_text;
	message.serviceId = self.serviceModel.serviceId;
	message.sendFlag = sending;
	
	bool result = [_psDAO saveServiceMessage:message];
	if(result)
	{
//		[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,message.msgId]];
		ConvRecord *_convRecord = [[ConvRecord alloc]init];
		
		[_psDAO convertServiceMessage:message toConvRecord:_convRecord];
		[msgList addObject:_convRecord];
		[self setTimeDisplay:_convRecord andIndex:msgList.count - 1];
		[msgTable reloadData];
		[self scrollToEnd];

        //消息修改发送状态
        BOOL sendResult = [_conn sendPSMsg:message];
        
		if (sendResult) {
            _convRecord.send_flag = send_success;
            message.sendFlag = send_success;
        }
        else{
            _convRecord.send_flag = send_upload_fail;
            message.sendFlag = send_upload_fail;
        }
        
        [_psDAO updateSendFlagOfServiceMessage:message];
        
		[_convRecord release];
		
		messageTextField.text = @"";
		[self textViewDidChange:messageTextField];
	}
    
	[message release];
}

#pragma mark 获取并显示未读记录数
-(void)showNoReadNum
{
	[PSBackButtonUtil showNoReadNum:nil andButton:backButton];
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
	backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}
-(void)backButtonPressed:(id)sender
{
	[[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 添加右边按钮
-(void)setRightBtn
{
	UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 0, 44,44);
	[addButton setBackgroundImage:[UIImage imageNamed:@"SingleMember.png"] forState:UIControlStateNormal];
	[addButton setBackgroundImage:[UIImage imageNamed:@"SingleMember_click.png"] forState:UIControlStateHighlighted];
	[addButton setBackgroundImage:[UIImage imageNamed:@"SingleMember_click.png"] forState:UIControlStateSelected];
	[addButton addTarget:self action:@selector(viewServiceInfo:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:addButton]autorelease];
}

#pragma mark 查看服务号资料
-(void)viewServiceInfo:(id)sender
{
	PSDetailViewController *_controller = [[PSDetailViewController alloc]init];
	_controller.serviceId = self.serviceModel.serviceId;
//	_controller.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:_controller animated:YES];
	[_controller release];
}

#pragma mark 处理会话通知
-(void)handleCmd:(NSNotification*)notification
{
	eCloudNotification	*cmd =	(eCloudNotification *)[notification object]; 
	switch (cmd.cmdId)
	{
		case rev_msg:
		{
			NewMsgNotice *_notice = notification.userInfo;
			if(_notice.msgType == ps_new_msg_type)
			{
				int serviceId = _notice.serviceId;
				if(serviceId == self.serviceModel.serviceId)
				{
					int serviceMsgId = _notice.serviceMsgId;
					ServiceMessage *message = [_psDAO getMessageByServiceMsgId:serviceMsgId];
					if(message.msgType == ps_msg_type_news)
					{
						[msgList addObject:message];
					}
					else
					{
						ConvRecord *_convRecord = [[ConvRecord alloc]init];
						[_psDAO convertServiceMessage:message toConvRecord:_convRecord];
						[msgList addObject:_convRecord];
						[_convRecord release];
					}
					
					[_psDAO updateReadFlagByServiceMsgId:serviceMsgId];
					[msgTable reloadData];
					
					[LogUtil debug:[NSString stringWithFormat:@"%s,%.0f,%.0f",__FUNCTION__,msgTable.contentOffset.y,msgTable.contentSize.height]];
					
					if (msgTable.contentOffset.y<msgTable.contentSize.height-900) {
						NSLog(@"－－－－－不刷新，不置底部");
					}else{
						[self scrollToEnd];
					}
				}
			}
			[self showNoReadNum];

		}
			break;
	}
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];

	//	监听系统菜单显示，隐藏
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuDisplay) name:UIMenuControllerWillShowMenuNotification object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuHide) name:UIMenuControllerWillHideMenuNotification object:nil];
	
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openWebUrlOfMsg:) name:OPEN_WEB_NOTIFICATION object:nil];
	
	//监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
	if(self.needRefresh)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
		self.needRefresh = NO;
		self.title = self.serviceModel.serviceName;
		
        [self getPSMenuList];
        [self refreshFooterView];
		//	取出用户上次未发出的消息，给输入框赋值
//		messageTextField.copypic=false;
//		messageTextField.text = self.serviceModel.lastInputMsg;
//		[self textViewDidChange:messageTextField];
        messageTextField.text = self.serviceModel.lastInputMsg;
//        if ([messageTextField.text length] && ![messageTextField isHidden]) {
//            [messageTextField becomeFirstResponder];
//        }
        [self setFooterView];
		
		//		发通知出来，通知会话列表，我的界面刷新，主要是更新未读消息数
		int unreadMsgCount = [_psDAO getUnreadMsgCountOfPS:self.serviceModel.serviceId];
		if(unreadMsgCount > 0)
		{
			//	把所有的消息设置为已读
			[_psDAO updateReadFlagOfPSMsg:self.serviceModel.serviceId];
			eCloudNotification *notification = [[eCloudNotification alloc]init];
			notification.cmdId = ps_msg_read;
			[[NSNotificationCenter defaultCenter]postNotificationName:CONVERSATION_NOTIFICATION object:notification];
			[notification release];
		}
		
		
		[self getPsMsgDtl];
		[msgTable reloadData];
		[self scrollToEnd];
		
		[self showNoReadNum];
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
    [KxMenu dismissMenu];
//	保存用户的输入
    [messageTextField resignFirstResponder];
    NSString *lastinputstr=@"";
	if (messageTextField.text)
	{
        lastinputstr=messageTextField.text;
    }

	[_psDAO saveLastInputMsgOfService:self.serviceModel.serviceId andLastInputMsg:lastinputstr];
	
	//取消监听键盘高度的变换
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	//	监听系统菜单显示，隐藏
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:OPEN_WEB_NOTIFICATION object:nil];
}

#pragma mark 滑动到最底部
-(void)scrollToEnd
{
	int section = [msgList count];
	int row = 0;
	int count = [msgList count] ;
	if(count > 0)
	{
		id _id = [msgList objectAtIndex:count-1];
		if([_id isKindOfClass:[ServiceMessage class]])
		{
			ServiceMessage *message = (ServiceMessage*)_id;
			if(message.detail)
			{
				row = message.detail.count - 1;
			}
		}
		[msgTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
						atScrollPosition: UITableViewScrollPositionBottom
								animated:NO];
	}
}

#pragma mark 获取服务号对应的消息
-(void)getPsMsgDtl
{
	totalCount = [_psDAO getServiceMsgCountByServiceId:self.serviceModel.serviceId] ;
	if(totalCount > num_convrecord)
	{
		limit = num_convrecord;
		offset = totalCount - num_convrecord;
	}
	else {
		limit = totalCount;
		offset = 0;
	}
	if(msgList)
	{
		[msgList release];
		msgList = nil;
	}
	@autoreleasepool
	{
		msgList = [[_psDAO getServiceMessageByServiceId:self.serviceModel.serviceId andLimit:limit andOffset:offset]retain];
		for(int i = 0;i<msgList.count;i++)
		{
			id _id = [msgList objectAtIndex:i];
			if([_id isKindOfClass:[ConvRecord class]])
			{
				[self setTimeDisplay:((ConvRecord*)_id) andIndex:i];
			}
		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark tableview
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	NSLog(@"%s",__FUNCTION__);
////	UITableViewCell *cell = [msgTable cellForRowAtIndexPath:indexPath];
////	UIView *backgroundViews = [[UIView alloc]initWithFrame:cell.frame];
////	backgroundViews.backgroundColor = [UIColor grayColor];
////	[cell setSelectedBackgroundView:backgroundViews];
//}
//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	NSLog(@"%s",__FUNCTION__);
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	加载提示
	if(indexPath.section == 0)
	{
		return 40;
	}
	float height = 0;
	
	int section = indexPath.section;
	int row = indexPath.row;
	
	id _id = [msgList objectAtIndex:section-1];
	if([_id isKindOfClass:[ConvRecord class]])
	{
		height = [talkSessionUtil getMsgBodyHeight:(ConvRecord*)_id];
	}
	else
	{
		ServiceMessage *message = (ServiceMessage*)_id;
		int msgType = message.msgType;
		if(msgType == ps_msg_type_news)
		{
			if(message.detail && message.detail.count > 0)
			{
				if(message.detail.count == 1)
				{
					height = [PSMsgUtil getSinglePsMsgHeight:message];
				}
				else
				{
					if(row == 0)
					{
						height = ps_msg_row0_height;
					}
					else
					{
						height = ps_msg_row1_height;
					}
				}
			}
		}
	}
	return height;	
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
		return 1;
	
	int rows = 0;
	
	id _id = [msgList objectAtIndex:section-1];
	
	if([_id isKindOfClass:[ConvRecord class]])
	{
		rows = 1;
	}
	else
	{
		ServiceMessage *message = (ServiceMessage*)_id;
		if(message.msgType == ps_msg_type_news && message.detail)
		{
			rows = message.detail.count;
		}
	}
		
//	[LogUtil debug:[NSString stringWithFormat:@"%s ,rows is %d",__FUNCTION__,rows]];

	return rows;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int number =  [msgList count] + 1;
	return number;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0)
	{
		[UIAdapterUtil removeBackground:cell];
		return;
	}
	
	int section = indexPath.section;
	id _id = [msgList objectAtIndex:section-1];
	if([_id isKindOfClass:[ConvRecord class]])
	{
		[UIAdapterUtil removeBackground:cell];
	}
    else
    {
        if (IOS7_OR_LATER)
        {
            [UIAdapterUtil removeBackground:cell];
            [UIAdapterUtil customCellBackground:tableView andCell:cell andIndexPath:indexPath];
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	[LogUtil debug:[NSString stringWithFormat:@"%s,section is %d",__FUNCTION__,indexPath.section]];
	//		add by shisp第一行显示为加载提示框
	if(indexPath.section == 0)
	{
		UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
		[cell addSubview:loadingIndic];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	
	int section = indexPath.section;
	int row = indexPath.row;
	

	id _id = [msgList objectAtIndex:indexPath.section-1];
	if([_id isKindOfClass:[ConvRecord class]])
	{
		UITableViewCell *chatCell = [tableView dequeueReusableCellWithIdentifier:chatCellId];

		if(chatCell== nil)
		{
			chatCell = [talkSessionUtil tableViewCellWithReuseIdentifier:chatCellId];
		}

		ConvRecord *_convRecord = (ConvRecord*)_id;
		[talkSessionUtil setPropertyOfConvRecord:_convRecord];
		[talkSessionUtil configureCell:chatCell andConvRecord:_convRecord];
		
		//	头像
		[self processHeadImage:chatCell andConvRecord:_convRecord];
		
		
		//	状态按钮
		UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[chatCell.contentView viewWithTag:status_spinner_tag];
//		UIButton *failButton = (UIButton*)[cell.contentView viewWithTag:status_failBtn_tag];
		
		//如果是发送的消息，并且发送状态是上传成功后发送中或上传中，那么显示正在发送
		if(_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading))
		{
			[spinner startAnimating];
		}
		else
		{
			[spinner stopAnimating];
		}

		return chatCell;
	}
	else
	{
		UITableViewCell *msgCell;
		
		ServiceMessage *message = (ServiceMessage*)_id;
		ServiceMessageDetail *detailMsg = [message.detail objectAtIndex:row];

		if(message.detail.count == 1)
		{
			msgCell = [tableView dequeueReusableCellWithIdentifier:SingleMsgCellId];
			
			if(msgCell == nil)
			{
				msgCell = [PSMsgUtil singlePsMsgTableViewCellWithReuseIdentifier:SingleMsgCellId];
			}
			[PSMsgUtil  configureSinglePsMsgCell:msgCell andPSMsg:message];
		}
		else
		{		
			msgCell = [tableView dequeueReusableCellWithIdentifier:MsgCellId];
			
			if(msgCell == nil)
			{
				msgCell = [PSMsgUtil multiPsMsgTableViewCellWithReuseIdentifier:MsgCellId];
			}
			
			[PSMsgUtil configureMultiPsMsgCell:msgCell andPSMsgDtl:detailMsg];
		}

		UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[msgCell.contentView viewWithTag:ps_spinner_tag];
		
		if(!detailMsg.isPicExists)
		{
//			异步下载图片
			if(!detailMsg.isPicDownloading)
			{
				detailMsg.isPicDownloading = YES;
				[self autoDownloadPic:msgCell andDetailMsg:detailMsg];
			}
			else
			{
				[spinner startAnimating];				
			}
		}
		else
		{
			[spinner stopAnimating];
		}
		
		return msgCell;
	}
}
#pragma mark 点击头像查看用户资料
-(void)processHeadImage:(UITableViewCell*)cell andConvRecord:(ConvRecord*)_convRecord
{
	int msgFlag = _convRecord.msg_flag;
	int serviceId = _convRecord.conv_id.intValue;
	
	UIImage *image;
	if(msgFlag == send_msg)
	{
//		取头像
		NSString *picPath = [StringUtil getLogoFilePathBy:_conn.userId andLogo:_conn.emp_logo];
		image = [UIImage imageWithContentsOfFile:picPath];
		if(!image)
		{
//			没有取到，去查询数据库
			Emp *curUser = [ [eCloudDAO getDatabase] getEmpInfo:_conn.userId];
			picPath = [StringUtil getLogoFilePathBy:_conn.userId andLogo:curUser.emp_logo];
			image = [UIImage imageWithContentsOfFile:picPath];
			if(image == nil)
			{
//				设置默认头像
				if (curUser.emp_sex==0)
				{//女
					image =[UIImage imageNamed:@"female.png"];
				}else
				{
					image =[UIImage imageNamed:@"male.png"];
				}
			}
		}
	}
	else
	{
		image = [PSUtil getServiceLogo:self.serviceModel];
		UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:head_empName_tag];
		nameLabel.text = self.serviceModel.serviceName;
	}
	UIImageView *headView = (UIImageView*)[cell.contentView viewWithTag:head_tag];
	headView.image = image;
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewUserInfo:)];
	[headView addGestureRecognizer:singleTap];
	[singleTap release];
}

#pragma mark 查看用户资料
-(void)viewUserInfo:(UITapGestureRecognizer *)gesture
{
	CGPoint p = [gesture locationInView:msgTable];
	NSIndexPath *indexPath = [msgTable indexPathForRowAtPoint:p];
	ConvRecord *_convRecord = [msgList objectAtIndex:indexPath.section-1];
	if(_convRecord.msg_flag == send_msg)
	{
		//		打开用户自己的资料
		userInfoViewController *userInfo = [[userInfoViewController alloc]init];
		userInfo.tagType=1;
//		userInfo.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:userInfo animated:YES];
		[userInfo release];
	}
	else
	{
		[self viewServiceInfo:nil];
	}
}

-(void)autoDownloadPic:(UITableViewCell *)cell andDetailMsg:(ServiceMessageDetail*)detailMsg
{
	UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:ps_spinner_tag];
	[spinner startAnimating];
	dispatch_queue_t queue;
	queue = dispatch_queue_create("download ps detail msg pic", NULL);
	dispatch_async(queue, ^{
		NSURL *url = [NSURL URLWithString:[StringUtil trimString:detailMsg.msgUrl]];
		NSData *imageData = [NSData dataWithContentsOfURL:url];
		UIImage *image = [UIImage imageWithData:imageData];
		if(detailMsg.row == 0)
		{//大图尺寸裁剪
			image = [image imageByScalingAndCroppingForSize:CGSizeMake(max_content_width, ps_big_pic_height)];
		}
		else
		{//按照正方形裁剪
			image = [image imageByScalingAndCroppingForSize:CGSizeMake(100, 100)];
		}
		
		
		if (UIImagePNGRepresentation(image) == nil)
		{
            imageData = UIImageJPEGRepresentation(image, 1);
        } else
		{
            imageData = UIImagePNGRepresentation(image);
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			[spinner stopAnimating];
			detailMsg.isPicDownloading = NO;
			if (image!=nil)
			{				
				NSString *picpath = [PSMsgUtil getDtlImgPath:detailMsg];
				BOOL success= [imageData writeToFile:picpath atomically:YES];
				if(!success)
				{
					NSLog(@"推送消息明细对应图片保存失败");
				}
				else
				{
					for(int i = msgList.count-1;i>=0;i--)
					{
						id _id = [msgList objectAtIndex:i];
						if([_id isKindOfClass:[ServiceMessage class]])
						{
							ServiceMessage *message = (ServiceMessage*)_id;
							if(message.msgId == detailMsg.serviceMsgId)
							{
//								[LogUtil debug:[NSString stringWithFormat:@"%s,download ok row is %d,section is %d",__FUNCTION__,detailMsg.row,i]];

								NSIndexPath *indexPath = [NSIndexPath indexPathForRow:detailMsg.row inSection:i+1];
								[msgTable beginUpdates];
								[msgTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
								[msgTable endUpdates];
							}
						}
					}
				}
			}
		});
	});
	

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return 0;
	
	id _id = [msgList objectAtIndex:section-1];
	if([_id isKindOfClass:[ServiceMessage class]])
	{
		return 30;
	}
	return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return nil;
	
	id _id = [msgList objectAtIndex:section-1];
	if([_id isKindOfClass:[ServiceMessage class]])
	{
		UITableViewCell *headerCell;
//		如果是
		if (IOS_VERSION_BEFORE_6)
		{
			headerCell = [PSMsgUtil headerViewWithReuseIdentifier:headerCellId];
		}
		else
		{
			 headerCell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerCellId];
			if(headerCell == nil)
			{
				headerCell = [PSMsgUtil headerViewWithReuseIdentifier:headerCellId];
			}
		}

		[PSMsgUtil configureHeaderView:headerCell andPSMsg:(ServiceMessage*)_id];
		return headerCell.contentView;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	int section = indexPath.section;
	int row = indexPath.row;
	if(section > 0)
	{
		id _id = [msgList objectAtIndex:section-1];
		if([_id isKindOfClass:[ServiceMessage class]])
		{
			ServiceMessage *message = (ServiceMessage*)_id;
			ServiceMessageDetail *dtlMessage = [message.detail objectAtIndex:row];
			if(dtlMessage.msgLink && dtlMessage.msgLink.length > 0)
			{
				[self openWebUrl:[StringUtil trimString:dtlMessage.msgLink]];
			}
		}
	}
}

#pragma mark 获取历史记录，加载历史记录
- (void)getHistoryRecord
{
	//	总数量
	totalCount = [_psDAO getServiceMsgCountByServiceId:self.serviceModel.serviceId] ;
	//已经加载数量
	loadCount = msgList.count;
	
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
//	NSLog(@"%s,totalCount is %d,loadCount is %d",__FUNCTION__,totalCount,loadCount);
//	NSLog(@"get history record limit is %d,offset is %d",limit,offset);
	@autoreleasepool
	{
		 NSArray *historyList = [_psDAO getServiceMessageByServiceId:self.serviceModel.serviceId andLimit:limit andOffset:offset];
		int count=[historyList count];
		
		//	把历史消息记录添加到现有的数据列表里
		for (int i=count-1; i>=0; i--)
		{
			ServiceMessage *message =[historyList objectAtIndex:i];
			[msgList insertObject:message atIndex:0];
		}
		
		//	设置时间是否显示，设置一些属性，例如消息对应的图片是否存在
		for(int i = 0;i<historyList.count;i++)
		{
			id _id = [historyList objectAtIndex:i];
			if([_id isKindOfClass:[ConvRecord class]])
			{
				[self setTimeDisplay:((ConvRecord*)_id) andIndex:i];
			}
		}
	}
	
	
    float oldh=msgTable.contentSize.height;
	[msgTable reloadData];
	
	[self hideLoadingCell];
	
    float newh=msgTable.contentSize.height;
	//	NSLog(@"--new-offset--%0.0f---cont-- %0.0f  ---left- %0.0f",self.chatTableView.contentOffset.y,self.chatTableView.contentSize.height,newh-oldh);
	msgTable.contentOffset=CGPointMake(0, newh-oldh-20);
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

-(void)hideLoadingCell
{
	loadingIndic.hidden = YES;
	[loadingIndic stopAnimating];
	isLoading = false;
}

#pragma mark 确定本条记录是否显示时间
-(void)setTimeDisplay:(ConvRecord*)record  andIndex:(int)_index
{
	if(_index == 0)
	{
		record.isTimeDisplay = true;
		return;
	}
	
	bool isDisplay = true;
	
	int lastDisplayMsgIndex = [self getLastDisplayTimeMsg:_index];
	
	id _id = [msgList objectAtIndex:lastDisplayMsgIndex];
	
	if([_id isKindOfClass:[ServiceMessage class]])
	{
		record.isTimeDisplay = true;
		return;
	}
	
	//			如果当前的时间和第一条的时间在3分钟之内，那么就不用显示,有两种情况，一个是小于msg_time_sec,一个是小于0，防止下面消息的显示时间比上面消息的显示时间早的情况 fabs(
	NSTimeInterval _diff = record.msg_time.intValue - ((ConvRecord*)_id).msg_time.intValue;
	
	if(_diff < 0 || (_diff >= 0 && _diff <= msg_time_sec))
	{
		isDisplay = false;
	}
	record.isTimeDisplay = isDisplay;
}

#pragma mark 找到最近的一条显示时间的消息，从_index开始向前找
-(int)getLastDisplayTimeMsg:(int)_index
{
	for(int i= _index;i>=0;i--)
	{
		id _id = [msgList objectAtIndex:i];
		if([_id isKindOfClass:[ServiceMessage class]])
		{
			return i;
		}
		else
		{
			if(((ConvRecord*)_id).isTimeDisplay)
			{
				return i;
			}
		}
	}
	return 0;
}

#pragma mark 打开超链接
-(void)openWebUrl:(NSString *)urlStr
{
    openWebViewController *openweb=[[openWebViewController alloc]init];
	openweb.customTitle = self.serviceModel.serviceName;
    openweb.urlstr=urlStr;
	openweb.fromtype=1;
	openweb.needUserInfo = YES;
    [self.navigationController pushViewController:openweb animated:YES];
    [openweb release];
}

#pragma mark - 键盘事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
   
    //[self autoMovekeyBoard:keyboardRect.size.height];
    NSString *heightstr=[NSString stringWithFormat:@"%0.0f",keyboardRect.size.height];
    [self performSelector:@selector(latershow:) withObject:heightstr afterDelay:0.2];
}
-(void)latershow:(NSString *)keyboardRect
{
	[self autoMovekeyBoard:keyboardRect.floatValue];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	//     NSLog(@"---keyboardWillHide");
//    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];

    [self autoMovekeyBoard:0];
}

#pragma mark 键盘的处理
-(void) autoMovekeyBoard: (float) h{
	keyboardH = h;
    if (h>0)
	{
		tableBackGroudButton.hidden=NO;
    }
	else
    {
		tableBackGroudButton.hidden=YES;
    }
	
	float footerY = self.view.frame.size.height - (h + origin_footer_h + (messageTextField.frame.size.height-34));
	footerView.frame = CGRectMake(0.0f, footerY, 320.0f, (origin_footer_h + (messageTextField.frame.size.height-34)));

	int tableH = self.view.frame.size.height - h - footerView.frame.size.height;
	msgTable.frame=CGRectMake(0, 0, 320,tableH);
	if([msgList count] > 0)
	{
		[self scrollToEnd];
	}
}

#pragma mark 点击让键盘消失事件
-(void)tableBackGroudAction:(id)sender
{
    tableBackGroudButton.hidden=YES;
    
    if(messageTextField.isFirstResponder)
    {
		[messageTextField resignFirstResponder];
    }
//	else
//    {
//		[self autoMovekeyBoard:0];
//    }
}

#pragma mark 随着用户输入的文字变化文本框大小
- (void)textViewDidChange:(UITextView *)textView
{
	//	NSLog(@"%s,%.0f",__FUNCTION__,footerView.frame.origin.y);
	
    if (textView.text==nil||textView.text.length==0) {
        textView.text=@" ";
    }
	
    CGSize size = [[textView text] sizeWithFont:[textView font]];
    // 2. 取出文字的高度
    int fontHeight = size.height;
    
    //3. 计算行数
    int rowNumber = [talkSessionUtil measureHeightOfUITextView:textView]/fontHeight;
	
//	[LogUtil debug:[NSString stringWithFormat:@"fontHeight is %d, textView.contentSize.height is %.0f",fontHeight,textView.contentSize.height]];
	
//	小于4行，需要进行变化
	if(rowNumber <= 3)
	{
		float footerH = origin_footer_h + (rowNumber-1)*fontHeight;
		int footerY = self.view.frame.size.height - footerH - keyboardH;
		footerView.frame = CGRectMake(0, footerY, 320, footerH);
		float newTextViewH = origin_textfield_h + (rowNumber-1)*fontHeight;
        if (self.hasListMenu) {
            messageTextField.frame = CGRectMake(10+50.0, (footerH - newTextViewH)/2, 180.0, newTextViewH);
        }
        else{
            messageTextField.frame = CGRectMake(10, (footerH - newTextViewH)/2, origin_textfield_w, newTextViewH);
        }
        
		subfooterView.frame = CGRectMake(0, newTextViewH-34.0, 320, footerH);
		
//		CGRect sendBtnFrame = sendButton.frame;
//		sendBtnFrame.origin.y = (footerH - send_msg_button_h)/2;
//		sendButton.frame =sendBtnFrame;
		
        CGRect rect = linebreakView.frame;
        rect.size.height += (rowNumber-1)*fontHeight;
        linebreakView.frame = rect;
        
		CGRect tableFrame = msgTable.frame;
		tableFrame.size.height = self.view.frame.size.height - keyboardH - footerView.frame.size.height;
		msgTable.frame = tableFrame;
	}
    else if (rowNumber>3){
        float footerH = origin_footer_h + 2*fontHeight;
		int footerY = self.view.frame.size.height - footerH - keyboardH;
		footerView.frame = CGRectMake(0, footerY, 320, footerH);
		float newTextViewH = origin_textfield_h + 2*fontHeight;
        if (self.hasListMenu) {
            messageTextField.frame = CGRectMake(10+50.0, (footerH - newTextViewH)/2, 180.0, newTextViewH);
        }
        else{
            messageTextField.frame = CGRectMake(10, (footerH - newTextViewH)/2, origin_textfield_w, newTextViewH);
        }
		subfooterView.frame = CGRectMake(0, newTextViewH-34.0, 320, footerH);
		
        //		CGRect sendBtnFrame = sendButton.frame;
        //		sendBtnFrame.origin.y = (footerH - send_msg_button_h)/2;
        //		sendButton.frame =sendBtnFrame;
		
        CGRect rect = linebreakView.frame;
        rect.size.height += (rowNumber-1)*fontHeight;
        linebreakView.frame = rect;
        
		CGRect tableFrame = msgTable.frame;
		tableFrame.size.height = self.view.frame.size.height - keyboardH - footerView.frame.size.height;
		msgTable.frame = tableFrame;
    }
	
    if ([textView.text isEqualToString:@" "]) {
        textView.text=@"";
    }
}

#pragma mark - UITextViewDelegate 协议方法
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self sendPSMessage:sendButton];
        return NO;
    }
    return YES;
}


#pragma mark ==========长按功能===========
//-(void)tapCell:(UITapGestureRecognizer*)gestureRecognizer
//{
//	CGPoint p = [gestureRecognizer locationInView:msgTable];
//	NSIndexPath *indexPath = [msgTable indexPathForRowAtPoint:p];
//	UITableViewCell *cell = [msgTable cellForRowAtIndexPath:indexPath];
//	if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
//	{
//		cell.backgroundColor = [UIColor orangeColor];
//	}
//	else if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
//	{
//		cell.backgroundColor = [UIColor clearColor];
//	}
//}
- (void) longPressAction:(UILongPressGestureRecognizer *)gestureRecognizer
{
 	if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
	{
		CGPoint p = [gestureRecognizer locationInView:msgTable];
		[self prepareToShowMenu:p];
    }
}

-(void)prepareToShowMenu:(CGPoint)p
{
	NSIndexPath *indexPath = [msgTable indexPathForRowAtPoint:p];
    NSString *pointY=[NSString stringWithFormat:@"%0.0f",p.y];
	if(indexPath)
	{
		if(indexPath.section == 0) return;
		
		self.editIndexPath = nil;
		//		点击位置对应的记录下标
		int _section = indexPath.section;
		id _id = [msgList objectAtIndex:indexPath.section - 1];
//		if([_id isKindOfClass:[ServiceMessage class]] || [_id isKindOfClass:[ServiceMessageDetail class]])
//		{
			self.editIndexPath = indexPath;
			UITableViewCell *cell = [msgTable cellForRowAtIndexPath:indexPath];
			[cell becomeFirstResponder];
			[self performSelector:@selector(showMenu:)withObject:[NSDictionary dictionaryWithObjectsAndKeys:cell,@"LONG_CLICK_CELL",pointY,@"pointY", nil] afterDelay:0.05f];
//		}
	}
}

#pragma mark  长按或双击可以复制消息文本功能
- (void)showMenu:(id)dic
{
	tableBackGroudButton.hidden = NO;
	
 	UITableViewCell *longClickCell =  (UITableViewCell*)[(NSDictionary *)dic objectForKey:@"LONG_CLICK_CELL"];
//	显示菜单前，设置长按效果

	if(self.editIndexPath)
	{
		int section = self.editIndexPath.section;
		
		id _id = [msgList objectAtIndex:section - 1];
		if([_id isKindOfClass:[ConvRecord class]])
		{
			ConvRecord *editRecord = (ConvRecord*)_id;
			UIImageView *bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_send_tag];
			if(bubbleView.hidden)
			{
				bubbleView = (UIImageView*)[longClickCell.contentView viewWithTag:bubble_rcv_tag];
			}
				
			NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
			float copyX;
			if(editRecord.msg_flag == rcv_msg)
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
		else
		{
			float r = 233/255.0;
			UIColor *_color = [UIColor colorWithRed:r green:r blue:r alpha:1];
			longClickCell.backgroundColor = _color;

			ServiceMessage *_serviceMessage = [msgList objectAtIndex:section-1];
			for(int row = 0;row < _serviceMessage.detail.count;row++)
			{
				NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:row inSection:section];
				if(row != self.editIndexPath.row)
				{
					[[msgTable cellForRowAtIndexPath:_indexPath] setBackgroundColor:_color];
				}
			}
			float menuX = 160;
			
			NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
			int menuY=[pointY intValue]-longClickCell.frame.origin.y;
			UIMenuController * menu = [UIMenuController sharedMenuController];
			[menu setTargetRect: CGRectMake(menuX , menuY, 1, 1) inView: longClickCell];
			[menu setMenuVisible: YES animated: YES];
		}
	}	
}

#pragma mark 目前只提供删除功能
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;
	if(self.editIndexPath)
	{
		//	是否允许copy
		BOOL canCopy = NO;
		id _id = [msgList objectAtIndex:self.editIndexPath.section-1];
		if([_id isKindOfClass:[ConvRecord class]])
		{
			canCopy = YES;
		}
		if(action == @selector(delete:))
		{
			retValue = YES;
		}
		else if(action == @selector(copy:))
		{
			retValue = canCopy;
		}
	}
	
	return retValue;
}

-(void)menuDisplay
{
	if(self.editIndexPath)
	{
		id _id = [msgList objectAtIndex:self.editIndexPath.section-1];
		if([_id isKindOfClass:[ConvRecord class]])
		{
			UITableViewCell *cell = [msgTable cellForRowAtIndexPath:self.editIndexPath];
			UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
			if(bubbleView.hidden)
			{
				bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
			}
			bubbleView.highlighted = YES;
		}
	}
}
-(void)menuHide
{
	if(self.editIndexPath)
	{
		id _id = [msgList objectAtIndex:self.editIndexPath.section - 1];
		if([_id isKindOfClass:[ConvRecord class]])
		{
			UITableViewCell *cell = [msgTable cellForRowAtIndexPath:self.editIndexPath];
			UIImageView *bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
			if(bubbleView.hidden)
			{
				bubbleView = (UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
			}
			bubbleView.highlighted = NO;
		}
		else
		{
			//		弹出菜单隐藏的时候，设置cell background color 为 clearcolor
			UITableViewCell *cell = [msgTable cellForRowAtIndexPath:self.editIndexPath];
            float r = 247/255.0;
            UIColor *_color = [UIColor colorWithRed:r green:r blue:r alpha:1];
            cell.backgroundColor = _color;

			int section = self.editIndexPath.section;
			ServiceMessage *_serviceMessage = [msgList objectAtIndex:section - 1];
			
			for(int row = 0;row < _serviceMessage.detail.count;row++)
			{
				NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:row inSection:section];
				if(row != self.editIndexPath.row)
				{
					[[msgTable cellForRowAtIndexPath:_indexPath] setBackgroundColor:_color];
				}
			}
		}
		
		self.editIndexPath = nil;
	}
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)delete:(id)sender
{
	if(self.editIndexPath)
	{
		id _id = [msgList objectAtIndex:self.editIndexPath.section - 1];
		if([_id isKindOfClass:[ConvRecord class]])
		{
			ServiceMessage *serviceMessage = [[ServiceMessage alloc]init];
			serviceMessage.msgType = ps_msg_type_text;
			serviceMessage.msgId = ((ConvRecord*)_id).msgId;
			[_psDAO deleteServiceMessage:serviceMessage];
		}
		else
		{
			ServiceMessage *serviceMessage = [msgList objectAtIndex:(self.editIndexPath.section - 1)];
			[_psDAO deleteServiceMessage:serviceMessage];
		}

		[msgList removeObjectAtIndex:(self.editIndexPath.section - 1)];
		[msgTable beginUpdates];
		[msgTable deleteSections:[NSIndexSet indexSetWithIndex:self.editIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
		[msgTable endUpdates];
		self.editIndexPath = nil;
	}
}
- (void)copy:(id)sender
{
	if(self.editIndexPath)
	{
		ConvRecord *_convRecord = [msgList objectAtIndex:self.editIndexPath.section - 1];
		if(_convRecord.msg_type == ps_msg_type_text)
		{
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			[pasteboard setString:_convRecord.msg_body];
		}
	}
}

-(void)openWebUrlOfMsg:(NSNotification *)notification
{
	openWebViewController *openweb=[[openWebViewController alloc]init];
	openweb.title = self.serviceModel.serviceName;
    openweb.urlstr=notification.object;
	openweb.fromtype=1;
    [self.navigationController pushViewController:openweb animated:YES];
    [openweb release];
}
@end
