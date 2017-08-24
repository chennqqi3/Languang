//
//  ImgtxtMsgModel.m
//  eCloud
//
//  Created by shisuping on 16/8/18.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "ImgtxtMsgModel.h"

@implementation ImgtxtMsgModel

@synthesize url;
@synthesize imgUrl;
@synthesize title;
@synthesize subTitle;
@synthesize fromWhere;

- (void)dealloc{

    self.url = nil;
    self.imgUrl = nil;
    self.title = nil;
    self.subTitle = nil;
    self.fromWhere = nil;
    
    [super dealloc];
}
@end
