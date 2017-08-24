#ifndef __MYFUNCLIB_H__
#define __MYFUNCLIB_H__

#include "BasicDefine.h"
#include "protocol.h"

void uSleep(int lTime);

void String2Upper(char* pString);

UINT8 Char2Digit(const char ch);

UINT32 ParseLength(const char* pszData, UINT32 u32Bytes);


//ת������Ϊ�����ֽ���
int toBytesLogin(LOGIN*pThis, LV255* pData);

	//ת��������Ϊ�ṹ��
int toDecodeLOGINACK(LOGINACK*pThis, INT8* pData);
	
	//ת��Ϊ������,���س���
int toEncodeLOGINACK(LOGINACK*pThis, INT8* pOutData);
//����������:תΪ��������
int  toBytesTAccessRequest(TAccessRequest*pThis, LV1024 *pLV1024);//ת��Ϊwang luo�ֽ���


	//����������Ӧ��:��ѹ�������ݰ�����Ա����
//������pData �յ�����������
int toDecodeLOGINACCESSACK(LOGINACCESSACK*pThis, INT8 *pData);

	//��ѹȫ��״̬�� 
int toDecodeTALLUserStatus(TALLUserStatus*pThis, UINT32 uBegID,UINT32 uGetNum,TGetStatusRsp* pData,UINT32* pEndUserID  );

#endif
