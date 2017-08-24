//
//  QualityAssessmentHeader.h
//  BeTalk
//
//  Created by 房潇 on 2016/11/22.
//  Copyright © 2016年 nationsky. All rights reserved.
//

#ifndef QualityAssessmentHeader_h
#define QualityAssessmentHeader_h

#import <JavaScriptCore/JavaScriptCore.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>

#define kREQUESTSTR @"http://10.122.1.23:8080/app/index.html#!/home"

#define kSECURITYKEY @"JdAgEAAoGBAOdC92"
#define kAPPKEY @"00001"
#define kACCESSTOKEN [[NSUserDefaults standardUserDefaults]stringForKey:@"accesstoken"]
#define kSTATUSCOLOR [UIColor colorWithRed:0.00f green:0.54f blue:0.91f alpha:1.00f]

#endif /* QualityAssessmentHeader_h */
