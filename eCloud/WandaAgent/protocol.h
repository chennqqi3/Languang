#ifndef __PROTOCOL_H__
#define __PROTOCOL_H__

#include "BasicDefine.h"

#define MSGHEAD_LEN          8
#define HTTPHEAD_MAXLEN      45
#define PACKET_MAXLEN        2500
#define PACKET_CONTENT_LEN   1900
#define PACKET_LEN_INDICATOR 4

#define CONF_FILE_MAX       10
#define FILE_NAME_MAX_LEN   128
#define USERNAME_MAXLEN     128
#define LOGO_MAXLEN         7 
#define EMAIL_MAXLEN        64
#define POSTCODE_MAXLEN     64
#define FAX_MAXLEN          64

//Guojian Modify 2016-12-15
//南航SSO最大允许密码长度50，适应此情况
#ifdef _NANHANG_FLAG_
#define PASSWD_MAXLEN       51
#else
#define PASSWD_MAXLEN       16
#endif
//end Guojian Modify 2016-12-15

//Guojian Modify 2017-03-07
//泰禾最大允许修改信息长度为50，适应此情况
#ifdef _TAIHE_FLAG_
#define MODIINFO_MAXLEN_EX	180
#else
#define MODIINFO_MAXLEN_EX	180
#endif
//end Guojian Modify 2016-12-15

#define COMPNAME_MAXLEN     50
#define DEPTNAME_MAXLEN     255
#define COMPLOGO_MAXLEN     50
#define PHONE_MAXLEN        64
#define TEL_MAXLEN          64
#define GROUPNAME_MAXLEN    50
#define GROUPID_MAXLEN      20
#define POST_MAXLEN         255
#define USERCODE_MAXLEN     30
#define MSG_MAXLEN          1800
#define MAX_TITLELEN        300
#define MSG_MAXBROADLEN     1000
#define MODIINFO_MAXLEN     50
#define LOCAL_MAXLEN        50
#define FILENAME_MAXLEN     300 
#define URL_MAXLEN          40
#define IP_MAXLEN           16
#define HOST_MAXLEN         64
#define SIGN_MAXLEN         46

#define TOKEN_MAXLEN        80
#define DESTSINGLENUM       10
#define DESTGROUPNUM        10
#define FILEPATHLEN         100
#define SCHEDULENAME_LEN    60
#define SCHEDULEDETAIL_LEN  300
#define RANKNAME_LEN        30
#define PROFESSNAME_LEN     30
#define AREANAME_LEN        60

#define MAXNUM_PAGE_DEPT       30       //每页部门最大数
#define MAXNUM_PAGE_USER       8        //每页用户最大数
#define MAXNUM_PAGE_USERSIMP   50       //每页用户简要信息最大数
#define MAXNUM_PAGE_USERDEPT   50       //每页部门用户最大数
#define MAXNUM_PAGE_USERID     500      //每页用户ID最大数
#define MAXNUM_PAGE_USERSTATE  300      //每页用户状态信息最大数
#define MAXNUM_RECVER_ID       100      //每次广播最个用户ID或部门ID个数
#define MAX_SPECIAL_NUM       100      //黑名单每次请求最大数
#define MAXNUM_USERIN_DEPT     10      //用户兼职最多部门数
#define MAX_CHILD_DEPT  1000      //一个部门的最大子部门数  发送广播时用到
#define AES_FILE_PWD_LEN      100   //解密文件密码
#define MAX_USERSTATUS_NUM    400 //用户状态最大数 v1.1

#define VERSION_MAXLEN 20	//版本最大长度V1.1
#define MAC_ADDR_MAXLEN 6	//mac地址V1.1
#define MAX_PURVIEW 10		//最多权限参数数V1.1

#define LV255_MAX 255      //lv方式最长
#define MAX_ADDR_LEN    1024 //adrr len

#define MAX_CONTANTSDOWNLOADPATH_LEN	200	//通讯录DB文件的下载路径

//////////////////////BIG DATA//////////////////////////////begin

#define LVAR_BYTES			1				// LVAR bytes
#define LLVAR_BYTES			2				// LLVAR bytes
#define LLLVAR_BYTES		3				// LLLVAR bytes
#define LLLLVAR_BYTES		4				// LLLLVAR bytes
/*
#define EIMERR_PARSE_FINISHED		91				// Reach at the end of the package, parse finished
#define EIMERR_SUCCESS		0				// Parse succeeded of this time
#define EIMERR_INVALID_PARAMTER	-91				// Parameter error
#define EIMERR_PACKAGE_ERROR	-92				// Package error
*/
#define UINT8_BYTES			sizeof(UINT8)	// UINT8 bytes
#define UINT16_BYTES		sizeof(UINT16)	// UINT16 bytes
#define UINT32_BYTES		sizeof(UINT32)	// UINT32 bytes

#define MAKE_UINT16_EX_(P) MAKE_UINT16_( (P)[u32Pos + 0], (P)[u32Pos + 1] )
#define MAKE_UINT32_EX_(P) MAKE_UINT32_( MAKE_UINT16_((P)[u32Pos + 0], (P)[u32Pos + 1]), MAKE_UINT16_((P)[u32Pos + 2], (P)[u32Pos + 3]) )
////////////////////////BIG DATA//////////////////////////////

//命令字
typedef enum
{
	CMD_LOGIN = 21,		// 登录				21
	CMD_LOGINACK,		// 登录应答			22
	CMD_LOGOUT,			// 退出				23
	CMD_LOGOUTACK,		// 退出应答			24
	CMD_NOTICESTATE,	// 员工在线状态变化通知25
	CMD_NOTICESTATEACK, // 状态变化通知应答	26

	CMD_ALIVE,			// 心跳				27
	CMD_ALIVEACK,		// 心跳应答			28

	CMD_MODIINFO,		// 修改本人资料		29
	CMD_MODIINFOACK,	// 修改本人资料应答	30
	CMD_MODIINFONOTICE, // 资料修改通知		31
	CMD_MODIINFONOTICEACK, // 资料修改通知应答	32

	CMD_GETCOMPINFO,	// 获取企业信息		33
	CMD_GETCOMPINFOACK, // 获取企业信息应答	34

	CMD_NOTICECOMPINFO, // 企业信息更新通知	35
	CMD_NOTICECOMPINFOACK, //企业信息更新通知应答 36

	CMD_GETDEPTLIST,	// 获取组织构架       37
	CMD_GETDEPTLISTACK, // 获取组织构架应答	38

	CMD_NOTICEDEPTLIST,		// 组织构架更新通知	39
	CMD_NOTICEDEPTLISTACK,	//组织构架更新通知应答	40

	CMD_GETUSERLIST,		// 获取员工列表		41
	CMD_GETUSERLISTACK,		// 获取员工列表应答	42

	CMD_GETUSERDEPT,		// 获取员工部门信息	43
	CMD_GETUSERDEPTACK,		// 获取员工部门信息应答44

	CMD_GETEMPLOYEEINFO,	// 获取员工详细信息	45
	CMD_GETEMPLOYEEINFOACK, // 获取员工详细信息应答46

	CMD_CREATEGROUP,		// 创建聊天群组		47
	CMD_CREATEGROUPACK,		// 创建聊天群组应答	48
	CMD_CREATEGROUPNOTICE,	// 创建群组通知		49
	CMD_CREATEGROUPNOTICEACK,// 创建群组通知应答	50

	CMD_MODIGROUP,			// 修改群组资料		51
	CMD_MODIGROUPACK,		// 修改群组资料应答	52
	CMD_MODIGROUPNOTICE,	// 修改群组通知		53
	CMD_MODIGROUPNOTICEACK, // 修改群组通知应答	54

	CMD_GETGROUP,			// 获取群组信息       55
	CMD_GETGROUPACK,		// 获取群组信息		56

	CMD_MODIMEMBER,			// 添加、删除群组成员		57
	CMD_MODIMEMBERACK,		// 添加、删除群组成员应答	58
	CMD_MODIMEMBERNOTICE,	// 成员变化通知			59
	CMD_MODIMEMBERNOTICEACK,// 成员变化通知应答		60

	CMD_SENDMSG,			// 发送消息				61
	CMD_SENDMSGACK,			// 发送消息应答			62
	CMD_MSGNOTICE,			// 消息通知              63
	CMD_MSGNOTICEACK,		// 消息通知应答			64

	CMD_GETUSERSTATE,		// 获取员工在线状态		65
	CMD_GETUSERSTATEACK,	// 获取员工在线状态应答	66

	CMD_MODIEMPLOYEE,		// 修改多个用户资料		67
	CMD_MODIEMPLOYEEACK,	// 修改多项用户资料应答	68

	CMD_SENDBROADCAST,		// 发送广播				69
	CMD_SENDBROADCASTACK,	// 发送广播应答			70
	CMD_BROADCASTNOTICE,	// 广播通知				71
	CMD_BROADCASTNOTICEACK, // 广播通知应答			72

	CMD_MSGREAD,			// 消息已读				73
	CMD_MSGREADACK,			// 消息已读应答			74
	CMD_MSGREADNOTICE,		// 消息已读通知			75
	CMD_MSGREADNOTICEACK,	// 消息已读通知应答		76

	CMD_GETUSERSIMLIST,		// 获取员工简要信息列表	77
	CMD_GETUSERSIMLISTACK,	// 员工简要信息列表应答	78

	CMD_MSGNOTICECONFIRM,	// 消息通知已接收确认		79
	CMD_MSGNOTICECONFIRMACK,// 消息通知已接收确认应答	80

	CMD_REGULAR_GROUP_UPDATE_REQ,	// 客户端请求更新群组信息. 81
	CMD_REGULAR_GROUP_UPDATE_RSP,	// 对CMD_REGULAR_GROUP_REQ的响应. 82

    CMD_CHECK_TIME_REQ,			// 服务器时间校验请求	83
    CMD_CHECK_TIME_RESP,		// 服务器时间校验应答	84

	CMD_GET_OFFLINE_REQ,		// 离线消息请求		85
    CMD_GET_OFFLINE_RESP,		// 离线消息总数应答	86

	CMD_REFUSEGROUP_REQ,		// 停止群组推送、消息	87
    CMD_REFUSEGROUP_RESP,		// 停止群组推送、消息应答 88

	CMD_QUITGROUP,				//主动退群请求				89
	CMD_QUITGROUPACK,			//主动退群应答				90
	CMD_QUITGROUPNOTICE,		//主动退群通知				91
	CMD_QUITGROUPNOTICEACK,		//主动退群通知应答				92

	CMD_RESETSELFINFO,			//本人信息变更通知联系人请求	93
	CMD_RESETSELFINFOACK,		//本人信息变更通知联系人请求应答	94
	CMD_RESETSELFINFONOTICE,	//用户信息变更通知				95
	CMD_RESETSELFINFONOTICEACK,	//用户信息变更通知应答			96

	CMD_ECWX_SYNC_REQ, /** 网信客户端同步公众账号请求, 97. */
	CMD_ECWX_SYNC_RSP, /** 网信客户端同步公众账号响应, 98. */
	CMD_ECWX_SMSG_REQ, /** 网信客户端向公众账号上行消息请求, 99. */
	CMD_ECWX_SMSG_RSP, /** 网信客户端向公众账号推送消息响应, 100. */
	CMD_ECWX_PACC_NOT, /** 公众平台下行消息至网信客户端通知, 101. */

	CMD_CREATESCHDULE, // 创建、修改日程提醒 102
	CMD_CREATESCHDULEACK, // 创建、修改日程提醒应答103
	CMD_CREATESCHDULENOTICE, // 创建、修改日程提醒通知 104
	CMD_CREATESCHDULENOTICEACK,//创建、修改日程提醒通知应答105

	CMD_GETDATALISTTYPE, //获取人员信息下载方式请求 106
	CMD_GETDATALISTTYPEACK, //获取人员信息下载方式请求应答 107

    CMD_COMPLASTTIMENOTICE, // 服务端发起企业相关最后更新时间的通知           108

	CMD_DELETESCHDULE, // 删除日程提醒 109
	CMD_DELETESCHDULEACK, // 删除日程提醒应答110
	CMD_DELETESCHDULENOTICE, // 删除日程提醒通知 111
	CMD_DELETESCHDULENOTICEACK, // 删除日程提醒通知应答 112
	
	CMD_GROUPPUSHFLAG,  //ios群组消息推送 113
	CMD_GROUPPUSHFLAGACK, //ios群组消息推送修改应答 114

	CMD_IOSBACKGROUND_REQ, // IOS转入后台请求 115
	CMD_IOSBACKGROUND_ACK, // IOS转入后台应答116

	CMD_GETUSERRANK_REQ, // 获取级别(员工所属)请求 117
	CMD_GETUSERRANK_ACK, // 获取级别(员工所属)应答 118

	CMD_GETUSERPROFE_REQ, // 获取业务(员工所属)请求 119
	CMD_GETUSERPROFE_ACK, // 获取业务(员工所属)应答 120
	
	CMD_GETUSERAREA_REQ, // 获取地域(员工所属)请求 121
	CMD_GETUSERAREA_ACK, // 获取地域(员工所属)应答 122

	CMD_GETSPECIALLIST = 130, 		// 130获取特殊用户列表
	CMD_GETSPECIALLISTACK,			// 131获取特殊用户列表应答
	CMD_MODISPECIALLISTNOTICE,		// 132通知变更通知
	CMD_MODISPECIALLISTNOTICEACK,	// 133收到应答

	CMD_CREATEREGULARGROUPNOTICE = 135,	//135 固定组创建通知
	CMD_CREATEREGULARGROUPNOTICEACK,	//136 固定组创建通知应答
	CMD_DELETEREGULARGROUPNOTICE,		//137 固定组删除通知
	CMD_DELETEREGULARGROUPNOTICEACK,	//138 固定组删除通知应答

	CMD_MODIDEPTUSER=145, // 修改员工部门资料                                          145
	CMD_MODIDEPTUSERACK, // 修改员工部门资料应答                           146	
	CMD_MODIDEPTUSERNOTICE, // 修改员工部门资料通知                      147
	CMD_MODIDEPTUSERNOTICEACK, // 修改员工部门资料通知应答       148
	CMD_MODIDEPINFO,   // 修改组织架构资料	                                  149
	CMD_MODIDEPINFOACK,   //修改组织架构资料应答                           150
	CMD_MODIDEPINFONOTICE, // 修改组织架构资料通知           	·151
	CMD_MODIDEPINFONOTICEACK, // 修改组织架构资料通知应答       152
	CMD_GETTOTALLISTTYPE=157, //获取全量信息下载方式请求 157
	CMD_GETTOTALLISTTYPEACK, //获取全量信息下载方式请求应答 158
	CMD_GET_HEAD_ICON_ADD_LIST_REQ,//获取头像变化用户列表请求159
	CMD_GET_HEAD_ICON_ADD_LIST_RSP,//应答

	CMD_APP_SYNC_REQ = 170,     //170   客户端上行至开放平台的同步通知
	CMD_APP_SYNC_ACK,           //171   开放平台下行至客户端的同步应答
	CMD_APP_DATA_REPORT,        //172   客户端上行至开放平台的数据上报
	CMD_APP_TOKEN_NOTICE,       //173   开放平台的token通知
	CMD_APP_PUSH_NOTICE,        //174   开放平台的推送通知  
	
	CMD_ROAMINGDATASYN = 175,	//175	漫游数据同步请求
	CMD_ROAMINGDATASYNACK,		//176	漫游数据同步请求应答
	CMD_ROAMINGDATAMODI,		//177	漫游数据增加、删减请求
	CMD_ROAMINGDATAMODIACK,		//178	漫游数据增加、删减请求应答
	CMD_ROAMINGDATAMODINOTICE,	//179	漫游数据增加、删减通知

	CMD_SUBSCRIBERREQ,			//180	临时订阅请求 //暂时不用
	CMD_SUBSCRIBERACK,			//181	临时订阅请求 //暂时不用
	CMD_GET_STATUS_REQ=182,		//182	获取状态请求
	CMD_NOTICESTATE_ALL,		//183	全量状态通知

	CMD_RELOGINNOTICE,			//184	相同客户端重登录通知（剔重通知）
	CMD_FORBIDDENNOTICE, 		//185   用户禁用通知

	CMD_READMSGSYNCREQ,			//186	已读消息同步请求(通知另一端消息已经在本端查看过了)
	CMD_READMSGSYNCNOTICE,		//187	已读消息同步通知

	CMD_GULARGROUP_PROTOCOL2_CREATENOTICE,	//188 固定组协议2创建通知
	CMD_GULARGROUP_PROTOCOL2_CREATEACK,		//189 固定组协议2创建应答
	CMD_ROBOTSYNCREQ,			//190 机器人同步请求
	CMD_ROBOTSYNCRSP,			//191 机器人同步应答

	CMD_CONTACTSCLEANNOTICE,	//192 通讯录全量更新通知
	CMD_CONTACTSCLEANNOTICERSP,	//193 通讯录全量更新通知应答

	/////////////////////////////////////////////////////////
	//added by rock
	CMD_MSGCANCEL = 196,		// 196 消息召回
	CMD_MSGCANCELACK,		    // 197 消息召回应答
		
	CMD_MSGCANCELNOTICE,		// 198 召回通知
	CMD_MSGCANCELNOTICEACK,     // 199 召回通知应答
	/////////////////////////////////////////////////////////

	CMD_PROTOCOL_V2	=200,		//协议2

	CMD_VIRTUAL_GROUP_REQ = 201,		//虚拟组信息获取请求		
	CMD_VIRTUAL_GROUP_ACK = 202,		//虚拟组信息获取应答		
	CMD_VIRTUAL_GROUP_NOTICE = 203,		//虚拟组信息通知

	CMD_FAVORITE_SYNC_REQ = 206,		//收藏同步请求
	CMD_FAVORITE_SYNC_ACK = 207,		//收藏同步应答

	CMD_FAVORITE_MODIFY_REQ = 208,		//收藏修改（新增、修改、删除）
	CMD_FAVORITE_MODIFY_ACK = 209,		//收藏修改应答
	CMD_FAVORITE_NOTICE = 210,			//收藏通知

	CMD_DEPTSHOWCONFIG_REQ = 211,		//部门显示配置请求
	CMD_DEPTSHOWCONFIG_ACK = 212,		//部门显示配置应答

    CMD_MEETING_INFO_NOTICE     = 213,     //会议基本信息通知
    CMD_MEETING_MBRINFO_NOTICE  = 214,     // 会议成员信息通知
    CMD_MEETING_FILEINFO_NOTICE = 215,     // 会议附件信息通知
    CMD_MEETING_USERINFO_NOTICE = 216,     // 会议账号信息通知
    CMD_MEETING_MSG_NOTICE      = 217,     // 会议提醒消息
    CMD_GET_MEETING_ACCOUNT_INFO = 218,    // 获取全时帐号信息
    CMD_MEETING_LEVEL_NOTICE    =219,      //设置是否是重要会议
    CMD_MEETING_REMARKS_NOTICE=220,        // 会议备注信息通知
} TERM_CMD_TYPE; 


