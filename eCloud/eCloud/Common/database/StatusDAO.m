
#import "StatusDAO.h"
#import "StringUtil.h"
#import "UserDefaults.h"

//表名称
#define table_get_status @"get_status_time"
//表创建
#define create_get_status_table @"create table if not exists get_status_time(status_type integer,status_id text,status_time int, primary key (status_type,status_id))"

static StatusDAO *_statusDAO;
@implementation StatusDAO

+ (StatusDAO *)getDatabase
{
    if (!_statusDAO) {
        _statusDAO = [[StatusDAO alloc]init];
    }
    return _statusDAO;
}

- (void)createTable
{
    [self operateSql:create_get_status_table Database:_handle toResult:nil];
}

- (BOOL)needGetStatus:(NSString *)statusId andType:(int)statusType
{
    NSString *sql = [NSString stringWithFormat:@"select status_time from %@ where status_id = '%@' and status_type = %d",table_get_status,statusId,statusType];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        int lastStatusTime = [[[result objectAtIndex:0]valueForKey:@"status_time"]intValue];
        
        int i = [[StringUtil currentTime]intValue];
        int j = [UserDefaults getStatusTimeInterval];
        
        if (([[StringUtil currentTime]intValue] - lastStatusTime) >= [UserDefaults getStatusTimeInterval]) {
            NSLog(@"%s,%@,%d",__FUNCTION__,statusId,statusType);

//            NSLog(@"已经超过超时时间，需要获取状态");
            [self modifyStatusTime:statusId andType:statusType];
            return YES;
        }
//        NSLog(@"没有超过超时时间，不需要获取状态");
        return NO;
    }
//    NSLog(@"还没有获取状态记录，需要获取状态");
    [self saveStatusTime:statusId andType:statusType];
    return YES;
}

//根据id，type，时间，增加一条新的记录
- (void)saveStatusTime:(NSString *)statusId andType:(int)statusType
{
    NSString *sql = [NSString stringWithFormat:@"insert into %@(status_Id,status_type,status_time) values('%@',%d,%@)",table_get_status,statusId,statusType,[StringUtil currentTime]];
    [self operateSql:sql Database:_handle toResult:nil];
}

//根据id，type，时间，修改原有的记录
- (void)modifyStatusTime:(NSString *)statusId andType:(int)statusType
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set status_time = %@ where status_id = '%@' and status_type = %d",table_get_status,[StringUtil currentTime], statusId,statusType];
    [self operateSql:sql Database:_handle toResult:nil];
}

//删除所有时间超过的记录
-(void)deleteInvalidStatusTime
{
//    NSString *sql = [NSString stringWithFormat:@"delete from %@ where (%@ - status_time) >= %d",table_get_status,[StringUtil currentTime],[UserDefaults getStatusTimeInterval]];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ ",table_get_status];
    [self operateSql:sql Database:_handle toResult:nil];
}
@end
