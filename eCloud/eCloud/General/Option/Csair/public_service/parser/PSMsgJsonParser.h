//
//  PSMsgJsonParser.h
//  eCloud
//
//  Created by Richard on 13-10-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceMessage;
@interface PSMsgJsonParser : NSObject

-(ServiceMessage *)parsePsMsg:(NSString*)psMsg;

-(NSMutableArray *)parsePSMenuList:(NSString*)menuListStr;//解析公众平台菜单

@end
