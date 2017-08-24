//员工

#import "Emp.h"
#import "LogUtil.h"
#import "StringUtil.h"
#import "PermissionModel.h"
#import "LanUtil.h"
#import "Dept.h"
#import "eCloudDefine.h"
#import "client.h"
#import "RobotDAO.h"
#import "eCloudDAO.h"

@implementation Emp
{
    //  未读回复 一呼万应
    int unread;
    //	员工id
    int _emp_id;
    //	员工name
    NSString *_emp_name;
    //	员工sex
    int _emp_sex;
    //	员工状态
    int _emp_status;
    // 选择
    bool _isSelected;
    
    // 员工所属部门
    int _emp_dept;
    
    // 级别
    int _emp_level;
    //	员工的邮箱
    NSString *_emp_mail;
    //	员工的电话
    NSString *_emp_tel;
    //员工的手机号码
    NSString *_emp_mobile;
    //	员工的头像
    NSString *_emp_logo;
    
    //	员工的部门名称
    NSString *_deptName;
    
    //	员工的职务名称
    NSString *_titleName;
    
    //	资料是否已从服务器获取
    bool _info_flag;
    
    //	公司id
    int _comp_id;
    
    //	是否显示
    bool _display;
    
    //	工号
    NSString *_empCode;
    //	签名
    NSString *_signature;
    //	登录类型
    int _loginType;
    //	员工的宅电
    NSString *_emp_hometel;
    //	员工的宅电
    NSString *_emp_emergencytel;
    NSString *_parent_dept_list;
}

@synthesize isAddToSearchResult;

@synthesize isUserLogo;

@synthesize isDefaultCommonEmp;
@synthesize emp_id = _emp_id;
@synthesize emp_name = _emp_name;
@synthesize emp_sex = _emp_sex;
@synthesize emp_status = _emp_status;
@synthesize isSelected = _isSelected;
@synthesize emp_dept =_emp_dept;
@synthesize emp_level=_emp_level;
@synthesize emp_mail = _emp_mail;
@synthesize emp_tel = _emp_tel;

@synthesize deptName = _deptName;
@synthesize titleName = _titleName;
@synthesize info_flag = _info_flag;

@synthesize emp_mobile = _emp_mobile;
@synthesize emp_logo = _emp_logo;

@synthesize comp_id = _comp_id;

@synthesize display = _display;
@synthesize parent_dept_list=_parent_dept_list;

@synthesize empCode = _empCode;
@synthesize signature = _signature;
@synthesize loginType = _loginType;
@synthesize emp_hometel=_emp_hometel;
@synthesize emp_emergencytel=_emp_emergencytel;
@synthesize parentDept;
@synthesize empPinyinSimple;
@synthesize unread;

@synthesize msgReadTime;

@synthesize empPinyin;

@synthesize permission;
@synthesize isSpecial;

@synthesize birthday;
@synthesize birthdayStr;
@synthesize empFax;
@synthesize empAddress;
@synthesize empPostCode;
@synthesize empNameEng;

@synthesize isNotRcvMsg;
@synthesize isAdmin;

@synthesize empSort;

@synthesize logoImage;

@synthesize isRobot;

-(void)dealloc
{
    self.logoImage = nil;
    self.birthdayStr = nil;
    self.empFax = nil;
    self.empAddress = nil;
    self.empPostCode = nil;
    self.empNameEng = nil;
    
    self.empPinyin = nil;
	self.empPinyinSimple = nil;
	self.emp_mail = nil;
	self.emp_tel = nil;
	self.emp_hometel = nil;
	self.emp_emergencytel = nil;
	self.deptName = nil;
	self.titleName = nil;
	self.emp_mobile = nil;
	self.emp_logo = nil;
	self.empCode = nil;
	self.signature = nil;
	self.parentDept = nil;
	self.emp_name = nil;
    self.parent_dept_list=nil;
    self.permission = nil;
	[super dealloc];
}

