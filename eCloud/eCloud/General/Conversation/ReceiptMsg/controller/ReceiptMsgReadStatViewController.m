// 显示一呼百应消息的已读统计

#import "ReceiptMsgReadStatViewController.h"
#import "ReceiptDAO.h"
#import "PSBackButtonUtil.h"
#import "ImageUtil.h"
#import "ReceiptMsgReadStatUtil.h"
#import "UIAdapterUtil.h"
#import "ConvRecord.h"
#import "SliderSwitch.h"
#import "eCloudDefine.h"


@interface ReceiptMsgReadStatViewController ()<UITableViewDataSource,UITableViewDelegate,SliderSwitchDelegate>

@end

@implementation ReceiptMsgReadStatViewController
{
	UITableView *_tableView;
	
	ReceiptDAO *db;
	
	SliderSwitch *slideSwitch;
}

@synthesize msgId;
@synthesize convRecord;
@synthesize readItemArray;
@synthesize unReadItemArray;

- (void)dealloc
{
    self.readItemArray = nil;
    self.unReadItemArray = nil;
    self.convRecord = nil;
    
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
    
    [UIAdapterUtil processController:self];
    
	db = [ReceiptDAO getDataBase];
	
	CGRect _frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
	slideSwitch=[[SliderSwitch alloc]initWithFrame:_frame];
    [slideSwitch setFrameHorizontal:_frame numberOfFields:2 withCornerRadius:0.0];
    slideSwitch.delegate=self;

	[slideSwitch setSwitchFrameColor:[UIColor grayColor]];
    [slideSwitch setFrameBackgroundColor:[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1]];
    [slideSwitch setTextColor:[UIColor blackColor]];
    [slideSwitch setSwitchBorderWidth:0];
    
    [self.view addSubview:slideSwitch];
	[slideSwitch release];
	
    
	_frame = CGRectMake(0, slideSwitch.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - 44 - slideSwitch.frame.size.height);
	_tableView = [[UITableView alloc]initWithFrame:_frame];
    [UIAdapterUtil setPropertyOfTableView:_tableView];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];
	[_tableView release];
	
    blueLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 43, self.view.frame.size.width/2, 2)];
    blueLabel.backgroundColor=[UIColor blueColor];
    [self.view addSubview:blueLabel];
    
    NSString *tempStr = @"receipt_msg_read_stat_0";
    if (convRecord.isHuizhiMsg) {
        tempStr = @"receipt_msg_read_stat_1";
    }
    
	self.title = [StringUtil getLocalizableString:tempStr];
	
	[self setLeftBtn];
}
-(void)refreshData
{
	self.readItemArray = [NSArray arrayWithArray:[db getReceiptUser:self.msgId andReadFlag:1]];
	self.unReadItemArray = [NSArray arrayWithArray:[db getReceiptUser:self.msgId andReadFlag:0]];
	
	//	已读
	int readCount = [self.readItemArray count];
	//未读
	int unReadCount = [self.unReadItemArray count];

	NSString *temp = [NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"receipt_msg_read"],readCount];
	[slideSwitch setText:temp forTextIndex:1];
	
	temp = [NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"receipt_msg_unread"],unReadCount];
	[slideSwitch setText:temp forTextIndex:2];
	
	[_tableView reloadData];
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}
-(void)backButtonPressed:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshData];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
}
-(void)handleCmd:(NSNotification*)notification
{
	eCloudNotification	*cmd					=	(eCloudNotification *)[notification object];
	switch (cmd.cmdId)
	{
		case msg_read_notice:
		{
			NSDictionary *dic = cmd.info;
			NSString *msgId = [dic objectForKey:@"MSG_ID"];
			if(msgId.intValue == self.msgId)
			{
				[self refreshData];
			}
		}
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(slideSwitch.selectedIndex == 0)
	{
		return [self.readItemArray count];
	}
	else
	{
		return [self.unReadItemArray count];
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"cellID";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell == nil)
	{
		cell = [ReceiptMsgReadStatUtil cellWithReuseIdentifier:cellID];
	}
	Emp *_emp;
	BOOL isRead = NO;
	if(slideSwitch.selectedIndex == 0)
	{
		isRead = YES;
		_emp = [self.readItemArray objectAtIndex:indexPath.row];
	}
	else
	{
		_emp = [self.unReadItemArray objectAtIndex:indexPath.row];
	}
	[ReceiptMsgReadStatUtil configCell:cell andEmp:_emp andReadFlag:isRead];
		
	return cell;
}

-(void)slideView:(SliderSwitch *)slideswitch switchChangedAtIndex:(NSUInteger)index
{
    
    if (index==0) {
    blueLabel.frame=CGRectMake(0, 43, self.view.frame.size.width/2, 2);
    }else
    {
     blueLabel.frame=CGRectMake(self.view.frame.size.width/2, 43, self.view.frame.size.width/2, 2);
    }
	[_tableView reloadData];
}
@end
