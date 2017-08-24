
#import "QueryDAO.h"
#import "eCloudConfig.h"
#import "eCloudDefine.h"
#import "talkSessionUtil.h"

#import "Conversation.h"
#import "eCloudDAO.h"
#import "QueryResultCell.h"
#import "StringUtil.h"
#import "conn.h"
#import "ConvRecord.h"
#import "Emp.h"
#ifdef _LANGUANG_FLAG_
#import "MiLiaoUtilArc.h"
#endif
static QueryDAO *queryDAO;

@implementation QueryDAO

+ (QueryDAO *)getDatabase
{
    if (queryDAO == nil) {
        queryDAO = [[self alloc]init];
    }
    return queryDAO;
}

#pragma mark 查找会话记录表，找到包含查询条件的文本类型的消息，如果某个会话只包含了一条，则直接返回匹配的这条消息，如果包含了多条，则显示n条记录，生成对应的Conversation对象，放到数组里返回用来在界面上展示
-(NSArray *)getConversationBySearchConvRecord:(NSString *)searchStr
{
    int startTime = [[StringUtil currentTime]intValue];
    NSMutableArray *convArray = [NSMutableArray array];
    
    NSString *sql1 = [NSString stringWithFormat:@"(select count(conv_id) as _count,conv_id,msg_body,id as msgId from %@ where msg_type = %d and msg_body like ? group by conv_id)",table_conv_records,type_text];
    
    NSString *sql2 = [NSString stringWithFormat:@"select a.*,b.*, 'Y' as display_merge_logo from %@ a,%@ b where a.conv_id = b.conv_id order by b.last_msg_time desc",sql1,table_conversation];
    
    sqlite3_stmt *stmt = nil;
    
    //		编译
    pthread_mutex_lock(&add_mutex);
    int state = sqlite3_prepare_v2(_handle, [sql2 UTF8String], -1, &stmt, nil);
    pthread_mutex_unlock(&add_mutex);
    
    if(state != SQLITE_OK)
    {
        //			编译错误
        [LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
        //			释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        return nil;
    }
    
    //		绑定值
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string
    
    NSMutableArray *result = [NSMutableArray array];
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);

    
    for (NSDictionary *dic in result)
    {
        Conversation *conv = [[Conversation alloc]init];

        [self putDic:dic toConversation:conv];
        
//        NSLog(@"%s,convType is %d,convId is %@",__FUNCTION__,conv.conv_type,conv.conv_id);

        ConvRecord *_convRecord = [[ConvRecord alloc]init];
        _convRecord.msg_type = type_text;
        
        int _count = [[dic valueForKey:@"_count"]intValue];
        _convRecord.tryCount = _count;
        if (_count > 0)
        {
            if (_count == 1)
            {
                _convRecord.msgId = [[dic valueForKey:@"msgId"]intValue];
                _convRecord.msg_body = [dic valueForKey:@"msg_body"];
                
                [talkSessionUtil preProcessRobotMsg:_convRecord];
                [talkSessionUtil preProcessTextMsg:_convRecord];
                [talkSessionUtil preProcessredPacketMsg:_convRecord];
            }
            else
            {
                _convRecord.msg_body = [NSString stringWithFormat:[StringUtil getLocalizableString:@"search_result_record_count"],_count];
            }
        }
        conv.last_record = _convRecord;
        [_convRecord release];
        
        [convArray addObject:conv];
        [conv release];        
    }
    NSLog(@"匹配会话记录需要的时间:%d",[[StringUtil currentTime]intValue] - startTime);
    return convArray;
}

