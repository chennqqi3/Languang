//个人漫游数据相关的数据库定义与操作

#import "eCloud.h"

@interface UserDataDAO : eCloud

+ (UserDataDAO *)getDatabase;

/**
 功能描述
 建数据库表
 
 */
- (void)createTable;

#pragma mark ===========常用联系人===============

/**
 功能描述
 添加常用联系人
 
 参数 empIdArray 要添加的员工数组 isDefault 是否是默认的
 */
- (void)addCommonEmp:(NSArray *)empIdArray andIsDefault:(BOOL)isDefault;

/**
 功能描述
 删除常用联系人
 
 参数 empId 员工id
 */
- (void)removeCommonEmp:(int)empId;

/**
 功能描述
 获取所有常用联系人
 
 返回值 emp模型的可变数组
 */
- (NSArray *)getAllCommonEmp;


/**
 功能描述
 获取所有联系人
 
 返回值 emp模型的可变数组
 */
- (NSArray *)getAllEmp;

/**
 功能描述
 判断一个用户是否常用联系人
 
 参数 empId 员工id
 
 返回值 YES 是 NO 否
 */
- (BOOL)isCommonEmp:(int)empId;

/**
 功能描述
 添加一个常用联系人
 
 参数 empId 员工id isDefault 是否是默认的
 
 */
- (void)addOneCommonEmp:(int)empId andIsDefault:(BOOL)isDefault;

/**
 功能描述
 删除多个常用联系人
 
 参数 empIdArray 员工id数组
 */
- (void)removeCommonEmps:(NSArray *)empIdArray;

/**
 功能描述
 删除所有的常用联系人，不包含缺省联系人
 
 参数 isDefault 是否是默认的
 */
- (void)removeAllCommonEmps:(BOOL)isDefault;

#pragma mark ===========常用部门===============

/**
 功能描述
 添加部门
 
 参数 deptIdArray 部门ID数组
 */
- (void)addCommonDept:(NSArray *)deptIdArray;

/**
 功能描述
 删除多个部门
 
 参数 deptIdArray 部门ID数组
 */
- (void)removeCommonDepts:(NSArray *)deptIdArray;

/**
 功能描述
 删除部门
 
 参数 deptId 部门id
 */
- (void)removeCommonDept:(int)deptId;

/**
 功能描述
 获取所有常用部门
 
 返回值 部门可变数组
 */
- (NSArray *)getAllCommonDept;

/**
 功能描述
 获取所有常用部门
 
 返回值 部门可变字典
 */
- (NSMutableDictionary *)getAllCommonDeptDic;

/**
 功能描述
 删除所有的常用部门 因为假如常用部门有变化，服务器返回的是全量的常用部门数据
 
 */
- (void)removeAllCommonDepts;

/**
 功能描述
 删除所有的常用部门 因为假如常用部门有变化，服务器返回的是全量的常用部门数据
 
 参数 deptId 部门id
 */
-(BOOL)isCommonDept:(NSInteger) deptId;

#pragma mark ===========固定群组===============

/**
 功能描述
 保存固定群组
 
 参数 dic 会话字典 empArray 成员数组
 */
- (void)addSystemGroup:(NSDictionary *)dic andValues:(NSArray *)empArray;

/**
 功能描述
 更新固定组
 
 参数 convId 会话id
 */
-(void)updateSystemGroup:(NSString *)convId andValues:(NSDictionary *)dic;

/**
 功能描述
 获取所有固定群组
 
 返回值 修改好的数组
 */
- (NSArray *)getALlSystemGroup;

/**
 获取指定条件的固定群 或 讨论组 集合

 @param groupType 组类型：  固定群 1  或  讨论组  2
 @param whereSql  条件

 @return 符合条件的集合
 */
- (NSArray *)getGroupsBytype:(int)groupType where:(NSString *)whereSql;

/**
 功能描述
 判断一个群组是否固定群组
 
 参数 convId 会话id
 
 返回值 成功yes 失败no
 */
- (BOOL)isSystemGroup:(NSString *)convId;

/**
 功能描述
 判断自己释放是固定组的管理员
 
 参数 convId 会话id
 
 返回值 成功yes 失败no
 */
- (BOOL)isAdminOfConv:(NSString *)convId;

/**
 功能描述
 删除固定组
 
 参数 convId 会话id
 
 */
-(void)deleteSystemGroup:(NSString *)convId;

/**
 功能描述
 增加固定组成员
 
 参数 empArray 成员数组
 
 */
-(void)addSystemGroupEmp:(NSArray *)empArray;

/**
 功能描述
 删除固定组成员
 
 参数 empArray 成员数组
 
 */
-(void)deleteSystemGroupEmp:(NSArray *)empArray;

/**
 功能描述
 设置为固定组管理员
 
 参数 empArray 成员数组
 
 */
-(void)setAdminOfSystemGroupEmp:(NSArray *)empArray;

/**
 功能描述
 更新固定群组名称
 
 参数 dic 成员字典
 
 */
-(void)updateSystemGroupName:(NSDictionary *)dic;

#pragma mark ===========自定义群组===============
/**
 功能描述
 获取所有自定义组
 
 返回值 数组
 */
- (NSArray *)getALlCommonGroup;

/**
 按照条件获取组集合

 @param groupType 组类型:  固定群 或 讨论组
 @param whereSql  查询条件

 @return 符合条件的集合
 */
- (NSArray *)getALlGroupByType:(int)groupType where:(NSString *)whereSql;

/**
 功能描述
 判断一个群组是否常用群组
 
 参数 convId 会话id
 
 返回值 是为YES 不是为NO
 */
- (BOOL)isCommonGroup:(NSString *)convId;

/**
 功能描述
 添加一个自定义组
 
 参数 convId 会话id

 */
- (void)addOneCommonGroup:(NSString *)convId;

/**
 功能描述
 添加多个自定义组
 
 参数 convIdArray 会话id数组
 
 */
- (void)addCommonGroups:(NSArray *)convIdArray;

/**
 功能描述
 删除一个自定义组
 
 参数 convId 会话id
 
 */
- (void)removeOneCommonGroup:(NSString *)convId;

/**
 功能描述
 查询最近100个的普通的讨论组，用户选择可以添加为常用讨论组
 
 返回值 数组
 */
- (NSArray *)getRecentNormalGroups;

#pragma mark ===========缺省常联系人===============

/**
 功能描述
 添加缺省联系人
 
 参数 defalutCommonEmpArray 缺省联系人数组
 */
-(void)addDefalutCommonEmp:(NSArray*)defalutCommonEmpArray;

/**
 功能描述
 删除所有缺省联系人

 */
-(void)removeAllDefaultCommonEmp;

/**
 功能描述
 判断是否是缺省联系人
 
 参数 empId 用户id
 */
-(BOOL)isDefaultCommonEmp:(int)empId;

/**
 功能描述
 根据群组id，得到groupTypeValue
 
 参数 convId 群组id
 */
- (int)getGroupTypeValueByConvId:(NSString *)convId;

/**
 功能描述
 查询一个固定群所有的管理员
 
 参数 convId 群组id
 
 返回值 字典
 */
- (NSDictionary *)getAllAdminOfSystemGroup:(NSString *)convId;

@end
