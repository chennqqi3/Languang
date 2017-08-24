

#import "RobotDAO.h"

#import "UserDefaults.h"

#import "RobotMenuParser.h"

#import "conn.h"
#import "Emp.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "eCloudDefine.h"

#import "talkSessionUtil2.h"

static RobotDAO *robotDAO;

#define robot_table_name @"robot"

#define create_robot_table @"create table if not exists robot(robot_id integer primary key,robot_type integer,robot_attr integer,robot_greetings text,robot_menu text)" //,robot_topic

@implementation RobotDAO

+ (RobotDAO *)getDatabase
{
    if (!robotDAO) {
        robotDAO = [[super alloc]init];
    }
    return robotDAO;
}

//创建机器人表
- (void)createTable
{
    [self operateSql:create_robot_table Database:_handle toResult:nil];
    
//    增加小万菜单
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add robot_menu text",robot_table_name];
    [self operateSql:sql Database:_handle toResult:nil];
//    增加小万主题
//    sql = [NSString stringWithFormat:@"alter table %@ add robot_topic text",robot_table_name];
//    [self operateSql:sql Database:_handle toResult:nil];
}

//保存机器人资料
- (void)saveRobotInfo:(NSArray *)info
{
    //    首先删除之前的数据
    NSString *sql = [NSString stringWithFormat:@"delete from %@",robot_table_name];
    [self operateSql:sql Database:_handle toResult:nil];
    
    //    保存同步到的数据
    for (NSDictionary *dic in info)
    {
        sql = [NSString stringWithFormat:@"insert into %@(robot_id,robot_type,robot_attr,robot_greetings) values(?,?,?,?)",robot_table_name];
        
        sqlite3_stmt *stmt = nil;
        
        //		编译
        pthread_mutex_lock(&add_mutex);
        int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
        pthread_mutex_unlock(&add_mutex);
        
        if(state != SQLITE_OK)
        {
            //			编译错误
            [LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
            //			释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
            
            return;
        }
        
        pthread_mutex_lock(&add_mutex);
        sqlite3_bind_int(stmt, 1, [[dic valueForKey:@"robot_id"] intValue]);
        sqlite3_bind_int(stmt, 2, [[dic valueForKey:@"robot_type"] intValue]);
        sqlite3_bind_int(stmt, 3, [[dic valueForKey:@"robot_attr"] intValue]);
        sqlite3_bind_text(stmt, 4, [[dic valueForKey:@"robot_greetings"] UTF8String],-1,NULL);
        
        state = sqlite3_step(stmt);
        
        pthread_mutex_unlock(&add_mutex);
        
        //	执行结果
        if(state != SQLITE_DONE &&  state != SQLITE_OK)
        {
            //			执行错误
            [LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
            //释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
            
            return;
        }
        //释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
    }
    
    [self updateRobotStatus];
}

//同步完机器人之后 修改机器人对应的人员的状态是pc在线
- (void)updateRobotStatus
{
    NSString *sql = [NSString stringWithFormat:@"select robot_id from %@",robot_table_name];
    NSMutableArray *result = [self querySql:sql];
    for (NSDictionary *dic in result) {
        [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[dic description]]];
    }
    
    //    修改数据库里机器人的状态为pc在线
    if (result.count > 0) {
        for (NSDictionary *dic in result)
        {
            NSString *sql = [NSString stringWithFormat:@"update %@ set emp_status = %d,emp_login_type = %d where emp_id = %d",table_employee,status_online,TERMINAL_PC,[[dic valueForKey:@"robot_id"]intValue]];

            pthread_mutex_lock(&add_mutex);
            char *errorMsg;
            int resultCode = sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMsg);
            [LogUtil debug:[NSString stringWithFormat:@"%s result is %d",__FUNCTION__,resultCode]];
            pthread_mutex_unlock(&add_mutex);
        }
    }
}

//初始化机器人 查询机器人，把内存中机器人的状态设置为pc在线，并且设置Emp的isRobot属性为YES
- (void)initRobots
{
    conn *_conn = [conn getConn];
    
    NSString *sql = [NSString stringWithFormat:@"select b.emp_id,b.dept_id from %@ a,%@ b where a.robot_id = b.emp_id",robot_table_name,table_emp_dept];
    
    NSMutableArray *result = [self querySql:sql];
    
    for (NSDictionary *dic in result)
    {
        NSString *empKey = [NSString stringWithFormat:@"%d_%d",[[dic valueForKey:@"emp_id"]intValue],[[dic valueForKey:@"dept_id"]intValue]];
        Emp *emp = [_conn.allEmpsDic valueForKey:empKey];
        if (emp) {
            emp.isRobot = YES;
            emp.loginType = TERMINAL_PC;
            emp.emp_status = status_online;
        }
    }
}

