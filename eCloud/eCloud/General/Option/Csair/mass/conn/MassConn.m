#import "MassConn.h"
#import "ConvRecord.h"
#import "conn.h"
#import "MsgNotice.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "MassDAO.h"
#import "NewMsgNotice.h"
#import "Emp.h"
#import "Dept.h"
@implementation MassConn

+(BOOL)sendMassMsg:(CONNCB *)_conncb andConvEmpArray:(NSArray*)convEmpArray andConvRecord:(ConvRecord *)_convRecord
{
	int ret = 0;
	int msgType = _convRecord.msg_type;
	
//	char *msg;
	char msg[MSG_MAXLEN];
	memset(msg,0,sizeof(msg));
	
	int msgLen=0;

	if(msgType == type_text)
	{//普通文本消息
		const char* cMsg = [_convRecord.msg_body cStringUsingEncoding: NSUTF8StringEncoding];
		msgLen = strlen(cMsg);
		memcpy(msg + 10,cMsg,msgLen);
        msgLen += 10;
	}
	else if(msgType == type_pic || msgType == type_record)
	{
		NSString *fileName = _convRecord.file_name;
		NSString *fileUrl = _convRecord.msg_body;
		
		int fileSize = _convRecord.file_size.intValue;
		
		const char *_fileName = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
		int fileNameLen = strlen(_fileName);
		
		const char *_fileUrl = [fileUrl cStringUsingEncoding:NSUTF8StringEncoding];
		int fileUrlLen = strlen(_fileUrl);
		
		FILE_META fileinfo;
		memset(&fileinfo, 0, sizeof(FILE_META));
		
		//	文件大小
		fileinfo.dwFileSize = htonl(fileSize);
		//	文件名字
		memcpy(fileinfo.aszFileName, _fileName, fileNameLen);
		//	文件url
		memcpy(fileinfo.aszURL,_fileUrl,fileUrlLen);
		
//		msg = (char*)&fileinfo;
		msgLen = sizeof(FILE_META);
		memcpy(msg, &fileinfo, msgLen);
	}
	else if(msgType == type_long_msg)
	{
		NSString *fileUrl = _convRecord.msg_body;
		int fileSize = _convRecord.file_size.intValue;
		NSString *messageHead = _convRecord.file_name;
		
		//	文件名字是文件URL.txt
		NSString *tempFileName = [NSString stringWithFormat:@"%@.txt",fileUrl];
		const char *_fileName = [tempFileName cStringUsingEncoding:NSUTF8StringEncoding];
		int fileNameLen = strlen(_fileName);
		
		const char *_fileUrl = [fileUrl cStringUsingEncoding:NSUTF8StringEncoding];
		int fileUrlLen = strlen(_fileUrl);
		
		FILE_META fileinfo;
		memset(&fileinfo, 0, sizeof(FILE_META));
		
		//	文件大小
		fileinfo.dwFileSize = htonl(fileSize);
		//	文件名字
		memcpy(fileinfo.aszFileName, _fileName, fileNameLen);
		//	文件url
		memcpy(fileinfo.aszURL,_fileUrl,fileUrlLen);
		
		//	长消息head,定长50个字符
		const char *cMsgHead = [messageHead cStringUsingEncoding:NSUTF8StringEncoding];
		int messageHeadLen = strlen(cMsgHead);
		//	[LogUtil debug:[NSString stringWithFormat:@"messageHeadLen is %d",messageHeadLen);
		
		char _msgHead[50];
		memset(_msgHead, 0, sizeof(_msgHead));
		memcpy(_msgHead,cMsgHead, messageHeadLen > 50?50:messageHeadLen);
		
		
		//	消息体的总长度(字体+文件+消息头部)
		int totalLen = sizeof(FILE_META) + 50;
		//	总消息体
		char totalMsg[totalLen];
		memset(totalMsg,0,sizeof(totalMsg));
		memcpy(totalMsg,&fileinfo,sizeof(FILE_META));
		memcpy((totalMsg + sizeof(FILE_META)), _msgHead, 50);
		
		msgLen = totalLen;
		memcpy(msg, totalMsg, msgLen);
	}

	const char *title = [@"" cStringUsingEncoding:NSUTF8StringEncoding];
	
	int memberCount = convEmpArray.count;
	
	conn *_conn = [conn getConn];
	
	int iDiv = memberCount / MAXNUM_RECVER_ID;
//	满MAXNUM_RECVER_ID成员的发送
	for(int i = 0;i<iDiv;i++)
	{
		BROADCAST_RECVER pRecverIDs[MAXNUM_RECVER_ID];
		memset(pRecverIDs, 0, sizeof(pRecverIDs));

		for(int j = 0; j < MAXNUM_RECVER_ID;j++)
		{
			int _index = j+i * MAXNUM_RECVER_ID;
			id _id = [convEmpArray objectAtIndex:_index];
			if([_id isKindOfClass:[Emp class]])
			{
				pRecverIDs[j].cIsDept = 0;
				pRecverIDs[j].dwRecverID = ((Emp*)_id).emp_id;
			}
			else
			{
				pRecverIDs[j].cIsDept = 1;
				pRecverIDs[j].dwRecverID = ((Dept*)_id).dept_id;
			}
		}
		long long newMsgId = [_conn getNewMsgId];
		[LogUtil debug:[NSString stringWithFormat:@"发送一呼万应消息:%lld",newMsgId]];
		ret = CLIENT_SendBroadCast(_conncb, (char*)pRecverIDs,MAXNUM_RECVER_ID, (char*)title, msg, msgLen,newMsgId, [_conn getCurrentTime], msgType, 1, _convRecord.origin_msg_id);
		if(ret == 0)
		{
			continue;
		}
		else
		{
			return NO;
		}
	}
	
//	不满MAXNUM_RECVER_ID的成员
	int iMov = memberCount % MAXNUM_RECVER_ID;
	
	BROADCAST_RECVER pRecverIDs[iMov];
	memset(pRecverIDs, 0, sizeof(pRecverIDs));
	
	for(int i = 0;i<iMov;i++)
	{
		int _index = i+iDiv * MAXNUM_RECVER_ID;
		id _id = [convEmpArray objectAtIndex:_index];
		if([_id isKindOfClass:[Emp class]])
		{
			pRecverIDs[i].cIsDept = 0;
			pRecverIDs[i].dwRecverID = ((Emp*)_id).emp_id;
		}
		else
		{
			pRecverIDs[i].cIsDept = 1;
			pRecverIDs[i].dwRecverID = ((Dept*)_id).dept_id;
		}
	}
	[LogUtil debug:[NSString stringWithFormat:@"发送一呼万应消息:%lld",_convRecord.origin_msg_id]];
	
//	int  CLIENT_SendBroadCast(PCONNCB pConnCB, char *pRecverIDs, int num, char *pszTitle, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nMsgType, unsigned char nAllReply, UINT64 nSrcMsgID)
	
	ret = CLIENT_SendBroadCast(_conncb, (char*)pRecverIDs,iMov, (char*)title, msg, msgLen, _convRecord.origin_msg_id, [_conn getCurrentTime], msgType, 1, _convRecord.origin_msg_id);
	if(ret != 0)
	{
		return NO;
	}

	return YES;
}

