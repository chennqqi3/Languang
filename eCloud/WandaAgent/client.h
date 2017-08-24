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
    int  nUpdateFlag1;       // �Ƿ�ǿ��������־
    char aszVerInfo1[20];    // �汾��Ϣ
    char aszURL1[100];       // ����URL 

    // Andriod
    int  nUpdateFlag2;       // �Ƿ�ǿ��������־
    char aszVerInfo2[20];    // �汾��Ϣ
    char aszURL2[100];       // ����URL 

    // IOS
    int  nUpdateFlag3;       // �Ƿ�ǿ��������־
    char aszVerInfo3[20];    // �汾��Ϣ
    char aszURL3[100];       // ����URL */

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
	INT32 dwAliveTime;//������� ��λ��


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
 *    - CMD_LOGINACK:           #LOGINACK           ��¼Ӧ��
 *    - CMD_LOGOUTACK:          #LOGOUTACK          �˳�Ӧ��
 *    - CMD_MODIINFOACK:        #MODIINFOACK        �޸��û���ϢӦ��    
 *    - CMD_GETCOMPINFOACK:     #GETCOMPINFOACK     ��ȡ��ҵ��ϢӦ��
 *    - CMD_GETDEPTLISTACK:     #GETDEPTLISTACK     ��ȡ����Ӧ��
 *    - CMD_GETUSERLISTACK:     #GETUSERLISTACK     ��ȡ����ҵԱ���б�Ӧ��
 *    - CMD_GETUSERDEPTACK:     #GETUSERDEPTACK     ��ȡԱ���벿�Ź�ϵӦ��
 *    - CMD_GETUSERSTATELISTACK:#GETUSERSTATELISTACK��ȡ����Ա��״̬��ϢӦ��
 *    - CMD_GETEMPLOYEEINFOACK  #GETEMPLOYEEACK     ��ȡԱ����ϸ��ϢӦ��
 *    - CMD_ALIVEACK:           #ALIVEACK           ����Ӧ��
 *
 *    - CMD_CREATEGROUPACK:     #CREATEGROUPACK     ��������Ⱥ��Ӧ��
 *    - CMD_MODIGROUPACK:       #MODIGROUPACK       �޸�Ⱥ����ϢӦ��
 *    - CMD_GETGROUPACK:        #GETGROUPACK        ��ȡȺ����ϢӦ��
 *    - CMD_MODIMEMBERACK:      #MODIMEMBERACK      �޸�Ⱥ���ԱӦ��
 *    - CMD_SENDMSGACK:         #SENDMSGACK         ������ϢӦ��
 *    - CMD_SENDBROADCASTACK:   #SENDBROADCASTACK   �㲥Ӧ��
 *    - CMD_MSGREADACK:         #MSGREADACK         ��Ϣ�Ѷ�Ӧ��
 *
 *    - CMD_NOTICESTATE:        #USERSTATUSNOTIC    ����ҵԱ������״̬�仯֪ͨ
 *    - CMD_NOTICECOMPINFO:     #NOTICECOMPINFO     ��ҵ��Ϣ����֪ͨ
 *    - CMD_NOTICEDEPTLIST:     #NOTICEDEPTLIST     ������Ϣ����֪ͨ
 *    - CMD_MODIINFONOTICE:     #MODIINFONOTICE     �û������޸�֪ͨ
 *    - CMD_CREATEGROUPNOTICE:  #CREATEGROUPNOTICE  Ⱥ�齨��֪ͨ 
 *    - CMD_MODIGROUPNOTICE:    #MODIGROUPNOTICE    Ⱥ���޸�֪ͨ
 *    - CMD_MODIMEMBERNOTICE:   #MODIMEMBERNOTICE   Ⱥ���Ա�仯֪ͨ
 *    - CMD_MSGNOTICE:          #MSGNOTICE          ��Ϣ֪ͨ
 *    - CMD_BROADCASTNOTICE:    #BROADCASTNOTICE    �㲥֪ͨ
 *    - CMD_MSGREADNOTICE:      #MSGREADNOTICE      ��Ϣ�Ѷ�֪ͨ
 *    - CMD_MSGNOTICECONFIRM:   #MSGNOTICECONFIRM   ��Ϣ֪ͨ�ѽ���ȷ��
 *
 * return 1: get a response; 0: no response; -1: parameter error; -2: no connect
 */

/*
 * client����Ϣ���л�ȡ��Ϣ
 * pMessage������������洢��ȡ������Ϣ
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
 * ��������ʱ����
 * iAliveTime :��λ��
 * return: 0 success
 */
