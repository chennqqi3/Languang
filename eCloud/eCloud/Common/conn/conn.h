//
//  conn.h
//  eCloud
//
//  Created by robert on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"
#import "eCloudDefine.h"

@class EmpDeptDL;
@class Emp;

@class eCloudNotification;
@class AppDelegate;
@class ServiceMessage;
@class ConvRecord;
@class ASIHTTPRequest;
@class APPStateRecord;

@class DeptInMemory;

@interface conn : NSObject
{
	
	CONNCB *_conncb;

    /** 全局变量，每发送一条消息+1 */
	int _seq;

    /** 用户状态 */
	int _userStatus;
    
    /** 用户ID */
	NSString *_userId;
    
    /** 用户账号 */
    NSString *user_code;
    
    /** 用户邮箱 */
	NSString *_userEmail;
    
    /** 用户密码 */
	NSString *_userPasswd;
    
    /** 用户名字 */
	NSString *_userName;
    
    /** 设备ToKen */
    NSString *_deviceToken;
    
    /** 性别 */
    int emp_sex;
    
    /** 头像 */
	NSString *emp_logo;
    
    /** 部门本地时间戳 */
	NSString *_oldDeptUpdateTime;
    
    /** 员工与部门关系本地时间戳 */
	NSString *_oldEmpDeptUpdateTime;
    
    /** 员工本地时间戳 */
    NSString *_oldEmpUpdateTime;
    
    /** 固定群组 本地的时间戳 */
    NSString *_oldVgroupTime;
    
	NSString *_newCompUpdateTime;
    
    /** 部门最新时间戳 */
	NSString *_newDeptUpdateTime;
    
    /** 部门最新时间戳 */
	NSString *_newEmpUpdateTime;
    
    /** 员工与部门关系最新时间戳 */
	NSString *_newEmpDeptUpdateTime;
    
    NSString *_newVgroupTime;

    /** 临时变量 */
	int _iTimeout;
    
    /** 是不是需要检测超时的cmd */
	bool _isTimeoutCmd;

    /** 是不是登录命令 */
	bool _isLoginCmd;
    
    /** 是不是创建群组指令 */
	bool _isCreateGroupCmd;
    
    /** 是不是获取用户消息指令 */
	bool _isGetUserInfoCmd;
	
    /** 临时ID */
	NSString *_tempConvId;

    /** 版本升级 */
	int _updateFlag;
    
    /** 更新的版本 */
	NSString *_updateVersion;
    
    /** 更新的URL */
	NSString *_updateUrl;
    
    /** 版本描述URL */
    NSString *_updateDescURL;
	
    /** 是否初次下载 true第一次下载 false不是第一次下载 */
	bool _isFirstGetUserDeptList;

    /** 验证部门员工信息是否下载完整 */
	int _userDeptPage;
    
    /** 部门员工信息页数 */
	int _deptPage;

    /** 新服务器时间 */
    int nServerCurrentTime;
    
    long long dTime;
    long long dnextTime;
    
    /** 权限信息 */
    NSMutableDictionary *wPurviewDic;
    
    /** 废弃 */
    int wPurview;
    
    /** 废弃 */
    NSString *wPur_binary_str;
    
    /** 废弃 */
    int audiosuccess;
    
	/** 废弃 */
	BOOL canNextLogin;
    
    /** 废弃 */
    BOOL isLinking;

    /** 是否已经收完离线消息 */
	bool isOfflineMsgFinish;
    
    /** 保存没有发出通知的消息id */
	NSMutableArray *_offLineMsgs;
	
    /** 消息线程 */
	NSThread *_msgThread;
    
	/** 通知名称 */
	NSString *notificationName;
    
    /** 通知带的对象 */
	eCloudNotification *notificationObject;
	
    /** 收取离线消息超时处理timer */
	NSTimer *_offlineMsgTimer;
    
    /** 增加一个变量，如果联系人不存在，或者会话还没创建好，则把这个消息设置为已读 */
	bool isConversationNormal;

    /** 没有发出通知的消息是否已经处理 */
	bool isOfflineMsgsSend;

    /** 重链次数限制 */
    int relinkNum;
    
    /** 废弃 */
    bool isclickedUpdate;

    /** 连接开始的时间 */
    int connStartTime;

}

/** 是否需要 清除内存中的员工资料 */
@property (nonatomic,assign) BOOL needClearEmpArray;

/** 同步组织架构的开始时间 因为OrgConn里需要访问，所以在这里定义一下 */
@property (nonatomic,assign) int timeStart;

/** 同步组织架构时，会话列表标题显示的内容 比如 同步部门、保存部门、同步员工资料、保存员工资料等 */
@property (nonatomic,retain) NSString *downloadOrgTips;

