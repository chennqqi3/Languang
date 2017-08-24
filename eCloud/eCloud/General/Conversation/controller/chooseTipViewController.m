//
//  chooseTipViewController.m
//  eCloud
//
//  Created by  lyong on 14-4-2.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "chooseTipViewController.h"
#import "Emp.h"
#import "eCloudDefine.h"
#import "UserDisplayUtil.h"
#import "talkSessionViewController.h"
#import "UIAdapterUtil.h"
#import "InputTextView.h"
#import "StringUtil.h"
#import "conn.h"
#import "Emp.h"
#import "personInfoViewController.h"
#import "VirGroupObj.h"
#import "userInfoViewController.h"
#import "OffenGroup.h"

@interface chooseTipViewController ()

@end

@implementation chooseTipViewController
@synthesize dataArray;
@synthesize predelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"选择提醒的人";
    [UIAdapterUtil processController:self];
       //设置背景
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    personGroupTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIAdapterUtil getDeviceMainScreenWidth], self.view.frame.size.height - 44) style:UITableViewStylePlain];
    [UIAdapterUtil setPropertyOfTableView:personGroupTable];
    [UIAdapterUtil setExtraCellLineHidden:personGroupTable];
    [personGroupTable setDelegate:self];
    [personGroupTable setDataSource:self];
    personGroupTable.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:personGroupTable];
	// Do any additional setup after loading the view.
}
#pragma  table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    
	return [self.dataArray count];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 55;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        
        //		获得logoView，其中包含了一个子View，用来显示是否手机在线的view
        UIImageView *iconview = [UserDisplayUtil getUserLogoView];
        iconview.tag=1;
        iconview.userInteractionEnabled=NO;

		//		cell总高度
		float cellHeight = 55;
		//		logo的frame
		float logoX = 10;
		float logoY = (cellHeight - iconview.frame.size.height) / 2;
		//		name frame
		float nameX = logoX + iconview.frame.size.width + 10;
		float nameY = 0;
		float contentWidth = ([UIAdapterUtil getTableCellContentWidth] - iconview.frame.size.width - 10);
		float nameWidth = contentWidth *0.65;
        float nameHeight = cellHeight;
		
		
		//		设置frame
		float x = logoX;
		float y = logoY;
		CGRect _frame = iconview.frame;
		_frame.origin.x = x;
		_frame.origin.y = y;
		iconview.frame = _frame;
		//增加到cell中
        [cell.contentView addSubview:iconview];
        
        UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(nameX, nameY, nameWidth, nameHeight)];
        namelable.tag=2;
        namelable.font=[UIFont boldSystemFontOfSize:16];
		
        namelable.backgroundColor=[UIColor clearColor];
        namelable.textColor=[UIAdapterUtil isGOMEApp]?GOME_NAME_COLOR:[UIColor blackColor];
        [cell.contentView addSubview:namelable];
        [namelable release];
        [UIAdapterUtil customSelectBackgroundOfCell:cell];
    }
    Emp *emp=[self.dataArray objectAtIndex:indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
    UIImageView *iconview=(UIImageView *)[cell.contentView viewWithTag:1];
    
    [UserDisplayUtil setUserLogoView:iconview andEmp:emp];
     namelabel.text = emp.emp_name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	  Emp *emp=[self.dataArray objectAtIndex:indexPath.row];
    NSString *nameStr = [NSString stringWithFormat:@"%@ ",emp.emp_name];
    NSMutableString *mutableStr = [[[NSMutableString alloc]initWithString:((talkSessionViewController *)self.predelegate).messageTextField.text]autorelease];
    
    nameStr = [NSString stringWithFormat:@"%@",nameStr];
    
    unsigned long index = _range.location+1;
    if (index > mutableStr.length) // 只有在九宫格键盘下 连按“.-@/#”这个键三次来选中“@”的情况下 才需要做此调整
    {
        index--;
    }
    
    [mutableStr insertString:nameStr  atIndex:index];
    
    ((talkSessionViewController *)self.predelegate).messageTextField.text= mutableStr;
    
   [self.navigationController popViewControllerAnimated:YES];
    
    [((talkSessionViewController *)self.predelegate).messageTextField becomeFirstResponder];
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = personGroupTable.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    personGroupTable.frame = _frame;
    
    [personGroupTable reloadData];
}
@end
