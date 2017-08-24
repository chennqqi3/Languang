//
//  JBBasicFileManager.m
//  SeeKool
//  
//  Copyright (c) 2013 YongbinZhang
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JBBasicFileManager.h"

@interface JBBasicFileManager ()

//  返回Document,Library和Catch目录的路径
+ (NSString *)DocumentsPath;
+ (NSString *)LibraryPath;
+ (NSString *)CatchPath;

//  本地目录下文件夹的路径
+ (NSString *)dirPathAtBasicPath:(NSString *)basicPath WithDirName:(NSString *)dirName;
//  本地目录下文件的路径
//+ (NSString *)filePathAtBasicPath:(NSString *)basicPath WithFileName:(NSString *)fileName;

//  检查本地文件是否存在
+ (BOOL)isFilePathExist:(NSString *)filePath isDir:(BOOL)isDir;


@end

@implementation JBBasicFileManager

//  返回Document目录的路径
+ (NSString *)DocumentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//  返回Library目录的路径
+ (NSString *)LibraryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//  返回Catch目录的路径
+ (NSString *)CatchPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//  获取本地目录下文件夹的路径
+ (NSString *)dirPathAtBasicPath:(NSString *)basicPath WithDirName:(NSString *)dirName
{
    NSMutableString *currentPath = [NSMutableString stringWithString:basicPath];
    
    NSArray *paths = [currentPath componentsSeparatedByString:@"/"];
    if (![[paths objectAtIndex:([paths count] - 1)] isEqualToString:@""]) {
        [currentPath appendString:@"/"];
    }
    
    if (dirName && ![dirName isEqualToString:@""]) {
        [currentPath appendFormat:@"%@/",dirName];
    }
    
    return currentPath;
}

//  本地目录下文件的路径
+ (NSString *)filePathAtBasicPath:(NSString *)basicPath WithFileName:(NSString *)fileName
{
    NSMutableString *currentPath = [NSMutableString stringWithString:basicPath];
    
    NSArray *paths = [currentPath componentsSeparatedByString:@"/"];
    if (![[paths objectAtIndex:([paths count] - 1)] isEqualToString:@""]) {
        [currentPath appendString:@"/"];
    }
    
    if (fileName && ![fileName isEqualToString:@""]) {
        [currentPath appendFormat:@"%@",fileName];
    }
    
    return currentPath;
}

//  在Documents文件夹下的路径
+ (NSString *)pathInDocumentsWithDirPath:(NSString *)dirPath filePath:(NSString *)filePath
{
    NSMutableString *basePath = (NSMutableString *)[self dirPathAtBasicPath:[self DocumentsPath] WithDirName:dirPath];
    
    if (filePath && ![filePath isEqualToString:@""]) {
        return [basePath stringByAppendingPathComponent:filePath];
    } else {
        return basePath;
    }
}

//  在Library文件夹下的路径
+ (NSString *)pathInLibraryWithDirPath:(NSString *)dirPath filePath:(NSString *)filePath
{
    NSMutableString *basePath = (NSMutableString *)[self dirPathAtBasicPath:[self LibraryPath] WithDirName:dirPath];
    
    if (filePath && ![filePath isEqualToString:@""]) {
        return [basePath stringByAppendingPathComponent:filePath];
    } else {
        return basePath;
    }
}

//  在Catch文件夹下的路径
+ (NSString *)pathInCatchWithDirPath:(NSString *)dirPath filePath:(NSString *)filePath
{
    NSMutableString *basePath = (NSMutableString *)[self dirPathAtBasicPath:[self CatchPath] WithDirName:dirPath];
    
    if (filePath && ![filePath isEqualToString:@""]) {
        return [basePath stringByAppendingPathComponent:filePath];
    } else {
        return basePath;
    }
}


