
#import "BlackListConn.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "LogUtil.h"
#import "PermissionModel.h"
#import "PermissionDAO.h"
#import "BlackListModel.h"
#import "WhiteListModel.h"
#import "SpecialListModel.h"
#import "eCloudUser.h"

#import "Emp.h"
#import "Dept.h"

@implementation BlackListConn

+ (BlackListConn *)getConn
{
    static BlackListConn * singleton;
    if (!singleton)
    {
        singleton = [[BlackListConn alloc] init];
    }
    return singleton;
}
#pragma mark 获取黑名单
//- (void)getBlacklist
//{
//    NSLog(@"%s",__FUNCTION__);
//}

#pragma mark 获取黑名单
- (void)getBlacklist
{
    return;
    conn *_conn = [conn getConn];
    PermissionDAO *permissionDAO = [PermissionDAO getDatabase];
    
    int oldSpeicalTime = 0;
    int oldWhiteTime = 0;
    
    int newSpeicalTime = 0;
    int newWhiteTime = 0;
    
    BOOL needGetBlackList = NO;
    if (_conn.oldBlacklistUpdateTime == nil || _conn.oldBlacklistUpdateTime.length == 0)
    {
        NSLog(@"本地还没有特殊名单数据");
        needGetBlackList = YES;
    }
    else
    {
        NSRange range = [_conn.oldBlacklistUpdateTime rangeOfString:@"|"];
        if(range.length == 0)
        {
            NSLog(@"本地保存的时间戳不符合规范");
        }
        else
        {
            oldSpeicalTime = [[_conn.oldBlacklistUpdateTime substringToIndex:range.location]intValue];
            oldWhiteTime = [[_conn.oldBlacklistUpdateTime substringFromIndex:range.location + 1]intValue];
            
            //            看新的时间戳是什么
            range = [_conn.newBlacklistUpdateTime rangeOfString:@"|"];
            if(range.length == 0)
            {
                NSLog(@"新的特殊名单的时间戳不符合规范");
            }
            else
            {
                newSpeicalTime = [[_conn.newBlacklistUpdateTime substringToIndex:range.location]intValue];
                newWhiteTime = [[_conn.newBlacklistUpdateTime substringFromIndex:range.location + 1]intValue];
                
                [LogUtil debug:[NSString stringWithFormat:@"%s,new special time is %d ,old special time is %d,new white time is %d ,old white time is %d",__FUNCTION__,newSpeicalTime,oldSpeicalTime,newWhiteTime,oldWhiteTime]];
                
                if((newSpeicalTime > oldSpeicalTime) || (newWhiteTime > oldWhiteTime))
                {
                    needGetBlackList = YES;
                }
            }
        }
    }
//    needGetBlackList = NO;
    if(needGetBlackList)
    {
        eCloudDAO *db = [eCloudDAO getDatabase];
        NSArray *deptsArray = [db getUserDeptsArray];
        if(deptsArray == nil)
        {
            NSLog(@"没有查到用户部门，不再继续获取特殊用户列表");
        }
        else
        {
            int deptCount = deptsArray.count;
            
            GETSPECIALLIST *getData = (GETSPECIALLIST *)malloc(sizeof(GETSPECIALLIST));
            memset(getData, 0, sizeof(GETSPECIALLIST));
            getData->cDeptNum = deptCount;
            getData->cLoginType = TERMINAL_IOS;
            getData->cPageSeq = 1;
            getData->dwUserID = _conn.userId.intValue;
            getData->nSpecialTme = oldSpeicalTime;
            getData->nWhiteTime = oldWhiteTime;
            
            for (int i = 0; i < deptCount; i++)
            {
                getData->dwDepID[i] = [[deptsArray objectAtIndex:i]intValue];
            }
            
            if(CLIENT_GetSpecialList([_conn getConnCB],getData) == 0)
            {
                NSLog(@"获取特殊用户指令发送成功");
                permissionDAO.needReComputeDeptEmpCout = NO;
            }
            else
            {
                NSLog(@"获取特殊用户指令发送失败");
            }
            free(getData);
        }
    }
    else
    {
        NSLog(@"特殊用户列表没有变化");
    }
}


