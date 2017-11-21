#ifndef __CTOOLSFORLUA_H__
#define __CTOOLSFORLUA_H__

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "../login/UserLogin.h"

class cToolsForLua
{
public:
	static void init(cocos2d::Application * application);

	static void MessageBox(const char * msg, const char * title);
	
	static bool isDebugVersion();

	static bool writeStringToFile(const char * data, int size,const char * fullPath);

	static float calc2VecAngle(float bx, float by, float vx, float vy);

	//这两个函数别随便调用,传送空字符有危险(王大师做登录专用的)
	static std::string decode(const std::string &text, const std::string &key);
	static std::string encode(const std::string &text, const std::string &key);

	static std::string sha1(char* input);

	//MD5 lua使用会有空字符危险( 有对应的全局函数cTools_msg_pack和cTools_md5_encode )
	static std::string md5_encode(const std::string & msgBuff);

	static void immediatelyDraw();

	static char * getIOSDeviceModel();

	static char * getIOSSystemVersion();

	static std::string urlEncodeForBase64(const std::string & base64);
	static std::string urlDecodeForUrlBase64(const std::string & urlbase64);

	//这两个函数在C++使用,lua使用会有空字符危险( 有对应的全局函数cTools_msg_pack和cTools_msg_unpack )
	static std::string msg_pack(const std::string & msgBuff);
	static std::string msg_unpack(const std::string & msgBuff);

	static std::string msg_pack2(const std::string & msgBuff);
	static std::string msg_unpack2(const std::string & msgBuff);
	static std::string msg_unpack2_new(const std::string & msgBuff, int * sss);

	//此函数会造成lua内存泄漏,是特别情况下才使用的.不明白就问李寒松
	static int pushHandlerForlua(int nHandler);

	//重启游戏
	static void reStartGame();

	static void removeSearchPaths(const std::vector<std::string> & removePaths);

	//设置角标数量
	static void setBadge(int var);

	static void showAsynchronousBox();

	static void hideAsynchronousBox();

	static std::string getExternalAssetsPath();

public:
	static void cTools_manual(lua_State* tolua_S);
    
public:
    static std::string s_ios_deviceToken;
    
};



#endif //__CTOOLSFORLUA_H__