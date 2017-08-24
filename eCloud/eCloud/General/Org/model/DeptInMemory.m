
#import "DeptInMemory.h"
#import "LanUtil.h"

@implementation DeptInMemory
@synthesize deptId;
@synthesize onlineEmpCount;
@synthesize deptNameContainParent;
@synthesize deptNameContainParentEng;
@synthesize deptParentDept;
@synthesize isChecked;
@synthesize subDept;
@synthesize deptName;
@synthesize deptNameEng;

- (void)dealloc
{
    self.deptName = nil;
    self.deptNameEng = nil;
    self.deptNameContainParentEng = nil;
    self.deptNameContainParent = nil;
    self.deptParentDept = nil;
    self.subDept = nil;
    [super dealloc];
}

//泰和 蓝光 要求搜索人员时显示人员的部门及父部门
#if defined(_TAIHE_FLAG_) || defined(_LANGUANG_FLAG_)

#else
- (NSString *)deptNameContainParent
{
    if ([LanUtil isChinese])
    {
        return self.deptName;
    }
    else
    {
        if (self.deptNameEng) {
            return self.deptNameEng;
        }
        return self.deptName;
    }
}
#endif



@end
