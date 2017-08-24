#include "http.h"
#include "BasicDefine.h"
#include "myfunc.h"

int SendData(SOCKET nSocket, char *pszData, UINT32 dwSize)
{
    int nRet   = 0;
    int nCount = 0;
    int nTmp   = 0;
    int nTotal = dwSize;
    const char* pData = pszData;

    while(1)
    {
        nTmp = send(nSocket, pData, nTotal, 0);
       // int err=errno;
        if (nTmp < 0)
        {
            nCount ++;
            if (WSAGetLastError() == EWOULDBLOCK || WSAGetLastError() == EINTR)
            {
                if (nCount > 30)
                {
					return EIMERR_SENDSOCKET_SOCKET;
                    break;
                }
                uSleep(100);
				continue;
			}
            else
            {
                return EIMERR_SENDSOCKET_SOCKET;
            }
        }

        if (nTmp == nTotal)
            return dwSize;

        nTotal -= nTmp;
        pData  += nTmp;
        nRet   += nTmp;
    }
    return nRet;
}

int EncryptSendHttpData(char cCmdId,SOCKET nSocket, char *pszData, int nDataLen)
{
    INT32           nReturn = 0;
	TEncrypt        tData;
 
    char           *pSendBuf = tData.strBuffer;
	char szData[PACKET_MAX_LEN]="";
	if ( nDataLen > (int)sizeof(tData.strBuffer))
		return EIMERR_INVALID_PARAMTER;
    memcpy(szData, pszData, nDataLen);
	int iDataLength =  nDataLen;
	int iOutLength;
	int iTotalLength=0;

	int iRsaLen=0;
	char  szRsaData[200]="";

 
   switch(cCmdId)
   {
   case CMD_ENCRYPT_SEND_PWD_REQ://登录传输密码命令字
	   //加密AES密码数据 128字节

		EncryptRsa((unsigned char*)GetAesKey(),16,(unsigned char*)szRsaData,&iRsaLen);
		tData.cCmdID = cCmdId;
		memcpy(pSendBuf,szRsaData, iRsaLen);
	   //AES加密发送数据
		SetKeyAes((unsigned char*)GetAesKey());
		//SetKeyAes((unsigned char*)"abcdefgh12345678");
		EncryptAes(szData,iDataLength,pSendBuf+iRsaLen,&iOutLength);
 
	   //计算长度
		iTotalLength = 5+iRsaLen+iOutLength;
		tData.nLength = htonl(iTotalLength);    
		
		 printf("type:%d,aeskey:%s,len:%d,iOutLength:%d,iRsaLen:%d,iDataLength:%d :data:%s\n",tData.cCmdID,GetAesKey(),iTotalLength,iOutLength,iRsaLen,iDataLength,szData);
	   break;
   case CMD_ENCRYPT_SEND_DATA_REQ:
	   //AES加密发送数据
	   tData.cCmdID = CMD_ENCRYPT_SEND_DATA_REQ;
		 EncryptAes(szData,iDataLength,pSendBuf+iRsaLen,&iOutLength);
	   //计算长度
		iTotalLength = sizeof(char)+sizeof(int)+iRsaLen+iOutLength;
		tData.nLength = htonl(iTotalLength);
		printf("CMD_ENCRYPT_SEND_DATA_REQ:%d\n",iTotalLength);
	   break;
	case CMD_SEND_OR_RECV_DATA://发送数据不加密
		tData.cCmdID = CMD_SEND_OR_RECV_DATA;
		memcpy(pSendBuf, pszData, iDataLength);
		iTotalLength = sizeof(char)+sizeof(int)+iDataLength;
		tData.nLength = htonl(iTotalLength);
		printf("CMD_SEND_OR_RECV_DATA:%d\n",iTotalLength);
	   break;
  case CMD_PROTOCOL_SEND_OR_RECV_DATA_ENCRYPT:
	   //AES加密发送数据V2
	   tData.cCmdID = CMD_PROTOCOL_SEND_OR_RECV_DATA_ENCRYPT;
		 EncryptAes(szData,iDataLength,pSendBuf+iRsaLen,&iOutLength);
	   //计算长度
		iTotalLength = sizeof(char)+sizeof(int)+iRsaLen+iOutLength;
		tData.nLength = htonl(iTotalLength);
		printf("CMD_PROTOCOL_SEND_OR_RECV_DATA_ENCRYPT:%d\n",iTotalLength);
	   break;
	case CMD_PROTOCOL_SEND_OR_RECV_DATA://发送数据不加密V2
		tData.cCmdID = CMD_PROTOCOL_SEND_OR_RECV_DATA;
		memcpy(pSendBuf, pszData, iDataLength);
		iTotalLength = sizeof(char)+sizeof(int)+iDataLength;
		tData.nLength = htonl(iTotalLength);
		printf("CMD_SEND_OR_RECV_DATA:%d\n",iTotalLength);
	   break;

   }
  
    nReturn = SendData(nSocket, (char*)&tData,iTotalLength );
    if (nReturn == iTotalLength) 
		return EIMERR_SUCCESS;

    return nReturn;
}


