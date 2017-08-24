//
//  RedpacketUser.h
//  RedpacketDemo
//
//  Created by Mr.Yang on 2016/11/18.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 演示用临时用户信息 */

@interface redPacketUserInfo : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, copy) NSString *userNickName;
@property (nonatomic, copy) NSString *userAvatarURL;

+ (redPacketUserInfo *)configWithUserId:(NSString *)userId
                      userName:(NSString *)userName
                 andUserAvatar:(NSString *)userAvatar
                 andUserAvatarURL:(NSString *)userAvatarURL;

@end

@interface RedpacketUser : NSObject

@property (nonatomic, strong)             redPacketUserInfo *userInfo;
@property (nonatomic, strong)             redPacketUserInfo *talkingUserInfo;
@property (nonatomic, strong, readonly)   NSMutableArray <redPacketUserInfo *> *users;

+  (RedpacketUser *)currentUser;

- (void)loginWithSender:(NSString *)sender
            andReceiver:(NSString *)receiver;

- (void)changeUserBetweenUser1AndUser2;

- (void)loginOut;

@end