#ifdef WIN32
IM_API (int) CLIENT_SetAliveTime(PCONNCB pConnCB,INT32 iAliveTime);
#else
IM_API int CLIENT_SetAliveTime(PCONNCB pConnCB,INT32 iAliveTime);
#endif


/*
 * ���ӵ��������Ȼ�����ӵ��������
 *
 * ip:   Server IP
 * port: Server port
 * pAccount account
 * type 0û��Я����1Я�����ϴ�ʧ�ܵĽ�������ַ�Ͷ˿�
 * pVersion �汾��
 * 
 * return 0: success,����ʧ��
 */
#ifdef WIN32
IM_API( int )	CLIENT_Connect(PCONNCB pConnCB, char *ip, unsigned short port,char* pAccount,char type,char* pVersion,TERMINAL_TYPE  osType,int connectTimeout=3,int RecvTimeOut=3,char* pFailService=NULL, unsigned short failPort=0);
#else
IM_API int		CLIENT_Connect(PCONNCB pConnCB, char *ip, unsigned short port,char* pAccount,char type,char* pVersion,TERMINAL_TYPE  osType,int connectTimeout,int RecvTimeOut,char* pFailService, unsigned short failPort);
#endif

/*
 * ֱ�����ӵ� �������
 *
 * ip:   Server IP
 * port: Server port
 * 
 * return 0: success; ����ʧ��
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
 * nStatus: 0: ���� 1: ���� 2:�뿪 3:�˳�
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
 * �޸ĵ����û���Ϣ
 * Modify user information
 *
 * nType: modify type, 0: �Ա� 1: ���� 2: �������� 3: סַ 4:�칫�绰���� 5: �ֻ����� 6: ����
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
 * ��Ϣ�޸�֪ͨ���10����ϵ��
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
 * �޸Ķ����û���Ϣ
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
 * ��ȡ��ҵ��Ϣ
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
 * ��ȡ��ҵ��֯������Ϣ
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
 * ��ȡԱ���б����ط�ʽ
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
 * ��ȡԱ���б�
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
 * ��ȡԱ��������Ϣ
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
 * ��ȡ��ҵԱ��״̬��Ϣ�б�
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
 * ����Ⱥ��
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
 * �޸�Ⱥ����Ϣ
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
 * �˳�Ⱥ��
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
 * ���͵�����Ϣ
 * ������Ϣ�����˺�Ⱥ����ɣ�
 * ������Ϣ֪ͨӦ��
 *
 * nRecverID: the receiver ID
 * nType:     the message type, 0: �ı� 1: ͼƬ 2: ���� 3: ��Ƶ 4:����
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
 * ������Ϣ��ִ
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
 * P2P����ȷ��
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
 * ����Ⱥ�飨������͹̶�Ⱥ����Ϣ
 * Send message to group, group chat
 *
 * pszGroupID:  the group ID
 * nType:     the message type, 0: �ı� 1: ͼƬ 2: ���� 3: ��Ƶ 4:����
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
 * �޸ģ����ӡ�ɾ����Ⱥ���Ա
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
 * ���͹㲥��Ϣ�����͹㲥Э�������Ϣ
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
 * �˳���¼���ͷ���Դ
 * The release
 */
#ifdef WIN32
IM_API( void ) CLIENT_UnInit(PCONNCB pConnCB, unsigned char nManual);
#else
IM_API void  CLIENT_UnInit(PCONNCB pConnCB, unsigned char nManual);
#endif

/*
 * ��ȡ�̶�Ⱥ����Ϣ
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
 * �������У��ʱ��
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
 * ��ȡ������Ϣ
 * Send GetOffline
 * nTermType  �û����� 3pC ,ANDROID 1, ios 2
 * return:

 */
#ifdef WIN32
IM_API( int ) CLIENT_GetOffline(PCONNCB pConnCB, UINT8 nTermType);
#else
IM_API int  CLIENT_GetOffline(PCONNCB pConnCB, UINT8 nTermType);
#endif

/*
 * Ⱥ����Ϣ���Σ��ӿ�δʵ�֣�
 * nTermType  �û����� 3pC ,ANDROID 1, ios 2
 * return:

 */
#ifdef WIN32
IM_API( int ) CLIENT_RefuseGroupMsg(PCONNCB pConnCB, char *pszGroupID, unsigned char cRefuseType);
#else
IM_API int  CLIENT_RefuseGroupMsg(PCONNCB pConnCB, char *pszGroupID, unsigned char cRefuseType);
#endif

/*
 * ��Ϣ����ID����
 * nTermType  �û����� 3 pC ,ANDROID 1, ios 2
   uTime    ��2013.6.31��������ʱ�������
 * return:

 */
