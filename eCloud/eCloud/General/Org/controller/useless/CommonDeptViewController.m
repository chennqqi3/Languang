
#import "CommonDeptViewController.h"
#import "eCloudDAO.h"
#import "Conversation.h"
#import "contactViewController.h"
#import "UIAdapterUtil.h"
#import "UserDataDAO.h"
#import "DeptCell.h"
#import "EmpCell.h"
#import "conn.h"
#import "Emp.h"
#import "personInfoViewController.h"
#import "userInfoViewController.h"
#import "AddCommonDeptViewController.h"
#import "organizationalViewController.h"

#import "UserDataConn.h"
#import "ecloudNotification.h"
#import "UserTipsUtil.h"
#import "Dept.h"

#import "eCloudDefine.h"

@interface CommonDeptViewController ()

@property (nonatomic , retain) NSMutableArray * itemArray;
@property (nonatomic,retain) NSIndexPath *removeIndexPath;

@end

@implementation CommonDeptViewController
{
	eCloudDAO *db;
    UserDataDAO *userDataDAO;
    UserDataConn *userDataConn;

    conn *_conn;
    BOOL needRefresh;
    UITableView *personTable;
    UILabel *tiplabel;
}
@synthesize removeIndexPath;
@synthesize itemArray;

-(void)dealloc
{
    self.removeIndexPath = nil;
	self.itemArray = nil;
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
    _conn = [conn getConn];

    userDataDAO = [UserDataDAO getDatabase];
    userDataConn = [UserDataConn getConn];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"main_my"] andTarget:self andSelector:@selector(backButtonPressed:)];
        //	右边按钮
    [UIAdapterUtil setRightButtonItemWithImageName:@"add_connet.png" andTarget:self andSelector:@selector(addButtonPressed:)];
	
    personTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50) style:UITableViewStylePlain];
    [personTable setDelegate:self];
    [personTable setDataSource:self];
    personTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:personTable];
    [personTable release];
    
    tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 50, 320, 100)];
    tiplabel.backgroundColor=[UIColor clearColor];
    tiplabel.textAlignment=UITextAlignmentCenter;
    tiplabel.numberOfLines = 0;
//    tiplabel.text=@"请在通讯录中选择添加常用部门";
    tiplabel.text = [StringUtil getLocalizableString:@"me_common_departments_tip"];
    tiplabel.textColor=[UIColor grayColor];
    [self.view addSubview:tiplabel];
    tiplabel.hidden=YES;
    [tiplabel release];
    
    needRefresh = YES;
}

- (void) addButtonPressed:(id) sender
{
 	AddCommonDeptViewController *chooseContact=[[AddCommonDeptViewController alloc]init];
    [self.navigationController pushViewController:chooseContact animated:YES];
	[chooseContact release];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];

    if (!needRefresh) {
        needRefresh = YES;
        return;
    }
    
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [personTable setEditing:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATE_USER_DATA_NOTIFICATION object:nil];

}

