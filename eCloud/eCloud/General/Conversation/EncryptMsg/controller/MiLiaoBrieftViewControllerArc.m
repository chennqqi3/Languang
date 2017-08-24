//
//  ViewController.m
//  miliao
//
//  Created by Alex-L on 2017/6/14.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import "MiLiaoBrieftViewControllerArc.h"
#import "UIAdapterUtil.h"

@interface MiLiaoBrieftViewControllerArc ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation MiLiaoBrieftViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"什么是密聊";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:(UITableViewStylePlain)];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width-40, 360)];
    label.numberOfLines = 0;
    label.textColor = [UIColor colorWithWhite:0 alpha:1];
    label.text = @"密聊是用户一对一进行私密聊天，具备如下属性：\n1、消息在对方点击查看消息内容之后30秒自动销毁，在任何端不留痕迹；\n2、消息禁止拷贝和转发；\n3、消息通知不透出内容；\n4、密聊头像名字打码防截屏；";
    label.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    [label sizeToFit];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 360;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

//返回 按钮
-(void) backButtonPressed:(id) sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