#ifdef WIN32
IM_API (UINT64) CLIENT_PackMsgId(UINT32 uUserId,UINT8 nTermType, UINT32 uTime);
#else
IM_API UINT64 CLIENT_PackMsgId(UINT32 uUserId,UINT8 nTermType, UINT32 uTime);
#endif

/*
 * ��Ϣ����IDת��Ϊ�����򣬿ɴ�ӡ����ϢID��Ϣ
 * nTermType  �û����� 3 pC ,ANDROID 1, ios 2
   uTime    ��2013.6.31��������ʱ�������
 * return:

 */
#ifdef WIN32
IM_API( UINT64 )CLIENT_UnpackMsgId(UINT64 uMsgId);
#else
IM_API UINT64 CLIENT_UnpackMsgId(UINT64 uMsgId);
#endif

 /* 
 * �����ճ���Ϣ
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
 * �����ճ���Ϣ֪ͨӦ��
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
 * ɾ���ճ���Ϣ
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
 *	iosȺ����Ϣ���Ϳ��أ�Ⱥ����Ϣ����ţ�
 *
 *  return��
 *	0�� success
 *	-1��the connect error
 *	-2:  the parameter error
 *   -3:  No login
 */
#ifdef WIN32
IM_API( int )  CLIENT_GroupPushFlag(PCONNCB pConnCB, char* aszGroupid, int Flag);
#else
int  CLIENT_GroupPushFlag(PCONNCB pConnCB, char* aszGroupid, int Flag);
#endif

/*client����������ƽ̨����Ϣ����
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

/*client���ͻ�ȡ����ҵ�񡢵�����Ϣ
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
/*client����������Ϣ�б�
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseDeptInfo(const char* pszDeptInfo, UINT32* pu32StartPos, DEPTINFO* psDeptInfo);
#else
IM_API int  CLIENT_ParseDeptInfo(const char* pszDeptInfo, UINT32* pu32StartPos, DEPTINFO* psDeptInfo);
#endif

/*client�����û�������Ϣ�б�
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseDeptUserInfo(const char* pszDeptUserInfo, UINT32* pu32StartPos, USERDEPT* psUserDept);
#else
IM_API int  CLIENT_ParseDeptUserInfo(const char* pszDeptUserInfo, UINT32* pu32StartPos, USERDEPT* psUserDept);
#endif

/*client�����û���Ϣ�б�
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseUserInfo(const char* pszUserInfo, UINT32* pu32StartPos, USERINFO* psUserInfo);
#else
IM_API int  CLIENT_ParseUserInfo(const char* pszUserInfo, UINT32* pu32StartPos, USERINFO* psUserInfo);
#endif

/*client�ƶ��˽����û���Ҫ��Ϣ�б�
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

/*client������ȡ�û�����(Ա������)��Ϣ
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserRank(const char* pszUserRank, UINT32* pu32StartPos, USERRANK* psUserRank);
#else
int   CLIENT_ParseUserRank(const char* pszUserRank, UINT32* pu32StartPos, USERRANK* psUserRank);
#endif

/*client������ȡ�û�ҵ��(Ա������)��Ϣ
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserPro(const char* pszUserPro, UINT32* pu32StartPos, USERPROFESSIONAL* psUserPro);
#else
int   CLIENT_ParseUserPro(const char* pszUserPro, UINT32* pu32StartPos, USERPROFESSIONAL* psUserPro);
#endif

/*client������ȡ�û�����(Ա������)��Ϣ
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ParseUserArea(const char* pszUserArea, UINT32* pu32StartPos, USERAREA* psUserArea);
#else
int   CLIENT_ParseUserArea(const char* pszUserArea, UINT32* pu32StartPos, USERAREA* psUserArea);
#endif

/*client������ȡ�û���ϸ��Ϣ
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseEmploee(const char* pszEmploee, UINT32* pu32StartPos, EMPLOYEE* psUserInfo);
#else
IM_API int  CLIENT_ParseEmploee(const char* pszEmploee, UINT32* pu32StartPos, EMPLOYEE* psUserInfo);
#endif

/*client������ȡͷ��仯�û��б�
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int ) CLIENT_ParseUserHeadIconList(const char* pszUserList, UINT32* pu32StartPos, TUserHeadIconList* psUserList);
#else
IM_API int  CLIENT_ParseUserHeadIconList(const char* pszUserList, UINT32* pu32StartPos, TUserHeadIconList* psUserList);
#endif

/*client���ù�Կ·��
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SetRsaKeyPath(char* path);
#else
IM_API int   CLIENT_SetRsaKeyPath(char* path);
#endif

/*client����ios�ͻ����л�����̨�����ϱ�δ����Ϣ��
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

/*client���ͻ�ȡ������Ա�б�����
*
*return :
*     0: success;
 
*/
#ifdef WIN32
	IM_API( int )  CLIENT_GetSpecialList(PCONNCB pConnCB,GETSPECIALLIST *pData);
