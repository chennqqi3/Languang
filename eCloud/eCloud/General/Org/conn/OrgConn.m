
#import "OrgConn.h"
#import "StringUtil.h"
#import "conn.h"
#import "LogUtil.h"
#import "UserDataConn.h"
#import "ZipArchive.h"
#import "OrgSyncTypeAck.h"
#import "EmpDeptDL.h"
#import "eCloudUser.h"
#import "eCloudDAO.h"

#import "eCloudConfig.h"
#import "eCloudNotification.h"
#import "NotificationUtil.h"
#import "UserDataConn.h"

static OrgConn *orgConn;

@interface OrgConn (){
    
}
//收到的部门隐藏配置的页数
@property (nonatomic,assign) int curDeptShowConfigPage;

//收到的部门隐藏配置数据
@property (nonatomic,retain) NSMutableArray *deptShowConfigArray;


@end

@implementation OrgConn
{
    int downloadFileStartTime;
}

@synthesize curDeptShowConfigPage;
@synthesize deptShowConfigArray;

@synthesize orgSyncTypeAck;

- (void)dealloc
{
    self.deptShowConfigArray = nil;
    self.orgSyncTypeAck = nil;
    [super dealloc];
}

+ (OrgConn *)getConn
{
    if (!orgConn) {
        orgConn = [[super alloc]init];
    }
    return orgConn;
}

#pragma mark =======同步方式请求及应答处理=========

/** 查看组织架构同步方式 包含部门及员工与部门关系 */
- (void)getOrgSyncType
{
    self.orgSyncTypeAck = nil;
    
    conn *_conn = [conn getConn];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s, 部门 old time is %@ , new time is %@",__FUNCTION__,_conn.oldDeptUpdateTime,_conn.deptUpdateTime]];
    [LogUtil debug:[NSString stringWithFormat:@"%s, 员工与部门关系 old time is %@ , new time is %@",__FUNCTION__,_conn.oldEmpDeptUpdateTime,_conn.empDeptUpdateTime]];

    /** 看部门是否需要同步 */
    int needSyncDept = 0;
    if (_conn.oldDeptUpdateTime.intValue < _conn.deptUpdateTime.intValue) {
        needSyncDept = 1;
    }

    /** 看员工资料是否需要同步 */
    int needSyncEmpDept = 0;
    if (_conn.oldEmpDeptUpdateTime.intValue < _conn.empDeptUpdateTime.intValue) {
        needSyncEmpDept = 1;
    }
    
//
    BOOL needGetSyncType = NO;
    
    GETDATALISTTYPEPARAMETET info;
    memset(&info, 0, sizeof(info));
    
    if (needSyncDept == 1) {
        needGetSyncType = YES;
        info.cUpdataTypeDept = 1;
        info.dwLastUpdateTimeDept = _conn.oldDeptUpdateTime.intValue;
    }
    else
    {
        info.cUpdataTypeDept = 0;
    }
    
    if (needSyncEmpDept == 1) {
        needGetSyncType = YES;
        info.cUpdataTypeDeptUser = 1;
        info.dwLastUpdateTimeDeptUser = _conn.oldEmpDeptUpdateTime.intValue;
    }
    else
    {
        info.cUpdataTypeDeptUser = 0;
    }
    
    if (needGetSyncType) {

        /** 不同步用户资料，只获取部门和员工与部门关系的同步方式 */
        info.cUpdataTypeUser = 0;
        info.nTermType = TERMINAL_IOS;
        info.nNetType = 0;
        
        CLIENT_GETDATALISTTYPE([_conn getConnCB],&info);
//        [LogUtil debug:@"获取组织架构同步类型"];
    }
    else
    {
        [LogUtil debug:@"不需要同步组织架构，开始同步固定群组"];
        [[UserDataConn getConn]sendSystemGroupSync];
    }
}

