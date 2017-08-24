//
//  FileManege.m
//  eCloud
//
//  Created by Alex L on 15/11/10.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "EncryptFileManege.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"
#import "eCloudConfig.h"

#define PASSWORD @"LLKWEJFKALJDKLZJXVD"

@implementation EncryptFileManege

+ (BOOL)saveFileWithPath:(NSString *)filePath withData:(NSData *)data
{
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        NSLog(@"%s filepath is %@",__FUNCTION__,filePath);
       NSError *error1 = nil;
        NSData *encryptedData = [RNEncryptor encryptData:data
                                            withSettings:kRNCryptorAES256Settings
                                                password:PASSWORD
                                                   error:&error1];
        
        BOOL isSuccess = [encryptedData writeToFile:filePath options:NSDataWritingFileProtectionComplete error:nil];
        return isSuccess;
    }
    else
    {
        return [data writeToFile:filePath options:NSDataWritingFileProtectionComplete error:nil];
    }
}

+ (NSData *)getDataWithPath:(NSString *)filePath
{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
//        NSLog(@"%s filepath is %@",__FUNCTION__,filePath);
        NSError *error;
        NSData *decryptedData = [RNDecryptor decryptData:data
                                            withPassword:PASSWORD
                                                   error:&error];
        
        if (decryptedData == nil)
        {
//            if (data == nil) {
//                NSLog(@"文件不存在");
//            }else{
//                NSLog(@"文件还没有加密");
//            }
            return data;
        }else{
//            NSLog(@"文件已经加密");
        }
        
        return decryptedData;
    }
    
    return data;
}

+ (void)encryptExistFile:(NSString *)filePath
{
    if ([eCloudConfig getConfig].needFixSecurityGap){
        NSLog(@"%s filepath is %@",__FUNCTION__,filePath);
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        [EncryptFileManege saveFileWithPath:filePath withData:data];
    }
}

@end
