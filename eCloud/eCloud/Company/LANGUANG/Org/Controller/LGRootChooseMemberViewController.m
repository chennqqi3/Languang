//
//  LGOrgViewController.m
//  eCloud
//
//  Created by shisuping on 17/7/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGRootChooseMemberViewController.h"
#import "LGOrgDefine.h"
#import "LGOrgViewController.h"
#import "JPLabel.h"

@interface LGRootChooseMemberViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,LGOrgCellProtocol>
{
    UITableView *orgTable;
    UISearchBar *_searchBar;
    UISearchDisplayController *searchdispalyCtrl;
    
    UIView *bottomNavibar;
    UIScrollView *bottomScrollview;
    UIButton *addButton;

//    默认没有选中全部
    BOOL isSelectAll;
    UIButton *rightBtn;


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

@property (assign, nonatomic) CGFloat topViewVal;
@property (assign, nonatomic) CGRect keyRect;

@end

@implementation LGRootChooseMemberViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self bottomScrollviewShow];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    self.searchStr = nil;
    
    self.itemArray = nil;
    self.searchResults = nil;
    
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;

    [super dealloc];
}

- (void)addObserver{
    //add by shisp  注册组织架构信息变动通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCancel) name:BACK_TO_CONTACTVIEW_FROM_NEWORG object:nil];
//    
//    //刷新通讯录语言
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLanguage) name:REFREASH_CONACTS_LANGUAGE object:nil];
}