/** 处理应答 */
- (void)processGetOrgSyncTypeAck:(GETDATALISTTYPEACK *)info
{
    conn *_conn = [conn getConn];
    int result = info->result;
    if (result == RESULT_SUCCESS) {
        
        OrgSyncTypeAck *_orgSyncTypeAck = [[OrgSyncTypeAck alloc]init];

        /** 确定部门同步方式 */
        int syncTypeDept = info->cDownLoadTypeDept;
        
        if (syncTypeDept == sync_type_file) {
            
            NSString *filePath = [StringUtil getStringByCString:(char *)info->strDownLoadPathDept];
            NSString *filePassword = [StringUtil getStringByCString:(char *)info->strFilePwdDept];

            [LogUtil debug:[NSString stringWithFormat:@"文件方式同步部门 文件路径为:%@ 解密密码为:%@",filePath,filePassword]];
            
            if (filePath.length > 0 && filePassword.length > 0) {

                /** 文件方式 */
                _orgSyncTypeAck.filePathDept = filePath;
                _orgSyncTypeAck.filePasswordDept = filePassword;
                
                _orgSyncTypeAck.fileTypeDept = info->cUpdataTypeDept;
                _orgSyncTypeAck.updateTimeDept = info->dwLastUpdateTimeDept;
            }
            else
            {
                /** 文件路径或密码无效，仍采用数据包方式 */
                syncTypeDept = sync_type_packet;
            }
        }
        
        if (syncTypeDept == sync_type_packet) {
            [LogUtil debug:@"数据包方式同步部门"];
        }

        _orgSyncTypeAck.syncTypeDept = syncTypeDept;
        
        /** 确定员工与部门关系同步方式 */
        int syncTypeEmpDept = info->cDownLoadTypeDeptUser;
        
        if (syncTypeEmpDept == sync_type_file) {
            
            NSString *filePath = [StringUtil getStringByCString:(char *)info->strDownLoadPathDeptUser];
            NSString *filePassword = [StringUtil getStringByCString:(char *)info->strFilePwdDeptUser];
            
            [LogUtil debug:[NSString stringWithFormat:@"文件方式同步员工部门 文件路径为:%@ 解密密码为:%@",filePath,filePassword]];
            
            if (filePath.length > 0 && filePassword.length > 0) {

                /** 文件方式 */
                _orgSyncTypeAck.filePathEmpDept = filePath;
                _orgSyncTypeAck.filePasswordEmpDept = filePassword;
                
                _orgSyncTypeAck.fileTypeEmpDept = info->cUpdataTypeDeptUser;
                _orgSyncTypeAck.updateTimeEmpDept = info->dwLastUpdateTimeDeptuser;
            }
            else
            {
                /** 文件路径或密码无效，仍采用数据包方式 */
                syncTypeEmpDept = sync_type_packet;
            }
        }
        
        if (syncTypeEmpDept == sync_type_packet) {
            [LogUtil debug:@"数据包方式同步员工与部门关系"];
        }
        _orgSyncTypeAck.syncTypeEmpDept = syncTypeEmpDept;
        
        self.orgSyncTypeAck = _orgSyncTypeAck;
        
        [_orgSyncTypeAck release];
        
        [self syncDept];
    }
    else
    {
        /**  如果获取失败，走原来的流程 */
        [_conn getDeptInfo:nil];
    }
}


#pragma mark ========部门数据同步=========

#define dept_zip_file_name @"dept.zip"

- (NSString *)getDeptZipFilePath
{
    return [[StringUtil getFileDir]stringByAppendingPathComponent:dept_zip_file_name];
}

- (NSString *)getDeptFilePath
{
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[StringUtil getFileDir]];
    
    NSString *file;
    while ((file = [dirEnum nextObject]))
    {
        /**  是txt文件 并且 包含_dept_ */
        if(file && ([[file pathExtension] isEqualToString:@"txt"] && [file rangeOfString:@"_dept_"].length > 0))
        {
            return [[StringUtil getFileDir]stringByAppendingPathComponent:file];
        }
    }
    return nil;
}

