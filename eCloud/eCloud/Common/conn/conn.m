

#import "conn.h"

#import "WXOrgUtil.h"
#import "TabbarUtil.h"

#ifdef _LANGUANG_FLAG_
#import "RedPacketModelArc.h"
#import "LANGUANGAppMsgModelARC.h"
#import "LANGUANGAppViewControllerARC.h"
#endif

#ifdef _XIANGYUAN_FLAG_
#import "XIANGYUANAgentViewControllerARC.h"
#import "XIANGYUANAppViewControllerARC.h"
#endif

#import "TextMsgExtDefine.h"
#import "MiLiaoUtilArc.h"

#ifdef _GOME_FLAG_
#import "GOMEEmailUtilArc.h"
#import "GOMEMailDefine.h"
#endif

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#endif

#import "CreateGroupDefine.h"
#import "CreateGroupUtil.h"

#import "TextMsgExtDefine.h"

#import "ConvNotification.h"

#import "OpenCtxDefine.h"
#import "JSONKit.h"

#import "StatusMonitor.h"

#import "APPUtil.h"
#import "HDNotificationView.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"
#import "eCloudNotification.h"
#import "UserInfo.h"
#import "ConnResult.h"
#import "ChineseToPinyin.h"
#import "settingRemindController.h"
#import "ServerConfig.h"
#import "Emp.h"
#import "EmpDeptDL.h"
#import "LogUtil.h"
#import "CollectionConn.h"
#import "WandaNotificationNameDefine.h"

#import "ApplicationManager.h"

#import "RobotDisplayUtil.h"

#import "RobotMenuParser.h"

#import "JSONKit.h"

#import "RobotConn.h"
#import "RobotDAO.h"

#import "BlackListConn.h"
#import "PermissionModel.h"
#import "AppDelegate.h"
//#import "XmlParser.h"
#import "MsgNotice.h"
#import "eCloudUser.h"
#import "eCloudDAO.h"
#import "helperObject.h"
#import "PSConn.h"
#import "NewMsgNotice.h"
#import "ReceiptDAO.h"
#import "Rank.h"
#import "Profession.h"
#import "Area.h"
#import "AdvanceQueryDAO.h"

#import "MassConn.h"
#import "MassDAO.h"

#import "APPConn.h"

#import "StatusConn.h"

#import "UserDataConn.h"

#import "DeptInMemory.h"
#import "UserDefaults.h"

#import "LoginConn.h"
#import "AccessConn.h"
#import "EmpLogoConn.h"
#import "StringUtil.h"
#import "ScheduleConn.h" 
#import "UserDataDAO.h"
#import "APPListModel.h"

#import "NotificationUtil.h"
#import "NotificationsViewController.h"
#import "APPPlatformDOA.h"

#import "MsgConn.h"

#import "OrgConn.h"
#import "RobotResponseXmlParser.h"
#import "RobotResponseModel.h"
#import "VirtualGroupConn.h"
#ifdef _TAIHE_FLAG_
#import "TAIHEAppMsgModel.h"
#endif
#import "talkSessionUtil.h"
#import "talkSessionUtil2.h"

/** 每隔一段时间向服务器发送checkTime指令 */
#define send_checktime_interval_short (30)
#define send_checktime_interval_long (60)
#define checktime_timeout 15

@interface conn(private)
{
}

/** 和通讯录同步有关的提示信息，比如同步组织架构、同步部门、保存部门等 */
@property (nonatomic,retain,readwrite)NSString *downloadOrgTips;


/*
-(void)getMessage;

- (void)notifyMessage:(NSDictionary *)message;
- (void)sendNotificationMessage:(NSDictionary *)message;

-(void)processLogin:(LOGINACK *)loginAck;

-(void)processGetCompInfo:(GETCOMPINFOACK*)getCompInfoAck;
-(void)processGetDeptList:(GETDEPTLISTACK *)getDeptListAck;

-(void)processGetUserList:(GETUSERLISTACK *)getUserListAck;

-(void)processGetUserDept:(GETUSERDEPTACK *)getUserDeptAck;

-(void)getOrgInfo;

//获取用户状态
-(void)processGetUserStateList:(GETUSERSTATELISTACK*)info;

//处理用户状态通知
//-(void)processUserStatusNotice:(USERSTATUSNOTICE*)info;

//bigdata
-(void)processUserStatusNotice:(USERSTATUSSETNOTICE*)info;

//创建分组
-(void)processCreateGroup:(CREATEGROUPACK*)createGroupAck;

//处理收到的创建分组通知
-(void)processCreateGroupNotice:(CREATEGROUPNOTICE *)info;

//发送消息是否成功
-(void)processSendMsgAck:(SENDMSGACK*)sendMsgAck;

//修改用户资料应答
-(void)processModifyUserInfo:(MODIINFOACK *)info;

//获取分组信息应答
-(void)processGetGroupInfo:(GETGROUPINFOACK *)info;

//修改分组成员应答
-(void)processModifyGroupMember:(MODIMEMBERACK*)info;

//修改分组名称应答
-(void)processModifyGroup:(MODIGROUPACK*)info;

//获取分组信息应答和收到创建分组通知后创建群组
-(void)createGroup:(NSString*)grpId andName:(NSString*)grpName andCreateor:(int)createId andGroupTime:(NSString*)groupTime andEmps:(NSArray*)emps;

//分组成员变化通知
-(void)processModifyGroupMemberNotice:(MODIMEMBERNOTICE*)info;

//分组信息修改通知
-(void)processModifyGroupNotice:(MODIGROUPNOTICE*)info;

//获取员工信息应答
-(void)processGetUserInfo:(GETEMPLOYEEACK*)info;

//处理消息已读通知
-(void)processMsgReadNotice:(MSGREADNOTICE*)info;
//处理虚拟组
//-(void)processVgroup:(VIR_GROUP_UPDATE_RSP*)info;
*/
@end


@implementation conn
{
    /** 和通讯录、会话相关的数据库实例 */
	eCloudDAO *db;
    
    /** 和用户配置相关的数据库程序实例，比如获取本地时间戳，保存最新时间戳 */
	eCloudUser *userDb;

    /** deprecated */
	AdvanceQueryDAO *advanceQueryDAO;

    /** 处理队列，为了避免阻塞收消息线程，某些保存到本地的任务放在队列里去完成 */
	NSOperationQueue *orgQueue;
    
    /** deprecated */
	NSOperationQueue *msgQueue;

    /** 获取员工部门信息开始时间 */
//	int timeStart;

    /** 获取员工部门信息结束时间 */
	int timeEnd;
	
    /** 每隔一段时间向服务器发送一个checkTime指令，如果在指定时间内收到了应答，那就证明和服务器通讯是正常的 */
	NSThread *checkTimeThread;
    
	NSTimer *checkTimeTimer;
    
    /** 应用在使用过程中，通过发送checktime指令，检测和服务器的通讯 */
	int checkTimeSerial;
    
    /** 检测的时间间隔 30s 60s 交替进行 */
	int checkTimeInterval;
	
    /** 应用激活时，发送一个checktime_timeout到服务器 */
	int activeCheckTimeSerial;

    /** 用来控制通讯超时的Timer */
	NSTimer *timeoutTimer;

    /** 上次连接的ip */
    NSString *lastConnectIp;
    
    int lastConnectPort;

    /** 获取状态的程序 */
    StatusConn *_statusConn;

    /** 个人漫游数据 */
    UserDataConn *_userDataConn;
    
    /** 处理登录应答的通讯程序 */
    LoginConn *loginConn;
    
    /** 连接服务器的通讯程序 */
    AccessConn *accessConn;
    
    /** 同步用户头像的通讯程序 */
    EmpLogoConn *empLogoConn;

    /** 操作常用联系人、常用部门、固定群组等数据的数据库程序 */
    UserDataDAO *_userDataDao;
    
    /** 消息相关实体 */
    MsgConn *msgConn;
    
    /** 定义一个上次发送的消息id和netid，如果这次发送的和上次的相同，这次就不再发送 主要是针对pc发过来的图文消息，ios客户端会分多条保存，所以不用每条都发 */
    long long lastRcvMsgId;
    
    int lastRcvNetId;
    
    /** 同步公众号获取的公众号个数 */
    int psSynCount;

    /** 同步公众号时当前个数 */
    int psSynCurrCount;
}
//同步部门配置 是否超时
@synthesize isSyncDeptShowTimeout;
//是否是同步部门显示配置指令
@synthesize isSyncDeptShowCmd;

@synthesize needClearEmpArray;
@synthesize noProcessMsgReadNotice;
@synthesize incompleteReceiptMsgArray;

/** 撤回消息 命令 */
@synthesize isRecallMsgCmd;

@synthesize oldRobotUpdateTime;
@synthesize newRobotUpdateTime;

@synthesize timeStart;

@synthesize bigSystemGroupDic;

/** 获取到的离线消息的总数 */
@synthesize curRcvOfflineMsgCount;
@synthesize offlineMsgTotal;
@synthesize offlineMsgCurCount;
@synthesize offlineMsgArray;

@synthesize isRefreshOrgByHand;

@synthesize systemGroupSyncCount;
@synthesize systemGroupCurCount;
@synthesize needCountSystemGroup;

@synthesize downloadOrgTips = _downloadOrgTips;

/** 级别，业务，地域同步时间戳 */
@synthesize oldRankUpdateTime;
@synthesize newRankUpdateTime;

@synthesize oldProfUpdateTime;
@synthesize newProfUpdateTime;

@synthesize oldAreaUpdateTime;
@synthesize newAreaUpdateTime;

/** 上次发出checkTime的时间 */
@synthesize lastSendCheckTimeCmdTime;

/** 上次获取状态的时间 */
@synthesize lastGetUserStateListTime;

/** 是不是第一次保存用户状态 */
@synthesize isFirstProcessUserStateList;

@synthesize oldCommonDeptUpdateTime;
@synthesize oldDefaultCommonEmpUpdateTime;
@synthesize oldCommonEmpUpdateTime;
@synthesize oldCurUserInfoUpdateTime;
@synthesize oldCurUserLogoUpdateTime;
@synthesize oldEmpLogoUpdateTime;

@synthesize newCommonDeptUpdateTime;
@synthesize newCommonEmpUpdateTime;
@synthesize newDefaultCommonEmpUpdateTime;
@synthesize newEmpLogoUpdateTime;
@synthesize newCurUserInfoUpdateTime;
@synthesize newCurUserLogoUpdateTime;

@synthesize notificationObject;
@synthesize notificationName;
@synthesize isUpdateUserDataCmd;

@synthesize curConvId;
@synthesize empCodeAndEmpDic;

@synthesize allEmpsDic;
@synthesize allDeptsDic;

@synthesize oldBlacklistUpdateTime;
@synthesize newBlacklistUpdateTime;

@synthesize isKick;
@synthesize isDisable;
@synthesize isInvalidPassword;

@synthesize curUser;
@synthesize msgThread;
@synthesize isQuitGroupCmd;
@synthesize isGetOfflineMsgNumCmd;

@synthesize seq = _seq;

@synthesize tempConvId = _tempConvId;
@synthesize offLineMsgs = _offLineMsgs;
@synthesize iTimeout = _iTimeout;
@synthesize isTimeoutCmd = _isTimeoutCmd;

@synthesize userStatus = _userStatus;
@synthesize userId = _userId;
@synthesize userEmail = _userEmail;
@synthesize userPasswd = _userPasswd;
@synthesize userName = _userName;
@synthesize userRcvMsgFlag;

@synthesize deviceToken=_deviceToken;
@synthesize isLoginCmd = _isLoginCmd;
@synthesize isCreateGroupCmd = _isCreateGroupCmd;
@synthesize isGetUserInfoCmd = _isGetUserInfoCmd;
@synthesize compUpdateTime = _newCompUpdateTime;
@synthesize deptUpdateTime = _newDeptUpdateTime;
@synthesize empUpdateTime = _newEmpUpdateTime;
@synthesize VgroupTime=_newVgroupTime;
@synthesize oldVgroupTime=_oldVgroupTime;
@synthesize empDeptUpdateTime = _newEmpDeptUpdateTime;
@synthesize oldDeptUpdateTime = _oldDeptUpdateTime;
@synthesize oldEmpDeptUpdateTime = _oldEmpDeptUpdateTime;
@synthesize oldEmpUpdateTime=_oldEmpUpdateTime;
@synthesize updateFlag = _updateFlag;
@synthesize updateVersion = _updateVersion;
@synthesize forceUpdate;
@synthesize hasNewVersion;
@synthesize updateInfo;

@synthesize updateUrl = _updateUrl;
@synthesize isclickedUpdate;
@synthesize isFirstGetUserDeptList = _isFirstGetUserDeptList;
@synthesize userDeptPage = _userDeptPage;
@synthesize deptPage = _deptPage;
@synthesize curEmpId;
@synthesize emp_sex;
@synthesize emp_logo;
//new
@synthesize nServerCurrentTime;
@synthesize dTime;
@synthesize dnextTime;
@synthesize wPurviewDic;
@synthesize wPurview;
@synthesize wPur_binary_str;
@synthesize audiosuccess;
@synthesize canNextLogin;
@synthesize isLinking;
@synthesize connStatus = _connStatus;
@synthesize downLoadImageStatus;

@synthesize isOfflineMsgFinish;

@synthesize allEmpArray;
@synthesize onlineEmpCountArray;

@synthesize deptArray;
@synthesize empArray;
@synthesize empStatusArray;
@synthesize empDeptArray;

@synthesize contactNeedDownloadLogo;
@synthesize relinkNum;

@synthesize maxGroupMember;
@synthesize user_code;
@synthesize isNeetModifyPwd;

static conn *_conn;

+(conn *)getConn
{
	if(_conn == nil)
	{
		_conn = [[self alloc]init];
	}
	return _conn;
}
/** 初始化 */
-(id)init
{
	id _id = [super init];
	msgQueue = [[NSOperationQueue alloc]init];
	[msgQueue setMaxConcurrentOperationCount:1];
	
	orgQueue = [[NSOperationQueue alloc]init];
	[orgQueue setMaxConcurrentOperationCount:1];
    self.relinkNum=0;
	
	notificationObject = [[eCloudNotification alloc]init];
	db = [eCloudDAO getDatabase];
	userDb = [eCloudUser getDatabase];
    advanceQueryDAO = [AdvanceQueryDAO getDataBase];
    
    _statusConn = [StatusConn getConn];
    
    _userDataConn = [UserDataConn getConn];
    
    loginConn = [LoginConn getConn];
    accessConn = [AccessConn getConn];
    empLogoConn = [EmpLogoConn getConn];
    
    _userDataDao = [UserDataDAO getDatabase];
    
    msgConn = [MsgConn getConn];
    
    self.needClearEmpArray = NO;
    
	return _id;
}
-(void)dealloc
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	[self uninitConn];
    self.notificationName = nil;
    self.notificationObject = nil;
    
    self.curConvId = nil;
    self.allEmpsDic = nil;
    self.allDeptsDic = nil;
	
    self.oldBlacklistUpdateTime = nil;
    self.newBlacklistUpdateTime = nil;
    
    
    //	[checkTimeThread release];
    //	checkTimeThread = nil;
    
    
	self.curUser = nil;
    
    if(self.msgThread && [self.msgThread isExecuting])
    {
        [self.msgThread cancel];
    }
	self.msgThread = nil;
	
    self.contactNeedDownloadLogo = nil;
	self.allEmpArray = nil;
	self.onlineEmpCountArray = nil;
	[msgQueue release];
	[orgQueue release];
	self.userId = nil;
    self.user_code=nil;
	self.userEmail = nil;
	self.userPasswd = nil;
	self.userName = nil;
	self.deviceToken = nil;
	self.emp_logo = nil;
	
	self.oldDeptUpdateTime = nil;
	self.oldEmpDeptUpdateTime = nil;
	self.oldEmpUpdateTime = nil;
	self.oldVgroupTime = nil;
	
	self.compUpdateTime = nil;
	self.deptUpdateTime = nil;
	self.empUpdateTime = nil;
	self.empDeptUpdateTime = nil;
	self.VgroupTime = nil;
	
	self.tempConvId = nil;
	self.offLineMsgs = nil;
	
	self.updateVersion = nil;
	self.updateUrl = nil;
	self.updateInfo = nil;
    
	self.wPurviewDic = nil;
	
	
	if(notificationObject != nil)
	{
		[notificationObject release];
	}

	_conn = nil;
	self.empArray = nil;
	self.deptArray = nil;
	self.empStatusArray = nil;
	self.empDeptArray = nil;
	
	[super dealloc];
}
/*
-(void)getTickCountByNext//获取当前时钟值
{
  	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    self.dnextTime = [[NSDate date]timeIntervalSince1970];
    //    [LogUtil debug:[NSString stringWithFormat:@"------ self.dnextTime---%llu",self.dnextTime]];
}


-(void) CreateSocketClient: (NSString*) serverIP PORT: (in_port_t) port
{
    CFSocketContext sockContext = {0, // 结构体的版本，必须为0
        self,  // 一个任意指针的数据，可以用在创建时CFSocket对象相关联。这个指针被传递给所有的上下文中定义的回调。
        NULL, // 一个定义在上面指针中的retain的回调， 可以为NULL
        NULL, NULL};
	
	CFSocketRef _client = CFSocketCreate(
										 kCFAllocatorDefault,
										 PF_INET,        // The protocol family for the socket
										 SOCK_STREAM,    // The socket type to create
										 IPPROTO_TCP,    // The protocol for the socket. TCP vs UDP.
										 kCFSocketConnectCallBack,  // New connections will be automatically accepted and the callback is called with the data argument being a pointer to a CFSocketNativeHandle of the child socket.
										 (CFSocketCallBack)&TCPServerConnectCallBack,
										 &sockContext );
	
	
    if (_client != nil) {
        int existingValue = 1;
		
        // Make sure that same listening socket address gets reused after every connection
        setsockopt( CFSocketGetNative(_client),
                   SOL_SOCKET, SO_REUSEADDR, (void *)&existingValue,
                   sizeof(existingValue));
		
		
        struct sockaddr_in addr4;   // IPV4
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = htons(port);
        addr4.sin_addr.s_addr = inet_addr([serverIP UTF8String]);  // 把字符串的地址转换为机器可识别的网络地址
		
        // 把sockaddr_in结构体中的地址转换为Data
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
        CFSocketConnectToAddress(_client, // 连接的socket
                                 address, // CFDataRef类型的包含上面socket的远程地址的对象
                                 -1  // 连接超时时间，如果为负，则不尝试连接，而是把连接放在后台进行，如果_socket消息类型为kCFSocketConnectCallBack，将会在连接成功或失败的时候在后台触发回调函数
                                 );
		
        CFRunLoopRef cRunRef = CFRunLoopGetCurrent();    // 获取当前线程的循环
        // 创建一个循环，但并没有真正加如到循环中，需要调用CFRunLoopAddSource
        CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _client, 0);
        CFRunLoopAddSource(cRunRef, // 运行循环
                           sourceRef,  // 增加的运行循环源, 它会被retain一次
                           kCFRunLoopCommonModes  // 增加的运行循环源的模式
                           );
        CFRelease(sourceRef);
		
		
		
    }
}
// socket回调函数的格式：
static void TCPServerConnectCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    if (data != NULL) {
        // 当socket为kCFSocketConnectCallBack时，失败时回调失败会返回一个错误代码指针，其他情况返回NULL
        NSLog(@"连接失败");
        return;
    }
	
}
*/

/** 增加一个新方法，释放连接资源 */
-(void)uninitConn
{
	if(_conncb)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
		CLIENT_UnInit(_conncb, 0);
		_conncb = nil;
	}
}

/** 初始化链接 */
-(bool)initConn
{
    [LogUtil debug:[NSString stringWithFormat:@"%s,开始连接...",__FUNCTION__]];
    connStartTime = [[NSDate date]timeIntervalSince1970];
    
    self.maxGroupMember = default_group_member;
    
	self.isKick = NO;
    self.isDisable = NO;
	self.connStatus = linking_type;
    psSynCount = -1;
    psSynCurrCount = -1;
    
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	
  	NSString *keyPath = [[StringUtil getHomeDir] stringByAppendingPathComponent:@"rsa_public.key"];
	NSString *localKeyPath = [[StringUtil getBundle] pathForAuxiliaryExecutable:@"rsa_public.key"];
	if([[NSFileManager defaultManager]fileExistsAtPath:localKeyPath isDirectory:NO])
	{
		NSString *keyStr = [NSString stringWithContentsOfFile:localKeyPath encoding:NSUTF8StringEncoding error:nil];
		[LogUtil debug:[NSString stringWithFormat:@"本地保存了密钥：%@",keyStr]];
		
		if(![[NSFileManager defaultManager] fileExistsAtPath:keyPath isDirectory:NO])
		{
			NSData *data=[NSData dataWithContentsOfFile:localKeyPath];
			[data writeToFile:keyPath atomically:YES];
		}
	}
	if([[NSFileManager defaultManager] fileExistsAtPath:keyPath isDirectory:NO])
	{
		NSString *keyStr = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:nil];
		[LogUtil debug:[NSString stringWithFormat:@"密钥文件存在，密钥是%@",keyStr]];
	}
	else
	{
		[LogUtil debug:@"密钥文件不存在"];
	}
    
    CLIENT_SetRsaKeyPath((char*)[keyPath cStringUsingEncoding:NSUTF8StringEncoding]);
	
	[self reInitConn];
	
	ServerConfig *serverConfig = [userDb getServerConfig];
	
	int tryCount = 0;
	int nRet = [accessConn connectServer];
    if (nRet == 0)
	{
        int nowTime = [[NSDate date]timeIntervalSince1970];
        [LogUtil debug:[NSString stringWithFormat:@"连接服务器成功，所需时间：%d", nowTime - connStartTime]];
        connStartTime = nowTime;
        
		return true;
	}
	else
	{
		self.connStatus = not_connect_type;
	}
    
    /** 在此处添加连接服务器失败的通知 */
    [self sendWandaLoginNotification:nRet];

	return false;
}
/*
- (void)getLastConnectData
{
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
    lastConnectIp = [_defaults valueForKey:@"last_connect_ip"];
    lastConnectPort = [[_defaults valueForKey:@"last_connect_port"]intValue];
}*/

-(void)reInitConn
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	
	[self uninitConn];
    
    [StringUtil clearLogFile];
	
    _conncb = CLIENT_Init(CMNET,[[[StringUtil getHomeDir]stringByAppendingPathComponent:@"client"]cStringUsingEncoding:NSUTF8StringEncoding]);
}

/** 系统转到前台后，如果在线，那么发送checktime指令到服务器端，验证和服务器通讯是否可用 */
-(int)sendConnCheckCmd
{
    //        只有连接状态正常的时候才发送checkTime
    if (self.connStatus == normal_type)
    {
        int curTime = [self getCurrentTime];
        [LogUtil debug:[NSString stringWithFormat:@"%s,curTime - lastSendCheckCmdTime is %d",__FUNCTION__,(curTime - lastSendCheckTimeCmdTime)]];
        if((curTime - lastSendCheckTimeCmdTime) > 3)
        {
            activeCheckTimeSerial = [[NSDate date] timeIntervalSince1970];
            int ret = CLIENT_CheckTime(_conncb, activeCheckTimeSerial);
            if(ret == 0)
            {
                self.connStatus = rcv_type;
                
//                eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
//                _notificationObject.cmdId = start_check_network;
//                
//                [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
                
                lastSendCheckTimeCmdTime = curTime;
                return 0;
            }
            return 1;
        }
        else
        {
            return 2;
        }
    }
    else
    {
        return 2;
    }
}

/** 设置是否屏蔽群组消息，flag 为0表示不屏蔽，flag为1表示屏蔽 */
-(BOOL)setRcvFlagOfConv:(NSString*)convId andRcvMsgFlag:(int)rcvMsgFlag
{
//    (const char)
	int ret = CLIENT_GroupPushFlag(_conncb,(const char*)[convId cStringUsingEncoding:NSUTF8StringEncoding],rcvMsgFlag);
	if(ret == 0)
	{
		return YES;
	}
	return NO;
}

/** 用户按了home键，告诉服务器未读记录数 */
-(BOOL)putUnreadMsgCountToServer
{
	int count=[db getAllNumNotReadedMessge];
	int ret = CLIENT_IosBackGroundReq(_conncb,count);
	if(ret == 0)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,unread msg count is %d",__FUNCTION__,count]];
		return YES;
	}
	return NO;
}

#pragma mark 启用线程发送checktime指令到服务器端，验证网络是否可用
/** 启用线程发送checktime指令到服务器端，验证网络是否可用 */
-(void)sendCheckTime
{
	while(checkTimeThread && ![checkTimeThread isCancelled])
	{
        if([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive)
        {
            /** 只有用户在 */
            /** 如果用户在线 并且 是就绪状态 才检测和服务器的链接 */
            
            if (self.connStatus == normal_type) {
                checkTimeSerial = [[NSDate date] timeIntervalSince1970];
//                [LogUtil debug:[NSString stringWithFormat:@"%s 线程检查和服务器的连接是否正常",__FUNCTION__]];
                int ret = CLIENT_CheckTime(_conncb, checkTimeSerial);
                if(ret == 0)
                {
                    checkTimeTimer = [NSTimer scheduledTimerWithTimeInterval:checktime_timeout target:self selector:@selector(checkTimeTimeout) userInfo:nil repeats:NO];
                }
                else
                {
                    if([[ApplicationManager getManager] needAutoConnect])
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"%s,发checktime指令失败，退出线程，并自动重连",__FUNCTION__]];
                        [[ApplicationManager getManager]connCheckTimeout];
                    }
                    break;
                }
            }
            else
            {
                [LogUtil debug:@"IM还没有就绪，不发检测指令"];
            }
        }
        
		if(checkTimeInterval == send_checktime_interval_short)
		{
			checkTimeInterval = send_checktime_interval_long;
		}
		else
		{
			checkTimeInterval = send_checktime_interval_short;
		}
		[NSThread sleepForTimeInterval:checkTimeInterval];
	}
	[checkTimeThread release];
	checkTimeThread = nil;
}

/** 发送checktime指令超时时自动重连 */
-(void)checkTimeTimeout
{
	checkTimeTimer = nil;
	if([[ApplicationManager getManager] needAutoConnect])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,check time 失败，自动重连",__FUNCTION__]];
		[[ApplicationManager getManager] connCheckTimeout];
	}
}
/** 停止超时检测 */
-(void)stopCheckTimeTimer
{
	if(checkTimeTimer && [checkTimeTimer isValid])
	{
		[checkTimeTimer invalidate];
		checkTimeTimer = nil;
	}
}
/** 关闭链接，一般不用 */
-(void)closeConn
{
	[self uninitConn];
}

/** 登录 */
-(bool)login:(NSString *)mail andPasswd:(NSString*)passwd
{
    /** 因为在发出登录前，已经把账号和密码保存到UserDefaults里了，所以在这里参数 mail和passwd和保存在userdefaults里的账号和密码是一致的 */
    /** 但是为了兼容以前的程序，还是要给self.userEmail和self.userPassword赋值 */
    self.userEmail = [UserDefaults getUserAccount];
    self.userPasswd = [UserDefaults getUserPassword];
    char *cUserAccount = [StringUtil getCStringByString:self.userEmail];
    char *userPassword =  [StringUtil getCStringByString:self.userPasswd];
    
//    char *version = [StringUtil getCStringByString:[userDb getVersion:app_version_type]];
    /** 从UserDefaults里获取 apptype */
    NSString *appType = [UserDefaults getAppType];// [NSString stringWithFormat:@"%@",independent_enterprise_type];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,app type is %@ token is %@ ",__FUNCTION__,appType,[UserDefaults getDeviceToken]]];

    /** 如果是融合版本 也就是我们提供SDK给其它公司的版本，为了方便查看SDK的生成日期，建议合作公司打包时配置sdk的发布日期 */
    if ([appType isEqualToString:combine_enterprise_type]){
        NSString *SDKCreateTime = [StringUtil getSDKReleaseDate];
        if (SDKCreateTime.length) {
            [LogUtil debug:[NSString stringWithFormat:@"%s SDK生成日期为 %@ ",__FUNCTION__,SDKCreateTime]];
        }else{
            [LogUtil debug:[NSString stringWithFormat:@"%s 请在info.plist配置 SDKReleaseDate 格式为yyyy-MM-dd 序列号(001,002...) 比如 '2016-09-22 001' ",__FUNCTION__]];
        }
    }
    
    char *version = [StringUtil getCStringByString:appType];
    
    /** 原来这个参数传的是@"mac" 这在南航会引起 16位密码不能正常登录，现在改为传@"" */
    const char *mac = [@"" cStringUsingEncoding:NSUTF8StringEncoding];

    /** 推送token */
    char *token = [StringUtil getCStringByString:[UserDefaults getDeviceToken]];

    [LogUtil debug:[NSString stringWithFormat:@"%s,userAccount is %@",__FUNCTION__,self.userEmail]];

    int nRet = CLIENT_Login(_conncb, cUserAccount, userPassword, TERMINAL_IOS, version, mac, token);
    
	[LogUtil debug: [NSString stringWithFormat:@"%s,nRet is %d",__FUNCTION__,nRet]];
	
	if(nRet == 0)
	{
//        if (![eCloudConfig getConfig].supportShareExtension)
//        {
            NSString *str =  [[ServerConfig shareServerConfig]getShareName];
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:str];
            [sharedDefaults setObject:@(1) forKey:@"isLogin"];
        //}
        
        /** update by shisp 连接成功后，需要显示收取中，或者正在下载组织架构 */
		self.isLoginCmd = true;

        if (self.msgThread && self.msgThread.cancelled) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 收消息线程已取消",__FUNCTION__]];
        }
        if (self.msgThread && self.msgThread.finished) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 收消息线程已结束",__FUNCTION__]];
        }
        if(self.msgThread == nil || self.msgThread.cancelled || self.msgThread.finished)
		{
            [LogUtil debug:[NSString stringWithFormat:@"%s 创建新的收消息线程",__FUNCTION__]];
			self.msgThread =  [[[NSThread alloc]initWithTarget:self selector:@selector(getMessage) object:nil]autorelease];
			[self.msgThread start];
		}
		
		[self startTimeoutTimer:30];
		
		return true;
	}
    [_conn sendWandaLoginNotification:RESULT_NOLOGIN];

	self.connStatus = not_connect_type;
	return false;
}

/** 启动超时定时 */
-(void)startTimeoutTimer:(int)_timeout
{
	[self performSelectorOnMainThread:@selector(startTimeoutTimerOnMainThread:) withObject:[StringUtil getStringValue:_timeout] waitUntilDone:YES];
}

-(void)startTimeoutTimerOnMainThread:(NSString *)timeoutStr
{
	[self stopTimeoutTimer];
	timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeoutStr.intValue target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}


/** 停止超时定时器 */
-(void)stopTimeoutTimer
{
	[self performSelectorOnMainThread:@selector(stopTimeoutTimerOnMainThread) withObject:nil waitUntilDone:YES];
}
-(void)stopTimeoutTimerOnMainThread
{
	if(timeoutTimer && [timeoutTimer isValid])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
		[timeoutTimer invalidate];
	}
	timeoutTimer = nil;
}

