//
//  GMRequestFile.h
//  GMNetworkService
//
//  Created by 岳潇洋 on 2017/6/7.
//  Copyright © 2017年 岳潇洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMRequestFile : NSObject

@property(copy,nonatomic) NSString * fileName;
@property(copy,nonatomic) NSString * keyName;
@property(strong,nonatomic) NSData * data;
@property(copy,nonatomic) NSString * miniType;

- (id)initWithFileName:(NSString *) fileName keyName:(NSString *) keyName data:(NSData *) data miniType:(NSString *) mini;
@end
