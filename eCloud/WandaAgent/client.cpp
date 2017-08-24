#include "client.h"
#include "BasicDefine.h"
#include "http.h"
#include "change.h"
#include "myfunc.h"
#include "protocol.h"

#define ENC_SEND_RET_(R)	((R) >= 0 ? EIMERR_SUCCESS : (R))
#define CHECK_NULL_RET_(P)	if ((P) == NULL) return EIMERR_INVALID_PARAMTER
#define CHECK_PCB_RET_(P) \
	{ \
		if((P) == NULL) return EIMERR_ALIVE_NO_CONNECT; \
		if(!(P)->fLogin) return EIMERR_ALIVE_NO_LOGIN; \
	}

static int g_nSeq = 0;
//static int g_nSessionID = 0;
static int g_ExitExe = 0;			// 1: is exiting...
static int g_ThreadAliveCount = 0;	// <=0: no thread is working
static const char *json_ecwx_up_sync = "{\"fromUser\":\"%s\","
									"\"toUser\":%d,"
									"\"msgType\":\"%s\","
									"\"content\":{\"text\":"
									"\"%s\",\"sequence\":%d}"
									"}";

static const char *json_ecwx_up_updatemenu = "{\"fromUser\":\"%s\","
									"\"toUser\":%d,"
									"\"msgType\":\"%s\","
									"\"content\":{\"text\":"
									"%s,\"sequence\":%d}"
									"}";

static const char *g_cszHttpReqHead = "POST / HTTP/1.1\r\n"
                                      "SESSIONID: %d\r\n"
                                      "Content-Length: %d\r\n"
                                      "\r\n";

static int CLIENT_SendAlive(PCONNCB pConnCB);
static int CLIENT_SendMsgReadNoticeAck(PCONNCB pConnCB, UINT32 dwRecverID, UINT64 dwMsgID);
static int CLIENT_ntoh_cmd(PCONNCB pConnCB, int &nContentLength, int &nMsgNotice, TERM_CMD_HEAD **pHead);
static pthread_mutex_t g_SeqLock;


MYTYPE_THREAD_FUNC alivethread(void *pParam)
{
	PCONNCB pConnCB = (PCONNCB)pParam;
	try
	{
	g_ThreadAliveCount++;
    pthread_detach(pthread_self());
    int nCount = 0;
	UINT16 nSleepCount = 0;
    INT32 iAliveTime=5;
	INT32 ALIVE_MIN =3;
	INT32 ALIVE_MAX =180;
    while(pConnCB->nRunFlag /*&& g_ExitExe == 0*/)
    {
        nCount ++;
		nSleepCount ++;
		#ifdef WIN32
        uSleep(500);
		#else
		sleep(1);
		#endif
        
		if( (pConnCB->dwAliveTime/10 > ALIVE_MIN) && (pConnCB->dwAliveTime/10 <= ALIVE_MAX))
			iAliveTime = pConnCB->dwAliveTime;

		#ifdef WIN32
        if (nCount >= iAliveTime && nSleepCount >= 180)
		#else
		if (nCount >= iAliveTime && nSleepCount >= 90)
		#endif
        {
            nCount = 0;
			nSleepCount = 0;
            if (pConnCB->fConnect && pConnCB->fLogin)
            {
                if (CLIENT_SendAlive(pConnCB) != 0)
                {
                    pConnCB->fConnect = FALSE;
                    pConnCB->fLogin   = FALSE;
                    pConnCB->nRunFlag = 0;
                    CLOSE_(pConnCB->nSocket);
                }
            }
        }
    }
	}
	catch(...)
	{
		g_ThreadAliveCount--;
		return EIMERR_SUCCESS;
	}

	#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "alivethread exit\n");
	}
	#endif
    printf("alivethread exit\n");
	g_ThreadAliveCount--;

    return EIMERR_SUCCESS;
}

MYTYPE_THREAD_FUNC recvthread(void *pParam)
{
	PCONNCB pConnCB = (PCONNCB)pParam;
	try
	{
	g_ThreadAliveCount++;
    char aszData[PACKET_MAXLEN+500];
    memset(aszData,0,sizeof(aszData));
    TERM_CMD_HEAD mTermCmdHead;
    memset(&mTermCmdHead, 0, sizeof(TERM_CMD_HEAD));
    TERM_CMD_HEAD *pHead = NULL;
    fd_set      sFDSet;
    struct timeval sTimeOut;
    int nMsgNotice = 0;

    int nRet     = 0;
    int nReturn  = 0;
	int nHttpRet = 0;
    int nLoop    = 0;
    int nCLen    = 0;

    pthread_detach(pthread_self());

#ifdef _LOG_FLAG_
	pConnCB->pLog->PrintLog(DEBUG_LEVEL, "recv thread start...");
#endif

    while(pConnCB->nRunFlag/* && g_ExitExe == 0*/)
    {
        sTimeOut.tv_sec  = 1;
        sTimeOut.tv_usec = 0;
        FD_ZERO(&sFDSet);
        FD_SET(pConnCB->nSocket, &sFDSet);
        nReturn = select(pConnCB->nSocket+1, &sFDSet, NULL, NULL, &sTimeOut);

        if (nReturn == 0)
        {
            continue;
        }
		else if (nReturn < 0)
		{
			goto goExit;
		}
        nLoop++;

        memset(aszData,0,sizeof(aszData));

		nHttpRet=EncryptRecvMsg(pConnCB->nSocket, aszData, sizeof(aszData));

        if (nHttpRet > 1)
        {
            //接收HTTP包体
            if (nHttpRet <= PACKET_MAXLEN)
		    {
                memcpy(&mTermCmdHead, aszData, sizeof(TERM_CMD_HEAD));
                pHead = NULL;
                pHead = &mTermCmdHead;
			    {
				    nRet = CLIENT_ntoh_cmd(pConnCB, nCLen, nMsgNotice, &pHead);

                    if (nMsgNotice % 100 == 0 && nMsgNotice != 0)
                    {
                        #ifdef _LOG_FLAG_
						if(pConnCB != NULL)
						{
							pConnCB->pLog->PrintLog(DEBUG_LEVEL, "msgnotice num:%d", nMsgNotice);
						}
                        #endif
                    }
			    } 
            }
			else
			{
#ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "data too big ,now close!");
		}
#endif
				pConnCB->fConnect = FALSE;
				pConnCB->fLogin   = FALSE;
				pConnCB->nRunFlag = 0;
				CLOSE_(pConnCB->nSocket);
				break;
			}
        }
        else if( nHttpRet == 0 )
		{
			continue;
		}
		else if(nHttpRet==EIMERR_RECV_TIMEOUT_SOCKET)//超时
		{
			continue;
		}
		else
        {
goExit:
#ifdef _LOG_FLAG_
if(pConnCB != NULL)
{
	pConnCB->pLog->PrintLog(DEBUG_LEVEL, "1:recv packet error,socket:%d,ret:%d errcode=%d ",pConnCB->nSocket,nHttpRet, WSAGetLastError() );		
}
#endif
            pConnCB->fConnect = FALSE;
            pConnCB->fLogin   = FALSE;
            pConnCB->nRunFlag = 0;
            CLOSE_(pConnCB->nSocket);
            break;
        }
    }
	}
	catch(...)
	{
		g_ThreadAliveCount--;
		return EIMERR_SUCCESS;
	}
	#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "recvthread exit");	
	}
	#endif
	printf("recvthread exit\n");
	g_ThreadAliveCount--;

    return EIMERR_SUCCESS;
}

