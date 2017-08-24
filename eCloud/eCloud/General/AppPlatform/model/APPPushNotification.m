//
//  APPPushNotification.m
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPPushNotification.h"

@implementation APPPushNotification
@synthesize msgId;
@synthesize read_flag;
@synthesize appid;
@synthesize notinum;
@synthesize pri;
@synthesize title;
@synthesize summary;
@synthesize pushurl;
@synthesize notitime;
@synthesize src;
@synthesize needDisplayTime;
@synthesize notiTimeDisplay;

- (void)dealloc{
    self.appid = nil;
    self.title = nil;
    self.summary = nil;
    self.pushurl = nil;
    self.src = nil;
    self.notiTimeDisplay = nil;
    [super dealloc];
}
@end
