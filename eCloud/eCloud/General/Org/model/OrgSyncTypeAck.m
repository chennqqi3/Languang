
#import "OrgSyncTypeAck.h"

@implementation OrgSyncTypeAck

@synthesize syncTypeDept;
@synthesize syncTypeEmpDept;

@synthesize fileTypeDept;
@synthesize fileTypeEmpDept;

@synthesize filePathDept;
@synthesize filePasswordDept;

@synthesize filePasswordEmpDept;
@synthesize filePathEmpDept;


- (void)dealloc
{
    self.filePathDept = nil;
    self.filePasswordDept = nil;

    self.filePathEmpDept = nil;
    self.filePasswordEmpDept = nil;
    [super dealloc];
}
@end
