
#include "tolua_fix.h"

#include "NetLua.h"
#include "NetManager.h"


NS_SANGUO_MOBILE_GAME_BEGIN;

static int c_setup_login_server(lua_State *L)
{
    size_t len;
    const char* cstr = lua_tolstring(L, 1, &len);
    std::string ip(cstr, len);
    int port = lua_tointeger(L,2);

    CCLOG("c_setup_login_server  [ ip:%s,port:%d]",ip.c_str(),port);
    NetManager::Instance()->setupLoginServer(ip,port);

    return 0;
}

static int c_setup_game_server(lua_State *L)
{
    size_t len;
    const char* cstr = lua_tolstring(L, 1, &len);
    std::string ip(cstr, len);
    int port = lua_tointeger(L,2);

    CCLOG("c_setup_game_server [ ip:%s,port:%d]",ip.c_str(),port);
    NetManager::Instance()->setupGameServer(ip,port);

    return 0;
}


static int c_send_req(lua_State *L)
{
    size_t len;
    const UserReqEnum req = (UserReqEnum)lua_tointeger(L,1);
    const int msgId = lua_tointeger(L,2);
    const char* cstr = lua_tolstring(L, 3, &len);
    PtrUserReq net_req = PtrUserReq(new UserReq(req, msgId, cstr, len));
    NetManager::Instance()->appendUserReq(net_req);
    
    return 0;
}

static int c_pick_notify(lua_State *L)
{
    NetNotify* notify = NetManager::Instance()->pickNotify();
    if(notify)
    {
        lua_pushnumber(L,notify->_notify);
        lua_pushnumber(L,notify->_msgId);
        lua_pushlstring(L,notify->_data.c_str(), notify->_data.size());

        delete notify;
        
        return 3;
    }
    
    return 0;
}

extern int register_sgNet_luabinding(lua_State *L)
{
/*
    lua_register(L, "c_send_req", c_send_req);
    lua_register(L, "c_pick_notify", c_pick_notify);
    lua_register(L, "c_setup_login_server", c_setup_login_server);  
    lua_register(L, "c_setup_game_server", c_setup_game_server);      
    */

    lua_getglobal(L, "_G");
    if (lua_istable(L,-1))//stack:...,_G,
    {       
        tolua_function(L, "c_send_req", c_send_req);
        tolua_function(L, "c_pick_notify", c_pick_notify);
        tolua_function(L, "c_setup_login_server", c_setup_login_server);
        tolua_function(L, "c_setup_game_server", c_setup_game_server);
    }
    lua_pop(L, 1);
    
    return 1;


}

NS_SANGUO_MOBILE_GAME_END; //namespace

