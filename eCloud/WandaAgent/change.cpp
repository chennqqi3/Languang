#include "change.h"

void hton_term_head(TERM_CMD_HEAD *p)
{
    p->wMsgLen = htons(p->wMsgLen);
    p->wCmdID  = htons(p->wCmdID);
    p->dwSeq = htonl(p->dwSeq);
}

void ntoh_term_head(TERM_CMD_HEAD *p)
{
    p->wMsgLen = ntohs(p->wMsgLen);
    p->wCmdID  = ntohs(p->wCmdID);
    p->dwSeq = ntohl(p->dwSeq);
}

void hton_term_compinfo(COMPINFO *p)
{
    p->dwCompID = htonl(p->dwCompID);
    p->dwEstablish_time = htonl(p->dwEstablish_time);
    p->dwUpdate_time = htonl(p->dwUpdate_time);
}

void ntoh_term_compinfo(COMPINFO *p)
{
    p->dwCompID = ntohl(p->dwCompID);
    p->dwEstablish_time = ntohl(p->dwEstablish_time);
    p->dwUpdate_time = ntohl(p->dwUpdate_time);
}

void hton_term_deptinfo(DEPTINFO *p)
{
    p->dwDeptID = htonl(p->dwDeptID);
    p->dwPID = htonl(p->dwPID);
    p->wSort = htons(p->wSort);
		p->dwCompID = htonl(p->dwCompID);
	p->dwUpdateTime = htonl(p->dwUpdateTime);
 
}

void ntoh_term_deptinfo(DEPTINFO *p)
{
    p->dwDeptID = ntohl(p->dwDeptID);
    p->dwPID = ntohl(p->dwPID);
    p->wSort = ntohs(p->wSort);
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUpdateTime = ntohl(p->dwUpdateTime);
 
}

