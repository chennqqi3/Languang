//
//  LGInvoiceListControllerARC.m
//  eCloud
//
//  Created by Ji on 17/7/12.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGInvoiceListControllerARC.h"
#import "SettingItem.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "LGInvoiceMsgCellARC.h"
#import "StringUtil.h"
#import "UserDefaults.h"
#import "LGAddInvoiceControllerARC.h"
#import "LookOverPhotoViewController.h"
#import "SDImageCache.h"
#import "LGInvoiceDetailsControllerARC.h"
#import "PSMsgDspUtil.h"
@interface LGInvoiceListControllerARC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,assign) float cellheight;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LGInvoiceListControllerARC

- (NSMutableArray *)dataArray
{
//    if (_dataArray == nil)
//    {
        _dataArray = [NSMutableArray array];
        
        NSMutableArray *array = [UserDefaults getLGCommonMsg];
  
        for (NSArray *arr in array) {
            
            [_dataArray addObject:arr];
        }

//        NSMutableArray *mArr = [NSMutableArray array];
//        
//        SettingItem *_item = nil;
//        NSMutableArray *arr1 = [NSMutableArray array];
//        
//        _item = [[SettingItem alloc]init];
//        _item.itemName = @"名称";
//        _item.itemValue = dict[_item.itemName];
//        [arr1 addObject:_item];
//        
//        _item = [[SettingItem alloc]init];
//        _item.itemName = @"纳税人识别号";
//        _item.itemValue = dict[_item.itemName];
//        [arr1 addObject:_item];
//        
//        _item = [[SettingItem alloc]init];
//        _item.itemName = @"公司地址";
//        _item.itemValue = dict[_item.itemName];
//        [arr1 addObject:_item];
//        
//        _item = [[SettingItem alloc]init];
//        _item.itemName = @"公司电话";
//        _item.itemValue = dict[_item.itemName];
//        [arr1 addObject:_item];
//        
//        _item = [[SettingItem alloc]init];
//        _item.itemName = @"开户银行名称";
//        _item.itemValue = dict[_item.itemName];
//        [arr1 addObject:_item];
//        
//        _item = [[SettingItem alloc]init];
//        _item.itemName = @"开户银行账号";
//        _item.itemValue = dict[_item.itemName];
//        [arr1 addObject:_item];
//        
//        _item = [[SettingItem alloc]init];
//        _item.itemName = @"开票照片";
//        _item.itemValue = dict[_item.itemName];
//        [arr1 addObject:_item];
//        
//        [mArr addObject:arr1];
//        
//        _dataArray = [mArr copy];
    //}
    
    return _dataArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _cellheight = 60;
    [_tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"开票信息";
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = [self customHeaderView];
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    [UIAdapterUtil removeLeftSpaceOfTableViewCellSeperateLine:self.tableView];
    
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
    static NSString *CellIdentifier = @"Cell";
    LGInvoiceMsgCellARC *cell = [[LGInvoiceMsgCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[LGInvoiceMsgCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *arr = self.dataArray[indexPath.section];
    NSString *string = arr[indexPath.row];
    NSArray *array = [string componentsSeparatedByString:@"="];
    if (array.count == 2) {
        if (indexPath.row == 6) {
            
            cell.valueLabel.hidden = YES;
            cell.invoiceImage.hidden = NO;
            cell.nameLabel.text = array[1] ? array[1] : @"";
            cell.invoiceImage.image =  [UIImage imageWithData:[NSData dataWithContentsOfFile:array[0]]];//[UIImage imageWithContentsOfFile:array[0]];
            if (cell.invoiceImage.image) {
                _cellheight = 130;
                cell.invoiceImage.frame = CGRectMake(120, 5, 90, 120);
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
                tap.numberOfTouchesRequired = 1;
                tap.delegate = self;
                [cell.invoiceImage addGestureRecognizer:tap];
            }
            
        }else{
        
            cell.nameLabel.text = array[1] ? array[1] : @"";
            cell.valueLabel.text = array[0] ? array[0] : @"";
            
        }
        cell.nameLabel.textColor = [UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:1];
        cell.valueLabel.textColor = [UIColor blackColor];

    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    tap.numberOfTouchesRequired = 1;
    tap.delegate = self;
    [cell addGestureRecognizer:tap];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    [UIAdapterUtil customCellBackground:tableView andCell:cell andIndexPath:indexPath];
 
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSArray *arr = self.dataArray[indexPath.section];
//    SettingItem *item = arr[indexPath.row];
    //    [self performSelector:item.clickSelector withObject:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 6) {
        
        return _cellheight ? _cellheight : 60;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 60 , 50)];
//    tipLabel.text = @"蓝光地产金融集团";
    NSArray *arr = self.dataArray[section];
    NSString *string = arr[0];
    NSArray *array = [string componentsSeparatedByString:@"="];
    tipLabel.text = array[0];
    
    [tipLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [header addSubview:tipLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREEN_WIDTH - 40, 12.5, 25, 25);
    [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[StringUtil getImageByResName:@"delete_invoice.png"] forState:UIControlStateNormal];
    button.tag = section;
    [header addSubview:button];
    
    return header;
}

- (UIView *)customHeaderView{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 10, SCREEN_WIDTH - 40, 40  );
    [button addTarget:self action:@selector(increaseAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[StringUtil getImageByResName:@"jia_invoice.png"] forState:UIControlStateNormal];
    [button setTitle:@"新增开票信息" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize: 15];
    [button setTitleColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1]forState:UIControlStateNormal];
    [button.layer setBorderColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1].CGColor];
    button.backgroundColor = [UIColor clearColor];
    [button.layer setBorderWidth:1];
    [button.layer setMasksToBounds:YES];
    button.layer.cornerRadius = 3;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [view addSubview:button];
    
    return view;
}
- (void)increaseAction:(id)sender{
    
    LGAddInvoiceControllerARC *add = [[LGAddInvoiceControllerARC alloc]init];
    [self.navigationController pushViewController:add animated:YES];
}
-(void)deleteAction:(UIButton *)sender
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[UserDefaults getLGCommonMsg]];
    [array removeObjectAtIndex:sender.tag];
    
    [UserDefaults setLGCommonMsg:array];
    _dataArray = nil;
    [self.tableView reloadData];
}

- (void)cellTap:(UITapGestureRecognizer*)tap{

    CGPoint point = [tap locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.dataArray[indexPath.section]];
    LGInvoiceDetailsControllerARC *detalis = [[LGInvoiceDetailsControllerARC alloc]init];
    detalis.dataArray = arr;
    detalis.section = (int )indexPath.section;
    
    [self.navigationController pushViewController:detalis animated:YES];
    
}
-(void)actionTap:(UITapGestureRecognizer*)tap{

    CGPoint point = [tap locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    LGInvoiceMsgCellARC *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    LookOverPhotoViewController *viewCtl = [[LookOverPhotoViewController alloc] initWithImage:cell.invoiceImage.image];
    viewCtl.view.backgroundColor = [UIColor lightGrayColor];
    viewCtl.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:viewCtl animated:YES];

}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
