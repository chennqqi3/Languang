//
//  LGAppMsgViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/6/13.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGAppMsgViewControllerARC.h"
#import "eCloudDefine.h"

#import "LANGUANGAppMsgCellARC.h"
#import "LANGUANGAppMsgModelARC.h"
#import "eCloudDAO.h"
#import "ConvNotification.h"
#import "RemindModel.h"
#import "StringUtil.h"
#import "ConvRecord.h"
#import "Conversation.h"
#import "LGMettingDetailViewControllerArc.h"
#import "LANGUANGAppMsgCellARCDelegate.h"
#import "NewMsgNotice.h"
#import "PSBackButtonUtil.h"
#import "talkSessionViewController.h"
#import "ReceiptMsgUtil.h"
#import "MJRefresh.h"
#import "ServerConfig.h"
#import "LGMettingTipCellARC.h"


static NSString *cellIdentifier = @"cellIdentifier";

@interface LGAppMsgViewControllerARC ()<UITableViewDelegate, UITableViewDataSource, LANGUANGAppMsgCellARCDelegate>

@property (nonatomic, strong) UITableView *tableView;
/**  数据源  */
@property (nonatomic, strong) NSMutableArray *appMsgModelArr;
/**  是否是查看详情操作  */
@property (nonatomic,assign) BOOL isGotoDetail;

@property (nonatomic, assign) CGFloat delta;//先定义一个delta保存后面的差值

@end

@implementation LGAppMsgViewControllerARC
{
    //	会话的总记录个数
    int totalCount;
    //	已经加载的记录个数
    NSInteger loadCount;
    //	查询会话时用到的参数
    int limit;
    int offset;
    
}

- (NSMutableArray *)appMsgModelArr
{
    if (_appMsgModelArr == nil)
    {
        _appMsgModelArr = [NSMutableArray array];
        
        totalCount = [[talkSessionViewController getTalkSession] getConvRecordCountBy:self.conv.conv_id];
        if(totalCount > num_convrecord)
        {
            eCloudDAO *_ecloud = [eCloudDAO getDatabase];
            NSDictionary *dic = [_ecloud getNewPinMsgs:self.conv.conv_id];
            int unreadMsgCount = [dic[@"unread_msg_count"]intValue];
            if (unreadMsgCount > num_convrecord) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 新消息条数 大于 10条，需要取出所有的新消息",__FUNCTION__]];
                limit = unreadMsgCount;
            }else{
                limit = num_convrecord;
            }
            offset = totalCount - limit;
        }
        else {
            limit = totalCount;
            offset = 0;
        }
        NSArray *recordArr= [[eCloudDAO getDatabase] getConvRecordBy:self.conv.conv_id andLimit:limit andOffset:offset];
        
        for (ConvRecord *record in recordArr) {
            LANGUANGAppMsgModelARC *appMsgModel = [self getConvRecord:record];
            
            [_appMsgModelArr addObject:appMsgModel];
            
            // 将消息置为已读
            //            [[eCloudDAO getDatabase] updateReadStatusByMsgId:[NSString stringWithFormat:@"%d",record.msgId] sendRead:0];
        }
        loadCount = _appMsgModelArr.count;
        if (_appMsgModelArr && _appMsgModelArr.count > 0) {
            LANGUANGAppMsgModelARC *appMsgModel = _appMsgModelArr[0];
            
        }
        
    }
    
    //全部消息设置为已读
    [[eCloudDAO getDatabase] updateTextMessageToReadState:self.conv.conv_id];
    
    return _appMsgModelArr;
}


- (LANGUANGAppMsgModelARC *)getConvRecord:(ConvRecord *)record{
    NSData *bodyData = [record.msg_body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *appMsgDic = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
    
    LANGUANGAppMsgModelARC *appMsgModel = [LANGUANGAppMsgModelARC appMsgModelWithDic:appMsgDic];
    appMsgModel.msgtime = record.msg_time;
//    
//    //    会议消息
//    if (appMsgModel.confid.length) {
//        //appMsgModel.location = @"第三方的士大夫撒旦撒旦顺丰到付胜多负少水电费水电费的水电费收水电费水电费是范德萨的冯绍峰的";
//        appMsgModel.apptype = app_conf_flag;
//    }
    
    return appMsgModel;
}

- (void)viewWillAppear:(BOOL)animated{
    [UIAdapterUtil hideTabBar:self];
}
- (void)viewDidDisappear:(BOOL)animated{
//    if (!self.isGotoDetail) {
//        [UIAdapterUtil showTabar:self];
//    }else{
//        self.isGotoDetail = NO;
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.conv.conv_title;
    
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT ) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"LANGUANGAppMsgCellARC" bundle:nil]  forCellReuseIdentifier:cellIdentifier];

    // 监听新通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewRemind:) name:CONVERSATION_NOTIFICATION object:nil];
    
    __weak typeof (self) weakSelf = self;
    
    //创建下拉刷新
    MJRefreshNormalHeader* header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf performSelector:@selector(headerRefresh)withObject:nil afterDelay:1.0f];
        
    }];
    //隐藏文字
    header.stateLabel.hidden = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    self.tableView.mj_header= header;
    
    
    // 滑动到最后
    [self scrollToEnd];
}