#pragma mark - 添加联系人
-(void) addButtonPressed:(id) sender{
    [_searchBar resignFirstResponder];
    
    [self closeCurVC];
    
    if (self.chooseMemberDelegate && [self.chooseMemberDelegate respondsToSelector:@selector(didFinishSelectContacts:)]) {
        
        [self.chooseMemberDelegate didFinishSelectContacts:self.nowSelectedEmpArray];
    }
    [[conn getConn]setAllEmpNotSelect];
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
    LGChooseMemberViewController *vc = [[[LGChooseMemberViewController alloc]init]autorelease];
    vc.chooseMemberDelegate = self.chooseMemberDelegate;
    vc.maxSelectCount = self.maxSelectCount;
    vc.oldEmpIdArray = self.oldEmpIdArray;
    vc.isSingleSelect = self.isSingleSelect;

    vc.curDeptId = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

/** 打开二级界面，显示用户所在部门 */
- (void)openMyDept:(Dept *)dept{
    LGChooseMemberViewController *vc = [[[LGChooseMemberViewController alloc]init]autorelease];
    vc.chooseMemberDelegate = self.chooseMemberDelegate;
    vc.maxSelectCount = self.maxSelectCount;
    vc.oldEmpIdArray = self.oldEmpIdArray;
    vc.isSingleSelect = self.isSingleSelect;
    vc.curDeptId = dept.dept_id;
    [self.navigationController pushViewController:vc animated:YES];
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
    
    [self backButtonPressed:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
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

/** 点击Emp cell */
- (void)selectEmp:(Emp *)emp{
    int nowcount= (int)[self.nowSelectedEmpArray count];// [selectedEmps count];

    BOOL isOldMember=FALSE;
    if ([self isEmpInOldEmpIdArray:emp] ||  emp.emp_id == [conn getConn].curUser.emp_id) {
        isOldMember = true;
    }
    if (isOldMember) {
        return;
    }
    
//    if(!emp.permission.canSendMsg)
//    {
//        [PermissionUtil showAlertWhenCanNotSendMsg:emp];
//        return;
//    }
    
    if (emp.isSelected) { //不选中
        emp.isSelected=false;
    }else   //选中
    {
        if (!_isSingleSelect && self.maxSelectCount <= self.nowSelectedEmpArray.count) {
            [self showSelectMemberExceedAlert];
            return;
        }
        
        emp.isSelected=true;
    }
    [self selectByEmployee:emp.emp_id status:emp.isSelected];
    
    //        如果现在是搜索状态，那么需要刷新搜索结果view
    if (searchdispalyCtrl.isActive) {
        [searchdispalyCtrl.searchResultsTableView reloadData];
    }else{
        [orgTable reloadData];
    }
    //显示在底部
    [self bottomScrollviewShow];
    
    [self refreshSelectBtn];
}

/** 从内存里选择一个人员 */
-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus
{
    NSArray *empArray = [[conn getConn] getEmpByEmpId:emp_id];
    
    for (Emp *_emp in empArray)
    {
        _emp.isSelected = selectedStatus;
        [self updateNowSelectedEmp:_emp];
    }
    [self displayNowSelectedEmp];
}

#pragma mark 选中或反选一个emp时，修改现在选中的emp的数组
-(void)updateNowSelectedEmp:(Emp *)emp
{
    if(emp.isSelected)
    {
        bool isNowSelected = false;
        for(Emp *_emp in self.nowSelectedEmpArray)
        {
            if(_emp.emp_id == emp.emp_id)
            {
                isNowSelected = true;
                NSLog(@"%@已经选中",_emp.emp_name);
                break;
            }
        }
        
        if(!isNowSelected && ![self isEmpInOldEmpIdArray:emp])
        {
            if (self.isSingleSelect) {
                
                for (Emp *_emp in self.nowSelectedEmpArray) {
                    NSArray *empArray = [[conn getConn] getEmpByEmpId:_emp.emp_id];
                    for (Emp *_emp in empArray)
                    {
                        _emp.isSelected = false;
                    }
                }
                [LogUtil debug:[NSString stringWithFormat:@"%s 是单选，需要先删除原来的",__FUNCTION__]];
                [self.nowSelectedEmpArray removeAllObjects];
                
                for (NSArray *_array in self.itemArray) {
                    for (SettingItem *item in _array) {
                        if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                            Emp *tempEmp = (Emp *)item.dataObject;
                            if (tempEmp.emp_id == emp.emp_id) {
                                tempEmp.isSelected = true;
                            }else{
                                tempEmp.isSelected = false;
                            }
                        }
                    }
                }
            }
            [self.nowSelectedEmpArray addObject:emp];
        }
    }
    else
    {
        for (int i=0; i<[self.nowSelectedEmpArray count]; i++) {
            Emp *deleteEmp=[self.nowSelectedEmpArray objectAtIndex:i];
            if (deleteEmp.emp_id==emp.emp_id) {
                [self.nowSelectedEmpArray removeObject:deleteEmp];
            }
        }
    }
}

/** 是否是禁用的人员 */
- (BOOL)isEmpInOldEmpIdArray:(Emp *)emp{
    BOOL isExist = NO;
    for (Emp *temp in self.oldEmpIdArray) {
        if (temp.emp_id == emp.emp_id) {
            isExist = YES;
            break;
        }
    }
    return isExist;
}

/** 显示选择的人员 */
-(void)displayNowSelectedEmp
{
    NSLog(@"选中个数：%d",self.nowSelectedEmpArray.count);
    //	for(Emp * _emp in self.nowSelectedEmpArray)
    //	{
    ////		NSLog(@"%@",_emp.emp_name);
    //	}
}

/** 判断是否所有的人员都选中了 */
- (BOOL)isCurrentEmpsSelected{
    BOOL isSelected = NO;
    
    for (NSArray *_array in self.itemArray) {
        for (SettingItem *item in _array) {
            if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                
                Emp *emp = (Emp *)item.dataObject;
                if (!emp.isSelected) {
                    isSelected = NO;
                    break;
                }
                else{
                    isSelected = YES;
                }
            }
        }
    }
    
    return isSelected;
}


- (void)refreshSelectBtn{
    isSelectAll = [self isCurrentEmpsSelected];
    if (isSelectAll) {
        [self setUnSelectAllBtn:rightBtn];
    }
    else{
        [self setSelectAllBtn:rightBtn];
    }
}

//设置全选按钮
- (void)setUnSelectAllBtn:(UIButton *)rightButton
{
    [rightBtn setTitle:@"反选" forState:UIControlStateNormal];
}
//设置反选按钮
- (void)setSelectAllBtn:(UIButton *)rightButton
{
    [rightBtn setTitle:@"全选" forState:UIControlStateNormal];
}

//获取当前列表未选中人员数
- (int)getCurrentDesSelectedEmpCount{
    int deselectCount = 0;
    for (NSArray *_array in self.itemArray) {
        for (SettingItem *item in _array) {
            if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                Emp *tempEmp = (Emp*)item.dataObject;
                if (!tempEmp.isSelected) {
                    deselectCount ++;
                }
            }
        }
    }
    return deselectCount;
}


