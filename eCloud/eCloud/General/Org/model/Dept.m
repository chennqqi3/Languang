
//部门
#import "Dept.h"
#import "LanUtil.h"

@implementation Dept
@synthesize deptNameEng;
@synthesize dept_id = _dept_id;
@synthesize dept_name = _dept_name;
@synthesize fdept_name = _fdept_name;
@synthesize dept_parent = _dept_parent;
@synthesize dept_comp_id = _dept_comp_id;
@synthesize child_Depts = _child_Depts;
@synthesize dept_emps = _dept_emps;
@synthesize isChecked = _isChecked;
@synthesize isExtended = _isExtended;
@synthesize dept_level=_dept_level;
@synthesize display = _display;
@synthesize firstExend = _firstExtend;
@synthesize totalNum;
@synthesize onlineNum;
@synthesize subDeptsStr;
@synthesize dept_tel=_dept_tel;
@synthesize dept_type;

-(void)dealloc
{
    self.deptNameEng = nil;
	self.dept_name = nil;
    self.fdept_name = nil;
	self.child_Depts = nil;
	self.dept_emps = nil;
	
	self.dept_tel = nil;
	self.subDeptsStr = nil;
	
	[super dealloc];
}
    
-(NSString *)toString
{
	NSLog(@"********** %@",self.dept_name);
	
	for(int i=0;i<[self.dept_emps count];i++)
	{
		[[self.dept_emps objectAtIndex:i]toString];
	}
	
	for(int i=0;i<[self.child_Depts count];i++)
	{
		[[self.child_Depts objectAtIndex:i]toString];
	}

	return self.dept_name;
}
    
//    add by shisp 获取部门名称时增加语言判断
    - (NSString *)dept_name
    {
        if ([LanUtil isChinese])
        {
            return _dept_name;
        }
        else
        {
            if (deptNameEng && deptNameEng.length > 0) {
                return deptNameEng;
            }
            return _dept_name;
        }
    }
    
@end
