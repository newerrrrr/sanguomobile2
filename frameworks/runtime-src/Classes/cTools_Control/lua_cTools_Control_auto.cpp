#include "lua_cTools_Control_auto.hpp"
#include "cTools_Control.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"


int lua_cTools_Control_LHSTmxBaseLayer_getTmxLayerType(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxBaseLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxBaseLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxBaseLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxBaseLayer_getTmxLayerType'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxBaseLayer_getTmxLayerType'", nullptr);
            return 0;
        }
        int ret = (int)cobj->getTmxLayerType();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxBaseLayer:getTmxLayerType",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxBaseLayer_getTmxLayerType'.",&tolua_err);
#endif

    return 0;
}
static int lua_cTools_Control_LHSTmxBaseLayer_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTmxBaseLayer)");
    return 0;
}

int lua_register_cTools_Control_LHSTmxBaseLayer(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTmxBaseLayer");
    tolua_cclass(tolua_S,"LHSTmxBaseLayer","LHSTmxBaseLayer","",nullptr);

    tolua_beginmodule(tolua_S,"LHSTmxBaseLayer");
        tolua_function(tolua_S,"getTmxLayerType",lua_cTools_Control_LHSTmxBaseLayer_getTmxLayerType);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTmxBaseLayer).name();
    g_luaType[typeName] = "LHSTmxBaseLayer";
    g_typeCast["LHSTmxBaseLayer"] = "LHSTmxBaseLayer";
    return 1;
}

int lua_cTools_Control_LHSParallelogram_getL(lua_State* tolua_S)
{
    int argc = 0;
    LHSParallelogram* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSParallelogram",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSParallelogram*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSParallelogram_getL'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSParallelogram_getL'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getL();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSParallelogram:getL",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSParallelogram_getL'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSParallelogram_containsPoint(lua_State* tolua_S)
{
    int argc = 0;
    LHSParallelogram* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSParallelogram",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSParallelogram*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSParallelogram_containsPoint'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSParallelogram:containsPoint");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSParallelogram_containsPoint'", nullptr);
            return 0;
        }
        bool ret = cobj->containsPoint(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSParallelogram:containsPoint",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSParallelogram_containsPoint'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSParallelogram_getT(lua_State* tolua_S)
{
    int argc = 0;
    LHSParallelogram* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSParallelogram",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSParallelogram*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSParallelogram_getT'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSParallelogram_getT'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getT();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSParallelogram:getT",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSParallelogram_getT'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSParallelogram_getB(lua_State* tolua_S)
{
    int argc = 0;
    LHSParallelogram* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSParallelogram",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSParallelogram*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSParallelogram_getB'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSParallelogram_getB'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getB();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSParallelogram:getB",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSParallelogram_getB'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSParallelogram_getR(lua_State* tolua_S)
{
    int argc = 0;
    LHSParallelogram* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSParallelogram",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSParallelogram*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSParallelogram_getR'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSParallelogram_getR'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getR();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSParallelogram:getR",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSParallelogram_getR'.",&tolua_err);
#endif

    return 0;
}
static int lua_cTools_Control_LHSParallelogram_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSParallelogram)");
    return 0;
}

int lua_register_cTools_Control_LHSParallelogram(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSParallelogram");
    tolua_cclass(tolua_S,"LHSParallelogram","LHSParallelogram","",nullptr);

    tolua_beginmodule(tolua_S,"LHSParallelogram");
        tolua_function(tolua_S,"getL",lua_cTools_Control_LHSParallelogram_getL);
        tolua_function(tolua_S,"containsPoint",lua_cTools_Control_LHSParallelogram_containsPoint);
        tolua_function(tolua_S,"getT",lua_cTools_Control_LHSParallelogram_getT);
        tolua_function(tolua_S,"getB",lua_cTools_Control_LHSParallelogram_getB);
        tolua_function(tolua_S,"getR",lua_cTools_Control_LHSParallelogram_getR);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSParallelogram).name();
    g_luaType[typeName] = "LHSParallelogram";
    g_typeCast["LHSParallelogram"] = "LHSParallelogram";
    return 1;
}

int lua_cTools_Control_LHSTileData_getIndex(lua_State* tolua_S)
{
    int argc = 0;
    LHSTileData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTileData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTileData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTileData_getIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTileData_getIndex'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getIndex();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTileData:getIndex",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTileData_getIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTileData_getCustomName(lua_State* tolua_S)
{
    int argc = 0;
    LHSTileData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTileData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTileData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTileData_getCustomName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTileData_getCustomName'", nullptr);
            return 0;
        }
        const char* ret = cobj->getCustomName();
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTileData:getCustomName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTileData_getCustomName'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTileData_getEditGid(lua_State* tolua_S)
{
    int argc = 0;
    LHSTileData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTileData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTileData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTileData_getEditGid'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTileData_getEditGid'", nullptr);
            return 0;
        }
        int ret = cobj->getEditGid();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTileData:getEditGid",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTileData_getEditGid'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTileData_getShowNode(lua_State* tolua_S)
{
    int argc = 0;
    LHSTileData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTileData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTileData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTileData_getShowNode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTileData_getShowNode'", nullptr);
            return 0;
        }
        cocos2d::Node* ret = cobj->getShowNode();
        object_to_luaval<cocos2d::Node>(tolua_S, "cc.Node",(cocos2d::Node*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTileData:getShowNode",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTileData_getShowNode'.",&tolua_err);
#endif

    return 0;
}
static int lua_cTools_Control_LHSTileData_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTileData)");
    return 0;
}

int lua_register_cTools_Control_LHSTileData(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTileData");
    tolua_cclass(tolua_S,"LHSTileData","LHSTileData","",nullptr);

    tolua_beginmodule(tolua_S,"LHSTileData");
        tolua_function(tolua_S,"getIndex",lua_cTools_Control_LHSTileData_getIndex);
        tolua_function(tolua_S,"getCustomName",lua_cTools_Control_LHSTileData_getCustomName);
        tolua_function(tolua_S,"getEditGid",lua_cTools_Control_LHSTileData_getEditGid);
        tolua_function(tolua_S,"getShowNode",lua_cTools_Control_LHSTileData_getShowNode);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTileData).name();
    g_luaType[typeName] = "LHSTileData";
    g_typeCast["LHSTileData"] = "LHSTileData";
    return 1;
}

