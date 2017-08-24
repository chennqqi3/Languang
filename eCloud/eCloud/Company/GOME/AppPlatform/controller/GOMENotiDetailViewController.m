//
//  GOMENotiDetailViewController.m
//  eCloud
//
//  Created by Alex L on 16/12/7.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "GOMENotiDetailViewController.h"
#import "eCloudDefine.h"
#import "AppMsgModel.h"

#ifdef _GOME_FLAG_
#import "GSAMeetingMainViewController.h"
#import "GOMEAppMsgModel.h"
#endif

#import "MJRefresh.h"
#import "GOMENotificationCell.h"
#import "talkSessionUtil.h"
#import "eCloudDAO.h"
#import "APPPlatformDOA.h"
#import "OpenNotificationDefine.h"
#import "ConvNotification.h"
#import "RemindModel.h"
#import "JSONKit.h"
#import "StringUtil.h"
//
//#import "GSAMeetingMainViewController.h"
//#import "GSAEmolumentMainViewController.h"
//#import "GSASpecialMainViewController.h"
//#import "GSAPunishmentMainViewController.h"
//#import "GSAStoreMainViewController.h"
//#import "GSABusinessMainViewController.h"
//#import "GSAAwardMainViewController.h"
//#import "GSAExamineMainViewController.h"
//#import "GSAPersonalReportMainViewController.h"
//#import "GSAMyShopMainViewController.h"
//#import "GSAEvaluationMainViewController.h"
//#import "GSAShareMainViewController.h"

static NSString *cellIdentifier = @"cellIdentifier";
@interface GOMENotiDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,GOMENotificationCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *broadcastArr;

@end

@implementation GOMENotiDetailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_REMIND_NOTIFICATION object:nil];
    
    // 发出已读通知
//    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.appModel.appid],@"conv_id", nil];
//    
//    [[eCloudDAO getDatabase] sendNewConvNotification:info andCmdType:read_app_msg];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[APPPlatformDOA getDatabase]setAppMsgReadOfApp: [StringUtil getStringValue:self.appModel.appid]];
}

- (NSMutableArray *)broadcastArr
{
    if (_broadcastArr == nil)
    {
        NSArray *tempArray = [[eCloudDAO getDatabase] getBroadcastList:appNotice_broadcast withAppID:[NSString stringWithFormat:@"%d",self.appModel.appid] currentCount:0];
        
        _broadcastArr = [NSMutableArray arrayWithArray:[self getAppModelWithArr:tempArray]];
    }
    
    return _broadcastArr;
}

- (NSArray *)getAppModelWithArr:(NSArray *)tempArray
{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:tempArray.count];
    
    for (NSDictionary *dic in tempArray) {
        NSString *appMsgTitle = dic[@"asz_titile"];
        NSString *appMsgContent = dic[@"asz_message"];
        int appMsgTime = [dic[@"sendtime"]intValue];
        NSString *msgID = dic[@"msg_id"];
        
        AppMsgModel *_model = [[AppMsgModel alloc]init];
        _model.appMsgTitle = appMsgTitle;
        _model.appMsgContent = appMsgContent;
        _model.appMsgTime = appMsgTime;
        _model.msgID = msgID;
        
        NSDictionary *tempDic = [appMsgContent objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        if (tempDic) {
            GOMEAppMsgModel *gomeAppMsgModel = [[GOMEAppMsgModel alloc]init];
            gomeAppMsgModel.msgContent = tempDic[@"MsgContent"];
            gomeAppMsgModel.extendMsg = tempDic[@"Ext"];
            _model.gomeAppMsgModel = gomeAppMsgModel;
        }
        
        
        [mArray addObject:_model];
    }
    
    return mArray;
}

- (void)loadMoreData
{
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData)
        return;
    
    
    NSArray *tempArray = [[eCloudDAO getDatabase] getBroadcastList:appNotice_broadcast withAppID:[NSString stringWithFormat:@"%d",self.appModel.appid] currentCount:self.broadcastArr.count];
    if (tempArray.count!=0)
    {
        // tempArray里装的是字典，要转成模型
        [self.broadcastArr addObjectsFromArray:[self getAppModelWithArr:tempArray]];
        [self.tableView reloadData];
        
        
        // 如果不等于10说明没有更多数据了
        if (tempArray.count != num_convrecord)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.tableView.mj_footer.state =  MJRefreshStateNoMoreData;
            });
            
            return;
        }
        
        
        //结束尾部刷新
        [self.tableView.mj_footer endRefreshing];
    }
    else
    {
        self.tableView.mj_footer.state =  MJRefreshStateNoMoreData;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.appModel.appname;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-17) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"GOMENotificationCell" bundle:nil]  forCellReuseIdentifier:cellIdentifier];
    
    // 监听新通知
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewRemind:) name:NEW_REMIND_NOTIFICATION object:nil];
}