#pragma mark --请求超时--
-(void)requestTimeout
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	timeoutTimer = nil;
    /** 默认的通知名称 */
	if(self.isLoginCmd)
	{
        [self sendWandaLoginNotification:RESULT_REQTIMEOUT];
        
        /** 如果是登录指令，那么发送登录超时通知 */
		self.connStatus = not_connect_type;
		[LogUtil debug:[NSString stringWithFormat:@"%s,登录超时",__FUNCTION__]];
		
		self.isLoginCmd = false;
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = login_timeout;
        
        [[NotificationUtil getUtil]sendNotificationWithName:LOGIN_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
    
        return;
        
	}
    
    /** 获取部门显示配置数据超时 */
    else if (self.isSyncDeptShowCmd){
        self.isSyncDeptShowCmd = NO;
        [self getEmpDeptInfo:nil];
        return;
    }

    /** 创建群组超时 */
	else if(self.isCreateGroupCmd)
	{
		self.isCreateGroupCmd = false;
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = create_group_timeout;
        
        [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        
        return;

	}
    
    /** 获取用户资料超时 */
	else if(self.isGetUserInfoCmd)
	{
		self.isGetUserInfoCmd = false;
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = get_user_info_timeout_new;
        
        [[NotificationUtil getUtil]sendNotificationWithName:GETUSERINFO_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        return;
	}
    /** 退出群组超时 */
	else if(self.isQuitGroupCmd)
	{
		self.isQuitGroupCmd = false;
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = quit_group_timeout;
        
        [[NotificationUtil getUtil]sendNotificationWithName:QUIT_GROUP_NOTIFICATION andObject:_notificationObject andUserInfo:nil];\
        return;
	}
    
    /** 获取离线消息条数超时 */
    else if(self.isGetOfflineMsgNumCmd)
    {
        /** 获取离线消息条数超时，直接修改为离线消息收取完毕 */
        self.isGetOfflineMsgNumCmd = false;
        [self sendRcvOfflineMsgFinishNotify];
        return;
    }
    /** 设置、取消常用联系人超时 设置、取消常用部门超时 */
    else if(self.isUpdateUserDataCmd)
    {
        self.isUpdateUserDataCmd = false;
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = update_user_data_timeout;
        
        [[NotificationUtil getUtil]sendNotificationWithName:UPDATE_USER_DATA_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        return;
    }
    /** 消息撤回超时 */
    else if (self.isRecallMsgCmd)
    {
        self.isRecallMsgCmd = NO;
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = recall_msg_timeout;
        
        [[NotificationUtil getUtil]sendNotificationWithName:RECALL_MSG_RESULT_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        return;
    }
    /** 其它类型超时 */
    eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
    _notificationObject.cmdId = cmd_timeout;
    
    [[NotificationUtil getUtil]sendNotificationWithName:TIMEOUT_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
}

#pragma mark ----获取公司信息-----
-(bool)getCompInfo
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	if(CLIENT_GetCompInfo(_conncb) == 0)
	{
        return true;
	}
	return false;
}

#pragma mark----获取部门信息----
-(bool)getDeptInfo:(NSString *)deptUpdateTime
{
	[LogUtil debug:[NSString stringWithFormat:@"%s, old time is %@ , new time is %@",__FUNCTION__,self.oldDeptUpdateTime,self.deptUpdateTime]];
    
    /** 如果时间比服务器返回的时间晚，那么去服务器获取更新 */
	if(self.deptUpdateTime.intValue > SERVER_INIT_TIMESTAMP && [self.oldDeptUpdateTime compare:self.deptUpdateTime] == NSOrderedAscending)
	{
		self.timeStart = [[NSDate date] timeIntervalSince1970];
        
		if(self.oldDeptUpdateTime.intValue == 0)
		{
			self.isFirstGetUserDeptList = true;
        
            /** 删除所有的部门数据 */
            //			[db deleteAllDepts];
		}
		self.deptPage = 0;
		CLIENT_GetDeptInfo(_conncb, [self.oldDeptUpdateTime intValue],TERMINAL_IOS);
		self.deptArray = [NSMutableArray array];

         self.downloadOrgTips = [StringUtil getAppLocalizableString:@"conn_dept_synchronizing"];
	}
	else
	{
        /** 查询下dept_name_contain_parent是否生成，如果没有生成，那么就先计算 */
        [db calculateDeptNameContainParentOfDept];
        
		[self getAllDeptId];
		
        /** 获取员工部门有没有更新 */
//		[self getEmpDeptInfo:nil];
        
        //        同步 部门显示配置 然后同步员工与部门关系
        [[OrgConn getConn]syncDeptShowConfig];

	}
    
	return true;
}

#pragma mark 获取所有的部门id，并初始化在线人数为0
-(void)getAllDeptId
{
    if (!self.isOfflineMsgFinish)
    {
        [LogUtil debug:@"离线消息还没有获取完，暂时不获取部门"];
        return;
    }
	if(self.onlineEmpCountArray == nil ||  self.onlineEmpCountArray.count == 0)
	{
        [self getAllDeptFromDB];
	}
}

- (void)getAllDeptFromDB
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    DeptInMemory *deptInMemory = [[DeptInMemory alloc]init];
    self.onlineEmpCountArray = [NSMutableArray arrayWithObject:deptInMemory];
    [deptInMemory release];
    
    dispatch_queue_t queue = dispatch_queue_create("get_dept_from_db", NULL);
    dispatch_async(queue, ^{
        [db getAllDeptId];
    });
    dispatch_release(queue);
}

/** 添加任务到队列 */
-(void)addTaskToQueue:(SEL)_selector andObject:(id)_object
{
    [self addTaskToQueueWithTarget:self withSelector:_selector withObject:_object];
}

/** 添加任务到队列 */
-(void)addTaskToQueueWithTarget:(id)_target withSelector:(SEL)_selector withObject:(id)_object
{
	NSInvocationOperation *_invocation = [[NSInvocationOperation alloc]initWithTarget:_target selector:_selector object:_object];
	
	if ([[orgQueue operations] count]>0 && [[orgQueue operations]lastObject]) {
		
		[_invocation addDependency:[[orgQueue operations]lastObject]];
	}
	[orgQueue addOperation:_invocation];
	[_invocation release];
}

#pragma mark---获取员工信息----
-(bool)getEmployeeInfo:(NSString *)empUpdateTime
{
//    self.oldEmpUpdateTime = [StringUtil getStringValue:self.empUpdateTime.intValue - 3600  * 24 * 2];
	[LogUtil debug:[NSString stringWithFormat:@"%s,old time is %@ , new time is %@",__FUNCTION__,self.oldEmpUpdateTime,self.empUpdateTime]];
    
    if (self.empUpdateTime.intValue == SERVER_INIT_TIMESTAMP) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 登录返回的是初始时间戳 不处理",__FUNCTION__]];
        
        return false;
    }
    
    /** 如果员工信息是快同步，并且有更新，则获取更新 */
	if([self.oldEmpUpdateTime compare:self.empUpdateTime] == NSOrderedAscending)
	{
		if(self.oldEmpUpdateTime.intValue == 0)
		{
            /** 如果是慢同步，那么就只保存时间，只有快同步时才获取变化 */
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,self.empUpdateTime,emp_updatetime, nil];
			[userDb saveEmpUpdateTime:dic];
		}
        //bigdata
 		else
		{
			self.empArray = [NSMutableArray array];
            //			CLIENT_GetUserList(_conncb, [self.oldEmpUpdateTime intValue]);
            //			bigdata
			CLIENT_GetUserList(_conncb, [self.oldEmpUpdateTime intValue],TERMINAL_IOS);
            
            self.userDeptPage = 0;

		}
	}
	return true;
}

-(void)getAllEmpArray
{
    if (!self.isOfflineMsgFinish)
    {
        [LogUtil debug:@"离线消息还没有获取完，暂时不获取人员"];
        return;
    }
    
	if((self.allEmpArray == nil || self.allEmpArray.count == 0))
	{
		[self getAllEmpArrayFromDb];
        //		[self addTaskToQueue:@selector(getAllEmpArrayFromDb) andObject:nil];
	}
}

-(void)getAllEmpArrayFromDb
{
    /** 首先是把当前用户加到allEmpArray中，避免获取多次 */
    Emp *_emp = [[Emp alloc]init];
    self.allEmpArray = [NSMutableArray arrayWithObject:_emp];
    [_emp release];
    
    self.empCodeAndEmpDic = [NSMutableDictionary dictionary];
    self.allEmpsDic = [NSMutableDictionary dictionary];

    dispatch_queue_t queue = dispatch_queue_create("get_employee_from_db", NULL);
    dispatch_async(queue, ^{
        [db getEmployeeList];
    });
    dispatch_release(queue);
    //    update by shisp 更换为采用异步方式获取员工数据
    //	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //	self.allEmpArray = [NSMutableArray arrayWithArray:[db getEmployeeList]];
    //	[pool release];
}

#pragma mark---获取员工部门对应关系-----
-(bool)getEmpDeptInfo:(NSString*)empDeptUpdateTime
{
	[LogUtil debug:[NSString stringWithFormat:@"%s,old time is %@ , new time is %@",__FUNCTION__,self.oldEmpDeptUpdateTime,self.empDeptUpdateTime]];
    

    /** 如果时间比服务器返回的时间晚，那么需要去服务器获取更新 */
    if(self.empDeptUpdateTime.intValue > SERVER_INIT_TIMESTAMP && [self.oldEmpDeptUpdateTime compare:self.empDeptUpdateTime] == NSOrderedAscending)
	{
		self.timeStart = [[NSDate date] timeIntervalSince1970];
		
		if([self.oldEmpDeptUpdateTime compare:@"0"] == NSOrderedSame)
		{
			self.isFirstGetUserDeptList = true;
            //			[db deleteAllEmpDeptsAndEmps];
		}
		else
		{
			self.isFirstGetUserDeptList = false;
		}
		
		self.userDeptPage = 0;
		
		self.empDeptArray=[NSMutableArray array];
		
        //		CLIENT_GetUserDept(_conncb, [self.oldEmpDeptUpdateTime intValue]);
        //		bigdata
		CLIENT_GetUserDept(_conncb, [self.oldEmpDeptUpdateTime intValue],TERMINAL_IOS);
        
        self.downloadOrgTips = [StringUtil getAppLocalizableString:@"conn_emp_synchronizing"];
	}
	else
	{
        if (self.needClearEmpArray) {
            if(self.allEmpArray && self.allEmpArray.count > 0)
            {
                [self.allEmpArray removeAllObjects];
            }
            
            self.needClearEmpArray = NO;
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 之前同步到有用户离职，所以需要重新获取员工与部门关系",__FUNCTION__]];
        }
        
        
		[self getAllEmpArray];
        //获取用户状态
        //		[self getUserStateList];
//		[self getOfflineMsgNum];
        
#ifdef _XIANGYUAN_FLAG_
//#ifdef _LANGUANG_FLAG_
//        同步获取部门显示配置并处理
//        [[OrgConn getConn]getXYDeptShowConfig];
#endif

        
        /** 应该去先同步固定群组 */
        [_userDataConn sendSystemGroupSync];
	}
	return true;
}

#pragma mark---获取所有用户在线状态-----
-(bool)getUserStateList:(BOOL)needCheckTime
{
    /** 万达版本不获取全量状态或增量状态 */
    return false;
    
    /** 如果是登录后第一次获取状态，或者和上一次获取状态相差了5分钟，则获取状态 */
    int curTime = [self getCurrentTime];
    if(needCheckTime)
    {
        [LogUtil debug:[NSString stringWithFormat:@"两次获取状态间隔为:%d",(curTime - lastGetUserStateListTime)]];
    }
    
    if(!needCheckTime || (needCheckTime && (curTime - lastGetUserStateListTime) >= 300))
    {
        if(CLIENT_GetUserStateList(_conncb)== 0)
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
            self.empStatusArray = [NSMutableArray array];
            lastGetUserStateListTime = curTime;
            
            return true;
        }
    }
	return false;
}

#pragma mark --创建聊天群组---
-(bool)createConversation:(NSString *)convId andName:(NSString*)convName andEmps:(NSArray*)convEmps
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	char iEmps[[convEmps count] * sizeof(int)];
	int iEmp;
	int index = 0;
	for(Emp *emp in convEmps)
	{
		iEmp = emp.emp_id;
		memcpy(iEmps + index, &iEmp, sizeof(int));
		index += sizeof(int);
	}
	
	const char * cConvName = [convName cStringUsingEncoding:NSUTF8StringEncoding];
	int len = strlen(cConvName);
    
	if(CLIENT_CreateGroup(_conncb, (char*)[convId cStringUsingEncoding:NSUTF8StringEncoding], (char*)cConvName,len, (char*)iEmps, [convEmps count],[self getCurrentTime]) == 0){
		
		self.isCreateGroupCmd = true;
		[self startTimeoutTimer:30];
		return true;
	}
	return false;
}

#pragma mark---获取用户资料---
-(bool)getUserInfo:(int)userId
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	if(self.userStatus != status_online)
		return false;

    /** 如果是手动点击获取用户资料，那么第3个参数为1 */
	if(CLIENT_GetEmployee(_conncb, userId,1) == 0)
	{
		self.isGetUserInfoCmd = true;
		[self startTimeoutTimer:15];
		return true;
	}
	return false;
}

#pragma mark---后台自动获取用户资料---
-(bool)getUserInfoAuto:(int)userId
{
    if(self.userStatus != status_online)
        return false;

    /** 华夏幸福不需要客户段同步用户资料 */
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    if(userId == self.userId.intValue){
        CLIENT_GetEmployee(_conncb, userId,0);
    }
#else
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    if(CLIENT_GetEmployee(_conncb, userId,0) == 0)
    {
        return true;
    }
#endif
    return false;
}
#pragma mark-----获取组信息-----
-(bool)getGroupInfo:(NSString*)grpId
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	if(CLIENT_GetGroupInfo(_conncb, (char*)[grpId cStringUsingEncoding:NSUTF8StringEncoding]) == 0)
    {
        return true;
    }
    return false;
}

#pragma mark 主动退群 需要提示用户 需要处理超时的情况
-(bool)quitGroup:(NSString*)convId
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	
	if(self.userStatus != status_online) return false;
	
	
	if(CLIENT_QuitGroup(_conncb, (char*)[convId cStringUsingEncoding:NSUTF8StringEncoding]) == 0)
	{
		self.isQuitGroupCmd = true;
		[self startTimeoutTimer:30];
		
		return true;
	}
	
	return false;
}
#pragma mark----修改聊天群组成员 type: 0: add member 1: del memeber----
-(bool)modifyGroupMember:(NSString *)grpId andEmps:(NSArray *)emps andOperType:(int)operType
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	if(self.userStatus != status_online) return false;
	
	if(emps == nil || [emps count] == 0) return false;
    
	char cEmp[[emps count] * sizeof(int)];
	int index = 0;
	int empId;
	for(Emp *emp in emps)
	{
		empId = emp.emp_id;
		memcpy(cEmp + index,& empId, sizeof(int));
		index += sizeof(int);
	}
	
	if(CLIENT_ModiMember(_conncb, (char*)[grpId cStringUsingEncoding:NSUTF8StringEncoding], (char*)cEmp, [emps count], operType,[self getCurrentTime]) == 0)
	{
		[self startTimeoutTimer:30];
        
		return true;
	}
	
	return false;
    
}

#pragma mark ---修改群组名称和备注 type: 0: the group name; 1: the group note-----
/** 如果创建人是自己，可以提交到服务器，修改名称，否则只修改本地的备注 */
-(bool)modifyGroupInfo:(NSString*)grpId andValue:(NSString*)newValue andValueType:(int)valueType
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	if(self.userStatus != status_online) return false;
	
	if(CLIENT_ModiGroup(_conncb, (char*)[grpId cStringUsingEncoding:NSUTF8StringEncoding], (char*)[newValue cStringUsingEncoding:NSUTF8StringEncoding], valueType,[self getCurrentTime]) == 0)
	{
		[self startTimeoutTimer:30];
        
		return true;
	}
	return false;
}

#pragma mark---- 0: 性别 1: 籍贯 2: 出生日期 3: 住址 4:办公电话号码 5: 手机号码 6: 密码 7:头像ID 8:个人签名 9:权限 10:宅电 11:紧急联系手机 14:修改邮箱  100:修改多项资料
-(bool)modifyUserInfo:(int)type andNewValue:(NSString*)newValue
{
	[LogUtil debug:[NSString stringWithFormat:@"%s,type is %d,value is %@",__FUNCTION__,type,newValue]];
    
	if(self.userStatus != status_online) return false;
	const char * cNewValue = [newValue cStringUsingEncoding:NSUTF8StringEncoding];
    int len = strlen(cNewValue);
    
	if(CLIENT_ModiInfo(_conncb, type, len, (char*)cNewValue) == 0)
	{
		[self startTimeoutTimer:30];
        
		return true;
	}
	return false;
}
#pragma mark 头像修改成功后，通知最近的10个联系人 deprecated
-(void)notifyRecentContactWhenUpdateLogo:(NSString *)newUrl
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	NSMutableArray *singleContact = [NSMutableArray array];
	NSMutableArray *groupContact = [NSMutableArray array];
	
	NSArray *recentContact = [db getRecentContact];
	for(NSDictionary *dic in recentContact)
	{
		if([[dic valueForKey:@"conv_type"]intValue] == singleType)
		{
			[singleContact addObject:[dic valueForKey:@"conv_id"]];
		}
		else
		{
			[groupContact addObject:[dic valueForKey:@"conv_id"]];
		}
	}
	
	const char *cNewUrl = [newUrl cStringUsingEncoding:NSUTF8StringEncoding];
	int newUrlLen = strlen(cNewUrl);

    /** 初始化 */
	RESETSELFINFO _info;
	memset(&_info,0,sizeof(RESETSELFINFO));
	
    /** 用户id */
	_info.dwUserID = self.userId.intValue;
    
    /** 修改类型 */
	_info.cModiType = 7;
    
    /** 修改内容长度 */
	_info.cLen = newUrlLen;
	
    /** 修改内容 */
	memcpy(_info.aszModiInfo,cNewUrl,newUrlLen);
	
    /** 单人总数 */
    /** 单人 */
	int singleCount = singleContact.count;
	if(singleCount > 0)
	{
		_info.cSigleNum = singleCount;
		
		for(int i=0;i<singleCount;i++)
		{
			_info.dwDestUserID[i] = [[singleContact objectAtIndex:i]intValue];
		}
	}
    /** 多人总数 */
    /** 多人 */
	int groupCount = groupContact.count;
	if(groupCount > 0)
	{
		_info.cGroupNum = groupCount;
		for(int i=0;i<groupCount;i++)
		{
            //			[LogUtil debug:[NSString stringWithFormat:@"%@",[groupContact objectAtIndex:i]]];
			sprintf(_info.aszGroupID[i],"%s",[[groupContact objectAtIndex:i]cStringUsingEncoding:NSUTF8StringEncoding]);
		}
	}
	
	CLIENT_ModiSelfNotice(_conncb,&_info);
}

#pragma mark---发送消息 文本消息---
/** 会话-发送消息 会话id，会话类型，消息类型，消息和消息Id */
-(bool)sendMsg:(NSString*)convId andConvType:(int)convType andMsgType:(int)msgType andMsg:(NSString*)msg andMsgId:(long long)msgId andTime:(int)nSendTime andReceiptMsgFlag:(int)receiptMsgFlag
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	if(self.userStatus != status_online)
		return false;
    
    if (convType == singleType) {
        
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:convId])
        {
            convId = [[MiLiaoUtilArc getUtil]getEmpIdWithMiLiaoConvId:convId];
            msg = [[MiLiaoUtilArc getUtil] formatMiLiaoMsg:msg];
            /** 密聊消息默认为一呼百应消息或者回执消息 */
            receiptMsgFlag = conv_status_huizhi;
        }
        else if ([UserDefaults getIRobotId] == convId.intValue) {
            msg = [[RobotDisplayUtil getUtil]formatMsg:msg];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 格式化后的发送给小万的消息为: %@",__FUNCTION__,msg]];
        }
    }
    
    const char *cMsg = [msg cStringUsingEncoding:NSUTF8StringEncoding];
	int len = strlen(cMsg);
    /*-------------------------------补前面10位为0-------------------------*/
    char temp[len+10];
    memset(temp,0,sizeof(temp));
    if (msgType==type_text || msgType == type_imgtxt || msgType == type_wiki) {//补前面10位为0
        
        memcpy(temp+10,cMsg,len);
        len=len+10;
        cMsg=temp;
    }
	if(convType == rcvMassType)
	{

        /** 发送一呼万应消息的回复 */
		NSRange range = [convId rangeOfString:@"|"];
		if(range.length > 0)
		{
			NSString *srcMsgId = [convId substringToIndex:range.location];
			long long lSrcMsgId = [srcMsgId longLongValue];
			NSString *sEmpId = [convId substringFromIndex:range.location + 1];
			int ret = CLIENT_SendSMS(_conncb, sEmpId.intValue, msgType,(char *)cMsg , len, msgId,nSendTime,0,0,0,2,lSrcMsgId);
			if( ret == 0)
				return true;
			else
			{
				[LogUtil debug:[NSString stringWithFormat:@"ret is %d",ret]];
			}
			return false;
		}
	}
	
    /** 如果是回执消息，那么按照回执消息的协议发送 */
    int cRead = 0;
    if (receiptMsgFlag == conv_status_huizhi) {
        cRead = 1;
        receiptMsgFlag = 0;
    }
    
    /** 单人会话 */
	if(convType == singleType)
	{
		int ret = CLIENT_SendSMS(_conncb, convId.intValue, msgType,(char *)cMsg , len, msgId,nSendTime,cRead,0,0,receiptMsgFlag,0);
		if( ret == 0)
			return true;
		else {
			[LogUtil debug:[NSString stringWithFormat:@"ret is %d",ret]];
		}
	}
	else if(convType == mutiableType) {
        int nGroupType = [_userDataDao getGroupTypeValueByConvId:convId];
        
		if(CLIENT_SendtoGroup(_conncb, (char*)[convId cStringUsingEncoding:NSUTF8StringEncoding],msgType,(char*)cMsg, len, msgId,nSendTime,nGroupType,0,0,receiptMsgFlag,cRead) == 0)
			return true;
	}
    
	return false;
}

/** 会话-发送图片或录音或文件消息，会话id，会话类型，消息类型，文件大小，文件名字，文件URL和消息Id */
-(bool)sendMsg:(NSString*)convId andConvType:(int)convType andMsgType:(int)msgType andFileSize:(int)fileSize andFileName:(NSString*)fileName andFileUrl:(NSString*)fileUrl andMsgId:(long long)msgId andTime:(int)nSendTime andReceiptMsgFlag:(int)receiptMsgFlag
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    /** add by shisp 如果fileUrl 包含了 _ ,那么属于发送本地文件，那么需要把_去掉 */
    if(msgType == type_file)
    {
//        NSRange range = [fileUrl rangeOfString:@"_"];
//        if(range.length > 0)
//        {
//            fileUrl = [fileUrl substringToIndex:range.location];
//            NSLog(@"发送本地文件，fileUrl is %@",fileUrl);
//            fileName = [StringUtil getProperFileName:fileName];
//        }
    }
    

    /** 如果用户为离线状态，那么也显示消息，但消息的状态为发送失败 */
	if(self.userStatus != status_online)
	{
        /** 不用修改为发送失败状态 只是发送中而已 */
        //		[db updateSendFlagByMsgId:[StringUtil getStringValue:msgId] andSendFlag:send_failure];
		return false;
	}
    
    if (convType == singleType) {
        
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:convId])
        {
            /** 转为格式化文本消息发送 */
            convId = [[MiLiaoUtilArc getUtil]getEmpIdWithMiLiaoConvId:convId];
            NSString *tempMsg = [[MiLiaoUtilArc getUtil]formatMiLiaoMsg:msgType andMsg:fileUrl andFileName:fileName andFileSize:fileSize];
            /** 密聊消息默认为一呼百应消息或者回执消息 */
            receiptMsgFlag = conv_status_huizhi;
            [self sendMsg:convId andConvType:singleType andMsgType:type_text andMsg:tempMsg andMsgId:msgId andTime:nSendTime andReceiptMsgFlag:receiptMsgFlag];
            return true;
        }
    }

	const char *_fileName = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
	int fileNameLen = strlen(_fileName);
	
	const char *_fileUrl = [fileUrl cStringUsingEncoding:NSUTF8StringEncoding];
	int fileUrlLen = strlen(_fileUrl);
	
	FILE_META fileinfo;
	memset(&fileinfo, 0, sizeof(FILE_META));
	
    //	文件大小
	fileinfo.dwFileSize = htonl(fileSize);
    //	文件名字
	memcpy(fileinfo.aszFileName, _fileName, fileNameLen);
    //	文件url
	memcpy(fileinfo.aszURL,_fileUrl,fileUrlLen);
    
	char* msg = (char*)&fileinfo;
	
	if(convType == rcvMassType)
	{
        /** 发送一呼万应消息的回复*/
		NSRange range = [convId rangeOfString:@"|"];
		if(range.length > 0)
		{
			NSString *srcMsgId = [convId substringToIndex:range.location];
			long long lSrcMsgId = [srcMsgId longLongValue];
			NSString *sEmpId = [convId substringFromIndex:range.location + 1];
			int ret = CLIENT_SendSMS(_conncb, sEmpId.intValue, msgType,msg ,sizeof(FILE_META), msgId,nSendTime,0,0,0,2,lSrcMsgId);
			if( ret == 0)
				return true;
			else
			{
				[LogUtil debug:[NSString stringWithFormat:@"ret is %d",ret]];
			}
			return false;
		}
	}

    /** 如果是回执消息，那么按照回执消息的协议发送*/
    int cRead = 0;
    if (receiptMsgFlag == conv_status_huizhi) {
        cRead = 1;
        receiptMsgFlag = 0;
    }

    /** 单人会话*/
	if(convType == singleType)
	{
		int ret = CLIENT_SendSMS(_conncb, convId.intValue, msgType,msg ,sizeof(FILE_META), msgId,nSendTime,cRead,0,0,receiptMsgFlag,0);
		if( ret == 0)
			return true;
	}
	else {
        int nGroupType = [_userDataDao getGroupTypeValueByConvId:convId];

		if(CLIENT_SendtoGroup(_conncb, (char*)[convId cStringUsingEncoding:NSUTF8StringEncoding],msgType,msg,sizeof(FILE_META), msgId,nSendTime,nGroupType,0,0,receiptMsgFlag,cRead) == 0)
			return true;
	}

    /** 如果发送消息返回了非0，那么设置为发送失败状态*/
    //	[db updateSendFlagByMsgId:[StringUtil getStringValue:msgId] andSendFlag:send_failure];
	return false;
}

/** 增加发送长消息的方法*/
-(bool)sendLongMsg:(NSString*)convId andConvType:(int)convType andMsgType:(int)msgType andFileSize:(int)fileSize andMessageHead:(NSString*)messageHead andFileUrl:(NSString*)fileUrl andMsgId:(long long)msgId andTime:(int)nSendTime andReceiptMsgFlag:(int)receiptMsgFlag
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	
	if(self.userStatus != status_online)
	{
		return false;
	}
    
    /** 文件名字是文件URL.txt*/
	NSString *tempFileName = [NSString stringWithFormat:@"%@.txt",fileUrl];
	const char *_fileName = [tempFileName cStringUsingEncoding:NSUTF8StringEncoding];
	int fileNameLen = strlen(_fileName);
	
	const char *_fileUrl = [fileUrl cStringUsingEncoding:NSUTF8StringEncoding];
	int fileUrlLen = strlen(_fileUrl);
	
	FILE_META fileinfo;
	memset(&fileinfo, 0, sizeof(FILE_META));
	
    /** 文件大小*/
	fileinfo.dwFileSize = htonl(fileSize);

    /** 文件名字*/
	memcpy(fileinfo.aszFileName, _fileName, fileNameLen);

    /** 文件url*/
	memcpy(fileinfo.aszURL,_fileUrl,fileUrlLen);
	
    /** 长消息head,定长50个字符*/
	const char *cMsgHead = [messageHead cStringUsingEncoding:NSUTF8StringEncoding];
	int messageHeadLen = strlen(cMsgHead);
    //	[LogUtil debug:[NSString stringWithFormat:@"messageHeadLen is %d",messageHeadLen);
	
	char _msgHead[50];
	memset(_msgHead, 0, sizeof(_msgHead));
	memcpy(_msgHead,cMsgHead, messageHeadLen > 50?50:messageHeadLen);
	
    /** 消息体的总长度(字体+文件+消息头部)*/
	int totalLen = 10 + sizeof(FILE_META) + 50;

    /** 总消息体*/
	char totalMsg[totalLen];
	memset(totalMsg,0,sizeof(totalMsg));
	memcpy(totalMsg + 10,&fileinfo,sizeof(FILE_META));
	memcpy((totalMsg + 10 + sizeof(FILE_META)), _msgHead, 50);
	
    [LogUtil debug:[NSString stringWithFormat:@"发生长消息，摘要信息是%@",messageHead]];
	if(convType == rcvMassType)
	{

        /** 发送一呼万应消息的回复*/
		NSRange range = [convId rangeOfString:@"|"];
		if(range.length > 0)
		{
			NSString *srcMsgId = [convId substringToIndex:range.location];
			long long lSrcMsgId = [srcMsgId longLongValue];
			NSString *sEmpId = [convId substringFromIndex:range.location + 1];
			int ret = CLIENT_SendSMS(_conncb, sEmpId.intValue, msgType,totalMsg ,sizeof(totalMsg), msgId,nSendTime,0,0,0,2,lSrcMsgId);
			if( ret == 0)
				return true;
			else
			{
				[LogUtil debug:[NSString stringWithFormat:@"ret is %d",ret]];
			}
			return false;
		}
	}
    
    /** 如果是回执消息，那么按照回执消息的协议发送*/
    int cRead = 0;
    if (receiptMsgFlag == conv_status_huizhi) {
        cRead = 1;
        receiptMsgFlag = 0;
    }
    
    /** 单人会话*/
	if(convType == singleType)
	{
		int ret = CLIENT_SendSMS(_conncb, convId.intValue, msgType,totalMsg ,sizeof(totalMsg), msgId,nSendTime,cRead,0,0,receiptMsgFlag,0);
		if( ret == 0)
			return true;
	}
	else {
        int nGroupType = [_userDataDao getGroupTypeValueByConvId:convId];

		if(CLIENT_SendtoGroup(_conncb, (char*)[convId cStringUsingEncoding:NSUTF8StringEncoding],msgType,totalMsg,sizeof(totalMsg), msgId,nSendTime,nGroupType,0,0,receiptMsgFlag,cRead) == 0)
			return true;
	}
    /** 如果发送消息返回了非0，那么设置为发送失败状态*/
	//	[db updateSendFlagByMsgId:[StringUtil getStringValue:msgId] andSendFlag:send_failure];
	return false;
}

#pragma mark -----发送消息已读通知----
-(bool)sendMsgReadNotice:(ConvRecord*)convRecord
{
	if(self.userStatus != status_online) return false;
	
	int senderId = convRecord.emp_id;
	long long msgId = convRecord.origin_msg_id;
	int nowTime = [self getCurrentTime];
    /** type 为 1表示是一呼百应消息 默认是回执消息*/
    
    int msgType = 0;
    if (convRecord.isReceiptMsg) {
        msgType = 1;
        NSLog(@"%s,发送一呼百应已读,%lld",__FUNCTION__,msgId);
    }
    else
    {
        NSLog(@"%s，发送回执已读,%lld",__FUNCTION__,msgId);
    }
	int ret = CLIENT_SendReadSMS(_conncb,senderId, msgId,msgType,nowTime);
	if(ret == 0)
		return true;
	return false;
}
#pragma mark --获取离线消息数量---
-(bool)getOfflineMsgNum
{

    /** 首先同步机器人菜单、机器人主题、生成机器人欢迎语、文件助手欢迎语*/
    [[RobotConn getConn]syncRobotMenu];
    [[RobotConn getConn]syncRobotTopic];    
    [[RobotDAO getDatabase]createOneNewMsgOfGreetingsOfIRobot];
    [[RobotDAO getDatabase]createOneNewMsgOfGreetingsOfFileTransfer];
    [[RobotDAO getDatabase]createOneNewMsgOfGreetingsOfLanxin];
    
    
    // 获取并保存自己能查看电话的人的rank
#if defined(_XIANGYUAN_FLAG_) || defined(_ZHENGRONG_FLAG_)
        [UserDefaults saveRankArray];
#endif
    
#ifdef _GOME_FLAG_
    if (START_GOME_MAIL) {
        [[GOMEEmailUtilArc getEmailUtil]startEmailTimer];
    }
#endif
    
    /** 万达需要第一次登录时，从服务器下载数据库文件，此数据库里应该已经包含下载好的组织架构，以及对应的时间戳,如果需要生成这样的数据库文件，就不再收取离线消息了*/
//    [StringUtil zipDb];
//     return false;
    self.connStatus = rcv_type;
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	int ret = CLIENT_GetOffline(_conncb,TERMINAL_IOS);
	if(ret == 0)
    {
        self.offlineMsgCurCount = 0;
        self.offlineMsgTotal = 0;
        self.offlineMsgArray = [NSMutableArray array];
        
        self.curRcvOfflineMsgCount = 0;
        
        /** 初始化已读消息数组*/
        msgConn.msgReadArray = [NSMutableArray array];
        /** 初始化离线回执消息数组*/
        [msgConn initOfflineRecallMsgArray];
        
        self.noProcessMsgReadNotice = [NSMutableArray array];
        
        self.isOfflineMsgFinish = false;
        self.isGetOfflineMsgNumCmd = true;
 		[self startTimeoutTimer:5];
 		return true;
    }
	return false;
}



#pragma mark----注销-----
/** 注销但是不退出*/
-(bool)logout
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	if( _conncb )
    {
		CLIENT_Logout(_conncb, 3, 0);
		self.connStatus = not_connect_type;
        self.userStatus = status_offline;
        [self.msgThread cancel];
        self.msgThread = nil;
        
    }
    
#ifdef _GOME_FLAG_
    [[GOMEEmailUtilArc getEmailUtil]stopEmailTimer];
#endif

    
    return true;
}

/** 注销，可以退出到登录界面，也可以不退出*/
-(bool)logout:(int)type
{
	[LogUtil debug:[NSString stringWithFormat:@"%s,type is %d",__FUNCTION__,type]];
    int result = 0;
	if( _conncb )
    {
        CLIENT_Logout(_conncb, 3, type);
    }
    self.connStatus = not_connect_type;
    self.userStatus = status_offline;
    
    [self.msgThread cancel];
    self.msgThread = nil;

    if (type == 1) {
        [UserDefaults saveUserIsExit:YES];
        [UserDefaults saveExistStatus:YES];
    }
    
#ifdef _GOME_FLAG_
    [[GOMEEmailUtilArc getEmailUtil]stopEmailTimer];
#endif

    return true;
}

#pragma mark----用户状态改变 离线0 在线1 离开2-----
/** deprecated*/
-(bool)changeUserStatus:(int)status
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    //
    //	int nret = CLIENT_Logout(_conncb,status);
    //	if(nret == 0)
    //		return true;
	return false;
}
//deprecated
-(int)getOnLineState
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    int nReturn=0;
    if (_conncb == NULL )
        nReturn = -1;
    
    if (!_conncb->fConnect && !_conncb->fKick)
    {
        nReturn = -2;
    }
    return nReturn;
}

