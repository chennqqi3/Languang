//
//  LGInvoiceControllerARC.m
//  eCloud
//
//  Created by Ji on 17/7/11.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGInvoiceControllerARC.h"
#import "SettingItem.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "LGInvoiceListCellARC.h"
#import "LGInvoiceBeginControllerARC.h"
#import "LGInvoiceListControllerARC.h"
#import "LGAddInvoiceControllerARC.h"
#import "UserDefaults.h"

@interface LGInvoiceControllerARC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,invoiceListDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation LGInvoiceControllerARC

- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        
        SettingItem *_item = nil;
        
        
        NSMutableArray *arr1 = [NSMutableArray array];
        //    登录用户资料
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"开票信息"];
        _item.imageName = @"kaipiao.png";
        _item.clickSelector = @selector(openInvoiceDetails);
        [arr1 addObject:_item];
        
        
        [mArr addObject:arr1];

        _dataArray = [mArr copy];
    }
    
    return _dataArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [UIAdapterUtil showTabar:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [StringUtil getLocalizableString:@"me_common"];
    
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
#ifdef _LANGUANG_FLAG_
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
  
#endif
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LGInvoiceListCellARC *cell = [[LGInvoiceListCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSArray *arr = self.dataArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    cell.titleLabel.text = item.itemName ? item.itemName : @"";
    cell.icon.image = [StringUtil getImageByResName:item.imageName];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = self.dataArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    
    [self performSelector:item.clickSelector withObject:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)openInvoiceDetails{
    
    NSMutableArray *arr =  [UserDefaults getLGCommonMsg];
    UIViewController *begin;
    if (arr.count) {
        
        begin = [[LGInvoiceListControllerARC alloc]init];
        
    }else{
       
        begin = [[LGInvoiceBeginControllerARC alloc]init];
    }
    
    
    [self.navigationController pushViewController:begin animated:YES];
    
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    _dataArray = nil;
  
}

- (void)returnString:(NSString *)string{
    
    if ([string isEqualToString:@"save"]) {
        
        LGInvoiceListControllerARC *list = [[LGInvoiceListControllerARC alloc]init];
        [self.navigationController pushViewController:list animated:YES];
    }
    
}
@end