int lua_cTools_Control_MapScrollView_setIsFullScreenTouch(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_setIsFullScreenTouch'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "MapScrollView:setIsFullScreenTouch");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_setIsFullScreenTouch'", nullptr);
            return 0;
        }
        cobj->setIsFullScreenTouch(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:setIsFullScreenTouch",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_setIsFullScreenTouch'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_performedAnimatedScroll_2(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_performedAnimatedScroll_2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "MapScrollView:performedAnimatedScroll_2");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_performedAnimatedScroll_2'", nullptr);
            return 0;
        }
        cobj->performedAnimatedScroll_2(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:performedAnimatedScroll_2",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_performedAnimatedScroll_2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_openParallelogramClamp(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_openParallelogramClamp'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 4) 
    {
        cocos2d::Vec2 arg0;
        cocos2d::Vec2 arg1;
        cocos2d::Vec2 arg2;
        cocos2d::Vec2 arg3;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "MapScrollView:openParallelogramClamp");

        ok &= luaval_to_vec2(tolua_S, 3, &arg1, "MapScrollView:openParallelogramClamp");

        ok &= luaval_to_vec2(tolua_S, 4, &arg2, "MapScrollView:openParallelogramClamp");

        ok &= luaval_to_vec2(tolua_S, 5, &arg3, "MapScrollView:openParallelogramClamp");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_openParallelogramClamp'", nullptr);
            return 0;
        }
        cobj->openParallelogramClamp(arg0, arg1, arg2, arg3);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:openParallelogramClamp",argc, 4);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_openParallelogramClamp'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_closeParallelogramClamp(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_closeParallelogramClamp'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_closeParallelogramClamp'", nullptr);
            return 0;
        }
        cobj->closeParallelogramClamp();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:closeParallelogramClamp",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_closeParallelogramClamp'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_setCanZoomScale(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_setCanZoomScale'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "MapScrollView:setCanZoomScale");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_setCanZoomScale'", nullptr);
            return 0;
        }
        cobj->setCanZoomScale(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:setCanZoomScale",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_setCanZoomScale'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_unregisterScriptBoundaryHandler(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_unregisterScriptBoundaryHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_unregisterScriptBoundaryHandler'", nullptr);
            return 0;
        }
        cobj->unregisterScriptBoundaryHandler();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:unregisterScriptBoundaryHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_unregisterScriptBoundaryHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_stoppedAnimatedScroll_2(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_stoppedAnimatedScroll_2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Node* arg0;

        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "MapScrollView:stoppedAnimatedScroll_2");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_stoppedAnimatedScroll_2'", nullptr);
            return 0;
        }
        cobj->stoppedAnimatedScroll_2(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:stoppedAnimatedScroll_2",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_stoppedAnimatedScroll_2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_setContentOffsetInDuration_EaseExponentialOut(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_setContentOffsetInDuration_EaseExponentialOut'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        cocos2d::Vec2 arg0;
        double arg1;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "MapScrollView:setContentOffsetInDuration_EaseExponentialOut");

        ok &= luaval_to_number(tolua_S, 3,&arg1, "MapScrollView:setContentOffsetInDuration_EaseExponentialOut");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_setContentOffsetInDuration_EaseExponentialOut'", nullptr);
            return 0;
        }
        cobj->setContentOffsetInDuration_EaseExponentialOut(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:setContentOffsetInDuration_EaseExponentialOut",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_setContentOffsetInDuration_EaseExponentialOut'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_registerScriptBoundaryHandler(lua_State* tolua_S)
{
    int argc = 0;
    MapScrollView* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MapScrollView*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_MapScrollView_registerScriptBoundaryHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "MapScrollView:registerScriptBoundaryHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_MapScrollView_registerScriptBoundaryHandler'", nullptr);
            return 0;
        }
        cobj->registerScriptBoundaryHandler(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MapScrollView:registerScriptBoundaryHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_registerScriptBoundaryHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_MapScrollView_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"MapScrollView",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 0)
        {
            MapScrollView* ret = MapScrollView::create();
            object_to_luaval<MapScrollView>(tolua_S, "MapScrollView",(MapScrollView*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 1)
        {
            cocos2d::Size arg0;
            ok &= luaval_to_size(tolua_S, 2, &arg0, "MapScrollView:create");
            if (!ok) { break; }
            MapScrollView* ret = MapScrollView::create(arg0);
            object_to_luaval<MapScrollView>(tolua_S, "MapScrollView",(MapScrollView*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 2)
        {
            cocos2d::Size arg0;
            ok &= luaval_to_size(tolua_S, 2, &arg0, "MapScrollView:create");
            if (!ok) { break; }
            cocos2d::Node* arg1;
            ok &= luaval_to_object<cocos2d::Node>(tolua_S, 3, "cc.Node",&arg1, "MapScrollView:create");
            if (!ok) { break; }
            MapScrollView* ret = MapScrollView::create(arg0, arg1);
            object_to_luaval<MapScrollView>(tolua_S, "MapScrollView",(MapScrollView*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "MapScrollView:create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollView_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_MapScrollView_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MapScrollView)");
    return 0;
}

int lua_register_cTools_Control_MapScrollView(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"MapScrollView");
    tolua_cclass(tolua_S,"MapScrollView","MapScrollView","cc.ScrollView",nullptr);

    tolua_beginmodule(tolua_S,"MapScrollView");
        tolua_function(tolua_S,"setIsFullScreenTouch",lua_cTools_Control_MapScrollView_setIsFullScreenTouch);
        tolua_function(tolua_S,"performedAnimatedScroll_2",lua_cTools_Control_MapScrollView_performedAnimatedScroll_2);
        tolua_function(tolua_S,"openParallelogramClamp",lua_cTools_Control_MapScrollView_openParallelogramClamp);
        tolua_function(tolua_S,"closeParallelogramClamp",lua_cTools_Control_MapScrollView_closeParallelogramClamp);
        tolua_function(tolua_S,"setCanZoomScale",lua_cTools_Control_MapScrollView_setCanZoomScale);
        tolua_function(tolua_S,"unregisterScriptBoundaryHandler",lua_cTools_Control_MapScrollView_unregisterScriptBoundaryHandler);
        tolua_function(tolua_S,"stoppedAnimatedScroll_2",lua_cTools_Control_MapScrollView_stoppedAnimatedScroll_2);
        tolua_function(tolua_S,"setContentOffsetInDuration_EaseExponentialOut",lua_cTools_Control_MapScrollView_setContentOffsetInDuration_EaseExponentialOut);
        tolua_function(tolua_S,"registerScriptBoundaryHandler",lua_cTools_Control_MapScrollView_registerScriptBoundaryHandler);
        tolua_function(tolua_S,"create", lua_cTools_Control_MapScrollView_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(MapScrollView).name();
    g_luaType[typeName] = "MapScrollView";
    g_typeCast["MapScrollView"] = "MapScrollView";
    return 1;
}

int lua_cTools_Control_MapScrollViewPerspective_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"MapScrollViewPerspective",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 0)
        {
            MapScrollViewPerspective* ret = MapScrollViewPerspective::create();
            object_to_luaval<MapScrollViewPerspective>(tolua_S, "MapScrollViewPerspective",(MapScrollViewPerspective*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 1)
        {
            cocos2d::Size arg0;
            ok &= luaval_to_size(tolua_S, 2, &arg0, "MapScrollViewPerspective:create");
            if (!ok) { break; }
            MapScrollViewPerspective* ret = MapScrollViewPerspective::create(arg0);
            object_to_luaval<MapScrollViewPerspective>(tolua_S, "MapScrollViewPerspective",(MapScrollViewPerspective*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 2)
        {
            cocos2d::Size arg0;
            ok &= luaval_to_size(tolua_S, 2, &arg0, "MapScrollViewPerspective:create");
            if (!ok) { break; }
            cocos2d::Node* arg1;
            ok &= luaval_to_object<cocos2d::Node>(tolua_S, 3, "cc.Node",&arg1, "MapScrollViewPerspective:create");
            if (!ok) { break; }
            MapScrollViewPerspective* ret = MapScrollViewPerspective::create(arg0, arg1);
            object_to_luaval<MapScrollViewPerspective>(tolua_S, "MapScrollViewPerspective",(MapScrollViewPerspective*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "MapScrollViewPerspective:create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_MapScrollViewPerspective_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_MapScrollViewPerspective_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MapScrollViewPerspective)");
    return 0;
}

int lua_register_cTools_Control_MapScrollViewPerspective(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"MapScrollViewPerspective");
    tolua_cclass(tolua_S,"MapScrollViewPerspective","MapScrollViewPerspective","MapScrollView",nullptr);

    tolua_beginmodule(tolua_S,"MapScrollViewPerspective");
        tolua_function(tolua_S,"create", lua_cTools_Control_MapScrollViewPerspective_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(MapScrollViewPerspective).name();
    g_luaType[typeName] = "MapScrollViewPerspective";
    g_typeCast["MapScrollViewPerspective"] = "MapScrollViewPerspective";
    return 1;
}

int lua_cTools_Control_LHSTmxData_getTileWidth(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxData_getTileWidth'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxData_getTileWidth'", nullptr);
            return 0;
        }
        int ret = cobj->getTileWidth();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxData:getTileWidth",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxData_getTileWidth'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxData_getLayerProperty_layerName(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxData_getLayerProperty_layerName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        std::string arg0;
        std::string arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "LHSTmxData:getLayerProperty_layerName");

        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "LHSTmxData:getLayerProperty_layerName");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxData_getLayerProperty_layerName'", nullptr);
            return 0;
        }
        std::string ret = cobj->getLayerProperty_layerName(arg0, arg1);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxData:getLayerProperty_layerName",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxData_getLayerProperty_layerName'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxData_getTileHeight(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxData_getTileHeight'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxData_getTileHeight'", nullptr);
            return 0;
        }
        int ret = cobj->getTileHeight();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxData:getTileHeight",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxData_getTileHeight'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxData_getHeight(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxData_getHeight'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxData_getHeight'", nullptr);
            return 0;
        }
        int ret = cobj->getHeight();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxData:getHeight",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxData_getHeight'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxData_getWidth(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxData_getWidth'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxData_getWidth'", nullptr);
            return 0;
        }
        int ret = cobj->getWidth();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxData:getWidth",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxData_getWidth'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxData_getSpriteFrame_globalGid(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxData_getSpriteFrame_globalGid'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSTmxData:getSpriteFrame_globalGid");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxData_getSpriteFrame_globalGid'", nullptr);
            return 0;
        }
        cocos2d::SpriteFrame* ret = cobj->getSpriteFrame_globalGid(arg0);
        object_to_luaval<cocos2d::SpriteFrame>(tolua_S, "cc.SpriteFrame",(cocos2d::SpriteFrame*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxData:getSpriteFrame_globalGid",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxData_getSpriteFrame_globalGid'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxData_getTileProperty_globalGid(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxData_getTileProperty_globalGid'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        std::string arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSTmxData:getTileProperty_globalGid");

        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "LHSTmxData:getTileProperty_globalGid");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxData_getTileProperty_globalGid'", nullptr);
            return 0;
        }
        std::string ret = cobj->getTileProperty_globalGid(arg0, arg1);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxData:getTileProperty_globalGid",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxData_getTileProperty_globalGid'.",&tolua_err);
#endif

    return 0;
}
static int lua_cTools_Control_LHSTmxData_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTmxData)");
    return 0;
}

int lua_register_cTools_Control_LHSTmxData(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTmxData");
    tolua_cclass(tolua_S,"LHSTmxData","LHSTmxData","",nullptr);

    tolua_beginmodule(tolua_S,"LHSTmxData");
        tolua_function(tolua_S,"getTileWidth",lua_cTools_Control_LHSTmxData_getTileWidth);
        tolua_function(tolua_S,"getLayerProperty_layerName",lua_cTools_Control_LHSTmxData_getLayerProperty_layerName);
        tolua_function(tolua_S,"getTileHeight",lua_cTools_Control_LHSTmxData_getTileHeight);
        tolua_function(tolua_S,"getHeight",lua_cTools_Control_LHSTmxData_getHeight);
        tolua_function(tolua_S,"getWidth",lua_cTools_Control_LHSTmxData_getWidth);
        tolua_function(tolua_S,"getSpriteFrame_globalGid",lua_cTools_Control_LHSTmxData_getSpriteFrame_globalGid);
        tolua_function(tolua_S,"getTileProperty_globalGid",lua_cTools_Control_LHSTmxData_getTileProperty_globalGid);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTmxData).name();
    g_luaType[typeName] = "LHSTmxData";
    g_typeCast["LHSTmxData"] = "LHSTmxData";
    return 1;
}

int lua_cTools_Control_LHSTmxCache_removeTmxFileWithName(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxCache* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxCache",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxCache*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxCache_removeTmxFileWithName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSTmxCache:removeTmxFileWithName"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxCache_removeTmxFileWithName'", nullptr);
            return 0;
        }
        cobj->removeTmxFileWithName(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxCache:removeTmxFileWithName",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxCache_removeTmxFileWithName'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxCache_loadTmxFile(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxCache* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxCache",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxCache*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxCache_loadTmxFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSTmxCache:loadTmxFile"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxCache_loadTmxFile'", nullptr);
            return 0;
        }
        LHSTmxData* ret = cobj->loadTmxFile(arg0);
        object_to_luaval<LHSTmxData>(tolua_S, "LHSTmxData",(LHSTmxData*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxCache:loadTmxFile",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxCache_loadTmxFile'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxCache_removeAllTmxFile(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxCache* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxCache",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxCache*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxCache_removeAllTmxFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxCache_removeAllTmxFile'", nullptr);
            return 0;
        }
        cobj->removeAllTmxFile();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxCache:removeAllTmxFile",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxCache_removeAllTmxFile'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxCache_destroyInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTmxCache",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxCache_destroyInstance'", nullptr);
            return 0;
        }
        LHSTmxCache::destroyInstance();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTmxCache:destroyInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxCache_destroyInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSTmxCache_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTmxCache",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxCache_getInstance'", nullptr);
            return 0;
        }
        LHSTmxCache* ret = LHSTmxCache::getInstance();
        object_to_luaval<LHSTmxCache>(tolua_S, "LHSTmxCache",(LHSTmxCache*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTmxCache:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxCache_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSTmxCache_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTmxCache)");
    return 0;
}

int lua_register_cTools_Control_LHSTmxCache(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTmxCache");
    tolua_cclass(tolua_S,"LHSTmxCache","LHSTmxCache","",nullptr);

    tolua_beginmodule(tolua_S,"LHSTmxCache");
        tolua_function(tolua_S,"removeTmxFileWithName",lua_cTools_Control_LHSTmxCache_removeTmxFileWithName);
        tolua_function(tolua_S,"loadTmxFile",lua_cTools_Control_LHSTmxCache_loadTmxFile);
        tolua_function(tolua_S,"removeAllTmxFile",lua_cTools_Control_LHSTmxCache_removeAllTmxFile);
        tolua_function(tolua_S,"destroyInstance", lua_cTools_Control_LHSTmxCache_destroyInstance);
        tolua_function(tolua_S,"getInstance", lua_cTools_Control_LHSTmxCache_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTmxCache).name();
    g_luaType[typeName] = "LHSTmxCache";
    g_typeCast["LHSTmxCache"] = "LHSTmxCache";
    return 1;
}

