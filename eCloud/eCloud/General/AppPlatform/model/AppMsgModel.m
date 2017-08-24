//
//  AppMsgModel.m
//  eCloud
//
//  Created by shisuping on 17/2/21.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "AppMsgModel.h"
#ifdef _GOME_FLAG_
#import "GOMEAppMsgModel.h"
#endif

@implementation AppMsgModel

- (void)dealloc{
    self.msgID = nil;
    self.appMsgTitle = nil;
    self.appMsgContent = nil;
    
#ifdef _GOME_FLAG_
    self.gomeAppMsgModel = nil;
#endif
    [super dealloc];
}
@end
