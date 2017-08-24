//
//  UploadFileModel.m
//  WebViewCache
//
//  Created by Pain on 14-11-20.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import "UploadFileModel.h"

@implementation UploadFileModel

@synthesize upload_id;
@synthesize userid;
@synthesize filemd5;
@synthesize filename;
@synthesize filepath;
@synthesize filesize;
@synthesize type;
@synthesize rc;
@synthesize token;
@synthesize upload_start_index;
@synthesize upload_state;

- (void)dealloc{
    
    NSLog(@"%s",__FUNCTION__);
    self.upload_id = nil;
    self.userid = nil;
    self.filemd5 = nil;
    self.filename = nil;
    self.filepath = nil;
    self.rc = nil;
    self.token = nil;
    
    [super dealloc];
}


@end
