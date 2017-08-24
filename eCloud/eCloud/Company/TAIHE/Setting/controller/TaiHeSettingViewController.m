//
//  TaiHeSettingViewController.m
//  eCloud
//
//  Created by Ji on 17/1/17.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TaiHeSettingViewController.h"
#import "TaiHeSettingCell.h"
#import "StringUtil.h"
#import "OpenNotificationDefine.h"
#import "IOSSystemDefine.h"
#import "TaiHeSettingCell.h"
#import "ImageUtil.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "userInfoViewController.h"
#import "UserDefaults.h"
#import "GXViewController.h"
#import "mainViewController.h"
#import "ServerConfig.h"
#import "TabbarUtil.h"
#import "TAIHEAppViewController.h"
#import "settingViewController.h"
#import "FileAssistantViewController.h"
#import "personInfoViewController.h"
#import "TAIHEAgentLstViewController.h"

@interface TaiHeSettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property(nonatomic,strong)UITableView *personalTableView;
//@property(nonatomic,strong)NSMutableArray *dataSource;
@property(retain,nonatomic) Emp *emp;

@property(assign)id delegete;
@end

@implementation TaiHeSettingViewController
{
    NSMutableArray *_settingArray;
    NSMutableArray *_imageArray;
    conn *_conn;
    eCloudDAO *db;
    
    UIAlertView *tipAlert;
    bool isExit;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
        _settingArray = [NSMutableArray array];
        _imageArray = [NSMutableArray array];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"我";
//    self.title = [StringUtil getAppLocalizableString:@"main_settings"];

//    [_personalTableView reloadData];
    // 从个人信息回到"我的"界面tabbar会隐藏
    [UIAdapterUtil showTabar:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *array = [[NSArray alloc] initWithObjects:@"我的文件",@"设置",@"修改密码",@"IT热线：400-918-9778", nil];
    NSArray *imageArray = [[NSArray alloc] initWithObjects:@"icon_file_assistant.png",@"icon_setup.png",@"password_image.png",@"it_image.png", nil];
    _settingArray = array;
    _imageArray = imageArray;
    _personalTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    [self.view addSubview:_personalTableView];
    _personalTableView.delegate=self;
    _personalTableView.dataSource=self;
    _personalTableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    _personalTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [UIAdapterUtil setPropertyOfTableView:_personalTableView];
    
    //刷新头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:@"ModifyThePicture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:GET_CURUSERICON_NOTIFICATION object:nil];

}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    
    view.tintColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
}

#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //分组数 也就是section数
    return 3;
}
//设置每个分组下tableview的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }else if (section==1) {
        return _settingArray.count;
    }else {
        return 1;
    }
}
//每个分组上边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==1) {
        return 50;
    }
    return 15;
}
//每一个分组下对应的tableview 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 120;
    }
    return 52;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    int section = indexPath.section;
    if (section ==0)
    {
        return [self getUserInfoCell];
    }
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [_personalTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section ==1){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        if (indexPath.row == 3) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = [_settingArray objectAtIndex:indexPath.row];
        cell.imageView.image = [StringUtil getImageByResName:[_imageArray objectAtIndex:indexPath.row]];
        //if (indexPath.row == 2) {
            
          //  NSString *str = @"IT服务热线 ：400-918-9778";
          //  NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];

            //[attrStr addAttribute:NSForegroundColorAttributeName
              //              value:[UIColor blueColor]
                //            range:NSMakeRange(8, 12)];
 
            //[attrStr addAttribute:NSUnderlineStyleAttributeName
              //              value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                //            range:NSMakeRange(8, 12)];
            //cell.textLabel.attributedText = attrStr;
            //cell.accessoryType = UITableViewCellAccessoryNone;
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;

       // }
        return cell;
    }else if (indexPath.section==2) {
        cell.textLabel.text = @"退出登录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
        return cell;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section== 0 && indexPath.row == 0)
    {
        
        userInfoViewController *userInfoView = [[userInfoViewController alloc] init];
        
//        [self hideTabBar];
        [self.navigationController pushViewController:userInfoView animated:YES];
   
    }else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            
            FileAssistantViewController *fileVC = [[FileAssistantViewController alloc]init];
            [self hideTabBar];
            [self.navigationController pushViewController:fileVC animated:YES];
            
        }else if(indexPath.row ==1){
            
            settingViewController *setting = [[settingViewController alloc]init];
            [self hideTabBar];
            [self.navigationController pushViewController:setting animated:YES];
            
        }else if(indexPath.row == 2){
            TAIHEAgentLstViewController *agentListVC = [[TAIHEAgentLstViewController alloc]init];
            agentListVC.urlstr = [[[ServerConfig shareServerConfig] getModifyPwdUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.navigationController pushViewController:agentListVC animated:YES];
        }else if(indexPath.row == 3){
            
            [personInfoViewController callNumber:@"400-918-9778"];
            
        }
    }
    else if(indexPath.section == 2){
        [self exitAction];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)Picture{
    
    [_personalTableView reloadData];
}
- (UITableViewCell *)getUserInfoCell
{
    
    self.emp = [db getEmpInfo:_conn.userId];
    
    TaiHeSettingCell *mCell = [[TaiHeSettingCell alloc] init];
    mCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    mCell.homeDay.text = self.emp.emp_name;
    mCell.homeImageView.image = [[TAIHEAppViewController getTaiHeAppViewController]headTangential];
    mCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return mCell;
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ModifyThePicture" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CURUSERICON_NOTIFICATION object:nil];
    
    _settingArray = nil;
//    [_settingArray removeAllObjects];

}
-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}

#pragma mark - 退出逻辑
- (void)exitAction{
    NSString *temp = @"";
    if(_conn.connStatus == linking_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_connecting_server"];
    }
    else if(_conn.connStatus == rcv_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_receiving_messages"];
    }
    else if(_conn.connStatus == download_org)
    {
        temp = [StringUtil getLocalizableString:@"settings_loading_organizational_structure"];
    }
    else if(_conn.downLoadImageStatus == download_guide)
    {
        temp = [StringUtil getLocalizableString:@"settings_download_guide"];
    }
    
    if(temp.length > 0)
    {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:[StringUtil getAppName] ] message:temp delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [tipAlert dismissWithClickedButtonIndex:0 animated:YES];
        [tipAlert show];
        tipAlert = nil;
        return;
    }
    
    else {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
        [tipAlert show];
    }
}
- (void)exit{
    [UserDefaults saveUserIsExit:YES];
    
    if (self.delegete && [self.delegete isKindOfClass:[mainViewController class]]) {
        [( (mainViewController*)self.delegete)backRoot];
    }else{
        id tabbarVC = [TabbarUtil getTabbarController];
        if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
            id mainVC = ((GXViewController *)tabbarVC).delegate;
            [((mainViewController*)mainVC) backRoot];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==tipAlert)
    {
        if (buttonIndex==1)
        {
           	if(_conn.connStatus == normal_type)
            {
                isExit = true;
                
                [_conn logout:1];
                NSString *str =  [[ServerConfig shareServerConfig]getShareName];
                NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:str];
                [sharedDefaults removeObjectForKey:@"isLogin"];
                
                [self exit];
            }
            else if(_conn.connStatus == not_connect_type)
            {
                [self exit];
            }
            
            /** 泰禾退出登录 */
            [[NSNotificationCenter defaultCenter]postNotificationName:TAI_HE_LOG_OUT object:nil userInfo:nil];
        }
    }
}
@end
