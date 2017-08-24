//
//  FileRecord.m
//  eCloud
//
//  Created by Richard on 13-12-6.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "FileRecord.h"
#import "talkSessionUtil.h"
#import "StringUtil.h"
#import "EncryptFileManege.h"
#import "CollectionUtil.h"
#import "eCloudDefine.h"
#import "RobotResponseModel.h"
#import "RobotUtil.h"
@implementation FileRecord
@synthesize convRecord;
//@synthesize previewItemTitle;
//@synthesize previewItemURL;

-(void)dealloc
{
	self.convRecord = nil;
	[super dealloc];
}

-(NSString*)previewItemTitle
{
    if (self.convRecord.isRobotFileMsg) {
        return self.convRecord.robotModel.msgFileName;
    }
	return self.convRecord.file_name;
}
-(NSURL*)previewItemURL
{
    if (self.convRecord.isRobotFileMsg) {
        
        NSString *filePath = [RobotUtil getDownloadFilePathWithConvRecord:self.convRecord];
        
        return [NSURL fileURLWithPath:filePath];
    }
    NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:self.convRecord]];
    
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *newPath = [tmpDir stringByAppendingPathComponent:[talkSessionUtil getFileName:self.convRecord]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            return [NSURL fileURLWithPath:newPath];
        }
        NSData *data = [EncryptFileManege getDataWithPath:filePath];
//        NSString *path = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:@"tempFile"];
        
        [data writeToFile:newPath atomically:YES];
        
        return [NSURL fileURLWithPath:newPath];
    }
	
	return [NSURL fileURLWithPath:filePath];
}

@end