+(MsgNotice*)getMsgNoticeObject:(BROADCASTNOTICE *)_msgNotice
{
	MsgNotice *_msg = [[[MsgNotice alloc]init]autorelease];
	_msg.senderId = _msgNotice->dwSenderID;
	_msg.rcvId = _msgNotice->dwRecverID;
	_msg.msgId = _msgNotice->dwMsgID;
	_msg.msgType = _msgNotice->cMsgType;
	_msg.msgLen = _msgNotice->dwMsgLen;
	_msg.msgTime = _msgNotice->dwSendTime;
	
	_msg.srcMsgIdOfMassMsg = _msgNotice->dwSrcMsgID;
	if(_msgNotice->cAllReply == 1)
	{
		_msg.isMassMsg = YES;
	}
	//	[LogUtil debug:[NSString stringWithFormat:@"msg len is %d",_msg.msgLen]];
	if(_msg.msgLen > 0)
	{
		switch(_msg.msgType)
		{
			case type_text:
			{
                int msgLen = _msgNotice->dwMsgLen - 10;
                char temp[msgLen + 1];
                memset(temp,0,sizeof(temp));
                memcpy(temp,_msgNotice->aszMessage+10, msgLen);
                
                _msg.msgBody = [StringUtil getStringByCString:temp];
			}
				break;
			case type_long_msg:
			{
				//		取出长消息文件信息
				char _fileInfo[sizeof(FILE_META)];
				memset(_fileInfo,0,sizeof(_fileInfo));
				memcpy(_fileInfo,_msgNotice->aszMessage,sizeof(FILE_META));
				
				FILE_META *fileInfo = (FILE_META *)_fileInfo;
				//		长消息字节数
				_msg.fileSize = ntohl(fileInfo->dwFileSize);
				//长消息文件名字
				//				fileName = [StringUtil getStringByCString:fileInfo->aszFileName];
				//		长消息文件url
				_msg.msgBody = [StringUtil getStringByCString:fileInfo->aszURL];
				
				//		长消息头部
				int msgHeadLen = _msgNotice->dwMsgLen - sizeof(FILE_META);
				char temp[msgHeadLen + 1];
				memset(temp,0,sizeof(temp));
				memcpy(temp,_msgNotice->aszMessage+sizeof(FILE_META), msgHeadLen);
				//				把消息头保存在fileName属性中
				_msg.fileName = [StringUtil getStringByCString:temp];
				
			}
				break;
			case type_pic:
			case type_record:
			case type_file:
			{
				FILE_META *fileInfo = (FILE_META *)&_msgNotice->aszMessage;
				_msg.fileSize = ntohl(fileInfo->dwFileSize);
				
				//				如果是录音消息，并且长度不正常，那么赋值一个10s，否则不能正常显示录音
				if(_msg.msgType == type_record && (_msg.fileSize > 60 || _msg.fileSize<=0))
				{
					[LogUtil debug:[NSString stringWithFormat:@"record len is :%d",_msg.fileSize]];
					_msg.fileSize = 10;
				}
				_msg.fileName = [StringUtil getStringByCString:fileInfo->aszFileName];
				_msg.msgBody = [StringUtil getStringByCString:fileInfo->aszURL];
				
			}
				break;
            case type_imgtxt:
            {
                int msgLen = _msgNotice->dwMsgLen - 10;
                char temp[msgLen + 1];
                memset(temp,0,sizeof(temp));
                memcpy(temp,_msgNotice->aszMessage+10, msgLen);
                
                _msg.msgBody = [StringUtil getStringByCString:temp];
            }
                break;
            case type_wiki:
            {
                int msgLen = _msgNotice->dwMsgLen - 10;
                char temp[msgLen + 1];
                memset(temp,0,sizeof(temp));
                memcpy(temp,_msgNotice->aszMessage+10, msgLen);
                
                _msg.msgBody = [StringUtil getStringByCString:temp];
            }
                break;
		}
        
//        NSLog(@"%s,sender is %d ,rceiver is %d , msg_id is %lld , msgType is %d ,msgLen is %d , srcMsgIdOfMassMsg is %lld , msgbody is %@ ",__FUNCTION__,_msg.senderId,_msg.rcvId,_msg.msgId,_msg.msgType,_msg.msgLen,_msg.srcMsgIdOfMassMsg,_msg.msgBody);

		return _msg;
	}
	return nil;
}
#pragma mark 收到一呼万应的消息，保存为一个新的会话，返回新会话的convId
+(NSString*)createNewConversation:(MsgNotice*)msgNotice
{
	//	首先要创建会话
	//	源消息id 和 发送人的id为convId
	NSString *convId = [NSString stringWithFormat:@"%lld|%d",msgNotice.srcMsgIdOfMassMsg,msgNotice.senderId];
	NSString *convType = [StringUtil getStringValue:rcvMassType];
	
	//	发送人
	int senderId = msgNotice.senderId;
	eCloudDAO *_eCloud = [eCloudDAO getDatabase];
	NSDictionary *dic = [_eCloud searchEmp:[StringUtil getStringValue:senderId]];
	if(dic == nil)
	{
		return nil;
	}
	NSString *empName = [dic valueForKey:@"emp_name"];
	conn *_conn = [conn getConn];
	 dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
						 convType,@"conv_type",
						 empName,@"conv_title",
						 [StringUtil getStringValue:senderId],@"create_emp_id",
						 [_conn getSCurrentTime],@"create_time", nil];
	
	[_eCloud addConversation:[NSArray arrayWithObject:dic]];
	
	return convId;
}