#pragma pack(push, 1)


typedef struct TERM_CMD_HEAD
{
	INT16 wMsgLen;
	INT16 wCmdID;
	INT32 dwSeq;
	char aszMsg[PACKET_MAXLEN];
} TERM_CMD_HEAD;

typedef struct  tagLV1024
{
	enum{MAXLEN=1024};
unsigned short len;
char value[MAXLEN];
} LV1024;

//LV 不同长度包定义

typedef struct  tagLV255
{
	enum{MAXLEN=255};
unsigned char len;
char value[MAXLEN];
} LV255;
//LV 不同长度包定义
typedef struct  tagLV128
{
	enum{MAXLEN=128};
unsigned char len;
char value[MAXLEN];
} LV128;
//LV 不同长度包定义
typedef struct  tagLV64
{
	enum{MAXLEN=64};
unsigned char len;
char value[MAXLEN];
} LV64;
//LV 不同长度包定义
typedef struct  tagLV32
{
enum{MAXLEN=32};
unsigned char len;
char value[MAXLEN];
} LV32;


// 企业信息
typedef struct CompInfo
{
	UINT32 dwCompID; // 企业ID
	INT8 aszCompCode[10]; // 企业代码
	INT8 aszCompName[50]; // 企业名称
	INT8 aszLogo[50]; // 企业LOGO路径
	UINT32 dwEstablish_time; // 成立时间
	UINT32 dwUpdate_time; // 更新时间
} COMPINFO;

typedef enum 
{
	DEPTSHOWTYPE_SHOWNOTHING = 0,
	DEPTSHOWTYPE_SHOWSUBDEPT = 1,
	DEPTSHOWTYPE_SHOWALL = 2,
}DEPTSHOWTYPE;

// 部门信息v1.1
typedef struct DeptInfo
{

	UINT32 dwDeptID;
	UINT32 dwCompID;
	INT8 szCnDeptName[DEPTNAME_MAXLEN+1];//部门中文名
	INT8 szEnDeptName[DEPTNAME_MAXLEN+1];//英文部门名
	INT32 dwPID;
	UINT32 dwUpdateTime;
	UINT8 wUpdate_type; // 更新类型, 1: 新增 2: 修改 3: 删除
	UINT16 wSort; // 排序序号
    char aszDeptTel[TEL_MAXLEN+1]; //部门联系方式
    UINT8 cShowLevel;
} DEPTINFO;

// 用户简要信息v1.1
typedef struct _UserSimplifyInfo
{
	UINT32 dwUserID; //用户ID
	INT8 aszCnUserName[USERNAME_MAXLEN+1]; //姓名
	INT8 aszEnUserName[USERNAME_MAXLEN+1]; //姓名
	INT8 aszUserCode[USERCODE_MAXLEN+1];///帐号
	INT8 cSex; //性别
	UINT8 wUpdate_type; //更新类型, 1: 新增 2: 修改 3: 删除
} USERSimplifyINFO;

// 用户信息V1.1
typedef struct _UserInfo
{
	UINT32 dwUserID; //用户ID
	INT8 aszUserCode[USERCODE_MAXLEN + 1]; //zhanghao号
	INT8 aszCnUserName[USERNAME_MAXLEN+1]; //姓名
	INT8 aszEnUserName[USERNAME_MAXLEN+1]; //姓名
	char aszEmail[EMAIL_MAXLEN + 1]; //邮箱
	INT8 cSex; //性别
	INT8 aszPost[POST_MAXLEN + 1]; //职务
	INT8 aszAdrr[MAX_ADDR_LEN+1];
//	INT8 aszPost[POST_MAXLEN+1]; //职务
	char aszTel[TEL_MAXLEN+1]; //办公电话
	INT8 aszPhone[PHONE_MAXLEN + 1]; //手机号码
	
	char aszPostcode[POSTCODE_MAXLEN+1];
	char aszFax[FAX_MAXLEN+1];
	UINT32 dwUpdateTime;//最后更新时间
	UINT8 wUpdate_type; // 更新类型, 1: 新增 2: 修改 3: 删除
	UINT32 dwBirth; // 生日
	UINT32 dwHiredate; // 入职时间
	INT8   aszSign[SIGN_MAXLEN + 1];
} USERINFO;

// 员工权限
typedef struct _Employee_purview
{
	UINT32 dwID; //权限ID
	UINT32 dwParameter; //属性
} EMPLOYEE_PURVIEW;

// 用户信息V1.1
typedef struct _UserInfoExtend
{
	UINT32 dwCompID; // 企业ID
	UINT32 dwUserID; //用户ID
	char aszPassword[PASSWD_MAXLEN]; // 密码
	INT8   aszLogo[LOGO_MAXLEN+1];
	UINT32 dwLogoUpdateTime;//logo最后更新时间
	INT8   aszSign[SIGN_MAXLEN+1];
	char   aszHomeTel[TEL_MAXLEN+1]; //宅电
	char	aszEmergencyphone[TEL_MAXLEN+1]; //紧急电话
	INT8    cMsgsynType;//  0 PC全收 PC在线，移动端在线不收； 1 两端都收； 2移动端不收，PC全收
	INT8    cUserType;//用户类型：0:正常用户 1:虚拟用户
	INT8    cForbidden;//是否禁止
	UINT32 dwBirth; // 生日
	UINT32 dwUpdateTime;//最后更新时间
	UINT8 wUpdate_type; // 更新类型, 1: 新增 2: 修改 3: 删除
	UINT8 cStatus; // 在线状态 0:离线 1:上线 2:离开
	UINT8 cLoginType; // 登录类型
	UINT16 wPurview;  // 用户权限
	EMPLOYEE_PURVIEW mPurview[MAX_PURVIEW]; // 该企业有属性的内置权限
} USERINFOExtend;

// 员工信息 
typedef struct _Employee
{
	USERINFO tUserInfo;
	USERINFOExtend tUserExtend;
} EMPLOYEE;

// 员工部门信息V1.1
typedef struct _UserDept
{
	
	UINT32 dwDeptID;
	UINT32 dwUserID;
	char aszUserCode[USERCODE_MAXLEN+1];// 工号
	 char aszCnUserName[USERNAME_MAXLEN+1]; // 姓名
	 char aszEnUserName[USERNAME_MAXLEN+1]; // 姓名
	char aszLogo[LOGO_MAXLEN + 1]; // 头像路径
	INT8 cSex; // 性别
	INT16 wSort;//排序
	INT8 cRankID; // 本人级别
	INT8 cProfessionalID; // 本人业务
	UINT16 dwAreaID; // 本人地域
	UINT32 dwUpdateTime;//最后更新时间
	UINT8 wUpdate_type; // 更新类型, 1: 新增 2: 修改 3: 删除
} USERDEPT;

// Guojian Add 2013-12-10
// 级别(员工所属)信息
typedef struct _UserRank
{
	UINT8 cRankID;
	char  aszRankName[RANKNAME_LEN+1]; // 级别名称
	UINT8 wUpdate_type; // 更新类型, 1: 新增 2: 修改 3: 删除
} USERRANK;

// 业务(员工所属)信息
typedef struct _UserProfessional
{
	UINT8 cProfessionalID;
	char  aszProfessionalName[PROFESSNAME_LEN+1]; // 业务名称
	UINT8 wUpdate_type; // 更新类型, 1: 新增 2: 修改 3: 删除
} USERPROFESSIONAL;

