//
//  BGYMyTimelineViewControllerARC.m
//  eCloud
//
//  Created by Alex-L on 2017/7/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYMyTimelineViewControllerARC.h"

#import "BGYMyTimelineCellARC.h"

#import "BGYTimelineModelARC.h"

#import "UIAdapterUtil.h"

static NSString *myTimelineCellID = @"myTimelineCellID";
@interface BGYMyTimelineViewControllerARC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation BGYMyTimelineViewControllerARC

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
        
        BGYTimelineModelARC *model = nil;
        model = [[BGYTimelineModelARC alloc] init];
        model.time = @"067月";
        model.contentStr = @"但是不久之前却传来一个消息，据说美国制造的超级高铁开始测试了，时速最高可超过1200公里，那可是比飞机还要足足快了两倍啊！";
        [_dataArray addObject:model];
        
        model = [[BGYTimelineModelARC alloc] init];
        model.time = @"077月";
        model.contentStr = @"但是不久之前却传来一个消息，据说美国制造的超级高铁开始测试了，时速最高可超过1200公里，那可是比飞机还要足足快了两倍啊！";
        [_dataArray addObject:model];
        
        
//        model = [[BGYTimelineModelARC alloc] init];
//        model.time = @"087月";
//        NSString *utlStr = @"http://ww3.sinaimg.cn/thumbnail/6262423agw1evvyu96j6tj20oz18g0uw.jpg";
//        model.images = @[utlStr, utlStr, utlStr];
//        [_dataArray addObject:model];
//        
//        
//        model = [[BGYTimelineModelARC alloc] init];
//        model.time = @"087月";
//        model.images = @[utlStr, ];
//        [_dataArray addObject:model];
//        
//        
//        model = [[BGYTimelineModelARC alloc] init];
//        model.time = @"087月";
//        model.images = @[utlStr, utlStr, utlStr, utlStr];
//        [_dataArray addObject:model];
    }
    
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的主页";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // 注册cell
    [tableView registerClass:[BGYMyTimelineCellARC class] forCellReuseIdentifier:myTimelineCellID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BGYMyTimelineCellARC *cell = [tableView dequeueReusableCellWithIdentifier:myTimelineCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

@end