#pragma mark 保存黑名单
- (void)saveBlacklist:(GETSPECIALLISTACK*)info
{
    if(info->result != RESULT_SUCCESS)
    {
        NSLog(@"获取特殊用户列表返回了失败");
        return;
    }
    conn *_conn = [conn getConn];
    int specialTime = info->nSpecialTme;
    int whiteTime = [_conn getWhiteTime];
    
    NSMutableArray *specialList = [NSMutableArray array];
    
//    保存特殊用户到数组
    int specialCount = info->wSpecialNum;
    for (int i = 0; i < specialCount; i++)
    {
        SpecialList_t _special = info->mSpecialList[i];
        SpecialListModel *_model = [[SpecialListModel alloc]init];
        _model.userId = _special.dwSpecialID;
        _model.userType = _special.cIdType;
        _model.updateType = _special.cOpType;
        _model.hideType = _special.cHideType;
        [specialList addObject:_model];
        [_model release];
    }    
    
//    保存白名单到数组
    NSMutableArray *whiteList = [NSMutableArray array];
    int whiteCount = info->wWhiteNum;
    for (int i = 0; i < whiteCount; i++)
    {
        WhiteList_t _white = info->mWhiteList[i];
        WhiteListModel *_model = [[WhiteListModel alloc]init];
        _model.userId = _white.dwSpecialID;
        _model.userType = _white.cIdType;
        _model.updateType = _white.cOpType;
        _model.whiteUserId = _white.dwWhiteID;
//        如果时间戳比较大，则保存新的时间戳
        if(_white.nWhiteTime > whiteTime)
        {
            whiteTime = _white.nWhiteTime;
        }
        
        [whiteList addObject:_model];
        [_model release];
    }
    
    NSLog(@"%s,special count is %d ,%d    white count is %d,%d  ",__FUNCTION__,specialCount,specialList.count,whiteCount,whiteList.count);
    
    [_conn setNewBlacklistTime:specialTime andWhiteTime:whiteTime];
    
    [self saveToDB:specialList andWhiteList:whiteList];
}
#pragma mark 保存黑名单
- (void)saveBlacklistNotice:(MODISPECIALLISTNOTICE*)info
{
    NSLog(@"%s",__FUNCTION__);
    
    conn *_conn = [conn getConn];
    int specialTime = info->nSpecialTme;
    int whiteTime = [_conn getWhiteTime];

    NSMutableArray *specialList = [NSMutableArray array];
    //    保存特殊用户到数组
    
    int specialCount = info->wSpecialNum;
    for (int i = 0; i < specialCount; i++)
    {
        SpecialList_t _special = info->mSpecialList[i];
        SpecialListModel *_model = [[SpecialListModel alloc]init];
        _model.userId = _special.dwSpecialID;
        _model.userType = _special.cIdType;
        _model.updateType = _special.cOpType;
        _model.hideType = _special.cHideType;
        [specialList addObject:_model];
        [_model release];
    }
    //    保存白名单到数组
    NSMutableArray *whiteList = [NSMutableArray array];
    int whiteCount = info->wWhiteNum;
    for (int i = 0; i < whiteCount; i++)
    {
        WhiteList_t _white = info->mWhiteList[i];
        WhiteListModel *_model = [[WhiteListModel alloc]init];
        _model.userId = _white.dwSpecialID;
        _model.userType = _white.cIdType;
        _model.updateType = _white.cOpType;
        _model.whiteUserId = _white.dwWhiteID;
        
        if(_white.nWhiteTime > whiteTime)
        {
            whiteTime = _white.nWhiteTime;
        }
        [whiteList addObject:_model];
        [_model release];
    }
    
    NSLog(@"%s,special count is %d ,%d    white count is %d,%d  ",__FUNCTION__,specialCount,specialList.count,whiteCount,whiteList.count);
    
//    更新时间戳，用来保存新的时间戳
    [_conn setNewBlacklistTime:specialTime andWhiteTime:whiteTime];
    
    [self saveToDB:specialList andWhiteList:whiteList];

}


