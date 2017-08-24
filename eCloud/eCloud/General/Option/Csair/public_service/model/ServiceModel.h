//
//  ServiceModel.h
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceModel : NSObject
{
	
}
@property(nonatomic,assign) int serviceId;
@property(nonatomic,retain) NSString *serviceCode;
@property(nonatomic,retain) NSString *serviceName;
@property(nonatomic,retain) NSString *servicePinyin;
@property(nonatomic,retain) NSString *serviceUrl;
@property(nonatomic,retain) NSString *serviceIcon;
@property(nonatomic,retain) NSString *serviceDesc;
@property(nonatomic,assign) int followFlag;
@property(nonatomic,assign) int rcvMsgFlag;
@property(nonatomic,retain) NSString *lastInputMsg;
@property(assign)int serviceType;
@property(assign)int serviceStatus;

@end
