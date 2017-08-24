//
//  LGOrgViewController.m
//  eCloud
//
//  Created by shisuping on 17/7/25.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGOrgViewController.h"
#import "LGOrgDefine.h"
#import "JPLabel.h"


@interface LGOrgViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    UITableView *orgTable;
    UIView *emptyView;
    UISearchBar *_searchBar;
    UISearchDisplayController *searchdispalyCtrl;
    
    UIScrollView *scrollView;
    
    NSMutableArray *headShowArr;
}

/** 部门层级 数组 */
@property (nonatomic,retain)NSMutableArray *deptArray;

/** 当前界面 数据项 */
@property (nonatomic,retain)NSMutableArray *itemArray;

/** 搜索结果 */
@property (nonatomic,retain)NSMutableArray *searchResults;

@property (nonatomic,retain) NSString *searchStr;


@end

@implementation LGOrgViewController
{
    CGFloat _tableViewLineX;
}
- (void)dealloc{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    self.deptArray = nil;
    self.searchStr = nil;
    self.itemArray = nil;
    self.searchResults = nil;
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    [super dealloc];
}

/** 搜索栏下面是部门层级scrollview */
- (void)addTopNavBar{
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,searchbar_height+SEARCHBAR_SPACE, SCREEN_WIDTH, top_dept_height)];
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    scrollView.scrollsToTop = NO;
    [scrollView release];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(scrollView.frame)-1, self.view.frame.size.width, 0.6)];
    view.backgroundColor = [StringUtil colorWithHexString:@"#E4E4E4"];
    [self.view addSubview:view];
    
}

/** 搜索bar */
- (void)initSearchBar
{
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, searchbar_height)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getAppLocalizableString:@"chats_search"];
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    // 修改搜索框的外层背景颜色与搜索文本框的背景色
    [UIAdapterUtil setSearchColorForTextBarAndBackground:_searchBar];
    
    [self.view addSubview:_searchBar];
    [_searchBar release];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), self.view.frame.size.width, 0.6)];
    view.backgroundColor = [StringUtil colorWithHexString:@"#E4E4E4"];
    [self.view addSubview:view];

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:@"联系人" andTarget:self andSelector:@selector(backButtonPressed)];

    [self initSearchBar];
    
    [self addTopNavBar];
    
    int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - searchbar_height - top_dept_height - top_to_tableview_space;
    
    //组织架构展示table
    orgTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, searchbar_height + top_dept_height + top_to_tableview_space, self.view.frame.size.width, tableH) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:orgTable];
    [orgTable setDelegate:self];
    [orgTable setDataSource:self];
    orgTable.scrollsToTop = YES;
    orgTable.backgroundColor=[UIColor clearColor];
    orgTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:orgTable];
    [orgTable release];
    
    emptyView = [[UIView alloc]initWithFrame:orgTable.frame];
    emptyView.backgroundColor = [UIColor clearColor];
    CGFloat fontSize = 14.0f;
    NSString *tips = [StringUtil getLocalizableString:@"dept_no_person_tip"];
    CGSize font = [tips sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    UILabel *tipL = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-font.width)/2, tableH/4, font.width, font.height)];
    tipL.textAlignment = NSTextAlignmentCenter;
    tipL.font = [UIFont systemFontOfSize:fontSize];
    tipL.text = tips;
    tipL.textColor = [StringUtil colorWithHexString:@"#A2A2A2"];
    [emptyView addSubview:tipL];
    [tipL release];
    emptyView.hidden = YES;
    [self.view addSubview:emptyView];
    [emptyView release];
    
    [UIAdapterUtil setExtraCellLineHidden:orgTable];
    [UIAdapterUtil setExtraCellLineHidden:searchdispalyCtrl.searchResultsTableView];
    
    [self refreshTopBar];
    
    [self refreshTableView];
}

- (void)btnAction:(id)sender{
    int _tag = (int)((UIButton *)sender).tag;
    int index = _tag - dept_tag_base;
    
    if (index == 0) {
        [self backButtonPressed];
    }else if (index < self.deptArray.count){
        Dept *_dept = self.deptArray[index];
        self.curDeptId = _dept.dept_id;
        [self refreshTopBar];
        [self refreshTableView];
    }
}

