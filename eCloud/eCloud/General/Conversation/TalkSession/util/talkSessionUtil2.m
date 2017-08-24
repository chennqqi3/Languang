//
//  talkSessionUtil2.m
//  eCloud
//
//  Created by Richard on 14-1-9.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "talkSessionUtil2.h"
#import "eCloudDefine.h"
#import "Emp.h"
#import "conn.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "MassDAO.h"
#import "MessageView.h"

#import "MiLiaoUtilArc.h"

#import "DownloadFileModel.h"
#import "UploadFileModel.h"

#import "Dept.h"

static talkSessionUtil2 *_talkSessionUtil2;

@implementation talkSessionUtil2
{
    NSMutableArray *downloadRecordList;
    NSMutableArray *upLoadRecordList;
}
static int recycle = 0;

+(talkSessionUtil2*)getTalkSessionUtil
{
    if(_talkSessionUtil2 == nil)
    {
        _talkSessionUtil2 = [[talkSessionUtil2 alloc]init];
    }
    return _talkSessionUtil2;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        downloadRecordList = [[NSMutableArray alloc]init];
        upLoadRecordList = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)dealloc
{
    for (ConvRecord *_convRecord in downloadRecordList) {
        //解除下载的delegate
        if (_convRecord.download_flag == state_downloading && _convRecord.downloadRequest) {
            _convRecord.downloadRequest.downloadProgressDelegate = nil;
            [_convRecord.downloadRequest clearDelegatesAndCancel];
        }
    }
    
    [downloadRecordList release];
    downloadRecordList = nil;
    
    
    for (ConvRecord *_convRecord in upLoadRecordList) {
        //解除上传的delegate
        if (_convRecord.send_flag == state_uploading && _convRecord.uploadRequest) {
            _convRecord.uploadRequest.uploadProgressDelegate = nil;
            [_convRecord.uploadRequest clearDelegatesAndCancel];
        }
    }
    
    [upLoadRecordList release];
    upLoadRecordList = nil;
}

//获取默认的聊天的title
+(NSString*)getDefaultTitle:(int)convType andConvEmpArray:(NSArray*)convEmpArray
{
	NSString *titleStr = @"会话";
	if(convType == mutiableType)
	{
		if ([convEmpArray count]>=3)
		{
			Emp *emp1=[convEmpArray objectAtIndex:0];
			Emp *emp2=[convEmpArray objectAtIndex:1];
			Emp *emp3=[convEmpArray objectAtIndex:2];
			titleStr =[NSString stringWithFormat:@"%@,%@,%@",emp3.emp_name,emp2.emp_name,emp1.emp_name];
		}
	}
	else if(convType == massType)
	{
		titleStr = [StringUtil getLocalizableString:@"mass_send_msg"];
	}
	return titleStr;
}

//生成会话id
+(NSString*)getNewConvIdByNowTime:(NSString*)nowTime
{
	conn *_conn = [conn getConn];
	NSString *temp = [NSString stringWithFormat:@"00000000%@",_conn.userId];
	temp = [temp substringFromIndex:([temp length] - 8)];
	
	NSString *newConvId = [NSString stringWithFormat:@"%@%@%d",nowTime,temp,recycle];
	recycle++;
	if(recycle == 10) recycle = 0;
	return newConvId;
}