// 地域(员工所属)信息
typedef struct _UserArea
{
	UINT16 dwAreaID;
	char aszAreaName[AREANAME_LEN + 1];
	UINT16 dwPID;
	UINT8 wUpdate_type; // 更新类型, 1: 新增 2: 修改 3: 删除
} USERAREA;
// end Guojian Add 2013-12-10

// 服务端返回错误码
typedef enum
{
	RESULT_SUCCESS = 0,
	RESULT_NOLOGIN,			// 未登录 1
	RESULT_RELOGIN,			// 重复登录 2
	RESULT_INVALIDPASSWD,	// 密码错误 3
	RESULT_INVALIDUSER,		// 非法用户 4
	RESULT_REQTIMEOUT,		// 请求超时 5
	RESULT_NOGROUP,			// 没有该群组  6
	RESULT_MSGLEN_OVERLOAD, // 消息长度太长 7
	RESULT_UNKNOWN,			//UNKNOW 8
	RESULT_NOREGULAR_GROUP,	//用户不在 固定组 9
	RESULT_GROUPEXIST,		//群组已存在 10
	RESULT_GROUPCREATE,		//群组创建失败 11
	RESULT_FORBIDDENUSER,	//禁用用户 12
	RESULT_INCALIDREQ,		//无效请求 13
	RESULT_SYSTEM_OVERLOAD, //14 超过整体过载保护（200条/秒） 
	RESULT_SYSTEM_MAX_CONNECT,//15 系统达到最大连接数
	RESULT_USER_IN_BLACKLIST, //16 用户在黑名单中（停止尝试登录）
	RESULT_CLIENT_VERSION_TOO_LITTLE, //17-客户端版本过低(强制升级且是移动端才提示),


	RESULT_CONNECT_SSO_FAIL = 20,   //20 SSO 连接问题
	RESULT_SSO_AD_NOFOUND = 21,     //21 登录时在AD中不存在
	RESULT_SSO_DB_NOFOUND,          //22 登录时在数据库中不存在（可能原因是没有从AD中将用户同步过来）
	RESULT_SSO_SET_ADPASSWD_FAIL,   //23 Ad密码修改失败
	RESULT_SSO_SET_DBPASSWD_FAIL,   //24 db密码修改失败
	RESULT_SSO_SET_RTXPASSWD_FAIL,  //25 rtx密码修改失败
	RESULT_SSO_SET_NCPASSWD_FAIL,   //26 nc密码修改失败
	RESULT_SSO_VISIT_AD_FAIL = 27,  //27 AD服务器拒绝访问
	RESULT_SSO_ORI_PASSWD_ERR,      //28 原密码错误
	RESULT_SSO_IDENTITY_FAIL,       //29 身份验证失败
	RESULT_SSO_CALL_FAIL,           //30 当前调用无效
	RESULT_SSO_NOMEMORY,            //31 没有足够的内存继续执行程序
	RESULT_SSO_CONNECT_AD_FAIL,     //32 无法连接AD服务器
	RESULT_SSO_UPDATE_AD_FAIL,      //33 在更新AD存储区的过程中发生错误
	RESULT_SSO_OTHER_ERR,           //34 其它错误
	RESULT_SSO_USER_OR_PASSWD_ERR,  //35 用户名或密码错误
	RESULT_SSO_USER_FORBID_ERR,     //36 用户被禁用
	RESULT_SSO_USER_EXPIRE_ERR,     //37 账户已经过期
	RESULT_SSO_USER_ORIGINALPASSWD_ERR,//38 密码仍然为初始密码(123321)必须修改密码之后才能访问
	RESULT_SSO_PASSWD_EXPIRE_NEXT_SET, //39 密码已经过期，需要修改密码后才能登录(用户下次登录必须更改密码)
	RESULT_SSO_PASSWD_EXPIRE_ERR,   //40 密码已经过期，需要修改密码后才能登录
	RESULT_SSO_NO_VISIT_POWER,      //41 您没有访问该系统的权限

	RESULT_SSO_IP_ILLEGAL_ERR = 60, //60 请求IP不在TrustAccessorIPs范围内
	RESULT_SSO_USER_OR_PASSWD_EMPTY,//61 用户名或密码为空
	RESULT_SSO_SYSCODE_EMPTY,       //62 系统代码为空
	RESULT_SSO_HTTP_GET_FORBID,     //63 不能使用Get获取数据
	RESULT_SSO_HTTP_POST_FORBID,    //64 不能使用POST获取数据
	RESULT_SSO_HTTP_CONTENTTYPE_ERR,//65 Content-Type 格式错误
	RESULT_SSO_FUNCTION_FORBID,		//66 该功能未启用，无法通过该接口验证用户，请联系管理员。

	RESULT_VIRGTOUP_NOT_EXIT,		//67  虚拟组不存在
	RESULT_VIRGTOUP_OUTOF_SVC,		//68  暂时无法提供服务
	RESULT_VIRGTOUP_SVC_DENIED,		//69  虚拟组服务不能主动给用户发送消息
	RESULT_GROUPMEMBERISVIRTUAL,	//70  群组不能包含虚拟组账号

} RESULT;

// 心跳包结构体
typedef struct _Alive
{
	UINT32 dwUserID;
} ALIVE;
//心跳应答
typedef struct _AliveAck
{
	RESULT result;
} ALIVEACK;

// login type 登录类型
typedef enum
{
	TERMINAL_ANDROID = 1, TERMINAL_IOS, TERMINAL_PC,TERMINAL_MAC,TERMINAL_WINDOWSPHONE 
} TERMINAL_TYPE;


//v1.1 登录请求
typedef struct _Login
{
	char aszVersion[VERSION_MAXLEN];
	LV32 tAccount;	// 登录帐号
	char cLoginType;// 登录类型
	char aszPassword[PASSWD_MAXLEN];
	unsigned char aszMacAddr[MAC_ADDR_MAXLEN];
	LV128 tDeviceToken;	// TOKEN_MAXLEN+1 如果有,1字节长度，TOKEN_MAXLEN=80内容

} LOGIN;

//登录应答时间戳
typedef struct _UpdateTimeStamp
{
	UINT32 dwCompUpdateTime;					// 企业信息最后更新时间
	UINT32 dwDeptUpdateTime;					// 企业组织构架最后更新时间
	UINT32 dwUserUpdateTime;					// 企业员工列表最后更新时间
	UINT32 dwDeptUserUpdateTime;				// 部门与员工最后更新时间
	UINT32 dwPersonalInfoUpdateTime;			// 自己的信息资料
	UINT32 dwPersonalCommonContactUpdateTime;	// 自己的漫游常用联系人信息资料
	UINT32 dwPersonalCommonDeptUpdateTime;		// 自己的漫游常用的常用部门信息资料
	UINT32 dwPersonalAttentionUpdateTime;		// 自己的漫游关注人信息资料
	UINT32 dwGlobalCommonContactUpdateTime;		// 自己的漫游缺省的常用联系人信息资料
	UINT32 dwOthersAvatarUpdateTime;			// 其他人的头像更新时间
	UINT32 dwPersonalAvatarUpdateTime;			// 本人的头像更新时间
	UINT32 dwRegularGroupUpdateTime;			// 固定群时戳
	UINT32 dwUserRankUpdateTime;				// 允许客户端消息撤回时间，单位：秒
	UINT32 dwUserProUpdateTime;					// 业务信息最后更新时间
	UINT32 dwUserAreaUpdateTime;				// 地域信息最后更新时间
	UINT32 dwSpecialListUpdatetime;				// 特殊用户列表最后更新时间
	UINT32 dwSpecialWhiteListUpdatetime;		// 特殊用户白名单最后更新时间
	UINT32 nServerCurrentTime;					// 服务器时间  
} TUpdateTimeStamp;
 
//v1.1登录应答
/*返回值:0成功，1-帐号被禁用 2-帐号无效 3-用户名密码错4-超过整体过载保护（200条/秒） 5-超过最大连接数（3万）
6-用户在黑名单中（停止尝试登录）7-客户端版本过低(强制升级且是移动端才提示),10未知，看描述 1字节，整数, 11连接认证服务失败 12发送路由服务失败*/
typedef struct _LoginAck
{
	INT8		ret;																		// 0成功，
	LV255 	tRetDesc;						// 返回值描述
	LV255	tAuthToken;						// 登录认证token,做单点登陆用	
	LV128 	tCnUserName;					// 用户名字
	LV128	tEnUserName;					// 英文名字
	UINT32	dwSessionID;					// http session id
	UINT32	dwCompID;						// 公司ID
	UINT32	uUserId;
	INT8	sex;
	TUpdateTimeStamp tTimeStamp;			// 所有更新时戳
	/*
	权限：2字节
	短信权限：1-有 0-无
	部门广播权限：1-有 0-无 	部门ID列表：当有 ？
	全网广播权限：1-有 0-无
	远程桌面：1-有 0-无
	应用共享：1-有 0-无
	移动端客户端语音片段：1-有，0-无
	*/
	UINT16 wPurview;						// 用户权限
	EMPLOYEE_PURVIEW mPurview[MAX_PURVIEW];// 权限内容：权限
	UINT32 dwPersonalDisplay;				// 个人资料显示：4字节（每位控制一个字段，最多控制32个字段）
	UINT32 dwPersonalEdit;					// 个人资料可编辑：4字节（每位控制一个字段，最多控制32个字段）
	INT8   cDeptUserLanguageDisplay;// 部门、人员中英文显示：1字节（2位代表部门中文-00为纯中文/01为中文+英文，
											// 2位代表部门英文-00为纯英文/01为英文+中文，
											// 2位代表人员中文-00为纯中文/01为中文+英文，
											// 2位代表人员英文-00为纯英文/01为英文+中文）
	UINT16 wGroupMaxMemberNum;				// 讨论组最大人数：2字节整数
	UINT16 wPCMaxSendFileSize;				// PC文件最大发送大小：单位为M，整数，2字节
	UINT8  cMobileMaxSendFileSize;			// 移动客户端文件最大发送大小：单位为M，整数，1字节
	UINT8  cPCGetStatusInterval;			// PC客户端拉取时间间隔：单位分，整数，1字节
	UINT8  cPCSubscribeInterval;			// PC客户端临时订阅超时时间：单位为分，整数，1字节（该值同时为超时检查间隔）
	UINT8  cMobileGetStatusInterval;		// 移动客户端拉取状态超时时间：单位为分，整数，1字节（该值同时为超时检查间隔
	UINT16  wPCTempSubscribeMaxNum;			// PC客户端临时订阅列表最大人数（用户ID订阅方式）：整数,2字节，超过则清除最开始的人
	UINT16  wGetStatusMaxNum;				// 客户端状态拉取最大人数:  2字节，整数
	UINT16  wPCAliveMaxInterval;			// PC客户端心跳包时间间隔：单位为秒，整数，2字节
	UINT16  wMobileAliveMaxInterval;		// mobile客户端心跳包时间间隔：单位为秒，整数，2字节
	UINT16  wPCSMSMaxLength;				// PC短信每条发送字符最大值：2字节，单条拆分字符数：2字节
	UINT16  wPCSMSSplitLength;				// PC短信拆分长度
	UINT8   cMobileServiceExpiry;			// 移动客户端接入服务地址有效时间：单位小时，1字节
	UINT16  wMobileUploadRecentContact;		// 移动端登录后，获取状态时，上传的最近联系人，最大人数，2字节
	UINT16  wPCUploadRecentContact;			// PC登录后，获取状态时，上传的最近联系人，最大人数，2字节
	UINT8   cModifyPersonalAuditPeriod;		// 修改个人资料审核时间：1字节，小时
	UINT8	cMsgSynType;					// 消息同步类型

	char	aszContactPath[MAX_CONTANTSDOWNLOADPATH_LEN];	//通讯录DB文件下载路径
	UINT32	dwRobotInfoUpdatetime;		// 机器人信息最后更新时间戳

} LOGINACK;
 
 
//用户状态v1.1
typedef struct _user_status
{
	//顺序 0离线 1:在线 2: 离开 3:手机在线
	UINT16	wNum[4];		//各个状态的用户数
	UINT32	dwUserID[MAX_USERSTATUS_NUM];	//用户列表
}user_status;

// 用户在线状态变化通知
typedef struct _UserStatusNotice
{
	UINT32 dwUserID;
	UINT8 cStatus;		// 0:离线 1:在线 2:离开 3:退出
	UINT8 cLoginType;	// 登录类型
} USERSTATUSNOTICE;

//v1.1 用户状态变化列表
typedef struct _UserStatusNoticeList
{
	UINT32 dwUserStatusNum;//用户数
	USERSTATUSNOTICE szUserStatus[MAX_USERSTATUS_NUM];
}TUserStatusList;

// 用户在线状态变化通知集合
typedef struct _UserStatusSetNotice
{
	UINT16 wCurrNum;  // 本页个数
    char   strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} USERSTATUSSETNOTICE;
//登出、注销
typedef struct _Logout
{
	UINT32 dwUserID;
	INT8 cStatus; // 0: 离线 1: 在线 2:离开 3:退出
    INT8 cLoginType; //登录类型
    INT8 cManual; //手动退出
} LOGOUT;
//登出、注销应答
typedef struct _LogoutAck
{
	RESULT result;
	INT8 cStatus; // 0:离线 1:在线 2: 离开 3:退出
} LOGOUTACK;

