
#include "tolua_fix.h"
#include "cocos2d.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

#include "PSDeviceInfo.h"

USING_NS_CC;


static int lua_PSDeviceInfo_isLocalWiFiAvailable(lua_State* tolua_S)
{
    int argc = 0;
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (0 == argc)
    {
        bool ret = PSDeviceInfo::isLocalWiFiAvailable();
        lua_pushboolean(tolua_S, (bool)ret);
        return 1;
    }
    
    luaL_error(tolua_S, "'isLocalWiFiAvailable has wrong number of arguments: %d, was expecting %d\n", argc, 0);
    return 0;
    
}


static int lua_PSDeviceInfo_isInternetConnectionAvailable(lua_State* tolua_S)
{
    int argc = lua_gettop(tolua_S) - 1;
    
    if (0 == argc)
    {
        bool ret = PSDeviceInfo::isInternetConnectionAvailable();
        lua_pushboolean(tolua_S, (bool)ret);
        return 1;
    }
    
    luaL_error(tolua_S, "'isInternetConnectionAvailable has wrong number of arguments: %d, was expecting %d\n", argc, 0);
    return 0;    
}


static int lua_PSDeviceInfo_getMyUUID(lua_State* tolua_S)
{
    int argc = lua_gettop(tolua_S) - 1;
    
    if (0 == argc)
    {
        std::string uuid = PSDeviceInfo::getMyUUID();
        lua_pushlstring(tolua_S, uuid.c_str(), uuid.size());
        return 1;
    }
    
    luaL_error(tolua_S, "'getMyUUID has wrong number of arguments: %d, was expecting %d\n", argc, 0);
    return 0; 
}

static int lua_PSDeviceInfo_getMD5String(lua_State* tolua_S)
{
    int argc = lua_gettop(tolua_S) - 1;
    
    if (1 == argc)
    {
        size_t len;
        const char* tmp = lua_tolstring(tolua_S, 2, &len);        
         std::string str(tmp, len);
         
        std::string md5 = PSDeviceInfo::getMD5String(str);
        lua_pushlstring(tolua_S, md5.c_str(), md5.size());
        return 1;
    }
    
    luaL_error(tolua_S, "'getMD5String has wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0; 
}


extern int register_PSDeviceInfo_luabinding(lua_State* tolua_S)
{
    tolua_open(tolua_S);
    tolua_usertype(tolua_S, "PSDeviceInfo");
    tolua_module(tolua_S, NULL,0);
    tolua_beginmodule(tolua_S, NULL);
        tolua_cclass(tolua_S,"PSDeviceInfo","PSDeviceInfo","",NULL);
        tolua_beginmodule(tolua_S, "PSDeviceInfo");
            tolua_function(tolua_S, "isLocalWiFiAvailable", lua_PSDeviceInfo_isLocalWiFiAvailable);
            tolua_function(tolua_S, "isInternetConnectionAvailable", lua_PSDeviceInfo_isInternetConnectionAvailable);
            tolua_function(tolua_S, "getMyUUID", lua_PSDeviceInfo_getMyUUID);
            tolua_function(tolua_S, "getMD5String", lua_PSDeviceInfo_getMD5String);
        tolua_endmodule(tolua_S);
    tolua_endmodule(tolua_S);
   return 1; 
}