#pragma mark 
- (void)putDic:(NSDictionary *)dic toConversation:(Conversation *)conv
{
    conv.conv_id = [dic objectForKey:@"conv_id"];
	conv.conv_type = [[dic objectForKey:@"conv_type"]intValue];
	conv.conv_title = [dic objectForKey:@"conv_title"];
	conv.conv_remark = [dic objectForKey:@"conv_remark"];
    conv.create_time = [dic objectForKey:@"create_time"];
	conv.recv_flag = [[dic objectForKey:@"recv_flag"]intValue];
    conv.last_msg_id=[[dic objectForKey:@"last_msg_id"]intValue];
    
    [[eCloudDAO getDatabase]processAboutGroupMergedLogoWithConversation:conv andDicData:dic];

    if (conv.conv_type==singleType || conv.conv_type == rcvMassType)
	{//单人会话
        eCloudDAO *ecloudDAO = [eCloudDAO getDatabase];
        
        NSString *_convId = conv.conv_id;
//        如果是收到的一呼万应消息，也要根据人员 显示头像或默认头像
        if (conv.conv_type == rcvMassType) {
            NSString *_str = [NSString stringWithString:conv.conv_id];
            NSRange _range = [_str rangeOfString:@"|"];
            if (_range.length > 0) {
                _convId = [_str substringFromIndex:_range.location + 1];
            }
        }
        
		Emp *emp = [ecloudDAO getEmployeeById:[StringUtil getStringValue:_convId.intValue]];
		
		if(emp)
		{
			conv.emp=emp;
			if(emp.emp_name && emp.emp_name.length > 0)
			{
				conv.conv_title = emp.emp_name;
			}
			else
			{
				conv.conv_title = emp.empCode;
			}
		}
		else
		{
			//			add by shisp 如果发来消息的员工在本地没有，那么创建一个空的
			Emp *_emp = [[Emp alloc]init];
			_emp.emp_id = _convId.intValue;
			conv.emp = _emp;
			[_emp release];
		}
    }
}

#pragma mark 如果某个会话包含了多条匹配查询条件的记录，则点击后可以展开更详细的查询结果，下面的方法就是查询某会话的每一条匹配的记录，并且按照时间倒叙排列，显示在二级查询结果界面上，还有一个是偏移量
- (NSArray *)getSearchResultsByConversation:(Conversation *)conv andSearchStr:(NSString *)searchStr
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and msg_type = %d and (msg_body like ? )  order by msg_time desc,id desc ",table_conv_records ,conv.conv_id,type_text];
    
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
        return nil;
    }
    
    //		绑定值
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string
    
    NSMutableArray *result = [NSMutableArray array];
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);

    if (result && result.count > 0) {
     
        NSMutableArray *queryResults = [NSMutableArray arrayWithCapacity:result.count];
        
        for (NSDictionary *dic in result) {
//            NSLog(@"%s,%@",__FUNCTION__,[dic description]);
            
            Conversation *_conv = [[Conversation alloc]initWithConversation:conv];
            
            //            用来显示消息时间，消息内容
            ConvRecord *_convRecord = [[ConvRecord alloc]init];
            _convRecord.msgId = [[dic valueForKey:@"id"]intValue];
            _convRecord.msg_time = [dic valueForKey:@"msg_time"];
            _convRecord.msg_type = type_text;
            _convRecord.msg_body = [dic valueForKey:@"msg_body"];
            
            _convRecord.msgTimeDisplay = [StringUtil getDisplayTime_day:_convRecord.msg_time];

            [talkSessionUtil preProcessTextMsg:_convRecord];
            [talkSessionUtil preProcessRobotMsg:_convRecord];
            [talkSessionUtil preProcessredPacketMsg:_convRecord];
            _conv.last_record = _convRecord;
            [_convRecord release];
            
            [queryResults addObject:_conv];
            
            [_conv release];

        }
        return queryResults;
    }
    return nil;
}