/** 处理接收的消息 */
-(void)getMessage
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
	MESSAGE _msg;
	
	int nRet;
	int lastRet;
	
	while(self.msgThread  && ![self.msgThread isCancelled])
	{
        //		if()
        //		{
        /** 默认传一个0值，nRet值得含义 -1是未初始化链接 -2是链接被断开 -3是被踢 0是没有消息 1是有消息 */
		nRet = CLIENT_GetMessage(_conncb, &_msg);
		if(nRet < 0 && nRet != lastRet)
		{
            /** 和上次相同就不打印日志 */
			[LogUtil debug:[NSString stringWithFormat:@"%s,nRet is %d",__FUNCTION__,nRet]];
		}
		lastRet = nRet;
        
        if(nRet < 0)
        {
            if(self.userStatus == status_offline)
            {
                [NSThread sleepForTimeInterval:1];
                continue;
            }
            
            self.isKick = NO;
            self.isDisable = NO;
            
            /** 根据不用的错误代码，进行不同的处理 */
            switch(nRet)
            {
                case EIMERR_INVALID_PARAMTER:
                    [LogUtil debug:[NSString stringWithFormat:@"-1，链接未初始化，显示手动链接按钮"]];
                    [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];

                    break;
                case EIMERR_NOT_CONN:
                    [LogUtil debug:[NSString stringWithFormat:@"-2，链接断开，显示手动链接按钮"]];
                    [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
                    break;
                case EIMERR_KICK:
                    [LogUtil debug:[NSString stringWithFormat:@"-3，提示用户被离线"]];
                    self.isKick = YES;
                    [[NotificationUtil getUtil]sendNotificationWithName:USER_NOTICE_OFFLINE andObject:nil andUserInfo:nil];
                    break;
                case EIMERR_FORBIDDEN:
                    [LogUtil debug:[NSString stringWithFormat:@"-4，提示用户被禁用"]];
                    self.isDisable = YES;
                    [[NotificationUtil getUtil]sendNotificationWithName:USER_DISABLE_NOTIFICATION andObject:nil andUserInfo:nil];
                    break;
                default:
                    [LogUtil debug:[NSString stringWithFormat:@"其它错误nRet is %d,显示手动链接按钮",nRet]];
                    [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
            }
            
            /** 修改为离线状态 */
            self.userStatus = status_offline;
            [db updateUserStatus:self.userId andStatus:status_offline];
            self.connStatus = not_connect_type;

            continue;
        }
        else
        {
            if (nRet == EIMERR_EMPTY_MSG)
            {
                /** 没有消息 */
                //		[LogUtil debug:[NSString stringWithFormat:@"没有消息"]];
                [NSThread sleepForTimeInterval:sec_interval];
            }
            else
            {
                /** 处理消息 */
                int cmdId = _msg.wCmdID;
                
                NSLog(@"getmessage,%d",cmdId);

                switch(cmdId)
                {
                    case CMD_DEPTSHOWCONFIG_ACK:
                    {
                        [LogUtil debug:@"收到了部门显示配置应答"];
                        
                        if (self.isSyncDeptShowTimeout){
                            [LogUtil debug:[NSString stringWithFormat:@"获取部门显示配置超时，已经开始获取员工与部门关系了，因此不再处理此应答"]];
                            return;
                        }
                        
                        GETDEPTSHOWCONFIGACK *info = (GETDEPTSHOWCONFIGACK *)(_msg.aszData);
                        [[OrgConn getConn]processDeptShowConfig:info];
                    }
                        break;
                        
                    case CMD_FAVORITE_NOTICE:
                    {
                        FAVORITE_NOTICE *info = (FAVORITE_NOTICE *)(_msg.aszData);
                        NSLog(@"收到了收藏");
                        [[CollectionConn getConn] collectNotice:info];
                    }
                        break;
                    case CMD_FAVORITE_SYNC_ACK:
                    {
                        FAVORITE_SYNC_ACK *info = (FAVORITE_SYNC_ACK *)(_msg.aszData);
                        [LogUtil debug:[NSString stringWithFormat:@"收到了收藏的同步应答 %d",info->wTotalNum]];
                        [[CollectionConn getConn] processCollectionSyncAck:info];
                    }
                        break;
                    case CMD_FAVORITE_MODIFY_ACK:
                    {
                        NSLog(@"收到了添加或删除收藏的应答");
                        FAVORITE_MODIFY_ACK *info = (FAVORITE_MODIFY_ACK *)(_msg.aszData);
                        [[CollectionConn getConn] ModiRequestAck:info];
                    }
                        break;
                    case CMD_ROBOTSYNCRSP:
                    {
                        [LogUtil debug:@"收到了机器人资料同步应答"];
                        ROBOTSYNCRSP *info = (ROBOTSYNCRSP *)(_msg.aszData);
                        [[RobotConn getConn]processSyncRobotAck:info];
                    }
                        break;
                    case CMD_GETDATALISTTYPEACK://deprecated
                    {
//                        [LogUtil debug:@"收到了组织架构同步类型应答"];
                        GETDATALISTTYPEACK *info = (GETDATALISTTYPEACK *)(_msg.aszData);
                        [[OrgConn getConn]processGetOrgSyncTypeAck:info];
                        
                    }
                        break;
                        
                     /** 增加已读消息 */
                    case CMD_READMSGSYNCNOTICE:
                    {
                        [LogUtil debug:@"收到了消息已读通知"];
                        MSG_READ_SYNC *info = (MSG_READ_SYNC *)(_msg.aszData);
                        [[MsgConn getConn]processMsgReadNotify:info];
                    }
                        break;
                        
                        /** 头像变化的用户列表 */
                    case CMD_GET_HEAD_ICON_ADD_LIST_RSP:
                    {
                        TGetUserHeadIconListAck *info = (TGetUserHeadIconListAck *)(_msg.aszData);
                        [empLogoConn processEmpLogoSyncAck:info];
                    }
                        break;
                        /** logout应答 */
                    case CMD_LOGOUTACK:
                    {
                        NSLog(@"%s,logout",__FUNCTION__);
                        [self.msgThread cancel];
                        self.msgThread = nil;
                    }
                        break;
                        /** 漫游数据同步应答 (常用联系人、常用部门等) */
                    case CMD_ROAMINGDATASYNACK:
                    {
//                        NSLog(@"收到个人数据同步应答");
                        ROAMDATASYNCACK *info = (ROAMDATASYNCACK *)(_msg.aszData);
                        [_userDataConn processUserDataSyncAck:info];
                        
                    }
                        break;
                        /** 漫游数据修改应答 */
                    case CMD_ROAMINGDATAMODIACK:
                    {
//                        NSLog(@"收到修改个人漫游数据的应答");
                        ROAMDATAMODIACK *info = (ROAMDATAMODIACK *)(_msg.aszData);
                        [_userDataConn processUserDataModiAck:info];
                    }
                        break;
                        /** 漫游数据修改通知 */
                    case CMD_ROAMINGDATAMODINOTICE:
                    {
                        ROAMDATAMODINOTICE *info = (ROAMDATAMODINOTICE *)(_msg.aszData);
                        [_userDataConn processUserDataModiNotice:info];
                    }
                        break;
                    
                        /** 固定群组同步应答 */
                    case CMD_REGULAR_GROUP_UPDATE_RSP:
                    {
                        REGULAR_GROUP_UPDATE_RSP *info = (REGULAR_GROUP_UPDATE_RSP *)(_msg.aszData);
                        
                        self.systemGroupSyncCount = info->wGroupNum;
                        [LogUtil debug:[NSString stringWithFormat:@"固定群组应答总数%d",self.systemGroupSyncCount]];

                        if (info->wGroupNum == 0)
                        {
                            /** 先同步机器人数据，再获取离线消息 */
                            [[RobotConn getConn]syncRobotInfo];
//                            [self getOfflineMsgNum];
                        }
                        else
                        {
                            [self checkAndFinishSystemGroupSync];
//                            self.systemGroupSyncCount = info->wGroupNum;
//                            [LogUtil debug:[NSString stringWithFormat:@"固定群组应答总数%d",self.systemGroupSyncCount]];
                        }
//                        NSLog(@"收到请求应答%i",info->result);
//                        NSLog(@"收到请求应答%i",info->wGroupNum);
                    }
                        break;
//                        现在群组创建都走 分包的协议
//                    case CMD_CREATEREGULARGROUPNOTICE :
//                    {   //创建固定组通知
//                        [LogUtil debug:[NSString stringWithFormat:@"固定群组创建通知 %d",self.systemGroupCurCount]];
//                        CREATEREGULARGROUPNOTICE *info = (CREATEREGULARGROUPNOTICE *)(_msg.aszData);
//                        [_userDataConn processSystemGroupCreateNotice:info];
//                        
//                        [self checkAndFinishSystemGroupSync];
//                    }
//                        break;
                    case CMD_DELETEREGULARGROUPNOTICE :
                        /** 删除固定组通知 */
                    {
                        DELETEREGULARGROUPNOTICE *info = (DELETEREGULARGROUPNOTICE *)(_msg.aszData);
                        [_userDataConn processSystemGroupDeleteNotice:info];
                        
                        if (self.needCountSystemGroup) {
                            self.systemGroupCurCount++;
                            [LogUtil debug:[NSString stringWithFormat:@"收到了删除固定群组的通知，固定群组总包数为%d,已经同步的包数%d",self.systemGroupSyncCount,self.systemGroupCurCount]];
                            [self checkAndFinishSystemGroupSync];
                        }else{
                            [LogUtil debug:@"收到了删除固定群组的通知，不过不是同步到的，应该是在管理台操作后，发给客户端的"];
                        }
                    }
                        break;
                        
                        /** 增加 固定群组创建通知2 的处理 by shisp */
                    case CMD_GULARGROUP_PROTOCOL2_CREATENOTICE:
                    {
                        /** 创建固定群组通知 在人数比较多的情况下会分包发送 */
                        CREATEREGULARGROUPPROTOCOL2NOTICE *info = (CREATEREGULARGROUPPROTOCOL2NOTICE *)(_msg.aszData);
                        NSString *groupId = [StringUtil getStringByCString:info->aszGroupID];
                        
                        NSString *groupName = [StringUtil getStringByCString:info->aszGroupName];

                        /** 当前包含成员的个数 */
                        int memberNum = info->wCurrentNum;
                        int totalMemberCount = info->wTotalNum;

                        /** 当前包含的成员 */
                        NSMutableArray *memberArray = [NSMutableArray arrayWithCapacity:memberNum];
                        
                        for (int i = 0; i < memberNum; i++) {
                            regulargroup_member member = info->aUserList[i];
                            
                            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
                            [mDic setValue:[NSNumber numberWithInt:member.dwUserID] forKey:@"emp_id"];
                           
                            [mDic setValue:groupId forKey:@"conv_id"];
                            [mDic setValue:[NSNumber numberWithInt:member.cAttribute & 1] forKey:@"is_admin"];
                            [memberArray addObject:mDic];
                        }
                        if (!self.bigSystemGroupDic) {
                            [LogUtil debug:@"初始化处理固定群组用到的字典字典"];
                            self.bigSystemGroupDic = [NSMutableDictionary dictionary];
                        }
                        NSArray *receivedMemberArray = [self.bigSystemGroupDic valueForKey:groupId];
                        if (receivedMemberArray.count > 0)
                        {
                        /** 把本次收到的成员加到已收到的成员数组里*/
                            [memberArray addObjectsFromArray:receivedMemberArray];
                        }
                        /** 保存已收到的成员*/
                        [self.bigSystemGroupDic setObject:memberArray forKey:groupId];
                        
                        [LogUtil debug:[NSString stringWithFormat:@"收到固定群组 %@ 创建的报文,成员总个数%d,目前已收到的成员个数%d",groupName,totalMemberCount,memberArray.count]];
                        
                        if (totalMemberCount == memberArray.count) {
                            /** 首先保存此大固定群组 */
                            [_userDataConn processBigSystemGroupCreateNotice:info];
                            
                            if (needCountSystemGroup) {
                                self.systemGroupCurCount++;
                                
                                [LogUtil debug:[NSString stringWithFormat:@"%s 固定群组同步，需要同步的总包数为%d 已经同步的包数为%d",__FUNCTION__,self.systemGroupSyncCount,self.systemGroupCurCount]];
                                /** 已经收全 */
                                [self checkAndFinishSystemGroupSync];
                            }else{
                                [LogUtil debug:@"管理台修改或者创建了固定群组，服务器通知给客户端进行处理"];
                            }
                        }

                    }
                        break;
                        
//                        暂时不处理
//                    case CMD_GULARGROUPMEMBERCHANGENOTICE :
//                    {   // 固定组成员变化通知
//                        GULARGROUPMEMBERCHANGENOTICE *info = (GULARGROUPMEMBERCHANGENOTICE *)(_msg.aszData);
//                        [_userDataConn processSystemGroupMemberChangeNotice:info];
//                    }
//                        break;
//                    case CMD_GULARGROUPNAMECHANGENOTICE :
//                    {   // 固定组名称变化通知
//                        GULARGROUPNAMECHANGENOTICE *info = (GULARGROUPNAMECHANGENOTICE *)(_msg.aszData);
//                        [_userDataConn processSystemGroupNameChangeNotice:info];
//                    }
//                        break;
                    case CMD_GETSPECIALLISTACK://deprecated
                    {
                        GETSPECIALLISTACK *info = (GETSPECIALLISTACK *)(_msg.aszData);
                        [[BlackListConn getConn]saveBlacklist:info];
                    }
                        break;
                    case CMD_MODISPECIALLISTNOTICE: //deprecated
                    {
                        MODISPECIALLISTNOTICE *info = (MODISPECIALLISTNOTICE*)(_msg.aszData);
                        [[BlackListConn getConn]saveBlacklistNotice:info];
                    }
                        break;
                        /** 南航群发功能 */
                    case CMD_SENDBROADCASTACK:
                    {
                        SENDBROADCASTACK *info = (SENDBROADCASTACK*)(_msg.aszData);
                        if(info->result == RESULT_SUCCESS)
                        {
                            [LogUtil debug:[NSString stringWithFormat:@"收到一呼万应消息发送应答,%lld ",info->dwMsgID]];
                            NSString *originMsgId = [NSString stringWithFormat:@"%lld",info->dwMsgID];
                            MassDAO *massDAO = [MassDAO getDatabase];
                            NSString *msgId = [massDAO getMsgIdByOriginMsgId:originMsgId];
                            if(msgId)
                            {
                                NSDictionary *dic =[NSDictionary dictionaryWithObject:msgId forKey:@"mass_msg_id"];
                                [massDAO updateSendFlagByMsgId:msgId andSendFlag:send_success];
                                
                                eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                                _notificationObject.cmdId = send_msg_success;
                                _notificationObject.info = dic;
                                
                                [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
                            }
                        }
                    }
                        break;
                    case CMD_MSGREADACK:
                    {
                        /** 回执消息已读发送应答 */
                        [LogUtil debug:@"收到了已读通知发送结果"];
                        MSGREADACK *info = (MSGREADACK*)(_msg.aszData);
                        if(info->result == RESULT_SUCCESS)
                        {
                            int rcvEmpId = info->dwRecverID;
                            NSString *originMsgId = [NSString stringWithFormat:@"%lld",info->dwMsgID];
                            
                            NSArray *msgIdArray = [db getMsgIdArrayByOriginMsgId:originMsgId andSenderId:rcvEmpId];
                            
                            if(msgIdArray.count > 0)
                            {
                                [[ReceiptDAO getDataBase]updateMsgReadNoticeFlag:msgIdArray];
                                
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[msgIdArray objectAtIndex:0],@"MSG_ID",originMsgId,@"origin_msg_id", nil];

                                eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                                _notificationObject.cmdId = receipt_msg_send_read_success;
                                _notificationObject.info = dic;
                                
                                [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

                            }
                            
                        }
                    }
                        break;
                        /** 南航专用 用户级别 */
                    case CMD_GETUSERRANK_ACK:
                    {
                        [LogUtil debug:@"收到了用户级别同步应答"];
                        GETUSERPAASK *_info = (GETUSERPAASK*)(_msg.aszData);
                        [self processGetUserRank:_info];
                    }
                        break;
                        /** 南航专用 用户业务 */
                    case CMD_GETUSERPROFE_ACK:
                    {
                        [LogUtil debug:@"收到了用户业务同步应答"];
                        GETUSERPAASK *_info = (GETUSERPAASK*)(_msg.aszData);
                        [self processGetUserProf:_info];
                    }
                        break;
                        /** 南航专用 用户地域 */
                    case CMD_GETUSERAREA_ACK:
                    {
                        [LogUtil debug:@"收到了用户地域同步应答"];
                        GETUSERPAASK *_info = (GETUSERPAASK*)(_msg.aszData);
                        [self processGetUserArea:_info];
                    }
                        break;
                        /** 发送未读消息数数量到服务器应答 */
                    case CMD_IOSBACKGROUND_ACK:
                    {
                        IOSBACKGROUNDACK *info = (IOSBACKGROUNDACK *)_msg.aszData;
                        int result = info->cResult;
                        [LogUtil debug:[NSString stringWithFormat:@"收到设置未读消息数应答,%d",result]];
                    }
                        break;
                        /** 设置屏蔽群组消息应答 */
                    case CMD_GROUPPUSHFLAGACK:
                    {
                        GROUPPUSHFLAGACK *info = (GROUPPUSHFLAGACK *)_msg.aszData;
                        NSString *convId = [StringUtil getStringByCString:info->aszGroup];
                        int result = info->result;
                        /** 发通知出去 */
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[StringUtil getStringValue:result],@"result_code", nil];
                        [[NotificationUtil getUtil]sendNotificationWithName:SET_CONV_RCV_MSG_FLAG_NOTIFICATION andObject:nil andUserInfo:dic];
                    }
                        break;
              
                        /** checkTime应答 */
                    case CMD_CHECK_TIME_RESP:
                    {
                        CHECK_TIME_RESP *info = (CHECK_TIME_RESP *)_msg.aszData;
                        int retSerial = info->dwSerial;
                        [LogUtil debug:[NSString stringWithFormat:@"收到checktime应答,%d",retSerial]];
                        if(retSerial == checkTimeSerial)
                        {
//                            [LogUtil debug:@"线程检测网络"];
                            [self stopCheckTimeTimer];
                        }
                        else if(retSerial == activeCheckTimeSerial)
                        {
                            self.connStatus = normal_type;
                            self.userStatus = status_online;
                            
//                            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
//                            _notificationObject.cmdId = end_check_network;
//                            
//                            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
                            
                            [LogUtil debug:@"由后台进入前台，通过checkTime检测网络"];
                            [self getUserStateList:YES];
                            [[ApplicationManager getManager] stopConnCheckTimer];
                        }
                    }
                        break;
                        
                        /** 增加公众平台的信息的接收 公众号 公众号菜单 */
                    case CMD_ECWX_SYNC_RSP:
                    {
                        NSString *psStr = [StringUtil getStringByCString:_msg.aszData];
                        
                        if ([psStr rangeOfString:@"<sync>"].length > 0) {
                            if(psSynCount == -1) {
                                NSRange totalStartRange = [psStr rangeOfString:@"<total>"];
                                NSRange totalEndRange = [psStr rangeOfString:@"</total>"];
                                totalStartRange.location = totalStartRange.location+totalStartRange.length;
                                totalStartRange.length = totalEndRange.location - totalStartRange.location;
                                NSLog(@"totalStartRange:%@,totalEndRange:%@",NSStringFromRange(totalStartRange),NSStringFromRange(totalEndRange));
                                NSString *totalCount = [psStr substringWithRange:totalStartRange];
                                [LogUtil debug:[NSString stringWithFormat:@"%s CMD_ECWX_SYNC_RSP同步下来的公众号的个数为:%@",__FUNCTION__,totalCount]];
                            
                                /** 得到公众号同步的个数 */
                                psSynCount = [totalCount intValue];
                                psSynCurrCount = 1;
                            }
                            
                            [LogUtil debug:[NSString stringWithFormat:@"%s CMD_ECWX_SYNC_RSP同步下来的公众号字典内容:%@",__FUNCTION__,psStr]];
                            
                            /** 进行公众号菜单的同步，有如下两种情况 */
                            /** 1.公众号无变化 */
                    
                            if (psSynCount == 0) {
                            
                                /** 同步公众号菜单 */
                                [self syncpsMenuListSyncRequest];
                                break;
                            }
  
                            /** 同步公众号 */
                            [self addTaskToQueue:@selector(savePS:) andObject:psStr];
                            /** 2.公众号同步完成后 */
                            if (psSynCurrCount == psSynCount) {
                                /** 同步公众号菜单 */
                                [self syncpsMenuListSyncRequest];
                            }
                            psSynCurrCount++;
                        }else if ([psStr rangeOfString:@"Menus"].length > 0){
                            
                            /** 同步菜单 */
                            NSData* jsonData = [psStr dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *dic = (NSDictionary *)[jsonData objectFromJSONData];
//                            [LogUtil debug:[NSString stringWithFormat:@"%s 菜单内容：%@ ",__FUNCTION__,dic]];
                            
                            if (dic) {
                                NSMutableArray *temMenus = [NSMutableArray arrayWithArray:[dic objectForKey:@"Menus"]];
                                
                                if ([temMenus count]) {
                                    [LogUtil debug:[NSString stringWithFormat:@"%s CMD_ECWX_SYNC_RSP同步下来的公众号菜单字典内容:%@",__FUNCTION__,dic]];
                                   
                                    /** 菜单同步消息 */
                                    [self addTaskToQueue:@selector(savePSMenuList:) andObject:psStr];
                                }
                            }
                        }else if ([psStr rangeOfString:@"MsgType"].length > 0)
                        {
                            [LogUtil debug:[NSString stringWithFormat:@"%s CMD_ECWX_SYNC_RSP被单击公众号菜单内容:%@",__FUNCTION__,psStr]];
                            
                            /** 菜单点击子菜单，服务器返回的响应消息处理 */
                            [self savePSMsg:psStr];
                        }
                    }
                        break;
                        /** 收到公众号推送消息 */
                    case CMD_ECWX_PACC_NOT:
                    {
                    
                        /** 收到服务号推送消息后，先parse把msgId和jsondata取出，msgid用来回应答，jsondata用来保存到数据库，暂时不升级 */
                        //								unsigned long long msgId;
                        //								char jsonData[800];
                        //								memset(jsonData, 0, sizeof(jsonData));
                        //								CLIENT_ParseMsgId(_msg.aszData, &msgId,jsonData);
                        //								CLIENT_SendMsgNoticeAck(_conncb, msgId);
                        
                        ECWX_PUSH_NOTICE *psPushNotice = (ECWX_PUSH_NOTICE *)_msg.aszData;
                        
                        MsgNotice *msgNotice = [PSConn getMsgNoticeObject:psPushNotice];
                        [self addTaskToQueue:@selector(processPSMSg:) andObject:msgNotice];

                    }
                        break;
                    case CMD_ECWX_SMSG_RSP:
                    {
//                        目前没有用到
                    }
                        break;
                        
                        /** 登录 */
                    case CMD_LOGINACK:
                    {
                        int nowTime = [[NSDate date]timeIntervalSince1970];
                        [LogUtil debug:[NSString stringWithFormat:@"连接成功，收到登录应答，时间：%d",nowTime - connStartTime]];
                        connStartTime = nowTime;
                        
                        [LogUtil debug:[NSString stringWithFormat:@"登录返回"]];
                        LOGINACK *_loginAck = (LOGINACK *)_msg.aszData;
                        [self processLogin:_loginAck];
                    }
                        break;
                
                        /** 心跳ACK */
                    case CMD_ALIVEACK:
                    {
                    }
                        break;
                        
                        /** 获取公司资料 */
                    case CMD_GETCOMPINFOACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"取公司资料返回"]];
                        
                        GETCOMPINFOACK *_getCompInfoAck = (GETCOMPINFOACK *)(_msg.aszData);
                        [self processGetCompInfo:_getCompInfoAck];
                    }
                        break;
            
                        /** 获取部门资料 */
                    case CMD_GETDEPTLISTACK:
                    {
//                        [LogUtil debug:[NSString stringWithFormat:@"取部门资料返回"]];
                        
                        GETDEPTLISTACK *_getDeptListAck = (GETDEPTLISTACK*)(_msg.aszData);
                        [self processGetDeptList:_getDeptListAck];
                    }
                        break;
                        
                        /** <#Class#>获取员工信息 */
                    case CMD_GETUSERLISTACK:
                    {
//                        [LogUtil debug:[NSString stringWithFormat:@"取员工信息返回"]];
                        
                        GETUSERLISTACK *_getUserListAck = (GETUSERLISTACK*)(_msg.aszData);
                        [self processGetUserList:_getUserListAck];
                    }
                        break;
                        
                        /** 获取员工，部门对应信息 */
                    case CMD_GETUSERDEPTACK:
                    {
//                        [LogUtil debug:[NSString stringWithFormat:@"取员工部门返回"]];
                        
                        GETUSERDEPTACK *_getUserDeptAck = (GETUSERDEPTACK*)(_msg.aszData);
                        [self processGetUserDept:_getUserDeptAck];
                    }
                        break;
                        
                        /** 修改用户资料应答 */
                    case CMD_MODIINFOACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"修改用户资料返回"]];
                        
                        MODIINFOACK *info = (MODIINFOACK *)(_msg.aszData);
                        [self processModifyUserInfo:info];
                    }
                        break;
                        
                        /** 获取组信息应答 */
                    case CMD_GETGROUPACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"获取分组信息返回"]];
                        
                        GETGROUPINFOACK *info = (GETGROUPINFOACK *)(_msg.aszData);
                        [self processGetGroupInfo:info];
                    }
                        break;
                        
                        /** 修改组成员应答 */
                    case CMD_MODIMEMBERACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"添加分组成员返回"]];
                        
                        MODIMEMBERACK *info = (MODIMEMBERACK*)(_msg.aszData);
                        [self processModifyGroupMember:info];
                    }
                        break;
                        
                        /** 修改组名称应答 */
                    case CMD_MODIGROUPACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"修改分组名称返回"]];
                        
                        MODIGROUPACK *info = (MODIGROUPACK*)(_msg.aszData);
                        [self processModifyGroup:info];
                    }
                        break;
                        
                        /** 返回所有用户状态 */
                    case CMD_GETUSERSTATEACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"返回所有用户状态返回"]];
                        
                        GETUSERSTATELISTACK *info = (GETUSERSTATELISTACK*)(_msg.aszData);
                        [self processGetUserStateList:info];
                    }
                        break;
                        
                        /** 用户状态变化通知 */
                    case CMD_NOTICESTATE:
                    {
//                       	[LogUtil debug:[NSString stringWithFormat:@"用户状态变化通知"]];
                        
                        TUserStatusList *info = (TUserStatusList *)(_msg.aszData);
                        [self saveEmpStatusOfWanda:info];

                        /** 万达之前的处理 */
                        //                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                        //							USERSTATUSNOTICE *info = (USERSTATUSNOTICE*)(_msg.aszData);
//                        USERSTATUSSETNOTICE *info = (USERSTATUSSETNOTICE*)(_msg.aszData);
//                        [self processUserStatusNotice:info];
//                        [pool release];
                    }
                        break;
                   
                        /** 广播通知 应用的消息发给客户端是也是通过广播协议 */
                    case CMD_BROADCASTNOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"广播通知"]];
                        BROADCASTNOTICE *info=(BROADCASTNOTICE *)(_msg.aszData);
                        [self processBroadcastNotice:info];
                    }
                        break;
                      
                        /** 发送消息应答 */
                    case CMD_SENDMSGACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"发送消息返回"]];
                        
                        SENDMSGACK *_sendMsgAck = (SENDMSGACK*)(_msg.aszData);
                        /** 先判断是否是撤回消息 */
                        BOOL isRecallMsg = [[MsgConn getConn]processMsgCancelAck:_sendMsgAck];
                        if (!isRecallMsg) {
                            [self processSendMsgAck:_sendMsgAck];
                        }
                    }
                        break;
                      
                        /** 收到消息通知 */
                    case CMD_MSGNOTICE:
                    {
                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                        MSGNOTICE *_msgNotice = (MSGNOTICE*)(_msg.aszData);
                        [LogUtil debug:[NSString stringWithFormat:@"收到消息通知,%llu",(unsigned long long)_msgNotice->dwMsgID]];
                        
//                        CLIENT_SendMsgNoticeAck(_conncb, _msgNotice->dwMsgID);
//                        CLIENT_SendMsgNoticeAck(_conncb, _msgNotice->dwMsgID,_msgNotice->dwNetID);
                        
                        MsgNotice *_msg = [self getMsgNoticeObject:_msgNotice];
                        
                        if(_msg)
                        {
                            if (_msg.isOffline == 1) {
                                self.curRcvOfflineMsgCount++;
                            }
                            [self addTaskToQueue:@selector(processRcvMsg:) andObject:_msg];
                        }
                        
                        [pool release];
                        
                        _msgNotice=nil;
                        //	/*更新未读*/
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"showNoReadNum" object:nil];
                        //                        notificationName = @"showNoReadNum";
                        //                        [self notifyMessage:nil];
                        
                    }
                        break;
                    
                        /** 创建分组应答 */
                    case CMD_CREATEGROUPACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"创建分组返回"]];
                        
                        CREATEGROUPACK *_createGrpAck = (CREATEGROUPACK*)(_msg.aszData);
                        [self processCreateGroup:_createGrpAck];
                    }
                        break;
                      
                        /** 创建分组通知 */
                    case CMD_CREATEGROUPNOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"创建分组通知"]];
                        
                        CREATEGROUPNOTICE *info = (CREATEGROUPNOTICE*)(_msg.aszData);
                        [self processCreateGroupNotice:info];
                    }
                        break;
                       
                        /** 分组成员变化通知 */
                    case CMD_MODIMEMBERNOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"分组成员变化通知"]];
                        
                        MODIMEMBERNOTICE *info = (MODIMEMBERNOTICE*)(_msg.aszData);
                        [self processModifyGroupMemberNotice:info];
                    }
                        break;
                       
                        /** 分组信息修改通知 */
                    case CMD_MODIGROUPNOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"分组名称修改通知"]];
                        
                        MODIGROUPNOTICE *info = (MODIGROUPNOTICE*)(_msg.aszData);
                        [self processModifyGroupNotice:info];
                    }
                        break;
                        
                        /** 获取员工信息应答 */
                    case CMD_GETEMPLOYEEINFOACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"获取员工资料返回"]];
                        GETEMPLOYEEACK *info = (GETEMPLOYEEACK*)(_msg.aszData);
                        [self processGetUserInfo:info];
                    }
                        break;
                     
                        /** 获取虚拟组下发信息 by yanlei */
                    case CMD_VIRTUAL_GROUP_ACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"获取虚拟组应答"]];
                        VIRTUAL_GROUP_INFO_ACK *info = (VIRTUAL_GROUP_INFO_ACK*)(_msg.aszData);
//                        [self processVirtualGroupInfo:info];
                        [[VirtualGroupConn getVirtualGroupConn]processVirtualGroupInfoAck:info];
                    }
                        break;
                     
                        /** 获取虚拟组下发通知信息 by yanlei */
                    case CMD_VIRTUAL_GROUP_NOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"获取虚拟组下发通知"]];
                        VIRTUAL_GROUP_INFO_NOTICE *info = (VIRTUAL_GROUP_INFO_NOTICE*)(_msg.aszData);
//                        [self processVirtualGroupInfo:info];
                        [[VirtualGroupConn getVirtualGroupConn]processVirtualGroupInfoNotice:info];
                    }
                        break;
                        
                        /** 获取消息已读通知 */
                    case CMD_MSGREADNOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"收到消息已读通知"]];
                        MSGREADNOTICE *info = (MSGREADNOTICE *)(_msg.aszData);
                        [self processMsgReadNotice:info];
                    }
                        break;
//                    case CMD_VIRGROUP_UPDATE_RSP:
//                    {
//                        [LogUtil debug:[NSString stringWithFormat:@"收到获取虚拟组"]];
//                        VIR_GROUP_UPDATE_RSP *info = (VIR_GROUP_UPDATE_RSP *)(_msg.aszData);
//                        [self processVgroup:info];
//                    }
//                        break;
                    case CMD_GET_OFFLINE_RESP:
                    {
                        self.isGetOfflineMsgNumCmd = false;
                        [self stopTimeoutTimer];
                        
                        GET_OFFLINE_RESP *_info = (GET_OFFLINE_RESP*)(_msg.aszData);
                        int offlineMsgCount = _info->dwOfflineMsgCount;
                        [LogUtil debug:[NSString stringWithFormat:@"收到离线消息总数,%d",offlineMsgCount]];
                        
                        connStartTime = [[NSDate date]timeIntervalSince1970];
                        
                        self.offlineMsgTotal = offlineMsgCount;
                        
                        if(offlineMsgCount == 0)
                        {
                            [self sendRcvOfflineMsgFinishNotify];
                        }
                        else
                        {
                            
                            /** 初始化收取离线消息期间收到的消息id */
                            if(self.offLineMsgs && self.offLineMsgs.count > 0)
                            {
                                [self.offLineMsgs removeAllObjects];
                            }
                            else
                            {
                                self.offLineMsgs = [NSMutableArray array];
                            }
                            
                            isOfflineMsgsSend = false;
                            
                            /** 收取离线消息超时处理 */
                            [self performSelectorOnMainThread:@selector(processRcvOfflineMsgTimeout:) withObject:[NSNumber numberWithInt:30] waitUntilDone:YES];
                            
                        }
                        
                    }
                        break;
                        
                    case CMD_QUITGROUPACK:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"收到主动退出群组应答"]];
                        QUITGROUPACK *info = (QUITGROUPACK *)(_msg.aszData);
                        [self processQuitGroup:info];
                    }
                        break;
                    case CMD_RESETSELFINFONOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"收到用户资料修改通知"]];
                        RESETSELFINFONOTICE *info = (RESETSELFINFONOTICE*)(_msg.aszData);
                        [self processModifyUserInfoNotice:info];
                    }
                        break;
                    case CMD_QUITGROUPNOTICE:
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"收到主动退出群组通知"]];
                        QUITGROUPNOTICE *info = (QUITGROUPNOTICE*)(_msg.aszData);
                        [self processQuitGroupNotice:info];
                    }
                        break;
                    case CMD_RESETSELFINFOACK://derecated
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"头像变更后发给最近联系人应答"]];
                    }
                        break;
                    case CMD_CREATESCHDULEACK://deprecated
                    {
                        CREATESCHEDULEACK *info=(CREATESCHEDULEACK*)(_msg.aszData);
                        [LogUtil debug:[NSString stringWithFormat:@"创建日程提醒应答  %d",info->result]];
                        
                    }
                        break;
                    case CMD_CREATESCHDULENOTICE://deprecated
                    {
                        CREATESCHEDULENOTICE *info=(CREATESCHEDULENOTICE*)(_msg.aszData);
                        [LogUtil debug:[NSString stringWithFormat:@"日程提醒应答  aszScheduleID- %s  aszScheduleName- %s  aszScheduleDetail-- %s",info->aszScheduleID,info->aszScheduleName,info->aszScheduleDetail]];
                        [[ScheduleConn getScheduleConn] processGetHelperSchedule:info];
                        notificationName = @"HELPER_MESSAGE_NOTIFICATION";
//                        [self notifyMessage:nil];
                    }
                        break;
                    case CMD_DELETESCHDULEACK://deprecated
                    {
                        DELETESCHEDULEACK *info=(DELETESCHEDULEACK*)(_msg.aszData);
                        [LogUtil debug:[NSString stringWithFormat:@"删除日程应答  %d",info->result]];
                    }
                        break;
                    case CMD_DELETESCHDULENOTICE://deprecated
                    {
                        DELETESCHEDULE *info=(DELETESCHEDULE*)(_msg.aszData);
                        [LogUtil debug:[NSString stringWithFormat:@"删除日程发起人  %d",info->dwUserID]];
                        [[ScheduleConn getScheduleConn] processDeleteHelperSchedule:info];
                    }
                        break;
                        /** deprecated 目前同步应用走http协议 */
                    case CMD_APP_SYNC_ACK:
                    {
                        
                        /** 开放平台下行至客户端的同步应答 */
                        NSString *appListStr = [StringUtil getStringByCString:_msg.aszData];
                        [LogUtil debug:[NSString stringWithFormat:@"收到开放平台下发同步应用 %@",appListStr]];
                        [self addTaskToQueue:@selector(saveAppList:) andObject:appListStr];
                        
                    }
                        break;
                        /** deprecated 目前token都是通过登录应答给到客户端 */
                    case CMD_APP_TOKEN_NOTICE:
                    {
                        
                        /** 开放平台的token通知 */
                        NSString *appTokenStr = [StringUtil getStringByCString:_msg.aszData];
                        [LogUtil debug:[NSString stringWithFormat:@"收到开放平台的token通知 %@",appTokenStr]];
                        [APPConn saveAppToken:appTokenStr];
                    }
                        break;
                        /** deprecated 平台通知通过广播协议或者消息协议给到客户端 */
                    case CMD_APP_PUSH_NOTICE:
                    {
                        
                        /** 开放平台推送通知 */
                        NSString *appMsgStr = [StringUtil getStringByCString:_msg.aszData];
                        [LogUtil debug:[NSString stringWithFormat:@"收到开放平台推送通知 %@",appMsgStr]];
                        
                        NewMsgNotice *_notice = [APPConn saveAPPMsg:appMsgStr];
                        if(_notice)
                        {
                            notificationName = CONVERSATION_NOTIFICATION;
                            notificationObject.cmdId = rev_msg;
                            settingRemindController *remindController = [settingRemindController initSettingRemind];
                            remindController.soundFlag = 1;
                            [remindController checkRemindType];
//                            [self notifyMessage:_notice];
                        }
                    }
                        break;
                }
            }
        }
		
        //		[NSThread sleepForTimeInterval:sec_interval];
        
        
        // 		}
	}
	[LogUtil debug:[NSString stringWithFormat:@"退出收消息线程"]];
    self.msgThread = nil;
}

