//
//  TAIHEAppMsgViewController.m
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEAppMsgViewController.h"
#import "eCloudDefine.h"

#import "TAIHEAppMsgCell.h"
#import "TAIHEAppMsgModel.h"
#import "eCloudDAO.h"
#import "ConvNotification.h"
#import "RemindModel.h"
#import "StringUtil.h"
#import "ConvRecord.h"
#import "Conversation.h"
#import "TAIHEAgentLstViewController.h"
#import "TAIHEAppMsgCellDelegate.h"
#import "TAIHEEmailAppMsgCell.h"
#import "NewMsgNotice.h"
#import "PSBackButtonUtil.h"
#import "talkSessionViewController.h"
#import "ReceiptMsgUtil.h"
#import "MJRefresh.h"
#import "ServerConfig.h"

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *cellEmailIdentifier = @"cellEmailIdentifier";

@interface TAIHEAppMsgViewController ()<UITableViewDelegate, UITableViewDataSource, TAIHEAppMsgCellDelegate>
/**  当前要加载的第三方应用的类别   */
@property (nonatomic,assign) int appFlag;
/**  table  */
@property (nonatomic, strong) UITableView *tableView;
/**  数据源  */
@property (nonatomic, strong) NSMutableArray *appMsgModelArr;
/**  是否是查看详情操作  */
@property (nonatomic,assign) BOOL isGotoDetail;

@property (nonatomic, assign) CGFloat delta;//先定义一个delta保存后面的差值
@end

@implementation TAIHEAppMsgViewController
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
            TAIHEAppMsgModel *appMsgModel = [self getConvRecord:record];
            
            [_appMsgModelArr addObject:appMsgModel];
            
            // 将消息置为已读
//            [[eCloudDAO getDatabase] updateReadStatusByMsgId:[NSString stringWithFormat:@"%d",record.msgId] sendRead:0];
        }
        loadCount = _appMsgModelArr.count;
        if (_appMsgModelArr && _appMsgModelArr.count > 0) {
            TAIHEAppMsgModel *appMsgModel = _appMsgModelArr[0];
            
            _appFlag = appMsgModel.apptype;
        }
        
    }
    
    //全部消息设置为已读
    [[eCloudDAO getDatabase] updateTextMessageToReadState:self.conv.conv_id];
    
    return _appMsgModelArr;
}


- (TAIHEAppMsgModel *)getConvRecord:(ConvRecord *)record{
    NSData *bodyData = [record.msg_body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *appMsgDic = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
    
    TAIHEAppMsgModel *appMsgModel = [TAIHEAppMsgModel appMsgModelWithDic:appMsgDic];
    appMsgModel.msgtime = record.msg_time;
    
//    会议消息
    if (appMsgModel.confid.length) {
        //appMsgModel.location = @"第三方的士大夫撒旦撒旦顺丰到付胜多负少水电费水电费的水电费收水电费水电费是范德萨的冯绍峰的";
        appMsgModel.apptype = app_conf_flag;
    }
    
    return appMsgModel;
}

- (void)viewWillAppear:(BOOL)animated{
    [UIAdapterUtil hideTabBar:self];
}
- (void)viewDidDisappear:(BOOL)animated{
    if (!self.isGotoDetail) {
        [UIAdapterUtil showTabar:self];
    }else{
        self.isGotoDetail = NO;
    }
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
    [self.tableView registerNib:[UINib nibWithNibName:@"TAIHEAppMsgCell" bundle:nil]  forCellReuseIdentifier:cellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TAIHEEmailAppMsgCell" bundle:nil]  forCellReuseIdentifier:cellEmailIdentifier];
    
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
            TAIHEAppMsgModel *appMsgModel = [self getConvRecord:record];
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
                                TAIHEAppMsgModel *appMsgModel = [self getConvRecord:convRecord];
                                
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
- (void)viewDetail:(TAIHEAppMsgCell *)curCell
{
    TAIHEAppMsgModel *msgModel = curCell.appMsgModel;
    
//    会议消息不展开
    if (msgModel.apptype == app_conf_flag){
        return;
    }
    
    self.isGotoDetail = YES;
    
    TAIHEAgentLstViewController *openweb=[[TAIHEAgentLstViewController alloc]init];
    
    // 使用加密的参数
    NSString *paramStr = [StringUtil encryptStr];
    NSString *ssoUrl = [[ServerConfig shareServerConfig]getSSOServerUrl];
    NSString *oaUrl = [[ServerConfig shareServerConfig]getOAServerUrl];
    NSString *url = [NSString stringWithFormat:@"%@?username=%@",ssoUrl,paramStr];

    openweb.urlstr= [[NSString stringWithFormat:@"%@&url=%@",url,msgModel.url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (msgModel.apptype == app_email_flag) {
        
        openweb.isWhere = REFRESH_EMAIL;
    }else if (msgModel.apptype == app_oa_flag){
        
        openweb.isWhere = REFRESH_OA;
    }
    openweb.isGoHome = GO_NATIVE_HOME;
    [self.navigationController pushViewController:openweb animated:YES];
}

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
    TAIHEAppMsgCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self viewDetail:cell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    TAIHEAppMsgModel *_model = self.appMsgModelArr[indexPath.row];
    if (_model.apptype == app_oa_flag || _model.apptype == app_oa_attendance_flag) {
        TAIHEAppMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.delegate = self;
        cell.tag = indexPath.row;
        cell.appMsgModel = _model;
        
        return cell;
    }else if (_model.apptype == app_email_flag || _model.apptype == app_conf_flag){
        TAIHEEmailAppMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellEmailIdentifier];
        cell.delegate = self;
        cell.tag = indexPath.row;
        cell.appMsgModel = _model;
        return cell;
    }
    return nil;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TAIHEAppMsgModel *_model = self.appMsgModelArr[indexPath.row];
    
    if (_model.apptype == app_oa_flag) {
        return 200;
    }else if(_model.apptype == app_email_flag || _model.apptype == app_conf_flag){
        // 根据文字多少计算cell的高度
        NSMutableParagraphStyle *paragphStyle=[[NSMutableParagraphStyle alloc]init];
        paragphStyle.lineSpacing=0;//设置行距为0
        paragphStyle.firstLineHeadIndent=0.0;
        paragphStyle.hyphenationFactor=0.0;
        paragphStyle.paragraphSpacingBefore=0.0;
        NSDictionary *attributeDic1 = @{
                                        NSFontAttributeName:[UIFont systemFontOfSize:17],
                                        NSParagraphStyleAttributeName:paragphStyle, NSKernAttributeName:@1.0f
                                       };
        TAIHEAppMsgModel *appMsgModelItem = self.appMsgModelArr[indexPath.row];
        NSString *contentStr = appMsgModelItem.content;
        if (appMsgModelItem.apptype == app_conf_flag) {
            contentStr = appMsgModelItem.location;
        }
        CGSize size1 = [contentStr sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(SCREEN_WIDTH-50, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        //CGSize size1 = [contentStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-50, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic1 context:nil].size;
        
        return 153 + size1.height;
    }
    
    return 100;
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
    
//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewScrollPositionBottom];
//    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    
    // 发出已读通知
    //    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.appModel.appid],@"conv_id", nil];
    //
    //    [[eCloudDAO getDatabase] sendNewConvNotification:info andCmdType:read_app_msg];
}
@end