- (void)processNewRemind:(NSNotification *)noti
{
    RemindModel *model = noti.userInfo[NEW_REMIND_KEY];
    if (model.fromSystem.intValue == self.appModel.appid)
    {
        NSDictionary *dic = [[eCloudDAO getDatabase] getRemindDicByMsgId:model.remindMsgId];
        NSString *appMsgTitle = dic[@"asz_titile"];
        NSString *appMsgContent = dic[@"asz_message"];
        int appMsgTime = [dic[@"sendtime"]intValue];
        NSString *msgID = dic[@"msg_id"];
        
        AppMsgModel *_model = [[AppMsgModel alloc]init];
        _model.appMsgTitle = appMsgTitle;
        _model.appMsgContent = appMsgContent;
        _model.appMsgTime = appMsgTime;
        _model.msgID = msgID;
        
        NSDictionary *tempDic = [appMsgContent objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        if (tempDic) {
            GOMEAppMsgModel *gomeAppMsgModel = [[GOMEAppMsgModel alloc]init];
            gomeAppMsgModel.msgContent = tempDic[@"MsgContent"];
            gomeAppMsgModel.extendMsg = tempDic[@"Ext"];
            _model.gomeAppMsgModel = gomeAppMsgModel;
        }
        
        [self.broadcastArr insertObject:_model atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - <GOMENotificationCellDelegate>
- (void)deleteWithIndex:(NSInteger)index
{
    NSLog(@"delete index %ld",(long)index);
    
    // 删除数据库中的数据 并发出删除通知
    AppMsgModel *model = self.broadcastArr[index];
    [[APPPlatformDOA getDatabase] removeOneAppMsgByMsgId:model.msgID];
    
    [self.broadcastArr removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self performSelector:@selector(reloadTableViewData) withObject:nil afterDelay:0.5];
}

- (void)viewDetail:(GOMENotificationCell *)curCell
{
#ifdef _GOME_FLAG_
    
    UIViewController *ctl = [[NSClassFromString(self.appModel.apppage1) alloc] init];
    if (ctl)
    {
        //        如果是会议，那么需要把ext的内容传给会议程序
        if ([ctl isKindOfClass:[GSAMeetingMainViewController class]]) {
            
            AppMsgModel *_model = curCell.appMsgModel;
            
            ((GSAMeetingMainViewController *)ctl).messageExt =  _model.gomeAppMsgModel.extendMsg;
        }
        [self.navigationController pushViewController:ctl animated:YES];
    }
    
#endif
    
}

- (void)reloadTableViewData
{
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.broadcastArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GOMENotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.deleteDelegate = self;
    cell.tag = indexPath.row;
    AppMsgModel *_model = self.broadcastArr[indexPath.row];
    cell.appMsgModel = _model;
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 根据文字多少计算cell的高度
    NSMutableParagraphStyle *paragphStyle=[[NSMutableParagraphStyle alloc]init];
    paragphStyle.lineSpacing=0;//设置行距为0
    paragphStyle.firstLineHeadIndent=0.0;
    paragphStyle.hyphenationFactor=0.0;
    paragphStyle.paragraphSpacingBefore=0.0;
    NSDictionary *attributeDic1=@{
                                 NSFontAttributeName:[UIFont systemFontOfSize:17], NSParagraphStyleAttributeName:paragphStyle, NSKernAttributeName:@1.0f
                                 };
    AppMsgModel *_model = self.broadcastArr[indexPath.row];
    
    CGSize size1 = CGSizeMake(0, 0);
    if (_model.gomeAppMsgModel.msgContent)
    {
        size1 = [_model.gomeAppMsgModel.msgContent boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-50, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic1 context:nil].size;
    }
    
    
    NSDictionary *attributeDic2=@{
                                  NSFontAttributeName:[UIFont systemFontOfSize:21], NSParagraphStyleAttributeName:paragphStyle, NSKernAttributeName:@1.0f
                                  };
    CGSize size2=[_model.appMsgTitle boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-50, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic2 context:nil].size;
    NSLog(@"height1 %f height2 %f", size1.height, size2.height);

    return 170 + size1.height + size2.height;
}

@end