- (void)refresh
{
    self.itemArray = [NSMutableArray arrayWithArray:[userDataDAO getAllCommonDept]];
    
    if (self.itemArray.count == 0)
    {
        personTable.hidden = YES;
        tiplabel.hidden = NO;
    }
    else
    {
        personTable.hidden = NO;
        tiplabel.hidden = YES;
        
        [personTable reloadData];
    }
    [UIAdapterUtil setExtraCellLineHidden:personTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 获取员工的显示方式
-(EmpCell *)getEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpCell *empCell = [personTable dequeueReusableCellWithIdentifier:empCellID];
	if(empCell == nil)
	{
		empCell = [[[EmpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
        
        [self addGesture:empCell];
	}
	
	Emp *emp = [self.itemArray objectAtIndex:indexPath.row];
	[empCell configureCell:emp];
    
	return empCell;
}

- (void)addGesture:(EmpCell *)empCell
{
    UIImageView *logoView = (UIImageView *)[empCell viewWithTag:emp_logo_tag];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openPersonInfo:)];
    [logoView addGestureRecognizer:singleTap];
    [singleTap release];
}
-(void)openPersonInfo:(UIGestureRecognizer*)gesture
{
    UIImageView *logoView = gesture.view;
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    NSString *empIdStr = empIdLabel.text;
    
    needRefresh = NO;
    
    [organizationalViewController openUserInfoById:empIdStr andCurController:self];
}

#pragma  mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indentation = 0;
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[Dept class]]) {
        indentation = ((Dept *)temp).dept_level;
    }
    else
    {
        indentation = ((Emp *)temp).emp_level;
    }
    return indentation;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    
	return self.itemArray.count;
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[Dept class]]) {
        return dept_row_height;
    }// Configure the cell.
	else {
        return emp_row_height;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[Dept class]])
    {
        static NSString *deptCellID = @"deptCellID";
        DeptCell *deptCell = [tableView dequeueReusableCellWithIdentifier:deptCellID];
        if (deptCell == nil)
        {
            deptCell = [[[DeptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deptCellID] autorelease];
        }
        Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
        [deptCell configCell:dept];
        return deptCell;
    }
    else
    {
        return [self getEmpCell:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    id temp=[self.itemArray objectAtIndex:indexPath.row];
    if([temp isKindOfClass:[Dept class]])
    {
        Dept *dept = [self.itemArray objectAtIndex:indexPath.row];
        int level=dept.dept_level+1;
        if (dept.isExtended) { //收起展示
            dept.isExtended=false;
            int remvoecount=0;
            for (int i=indexPath.row+1; i<[self.itemArray count]; i++) {
                
                
                id temp1 = [self.itemArray objectAtIndex:i];
                
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
                [self.itemArray removeObjectsInRange:range];
            }
            
            
        }else   //显示子部门及人员
        {
            UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            float noworigin=cell.frame.origin.y;
            
            NSMutableArray *allArray = [NSMutableArray array];// [[NSMutableArray alloc]init];
//            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            
            NSArray *tempDeptArray=[db getLocalNextDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level];
            NSArray *tempEpArray=[db getEmpsByDeptID:dept.dept_id andLevel:level];
            [allArray addObjectsFromArray:tempEpArray];
            [allArray addObjectsFromArray:tempDeptArray];
//            [pool release];
            
            NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
            [self.itemArray insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
//            [allArray release];
            
            dept.isExtended=true;
            
            /*自动收起---------------------------------------------------------------bigen------------*/
            float isExtendedPoint=0;
            float sumnum=0;
            for (int i=0; i<[self.itemArray count]; i++) {
                id temp1 = [self.itemArray objectAtIndex:i];
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
                        for (int nowindex=i+1; nowindex<[self.itemArray count]; nowindex++) {
                            
                            
                            id temp1 = [self.itemArray objectAtIndex:nowindex];
                            
                            if([temp1 isKindOfClass:[Emp class]])
                            {
                                if (((Emp *)temp1).emp_level<=extendedDept.dept_level) {
                                    break;
                                }
                                emplen+=emp_row_height;
                            }
                            
                            if([temp1 isKindOfClass:[Dept class]])
                            {
                                if (((Dept *)temp1).dept_level<=extendedDept.dept_level) {
                                    break;
                                }
                                deptlen+=dept_row_height;
                            }
                            remvoecount++;
                        }
                        if (remvoecount!=0) {
                            NSRange range =NSMakeRange(i+1,remvoecount);
                            [self.itemArray removeObjectsInRange:range];
                        }
                        sumnum=deptlen+emplen;
                        break;
                    }
                    
                }
            }
            
            [tableView reloadData];
            
            if (isExtendedPoint<noworigin) {
                float offsetvalue=noworigin-sumnum;
                if (offsetvalue<0) {
                    offsetvalue=noworigin;
                }
                tableView.contentOffset=CGPointMake(0,offsetvalue);//NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
            }else{
                tableView.contentOffset=CGPointMake(0,noworigin);//NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
            }
        }
        
        [tableView reloadData] ;
    }
    
    else {
        //		如果用户点击的是具体的员工，那么就打开与该员工进行会话的窗口
        if([temp isKindOfClass:[Emp class]])
        {
            [UIAdapterUtil openConversation:self andEmp:(Emp*)temp];
        }
    }
}

//修改删除按钮的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [StringUtil getLocalizableString:@"me_common_departments_delete"];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%d,%d",self.itemArray.count,indexPath.row);

    if (indexPath.row == self.itemArray.count) {
        return NO;
    }
    
    id item=[self.itemArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[Dept class]]) {
         Dept *dept = item;
         int level=dept.dept_level;
        if (level==0) {
            return YES;
        }
        else
         {
          return NO;
         }
    }
     return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        id item=[self.itemArray objectAtIndex:indexPath.row];
        if ([item isKindOfClass:[Dept class]])
        {
            Dept *dept = item;
            int level=dept.dept_level;
            if (level==0) {
                BOOL ret = [userDataConn sendModiRequestWithDataType:user_data_type_dept andUpdateType:user_data_update_type_delete andData:[NSArray arrayWithObject:[StringUtil getStringValue:dept.dept_id]]];
                
                if (ret) {
                    self.removeIndexPath = indexPath;
                    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"me_loading_tip"]];
                }
            }
        }
    }
}

-(void)displayTabBar
{
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}

-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
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
                Dept *dept = [self.itemArray objectAtIndex:self.removeIndexPath.row];
                [userDataDAO removeCommonDept:dept.dept_id];
                [self refresh];
            }
                break;
            case update_user_data_fail:
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_departments_remove_failure"]];
                break;
            case update_user_data_timeout:
                [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"me_common_departments_remove_timeout"]];
                break;
			default:
				break;
        }
    }
}

@end
