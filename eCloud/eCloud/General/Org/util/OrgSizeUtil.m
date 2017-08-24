//
//  OrgSizeUtil.m
//  eCloud
//
//  Created by yanlei on 15/9/6.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "OrgSizeUtil.h"
#import "eCloudDefine.h"

@implementation OrgSizeUtil

//导航栏 和 通讯录内容的间隔
+ (float)getSpaceBetweenDeptNavAndContent
{
    return 10.0;
}


//通讯录 部门导航栏的字体
+ (float)getFontSizeOfDeptNav
{
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        return 17.0;
    }
    return 14.0;
}

+ (float)getLeftScrollViewWidth
{
    if (IS_IPHONE_6) {
        return 45.0f;
    }else if(IS_IPHONE_6P) {
        return 50.0f;
    }
    return 32.0;
}
+ (float)getLeftScrollViewHeight
{
    // 原来高度是71，现在按等比例计算高度
    return [OrgSizeUtil getLeftScrollViewWidth]*70/32;
}
+ (float)getLeftSpaceSelectViewWidth
{
    if (IS_IPHONE_6) {
        return 50.0f;
    }else if(IS_IPHONE_6P) {
        return 55.0f;
    }
    return 40.0;
}
@end
