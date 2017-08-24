//
//  cityChooseViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//
//
//  provinceChooseViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "cityChooseViewController.h"
#import "StringUtil.h"
#import "RecentMember.h"
#import "zoneChooseViewController.h"
#import "Area.h"
#import "AdvanceQueryDAO.h"
#import "UIAdapterUtil.h"

#import "conn.h"
#import "LCLLoadingView.h"
#import "eCloudDefine.h"

@implementation cityChooseViewController
{
 AdvanceQueryDAO *advanceQueryDAO;
}
@synthesize nowSelectedEmpArray;
@synthesize chooseArray;
@synthesize typeTag;
@synthesize delegete;
@synthesize province_id;

-(void)dealloc
{
	NSLog(@"%s",__FUNCTION__);
	self.nowSelectedEmpArray=nil;
	self.delegete = nil;
	
	[[NSNotificationCenter defaultCenter]removeObserver:self name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
    
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


-(void)highButtonPressed:(id)sender
{
    BOOL hasSelected=NO;
    NSString *selectedStr=nil;
    NSString *area_id_strs=nil;
    for (int i=0; i<[self.chooseArray count]; i++) {
        id temp=[self.chooseArray objectAtIndex:i];
        if ([temp isKindOfClass:[Area class]]) {
            
            Area *rank=(Area *)temp;
            if (rank.isChecked) {
                hasSelected=YES;
                if (selectedStr==nil) {
                    selectedStr=rank.areaName;
                    area_id_strs=[NSString stringWithFormat:@"%d",rank.areaId];
                }else{
                selectedStr=[NSString stringWithFormat:@"%@,%@",selectedStr,rank.areaName];
                area_id_strs=[NSString stringWithFormat:@"%@,%d",area_id_strs,rank.areaId];
                }
            }
            
        }
    }
    if (hasSelected) {
        ((zoneChooseViewController *)self.delegete).cityLabel.text=selectedStr;
        ((zoneChooseViewController *)self.delegete).area_id_strings=area_id_strs;
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        UIAlertView *tempalert=[[UIAlertView alloc]initWithTitle:@"您还没有选择" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [tempalert show];
        [tempalert release];
    }
    
}
-(void)updateShowData
{
    self.chooseArray=[advanceQueryDAO getrCityArray:self.province_id];
    [chooseTable reloadData];
}
- (void)viewDidLoad
{
    
	NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
	_conn = [conn getConn];
    advanceQueryDAO = [AdvanceQueryDAO getDataBase];
    self.chooseArray=[advanceQueryDAO getrCityArray:self.province_id];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    self.title=@"请选择市";
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];

    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"confirm"] andTarget:self andSelector:@selector(highButtonPressed:)];
    
    
    //	组织架构展示table
	int tableH = SCREEN_HEIGHT -20 - 45;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
//	if(iPhone5)
//		tableH = tableH + i5_h_diff;
	
    chooseTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH) style:UITableViewStylePlain];
    [chooseTable setDelegate:self];
    [chooseTable setDataSource:self];
    chooseTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:chooseTable];
    
    
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	
    
}

-(void)dismissSelf:(NSNotification *)notification
{
	
	[self dismissModalViewControllerAnimated:NO];
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
 	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
    if (self.typeTag==2) {
        self.navigationController.navigationBarHidden = NO;
    }
	[self.navigationController popViewControllerAnimated:YES];
}

//隐藏查询输入框的键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[searchTextView resignFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.chooseArray count];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id temp=[self.chooseArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[RecentMember class]])
    {
        return 0;
    }else
    {
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return nil;
    
    
}
-(void)titleButtonAction:(id)sender
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id temp=[self.chooseArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[RecentMember class]]) {
        return 45;
    }// Configure the cell.
    else {
        return 58;
    }
    
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        selectView.tag=5;
        selectView.backgroundColor=[UIColor clearColor];
        cell.accessoryView=selectView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        
        UILabel *onlineLabel=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-110, 5, SCREEN_WIDTH-230, 30)];
        onlineLabel.backgroundColor=[UIColor clearColor];
        onlineLabel.tag=1;
        onlineLabel.hidden=YES;
        onlineLabel.textAlignment=UITextAlignmentCenter;
        onlineLabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:onlineLabel];
        [onlineLabel release];
        
    }
    
    
    UIButton *selectButton=(UIButton *)cell.accessoryView;
    selectButton.tag=indexPath.row;
    //[selectButton addTarget:self action:@selector(selectChooseAction:) forControlEvents:UIControlEventTouchUpInside];
    selectButton.userInteractionEnabled=NO;
    cell.textLabel.font=[UIFont systemFontOfSize:17];
    id temp=[self.chooseArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[RecentMember class]]) {
        RecentMember *itemobject=(RecentMember *)temp;
        
        if (itemobject.isChecked) { //选中
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
        }else   //未选择
        {
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
            
        }
        
        cell.textLabel.text=itemobject.type_name;
        
    }else
    {
        Area *itemobject=(Area *)temp;
        cell.textLabel.text=itemobject.areaName;
        if (itemobject.isChecked) { //选中
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
        }else   //未选择
        {
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
            
        }
        
    }
    
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id temp=[self.chooseArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[RecentMember class]])
    {
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        UIButton *button=(UIButton *)[cell viewWithTag:5];
        
        RecentMember *recent=(RecentMember *)temp;
        if (recent.isChecked) { //不选中
            recent.isChecked=false;
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
        }else   //选中
        {
            //            if ( nowcount+dept.totalNum>(maxGroupNum - self.oldEmpIdArray.count)) {
            //				[self showGroupNumExceedAlert];
            //                return;
            //            }
            
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            recent.isChecked=true;
        }
        
        //		把选中状态呈现在界面上
        for (int i=indexPath.row+1; i<[self.chooseArray count]; i++) {
            id temp1 = [self.chooseArray objectAtIndex:i];
            if([temp1 isKindOfClass:[Area class]])
            {
                
                ((Area *)temp1).isChecked=recent.isChecked;
            }
        }
        [chooseTable reloadData];
        
    }else
    {
        
        if (((Area *)temp).isChecked) {
            ((Area *)temp).isChecked=false;
        }else
        {
            ((Area *)temp).isChecked=true;
        }
        [chooseTable reloadData];
    }
    
    
}

-(void)iconAction:(id)sender
{
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //NSLog(@"-----scrollViewDidScroll");
    //    if (!backgroudButton) {
    //         [_searchBar resignFirstResponder];
    //        backgroudButton.hidden=YES;
    //    }
    
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //    NSLog(@"-----scrollViewDidEndDragging");
    
    
    
}

@end

