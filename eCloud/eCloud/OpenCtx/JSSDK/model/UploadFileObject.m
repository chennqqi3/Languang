//
//  UploadFileObject.m
//  eCloud
//
//  Created by shisuping on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "UploadFileObject.h"
#import "JSONKit.h"

@implementation UploadFileObject
@synthesize uploadFilePath;
@synthesize uploadResponse;
@synthesize uploadUrl;
@synthesize uploadFileType;

- (void)dealloc
{
    self.uploadFilePath = nil;
    self.uploadResponse = nil;
    self.uploadUrl = nil;
    [super dealloc];
}

- (NSString *)getFileToken
{
    if (self.uploadResponse) {
        NSDictionary *_dic = [self.uploadResponse objectFromJSONString];
        if ([_dic[@"result"] isEqualToString:@"success"]) {
            NSString *fileToken = _dic[@"token"];
            return fileToken;
        }
    }
    return nil;
}


@end
