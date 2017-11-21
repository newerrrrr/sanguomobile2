#include "SimpleAudioEngine.h"
#include "gameDelegate.h"
#include "CCLuaEngine.h"
#include "cocos-ext.h"
#include "../forLua/luaBindFunction.h"
#include "ui/CocosGUI.h"
#include "cocostudio/CocoStudio.h"
#include "../httpNet/httpNet.h"
#include "../cTools_Control/LHSTmxCache.h"

USING_NS_CC;
USING_NS_CC_EXT;
using namespace CocosDenshion;

static gameDelegate *s_gameDelegate = nullptr;

gameDelegate * gameDelegate::getInstance()
{
	if (!s_gameDelegate)
		s_gameDelegate = new (std::nothrow) gameDelegate();
	return s_gameDelegate;
}

void gameDelegate::destroyInstance()
{
	if (s_gameDelegate)
	{
		delete s_gameDelegate;
		s_gameDelegate = nullptr;
	}
}

#define GC_Wait_Time (10.0f)
void gameDelegate::onDirectorDrawScene(float dt)
{
	int id = luaBindFunction::getInstance()->getLuaFunction("onMainLoop");
	if (id != DEF_FUNCTION_NIL)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushFloat(dt);
		pStack->executeFunctionByHandler(id, 1);
		pStack->clean();


		static float s_gctime = GC_Wait_Time;
		s_gctime -= dt;
		if (s_gctime <= 0.0f)
		{
			lua_gc(pStack->getLuaState(), LUA_GCCOLLECT, 0);
			s_gctime = GC_Wait_Time;
		}
	}
	httpNet::getInstance()->updateLoop();
}

void gameDelegate::onDirectorEnd()
{
	int id = luaBindFunction::getInstance()->getLuaFunction("onExitGame");
	if (id != DEF_FUNCTION_NIL)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->executeFunctionByHandler(id, 0);
		pStack->clean();

		//gc for end
		lua_gc(pStack->getLuaState(), LUA_GCCOLLECT, 0);
	}

	CSLoader::destroyInstance();
	httpNet::destroyInstance();
	LHSTmxCache::destroyInstance();
}

void gameDelegate::applicationDidEnterBackground()
{
	int id = luaBindFunction::getInstance()->getLuaFunction("onDidEnterBackground");
	if (id != DEF_FUNCTION_NIL)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->executeFunctionByHandler(id, 0);
		pStack->clean();
	}
	else
	{
		Director::getInstance()->pause();
		Director::getInstance()->stopAnimation();
		SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
		SimpleAudioEngine::getInstance()->pauseAllEffects();
	}
}

void gameDelegate::applicationWillEnterForeground()
{
	int id = luaBindFunction::getInstance()->getLuaFunction("onWillEnterForeground");
	if (id != DEF_FUNCTION_NIL)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->executeFunctionByHandler(id, 0);
		pStack->clean();
	}
	else
	{
		Director::getInstance()->resume();
		Director::getInstance()->startAnimation();
		SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
		SimpleAudioEngine::getInstance()->resumeAllEffects();
	}
}

