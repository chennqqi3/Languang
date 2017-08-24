//
//  GOMEAppMsgModel.m
//  eCloud
//
//  Created by shisuping on 17/2/21.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "GOMEAppMsgModel.h"

@implementation GOMEAppMsgModel

- (void)dealloc{
    self.msgContent = nil;
    self.extendMsg = nil;
    [super dealloc];
}
@end
