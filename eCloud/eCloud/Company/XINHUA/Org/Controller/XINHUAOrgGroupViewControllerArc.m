//
//  XINHUAOrgGroupViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAOrgGroupViewControllerArc.h"
#import "talkSessionViewController.h"

#import "UIAdapterUtil.h"
#import "UserDisplayUtil.h"

#import "Conversation.h"

#import "eCloudDefine.h"

#import "eCloudDAO.h"

#import "XINHUAGroupCellArc.h"

static NSString *orgGroupCellID = @"xinhuaOrgGroupCellID";
@interface XINHUAOrgGroupViewControllerArc ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation XINHUAOrgGroupViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.groupTitle;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[XINHUAGroupCellArc class] forCellReuseIdentifier:orgGroupCellID];
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
    XINHUAGroupCellArc *cell = [tableView dequeueReusableCellWithIdentifier:orgGroupCellID];
    
    Conversation *conv = self.dataArray[indexPath.row];
    cell.groupLogo.image = [UserDisplayUtil getImageWithConv:conv];
    cell.groupName.text = conv.getConvTitle;
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Conversation *conv = self.dataArray[indexPath.row];
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    
    talkSession.talkType = mutiableType;
    talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
    talkSession.convId = conv.conv_id;
    talkSession.needUpdateTag=1;
    talkSession.convEmps =[_ecloud getAllConvEmpBy:conv.conv_id];
    talkSession.last_msg_id=conv.last_msg_id;
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(selectGroupFinish)])
    {
        [_delegate selectGroupFinish];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
}

@end
