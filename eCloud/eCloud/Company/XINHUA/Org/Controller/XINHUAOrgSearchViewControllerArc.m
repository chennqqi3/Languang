//
//  XINHUAOrgSearchViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/4/14.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "XINHUAOrgSearchViewControllerArc.h"
#import "NewOrgViewController.h"
#import "XINHUAUserInfoViewControllerArc.h"
#import "talkSessionViewController.h"

#import "XINHUAEmpCellArc.h"

#import "AppDelegate.h"

#import "eCloudDAO.h"
#import "UserDefaults.h"

#import "eCloudDefine.h"
#import "Conversation.h"
#import "UserDataDAO.h"
#import "XINHUADefineHeader.h"


static NSString *searchResultIdentifier = @"searchResultIdentifier";
@interface XINHUAOrgSearchViewControllerArc ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UILabel *instructionLabel;

@property (nonatomic, strong) UIView *searchView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *searchResultArr;

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation XINHUAOrgSearchViewControllerArc

- (NSArray *)titleArray
{
    if (_titleArray == nil)
    {
        _titleArray = @[@"联系人",@"群组",@"讨论组"];
    }
    
    return _titleArray;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    
    // 设置状态栏颜色为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    
    self.searchResultArr = [NSMutableArray array];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 添加头部搜索的View
    UIView *searchBackgrounpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    searchBackgrounpView.backgroundColor = [UIColor colorWithRed:244/255.0 green:247/255.0 blue:249/255.0 alpha:1];
    [self.view addSubview:searchBackgrounpView];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 63, SCREEN_WIDTH, 1)];
    separatorView.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1];
    [searchBackgrounpView addSubview:separatorView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 30, SCREEN_WIDTH-20-50, 28)];
    self.searchBar.placeholder = [StringUtil getAppLocalizableString:@"search"];
    self.searchBar.delegate = self;
    [searchBackgrounpView addSubview:self.searchBar];
    
    [self.searchBar becomeFirstResponder];
    
    // 取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitleColor:XINHUA_DEEP_BLUE forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(SCREEN_WIDTH-60, 30, 60, 30);
    [cancelBtn setTitle:[StringUtil getAppLocalizableString:@"cancel"] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    [searchBackgrounpView addSubview:cancelBtn];
    
    
    // 添加tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 注册自定义cell
    [self.tableView registerNib:[UINib nibWithNibName:@"XINHUAEmpCellArc" bundle:nil] forCellReuseIdentifier:searchResultIdentifier];
    
    
    // 搜索下面的View
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    self.searchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchView];
    
    self.instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-230)/2, 30, 230, 35)];
    self.instructionLabel.text = [StringUtil getAppLocalizableString:@"search_for_friends_class_discussion_group"];
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1];
    [self.searchView addSubview:self.instructionLabel];
}

- (void)cancelSearch
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 设置状态栏颜色为黑色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - <UISearchBarDelegate>
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    return YES;
}

// 搜索的关键字改变时
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        self.searchView.hidden = NO;
        self.instructionLabel.text = [StringUtil getAppLocalizableString:@"search_for_friends_class_discussion_group"];
    }
}

// 点击搜索时
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
    self.searchView.hidden = YES;
    [self searchOrg];
}

