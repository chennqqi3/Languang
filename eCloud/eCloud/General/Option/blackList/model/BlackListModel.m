
#import "BlackListModel.h"
#import "PermissionModel.h"

@implementation BlackListModel
@synthesize isBlack;
@synthesize permission;
@synthesize userId;
@synthesize userType;
@synthesize hideType;

- (void)dealloc
{
    self.permission = nil;
    [super dealloc];
}

- (void)setHideType:(int)_hideType
{
    self.permission = [[PermissionModel alloc]init];
    [self.permission setPermission:_hideType];
    hideType = _hideType;
}
- (int)hideType
{
    if(self.permission.isHidden)
    {
        return 1;
    }
    else
    {
        return hideType;
    }
}
@end