// 修改用户资料
typedef struct _ModiInfo
{
	UINT32 dwUserID;
	char cModiType; // 0: 性别 1: 籍贯 2: 出生日期 3: 住址 4:办公电话号码 5: 手机号码 6: 密码 7:头像ID 8:个人签名 9:权限 10:宅电 11:紧急联系手机 14:修改邮箱  100:修改多项资料
	UINT8 cLen; // 修改内容长度
#ifdef _TAIHE_FLAG_
	INT8 aszModiInfo[MODIINFO_MAXLEN_EX];	// 修改内容
#else
	INT8 aszModiInfo[MODIINFO_MAXLEN];		// 修改内容
#endif
} MODIINFO;

typedef struct _ModiDeptUser
{
	UINT32  dwUserID;
	char    cModiType;  // 0:部门id   1: 姓名 2: 头像 3: 性别 4 : 本人级别5:本人业务6:本人地域 100:所有可修改项
	INT8 	cLen; // 修改内容长度
	INT8    aszModiInfo[MODIINFO_MAXLEN]; // 修改内容
}MODIDEPTUSER;

typedef struct _ModiDeptInfo
{
	UINT32  dwDeptID;
	char    cModiType; // 0:部门名称  1: 上级部门ID 2: 排序序号 3: 部门联系方式100:  所有可修改项
    INT8 	cLen; // 修改内容长度
	INT8    aszModiInfo[MODIINFO_MAXLEN]; // 修改内容
}MODIDEPTINFO;

//修改用户信息应答
typedef struct _ModiInfoAck
{
	RESULT result;
} MODIINFOACK;

// 修改多项用户资料
typedef struct _ModiEmployee
{
	UINT32 dwUserID;
	EMPLOYEE sEmployee;
} MODIEMPLOYEE;

typedef struct _ModiEmployeeAck
{
	RESULT result;
} MODIEMPLOYEEACK;

// 用户资料修改通知
typedef struct _ModiInfoNotice
{
	UINT32 dwUserID; // 更新者
	UINT8 cModiType; // 0: 性别 1: 籍贯 2: 出生日期 3: 住址 4:办公电话号码 5: 手机号码 6: 密码 7:头像ID 8:个人签名 9:权限 10:宅电 11:紧急联系手机 100:修改多项资料
	EMPLOYEE sEmployee;
} MODIINFONOTICE;

typedef struct _ModiInfoNoticeAck
{
	int dwUserID;
} MODIINFONOTICEACK;

// 获取企业信息
typedef struct _GetCompInfo
{
	UINT32 dwUserID;
	UINT32 dwCompID;
} GETCOMPINFO;

typedef struct _GetCompInfoAck
{
	RESULT result;
	COMPINFO sCompInfo;
} GETCOMPINFOACK;


//下载文件类型
typedef struct _DownloadFileType
{
UINT8  cDownLoadType; // , 1: 文件全量下载 2:变化差量下载
char   strDownLoadPath[FILEPATHLEN];
}TDownloadFileType;

// 获取部门信息//v1.1
typedef struct _GetDeptList
{
	UINT32 dwUserID;
	UINT32 dwCompID;
	UINT8  cLoginType;       // 登录类型
	UINT32 dwLastUpdateTime; // 最后更新时间
} GETDEPTLIST;

typedef struct _GetDeptListAck//v1.1
{
    UINT16 nPacketLen;
	INT8 cPacketType;//0 返回增量的部门信息,1返回文件下载的结构体：strPacketBuff数据中装载结构体： TDownloadFileType
	RESULT result;//
	UINT16 wCurrPage; // 当前页数 0:end
	UINT16 wCurrNum;  // 本页个数
    char   strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} GETDEPTLISTACK;

// 获取全量通讯录
typedef struct _GetTotalListType
{
	UINT32 dwUserID;
	UINT32 dwCompID;
    UINT8  cLoginType;
    UINT8  cNetType;
	UINT32 dwLastUpdateTime; // 最后更新时间
} GETTOTALLISTTYPE;
// 获取全量通讯录应答
typedef struct _GetTotalListTypeAck
{
    UINT16 nPacketLen;
	RESULT result;
	UINT8  cDownLoadType; // , 1: 文件全量下载 2:变化增量下载
	char   strDownLoadPath[FILEPATHLEN];
    UINT32 nFilePwd; //解压密码
    char  aesFilePwd[AES_FILE_PWD_LEN]; //解密文件密码
} GETTOTALLISTTYPEACK;

//获取员工信息的方法请求参数结构体
typedef struct _GetDataListTypeParameter
{
	UINT8  nTermType;
	UINT8  nNetType;
	UINT8  cUpdataTypeDept;          //0: 部门未请求  1;请求
	UINT8  cUpdataTypeDeptUser;      //0: 部门人员未请求  1;请求
	UINT8  cUpdataTypeUser;          //0: 人员未请求  1;请求
	UINT32 dwLastUpdateTimeDept;     //部门最后更新时间
	UINT32 dwLastUpdateTimeDeptUser; //部门人员最后更新时间
	UINT32 dwLastUpdateTimeUser;     //人员最后更新时间
}GETDATALISTTYPEPARAMETET;

// 获取员工信息的方法请求
typedef struct _GetDataListType
{
	UINT32 dwUserID;
	UINT32 dwCompID;
    UINT8  cLoginType;
    UINT8  cNetType;
	UINT8  cUpdataTypeDept;        //0: 部门未请求  1;请求
	UINT8  cUpdataTypeDeptUser;    //0: 部门人员未请求  1;请求
	UINT8  cUpdataTypeUser;        //0: 人员未请求  1;请求
	UINT32 dwLastUpdateTimeDept;     //部门最后更新时间
	UINT32 dwLastUpdateTimeDeptUser; //部门人员最后更新时间
	UINT32 dwLastUpdateTimeUser;     //人员最后更新时间
} GETDATALISTTYPE;

// 获取员工信息的方法应答
typedef struct _GetDataListTypeAck
{
    UINT16  nPacketLen;
	RESULT  result;
	UINT8   cUpdataTypeDept;         // 0：部门全量    1：部门增量
	UINT8   cUpdataTypeDeptUser;     // 0：部门人员全量 1：部门人员增量
	UINT8   cUpdataTypeUser;         // 0：人员全量    1：人员增量

	UINT8   cDownLoadTypeDept;       //0:文件下载  1:数据包下载（即原来的老流程）
	UINT8   cDownLoadTypeDeptUser;   //0:文件下载  1:数据包下载（即原来的老流程）
	UINT8   cDownLoadTypeUser;       //0:文件下载  1:数据包下载（即原来的老流程）

	UINT8   strDownLoadPathDept[100];       //部门文件下载路径	
	UINT8   strFilePwdDept[21];             //部门通讯录文件解密密码
	UINT8   strDownLoadPathDeptUser[100];   //部门人员下载路径	
	UINT8   strFilePwdDeptUser[21];         //部门人员通讯录文件解密密码
	UINT8   strDownLoadPathUser[100];       //人员下载路径	
	UINT8   strFilePwdUser[21];             //人员通讯录文件解密密码

	UINT32  dwLastUpdateTimeDept;          // 部门最后更新时间
	UINT32  dwLastUpdateTimeDeptuser;      // 部门人员最后更新时间
	UINT32  dwLastUpdateTimeUser;          // 人员最后更新时间

} GETDATALISTTYPEACK;

// 获取员工列表//v1.1
typedef struct _GetUserList
{
	UINT32 dwUserID;
	UINT32 dwCompID;
	UINT8  cLoginType;
	UINT32 dwLastUpdateTime; // 最后更新时间
} GETUSERLIST;

// 获取员工信息列表应答//v1.1
typedef struct _GetUserListAck
{
    UINT16 nPacketLen;
	INT8   cPacketType;//0 返回增量的员工信息,1返回文件下载的结构体：strPacketBuff数据中装载结构体： TDownloadFileType
	RESULT result;
	UINT16 wCurrPage; // 当前页数, 0: end
	UINT16 wCurrNum; // 本页员工个数
	char   strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} GETUSERLISTACK;
//用户列表
typedef struct UserListMobile
{
    UINT32 dwUserID;
    UINT8  wUpdate_type; //更新类型, 1: 新增 2: 修改 3: 删除
}UserListMobile;

// 获取员工简要信息列表
typedef struct _GetUserSimList
{
	UINT32 dwUserID;
	UINT32 dwCompID;
	UINT32 dwLastUpdateTime; // 最后更新时间
} GETUSERSIMLIST;

// 获取员工简要信息列表应答
typedef struct _GetUserSimListAck
{
	RESULT result;//
	UINT16 wCurrPage; // 当前页数, 0: end
	UINT16 wCurrNum; // 本页员工个数
	USERSimplifyINFO aUserInfo[MAXNUM_PAGE_USERSIMP];
} GETUSERSIMLISTACK;

// 获取员工部门信息//v1.1
typedef struct _GetUserDept
{
	UINT32 dwUserID;
	UINT32 dwCompID;
	UINT8  cLoginType;
	UINT32 dwLastUpdateTime;
} GETUSERDEPT;

// 获取部门人员信息列表应答//v1.1
typedef struct _GetUserDeptAck
{
    UINT16 nPacketLen;
	INT8   cPacketType;//0返回增量的bu men 员工信息,1返回文件下载的结构体：strPacketBuff数据中装载结构体： TDownloadFileType
	RESULT result;////0 
	UINT16 wCurrPage; // 当前页数 0: end
	UINT16 wCurrNum;  // 本页员工个数
	char   strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} GETUSERDEPTACK;

// 获取所有员工在线状态
typedef struct _GetUserStateList
{
	UINT32 dwUserID;
	UINT32 dwCompID;
} GETUSERSTATELIST;

// 获取所有员工在线状态应答
typedef struct
{
	UINT32 dwUserID;
	INT8 cState; // 0:离线 1:上线 2:离开 3:退出
	UINT8 cLoginType; // 登录类型
} USERSTATE;
//获取用户状态列表应答
typedef struct _GetUserStateListAck
{
	RESULT result;
	UINT16 wCurrPage; // 当前页数 0: end
	UINT16 wCurrNum;
	USERSTATE aUserState[MAXNUM_PAGE_USERSTATE];
} GETUSERSTATELISTACK;

// 获取员工详细信息
typedef struct _GetEmployeeInfo
{
	UINT32 dwUserID;
	int nType;
} GETEMPLOYEEINFO;

// 获取员工详细信息列表应答
typedef struct _GetEmployeeInfoAck
{
	RESULT result;
	int nType;
	UINT32 dwUserID;
	char   strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} GETEMPLOYEEACK;

// Guojian Add 2013-12-10
// 获取企业员工的级别、业务、地域信息请求
// 通过命令字来区分是获取级别还是业务、地域
typedef struct _GetUserRPA
{
	UINT32 dwUserID;
	UINT32 dwCompID;
	UINT8  cLoginType;       // 登录类型
	UINT32 dwLastUpdateTime; // 最后更新时间
} GETUSERRPA;

// 获取企业员工的级别、业务、地域信息应答
typedef struct _GetUserRPAAck
{
    UINT16 nPacketLen;
	RESULT result;
	UINT16 wCurrPage; // 当前页数 0: end
	UINT16 wCurrNum;  // 本页个数
	char   strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} GETUSERPAASK;
// end Guojian Add 2013-12-10

//创建群组
typedef struct _CreateGroup
{
	UINT32 dwUserID;
	char aszGroupID[GROUPID_MAXLEN];
	char aszGroupName[GROUPNAME_MAXLEN + 1];
    UINT32 dwTime;
	UINT16 wUserNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} CREATEGROUP;
//创建群组应答
typedef struct _CreateGroupAck
{
	RESULT result;
	char aszGroupID[GROUPID_MAXLEN];
	char aszGroupName[GROUPNAME_MAXLEN + 1];
    UINT32 dwTime;
	UINT16 wUserNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} CREATEGROUPACK;
//创建群组通知
typedef struct _CreateGroupNotice
{
	UINT32 dwUserID; // creater id
	char aszGroupID[GROUPID_MAXLEN];
	char aszGroupName[GROUPNAME_MAXLEN + 1];
    UINT32 dwTime;
	UINT16 wUserNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} CREATEGROUPNOTICE;
//修改群组信息
typedef struct _ModiGroup
{
	UINT32 dwUserID;
	char aszGroupID[GROUPID_MAXLEN];
	char cType; // 0: group name; 1: group note
	char aszData[GROUPNAME_MAXLEN + 1];
    UINT32 dwTime;
} MODIGROUP;
//修改群组信息应答
typedef struct _ModiGroupAck
{
	RESULT result;
	char aszGroupID[GROUPID_MAXLEN];
	char cType; // 0: group name; 1: group note
	char aszData[GROUPNAME_MAXLEN + 1];
    UINT32 dwTime;
} MODIGROUPACK;
//修改群组信息通知
typedef struct _ModiGroupNotice
{
	char aszGroupID[GROUPID_MAXLEN];
	UINT8 cType; // 0: group name; 1: group note
	INT8 aszData[GROUPNAME_MAXLEN + 1];
    UINT32 dwUserID;
    UINT32 dwTime;
} MODIGROUPNOTICE;

