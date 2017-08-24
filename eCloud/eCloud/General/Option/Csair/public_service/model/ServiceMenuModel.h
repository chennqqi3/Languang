//
//  ServiceMenuModel.h
//  1244
//
//  Created by Pain on 14-8-25.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceMenuModel : NSObject{
    
}
@property(nonatomic,assign)int platformid;//开放平台id
@property(nonatomic,retain)NSString *createtime;//开放平台id菜单时间
@property(nonatomic,retain) NSArray *button;//自定义菜单


@end
