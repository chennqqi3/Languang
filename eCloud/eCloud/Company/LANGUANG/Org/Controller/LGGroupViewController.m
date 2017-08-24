//
//  LGGroupViewController.m
//  eCloud
//
//  Created by yanlei on 2017/7/28.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGGroupViewController.h"
#import "LGOrgDefine.h"
#import "UserDataDAO.h"
#import "talkSessionViewController.h"
#import "LCLLoadingView.h"
#import "LGOrgViewController.h"
#import "LGGroupEmptyView.h"

/** 搜索框高度 */
#define DEF_SEARCHBAR_HEIGHT (44.0)
/** 组高 */
#define DEF_GROUP_SECTION_HEADER_HEIGHT (40.0)

@interface LGGroupViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,ChooseMemberDelegate>
{
    UITableView *orgTable;
    UISearchBar *_searchBar;
    UISearchDisplayController *searchdispalyCtrl;
    
    BOOL isSearch ;
    NSMutableArray *headShowArr;
    LGGroupEmptyView *_emptyView;

}

/** 当前界面 数据项 */
@property (nonatomic,retain)NSMutableArray *itemArray;

/** 搜索结果 */
@property (nonatomic,retain)NSMutableArray *searchResults;

/** 搜索内容 */
@property (nonatomic,retain) NSString *searchStr;

@end

@implementation LGGroupViewController

- (void)dealloc{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    self.searchStr = nil;
    self.itemArray = nil;
    self.searchResults = nil;
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    [super dealloc];
}

/** 搜索bar */
- (void)initSearchBar
{
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, DEF_SEARCHBAR_HEIGHT)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getAppLocalizableString:@"chats_search"];
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), self.view.frame.size.width, 0.6)];
    view.backgroundColor = [StringUtil colorWithHexString:@"#E4E4E4"];
    [self.view addSubview:view];
    
    // 修改搜索框的外层背景颜色与搜索文本框的背景色
    [UIAdapterUtil setSearchColorForTextBarAndBackground:_searchBar];
    
    [self.view addSubview:_searchBar];
    [_searchBar release];
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchdispalyCtrl.active = NO;
    searchdispalyCtrl.delegate = self;
    searchdispalyCtrl.searchResultsDelegate=self;
    searchdispalyCtrl.searchResultsDataSource = self;
    
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
}

//返回 按钮
-(void) backButtonPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

// 发起群聊
- (void)rightButtonPressed{
    NSLog(@"发起群聊");
    
    LGRootChooseMemberViewController *vc = [[[LGRootChooseMemberViewController alloc]init]autorelease];
    vc.chooseMemberDelegate = self;
    vc.maxSelectCount = [conn getConn].maxGroupMember - 1;
    vc.oldEmpIdArray = [NSArray arrayWithObject:[conn getConn].curUser];
    UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
    [self presentViewController:nav animated:YES completion:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];
    // 加载数据
    [self refreshTableView];
    
    if(!self.itemArray.count)
    {
        [self myGroupIsEmpty];

    }
    else
    {
        [self myGroupIsUnEmpty];

    }
}

- (void)myGroupIsEmpty
{
    [self.view addSubview:_emptyView];
}
- (void)myGroupIsUnEmpty
{
    [_emptyView removeFromSuperview];
}

- (void)initEmptyView
{
    _emptyView = [[LGGroupEmptyView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    __weak typeof(self) weakSelf = self;
    _emptyView.startGroupChatCallback =  ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf rightButtonPressed];
        }
    };
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    self.title = [StringUtil getLocalizableString:@"我的群组"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:@"联系人" andTarget:self andSelector:@selector(backButtonPressed)];
//    [UIAdapterUtil setRightButtonItemWithTitle:@"发起群聊" andTarget:self andSelector:@selector(rightButtonPressed)];
    
    [self initSearchBar];
    
    int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - DEF_SEARCHBAR_HEIGHT;
    
    //组织架构展示table
    orgTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, DEF_SEARCHBAR_HEIGHT, self.view.frame.size.width, tableH) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:orgTable];
    [orgTable setDelegate:self];
    [orgTable setDataSource:self];
    orgTable.scrollsToTop = YES;
    orgTable.backgroundColor=[UIColor clearColor];
    orgTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:orgTable];
    [orgTable release];
    
    [UIAdapterUtil setExtraCellLineHidden:orgTable];
    [UIAdapterUtil setExtraCellLineHidden:searchdispalyCtrl.searchResultsTableView];
    [self initEmptyView];

}

