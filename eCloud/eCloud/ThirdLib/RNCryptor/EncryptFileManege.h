//
//  FileManege.h
//  eCloud
//
//  Created by Alex L on 15/11/10.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptFileManege : NSObject

+ (BOOL)saveFileWithPath:(NSString *)filePath withData:(NSData *)data;

+ (NSData *)getDataWithPath:(NSString *)filePath;

+ (void)encryptExistFile:(NSString *)filePath;

@end