typedef struct _ModiGroupNoticeAck
{
	UINT32 dwUserID;
	char aszGroupID[GROUPID_MAXLEN];
} MODIGROUPNOTICEACK;

//增加、删除群组成员
typedef struct _ModiMember
{
	UINT32 dwUserID;
	char aszGroupID[GROUPID_MAXLEN];
	UINT8 cOpType; // 0: 添加 1: 删除
    UINT32 dwTime; //Guojian Add 2013-08-24
	UINT16 wNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} MODIMEMBER;

//增加、删除群组成员应答
typedef struct _ModiMemberAck
{
	RESULT result;
	char aszGroupID[GROUPID_MAXLEN];
	UINT8 cOpType; // 0: 添加 1: 删除
    UINT32 dwTime; //Guojian Add 2013-08-24
	UINT16 wNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} MODIMEMBERACK;

//新增、删除群组成员通知
typedef struct _ModiMemberNotice
{
	UINT32 dwModiID; // 修改者 ID
	char aszGroupID[GROUPID_MAXLEN];
	UINT8 cOpType; // 0:添加 1:删除
    UINT32 dwTime; //Guojian Add 2013-08-24
	UINT16 wNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} MODIMEMBERNOTICE;

//新增、删除群组成员通知应答
typedef struct _ModiMemberNoticeAck
{
	UINT32 dwUserID;
	char aszGroupID[GROUPID_MAXLEN];
} MODIMEMBERNOTICEACK;

//Guojian Add 2013-08-23
//主动退出群组
typedef struct _QuitGroup
{
	UINT32 dwUserID;
	char aszGroupID[GROUPID_MAXLEN];
} QUITGROUP;

//主动退出群组应答
typedef struct _QuitGroupAck
{
    INT16 nReturn;
    char aszGroupID[GROUPID_MAXLEN];
} QUITGROUPACK;

//主动退出群组通知
typedef struct _QuitGroupNotice
{
	UINT32 dwUserID;
    UINT32 dwTime; //Guojian Add 2013-08-24
	char aszGroupID[GROUPID_MAXLEN];
} QUITGROUPNOTICE;

//主动退出群组通知应答
typedef struct _QuitGroupNoticeAck
{
    INT16 nReturn;
} QUITGROUPNOTICEACK;

//获取群组信息
typedef struct _GetGroupInfo
{
	UINT32 dwUserID;
	char aszGroupID[GROUPID_MAXLEN];
} GETGROUPINFO;

//获取群组信息应答
typedef struct _GetGroupInfoAck
{
	RESULT result;
	UINT32 dwCreaterID; // 创建人用户ID
	char aszGroupID[GROUPID_MAXLEN];
	INT8 aszGroupName[GROUPNAME_MAXLEN + 1];
	INT8 aszGroupNote[GROUPNAME_MAXLEN + 1];
    UINT32 dwTime; //Guojian Add 2013-08-24
	UINT16 wNum; // 用户数
	UINT32 aUserID[MAXNUM_PAGE_USERID]; // 用户ID
} GETGROUPINFOACK;

enum im_msg_type
{
	IM_MSGTYPE_TEXT = 0,	//普通文本消息
	IM_MSGTYPE_IMG  = 1,	//普通图片消息
	IM_MSGTYPE_VOICE = 2,	//普通语音消息
	IM_MSGTYPE_VIDEO = 3,	//普通视频消息
	IM_MSGTYPE_FILE	= 4,	//普通文件消息
	IM_MSGTYPE_P2P	= 5,	//P2P捂手消息
	IM_MSGTYPE_FILERECVED = 6,	//文件接收回复消息
	IM_MSGTYPE_LONGTEXT = 7,	//长文本消息
	IM_MSGTYPE_PCAUTO = 8,	//PC自动回复消息

	IM_MSGTYPE_PUSH	= 10,	//公众平台推送消息

	IM_MSGTYPE_BROADCAST = 20,	//广播消息
	IM_MSGTYPE_SMS_SEND = 21,	//短信发送
	IM_MSGTYPE_SMS_RECEIPT = 22,//短信回执
	IM_MSGTYPE_SMS_RSP = 23,	//平台的短信回复
	IM_MSGTYPE_SMS_PUSH = 24,	//万达平台的IM消息
	IM_MSGTYPE_SMS_ALERT = 25,	//万达平台的IM提醒
	IM_MSGTYPE_ROBOT_SUGGEST = 26, //机器人智能输入提示

	IM_MSGTYPE_MSG_RECALL = 50, //消息召回
	IM_MSGTYPE_GROUP_ANNO= 51, //群公告
};

//发送消息
typedef struct _SendMSG
{
	UINT32 dwUserID; // sender id
	UINT32 dwRecverID; // recver id
	INT8 aszGroupID[GROUPID_MAXLEN]; // 群组ID
	UINT64 dwMsgID; // 客户端消息ID
	UINT8 cIsGroup; // 是否是群组聊天 0:非群组聊天; 1:群组聊天
	UINT8 cType; // 0: 文本 1: 图片 2: 语音 3:视频 4:P2P握手请求 5:其它
    UINT8 cRead; // 1: 发送已读 0:不发送已读
	UINT8 cAllReply; // 是否是一呼百应消息 0:不是 1:一呼百应 2:一呼万应回复消息
	UINT64 dwSrcMsgID; // 一呼万应源消息ID
    UINT32 nSendTime; //发送时间
	UINT8 nMsgTotal;//消息总条数
	UINT8 nMsgSeq;//一条大消息的第几条消息，例如：1，2，3
	UINT16 dwMsgLen;
	char aszMessage[MSG_MAXLEN];
} SENDMSG;

//文件结构体
// 当SENDMSG中的cType为1、2或3时, aszMessage为如下:
typedef struct _FILE_META
{
	UINT32 dwFileSize;
	char aszFileName[FILENAME_MAXLEN + 1];
	char aszURL[URL_MAXLEN + 1];
} FILE_META;
//发送消息应答
typedef struct _SendMSGAck
{
	RESULT result;
	UINT64 dwMsgID;
} SENDMSGACK;

//消息通知
typedef struct _MSGNotice
{
	UINT32 dwSenderID;
	UINT32 dwRecverID; // 用户ID
	INT8 aszGroupID[GROUPID_MAXLEN]; // 群组ID
	UINT64 dwMsgID; // 消息ID
	INT8 cIsGroup; // 是否是群组聊天
    UINT32 dwGroupTime;// 群组变更时间
	INT8 cMsgType; // 消息类型
	INT8 cOffline; // 是否离线消息 1、离线消息
	UINT8 cRead; // 1: 发送已读 0:不发送已读
	UINT8 cAllReply; // 是否是一呼百应消息 0:不是 1:一呼百应 2:一呼万应消息回复
	UINT64 dwSrcMsgID; // 一呼万应消息ID
	UINT8 nMsgTotal;//拆分消息总条数 同批次消息总数，不超过256
	UINT8 nMsgSeq;//一条大消息的第几条消息，例如：1，2，3
	UINT16 nOffMsgTotal;// 离线消息总数
	UINT16 nOffMsgSeq;//离线消息第几条
	UINT16 dwMsgLen;
	UINT32 dwSendTime; // 发送时间
	UINT32 dwNetID;
	char aszMessage[MSG_MAXLEN];
} MSGNOTICE;

//消息通知应答
typedef struct _MSGNoticeAck
{
	UINT32 dwUserID; // 发送者
	UINT64 dwMsgID;
	UINT32 dwNetID;
} MSGNOTICEACK;

typedef struct _MSGNoticeAckCache
{
	UINT8  cTerminalType; //接收方终端类型
	UINT32 dwUserID; // 发送者
	UINT64 dwMsgID;
} MSGNOTICEACKCACHE;

//当消息类型为4:P2P握手请求时，接收方发送消息接收确认到发送方
typedef struct _MSGNoticeConfirm
{
	UINT32 dwSenderID;
	UINT32 dwRecverID; // 用户ID
	UINT64 dwMsgID; // 消息ID
	UINT32 dwMsgLen;
	char aszMessage[MSG_MAXLEN];
} MSGNOTICECONFIRM;

//回执消息
typedef struct _MSGRead
{
	UINT32 dwSenderID;
	UINT32 dwRecverID;
	UINT64 dwMsgID;
	UINT8  cMsgType; //0:回执 1:消息已读(已听)
    UINT32 dwTime; // 消息被读时间
} MSGREAD;
//回执消息应答
typedef struct _MsgReadAck
{
	RESULT result;
	UINT32 dwSenderID;
	UINT32 dwRecverID;
	UINT64 dwMsgID;
} MSGREADACK;

//回执消息通知
typedef struct _MsgReadNotice
{
	UINT32 dwSenderID;
	UINT32 dwRecverID;
	UINT64 dwMsgID;
	UINT8  cMsgType; //0:回执 1:消息已读(已听)
	UINT32 dwTime; // 消息被读时间
} MSGREADNOTICE;

typedef struct _MsgReadNoticeAck
{
	UINT32 dwSenderID;
	UINT32 dwRecverID;
	UINT64 dwMsgID;
} MSGREADNOTICEACK;

// 广播
typedef struct Broadcast_Recver
{
	UINT32 dwRecverID; // UserID or DeptID
	UINT8 cIsDept; // the flag of dwRecverID
} BROADCAST_RECVER;

//广播消息
typedef struct _SendBroadcast
{
	UINT32 dwUserID; // 发送者ID
	BROADCAST_RECVER aRecver[MAXNUM_RECVER_ID];
	UINT16 wRecverNum; // Recver个数
	UINT64 dwMsgID; // 消息ID
    UINT32 dwTime; //发送时间
    UINT8  cMsgType;								//0:文字
   													//1:图片
                                                    //2:语音
	UINT8 cAllReply; // 是否是一呼万应广播消息,1:一呼万应
	UINT64 dwSrcMsgID; // 一呼万应源消息ID
	char aszTitile[MAX_TITLELEN];
	UINT16 dwMsgLen; // 消息长度
	char aszMessage[MSG_MAXBROADLEN];
} SENDBROADCAST;
//广播消息应答
typedef struct _SendBroadcastAck
{
	RESULT result;
	UINT64 dwMsgID;
} SENDBROADCASTACK;

// 广播消息通知
typedef struct _BroadcastNotice
{
	UINT32 dwSenderID;
	UINT32 dwRecverID;
	UINT64 dwMsgID;
	UINT32 dwSendTime;
    UINT8  cMsgType;								//0:文字
   													//1:图片
                                                    //2:语音
	UINT8 cAllReply; // 是否是一呼万应广播消息,1:一呼万应
	UINT64 dwSrcMsgID; // 一呼万应源消息ID
	char aszTitile[MAX_TITLELEN];
	UINT16 dwMsgLen;
	char aszMessage[MSG_MAXBROADLEN];
} BROADCASTNOTICE;

// 时间校验
typedef struct
{
	UINT32 dwSerial;
} CHECK_TIME_REQ;

// 时间校验应答
typedef struct
{
	UINT32 dwSerial;
    UINT32 timeNow;
} CHECK_TIME_RESP;

//ios群组消息推送修改
typedef struct 
{
	INT8		aszGroupID[GROUPID_MAXLEN];
	UINT32	dwUserID;
	UINT32    dwPushFlag; //ios的群消息推送标志，0：推送，1：不推送
}GROUP_PUSH_FLAG;

typedef struct _GroupPushFlagAck
{
	UINT8  aszGroup[GROUPID_MAXLEN];				//群组ID
	RESULT result;						//返回应答结果  0:修改成功，6：未登陆，8：unknown
}GROUPPUSHFLAGACK;

// 离线消息请求
typedef struct
{
	UINT32 dwUserID;
	UINT8 cLoginType; // 登录类型
} GET_OFFLINE_REQ;

// 离线消息总数应答
typedef struct
{
	UINT32 dwOfflineMsgCount;	//离线消息总数
} GET_OFFLINE_RESP;

// 屏蔽群组信息
typedef struct
{
	UINT32 dwUserID;
    char aszGroupID[GROUPID_MAXLEN];
    char cRefuseType;  //1、屏蔽推送信息，2、屏蔽消息下发
} REFUSE_GROUPMSG_REQ;

// 屏蔽群组信息应答
typedef struct
{
    UINT16 nRet;
} REFUSE_GROUPMSG_RESP;

//Guojian Add 2013-08-23
//本人信息变更通知联系人请求
typedef struct _ResetSelfInfo
{
	UINT32 dwUserID;
	char cModiType; // 0: 性别 1: 籍贯 2: 出生日期 3: 住址 4:办公电话号码 5: 手机号码 6: 密码 7:头像ID 8:个人签名 9:权限 10:宅电 11:紧急联系手机  14:修改邮箱 100:修改多项资料
	INT8 cLen; // 修改内容长度
	INT8 aszModiInfo[MODIINFO_MAXLEN]; // 修改内容
    INT8 cSigleNum; //单人总数
    UINT32 dwDestUserID[DESTSINGLENUM]; //被通知用户
    INT8 cGroupNum; //群组总数
	char aszGroupID[DESTGROUPNUM][GROUPID_MAXLEN];
} RESETSELFINFO;

