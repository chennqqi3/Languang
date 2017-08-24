//
//  PhoneUtil.m
//  eCloud
//
//  Created by shisuping on 14-7-14.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "PhoneUtil.h"
#import "Emp.h"
#import "KxMenu.h"
#import "PermissionModel.h"
#import "StringUtil.h"

#import "personInfoViewController.h"

@implementation PhoneUtil

+ (BOOL)needDisplayPhoneButton:(Emp *)p
{
    BOOL isHidden =  p.permission.isHidden;
    BOOL isHideAllInfo = p.permission.isHideAllInfo;
    BOOL isHidePartInfo = p.permission.isHidePartInfo;
    
    if (isHidden || isHideAllInfo || isHidePartInfo) {
        return NO;
    }
    if ((p.emp_mobile && p.emp_mobile.length > 0) || (p.emp_emergencytel && p.emp_emergencytel.length > 0) || (p.emp_hometel && p.emp_hometel.length > 0) || (p.emp_tel && p.emp_tel.length > 0))
    {
        return YES;
    }
    
    return NO;
}

+ (void)showPopView:(UIViewController *)currentController andTargetButton:(UIButton *)targetButton andEmp:(Emp *)p
{
    NSMutableArray *menuItems = [NSMutableArray array];
    if (p.emp_tel && p.emp_tel.length > 0)
    {
        id item = [KxMenuItem menuItem:[NSString stringWithFormat:[NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"chats_talksession_tel"],p.emp_tel]]
                                 image:nil
                                target:self
                                action:@selector(callTelNum:)];
        ((KxMenuItem *)item).tel = p.emp_tel;
        [menuItems addObject:item];
    }
    if (p.emp_mobile && p.emp_mobile.length > 0)
    {
        id item = [KxMenuItem menuItem:[NSString stringWithFormat:[NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"chats_talksession_mobile"],p.emp_mobile]]
                                 image:[StringUtil getImageByResName:@"action_icon"]
                                target:self
                                action:@selector(callTelNum:)];
        ((KxMenuItem *)item).tel = p.emp_mobile;
        [menuItems addObject:item];
    }
    if (p.emp_hometel && p.emp_hometel.length > 0)
    {
        id item = [KxMenuItem menuItem:[NSString stringWithFormat:[NSString stringWithFormat:@"宅电: %@",p.emp_hometel]]
                                 image:[StringUtil getImageByResName:@"action_icon"]
                                target:self
                                action:@selector(callTelNum:)];
        ((KxMenuItem *)item).tel = p.emp_hometel;
        [menuItems addObject:item];
    }
    if (p.emp_emergencytel && p.emp_emergencytel.length > 0)
    {
        id item = [KxMenuItem menuItem:[NSString stringWithFormat:[NSString stringWithFormat:@"紧急: %@",p.emp_emergencytel]]
                                 image:[StringUtil getImageByResName:@"action_icon"]
                                target:self
                                action:@selector(callTelNum:)];
        ((KxMenuItem *)item).tel = p.emp_emergencytel;
        [menuItems addObject:item];
    }
    
    if (menuItems.count ==1) {
        KxMenuItem *item =(KxMenuItem *)menuItems[0];
        [self callTelNum:item];
    }
    else
    {
        [KxMenu showMenuInView:currentController.view
                      fromRect:CGRectMake(targetButton.center.x, 0, 0, 0)
                     menuItems:menuItems];
    }
}

+(void)callTelNum:(id)sender
{
    KxMenuItem *item = (KxMenuItem *)sender;
    [personInfoViewController callNumber:item.tel];
}
@end
