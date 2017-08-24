//
//  NSData+AES.h
//  Smile
//
//  Created by apple on 15/8/25.
//  Copyright (c) 2015年 Weconex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (Encryption)

- (NSData *)AES256Encrypt;   //加密
- (NSData *)AES256Decrypt;   //解密

@end