//创建群聊会话
+(void)createConversation:(int)convType andConvId:(NSString*)convId andTitle:(NSString*)title andCreateTime:(NSString*)createTime andConvEmpArray:(NSArray*)convEmpArray  andMassTotalEmpCount:(int)massTotalEmpCount
{
	conn *_conn = [conn getConn];
	eCloudDAO *_ecloud = [eCloudDAO getDatabase];
	if(convType == mutiableType)
	{
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
							 [StringUtil getStringValue:mutiableType],@"conv_type",
							 title,@"conv_title",
							 [StringUtil getStringValue:open_msg],@"recv_flag",
							 _conn.userId,@"create_emp_id",
							 createTime, @"create_time",
							 @"-1",@"last_msg_id", nil];
		
		[_ecloud addConversation:[NSArray arrayWithObject:dic]];
		
		//				增加会话成员
		NSMutableArray *tempArray = [NSMutableArray array];
		for(Emp *_emp in convEmpArray)
		{
			dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[StringUtil getStringValue:_emp.emp_id ],@"emp_id", nil];
			[tempArray addObject:dic];
		}
		[_ecloud addConvEmp:tempArray];
		
		//			在这里增加一个群组创建消息 你邀请谁加入群聊
		//			//群聊中除自己以外的人员的名称
		NSMutableString *otherNames = [NSMutableString stringWithString:@""];
		
		for(Emp *_emp in convEmpArray)
		{
			if(_emp.emp_id != _conn.userId.intValue)
			{
				[otherNames appendString:[_emp getEmpName]];
				[otherNames appendString:@","];
			}
		}
		
		if(otherNames.length > 1)
		{
			[otherNames deleteCharactersInRange:NSMakeRange(otherNames.length-1, 1)];
			
			
			NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_invite_x_join_group"],otherNames];
			//	保存到数据库中
			//				 新增文本消息，并通知
			[_conn saveGroupNotifyMsg:convId andMsg:msgBody andMsgTime:[_conn getSCurrentTime]];
		}
	}
	else if(convType == massType)
	{
		MassDAO *massDAO = [MassDAO getDatabase];

		//				增加会话成员
		NSMutableArray *empMemberArray = [NSMutableArray array];
		for(id  _id in convEmpArray)
		{
			if([_id isKindOfClass:[Emp class]])
			{
				Emp *_emp = (Emp*)_id;
				if(_emp.emp_id == _conn.userId.intValue)
				{
//					用户自己不加进去
				}
				else
				{
					NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
										 [StringUtil getStringValue:emp_member_type],@"member_type",
										 [StringUtil getStringValue:_emp.emp_id ],@"member_id", nil];
					[empMemberArray addObject:dic];					
				}
			}
			else if([_id isKindOfClass:[Dept class]])
			{
				Dept *_dept = (Dept*)_id;
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
									 [StringUtil getStringValue:dept_member_type],@"member_type",
									 [StringUtil getStringValue:_dept.dept_id],@"member_id", nil];
				[empMemberArray addObject:dic];
			}
		}
		[massDAO addConvMember:empMemberArray];

//		增加会话
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
							 title,@"conv_title",
							 _conn.userId,@"create_emp_id",
							 createTime, @"create_time",
							 @"-1",@"last_msg_id",
							 [StringUtil getStringValue:massTotalEmpCount],@"emp_count",nil];
		[massDAO addConversation:dic];
		
//自动生成一条通知消息
		NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"mass_msg_tips"] ,massTotalEmpCount];
		//	设置为已读
		NSString *sReadFlag = @"0";
		//	发消息
		NSString *sMsgFlag = [StringUtil getStringValue:send_msg];
		//
		NSString *sSendFlag = [StringUtil getStringValue:send_success];
		
		 dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
							 _conn.userId,@"emp_id",
							 [StringUtil getStringValue:type_group_info],@"msg_type",
							 msgBody,@"msg_body",
							 [_conn getSCurrentTime],@"msg_time",
							 sReadFlag,@"read_flag",
							 sMsgFlag,@"msg_flag",
							 sSendFlag,@"send_flag",@"",@"file_name",@"0",@"file_size",@"",@"origin_msg_id",nil];
		
		[massDAO addConvRecord:dic];
	}
}

#pragma mark 如果不存在下载列表中，则增加
-(void)addRecordToDownloadList:(ConvRecord*)_convRecord
{
    if(![self isRecordInDownloadList:_convRecord])
    {
        [downloadRecordList addObject:_convRecord];
//        NSLog(@"%s,",__FUNCTION__);
    }
}
#pragma mark 是否存在下载列表中
-(BOOL)isRecordInDownloadList:(ConvRecord*)_convRecord
{
    for(int i = downloadRecordList.count-1;i>=0;i--)
    {
        ConvRecord *convRecord = [downloadRecordList objectAtIndex:i];
        if(convRecord.msgId == _convRecord.msgId)
        {
            return YES;
        }
    }
    return NO;
}
#pragma mark 如果在下载列表中，则获取下载的属性，并进行设置
-(void)setDownloadPropertyOfRecord:(ConvRecord*)_convRecord
{
    //    update by shisp 不明白为什么要把图片加上，因为我只发现文件加进去了，也许应该把图片 视频 文件都加上才对 现在图片是在Gallery里下载的，已经没有在加到队列中了
    if((_convRecord.msg_type == type_pic && !_convRecord.isBigPicExist) || (_convRecord.msg_type == type_file && !_convRecord.isFileExists) || (_convRecord.msg_type == type_video && !_convRecord.isVideoExist))
    {
        for(int i = downloadRecordList.count-1;i>=0;i--)
        {
            ConvRecord *convRecord = [downloadRecordList objectAtIndex:i];
            if(convRecord.msgId == _convRecord.msgId)
            {
                _convRecord.isDownLoading = convRecord.isDownLoading;
                _convRecord.downloadRequest = convRecord.downloadRequest;
                
                NSLog(@"%s,",__FUNCTION__);
                break;
            }
        }

    }
}

