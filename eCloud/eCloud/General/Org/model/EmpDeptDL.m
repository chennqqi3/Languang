
#import "EmpDeptDL.h"

@implementation EmpDeptDL

@synthesize empId = _empId;
@synthesize deptId = _deptId;
@synthesize empCode = _empCode;
@synthesize empName;
@synthesize empLogo;
@synthesize empSex;

@synthesize rankId;
@synthesize profId;
@synthesize areaId;

@synthesize empSort;

@synthesize updateType;

@synthesize empNameEng;

-(void)dealloc
{
    self.empNameEng = nil;
	self.empCode = nil;
	self.empName = nil;
	self.empLogo = nil;
	[super dealloc];
}
@end
