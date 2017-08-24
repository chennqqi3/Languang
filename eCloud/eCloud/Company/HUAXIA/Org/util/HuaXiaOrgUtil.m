//
//  HuaXiaOrgUtil.m
//  eCloud
//
//  Created by shisuping on 17/5/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "HuaXiaOrgUtil.h"
#import "NewChooseMemberViewController.h"
#import "UIAdapterUtil.h"
#import "CreateGroupDefine.h"
#import "LogUtil.h"
#import "NewOrgViewController.h"
#import "WXOrgUtil.h"
#import "OpenCtxDefine.h"

@interface HuaXiaOrgUtil () <ChooseMemberDelegate>

@end

static HuaXiaOrgUtil *huaXiaOrgUtil;

@implementation HuaXiaOrgUtil

+ (HuaXiaOrgUtil *)getUtil{
    if (!huaXiaOrgUtil) {
        huaXiaOrgUtil = [[HuaXiaOrgUtil alloc]init];
    }
    return huaXiaOrgUtil;
}

- (void)openSelectHXUserVC{
    NewChooseMemberViewController *vc = [[[NewChooseMemberViewController alloc]init]autorelease];
    vc.chooseMemberDelegate = self;
    vc.typeTag = type_hxxf_select_contacts;
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *dic in self.disableSelectUserArray) {
        Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:dic];
        [temp addObject:_emp];
    }
    vc.oldEmpIdArray = temp;
    UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
    [self.openVC presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark ===choose member delegate====
- (void)didFinishSelectContacts:(NSArray *)userArray{
    if (self.orgDelegate && [self.orgDelegate respondsToSelector:@selector(didSelectHXUsers:)]) {
        [self.orgDelegate didSelectHXUsers:userArray];
    }
}

/** 异步获取华夏用户资料 */
- (NSDictionary *)getHXEmpInfoByEmpId:(int)empId withUserInfo:(NSDictionary *)userInfo withCompleteHandler:(getHXEmpInfoByEmpIdResultBlock)completeHandler{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取%d用户资料 %@",__FUNCTION__,empId,userInfo]];

    dispatch_queue_t _queue = dispatch_queue_create("download_emp_logo", NULL);
    dispatch_async(_queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:empId],EMP_ID_KEY,[NSString stringWithFormat:@"UserName%d",empId],EMP_NAME_KEY,[NSNumber numberWithInt:0],EMP_SEX_KEY,[NSString stringWithFormat:@"UserCode%d",empId],EMP_CODE_EKY, nil];
        [LogUtil debug:[NSString stringWithFormat:@"%s 返回%d用户资料 %@",__FUNCTION__,empId,dic]];

        completeHandler(dic,userInfo);
        

    });
    return nil;
}

/** 打开华夏办公系统联系人资料界面 */
- (void)openHXUserInfoById:(int)empId andCurController:(UIViewController *)curController{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
}

/** 异步获取华夏用户头像 如果没有头像则返回nil*/
- (UIImage *)getHXEmpLogoByEmpId:(int)empId withUserInfo:(NSDictionary *)userInfo withCompleteHandler:(getHXEmpLogoByEmpIdResultBlock)completeHandler{
    return nil;
}

@end
