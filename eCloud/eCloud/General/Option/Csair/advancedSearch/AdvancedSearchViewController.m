//
//  AdvancedSearchViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-16.
//  Copyright (c) 2013年  lyong. All rights reserved.
//
//
//  AdvancedSearchViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-10.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "AdvancedSearchViewController.h"
#import "Dept.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "rankChooseViewController.h"
#import "businessChooseViewController.h"
#import "zoneChooseViewController.h"
#import "talkSessionViewController.h"
#import "chatMessageViewController.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "addScheduleViewController.h"
#import "RecentMember.h"
#import "RecentGroup.h"
#import "specialChooseMemberViewController.h"
#import "citiesObject.h"
#import "AdvanceQueryDAO.h"
#import "UIAdapterUtil.h"
#import "Emp.h"
#import "eCloudDefine.h"

@implementation AdvancedSearchViewController
{
	eCloudDAO *_ecloud ;
    AdvanceQueryDAO *advanceQueryDAO;
}
@synthesize nowSelectedEmpArray;
@synthesize oldEmpIdArray;
@synthesize chooseArray;
@synthesize employeeArray;
@synthesize  deptArray;
@synthesize typeTag;
@synthesize delegete;
@synthesize rankLabel;
@synthesize bussinesslLabel;
@synthesize zoneArray;
@synthesize rank_list_str;
@synthesize business_list_str;

-(void)dealloc
{
	NSLog(@"%s",__FUNCTION__);
	self.nowSelectedEmpArray=nil;
	self.oldEmpIdArray = nil;
	self.delegete = nil;
	self.employeeArray = nil;
	self.deptArray = nil;
	
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
    if (self.rank_list_str==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请选择级别" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    if (self.business_list_str==nil) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请选择业务" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
  
    city_list_str=nil;
    for (int i=0; i<[self.zoneArray count]; i++) {
        id temp=[self.zoneArray objectAtIndex:i];
        if ([temp isKindOfClass:[citiesObject class]])
        {
            citiesObject *city=   (citiesObject *)temp;
            
            if (city_list_str==nil) {
                city_list_str=city.some_cityid;
            }else
            {
                city_list_str=[NSString stringWithFormat:@"%@,%@",city_list_str,city.some_cityid];
            }
            
        }
    }
  
   // self.chooseArray=[advanceQueryDAO getChooseArrayByRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    [advanceQueryDAO createTempDepts:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
    self.chooseArray=[advanceQueryDAO getTempDeptInfoWithLevel:@"0" andLevel:0 andSelected:false];
    [chooseTable reloadData];
    if ([self.chooseArray count]>3) {
        [chooseTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
                           atScrollPosition: UITableViewScrollPositionTop
                                   animated:NO];
    }
   
}
- (void)viewDidLoad
{
    
	NSLog(@"%s",__FUNCTION__);
    [super viewDidLoad];
	_conn = [conn getConn];
	_ecloud = [eCloudDAO getDatabase];
	self.oldEmpIdArray = [NSMutableArray array];
	self.nowSelectedEmpArray = [NSMutableArray array];
    self.zoneArray = [NSMutableArray array];
    advanceQueryDAO = [AdvanceQueryDAO getDataBase];
	maxGroupNum = 80;
    self.chooseArray= [NSMutableArray array];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    self.title=@"高级搜索";
    //	左边按钮
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    //    右边按钮
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"search_tips"] andTarget:self andSelector:@selector(highButtonPressed:)];
   
    //	组织架构展示table
	int tableH = 460 - 85;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    chooseTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
    [chooseTable setDelegate:self];
    [chooseTable setDataSource:self];
    chooseTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:chooseTable];
    

	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	
    //	自定义导航栏
	int toolbarY = self.view.frame.size.height - 44-44;
    //	if(iPhone5)
    //		toolbarY = toolbarY + i5_h_diff;
    UINavigationBar *bottomNavibar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, toolbarY, 320, 45)];
    bottomNavibar.tintColor=[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0];
    [self.view addSubview:bottomNavibar];
    //	右边按钮
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(260, 7.5, 50, 30);
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [addButton setTitle:@"确定" forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:addButton];
    addButton.enabled=NO;
    bottomScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 260, 45)];
    // bottomScrollview.backgroundColor=[UIColor greenColor];
    [bottomNavibar addSubview:bottomScrollview];
    bottomScrollview.pagingEnabled = NO;
    bottomScrollview.showsHorizontalScrollIndicator = YES;
    bottomScrollview.showsVerticalScrollIndicator = YES;
    bottomScrollview.scrollsToTop = NO;
    
    self.rankLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 25, 260, 30)];
    self.rankLabel.backgroundColor=[UIColor clearColor];
    self.rankLabel.font=[UIFont systemFontOfSize:14];
    self.rankLabel.textColor=[UIColor grayColor];
    
    self.bussinesslLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 25, 260, 30)];
    self.bussinesslLabel.backgroundColor=[UIColor clearColor];
    self.bussinesslLabel.font=[UIFont systemFontOfSize:14];
    self.bussinesslLabel.textColor=[UIColor grayColor];
    
    self.bussinesslLabel.text=@"请选择";
    self.rankLabel.text=@"请选择";
}

