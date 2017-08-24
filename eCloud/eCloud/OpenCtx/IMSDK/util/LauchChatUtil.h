// 从wandaapp加载会话 deprecated

#import <Foundation/Foundation.h>

@interface LauchChatUtil : NSObject

+ (LauchChatUtil *)getLauchChatUtil;

- (BOOL)lauchChatWithUserAccounts:(NSArray *)userAccounts andMsg:(NSString *)messageStr andOpenType:(int)openType andIsSelect:(BOOL)isSelect andVC:(UIViewController *)viewController;


/** 华夏自己管理通讯录，打开联系人资料时，可以发起单聊接口 */
- (void)openSingleConvFromHXEmpInfo:(NSDictionary *)dic;

@end
