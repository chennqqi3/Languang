
#import "eCloud.h"

@class eCloud;
@class Emp;

@interface OrgDAO : eCloud
{
	
}

/**
 功能描述
 增加公司
 
 参数 compId 公司ID compName 公司名字
 */
-(void)addCompany:(NSString *)compId andName:(NSString*)compName;

/**
 功能描述
 根据公司id，查询公司的信息
 
 参数 compId 公司ID
 返回值 可变数组
 */
-(NSString *)getCompanyNameBy:(NSString *) compId;

/**
 功能描述
 保存部门
 
 参数 info 部门数组
 返回值 YES 成功 NO 失败
 */
-(bool)addDept:(NSArray *)info;

/**
 功能描述
 查询一个部门
 
 参数 deptId 部门ID
 返回值 YES 成功 NO 失败
 */
-(NSDictionary *)searchDept:(NSString*)deptId;

/**
 功能描述
 删除部门
 
 参数 info 部门素组
 */
-(void)delDepts:(NSArray *)info;

/**
 功能描述
 取出某一部门下的所有子部门
 
 参数 deptParent 父部门
 返回值 可变数组
 */
-(NSArray *)getChildDepts:(NSString*)deptParent;

/**
 功能描述
 add by shisp 检测下dept_name_contain_parent 字段，如果还没有计算，那么先计算，否则返回
 
 */
- (void)calculateDeptNameContainParentOfDept;

/**
 功能描述
 查询所有的部门id，返回所有的deptid，每个deptid对应的在线人数为0，增加获取部门的所有父部门

 返回值 nil
 */
-(NSArray*)getAllDeptId;

/**
 功能描述
 查询部门表，查询每一个部门，并且找到其所有直接或间接的子部门，并保存到相应数据库
 
 返回值 YES 成功 NO 失败
 */
-(bool)saveDeptSubDept;

/**
 功能描述
 保存每个部门的所有的父亲部门
 
 返回值 YES 成功 NO 失败
 */
-(bool)saveDeptParentDept;

/**
 功能描述
 修改用户自己的状态，包括修改用户表及员工表里的用户状态的值
 
 参数 userId 员工ID status 员工状态

 */
-(void)updateUserStatus:(NSString*)userId andStatus:(int)status;

/**
 功能描述
 删除联系人和部门的对应关系
 
 参数 info 员工数组
 */
-(void)delEmpDepts:(NSArray *)info;

/**
 功能描述
 组织架构---保存员工数据，部门与员工关系数据
 
 参数 empDepts 员工与部门关系数组
 
 返回值 YES 成功 NO 失败
 */
-(bool)saveEmpDepts:(NSArray*)empDepts;

/**
 功能描述
 同门数据后，更新部门总人数信息步完员工部
 
 返回值 YES 成功 NO 失败
 */
-(bool)updateDeptEmpCount;

/**
 功能描述
 修改用户状态
 
 参数 info 用户数组

 */
-(void)updateEmpStatus:(NSArray *)info;

/**
 功能描述
 设置所有人员的状态为离线
 
 */
-(void)setAllEmpsToOffline;

/**
 功能描述
 根据部门id，获取部门的所有员工信息,并定位级别（废弃代码）
 
 参数 deptId 部门ID level 级别
 返回值 可变数组
 */
-(NSArray *)getDeptEmpInfoWithLevel:(NSString *)deptId andLevel:(int)level;

/**
 功能描述
 取出某一部门所有父部门
 
 参数 deptParent 父部门
 返回值 可变数组
 */
-(NSArray *)getParentDepts:(NSString*)deptParent;

/**
 功能描述
 根据上级部门id，获取直接子部门，并定位级别
 
 参数 deptParent 父部门 level 级别
 返回值 可变数组
 */
-(NSArray *)getLocalNextDeptInfoWithLevel:(NSString *)deptParent andLevel:(int)level;

/**
 功能描述
 选择部门下所有员工，并设置选择状态
 
 参数 deptId 部门ID level 级别 isSelected 选中状态
 返回值 数组
 */
-(NSArray *)getDeptEmpInfoWithSelected:(NSString *)deptId andLevel:(int)level andSelected:(bool)isSelected;

