//
//  broadcastRecoredMoreMemberViewController.m
//  eCloud
//
//  Created by  lyong on 14-1-10.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "broadcastRecoredMoreMemberViewController.h"
#import "eCloudDefine.h"
#import "ImageUtil.h"
#import "talkSessionViewController.h"
#import "MassDAO.h"
#import "EmpCell.h"
#import "UIAdapterUtil.h"
#import "MessageView.h"
#import "Emp.h"
#import "Dept.h"
#import "ConvRecord.h"
#import "conn.h"

@interface broadcastRecoredMoreMemberViewController ()
{
talkSessionViewController *talkSession;
     MassDAO *massDAO;
}
@property(nonatomic,retain)talkSessionViewController *talkSession;
@property(nonatomic,retain)MassDAO *massDAO;
@end

@implementation broadcastRecoredMoreMemberViewController
@synthesize otheremps_Array;
@synthesize massDAO;
@synthesize talkSession;
@synthesize msg_id;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //适配ios7UIViewController的变化
    [UIAdapterUtil processController:self];
    
    self.title=@"回复列表";
    _conn = [conn getConn];
    self.massDAO = [MassDAO getDatabase];
    if(self.talkSession == nil)
		self.talkSession = [[talkSessionViewController alloc]init];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];

	// Do any additional setup after loading the view.
    //	组织架构展示table
	int tableH = self.view.frame.size.height-45;

    broadcastMemberListTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
    [broadcastMemberListTable setDelegate:self];
    [broadcastMemberListTable setDataSource:self];
    broadcastMemberListTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:broadcastMemberListTable];
}
#pragma  table
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return [self.otheremps_Array count];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
    
    if ([temp isKindOfClass:[Dept class]]) {
        return 45;
    }// Configure the cell.
    else {
        return 58;
    }
    
    
}

