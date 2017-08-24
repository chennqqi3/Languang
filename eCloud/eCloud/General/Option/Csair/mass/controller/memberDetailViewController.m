//
//  memberDetailViewController.m
//  eCloud
//
//  Created by  lyong on 14-1-8.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "memberDetailViewController.h"
#import "eCloudDefine.h"
#import "Emp.h"
#import "AdvanceQueryDAO.h"
#import "personInfoViewController.h"
#import "userInfoViewController.h"
#import "LCLLoadingView.h"
#import "eCloudDAO.h"
#import "conn.h"
#import "Dept.h"

@interface memberDetailViewController ()

@end

@implementation memberDetailViewController
{
AdvanceQueryDAO *advanceQueryDAO;
personInfoViewController *personInfo;
    eCloudDAO *db;
}
@synthesize chooseArray;
@synthesize emp_id_list;

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
 [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
 [[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];
}
-(void)handleCmd:(NSNotification *)notification
{
	eCloudNotification *cmd = [notification object];
	if(cmd != nil)
	{
		int cmdId = cmd.cmdId;
        switch (cmdId) {
            case get_user_info_success:
			{
				NSLog(@"get user info success");
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				NSString* empId = [cmd.info objectForKey:@"EMP_ID"];
				Emp *emp = [db getEmpInfo:empId];
				
				personInfo.titleStr=emp.emp_name;
				personInfo.sexType=emp.emp_sex;
				personInfo.emp=emp;
				[self.navigationController pushViewController:personInfo animated:YES];
                //				[self presentModalViewController:personInfo animated:YES];
				//			[personInfo release];
				
			}
				break;
			case get_user_info_timeout:
			{
				NSLog(@"get user info timeout ......");
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				[self.navigationController pushViewController:personInfo animated:YES];
				
                //				[self presentModalViewController:personInfo animated:YES];
				//			[personInfo release];
				
			}
				break;
				
			case get_user_info_failure:
			{
				NSLog(@"get user info failure");
				
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				[self.navigationController pushViewController:personInfo animated:YES];
                
                //				[self presentModalViewController:personInfo animated:YES];
				//			[personInfo release];
				
			}

        }
    }
}
//返回 按钮
-(void) backButtonPressed:(id) sender{

	[self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
	// Do any additional setup after loading the view.
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
    advanceQueryDAO = [AdvanceQueryDAO getDataBase];
    self.chooseArray=[advanceQueryDAO getTempDeptInfoWithLevel:@"0" andLevel:0 andSelected:false];
     personInfo=[[personInfoViewController alloc]init];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    //	组织架构展示table
	int tableH = 460 - 85+44;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    chooseTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
    [chooseTable setDelegate:self];
    [chooseTable setDataSource:self];
    chooseTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:chooseTable];
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
    return 0;
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
        if ([temp isKindOfClass:[Dept class]]) {
                return 42;
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

        UILabel *onlineLabel=[[UILabel alloc]initWithFrame:CGRectMake(320-60, 5, 60, 30)];
        onlineLabel.backgroundColor=[UIColor clearColor];
        onlineLabel.tag=1;
        onlineLabel.hidden=YES;
        onlineLabel.textAlignment=UITextAlignmentCenter;
        onlineLabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:onlineLabel];
        [onlineLabel release];
        
    }
    
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
     
          //  [selectButton addTarget:self action:@selector(selectChooseAction:) forControlEvents:UIControlEventTouchUpInside]
            cell.textLabel.text=dept.dept_name;//[NSString stringWithFormat:@"%@ [5/9]",dept.dept_name];;
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
            onlineLabel.hidden=NO;
            onlineLabel.text=[NSString stringWithFormat:@"%d",dept.totalNum];
        }
        else if([temp isKindOfClass:[Emp class]])
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            Emp *emp=(Emp *)temp;

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

            
            cell.textLabel.text=emp.emp_name;
            UILabel *onlineLabel=(UILabel *)[cell.contentView viewWithTag:1];
            onlineLabel.hidden=YES;
        }
        
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

        id temp=[self.chooseArray objectAtIndex:indexPath.row];
       if ([temp isKindOfClass:[Dept class]])
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
                    NSArray *tempEpArray=[advanceQueryDAO getTempDeptEmpInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked andEmpList:self.emp_id_list];
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
        }else if ([temp isKindOfClass:[Emp class]])
        {
            Emp *emp=(Emp *)temp;

            if(emp.emp_id == [_conn.userId intValue])
            {
                //		打开用户自己的资料
                userInfoViewController *userInfo = [[userInfoViewController alloc]init];
                userInfo.tagType=1;
                userInfo.emp=emp;
                userInfo.titleStr=emp.emp_name;
                [self.navigationController pushViewController:userInfo animated:YES];
                [userInfo release];
                return;
            }
            personInfo.emp=emp;
            [self.navigationController pushViewController:personInfo animated:YES];
        }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
