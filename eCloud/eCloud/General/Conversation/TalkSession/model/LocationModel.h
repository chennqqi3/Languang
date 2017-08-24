//
//  LocationModel.h
//  eCloud
//  位置消息模型
//  Created by shisuping on 16/5/26.
//  Copyright © 2016年  lyong. All rights reserved.
//

//{
//    "type" : "location",
//    "location" : {
//        "latitude" : "22.52952824472849",
//        "url" : "",
//        "longitude" : "113.9417122069639",
//        "address" : "芒果网大厦-广东省深圳市南山区后海大道2378号"
//    }
//}

#import <Foundation/Foundation.h>
#import "TextMsgExtDefine.h"


@interface LocationModel : NSObject

//经度
@property (nonatomic,assign) double lantitude;
//维度
@property (nonatomic,assign) double longtitude;

//当前位置
@property (nonatomic,strong) NSString *address;
@end

@interface NewLocationModel : LocationModel

@property(nonatomic, copy) NSString *lantitudeStr;
@property(nonatomic, copy) NSString *longtitudeStr;

@end
