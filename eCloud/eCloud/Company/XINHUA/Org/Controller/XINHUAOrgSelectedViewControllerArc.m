//
//  XINHUAOrgViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/4/12.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "XINHUAOrgSelectedViewControllerArc.h"
#import "XINHUAOrgGroupViewControllerArc.h"

#import "eCloudDAO.h"

#import "UIAdapterUtil.h"

#import "XINHUAEmpIconCellArc.h"

#import "XINHUAEmpCellArc.h"
#import "XINHUAEmpHeadViewCellArc.h"

#import "MJRefresh.h"

#import "Emp.h"
#import "UserDefaults.h"

#import "UIAdapterUtil.h"

#import "AppDelegate.h"

#import "eCloudDefine.h"

#import "UserDataDAO.h"

#define SEARCHBAR_H 47
#define COLLECTIONVIEW_H SEARCHBAR_H
#define TABBAR_H 48
#define NAVI_H 64


#define ITEM_W 40
#define ITEM_H 40


#define MAX_COUNT (IS_IPHONE_5 ? 5 : 6)


static NSString *cellIdentifier = @"orgselectedcellIdentifier";
static NSString *resultCellIdentifier = @"selectresultCellIdentifier";

static NSString *headIdentifier = @"orgselectedheadIdentifier";
static NSString *orgFristCellIdentifier = @"orgFristCellIdentifier";
static NSString *empIconCellArcIdentifier = @"empIconCellArcIdentifier";

@interface XINHUAOrgSelectedViewControllerArc ()<OrgGroupViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    BOOL _isSearching;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionView *collectionView;

/** 选择的成员 */
@property (nonatomic, strong) NSMutableArray *selectedArray;

/** 搜索到的成员 */
@property (nonatomic, strong) NSMutableArray *searchResultArr;

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation XINHUAOrgSelectedViewControllerArc

- (void)dealloc
{
    
    NSLog(@"%s", __func__);
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(ITEM_W, ITEM_H);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 5;
        
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, COLLECTIONVIEW_H)collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_collectionView];
        
        //注册cell
        [_collectionView registerClass:[XINHUAEmpIconCellArc class] forCellWithReuseIdentifier:empIconCellArcIdentifier];
    }
    
    return _collectionView;
}

- (NSMutableArray *)searchResultArr
{
    if (_searchResultArr == nil)
    {
        _searchResultArr = [NSMutableArray array];
    }
    
    return _searchResultArr;
}

- (NSMutableArray *)selectedArray
{
    if (_selectedArray == nil)
    {
        _selectedArray = [NSMutableArray array];
    }
    
    return _selectedArray;
}

//如果没有给成员数组赋值就到本地数据库获取
- (NSMutableArray *)empArray
{
    if (_empArray == nil)
    {
        NSString *currentChar = @"";
        
        NSMutableArray *titleArr = [NSMutableArray array];
        NSMutableArray *empArr = [NSMutableArray array];
        
        NSArray *arr = [[UserDataDAO getDatabase] getAllEmp];
        NSMutableArray * allEmpArr = [NSMutableArray arrayWithArray:arr];
        // 把自己移除
        for (Emp *emp in allEmpArr) {
            if (emp.emp_id == [conn getConn].curUser.emp_id) {
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
        
        self.titleArray = [NSMutableArray arrayWithArray:titleArr];
        _empArray = [empArr copy];
    }
    
    return _empArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (self.titleArray)
    {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.titleArray];
        [arr replaceObjectAtIndex:0 withObject:@""];
        self.titleArray = [arr mutableCopy];
    }
    
    [self setupUI];
}

- (void)setupUI
{
    self.title = [StringUtil getAppLocalizableString:@"address_book"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(cancel) andDisplayLeftButtonImage:NO];
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"confirm"] andTarget:self andSelector:@selector(confirm)];
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SEARCHBAR_H)];
    self.searchBar.placeholder = [StringUtil getAppLocalizableString:@"search"];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SEARCHBAR_H, SCREEN_WIDTH, SCREEN_HEIGHT-NAVI_H-SEARCHBAR_H) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // “确定”键 默认不可点
    NSArray *arr = self.navigationItem.rightBarButtonItems;
    UIBarButtonItem *item2 = arr[1];
    item2.enabled = NO;
    
    
    // 分割线
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, SEARCHBAR_H, [UIScreen mainScreen].bounds.size.width, 1)];
    view1.backgroundColor = [UIColor colorWithWhite:.9f alpha:1];
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
    view2.backgroundColor = [UIColor colorWithWhite:.9f alpha:1];
    [self.tableView addSubview:view2];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 去掉多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // 注册自定义cell
    [self.tableView registerNib:[UINib nibWithNibName:@"XINHUAEmpCellArc" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"XINHUAEmpCellArc" bundle:nil] forCellReuseIdentifier:resultCellIdentifier];
    // 注册自定义headCell
    [self.tableView registerClass:[XINHUAEmpHeadViewCellArc class] forHeaderFooterViewReuseIdentifier:headIdentifier];
    
    // 设置索引样式
    self.tableView.sectionIndexColor = [UIColor colorWithWhite:0.7 alpha:1];     // 设置默认时索引值颜色
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];   // 设置选中时，索引背景颜色
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];           // 设置默认时，索引的背景颜色
}

- (void)confirm
{
    NSLog(@"确定");
    [self.delegate didFinishSelectContacts:self.selectedArray];
    
    [self cancel];
}