/** 获取固定群组和讨论组 */
- (void)refreshTableView{
    
    if (_itemArray == nil) {
        _itemArray = [[NSMutableArray alloc]init];
    }else{
        [_itemArray removeAllObjects];
    }
    
    //公司群组(固定群组)regular_group
    NSArray *regularGroupArray = [[UserDataDAO getDatabase] getALlSystemGroup];
    [self dataProcess:regularGroupArray groupName:@"公司群" reloadSource:enum_item_type];
    //讨论组 type_dept_my_group
    NSArray *myGroupArray = [[UserDataDAO getDatabase] getALlCommonGroup];
    
    [self dataProcess:myGroupArray groupName:@"讨论组" reloadSource:enum_item_type];
    
    // 刷新表格
    [orgTable reloadData];
}

- (void)dataProcess:(NSArray *)arr groupName:(NSString *)groupName reloadSource:(int)sourceType
{
    NSMutableArray *allMyGroupArray = [[[NSMutableArray alloc]init]autorelease];
    NSString *nameStr = nil;
    SettingItem *_item;
    for (int index = 0; index < arr.count; index++) {
        Conversation *_conv = arr[index];
        
        if (index == 0) {
            // 设置组头视图
            _item = [[[SettingItem alloc]init]autorelease];
            _item.headerHight = DEF_GROUP_SECTION_HEADER_HEIGHT;
            _item.itemName = groupName;
//            _item.headerView = [[self class] getHeaderViewOfGroup:groupName];
            [allMyGroupArray addObject:_item];
        }
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = nameStr;
        _item.dataObject = _conv;
        // 打开会话
        _item.clickSelector = @selector(openConversation:);
        [allMyGroupArray addObject:_item];
    }
    // 为itemArray赋值  空数组不添加
    if (sourceType == enum_item_type && allMyGroupArray.count > 0) {
        [self.itemArray addObject:allMyGroupArray];
    }else if (sourceType == enum_search_type && allMyGroupArray.count > 0){
        [self.searchResults addObject:allMyGroupArray];
    }
}

/**
 打开会话界面

 @param conv 讨论组或公司群会话实体
 */
- (void)openConversation:(Conversation *)conv
{
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.talkType = mutiableType;
    talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
    talkSession.convId = conv.conv_id;
    talkSession.needUpdateTag=1;
    talkSession.convEmps =[[eCloudDAO getDatabase] getAllConvEmpBy:conv.conv_id];
    talkSession.last_msg_id=conv.last_msg_id;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
}

/**
 根据是否在搜索，返回数据源

 @return 数据源集合
 */
- (NSArray *)getDataSource
{
    if (isSearch) {
        return self.searchResults;
    }
    return self.itemArray;
}

/** 查看某个人的联系资料 */
- (void)openEmp:(Emp *)emp{
    [NewOrgViewController openUserInfoById:[StringUtil getStringValue:emp.emp_id] andCurController:self];
}

/** 打开二级界面，显示用户所在部门 */
- (void)openMyDept:(Dept *)dept{
    LGOrgViewController *vc = [[[LGOrgViewController alloc]init]autorelease];
    vc.curDeptId = dept.dept_id;
    [self.navigationController pushViewController:vc animated:YES];
    
    [UIAdapterUtil hideTabBar:self];
}

