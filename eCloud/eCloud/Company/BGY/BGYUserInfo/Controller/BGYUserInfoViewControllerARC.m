//
//  BGYUserInfoViewControllerARC.m
//  eCloud
//
//  Created by Alex-L on 2017/7/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYUserInfoViewControllerARC.h"

#import "BGYUserInfoHeadCellARC.h"
#import "BGYUserInfoCellARC.h"

#import "SettingItem.h"
#import "StringUtil.h"
#import "ImageUtil.h"

#import "conn.h"

@interface BGYUserInfoViewControllerARC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *itemArray;

@end

@implementation BGYUserInfoViewControllerARC

- (NSArray *)itemArray
{
    if (_itemArray == nil)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        
        Emp *_emp = [conn getConn].curUser;
        
        SettingItem *item = nil;
        item = [[SettingItem alloc] init];
        item.itemName = @"职位";
        item.imageName = @"info_zhiwei";
        item.itemValue = @"测试职位"; //_emp.titleName;
        [mArr addObject:item];
        
        item = [[SettingItem alloc] init];
        item.itemName = @"部门";
        item.imageName = @"info_dept";
        item.itemValue = @"信管中心测试单位"; // _emp.deptName;
        [mArr addObject:item];
        
        item = [[SettingItem alloc] init];
        item.itemName = @"手机";
        item.imageName = @"info_phone";
        item.itemValue = @"1234567890"; //_emp.emp_mobile;
        [mArr addObject:item];
        
        item = [[SettingItem alloc] init];
        item.itemName = @"座机";
        item.imageName = @"info_tel";
        item.itemValue = _emp.emp_tel;
        [mArr addObject:item];
        
        item = [[SettingItem alloc] init];
        item.itemName = @"邮箱";
        item.imageName = @"info_email";
        item.itemValue = _emp.emp_mail;
        [mArr addObject:item];
        
        
        _itemArray = [mArr copy];
    }
    
    return _itemArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    tableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tableView registerNib:[UINib nibWithNibName:@"BGYUserInfoHeadCellARC" bundle:nil] forCellReuseIdentifier:@"infoheadCell"];
    [tableView registerNib:[UINib nibWithNibName:@"BGYUserInfoCellARC" bundle:nil] forCellReuseIdentifier:@"infoCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        BGYUserInfoHeadCellARC *headCell = [tableView dequeueReusableCellWithIdentifier:@"infoheadCell"];
        
        Emp *_emp = [conn getConn].curUser;
        headCell.userLogo.image = [StringUtil getImageByResName:@"more_big_logo"]; // [ImageUtil getEmpLogo:_emp];
        headCell.empName.text = _emp.emp_name;
        headCell.empCode.text = @"V_jadlwn"; //_emp.empCode;
        
        return headCell;
    }
    else
    {
        BGYUserInfoCellARC *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
        
        SettingItem *item = self.itemArray[indexPath.row];
        cell.title.text = item.itemName;
        cell.nameLabel.text = item.itemValue;
        cell.icon.image = [StringUtil getImageByResName:item.imageName];
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 25;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 160;
    }
    
    return 60;
}

@end
