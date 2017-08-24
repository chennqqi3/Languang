//
//  PSSyncResParser.h
//  eCloud
//
//  Created by Richard on 13-10-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSSyncResXmlParser : NSObject<NSXMLParserDelegate>
{
}

-(bool)parse:(NSString*)syncRes;

@property(nonatomic,assign) int sequence;
@property(nonatomic,retain) NSMutableArray *accounts;

@end
