//
//  CloudFileModel.m
//  eCloud
//
//  Created by Ji on 16/11/3.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "CloudFileModel.h"

@implementation CloudFileModel
- (void)dealloc
{
    
    self.fileName = nil;
    self.fileUrl = nil;
    [super dealloc];
}
@end
