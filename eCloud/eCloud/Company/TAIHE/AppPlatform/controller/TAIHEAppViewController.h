//
//  TAIHEAppViewController.h
//  eCloud
//
//  Created by Ji on 17/1/10.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

//明源待办需要设置cookie 明源待办URL定义
#define TAIHE_MINGYUAN_URL @".fdccloud.com"
//泰和OA域名
#define TAIHE_OA_DOMAIN @".tahoecn.com"
//泰禾单点登录token 名字
#define TAIHE_SSO_TOKEN_NAME @"LtpaToken"
@interface TAIHEAppViewController : UIViewController

+(TAIHEAppViewController *)getTaiHeAppViewController;
- (UIImage *)headTangential;
@property (nonatomic,assign) BOOL isReloadHttpUnReadEmail;
@property (nonatomic,assign) BOOL isReloadHttpUnReadDaiban;

/*
 返回泰禾App token
 */
+ (NSString *)cookieString;


/**
 查看请求的url是否是明源的待办，如果是则设置好cookie

 @param request 页面请求
 */
+ (void)setAppCookie:(NSURLRequest *)request;

@end