- (id)init
{
    id _id = [super init];
    
//    初始化permisson
    PermissionModel *_permission = [[PermissionModel alloc]init];
    [_permission setPermission:0];
    self.permission = _permission;
    [_permission release];
    
    self.isRobot = NO;
    
    self.canChoose = YES;
    
    return _id;
}

-(int)getLength
{
	int count = (self.emp_name?strlen([self.emp_name UTF8String]):0) +
    (self.emp_logo?strlen([self.emp_logo UTF8String]):0) +
	(self.emp_hometel?strlen([self.emp_hometel UTF8String]):0) +
	(self.emp_emergencytel?strlen([self.emp_emergencytel UTF8String]):0) +
	(self.deptName?strlen([self.deptName UTF8String]):0 )+
	(self.emp_mail?strlen([self.emp_mail UTF8String]):0) +
	(self.emp_mobile?strlen([self.emp_mobile UTF8String]):0) +
	(self.emp_tel?strlen([self.emp_tel UTF8String]):0) +
	(self.empCode?strlen([self.empCode UTF8String]):0) +
	(self.signature?strlen([self.signature UTF8String]):0) +
	(self.titleName?strlen([self.titleName UTF8String]):0) +
	(self.empPinyinSimple?strlen([self.empPinyinSimple UTF8String]):0) +
    (self.empPinyin?strlen([self.empPinyin UTF8String]):0) +
    sizeof(self.emp_id) * 9;
    
    //	NSLog(@"--%@,%d",self.emp_name,count);
	return count;
	//	[self.emp_mail UTF8String]
    
}
-(NSString *)toString
{
	return nil;
}
    
//    add by shisp 返回人员名称，增加语言判断
    - (NSString *)emp_name
    {
        if ([LanUtil isChinese]) {
            if(_emp_name && _emp_name.length>0)
            return _emp_name;
        }
        else
        {
            if (empNameEng && empNameEng.length > 0) {
                return empNameEng;
            }
            if(_emp_name && _emp_name.length>0)
                return _emp_name;
        }
        if(self.empCode && self.empCode.length > 0)
            return self.empCode;
        
        //查一下数据库 看看 是不是 离职的人员
        NSString *tempName = [[eCloudDAO getDatabase]getEmpNameByEmpId:[StringUtil getStringValue:self.emp_id]];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 通过Emp对象没有取到名字，再次根据empId去查数据库，结果是%@",__FUNCTION__,tempName]];
        
        return tempName;
        
//        return [StringUtil getStringValue:self.emp_id];
    }
    
-(NSString*)getEmpName
{
    return self.emp_name;
}

//增加根据empId来排序
- (NSComparisonResult)compareByEmpId:(Emp *) anotherElement
{
    return [[NSNumber numberWithInt:self.emp_id] compare:[NSNumber numberWithInt:anotherElement.emp_id]];
}

- (NSString *)emp_logo
{
    return default_emp_logo;
}


//设置
- (void)setEmp_id:(int)emp_id
{
    _emp_id = emp_id;
    
    isRobot = [[RobotDAO getDatabase]isRobotUser:emp_id];
    if (isRobot) {
        NSLog(@"%d 是机器人",emp_id);
    }
}

//新建一个方法，只是简单的设置empid属性，不考虑是否机器人
- (void)setEmpId:(int)emp_id
{
    _emp_id = emp_id;
}

- (int)emp_status
{
    if (isRobot) {
        return status_online;
    }
    return _emp_status;
}

- (int)loginType
{
    if (isRobot) {
        return TERMINAL_PC;
    }
    return _loginType;
}

- (BOOL)isAppNoticeAccount{
    if ([UIAdapterUtil isTAIHEApp] || [UIAdapterUtil isLANGUANGApp]) {
        if (self.empCode.length) {
            if ([self.empCode compare:EMAIL_EMP_CODE options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            }
            if ([self.empCode compare:DAIBAN_EMP_CODE options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            }
            if ([self.empCode compare:MEETING_EMP_CODE options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            }
            if ([self.empCode compare:ATTENDANCE_EMP_CODE options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            }
        }
    }
    return NO;
}

@end
