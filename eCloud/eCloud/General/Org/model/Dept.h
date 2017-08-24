//add by shisp 部门类

#import <Foundation/Foundation.h>

typedef enum
{
    type_dept_normal = 0,      //普通部门
    type_dept_common_contact,  //常联系人
    type_dept_common_dept,     //常用部门
    type_dept_my_group,        //我的群组
    type_dept_regular_group,     //固定群组
    type_dept_my_computer, //    南航增加 我的电脑
    type_dept_orgization //南航增加 我的组织架构
}open_dept_type;

@interface Dept : NSObject
{
    //	部门id
    int _dept_id;
    //	部门名称
    NSString *_dept_name;
    //	父部门名称
    NSString *_fdept_name;
    //	上级部门
    int _dept_parent;
    //	公司id
    int _dept_comp_id;
    //	子部门
    NSArray *_child_Depts;
    //	部门员工
    NSArray *_dept_emps;
    //	选择状态
    bool _isChecked;
    //	展开状态
    bool _isExtended;
    //级别
    int _dept_level;
    //	是否显示
    bool _display;
    //	是否已经展开过
    bool _firstExtend;
    
    int totalNum;
    int onlineNum;
    NSString *subDeptsStr;// 用逗号隔开的字符串
    //部门电话
    NSString *_dept_tel;
    
    int dept_type;//部门类型
}

/** 该部门的人数 */
@property(nonatomic,assign)int totalNum;
/** 该部门的在线人数 */
@property(nonatomic,assign)int onlineNum;
/** 部门ID */
@property(nonatomic,assign) int dept_id;
/** 部门中文名称 */
@property(nonatomic,retain) NSString *dept_name;
/** 部门英文名称 */
@property (nonatomic,retain) NSString *deptNameEng;
/** 该属性已弃用 */
@property(nonatomic,retain) NSString *fdept_name;
/** 部门电话 */
@property(nonatomic,retain) NSString *dept_tel;
/** 直接子部门 */
@property(nonatomic,retain) NSString *subDeptsStr;
/** 父部门 */
@property(nonatomic,assign) int dept_parent;
/** 该属性已弃用 */
@property(nonatomic,assign) int dept_comp_id;
/** 子部门数组 */
@property(nonatomic,retain) NSArray *child_Depts;
/** 该部门下的员工 */
@property(nonatomic,retain) NSArray *dept_emps;
/** 该部门是否已被选中 */
@property(nonatomic,assign) bool isChecked;
/** 该部门是否已展开 */
@property(nonatomic,assign) bool isExtended;
/** 部门层级 */
@property(nonatomic,assign) int dept_level;
/** 是否展示 */
@property(nonatomic,assign) bool display;
/** 该属性已弃用 */
@property(nonatomic,assign) bool firstExend;
/** 部门类型 */
@property(nonatomic,assign)int dept_type;
-(NSString *)toString;
@end
