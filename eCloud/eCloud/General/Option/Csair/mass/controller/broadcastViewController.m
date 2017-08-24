//
//  broadcastViewController.m
//  eCloud
//  这是之前给南航做的一呼万应的界面 deprecated
//  Created by  lyong on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "broadcastViewController.h"
#import "StringUtil.h"
#import "MessageView.h"
#import "MassDAO.h"
#import "massConversationObject.h"
#import "talkSessionViewController.h"
#import "NewMsgNotice.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"
#import "broadcastChooseMemberViewController.h"
#import "chooseForSepcialViewController.h"

@interface broadcastViewController ()
{
    UIView *tipView;
    MassDAO *massDAO;
    NSMutableArray *massArray;
    talkSessionViewController *talkSession;
}
@property(nonatomic,retain)UIView *tipView;
@property(nonatomic,retain)MassDAO *massDAO;
@property(nonatomic,retain)NSMutableArray *massArray;
@property(nonatomic,retain)talkSessionViewController *talkSession;
@end

@implementation broadcastViewController
@synthesize tipView;
@synthesize massDAO;
@synthesize massArray;
@synthesize talkSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleCmd:)
                                                name:CONVERSATION_NOTIFICATION
                                              object:nil];
    if (broadcastListTable!=nil) {//刷新
        self.massArray=[self.massDAO getAllMassConversation];
        if ([self.massArray count]==0) {
            self.tipView.hidden=NO;
            broadcastListTable.hidden=YES;
        }else
        {
            self.tipView.hidden=YES;
            broadcastListTable.hidden=NO;
            [broadcastListTable reloadData];
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    
    // add by toxicanty 0727
    [broadcastListTable setEditing:NO];
}

-(void)handleCmd:(NSNotification *)notification
{
	   eCloudNotification	*cmd=	(eCloudNotification *)[notification object];
		switch (cmd.cmdId) {
			case rev_msg://处理接收消息
            {
                // 通知内对象变为了字典
//                NewMsgNotice *_notice = notification.userInfo;
                NSDictionary *_userInfo = notification.userInfo;
                NewMsgNotice *_notice = [_userInfo valueForKey:@"msg_notice"];
                
                if(_notice.msgType == mass_reply_msg_type)
                {
                   self.massArray=[self.massDAO getAllMassConversation];
                    [broadcastListTable reloadData];
                }
			default:
				break;
		}
	 }
    
}

-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //适配ios7UIViewController的变化
    [UIAdapterUtil processController:self];
    
    self.massDAO = [MassDAO getDatabase];
    self.massArray=[self.massDAO getAllMassConversation];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"一呼万应";
    if(self.talkSession == nil)
		self.talkSession = [[talkSessionViewController alloc]init];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
    
    self.tipView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenW, 300)];
    [self.view addSubview:self.tipView];
    UIImageView *tipImageView=[[UIImageView alloc]initWithFrame:CGRectMake((screenW-100)/2, 50, 100, 100)];
    tipImageView.image=[StringUtil getImageByResName:@"yihuwanying_big.png"];
    self.tipView.hidden=YES;
    [self.tipView addSubview:tipImageView];
    [tipImageView release];
    UILabel *tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 155, screenW-20, 80)];
    tiplabel.numberOfLines=0;
    tiplabel.font=[UIFont systemFontOfSize:14];
    tiplabel.text=@"您可以同时给多个同事发送一呼万应消息，您的同事收到的将是您单独发与他的消息，他可以对您的一呼万应消息进行回复，回复消息只有您自己可以看到，一呼万应的其他接收者是看不到的";
	 [self.tipView addSubview:tiplabel];
    [tiplabel release];
    
    //	组织架构展示table
	int tableH = SCREEN_HEIGHT - 20 - 85;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
//	if(iPhone5)
//		tableH = tableH + i5_h_diff;
	
    broadcastListTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH) style:UITableViewStylePlain];
    [broadcastListTable setDelegate:self];
    [broadcastListTable setDataSource:self];
    broadcastListTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:broadcastListTable];
    if ([self.massArray count]==0) {
        self.tipView.hidden=NO;
        broadcastListTable.hidden=YES;
    }
    
    [UIAdapterUtil setExtraCellLineHidden:broadcastListTable];

    int footerY =self.view.frame.size.height - 45-44;
//    if(iPhone5)
//        footerY = footerY + i5_h_diff;
   
    footerView=[[UIView alloc]initWithFrame:CGRectMake(0, footerY, screenW, 50)];
    //footerView.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    //footerView.backgroundColor=[UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn2"]];
    [self.view addSubview:footerView];
    if (IOS7_OR_LATER) {
        footerView.frame=CGRectMake(0.0f,footerY-20,screenW, 50);
    }
    UIButton *newBroadCastButton=[UIButton buttonWithType:UIButtonTypeCustom];
    newBroadCastButton.frame=CGRectMake(30, 5, screenW-60, 35);
    newBroadCastButton.backgroundColor = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn2"]];