void hton_userinfo(USERINFO *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_userinfo(USERINFO *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}


void hton_term_alive(ALIVE *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_alive(ALIVE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_employee(EMPLOYEE *p)
{
	hton_USERINFOExtend(&p->tUserExtend);
	hton_term_userinfo(&p->tUserInfo);

}

void ntoh_term_employee(EMPLOYEE *p)
{
    ntoh_USERINFOExtend(&p->tUserExtend);
	ntoh_term_userinfo(&p->tUserInfo);
}

void hton_term_getemployee(GETEMPLOYEEINFO *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->nType = htonl(p->nType);
}

void ntoh_term_getemployee(GETEMPLOYEEINFO *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->nType = ntohl(p->nType);
}

void hton_term_modiinfo(MODIINFO *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_modiinfo(MODIINFO *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_modiemployee(MODIEMPLOYEE *p)
{
    p->dwUserID = htonl(p->dwUserID);

    hton_term_employee(&p->sEmployee);
}

void ntoh_term_modiemployee(MODIEMPLOYEE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    ntoh_term_employee(&p->sEmployee);
}

void hton_term_modiemployeeAck(MODIEMPLOYEEACK *p)
{
    p->result = (RESULT)htonl(p->result);
}

void ntoh_term_modiemployeeAck(MODIEMPLOYEEACK *p)
{
    p->result = (RESULT)ntohl(p->result);
}

void hton_term_modiinfoAck(MODIINFOACK *p)
{
    p->result = (RESULT)htonl(p->result);
}

void ntoh_term_modiinfoAck(MODIINFOACK *p)
{
    p->result = (RESULT)ntohl(p->result);
}

void hton_term_getcompinfo(GETCOMPINFO *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwCompID = htonl(p->dwCompID);
}

void ntoh_term_getcompinfo(GETCOMPINFO *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwCompID = ntohl(p->dwCompID);
}

void hton_term_getdeptlist(GETDEPTLIST *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwCompID = htonl(p->dwCompID);
    p->dwLastUpdateTime = htonl(p->dwLastUpdateTime);
}

void ntoh_term_getdeptlist(GETDEPTLIST *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwCompID = ntohl(p->dwCompID);
    p->dwLastUpdateTime = ntohl(p->dwLastUpdateTime);
}

void hton_term_getuserlist(GETUSERLIST *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwCompID = htonl(p->dwCompID);
    p->dwLastUpdateTime = htonl(p->dwLastUpdateTime);
}

void ntoh_term_getuserlist(GETUSERLIST *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwCompID = ntohl(p->dwCompID);
    p->dwLastUpdateTime = ntohl(p->dwLastUpdateTime);
}

void hton_term_getuserdept(GETUSERDEPT *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwCompID = htonl(p->dwCompID);
    p->dwLastUpdateTime = htonl(p->dwLastUpdateTime);
}

void ntoh_term_getuserdept(GETUSERDEPT *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwCompID = ntohl(p->dwCompID);
    p->dwLastUpdateTime = ntohl(p->dwLastUpdateTime);
}

void hton_term_getuserstate(GETUSERSTATELIST *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwCompID = htonl(p->dwCompID);
}

void ntoh_term_getuserstate(GETUSERSTATELIST *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwCompID = ntohl(p->dwCompID);
}

void hton_term_creategroup(CREATEGROUP *p)
{
    int i = p->wUserNum;
    
    p->dwUserID = htonl(p->dwUserID);
    p->dwTime   = htonl(p->dwTime);
    p->wUserNum = htons(p->wUserNum);

    while (--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);
}

void ntoh_term_creategroup(CREATEGROUP *p)
{
    int i = 0;

    p->dwUserID = ntohl(p->dwUserID);
    p->dwTime   = ntohl(p->dwTime);
    p->wUserNum = ntohs(p->wUserNum);

    i = p->wUserNum;
    while (--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

void hton_term_modigroup(MODIGROUP *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwTime   = htonl(p->dwTime);
}

void ntoh_term_modigroup(MODIGROUP *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwTime   = ntohl(p->dwTime);
}

void hton_term_getgroupinfo(GETGROUPINFO *p)
{
    p->dwUserID = htonl(p->dwUserID);
}


void ntoh_term_getgroupinfo(GETGROUPINFO *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_sendsms(SENDMSG *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
    p->nSendTime = htonl(p->nSendTime);
    p->dwMsgLen = htons(p->dwMsgLen);
	p->dwSrcMsgID = htonl64(p->dwSrcMsgID);
}

void ntoh_term_sendsms(SENDMSG *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID = ntohl64(p->dwMsgID);
    p->nSendTime = ntohl(p->nSendTime);
    p->dwMsgLen = ntohs(p->dwMsgLen);
	p->dwSrcMsgID = ntohl64(p->dwSrcMsgID);
}

void hton_term_msgread(MSGREAD *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
    p->dwTime  = htonl(p->dwTime);
}

void ntoh_term_msgread(MSGREAD *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID = ntohl64(p->dwMsgID);
    p->dwTime  = ntohl(p->dwTime);
}

void hton_term_msgnoticeconfirm(MSGNOTICECONFIRM *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID    = htonl64(p->dwMsgID);
    p->dwMsgLen   = htonl(p->dwMsgLen);
}

void ntoh_term_msgnoticeconfirm(MSGNOTICECONFIRM *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID    = ntohl64(p->dwMsgID);
    p->dwMsgLen   = ntohl(p->dwMsgLen);
}

void hton_term_msgreadnotice(MSGREADNOTICE *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
    p->dwTime = htonl(p->dwTime);
}

void ntoh_term_msgreadnotice(MSGREADNOTICE *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID = ntohl64(p->dwMsgID);
    p->dwTime = ntohl(p->dwTime);
}

void hton_term_msgreadnoticeAck(MSGREADNOTICEACK *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
}

void ntoh_term_msgreadnoticeAck(MSGREADNOTICEACK *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID = ntohl64(p->dwMsgID);
}

void hton_term_sendbroad(SENDBROADCAST *p)
{
    int i = p->wRecverNum;

    p->dwUserID = htonl(p->dwUserID);
    p->wRecverNum = htons(p->wRecverNum);
    p->dwMsgID = htonl64(p->dwMsgID);
    p->dwMsgLen = htons(p->dwMsgLen);
    p->dwTime   = htonl(p->dwTime);
	p->dwSrcMsgID = htonl64(p->dwSrcMsgID);

    while (--i >= 0)
        p->aRecver[i].dwRecverID = htonl(p->aRecver[i].dwRecverID);
}

void ntoh_term_sendbroad(SENDBROADCAST *p)
{
    int i = 0;

    p->dwUserID = ntohl(p->dwUserID);
    p->wRecverNum = ntohs(p->wRecverNum);
    p->dwMsgID = ntohl64(p->dwMsgID);
    p->dwMsgLen = ntohs(p->dwMsgLen);
    p->dwTime   = ntohl(p->dwTime);
	p->dwSrcMsgID = ntohl64(p->dwSrcMsgID);

    i = p->wRecverNum;

    while(--i >= 0)
        p->aRecver[i].dwRecverID = ntohl(p->aRecver[i].dwRecverID);
}


void hton_term_modimember(MODIMEMBER *p)
{
    int i = p->wNum;

    p->dwUserID = htonl(p->dwUserID);
    p->dwTime   = htonl(p->dwTime);
    p->wNum = htons(p->wNum);
    while (--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);
}

void ntoh_term_modimember(MODIMEMBER *p)
{
    int i = 0;

    p->dwUserID = ntohl(p->dwUserID);
    p->dwTime   = ntohl(p->dwTime);
    p->wNum = ntohs(p->wNum);
    
    i = p->wNum;
    while (--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

////////
void hton_term_userinfo(USERINFO *p)
{
    p->dwUserID = htonl(p->dwUserID);
	p->dwUpdateTime = htonl(p->dwUpdateTime);
	p->dwBirth = htonl(p->dwBirth);
	p->dwHiredate = htonl(p->dwHiredate);
}

void ntoh_term_userinfo(USERINFO *p)
{
    p->dwUserID = ntohl(p->dwUserID);
	p->dwUpdateTime = ntohl(p->dwUpdateTime);
	p->dwBirth = ntohl(p->dwBirth);
	p->dwHiredate = ntohl(p->dwHiredate);
}

void hton_term_userdept(USERDEPT *p)
{
	p->dwUpdateTime = htonl(p->dwUpdateTime);
	p->wSort = htons(p->wSort);
    p->dwUserID = htonl(p->dwUserID);
    p->dwDeptID = htonl(p->dwDeptID);
	p->dwAreaID = htons(p->dwAreaID);
}

void ntoh_term_userdept(USERDEPT *p)
{
	p->dwUpdateTime = ntohl(p->dwUpdateTime);
	p->wSort = ntohs(p->wSort);
    p->dwUserID = ntohl(p->dwUserID);
    p->dwDeptID = ntohl(p->dwDeptID);
	p->dwAreaID = ntohs(p->dwAreaID);
}


void ntoh_timestamp_resp(TUpdateTimeStamp *p)
{
 
 	p->dwCompUpdateTime						= ntohl(p->dwCompUpdateTime); // ÆóÒµÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwDeptUpdateTime						= ntohl(p->dwDeptUpdateTime); // ÆóÒµ×éÖ¯¹¹¼Ü×îºó¸üÐÂÊ±¼ä
	p->dwUserUpdateTime						= ntohl(p->dwUserUpdateTime); // ÆóÒµÔ±¹¤ÁÐ±í×îºó¸üÐÂÊ±¼ä
	p->dwDeptUserUpdateTime					= ntohl(p->dwDeptUserUpdateTime); // ²¿ÃÅÓëÔ±¹¤×îºó¸üÐÂÊ±¼ä
	p->dwPersonalInfoUpdateTime				= ntohl(p->dwPersonalInfoUpdateTime);//×Ô¼ºµÄÐÅÏ¢×ÊÁÏ
	p->dwPersonalCommonContactUpdateTime	= ntohl(p->dwPersonalCommonContactUpdateTime);//×Ô¼ºµÄÂþÓÎ³£ÓÃÁªÏµÈËÐÅÏ¢×ÊÁÏ
	p->dwPersonalCommonDeptUpdateTime		= ntohl(p->dwPersonalCommonDeptUpdateTime);//×Ô¼ºµÄÂþÓÎ³£ÓÃµÄ³£ÓÃ²¿ÃÅÐÅÏ¢×ÊÁÏ
	p->dwPersonalAttentionUpdateTime		= ntohl(p->dwPersonalAttentionUpdateTime);//×Ô¼ºµÄÂþÓÎ¹Ø×¢ÈËÐÅÏ¢×ÊÁÏ
	p->dwGlobalCommonContactUpdateTime		= ntohl(p->dwGlobalCommonContactUpdateTime);//×Ô¼ºµÄÂþÓÎÈ±Ê¡µÄ³£ÓÃÁªÏµÈËÐÅÏ¢×ÊÁÏ
	p->dwOthersAvatarUpdateTime				= ntohl(p->dwOthersAvatarUpdateTime);//ÆäËûÈËµÄÍ·Ïñ¸üÐÂÊ±¼ä
	p->dwPersonalAvatarUpdateTime			= ntohl(p->dwPersonalAvatarUpdateTime);//±¾ÈËµÄÍ·Ïñ¸üÐÂÊ±¼ä
	p->dwRegularGroupUpdateTime				= ntohl(p->dwRegularGroupUpdateTime);//¹Ì¶¨ÈºÊ±´Á
	p->dwUserRankUpdateTime					= ntohl(p->dwUserRankUpdateTime); // ¼¶±ðÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwUserProUpdateTime					= ntohl(p->dwUserProUpdateTime);  // ÒµÎñÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwUserAreaUpdateTime					= ntohl(p->dwUserAreaUpdateTime); // µØÓòÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwSpecialListUpdatetime				= ntohl(p->dwSpecialListUpdatetime);			//ÌØÊâÓÃ»§ÁÐ±í×îºó¸üÐÂÊ±¼ä
	p->dwSpecialWhiteListUpdatetime			= ntohl(p->dwSpecialWhiteListUpdatetime);    //ÌØÊâÓÃ»§°×Ãûµ¥×îºó¸üÐÂÊ±¼ä
	p->nServerCurrentTime					= ntohl(p->nServerCurrentTime);   //·þÎñÆ÷Ê±¼ä  

}

void ntoh_term_login_resp(LOGINACK *p)
{
    //p->dwResult = (RESULT)ntohl(p->dwResult);
    p->dwSessionID = ntohl(p->dwSessionID);
	p->dwCompID = ntohl(p->dwCompID);
	p->uUserId = ntohl(p->uUserId);

	ntoh_timestamp_resp(&p->tTimeStamp);
   
	p->wPurview=ntohs(p->wPurview);
 
	for(int i=0; i< MAX_PURVIEW; i++)
	{
		p->mPurview[i].dwID = ntohl(p->mPurview[i].dwID);
		p->mPurview[i].dwParameter = ntohl(p->mPurview[i].dwParameter);
	}
	p->dwPersonalDisplay= ntohl(p->dwPersonalDisplay);
	p->dwPersonalEdit = ntohl(p->dwPersonalEdit);

	p->wGroupMaxMemberNum =ntohs(p->wGroupMaxMemberNum);
	p->wPCMaxSendFileSize = ntohs(p->wPCMaxSendFileSize);

	p->wPCTempSubscribeMaxNum = ntohs(p->wPCTempSubscribeMaxNum);
	p->wGetStatusMaxNum	=ntohs(p->wGetStatusMaxNum);
	p->wPCAliveMaxInterval =ntohs(p->wPCAliveMaxInterval);

	p->wMobileAliveMaxInterval =ntohs(p->wMobileAliveMaxInterval);
	p->wPCSMSMaxLength =ntohs(p->wPCSMSMaxLength);
	p->wMobileUploadRecentContact =ntohs(p->wMobileUploadRecentContact);
	p->wPCUploadRecentContact =ntohs(p->wPCUploadRecentContact);
	p->dwRobotInfoUpdatetime =ntohl(p->dwRobotInfoUpdatetime);
}

void hton_timestamp_resp(TUpdateTimeStamp *p)
{
 
 	p->dwCompUpdateTime						= htonl(p->dwCompUpdateTime); // ÆóÒµÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwDeptUpdateTime						= htonl(p->dwDeptUpdateTime); // ÆóÒµ×éÖ¯¹¹¼Ü×îºó¸üÐÂÊ±¼ä
	p->dwUserUpdateTime						= htonl(p->dwUserUpdateTime); // ÆóÒµÔ±¹¤ÁÐ±í×îºó¸üÐÂÊ±¼ä
	p->dwDeptUserUpdateTime					= htonl(p->dwDeptUserUpdateTime); // ²¿ÃÅÓëÔ±¹¤×îºó¸üÐÂÊ±¼ä
	p->dwPersonalInfoUpdateTime				= htonl(p->dwPersonalInfoUpdateTime);//×Ô¼ºµÄÐÅÏ¢×ÊÁÏ
	p->dwPersonalCommonContactUpdateTime	= htonl(p->dwPersonalCommonContactUpdateTime);//×Ô¼ºµÄÂþÓÎ³£ÓÃÁªÏµÈËÐÅÏ¢×ÊÁÏ
	p->dwPersonalCommonDeptUpdateTime		= htonl(p->dwPersonalCommonDeptUpdateTime);//×Ô¼ºµÄÂþÓÎ³£ÓÃµÄ³£ÓÃ²¿ÃÅÐÅÏ¢×ÊÁÏ
	p->dwPersonalAttentionUpdateTime		= htonl(p->dwPersonalAttentionUpdateTime);//×Ô¼ºµÄÂþÓÎ¹Ø×¢ÈËÐÅÏ¢×ÊÁÏ
	p->dwGlobalCommonContactUpdateTime		= htonl(p->dwGlobalCommonContactUpdateTime);//×Ô¼ºµÄÂþÓÎÈ±Ê¡µÄ³£ÓÃÁªÏµÈËÐÅÏ¢×ÊÁÏ
	p->dwOthersAvatarUpdateTime				= htonl(p->dwOthersAvatarUpdateTime);//ÆäËûÈËµÄÍ·Ïñ¸üÐÂÊ±¼ä
	p->dwPersonalAvatarUpdateTime			= htonl(p->dwPersonalAvatarUpdateTime);//±¾ÈËµÄÍ·Ïñ¸üÐÂÊ±¼ä
	p->dwRegularGroupUpdateTime				= htonl(p->dwRegularGroupUpdateTime);//¹Ì¶¨ÈºÊ±´Á
	p->dwUserRankUpdateTime					= htonl(p->dwUserRankUpdateTime); // ¼¶±ðÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwUserProUpdateTime					= htonl(p->dwUserProUpdateTime);  // ÒµÎñÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwUserAreaUpdateTime					= htonl(p->dwUserAreaUpdateTime); // µØÓòÐÅÏ¢×îºó¸üÐÂÊ±¼ä
	p->dwSpecialListUpdatetime				= htonl(p->dwSpecialListUpdatetime);			//ÌØÊâÓÃ»§ÁÐ±í×îºó¸üÐÂÊ±¼ä
	p->dwSpecialWhiteListUpdatetime			= htonl(p->dwSpecialWhiteListUpdatetime);    //ÌØÊâÓÃ»§°×Ãûµ¥×îºó¸üÐÂÊ±¼ä
	p->nServerCurrentTime					= htonl(p->nServerCurrentTime);   //·þÎñÆ÷Ê±¼ä  

}

void hton_term_login_resp(LOGINACK *p)
{
    //p->dwResult = (RESULT)htonl(p->dwResult);
    p->dwSessionID = htonl(p->dwSessionID);
	p->dwCompID = htonl(p->dwCompID);
	p->uUserId = htonl(p->uUserId);

	ntoh_timestamp_resp(&p->tTimeStamp);
   
	p->wPurview=htons(p->wPurview);
 
	for(int i=0; i< MAX_PURVIEW; i++)
	{
		p->mPurview[i].dwID = htonl(p->mPurview[i].dwID);
		p->mPurview[i].dwParameter = htonl(p->mPurview[i].dwParameter);
	}
	p->dwPersonalDisplay= htonl(p->dwPersonalDisplay);
	p->dwPersonalEdit = htonl(p->dwPersonalEdit);

	p->wGroupMaxMemberNum =htons(p->wGroupMaxMemberNum);
	p->wPCMaxSendFileSize = htons(p->wPCMaxSendFileSize);

	p->wPCTempSubscribeMaxNum = htons(p->wPCTempSubscribeMaxNum);
	p->wGetStatusMaxNum	=htons(p->wGetStatusMaxNum);
	p->wPCAliveMaxInterval =htons(p->wPCAliveMaxInterval);

	p->wMobileAliveMaxInterval =htons(p->wMobileAliveMaxInterval);
	p->wPCSMSMaxLength =htons(p->wPCSMSMaxLength);
	p->wMobileUploadRecentContact =htons(p->wMobileUploadRecentContact);
	p->wPCUploadRecentContact =htons(p->wPCUploadRecentContact);
	p->dwRobotInfoUpdatetime =htonl(p->dwRobotInfoUpdatetime);
}


void hton_term_logout_req(LOGOUT *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_logout_req(LOGOUT *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_logout_resp(LOGOUTACK *p)
{
    p->result = (RESULT)htonl(p->result);
}

void ntoh_term_logout_resp(LOGOUTACK *p)
{
    p->result = (RESULT)ntohl(p->result);
}

void hton_term_userstatus_notice(USERSTATUSNOTICE *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_userstatus_notice(USERSTATUSNOTICE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_modiinfonotice(MODIINFONOTICE *p)
{
    p->dwUserID = htonl(p->dwUserID);
    hton_term_employee(&p->sEmployee);
}

void ntoh_term_modiinfonotice(MODIINFONOTICE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    ntoh_term_employee(&p->sEmployee);
}

void hton_term_GetCompInfoAck(GETCOMPINFOACK *p)
{
    p->result = (RESULT)htonl(p->result);
    hton_term_compinfo(&p->sCompInfo);
}

void ntoh_term_GetCompInfoAck(GETCOMPINFOACK *p)
{
    p->result = (RESULT)ntohl(p->result);
    ntoh_term_compinfo(&p->sCompInfo);
}

void hton_term_GetDeptListAck(GETDEPTLISTACK *p)
{
    p->nPacketLen = htons(p->nPacketLen);
    p->result = (RESULT)htonl(p->result);
    p->wCurrPage = htons(p->wCurrPage);
    p->wCurrNum  = htons(p->wCurrNum);
}

void ntoh_term_GetDeptListAck(GETDEPTLISTACK *p)
{
    p->nPacketLen = ntohs(p->nPacketLen);
    p->result = (RESULT)ntohl(p->result);
    p->wCurrPage = ntohs(p->wCurrPage);
    p->wCurrNum = ntohs(p->wCurrNum);
}

void hton_term_GetUserListAck(GETUSERLISTACK *p)
{
    p->nPacketLen = htons(p->nPacketLen);
    p->result = (RESULT)htonl(p->result);
    p->wCurrPage = htons(p->wCurrPage);
    p->wCurrNum = htons(p->wCurrNum);
}

void ntoh_term_GetUserListAck(GETUSERLISTACK *p)
{
    p->nPacketLen = ntohs(p->nPacketLen);
    p->result = (RESULT)ntohl(p->result);
    p->wCurrPage = ntohs(p->wCurrPage);
    p->wCurrNum = ntohs(p->wCurrNum);
}

void hton_term_GetUserDeptAck(GETUSERDEPTACK *p)
{
    p->nPacketLen = htons(p->nPacketLen);
    p->result     = (RESULT)htonl(p->result);
    p->wCurrPage  = htons(p->wCurrPage);
    p->wCurrNum   = htons(p->wCurrNum);
}

void ntoh_term_GetUserDeptAck(GETUSERDEPTACK *p)
{
    p->nPacketLen = ntohs(p->nPacketLen);
    p->result     = (RESULT)ntohl(p->result);
    p->wCurrPage  = ntohs(p->wCurrPage);
    p->wCurrNum   = ntohs(p->wCurrNum);
}

void hton_term_GetEmployeeAck(GETEMPLOYEEACK *p)
{
    p->result = (RESULT)htonl(p->result);
    p->nType = htonl(p->nType);
	p->dwUserID = htonl(p->dwUserID);
   // hton_term_employee(&p->sEmployee);
}

void ntoh_term_GetEmployeeAck(GETEMPLOYEEACK *p)
{
    p->result = (RESULT)ntohl(p->result);
    p->nType =  ntohl(p->nType);
	p->dwUserID = ntohl(p->dwUserID);
    //ntoh_term_employee(&p->sEmployee);
}

void hton_term_userstate(USERSTATE *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_userstate(USERSTATE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_GetUserStateAck(GETUSERSTATELISTACK *p)
{
    int i = p->wCurrNum;
    p->result = (RESULT)htonl(p->result);
    p->wCurrPage = htons(p->wCurrPage);
    p->wCurrNum = htons(p->wCurrNum);

    while(--i >= 0)
        hton_term_userstate(&p->aUserState[i]);
}

void ntoh_term_GetUserStateAck(GETUSERSTATELISTACK *p)
{
    int i = 0;
    p->result = (RESULT)ntohl(p->result);
    p->wCurrPage = ntohs(p->wCurrPage);
    p->wCurrNum = ntohs(p->wCurrNum);
    
    i = p->wCurrNum;

    while(--i >= 0)
        ntoh_term_userstate(&p->aUserState[i]);
}

void hton_term_CreateGroupAck(CREATEGROUPACK *p)
{
    int i = p->wUserNum;
    p->result = (RESULT)htonl(p->result);
    p->dwTime = htonl(p->dwTime);
    p->wUserNum = htons(p->wUserNum);

    while(--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);
}

void ntoh_term_CreateGroupAck(CREATEGROUPACK *p)
{
    int i = 0;
    p->result = (RESULT)ntohl(p->result);
    p->dwTime = ntohl(p->dwTime);
    p->wUserNum = ntohs(p->wUserNum);

    i = p->wUserNum;
    while(--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

void hton_term_ModiGroupNotice(MODIGROUPNOTICE *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwTime   = htonl(p->dwTime);
}

void ntoh_term_ModiGroupNotice(MODIGROUPNOTICE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwTime   = ntohl(p->dwTime);
}

void hton_term_CreateGroupNotice(CREATEGROUPNOTICE *p)
{
    int i = p->wUserNum;
    
    p->dwUserID = htonl(p->dwUserID);
    p->dwTime   = htonl(p->dwTime);
    p->wUserNum = htons(p->wUserNum);

    while (--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);
}

void ntoh_term_CreateGroupNotice(CREATEGROUPNOTICE *p)
{
    int i = 0;

    p->dwUserID = ntohl(p->dwUserID);
    p->dwTime   = ntohl(p->dwTime);
    p->wUserNum = ntohs(p->wUserNum);

    i = p->wUserNum;
    while (--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

void hton_term_ModiGroupAck(MODIGROUPACK *p)
{
    p->result = (RESULT)htonl(p->result);
    p->dwTime = htonl(p->dwTime);
}

void ntoh_term_ModiGroupAck(MODIGROUPACK *p)
{
    p->result = (RESULT)ntohl(p->result);
    p->dwTime = ntohl(p->dwTime);
}
void hton_term_GetGroupAck(GETGROUPINFOACK *p)
{
    int i = p->wNum;
    p->result = (RESULT)htonl(p->result);
    p->dwCreaterID = htonl(p->dwCreaterID);
    p->dwTime      = htonl(p->dwTime);
    p->wNum = htons(p->wNum);

    while(--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);
}
void ntoh_term_GetGroupAck(GETGROUPINFOACK *p)
{
    int i = 0;
    p->result = (RESULT)ntohl(p->result);
    p->dwCreaterID = ntohl(p->dwCreaterID);
    p->dwTime      = ntohl(p->dwTime);
    p->wNum = ntohs(p->wNum);

    i = p->wNum;
    while(--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}
void hton_term_ModiMemberAck(MODIMEMBERACK *p)
{
    int i = p->wNum;
    p->result = (RESULT)htonl(p->result);
    p->dwTime = htonl(p->dwTime);
    p->wNum = htons(p->wNum);

    while (--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);
}
void ntoh_term_ModiMemberAck(MODIMEMBERACK *p)
{
    int i = 0;
    p->result = (RESULT)ntohl(p->result);
    p->dwTime = ntohl(p->dwTime);
    p->wNum = ntohs(p->wNum);

    i = p->wNum;
    while (--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

void hton_term_ModiMemberNotice(MODIMEMBERNOTICE *p)
{
    int i = p->wNum;

    p->dwModiID = htonl(p->dwModiID);
    p->dwTime   = htonl(p->dwTime);
    p->wNum = htons(p->wNum);
    while (--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);
}

void ntoh_term_ModiMemberNotice(MODIMEMBERNOTICE *p)
{
    int i = 0;

    p->dwModiID = ntohl(p->dwModiID);
    p->dwTime   = ntohl(p->dwTime);
    p->wNum     = ntohs(p->wNum);
    
    i = p->wNum;
    while (--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

void hton_term_SendMsgAck(SENDMSGACK *p)
{
    p->result = (RESULT)htonl(p->result);
    p->dwMsgID = htonl64(p->dwMsgID);
}

void ntoh_term_SendMsgAck(SENDMSGACK *p)
{
    p->result = (RESULT)ntohl(p->result);
    p->dwMsgID = ntohl64(p->dwMsgID);
}

void hton_term_MsgNotice(MSGNOTICE *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID    = htonl64(p->dwMsgID);
    p->dwMsgLen   = htons(p->dwMsgLen);
    p->dwSendTime = htonl(p->dwSendTime);
    p->dwGroupTime  = htonl(p->dwGroupTime);
    p->nOffMsgTotal = htons(p->nOffMsgTotal);
    p->nOffMsgSeq   = htons(p->nOffMsgSeq);
	p->dwSrcMsgID   = htonl64(p->dwSrcMsgID);
	p->dwNetID		= htonl(p->dwNetID);
}

void ntoh_term_MsgNotice(MSGNOTICE *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID    = ntohl64(p->dwMsgID);
    p->dwMsgLen   = ntohs(p->dwMsgLen);
    p->dwSendTime = ntohl(p->dwSendTime);
    p->dwGroupTime  = ntohl(p->dwGroupTime);
    p->nOffMsgTotal = ntohs(p->nOffMsgTotal);
    p->nOffMsgSeq   = ntohs(p->nOffMsgSeq);
	p->dwSrcMsgID   = ntohl64(p->dwSrcMsgID);
	p->dwNetID		= ntohl(p->dwNetID);
}

void hton_term_MsgNoticeAck(MSGNOTICEACK *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwMsgID  = htonl64(p->dwMsgID);
	p->dwNetID = htonl(p->dwNetID);
}

void ntoh_term_MsgNoticeAck(MSGNOTICEACK *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwMsgID = ntohl64(p->dwMsgID);
	p->dwNetID = ntohl(p->dwNetID);
}

void hton_term_MsgReadAck(MSGREADACK *p)
{
    p->result = (RESULT)htonl(p->result);
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
}

void ntoh_term_MsgReadAck(MSGREADACK *p)
{
    p->result = (RESULT)ntohl(p->result);
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID = ntohl64(p->dwMsgID);
}

void hton_term_MsgReadNotice(MSGREADNOTICE *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
    p->dwTime = htonl(p->dwTime);
}

void ntoh_term_MsgReadNotice(MSGREADNOTICE *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID = ntohl64(p->dwMsgID);
    p->dwTime = ntohl(p->dwTime);
}

void hton_term_MsgReadNoticeAck(MSGREADNOTICEACK *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
}

void ntoh_term_MsgReadNoticeAck(MSGREADNOTICEACK *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID = ntohl64(p->dwMsgID);
}

void hton_term_SendBroadAck(SENDBROADCASTACK *p)
{
    p->result = (RESULT)htonl(p->result);
    p->dwMsgID = htonl64(p->dwMsgID);
}

void ntoh_term_SendBroadAck(SENDBROADCASTACK *p)
{
    p->result = (RESULT)ntohl(p->result);
    p->dwMsgID = ntohl64(p->dwMsgID);
}

void hton_term_BroadNotice(BROADCASTNOTICE *p)
{
    p->dwSenderID = htonl(p->dwSenderID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID    = htonl64(p->dwMsgID);
    p->dwMsgLen   = htons(p->dwMsgLen);
    p->dwSendTime = htonl(p->dwSendTime);
	p->dwSrcMsgID = htonl64(p->dwSrcMsgID);
}

void ntoh_term_BroadNotice(BROADCASTNOTICE *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID    = ntohl64(p->dwMsgID);
    p->dwMsgLen   = ntohs(p->dwMsgLen);
    p->dwSendTime = ntohl(p->dwSendTime);
	p->dwSrcMsgID = ntohl64(p->dwSrcMsgID);
}

void hton_term_checktime_req(CHECK_TIME_REQ *p)
{
	p->dwSerial = htonl(p->dwSerial);
}

void ntoh_term_checktime_resp(CHECK_TIME_RESP *p)
{
    p->dwSerial = ntohl(p->dwSerial);
    p->timeNow  = ntohl(p->timeNow);
}


void hton_term_getoffline_req(GET_OFFLINE_REQ *p)
{
	p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_getoffline_resp(GET_OFFLINE_RESP *p)
{
    p->dwOfflineMsgCount = ntohl(p->dwOfflineMsgCount);
}


void hton_term_refusegroup_req(REFUSE_GROUPMSG_REQ *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_refusegroup_resp(REFUSE_GROUPMSG_REQ *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

UINT64  htonl64(UINT64  host)   
{   

UINT64   ret = 0;   
unsigned long   high,low;
low   =   host & 0xFFFFFFFF;
high   =  (host >> 32) & 0xFFFFFFFF;
low   =   htonl(low);   
high   =   htonl(high);   
ret   =   low;
ret   <<= 32;   
ret   |=   high;   
return   ret;   
}

UINT64  ntohl64(UINT64   host)   
{   
UINT64   ret = 0;   
unsigned long   high,low;
low   =   host & 0xFFFFFFFF;
high   =  (host >> 32) & 0xFFFFFFFF;
low   =   ntohl(low);   
high   =   ntohl(high);   
ret   =   low;
ret   <<= 32;   
ret   |=   high;   
return   ret;   
}

void hton_term_QuitGroupreq(QUITGROUP *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_QuitGroupreq(QUITGROUP *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_QuitGroupNotice(QUITGROUPNOTICE *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwTime = htonl(p->dwTime);
}

void ntoh_term_QuitGroupNotice(QUITGROUPNOTICE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwTime   = ntohl(p->dwTime);
}

void hton_term_resetselfinfo_req(RESETSELFINFO *p)
{
    p->dwUserID = htonl(p->dwUserID);
    int i = 0;
    i = p->cSigleNum;
    while(--i >= 0)
        p->dwDestUserID[i] = htonl(p->dwDestUserID[i]);
}

void ntoh_term_resetselfinfo_req(RESETSELFINFO *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    int i = 0;
    i = p->cSigleNum;
    while(--i >= 0)
        p->dwDestUserID[i] = ntohl(p->dwDestUserID[i]);
}

void hton_term_resetselfinfo_notice(RESETSELFINFONOTICE *p)
{
    p->dwUserID = htonl(p->dwUserID);
}

void ntoh_term_resetselfinfo_notice(RESETSELFINFONOTICE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
}

void hton_term_CreateSchedule(CREATESCHEDULE *p)
{
    p->dwUserID = htonl(p->dwUserID);
	p->dwBeginTime = htonl(p->dwBeginTime);
	p->dwEndTime = htonl(p->dwEndTime);
	
    int i = 0;
    i = p->wUserNum;
    while(--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);

	p->wUserNum = htons(p->wUserNum);
}

void ntoh_term_CreateSchedule(CREATESCHEDULE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
	p->dwBeginTime = ntohl(p->dwBeginTime);
	p->dwEndTime = ntohl(p->dwEndTime);
	p->wUserNum = ntohs(p->wUserNum);
	
    int i = 0;
    i = p->wUserNum;
    while(--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

void hton_term_CreateScheduleAck(CREATESCHEDULEACK *p)
{
	p->result = (RESULT)htonl(p->result);
}

void ntoh_term_CreateScheduleAck(CREATESCHEDULEACK *p)
{
	p->result = (RESULT)ntohl(p->result);
}

void hton_term_CreateScheduleNotice(CREATESCHEDULENOTICE *p)
{
    p->dwUserID = htonl(p->dwUserID);
	p->dwBeginTime = htonl(p->dwBeginTime);
	p->dwEndTime = htonl(p->dwEndTime);	

    int i = 0;
    i = p->wUserNum;
    while(--i >= 0)
        p->aUserID[i] = htonl(p->aUserID[i]);

	p->wUserNum = htons(p->wUserNum);
}

void ntoh_term_CreateScheduleNotice(CREATESCHEDULENOTICE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
	p->dwBeginTime = ntohl(p->dwBeginTime);
	p->dwEndTime = ntohl(p->dwEndTime);
	p->wUserNum = ntohs(p->wUserNum);

    int i = 0;
    i = p->wUserNum;
    while(--i >= 0)
        p->aUserID[i] = ntohl(p->aUserID[i]);
}

void hton_term_GETDATALISTTYPE(GETDATALISTTYPE *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwCompID = htonl(p->dwCompID);
	p->dwLastUpdateTimeDept     = htonl(p->dwLastUpdateTimeDept);
	p->dwLastUpdateTimeDeptUser = htonl(p->dwLastUpdateTimeDeptUser);
	p->dwLastUpdateTimeUser     = htonl(p->dwLastUpdateTimeUser);
}
void ntoh_term_GETDATALISTTYPE(GETDATALISTTYPE *p)
{
    p->dwUserID = ntohl(p->dwUserID);
    p->dwCompID = ntohl(p->dwCompID);
	p->dwLastUpdateTimeDept     = ntohl(p->dwLastUpdateTimeDept);
	p->dwLastUpdateTimeDeptUser = ntohl(p->dwLastUpdateTimeDeptUser);
	p->dwLastUpdateTimeUser     = ntohl(p->dwLastUpdateTimeUser);
}

void hton_term_GETDATALISTTYPEACK(GETDATALISTTYPEACK *p)
{
    p->nPacketLen = htons(p->nPacketLen);
    p->result     = (RESULT)htonl(p->result);
	p->dwLastUpdateTimeDept     = htonl(p->dwLastUpdateTimeDept);
	p->dwLastUpdateTimeDeptuser = htonl(p->dwLastUpdateTimeDeptuser);
	p->dwLastUpdateTimeUser     = htonl(p->dwLastUpdateTimeUser);
}

void ntoh_term_GETDATALISTTYPEACK(GETDATALISTTYPEACK *p)
{
    p->nPacketLen = ntohs(p->nPacketLen);
    p->result     = (RESULT)ntohl(p->result);
	p->dwLastUpdateTimeDept     = ntohl(p->dwLastUpdateTimeDept);
	p->dwLastUpdateTimeDeptuser = ntohl(p->dwLastUpdateTimeDeptuser);
	p->dwLastUpdateTimeUser     = ntohl(p->dwLastUpdateTimeUser);
}

void hton_term_userstatusset_notice(USERSTATUSSETNOTICE *p)
{
    p->wCurrNum = htons(p->wCurrNum);
}

void ntoh_term_userstatusset_notice(USERSTATUSSETNOTICE *p)
{
    p->wCurrNum = ntohs(p->wCurrNum);
}

void hton_term_complsttime_notice(COMPLASTTIMENOTICE *p)
{
    p->dwCompID = htonl(p->dwCompID);
    p->dwDeptUpdateTime = htonl(p->dwDeptUpdateTime);
    p->dwDeptUserUpdateTime = htonl(p->dwDeptUserUpdateTime);
    p->dwUserUpdateTime = htonl(p->dwUserUpdateTime);
    p->vgts = htonl(p->vgts);
}

void ntoh_term_complsttime_notice(COMPLASTTIMENOTICE *p)
{
    p->dwCompID = ntohl(p->dwCompID);
    p->dwDeptUpdateTime = ntohl(p->dwDeptUpdateTime);
    p->dwDeptUserUpdateTime = ntohl(p->dwDeptUserUpdateTime);
    p->dwUserUpdateTime = ntohl(p->dwUserUpdateTime);
    p->vgts = ntohl(p->vgts);
}


void hton_ios_background_req(IOSBACKGROUNDREQ *p)
{
	p->dwPushMsgCount	= htonl(p->dwPushMsgCount);
	p->dwUserID		= htonl(p->dwUserID);

}

void ntoh_ios_background_req(IOSBACKGROUNDREQ *p)
{
	p->dwPushMsgCount	= ntohl(p->dwPushMsgCount);
	p->dwUserID		= ntohl(p->dwUserID);
}

void hton_getuserrpa_req(GETUSERRPA *p)
{
	p->dwUserID	    = htonl(p->dwUserID);
	p->dwCompID	    = htonl(p->dwCompID);
	p->dwLastUpdateTime	    = htonl(p->dwLastUpdateTime);
}

void ntoh_getuserrpa_req(GETUSERRPA *p)
{
	p->dwUserID	    = ntohl(p->dwUserID);
	p->dwCompID	    = ntohl(p->dwCompID);
	p->dwLastUpdateTime	    = ntohl(p->dwLastUpdateTime);
}

void hton_getuserrpa_ack(GETUSERPAASK *p)
{
	p->nPacketLen	= htons(p->nPacketLen);
	p->result	    = (RESULT)htonl(p->result);
	p->wCurrPage	= htons(p->wCurrPage);
	p->wCurrNum	    = htons(p->wCurrNum);
}

void ntoh_getuserrpa_ack(GETUSERPAASK *p)
{
	p->nPacketLen	= ntohs(p->nPacketLen);
	p->result	    = (RESULT)ntohl(p->result);
	p->wCurrPage	= ntohs(p->wCurrPage);
	p->wCurrNum	    = ntohs(p->wCurrNum);
}


void ntoh_GETSPECIALLISTACK(GETSPECIALLISTACK*p)
{
	p->wSpecialNum	= ntohs(p->wSpecialNum);
	p->wWhiteNum	= ntohs(p->wWhiteNum);
	p->result	    = (RESULT)ntohl(p->result);
	p->nSpecialTme	= ntohl(p->nSpecialTme);

	for(int i=0; i< p->wSpecialNum; i++)
	{
		p->mSpecialList[i].dwSpecialID = ntohl(p->mSpecialList[i].dwSpecialID );
	}
	for(int j=0; j< p->wWhiteNum; j++)
	{
		p->mWhiteList[j].dwSpecialID= ntohl(p->mWhiteList[j].dwSpecialID );
		p->mWhiteList[j].dwWhiteID	= ntohl(p->mWhiteList[j].dwWhiteID );
		p->mWhiteList[j].nWhiteTime = ntohl(p->mWhiteList[j].nWhiteTime );
	}
	return ;
}

//void hton_GETSPECIALLISTACK(GETSPECIALLISTACK*p)
//{
//	
//	p->result	    = (RESULT)htonl(p->result);
//	p->nTimeStamp	= htonl(p->nTimeStamp);
//
//	for(int i=0; i< p->wBlcakListNum; i++)
//	{
//		p->szBlackList[i].dwSpecialID = htonl(p->szBlackList[i].dwSpecialID );
//	}
//	p->wBlcakListNum = htons(p->wBlcakListNum);
//	return ;
//}

void hton_MODISPECIALLISTNOTICE(MODISPECIALLISTNOTICE*p)
{
	p->nSpecialTme = htonl(p->nSpecialTme);
//	p->nWhiteTime = htonl(p->nWhiteTime);
   
	p->dwMsgID = htonl64(p->dwMsgID);

	for(int i=0; i< p->wSpecialNum; i++)
	{
		p->mSpecialList[i].dwSpecialID =htonl(p->mSpecialList[i].dwSpecialID);
	}
	for(int j=0; j< p->wWhiteNum; j++)
	{
		p->mWhiteList[j].dwWhiteID =htonl(p->mWhiteList[j].dwWhiteID);
        p->mWhiteList[j].dwSpecialID=htonl(p->mWhiteList[j].dwSpecialID);
        p->mWhiteList[j].nWhiteTime=htonl(p->mWhiteList[j].nWhiteTime);
	}

	p->wSpecialNum =htons(p->wSpecialNum);
	p->wWhiteNum =htons(p->wWhiteNum);
}

 

void ntoh_MODISPECIALLISTNOTICE(MODISPECIALLISTNOTICE*p)
{
	p->dwMsgID		= ntohl64(p->dwMsgID);
	p->nSpecialTme	= ntohl(p->nSpecialTme);
	p->wSpecialNum	= ntohs(p->wSpecialNum);
	p->wWhiteNum	= ntohs(p->wWhiteNum);

	for(int i=0; i< p->wSpecialNum; i++)
	{
		p->mSpecialList[i].dwSpecialID =ntohl(p->mSpecialList[i].dwSpecialID);
	}
	for(int j=0; j< p->wWhiteNum; j++)
	{
		p->mWhiteList[j].dwWhiteID	= ntohl(p->mWhiteList[j].dwWhiteID);
        p->mWhiteList[j].dwSpecialID= ntohl(p->mWhiteList[j].dwSpecialID);
        p->mWhiteList[j].nWhiteTime	= ntohl(p->mWhiteList[j].nWhiteTime);
    }

}



void hton_ModiSpecialListNoticeAck(MODISPECIALLISTNOTICEACK* p)
{
	p->dwUserID = htonl(p->dwUserID);
	p->dwMsgID  = htonl64(p->dwMsgID);
	p->iRetcode = htons(p->iRetcode);
}
void ntoh_ModiSpecialListNoticeAck(MODISPECIALLISTNOTICEACK* p)
{
	p->dwUserID = ntohl(p->dwUserID);
	p->dwMsgID  = ntohl64(p->dwMsgID);
	p->iRetcode = ntohs(p->iRetcode);

}

void hton_TGetStatusReq_req(TGetStatusReq* p)
{

	p->dwCompID = htonl(p->dwCompID);
	p->uUserId=htonl(p->uUserId);
	for(int i=0; i< p->nUserNum; i++)
	{
		p->aUserId[i] = htonl(p->aUserId[i]);
	}
	p->nUserNum = htons(p->nUserNum);

}
 

void ntoh_term_THead(THead *p)
{
	p->wPackageBodyLen	= ntohs(p->wPackageBodyLen);
	p->dwSrcId		= ntohl(p->dwSrcId);
	p->dwDstId		= ntohl(p->dwDstId);
	p->dwSendTime	= ntohl(p->dwSendTime);
	p->dwMsgId		= ntohl64(p->dwMsgId);
	p->dwCompId		= ntohl(p->dwCompId);
}
void hton_term_THead(THead *p)
{
	p->wPackageBodyLen	= htons(p->wPackageBodyLen);
	p->dwSrcId		= htonl(p->dwSrcId);
	p->dwDstId		= htonl(p->dwDstId);
	p->dwSendTime	= htonl(p->dwSendTime);
	p->dwMsgId		= htonl64(p->dwMsgId);
	p->dwCompId		= htonl(p->dwCompId);
}

void ntoh_term_SUBSCRIBER_REQ(SUBSCRIBER_REQ *p)
{
	ntoh_term_THead(&p->mPackageHead);
	p->wNum = ntohs(p->wNum);
	int i = p->wNum;
	while(--i >= 0)
	{
		p->dwIdList[i] = ntohl(p->dwIdList[i]);
	}
}
void hton_term_SUBSCRIBER_REQ(SUBSCRIBER_REQ *p)
{
	hton_term_THead(&p->mPackageHead);
	int i = p->wNum;
	p->wNum = htons(p->wNum);
	while(--i >= 0)
	{
		p->dwIdList[i] = htonl(p->dwIdList[i]);
	}
}



void ntoh_SUBSCRIBER_ACK(SUBSCRIBER_ACK *p)
{
	ntoh_term_THead(&p->mPackageHead);
	int num=0;
	for (unsigned int j = 0; j< sizeof(p->mUserStatus.wNum) / sizeof(p->mUserStatus.wNum[0]); j++)
	{
		p->mUserStatus.wNum[j] = ntohs(p->mUserStatus.wNum[j]);
		num +=p->mUserStatus.wNum[j] ;

	}
	
	for(int i=0; i< num; i++)
	{
		p->mUserStatus.dwUserID[i]=ntohl(p->mUserStatus.dwUserID[i]);
	}


}

void hton_SUBSCRIBER_ACK(SUBSCRIBER_ACK *p)
{
	hton_term_THead(&p->mPackageHead);
int num=0;
	for(unsigned int j=0; j< sizeof(p->mUserStatus.wNum)/sizeof(p->mUserStatus.wNum[0]); j++)
	{
		num +=p->mUserStatus.wNum[j] ;
	}
	
	for(int i=0; i< num; i++)
	{
		p->mUserStatus.dwUserID[i]=htonl(p->mUserStatus.dwUserID[i]);
	}

	for (unsigned int j = 0; j< sizeof(p->mUserStatus.wNum) / sizeof(p->mUserStatus.wNum[0]); j++)
	{
		p->mUserStatus.wNum[j] = htons(p->mUserStatus.wNum[j]);
	}
}


void ntoh_TJson(TJson*p)
{
	
	ntoh_term_THead(&p->mPackageHead);
}
void hton_TJson(TJson*p)
{
	hton_term_THead(&p->mPackageHead);
}


void ntoh_term_ROAMDATASYNC(ROAMDATASYNC *p)
{
	p->dwUserid = ntohl(p->dwUserid);
	p->dwCompid = ntohl(p->dwCompid);
	p->dwUpdatetime = ntohl(p->dwUpdatetime);
}
void hton_term_ROAMDATASYNC(ROAMDATASYNC *p)
{
	p->dwUserid = htonl(p->dwUserid);
	p->dwCompid = htonl(p->dwCompid);
	p->dwUpdatetime = htonl(p->dwUpdatetime);
}

void ntoh_term_ROAMDATAMODI(ROAMDATAMODI *p)
{
	p->dwUserid = ntohl(p->dwUserid);
	p->dwCompid = ntohl(p->dwCompid);
	p->wNum = ntohs(p->wNum);
	int i = p->wNum;
	while(--i >= 0)
	{
		p->dwUsersList[i] = ntohl(p->dwUsersList[i]);
	}
}
void hton_term_ROAMDATAMODI(ROAMDATAMODI *p)
{
	int i = p->wNum;
	p->dwUserid = htonl(p->dwUserid);
	p->dwCompid = htonl(p->dwCompid);
	p->wNum = htons(p->wNum);
	while(--i >= 0)
	{
		p->dwUsersList[i] = htonl(p->dwUsersList[i]);
	}
}


void ntoh_term_ROAMDATASYNCACK(ROAMDATASYNCACK *p)
{
	p->dwUserid = ntohl(p->dwUserid);
	p->wNum = ntohs(p->wNum);
	int i = p->wNum;
	while(--i >= 0)
	{
		p->dwUsersList[i] = ntohl(p->dwUsersList[i]);
	}
}
void hton_term_ROAMDATASYNCACK(ROAMDATASYNCACK *p)
{
	int i = p->wNum;
	p->dwUserid = htonl(p->dwUserid);
	p->wNum = htons(p->wNum);
	while(--i >= 0)
	{
		p->dwUsersList[i] = htonl(p->dwUsersList[i]);
	}
}

void ntoh_term_ROAMDATAMODIACK(ROAMDATAMODIACK *p)
{
	p->dwUserid = ntohl(p->dwUserid);
	p->dwUpdatetime = ntohl(p->dwUpdatetime);

	if (1 == p->cResponseType || 3 == p->cResponseType)
	{
		int j =0;
		for (int i = 0; i < 4; i++)
		{
			p->tUserStatus.wNum[i] = ntohs(p->tUserStatus.wNum[i]);
			j += p->tUserStatus.wNum[i];
		}
		while(--j >= 0)
		{
			p->tUserStatus.dwUserID[j] = ntohl(p->tUserStatus.dwUserID[j]);
		}
	}
	else if (2 == p->cResponseType)
	{
		p->tDeptlist.wNum = ntohs(p->tDeptlist.wNum);

		int i = p->tDeptlist.wNum;
		while(--i >= 0)
		{
			p->tDeptlist.dwDept[i] = ntohl(p->tDeptlist.dwDept[i]);
		}
	}
}
void hton_term_ROAMDATAMODIACK(ROAMDATAMODIACK *p)
{

	p->dwUserid = htonl(p->dwUserid);
	p->dwUpdatetime = htonl(p->dwUpdatetime);


	if (1 == p->cResponseType || 3 == p->cResponseType)
	{
		int j =0;
		for (int i = 0; i < 4; i++)
		{
			j += p->tUserStatus.wNum[i];
			p->tUserStatus.wNum[i] = htons(p->tUserStatus.wNum[i]);
		}
		while(--j >= 0)
		{
			p->tUserStatus.dwUserID[j] = htonl(p->tUserStatus.dwUserID[j]);
		}
	}
	else if (2 == p->cResponseType)
	{
		int i = p->tDeptlist.wNum;

		p->tDeptlist.wNum = htons(p->tDeptlist.wNum);
		while(--i >= 0)
		{
			p->tDeptlist.dwDept[i] = htonl(p->tDeptlist.dwDept[i]);
		}
	}
}


void ntoh_term_ROAMDATAMODINOTICE(ROAMDATAMODINOTICE *p)
{
	p->dwUserid = ntohl(p->dwUserid);
	p->dwUpdatetime = ntohl(p->dwUpdatetime);

	if (1 == p->cResponseType || 3 == p->cResponseType)
	{
		int j =0;
		for (int i = 0; i < 4; i++)
		{
			p->tUserStatus.wNum[i] = ntohs(p->tUserStatus.wNum[i]);
			j += p->tUserStatus.wNum[i];
		}
		while(--j >= 0)
		{
			p->tUserStatus.dwUserID[j] = ntohl(p->tUserStatus.dwUserID[j]);
		}
	}
	else if (2 == p->cResponseType)
	{
		p->tDeptlist.wNum = ntohs(p->tDeptlist.wNum);

		int i = p->tDeptlist.wNum;
		while(--i >= 0)
		{
			p->tDeptlist.dwDept[i] = ntohl(p->tDeptlist.dwDept[i]);
		}
	}
}
void hton_term_ROAMDATAMODINOTICE(ROAMDATAMODINOTICE *p)
{
	p->dwUserid = htonl(p->dwUserid);
	p->dwUpdatetime = htonl(p->dwUpdatetime);

	if (1 == p->cResponseType || 3 == p->cResponseType)
	{
		int j =0;
		for (int i = 0; i < 4; i++)
		{
			j += p->tUserStatus.wNum[i];
			p->tUserStatus.wNum[i] = htons(p->tUserStatus.wNum[i]);
		}
		while(--j >= 0)
		{
			p->tUserStatus.dwUserID[j] = htonl(p->tUserStatus.dwUserID[j]);
		}
	}
	else if (2 == p->cResponseType)
	{
		int i = p->tDeptlist.wNum;

		p->tDeptlist.wNum = htons(p->tDeptlist.wNum);
		while(--i >= 0)
		{
			p->tDeptlist.dwDept[i] = htonl(p->tDeptlist.dwDept[i]);
		}
	}
}



void hton_USERINFOExtend(USERINFOExtend* p)
{
	p->dwBirth = htonl(p->dwBirth);
	p->dwCompID = htonl(p->dwCompID);
	p->dwLogoUpdateTime = htonl(p->dwLogoUpdateTime);
	p->dwUpdateTime = htonl(p->dwUpdateTime);
	p->dwUserID = htonl(p->dwUserID);
	p->wPurview = htons(p->wPurview);
	for(int i=0; i<MAX_PURVIEW; i++)
	{
		p->mPurview[i].dwID=htonl(p->mPurview[i].dwID);
		p->mPurview[i].dwParameter=htonl(p->mPurview[i].dwParameter);
	}
}


void ntoh_USERINFOExtend(USERINFOExtend* p)
{
	p->dwBirth = ntohl(p->dwBirth);
	p->dwCompID = ntohl(p->dwCompID);
	p->dwLogoUpdateTime = ntohl(p->dwLogoUpdateTime);
	p->dwUpdateTime = ntohl(p->dwUpdateTime);
	p->dwUserID = ntohl(p->dwUserID);
	p->wPurview = ntohs(p->wPurview);
	for(int i=0; i< MAX_PURVIEW; i++)
	{
		p->mPurview[i].dwID=ntohl(p->mPurview[i].dwID);
		p->mPurview[i].dwParameter=ntohl(p->mPurview[i].dwParameter);
	}
}

void hton_TGetUserHeadIconList(TGetUserHeadIconList*p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwLastUpdateTime = htonl(p->dwLastUpdateTime);
	p->dwUserID = htonl(p->dwUserID);

}


void ntoh_TGetUserHeadIconList(TGetUserHeadIconList*p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwLastUpdateTime = ntohl(p->dwLastUpdateTime);
	p->dwUserID = ntohl(p->dwUserID);

}
void hton_TGetUserHeadIconListAck(TGetUserHeadIconListAck*p)
{
	p->nPacketLen = htons(p->nPacketLen);
	p->result = (RESULT)htonl(p->result);
	p->wCurrNum = htons(p->wCurrNum);
	p->wCurrPage =  htons(p->wCurrPage);

}
void ntoh_TGetUserHeadIconListAck(TGetUserHeadIconListAck*p)
{
	p->nPacketLen = ntohs(p->nPacketLen);
	p->result = (RESULT)htonl(p->result);
	p->wCurrNum = ntohs(p->wCurrNum);
	p->wCurrPage =  ntohs(p->wCurrPage);

}



void hton_term_CreateRegularGroupNotice(CREATEREGULARGROUPNOTICE *p)
{
	int i = p->wUserNum;
	p->dwCreaterID = htonl(p->dwCreaterID);
	p->dwTime = htonl(p->dwTime);
	p->wUserNum = htons(p->wUserNum);
	while (--i >= 0)
		p->aUserList[i].dwUserID = htonl(p->aUserList[i].dwUserID);
}

void ntoh_term_CreateRegularGroupNotice(CREATEREGULARGROUPNOTICE *p)
{
	p->dwCreaterID = ntohl(p->dwCreaterID);
	p->dwTime = ntohl(p->dwTime);
	p->wUserNum = ntohs(p->wUserNum);
	int i = p->wUserNum;
	while (--i >= 0)
		p->aUserList[i].dwUserID = ntohl(p->aUserList[i].dwUserID);
}
void hton_term_CreateRegularGroupProtocol2Notice(CREATEREGULARGROUPPROTOCOL2NOTICE *p)
{
	int i = p->wCurrentNum;
	p->dwCreaterID = htonl(p->dwCreaterID);
	p->dwTime = htonl(p->dwTime);
	p->wMemberTotalPage = htons(p->wMemberTotalPage);
	p->wMemberPage = htons(p->wMemberPage);
	p->wTotalNum = htons(p->wTotalNum);
	p->wCurrentNum = htons(p->wCurrentNum);
	while (--i >= 0)
		p->aUserList[i].dwUserID = htonl(p->aUserList[i].dwUserID);
}

void ntoh_term_CreateRegularGroupProtocol2Notice(CREATEREGULARGROUPPROTOCOL2NOTICE *p)
{
	p->dwCreaterID = ntohl(p->dwCreaterID);
	p->dwTime = ntohl(p->dwTime);
	p->wMemberTotalPage = ntohs(p->wMemberTotalPage);
	p->wMemberPage = ntohs(p->wMemberPage);
	p->wTotalNum = ntohs(p->wTotalNum);
	p->wCurrentNum = ntohs(p->wCurrentNum);
	int i = p->wCurrentNum;
	while (--i >= 0)
		p->aUserList[i].dwUserID = ntohl(p->aUserList[i].dwUserID);
}

void hton_term_DeleteRegularGroupNotice(DELETEREGULARGROUPNOTICE *p)
{
	p->dwDeleteID = htonl(p->dwDeleteID);
	p->dwTime = htonl(p->dwTime);
}

void ntoh_term_DeleteRegularGroupNotice(DELETEREGULARGROUPNOTICE *p)
{
	p->dwDeleteID = ntohl(p->dwDeleteID);
	p->dwTime = ntohl(p->dwTime);
}


void hton_term_regulargroupupdatereq(REGULAR_GROUP_UPDATE_REQ *p)
{
	p->dwUserID = htonl(p->dwUserID);
	p->dwRegularTime = htonl(p->dwRegularTime);
}

void ntoh_term_regulargroupupdatersp(REGULAR_GROUP_UPDATE_RSP *p)
{
	p->result = (RESULT)ntohl(p->result);
	p->wGroupNum = ntohs(p->wGroupNum);
}


void hton_term_MSG_READ_SYNC(MSG_READ_SYNC *p)
{
	int i = p->wNum;
	p->dwUserID = htonl(p->dwUserID);
	p->wNum = htons(p->wNum);
	while ((--i) >= 0)
	{
		(p->aSessionData[i]).dwTimestamp = htonl((p->aSessionData[i]).dwTimestamp);
		if ((p->aSessionData[i]).cType == 1)
		{
			(p->aSessionData[i]).dwUserID = htonl((p->aSessionData[i]).dwUserID);
		}
	}
}

void ntoh_term_MSG_READ_SYNC(MSG_READ_SYNC *p)
{
	p->dwUserID = ntohl(p->dwUserID);
	p->wNum = ntohs(p->wNum);
	int i = p->wNum;

	while ((--i) >= 0)
	{
		(p->aSessionData[i]).dwTimestamp = ntohl((p->aSessionData[i]).dwTimestamp);
		if ((p->aSessionData[i]).cType == 1)
		{
			(p->aSessionData[i]).dwUserID = ntohl((p->aSessionData[i]).dwUserID);
		}
	}
}

void ntoh_term_ROBOTSYNCREQ(ROBOTSYNCREQ *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->dwTimestamp = ntohl(p->dwTimestamp);
}
void hton_term_ROBOTSYNCREQ(ROBOTSYNCREQ *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->dwTimestamp = htonl(p->dwTimestamp);
}
void ntoh_term_ROBOTSYNCRSP(ROBOTSYNCRSP *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->dwTimestamp = ntohl(p->dwTimestamp);
	p->wTotalPage = ntohs(p->wTotalPage);
	p->wCurrentPage = ntohs(p->wCurrentPage);
	p->wRobotNum = ntohs(p->wRobotNum);
	int i = p->wRobotNum;
	while ((--i )>= 0)
	{
		(p->sRobotList[i]).dwUserID = ntohl((p->sRobotList[i]).dwUserID);
		(p->sRobotList[i]).dwAttribute = ntohl((p->sRobotList[i]).dwAttribute);
	}
}
void hton_term_ROBOTSYNCRSP(ROBOTSYNCRSP *p)
{
	int i = p->wRobotNum;
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->dwTimestamp = htonl(p->dwTimestamp);
	p->wTotalPage = htons(p->wTotalPage);
	p->wCurrentPage = htons(p->wCurrentPage);
	p->wRobotNum = htons(p->wRobotNum);
	while ((--i )>= 0)
	{
		(p->sRobotList[i]).dwUserID = htonl((p->sRobotList[i]).dwUserID);
		(p->sRobotList[i]).dwAttribute = htonl((p->sRobotList[i]).dwAttribute);
	}
}

void ntoh_term_CONTACTSUPDATENOTICE(CONTACTSUPDATENOTICE *p)
{
	p->dwCount = ntohs(p->dwCount);
	p->dwTimeStampe = ntohl(p->dwTimeStampe);
	p->dwUserID = ntohl(p->dwUserID);
}
void hton_term_CONTACTSUPDATENOTICE(CONTACTSUPDATENOTICE *p)
{
	p->dwCount = htons(p->dwCount);
	p->dwTimeStampe = htonl(p->dwTimeStampe);
	p->dwUserID = htonl(p->dwUserID);
}
void ntoh_term_CONTACTSUPDATENOTICEACK(CONTACTSUPDATENOTICEACK *p)
{
	p->dwTimeStampe = ntohl(p->dwTimeStampe);
	p->dwUserID = ntohl(p->dwUserID);
}
void hton_term_CONTACTSUPDATENOTICEACK(CONTACTSUPDATENOTICEACK *p)
{
	p->dwTimeStampe = htonl(p->dwTimeStampe);
	p->dwUserID = htonl(p->dwUserID);
}

void htonl_ECWX_PUSH_NOTICE(ECWX_PUSH_NOTICE *p)
{
	p->wSize = htons(p->wSize);
	p->wCmd = htons(p->wCmd);
	p->dwTid = htonl(p->dwTid);

	p->dwSrcUserID = htonl(p->dwSrcUserID);
	p->dwNetID = htonl(p->dwNetID);
	p->dwTimestamp = htonl(p->dwTimestamp);

	p->ddwMsgID = htonl64(p->ddwMsgID);
	p->dwDstUserID = htonl(p->dwDstUserID);

	p->wOfflineTotal = htons(p->wOfflineTotal);
	p->wOfflineSeq = htons(p->wOfflineSeq);
}

void ntohl_ECWX_PUSH_NOTICE(ECWX_PUSH_NOTICE *p)
{
	p->wSize = ntohs(p->wSize);
	p->wCmd = ntohs(p->wCmd);
	p->dwTid = ntohl(p->dwTid);

	p->dwSrcUserID = ntohl(p->dwSrcUserID);
	p->dwNetID = ntohl(p->dwNetID);
	p->dwTimestamp = ntohl(p->dwTimestamp);

	p->ddwMsgID = ntohl64(p->ddwMsgID);
	p->dwDstUserID = ntohl(p->dwDstUserID);

	p->wOfflineTotal = ntohs(p->wOfflineTotal);
	p->wOfflineSeq = ntohs(p->wOfflineSeq);
}

void ntoh_term_MsgCancelAck(MSGCancelACK *p)
{
    p->result = (RESULT)ntohl(p->result);
    p->dwMsgID = ntohl64(p->dwMsgID);
	p->dwCancelMsgID = ntohl64(p->dwCancelMsgID);
}

void ntoh_term_MsgCancelNotice(MSGCancelNotice *p)
{
    p->dwSenderID = ntohl(p->dwSenderID);
    p->dwRecverID = ntohl(p->dwRecverID);
    p->dwMsgID    = ntohl64(p->dwMsgID);
    p->dwCancelMsgID = ntohl64(p->dwCancelMsgID);
    p->dwSendTime = ntohl(p->dwSendTime);
    p->dwGroupTime  = ntohl(p->dwGroupTime);
 	p->dwNetID		= ntohl(p->dwNetID);
}

void hton_term_sendCancelSms(MSGCancel *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwRecverID = htonl(p->dwRecverID);
    p->dwMsgID = htonl64(p->dwMsgID);
	p->dwCancelMsgID = htonl64(p->dwCancelMsgID);
    p->nSendTime = htonl(p->nSendTime);
}

void hton_term_CancelNoticeAck(MSGCancelNoticeAck *p)
{
    p->dwUserID = htonl(p->dwUserID);
    p->dwMsgID  = htonl64(p->dwMsgID);
	p->dwCancelMsgID  = htonl64(p->dwCancelMsgID);
	p->dwNetID = htonl(p->dwNetID);
}

void hton_term_virgroup_info_req(VIRTUAL_GROUP_INFO_REQ *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->dwTimestamp = htonl(p->dwTimestamp);
}
void ntoh_term_virgroup_info_req(VIRTUAL_GROUP_INFO_REQ *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->dwTimestamp = ntohl(p->dwTimestamp);
}

void ntoh_term_virgroup_info_ack(VIRTUAL_GROUP_INFO_ACK *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->wVirGroupNum = ntohs(p->wVirGroupNum);
	p->dwResult = ntohl(p->dwResult);
}
void hton_term_virgroup_info_ack(VIRTUAL_GROUP_INFO_ACK *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->wVirGroupNum = htons(p->wVirGroupNum);
	p->dwResult = htonl(p->dwResult);
}

void hton_term_virgroup_basic_info(virtual_group_basic_info *p)
{
	p->dwMainUserID = htonl(p->dwMainUserID);
	p->dwGroupTime = htonl(p->dwGroupTime);
	p->wMemberNum = htons(p->wMemberNum);
	p->wSingleSvcNum = htons(p->wSingleSvcNum);
	p->wTimeoutMinute = htons(p->wTimeoutMinute);
}

void ntoh_term_virgroup_basic_info(virtual_group_basic_info *p)
{
	p->dwMainUserID = ntohl(p->dwMainUserID);
	p->dwGroupTime = ntohl(p->dwGroupTime);
	p->wMemberNum = ntohs(p->wMemberNum);
	p->wSingleSvcNum = ntohs(p->wSingleSvcNum);
	p->wTimeoutMinute = ntohs(p->wTimeoutMinute);
}

void hton_term_virgroup_info(virtual_group_info *p)
{
	hton_term_virgroup_basic_info(&p->mBasicInfo);
	int i = MAX_VIR_GROUP_MEMBER;
	while((--i) >= 0)
	{
		p->dwGroupMember[i] = htonl(p->dwGroupMember[i]);
	}
}

void ntoh_term_virgroup_info(virtual_group_info *p)
{
	ntoh_term_virgroup_basic_info(&p->mBasicInfo);
	int i = MAX_VIR_GROUP_MEMBER;
	while((--i) >= 0)
	{
		p->dwGroupMember[i] = ntohl(p->dwGroupMember[i]);
	}
}

void hton_term_virgroup_info_notice(VIRTUAL_GROUP_INFO_NOTICE *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->wTotalNum = htons(p->wTotalNum);
	p->wCurNum = htons(p->wCurNum);
	hton_term_virgroup_info(&p->mVirGroupInfo);
}

void ntoh_term_virgroup_info_notice(VIRTUAL_GROUP_INFO_NOTICE *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->wTotalNum = ntohs(p->wTotalNum);
	p->wCurNum = ntohs(p->wCurNum);
	ntoh_term_virgroup_info(&p->mVirGroupInfo);
}

void hton_term_favorite_sync_req(FAVORITE_SYNC_REQ *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->dwTimestamps = htonl(p->dwTimestamps);
}
void ntoh_term_favorite_sync_req(FAVORITE_SYNC_REQ *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->dwTimestamps = ntohl(p->dwTimestamps);
}
void hton_term_favorite_info(favorite_info *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->dwCollTime = htonl(p->dwCollTime);
	p->dwSender = htonl(p->dwSender);
	p->dwSendTime = htonl(p->dwSendTime);
	p->ddwMsgID = htonl64(p->ddwMsgID);
	p->wMsgType = htons(p->wMsgType);
	p->dwMsgSize = htons(p->dwMsgSize);
}

void ntoh_term_favorite_info(favorite_info *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->dwCollTime = ntohl(p->dwCollTime);
	p->dwSender = ntohl(p->dwSender);
	p->dwSendTime = ntohl(p->dwSendTime);
	p->ddwMsgID = ntohl64(p->ddwMsgID);
	p->wMsgType = ntohs(p->wMsgType);
	p->dwMsgSize = ntohs(p->dwMsgSize);
}
void hton_term_favorite_batch(favorite_batch_opera *p)
{
	int i = p->wNum;
	p->wNum = htons(p->wNum);
	while((--i) >= 0)
		p->ddwMsgID[i] = htonl64(p->ddwMsgID[i]);
}
void ntoh_term_favorite_batch(favorite_batch_opera *p)
{
	p->wNum = ntohs(p->wNum);

	int i = p->wNum;
	while((--i) >= 0)
		p->ddwMsgID[i] = ntohl64(p->ddwMsgID[i]);
}

void hton_term_favorite_modify_req(FAVORITE_MODIFY_REQ *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	if (p->cOperType == 1 || p->cOperType == 2)
	{
		hton_term_favorite_info(&p->stFavoriteInfo);
	}
	else
	{
		hton_term_favorite_batch(&p->stFavoriteBatch);
	}

}
void ntoh_term_favorite_modify_req(FAVORITE_MODIFY_REQ *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	if (p->cOperType == 1 || p->cOperType == 2)
	{
		ntoh_term_favorite_info(&p->stFavoriteInfo);
	}
	else
	{
		ntoh_term_favorite_batch(&p->stFavoriteBatch);
	}
}

void hton_term_favorite_sync_ack(FAVORITE_SYNC_ACK *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->dwResult = htonl(p->dwResult);
	p->wTotalNum = htons(p->wTotalNum);
}
void ntoh_term_favorite_sync_ack(FAVORITE_SYNC_ACK *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->dwResult = ntohl(p->dwResult);
	p->wTotalNum = ntohs(p->wTotalNum);
}
void hton_term_favorite_notice(FAVORITE_NOTICE *p)
{
	hton_term_favorite_modify_req((FAVORITE_MODIFY_REQ*)p);
}
void ntoh_term_favorite_notice(FAVORITE_NOTICE *p)
{
	ntoh_term_favorite_modify_req((FAVORITE_MODIFY_REQ*)p);
}
void hton_term_favorite_modify_ack(FAVORITE_MODIFY_ACK *p)
{
	p->dwCompID = htonl(p->dwCompID);
	p->dwUserID = htonl(p->dwUserID);
	p->dwResult = htonl(p->dwResult);

	hton_term_favorite_batch(&p->stFavoriteBatch);
}
void ntoh_term_favorite_modify_ack(FAVORITE_MODIFY_ACK *p)
{
	p->dwCompID = ntohl(p->dwCompID);
	p->dwUserID = ntohl(p->dwUserID);
	p->dwResult = ntohl(p->dwResult);

	ntoh_term_favorite_batch(&p->stFavoriteBatch);
}

void hton_term_GetDeptShowConfigAck(GETDEPTSHOWCONFIGACK *p)
{
    p->wPacketLen = htons(p->wPacketLen);
    p->dwUserID  =  htonl(p->dwUserID);
    p->dwUpdateTime = htonl(p->dwUpdateTime);
    p->wCurrPage = htons(p->wCurrPage);
    p->wCurrNum  = htons(p->wCurrNum);
}
void ntoh_term_GetDeptShowConfigAck(GETDEPTSHOWCONFIGACK *p)
{
    p->wPacketLen = ntohs(p->wPacketLen);
    p->dwUserID  =  ntohl(p->dwUserID);
    p->dwUpdateTime = ntohl(p->dwUpdateTime);
    p->wCurrPage = ntohs(p->wCurrPage);
    p->wCurrNum  = ntohs(p->wCurrNum);
}

void ntoh_MeetingBaseInfoNotice(confInfoNotice* pMeetingNotice)
{
    pMeetingNotice->dwUserId = ntohl(pMeetingNotice->dwUserId);
    pMeetingNotice->sConfBasicInfo.dwStartTime = ntohl(pMeetingNotice->sConfBasicInfo.dwStartTime);
    pMeetingNotice->sConfBasicInfo.dwEndTime = ntohl(pMeetingNotice->sConfBasicInfo.dwEndTime);
    pMeetingNotice->sConfBasicInfo.dwConfLength = ntohl(pMeetingNotice->sConfBasicInfo.dwConfLength);
    pMeetingNotice->sConfBasicInfo.dwcreatorID = ntohl(pMeetingNotice->sConfBasicInfo.dwcreatorID);
    
    pMeetingNotice->sConfBasicInfo.dwRealLength = ntohl(pMeetingNotice->sConfBasicInfo.dwRealLength);
    pMeetingNotice->sConfBasicInfo.dwMbrMaxNum = ntohl(pMeetingNotice->sConfBasicInfo.dwMbrMaxNum);
    pMeetingNotice->sConfBasicInfo.dwUpdateTime = ntohl(pMeetingNotice->sConfBasicInfo.dwUpdateTime);
    pMeetingNotice->sConfBasicInfo.dwPartNum = ntohl(pMeetingNotice->sConfBasicInfo.dwPartNum);
    pMeetingNotice->sConfBasicInfo.dwFileNum = ntohl(pMeetingNotice->sConfBasicInfo.dwFileNum);
    pMeetingNotice->sConfBasicInfo.dwRealEndTime = ntohl(pMeetingNotice->sConfBasicInfo.dwRealEndTime);
    pMeetingNotice->sConfBasicInfo.dwRealStartTime = ntohl(pMeetingNotice->sConfBasicInfo.dwRealStartTime);
}

void ntoh_MeetingMbrInfoNotice(confMbrInfoNotice* pConfMbrInfoNotice)
{
    pConfMbrInfoNotice->dwUserId = ntohl(pConfMbrInfoNotice->dwUserId);
    pConfMbrInfoNotice->wMbrNum = ntohs(pConfMbrInfoNotice->wMbrNum);
    int i = pConfMbrInfoNotice->wMbrNum;
    while(--i >= 0)
    {
        pConfMbrInfoNotice->sMbrList[i].dwMbrId = ntohl(pConfMbrInfoNotice->sMbrList[i].dwMbrId);
        pConfMbrInfoNotice->sMbrList[i].dwOperaId = ntohl(pConfMbrInfoNotice->sMbrList[i].dwOperaId);
        pConfMbrInfoNotice->sMbrList[i].dwUpdateTime = ntohl(pConfMbrInfoNotice->sMbrList[i].dwUpdateTime);
    }
}

void ntoh_MeetingFileInfoNotice(confFileInfoNotice* pMeetingNotice)
{
    pMeetingNotice->dwUserId = ntohl(pMeetingNotice->dwUserId);
    pMeetingNotice->wFileNum = ntohs(pMeetingNotice->wFileNum);
    int i = pMeetingNotice->wFileNum;
    while (--i >= 0)
    {
        pMeetingNotice->sFileList[i].dwUpdateTime = ntohl(pMeetingNotice->sFileList[i].dwUpdateTime);
        pMeetingNotice->sFileList[i].fileSize = ntohl(pMeetingNotice->sFileList[i].fileSize);
    }
}

void ntoh_MeetingUserInfoNotice(confUserInfoNotice *pMeetingNotice)
{
    pMeetingNotice->dwUserId = ntohl(pMeetingNotice->dwUserId);
}
