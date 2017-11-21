#import <Foundation/Foundation.h>


@interface ClientInfo : NSObject
{
    
}
@property (nonatomic, retain) NSString *pingGamehostResponseDuration;
@property (nonatomic, retain) NSString *pingPayhostResponseDuration;
@property (nonatomic, retain) NSString *is_simulator;

@property (nonatomic, assign) int                pingCount;//ping的次数
@property (nonatomic, assign) BOOL               isPingFinished;//是否已经ping完毕
@property (nonatomic, assign) int                pingSuccessCount;//ping成功的次数
@property (nonatomic, assign) double             pingDurationSum;//ping持续和

@property (nonatomic, retain) NSString *payHost;
@property (nonatomic, retain) NSString *gameHost;
@property (nonatomic, retain) NSString *postUrl;

+ (ClientInfo *)sharedClientInfo;
- (NSData *) packetToData;

- (void)ping:(NSString*)address;
- (void)pingNext:(NSString*)address;
- (void)startToPing:(NSString*)address;
- (void)pingResult:(NSString*)hostName withDutaion:(NSNumber*) duration;
- (void)sendClientData;

- (NSString*) doDevicePlatform;

- (NSString *)getMacAddress;

- (double)availableMemory;

- (double)usedMemory;


@end