#else
	int   CLIENT_GetSpecialList(PCONNCB pConnCB,GETSPECIALLIST *pData);
#endif

/*client����������Ա�����޸�֪ͨӦ��
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_ModiSpecialListNoticeAck(PCONNCB pConnCB,UINT64 dwMsgID);
#else
int   CLIENT_ModiSpecialListNoticeAck(PCONNCB pConnCB,UINT64 dwMsgID);
#endif 

/*client���ͻ�ȡ״̬����
*
*return :
*     0: success;
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_GetUserStatusReq(PCONNCB pConnCB,TGetStatusReq *pStatusReq);
#else
int   CLIENT_GetUserStatusReq(PCONNCB pConnCB,TGetStatusReq *pStatusReq);
#endif 


/*client�����û�״̬��
*
*return :
*     0: success; �����ο�������
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_user_status_Parse(BOOL  bNeedTurn, user_status* pData, TUserStatusList* pStatusList );
#else
int   CLIENT_user_status_Parse(BOOL  bNeedTurn, user_status* pData, TUserStatusList* pStatusList );
#endif


/*client������ʱ��������
*
*return :
*     0: success; �����ο�������
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendSubscribeReq(PCONNCB pConnCB,SUBSCRIBER_REQ *pData);
#else
int   CLIENT_SendSubscribeReq(PCONNCB pConnCB,SUBSCRIBER_REQ *pData);
#endif 

/*clientjson��ʽ�������ݰ���
*
*return :
*     0: success; �����ο�������
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendJSON(PCONNCB pConnCB,TJson *pData);
#else
int   CLIENT_SendJSON(PCONNCB pConnCB,TJson *pData);
#endif 

/*clientjson��ʽ�������ݰ���,����
*
*return :
*     0: success; �����ο�������
 
*/
#ifdef WIN32
IM_API( int )  CLIENT_SendJSON_Encrypt(PCONNCB pConnCB,TJson *pData);
#else
int   CLIENT_SendJSON_Encrypt(PCONNCB pConnCB,TJson *pData);
#endif 

/*
 * CLIENT_GetConnectRspInfo			��ȡ������Ϣ
 * pConnCB:							�û����ӽṹ��
 * pTaccessResponse:				�����������ȡ�������Ӧ��ṹ��
 * return:							0 �ɹ�

 */
#ifdef WIN32
IM_API( int )  CLIENT_GetConnectRspInfo(PCONNCB pConnCB,  LOGINACCESSACK *pTaccessResponse);
#else
int   CLIENT_GetConnectRspInfo(PCONNCB pConnCB, LOGINACCESSACK *pTaccessResponse);
#endif 

/*
 * CLIENT_RoamingDataModi			�������ݣ�������ϵ�ˡ����ò��š���ע�ˣ�ͬ��
 * pConnCB:							�û����ӽṹ��
 * pData:							��������ͬ������ṹ��
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_RoamingDataSync(PCONNCB pConnCB,ROAMDATASYNC *pData);
#else
int   CLIENT_RoamingDataSync(PCONNCB pConnCB,ROAMDATASYNC *pData);
#endif

/*
 * CLIENT_RoamingDataModi			���������޸�
 * pConnCB:							�û����ӽṹ��
 * pData:							�����������ӡ�ɾ������ṹ��
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
	IM_API( int )  CLIENT_RoamingDataModi(PCONNCB pConnCB,ROAMDATAMODI *pData);
#else
	int   CLIENT_RoamingDataModi(PCONNCB pConnCB,ROAMDATAMODI *pData);
#endif

/*
 * CLIENT_GetUserHeadIconList		�����ȡͷ��仯���û��б�
 * pConnCB:							�û����ӽṹ��
 * nLastUpdateTime:					�ͻ������µ�ͷ��ʱ��
 * cType:							�ͻ������� 1 android, 2 ios, 3 pc
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_GetUserHeadIconList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#else
int  CLIENT_GetUserHeadIconList(PCONNCB pConnCB, int nLastUpdateTime, TERMINAL_TYPE cType);
#endif

/*
 * CLIENT_GetErrorCode				�ͻ��˴�����ת��
 * eResult:							����˷��صĴ�����
 * return:							�ͻ�����Ҫ�Ĵ�����

 */