#pragma mark 点击某一条具体的查询结果，显示聊天界面，但是要定位在对应的记录，下面的方法就是返回多一些属性，便于实现这种展示效果，参数就是对应的某一条具体的查询结果
#pragma mark 返回一个Dic，包含要在界面上加载的记录，总记录数，
- (NSDictionary *)getConvRecordListByConversation:(Conversation *)conv
{
    conn *_conn = [conn getConn];
    int start = [_conn getCurrentTime];
    NSString *convId = conv.conv_id;
    int msgId = conv.last_record.msgId;
    
//    查询当前会话，当前聊天记录之前一共有多少条聊天记录
    NSString *sql = [NSString stringWithFormat:@"select count(id) as _count from %@ where conv_id = '%@' and id < %d",table_conv_records,convId,msgId];
    
    NSMutableArray *result = [self querySql:sql];
    
    int count1 = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
    
    int offset;
    
    int _offset;
    
//    剩下的聊天记录比一次加载的多
    if(count1 > num_convrecord)
    {
        offset = count1 - num_convrecord;
        _offset = num_convrecord;
    }
    else
    {
        offset = 0;
        _offset = count1;
    }
    
//    查询当前会话，当前聊天记录以后还有多少条聊天记录
    sql = [NSString stringWithFormat:@"select count(id) as _count from %@ where conv_id = '%@' and id >= %d",table_conv_records,convId,msgId];
    result = [self querySql:sql];
    int count2 = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
    
    int limit = _offset + count2;
    
    int totalCount = count1 + count2;
    
    eCloudDAO *ecloudDAO = [eCloudDAO getDatabase];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[ecloudDAO getConvRecordBy:convId andLimit:limit andOffset:offset],@"result_array",[StringUtil getStringValue:_offset],@"offset",[StringUtil getStringValue:totalCount],@"total_count", nil];
    int end = [_conn getCurrentTime];
//    NSLog(@"%s,end - start is %d",__FUNCTION__,(end - start));
    return dic;
}

#pragma mark 根据用户输入的内容，查询会话的标题和会话参与人，找到符合条件的会话记录，显示在会话列表
-(NSArray *)getConversationBy:(NSString *)searchStr
{
    if (!searchStr || searchStr.length <= 0) {
        return nil;
    }
    
    int startTime = [[StringUtil currentTime]intValue];
    
//    NSLog(@"%s,%@",__FUNCTION__,searchStr);
//    int _type = [StringUtil getStringType:searchStr];
//    if(_type == other_type)
//        return nil;

    eCloudDAO *ecloudDAO = [eCloudDAO getDatabase];

	NSMutableArray *convIdArray = [NSMutableArray array];
	
    //	查询会话表，找到会话标题中包含输入内容的会话记录
	NSString * sql = [NSString stringWithFormat:@"select distinct(conv_id) from %@ where conv_title like ?",table_conversation];
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
        return nil;
    }
    
    //		绑定值
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string
    
    NSMutableArray *result = [NSMutableArray array];
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);

	if(result.count > 0)
	{
        //		NSLog(@"sql is %@",sql);
		for(NSDictionary *dic in result)
		{
            //			NSLog(@"%s,%@",__FUNCTION__,[dic valueForKey:@"conv_id"]);
			[convIdArray addObject:[dic valueForKey:@"conv_id"]];
		}
	}
	
//    NSLog(@"标题匹配需要时间%d",[[StringUtil currentTime]intValue] - startTime);
//    startTime = [[StringUtil currentTime]intValue];
    
    //	根据输入内容查找用户表
    
//    匹配群成员的会话id 字符串
    NSMutableString *convIdStrThatMatchMember = [NSMutableString string];
    
	NSArray *empArray = [ecloudDAO searchUserBy:searchStr];
	if(empArray.count > 0)
	{
        Emp *emp = [empArray objectAtIndex:0];
        
        NSMutableString *empStr = [NSMutableString stringWithString:emp.emp_name];
		NSMutableString *mStr = [NSMutableString stringWithString:[StringUtil getStringValue:emp.emp_id]];
		for(int i = 1;i<empArray.count;i++)
		{
            emp = [empArray objectAtIndex:i];
			[mStr appendFormat:@","];
			[mStr appendFormat:[StringUtil getStringValue:emp.emp_id]];
            
            [empStr appendFormat:@",%@",emp.emp_name];
		}
        
//        NSLog(@"emp id is:%@ emp name is %@",mStr,empStr);
        
		sql = [NSString stringWithFormat:@"select distinct(conv_id) from %@ where emp_id in (%@)",table_conv_emp,mStr];
		
        //		NSLog(@"%s,sql is %@",__FUNCTION__,sql);
		
		result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		
		for(NSDictionary *dic in result)
		{
            //			NSLog(@"%s,%@",__FUNCTION__,[dic valueForKey:@"conv_id"]);
            NSString *curConvId = [dic valueForKey:@"conv_id"];
			[convIdArray addObject:curConvId];
            [convIdStrThatMatchMember appendFormat:@"%@,",curConvId];
		}
	}
    
