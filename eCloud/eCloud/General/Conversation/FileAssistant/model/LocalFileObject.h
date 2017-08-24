//
//  LocalFileObject.h
//  QuickLookDemo
//
//  Created by Pain on 14-4-10.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface LocalFileObject : NSObject<QLPreviewItem>{
    NSString * _fileName;
    NSString * _fileFullPath;
    int _fileSize;
    NSString *_fileCreateDate;
    BOOL _isFileSelect;
}
@property (nonatomic,retain) NSString *fileName;
@property (nonatomic,retain) NSString *fileFullPath;
@property(nonatomic,retain) NSString *fileCreateDate;
@property(assign) int fileSize;
@property(assign) BOOL isFileSelect;

@end