#ifdef WIN32
IM_API( int ) CLIENT_GetErrorCode(RESULT eResult);
#else
IM_API int CLIENT_GetErrorCode(RESULT eResult);
#endif
/*
 * CLIENT_Disconnect				�ͻ��˵ǳ�����
 * pConnCB:							�û����ӽṹ��
 * return:							0 �ɹ�

 */
#ifdef WIN32
IM_API( int )	CLIENT_Disconnect(PCONNCB pConnCB);
#else
int				CLIENT_Disconnect(PCONNCB pConnCB);
#endif

/*
 * CLIENT_MsgReadSyncReq			�Ѷ���Ϣͬ������
 * pConnCB:							�û����ӽṹ��
 * pData:							�ͻ����Ѷ���Ϣͬ������ṹ��
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_MsgReadSyncReq(PCONNCB pConnCB,MSG_READ_SYNC *pData);
#else
int   CLIENT_MsgReadSyncReq(PCONNCB pConnCB,MSG_READ_SYNC *pData);
#endif

/*
 * CLIENT_RobotInfoSync				��������Ϣͬ������
 * pConnCB:							�û����ӽṹ��
 * pData:							��������Ϣͬ������ṹ��
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_RobotInfoSync(PCONNCB pConnCB,ROBOTSYNCREQ *pData);
#else
int   CLIENT_RobotInfoSync(PCONNCB pConnCB,ROBOTSYNCREQ *pData);
#endif

/*
 * CLIENT_SendContactsUpdateAck		����ͨѶ¼����֪ͨӦ��
 * pConnCB:							�û����ӽṹ��
 * dwTimeStamp:						ͨѶ¼���µ�ʱ���
 * cTerminalType:					�û����� 1 android, 2 ios, 3 pc
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_SendContactsUpdateAck(PCONNCB pConnCB, UINT32 dwTimeStamp, UINT8 cTerminalType);
#else
int   CLIENT_SendContactsUpdateAck(PCONNCB pConnCB, UINT32 dwTimeStamp, UINT8 cTerminalType);
#endif

/*
 * CLIENT_VirtualGroupInfoReq		������������Ϣ����
 * pConnCB:							�û����ӽṹ��
 * dwTimeStamp:						�����鱾��ʱ���
 * cTerminalType:					�û����� 1 android, 2 ios, 3 pc
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_VirtualGroupInfoReq(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#else
int CLIENT_VirtualGroupInfoReq(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#endif
/*
 * CLIENT_FavoriteSync				�ղ�ͬ������
 * pConnCB:							�û����ӽṹ��
 * dwTimeStamp:						�ղر���ʱ���
 * cTerminalType:					�û����� 1 android, 2 ios, 3 pc
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_FavoriteSync(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#else
int CLIENT_FavoriteSync(PCONNCB pConnCB,UINT32 dwTimeStamp,UINT8 cTerminalType);
#endif
/*
 * CLIENT_FavoriteModifyReq			�ղز�������
 * pConnCB:							�û����ӽṹ��
 * dwTimeStamp:						�ղز����ṹ��
 * return:							0 �ɹ������� ����ʧ��

 */
#ifdef WIN32
IM_API( int )  CLIENT_FavoriteModifyReq(PCONNCB pConnCB,FAVORITE_MODIFY_REQ *pFavorite);
#else
int CLIENT_FavoriteModifyReq(PCONNCB pConnCB,FAVORITE_MODIFY_REQ *pFavorite);
#endif

/**
 * [CLIENT_GetDeptShowConfig ��ȡ������ʾ������Ϣ]
 * @param  pConnCB   [�û����ӽṹ��]
 * @param  timestamp [��������ʱ���]
 * @param  cType     [�û���¼����]
 * @return           [0�ɹ������� ����ʧ��]
 */
#ifdef WIN32
IM_API( int )  CLIENT_GetDeptShowConfig(PCONNCB pConnCB, int timestamp, TERMINAL_TYPE cType);
#else
int  CLIENT_GetDeptShowConfig(PCONNCB pConnCB, int timestamp, TERMINAL_TYPE cType);
#endif

/**
 * [CLIENT_ParseDeptShowConfig ����������ʾ������Ϣ]
 * @param  pszDeptInfo     [������ʾ����Ӧ���ַ���]
 * @param  pu32StartPos    [�����Ŀ�ʼλ��]
 * @param  psDeptShowLevel [������������Ŷ�Ӧ�Ľṹ��]
 * @return                 [EIMERR_SUCCESS��EIMERR_PARSE_FINISHED��EIMERR_INVALID_PARAMTER]
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
