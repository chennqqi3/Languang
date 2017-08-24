//
//  broadcastListViewController.m
//  eCloud
//
//  Created by  lyong on 13-4-15.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "broadcastListViewController.h"
#import "eCloudDAO.h"
#import "UIAdapterUtil.h"
#import "broadcastContentViewController.h"
#import "PSBackButtonUtil.h"
#import "ConvNotification.h"
#import "eCloudNotification.h"
#import "QueryResultCell.h"
#import "Emp.h"
#import "eCloudDefine.h"


@interface broadcastListViewController ()

@end

@implementation broadcastListViewController
{
	eCloudDAO *db;
    UIButton *leftButton;
}
@synthesize itemArray;

- (void)dealloc
{
    self.itemArray = nil;
    self.convId = nil;
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    personTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    if (self.broadcastType == normal_broadcast)
    {
        self.title=[StringUtil getLocalizableString:@"settings_broadcast_message"];
    }
    else
    {
        self.title=[StringUtil getLocalizableString:@"im_notice"];
    }
    
    self.itemArray =[db getBroadcastList:self.broadcastType];
    NSArray *tempArr = self.itemArray;
    [PSBackButtonUtil showNoReadNum:nil andButton:leftButton andBtnTitle:[StringUtil getAppLocalizableString:@"main_chats"]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleCmd:)
                                                name:CONVERSATION_NOTIFICATION
                                              object:nil];

    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleCmd:)
                                                name:NEW_CONVERSATION_NOTIFICATION
                                              object:nil];
    [personTable reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [personTable setEditing:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_CONVERSATION_NOTIFICATION object:nil];
}

-(void)handleCmd:(NSNotification *)notification
{
    eCloudNotification *_notification = [notification object];
    if(_notification != nil)
    {
        int cmdId = _notification.cmdId;
        switch (cmdId) {
            case rev_msg:
            {
                [PSBackButtonUtil showNoReadNum:nil andButton:leftButton andBtnTitle:[StringUtil getAppLocalizableString:@"main_chats"]];
            }
                break;
            case add_new_conversation:
            {
                [self.itemArray removeAllObjects];
                self.itemArray =[db getBroadcastList:self.broadcastType];
                [personTable reloadData];
                [PSBackButtonUtil showNoReadNum:nil andButton:leftButton andBtnTitle:[StringUtil getAppLocalizableString:@"main_chats"]];
            }
                break;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    db = [eCloudDAO getDatabase];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    [UIAdapterUtil processController:self];
    
    leftButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    personTable= [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [personTable setDelegate:self];
    [personTable setDataSource:self];
    personTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:personTable];
    [personTable release];
    
    [UIAdapterUtil setPropertyOfTableView:personTable];
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:personTable];

    [UIAdapterUtil setExtraCellLineHidden:personTable];
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
    
	[self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    
	return [self.itemArray count];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return conv_row_height;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        cell.backgroundColor = [UIColor whiteColor];
        
        // 0814
       CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
        float nameX = 10;
        float nameY = 8;
        UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(nameX, nameY, (screenW - nameX * 2)*0.8, (conv_row_height - nameY * 2) /2)];
        namelable.tag=2;
        namelable.font=[UIFont boldSystemFontOfSize:17];
        namelable.backgroundColor=[UIColor clearColor];
        namelable.textColor=[UIColor blackColor];
        [cell.contentView addSubview:namelable];
        [namelable release];
        
        CGFloat timelabelW = (screenW - nameX * 2)*0.2;
        UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(namelable.frame.origin.x + namelable.frame.size.width, namelable.frame.origin.y , timelabelW, namelable.frame.size.height)];
        timelabel.tag=3;
        timelabel.textAlignment = UITextAlignmentRight;
        timelabel.font=[UIFont systemFontOfSize:11];
        timelabel.backgroundColor=[UIColor clearColor];
        timelabel.textColor=[UIColor grayColor];
        timelabel.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:timelabel];
        [timelabel release];
        
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(namelable.frame.origin.x, namelable.frame.origin.y + namelable.frame.size.height, (cell.contentView.frame.size.width - 45), namelable.frame.size.height)];
        titleLabel.tag=4;
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.backgroundColor=[UIColor clearColor];
        [cell.contentView addSubview:titleLabel];
        [titleLabel release];
        
        float readFlagWidth = 10;
        float readFlagHeight = 10;
        
        UIImageView *readFlagView = [[UIImageView alloc] initWithFrame:CGRectMake(screenW - 30, nameY + namelable.frame.size.height + (namelable.frame.size.height - readFlagHeight)/2  , readFlagWidth, readFlagHeight)];

        readFlagView.image = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"broadcast_new" andType:@"png"]];

        readFlagView.tag = 5;

        [cell.contentView addSubview:readFlagView];
        [readFlagView release];
        
    }
	
	NSDictionary *dic= [self.itemArray objectAtIndex:indexPath.row];
    
