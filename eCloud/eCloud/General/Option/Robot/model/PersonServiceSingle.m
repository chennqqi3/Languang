//
//  PersonServiceSingle.m
//  eCloud
//
//  Created by yanlei on 15/11/18.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "PersonServiceSingle.h"

@implementation PersonServiceSingle
+ (id)sharePersonServiceSingle{
    static dispatch_once_t onceToken;
    static id _s;
    dispatch_once(&onceToken, ^{
        _s = [[[self class]alloc]init];
    });
    return _s;
}
@end
