//
//  contactListViewController.m
//  eCloud
//
//  Created by  lyong on 13-3-19.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "contactListViewController.h"
#import "eCloudDAO.h"
#import "UIAdapterUtil.h"
#import "Conversation.h"
#import "contactViewController.h"
#import "UIAdapterUtil.h"
#import "conn.h"
#import "Emp.h"
#import "personInfoViewController.h"
#import "VirGroupObj.h"
#import "userInfoViewController.h"
#import "OffenGroup.h"
#import "talkSessionViewController.h"

@interface contactListViewController ()

@end

@implementation contactListViewController
{
	eCloudDAO *db;
}
@synthesize itemArray;
@synthesize talkSession;
-(void)dealloc
{
	self.itemArray = nil;
	self.talkSession = nil;
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
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	db = [eCloudDAO getDatabase];
	
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
        //	右边按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 0, 44, 44);
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"add_connet.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:addButton] autorelease];
    _conn = [conn getConn];
    //最近会话展示窗口
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
	
	int tableH = 420;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    personTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
    [personTable setDelegate:self];
    [personTable setDataSource:self];
    personTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:personTable];
    
	personInfo = [[personInfoViewController alloc]init];
    tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 50, 320, 100)];
    tiplabel.backgroundColor=[UIColor clearColor];
    tiplabel.textAlignment=UITextAlignmentCenter;
    tiplabel.text=@"请在通讯录中选择添加常用联系人";
    tiplabel.textColor=[UIColor grayColor];
    [self.view addSubview:tiplabel];
    tiplabel.hidden=YES;
    noflushTag=0;
	self.itemArray = [NSMutableArray array];
}
-(void) addButtonPressed:(id) sender{
   
//	
// 	chooseContact=[[addContactPersonToBeOffen alloc]init];
//    [self.navigationController pushViewController:chooseContact animated:YES];
//	[chooseContact release];
//    //    [self.navigationController presentModalViewController:chooseMember animated:YES];
    
}
-(void)viewWillAppear:(BOOL)animated
{
	//[self displayTabBar];
	self.navigationController.navigationBarHidden = NO;
    
    if (personTable!=nil) {
        if (noflushTag==1) {
            noflushTag=0;
            return;
        }
		
		[self.itemArray removeAllObjects];
        
         NSArray *offengroupArray=[db getOffenGroup:@"-2" andLevel:0];
        NSArray *tempEpArray=[db getEmpFromVirGroup:@"-1" andLevel:0];
        
        int offengroupCount=[offengroupArray count];
        int empCount=[tempEpArray count];
        
   
        NSArray *virgroups=[db getVirGroups];
        int virgroupCount=[virgroups count];
        if ((offengroupCount+empCount+virgroupCount)!=2){
        
        [self.itemArray addObjectsFromArray:virgroups];
        int sum_count =[self.itemArray count];
        if(sum_count==0)return;
            
        VirGroupObj *vgroupOBJ = [self.itemArray objectAtIndex:sum_count-1];
        if ([vgroupOBJ.virgroup_id isEqualToString:@"-1"]) {
            int level=vgroupOBJ.virgroup_level+1;
            NSArray *tempEpArray=[db getEmpFromVirGroup:vgroupOBJ.virgroup_id andLevel:level];
            NSMutableArray *allArray=[[NSMutableArray alloc]init];
            [allArray addObjectsFromArray:tempEpArray];
            int count=[tempEpArray count];
            if (count>0) {
                NSRange range =NSMakeRange(sum_count, [allArray count]);
                [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                vgroupOBJ.isExtended=true;
            }
			[allArray release];
        }
        
       // [self.itemArray removeObjectAtIndex:sum_count-1];
        //[self.itemArray addObjectsFromArray:emps];
        [personTable reloadData];
      }
    }
    if ([self.itemArray count]>0) {
        personTable.hidden=NO;
        tiplabel.hidden=YES;
    }else
    {
        personTable.hidden=YES;
        tiplabel.hidden=NO;
    }
}
-(void)viewDidAppear:(BOOL)animated
{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    
	return [self.itemArray count];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id item=[self.itemArray objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
	{
		
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		
		UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 35, 35)];
        iconview.tag=1;
        iconview.hidden=YES;
        [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:iconview];
        [iconview release];
        
        UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(60, 20, 200, 20)];
        namelable.tag=2;
        namelable.font=[UIFont boldSystemFontOfSize:14];
		
		
        namelable.backgroundColor=[UIColor clearColor];
        namelable.textColor=[UIColor blackColor];
        [cell.contentView addSubview:namelable];
        [namelable release];
        
        UILabel *signatureLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 35, 200, 30)];
        signatureLabel.backgroundColor=[UIColor clearColor];
        signatureLabel.tag=3;
        signatureLabel.hidden=YES;
        signatureLabel.textColor=[UIColor grayColor];
        signatureLabel.textAlignment=UITextAlignmentLeft;
        signatureLabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:signatureLabel];
        [signatureLabel release];
        
        UILabel *mtiplabel=[[UILabel alloc]initWithFrame:CGRectMake(30, 40, 220, 20)];
        mtiplabel.tag=4;
        mtiplabel.font=[UIFont systemFontOfSize:14];
        mtiplabel.backgroundColor=[UIColor clearColor];
        mtiplabel.textColor=[UIColor grayColor];
        mtiplabel.text=@"(请在通讯录中选择添加常用联系人)";
        mtiplabel.hidden=YES;
        mtiplabel.textAlignment=UITextAlignmentLeft;
        [cell.contentView addSubview:mtiplabel];
        [mtiplabel release];
        
        UIButton *detailButton=[[UIButton alloc]initWithFrame:CGRectMake(320-100/96.0*58, 0, 100/96.0*58, 58)];
        detailButton.tag=7;
        detailButton.hidden=YES;
        //[detailButton addTarget:self action:@selector(DetailAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:detailButton];
        [detailButton release];
        
        }
        cell.backgroundColor=[UIColor clearColor];
     if ([item isKindOfClass:[VirGroupObj class]]) 
        {
            VirGroupObj *groupOBJ=item;
            if (groupOBJ.isExtended) {
                cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic02.png"];
            }else
            {
                cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic01.png"];
            }
            UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
            namelabel.frame=CGRectMake(30, 20, 200, 20);
            namelabel.text=groupOBJ.virgroup_name;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (![groupOBJ.virgroup_id isEqualToString:@"-1"]&&![groupOBJ.virgroup_id isEqualToString:@"-2"]) {
                UIButton * detailButton=(UIButton *)[cell viewWithTag:7];
                detailButton.titleLabel.text=[NSString stringWithFormat:@"%d",indexPath.row];
                detailButton.hidden=NO;
                detailButton.frame=CGRectMake(320-55, 10, 40, 40);
                [detailButton setImage:[StringUtil getImageByResName:@"Group_ios.png"] forState:UIControlStateNormal];
                [detailButton addTarget:self action:@selector(startGroupChat:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
//             UILabel *tlable=(UILabel *)[cell.contentView viewWithTag:4];
//             tlable.hidden=NO;
            }
         
        }else if([item isKindOfClass:[OffenGroup class]])
        {
            OffenGroup *offengroup=item;
            cell.imageView.image= [StringUtil getImageByResName:@"Group_ios_40.png"];
            UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
            namelabel.text=offengroup.group_title;
        }
        else{
        Emp *emp=item;
        UIButton *iconview=(UIButton *)[cell.contentView viewWithTag:1];
            iconview.hidden=NO;
        iconview.titleLabel.text=[NSString stringWithFormat:@"%d",indexPath.row];
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
        
        // iconview.image=[StringUtil getImageByResName:@"person.png"];
        UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
        namelabel.text=emp.emp_name;
      if (emp.signature!=nil&&[emp.signature length]>0) {
        UILabel *signatureLabel=(UILabel *)[cell.contentView viewWithTag:3];
        signatureLabel.hidden=NO;
        signatureLabel.text=emp.signature;
       }else
       {
        UILabel *signatureLabel=(UILabel *)[cell.contentView viewWithTag:3];
        signatureLabel.hidden=YES;
       }

    UIButton * detailButton=(UIButton *)[cell viewWithTag:7];
    detailButton.titleLabel.text=[NSString stringWithFormat:@"%d",indexPath.row];
    detailButton.hidden=NO;
    detailButton.frame=CGRectMake(320-100/96.0*58, 0, 100/96.0*58, 58);
			[detailButton setImage:[StringUtil getImageByResName:@"detail.png"] forState:UIControlStateNormal];
            [detailButton setImage:[StringUtil getImageByResName:@"detail_click.png"] forState:UIControlStateHighlighted];
            [detailButton setImage:[StringUtil getImageByResName:@"detail_click.png"] forState:UIControlStateSelected];
			
      [detailButton addTarget:self action:@selector(DetailAction:) forControlEvents:UIControlEventTouchUpInside];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失

    id item=[self.itemArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[Emp class]]) {
        noflushTag=1;
        Emp *emp=item;
        if ([_conn.userId intValue]==emp.emp_id) {
            
            if (userInfo==nil) {
                userInfo=[[userInfoViewController alloc]init];
            }
            userInfo.tagType=1;
            userInfo.titleStr=emp.emp_name;
			[self hideTabBar];
			[self.navigationController pushViewController:userInfo animated:YES];            
            return;
        }
//        update by shisp 选择常用联系人，打开聊天界面
        [UIAdapterUtil openConversation:self andEmp:emp];
        
    }
    else if([item isKindOfClass:[OffenGroup class]])
    {
        OffenGroup *offengroup=item;
        
//		增加判断会话表里是否还存在此会话，如果不存在，那么就增加此会话
        NSDictionary *_dic = [db searchConversationBy:offengroup.group_id];
        int last_msg_id = -1;
		if(!_dic)
		{
			//				单人会话
			NSString *convType = [StringUtil getStringValue:mutiableType];
			//				不屏蔽
			NSString *recvFlag = [StringUtil getStringValue:open_msg];
			
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:offengroup.group_id,@"conv_id",convType,@"conv_type",offengroup.group_title,@"conv_title",recvFlag,@"recv_flag",_conn.userId,@"create_emp_id",@"",@"create_time", nil];
			
			//		增加会话数据
			[db addConversation:[NSArray arrayWithObject:dic]];
		}
        else
        {
            last_msg_id = [[_dic valueForKey:@"last_msg_id"]intValue];
        }
        
//        修改打开常用群组的代码 update by shisp
        Conversation *conv = [[Conversation alloc]init];
        conv.conv_type = mutiableType;
        conv.conv_title = offengroup.group_title;
        conv.conv_id = offengroup.group_id;
        conv.recordType = normal_conv_record_type;
        conv.last_msg_id = last_msg_id;
        
        contactViewController *contactView = [UIAdapterUtil getContactViewController:self];
        [contactView openConversation:conv];
        [conv release];
        
//        [self.tabBarController setSelectedIndex:0];
        [UIAdapterUtil showChatPage:self];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        VirGroupObj *vgroupOBJ = [self.itemArray objectAtIndex:indexPath.row];
        int level=vgroupOBJ.virgroup_level+1;
        if (vgroupOBJ.isExtended) { //收起展示
            vgroupOBJ.isExtended=false;
            int remvoecount=0;
            for (int i=indexPath.row+1; i<[self.itemArray count]; i++) {
                
                
                id temp1 = [self.itemArray objectAtIndex:i];
                
                if([temp1 isKindOfClass:[Emp class]])
                {
                    if (((Emp *)temp1).emp_level<=vgroupOBJ.virgroup_level) {
                        break;
                    }
                }
                if([temp1 isKindOfClass:[OffenGroup class]])
                {
                    if (((OffenGroup *)temp1).group_level<=vgroupOBJ.virgroup_level) {
                        break;
                    }
                }
                if([temp1 isKindOfClass:[VirGroupObj class]])
                {
                    if (((VirGroupObj *)temp1).virgroup_level<=vgroupOBJ.virgroup_level) {
                        break;
                    }
                    
                }
                remvoecount++;
            }
            if (remvoecount!=0) {
                NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                [self.itemArray removeObjectsInRange:range];
            }
            
            
        }else   //显示子部门及人员
        {
            if ([vgroupOBJ.virgroup_id isEqualToString:@"-2"]) {
                
                NSLog(@"常用群组");
                NSArray *tempEpArray=[db getOffenGroup:vgroupOBJ.virgroup_id andLevel:level];
                NSMutableArray *allArray=[[NSMutableArray alloc]init];
                [allArray addObjectsFromArray:tempEpArray];
                NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                vgroupOBJ.isExtended=true;
                
            }else
            {
                
            NSArray *tempEpArray=[db getEmpFromVirGroup:vgroupOBJ.virgroup_id andLevel:level];
            NSMutableArray *allArray=[[NSMutableArray alloc]init];
            [allArray addObjectsFromArray:tempEpArray];
            int count=[tempEpArray count];
            
            NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
            [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
            vgroupOBJ.isExtended=true;
            
            if ([vgroupOBJ.virgroup_id isEqualToString:@"-1"]&&count==0) {
                UIAlertView *tempalert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请在通讯录中选择添加常用联系人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [tempalert show];
                [tempalert release];
              }
           }
        }
        
        [tableView reloadData] ;
        
    }
}
//修改删除按钮的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id item=[self.itemArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[Emp class]]) {
         Emp *emp = item;
        if ([emp.deptName isEqualToString:@"-1"]) {
            return YES;
        }
        else
         {
          return NO;
         }
    }
    
    if ([item isKindOfClass:[OffenGroup class]]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id item=[self.itemArray objectAtIndex:indexPath.row];
        if ([item isKindOfClass:[Emp class]])
        {
		Emp *emp=item;
		[db deleteContactPersonFromVirGroup:emp.emp_id];
		[self.itemArray removeObjectAtIndex:indexPath.row];
        NSMutableArray *array=[[NSMutableArray alloc]init];
        [array addObject:emp];
        [[conn getConn]deleteSynchronousMember:array];
        [array release];
		//[tableView reloadData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([self.itemArray count]>0) {
            personTable.hidden=NO;
            tiplabel.hidden=YES;
        }else
        {
            personTable.hidden=YES;
            tiplabel.hidden=NO;
        }
       }else if([item isKindOfClass:[OffenGroup class]])
       {
           OffenGroup *offengroup=item;
           [db deleteOffenGroupFromVirGroup:offengroup.group_id];
           [self.itemArray removeObjectAtIndex:indexPath.row];
           //[tableView reloadData];
           [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
       
       }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(void)iconAction:(id)sender
{
     noflushTag=1;
    UIButton *button=(UIButton *)sender;
    int index=[button.titleLabel.text intValue];
    Emp *emp=[self.itemArray objectAtIndex:index];
    if ([_conn.userId intValue]==emp.emp_id) {
        
        if (userInfo==nil) {
            userInfo=[[userInfoViewController alloc]init];
        }
        userInfo.tagType=1;
		userInfo.titleStr=emp.emp_name;
		[self hideTabBar];
		[self.navigationController pushViewController:userInfo animated:YES];
        return;
    }
    personInfo.emp= [db getEmpInfo:[StringUtil getStringValue:(emp.emp_id)]];
    [self.navigationController pushViewController:personInfo animated:YES];
}
-(void)startGroupChat:(id)sender
{
//    暂时先不修改，目前没有虚拟组 add by shisp
     noflushTag=1;
    UIButton *button=(UIButton *)sender;
    int index=[button.titleLabel.text intValue];
    VirGroupObj *virObj=[self.itemArray objectAtIndex:index];
    self.talkSession.talkType = mutiableType;
    self.talkSession.titleStr = virObj.virgroup_name;
    self.talkSession.convId = virObj.virgroup_id;
    self.talkSession.needUpdateTag=1;
    self.talkSession.isVirGroup=true;
    self.talkSession.convEmps = [db getEmpsFromVirGroupByVirgroupid:virObj.virgroup_id];
	
	[self hideTabBar];
	[self.navigationController pushViewController:personInfo animated:YES];

//    [self presentModalViewController:self.talkSession animated:YES];

    NSLog(@"---------startGroupChat");
}

-(void)DetailAction:(id)sender
{    noflushTag=1;
    UIButton *button=(UIButton *)sender;
    int index=[button.titleLabel.text intValue];
    Emp *emp=[self.itemArray objectAtIndex:index];
    if ([_conn.userId intValue]==emp.emp_id) {
        
        if (userInfo==nil) {
            userInfo=[[userInfoViewController alloc]init];
        }
        userInfo.tagType=1;
		userInfo.titleStr=emp.emp_name;
		[self hideTabBar];
		[self.navigationController pushViewController:userInfo animated:YES];
        return;
    }

    personInfo.emp= [db getEmpInfo:[StringUtil getStringValue:(emp.emp_id)]];
    [self.navigationController pushViewController:personInfo animated:YES];
}
-(void)displayTabBar
{
    /*
	//	add by shisp 2013.6.16
	//	在隐藏的情况下，显示出来，并且
	if(self.tabBarController && self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上减去tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		//NSLog(@"tabbar height is %.0f",_tabBar.frame.size.height);
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height - _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		self.tabBarController.tabBar.hidden = NO;
		
	}
     */
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}

-(void)hideTabBar
{
	/*
	//	add by shisp 2013.6.16
	//	如果tabbar是显示的状态那么
	if(self.tabBarController && 	!self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上加上tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height + _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		//NSLog(@"height is %.0f",contentView.frame.size.height);
		
		//		隐藏UITabBar
		self.tabBarController.tabBar.hidden = YES;
		
	}
     */
    
    [UIAdapterUtil hideTabBar:self];
}


@end
