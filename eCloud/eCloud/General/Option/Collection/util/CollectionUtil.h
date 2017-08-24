//
//  CollectionUtil.h
//  eCloud
//
//  Created by Alex L on 15/10/13.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionUtil : NSObject

+ (NSString *)getFileName:(NSString *)msg_body with:(NSString *)file_name;

+ (NSString *)getTheFilePath:(NSString *)msg_body with:(NSString *)file_name;

+ (NSString *)newCollectFilePath;

+ (NSString *)newRcvFilePath;

+ (void)deleteCollection:(NSDictionary *)dic;

@end
