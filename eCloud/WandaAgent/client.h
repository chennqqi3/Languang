/*****************************************************************
 *
 * Client agent for ecloud IM
 *
 *****************************************************************/

#ifndef __CLIENT_H__
#define __CLIENT_H__

#include "protocol.h"
#include "queue.h"
#include "TRSA.h"
#include "AES.h"
 

#ifdef _LOG_FLAG_
#include "SysLog.h"
#endif

#define MIN_(a, b) ( (a) < (b) ? (a) : (b) )

#define MAKE_UINT16_(a, b)      ((UINT16)(((UINT8)(((UINT32)(a)) & 0xff)) | ((UINT16)((UINT8)(((UINT32)(b)) & 0xff))) << 8))
#define MAKE_UINT32_(a, b)      ((UINT32)(((UINT16)(((UINT32)(a)) & 0xffff)) | ((UINT32)((UINT16)(((UINT32)(b)) & 0xffff))) << 16))


#ifdef __cplusplus
extern "C"
{
#endif

typedef struct _Message
{
    UINT16     wCmdID;
    char       aszData[PACKET_MAXLEN+1];
} MESSAGE;
    

struct _ConnCB
{
   /* char aszAccessIP[65];
    int  nAccessPort;

    char aszIP[65];
    int  nPort;

    // PC
    int  nUpdateFlag1;       // 是否强制升级标志
    char aszVerInfo1[20];    // 版本信息
    char aszURL1[100];       // 下载URL 

    // Andriod
    int  nUpdateFlag2;       // 是否强制升级标志
    char aszVerInfo2[20];    // 版本信息
    char aszURL2[100];       // 下载URL 

    // IOS
    int  nUpdateFlag3;       // 是否强制升级标志
    char aszVerInfo3[20];    // 版本信息
    char aszURL3[100];       // 下载URL */

    SOCKET  nSocket;
    char cAccessMode;

    // private
    int  nRunFlag;
    UINT32 dwSessionID;
    UINT32 dwUserID;
    UINT32 dwCompID;

    mqueue *pQueueMsg;

    BOOL	fConnect;	// Connect flag
    BOOL	fLogin;		// Login flag
    BOOL	fKick;		// ReLogin Kick
	BOOL	fForbidden;	// Forbidden

	//Guojian Add 2015-03-28
	pthread_mutex_t mConnectlock;
	//end Guojian Add 2015-03-28

	LOGINACCESSACK tAccessAck;
	INT32 dwAliveTime;//心跳间隔 单位秒


#ifdef _LOG_FLAG_
	SysLog *pLog;
#endif
};

typedef struct _ConnCB CONNCB;
typedef struct _ConnCB *PCONNCB;

/*
 * Get CMD response 
 *
 * pszResponse: The CMD response, reference: #MESSAGE
 *  the wCmdID of #MESSAGE, reference: #TERM_CMD_TYPE 
 *    - CMD_LOGINACK:           #LOGINACK           登录应答
 *    - CMD_LOGOUTACK:          #LOGOUTACK          退出应答
 *    - CMD_MODIINFOACK:        #MODIINFOACK        修改用户信息应答    
 *    - CMD_GETCOMPINFOACK:     #GETCOMPINFOACK     获取企业信息应答
 *    - CMD_GETDEPTLISTACK:     #GETDEPTLISTACK     获取部门应答
 *    - CMD_GETUSERLISTACK:     #GETUSERLISTACK     获取本企业员工列表应答
 *    - CMD_GETUSERDEPTACK:     #GETUSERDEPTACK     获取员工与部门关系应答
 *    - CMD_GETUSERSTATELISTACK:#GETUSERSTATELISTACK获取所有员工状态信息应答
 *    - CMD_GETEMPLOYEEINFOACK  #GETEMPLOYEEACK     获取员工详细信息应答
 *    - CMD_ALIVEACK:           #ALIVEACK           心跳应答
 *
 *    - CMD_CREATEGROUPACK:     #CREATEGROUPACK     创建聊天群组应答
 *    - CMD_MODIGROUPACK:       #MODIGROUPACK       修改群组信息应答
 *    - CMD_GETGROUPACK:        #GETGROUPACK        获取群组信息应答
 *    - CMD_MODIMEMBERACK:      #MODIMEMBERACK      修改群组成员应答
 *    - CMD_SENDMSGACK:         #SENDMSGACK         发送消息应答
 *    - CMD_SENDBROADCASTACK:   #SENDBROADCASTACK   广播应答
 *    - CMD_MSGREADACK:         #MSGREADACK         消息已读应答
 *
 *    - CMD_NOTICESTATE:        #USERSTATUSNOTIC    本企业员工在线状态变化通知
 *    - CMD_NOTICECOMPINFO:     #NOTICECOMPINFO     企业信息更新通知
 *    - CMD_NOTICEDEPTLIST:     #NOTICEDEPTLIST     部门信息更新通知
 *    - CMD_MODIINFONOTICE:     #MODIINFONOTICE     用户资料修改通知
 *    - CMD_CREATEGROUPNOTICE:  #CREATEGROUPNOTICE  群组建立通知 
 *    - CMD_MODIGROUPNOTICE:    #MODIGROUPNOTICE    群组修改通知
 *    - CMD_MODIMEMBERNOTICE:   #MODIMEMBERNOTICE   群组成员变化通知
 *    - CMD_MSGNOTICE:          #MSGNOTICE          消息通知
 *    - CMD_BROADCASTNOTICE:    #BROADCASTNOTICE    广播通知
 *    - CMD_MSGREADNOTICE:      #MSGREADNOTICE      消息已读通知
 *    - CMD_MSGNOTICECONFIRM:   #MSGNOTICECONFIRM   消息通知已接收确认
 *
 * return 1: get a response; 0: no response; -1: parameter error; -2: no connect
 */

/*
 * client从消息队列获取消息
 * pMessage：输出参数，存储获取到的消息
 * return: 0 success, others
 */
#ifdef WIN32
IM_API( int ) CLIENT_GetMessage(PCONNCB pConnCB, MESSAGE *pMessage);
#else
IM_API int  CLIENT_GetMessage(PCONNCB pConnCB, MESSAGE *pMessage);
#endif

/*
 * Initialization client agent
 * 
 * cMode: Access methods 1: CMNET 2: CMWAP
 *
 * return PCONNCB
 */
typedef enum{ CMNET = 1, CMWAP} QY_ACCESS_MODE;
#ifdef WIN32
IM_API( PCONNCB) CLIENT_Init(QY_ACCESS_MODE cMode, const char* pszLogFile);
#else
	IM_API PCONNCB CLIENT_Init(QY_ACCESS_MODE cMode, const char* pszLogFile);
#endif

/*
 * 设置心跳时间间隔
 * iAliveTime :单位秒
 * return: 0 success
 */
#ifdef WIN32
IM_API (int) CLIENT_SetAliveTime(PCONNCB pConnCB,INT32 iAliveTime);
#else
IM_API int CLIENT_SetAliveTime(PCONNCB pConnCB,INT32 iAliveTime);
#endif


/*
 * 连接到接入管理，然后连接到接入服务
 *
 * ip:   Server IP
 * port: Server port
 * pAccount account
 * type 0没有携带；1携带了上次失败的接入服务地址和端口
 * pVersion 版本号
 * 
 * return 0: success,其他失败
 */
#ifdef WIN32
IM_API( int )	CLIENT_Connect(PCONNCB pConnCB, char *ip, unsigned short port,char* pAccount,char type,char* pVersion,TERMINAL_TYPE  osType,int connectTimeout=3,int RecvTimeOut=3,char* pFailService=NULL, unsigned short failPort=0);
#else
IM_API int		CLIENT_Connect(PCONNCB pConnCB, char *ip, unsigned short port,char* pAccount,char type,char* pVersion,TERMINAL_TYPE  osType,int connectTimeout,int RecvTimeOut,char* pFailService, unsigned short failPort);
#endif

/*
 * 直接连接到 接入服务
 *
 * ip:   Server IP
 * port: Server port
 * 
 * return 0: success; 其他失败
 */
#ifdef WIN32
IM_API( int )	CLIENT_ConnectService(PCONNCB pConnCB, char *ip, unsigned short port,int connectTimeout );
#else
IM_API int		CLIENT_ConnectService(PCONNCB pConnCB, char *ip, unsigned short port,int connectTimeout );
#endif

/*
 * Client login
 *
 * pszUserName: user name(email)
 * pszPassword: user password
 * cType:       login type, reference #TERMINAL_TYPE
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 */
#ifdef WIN32
IM_API( int ) CLIENT_Login(PCONNCB pConnCB, char* pszUserName, char* pszPassword, TERMINAL_TYPE cType,char* pszVersion,char* pszMacAddr, char* pszDeviceToken);
#else
IM_API int  CLIENT_Login(PCONNCB pConnCB, char* pszUserName, char* pszPassword, TERMINAL_TYPE cType,char* pszVersion,char* pszMacAddr, char* pszDeviceToken);
#endif

/*
 * Send alive
 *
 * pszUserName: user name(eamil)
 *
 * return 0: success; -1 
 */
//IM_API int CLIENT_SendAlive(PCONNCB pConnCB, int nUserID);

/*
 * Client logout
 *
 * nStatus: 0: 离线 1: 上线 2:离开 3:退出
 * return 0: success; -1 failure
 */
#ifdef WIN32
IM_API( int ) CLIENT_Logout(PCONNCB pConnCB, int nStatus, unsigned char cManual);
#else
IM_API int  CLIENT_Logout(PCONNCB pConnCB, int nStatus, unsigned char cManual);
#endif

/*
 * Get a employee information
 *
 * nUserID: the user id
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_GetEmployee(PCONNCB pConnCB, int nUserID, int nType);
#else
IM_API int  CLIENT_GetEmployee(PCONNCB pConnCB, int nUserID, int nType);
#endif

/*
 * 修改单项用户信息
 * Modify user information
 *
 * nType: modify type, 0: 性别 1: 籍贯 2: 出生日期 3: 住址 4:办公电话号码 5: 手机号码 6: 密码
 * nLen:  the length of modify info(szInfo)
 * szInfo: the data of modify 
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int )  CLIENT_ModiInfo(PCONNCB pConnCB, int nType, int nLen, char *szInfo);
#else
IM_API int   CLIENT_ModiInfo(PCONNCB pConnCB, int nType, int nLen, char *szInfo);
#endif

/*
 * 信息修改通知最近10个联系人
 * Modify user information 
 *
 * nType: modify type
 * nLen:  the length of modify info(szInfo)
 * szInfo: the data of modify 
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int )  CLIENT_ModiSelfNotice(PCONNCB pConnCB, RESETSELFINFO *pNotice);
#else
IM_API int   CLIENT_ModiSelfNotice(PCONNCB pConnCB, RESETSELFINFO *pNotice);
#endif

/*
 * 修改多项用户信息
 * Modify employee information 
 *
 * pEmpyInfo: the modify information of employee, #EMPLOYEE
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_ModiEmpyInfo(PCONNCB pConnCB, EMPLOYEE *pEmpyInfo);
#else
IM_API int  CLIENT_ModiEmpyInfo(PCONNCB pConnCB, EMPLOYEE *pEmpyInfo);
#endif

/*
 * 获取企业信息
 * 
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_GetCompInfo(PCONNCB pConnCB);
#else
IM_API int  CLIENT_GetCompInfo(PCONNCB pConnCB);
#endif

/* 
 * 获取企业组织构架信息
 *
 * nLastUpdateTime: the last update time
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int )  CLIENT_GetDeptInfo(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#else
IM_API int CLIENT_GetDeptInfo(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#endif


/*
 * 获取员工列表下载方式
 *
 * nLastUpdateTime: the last update time
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_GETDATALISTTYPE(PCONNCB pConnCB, GETDATALISTTYPEPARAMETET* pGetDataTypePara);
#else
IM_API int  CLIENT_GETDATALISTTYPE(PCONNCB pConnCB, GETDATALISTTYPEPARAMETET* pGetDataTypePara);
#endif


/*
 * 获取员工列表
 *
 * nLastUpdateTime: the last update time
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_GetUserList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#else
IM_API int  CLIENT_GetUserList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#endif

/*
 * 获取员工部门信息
 *
 * nLastUpdateTime: the last update time
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int )  CLIENT_GetUserDept(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#else
IM_API int   CLIENT_GetUserDept(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#endif

/*
 * 获取企业员工状态信息列表
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_GetUserStateList(PCONNCB pConnCB);
#else
IM_API int  CLIENT_GetUserStateList(PCONNCB pConnCB);
#endif

 /* 
 * 创建群组
 *
 * Create group
 *
 * pszGoupID: the group id
 * szGroupName: group name
 * nGroupNameLen: the length of group name
 * szUserList:  user id list
 * num:         user count
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 *  -4: the number of members of the group over the limit
 */
#ifdef WIN32
IM_API( int ) CLIENT_CreateGroup(PCONNCB pConnCB, char *pszGroupID, char *pszGroupName, int nGroupNameLen, char *pszUsers, int num, int nGroupTime);
#else
IM_API int  CLIENT_CreateGroup(PCONNCB pConnCB, char *pszGroupID, char *pszGroupName, int nGroupNameLen, char *pszUsers, int num, int nGroupTime);
#endif

/*
 * 修改群组信息
 * Modify group information
 *
 * pszGroup: The group id
 * szNew:  The new value
 * nType:  type, 0: the group name; 1: the group note
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_ModiGroup(PCONNCB pConnCB, char *pszGroupID, char* pszNew, int nType, int nGroupTime);
#else
IM_API int  CLIENT_ModiGroup(PCONNCB pConnCB, char *pszGroupID, char* pszNew, int nType, int nGroupTime);
#endif

/*
 * 退出群组
 * Quit group
 * pszGroup: The group id
 * szNew:  The new value
 * nType:  type, 0: the group name; 1: the group note
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_QuitGroup(PCONNCB pConnCB, char *pszGroupID);
#else
IM_API int  CLIENT_QuitGroup(PCONNCB pConnCB, char *pszGroupID);
#endif

/*
 * Get group info, member id list
 *
 * pszGroupID: the group id
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_GetGroupInfo(PCONNCB pConnCB, char *pszGroupID);
#else
IM_API int  CLIENT_GetGroupInfo(PCONNCB pConnCB, char *pszGroupID);
#endif

/*
 * 发送单人消息
 * 发送消息（单人和群组均可）
 * 发送信息通知应答
 *
 * nRecverID: the receiver ID
 * nType:     the message type, 0: 文本 1: 图片 2: 语音 3: 视频 4:其它
 * szMsg:     the message data
 * len:       the length of message data
 * nMsgID:    the message ID
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_SendSMS(PCONNCB pConnCB, int nRecverID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nReadFlag, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply, UINT64 nSrcMsgID);

IM_API( int ) CLIENT_SendSMSEx(PCONNCB pConnCB, SENDMSG *pSMS);

IM_API( int ) CLIENT_SendMsgNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT32 dwNetID);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//added by rock
IM_API( int ) CLIENT_SendSMSCancel(PCONNCB pConnCB, MSGCancel* pMsgCancel);

IM_API( int ) CLIENT_SendCancelNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT64 nCancelMsgID, UINT32 dwNetID);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#else
IM_API int  CLIENT_SendSMS(PCONNCB pConnCB, int nRecverID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nReadFlag, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply, UINT64 nSrcMsgID);

IM_API int  CLIENT_SendSMSEx(PCONNCB pConnCB, SENDMSG *pSMS);

IM_API int  CLIENT_SendMsgNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT32 dwNetID);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//added by rock
IM_API int  CLIENT_SendSMSCancel(PCONNCB pConnCB, MSGCancel* pMsgCancel);

IM_API int  CLIENT_SendCancelNoticeAck(PCONNCB pConnCB, UINT64 dwMsgID, UINT64 nCancelMsgID, UINT32 dwNetID);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif

/*
 * 发送消息回执
 *
 * nSenderID: the sender ID
 * nMsgID:    the messgae ID
 *
 * return:
 *   0: success
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_SendReadSMS(PCONNCB pConnCB, int nSenderID, UINT64 nMsgID, unsigned char nMsgType, int nReadTime);
#else
IM_API int  CLIENT_SendReadSMS(PCONNCB pConnCB, int nSenderID, UINT64 nMsgID, unsigned char nMsgType, int nReadTime);
#endif

/*
 * P2P握手确认
 *
 * nRecvID:  the receiver ID
 * nMsgID:   the messgae ID
 *
 * return:
 *   0: success
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_SendMSGNoticeConfirm(PCONNCB pConnCB, int nRecvID, char *pszMsg, int len, UINT64 nMsgID);
#else
IM_API int  CLIENT_SendMSGNoticeConfirm(PCONNCB pConnCB, int nRecvID, char *pszMsg, int len, UINT64 nMsgID);
#endif

/* 
 * 发送群组（讨论组和固定群）消息
 * Send message to group, group chat
 *
 * pszGroupID:  the group ID
 * nType:     the message type, 0: 文本 1: 图片 2: 语音 3: 视频 4:其它
 * szMsg:     The message data
 * len:       the length of message data
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */

#ifdef WIN32
IM_API( int )  CLIENT_SendtoGroup(PCONNCB pConnCB, char* pszGroupID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nGroupType, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply,unsigned char cRead);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//added by rock
IM_API( int )  CLIENT_SendCancelToGroup(PCONNCB pConnCB, char* pszGroupID, int nType, UINT64 nMsgID, int nSendTime, int nGroupType, UINT64 nCancelMsgID);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#else
int  CLIENT_SendtoGroup(PCONNCB pConnCB, char* pszGroupID, int nType, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nGroupType, unsigned char nMsgTotal, unsigned char nMsgSeq, unsigned char nAllReply,unsigned char cRead);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//added by rock
int  CLIENT_SendCancelToGroup(PCONNCB pConnCB, char* pszGroupID, int nType, UINT64 nMsgID, int nSendTime, int nGroupType, UINT64 nCancelMsgID);

#endif

/*
 * 修改（增加、删除）群组成员
 * add/del member to the group
 *
 * pszGroupID: the group id
 * pszUsers: the user array
 * num: the user count
 * nType: 0: add member 1: del memeber
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_ModiMember(PCONNCB pConnCB, char *pszGroupID, char *pszUsers, int num, int nType, int nGroupTime);
#else
IM_API int  CLIENT_ModiMember(PCONNCB pConnCB, char *pszGroupID, char *pszUsers, int num, int nType, int nGroupTime);
#endif

/*
 * 发送广播消息、发送广播协议类的消息
 * Send broadcast
 *
 * pRecverIDs: the array of DeptID or UserID, #Broadcast_Recver 
 * num:        the num of pRecverIDs
 * nType:      the message type
 * pszMsg:     the message
 * len:        the length of message
 * nMsgID:     the message id
 *
 * return:
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 *  -4: the message over length
 *  -5: the recver num over
 */
#ifdef WIN32
IM_API( int )  CLIENT_SendBroadCast(PCONNCB pConnCB, char *pRecverIDs, int num, char *pszTitle, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nMsgType, unsigned char nAllReply, UINT64 nSrcMsgID);
#else
IM_API int   CLIENT_SendBroadCast(PCONNCB pConnCB, char *pRecverIDs, int num, char *pszTitle, char *pszMsg, int len, UINT64 nMsgID, int nSendTime, int nMsgType, unsigned char nAllReply, UINT64 nSrcMsgID);
#endif

/*
 * 退出登录，释放资源
 * The release
 */
#ifdef WIN32
IM_API( void ) CLIENT_UnInit(PCONNCB pConnCB, unsigned char nManual);
#else
IM_API void  CLIENT_UnInit(PCONNCB pConnCB, unsigned char nManual);
#endif

/*
 * 获取固定群组信息
 *
 * Get regular group info 
 *
 * uTimestamp: the group info last update time
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 */
#ifdef WIN32
IM_API( int ) CLIENT_GetRegularGroupInfo(PCONNCB pConnCB, UINT32 uTimestamp);
#else
IM_API int  CLIENT_GetRegularGroupInfo(PCONNCB pConnCB, UINT32 uTimestamp);
#endif

/*
 * 与服务器校对时间
 * Send CheckTime
 *
 * return:
 */
#ifdef WIN32
IM_API( int )  CLIENT_CheckTime(PCONNCB pConnCB, int nSerial);
#else
IM_API int CLIENT_CheckTime(PCONNCB pConnCB, int nSerial);
#endif

/*
 * 获取离线消息
 * Send GetOffline
 * nTermType  用户类型 3pC ,ANDROID 1, ios 2
 * return:

 */
#ifdef WIN32
IM_API( int ) CLIENT_GetOffline(PCONNCB pConnCB, UINT8 nTermType);
#else
IM_API int  CLIENT_GetOffline(PCONNCB pConnCB, UINT8 nTermType);
#endif

/*
 * 群组消息屏蔽（接口未实现）
 * nTermType  用户类型 3pC ,ANDROID 1, ios 2
 * return:

 */
#ifdef WIN32
IM_API( int ) CLIENT_RefuseGroupMsg(PCONNCB pConnCB, char *pszGroupID, unsigned char cRefuseType);
#else
IM_API int  CLIENT_RefuseGroupMsg(PCONNCB pConnCB, char *pszGroupID, unsigned char cRefuseType);
#endif

/*
 * 消息序列ID生成
 * nTermType  用户类型 3 pC ,ANDROID 1, ios 2
   uTime    从2013.6.31日起到现在时间的秒数
 * return:

 */
#ifdef WIN32
IM_API (UINT64) CLIENT_PackMsgId(UINT32 uUserId,UINT8 nTermType, UINT32 uTime);
#else
IM_API UINT64 CLIENT_PackMsgId(UINT32 uUserId,UINT8 nTermType, UINT32 uTime);
#endif

/*
 * 消息序列ID转换为主机序，可打印出消息ID信息
 * nTermType  用户类型 3 pC ,ANDROID 1, ios 2
   uTime    从2013.6.31日起到现在时间的秒数
 * return:

 */
#ifdef WIN32
IM_API( UINT64 )CLIENT_UnpackMsgId(UINT64 uMsgId);
#else
IM_API UINT64 CLIENT_UnpackMsgId(UINT64 uMsgId);
#endif

 /* 
 * 创建日程信息
 * Create schedule
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 *  -4: the number of members of the group over the limit
 */
#ifdef WIN32
IM_API( int ) CLIENT_CreateSchedule(PCONNCB pConnCB, CREATESCHEDULE *pCreate);
#else
IM_API int  CLIENT_CreateSchedule(PCONNCB pConnCB, CREATESCHEDULE *pCreate);
#endif


 /* 
 * 创建日程信息通知应答
 * Create schedule
 *
 * return: 
 *   0: success;
 */
#ifdef WIN32
IM_API( int )  CLIENT_CreateScheduleNotieAck(PCONNCB pConnCB, char *pScheduleID);
#else
int   CLIENT_CreateScheduleNotieAck(PCONNCB pConnCB, char *pScheduleID);
#endif

 /* 
 * 删除日程信息
 * delete schedule
 *
 * return: 
 *   0: success;
 *  -1: the connect error
 *  -2: the parameter error
 *  -3: No login
 *  -4: the number of members of the group over the limit
 */
#ifdef WIN32
IM_API( int ) CLIENT_DeleteSchedule(PCONNCB pConnCB, DELETESCHEDULE *pDelete);
#else
IM_API int  CLIENT_DeleteSchedule(PCONNCB pConnCB, DELETESCHEDULE *pDelete);
#endif

/*
 *	ios群组消息推送开关（群组消息免打扰）
 *
 *  return：
 *	0： success
 *	-1：the connect error
 *	-2:  the parameter error
 *   -3:  No login
 */
#ifdef WIN32
IM_API( int )  CLIENT_GroupPushFlag(PCONNCB pConnCB, char* aszGroupid, int Flag);
#else
int  CLIENT_GroupPushFlag(PCONNCB pConnCB, char* aszGroupid, int Flag);
#endif

/*client上行至公众平台的消息请求
*
*return :
*     0: success;
*    -1: the connect error
*    -2: the parameter error
*    -3: No login
*/
#ifdef WIN32
IM_API( int )  CLIENT_ecwx_up(PCONNCB pConnCB, char* fromUser,int toUser, char* msgType, char* text, int sequence, int cmd);
#else
IM_API int   CLIENT_ecwx_up(PCONNCB pConnCB, char* fromUser,int toUser, char* msgType, char* text, int sequence, int cmd);
#endif

/*client发送获取级别、业务、地域信息
*
*return :
*     0: success;
*    -1: the connect error
*    -2: the parameter error
*    -3: No login
*/
#ifdef WIN32
IM_API( int )  CLIENT_get_userRPA(PCONNCB pConnCB, UINT16 nCmdID, int nLastUpdateTime, TERMINAL_TYPE cType);
#else
IM_API int   CLIENT_get_userRPA(PCONNCB pConnCB, UINT16 nCmdID, int nLastUpdateTime, TERMINAL_TYPE cType);
#endif

//////////////////////BIG DATA//////////////////////////////
/*client解析部门信息列表
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseDeptInfo(const char* pszDeptInfo, UINT32* pu32StartPos, DEPTINFO* psDeptInfo);
#else
IM_API int  CLIENT_ParseDeptInfo(const char* pszDeptInfo, UINT32* pu32StartPos, DEPTINFO* psDeptInfo);
#endif

/*client解析用户部门信息列表
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseDeptUserInfo(const char* pszDeptUserInfo, UINT32* pu32StartPos, USERDEPT* psUserDept);
#else
IM_API int  CLIENT_ParseDeptUserInfo(const char* pszDeptUserInfo, UINT32* pu32StartPos, USERDEPT* psUserDept);
#endif

/*client解析用户信息列表
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseUserInfo(const char* pszUserInfo, UINT32* pu32StartPos, USERINFO* psUserInfo);
#else
IM_API int  CLIENT_ParseUserInfo(const char* pszUserInfo, UINT32* pu32StartPos, USERINFO* psUserInfo);
#endif

/*client移动端解析用户简要信息列表
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseUserListMobile(const char* pszUserListMobile, UINT32* pu32StartPos, UserListMobile* psUserListMobile);
#else
IM_API int  CLIENT_ParseUserListMobile(const char* pszUserListMobile, UINT32* pu32StartPos, UserListMobile* psUserListMobile);
#endif

#ifdef WIN32
IM_API( int ) CLIENT_ParseUserStatusSetNotice(const char* pszUserStatusSetNotice, UINT32* pu32StartPos, USERSTATUSNOTICE* psUserStatusNotice);
#else
IM_API int  CLIENT_ParseUserStatusSetNotice(const char* pszUserStatusSetNotice, UINT32* pu32StartPos, USERSTATUSNOTICE* psUserStatusNotice);
#endif

/*client解析获取用户级别(员工所属)信息
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserRank(const char* pszUserRank, UINT32* pu32StartPos, USERRANK* psUserRank);
#else
int   CLIENT_ParseUserRank(const char* pszUserRank, UINT32* pu32StartPos, USERRANK* psUserRank);
#endif

/*client解析获取用户业务(员工所属)信息
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserPro(const char* pszUserPro, UINT32* pu32StartPos, USERPROFESSIONAL* psUserPro);
#else
int   CLIENT_ParseUserPro(const char* pszUserPro, UINT32* pu32StartPos, USERPROFESSIONAL* psUserPro);
#endif

/*client解析获取用户地域(员工所属)信息
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserArea(const char* pszUserArea, UINT32* pu32StartPos, USERAREA* psUserArea);
#else
int   CLIENT_ParseUserArea(const char* pszUserArea, UINT32* pu32StartPos, USERAREA* psUserArea);
#endif

/*client解析获取用户详细信息
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseEmploee(const char* pszEmploee, UINT32* pu32StartPos, EMPLOYEE* psUserInfo);
#else
IM_API int  CLIENT_ParseEmploee(const char* pszEmploee, UINT32* pu32StartPos, EMPLOYEE* psUserInfo);
#endif

/*client解析获取头像变化用户列表
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseUserHeadIconList(const char* pszUserList, UINT32* pu32StartPos, TUserHeadIconList* psUserList);
#else
IM_API int  CLIENT_ParseUserHeadIconList(const char* pszUserList, UINT32* pu32StartPos, TUserHeadIconList* psUserList);
#endif

/*client设置公钥路径
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SetRsaKeyPath(char* path);
#else
IM_API int   CLIENT_SetRsaKeyPath(char* path);
#endif

/*client发送ios客户端切换到后台请求，上报未读消息数
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )	CLIENT_IosBackGroundReq(PCONNCB pConnCB,UINT32 uPushMsgCount );
#else
IM_API int		CLIENT_IosBackGroundReq(PCONNCB pConnCB,UINT32 uPushMsgCount );
#endif

#ifdef WIN32
IM_API( int )  CLIENT_Log(PCONNCB pConnCB, int eLevel, char* pszFmt, ...);
#else
	int   CLIENT_Log(PCONNCB pConnCB, const char* pszFmt, ...);
#endif

/*client发送获取特殊人员列表请求
*
*return :
*     0: success;
 
*/
#ifdef WIN32
	IM_API( int )  CLIENT_GetSpecialList(PCONNCB pConnCB,GETSPECIALLIST *pData);
#else
	int   CLIENT_GetSpecialList(PCONNCB pConnCB,GETSPECIALLIST *pData);
#endif

/*client发送特殊人员名单修改通知应答
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ModiSpecialListNoticeAck(PCONNCB pConnCB,UINT64 dwMsgID);
#else
int   CLIENT_ModiSpecialListNoticeAck(PCONNCB pConnCB,UINT64 dwMsgID);
#endif 

/*client发送获取状态请求
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_GetUserStatusReq(PCONNCB pConnCB,TGetStatusReq *pStatusReq);
#else
int   CLIENT_GetUserStatusReq(PCONNCB pConnCB,TGetStatusReq *pStatusReq);
#endif 


/*client解析用户状态包
*
*return :
*     0: success; 其他参看错误码
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_user_status_Parse(BOOL  bNeedTurn, user_status* pData, TUserStatusList* pStatusList );
#else
int   CLIENT_user_status_Parse(BOOL  bNeedTurn, user_status* pData, TUserStatusList* pStatusList );
#endif


/*client发送临时订阅请求
*
*return :
*     0: success; 其他参看错误码
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendSubscribeReq(PCONNCB pConnCB,SUBSCRIBER_REQ *pData);
#else
int   CLIENT_SendSubscribeReq(PCONNCB pConnCB,SUBSCRIBER_REQ *pData);
#endif 

/*clientjson格式发送数据包体
*
*return :
*     0: success; 其他参看错误码
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendJSON(PCONNCB pConnCB,TJson *pData);
#else
int   CLIENT_SendJSON(PCONNCB pConnCB,TJson *pData);
#endif 

/*clientjson格式发送数据包体,加密
*
*return :
*     0: success; 其他参看错误码
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendJSON_Encrypt(PCONNCB pConnCB,TJson *pData);
#else
int   CLIENT_SendJSON_Encrypt(PCONNCB pConnCB,TJson *pData);
#endif 

/*
 * CLIENT_GetConnectRspInfo			获取接入信息
 * pConnCB:							用户连接结构体
 * pTaccessResponse:				输出参数，获取接入管理应答结构体
 * return:							0 成功

 */
#ifdef WIN32
IM_API( int )  CLIENT_GetConnectRspInfo(PCONNCB pConnCB,  LOGINACCESSACK *pTaccessResponse);
#else
int   CLIENT_GetConnectRspInfo(PCONNCB pConnCB, LOGINACCESSACK *pTaccessResponse);
#endif 

/*
 * CLIENT_RoamingDataModi			漫游数据（常用联系人、常用部门、关注人）同步
 * pConnCB:							用户连接结构体
 * pData:							漫游数据同步请求结构体
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_RoamingDataSync(PCONNCB pConnCB,ROAMDATASYNC *pData);
#else
int   CLIENT_RoamingDataSync(PCONNCB pConnCB,ROAMDATASYNC *pData);
#endif

/*
 * CLIENT_RoamingDataModi			漫游数据修改
 * pConnCB:							用户连接结构体
 * pData:							漫游数据增加、删减请求结构体
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
	IM_API( int )  CLIENT_RoamingDataModi(PCONNCB pConnCB,ROAMDATAMODI *pData);
#else
	int   CLIENT_RoamingDataModi(PCONNCB pConnCB,ROAMDATAMODI *pData);
#endif

/*
 * CLIENT_GetUserHeadIconList		请求获取头像变化的用户列表
 * pConnCB:							用户连接结构体
 * nLastUpdateTime:					客户端最新的头像时间
 * cType:							客户端类型 1 android, 2 ios, 3 pc
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_GetUserHeadIconList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#else
int  CLIENT_GetUserHeadIconList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#endif

/*
 * CLIENT_GetErrorCode				客户端错误码转换
 * eResult:							服务端返回的错误码
 * return:							客户端需要的错误码

 */
#ifdef WIN32
IM_API( int ) CLIENT_GetErrorCode(RESULT eResult);
#else
IM_API int CLIENT_GetErrorCode(RESULT eResult);
#endif
/*
 * CLIENT_Disconnect				客户端登出请求
 * pConnCB:							用户连接结构体
 * return:							0 成功

 */
#ifdef WIN32
IM_API( int )	CLIENT_Disconnect(PCONNCB pConnCB);
#else
int				CLIENT_Disconnect(PCONNCB pConnCB);
#endif

/*
 * CLIENT_MsgReadSyncReq			已读消息同步请求
 * pConnCB:							用户连接结构体
 * pData:							客户端已读消息同步请求结构体
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_MsgReadSyncReq(PCONNCB pConnCB,MSG_READ_SYNC *pData);
#else
int   CLIENT_MsgReadSyncReq(PCONNCB pConnCB,MSG_READ_SYNC *pData);
#endif

/*
 * CLIENT_RobotInfoSync				机器人信息同步请求
 * pConnCB:							用户连接结构体
 * pData:							机器人信息同步请求结构体
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_RobotInfoSync(PCONNCB pConnCB,ROBOTSYNCREQ *pData);
#else
int   CLIENT_RobotInfoSync(PCONNCB pConnCB,ROBOTSYNCREQ *pData);
#endif

/*
 * CLIENT_SendContactsUpdateAck		发送通讯录更新通知应答
 * pConnCB:							用户连接结构体
 * dwTimeStamp:						通讯录更新的时间戳
 * cTerminalType:					用户类型 1 android, 2 ios, 3 pc
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_SendContactsUpdateAck(PCONNCB pConnCB, UINT32 dwTimeStamp, UINT8 cTerminalType);
#else
int   CLIENT_SendContactsUpdateAck(PCONNCB pConnCB, UINT32 dwTimeStamp, UINT8 cTerminalType);
#endif

/*
 * CLIENT_VirtualGroupInfoReq		发送虚拟组信息请求
 * pConnCB:							用户连接结构体
 * dwTimeStamp:						虚拟组本地时间戳
 * cTerminalType:					用户类型 1 android, 2 ios, 3 pc
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_VirtualGroupInfoReq(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#else
int CLIENT_VirtualGroupInfoReq(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#endif
/*
 * CLIENT_FavoriteSync				收藏同步请求
 * pConnCB:							用户连接结构体
 * dwTimeStamp:						收藏本地时间戳
 * cTerminalType:					用户类型 1 android, 2 ios, 3 pc
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_FavoriteSync(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#else
int CLIENT_FavoriteSync(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#endif
/*
 * CLIENT_FavoriteModifyReq			收藏操作请求
 * pConnCB:							用户连接结构体
 * dwTimeStamp:						收藏操作结构体
 * return:							0 成功，其他 发送失败

 */
#ifdef WIN32
IM_API( int )  CLIENT_FavoriteModifyReq(PCONNCB pConnCB,FAVORITE_MODIFY_REQ *pFavorite);
#else
int CLIENT_FavoriteModifyReq(PCONNCB pConnCB,FAVORITE_MODIFY_REQ *pFavorite);
#endif

/**
 * [CLIENT_GetDeptShowConfig 获取部门显示配置信息]
 * @param  pConnCB   [用户连接结构体]
 * @param  timestamp [本地配置时间戳]
 * @param  cType     [用户登录类型]
 * @return           [0成功，其他 发送失败]
 */
#ifdef WIN32
IM_API( int )  CLIENT_GetDeptShowConfig(PCONNCB pConnCB, int timestamp, TERMINAL_TYPE cType);
#else
int  CLIENT_GetDeptShowConfig(PCONNCB pConnCB, int timestamp, TERMINAL_TYPE cType);
#endif

/**
 * [CLIENT_ParseDeptShowConfig 解析部门显示配置信息]
 * @param  pszDeptInfo     [部门显示配置应答字符串]
 * @param  pu32StartPos    [解析的开始位置]
 * @param  psDeptShowLevel [输出参数，部门对应的结构体]
 * @return                 [EIMERR_SUCCESS，EIMERR_PARSE_FINISHED，EIMERR_INVALID_PARAMTER]
 */
#ifdef WIN32
IM_API( int )  CLIENT_ParseDeptShowConfig(const char* pszDeptInfo, UINT32* pu32StartPos, SINGLEDEPTSHOWLEVEL* psDeptShowLevel);
#else
int   CLIENT_ParseDeptShowConfig(const char* pszDeptInfo, UINT32* pu32StartPos, SINGLEDEPTSHOWLEVEL* psDeptShowLevel);
#endif

#ifdef WIN32
IM_API( int )  CLIENT_GetMeetingAccountInfo(PCONNCB pConnCB, TERMINAL_TYPE cType);
#else
int   CLIENT_GetMeetingAccountInfo(PCONNCB pConnCB, TERMINAL_TYPE cType);
#endif

#ifdef __cplusplus
}
#endif

#endif
