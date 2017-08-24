//
//  JBPlistFileManager.h
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

#import <Foundation/Foundation.h>
#import "JBBasicFileManager.h"


@interface JBPlistFileManager : JBBasicFileManager

//  读取plist文件中的数据
+ (NSArray *)readDataFromPlistFileAtPath:(NSString *)path;

+ (NSArray *)readArrDataFromPlistFileAtPath:(NSString *)path;
+ (NSDictionary *)readDicDataFromPlistFileAtPath:(NSString *)path;

//  将数组数据保存到plist文件中
+ (BOOL)writeData:(NSArray *)data ToPlistFileAtPath:(NSString *)path;

+ (BOOL)writeArrData:(NSArray *)data ToPlistFileAtPath:(NSString *)path;
+ (BOOL)writeDicData:(NSDictionary *)data ToPlistFileAtPath:(NSString *)path;


//  将新数据添加到plist文件中(For Array)
+ (BOOL)appendData:(NSDictionary *)data ToPlistFileAtPath:(NSString *)path;

//  删除plist文件中的数据
+ (BOOL)removeData:(NSDictionary *)data FromPlistFileAtPath:(NSString *)path;
//  (For Array)
+ (BOOL)removeDataAtIndex:(NSUInteger)index FromPlistFileAtPath:(NSString *)path;

@end