#pragma mark - 下拉刷新
- (void)headerRefresh{
    
    if(totalCount < num_convrecord){
        
        [self endRefresh];
        
        return;
    }else{
        
        if(totalCount > (loadCount + num_convrecord)){
            
            limit = num_convrecord;
            offset = totalCount - (loadCount + num_convrecord);
        }else        {
            limit =totalCount - loadCount;
            offset = 0;
        }
        
        NSArray *recordArr= [[eCloudDAO getDatabase] getConvRecordBy:self.conv.conv_id andLimit:limit andOffset:offset];
        
        int count=[recordArr count];
        
        for (int i=count-1; i>=0; i--)
        {
            ConvRecord *record = recordArr[i];
            LANGUANGAppMsgModelARC *appMsgModel = [self getConvRecord:record];
            [_appMsgModelArr insertObject:appMsgModel atIndex:0];
        }
        loadCount = _appMsgModelArr.count;
        [self endRefresh];
        
        float oldh = self.tableView.contentSize.height;
        
        [self.tableView reloadData];
        
        float newh=self.tableView.contentSize.height;
        self.tableView.contentOffset=CGPointMake(0, newh-oldh-20);
    }
    
}
#pragma mark - 结束下拉刷新和上拉加载
- (void)endRefresh{
    
    [self.tableView.mj_header endRefreshing];
    
}


- (void)processNewRemind:(NSNotification *)noti
{
    eCloudNotification	*cmd =	(eCloudNotification *)[noti object];
    switch (cmd.cmdId)
    {
        case rev_msg:
        {
            NSDictionary *_userInfo = noti.userInfo;
            if (_userInfo){
                NewMsgNotice *_notice = [_userInfo valueForKey:@"msg_notice"];
                if (_notice){
                    if(_notice.msgType == normal_new_msg_type){
                        NSString* convId = _notice.convId;
                        if([convId isEqualToString:self.conv.conv_id]){
                            NSString *msgId = _notice.msgId;
                            ConvRecord *convRecord = [[eCloudDAO getDatabase] getConvRecordByMsgId:msgId];
                            if(convRecord){
                                // 将消息添加到数据源的最后
                                LANGUANGAppMsgModelARC *appMsgModel = [self getConvRecord:convRecord];
                                
                                [self.appMsgModelArr addObject:appMsgModel];
                                
                                // 滑动到最后
                                [self scrollToEnd];
                                
                                // 将消息置为已读
                                [[eCloudDAO getDatabase] updateReadStatusByMsgId:[NSString stringWithFormat:@"%d",convRecord.msgId] sendRead:0];
                                
                            }
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - <TAIHEAppMsgCellDelegate>
//- (void)viewDetail:(LANGUANGAppMsgCellARC *)curCell
//{
//    LANGUANGAppMsgModelARC *msgModel = curCell.LGAppMsgModel;
//    self.isGotoDetail = YES;
//    LGMettingDetailViewControllerArc *metting=[[LGMettingDetailViewControllerArc alloc]init];
//    metting.idNum = msgModel.idNum;
//    [self.navigationController pushViewController:metting animated:YES];
//}

//- (void)viewDetailToTip:(LGMettingTipCellARC *)curCell
//{
//    LANGUANGAppMsgModelARC *msgModel = curCell.LGAppMsgModel;
//    self.isGotoDetail = YES;
//    LGMettingDetailViewControllerArc *metting=[[LGMettingDetailViewControllerArc alloc]init];
//    metting.idNum = msgModel.idNum;
//    [self.navigationController pushViewController:metting animated:YES];
//}
- (void)reloadTableViewData
{
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appMsgModelArr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LANGUANGAppMsgModelARC *model = self.appMsgModelArr[indexPath.row];
    LGMettingDetailViewControllerArc *metting=[[LGMettingDetailViewControllerArc alloc]init];
    metting.idNum = model.idNum;
    metting.type = model.importance;
    [self.navigationController pushViewController:metting animated:YES];
//    LANGUANGAppMsgCellARC *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    [self viewDetail:cell];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    LANGUANGAppMsgModelARC *model = self.appMsgModelArr[indexPath.row];

    if ([model.meetingMsgType isEqualToString:@"5"] || [model.meetingMsgType isEqualToString:@"2"]) {
        
        
        LGMettingTipCellARC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[LGMettingTipCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell configCellWithDataModel:model];
        cell.LGAppMsgModel = model;
        
        return cell;
    }else{
        
        LANGUANGAppMsgCellARC *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[LANGUANGAppMsgCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.delegate = self;
        cell.tag = indexPath.row;
        cell.LGAppMsgModel = model;
        return cell;
    }
    
    
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LANGUANGAppMsgModelARC *model = self.appMsgModelArr[indexPath.row];
    NSString *str;
    if ([model.meetingMsgType isEqualToString:@"5"]) {
        
        str = [NSString stringWithFormat:@"[结束]\"%@%@\"会议还有%@结束,结束之后会议室将会关闭",model.startTime,model.title,model.duration];
    }else if ([model.meetingMsgType isEqualToString:@"2"]){
        
        //[取消]“2017.05.23 09:00 需求沟通”会议已取消
        str = [NSString stringWithFormat:@"[取消]\"%@%@\"会议已取消",model.startTime,model.title];
    }
    
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 90, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    if ([model.meetingMsgType isEqualToString:@"5"] || [model.meetingMsgType isEqualToString:@"2"] ) {
        
        return size.height + 10;
    }else{
        return 200;
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.delta =scrollView.contentSize.height - scrollView.contentOffset.y;
}
- (void)scrollToEnd{
    [self.tableView reloadData];
    NSUInteger index = [self.appMsgModelArr count] - 1;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.appMsgModelArr count]-1 inSection:0]
                          atScrollPosition: UITableViewScrollPositionBottom animated:NO];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
 
}

@end
