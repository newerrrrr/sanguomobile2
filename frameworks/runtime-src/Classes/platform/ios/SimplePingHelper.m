#import "SimplePingHelper.h"

@interface SimplePingHelper()
@property(nonatomic,retain) SimplePing* simplePing;
@property(nonatomic,retain) id target;
@property(nonatomic,assign) SEL sel;
@property(nonatomic,assign) double startTime;
@property(nonatomic,assign) double duration;

- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel;
- (void)go;
@end

@implementation SimplePingHelper
@synthesize simplePing, target, sel,startTime,duration;

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel {
	// The helper retains itself through the timeout function
	[[[[SimplePingHelper alloc] initWithAddress:address target:target sel:sel] autorelease] go];
}

#pragma mark - Init/dealloc

- (void)dealloc {
	self.simplePing = nil;
	self.target = nil;
	[super dealloc];
}

- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel {
	if (self = [self init]) {
		self.simplePing = [SimplePing simplePingWithHostName:address];
		self.simplePing.delegate = self;
		self.target = _target;
		self.sel = _sel;
	}
	return self;
}

#pragma mark - Go

- (void)go {
	[self.simplePing start];
	[self performSelector:@selector(endTime) withObject:nil afterDelay:5]; // inModes:@[NSRunLoopCommonModes]
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while (self.simplePing != nil);
}

#pragma mark - Finishing and timing out

// Called on success or failure to clean up
- (void)killPing {
	[self.simplePing stop];
	[[self.simplePing retain] autorelease]; // In case, higher up the call stack, this got called by the simpleping object itself
	self.simplePing = nil;
}

- (void)successPing {
    NSString* hostName = [self.simplePing.hostName retain];
	[self killPing];
	[target performSelector:sel withObject:hostName withObject:[NSNumber numberWithDouble:duration]];
    [hostName release];
}

- (void)failPing:(NSString*)reason {
    NSString* hostName = [self.simplePing.hostName retain];
	[self killPing];
	[target performSelector:sel withObject:hostName withObject:[NSNumber numberWithDouble:0.0]];
    [hostName release];
}

// Called 1s after ping start, to check if it timed out
- (void)endTime {
	if (self.simplePing) { // If it hasn't already been killed, then it's timed out
		[self failPing:@"timeout"];
	}
}

#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
	self.startTime =[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] doubleValue];
	[self.simplePing sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
	[self failPing:@"didFailWithError"];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
	// Eg they're not connected to any network
	[self failPing:@"didFailToSendPacket"];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
    double endTime =[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] doubleValue];
    duration = (endTime - startTime) * 1000;
   	[self successPing];
}

@end