/** 新的同步部门 */
- (void)syncDept
{
    conn *_conn = [conn getConn];

    if ([_conn.oldDeptUpdateTime isEqualToString:_conn.deptUpdateTime])
    {
        /** 同步员工与部门关系 */
        [self syncEmpDept];
    }
    else
    {
        if (self.orgSyncTypeAck.syncTypeDept == sync_type_packet)
        {
            /** 数据包方式 */
            [_conn getDeptInfo:nil];
        }
        else
        {
            _conn.timeStart = [[NSDate date] timeIntervalSince1970];
            
            /** 下载文件 */
            NSData *deptZipData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.orgSyncTypeAck.filePathDept]];
            
            if (deptZipData.length > 0)
            {
                /** 保存数据 */
                NSString *zipFilePath = [self getDeptZipFilePath];
                if ([deptZipData writeToFile:zipFilePath atomically:YES])
                {
                    /** 解压数据 */
                    ZipArchive *zipArchive = [[ZipArchive alloc]init];
                    
                    BOOL unzipResult = [zipArchive UnzipOpenFile:zipFilePath Password:self.orgSyncTypeAck.filePasswordDept];
                    if (unzipResult)
                    {
                        unzipResult = [zipArchive UnzipFileTo:[StringUtil getFileDir] overWrite:YES];
                        if (unzipResult)
                        {
//                            NSLog(@"解压数据库文件成功");
                        }
                        [zipArchive CloseZipFile2];
                    }
                    
                    [zipArchive release];

                    /** 找目录下 */
                    if (unzipResult)
                    {
                        NSString *deptFilePath = [self getDeptFilePath];
                        [LogUtil debug:[NSString stringWithFormat:@"解压后的部门文件路径为%@",deptFilePath]];
                        
                        if (deptFilePath)
                        {
                            BOOL success = [self parseAndSaveDeptData:deptFilePath];
                            if (success)
                            {
                                /** 解析保存部门成功，开始处理员工与部门关系 */
                                [self syncEmpDept];
                            }
                            else
                            {
                                //
                                [_conn getDeptInfo:nil];
                            }
                        }
                        else
                        {
                            /** 没有解压成功 */
                            [_conn getDeptInfo:nil];
                        }

                        /** 处理完成后，需要删除压缩文件 和 解压后的文件 */
                        [[NSFileManager defaultManager]removeItemAtPath:deptFilePath error:nil];
                    }
                    else
                    {
                        /** 解压失败 */
                        [_conn getDeptInfo:nil];
                    }

                    [[NSFileManager defaultManager]removeItemAtPath:zipFilePath error:nil];

                }
                else
                {
                    /** 保存文件失败 */
                    [_conn getDeptInfo:nil];
                }
            }
            else
            {
                /** 没有取到文件 */
                [_conn getDeptInfo:nil];
            }
        }
    }
}

/** 部门ID|父部门ID|部门中文名称|部门英文名称|更新类型|部门排序|部门电话 */
/** 解析 保存 部门数据 */
- (BOOL)parseAndSaveDeptData:(NSString *)deptFilePath
{
    conn *_conn = [conn getConn];
    
    long long start = [StringUtil currentMillionSecond];
    
    NSData *orgData = [NSData dataWithContentsOfFile:deptFilePath];
    
    NSString *orgStr = [[NSString alloc]initWithData:orgData encoding:NSUTF8StringEncoding];

    NSArray *orgArray = [orgStr componentsSeparatedByString:@"\n"];

    /** 保存解析出来的数据 */
    NSMutableArray *mOrgArray = [NSMutableArray array];
    
//    NSLog(@"总部门数:%d",orgArray.count);
    
    for (int i = 0; i < orgArray.count; i++) {
        
        NSString *tempStr = [orgArray objectAtIndex:i];
        
        NSArray *tempArray = [tempStr componentsSeparatedByString:@"|"];
        
        int tempCount = tempArray.count;
        
        if (tempCount >= 7) {
            
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            for (int j = 0; j < tempCount; j++) {
                switch (j) {
                    case 0:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_id"];
                    }
                        break;
                    case 1:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_parent"];
                    }
                        break;
                    case 2:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_name"];
                    }
                        break;
                    case 3:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_name_eng"];
                    }
                        break;
                    case 4:
                    {
                        [mDic setValue:[NSNumber numberWithInt:[[tempArray objectAtIndex:j]intValue]] forKey:@"update_type"];
                    }
                        break;
                    case 5:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_sort"];
                    }
                        break;
                    case 6:
                    {
                        [mDic setValue:[tempArray objectAtIndex:j] forKey:@"dept_tel"];
                    }
                        break;
                    default:
                        break;
                }
            }
            [mOrgArray addObject:mDic];
            