#pragma mark 保存收到的群发消息，如果成功则返回msgid
+(NSString*)saveRcvMassMsg:(MsgNotice*)msgNotice
{
//	源消息id 和 发送人的id为convId
	NSString *convId = [NSString stringWithFormat:@"%lld|%d",msgNotice.srcMsgIdOfMassMsg,msgNotice.senderId];
//	发送人
	int senderId = msgNotice.senderId;

	eCloudDAO *_eCloud = [eCloudDAO getDatabase];
	
//	其次要增加会话记录
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
		   [StringUtil getStringValue:senderId],@"emp_id",
		   [StringUtil getStringValue:msgNotice.msgType],@"msg_type",
		   msgNotice.msgBody,@"msg_body",
		   [StringUtil getStringValue:msgNotice.msgTime],@"msg_time",
			@"1",@"read_flag",
		   [StringUtil getStringValue:rcv_msg],@"msg_flag",
		   msgNotice.fileName,@"file_name",
		   [StringUtil getStringValue:msgNotice.fileSize],@"file_size",
		   [NSString stringWithFormat:@"%lld",msgNotice.msgId],@"origin_msg_id", nil];
	
//    NSLog(@"%@",[dic description]);
    
	NSDictionary *_dic = [_eCloud addConvRecord:[NSArray arrayWithObject:dic]];
	NSString *msgId;
	if(_dic)
	{
		msgId = [_dic valueForKey:@"msg_id"];
	}
	else
	{
		msgId = nil;
	}
	
	return msgId;
}