//判断一个用户是否是机器人用户
- (BOOL)isRobotUser:(int)empId
{
    NSString *sql = [NSString stringWithFormat:@"select robot_id from %@ where robot_id = %d",robot_table_name,empId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        return YES;
    }
    return NO;
}

//插入问候语或修改问候语的时间为最近的时间
- (void)initGreetingsWithRobotId:(int)robotId andRobotName:(NSString *)robotName
{
    conn *_conn = [conn getConn];
//    查询是否有问候语
    NSString *sql = [NSString stringWithFormat:@"select robot_greetings from %@ where robot_id = %d",robot_table_name,robotId];
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count > 0) {
        NSString *greetings = [[result objectAtIndex:0]valueForKey:@"robot_greetings"];
        if (greetings.length > 0) {
//            查询下是否已经有这样的记录，如果有则修改时间，否则插入
            sql = [NSString stringWithFormat:@"select id from %@ where conv_id = '%d' and msg_type = %d and msg_body = '%@' ",table_conv_records,robotId,type_text,greetings];
            
            result = [self querySql:sql];
            if (result.count > 0)
            {
                //             修改时间
                sql = [NSString stringWithFormat:@"update %@ set msg_time = %d where id = %d",table_conv_records,[_conn getCurrentTime],[[[result objectAtIndex:0]valueForKey:@"id"]intValue]];
                [self operateSql:sql Database:_handle toResult:nil];
            }
            else
            {
                NSString *convId = [StringUtil getStringValue:robotId];

                [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:convId andTitle:robotName];
                
                //            添加
                NSString *senderId = [StringUtil getStringValue:robotId];
                NSString *msgType = [StringUtil getStringValue:type_text];
                NSString *msgBody = [NSString stringWithString:greetings];
                NSString *now = [_conn getSCurrentTime];
                
                NSString *originMsgId =  [NSString stringWithFormat:@"%lld",[_conn getNewMsgId]];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
                                     senderId,@"emp_id",
                                     msgType,@"msg_type",
                                     msgBody,@"msg_body",
                                     now,@"msg_time",
                                     @"0",@"read_flag",
                                     [StringUtil getStringValue:rcv_msg],@"msg_flag",
                                     [StringUtil getStringValue:send_success],@"send_flag",
                                     @"",@"file_name",
                                     @"0",@"file_size",
                                     originMsgId,@"origin_msg_id",
                                     @"0",@"msg_group_time",
                                     @"0",@"receipt_msg_flag",
                                     nil];
                
                [[eCloudDAO getDatabase]addConvRecord:[NSArray arrayWithObject:dic]];
                
            }
        }
    }
}

//获取小万的菜单
- (NSString *)getRobotMenu
{
    NSString *menuString = nil;
    int robotId = [self getRobotId];
    if (robotId) {
        NSString *sql = [NSString stringWithFormat:@"select robot_menu from %@ where robot_id = %d",robot_table_name,robotId];
        NSMutableArray *result = [self querySql:sql];
        if (result.count > 0) {
            menuString = [result[0] valueForKey:@"robot_menu"];
        }
    }
    return menuString;
}

//保存小万的菜单数据
- (BOOL)saveRobotMenu:(NSString *)menuString;
{
//    首先根据小万的usercode找到user_id，然后根据userid查找机器人表，保存菜单数据
    int robotId = [self getRobotId];
    if (robotId) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set robot_menu = ? where robot_id = %d",robot_table_name,robotId];
        
        sqlite3_stmt *stmt = nil;
        
        //		编译
        pthread_mutex_lock(&add_mutex);
        int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
        pthread_mutex_unlock(&add_mutex);
        
        if (state == SQLITE_OK) {
            //		绑定值
            pthread_mutex_lock(&add_mutex);
            sqlite3_bind_text(stmt, 1, [menuString UTF8String],-1,NULL);

            state = sqlite3_step(stmt);
            
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
            
            if (state == SQLITE_OK || state == SQLITE_DONE) {
                return YES;
            }
        }
    }
    return NO;
}
//
////保存小万的主题
//- (BOOL)saveRobotTopic:(NSString *)topic;
//{
//    int robotId = [self getRobotId];
//    if (robotId) {
//        NSString *sql = [NSString stringWithFormat:@"update %@ set robot_topic = ? where robot_id = %d",robot_table_name,robotId];
//        
//        sqlite3_stmt *stmt = nil;
//        
//        //		编译
//        pthread_mutex_lock(&add_mutex);
//        int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
//        pthread_mutex_unlock(&add_mutex);
//        
//        if (state == SQLITE_OK) {
//            //		绑定值
//            pthread_mutex_lock(&add_mutex);
//            sqlite3_bind_text(stmt, 1, [topic UTF8String],-1,NULL);
//            
//            state = sqlite3_step(stmt);
//            
//            sqlite3_finalize(stmt);
//            pthread_mutex_unlock(&add_mutex);
//            
//            if (state == SQLITE_OK || state == SQLITE_DONE) {
//                return YES;
//            }
//        }
//    }
//    return NO;
//}
//
////获取小万的主题
//- (NSString *)getRobotTopic
//{
//    NSString *topic = nil;
//    int robotId = [self getRobotId];
//    if (robotId) {
//        NSString *sql = [NSString stringWithFormat:@"select robot_topic from %@ where robot_id = %d",robot_table_name,robotId];
//        NSMutableArray *result = [self querySql:sql];
//        if (result.count > 0) {
//            topic = [result[0] valueForKey:@"robot_topic"];
//        }
//    }
//    return topic;
//}
//

