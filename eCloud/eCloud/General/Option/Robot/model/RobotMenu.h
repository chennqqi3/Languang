//
//  RobotMenu.h
//  eCloud
//
//  Created by shisuping on 15/11/9.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RobotMenu : NSObject

@property (nonatomic,retain) NSString *menuName;
@property (nonatomic,assign) int menuOrder;
@property (nonatomic,retain) NSString *menuKey;

//是否被选中
@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,retain) NSMutableArray *subMenu;

@end