// return :
//        0: 正常处理，但不入队列
//        1: 正常处理，并入队列
//        2: 还有命令
int CLIENT_ntoh_cmd(PCONNCB pConnCB, int &nContentLength, int &nMsgNotice, TERM_CMD_HEAD **ppHead)
{
    int nRet    = 1;
    int nReturn = 0;
    TERM_CMD_HEAD *pHead = *ppHead;
    
    ntoh_term_head(pHead);
    
    // insert queue
    MESSAGE Message;
    memset(&Message, 0, sizeof(Message));
    Message.wCmdID = pHead->wCmdID;
    
    switch(pHead->wCmdID)
    {
	//心跳应答
    case CMD_ALIVEACK:
        {
            RESULT *pResult = (RESULT*)pHead->aszMsg;
            *pResult = (RESULT)ntohl(*pResult); 
            if (*pResult != RESULT_SUCCESS)
            {
                pConnCB->fConnect = FALSE;
                pConnCB->fLogin   = FALSE;
                pConnCB->nRunFlag = 0;

				if(*pResult == RESULT_RELOGIN)	//user relogin
                {
				    pConnCB->fKick = TRUE;
                }
				if (*pResult == RESULT_FORBIDDENUSER)  //user forbidden
				{
					pConnCB->fForbidden = TRUE;
				}
                CLOSE_(pConnCB->nSocket);
                break;
            }
            break;
        }
    //登录应答
    case CMD_LOGINACK:
        {
			LOGINACK tLoginAck;
 
			toDecodeLOGINACK(&tLoginAck, (INT8*)pHead->aszMsg);
            ntoh_term_login_resp(&tLoginAck);
			pConnCB->dwUserID    = tLoginAck.uUserId;
			pConnCB->dwCompID    = tLoginAck.dwCompID;
			pConnCB->dwSessionID = tLoginAck.dwSessionID;

			memset(pHead->aszMsg, 0, sizeof(pHead->aszMsg));
			memcpy(pHead->aszMsg, &tLoginAck, sizeof(tLoginAck));
			 
			#ifdef _LOG_FLAG_
			if(pConnCB != NULL)
			{
				pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CMD_LOGINACK cmd=%d,result:%d",pHead->wCmdID,tLoginAck.ret );			
			}
			#endif
			pHead->wMsgLen = MSGHEAD_LEN+sizeof(tLoginAck);
            if (tLoginAck.ret == RESULT_SUCCESS)
            {
                pConnCB->fLogin = TRUE;
            }
            break;
        }
    //状态变更应答
    case CMD_LOGOUTACK:
        {
            LOGOUTACK *pAck = (LOGOUTACK*)pHead->aszMsg;
            ntoh_term_logout_resp(pAck);
    //        if (pAck->cStatus == 0 || pAck->cStatus == 3)
    //        {
    //            pConnCB->fLogin   = FALSE;
    //            pConnCB->nRunFlag = 0;
    //            pConnCB->fConnect = FALSE;
    //            CLOSE_(pConnCB->nSocket);
    //        }
            break;
        }
    //获取本企业信息
    case CMD_GETCOMPINFOACK:
        {
            GETCOMPINFOACK *pAck = (GETCOMPINFOACK*)pHead->aszMsg;
            ntoh_term_GetCompInfoAck(pAck);
            break;
        }
    //获取部门列表应答v1.1
    case CMD_GETDEPTLISTACK:
        {
            GETDEPTLISTACK *pAck = (GETDEPTLISTACK*)pHead->aszMsg;
            ntoh_term_GetDeptListAck(pAck);
            break;
        }
    //获取用户下载方式应答
	case CMD_GETDATALISTTYPEACK:
        {
		    GETDATALISTTYPEACK *pAck = (GETDATALISTTYPEACK*)pHead->aszMsg;
			ntoh_term_GETDATALISTTYPEACK(pAck);
            break;
        }
    //获取用户列表应答v1.1
    case CMD_GETUSERLISTACK:
        {
            GETUSERLISTACK *pAck = (GETUSERLISTACK*)pHead->aszMsg;
            ntoh_term_GetUserListAck(pAck);
            break;
        }
	//获取头像变化的用户列表v1.1
	case CMD_GET_HEAD_ICON_ADD_LIST_RSP:
		{
			TGetUserHeadIconListAck *pAck =  (TGetUserHeadIconListAck*)pHead->aszMsg;
			ntoh_TGetUserHeadIconListAck(pAck);
			break;
		}
    //获取部门用户列表应答v1.1
    case CMD_GETUSERDEPTACK:
        {
            GETUSERDEPTACK *pAck = (GETUSERDEPTACK*)pHead->aszMsg;
            ntoh_term_GetUserDeptAck(pAck);
            break;
        }
    //获取用户状态列表应答
    case CMD_GETUSERSTATEACK:
        {
            GETUSERSTATELISTACK *pAck = (GETUSERSTATELISTACK*)pHead->aszMsg;
            ntoh_term_GetUserStateAck(pAck);
            break;
        }
    //修改信息应答
    case CMD_MODIINFOACK:
        {
            MODIINFOACK *pAck = (MODIINFOACK*)pHead->aszMsg;
            ntoh_term_modiinfoAck(pAck);
            break;
        }
    //用户修改信息通知
    case CMD_MODIINFONOTICE:
        {
            MODIINFONOTICE *pNotice = (MODIINFONOTICE *)pHead->aszMsg;
            ntoh_term_modiinfonotice(pNotice);
            break;
        }
    //获取员工详细信息应答
    case CMD_GETEMPLOYEEINFOACK:
        {
            GETEMPLOYEEACK *pAck = (GETEMPLOYEEACK*)pHead->aszMsg;
            ntoh_term_GetEmployeeAck(pAck);
            break;
        }
    //用户状态变更通知
    case CMD_NOTICESTATE:
        {
			UINT16 szNum[4];//离线 0， 在线 1 ，离开 2，移动 3
			UINT8  szStatus[4];
			INT8* pInBuf=pHead->aszMsg;
			memcpy(szNum,pHead->aszMsg, sizeof(szNum));
			for(int i=0; i< 4; i++)
			{
				szNum[i]= ntohs(szNum[i]);
				szStatus[i]=i;
			}
			INT32 pos=sizeof(szNum);
			UINT8 cType=3;//3PC; 手机1，2 
			INT32 iUserNum=0;
			TUserStatusList tStatusList;
			memset(&tStatusList, 0, sizeof(tStatusList));
			for(int i=0; i< 4; i++)
			{

				if(i == 3)
					cType = 1;
				for(int j=0; j< szNum[i]; j++)
				{
					tStatusList.dwUserStatusNum++;
					tStatusList.szUserStatus[iUserNum].dwUserID=ntohl(*((UINT32*)(pInBuf+pos)));
					//手机在线
					if (i == 3)
						tStatusList.szUserStatus[iUserNum].cStatus = 1; 
					else
						tStatusList.szUserStatus[iUserNum].cStatus =szStatus[i];

					tStatusList.szUserStatus[iUserNum].cLoginType = cType;
					pos += sizeof(INT32);
					//memcpy(Message.aszData+ sizeof(UINT32)+iUserNum*sizeof(USERSTATUSNOTICE),&tStatusList.szUserStatus[iUserNum] ,sizeof(USERSTATUSNOTICE) );
					iUserNum++;
				}
			}

			pHead->wMsgLen=MSGHEAD_LEN+sizeof(TUserStatusList);
			memcpy(pHead->aszMsg, &tStatusList,sizeof(TUserStatusList));

            break;
        }

    //创建群组应答
    case CMD_CREATEGROUPACK:
        {
            CREATEGROUPACK *pAck = (CREATEGROUPACK*)pHead->aszMsg;
            ntoh_term_CreateGroupAck(pAck);
            break;
        }
    //群组创建通知
    case CMD_CREATEGROUPNOTICE:
        {
            CREATEGROUPNOTICE *pNotice = (CREATEGROUPNOTICE*)pHead->aszMsg;
            ntoh_term_CreateGroupNotice(pNotice);
            break;
        }
    //修改群组应答
    case CMD_MODIGROUPACK:
        {
            MODIGROUPACK *pAck = (MODIGROUPACK*)pHead->aszMsg;
            ntoh_term_ModiGroupAck(pAck);
            break;
        }
    //群组修改通知
    case CMD_MODIGROUPNOTICE:
        {
            MODIGROUPNOTICE *pNotice = (MODIGROUPNOTICE*)pHead->aszMsg;
            ntoh_term_ModiGroupNotice(pNotice);
            break;
        }
    //获取群组信息应答
    case CMD_GETGROUPACK:
        {
            GETGROUPINFOACK *pAck = (GETGROUPINFOACK*)pHead->aszMsg;
            ntoh_term_GetGroupAck(pAck);
            break;
        }
    //修改群组成员应答
    case CMD_MODIMEMBERACK:
        {
            MODIMEMBERACK *pAck = (MODIMEMBERACK*)pHead->aszMsg;
            ntoh_term_ModiMemberAck(pAck);
            break;
        }
    //修改群组成员通知
    case CMD_MODIMEMBERNOTICE:
        {
            MODIMEMBERNOTICE *pNotice = (MODIMEMBERNOTICE*)pHead->aszMsg;
            ntoh_term_ModiMemberNotice(pNotice);
            break;
        }
    //消息应答
    case CMD_SENDMSGACK:
        {
            SENDMSGACK *pAck = (SENDMSGACK*)pHead->aszMsg;
            ntoh_term_SendMsgAck(pAck);
            break;
        }
    //已读请求应答
    case CMD_MSGREADACK:
        {
            MSGREADACK *pAck = (MSGREADACK*)pHead->aszMsg;
            ntoh_term_MsgReadAck(pAck);
            break;
        }
	///////////////////////////////////////////////////////
	//added by rock
    case CMD_MSGCANCELACK:  //消息召回应答
        {
            MSGCancelACK *pAck = (MSGCancelACK*)pHead->aszMsg;
            ntoh_term_MsgCancelAck(pAck);
            break;
        }
	case CMD_MSGCANCELNOTICE:
		{
            MSGCancelNotice *pNotice = (MSGCancelNotice*)pHead->aszMsg;
            ntoh_term_MsgCancelNotice(pNotice);

			if(pNotice->cIsGroup == 3)//点对点自己消息
			{
				pNotice->cIsGroup = 0;
				UINT32 dwTmp = pNotice->dwRecverID; 
				pNotice->dwRecverID = pNotice->dwSenderID;
				pNotice->dwSenderID = dwTmp;
			}
			else if(pNotice->cIsGroup == 4)//自己群消息同步
			{
				pNotice->cIsGroup = 1;
				UINT32 dwTmp = pNotice->dwRecverID; 
				pNotice->dwRecverID = pNotice->dwSenderID;
				pNotice->dwSenderID = dwTmp;
			}
            nMsgNotice++;

			break;
		}
	///////////////////////////////////////////////////////

    //消息通知
    case CMD_MSGNOTICE:
        {
            MSGNOTICE *pNotice = (MSGNOTICE*)pHead->aszMsg;
            ntoh_term_MsgNotice(pNotice);
			if(pNotice->cIsGroup == 3)//点对点自己消息
			{
				pNotice->cIsGroup = 0;
				UINT32 dwTmp = pNotice->dwRecverID; 
				pNotice->dwRecverID = pNotice->dwSenderID;
				pNotice->dwSenderID = dwTmp;
			}
			else if(pNotice->cIsGroup == 4)//自己群消息同步
			{
				pNotice->cIsGroup = 1;
				UINT32 dwTmp = pNotice->dwRecverID; 
				pNotice->dwRecverID = pNotice->dwSenderID;
				pNotice->dwSenderID = dwTmp;
			}
            nMsgNotice++;
            // send message notice ack
            //CLIENT_SendMsgNoticeAck(pConnCB, pNotice->dwMsgID);
            break;
        }
	//网信客户端同步公众账号响应
	case CMD_ECWX_SYNC_RSP:
		{
			break;
		}
	//公众平台下行消息至网信客户端通知
	case CMD_ECWX_PACC_NOT:
		{
			//hton_term_head(pHead);
			ECWX_PUSH_NOTICE *pEcwxPushNotice = (ECWX_PUSH_NOTICE *)pHead->aszMsg;
			ntohl_ECWX_PUSH_NOTICE(pEcwxPushNotice);
			break;
		}
	// 开放平台下行至客户端的同步应答
	case CMD_APP_SYNC_ACK:
		{
			break;
		}
	//开放平台的token通知
	case CMD_APP_TOKEN_NOTICE:
		{
			break;
		}
	//开放平台的推送通知
	case CMD_APP_PUSH_NOTICE:
		{
			break;
		}
	//群组消息推送修改应答
	case CMD_GROUPPUSHFLAGACK:
		{
			GROUPPUSHFLAGACK *pAck =(GROUPPUSHFLAGACK*)pHead->aszMsg;
			pAck->result = (RESULT)ntohl(pAck->result);
			break;
		}
    //消息通知已接收确认
    case CMD_MSGNOTICECONFIRM:
        {
            MSGNOTICECONFIRM *pNoticeConfirm = (MSGNOTICECONFIRM*)pHead->aszMsg;
            ntoh_term_msgnoticeconfirm(pNoticeConfirm);
            break;
        }
    //消息已读通知
    case CMD_MSGREADNOTICE:
        {
            MSGREADNOTICE *pNotice = (MSGREADNOTICE*)pHead->aszMsg;
            ntoh_term_msgreadnotice(pNotice);
            break;
        }
    //广播消息应答
    case CMD_SENDBROADCASTACK:
        {
            SENDBROADCASTACK *pAck = (SENDBROADCASTACK*)pHead->aszMsg;
            ntoh_term_SendBroadAck(pAck);
            break;
        }
    //广播消息通知
    case CMD_BROADCASTNOTICE:
        {
            BROADCASTNOTICE *pNotice = (BROADCASTNOTICE*)pHead->aszMsg;
            ntoh_term_BroadNotice(pNotice);
            break;
        }
	//获取虚拟群组信息应答CMD_REGULAR_GROUP_UPDATE_RSP
    case CMD_REGULAR_GROUP_UPDATE_RSP:
        {
            REGULAR_GROUP_UPDATE_RSP *pAck = (REGULAR_GROUP_UPDATE_RSP*)pHead->aszMsg;
            ntoh_term_regulargroupupdatersp(pAck);
            break;
        }
    case CMD_CHECK_TIME_RESP:
        {
            CHECK_TIME_RESP *pAck = (CHECK_TIME_RESP*)pHead->aszMsg;
            ntoh_term_checktime_resp(pAck);
            break;
        }
	case CMD_GET_OFFLINE_RESP:
		{
			GET_OFFLINE_RESP *pAck = (GET_OFFLINE_RESP*)pHead->aszMsg;
			ntoh_term_getoffline_resp(pAck);
			break;
		}
    //主动退群应答
    case CMD_QUITGROUPACK:
        {
            QUITGROUPACK *pAck = (QUITGROUPACK*)pHead->aszMsg;
            pAck->nReturn = ntohs(pAck->nReturn);
            break;
        }
    //主动退群通知
    case CMD_QUITGROUPNOTICE:
        {
            QUITGROUPNOTICE *pNotice = (QUITGROUPNOTICE*)pHead->aszMsg;
            ntoh_term_QuitGroupNotice(pNotice);
            break;
        }
    //本人信息变更应答
    case CMD_RESETSELFINFOACK:
        {
            RESETSELFINFOACK *pAck = (RESETSELFINFOACK*)pHead->aszMsg;
            pAck->nReturn = ntohs(pAck->nReturn);
            break;
        }
    //用户信息变更通知
    case CMD_RESETSELFINFONOTICE:
        {
            RESETSELFINFONOTICE *pNotice = (RESETSELFINFONOTICE*)pHead->aszMsg;
            ntoh_term_resetselfinfo_notice(pNotice);
            break;
		}
	//日程创建请求应答
	case CMD_CREATESCHDULEACK:
		{
			CREATESCHEDULEACK *pAck = (CREATESCHEDULEACK*)pHead->aszMsg;
			pAck->result = (RESULT)ntohl(pAck->result);
			break;
		}
	//日程创建通知
	case CMD_CREATESCHDULENOTICE:
		{
            CREATESCHEDULENOTICE *pNotice = (CREATESCHEDULENOTICE*)pHead->aszMsg;
            ntoh_term_CreateScheduleNotice(pNotice);
			break;
		}
	//日程删除通知
	case CMD_DELETESCHDULENOTICE:
		{
            DELETESCHEDULE *pNotice = (DELETESCHEDULE*)pHead->aszMsg;
            pNotice->dwUserID = ntohl(pNotice->dwUserID);
			break;
		}
    //日程删除应答
    case CMD_DELETESCHDULEACK:
        {
            DELETESCHEDULEACK *pAck = (DELETESCHEDULEACK*)pHead->aszMsg;
            pAck->result = (RESULT)ntohl(pAck->result);
            break;
        }
    //服务端发起企业相关最后更新时间的通知
    case CMD_COMPLASTTIMENOTICE:
        {
            COMPLASTTIMENOTICE *pNotice = (COMPLASTTIMENOTICE*)pHead->aszMsg;
            ntoh_term_complsttime_notice(pNotice);
            break;
        }
	//IOS转后台运行应答
	case CMD_IOSBACKGROUND_ACK:
		{
			IOSBACKGROUNDACK* pBody = (IOSBACKGROUNDACK*)pHead->aszMsg;
			break;
		}
	//获取级别(员工所属)应答 118
	case CMD_GETUSERRANK_ACK:
		{
			GETUSERPAASK *pNotice = (GETUSERPAASK*)pHead->aszMsg;
			ntoh_getuserrpa_ack(pNotice);
			break;
		}
	//获取业务(员工所属)应答 120
	case CMD_GETUSERPROFE_ACK:
		{
			GETUSERPAASK *pNotice = (GETUSERPAASK*)pHead->aszMsg;
			ntoh_getuserrpa_ack(pNotice);
			break;
		}
	//获取地域(员工所属)应答 122
	case CMD_GETUSERAREA_ACK:
		{
			GETUSERPAASK *pNotice = (GETUSERPAASK*)pHead->aszMsg;
			ntoh_getuserrpa_ack(pNotice);
			break;
		}
	//获取特殊用户列表应答
	case CMD_GETSPECIALLISTACK:
		{
			GETSPECIALLISTACK mAck;
			memset(&mAck, 0, sizeof(GETSPECIALLISTACK));
			//int mDateLen = pHead->wMsgLen - MSGHEAD_LEN;

			//还原有效数据到定长数据
			int mPos = 0;
			memcpy(&mAck, (char *)&pHead->aszMsg + mPos, 2*(sizeof(UINT16) + sizeof(UINT32)));

			mPos += 2*(sizeof(UINT16) + sizeof(UINT32));
			memcpy(&mAck.mSpecialList,
					(char *)&pHead->aszMsg + mPos, 
					ntohs(mAck.wSpecialNum) * sizeof(SpecialList_t));

			mPos += ntohs(mAck.wSpecialNum) * sizeof(SpecialList_t);
			memcpy(&mAck.mWhiteList,
					(char *)&pHead->aszMsg + mPos,
					ntohs(mAck.wWhiteNum) * sizeof(WhiteList_t));

			mPos += ntohs(mAck.wWhiteNum) * sizeof(WhiteList_t);
			mAck.cPageSeq = pHead->aszMsg[mPos];

			ntoh_GETSPECIALLISTACK(&mAck);

			memset(pHead->aszMsg, 0, PACKET_MAXLEN);
			memcpy(pHead->aszMsg, &mAck, sizeof(GETSPECIALLISTACK));

			pHead->wMsgLen = sizeof(GETSPECIALLISTACK) + MSGHEAD_LEN;

			//GETSPECIALLISTACK *pAck = (GETSPECIALLISTACK *)pHead->aszMsg;
			//ntoh_GETSPECIALLISTACK(pAck);		
  
			break;
		}
	//获取修改黑名单通知
	case CMD_MODISPECIALLISTNOTICE:
		{
			MODISPECIALLISTNOTICE mNotice;
			memset(&mNotice, 0, sizeof(MODISPECIALLISTNOTICE));
			//int mDateLen = pHead->wMsgLen - MSGHEAD_LEN;

			//还原有效数据到定长数据
			int mPos = 0;
			int mLen = sizeof(UINT64) + sizeof(UINT32) + 2 * sizeof(UINT16);
			memcpy(&mNotice, (char *)&pHead->aszMsg + mPos, mLen);

			mPos += mLen;
			mLen = ntohs(mNotice.wSpecialNum) * sizeof(SpecialList_t);
			memcpy(&mNotice.mSpecialList, (char *)&pHead->aszMsg + mPos, mLen);

			mPos += mLen;
			mLen = ntohs(mNotice.wWhiteNum) * sizeof(WhiteList_t);
			memcpy(&mNotice.mWhiteList, (char *)&pHead->aszMsg + mPos, mLen);

			mPos += mLen;
			mNotice.cPageSeq = pHead->aszMsg[mPos];

			ntoh_MODISPECIALLISTNOTICE(&mNotice);

			memset(pHead->aszMsg, 0, PACKET_MAXLEN);
			memcpy(pHead->aszMsg, &mNotice, sizeof(MODISPECIALLISTNOTICE));

			pHead->wMsgLen = sizeof(MODISPECIALLISTNOTICE) + MSGHEAD_LEN;

			//MODISPECIALLISTNOTICE* pBody=(MODISPECIALLISTNOTICE*)pHead->aszMsg;
			//ntoh_MODISPECIALLISTNOTICE(pBody);

			break;
		}
	case CMD_ROAMINGDATASYNACK:	//176	漫游数据同步请求应答
		{
			ROAMDATASYNCACK *pRoamingDataSyncAck = (ROAMDATASYNCACK *)pHead->aszMsg;
			ntoh_term_ROAMDATASYNCACK(pRoamingDataSyncAck);
			break;
		}
	case CMD_ROAMINGDATAMODIACK://178	漫游数据增加、删减请求应答
		{
			ROAMDATAMODIACK *pRoamingDataModiAck = (ROAMDATAMODIACK *)pHead->aszMsg;
			ntoh_term_ROAMDATAMODIACK(pRoamingDataModiAck);
			break;
		}
	case CMD_ROAMINGDATAMODINOTICE://179	漫游数据增加、删减通知
		{
			ROAMDATAMODINOTICE *pRoamingDataModiNotice = (ROAMDATAMODINOTICE *)pHead->aszMsg;
			ntoh_term_ROAMDATAMODINOTICE(pRoamingDataModiNotice);
			break;
		}
	case CMD_NOTICESTATE_ALL:
		{
			TALLUserStatus  tAllStatus;

			memcpy(&tAllStatus,pHead->aszMsg, sizeof(tAllStatus));

			tAllStatus.uBegUserID = ntohl(tAllStatus.uBegUserID);
			tAllStatus.uEndUserID = ntohl(tAllStatus.uEndUserID);
			UINT32 uBegId= tAllStatus.uBegUserID;
			UINT32 uEndId=0;
			
			INT32 iGetNum = 0;;
			INT32 iOver=0;

			TGetStatusRsp tStatusList;
			memset(&tStatusList, 0, sizeof(TGetStatusRsp));

			for(;;)
			{
				if((tAllStatus.uEndUserID-uBegId+1) >MAX_USERSTATUS_NUM )
				{
					iGetNum = MAX_USERSTATUS_NUM;
				}
				else
				{
					iOver=1;
					iGetNum = tAllStatus.uEndUserID-uBegId+1;
				}
				memset(&tStatusList, 0, sizeof(TGetStatusRsp));
				toDecodeTALLUserStatus(&tAllStatus, uBegId,iGetNum, &tStatusList,  &uEndId);
				uBegId = uEndId +1;
				MESSAGE msg;
				msg.wCmdID = CMD_NOTICESTATE;
				memcpy(msg.aszData, &tStatusList,sizeof(tStatusList) );            
				NODE node;
				node.len = sizeof(MESSAGE);
				node.data = (char*)&msg;
				nReturn = mq_push(pConnCB->pQueueMsg, &node);
				if (nReturn == -1)
				{
					#ifdef _LOG_FLAG_
					if(pConnCB != NULL)
					{
						pConnCB->pLog->PrintLog(DEBUG_LEVEL, "status:input mq_push queue fail:\n");
					}
					#endif
					uSleep(100);
					nReturn = mq_push(pConnCB->pQueueMsg, &node);
					#ifdef _LOG_FLAG_
					if(pConnCB != NULL)
					{
						pConnCB->pLog->PrintLog(DEBUG_LEVEL, "2 times status:input mq_push queue fail:\n");
					}
					#endif
				}
				if(iOver)
					break;
			}
#ifdef _LOG_FLAG_
			if(pConnCB != NULL)
			{
				pConnCB->pLog->PrintLog(DEBUG_LEVEL, "get a full user status start userid %d end userid %d",
					tAllStatus.uBegUserID,tAllStatus.uEndUserID);
			}
#endif
			return EIMERR_SUCCESS;
		break;
		}
	case CMD_PROTOCOL_V2://协议2
		{
			
			switch(pHead->aszMsg[0])
			{
			case THead::SUBCRIBE_SERVICE://订阅
					{
						SUBSCRIBER_ACK *pAck=(SUBSCRIBER_ACK*)pHead->aszMsg;
						ntoh_SUBSCRIBER_ACK(pAck);
						pHead->wMsgLen=MSGHEAD_LEN+sizeof(SUBSCRIBER_ACK);
						break;
					}
				default:
					break;
			}

			break;
		}
	//创建固定组通知
	case CMD_CREATEREGULARGROUPNOTICE:
		{
			CREATEREGULARGROUPNOTICE *pNotice = (CREATEREGULARGROUPNOTICE *)pHead->aszMsg;
			ntoh_term_CreateRegularGroupNotice(pNotice);
			break;
		}
	//创建固定组通知协议2
	case CMD_GULARGROUP_PROTOCOL2_CREATENOTICE:
		{
			CREATEREGULARGROUPPROTOCOL2NOTICE *pNotice = (CREATEREGULARGROUPPROTOCOL2NOTICE *)pHead->aszMsg;
			ntoh_term_CreateRegularGroupProtocol2Notice(pNotice);
			break;
		}
	//删除固定组通知
	case CMD_DELETEREGULARGROUPNOTICE:
		{
			DELETEREGULARGROUPNOTICE *pNotice = (DELETEREGULARGROUPNOTICE *)pHead->aszMsg;
			ntoh_term_DeleteRegularGroupNotice(pNotice);
			break;
		}
	//184	相同客户端重登录通知（剔重通知）
	case CMD_RELOGINNOTICE:			
		{
			CLIENT_RELOGIN_NOTICE *pNotice = (CLIENT_RELOGIN_NOTICE*)pHead->aszMsg;
			pNotice->dwUserID = ntohl(pNotice->dwUserID);

			if (pConnCB->dwUserID == pNotice->dwUserID)	//user relogin
			{
				pConnCB->fKick = TRUE;
			}
			break;
		}
	case CMD_FORBIDDENNOTICE:
		{
			CLIENT_FORBIDDEN_NOTICE *pNotice = (CLIENT_FORBIDDEN_NOTICE*)pHead->aszMsg;
			pNotice->dwUserID = ntohl(pNotice->dwUserID);
			pNotice->dwTime = ntohl(pNotice->dwTime);

			if (pConnCB->dwUserID == pNotice->dwUserID)	//user forbidden
			{
				pConnCB->fForbidden = TRUE;
			}

			break;
		}
	case CMD_READMSGSYNCNOTICE:
		{
			MSG_READ_SYNC *pNotice = (MSG_READ_SYNC *)pHead->aszMsg;
			ntoh_term_MSG_READ_SYNC(pNotice);
			break;
		}
	case CMD_ROBOTSYNCRSP:
		{
			ROBOTSYNCRSP *pRsp = (ROBOTSYNCRSP *)pHead->aszMsg;
			ntoh_term_ROBOTSYNCRSP(pRsp);
			break;
		}
	//通讯录全量更新通知
	case CMD_CONTACTSCLEANNOTICE:
		{
			CONTACTSUPDATENOTICE *pRsp = (CONTACTSUPDATENOTICE *)pHead->aszMsg;
			ntoh_term_CONTACTSUPDATENOTICE(pRsp);
			break;
		}
	//虚拟组信息应答
	case CMD_VIRTUAL_GROUP_ACK:
		{
			VIRTUAL_GROUP_INFO_ACK *pVirAck = (VIRTUAL_GROUP_INFO_ACK *)pHead->aszMsg;
			ntoh_term_virgroup_info_ack(pVirAck);
			break;
		}
	//虚拟组信息通知
	case CMD_VIRTUAL_GROUP_NOTICE:
		{
			VIRTUAL_GROUP_INFO_NOTICE *pVirNotice = (VIRTUAL_GROUP_INFO_NOTICE *)pHead->aszMsg;
			ntoh_term_virgroup_info_notice(pVirNotice);
			break;
		}
	//收藏同步应答
	case CMD_FAVORITE_SYNC_ACK:
		{
			FAVORITE_SYNC_ACK *pFavoriteAck = (FAVORITE_SYNC_ACK *)pHead->aszMsg;
			ntoh_term_favorite_sync_ack(pFavoriteAck);
			break;
		}
	//收藏通知
	case CMD_FAVORITE_NOTICE:
		{
			FAVORITE_NOTICE *pFavoriteNotice = (FAVORITE_NOTICE *)pHead->aszMsg;
			ntoh_term_favorite_notice(pFavoriteNotice);
			break;
		}
	//收藏操作应答
	case CMD_FAVORITE_MODIFY_ACK:
		{
			FAVORITE_MODIFY_ACK *pFavModAck = (FAVORITE_MODIFY_ACK *)pHead->aszMsg;
			ntoh_term_favorite_modify_ack(pFavModAck);
			break;
		}
    case CMD_DEPTSHOWCONFIG_ACK:
        {
            GETDEPTSHOWCONFIGACK *pAck = (GETDEPTSHOWCONFIGACK*)pHead->aszMsg;
            ntoh_term_GetDeptShowConfigAck(pAck);
            if (pAck->dwUserID != pConnCB->dwUserID)
            {
                pAck->cUpdateFlag = 0;
                memset(pAck->strPacketBuff,0,sizeof(pAck->strPacketBuff));
            }
            break;
        }
        //会议相关通知:  会议基本信息,成员列表,文件,距离开会时间
    case CMD_MEETING_INFO_NOTICE:
        {
            confInfoNotice *pMeetingNotice = (confInfoNotice*)pHead->aszMsg;
            ntoh_MeetingBaseInfoNotice(pMeetingNotice);
        }
        break;
    case CMD_MEETING_LEVEL_NOTICE:
    case CMD_MEETING_MBRINFO_NOTICE:
        {
            confMbrInfoNotice* pMeetingNotice = (confMbrInfoNotice*)pHead->aszMsg;
            ntoh_MeetingMbrInfoNotice(pMeetingNotice);
        }
        break;
    case CMD_MEETING_FILEINFO_NOTICE:
        {
            confFileInfoNotice *pMeetingNotice = (confFileInfoNotice*)pHead->aszMsg;
            ntoh_MeetingFileInfoNotice(pMeetingNotice);
        }
        break;
    case CMD_MEETING_USERINFO_NOTICE:
        {
            confUserInfoNotice *pMeetingNotice = (confUserInfoNotice*)pHead->aszMsg;
            ntoh_MeetingUserInfoNotice(pMeetingNotice);
        }
        break;
    case CMD_MEETING_REMARKS_NOTICE:
        {
            confRemarksNotice *pMeetingNotice = (confRemarksNotice*)pHead->aszMsg;
            pMeetingNotice->dwUserId = ntohl(pMeetingNotice->dwUserId);
        }break;
    default:
        {
            nRet = 0;
            printf("wCmdID:%d\n", pHead->wCmdID); 
            break;
        }
    }
                    
    if (pHead->wCmdID == CMD_ALIVEACK && !pConnCB->fKick && !pConnCB->fForbidden) 
    {
		#ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CMD_ALIVEACK return \n");
		}
        #endif
        return nRet;
    }
    if (nRet == 0) 
    {
		#ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "nRet == 0 return \n");
		}
        #endif
        return EIMERR_SUCCESS;
    }
	NODE node;
	memset(&node, 0, sizeof(NODE));
    //插入队列
	if (pHead->wMsgLen > MSGHEAD_LEN)
	{
		memcpy(Message.aszData, pHead->aszMsg, pHead->wMsgLen - MSGHEAD_LEN); 
		node.len = sizeof(Message);
		node.data = (char*)&Message;
		nReturn = mq_push(pConnCB->pQueueMsg, &node);
	}
	else
	{
		nReturn = -2;

	}

    if (nReturn == -1)
    {
        #ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "1:input queue fail:\n");
		}
        #endif
        uSleep(100);
        nReturn = mq_push(pConnCB->pQueueMsg, &node);
    }
    else if (nReturn == -2)
    {
        #ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "2:input queue fail:\n");
		}
        #endif
    }
	LOGOUTACK *pAck = (LOGOUTACK*)pHead->aszMsg;
	if (pHead->wCmdID==CMD_LOGOUTACK &&  (pAck->cStatus == 0 || pAck->cStatus == 3))
    {
		#ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CMD_LOGOUTACK close\n");
		}
        #endif
		uSleep(50);
        pConnCB->fLogin   = FALSE;
        pConnCB->nRunFlag = 0;
        pConnCB->fConnect = FALSE;
        CLOSE_(pConnCB->nSocket);
    }
    return nRet;
}
#ifdef WIN32
IM_API( int )  CLIENT_GetMessage(PCONNCB pConnCB, MESSAGE *pMessage)
#else
int   CLIENT_GetMessage(PCONNCB pConnCB, MESSAGE *pMessage)
#endif
{
    NODE node;

    if (pConnCB == NULL || pMessage == NULL)
        return EIMERR_INVALID_PARAMTER;
   
    if (pConnCB->fKick)
        return EIMERR_KICK;

	if (pConnCB->fForbidden)
		return EIMERR_FORBIDDEN;

	if (!pConnCB->fConnect && !pConnCB->fKick && !pConnCB->fForbidden)
		return EIMERR_NOT_CONN;

    if (mq_empty(pConnCB->pQueueMsg))
        return EIMERR_EMPTY_MSG;

    node.data = (char*)pMessage;
    return mq_pop(pConnCB->pQueueMsg, &node) ? EIMERR_SUCCESS : EIMERR_EMPTY_MSG;
}

