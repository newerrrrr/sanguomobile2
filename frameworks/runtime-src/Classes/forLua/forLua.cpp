/*
** Lua binding: forLua
** Generated automatically by tolua++-1.0.92 on 12/01/16 13:47:43.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif
#include "string.h"

#include "tolua++.h"

/* Exported function */
TOLUA_API int  tolua_forLua_open (lua_State* tolua_S);

#include "tolua_fix.h"
#include <map>
#include <string>
#include <list>
#include <vector>
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos-ext.h"
using namespace cocos2d;
using namespace cocos2d::extension;
using namespace CocosDenshion;
#include "luaBindFunction.h"
#include "cToolsForLua.h"
#include "../httpNet/httpNet.h"

/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 
 tolua_usertype(tolua_S,"cToolsForLua");
 tolua_usertype(tolua_S,"httpNet");
 tolua_usertype(tolua_S,"luaBindFunction");
}

/* method: getInstance of class  luaBindFunction */
#ifndef TOLUA_DISABLE_tolua_forLua_luaBindFunction_getInstance00
static int tolua_forLua_luaBindFunction_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"luaBindFunction",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   luaBindFunction* tolua_ret = (luaBindFunction*)  luaBindFunction::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"luaBindFunction");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: destroyInstance of class  luaBindFunction */
#ifndef TOLUA_DISABLE_tolua_forLua_luaBindFunction_destroyInstance00
static int tolua_forLua_luaBindFunction_destroyInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"luaBindFunction",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   luaBindFunction::destroyInstance();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'destroyInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: binLuaFunction of class  luaBindFunction */
#ifndef TOLUA_DISABLE_tolua_forLua_luaBindFunction_binLuaFunction00
static int tolua_forLua_luaBindFunction_binLuaFunction00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"luaBindFunction",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  luaBindFunction* self = (luaBindFunction*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION funcID = (  toluafix_ref_function(tolua_S,2,0));
  const char* funName = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'binLuaFunction'", NULL);
#endif
  {
   self->binLuaFunction(funcID,funName);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'binLuaFunction'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: removeLuaFunction of class  luaBindFunction */
#ifndef TOLUA_DISABLE_tolua_forLua_luaBindFunction_removeLuaFunction00
static int tolua_forLua_luaBindFunction_removeLuaFunction00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"luaBindFunction",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  luaBindFunction* self = (luaBindFunction*)  tolua_tousertype(tolua_S,1,0);
  const char* funName = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'removeLuaFunction'", NULL);
#endif
  {
   self->removeLuaFunction(funName);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'removeLuaFunction'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: removeAllLuaFunction of class  luaBindFunction */
#ifndef TOLUA_DISABLE_tolua_forLua_luaBindFunction_removeAllLuaFunction00
static int tolua_forLua_luaBindFunction_removeAllLuaFunction00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"luaBindFunction",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  luaBindFunction* self = (luaBindFunction*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'removeAllLuaFunction'", NULL);
#endif
  {
   self->removeAllLuaFunction();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'removeAllLuaFunction'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getLuaFunction of class  luaBindFunction */
#ifndef TOLUA_DISABLE_tolua_forLua_luaBindFunction_getLuaFunction00
static int tolua_forLua_luaBindFunction_getLuaFunction00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"luaBindFunction",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  luaBindFunction* self = (luaBindFunction*)  tolua_tousertype(tolua_S,1,0);
  const char* funName = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getLuaFunction'", NULL);
#endif
  {
   int tolua_ret = (int)  self->getLuaFunction(funName);
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getLuaFunction'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: MessageBox of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_MessageBox00
static int tolua_forLua_cToolsForLua_MessageBox00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* msg = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* title = ((const char*)  tolua_tostring(tolua_S,3,0));
  {
   cToolsForLua::MessageBox(msg,title);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MessageBox'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: isDebugVersion of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_isDebugVersion00
static int tolua_forLua_cToolsForLua_isDebugVersion00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   bool tolua_ret = (bool)  cToolsForLua::isDebugVersion();
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isDebugVersion'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: writeStringToFile of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_writeStringToFile00
static int tolua_forLua_cToolsForLua_writeStringToFile00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* data = ((const char*)  tolua_tostring(tolua_S,2,0));
  int size = ((int)  tolua_tonumber(tolua_S,3,0));
  const char* fullPath = ((const char*)  tolua_tostring(tolua_S,4,0));
  {
   bool tolua_ret = (bool)  cToolsForLua::writeStringToFile(data,size,fullPath);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'writeStringToFile'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: calc2VecAngle of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_calc2VecAngle00
static int tolua_forLua_cToolsForLua_calc2VecAngle00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  float bx = ((float)  tolua_tonumber(tolua_S,2,0));
  float by = ((float)  tolua_tonumber(tolua_S,3,0));
  float vx = ((float)  tolua_tonumber(tolua_S,4,0));
  float vy = ((float)  tolua_tonumber(tolua_S,5,0));
  {
   float tolua_ret = (float)  cToolsForLua::calc2VecAngle(bx,by,vx,vy);
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'calc2VecAngle'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: urlEncodeForBase64 of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_urlEncodeForBase6400
static int tolua_forLua_cToolsForLua_urlEncodeForBase6400(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string base64 = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  {
   std::string tolua_ret = (std::string)  cToolsForLua::urlEncodeForBase64(base64);
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
   tolua_pushcppstring(tolua_S,(const char*)base64);
  }
 }
 return 2;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'urlEncodeForBase64'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: urlDecodeForUrlBase64 of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_urlDecodeForUrlBase6400
static int tolua_forLua_cToolsForLua_urlDecodeForUrlBase6400(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string urlbase64 = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  {
   std::string tolua_ret = (std::string)  cToolsForLua::urlDecodeForUrlBase64(urlbase64);
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
   tolua_pushcppstring(tolua_S,(const char*)urlbase64);
  }
 }
 return 2;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'urlDecodeForUrlBase64'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: decode of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_decode00
static int tolua_forLua_cToolsForLua_decode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string text = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  const std::string key = ((const std::string)  tolua_tocppstring(tolua_S,3,0));
  {
   std::string tolua_ret = (std::string)  cToolsForLua::decode(text,key);
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
   tolua_pushcppstring(tolua_S,(const char*)text);
   tolua_pushcppstring(tolua_S,(const char*)key);
  }
 }
 return 3;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'decode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: encode of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_encode00
static int tolua_forLua_cToolsForLua_encode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,2,0,&tolua_err) ||
     !tolua_iscppstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const std::string text = ((const std::string)  tolua_tocppstring(tolua_S,2,0));
  const std::string key = ((const std::string)  tolua_tocppstring(tolua_S,3,0));
  {
   std::string tolua_ret = (std::string)  cToolsForLua::encode(text,key);
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
   tolua_pushcppstring(tolua_S,(const char*)text);
   tolua_pushcppstring(tolua_S,(const char*)key);
  }
 }
 return 3;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'encode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sha1 of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_sha100
static int tolua_forLua_cToolsForLua_sha100(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  char* input = ((char*)  tolua_tostring(tolua_S,2,0));
  {
   std::string tolua_ret = (std::string)  cToolsForLua::sha1(input);
   tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sha1'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: immediatelyDraw of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_immediatelyDraw00
static int tolua_forLua_cToolsForLua_immediatelyDraw00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   cToolsForLua::immediatelyDraw();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'immediatelyDraw'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getIOSDeviceModel of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_getIOSDeviceModel00
static int tolua_forLua_cToolsForLua_getIOSDeviceModel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   char* tolua_ret = (char*)  cToolsForLua::getIOSDeviceModel();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getIOSDeviceModel'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getIOSSystemVersion of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_getIOSSystemVersion00
static int tolua_forLua_cToolsForLua_getIOSSystemVersion00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   char* tolua_ret = (char*)  cToolsForLua::getIOSSystemVersion();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getIOSSystemVersion'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: pushHandlerForlua of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_pushHandlerForlua00
static int tolua_forLua_cToolsForLua_pushHandlerForlua00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  LUA_FUNCTION funcID = (  toluafix_ref_function(tolua_S,2,0));
  {
   int tolua_ret = (int)  cToolsForLua::pushHandlerForlua(funcID);
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'pushHandlerForlua'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: reStartGame of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_reStartGame00
static int tolua_forLua_cToolsForLua_reStartGame00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   cToolsForLua::reStartGame();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'reStartGame'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setBadge of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_setBadge00
static int tolua_forLua_cToolsForLua_setBadge00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  int var = ((int)  tolua_tonumber(tolua_S,2,0));
  {
   cToolsForLua::setBadge(var);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setBadge'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: showAsynchronousBox of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_showAsynchronousBox00
static int tolua_forLua_cToolsForLua_showAsynchronousBox00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   cToolsForLua::showAsynchronousBox();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'showAsynchronousBox'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: hideAsynchronousBox of class  cToolsForLua */
#ifndef TOLUA_DISABLE_tolua_forLua_cToolsForLua_hideAsynchronousBox00
static int tolua_forLua_cToolsForLua_hideAsynchronousBox00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"cToolsForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   cToolsForLua::hideAsynchronousBox();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'hideAsynchronousBox'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getInstance of class  httpNet */
#ifndef TOLUA_DISABLE_tolua_forLua_httpNet_getInstance00
static int tolua_forLua_httpNet_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"httpNet",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   httpNet* tolua_ret = (httpNet*)  httpNet::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"httpNet");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: destroyInstance of class  httpNet */
#ifndef TOLUA_DISABLE_tolua_forLua_httpNet_destroyInstance00
static int tolua_forLua_httpNet_destroyInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"httpNet",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   httpNet::destroyInstance();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'destroyInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: Post of class  httpNet */
#ifndef TOLUA_DISABLE_tolua_forLua_httpNet_Post00
static int tolua_forLua_httpNet_Post00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"httpNet",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !toluafix_isfunction(tolua_S,5,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnumber(tolua_S,6,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,7,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,8,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,9,0,&tolua_err) ||
     !tolua_isstring(tolua_S,10,1,&tolua_err) ||
     !tolua_isstring(tolua_S,11,1,&tolua_err) ||
     !tolua_isstring(tolua_S,12,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,13,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  httpNet* self = (httpNet*)  tolua_tousertype(tolua_S,1,0);
  const char* urlString = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* jsonString = ((const char*)  tolua_tostring(tolua_S,3,0));
  int jsonSize = ((int)  tolua_tonumber(tolua_S,4,0));
  LUA_FUNCTION funcID = (  toluafix_ref_function(tolua_S,5,0));
  int connectTime = ((int)  tolua_tonumber(tolua_S,6,0));
  int totalTime = ((int)  tolua_tonumber(tolua_S,7,0));
  bool useAsync = ((bool)  tolua_toboolean(tolua_S,8,0));
  bool usePack = ((bool)  tolua_toboolean(tolua_S,9,0));
  const char* headString = ((const char*)  tolua_tostring(tolua_S,10,nullptr));
  const char* headSplitFlag = ((const char*)  tolua_tostring(tolua_S,11,nullptr));
  const char* ssl_path = ((const char*)  tolua_tostring(tolua_S,12,nullptr));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'Post'", NULL);
#endif
  {
   self->Post(urlString,jsonString,jsonSize,funcID,connectTime,totalTime,useAsync,usePack,headString,headSplitFlag,ssl_path);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'Post'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: Post2 of class  httpNet */
#ifndef TOLUA_DISABLE_tolua_forLua_httpNet_Post200
static int tolua_forLua_httpNet_Post200(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"httpNet",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !toluafix_isfunction(tolua_S,5,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnumber(tolua_S,6,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,7,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,8,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,9,0,&tolua_err) ||
     !tolua_isstring(tolua_S,10,1,&tolua_err) ||
     !tolua_isstring(tolua_S,11,1,&tolua_err) ||
     !tolua_isstring(tolua_S,12,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,13,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  httpNet* self = (httpNet*)  tolua_tousertype(tolua_S,1,0);
  const char* urlString = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* jsonString = ((const char*)  tolua_tostring(tolua_S,3,0));
  int jsonSize = ((int)  tolua_tonumber(tolua_S,4,0));
  LUA_FUNCTION funcID = (  toluafix_ref_function(tolua_S,5,0));
  int connectTime = ((int)  tolua_tonumber(tolua_S,6,0));
  int totalTime = ((int)  tolua_tonumber(tolua_S,7,0));
  bool useAsync = ((bool)  tolua_toboolean(tolua_S,8,0));
  bool usePack = ((bool)  tolua_toboolean(tolua_S,9,0));
  const char* headString = ((const char*)  tolua_tostring(tolua_S,10,nullptr));
  const char* headSplitFlag = ((const char*)  tolua_tostring(tolua_S,11,nullptr));
  const char* ssl_path = ((const char*)  tolua_tostring(tolua_S,12,nullptr));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'Post2'", NULL);
#endif
  {
   self->Post2(urlString,jsonString,jsonSize,funcID,connectTime,totalTime,useAsync,usePack,headString,headSplitFlag,ssl_path);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'Post2'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: Get of class  httpNet */
#ifndef TOLUA_DISABLE_tolua_forLua_httpNet_Get00
static int tolua_forLua_httpNet_Get00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"httpNet",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnumber(tolua_S,4,1,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,1,&tolua_err) ||
     !tolua_isstring(tolua_S,6,1,&tolua_err) ||
     !tolua_isstring(tolua_S,7,1,&tolua_err) ||
     !tolua_isstring(tolua_S,8,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,9,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  httpNet* self = (httpNet*)  tolua_tousertype(tolua_S,1,0);
  const char* urlString = ((const char*)  tolua_tostring(tolua_S,2,0));
  LUA_FUNCTION funcID = (  toluafix_ref_function(tolua_S,3,0));
  int connectTime = ((int)  tolua_tonumber(tolua_S,4,7));
  int totalTime = ((int)  tolua_tonumber(tolua_S,5,7));
  const char* headString = ((const char*)  tolua_tostring(tolua_S,6,nullptr));
  const char* headSplitFlag = ((const char*)  tolua_tostring(tolua_S,7,nullptr));
  const char* ssl_path = ((const char*)  tolua_tostring(tolua_S,8,nullptr));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'Get'", NULL);
#endif
  {
   self->Get(urlString,funcID,connectTime,totalTime,headString,headSplitFlag,ssl_path);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'Get'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: DiscardAllPost of class  httpNet */
#ifndef TOLUA_DISABLE_tolua_forLua_httpNet_DiscardAllPost00
static int tolua_forLua_httpNet_DiscardAllPost00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"httpNet",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  httpNet* self = (httpNet*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'DiscardAllPost'", NULL);
#endif
  {
   self->DiscardAllPost();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'DiscardAllPost'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: SetFailedThing of class  httpNet */
#ifndef TOLUA_DISABLE_tolua_forLua_httpNet_SetFailedThing00
static int tolua_forLua_httpNet_SetFailedThing00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"httpNet",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  httpNet* self = (httpNet*)  tolua_tousertype(tolua_S,1,0);
  bool var = ((bool)  tolua_toboolean(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'SetFailedThing'", NULL);
#endif
  {
   self->SetFailedThing(var);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'SetFailedThing'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_forLua_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"luaBindFunction","luaBindFunction","",NULL);
  tolua_beginmodule(tolua_S,"luaBindFunction");
   tolua_function(tolua_S,"getInstance",tolua_forLua_luaBindFunction_getInstance00);
   tolua_function(tolua_S,"destroyInstance",tolua_forLua_luaBindFunction_destroyInstance00);
   tolua_function(tolua_S,"binLuaFunction",tolua_forLua_luaBindFunction_binLuaFunction00);
   tolua_function(tolua_S,"removeLuaFunction",tolua_forLua_luaBindFunction_removeLuaFunction00);
   tolua_function(tolua_S,"removeAllLuaFunction",tolua_forLua_luaBindFunction_removeAllLuaFunction00);
   tolua_function(tolua_S,"getLuaFunction",tolua_forLua_luaBindFunction_getLuaFunction00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"cToolsForLua","cToolsForLua","",NULL);
  tolua_beginmodule(tolua_S,"cToolsForLua");
   tolua_function(tolua_S,"MessageBox",tolua_forLua_cToolsForLua_MessageBox00);
   tolua_function(tolua_S,"isDebugVersion",tolua_forLua_cToolsForLua_isDebugVersion00);
   tolua_function(tolua_S,"writeStringToFile",tolua_forLua_cToolsForLua_writeStringToFile00);
   tolua_function(tolua_S,"calc2VecAngle",tolua_forLua_cToolsForLua_calc2VecAngle00);
   tolua_function(tolua_S,"urlEncodeForBase64",tolua_forLua_cToolsForLua_urlEncodeForBase6400);
   tolua_function(tolua_S,"urlDecodeForUrlBase64",tolua_forLua_cToolsForLua_urlDecodeForUrlBase6400);
   tolua_function(tolua_S,"decode",tolua_forLua_cToolsForLua_decode00);
   tolua_function(tolua_S,"encode",tolua_forLua_cToolsForLua_encode00);
   tolua_function(tolua_S,"sha1",tolua_forLua_cToolsForLua_sha100);
   tolua_function(tolua_S,"immediatelyDraw",tolua_forLua_cToolsForLua_immediatelyDraw00);
   tolua_function(tolua_S,"getIOSDeviceModel",tolua_forLua_cToolsForLua_getIOSDeviceModel00);
   tolua_function(tolua_S,"getIOSSystemVersion",tolua_forLua_cToolsForLua_getIOSSystemVersion00);
   tolua_function(tolua_S,"pushHandlerForlua",tolua_forLua_cToolsForLua_pushHandlerForlua00);
   tolua_function(tolua_S,"reStartGame",tolua_forLua_cToolsForLua_reStartGame00);
   tolua_function(tolua_S,"setBadge",tolua_forLua_cToolsForLua_setBadge00);
   tolua_function(tolua_S,"showAsynchronousBox",tolua_forLua_cToolsForLua_showAsynchronousBox00);
   tolua_function(tolua_S,"hideAsynchronousBox",tolua_forLua_cToolsForLua_hideAsynchronousBox00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"httpNet","httpNet","",NULL);
  tolua_beginmodule(tolua_S,"httpNet");
   tolua_function(tolua_S,"getInstance",tolua_forLua_httpNet_getInstance00);
   tolua_function(tolua_S,"destroyInstance",tolua_forLua_httpNet_destroyInstance00);
   tolua_function(tolua_S,"Post",tolua_forLua_httpNet_Post00);
   tolua_function(tolua_S,"Post2",tolua_forLua_httpNet_Post200);
   tolua_function(tolua_S,"Get",tolua_forLua_httpNet_Get00);
   tolua_function(tolua_S,"DiscardAllPost",tolua_forLua_httpNet_DiscardAllPost00);
   tolua_function(tolua_S,"SetFailedThing",tolua_forLua_httpNet_SetFailedThing00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_forLua (lua_State* tolua_S) {
 return tolua_forLua_open(tolua_S);
};
#endif

