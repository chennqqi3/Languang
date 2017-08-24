//
//  RobotMenuParser.m
//  eCloud
//
//  Created by shisuping on 15/11/9.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "RobotMenuParser.h"

#import "GDataXMLNode.h"

#import "LogUtil.h"

#import "RobotMenu.h"

#define ELE_MENUS @"menus"
#define ELE_MENUS_UPDATE_TIME @"update_time"

#define ELE_TOP_MENU @"topMenu"
#define ELE_MENU @"menu"
#define ELE_MENU_NAME @"name"
#define ELE_MENU_ORDER @"order"
#define ELE_MENU_KEY @"key"

@implementation RobotMenuParser
@synthesize menuArray;
@synthesize updateTime;

- (void)dealloc
{
    self.menuArray = nil;
    self.updateTime = nil;
    [super dealloc];
}

- (BOOL)parseRobotMenu:(NSString *)menuString
{
    if (!menuString) {
        return NO;
    }
    
    NSError* error = nil;
    
    GDataXMLDocument* XMLdocument = [[GDataXMLDocument alloc] initWithXMLString:menuString options:0 error:&error];
    if (error) {
        [LogUtil debug:[NSString stringWithFormat:@"%s error is %@",__FUNCTION__,[error description]]];
        return NO;
    }
    
    GDataXMLElement* rootElement = [XMLdocument rootElement];
    
//    获取udpatetime属性
    self.updateTime = [[rootElement attributeForName:ELE_MENUS_UPDATE_TIME]stringValue];
    
    self.menuArray = [NSMutableArray array];
    
    NSArray *topMenuArray = [rootElement elementsForName:ELE_TOP_MENU];
    
    for (GDataXMLElement *topMenuElement in topMenuArray) {

        RobotMenu *topRobotMenu = [[[RobotMenu alloc]init]autorelease];
        topRobotMenu.menuName = [[topMenuElement attributeForName:ELE_MENU_NAME]stringValue];
        topRobotMenu.menuOrder = [[[topMenuElement attributeForName:ELE_MENU_KEY]stringValue]intValue];
        topRobotMenu.menuKey = [[topMenuElement attributeForName:ELE_MENU_KEY]stringValue];
        topRobotMenu.subMenu = [NSMutableArray array];

        [self.menuArray addObject:topRobotMenu];

        for (GDataXMLElement *subMenuElement in [topMenuElement elementsForName:ELE_MENU]) {
            
            RobotMenu *subRobotMenu = [[[RobotMenu alloc]init]autorelease];
            subRobotMenu.menuName = [[subMenuElement attributeForName:ELE_MENU_NAME]stringValue];;
            subRobotMenu.menuOrder = [[[subMenuElement attributeForName:ELE_MENU_KEY]stringValue]intValue];
            subRobotMenu.menuKey = [[subMenuElement attributeForName:ELE_MENU_KEY]stringValue];;
            [topRobotMenu.subMenu addObject:subRobotMenu];
        }
    }
    return YES;
}
@end