/** 获取顶部部门层级数组 */
- (void)refreshTopBar{
    
    for (UIView *eachView in [scrollView subviews])
    {
        [eachView removeFromSuperview];
        eachView = nil;
    }
    
    Dept *tempDept;
    
    NSMutableArray *mArray = [NSMutableArray array];
    
    tempDept = [[[Dept alloc]init]autorelease];
    tempDept.dept_name = @"联系人";
    [mArray addObject:tempDept];
    
    tempDept = [[[Dept alloc]init]autorelease];
    tempDept.dept_id = 0;
    tempDept.dept_name = @"蓝光发展";
    [mArray addObject:tempDept];
    
/** 如果当期不是跟部门，那么需要显示部门导航 */
    if (self.curDeptId > 0) {
        NSArray *parentDept = [[eCloudDAO getDatabase]getParentDepts:[StringUtil getStringValue:self.curDeptId]];
        NSMutableArray *_array = [NSMutableArray arrayWithArray:parentDept];
        [_array addObject:[StringUtil getStringValue:self.curDeptId]];
        
        for (NSString *deptId in _array) {
            NSDictionary *dic = [[eCloudDAO getDatabase]searchDept:deptId];
            
            tempDept = [[[Dept alloc]init]autorelease];
            tempDept.dept_name = dic[@"dept_name"];
            tempDept.dept_id = [dic[@"dept_id"]intValue];
            [mArray addObject:tempDept];
        }
        
    }
    
    self.deptArray = [NSMutableArray arrayWithArray:mArray];
    
    float buttonX = 0;
    
    int deptNavCount = (int)[self.deptArray count];
    
    for (int i = 0; i < deptNavCount; i ++) {
        Dept *_dept = self.deptArray[i];
        
        UIFont *textFont = [UIFont systemFontOfSize:top_dpet_name_font_size];
        
        CGSize textSize = [_dept.dept_name sizeWithAttributes:@{NSFontAttributeName:textFont}];
        
        float btnWidth = textSize.width + 2 * top_dept_name_space;
        
        UIButton *btn = [[[UIButton alloc] initWithFrame:CGRectMake(buttonX, 0, btnWidth, top_dept_height)]autorelease];
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:_dept.dept_name forState:UIControlStateNormal];
        
        [btn setTitleColor:top_dept_name_active_color forState:UIControlStateNormal];
        [btn setTitleColor:top_dept_name_inactive_color forState:UIControlStateDisabled];
        [btn.titleLabel setFont:textFont];
        
        btn.tag = (dept_tag_base + i);
        
        [scrollView addSubview:btn];
        
        buttonX += btnWidth;
        
        if (i == (deptNavCount - 1)) {
//            不用加>图片
            btn.enabled = NO;
//            设置标题
            self.title = @"蓝光发展组织架构";//_dept.dept_name;
        }else{

//            给按钮添加点击事件
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

//            显示>图片
            UIImage *arrowImage = [StringUtil getImageByResName:@"btn_right_arrow"];
            float arrowX = buttonX;
            float arrowY = (top_dept_height - arrowImage.size.height) * 0.5;
            
            UIImageView *arrowView = [[[UIImageView alloc]initWithFrame:CGRectMake(arrowX, arrowY, arrowImage.size.width, arrowImage.size.height)]autorelease];
            arrowView.image = arrowImage;
            [scrollView addSubview:arrowView];
            
            buttonX += arrowImage.size.width;
            
        }
    }
    
    scrollView.contentSize = CGSizeMake(buttonX, top_dept_height);
    if (scrollView.contentSize.width > SCREEN_WIDTH) {
        scrollView.contentOffset = CGPointMake(scrollView.contentSize.width - SCREEN_WIDTH, 0);
    }
}

