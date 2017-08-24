
#import "NewMyViewControllerOfTableview.h"
#import "myCell.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "ImageUtil.h"
#import "ImageSet.h"
#import "UIAdapterUtil.h"
#import "userInfoViewController.h"
#import "MonthHelperViewController.h"
#import "CommonDeptViewController.h"
#import "CommonEmpViewController.h"
#import "SystemGroupViewController.h"
#import "CommonGroupViewController.h"
#import "FileAssistantViewController.h"
#import "APPListViewController.h"
#import "PSListViewController.h"
#import "KapokHistoryViewController.h"

#define STR_TITLE_MAX 4
//static const char* userDataTextArray[STR_TITLE_MAX] = {"常用联系人","常用部门","自定义组","网信群"};
static const char* userDataPicNameArray[STR_TITLE_MAX] = {"me_commom_contact_btn","me_costom_group_btn","me_wanda_group_btn","me_commom_department_btn"};

@interface NewMyViewControllerOfTableview(){
    NSMutableArray *userDataTextArray;
}
@property(retain,nonatomic) Emp *emp;
@end

@implementation NewMyViewControllerOfTableview
{
    conn *_conn;
    eCloudDAO *db;
    
    UITableView *myTableView;
    CGSize deptSize;
    CGFloat userCellHeight;
}

- (void)dealloc{
    [userDataTextArray removeAllObjects];
    [userDataTextArray release];
    [self.emp release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    userDataTextArray = [[NSMutableArray alloc] init];
    
    myTableView= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height-80) style:UITableViewStyleGrouped];
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundView = nil;
    myTableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:myTableView];
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height);
    [myTableView release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayTabBar];
    
    self.title= [StringUtil getAppLocalizableString:@"main_my"];
    
    if ([userDataTextArray count]) {
        [userDataTextArray removeAllObjects];
    }
    //计算部门标签高度
    self.emp= [db getEmpInfo:_conn.userId];
    
    [userDataTextArray addObject:[StringUtil getLocalizableString:@"me_common_contacts"]];
    [userDataTextArray addObject:[StringUtil getLocalizableString:@"me_custom_groups"]];
    [userDataTextArray addObject:[StringUtil getLocalizableString:@"me_ecloud_groups"]];
    [userDataTextArray addObject:[StringUtil getLocalizableString:@"me_common_departments"]];
    
    [myTableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return 1;
//
    if (section ==0)
        return 1;
    else if (section ==1)
        return 1;
//    else if (section == 2)
//        return 1;
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 15;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        return myCellHeight;
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    if (section ==0)
    {
        return [self getUserInfoCell];
    }
    
    static NSString *CellIdentifier = @"Cell1";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [StringUtil getLocalizableString:@"me_file_assistant"];
            cell.imageView.image = [StringUtil getImageByResName:@"me_file_assistant_btn.png" ];
        }
//        else if (indexPath.row == 1)
//        {
//            cell.textLabel.text = [StringUtil getLocalizableString:@"public_service"];
//            cell.imageView.image = [StringUtil getImageByResName:@"gongzonghao.png"];
//        }
//        else if (indexPath.row == 2)
//        {
//            cell.textLabel.text = [StringUtil getLocalizableString:@"kapok_fly"];
//            cell.imageView.image = [StringUtil getImageByResName:@"kapok_fly_icon.png"];
//        }
        
    }
    
//    if (section ==1)
//    {
//        cell.textLabel.text = [userDataTextArray objectAtIndex:[indexPath row]];
//        cell.imageView.image = [StringUtil getImageByResName:[NSString stringWithUTF8String:userDataPicNameArray[indexPath.row]]];
//    }
//    if (section ==2)
//    {
//        cell.textLabel.text = [StringUtil getLocalizableString:@"me_file_assistant"];
//        cell.imageView.image = [StringUtil getImageByResName:@"me_file_assistant_btn.png" ];
//    }
//    if (indexPath.section ==3)
//    {
//        cell.textLabel.text = [StringUtil getLocalizableString:@"me_schedule_assistant"];
//        cell.imageView.image = [StringUtil getImageByResName:@"schedule_icon_menu"];
//    }
    return cell;
}

