//放在内存里的部门资料对象 shisp

#import <Foundation/Foundation.h>
@interface DeptInMemory : NSObject

@property (nonatomic,assign) int deptId;
@property (nonatomic,assign) int onlineEmpCount;
//部门的父部门
@property (nonatomic,retain) NSString *deptParentDept;
//包含父部门名称的部门名称
@property (nonatomic,retain) NSString *deptNameContainParent;
//包含父部门英文名称的英文部门名称
@property (nonatomic,retain) NSString *deptNameContainParentEng;
@property (nonatomic,assign) bool isChecked;

//部门的子部门
@property (nonatomic,retain) NSString *subDept;

//部门名称
@property (nonatomic,retain) NSString *deptName;

//部门英文名称
@property (nonatomic,retain) NSString *deptNameEng;

@end
