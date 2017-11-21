
#ifndef _H_NETLUA_H_  
#define _H_NETLUA_H_  

#include "NetCommon.h"

#define ENABLE_LUA_BINDING 1

#if ENABLE_LUA_BINDING
#if __cplusplus
extern "C" {
#endif // #if __cplusplus
#include "lauxlib.h"
#if __cplusplus
}
#endif // #if __cplusplus
#endif // #if ENABLE_LUA_BINDING


NS_SANGUO_MOBILE_GAME_BEGIN

extern int register_sgNet_luabinding(lua_State *L);

NS_SANGUO_MOBILE_GAME_END //namespace


#endif //_H_NETLUA_H_  