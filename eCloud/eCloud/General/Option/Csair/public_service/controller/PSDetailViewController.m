
#import "PSDetailViewController.h"
#import "PSUtil.h"
#import "LogUtil.h"
#import "PSBackButtonUtil.h"
#import "PSMsgDtlViewController.h"
#import "PublicServiceDAO.h"
#import "UIAdapterUtil.h"
#import "talkSessionViewController.h"
#import "ServiceModel.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"
#import "eCloudDefine.h"

@interface PSDetailViewController ()

@end

//常量的定义
//图片的frame
#define ps_logo_x (10)
#define ps_logo_y (10)
#define ps_logo_size (60)

//图片和名字的间隔
#define logo_name_space (20)

//名称的frame
#define ps_name_x (ps_logo_x + ps_logo_size + logo_name_space)
#define ps_name_y (20)
#define ps_name_width (SCREEN_WIDTH -ps_logo_x * 2 - logo_name_space -ps_logo_size)
#define ps_name_height (20)

//名称字体
#define ps_name_font_size 18

//包含图片和名称的view的frame
#define header_x (0)
#define header_y (0)
#define header_width (SCREEN_WIDTH)
#define header_height (ps_logo_size + ps_logo_y * 2)

//ps详细资料

//功能介绍title和内容之间的间隔
#define title_content_space (10)

//功能介绍 title frame
#define ps_desc_title_x (10)
#define ps_desc_title_y (10)
#define ps_desc_title_width ((SCREEN_WIDTH - 20 - ps_desc_title_x * 2 - title_content_space) * 0.3)

//功能接收title font 和 color
#define ps_desc_title_font_size (17)

//功能介绍frame
#define ps_desc_x (ps_desc_title_x + ps_desc_title_width + title_content_space)
#define ps_desc_y (ps_desc_title_y)
#define ps_desc_width ((SCREEN_WIDTH - 20 - ps_desc_title_x * 2 - title_content_space) * 0.7 )

//行高度
#define row_height (45)

//接收消息 title宽度
#define rcv_msg_title_width (SCREEN_WIDTH - 120)

//接收消息 开关x
#define rcv_msg_switch_x (SCREEN_WIDTH - 100)


@implementation PSDetailViewController
{
	PublicServiceDAO *db;
}

@synthesize serviceId;
@synthesize serviceModel;

-(void)dealloc
{
	self.serviceModel = nil;
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
	db = [PublicServiceDAO getDatabase];
	
//	self.view.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
	self.title = [StringUtil getLocalizableString:@"detail_info"];
	
	CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44);
	
	UITableView *tableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.backgroundView = nil;
//	tableView.backgroundColor =  [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];

	[self.view addSubview:tableView];
	[tableView release];

	[self setLeftBtn];
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
	[self.navigationController setNavigationBarHidden:NO animated:YES];

	[self getServiceModel];
}

-(void)getServiceModel
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	self.serviceModel = [db getServiceByServiceId:self.serviceId];
	[pool release];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//	1 功能介绍
	//	2 是否接收消息
	//	3 查看消息
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
	
	int section = indexPath.section;
	switch (section) {
		case 0:
		{
//			功能介绍
			[self configPSDescView:cell];
		}
			break;
		case 1:
		{
//			接收消息
			[self configRcvMsgView:cell];
			
		}
			break;
		case 2:
		{
//			查看消息
			[self configViewMsgView:cell];
		}
			break;
			
		default:
			break;
	}
	return cell;
}

#pragma mark 功能介绍View
-(void)configPSDescView:(UITableViewCell*)cell
{
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

//	功能介绍标题
	NSString *titleStr = [StringUtil getLocalizableString:@"ps_desc_title"];
	CGSize size = [titleStr sizeWithFont:[UIFont systemFontOfSize:ps_desc_title_font_size] constrainedToSize:CGSizeMake(ps_desc_title_width,10000.0f) lineBreakMode:UILineBreakModeWordWrap];
//	[LogUtil debug:[NSString stringWithFormat:@"title height is %.0f",size.height]];
	
	CGRect rect = CGRectMake(ps_desc_title_x, ps_desc_title_y, ps_desc_width, size.height);
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:rect];
	titleLabel.font = [UIFont systemFontOfSize:ps_desc_title_font_size];
	titleLabel.textColor = [UIColor grayColor];
	titleLabel.text = titleStr;
	titleLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];
	
//	功能介绍
	NSString *descStr = self.serviceModel.serviceDesc;
	size = [descStr sizeWithFont:[UIFont systemFontOfSize:ps_desc_title_font_size] constrainedToSize:CGSizeMake(SCREEN_WIDTH-ps_desc_x-10,10000.0f)lineBreakMode:UILineBreakModeWordWrap];
	
	rect = CGRectMake(ps_desc_x, ps_desc_y, SCREEN_WIDTH-ps_desc_x-10, size.height);
	UILabel *descLabel = [[UILabel alloc]initWithFrame:rect];
	descLabel.font = [UIFont systemFontOfSize:ps_desc_title_font_size];
	descLabel.text = descStr;
	descLabel.numberOfLines = 0;
	descLabel.backgroundColor = [UIColor clearColor];
	
	[cell.contentView addSubview:descLabel];
	[descLabel release];
	
}

