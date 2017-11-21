
#include "tolua_fix.h"
#include "cocos2d.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"

#include "sgHttpLua.h"
#include "sgHttp.h"

USING_NS_CC;



static int lua_sgHttp_instance(lua_State* tolua_S)
{
    int argc = 0;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertable(tolua_S,1,"sgHttp",0,&tolua_err)) goto tolua_lerror;
#endif
    
    argc = lua_gettop(tolua_S) - 1;
    
    if(0 == argc)
    {
        sgHttp* tolua_ret = (sgHttp*)sgHttp::instance();
        tolua_pushusertype(tolua_S,(void*)tolua_ret,"sgHttp");
        return 1;
    }
    
    luaL_error(tolua_S, "'sgHttp::instance() has wrong number of arguments: %d, was expecting %d\n", argc, 2);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_sgHttp_instance'.",&tolua_err);
    return 0;
#endif
}


static int lua_sgHttp_getData(lua_State *tolua_S)
{
    int argc = 0;
    sgHttp* self = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"sgHttp",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (sgHttp*)  tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(tolua_S,"invalid 'self' in function 'lua_sgHttp_getData'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (2 == argc)
    {
        size_t len;
        const char* url = lua_tolstring(tolua_S, 2, &len);
        LUA_FUNCTION handler = toluafix_ref_function(tolua_S,3,0);
        ScriptHandlerMgr::getInstance()->addCustomHandler((void*)self, handler);
        
        self->getData(url, [=](bool result, std::string &rspData){
                LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
                stack->pushBoolean(result);
                stack->pushString(rspData.c_str(), rspData.size());
                stack->executeFunctionByHandler(handler, 2);
                stack->clean();   
                LuaEngine::getInstance()->removeScriptHandler(handler);
                });
                
        return 1;
    }
    
    luaL_error(tolua_S, "'sgHttp::getData() has wrong number of arguments: %d, was expecting %d\n", argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_sgHttp_getData' ",&tolua_err);
    return 0;
#endif
    
}

static int lua_sgHttp_postData(lua_State *tolua_S)
{
    int argc = 0;
    sgHttp* self = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(tolua_S,1,"sgHttp",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (sgHttp*)  tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(tolua_S,"invalid 'self' in function 'lua_sgHttp_postData'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(tolua_S) - 1;
    
    if (3 == argc)
    {
        size_t len, len2;
        const char* url = lua_tolstring(tolua_S, 2, &len);
        const char* str_data = lua_tolstring(tolua_S, 3, &len2);
        LUA_FUNCTION handler = toluafix_ref_function(tolua_S,4,0);
        ScriptHandlerMgr::getInstance()->addCustomHandler((void*)self, handler);
        
        self->postData(url, str_data, len2, [=](bool result, std::string &rspData){
                LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
                stack->pushBoolean(result);
                stack->pushString(rspData.c_str(), rspData.size());
                stack->executeFunctionByHandler(handler, 2);
                stack->clean();  
                LuaEngine::getInstance()->removeScriptHandler(handler);
                });
        
        return 1;
    }
    
    luaL_error(tolua_S, "'sgHttp::postData() has wrong number of arguments: %d, was expecting %d\n", argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_sgHttp_postData' ",&tolua_err);
    return 0;
#endif
    
}


extern int register_sgHttp_luabinding(lua_State* tolua_S)
{
    tolua_open(tolua_S);
    tolua_usertype(tolua_S, "sgHttp");
    tolua_module(tolua_S, NULL,0);
    tolua_beginmodule(tolua_S, NULL);
        tolua_cclass(tolua_S,"sgHttp","sgHttp","",NULL);
        tolua_beginmodule(tolua_S, "sgHttp");
            tolua_function(tolua_S, "instance", lua_sgHttp_instance);
            tolua_function(tolua_S, "getData", lua_sgHttp_getData);
            tolua_function(tolua_S, "postData", lua_sgHttp_postData);
        tolua_endmodule(tolua_S);
    tolua_endmodule(tolua_S);
   return 1; 
}