int lua_cTools_Control_LHSTmxImageLayer_setVisibleOperat(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxImageLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxImageLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxImageLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxImageLayer_setVisibleOperat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSTmxImageLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxImageLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2) 
    {
        bool arg0;
        cocos2d::Size arg1;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSTmxImageLayer:setVisibleOperat");

        ok &= luaval_to_size(tolua_S, 3, &arg1, "LHSTmxImageLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxImageLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxImageLayer:setVisibleOperat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxImageLayer_setVisibleOperat'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxImageLayer_getTmxLayerType(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxImageLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxImageLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxImageLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxImageLayer_getTmxLayerType'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxImageLayer_getTmxLayerType'", nullptr);
            return 0;
        }
        int ret = (int)cobj->getTmxLayerType();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxImageLayer:getTmxLayerType",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxImageLayer_getTmxLayerType'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxImageLayer_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTmxImageLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxImageLayer_create'", nullptr);
            return 0;
        }
        LHSTmxImageLayer* ret = LHSTmxImageLayer::create();
        object_to_luaval<LHSTmxImageLayer>(tolua_S, "LHSTmxImageLayer",(LHSTmxImageLayer*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTmxImageLayer:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxImageLayer_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSTmxImageLayer_createWithTexture(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTmxImageLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Texture2D* arg0;
        ok &= luaval_to_object<cocos2d::Texture2D>(tolua_S, 2, "cc.Texture2D",&arg0, "LHSTmxImageLayer:createWithTexture");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxImageLayer_createWithTexture'", nullptr);
            return 0;
        }
        LHSTmxImageLayer* ret = LHSTmxImageLayer::createWithTexture(arg0);
        object_to_luaval<LHSTmxImageLayer>(tolua_S, "LHSTmxImageLayer",(LHSTmxImageLayer*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTmxImageLayer:createWithTexture",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxImageLayer_createWithTexture'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSTmxImageLayer_constructor(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxImageLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxImageLayer_constructor'", nullptr);
            return 0;
        }
        cobj = new LHSTmxImageLayer();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"LHSTmxImageLayer");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxImageLayer:LHSTmxImageLayer",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxImageLayer_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_cTools_Control_LHSTmxImageLayer_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTmxImageLayer)");
    return 0;
}

int lua_register_cTools_Control_LHSTmxImageLayer(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTmxImageLayer");
    tolua_cclass(tolua_S,"LHSTmxImageLayer","LHSTmxImageLayer","cc.Sprite",nullptr);

    tolua_beginmodule(tolua_S,"LHSTmxImageLayer");
        tolua_function(tolua_S,"new",lua_cTools_Control_LHSTmxImageLayer_constructor);
        tolua_function(tolua_S,"setVisibleOperat",lua_cTools_Control_LHSTmxImageLayer_setVisibleOperat);
        tolua_function(tolua_S,"getTmxLayerType",lua_cTools_Control_LHSTmxImageLayer_getTmxLayerType);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSTmxImageLayer_create);
        tolua_function(tolua_S,"createWithTexture", lua_cTools_Control_LHSTmxImageLayer_createWithTexture);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTmxImageLayer).name();
    g_luaType[typeName] = "LHSTmxImageLayer";
    g_typeCast["LHSTmxImageLayer"] = "LHSTmxImageLayer";
    return 1;
}

int lua_cTools_Control_LHSTmxTileLayer_getTileWidth(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getTileWidth'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getTileWidth'", nullptr);
            return 0;
        }
        int ret = cobj->getTileWidth();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getTileWidth",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getTileWidth'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getIndexWithNodePosition_Rough(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getIndexWithNodePosition_Rough'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getIndexWithNodePosition_Rough");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getIndexWithNodePosition_Rough'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getIndexWithNodePosition_Rough(arg0);
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getIndexWithNodePosition_Rough",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getIndexWithNodePosition_Rough'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_addEditTile(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_addEditTile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 4) 
    {
        cocos2d::Node* arg0;
        int arg1;
        int arg2;
        int arg3;

        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "LHSTmxTileLayer:addEditTile");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "LHSTmxTileLayer:addEditTile");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "LHSTmxTileLayer:addEditTile");

        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "LHSTmxTileLayer:addEditTile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_addEditTile'", nullptr);
            return 0;
        }
        cobj->addEditTile(arg0, arg1, arg2, arg3);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:addEditTile",argc, 4);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_addEditTile'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getTileHeight(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getTileHeight'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getTileHeight'", nullptr);
            return 0;
        }
        int ret = cobj->getTileHeight();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getTileHeight",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getTileHeight'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getTileDataWithNodePosition(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getTileDataWithNodePosition'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getTileDataWithNodePosition");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getTileDataWithNodePosition'", nullptr);
            return 0;
        }
        LHSTileData* ret = cobj->getTileDataWithNodePosition(arg0);
        object_to_luaval<LHSTileData>(tolua_S, "LHSTileData",(LHSTileData*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getTileDataWithNodePosition",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getTileDataWithNodePosition'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_setVisibleOperat(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_setVisibleOperat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSTmxTileLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2) 
    {
        bool arg0;
        cocos2d::Size arg1;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSTmxTileLayer:setVisibleOperat");

        ok &= luaval_to_size(tolua_S, 3, &arg1, "LHSTmxTileLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:setVisibleOperat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_setVisibleOperat'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getTileDataWithIndex(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getTileDataWithIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getTileDataWithIndex");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getTileDataWithIndex'", nullptr);
            return 0;
        }
        LHSTileData* ret = cobj->getTileDataWithIndex(arg0);
        object_to_luaval<LHSTileData>(tolua_S, "LHSTileData",(LHSTileData*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getTileDataWithIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getTileDataWithIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getHeight(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getHeight'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getHeight'", nullptr);
            return 0;
        }
        int ret = cobj->getHeight();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getHeight",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getHeight'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getNodePositionWithIndex(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getNodePositionWithIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getNodePositionWithIndex");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getNodePositionWithIndex'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getNodePositionWithIndex(arg0);
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getNodePositionWithIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getNodePositionWithIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getZOrderWithIndex(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getZOrderWithIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getZOrderWithIndex");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getZOrderWithIndex'", nullptr);
            return 0;
        }
        int ret = cobj->getZOrderWithIndex(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getZOrderWithIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getZOrderWithIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getTmxLayerType(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getTmxLayerType'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getTmxLayerType'", nullptr);
            return 0;
        }
        int ret = (int)cobj->getTmxLayerType();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getTmxLayerType",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getTmxLayerType'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_removeTile(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_removeTile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        int arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSTmxTileLayer:removeTile");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "LHSTmxTileLayer:removeTile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_removeTile'", nullptr);
            return 0;
        }
        cobj->removeTile(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 3) 
    {
        int arg0;
        int arg1;
        bool arg2;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSTmxTileLayer:removeTile");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "LHSTmxTileLayer:removeTile");

        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "LHSTmxTileLayer:removeTile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_removeTile'", nullptr);
            return 0;
        }
        cobj->removeTile(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:removeTile",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_removeTile'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getWidth(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getWidth'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getWidth'", nullptr);
            return 0;
        }
        int ret = cobj->getWidth();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getWidth",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getWidth'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_addCustomTile(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_addCustomTile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 5) 
    {
        cocos2d::Node* arg0;
        int arg1;
        int arg2;
        int arg3;
        const char* arg4;

        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "LHSTmxTileLayer:addCustomTile");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "LHSTmxTileLayer:addCustomTile");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "LHSTmxTileLayer:addCustomTile");

        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "LHSTmxTileLayer:addCustomTile");

        std::string arg4_tmp; ok &= luaval_to_std_string(tolua_S, 6, &arg4_tmp, "LHSTmxTileLayer:addCustomTile"); arg4 = arg4_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_addCustomTile'", nullptr);
            return 0;
        }
        cobj->addCustomTile(arg0, arg1, arg2, arg3, arg4);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:addCustomTile",argc, 5);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_addCustomTile'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getCustomTileCountWithCustomName(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getCustomTileCountWithCustomName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSTmxTileLayer:getCustomTileCountWithCustomName"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getCustomTileCountWithCustomName'", nullptr);
            return 0;
        }
        int ret = cobj->getCustomTileCountWithCustomName(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getCustomTileCountWithCustomName",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getCustomTileCountWithCustomName'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getNodePositionCenterWithIndex(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getNodePositionCenterWithIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getNodePositionCenterWithIndex");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getNodePositionCenterWithIndex'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = cobj->getNodePositionCenterWithIndex(arg0);
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getNodePositionCenterWithIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getNodePositionCenterWithIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getParallelogram(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getParallelogram'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getParallelogram'", nullptr);
            return 0;
        }
        const LHSParallelogram* ret = cobj->getParallelogram();
        object_to_luaval<LHSParallelogram>(tolua_S, "LHSParallelogram",(LHSParallelogram*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getParallelogram",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getParallelogram'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getGidWithIndex(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getGidWithIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getGidWithIndex");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getGidWithIndex'", nullptr);
            return 0;
        }
        int ret = cobj->getGidWithIndex(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getGidWithIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getGidWithIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_removeAllTile(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_removeAllTile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_removeAllTile'", nullptr);
            return 0;
        }
        cobj->removeAllTile();
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSTmxTileLayer:removeAllTile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_removeAllTile'", nullptr);
            return 0;
        }
        cobj->removeAllTile(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:removeAllTile",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_removeAllTile'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_removeTileWithCustomName(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_removeTileWithCustomName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSTmxTileLayer:removeTileWithCustomName"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_removeTileWithCustomName'", nullptr);
            return 0;
        }
        cobj->removeTileWithCustomName(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2) 
    {
        const char* arg0;
        bool arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSTmxTileLayer:removeTileWithCustomName"); arg0 = arg0_tmp.c_str();

        ok &= luaval_to_boolean(tolua_S, 3,&arg1, "LHSTmxTileLayer:removeTileWithCustomName");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_removeTileWithCustomName'", nullptr);
            return 0;
        }
        cobj->removeTileWithCustomName(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:removeTileWithCustomName",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_removeTileWithCustomName'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_getGidWithNodePosition(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxTileLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxTileLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxTileLayer_getGidWithNodePosition'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Vec2 arg0;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "LHSTmxTileLayer:getGidWithNodePosition");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_getGidWithNodePosition'", nullptr);
            return 0;
        }
        int ret = cobj->getGidWithNodePosition(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxTileLayer:getGidWithNodePosition",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_getGidWithNodePosition'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxTileLayer_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTmxTileLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        int arg0;
        int arg1;
        int arg2;
        int arg3;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSTmxTileLayer:create");
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "LHSTmxTileLayer:create");
        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "LHSTmxTileLayer:create");
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "LHSTmxTileLayer:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxTileLayer_create'", nullptr);
            return 0;
        }
        LHSTmxTileLayer* ret = LHSTmxTileLayer::create(arg0, arg1, arg2, arg3);
        object_to_luaval<LHSTmxTileLayer>(tolua_S, "LHSTmxTileLayer",(LHSTmxTileLayer*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTmxTileLayer:create",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxTileLayer_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSTmxTileLayer_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTmxTileLayer)");
    return 0;
}

