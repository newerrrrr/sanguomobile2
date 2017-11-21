//
//  VoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceConverter : NSObject

+ (BOOL)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath;

+ (BOOL)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath;

@end
