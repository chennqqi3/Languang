//
//  JBBasicFileManager.h
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

#import <Foundation/Foundation.h>

@interface JBBasicFileManager : NSObject

//  本地目录下文件的路径
+ (NSString *)filePathAtBasicPath:(NSString *)basicPath WithFileName:(NSString *)fileName;

//  在Documents文件夹下的路径
+ (NSString *)pathInDocumentsWithDirPath:(NSString *)dirPath filePath:(NSString *)filePath;
//  在Library文件夹下的路径
+ (NSString *)pathInLibraryWithDirPath:(NSString *)dirPath filePath:(NSString *)filePath;
//  在Catch文件夹下的路径
+ (NSString *)pathInCatchWithDirPath:(NSString *)dirPath filePath:(NSString *)filePath;


//  检查路径是否指向文件
+ (BOOL)isExistFileAtPath:(NSString *)path;
//  检查路径是否指向文件夹
+ (BOOL)isExistDirAtPath:(NSString *)path;
//  检查本地路径下是否存在某个文件
+ (BOOL)isExistFile:(NSString *)fileName AtPath:(NSString *)path;
//  检查本地路径下是否存在某个文件夹
+ (BOOL)isExistDir:(NSString *)dirName AtPath:(NSString *)path;


//  当前路径对应的那一级目录下，除文件夹之外的文件的大小
+ (unsigned long long)fileSizeWithInDirectFolderAtPath:(NSString *)path;
//  某个路径下所有文件的大小
+ (unsigned long long)totalFilesSizeAtPath:(NSString *)path;

//  检查是否文件夹大小到达上限
+ (BOOL)isArriveUpperLimitAtPaths:(NSArray *)paths WithUpperLimitByByte:(unsigned long long)upperLimit;
+ (BOOL)isArriveUpperLimitAtPaths:(NSArray *)paths WithUpperLimitByKByte:(unsigned long long)upperLimit;
+ (BOOL)isArriveUpperLimitAtPaths:(NSArray *)paths WithUpperLimitByMByte:(unsigned long long)upperLimit;


//  在本地添加文件夹
+ (NSString *)createDir:(NSString *)path;
//  在本地目录下添加文件夹
+ (NSString *)createDir:(NSString *)dirName AtPath:(NSString *)path;


//  在本地删除路径
+ (BOOL)deletePath:(NSString *)path;
+ (void)deletePaths:(NSArray *)paths;

@end
