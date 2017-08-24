//
//  WXOrgUtil.m
//  eCloud
//
//  Created by shisuping on 17/5/13.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "WXOrgUtil.h"
#import "CreateGroupDefine.h"
#import "Emp.h"
#import "EmpDeptDL.h"
#import "LogUtil.h"
#import "eCloudDAO.h"
#import "eCloudDefine.h"

@implementation WXOrgUtil


/** 把华夏的字典转为一个Emp对象 */
+ (Emp *)getEmpByHXEmpDic:(NSDictionary *)dic{
    if (dic){
        Emp *_emp = [[[Emp alloc]init]autorelease];
        _emp.emp_id = [dic[EMP_ID_KEY]intValue];
        _emp.emp_name = dic[EMP_NAME_KEY];
        int tempSex = [dic[EMP_SEX_KEY]intValue];
        /** 华夏 性别值0 表示男 其它是女 */
        if (tempSex == 0) {
            _emp.emp_sex = 1;
        }else{
            _emp.emp_sex = 0;
        }
//        默认为状态为离线
        _emp.emp_status = status_offline;
        _emp.empCode = dic[EMP_CODE_EKY];
        
        BOOL save = [[eCloudDAO getDatabase]saveHXEmpToDB:_emp];
        if (save) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 从华夏获取到了用户资料 userid is %d",__FUNCTION__,_emp.emp_id]];
        }
        
        return _emp;
    }
    return nil;
}

@end
