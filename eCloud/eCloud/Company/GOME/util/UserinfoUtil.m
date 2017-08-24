//
//  UserinfoUtil.m
//  eCloud
//
//  Created by Alex L on 17/3/7.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "UserinfoUtil.h"
#import "conn.h"
#import "Emp.h"
#import "UserDefaults.h"
#import "ImageUtil.h"

@implementation UserinfoUtil

+ (NSString *)getEmpID
{
    NSString *empID = [UserDefaults getGOMEEmpId];
    return empID.length > 0 ? empID : @"";
}

+ (NSString *)getUserAccount
{
    NSString *account = [UserDefaults getUserAccount];
    return account.length > 0 ? account : @"";
}

+ (NSString *)getGOMEToken
{
    NSString *token = [UserDefaults getGOMEToken];
    return token.length>0 ? token : @"";
}

+ (NSString *)getUserCode
{
    NSString *userCode = [conn getConn].user_code;
    return userCode.length>0 ? userCode : @"";
}

+ (NSString *)getUserCodeWithoutA5
{
    NSString *userCodeA5 = [conn getConn].user_code;
    NSString *userCode = [userCodeA5 substringToIndex:userCodeA5.length-2];
    return userCode.length>0 ? userCode : @"";
}

+ (UIImage *)getEmpLogo
{
    Emp *emp = [conn getConn].curUser;
    return [ImageUtil getEmpLogo:emp];
}

+ (NSString *)getEmpName
{
    NSString *name = [UserDefaults getGOMEEmpName];
    return name.length>0 ? name : @"";
}

+ (int)getEmpSex
{
    Emp *emp = [conn getConn].curUser;
    return emp.emp_sex;
}

+ (NSString *)getEmpMail
{
    Emp *emp = [conn getConn].curUser;
    NSString *mail = emp.emp_mail;
    return mail.length > 0 ? mail : @"";
}

+ (NSString *)getEmpMobile
{
    Emp *emp = [conn getConn].curUser;
    NSString *mobile = emp.emp_mobile;
    return mobile.length > 0 ? mobile : @"";
}

+ (NSString *)getEmpTitle
{
    Emp *emp = [conn getConn].curUser;
//    国美要求返回部门，不返回职务，但是方法名字不变
    NSString *title = emp.deptName;// emp.titleName;
    return title.length > 0 ? title : @"";
}

@end
