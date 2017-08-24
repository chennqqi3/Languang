//
//  LGMSGSettingViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/5/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGMSGSettingViewControllerArc.h"
#import "eCloudDefine.h"

@interface LGMSGSettingViewControllerArc ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LGMSGSettingViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIAdapterUtil hideTabBar:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = @"消息中心通知推送";
    
    UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 50, 30)];
    [switch1 addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:switch1];
    
    switch1.on = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}

-(void)switchAction:(UISwitch *)sender
{
    if (sender.isOn)
    {
        NSLog(@"打开消息中心通知推送");
    }
    else
    {
        NSLog(@"关闭消息中心通知推送");
    }
}

@end
