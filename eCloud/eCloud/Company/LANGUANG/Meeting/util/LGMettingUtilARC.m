//
//  LGMettingUtilARC.m
//  eCloud
//
//  Created by Ji on 17/6/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGMettingUtilARC.h"
#import "eCloudConfig.h"

@implementation LGMettingUtilARC


+ (NSString *)getInterfaceUrl{

    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    NSString *OAUrl;
    int otherServer = [eCloudConfig getConfig].otherServerPort.intValue;
    if ([primaryServerUrl isEqualToString:@"im.brc.com.cn"]) {
        
        OAUrl = [NSString stringWithFormat:@"http://im.brc.com.cn:%d",otherServer];
        
    }else{
        
        OAUrl = [NSString stringWithFormat:@"http://222.209.223.92:%d",otherServer];
        
    }
    return OAUrl;
}

+ (NSString *)get9013Url{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    NSString *OAUrl;
    if ([primaryServerUrl isEqualToString:@"im.brc.com.cn"]) {
        
        OAUrl = @"http://im.brc.com.cn";
        
    }else{
        
        OAUrl = @"http://222.209.223.92:9013";
        
    }
    return OAUrl;
}

+ (NSString *)get9012Url{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    NSString *OAUrl;
    if ([primaryServerUrl isEqualToString:@"im.brc.com.cn"]) {
        
        OAUrl = @"http://im.brc.com.cn";
        
    }else{
        
        OAUrl = @"http://222.209.223.92:9012";
        
    }
    return OAUrl;
}


+ (NSString *)getTestUrl{
    
    NSString *primaryServerUrl = [eCloudConfig getConfig].primaryServerUrl;
    NSString *OAUrl;
    if ([primaryServerUrl isEqualToString:@"im.brc.com.cn"]) {
        
        OAUrl = @"http://im.brc.com.cn";
        
    }else{
        
        OAUrl = @"http://dev.brc.com.cn:9997";
        
    }
    return OAUrl;
}
@end