- (void)searchOrg
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    
    
    
    dispatch_queue_t queue = dispatch_queue_create("search org", NULL);
    
    dispatch_async(queue, ^{
        int _type = [StringUtil getStringType:self.searchBar.text];
        
        if(_type != other_type){
//            searchDeptAndEmpTag=1;
            
            
            
            
            NSString *_searchStr = [NSString stringWithString:self.searchBar.text];
            NSMutableArray *dataarray=[NSMutableArray array];
            
            
            // 联系人
            [_ecloud setLimitWhenSearchUser:YES];
            NSArray *emparray= [_ecloud getEmpsByNameOrPinyin:_searchStr andType:_type];
            NSMutableArray *allEmpArr = [NSMutableArray arrayWithArray:emparray];
            if (emparray.count > 0)
            {
                // 把自己移除
                for (Emp *emp in emparray) {
                    if ([[UserDefaults getUserAccount] isEqualToString:emp.empCode]) {
                        [allEmpArr removeObject:emp];
                        break;
                    }
                }
                [dataarray addObject:allEmpArr];
            }
            
            
            
            // 包含搜索的人的固定组
            NSArray *systemArray = [[UserDataDAO getDatabase] getALlSystemGroup];
            NSMutableArray *systemMArray = [NSMutableArray array];
            for (Conversation *conv in systemArray)
            {
                NSArray *arr = [conv getConvEmps];
                BOOL shouldBreak = false;
                for (Emp *emp1 in arr)
                {
                    if (shouldBreak) {
                        break;
                    }
                    for (Emp *emp2 in emparray)
                    {
                        if (emp1.emp_id == emp2.emp_id)
                        {
                            conv.convEmps = arr;
                            [systemMArray addObject:conv];
                            shouldBreak = true;
                            break;
                        }
                    }
                }
            }
            if (systemMArray.count > 0)
            {
                [dataarray addObject:systemMArray];
            }
            
            
            
            
            // 包含搜索的人的讨论组
            NSArray *groupArray = [[UserDataDAO getDatabase] getALlCommonGroup];
            
            NSMutableArray *groupMArray = [NSMutableArray array];
            for (Conversation *conv in groupArray)
            {
                NSArray *arr = [conv getConvEmps];
                BOOL shouldBreak = false;
                for (Emp *emp1 in arr)
                {
                    if (shouldBreak) {
                        break;
                    }
                    for (Emp *emp2 in emparray)
                    {
                        if (emp1.emp_id == emp2.emp_id)
                        {
                            conv.convEmps = arr;
                            [groupMArray addObject:conv];
                            shouldBreak = true;
                            break;
                        }
                    }
                }
            }
            if (groupArray.count > 0)
            {
                [dataarray addObject:groupMArray];
            }
            
            
            [self.searchResultArr removeAllObjects];
            [self.searchResultArr addObjectsFromArray:dataarray];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
            // 没有搜索到
            if (![self.searchResultArr count]) {
                NSLog(@"没有搜索到");
                
                
                self.instructionLabel.text = [StringUtil getAppLocalizableString:@"no_result"];
                self.searchView.hidden = NO;
//                [self setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"]];
            }
            
//            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
}

#pragma mark - <UITableViewDataSource>
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.searchResultArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.searchResultArr[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XINHUAEmpCellArc *cell = [tableView dequeueReusableCellWithIdentifier:searchResultIdentifier];
    
    cell.isEditing = NO;
    
    NSArray *arr = self.searchResultArr[indexPath.section];
    if (indexPath.section == 0)
    {
        Emp *emp = arr[indexPath.row];
        cell.emp = emp;
        
        cell.searchEmpStr = self.searchBar.text;
    }
    else
    {
        Conversation *conv = arr[indexPath.row];
        cell.conv = conv;
    }
    
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
/** 行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

/** 头部高度 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headID = @"xinhuaHeaderID";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headID];
    if (header == nil)
    {
        header = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headID];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 25)];
        titleLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
        titleLabel.tag = 1002;
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        [header addSubview:titleLabel];
    }
    
    UILabel *titleLabel = [header viewWithTag:1002];
    titleLabel.text = self.titleArray[section];
    
    return header;
}

/** 点击cell */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSArray *arr = self.searchResultArr[indexPath.section];
        Emp *emp = arr[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOOK_EMP_INFOMATION_NOTIFICATION object:emp];
    }
    else
    {
        NSArray *arr = self.searchResultArr[indexPath.section];
        Conversation *conv = arr[indexPath.row];
        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
        eCloudDAO *_ecloud = [eCloudDAO getDatabase];
        
        talkSession.talkType = mutiableType;
        talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
        talkSession.convId = conv.conv_id;
        talkSession.needUpdateTag=1;
        talkSession.convEmps =[_ecloud getAllConvEmpBy:conv.conv_id];
        talkSession.last_msg_id=conv.last_msg_id;
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
    }
    
    
    [self cancelSearch];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

@end