//            NSLog(@"%@",[mDic description]);
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"需要时间:%lld,解析出来的部门数:%d",[StringUtil currentMillionSecond] - start,mOrgArray.count]];
    
    if (mOrgArray.count > 0) {
        _conn.deptArray = [NSMutableArray arrayWithArray:mOrgArray];
        
        if ([_conn saveDept]) {
            
            /** 保存时间 */
            _conn.deptUpdateTime = [StringUtil getStringValue:self.orgSyncTypeAck.updateTimeDept];
            [[eCloudUser getDatabase]saveDeptUpdateTime:nil];

            return YES;
        }
        else
        {
            /** 保存失败 */
            [LogUtil debug:@"保存部门失败"];
            return NO;
        }
    }
    else
    {
//
        [LogUtil debug:@"解析出来的部门数据为空"];
        return NO;
    }
    //
    
//        for (int i = 0; i < orgStr.length; i++) {
//            NSString *tempStr = [orgStr substringWithRange:NSMakeRange(i, 1)];
//            if ([tempStr isEqualToString:@"\n"]) {
//                NSLog(@"遇到了换行符,%d",i);
//            }
//            else if ([tempStr isEqualToString:@"\r"])
//            {
//                NSLog(@"遇到了回车符,%d",i);
//            }
//            if (i > 100) {
//                break;
//            }
//        }
    //    NSLog(@"%@,%@",orgPath,_str);
}

#pragma mark =========员工与部门关系同步==========

#define emp_dept_zip_file_name @"emp_dept.zip"

- (NSString *)getEmpDeptZipFilePath
{
    return [[StringUtil getFileDir]stringByAppendingPathComponent:emp_dept_zip_file_name];
}

- (NSString *)getEmpDeptFilePath
{
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[StringUtil getFileDir]];
    
    NSString *file;
    while ((file = [dirEnum nextObject]))
    {
        /** 是txt文件 并且 包含_dept_ */
        if(file && ([[file pathExtension] isEqualToString:@"txt"] && [file rangeOfString:@"_deptuser_"].length > 0))
        {
            return [[StringUtil getFileDir]stringByAppendingPathComponent:file];
        }
    }
    return nil;
}

/** 新的同步部门 */
- (void)syncEmpDept
{
    conn *_conn = [conn getConn];
    
    if ([_conn.oldEmpDeptUpdateTime isEqualToString:_conn.empDeptUpdateTime])
    {
        /** 同步固定群组 */
        [[UserDataConn getConn]sendSystemGroupSync];
    }
    else
    {
        if (self.orgSyncTypeAck.syncTypeEmpDept == sync_type_packet)
        {
            
            /** 数据包方式 */
            [_conn getEmpDeptInfo:nil];
        }
        else
        {
            _conn.timeStart = [[NSDate date] timeIntervalSince1970];

            /** 下载文件 */
            NSData *zipData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.orgSyncTypeAck.filePathEmpDept]];
            
            if (zipData.length > 0)
            {

                /** 保存数据 */
                NSString *zipFilePath = [self getEmpDeptZipFilePath];
                if ([zipData writeToFile:zipFilePath atomically:YES])
                {
                    /** 解压数据 */
                    ZipArchive *zipArchive = [[ZipArchive alloc]init];
                    
                    BOOL unzipResult = [zipArchive UnzipOpenFile:zipFilePath Password:self.orgSyncTypeAck.filePasswordEmpDept];
                    if (unzipResult)
                    {
                        unzipResult = [zipArchive UnzipFileTo:[StringUtil getFileDir] overWrite:YES];
                        if (unzipResult)
                        {
//                            NSLog(@"解压数据库文件成功");
                        }
                        [zipArchive CloseZipFile2];
                    }
                    
                    [zipArchive release];

                    /** 找目录下 */
                    if (unzipResult)
                    {
                        NSString *empDeptFilePath = [self getEmpDeptFilePath];
                        [LogUtil debug:[NSString stringWithFormat:@"解压后的员工与部门关系文件路径为%@",empDeptFilePath]];
                        
                        if (empDeptFilePath)
                        {
                            BOOL success = [self parseAndSaveEmpDeptData:empDeptFilePath];
                            if (success)
                            {
                                /** 解析保存员工与部门关系成功，开始同步固定群组 */
                                [[UserDataConn getConn]sendSystemGroupSync];
                            }
                            else
                            {
                                
                                [_conn getEmpDeptInfo:nil];
                            }
                            
                        }
                        else
                        {
                    
                            /** 没有解压成功 */
                            [_conn getEmpDeptInfo:nil];
                        }

                        /** 处理完成后，需要删除解压后的文件 */
                        [[NSFileManager defaultManager]removeItemAtPath:empDeptFilePath error:nil];
                    }
                    else
                    {
                        /** 解压失败 */
                        [_conn getEmpDeptInfo:nil];
                    }
                    
                    /** 删除压缩的文件 */
                    [[NSFileManager defaultManager]removeItemAtPath:zipFilePath error:nil];
                }
                else
                {
                    /** 保存文件失败 */
                    [_conn getEmpDeptInfo:nil];
                }
            }
            else
            {
                /** 没有取到文件 */
                [_conn getEmpDeptInfo:nil];
            }
            
        }
    }
}