//是否支持机器人
- (BOOL)supportRobot
{
    if ([UIAdapterUtil isGOMEApp]) {
        return YES;
    }
    return NO;
}

//取出小万的userid 取出后放在userdefaults中，免于每次都从数据库查询
- (int)getRobotId
{
    if (![self supportRobot]){
        [UserDefaults saveIRobotId:-1];
        return 0;
    }
    int empId = [UserDefaults getIRobotId];
    //    NSLog(@"%s empId is %d",__FUNCTION__,empId);
    if (empId >= 0) {
        return empId;
    }else{
        empId = [[eCloudDAO getDatabase]getEmpIdByUserAccount:USERCODE_OF_IROBOT];
        //        NSLog(@"%s 数据库查询到的empId is %d",__FUNCTION__,empId);
        
        if (empId < 0) {
            empId = 0;
        }
        
        if (empId > 0) {
            [UserDefaults saveIRobotId:empId];
        }
    }
    return empId;
}

//根据robotId得到robotName
- (NSString *)getRobotNameByRobotId:(int)robotId
{
    NSString *empName = nil;
    NSString *sql = [NSString stringWithFormat:@"select emp_id,emp_name,emp_name_eng from %@ where emp_id = %d",table_employee,robotId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        Emp *_emp = [[Emp alloc]init];
        _emp.emp_id = [[[result objectAtIndex:0]valueForKey:@"emp_id"]intValue];
        _emp.emp_name = [result[0] valueForKey:@"emp_name"];
        _emp.empNameEng = [result[0] valueForKey:@"emp_name_eng"];
        
        empName = _emp.emp_name;
    }
    return empName;
}

//取出小万的id，生成内容是欢迎语的新消息
- (void)createOneNewMsgOfGreetingsOfIRobot
{
    int robotId = [self getRobotId];
    [self createOneNewMsgOfGreetingsWithRobotId:robotId andTipContent:nil];
}

//处理蓝信小秘书，生成内容是欢迎语的新消息
- (void)createOneNewMsgOfGreetingsOfLanxin
{
    /*
     首次进入蓝信，推送以下文字：
     欢迎你使用蓝信。如果你在使用过程中有任何的问题或建议，请记得在这里直接给我发信进行反馈噢。你也可以通过：我的>设置>意见反馈 进行反馈，蓝信的发展离不开你。
     
     退出账户再次登录后，蓝信推送以下文字：
     欢迎你再次回到蓝信。如果你在使用过程中有任何的问题或建议，请记得在这里直接给我发信进行反馈噢。你也可以通过：我的>设置>意见反馈 进行反馈，蓝信的发展离不开你。
     */
    BOOL userIsExist = [UserDefaults getExistStatus];
    NSMutableArray *didLoginUserArr = [UserDefaults getDidLoginUserWithArr];
    
    if (![didLoginUserArr containsObject:[conn getConn].userId]) {
        // 首次登录
        [UserDefaults saveExistStatus:NO];
        // 将登录过的账号添加入数组，保存到沙盒中
        [didLoginUserArr addObject:[conn getConn].userId];
        [UserDefaults saveDidLoginUserWithArr:didLoginUserArr];
        
        NSString *tipStr = @"欢迎你使用蓝信。如果你在使用过程中有任何的问题或建议，请记得在这里直接给我发信进行反馈噢。你也可以通过：我的>设置>意见反馈 进行反馈，蓝信的发展离不开你。";
        [self createOneNewMsgOfGreetingsWithRobotId:13774 andTipContent:tipStr];
    }else if(userIsExist){
        // 退出账号的再次登录
        [UserDefaults saveExistStatus:NO];
        
        NSString *tipStr = @"欢迎你再次回到蓝信。如果你在使用过程中有任何的问题或建议，请记得在这里直接给我发信进行反馈噢。你也可以通过：我的>设置>意见反馈 进行反馈，蓝信的发展离不开你。";
        [self createOneNewMsgOfGreetingsWithRobotId:13774 andTipContent:tipStr];
    }
}