- (UITableViewCell *)getUserInfoCell
{
    myCell *mCell = [[myCell alloc] init];
    
    mCell.nameLable.text = self.emp.emp_name;
    
    mCell.deptLable.text = self.emp.empCode;
    mCell.iconView.image = [ImageUtil getOnlineEmpLogo:self.emp];

    return [mCell autorelease];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section== 0 && indexPath.row == 0)
    {
        userInfoViewController *userInfoView = [[userInfoViewController alloc] init];
        [self hideTabBar];
        [self.navigationController pushViewController:userInfoView animated:YES];
        [userInfoView release];
    }
//    else if(indexPath.section == 1 && indexPath.row == 0)
//    {
//        //常联系人
//        CommonEmpViewController *commonEmpView = [[CommonEmpViewController alloc] init];
//        commonEmpView.title = [StringUtil getLocalizableString:@"me_common_contacts"];
//        [self hideTabBar];
//        [self.navigationController pushViewController: commonEmpView animated:YES];
//        [commonEmpView release];
//        
//    }
//    else if(indexPath.section == 1 && indexPath.row == 1)
//    {
//        //自定义组
//        CommonGroupViewController *commonGroupView = [[CommonGroupViewController alloc] init];
//        commonGroupView.title = [StringUtil getLocalizableString:@"me_custom_groups"];
//        [self hideTabBar];
//        [self.navigationController pushViewController: commonGroupView animated:YES];
//        [commonGroupView release];
//    }
//    else if(indexPath.section == 1 && indexPath.row == 2)
//    {
//        //网信组
//        SystemGroupViewController *systemGroupView = [[SystemGroupViewController alloc] init];
//        systemGroupView.title = [StringUtil getLocalizableString:@"me_ecloud_groups"];
//        [self hideTabBar];
//        [self.navigationController pushViewController: systemGroupView animated:YES];
//        [systemGroupView release];
//    }
//    else if(indexPath.section == 1 && indexPath.row == 3)
//    {
//        //常用部门
//        CommonDeptViewController *contactlist=[[CommonDeptViewController alloc]init];
//        contactlist.title=[StringUtil getLocalizableString:@"me_common_departments"];
//        //contactlist.hidesBottomBarWhenPushed = YES;
//        [self hideTabBar];
//        [self.navigationController pushViewController:contactlist animated:YES];
//        [contactlist release];
//    }
    else if(indexPath.section ==1 && indexPath.row == 0)
    {
        FileAssistantViewController *fileAssistantVC = [[FileAssistantViewController alloc] init];
       // 0810 打开
       // FileAssistantViewController *fileAssistantVC = [FileAssistantViewController getFileAssistantViewCtr];
        fileAssistantVC.title = [StringUtil getLocalizableString:@"me_file_assistant"];
        [self hideTabBar];
        [self.navigationController pushViewController: fileAssistantVC animated:YES];
        [fileAssistantVC release];
    }
//    else if(indexPath.section == 1 && indexPath.row == 1)
//    {
//        //应用平台
//        PSListViewController *controller = [[PSListViewController alloc]initWithStyle:UITableViewStylePlain];
//        //		controller.hidesBottomBarWhenPushed = YES;
//        [self hideTabBar];
//        [self.navigationController pushViewController:controller animated:YES];
//        [controller release];
////        APPListViewController *ctr=[[APPListViewController alloc]init];
////        [self hideTabBar];
////        [self.navigationController pushViewController:ctr animated:YES];
////        [ctr release];
//    }
//    else if (indexPath.section == 1 && indexPath.row == 2){
//        //木棉童飞
//        if (kapokHistory==nil) {
//            kapokHistory = [[KapokHistoryViewController alloc] initWithNibName:nil bundle:nil];
//            kapokHistory.title=@"木棉童飞";
//            
//        }
//        [self hideTabBar];
//        [self.navigationController pushViewController: kapokHistory animated:YES];
//    }
//    else if(indexPath.section == 3 && indexPath.row == 0)
//    {
//        MonthHelperViewController *mainVC = [[MonthHelperViewController alloc] initWithNibName:nil bundle:nil];
//        mainVC.title = [StringUtil getLocalizableString:@"me_schedule_assistant"];
//        [self hideTabBar];
//        [self.navigationController pushViewController: mainVC animated:YES];
//        [mainVC release];
//
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}

-(void)displayTabBar
{
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}

@end