#ifdef WIN32
IM_API( PCONNCB) CLIENT_Init(QY_ACCESS_MODE cMode, const char* pszLogFile)
#else
PCONNCB CLIENT_Init(QY_ACCESS_MODE cMode, const char* pszLogFile)
#endif
{
    PCONNCB pConnCB = NULL;
#ifdef WIN32
    WORD wVersion;
    WSADATA WSAData;
    wVersion=MAKEWORD(2,0);
    int err = WSAStartup(wVersion,&WSAData);
    if(0 != err)
    {
        return NULL;
    }
    if(LOBYTE( WSAData.wVersion ) != 2)
    {
        WSACleanup();
        return NULL;
    }
#endif

	g_ExitExe = 0;
    pConnCB = (PCONNCB)malloc(sizeof(CONNCB));
    memset(pConnCB, 0, sizeof(CONNCB));

    pConnCB->dwSessionID = 0;
    pConnCB->cAccessMode = CMNET; 
    pConnCB->fConnect = FALSE;
    pConnCB->fLogin = FALSE;
	pConnCB->fKick  = 0;
	pConnCB->fForbidden = 0;

	pConnCB->dwAliveTime=30;
    pConnCB->pQueueMsg = mq_create(5000);

	//Guojian Add 2015-03-28
	pthread_mutex_init(&pConnCB->mConnectlock, NULL);
	//end Guojian Add 2015-03-28

#ifdef _LOG_FLAG_
	pConnCB->pLog = new SysLog();
	pConnCB->pLog->OpenLogFile((pszLogFile == NULL || pszLogFile[0] == '\0') ? "log" : pszLogFile );
	pConnCB->pLog->SetLogLevel(4);
#endif

//pConnCB->aes.SetKey((unsigned char*)pConnCB->rsa.GetInitAesKey());

	InitRsa();
	//strcpy(m_strRsaPathFile,"D:\\sxit\\svn\\svnclient\\out\\Debug\\rsa_public.key");
	LoadPublicKeyFile(m_strRsaPathFile);
	InitAes();
 
	pthread_mutex_init(&g_SeqLock,NULL);
    return pConnCB;
}
INT32 SetNoBlock( SOCKET& nSocket )
{
	INT32               lRetVal;

	if ( nSocket == 0 )
		return EIMERR_INVALID_PARAMTER;

#ifdef WIN32
	unsigned long l= 1;
	lRetVal= ioctlsocket( nSocket, FIONBIO, &l );

	if ( lRetVal < 0 )
		return EIMERR_SOCKET_GETOPT_SOCKET;
#else
	//设置非阻塞通讯方式
	lRetVal= fcntl( nSocket, F_GETFL, 0 );

	if ( lRetVal < 0 )
		return EIMERR_SOCKETSETOPT;

	lRetVal |= O_NONBLOCK;
	fcntl( nSocket, F_SETFL, lRetVal );
#endif

	return EIMERR_SUCCESS;
}

int CLIENT_ConnectAccess(PCONNCB pConnCB, char *ip, unsigned short  port,TAccessRequest *pTAccessRequest,LOGINACCESSACK*pAccessAck,int connectTimeout,int RecvTimeOut)
{
    struct sockaddr_in servaddr;
	int socklen = sizeof(servaddr);
    SOCKET nSocket;
    int nCmdLen = 0;
    int nRet = 0;
    char aszHttpBuf[HTTPHEAD_MAXLEN+2];
    memset(aszHttpBuf, 0, sizeof(aszHttpBuf));
    char aszPacket[PACKET_MAXLEN];
    memset(aszPacket, 0, sizeof(aszPacket));
    char strChange[PACKET_MAXLEN];
    memset(strChange, 0, sizeof(strChange));
	char szIp[30]="";
 
    char *pHostName = ip;
    struct hostent *host;

    struct timeval  sTimeOut;
    fd_set			sFDSet;
    struct linger   sLin;

    CHECK_NULL_RET_(pConnCB);

    if ((nSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {  
#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
        pConnCB->pLog->PrintLog(DEBUG_LEVEL, "create socket error %s, err:%d\n", ip, errno);
	}
#endif
        return EIMERR_SOCKETFD_SOCKET;
    }

    /*strcpy(pConnCB->aszAccessIP, ip);
    pConnCB->nAccessPort = port;*/

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;

    if (isalpha (pHostName[0]))
    {
        host = gethostbyname(pHostName);
        if (host == NULL)
        {
#ifdef _LOG_FLAG_
			if(pConnCB != NULL)
			{
				pConnCB->pLog->PrintLog(DEBUG_LEVEL, "cannot get host by hostname %s, err:%d\n", ip, errno);
			}
#endif
            return EIMERR_GETHOSTNAME_SOCKET;
        }

        //strcpy(pConnCB->aszAccessIP, inet_ntoa(*((struct in_addr*)host->h_addr)));
		strcpy(szIp, inet_ntoa(*((struct in_addr*)host->h_addr)));
    }
	else
	{
		strcpy(szIp, ip);
	}

#ifdef WIN32
    	servaddr.sin_addr.S_un.S_addr = inet_addr(szIp);
	//	servaddr.sin_addr.S_un.S_addr = inet_addr(pConnCB->aszAccessIP);
#else
		inet_aton(szIp, &servaddr.sin_addr);
    //	inet_aton(pConnCB->aszAccessIP, &servaddr.sin_addr);
#endif
    servaddr.sin_port = htons(port);

 //   int nOpt = 1;
	sLin.l_onoff         = 1;        
    sLin.l_linger        = 0;
#ifdef WIN32
    setsockopt(nSocket, SOL_SOCKET, SO_LINGER, (const char*)&sLin, sizeof(sLin));
#else
    setsockopt(nSocket, SOL_SOCKET, SO_LINGER, &sLin, sizeof(sLin));
    //setsockopt(nSocket, SOL_SOCKET, SO_NOSIGPIPE, &nOpt, sizeof(nOpt));
#endif

	int nRecvBuf=1024*1024;//设置为 
	setsockopt(nSocket,SOL_SOCKET,SO_RCVBUF,(const char*)&nRecvBuf,sizeof(int));
	int nSendBuf=1024*1024;//设置为 
	setsockopt(nSocket,SOL_SOCKET,SO_SNDBUF,(const char*)&nSendBuf,sizeof(int));


    SetNoBlock(nSocket);

    nRet = connect(nSocket, (struct sockaddr*)&servaddr, socklen);

    if (nRet != 0)
    {
	    sTimeOut.tv_sec  = connectTimeout;
	    sTimeOut.tv_usec = 0;
	    FD_ZERO(&sFDSet);
	    FD_SET(nSocket, &sFDSet);
        nRet = select(nSocket+1, NULL, &sFDSet, NULL, &sTimeOut);
   
        if(nRet <=0)
        {
            CLOSE_(nSocket);
            return EIMERR_CONNECT_TIMEOUT_SOCKET;
        }
        int nErr = -1;
        int nErrLen = sizeof(int);
        getsockopt(nSocket, SOL_SOCKET, SO_ERROR, (char*)&nErr, (socklen_t *)&nErrLen); 
        if (nErr != 0)
        {
            CLOSE_(nSocket);
            return EIMERR_SOCKET_GETOPT_SOCKET;
        }
    }

    memset(aszPacket, 0, sizeof(aszPacket));

	LV1024 tLV1024;
	toBytesTAccessRequest(pTAccessRequest,&tLV1024);

	nCmdLen = tLV1024.len;
 

    TERM_CMD_HEAD tHead;
    tHead.wCmdID=9;
    tHead.wMsgLen = 8+nCmdLen;
    hton_term_head(&tHead);
    char szTmp[1000]="req";
    
 
	memcpy(tHead.aszMsg, tLV1024.value,nCmdLen);
    memcpy(szTmp+3, &tHead, nCmdLen+8);

	nRet = SendData(nSocket, (char*)szTmp, nCmdLen+8+3);
    if (nRet < nCmdLen)
    {
#ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "send fail, nRet:%d, errno:%d\n", nRet, errno);
		}
#endif
        CLOSE_(nSocket);
        return nRet;
    }

     memset(aszPacket,0,sizeof(aszPacket));
    {

        nRet = RecvMsg(nSocket, aszPacket, sizeof(aszPacket),RecvTimeOut);
        if (nRet < 0 )
        {
#ifdef _LOG_FLAG_
			if(pConnCB != NULL)
			{
				pConnCB->pLog->PrintLog(DEBUG_LEVEL, "recv fail, nSocket:%d, nRet:%d, errno:%d\n", nSocket, nRet, errno);
			}
#endif
            CLOSE_(nSocket);
            return nRet;
        }
        else
        {
         
            TERM_CMD_HEAD *pHead;
            pHead = (TERM_CMD_HEAD *)aszPacket;
            ntoh_term_head(pHead);

			toDecodeLOGINACCESSACK(pAccessAck,(INT8*)(pHead->aszMsg));
 
			memcpy(&pConnCB->tAccessAck,pAccessAck,sizeof(pConnCB->tAccessAck));
			if (pAccessAck->ret == 0)
            {
                CLOSE_(nSocket);
                return EIMERR_SUCCESS;
            }
			else 
			{
				CLOSE_(nSocket);
				return (CLIENT_GetErrorCode((RESULT)pAccessAck->ret));
			}
        }

    }
    
    CLOSE_(nSocket);
    return EIMERR_SOCKET_OTHERS_ERR;
}
#ifdef WIN32
IM_API( int )  CLIENT_GetVersionInfo(PCONNCB pConnCB, TERMINAL_TYPE cType, int *pUpdateFlag, char *pszVerInfo, char *pszURL)
#else
int  CLIENT_GetVersionInfo(PCONNCB pConnCB, TERMINAL_TYPE cType, int *pUpdateFlag, char *pszVerInfo, char *pszURL)
#endif
{
    CHECK_NULL_RET_(pConnCB);
	/*
    if (cType == TERMINAL_PC)
    {
        *pUpdateFlag = pConnCB->nUpdateFlag1;
        strcpy(pszVerInfo, pConnCB->aszVerInfo1);
        strcpy(pszURL, pConnCB->aszURL1);
    }
    else if (cType == TERMINAL_ANDROID)
    {
        *pUpdateFlag = pConnCB->nUpdateFlag2;
        strcpy(pszVerInfo, pConnCB->aszVerInfo2);
        strcpy(pszURL, pConnCB->aszURL2);
    }
    else if(cType == TERMINAL_IOS)
    {
        *pUpdateFlag = pConnCB->nUpdateFlag3;
        strcpy(pszVerInfo, pConnCB->aszVerInfo3);
        strcpy(pszURL, pConnCB->aszURL3);
    }
	*/
    return 0;
}

#ifdef WIN32
IM_API( int )	CLIENT_Connect(PCONNCB pConnCB, char *ip, unsigned short port,char* pAccount,char type,char* pVersion,TERMINAL_TYPE  osType,int connectTimeout,int RecvTimeOut,char* pFailService, unsigned short failPort)
#else
int				CLIENT_Connect(PCONNCB pConnCB, char *ip, unsigned short port,char* pAccount,char type,char* pVersion,TERMINAL_TYPE  osType,int connectTimeout,int RecvTimeOut,char* pFailService, unsigned short failPort)
#endif
{
    struct sockaddr_in servaddr;
	int socklen = sizeof(servaddr);
    pthread_t tid = 0;
    char *pHostName = NULL;
    struct hostent *host;
    char aszIP[256]="";
 
    struct timeval	sTimeOut;
    fd_set			sFDSet;
    int nReturn = 0;

	//Guojian Add 2015-03-28
	//保证同时只有一个连接请求
	pthread_mutex_lock(&pConnCB->mConnectlock);
	//end Guojian Add 2015-03-28

	//Guojian Modify 2015-03-28
    if (pConnCB->fConnect) 
	{
		//return EIMERR_SUCCESS;
		//返回重复登录
		pthread_mutex_unlock(&pConnCB->mConnectlock);

		#ifdef _LOG_FLAG_
		if(pConnCB != NULL)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL,
				"repeat connect,nowsocket%d,flagconnect:%u,flaglogin:%u,flagkick:%u,flagforbidden:%u",
				pConnCB->nSocket,pConnCB->fConnect,pConnCB->fLogin,pConnCB->fKick,pConnCB->fForbidden);
		}
		#endif
		return EIMERR_REPEAT_LOGIN;
	}
	//end Guojian Modify 2015-03-28
	
    pConnCB->fLogin = FALSE;
    pConnCB->fKick = FALSE;
	pConnCB->fForbidden = FALSE;

	TAccessRequest tTAccessRequest;
	memset(&tTAccessRequest,0,sizeof(tTAccessRequest));
	tTAccessRequest.osType = osType;

	if(pFailService!=NULL)
	{
		tTAccessRequest.tFailServiceAddr.len=strlen(pFailService);
		if(tTAccessRequest.tFailServiceAddr.len <= tTAccessRequest.tFailServiceAddr.MAXLEN )
			strncpy(tTAccessRequest.tFailServiceAddr.value,pFailService,tTAccessRequest.tFailServiceAddr.len);
	}
	strncpy(tTAccessRequest.szVer,pVersion,sizeof(tTAccessRequest.szVer));
	if(pAccount!=NULL)
	{
		tTAccessRequest.tUserAccount.len=strlen(pAccount);
		if(tTAccessRequest.tUserAccount.len <=tTAccessRequest.tUserAccount.MAXLEN)
		{
			strncpy(tTAccessRequest.tUserAccount.value,pAccount,tTAccessRequest.tUserAccount.len);
		}
	}
	tTAccessRequest.type=type;
	tTAccessRequest.uPort=failPort;
	LOGINACCESSACK tAccessAck;
    memset(&tAccessAck,0, sizeof(tAccessAck));
    if ((nReturn=CLIENT_ConnectAccess(pConnCB, ip, port,&tTAccessRequest,&tAccessAck,connectTimeout,RecvTimeOut )) != 0)
    {
		memcpy(&pConnCB->tAccessAck, &tAccessAck, sizeof(pConnCB->tAccessAck));
		pthread_mutex_unlock(&pConnCB->mConnectlock);
        return nReturn;
    }
	memcpy(&pConnCB->tAccessAck, &tAccessAck, sizeof(pConnCB->tAccessAck));
	if(nReturn == 0 && tAccessAck.ret > 0)
	{
		pthread_mutex_unlock(&pConnCB->mConnectlock);
		return EIMERR_ACCESS_MANAGER_FAIL-tAccessAck.ret;
	}

	pConnCB->nSocket = socket(AF_INET, SOCK_STREAM, 0);
	if (pConnCB->nSocket == SOCKET_RETURN_ERROR)
    {  
		pthread_mutex_unlock(&pConnCB->mConnectlock);
        return EIMERR_SOCKETFD_SOCKET; 
    }
	strncpy(aszIP, pConnCB->tAccessAck.tServiceAddr.value,pConnCB->tAccessAck.tServiceAddr.len);
    pHostName = aszIP;
    if (isalpha (pHostName[0]))
    {
        host = gethostbyname(pHostName);
        if (host == NULL)
        {
			pthread_mutex_unlock(&pConnCB->mConnectlock);
            return EIMERR_GETHOSTNAME_SERVICE_SOCKET;
        }
        strcpy(aszIP, inet_ntoa(*((struct in_addr*)host->h_addr)));
    }

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
#ifdef WIN32
    //servaddr.sin_addr.S_un.S_addr = inet_addr(pConnCB->aszIP);
    servaddr.sin_addr.S_un.S_addr = inet_addr(aszIP);
#else
    //inet_aton(ip, &servaddr.sin_addr);
    inet_aton(aszIP, &servaddr.sin_addr);
#endif
	servaddr.sin_port = htons(pConnCB->tAccessAck.uPort);

    struct linger       sLin;
	sLin.l_onoff         = 1;        
    sLin.l_linger        = 0;
#ifdef WIN32
    setsockopt(pConnCB->nSocket, SOL_SOCKET, SO_LINGER, (const char*)&sLin, sizeof(sLin));
#else
    setsockopt(pConnCB->nSocket, SOL_SOCKET, SO_LINGER, &sLin, sizeof(sLin));
    //setsockopt(pConnCB->nSocket, SOL_SOCKET, SO_NOSIGPIPE, &nOpt, sizeof(nOpt));
#endif

	int nRecvBuf=1024*1024;//设置为 
	setsockopt(pConnCB->nSocket,SOL_SOCKET,SO_RCVBUF,(const char*)&nRecvBuf,sizeof(int));
	int nSendBuf=1024*1024;//设置为 
	setsockopt(pConnCB->nSocket,SOL_SOCKET,SO_SNDBUF,(const char*)&nSendBuf,sizeof(int));

    SetNoBlock (pConnCB->nSocket);

    nReturn = connect(pConnCB->nSocket, (struct sockaddr*)&servaddr, socklen);

    if (nReturn < 0)
    {
	    sTimeOut.tv_sec  = connectTimeout;
	    sTimeOut.tv_usec = 0;
	    FD_ZERO(&sFDSet);
	    FD_SET(pConnCB->nSocket, &sFDSet);
        nReturn = select(pConnCB->nSocket+1, NULL, &sFDSet, NULL, &sTimeOut);

        if(nReturn <= 0)
        {
			#ifdef _LOG_FLAG_
			if(pConnCB != NULL)
			{
				pConnCB->pLog->PrintLog(DEBUG_LEVEL,"1-connect error,socket:%d,renturn:%d",pConnCB->nSocket,nReturn);
			}
			#endif
            CLOSE_(pConnCB->nSocket);
			pthread_mutex_unlock(&pConnCB->mConnectlock);
            return EIMERR_CONNECT_SERVICE_TIMEOUT_SOCKET;
        }

        int nErr = -1;
        int nErrLen = sizeof(int);
        getsockopt(pConnCB->nSocket, SOL_SOCKET, SO_ERROR, (char*)&nErr, (socklen_t *)&nErrLen); 
        if (nErr != 0)
        {
			#ifdef _LOG_FLAG_
			if(pConnCB != NULL)
			{
				pConnCB->pLog->PrintLog(DEBUG_LEVEL,"2-connect error,socket:%d,renturn:%d",pConnCB->nSocket,nReturn);
			}
			#endif
            CLOSE_(pConnCB->nSocket);
			pthread_mutex_unlock(&pConnCB->mConnectlock);
            return EIMERR_SOCKET_GETOPT_SOCKET;
        }
    }

	#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "connect succuss,socket:%d",pConnCB->nSocket);	
	}
	#endif

    pConnCB->nRunFlag = 1;
    // start recv thread
    pthread_create(&tid, NULL, recvthread, pConnCB);
    // start alive thread
    pthread_create(&tid, NULL, alivethread, pConnCB);
    pConnCB->fConnect = TRUE; 
	pthread_mutex_unlock(&pConnCB->mConnectlock);
    return EIMERR_SUCCESS;
}




/*
 * 直接连接到 接入服务
 *
 * ip:   Server IP
 * port: Server port
 * 
 connectTimeout 连接超时时间
 RecvTimeOut 接收超时时间
 * return 0: success; 其他失败
 */
#ifdef WIN32
IM_API( int )	CLIENT_ConnectService(PCONNCB pConnCB, char *ip, unsigned short port,int connectTimeout )
#else
IM_API int		CLIENT_ConnectService(PCONNCB pConnCB, char *ip, unsigned short port,int connectTimeout )
#endif
{
    struct sockaddr_in servaddr;
	int socklen = sizeof(servaddr);
    pthread_t tid = 0;
    char *pHostName = NULL;
    struct hostent *host;
    char aszIP[256]="";
 
    struct timeval      sTimeOut;
    fd_set      sFDSet;
    int nReturn = 0;

    if (pConnCB->fConnect) 
		return EIMERR_SUCCESS;
    pConnCB->fLogin = FALSE;
    pConnCB->fKick = FALSE;
	pConnCB->fForbidden = FALSE;


	pConnCB->nSocket = socket(AF_INET, SOCK_STREAM, 0);
	if (pConnCB->nSocket == SOCKET_RETURN_ERROR)
    {  
        return EIMERR_SOCKETFD_SOCKET;
    }
	strcpy(aszIP, ip);
    pHostName = aszIP;
    if (isalpha (pHostName[0]))
    {
        host = gethostbyname(pHostName);
        if (host == NULL)
        {
            return EIMERR_GETHOSTNAME_SERVICE_SOCKET;
        }

        strcpy(aszIP, inet_ntoa(*((struct in_addr*)host->h_addr)));
    }

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
#ifdef WIN32
    //servaddr.sin_addr.S_un.S_addr = inet_addr(pConnCB->aszIP);
    servaddr.sin_addr.S_un.S_addr = inet_addr(aszIP);
#else
    //inet_aton(ip, &servaddr.sin_addr);
    inet_aton(aszIP, &servaddr.sin_addr);
#endif
	servaddr.sin_port = htons(port);

//    int nOpt = 0;
    struct linger       sLin;
	sLin.l_onoff         = 1;        
    sLin.l_linger        = 0;
#ifdef WIN32
    setsockopt(pConnCB->nSocket, SOL_SOCKET, SO_LINGER, (const char*)&sLin, sizeof(sLin));
#else
    setsockopt(pConnCB->nSocket, SOL_SOCKET, SO_LINGER, &sLin, sizeof(sLin));
    //setsockopt(pConnCB->nSocket, SOL_SOCKET, SO_NOSIGPIPE, &nOpt, sizeof(nOpt));
#endif

	int nRecvBuf=1024*1024;//设置为 
	setsockopt(pConnCB->nSocket,SOL_SOCKET,SO_RCVBUF,(const char*)&nRecvBuf,sizeof(int));
	int nSendBuf=1024*1024;//设置为 
	setsockopt(pConnCB->nSocket,SOL_SOCKET,SO_SNDBUF,(const char*)&nSendBuf,sizeof(int));

    SetNoBlock (pConnCB->nSocket);

    nReturn = connect(pConnCB->nSocket, (struct sockaddr*)&servaddr, socklen);

    if (nReturn < 0)
    {
	    sTimeOut.tv_sec  = connectTimeout;
	    sTimeOut.tv_usec = 0;
	    FD_ZERO(&sFDSet);
	    FD_SET(pConnCB->nSocket, &sFDSet);
        nReturn = select(pConnCB->nSocket+1, NULL, &sFDSet, NULL, &sTimeOut);

        if(nReturn <= 0)
        {
            CLOSE_(pConnCB->nSocket);
            return EIMERR_CONNECT_SERVICE_TIMEOUT_SOCKET;
        }

        int nErr = -1;
        int nErrLen = sizeof(int);
        getsockopt(pConnCB->nSocket, SOL_SOCKET, SO_ERROR, (char*)&nErr, (socklen_t *)&nErrLen); 
        if (nErr != 0)
        {
            CLOSE_(pConnCB->nSocket);
            return EIMERR_SOCKET_GETOPT_SOCKET;
        }
    }

    pConnCB->nRunFlag = 1;

    // start recv thread
    pthread_create(&tid, NULL, recvthread, pConnCB);

    // start alive thread
    pthread_create(&tid, NULL, alivethread, pConnCB);
 
    pConnCB->fConnect = TRUE; 

	return EIMERR_SUCCESS;
}

