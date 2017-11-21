#include "paymentForLua.h"
#include "tolua_fix.h"
#include <zlib.h>

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include "ios/IapManager.h"
#endif

using namespace cocos2d;

static int paymentForLua_IOS_purchase(lua_State *L)
{
	do 
	{
		CC_BREAK_IF(lua_gettop(L) < 3);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		CC_BREAK_IF(lua_type(L, 2) != LUA_TSTRING);
        CC_BREAK_IF(lua_type(L, 3) != LUA_TSTRING);
		const char * orderId = lua_tostring(L, 1);
		const char * productId = lua_tostring(L, 2);
        const char * language = lua_tostring(L, 3);
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
        [IapManager purchase:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:orderId],@"orderId", [NSString stringWithUTF8String:productId],@"productId",[NSString stringWithUTF8String:language],@"language", nil]];
#endif
	} while (false);
	return 0;
}

static int paymentForLua_IOS_setNotifyUrl(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		const char * url = lua_tostring(L, 1);
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
		setNotifyUrl(url);
#endif
	} while (false);
	return 0;
}

void paymentForLua::paymentForLua_manual(lua_State* tolua_S)
{
	lua_register(tolua_S, "paymentForLua_IOS_purchase", paymentForLua_IOS_purchase);
	lua_register(tolua_S, "paymentForLua_IOS_setNotifyUrl", paymentForLua_IOS_setNotifyUrl);
}