//本人信息变更通知联系人请求应答
typedef struct _ResetSelfInfoAck
{
    INT16 nReturn;
} RESETSELFINFOACK;

//用户信息变更通知
typedef struct _ResetSelfInfoNotice
{
	UINT32 dwUserID;
	char cModiType; // 0: 性别 1: 籍贯 2: 出生日期 3: 住址 4:办公电话号码 5: 手机号码 6: 密码 7:头像ID 8:个人签名 9:权限 10:宅电 11:紧急联系手机  14:修改邮箱 100:修改多项资料
	INT8 cLen; // 修改内容长度
	INT8 aszModiInfo[MODIINFO_MAXLEN]; // 修改内容
} RESETSELFINFONOTICE;

//用户信息变更通知应答
typedef struct _ResetSelfInfoNoticeAck
{
    INT16 nReturn;
} RESETSELFINFONOTICEACK;

//创建、修改日程提醒
typedef struct _CreateSchedule
{
	UINT32 dwUserID;
	char aszScheduleID[GROUPID_MAXLEN];
	char aszScheduleName[SCHEDULENAME_LEN + 1];
	char aszScheduleDetail[SCHEDULEDETAIL_LEN + 1];
	char aszGroupID[GROUPID_MAXLEN];//GROUPID
	UINT32 dwBeginTime;
	UINT32 dwEndTime;
	UINT8  cType; //提醒类型 0:正点,1:5分钟,2:10分钟,3:30分钟,4:1小时,5:1天前
	UINT8  cOperType; //操作类型 1:创建，2:修改
	UINT16 wUserNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} CREATESCHEDULE;

//创建、修改日程提醒
typedef struct _CreateScheduleAck
{
	RESULT result;
	UINT8  cOperType; //操作类型 1:创建，2:修改
	char aszScheduleID[GROUPID_MAXLEN]; //按照GROUPID的规则
} CREATESCHEDULEACK;

//创建、修改日程提醒通知
typedef struct _CreateScheduleNotice
{
	UINT32 dwUserID;
	char aszScheduleID[GROUPID_MAXLEN]; //按照GROUPID的规则
	char aszScheduleName[SCHEDULENAME_LEN + 1];
	char aszScheduleDetail[SCHEDULEDETAIL_LEN + 1];
	char aszGroupID[GROUPID_MAXLEN];
	UINT32 dwBeginTime;
	UINT32 dwEndTime;
	UINT8  cType; //提醒类型 0:正点,1:5分钟,2:10分钟,3:30分钟,4:1小时,5:1天前
	UINT8  cOperType; //操作类型 1:创建，2:修改
	UINT16 wUserNum;
	UINT32 aUserID[MAXNUM_PAGE_USERID];
} CREATESCHEDULENOTICE;

//创建、修改日程提醒通知应答
typedef struct _CreateScheduleNoticeAck
{
	char aszScheduleID[GROUPID_MAXLEN]; //按照GROUPID的规则
} CREATESCHEDULENOTICEACK;

//删除日程提醒
typedef struct _DeleteSchedule
{
	UINT32 dwUserID;
	char aszScheduleID[GROUPID_MAXLEN];
	char aszGroupID[GROUPID_MAXLEN];
}DELETESCHEDULE;

//删除日程提醒应答
typedef struct _DeleteScheduleAck
{
	RESULT result;
	char   aszScheduleID[GROUPID_MAXLEN];
}DELETESCHEDULEACK;

typedef struct _CompLastTimeNotice
{
	UINT32 dwCompID;              // 企业ID
	UINT32 dwDeptUpdateTime;      // 企业组织构架最后更新时间
    UINT32 dwDeptUserUpdateTime;  // 部门与员工最后更新时间
	UINT32 dwUserUpdateTime;      // 企业员工列表最后更新时间
	UINT32 vgts;                  // 固定组最后更新时间.
} COMPLASTTIMENOTICE;

//IOS转后台请求
typedef struct _IOSBACKGROUND_REQ
{
	UINT32 dwUserID;		//用户ID
	UINT32 dwPushMsgCount;//推送消息计数
}IOSBACKGROUNDREQ;


//IOS转后台应答
typedef struct _IOSBACKGROUND_ACK
{
    char cResult;//处理结果0成功
}IOSBACKGROUNDACK;

//特殊用户结构体
typedef  struct  _special_list
{
	UINT32  dwSpecialID;		//特殊用户或部门ID
	UINT8	cOpType;		//操作类型 0：增加 1：删除
	UINT8 	cIdType;			//ID 类型
	UINT8	cHideType;		//隐藏类型
}SpecialList_t;

//获取特殊用户列表请求结构体
typedef	struct  _GetSpecialList
{
	UINT32  dwUserID;		//普通用户ID
	UINT8   cDeptNum;//所在部门数
	UINT32  dwDepID[MAXNUM_USERIN_DEPT];		//部门ID
	UINT32	nSpecialTme;		//特殊用户时间戳
	UINT32	nWhiteTime;		//白名单时间戳
	UINT8   cLoginType;		//登录类型
	UINT8   cPageSeq;		//第几页默认就一页
}GETSPECIALLIST; 
//白名单
typedef  struct  _white_list
{
	UINT32  dwSpecialID;		//特殊用户或部门ID
	UINT32  dwWhiteID;		//普通用户或部门ID
	UINT32	nWhiteTime;		//白名单时间戳
	UINT8	cOpType;		//操作类型 0：增加 1：删除
	UINT8 	cIdType;			//ID 类型
}WhiteList_t;

//获取特殊用户列表应答
typedef	struct  _GetSpecialListAck
{	
	RESULT  result;
	UINT32	nSpecialTme;		//特殊用户时间戳
	//UINT32	nWhiteTime;		//白名单时间戳
	UINT16  wSpecialNum;	//特殊用户数量
	UINT16  wWhiteNum;		//白名单数量
	SpecialList_t 	mSpecialList[MAX_SPECIAL_NUM];	//特殊用户列表
	WhiteList_t		mWhiteList[MAX_SPECIAL_NUM]; 	//白名单列表
	UINT8   cPageSeq;		//第几页默认就一页
} GETSPECIALLISTACK;

//黑名单更新通知
typedef  struct  _ModiSpecialListNotice
{
	UINT64 dwMsgID; // 消息ID
	UINT32	nSpecialTme;		//特殊用户时间戳
	UINT16  wSpecialNum;	//特殊用户数量
	UINT16  wWhiteNum;		//白名单数量
	SpecialList_t mSpecialList[MAX_SPECIAL_NUM];	//特殊用户列表
	WhiteList_t	mWhiteList[MAX_SPECIAL_NUM]; 	//白名单列表
	UINT8   cPageSeq;		//第几页默认就一页
} MODISPECIALLISTNOTICE;

typedef  struct  _ModiSpecialListNoticeAck   //
{	
	UINT64 dwMsgID; // 消息ID
	UINT32 	dwUserID;
	UINT16	iRetcode;
} MODISPECIALLISTNOTICEACK;

//连接到接入管理服务请求包
typedef struct tagTAccessRequest
{
	char type;//包类型：0没有携带；1携带了上次失败的接入服务地址和端口
	char szVer[VERSION_MAXLEN];//客户端软件版本号，未必是正运行的
	char  osType;//操作系统类型：1安卓，2 ios 3.微软PC 4MAC 5.WINDOWSPHONE 
	LV32  tUserAccount ;//用户帐号LV方式；1字节长度，帐号最长29字节
	LV64    tFailServiceAddr;//上次失败的接入服务地址,IP或域名；长度1字节，最长63字节
	unsigned short  uPort;//接入服务的端口号；0则没有端口号
} TAccessRequest;

//连接到接入管理服务应答包
typedef struct  tagLOGINACCESSACK
{
	//成员变化（顺序或大小），则需要修改toDecode函数
	char ret;// 1字节，值：0成功没有返回值描述，1失败，2.过载保护， 3黑名单,4：没有该账号
	LV255 tRetDesc;//返回值描述1字节长度，254字节内容
	short  iTryTime;// 重试时间：2字节，秒为单位，为0立即尝试，黑名单则返回1800秒
	LV64    tServiceAddr;//接入服务地址,IP或域名；1字节长度，最长63字节
	unsigned short  uPort;//接入服务的端口号；0则没有端口号
	char UpgradeType;//升级类型：1字节 ： 0无需升级，1强制，2静默，3可选
	unsigned short  uUpgradeWaitTime;//静默等待时间：单位分钟，2字节
	char isDeltaUpgrade;// 是否增量：1字节，1全量，2增量，没有为0
	char szLatestVer[20];//服务端的客户端软件版包本号
	LV255 tUpgradeFileUrl;// 升级文件地址：255，LV方式，1字节长度，254字节内容
	LV255 tLatestVerDesc;// 版本描述URL：200，LV方式1字节长度，199字节内容
} LOGINACCESSACK,TAccessRsp;

//v1.1发起状态拉取请求包
typedef struct tagTGetStatusReq
{
	UINT32 dwCompID; // 企业ID
	INT8 cTerminalType;//终端类型：1安卓， 2ios 3pc 4 mac  5 windowsphone
	UINT32 uUserId;

	/*请求用户类别拉取范围：1字节
	0-返回全部用户状态
    1-只返回固定订阅关系状态
	2-部门列表 
	3-用户列表 */
	INT8 cUserType;
	UINT16 nUserNum;//用户数
	UINT32 aUserId[MAX_USERSTATUS_NUM];
}TGetStatusReq;

//v1.1发起状态应答包
//直接用通知包
typedef TUserStatusList TGetStatusRsp;

//v1.1全量状态包
typedef struct tagALLUserStatus
{
	enum max
	{
		MAX_BYTE_BITMAP=1400
	};
	UINT32 uBegUserID;
	UINT32 uEndUserID;
	UINT8  Bitmap[MAX_BYTE_BITMAP];
}TALLUserStatus;


//协议二-------------------------------------------------------------------
//服务定义

//---------------------------------------------------------------------------
//协议二消息包头
typedef struct tagHead
{
	enum enumBusinessType
	{
		CHAT=1,SUBCRIBE_SERVICE=101
	};
	enum enumUserType
	{
		ALL=0,ANDROID=1,IOS=2,PC=3,MAC=4, WINPHON=5
	};
	UINT8	cBusinessType;	//业务类型 101
	UINT16	wPackageBodyLen;//包长，不含包头
	UINT8	cSrcType;		//0所有终端 1:安卓2:IOS3:PC 4:mac 5:winphone 101:订阅服务	
	UINT32	dwSrcId;		//用户ID或当是内部服务0
	UINT8	cDstType;		//0所有终端,1:安卓2:IOS 3:PC 4:mac 5:winphone 101:订阅服务	
	UINT32	dwDstId;		//用户ID或当是内部服务0
	UINT32	dwSendTime;		//发送时间戳 1970—现在的秒
	UINT64	dwMsgId;		//消息ID
	UINT32  dwCompId;		//企业ID
}THead;
//状态订阅请求
typedef struct tag_subscriber_request
{
	THead	mPackageHead;
	UINT8	cRequestType;	//1-临时订阅		2-取消临时订阅
	UINT16	wNum;			//.ID数量：0-N  400个，2字节
	UINT32	dwIdList[MAX_USERSTATUS_NUM];	//ID列表：4字节*ID数量
}SUBSCRIBER_REQ;
//状态订阅应答
typedef struct tagSubscribeRsp
{
	THead	mPackageHead;
	RESULT	cResult;		//0成功，2临时订阅数超过最大限制
	UINT8	cResponseType;	//10-临时订阅	11-取消临时订阅(不返回状态)
	user_status mUserStatus;	//订阅用户状态
}SUBSCRIBER_ACK;

//json通用包,包括请求和应答
typedef struct tagJson
{
	THead	mPackageHead;
	INT8   szBody[PACKET_MAXLEN];
}TJson;

#define ROAMINGDATA_FRE_CON	400		//常用联系人个数
#define ROAMINGDATA_COM_DEP	20		//常用部门
#define ROAMINGDATA_ATT_CON 100 	//关注人
#define ROAMINGDATAREQSIZE  (ROAMINGDATA_FRE_CON*4 +100)	//请求包大小	

//部门列表
struct deptlist
{
	UINT16	wNum;	//部门数
	UINT32	dwDept[ROAMINGDATA_FRE_CON];	//部门ID 
};

//漫游数据同步请求
typedef struct _roamingdata_synchronize_request
{
	UINT32	dwUserid;		//用户ID
	UINT32	dwCompid;		//企业ID(缺省常用联系人时用到)
	UINT8	cTerminalType;	//终端类型 1：android 2：IOS3：PC 4：Mac 5：winphone
	UINT8	cRequestType;	//请求类型 1：常用联系人2：常用部门 3:关注人 6:缺省常用联系人
	UINT32	dwUpdatetime;	//常用联系人或常用部门客户端时间戳
}ROAMDATASYNC;
//漫游数据同步应答
typedef struct _roamingdata_synchronize_response
{
	UINT32	dwUserid;		//用户ID(缺省常用联系人时用到)
	UINT8	cTerminalType;	//终端类型 1：android 2：IOS3：PC 4：Mac 5：winphone
	UINT8	cResponseType;	//请求类型 1：常用联系人2：常用部门 3：关注人 6:缺省常用联系人
	UINT16	wNum;			//常用联系人或常用部门数量
	UINT32	dwUsersList[ROAMINGDATA_FRE_CON];	//常用联系人或常用部门列表
}ROAMDATASYNCACK; 