-(void)bottomScrollviewShow
{
    
    for(UIView *view in [bottomScrollview subviews])
    {
        [view removeFromSuperview];
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	UITableViewCell *pageview;
	
	int nowindex=0;
	
	int iconSize = 30;
	
	UIButton *iconbutton;
    
    UILabel* nameLabel;
    
	int x;
	int y;
	int cx;
	int cy;
    x=0;
	y=0;
	cx=5;
	cy=0;
	pageview=[[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, bottomScrollview.frame.size.width, bottomScrollview.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
    Emp *emp;
    NSString *empLogo;
    NSMutableArray *selectArray = [NSMutableArray arrayWithArray:self.nowSelectedEmpArray];
	
	
    //	如果有选中的那么加到selectArray中
    //    for (int i=0; i<[self.employeeArray count]; i++) {
    //        emp=[self.employeeArray objectAtIndex:i];
    //        if (emp.isSelected) {
    //            [selectArray addObject:emp];
    //                   }
    //    }
    
    if ([selectArray count]==0) {
        addButton.enabled=NO;
        [addButton setTitle:@"确定" forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    }else
    {
        addButton.enabled=YES;
        NSString *titlestr=[NSString stringWithFormat:@"确定(%d)",[selectArray count]];
        [addButton setTitle:titlestr forState:UIControlStateNormal];
        addButton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
        if ([selectArray count]>80) {
            addButton.titleLabel.font=[UIFont boldSystemFontOfSize:9];
        }
    }
    for (int i=0; i<[selectArray count]; i++) {
        cx=cx+iconSize + 5;
        if (i==0) {
            cx=0;
        }
        emp=[selectArray objectAtIndex:i];
        //		update by shisp icon大小设为30，否则和文字重叠
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+3,iconSize,iconSize)];
        
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, iconSize , iconSize, 45 - iconSize - 6)];
        nameLabel.text=emp.emp_name;
        nameLabel.textAlignment=UITextAlignmentCenter;
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont boldSystemFontOfSize:9];
        [iconbutton addSubview:nameLabel];
        [nameLabel release];
        empLogo = emp.emp_logo;
        
        //	获取圆角的用户头像
        UIImage *image = [self getEmpLogo:emp];
        
        [iconbutton setBackgroundImage:image forState:UIControlStateNormal];
        iconbutton.tag=nowindex;
        
        iconbutton.backgroundColor=[UIColor clearColor];
        // [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
        // backView.image=[StringUtil getImageByResName:@"setting.png"];
        //[pageview addSubview:backView];
        [pageview addSubview:iconbutton];
        
        
        [iconbutton release];
        
    }
    pageview.frame=CGRectMake(0, 0,x+cx+45,45);
	pageview.backgroundColor=[UIColor clearColor];
	[bottomScrollview addSubview:pageview];
	bottomScrollview.contentSize = CGSizeMake(x+cx+45,45);
    CGPoint bottomOffset = CGPointMake(bottomScrollview.contentSize.width - bottomScrollview.bounds.size.width,0);
    [bottomScrollview setContentOffset:bottomOffset animated:NO];
    [pageview release];
    [pool release];
}