- (void)setCurrentEmpSelected:(BOOL)selected{
    for (NSArray *_array in self.itemArray) {
        for (SettingItem *item in _array) {
            if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                Emp *emp = (Emp*)item.dataObject;
                
                if (emp.emp_id != [conn getConn].curUser.emp_id) {
                    emp.isSelected = selected;
                    [self selectByEmployee:emp.emp_id status:emp.isSelected];
                }
            }
        }
    }
}


#pragma mark - 全选或取消当前员工
- (void)selectAllBtnPressed:(UIButton *)sender{
    isSelectAll = !isSelectAll;
    if (isSelectAll) {
        
        //全选
        int nowcount= [self.nowSelectedEmpArray count];
//
        int deselectCount = [self getCurrentDesSelectedEmpCount];
        if ((nowcount+deselectCount)>self.maxSelectCount){
            [self showSelectMemberExceedAlert];
            isSelectAll = NO;
            return;
        }
        [self setUnSelectAllBtn:rightBtn];
    }
    else{
        [self setSelectAllBtn:rightBtn];
    }
    
    [self setCurrentEmpSelected:isSelectAll];
    [orgTable reloadData];
    [self bottomScrollviewShow];
}

#pragma mark 提醒用户选择人数已经超过最大值
-(void)showSelectMemberExceedAlert{
    NSString *titlestr=[NSString stringWithFormat:@"最多选择%d人",self.maxSelectCount];
    [UserTipsUtil showAlert:titlestr];
}

-(NSArray *)getRootItem
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSMutableArray *_array;
    SettingItem *_item;
    
    Dept *tempDept = nil;
    
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
                _item.clickSelector = @selector(selectEmp:); //点击事件
                _item.displaySelectBtn = YES;

                if ([self isEmpInOldEmpIdArray:_emp]) {
                    _emp.canChoose = NO;
                }

                [_array addObject:_item];
            }
            
            if (commonEmpArray.count && !self.isSingleSelect) {
                rightBtn.hidden = NO;
            }else{
                rightBtn.hidden = YES;
            }
            
        }
        
        [tempArray addObject:_array];
    }

    return tempArray;
}

