//
//  GzipUtil.h
//  eCloud
//
//  Created by Richard on 14-1-7.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GzipUtil : NSObject

+(NSString *)uncompressZippedData:(NSString*)compressedStr;

@end
