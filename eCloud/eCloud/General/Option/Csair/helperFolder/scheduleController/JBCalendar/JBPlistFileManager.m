//
//  JBPlistFileManager.m
//  SeeKool
//
//  Created by SeeKool on 9/4/12.
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

#import "JBPlistFileManager.h"


@implementation JBPlistFileManager


//  读取plist文件中的数据
+ (NSArray *)readDataFromPlistFileAtPath:(NSString *)path
{    
    if (![self isExistFileAtPath:path]) {
        return nil;
    } else {
        return [[NSArray alloc] initWithContentsOfFile:path];
    }
}

+ (NSArray *)readArrDataFromPlistFileAtPath:(NSString *)path
{
    if (![self isExistFileAtPath:path]) {
        return nil;
    } else {
        return [[NSArray alloc] initWithContentsOfFile:path];
    }
}

+ (NSDictionary *)readDicDataFromPlistFileAtPath:(NSString *)path
{
    if (![self isExistFileAtPath:path]) {
        return nil;
    } else {
        return [[NSDictionary alloc] initWithContentsOfFile:path];
    }
}

//  将数组数据保存到plist文件中
+ (BOOL)writeData:(NSArray *)data ToPlistFileAtPath:(NSString *)path
{    
    if (![self isExistFileAtPath:path]) {
        NSString *dirPath = [path stringByDeletingLastPathComponent];
        
        if (![self createDir:dirPath]) {
            return NO;
        }
    }
    
    if (data) {
        return [data writeToFile:path atomically:YES];        
    } else {
        return NO;
    }
}

+ (BOOL)writeArrData:(NSArray *)data ToPlistFileAtPath:(NSString *)path
{
    if (![self isExistFileAtPath:path]) {
        NSString *dirPath = [path stringByDeletingLastPathComponent];
        
        if (![self createDir:dirPath]) {
            return NO;
        }
    }
    
    if (data) {
        return [data writeToFile:path atomically:YES];
    } else {
        return NO;
    }
}

+ (BOOL)writeDicData:(NSDictionary *)data ToPlistFileAtPath:(NSString *)path
{
    if (![self isExistFileAtPath:path]) {
        NSString *dirPath = [path stringByDeletingLastPathComponent];
        
        if (![self createDir:dirPath]) {
            return NO;
        }
    }
    
    if (data) {
        return [data writeToFile:path atomically:YES];
    } else {
        return NO;
    }
}

//  将新数据添加到plist文件中
+ (BOOL)appendData:(NSDictionary *)data ToPlistFileAtPath:(NSString *)path
{
    if (data) {
        NSMutableArray *currentData = [[NSMutableArray alloc] init];
        NSArray *originalData = [self readDataFromPlistFileAtPath:path];
        

        
        if (originalData) {
            [currentData addObjectsFromArray:originalData];            
        }
        
        [currentData addObject:data];
        return [self writeData:currentData ToPlistFileAtPath:path];
    } else {
        return NO;
    }
}

//  删除plist文件中的数据
+ (BOOL)removeData:(NSDictionary *)data FromPlistFileAtPath:(NSString *)path
{
    if (data) {
        NSMutableArray *currentData = [[NSMutableArray alloc] init];
        NSArray *originalData = [self readDataFromPlistFileAtPath:path];
        
        if (originalData) {
            [currentData addObjectsFromArray:originalData];
            [currentData removeObject:data];
            
            return [self writeData:currentData ToPlistFileAtPath:path];
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

+ (BOOL)removeDataAtIndex:(NSUInteger)index FromPlistFileAtPath:(NSString *)path
{
    NSMutableArray *currentData = [[NSMutableArray alloc] init];
    NSArray *originalData = [self readDataFromPlistFileAtPath:path];
    
    if (originalData) {
        [currentData addObjectsFromArray:originalData];
        [currentData removeObjectAtIndex:index];
        
        return [self writeData:currentData ToPlistFileAtPath:path];
    } else {
        return NO;
    }
}

@end