/** 根据部门名称返回自定义头像的颜色和要显示的文本 */
+ (NSDictionary *)getUserDefineLogoDic:(Dept *)_dept{
    if (_dept.dept_parent == 0) {
        NSString *deptName = _dept.dept_name;
        UIColor *logoColor = nil;
        NSString *logoText = nil;
        
        if ([deptName rangeOfString:@"发展"].length) {
            logoText = @"发展";
            logoColor = lg_main_color;
        }else if ([deptName rangeOfString:@"地产"].length) {
            logoText = @"地产";
            logoColor = [UIColor colorWithRed:0xE8/255.0 green:0xB7/255.0 blue:0x00/255.0 alpha:1];
        }else if ([deptName rangeOfString:@"生命"].length) {
            logoText = @"生命";
            logoColor = [UIColor colorWithRed:0x66/255.0 green:0xC6/255.0 blue:0x55/255.0 alpha:1];
        }else if ([deptName rangeOfString:@"服务"].length) {
            logoText = @"服务";
            logoColor = [UIColor colorWithRed:0x89/255.0 green:0xBB/255.0 blue:0xFD/255.0 alpha:1];
        }else if ([deptName rangeOfString:@"网络"].length) {
            logoText = @"网络";
            logoColor = [UIColor colorWithRed:0x58/255.0 green:0x9F/255.0 blue:0xFD/255.0 alpha:1];
        }else if ([deptName rangeOfString:@"外部"].length) {
            logoText = @"外部";
            logoColor = [UIColor colorWithRed:0xB4/255.0 green:0xD4/255.0 blue:0xFE/255.0 alpha:1];
        }else{
            logoColor = randomColor;
            if (deptName.length <= 2) {
                logoText = deptName;
            }else{
                logoText = [deptName substringToIndex:2];
            }
        }

        if (logoColor) {
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            mDic[KEY_USER_DEFINE_LOGO_TEXT] = logoText;
            mDic[KEY_USER_DEFINE_LOGO_BG_COLOR] = logoColor;
            mDic[KEY_USER_DEFINE_LOGO_SIZE] = @(logo_height);
            mDic[KEY_USER_DEFINE_LOGO_TEXT_SIZE] = @(14.0);
            mDic[KEY_USER_DEFINE_LOGO_TEXT_COLOR] = [UIColor whiteColor];
            return mDic;
        }
    }
    return nil;
}

/** 查看某个人的联系资料 */
- (void)openEmp:(Emp *)emp{
    [NewOrgViewController openUserInfoById:[StringUtil getStringValue:emp.emp_id] andCurController:self];
}

/** 打开部门 */
- (void)openDept:(Dept *)dept{
    
    self.curDeptId = dept.dept_id;
    [self refreshTopBar];
    [self refreshTableView];
    
    [self searchCancel];
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

/** 获取部门人员和子部门 */
- (void)refreshTableView{
    NSMutableArray *allArray=[NSMutableArray array];
    
    //         子部门
    NSArray *tempDeptArray = [[eCloudDAO getDatabase] getLocalNextDeptInfoWithLevel:[StringUtil getStringValue:self.curDeptId]  andLevel:0];
    //         部门下的人员
    NSArray *tempEpArray = nil;
    
    if (self.curDeptId) {
        tempEpArray = [[eCloudDAO getDatabase] getEmpsByDeptID:self.curDeptId andLevel:0];
    }
    
    SettingItem *_item;
    
    for (Emp *_emp in tempEpArray) {
        [[eCloudDAO getDatabase]setEmpDeptAttrOfLG:_emp];

        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = _emp.emp_name;
        _item.dataObject = _emp;
//        打开用户资料
        _item.clickSelector = @selector(openEmp:);
        [allArray addObject:_item];
    }
    
    for (Dept *_dept in tempDeptArray) {
        _item = [[[SettingItem alloc]init]autorelease];
        _item.itemName = _dept.dept_name;
        
        _item.logoDic = [[self class]getUserDefineLogoDic:_dept];
        _item.clickSelector = @selector(openDept:);
        _item.dataObject = _dept;
        [allArray addObject:_item];
    }
    
    self.itemArray = [NSMutableArray arrayWithObject:allArray];
    
    [orgTable reloadData];
    if (allArray.count == 0) {
        // 显示空视图
        emptyView.hidden = NO;
    }else{
        emptyView.hidden = YES;
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
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section{
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        header.textLabel.font = [UIFont systemFontOfSize:12];
        header.textLabel.textColor = [StringUtil colorWithHexString:@"#A9A9A9"];
        header.textLabel.text = headShowArr[section];
    }
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == searchdispalyCtrl.searchResultsTableView) {
        SettingItem *_item = [self getSearchResultItemByIndexPath:indexPath];
        LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        [cell configureCellWithObject:_item];
        return cell;
    }

    SettingItem *_item = [self getItemByIndexPath:indexPath];
    LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    [cell configureCellWithObject:_item];
    

    JPLabel *nameLabel = (JPLabel*)[cell viewWithTag:emp_name_tag];
//    [UIAdapterUtil alignHeadIconAndCellSeperateLine:orgTable withOriginX:nameLabel.frame.origin.x];
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
            [self performSelector:_item.clickSelector];
        }
    }
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

#pragma mark - 搜索相关
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
                        _item.clickSelector = @selector(openDept:); //点击事件
                        
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    if (!searchdispalyCtrl.isActive) {
        int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - searchbar_height - top_dept_height - top_to_tableview_space;
        if (orgTable.frame.size.height != tableH) {
            orgTable.frame = CGRectMake(0.0, searchbar_height + top_dept_height + top_to_tableview_space, self.view.frame.size.width, tableH);
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


@end
