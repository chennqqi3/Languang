//
//  NSData+AES256.h
//  sdk-Demo
//
//  Created by Alex L on 16/8/17.
//  Copyright © 2016年 Alex L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key;   //加密

- (NSData *)AES256DecryptWithKey:(NSString *)key;   //解密

- (NSString *)newStringInBase64FromData;            //追加64编码

+ (NSString*)base64encode:(NSString*)str;           //同上64编码

@end
