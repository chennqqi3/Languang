//
//  AutoSendMsg.h
//  eCloud
//
//  Created by robert on 12-9-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoSendMsg : NSObject
{
	int _id;
	NSString *msg;
}
@property (assign) int id;
@property (retain) NSString *msg;
@end
