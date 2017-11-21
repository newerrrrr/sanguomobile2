
#import <AVFoundation/AVFoundation.h>

@interface FileNameHelper : NSObject

/**
获取缓存路径
@returns 缓存路径
*/
+ (NSString*)getCacheDirectory;


/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;

+ (NSString*)getFullpath:(NSString *)_path ofName:(NSString *)_fileName ofType:(NSString *)_type;

+ (void)setAudioOutputPort;

+ (BOOL)isHeadphonesPluggedIn;


@end