/** 解析 保存 员工与部门关系数据 */
- (BOOL)parseAndSaveEmpDeptData:(NSString *)filePath
{
    conn *_conn = [conn getConn];
    
    long long start = [StringUtil currentMillionSecond];
    
    NSData *orgData = [NSData dataWithContentsOfFile:filePath];
    
    NSString *orgStr = [[NSString alloc]initWithData:orgData encoding:NSUTF8StringEncoding];
    
    NSArray *orgArray = [orgStr componentsSeparatedByString:@"\n"];

    /** 保存解析出来的数据 */
    NSMutableArray *mOrgArray = [NSMutableArray array];
    
    //    NSLog(@"总部门数:%d",orgArray.count);
    
    for (int i = 0; i < orgArray.count; i++) {
        
        NSString *tempStr = [orgArray objectAtIndex:i];
        
        NSArray *tempArray = [tempStr componentsSeparatedByString:@"|"];
        
        int tempCount = tempArray.count;
        
        if (tempCount >= 7) {
            
            EmpDeptDL *_empDeptDl = [[EmpDeptDL alloc]init];
            _empDeptDl.empLogo = @"0";
            _empDeptDl.rankId = 0;
            _empDeptDl.profId = 0;
            _empDeptDl.areaId = 0;

            /** 部门ID|用户ID|用户工号|用户中文名|用户英文名|性别|排序|更新类型|最后更新时间|本人级别|本人业务|本人地域|头像路径 */
            for (int j = 0; j < tempCount; j++) {
                NSString *curStr = [tempArray objectAtIndex:j];
                switch (j) {
                    case 0:
                    {
                        _empDeptDl.deptId = [curStr intValue];
                    }
                        break;
                    case 1:
                    {
                        _empDeptDl.empId = [curStr intValue];
                    }
                        break;
                    case 2:
                    {
                        _empDeptDl.empCode = curStr;
                    }
                        break;
                    case 3:
                    {
                        _empDeptDl.empName = curStr;
                    }
                        break;
                    case 4:
                    {
                        _empDeptDl.empNameEng = curStr;
                    }
                        break;
                    case 5:
                    {
                        _empDeptDl.empSex = [curStr intValue];
                    }
                        break;
                    case 6:
                    {
                        _empDeptDl.empSort = [curStr intValue];
                    }
                        break;
                    case 7:
                    {
                        _empDeptDl.updateType = [curStr intValue];
                    }
                        break;
                    default:
                        break;
                }
            }
            [mOrgArray addObject:_empDeptDl];
            [_empDeptDl release];
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"需要时间:%lld,解析出来的员工与部门关系总数:%d",[StringUtil currentMillionSecond] - start,mOrgArray.count]];
    
    if (mOrgArray.count > 0) {
        _conn.empDeptArray = [NSMutableArray arrayWithArray:mOrgArray];
        
        if ([_conn saveEmpDept2]) {
            
            /** 保存时间 */
            _conn.empDeptUpdateTime = [StringUtil getStringValue:self.orgSyncTypeAck.updateTimeEmpDept];
            [[eCloudUser getDatabase]saveEmpDeptUpdateTime:nil];
            return YES;
        }
        else
        {
            /** 保存失败 */
            [LogUtil debug:@"保存员工部门失败"];
            return NO;
        }
    }
    else
    {
        
        [LogUtil debug:@"解析出来的员工与部门关系数据为空"];
        return NO;
    }
}