/** 通知名称 deprecated */
@property(nonatomic,retain)NSString *notificationName;

/** 通知带的对象 deprecated */
@property(nonatomic,retain)eCloudNotification *notificationObject;

/** deprecated */
@property(nonatomic,assign) int relinkNum;

/** 保存在内存里的登录用户的emp_code 对应数据库里的emp_code列，登录应答里没有包含这个值，同步简要信息时包含了emp_code 获取用户详情时也包含了emp_code */
@property(nonatomic,retain) NSString *user_code;

/** 当前登录用户对应的Emp对象 如果用户还没有保存到数据库，那么取的是登录应答里返回的用户简要资料；否则就是从数据库里读出的用户详情 */
@property(nonatomic,retain)Emp *curUser;

/** 收消息的线程 从clientAgent里的消息队列里获取消息进行处理 */
@property(nonatomic,retain)NSThread *msgThread;

/** deprecated */
@property(nonatomic,assign)int seq;

/** 用户的状态 在线或者离线 离开、退出、未连接这几个状态暂时没有使用 */
@property(nonatomic,assign) int userStatus;

/** 登录用户的empId */
@property(nonatomic,retain) NSString* userId;

/** 用户登录时输入的账号 */
@property(nonatomic,retain) NSString* userEmail;

/** 用户登录时输入的密码 */
@property(nonatomic,retain) NSString* userPasswd;

/** 登录用户的名字 登录应答里带了登录用户的名字 */
@property(nonatomic,retain) NSString* userName;

/** add by shisp 当前登录用户的收消息标志 是否需要同步pc的消息 */
@property(nonatomic,assign)int userRcvMsgFlag;

/** 推送token */
@property(nonatomic,retain) NSString *deviceToken;

/** deprecated */
@property(nonatomic,retain) NSString *logintoken;

/** deprecated */
@property(nonatomic,assign) int emp_sex;

/** deprecated */
@property(nonatomic,retain) NSString *emp_logo;

/** 固定群组 本地的时间戳 */
@property(nonatomic,retain) NSString *oldVgroupTime;

/** 部门本地时间戳 */
@property(nonatomic,retain) NSString *oldDeptUpdateTime;

/** 员工与部门关系本地时间戳 */
@property(nonatomic,retain) NSString *oldEmpDeptUpdateTime;

/** 员工本地时间戳 */
@property(nonatomic,retain) NSString *oldEmpUpdateTime;

/** 公司信息最新时间戳 */
@property(nonatomic,retain) NSString *compUpdateTime;

/** 部门最新时间戳 */
@property(nonatomic, retain) NSString *deptUpdateTime;

/** 员工最新时间戳 */
@property(nonatomic,retain) NSString *empUpdateTime;

/** 员工与部门关系最新时间戳 */
@property(nonatomic,retain) NSString *empDeptUpdateTime;

/** 固定群组最新时间戳 */
@property(nonatomic,retain) NSString *VgroupTime;

/** 级别，业务，地域同步时间戳 deprecated */
@property (nonatomic,assign) int oldRankUpdateTime;
@property (nonatomic,assign) int newRankUpdateTime;

@property (nonatomic,assign) int oldProfUpdateTime;
@property (nonatomic,assign) int newProfUpdateTime;

@property (nonatomic,assign) int oldAreaUpdateTime;
@property (nonatomic,assign) int newAreaUpdateTime;

/** 上次发出checkTime的时间 */
@property (nonatomic,assign) int lastSendCheckTimeCmdTime;

/** 上次获取状态的时间 deprecated*/
@property (nonatomic,assign) int lastGetUserStateListTime;

/** 是不是第一次保存用户状态 deprecated*/
@property (nonatomic,assign) BOOL isFirstProcessUserStateList;

/** deprecated*/
@property(nonatomic,retain) 	NSString *tempConvId;
@property(nonatomic,retain) NSMutableArray *offLineMsgs;
@property(assign) bool isOfflineMsgFinish;

/** add by shisp 链接状态，包括未链接，连接中，下载组织架构，收取中，正常*/
@property(nonatomic,assign) int connStatus;

/** add by yanlei 广告页下载状态标示*/
@property(nonatomic,assign) int downLoadImageStatus;

/** 是否初次下载 true第一次下载 false不是第一次下载*/
@property(nonatomic,assign) bool isFirstGetUserDeptList;

/** deprecated*/
@property(nonatomic,assign) BOOL canNextLogin;

/** 是否正在连接中 如果已经在连接中了，就不再发起连接了*/
@property(nonatomic,assign) BOOL isLinking;

/** deprecated*/
@property(nonatomic,assign) int audiosuccess;

/** deprecated*/
@property(nonatomic,assign) int wPurview;

