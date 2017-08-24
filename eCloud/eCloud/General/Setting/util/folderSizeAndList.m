//
//  allFileSize.m
//  eCloud
//
//  Created by SH on 14-8-8.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "folderSizeAndList.h"
#import "StringUtil.h"
#import "UserDefaults.h"

@implementation folderSizeAndList
{
    long long allFileSize;
}

-(NSArray *)getFileList:(NSString *) directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentDir = [StringUtil newRcvFilePath];
    
    NSError *error =nil;
    
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    return fileList;
}

//-(NSString *) getALLFileSize:(NSString *) directoryPath
//{
//    
//    folderSizeAndList *fsl = [[folderSizeAndList alloc] init];
//    NSArray *fileList = [fsl getFileList:directoryPath];
//    [fsl release];
//    
//    for (NSString *filePath in fileList)
//    {
//        NSString *fullPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:filePath];
//        
//        long long fileSize = [self fileSizeAtPath:fullPath];
//        
//        allFileSize += fileSize;
//        
//    }
//    return [StringUtil getDisplayFileSize:allFileSize];
//}

- (long long) fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath])
    {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(NSString *) singleFileSize:(NSString *) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath])
    {
        return [StringUtil getDisplayFileSize:[[manager attributesOfItemAtPath:filePath error:nil] fileSize]];
    }
    return 0;
}

-(long long) getALLFileSizeLong:(NSString *) directoryPath
{
    folderSizeAndList *fsl = [[folderSizeAndList alloc] init];
    NSArray *fileList = [fsl getFileList:directoryPath];
    [fsl release];
    
//    图片大小
    long long _picSize = 0;
//    文件大小
    long long _fileSize = 0;
    
    for (NSString *filePath in fileList)
    {
//        NSLog(@"%s,%@",__FUNCTION__,filePath);
        
//        update by shisp 如果文件是图片缩略图(以small开始，并且是png类型) 或者 是录音(.amr类型)则不计算大小
        NSString *_ext = [filePath pathExtension];
        
        if (([filePath hasPrefix:@"small"] && [_ext isEqualToString:@"png"]) || [_ext isEqualToString:@"amr"]) {
//            NSLog(@"是缩略图或录音文件");
        }
        else
        {
            NSString *fullPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:filePath];
            long long fileSize = [self fileSizeAtPath:fullPath];

            if ([_ext isEqualToString:@"png"]) {
//                NSLog(@"是大图");
                _picSize += fileSize;
            }
            else
            {
//                NSLog(@"是文件");
                _fileSize += fileSize;
            }
        }
//        allFileSize += fileSize;
    }
    [UserDefaults setPicStorage:[NSNumber numberWithLongLong:_picSize]];
    [UserDefaults setFileStorage:[NSNumber numberWithLongLong:_fileSize]];
    
    return (_picSize + _fileSize);
}

@end
