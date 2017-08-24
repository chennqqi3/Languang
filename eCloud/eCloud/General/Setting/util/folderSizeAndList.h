//
//  allFileSize.h
//  eCloud
//
//  Created by SH on 14-8-8.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface folderSizeAndList : NSObject

-(NSArray *) getFileList:(NSString *)directoryPath;

//-(NSString *) getALLFileSize:(NSString *) directoryPath;

-(long long) getALLFileSizeLong:(NSString *) directoryPath;

-(NSString *) singleFileSize:(NSString *) filePath;

- (long long) fileSizeAtPath:(NSString*) filePath;

@end