/** deprecated*/
@property(nonatomic,retain)NSString *wPur_binary_str;

/** deprecated*/
@property(nonatomic,retain) NSMutableDictionary *wPurviewDic;

/** 登录成功后从应答里得到了服务器时间，记录当时的本地时间 目的是为了和服务器时间保持同步*/
@property(nonatomic,assign)long long dTime;

/** deprecated*/
@property(nonatomic,assign)long long dnextTime;

/** 登录成功后应答里返回的服务器时间*/
@property(nonatomic,assign)int nServerCurrentTime;

/** deprecated*/
@property(nonatomic,assign) int iTimeout;

/** deprecated*/
@property(nonatomic,assign) bool isTimeoutCmd;

/** deprecated*/
@property(nonatomic,assign) bool isclickedUpdate;

/** 是否登录指令*/
@property(nonatomic,assign) bool isLoginCmd;

/** 是否创建群组指令*/
@property(nonatomic,assign) bool isCreateGroupCmd;

/** 是否获取用户资料指令*/
@property(nonatomic,assign) bool isGetUserInfoCmd;

/** 是否退出讨论组指令*/
@property(nonatomic,assign) bool isQuitGroupCmd;

/** 是否获取离线消息条数指令*/
@property(nonatomic,assign) bool isGetOfflineMsgNumCmd;

#pragma mark =========修改个人漫游数据===========

//同步部门配置是否超时
@property (nonatomic,assign) BOOL isSyncDeptShowTimeout;
//同步部门显示指令
@property (nonatomic,assign) BOOL isSyncDeptShowCmd;


/** 是否修改个人漫游数据指令*/
@property(nonatomic,assign) bool isUpdateUserDataCmd;

/** deprecated*/
@property(nonatomic,assign) int updateFlag;

/** 最新版本号*/
@property(nonatomic,retain) NSString *updateVersion;

/** 新版本对应的url*/
@property(nonatomic,retain) NSString *updateUrl;

/** 新版本的描述信息*/
@property(nonatomic,retain) NSString *updateInfo;

/** 是否有新版本*/
@property(nonatomic,assign) BOOL hasNewVersion;

/** 是否是强制升级*/
@property(nonatomic,assign) BOOL forceUpdate;

/** 收到的员工与部门关系数据页数*/
@property(nonatomic,assign)int userDeptPage;

/** 收到的部门数据页数*/
@property(nonatomic,assign)int deptPage;

/** 当前正在获取详细资料的empId*/
@property(nonatomic,assign)int curEmpId;

/** 所有员工资料的数组*/
@property(nonatomic,retain)NSMutableArray *allEmpArray;

/** 每个部门的在线人数 也就是放在内存里的部门数据*/
@property(nonatomic,retain)NSMutableArray *onlineEmpCountArray;

/** 收到的部门数据数组*/
@property(nonatomic,retain)NSMutableArray *deptArray;

/** 收到的员工资料数组*/
@property(nonatomic,retain)NSMutableArray *empArray;

/** 收到的员工状态数组*/
@property(nonatomic,retain)NSMutableArray *empStatusArray;

/** 收到的员工与部门关系数组*/
@property(nonatomic,retain)NSMutableArray *empDeptArray;

/** 需要下载头像的联系人 deprecated*/
@property(nonatomic,retain) NSDictionary *contactNeedDownloadLogo;

/** 是否是被离线*/
@property(nonatomic,assign) BOOL isKick;

/** 提示被禁用*/
@property(nonatomic,assign) BOOL isDisable;

/** 是否密码错*/
@property(nonatomic,assign) BOOL isInvalidPassword;

/** 群组成员的最大数*/
@property(nonatomic,assign) int maxGroupMember;

/** 黑名单的同步时间 deprecated*/
@property (nonatomic,retain) NSString *oldBlacklistUpdateTime;

/** 白名单的同步时间 deprecated*/
@property (nonatomic,retain) NSString *newBlacklistUpdateTime;

/** 万达版本新增的时间戳*/
/** 本地默认常用联系人时间戳*/
@property (nonatomic,assign) int oldDefaultCommonEmpUpdateTime;

/** 新的默认常用联系人时间戳*/
@property (nonatomic,assign) int newDefaultCommonEmpUpdateTime;

/** 本地常用联系人时间戳*/
@property (nonatomic,assign) int oldCommonEmpUpdateTime;

/** 新的常用联系人时间戳*/
@property (nonatomic,assign) int newCommonEmpUpdateTime;

/** 本地的常用部门时间戳*/
@property (nonatomic,assign) int oldCommonDeptUpdateTime;

/** 新的常用部门时间戳*/
@property (nonatomic,assign) int newCommonDeptUpdateTime;

