//
//  PersonServiceSingle.h
//  eCloud
//
//  Created by yanlei on 15/11/18.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonServiceSingle : NSObject

@property (nonatomic,retain) NSMutableArray *personServiceArray;

#pragma mark - 创建单例
+ (id)sharePersonServiceSingle;
@end
