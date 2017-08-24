//登录返回后返回的权限对应的Model类

#import <Foundation/Foundation.h>

@interface AuthModel : NSObject

+ (AuthModel *)getModel;

@property (nonatomic,assign)int auth;
@property (nonatomic,retain) NSMutableDictionary *authDic;

//是否有一呼百应权限
- (BOOL)canYHBY;

//是否有一呼万应权限
- (BOOL)canYHWY;

//如果有一呼万应权限，那么最多人数是多少
- (int)maxYHWY;

//是否有木棉童飞权限
- (BOOL)canMMTF;

@end