#pragma mark ---处理登录消息---

-(void)processLogin:(LOGINACK *)loginAck
{
    /** 首先设置离线消息还没有处理完毕 */
    self.isOfflineMsgFinish = false;

    [loginConn processLoginAck:loginAck];
}

#pragma mark ============获取组织架构信息============
/** 根据userId，查询用户表，如果没有查到，那么慢同步组织结构数据，否则取出保存的更新时间信息，快同步组织结构信息 */
-(void)getOrgInfo
{
	NSDictionary *dic = [userDb searchUserByUserid:self.userId];
	if(dic == nil)
	{
		[LogUtil debug:[NSString stringWithFormat:@"没有查到用户信息"]];
		return;
	}
	
	NSString * oldCompUpdateTime = [dic objectForKey:comp_updatetime];

    /** 取公司信息 */
	if(oldCompUpdateTime == nil || [oldCompUpdateTime length] == 0 || ([oldCompUpdateTime compare:self.compUpdateTime] == NSOrderedAscending))
	{
		[self getCompInfo];
	}
    
	self.oldDeptUpdateTime = [dic objectForKey:dept_updatetime];
	if(self.oldDeptUpdateTime == nil || [self.oldDeptUpdateTime length] == 0)
	{
		self.oldDeptUpdateTime = @"0";
	}
	
	self.oldEmpDeptUpdateTime = [dic objectForKey:emp_dept_updatetime];
	if(self.oldEmpDeptUpdateTime == nil || [self.oldEmpDeptUpdateTime length] == 0)
	{
		self.oldEmpDeptUpdateTime = @"0";
	}
	
	self.oldEmpUpdateTime = [dic objectForKey:emp_updatetime];
	if(self.oldEmpUpdateTime == nil || [self.oldEmpUpdateTime length] == 0)
	{
		self.oldEmpUpdateTime = @"0";
	}
	
//    测试代码
//    self.oldEmpUpdateTime = [StringUtil getStringValue:SERVER_INIT_TIMESTAMP];
    
    if (self.oldEmpUpdateTime.intValue == SERVER_INIT_TIMESTAMP) {
        self.oldEmpUpdateTime = @"0";
        [LogUtil debug:[NSString stringWithFormat:@"%s 员工资料时间戳 本地记得是 服务器初始时间戳，因此强制设置为0",__FUNCTION__]];
    }
    
	self.oldVgroupTime = [dic objectForKey:vgroup_updatetime];
	if(self.oldVgroupTime == nil || [self.oldVgroupTime length] == 0)
	{
		self.oldVgroupTime = @"0";
	}
	
    //	取出旧的同步时间戳
    oldRankUpdateTime =[[dic valueForKey:rank_updatetime]intValue];
    oldProfUpdateTime = [[dic valueForKey:prof_updatetime]intValue];
    oldAreaUpdateTime = [[dic valueForKey:area_updatetime]intValue];
    self.oldBlacklistUpdateTime = [dic valueForKey:@"black_list_updatetime"];
    
    self.oldCommonEmpUpdateTime = [[dic valueForKey:common_emp_updatetime]intValue];
    self.oldDefaultCommonEmpUpdateTime = [[dic valueForKey:default_common_emp_updatetime]intValue];
    self.oldCommonDeptUpdateTime = [[dic valueForKey:common_dept_updatetime]intValue];
    self.oldCurUserInfoUpdateTime = [[dic valueForKey:cur_user_info_updatetime]intValue];
    self.oldCurUserLogoUpdateTime = [[dic valueForKey:cur_user_logo_updatetime]intValue];
    self.oldEmpLogoUpdateTime = [[dic valueForKey:emp_logo_updatetime]intValue];
    
//    测试代码
//    self.oldEmpLogoUpdateTime = SERVER_INIT_TIMESTAMP;
    
    if (self.oldEmpLogoUpdateTime == SERVER_INIT_TIMESTAMP) {
        self.oldEmpLogoUpdateTime = 0;
        [LogUtil debug:[NSString stringWithFormat:@"%s 员工头像的时间戳 本地记得是 服务器初始时间戳，因此强制设置为0",__FUNCTION__]];
    }
    
    self.oldDefaultCommonEmpUpdateTime = [[dic valueForKey:default_common_emp_updatetime]intValue];
    
    self.oldRobotUpdateTime = [[dic valueForKey:robot_updatetime]intValue];
 
    self.oldCollectUpdateTime = [[dic valueForKey:collect_updatetime]intValue];
    
    self.oldDeptShowConfigUpdateTime = [[dic valueForKey:dept_show_config_updatetime]intValue];

}

#pragma mark ---处理公司消息---

-(void)processGetCompInfo:(GETCOMPINFOACK*)getCompInfoAck
{
	int result = getCompInfoAck->result;
	if(result == RESULT_SUCCESS)
	{
		COMPINFO *compInfo = &getCompInfoAck->sCompInfo;
		
		int iCompId = compInfo->dwCompID;
		NSString *sCompId = [StringUtil getStringValue:iCompId];
		
		[[NSUserDefaults standardUserDefaults]setValue:sCompId forKey:@"COMP_ID"];
		
		NSString *compName = [StringUtil getStringByCString:compInfo->aszCompName];
		
		
		//							保存公司信息
		[db addCompany:sCompId andName:compName];
		
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,self.compUpdateTime,comp_updatetime, nil];
		[userDb saveCompUpdateTime:dic];
	}
}


#pragma mark ---处理部门信息---
//bigdata
-(void)processGetDeptList:(GETDEPTLISTACK *)getDeptListAck
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	int result = getDeptListAck->result;
	self.deptPage++;

	if(result == RESULT_SUCCESS)
	{
		int num = getDeptListAck->wCurrNum;
//        [LogUtil debug:[NSString stringWithFormat:@"%s,%d,num is %d",__FUNCTION__,self.deptPage,num]];
		
		NSMutableArray *deleteDepts = [NSMutableArray array];
		
		unsigned int startPos = 0;
		DEPTINFO _deptInfo;
        memset(&_deptInfo, 0, sizeof(_deptInfo));
		
		int iCount = 0;
		int iDeleteCount = 0;
		
        //		解析过程中是否出错
		bool hasError = false;
        //		解析是否完成
		bool finish = false;
		while (!finish)
		{
			int ret = CLIENT_ParseDeptInfo(getDeptListAck->strPacketBuff, &startPos, &_deptInfo);
            
			switch(ret)
			{
				case EIMERR_PARSE_FINISHED:
				{//正常结束
					finish = true;
				}
					break;
				case EIMERR_SUCCESS:
				{//解析数据并且保存
					int updateType = _deptInfo.wUpdate_type;
					
					int deptId = _deptInfo.dwDeptID;
					
					NSString *sDeptId = [StringUtil getStringValue:deptId];
					
					NSString *deptName = [StringUtil getStringByCString:_deptInfo.szCnDeptName];
                    
                    NSString *deptNameEng = [StringUtil getStringByCString:_deptInfo.szEnDeptName];;
					
					NSString *deptTel = [StringUtil getStringByCString:_deptInfo.aszDeptTel];
					
					int deptParent = _deptInfo.dwPID;
					NSString *sDeptParent = [StringUtil getStringValue:deptParent];
					
					int _sort = (unsigned short)_deptInfo.wSort;
                                        NSLog(@"%s,dept_id  is %d,dept name is %@ ,dept sort is %d",__FUNCTION__,deptId,deptName,_sort);
					NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:sDeptId,@"dept_id",deptName,@"dept_name",deptNameEng,@"dept_name_eng",sDeptParent,@"dept_parent",[StringUtil getStringValue:_sort],@"dept_sort",deptTel,@"dept_tel",sDeptId,@"sub_dept",[NSNumber numberWithInt:updateType],@"update_type",nil];
                    [self.deptArray addObject:dic];
                    
                    if (deptId == 99999) {
                        NSLog(@"调离");
                    }
					
//					//								根据类型判断是增加，删除还是修改
//					if(updateType == insertRecord || updateType == updateRecord)
//					{
//						[self.deptArray addObject:dic];
//					}
//					else
//					{
////                         NSLog(@"%s,dept name is %@ ,dept sort is %d",__FUNCTION__,deptName,_sort);
//						[deleteDepts addObject:dic];
//						iDeleteCount++;
//					}
					iCount ++;
				}
					break;
				case EIMERR_INVALID_PARAMTER:
				{//异常结束，参数有错
					[LogUtil debug:[NSString stringWithFormat:@"Parameter error"]];
					hasError = true;
					finish = true;
				}
					break;
				case EIMERR_PACKAGE_ERROR:
				{//异常结束，报文有错
					[LogUtil debug:[NSString stringWithFormat:@"Package error"]];
					hasError = true;
					finish = true;
				}
					break;
			}
		}
		if(hasError)
		{
			[LogUtil debug:[NSString stringWithFormat:@"没有解析完成，需要重新获取"]];
            [self downloadOrgError:@"同步部门数据有误"];
		}
		else
		{
			if(num != iCount)
			{
				[LogUtil debug:[NSString stringWithFormat:@"解析完成，但数据不一致"]];
                [self downloadOrgError:@"同步部门数据有误"];
			}
			else
			{
                //				解析完成，并且数据一致
//				if(iDeleteCount > 0)
//				{
////					[LogUtil debug:[NSString stringWithFormat:@"%s,iDeleteCount is %d",__FUNCTION__,iDeleteCount]];
//					[db delDepts:deleteDepts];
//				}
				//		保存部门信息更新时间
				if(getDeptListAck->wCurrPage == 0)
				{
					//					打印出总包数
					[LogUtil debug:[NSString stringWithFormat:@"部门总包数:%d",self.deptPage]];
					if([self saveDept])
					{
                        if (self.isRefreshOrgByHand) {
                            [LogUtil debug:@"手动刷新组织架构，同步部门完成"];
//                            [self getEmpDeptInfo:nil];
                            [[OrgConn getConn]syncDeptShowConfig];

                            return;
                        }
                        //                        add by shsip 保存部门之后，刷新下组织架构
                        [self sendRefreshOrgNotification];
                        
                        if ([OrgConn getConn].orgSyncTypeAck) {
                            //                        update by shisp 使用新的方式 同步员工与部门关系
                            [[OrgConn getConn]syncEmpDept];
                        }
                        else
                        {
                            //	取完部门资料，再取部门和员工关系
//                            [self getEmpDeptInfo:nil];
                            [[OrgConn getConn]syncDeptShowConfig];
                        }
					}
				}
			}
		}
    }
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"取部门关系失败"]];
	}
	
	[pool release];
}

#pragma mark -- 保存部门信息
-(bool)saveDept
{
    self.downloadOrgTips = [StringUtil getAppLocalizableString:@"conn_save_dept"];
	bool result = true;
	[LogUtil debug:[NSString stringWithFormat:@"%s,部门个数：%d",__FUNCTION__,self.deptArray.count]];
	if([db addDept:self.deptArray])
	{
		[self.deptArray removeAllObjects];
#pragma mark -- 保存子部门数据
		if([db saveDeptSubDept])
		{
#pragma mark -- 保存父部门数据
			if([db saveDeptParentDept])
			{
				//	同步完员工部门关系后，更新部门总人数列
				if([db updateDeptEmpCount])
				{
					timeEnd = [[NSDate date] timeIntervalSince1970];
					[LogUtil debug:[NSString stringWithFormat:@"同步部门数据并保存成功，总耗时：%d",(timeEnd - self.timeStart)]];
					
					//				保存部门信息同步时间
					NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,self.deptUpdateTime,dept_updatetime, nil];
					[userDb saveDeptUpdateTime:dic];
					
#pragma mark 取出所有的部门，用于计算部门在线人数
					
					if(self.onlineEmpCountArray && self.onlineEmpCountArray.count > 0)
					{
						[self.onlineEmpCountArray removeAllObjects];
					}
                    [self getAllDeptId];
					return true;
				}
			}
		}
	}
	[self.deptArray removeAllObjects];
    
	return false;
}


#pragma mark --处理员工信息---
// big data
-(void)processGetUserList:(GETUSERLISTACK *)getUserListAck
{
    //	NSMutableArray *addOrUpdateUsers = [NSMutableArray array];
	NSMutableArray *delUsers = [NSMutableArray array];
	
    self.userDeptPage ++;
//    [LogUtil debug:[NSString stringWithFormat:@"获取变化的员工，当前页数%d，当前页包含记录个数:%d",self.userDeptPage,getUserListAck->wCurrNum]];

	if(getUserListAck->result == RESULT_SUCCESS)
	{
		int num = getUserListAck->wCurrNum;
		unsigned int startPos = 0;
		UserListMobile _userListMobile;
		int iCount = 0;
		int iDeleteCount = 0;
		
		//		解析过程中是否出错
		bool hasError = false;
		//		解析是否完成
		bool finish = false;
		while (!finish)
		{
			int ret = CLIENT_ParseUserListMobile(getUserListAck->strPacketBuff, &startPos, &_userListMobile);
			switch(ret)
			{
				case EIMERR_PARSE_FINISHED:
				{//正常结束
					finish = true;
				}
					break;
				case EIMERR_SUCCESS:
				{//解析数据并且保存
					NSString *empId = [StringUtil getStringValue:_userListMobile.dwUserID];
                    
					int updateType = _userListMobile.wUpdate_type;
					
                    if (updateType == deleteRecord) {
                        NSLog(@"%s,emp id is %@ updatetype is %d",__FUNCTION__,empId,updateType);
//                        [LogUtil debug:[NSString stringWithFormat:@"%s,emp id is %@ updatetype is %d",__FUNCTION__,empId,updateType]];
                    }

                    [self.empArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",[NSNumber numberWithInt:updateType],@"update_type", nil]];
					iCount++;
				}
					break;
				case EIMERR_INVALID_PARAMTER:
				{//异常结束，参数有错
					[LogUtil debug:[NSString stringWithFormat:@"Parameter error"]];
					hasError = true;
					finish = true;
				}
					break;
				case EIMERR_PACKAGE_ERROR:
				{//异常结束，报文有错
					[LogUtil debug:[NSString stringWithFormat:@"Package error"]];
					hasError = true;
					finish = true;
				}
					break;
			}
		}
		
        if(hasError)
        {
            [LogUtil debug:[NSString stringWithFormat:@"没有解析完成，需要重新获取"]];
//            [self getEmployeeInfo:nil];
        }
        else
        {
            if(num != iCount)
            {
                [LogUtil debug:[NSString stringWithFormat:@"解析完成，但数据不一致"]];
//                [self getEmployeeInfo:nil];
            }
            else
            {
                //				解析完成，并且数据一致
                //		保存信息更新时间
                if(getUserListAck->wCurrPage == 0)
                {
                    [LogUtil debug:[NSString stringWithFormat:@"变化的员工总页数:%d",self.userDeptPage]];

                    [self saveEmp2];
                    
                }
            }
        }
    }
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"员工资料同步失败"]];
	}
}

#pragma mark 放在队列里保存用户详细资料，每次保存定量数据，目前是每次100
-(void)saveEmp1:(NSArray *)tempEmpArray
{
	[db updateEmp:tempEmpArray];
}

#pragma mark 放在队列里保存用户详细资料，并且记录更新时间
-(void)saveEmp2
{
    int startTime = [self getCurrentTime];
//    先把删除的和其它的分开，然后分别处理
    NSMutableArray *addOrUpdateRecords = [NSMutableArray array];
    NSMutableArray *deleteRecords = [NSMutableArray array];
    for (NSDictionary *dic in self.empArray)
    {
        NSNumber *updateType = [dic valueForKey:@"update_type"];
        if (updateType.intValue == deleteRecord)
        {
            [deleteRecords addObject:dic];
        }
        else
        {
            [addOrUpdateRecords addObject:[dic valueForKey:@"emp_id"]];
        }
    }
    
    if (deleteRecords.count > 0)
    {
        [db delEmps:deleteRecords];
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,addorupdate %lu ,delete %lu",__FUNCTION__,(unsigned long)addOrUpdateRecords.count,(unsigned long)deleteRecords.count]];
    
	for(NSString *empId in addOrUpdateRecords)
    {
        [db updateEmpInfoFlag:empId];
    }
	
    //			保存时间
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,self.empUpdateTime,emp_updatetime, nil];
	[userDb saveEmpUpdateTime:dic];
	
	[self.empArray removeAllObjects];
    
//  如果有删除的人，证明有些人离职了，
    if (deleteRecords.count > 0) {
        self.needClearEmpArray = YES;
//        if (self.allEmpArray.count ) {
//            [self.allEmpArray removeAllObjects];
//            [self.empCodeAndEmpDic removeAllObjects];
//            [self.allEmpsDic removeAllObjects];
//            
//        }
//        [self getAllEmpArray];
    }
    [LogUtil debug:[NSString stringWithFormat:@"同步员工资料完成完成,%d",([self getCurrentTime] - startTime)]];
}

#pragma mark--处理员工部门信息----
// bigdata
-(void)processGetUserDept:(GETUSERDEPTACK *)getUserDeptAck
{
	NSMutableArray *delEmpDepts = [NSMutableArray array];
	self.userDeptPage ++;
	
//    	[LogUtil debug:[NSString stringWithFormat:@"当前页数%d，当前页包含记录个数:%d",self.userDeptPage,getUserDeptAck->wCurrNum]];
	
	if(getUserDeptAck->result == RESULT_SUCCESS)
	{
		int num = getUserDeptAck->wCurrNum;
		unsigned int startPos = 0;
		USERDEPT _userDept;
		int iCount = 0;
		int iDeleteCount = 0;
		
		//		解析过程中是否出错
		bool hasError = false;
		//		解析是否完成
		bool finish = false;
		while (!finish)
		{
			int ret = CLIENT_ParseDeptUserInfo(getUserDeptAck->strPacketBuff, &startPos, &_userDept);
			switch(ret)
			{
				case EIMERR_PARSE_FINISHED:
				{//正常结束
					finish = true;
				}
					break;
				case EIMERR_SUCCESS:
				{//解析数据并且保存
					EmpDeptDL *_empDeptDl = [[EmpDeptDL alloc]init];
					_empDeptDl.empId = _userDept.dwUserID;
					_empDeptDl.empCode =  [StringUtil getStringByCString:_userDept.aszUserCode];
					_empDeptDl.deptId = _userDept.dwDeptID;
                    
//                   update by shisp 保存empLogo时，不保存服务器端返回的数据，而是保存为0，就是默认的头像时间戳
					_empDeptDl.empLogo = @"0";//[StringUtil getStringByCString:_userDept.aszLogo];
					_empDeptDl.empName = [StringUtil getStringByCString:_userDept.aszCnUserName];
                    
                    _empDeptDl.empNameEng = [StringUtil getStringByCString:_userDept.aszEnUserName];
                    
					_empDeptDl.empSex = _userDept.cSex;
					
					_empDeptDl.rankId = _userDept.cRankID;
                    
                    if ([UIAdapterUtil isCsairApp] && START_CSAIR_HIDE_ORG) {
                        if (_empDeptDl.rankId == 0) {
                            //                        不显示
                            [LogUtil debug:[NSString stringWithFormat:@"%s %@ 不能显示",__FUNCTION__,_empDeptDl.empName]];
                        }else if(_empDeptDl.rankId == 1){
                            //                        显示
//                            [LogUtil debug:[NSString stringWithFormat:@"%s %@ 需要显示",__FUNCTION__,_empDeptDl.empName]];
                        }
                    }
                    
                    
					_empDeptDl.profId = _userDept.cProfessionalID;
					_empDeptDl.areaId = _userDept.dwAreaID;
//                    
//                    if ([_empDeptDl.empCode isEqualToString:@"youjiachen"])
//                    {
//                        NSLog(@"test");
//                    }
//					
//                    _empDeptDl.empSort = 0;
//                    if (_userDept.wSort > 0) {
//                        NSLog( @"%s,%@,%d",__FUNCTION__,_empDeptDl.empName,_userDept.wSort);
//                    }
					int updateType = _userDept.wUpdate_type;
                    _empDeptDl.empSort = (unsigned short)_userDept.wSort;

                    if (updateType == deleteRecord) {
                        NSLog(@"%s,empid is %d empcode is %@ emp name is %@,dept id is %d,updateType is %d",__FUNCTION__,_empDeptDl.empId, _empDeptDl.empCode,_empDeptDl.empName,_empDeptDl.deptId,updateType);
                    }
                    
                    if ([_empDeptDl.empCode rangeOfString:@"v_ctxtest14" options:NSCaseInsensitiveSearch].length > 0)
                    {
                        NSLog(@"%s,emp name is %@,emp sort is %d,updateType is %d",__FUNCTION__,_empDeptDl.empName,_empDeptDl.empSort,updateType);
                    }
                    
                    _empDeptDl.updateType = updateType;
                    
#if defined(_XIANGYUAN_FLAG_) || defined(_ZHENGRONG_FLAG_)
//                    [LogUtil debug:[NSString stringWithFormat:@"%s %@ rankid is %d",__FUNCTION__,_empDeptDl.empName,_empDeptDl.rankId]];
#endif


                    [self.empDeptArray addObject:_empDeptDl];
                    
					[_empDeptDl release];
					iCount ++;
				}
					break;
				case EIMERR_INVALID_PARAMTER:
				{//异常结束，参数有错
					[LogUtil debug:[NSString stringWithFormat:@"Parameter error"]];
					hasError = true;
					finish = true;
				}
					break;
				case EIMERR_PACKAGE_ERROR:
				{//异常结束，报文有错
					[LogUtil debug:[NSString stringWithFormat:@"Package error"]];
					hasError = true;
					finish = true;
				}
					break;
			}
		}
		
		if(hasError)
		{
			[LogUtil debug:[NSString stringWithFormat:@"没有解析完成，需要重新获取"]];
            [self downloadOrgError:@"同步员工与部门关系数据有误"];
		}
		else
		{
			if(num != iCount)
			{
				[LogUtil debug:[NSString stringWithFormat:@"解析完成，但数据不一致"]];
                [self downloadOrgError:@"同步员工与部门关系数据有误"];
			}
			else
			{
				//		保存部门信息更新时间
				if(getUserDeptAck->wCurrPage == 0)
				{
					[LogUtil debug:[NSString stringWithFormat:@"员工与部门资料总页数:%d",self.userDeptPage]];
					if([self saveEmpDept2])
					{
#ifdef _XIANGYUAN_FLAG_
//#ifdef _LANGUANG_FLAG_
                        //        同步获取部门显示配置并处理
                        //[[OrgConn getConn]getXYDeptShowConfig];
#endif
                        if (self.isRefreshOrgByHand)
                        {
                            [LogUtil debug:@"手动刷新组织架构，同步员工与部门关系完成"];

                            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                            _notificationObject.cmdId = refresh_org_byhand_finish;
                            
                            [[NotificationUtil getUtil]sendNotificationWithName:ORG_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
                            
                            self.connStatus = normal_type;
                            return;
                        }
                        
                        [self sendRefreshOrgNotification];
                        //						员工部门数据同步完成后，获取状态
                        //						[self getUserStateList];
//						[self getOfflineMsgNum];
//                        如果是手动刷新通讯录 则不继续下面的流程

                        [_userDataConn sendSystemGroupSync];
					}
				}
			}
		}
	}
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"取员工部门失败"]];
	}
}

#pragma mark 放到队列里保存员工部门数据，并且记录更新时间
-(bool)saveEmpDept2
{
    self.downloadOrgTips = [StringUtil getAppLocalizableString:@"conn_save_emp"];
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,self.empDeptArray.count]];
	if([db saveEmpDepts:self.empDeptArray])
	{
		//	同步完员工部门关系后，更新部门总人数列
		if([db updateDeptEmpCount])
		{
			timeEnd = [[NSDate date] timeIntervalSince1970];
			[LogUtil debug:[NSString stringWithFormat:@"同步保存员工与部门关系完成，总耗时：%d",(timeEnd - self.timeStart)]];
			
			//		保存员工部门信息更新时间
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,self.empDeptUpdateTime,emp_dept_updatetime, nil];
			[userDb saveEmpDeptUpdateTime:dic];
			if(self.allEmpArray && self.allEmpArray.count > 0)
			{
				[self.allEmpArray removeAllObjects];
			}
            [self getAllEmpArray];
            //			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            //			self.allEmpArray = [NSMutableArray arrayWithArray:[db getEmployeeList]];
            //			[pool release];
			return true;
		}
	}
	[self.empDeptArray removeAllObjects];
	return false;
}

#pragma mark---获取用户状态---
-(void)processGetUserStateList:(GETUSERSTATELISTACK*)info
{
    //    如果是登录后第一次获取状态，那么就按照现在的处理
    //    否则就要按照新的方式处理
	if(info->result == RESULT_SUCCESS)
	{
		int curPage = info->wCurrPage;
		int curNum = info->wCurrNum;
        
		if(curNum > 0)
		{
			USERSTATE *userState;
			;
			for(int i = 0;i<curNum;i++)
			{
				userState =& (info->aUserState)[i];
				
				NSString *sState = [StringUtil getClientStatusByServerStatus:userState->cState];
				
                //				if(sState.intValue == status_online || sState.intValue == status_leave)
                //				{
                int loginType = userState->cLoginType;
                //                [LogUtil debug:[NSString stringWithFormat:@"%s empId is %d, empStatus is %d,  loginType is %d",__FUNCTION__,userState->dwUserID, userState->cState, loginType]];
                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[StringUtil getStringValue: userState->dwUserID],@"emp_id",sState,@"emp_status",[StringUtil getStringValue:loginType],@"emp_login_type", nil];
                [self.empStatusArray addObject:dic];
                [dic release];
                //				}
			}
		}
		
		if(curPage == 0)
		{
            [LogUtil debug:[NSString stringWithFormat:@"获取用户在线状态完毕"]];
            if(isFirstProcessUserStateList)
            {
                [LogUtil debug:@"第一次获取到状态，包括所有在线用户"];
                //			在保存状态之前，先把所有用户的状态设置为离线
                [self addTaskToQueue:@selector(saveEmpStatus) andObject:nil];
                [self getRankInfo];
            }
            else
            {
                [LogUtil debug:@"主动获取到状态变化，包括增量的用户状态修改"];
                
                [self updateEmpStatusOfStatusNotice:self.empStatusArray];
            }
		}
	}
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"get user state failure"]];
	}
}

//deprecatd 之前南航要求显示在线人数，目前不需要
-(void)saveEmpStatus
{
    [db setAllEmpsToOffline];
    
	[db updateEmpStatus:self.empStatusArray];
	
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d,%@",__FUNCTION__,self.empStatusArray.count,self.empStatusArray]];
	
    //	用户状态取完毕后，要保存在部门在线人员中
    //	首先把所有用户状态设置为离线
	[self getAllEmpArray];
    
//    int totalEmpCount = [db getDeptEmpCount];
    
    while (self.allEmpArray.count <= 1) {
        
        [NSThread sleepForTimeInterval:0.005];
        //        NSLog(@"total emp count is %d,current emp count is %d",totalEmpCount,self.allEmpArray.count);
    }
    
    //    保存状态时，先看下员工是否都已保存在了内存中，如果没有，那么休眠一会儿，直到都获取完再继续往下执行
    
	for(Emp *_emp in [self getAllEmpInfoArray])
	{
		_emp.emp_status = status_offline;
	}
    //	把部门对应的在线的用户数设置为0
//	[self getAllDeptId];
    
    for (DeptInMemory *_dept in [self getAllDeptInfoArray]) {
        _dept.onlineEmpCount = 0;
    }
	
    //	取出人员，找到其部门，然后再更新部门对应人数
	for(NSDictionary *statusDic in self.empStatusArray)
	{
		[self updateOnlineEmpCount:statusDic];
	}
    
    if(isFirstProcessUserStateList)
    {
        isFirstProcessUserStateList = NO;
        [self executeAfterSaveUserStatus];
    }
    //    add by shisp 获取完用户状态后，刷新下组织架构
    [self sendRefreshOrgNotification];
}

#pragma mark 根据deptId 找到对应的部门的emp数组 从内存里获取某个部门的所有联系人
- (NSArray *)getEmpsByDeptId:(int)deptId
{
    [self getAllEmpArray];
	NSMutableArray *_empArray = [NSMutableArray array];
	
	for(Emp *_emp in [self getAllEmpInfoArray])
	{
		if(_emp.emp_dept == deptId)
		{
			[_empArray addObject:_emp];
		}
	}
	return _empArray;
}

#pragma mark 根据empId，找到对应的emp
-(NSArray*)getEmpByEmpId:(int)empId
{
    //	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	[self getAllEmpArray];
	NSMutableArray *_empArray = [NSMutableArray array];
	
    NSArray *deptArray = [db getDeptCountByEmpId:empId];
    for (int i = 0;i < deptArray.count; i++)
    {
        NSString *key = [NSString stringWithFormat:@"%d_%d",empId,[[[deptArray objectAtIndex:i]valueForKey:@"dept_id"]intValue]];
        Emp *_emp = [self.allEmpsDic objectForKey:key];
        if (_emp) {
            [_empArray addObject:_emp];
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,@"内存中还没有员工数据"]];
        }
    }
    //    NSLog(@"%s,emp_id is %d, emp count is %d",__FUNCTION__,empId,_empArray.count);
	return _empArray;
}
#pragma mark 把所有内存中的员工数据设置为非选中状态
-(void)setAllEmpNotSelect
{
	[self getAllEmpArray];
	for(Emp *_emp in [self getAllEmpInfoArray])
	{
        if (_emp.isSelected) {
            _emp.isSelected = false;
        }
	}
}

#pragma mark 更新对应部门的在线人数 状态如果有变化，那么就返回YES，如果没有变化那么就返回NO
-(BOOL)updateOnlineEmpCount:(NSDictionary*)statusDic
{
    BOOL statusChange = NO;
    
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,statusDic is %@",__FUNCTION__,[statusDic description]]];
	int empId = [[statusDic valueForKey:@"emp_id"]intValue];
	int empStatus = [[statusDic valueForKey:@"emp_status"]intValue];
	int loginType = [[statusDic valueForKey:@"emp_login_type"]intValue];
    
	NSArray *_empArray = [self getEmpByEmpId:empId];
    
//	[self getAllDeptId];
    
	for(Emp *_emp in _empArray)
	{
        //        并且不是自己，自己肯定要显示状态
        if(_emp.permission.hideState && _emp.emp_id != self.userId.intValue)
        {
            NSLog(@"%@设置了屏蔽状态",_emp.emp_name);
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:statusDic];
            [mDic setValue:[StringUtil getStringValue:status_offline] forKey:@"emp_status"];
            [mDic setValue:[StringUtil getStringValue:TERMINAL_PC] forKey:@"emp_login_type"];
            
            [db updateEmpStatus:[NSArray arrayWithObject:mDic]];
            continue;
        }
        
//        如果是机器人，那么状态不变，仍然为在线
        if (_emp.isRobot) {
            continue;
        }
        
        if (_emp.emp_status != empStatus)
        {
            //                如果状态改变
            statusChange = YES;
        }
        else if(empStatus == status_online && _emp.loginType != loginType)
        {
            //                如果是在线，并且登录方式改变
            statusChange = YES;
        }
        
        _emp.emp_status = empStatus;
        _emp.loginType = loginType;
        
        continue;

        
		if(_emp && self.onlineEmpCountArray)
		{
            if (_emp.emp_status != empStatus)
            {
//                如果状态改变
                statusChange = YES;
            }
            else if(empStatus == status_online && _emp.loginType != loginType)
            {
//                如果是在线，并且登录方式改变
                statusChange = YES;
            }
            
			//		如果状态没有变化 或者原来是在线，现在是离开，或者原来是离开，现在是在线，那么数量不变
//			if((_emp.emp_status == empStatus) || (_emp.emp_status == status_online && empStatus == status_leave) || (_emp.emp_status == status_leave && empStatus == status_online))
//			{
//				_emp.emp_status = empStatus;
//				_emp.loginType = loginType;
//				continue;
//			}
			_emp.emp_status = empStatus;
			_emp.loginType = loginType;
			
//            万达版本不计算在线人数,下面计算人数的代码不执行
            continue;
            
			int deptId = _emp.emp_dept;
			
            //					[LogUtil debug:[NSString stringWithFormat:@"emp dept id is %d",deptId]];
            
            //    update by shisp 原来是从数组中获取，现在从Dictionary中获取，可以根据deptId快速定位
            DeptInMemory *_dept = [self getDeptInMemoryByDeptId:deptId];
            if (_dept) {
                if(_emp.permission.isHidden)
                {
                    NSLog(@"修改部门在线人数时，发现这个用户是隐藏的，那么在线人数不受影响");
                    continue;
                }
                
                NSString *parentDept = _dept.deptParentDept;
                //									[LogUtil debug:[NSString stringWithFormat:@"parentDept is %@",parentDept]];
                int oldCount = _dept.onlineEmpCount;
                //									[LogUtil debug:[NSString stringWithFormat:@"mDic is %@",[mDic description]]];
                if(empStatus == status_online || empStatus == status_leave)
                {
                    _dept.onlineEmpCount = oldCount + 1;
                    //					所有父部门在线人数也应该+1
                    [self updateParentDeptOnlineEmpCount:parentDept andType:0];
                }
                else
                {
                    if(oldCount > 0)
                    {
                        _dept.onlineEmpCount = oldCount - 1;
                        //						所有父部门在线人数也应该-1
                        [self updateParentDeptOnlineEmpCount:parentDept andType:1];
                    }
                }
            }
		}
	}
    return statusChange;
}
#pragma mark 修改父部门的在线人数，参数是父部门字符串，_type为0，表示+1，为1表示-1 deprecated
-(void)updateParentDeptOnlineEmpCount:(NSString*)parentDept andType:(int)_type
{
	NSArray *_deptArray = [parentDept componentsSeparatedByString:@","];
	for(NSString *deptId in _deptArray)
	{
		[self updateOneDeptEmpCount:deptId andType:_type];
	}
	
}
#pragma mark 修改某一个部门的在线人数，参数部门id，_type为0，表示+1，为1表示-1 deprecated
-(void)updateOneDeptEmpCount:(NSString*)deptId andType:(int)_type
{
    //    update by shisp 原来是从数组中获取，现在从Dictionary中获取，可以根据deptId快速定位
    DeptInMemory *_dept = [self getDeptInMemoryByDeptId:deptId.intValue];
    if (_dept) {
        int _count = _dept.onlineEmpCount;
        if(_type == 0)
        {
            _count++;
        }
        else
        {
            _count--;
            if(_count < 0)
                _count = 0;
        }
        _dept.onlineEmpCount = _count;
    }
}

