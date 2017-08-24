//
//  LGNewsMdelARC.h
//  eCloud
//
//  Created by Ji on 17/6/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGNewsMdelARC : NSObject

@property (nonatomic,strong) NSString *type;

@property (nonatomic,strong) NSString *title;

@property (nonatomic,strong) NSString *url;

+ (instancetype)newsModelWithDic:(NSDictionary *)dic;
    
@end
