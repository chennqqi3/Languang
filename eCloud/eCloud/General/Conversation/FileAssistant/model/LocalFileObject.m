//
//  LocalFileObject.m
//  QuickLookDemo
//
//  Created by Pain on 14-4-10.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import "LocalFileObject.h"

//NSMutableDictionary *pathDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:file,@"fileName",[[self getFilesScaningPath] stringByAppendingPathComponent:file],@"fileFullPath",[NSNumber numberWithBool:NO],@"isSelected",@"0",@"fileSize",@"",@"fileCreateDate",nil];
//[self.dirArray addObject:pathDic];
//[pathDic release];

@implementation LocalFileObject
@synthesize fileName = _fileName;
@synthesize fileFullPath = _fileFullPath;
@synthesize fileCreateDate = _fileCreateDate;
@synthesize fileSize = _fileSize;
@synthesize isFileSelect = _isFileSelect;

-(void)dealloc
{
	self.fileName = nil;
    self.fileFullPath = nil;
	self.fileCreateDate = nil;
	[super dealloc];
}

-(NSString*)previewItemTitle
{
	return self.fileName;
}

-(NSURL*)previewItemURL
{
	
	NSString *filePath = self.fileFullPath;
	return [NSURL fileURLWithPath:filePath];
}

@end
