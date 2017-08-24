#ifndef __TERMCHANGE_H__
#define __TERMCHANGE_H__

#include "protocol.h"

void hton_term_head(TERM_CMD_HEAD *p);
void ntoh_term_head(TERM_CMD_HEAD *p);

void hton_term_alive(ALIVE *p);
void ntoh_term_alive(ALIVE *p);

void hton_term_compinfo(COMPINFO *p);
void ntoh_term_compinfo(COMPINFO *p);

void hton_term_userinfo(USERINFO *p);
void ntoh_term_userinfo(USERINFO *p);

void hton_term_userdept(USERDEPT *p);

void hton_term_employee(EMPLOYEE *p);
void ntoh_term_employee(EMPLOYEE *p);

void hton_term_getemployee(GETEMPLOYEEINFO *p);
void ntoh_term_getemployee(GETEMPLOYEEINFO *p);

void hton_term_modiinfo(MODIINFO *p);
void ntoh_term_modiinfo(MODIINFO *p);

void hton_term_modiemployee(MODIEMPLOYEE *p);
void ntoh_term_modiemployee(MODIEMPLOYEE *p);

void hton_term_modiemployeeAck(MODIEMPLOYEEACK *p);
void ntoh_term_modiemployeeAck(MODIEMPLOYEEACK *p);

void hton_term_modiinfoAck(MODIINFOACK *p);
void ntoh_term_modiinfoAck(MODIINFOACK *p);

void hton_term_getcompinfo(GETCOMPINFO *p);
void ntoh_term_getcompinfo(GETCOMPINFO *p);

void hton_term_getdeptlist(GETDEPTLIST *p);
void ntoh_term_getdeptlist(GETDEPTLIST *p);

void hton_term_getuserlist(GETUSERLIST *p);
void ntoh_term_getuserlist(GETUSERLIST *p);

void hton_term_getuserdept(GETUSERDEPT *p);
void ntoh_term_getuserdept(GETUSERDEPT *p);

void hton_term_getuserstate(GETUSERSTATELIST *p);
void ntoh_term_getuserstate(GETUSERSTATELIST *p);

void hton_term_creategroup(CREATEGROUP *p);
void ntoh_term_creategroup(CREATEGROUP *p);

void hton_term_modigroup(MODIGROUP *p);
void ntoh_term_modigroup(MODIGROUP *p);

void hton_term_getgroupinfo(GETGROUPINFO *p);
void ntoh_term_getgroupinfo(GETGROUPINFO *p);

void hton_term_sendsms(SENDMSG *p);
void ntoh_term_sendsms(SENDMSG *p);

void hton_term_msgread(MSGREAD *p);
void ntoh_term_msgread(MSGREAD *p);

void hton_term_msgnoticeconfirm(MSGNOTICECONFIRM *p);
void ntoh_term_msgnoticeconfirm(MSGNOTICECONFIRM *p);

void hton_term_msgreadnotice(MSGREADNOTICE *p);
void ntoh_term_msgreadnotice(MSGREADNOTICE *p);
void hton_term_msgreadnoticeAck(MSGREADNOTICEACK *p);
void ntoh_term_msgreadnoticeAck(MSGREADNOTICEACK *p);

void hton_term_modimember(MODIMEMBER *p);
void ntoh_term_modimember(MODIMEMBER *p);
/*
void hton_userinfo(TUSERINFO *p);
void ntoh_userinfo(TUSERINFO *p);
*/

void ntoh_term_login_resp(LOGINACK *p);

void hton_term_logout_req(LOGOUT *p);
void ntoh_term_logout_req(LOGOUT *p);

void hton_term_logout_resp(LOGOUTACK *p);
void ntoh_term_logout_resp(LOGOUTACK *p);

void hton_term_userstatus_notice(USERSTATUSNOTICE *p);
void ntoh_term_userstatus_notice(USERSTATUSNOTICE *p);

void hton_term_modiinfonotice(MODIINFONOTICE *p);
void ntoh_term_modiinfonotice(MODIINFONOTICE *p);

void hton_term_GetCompInfoAck(GETCOMPINFOACK *p);
void ntoh_term_GetCompInfoAck(GETCOMPINFOACK *p);

void hton_term_GetDeptListAck(GETDEPTLISTACK *p);
void ntoh_term_GetDeptListAck(GETDEPTLISTACK *p);