#pragma mark 获取对应部门的在线人数 deprecated
-(int)getOnlineEmpCountByDeptId:(int)deptId
{
    //            万达版本不计算在线人数
    return 0;
	if(deptId > 0 && self.onlineEmpCountArray)
	{
        //    update by shisp 原来是从数组中获取，现在从Dictionary中获取，可以根据deptId快速定位
        
        DeptInMemory *_dept = [self getDeptInMemoryByDeptId:deptId];
        if (_dept) {
            return _dept.onlineEmpCount;
        }
	}
	return 0;
}
#pragma mark 获取多个部门的在线人数总和 deprecated
-(int)getOnlineEmpCountByDeptIdGroup:(NSArray*)deptIdArray
{
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,deptIdArray]];
	int count = 0;
	for(NSString *deptId in deptIdArray)
	{
		count = count + [self getOnlineEmpCountByDeptId:deptId.intValue];
	}
	return count;
}

#pragma mark 根据deptId,从内存中获取对应的父部门id 搜索联系人时使用
-(NSString *)getDeptParentStrByDeptId:(int)deptId
{
    NSString *parentDept = nil;
    //    update by shisp 原来是从数组中获取，现在从Dictionary中获取，可以根据deptId快速定位
    
    DeptInMemory *_dept = [self getDeptInMemoryByDeptId:deptId];
    if (_dept) {
        parentDept = _dept.deptParentDept;
    }
    return parentDept;
}

#pragma mark---处理用户状态通知---
//bigdata deprecated
-(void)processUserStatusNotice:(USERSTATUSSETNOTICE*)info
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //	int curNum = info->wCurrNum;
	NSMutableArray *statusArray = [NSMutableArray array];
	
	//		解析过程中是否出错
	bool hasError = false;
	//		解析是否完成
	bool finish = false;
    
	unsigned int startPos = 0;
	USERSTATUSNOTICE _userStatusNotice;
	
	while (!finish)
	{
		int ret = CLIENT_ParseUserStatusSetNotice(info->strPacketBuff, &startPos, &_userStatusNotice);
		switch(ret)
		{
			case EIMERR_PARSE_FINISHED:
			{//正常结束
				finish = true;
			}
				break;
			case EIMERR_SUCCESS:
			{//解析数据并且保存
				NSString *empId = [StringUtil getStringValue: _userStatusNotice.dwUserID];
				NSString *empStatus = [StringUtil getClientStatusByServerStatus:_userStatusNotice.cStatus];
				int loginType = _userStatusNotice.cLoginType;
                [LogUtil debug:[NSString stringWithFormat:@"%s,emp is is %d,status is %d ,loginType is %d",__FUNCTION__,_userStatusNotice.dwUserID,_userStatusNotice.cStatus,loginType]];
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",empStatus,@"emp_status",[StringUtil getStringValue:loginType],@"emp_login_type", nil];
				[statusArray addObject:dic];
			}
				break;
			case EIMERR_INVALID_PARAMTER:
			{//异常结束，参数有错
				[LogUtil debug:[NSString stringWithFormat:@"Parameter error"]];
				hasError = true;
				finish = true;
			}
				break;
			case EIMERR_PACKAGE_ERROR:
			{//异常结束，报文有错
				[LogUtil debug:[NSString stringWithFormat:@"Package error"]];
				hasError = true;
				finish = true;
			}
				break;
		}
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,statusArrayCount is %d",__FUNCTION__,statusArray.count]];
    [self updateEmpStatusOfStatusNotice:statusArray];
    
    //	[db updateEmpStatus:statusArray];
    //	//	更新内存中对应的在线人数
    //	for(NSDictionary *dic in statusArray)
    //	{
    //		[self updateOnlineEmpCount:dic];
    //	}
    
    [pool release];
}

//保存用户状态 万达版本
- (void)saveEmpStatusOfWanda:(TUserStatusList *)info
{
    NSMutableArray *statusArray = [NSMutableArray array];
    int num = info->dwUserStatusNum;
    [LogUtil debug:[NSString stringWithFormat:@"收到%d个用户状态",num]];
    for (int i = 0; i < num; i++)
    {
        USERSTATUSNOTICE _userStatusNotice = info->szUserStatus[i];
        NSString *empId = [StringUtil getStringValue: _userStatusNotice.dwUserID];
        NSString *empStatus = [StringUtil getClientStatusByServerStatus:_userStatusNotice.cStatus];
        int loginType = _userStatusNotice.cLoginType;
//        [LogUtil debug:[NSString stringWithFormat:@"%s,emp is %d,status is %@ ,loginType is %d",__FUNCTION__,_userStatusNotice.dwUserID,empStatus,loginType]];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:empId,@"emp_id",empStatus,@"emp_status",[StringUtil getStringValue:loginType],@"emp_login_type", nil];
        [statusArray addObject:dic];
    }
    
//    int totalEmpCount = [db getDeptEmpCount];

//    update by shisp 不再放到队列里执行
    [self updateEmpStatusOfStatusNotice:statusArray];
}

-(void)updateEmpStatusOfStatusNotice:(NSArray*)statusArray
{
    NSMutableArray *statusChangeArray = [NSMutableArray array];
 
    if (self.allEmpArray.count <= 1)
    {
//        如果内存里还没有员工数据，那么把取到的用户状态都发出去，否则把有变化的发出去
        [LogUtil debug:@"save wanda status 内存里还没有员工数据"];
        
//        要加下判断，如果是机器人，则状态为pc在线
        for (NSDictionary *dic in statusArray)
        {
            int empId = [[dic valueForKey:@"emp_id"]intValue];
            BOOL isRobot = [[RobotDAO getDatabase]isRobotUser:empId];
            if (isRobot)
            {
                [statusChangeArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:empId],@"emp_id",[StringUtil getStringValue:status_online],@"emp_status",[StringUtil getStringValue:TERMINAL_PC],@"emp_login_type", nil]];
            }
            else
            {
                [statusChangeArray addObject:dic];
            }
        }
        
//        [statusChangeArray addObjectsFromArray:statusArray];
    }
    else
    {
        //	更新内存中对应的在线人数
        for(NSDictionary *dic in statusArray)
        {
            BOOL statusChange = [self updateOnlineEmpCount:dic];
            if (statusChange) {
                [statusChangeArray addObject:dic];
            }
        }
    }
    
//    发送状态变化通知出去
    if (statusChangeArray.count > 0) {
        [db updateEmpStatus:statusChangeArray];
//        [LogUtil debug:[NSString stringWithFormat:@"状态变化了的用户如下:%@",statusChangeArray]];
        
        [[NotificationUtil getUtil]sendNotificationWithName:EMP_STATUS_CHANGE_NOTIFICATION andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:statusChangeArray forKey:key_status_change_array]];
    }
}

#pragma mark---处理广播消息
-(void)processBroadcastNotice:(BROADCASTNOTICE*)info
{
//    测试代码
//    info->cAllReply = broadcast_msg_type_agent_notice;
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:APPLICATION_PUSH];
    int broadcastType = info->cAllReply; //2: IM提醒通知
    
//    测试代码
 //   broadcastType = broadcast_msg_type_agent_notice;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 收到的广播类型为 %d",__FUNCTION__,broadcastType]];
    
    // 一呼万应接收信息处理
    if (broadcastType == mass_notice_broadcast) {
        MsgNotice *_msg = [MassConn getMsgNoticeObject:info];
        if(_msg && _msg.isMassMsg)
        {
            [self setUserStatusToOnlineIfNotOnline:_msg];
            [self addTaskToQueue:@selector(saveMassMsg:) andObject:_msg];
        }
    }else if(broadcastType == appNotice_broadcast){
        [APPConn processBroadcastNotice:info];
    }else{
        NSString *SenderID = [StringUtil getStringValue: info->dwSenderID];
        NSString *RecverID = [StringUtil getStringValue: info->dwRecverID];
        NSString *SendTime = [StringUtil getStringValue:info->dwSendTime];
        NSString *MsgID = [StringUtil getStringValue:info->dwMsgID];
        NSString *MsgLen=[StringUtil getStringValue:info->dwMsgLen];
        
        NSString *Titile = [StringUtil getStringByCString:info->aszTitile];
        
        //是否已经保存过该条广播
        if ([db isBroadcastSaved:MsgID]) {
            [LogUtil debug:[NSString stringWithFormat:@"%s broadcast has saved",__FUNCTION__]];
            return;
        }
        
        //    需要把消息里的字体去掉
        int msgLen = info->dwMsgLen - 10;
        char temp[msgLen + 1];
        memset(temp,0,sizeof(temp));
        memcpy(temp,info->aszMessage + 10, msgLen - 1);
        
        NSString *Message = [StringUtil getStringByCString:temp];
        
        
        //    NSString *Message = [StringUtil getStringByCString:info->aszMessage];
        //广播---保存
        if (Titile==nil||(Titile!=nil&&[Titile length]==0)) {
            Titile=@"";
        }
        if (Message==nil||(Message!=nil&&[Message length]==0)) {
            Message=@"";
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"SenderID--%@ SendTime--%@ MsgID--%@ MsgLen---%@ Titile--%@  Message---%@",SenderID,SendTime,MsgID,MsgLen,Titile,Message]];
        
        if (broadcastType == imNotice_broadcast) {
            [LogUtil debug:[NSString stringWithFormat:@"%s，收到应用提醒",__FUNCTION__]];
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,收到普通的广播消息",__FUNCTION__]];
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SenderID,@"sender_id",RecverID,@"recver_id",MsgID,@"msg_id",SendTime,@"sendtime",MsgLen,@"msglen",Titile,@"asz_titile",Message,@"asz_message",[NSNumber numberWithInt:broadcastType],@"broadcast_type", nil];
        
        [db saveBroadcast:[NSArray arrayWithObject:dic]];
    }
}

#pragma mark ---处理群组创建消息----
-(void)processCreateGroup:(CREATEGROUPACK*)createGroupAck
{
	[self stopTimeoutTimer];
	self.isCreateGroupCmd = false;

    NSString *convId = [StringUtil getStringByCString:createGroupAck->aszGroupID];
    if (convId)
    {
        if(createGroupAck->result == RESULT_SUCCESS)
        {
            //		修改last_msg_id标志为0，-1表示没有创建
            [db setGroupCreateFlag:convId];
            // 保存创建时间
            [db updateConversationTime:convId andTime:createGroupAck->dwTime];
            
            [LogUtil debug:[NSString stringWithFormat:@"create group success ,groupid is %@",convId]];
            
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = create_group_success;
            
//            增加服务器返回的群组创建的时间
            _notificationObject.info = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"CONV_ID",[NSNumber numberWithInt:createGroupAck->dwTime],@"group_create_time", nil];
//            [NSDictionary dictionaryWithObject:convId forKey:@"CONV_ID"];
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"create group failure"]];
            
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = create_group_failure;
            _notificationObject.info = [NSDictionary dictionaryWithObject:convId forKey:@"CONV_ID"];
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        }
    }
}

#pragma mark ----修改用户资料应答----
-(void)processModifyUserInfo:(MODIINFOACK *)info
{
	[self stopTimeoutTimer];
    
	if(info->result == RESULT_SUCCESS)
	{
        
        [LogUtil debug:[NSString stringWithFormat:@"update user info success"]];

        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = modify_userinfo_success;
        
        [[NotificationUtil getUtil]sendNotificationWithName:MODIFYUSER_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
	}
	else {
        [LogUtil debug:[NSString stringWithFormat:@"update user info fail"]];

        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = modify_userinfo_failure;
        
        [[NotificationUtil getUtil]sendNotificationWithName:MODIFYUSER_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
	}
}

#pragma mark ----获取分组信息应答----
//收到消息的时候，要增加到消息记录表里，同时还要判断会话表里是否包含此会话，不包含则要增加，如果是单聊，可以本地添加，如果是群聊，就要从服务器获取群信息，入库
-(void)processGetGroupInfo:(GETGROUPINFOACK *)info
{
	if(info->result == RESULT_SUCCESS)
	{
		[LogUtil debug:[NSString stringWithFormat:@"get group info success"]];
        
		int createId = info->dwCreaterID;
		NSString *grpId = [StringUtil getStringByCString:info->aszGroupID];
        
//        测试数据
//        char tempGrpName[50];
//        memset(tempGrpName, 0x0, sizeof(tempGrpName));
//        
//        int _len = strlen(info->aszGroupName);
//        memcpy(tempGrpName, info->aszGroupName, _len - 2);
//        
//        NSString *grpName = [StringUtil getStringByCString:tempGrpName];
        
        NSString *grpName = [StringUtil getGrpNameFromCGroupName:info->aszGroupName];
        
        NSMutableArray *emps = [NSMutableArray array];
		int empId;
		int empNum = info->wNum;
		for(int i=0;i<empNum;i++)
		{
			empId = (info->aUserID)[i];
			[emps addObject:[StringUtil getStringValue:empId]];
		}
        
        [LogUtil debug:[NSString stringWithFormat:@"%s,grpId is %@,grpName is %@ empNum is %d",__FUNCTION__,grpId,grpName,empNum]];
		
        //		[LogUtil debug:[NSString stringWithFormat:@"%s,群组成员包括：%@",__FUNCTION__,emps]];
        
        //		创建时间
		NSString *groupTime = [StringUtil getStringValue:info->dwTime];
		
        //		[LogUtil debug:[NSString stringWithFormat:@"%s,groupTIme is %@",__FUNCTION__,groupTime]];
		[self createGroup:grpId andName:grpName andCreateor:createId andGroupTime:groupTime andEmps:emps];
        
        if (self.incompleteReceiptMsgArray.count > 0) {
            NSMutableArray *tempArray = [NSMutableArray array];
            
            for (NSDictionary *dic in self.incompleteReceiptMsgArray) {
                NSString *convId = dic[@"conv_id"];
                if ([grpId isEqualToString:convId]) {
                    [tempArray addObject:dic];
                }
            }
            [db processReceiptMsgArray:tempArray];
            
            for (NSDictionary *dic in tempArray) {
                [self.incompleteReceiptMsgArray removeObject:dic];
            }
        }
	}
	else{
		[LogUtil debug:[NSString stringWithFormat:@"get group info failure"]];
	}
}

#pragma mark----获取分组信息应答和收到创建分组通知后创建群组----
-(void)createGroup:(NSString*)grpId andName:(NSString*)grpName andCreateor:(int)createId andGroupTime:(NSString*)groupTime andEmps:(NSArray*)emps
{
    //    如果是机组群，那么自动去掉机组群标题中的空格字符
    if ([grpId hasPrefix:@"g"])
    {
        grpName = [grpName stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    //	是否生成谁邀请谁加入群组的消息
	bool needSaveGroupInfo = false;
	
    //	如果群组不存在，才添加
	NSDictionary *_dic = [db searchConversationBy:grpId];
	if(_dic)
	{
		NSString *createEmp = [_dic valueForKey:@"create_emp_id"];
		NSString *createTime = [_dic valueForKey:@"create_time"];
        
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:grpName,@"conv_title",[StringUtil getStringValue:createId],@"create_emp_id",groupTime,@"create_time", nil];
		
		[db updateConversation:grpId andValues:dic];
        
		if((createEmp == nil || createEmp.intValue == 0) && (createTime == nil || createTime.length == 0))
		{
            //			群组存在，但createEmp和createTime都没有值，是以下这种情况
            //			收到了群组的消息后，本地还没有这个群组，那么创建一个群组，但不给create_emp_id和create_time赋值，等获取了群组消息后才赋值
            //			这时需要生成谁邀请谁加入群组的通知
            
            
			needSaveGroupInfo = true;
            
            //    南航要求自己创建的群自动加到常用群
            if ([UIAdapterUtil isCsairApp]) {
                int createUserId = [[dic valueForKey:@"create_emp_id"]intValue];
                if ([conn getConn].userId.intValue == createUserId) {
                    [[UserDataDAO getDatabase]addOneCommonGroup:grpId];
                }
            }
		}
        //		群组名称可能修改
		[self sendGroupNameModifyNotification:grpId andNewGroupName:grpName];
	}
	else
	{
		needSaveGroupInfo = true;
		//				多人会话
		NSString *convType = [StringUtil getStringValue:mutiableType];
		//				不屏蔽
		NSString *recvFlag = [StringUtil getStringValue:open_msg];
        
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
							 grpId,@"conv_id",
							 convType,@"conv_type",
							 grpName,@"conv_title",
							 recvFlag,@"recv_flag",
							 [StringUtil getStringValue:createId],@"create_emp_id",
							 groupTime,@"create_time",nil];
		[db addConversation:[NSArray arrayWithObject:dic]];
        
//      新加群组 默认不在会话列表显示，有消息时才在列表显示
        if (createId != _conn.userId.intValue) {
            [db updateDisplayFlag:grpId andFlag:1];
        }
	}
    
	//			群组成员可能有变化，先删除成员，再添加成员
	[db deleteConvEmpBy:grpId];
    
	//		增加会话人员
	NSMutableArray *convEmps = [NSMutableArray arrayWithCapacity:[emps count]];
	for(NSString *empId in emps){
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",empId,@"emp_id",nil];
		[convEmps addObject:dic];
	}
	[db addConvEmp:convEmps];
	
    //	通知成员变化
	[self sendGroupMemberModifyNotification:grpId];
	
	if(needSaveGroupInfo)
	{
		//	//	谁邀请你和谁加入群聊
		NSString *createEmpName = [StringUtil getLocalizableString:@"group_notify_big_you"];
		if(createId != self.userId.intValue)
		{
			createEmpName = [db getEmpNameByEmpId:[StringUtil getStringValue:createId]];
            
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
            if ([createEmpName isEqualToString:[StringUtil getStringValue:createId]]) {
//                没有取到用户名字 需要调用华夏接口
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",[StringUtil getStringValue:mutiableType],@"conv_type", nil];
                
                NSDictionary *huaXiaEmpDic = [[HuaXiaOrgUtil getUtil]getHXEmpInfoByEmpId:createId withUserInfo:userInfo withCompleteHandler:^(NSDictionary *empInfoDic, NSDictionary *userInfo) {
                    
                    Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:empInfoDic];
                    if (_emp) {
                        //                    发出通知给会话列表界面修改某个单聊会话的会话标题
                        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                        [mDic setObject:_emp forKey:@"EMP"];
                        
                        [[NotificationUtil getUtil]sendNotificationWithName:GET_USER_INFO_FROM_HX_NOTIFICATION andObject:nil andUserInfo:mDic];
                    }
                }];
                if (huaXiaEmpDic){
                    //马上获取到了Emp
                    Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:huaXiaEmpDic];
                    createEmpName = _emp.emp_name;
                }else{
                    createEmpName = [NSString stringWithFormat:@"\'%@\'",createEmpName];
                }
                
            }
#endif

            
		}
		//	//群聊中除创建者和自己以外的人员的名称
		NSMutableString *otherNames = [NSMutableString stringWithString:@""];
		for(NSString *empId in emps)
		{
			if(empId.intValue != createId && empId.intValue != self.userId.intValue)
			{
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
                NSString *empName = [db getEmpNameByEmpId:empId];

                if ([empName isEqualToString:empId]) {
                    //                没有取到用户名字 需要调用华夏接口
                    
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",[StringUtil getStringValue:mutiableType],@"conv_type", nil];
                    
                    NSDictionary *huaXiaEmpDic = [[HuaXiaOrgUtil getUtil]getHXEmpInfoByEmpId:empId.intValue withUserInfo:userInfo withCompleteHandler:^(NSDictionary *empInfoDic, NSDictionary *userInfo) {
                        
                        Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:empInfoDic];
                        if (_emp) {
                            //                    发出通知给会话列表界面修改某个单聊会话的会话标题
                            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                            [mDic setObject:_emp forKey:@"EMP"];
                            
                            [[NotificationUtil getUtil]sendNotificationWithName:GET_USER_INFO_FROM_HX_NOTIFICATION andObject:nil andUserInfo:mDic];
                        }
                    }];
                    if (huaXiaEmpDic){
                        //马上获取到了Emp
                        Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:huaXiaEmpDic];
                        empName = _emp.emp_name;
                    }else{
                        empName =  [NSString stringWithFormat:@"\'%@\'",empName];
                    }
                }
                [otherNames appendString:empName];
                [otherNames appendString:@","];
#else
                [otherNames appendString:[db getEmpNameByEmpId:empId]];
                [otherNames appendString:@","];
#endif
            }
		}
		if(otherNames.length > 1)
		{
			[otherNames deleteCharactersInRange:NSMakeRange(otherNames.length-1, 1)];
			
            
            //			NSString *msgBody = [NSString stringWithFormat:@"%@邀请你加入了群聊,群聊参与人还有:%@",createEmpName,otherNames];
            //			[LogUtil debug:[NSString stringWithFormat:@"%s,groupTime is %@",__FUNCTION__,groupTime]];
            
			NSString *msgBody = nil;
			if(createId == self.userId.intValue)
			{
				msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_invite_y_join_group"],createEmpName,otherNames];
			}
			else
			{
                //                如果是机组群，那么群组创建通知的内容有所不同
                if ([grpId hasPrefix:@"g"]) {
                    
                    //                    张三、李四、王五、陈六、朱七、郑八、许九加入了20130819CZ7980(深圳-北京)机组群'
                    [otherNames insertString:[NSString stringWithFormat:@"%@,",self.userName] atIndex:0];
                    msgBody = [NSString stringWithFormat:@"%@加入了%@机组群",otherNames,grpName];
                }
                else
                {
                    msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_invite_y_and_z_to_group"],createEmpName,otherNames];
                }
			}
			//			[LogUtil debug:[NSString stringWithFormat:@"%s,groupTime is %@",__FUNCTION__,groupTime]];
            
			//	保存到数据库中
            //		首先查询数据库对应该会话有没有消息记录，如果有就返回时间，否则返回-1
			int earlyMsgTime = -1;
			NSDictionary *_dic = [db getConvMsgTime:grpId andType:0];
			if(_dic)
			{
				earlyMsgTime = [[_dic valueForKey:@"msg_time"]intValue];
			}
			if(earlyMsgTime > 0 && earlyMsgTime < groupTime.intValue)
			{
				[LogUtil debug:[NSString stringWithFormat:@"如果本地保存的群组的最早消息的时间比获取到的群组创建时间要晚，那么就重新计算邀请信息的时间"]];
				groupTime = [StringUtil getStringValue:earlyMsgTime - 1];
			}
            [self saveGroupNotifyMsg:grpId andMsg:msgBody andMsgTime:groupTime];
		}
	}
	
	//		在这里通知会话界面刷新
    eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
    _notificationObject.cmdId = get_group_info_success;
    
    [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

}

#pragma mark ----修改分组成员应答----
-(void)processModifyGroupMember:(MODIMEMBERACK*)info
{
	[self stopTimeoutTimer];
    
	if(info->result == RESULT_SUCCESS)
	{
		NSString* grpId = [StringUtil getStringByCString:info->aszGroupID];
		[LogUtil debug:[NSString stringWithFormat:@"modify group member success grpid is %@",grpId]];
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = modify_group_success;
        _notificationObject.info = [NSDictionary dictionaryWithObjectsAndKeys:grpId,@"GRP_ID",[NSNumber numberWithInt:info->cOpType],@"oper_type",nil];
        
        [[NotificationUtil getUtil]sendNotificationWithName:MODIFYMEBER_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

	}
	else
    {
		[LogUtil debug:[NSString stringWithFormat:@"modify group member failure"]];
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = modify_group_failure;
        
        [[NotificationUtil getUtil]sendNotificationWithName:MODIFYMEBER_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
	}
}

#pragma mark ----修改分组名称应答----
-(void)processModifyGroup:(MODIGROUPACK*)info
{
	[self stopTimeoutTimer];
    
	if(info->result == RESULT_SUCCESS)
	{
        //		自己主动修改群组名称
		NSString* grpId = [StringUtil getStringByCString:info->aszGroupID];
        NSString *newGrpName = [StringUtil getStringByCString:info->aszData];

		[LogUtil debug:[NSString stringWithFormat:@"modify group name success grpid is %@",grpId]];
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = modify_groupname_success;
        _notificationObject.info = [NSDictionary dictionaryWithObject:grpId forKey:@"GRP_ID"];
        
        [[NotificationUtil getUtil]sendNotificationWithName:MODIFYGROUPNAME_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

        [self sendGroupNameModifyNotification:grpId andNewGroupName:newGrpName];

	}
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"modify group name failure"]];
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = modify_groupname_failure;
        
        [[NotificationUtil getUtil]sendNotificationWithName:MODIFYGROUPNAME_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

	}
	
	if(info->result == RESULT_SUCCESS)
	{
		//		自己主动修改群组名称
		NSString* grpId = [StringUtil getStringByCString:info->aszGroupID];
		
		NSString *newGrpName = [StringUtil getStringByCString:info->aszData];
		NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_change_group_name_to_x"],newGrpName];
		
		NSString *operTime = [StringUtil getStringValue:info->dwTime];
		
		[self saveGroupNotifyMsg:grpId andMsg:msgBody andMsgTime:operTime];
		[db updateConversationTime:grpId andTime:info->dwTime];
	}
}

#pragma mark----处理发送消息-----

-(void)processSendMsgAck:(SENDMSGACK*)sendMsgAck
{
	NSString *originMsgId = [NSString stringWithFormat:@"%lld",sendMsgAck->dwMsgID];
    NSDictionary *dic = [db getMsgInfoByOriginMsgId:originMsgId];
    if (dic) {
        NSString *msgId = [StringUtil getStringValue:[[dic valueForKey:@"MSG_ID"]intValue]];
        
        if(sendMsgAck->result == RESULT_SUCCESS)
        {
            [db updateSendFlagByMsgId:msgId andSendFlag:send_success];
            
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = send_msg_success;
            _notificationObject.info = dic;
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
            
        }
        else
        {
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = send_msg_failure;
            
            _notificationObject.info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:sendMsgAck->result],@"result_code", nil];
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
            
            //			消息即使发送失败，也不更改发送状态 update by shisp
           // if (sendMsgAck->result == RESULT_VIRGTOUP_OUTOF_SVC) {
           //     [db updateSendFlagByMsgId:msgId andSendFlag:send_failure];
           // }
        }
    }
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"发送消息通知收到后，没有找到发送消息的记录，对应的消息id为%@",originMsgId]];
	}
}

#pragma mark---收到创建分组通知---

-(void)processCreateGroupNotice:(CREATEGROUPNOTICE *)info
{
	NSString *grpId = [StringUtil getStringByCString:info->aszGroupID];
	
	int createId = info->dwUserID;
	int createTime = info->dwTime;
	
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,createTime is %d",__FUNCTION__,createTime]];
	NSString *grpName = [StringUtil getGrpNameFromCGroupName:info->aszGroupName];
	
    // [LogUtil debug:[NSString stringWithFormat:@"%s,grpName is %@",__FUNCTION__,grpName]];
    
	int empCount = info->wUserNum;
	NSMutableArray *emps = [NSMutableArray arrayWithCapacity:empCount];
	int empId;
	
	//		增加会话成员
	for(int i=0;i<empCount;i++)
	{
		empId = (info->aUserID)[i];
		[emps addObject:[StringUtil getStringValue:empId]];
	}
	
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,群组成员包括：%@",__FUNCTION__,emps]];
	
	[self createGroup:grpId andName:grpName andCreateor:createId andGroupTime:[StringUtil getStringValue:createTime] andEmps:emps];
}

//分组成员变化通知
-(void)processModifyGroupMemberNotice:(MODIMEMBERNOTICE*)info
{
	NSString *grpId = [StringUtil getStringByCString:info->aszGroupID];
	
	if([db searchConversationBy:grpId] == nil)
	{
		[LogUtil debug:[NSString stringWithFormat:@"group is not exists ,grpId is %@",grpId]];
	}
	else
	{
        //		被操作的成员
		NSMutableString *empNames = [NSMutableString string];
		
		int operType = info->cOpType;//0：增加 1：删除
		int empCount = info->wNum;
		
		if(empCount > 0)
		{
			NSMutableArray *convEmps = [NSMutableArray arrayWithCapacity:empCount];
			int empId;
			for(int i=0;i<empCount;i++)
			{
				empId = (info->aUserID)[i];
				[convEmps addObject:[NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",  [StringUtil getStringValue:empId],@"emp_id",nil]];
				NSString *empName = [StringUtil getLocalizableString:@"group_notify_you"];
                //				获取名字
				if(empId != self.userId.intValue)
				{
					empName = [db getEmpNameByEmpId:[StringUtil getStringValue:empId]];
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
                    if ([empName isEqualToString:[StringUtil getStringValue:empId]]) {
//                        没有找到用户
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",[StringUtil getStringValue:mutiableType],@"conv_type", nil];
                        
                        NSDictionary *huaXiaEmpDic = [[HuaXiaOrgUtil getUtil]getHXEmpInfoByEmpId:empId withUserInfo:userInfo withCompleteHandler:^(NSDictionary *empInfoDic, NSDictionary *userInfo) {
                            
                            Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:empInfoDic];
                            if (_emp) {
                                //                    发出通知给会话列表界面修改某个单聊会话的会话标题
                                NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                                [mDic setObject:_emp forKey:@"EMP"];
                                
                                [[NotificationUtil getUtil]sendNotificationWithName:GET_USER_INFO_FROM_HX_NOTIFICATION andObject:nil andUserInfo:mDic];
                            }
                        }];
                        if (huaXiaEmpDic){
                            //马上获取到了Emp
                            Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:huaXiaEmpDic];
                            empName = _emp.emp_name;
                        }else{
                            empName = [NSString stringWithFormat:@"\'%@\'",empName];
                        }

                    }
#endif
				}
				[empNames appendString:empName];
				[empNames appendString:@","];
			}
			
			
			if(operType == 0)
			{
				[LogUtil debug:[NSString stringWithFormat:@"add member %@",convEmps]];
				[db addConvEmp:convEmps];
			}
			else if(operType == 1)
			{
				[LogUtil debug:[NSString stringWithFormat:@"delete member %@",convEmps]];
				[db deleteConvEmp:convEmps];
			}
			
            //			增加群组变化通知
			if(empNames.length > 1)
			{
				[empNames deleteCharactersInRange:NSMakeRange(empNames.length-1, 1)];
                
				//		操作人的名称
				int operEmpId = info->dwModiID;
				NSString *operEmpName = [StringUtil getLocalizableString:@"group_notify_big_you"];
				if(operEmpId != self.userId.intValue)
				{
					operEmpName = [db getEmpNameByEmpId:[StringUtil getStringValue:operEmpId]];
                    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
                    if ([operEmpName isEqualToString:[StringUtil getStringValue:operEmpId]]) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",[StringUtil getStringValue:mutiableType],@"conv_type", nil];
                        
                        NSDictionary *huaXiaEmpDic = [[HuaXiaOrgUtil getUtil]getHXEmpInfoByEmpId:operEmpId withUserInfo:userInfo withCompleteHandler:^(NSDictionary *empInfoDic, NSDictionary *userInfo) {
                            
                            Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:empInfoDic];
                            if (_emp) {
                                //                    发出通知给会话列表界面修改某个单聊会话的会话标题
                                NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                                [mDic setObject:_emp forKey:@"EMP"];
                                
                                [[NotificationUtil getUtil]sendNotificationWithName:GET_USER_INFO_FROM_HX_NOTIFICATION andObject:nil andUserInfo:mDic];
                            }
                        }];
                        if (huaXiaEmpDic){
                            //马上获取到了Emp
                            Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:huaXiaEmpDic];
                            operEmpName = _emp.emp_name;
                        }else{
                            operEmpName = [NSString stringWithFormat:@"\'%@\'",operEmpName];
                        }
                    }
#endif

				}
				//		操作的时间
				NSString *operTime = [StringUtil getStringValue:info->dwTime];
				
				NSString *msgBody = @"";
				if(operType == 0)
				{
					msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_invite_y_join_group"],operEmpName,empNames];
				}
				else
				{
					msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_remove_y_from_group"],operEmpName,empNames];
//                    如果是龙湖版本，那么被移除时需要自动删除群组
                    if ([[eCloudConfig getConfig]supportGuidePages] && [empNames rangeOfString:[StringUtil getLocalizableString:@"group_notify_you"]].length > 0) {
                        //		发出群组成员变化通知
                        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                        _notificationObject.cmdId = removed_from_group;
                        _notificationObject.info = [NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id", nil];
                        
                        [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
                        return;
                    }
				}
				[self saveGroupNotifyMsg:grpId andMsg:msgBody andMsgTime:operTime];
				//		修改群组时间
				[db updateConversationTime:grpId andTime:info->dwTime];
			}
		}
        
        [self sendGroupMemberModifyNotification:grpId];
	}
}

#pragma mark 群组成员变化或某人退出群组，都应该发送群组成员变化通知
-(void)sendGroupMemberModifyNotification:(NSString*)grpId
{
	//		发出群组成员变化通知
    eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
    _notificationObject.cmdId = group_member_change;
    
    [db asynCreateMergedLogoWithConvId:grpId andConvTitle:@"xxx"];
    
    [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:[NSDictionary dictionaryWithObject:grpId forKey:@"conv_id"]];
}

//分组信息修改通知
-(void)processModifyGroupNotice:(MODIGROUPNOTICE*)info
{
	NSString *grpId = [StringUtil getStringByCString:info->aszGroupID];
	
	[LogUtil debug:[NSString stringWithFormat:@"modify group notice ,grpid is %@",grpId]];
	
	int type = info->cType;//0: group name 1:group note
	NSString *newValue = [StringUtil getStringByCString:info->aszData];
	
	if([db searchConversationBy:grpId])
	{
		[db updateConvInfo:grpId andType:type andNewValue:newValue];
		//	谁修改群名为"新群名"
        //操作人
		int operEmpId = info->dwUserID;
		NSString *operEmpName;
		if(self.userId.intValue == operEmpId)
		{
			operEmpName = [StringUtil getLocalizableString:@"group_notify_big_you"];
		}
		else
		{
			operEmpName = [db getEmpNameByEmpId:[StringUtil getStringValue:operEmpId]];
        }
		
		//			发出群组名称修改通知
		[self sendGroupNameModifyNotification:grpId andNewGroupName:newValue];
		
		NSString *operTime = [StringUtil getStringValue:info->dwTime];
		NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_change_group_name_to_y"],operEmpName,newValue];
		[self saveGroupNotifyMsg:grpId andMsg:msgBody andMsgTime:operTime];
		[db updateConversationTime:grpId andTime:info->dwTime];
        
	}
}