#ifdef WIN32
IM_API( int )	CLIENT_Login(PCONNCB pConnCB, char* pszUserName, char* pszPassword, TERMINAL_TYPE cType,char* pszVersion,char* pszMacAddr, char* pszDeviceToken)
#else
int				CLIENT_Login(PCONNCB pConnCB, char* pszUserName, char* pszPassword, TERMINAL_TYPE cType,char* pszVersion,char* pszMacAddr, char* pszDeviceToken)
#endif
{

	LOGIN tLogin;
    LOGIN *pLogin=&tLogin;
	memset(&tLogin, 0, sizeof(tLogin));
    if (pConnCB == NULL || pszUserName == NULL || pszPassword == NULL)
    {
        return EIMERR_INVALID_PARAMTER;
    }
    int nCmdLen = 0;
    int nRet    = 0;
 
    char aszPacket[PACKET_MAXLEN];
    memset(aszPacket, 0, sizeof(aszPacket));

    if (pConnCB->fLogin) 
    {
        return EIMERR_SUCCESS;
    }

    nCmdLen = 0;
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);

    pHead->wCmdID  = CMD_LOGIN;
    pHead->dwSeq   = g_nSeq++;

	int tmpLen = 0;
	if(pszUserName != NULL)
		tmpLen = strlen(pszUserName);
	strncpy(pLogin->tAccount.value, pszUserName, tmpLen);
	pLogin->tAccount.len=tmpLen;

	tmpLen = strlen(pszPassword);
	strncpy(pLogin->aszPassword, pszPassword, tmpLen);

    pLogin->cLoginType = cType;

	tmpLen=0;
    if (pszDeviceToken != NULL)
    {	
		tmpLen = strlen(pszDeviceToken);
		memcpy(pLogin->tDeviceToken.value, pszDeviceToken, tmpLen);
    }
	pLogin->tDeviceToken.len = tmpLen;

	if(pszMacAddr)
	{
		memcpy(pLogin->aszMacAddr, pszMacAddr, sizeof(pLogin->aszMacAddr));
	}
	memcpy(pLogin->aszVersion, pszVersion, strlen(pszVersion));

	LV255 tmpLv;
	memset(&tmpLv, 0, sizeof(tmpLv));
	toBytesLogin(pLogin,&tmpLv);

	nCmdLen=pHead->wMsgLen = tmpLv.len+MSGHEAD_LEN;
	memcpy(aszPacket+MSGHEAD_LEN, tmpLv.value, tmpLv.len);
    hton_term_head(pHead);

	nRet =EncryptSendHttpData(CMD_ENCRYPT_SEND_PWD_REQ,pConnCB->nSocket, (char*)pHead, nCmdLen);
    return ENC_SEND_RET_( nRet );
}
int CLIENT_SendAlive(PCONNCB pConnCB)
{
    ALIVE   *pAlive;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(ALIVE) + MSGHEAD_LEN;
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));


    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pAlive = (ALIVE*)((char*)pHead + MSGHEAD_LEN);
    pHead->wCmdID = CMD_ALIVE;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = sizeof(ALIVE) + MSGHEAD_LEN;

    pAlive->dwUserID = pConnCB->dwUserID;
    hton_term_head(pHead);
    hton_term_alive(pAlive);

    nRet = EncryptSendHttpData(CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_SendMsgNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT32 dwNetID)
