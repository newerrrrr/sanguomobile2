#import "ClientInfo.h"
#import "SimplePingHelper.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <net/if.h>
#import <net/if_dl.h>

static ClientInfo *_sharedClientInfo = nil;

@implementation ClientInfo

+ (ClientInfo *)sharedClientInfo;
{
    @synchronized(self)
    {
        if(_sharedClientInfo == nil)
        {
            _sharedClientInfo = [[ClientInfo alloc] init];
        }
    }
    return _sharedClientInfo;
}

- (id)init
{
    if((self = [super init]))
    {
    }
    return self;
}

- (NSData *)packetToData
{
    NSString *packetString = [[[NSString alloc] init] autorelease];
    UIDevice *device = [UIDevice currentDevice];
    
    if(self.pingGamehostResponseDuration != nil)
    {
        packetString = [packetString stringByAppendingString:@"ping_game_host="];
        packetString = [packetString stringByAppendingString:self.pingGamehostResponseDuration];
    }
    if(self.pingPayhostResponseDuration != nil)
    {
        packetString = [packetString stringByAppendingString:@"&ping_pay_host="];
        packetString = [packetString stringByAppendingString:self.pingPayhostResponseDuration];
    }
    
    //是否模拟器
    packetString = [packetString stringByAppendingString:@"&is_simulator="];
    NSString *sercher = @"Simulator";
    NSRange foundObj=[[device model] rangeOfString:sercher options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        packetString = [packetString stringByAppendingString:@"true"];
    } else {
        packetString = [packetString stringByAppendingString:@"false"];
    }
    
    //是否有电话功能
    sercher = @"iPhone";
    packetString = [packetString stringByAppendingString:@"&has_phone="];
    foundObj=[[device model] rangeOfString:sercher options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        packetString = [packetString stringByAppendingString:@"true"];
    } else {
        packetString = [packetString stringByAppendingString:@"false"];
    }
    
    //游戏
    packetString = [packetString stringByAppendingString:@"&game=sanguomobile2"];
    
    //系统版本号
    packetString = [packetString stringByAppendingString:@"&api_version="];
    packetString = [packetString stringByAppendingString:[device systemVersion]];
    
    //用户设备具体品牌及型号
    packetString = [packetString stringByAppendingString:@"&device_brand="];
    packetString = [packetString stringByAppendingString:[device model]];
    
    //显示屏信息
    UIScreen *currentScreen = [UIScreen mainScreen];
    NSString* scree=[NSString stringWithFormat:@"&screen_info=width:%0.1f;height:%0.1f",currentScreen.bounds.size.width,currentScreen.bounds.size.height];
    packetString = [packetString stringByAppendingString:scree];

    //内存信息
    NSString *memory = [NSString stringWithFormat:@"可用内存:%f;已用内存:%f", [self availableMemory],[self usedMemory]];
    packetString = [packetString stringByAppendingString:@"&system_memory="];
    packetString = [packetString stringByAppendingString:memory];
    
#ifdef LOGON
    NSLog(@"packetToData %@",packetString);
#endif
    return [packetString dataUsingEncoding:NSUTF8StringEncoding];
}

// ping==>pingNext==>startToPing
-(void) ping:(NSString *)address{
    self.pingGamehostResponseDuration=nil;
    self.pingPayhostResponseDuration=nil;
    self.isPingFinished=NO;
    [self pingNext:address];
}

-(void) pingNext:(NSString *)address{
    self.pingSuccessCount=0;
    self.pingCount=0;
    self.pingDurationSum=0.0;
    [self startToPing:address];
}

-(void) startToPing:(NSString *)address{
    self.pingCount++;
    [SimplePingHelper ping:address target:self sel:@selector(pingResult:withDutaion:)];
    
}

- (void)pingResult:(NSString*)hostName withDutaion:(NSNumber*) duration
{
    if(![duration isEqualToNumber:[NSNumber numberWithDouble:0.0]])
    {
        self.pingSuccessCount++;
        self.pingDurationSum=self.pingDurationSum+[duration doubleValue];
        NSLog(@"success %f %@",[duration doubleValue],hostName);
    }
    else
    {
        NSLog(@"fail %@",hostName);
    }
    
    if(self.pingSuccessCount<4 && self.pingCount<=10)
    {
        [self startToPing:hostName];
    }
    else
    {
        if(self.pingSuccessCount>0)
        {
            if(self.pingGamehostResponseDuration==nil)
            {
                self.pingGamehostResponseDuration=[NSString stringWithFormat:@"%.2fms",self.pingDurationSum/self.pingSuccessCount];
                NSLog(@"self.pingGamehostResponseDuration=%@,hostName=%@",self.pingGamehostResponseDuration,hostName);
            }
            else if(self.pingPayhostResponseDuration==nil)
            {
                self.pingPayhostResponseDuration=[NSString stringWithFormat:@"%.2fms",self.pingDurationSum/self.pingSuccessCount];
                NSLog(@"self.pingPayhostResponseDuration=%@,hostName=%@",self.pingPayhostResponseDuration,hostName);
                [self sendClientData];
            }
        }
        
        if(self.pingPayhostResponseDuration==nil && !self.isPingFinished)
        {
            self.isPingFinished=YES;
            if([hostName isEqualToString:self.payHost])
            {
                [self sendClientData];
            }
            else
            {
                [self pingNext:self.payHost];
            }
        }
    }
}

-(void)sendClientData
{
    //将NSSrring格式的参数转换格式为NSData，POST提交必须用NSData数据。
    NSData *postData = [self packetToData];

    //计算POST提交数据的长度
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSLog(@"postLength=%@",postLength);

    //定义NSMutableURLRequest
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];

    //设置提交目的url
    [request setURL:[NSURL URLWithString:self.postUrl]];

    //设置提交方式为 POST
    [request setHTTPMethod:@"POST"];

    //设置http-header:Content-Type
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    //设置http-header:Content-Length
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    //设置需要post提交的内容
    [request setHTTPBody:postData];

    [[[NSURLConnection alloc]initWithRequest:request delegate:self]autorelease];

}

//接收到服务器回应的时候调用此方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"----connection didReceiveResponse-----");
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
}
//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"----connection didReceiveData----- data=%@",data);
}
//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *receiveStr = [[NSString alloc]initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"----connectionDidFinishLoading-----");
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}

- (NSString*) doDevicePlatform
{
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}
// 获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}
#pragma mark -
#pragma mark dealloc
- (void)dealloc
{
    [_sharedClientInfo release];
    
    [super dealloc];
}
@end