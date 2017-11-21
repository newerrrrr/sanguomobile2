//
//  ARRecorder.h
//  AudioRecorder
//
//  Created by A. Emre Ünal on 07/07/14.
//  Copyright (c) 2014 A. Emre Ünal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface ARRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

+ (ARRecorder*) getInstance;

+ (void) destroyInstance;

+ (void) startRecord:(NSDictionary *)dict;

+ (void) stopRecord:(NSDictionary *)dict;

+ (void) cancelRecord;

+ (void) startPlaySound:(NSDictionary *)dict;

+ (void) stopPlayingSound;


- (void)setScriptHandler:(int)scriptHandler;

- (int) getScriptHandler;

- (BOOL)onStartRecording;

- (void)onStopRecording;

- (void)onCancelRecording;

- (BOOL)onStartPlaying:(NSString *)filepath;

- (void)onStopPlaying;

- (void)stopPlayingAndRecording;

- (BOOL)recording;

- (BOOL)playing;

- (NSMutableDictionary *)getRecorderSettings;

- (void)onRecordResult:(BOOL)result;

- (void)onPlayResult:(BOOL)result;

- (BOOL)pcmToMp3;


@end
