//
//  LGOrgViewController.m
//  eCloud
//
//  Created by shisuping on 17/7/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGRootOrgViewController.h"
#import "LGOrgDefine.h"
#import "LGOrgViewController.h"
#import "LGRootChooseMemberViewController.h"
#import "LGGroupViewController.h"
#import "JPLabel.h"

@interface LGRootOrgViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,ChooseMemberDelegate>
{
    UITableView *orgTable;
    UISearchBar *_searchBar;
    UISearchDisplayController *searchdispalyCtrl;
    
//    通讯录是否展开
    BOOL isOrgExtend;
    
//    常用联系人是否展开
    BOOL isCommonEmpExtend;
    
    NSMutableArray *headShowArr;
    CGFloat _tableViewLineX;

}

@property (nonatomic,retain) NSString *searchStr;

@property (nonatomic,retain)NSMutableArray *itemArray;

/** 搜索结果 */
@property (nonatomic,retain)NSMutableArray *searchResults;

@end

@implementation LGRootOrgViewController

- (void)dealloc{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    self.searchStr = nil;
    self.itemArray = nil;
    self.searchResults = nil;
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (searchdispalyCtrl.isActive) {
        [UIAdapterUtil hideTabBar:self];
    }else{
        [UIAdapterUtil showTabar:self];
    }
    self.title = [StringUtil getAppLocalizableString:@"main_cont"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    //右边按钮
    UIButton *button = [UIAdapterUtil setRightButtonItemWithImageName:@"add_ios.png" andTarget:self andSelector:@selector(addButtonPressed:)];
    [button setImage:[StringUtil getImageByResName:@"add_ios_hl.png"] forState:UIControlStateHighlighted];
    
    [self initSearchBar];
    
    int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - TABBAR_HEIGHT - _searchBar.frame.size.height;
    
    //组织架构展示table
    orgTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, _searchBar.frame.size.height, self.view.frame.size.width, tableH) style:UITableViewStyleGrouped];
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

    [self addObserver];
    
    NSArray *tempArray = [self getRootItem];
    self.itemArray = [NSMutableArray arrayWithArray:tempArray];
    [orgTable reloadData];
    
}


- (void)addObserver{
    //add by shisp  注册组织架构信息变动通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:UPDATE_USER_DATA_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCancel) name:BACK_TO_CONTACTVIEW_FROM_NEWORG object:nil];
//
//    //刷新通讯录语言
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLanguage) name:REFREASH_CONACTS_LANGUAGE object:nil];
    
    //    update by shisp 当和会话列表相关的表有更新时，会发出通知，在这里接收通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];

}

#pragma mark - 选择联系人
-(void) addButtonPressed:(id) sender{
    [_searchBar resignFirstResponder];
    
    LGRootChooseMemberViewController *vc = [[[LGRootChooseMemberViewController alloc]init]autorelease];
    vc.chooseMemberDelegate = self;
    vc.maxSelectCount = [conn getConn].maxGroupMember - 1;
    vc.oldEmpIdArray = [NSArray arrayWithObject:[conn getConn].curUser];
    UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)initSearchBar
{
//    默认都是展开的
    isOrgExtend = YES;
    isCommonEmpExtend = YES;
    
    //查询bar
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getAppLocalizableString:@"chats_search"];
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
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

//根据indexPath获取item
- (SettingItem *)getItemByIndexPath:(NSIndexPath *)indexPath
{
    NSArray *_array = self.itemArray[indexPath.section];
    
    SettingItem *_item = _array[indexPath.row];
    return _item;
}
//根据indexPath获取搜索结果item
- (SettingItem *)getSearchResultItemByIndexPath:(NSIndexPath *)indexPath
{
    NSArray *_array = self.searchResults[indexPath.section];
    SettingItem *_item = _array[indexPath.row];
    return _item;
}

/** 打开和文件助手的聊天 */
- (void)openMyCoumputer{
    NSLog(@"open my computer");
    
    Emp *_emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:USERCODE_OF_FILETRANSFER];
    [UIAdapterUtil openConversation:self andEmp:_emp];

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

