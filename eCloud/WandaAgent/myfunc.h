#ifndef __MYFUNCLIB_H__
#define __MYFUNCLIB_H__

#include "BasicDefine.h"
#include "protocol.h"

void uSleep(int lTime);

void String2Upper(char* pString);

UINT8 Char2Digit(const char ch);

UINT32 ParseLength(const char* pszData, UINT32 u32Bytes);


//转换数据为网络字节流
int toBytesLogin(LOGIN*pThis, LV255* pData);

	//转换网络流为结构体
int toDecodeLOGINACK(LOGINACK*pThis, INT8* pData);
	
	//转换为网络流,返回长度
int toEncodeLOGINACK(LOGINACK*pThis, INT8* pOutData);
//请求接入管理:转为网络流量
int  toBytesTAccessRequest(TAccessRequest*pThis, LV1024 *pLV1024);//转换为wang luo字节流


	//请求接入管理应答:解压网络数据包到成员函数
//参数：pData 收到的网络数据
int toDecodeLOGINACCESSACK(LOGINACCESSACK*pThis, INT8 *pData);

	//解压全量状态数 
int toDecodeTALLUserStatus(TALLUserStatus*pThis, UINT32 uBegID,UINT32 uGetNum,TGetStatusRsp* pData,UINT32* pEndUserID  );

#endif