- (void)addBottomBar{
    //自定义底部导航栏
    float toolbarY = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - bottom_bar_height;
    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY, SCREEN_WIDTH, bottom_bar_height)];
    bottomNavibar.backgroundColor = bottom_bar_bgcolor;
    bottomNavibar.hidden = YES;
    
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    UIWindow *window = self.view.window;
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    //分割线
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, bottomNavibar.frame.size.width, 1.0)];
    lineLab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineLab.backgroundColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    [bottomNavibar addSubview:lineLab];
    [lineLab release];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.backgroundColor = bottom_button_bgcolor;
    addButton.frame = CGRectMake(SCREEN_WIDTH - bottom_button_width - bottom_button_space, (bottom_bar_height - bottom_button_height) * 0.5, bottom_button_width, bottom_button_height);
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:addButton];
    addButton.enabled=NO;
    addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [addButton setTitle:[StringUtil getLocalizableString:@"confirm"] forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:bottom_button_text_size];
    addButton.layer.cornerRadius = 3.0;
    
    bottomScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 1, SCREEN_WIDTH - addButton.frame.size.width - bottom_button_space * 2, bottom_bar_height)];
    bottomScrollview.scrollsToTop = NO;
    bottomScrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [bottomNavibar addSubview:bottomScrollview];
    bottomScrollview.pagingEnabled = NO;
    bottomScrollview.showsHorizontalScrollIndicator = YES;
    bottomScrollview.showsVerticalScrollIndicator = YES;
    [bottomScrollview release];
    
}
/** 显示选择的人员 */
-(void)bottomScrollviewShow{
    if (self.nowSelectedEmpArray.count == 0) {
        bottomNavibar.hidden = YES;
        if (searchdispalyCtrl.isActive) {
            CGRect _frame = searchdispalyCtrl.searchResultsTableView.frame;
            _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT-bottom_bar_height;
            searchdispalyCtrl.searchResultsTableView.frame = _frame;
        }else{
            int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - _searchBar.frame.size.height;
            orgTable.frame = CGRectMake(0.0, _searchBar.frame.size.height, self.view.frame.size.width, tableH);
        }
        return;
    }else{
        [self.view bringSubviewToFront:bottomNavibar];
        
        bottomNavibar.hidden = NO;
        if (searchdispalyCtrl.isActive) {
            CGRect _frame = searchdispalyCtrl.searchResultsTableView.frame;
            _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - bottom_bar_height - bottom_bar_height;
            searchdispalyCtrl.searchResultsTableView.frame = _frame;
            
            _frame = bottomNavibar.frame;
            _frame.origin.y = SCREEN_HEIGHT - STATUSBAR_HEIGHT - bottom_bar_height;
            bottomNavibar.frame = _frame;
            
        }else{
            CGRect _frame = orgTable.frame;
            _frame.size.height = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - _searchBar.frame.size.height - bottom_bar_height;
            orgTable.frame = _frame;
            
            _frame = bottomNavibar.frame;
            _frame.origin.y = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - bottom_bar_height;
            bottomNavibar.frame = _frame;
            
        }
}

    //    首先删除已有的view
    for(UIView *view in [bottomScrollview subviews])
    {
        [view removeFromSuperview];
        view = nil;
    }
    
    //    设置确定按钮
    NSMutableArray *selectArray = [NSMutableArray arrayWithArray:self.nowSelectedEmpArray];
    
    //    确定按钮
    if ([selectArray count]==0) {
        addButton.enabled=NO;
        [addButton setTitle:[StringUtil getLocalizableString:@"confirm"] forState:UIControlStateNormal];
    }else
    {
        addButton.enabled=YES;
        //    蓝光要求不显示用户自己
        int _count = (int)selectArray.count;
   
        NSString *titlestr=[NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"confirm"],_count];
        [addButton setTitle:titlestr forState:UIControlStateNormal];
    }
    
    float iconX = 0;
    
    int _index = 0;
    for (Emp *_emp in selectArray) {
        
        iconX += bottom_header_space;
        
        UIImageView *iconView = [UserDisplayUtil getUserLogoViewWithLogoHeight:bottom_header_height];
        CGRect _frame = iconView.frame;
        _frame.origin.y = (bottom_bar_height - bottom_header_height) * 0.5;
        _frame.origin.x = iconX;
        iconView.frame = _frame;
        
        iconView.userInteractionEnabled = YES;
        iconView.tag = bottom_icon_tag_base + _index;
        _index++;
        
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconbuttonAction:)]autorelease];
        [iconView addGestureRecognizer:singleTap];
        
        [UserDisplayUtil setUserLogoView:iconView andEmp:_emp];
        
        [UserDisplayUtil hideStatusView:iconView];

        [bottomScrollview addSubview:iconView];
        
        iconX = iconX + iconView.frame.size.width + bottom_header_space ;
    }
    
    bottomScrollview.contentSize = CGSizeMake(iconX, bottom_bar_height);
    if (bottomScrollview.contentSize.width > bottom_scrollview_width) {
        bottomScrollview.contentOffset = CGPointMake(bottomScrollview.contentSize.width - bottom_scrollview_width, 0);
    }
}