//漫游数据增加、删减请求
typedef struct _roamingdata_modify_request
{
	UINT32	dwUserid;	
	UINT32	dwCompid;		//企业ID
	UINT8	cTerminalType;	//1：android  2：IOS 3：PC 4：Mac 5：winphone
	UINT8	cRequestType;	//1：常用联系人 2：常用部门 （暂做1，2,3）3：关注人//4自定义（组信息）5自定义组成员变化
	UINT8	cModifyType;	//1：添加， 2：删除
	UINT16	wNum;			//常用联系人或常用部门数量
	UINT32	dwUsersList[ROAMINGDATA_FRE_CON];	//常用联系人或常用部门列表 
} ROAMDATAMODI;

//漫游数据增加、删减应答
typedef struct _roamingdata_modify_response
{
	RESULT	cResult;		//0：成功  其他错误
	UINT32	dwUserid;
	UINT8	cTerminalType;	//1：android  2：IOS 3：PC 4：Mac 5：winphone
	UINT32	dwUpdatetime;
	UINT8	cResponseType;	//1：常用联系人 2：常用部门 （暂做1，2，3）,3.关注人 4自定义（组信息）5自定义组成员变化
	UINT8	cModifyType;	//1：添加， 2：删除
	union 	
	{
		 struct deptlist  tDeptlist;		//请求类型2：返回部门列表
		 user_status tUserStatus;	//请求类型1\3：返回状态数据
	};
} ROAMDATAMODIACK;

//漫游数据通知
typedef struct _roamingdata_modify_notice
{
	UINT32	dwUserid;
	UINT8	cTerminalType;	//1：android  2：IOS 3：PC 4：Mac 5：winphone
	UINT32	dwUpdatetime;
	UINT8	cResponseType;	//1：常用联系人 2：常用部门 （暂做1，2，3）,3.关注人 4自定义（组信息）5自定义组成员变化
	UINT8	cModifyType;	//1：添加， 2：删除
	union 	
	{
		 struct deptlist  tDeptlist;		//请求类型2：返回部门列表
		 user_status tUserStatus;//请求类型1\3：返回状态数据
	};
} ROAMDATAMODINOTICE;

// 获取变化头像员工列表
typedef struct _GetUserHeadIconList
{
	UINT32 dwUserID;
	UINT32 dwCompID;
	UINT8  cLoginType;
	UINT32 dwLastUpdateTime; // 最后更新时间
} TGetUserHeadIconList;
// 获取变化头像员工列表应答
typedef struct _GetUserHeadIconListAck
{
    UINT16 nPacketLen;
	RESULT result;
	UINT16 wCurrPage; // 当前页数, 0: end
	UINT16 wCurrNum; // 本页员工个数
	char   strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} TGetUserHeadIconListAck;

//用户列表
typedef struct _UserHeadIconList
{
    UINT32 dwUserID;
    UINT8  wUpdate_type; //更新类型, 1: 新增 2: 修改 3: 删除
}TUserHeadIconList;

#define PAGE_REGULAR_MAXNUM_USERID      300         //固定群组成员最大数
#define REGULAR_PROCLAMATION_SIZE		50			//固定组公告字节数

//固定组成员结构体
typedef struct _regulargroup_member
{
	UINT32		dwUserID;		//固定组成员ID
	UINT8		cAttribute;		//属性，按位使用，方便以后扩展
	/****************************************/
	/*字段：attribute，判断用户是否是管理员		*/
	/*7	   6	5	4	3	2	1	0		*/
	/*保留 保留 保留 保留 保留 保留 保留 管理员	*/
	/****************************************/
} regulargroup_member;


//固定组创建通知
typedef struct _create_regulargroup_notice
{
	UINT32	dwCreaterID; // creater id
	char	aszGroupID[GROUPID_MAXLEN];
	char	aszGroupName[GROUPNAME_MAXLEN];
	char	aszGroupProclamation[REGULAR_PROCLAMATION_SIZE];
	UINT32	dwTime;
	UINT16	wUserNum;
	regulargroup_member	aUserList[PAGE_REGULAR_MAXNUM_USERID];
} CREATEREGULARGROUPNOTICE;
//固定组协议2（创建通知分包）
typedef struct _create_regulargroup_protocol2_notice
{
	UINT32	dwCreaterID; 
	char	aszGroupID[GROUPID_MAXLEN];
	char	aszGroupName[GROUPNAME_MAXLEN];
	char	aszGroupProclamation[REGULAR_PROCLAMATION_SIZE];
	UINT32	dwTime;
	UINT16	wMemberTotalPage;	//固定组成员列表总页数
	UINT16	wMemberPage;		//固定组成员列表当前页
	UINT16	wTotalNum;			//固定组成员总数
	UINT16	wCurrentNum; 		//固定组成员当前页个数	
	regulargroup_member	aUserList[PAGE_REGULAR_MAXNUM_USERID];
} CREATEREGULARGROUPPROTOCOL2NOTICE;


//固定组删除通知
typedef struct _delete_regulargroup_notice
{
	UINT32	dwTime;
	UINT32	dwDeleteID;		//删除者ID
	char	aszGroupID[GROUPID_MAXLEN];
} DELETEREGULARGROUPNOTICE;

//固定组成员变更通知
typedef struct _regulargroup_memberchange_notice
{
	UINT32	dwModifyID; //操作者ID
	UINT32	dwTime;
	UINT8	cOperType;	//0:增加	1:删除 2：修改属性
	char	aszGroupID[GROUPID_MAXLEN];
	UINT16	wUserNum;
	regulargroup_member	aUserList[PAGE_REGULAR_MAXNUM_USERID];
} GULARGROUPMEMBERCHANGENOTICE;

//固定组名称改变通知
typedef struct _regulargroup_namechange_notice
{
	UINT32	dwModifyID; //操作者ID
	UINT32	dwTime;
	char	aszGroupID[GROUPID_MAXLEN];
	char	aszGroupName[GROUPNAME_MAXLEN];
} GULARGROUPNAMECHANGENOTICE;

//固定组公告改变通知
typedef struct _regulargroup_proclamationchange_notice
{
	UINT32	dwModifyID; //操作者ID
	UINT32	dwTime;
	char	aszGroupID[GROUPID_MAXLEN];
	char	aszGroupProclamation[REGULAR_PROCLAMATION_SIZE];
} GULARGROUPPROCLAMATIONCHANGENOTICE;

// 用户更新固定组请求
typedef struct
{
	UINT32 dwUserID;		// 用户ID
	UINT32 dwRegularTime;	// 本地时间戳
} REGULAR_GROUP_UPDATE_REQ;

// 用户更新固定组响应
typedef struct
{
	RESULT result;
	UINT16	wGroupNum; //需要更新的固定组个数
} REGULAR_GROUP_UPDATE_RSP;
//重登录通知
typedef struct _client_relogin_notice
{
	UINT32 dwUserID;	//用户ID
	UINT8  cLoginType;	//登录类型
}CLIENT_RELOGIN_NOTICE;
//禁用通知
typedef struct _client_forbidden_notice
{
	UINT32 dwUserID;	//禁止登录帐号
	UINT8  cType;		//禁止登录类型 1.帐号被禁用，不允许登录 2.帐号被踢，请直接重新连接
	UINT32 dwTime;		//帐号禁用时长，与cType配合使用，当cType取值为2时有效，秒为单位，0表示立即连接。
}CLIENT_FORBIDDEN_NOTICE;

struct session_data 
{
	UINT32	dwTimestamp;//会话最大消息的时间戳
	UINT8	cType;		//会话类型 1：用户ID 2：群组ID
	union 		//会话ID，与会话类型联合使用
	{
		UINT32 	dwUserID;	//用户ID
		UINT8	aszGroupID[GROUPID_MAXLEN];	//群组ID
	};
};
//消息已读同步请求
typedef struct msg_read_sync
{
#define MAX_MSGREAD_SYNC_SESSION_NUM	50
	UINT32	dwUserID;	//用户ID
	UINT8	cTerminalType;	//用户终端类型
	UINT16	wNum;	//上报的会话个数
	struct session_data aSessionData[MAX_MSGREAD_SYNC_SESSION_NUM];	//会话列表信息
}MSG_READ_SYNC;



//机器人信息同步请求结构体
typedef struct _robot_sync_req
{
	UINT32	dwCompID;	//企业ID
	UINT32	dwUserID;	//用户ID
	UINT8	cTerminal;	//终端类型
	UINT8	cReqType;	//类型(保留字段)
	UINT32	dwTimestamp;//时间戳
}ROBOTSYNCREQ;
//机器人信息结构体
typedef struct _robot_user
{
#define MAX_ROBOTGREETINGS_NUM	300		//机器人问候语最大字节数
	UINT32	dwUserID;	//机器人ID
	UINT32	dwAttribute;//机器人属性(保留字段)
	UINT8	cUserType;	//机器人类型
	UINT8	aszGreetings [MAX_ROBOTGREETINGS_NUM];	//机器人问候语
}robotuser;
//机器人同步应答结构体
typedef struct _robot_sync_rsp
{
#define MAX_ROBOTLIST_NUM		6		//机器人列表最大个数
	UINT32  dwCompID;	//企业ID
	UINT32  dwUserID;	//用户ID
	UINT8	cTerminal;	//终端类型
	UINT8	cReqType;	//类型
	UINT32	dwTimestamp;//时间戳
	UINT16	wTotalPage;		//总页数
	UINT16	wCurrentPage;	//当前页数
	UINT16	wRobotNum;	//机器人个数
	robotuser	sRobotList[MAX_ROBOTLIST_NUM];		//机器人列表
}ROBOTSYNCRSP;

//通讯录全量更新通知
typedef struct _ContactsUpdateNotice
{
	UINT32	dwUserID;						// 用户ID
	UINT32	dwTimeStampe;					// 本次更新唯一标识，整形时间
	UINT8	cTerminalType;					// 本次通知的终端类型
	INT8	cUpdateType;					// 更新类型 1、倒计时完成后立即全量更新 2、下次登录时全量更新
    UINT16	dwCount;						// 倒计时时长，秒为单位，0值标识立即更新
}CONTACTSUPDATENOTICE;

//通讯录全量更新通知应答
typedef struct _ContactsUpdateNoticeAck
{
	UINT32	dwUserID;						// 用户ID
	UINT32	dwTimeStampe;					// 本次更新唯一标识，整形时间
	UINT8	cTerminalType;					// 本次通知的终端类型
}CONTACTSUPDATENOTICEACK;

//公众平台推送消息
typedef struct _ecwx_push_notice 
{
	UINT16	wSize;			//包长度
	UINT16	wCmd;			//命令字
	UINT32	dwTid;			//事务ID

	UINT32	dwSrcUserID;	//发送者（公众平台ID）
	UINT32	dwNetID;		//网元ID
	UINT32	dwTimestamp;	//时间戳
	UINT64	ddwMsgID;		//消息ID
	UINT32	dwDstUserID;	//接收者ID

	UINT8	cIsOfflineMsg;	//是否是离线消息 0:不是 1:是
	UINT16	wOfflineTotal; 	//离线消息消息总数
	UINT16	wOfflineSeq;	//离线消息消息序列

	char aszContent[MSG_MAXLEN];	//推送消息内容
}ECWX_PUSH_NOTICE;

///////////////////////////////////////////////////////////////////////////////////
//added by rock
typedef struct _MsgCancel  //消息召回(CMD_MSGCANCEL)
{
	UINT32 dwUserID;					// sender id
	UINT32 dwRecverID;					// recver id
	INT8   aszGroupID[GROUPID_MAXLEN];	// 群组ID
	UINT64 dwMsgID;						//客户端消息ID
	UINT64 dwCancelMsgID;               //召回消息ID
	UINT8  cIsGroup;	// 是否是群组聊天 0:非群组聊天; 1:群组聊天
	UINT8  cType;       // 0: 文本 1: 图片 2: 语音 3:文件
   UINT32  nSendTime;	// 发送时间
} MSGCancel;

typedef struct _MSGCancelAck  //消息召回应答(CMD_MSGCANCELACK)
{
	RESULT result;
	UINT64 dwMsgID;
    UINT64  dwCancelMsgID;              //召回消息ID
} MSGCancelACK;

//召回通知(CMD_MSGCANCELNOTICE)
typedef struct _MSGCancelNotice
{
	UINT32 dwSenderID;                  //用户ID
	UINT32 dwRecverID;					// 用户ID
	INT8   aszGroupID[GROUPID_MAXLEN];	// 群组ID
	UINT64 dwMsgID;						// 消息ID
	UINT64 dwCancelMsgID;               // 召回消息ID
	INT8   cIsGroup;					// 是否是群组聊天
    UINT32 dwGroupTime;					// 群组变更时间
	INT8   cMsgType;					// 消息类型
	INT8   cOffline;					// 是否离线消息 1、离线消息
	UINT32 dwSendTime;					// 发送时间
	UINT32 dwNetID;
} MSGCancelNotice;