void hton_term_GetUserListAck(GETUSERLISTACK *p);
void ntoh_term_GetUserListAck(GETUSERLISTACK *p);

void hton_term_GetUserDeptAck(GETUSERDEPTACK *p);
void ntoh_term_GetUserDeptAck(GETUSERDEPTACK *p);

void hton_term_GetEmployeeAck(GETEMPLOYEEACK *p);
void ntoh_term_GetEmployeeAck(GETEMPLOYEEACK *p);

void hton_term_CreateGroupAck(CREATEGROUPACK *p);
void ntoh_term_CreateGroupAck(CREATEGROUPACK *p);

void hton_term_CreateGroupNotice(CREATEGROUPNOTICE *p);
void ntoh_term_CreateGroupNotice(CREATEGROUPNOTICE *p);

void hton_term_ModiGroupAck(MODIGROUPACK *p);
void ntoh_term_ModiGroupAck(MODIGROUPACK *p);

void hton_term_ModiGroupNotice(MODIGROUPNOTICE *p);
void ntoh_term_ModiGroupNotice(MODIGROUPNOTICE *p);

void hton_term_GetGroupAck(GETGROUPINFOACK *p);
void ntoh_term_GetGroupAck(GETGROUPINFOACK *p);

void hton_term_ModiMemberAck(MODIMEMBERACK *p);
void ntoh_term_ModiMemberAck(MODIMEMBERACK *p);

void hton_term_ModiMemberNotice(MODIMEMBERNOTICE *p);
void ntoh_term_ModiMemberNotice(MODIMEMBERNOTICE *p);

void hton_term_SendMsgAck(SENDMSGACK *p);
void ntoh_term_SendMsgAck(SENDMSGACK *p);

void hton_term_MsgReadAck(MSGREADACK *p);
void ntoh_term_MsgReadAck(MSGREADACK *p);

void hton_term_MsgNotice(MSGNOTICE *p);
void ntoh_term_MsgNotice(MSGNOTICE *p);

void hton_term_MsgNoticeAck(MSGNOTICEACK *p);
void ntoh_term_MsgNoticeAck(MSGNOTICEACK *p);

void hton_term_MsgReadNotice(MSGREADNOTICE *p);
void ntoh_term_MsgReadNotice(MSGREADNOTICE *p);

void hton_term_MsgReadNoticeAck(MSGREADNOTICEACK *p);
void ntoh_term_MsgReadNoticeAck(MSGREADNOTICEACK *p);

void hton_term_userstate(USERSTATE *p);
void ntoh_term_userstate(USERSTATE *p);

void hton_term_GetUserStateAck(GETUSERSTATELISTACK *p);
void ntoh_term_GetUserStateAck(GETUSERSTATELISTACK *p);

void hton_term_sendbroad(SENDBROADCAST *p);
void ntoh_term_sendbroad(SENDBROADCAST *p);

void hton_term_SendBroadAck(SENDBROADCASTACK *p);
void ntoh_term_SendBroadAck(SENDBROADCASTACK *p);

void hton_term_BroadNotice(BROADCASTNOTICE *p);
void ntoh_term_BroadNotice(BROADCASTNOTICE *p);




void hton_term_checktime_req(CHECK_TIME_REQ *p);
void ntoh_term_checktime_resp(CHECK_TIME_RESP *p);

void hton_term_getoffline_req(GET_OFFLINE_REQ *p);
void ntoh_term_getoffline_resp(GET_OFFLINE_RESP *p);

void hton_term_refusegroup_req(REFUSE_GROUPMSG_REQ *p);
void ntoh_term_refusegroup_resp(REFUSE_GROUPMSG_REQ *p);
UINT64  htonl64(UINT64  host);
UINT64  ntohl64(UINT64   host)   ;

void hton_term_QuitGroupreq(QUITGROUP *p);
void ntoh_term_QuitGroupreq(QUITGROUP *p);

void hton_term_QuitGroupNotice(QUITGROUPNOTICE *p);
void ntoh_term_QuitGroupNotice(QUITGROUPNOTICE *p);

void hton_term_resetselfinfo_req(RESETSELFINFO *p);
void ntoh_term_resetselfinfo_req(RESETSELFINFO *p);

void hton_term_resetselfinfo_notice(RESETSELFINFONOTICE *p);
void ntoh_term_resetselfinfo_notice(RESETSELFINFONOTICE *p);