#pragma mark =======table view delegate===========
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        return self.searchResults.count;
    }
    return [self getDataSource].count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        NSArray *_array = self.searchResults[section];
        return _array.count;
    }
    NSArray *arr = [self getDataSource];
    if (section < arr.count) {
        NSArray * itemsArr = arr[section];
        return itemsArr.count - 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        return 33.0;
    }
    return 33.0;//DEF_GROUP_SECTION_HEADER_HEIGHT;
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section{
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    view.tintColor = [UIColor clearColor];
//    header.textLabel.font = [UIFont systemFontOfSize:12];
//    header.textLabel.textColor = [StringUtil colorWithHexString:@"#E4E4E4"];
//    if (tableView == searchdispalyCtrl.searchResultsTableView) {
//        header.textLabel.text = headShowArr[section];
//    }else{
//        SettingItem *_item = [self getItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] tableIndex:enum_section_head];
//        header.textLabel.text = _item.itemName;
//    }
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 33)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, (33-20)/2, self.view.frame.size.width-10, 20)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [StringUtil colorWithHexString:@"#A9A9A9"];

    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        label.text = headShowArr[section];
    }else{
        SettingItem *_item = [self getItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] tableIndex:enum_section_head];
        label.text = _item.itemName;
    }
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    SettingItem *_item = [self getItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] tableIndex:enum_section_head];
//    if (_item.headerView) {
//        return _item.headerView;
//    }
//    return nil;
//}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        SettingItem *_item = [self getSearchResultItemByIndexPath:indexPath];
        LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        [cell configureCellWithObject:_item];
        return cell;
    }
    SettingItem *_item = [self getItemByIndexPath:indexPath tableIndex:enum_row];
    
    LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    [cell configureCellWithObject:_item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        SettingItem *_item = [self getSearchResultItemByIndexPath:indexPath];
        if (_item.clickSelector) {
            if (_item.dataObject) {
                [self performSelector:_item.clickSelector withObject:_item.dataObject];
            }else{
                [self performSelector:_item.clickSelector];
            }
        }
        return;
    }
    
    SettingItem *_item = [self getItemByIndexPath:indexPath tableIndex:enum_row];
    if (_item.clickSelector) {
        if (_item.dataObject) {
            [self performSelector:_item.clickSelector withObject:_item.dataObject];
        }else{
            [self performSelector:_item.clickSelector];
        }
    }
//    if (isSearch) {
//        [self searchCancel];
//    }
}

