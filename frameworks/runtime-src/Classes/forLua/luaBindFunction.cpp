#include "luaBindFunction.h"

static const unsigned char gfhfdgdfg[16] = {
	0x2b,
	0x21,
	0x20,
	0x2d,
	0x20,
	0x2b,
	0x71,
	0x7d,
	0x6a,
	0x72,
	0x73,
	0x7f,
	0x71,
	0x78,
	0x7d,
	0x6b,
};

const unsigned char * cxvxzcdsfrhgfhgdfgsdf = gfhfdgdfg;


static luaBindFunction *s_luaBindFunction = nullptr;

luaBindFunction * luaBindFunction::getInstance()
{
	if (!s_luaBindFunction)
		s_luaBindFunction = new (std::nothrow) luaBindFunction();
	return s_luaBindFunction;
}

void luaBindFunction::destroyInstance()
{
	if (s_luaBindFunction)
	{
		delete s_luaBindFunction;
		s_luaBindFunction = nullptr;
	}
}

luaBindFunction::luaBindFunction()
{

}

luaBindFunction::~luaBindFunction()
{
	
}

void luaBindFunction::binLuaFunction(int nHandler, const char * funName)
{
	if (funName && strcmp(funName, ""))
	{
		if (_functions.find(funName) != _functions.end())
		{
			CCLOG("Warning : function \"%s\" repeat , will remove last", funName);
			removeLuaFunction(funName);
		}
		_functions.insert(std::pair<std::string, int>(funName, nHandler));
	}
}

void luaBindFunction::removeLuaFunction(const char * funName)
{
	std::map<std::string, int>::iterator it = _functions.find(funName);
	if (it != _functions.end())
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(it->second);
		_functions.erase(it);
	}
}

void luaBindFunction::removeAllLuaFunction()
{
	for (std::map<std::string, int>::iterator it = _functions.begin(); it != _functions.end(); it++)
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(it->second);
	_functions.clear();
}

int luaBindFunction::getLuaFunction(const char * funName)
{
	std::map<std::string, int>::iterator it = _functions.find(funName);
	if (it != _functions.end())
		return it->second;
	return DEF_FUNCTION_NIL;
}