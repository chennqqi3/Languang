//
//  BizConfVideoSDK.h
//  Bizconfsdk
//
//  Created by bizconf on 16/8/8.
//  Copyright © 2016年 bizconf. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BizConfVideoSDKSettings.h"



typedef enum {
    //Success
    SDKMeetError_Success                    = 0,
    //Not Authorized
    SDKMeetError_NotAuthorized,
    //Incorrect meeting number
    SDKMeetError_IncorrectMeetingNumber,
    //Meeting Timeout
    SDKMeetError_MeetingTimeout,
    //Network Unavailable
    SDKMeetError_NetworkUnavailable,
    //Client Version Incompatible
    SDKMeetError_MeetingClientIncompatible,
    //User is Full
    SDKMeetError_UserFull,
    //Meeting is over
    SDKMeetError_MeetingOver,
    //Meeting does not exist
    SDKMeetError_MeetingNotExist,
    //Meeting has been locked
    SDKMeetError_MeetingLocked,
    //Meeting Restricted
    SDKMeetError_MeetingRestricted,
    //JBH Meeting Restricted
    SDKMeetError_MeetingJBHRestricted,
    
    //Invalid Arguments
    SDKMeetError_InvalidArguments,
    SDKMeetError_InvalidUserType,
    //Already In another ongoing meeting
    SDKMeetError_InAnotherMeeting,
    //Unknown error
    SDKMeetError_Unknown,
    
    
    
}BizSDKMeetError;

typedef enum {
    //Auth Success
    BizSDKAuthError_Success                 = 200,
    //Invalid channelID
    BizSDKAuthError_InvalidChannelID,
    //Key or Secret is empty
    BizSDKAuthError_KeyOrChannelIDEmpty,
    //Network or Server problem
    BizSDKAuthError_ConnectionError,
    //Auth Unknown error
    BizSDKAuthError_Unknown
}BizSDKAuthError;

@protocol BizConfVideoSDKDelegate <NSObject>

@optional

-(void)onMeetingEnd;

@end

@interface BizConfVideoSDK : NSObject

@property (assign, nonatomic) id<BizConfVideoSDKDelegate> delegate;

+ (instancetype)sharedSDK;

-(BOOL)isAuthorized;
/**
 该方法用于验证用户信息
 channelId:客户授权码
 key:客户的识别码
 target:用于验证调用代理方法,默认为appdelegate里的self
 result:认证的结果
 */
- (void)authSdk:(NSString *)channelId
        withKey:(NSString *)key
     withTarget:(id) target
         result:(void (^)(BizSDKAuthError))completion;

- (void)authSdk:(NSString *)channelId
        withKey:(NSString *)key
     withTarget:(id) target
resultWithDetail:(void (^)(BizSDKAuthError authErrorCode
                           ,NSURLResponse * response
                           ,NSError * error))completion;

/**
 该方法用于计入会议
 userName :参会人的姓名
 meetingNum: 会议号
 uid:参会人的身份标识(非必填，可以为空)
 */
- (void)joinMeeting:(NSString *) userName
          meetingNo:(NSString *)meetingNo
                uid:(NSString *)uid
           password:(NSString *)password
               cuid:(NSString *)cuid
            isAudio:(BOOL) audio
            isvideo:(BOOL) video
             result:(void (^)(BizSDKMeetError))completion;

/**
 该方法用于开启会议
 userId 收到结果客户端从bizconf站点用户帐户。
 userName 用户名将被用作显示名称的bizconf会议。
 Token 收到结果客户端从bizconf站点用户帐户。
 meetingNo 会议号
 */
- (void)startMeeting:(NSString *)userId
            userName:(NSString *)userName
           userToken:(NSString *)token
           meetingNo:(NSString *)meetingNo
                cuid:(NSString *)cuid
              result:(void (^)(BizSDKMeetError))completion;


/**
 * Sets the client root navigation controller
 *
 * @param nav: A root navigation controller for pushing meeting UI.
 *
 * *Note*: This method is optional, If the window's rootViewController of the app is a UINavigationController, you can call this method, or just ignore it.
 */
- (void)setNavC:(UINavigationController *) nav;

@end










