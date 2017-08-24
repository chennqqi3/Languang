//
//  DownloadFileModel.m
//  eCloud
//
//  Created by Pain on 14-12-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "DownloadFileModel.h"

@implementation DownloadFileModel

@synthesize download_id;
@synthesize download_state;

- (void)dealloc{
    self.download_id = nil;
    [super dealloc];
}

@end
