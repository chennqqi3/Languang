//
//  XIANGYUANHomeModleARC.m
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANHomeModleARC.h"

@implementation XIANGYUANHomeModleARC

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    //    if ([key isEqualToString:@"msgtype"]) {
    //        return;
    //    }
    if ([key isEqualToString:@"description"]) {//如果你觉得后台的某个key不符合你的性格或者这个类的属性，你也可以自己搞
        self.newsdescription = value;
    }
}

@end