/** 本地当前登录用户的个人资料时间戳*/
@property (nonatomic,assign) int oldCurUserInfoUpdateTime;

/** 新的当前登录用户的个人资料时间戳*/
@property (nonatomic,assign) int newCurUserInfoUpdateTime;

/** 本地当前登录用户头像时间戳*/
@property (nonatomic,assign) int oldCurUserLogoUpdateTime;

/** 新的当前登录用户头像时间戳*/
@property (nonatomic,assign) int newCurUserLogoUpdateTime;

/** 本地其它用户头像时间戳*/
@property (nonatomic,assign) int oldEmpLogoUpdateTime;

/** 新的其它用户头像时间戳*/
@property (nonatomic,assign) int newEmpLogoUpdateTime;

/** 本地机器人时间戳*/
@property (nonatomic,assign) int oldRobotUpdateTime;

/** 新的机器人时间戳*/
@property (nonatomic,assign) int newRobotUpdateTime;

/** 部门显示配置的时间戳 */
@property (nonatomic,assign) int oldDeptShowConfigUpdateTime;
@property (nonatomic,assign) int newDeptShowConfigUpdateTime;


/** 放在内存里的部门字典数据 key是deptid，value是一个对象DeptInMemory*/
@property (nonatomic,retain) NSMutableDictionary *allDeptsDic;

/** 放在内存里的员工字典信息 key 是员工id_部门id,value是一个Emp对象*/
@property (nonatomic,retain) NSMutableDictionary *allEmpsDic;

/** 放在内存里的员工字典信息 key 是员工账号 value是一个Emp对象*/
@property(nonatomic,retain) NSMutableDictionary *empCodeAndEmpDic;

/** 当前用户所在聊天界面的id，如果停留在某聊天界面，那么就是这个聊天界面的id，否则就是nil，主要用来区分新消息使用不同的声音*/
@property (nonatomic,retain) NSString *curConvId;

/** 旧的收藏时间*/
@property (nonatomic,assign) int oldCollectUpdateTime;

/** 同步固定群组 应答计数*/
@property (nonatomic,assign) int systemGroupSyncCount;

/** 同步固定群组 当前收到计数*/
@property (nonatomic,assign) int systemGroupCurCount;

/** 是否需要统计收到的固定群组应答的数量*/
@property (nonatomic,assign) BOOL needCountSystemGroup;

/** 手动刷新通讯录标志 如果是手动刷新通讯录则下载了部门和员工与部门关系后，就不在继续下面的流程了*/
@property (nonatomic,assign) BOOL isRefreshOrgByHand;

/** 因为离线消息到达客户端的顺序是乱序的，所以需要对离线消息进行计数，当实际数量和计数一致时才算收取完毕*/
/** 离线消息收集到一个数组里，最后使用一个事物进行保存*/
/** 离线消息总数*/
@property (nonatomic,assign) int offlineMsgTotal;

/** 当前开始处理的离线消息条数*/
@property (nonatomic,assign) int offlineMsgCurCount;

/** 保存离线消息的数组*/
@property (nonatomic,retain) NSMutableArray *offlineMsgArray;

/** 当前收到的离线消息的条数*/
@property (nonatomic,assign) int curRcvOfflineMsgCount;

/** 固定群组如果人数多，需要分包发送，定义一个NSMutableDictionary，key是固定群组的id value也是一个dictionary，保存了已经收到的页数和成员*/
@property (nonatomic,retain) NSMutableDictionary *bigSystemGroupDic;

/** 是否是撤回消息命令*/
@property (nonatomic,assign) BOOL isRecallMsgCmd;

/** 从pc端同步过来的钉消息，在群组资料还没有获取的情况下，要暂时缓存在数组了*/
@property (nonatomic,retain) NSMutableArray *incompleteReceiptMsgArray;

/** 从pc同步过来的钉消息，已读通知已经收到了，但本地还没用入库，这时需要先保存起来，等离线消息入库完毕后再进行处理*/
@property (nonatomic,retain) NSMutableArray * noProcessMsgReadNotice;

/** 是否第一次登录  根据cModifyPersonalAuditPeriod  0:第一次登录    1:不是第一次登录  进行判断*/
@property (nonatomic,assign) BOOL isNeetModifyPwd;

/** 懒加载*/
+(conn *)getConn;

/**
 功能描述
 初始化链接
 
 */
-(bool)initConn;

/**
 功能描述
 关闭链接
 
 */
-(void)closeConn;

/**
 功能描述
 发出登录命令，命令执行的结果，在getMessage里进行处理

 参数
    mail:账号
    passwd：密码
 
 返回值
    true 表示命令发送成功
    false 表示命令发送失败
 */
-(bool)login:(NSString *)mail andPasswd:(NSString*)passwd;