/** 打开我的群组二级界面 */
- (void)openMyGroup{
    NSLog(@"open my group");
    LGGroupViewController *vc = [[[LGGroupViewController alloc]init]autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    [UIAdapterUtil hideTabBar:self];
}

/** 展开或者收起 组织架构及自己的部门 */
- (void)extendOrg{
    isOrgExtend = YES;
    NSArray *tempArray = [self getRootItem];
    self.itemArray = [NSMutableArray arrayWithArray:tempArray];
    [orgTable reloadData];
}

- (void)packUpOrg{
    isOrgExtend = NO;
    NSArray *tempArray = [self getRootItem];
    self.itemArray = [NSMutableArray arrayWithArray:tempArray];
    [orgTable reloadData];
}

/** 打开二级界面，显示所有一级部门 */
- (void)openOrgRoot{
    LGOrgViewController *vc = [[[LGOrgViewController alloc]init]autorelease];
    vc.curDeptId = 0;
    [self.navigationController pushViewController:vc animated:YES];
    [UIAdapterUtil hideTabBar:self];
}

/** 打开二级界面，显示用户所在部门 */
- (void)openMyDept:(Dept *)dept{
    LGOrgViewController *vc = [[[LGOrgViewController alloc]init]autorelease];
    vc.curDeptId = dept.dept_id;
    [self.navigationController pushViewController:vc animated:YES];

    [UIAdapterUtil hideTabBar:self];

}


/** 收起常用联系人 */
- (void)extendCommonEmp{
    isCommonEmpExtend = YES;
    NSArray *tempArray = [self getRootItem];
    self.itemArray = [NSMutableArray arrayWithArray:tempArray];
    [orgTable reloadData];
}

/** 展开常用联系人 */
- (void)packUpCommonEmp{
    isCommonEmpExtend = NO;
    NSArray *tempArray = [self getRootItem];
    self.itemArray = [NSMutableArray arrayWithArray:tempArray];
    [orgTable reloadData];
}

/** 查看某个人的联系资料 */
- (void)openEmp:(Emp *)emp{
    [NewOrgViewController openUserInfoById:[StringUtil getStringValue:emp.emp_id] andCurController:self];
}

-(NSArray *)getRootItem
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSMutableArray *_array;
    SettingItem *_item;
    
    Dept *tempDept = nil;
    
//    =======第一个分组
    {
        //    我的电脑
        _array = [NSMutableArray array];
        
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"contact_FileTransfer"]];
        _item.imageName = @"btn_chat_add_file"; //我的电脑对应的图片
        _item.clickSelector = @selector(openMyCoumputer); //点击我的电脑
        
        [_array addObject:_item];
        
        //我的群组
        _item = [[[SettingItem alloc]init]autorelease];
        
        _item.itemName = @"我的群组";// [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"me_custom_groups"]];
        _item.imageName = @"ic_contact_group"; //我的群组对应的图片
        _item.clickSelector = @selector(openMyGroup); //点击我的群组
        
        [_array addObject:_item];
        
        [tempArray addObject:_array];
    }
    
//    ========第二个分组
    {
        //    四川蓝光和骏实业有限公司 组织架构 互联网信息中心等自己的部门
        _array = [NSMutableArray array];
        
        _item = [[[SettingItem alloc]init]autorelease];
        _item.dataObject = tempDept;
        _item.itemName = @"蓝光发展";
        _item.imageName = @"ic_contact_languang_brc"; //对应的图片
        if (isOrgExtend) {
            _item.clickSelector = @selector(packUpOrg);
        }else{
            _item.clickSelector = @selector(extendOrg);
        }
        
        [_array addObject:_item];
        
        if (isOrgExtend) {
            
            _item = [[[SettingItem alloc]init]autorelease];
            _item.dataObject = tempDept;
            _item.itemName = @"组织架构";
            _item.imageName = @"ic_contact_connect"; //对应的图片
            _item.clickSelector = @selector(openOrgRoot); //点击事件
            
            [_array addObject:_item];
            
            //    用户自己所在部门
            NSArray *userDeptArray = [[eCloudDAO getDatabase]getDeptByEmpId:[conn getConn].curUser.emp_id];
            for (Dept *_dept in userDeptArray) {
                
                _item = [[[SettingItem alloc]init]autorelease];
                _item.dataObject = _dept;
                _item.itemName = _dept.dept_name;
                _item.imageName = @"ic_contact_connect"; //对应的图片
                _item.clickSelector = @selector(openMyDept:); //点击事件
                
                [_array addObject:_item];
            }
        }
        
        [tempArray addObject:_array];

    }
    
//========第三个分组
    {
        _array = [NSMutableArray array];

        //    常用联系人 已经用户所有的常用联系人
        _item = [[[SettingItem alloc]init]autorelease];
        _item.dataObject = tempDept;
        _item.itemName = @"常联系人";
        _item.imageName = @"ic_contact_common"; //对应的图片
        if (isCommonEmpExtend) {
            _item.clickSelector = @selector(packUpCommonEmp); //点击事件
        }else{
            _item.clickSelector = @selector(extendCommonEmp); //点击事件
        }
        
        [_array addObject:_item];
        
        if (isCommonEmpExtend) {
            NSArray *commonEmpArray = [[UserDataDAO getDatabase]getAllCommonEmp];
            for (Emp *_emp in commonEmpArray) {
                [[eCloudDAO getDatabase]setEmpDeptAttrOfLG:_emp];
                _item = [[[SettingItem alloc]init]autorelease];
                _item.dataObject = _emp;
                _item.clickSelector = @selector(openEmp:); //点击事件
                
                [_array addObject:_item];
            }
        }
        
        [tempArray addObject:_array];
    }

    return tempArray;
}

#pragma mark ======搜索=======
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

    [UIAdapterUtil showTabar:self];
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