/**
 功能描述
 并是否选中 根据上级部门id，获取直接子部门，并定位级别
 
 参数 deptParent 父部门 level 级别 isSelected 选中状态
 返回值 数组
 */
-(NSArray *)getLocalNextDeptInfoWithSelected:(NSString *)deptParent andLevel:(int)level andSelected:(bool)isSelected;

/**
 功能描述
 增加一个方法，获取员工总人数，是员工部门表和员工表通过emp_id链接后的记录的总数
 
 返回值 员工总人数
 */
- (int)getDeptEmpCount;

/**
 功能描述
 获取所有人员放在内存中
 
 返回值 nil
 */
-(NSArray *)getEmployeeList;

/**
 功能描述
 获取部门，选择聊天成员时使用
 
 返回值 包含父部门名称的部门名称
 */
-(NSArray *)getDeptList;

/**
 功能描述
 获取某部门人员数量
 
 参数 dept_id 部门ID
 
 返回值 某个部门的人员数量
 */
-(int)getDeptNumBy:(int)dept_id;

/**
 功能描述
 修改某用户的empinfoflag为N
 
 参数 empId 用户id
 
 */
-(void)updateEmpInfoFlag:(NSString*)empId;

/**
 功能描述
 保存员工资料
 
 参数 info 员工数组
 
 */
-(void)addEmp:(NSArray *)info;

/**
 功能描述
 修改多个员工的信息
 
 参数 info 员工数组
 
 */
-(void)updateEmp:(NSArray *)info;

/**
 功能描述
 根据员工id查找员工名字
 
 参数 emp_id 用户id
 
 返回值 如果名字为空，返回员工工号，如果工号为空，则返回用户id
 */
-(NSString *)getEmpNameByEmpId:(NSString *)emp_id;

/**
 功能描述
 查询员工
 
 参数 emp_id 用户id
 
 返回值 如果返回nil，则没有查询到，否则返回员工字典
 */
-(NSDictionary *)searchEmp:(NSString*)empId;

/**
 功能描述
 根据工号查询用户资料
 
 参数 usercode 用户账号
 
 返回值 如果返回nil，则没有查询到，否则返回用户资料字典
 */
-(NSDictionary *)searchEmpInfoByUsercode:(NSString*)usercode;


/**
 根据员工id找到员工所在部门

 @param empId 员工id
 @return 返回员工所在部门
 */
- (NSString *)getEmpDeptNameByEmpId:(NSString *)empId;

/**
 功能描述
 查询本地用户资料，除包括基本信息如果id，名称，性别外，还包括部门名称，职务名称，email，手机号等信息
 
 参数 empId 用户id
 
 返回值 如果返回nil，则没有查询到，否则返回Emp模型
 */
-(Emp *)getEmpInfo:(NSString*)empId;

/**
 功能描述
 根据empCode，在内存里找到对应的emp
 
 参数 empCode 用户账号
 
 返回值 Emp模型
 */
-(Emp*)getEmpFromMemoryByEmpCode:(NSString *)empCode;

/**
 功能描述
 根据工号查询本地用户资料
 
 参数 empCode 用户账号
 
 返回值 如果返回nil，则没有查询到，否则返回Emp模型
 */
-(Emp *)getEmpInfoByUsercode:(NSString*)usercode;

/**
 功能描述
 按emp_id 获取 人员信息 ,和getEmpInfo的区别是没有获取部门
 
 参数 emp_id 用户ID
 
 返回值 如果返回nil，则没有查询到，否则返回Emp模型
 */
-(Emp *)getEmployeeById:(NSString *)emp_id;

/**
 功能描述
 根据empName,获取Emp信息
 
 参数 empName 用户姓名
 
 返回值 返回nil，则没有查询到，否则返回Emp模型如果
 */
-(Emp *)getEmpInfoByEmpName:(NSString *)empName;

/**
 功能描述
 删除人员
 
 参数 info 用户数组

 */
-(void)delEmps:(NSArray *)info;

