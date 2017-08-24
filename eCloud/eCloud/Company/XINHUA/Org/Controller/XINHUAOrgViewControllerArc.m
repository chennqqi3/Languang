//
//  XINHUAOrgViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/4/12.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "XINHUAOrgViewControllerArc.h"
#import "XINHUAOrgSearchViewControllerArc.h"
#import "XINHUAOrgSelectedViewControllerArc.h"
#import "NewChooseMemberViewController.h"
#import "XINHUAUserInfoViewControllerArc.h"
#import "XINHUAOrgGroupViewControllerArc.h"

#import "CreateGroupUtil.h"
#import "UIAdapterUtil.h"
#import "NotificationUtil.h"

#import "XINHUAEmpCellArc.h"
#import "XINHUAEmpHeadViewCellArc.h"
#import "XINHUAGroupCellArc.h"

#import "ConvNotification.h"

#import "eCloudDAO.h"
#import "UserDataDAO.h"

#import "Emp.h"

#import "UIAdapterUtil.h"
#import "StringUtil.h"

#import "AppDelegate.h"

#import "eCloudDefine.h"
#import "OpenCtxDefine.h"

#import "UserDataDAO.h"
#import "UserDefaults.h"

#define SEARCHBAR_H 43
#define TABBAR_H 48
#define NAVI_H 64

static NSString *cellIdentifier = @"orgcellIdentifier";
static NSString *headIdentifier = @"orgheadIdentifier";
static NSString *searchCellIdentifier = @"orgsearchCellIdentifier";
static NSString *orgGroupCellIdentifier = @"orgGroupCellIdentifier";

@interface XINHUAOrgViewControllerArc ()<ChooseMemberDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;

/** 现有的成员（包括原来的和新加的成员） */
@property (nonatomic, strong) NSMutableArray *selectedArray;
/** 所有供选择的成员 */
@property (nonatomic, strong) NSMutableArray *empArray;
/** 索引数组 */
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation XINHUAOrgViewControllerArc

- (NSMutableArray *)empArray
{
    if (_empArray == nil)
    {
        NSString *currentChar = @"";
        
        NSMutableArray *titleArr = [NSMutableArray array];
        [titleArr addObject:@"{search}"];
        NSMutableArray *empArr = [NSMutableArray array];
        
        NSArray *arr = [[UserDataDAO getDatabase] getAllEmp];
        
        
        // 去重
        NSMutableArray *mArr = [NSMutableArray array];
        for (Emp *emp1 in arr) {
            BOOL canAdd = YES;
            for (Emp *emp2 in mArr) {
                if ([emp1.empCode isEqualToString:emp2.empCode]) {
                    canAdd = NO;
                    NSLog(@"%@-%@",emp1.emp_name,emp1.empCode);
                    NSLog(@"aldfljasldjfal");
                    break;
                }
            }
            if (canAdd)
            {
                [mArr addObject:emp1];
            }
        }
        
        
        NSMutableArray * allEmpArr = [NSMutableArray arrayWithArray:mArr];
        // 把自己移除
        for (Emp *emp in allEmpArr) {
            if ([[UserDefaults getUserAccount] isEqualToString:emp.empCode]) {
                [allEmpArr removeObject:emp];
                break;
            }
        }
        // 按照拼音排序
        [allEmpArr sortUsingComparator:^NSComparisonResult(Emp *emp1, Emp *emp2) {
            
            return [emp1.empPinyin compare:emp2.empPinyin];
        }];
        for (Emp *emp in allEmpArr)
        {
            if (emp.empPinyin.length)
            {
                NSString *initial = [emp.empPinyin substringToIndex:1];
                // 把首字母转换成大写的
                initial = [initial uppercaseString];
                if (initial != nil && ![initial isEqualToString:currentChar])
                {
                    NSMutableArray *arr = [NSMutableArray array];
                    [empArr addObject:arr];
                    
                    // 把该索引加入索引数组
                    [titleArr addObject:initial];
                }
                
                [[empArr lastObject] addObject:emp];
                
                currentChar = initial;
            }
        }
        
        self.titleArray = [NSMutableArray arrayWithArray:titleArr];
        _empArray = [empArr copy];
    }
    
    return _empArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [UIAdapterUtil showTabar:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    
    
    // 监听头像变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLogo) name:NEW_CONVERSATION_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LookempInfomation:) name:LOOK_EMP_INFOMATION_NOTIFICATION object:nil];
}

- (void)LookempInfomation:(NSNotification *)noti
{
    XINHUAUserInfoViewControllerArc *userInfoCtl = [[XINHUAUserInfoViewControllerArc alloc] init];
    
    Emp *emp1 = (Emp *)noti.object;
    userInfoCtl.emp = emp1;
    [self.navigationController pushViewController:userInfoCtl animated:YES];
}

- (void)changeLogo
{
    [self.tableView reloadData];
}

- (void)setupUI
{
    self.title = [StringUtil getAppLocalizableString:@"address_book"];
    
    
//    [UIAdapterUtil setRightButtonItemWithImageName:@"add_ios" andTarget:self andSelector:@selector(setEditing)];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVI_H-TABBAR_H) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 去掉多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // 注册自定义cell
    [self.tableView registerNib:[UINib nibWithNibName:@"XINHUAEmpCellArc" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    // 注册自定义headCell
    [self.tableView registerClass:[XINHUAEmpHeadViewCellArc class] forHeaderFooterViewReuseIdentifier:headIdentifier];
    
    // 设置索引样式
    self.tableView.sectionIndexColor = [UIColor colorWithWhite:0.7 alpha:1];     // 设置默认时索引值颜色
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];   // 设置选中时，索引背景颜色
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];           // 设置默认时，索引的背景颜色
}

- (void)setEditing
{
    XINHUAOrgSelectedViewControllerArc *orgSelectedVc = [[XINHUAOrgSelectedViewControllerArc alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:orgSelectedVc];
    orgSelectedVc.empArray = self.empArray;
    orgSelectedVc.delegate = self;
    orgSelectedVc.originArray = [self getOriginArray];
    orgSelectedVc.titleArray = self.titleArray;
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (NSMutableArray *)getOriginArray
{
    NSMutableArray *arr = [NSMutableArray array];
    conn *_conn = [conn getConn];
    [arr addObject:_conn.curUser];
    return arr;
}

#pragma mark =====chooseMemberDelegate=======
- (void)didFinishSelectContacts:(NSArray *)userArray{
    [CreateGroupUtil getUtil].typeTag = type_create_conversation;
    [[CreateGroupUtil getUtil]createGroup:userArray];
}

#pragma mark - <UISearchBarDelegate>
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    XINHUAOrgSearchViewControllerArc *orgSearchVc = [[XINHUAOrgSearchViewControllerArc alloc] init];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    [window addSubview:orgSearchVc.view];
    [window.rootViewController addChildViewController:orgSearchVc];
    
    return NO;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.empArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }
    
    NSArray *array = self.empArray[section-1];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row==0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
                UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SEARCHBAR_H)];
                searchBar.placeholder = [StringUtil getAppLocalizableString:@"search"];
                searchBar.delegate = self;
                [cell addSubview:searchBar];
            }
            
            return cell;
        }
        else if (indexPath.row==1)
        {
            XINHUAGroupCellArc *cell = [tableView dequeueReusableCellWithIdentifier:orgGroupCellIdentifier];
            if (cell == nil)
            {
                cell = [[XINHUAGroupCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orgGroupCellIdentifier];
            }
            
            
            cell.groupLogo.image = [StringUtil getImageByResName:@"xingzhengzu"];
            cell.groupName.text = [StringUtil getAppLocalizableString:@"administrative_class_group"];
            
            return cell;
        }
        else
        {
            XINHUAGroupCellArc *cell = [tableView dequeueReusableCellWithIdentifier:orgGroupCellIdentifier];
            if (cell == nil)
            {
                cell = [[XINHUAGroupCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orgGroupCellIdentifier];
            }
            
            
            cell.groupLogo.image = [StringUtil getImageByResName:@"taolunzu"];
            cell.groupName.text = [StringUtil getAppLocalizableString:@"discussion_group"];
            
            return cell;
        }
    }
    else
    {
        XINHUAEmpCellArc *empCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        empCell.isEditing = NO;
        NSArray *arr = self.empArray[indexPath.section-1];
        Emp *emp = arr[indexPath.row];
        
        empCell.emp = emp;
        
        return empCell;
    }
    
    return nil;
}

