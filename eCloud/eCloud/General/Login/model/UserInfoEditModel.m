
#import "UserInfoEditModel.h"

static UserInfoEditModel *_model;
@implementation UserInfoEditModel

@synthesize iEdit;

+ (UserInfoEditModel *)getModel
{
    if (_model == nil) {
        _model = [[UserInfoEditModel alloc]init];
    }
    return _model;
}
@end
