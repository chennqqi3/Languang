//
//  GSAGSMHeader.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/6.
//  Copyright © 2016年 Gome. All rights reserved.
//

#ifndef GSAGSMHeader_h
#define GSAGSMHeader_h

#import "GSAAwardModel.h"

#define kAwardURL @"http://g.corp.gome.com.cn/gome-gsm-open/m/commissionApp"

#define kGSAAccessToken [[NSUserDefaults standardUserDefaults]objectForKey:@"accesstoken"]?[[NSUserDefaults standardUserDefaults]objectForKey:@"accesstoken"]:@""
#define kGSAAccessToken [[NSUserDefaults standardUserDefaults]objectForKey:@"employeeId"]?[[NSUserDefaults standardUserDefaults]objectForKey:@"employeeId"]:@""
//
//#define kGSAAccessToken @"92d0c8246c0d4b359b448dbfd7d2ca9d"
//#define kGSAEmpNum @"00047230"

#define kAwardParamsName @"gmcxf"

#endif /* GSAGSMHeader_h */
