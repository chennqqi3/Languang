#ifndef __HTTP_H__
#define __HTTP_H__

#include "BasicDefine.h"
#include "protocol.h"
#include "client.h"
#define PACKET_MAX_LEN 4096
#pragma pack(push, 1)
typedef struct tagEncrypt
{
    char   cCmdID;// 
    INT32  nLength;
	char  strBuffer[PACKET_MAX_LEN];
}TEncrypt;

typedef struct tagStatusData
{
	UINT16 szNum[4];//离线， 在线，离开，移动
	UINT32 szUserId[0];
} TStatusData;


#define CMD_ENCRYPT_PUBLIC_KEY_RSP 99  	//服务端公钥下发应答
#define CMD_ENCRYPT_SEND_PWD_REQ 101 	//客户端发送RSA加密登录请求
#define CMD_ENCRYPT_SEND_PWD_RSP 102 	//加密的登录应答包
#define CMD_ENCRYPT_SEND_DATA_REQ 103		//发送加密的普通数据请求
#define CMD_ENCRYPT_DATA_RSP 100			//发送加密的普通数据应答
#define CMD_SEND_OR_RECV_DATA 105			//普通数据收发,不加密
#define CMD_STATUS_NOTICE 107				//状态通知
#define CMD_PROTOCOL_SEND_OR_RECV_DATA_ENCRYPT 108		//协议2收发加密数据
#define CMD_PROTOCOL_SEND_OR_RECV_DATA 109				//协议2收发没有加密数据
#define CMD_ALLSTATUS_NOTICE 110				//全量状态通知



#pragma pack(pop)
//收取消息：消息格式必须是 4字节长度，起头的，uBufLen 是pBuffer 的长度
INT32 RecvMsg(INT32 nSockFd, char* pBuffer, UINT32 uBufLen,UINT32 uTimeOut=3 );
 
//socket 发送数据,必须非阻塞的
int SendData(SOCKET nSocket, char *pszData, UINT32 dwSize);

//发送加密数据或业务数据
int EncryptSendHttpData(char cCmdId,SOCKET nSocket, char *pszData, int nDataLen);

//接收加密数据或不加密的
INT32 EncryptRecvMsg(INT32 nSockFd, char* pBuffer, UINT32 uBufLen);


INT32 ParseData(INT8* pInBuf,INT32 iInLength, INT8* pOutBuffer, INT32* pOutLength);

#endif // __HTTP_H__