/**
 功能描述
 登出命令，但可以收到离线推送
 
 返回值
    true 表示命令发送成功
    false 表示命令发送失败
 */
-(bool)logout;

/**
 功能描述
 登出命令 
 
 参数
    0:只是登出，但是扔可以收到离线推送
    1：不再有离线消息推送，退出到登录界面
 
 返回值
    true 表示命令发送成功
    false 表示命令发送失败
 
 */
-(bool)logout:(int)type;

//modify user info
//-(bool) modify_user_info:(int) type andInfo:(NSString *)info;

#pragma mark ============获取组织架构信息============
/**
 功能描述
 查询user_info表，取出本地的时间戳到内存，同步时使用
 */
-(void)getOrgInfo;

/**
 功能描述
 发起同步公司资料命令 
 
 应答命令字：CMD_GETCOMPINFOACK
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败
 */
-(bool)getCompInfo;

/**
 功能描述
 发起同步部门指令,同步部门数据的增加、删除、修改
 应答命令字：CMD_GETDEPTLISTACK
 
 参数
 因为本地时间戳和最新时间戳都放在了内存里，所以现在参数无效
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败

 */
-(bool)getDeptInfo:(NSString *)deptUpdateTime;

/**
 功能描述
 发起同步联系人资料指令，同步联系人数据的增加、删除和修改
 应答命令字：CMD_GETUSERLISTACK
 
 参数
 因为本地时间戳和最新时间戳都放在了内存里，所以现在参数无效
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败
 */
-(bool)getEmployeeInfo:(NSString *)empUpdateTime;

//查询数据库，如果有的员工还没有下载详细资料，那么下载

//deprecated
-(void)getNoDetailEmps;

/**
 功能描述
 发起同步员工与部门关系和员工简要信息指令，同步员工与部门关系和员工简要信息的增加、删除和修改
 应答命令字：CMD_GETUSERDEPTACK
 
 参数
 因为本地时间戳和最新时间戳都放在了内存里，所以现在参数无效
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败
 */
-(bool)getEmpDeptInfo:(NSString*)empDeptUpdateTime;

//获取所有用户在线状态
//-(bool)getUserStateList;

//创建聊天群组
/**
 功能描述
 发起创建讨论组指令
 应答命令字：CMD_CREATEGROUPACK
 
 参数
    convId:讨论组id
    convName:讨论组标题
    convEmps:讨论组成员
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败
 */
-(bool)createConversation:(NSString *)convId andName:(NSString*)convName andEmps:(NSArray*)convEmps;

//获取groupinfo
/**
 功能描述
 获取讨论组信息，讨论组名称、标题、成员
 应答命令字：CMD_GETGROUPACK
 
 参数
    grpId：讨论组id
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败
 */
-(bool)getGroupInfo:(NSString*)grpId;

//修改聊天群组成员 type: 0: add member 1: del memeber
/**
 功能描述
 增加或者删除讨论组成员
 应答命令字：CMD_MODIMEMBERACK
 
 参数
    grpId:讨论组id
    emps:变化的讨论组成员数组
    operType:0为增加成员 1为删除成员
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败
 
 */
-(bool)modifyGroupMember:(NSString *)grpId andEmps:(NSArray *)emps andOperType:(int)operType;

/**
 功能描述
 修改讨论组标题
 应答命令字：CMD_MODIGROUPACK
 
 参数
    grpId:讨论组id
    newValue:新的讨论组标题
    valueType:固定为0 (原来如果传1代表是修改讨论组备注，现在deperacated)
 
 返回值
 true 表示命令发送成功
 false 表示命令发送失败
 
 */
-(bool)modifyGroupInfo:(NSString*)grpId andValue:(NSString*)newValue andValueType:(int)valueType;

/**
 功能描述
 修改用户资料 有些公司要求客户端能够修改用户资料
 应答命令字：CMD_MODIINFOACK
 
 参数
    type:0 性别 1籍贯 2 出生日期 3住址 4办公电话 5手机号码 6密码
    newValue:新的用户资料
 */
-(bool)modifyUserInfo:(int)type andNewValue:(NSString*)newValue;

#pragma mark 头像修改成功后，通知最近的10个联系人
//deprecated
-(void)notifyRecentContactWhenUpdateLogo:(NSString *)newUrl;

/**
 功能描述
 获取用户的详细资料，比如手机、邮箱、地址、邮编等
 应答命令字：CMD_GETEMPLOYEEINFOACK
 
 参数
    userId：empId
 
 */
-(bool)getUserInfo:(int)userId;

#pragma mark---后台自动获取用户资料---
/**
 功能描述
 获取某个联系人的详细资料，需要时自动获取
 
 参数
    联系人的empId
 */
-(bool)getUserInfoAuto:(int)userId;

