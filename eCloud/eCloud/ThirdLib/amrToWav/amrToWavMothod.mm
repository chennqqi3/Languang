//
//  amrToWavMothod.m
//  eCloud
//
//  Created by  lyong on 12-11-22.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "amrToWavMothod.h"
#import "amrFileCodec.h"
@implementation amrToWavMothod

-(void)startAMRtoWAV:(NSString *)fromPath tofile:(NSString *)toPath
{
  DecodeAMRFileToWAVEFile(fromPath,toPath);

}

-(int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath
{
    
    if (EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;
    
    return 1;
}

@end