//召回通知应答(CMD_MSGCANCELNOTICEACK)
typedef struct _MSGCancelNoticeAck  
{
	UINT32 dwUserID;
	UINT64 dwMsgID;
	UINT64 dwCancelMsgID;              //召回消息ID
	UINT32 dwNetID;
} MSGCancelNoticeAck;
///////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
#define VIRGROUP_ADD                     (1)
#define VIRGROUP_UPDATE                  (2)
#define VIRGROUP_DELETE                  (3)

//虚拟组基本信息
struct virtual_group_basic_info
{
#define		MAX_VIR_GRP_PMT_LEN	255
	UINT32	dwMainUserID;				//虚拟组关联账号
	char	strGroupID[GROUPID_MAXLEN];	//虚拟组ID
	UINT32	dwGroupTime;				//虚拟组时间戳
	UINT8	cUpdateType;				//虚拟组更新类型 1：增加  2：修改  3：删除
	UINT16	wMemberNum;					//虚拟组成员个数
	UINT16	wSingleSvcNum;				//单个成员服务的最大人数
	UINT16	wTimeoutMinute;				//连接空闲超时时间
	UINT8	cDisplaysUsercode;			//是否显示真实的usercode
	char	strWaiting[MAX_VIR_GRP_PMT_LEN];//等待提示语
	char	strHangup[MAX_VIR_GRP_PMT_LEN];	//挂断提示语
	char	strOncall[MAX_VIR_GRP_PMT_LEN];	//建立连接提示语
};
//虚拟组全部信息(包括虚拟组成员)
struct virtual_group_info
{
#define MAX_VIR_GROUP_MEMBER 200
	struct virtual_group_basic_info mBasicInfo;	//基本信息
	UINT32 dwGroupMember[MAX_VIR_GROUP_MEMBER];	//成员列表
};

////////////////////////////////////////////////////////////////////
//虚拟组信息请求
typedef struct	virtual_group_info_req
{
	UINT8  cTerminalType;	//终端类型
	UINT32 dwCompID;	//企业ID
	UINT32 dwUserID;	//用户ID
	UINT32 dwTimestamp;	//本地虚拟组最大时间戳
}VIRTUAL_GROUP_INFO_REQ;
//虚拟组信息请求应答
typedef struct	virtual_group_info_ack
{
	UINT32 dwResult;
	UINT8  cTerminalType;
	UINT32 dwCompID;
	UINT32 dwUserID;
	UINT16 wVirGroupNum;	//返回变化的虚拟组个数
}VIRTUAL_GROUP_INFO_ACK;
//虚拟组信息通知
typedef struct virtual_group_info_notice
{
	UINT8  cTerminalType;
	UINT32 dwCompID;
	UINT32 dwUserID;
	UINT16 wTotalNum;	//总共变化的群组
	UINT16 wCurNum;		//当前是第几个
	struct virtual_group_info mVirGroupInfo;
}VIRTUAL_GROUP_INFO_NOTICE;
////////////////////////////////////////////////////////////////////
////////////////////视频会议协议机构体

//创建会议应答
typedef struct meeting_create_ack
{
#define MAXLENGTH_RESULT         (200)
#define MAXLENGTH_CONTENT_TYPE   (50)
	int status;    //应答状态
	               //0：创建会议成功；
	               //10001  会议开始时间小于当前时间 
	               //10002	时长超过24小时
	               //10003	预约会议失败
	               //10004	开始时间大于6个月时间
	char result[MAXLENGTH_RESULT];     //失败原因
	char content_type[MAXLENGTH_CONTENT_TYPE];
}MEETING_CREATE_ACK;
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
//收藏协议结构体//
////////////////////////////////////////////////////////////////////

//同步请求
typedef struct	favorite_sync_req
{
	UINT32	dwCompID;		//企业ID
	UINT32	dwUserID;		//用户ID
	UINT8	cTerminal;		//终端类型
	UINT32	dwTimestamps;	//本地收藏最大时间戳
}FAVORITE_SYNC_REQ;

//同步应答
typedef struct	favorite_sync_ack
{
	UINT32	dwResult;		//应答结果
	UINT32	dwCompID;		//企业ID
	UINT32	dwUserID;		//用户ID
	UINT8	cTerminal;		//终端类型
	UINT16	wTotalNum;		//跟新的收藏条数
}FAVORITE_SYNC_ACK;

//批量删除收藏数据
struct favorite_batch_opera
{
#define MAX_BATCH_OPERA_NUM 100
	UINT16	wNum;		//数量
	UINT64	ddwMsgID[MAX_BATCH_OPERA_NUM];	//消息ID
};
//收藏详细数据
struct favorite_info 
{
	UINT32	dwCompID;	//企业ID
	UINT32	dwUserID;	//用户ID
	UINT32	dwCollTime;	//消息收藏时间
	UINT8	cUpdateType;//1新增，2修改，3删除
	UINT32	dwSender;	//原始消息发送者
	UINT8	cIsGroup;	//
	UINT8	strGroupID[GROUPID_MAXLEN];
	UINT64	ddwMsgID;	//消息ID
	UINT32	dwSendTime;	//发送时间
	UINT16	wMsgType;	//消息类型
	UINT16	dwMsgSize;	//消息长度
	INT8	strMsgContent[MSG_MAXLEN];	//消息内容
};

//收藏更新请求,收藏通知
typedef struct favorite_modify_req 
{
	UINT32	dwCompID;		//企业ID
	UINT32	dwUserID;		//用户ID
	UINT8	cTerminal;		//终端类型
	UINT8	cOperType;		//操作类型 1新增,2修改,3删除
	UINT16	wTotalNum;		//总条数
	UINT16	wCurNum;		//当前条数
	union
	{
		struct favorite_info stFavoriteInfo;	//新增收藏
		struct favorite_batch_opera stFavoriteBatch;	//批量删除收藏
	};
}favorite_notice;

typedef struct favorite_modify_req  FAVORITE_MODIFY_REQ;
typedef favorite_notice  FAVORITE_NOTICE;

//收藏更新应答
typedef struct favorite_modify_ack
{
	UINT32	dwResult;		//
	UINT32	dwCompID;		//企业ID
	UINT32	dwUserID;		//用户ID
	UINT8	cTerminal;		//终端类型
	UINT8	cOperType;		//操作类型 1新增,2修改,3删除

	struct favorite_batch_opera stFavoriteBatch;
}FAVORITE_MODIFY_ACK;
////////////////////////////////////////////////////////////////////
///

// 部门显示配置请求结构体
typedef struct	_GetDeptShowConfigReq
{
	UINT32	dwCompID;		//企业ID
	UINT32	dwUserID;		//用户ID
	UINT8	cTerminal;		//终端类型
	UINT32	dwTimestamps;	//本地部门显示配置时间戳
}GETDEPTSHOWCONFIGREQ;

// 部门显示配置应答结构体
typedef struct _GetDeptShowConfigAck
{
	UINT16  wPacketLen;
	UINT32  dwUserID;	// 用户userid
	UINT8	cTerminal;	// 终端类型
	UINT8	cUpdateFlag;		//0:配置未更改，不需要更新，1：配置更改了，需要更新 
    UINT32  dwUpdateTime;		//部门显示配置最新时间戳
    UINT8	cDefaultShowLevel;	//0：默认为0(全部不显示)，2：默认为2(全部显示)
	UINT16 	wCurrPage;	// 当前页数 0:结束页
	UINT16 	wCurrNum;	// 本页部门个数
    char   	strPacketBuff[PACKET_LEN_INDICATOR+PACKET_CONTENT_LEN];
} GETDEPTSHOWCONFIGACK;

// 解析部门显示配置结构体
typedef struct _SingleDeptShowLevel
{
	UINT32 dwDeptID;
    UINT8  cShowLevel;
} SINGLEDEPTSHOWLEVEL;


#define MAX_CONFID_LEN 32
#define MAX_CONF_TITLE_LEN 256
#define MAX_CONF_REMARK_LEN 1500
#define CONF_FILE_MAX 10
#define FILE_NAME_MAX_LEN 128

typedef struct _conf_basic_info{
    char strConfId[MAX_CONFID_LEN];			//会议ID
    char strHostCode[32];		// 主持人密码
    char strMbrCode[32];		// 成员密码
    char strConfTitle[MAX_CONF_TITLE_LEN];		// 会议主题
    INT32 dwStartTime;			// 开始时间
    INT32 dwEndTime;			// 结束时间
    INT32 dwConfLength;			// 设定会议时长
    UINT8 cConfStatus;			// 会议状态 0：会议不存在；1：会议已创建；2：会议已开始；4：会议已结束// 18：会议已锁定；5：会议已过期
    char  strCreatorAcct[32];	// 会议创建者usercode
    UINT32 dwcreatorID;			// 会议创建者userid
    UINT8 cConfType;			// 会议类型，0:线下会议 1:云会议
    UINT8 cIsRepeat;			// 是否是循环会议
    char strRepeatKey[32];		// 循环会议唯一标识，删除循环会议时用到
    UINT8 cConfMode;			// 会议模式，0:协作模式 1:会场模式
    UINT32 dwRealStartTime;	    // 实际开始时间
    UINT32 dwRealEndTime;		// 实际结束时间
    UINT32 dwRealLength;		// 实际会议时长
    UINT32 dwMbrMaxNum;			// 会议成员个数最大值
    char strMbrUrl[MAX_CONF_TITLE_LEN];		// 会议成员URL
    char strHostUrl[MAX_CONF_TITLE_LEN];		// 主持人URL
    char strLocation[MAX_CONF_TITLE_LEN];		// 会议地点

    UINT8 cUpdateType;			// 1.新增 2.修改 3.删除
    UINT32 dwUpdateTime;		// 更新时间戳

    UINT8 cSMSNotice;			// 0:不需要短信提醒 1:需要短信提醒
    UINT32 dwPartNum;
    UINT32 dwFileNum;
}confBasicInfo;

// 会议基本信息通知
typedef struct _conf_info_notice{

    UINT32 dwUserId;			// 接收者
    UINT8 cTerminal;			// 终端类型 同步通知需要填写
    UINT8 cOperType;			// 1客户端同步通知，2服务端推送

    confBasicInfo sConfBasicInfo; // 会议基本信息
}confInfoNotice;

//会议备注通知
typedef struct _conf_remarks_notice
{
    UINT32 dwUserId;			// 接收者
    UINT8 cTerminal;			// 终端类型 同步通知需要填写
    UINT8 cOperType;			// 1客户端同步通知，2服务端推送
    char strConfId[MAX_CONFID_LEN];
    char strConfRemark[MAX_CONF_REMARK_LEN];	// 会议备注
}confRemarksNotice;

typedef struct _conf_file_info
{
    char fileToken[32];
    char fileName[FILE_NAME_MAX_LEN];
    UINT32 fileSize;
    UINT32 dwUpdateTime;
}confFileInfo;

// 会议附件信息通知
typedef struct _conf_file_info_notice{
    UINT32 dwUserId;	// 接收者
    UINT8 cTerminal;	// 终端类型 同步通知需要填写
    UINT8 cOperType;	// 1客户端同步通知(全量)，2服务端推送(全量) 
    UINT8 cDataType;
    char strConfId[32];
    UINT16 wFileNum;	// 文件数量
    confFileInfo sFileList[CONF_FILE_MAX]; // 附件信息
}confFileInfoNotice;

typedef struct _conf_basic_member_info
{
    UINT32 dwMbrId;
    UINT32 dwOperaId;
    UINT8 cIsAccept;
    UINT32 dwUpdateTime;	// 时间戳
	UINT8 cIsRead;
    UINT8 cConfLevel;			// 0:普通会议 1:重要会议
}confBasicMbrInfo;
;
// 会议成员信息通知
typedef struct _conf_member_info_notice{
    UINT32 dwUserId;	// 接收者
    UINT8 cTerminal;	// 终端类型 同步通知需要填写
    UINT8 cOperType;	// 1客户端同步通知(全量)，2服务端推送(全量) 
    UINT8 cDataType;
#define CONF_MBR_MAX 100
    char strConfId[32];	// 会议ID
    UINT16 wMbrNum;		// 成员数量
    confBasicMbrInfo sMbrList[CONF_MBR_MAX];
}confMbrInfoNotice;


// 会议账号信息通知
typedef struct _conf_user_info_notice{
    UINT32 dwUserId;	
	char strConfUserCode[50];   // 全时帐号
    char strConfUserId[32];	// 全时Id
    char strConfPwd[32];	// 会议账号密码
    UINT8 acctType;			// 1 账号(可以预约会议)，2 用户(只参加会议)
	char cConfLang;	        // 1:'zh-cn' 2:'en'
    UINT8 cUpdateType;		// 1新增，2修改，3删除
}confUserInfo,confUserInfoNotice, *PS_ConfUserInfo;
typedef const struct _conf_user_info_notice* PS_ConfUserInfo_;

//会议帐号请求
typedef struct	_conf_account_info_req
{
    UINT32	dwCompID;		//企业ID
    UINT32	dwUserID;		//用户ID
    UINT8	cTerminal;		//终端类型
}S_GetMeetingAccountInfo;


#pragma pack(pop)

#endif