void hton_term_CreateSchedule(CREATESCHEDULE *p);
void ntoh_term_CreateSchedule(CREATESCHEDULE *p);

void hton_term_CreateScheduleAck(CREATESCHEDULEACK *p);
void ntoh_term_CreateScheduleAck(CREATESCHEDULEACK *p);

void hton_term_CreateScheduleNotice(CREATESCHEDULENOTICE *p);
void ntoh_term_CreateScheduleNotice(CREATESCHEDULENOTICE *p);

void hton_term_GETDATALISTTYPE(GETDATALISTTYPE *p);
void ntoh_term_GETDATALISTTYPE(GETDATALISTTYPE *p);

void hton_term_GETDATALISTTYPEACK(GETDATALISTTYPEACK *p);
void ntoh_term_GETDATALISTTYPEACK(GETDATALISTTYPEACK *p);

void hton_term_userstatusset_notice(USERSTATUSSETNOTICE *p);
void ntoh_term_userstatusset_notice(USERSTATUSSETNOTICE *p);

void hton_term_deptinfo(DEPTINFO *p);
void ntoh_term_deptinfo(DEPTINFO *p);

void ntoh_term_userdept(USERDEPT *p);

void hton_term_complsttime_notice(COMPLASTTIMENOTICE *p);
void ntoh_term_complsttime_notice(COMPLASTTIMENOTICE *p);

void hton_ios_background_req(IOSBACKGROUNDREQ *p);
void ntoh_ios_background_req(IOSBACKGROUNDREQ *p);
 
void hton_getuserrpa_req(GETUSERRPA *p);
void ntoh_getuserrpa_req(GETUSERRPA *p);

void hton_getuserrpa_ack(GETUSERPAASK *p);
void ntoh_getuserrpa_ack(GETUSERPAASK *p);


 
void hton_GETSPECIALLISTACK(GETSPECIALLISTACK* p);
void ntoh_GETSPECIALLISTACK(GETSPECIALLISTACK*p);

void hton_MODISPECIALLISTNOTICE(MODISPECIALLISTNOTICE*p);
void ntoh_MODISPECIALLISTNOTICE(MODISPECIALLISTNOTICE*p);

void hton_ModiSpecialListNoticeAck(MODISPECIALLISTNOTICEACK* p);
void ntoh_ModiSpecialListNoticeAck(MODISPECIALLISTNOTICEACK* p);

void hton_TGetStatusReq_req(TGetStatusReq* p);
 


void ntoh_term_THead(THead *p);
 
void hton_term_THead(THead *p);
 

void ntoh_term_SUBSCRIBER_REQ(SUBSCRIBER_REQ *p);
 
void hton_term_SUBSCRIBER_REQ(SUBSCRIBER_REQ *p);



void ntoh_SUBSCRIBER_ACK(SUBSCRIBER_ACK *p);

void ntoh_TJson(TJson*p);
void hton_TJson(TJson*p);


void ntoh_term_ROAMDATASYNC(ROAMDATASYNC *p);
void hton_term_ROAMDATASYNC(ROAMDATASYNC *p);
void ntoh_term_ROAMDATAMODI(ROAMDATAMODI *p);
void hton_term_ROAMDATAMODI(ROAMDATAMODI *p);
void ntoh_term_ROAMDATASYNCACK(ROAMDATASYNCACK *p);
void hton_term_ROAMDATASYNCACK(ROAMDATASYNCACK *p);
void ntoh_term_ROAMDATAMODIACK(ROAMDATAMODIACK *p);
void hton_term_ROAMDATAMODIACK(ROAMDATAMODIACK *p);
 
void ntoh_term_ROAMDATAMODINOTICE(ROAMDATAMODINOTICE *p);
void hton_term_ROAMDATAMODINOTICE(ROAMDATAMODINOTICE *p);


void ntoh_USERINFOExtend(USERINFOExtend* p);
void hton_USERINFOExtend(USERINFOExtend* p);


void hton_TGetUserHeadIconList(TGetUserHeadIconList*p);
void ntoh_TGetUserHeadIconList(TGetUserHeadIconList*p);
 


void hton_TGetUserHeadIconListAck(TGetUserHeadIconListAck*p);
void ntoh_TGetUserHeadIconListAck(TGetUserHeadIconListAck*p);

void hton_term_CreateRegularGroupNotice(CREATEREGULARGROUPNOTICE *p);
void ntoh_term_CreateRegularGroupNotice(CREATEREGULARGROUPNOTICE *p);