//会话-发送消息 会话id，会话类型，消息类型，消息和消息Id
//-(bool)sendMsg:(NSString*)convId andConvType:(int)convType andMsgType:(int)msgType andMsg:(NSString*)msg andMsgId:(int)msgId;

/**
 功能描述
 发送图片、语音、文件等文件类型消息
 应答命令字：CMD_SENDMSGACK
 
 参数：
    convId:会话id
    convType:会话类型
    msgType:消息类型
    fileSize:文件大小
    fileName:文件名称
    fileUrl:文件url(此文件在文件服务器上的url)
    msgId:消息id
    nSendTime:消息时间
    receiptMsgFlag:回执消息标志
 
 */
-(bool)sendMsg:(NSString*)convId andConvType:(int)convType andMsgType:(int)msgType andFileSize:(int)fileSize andFileName:(NSString*)fileName andFileUrl:(NSString*)fileUrl andMsgId:(long long)msgId andTime:(int)nSendTime andReceiptMsgFlag:(int)receiptMsgFlag;

/**
 功能描述
 发送文本类型消息
 应答命令字：CMD_SENDMSGACK
 
 参数：
 convId:会话id
 convType:会话类型
 msgType:消息类型
 msg:消息内容
 msgId:消息id
 nSendTime:消息时间
 receiptMsgFlag:回执消息标志
 
 */
-(bool)sendMsg:(NSString*)convId andConvType:(int)convType andMsgType:(int)msgType andMsg:(NSString*)msg andMsgId:(long long)msgId andTime:(int)nSendTime andReceiptMsgFlag:(int)receiptMsgFlag;

/**
 功能描述
 发送长消息
 应答命令字：CMD_SENDMSGACK
 
 参数：
 convId:会话id
 convType:会话类型
 msgType:消息类型
 fileSize:长消息对应文本文件的大小
 messageHead:长消息的摘要信息
 fileUrl:长消息对应文本文件的url
 msgId:消息id
 nSendTime:消息时间
 receiptMsgFlag:回执消息标志
 
 */
-(bool)sendLongMsg:(NSString*)convId andConvType:(int)convType andMsgType:(int)msgType andFileSize:(int)fileSize andMessageHead:(NSString*)messageHead andFileUrl:(NSString*)fileUrl andMsgId:(long long)msgId andTime:(int)nSendTime andReceiptMsgFlag:(int)receiptMsgFlag;

#pragma mark -----一呼百应消息，发送消息已读通知----
/**
 功能描述
 发送消息已读 对于回执消息，读了之后要发送已读
 应答命令字：CMD_MSGREADACK
 
 参数
    convRecord:某回执消息对应的模型
 
 */
-(bool)sendMsgReadNotice:(ConvRecord*)convRecord;

#pragma mark----用户状态改变 离线0 在线1 离开2-----
//deprecated
-(bool)changeUserStatus:(int)status;
//deprecated
-(void)getTickCountByNext;//获取当前时钟值;
//-(bool)getVgroupInfo:(NSString *)vgrouptimestr;//获取虚拟组
//deprecated
-(int)getOnLineState;

/**
 功能描述
 生成一个新的消息id 发送消息时需要生成一个新的消息id
 
 返回值
    新的消息id 应该是UINT64
 */
-(long long)getNewMsgId;

/**
 功能描述
 生成一个NSString类型的新消息id，方便使用
 
 返回值
 新的消息id 应该是UINT64
 */
-(NSString *)getSNewMsgId;

/**
 功能描述
 获取当前时间，已服务器时间为基准，发送消息时消息时间要和服务器保持一致
 
 返回值
    int:当前服务器的时间
 */
-(int)getCurrentTime;

/**
 功能描述
 获取当前时间，已服务器时间为基准，发送消息时消息时间要和服务器保持一致
 
 返回值
    NSString:当前服务器的时间
 */
-(NSString*)getSCurrentTime;


#pragma mark 获取多个部门的在线人数总和
//deprecated
-(int)getOnlineEmpCountByDeptIdGroup:(NSArray*)deptIdArray;
#pragma mark 获取对应部门的在线人数
//deprecated
-(int)getOnlineEmpCountByDeptId:(int)deptId;

#pragma mark 根据deptId 找到对应的部门的emp数组
/**
 功能描述
 从内存里获取某一个部门的所有联系人，比如在通讯录里展开某个部门时，如果内存里有，就从内存获取
 
 参数
    deptId：部门id
 
 返回值
    某部门的联系人资料数组
 */
- (NSArray *)getEmpsByDeptId:(int)deptId;

#pragma mark 根据empId，找到对应的emp
/**
 功能描述
 根据empId从内存里获取员工资料
 
 参数
    empId:员工id
 
 返回值
    因为一个员工可能在多个部门，所以返回的是一个数组
 */
