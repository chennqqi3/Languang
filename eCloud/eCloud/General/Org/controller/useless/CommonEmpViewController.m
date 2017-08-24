//
//  CommonEmpViewController.m
//  eCloud
//
//  Created by shisuping on 14-9-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "CommonEmpViewController.h"
#import "personInfoViewController.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "UserDataDAO.h"
#import "EmpCell.h"
#import "specialChooseMemberViewController.h"
#import "personGroupViewController.h"
#import "eCloudDAO.h"
#import "UserDataConn.h"
#import "UserTipsUtil.h"
#import "Emp.h"
#import "eCloudNotification.h"

@interface CommonEmpViewController ()
@property (nonatomic,retain)NSMutableArray *commonEmpArray;
@property (nonatomic,retain)NSMutableArray *letterSortCommonEmpArray;
@property (nonatomic,retain)NSMutableArray *indexArray;
@property (nonatomic,retain) NSIndexPath *removeIndexPath;
@end

@implementation CommonEmpViewController
{
    UITableView *tableView;
    UserDataDAO *userData;
    UserDataConn *userDataConn;
    eCloudDAO *db;
    UILabel *tiplabel;
    BOOL needRefresh;
}

@synthesize commonEmpArray;
@synthesize removeIndexPath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userData = [UserDataDAO getDatabase];
    userDataConn = [UserDataConn getConn];
    
    db = [eCloudDAO getDatabase];
    
    needRefresh = YES;
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"main_my"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    [UIAdapterUtil setRightButtonItemWithImageName:@"add_connet.png" andTarget:self andSelector:@selector(addButtonPressed:)];
    
    tableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height-50) style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    [tableView release];
    
    tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 100)];
    tiplabel.backgroundColor=[UIColor clearColor];
    tiplabel.textAlignment=UITextAlignmentCenter;
    tiplabel.numberOfLines = 0;
//    tiplabel.text=@"请在通讯录中选择添加常用联系人";
    tiplabel.text = [StringUtil getLocalizableString:@"me_common_contacts_tip"];
    tiplabel.textColor=[UIColor grayColor];
    tiplabel.hidden=YES;
    [self.view addSubview:tiplabel];
    [tiplabel release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    [tableView setEditing:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];
    
    if (!needRefresh)
    {
        needRefresh = YES;
        return;
    }
    
    [self refresh];
    
}

-(void)refresh
{
    self.commonEmpArray = [NSMutableArray arrayWithArray:[userData getAllCommonEmp]];
    NSLog(@"常用联系人个数%d",self.commonEmpArray.count);
    if (self.commonEmpArray.count > 0)
    {
        tableView.hidden = NO;
        tiplabel.hidden = YES;
        self.indexArray = [self IndexArray:self.commonEmpArray];
        self.letterSortCommonEmpArray = [self LetterSortArray:self.commonEmpArray];
        [tableView reloadData];
    }
    else
    {
        tableView.hidden = YES;
        tiplabel.hidden = NO;
    }
    [UIAdapterUtil setExtraCellLineHidden:tableView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.commonEmpArray.count>0)
    {
        return self.letterSortCommonEmpArray.count;
    }
    else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *empsForSection = self.letterSortCommonEmpArray[section];
    return empsForSection.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return emp_row_height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.indexArray[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
    static NSString *CellIdentifier = @"Cell";
    EmpCell *empCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
     if (empCell ==nil)
     {
         empCell = [[[EmpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
     }

//     [empCell configureCell:self.commonEmpArray[indexPath.row] andDisplayStatus:YES];

     
     NSArray *empsForSection = self.letterSortCommonEmpArray[indexPath.section];
     [empCell configureCell:empsForSection[indexPath.row]];
     
     UIImageView *imageView = (UIImageView *)[empCell viewWithTag:emp_logo_tag];
     imageView.userInteractionEnabled = YES;
     UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconClick:)];
     [imageView addGestureRecognizer:singleTap1];
     [singleTap1 release];
     return empCell;
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *tempArr = self.letterSortCommonEmpArray[indexPath.section];

    [UIAdapterUtil openConversation:self andEmp:tempArr[indexPath.row]];
}

-(void) addButtonPressed:(id) sender
{
 	specialChooseMemberViewController *_controller = [[specialChooseMemberViewController alloc]init];
    _controller.typeTag = type_add_common_emp;// 0;
	[self.navigationController pushViewController:_controller animated:YES];
    [_controller release];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.commonEmpArray.count>0 && indexPath.row < self.commonEmpArray.count)
    {
//        NSLog(@"%d",indexPath.row);
//        Emp *emp = self.commonEmpArray[indexPath.row];
//        if (emp.isDefaultCommonEmp)
//            return NO;
//        else
//            return YES;
        NSMutableArray *tempArr = self.letterSortCommonEmpArray[indexPath.section];
        Emp *emp = tempArr[indexPath.row];
        if (emp.isDefaultCommonEmp)
            return NO;
        else
            return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Emp *emp = self.commonEmpArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BOOL ret = [userDataConn sendModiRequestWithDataType:user_data_type_emp andUpdateType:user_data_update_type_delete andData:[NSArray arrayWithObject:[StringUtil getStringValue:emp.emp_id]]];
        
        if (ret) {
            self.removeIndexPath = indexPath;
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"me_loading_tip"]];
        }
    }
}