-(void)removeRecordFromDownloadList:(int)msgId
{    
    for(int i = downloadRecordList.count-1;i>=0;i--)
    {
        ConvRecord *convRecord = [downloadRecordList objectAtIndex:i];
        if(convRecord.msgId == msgId)
        {
            convRecord.downloadRequest.downloadProgressDelegate = nil;
            [convRecord.downloadRequest clearDelegatesAndCancel];
            [downloadRecordList removeObject:convRecord];
//            NSLog(@"%s,",__FUNCTION__);
          break;
        }
    }
}

-(void)createSingleConversation:(NSString *)convId andTitle:(NSString *)titleStr
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    conn *_conn = [conn getConn];
	NSString *nowTime =[_conn getSCurrentTime];
    
	//		如果会话表里没有这条单聊记录，则添加
	if(![_ecloud searchConversationBy:convId])
	{
		//				单人会话
		NSString *convType = [StringUtil getStringValue:singleType];
		//				不屏蔽
		NSString *recvFlag = [StringUtil getStringValue:open_msg];
		
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",convType,@"conv_type",titleStr,@"conv_title",recvFlag,@"recv_flag",_conn.userId,@"create_emp_id",nowTime,@"create_time", nil];
		
		//		增加会话数据
		[_ecloud addConversation:[NSArray arrayWithObject:dic]];
		
		//			第一次和某个人聊天，下载用户资料和头像
		[_ecloud getUserInfoAndDownloadLogo:convId];
        
        [self createMiliaoTips:convId];
	}
}

/** 生成密聊提示 */
- (void)createMiliaoTips:(NSString *)convId{
    [self createMiliaoTips:convId andTipsTime:[[conn getConn] getCurrentTime]];
}

/** 生成密聊提示  增加一个参数 提示时间*/
- (void)createMiliaoTips:(NSString *)convId andTipsTime:(int)tipTime{
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:convId])
    {
        //	发消息
        NSString *sMsgFlag = [StringUtil getStringValue:send_msg];
        //
        NSString *sSendFlag = [StringUtil getStringValue:send_success];
        
        NSString *msgBody = @"消息已读后自动销毁\n消息在各端不留痕迹\n消息禁止拷贝或转发\n头像名字打码防截屏";
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[conn getConn].userId,@"emp_id",[StringUtil getStringValue:type_group_info],@"msg_type",msgBody,@"msg_body",[StringUtil getStringValue:tipTime],@"msg_time", @(0),@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag",@"",@"file_name",@"0",@"file_size",@"",@"origin_msg_id",nil];
        
        [[eCloudDAO getDatabase] addConvRecord:[NSArray arrayWithObject:dic]];
    }

}


//根据要转发的记录，得到群聊的标题
- (NSString *)getTitleStrByConvRecord:(ConvRecord *)convRecord
{
    //    标题
    NSString *messageStr = convRecord.msg_body;
    
    int iMsgType = convRecord.msg_type;
    
    if(iMsgType == type_pic)
    {
        messageStr = [StringUtil getLocalizableString:@"msg_type_pic"];
    }
    else if(iMsgType == type_long_msg)
    {
        messageStr = convRecord.file_name;
    }
    else if(iMsgType == type_file)
    {
        messageStr = convRecord.file_name;
    }
    else
    {
        messageStr = [[MessageView getMessageView] replaceFaceStrWithText:messageStr] ;
    }
    
    if (messageStr.length>15)
    {
        messageStr=[messageStr substringToIndex:15];
    }
    
    return messageStr;
}

#pragma mark - 文件上传记录
-(void)addRecordToUploadList:(ConvRecord*)_convRecord
{
    if(![self isRecordInUploadList:_convRecord])
    {
        [upLoadRecordList addObject:_convRecord];
        //        NSLog(@"%s,",__FUNCTION__);
    }
}

