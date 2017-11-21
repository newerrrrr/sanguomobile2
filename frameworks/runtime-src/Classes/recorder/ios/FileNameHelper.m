

#import "FileNameHelper.h"

@implementation FileNameHelper

/**
获取缓存路径
@returns 缓存路径
*/
+ (NSString*)getCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0]stringByAppendingPathComponent:@"Voice"];
}


/**
生成文件路径
@param _fileName 文件名
@param _type 文件类型
@returns 文件路径
*/
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[FileNameHelper getCacheDirectory]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}


+ (NSString*)getFullpath:(NSString *)_path ofName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[_path stringByAppendingPathComponent:_fileName] stringByAppendingPathExtension:_type];

    return fileDirectory;
}




+ (void)setAudioOutputPort
{
    if (![FileNameHelper isHeadphonesPluggedIn]) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
}

+ (BOOL)isHeadphonesPluggedIn
{
    NSArray *availableOutputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    for (AVAudioSessionPortDescription *portDescription in availableOutputs) {
        if ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
    }
    return NO;
}





@end
