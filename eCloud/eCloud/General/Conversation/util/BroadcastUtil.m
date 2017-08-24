//
//  BroadcastUtil.m
//  eCloud
//
//  Created by shisuping on 16/12/14.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "BroadcastUtil.h"
#import "eCloudDAO.h"
#import "eCloudDefine.h"

@implementation BroadcastUtil
+ (int)getBroadcastConvTypeWithBroadcastType:(int)broadcastType{
    int _broadcastConvType = broadcastConvType;
    switch (broadcastType) {
        case normal_broadcast:
        {
            
        }
            break;
        case imNotice_broadcast:
        {
            _broadcastConvType = imNoticeBroadcastConvType;
        }
            break;
        case appNotice_broadcast:
        {
            _broadcastConvType = appNoticeBroadcastConvType;
        }
            break;
            
        default:
            break;
    }
    
    return _broadcastConvType;
}

+ (int)getBroadcastTypeWithBroadcastConvType:(int)broadcastConvType
{
    int broadcastType = normal_broadcast;
    switch (broadcastConvType) {
        case appNoticeBroadcastConvType:
        {
            broadcastType = appNotice_broadcast;
        }
            break;
        case imNoticeBroadcastConvType:{
            broadcastType = imNotice_broadcast;
        }
            break;
            
        default:
            break;
    }
    return broadcastType;
}

@end
