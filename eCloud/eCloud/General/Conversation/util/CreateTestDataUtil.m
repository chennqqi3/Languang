

#import "CreateTestDataUtil.h"
#import "eCloudDAO.h"
#import "conn.h"

#import "eCloudDefine.h"
#import "talkSessionUtil2.h"
#import "StringUtil.h"

#import "Emp.h"
@implementation CreateTestDataUtil

+ (BOOL)createTestData
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    
    conn *_conn = [conn getConn];
    
    if (_conn.curUser == nil)
    {
        return NO;
    }
    
    NSArray *empArray = [_conn getAllEmpInfoArray];
    
    if (empArray.count <= 1) {
        return NO;
    }
    int start = [_conn getCurrentTime];
    
    _conn.connStatus = download_org;
    _conn.downloadOrgTips = @"正在删除...";
    [db deleteTestData];
    
    NSString *convType = [StringUtil getStringValue:mutiableType];
    NSString *recvFlag = [StringUtil getStringValue:open_msg];
    NSString *convId;
    NSString *groupName;
    NSString *groupTime;
    
    
    int nowTime = [_conn getCurrentTime];
    
    NSString *createEmpId;
    
    NSDictionary *dic;
    
//    商业地产行政部的dept_id为1381
    int deptId = 1381;
    
    NSMutableArray *canUseEmps = [NSMutableArray array];
    
//    是否需要把自己加到群组成员里
    BOOL needAddSelf = YES;
    for (Emp *emp in empArray)
    {
        if (emp.emp_dept == deptId)
        {
            [canUseEmps addObject:emp];
            
            if (emp.emp_id == _conn.userId.intValue)
            {
                needAddSelf = NO;
            }
        }

        if (canUseEmps.count == 80)
        
        {
            break;
        }
    }
    
    if (needAddSelf)
    {
        [canUseEmps addObject:_conn.curUser];
    }
    
    NSMutableArray *convEmps;
    
    int max = 1000;
     for (int i = 0;i<max;i++)
    {

//        创建会话
        convId = [NSString stringWithFormat:@"test%d",i];
        groupName = [NSString stringWithFormat:@"测试群组%d",i];
        groupTime = [StringUtil getStringValue:(nowTime + i)];
        createEmpId = [StringUtil getStringValue:((Emp *)[empArray objectAtIndex:i]).emp_id];
        
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               convId,@"conv_id",
               convType,@"conv_type",
               groupName,@"conv_title",
               recvFlag,@"recv_flag",
               createEmpId,@"create_emp_id",
               groupTime,@"create_time",@"0",@"last_msg_id",nil];
        
        [db addConversation:[NSArray arrayWithObject:dic]];
        
//        增加会话成员
        convEmps = [NSMutableArray arrayWithCapacity:[canUseEmps count]];
        
        for(Emp *emp in canUseEmps)
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[StringUtil getStringValue:emp.emp_id],@"emp_id",nil];
            [convEmps addObject:dic];
        }
        [db addConvEmp:convEmps];
        
        
//        增加会话记录
        
        
        if (i == max - 1)
        {
            for (int count = 0; count < 100 ; count ++)
            {
                NSMutableArray *convRecords = [NSMutableArray array];
               int index = 0;
                for (Emp *emp in canUseEmps)
                {
                    index ++;
                    int msgFlag = rcv_msg;
                    if (emp.emp_id == _conn.userId.intValue)
                    {
                        msgFlag = send_msg;
                    }
                    
                    NSString *originMsgId = [NSString stringWithFormat:@"%lld", [_conn getNewMsgId]];
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[StringUtil getStringValue:emp.emp_id],@"emp_id",[StringUtil getStringValue:type_text],@"msg_type",[NSString stringWithFormat:@"%@%@%@ %d条",emp.emp_name,emp.empCode,emp.empNameEng,count],@"msg_body",[StringUtil getStringValue:(nowTime + index + count)],@"msg_time", @"0",@"read_flag",[StringUtil getStringValue:msgFlag],@"msg_flag",@"1",@"send_flag", @"",@"file_name",@"0",@"file_size",originMsgId,@"origin_msg_id",@"0",@"is_set_redstate",@"0",@"msg_group_time",@"0",@"receipt_msg_flag",nil];
                    [convRecords addObject:dic];
                }
                [db addConvRecord_temp_test:convRecords];

            }
            
        }
        else
        {
            NSMutableArray *convRecords = [NSMutableArray array];

            int index = 0;
            for(Emp *emp in canUseEmps)
            {
                index ++;
                int msgFlag = rcv_msg;
                if (emp.emp_id == _conn.userId.intValue)
                {
                    msgFlag = send_msg;
                }
                
                NSString *originMsgId = [NSString stringWithFormat:@"%lld", [_conn getNewMsgId]];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[StringUtil getStringValue:emp.emp_id],@"emp_id",[StringUtil getStringValue:type_text],@"msg_type",[NSString stringWithFormat:@"%@%@%@",emp.emp_name,emp.empCode,emp.empNameEng],@"msg_body",[StringUtil getStringValue:(nowTime + index)],@"msg_time", @"0",@"read_flag",[StringUtil getStringValue:msgFlag],@"msg_flag",@"1",@"send_flag", @"",@"file_name",@"0",@"file_size",originMsgId,@"origin_msg_id",@"0",@"is_set_redstate",@"0",@"msg_group_time",@"0",@"receipt_msg_flag",nil];
                [convRecords addObject:dic];
                
              }
            
            [db addConvRecord_temp_test:convRecords];

        }
        
        
        
        _conn.downloadOrgTips = [NSString stringWithFormat:@"%d",i];

//        NSLog(@"%s  %d",__FUNCTION__,i);
    }
    
    NSLog(@"%s,耗费时间为:%d",__FUNCTION__,([_conn getCurrentTime] - start));
    return YES;
}

@end