#pragma mark 保存用户对一呼万应消息的回复
+(NewMsgNotice*)saveReplyMessage:(MsgNotice*)msgNotice
{
	NewMsgNotice *_notice = [[[NewMsgNotice alloc]init]autorelease];
	
	long long srcMsgId = msgNotice.srcMsgIdOfMassMsg;
	MassDAO *massDAO = [MassDAO getDatabase];
	NSString *msgId = [massDAO getMsgIdByOriginMsgId:[NSString stringWithFormat:@"%lld",srcMsgId]];
	ConvRecord *_convRecord = [massDAO getConvRecordByMsgId:msgId];
	NSString *convId = _convRecord.conv_id;
	NSString *senderId = [StringUtil getStringValue:msgNotice.senderId];
    NSString *sSendFlag = [StringUtil getStringValue:send_success];
	if(msgNotice.fileName == nil)
	{
		msgNotice.fileName = @"";
	}
	NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
						  convId,@"conv_id",
						  senderId,@"emp_id",
						  [StringUtil getStringValue:msgNotice.msgType] ,@"msg_type",
						  msgNotice.msgBody,@"msg_body",
						  [StringUtil getStringValue:msgNotice.msgTime],@"msg_time",
						  [StringUtil getStringValue:rcv_msg],@"msg_flag",
						  @"1",@"read_flag",
						  msgNotice.fileName,@"file_name",
						  [StringUtil getStringValue:msgNotice.fileSize],@"file_size",
						  [NSString stringWithFormat:@"%lld",msgNotice.msgId],@"origin_msg_id",
						  @"1",@"is_set_redstate",
                          sSendFlag,@"send_flag",
						  msgId,@"send_msg_id", nil];
	NSDictionary *_dic = [massDAO addConvRecord:dic];
	if(_dic)
	{
		[LogUtil debug:[NSString stringWithFormat:@"收到应答并入群发消息表成功,%@",msgId]];
		
		[self saveReplyMessage2:msgNotice];
		
		_notice.msgType = mass_reply_msg_type;
		_notice.msgId = msgId;
		_notice.convId = convId;
	
		return _notice;
	}
	else
	{
		[LogUtil debug:@"收到应答，但入库失败"];
		return nil;
	}
}

