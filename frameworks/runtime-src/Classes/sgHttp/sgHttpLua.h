
#ifndef sgHttpLua_H  
#define sgHttpLua_H  

#if __cplusplus
extern "C" {
#endif // #if __cplusplus

#include "lauxlib.h"

#if __cplusplus
}
#endif // #if __cplusplus





extern int register_sgHttp_luabinding(lua_State* tolua_S);



#endif //sgHttpLua_H  