int lua_register_cTools_Control_LHSTmxTileLayer(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTmxTileLayer");
    tolua_cclass(tolua_S,"LHSTmxTileLayer","LHSTmxTileLayer","cc.Layer",nullptr);

    tolua_beginmodule(tolua_S,"LHSTmxTileLayer");
        tolua_function(tolua_S,"getTileWidth",lua_cTools_Control_LHSTmxTileLayer_getTileWidth);
        tolua_function(tolua_S,"getIndexWithNodePosition_Rough",lua_cTools_Control_LHSTmxTileLayer_getIndexWithNodePosition_Rough);
        tolua_function(tolua_S,"addEditTile",lua_cTools_Control_LHSTmxTileLayer_addEditTile);
        tolua_function(tolua_S,"getTileHeight",lua_cTools_Control_LHSTmxTileLayer_getTileHeight);
        tolua_function(tolua_S,"getTileDataWithNodePosition",lua_cTools_Control_LHSTmxTileLayer_getTileDataWithNodePosition);
        tolua_function(tolua_S,"setVisibleOperat",lua_cTools_Control_LHSTmxTileLayer_setVisibleOperat);
        tolua_function(tolua_S,"getTileDataWithIndex",lua_cTools_Control_LHSTmxTileLayer_getTileDataWithIndex);
        tolua_function(tolua_S,"getHeight",lua_cTools_Control_LHSTmxTileLayer_getHeight);
        tolua_function(tolua_S,"getNodePositionWithIndex",lua_cTools_Control_LHSTmxTileLayer_getNodePositionWithIndex);
        tolua_function(tolua_S,"getZOrderWithIndex",lua_cTools_Control_LHSTmxTileLayer_getZOrderWithIndex);
        tolua_function(tolua_S,"getTmxLayerType",lua_cTools_Control_LHSTmxTileLayer_getTmxLayerType);
        tolua_function(tolua_S,"removeTile",lua_cTools_Control_LHSTmxTileLayer_removeTile);
        tolua_function(tolua_S,"getWidth",lua_cTools_Control_LHSTmxTileLayer_getWidth);
        tolua_function(tolua_S,"addCustomTile",lua_cTools_Control_LHSTmxTileLayer_addCustomTile);
        tolua_function(tolua_S,"getCustomTileCountWithCustomName",lua_cTools_Control_LHSTmxTileLayer_getCustomTileCountWithCustomName);
        tolua_function(tolua_S,"getNodePositionCenterWithIndex",lua_cTools_Control_LHSTmxTileLayer_getNodePositionCenterWithIndex);
        tolua_function(tolua_S,"getParallelogram",lua_cTools_Control_LHSTmxTileLayer_getParallelogram);
        tolua_function(tolua_S,"getGidWithIndex",lua_cTools_Control_LHSTmxTileLayer_getGidWithIndex);
        tolua_function(tolua_S,"removeAllTile",lua_cTools_Control_LHSTmxTileLayer_removeAllTile);
        tolua_function(tolua_S,"removeTileWithCustomName",lua_cTools_Control_LHSTmxTileLayer_removeTileWithCustomName);
        tolua_function(tolua_S,"getGidWithNodePosition",lua_cTools_Control_LHSTmxTileLayer_getGidWithNodePosition);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSTmxTileLayer_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTmxTileLayer).name();
    g_luaType[typeName] = "LHSTmxTileLayer";
    g_typeCast["LHSTmxTileLayer"] = "LHSTmxTileLayer";
    return 1;
}

int lua_cTools_Control_LHSTmxLayer_getTileWidth(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxLayer_getTileWidth'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_getTileWidth'", nullptr);
            return 0;
        }
        int ret = cobj->getTileWidth();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxLayer:getTileWidth",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_getTileWidth'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxLayer_setVisibleOperat(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxLayer_setVisibleOperat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSTmxLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2) 
    {
        bool arg0;
        cocos2d::Size arg1;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSTmxLayer:setVisibleOperat");

        ok &= luaval_to_size(tolua_S, 3, &arg1, "LHSTmxLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxLayer:setVisibleOperat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_setVisibleOperat'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxLayer_getHeight(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxLayer_getHeight'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_getHeight'", nullptr);
            return 0;
        }
        int ret = cobj->getHeight();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxLayer:getHeight",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_getHeight'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxLayer_getTileHeight(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxLayer_getTileHeight'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_getTileHeight'", nullptr);
            return 0;
        }
        int ret = cobj->getTileHeight();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxLayer:getTileHeight",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_getTileHeight'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxLayer_getWidth(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxLayer_getWidth'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_getWidth'", nullptr);
            return 0;
        }
        int ret = cobj->getWidth();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxLayer:getWidth",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_getWidth'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxLayer_getParallelogram(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSTmxLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSTmxLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSTmxLayer_getParallelogram'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_getParallelogram'", nullptr);
            return 0;
        }
        const LHSParallelogram* ret = cobj->getParallelogram();
        object_to_luaval<LHSParallelogram>(tolua_S, "LHSParallelogram",(LHSParallelogram*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxLayer:getParallelogram",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_getParallelogram'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSTmxLayer_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTmxLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSTmxLayer:create"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_create'", nullptr);
            return 0;
        }
        LHSTmxLayer* ret = LHSTmxLayer::create(arg0);
        object_to_luaval<LHSTmxLayer>(tolua_S, "LHSTmxLayer",(LHSTmxLayer*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTmxLayer:create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSTmxLayer_constructor(lua_State* tolua_S)
{
    int argc = 0;
    LHSTmxLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSTmxLayer:LHSTmxLayer"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTmxLayer_constructor'", nullptr);
            return 0;
        }
        cobj = new LHSTmxLayer(arg0);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"LHSTmxLayer");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSTmxLayer:LHSTmxLayer",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTmxLayer_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_cTools_Control_LHSTmxLayer_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTmxLayer)");
    return 0;
}

int lua_register_cTools_Control_LHSTmxLayer(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTmxLayer");
    tolua_cclass(tolua_S,"LHSTmxLayer","LHSTmxLayer","cc.Layer",nullptr);

    tolua_beginmodule(tolua_S,"LHSTmxLayer");
        tolua_function(tolua_S,"new",lua_cTools_Control_LHSTmxLayer_constructor);
        tolua_function(tolua_S,"getTileWidth",lua_cTools_Control_LHSTmxLayer_getTileWidth);
        tolua_function(tolua_S,"setVisibleOperat",lua_cTools_Control_LHSTmxLayer_setVisibleOperat);
        tolua_function(tolua_S,"getHeight",lua_cTools_Control_LHSTmxLayer_getHeight);
        tolua_function(tolua_S,"getTileHeight",lua_cTools_Control_LHSTmxLayer_getTileHeight);
        tolua_function(tolua_S,"getWidth",lua_cTools_Control_LHSTmxLayer_getWidth);
        tolua_function(tolua_S,"getParallelogram",lua_cTools_Control_LHSTmxLayer_getParallelogram);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSTmxLayer_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTmxLayer).name();
    g_luaType[typeName] = "LHSTmxLayer";
    g_typeCast["LHSTmxLayer"] = "LHSTmxLayer";
    return 1;
}

int lua_cTools_Control_LHSArmatureAnimation_registerScriptFrameHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSArmatureAnimation* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSArmatureAnimation",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSArmatureAnimation*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSArmatureAnimation_registerScriptFrameHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSArmatureAnimation:registerScriptFrameHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSArmatureAnimation_registerScriptFrameHandler'", nullptr);
            return 0;
        }
        cobj->registerScriptFrameHandler(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSArmatureAnimation:registerScriptFrameHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSArmatureAnimation_registerScriptFrameHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSArmatureAnimation_unregisterScriptMovementHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSArmatureAnimation* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSArmatureAnimation",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSArmatureAnimation*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSArmatureAnimation_unregisterScriptMovementHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSArmatureAnimation_unregisterScriptMovementHandler'", nullptr);
            return 0;
        }
        cobj->unregisterScriptMovementHandler();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSArmatureAnimation:unregisterScriptMovementHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSArmatureAnimation_unregisterScriptMovementHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSArmatureAnimation_unregisterScriptFrameHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSArmatureAnimation* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSArmatureAnimation",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSArmatureAnimation*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSArmatureAnimation_unregisterScriptFrameHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSArmatureAnimation_unregisterScriptFrameHandler'", nullptr);
            return 0;
        }
        cobj->unregisterScriptFrameHandler();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSArmatureAnimation:unregisterScriptFrameHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSArmatureAnimation_unregisterScriptFrameHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSArmatureAnimation_registerScriptMovementHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSArmatureAnimation* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSArmatureAnimation",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSArmatureAnimation*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSArmatureAnimation_registerScriptMovementHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSArmatureAnimation:registerScriptMovementHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSArmatureAnimation_registerScriptMovementHandler'", nullptr);
            return 0;
        }
        cobj->registerScriptMovementHandler(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSArmatureAnimation:registerScriptMovementHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSArmatureAnimation_registerScriptMovementHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSArmatureAnimation_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSArmatureAnimation",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocostudio::Armature* arg0;
        ok &= luaval_to_object<cocostudio::Armature>(tolua_S, 2, "ccs.Armature",&arg0, "LHSArmatureAnimation:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSArmatureAnimation_create'", nullptr);
            return 0;
        }
        LHSArmatureAnimation* ret = LHSArmatureAnimation::create(arg0);
        object_to_luaval<LHSArmatureAnimation>(tolua_S, "LHSArmatureAnimation",(LHSArmatureAnimation*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSArmatureAnimation:create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSArmatureAnimation_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSArmatureAnimation_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSArmatureAnimation)");
    return 0;
}

int lua_register_cTools_Control_LHSArmatureAnimation(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSArmatureAnimation");
    tolua_cclass(tolua_S,"LHSArmatureAnimation","LHSArmatureAnimation","ccs.ArmatureAnimation",nullptr);

    tolua_beginmodule(tolua_S,"LHSArmatureAnimation");
        tolua_function(tolua_S,"registerScriptFrameHandler",lua_cTools_Control_LHSArmatureAnimation_registerScriptFrameHandler);
        tolua_function(tolua_S,"unregisterScriptMovementHandler",lua_cTools_Control_LHSArmatureAnimation_unregisterScriptMovementHandler);
        tolua_function(tolua_S,"unregisterScriptFrameHandler",lua_cTools_Control_LHSArmatureAnimation_unregisterScriptFrameHandler);
        tolua_function(tolua_S,"registerScriptMovementHandler",lua_cTools_Control_LHSArmatureAnimation_registerScriptMovementHandler);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSArmatureAnimation_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSArmatureAnimation).name();
    g_luaType[typeName] = "LHSArmatureAnimation";
    g_typeCast["LHSArmatureAnimation"] = "LHSArmatureAnimation";
    return 1;
}