//    NSLog(@"成员匹配需要时间%d",[[StringUtil currentTime]intValue] - startTime);
//    startTime = [[StringUtil currentTime]intValue];
//    
	if(convIdArray.count > 0)
	{
		NSMutableString *mStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"'%@'",[convIdArray objectAtIndex:0]]];
#ifdef _LANGUANG_FLAG_
        if ([[MiLiaoUtilArc getUtil]LGisMiLiaoConv:mStr]) {
            
            mStr = nil;
        }
#endif
		for(int i = 1;i<convIdArray.count;i++)
		{
            NSString *curConvId = [convIdArray objectAtIndex:i];
#ifdef _LANGUANG_FLAG_
            if ([[MiLiaoUtilArc getUtil]LGisMiLiaoConv:curConvId]) {
                
                continue;
            }
#endif
            [mStr appendString:@","];
            [mStr appendString:[NSString stringWithFormat:@"'%@'",[convIdArray objectAtIndex:i]]];
		}
        
        NSLog(@"会话id：%@",mStr);
		sql = [NSString stringWithFormat:@"select *, 'Y' as display_merge_logo from %@ where conv_id in (%@)  order by last_msg_time desc",table_conversation,mStr];
        //		NSLog(@"%s,sql is %@",__FUNCTION__,sql);
		
		result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		
		if(result &&[result count]>0)
		{
            NSMutableArray *convArray = [NSMutableArray array];
            
//            单聊Array
            NSMutableArray *singleArray = [NSMutableArray array];
//            群聊Array
            NSMutableArray *multipleArray = [NSMutableArray array];
            
//            广播或应用平台推送
            NSMutableArray *otherTypeArray = [NSMutableArray array];
            
            for (NSDictionary *dic in result)
            {
                Conversation *conv = [[Conversation alloc]init];
                [self putDic:dic toConversation:conv];
                
                int convType = conv.conv_type;
 
                NSString *convId = conv.conv_id;
                
//                NSLog(@"%s convType is %d convId is %@",__FUNCTION__,convType,convId);
                
                NSMutableArray *_result = [NSMutableArray array];

                if ([convIdStrThatMatchMember rangeOfString:convId].length > 0 && convType == mutiableType)
                {
                    int strType = [StringUtil getStringType:searchStr];
                    //                如果是以声母开头的字母，那么按照拼音查询，否则按照名字查询
                    NSString *firstLetter = [searchStr substringToIndex:1];
                    if (strType == letter_type)
                    {
                        //                    update by shisp 应该是简拼匹配或者是账号匹配
                        
                        if ([eCloudConfig getConfig].needCreateEmpPinyinByEmpName) {
                            sql = [NSString stringWithFormat:@"select c.* from %@ a , %@ b, %@ c where a.conv_id = ? and (c.emp_pinyin_all || c.emp_pinyin_simple) like ? and a.conv_id = b.conv_id and b.emp_id = c.emp_id  limit 1",table_conversation,table_conv_emp,table_employee];
                            
                        }else{
                            sql = [NSString stringWithFormat:@"select c.* from %@ a , %@ b, %@ c where a.conv_id = ? and (emp_code like ?) and a.conv_id = b.conv_id and b.emp_id = c.emp_id  limit 1",table_conversation,table_conv_emp,table_employee];
                        }
                    }
                    else
                    {
                        sql = [NSString stringWithFormat:@"select c.* from %@ a , %@ b, %@ c where a.conv_id = ? and c.emp_name like ? and a.conv_id = b.conv_id and b.emp_id = c.emp_id limit 1",table_conversation,table_conv_emp,table_employee];
                    }
                    
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
                        return nil;
                    }
                    
                    //		绑定值
                    sqlite3_bind_text(stmt, 1, [convId UTF8String],-1,NULL);//search string
                    sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string
                    
                    [self packageStatement:stmt toArray:_result];
                    
                    //释放资源
                    pthread_mutex_lock(&add_mutex);
                    sqlite3_finalize(stmt);
                    pthread_mutex_unlock(&add_mutex);
                }
                
                if (_result.count > 0) {
//                    if (convType == singleType) {
//                        conv.last_record = nil;
//                        conv.specialStr = nil;
//                    }
//                    else
//                    {
                        NSString *empName = [[_result objectAtIndex:0]valueForKey:@"emp_name"];
                        ConvRecord *_convRecord = [[ConvRecord alloc]init];
                        _convRecord.msg_body = [NSString stringWithFormat:[StringUtil getLocalizableString:@"include_some_one"],empName];
                        conv.last_record = _convRecord;
                        conv.specialStr = empName;
                        [_convRecord release];                        
//                    }
                }
                else
                {
                    if (convType == singleType) {
                        conv.last_record = nil;
                        conv.specialStr = nil;
                    }
                    else
                    {
                        conv.last_record = nil;
                        conv.specialStr = searchStr;
                    }
                }
//                不显示群组人数
                if (convType == mutiableType) {
                    int totalNum = [ecloudDAO getAllConvEmpNumByConvId:convId];
                    NSString *convTitle = conv.conv_title;
//                    conv.conv_title = [NSString stringWithFormat:@"%@(%d)",convTitle,totalNum];
                    conv.totalEmpCount = totalNum;
                }
                
                if (convType == singleType) {
                    [singleArray addObject:conv];
                }
                else if(convType == mutiableType)
                {
                    [multipleArray addObject:conv];
                }
                else
                {
                    [otherTypeArray addObject:conv];
                }
            }
            [convArray addObjectsFromArray:otherTypeArray];
            [convArray addObjectsFromArray:singleArray];
            [convArray addObjectsFromArray:multipleArray];
            
            NSLog(@"匹配会话需要时间%d",[[StringUtil currentTime]intValue] - startTime);
            
            return convArray;
		}
	}
	
	return nil;
}

