//
//  GOMEAddAppViewController.m
//  eCloud
//
//  Created by Alex L on 17/2/10.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "GOMEAddAppViewController.h"
#import "GOMEAddAppCell.h"
#import "LogUtil.h"
#import "APPPlatformDOA.h"
#import "APPUtil.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

static NSString *addCellIdentifier = @"addCellIdentifier";
@interface GOMEAddAppViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *appDataArray;

@end

@implementation GOMEAddAppViewController

- (NSMutableArray *)appDataArray
{
    if (_appDataArray == nil)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        NSArray *array = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
        for (NSArray *arr1 in array)
        {
            for (APPListModel *model in arr1)
            {
                // 没有有显示在工作界面的才加到数组里
                UIViewController *ctl = [[NSClassFromString(model.apppage1) alloc] init];
                if (ctl != nil)
                {
                    [mArr addObject:model];
                }
            }
        }
        
        _appDataArray = [mArr copy];
        
    }
    
    return _appDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加应用";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-12) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"GOMEAddAppCell" bundle:nil] forCellReuseIdentifier:addCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GOMEAddAppCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
    
    cell.model = self.appDataArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

@end