-(void)iconClick:(UITapGestureRecognizer *)recognizer
{
    needRefresh = NO;
//    UITableViewCell *selectIconOfCell = (UITableViewCell *)[[[recognizer.view superview] superview] superview];
//    
//    NSIndexPath *iconIndexPath = [tableView indexPathForCell:selectIconOfCell];
//    NSMutableArray *tempArr = self.letterSortCommonEmpArray[iconIndexPath.section];
//    NSLog(@"%d",iconIndexPath.section);
//    Emp *emp = tempArr[iconIndexPath.row];
//    personInfoViewController *personInfoView = [[personInfoViewController alloc] init];
//    personInfoView.emp= [db getEmpInfo: [StringUtil getStringValue:emp.emp_id]];
//    [self.navigationController pushViewController:personInfoView animated:YES];
//    [personInfoView release];
    
    UIImageView *iconView = (UIImageView *)recognizer.view;
    UILabel *empIdLabel = (UILabel *)[iconView viewWithTag:emp_id_tag];
    personInfoViewController *personInfoView = [[personInfoViewController alloc] init];
    personInfoView.emp= [db getEmpInfo: empIdLabel.text];
    [self.navigationController pushViewController:personInfoView animated:YES];
    [personInfoView release];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexArray;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    
    // 让table滚动到对应的indexPath位置
    [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    return index;
    
}

//返回右边索引的数组
-(NSMutableArray *)IndexArray:(NSArray*)empArray
{
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    NSString *tempStr = @"";
    for (Emp *emp in empArray)
    {
        NSString *firstLetter = [emp.empCode substringToIndex:1];
        if (![firstLetter isEqualToString:tempStr])
        {
            [indexArray addObject:firstLetter];
            tempStr = firstLetter;
        }
    }
    return indexArray;
}

//返回联系人
-(NSMutableArray*)LetterSortArray:(NSArray*)empArray
{
    NSMutableArray *LetterResult=[NSMutableArray array];
    NSMutableArray *item = [NSMutableArray array];
    NSString *tempString =@"";
    //拼音分组
    for (Emp* emp in empArray) {
        
        NSString *firstLetter = [emp.empCode substringToIndex:1];
//        NSString *namePinyinString = emp.empCode;
        
        if(![firstLetter isEqualToString:tempString])
        {
            
            item = [NSMutableArray array];
            [item  addObject:emp];
            [LetterResult addObject:item];
            
            tempString = firstLetter;
        }else
        {
            [item  addObject:emp];
        }
    }
    return LetterResult;
}


-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    self.removeIndexPath = nil;
    self.commonEmpArray = nil;
    self.letterSortCommonEmpArray = nil;
    self.indexArray = nil;
    tableView = nil;
    tiplabel = nil;
    [super dealloc];
 }
#pragma mark ===========handleCmd=============

-(void)handleCmd:(NSNotification *)notification
{

    [UserTipsUtil hideLoadingView];
	eCloudNotification *_notification = [notification object];
	if(_notification != nil)
	{
		int cmdId = _notification.cmdId;
		switch (cmdId) {
            case update_user_data_success:
            {
                NSMutableArray *tempArr = self.letterSortCommonEmpArray[self.removeIndexPath.section];
                Emp *_emp = [tempArr objectAtIndex:self.removeIndexPath.row];
                [userData removeCommonEmp:_emp.emp_id];
                [self refresh];
            }
                 break;
            case update_user_data_fail:
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_contacts_remove_failure"]];
                break;
            case update_user_data_timeout:
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_contacts_remove_timeout"]];
                break;
			default:
				break;
        }
    }
}
@end