//    	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SenderID,@"sender_id",RecverID,@"recver_id",MsgID,@"msg_id",SendTime,@"sendtime",MsgLen,@"msglen",Titile,@"asz_titile",Message,@"asz_message", nil]
    
    //	会话名称
    Emp *emp= [db getEmployeeById:[dic objectForKey:@"sender_id"]];
    
	UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
    namelabel.text = emp.emp_name;
    
    //	最后一条消息时间
	UILabel *timelabel=(UILabel *)[cell.contentView viewWithTag:3];
	timelabel.text = [StringUtil getLastMessageDisplayTime:[dic objectForKey:@"sendtime"]];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:4];
   	titleLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"asz_titile"]];
    UIImageView *readFlagView = [cell.contentView viewWithTag:5];
    if ([[dic valueForKey:@"read_flag"] intValue]== 1) {
        readFlagView.hidden = NO;
    }
    else{
        readFlagView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    broadcastContentViewController *_broadcastContentController = [[broadcastContentViewController alloc]init];
    
    NSDictionary *dic= [self.itemArray objectAtIndex:indexPath.row];
    _broadcastContentController.titleString= [dic objectForKey:@"asz_titile"];
    _broadcastContentController.messageString = [dic objectForKey:@"asz_message"];
    _broadcastContentController.msgId = [dic objectForKey:@"msg_id"];
    _broadcastContentController.convId = self.convId;
    _broadcastContentController.broadcastType = self.broadcastType;
    [self.navigationController pushViewController:_broadcastContentController animated:YES];
    [_broadcastContentController release];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *dic=[self.itemArray objectAtIndex:indexPath.row];
	   
		deleteConvId = [dic objectForKey:@"msg_id"];
        deleteRow = indexPath.row;
        
		NSString *titleStr = @"";
		
        titleStr = [NSString stringWithFormat:@"确定删除标题为'%@'的广播消息？",[dic objectForKey:@"asz_titile"]];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:titleStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
		alert.tag = 2;
		[alert dismissWithClickedButtonIndex:1 animated:YES];
		[alert show];
		[alert release];
		
        //        [tableData removeObjectAtIndex:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


#pragma mark alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag;
    
    if(tag == 2 && buttonIndex == 0)
    {
        if ([db needUpdateBroadcastReadFlag:deleteConvId])
        {
            [db updateBroadcastReadFlagToRead:deleteConvId andUpdateConvId:self.convId andBroadcastType:self.broadcastType];
            [PSBackButtonUtil showNoReadNum:nil andButton:leftButton andBtnTitle:[StringUtil getAppLocalizableString:@"main_chats"]];
        }
        
        [db deleteBroadcastByOne:deleteConvId andConvId:self.convId];
        [self.itemArray removeObjectAtIndex:deleteRow];
        
        [personTable reloadData];
        return;
    }
}

@end
