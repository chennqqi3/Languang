//
//  UserInfo.h
//  eCloud
//
//  Created by robert on 12-10-12.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
{
	int _userId;
	NSString *_userName;
	NSString *_userEmail;
	NSString *_userPasswd;
	NSString *_tel;
	NSString *_mobile;
	NSString *_title;
	int _compId;
	int _sex;
	int _status;
	NSString *_logo;
    int voiceFlag;
    int vibrateFlag;
    int sendreadFlag;
    int noticeFlag;
    int receiver_model_Flag;
}
@property(assign) int  receiver_model_Flag;
@property(assign) int  noticeFlag;
@property(assign) int sendreadFlag;
@property(assign) int voiceFlag;
@property(assign) int vibrateFlag;
@property(assign) int userId;
@property(retain) NSString *userName;
@property(retain) NSString *userEmail;
@property(retain) NSString *userPasswd;
@property(retain) NSString *tel;
@property(retain) NSString *mobile;
@property(retain) NSString *title;
@property(assign) int compId;
@property(assign) int sex;
@property(assign) int status;
@property(retain) NSString *logo;
@end
