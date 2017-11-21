#ifndef __ASYNCHRONOUSBOX_H__
#define __ASYNCHRONOUSBOX_H__

#include "cocos2d.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
 

class asynchronousBox_Win32
{
public:
	asynchronousBox_Win32();
	~asynchronousBox_Win32();

	//显示异步框
	static void showAsynchronousBox();
	//关闭异步框
	static void hideAsynchronousBox();

};


#endif

#endif  //! __ASYNCHRONOUSBOX_H__