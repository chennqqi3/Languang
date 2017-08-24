//
//  clearData.m
//  eCloud
//
//  Created by SH on 14-8-5.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "clearData.h"
#import "UserDefaults.h"

@implementation clearData

-(void)clearData:(NSMutableArray *)pathArry
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path in pathArry)
    {
        BOOL bRet = [fileManager fileExistsAtPath:path];
        
        if (bRet)
        {
            NSError *err;
            
            [fileManager removeItemAtPath:path error:&err];
        }
    }
}

@end
