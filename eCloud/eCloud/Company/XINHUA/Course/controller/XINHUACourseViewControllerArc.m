//
//  XINHUACourseViewControllerArc.m
//  eCloud
//
//  Created by Ji on 17/4/28.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUACourseViewControllerArc.h"
#import "XINHUAWebviewViewControllerArc.h"

#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"

#import "XINHUAGroupCellArc.h"

#import "XINHUAgentLstViewControllerArc.h"

@interface XINHUACourseViewControllerArc ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *courseTableView;

@end

@implementation XINHUACourseViewControllerArc
{
    NSMutableArray *_labelArray;
    NSMutableArray *_imageArray;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIAdapterUtil showTabar:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [StringUtil getAppLocalizableString:@"course"];
    
    // Do any additional setup after loading the view.
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _labelArray = [[NSMutableArray alloc] initWithObjects:[StringUtil getAppLocalizableString:@"E_commerce"], nil];
    _imageArray = [[NSMutableArray alloc] initWithObjects:@"dianshang", nil];
    
    _courseTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _courseTableView.delegate=self;
    _courseTableView.dataSource=self;
    _courseTableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    _courseTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_courseTableView];
    [UIAdapterUtil setPropertyOfTableView:_courseTableView];
    _courseTableView.tableFooterView = [[UIView alloc]init];
}

#pragma mark tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    return _labelArray.count;
 
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"courseCell";
    
    XINHUAGroupCellArc *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[XINHUAGroupCellArc alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.groupName.text = [_labelArray objectAtIndex:indexPath.row];
    cell.groupLogo.image = [StringUtil getImageByResName:[_imageArray objectAtIndex:indexPath.row]];
    
    return cell;
}

/** 每个分组上边预留的空白高度 */
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}
/** 每个分组下边预留的空白高度 */
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XINHUAWebviewViewControllerArc *agent = [[XINHUAWebviewViewControllerArc alloc]init];
    agent.urlstr = @"http://ke.ecuber.cn/login?goto=%2F";
    agent.isAutoLogin = YES;
    [self.navigationController pushViewController:agent animated:YES];

    [UIAdapterUtil hideTabBar:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