#pragma mark ======搜索=======

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchStr = [StringUtil trimString:searchBar.text];
    if([self.searchStr length] == 0)
    {
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)searchOrg
{
    dispatch_queue_t queue = dispatch_queue_create("search org", NULL);
    
    dispatch_async(queue, ^{
        int _type = [StringUtil getStringType:self.searchStr];
        
        if(_type != other_type){
            if (!headShowArr) {
                headShowArr = [[NSMutableArray alloc]init];
            }else{
                [headShowArr removeAllObjects];
            }
            
            SettingItem *_item = nil;
            
            NSMutableArray *dataarray=[NSMutableArray array];
            NSMutableArray *_array ;
            //            搜索人员
            [[eCloudDAO getDatabase] setLimitWhenSearchUser:YES];
            NSArray *emparray= [[eCloudDAO getDatabase] getEmpsByNameOrPinyin:self.searchStr andType:_type];
            
            if (emparray && emparray.count > 0) {
                _array = [NSMutableArray array];
                // 显示 同事 组头
                [headShowArr addObject:DEF_HEAD_TITLE_ARR[title_emp]];
                for (Emp *_emp in emparray) {
                    [[eCloudDAO getDatabase]setEmpDeptAttrOfLG:_emp];
                    _item = [[[SettingItem alloc]init]autorelease];
                    _item.dataObject = _emp;
                    _item.searchContent = self.searchStr;
                    _item.clickSelector = @selector(openEmp:); //点击事件
                    
                    [_array addObject:_item];
                }
                [dataarray addObject:_array];
            }
            
            //讨论组 type_dept_my_group
            NSArray *myGroupArray = [[UserDataDAO getDatabase] getGroupsBytype:common_group_type where:self.searchStr];
            if (myGroupArray && myGroupArray.count > 0) {
                _array = [NSMutableArray array];
                // 显示 讨论组 组头
                [headShowArr addObject:DEF_HEAD_TITLE_ARR[title_custom_group]];
                for (Conversation *_conv in myGroupArray) {
                    _item = [[[SettingItem alloc]init]autorelease];
                    _item.dataObject = _conv;
                    _item.searchContent = self.searchStr;
                    _item.clickSelector = @selector(openConversation:); //点击事件
                    
                    [_array addObject:_item];
                }
                [dataarray addObject:_array];
            }
            // 公司群
            NSArray *regularGroupArray = [[UserDataDAO getDatabase] getGroupsBytype:system_group_type where:self.searchStr];
            if (regularGroupArray && regularGroupArray.count > 0) {
                _array = [NSMutableArray array];
                // 显示 公司群 组头
                [headShowArr addObject:DEF_HEAD_TITLE_ARR[title_group]];
                for (Conversation *_conv in regularGroupArray) {
                    _item = [[[SettingItem alloc]init]autorelease];
                    _item.dataObject = _conv;
                    _item.searchContent = self.searchStr;
                    _item.clickSelector = @selector(openConversation:); //点击事件
                    
                    [_array addObject:_item];
                }
                [dataarray addObject:_array];
            }
            
            //            增加搜索部门
            if ([eCloudConfig getConfig].needSearchDept) {
                NSArray *tempDeptArray = [[eCloudDAO getDatabase] getDeptByNameOrPinyin:self.searchStr andType:_type];
                if (tempDeptArray && tempDeptArray.count > 0) {
                    _array = [NSMutableArray array];
                    // 显示 部门 组头
                    [headShowArr addObject:DEF_HEAD_TITLE_ARR[title_dept]];
                    for (Dept *_dept in tempDeptArray) {
                        _item = [[[SettingItem alloc]init]autorelease];
                        _item.dataObject = _dept;
                        _item.itemName = _dept.dept_name;
                        _item.searchContent = self.searchStr;
                        _item.clickSelector = @selector(openMyDept:); //点击事件
                        
                        [_array addObject:_item];
                    }
                    [dataarray addObject:_array];
                }
            }
            
            [self.searchResults removeAllObjects];
            //            [self.searchResults addObject:dataarray];
            [self.searchResults addObjectsFromArray:dataarray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
            self.searchDisplayController.searchResultsTableView.contentOffset = CGPointMake(0, 0);
            if (![self.searchResults count]) {
                [UIAdapterUtil setSearchResultsTitle:[NSString stringWithFormat:[StringUtil getLocalizableString:@"no_search_result"],self.searchStr] andCurVC:self];
            }
            
            [UserTipsUtil hideLoadingView];
        });
    });
    dispatch_release(queue);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchStr length] < [eCloudConfig getConfig].searchTextMinLen.intValue) {
        [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"search_tip"]];
        return;
    }
    
    [searchBar resignFirstResponder];
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"searching"]];
    
    [self searchOrg];
}

#pragma mark - UISearchDisplayDelegate协议方法
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    orgTable.scrollsToTop = NO;
    controller.searchResultsTableView.scrollsToTop = YES;
    
    // 激活搜索框时，添加提示语view
    [self performSelector:@selector(addTipsViewWithCtrl:) withObject:controller afterDelay:0.1];
    
    [UIAdapterUtil hideTabBar:self];
    [UIAdapterUtil customCancelButton:self];
}

// 查询前显示提示语
- (void)addTipsViewWithCtrl:(UISearchDisplayController *)controller
{
    [UIAdapterUtil addTipsViewWithView:controller];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    orgTable.scrollsToTop = YES;
    controller.searchResultsTableView.scrollsToTop = NO;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [UIAdapterUtil setSearchResultsTitle:@"" andCurVC:self];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
        //         南航融合版本 搜索纪录 被盖住了，隐藏修改尺寸
        CGRect _frame = CGRectMake(0, 0, tableView.frame.size.width, SCREEN_HEIGHT - 108);
        tableView.frame = _frame;
    }
}

-(void)searchCancel
{
    [self.searchDisplayController setActive:NO animated:NO];
}

