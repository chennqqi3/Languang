//
//  provinceChooseViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "provinceChooseViewController.h"
#import "StringUtil.h"
#import "RecentMember.h"
#import "RecentGroup.h"
#import "zoneChooseViewController.h"
#import "AdvanceQueryDAO.h"
#import "UIAdapterUtil.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "Area.h"


@implementation provinceChooseViewController
{
	AdvanceQueryDAO *advanceQueryDAO;
}
@synthesize nowSelectedEmpArray;
@synthesize chooseArray;
@synthesize typeTag;
@synthesize delegete;
@synthesize country_id;
@synthesize selectedArea;
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
    if (self.selectedArea!=nil) {
        ((zoneChooseViewController *)self.delegete).provinceLabel.text=self.selectedArea.areaName;
       
        if (((zoneChooseViewController *)self.delegete).province_id!=self.selectedArea.areaId) {
            ((zoneChooseViewController *)self.delegete).province_id=self.selectedArea.areaId;
            ((zoneChooseViewController *)self.delegete).cityLabel.text=@"请选择";
        }
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
    self.chooseArray=[advanceQueryDAO getAllArea:self.country_id];
    [chooseTable reloadData];
}
- (void)viewDidLoad
{
    
	NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
    _conn = [conn getConn];
    advanceQueryDAO = [AdvanceQueryDAO getDataBase];
    self.chooseArray=[advanceQueryDAO getAllArea:self.country_id];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    self.title=@"请选择省/州";
    
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
 
        return 1;
    
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

        return 58;

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
      id temp=[self.chooseArray objectAtIndex:indexPath.row];
      UIButton *selectButton=(UIButton *)cell.accessoryView;
      selectButton.tag=indexPath.row;
    //[selectButton addTarget:self action:@selector(selectChooseAction:) forControlEvents:UIControlEventTouchUpInside];
      selectButton.userInteractionEnabled=NO;
      cell.textLabel.font=[UIFont systemFontOfSize:17];
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
        

    
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int newrow=[indexPath row];
    // int row=newrow;
	int oldrow=(oldindexpath!=nil)?[oldindexpath row]:-1;
    
	if (newrow!=oldrow) {
		
        id newtemp=[self.chooseArray objectAtIndex:indexPath.row];
        ((Area *)newtemp).isChecked=true;
        self.selectedArea=((Area *)newtemp);
        if (oldindexpath!=nil) {
            id oldtemp=[self.chooseArray objectAtIndex:oldindexpath.row];
            ((Area *)oldtemp).isChecked=false;
            [oldindexpath release];
        }
        oldindexpath = [indexPath copy];//一定要这么写，要不报错
        
	}
    [chooseTable reloadData];
    
    
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