-(void)iconbuttonAction:(UITapGestureRecognizer *)gesture
{
    UIView *view = (UIView *)gesture.view;
    int index = (int)(view.tag - bottom_icon_tag_base);
    
    Emp *emp=[self.nowSelectedEmpArray objectAtIndex:index];
    
    
    if ([conn getConn].userId) {
        if (emp.emp_id == [conn getConn].userId.intValue)
        {
            //            如果是用户自己则不能删除
            return;
        }
    }
    
    
    NSLog(@"--删除成员－－index %d  emp %@",index,emp);
    emp.isSelected=false;
    [self selectByEmployee:emp.emp_id status:emp.isSelected];
    
    for (NSArray *_array in self.itemArray) {
        
        for (SettingItem *item in _array) {
            if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                Emp *emp1=(Emp *)item.dataObject;
                if (emp1.emp_id==emp.emp_id) {
                    emp1.isSelected=false;
                }
            }
        }
    }
    
    [orgTable reloadData];

    //    显示在底部
    [self bottomScrollviewShow];
    
    [self refreshSelectBtn];
}

//返回 按钮
-(void)backButtonPressed:(id)sender{
    [self closeCurVC];
    [[conn getConn]setAllEmpNotSelect];
}

- (void)closeCurVC{
    if (self.navigationController.viewControllers.count) {
        if ([self.navigationController.viewControllers[0] isKindOfClass:[self class]]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            if (self.chooseMemberDelegate) {
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[self.chooseMemberDelegate class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                }
            }
//            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nowSelectedEmpArray = [NSMutableArray array];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];

    self.title = @"选择联系人";// [StringUtil getLocalizableString:@"main_contacts"];
    
    BOOL displayLeftButtonImage = NO;
    if ([self.chooseMemberDelegate isKindOfClass:[MiLiaoConvListViewController class]]) {
        displayLeftButtonImage = YES;
    }
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    

    if (!self.isSingleSelect) {
        rightBtn = [UIAdapterUtil setRightButtonItemWithTitle:nil andTarget:self andSelector:@selector(selectAllBtnPressed:)];
        [self setSelectAllBtn:rightBtn];        
    }

    
    
    [self initSearchBar];
    
    int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT  - _searchBar.frame.size.height - bottom_bar_height;
    
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
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:orgTable];
    [UIAdapterUtil setExtraCellLineHidden:orgTable];
    [UIAdapterUtil setExtraCellLineHidden:searchdispalyCtrl.searchResultsTableView];
    
    [self addObserver];
    
    [self addBottomBar];
    
    NSArray *tempArray = [self getRootItem];
    self.itemArray = [NSMutableArray arrayWithArray:tempArray];
    [orgTable reloadData];

}




#pragma mark =======table view delegate===========
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return self.searchResults.count;
    }
    
    return self.itemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
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
    if(tableView == self.searchDisplayController.searchResultsTableView){

        SettingItem *_item = [self getSearchResultItemByIndexPath:indexPath];
        LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        cell.delegate = self;
        [cell configureCellWithObject:_item];
        JPLabel *nameLabel = (JPLabel*)[cell viewWithTag:emp_name_tag];
        _tableViewLineX = nameLabel.frame.origin.x;

        return cell;

    }
    else
    {
        SettingItem *_item = [self getItemByIndexPath:indexPath];
        
        LGOrgCell *cell = [[[LGOrgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        cell.delegate = self;
        [cell configureCellWithObject:_item];
        JPLabel *nameLabel = (JPLabel*)[cell viewWithTag:emp_name_tag];
        _tableViewLineX = nameLabel.frame.origin.x;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        SettingItem *_item = [self getSearchResultItemByIndexPath:indexPath];
        if (_item.clickSelector) {
            if (_item.dataObject) {
                [self performSelector:_item.clickSelector withObject:_item.dataObject];
            }else{
                [self performSelector:_item.clickSelector];
            }
        }
    }else{
        SettingItem *_item = [self getItemByIndexPath:indexPath];
        if (_item.clickSelector) {
            if (_item.dataObject) {
                [self performSelector:_item.clickSelector withObject:_item.dataObject];
            }else{
                [self performSelector:_item.clickSelector];
            }
        }
    }
}


#pragma mark ======搜索=======
//根据indexPath获取搜索结果item
- (SettingItem *)getSearchResultItemByIndexPath:(NSIndexPath *)indexPath
{
    NSArray *_array = self.searchResults[indexPath.section];
    SettingItem *_item = _array[indexPath.row];
    return _item;
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
                    _item.clickSelector = @selector(selectEmp:); //点击事件
                    _item.displaySelectBtn = YES;
                    
                    if ([self isEmpInOldEmpIdArray:_emp]) {
                        _emp.canChoose = NO;
                    }
                    
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
                    _item.displaySelectBtn = YES;
                    
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
                    _item.displaySelectBtn = YES;
                    
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
                        _item.displaySelectBtn = YES;
                        
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

    [self bottomScrollviewShow];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"%s",__FUNCTION__);
    [self bottomScrollviewShow];
}


- (void)viewWillLayoutSubviews
{
    NSLog(@"%s %@",__FUNCTION__,(searchdispalyCtrl.isActive?@"查询状态":@"正常状态"));
    [super viewWillLayoutSubviews];
    if (!searchdispalyCtrl.isActive) {
        
        int tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - _searchBar.frame.size.height - bottom_bar_height;
        if (self.nowSelectedEmpArray.count == 0) {
            tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT - _searchBar.frame.size.height;
        }
        orgTable.frame = CGRectMake(0.0, _searchBar.frame.size.height+SEARCHBAR_SPACE, self.view.frame.size.width, tableH);
    }
}


#pragma mark ======LGOrgCellProtocol=======
- (void)clickSelectButton:(LGOrgCell *)cell{
    id _id = cell.dataObject;
    if ([_id isKindOfClass:[SettingItem class]]) {
        SettingItem *_item = (SettingItem *)_id;
        if (_item.dataObject) {
            if ([_item.dataObject isKindOfClass:[Emp class]]) {
                [self selectEmp:_item.dataObject];
            }else if ([_item.dataObject isKindOfClass:[Dept class]]){
                [UserTipsUtil showAlert:@"暂时还不能选部门哦"];
            }
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

// 键盘弹出隐藏，对底部人员的显示后面处理
//-(void)keyboradWillShow:(NSNotification *)noti
//{
//    // 键盘的frame
//    CGRect keyboradF = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardH = keyboradF.size.height;
//    //    CGFloat textfieldYPlusH = self.textfield.frame.origin.y + self.textfield.frame.size.height;
//    CGFloat textfieldYPlusH = CGRectGetMaxY(bottomNavibar.frame);
//    CGFloat keyboardY = [UIApplication sharedApplication].keyWindow.frame.size.height - keyboardH;
//    if (textfieldYPlusH > keyboardY)
//    {
//        [self bottomScrollviewShow];
//        CGFloat delta = textfieldYPlusH - keyboardY;
//        // 平移动画
//        bottomNavibar.transform = CGAffineTransformMakeTranslation(0, -delta);
//    }
//}
//-(void)keyboradWillHide:(NSNotification *)noti
//{
//    // 还原成原来的位置
//    bottomNavibar.transform = CGAffineTransformIdentity;
//}
@end