-(UIImage *)getEmpLogo:(Emp*)emp
{
	UIImage *image = nil;
	NSString *empLogo = emp.emp_logo;
	if(empLogo && [empLogo length] > 0)
	{
		NSString *picPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
		UIImage *img = [UIImage imageWithContentsOfFile:picPath];
        if (img)
		{
			image=[UIImage createRoundedRectImage:img size:CGSizeZero];
		}
	}
	if(image == nil)
	{
		if (emp.emp_sex==0)
		{//女
			image=[StringUtil getImageByResName:@"female.png"];
		}
		else
		{
			image=[StringUtil getImageByResName:@"male.png"];
		}
	}
	return image;
}
-(void)dismissSelf:(NSNotification *)notification
{
	
	[self dismissModalViewControllerAnimated:NO];
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    

	NSLog(@"本次选中的最多人数为%d",(maxGroupNum - self.oldEmpIdArray.count));

	
	self.employeeArray =  [NSMutableArray arrayWithArray:_conn.allEmpArray];
	self.deptArray=[NSMutableArray arrayWithArray:[_ecloud getDeptList]];

    if (bottomScrollview!=nil) {
        [self bottomScrollviewShow];
    }
    [chooseTable reloadData];
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

#pragma mark 提醒用户选择人数已经超过最大值
-(void)showGroupNumExceedAlert
{
	NSString *titlestr=[NSString stringWithFormat:@"群组的成员个数最多为%d个",maxGroupNum];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:titlestr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}

#pragma mark 选择后确定
-(void) addButtonPressed:(id) sender{
    //	关闭键盘
    //			判断选中的人员数量
    if([self.nowSelectedEmpArray count] > (maxGroupNum - self.oldEmpIdArray.count) )
    {
        [self showGroupNumExceedAlert];
        return;
    }
    [self.nowSelectedEmpArray addObjectsFromArray:self.oldEmpIdArray];
    NSMutableArray *newArray=[NSMutableArray array];
    NSMutableArray *oldArray=((specialChooseMemberViewController*)self.delegete).nowSelectedEmpArray;
    BOOL isexit=NO;
    for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
        Emp *emp1=[self.nowSelectedEmpArray objectAtIndex:i];
        isexit=NO;
        for (int j=0; j<[oldArray count]; j++) {
            Emp *emp2=[oldArray objectAtIndex:j];
            if (emp1.emp_id==emp2.emp_id) {
                isexit=YES;
                break;
            }
        }
        if (!isexit) {
            [newArray addObject:emp1];
        }
        
    }
    [ ((specialChooseMemberViewController*)self.delegete).nowSelectedEmpArray addObjectsFromArray:newArray];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

        return 2;
    
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   if (section==1) {
        return [self.chooseArray count];
       }else
       {
       return 3+[self.zoneArray count];
       }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        id temp=[self.chooseArray objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[Emp class]])
        {
            int indentation=0;
            indentation=((Emp *)temp).emp_level;
            
            return indentation;
        }else if([temp isKindOfClass:[Dept class]])
        {
            int indentation=0;
            indentation=((Dept *)temp).dept_level;
            
            return indentation;
        }
  
    }
    return 0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
         if(section==0)
        {
            return 20;
        }
        else
        {
            return 0;
        }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   if (section==0) {
            UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
            titlelabel.backgroundColor=[UIColor lightGrayColor];
            titlelabel.font=[UIFont systemFontOfSize:14];
            titlelabel.text=@" 选择搜索组合条件";
            return titlelabel;
        }else
        {
        return nil;
    }
    
}
-(void)titleButtonAction:(id)sender
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
     
        if (indexPath.row==2) {
            return 40;
        }else
        {
         return 58;
        }
    }else
    {
        id temp=[self.chooseArray objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[RecentMember class]]) {
            return 45;
        }// Configure the cell.
        else {
            if ([temp isKindOfClass:[Dept class]]) {
                return 42;
            }// Configure the cell.
            else {
                return 58;
            }
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.section==0&&indexPath.row>2) {
       return YES;
    }
   return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.zoneArray removeObjectAtIndex:indexPath.row-3];
        // Delete the row from the data source.
        [chooseTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        if (indexPath.section==0) {
             cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
           
            UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 260, 20)];
            titleLabel.tag=2;
            titleLabel.backgroundColor=[UIColor clearColor];
            titleLabel.font=[UIFont systemFontOfSize:14];
            [cell.contentView addSubview:titleLabel];
            [titleLabel release];
  
        }else{
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        selectView.tag=5;
        selectView.backgroundColor=[UIColor clearColor];
        cell.accessoryView=selectView;
		cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        }
        UILabel *onlineLabel=[[UILabel alloc]initWithFrame:CGRectMake(210, 5, 90, 30)];
        onlineLabel.backgroundColor=[UIColor clearColor];
        onlineLabel.tag=1;
        onlineLabel.hidden=YES;
        onlineLabel.textAlignment=UITextAlignmentCenter;
        onlineLabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:onlineLabel];
        [onlineLabel release];
        
    }
   

        if (indexPath.section==0) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray ;
            UILabel *titlelabel=(UILabel *)[cell.contentView viewWithTag:2];
          //  UILabel *detaillabel=(UILabel *)[cell.contentView viewWithTag:3];
            if (indexPath.row==0) {
                titlelabel.text=@"级别";
                [cell.contentView addSubview:self.rankLabel];
               
            }else if(indexPath.row==1)
            {
                titlelabel.text=@"业务";
               
                [cell.contentView addSubview:self.bussinesslLabel];
            }else if(indexPath.row==2)
            {
                    titlelabel.text=@"地域";
                   // detaillabel.text=@"全部地域";
                 
            }else
                {
                    id temp=[self.zoneArray objectAtIndex:indexPath.row-3];
                    citiesObject *city=(citiesObject *)temp;
                    titlelabel.text=city.some_cities;
                   cell.accessoryType=UITableViewCellAccessoryNone;
                }
            
        }else
        {
        UIButton *selectButton=(UIButton *)cell.accessoryView;
        selectButton.tag=indexPath.row;
         
        cell.textLabel.font=[UIFont systemFontOfSize:17];
        id temp=[self.chooseArray objectAtIndex:indexPath.row];
         if ([temp isKindOfClass:[Dept class]]) {
                Dept *dept = (Dept *)temp;
                
                if (dept.isExtended) {
                    cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic02.png"];
                }else
                {
                    cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic01.png"];
                }
             if(!selectButton.hidden)
             {
                 if (dept.isChecked) { //选中
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
             [selectButton addTarget:self action:@selector(selectChooseAction:) forControlEvents:UIControlEventTouchUpInside];
             selectButton.userInteractionEnabled=YES;
                cell.textLabel.text=dept.dept_name;//[NSString stringWithFormat:@"%@ [5/9]",dept.dept_name];;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
                onlineLabel.hidden=NO;
                onlineLabel.text=[NSString stringWithFormat:@"%d",dept.totalNum];
            }
            else if([temp isKindOfClass:[Emp class]])
            {
            Emp *emp=(Emp *)temp;
            
            for(Emp *_emp in self.oldEmpIdArray)
            {
                if(_emp.emp_id == emp.emp_id)
                {
                    selectButton.hidden = YES;
                    break;
                }
            }
            if(!selectButton.hidden)
            {
                if (emp.isSelected) { //选中
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
            selectButton.userInteractionEnabled=NO;
            if(_conn.userStatus == status_online)
            {
                if (emp.emp_status==status_online) {//在线
                    if (emp.emp_sex==0) {//女
                        cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_40.png"];
                    }else
                    {
                        cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_40.png"];
                    }
                }else if(emp.emp_status==status_leave)//离开
                {
                    if (emp.emp_sex==0) {//女
                        cell.imageView.image=[StringUtil getImageByResName:@"Female_ios_leave.png"];
                    }else
                    {
                        cell.imageView.image=[StringUtil getImageByResName:@"Male_ios_leave.png"];
                    }
                }else//离线，或离开
                {
                    cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
                }
            }
            else {
                cell.imageView.image=[StringUtil getImageByResName:@"Offline_ios_35.png"];
            }
            cell.imageView.userInteractionEnabled=YES;
            UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
            iconview.tag=indexPath.row;
            iconview.userInteractionEnabled=NO;
            [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.imageView addSubview:iconview];
            [iconview release];
            
            cell.textLabel.text=emp.emp_name;
            UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
            onlineLabel.hidden=YES;
        }
        
    }
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section==0) {
        if (indexPath.row==0) {
          if (rankChoose==nil) {
            rankChoose=[[rankChooseViewController alloc]init];
              rankChoose.delegete=self;
          }
        [self.navigationController pushViewController:rankChoose animated:YES];
            
        }else if(indexPath.row==1) {

            if (businessChoose==nil) {
                businessChoose=[[businessChooseViewController alloc]init];
                businessChoose.delegete=self;
            }
             [self.navigationController pushViewController:businessChoose animated:YES];
        }else if(indexPath.row==2) {
            
            if (zoneChoose==nil) {
                zoneChoose=[[zoneChooseViewController alloc]init];
                zoneChoose.delegete=self;
            }
            [self.navigationController pushViewController:zoneChoose animated:YES];
        }
        
    }else
    {
        id temp=[self.chooseArray objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[Emp class]])
        {
            int nowcount= [self.nowSelectedEmpArray count];// [selectedEmps count];
            
            //	找到复选框所在的行
            UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            UIButton *button=(UIButton *)[cell viewWithTag:5];
            //	取出对应行的对象是一个部门还是一个员工
            
            //       选中的是员工
            Emp *emp=(Emp *)temp;
            BOOL isOldMember=FALSE;
            for(Emp *_emp in self.oldEmpIdArray)
            {
                if(_emp.emp_id == emp.emp_id)
                {
                    isOldMember = true;
                    NSLog(@"%@是已有成员",emp.emp_name);
                    break;
                }
            }
            if (isOldMember) {
                return;
            }
            
            if (emp.isSelected) { //不选中
                emp.isSelected=false;
                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
                [button setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
            }else   //选中
            {
                if (nowcount+1>(maxGroupNum - self.oldEmpIdArray.count)) {
                    [self showGroupNumExceedAlert];
                    return;
                }
                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
                [button setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
                emp.isSelected=true;
            }
            [self selectByEmployee:emp.emp_id status:emp.isSelected];
            [chooseTable reloadData];
            //    显示在底部
            [self bottomScrollviewShow];
        }else if ([temp isKindOfClass:[Dept class]])
        {
            Dept *dept = (Dept *)temp;
            int level=dept.dept_level+1;
            if (dept.isExtended) { //收起展示
                dept.isExtended=false;
                int remvoecount=0;
                for (int i=indexPath.row+1; i<[self.chooseArray count]; i++) {
                    
                    
                    id temp1 = [self.chooseArray objectAtIndex:i];
                    
                    if([temp1 isKindOfClass:[Emp class]])
                    {
                        if (((Emp *)temp1).emp_level<=dept.dept_level) {
                            break;
                        }
                    }
                    
                    if([temp1 isKindOfClass:[Dept class]])
                    {
                        if (((Dept *)temp1).dept_level<=dept.dept_level) {
                            break;
                        }
                        
                    }
                    remvoecount++;
                }
                if (remvoecount!=0) {
                    NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                    [self.chooseArray removeObjectsInRange:range];
                }
                
                
            }else   //显示子部门及人员
            {
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                float noworigin=cell.frame.origin.y;
                
                NSMutableArray *allArray=[[NSMutableArray alloc]init];
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                NSArray *tempDeptArray=[advanceQueryDAO getTempDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked];
                if ([dept.subDeptsStr isEqualToString:@"0"]) {
                    NSArray *tempEpArray=[advanceQueryDAO getTempDeptEmpInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked andRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
                    [allArray addObjectsFromArray:tempEpArray];
                }
               
                [allArray addObjectsFromArray:tempDeptArray];
                [pool release];
                NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                [self.chooseArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                [allArray release];
                
                dept.isExtended=true;
                
                /*自动收起---------------------------------------------------------------bigen------------*/
                float isExtendedPoint=0;
                float sumnum=0;
                for (int i=0; i<[self.chooseArray count]; i++) {
                    id temp1 = [self.chooseArray objectAtIndex:i];
                    if([temp1 isKindOfClass:[Dept class]])
                    {   Dept*extendedDept=((Dept *)temp1);
                        if (extendedDept.dept_id!=dept.dept_id&&extendedDept.dept_level==dept.dept_level&&extendedDept.isExtended) {
                            NSIndexPath *tempindexpath=[NSIndexPath indexPathForRow:i inSection:0];
                            UITableViewCell *tempcell=[tableView cellForRowAtIndexPath:tempindexpath];
                            isExtendedPoint=tempcell.frame.origin.y;
                            
                            extendedDept.isExtended=false;
                            int remvoecount=0;
                            float emplen=0;
                            float deptlen=0;
                            for (int nowindex=i+1; nowindex<[self.chooseArray count]; nowindex++) {
                                
                                
                                id temp1 = [self.chooseArray objectAtIndex:nowindex];
                                
                                if([temp1 isKindOfClass:[Emp class]])
                                {
                                    if (((Emp *)temp1).emp_level<=extendedDept.dept_level) {
                                        break;
                                    }
                                    emplen+=58;
                                }
                                
                                if([temp1 isKindOfClass:[Dept class]])
                                {
                                    if (((Dept *)temp1).dept_level<=extendedDept.dept_level) {
                                        break;
                                    }
                                    deptlen+=42;
                                }
                                remvoecount++;
                            }
                            if (remvoecount!=0) {
                                NSRange range =NSMakeRange(i+1,remvoecount);
                                [self.chooseArray removeObjectsInRange:range];
                            }
                            sumnum=deptlen+emplen;
                            break;
                        }
                        
                    }
                }
                
                [tableView reloadData];
                
                //			[LogUtil debug:[NSString stringWithFormat:@" noworigin is %.0f isExtendedPoint is %.0f ,sumnum is %.0f",noworigin,isExtendedPoint,sumnum]];
                
                if (isExtendedPoint<noworigin) {
                    float offsetvalue=noworigin-sumnum;
                    if (offsetvalue<0) {
                        offsetvalue=noworigin;
                    }
                    tableView.contentOffset=CGPointMake(0,offsetvalue);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                }else{
                    tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                }
                
 
                
                //			[LogUtil debug:[NSString stringWithFormat:@"tableView.contentOffset %.0f", tableView.contentOffset.y]];
                
                
                /*自动收起*///---------------------------------------------------------------end------------//
                //            NSLog(@"---cell.offset-- %0.0f",tableView.contentOffset.y);
            }
            
            [tableView reloadData] ;
        }
        
    }
    
}

-(void)iconAction:(id)sender
{
}
//筛选结果
-(void)selectChooseAction:(id)sender
{
    int nowcount= [self.nowSelectedEmpArray count];
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    //	取出对应行的对象是一个部门还是一个员工
    id temp=[self.chooseArray objectAtIndex:row];
    //	如果是部门
    if([temp isKindOfClass:[Dept class]])
    {
        NSLog(@"----maxGroupNum--%d",maxGroupNum);
        //			判断选中的人员数量
        Dept *dept = (Dept *)temp;
        if (dept.isChecked) { //不选中
            dept.isChecked=false;
            [button setImage:[StringUtil getImageByResName:@"unselected.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"unselected.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"unselected.png"] forState:UIControlStateSelected];
        }else   //选中
        {
//            if ( nowcount+dept.totalNum>(maxGroupNum - self.oldEmpIdArray.count)) {
//				[self showGroupNumExceedAlert];
//                return;
//            }
            [button setImage:[StringUtil getImageByResName:@"selected.png"] forState:UIControlStateNormal];
            [button setImage:[StringUtil getImageByResName:@"selected.png"] forState:UIControlStateHighlighted];
            [button setImage:[StringUtil getImageByResName:@"selected.png"] forState:UIControlStateSelected];
            dept.isChecked=true;
        }
        //		设置部门，部门的子部门，部门员工，子部门员工的选中状态
     //   [self selectByDept:dept.dept_id status:dept.isChecked];
        NSString *deptid=[NSString stringWithFormat:@"%d",dept.dept_id];
        NSArray *emp_array=[advanceQueryDAO getTempDeptEmpByParent:deptid andSelected:dept.isChecked andRank:self.rank_list_str andBusiness:self.business_list_str andCity:city_list_str];
        for (int i=0; i<[emp_array count]; i++) {
            Emp *emp=[emp_array objectAtIndex:i];
            [self updateNowSelectedEmp:emp];
            
        }
         [self bottomScrollviewShow];
        //		把选中状态呈现在界面上
        for (int i=row+1; i<[self.chooseArray count]; i++) {
            id temp1 = [self.chooseArray objectAtIndex:i];
            if([temp1 isKindOfClass:[Emp class]])
            {
                if (((Emp *)temp1).emp_level<=dept.dept_level) {
                    break;
                }
                ((Emp *)temp1).isSelected=dept.isChecked;
            }
            
            if([temp1 isKindOfClass:[Dept class]])
            {
                if (((Dept *)temp1).dept_level<=dept.dept_level) {
                    break;
                }
                ((Dept *)temp1).isChecked=dept.isChecked;
            }
        }
        
        [chooseTable reloadData];
        
    }
}

//选中或未选中
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus
{
    //	部门id
    NSString *dept_id_str=[NSString stringWithFormat:@"%d",dept_id];
    //	部门的子部门
    NSArray *tempArray=[_ecloud getChildDepts:dept_id_str];
    Emp *emp;
    NSString *deptId;
    
    //    设置子部门下的员工的选中状态
    for (int i=0; i<[self.employeeArray count]; i++) {
        
        emp=[self.employeeArray objectAtIndex:i];
        for (int j=0;j<[tempArray count]; j++) {
            
            deptId=[tempArray objectAtIndex:j];
            if (emp.emp_dept==[deptId intValue])
			{
				bool isOldMember = false;
				for(Emp *_emp in self.oldEmpIdArray)
				{
					if(_emp.emp_id == emp.emp_id)
					{
						isOldMember = true;
						NSLog(@"%@是已有成员",emp.emp_name);
						break;
					}
				}
				if(isOldMember)
					continue;
				
                emp.isSelected=selectedStatus;
				[self updateNowSelectedEmp:emp];
				break;
            }
        }
    }
	[self displayNowSelectedEmp];
    Dept *dept;
    //    设置子部门的选中状态
    for (int i=0; i<[self.deptArray count]; i++) {
        dept=[self.deptArray objectAtIndex:i];
        for (int j=0;j<[tempArray count]; j++) {
            
            deptId=[tempArray objectAtIndex:j];
            if (dept.dept_id==[deptId intValue]) {
                dept.isChecked=selectedStatus;
				break;
            }
        }
    }
}

#pragma mark 选中或反选一个emp时，修改现在选中的emp的数组
-(void)updateNowSelectedEmp:(Emp *)emp
{
	if(emp.isSelected)
	{
		bool isNowSelected = false;
		for(Emp *_emp in self.nowSelectedEmpArray)
		{
			if(_emp.emp_id == emp.emp_id)
			{
				isNowSelected = true;
				NSLog(@"%@已经选中",_emp.emp_name);
				break;
			}
		}
		if(!isNowSelected)
		{
			[self.nowSelectedEmpArray addObject:emp];
		}
	}
	else
	{
		for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
            Emp *deleteEmp=[self.nowSelectedEmpArray objectAtIndex:i];
            if (deleteEmp.emp_id==emp.emp_id) {
                [self.nowSelectedEmpArray removeObject:deleteEmp];
            }
        }
	}
}
-(void)displayNowSelectedEmp
{
	NSLog(@"选中个数：%d",self.nowSelectedEmpArray.count);
	for(Emp * _emp in self.nowSelectedEmpArray)
	{
		NSLog(@"%@",_emp.emp_name);
	}
}

-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus
{
    Emp *emp;
    
    for (int i=0; i<[self.employeeArray count]; i++) {
        emp=[self.employeeArray objectAtIndex:i];
        if (emp.emp_id==emp_id) {
            emp.isSelected=selectedStatus;
			[self updateNowSelectedEmp:emp];
			break;
        }
    }
	[self displayNowSelectedEmp];
}
#pragma mark 
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