void hton_term_CreateRegularGroupProtocol2Notice(CREATEREGULARGROUPPROTOCOL2NOTICE *p);
void ntoh_term_CreateRegularGroupProtocol2Notice(CREATEREGULARGROUPPROTOCOL2NOTICE *p);

void hton_term_DeleteRegularGroupNotice(DELETEREGULARGROUPNOTICE *p);
void ntoh_term_DeleteRegularGroupNotice(DELETEREGULARGROUPNOTICE *p);

void hton_term_regulargroupupdatereq(REGULAR_GROUP_UPDATE_REQ *p);
void ntoh_term_regulargroupupdatersp(REGULAR_GROUP_UPDATE_RSP *p);

void hton_term_MSG_READ_SYNC(MSG_READ_SYNC *p);
void ntoh_term_MSG_READ_SYNC(MSG_READ_SYNC *p);

void ntoh_term_ROBOTSYNCREQ(ROBOTSYNCREQ *p);
void hton_term_ROBOTSYNCREQ(ROBOTSYNCREQ *p);
void ntoh_term_ROBOTSYNCRSP(ROBOTSYNCRSP *p);
void hton_term_ROBOTSYNCRSP(ROBOTSYNCRSP *p);

void ntoh_term_CONTACTSUPDATENOTICE(CONTACTSUPDATENOTICE *p);
void hton_term_CONTACTSUPDATENOTICE(CONTACTSUPDATENOTICE *p);
void ntoh_term_CONTACTSUPDATENOTICEACK(CONTACTSUPDATENOTICEACK *p);
void hton_term_CONTACTSUPDATENOTICEACK(CONTACTSUPDATENOTICEACK *p);

void htonl_ECWX_PUSH_NOTICE(ECWX_PUSH_NOTICE *p);
void ntohl_ECWX_PUSH_NOTICE(ECWX_PUSH_NOTICE *p);

//added by rock
void ntoh_term_MsgCancelAck(MSGCancelACK *p);
void ntoh_term_MsgCancelNotice(MSGCancelNotice *p);

void hton_term_sendCancelSms(MSGCancel *p);
void hton_term_CancelNoticeAck(MSGCancelNoticeAck *p);

void hton_term_virgroup_info_req(VIRTUAL_GROUP_INFO_REQ *p);
void ntoh_term_virgroup_info_req(VIRTUAL_GROUP_INFO_REQ *p);
void ntoh_term_virgroup_info_ack(VIRTUAL_GROUP_INFO_ACK *p);
void hton_term_virgroup_info_ack(VIRTUAL_GROUP_INFO_ACK *p);
void hton_term_virgroup_info_notice(VIRTUAL_GROUP_INFO_NOTICE *p);
void ntoh_term_virgroup_info_notice(VIRTUAL_GROUP_INFO_NOTICE *p);

void hton_term_favorite_sync_req(FAVORITE_SYNC_REQ *p);
void ntoh_term_favorite_sync_req(FAVORITE_SYNC_REQ *p);
void hton_term_favorite_modify_req(FAVORITE_MODIFY_REQ *p);
void ntoh_term_favorite_modify_req(FAVORITE_MODIFY_REQ *p);
void hton_term_favorite_sync_ack(FAVORITE_SYNC_ACK *p);
void ntoh_term_favorite_sync_ack(FAVORITE_SYNC_ACK *p);
void hton_term_favorite_notice(FAVORITE_NOTICE *p);
void ntoh_term_favorite_notice(FAVORITE_NOTICE *p);
void hton_term_favorite_modify_ack(FAVORITE_MODIFY_ACK *p);
void ntoh_term_favorite_modify_ack(FAVORITE_MODIFY_ACK *p);

void hton_term_GetDeptShowConfigAck(GETDEPTSHOWCONFIGACK *p);
void ntoh_term_GetDeptShowConfigAck(GETDEPTSHOWCONFIGACK *p);

void ntoh_MeetingBaseInfoNotice(confInfoNotice* pMeetingNotice);
void ntoh_MeetingMbrInfoNotice(confMbrInfoNotice* pMeetingNotice);
void ntoh_MeetingFileInfoNotice(confFileInfoNotice* pMeetingNotice);
void ntoh_MeetingUserInfoNotice(confUserInfoNotice *pMeetingNotice);


#endif
