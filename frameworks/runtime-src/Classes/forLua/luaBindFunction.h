#ifndef __LUABINDFUNCTION_H__
#define __LUABINDFUNCTION_H__

#include "cocos2d.h"

#define DEF_FUNCTION_NIL	(-1)

class luaBindFunction
{
public:
	static luaBindFunction * getInstance();
	static void destroyInstance();

	luaBindFunction();
	~luaBindFunction();

	void binLuaFunction(int nHandler, const char * funName);

	void removeLuaFunction(const char * funName);

	void removeAllLuaFunction();

	//failed return DEF_FUNCTION_NIL
	int getLuaFunction(const char * funName);

private:
	std::map<std::string, int> _functions;
};

extern const unsigned char * cxvxzcdsfrhgfhgdfgsdf;

#endif //__LUABINDFUNCTION_H__