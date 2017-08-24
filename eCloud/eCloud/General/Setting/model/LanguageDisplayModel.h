//显示中英文开关

#import <Foundation/Foundation.h>

@interface LanguageDisplayModel : NSObject

@property (nonatomic,assign) int iLanDisplay;
+ (LanguageDisplayModel *)getModel;

@end
