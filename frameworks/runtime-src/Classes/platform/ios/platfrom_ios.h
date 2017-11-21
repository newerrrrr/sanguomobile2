#ifndef __PLATFROM_IOS_H__
#define __PLATFROM_IOS_H__

#include "cocos2d.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS


class platfrom_ios
{
public:

	static char * getDeviceModel();
	
	static char * getSystemVersion();

};



#endif

#endif  // __PLATFROM_IOS_H__