int lua_cTools_Control_LHSArmature_getLHSAnimation(lua_State* tolua_S)
{
    int argc = 0;
    LHSArmature* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSArmature",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSArmature*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSArmature_getLHSAnimation'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSArmature_getLHSAnimation'", nullptr);
            return 0;
        }
        LHSArmatureAnimation* ret = cobj->getLHSAnimation();
        object_to_luaval<LHSArmatureAnimation>(tolua_S, "LHSArmatureAnimation",(LHSArmatureAnimation*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSArmature:getLHSAnimation",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSArmature_getLHSAnimation'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSArmature_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSArmature",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 1)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0, "LHSArmature:create");
            if (!ok) { break; }
            LHSArmature* ret = LHSArmature::create(arg0);
            object_to_luaval<LHSArmature>(tolua_S, "LHSArmature",(LHSArmature*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 0)
        {
            LHSArmature* ret = LHSArmature::create();
            object_to_luaval<LHSArmature>(tolua_S, "LHSArmature",(LHSArmature*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 2)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0, "LHSArmature:create");
            if (!ok) { break; }
            cocostudio::Bone* arg1;
            ok &= luaval_to_object<cocostudio::Bone>(tolua_S, 3, "ccs.Bone",&arg1, "LHSArmature:create");
            if (!ok) { break; }
            LHSArmature* ret = LHSArmature::create(arg0, arg1);
            object_to_luaval<LHSArmature>(tolua_S, "LHSArmature",(LHSArmature*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "LHSArmature:create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSArmature_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSArmature_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSArmature)");
    return 0;
}

int lua_register_cTools_Control_LHSArmature(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSArmature");
    tolua_cclass(tolua_S,"LHSArmature","LHSArmature","ccs.Armature",nullptr);

    tolua_beginmodule(tolua_S,"LHSArmature");
        tolua_function(tolua_S,"getLHSAnimation",lua_cTools_Control_LHSArmature_getLHSAnimation);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSArmature_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSArmature).name();
    g_luaType[typeName] = "LHSArmature";
    g_typeCast["LHSArmature"] = "LHSArmature";
    return 1;
}

int lua_cTools_Control_LHSRenderTextureToScreen_initWithRenderTexture(lua_State* tolua_S)
{
    int argc = 0;
    LHSRenderTextureToScreen* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSRenderTextureToScreen",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSRenderTextureToScreen*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSRenderTextureToScreen_initWithRenderTexture'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::RenderTexture* arg0;

        ok &= luaval_to_object<cocos2d::RenderTexture>(tolua_S, 2, "cc.RenderTexture",&arg0, "LHSRenderTextureToScreen:initWithRenderTexture");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSRenderTextureToScreen_initWithRenderTexture'", nullptr);
            return 0;
        }
        bool ret = cobj->initWithRenderTexture(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSRenderTextureToScreen:initWithRenderTexture",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSRenderTextureToScreen_initWithRenderTexture'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSRenderTextureToScreen_setFlippedY(lua_State* tolua_S)
{
    int argc = 0;
    LHSRenderTextureToScreen* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSRenderTextureToScreen",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSRenderTextureToScreen*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSRenderTextureToScreen_setFlippedY'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSRenderTextureToScreen:setFlippedY");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSRenderTextureToScreen_setFlippedY'", nullptr);
            return 0;
        }
        cobj->setFlippedY(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSRenderTextureToScreen:setFlippedY",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSRenderTextureToScreen_setFlippedY'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSRenderTextureToScreen_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSRenderTextureToScreen",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::RenderTexture* arg0;
        ok &= luaval_to_object<cocos2d::RenderTexture>(tolua_S, 2, "cc.RenderTexture",&arg0, "LHSRenderTextureToScreen:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSRenderTextureToScreen_create'", nullptr);
            return 0;
        }
        LHSRenderTextureToScreen* ret = LHSRenderTextureToScreen::create(arg0);
        object_to_luaval<LHSRenderTextureToScreen>(tolua_S, "LHSRenderTextureToScreen",(LHSRenderTextureToScreen*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSRenderTextureToScreen:create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSRenderTextureToScreen_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSRenderTextureToScreen_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSRenderTextureToScreen)");
    return 0;
}

int lua_register_cTools_Control_LHSRenderTextureToScreen(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSRenderTextureToScreen");
    tolua_cclass(tolua_S,"LHSRenderTextureToScreen","LHSRenderTextureToScreen","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"LHSRenderTextureToScreen");
        tolua_function(tolua_S,"initWithRenderTexture",lua_cTools_Control_LHSRenderTextureToScreen_initWithRenderTexture);
        tolua_function(tolua_S,"setFlippedY",lua_cTools_Control_LHSRenderTextureToScreen_setFlippedY);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSRenderTextureToScreen_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSRenderTextureToScreen).name();
    g_luaType[typeName] = "LHSRenderTextureToScreen";
    g_typeCast["LHSRenderTextureToScreen"] = "LHSRenderTextureToScreen";
    return 1;
}

int lua_cTools_Control_LHSRenderTextureToScreenToLua_unregisterScriptDrawHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSRenderTextureToScreenToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSRenderTextureToScreenToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSRenderTextureToScreenToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_unregisterScriptDrawHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_unregisterScriptDrawHandler'", nullptr);
            return 0;
        }
        cobj->unregisterScriptDrawHandler();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSRenderTextureToScreenToLua:unregisterScriptDrawHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_unregisterScriptDrawHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSRenderTextureToScreenToLua_registerScriptDrawHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSRenderTextureToScreenToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSRenderTextureToScreenToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSRenderTextureToScreenToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_registerScriptDrawHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSRenderTextureToScreenToLua:registerScriptDrawHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_registerScriptDrawHandler'", nullptr);
            return 0;
        }
        cobj->registerScriptDrawHandler(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSRenderTextureToScreenToLua:registerScriptDrawHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_registerScriptDrawHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSRenderTextureToScreenToLua_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSRenderTextureToScreenToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::RenderTexture* arg0;
        ok &= luaval_to_object<cocos2d::RenderTexture>(tolua_S, 2, "cc.RenderTexture",&arg0, "LHSRenderTextureToScreenToLua:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_create'", nullptr);
            return 0;
        }
        LHSRenderTextureToScreenToLua* ret = LHSRenderTextureToScreenToLua::create(arg0);
        object_to_luaval<LHSRenderTextureToScreenToLua>(tolua_S, "LHSRenderTextureToScreenToLua",(LHSRenderTextureToScreenToLua*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSRenderTextureToScreenToLua:create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSRenderTextureToScreenToLua_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSRenderTextureToScreenToLua_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSRenderTextureToScreenToLua)");
    return 0;
}

int lua_register_cTools_Control_LHSRenderTextureToScreenToLua(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSRenderTextureToScreenToLua");
    tolua_cclass(tolua_S,"LHSRenderTextureToScreenToLua","LHSRenderTextureToScreenToLua","LHSRenderTextureToScreen",nullptr);

    tolua_beginmodule(tolua_S,"LHSRenderTextureToScreenToLua");
        tolua_function(tolua_S,"unregisterScriptDrawHandler",lua_cTools_Control_LHSRenderTextureToScreenToLua_unregisterScriptDrawHandler);
        tolua_function(tolua_S,"registerScriptDrawHandler",lua_cTools_Control_LHSRenderTextureToScreenToLua_registerScriptDrawHandler);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSRenderTextureToScreenToLua_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSRenderTextureToScreenToLua).name();
    g_luaType[typeName] = "LHSRenderTextureToScreenToLua";
    g_typeCast["LHSRenderTextureToScreenToLua"] = "LHSRenderTextureToScreenToLua";
    return 1;
}

int lua_cTools_Control_LHSOutNotVisitNode_setVisibleOperat(lua_State* tolua_S)
{
    int argc = 0;
    LHSOutNotVisitNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSOutNotVisitNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSOutNotVisitNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSOutNotVisitNode_setVisibleOperat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSOutNotVisitNode:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSOutNotVisitNode_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2) 
    {
        bool arg0;
        cocos2d::Size arg1;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSOutNotVisitNode:setVisibleOperat");

        ok &= luaval_to_size(tolua_S, 3, &arg1, "LHSOutNotVisitNode:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSOutNotVisitNode_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSOutNotVisitNode:setVisibleOperat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSOutNotVisitNode_setVisibleOperat'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSOutNotVisitNode_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSOutNotVisitNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSOutNotVisitNode_create'", nullptr);
            return 0;
        }
        LHSOutNotVisitNode* ret = LHSOutNotVisitNode::create();
        object_to_luaval<LHSOutNotVisitNode>(tolua_S, "LHSOutNotVisitNode",(LHSOutNotVisitNode*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSOutNotVisitNode:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSOutNotVisitNode_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSOutNotVisitNode_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSOutNotVisitNode)");
    return 0;
}

int lua_register_cTools_Control_LHSOutNotVisitNode(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSOutNotVisitNode");
    tolua_cclass(tolua_S,"LHSOutNotVisitNode","LHSOutNotVisitNode","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"LHSOutNotVisitNode");
        tolua_function(tolua_S,"setVisibleOperat",lua_cTools_Control_LHSOutNotVisitNode_setVisibleOperat);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSOutNotVisitNode_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSOutNotVisitNode).name();
    g_luaType[typeName] = "LHSOutNotVisitNode";
    g_typeCast["LHSOutNotVisitNode"] = "LHSOutNotVisitNode";
    return 1;
}

int lua_cTools_Control_LHSOutNotVisitLayer_setVisibleOperat(lua_State* tolua_S)
{
    int argc = 0;
    LHSOutNotVisitLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSOutNotVisitLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSOutNotVisitLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSOutNotVisitLayer_setVisibleOperat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSOutNotVisitLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSOutNotVisitLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2) 
    {
        bool arg0;
        cocos2d::Size arg1;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSOutNotVisitLayer:setVisibleOperat");

        ok &= luaval_to_size(tolua_S, 3, &arg1, "LHSOutNotVisitLayer:setVisibleOperat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSOutNotVisitLayer_setVisibleOperat'", nullptr);
            return 0;
        }
        cobj->setVisibleOperat(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSOutNotVisitLayer:setVisibleOperat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSOutNotVisitLayer_setVisibleOperat'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSOutNotVisitLayer_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSOutNotVisitLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSOutNotVisitLayer_create'", nullptr);
            return 0;
        }
        LHSOutNotVisitLayer* ret = LHSOutNotVisitLayer::create();
        object_to_luaval<LHSOutNotVisitLayer>(tolua_S, "LHSOutNotVisitLayer",(LHSOutNotVisitLayer*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSOutNotVisitLayer:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSOutNotVisitLayer_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSOutNotVisitLayer_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSOutNotVisitLayer)");
    return 0;
}