INT32 EncryptRecvMsg(INT32 nSockFd, char* pBuffer, UINT32 uBufLen)
{

    INT32       nReturn  = 0;
    INT32       nRecvLen = 0;
    UINT32      nCount   = 0;

	if(nSockFd <= 0 )
		return EIMERR_SOCKETFD_SOCKET;
    char        strChange[10];
	char  strBuffer[PACKET_MAXLEN+500];
    memset(strChange, 0, sizeof(strChange));
	memset(strBuffer,0, sizeof(strBuffer));
 
	char        *pBuf    = strBuffer;
	UINT32 iDataLength =0;
	int iOutLength =0;
	//char* pBeg=NULL,*pEnd=NULL;
	//char szLength[20]="";
	//int iHeadLen=0;
	//读取长度
	while(1)
	{
		//包格式：HTTP头 类型 长度 业务数据长度
		nRecvLen = recv(nSockFd, pBuf,  sizeof(strBuffer), MSG_PEEK);
		if(nRecvLen > 0 )
		{
			iDataLength =0;
			if(nRecvLen >= 5)
			{
				iDataLength = ntohl(*((INT32*)(pBuf+1)));
			}
			else
			{
				nCount++;                
                if (nCount >= 10)
                {
                    nCount = 0;
					return EIMERR_RECV_TIMEOUT_SOCKET;
                }
				uSleep(100);
				continue;
			}

			if((INT32)iDataLength<=nRecvLen && iDataLength>0)
			{

				if(iDataLength > uBufLen) // 数据超过给的缓存，返回
					return EIMERR_RECVDATA_TOOBIG_SOCKET;
				//收取
				nRecvLen = recv(nSockFd, pBuf, iDataLength, 0);
				if (nRecvLen != (INT32)iDataLength)
					return EIMERR_RECV_DATA_SOCKET;

				return ParseData(pBuf, iDataLength, pBuffer, &iOutLength);
			}
			else
			{
				nCount++;                
                if (nCount >= 10)
                {
                    nCount = 0;
					return EIMERR_RECV_TIMEOUT_SOCKET;
                }
				uSleep(100);
				continue;
			}
		}
		else if(nRecvLen < 0)
        {
            //if(EAGAIN == errno) 
            //由于是非阻塞的模式,所以当errno为EAGAIN时,表示当前缓冲区已无数据可读,在这里就当作是该次事件已处理
            if (WSAGetLastError() == EWOULDBLOCK || WSAGetLastError() == EINTR || WSAGetLastError() == EAGAIN)
            {
                nCount++;                
                if (nCount >= 10)
                {
                    nCount = 0;
                    return EIMERR_RECV_TIMEOUT_SOCKET;
                }
                uSleep(100);
                continue;
            }
            else
            {
                return EIMERR_RECVSOCKET_SOCKET;
            }
        }
		else if(0 == nRecvLen)
		{
			return EIMERR_SOCKETCLOSE_SOCKET;
		}
	
	}
    return nReturn;
}



INT32 RecvMsg(INT32 nSockFd, char* pBuffer, UINT32 uBufLen,UINT32 uTimeOut)
{
    INT32       nReturn  = 0;
    INT32       nRecvLen = 0;
    UINT32      nCount   = 0;
    UINT32      uLen     = uBufLen;
    char        *pBuf    = pBuffer;

    char        strChange[100];
    memset(strChange, 0, sizeof(strChange));
	int iFlag=0;

    while (1)
    {
        nRecvLen = recv(nSockFd, pBuf, uLen, 0);

        if(nRecvLen < 0)
        {
            //if(EAGAIN == errno) 
            //由于是非阻塞的模式,所以当errno为EAGAIN时,表示当前缓冲区已无数据可读,在这里就当作是该次事件已处理
            if (WSAGetLastError() == EWOULDBLOCK || WSAGetLastError() == EINTR)
            {
                nCount++;                
                if (nCount >= uTimeOut*10)
                {
                    nCount = 0;
					return EIMERR_RECV_TIMEOUT_SOCKET;
                }
                uSleep(100);
                continue;
            }
            else
            {
                return EIMERR_RECVSOCKET_SOCKET;
            }
        }
        //表示对端的socket已正常关闭.
        else if(0 == nRecvLen)  
        {
            return EIMERR_SOCKETCLOSE_SOCKET;
        }

		if(iFlag==0)
		{
			iFlag=1;
			uBufLen = ntohs(*(INT16*)pBuf);
		}

        pBuf    += nRecvLen;
        uLen    -= nRecvLen;
        nReturn += nRecvLen;

        //读够字节数，退出
        if ((UINT32)nReturn == uBufLen)
        {
            break;
        }
    }


    return nReturn;
}




