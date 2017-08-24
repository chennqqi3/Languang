//
//  Area.h
//  eCloud
//
//  Created by Richard on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Area : NSObject

@property(assign)int areaId;
@property(retain) NSString *areaName;
@property(assign)int parentArea;
@property(assign)bool isChecked;
@end
