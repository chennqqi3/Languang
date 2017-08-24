//
//  FileRecord.h
//  eCloud
//
//  Created by Richard on 13-12-6.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
#import "ConvRecord.h"
@interface FileRecord : NSObject<QLPreviewItem>

@property(retain) ConvRecord *convRecord;
@end
