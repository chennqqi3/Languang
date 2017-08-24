//和机器人相关的通讯类

#import "RobotConn.h"

#import "JSONKit.h"
#import "TimeUtil.h"

#import "RobotMenuParser.h"

#import "conn.h"
#import "LogUtil.h"
#import "UserDefaults.h"
#import "StringUtil.h"
#import "RobotDAO.h"

#import "eCloudUser.h"
#import "eCloudDefine.h"

@interface RobotConn ()

@property (nonatomic,assign) int curPage;
@property (nonatomic,retain) NSMutableArray *robotArray;

@end


static RobotConn *robotConn;

@implementation RobotConn

@synthesize curPage;
@synthesize robotArray;
@synthesize robotMenuArray;

- (void)dealloc
{
    self.robotMenuArray = nil;
    self.robotArray = nil;
    
    [super dealloc];
}

+ (RobotConn *)getConn
{
    if (!robotConn) {
        robotConn = [[super alloc]init];
    }
    return robotConn;
}

//发起同步机器人资料请求
- (void)syncRobotInfo
{
    conn *_conn = [conn getConn];
    
//    test code
//    _conn.oldRobotUpdateTime = 0;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s old time is %d, new time is %d",__FUNCTION__,_conn.oldRobotUpdateTime,_conn.newRobotUpdateTime]];
    
    if (_conn.oldRobotUpdateTime < _conn.newRobotUpdateTime)
    {
        ROBOTSYNCREQ info;
        memset(&info, 0x0, sizeof(info));
        info.dwCompID = [UserDefaults getCompId];
        info.dwUserID = _conn.userId.intValue;
        info.cTerminal = TERMINAL_IOS;
        info.cReqType = 0;
        info.dwTimestamp = _conn.oldRobotUpdateTime;
        
        
        CLIENT_RobotInfoSync([_conn getConnCB],&info);
        
        self.curPage = 0;
        self.robotArray = [NSMutableArray array];
    }
    else
    {
        [_conn getOfflineMsgNum];
    }
}
//typedef struct _robot_user
//{
//#define MAX_ROBOTGREETINGS_NUM	300		//机器人问候语最大字节数
//    UINT32	dwUserID;	//机器人ID
//    UINT32	dwAttribute;//机器人属性(保留字段)
//    UINT8	cUserType;	//机器人类型
//    UINT8	aszGreetings [MAX_ROBOTGREETINGS_NUM];	//机器人问候语
//}robotuser;
//
//typedef struct _robot_sync_rsp
//{
//#define MAX_ROBOTLIST_NUM		6		//机器人列表最大个数
//    UINT32  dwCompID;	//企业ID
//    UINT32  dwUserID;	//用户ID
//    UINT8	cTerminal;	//终端类型
//    UINT8	cReqType;	//类型
//    UINT32	dwTimestamp;//时间戳
//    UINT16	wTotalPage;		//总页数
//    UINT16	wCurrentPage;	//当前页数
//    UINT16	wRobotNum;	//机器人个数
//    robotuser	sRobotList[MAX_ROBOTLIST_NUM];		//机器人列表
//}ROBOTSYNCRSP;

//处理机器人同步应答
- (void)processSyncRobotAck:(ROBOTSYNCRSP *)info
{
    self.curPage++;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,total page is %d,cur page is %d",__FUNCTION__,info->wTotalPage,self.curPage]];
    
    int robotNum = info->wRobotNum;
    
    for (int i = 0; i < robotNum; i++) {
        robotuser _user = info->sRobotList[i];
        NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_user.dwUserID],@"robot_id",
                              [NSNumber numberWithInt:_user.cUserType],@"robot_type",
                              [NSNumber numberWithInt:_user.dwAttribute],@"robot_attr",
                              [StringUtil getStringByCString:(char *)_user.aszGreetings],@"robot_greetings",nil];
        
        [self.robotArray addObject:_dic];
    }
    
    if (self.curPage == info->wTotalPage) {
//保存
        [[RobotDAO getDatabase]saveRobotInfo:self.robotArray];
        
        [[eCloudUser getDatabase]saveRobotUpdateTime];
        
        self.robotArray = nil;

        [[conn getConn]getOfflineMsgNum];
    }
}