//
//    [newBroadCastButton setBackgroundImage:nil forState:UIControlStateNormal];
    newBroadCastButton.adjustsImageWhenHighlighted = NO;
//    [newBroadCastButton setBackgroundImage:[StringUtil getImageByResName:@"yihuwanying_button_up.png"] forState:UIControlStateNormal];
//    [newBroadCastButton setBackgroundImage:[StringUtil getImageByResName:@"yihuwanying_button_down.png"] forState:UIControlStateHighlighted];
//    [newBroadCastButton setBackgroundImage:[StringUtil getImageByResName:@"yihuwanying_button_down.png"] forState:UIControlStateSelected];
    [newBroadCastButton setTitle:@"新建一呼万应" forState:UIControlStateNormal];
	[newBroadCastButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	newBroadCastButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [newBroadCastButton addTarget:self action:@selector(newBroadCastButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:newBroadCastButton];
    // Do any additional setup after loading the view.
}
-(void)newBroadCastButtonAction:(id)sender
{
    //一呼百应 权限
//    if (broadcastChoose==nil) {
//        broadcastChoose=[[broadcastChooseMemberViewController alloc]init];
//    }
//    broadcastChoose.typeTag=0;
//    //[self.navigationController.tabBarController setHidesBottomBarWhenPushed:YES];
//	
//	[self.navigationController pushViewController:broadcastChoose animated:YES];
    
    
    
    if (chooseSpcial==nil) {
        chooseSpcial=[[chooseForSepcialViewController alloc]init];
    }
    chooseSpcial.typeTag=0;
    //[self.navigationController.tabBarController setHidesBottomBarWhenPushed:YES];
	
	[self.navigationController pushViewController:chooseSpcial animated:YES];

}
#pragma mark -
#pragma mark Table view data source


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.massArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
	{
        //		cell总高度
		float cellHeight = 55;
        //		logo的frame
		float logoX = 10;
		float logoY = 7.5;
        //		name frame
		float nameX = logoX + chatview_logo_size + 5;
		float nameY = 5;
		float contentWidth = (SCREEN_WIDTH-20 - chatview_logo_size - 10);
		float nameWidth = contentWidth *0.65;
		float nameHeight = (cellHeight - logoY*2)/2;
        //		时间frame
		float timeX = nameX + nameWidth + 5;
		float timeY = nameY;
		float timeWidth = contentWidth*0.35;
		float timeHeight = nameHeight;
		
        //		详细内容
		float detailX = nameX;
		float detailY = nameY + nameHeight + 5;
		float detailWidth = nameWidth;
		float detailHeight = nameHeight;
		
        //		新消息数量
		float newMsgWidth = 20;
		float newMsgHeight = 20;
		float newMsgX = timeX + timeWidth - newMsgWidth;
		float newMsgY = timeY + timeHeight + 5 + (timeHeight - newMsgHeight)/2;
		
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		UIImageView *iconview = [[UIImageView alloc]initWithFrame:CGRectMake(logoX, logoY, chatview_logo_size, chatview_logo_size)];
        //		UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, chatview_logo_size, chatview_logo_size)];
        iconview.tag=1;
        iconview.userInteractionEnabled=NO;
        // [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:iconview];
        [iconview release];
        
        UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(nameX, nameY, nameWidth, nameHeight)];
        namelable.tag=2;
        namelable.font=[UIFont boldSystemFontOfSize:16];
		
        namelable.backgroundColor=[UIColor clearColor];
        namelable.textColor=[UIColor blackColor];
        [cell.contentView addSubview:namelable];
        [namelable release];
        
        UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(timeX, timeY, timeWidth+5, timeHeight)];
        timelabel.tag=3;
        timelabel.font=[UIFont systemFontOfSize:13];
        timelabel.backgroundColor=[UIColor clearColor];
        timelabel.textColor=[UIColor grayColor];
		timelabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:timelabel];
        [timelabel release];
        
		UIView *detailView = [[UIView alloc]initWithFrame:CGRectMake(detailX, detailY, detailWidth, detailHeight)];
		detailView.tag = 4;
		[cell.contentView addSubview:detailView];
		[detailView release];
        
        UIImageView *redpart=[[UIImageView alloc]initWithFrame:CGRectMake(newMsgX,newMsgY, newMsgWidth, newMsgHeight)];
        redpart.image=[StringUtil getImageByResName:@"app_new_push.png"];
        redpart.tag=6;
        redpart.hidden=YES;
        [cell.contentView addSubview:redpart];
        [redpart release];
        
        UILabel *redpartTag=[[UILabel alloc]initWithFrame:CGRectMake(newMsgX,newMsgY, newMsgWidth, newMsgHeight)];
        redpartTag.tag=5;
        redpartTag.hidden=YES;
		redpartTag.font=[UIFont systemFontOfSize:11];
        redpartTag.backgroundColor=[UIColor clearColor];
        redpartTag.textAlignment=UITextAlignmentCenter;
        redpartTag.textColor=[UIColor whiteColor];
        [cell.contentView addSubview:redpartTag];
        [redpartTag release];
		
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.backgroundColor=[UIColor clearColor];
    
	
	UIImageView *iconview=(UIImageView *)[cell.contentView viewWithTag:1];
	UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
	

	UIImage *image = [StringUtil getImageByResName:@"yihuwanying.png"];
	
	if(image)
	{
		[iconview setImage:image];
	}
    massConversationObject *massObject=[self.massArray objectAtIndex:indexPath.row];
    
	namelabel.text =[NSString stringWithFormat:@"%d位收件人",massObject.emp_count];
	
	UILabel *timelabel=(UILabel *)[cell.contentView viewWithTag:3];

    //	如果是空会话，那么显示群组创建时间
    if(massObject.last_msg_time)
    {
        timelabel.text=[StringUtil getLastMessageDisplayTime:massObject.last_msg_time];
    }
    else
    {
        timelabel.text=[StringUtil getLastMessageDisplayTime:massObject.create_time];
    }

	UIView *detailView = (UIView*)[cell.contentView viewWithTag:4];
	for(UIView *uiView in [detailView subviews])
	{
		[uiView removeFromSuperview];
	}
	
	int msgType = massObject.last_msg_type;
    //如果最后一条消息类型是分组变化通知，那么不显示发言人名字
    
    if(msgType == type_text || msgType == type_long_msg)
    {
        [detailView addSubview:[[MessageView getLastMessageView] bubbleView:[NSString stringWithFormat:@"%@",massObject.last_msg_body]  from:true]];
    }
    //		最后一条消息是文件类型
    else if(msgType == type_file)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 200 , 20)];
        label.lineBreakMode = UILineBreakModeMiddleTruncation;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = [NSString stringWithFormat:@"%@",massObject.last_msg_body];
        [detailView addSubview:label];
        [label release];
        
    }
    else if(msgType == type_pic)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 100 , 20)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = [StringUtil getLocalizableString:@"msg_type_pic"];
        label.textColor = [UIColor redColor];
        
        [detailView addSubview:label];
        [label release];
    }
    else if(msgType == type_record)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 100 , 20)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = [StringUtil getLocalizableString:@"msg_type_record"];
        label.textColor = [UIColor redColor];
        
        [detailView addSubview:label];
        [label release];
    }

	
    UILabel *redpartTag=(UILabel *)[cell.contentView viewWithTag:5];
    UIImageView *redpart=(UIImageView *)[cell.contentView viewWithTag:6];
    
    if (massObject.unread>0) {
        redpart.hidden=NO;
        redpartTag.hidden=NO;
        redpartTag.text=[NSString stringWithFormat:@"%d",massObject.unread];
        
    }else
    {
        redpart.hidden=YES;
        redpartTag.hidden=YES;
    }
    

    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    broadcastRecordMemberViewController *broadcastRecordMember=[[broadcastRecordMemberViewController alloc]init];
//    [self.navigationController pushViewController:broadcastRecordMember animated:YES];
//    [broadcastRecordMember release];
    
    massConversationObject *massObject=[self.massArray objectAtIndex:indexPath.row];
    self.talkSession.talkType = massType;
    self.talkSession.titleStr = massObject.conv_title;
    self.talkSession.convId =massObject.conv_id;
	self.talkSession.convEmps = [massDAO getConvMemberByConvId:massObject.conv_id];
    //         self.talkSession.delegete=self;
    self.talkSession.needUpdateTag=1;
    //			self.talkSession.hidesBottomBarWhenPushed = YES;
    
   // [self hideTabBar];
    [self.navigationController pushViewController:self.talkSession animated:YES];
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		massConversationObject *massObject=[self.massArray objectAtIndex:indexPath.row];
		
		[massDAO deleteConvAndConvRecordsBy:massObject.conv_id];
		
		[self.massArray removeObjectAtIndex:indexPath.row];
		[tableView reloadData];
	}
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

	return YES;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