//在一个会话内，搜索和查询条件匹配的聊天记录 参数 包括 会话id 搜索内容
- (NSArray *)searchConvRecordsInConv:(NSString *)convId withSearchStr:(NSString *)searchStr withConvType:(int)convType
{
    //    如果是群聊，那么查看一下输入的内容是否和某个用户匹配
    NSString *matchEmpIds = @"";
    if (convType == mutiableType) {
        int strType = [StringUtil getStringType:searchStr];
        
        if (strType == other_type) {
            //什么都不做
        }
        else
        {
            NSString *sql;
            
            if (strType == letter_type) {
                
                if ([eCloudConfig getConfig].needCreateEmpPinyinByEmpName) {
                    sql = [NSString stringWithFormat:@"select a.emp_id from %@ a ,%@ b where a.conv_id = '%@' and a.emp_id = b.emp_id and (b.emp_pinyin_all || b.emp_pinyin_simple) like ?",table_conv_emp,table_employee,convId,searchStr];
                    
                }else{
                    sql = [NSString stringWithFormat:@"select a.emp_id from %@ a ,%@ b where a.conv_id = '%@' and a.emp_id = b.emp_id and b.emp_code like ? ",table_conv_emp,table_employee,convId,searchStr];
                }
            }
            else
            {
                sql = [NSString stringWithFormat:@"select a.emp_id from %@ a ,%@ b where a.conv_id = '%@' and a.emp_id = b.emp_id and b.emp_name like ? ",table_conv_emp,table_employee,convId,searchStr];
            }
            
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
                return nil;
            }
            
            //		绑定值
            sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string
            
            NSMutableArray *result = [NSMutableArray array];
            [self packageStatement:stmt toArray:result];
            
            //释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
            
            if (result.count == 0) {
                //                什么都不做
            }
            else
            {
                NSMutableString *mStr = [NSMutableString stringWithString:@""];
                for (NSDictionary *dic in result) {
                    [mStr appendString:[NSString stringWithFormat:@"%d,",[[dic valueForKey:@"emp_id"]intValue]]];
                }
                [mStr deleteCharactersInRange:NSMakeRange(mStr.length - 1, 1)];
                matchEmpIds = [NSString stringWithString:mStr];
            }
        }
    }
    
    NSString *colsName = @"a.file_name,a.msg_type,a.id as last_msg_id,a.msg_time,a.msg_body,a.emp_id,b.emp_name,b.emp_sex,b.emp_status,b.emp_login_type";
    
