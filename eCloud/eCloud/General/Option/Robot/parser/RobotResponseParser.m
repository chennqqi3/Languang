//
//  RobotResponseParser.m
//  eCloud
//
//  Created by shisuping on 16/12/26.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "RobotResponseParser.h"
#import "GDataXMLNode.h"
#import "LogUtil.h"

@implementation RobotResponseParser

+ (void)parse:(NSString *)message
{
    [LogUtil debug:[NSString stringWithFormat:@"%s message is %@",__FUNCTION__,message]];

    NSError *error;
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:message options:0 error:&error];
    
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *array = [xmlEle children];
    NSLog(@"count : %lu", (unsigned long)[array count]);
    
    [[self class]displayElement:xmlEle];
}

+ (void)displayElement:(GDataXMLElement *)ele
{
    [LogUtil debug:[NSString stringWithFormat:@"%s %@ ",__FUNCTION__,[ele description]]];
    
    for (GDataXMLElement *subEle in [ele children]) {
        [[self class]displayElement:subEle];
    }

}


@end