//  检查文件是否存在
+ (BOOL)isFilePathExist:(NSString *)filePath isDir:(BOOL)isDir;
{    
    if (filePath) {        
        NSString *path = [NSString stringWithString:filePath];
        if (!path || path.length <= 0) {
            return NO;
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];    
        BOOL dir;
        if ([fileManager fileExistsAtPath:path isDirectory:&dir]) {
            if (dir == isDir) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

//  检查路径是否指向文件
+ (BOOL)isExistFileAtPath:(NSString *)path
{    
    return [self isFilePathExist:path isDir:NO];
}

//  检查路径是否指向文件夹
+ (BOOL)isExistDirAtPath:(NSString *)path
{    
    NSString *tempPath = [NSString stringWithString:path];
    return [self isFilePathExist:tempPath isDir:YES];
}


//  检查本地路径下是否存在某个文件
+ (BOOL)isExistFile:(NSString *)fileName AtPath:(NSString *)path
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, fileName];
    return [self isExistFileAtPath:filePath];
}

//  检查本地路径下是否存在某个文件夹
+ (BOOL)isExistDir:(NSString *)dirName AtPath:(NSString *)path;
{
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@", path, dirName];
    
    return [self isExistDirAtPath:dirPath];
}



//  当前路径对应的那一级目录下，除文件夹之外的文件的大小
+ (unsigned long long)fileSizeWithInDirectFolderAtPath:(NSString *)path
{
    unsigned long long size = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self isExistFileAtPath:path]) {
        NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:path error:nil];
        size += fileAttributeDic.fileSize;
    } else if([self isExistDirAtPath:path]) {
        NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString * component in array) {
            NSString *fullPath = [path stringByAppendingString:component];
            BOOL isDir;
            if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir) {
                NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
                size += fileAttributeDic.fileSize;
            }
        }
    }
        
    return size;
}

//  某个路径下所有文件的大小
+ (unsigned long long)totalFilesSizeAtPath:(NSString *)path
{
    unsigned long long size = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([self isExistFileAtPath:path]) {
        NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:path error:nil];
        size += fileAttributeDic.fileSize;
    } else if([self isExistDirAtPath:path]) {
        NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString * component in array) {
            NSString *fullPath = [path stringByAppendingString:component];
            NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
    }
        
    return size;
}

//  检查是否文件夹大小到达上限，根据字节计算
+ (BOOL)isArriveUpperLimitAtPaths:(NSArray *)paths WithUpperLimitByByte:(unsigned long long)upperLimit
{
    unsigned long long totalSize = 0;
    
    for (NSString *path in paths) {
        totalSize += [self totalFilesSizeAtPath:path];
    }
    
    if (totalSize >= upperLimit) {
        return YES;
    } else {
        return NO;
    }
}

//  检查是否文件夹大小到达上限，根据KB计算
+ (BOOL)isArriveUpperLimitAtPaths:(NSArray *)paths WithUpperLimitByKByte:(unsigned long long)upperLimit
{
    return [self isArriveUpperLimitAtPaths:paths WithUpperLimitByByte:(1024 * upperLimit)];
}

//  检查是否文件夹大小到达上限，根据MB计算
+ (BOOL)isArriveUpperLimitAtPaths:(NSArray *)paths WithUpperLimitByMByte:(unsigned long long)upperLimit
{
    return [self isArriveUpperLimitAtPaths:paths WithUpperLimitByKByte:(1024 * upperLimit)];
}



//  在本地添加文件夹
+ (NSString *)createDir:(NSString *)path
{
    NSMutableString *currentPath = [[NSMutableString alloc] initWithString:path];
    
    NSArray *paths = [currentPath componentsSeparatedByString:@"/"];
    if (![[paths objectAtIndex:([paths count] - 1)] isEqualToString:@""]) {
        [currentPath appendString:@"/"];
    }
    
    if (![self isFilePathExist:currentPath isDir:YES]) {
        if ([[NSFileManager defaultManager] createDirectoryAtPath:currentPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            return currentPath;
        } else {
            return nil;
        }
    } else {
        return currentPath;
    }    
}


//  在本地添加文件夹
+ (NSString *)createDir:(NSString *)dirName AtPath:(NSString *)path
{
    NSString *currentPath = [self dirPathAtBasicPath:path WithDirName:dirName];
    if (currentPath) {
        return [self createDir:currentPath];
    } else {
        return path;
    }
}

//  在本地删除路径
+ (BOOL)deletePath:(NSString *)path
{
    if (path) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        return [fileManager removeItemAtPath:path error:nil];
    } else {
        return NO;
    }
}

+ (void)deletePaths:(NSArray *)paths
{
    if (paths && paths.count > 0) {
        for (NSString *path in paths) {
            [self deletePath:path];
        }
    }
}

@end