- (void)searchConversation
{
    int _type = [StringUtil getStringType:self.searchStr];
    
    if(_type != other_type){
        [self.searchResults removeAllObjects];
        
        //公司群组(固定群组)regular_group
        NSArray *regularGroupArray = [[UserDataDAO getDatabase] getGroupsBytype:system_group_type where:self.searchStr];
        [self dataProcess:regularGroupArray groupName:@"公司群" reloadSource:enum_search_type];
        //讨论组 type_dept_my_group
        NSArray *myGroupArray = [[UserDataDAO getDatabase] getGroupsBytype:common_group_type where:self.searchStr];
        [self dataProcess:myGroupArray groupName:@"讨论组" reloadSource:enum_search_type];
    }
    
    [searchdispalyCtrl.searchResultsTableView reloadData];
    [[LCLLoadingView currentIndicator] hiddenForcibly:true];
}

//根据indexPath获取item
- (SettingItem *)getItemByIndexPath:(NSIndexPath *)indexPath tableIndex:(int)tableIndex
{
    NSArray *itemArr = nil;
    if (isSearch) {
        itemArr = self.searchResults[indexPath.section];
    }else{
        itemArr = self.itemArray[indexPath.section];
    }
    
    SettingItem *_item = nil;
    if (tableIndex == enum_row && (indexPath.row+1) <= itemArr.count) {
        _item = itemArr[indexPath.row + 1];
    }else if(tableIndex == enum_section_head && (indexPath.row+1) <= itemArr.count){
        _item = itemArr[0];
    }
    return _item;
}

//根据indexPath获取搜索结果item
- (SettingItem *)getSearchResultItemByIndexPath:(NSIndexPath *)indexPath
{
    NSArray *_array = self.searchResults[indexPath.section];
    SettingItem *_item = _array[indexPath.row];
    return _item;
}

/**
 获取组头视图

 @param groupName 组头名称

 @return 组头视图
 */
+ (UIView *)getHeaderViewOfGroup:(NSString *)groupName
{
    UIColor *backgroundColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
    UIColor *foreColor = [UIColor colorWithRed:156.0/255 green:156.0/255 blue:156.0/255 alpha:1.0];
    
    UIView *headBgView = [[[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,DEF_GROUP_SECTION_HEADER_HEIGHT)]autorelease];
    headBgView.backgroundColor = [UIColor clearColor];
    headBgView.layer.backgroundColor = backgroundColor.CGColor;
    
    UILabel *titlelabel = [[[UILabel alloc]initWithFrame:CGRectMake(12,0.0, SCREEN_WIDTH - 12, DEF_GROUP_SECTION_HEADER_HEIGHT)]autorelease];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.layer.backgroundColor = backgroundColor.CGColor;
    titlelabel.numberOfLines = 2;
    titlelabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titlelabel.font = [UIFont systemFontOfSize:13.5];
    titlelabel.textColor = foreColor;
    
    titlelabel.textAlignment = NSTextAlignmentLeft;
    // [StringUtil getLocalStringRelatedWithAppNameByKey:@"select_custom_groups_tip"]
    titlelabel.text = [NSString stringWithFormat:@"\n%@",groupName];
    [headBgView addSubview:titlelabel];
    [titlelabel sizeToFit];
    return headBgView;
}

- (UITableView *)getTableView{
    UITableView *tableView;
    if (isSearch){
        tableView = searchdispalyCtrl.searchResultsTableView;
    }
    else{
        tableView = orgTable;
    }
    return tableView;
}

#pragma mark =====chooseMemberDelegate=======
- (void)didFinishSelectContacts:(NSArray *)userArray{
    [CreateGroupUtil getUtil].typeTag = type_create_conversation;
    [[CreateGroupUtil getUtil]createGroup:userArray];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    if (!searchdispalyCtrl.isActive) {
        int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - DEF_SEARCHBAR_HEIGHT;
        if (orgTable.frame.size.height != tableH) {
            orgTable.frame = CGRectMake(0.0, DEF_SEARCHBAR_HEIGHT, self.view.frame.size.width, tableH);
        }
    }
}

@end