#pragma mark - <UITableViewDelegate>
/** 行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return 43;
    }
    return 60;
}

/** 头部高度 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    return 22;
}

/** 头部控件 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    XINHUAEmpHeadViewCellArc *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headIdentifier];
    
    NSString *title = @"";
    if (self.titleArray.count > section)
    {
        title = self.titleArray[section];
    }
    
    cell.title = title;
    
    return cell;
}

/** 索引数组 */
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.titleArray;
}

/** 点击cell */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row==1)
        {
            XINHUAOrgGroupViewControllerArc *orgGroupVC = [[XINHUAOrgGroupViewControllerArc alloc] init];
            orgGroupVC.groupTitle = [StringUtil getAppLocalizableString:@"administrative_class_group"];
            
            NSArray *systemGroup = [[UserDataDAO getDatabase] getALlSystemGroup];
            orgGroupVC.dataArray = systemGroup;
            [self.navigationController pushViewController:orgGroupVC animated:YES];
        }
        else if (indexPath.row==2)
        {
            XINHUAOrgGroupViewControllerArc *orgGroupVC = [[XINHUAOrgGroupViewControllerArc alloc] init];
            orgGroupVC.groupTitle = [StringUtil getAppLocalizableString:@"discussion_group"];
            
            NSArray *commonGroup = [[UserDataDAO getDatabase] getALlCommonGroup];
            orgGroupVC.dataArray = commonGroup;
            [self.navigationController pushViewController:orgGroupVC animated:YES];
        }
    }
    else
    {
        NSArray *arr = self.empArray[indexPath.section-1];
        Emp *emp = arr[indexPath.row];
        
        XINHUAUserInfoViewControllerArc *userInfoCtl = [[XINHUAUserInfoViewControllerArc alloc] init];
        
        eCloudDAO *_ecloud = [eCloudDAO getDatabase];
        Emp *emp1 = [_ecloud getEmpInfo:[NSString stringWithFormat:@"%d",emp.emp_id]];
        userInfoCtl.emp = emp1;
        [self.navigationController pushViewController:userInfoCtl animated:YES];
    }
}

@end
