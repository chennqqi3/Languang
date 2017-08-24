//
//  APPToken.h
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

//------TOKEN通知------//

#import <Foundation/Foundation.h>

@interface APPToken : NSObject{
    
}
@property (nonatomic,retain) NSString *usercode; //工号
@property(nonatomic,retain) NSString *token;//Token:工号+时间戳(到毫秒)+5位随机数做MD5加密

@end