#pragma mark ========获取和处理部门隐藏配置========
//获取有哪些部门隐藏
- (void)syncDeptShowConfig
{
    if ([eCloudConfig getConfig].needSyncDeptShowConfig) {
        [LogUtil debug:[NSString stringWithFormat:@"%s oldDeptShowConfigUpdateTime is %d",__FUNCTION__,[conn getConn].oldDeptShowConfigUpdateTime]];
        
        conn *_conn = [conn getConn];
        int ret = CLIENT_GetDeptShowConfig([_conn getConnCB], _conn.oldDeptShowConfigUpdateTime, TERMINAL_IOS);
        
        //        int ret = CLIENT_GetDeptShowConfig([_conn getConnCB], 0, TERMINAL_IOS);
        if (ret == RESULT_SUCCESS) {
            self.curDeptShowConfigPage = 0;
            self.deptShowConfigArray = [NSMutableArray array];
            //            启动超时
            _conn.isSyncDeptShowTimeout = NO;
            _conn.isSyncDeptShowCmd = YES;
            [_conn startTimeoutTimer:5];
        }else{
            //        同步员工与部门关系
            [[conn getConn]getEmpDeptInfo:nil];
        }
    }else{
        //        同步员工与部门关系
        [[conn getConn]getEmpDeptInfo:nil];
    }
}