-(NSArray*)getEmpByEmpId:(int)empId;

#pragma mark 把所有内存中的员工数据设置为非选中状态
/**
 功能描述
 选择联系人时，会修改内存里某些员工被选中，选择联系人完成后，要设置内存里所有联系人的状态为未选中
 */
-(void)setAllEmpNotSelect;

#pragma mark 当收到创建群组通知时，收到群组成员变化通知时，保存通知消息，并通知
/**
 功能描述
    增加或者减少群组成员时，创建讨论组时，修改讨论组名称时，某个人退出讨论组时，系统自动生成一条群组变化通知消息。
 
 参数
    convId:讨论组id
    msgBody:群组通知消息的内容
    msgTime:群组通知的时间
 
 */
-(void)saveGroupNotifyMsg:(NSString*)convId andMsg:(NSString*)msgBody andMsgTime:(NSString*)msgTime;

#pragma mark 主动退出群组指令
/**
 功能描述
 发出主动退出群组指令
 应答命令字：CMD_QUITGROUPACK
 
 参数
    convId:群组id
 */
-(bool)quitGroup:(NSString*)convId;

#pragma mark 查询后台保存数据是否成功
//deprecated
-(bool)isDataSaved;

#pragma mark 所有的员工资料放在了内存里
/**
 功能描述
 获取所有联系人资料，放到内存里
 */
-(void)getAllEmpArray;

/**
 功能描述
 上行消息到公众号
 
 参数
    message:公众号消息模型
 
 */
-(BOOL)sendPSMsg:(ServiceMessage*)message;

/**
 功能描述
 点击公众号菜单，发送菜单上行命令
 
 参数
    message:公众号消息模型
 */
-(BOOL)sendPSMenuMsg:(ServiceMessage*)message;

/**
 功能描述
 发出获取离线消息总数指令
 应答命令字：CMD_GET_OFFLINE_RESP
 
 */
-(bool)getOfflineMsgNum;

/**
 功能描述
 释放连接资源
 */
-(void)uninitConn;

/**
 功能描述
 重新连接服务器，先释放原来的连接
 
 */
-(void)reInitConn;

/**
 功能描述
 系统转到前台后，如果在线，那么发送checktime指令到服务器端，验证和服务器通讯是否可用
 
 返回值
    0：检测命令已经发出
    1：检测命令发送失败
    2：计划3秒内发送检测指令，时间没有超过3秒，则不发
 */
-(int)sendConnCheckCmd;

/**
 功能描述
 设置是否屏蔽群组消息，flag 为0表示不屏蔽，flag为1表示屏蔽
 应答命令字：CMD_GROUPPUSHFLAGACK
 
 参数
    convId:讨论组id
    rcvMsgFlag:为0表示不屏蔽，为1表示屏蔽
 */
-(BOOL)setRcvFlagOfConv:(NSString*)convId andRcvMsgFlag:(int)rcvMsgFlag;

/**
 功能描述
 用户按了home键，告诉服务器当前的未读记录数
 
 */
-(BOOL)putUnreadMsgCountToServer;

/**
 功能描述
 如果已经和服务器连接上了，那么使用clientAgent里记日志的程序来记日志
 
 参数
    longStr:要记到日志里的内容
 
 返回值
    服务器记了日志返回YES，否则返回NO
 */
-(BOOL)debug:(NSString*)logStr;

/**
 功能描述
 同步公众号
 */
-(void)syncPublicService;

/**
 功能描述
 同步公众号菜单
 
 */
-(void)syncpsMenuListSyncRequest;

/**
 功能描述
 南航的一呼万应 群发消息 deprecated
 
 */
-(BOOL)sendMassMsg:(NSArray*)convEmpArray andConvRecord:(ConvRecord*)_convRecord;

//deprecated
-(void)saveUpdateInfo:(ASIHTTPRequest*)request;
//deprecated
-(void)downloadUpdateInfoFail:(ASIHTTPRequest*)request;

#pragma mark 黑白名单功能相关
/**
 功能描述
 获取和服务器的连接，要是和服务器通讯，需要提供连接参数
 
 返回值
 CONNCB结构体
 
 */
-(CONNCB *)getConnCB;

//deprecated
- (int)getSpeicalTime;
//deprecated
- (int)getWhiteTime;
//deprecated
- (void)setNewBlacklistTime:(int)specialTime andWhiteTime:(int)whiteTime;
#pragma mark
/**
 功能描述
 根据deptId,从内存中获取对应部门的父部门
 
 参数
 deptId:部门id
 
 返回
    部门的父部门
 
 */
