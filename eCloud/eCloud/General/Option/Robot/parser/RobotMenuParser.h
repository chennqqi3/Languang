//
//  RobotMenuParser.h
//  eCloud
//  把xml格式的menu解析成RobotMenu类型的对象
//  Created by shisuping on 15/11/9.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RobotMenuParser : NSObject

//小万菜单的更新时间
@property (nonatomic,retain) NSString *updateTime;

//小万菜单数组
@property (nonatomic,retain) NSMutableArray *menuArray;


- (BOOL)parseRobotMenu:(NSString *)menuString;

@end