//解析部门隐藏的返回结果
- (void)processDeptShowConfig:(GETDEPTSHOWCONFIGACK *)getDeptShowConfigAck
{
    conn *_conn = [conn getConn];
    
    _conn.isSyncDeptShowCmd = NO;
    [_conn stopTimeoutTimer];
    
    //    cUpdateFlag 0:配置未更改，不需要更新，1：配置更改了，需要更新
    if (getDeptShowConfigAck->cUpdateFlag == 0) {
        [LogUtil debug:@"部门显示配置没有更新,直接同步员工与部门关系"];
        [[conn getConn]getEmpDeptInfo:nil];
        return;
    }
    
    //0：默认为0(全部不显示)，2：默认为2(全部显示)
    int defaultShowLevel = getDeptShowConfigAck->cDefaultShowLevel;
    if (defaultShowLevel == 0) {
        [LogUtil debug:@"部门默认为全部隐藏"];
    }else{
        [LogUtil debug:@"部门默认为全部显示"];
    }
    
    //    最新时间戳
    int newDeptShowConfigUpdateTime = getDeptShowConfigAck->dwUpdateTime;
    //    [LogUtil debug:[NSString stringWithFormat:@"%s updatetime is %d",__FUNCTION__,newDeptShowConfigUpdateTime]];
    
    self.curDeptShowConfigPage++;
    
    [LogUtil debug:[NSString stringWithFormat:@"当前页数%d，当前页包含记录个数:%d",self.curDeptShowConfigPage,getDeptShowConfigAck->wCurrNum]];
    
    //    解析内容
    int num = getDeptShowConfigAck->wCurrNum;
    unsigned int startPos = 0;
    SINGLEDEPTSHOWLEVEL singleDeptShowLevel;
    int iCount = 0;
    
    //		解析过程中是否出错
    bool hasError = false;
    
    if (num) {
        //        大于0时才去解析
        //		解析是否完成
        bool finish = false;
        while (!finish)
        {
            int ret = CLIENT_ParseDeptShowConfig(getDeptShowConfigAck->strPacketBuff, &startPos, &singleDeptShowLevel);
            switch(ret)
            {
                case EIMERR_PARSE_FINISHED:
                {//正常结束
                    finish = true;
                }
                    break;
                case EIMERR_SUCCESS:
                {//解析数据并且保存
                    
                    int deptId = singleDeptShowLevel.dwDeptID;
                    int showLevel = singleDeptShowLevel.cShowLevel;
                    iCount ++;
                    
                    NSLog(@"%s deptId is %d showLevel is %d",__FUNCTION__,deptId,showLevel);
                    [self.deptShowConfigArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:deptId],@"dept_id",[NSNumber numberWithInt:showLevel],@"show_level", nil]];
                }
                    break;
                case EIMERR_INVALID_PARAMTER:
                {//异常结束，参数有错
                    [LogUtil debug:[NSString stringWithFormat:@"Parameter error"]];
                    hasError = true;
                    finish = true;
                }
                    break;
                case EIMERR_PACKAGE_ERROR:
                {//异常结束，报文有错
                    [LogUtil debug:[NSString stringWithFormat:@"Package error"]];
                    hasError = true;
                    finish = true;
                }
                    break;
            }
        }
    }
    
    if(hasError)
    {
        [LogUtil debug:[NSString stringWithFormat:@"没有解析完成，需要重新获取"]];
        [[conn getConn] downloadOrgError:@"获取部门显示配置数据有误，直接获取员工与部门关系"];
        //            设置为YES时，如果再收到错误的应答 也不再处理了
        _conn.isSyncDeptShowTimeout = YES;
        [_conn getEmpDeptInfo:nil];
    }
    else
    {
        if(num != iCount)
        {
            [LogUtil debug:[NSString stringWithFormat:@"解析完成，但数据不一致"]];
            [[conn getConn] downloadOrgError:@"获取部门显示配置数据有误，直接获取员工与部门关系"];
            //            设置为YES时，如果再收到错误的应答 也不再处理了
            _conn.isSyncDeptShowTimeout = YES;
            [_conn getEmpDeptInfo:nil];
        }
        else
        {
            //		保存同步结果
            if(getDeptShowConfigAck->wCurrPage == 0)
            {
                [LogUtil debug:[NSString stringWithFormat:@"部门显示配置总页数:%d",self.curDeptShowConfigPage]];
                
                //                    保存部门显示配置数据 首先保存默认值 再保存特殊值
                BOOL result1 = [[eCloudDAO getDatabase]updateAllDeptWithDisplayFlag:defaultShowLevel];
                
                BOOL result2 = [[eCloudDAO getDatabase]updatePartDeptDisplayFlags:self.deptShowConfigArray];
                
                if (result1 && result2) {
                    //                        保存成功后 保存时间戳
                    [conn getConn].newDeptShowConfigUpdateTime = newDeptShowConfigUpdateTime;
                    
                    [[eCloudUser getDatabase]saveDeptShowConfigUpdateTime];
                }
                
                [[conn getConn]getEmpDeptInfo:nil];
            }
        }
    }
}
#pragma mark ====祥源获取部门显示配置=====
- (void)getXYDeptShowConfig{
    
    //    旧的部门隐藏时间戳
    int oldDeptShowConfigUpdateTime = [conn getConn].oldDeptShowConfigUpdateTime;
    
    //    当前服务器时间
    int interval = [[conn getConn]getCurrentTime];
    
    NSString *tempStr = [NSString stringWithFormat:@"%d%@%@",interval,[conn getConn].userId,md5_password];
    NSString *md5Str = [StringUtil getMD5Str:tempStr];
    
    //    祥源获取部门显示配置的url
    NSString *urlString = [[ServerConfig shareServerConfig]getXYDeptShowConfigUrl];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s oldDeptShowConfigUpdateTime is %d url is %@",__FUNCTION__,oldDeptShowConfigUpdateTime,urlString]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{@"Content-Type":@"application/json"};
    request.timeoutInterval = [StringUtil getRequestTimeout];
    
    NSDictionary *dic = @{@"t":@(interval),@"updatetime":@(oldDeptShowConfigUpdateTime),@"userid":[conn getConn].userId,@"mdkey":md5Str,@"terminal":@(TERMINAL_IOS)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    // 将字符串转换成数据
    
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取到了祥源的部门配置 %@ %@",__FUNCTION__,response,error]];
    
    if (response.statusCode == 200) {
        NSDictionary *responseDic = [retData objectFromJSONData];
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取到了祥源的部门配置 %@",__FUNCTION__,responseDic]];
        
        if ([responseDic[@"status"]intValue] == 0) {
            
            NSArray *tempArray = responseDic[@"result"];
            //                    显示的部门
            NSMutableArray *mArrayDisplay = [NSMutableArray array];
            //                    不显示的部门
            NSMutableArray *mArrayHide = [NSMutableArray array];
            
            for (NSDictionary *tempDic in tempArray) {
                int deptId = [tempDic[@"deptid"]intValue];
                
                NSDictionary *dic = [[eCloudDAO getDatabase]searchDept:[StringUtil getStringValue:deptId]];
                int updateType = [tempDic[@"updateType"]intValue];
                
                if (updateType == insertRecord) {
                    [mArrayDisplay addObject:[NSNumber numberWithInt:deptId]];
                }else{
                    [mArrayHide addObject:[NSNumber numberWithInt:deptId]];
                }
                [LogUtil debug:[NSString stringWithFormat:@"%s 部门 %d %@ updatetype %d",__FUNCTION__,deptId,dic[@"dept_name"],updateType]];
            }
            
            if (tempArray.count == 0) {
                if (oldDeptShowConfigUpdateTime == 0) {
                    /** 第一次获取部门显示配置  但没有要显示的部门，因此显示默认部门*/
                    if (mArrayDisplay.count == 0) {
                        /** 隐藏所有部门 */
                        BOOL result1 = [[eCloudDAO getDatabase]updateAllDeptWithDisplayFlag:dept_display_type_hide];
                        
                        /** 只显示自己所在部门的二级部门 */
                        [[eCloudDAO getDatabase]dspDefaultDept];
                    }
                }else{
                    //                    没有变化，不用处理
                }
            }else{
                if (oldDeptShowConfigUpdateTime == 0) {
                    
                    /** 隐藏所有部门 */
                    BOOL result1 = [[eCloudDAO getDatabase]updateAllDeptWithDisplayFlag:dept_display_type_hide];
                    
                    if (mArrayDisplay.count == 0) {
                        //                        没有要显示的部门，显示默认部门
                        [[eCloudDAO getDatabase]dspDefaultDept];
                    }else{
                        /** 显示收到的部门 */
                        for (NSNumber *deptId in mArrayDisplay) {
                            //                                    显示部门的父节点和子节点
                            [[eCloudDAO getDatabase]displayParentDeptAndSubDept:deptId.intValue];
                        }
                    }
                }else{
                    /** 删除部门 */
                    for (NSNumber *deptId in mArrayHide) {
                        [[eCloudDAO getDatabase]hideDeptAndSubDept:deptId.intValue];
                    }
                    /** 添加部门 */
                    for (NSNumber *deptId in mArrayDisplay) {
                        //                                显示部门的父节点和子节点
                        [[eCloudDAO getDatabase]displayParentDeptAndSubDept:deptId.intValue];
                    }
                }
            }
            
            //                        保存成功后 保存时间戳
            [conn getConn].newDeptShowConfigUpdateTime = [[conn getConn]getCurrentTime];
            
            [[eCloudUser getDatabase]saveDeptShowConfigUpdateTime];
        }else{
            if ([conn getConn].oldDeptShowConfigUpdateTime == 0) {
//                显示默认的
                /** 隐藏所有部门 */
                BOOL result1 = [[eCloudDAO getDatabase]updateAllDeptWithDisplayFlag:dept_display_type_hide];
                
                /** 只显示自己所在部门的二级部门 */
                [[eCloudDAO getDatabase]dspDefaultDept];
            }
        }
        
    }else{
        if ([conn getConn].oldDeptShowConfigUpdateTime == 0) {
//            显示默认的
            /** 隐藏所有部门 */
            BOOL result1 = [[eCloudDAO getDatabase]updateAllDeptWithDisplayFlag:dept_display_type_hide];
            
            /** 只显示自己所在部门的二级部门 */
            [[eCloudDAO getDatabase]dspDefaultDept];

        }
    }
}

@end
