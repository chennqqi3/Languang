//
//  RedpacketConfig1.m
//  RedpacketDemo
//
//  Created by Mr.Yang on 2016/10/22.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketConfig.h"
#import "YZHRedpacketBridge.h"
#import "YZHRedpacketBridgeProtocol.h"
#import "ASIFormDataRequest.h"
#import "RedpacketLib.h"
#import "RedpacketMessageCell.h"
#import "RedpacketTakenMessageTipCell.h"
#import "RedpacketUser.h"
#import "JSONKit.h"
#import "UserDefaults.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "Emp.h"
#import "ServerConfig.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "AESCipher.h"
#ifdef _LANGUANG_FLAG_

#import "LGMettingUtilARC.h"

#endif


static NSString *baseURL = @"https://rpv2.yunzhanghu.com";
static NSString *tokenRequestURL = @"/api/demo-sign?token=1&uid=";

#define WechatPayAppID      @"wx634a5f53be1b66bd"

@implementation NSDictionary (ValueForKey)

- (NSString *)stringValueForKey:(NSString *)key;
{
    id value = [self valueForKey:key];
    
    return [NSString stringWithFormat:@"%@", value];
}

@end

@interface RedpacketConfig () <YZHRedpacketBridgeDelegate, YZHRedpacketBridgeDataSource,ASIHTTPRequestDelegate>

@property (nonatomic, strong)   RedpacketViewControl *viewControl;

@property (nonatomic, copy) RedpacketSendPacketBlock sendBlock;
@property (nonatomic, copy) RedpacketGrabPacketBlock grabBlock;
@property(strong,nonatomic) Emp *emp;
@end


@implementation RedpacketConfig
{
    conn *_conn;
    eCloudDAO *db;
}
+ (RedpacketConfig *)sharedConfig
{
    static RedpacketConfig *__redpacketConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __redpacketConfig = [RedpacketConfig new];
    });
    
    return __redpacketConfig;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        [YZHRedpacketBridge sharedBridge].delegate = self;
        [YZHRedpacketBridge sharedBridge].dataSource = self;
        [YZHRedpacketBridge sharedBridge].isDebug = YES;
        
    }
    
    return self;
}

- (RedpacketUserInfo *)redpacketUserInfo
{
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
    self.emp = [db getEmpInfo:_conn.userId];
    
    ServerConfig *serverConfig = [ServerConfig shareServerConfig];

    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = [NSString stringWithFormat:@"%d",self.emp.emp_id];//;
    userInfo.userNickname = self.emp.emp_name; //[RedpacketUser currentUser].userInfo.userNickName;
    userInfo.userAvatar = [serverConfig getLogoUrlByEmpId:_conn.userId];//[RedpacketUser currentUser].userInfo.userAvatarURL;
    return userInfo;
    
}

/** 签名接口调用， 签名接口写法见官网文档 */
- (void)fetchUserSignWithUserID:(FetchRegisitParamBlock)fetchBlock
{

    NSString *userId = [self redpacketUserInfo].userId;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];
    NSString *paramStr = [NSString stringWithFormat:@"%@:%@",userId,timeString];
    NSString *sign = [AESCipher encryptAES:paramStr key:@"24899uyqwe45sd25"];
    
    if (userId) {

#ifdef _LANGUANG_FLAG_
        
        NSString *url = [NSString stringWithFormat:@"%@/FilesService/getRedkey?param=%@",[LGMettingUtilARC getInterfaceUrl],sign];

        
        ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];

        [requestForm startSynchronous];
        
        //输入返回的信息
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取红包签名 %@",__FUNCTION__,[requestForm responseString]]];
        NSString *jsonString = [requestForm responseString];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [jsonData objectFromJSONData];
        if ([resultDict[@"status"] isEqualToString:@"success"]) {
            
            //[self configWithSignDict:resultDict[@"data"] andBlock:fetchBlock];
            NSString *partner = @"712384";
            NSString *sign = resultDict[@"data"];
            RedpacketRegisitModel *model = [RedpacketRegisitModel signModelWithAppUserId:userId
                                                                              signString:sign
                                                                                 partner:partner
                                                                            andTimeStamp:timeString];
            NSLog(@"ReturnModel");
            fetchBlock(model);
        }
        
#endif
    }
    
    
}

- (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    
    return HMAC;
}

#pragma mark Redpacket
/** 红包SDK回调此函数进行注册 */
- (void)redpacketFetchRegisitParam:(FetchRegisitParamBlock)fetchBlock withError:(NSError *)error
{
    NSLog(@"RequestToken");
    [self fetchUserSignWithUserID:fetchBlock];
}

@end


@implementation RedpacketConfig (RedpacketControllers)

- (UITableViewCell *)cellForRedpacketMessageDict:(NSDictionary *)dict
{
    //NSDictionary *redpacketMessageDict = [dict valueForKey:@"1"];
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"redPacket"]) {
        
        RedpacketMessageModel *redpacketMessageModel = [RedpacketMessageModel redpacketMessageModelWithDic:dict];
        RedpacketMessageCell *cell = [[RedpacketMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configWithRedpacketMessageModel:redpacketMessageModel andRedpacketDic:dict];
   
        return cell;
        
    }else if([type isEqualToString:@"redPacketAction"]) {
        
//        redpacketMessageDict = [dict valueForKey:@"2"];
        RedpacketMessageModel *redpacketMessageModel = [RedpacketMessageModel redpacketMessageModelWithDic:dict];
        RedpacketTakenMessageTipCell *tipCell = [[RedpacketTakenMessageTipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [tipCell configWithRedpacketMessageModel:redpacketMessageModel andRedpacketDic:dict];
        tipCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return tipCell;
        
    }
    return nil;
}

- (CGFloat)heightForRedpacketMessageDict:(NSDictionary *)dict
{
    NSString *type = dict[@"type"];
    
    RedpacketMessageModel *redpacketMessageModel = [RedpacketMessageModel redpacketMessageModelWithDic:dict];
    if ([type isEqualToString:@"redPacket"]) {
        
        return [RedpacketMessageCell heightForRedpacketMessageCell:redpacketMessageModel];
    }else if([type isEqualToString:@"redPacketAction"]){
        
        return [RedpacketTakenMessageTipCell heightForRedpacketMessageTipCell];
        
    }
    return 1;
//    NSDictionary *redpacketMessageDict = [dict valueForKey:@"1"];
//    
//    RedpacketMessageModel *redpacketMessageModel = [RedpacketMessageModel redpacketMessageModelWithDic:redpacketMessageDict];
//    if (redpacketMessageDict) {
//        return [RedpacketMessageCell heightForRedpacketMessageCell:redpacketMessageModel];
//        
//    }else {
//        return [RedpacketTakenMessageTipCell heightForRedpacketMessageTipCell];
//        
//    }
}

-(void)showView:(UIView *)parentView
{
    parentView.hidden = NO;
    for(UIView *view in parentView.subviews)
    {
        view.hidden = NO;
        [self showView:view];

    }
}


@end

