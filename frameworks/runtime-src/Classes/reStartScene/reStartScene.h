#ifndef __RESTART_SCENE_H__
#define __RESTART_SCENE_H__

#include "cocos2d.h"

class reStartScene : public cocos2d::Layer
{
private:
	reStartScene(cocos2d::Application * application);
public:
	~reStartScene();

	static reStartScene* create(cocos2d::Application * application);

	virtual bool init();

	virtual void onEnterTransitionDidFinish();

	virtual void update(float delta);

private:
	float _delayTime;
	cocos2d::Application * _application;
};



#endif