#pragma mark 收到群组名称修改通知和获取群组信息成功通知，都发出群名修改通知
-(void)sendGroupNameModifyNotification:(NSString*)grpId andNewGroupName:(NSString*)newValue
{
	//			发出群组名称修改通知
    eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
    _notificationObject.cmdId = group_name_modify;
    
    [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",newValue,@"group_name", nil]];
}

#pragma mark 获取员工信息应答
-(void)processGetUserInfo:(GETEMPLOYEEACK*)info
{
	//	如果type是1表示手动触发，需要发出通知
	int _type = info->nType;
	if(_type == 1)
	{
		[self stopTimeoutTimer];
		self.isGetUserInfoCmd = false;
	}
    
	int empId = -1;
	NSString *name = nil;
    
//    万达版本logo暂时设置为@""
	NSString *logo = @"";
    
	if(info->result == RESULT_SUCCESS)
	{
        NSLog(@"%s,返回成功",__FUNCTION__);
        char *empData = info->strPacketBuff;
        
        EMPLOYEE employee;
        int startPos = 0;
        
        int parseResult = CLIENT_ParseEmploee(empData,&startPos,&employee);
        
        if (parseResult == EIMERR_SUCCESS)
        {
//            NSLog(@"解析成功");
            USERINFO userInfo = employee.tUserInfo;
            
            empId = userInfo.dwUserID;
            
            name = [StringUtil getStringByCString:userInfo.aszCnUserName];
            NSString *empNameEng = [StringUtil getStringByCString:userInfo.aszEnUserName];
            
            NSString *empCode = [StringUtil getStringByCString:userInfo.aszUserCode];

            int sex = userInfo.cSex;
            //		int status = emp->cStatus;
            
            NSString *empAddress = [StringUtil getStringByCString:userInfo.aszAdrr];
            NSString *empPostCode = [StringUtil getStringByCString:userInfo.aszPostcode];
            
            NSString* mail = [StringUtil getStringByCString:userInfo.aszEmail];
            NSString *phone = [StringUtil getStringByCString:userInfo.aszPhone];
            NSString *tel = [StringUtil getStringByCString:userInfo.aszTel];
            
            NSString *empTitle = [StringUtil getStringByCString:userInfo.aszPost];
            
            NSString *empFax = [StringUtil getStringByCString:userInfo.aszFax];

            USERINFOExtend userInfoExt = employee.tUserExtend;
            
            NSString *signature =  [StringUtil getStringByCString:userInfoExt.aszSign];
            NSString *sCompId = [[NSUserDefaults standardUserDefaults]valueForKey:@"COMP_ID"];
            NSString *hometel= [StringUtil getStringByCString:userInfoExt.aszHomeTel];
            NSString *emergencytel= [StringUtil getStringByCString:userInfoExt.aszEmergencyphone];
            
            //        增加生日，传真，地址，邮编，英文姓名
            int birthday = userInfoExt.dwBirth;
            
//            add by shisp 下载用户资料后，不保存时间戳，也不下载用户头像
            
            //        logo,@"emp_logo",
//          update by shisp 把头像的时间戳保存在emp_logo列里，用户自己和其它联系人同样处理
//            NSString *empLogo = [StringUtil getStringValue:userInfoExt.dwLogoUpdateTime];
//            if (empLogo == nil || empLogo.length == 0) {
//                empLogo = @"0";
//            }
            //如果是自动获取用户资料的，那么就去检查下头像，如果没有就下载
//            如果是当前登录用户，则不判断头像 add by shisp
//            if(_type == 0 && (empId != _conn.userId.intValue))
//            {
//                [StringUtil downloadUserLogo:[StringUtil getStringValue:empId] andLogo:empLogo andNeedSaveUrl:false];
//            }

//            update by shisp empLogo保持不变
            NSString *empLogo = @"0";
            NSArray *_empArray = [self getEmpByEmpId:empId];
            for(Emp *_emp in _empArray)
            {
                _emp.emp_sex = sex;
                _emp.emp_name = name;
                //                update by shisp 为了减少内存，不必要的数据不在内存中保存
                //                _emp.emp_mail = mail;
                //                _emp.emp_mobile = phone;
                //                _emp.emp_tel = tel;
                //                _emp.emp_logo = empLogo;
                //                _emp.signature = signature;
                //                _emp.titleName = empTitle;
                //                _emp.emp_hometel = hometel;
                //                _emp.emp_emergencytel = emergencytel;
                _emp.empCode = empCode;
                
                //                _emp.birthday = birthday;
                //                _emp.empFax = empFax;
                //                _emp.empAddress = empAddress;
                //                _emp.empPostCode = empPostCode;
                _emp.empNameEng = empNameEng;
                
                empLogo = _emp.emp_logo;
            }

            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:empId],@"emp_id",[StringUtil getStringValue:sex],@"emp_sex",name,@"emp_name",empCode,@"emp_code",mail,@"emp_mail",phone,@"emp_mobile",tel,@"emp_tel",hometel,@"emp_hometel",emergencytel,@"emp_emergencytel",@"Y",@"emp_info_flag",empTitle,@"emp_title",signature,@"emp_signature",sCompId,@"emp_comp_id",[StringUtil getStringValue:birthday],@"emp_birthday",empFax,@"emp_fax",empAddress,@"emp_address",empPostCode,@"emp_postcode",empNameEng,@"emp_name_eng",empLogo,@"emp_logo", nil];
            
            //		首先更新内存中的数据
            
            //		如果本地包含则修改，否则增加
            if([db searchEmp:[StringUtil getStringValue:empId]])
            {
                [db updateEmp:[NSArray arrayWithObject: dic]];
            }
            else
            {
                [db addEmp:[NSArray arrayWithObject:dic]];
            }
            
//            NSLog(@"保存成功");
            
            if (empId == self.userId.intValue) {
                [LogUtil debug:@"获取到当前用户资料后进行保存"];
                self.curUser = [db getEmpInfo:self.userId];
                [userDb saveCurUserInfoUpdateTime];
//                保存用户工号到内存
                _conn.user_code = empCode;
                
//                获取了当前用户资料后，也发送通知处理
//                [[NotificationUtil getUtil]sendNotificationWithName:GET_CURUSERINFO_NOTIFICATION andObject:nil andUserInfo:nil];
                
                //  同步组织架构前 同步应用
                if ([eCloudConfig getConfig].needApplist) {
                    //同步应用列表
                    dispatch_queue_t _queue = dispatch_queue_create("Sync App List", NULL);
                    dispatch_async(_queue, ^{
                        [_conn syncAppList];
                    });
                }
            }
            else
            {
                NSLog(@"empId is %d",empId);
                eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                _notificationObject.cmdId = get_user_info_success_new;
                _notificationObject.info = [NSDictionary dictionaryWithObject:[StringUtil getStringValue:empId] forKey:@"EMP_ID"];
                
                [[NotificationUtil getUtil]sendNotificationWithName:GETUSERINFO_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
            }
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"解析用户资料失败"]];
            
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = get_user_info_failure_new;
            
            [[NotificationUtil getUtil]sendNotificationWithName:GETUSERINFO_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        }
	}
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"get user info failure"]];

        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = get_user_info_failure_new;
        
        [[NotificationUtil getUtil]sendNotificationWithName:GETUSERINFO_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

	}
}

#pragma mark---处理接收消息------

-(void)processRcvMsg:(MsgNotice*)msgNotice
{
    [self setUserStatusToOnlineIfNotOnline:msgNotice];
//    在入库成功后 如果在后台运行 则生成本地通知
//    [self createLocalNotification:msgNotice];
    //	取出一呼百应消息的标志
    
    int iReceiptMsgFlag = msgNotice.receiptMsgFlag;
    
    if(msgNotice.isMassMsg)
    {
        NewMsgNotice *_notice = [MassConn saveReplyMessage:msgNotice];
        if(_notice)
        {
            
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = rev_msg;
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:_notice, @"msg_notice",nil]];
            
            [self sendRcvMsgAckWithMsgId:[NSNumber numberWithLongLong:msgNotice.msgId].longLongValue andNetId:[NSNumber numberWithInt:msgNotice.netID].intValue];
        }

        //		return;
    }
    
    NSString *sReceiptMsgFlag = [StringUtil getStringValue:iReceiptMsgFlag];
    
    //	如果离线消息还没有处理完毕，那么进行以下处理
    
    int iOffline = msgNotice.isOffline;
    
    //    是马上保存消息还是加到离线消息数组 yes是马上保存，no是需要加到离线消息数组
    BOOL saveToOfflineMsgArray = NO;
    
    //    是否需要发送离线消息已经收取完毕
    BOOL needSendOfflineMsgFinish = NO;
    
    //    是否需要把保存 还没有本地还没有创建群组 的消息
    BOOL needSaveIncompleteReceiptMsg = NO;

    //        如果是离线消息，那么计数加1 保存总数
    self.offlineMsgTotal = msgNotice.offMsgTotal;
    if(iOffline == 1 && self.offlineMsgTotal > 0)
    {
        if (!self.isOfflineMsgFinish) {
            saveToOfflineMsgArray = YES;
        }
        
        self.offlineMsgCurCount++;
        
        if (self.offlineMsgCurCount == self.offlineMsgTotal) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 离线消息数量为%d，当前收到的离线消息数量为%d ",__FUNCTION__,self.offlineMsgTotal,self.offlineMsgCurCount]];
            [self performSelectorOnMainThread:@selector(cancelOfflineMsgTimer) withObject:nil waitUntilDone:YES];
        }
        else
        {
            //			重新计算超时
            [self performSelectorOnMainThread:@selector(cancelOfflineMsgTimer) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(processRcvOfflineMsgTimeout:) withObject:[NSNumber numberWithInt:5] waitUntilDone:YES];
        }
    }
    
    //    如果还没有发送离线消息结束 并且已经收完了所有的离线消息 才发送离线消息收取完毕通知
    if(!self.isOfflineMsgFinish && self.offlineMsgTotal > 0 && self.offlineMsgCurCount == self.offlineMsgTotal)
    {
        needSendOfflineMsgFinish = YES;
    }
    
    // 若为一呼万应消息，发送接收离线消息通知
    if(msgNotice.isMassMsg)
    {
        if (needSendOfflineMsgFinish) {
            [self sendRcvOfflineMsgFinishNotify];
        }
        return;
    }

    
    notificationName = CONVERSATION_NOTIFICATION;
	NSString *convId = @"";
	
	NSString* senderId = [StringUtil getStringValue: msgNotice.senderId];
	NSString* sendTime =  [StringUtil getStringValue: msgNotice.msgTime];
	NSString* msgType =  [StringUtil getStringValue: msgNotice.msgType];
	
    //	为了发送已读消息通知，需要在数据库中记录原始消息的消息id
	NSString* originMsgId = [NSString stringWithFormat:@"%lld",msgNotice.msgId];
    //	[LogUtil debug:[NSString stringWithFormat:@"originMsgId is %@",originMsgId]];
    NSLog(@"lyanlyan=====%@",msgNotice.msgBody);
    
	NSString *msgStr = @"";
	NSString *fileName = @"";
	NSString *fileSize = @"";
	
	NSString* msgId;
    
    //	add by shisp 如果同步消息，那么收到的消息有可能是其它客户端发送的消息，所以定义以下两个字段，如果发消息的人的id如果是自己，那么是发送消息，并且是已读
    NSString *sReadFlag = @"1";
    NSString *sMsgFlag = [StringUtil getStringValue:rcv_msg];
    NSString *sSendFlag = [StringUtil getStringValue:send_success];
    //	是否提示用户，默认提示，当msgTotal为1时，不提示
    bool *alertUser = true;
    if(msgNotice.msgTotal == 1)
    {
        alertUser = false;
    }
    else if(msgNotice.msgTotal == 2)
    {
        alertUser = false;
        sReadFlag = @"0";
    }
    
    //同步自己的消息
    if([senderId isEqualToString:self.userId])
    {
        sReadFlag = @"0";
        sMsgFlag = [StringUtil getStringValue:send_msg];
    }
	
    //	群组是否接收并提示消息
	BOOL groupRcvMsgFlag = YES;
	
	int cIsGroup = msgNotice.isGroup;
	if(cIsGroup == 0)
	{//单聊
		if([senderId isEqualToString:self.userId])
		{
			convId = [StringUtil getStringValue:msgNotice.rcvId];
		}
		else
		{
			convId = senderId;
		}
	}
    //    普通群组或固定群组
    else if (cIsGroup == 1 || cIsGroup == 2)
	{//群聊
		convId = msgNotice.groupId;
	}
    
    //	先判断群组有没有创建，如果没创建就先创建群组
	if(cIsGroup == 0 && msgNotice.needCreateSingleConv)
	{//单聊
		//			convId = senderId;
		//		要查看下会话表里是否有对应的会话，如果没有那么要增加会话
		
        NSDictionary *empInfo = nil;
        if (msgNotice.isEncryptMsg) {
            empInfo = [db searchConversationBy:msgNotice.groupId];
        }else{
            empInfo = [db searchConversationBy:convId];
        }
        
        //		add by shisp 测试代码
        //		if(empInfo)
        //		{
        //			[db deleteConvAndConvRecordsBy:convId];
        //		}
        //
        //		empInfo = nil;
		
		if(empInfo == nil)
		{
			//			首先看下这个用户是否存在，存在就增加会话
			empInfo = [db searchEmp:convId];
			
            //			add by shisp 测试代码
            //			if(empInfo)
            //			{
            //				[db delEmps:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:convId forKey:@"emp_id"]]];
            //			}
            //
            //			empInfo = nil;
			NSString *convType = [StringUtil getStringValue:singleType];
			
			//				不屏蔽
			NSString *recvFlag = [StringUtil getStringValue:open_msg];
			if(empInfo)
			{
                NSDictionary *dic = nil;
                if (msgNotice.isEncryptMsg) {
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:msgNotice.groupId,@"conv_id",convType,@"conv_type",[empInfo objectForKey:@"emp_name"],@"conv_title",recvFlag,@"recv_flag",senderId,@"create_emp_id",[self getSCurrentTime],@"create_time", nil];
                    convId = msgNotice.groupId;
                }else{
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",convType,@"conv_type",[empInfo objectForKey:@"emp_name"],@"conv_title",recvFlag,@"recv_flag",senderId,@"create_emp_id",[self getSCurrentTime],@"create_time", nil];
                }

                [db addConversation:[NSArray arrayWithObject:dic]];
                [[talkSessionUtil2 getTalkSessionUtil]createMiliaoTips:convId andTipsTime:(msgNotice.msgTime - 5)];
			}
			else
			{
				[LogUtil debug:[NSString stringWithFormat:@"单聊用户不存在，需要主动获取用户资料"]];
//                如果是华夏幸福那么调用华夏幸福的接口获取用户资料
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",convType,@"conv_type", nil];
                
                NSDictionary *huaXiaEmpDic = [[HuaXiaOrgUtil getUtil]getHXEmpInfoByEmpId:convId.intValue withUserInfo:userInfo withCompleteHandler:^(NSDictionary *empInfoDic, NSDictionary *userInfo) {
                    
                    Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:empInfoDic];
                    if (_emp) {
                        //                    发出通知给会话列表界面修改某个单聊会话的会话标题
                        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                        [mDic setObject:_emp forKey:@"EMP"];
                        
                        [[NotificationUtil getUtil]sendNotificationWithName:GET_USER_INFO_FROM_HX_NOTIFICATION andObject:nil andUserInfo:mDic];
                    }
                }];
                if (huaXiaEmpDic){
//马上获取到了Emp
                    Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:huaXiaEmpDic];
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",convType,@"conv_type",_emp.emp_name,@"conv_title",recvFlag,@"recv_flag",senderId,@"create_emp_id",[self getSCurrentTime],@"create_time", nil];
                    [db addConversation:[NSArray arrayWithObject:dic]];

                }else{
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",convType,@"conv_type",convId,@"conv_title",recvFlag,@"recv_flag",senderId,@"create_emp_id",[self getSCurrentTime],@"create_time", nil];
                    
                    [db addConversation:[NSArray arrayWithObject:dic]];
                }

#else
                [self getUserInfoAuto:convId.intValue];
                NSDictionary *dic = nil;
                if (msgNotice.isEncryptMsg) {
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:msgNotice.groupId,@"conv_id",convType,@"conv_type",convId,@"conv_title",recvFlag,@"recv_flag",senderId,@"create_emp_id",[self getSCurrentTime],@"create_time", nil];
                    convId = msgNotice.groupId;
                }else{
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",convType,@"conv_type",convId,@"conv_title",recvFlag,@"recv_flag",senderId,@"create_emp_id",[self getSCurrentTime],@"create_time", nil];
                }
                [db addConversation:[NSArray arrayWithObject:dic]];
#endif
            }
		}
		else
		{//增加判断会话是否处于关闭状态，如果关闭，则打开
			if([[empInfo objectForKey:@"display_flag"] intValue] == 1)
			{
                if (msgNotice.isEncryptMsg) {
                    [db updateDisplayFlag:msgNotice.groupId andFlag:0];
                    convId = msgNotice.groupId;
                }else{
                    [db updateDisplayFlag:convId andFlag:0];
                }
            }else{
                if (msgNotice.isEncryptMsg) {
                    convId = msgNotice.groupId;
                }
            }
		}
	}
	else if (cIsGroup == 1 || cIsGroup == 2)
	{
		if(![db userExistInConvEmp:convId] && cIsGroup == 1)
		{
			//	收到群组消息，如果自己不在群中，那么把自己加到群组成员中
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",self.userId,@"emp_id",nil];
			[db addConvEmp:[NSArray arrayWithObject:dic]];
			
			[self sendGroupMemberModifyNotification:convId];
		}
		//			convId = groupId;
		NSDictionary *dic = [db searchConversationBy:convId];
		if(dic == nil && cIsGroup == 1)
		{
			[LogUtil debug:[NSString stringWithFormat:@"群组还没有创建，还没有收到创建群组通知，首先在本地先创建一个会话"]];
			[LogUtil debug:[NSString stringWithFormat:@"群组消息对应的时间是%d", msgNotice.msgTime]];
#pragma mark 如果本地还没有创建群组，那么先根据这条消息，先创建一个群组，需要把消息内容作为群组的标题
			
//            根据消息内容
			NSString *grpName = nil;
			if(msgType.intValue == type_text)
			{
				if(msgNotice.msgLen == 0 )
				{
					[LogUtil debug:[NSString stringWithFormat:@"消息长度为空"]];
                    
					if(needSendOfflineMsgFinish)
					{
						[self sendRcvOfflineMsgFinishNotify];
					}
					
					return;
				}
				
				grpName = msgNotice.msgBody;
			}
			else if(msgType.intValue == type_pic)
			{
				grpName = [StringUtil getLocalizableString:@"msg_type_pic"];
			}
			else if(msgType.intValue == type_record)
			{
				grpName = [StringUtil getLocalizableString:@"msg_type_record"];
			}
            else if(msgType.intValue == type_video)
            {
                grpName = [StringUtil getLocalizableString:@"msg_type_video"];
            }
            else if (msgType.intValue == type_file)
            {
                grpName = msgNotice.fileName;
            }
            else if (msgType.intValue == type_long_msg)
            {
                grpName = msgNotice.fileName;
            }
            else if(msgType.intValue == type_imgtxt)
            {
                grpName = [StringUtil getLocalizableString:@"msg_type_imgtxts"];
            }
            else if(msgType.intValue == type_wiki)
            {
                grpName = [StringUtil getLocalizableString:@"msg_type_wiki"];
            }
            
            if (!grpName) {
                grpName = @"";
            }

            //				多人会话
            NSString *convType = [StringUtil getStringValue:mutiableType];
            //				不屏蔽
            NSString *recvFlag = [StringUtil getStringValue:open_msg];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 convId,@"conv_id",
                                 convType,@"conv_type",
                                 grpName,@"conv_title",
                                 recvFlag,@"recv_flag",
                                 @"0",@"create_emp_id",
                                 @"",@"create_time",nil];
            //								 [StringUtil getStringValue:msgNotice.senderId],@"create_emp_id",
            //								 [self getSCurrentTime],@"create_time",nil];
            [db addConversation:[NSArray arrayWithObject:dic]];
            
            [LogUtil debug:[NSString stringWithFormat:@"从服务器端取群组信息数据"]];
            
            if (cIsGroup == 2) {
//                是固定群组，不用去获取群组资料
            }
            else
            {
                if (saveToOfflineMsgArray) {
                    [LogUtil debug:[NSString stringWithFormat:@"离线消息 不去 获取群组资料 收完后 再获取 %@",convId]];
                }else{
                    [LogUtil debug:[NSString stringWithFormat:@"在线消息，从服务器端取群组信息数据 %@",convId]];
                    [self getGroupInfo:convId];
//                龙湖要求修改回来，默认还是提醒
//                    if ([UIAdapterUtil isHongHuApp]) {
////                        非文本消息 或者是文本消息并且不是@消息，那么不提醒
//                        if (msgType.intValue != type_text || (![StringUtil isAtLoginUser:msgNotice.msgBody] && ![StringUtil isAtAllMsg:msgNotice.msgBody])) {
//                            alertUser = false;
//                        }
//                    }
                }
            }
		}
		else
		{
			if([[dic objectForKey:@"display_flag"] intValue] == 1)
			{
                //				[LogUtil debug:[NSString stringWithFormat:@"close status"]];
                
				[db updateDisplayFlag:convId andFlag:0];
			}
			if([[dic valueForKey:@"recv_flag"]intValue] == 1)
            {
                groupRcvMsgFlag = NO;
                //	如果屏蔽了群消息，那么不提示用户
                //	如果屏蔽了群消息，那么收到的消息默认为已读
                
                //                龙湖要求修改回来，默认还是提醒
                
                //                    //                        非文本消息 或者是文本消息并且不是@消息，那么不提醒
                if (msgType.intValue != type_text || (![StringUtil isAtLoginUser:msgNotice.msgBody] && ![StringUtil isAtAllMsg:msgNotice.msgBody])) {
                    alertUser = false;
                }
            }
		}
        
        //        需要判断一下群组成员，如果只有用户资料，那么就要特殊处理一下
        if (sMsgFlag.intValue == send_msg) {
            if (iReceiptMsgFlag == conv_status_huizhi || iReceiptMsgFlag == conv_status_receipt) {
                
                int convEmpCount = [db getAllConvEmpNumByConvId:convId];
                if (convEmpCount <= 1) {
                    [LogUtil debug:[NSString stringWithFormat:@"本条消息是同步过来的钉消息，并且群组资料还未获取"]];
                    needSaveIncompleteReceiptMsg = YES;
                    
                    if (!self.incompleteReceiptMsgArray) {
                        self.incompleteReceiptMsgArray = [NSMutableArray array];
                    }
                }
            }
        }
        
	}
	
	if(msgType.intValue == type_text)
	{
		if(msgNotice.msgLen == 0 )
		{
			[LogUtil debug:[NSString stringWithFormat:@"消息长度为空"]];
            if(needSendOfflineMsgFinish)
            {
                [self sendRcvOfflineMsgFinishNotify];
            }
            
            return;
		}
		
        /*从后10位开始截取，过滤掉字体信息*/
		msgStr = msgNotice.msgBody;
        //		[LogUtil debug:[NSString stringWithFormat:@"收到的消息为：%@",msgStr]];
		
        //        msgStr = [StringUtil getStringByCString:msgNotice->aszMessage];//不截取10个字长
		
        //		如果是文本消息 不能直接入库，要看下有没有pc端发来的截图
		NSMutableArray *array = [NSMutableArray array];
		
        if (msgNotice.robotResponseModel) {
            array = [NSMutableArray arrayWithObject:msgStr];
        }else{
            [StringUtil seperateMsg:msgStr andImageArray:array];
        }
        //		NSLog(@"%@",array.description);
        
		NSMutableString *mMessage = [NSMutableString string];
		NSString *imageName = @"";
		NSString *imageUrl = @"";
		NSDictionary *dic;
		if([array count] >= 1)
		{
            //			[LogUtil debug:[NSString stringWithFormat:@"---count >=%d",[array count]]];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			int _count = [array count];
			for(NSString *str in array)
			{
                dic = nil;
				if([str hasPrefix:PC_CROP_PIC_START] && [str hasSuffix:PC_CROP_PIC_END])
				{
					imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
					imageUrl = imageName;
					NSRange range = [imageName rangeOfString:@"." options:NSBackwardsSearch];
					if(range.length > 0)
					{
						imageUrl = [imageName substringWithRange:NSMakeRange(0,range.location)];
					}
					if(imageUrl.length > 0)
					{
                        //					把图片消息插入到会话记录中，目前pc没有传文件大小，并且通知
						dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",senderId,@"emp_id",[StringUtil getStringValue:type_pic],@"msg_type",imageUrl,@"msg_body",sendTime,@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag", imageName,@"file_name",@"0",@"file_size",
                               //							   update by shisp 为了能够还原原始的消息id，发送已读通知，originmsgid的格式修改如下 originmsgid|count
							   [NSString stringWithFormat:@"%lld|%d",originMsgId.longLongValue,_count],@"origin_msg_id",
                               //							   [NSString stringWithFormat:@"%lld",(originMsgId.longLongValue - _count)],@"origin_msg_id",
							   msgNotice.msgGroupTime,@"msg_group_time",sReceiptMsgFlag,@"receipt_msg_flag",[NSNumber numberWithLongLong:msgNotice.msgId],@"rcv_msg_id",[NSNumber numberWithInt:msgNotice.netID],@"rcv_net_id",msgNotice,@"msg_notice", nil];
                        
					}
				}
				else
				{
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",senderId,@"emp_id",[StringUtil getStringValue:type_text],@"msg_type",str,@"msg_body",sendTime,@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag", @"",@"file_name",@"0",@"file_size",
                           [NSString stringWithFormat:@"%lld|%d",originMsgId.longLongValue,_count],@"origin_msg_id",
                           msgNotice.msgGroupTime,@"msg_group_time",sReceiptMsgFlag,@"receipt_msg_flag",[NSNumber numberWithLongLong:msgNotice.msgId],@"rcv_msg_id",[NSNumber numberWithInt:msgNotice.netID],@"rcv_net_id",msgNotice,@"msg_notice", nil];
				}
				_count--;
                
                if(dic)
                {
                    if (needSaveIncompleteReceiptMsg) {
                        [self.incompleteReceiptMsgArray addObject:dic];
                    }
                    if (saveToOfflineMsgArray) {
                        [self.offlineMsgArray addObject:dic];
                    }
                    else
                    {
                        NSDictionary *_dic = [db addConvRecord:[NSArray arrayWithObject:dic]];
                        if(_dic)
                        {
                            msgId = [_dic valueForKey:@"msg_id"];
                        }
                        else
                        {
                            msgId = nil;
                        }
                        
                        if(msgId)
                        {//通知页面更新
                            [self sendMsgNotice2:msgId andConvId:convId andAlert:alertUser];
                            
//                            广播消息测试代码
//                            {
//                                //                            同时保存到广播里
//                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:senderId,@"sender_id",self.userId,@"recver_id",originMsgId,@"msg_id",sendTime,@"sendtime",@"0",@"msglen",[NSString stringWithFormat:@"广播%@",originMsgId],@"asz_titile",str,@"asz_message", nil];
//                                
//                                [db saveBroadcast:[NSArray arrayWithObject:dic]];
//                            }
                        }
                    }
                }
			}
//            if(needSendOfflineMsgFinish)
//            {
//                [self sendRcvOfflineMsgFinishNotify];
//            }
            
            [pool release];
            
//			return;
		}
	}
	
    //	增加接收保存通知长消息
	else if(msgType.intValue == type_long_msg)
	{
		if(msgNotice.msgLen == 0 )
		{
			[LogUtil debug:[NSString stringWithFormat:@"消息长度为空"]];
            if(needSendOfflineMsgFinish)
            {
                [self sendRcvOfflineMsgFinishNotify];
            }
            
			return;
		}
        //		长消息字节数
		int iFileSize = msgNotice.fileSize;
        //		长消息文件url
		msgStr = msgNotice.msgBody;
        //		长消息头部
		NSString *messageHead = msgNotice.fileName;
        
		if(msgStr && [msgStr length] > 0)
		{
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",senderId,@"emp_id",msgType,@"msg_type",msgStr,@"msg_body",sendTime,@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag", messageHead,@"file_name",[StringUtil getStringValue:iFileSize],@"file_size",originMsgId,@"origin_msg_id",@"0",@"is_set_redstate",msgNotice.msgGroupTime,@"msg_group_time",sReceiptMsgFlag,@"receipt_msg_flag",[NSNumber numberWithLongLong:msgNotice.msgId],@"rcv_msg_id",[NSNumber numberWithInt:msgNotice.netID],@"rcv_net_id",msgNotice,@"msg_notice",nil];
			
            if (needSaveIncompleteReceiptMsg) {
                [self.incompleteReceiptMsgArray addObject:dic];
            }
            if (saveToOfflineMsgArray) {
                [self.offlineMsgArray addObject:dic];
            }
            else
            {
                NSDictionary *_dic = [db addConvRecord:[NSArray arrayWithObject:dic]];
                if(_dic)
                {
                    msgId = [_dic valueForKey:@"msg_id"];
                }
                else
                {
                    msgId = nil;
                }
                if(msgId)
                {
                    [self sendMsgNotice2:msgId andConvId:convId andAlert:alertUser];
                }
            }
		}
//        if(needSendOfflineMsgFinish)
//        {
//            [self sendRcvOfflineMsgFinishNotify];
//        }
	}
    //	增加处理文件类型，和图片，录音同样处理
	else if(msgType.intValue == type_pic || msgType.intValue == type_record || msgType.intValue == type_file || msgType.intValue == type_video)//	如果是图片消息，那么需要解析收到的消息内容，把fileUrl解析出来
	{
		int iFileSize = msgNotice.fileSize;
		
		fileName = msgNotice.fileName;
		msgStr = msgNotice.msgBody;
		if(msgType.intValue == type_pic && !([[RobotDAO getDatabase]getRobotId] == msgNotice.senderId))//[[RobotDAO getDatabase]isRobotUser:msgNotice.senderId]
		{
			fileName = [NSString stringWithFormat:@"%@.png",msgStr];
		}
		if(msgStr && [msgStr length] > 0)
		{
			NSString *sRedState = @"1";
			if([senderId isEqualToString:self.userId])
			{
				sRedState = @"0";
			}
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",senderId,@"emp_id",msgType,@"msg_type",msgStr,@"msg_body",sendTime,@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag", fileName,@"file_name",[StringUtil getStringValue:iFileSize],@"file_size",originMsgId,@"origin_msg_id",sRedState,@"is_set_redstate",msgNotice.msgGroupTime,@"msg_group_time",sReceiptMsgFlag,@"receipt_msg_flag",[NSNumber numberWithLongLong:msgNotice.msgId],@"rcv_msg_id",[NSNumber numberWithInt:msgNotice.netID],@"rcv_net_id",msgNotice,@"msg_notice",nil];
            
            if (needSaveIncompleteReceiptMsg) {
                [self.incompleteReceiptMsgArray addObject:dic];
            }
            if (saveToOfflineMsgArray) {
                [self.offlineMsgArray addObject:dic];
            }
            else
            {
                NSDictionary *_dic = [db addConvRecord:[NSArray arrayWithObject:dic]];
                if(_dic)
                {
                    msgId = [_dic valueForKey:@"msg_id"];
                }
                else
                {
                    msgId = nil;
                }
                if(msgId)
                {
                    [self sendMsgNotice2:msgId andConvId:convId andAlert:alertUser];
                }
            }
		}
//        if(needSendOfflineMsgFinish)
//        {
//            [self sendRcvOfflineMsgFinishNotify];
//        }
	}else if (msgNotice.msgType == type_recall_msg){
        [[MsgConn getConn]processMsgCancelNotice:msgNotice];
    }
    else if(msgType.intValue == type_imgtxt || msgType.intValue == type_wiki)
    {
        if(msgNotice.msgLen == 0 )
        {
            [LogUtil debug:[NSString stringWithFormat:@"消息长度为空"]];
            if(needSendOfflineMsgFinish)
            {
                [self sendRcvOfflineMsgFinishNotify];
            }
            
            return;
        }
        
        /*从后10位开始截取，过滤掉字体信息*/
        msgStr = msgNotice.msgBody;
        
        //		如果是文本消息 不能直接入库，要看下有没有pc端发来的截图
        NSMutableArray *array = [NSMutableArray array];
        
        [StringUtil seperateMsg:msgStr andImageArray:array];
        
        NSMutableString *mMessage = [NSMutableString string];
        NSString *imageName = @"";
        NSString *imageUrl = @"";
        NSDictionary *dic;
        if([array count] >= 1)
        {
            //			[LogUtil debug:[NSString stringWithFormat:@"---count >=%d",[array count]]];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            int _count = [array count];
            for(NSString *str in array)
            {
                dic = nil;
                if([str hasPrefix:PC_CROP_PIC_START] && [str hasSuffix:PC_CROP_PIC_END])
                {
                    imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
                    imageUrl = imageName;
                    NSRange range = [imageName rangeOfString:@"." options:NSBackwardsSearch];
                    if(range.length > 0)
                    {
                        imageUrl = [imageName substringWithRange:NSMakeRange(0,range.location)];
                    }
                    if(imageUrl.length > 0)
                    {
                        //					把图片消息插入到会话记录中，目前pc没有传文件大小，并且通知
                        dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",senderId,@"emp_id",[StringUtil getStringValue:type_pic],@"msg_type",imageUrl,@"msg_body",sendTime,@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag", imageName,@"file_name",@"0",@"file_size",
                               //							   update by shisp 为了能够还原原始的消息id，发送已读通知，originmsgid的格式修改如下 originmsgid|count
                               [NSString stringWithFormat:@"%lld|%d",originMsgId.longLongValue,_count],@"origin_msg_id",
                               //							   [NSString stringWithFormat:@"%lld",(originMsgId.longLongValue - _count)],@"origin_msg_id",
                               msgNotice.msgGroupTime,@"msg_group_time",sReceiptMsgFlag,@"receipt_msg_flag",[NSNumber numberWithLongLong:msgNotice.msgId],@"rcv_msg_id",[NSNumber numberWithInt:msgNotice.netID],@"rcv_net_id",msgNotice,@"msg_notice", nil];
                        
                    }
                }
                else
                {
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",senderId,@"emp_id",[StringUtil getStringValue:type_text],@"msg_type",str,@"msg_body",sendTime,@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag", @"",@"file_name",@"0",@"file_size",
                           [NSString stringWithFormat:@"%lld|%d",originMsgId.longLongValue,_count],@"origin_msg_id",
                           msgNotice.msgGroupTime,@"msg_group_time",sReceiptMsgFlag,@"receipt_msg_flag",[NSNumber numberWithLongLong:msgNotice.msgId],@"rcv_msg_id",[NSNumber numberWithInt:msgNotice.netID],@"rcv_net_id",msgNotice,@"msg_notice", nil];
                }
                _count--;
                
                if(dic)
                {
                    if (needSaveIncompleteReceiptMsg) {
                        [self.incompleteReceiptMsgArray addObject:dic];
                    }
                    if (saveToOfflineMsgArray) {
                        [self.offlineMsgArray addObject:dic];
                    }
                    else
                    {
                        NSDictionary *_dic = [db addConvRecord:[NSArray arrayWithObject:dic]];
                        if(_dic)
                        {
                            msgId = [_dic valueForKey:@"msg_id"];
                        }
                        else
                        {
                            msgId = nil;
                        }
                        
                        if(msgId)
                        {//通知页面更新
                            [self sendMsgNotice2:msgId andConvId:convId andAlert:alertUser];
                        }
                    }
                }
            }
            
            [pool release];
        }
    }
    