/**
 功能描述
 如果用户详细料不是最新的，那么获取最新的用户资料并下载头像，如果是最新的，则检查头像是否存在，如果不存在则下载头像资，如果第一次和某个人单聊，或者是收到一条消息，并且是发送人第一次向这个群组发消息
 
 参数 empId 用户ID
 
 */
-(void)getUserInfoAndDownloadLogo:(NSString*)empId;

/**
 功能描述
 根据拼音或者名称查询部门
 
 废弃代码 by shisp
 
 */
-(NSArray *)getDeptByNameOrPinyin:(NSString*)searchText andType:(int)_type;

/**
 功能描述
 在会话列表界面增加了搜索功能，可以根据群组人员名称进行搜索，因为群组成员表里只保持了userid，因此查询要分两步，第一步是根据用户输入查询userid，第二步是根据userid，查询群组成员表，得到符合条件的群组
 
 参数 searchText 需要查询的关键字
 
 返回值 结果为可变数组
 */
-(NSArray *)searchUserBy:(NSString*)searchText;

/**
 功能描述
 根据拼音或者姓名查询联系人
 
 参数 searchText 需要查询的关键字 _type 查询的类型
 
 返回值 结果为可变数组
 */
-(NSArray *)getEmpsByNameOrPinyin:(NSString*)searchText andType:(int)_type;

/**
 功能描述
 筛选结果

 返回值 结果为可变数组
 */
-(NSArray *)getChooseArray;

/**
 功能描述
 最近讨论组，最近联系人
 
 返回值 结果为可变数组
 */
-(NSArray *)getTypeArray;

/**
 功能描述
 选择最近联系人下所有员工，并设置选择状态
 
 废弃代码 by shisp
 */
-(NSArray *)getRecentEmpInfoWithSelected:(NSString *)typeId andLevel:(int)level andSelected:(bool)isSelected;

/**
 功能描述
 选择最近讨论组下所有员工，并设置选择状态
 
 废弃代码 by shisp
 */
-(NSArray *)getRecentGroupMemberWithSelected:(NSString *)typeId andLevel:(int)level andSelected:(bool)isSelected andConvId:(NSString *)conv_id;

/**
 功能描述
 更新用户宅电
 
 参数 telephone 电话 userid 用户id
 */
-(void)updateUserHomeTel:(NSString *)telephone :(int)userid;

/**
 功能描述
 用户紧急联系电话
 
 参数 telephone 电话 userid 用户id
 */
-(void)updateUserEmergencyTel:(NSString *)telephone :(int)userid;

/**
 功能描述
 用户电话
 
 参数 telephone 电话 userid 用户id
 */
-(void)updateUserTelephone:(NSString *)telephone :(int)userid;

/**
 功能描述
 用户手机
 
 参数 mobileStr 手机 userid 用户id
 */
-(void)updateUserMobile:(NSString *)mobileStr :(int)userid;

/**
 功能描述
 用户性别
 
 参数 sex 性别 userid 用户id
 */
-(void)updateUserSex:(int)sex :(int)userid;

/**
 功能描述
 用户职务
 
 参数 position 职务 userid 用户id
 */
-(void)updateUserPosition:(NSString *)position :(int)userid;

/**
 功能描述
 用户头像
 
 参数 Avatar 头像 userid 用户id
 */
-(void)updateUserAvatar:(NSString *)Avatar :(int)userid;

/**
 功能描述
 用户邮件
 
 参数 mail 邮件 userid 用户id
 */
-(void)updateUserMail:(NSString *)mail :(int)userid;

/**
 功能描述
 用户地址
 
 参数 address 地址 userid 用户id
 */
-(void)updateUserAddress:(NSString *)address :(int)userid;

/**
 功能描述
 用户签名
 
 参数 signature 签名 userid 用户id
 */
-(void)updateUserSignature:(NSString *)signature :(int)userid;

#pragma mark
/**
 功能描述
 收到用户头像修改通知后，保存新的头像url
 
 参数 empId 员工id logo 新头像的url
 */
-(void)updateEmpLogo:(NSString*)empId andLogo:(NSString*)logo;

/**
 功能描述
 emp赋值
 
 参数 emp 员工模型
 */
-(void)putDicData:(NSDictionary*)dic toEmp:(Emp*)emp;