//    update by shisp 为避免sql注入问题，修改传参的方式
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ a,%@ b where a.conv_id = '%@' and a.msg_type = %d and a.msg_body like ?  COLLATE NOCASE and a.emp_id = b.emp_id order by msg_time desc",colsName,table_conv_records,table_employee,convId,type_text];
    if (matchEmpIds.length > 0) {
        sql = [NSString stringWithFormat:@"select %@ from %@ a,%@ b where a.conv_id = '%@' and ((a.msg_type = %d and a.msg_body like ? COLLATE NOCASE) or (a.emp_id in (%@))) and a.emp_id = b.emp_id order by msg_time desc",colsName,table_conv_records,table_employee,convId,type_text,matchEmpIds];
    }

    sqlite3_stmt *stmt = nil;
    
    //		编译
    pthread_mutex_lock(&add_mutex);
    int state = sqlite3_prepare(_handle, [sql UTF8String], -1, &stmt, nil);
    pthread_mutex_unlock(&add_mutex);
    
    if(state != SQLITE_OK)
    {
        //			编译错误
        [LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
        //			释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        return nil;
    }
    
    //		绑定值
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search str
    
    NSMutableArray *result = [NSMutableArray array];
    
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);
    
    for (NSMutableDictionary *dic in result) {
        int msgType = [[dic valueForKey:@"msg_type"]intValue];
        switch (msgType) {
            case type_text:
                //                    什么都不用修改
                break;
            case type_record:
            {
                [dic setValue:[StringUtil getLocalizableString:@"msg_type_record"] forKey:@"msg_body"];
            }
                break;
            case type_video:
            {
                [dic setValue:[StringUtil getLocalizableString:@"msg_type_video"] forKey:@"msg_body"];
            }
                break;
            case type_pic:
            {
                [dic setValue:[StringUtil getLocalizableString:@"msg_type_pic"] forKey:@"msg_body"];
            }
                break;
            case type_file:
            {
                [dic setValue:[NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"msg_type_file"],[dic valueForKey:@"file_name"]] forKey:@"msg_body"];
            }
                break;
            case type_long_msg:
            {
                [dic setValue:[dic valueForKey:@"file_name"] forKey:@"msg_body"];
            }
                break;
            case type_imgtxt:
            {
                [dic setValue:[dic valueForKey:@"msg_type_imgtxt"] forKey:@"msg_body"];
            }
                break;
            case type_wiki:
            {
                [dic setValue:[dic valueForKey:@"msg_type_wiki"] forKey:@"msg_body"];
            }
                break;
                
            default:
                break;
        }
    }
    return result;
}