//取出文件助手的id，生成内容是欢迎语的新消息
- (void)createOneNewMsgOfGreetingsOfFileTransfer
{
//    首先根据usercode查询到文件助手的empid，然后再判断是否需要生成和文件助手的新消息和单人聊天
    int robotId = 0;
    NSString *sql = [NSString stringWithFormat:@"select emp_id from %@ where emp_code = '%@'  COLLATE NOCASE ",table_employee,USERCODE_OF_FILETRANSFER];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        robotId = [[[result objectAtIndex:0]valueForKey:@"emp_id"]intValue];
    }
    [self createOneNewMsgOfGreetingsWithRobotId:robotId andTipContent:nil];
}

//查看和机器人的聊天记录，看是否有欢迎语，如果没有则生成一条内容是欢迎语的新消息
- (void)createOneNewMsgOfGreetingsWithRobotId:(int)robotId andTipContent:(NSString *)tipContent
{
    if (robotId) {
        conn *_conn = [conn getConn];
        //    查询是否有问候语
        NSString *sql = [NSString stringWithFormat:@"select robot_greetings from %@ where robot_id = %d",robot_table_name,robotId];
        NSMutableArray *result = [self querySql:sql];
        
        if (result.count > 0) {
            NSString *greetings = [[result objectAtIndex:0]valueForKey:@"robot_greetings"];
            if (greetings.length > 0) {
                //            查询下是否已经有这样的记录，如果有则修改时间，否则插入
                sql = [NSString stringWithFormat:@"select id from %@ where conv_id = '%d' and msg_type = %d and msg_body = '%@' ",table_conv_records,robotId,type_text,greetings];
                
                result = [self querySql:sql];
                if (result.count == 0)
                {
                    NSString *robotName = [self getRobotNameByRobotId:robotId];
                    
                    if (robotName) {
                        
                        NSString *convId = [StringUtil getStringValue:robotId];

                        [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:convId andTitle:robotName];
                        
                        //            添加
                        NSString *senderId = [StringUtil getStringValue:robotId];
                        NSString *msgType = [StringUtil getStringValue:type_text];
                        NSString *msgBody = [NSString stringWithString:greetings];
                        NSString *now = [_conn getSCurrentTime];
                        
                        NSString *originMsgId =  [NSString stringWithFormat:@"%lld",[_conn getNewMsgId]];
                        
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
                                             senderId,@"emp_id",
                                             msgType,@"msg_type",
                                             msgBody,@"msg_body",
                                             now,@"msg_time",
                                             @"1",@"read_flag",
                                             [StringUtil getStringValue:rcv_msg],@"msg_flag",
                                             [StringUtil getStringValue:send_success],@"send_flag",
                                             @"",@"file_name",
                                             @"0",@"file_size",
                                             originMsgId,@"origin_msg_id",
                                             @"0",@"msg_group_time",
                                             @"0",@"receipt_msg_flag",
                                             nil];
                        
                        [[eCloudDAO getDatabase]addConvRecord:[NSArray arrayWithObject:dic]];
                    }
                }
            }
        }else{
            NSString *robotName = [self getRobotNameByRobotId:robotId];
            
            NSString *greetings = @"欢迎你使用蓝信。如果你在使用过程中有任何的问题或建议，请记得在这里直接给我发信进行反馈噢。你也可以通过：我的>设置>意见反馈 进行反馈，蓝信的发展离不开你。";
            if (tipContent != nil) {
                greetings = tipContent;
            }
            
            if (robotName) {
                
                NSString *convId = [StringUtil getStringValue:robotId];
                
                [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:convId andTitle:robotName];
                
                //            添加
                NSString *senderId = [StringUtil getStringValue:robotId];
                NSString *msgType = [StringUtil getStringValue:type_text];
                NSString *msgBody = [NSString stringWithString:greetings];
                NSString *now = [_conn getSCurrentTime];
                
                NSString *originMsgId =  [NSString stringWithFormat:@"%lld",[_conn getNewMsgId]];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
                                     senderId,@"emp_id",
                                     msgType,@"msg_type",
                                     msgBody,@"msg_body",
                                     now,@"msg_time",
                                     @"1",@"read_flag",
                                     [StringUtil getStringValue:rcv_msg],@"msg_flag",
                                     [StringUtil getStringValue:send_success],@"send_flag",
                                     @"",@"file_name",
                                     @"0",@"file_size",
                                     originMsgId,@"origin_msg_id",
                                     @"0",@"msg_group_time",
                                     @"0",@"receipt_msg_flag",
                                     nil];
                
                [[eCloudDAO getDatabase]addConvRecord:[NSArray arrayWithObject:dic]];
            }
        }
    }
}


@end