#pragma mark 是否接收消息View
-(void)configRcvMsgView:(UITableViewCell*)cell
{
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

//	接收消息label
	NSString *rcvMsgStr = [StringUtil getLocalizableString:@"ps_rcv_msg"];
	CGSize size = [rcvMsgStr sizeWithFont: [UIFont systemFontOfSize:ps_desc_title_font_size]];
	
	CGRect rect = CGRectMake(ps_desc_title_x, ps_desc_title_y, rcv_msg_title_width, size.height);
	
	UILabel *rcvMsgLabel = [[UILabel alloc]initWithFrame:rect];
	rcvMsgLabel.font = [UIFont systemFontOfSize:ps_desc_title_font_size];
	rcvMsgLabel.text = rcvMsgStr;
	rcvMsgLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:rcvMsgLabel];
	[rcvMsgLabel release];
	
//	接收消息开关
	rect = CGRectMake(rcv_msg_switch_x,ps_desc_title_y,0,0);
	UISwitch *rcvMsgSwitch = [[UISwitch alloc] initWithFrame:rect];
    [UIAdapterUtil positionSwitch:rcvMsgSwitch ofCell:cell];
	if(serviceModel.rcvMsgFlag == 0)
	{
		[rcvMsgSwitch setOn:NO];
	}
	else
	{
		[rcvMsgSwitch setOn:YES];
	}
//	[rcvMsgSwitch addTarget:self action:@selector(switchSoundAction:) forControlEvents:UIControlEventValueChanged];
	[cell addSubview:rcvMsgSwitch];
	[rcvMsgSwitch release];
}

#pragma mark 查看消息View
-(void)configViewMsgView:(UITableViewCell *)cell
{
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

//	查看消息label
	NSString *viewMsgStr = [StringUtil getLocalizableString:@"ps_view_msg"];
	CGSize size = [viewMsgStr sizeWithFont:[UIFont systemFontOfSize:ps_desc_title_font_size]];
	CGRect rect = CGRectMake(ps_desc_title_x, ps_desc_title_y, size.width, size.height);
	UILabel *viewMsgLabel = [[UILabel alloc]initWithFrame:rect];
	viewMsgLabel.font = [UIFont systemFontOfSize:ps_desc_title_font_size];
	viewMsgLabel.text = viewMsgStr;
	viewMsgLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:viewMsgLabel];
	[viewMsgLabel release];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	功能介绍，至少为2行，如果内容较多，可显示更多行
//	其它都是一行
	
	if(indexPath.section == 0)
	{
		NSString *descStr = self.serviceModel.serviceDesc;
		CGSize size = [descStr sizeWithFont:[UIFont systemFontOfSize:ps_desc_title_font_size] constrainedToSize:CGSizeMake(ps_desc_width,10000.0f)lineBreakMode:UILineBreakModeWordWrap] ;
		
		float h = (size.height + 2 * ps_desc_y);
		if(h < row_height)
		{
			return row_height;
		}
		return h;
	}
	
	return row_height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	//	功能介绍 上面 显示 logo和name，作为headerView显示
	if(section == 0)
		return header_height;
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//	取消关注预留
	return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section == 0)
	{
		CGRect rect = CGRectMake(header_x, header_y, header_width, header_height);
		UIView *headerView = [[[UIView alloc]initWithFrame:rect]autorelease];
		
		rect = CGRectMake(ps_logo_x, ps_logo_y, ps_logo_size, ps_logo_size);
		UIImageView *logoView = [[UIImageView alloc]initWithFrame:rect];
		logoView.image = [PSUtil getServiceLogo:self.serviceModel];
		[headerView addSubview:logoView];
		[logoView release];
		
		rect = CGRectMake(ps_name_x, ps_name_y, ps_name_width, ps_name_height);
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:rect];
		nameLabel.font = [UIFont boldSystemFontOfSize:ps_name_font_size];
		nameLabel.text = self.serviceModel.serviceName;
		nameLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:nameLabel];
		[nameLabel release];
		
		return headerView;
	}
	return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
//	取消关注预留
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 2)
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		for(UIViewController *_controller in self.navigationController.viewControllers)
		{
			if([_controller isKindOfClass:[talkSessionViewController class]])
			{
				[self.navigationController popToViewController:_controller animated:YES];
				return;
			}
		}
		
		
//		PSMsgDtlViewController *controller = [PSMsgDtlViewController getPSMsgDtlViewController];
//		controller.needRefresh = YES;
////		controller.hidesBottomBarWhenPushed = YES;
//		controller.serviceModel = serviceModel;
//		[self.navigationController pushViewController:controller animated:YES];
        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
        talkSession.serviceModel = serviceModel;
        talkSession.needUpdateTag = 1;
        talkSession.talkType = publicServiceMsgDtlConvType;
        [self.navigationController pushViewController:talkSession animated:YES];

//		NSLog(@"view message");
	}
}


@end