int lua_register_cTools_Control_LHSOutNotVisitLayer(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSOutNotVisitLayer");
    tolua_cclass(tolua_S,"LHSOutNotVisitLayer","LHSOutNotVisitLayer","cc.Layer",nullptr);

    tolua_beginmodule(tolua_S,"LHSOutNotVisitLayer");
        tolua_function(tolua_S,"setVisibleOperat",lua_cTools_Control_LHSOutNotVisitLayer_setVisibleOperat);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSOutNotVisitLayer_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSOutNotVisitLayer).name();
    g_luaType[typeName] = "LHSOutNotVisitLayer";
    g_typeCast["LHSOutNotVisitLayer"] = "LHSOutNotVisitLayer";
    return 1;
}

int lua_cTools_Control_LHSManualVisitNode_setManualVisible(lua_State* tolua_S)
{
    int argc = 0;
    LHSManualVisitNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSManualVisitNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSManualVisitNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSManualVisitNode_setManualVisible'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSManualVisitNode:setManualVisible");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSManualVisitNode_setManualVisible'", nullptr);
            return 0;
        }
        cobj->setManualVisible(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSManualVisitNode:setManualVisible",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSManualVisitNode_setManualVisible'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSManualVisitNode_isManualVisible(lua_State* tolua_S)
{
    int argc = 0;
    LHSManualVisitNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSManualVisitNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSManualVisitNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSManualVisitNode_isManualVisible'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSManualVisitNode_isManualVisible'", nullptr);
            return 0;
        }
        bool ret = cobj->isManualVisible();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSManualVisitNode:isManualVisible",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSManualVisitNode_isManualVisible'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSManualVisitNode_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSManualVisitNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSManualVisitNode_create'", nullptr);
            return 0;
        }
        LHSManualVisitNode* ret = LHSManualVisitNode::create();
        object_to_luaval<LHSManualVisitNode>(tolua_S, "LHSManualVisitNode",(LHSManualVisitNode*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSManualVisitNode:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSManualVisitNode_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSManualVisitNode_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSManualVisitNode)");
    return 0;
}

int lua_register_cTools_Control_LHSManualVisitNode(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSManualVisitNode");
    tolua_cclass(tolua_S,"LHSManualVisitNode","LHSManualVisitNode","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"LHSManualVisitNode");
        tolua_function(tolua_S,"setManualVisible",lua_cTools_Control_LHSManualVisitNode_setManualVisible);
        tolua_function(tolua_S,"isManualVisible",lua_cTools_Control_LHSManualVisitNode_isManualVisible);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSManualVisitNode_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSManualVisitNode).name();
    g_luaType[typeName] = "LHSManualVisitNode";
    g_typeCast["LHSManualVisitNode"] = "LHSManualVisitNode";
    return 1;
}

int lua_cTools_Control_LHSManualVisitLayer_setManualVisible(lua_State* tolua_S)
{
    int argc = 0;
    LHSManualVisitLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSManualVisitLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSManualVisitLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSManualVisitLayer_setManualVisible'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "LHSManualVisitLayer:setManualVisible");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSManualVisitLayer_setManualVisible'", nullptr);
            return 0;
        }
        cobj->setManualVisible(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSManualVisitLayer:setManualVisible",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSManualVisitLayer_setManualVisible'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSManualVisitLayer_isManualVisible(lua_State* tolua_S)
{
    int argc = 0;
    LHSManualVisitLayer* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSManualVisitLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSManualVisitLayer*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSManualVisitLayer_isManualVisible'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSManualVisitLayer_isManualVisible'", nullptr);
            return 0;
        }
        bool ret = cobj->isManualVisible();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSManualVisitLayer:isManualVisible",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSManualVisitLayer_isManualVisible'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSManualVisitLayer_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSManualVisitLayer",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSManualVisitLayer_create'", nullptr);
            return 0;
        }
        LHSManualVisitLayer* ret = LHSManualVisitLayer::create();
        object_to_luaval<LHSManualVisitLayer>(tolua_S, "LHSManualVisitLayer",(LHSManualVisitLayer*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSManualVisitLayer:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSManualVisitLayer_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSManualVisitLayer_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSManualVisitLayer)");
    return 0;
}

int lua_register_cTools_Control_LHSManualVisitLayer(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSManualVisitLayer");
    tolua_cclass(tolua_S,"LHSManualVisitLayer","LHSManualVisitLayer","cc.Layer",nullptr);

    tolua_beginmodule(tolua_S,"LHSManualVisitLayer");
        tolua_function(tolua_S,"setManualVisible",lua_cTools_Control_LHSManualVisitLayer_setManualVisible);
        tolua_function(tolua_S,"isManualVisible",lua_cTools_Control_LHSManualVisitLayer_isManualVisible);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSManualVisitLayer_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSManualVisitLayer).name();
    g_luaType[typeName] = "LHSManualVisitLayer";
    g_typeCast["LHSManualVisitLayer"] = "LHSManualVisitLayer";
    return 1;
}

int lua_cTools_Control_LHSTools_checkTouchInSelf(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTools",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        cocos2d::Node* arg0;
        cocos2d::Touch* arg1;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "LHSTools:checkTouchInSelf");
        ok &= luaval_to_object<cocos2d::Touch>(tolua_S, 3, "cc.Touch",&arg1, "LHSTools:checkTouchInSelf");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTools_checkTouchInSelf'", nullptr);
            return 0;
        }
        bool ret = LHSTools::checkTouchInSelf(arg0, arg1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTools:checkTouchInSelf",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTools_checkTouchInSelf'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSTools_checkInSceneOrder(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTools",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Node* arg0;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "LHSTools:checkInSceneOrder");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTools_checkInSceneOrder'", nullptr);
            return 0;
        }
        bool ret = LHSTools::checkInSceneOrder(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTools:checkInSceneOrder",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTools_checkInSceneOrder'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSTools_checkAncestorsVisible(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTools",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Node* arg0;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "LHSTools:checkAncestorsVisible");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTools_checkAncestorsVisible'", nullptr);
            return 0;
        }
        bool ret = LHSTools::checkAncestorsVisible(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTools:checkAncestorsVisible",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTools_checkAncestorsVisible'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSTools_checkTouchInSelf_3D(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSTools",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        cocos2d::Node* arg0;
        cocos2d::Touch* arg1;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "LHSTools:checkTouchInSelf_3D");
        ok &= luaval_to_object<cocos2d::Touch>(tolua_S, 3, "cc.Touch",&arg1, "LHSTools:checkTouchInSelf_3D");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSTools_checkTouchInSelf_3D'", nullptr);
            return 0;
        }
        bool ret = LHSTools::checkTouchInSelf_3D(arg0, arg1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSTools:checkTouchInSelf_3D",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSTools_checkTouchInSelf_3D'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSTools_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSTools)");
    return 0;
}

int lua_register_cTools_Control_LHSTools(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSTools");
    tolua_cclass(tolua_S,"LHSTools","LHSTools","",nullptr);

    tolua_beginmodule(tolua_S,"LHSTools");
        tolua_function(tolua_S,"checkTouchInSelf", lua_cTools_Control_LHSTools_checkTouchInSelf);
        tolua_function(tolua_S,"checkInSceneOrder", lua_cTools_Control_LHSTools_checkInSceneOrder);
        tolua_function(tolua_S,"checkAncestorsVisible", lua_cTools_Control_LHSTools_checkAncestorsVisible);
        tolua_function(tolua_S,"checkTouchInSelf_3D", lua_cTools_Control_LHSTools_checkTouchInSelf_3D);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSTools).name();
    g_luaType[typeName] = "LHSTools";
    g_typeCast["LHSTools"] = "LHSTools";
    return 1;
}

int lua_cTools_Control_LHSAnimationReturn_GetTotalTime(lua_State* tolua_S)
{
    int argc = 0;
    LHSAnimationReturn* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSAnimationReturn",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSAnimationReturn*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSAnimationReturn_GetTotalTime'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimationReturn_GetTotalTime'", nullptr);
            return 0;
        }
        double ret = cobj->GetTotalTime();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSAnimationReturn:GetTotalTime",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSAnimationReturn_GetTotalTime'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSAnimationReturn_GetFps(lua_State* tolua_S)
{
    int argc = 0;
    LHSAnimationReturn* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSAnimationReturn",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSAnimationReturn*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSAnimationReturn_GetFps'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimationReturn_GetFps'", nullptr);
            return 0;
        }
        double ret = cobj->GetFps();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSAnimationReturn:GetFps",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSAnimationReturn_GetFps'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSAnimationReturn_GetTotalFrameNum(lua_State* tolua_S)
{
    int argc = 0;
    LHSAnimationReturn* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSAnimationReturn",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSAnimationReturn*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSAnimationReturn_GetTotalFrameNum'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimationReturn_GetTotalFrameNum'", nullptr);
            return 0;
        }
        int ret = cobj->GetTotalFrameNum();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSAnimationReturn:GetTotalFrameNum",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSAnimationReturn_GetTotalFrameNum'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSAnimationReturn_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSAnimationReturn",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimationReturn_create'", nullptr);
            return 0;
        }
        LHSAnimationReturn* ret = LHSAnimationReturn::create();
        object_to_luaval<LHSAnimationReturn>(tolua_S, "LHSAnimationReturn",(LHSAnimationReturn*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSAnimationReturn:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSAnimationReturn_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSAnimationReturn_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSAnimationReturn)");
    return 0;
}

int lua_register_cTools_Control_LHSAnimationReturn(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSAnimationReturn");
    tolua_cclass(tolua_S,"LHSAnimationReturn","LHSAnimationReturn","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"LHSAnimationReturn");
        tolua_function(tolua_S,"GetTotalTime",lua_cTools_Control_LHSAnimationReturn_GetTotalTime);
        tolua_function(tolua_S,"GetFps",lua_cTools_Control_LHSAnimationReturn_GetFps);
        tolua_function(tolua_S,"GetTotalFrameNum",lua_cTools_Control_LHSAnimationReturn_GetTotalFrameNum);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSAnimationReturn_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSAnimationReturn).name();
    g_luaType[typeName] = "LHSAnimationReturn";
    g_typeCast["LHSAnimationReturn"] = "LHSAnimationReturn";
    return 1;
}

int lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSAnimation",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSAnimation:createFrameAnimationWithIdOrder"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder'", nullptr);
            return 0;
        }
        cocos2d::Animate* ret = LHSAnimation::createFrameAnimationWithIdOrder(arg0);
        object_to_luaval<cocos2d::Animate>(tolua_S, "cc.Animate",(cocos2d::Animate*)ret);
        return 1;
    }
    if (argc == 2)
    {
        const char* arg0;
        double arg1;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSAnimation:createFrameAnimationWithIdOrder"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_number(tolua_S, 3,&arg1, "LHSAnimation:createFrameAnimationWithIdOrder");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder'", nullptr);
            return 0;
        }
        cocos2d::Animate* ret = LHSAnimation::createFrameAnimationWithIdOrder(arg0, arg1);
        object_to_luaval<cocos2d::Animate>(tolua_S, "cc.Animate",(cocos2d::Animate*)ret);
        return 1;
    }
    if (argc == 3)
    {
        const char* arg0;
        double arg1;
        bool arg2;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSAnimation:createFrameAnimationWithIdOrder"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_number(tolua_S, 3,&arg1, "LHSAnimation:createFrameAnimationWithIdOrder");
        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "LHSAnimation:createFrameAnimationWithIdOrder");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder'", nullptr);
            return 0;
        }
        cocos2d::Animate* ret = LHSAnimation::createFrameAnimationWithIdOrder(arg0, arg1, arg2);
        object_to_luaval<cocos2d::Animate>(tolua_S, "cc.Animate",(cocos2d::Animate*)ret);
        return 1;
    }
    if (argc == 4)
    {
        const char* arg0;
        double arg1;
        bool arg2;
        LHSAnimationReturn* arg3;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSAnimation:createFrameAnimationWithIdOrder"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_number(tolua_S, 3,&arg1, "LHSAnimation:createFrameAnimationWithIdOrder");
        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "LHSAnimation:createFrameAnimationWithIdOrder");
        ok &= luaval_to_object<LHSAnimationReturn>(tolua_S, 5, "LHSAnimationReturn",&arg3, "LHSAnimation:createFrameAnimationWithIdOrder");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder'", nullptr);
            return 0;
        }
        cocos2d::Animate* ret = LHSAnimation::createFrameAnimationWithIdOrder(arg0, arg1, arg2, arg3);
        object_to_luaval<cocos2d::Animate>(tolua_S, "cc.Animate",(cocos2d::Animate*)ret);
        return 1;
    }
    if (argc == 5)
    {
        const char* arg0;
        double arg1;
        bool arg2;
        LHSAnimationReturn* arg3;
        int arg4;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "LHSAnimation:createFrameAnimationWithIdOrder"); arg0 = arg0_tmp.c_str();
        ok &= luaval_to_number(tolua_S, 3,&arg1, "LHSAnimation:createFrameAnimationWithIdOrder");
        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "LHSAnimation:createFrameAnimationWithIdOrder");
        ok &= luaval_to_object<LHSAnimationReturn>(tolua_S, 5, "LHSAnimationReturn",&arg3, "LHSAnimation:createFrameAnimationWithIdOrder");
        ok &= luaval_to_int32(tolua_S, 6,(int *)&arg4, "LHSAnimation:createFrameAnimationWithIdOrder");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder'", nullptr);
            return 0;
        }
        cocos2d::Animate* ret = LHSAnimation::createFrameAnimationWithIdOrder(arg0, arg1, arg2, arg3, arg4);
        object_to_luaval<cocos2d::Animate>(tolua_S, "cc.Animate",(cocos2d::Animate*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSAnimation:createFrameAnimationWithIdOrder",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSAnimation_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSAnimation)");
    return 0;
}

int lua_register_cTools_Control_LHSAnimation(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSAnimation");
    tolua_cclass(tolua_S,"LHSAnimation","LHSAnimation","",nullptr);

    tolua_beginmodule(tolua_S,"LHSAnimation");
        tolua_function(tolua_S,"createFrameAnimationWithIdOrder", lua_cTools_Control_LHSAnimation_createFrameAnimationWithIdOrder);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSAnimation).name();
    g_luaType[typeName] = "LHSAnimation";
    g_typeCast["LHSAnimation"] = "LHSAnimation";
    return 1;
}

int lua_cTools_Control_LHSCustomShaderSprite_registerScriptBeforeDrawHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSCustomShaderSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSCustomShaderSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSCustomShaderSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSCustomShaderSprite_registerScriptBeforeDrawHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSCustomShaderSprite:registerScriptBeforeDrawHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSCustomShaderSprite_registerScriptBeforeDrawHandler'", nullptr);
            return 0;
        }
        cobj->registerScriptBeforeDrawHandler(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSCustomShaderSprite:registerScriptBeforeDrawHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSCustomShaderSprite_registerScriptBeforeDrawHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSCustomShaderSprite_unregisterScriptBeforeDrawHandler(lua_State* tolua_S)
{
    int argc = 0;
    LHSCustomShaderSprite* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSCustomShaderSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSCustomShaderSprite*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSCustomShaderSprite_unregisterScriptBeforeDrawHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSCustomShaderSprite_unregisterScriptBeforeDrawHandler'", nullptr);
            return 0;
        }
        cobj->unregisterScriptBeforeDrawHandler();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSCustomShaderSprite:unregisterScriptBeforeDrawHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSCustomShaderSprite_unregisterScriptBeforeDrawHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSCustomShaderSprite_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSCustomShaderSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 1)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0, "LHSCustomShaderSprite:create");
            if (!ok) { break; }
            LHSCustomShaderSprite* ret = LHSCustomShaderSprite::create(arg0);
            object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 0)
        {
            LHSCustomShaderSprite* ret = LHSCustomShaderSprite::create();
            object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 2)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0, "LHSCustomShaderSprite:create");
            if (!ok) { break; }
            cocos2d::Rect arg1;
            ok &= luaval_to_rect(tolua_S, 3, &arg1, "LHSCustomShaderSprite:create");
            if (!ok) { break; }
            LHSCustomShaderSprite* ret = LHSCustomShaderSprite::create(arg0, arg1);
            object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "LHSCustomShaderSprite:create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSCustomShaderSprite_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSCustomShaderSprite_createWithTexture(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSCustomShaderSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 2)
        {
            cocos2d::Texture2D* arg0;
            ok &= luaval_to_object<cocos2d::Texture2D>(tolua_S, 2, "cc.Texture2D",&arg0, "LHSCustomShaderSprite:createWithTexture");
            if (!ok) { break; }
            cocos2d::Rect arg1;
            ok &= luaval_to_rect(tolua_S, 3, &arg1, "LHSCustomShaderSprite:createWithTexture");
            if (!ok) { break; }
            LHSCustomShaderSprite* ret = LHSCustomShaderSprite::createWithTexture(arg0, arg1);
            object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 3)
        {
            cocos2d::Texture2D* arg0;
            ok &= luaval_to_object<cocos2d::Texture2D>(tolua_S, 2, "cc.Texture2D",&arg0, "LHSCustomShaderSprite:createWithTexture");
            if (!ok) { break; }
            cocos2d::Rect arg1;
            ok &= luaval_to_rect(tolua_S, 3, &arg1, "LHSCustomShaderSprite:createWithTexture");
            if (!ok) { break; }
            bool arg2;
            ok &= luaval_to_boolean(tolua_S, 4,&arg2, "LHSCustomShaderSprite:createWithTexture");
            if (!ok) { break; }
            LHSCustomShaderSprite* ret = LHSCustomShaderSprite::createWithTexture(arg0, arg1, arg2);
            object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 1)
        {
            cocos2d::Texture2D* arg0;
            ok &= luaval_to_object<cocos2d::Texture2D>(tolua_S, 2, "cc.Texture2D",&arg0, "LHSCustomShaderSprite:createWithTexture");
            if (!ok) { break; }
            LHSCustomShaderSprite* ret = LHSCustomShaderSprite::createWithTexture(arg0);
            object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "LHSCustomShaderSprite:createWithTexture",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSCustomShaderSprite_createWithTexture'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrameName(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSCustomShaderSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "LHSCustomShaderSprite:createWithSpriteFrameName");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrameName'", nullptr);
            return 0;
        }
        LHSCustomShaderSprite* ret = LHSCustomShaderSprite::createWithSpriteFrameName(arg0);
        object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSCustomShaderSprite:createWithSpriteFrameName",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrameName'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSCustomShaderSprite",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::SpriteFrame* arg0;
        ok &= luaval_to_object<cocos2d::SpriteFrame>(tolua_S, 2, "cc.SpriteFrame",&arg0, "LHSCustomShaderSprite:createWithSpriteFrame");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrame'", nullptr);
            return 0;
        }
        LHSCustomShaderSprite* ret = LHSCustomShaderSprite::createWithSpriteFrame(arg0);
        object_to_luaval<LHSCustomShaderSprite>(tolua_S, "LHSCustomShaderSprite",(LHSCustomShaderSprite*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSCustomShaderSprite:createWithSpriteFrame",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrame'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSCustomShaderSprite_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSCustomShaderSprite)");
    return 0;
}

int lua_register_cTools_Control_LHSCustomShaderSprite(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSCustomShaderSprite");
    tolua_cclass(tolua_S,"LHSCustomShaderSprite","LHSCustomShaderSprite","cc.Sprite",nullptr);

    tolua_beginmodule(tolua_S,"LHSCustomShaderSprite");
        tolua_function(tolua_S,"registerScriptBeforeDrawHandler",lua_cTools_Control_LHSCustomShaderSprite_registerScriptBeforeDrawHandler);
        tolua_function(tolua_S,"unregisterScriptBeforeDrawHandler",lua_cTools_Control_LHSCustomShaderSprite_unregisterScriptBeforeDrawHandler);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSCustomShaderSprite_create);
        tolua_function(tolua_S,"createWithTexture", lua_cTools_Control_LHSCustomShaderSprite_createWithTexture);
        tolua_function(tolua_S,"createWithSpriteFrameName", lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrameName);
        tolua_function(tolua_S,"createWithSpriteFrame", lua_cTools_Control_LHSCustomShaderSprite_createWithSpriteFrame);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSCustomShaderSprite).name();
    g_luaType[typeName] = "LHSCustomShaderSprite";
    g_typeCast["LHSCustomShaderSprite"] = "LHSCustomShaderSprite";
    return 1;
}