#pragma mark - 设置文件上传属性
//   update by shisp 因为只有文件和video加到upload list了，所以这里可以设置
-(void)setUploadPropertyOfRecord:(ConvRecord*)_convRecord{
    if(_convRecord.msg_type == type_file || _convRecord.msg_type == type_video){
        for(int i = upLoadRecordList.count-1;i>=0;i--){
            ConvRecord *convRecord = [upLoadRecordList objectAtIndex:i];
            if(convRecord.msgId == _convRecord.msgId){
                _convRecord.send_flag = convRecord.send_flag;
                _convRecord.uploadRequest = convRecord.uploadRequest;
                
                NSLog(@"%s,",__FUNCTION__);
                break;
            }
        }
    }
}


#pragma mark 是否存在上传列表中
-(BOOL)isRecordInUploadList:(ConvRecord*)_convRecord
{
    for(int i = upLoadRecordList.count-1;i>=0;i--)
    {
        ConvRecord *convRecord = [upLoadRecordList objectAtIndex:i];
        if(convRecord.msgId == _convRecord.msgId)
        {
            return YES;
        }
    }
    
    return NO;
}

-(void)removeRecordFromUploadList:(int)msgId
{
    for(int i = upLoadRecordList.count-1;i>=0;i--)
    {
        ConvRecord *convRecord = [upLoadRecordList objectAtIndex:i];
        if(convRecord.msgId == msgId)
        {
            convRecord.uploadRequest.uploadProgressDelegate = nil;
            [convRecord.uploadRequest clearDelegatesAndCancel];
            [upLoadRecordList removeObject:convRecord];
            //            NSLog(@"%s,",__FUNCTION__);
            break;
        }
    }
}

//虚拟组成员不在线时的提示语
#define TIPS_OF_VIRUTAL_GROUP_USER_OFFLINE @"客户服务人员暂时无法提供服务，如有紧急事宜请拨打电话联系."

- (void)createTipsRecordOfVirtualUser:(NSString *)convId{
    //	设置为已读
    NSString *sReadFlag = @"0";
    //	发消息
    NSString *sMsgFlag = [StringUtil getStringValue:send_msg];
    //
    NSString *sSendFlag = [StringUtil getStringValue:send_success];
    
    NSString *msgBody = TIPS_OF_VIRUTAL_GROUP_USER_OFFLINE;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[conn getConn].userId,@"emp_id",[StringUtil getStringValue:type_group_info],@"msg_type",msgBody,@"msg_body",[[conn getConn]getSCurrentTime],@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag",@"",@"file_name",@"0",@"file_size",@"",@"origin_msg_id",nil];
    
    NSDictionary *_dic = [[eCloudDAO getDatabase] addConvRecord:[NSArray arrayWithObject:dic]];
    NSString *msgId;
    if(_dic)
    {
        msgId = [_dic valueForKey:@"msg_id"];
    }
    else
    {
        msgId = nil;
    }
    //				[LogUtil debug:[NSString stringWithFormat:@"消息入库 msg is %@,msgId is %@",mMessage,msgId]];
    
    if(msgId)
    {//通知页面更新，但不发出声音
        [[conn getConn] sendMsgNotice2:msgId andConvId:convId andAlert:false];
    }

}



//设置表情icon
+ (void)setFaceIcon:(UIButton *)button{
    [button setImage:[StringUtil getImageByResName:@"btn_chat_face_normal"] forState:UIControlStateNormal];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_face_pressed"] forState:UIControlStateFocused];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_face_pressed"] forState:UIControlStateHighlighted];
}
//设置语音icon
+ (void)setAudioIcon:(UIButton *)button{
    [button setImage:[StringUtil getImageByResName:@"btn_chat_voice_normal"] forState:UIControlStateNormal];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_voice_press"] forState:UIControlStateFocused];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_voice_press"] forState:UIControlStateHighlighted];
}

//设置加号图标
+ (void)setPlusIcon:(UIButton *)button{
    [button setImage:[StringUtil getImageByResName:@"btn_chat_add_normal"] forState:UIControlStateNormal];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_add_pressed"] forState:UIControlStateSelected];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_add_pressed"] forState:UIControlStateHighlighted];
}

//设置键盘图标
+ (void)setKeyboardIcon:(UIButton *)button{
    [button setImage:[StringUtil getImageByResName:@"btn_chat_keyboard_normal"] forState:UIControlStateNormal];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_keyboard_pressed"] forState:UIControlStateSelected];
    [button setImage:[StringUtil getImageByResName:@"btn_chat_keyboard_pressed"] forState:UIControlStateHighlighted];
}

@end
