//
//  OANewsEntity.h
//  WanDaOAP3_IM
//
//  Created by SF on 16/4/13.
//  Copyright © 2016年 Wanda. All rights reserved.
//

//#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface BGYOANewsEntity : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * newsdescription;
@property (nonatomic, strong) NSString * thumb;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * inputtime;
@property (nonatomic, strong) NSString * newstype;
@property (nonatomic, strong) NSNumber * updatetime;

@end
