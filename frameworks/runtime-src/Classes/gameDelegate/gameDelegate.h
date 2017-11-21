#ifndef __GAME_DELEGATE_H__
#define __GAME_DELEGATE_H__

#include "cocos2d.h"

class gameDelegate : public cocos2d::pulsDirectorDelegate
{
public:
	static gameDelegate * getInstance();
	static void destroyInstance();

public:
	virtual void onDirectorDrawScene(float dt);
	virtual void onDirectorEnd();

public:
	void applicationDidEnterBackground();
	void applicationWillEnterForeground();
};



#endif