INT32 ParseData(INT8* pInBuf,INT32 iInLength, INT8* pOutBuffer, INT32* pOutLength)
{
 

	INT32 iRet=0;
	switch(*pInBuf)
	{
	case CMD_ENCRYPT_PUBLIC_KEY_RSP://保存公钥
		{

			FILE* fp =fopen(m_strRsaPathFile,"w");
			if(fp)
			{
				fwrite(pInBuf+5,20,1,fp);
				fclose(fp);
				LoadPublicKeyFile(m_strRsaPathFile);
				return EIMERR_RSAKEY_SOCKET;
			}
			return EIMERR_OPENRSAFILE_SOCKET;
		}
		break;

	case CMD_ENCRYPT_SEND_PWD_RSP:
		{
			DecryptAes(pInBuf+5,iInLength-5,pOutBuffer,pOutLength);
			return *pOutLength;

		}
	case CMD_ENCRYPT_DATA_RSP://解密加密的数据
		{
			DecryptAes(pInBuf+5,iInLength-5,pOutBuffer,pOutLength);

	 
			return *pOutLength;
		}
		break;
	case CMD_SEND_OR_RECV_DATA://普通数据不加密
		{
			//pOutBuffer = pInBuf+5;
			memcpy(pOutBuffer,pInBuf+5,iInLength-5);
			*pOutLength= iInLength -5;

			return  *pOutLength;
		}
		break;
	case CMD_STATUS_NOTICE://状态通知
		{
			TERM_CMD_HEAD tHead;
			memset(&tHead, 0, sizeof(tHead));
			tHead.wCmdID = htons(CMD_NOTICESTATE);
			tHead.wMsgLen = htons(MSGHEAD_LEN + iInLength-5);
			memcpy(tHead.aszMsg,pInBuf+5, iInLength-5);
			memcpy(pOutBuffer, &tHead, sizeof(tHead));
			return MSGHEAD_LEN + iInLength-5;
		}
		break;

	case CMD_PROTOCOL_SEND_OR_RECV_DATA_ENCRYPT://协议2收发加密数据
		{
			DecryptAes(pInBuf+5,iInLength-5,pOutBuffer,pOutLength);
			TERM_CMD_HEAD tHead;
			memset(&tHead, 0, sizeof(tHead));
			tHead.wCmdID = htons(CMD_PROTOCOL_V2);
			tHead.wMsgLen = htons(MSGHEAD_LEN + *pOutLength);
			memcpy(tHead.aszMsg,pOutBuffer, *pOutLength);
			memset(pOutBuffer, 0, *pOutLength);
			memcpy(pOutBuffer, &tHead, sizeof(tHead));

			return (*pOutLength + MSGHEAD_LEN);
		}

		break;

	case CMD_PROTOCOL_SEND_OR_RECV_DATA://协议2收发不加密数据
		{
			TERM_CMD_HEAD tHead;
			memset(&tHead, 0, sizeof(tHead));
			tHead.wCmdID = htons(CMD_PROTOCOL_V2);
			tHead.wMsgLen = htons(MSGHEAD_LEN + iInLength-5);
			memcpy(tHead.aszMsg,pInBuf+5, iInLength-5);
			memcpy(pOutBuffer, &tHead, sizeof(tHead));
			*pOutLength = sizeof(tHead);
			return MSGHEAD_LEN + iInLength-5;
		}
		break;

	case CMD_ALLSTATUS_NOTICE://全量状态
		{
			TERM_CMD_HEAD tHead;
			tHead.wCmdID = htons(CMD_NOTICESTATE_ALL);
			tHead.wMsgLen = htons(MSGHEAD_LEN + iInLength-5);
			memcpy(tHead.aszMsg,pInBuf+5, iInLength-5);
			memcpy(pOutBuffer, &tHead, sizeof(tHead));
			*pOutLength = sizeof(tHead);

			return MSGHEAD_LEN + iInLength-5;
		}
		break;
	default:


		break;
	}

 

	return iRet;
}