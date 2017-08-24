//收到部门和员工关系数据后，先保存起来，等收完再入库

#import <Foundation/Foundation.h>

@interface EmpDeptDL : NSObject
{
	int _empId;
	int _deptId;
	NSString *_empCode;
}
@property(nonatomic,assign)int empId;          /** 用户ID */
@property(nonatomic,assign)int deptId;         /** 部门ID */
@property(nonatomic,retain)NSString *empCode;  /** 员工编号 */

//add by shisp 增加用户姓名，性别和头像url
@property(nonatomic,retain) NSString* empName; /** 用户姓名 */
@property(nonatomic,retain) NSString *empLogo; /** 头像url */
@property(nonatomic,assign) int empSex;        /** 性别 */

//增加级别，业务，地域
@property(assign) int rankId; /** 级别 */
@property(assign) int profId; /** 业务 */
@property(assign) int areaId; /** 地域 */

//增加员工级别
@property(nonatomic,assign) int empSort;

//增加员工英文名称
@property (nonatomic,retain) NSString *empNameEng;

//增加一个修改类型，如果是删除 也是在保存到数据库里时删除，不再收报文的过程中删除

@property (nonatomic,assign) int updateType;

@end
