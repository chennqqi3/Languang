//
//  RedpacketBaseTableViewController.m
//  RedpacketDemo
//
//  Created by Mr.Yang on 2016/11/22.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketBaseTableViewController.h"
#import "RedpacketConfig.h"
#import "RedpacketUser.h"
#import "RedpacketDefines.h"
#import "RedpacketMessageModel.h"
#import "RedpacketOpenConst.h"

static NSString *kRedpacketsSaveKey     = @"redpacketSaveKey";
static NSString *kRedpacketGroupSaveKey = @"redpacketGroupSaveKey";


@implementation RedpacketBaseTableViewController

+ (instancetype)controllerWithControllerType:(BOOL)isGroup
{
    RedpacketBaseTableViewController *controller = [[[self class] alloc] initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    controller.isGroup = isGroup;
    
    return controller;
}

- (void)dealloc
{
    if (_mutDatas.count) {
        NSString *key = _isGroup ? kRedpacketGroupSaveKey   : kRedpacketsSaveKey;
        [[NSUserDefaults standardUserDefaults] setValue:_mutDatas forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.talkTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.talkTableView.delegate = self;
    self.talkTableView.dataSource = self;
    
    NSString *key = _isGroup ? kRedpacketGroupSaveKey   : kRedpacketsSaveKey;
    
    _mutDatas = [[[NSUserDefaults standardUserDefaults] valueForKey:key] mutableCopy];
    if (!_mutDatas) {
        _mutDatas = [NSMutableArray array];
    }
    
    UIBarButtonItem *changeUserItem = [[UIBarButtonItem alloc] initWithTitle:@"切换用户"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(userChangeItemClick)];
    self.navigationItem.rightBarButtonItem = changeUserItem;
}

/** 发红包页面 */
- (void)presentRedpacketViewController:(RPRedpacketControllerType)controllerType
{
    [self presentRedpacketViewController:controllerType
                isSupportMemberRedpacket:NO];
}

 /** 发红包页面（支持定向红包） */
- (void)presentRedpacketViewController:(RPRedpacketControllerType)controllerType
              isSupportMemberRedpacket:(BOOL)isSupport
{
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    
    NSInteger groupCount = 0;
    if (_isGroup) {
        
        //  当前群会话ID
        userInfo.userId = @"#ConveritionID#";
        groupCount = [RedpacketUser currentUser].users.count;
        
    }else {
        
        redPacketUserInfo *talkingUser = [RedpacketUser currentUser].talkingUserInfo;
        userInfo.userId = talkingUser.userId;
        userInfo.userAvatar = talkingUser.userAvatarURL;
        userInfo.userNickname = talkingUser.userNickName;
        
    }
    
    __weak typeof(self) weakSelf = self;
    /** 发红包成功*/
    RedpacketSendBlock sendSuccessBlock = ^(RedpacketMessageModel *model) {
        
        NSDictionary *redpacket = @{@"1": model.redpacketMessageModelToDic};    //  1代表红包消息
        [weakSelf.mutDatas addObject:redpacket];
        [weakSelf.talkTableView reloadData];
        
    };

     /** 定向红包获取群成员列表, 如果不需要指定接收人，可以传nil */
    RedpacketMemberListBlock memeberListBlock = nil;
    if(controllerType == RPRedpacketControllerTypeGroup && isSupport) {
    
        memeberListBlock = ^(RedpacketMemberListFetchBlock completionHandle) {
          
            NSMutableArray <RedpacketUserInfo *> *groupInfos = [NSMutableArray array];
            for (redPacketUserInfo *userInfo in [RedpacketUser currentUser].users) {
                
                RedpacketUserInfo *user = [RedpacketUserInfo new];
                user.userId = userInfo.userId;
                user.userNickname = userInfo.userNickName;
                user.userAvatar = userInfo.userAvatarURL;
                [groupInfos addObject:user];
            }
            
            completionHandle(groupInfos);
        };
    }
    
    [RedpacketViewControl presentRedpacketViewController:controllerType
                                         fromeController:weakSelf
                                        groupMemberCount:groupCount
                                   withRedpacketReceiver:userInfo
                                         andSuccessBlock:sendSuccessBlock
                           withFetchGroupMemberListBlock:memeberListBlock
                             andGenerateRedpacketIDBlock:nil];

}

#pragma mark - Redpacket End

- (void)userChangeItemClick
{
    //  测试目的：切换只在User1和User2之间切换
    [[RedpacketUser currentUser] changeUserBetweenUser1AndUser2];
    
    self.title = [RedpacketUser currentUser].userInfo.userNickName;
    
    [self.talkTableView reloadData];
}

#pragma mark -
#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 1;
    if (_mutDatas.count) {
        count = _mutDatas.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mutDatas.count == 0) {
        UITableViewCell *noneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        noneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        noneCell.textLabel.text = @"老板，请降下红包雨";
        
        return noneCell;
    }
    
    NSDictionary *dict = [_mutDatas objectAtIndex:indexPath.row];
    
    return [[RedpacketConfig sharedConfig] cellForRedpacketMessageDict:dict];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mutDatas.count == 0) {
        return 30.0f;
    }
    
    NSDictionary *dict = [_mutDatas objectAtIndex:indexPath.row];
    return [[RedpacketConfig sharedConfig] heightForRedpacketMessageDict:dict];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mutDatas.count == 0) return;
    
    NSDictionary *dict = [_mutDatas objectAtIndex:indexPath.row];
    
    NSDictionary *redpacketDic = [dict valueForKey:@"1"];
    if (redpacketDic) {
        
        [self redpacketTouched:redpacketDic];
        
    }else {
        return;
    }
    
}

/** 抢红包 */
- (void)redpacketTouched:(NSDictionary *)redpacketDic
{
    RedpacketMessageModel *model = [RedpacketMessageModel redpacketMessageModelWithDic:redpacketDic];
    
    __weak typeof(self) weakSelf = self;
    [RedpacketViewControl redpacketTouchedWithMessageModel:model
                                        fromViewController:self
                                        redpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
        
        /** 抢红包成功, 转账成功的回调*/
        NSDictionary *redpacket = @{@"2": messageModel.redpacketMessageModelToDic};    //  2代表红包被抢的消息
        [weakSelf.mutDatas addObject:redpacket];
        [weakSelf.talkTableView reloadData];
        
    } advertisementAction:nil];
}

@end
