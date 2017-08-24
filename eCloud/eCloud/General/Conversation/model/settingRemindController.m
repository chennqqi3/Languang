//
//  settingRemindController.m
//  eCloud
//
//  Created by  lyong on 12-10-29.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "settingRemindController.h"
#import "eCloudUser.h"
#import "conn.h"
#import "UserInfo.h"

static SystemSoundID moveSound;
static SystemSoundID touchSound;
static SystemSoundID showSound;

static SystemSoundID receiveSound1;
static SystemSoundID receiveSound2;

@implementation settingRemindController

@synthesize soundFlag;

static settingRemindController *settingRemind;

+(id)initSettingRemind
{
	if(settingRemind == nil)
	{
		settingRemind = [[self alloc]init];
        [settingRemind initSound];
	}
	return settingRemind;
}

#pragma mark AudioService callback function prototypes
void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID  ssID,
                                               void           *clientData
                                               );

#pragma mark AudioService callback function implementation

// Callback that gets called after we finish buzzing, so we
// can buzz a second time.
void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID  ssID,
                                               void           *clientData
                                               ) {
    
 //   vibrating = FALSE;
    
}

- (void)checkRemindType{
    
//	NSLog(@"%@",[StringUtil currentTime]);
  //  vibrating = TRUE;
//    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
//   // [setting setObject:tableData forKey:@"modeArray"];
//    BOOL soundSet=[setting boolForKey:@"soundSet"];
//    BOOL vibrateSet=[setting boolForKey:@"vibrateSet"];
    conn* _conn = [conn getConn];
    NSString *userid=_conn.userId;
    userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:userid];
//    AudioServicesAddSystemSoundCompletion (
//                                           kSystemSoundID_Vibrate,
//                                           NULL,
//                                           NULL,
//                                           MyAudioServicesSystemSoundCompletionProc,
//                                           NULL
//                                           );
    
	curtime = [[NSDate date]timeIntervalSince1970];
	
    if (userinfo.voiceFlag==1) 
	{//开启了声音

       if((curtime - oldtime) >= 3)
	   {//符合时间要求，播放声音，并且修改oldtime
//		   AudioServicesPlaySystemSound(showSound);
           if(self.soundFlag == 1)
           {
               AudioServicesPlaySystemSound(receiveSound1);
           }
           else if(self.soundFlag == 2)
           {
               AudioServicesPlaySystemSound(receiveSound2);
           }
               
		   oldtime = curtime;
//		   如果有震动则一起播放
		   if (userinfo.vibrateFlag==1) {
			   AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		   }
	   }
		
    }
	else 
	{
//		没有开启声音
		if (userinfo.vibrateFlag==1) {
//			开启了震动
			if((curtime - oldtime) > 3)
			{
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
				oldtime = curtime;				
			}
		}		
	}

    
    
}


- (void)initSound{
	
//	NSString *path ;
//    
//    path=[[NSBundle mainBundle] pathForResource:@"touch" ofType:@"caf"];
//    // path = [[NSBundle mainBundle] pathForAuxiliaryExecutable: @"touch.caf"];
//	AudioServicesCreateSystemSoundID ((CFURLRef)[NSURL fileURLWithPath:path],&touchSound);
//	
//	path = [[NSBundle mainBundle] pathForResource:@"move" ofType:@"caf"]; // button
//	AudioServicesCreateSystemSoundID ((CFURLRef)[NSURL fileURLWithPath:path],&moveSound);
//	
//	path = [[NSBundle mainBundle] pathForResource:@"focus" ofType:@"caf"]; // button
//	AudioServicesCreateSystemSoundID ((CFURLRef)[NSURL fileURLWithPath:path], &showSound);
    
    receiveSound1 = 1012;
    receiveSound2 = 1003;
}

-(void)sayHello{//发送时声音
	
	AudioServicesPlaySystemSound(touchSound);
    // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)dealloc {
	
	AudioServicesDisposeSystemSoundID (touchSound);
	AudioServicesDisposeSystemSoundID (moveSound);
	AudioServicesDisposeSystemSoundID (showSound);
    
	
    [super dealloc];
	
}


@end
