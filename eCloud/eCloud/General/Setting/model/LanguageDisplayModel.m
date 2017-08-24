

#import "LanguageDisplayModel.h"

static LanguageDisplayModel *_model;
@implementation LanguageDisplayModel

@synthesize iLanDisplay;

+ (LanguageDisplayModel *)getModel
{
    if (_model == nil) {
        _model = [[LanguageDisplayModel alloc]init];
    }
    return _model;
}
@end
