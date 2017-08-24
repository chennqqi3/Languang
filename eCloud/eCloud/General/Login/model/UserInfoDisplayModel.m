

#import "UserInfoDisplayModel.h"

static UserInfoDisplayModel *_model;

@implementation UserInfoDisplayModel

@synthesize iDisplay;

+ (UserInfoDisplayModel *)getModel
{
    if (_model == nil) {
        _model = [[UserInfoDisplayModel alloc]init];
    }
    return _model;
}
@end