/**
 功能描述
 emp赋值
 
 参数 dic 员工字典
 
 返回值 员工模型
 */
-(Emp *)getEmpByDicData:(NSDictionary *)dic;

/**
 功能描述
 查询第一个还未获取员工资料的员工id
 
 返回值 员工ID
 */
-(int)selectFirstNoDetailEmpId;

/**
 功能描述
 根据部门查询人员
 
 参数 dept_id 部门ID level 级别
 
 返回值 可变数组
 */
-(NSArray *)getEmpsByDeptID:(int)dept_id andLevel:(int)level;

/**
 功能描述
 获取特殊用户列表的时候，需要发送用户自己所在部门数组
 
 返回值 可变数组
 */
- (NSArray *)getUserDeptsArray;

/**
 功能描述
 根据empId返回部门id
 
 参数 empId 用户id
 
 返回值 可变数组
 */
- (NSArray *)getDeptCountByEmpId:(int)empId;

/**
 功能描述
 保存用户的简要信息
 
 参数 emp 用户模型

 */
- (void)saveCurUserBriefInfo:(Emp *)emp;

/**
 功能描述
 设置是否需要限制查询人数 add by shisp
 
 参数 needLimit 是否限制
 
 */
- (void)setLimitWhenSearchUser:(BOOL)needLimit;

/**
 功能描述
 手动刷新组织架构

 */
- (void)refreshOrgByHand;

/**
 功能描述
 根据用户账号得到对应的Emp对象
 
 参数 userAccount 用户账户
 
 返回值 返回nil，则没有查询到，否则返回Emp模型如果
 */
- (Emp *)getEmpByUserAccount:(NSString *)userAccount;

/**
 功能描述
 根据用户账号得到id
 
 参数 userAccount 用户账户
 
 返回值 如果没有找到，则返回-1，否则返回id
 */
- (int)getEmpIdByUserAccount:(NSString *)userAccount;

/**
 功能描述
 获取我的电脑这个一级部门的部门id
 
 返回值 如果没有找到，则返回-1，否则返回id
 */
- (int)getDeptIdOfMyComputerDept;

/**
 功能描述
 根据用户id获取其rank_id
 
 参数 userId 用户ID
 
 返回值 如果没有找到，则返回-1，否则返回id
 */
- (int)getRankIdWithUserId:(int)userId;

/**
 功能描述
 删除员工与部门关系数据 删除员工数据 启动重新同步 南航需求 用户级别更换后，需要重新获取 哪些用户隐藏 哪些用户显示

 */
- (void)clearEmpDeptData;

/** 华夏不同步通讯录 保存一个默认的部门 */
- (void)saveHXDefaultDept;

/** 从华夏取到人员后保存在本地 */
- (BOOL)saveHXEmpToDB:(Emp *)_emp;


#pragma mark =====隐藏部分部门相关======
//修改所有部门的display_flag
- (BOOL)updateAllDeptWithDisplayFlag:(int)displayFlag;

//保存特殊的部门显示标志
- (BOOL)updatePartDeptDisplayFlags:(NSArray *)array;

#pragma mark ========祥源部门隐藏========
/** 显示一个部门的父节点和子节点 */
- (void)displayParentDeptAndSubDept:(int)deptId;

/** 隐藏一个部门的父节点和子节点，只有父部门没有可显示的部门时，隐藏父部门 */
- (void)hideDeptAndSubDept:(int)deptId;

/** 确定某个部门是否需要显示 如果没有一个需要显示的子部门，则不显示 */
- (void)hideOrDspDept:(int)deptId;

/** 显示默认部门 找到用户自己所在部门的二级部门，显示此部门 */
- (void)dspDefaultDept;
    
/** 新华网 增加一个系统管理员用户 */
- (void)addSystemUser;

/** 获取一个用户所在的部门 */
- (NSArray *)getDeptByEmpId:(int)empId;

#pragma mark 获取所有讨论组
-(NSArray *)getAllGroupArray;

//如果是蓝光，因为要显示常用联系人所在部门和职位，所以这里还要给常用联系人的部门属性赋值
- (void)setEmpDeptAttrOfLG:(Emp *)emp;


@end
