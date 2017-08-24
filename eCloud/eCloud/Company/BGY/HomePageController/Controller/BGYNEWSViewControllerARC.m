//
//  NEWSViewControllerARC.m
//  eCloud
//
//  Created by Alex-L on 2017/7/13.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYNEWSViewControllerARC.h"
#import "YYTableView.h"
#import "BGYNewsCellARC.h"

static NSString *newsCellId = @"newsCellId";
@interface BGYNEWSViewControllerARC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) YYTableView *tableView;

@end

@implementation BGYNEWSViewControllerARC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[YYTableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"BGYNewsCellARC" bundle:nil] forCellReuseIdentifier:newsCellId];
}

- (void)setViewHeight:(CGFloat)viewHeight
{
    CGRect rect = self.tableView.frame;
    rect.size.height = viewHeight;
    self.tableView.frame = rect;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BGYNewsCellARC *cell = [tableView dequeueReusableCellWithIdentifier:newsCellId];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index %ld", (long)indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

@end