//    else
//    {
        if(needSendOfflineMsgFinish)
        {
            [self sendRcvOfflineMsgFinishNotify];
        }
//    }
}

//增加会话id参数，增加是否提醒用户参数
-(void)sendMsgNotice2:(NSString *)msgId andConvId:(NSString *)convId andAlert:(bool)isAlert
{
    //	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msg_id",convId,@"conv_id", nil];
	if(self.isOfflineMsgFinish)
	{
        //		[LogUtil debug:[NSString stringWithFormat:@"%s 发出收消息通知：%@",__FUNCTION__, msgId]];
		if(isAlert)
		{
            settingRemindController *remindController = [settingRemindController initSettingRemind];
			if([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive)
			{
                //                如果为空或者和当前的不一致
                if(self.curConvId == nil || ![self.curConvId isEqualToString:convId])
                {
                    remindController.soundFlag = 1;
                }
                else
                {
                    remindController.soundFlag = 2;
                }
                
				[remindController checkRemindType];
			}
		}
        
        NewMsgNotice *_notice = [[[NewMsgNotice alloc]init]autorelease];
        _notice.convId = convId;
        _notice.msgId = msgId;
        _notice.msgType = normal_new_msg_type;

        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = rev_msg;
        
        [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:_notice, @"msg_notice",nil]];

        //		休眠5ms
        //		[NSThread sleepForTimeInterval:0.005];
	}
	else
	{
		[self.offLineMsgs addObject:dic];
	}
}

#pragma mark 已经处理完离线消息通知，包括离线消息为0，全部获取离线消息，离线消息获取超时三种情况
-(void)sendRcvOfflineMsgFinishNotify
{
#pragma mark 发出 收取离线消息过程中收到的消息没有及时发出通知，离线消息处理完毕后，需要及时发出这些消息通知，用以会话界面和聊天界面更新
	if(!self.isOfflineMsgFinish)
	{
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

        if (self.userStatus == status_offline) {
            
            [self.offlineMsgArray removeAllObjects];
            [self.offLineMsgs removeAllObjects];
            self.isOfflineMsgFinish = true;
            
            [self getAllDeptId];
            [self getAllEmpArray];

            self.connStatus = not_connect_type;
            
            [LogUtil debug:@"保存离线消息完毕的时候，发现用户已经离线了，这时把离线消息清空"];
            return;
        }
        
        //    判断有没有还没有保存的离线消息，如果有则一起保存
        if (self.offlineMsgArray.count > 0) {
            [db saveOfflineMsgs:self.offlineMsgArray];
        }
        
        //        保存撤回的离线消息
        [[MsgConn getConn]saveOfflineRecallMsgs];
        
//        发送通知，更新会话列表
        
        NSMutableDictionary *offlineConvIdDic = [NSMutableDictionary dictionary];
        for (NSDictionary *dic in self.offlineMsgArray) {
            NSString *convId = dic[@"conv_id"];
            if (!offlineConvIdDic[convId]) {
//                保证一个会话的多条消息当成一条来处理
                offlineConvIdDic[convId] = @"1";
            }else{
                NSLog(@"convid is %@ 已经保存",convId);
            }
        }
        
        for (NSString *convId in offlineConvIdDic.allKeys) {
            NSDictionary *notiDic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
            [[eCloudDAO getDatabase] sendNewConvNotification:notiDic andCmdType:add_new_conversation];
        }
        
        
        
        
        if([self.offLineMsgs count] > 0)
        {
            [LogUtil debug:[NSString stringWithFormat:@"需要处理未发出通知的消息"]];
            
            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = offline_msgs;
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:[NSDictionary dictionaryWithObject:self.offLineMsgs forKey:@"offline_msgs"]];
        }
        
        int nowTime = [[NSDate date]timeIntervalSince1970];
        [LogUtil debug:[NSString stringWithFormat:@"收取离线消息完毕，时间：%d",nowTime - connStartTime]];
        
		self.isOfflineMsgFinish = true;
        
        [self getAllDeptId];
        [self getAllEmpArray];

        if (self.userStatus == status_offline) {
            self.connStatus = not_connect_type;

            eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
            _notificationObject.cmdId = rcv_offline_msg_finish;
            
            [[NotificationUtil getUtil]sendNotificationWithName:RCV_OFFLINE_MSG_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
            
            [db sendUnreadMsgNumNotification];
            
            [LogUtil debug:@"准备发送离线消息收取完成的通知时，发现用户已经离线了，这时修改状态为未连接"];
            
            return;
        }
        
        self.connStatus = normal_type;

        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = rcv_offline_msg_finish;
        
        [[NotificationUtil getUtil]sendNotificationWithName:RCV_OFFLINE_MSG_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

        [db sendUnreadMsgNumNotification];
        
//		万达版本收取完离线消息后，发起其它的同步, executeAfterSaveUserStatus方法的命名和实际不一致，应该是离线消息收取完毕后，执行下面的操作
        [self executeAfterSaveUserStatus];
        
        //收取完毕后，开启checkTime线程
        if(checkTimeThread == nil)
        {
            checkTimeThread = [[NSThread alloc]initWithTarget:self selector:@selector(sendCheckTime) object:nil];
            [checkTimeThread start];
        }
        
//        NSString *machine = [StringUtil machineName];
//        [LogUtil debug:[NSString stringWithFormat:@"终端名称: %@",machine]];
        
        if (self.offlineMsgArray.count > 0) {
            [LogUtil debug:@"离线消息应答开始发送"];
            for (NSDictionary *dic in self.offlineMsgArray) {
                long long srcMsgId = [[dic valueForKey:@"rcv_msg_id"]longLongValue];
                int netId =  [[dic valueForKey:@"rcv_net_id"]intValue];
                [self sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
                //        休眠1毫秒
                [NSThread sleepForTimeInterval:0.01];
            }
            
            [self.offlineMsgArray removeAllObjects];
            [LogUtil debug:@"离线消息应答已经发送完毕"];
        }
	}
}

//处理消息已读通知
-(void)processMsgReadNotice:(MSGREADNOTICE*)info
{
    int msgType = info->cMsgType;
    //	0为回执，1为已读通知
    if(msgType == 1)
    {
        NSLog(@"%s,收到了一呼百应消息的已读",__FUNCTION__);
    }
    else
    {
        NSLog(@"%s,收到了回执消息的已读",__FUNCTION__);
    }
    NSString *originMsgId = [NSString stringWithFormat:@"%lld",info->dwMsgID];
    
    //查询数据库，取出对应的id
    NSArray *msgIdArray = [db getMsgIdArrayByOriginMsgId:originMsgId andSenderId:info->dwRecverID];
    
    if (msgIdArray.count == 0) {
        [LogUtil debug:@"收到了已读回执，但是本地还没有保存这条消息"];
        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
        
        [mDic setValue:originMsgId forKey:@"origin_msg_id"];
        
        int empId = info->dwSenderID;
        [mDic setValue:[NSNumber numberWithInt:empId] forKey:@"emp_id"];
        
        int readTime = info->dwTime;
        [mDic setValue:[NSNumber numberWithInt:readTime] forKey:@"read_time"];
        
        int receiverEmpId = info->dwRecverID;
        [mDic setValue:[NSNumber numberWithInt:receiverEmpId] forKey:@"receiver_emp_id"];
        
        [self.noProcessMsgReadNotice addObject:mDic];
        return;
    }
    //    NSString *msgId = [db getMsgIdByOriginMsgId:originMsgId];
    for (NSString *msgId in msgIdArray) {
        int empId = info->dwSenderID;
        int readTime = info->dwTime;
        [[ReceiptDAO getDataBase]updateMsgReadState:msgId.intValue andEmpId:empId andReadTime:readTime];
        
        //	发送通知
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = msg_read_notice;
        _notificationObject.info = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"MSG_ID", nil];
        
        [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
        
    }
}

#pragma mark 收取离线消息超时处理
-(void)processRcvOfflineMsgTimeout:(NSNumber *)timeout
{
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,生成离线消息超时timer",__FUNCTION__]];
	
//    如果当前收到的离线消息数和总数一致，就不再判断超时
    if (self.offlineMsgTotal > 0 && (self.curRcvOfflineMsgCount == self.offlineMsgTotal)) {
        [self cancelOfflineMsgTimer];
//        [LogUtil debug:@"已经收取完所有的离线消息，不用再判断超时"];
        return;
    }
    int _timeout = rcv_offline_msg_timeout;
    if (timeout) {
        _timeout = [timeout intValue];
    }
	_offlineMsgTimer  =[NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector(rcvOfflineMsgTimeout) userInfo:nil repeats:NO];
}
-(void)rcvOfflineMsgTimeout
{
    if (self.offlineMsgTotal > 0 && (self.curRcvOfflineMsgCount == self.offlineMsgTotal)) {
        [self cancelOfflineMsgTimer];
//        [LogUtil debug:@"已经收取完所有的离线消息，不用执行超时操作"];
        return;
    }
	if(!self.isOfflineMsgFinish)
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,收取离线消息超时",__FUNCTION__]];
	}
    
	[self sendRcvOfflineMsgFinishNotify];
	
	[self performSelectorOnMainThread:@selector(cancelOfflineMsgTimer) withObject:nil waitUntilDone:YES];
}


-(void)cancelOfflineMsgTimer
{
	if(_offlineMsgTimer && _offlineMsgTimer.isValid)
	{
        //		[LogUtil debug:[NSString stringWithFormat:@"取消收取离线消息timer"]];
		[_offlineMsgTimer invalidate];
		_offlineMsgTimer = nil;
	}
}

//获取新的msgid
-(long long)getNewMsgId
{
	int nowtimeInt=[self getCurrentTime];
	long long newMsgId = CLIENT_PackMsgId(self.userId.intValue,TERMINAL_IOS,nowtimeInt);
	
    //	CLIENT_UnpackMsgId(newMsgId);
	
    //	[LogUtil debug:[NSString stringWithFormat:@"newMsgId is %lld",newMsgId]];
	return newMsgId;
}
//获取新的msgid
-(NSString *)getSNewMsgId
{
    NSString *newMsgId = [NSString stringWithFormat:@"%llu",[self getNewMsgId]];
    return newMsgId;
}


//获取当前时间，已服务器时间为基准
-(int)getCurrentTime
{
//        NSLog(@"%s,serverTime is %d,dtime is %lld",__FUNCTION__,self.nServerCurrentTime,self.dTime);
    if (self.nServerCurrentTime) {
        int nowtimeInt=self.nServerCurrentTime+([[NSDate date]timeIntervalSince1970] - self.dTime);
        return nowtimeInt;
    }else{
        return 0;
    }
}
-(NSString*)getSCurrentTime
{
	return [StringUtil getStringValue:[self getCurrentTime]];
}

//用户登录成功、收完离线消息后，自动发送状态为发送中的消息
-(void)reSendMsg:(ConvRecord *)_record
{
	int nowtimeInt=[_conn getCurrentTime];
	
	int receiptMsgFlag = conv_status_normal;
	if(_record.isReceiptMsg)
	{
		receiptMsgFlag = conv_status_receipt;
	}
    else if (_record.isHuizhiMsg)
    {
        receiptMsgFlag = conv_status_huizhi;
    }
        
	
    //	如果是文本消息
	int msgType = _record.msg_type;
	switch (msgType)
	{
		case type_text:
		{
			[self sendMsg:_record.conv_id andConvType:_record.conv_type andMsgType:msgType andMsg:_record.msg_body andMsgId:_record.origin_msg_id andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
		}
			break;
		case type_pic:
		case type_record:
        case type_file:
        case type_video:
		{
			[self sendMsg:_record.conv_id andConvType:_record.conv_type andMsgType:msgType andFileSize:_record.file_size.intValue andFileName:_record.file_name andFileUrl:_record.msg_body andMsgId:_record.origin_msg_id andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
		}
			break;
		case type_long_msg:
		{
			[self sendLongMsg:_record.conv_id andConvType:_record.conv_type andMsgType:msgType andFileSize:_record.file_size.intValue andMessageHead:_record.file_name andFileUrl:_record.msg_body andMsgId:_record.origin_msg_id andTime:nowtimeInt andReceiptMsgFlag:receiptMsgFlag];
		}
			break;
		default:
			break;
	}
}

//把结构体里的信息获取到消息模型里
-(MsgNotice*)getMsgNoticeObject:(MSGNOTICE *)_msgNotice
{
	MsgNotice *_msg = [[[MsgNotice alloc]init]autorelease];
	_msg.senderId = _msgNotice->dwSenderID;
	_msg.rcvId = _msgNotice->dwRecverID;
	_msg.groupId = [StringUtil getStringByCString:_msgNotice->aszGroupID];
	_msg.msgId = _msgNotice->dwMsgID;
	_msg.isGroup = _msgNotice->cIsGroup;
    
    _msg.netID = _msgNotice->dwNetID;
    
    if (_msg.isGroup == 3) {
        _msg.isMsgFromWX = YES;
    }
    else
    {
        _msg.isMsgFromWX = NO;
    }
    
	_msg.msgType = _msgNotice->cMsgType;
	_msg.isOffline = _msgNotice->cOffline;
	_msg.offMsgTotal = _msgNotice->nOffMsgTotal;
	_msg.offMsgSeq = _msgNotice->nOffMsgSeq;
	_msg.msgLen = _msgNotice->dwMsgLen;
	_msg.msgTime = _msgNotice->dwSendTime;
	_msg.msgGroupTime = [StringUtil getStringValue:_msgNotice->dwGroupTime];
	
    //	[LogUtil debug:[NSString stringWithFormat:@"_msg.msgGroupTime is %@",_msg.msgGroupTime]];
	_msg.msgTotal = _msgNotice->nMsgTotal;
    
	_msg.msgSeq = _msgNotice->nMsgSeq;
	
    //	[LogUtil debug:[NSString stringWithFormat:@"msg len is %d",_msg.msgLen]];
	if(_msg.msgLen > 0)
	{
		switch(_msg.msgType)
		{
			case type_text:
            case type_group_notice:
			{
                if (_msg.isMsgFromWX)
                {
                    //                    微信号 50字节
                    //                    char wx
                }
                else
                {
                    int msgLen = _msgNotice->dwMsgLen - 10;
                    char temp[msgLen + 1];
                    memset(temp,0,sizeof(temp));
                    memcpy(temp,_msgNotice->aszMessage+10, msgLen);
                    
                    _msg.msgBody = [StringUtil getStringByCString:temp];
                    
//                    _msg.msgBody = [NSString stringWithFormat:@"%@%@)%@",REPLY_TO_ONE_MSG_FLAG,[NSString stringWithFormat:@"%llu",_msg.msgId],_msg.msgBody];
                    
                    // add by yanlei 机器人应答要单独处理 [[RobotDAO getDatabase]isRobotUser:msgNotice.senderId]
                    if ([[RobotDAO getDatabase]getRobotId] == _msg.senderId || [StringUtil isXiaoWanMsg:_msg.msgBody]){
//                        去掉空格
                        
//                        NSString *str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testImage" ofType:@"docx"]];
//                        
//                        str = @"<soap:Body><ns2:askResponse xmlns:ns2=\"http://www.eastrobot.cn/ws/RobotService\"><robotResponse><commands><args>http://wandar.demo.xiaoi.com/robot/attachments/20151028142327393</args><args>唯美景不可辜负</args><args>绿渊潭</args><args>JPG</args><args>1.45 MB</args><name>imgmsg</name><state>1</state></commands><moduleId>core</moduleId><nodeId>000000004fedcb6e0150cbf6fc3958bb</nodeId><similarity>1.0</similarity><type>1</type></robotResponse></ns2:askResponse></soap:Body>";
//                        
//                        _msg.msgBody = str;
                        
                        NSString *tempStr = [_msg.msgBody stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];

                        RobotResponseXmlParser *robotParser = [[[RobotResponseXmlParser alloc]init]autorelease];
                        
                        if ([tempStr rangeOfString:@"[AGENT]"].length > 0 && [tempStr rangeOfString:@"[link submit="].length == 0) {
                            //            如果有agent 没有link，可能是收到人工服务的应答时，用户回复数字给小万，小万的回复就是这种格式，只有agent，没有link，为了能在界面上显示为超链接，因此手动修改了本地的值，增加了link submit add by shisp
                            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"[AGENT]" withString:@"[link submit=\"1\"][AGENT]"];
                            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"[/AGENT]" withString:@"[/AGENT][/link]"];
                        }
                        
                        _msg.msgBody = tempStr;
                        
                        bool result = [robotParser parse:tempStr andIsParseAgent:NO];
                        if (result) {
//                            if (robotParser.robotModel.msgType == type_record || robotParser.robotModel.msgType == type_video) {
//                                _msg.msgType = type_file;
//                                _msg.fileName = robotParser.robotModel.msgFileName;
//                            }else{
//                                _msg.msgType = robotParser.robotModel.msgType;
//                            }
                            _msg.robotResponseModel = robotParser.robotModel;
                            
                            [LogUtil debug:[NSString stringWithFormat:@"%s 小万的应答是 %@",__FUNCTION__,tempStr]];
                        }
                    }else{
                        NSData* jsonData = [_msg.msgBody dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *resultDict = [jsonData objectFromJSONData];
                        
                        if (resultDict && [resultDict isKindOfClass:[NSDictionary class]])
                        {
                            /** 是否密聊消息，如果是密聊消息，那么要先解析 */
                            if ([resultDict[KEY_MSG_TYPE] isEqualToString:KEY_MILIAO_MSG_TYPE]) {
                                _msg.msgType = [resultDict[KEY_MILIAO_CONTENT_TYPE] intValue];
                                
                                if (_msg.msgType == type_text) {
                                    _msg.msgBody = resultDict[KEY_MILIAO_DATA];
                                }else{
                                    _msg.fileSize = [resultDict[KEY_MILIAO_FILE_SIZE] intValue];
                                    _msg.fileName = resultDict[KEY_MILIAO_FILE_NAME];
                                    _msg.msgBody = resultDict[KEY_MILIAO_FILE_URL];
                                }
                                _msg.isEncryptMsg = YES;
                                _msg.groupId = [[MiLiaoUtilArc getUtil]getMiLiaoConvIdWithEmpId:_msg.senderId];
                            }
#ifdef _LANGUANG_FLAG_
//                            是单聊 并且是待办消息类型
                            else if([resultDict[KEY_MSG_TYPE] isEqualToString:KEY_LANGUANG_DAIBAN_TYPE] && _msg.isGroup == 0){
                                [UserDefaults setLanGuangDaiBanId:_msg.senderId];
                                _msg.needCreateSingleConv = NO;
                            }
#endif
                            
                        }
                    }
                    if (_msg.msgType == type_group_notice) {
                        _msg.msgBody = [NSString stringWithFormat:@"群公告消息:%@",_msg.msgBody];
                        _msg.msgType = type_text;
                    }
                }
			}
				break;
			case type_long_msg:
			{
				
				//		取出长消息文件信息
				char _fileInfo[sizeof(FILE_META)];
				memset(_fileInfo,0,sizeof(_fileInfo));
				memcpy(_fileInfo,_msgNotice->aszMessage + 10,sizeof(FILE_META));
				
				FILE_META *fileInfo = (FILE_META *)_fileInfo;
				//		长消息字节数
				_msg.fileSize = ntohl(fileInfo->dwFileSize);
				//长消息文件名字
                //				fileName = [StringUtil getStringByCString:fileInfo->aszFileName];
				//		长消息文件url
				_msg.msgBody = [StringUtil getStringByCString:fileInfo->aszURL];
				
				//		长消息头部
				/*从后10位开始截取，过滤掉字体信息*/
				int msgHeadLen = _msgNotice->dwMsgLen - 10 - sizeof(FILE_META);
				char temp[msgHeadLen + 1];
				memset(temp,0,sizeof(temp));
				memcpy(temp,_msgNotice->aszMessage+10+sizeof(FILE_META), msgHeadLen);
                //				把消息头保存在fileName属性中
                NSString *tempStr = [StringUtil getStringByCString:temp];
                if (tempStr.length) {
                    _msg.fileName = tempStr;
                }
                
//                如果没有取到摘要信息，就去下载，下载完成后，保存摘要信息，如果下载失败，则使用一个默认值
                if (_msg.fileName.length == 0) {
                    
                    NSString *token = [NSString stringWithFormat:@"%@",_msg.msgBody];
                    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
                    
                    NSData *_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                    if (_data.length) {
                        NSString *pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_msg.msgBody]];
                        BOOL success = [_data writeToFile:pathStr atomically:YES];
                        if (success) {
                            NSString *longMsg = [NSString stringWithContentsOfFile:pathStr encoding:NSUTF8StringEncoding error:nil];
                            
                            if (longMsg.length > 16) {
                                NSString *messageHead = [longMsg substringToIndex:16];
                                _msg.fileName = messageHead;
                            }
                        }
                    }
                    
                    if (_msg.fileName.length == 0) {
                        _msg.fileName = [StringUtil getLocalizableString:@"msg_type_long_msg"];
                    }
                }

                [LogUtil debug:[NSString stringWithFormat:@"长消息的摘要信息是：%@",_msg.fileName]];
			}
				break;
			case type_pic:
			case type_record:
			case type_file:
            case type_video:
			{
				FILE_META *fileInfo = (FILE_META *)&_msgNotice->aszMessage;
				_msg.fileSize = ntohl(fileInfo->dwFileSize);
				
                //				如果是录音消息，并且长度不正常，那么赋值一个10s，否则不能正常显示录音
				if(_msg.msgType == type_record && (_msg.fileSize > 60 || _msg.fileSize<=0))
				{
					[LogUtil debug:[NSString stringWithFormat:@"record len is :%d",_msg.fileSize]];
					_msg.fileSize = 10;
				}
				_msg.fileName = [StringUtil getStringByCString:fileInfo->aszFileName];
				_msg.msgBody = [StringUtil getStringByCString:fileInfo->aszURL];
                
			}
				break;
            case type_recall_msg:
            {
//                add by shisp 如果是撤回消息，那么把要真正要撤回的消息id取出来放到 srcMsgIdOfMassMsg属性里
                _msg.srcMsgIdOfMassMsg = _msgNotice->dwSrcMsgID;
            }
                break;
		}
        //		[LogUtil debug:[NSString stringWithFormat:@"msgBody len is %d,msgBody is %@",_msg.msgBody.length,_msg.msgBody]];
		
		_msg.receiptMsgFlag = _msgNotice->cAllReply;
        
//        如果是回执消息，那么需要特殊处理
        if (_msgNotice->cRead == 1) {
            _msg.receiptMsgFlag = conv_status_huizhi;
        }
        
//        NSLog(@"%s,cALlReply is %d ,msg body is %@",__FUNCTION__,_msg.receiptMsgFlag,_msg.msgBody);
        
		if(_msg.receiptMsgFlag == 2)
		{
			_msg.isMassMsg = YES;
			_msg.srcMsgIdOfMassMsg = _msgNotice->dwSrcMsgID;
		}

		return _msg;
	}
	return nil;
}

#pragma mark 当收到创建群组通知时，收到群组成员变化通知时，保存通知消息，并通知
-(void)saveGroupNotifyMsg:(NSString*)convId andMsg:(NSString*)msgBody andMsgTime:(NSString*)msgTime;
{
	//	设置为已读
	NSString *sReadFlag = @"0";
	//	发消息
	NSString *sMsgFlag = [StringUtil getStringValue:send_msg];
	//
	NSString *sSendFlag = [StringUtil getStringValue:send_success];
	
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",self.userId,@"emp_id",[StringUtil getStringValue:type_group_info],@"msg_type",msgBody,@"msg_body",msgTime,@"msg_time", sReadFlag,@"read_flag",sMsgFlag,@"msg_flag",sSendFlag,@"send_flag",@"",@"file_name",@"0",@"file_size",@"",@"origin_msg_id",nil];
	
	NSDictionary *_dic = [db addConvRecord:[NSArray arrayWithObject:dic]];
	NSString *msgId;
	if(_dic)
	{
		msgId = [_dic valueForKey:@"msg_id"];
	}
	else
	{
		msgId = nil;
	}
	//				[LogUtil debug:[NSString stringWithFormat:@"消息入库 msg is %@,msgId is %@",mMessage,msgId]];
	
	if(msgId)
	{//通知页面更新，但不发出声音
		[self sendMsgNotice2:msgId andConvId:convId andAlert:false];
	}
}

#pragma mark 处理主动退出群组应答
-(void)processQuitGroup:(QUITGROUPACK*)info
{
	[self stopTimeoutTimer];
	self.isQuitGroupCmd = false;
    
	
	int _ret = info->nReturn;
	if(_ret == 0)
	{
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = quit_group_success;
        
        [[NotificationUtil getUtil]sendNotificationWithName:QUIT_GROUP_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

	}
	else
	{
		[LogUtil debug:[NSString stringWithFormat:@"ret is %d",_ret]];

        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = quit_group_failure;
        
        [[NotificationUtil getUtil]sendNotificationWithName:QUIT_GROUP_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
	}
}

//deprecated
-(bool)isDataSaved
{
	[LogUtil debug:[NSString stringWithFormat:@"orgQueue.operationCount is %d,msgQueue.operationCoun is %d",orgQueue.operationCount,msgQueue.operationCount]];
	if(orgQueue.operationCount == 0 && msgQueue.operationCount == 0)
		return true;
	return false;
}

//处理退群通知
-(void)processQuitGroupNotice:(QUITGROUPNOTICE*)info
{
    //	退出时间
	NSString *grpId = [StringUtil getStringByCString:info->aszGroupID];
	if([db searchConversationBy:grpId])
	{
		int operEmpId = info->dwUserID;
        
//        [db deleteConvAndConvRecordsBy:conv.conv_id];
        if ([UIAdapterUtil isCsairApp] && (operEmpId == self.userId.intValue)) {
            //               如果是南航 并且退出的人是自己 那么 删除本地会话及会话记录
            [[eCloudDAO getDatabase]deleteConvAndConvRecordsBy:grpId];

        }else{
            NSDictionary *_dic =	[NSDictionary dictionaryWithObjectsAndKeys:grpId,@"conv_id",  [StringUtil getStringValue:operEmpId],@"emp_id",nil];
            
            [db deleteConvEmp:[NSArray arrayWithObject:_dic]];
            
            NSString *operTime = [StringUtil getStringValue:info->dwTime];
            NSString *operEmpName = [db getEmpNameByEmpId:[StringUtil getStringValue:operEmpId]];
            NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_quit_group"],operEmpName];
            [self saveGroupNotifyMsg:grpId andMsg:msgBody andMsgTime:operTime];
            [db updateConversationTime:grpId andTime:info->dwTime];
            
            [self sendGroupMemberModifyNotification:grpId];
        }
	}
}

//处理人员资料修改通知
-(void)processModifyUserInfoNotice:(RESETSELFINFONOTICE*)info
{
	int empId = info->dwUserID;
	int type = info->cModiType;
	if(type == 7)
	{
		NSString *logo = [StringUtil getStringByCString:info->aszModiInfo];
		[StringUtil downloadUserLogo:[StringUtil getStringValue:empId] andLogo:logo andNeedSaveUrl:true];
	}
	
    //	获取用户最新资料 type=2的情况下，需要判断是否下载头像
    //	CLIENT_GetEmployee(_conncb,empId,0);
}

#pragma mark 上行消息到公众号 deprecated
-(BOOL)sendPSMsg:(ServiceMessage*)message
{
	return [PSConn sendPSMsg:_conncb andFromUser:self.userId andServiceMessage:message];
}

//用户点击了公众号菜单
-(BOOL)sendPSMenuMsg:(ServiceMessage*)message{
    return [PSConn sendPSMenuMsg:_conncb andFromUser:self.userId andServiceMessage:message];
}

#pragma mark - 同步虚拟组信息 虚拟组是指 一个虚拟组账号 关联了多个账号，给某个虚拟组发消息，服务器会发给虚拟组成员里的某一个
-(BOOL)sendVirtualGroupReq{
    // by yanlei
    return [[VirtualGroupConn getVirtualGroupConn]syncVirtalGroupInfo:_conncb];
}

#pragma mark 当用户在后台运行时，收到了消息，那么就生成一个本地通知
//-(void)createLocalNotification:(MsgNotice*)msgNotice
-(void)createLocalNotification:(NSDictionary *)dic
{
    MsgNotice *msgNotice = [dic valueForKey:@"msg_notice"];
    if (!msgNotice) {
        return;
    }
    
//    生成本地通知时的userInfo 默认是普通消息
    NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:local_notification_normal_msg],KEY_NOTIFICATION_MSG_TYPE, nil];;
    
    //    保存到数据库时真正的消息类型和消息内容
    NSString *saveMsgBody = dic[@"msg_body"];
    int saveMsgType = [dic[@"msg_type"]intValue];
    
    NSLog(@"%s,msg body is %@,sender id is %d",__FUNCTION__,saveMsgBody,msgNotice.senderId);

    if (![NotificationsViewController needAlertWhenRcvMsg] || saveMsgType == type_recall_msg)
    {
        return;
    }
    
	UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];
	if(appState != UIApplicationStateActive)
	{
        int iOffline = msgNotice.isOffline;
        if(iOffline == 1)
        {
			[LogUtil debug:@"是离线消息，不生成本地通知"];
			return;
        }
		if(msgNotice.receiptMsgFlag == 2)
		{
			[LogUtil debug:@"是一呼万应的回复消息，不生成本地通知"];
			return;
		}
		if(msgNotice.msgTotal == 1)
		{
			[LogUtil debug:@"用户设置了消息同步，并且pc在线"];
			return;
		}
		int senderId = msgNotice.senderId;
        //		如果是同步自己的消息，就不显示本地通知
		if(senderId == self.userId.intValue)
		{
			[LogUtil debug:@"用户自己发来的消息"];
			return;
		}
        
        //        新增一个变量，记录用户是否需要新消息提醒，如果是@消息，那么即使设置了新消息不通知，也要通知
        //        是否需要
        BOOL newMsgAlert = YES;
        //        是否@消息，默认不是
        BOOL isAtMsg = NO;
        
        //		如果是群组消息，并且屏蔽群组消息，那么也不生成通知
		int cIsGroup = msgNotice.isGroup;
		if(cIsGroup == 1)
		{
			NSString *convId = msgNotice.groupId;
			if([db getRcvMsgFlagOfConvByConvId:convId])
			{
				[LogUtil debug:[NSString stringWithFormat:@"群组消息,本地已经设置了新消息不提醒"]];
                newMsgAlert = NO;
			}
		}
        
		NSArray *temp = [self getEmpByEmpId:senderId];
		NSString *senderName = [StringUtil getStringValue:senderId];
		if(temp.count > 0)
		{
			senderName = [[temp objectAtIndex:0]emp_name];
        }else {
//            再从数据库查询
            Emp *tempEmp = [[eCloudDAO getDatabase]getEmployeeById:[StringUtil getStringValue:senderId]];
            if (tempEmp) {
                senderName = tempEmp.emp_name;
            }
        }
        
//        update by shisp 代办的通知不在这里生成
//        }else if (senderId == 101){
//            // 新待办类型
//            senderName = @"新待办:";
//        }
		NSString *msgBody = nil;
        
        //                如果有人@我，通知内容会不一样
        BOOL msgBodyReady = NO;
        if(cIsGroup == 1)
        {
            NSString *tempStr = [NSString stringWithFormat:@"@%@",self.userName];
            if(saveMsgType == type_text)
            {
                msgBody = saveMsgBody;
            }
            else if(saveMsgType == type_long_msg)
            {
                msgBody = msgNotice.fileName;
            }
            
            if (msgBody && msgBody.length > 0) {
                if([msgBody rangeOfString:tempStr].length > 0 ||[StringUtil isAtAllMsg:msgBody])
                {
                    NSString *tipStr = [StringUtil getLocalizableString:@"someone_at_you"];
                    msgBody = [NSString stringWithFormat:tipStr,senderName];
                    msgBodyReady = YES;
                    senderName = @"";
                    isAtMsg = YES;
                }
            }
        }
        
        if(msgBodyReady == NO)
        {
//            update by shisp 2015.11.24
            msgBody = [StringUtil getUserTipsWithMsgType:saveMsgType andMsg:saveMsgBody];
        }
		
        if(newMsgAlert || (!newMsgAlert && isAtMsg))
        {
            NSString *newMsg = [NSString stringWithFormat:@"%@%@",senderName,msgBody];
//            {
//                "aps" : { "alert" : "This is the alert text", "badge" : 1, "sound" : "default” }
//                    “url”:
//                    “urlid”:
//                }
//            url :  wdoapage://contactViewController
#ifdef _TAIHE_FLAG_
            if (msgNotice.msgType == type_text) {

                ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
                _convRecord.msg_body = msgNotice.msgBody;
                [talkSessionUtil preProcessTextAppMsg:_convRecord];
                if (_convRecord.appMsgModel) {
                    if (_convRecord.appMsgModel.title) {
                        
                        newMsg = _convRecord.appMsgModel.title;
                    }
                }

            }
#endif
            
#ifdef _LANGUANG_FLAG_
      
            if (msgNotice.msgType == type_text) {
                
                ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
                _convRecord.msg_body = msgNotice.msgBody;
                NSDictionary *dic = [_convRecord.msg_body objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
                
//                一定要是字典类型
                if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                    if ([dic[@"type"] isEqualToString:@"meeting"]) {
                        
                        [talkSessionUtil preProcessMettingAppMsg:_convRecord];
                        if (_convRecord.meetingMsgModel) {
                            
                            //会议：一楼会议室1002（2017.04.28 14:00）
                            //“企业信息门户需求沟通会议”
//                                                    {   “type”: “meeting “,
//                                                        “confid”  :  “1”,
//                                                        “meetingMsgType“  :  ”1” ,
//                                                        “importance”  : “正式”,
//                                                        “title”  :  “测试”,
//                                                        “host”  :  “http://www.qwqwqw.com”,
//                                                        “startTime”  :  “2017-05-27 10:00:00”,
//                                                        “place”  :  “测试地点”,
//                                                        “duration”  :  “30分”,
//                                                        “summary”  :  “测试,测试, 测试, 测试, 测试”,
//                                                        “approach”  :  “15分”,
//                            
//                                                    }
                            
                            newMsg = [NSString stringWithFormat:@"会议:%@(%@)\n\"%@\"",_convRecord.meetingMsgModel.place,_convRecord.meetingMsgModel.startTime,_convRecord.meetingMsgModel.title];
                            notificationUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:notification_agent_msg],KEY_NOTIFICATION_MSG_TYPE, nil];
                        }
                        
                    }else if ([dic[@"type"] isEqualToString:@"redPacket"] || [dic[@"type"] isEqualToString:@"redPacketAction"]){
                        [talkSessionUtil preProcessredPacketMsg:_convRecord];
                        if (_convRecord.redPacketModel) {
                            
                            NSString *type = _convRecord.redPacketModel.type;
                            
                            if ([type isEqualToString:@"redPacket"]) {
                                
                                newMsg = [NSString stringWithFormat:@"%@发来一个红包",senderName];
                            }else if([type isEqualToString:@"redPacketAction"]){
                                
                                newMsg = [NSString stringWithFormat:@"%@领取了你的红包",senderName];
                                
                                if ([_convRecord.redPacketModel.hostId isEqualToString:_convRecord.redPacketModel.guestId]) {
                                    
                                    newMsg = @"你领取了自己发的红包";
                                }
                            }
                        }
                    }
                }
            }
            
            /** 如果是密聊消息那么只显示消息就可以 */
            if (msgNotice.isEncryptMsg) {
                newMsg = [StringUtil getLocalizableString:@"key_message"];
            }
            
            if ([dic[@"type"] isEqualToString:@"news"]) {
                
                newMsg = dic[@"title"];
            }
            
