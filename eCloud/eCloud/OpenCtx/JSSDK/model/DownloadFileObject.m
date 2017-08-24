//
//  DownloadFileObject.m
//  eCloud
//
//  Created by shisuping on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "DownloadFileObject.h"

@implementation DownloadFileObject

@synthesize downloadFilePath;
@synthesize downloadUrl;
@synthesize downloadResult;
@synthesize progressView;
@synthesize userInfo;

//@synthesize downloadFileType;
//@synthesize fileToken;
//@synthesize downloadFileName;
- (void)dealloc
{
//    self.fileToken = nil;
    self.userInfo = nil;
    self.progressView = nil;
    self.downloadUrl = nil;
    self.downloadFilePath = nil;
    
    [super dealloc];
}
@end