- (void)cancel
{
    [self.selectedArray removeAllObjects];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <OrgGroupViewControllerDelegate>
- (void)selectGroupFinish
{
    [self.selectedArray removeAllObjects];
    
    [self dismissViewControllerAnimated:NO completion:nil];
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
        _isSearching = NO;
        [self.tableView reloadData];
    }
}

// 点击搜索时
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _isSearching = YES;
    
    [self.searchBar resignFirstResponder];
    
    
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
            
            
            [dataarray addObjectsFromArray:emparray];
            
            [self.searchResultArr removeAllObjects];
            [self.searchResultArr  addObjectsFromArray:dataarray];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 没有搜索到
            if (![self.searchResultArr count]) {
                NSLog(@"没有搜索到");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                });
                
                //                [self setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"]];
            }
            
            //            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XINHUAEmpIconCellArc *cell = (XINHUAEmpIconCellArc *)[collectionView dequeueReusableCellWithReuseIdentifier:empIconCellArcIdentifier forIndexPath:indexPath];
    
    
    cell.emp = self.selectedArray[indexPath.row];
    
    
    return cell;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isSearching) {
        return 1;
    }
    return self.empArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSearching) {
        return self.searchResultArr.count;
    }
    
    if (section == 0) {
        return 1;
    }
    NSArray *array = self.empArray[section-1];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSearching)
    {
        XINHUAEmpCellArc *empCell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];
        
        empCell.isEditing = YES;
        
        Emp *emp = self.searchResultArr[indexPath.row];
        
        empCell.emp = emp;
        
        int index = [StringUtil isContainsEmp:emp WithArray:self.originArray];
        empCell.canBeSelected = index != EMP_NOT_FOUND;
        
        int index1 = [StringUtil isContainsEmp:emp WithArray:self.selectedArray];
        empCell.isselected = index1 != EMP_NOT_FOUND;
        
        return empCell;
    }
    
    
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:orgFristCellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:orgFristCellIdentifier];
            
            CGFloat height = 1.0/[UIScreen mainScreen].scale;
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 51, [UIScreen mainScreen].bounds.size.width, height)];
            view1.backgroundColor = [UIColor colorWithWhite:.9f alpha:1];
            [cell addSubview:view1];
        }
        
        
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [StringUtil getAppLocalizableString:@"select_a_discussion_group"];
        
        return cell;
    }
    
    
    XINHUAEmpCellArc *empCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    empCell.isEditing = YES;
    
    NSArray *arr = self.empArray[indexPath.section-1];
    Emp *emp = arr[indexPath.row];
    
    empCell.emp = emp;
    
    int index = [StringUtil isContainsEmp:emp WithArray:self.originArray];
    empCell.canBeSelected = index != EMP_NOT_FOUND;
    
    int index1 = [StringUtil isContainsEmp:emp WithArray:self.selectedArray];
    empCell.isselected = index1 != EMP_NOT_FOUND;;
    
    return empCell;
}

#pragma mark - <UITableViewDelegate>
/** 行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isSearching)
    {
        if (indexPath.section == 0) {
            return 52;
        }
        return 60;
    }
    
    return 60;
    
    
    
}

/** 头部高度 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
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
    if (_isSearching) {
        return nil;
    }
    return self.titleArray;
}

/** 点击cell */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    
    if (!_isSearching && indexPath.section == 0)
    {
        NSLog(@"选择一个讨论组");
        
        XINHUAOrgGroupViewControllerArc *orgGroupVC = [[XINHUAOrgGroupViewControllerArc alloc] init];
        orgGroupVC.groupTitle = [StringUtil getAppLocalizableString:@"discussion_group"];
        orgGroupVC.delegate = self;
        
        NSArray *commonGroup = [[UserDataDAO getDatabase] getALlCommonGroup];
        orgGroupVC.dataArray = commonGroup;
        [self.navigationController pushViewController:orgGroupVC animated:YES];
        
        
        return;
    }
    
    
    Emp *emp;
    if (_isSearching)
    {
        _isSearching = NO;
        
        emp = self.searchResultArr[indexPath.row];
    }
    else
    {
        NSArray *arr = self.empArray[indexPath.section-1];
        emp = arr[indexPath.row];
    }
    
    if ([StringUtil isContainsEmp:emp WithArray:self.originArray] != EMP_NOT_FOUND)
    {
        return;
    }
    
    
    int index = [StringUtil isContainsEmp:emp WithArray:self.selectedArray];
    if (index == EMP_NOT_FOUND)
    {
        [self.selectedArray addObject:emp];
    }
    else
    {
        [self.selectedArray removeObjectAtIndex:index];
    }
    
    
    [tableView reloadData];
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    CGFloat collectionView_W = self.selectedArray.count * (40+10);
    
    
    NSInteger count = MAX_COUNT;
    if (self.selectedArray.count < count)
    {
        self.collectionView.mj_w = collectionView_W;
        self.searchBar.mj_x = collectionView_W;
        self.searchBar.mj_w = SCREEN_WIDTH - collectionView_W;
    }
    
    [self.collectionView reloadData];
    
    
    if (self.selectedArray.count > 0)
    {
        NSIndexPath *collectIndexpath = [NSIndexPath indexPathForRow:self.selectedArray.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:collectIndexpath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    
    
    // 当选有人时 “确定” 才可点
    NSArray *arr = self.navigationItem.rightBarButtonItems;
    UIBarButtonItem *item2 = arr[1];
    item2.enabled = self.selectedArray.count > 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder] && [scrollView isEqual:self.tableView])
    {
        [self.searchBar resignFirstResponder];
    }
}

@end
