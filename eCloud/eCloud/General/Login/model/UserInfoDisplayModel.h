//用户资料显示开关
#import <Foundation/Foundation.h>

@interface UserInfoDisplayModel : NSObject

@property (nonatomic,assign) int iDisplay;

+ (UserInfoDisplayModel *)getModel;

@end
