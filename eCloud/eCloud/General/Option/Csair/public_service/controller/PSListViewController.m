//
//  PSListViewController.m
//  eCloud
// 服务号列表
//  Created by Shisp on 13-10-28.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "PSListViewController.h"
#import "PublicServiceDAO.h"
#import "ServiceModel.h"
#import "PSUtil.h"
#import "PSDetailViewController.h"
#import "PSMsgDtlViewController.h"
#import "PSBackButtonUtil.h"
#import "talkSessionViewController.h"

#import "UIAdapterUtil.h"
#import "eCloudDefine.h"

@interface PSListViewController ()

@end

#define logo_tag 100
#define name_tag 101
#define detail_tag 102
//图片大小
#define logo_size 40
//文字字体大小
#define font_size 17
//行高度
#define row_height 55
@implementation PSListViewController
{
	PublicServiceDAO *db;
}
@synthesize psList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
	self.psList = nil;
	[super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	db = [PublicServiceDAO getDatabase];

    [UIAdapterUtil setExtraCellLineHidden:self.tableView];
	self.title = [StringUtil getLocalizableString:@"public_service"];
	self.tableView.rowHeight = row_height;
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

	[self getPsList];
	
}
//查询所有服务号
-(void)getPsList
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    self.psList = [db getAllService:service_type_in_ps];
	[pool release];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.psList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
	{
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
//logo
		CGRect rect = CGRectMake(10,(row_height - logo_size)/2,logo_size,logo_size);
		UIImageView *logoView = [[UIImageView alloc]initWithFrame:rect];
		logoView.tag = logo_tag;
		[cell.contentView addSubview:logoView];
		[logoView release];
//		name
		rect = CGRectMake(10+logo_size + 10,0,200,row_height);
		UILabel *label = [[UILabel alloc]initWithFrame:rect];
		label.tag = name_tag;
		label.font = [UIFont systemFontOfSize:font_size];
		[cell.contentView addSubview:label];
		[label release];
		
//		详细资料按钮
		
        UIImage *detailImage = [StringUtil getImageByResName:@"detail.png"];

        UIImage *detailImageClick = [StringUtil getImageByResName:@"detail_click.png"];
		
		float ratio = detailImage.size.width / detailImage.size.height;
		
		float imageHeight = row_height;
		float imageWidth = ratio * row_height;
		
        // 0803 适配
		rect = CGRectMake(self.view.frame.size.width - imageWidth, 0, imageWidth, imageHeight);
		UIButton *detailButton=[[UIButton alloc]initWithFrame:rect];
		detailButton.tag = detail_tag;
		
		[detailButton setImage:detailImage forState:UIControlStateNormal];
		[detailButton setImage:detailImageClick forState:UIControlStateHighlighted];
		[detailButton setImage:detailImageClick forState:UIControlStateSelected];
		
        [detailButton addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:detailButton];
        [detailButton release];
	}
	
	ServiceModel *serviceModel = [self.psList objectAtIndex:indexPath.row];
	
	UIImageView *logoView = (UIImageView*)[cell.contentView viewWithTag:logo_tag];
	logoView.image = [PSUtil getServiceLogo:serviceModel];
	
	UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:name_tag];
	nameLabel.text = serviceModel.serviceName;
	
	UIButton *dtlBtn = (UIButton*)[cell.contentView viewWithTag:detail_tag];
	dtlBtn.titleLabel.text = [StringUtil getStringValue:serviceModel.serviceId];
	
	return cell;
}

-(void)detailAction:(id)sender
{
	UIButton *dtlBtn = (UIButton*)sender;
	int serviceId = dtlBtn.titleLabel.text.intValue;
	PSDetailViewController *_controller = [[PSDetailViewController alloc]init];
	_controller.serviceId = serviceId;
//	_controller.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:_controller animated:YES];
	[_controller release];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	ServiceModel *serviceModel = [self.psList objectAtIndex:indexPath.row];

//	PSMsgDtlViewController *controller = [PSMsgDtlViewController getPSMsgDtlViewController];
//	controller.needRefresh = YES;
////	controller.hidesBottomBarWhenPushed = YES;
//	controller.serviceModel = serviceModel;
//	[self.navigationController pushViewController:controller animated:YES];
    
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
//    int serviceId = [conv.conv_id intValue];
    
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.serviceModel = [db getServiceByServiceId:serviceModel.serviceId];
    talkSession.needUpdateTag = 1;
    talkSession.talkType = publicServiceMsgDtlConvType;
    [self.navigationController pushViewController:talkSession animated:YES];
}

@end