- (void)saveToDB:(NSMutableArray *)specialList andWhiteList:(NSMutableArray *)whiteList
{    
    PermissionDAO *dao = [PermissionDAO getDatabase];
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    
    conn *_conn = [conn getConn];
    
    NSLog(@"保存特殊用户名单到数据库");
    for(SpecialListModel *_model in specialList)
    {
        [dao saveIfIsSpecial:_model];
    }

    NSLog(@"保存白名单到数据库");
    for(WhiteListModel *_model in whiteList)
    {
        int userId = _model.userId;
        int userType = _model.userType;
        if(_model.updateType == insertRecord)
        {
            [dao addWhiteUser:_model];
        }
        else if(_model.updateType == deleteRecord)
        {
            [dao deleteWhiteUser:_model];
        }
    }

    //    遍历特殊名单列表
    NSLog(@"遍历特殊名单列表");
    for(SpecialListModel *_model in specialList)
    {
        int userId = _model.userId;
        int userType = _model.userType;
        
        if(userType == type_emp)
        {
           Emp *emp = [_ecloud getEmpInfo:[NSString stringWithFormat:@"%d",userId]];
            NSLog(@"emp is %d, %@",userId,emp.emp_name);
        }
        else
        {
            NSDictionary *dic = [_ecloud searchDept:[NSString stringWithFormat:@"%d",userId]];
            NSLog(@"dept is %d, %@",userId,[dic valueForKey:@"dept_name"]);
        }
        int hideType = _model.hideType;
        
        BlackListModel *blackModel = [[BlackListModel alloc]init];
        blackModel.userId = userId;
        blackModel.userType = userType;
        blackModel.hideType = hideType;
        
        if(_model.updateType == insertRecord)
        {
            [dao addSpeicalUser:blackModel];
        }
        else if(_model.updateType == updateRecord)
        {
            [dao updateSpecialUser:blackModel];
        }
        else if (_model.updateType == deleteRecord)
        {
            [dao deleteSpecialUser:blackModel];
        }
        
        [blackModel release];
    }
    
    NSLog(@"遍历白名单");
    //    处理白名单的变化
    for(WhiteListModel *_model in whiteList)
    {
        int userId = _model.userId;
        int userType = _model.userType;
        
        if(userType == type_emp)
        {
            Emp *emp = [_ecloud getEmpInfo:[NSString stringWithFormat:@"%d",userId]];
            NSLog(@"emp is %d, %@",userId,emp.emp_name);
        }
        else
        {
            NSDictionary *dic = [_ecloud searchDept:[NSString stringWithFormat:@"%d",userId]];
            NSLog(@"dept is %d,%@",userId,[dic valueForKey:@"dept_name"]);
        }
        
        BlackListModel *tempModel = [dao getSpeicialUser:userId andUserType:userType];
        if(tempModel == nil)
        {
            NSLog(@"某特殊用户的白名单修改了，但是本地没有这个特殊用户，直接返回");
            continue;
        }
        
        if(_model.updateType == deleteRecord)
        {
            NSLog(@"白名单里删除了一条记录");
            BOOL isBlack = [dao isBlack:tempModel];
            if(isBlack)
            {
                tempModel.isBlack = 1;
                [dao updateSpecialUserBlackFlag:tempModel];
                
                if(tempModel.permission.isHidden)
                {
                    NSLog(@"hideType是隐藏");
                    dao.needReComputeDeptEmpCout = YES;
                }
            }
        }
        else if(tempModel.isBlack == 1 && _model.updateType == insertRecord)
        {
            tempModel.isBlack = 0;
            NSLog(@"原来不在白名单里，现在加入了白名单");
            [dao updateSpecialUserBlackFlag:tempModel];
            
            if(tempModel.permission.isHidden)
            {
                NSLog(@"hideType是隐藏");
                dao.needReComputeDeptEmpCout = YES;
            }
        }
    }
    
    [dao reComputeDeptEmpCountIfNeed];
    
//    保存新的时间戳
    eCloudUser *userDb = [eCloudUser getDatabase];
    [userDb saveBlacklistUpdateTime:[NSDictionary dictionaryWithObject:_conn.newBlacklistUpdateTime forKey:black_list_updatetime]];
}

- (void)addTestData
{
    NSMutableArray *specialList = [NSMutableArray array];
    
//一个特殊用户
//    增加一个特殊用户
//    修改一个特殊用户，修改其hideType的值
//    删除一个特殊用户
//    增加一个特殊部门
//    修改一个部门
//    删除一个部门
    
    SpecialListModel *_model = [[SpecialListModel alloc]init];
    _model.userId = 10;
    _model.userType = type_dept;
    _model.hideType = 1;
    _model.updateType = insertRecord;
    
    [specialList addObject:_model];
    
    [_model release];
    
//    加到白名单里
//    再测试从白名单里删除
//    加到白名单里
    NSMutableArray *whiteList = [NSMutableArray array];
//
//    WhiteListModel *wModel = [[WhiteListModel alloc]init];
//    wModel.updateType = deleteRecord;
//    wModel.userId = 10;
//    wModel.userType = type_dept;
//    wModel.whiteUserId = 99;
//    [whiteList addObject:wModel];
//    [wModel release];
    
    
    [self saveToDB:specialList andWhiteList:whiteList];
    
}

@end