+(void)saveReplyMessage2:(MsgNotice*)msgNotice
{
	int msgType = msgNotice.msgType;
	if(msgType == type_text)
	{
		[self saveTextReplyMessage:msgNotice];
	}
	else
	{
		ConvRecord *_convRecord = [[ConvRecord alloc]init];
		int senderId = msgNotice.senderId;
		_convRecord.conv_id = [StringUtil getStringValue:senderId];
		_convRecord.emp_id = senderId;
		_convRecord.msg_body = msgNotice.msgBody;
		_convRecord.msg_flag = rcv_msg;
		_convRecord.msg_time = [StringUtil getStringValue:msgNotice.msgTime];
		_convRecord.msg_type = msgNotice.msgType;
		_convRecord.msgId = msgNotice.msgId;
		_convRecord.file_size = [StringUtil getStringValue:msgNotice.fileSize];
		_convRecord.file_name = msgNotice.fileName;
		_convRecord.is_set_redstate = 1;
		_convRecord.origin_msg_id = msgNotice.msgId;
        _convRecord.send_flag = send_success;
		
		MassDAO *massDAO = [MassDAO getDatabase];
		[massDAO transferMassMsg:_convRecord];
		[_convRecord release];
	}
}

+(void)saveTextReplyMessage:(MsgNotice*)msgNotice
{
	eCloudDAO *db = [eCloudDAO getDatabase];
	
	NSString *originMsgId = [NSString stringWithFormat:@"%lld",msgNotice.msgId];
	NSString *senderId = [StringUtil getStringValue:msgNotice.senderId];
	NSString *sendTime = [StringUtil getStringValue:msgNotice.msgTime];
	
	NSString *msgStr = msgNotice.msgBody;
	//		如果是文本消息 不能直接入库，要看下有没有pc端发来的截图
	NSMutableArray *array = [NSMutableArray array];
	
	[StringUtil seperateMsg:msgStr andImageArray:array];
	
	NSMutableString *mMessage = [NSMutableString string];
	NSString *imageName = @"";
	NSString *imageUrl = @"";
	NSDictionary *dic;
    NSString *sSendFlag = [StringUtil getStringValue:send_success];
	if([array count] >= 1)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int _count = [array count];
		for(NSString *str in array)
		{
            dic = nil;
			if([str hasPrefix:PC_CROP_PIC_START] && [str hasSuffix:PC_CROP_PIC_END])
			{
				imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
				imageUrl = imageName;
				NSRange range = [imageName rangeOfString:@"." options:NSBackwardsSearch];
				if(range.length > 0)
				{
					imageUrl = [imageName substringWithRange:NSMakeRange(0,range.location)];
				}
				if(imageUrl.length > 0)
				{
					//					把图片消息插入到会话记录中，目前pc没有传文件大小，并且通知
					dic = [NSDictionary dictionaryWithObjectsAndKeys:senderId,@"conv_id",
						   senderId,@"emp_id",
						   [StringUtil getStringValue:type_pic],@"msg_type",
						   imageUrl,@"msg_body",
						   sendTime,@"msg_time",
						   @"0",@"read_flag",
						   [StringUtil getStringValue:rcv_msg],@"msg_flag",
						   sSendFlag,@"send_flag",
						   imageName,@"file_name",
						   @"0",@"file_size",
						   [NSString stringWithFormat:@"%@|%d",originMsgId,_count],@"origin_msg_id", nil];
				}
			}
			else
			{
                //					把图片消息插入到会话记录中，目前pc没有传文件大小，并且通知
                dic = [NSDictionary dictionaryWithObjectsAndKeys:senderId,@"conv_id",
                       senderId,@"emp_id",
                       [StringUtil getStringValue:type_text],@"msg_type",
                       str,@"msg_body",
                       sendTime,@"msg_time",
                       @"0",@"read_flag",
                       [StringUtil getStringValue:rcv_msg],@"msg_flag",
                       sSendFlag,@"send_flag",
                       imageName,@"file_name",
                       @"0",@"file_size",
                       [NSString stringWithFormat:@"%@|%d",originMsgId,_count],@"origin_msg_id", nil];
			}
            
			_count --;
            
            if(dic)
            {
                NSDictionary *_dic = [db addConvRecord:[NSArray arrayWithObject:dic]];
                if(_dic)
                {
                    
                    NSString *msgId = [_dic valueForKey:@"msg_id"];
                    NSLog(@"收到一呼万应应答，保存成功");
                }
            }
		}
		[pool release];
}
}
@end
