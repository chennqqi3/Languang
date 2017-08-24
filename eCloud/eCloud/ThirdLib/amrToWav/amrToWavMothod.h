//
//  amrToWavMothod.h
//  eCloud
//
//  Created by  lyong on 12-11-22.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface amrToWavMothod : NSObject
-(void)startAMRtoWAV:(NSString *)fromPath tofile:(NSString *)toPath;
-(int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath;
@end