//搜索一个会话内，某个人的发言，搜索条件不需要和聊天记录相配，而是和成员的账号或姓名相匹配 废弃方法
- (NSArray *)searchSomeoneRecordsInConv:(NSString *)convId withSearchStr:(NSString *)searchStr
{
    NSMutableArray *result = [NSMutableArray array];
    
//    需要根据搜索条件找到成员
    int strType = [StringUtil getStringType:searchStr];
    
    if (strType == other_type) {
        return result;
    }
    
    NSString *sql;
    
    if (strType == letter_type) {
        sql = [NSString stringWithFormat:@"select a.emp_id,b.emp_name,b.emp_sex from %@ a ,%@ b where a.conv_id = '%@' and a.emp_id = b.emp_id and b.emp_code like '%%%@%%' limit(1) ",table_conv_emp,table_employee,convId,searchStr];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select a.emp_id,b.emp_name,b.emp_sex from %@ a ,%@ b where a.conv_id = '%@' and a.emp_id = b.emp_id and b.emp_name like '%%%@%%' limit(1) ",table_conv_emp,table_employee,convId,searchStr];
    }
    
    result = [self querySql:sql];

    NSLog(@"%@",[result description]);
    
    if (result.count == 0) {
        return result;
    }
    
    int empId = [[[result objectAtIndex:0]valueForKey:@"emp_id"]intValue];
    int empSex = [[[result objectAtIndex:0]valueForKey:@"emp_sex"]intValue];
    NSString *empName = [[result objectAtIndex:0]valueForKey:@"emp_name"];
    
//    NSString *sql = [NSString stringWithFormat:@"select a.id as last_msg_id,a.msg_time,a.msg_body,a.emp_id,b.emp_name,b.emp_sex, 0 as permission from %@ a,%@ b where a.conv_id = '%@' and a.msg_type = %d and a.msg_body like '%%%@%%' COLLATE NOCASE and a.emp_id = b.emp_id order by msg_time desc",table_conv_records,table_employee,convId,type_text,searchStr];

    sql = [NSString stringWithFormat:@"select id as last_msg_id,msg_time,msg_body,msg_type,emp_id,file_name, %d as emp_sex,'%@' as emp_name,0 as permission  from %@ where conv_id = '%@' and emp_id = %d order by msg_time desc ",empSex,empName,table_conv_records,convId,empId];
    
    result = [self querySql:sql];
    for (NSMutableDictionary *dic in result) {
        int msgType = [[dic valueForKey:@"msg_type"]intValue];
        switch (msgType) {
            case type_text:
                //                    什么都不用修改
                break;
            case type_record:
            {
                [dic setValue:[StringUtil getLocalizableString:@"msg_type_record"] forKey:@"msg_body"];
            }
                break;
            case type_video:
            {
                [dic setValue:[StringUtil getLocalizableString:@"msg_type_video"] forKey:@"msg_body"];
            }
                break;
            case type_pic:
            {
                [dic setValue:[StringUtil getLocalizableString:@"msg_type_pic"] forKey:@"msg_body"];
            }
                break;
            case type_file:
            {
                [dic setValue:[NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"msg_type_file"],[dic valueForKey:@"file_name"]] forKey:@"msg_body"];
            }
                break;
            case type_long_msg:
            {
                [dic setValue:[dic valueForKey:@"file_name"] forKey:@"msg_body"];
            }
                break;
            case type_imgtxt:
            {
                [dic setValue:[dic valueForKey:@"msg_type_imgtxt"] forKey:@"msg_body"];
            }
                break;
            case type_wiki:
            {
                [dic setValue:[dic valueForKey:@"msg_type_wiki"] forKey:@"msg_body"];
            }
                break;
                
            default:
                break;
        }
    }
    return result;
    
}

//根据查询条件找到匹配的人员id
- (NSString *)getMatchEmpIdBySearchStr:(NSString *)searchStr
{
    NSString *sql = nil;
    
    //    如果是群聊，那么查看一下输入的内容是否和某个用户匹配
    NSString *matchEmpIds = @"";
    int strType = [StringUtil getStringType:searchStr];
    
    if (strType == other_type) {
        //什么都不做
    }
    else
    {
        NSString *sql;
        
        if (strType == letter_type) {
            sql = [NSString stringWithFormat:@"select a.emp_id from %@ a  where a.emp_code like '%%%@%%' ",table_employee,searchStr];
        }
        else
        {
            sql = [NSString stringWithFormat:@"select a.emp_id from %@ a where a.emp_name like '%%%@%%' ",table_employee,searchStr];
        }
        
        NSMutableArray *result = [self querySql:sql];
        
        if (result.count == 0) {
            //                什么都不做
        }
        else
        {
            NSMutableString *mStr = [NSMutableString stringWithString:@""];
            for (NSDictionary *dic in result) {
                [mStr appendString:[NSString stringWithFormat:@"%d,",[[dic valueForKey:@"emp_id"]intValue]]];
            }
            [mStr deleteCharactersInRange:NSMakeRange(mStr.length - 1, 1)];
            matchEmpIds = [NSString stringWithString:mStr];
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s searchstr is %@ macthempid is %@",__FUNCTION__,searchStr,matchEmpIds]];
    return matchEmpIds;
    
}

@end