#else
int CLIENT_SendMsgNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT32 dwNetID)
#endif
{
    MSGNOTICEACK *pAck;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGNOTICEACK) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(&aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pAck = (MSGNOTICEACK*)((char*)pHead + MSGHEAD_LEN);
    pHead->wCmdID  = CMD_MSGNOTICEACK;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = sizeof(MSGNOTICEACK) + MSGHEAD_LEN;

    pAck->dwUserID = pConnCB->dwUserID;
    pAck->dwMsgID  = dwMsgID;
	pAck->dwNetID  = dwNetID;
    hton_term_head(pHead);
    hton_term_MsgNoticeAck(pAck);

    nRet = EncryptSendHttpData(CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

int  CLIENT_SendMsgReadNoticeAck(PCONNCB pConnCB, UINT32 dwRecverID, UINT64 dwMsgID)
{
    MSGREADNOTICEACK *pAck;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGREADNOTICEACK) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pAck = (MSGREADNOTICEACK*)((char*)pHead + MSGHEAD_LEN);
    pHead->wCmdID = CMD_MSGREADNOTICEACK;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = sizeof(MSGREADNOTICEACK) + MSGHEAD_LEN;

    pAck->dwSenderID = pConnCB->dwUserID;
    pAck->dwRecverID = dwRecverID;
    pAck->dwMsgID = dwMsgID;
    hton_term_head(pHead);
    hton_term_MsgReadNoticeAck(pAck);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,(char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_Logout(PCONNCB pConnCB, int nStatus, unsigned char cManual)
#else
int  CLIENT_Logout(PCONNCB pConnCB, int nStatus, unsigned char cManual)
#endif
{
	#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CLIENT_Logout,socket:%d",pConnCB->nSocket);
	}
	#endif
    LOGOUT  *pLogout;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(LOGOUT) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));
 
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pLogout = (LOGOUT*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_LOGOUT;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;
    
    pLogout->dwUserID = pConnCB->dwUserID;
    pLogout->cStatus = nStatus;
    pLogout->cManual = cManual;
                            
    hton_term_head(pHead);
    pLogout->dwUserID = htonl(pLogout->dwUserID);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

//ios群组消息推送
#ifdef WIN32
IM_API( int )  CLIENT_GroupPushFlag(PCONNCB pConnCB, char* aszGroupid, int Flag)
#else
int  CLIENT_GroupPushFlag(PCONNCB pConnCB, char* aszGroupid, int Flag)
#endif
{
	GROUP_PUSH_FLAG  *pPushFlag;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	int nMsgLen = sizeof(GROUP_PUSH_FLAG) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));


	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
	pPushFlag = (GROUP_PUSH_FLAG*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_GROUPPUSHFLAG;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	pPushFlag->dwUserID = pConnCB->dwUserID;
	pPushFlag->dwPushFlag = Flag;
	memcpy(pPushFlag->aszGroupID, aszGroupid, strlen(aszGroupid));

	hton_term_head(pHead);
	pPushFlag->dwUserID = htonl(pPushFlag->dwUserID);
	pPushFlag->dwPushFlag = htonl(pPushFlag->dwPushFlag);

	nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,(char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_GetEmployee(PCONNCB pConnCB, int nUserID, int nType)
#else
int  CLIENT_GetEmployee(PCONNCB pConnCB, int nUserID, int nType)
#endif
{
    GETEMPLOYEEINFO *pEmployee;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETEMPLOYEEINFO) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));


    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pEmployee = (GETEMPLOYEEINFO*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETEMPLOYEEINFO;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pEmployee->dwUserID = nUserID;
    pEmployee->nType    = nType;

    hton_term_head(pHead);
    hton_term_getemployee(pEmployee);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_ModiInfo(PCONNCB pConnCB, int nType, int nLen, char *szInfo)
#else
int  CLIENT_ModiInfo(PCONNCB pConnCB, int nType, int nLen, char *szInfo)
#endif
{
    MODIINFO *pModi;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = /*sizeof(MODIINFO) +*/ MSGHEAD_LEN + 6 + nLen;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pModi = (MODIINFO*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_MODIINFO;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pModi->dwUserID = pConnCB->dwUserID;
    pModi->cModiType = nType;
    pModi->cLen = (INT8)nLen;

    memcpy(pModi->aszModiInfo, szInfo, nLen);

    hton_term_head(pHead);
    hton_term_modiinfo(pModi);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_ModiSelfNotice(PCONNCB pConnCB, RESETSELFINFO *pNotice)
#else
int   CLIENT_ModiSelfNotice(PCONNCB pConnCB, RESETSELFINFO *pNotice)
#endif
{
    RESETSELFINFO *pReset = NULL;
    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(RESETSELFINFO) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));
    CHECK_NULL_RET_(pNotice);
	 
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pReset = (RESETSELFINFO*)((char*)pHead + MSGHEAD_LEN);

    memcpy(pReset, pNotice, sizeof(RESETSELFINFO));
    hton_term_resetselfinfo_req(pReset);

    pHead->wCmdID  = CMD_RESETSELFINFO;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    hton_term_head(pHead);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_ModiEmpyInfo(PCONNCB pConnCB, EMPLOYEE *pEmpyInfo)
#else
int   CLIENT_ModiEmpyInfo(PCONNCB pConnCB, EMPLOYEE *pEmpyInfo)
#endif
{
    MODIEMPLOYEE *pModiEmpy;
    EMPLOYEE *pEmpy;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MODIEMPLOYEE) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

 
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pModiEmpy = (MODIEMPLOYEE*)((char*)pHead + MSGHEAD_LEN);
    pEmpy = &pModiEmpy->sEmployee;

    pHead->wCmdID = CMD_MODIEMPLOYEE;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pModiEmpy->dwUserID = pConnCB->dwUserID;
    memcpy(pEmpy, pEmpyInfo, sizeof(EMPLOYEE));

    hton_term_head(pHead);
    hton_term_modiemployee(pModiEmpy);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_GetCompInfo(PCONNCB pConnCB)
#else
int   CLIENT_GetCompInfo(PCONNCB pConnCB)
#endif
{
    GETCOMPINFO *pCompInfo;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETCOMPINFO) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pCompInfo = (GETCOMPINFO*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETCOMPINFO;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pCompInfo->dwUserID = pConnCB->dwUserID;
    pCompInfo->dwCompID = pConnCB->dwCompID;

#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "recvthread cmd=%d,length=%d", pHead->wCmdID, pHead->wMsgLen);	
	}
#endif

    hton_term_head(pHead);
    hton_term_getcompinfo(pCompInfo);

    nRet = EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_GetDeptInfo(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#else
int  CLIENT_GetDeptInfo(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#endif
{
    GETDEPTLIST *pDeptInfo;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETDEPTLIST) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pDeptInfo = (GETDEPTLIST*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETDEPTLIST;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pDeptInfo->dwUserID   = pConnCB->dwUserID;
    pDeptInfo->dwCompID   = pConnCB->dwCompID;
	pDeptInfo->cLoginType = cType;
    pDeptInfo->dwLastUpdateTime = nLastUpdateTime;

#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "recvthread cmd=%d,length=%d", pHead->wCmdID, pHead->wMsgLen);		
	}
#endif

    hton_term_head(pHead);
    hton_term_getdeptlist(pDeptInfo);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API (int)  CLIENT_GETDATALISTTYPE(PCONNCB pConnCB, GETDATALISTTYPEPARAMETET* pGetDataTypePara) 
#else
int  CLIENT_GETDATALISTTYPE(PCONNCB pConnCB, GETDATALISTTYPEPARAMETET *pGetDataTypePara)
#endif
{
	GETDATALISTTYPE *pDataListType;

    int nCmdLen = 0;
    int nRet    = 0;
    char aszPacket[PACKET_MAXLEN];
	int nMsgLen = sizeof(GETDATALISTTYPE)+MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead =  (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
	pDataListType        =  (GETDATALISTTYPE*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID  = CMD_GETDATALISTTYPE;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

	pDataListType->dwUserID        = pConnCB->dwUserID;
	pDataListType->dwCompID        = pConnCB->dwCompID;
	pDataListType->cLoginType      = pGetDataTypePara->nTermType;
	pDataListType->cNetType        = pGetDataTypePara->nNetType;

	pDataListType->cUpdataTypeDept      = pGetDataTypePara->cUpdataTypeDept;
	pDataListType->cUpdataTypeDeptUser  = pGetDataTypePara->cUpdataTypeDeptUser;
	pDataListType->cUpdataTypeUser      = pGetDataTypePara->cUpdataTypeUser;

	pDataListType->dwLastUpdateTimeDept     = pGetDataTypePara->dwLastUpdateTimeDept;
	pDataListType->dwLastUpdateTimeDeptUser = pGetDataTypePara->dwLastUpdateTimeDeptUser;
	pDataListType->dwLastUpdateTimeUser     = pGetDataTypePara->dwLastUpdateTimeUser;

    hton_term_head(pHead);
	hton_term_GETDATALISTTYPE(pDataListType);

    nRet = EncryptSendHttpData(CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_GetUserList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#else
int  CLIENT_GetUserList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#endif
{
    GETUSERLIST *pUserList;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETUSERLIST) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pUserList = (GETUSERLIST*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETUSERLIST;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pUserList->dwUserID   = pConnCB->dwUserID;
    pUserList->dwCompID   = pConnCB->dwCompID;
	pUserList->cLoginType = cType;
    pUserList->dwLastUpdateTime = nLastUpdateTime;

    hton_term_head(pHead);
    hton_term_getuserlist(pUserList);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_GetUserDept(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#else
int   CLIENT_GetUserDept(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#endif
{
    GETUSERDEPT *pUserDept;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETUSERDEPT) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pUserDept = (GETUSERDEPT*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETUSERDEPT;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pUserDept->dwUserID   = pConnCB->dwUserID;
    pUserDept->dwCompID   = pConnCB->dwCompID;
	pUserDept->cLoginType = cType;
    pUserDept->dwLastUpdateTime = nLastUpdateTime;

#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "recvthread cmd=%d,length=%d", pHead->wCmdID, pHead->wMsgLen);	
	}
#endif

    hton_term_head(pHead);
    hton_term_getuserdept(pUserDept);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_get_userRPA(PCONNCB pConnCB, UINT16 nCmdID, int nLastUpdateTime, TERMINAL_TYPE cType)
#else
IM_API int   CLIENT_get_userRPA(PCONNCB pConnCB, UINT16 nCmdID, int nLastUpdateTime, TERMINAL_TYPE cType)
#endif
{
    GETUSERRPA *pUserRPA;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETUSERRPA) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pUserRPA = (GETUSERRPA*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID  = nCmdID;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pUserRPA->dwUserID   = pConnCB->dwUserID;
    pUserRPA->dwCompID   = pConnCB->dwCompID;
	pUserRPA->cLoginType = cType;
    pUserRPA->dwLastUpdateTime = nLastUpdateTime;

#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "recvthread cmd=%d,length=%d", pHead->wCmdID, pHead->wMsgLen);
	}
#endif

    hton_term_head(pHead);
    hton_getuserrpa_req(pUserRPA);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ, pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_GetUserStateList(PCONNCB pConnCB)
#else
int  CLIENT_GetUserStateList(PCONNCB pConnCB)
#endif
{
    GETUSERSTATELIST *pUserState;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETUSERSTATELIST) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pUserState = (GETUSERSTATELIST*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETUSERSTATE;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pUserState->dwUserID = pConnCB->dwUserID;
    pUserState->dwCompID = pConnCB->dwCompID;

    hton_term_head(pHead);
    hton_term_getuserstate(pUserState);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_CreateGroup(PCONNCB pConnCB, char *pszGroupID, char *pszGroupName, int nGroupNameLen, char *pszUsers, int num, int nGroupTime)
#else
int  CLIENT_CreateGroup(PCONNCB pConnCB, char *pszGroupID, char *pszGroupName, int nGroupNameLen, char *pszUsers, int num, int nGroupTime)
#endif
{
    CREATEGROUP *pCreate;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(CREATEGROUP) + MSGHEAD_LEN - (MAXNUM_PAGE_USERID-num)*sizeof(int);
 

	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));


    if (pszGroupName == NULL || pszUsers == NULL ) return EIMERR_INVALID_PARAMTER ;
    if (num > MAXNUM_PAGE_USERID || nGroupNameLen > GROUPNAME_MAXLEN) return EIMERR_FUNCTION_PARAM_MAXVALUE_ERR;

    memset(&aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pCreate = (CREATEGROUP*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_CREATEGROUP;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pCreate->dwUserID = pConnCB->dwUserID;
    memcpy(pCreate->aszGroupID, pszGroupID, sizeof(pCreate->aszGroupID)-1);
    memcpy(pCreate->aszGroupName, pszGroupName, nGroupNameLen);
    pCreate->dwTime   = nGroupTime;
    pCreate->wUserNum = num;
    memcpy(pCreate->aUserID, pszUsers, num * sizeof(UINT32));
    
    hton_term_head(pHead);
    hton_term_creategroup(pCreate);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_ModiGroup(PCONNCB pConnCB, char *pszGroupID, char* pszNew, int nType, int nGroupTime)
#else
int   CLIENT_ModiGroup(PCONNCB pConnCB, char *pszGroupID, char* pszNew, int nType, int nGroupTime)
#endif
{
    MODIGROUP *pModi;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MODIGROUP) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pModi = (MODIGROUP*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_MODIGROUP;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pModi->dwUserID = pConnCB->dwUserID;
    pModi->dwTime = nGroupTime;
    memcpy(pModi->aszGroupID, pszGroupID, sizeof(pModi->aszGroupID)-1);
    pModi->cType = nType;
    strncpy(pModi->aszData, pszNew, sizeof(pModi->aszData));
    
    hton_term_head(pHead);
    hton_term_modigroup(pModi);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,(char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_QuitGroup(PCONNCB pConnCB, char *pszGroupID)
#else
int  CLIENT_QuitGroup(PCONNCB pConnCB, char *pszGroupID)
#endif
{
    QUITGROUP *pQuit;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(QUITGROUP) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pQuit = (QUITGROUP*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_QUITGROUP;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pQuit->dwUserID = pConnCB->dwUserID;
    memcpy(pQuit->aszGroupID, pszGroupID, sizeof(pQuit->aszGroupID)-1);
    
    hton_term_head(pHead);
    hton_term_QuitGroupreq(pQuit);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_GetGroupInfo(PCONNCB pConnCB, char *pszGroupID)
#else
int  CLIENT_GetGroupInfo(PCONNCB pConnCB, char *pszGroupID)
#endif
{
    GETGROUPINFO *pGroup;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETGROUPINFO) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

 
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pGroup = (GETGROUPINFO*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETGROUP;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pGroup->dwUserID = pConnCB->dwUserID;
    memcpy(pGroup->aszGroupID, pszGroupID, sizeof(pGroup->aszGroupID)-1);
    
    hton_term_head(pHead);
    hton_term_getgroupinfo(pGroup);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,  (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_SendSMSEx(PCONNCB pConnCB, SENDMSG *pSMS)
#else
int   CLIENT_SendSMSEx(PCONNCB pConnCB, SENDMSG *pSMS)
#endif
{
	SENDMSG *pSMSTmp=NULL;
    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(SENDMSG) - MSG_MAXLEN + pSMS->dwMsgLen + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));
    if (pSMS->dwMsgLen > MSG_MAXLEN) return EIMERR_FUNCTION_PARAM_MAXVALUE_ERR;

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pSMSTmp = (SENDMSG*)((char*)pHead + MSGHEAD_LEN);
	memcpy(pSMSTmp, pSMS, sizeof(SENDMSG));

    pHead->wCmdID  = CMD_SENDMSG;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pSMSTmp->dwUserID = pConnCB->dwUserID;
	
    hton_term_head(pHead);
    hton_term_sendsms(pSMSTmp);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,  (char*)pHead, nMsgLen);

#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
        ntoh_term_sendsms(pSMSTmp);
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CLIENT_SendSMSEx cmd=CMD_SENDMSG, seq= %d, length=%d [%s]，nRet:%d,msgid:%llu\n", g_nSeq - 1, nMsgLen, (nRet>=0)? "Succeed": "Failed",nRet,pSMSTmp->dwMsgID);		
	}
#endif

    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_SendSMS(PCONNCB pConnCB, int nRecverID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nReadFlag, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply, UINT64 nSrcMsgID)
#else
int   CLIENT_SendSMS(PCONNCB pConnCB, int nRecverID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nReadFlag, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply, UINT64 nSrcMsgID)
#endif
{
    SENDMSG *pSMS;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(SENDMSG) - MSG_MAXLEN + len + MSGHEAD_LEN;
 

	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

     
    if (len > MSG_MAXLEN) return EIMERR_FUNCTION_PARAM_MAXVALUE_ERR;

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pSMS = (SENDMSG*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_SENDMSG;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pSMS->dwUserID = pConnCB->dwUserID;
    pSMS->dwRecverID = nRecverID;
    pSMS->cType = nType;
    pSMS->cRead = nReadFlag;
    pSMS->dwMsgID = nMsgID;
    pSMS->nSendTime = nSendTime;
    pSMS->dwMsgLen = len;
    pSMS->cIsGroup = 0;
	pSMS->nMsgTotal  = nMsgTotal;
	pSMS->nMsgSeq    = nMsgSeq;
	pSMS->cAllReply  = nAllReply;
	pSMS->dwSrcMsgID = nSrcMsgID;
    memcpy(pSMS->aszMessage, pszMsg, pSMS->dwMsgLen);
    
    hton_term_head(pHead);
    hton_term_sendsms(pSMS);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
        ntoh_term_sendsms(pSMS);
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CLIENT_SendSMS cmd=CMD_SENDMSG, seq= %d, length=%d [%s],nret:%d,msgid:%llu \n", g_nSeq - 1, nMsgLen, (nRet >= 0)? "Succeed": "Failed",nRet,pSMS->dwMsgID);
	}
#endif

    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_SendReadSMS(PCONNCB pConnCB, int nSenderID, UINT64 nMsgID, unsigned char nMsgType, int nReadTime)
#else
int  CLIENT_SendReadSMS(PCONNCB pConnCB, int nSenderID, UINT64 nMsgID, unsigned char nMsgType, int nReadTime)
#endif
{
    MSGREAD *pMsgRead;

    int nCmdLen = 0;
    int nRet    = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGREAD) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pMsgRead = (MSGREAD*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID  = CMD_MSGREAD;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pMsgRead->dwSenderID = pConnCB->dwUserID;
    pMsgRead->dwRecverID = nSenderID;
    pMsgRead->dwMsgID = nMsgID;
	pMsgRead->cMsgType = nMsgType;
    pMsgRead->dwTime  = nReadTime;
    
    hton_term_head(pHead);
    hton_term_msgread(pMsgRead);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_SendMSGNoticeConfirm(PCONNCB pConnCB, int nRecvID, char *pszMsg, int len, UINT64 nMsgID)
#else
int  CLIENT_SendMSGNoticeConfirm(PCONNCB pConnCB, int nRecvID, char *pszMsg, int len, UINT64 nMsgID)
#endif
{
    MSGNOTICECONFIRM *pMsgConfirm;

    int nCmdLen = 0;
    int nRet    = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGNOTICECONFIRM) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pMsgConfirm = (MSGNOTICECONFIRM*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID  = CMD_MSGNOTICECONFIRM;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pMsgConfirm->dwSenderID = pConnCB->dwUserID;
    pMsgConfirm->dwRecverID = nRecvID;
    pMsgConfirm->dwMsgID    = nMsgID;
    pMsgConfirm->dwMsgLen   = len;
    memcpy(pMsgConfirm->aszMessage, pszMsg, len);
    
    hton_term_head(pHead);
    hton_term_msgnoticeconfirm(pMsgConfirm);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_SendtoGroup(PCONNCB pConnCB, char* pszGroupID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nGroupType, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply,unsigned char cRead)
#else
int  CLIENT_SendtoGroup(PCONNCB pConnCB, char* pszGroupID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nGroupType, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply,unsigned char cRead)
#endif
{
    SENDMSG *pSMS;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(SENDMSG) - MSG_MAXLEN + len + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    CHECK_NULL_RET_( pszMsg);
 
    if (len > MSG_MAXLEN) return EIMERR_FUNCTION_PARAM_MAXVALUE_ERR;
 
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pSMS = (SENDMSG*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_SENDMSG;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pSMS->dwUserID = pConnCB->dwUserID;
    memcpy(pSMS->aszGroupID, pszGroupID, sizeof(pSMS->aszGroupID)-1);
    pSMS->cType = nType;
    pSMS->dwMsgID = nMsgID;
    pSMS->nSendTime = nSendTime;
	pSMS->cAllReply = nAllReply;
    pSMS->dwMsgLen = len;
    pSMS->cIsGroup = nGroupType;
	pSMS->nMsgTotal = nMsgTotal;
	pSMS->nMsgSeq = nMsgSeq;

	pSMS->cRead = cRead;

    memcpy(pSMS->aszMessage, pszMsg, pSMS->dwMsgLen);
    
    hton_term_head(pHead);
    hton_term_sendsms(pSMS);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,  (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
        ntoh_term_sendsms(pSMS);
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CLIENT_SendtoGroup cmd=CMD_SENDMSG, seq= %d, length=%d [%s],nret:%d,msgid:%llu \n", g_nSeq - 1, nMsgLen, (nRet >= 0)? "Succeed": "Failed",nRet,pSMS->dwMsgID);
	}
#endif
}
#ifdef WIN32
IM_API( int )  CLIENT_SendBroadCast(PCONNCB pConnCB, char *pRecverIDs, int num, char *pszTitle, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nMsgType, unsigned char nAllReply, UINT64 nSrcMsgID)
#else
int  CLIENT_SendBroadCast(PCONNCB pConnCB, char *pRecverIDs, int num, char *pszTitle, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nMsgType, unsigned char nAllReply, UINT64 nSrcMsgID)
#endif
{
    SENDBROADCAST *pBroad;

    int nCmdLen = 0;
    int nRet    = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(SENDBROADCAST) - MSG_MAXBROADLEN + len + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));
    if (len > MSG_MAXBROADLEN) return EIMERR_FUNCTION_PARAM_MAXVALUE_ERR;
    if (num > MAXNUM_RECVER_ID) return EIMERR_FUNCTION_PARAM_MAXVALUE_ERR;
    if (strlen(pszTitle) > MAX_TITLELEN) return EIMERR_FUNCTION_PARAM_MAXVALUE_ERR;


    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pBroad = (SENDBROADCAST*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID  = CMD_SENDBROADCAST;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;
	
    pBroad->dwUserID   = pConnCB->dwUserID;
    memcpy(pBroad->aRecver, pRecverIDs, sizeof(BROADCAST_RECVER) * num);
    pBroad->wRecverNum = num;
    pBroad->dwMsgLen   = len;
    pBroad->dwMsgID    = nMsgID;
    pBroad->dwTime     = nSendTime;
    pBroad->cMsgType   = nMsgType;
	pBroad->cAllReply  = nAllReply;
	pBroad->dwSrcMsgID = nSrcMsgID;
    memcpy(pBroad->aszTitile, pszTitle, strlen(pszTitle));
    memcpy(pBroad->aszMessage, pszMsg, pBroad->dwMsgLen);
    
    hton_term_head(pHead);
    hton_term_sendbroad(pBroad);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_ModiMember(PCONNCB pConnCB, char *pszGroupID, char *pszUsers, int num, int nType, int nGroupTime)
#else
int   CLIENT_ModiMember(PCONNCB pConnCB, char *pszGroupID, char *pszUsers, int num, int nType, int nGroupTime)
#endif
{
    MODIMEMBER *pModi;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MODIMEMBER) + MSGHEAD_LEN-(MAXNUM_PAGE_USERID-num)*sizeof(int);
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pModi = (MODIMEMBER*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_MODIMEMBER;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pModi->dwUserID = pConnCB->dwUserID;
    memcpy(pModi->aszGroupID, pszGroupID, sizeof(pModi->aszGroupID)-1);
    pModi->cOpType = nType;
    pModi->wNum = num;
    pModi->dwTime = nGroupTime;
    memcpy(pModi->aUserID, pszUsers, sizeof(UINT32) * num);
    
    hton_term_head(pHead);
    hton_term_modimember(pModi);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( void) CLIENT_UnInit(PCONNCB pConnCB, unsigned char nManual)
#else
void CLIENT_UnInit(PCONNCB pConnCB, unsigned char nManual)
#endif
{
    if (pConnCB != NULL)
    {
		CLIENT_Disconnect(pConnCB);
		#ifdef WIN32
		uSleep(2000);
		#else
		sleep(2);
		#endif

		#ifdef _LOG_FLAG_
		if (pConnCB->pLog)
		{
			pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CLIENT_UnInit Disconnect ok");	
			delete pConnCB->pLog;
			pConnCB->pLog = NULL;
		}
		#endif
		g_ExitExe = 1;
        mq_destroy(pConnCB->pQueueMsg);
		pthread_mutex_destroy(&pConnCB->mConnectlock);
        pthread_mutex_destroy(&g_SeqLock);
		if(pConnCB)
        free(pConnCB);
		pConnCB = NULL;
    }

#ifdef WIN32 
    WSACleanup();
#endif
}
#ifdef WIN32
//获取固定组信息

IM_API( int )  CLIENT_GetRegularGroupInfo(PCONNCB pConnCB, UINT32 uTimestamp)
#else
int   CLIENT_GetRegularGroupInfo(PCONNCB pConnCB, UINT32 uTimestamp)
#endif
{
    REGULAR_GROUP_UPDATE_REQ *pRegularGroup = NULL;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(REGULAR_GROUP_UPDATE_REQ) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pRegularGroup = (REGULAR_GROUP_UPDATE_REQ*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_REGULAR_GROUP_UPDATE_REQ;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pRegularGroup->dwUserID = pConnCB->dwUserID;
	pRegularGroup->dwRegularTime = uTimestamp;
       
    hton_term_head(pHead);
    hton_term_regulargroupupdatereq(pRegularGroup);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_CheckTime(PCONNCB pConnCB, int nSerial)
#else
int  CLIENT_CheckTime(PCONNCB pConnCB, int nSerial)
#endif
{
    CHECK_TIME_REQ *pCheck;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(CHECK_TIME_REQ) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pCheck = (CHECK_TIME_REQ*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_CHECK_TIME_REQ;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pCheck->dwSerial = nSerial;
    
    hton_term_head(pHead);
    hton_term_checktime_req(pCheck);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
//获取离线消息 ,nTermType终端类型
#ifdef WIN32
IM_API( int )  CLIENT_GetOffline(PCONNCB pConnCB, UINT8 nTermType)
#else
int   CLIENT_GetOffline(PCONNCB pConnCB, UINT8 nTermType)
#endif
{
    GET_OFFLINE_REQ *pBody = NULL;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GET_OFFLINE_REQ) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pBody = (GET_OFFLINE_REQ*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GET_OFFLINE_REQ;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pBody->dwUserID = pConnCB->dwUserID;
	pBody->cLoginType = nTermType;
 
    hton_term_head(pHead);
    hton_term_getoffline_req(pBody);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_RefuseGroupMsg(PCONNCB pConnCB, char *pszGroupID, unsigned char cRefuseType)
#else
int  CLIENT_RefuseGroupMsg(PCONNCB pConnCB, char *pszGroupID, unsigned char cRefuseType)
#endif
{
    REFUSE_GROUPMSG_REQ *pBody = NULL;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(REFUSE_GROUPMSG_REQ) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pBody = (REFUSE_GROUPMSG_REQ*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID  = CMD_REFUSEGROUP_REQ;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pBody->dwUserID = pConnCB->dwUserID;
    memcpy(pBody->aszGroupID, pszGroupID, GROUPID_MAXLEN-1);
	pBody->cRefuseType = cRefuseType;
 
    hton_term_head(pHead);
    hton_term_refusegroup_req(pBody);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

/*
 * 生成消息序列ID,网络序
 * nTermType  用户类型 3 pC ,ANDROID 1, ios 2
   uTime    从2013.6.31日起到现在时间的秒数
   
   
	MSGID规则：
	[63-61]: terminal  	3  bit
	[60-37]: userid		24 bit
	[36-8]:	 time		29 bit
	[7-0]:	 seq(0-249) 8  bit 
 * return:

 */
#ifdef WIN32
IM_API( UINT64) CLIENT_PackMsgId( UINT32 uUserId,UINT8 nTermType, UINT32 uTime)
#else
UINT64 CLIENT_PackMsgId( UINT32 uUserId,UINT8 nTermType, UINT32 uTime)
#endif
{

 
		static UINT32 seq=0;
		UINT32 tmp;
		UINT64 uMsgId=0;
		UINT64 uTmp=0;
		uTime = uTime - 1375100000;
 
	 
		pthread_mutex_lock(&g_SeqLock);
		nTermType = nTermType&0x7;
		tmp = nTermType;
		tmp = tmp << 29;
		uUserId = (uUserId << 5) &0x1FFFFFE0;
		seq++;
		seq %= 250;
		uMsgId = uUserId|tmp;
		uTmp = uTime & 0x1FFFFFFF;
		uTmp = (uTmp << 8);

		uMsgId=(uMsgId << 32)|uTmp;
		uMsgId= uMsgId |seq;

		//uMsgId = htonl64(uMsgId);
		pthread_mutex_unlock(&g_SeqLock);
	return uMsgId;
}
#ifdef WIN32
IM_API( UINT64) CLIENT_UnpackMsgId(UINT64 uMsgId)
#else
UINT64 CLIENT_UnpackMsgId(UINT64 uMsgId)
#endif
{

	//uMsgId = ntohl64(uMsgId);
		//以下调试使用
	UINT32 uUserId = (uMsgId >> 32);
	UINT8 nTermType = uUserId >> 30;
	uUserId = uUserId&0x3FFFFFFF;
	UINT32 uTime = (uMsgId & 0xFFFFFFFF);
	UINT8 seq =  uTime%10;
	uTime = uTime / 10 +1375100000;
	printf("seq:userid:%u,termtype:%d,time:%u,seq:%d,msgid:%lld\n",uUserId,nTermType,uTime,seq,uMsgId);
return uMsgId;
}

#ifdef WIN32
IM_API( int )  CLIENT_CreateSchedule(PCONNCB pConnCB, CREATESCHEDULE *pCreate)
#else
int   CLIENT_CreateSchedule(PCONNCB pConnCB, CREATESCHEDULE *pCreate)
#endif
{
    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));


    if (pCreate->wUserNum > MAXNUM_PAGE_USERID) return EIMERR_INVALID_PARAMTER;
	int nMsgLen = sizeof(CREATESCHEDULE) + MSGHEAD_LEN - (MAXNUM_PAGE_USERID-pCreate->wUserNum)*sizeof(UINT32);

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
	pCreate->dwUserID = pConnCB->dwUserID;
	hton_term_CreateSchedule(pCreate);
	memcpy((char*)pHead + MSGHEAD_LEN, pCreate, sizeof(CREATESCHEDULE));

    pHead->wCmdID  = CMD_CREATESCHDULE;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;
	
    hton_term_head(pHead);

    nRet = EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,(char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int ) CLIENT_DeleteSchedule(PCONNCB pConnCB, DELETESCHEDULE *pDelete)
#else
IM_API int  CLIENT_DeleteSchedule(PCONNCB pConnCB, DELETESCHEDULE *pDelete)
#endif
{
    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(DELETESCHEDULE) + MSGHEAD_LEN;
 
    CHECK_NULL_RET_( pDelete );
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
	pDelete->dwUserID = pConnCB->dwUserID;
	pDelete->dwUserID = htonl(pDelete->dwUserID);
	memcpy(pDelete->aszGroupID, pDelete->aszGroupID, GROUPID_MAXLEN-1);
	memcpy(pDelete->aszScheduleID, pDelete->aszScheduleID, GROUPID_MAXLEN-1);
	memcpy((char*)pHead + MSGHEAD_LEN, pDelete, sizeof(DELETESCHEDULE));

    pHead->wCmdID  = CMD_DELETESCHDULE;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;
	
    hton_term_head(pHead);

    nRet = EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_CreateScheduleNotieAck(PCONNCB pConnCB, char *pScheduleID)
#else
int   CLIENT_CreateScheduleNotieAck(PCONNCB pConnCB, char *pScheduleID)
#endif
{
    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    char *pHttp = aszPacket;
    int nMsgLen = sizeof(CREATESCHEDULENOTICEACK) + MSGHEAD_LEN;
 
    CHECK_NULL_RET_(pScheduleID);
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

	CREATESCHEDULENOTICEACK mAck;
	memset(&mAck, 0, sizeof(CREATESCHEDULENOTICEACK));
	memcpy(mAck.aszScheduleID, pScheduleID, GROUPID_MAXLEN);
    nCmdLen = sprintf(pHttp, g_cszHttpReqHead, pConnCB->dwSessionID, nMsgLen);
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
	memcpy((char*)pHead + MSGHEAD_LEN, &mAck, sizeof(CREATESCHEDULENOTICEACK));

    pHead->wCmdID  = CMD_CREATESCHDULENOTICEACK;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;
	
    hton_term_head(pHead);

    nRet = EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,(char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

//client至公众平台上行消息
#ifdef WIN32
IM_API( int )  CLIENT_ecwx_up(PCONNCB pConnCB, char* fromUser,int toUser, char* msgType, char* text, int sequence, int cmd)
#else
int   CLIENT_ecwx_up(PCONNCB pConnCB, char* fromUser,int toUser, char* msgType, char* text, int sequence, int cmd)
#endif
{
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	char szbuf[0x400] = { 0 };

    //同步菜单消息时，text字段不为空，内容需要加上双引号
    if (0 == strcmp(msgType, "menuMessage"))
    {
        sprintf(szbuf, json_ecwx_up_sync, fromUser,toUser, msgType, text, sequence);
    }
    //sync 和 updateMenu 时，text 不为空，则是一个数组，内容不需要加上双引号
	else if (text != NULL) 
	{
		sprintf(szbuf, json_ecwx_up_updatemenu, fromUser,toUser, msgType, text, sequence);

	}
    //sync 和 updateMenu 时，text为空，内容需要加上双引号
	else 
	{
		sprintf(szbuf, json_ecwx_up_sync, fromUser,toUser, msgType, text, sequence);
	}
    
	int nMsgLen = strlen(szbuf) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);

	pHead->wCmdID = cmd;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;
	memcpy(pHead->aszMsg, szbuf, strlen(szbuf));
	hton_term_head(pHead);

	nRet =  EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

//client至开放平台的请求
#ifdef WIN32
IM_API( int )  CLIENT_app_up(PCONNCB pConnCB, char* fromUser,char*msg, int cmd)
#else
int   CLIENT_app_up(PCONNCB pConnCB, char* fromUser,char*msg, int cmd)
#endif
{
	int nCmdLen = 0;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	char *pHttp = aszPacket;
	int nMsgLen = strlen(msg) + MSGHEAD_LEN +20;//20是usercode长度

	CHECK_PCB_RET_(pConnCB);
	memset(&aszPacket, 0, sizeof(aszPacket));

	nCmdLen = sprintf(pHttp, g_cszHttpReqHead, pConnCB->dwSessionID, nMsgLen);
	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);

	pHead->wCmdID = cmd;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;
	memcpy(pHead->aszMsg, fromUser, strlen(fromUser));//usercode
	memcpy(pHead->aszMsg + 20, msg, strlen(msg));//content
	hton_term_head(pHead);

	nRet =  EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}



#ifdef WIN32
IM_API( int )	CLIENT_IosBackGroundReq(PCONNCB pConnCB,UINT32 uPushMsgCount)
#else
IM_API int		CLIENT_IosBackGroundReq(PCONNCB pConnCB,UINT32 uPushMsgCount)
#endif
{
    IOSBACKGROUNDREQ *pBody = NULL;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(IOSBACKGROUNDREQ) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket );
    pBody = (IOSBACKGROUNDREQ*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_IOSBACKGROUND_REQ;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pBody->dwUserID = pConnCB->dwUserID;
	pBody->dwPushMsgCount = uPushMsgCount;

 
    hton_term_head(pHead);
    hton_ios_background_req(pBody);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}


//////////////////////BIG DATA//////////////////////////////

//=============================================================================
//Function:     CLIENT_ParseDeptInfo
//Description:	Parse VLA package of DEPTINFO, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 	2.2 获取部门信息应答		DEPTINFO	 <==> DEPTINFO
//
//Parameter:
//	pszDeptInfo     - The head of the VLA
//	pu32StartPos    - Start parse position, first time must be set to 0, it will be auto updated
//	psDeptInfo       - Return the parsed result of DEPTINFO
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//	   -2	- Package error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseDeptInfo(const char* pszDeptInfo, UINT32* pu32StartPos, DEPTINFO* psDeptInfo)
#else
int   CLIENT_ParseDeptInfo(const char* pszDeptInfo, UINT32* pu32StartPos, DEPTINFO* psDeptInfo)
#endif
{
	UINT32 u32Pos;					// Temp pos for parse
	UINT32 u32Length;				// Temp length for VAR length
	UINT32 u32DeptInfoPackSize;		// 2.2:4	DEPTINFO	ANS..1904	LLLLVAR
	UINT16 u16DeptInfoLength;		// 2.2:4.1	PLENGTH		B16			BINARY	M+	

	// Check parameter
	if( pszDeptInfo == NULL || pu32StartPos == NULL || psDeptInfo == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;		// Parameter error
	}

	// Check package size
	u32DeptInfoPackSize = ParseLength( pszDeptInfo, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32DeptInfoPackSize )
		return EIMERR_PARSE_FINISHED;			// Parse finished
	
	// Check position
	if( *pu32StartPos == 0 )			// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;	// Skip the length data of DEPTINFO 
	
	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psDeptInfo, 0, sizeof(DEPTINFO));
    psDeptInfo->cShowLevel= DEPTSHOWTYPE_SHOWALL;   //部门显示标识,默认显示全部

	// Field1. PLENGTH	B16		BINARY	M+
	u16DeptInfoLength = MAKE_UINT16_EX_( pszDeptInfo );
	u16DeptInfoLength = ntohs( u16DeptInfoLength );
	u32Pos += UINT16_BYTES;

	// Field2. DEPTID	B32		BINARY	M+
	psDeptInfo->dwDeptID = MAKE_UINT32_EX_( pszDeptInfo );
	u32Pos += UINT32_BYTES;
	
	psDeptInfo->dwCompID = MAKE_UINT32_EX_( pszDeptInfo );
	u32Pos += UINT32_BYTES;


	// Field3. DEPTNAME	ANS..32	LLVAR	ASCII	M+
	u32Length = ParseLength( &pszDeptInfo[u32Pos], LLLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psDeptInfo->szCnDeptName, &pszDeptInfo[u32Pos + 3], MIN_(u32Length, DEPTNAME_MAXLEN) );
	u32Pos += u32Length + LLLVAR_BYTES;


		u32Length = ParseLength( &pszDeptInfo[u32Pos], LLLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psDeptInfo->szEnDeptName, &pszDeptInfo[u32Pos + 3], MIN_(u32Length, DEPTNAME_MAXLEN) );
	u32Pos += u32Length + LLLVAR_BYTES;



	// Field4. PID	B32		BINARY	M+
	psDeptInfo->dwPID = MAKE_UINT32_EX_( pszDeptInfo );
	u32Pos += UINT32_BYTES; 

	psDeptInfo->dwUpdateTime = MAKE_UINT32_EX_( pszDeptInfo );
	u32Pos += UINT32_BYTES; 

	// Field5. UPDATETYPE	N1		ASCII	M+
	psDeptInfo->wUpdate_type =  ParseLength( &pszDeptInfo[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;

	// Field6. SORT	B16		BINARY	M+	默认值0
	psDeptInfo->wSort = MAKE_UINT16_EX_( pszDeptInfo );
	u32Pos += UINT16_BYTES;

	// Field7. DEPTTEL	ANS..22	LLVAR	ASCII	M+
	u32Length = ParseLength( &pszDeptInfo[u32Pos], LLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psDeptInfo->aszDeptTel, &pszDeptInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, TEL_MAXLEN) );
	u32Pos += u32Length + LLVAR_BYTES;

    if(u32Pos - *pu32StartPos != u16DeptInfoLength)
        return EIMERR_PACKAGE_ERROR;    // Package error

    ntoh_term_deptinfo(psDeptInfo);
    *pu32StartPos = u32Pos;         // Update position for next parse
    return EIMERR_SUCCESS;          // Parse succeeded
}

//=============================================================================
//Function:     CLIENT_ParseDeptUserInfo
//Description:	Parse VAL package of DEPTINFO, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 3.2 获取部门人员信息应答	DEPTUSERINFO <==> USERDEPT
//
//Parameter:
//	pszDeptUserInfo    - The Head of VLA
//	pu32StartPos       - Start parse position, first time must be set to 0, it will be auto updated
//	psUserDept          - Return the parsed result of USERDEPT
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//	   -2	- Package error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseDeptUserInfo(const char* pszDeptUserInfo, UINT32* pu32StartPos, USERDEPT* psUserDept)
#else
int   CLIENT_ParseDeptUserInfo(const char* pszDeptUserInfo, UINT32* pu32StartPos, USERDEPT* psUserDept)
#endif
{
	UINT32 u32Pos;					// Temp pos for parse
	UINT32 u32Length;				// Temp length for VAR length
	UINT32 u32DeptUserInfoPackSize;	// 3.2:4	DEPTUSERINFO	ANS..1904	LLLLVAR	ASCII	C+	
	UINT16 u16DeptUserInfoLength;	// 3.2:4.1	PLENGTH	B16		BINARY	M+	数据包长度，指示的长度包含本身所需的两个字节

	// Check parameter
	if( pszDeptUserInfo == NULL || pu32StartPos == NULL || psUserDept == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;	// Parameter error
	}

	// Check package size
	u32DeptUserInfoPackSize = ParseLength( pszDeptUserInfo, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32DeptUserInfoPackSize )
		return EIMERR_PARSE_FINISHED;		// Parse finished

	// Check position
	if( *pu32StartPos == 0 )			// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;	// Skip the length data of DEPTINFO 
	
	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserDept, 0, sizeof(USERDEPT) );
	
	// Field1. PLENGTH	B16		BINARY	M+
	u16DeptUserInfoLength = MAKE_UINT16_EX_( pszDeptUserInfo );
	u16DeptUserInfoLength = ntohs( u16DeptUserInfoLength );
	u32Pos += UINT16_BYTES;

	// Field2. DEPTID	B32		BINARY	M+
	psUserDept->dwDeptID = MAKE_UINT32_EX_( pszDeptUserInfo );
	u32Pos += UINT32_BYTES;

	// Field3. USERID	B32		BINARY	M+
	psUserDept->dwUserID = MAKE_UINT32_EX_( pszDeptUserInfo );
	u32Pos += UINT32_BYTES;

	// Field4. USERCODE	ANS..17	LLVAR	ASCII	M+
	u32Length = ParseLength( &pszDeptUserInfo[u32Pos], LLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psUserDept->aszUserCode, &pszDeptUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, USERCODE_MAXLEN) );
	u32Pos += u32Length + LLVAR_BYTES;

	// Field5. USERNAME	ANS..34	LLVAR	ASCII	M+
	u32Length = ParseLength( &pszDeptUserInfo[u32Pos], LLLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psUserDept->aszCnUserName, &pszDeptUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, USERNAME_MAXLEN) );
	u32Pos += u32Length + LLLVAR_BYTES;


	u32Length = ParseLength( &pszDeptUserInfo[u32Pos], LLLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psUserDept->aszEnUserName, &pszDeptUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, USERNAME_MAXLEN) );
	u32Pos += u32Length + LLLVAR_BYTES;

	// Field6. LOGO	ANS7		ASCII	C+	头像
	memcpy( psUserDept->aszLogo, &pszDeptUserInfo[u32Pos], sizeof( psUserDept->aszLogo ) - 1 );
	u32Pos += sizeof( psUserDept->aszLogo )-1;
	
	// Field7. SEX	N1		ASCII	M+
	psUserDept->cSex = ParseLength( &pszDeptUserInfo[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;


	psUserDept->wSort = MAKE_UINT16_EX_( pszDeptUserInfo );
	u32Pos += UINT16_BYTES; 


	// Field8. RANKID	N1				ASCII	C+ // 2017.5.27 由张署修改协议ASCII ==> BYTES, 郭总同意
	psUserDept->cRankID = pszDeptUserInfo[u32Pos] - '0';
	u32Pos += LVAR_BYTES;

	// Field9. PROID	N1		ASCII	C+
	psUserDept->cProfessionalID = ParseLength( &pszDeptUserInfo[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;

	// Field10. AREAID	B16		BINARY	C+
	psUserDept->dwAreaID = MAKE_UINT16_EX_( pszDeptUserInfo );
	u32Pos += UINT16_BYTES;


	psUserDept->dwUpdateTime = MAKE_UINT32_EX_( pszDeptUserInfo );
	u32Pos += UINT32_BYTES;


	// Field11. UPDATETYPE	N1		ASCII	M+
	psUserDept->wUpdate_type = ParseLength( &pszDeptUserInfo[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;

	if(u32Pos - *pu32StartPos != u16DeptUserInfoLength)
		return EIMERR_PACKAGE_ERROR;		// Package error

	ntoh_term_userdept( psUserDept );
	*pu32StartPos = u32Pos;				// Update position for next parse
	return EIMERR_SUCCESS;				// Parse succeeded
}

//=============================================================================
//Function:     CLIENT_ParseUserInfo
//Description:	Parse VAL package of USERINFO, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 4.2 获取人员基本信息应答	USERINFO	 <==> USERINFO
//
//Parameter:
//	pszUserInfo     - The Head of VLA
//	pu32StartPos    - Start parse position, first time must be set to 0, it will be auto updated
//	pUserInfo       - Return the parsed result of USERINFO
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//	   -2	- Package error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserInfo(const char* pszUserInfo, UINT32* pu32StartPos, USERINFO* psUserInfo)
#else
int   CLIENT_ParseUserInfo(const char* pszUserInfo, UINT32* pu32StartPos, USERINFO* psUserInfo)
#endif
{
#define BIT_(n)	( ((u32BitMap) >> (n)) & 1 )

	UINT32 u32Pos;					// Temp pos for parse
	UINT32 u32Length;				// Temp length for VAR length
	UINT32 u32BitMap;				// BIT MAP	B32		BINARY	M+
	UINT32 u32UserInfoPackSize;		// 4.2:4	USERINFO	ANS...1904	LLLLVAR	ASCII	C+	
	UINT16 u16UserInfoLength;		// 4.2:4.1	PLENGTH	B16		BINARY	M+	数据包长度，指示的长度包含本身所需的两个字节

	// Check parameter
	if( pszUserInfo == NULL || pu32StartPos == NULL || psUserInfo == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;	// Parameter error
	}

	// Check package size
	u32UserInfoPackSize = ParseLength( pszUserInfo, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32UserInfoPackSize )
		return EIMERR_PARSE_FINISHED;		// Parse finished

	// Check position
	if( *pu32StartPos == 0 )			// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;	// Skip the length data of DEPTINFO 
	
	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserInfo, 0, sizeof(USERINFO) );

	// Field1. PLENGTH	B16		BINARY	M+
	u16UserInfoLength = MAKE_UINT16_EX_( pszUserInfo );
	u16UserInfoLength = ntohs( u16UserInfoLength );
	u32Pos += UINT16_BYTES;

	// Field2. BIT MAP	B32		BINARY	M+
	u32BitMap = MAKE_UINT32_EX_( pszUserInfo );
	u32BitMap = ntohl( u32BitMap );
	u32Pos   += UINT32_BYTES;

	if( BIT_(0) )
	{
		psUserInfo->dwUserID = MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}

	if( BIT_(1) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLVAR_BYTES );
		memcpy( psUserInfo->aszCnUserName , &pszUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, USERNAME_MAXLEN) );
		u32Pos += u32Length + LLLVAR_BYTES;
	}
	if( BIT_(2) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLVAR_BYTES );
		memcpy( psUserInfo->aszEnUserName , &pszUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, USERNAME_MAXLEN) );
		u32Pos += u32Length + LLLVAR_BYTES;
	}

	// Field4. 1	USERCODE	ANS..17	LLVAR	ASCII	C+
	if( BIT_(3) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->aszUserCode, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, USERCODE_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}

 

	// Field6. 3	SEX	N1		ASCII	C+
	if( BIT_(4) )
	{
		psUserInfo->cSex = ParseLength( &pszUserInfo[u32Pos], LVAR_BYTES );
		u32Pos += LVAR_BYTES;
	}

	if( BIT_(5) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLLVAR_BYTES );
		memcpy( psUserInfo->aszAdrr, &pszUserInfo[u32Pos + LLLLVAR_BYTES], MIN_(u32Length, MAX_ADDR_LEN) );
		u32Pos += u32Length + LLLLVAR_BYTES;
	}

	if( BIT_(6) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLVAR_BYTES );
		memcpy( psUserInfo->aszPost, &pszUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, POST_MAXLEN) );
		u32Pos += u32Length + LLLVAR_BYTES;
	}


	if( BIT_(7) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->aszTel, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, TEL_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}

		if( BIT_(8) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->aszPhone, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, PHONE_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}
	if( BIT_(9) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->aszEmail, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, EMAIL_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}


	if( BIT_(10) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->aszPostcode, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, POSTCODE_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}

	if( BIT_(11) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->aszFax, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, FAX_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}
	if( BIT_(12) )
	{
	psUserInfo->dwUpdateTime = MAKE_UINT32_EX_( pszUserInfo );
	u32Pos += UINT32_BYTES;
	}

	// Field15. 12	UPDATETYPE	N1		ASCII	C+	
	if( BIT_(13) )
	{
		psUserInfo->wUpdate_type = ParseLength( &pszUserInfo[u32Pos], LVAR_BYTES );
		u32Pos += LVAR_BYTES;
	}
	
	if (BIT_(14))
	{
		psUserInfo->dwBirth = MAKE_UINT32_EX_(pszUserInfo);
		u32Pos += UINT32_BYTES;
	}

	if (BIT_(15))
	{
		psUserInfo->dwHiredate = MAKE_UINT32_EX_(pszUserInfo);
		u32Pos += UINT32_BYTES;
	}

	if (BIT_(16))
	{
		u32Length = ParseLength(&pszUserInfo[u32Pos], LLLVAR_BYTES);
		memcpy(psUserInfo->aszSign, &pszUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, SIGN_MAXLEN));
		u32Pos += u32Length + LLLVAR_BYTES;
	}

	if( u32Pos - *pu32StartPos != u16UserInfoLength )
		return EIMERR_PACKAGE_ERROR;		// Package error

	ntoh_term_userinfo( psUserInfo );
	*pu32StartPos = u32Pos;				// Update position for next parse
	return EIMERR_SUCCESS;				// Parse succeeded
}

//=============================================================================
//Function:     CLIENT_ParseUserInfoFast
//Description:	Parse VAL package of USERINFO, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 4.2 获取人员基本信息应答	USERINFO	 <==> UserListMobile
//
//Parameter:
//	pszUserListMobile	- The Head of VLA
//	pu32StartPos		- Start parse position, first time must be set to 0, it will be auto updated
//	psUserListMobile	- Return the parsed result of UserListMobile
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserListMobile(const char* pszUserListMobile, UINT32* pu32StartPos, UserListMobile* psUserListMobile)
#else
int   CLIENT_ParseUserListMobile(const char* pszUserListMobile, UINT32* pu32StartPos, UserListMobile* psUserListMobile)
#endif
{
	UINT32 u32Pos;						// Temp pos for parse
	UINT32 u32UserListMobilePackSize;	// 4.2:4	USERINFO	ANS...1904	LLLLVAR	ASCII	C+	

	// Check parameter
	if( pszUserListMobile == NULL || pu32StartPos == NULL || psUserListMobile == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;		// Parameter error
	}

	// Check package size
	u32UserListMobilePackSize = ParseLength( pszUserListMobile, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32UserListMobilePackSize )
		return EIMERR_PARSE_FINISHED;			// Parse finished

	// Check position
	if( *pu32StartPos == 0 )			// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;	// Skip the length data of DEPTINFO 
	
	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserListMobile, 0, sizeof(UserListMobile) );

	// Field1. USERID	B32		BINARY	M+
	psUserListMobile->dwUserID = MAKE_UINT32_EX_( pszUserListMobile );
	psUserListMobile->dwUserID = ntohl( psUserListMobile->dwUserID );
	u32Pos += UINT32_BYTES;

	// Field2. UPDATETYPE	N1		ASCII	M+
	psUserListMobile->wUpdate_type = ParseLength( &pszUserListMobile[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;

	*pu32StartPos = u32Pos;		// Update position for next parse
	return EIMERR_SUCCESS;		// Parse succeeded
}

//=============================================================================
//Function:     CLIENT_UserStatusSetNotice
//Description:	Parse VAL package of USERSTATEINFO, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 5.2 获取人员基本信息应答	USERSTATEINFO	 <==> USERSTATUSNOTICE
//
//Parameter:
//	pszUserStatusSetNotice	- The Head of VLA
//	pu32StartPos			- Start parse position, first time must be set to 0, it will be auto updated
//	psUserStatusNotice		- Return the parsed result of USERSTATUSNOTICE
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserStatusSetNotice(const char* pszUserStatusSetNotice, UINT32* pu32StartPos, USERSTATUSNOTICE* psUserStatusNotice)
#else
int   CLIENT_ParseUserStatusSetNotice(const char* pszUserStatusSetNotice, UINT32* pu32StartPos, USERSTATUSNOTICE* psUserStatusNotice)
#endif
{
	/*UINT32 u32Pos;						
	UINT32 u32UserStatusSetNoticePackSize;	// USERSTATUSNOTICE	

	// Check parameter
	if( pszUserStatusSetNotice == NULL || pu32StartPos == NULL || psUserStatusNotice == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;			// Parameter error
	}

	// Check package size
	u32UserStatusSetNoticePackSize = ParseLength( pszUserStatusSetNotice, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32UserStatusSetNoticePackSize )
		return EIMERR_PARSE_FINISHED;				// Parse finished

	// Check position
	if( *pu32StartPos == 0 )				// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;		// Skip the length data of DEPTINFO 
	
	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserStatusNotice, 0, sizeof(USERSTATUSNOTICE) );

	// Field1. USERID	B32		BINARY	M+
	psUserStatusNotice->dwUserID = MAKE_UINT32_EX_( pszUserStatusSetNotice );
	psUserStatusNotice->dwUserID = ntohl( psUserStatusNotice->dwUserID );
	u32Pos += UINT32_BYTES;

	// Field2. STATE	N1		ASCII	M+	1:在线 2:离开
	psUserStatusNotice->cStatus		= ParseLength( &pszUserStatusSetNotice[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;

	// Field3. LOGINTYPE	N1		ASCII	M+	1:ANDROID 2:IOS 3:PC
	psUserStatusNotice->cLoginType	= ParseLength( &pszUserStatusSetNotice[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;

	*pu32StartPos = u32Pos;		// Update position for next parse
	*/
	return EIMERR_SUCCESS;		// Parse succeeded
}

//=============================================================================
//Function:     CLIENT_ParseUserRank
//Description:	Parse VAL package of USERRANK, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 7.1 获取用户级别信息应答	USERRANKINFO <==> USERRANK
//
//Parameter:
//	pszUserRank     - The Head of VLA
//	pu32StartPos    - Start parse position, first time must be set to 0, it will be auto updated
//	psUserRank      - Return the parsed result of USERRANK
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//	   -2	- Package error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserRank(const char* pszUserRank, UINT32* pu32StartPos, USERRANK* psUserRank)
#else
int   CLIENT_ParseUserRank(const char* pszUserRank, UINT32* pu32StartPos, USERRANK* psUserRank)
#endif
{
	UINT32 u32Pos;					// Temp pos for parse
	UINT32 u32Length;				// Temp length for VAR length
	UINT32 u32UserRankSize;			// 7.1|2:4		USERRANKINFO	ANS..1904	LLLLVAR	ASCII	C+	
	UINT16 u16UserRankLength;		// 7.1|2:4.1	PLENGTH	B16		BINARY	M+	数据包长度，指示的长度包含本身所需的两个字节

	// Check parameter
	if( pszUserRank == NULL || pu32StartPos == NULL || psUserRank == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;	// Parameter error
	}

	// Check package size
	u32UserRankSize = ParseLength( pszUserRank, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32UserRankSize )
		return EIMERR_PARSE_FINISHED;		// Parse finished

	// Check position
	if( *pu32StartPos == 0 )			// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;	// Skip the length data of USERRANKINFO 

	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserRank, 0, sizeof(USERRANK) );

	// Field1. PLENGTH	B16		BINARY	M+	数据包长度，指示的长度包含本身所需的两个字节
	u16UserRankLength = MAKE_UINT16_EX_( pszUserRank );
	u16UserRankLength = ntohs( u16UserRankLength );
	u32Pos += UINT16_BYTES;

	// Field2. RANKID	N1		ASCII	M+
	psUserRank->cRankID = ParseLength( &pszUserRank[u32Pos], LVAR_BYTES );
	u32Pos += UINT8_BYTES;

	// Field3. USERCODE	ANS..17	LLVAR	ASCII	M+
	u32Length = ParseLength( &pszUserRank[u32Pos], LLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psUserRank->aszRankName, &pszUserRank[u32Pos + LLVAR_BYTES], MIN_(u32Length, RANKNAME_LEN) );
	u32Pos += u32Length + LLVAR_BYTES;

	// Field4. UPDATETYPE	N1		ASCII	M+	
	psUserRank->wUpdate_type = ParseLength( &pszUserRank[u32Pos], LVAR_BYTES );
	u32Pos += UINT8_BYTES;

	if(u32Pos - *pu32StartPos != u16UserRankLength)
		return EIMERR_PACKAGE_ERROR;		// Package error

	*pu32StartPos = u32Pos;				// Update position for next parse
	return EIMERR_SUCCESS;				// Parse succeeded
}

//=============================================================================
//Function:     CLIENT_ParseUserPro
//Description:	Parse VAL package of USERPROFESSIONAL, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 7.2 获取用户级别信息应答	 USERRANKINFO <==> USERPROFESSIONAL
//
//Parameter:
//	pszUserPro     - The Head of VLA
//	pu32StartPos    - Start parse position, first time must be set to 0, it will be auto updated
//	psUserPro      - Return the parsed result of USERPROFESSIONAL
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//	   -2	- Package error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserPro(const char* pszUserPro, UINT32* pu32StartPos, USERPROFESSIONAL* psUserPro)
#else
int   CLIENT_ParseUserPro(const char* pszUserPro, UINT32* pu32StartPos, USERPROFESSIONAL* psUserPro)
#endif
{
	return CLIENT_ParseUserRank(pszUserPro, pu32StartPos, (USERRANK*)psUserPro);
}

//=============================================================================
//Function:     CLIENT_ParseUserArea
//Description:	Parse VAL package of USERAREA, you need repeat call this function
//  to parse whole package until finished or occur error.
//
//	Reference: 7.1 获取用户级别信息应答	USERAREAINFO <==> USERAREA
//
//Parameter:
//	pszUserArea     - The Head of VLA
//	pu32StartPos    - Start parse position, first time must be set to 0, it will be auto updated
//	psUserArea      - Return the parsed result of USERAREAINFO
//
//Return:
//		1	- Reach at the end of the package, parse finished
//		0	- Parse succeeded of this time
//	   -1	- Parameter error
//	   -2	- Package error
//=============================================================================
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserArea(const char* pszUserArea, UINT32* pu32StartPos, USERAREA* psUserArea)
#else
int   CLIENT_ParseUserArea(const char* pszUserArea, UINT32* pu32StartPos, USERAREA* psUserArea)
#endif
{
	UINT32 u32Pos;					// Temp pos for parse
	UINT32 u32Length;				// Temp length for VAR length
	UINT32 u32UserAreaSize;			// 7.3:4	USERAREAINFO	ANS..1904	LLLLVAR	ASCII	C+	
	UINT16 u16UserAreaLength;		// 7.3:4.1	PLENGTH	B16		BINARY	M+	数据包长度，指示的长度包含本身所需的两个字节

	// Check parameter
	if( pszUserArea == NULL || pu32StartPos == NULL || psUserArea == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;	// Parameter error
	}

	// Check package size
	u32UserAreaSize = ParseLength( pszUserArea, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32UserAreaSize )
		return EIMERR_PARSE_FINISHED;		// Parse finished

	// Check position
	if( *pu32StartPos == 0 )			// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;	// Skip the length data of USERRANKINFO 

	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserArea, 0, sizeof(USERAREA) );

	// Field1.PLENGTH	B16		BINARY	M+	数据包长度，指示的长度包含本身所需的两个字节
	u16UserAreaLength = MAKE_UINT16_EX_( pszUserArea );
	u16UserAreaLength = ntohs( u16UserAreaLength );
	u32Pos += UINT16_BYTES;

	// Field2. AREAID	B16		BINARY	M+
	psUserArea->dwAreaID = MAKE_UINT16_EX_( pszUserArea );
	psUserArea->dwAreaID = ntohs( psUserArea->dwAreaID );
	u32Pos += UINT16_BYTES;

	// Field3. USERCODE	ANS..17	LLVAR	ASCII	M+
	u32Length = ParseLength( &pszUserArea[u32Pos], LLVAR_BYTES );
	if(u32Length > 0)
		memcpy( psUserArea->aszAreaName, &pszUserArea[u32Pos + LLVAR_BYTES], MIN_(u32Length, AREANAME_LEN) );
	u32Pos += u32Length + LLVAR_BYTES;

	// Field4. PID	B16		BINARY	M+	
	psUserArea->dwPID = MAKE_UINT16_EX_( pszUserArea );
	psUserArea->dwPID = ntohs( psUserArea->dwPID );
	u32Pos += UINT16_BYTES;

	// Field4. UPDATETYPE	N1		ASCII	M+
	psUserArea->wUpdate_type = ParseLength( &pszUserArea[u32Pos], LVAR_BYTES );
	u32Pos += UINT8_BYTES;

	if(u32Pos - *pu32StartPos != u16UserAreaLength)
		return EIMERR_PACKAGE_ERROR;		// Package error

	*pu32StartPos = u32Pos;				// Update position for next parse
	return EIMERR_SUCCESS;				// Parse succeeded
}

#ifdef WIN32
IM_API( int )  CLIENT_SetRsaKeyPath(char* path)
#else
IM_API int   CLIENT_SetRsaKeyPath(char* path)
#endif
{
	strcpy(m_strRsaPathFile,path);
	return EIMERR_SUCCESS;

}

#ifdef WIN32
IM_API( int )  CLIENT_Log(PCONNCB pConnCB, const char* pszFmt, ...)
#else
int   CLIENT_Log(PCONNCB pConnCB, const char* pszFmt, ...)
#endif
{
#ifdef _LOG_FLAG_
	va_list args;
	va_start(args, pszFmt);
	if(pConnCB)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, pszFmt, args);
	}
	else
	{
		vprintf(pszFmt,args);
	}
	va_end(args);
#endif
	
	return EIMERR_SUCCESS;
}



#ifdef WIN32
	IM_API( int )  CLIENT_GetSpecialList(PCONNCB pConnCB,GETSPECIALLIST *pData)
#else
	int   CLIENT_GetSpecialList(PCONNCB pConnCB,GETSPECIALLIST *pData)
#endif
{
 
    GETSPECIALLIST *pBody ;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETSPECIALLIST) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

 
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pBody = (GETSPECIALLIST*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GETSPECIALLIST;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;
 
	memcpy(pBody,pData,sizeof(GETSPECIALLIST));


	pBody->dwUserID =htonl(pBody->dwUserID);		//普通用户ID
	for(int i=0; i< pBody->cDeptNum && i<MAXNUM_USERIN_DEPT; i++)
	{
		pBody->dwDepID[i]= htonl(pBody->dwDepID[i]);
	}
	pBody->nSpecialTme=htonl(pBody->nSpecialTme);		//特殊用户时间戳
	pBody->nWhiteTime = htonl(pBody->nWhiteTime);	//白名单时间戳
 
	hton_term_head(pHead);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}


 
#ifdef WIN32
IM_API( int )  CLIENT_ModiSpecialListNoticeAck(PCONNCB pConnCB,UINT64 dwMsgID)
#else
int   CLIENT_ModiSpecialListNoticeAck(PCONNCB pConnCB,UINT64 dwMsgID)
#endif
{
	MODISPECIALLISTNOTICEACK *pAck;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MODISPECIALLISTNOTICEACK) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

   
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pAck = (MODISPECIALLISTNOTICEACK*)((char*)pHead + MSGHEAD_LEN);
    pHead->wCmdID  = CMD_MODISPECIALLISTNOTICEACK;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = sizeof(MODISPECIALLISTNOTICEACK) + MSGHEAD_LEN;

    pAck->dwUserID = pConnCB->dwUserID;
    pAck->dwMsgID  = dwMsgID;
    hton_term_head(pHead);
    hton_ModiSpecialListNoticeAck(pAck);

    nRet = EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,(char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

/*client发送获取状态请求
*
*return :
*     0: success;
      <0 失败：参加返回值，错误码
*/
#ifdef WIN32
IM_API( int )  CLIENT_GetUserStatusReq(PCONNCB pConnCB,TGetStatusReq *pStatusReq)
#else
int   CLIENT_GetUserStatusReq(PCONNCB pConnCB,TGetStatusReq *pStatusReq)
#endif 
{
    int		nRet = 0;
    INT8	aszPacket[PACKET_MAXLEN];
    int		nMsgLen =0;

	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pStatusReq);


    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
	int tmpLen = sizeof(TGetStatusReq)- (MAX_USERSTATUS_NUM-pStatusReq->nUserNum)*sizeof(pStatusReq->uUserId);

	hton_TGetStatusReq_req(pStatusReq);
 
	nMsgLen = tmpLen + MSGHEAD_LEN;
    pHead->wCmdID  = CMD_GET_STATUS_REQ;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;


    hton_term_head(pHead);
	memcpy(pHead->aszMsg, pStatusReq, tmpLen);

    nRet = EncryptSendHttpData( CMD_SEND_OR_RECV_DATA,pConnCB->nSocket,(char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}
/*client发送订阅请求
*
*return :
*     0: success;
      <0 失败：参加返回值，错误码
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendSubscribeReq(PCONNCB pConnCB,SUBSCRIBER_REQ *pData)
#else
int   CLIENT_SendSubscribeReq(PCONNCB pConnCB,SUBSCRIBER_REQ *pData)
#endif 
{
	int		nRet = 0;
    INT8	aszPacket[PACKET_MAXLEN];

	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pData);

    memset(aszPacket, 0, sizeof(aszPacket));
	pData->mPackageHead.cBusinessType=THead::SUBCRIBE_SERVICE;
	//pData->cRequestType=1;
	pData->mPackageHead.cDstType=0;
	pData->mPackageHead.dwDstId=0;

	int tmpLen;
	tmpLen = sizeof(SUBSCRIBER_REQ)- (MAX_USERSTATUS_NUM-pData->wNum) *sizeof(UINT32);
	pData->mPackageHead.wPackageBodyLen=htons(tmpLen-sizeof(THead));

	hton_term_SUBSCRIBER_REQ(pData);
 
    nRet = EncryptSendHttpData( CMD_PROTOCOL_SEND_OR_RECV_DATA,pConnCB->nSocket,(char*)pData, tmpLen);
    return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_user_status_Parse(BOOL  bNeedTurn, user_status* pData, TUserStatusList* pStatusList )
#else
int   CLIENT_user_status_Parse(BOOL  bNeedTurn,user_status* pData, TUserStatusList* pStatusList )
#endif
{

	UINT16 szNum[4];//离线 0， 在线 1 ，离开 2，移动 3
	UINT8  szStatus[4];
	INT8* pInBuf=(INT8*)pData;
	memcpy(szNum,pData, sizeof(szNum));
	for(int i=0; i< 4; i++)
	{
		if(bNeedTurn)
		szNum[i]= ntohs(szNum[i]);
		szStatus[i]=i;
	}
	INT32 pos=sizeof(szNum);
	UINT8 cType=3;//3PC; 手机1，2 
	INT32 iUserNum=0;
	memset(pStatusList, 0, sizeof(TUserStatusList));
	for(int i=0; i< 4; i++)
	{

		if(i == 3)
			cType = 1;
		for(int j=0; j< szNum[i]; j++)
		{
			pStatusList->dwUserStatusNum++;
			if(bNeedTurn)
				pStatusList->szUserStatus[iUserNum].dwUserID=ntohl(*((UINT32*)(pInBuf+pos)));
			else
				pStatusList->szUserStatus[iUserNum].dwUserID=(*((UINT32*)(pInBuf+pos)));
			//移动在线
			if (i == 3)
				pStatusList->szUserStatus[iUserNum].cStatus = 1; 
			else
				pStatusList->szUserStatus[iUserNum].cStatus =szStatus[i];

			pStatusList->szUserStatus[iUserNum].cLoginType = cType;
			pos += sizeof(INT32);
			iUserNum++;
		}
	}
	return 0;
}

#ifdef WIN32
IM_API( int )  CLIENT_SendJSON(PCONNCB pConnCB,TJson *pData)
#else
int   CLIENT_SendJSON(PCONNCB pConnCB,TJson *pData)
#endif 
{
	int		nRet = 0;
	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pData);

	int len = pData->mPackageHead.wPackageBodyLen+sizeof(pData->mPackageHead);
	hton_TJson(pData);
    nRet = EncryptSendHttpData( CMD_PROTOCOL_SEND_OR_RECV_DATA,pConnCB->nSocket,(char*)pData, len);
    return ENC_SEND_RET_( nRet );
}


/*clientjson格式发送数据包体,加密
*
*return :
*     0: success; 其他参看错误码
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendJSON_Encrypt(PCONNCB pConnCB,TJson *pData)
#else
int   CLIENT_SendJSON_Encrypt(PCONNCB pConnCB,TJson *pData)
#endif 
{
	int		nRet = 0;
	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pData);

	int len = pData->mPackageHead.wPackageBodyLen+sizeof(pData->mPackageHead);
	hton_TJson(pData);
    nRet = EncryptSendHttpData( CMD_PROTOCOL_SEND_OR_RECV_DATA_ENCRYPT,pConnCB->nSocket,(char*)pData, len);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )	CLIENT_GetConnectRspInfo(PCONNCB pConnCB,  LOGINACCESSACK *pTaccessResponse)
#else
int				CLIENT_GetConnectRspInfo(PCONNCB pConnCB, LOGINACCESSACK *pTaccessResponse)
#endif 
{
	memcpy(pTaccessResponse,&pConnCB->tAccessAck , sizeof(LOGINACCESSACK));
	return EIMERR_SUCCESS;
}



#ifdef WIN32
IM_API( int )  CLIENT_RoamingDataSync(PCONNCB pConnCB,ROAMDATASYNC *pData)
#else
int   CLIENT_RoamingDataSync(PCONNCB pConnCB,ROAMDATASYNC *pData)
#endif
{

	ROAMDATASYNC *pBody ;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	int nMsgLen = sizeof(ROAMDATASYNC) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pData);
	memset(aszPacket, 0, sizeof(aszPacket));

	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
	pBody = (ROAMDATASYNC*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_ROAMINGDATASYN;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	memcpy(pBody,pData,sizeof(ROAMDATASYNC));

	hton_term_ROAMDATASYNC(pBody);
	hton_term_head(pHead);

	nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_RoamingDataModi(PCONNCB pConnCB,ROAMDATAMODI *pData)
#else
int   CLIENT_RoamingDataModi(PCONNCB pConnCB,ROAMDATAMODI *pData)
#endif
{

	ROAMDATAMODI *pBody ;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN+500];
	int nMsgLen = sizeof(ROAMDATAMODI)-( ROAMINGDATA_FRE_CON - pData->wNum)*sizeof(UINT32) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pData);
	memset(aszPacket, 0, sizeof(aszPacket));

	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket );
	pBody = (ROAMDATAMODI*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_ROAMINGDATAMODI;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	memcpy(pBody,pData,sizeof(ROAMDATAMODI));

	hton_term_ROAMDATAMODI(pBody);
	hton_term_head(pHead);

	nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,  (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}


#ifdef WIN32
IM_API( int ) CLIENT_ParseEmploee(const char* pszEmploee, UINT32* pu32StartPos, EMPLOYEE* psUserInfo)
#else
IM_API int  CLIENT_ParseEmploee(const char* pszEmploee, UINT32* pu32StartPos, EMPLOYEE* psUserInfo)
#endif
{

	//#define BIT_(n)	( ((u32BitMap) >> (n)) & 1 )

	UINT32 u32Pos;					// Temp pos for parse
	UINT32 u32Length;				// Temp length for VAR length
	UINT32 u32BitMap;				// BIT MAP	B32		BINARY	M+
	//UINT32 u32UserInfoPackSize;		// 4.2:4	USERINFO	ANS...1904	LLLLVAR	ASCII	C+	
	UINT16 u16UserInfoLength;		// 4.2:4.1	PLENGTH	B16		BINARY	M+	数据包长度，指示的长度包含本身所需的两个字节

	const char* pszUserInfo = pszEmploee;


	// Check parameter
	if( pszUserInfo == NULL || pu32StartPos == NULL || psUserInfo == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;	// Parameter error
	}



	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserInfo, 0, sizeof(EMPLOYEE) );

	// Field1. PLENGTH	B16		BINARY	M+
	u16UserInfoLength = MAKE_UINT16_EX_( pszUserInfo );
	u16UserInfoLength = ntohs( u16UserInfoLength );
	u32Pos += UINT16_BYTES;

	// Field2. BIT MAP	B32		BINARY	M+
	u32BitMap = MAKE_UINT32_EX_( pszUserInfo );
	u32BitMap = ntohl( u32BitMap );
	u32Pos   += UINT32_BYTES;

	if( BIT_(0) )
	{
		psUserInfo->tUserInfo.dwUserID =psUserInfo->tUserExtend.dwUserID = MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}

	if( BIT_(1) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszCnUserName, &pszUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, USERNAME_MAXLEN) );
		u32Pos += u32Length + LLLVAR_BYTES;
	}
	if( BIT_(2) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszEnUserName , &pszUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, USERNAME_MAXLEN) );
		u32Pos += u32Length + LLLVAR_BYTES;
	}

	// Field4. 1	USERCODE	ANS..17	LLVAR	ASCII	C+
	if( BIT_(3) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszUserCode, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, USERCODE_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}



	// Field6. 3	SEX	N1		ASCII	C+
	if( BIT_(4) )
	{
		psUserInfo->tUserInfo.cSex = ParseLength( &pszUserInfo[u32Pos], LVAR_BYTES );
		u32Pos += LVAR_BYTES;
	}

	if( BIT_(5) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszAdrr, &pszUserInfo[u32Pos + LLLLVAR_BYTES], MIN_(u32Length, MAX_ADDR_LEN) );
		u32Pos += u32Length + LLLLVAR_BYTES;
	}

	if( BIT_(6) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszPost, &pszUserInfo[u32Pos + LLLVAR_BYTES], MIN_(u32Length, POST_MAXLEN) );
		u32Pos += u32Length + LLLVAR_BYTES;
	}


	if( BIT_(7) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszTel, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, TEL_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}

	if( BIT_(8) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszPhone, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, PHONE_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}
	if( BIT_(9) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszEmail, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, EMAIL_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}


	if( BIT_(10) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszPostcode, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, POSTCODE_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}

	if( BIT_(11) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserInfo.aszFax, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, FAX_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}
	if( BIT_(12) )
	{
		psUserInfo->tUserInfo.dwUpdateTime = MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}

	// Field15. 12	UPDATETYPE	N1		ASCII	C+	
	if( BIT_(13) )
	{
		psUserInfo->tUserInfo.wUpdate_type = ParseLength( &pszUserInfo[u32Pos], LVAR_BYTES );
		u32Pos += LVAR_BYTES;
	}

	if( BIT_(14) )
	{
		psUserInfo->tUserExtend.dwCompID = MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}

	if( BIT_(15) )
	{
		psUserInfo->tUserExtend.dwUserID = MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}

	if( BIT_(16) )
	{

		memcpy(psUserInfo->tUserExtend.aszPassword,&pszUserInfo[u32Pos],PASSWD_MAXLEN);
		u32Pos +=   PASSWD_MAXLEN;
	}

	if( BIT_(17) )
	{

		memcpy(psUserInfo->tUserExtend.aszLogo,&pszUserInfo[u32Pos],LOGO_MAXLEN);
		u32Pos +=   LOGO_MAXLEN;
	}

	if( BIT_(18) )
	{
		psUserInfo->tUserExtend.dwLogoUpdateTime = MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}
	if( BIT_(19) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserExtend.aszSign, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, SIGN_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}
	if( BIT_(20) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserExtend.aszHomeTel, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, TEL_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}
	if( BIT_(21) )
	{
		u32Length = ParseLength( &pszUserInfo[u32Pos], LLVAR_BYTES );
		memcpy( psUserInfo->tUserExtend.aszEmergencyphone, &pszUserInfo[u32Pos + LLVAR_BYTES], MIN_(u32Length, TEL_MAXLEN) );
		u32Pos += u32Length + LLVAR_BYTES;
	}
	if( BIT_(22) )
	{
		psUserInfo->tUserExtend.cMsgsynType = pszUserInfo[u32Pos];
		u32Pos += 1;
	}
	if( BIT_(23) )
	{
		psUserInfo->tUserExtend.cUserType = pszUserInfo[u32Pos];
		u32Pos += 1;
	}
	if( BIT_(24) )
	{
		psUserInfo->tUserExtend.cForbidden = pszUserInfo[u32Pos];
		u32Pos += 1;
	}
	if( BIT_(25) )
	{
		psUserInfo->tUserExtend.dwBirth =  MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}

	if( BIT_(26) )
	{
		psUserInfo->tUserExtend.dwUpdateTime =  MAKE_UINT32_EX_( pszUserInfo );
		u32Pos += UINT32_BYTES;
	}

	if( BIT_(27) )
	{
		psUserInfo->tUserExtend.wUpdate_type = pszUserInfo[u32Pos];
		u32Pos += 1;
	}
	if( BIT_(28) )
	{
		psUserInfo->tUserExtend.cStatus = pszUserInfo[u32Pos];
		u32Pos += 1;
	}

	if( BIT_(29) )
	{
		psUserInfo->tUserExtend.cLoginType = pszUserInfo[u32Pos];
		u32Pos += 1;
	}

	if( BIT_(30) )
	{
		psUserInfo->tUserExtend.wPurview =  MAKE_UINT16_EX_( pszUserInfo );
		u32Pos += UINT16_BYTES;
	}

	if( BIT_(31) )
	{
		memcpy(psUserInfo->tUserExtend.mPurview,&pszUserInfo[u32Pos],sizeof(psUserInfo->tUserExtend.mPurview));
		u32Pos += sizeof(psUserInfo->tUserExtend.mPurview);
	}



	if( u32Pos - *pu32StartPos != u16UserInfoLength )
		return EIMERR_PACKAGE_ERROR;		// Package error
	ntoh_term_employee(psUserInfo);

	*pu32StartPos = u32Pos;				// Update position for next parse
	return EIMERR_SUCCESS;				// Parse succeeded
}


#ifdef WIN32
IM_API (int) CLIENT_SetAliveTime(PCONNCB pConnCB,INT32 iAliveTime)
#else
IM_API int CLIENT_SetAliveTime(PCONNCB pConnCB,INT32 iAliveTime)
#endif
{
	pConnCB->dwAliveTime = iAliveTime;
	return EIMERR_SUCCESS;
}


#ifdef WIN32
IM_API( int )  CLIENT_GetUserHeadIconList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#else
int  CLIENT_GetUserHeadIconList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType)
#endif
{
    TGetUserHeadIconList *pUserList;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(TGetUserHeadIconList) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pUserList = (TGetUserHeadIconList*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GET_HEAD_ICON_ADD_LIST_REQ;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pUserList->dwUserID   = pConnCB->dwUserID;
    pUserList->dwCompID   = pConnCB->dwCompID;
	pUserList->cLoginType = cType;
    pUserList->dwLastUpdateTime = nLastUpdateTime;

    hton_term_head(pHead);
	hton_TGetUserHeadIconList(pUserList);
 

    nRet =EncryptSendHttpData( CMD_SEND_OR_RECV_DATA,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

//解析获取头像变化用户列表
#ifdef WIN32
IM_API( int ) CLIENT_ParseUserHeadIconList(const char* pszUserList, UINT32* pu32StartPos, TUserHeadIconList* psUserList)
#else
IM_API int  CLIENT_ParseUserHeadIconList(const char* pszUserList, UINT32* pu32StartPos, TUserHeadIconList* psUserList)
#endif
{
	UINT32 u32Pos;						// Temp pos for parse
	UINT32 u32UserListPackSize;	// 4.2:4	USERINFO	ANS...1904	LLLLVAR	ASCII	C+	

	// Check parameter
	if( pszUserList == NULL || pu32StartPos == NULL || psUserList == NULL )
	{
		//ASSERT_(0);
		return EIMERR_INVALID_PARAMTER;		// Parameter error
	}

	// Check package size
	u32UserListPackSize = ParseLength( pszUserList, LLLLVAR_BYTES );
	if( *pu32StartPos >= u32UserListPackSize )
		return EIMERR_PARSE_FINISHED;			// Parse finished

	// Check position
	if( *pu32StartPos == 0 )			// Is first time parse
		*pu32StartPos += LLLLVAR_BYTES;	// Skip the length data of DEPTINFO 
	
	// Prepare 
	u32Pos = *pu32StartPos;
	memset( psUserList, 0, sizeof(TUserHeadIconList) );

	// Field1. USERID	B32		BINARY	M+
	psUserList->dwUserID = MAKE_UINT32_EX_( pszUserList );
	psUserList->dwUserID = ntohl( psUserList->dwUserID );
	u32Pos += UINT32_BYTES;

	// Field2. UPDATETYPE	N1		ASCII	M+
	psUserList->wUpdate_type = ParseLength( &pszUserList[u32Pos], LVAR_BYTES );
	u32Pos += LVAR_BYTES;

	*pu32StartPos = u32Pos;		// Update position for next parse
	return EIMERR_SUCCESS;		// Parse succeeded
}

#ifdef WIN32
IM_API( int ) CLIENT_GetErrorCode(RESULT eResult)
#else
IM_API int CLIENT_GetErrorCode(RESULT eResult)
#endif
	{
		switch(eResult)
		{
		case RESULT_SUCCESS:					return EIMERR_SUCCESS;
		case RESULT_NOLOGIN:					return EIMERR_NOT_LOGIN;				// 未登录 1
		case RESULT_RELOGIN:					return EIMERR_REPEAT_LOGIN;				// 重复登录 2
		case RESULT_INVALIDPASSWD:				return EIMERR_INVALID_PSW;				// 密码错误 3
		case RESULT_INVALIDUSER:				return EIMERR_NO_USER;					// 非法用户 4
		case RESULT_REQTIMEOUT:					return EIMERR_REQ_TIMEOUT;				// 请求超时 5
		case RESULT_NOGROUP:					return EIMERR_NO_GROUP;					// 没有该群组  6
		case RESULT_MSGLEN_OVERLOAD:			return EIMERR_MSGLEN_OVERLOAD;			// 消息长度太长 7
		case RESULT_UNKNOWN:					return EIMERR_UNKNOWNS;					// UNKNOW 8
		case RESULT_NOREGULAR_GROUP:			return EIMERR_NO_REGULAR_GROUP;			// 用户不在固定组 9
		case RESULT_GROUPEXIST:					return EIMERR_GROUP_EXISTED;			// 群组已存在 10
		case RESULT_GROUPCREATE:				return EIMERR_CREATE_GROUP_FAIL;		// 群组创建失败 11
		case RESULT_GROUPMEMBERISVIRTUAL:       return EIMERR_CREATE_GROUP_VIRGROUP;    // 群组不能包含虚拟组帐号
		case RESULT_FORBIDDENUSER:				return EIMERR_FORBIDDEN;
		case RESULT_INCALIDREQ:					return EIMERR_INCALIDREQ; 				//无效请求 13
		case RESULT_SYSTEM_OVERLOAD:			return EIMERR_SYSTEM_OVERLOAD;			//14 超过整体过载保护（200条/秒） 
		case RESULT_SYSTEM_MAX_CONNECT:			return EIMERR_SYSTEM_MAX_CONNECT;		//15 系统达到最大连接数
		case RESULT_USER_IN_BLACKLIST:			return EIMERR_USER_IN_BLACKLIST;		//16 用户在黑名单中（停止尝试登录）
		case RESULT_CLIENT_VERSION_TOO_LITTLE:	return EIMERR_VERSION_TOO_LITTLE;		//17 客户端版本过低(强制升级且是移动端才提示):
		
		case RESULT_CONNECT_SSO_FAIL:			return EIMERR_CONNECT_SSO;				//20 SSO 连接问题
		case RESULT_SSO_AD_NOFOUND:				return EIMERR_SSO_AD_NOFOUND;			//21 登录时在AD中不存在
		case RESULT_SSO_DB_NOFOUND:				return EIMERR_SSO_DB_NOFOUND;			//22 登录时在数据库中不存在（可能原因是没有从AD中将用户同步过来）
		case RESULT_SSO_SET_ADPASSWD_FAIL:		return EIMERR_SSO_SET_AD_PSW;			//23 Ad密码修改失败
		case RESULT_SSO_SET_DBPASSWD_FAIL:		return EIMERR_SSO_SET_DB_PSW;			//24 db密码修改失败
		case RESULT_SSO_SET_RTXPASSWD_FAIL:		return EIMERR_SSO_SET_RTX_PSW;			//25 rtx密码修改失败
		case RESULT_SSO_SET_NCPASSWD_FAIL:		return EIMERR_SSO_SET_NC_PSW;			//26 nc密码修改失败
		case RESULT_SSO_VISIT_AD_FAIL:			return EIMERR_SSO_VISIT_AD;				//27 AD服务器拒绝访问
		case RESULT_SSO_ORI_PASSWD_ERR:			return EIMERR_SSO_ORI_PSW;				//28 原密码错误
		case RESULT_SSO_IDENTITY_FAIL:			return EIMERR_SSO_IDENTITY;				//29 身份验证失败
		case RESULT_SSO_CALL_FAIL:				return EIMERR_SSO_CALL;					//30 当前调用无效
		case RESULT_SSO_NOMEMORY:				return EIMERR_SSO_NOMEMORY;				//31 没有足够的内存继续执行程序
		case RESULT_SSO_CONNECT_AD_FAIL:		return EIMERR_SSO_CONNECT_AD;			//32 无法连接AD服务器
		case RESULT_SSO_UPDATE_AD_FAIL:			return EIMERR_SSO_UPDATE_AD;			//33 在更新AD存储区的过程中发生错误
		case RESULT_SSO_OTHER_ERR:				return EIMERR_SSO_OTHER;				//34 其它错误
		case RESULT_SSO_USER_OR_PASSWD_ERR:		return EIMERR_SSO_USER_OR_PSW;			//35 用户名或密码错误
		case RESULT_SSO_USER_FORBID_ERR:		return EIMERR_SSO_USER_FORBID;			//36 用户被禁用
		case RESULT_SSO_USER_EXPIRE_ERR:		return EIMERR_SSO_USER_EXPIRE;			//37 账户已经过期
		case RESULT_SSO_USER_ORIGINALPASSWD_ERR:return EIMERR_SSO_USER_ORIGINALPSW;		//38 密码仍然为初始密码(123321)必须修改密码之后才能访问
		case RESULT_SSO_PASSWD_EXPIRE_NEXT_SET:	return EIMERR_SSO_PSW_EXPIRE_NEXT_SET;	//39 密码已经过期，需要修改密码后才能登录(用户下次登录必须更改密码)
		case RESULT_SSO_PASSWD_EXPIRE_ERR:		return EIMERR_SSO_PSW_EXPIRE;			//40 密码已经过期，需要修改密码后才能登录
		case RESULT_SSO_NO_VISIT_POWER:			return EIMERR_SSO_NO_VISIT_POWER;		//41 您没有访问该系统的权限

		case RESULT_SSO_IP_ILLEGAL_ERR:			return EIMERR_SSO_IP_ILLEGAL;			//60 请求IP不在TrustAccessorIPs范围内
		case RESULT_SSO_USER_OR_PASSWD_EMPTY:	return EIMERR_SSO_USER_OR_PSW_EMPTY;	//61 用户名或密码为空
		case RESULT_SSO_SYSCODE_EMPTY:			return EIMERR_SSO_SYSCODE_EMPTY;		//62 系统代码为空
		case RESULT_SSO_HTTP_GET_FORBID:		return EIMERR_SSO_HTTP_GET_FORBID;		//63 不能使用Get获取数据
		case RESULT_SSO_HTTP_POST_FORBID:		return EIMERR_SSO_HTTP_POST_FORBID;		//64 不能使用POST获取数据
		case RESULT_SSO_HTTP_CONTENTTYPE_ERR:	return EIMERR_SSO_HTTP_CONTENTTYPE;		//65 Content-Type 格式错误
		case RESULT_SSO_FUNCTION_FORBID:		return EIMERR_SSO_FUNCTION_FORBID;		//66 该功能未启用，无法通过该接口验证用户，请联系管理员。

		case RESULT_VIRGTOUP_NOT_EXIT:          return EIMERR_VIRGTOUP_NOT_EXIT;        //70 虚拟组不存在
		case RESULT_VIRGTOUP_OUTOF_SVC:         return EIMERR_VIRGTOUP_OUTOF_SVC;       //71 客户服务人员暂时无法提供服务，如有紧急事宜请拨打电话联系
		case RESULT_VIRGTOUP_SVC_DENIED:        return EIMERR_VIRGROUP_SVC_DENIED;      //72 虚拟组服务不能主动给用户发送消息（虚拟组成员返回消息）
		default: return EIMERR_FAILED;
		}
	}

#ifdef WIN32
IM_API( int )	CLIENT_Disconnect(PCONNCB pConnCB)
#else
int				CLIENT_Disconnect(PCONNCB pConnCB)
#endif
{
	if ( pConnCB == NULL )
	{
		return EIMERR_SUCCESS;
	}

	if ( pConnCB->fLogin )
	{
		CLIENT_Logout(pConnCB, 3, 0);
	}

	CLOSE_(pConnCB->nSocket);
	return EIMERR_SUCCESS;
}

#ifdef WIN32
IM_API( int )  CLIENT_MsgReadSyncReq(PCONNCB pConnCB,MSG_READ_SYNC *pData)
#else
int   CLIENT_MsgReadSyncReq(PCONNCB pConnCB,MSG_READ_SYNC *pData)
#endif
{

	MSG_READ_SYNC *pBody ;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN+500];
	int nMsgLen = sizeof(MSG_READ_SYNC)-(MAX_MSGREAD_SYNC_SESSION_NUM - pData->wNum)*sizeof(session_data)
		+ MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pData);
	memset(aszPacket, 0, sizeof(aszPacket));

	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket );
	pBody = (MSG_READ_SYNC*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_READMSGSYNCREQ;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	memcpy(pBody,pData,sizeof(MSG_READ_SYNC));

	hton_term_MSG_READ_SYNC(pBody);
	hton_term_head(pHead);

	nRet =EncryptSendHttpData(CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
	return ENC_SEND_RET_(nRet);
}

#ifdef WIN32
IM_API( int )  CLIENT_RobotInfoSync(PCONNCB pConnCB,ROBOTSYNCREQ *pData)
#else
int   CLIENT_RobotInfoSync(PCONNCB pConnCB,ROBOTSYNCREQ *pData)
#endif
{
	ROBOTSYNCREQ *pBody ;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	int nMsgLen = sizeof(ROBOTSYNCREQ) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
	CHECK_NULL_RET_(pData);
	memset(aszPacket, 0, sizeof(aszPacket));

	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
	pBody = (ROBOTSYNCREQ*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_ROBOTSYNCREQ;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	memcpy(pBody,pData,sizeof(ROBOTSYNCREQ));

	hton_term_ROBOTSYNCREQ(pBody);
	hton_term_head(pHead);

	nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
	return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_SendContactsUpdateAck(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType)
#else
int CLIENT_SendContactsUpdateAck(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType)
#endif
{
    CONTACTSUPDATENOTICEACK *pAck;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGNOTICEACK) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(&aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pAck = (CONTACTSUPDATENOTICEACK*)((char*)pHead + MSGHEAD_LEN);
    pHead->wCmdID  = CMD_CONTACTSCLEANNOTICERSP;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = sizeof(CONTACTSUPDATENOTICEACK) + MSGHEAD_LEN;

    pAck->dwUserID = pConnCB->dwUserID;
	pAck->dwTimeStampe	= dwTimeStamp;
	pAck->cTerminalType	= cTerminalType;
    hton_term_head(pHead);
    hton_term_CONTACTSUPDATENOTICEACK(pAck);

    nRet = EncryptSendHttpData(CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,(char*)pHead,nMsgLen);
    return ENC_SEND_RET_( nRet );
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//added by rock
#ifdef WIN32
IM_API( int )  CLIENT_SendSMSCancel(PCONNCB pConnCB, MSGCancel* pMsgCancel)
#else
IM_API int  CLIENT_SendSMSCancel(PCONNCB pConnCB, MSGCancel* pMsgCancel)
#endif
{
	MSGCancel *pSMSTmp = NULL;

    int nRet = 0;
    int nCmdLen = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGCancel) + MSGHEAD_LEN; 
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pSMSTmp = (MSGCancel*)((char*)pHead + MSGHEAD_LEN);
	memcpy(pSMSTmp, pMsgCancel, sizeof(MSGCancel));

    pHead->wCmdID  = CMD_MSGCANCEL;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pSMSTmp->dwUserID = pConnCB->dwUserID;
	
    hton_term_head(pHead);
 	hton_term_sendCancelSms(pSMSTmp);

    nRet = EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ, pConnCB->nSocket, (char*)pHead, nMsgLen);

#ifdef _LOG_FLAG_
	if(pConnCB != NULL)
	{
		pConnCB->pLog->PrintLog(DEBUG_LEVEL, "CLIENT_SendSMSEx cmd=CMD_MSGCANCEL, seq= %d, length=%d [%s]\n", g_nSeq - 1, nMsgLen, (nRet >= 0)? "Succeed": "Failed");		
	}
#endif

    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_SendCancelNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT64 nCancelMsgID, UINT32 dwNetID)
#else
IM_API int  CLIENT_SendCancelNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT64 nCancelMsgID, UINT32 dwNetID)
#endif
{
	MSGCancelNoticeAck *pAck;

    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGCancelNoticeAck) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
    memset(&aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket);
    pAck = (MSGCancelNoticeAck*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID  = CMD_MSGCANCELNOTICEACK;
    pHead->dwSeq   = g_nSeq++;
    pHead->wMsgLen = sizeof(MSGCancelNoticeAck) + MSGHEAD_LEN;

    pAck->dwUserID = pConnCB->dwUserID;
    pAck->dwMsgID  = dwMsgID;
	pAck->dwCancelMsgID = nCancelMsgID;
	pAck->dwNetID  = dwNetID;
    
	hton_term_head(pHead);
    hton_term_CancelNoticeAck(pAck);

    nRet = EncryptSendHttpData(CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}


#ifdef WIN32
IM_API( int )  CLIENT_SendCancelToGroup(PCONNCB pConnCB, char* pszGroupID, int nType, UINT64 nMsgID, int nSendTime, int nGroupType, UINT64 nCancelMsgID)
#else
int  CLIENT_SendCancelToGroup(PCONNCB pConnCB, char* pszGroupID, int nType, UINT64 nMsgID, int nSendTime, int nGroupType, UINT64 nCancelMsgID)
#endif
{
    MSGCancel *pSMS;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(MSGCancel) + MSGHEAD_LEN;
 
	CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));
 
    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pSMS = (MSGCancel*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_MSGCANCEL;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pSMS->dwUserID = pConnCB->dwUserID;
    memcpy(pSMS->aszGroupID, pszGroupID, sizeof(pSMS->aszGroupID)-1);
    pSMS->cType = nType;
    pSMS->dwMsgID = nMsgID;
	pSMS->cIsGroup = nGroupType;
	pSMS->dwCancelMsgID = nCancelMsgID;
    pSMS->nSendTime = nSendTime;

    hton_term_head(pHead);
    hton_term_sendCancelSms(pSMS);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket,  (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_VirtualGroupInfoReq(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType)
#else
int CLIENT_VirtualGroupInfoReq(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType)
#endif
{
	VIRTUAL_GROUP_INFO_REQ *pVirReq = NULL;

	int nCmdLen = 0;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	int nMsgLen = sizeof(VIRTUAL_GROUP_INFO_REQ) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
	memset(aszPacket, 0, sizeof(aszPacket));
	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
	pVirReq = (VIRTUAL_GROUP_INFO_REQ*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_VIRTUAL_GROUP_REQ;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	pVirReq->dwUserID = pConnCB->dwUserID;
	pVirReq->dwCompID = pConnCB->dwCompID;
	pVirReq->cTerminalType  = cTerminalType;
	pVirReq->dwTimestamp = dwTimeStamp;

	hton_term_head(pHead);
	hton_term_virgroup_info_req(pVirReq);

	nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
	return ENC_SEND_RET_( nRet );
}
#ifdef WIN32
IM_API( int )  CLIENT_FavoriteSync(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType)
#else
int CLIENT_FavoriteSync(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType)
#endif
{
	FAVORITE_SYNC_REQ *pReq = NULL;

	int nCmdLen = 0;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	int nMsgLen = sizeof(FAVORITE_SYNC_REQ) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
	memset(aszPacket, 0, sizeof(aszPacket));
	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
	pReq = (FAVORITE_SYNC_REQ*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_FAVORITE_SYNC_REQ;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	pReq->dwUserID = pConnCB->dwUserID;
	pReq->dwCompID = pConnCB->dwCompID;
	pReq->cTerminal  = cTerminalType;
	pReq->dwTimestamps = dwTimeStamp;

	hton_term_head(pHead);
	hton_term_favorite_sync_req(pReq);

	nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
	return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_FavoriteModifyReq(PCONNCB pConnCB,FAVORITE_MODIFY_REQ *pFavorite)
#else
int CLIENT_FavoriteModifyReq(PCONNCB pConnCB,FAVORITE_MODIFY_REQ *pFavorite)
#endif
{
	FAVORITE_MODIFY_REQ *pReq = NULL;

	int nCmdLen = 0;
	int nRet = 0;
	char aszPacket[PACKET_MAXLEN];
	int nMsgLen = sizeof(FAVORITE_MODIFY_REQ) + MSGHEAD_LEN;

	CHECK_PCB_RET_(pConnCB);
	memset(aszPacket, 0, sizeof(aszPacket));
	TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
	pReq = (FAVORITE_MODIFY_REQ*)((char*)pHead + MSGHEAD_LEN);

	pHead->wCmdID = CMD_FAVORITE_MODIFY_REQ;
	pHead->dwSeq = g_nSeq++;
	pHead->wMsgLen = nMsgLen;

	memcpy(pReq,pFavorite,sizeof(FAVORITE_MODIFY_REQ));
	pReq->dwUserID = pConnCB->dwUserID;

	hton_term_head(pHead);
	hton_term_favorite_modify_req(pReq);

	nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
	return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_GetDeptShowConfig(PCONNCB pConnCB, int timestamp, TERMINAL_TYPE cType)
#else
int  CLIENT_GetDeptShowConfig(PCONNCB pConnCB, int timestamp, TERMINAL_TYPE cType)
#endif
{
    GETDEPTSHOWCONFIGREQ *pReq;

    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(GETDEPTSHOWCONFIGREQ) + MSGHEAD_LEN;
 
    CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pReq = (GETDEPTSHOWCONFIGREQ*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_DEPTSHOWCONFIG_REQ;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pReq->dwCompID   = htonl(pConnCB->dwCompID);
    pReq->dwUserID   = htonl(pConnCB->dwUserID);
    pReq->cTerminal  = cType;
    pReq->dwTimestamps = htonl(timestamp);

    hton_term_head(pHead);

    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}

#ifdef WIN32
IM_API( int )  CLIENT_ParseDeptShowConfig(const char* pszDeptInfo, UINT32* pu32StartPos, SINGLEDEPTSHOWLEVEL* psDeptShowLevel)
#else
int   CLIENT_ParseDeptShowConfig(const char* pszDeptInfo, UINT32* pu32StartPos, SINGLEDEPTSHOWLEVEL* psDeptShowLevel)
#endif
{
    UINT32 u32Pos;                  // Temp pos for parse
    UINT32 u32DeptInfoPackSize;     // 2.2:4    DEPTINFO    ANS..1904   LLLLVAR

    // Check parameter
    if( pszDeptInfo == NULL || pu32StartPos == NULL || psDeptShowLevel == NULL )
    {
        //ASSERT_(0);
        return EIMERR_INVALID_PARAMTER;     // Parameter error
    }

    // Check package size
    u32DeptInfoPackSize = ParseLength( pszDeptInfo, LLLLVAR_BYTES );
    if( *pu32StartPos >= u32DeptInfoPackSize )
        return EIMERR_PARSE_FINISHED;           // Parse finished
    
    // Check position
    if( *pu32StartPos == 0 )            // Is first time parse
        *pu32StartPos += LLLLVAR_BYTES; // Skip the length data of DEPTINFO 
    
    // Prepare 
    u32Pos = *pu32StartPos;
    memset( psDeptShowLevel, 0, sizeof(SINGLEDEPTSHOWLEVEL));

    // Field2. DEPTID   B32     BINARY  M+
    psDeptShowLevel->dwDeptID = MAKE_UINT32_EX_( pszDeptInfo );
    u32Pos += UINT32_BYTES;
    // Field. cShowLevel
    psDeptShowLevel->cShowLevel = ParseLength( &pszDeptInfo[u32Pos], LVAR_BYTES );
    u32Pos += LVAR_BYTES;

    psDeptShowLevel->dwDeptID = ntohl(psDeptShowLevel->dwDeptID);

    *pu32StartPos = u32Pos;         // Update position for next parse
    return EIMERR_SUCCESS;          // Parse succeeded
}

#ifdef WIN32
IM_API( int )  CLIENT_GetMeetingAccountInfo(PCONNCB pConnCB, TERMINAL_TYPE cType)
#else
int   CLIENT_GetMeetingAccountInfo(PCONNCB pConnCB, TERMINAL_TYPE cType)
#endif
{
    S_GetMeetingAccountInfo *pReq = NULL;
    int nCmdLen = 0;
    int nRet = 0;
    char aszPacket[PACKET_MAXLEN];
    int nMsgLen = sizeof(S_GetMeetingAccountInfo) + MSGHEAD_LEN;

    CHECK_PCB_RET_(pConnCB);
    memset(aszPacket, 0, sizeof(aszPacket));

    TERM_CMD_HEAD *pHead = (TERM_CMD_HEAD*)(aszPacket + nCmdLen);
    pReq = (S_GetMeetingAccountInfo*)((char*)pHead + MSGHEAD_LEN);

    pHead->wCmdID = CMD_GET_MEETING_ACCOUNT_INFO;
    pHead->dwSeq = g_nSeq++;
    pHead->wMsgLen = nMsgLen;

    pReq->dwCompID   = htonl(pConnCB->dwCompID);
    pReq->dwUserID   = htonl(pConnCB->dwUserID);
    pReq->cTerminal  = cType;
    hton_term_head(pHead);
    nRet =EncryptSendHttpData( CMD_ENCRYPT_SEND_DATA_REQ,pConnCB->nSocket, (char*)pHead, nMsgLen);
    return ENC_SEND_RET_( nRet );
}