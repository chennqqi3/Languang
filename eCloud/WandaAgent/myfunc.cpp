#include "myfunc.h"


void uSleep(int lTime)
{
#ifdef WIN32
    Sleep( lTime );
#else
    struct timeval sTime;
    sTime.tv_sec    = 0;
    sTime.tv_usec   = lTime*1000;
    select(0, NULL, NULL, NULL, &sTime);
#endif
}
void String2Upper(char* pString)
{
    INT16      iCurPos= 0;
    INT16      i= 'A' - 'a';

    if ( !pString )
        return;

    while ( pString[ iCurPos ] != 0 )
    {
        if ( pString[ iCurPos ] >= 'a' && pString[ iCurPos ] <= 'z' )
        {
            pString[ iCurPos ] += i;
        }

        iCurPos++;
    }
}
//=============================================================================
//Function:     Char2Digit
//Description:	Convert a charater to digit
//
//Parameter:
//	ch    - Charater to be convert, any invalid ch deal with as 0 
//
//Return:
//	The converted result   
//=============================================================================
UINT8 Char2Digit(const char ch)
{
	if( ch >= '0' && ch <= '9' )	// Is digit charater
		return ( ch - '0' );
	
	return 0;	// Invalid charater
}

//=============================================================================
//Function:     ParseLength
//Description:	Parse the VLA's(Variable Length Array) LENGTH, lead fill 0, format as:
//	LVAR, 		可变长（0－9）
//	LLVAR, 		可变长（0－99）
//	LLLVAR,  	可变长（0－999）
//	LLLLVAR,  	可变长（0－9999）
//
//Parameter:
//	pszData     - VLA data field
//	u32Bytes    - VLA's length charater count
//
//Return:
//		The converted result   
//=============================================================================
UINT32 ParseLength(const char* pszData, UINT32 u32Bytes)
{	// The length in pszData is DECIMAL ASCII
	UINT32 u32Ret	= 0;
	UINT32 u32Index = 0;

	switch(u32Bytes)
	{
	case 4:
		u32Ret += Char2Digit(pszData[u32Index++]);
		u32Ret *= 10;
	case 3:
		u32Ret += Char2Digit(pszData[u32Index++]);
		u32Ret *= 10;
	case 2:
		u32Ret += Char2Digit(pszData[u32Index++]);
		u32Ret *= 10;
	case 1:
		u32Ret += Char2Digit(pszData[u32Index]);
		break;
	default:
		//ASSERT_(0);
		break;
	}

	return u32Ret;
}



	//登陆请求 转换数据为网络字节流
	int toBytesLogin(LOGIN*pThis, LV255* pData)
	{
		INT32 pos =0;
		
		memcpy(pData->value,pThis->aszVersion,sizeof(pThis->aszVersion));
		pos +=sizeof(pThis->aszVersion);

		pData->value[pos]=pThis->tAccount.len;
		pos +=sizeof(pThis->tAccount.len);

		memcpy(pData->value+pos, pThis->tAccount.value, pThis->tAccount.len);
		pos +=pThis->tAccount.len;

		pData->value[pos]=pThis->cLoginType;
		pos += sizeof(pThis->cLoginType);

		memcpy(pData->value+pos, pThis->aszPassword, PASSWD_MAXLEN);
		pos += PASSWD_MAXLEN;

		memcpy(pData->value+pos, pThis->aszMacAddr, MAC_ADDR_MAXLEN);
		pos +=MAC_ADDR_MAXLEN;

		pData->value[pos]=pThis->tDeviceToken.len;
		pos +=sizeof(pThis->tDeviceToken.len);

		memcpy(pData->value+pos, pThis->tDeviceToken.value, pThis->tDeviceToken.len);
		pos +=pThis->tDeviceToken.len;
		
		pData->len= pos;
	
		return pos;
	}




		//登陆应答:转换网络流为结构体
	int toDecodeLOGINACK(LOGINACK*pThis, INT8* pData)
	{
		INT32 pos=0;
		memset(pThis, 0, sizeof(LOGINACK));
		pThis->ret = *pData;
		pos +=sizeof(pThis->ret);


		pThis->tRetDesc.len=*(pData+pos);
		pos +=sizeof(pThis->tRetDesc.len);

		memcpy(pThis->tRetDesc.value, pData+pos, pThis->tRetDesc.len);
		pos +=pThis->tRetDesc.len;


		pThis->tAuthToken.len=*(pData+pos);
		pos +=sizeof(pThis->tAuthToken.len);

		memcpy(pThis->tAuthToken.value, pData+pos, pThis->tAuthToken.len);
		pos +=pThis->tAuthToken.len;

	pThis->tCnUserName.len=*(pData+pos);
		pos +=sizeof(pThis->tCnUserName.len);

		memcpy(pThis->tCnUserName.value, pData+pos, pThis->tCnUserName.len);
		pos +=pThis->tCnUserName.len;
	
	
		pThis->tEnUserName.len=*(pData+pos);
		pos +=sizeof(pThis->tEnUserName.len);

		memcpy(pThis->tEnUserName.value, pData+pos, pThis->tEnUserName.len);
		pos +=pThis->tEnUserName.len;

		memcpy(&pThis->dwSessionID,pData+pos, 
			sizeof(LOGINACK)-sizeof(pThis->ret)-sizeof(pThis->tRetDesc)-sizeof(pThis->tAuthToken)-sizeof(pThis->tCnUserName)-sizeof(pThis->tEnUserName));//-2*sizeof(pThis->tEnUserName));
		return 0;
	}
 

 

	//请求接入管理:转为网络流量
	int  toBytesTAccessRequest(TAccessRequest*pThis, LV1024 *pLV1024)//转换为wang luo字节流
	{


		LV1024& tLV1024 =*pLV1024;
		tLV1024.len=0;
		INT32 pos =0;
		
		tLV1024.value[0]=pThis->type;
		pos += sizeof(pThis->type);

		memcpy(tLV1024.value+pos, pThis->szVer, sizeof(pThis->szVer));
		pos += sizeof(pThis->szVer);

		tLV1024.value[pos]=pThis->osType;
		pos +=sizeof(pThis->osType);


		tLV1024.value[pos]=pThis->tUserAccount.len;
		pos+=sizeof(pThis->tUserAccount.len);

		memcpy(tLV1024.value+pos, pThis->tUserAccount.value, pThis->tUserAccount.len);
		pos +=pThis->tUserAccount.len;


		tLV1024.value[pos]=pThis->tFailServiceAddr.len;
		pos+=sizeof(pThis->tFailServiceAddr.len);

		memcpy(tLV1024.value+pos, pThis->tFailServiceAddr.value, pThis->tFailServiceAddr.len);
		pos +=pThis->tFailServiceAddr.len;
 
		pThis->uPort = htons(pThis->uPort);
		memcpy(tLV1024.value+pos, &pThis->uPort, sizeof(pThis->uPort));
		pos+=sizeof(pThis->uPort);
 
		tLV1024.len = pos;
		return pos;
	}

		//请求接入管理应答:解压网络数据包到成员函数
	//参数：pData 收到的网络数据
	int toDecodeLOGINACCESSACK(LOGINACCESSACK*pThis, INT8 *pData)
	{
		INT32 pos=0;
		memset(pThis,0,sizeof(tagLOGINACCESSACK));

		pThis->ret = *pData;
		pos+=sizeof(pThis->ret);

		pThis->tRetDesc.len = *(pData+pos);
		pos+=sizeof(pThis->tRetDesc.len);

		memcpy(pThis->tRetDesc.value,pData+pos,pThis->tRetDesc.len);
		pos += pThis->tRetDesc.len;

		pThis->iTryTime = ntohs(*(INT16*)(pData+pos));
		pos += sizeof(pThis->iTryTime);

		pThis->tServiceAddr.len = *(pData+pos);
		pos+=sizeof(pThis->tServiceAddr.len);

		memcpy(pThis->tServiceAddr.value,pData+pos,pThis->tServiceAddr.len);
		pos += pThis->tServiceAddr.len;

		pThis->uPort = ntohs(*(INT16*)(pData+pos));
		pos += sizeof(pThis->uPort);

		pThis->UpgradeType = *(pData+pos);
		pos +=sizeof(pThis->UpgradeType);

		pThis->uUpgradeWaitTime = ntohs(*(INT16*)(pData+pos));
		pos += sizeof(pThis->uUpgradeWaitTime);
		
		pThis->isDeltaUpgrade = *(pData+pos);
		pos +=sizeof(pThis->isDeltaUpgrade);
		
		memcpy(pThis->szLatestVer, pData+pos, sizeof(pThis->szLatestVer));
		pos += sizeof(pThis->szLatestVer);
 
		pThis->tUpgradeFileUrl.len = *(pData+pos);
		pos+=sizeof(pThis->tUpgradeFileUrl.len);

		memcpy(pThis->tUpgradeFileUrl.value,pData+pos,pThis->tUpgradeFileUrl.len);
		pos += pThis->tUpgradeFileUrl.len;

		pThis->tLatestVerDesc.len = *(pData+pos);
		pos+=sizeof(pThis->tLatestVerDesc.len);

		memcpy(pThis->tLatestVerDesc.value,pData+pos,pThis->tLatestVerDesc.len);
		pos += pThis->tLatestVerDesc.len;

		return pos;
	}


	//解压全量状态数 
	int toDecodeTALLUserStatus(TALLUserStatus*pThis, UINT32 uBegID,UINT32 uGetNum,TGetStatusRsp* pData,UINT32* pEndUserID  )
	{
		UINT8 cStatus=0;
		pData->dwUserStatusNum=0;
		for(int i=(uBegID-pThis->uBegUserID) / 4; i < pThis->MAX_BYTE_BITMAP; i++)
		{
			for(int j=0; j < 4; j++)
			{
				cStatus=3;
				cStatus =cStatus& (pThis->Bitmap[i%pThis->MAX_BYTE_BITMAP] >> (j*2));
				pData->szUserStatus[pData->dwUserStatusNum].cStatus=cStatus;
				if (cStatus == 3)
				{
					pData->szUserStatus[pData->dwUserStatusNum].cLoginType = 1; //移动在线
					pData->szUserStatus[pData->dwUserStatusNum].cStatus = 1;
				}
				else if (cStatus != 0)
					pData->szUserStatus[pData->dwUserStatusNum].cLoginType = 3; //PC在线或离开

				if (cStatus != 0)
				{
					pData->szUserStatus[pData->dwUserStatusNum].dwUserID=pThis->uBegUserID+ 4*i +j;
					pData->dwUserStatusNum++;
				}
				*pEndUserID = pThis->uBegUserID+ 4*i +j;
				if(pData->dwUserStatusNum >= MAX_USERSTATUS_NUM || *pEndUserID >= pThis->uEndUserID)
					return pData->dwUserStatusNum;
			}
		}
		return 0;
	}