#endif
#ifdef _XIANGYUAN_FLAG_
            
            if (msgNotice.msgType == type_text) {
                
                ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
                _convRecord.msg_body = msgNotice.msgBody;
                NSDictionary *dic = [_convRecord.msg_body objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//                一定要是字典类型才处理
                if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                    
                    NSString *type = [NSString stringWithFormat:@"%@",dic[@"msgType"]];
                    
                    if ([type isEqualToString:KEY_XY_DAIBAN_MSG_TYPE]) {
                        
                        senderName = @"";
                        newMsg = [NSString stringWithFormat:@"[待办]%@",dic[@"message"][@"title"]];
//                        用户点击待办的时候，要求能自动打开待办这个应用的列表，不用支持其它应用，也不要求打开某个URL，只是打开待办列表即可
                        notificationUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:xy_notification_agent_msg],KEY_NOTIFICATION_MSG_TYPE, nil];
                    }else if ([type isEqualToString:KEY_XY_TONGGAO_MSG_TYPE]){
                        
                        senderName = @"";
                        newMsg = [NSString stringWithFormat:@"[通告]%@",dic[@"message"][@"title"]];
                        //                        用户点击待办的时候，要求能自动打开待办这个应用的列表，不用支持其它应用，也不要求打开某个URL，只是打开待办列表即可
                        notificationUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:notification_agent_msg],KEY_NOTIFICATION_MSG_TYPE, nil];
                    }
                }
            }
      
            
#endif
            if (![UIAdapterUtil isCombineApp]) {
                int badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
                
                //            应用未读消息数 + 1
                [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
            }
            
//            NSMutableDictionary *apsDic = [NSMutableDictionary dictionary];
//            [apsDic setValue:[NSNumber numberWithInt:badgeNumber] forKey:@"badge"];
//            
//            NSMutableDictionary *notiUserInfo = [NSMutableDictionary dictionary];
//            [notiUserInfo setValue:apsDic forKey:@"aps"];
//            [notiUserInfo setValue:@"wdoapage://contactViewController" forKey:@"url"];
            
//            本地通知怎么提示和系统设置-通知中的设置相关
            UILocalNotification *noti = [[UILocalNotification alloc]init];
            noti.alertBody = newMsg;
            
            if ([NotificationsViewController isNotificationNeedSound]) {
                noti.soundName = UILocalNotificationDefaultSoundName;
            }
            
//            noti.userInfo = notiUserInfo;
            
//            if (senderId == 101){
//                //            增加userInfo标志是收到了新待办通知信息
//                noti.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:notification_agent_msg],KEY_NOTIFICATION_MSG_TYPE, nil];
//            }else{

            noti.userInfo = notificationUserInfo;

//            }
            
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
            [noti release];
        }
    }
//测试程序
//    else{
//    if(appState == UIApplicationStateActive)
//    {
//        BOOL _bool = [StringUtil isPureNumberCharacters:saveMsgBody];
//        NSNumber *appId = [NSNumber numberWithInt:LONGHU_DAIBAN_APP_ID];
//        
//        if (_bool) {
//            NSLog(@"yes");
//            appId = [NSNumber numberWithInt:[saveMsgBody intValue]];
//        }else{
//            NSLog(@"NO");
//        }
//        
//        NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getAppName],KEY_NOTIFICATION_TITLE,saveMsgBody,KEY_NOTIFICATION_MESSAGE,appId,KEY_NOTIFICATION_APP_ID,@"",KEY_NOTIFICATION_APP_URL,[NSNumber numberWithInt:notification_agent_msg],KEY_NOTIFICATION_MSG_TYPE, nil];
//        [self performSelectorOnMainThread:@selector(presentNotificationWhenAppActive:) withObject:_dic waitUntilDone:YES];
//    }
}


//		同步公众号
-(void)syncPublicService
{
	[PSConn psSyncRequest:_conncb andFromUser:self.userId];
}

//同步公众号菜单
-(void)syncpsMenuListSyncRequest
{
    [PSConn psMenuListSyncRequest:_conncb andFromUser:self.userId];
}

//保存公众号菜单
-(void)savePSMenuList:(NSString*)meneStr{
    [PSConn parseAndSavePSMenuList:meneStr andFromUser:self.userId];
}

//保存公众号
-(void)savePS:(NSString*)psStr
{
	[PSConn parseAndSavePS:psStr andFromUser:self.userId];
}

#pragma mark - －－－－－－－－应用平台消息处理－－－－－－－－－－
//deprecated
- (void)saveAppList:(NSString *)appListStr{
    //保存同步应用列表
    [APPConn parseAndSaveAPPListInfo:appListStr];
    
    //有新应用
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:APP_NEW_DEFAULT] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APP_NEW_NOTIFICATION object:nil];
    }
}
//deprecated
- (void)saveAppMsg:(NSString *)appMsgStr{
    //保存应用推送消息
    [APPConn saveAPPMsg:appMsgStr];
}

-(void)syncAppList{
    //同步应用列表
//    [APPConn appSyncRequest:_conncb andFromUser:self.userId];
    [APPConn appSyncRequestOption:_conncb andFromUser:self.userId];
}

//deprecated
-(void)sendOneAPPStateRecordOfApp:(APPStateRecord*)appStateRec{
    //统计上报
    [APPConn sendAPPStateRecordRequest:_conncb andFromUser:self.userId andAPPStateRecord:appStateRec];
}

#pragma mark------------获取级别，业务，地域信息-------------
//deprecated
-(void)getRankInfo
{
	[LogUtil debug:[NSString stringWithFormat:@"%s, old time is %d , new time is %d",__FUNCTION__,oldRankUpdateTime,newRankUpdateTime]];
	if(oldRankUpdateTime < newRankUpdateTime)
	{
		CLIENT_get_userRPA(_conncb,CMD_GETUSERRANK_REQ,oldRankUpdateTime,TERMINAL_IOS);
	}
	else
	{
		[self getProfInfo];
	}
}
#pragma mark----获取业务信息----
//deprecated
-(void)getProfInfo
{
	[LogUtil debug:[NSString stringWithFormat:@"%s, old time is %d , new time is %d",__FUNCTION__,oldProfUpdateTime,newProfUpdateTime]];
	if(oldProfUpdateTime < newProfUpdateTime)
	{
		CLIENT_get_userRPA(_conncb,CMD_GETUSERPROFE_REQ,oldProfUpdateTime,TERMINAL_IOS);
	}
	else
	{
		[self getAreaInfo];
	}
}
#pragma mark----获取地域信息----
//deprecated
-(void)getAreaInfo
{
	[LogUtil debug:[NSString stringWithFormat:@"%s, old time is %d , new time is %d",__FUNCTION__,oldAreaUpdateTime,newAreaUpdateTime]];
	if(oldAreaUpdateTime < newAreaUpdateTime)
	{
		CLIENT_get_userRPA(_conncb,CMD_GETUSERAREA_REQ,oldAreaUpdateTime,TERMINAL_IOS);
	}
}

#pragma mark----保存级别，业务，地域信息----
//deprecated
-(void)processGetUserRank:(GETUSERPAASK *)info
{
	if(info->result == RESULT_SUCCESS)
	{
		NSMutableArray *addOrUpdateRecords = [NSMutableArray array];
		NSMutableArray *delRecords = [NSMutableArray array];
		
		int num = info->wCurrNum;
		unsigned int startPos = 0;
		USERRANK _userRank;
		int iCount = 0;
		
		BOOL hasError = NO;
		while(1)
		{
			int ret = CLIENT_ParseUserRank(info->strPacketBuff, &startPos, &_userRank);
			if(ret < 0)
			{
				[LogUtil debug:[NSString stringWithFormat:@"%s,parse error %d",__FUNCTION__,ret]];
				hasError = YES;
				break;
			}
			else if(ret == EIMERR_PARSE_FINISHED)
			{
				[LogUtil debug:[NSString stringWithFormat:@"%s,parse finish",__FUNCTION__]];
				break;
			}
			else
			{
				Rank *_rank = [[Rank alloc]init];
				_rank.rankId = _userRank.cRankID;
				_rank.rankName = [StringUtil getStringByCString:_userRank.aszRankName];
				
				int updateType = _userRank.wUpdate_type;
				if(updateType == insertRecord || updateType == updateRecord)
				{
					[addOrUpdateRecords addObject:_rank];
				}
				else
				{
					[delRecords addObject:_rank];
				}
				[_rank release];
				iCount++;
			}
		}
		
		if(hasError)
		{
			[self getRankInfo];
		}
		else
		{
			if(num != iCount)
			{
				[LogUtil debug:@"记录个数不一致"];
				[self getRankInfo];
			}
			else
			{
				if([addOrUpdateRecords count] > 0)
				{
					NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:addOrUpdateRecords,@"data_array",[StringUtil getStringValue:info->wCurrPage],@"cur_page", @"0",@"data_type",nil];
					[self addTaskToQueue:@selector(saveRPAToDb:) andObject:dic];
				}
				if([delRecords count] > 0)
				{
                    //					delete
				}
				if(info->wCurrPage == 0)
				{
					[self getProfInfo];
				}
			}
		}
	}
	else
	{
		[LogUtil debug:@"获取用户级别失败"];
	}
}
//deprecated
-(void)processGetUserProf:(GETUSERPAASK *)info
{
	if(info->result == RESULT_SUCCESS)
	{
		NSMutableArray *addOrUpdateRecords = [NSMutableArray array];
		NSMutableArray *delRecords = [NSMutableArray array];
		
		int num = info->wCurrNum;
		unsigned int startPos = 0;
		USERPROFESSIONAL _userProf;
		int iCount = 0;
		
		BOOL hasError = NO;
		while(1)
		{
			int ret = CLIENT_ParseUserPro(info->strPacketBuff, &startPos, &_userProf);
			if(ret < 0)
			{
				[LogUtil debug:[NSString stringWithFormat:@"%s,parse error %d",__FUNCTION__,ret]];
				hasError = YES;
				break;
			}
			else if(ret == EIMERR_PARSE_FINISHED)
			{
				[LogUtil debug:[NSString stringWithFormat:@"%s,parse finish",__FUNCTION__]];
				break;
			}
			else
			{
				Profession *_prof = [[Profession alloc]init];
				_prof.profId = _userProf.cProfessionalID;
				_prof.profName = [StringUtil getStringByCString:_userProf.aszProfessionalName];
				
				int updateType = _userProf.wUpdate_type;
				if(updateType == insertRecord || updateType == updateRecord)
				{
					[addOrUpdateRecords addObject:_prof];
				}
				else
				{
					[delRecords addObject:_prof];
				}
				[_prof release];
				iCount++;
			}
		}
		
		if(hasError)
		{
			[self getProfInfo];
		}
		else
		{
			if(num != iCount)
			{
				[LogUtil debug:@"记录个数不一致"];
				[self getProfInfo];
			}
			else
			{
				if([addOrUpdateRecords count] > 0)
				{
					NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:addOrUpdateRecords,@"data_array",[StringUtil getStringValue:info->wCurrPage],@"cur_page", @"1",@"data_type",nil];
					[self addTaskToQueue:@selector(saveRPAToDb:) andObject:dic];
				}
				if([delRecords count] > 0)
				{
					//					delete
				}
				if(info->wCurrPage == 0)
				{
					[self getAreaInfo];
				}
			}
		}
	}
	else
	{
		[LogUtil debug:@"获取用户业务失败"];
	}
}
//deprecated
-(void)processGetUserArea:(GETUSERPAASK *)info
{
	if(info->result == RESULT_SUCCESS)
	{
		NSMutableArray *addOrUpdateRecords = [NSMutableArray array];
		NSMutableArray *delRecords = [NSMutableArray array];
		
		int num = info->wCurrNum;
		unsigned int startPos = 0;
		USERAREA _userArea;
		int iCount = 0;
		
		BOOL hasError = NO;
		while(1)
		{
			int ret = CLIENT_ParseUserArea(info->strPacketBuff, &startPos, &_userArea);
			if(ret < 0)
			{
				[LogUtil debug:[NSString stringWithFormat:@"%s,parse error %d",__FUNCTION__,ret]];
				hasError = YES;
				break;
			}
			else if(ret == EIMERR_PARSE_FINISHED)
			{
				[LogUtil debug:[NSString stringWithFormat:@"%s,parse finish",__FUNCTION__]];
				break;
			}
			else
			{
				Area *_area = [[Area alloc]init];
				_area.areaId = _userArea.dwAreaID;
				_area.areaName = [StringUtil getStringByCString:_userArea.aszAreaName];
				_area.parentArea = _userArea.dwPID;
				
				int updateType = _userArea.wUpdate_type;
				if(updateType == insertRecord || updateType == updateRecord)
				{
					[addOrUpdateRecords addObject:_area];
				}
				else
				{
					[delRecords addObject:_area];
				}
				[_area release];
				iCount++;
			}
		}
		
		if(hasError)
		{
			[self getAreaInfo];
		}
		else
		{
			if(num != iCount)
			{
				[LogUtil debug:@"记录个数不一致"];
				[self getAreaInfo];
			}
			else
			{
				BOOL saveSuccess = YES;
				if([addOrUpdateRecords count] > 0)
				{
					NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:addOrUpdateRecords,@"data_array",[StringUtil getStringValue:info->wCurrPage],@"cur_page", @"2",@"data_type",nil];
					[self addTaskToQueue:@selector(saveRPAToDb:) andObject:dic];
				}
				if([delRecords count] > 0)
				{
					//					delete
				}
				if(info->wCurrPage == 0)
				{
				}
			}
		}
	}
	else
	{
		[LogUtil debug:@"获取用户地域失败"];
	}
}
//deprecated
-(void)saveRPAToDb:(NSDictionary*)dic
{
	NSArray *dataArray = [dic objectForKey:@"data_array"];
	int curPage = [[dic valueForKey:@"cur_page"]intValue];
	int dataType = [[dic valueForKey:@"data_type"]intValue];
	BOOL saveSuccess;
	if(dataType == 0)
	{
		saveSuccess = [advanceQueryDAO saveRank:dataArray];
		if(saveSuccess && curPage == 0)
		{
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,[StringUtil getStringValue:newRankUpdateTime],rank_updatetime, nil];
			[userDb saveRankUpdateTime:dic];
		}
	}
	else if(dataType == 1)
	{
		saveSuccess = [advanceQueryDAO saveProf:dataArray];
		if(saveSuccess && curPage == 0)
		{
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,[StringUtil getStringValue:newProfUpdateTime],prof_updatetime, nil];
			[userDb saveProfUpdateTime:dic];
		}
	}
	else if(dataType == 2)
	{
		//					save
		saveSuccess = [advanceQueryDAO saveArea:dataArray];
		if(saveSuccess && curPage == 0)
		{
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.userId,user_id,[StringUtil getStringValue:newAreaUpdateTime],area_updatetime, nil];
			[userDb saveAreaUpdateTime:dic];
		}
	}
}

//deprecated
-(BOOL)sendMassMsg:(NSArray*)convEmpArray andConvRecord:(ConvRecord*)_convRecord
{
	return [MassConn sendMassMsg:_conncb andConvEmpArray:convEmpArray andConvRecord:_convRecord];
}
//deprecated
-(void)saveMassMsg:(MsgNotice*)msgNotice
{
	NSString *convId = [MassConn createNewConversation:msgNotice];
	if(convId)
	{
		NSString *msgId = [MassConn saveRcvMassMsg:msgNotice];
		if(msgId)
		{
			[self createLocalNotification:msgNotice];
			[self sendMsgNotice2:msgId andConvId:convId andAlert:true];
		}
	}
}

//打印日志
-(BOOL)debug:(NSString*)logStr
{
	if(_conncb)
	{
		CLIENT_Log(_conncb,[logStr cStringUsingEncoding:NSUTF8StringEncoding]);
		return YES;
	}
	return NO;
}

#pragma mark 收到消息后，查下用户是否是在线的，如果是离线的，那么就设置该用户为在线
-(void)setUserStatusToOnlineIfNotOnline:(MsgNotice*)msgNotice
{
    if(msgNotice.isOffline == 1)
    {
//        [LogUtil debug:[NSString stringWithFormat:@"%s,离线消息不检查状态",__FUNCTION__]];
        return;
    }
    //    取出发送消息的用户id，如果发送消息的人不是自己，并且不是离线消息，那么就需要判断状态
    int senderId = msgNotice.senderId;
    if(senderId != self.userId.intValue)
    {
        //    判断用户状态是否在线
        NSArray *_empArray = [self getEmpByEmpId:senderId];
        if(_empArray.count > 0)
        {
            Emp *_emp = [_empArray objectAtIndex:0];
            //            [LogUtil debug:[NSString stringWithFormat:@"%s,senderId is %d,emp_status is %d,return",__FUNCTION__,senderId,_emp.emp_status]];
            
            if(_emp.emp_status == status_online || _emp.emp_status == status_leave)
            {
                //                [LogUtil debug:[NSString stringWithFormat:@"emp_status is online or leave,return"]];
                return;
            }
            //            update by shisp 如果发现用户发来了消息，但用户又不在线，那么获取状态变化
            //            [self getUserStateList:NO];
            
            //            //    如果不是在线，那么就更改状态
            [LogUtil debug:[NSString stringWithFormat:@"update userstatus"]];
            //            设置为在线，默认为pc登录
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:senderId],@"emp_id",[StringUtil getStringValue:status_online],@"emp_status",[StringUtil getStringValue:TERMINAL_PC],@"emp_login_type", nil];
            
            NSArray *statusArray = [NSArray arrayWithObject:dic];
            
            [self updateEmpStatusOfStatusNotice:statusArray];
        }
    }
}

//deprecated
-(void)saveUpdateInfo:(ASIHTTPRequest*)request
{
    int statuscode=[request responseStatusCode];
    
    if(statuscode == 404)
	{//文件不存在
        [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
        self.updateInfo = @"";
	}
    else
    {
        
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        self.updateInfo = [NSString stringWithContentsOfFile:request.downloadDestinationPath encoding:gbkEncoding error:nil];
        
    }
}
//deprecated
-(void)downloadUpdateInfoFail:(ASIHTTPRequest*)request
{
    [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
    self.updateInfo = @"";
}

-(CONNCB *)getConnCB
{
	return _conncb;
}

//deprecated
- (int)getSpeicalTime
{
    if(self.newBlacklistUpdateTime && self.newBlacklistUpdateTime.length > 0)
    {
        NSRange _range = [self.newBlacklistUpdateTime rangeOfString:@"|"];
        if(_range.length > 0)
        {
            int specialTime = [[self.newBlacklistUpdateTime substringToIndex:_range.location]intValue];
            return specialTime;
        }
    }
    return 0;
}

//deprecated
- (int)getWhiteTime
{
    if(self.newBlacklistUpdateTime && self.newBlacklistUpdateTime.length > 0)
    {
        NSRange _range = [self.newBlacklistUpdateTime rangeOfString:@"|"];
        if(_range.length > 0)
        {
            int whiteTime = [[self.newBlacklistUpdateTime substringFromIndex:_range.location + 1]intValue];
            return whiteTime;
        }
    }
    return 0;
}

//deprecated
- (void)setNewBlacklistTime:(int)specialTime andWhiteTime:(int)whiteTime
{
    self.newBlacklistUpdateTime = [NSString stringWithFormat:@"%d|%d",specialTime,whiteTime];
}

#pragma mark 获取所有部门资料，返回一个不可变的数组
- (NSArray *)getAllDeptInfoArray
{
    NSArray *_array = [NSMutableArray arrayWithArray:self.onlineEmpCountArray];
    return _array;
}

#pragma mark 获取所有员工资料，返回一个不可变的数组
- (NSArray *)getAllEmpInfoArray
{
    NSArray *_array = [NSMutableArray arrayWithArray:self.allEmpArray];
    return _array;  
}

//获取并保存用户状态后，需要完成的操作 应该是收取完离线消息后进行的数据同步操作
- (void)executeAfterSaveUserStatus
{
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    //    同步收藏
    [[CollectionConn getConn]sendCollectionSync:nil];

#else
    //    主动拉取固定订阅者状态
    [_statusConn getCommonEmpStatus];
    
    //查询需要下载头像的联系人，如果收到了快同步信息，那么就可以确定是否下载头像
    self.contactNeedDownloadLogo = [db selectContactNeedDownLoadLogo];
    
    //    同步用户资料
    [self getEmployeeInfo:nil];
    [empLogoConn syncEmpLogo];
    
    //		同步公众号
    [PSConn psSyncRequest:_conncb andFromUser:self.userId];
    
    
    // 同步公众号菜单
    //    [self syncpsMenuListSyncRequest];
    
    // 同步虚拟组 by yanlei
    [self sendVirtualGroupReq];
    
    //        给越秀地产打测试版本，不需要获取黑名单
    [[BlackListConn getConn]getBlacklist];
    
    //    同步常用联系人
    [_userDataConn sendUserDataSync:user_data_type_emp];
#ifdef _LANGUANG_FLAG_
    
    [_userDataConn getLGCommonGroup:nil];
    
#endif
    //    同步常用部门
    [_userDataConn sendUserDataSync:user_data_type_dept];
    
    //    同步缺省联系人
    [_userDataConn sendUserDataSync:user_data_type_default_common_emp];
    
    //    同步收藏
    [[CollectionConn getConn]sendCollectionSync:nil];
    
    //    换成在员工与部门关系同步完成后，发出固定群组同步请求
    //    [_userDataConn sendSystemGroupSync];

#endif
}


//根据deptid获取保存在内存里的部门对象
- (DeptInMemory *)getDeptInMemoryByDeptId:(int)deptId
{
    DeptInMemory *dept = [_conn.allDeptsDic valueForKey:[StringUtil getStringValue:deptId]];
    return dept;
}
//deprecated
- (void)setAllDeptsNotSelect
{
    for (DeptInMemory *_dept in _conn.onlineEmpCountArray) {
        if (_dept.isChecked) {
            _dept.isChecked = NO;
        }
    }
}

- (int)getCompId
{
    NSString *sCompId = [[NSUserDefaults standardUserDefaults]valueForKey:@"COMP_ID"];
    return sCompId.intValue;
}

//同步通讯录失败
- (void)downloadOrgError:(NSString *)errorStr
{
    [LogUtil debug:errorStr];
    //                update by shisp 设置未连接状态
    _conn.connStatus = not_connect_type;

    [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
}

//根据员工账号找到内存里对应的联系人模型
- (Emp *)getEmpByEmpCode:(NSString *)empCode
{
    if (empCode && empCode.length > 0)
    {
        [self getAllEmpArray];
        
        return [self.empCodeAndEmpDic objectForKey:[empCode lowercaseString]];
    }
    return nil;
}

//增加一个刷新组织结构的方法，因为有几个地方在调用，所以写一个公共的方法
- (void)sendRefreshOrgNotification
{
    eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
    _notificationObject.cmdId = refresh_org;
    
    [[NotificationUtil getUtil]sendNotificationWithName:ORG_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
}

//查看部门时间戳，员工与部门关系时间戳，如果都没有变化，则状态为收取中，否则会同步组织架构，前提时必须登录完成取到新的时间戳才能使用这个方法
- (void)setCurConnStatus
{
	if([self.oldDeptUpdateTime compare:self.deptUpdateTime] == NSOrderedAscending || [self.oldEmpDeptUpdateTime compare:self.empDeptUpdateTime] == NSOrderedAscending)
    {
        self.connStatus = download_org;
    }
    else
    {
        self.connStatus = rcv_type;
    }

}

//增加一个方法，根据状态返回不同的提示
- (NSString *)getTips
{
    NSString *tips = @"";
    switch (self.connStatus) {
        case not_connect_type:
            tips = [NSString stringWithFormat:[StringUtil getLocalizableString:@"contact_noConnecting"],[StringUtil getAppLocalizableString:@"main_chats"]];
            break;
        case linking_type:
            tips = [NSString stringWithFormat:[StringUtil getLocalizableString:@"contact_connecting"],[StringUtil getAppLocalizableString:@"main_chats"]];
            break;
        case download_org:
            tips = self.downloadOrgTips;
            break;
        case rcv_type:
            tips = [NSString stringWithFormat:[StringUtil getLocalizableString:@"contact_loading"],[StringUtil getAppLocalizableString:@"main_chats"]];
            break;
        case normal_type:
            tips = [StringUtil getAppLocalizableString:@"main_chats"];
            break;
            
        default:
            break;
    }
    return tips;
}


//增加一个方法发送收到消息应答，现在修改为入库完成后，再发送
- (void)sendRcvMsgAckWithMsgId:(long long)srcMsgId andNetId:(int)netID
{
    if(self.userStatus == status_offline)
    {
        [LogUtil debug:@"用户已经离线，不再发送消息收到应答"];
        return;
    }
    
    if (srcMsgId == lastRcvMsgId && netID == lastRcvNetId) {
//        如果和上次完全相同，则本次不用发
        [LogUtil debug:@"和上次发的一致，不再重复发送"];
        return;
    }
    
    int nRet = CLIENT_SendMsgNoticeAck(_conncb, srcMsgId,netID);
    lastRcvMsgId = srcMsgId;
    lastRcvNetId = netID;
    
    [LogUtil debug:[NSString stringWithFormat:@"发送消息收到应答:%lld,%d,nRet is %d",srcMsgId,netID,nRet]];
}

//同步固定群组 应答，无论是收到删除通知，还是创建通知(又分了两种，一种不用分包，一种需要分包)，都要计数加1，并且判断是否收取处理完毕，开始获取离线消息
- (void)checkAndFinishSystemGroupSync
{
    if (self.systemGroupSyncCount > 0 && self.systemGroupSyncCount == self.systemGroupCurCount) {
        //                                保存时间戳
//        [userDb saveVGroupUpdateTime:nil];
        self.systemGroupCurCount = 0;
        self.systemGroupSyncCount = 0;
        self.needCountSystemGroup = NO;
        //                                发送离线消息
        
//        先同步机器人，再获取离线消息
        [[RobotConn getConn]syncRobotInfo];
        
//        [self getOfflineMsgNum];
    }
}

//保存公众号的消息
- (void)savePSMsg:(NSString *)psMsg{
    NewMsgNotice *_notice = [PSConn savePSMsg:psMsg];
    if(_notice)
    {
        settingRemindController *remindController = [settingRemindController initSettingRemind];
        remindController.soundFlag = 1;
        [remindController checkRemindType];
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = rev_msg;
        [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:_notice, @"msg_notice",nil]];
    }
}

//收到公众号消息时加到队列里进行保存
- (void)processPSMSg:(MsgNotice *)msgNotice
{
    if (msgNotice.isOffline) {
        self.offlineMsgTotal = msgNotice.offMsgTotal;
        self.offlineMsgCurCount++;
        
        if (self.offlineMsgCurCount == self.offlineMsgTotal) {
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 离线消息数量为%d，当前收到的离线消息数量为%d",__FUNCTION__,self.offlineMsgTotal,self.offlineMsgCurCount]];

            [self performSelectorOnMainThread:@selector(cancelOfflineMsgTimer) withObject:nil waitUntilDone:YES];
        }
        else
        {
            //			重新计算超时
            [self performSelectorOnMainThread:@selector(cancelOfflineMsgTimer) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(processRcvOfflineMsgTimeout:) withObject:[NSNumber numberWithInt:5] waitUntilDone:YES];
        }
        
        [self savePSMsg:msgNotice.msgBody];
        
        if (!self.isOfflineMsgFinish && self.offlineMsgTotal > 0 && self.offlineMsgCurCount == self.offlineMsgTotal) {
            [self sendRcvOfflineMsgFinishNotify];
        }
    }
    else
    {
        [self savePSMsg:msgNotice.msgBody];
    }
    
    CLIENT_SendMsgNoticeAck(_conncb, msgNotice.msgId , msgNotice.netID);
}


//自动发送消息 自动获取群组资料
- (void)autoSendMsgAndGetGroupInfo
{
    //发送中的消息，自动发送出去
    NSArray *sendingRecords = [db getAllSendingRecords];
    if(sendingRecords && sendingRecords.count > 0)
    {
        for(ConvRecord *_record in sendingRecords)
        {
            [self reSendMsg:_record];
        }
    }
    
    //		没有获取群组消息的群组，自动获取群组消息
    //    只获取内存里就够了
    //    NSArray *convNeedGetGroupInfo = [db selectConvNeedGetGroupInfo];
    //    if(convNeedGetGroupInfo)
    //    {
    //        for(NSString *convId in convNeedGetGroupInfo)
    //        {
    //            [LogUtil debug:[NSString stringWithFormat:@"数据库里需要获取群组资料 convid is %@",convId]];
    //            [self getGroupInfo:convId];
    //        }
    //    }
    
}


//增加一个方法 发出登录结果的通知 万达版本使用
- (void)sendWandaLoginNotification:(int)retCode
{
    [[NotificationUtil getUtil]sendNotificationWithName:com_wanda_ecloud_im_login andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:retCode] forKey:key_login_ret_code]];
}

//应用激活的时候生成通知，提示用户
- (void)presentNotificationWhenAppActive:(NSDictionary *)dic
{
    UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];

    if (appState == UIApplicationStateActive) {
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_PUSH];
        
#ifdef _XIANGYUAN_FLAG_
//        祥源不判断这个值
        str = nil;
#endif
        
        if ([str isEqualToString:@"YES"]) {
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 点通知进来，不弹出自定义通知栏 %@",__FUNCTION__,str]];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:APPLICATION_PUSH];
            
        }else{
            
            if (self.connStatus == normal_type ||self.connStatus == rcv_type) {
                NSString *_title = dic[KEY_NOTIFICATION_TITLE];
                NSString *_msg = dic[KEY_NOTIFICATION_MESSAGE];
                int appid = [dic[KEY_NOTIFICATION_APP_ID] intValue];
                
#ifdef _LANGUANG_FLAG_
                
                _title = @"蓝信";
                _msg = dic[@"newTitle"];
                [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:nil];
#endif
                
#ifdef _XIANGYUAN_FLAG_
                
                NSDictionary *dict = dic[@"message"];
                _title = dict[@"title"];
                _msg = dict[@"content"];
#endif
            
                [HDNotificationView showNotificationViewWithImage:[StringUtil getImageByResName:@"logo_about.png"]
                                                            title:_title
                                                          message:_msg
                                                       isAutoHide:YES
                                                          onTouch:^{
                                                              
                                                              [LogUtil debug:[NSString stringWithFormat:@"%s 弹出自定义通知栏 %@",__FUNCTION__,str]];
                                                              [HDNotificationView hideNotificationViewOnComplete:nil];
                                                              
#ifdef _XIANGYUAN_FLAG_
                                                              NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                              
                                                              //            这个url并不是服务器推送的，是客户端自己确定的
                                                              NSString *urlString = [[ServerConfig shareServerConfig]getXYDAIBANUrl];
                                                              
                                                              [mDic setObject:urlString forKey:KEY_NOTIFICATION_APP_URL];
                                                              if ([TabbarUtil getTabbarController])
                                                              {
                                                                  [TabbarUtil showMyPage];
                                                                  [TabbarUtil saveStartAppInfo:mDic];
                                                                  
                                                              }
                                                              
#endif
                                                              
#ifdef _LANGUANG_FLAG_
                                                              UIViewController *vc1 = [UIAdapterUtil getPresentedViewController];
                                                              if (vc1) {
                                                                  [vc1 dismissViewControllerAnimated:YES completion:^{
                                                                      NSLog(@"close");
                                                                  }];
                                                              }
                                                              //                                                  UIViewController *vc2 = [UIAdapterUtil getCurrentVC];
                                                              [[ApplicationManager getManager]enterAppByClickNotification:dic];
//                                                              if ([TabbarUtil getTabbarController])
//                                                              {
//                                                                  [TabbarUtil showMyPage];
//                                                                  
//                                                              }
                                                              
                                                              //                                                  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults getAppId]];
                                                              //                                                  [dict setObject:@"NO" forKey:[NSString stringWithFormat:@"%d",appid]];
                                                              //                                                  [UserDefaults saveAppId:dict];
#endif
                                                          }];
                
                
            }
        }
    }
}

#pragma mark 重写设置 status 方法
- (void)setConnStatus:(int)connStatus
{
    _connStatus = connStatus;
    [StatusMonitor getStatusMonitor].connStatus = _connStatus;
}

- (void)setDownloadOrgTips:(NSString *)downloadOrgTips
{
    if (_downloadOrgTips != nil) {
        [_downloadOrgTips release];
    }
    _downloadOrgTips = [downloadOrgTips retain];
    [StatusMonitor getStatusMonitor].downloadOrgTips = _downloadOrgTips;
}
@end