#pragma mark 通知处理
//收到组织架构通知后，进行处理，如果是第一次加载，那么关闭对话框，否则从数据库中获取组织架构并刷新
-(void)refreshOrg:(NSNotification*)notification
{
    eCloudNotification *cmd = notification.object;
    switch (cmd.cmdId) {
        case first_load_org:
        case refresh_org:
        {
//            [[LCLLoadingView currentIndicator]hiddenForcibly:true];
//            [self getRootItem];
//            [orgTable reloadData];
            // 刷新常用联系人
            [self extendCommonEmp];
        }
            break;
        default:
            break;
    }
}

-(void)searchCancel
{
    [self.searchDisplayController setActive:NO animated:NO];
}

-(void)refreshLanguage
{
    [self getRootItem];
    [orgTable reloadData];
}

-(void)processNewConvNotification:(NSNotification *)notification
{
    eCloudNotification *_notification = [notification object];
    if(_notification != nil)
    {
        int cmdId = _notification.cmdId;
        switch (cmdId) {
            case user_logo_changed:
            {
                NSDictionary *dic = _notification.info;
                
                int empId = [[dic valueForKey:@"emp_id"]intValue];
                NSString *empLogo = [dic valueForKey:@"emp_logo"];
                
                if (self.searchDisplayController.active)
                {
                    for (int i = 0; i < self.searchResults.count; i++)
                    {
                        NSArray *_array = self.searchResults[i];
                        
                        for (int j = 0; j < _array.count; j++ ) {
                            SettingItem *item = _array[j];
                            if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                                Emp *_emp = (Emp *)item.dataObject;
                                if (_emp.emp_id == empId)
                                {
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                                    [self.searchDisplayController.searchResultsTableView beginUpdates];
                                    [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                    [self.searchDisplayController.searchResultsTableView endUpdates];
                                    break;
                                }

                            }
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < self.itemArray.count; i++)
                    {
                        NSArray *_array = self.itemArray[i];
                        
                        for (int j = 0; j < _array.count; j++ ) {
                            SettingItem *item = _array[j];
                            if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                                Emp *_emp = (Emp *)item.dataObject;
                                if (_emp.emp_id == empId)
                                {
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                                    [self.searchDisplayController.searchResultsTableView beginUpdates];
                                    [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                    [self.searchDisplayController.searchResultsTableView endUpdates];
                                    break;
                                }
                                
                            }
                        }
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}

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
                // 刷新常用联系人
                [self extendCommonEmp];
            }
                break;
            case update_user_data_fail:
            {
                
            }
                break;
            case update_user_data_timeout:
            {
                
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark =======table view delegate===========
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        return self.searchResults.count;
    }
    return self.itemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        NSArray *_array = self.searchResults[section];
        return _array.count;
    }
    NSArray *_array = self.itemArray[section];
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        return 33.0;
    }
    
    if (section > 0){
        return 12.0;
    }
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section{
    if (tableView != searchdispalyCtrl.searchResultsTableView) {
        view.tintColor = [UIColor clearColor];
    }else{
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        header.textLabel.font = [UIFont systemFontOfSize:12];
        header.textLabel.textColor = [StringUtil colorWithHexString:@"#A9A9A9"];
        header.textLabel.text = headShowArr[section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        SettingItem *_item = [self getSearchResultItemByIndexPath:indexPath];
        LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        [cell configureCellWithObject:_item];
        JPLabel *nameLabel = (JPLabel*)[cell viewWithTag:emp_name_tag];
        _tableViewLineX = nameLabel.frame.origin.x;

        return cell;
    }
    
    SettingItem *_item = [self getItemByIndexPath:indexPath];
    LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    [cell configureCellWithObject:_item];
    //对cell分割线进行文字对齐
    JPLabel *nameLabel = (JPLabel*)[cell viewWithTag:emp_name_tag];
//    [UIAdapterUtil alignHeadIconAndCellSeperateLine:orgTable withOriginX:nameLabel.frame.origin.x];
    nameLabel.userInteractionEnabled = NO;
    _tableViewLineX = nameLabel.frame.origin.x;

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
    
    SettingItem *_item = [self getItemByIndexPath:indexPath];
    if (_item.clickSelector) {
        if (_item.dataObject) {
            [self performSelector:_item.clickSelector withObject:_item.dataObject];
        }else{
//            orgTable.style = UITableViewStyleGrouped;
            [self performSelector:_item.clickSelector];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, _tableViewLineX, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}

#pragma mark =====chooseMemberDelegate=======
- (void)didFinishSelectContacts:(NSArray *)userArray{
    [CreateGroupUtil getUtil].typeTag = type_create_conversation;
    [[CreateGroupUtil getUtil]createGroup:userArray];
}

- (void)viewWillLayoutSubviews
{
    if (!searchdispalyCtrl.isActive) {
        int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - _searchBar.frame.size.height - self.tabBarController.tabBar.frame.size.height;
        orgTable.frame = CGRectMake(0.0, _searchBar.frame.size.height+SEARCHBAR_SPACE, self.view.frame.size.width, tableH);
        
    }
}





@end
