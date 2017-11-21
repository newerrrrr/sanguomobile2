//
//  VoiceConverter.m
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceConverter.h"

#import "interf_dec.h"
//#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"
@implementation VoiceConverter

+ (BOOL)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath
{

    NSData *data=[NSData dataWithContentsOfFile:_amrPath];
    NSData *newdata=DecodeAMRToWAVE(data);
    if (newdata!=nil)
    {
        [newdata writeToFile:_savePath atomically:YES];
        return true;
    }
    else
    {
        return false;
    }
}

+ (BOOL)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath
{
    
    NSData *data=[NSData dataWithContentsOfFile:_wavPath];
    NSData *newdata=EncodeWAVEToAMR(data, 1, 16);
    if (newdata!=nil)
    {
        [newdata writeToFile:_savePath atomically:YES];
        return true;
    }
    else
    {
        return false;
    }
}


@end
