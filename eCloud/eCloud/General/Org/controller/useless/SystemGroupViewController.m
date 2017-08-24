//
//  SystemGroupViewController.m
//  eCloud
//
//  Created by shisuping on 14-9-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "SystemGroupViewController.h"
#import "talkSessionViewController.h"
#import "UIAdapterUtil.h"
#import "UserDataDAO.h"
#import "eCloudDAO.h"
#import "GroupCell.h"
#import "UserDataConn.h"
#import "eCloudDefine.h"

@interface SystemGroupViewController ()
@property(nonatomic,retain)NSArray *systemGroup;
@end

@implementation SystemGroupViewController
{
    eCloudDAO *db;
    UserDataDAO *userData;
    UITableView *tableView;
    UILabel *tipLabel;
    BOOL needRefresh;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userData = [UserDataDAO getDatabase];
    db = [eCloudDAO getDatabase];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    needRefresh =  YES;
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"main_my"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    tableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height-50) style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    [tableView release];
    
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 50, 320, 100)];
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=UITextAlignmentCenter;
    tipLabel.text = [StringUtil getLocalizableString:@"您还没有网信群"];
    tipLabel.numberOfLines = 0;
    tipLabel.textColor=[UIColor grayColor];
    tipLabel.hidden=YES;
    [self.view addSubview:tipLabel];
    [tipLabel release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainRefreshData) name:SYSTEM_GROUP_UPDATE_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainRefreshData) name:CONVERSATION_NOTIFICATION object:nil];
    
    if (tableView !=nil)
    {
        if(needRefresh == NO)
            return;
    }
    
    [self refresh];
    
}

-(void)mainRefreshData
{
    [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SYSTEM_GROUP_UPDATE_NOTIFICATION" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CONVERSATION_NOTIFICATION" object:nil];
}

-(void)refresh
{
    self.systemGroup = [userData getALlSystemGroup];
    NSLog(@"网信群个数%d",self.systemGroup.count);
    
    if (self.systemGroup.count>0)
    {
        tableView.hidden = NO;
        tipLabel.hidden = YES;
        [tableView reloadData];
    }
    else
    {
        tableView.hidden = YES;
        tipLabel.hidden = NO;
    }
    [UIAdapterUtil setExtraCellLineHidden:tableView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.systemGroup.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return GroupCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GroupCell *groupCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (groupCell == nil) {
        groupCell = [[[GroupCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    }
    [groupCell configCell:self.systemGroup[indexPath.row]];
    
    UIView *imageLogo = [groupCell viewWithTag:logo_view_tag];
    CGRect _frame = imageLogo.frame;
    _frame.origin.y = (GroupCellHeight - chatview_logo_size)*0.5;
    imageLogo.frame = _frame;
    
    UIView *label = [groupCell viewWithTag:group_name_tag];
    CGPoint _center = label.center;
    _center.y = GroupCellHeight*0.5;
    label.center = _center;
    
    return groupCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    contactViewController *contactView = [UIAdapterUtil getContactViewController:self];
    [contactView openConversation:self.systemGroup[indexPath.row]];
    
    [UIAdapterUtil showChatPage:self];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    self.systemGroup = nil;
    tableView = nil;
    tipLabel = nil;
    [super dealloc];
}

@end
