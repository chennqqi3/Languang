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
	UINT16 szNum[4];//���ߣ� ���ߣ��뿪���ƶ�
	UINT32 szUserId[0];
} TStatusData;


#define CMD_ENCRYPT_PUBLIC_KEY_RSP 99  	//����˹�Կ�·�Ӧ��
#define CMD_ENCRYPT_SEND_PWD_REQ 101 	//�ͻ��˷���RSA���ܵ�¼����
#define CMD_ENCRYPT_SEND_PWD_RSP 102 	//���ܵĵ�¼Ӧ���
#define CMD_ENCRYPT_SEND_DATA_REQ 103		//���ͼ��ܵ���ͨ��������
#define CMD_ENCRYPT_DATA_RSP 100			//���ͼ��ܵ���ͨ����Ӧ��
#define CMD_SEND_OR_RECV_DATA 105			//��ͨ�����շ�,������
#define CMD_STATUS_NOTICE 107				//״̬֪ͨ
#define CMD_PROTOCOL_SEND_OR_RECV_DATA_ENCRYPT 108		//Э��2�շ���������
#define CMD_PROTOCOL_SEND_OR_RECV_DATA 109				//Э��2�շ�û�м�������
#define CMD_ALLSTATUS_NOTICE 110				//ȫ��״̬֪ͨ



#pragma pack(pop)
//��ȡ��Ϣ����Ϣ��ʽ������ 4�ֽڳ��ȣ���ͷ�ģ�uBufLen ��pBuffer �ĳ���
INT32 RecvMsg(INT32 nSockFd, char* pBuffer, UINT32 uBufLen,UINT32 uTimeOut=3 );
 
//socket ��������,�����������
int SendData(SOCKET nSocket, char *pszData, UINT32 dwSize);

//���ͼ������ݻ�ҵ������
int EncryptSendHttpData(char cCmdId,SOCKET nSocket, char *pszData, int nDataLen);

//���ռ������ݻ򲻼��ܵ�
INT32 EncryptRecvMsg(INT32 nSockFd, char* pBuffer, UINT32 uBufLen);


INT32 ParseData(INT8* pInBuf,INT32 iInLength, INT8* pOutBuffer, INT32* pOutLength);

#endif // __HTTP_H__
