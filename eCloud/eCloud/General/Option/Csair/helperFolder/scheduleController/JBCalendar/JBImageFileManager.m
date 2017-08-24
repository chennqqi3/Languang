//
//  JBImageFileManager.m
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

#import "JBImageFileManager.h"


@implementation JBImageFileManager

//  获取本地路径下的图片
+ (UIImage *)ImageAtPath:(NSString *)path
{
    return [UIImage imageWithContentsOfFile:path];
}


//  保存图片到本地
+ (BOOL)saveImg:(UIImage *)img ToPath:(NSString *)path
{
    if (img) {
        if (![self isExistFileAtPath:path]) {
            NSString *dirPath = [path stringByDeletingLastPathComponent];
            
            if (![self createDir:dirPath]) {
                return NO;
            }
        }
    }
    
    NSData *imgData = UIImageJPEGRepresentation(img, 0);
    return [imgData writeToFile:path atomically:YES];
}

@end