-(NSString *)getDeptParentStrByDeptId:(int)deptId;
/**
 暂时没有使用到 add by shisp
#pragma mark 修改内存中部门人员的数量,现在数据库里保存的是本部门的部门人数，总人数要计算得出
- (void)updateEmpCountOfDeptId:(int)deptId andEmpCount:(int)empCount;

#pragma mark 根据部门id计算本部门的总人数
- (int)getTotalEmpCountByDeptId:(int)deptId;
*/


#pragma mark 获取所有部门资料，返回一个不可变的数组
- (NSArray *)getAllDeptInfoArray;

#pragma mark 获取所有员工资料，返回一个不可变的数组
- (NSArray *)getAllEmpInfoArray;

/**
 功能描述
 同步公司应用列表
 
 */
-(void)syncAppList;//同步应用列表

//deprecated
-(void)sendOneAPPStateRecordOfApp:(APPStateRecord*)appStateRec;//统计上报

#pragma mark 同步常用联系人。新增
//-(BOOL)addSynchronousMember:(NSArray *)array;
#pragma mark 同步常用联系人。删除
//-(BOOL)deleteSynchronousMember:(NSArray *)array;

#pragma mark ===========与内存中部门信息相关的方法================
/**
 功能描述
 根据deptId得到内存里保存的部门信息
 
 参数 deptId 部门ID
 返回值 DeptInMemory 内存中的部门资料对象
 */
- (DeptInMemory *)getDeptInMemoryByDeptId:(int)deptId;

/**
 功能描述
 把选中的部门信息设置为未选中

 */
- (void)setAllDeptsNotSelect;

#pragma mark =============和服务器通讯判断是否超时=============
/**
 功能描述
 开启超时定时器
 
 参数
    _timeout:超时时间
 
 */
-(void)startTimeoutTimer:(int)_timeout;

/**
 功能描述
 停止超时定时器
 
 */
-(void)stopTimeoutTimer;

#pragma mark =============发出通知=============
//deprecated
- (void)notifyMessage:(NSDictionary *)message;
//deprecated
- (void)sendNotificationMessage:(NSDictionary *)message;

/**
 功能描述
 获取公司id
 
 */
- (int)getCompId;

#pragma mark =============保存状态，数据库和内存，并且发出通知=============
/**
 功能描述
 保存用户状态
 
 */
- (void)saveEmpStatusOfWanda:(TUserStatusList *)info;

/**
 功能描述
 根据empcode获取内存中保存的emp
 
 参数 empCode 员工账号
 返回值 Emp 员工模型
 */
- (Emp *)getEmpByEmpCode:(NSString *)empCode;

/**
 功能描述
 增加一个刷新组织结构的方法，因为有几个地方在调用，所以写一个公共的方法

 */
- (void)sendRefreshOrgNotification;

/**
 功能描述
 查看部门时间戳，员工与部门关系时间戳，如果都没有变化，则状态为收取中，否则会同步组织架构，前提时必须登录完成取到新的时间戳才能使用这个方法
 
 */
- (void)setCurConnStatus;

/**
 功能描述
 增加一个方法，根据状态返回不同的提示
 
 返回值 根据不同状态返回不同提示
 */
- (NSString *)getTips;

/**
 功能描述
 增加一个方法发送收到消息应答，现在修改为入库完成后，再发送
 
 参数 srcMsgId 消息ID
     srcMsgId 下一条消息ID
 */
- (void)sendRcvMsgAckWithMsgId:(long long)srcMsgId andNetId:(int)netID;

/**
 功能描述
 当用户在后台运行时，收到了消息，那么就生成一个本地通知
 
 参数 dic 字典
 */
-(void)createLocalNotification:(NSDictionary *)dic;

#pragma mark -- 保存部门信息
/**
 功能描述
 保存部门信息
 
 */
-(bool)saveDept;

/**
 功能描述
 保存员工与部门关系数据
 
 */
-(bool)saveEmpDept2;

/**
 功能描述
 登录成功，收完离线消息后，自动发送还在发送中的消息 自动获取需要获取的群组资料
 
 */
- (void)autoSendMsgAndGetGroupInfo;

/**
 功能描述
 增加一个方法 发出登录结果的通知 万达版本使用
 
 */
- (void)sendWandaLoginNotification:(int)retCode;

/**
 功能描述
 系统在前台运行时，生成类似系统通知的本地通知
 
 */
- (void)presentNotificationWhenAppActive:(NSDictionary *)dic;

/**
 功能描述
 收到新消息保存后，调用此方法，可以提醒用户
 
 参数
    msgId:消息id
    convId:讨论组id
    isAlert:是否需要提醒
 */
-(void)sendMsgNotice2:(NSString *)msgId andConvId:(NSString *)convId andAlert:(bool)isAlert;

@end