//同步小万菜单
- (void)syncRobotMenu
{
    int robotId = [[RobotDAO getDatabase]getRobotId];
    if (!robotId) {
        return;
    }
    NSString *syncUrlString = [NSString stringWithFormat:@"%@%@",[[ServerConfig shareServerConfig]getRobotMenuURL],[StringUtil getRobotUrlAddStr]];
    [LogUtil debug:[NSString stringWithFormat:@"%s,同步小万菜单的url是%@",__FUNCTION__,syncUrlString]];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:syncUrlString]];
    
    if (data) {
        NSString *menuString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (menuString) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 同步到的小万菜单数据是 %@",__FUNCTION__,menuString]];
            
            RobotMenuParser *newParser = [[[RobotMenuParser alloc]init]autorelease];
            [newParser parseRobotMenu:menuString];
            NSString *newUpdateTime = newParser.updateTime;
            self.robotMenuArray = newParser.menuArray;

//            首先从数据库查询已有的菜单
            NSString *oldMenuString = [[RobotDAO getDatabase]getRobotMenu];
            if (!oldMenuString) {
                [[RobotDAO getDatabase]saveRobotMenu:menuString];
            }else{
                RobotMenuParser *oldParser = [[[RobotMenuParser alloc]init]autorelease];
                [oldParser parseRobotMenu:oldMenuString];
                NSString *oldUpdateTime = oldParser.updateTime;
                
                if ([oldUpdateTime compare:newUpdateTime options:NSCaseInsensitiveSearch] != NSOrderedSame) {
                    [[RobotDAO getDatabase]saveRobotMenu:menuString];
                }
            }
        }
    }
}

#define KEY_TOPIC_STATUSCODE @"statusCode"
#define KEY_TOPIC @"topic"

//同步小万每日主题
- (void)syncRobotTopic
{
//    该项功能已经不再需要
    return;
    int robotId = [[RobotDAO getDatabase]getRobotId];
    if (!robotId) {
        return;
    }
    NSString *syncUrlString = [NSString stringWithFormat:@"%@%@",[[ServerConfig shareServerConfig]getRobotTopicURL],[StringUtil getRobotUrlAddStr]];
    [LogUtil debug:[NSString stringWithFormat:@"%s,同步小万主题的url是%@",__FUNCTION__,syncUrlString]];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:syncUrlString]];
    
    if (data) {
        NSDictionary *dic = [data objectFromJSONData];

        //            {"topic":"天气","statusCode":200}
        int statusCode = [dic[KEY_TOPIC_STATUSCODE]intValue];
        NSString *topic = dic[KEY_TOPIC];

        if (statusCode == 200) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 同步到的小万主题数据是 %@",__FUNCTION__,topic]];
            
            [self sendToRobotSlientlyWithTopic:topic];
        }
    }
}

//            同步到主题后，主动发送主题给小万
- (void)sendToRobotSlientlyWithTopic:(NSString *)topic
{
    NSString *sendDate = [UserDefaults getRobotTopicSendDate:topic];
    NSString *nowDate = [TimeUtil getDateOfTime:[[conn getConn]getCurrentTime]];
    
    if ([nowDate isEqualToString:sendDate]) {
        return;
    }
    
    int robotId = [[RobotDAO getDatabase]getRobotId];
    
    conn *_conn = [conn getConn];
    
    [_conn sendMsg:[StringUtil getStringValue:robotId] andConvType:singleType andMsgType:type_text andMsg:topic andMsgId:[_conn getNewMsgId] andTime:[_conn getCurrentTime] andReceiptMsgFlag:0];
    
    //            保存主题发送日期
    [UserDefaults saveRobotTopicSendDate:topic];
}

@end
