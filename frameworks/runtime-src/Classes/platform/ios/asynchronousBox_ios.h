#ifndef __LHSIOSLOC_H__
#define __LHSIOSLOC_H__

#include "cocos2d.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

class asynchronousBox_ios
{
public:
	asynchronousBox_ios();
	~asynchronousBox_ios();
    
    static void setWindows(void * windows);
    static void showAsynchronousBox();
    static void hideAsynchronousBox();
    
};

#endif

#endif //__LHSIOSLOC_H__