#pragma mark 获取员工的显示方式
-(EmpCell *)getEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpCell *empCell = [broadcastMemberListTable dequeueReusableCellWithIdentifier:empCellID];
	if(empCell == nil)
	{
		empCell = [[[EmpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
		
		UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
        detailButton.hidden=YES;
        
        UIButton *redButton=[[UIButton alloc]initWithFrame:CGRectMake(320-40, 5, 30, 20)];
        
        redButton.backgroundColor=[UIColor clearColor];
        redButton.tag=emp_red_tag;
        redButton.hidden=YES;
        //onlineLabel.textAlignment=UITextAlignmentCenter;
        redButton.font=[UIFont systemFontOfSize:12];
        [empCell.contentView addSubview:redButton];
        [redButton release];
        
	}
	
	Emp *emp = [self.otheremps_Array objectAtIndex:indexPath.row];
	[empCell configureCell:emp];
    
    UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
    UIButton *redButton = (UIButton*)[empCell viewWithTag:emp_red_tag];
    redButton.userInteractionEnabled=NO;
    if (emp.unread>0) {
        redButton.frame=CGRectMake(detailButton.frame.origin.x+15, 5, 30, 20);
      	redButton.hidden=NO;
        UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
        MessageView *messageView = [MessageView getMessageView];
        newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
        [redButton setBackgroundImage:newMsgImage forState:UIControlStateNormal];
        [redButton setTitle:[NSString stringWithFormat:@"%d",emp.unread] forState:UIControlStateNormal];
       
  
    }else
    {
        redButton.hidden=YES;
    }
	return empCell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            UIButton *onlineLabel=[[UIButton alloc]initWithFrame:CGRectMake(320-40, 5, 30, 20)];
           
            onlineLabel.backgroundColor=[UIColor clearColor];
            onlineLabel.tag=1;
            onlineLabel.hidden=YES;
            //onlineLabel.textAlignment=UITextAlignmentCenter;
            onlineLabel.font=[UIFont systemFontOfSize:12];
            [cell.contentView addSubview:onlineLabel];
            [onlineLabel release];
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        UIButton *selectButton=(UIButton *)cell.accessoryView;
        selectButton.tag=indexPath.row;
        
        cell.textLabel.font=[UIFont systemFontOfSize:17];
        id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[Dept class]]) {
            Dept *dept = (Dept *)temp;
           
            if (dept.isExtended) {
                cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic02.png"];
            }else
            {
                cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic01.png"];
            }
            cell.textLabel.text=dept.dept_name;//[NSString stringWithFormat:@"%@ [5/9]",dept.dept_name];;
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            if (dept.totalNum) {
                UIButton *onlineLabel=(UIButton *)[cell.contentView viewWithTag:1];
                onlineLabel.hidden=NO;
                UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
                MessageView *messageView = [MessageView getMessageView];
                newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
                newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
                [onlineLabel setBackgroundImage:newMsgImage forState:UIControlStateNormal];
                [onlineLabel setTitle:[NSString stringWithFormat:@"%d",dept.totalNum] forState:UIControlStateNormal];  
            }
        }
        else if([temp isKindOfClass:[Emp class]])
        {
          return [self getEmpCell:indexPath];
        }

    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

        id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
        if ([temp isKindOfClass:[Emp class]])
        {
            Emp *emp=(Emp *)temp;
            MassDAO *massDAO = [MassDAO getDatabase];
            [massDAO transferMassMsgByMsgId:self.msg_id andEmpId:emp.emp_id andReplyCount:emp.unread];
            self.talkSession.talkType = singleType;
            self.talkSession.titleStr = emp.emp_name;
            self.talkSession.convId =[NSString stringWithFormat:@"%d",emp.emp_id];
             self.talkSession.convEmps = [NSArray arrayWithObject:emp];
            //         self.talkSession.delegete=self;
            self.talkSession.needUpdateTag=1;
			self.talkSession.fromType = 1;
            //			self.talkSession.hidesBottomBarWhenPushed = YES;
            for(UIViewController *controller in self.navigationController.viewControllers)
            {
                if([controller isKindOfClass:[talkSessionViewController class]])
                {
                    [self.navigationController popToViewController:talkSession animated:YES];
                    return;
                }
            }
            // [self hideTabBar];
            [self.navigationController pushViewController:self.talkSession animated:YES];;
        }else if ([temp isKindOfClass:[Dept class]])
        {
            Dept *dept = (Dept *)temp;
            int level=dept.dept_level+1;
            if (dept.isExtended) { //收起展示
                dept.isExtended=false;
                int remvoecount=0;
                for (int i=indexPath.row+1; i<[self.otheremps_Array count]; i++) {
                    
                    
                    id temp1 = [self.otheremps_Array objectAtIndex:i];
                    
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
                    [self.otheremps_Array removeObjectsInRange:range];
                }
                
                
            }else   //显示子部门及人员
            {
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                float noworigin=cell.frame.origin.y;
                
                NSMutableArray *allArray=[[NSMutableArray alloc]init];
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                NSArray *tempDeptArray=[self.massDAO getTempDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked andMsgId:self.msg_id];
               // if ([dept.subDeptsStr isEqualToString:@"0"]) {
                    NSArray *tempEpArray=[self.massDAO  getTempDeptEmpInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked andMsgId:self.msg_id];
                    [allArray addObjectsFromArray:tempEpArray];
              //  }
                
                [allArray addObjectsFromArray:tempDeptArray];
                [pool release];
                NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                [self.otheremps_Array insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                [allArray release];
                
                dept.isExtended=true;
                
                /*自动收起---------------------------------------------------------------bigen------------*/
                float isExtendedPoint=0;
                float sumnum=0;
                for (int i=0; i<[self.otheremps_Array count]; i++) {
                    id temp1 = [self.otheremps_Array objectAtIndex:i];
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
                            for (int nowindex=i+1; nowindex<[self.otheremps_Array count]; nowindex++) {
                                
                                
                                id temp1 = [self.otheremps_Array objectAtIndex:nowindex];
                                
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
                                [self.otheremps_Array removeObjectsInRange:range];
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
                    tableView.contentOffset=CGPointMake(0,offsetvalue);NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                }else{
                    tableView.contentOffset=CGPointMake(0,noworigin);NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                }
                
            }
            
            [tableView reloadData] ;
        }

    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
