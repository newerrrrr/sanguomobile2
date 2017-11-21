#include "platfrom_ios.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#include <sys/types.h>
#include <sys/sysctl.h>

static char * s_deviceModel = nullptr;

char * platfrom_ios::getDeviceModel()
{
	if (!s_deviceModel)
	{
		int mib[2] = { CTL_HW, HW_MACHINE };
		size_t len;
		char * machine;
		sysctl(mib, 2, NULL, &len, NULL, 0);
		machine = new char[len + 1];
		sysctl(mib, 2, machine, &len, NULL, 0);
		NSString * platform = [NSString stringWithCString : machine encoding : NSASCIIStringEncoding];
		delete[] machine;
		const char * pUtf8 = [platform UTF8String];
		if (pUtf8)
		{
			size_t l = strlen(pUtf8);
			s_deviceModel = new char[l + 1];
            strcpy(s_deviceModel, pUtf8);
		}
	}
	return s_deviceModel;
}


static char * s_systemVersion = nullptr;

char * platfrom_ios::getSystemVersion()
{
	if (!s_systemVersion)
	{
		const char * pUtf8 = [[[UIDevice currentDevice] systemVersion] UTF8String];
		if (pUtf8)
		{
			size_t l = strlen(pUtf8);
			s_systemVersion = new char[l + 1];
			strcpy(s_systemVersion, pUtf8);
		}
	}
	return s_systemVersion;
}


#endif