#include "reStartScene.h"
#include "../AppDelegate.h"
#include "cocostudio/CocoStudio.h"
#include "forLua/luaBindFunction.h"

USING_NS_CC;

#define DELAY_TIME (0.1f)

reStartScene* reStartScene::create(cocos2d::Application * application)
{
	reStartScene * ret = new (std::nothrow) reStartScene(application);
	if (ret && ret->init())
	{
		ret->autorelease();
		return ret;
	}
	CC_SAFE_DELETE(ret);
	return nullptr;
}

reStartScene::reStartScene(cocos2d::Application * application)
	:_delayTime(DELAY_TIME)
	, _application(application)
{

}

reStartScene::~reStartScene()
{

}

bool reStartScene::init()
{
	bool ret = Layer::init();

	this->scheduleUpdate();
	return ret;
}

void reStartScene::onEnterTransitionDidFinish()
{
	Layer::onEnterTransitionDidFinish();
	this->scheduleUpdate();
	_delayTime = DELAY_TIME;
}

void reStartScene::update(float delta)
{
	_delayTime -= delta;
	if (_delayTime < 0)
	{
		this->unscheduleUpdate();
		if (_application)
		{
			cocostudio::ArmatureDataManager::getInstance()->removeAllArmatureFileInfo();
			SpriteFrameCache::getInstance()->removeUnusedSpriteFrames();
			Director::getInstance()->getTextureCache()->removeUnusedTextures();
			((AppDelegate*)_application)->runGame();
		}
	}
}
