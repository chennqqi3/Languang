//
//  RobotResponseModel.m
//  eCloud
//
//  Created by yanlei on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "RobotResponseModel.h"

@implementation RobotResponseModel

//@synthesize serviceId;
//@synthesize serviceCode;
@synthesize argsArray;

@synthesize nameString;

@synthesize msgType;

@synthesize msgFileDownloadUrl;
@synthesize msgFileName;
@synthesize msgFileSize;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.argsArray = [[[NSMutableArray alloc]init]autorelease];
        
        self.imgtxtArray = [[[NSMutableArray alloc]init]autorelease];
    }
    return self;
}

-(void)dealloc
{
    self.msgFileSize = nil;
    self.msgFileName = nil;
    self.msgFileDownloadUrl = nil;
    
    if (self.argsArray) {
        self.argsArray = nil;
    }
    
    if (self.imgtxtArray) {
        self.imgtxtArray = nil;
    }
    
    self.nameString = nil;
    self.type = nil;
    self.content = nil;
    //    self.serviceCode = nil;
    [super dealloc];
}
@end
