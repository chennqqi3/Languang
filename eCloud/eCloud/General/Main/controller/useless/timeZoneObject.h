//
//  timeZoneObject.h
//  eCloud
//
//  Created by  lyong on 12-10-23.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface timeZoneObject : NSObject
{

    NSString *nameStr;
    NSString*recordDate;
    int readState;
	int _msgId;
	bool _display;
	NSTimeInterval _msgTime;
}
@property(nonatomic,retain) NSString *nameStr;
@property(nonatomic,retain) NSString *recordDate;
@property(assign)int readState;
@property(assign)int msgId;
@property(assign)bool display;
@property(assign)NSTimeInterval msgTime;

@end
