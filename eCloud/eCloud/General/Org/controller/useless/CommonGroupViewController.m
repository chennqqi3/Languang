//
//  CommonGroupViewController.m
//  eCloud
//
//  Created by SH on 14-9-22.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "CommonGroupViewController.h"
#import "UIAdapterUtil.h"
#import "UserDataDAO.h"
#import "GroupCell.h"
#import "Conversation.h"
#import "StringUtil.h"
#import "eCloudDefine.h"

@interface CommonGroupViewController ()
@property (nonatomic,retain)NSMutableArray *commonGroupArray;

@end

@implementation CommonGroupViewController
{
    UITableView *tableView;
    UILabel *tipLabel;
    UserDataDAO *userData;
    BOOL needRefresh;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userData = [UserDataDAO getDatabase];
    
    needRefresh =  YES;
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"main_my"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake(0, 0, 44, 44);
//    [addButton setBackgroundImage:[UIImage imageNamed:@"add_connet.png"] forState:UIControlStateNormal];
//    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
    
    tableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height-50) style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:tableView];
    [tableView release];
    
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 50, 320, 100)];
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=UITextAlignmentCenter;
//    tipLabel.text=@"请在聊天资料中添加自定义组";
    tipLabel.text = [StringUtil getLocalizableString:@"me_custom_groups_tip"];
    tipLabel.numberOfLines = 0;
    tipLabel.textColor=[UIColor grayColor];
    tipLabel.hidden=YES;
    [self.view addSubview:tipLabel];
//    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [tipLabel release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"常用群组个数%d",self.commonGroupArray.count);
    if (tableView !=nil)
    {
        if(needRefresh == NO)
            return;
    }
    
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)refresh
{
    self.commonGroupArray = [userData getALlCommonGroup];
    if (self.commonGroupArray.count>0)
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commonGroupArray.count;
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
        groupCell = [[[GroupCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [groupCell configCell:self.commonGroupArray[indexPath.row]];
    
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
    [contactView openConversation:self.commonGroupArray[indexPath.row]];
    
    [UIAdapterUtil showChatPage:self];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Conversation *conv = self.commonGroupArray[indexPath.row];
        [userData removeOneCommonGroup:conv.conv_id];
        [self refresh];
    }
}

-(void)addButtonPressed:(id)sender
{
    //添加常用群组
}

-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    self.commonGroupArray = nil;
    tableView = nil;
    tipLabel =nil;
    [super dealloc];
}

@end