int lua_cTools_Control_LHSSchedulerActionManager_pause(lua_State* tolua_S)
{
    int argc = 0;
    LHSSchedulerActionManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSSchedulerActionManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSSchedulerActionManager_pause'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_pause'", nullptr);
            return 0;
        }
        cobj->pause();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSSchedulerActionManager:pause",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_pause'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSSchedulerActionManager_resume(lua_State* tolua_S)
{
    int argc = 0;
    LHSSchedulerActionManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSSchedulerActionManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSSchedulerActionManager_resume'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_resume'", nullptr);
            return 0;
        }
        cobj->resume();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSSchedulerActionManager:resume",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_resume'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSSchedulerActionManager_deleteSchedulerActionManage(lua_State* tolua_S)
{
    int argc = 0;
    LHSSchedulerActionManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSSchedulerActionManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSSchedulerActionManager_deleteSchedulerActionManage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_deleteSchedulerActionManage'", nullptr);
            return 0;
        }
        cobj->deleteSchedulerActionManage();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSSchedulerActionManager:deleteSchedulerActionManage",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_deleteSchedulerActionManage'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSSchedulerActionManager_getScaleTime(lua_State* tolua_S)
{
    int argc = 0;
    LHSSchedulerActionManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSSchedulerActionManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSSchedulerActionManager_getScaleTime'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_getScaleTime'", nullptr);
            return 0;
        }
        double ret = cobj->getScaleTime();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSSchedulerActionManager:getScaleTime",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_getScaleTime'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSSchedulerActionManager_getScheduler(lua_State* tolua_S)
{
    int argc = 0;
    LHSSchedulerActionManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSSchedulerActionManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSSchedulerActionManager_getScheduler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_getScheduler'", nullptr);
            return 0;
        }
        cocos2d::Scheduler* ret = cobj->getScheduler();
        object_to_luaval<cocos2d::Scheduler>(tolua_S, "cc.Scheduler",(cocos2d::Scheduler*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSSchedulerActionManager:getScheduler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_getScheduler'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSSchedulerActionManager_resetNodeSchedulerAndActionManage(lua_State* tolua_S)
{
    int argc = 0;
    LHSSchedulerActionManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSSchedulerActionManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSSchedulerActionManager_resetNodeSchedulerAndActionManage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Node* arg0;

        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "LHSSchedulerActionManager:resetNodeSchedulerAndActionManage");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_resetNodeSchedulerAndActionManage'", nullptr);
            return 0;
        }
        cobj->resetNodeSchedulerAndActionManage(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSSchedulerActionManager:resetNodeSchedulerAndActionManage",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_resetNodeSchedulerAndActionManage'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSSchedulerActionManager_setScaleTime(lua_State* tolua_S)
{
    int argc = 0;
    LHSSchedulerActionManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSSchedulerActionManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSSchedulerActionManager_setScaleTime'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "LHSSchedulerActionManager:setScaleTime");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_setScaleTime'", nullptr);
            return 0;
        }
        cobj->setScaleTime(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSSchedulerActionManager:setScaleTime",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_setScaleTime'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSSchedulerActionManager_newSchedulerActionManage(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSSchedulerActionManager",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSSchedulerActionManager_newSchedulerActionManage'", nullptr);
            return 0;
        }
        LHSSchedulerActionManager* ret = LHSSchedulerActionManager::newSchedulerActionManage();
        object_to_luaval<LHSSchedulerActionManager>(tolua_S, "LHSSchedulerActionManager",(LHSSchedulerActionManager*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSSchedulerActionManager:newSchedulerActionManage",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSSchedulerActionManager_newSchedulerActionManage'.",&tolua_err);
#endif
    return 0;
}
static int lua_cTools_Control_LHSSchedulerActionManager_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSSchedulerActionManager)");
    return 0;
}

int lua_register_cTools_Control_LHSSchedulerActionManager(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSSchedulerActionManager");
    tolua_cclass(tolua_S,"LHSSchedulerActionManager","LHSSchedulerActionManager","",nullptr);

    tolua_beginmodule(tolua_S,"LHSSchedulerActionManager");
        tolua_function(tolua_S,"pause",lua_cTools_Control_LHSSchedulerActionManager_pause);
        tolua_function(tolua_S,"resume",lua_cTools_Control_LHSSchedulerActionManager_resume);
        tolua_function(tolua_S,"deleteSchedulerActionManage",lua_cTools_Control_LHSSchedulerActionManager_deleteSchedulerActionManage);
        tolua_function(tolua_S,"getScaleTime",lua_cTools_Control_LHSSchedulerActionManager_getScaleTime);
        tolua_function(tolua_S,"getScheduler",lua_cTools_Control_LHSSchedulerActionManager_getScheduler);
        tolua_function(tolua_S,"resetNodeSchedulerAndActionManage",lua_cTools_Control_LHSSchedulerActionManager_resetNodeSchedulerAndActionManage);
        tolua_function(tolua_S,"setScaleTime",lua_cTools_Control_LHSSchedulerActionManager_setScaleTime);
        tolua_function(tolua_S,"newSchedulerActionManage", lua_cTools_Control_LHSSchedulerActionManager_newSchedulerActionManage);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSSchedulerActionManager).name();
    g_luaType[typeName] = "LHSSchedulerActionManager";
    g_typeCast["LHSSchedulerActionManager"] = "LHSSchedulerActionManager";
    return 1;
}

int lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLLine2(lua_State* tolua_S)
{
    int argc = 0;
    LHSDrawNodeToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSDrawNodeToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSDrawNodeToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLLine2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSDrawNodeToLua:registerScriptHandler_DrawGLLine2");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLLine2'", nullptr);
            return 0;
        }
        cobj->registerScriptHandler_DrawGLLine2(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSDrawNodeToLua:registerScriptHandler_DrawGLLine2",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLLine2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLLine2(lua_State* tolua_S)
{
    int argc = 0;
    LHSDrawNodeToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSDrawNodeToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSDrawNodeToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLLine2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLLine2'", nullptr);
            return 0;
        }
        cobj->unregisterScriptHandler_DrawGLLine2();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSDrawNodeToLua:unregisterScriptHandler_DrawGLLine2",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLLine2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLPoint2(lua_State* tolua_S)
{
    int argc = 0;
    LHSDrawNodeToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSDrawNodeToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSDrawNodeToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLPoint2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLPoint2'", nullptr);
            return 0;
        }
        cobj->unregisterScriptHandler_DrawGLPoint2();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSDrawNodeToLua:unregisterScriptHandler_DrawGLPoint2",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLPoint2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_Draw2(lua_State* tolua_S)
{
    int argc = 0;
    LHSDrawNodeToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSDrawNodeToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSDrawNodeToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_Draw2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSDrawNodeToLua:registerScriptHandler_Draw2");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_Draw2'", nullptr);
            return 0;
        }
        cobj->registerScriptHandler_Draw2(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSDrawNodeToLua:registerScriptHandler_Draw2",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_Draw2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLPoint2(lua_State* tolua_S)
{
    int argc = 0;
    LHSDrawNodeToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSDrawNodeToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSDrawNodeToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLPoint2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LHSDrawNodeToLua:registerScriptHandler_DrawGLPoint2");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLPoint2'", nullptr);
            return 0;
        }
        cobj->registerScriptHandler_DrawGLPoint2(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSDrawNodeToLua:registerScriptHandler_DrawGLPoint2",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLPoint2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_Draw2(lua_State* tolua_S)
{
    int argc = 0;
    LHSDrawNodeToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LHSDrawNodeToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LHSDrawNodeToLua*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_Draw2'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_Draw2'", nullptr);
            return 0;
        }
        cobj->unregisterScriptHandler_Draw2();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSDrawNodeToLua:unregisterScriptHandler_Draw2",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_Draw2'.",&tolua_err);
#endif

    return 0;
}
int lua_cTools_Control_LHSDrawNodeToLua_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LHSDrawNodeToLua",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_create'", nullptr);
            return 0;
        }
        LHSDrawNodeToLua* ret = LHSDrawNodeToLua::create();
        object_to_luaval<LHSDrawNodeToLua>(tolua_S, "LHSDrawNodeToLua",(LHSDrawNodeToLua*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LHSDrawNodeToLua:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cTools_Control_LHSDrawNodeToLua_constructor(lua_State* tolua_S)
{
    int argc = 0;
    LHSDrawNodeToLua* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cTools_Control_LHSDrawNodeToLua_constructor'", nullptr);
            return 0;
        }
        cobj = new LHSDrawNodeToLua();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"LHSDrawNodeToLua");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LHSDrawNodeToLua:LHSDrawNodeToLua",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_cTools_Control_LHSDrawNodeToLua_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_cTools_Control_LHSDrawNodeToLua_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LHSDrawNodeToLua)");
    return 0;
}

int lua_register_cTools_Control_LHSDrawNodeToLua(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LHSDrawNodeToLua");
    tolua_cclass(tolua_S,"LHSDrawNodeToLua","LHSDrawNodeToLua","cc.DrawNode",nullptr);

    tolua_beginmodule(tolua_S,"LHSDrawNodeToLua");
        tolua_function(tolua_S,"new",lua_cTools_Control_LHSDrawNodeToLua_constructor);
        tolua_function(tolua_S,"registerScriptHandler_DrawGLLine2",lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLLine2);
        tolua_function(tolua_S,"unregisterScriptHandler_DrawGLLine2",lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLLine2);
        tolua_function(tolua_S,"unregisterScriptHandler_DrawGLPoint2",lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_DrawGLPoint2);
        tolua_function(tolua_S,"registerScriptHandler_Draw2",lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_Draw2);
        tolua_function(tolua_S,"registerScriptHandler_DrawGLPoint2",lua_cTools_Control_LHSDrawNodeToLua_registerScriptHandler_DrawGLPoint2);
        tolua_function(tolua_S,"unregisterScriptHandler_Draw2",lua_cTools_Control_LHSDrawNodeToLua_unregisterScriptHandler_Draw2);
        tolua_function(tolua_S,"create", lua_cTools_Control_LHSDrawNodeToLua_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LHSDrawNodeToLua).name();
    g_luaType[typeName] = "LHSDrawNodeToLua";
    g_typeCast["LHSDrawNodeToLua"] = "LHSDrawNodeToLua";
    return 1;
}
TOLUA_API int register_all_cTools_Control(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"lhs",0);
	tolua_beginmodule(tolua_S,"lhs");

	lua_register_cTools_Control_LHSOutNotVisitNode(tolua_S);
	lua_register_cTools_Control_LHSTools(tolua_S);
	lua_register_cTools_Control_LHSRenderTextureToScreen(tolua_S);
	lua_register_cTools_Control_LHSRenderTextureToScreenToLua(tolua_S);
	lua_register_cTools_Control_LHSTileData(tolua_S);
	lua_register_cTools_Control_LHSCustomShaderSprite(tolua_S);
	lua_register_cTools_Control_LHSManualVisitLayer(tolua_S);
	lua_register_cTools_Control_LHSParallelogram(tolua_S);
	lua_register_cTools_Control_LHSDrawNodeToLua(tolua_S);
	lua_register_cTools_Control_LHSTmxCache(tolua_S);
	lua_register_cTools_Control_MapScrollView(tolua_S);
	lua_register_cTools_Control_MapScrollViewPerspective(tolua_S);
	lua_register_cTools_Control_LHSTmxBaseLayer(tolua_S);
	lua_register_cTools_Control_LHSTmxTileLayer(tolua_S);
	lua_register_cTools_Control_LHSTmxData(tolua_S);
	lua_register_cTools_Control_LHSManualVisitNode(tolua_S);
	lua_register_cTools_Control_LHSTmxLayer(tolua_S);
	lua_register_cTools_Control_LHSOutNotVisitLayer(tolua_S);
	lua_register_cTools_Control_LHSSchedulerActionManager(tolua_S);
	lua_register_cTools_Control_LHSAnimationReturn(tolua_S);
	lua_register_cTools_Control_LHSArmature(tolua_S);
	lua_register_cTools_Control_LHSTmxImageLayer(tolua_S);
	lua_register_cTools_Control_LHSAnimation(tolua_S);
	lua_register_cTools_Control_LHSArmatureAnimation(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

