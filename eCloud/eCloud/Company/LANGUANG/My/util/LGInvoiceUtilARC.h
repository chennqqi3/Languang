//
//  LGInvoiceUtilARC.h
//  eCloud
//
//  Created by Ji on 17/7/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGInvoiceUtilARC : NSObject

+ (BOOL)isLowerLetter:(NSString *)str;

+ (BOOL)isChinese:(NSString *)str;

+ (UITextView *)contentSizeToFit:(UITextView *)View;

@end
