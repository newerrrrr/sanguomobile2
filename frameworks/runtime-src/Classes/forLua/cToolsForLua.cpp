#include "cToolsForLua.h"
#include "tolua_fix.h"
#include <zlib.h>
#include "../platform/ios/platfrom_ios.h"
#include "../md5_tools/md5_tools.h"
#include "../AppDelegate.h"
#include "luaBindFunction.h"
#include "../cTools_Control/LHSDrawNodeToLua.h"
extern "C" {
#include "aes.h"
}
#include "platform/win32/asynchronousBox_Win32.h"
#include "platform/ios/asynchronousBox_ios.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID 
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#import "GeTuiSdk.h"
#endif

std::string cToolsForLua::s_ios_deviceToken = "";

USING_NS_CC;

static cocos2d::Application * s_application = nullptr;
void cToolsForLua::init(cocos2d::Application * application)
{
	s_application = application;
}

void cToolsForLua::MessageBox(const char * msg, const char * title)
{
	cocos2d::MessageBox(msg, title);
}

bool cToolsForLua::isDebugVersion()
{
#if !defined(COCOS2D_DEBUG) || COCOS2D_DEBUG == 0
	return false;
#else
	return true;
#endif
}

bool cToolsForLua::writeStringToFile(const char * data, int size, const char * fullPath)
{
	Data retData;
	retData.copy((unsigned char*)data, size);
	return FileUtils::getInstance()->writeDataToFile(retData, fullPath);
}

float cToolsForLua::calc2VecAngle(float bx, float by, float vx, float vy)
{
	float Tf = bx * vy - vx * by;
	if (Tf > 0)
		return CC_RADIANS_TO_DEGREES(acos((bx * vx + by * vy) / (sqrt(bx * bx + by * by) * sqrt(vx * vx + vy * vy))));
	else if (Tf < 0)
		return -CC_RADIANS_TO_DEGREES(acos((bx * vx + by * vy) / (sqrt(bx * bx + by * by) * sqrt(vx * vx + vy * vy))));
	else
	{
		float x = abs(bx + vx);
		float y = abs(by + vy);
		if (x >= abs(bx) && x >= abs(vx)
			&& y >= abs(by) && y >= abs(vy))
			return 0;
		else
			return /*CC_DEGREES_TO_RADIANS(*/180/*)*/;
	}
}

int cToolsForLua::pushHandlerForlua(int nHandler)
{
	return nHandler;
}


void cToolsForLua::immediatelyDraw()
{
	auto director = Director::getInstance();
	if (director)
	{
		auto renderer = director->getRenderer();
		if (renderer)
		{
			renderer->render();
		}
	}
}


//manual
//////////////////////////////////////////////////////////////////////////
static void s_luaval_to_vec2(lua_State* L, int lo, cocos2d::Vec2* outValue)
{
	lua_pushstring(L, "x");
	lua_gettable(L, lo);
	outValue->x = lua_isnil(L, -1) ? 0 : lua_tonumber(L, -1);
	lua_pop(L, 1);
	lua_pushstring(L, "y");
	lua_gettable(L, lo);
	outValue->y = lua_isnil(L, -1) ? 0 : lua_tonumber(L, -1);
	lua_pop(L, 1);
}

static void s_vec2_to_luaval(lua_State* L, const cocos2d::Vec2& vec2)
{
	if (NULL == L)
		return;
	lua_newtable(L);
	lua_pushstring(L, "x");
	lua_pushnumber(L, (lua_Number)vec2.x);
	lua_rawset(L, -3);
	lua_pushstring(L, "y");
	lua_pushnumber(L, (lua_Number)vec2.y);
	lua_rawset(L, -3);
}


static int cTools_read_file_data(lua_State *L)
{
	unsigned char * retData = NULL;
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		std::string filename = lua_tostring(L, 1);
		cocos2d::Data retData = cocos2d::FileUtils::getInstance()->getDataFromFile(filename.c_str());
		lua_settop(L, 0);
		CC_BREAK_IF(retData.isNull());
		lua_pushlstring(L, (char*)(retData.getBytes()), retData.getSize());
		return 1;
	} while (false);
	return 0;
}


static int cTools_base64_encode(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		char * buffer = nullptr;
		int size = base64Encode((const unsigned char *)data, len, &buffer);
		lua_settop(L, 0);
		CC_BREAK_IF(!buffer);
		lua_pushlstring(L, (char*)(buffer), size);
		free(buffer);
		return 1;
	} while (false);
	return 0;
}


static int cTools_base64_decode(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		unsigned char * buffer = nullptr;
		int size = base64Decode((const unsigned char *)data, len, &buffer);
		lua_settop(L, 0);
		CC_BREAK_IF(!buffer);
		lua_pushlstring(L, (char*)(buffer), size);
		free(buffer);
		return 1;
	} while (false);
	return 0;
}


static const char * s_c_binaryTexturePreName = "cTools_loadTexture_withBinary_hasCache_";
static int s_binaryTextureID = 0;
static int cTools_loadTexture_withBinary_hasCache(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		CC_BREAK_IF(!data || len == 0);
		Image * image = new (std::nothrow) Image();
		if (!image || !image->initWithImageData((const unsigned char *)data, len))
		{
			CC_SAFE_RELEASE(image);
			break;
		}
		char key[256] = { 0 };
		sprintf(key, "%s%d", s_c_binaryTexturePreName, ++s_binaryTextureID);
		Texture2D * texture = Director::getInstance()->getTextureCache()->addImage(image, key);
		CC_SAFE_RELEASE(image);
		lua_settop(L, 0);
		toluafix_pushusertype_ccobject(L, texture->_ID, &texture->_luaID, texture, "cc.Texture2D");
		return 1;
	} while (false);
	return 0;
}


static int cTools_loadTexture_withBinary_notCache(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		CC_BREAK_IF(!data || len == 0);
		Image * image = new (std::nothrow) Image();
		if (!image || !image->initWithImageData((const unsigned char *)data, len))
		{
			CC_SAFE_RELEASE(image);
			break;
		}

		Texture2D * texture = new (std::nothrow) Texture2D();
		if (!texture || !texture->initWithImage(image))
		{
			CC_SAFE_RELEASE(image);
			CC_SAFE_RELEASE(texture);
			break;
		}
		CC_SAFE_RELEASE(image);
		texture->autorelease();
		lua_settop(L, 0);
		toluafix_pushusertype_ccobject(L, texture->_ID, &texture->_luaID, texture, "cc.Texture2D");
		return 1;
	} while (false);
	return 0;
}


static int cTools_worldToNodeSpace_position(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 2);
		tolua_Error tolua_err;
		CC_BREAK_IF(!tolua_isusertype(L, 1, "cc.Node", 0, &tolua_err));
		cocos2d::Node* node = (cocos2d::Node*)tolua_tousertype(L, 1, nullptr);
		CC_BREAK_IF(!node);
		CC_BREAK_IF(lua_type(L, 2) != LUA_TTABLE);
		cocos2d::Vec2 position;
		s_luaval_to_vec2(L, 2, &position);
		lua_settop(L, 0);
		const Camera * camera = Camera::getVisitingCamera();
		if (camera == nullptr)
			camera = Camera::getDefaultCamera();
		const Mat4 w2n = node->getWorldToNodeTransform();
        cocos2d::Rect rect(Vec2::ZERO, node->getContentSize());
		if (camera == nullptr || rect.size.width <= 0 || rect.size.height <= 0)
		{
			s_vec2_to_luaval(L, Vec2(FLT_MAX, FLT_MAX));
			return 1;
		}
		Vec3 nearPos(position.x, position.y, -1), farPos(position.x, position.y, 1);
		nearPos = camera->unprojectGL(nearPos);
		farPos = camera->unprojectGL(farPos);
		w2n.transformPoint(&nearPos);
		w2n.transformPoint(&farPos);
		auto E = farPos - nearPos;
		Vec3 A = Vec3(rect.origin.x, rect.origin.y, 0);
		Vec3 B(rect.origin.x + rect.size.width, rect.origin.y, 0);
		Vec3 C(rect.origin.x, rect.origin.y + rect.size.height, 0);
		B = B - A;
		C = C - A;
		Vec3 BxC;
		Vec3::cross(B, C, &BxC);
		auto BxCdotE = BxC.dot(E);
		if (BxCdotE == 0)
		{
			s_vec2_to_luaval(L, Vec2(FLT_MAX, FLT_MAX));
			return 1;
		}
		auto t = (BxC.dot(A) - BxC.dot(nearPos)) / BxCdotE;
		Vec3 P = nearPos + t * E;
		s_vec2_to_luaval(L, Vec2(P.x, P.y));
		return 1;
	} while (false);
	return 0;
}


static int cTools_NodeSpaceToWorld_position(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 2);
		tolua_Error tolua_err;
		CC_BREAK_IF(!tolua_isusertype(L, 1, "cc.Node", 0, &tolua_err));
		cocos2d::Node* node = (cocos2d::Node*)tolua_tousertype(L, 1, nullptr);
		CC_BREAK_IF(!node);
		CC_BREAK_IF(lua_type(L, 2) != LUA_TTABLE);
		cocos2d::Vec2 position;
		s_luaval_to_vec2(L, 2, &position);
		lua_settop(L, 0);
		const Camera * camera = Camera::getVisitingCamera();
		if (camera == nullptr)
			camera = Camera::getDefaultCamera();
		if (camera == nullptr)
		{
			s_vec2_to_luaval(L, Vec2(FLT_MAX, FLT_MAX));
			return 1;
		}
		Vec2 wp = camera->projectGL(node->convertToWorldSpace3D(Vec3(position.x, position.y, 0.0f)));
		s_vec2_to_luaval(L, wp);
		return 1;
	} while (false);
	return 0;
}


static int cTools_msg_pack(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		std::string msg_data = cToolsForLua::msg_pack(std::string(data, (std::string::size_type)len));
		lua_settop(L, 0);
		lua_pushlstring(L, msg_data.c_str(), (size_t)msg_data.size());
		return 1;
	} while (false);
	return 0;
}


static int cTools_msg_unpack(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		std::string msg_data = cToolsForLua::msg_unpack(std::string(data, (std::string::size_type)len));
		lua_settop(L, 0);
		lua_pushlstring(L, msg_data.c_str(), (size_t)msg_data.size());
		return 1;
	} while (false);
	return 0;
}

static int cTools_msg_pack2(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		std::string msg_data = cToolsForLua::msg_pack2(std::string(data, (std::string::size_type)len));
		lua_settop(L, 0);
		lua_pushlstring(L, msg_data.c_str(), (size_t)msg_data.size());
		return 1;
	} while (false);
	return 0;
}

static int cTools_msg_unpack2(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		std::string msg_data = cToolsForLua::msg_unpack2(std::string(data, (std::string::size_type)len));
		lua_settop(L, 0);
		lua_pushlstring(L, msg_data.c_str(), (size_t)msg_data.size());
		return 1;
	} while (false);
	return 0;
}

static int cTools_md5_encode(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * data = lua_tolstring(L, 1, &len);
		std::string md5_data = cToolsForLua::md5_encode(std::string(data, (std::string::size_type)len));
		lua_settop(L, 0);
		lua_pushlstring(L, md5_data.c_str(), (size_t)md5_data.size());
		return 1;
	} while (false);
	return 0;
}


static int cTools_remove_search_paths(lua_State *L)
{
	do
	{
		std::vector<std::string> removePaths;
		int argc = lua_gettop(L);
		for (int i = 1; i <= argc; i++)
		{
			if (lua_type(L, i) == LUA_TSTRING)
			{
				size_t len = 0;
				const char * data = lua_tolstring(L, i, &len);
				removePaths.push_back(std::string(data, (std::string::size_type)len));
			}
		}
		lua_settop(L, 0);
		if (removePaths.size() > 0)
			cToolsForLua::removeSearchPaths(removePaths);
		return 0;
	} while (false);
	return 0;
}

const int s_Simple_key_count = 9;
static const char s_simple_key[s_Simple_key_count] = { 0x10, 0x11, 0x17, 0x12, 0x40, 0x6b, 0x36, 0x24, 0x26 };

static int cTools_simple_encrypt(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * lua_data = lua_tolstring(L, 1, &len);
		if (len <= 0 || strcmp(lua_data, "") == 0)
		{
			lua_settop(L, 0);
			lua_pushlstring(L, "", 0);
			return 1;
		}
		std::string dataString(lua_data, (std::string::size_type)len);
		int key_index = 0;
		for (size_t i = 0; i < len; i++)
		{
			dataString.at(i) ^= s_simple_key[key_index++];
			if (key_index == s_Simple_key_count)
				key_index = 0;
		}
		char * encoded64Data = nullptr;
		cocos2d::base64Encode((unsigned char *)(dataString.c_str()), (unsigned int)(dataString.size()), &encoded64Data);
		if (!encoded64Data)
		{
			lua_settop(L, 0);
			return 0;
		}
		std::string ret(encoded64Data);
		free(encoded64Data);
		lua_settop(L, 0);
		lua_pushlstring(L, ret.c_str(), (size_t)ret.size());
		return 1;
	} while (false);
	return 0;
}


static int cTools_simple_decrypt(lua_State *L)
{
	do
	{
		CC_BREAK_IF(lua_gettop(L) < 1);
		CC_BREAK_IF(lua_type(L, 1) != LUA_TSTRING);
		size_t len = 0;
		const char * lua_data = lua_tolstring(L, 1, &len);
		if (len == 0 || strcmp(lua_data, "") == 0)
		{
			lua_settop(L, 0);
			lua_pushlstring(L, "", 0);
			return 1;
		}
		unsigned char * decoded64Data = nullptr;
		int len64decode = cocos2d::base64Decode((unsigned char *)lua_data, (unsigned int)len, &decoded64Data);
		if (len64decode <= 0 || !decoded64Data)
		{
			if (decoded64Data)
				free(decoded64Data);
			lua_settop(L, 0);
			return 0;
		}
		std::string ret((char*)decoded64Data, (std::string::size_type)len64decode);
		if (decoded64Data)
			free(decoded64Data);
		int key_index = 0;
		for (int i = 0; i < len64decode; i++)
		{
			ret.at(i) ^= s_simple_key[key_index++];
			if (key_index == s_Simple_key_count)
				key_index = 0;
		}
		lua_settop(L, 0);
		lua_pushlstring(L, ret.c_str(), (size_t)ret.size());
		return 1;
	} while (false);
	return 0;
}


static int cTools_getNotificationClientid(lua_State *L)
{
	do
	{
		std::string ret("");
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
		JniMethodInfo t;
		if (JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lib/Cocos2dxHelper", "getNotificationClientid", "()Ljava/lang/String;")) {
			jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
			t.env->DeleteLocalRef(t.classID);
			ret = JniHelper::jstring2string(str);
			t.env->DeleteLocalRef(str);
		}
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
		NSString * nsCid = [GeTuiSdk clientId];
		if (nsCid)
		{
			const char * pUtf8 = [nsCid UTF8String];
			if (pUtf8)
				ret = pUtf8;
		}
#endif
		lua_settop(L, 0);
		lua_pushlstring(L, ret.c_str(), (size_t)ret.size());
		return 1;
	} while (false);
	return 0;
}



std::string cToolsForLua::getExternalAssetsPath()
{
	std::string ret("");
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lib/Cocos2dxHelper", "getExternalAssetsPath", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
		ret = JniHelper::jstring2string(str);
		t.env->DeleteLocalRef(str);
	}
#endif
	if (ret.size() > 0)
	{
		std::string::size_type pos = ret.rfind("/");
		if (ret.npos == pos || ret.size() - 1 != pos)
		{
			ret.append("/");
		}
	}
	return ret;
}

static int cTools_getExternalAssetsPath(lua_State *L)
{
	do
	{
		std::string ret = cToolsForLua::getExternalAssetsPath();
		lua_settop(L, 0);
		lua_pushlstring(L, ret.c_str(), (size_t)ret.size());
		return 1;
	} while (false);
	return 0;
}


static int cTools_getNotificationDeviceToken(lua_State *L)
{
    do
    {
        lua_settop(L, 0);
        lua_pushlstring(L, cToolsForLua::s_ios_deviceToken.c_str(), (size_t)cToolsForLua::s_ios_deviceToken.size());
        return 1;
    } while (false);
    return 0;
}


void cToolsForLua::cTools_manual(lua_State* tolua_S)
{
	lua_register(tolua_S, "cTools_read_file_data", cTools_read_file_data);
	lua_register(tolua_S, "cTools_base64_encode", cTools_base64_encode);
	lua_register(tolua_S, "cTools_base64_decode", cTools_base64_decode);
	lua_register(tolua_S, "cTools_loadTexture_withBinary_hasCache", cTools_loadTexture_withBinary_hasCache);
	lua_register(tolua_S, "cTools_loadTexture_withBinary_notCache", cTools_loadTexture_withBinary_notCache);
	lua_register(tolua_S, "cTools_worldToNodeSpace_position", cTools_worldToNodeSpace_position);
	lua_register(tolua_S, "cTools_NodeSpaceToWorld_position", cTools_NodeSpaceToWorld_position);
	lua_register(tolua_S, "cTools_msg_pack", cTools_msg_pack);
	lua_register(tolua_S, "cTools_msg_unpack", cTools_msg_unpack);
	lua_register(tolua_S, "cTools_md5_encode", cTools_md5_encode);
	lua_register(tolua_S, "cTools_remove_search_paths", cTools_remove_search_paths);
	lua_register(tolua_S, "cTools_remove_search_paths", cTools_remove_search_paths);
	lua_register(tolua_S, "cTools_remove_search_paths", cTools_remove_search_paths);
	lua_register(tolua_S, "cTools_simple_encrypt", cTools_simple_encrypt);
	lua_register(tolua_S, "cTools_simple_decrypt", cTools_simple_decrypt);
	lua_register(tolua_S, "cTools_getNotificationClientid", cTools_getNotificationClientid);
    lua_register(tolua_S, "cTools_getNotificationDeviceToken", cTools_getNotificationDeviceToken);
	lua_register(tolua_S, "cTools_getNotificationClientid", cTools_getExternalAssetsPath);
	lua_register(tolua_S, "cTools_msg_pack2", cTools_msg_pack2);
	lua_register(tolua_S, "cTools_msg_unpack2", cTools_msg_unpack2);
}

std::string cToolsForLua::sha1(char* input)
{
	return UserLogin::sha1(input);
}

std::string cToolsForLua::encode(const std::string &text, const std::string &key)
{
	return UserLogin::encode(text, key);
}

std::string cToolsForLua::decode(const std::string &text, const std::string &key)
{
	return UserLogin::decode(text, key);
}

std::string cToolsForLua::md5_encode(const std::string & msgBuff)
{
	Md5 md5Obj(msgBuff.c_str(), msgBuff.size());
	return md5Obj.toString();
}

char * cToolsForLua::getIOSDeviceModel()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return platfrom_ios::getDeviceModel();
#else
	return nullptr;
#endif
}

char * cToolsForLua::getIOSSystemVersion()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return platfrom_ios::getSystemVersion();
#else
	return nullptr;
#endif
}

std::string cToolsForLua::urlEncodeForBase64(const std::string & base64)
{
	std::string ret = "";
	ret.reserve(base64.size() + 64);
	ret.append(base64.c_str(), base64.size());
	
	std::string::size_type offset = ret.npos;

	offset = ret.find("+", 0);
	while (offset != ret.npos)
	{
		ret.replace(offset, 1, "%2B");
		offset = ret.find("+", offset);
	}

	offset = ret.find("/", 0);
	while (offset != ret.npos)
	{
		ret.replace(offset, 1, "%2F");
		offset = ret.find("/", offset);
	}

	offset = ret.rfind("=");
	while (offset != ret.npos)
	{
		ret.replace(offset, 1, "%3D");
		offset = ret.rfind("=", offset);
	}

	return ret;
}

std::string cToolsForLua::urlDecodeForUrlBase64(const std::string & urlbase64)
{
	std::string ret = "";
	ret.reserve(urlbase64.size() + 8);
	ret.append(urlbase64.c_str(), urlbase64.size());

	std::string::size_type offset = ret.npos;

	offset = ret.find("%2B", 0);
	while (offset != ret.npos)
	{
		ret.replace(offset, 3, "+");
		offset = ret.find("%2B", offset);
	}

	offset = ret.find("%2b", 0);
	while (offset != ret.npos)
	{
		ret.replace(offset, 3, "+");
		offset = ret.find("%2b", offset);
	}

	offset = ret.find("%2F", 0);
	while (offset != ret.npos)
	{
		ret.replace(offset, 3, "/");
		offset = ret.find("%2F", offset);
	}

	offset = ret.find("%2f", 0);
	while (offset != ret.npos)
	{
		ret.replace(offset, 3, "/");
		offset = ret.find("%2f", offset);
	}

	offset = ret.rfind("%3D");
	while (offset != ret.npos)
	{
		ret.replace(offset, 3, "=");
		offset = ret.rfind("%3D", offset);
	}

	offset = ret.rfind("%3d");
	while (offset != ret.npos)
	{
		ret.replace(offset, 3, "=");
		offset = ret.rfind("%3d", offset);
	}

	return ret;
}

//origin	{ 0x4c, 0x48, 0x53, 0x6c, 0x68, 0x73, 0x78, 0x79, 0x39, 0x5a, 0x4e, 0x2b, 0x3a, 0x3b, 0x0a, 0x7d }
//mask		{ 0x1d, 0x19, 0x02, 0x3d, 0x39, 0x22, 0x29, 0x28, 0x68, 0x0b, 0x1f, 0x7a, 0x6b, 0x6a, 0x5b, 0x2c }
static char s_CryptKey[] = { 0x1d, 0x19, 0x02, 0x3d, 0x39, 0x22, 0x29, 0x28, 0x68, 0x0b, 0x1f, 0x7a, 0x6b, 0x6a, 0x5b, 0x2c };
static const int s_CryptKey_count = sizeof(s_CryptKey) / sizeof(char);
static const char s_CryptKey_mask = 0x51;
static bool s_CryptKeyFirstUes = true;
static void msg_encrypt(unsigned char * buff, unsigned long length)
{
	if (s_CryptKeyFirstUes)
	{
		s_CryptKeyFirstUes = false;
		for (int i = 0; i < s_CryptKey_count; i++)
			s_CryptKey[i] = (s_CryptKey[i]) ^ s_CryptKey_mask;
	}
	int key_index = 0;
	for (unsigned long i = 0; i < length; i++)
	{
		(buff[i]) ^= s_CryptKey[key_index++];
		if (key_index == s_CryptKey_count)
			key_index = 0;
	}
}

static void msg_decrypt(unsigned char * buff, unsigned long length)
{
	if (s_CryptKeyFirstUes)
	{
		s_CryptKeyFirstUes = false;
		for (int i = 0; i < s_CryptKey_count; i++)
			s_CryptKey[i] = (s_CryptKey[i]) ^ s_CryptKey_mask;
	}
	int key_index = 0;
	for (unsigned long i = 0; i < length; i++)
	{
		(buff[i]) ^= s_CryptKey[key_index++];
		if (key_index == s_CryptKey_count)
			key_index = 0;
	}
}

const unsigned long s_DeflatBuffer_Size = 32 * 1024;
static unsigned char s_DeflatBuffer[s_DeflatBuffer_Size] = { 0 };

std::string cToolsForLua::msg_pack(const std::string & msgBuff)
{
	unsigned long origin_size = (unsigned long)(msgBuff.size());

	unsigned long need_size = compressBound(origin_size);
	
	unsigned char * buff = nullptr;

	unsigned long destLen = 0;

	if (need_size > s_DeflatBuffer_Size)
	{
		destLen = need_size;
		buff = new unsigned char[need_size];
	}
	else
	{
		destLen = s_DeflatBuffer_Size;
		buff = s_DeflatBuffer;
	}
	
	switch (compress(buff, &destLen, (const unsigned char *)msgBuff.c_str(), origin_size))
	{
	case Z_OK:
		break;
	default:
	{
		if (buff && buff != s_DeflatBuffer)
			delete[] buff;
		return "";
	}
		break;
	}

	msg_encrypt(buff, destLen);

	char * encodedData = nullptr;

	cocos2d::base64Encode(buff, (unsigned int)destLen, &encodedData);

	std::string ret(encodedData);

	if (buff && buff != s_DeflatBuffer)
		delete[] buff;

	free(encodedData);

	return cToolsForLua::urlEncodeForBase64(ret);
}

std::string cToolsForLua::msg_unpack(const std::string & msgBuff)
{
	std::string ret = "";

	if (msgBuff.size() == 0)
		return ret;

	//std::string base64Buff = urlDecodeForUrlBase64(msgBuff);

	unsigned char * decodedData = nullptr;
	int decodedDataLen = cocos2d::base64Decode((unsigned char*)msgBuff.c_str(), (unsigned int)(msgBuff.size()), &decodedData);

	if (decodedDataLen > 0)
	{
		msg_decrypt(decodedData, decodedDataLen);

		unsigned char* unpackedData = nullptr;

		ssize_t unpackedLen = cocos2d::ZipUtils::inflateMemoryWithHint(decodedData, (ssize_t)decodedDataLen, &unpackedData, ((decodedDataLen < 2000) ? (65536) : (131072)));

		if (unpackedLen > 0)
		{
			ret.append((const char *)unpackedData, (std::string::size_type)unpackedLen);
		}
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
		else
		{
			std::string originData(msgBuff.c_str(), msgBuff.size());
			originData.append("\0", 1);
			CCLOG("uncompress length zero : %s", originData.c_str());
		}
#endif
		if (unpackedData)
			free(unpackedData);
	}
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
	else
	{
		std::string originData(msgBuff.c_str(), msgBuff.size());
		originData.append("\0", 1);
		CCLOG("base64Decode length zero : %s", originData.c_str());
	}
#endif

	if (decodedData)
		free(decodedData);

	return ret;
}

static const unsigned char aes_key_mask[8] = {
	0x7a,
	0x76,
	0x79,
	0x78,
	0x74,
	0x7a,
	0x6a,
	0x71,
};

#define  AES_KEY_SIZE 32

#define HEAD_SIZE sizeof(int)

//协定大端
static int g_ConvertByteOrder(int v)
{
	unsigned short var = 0xddff;
	if ((*((unsigned char*)&var)) == 0xff)
	{
		int var = v;
		int len = sizeof(int);
		unsigned char * p = (unsigned char *)&var;
		for (int i = 0, j = len - 1; j > i; j--, i++)
		{
			unsigned char tv = p[j];
			p[j] = p[i];
			p[i] = tv;
		}
		return var;
	}
	return v;
}

static void en_sdfsxcvxcv(const char * password, int passwordLength, unsigned char * in_buffer, int in_length, unsigned char ** out_buffer, int * out_length)
{
	aes_context aes_ctx;
	unsigned char iv[16] = {};
	unsigned char key[32] = {};
	memset(iv, 0, sizeof(iv));
	memset(key, 0, sizeof(key));
	memcpy(key, password, passwordLength);
	aes_setkey_enc(&aes_ctx, key, 256);

	int enc_length = in_length + 16 - in_length % 16;
	unsigned char * tempBuff = new unsigned char[enc_length];
	memcpy(tempBuff, in_buffer, in_length);
	if (enc_length > in_length)
	{
		memset(tempBuff + in_length, 0, enc_length - in_length);
	}

	*out_length = enc_length + HEAD_SIZE;
	*out_buffer = new unsigned char[*out_length];
	int originDataLength = g_ConvertByteOrder((int)in_length);
	memcpy(*out_buffer, &originDataLength, HEAD_SIZE);

	aes_crypt_cbc(&aes_ctx, AES_ENCRYPT, enc_length, iv, tempBuff, (*out_buffer) + HEAD_SIZE);

	delete[] tempBuff;
}

static void de_sdfsxcvxcv(const char * password, int passwordLength, unsigned char * in_buffer, int in_length, unsigned char ** out_buffer, int * out_length)
{
	aes_context aes_ctx;
	unsigned char iv[16] = {};
	unsigned char key[32] = {};
	memset(iv, 0, sizeof(iv));
	memset(key, 0, sizeof(key));
	memcpy(key, password, passwordLength);
	aes_setkey_dec(&aes_ctx, key, 256);

	int originDataLength = 0;
	memcpy(&originDataLength, in_buffer, HEAD_SIZE);
	*out_length = g_ConvertByteOrder(originDataLength);
	*out_buffer = new unsigned char[in_length - HEAD_SIZE];

	aes_crypt_cbc(&aes_ctx, AES_DECRYPT, in_length - HEAD_SIZE, iv, in_buffer + HEAD_SIZE, *out_buffer);
}

std::string cToolsForLua::msg_pack2(const std::string & msgBuff)
{
	char aes_key_buf[AES_KEY_SIZE] = { 0 };
	for (int i = 0; i < AES_KEY_SIZE; i++)
	{
		if (i < 8)
			aes_key_buf[i] = ((unsigned char)(aes_key_mask[i])) ^ 18;
		else if (i < 16)
			aes_key_buf[i] = ((unsigned char)(LHSDrawNodeToLua::sdfsdafcxvxcv()[i - 8])) ^ 21;
		else
			aes_key_buf[i] = ((unsigned char)(cxvxzcdsfrhgfhgdfgsdf[i - 16])) ^ 25;
	}

	unsigned long origin_size = (unsigned long)(msgBuff.size());

	unsigned long need_size = compressBound(origin_size);

	unsigned char * buff = nullptr;

	unsigned long destLen = 0;

	if (need_size > s_DeflatBuffer_Size)
	{
		destLen = need_size;
		buff = new unsigned char[need_size];
	}
	else
	{
		destLen = s_DeflatBuffer_Size;
		buff = s_DeflatBuffer;
	}

	switch (compress(buff, &destLen, (const unsigned char *)msgBuff.c_str(), origin_size))
	{
	case Z_OK:
		break;
	default:
	{
		if (buff && buff != s_DeflatBuffer)
			delete[] buff;
		return "";
	}
		break;
	}

	unsigned char * outBuffer = nullptr;
	int outLength = 0;
	en_sdfsxcvxcv(aes_key_buf, AES_KEY_SIZE, buff, destLen, &outBuffer, &outLength);

	if (buff && buff != s_DeflatBuffer)
		delete[] buff;

	if (outBuffer == nullptr || outLength <= 0)
	{
		if (outBuffer)
			delete[] outBuffer;
		return "";
	}

	char * encodedData = nullptr;

	cocos2d::base64Encode(outBuffer, (unsigned int)outLength, &encodedData);

	if (outBuffer)
		delete[] outBuffer;

	std::string ret(encodedData);

	free(encodedData);

	return cToolsForLua::urlEncodeForBase64(ret);
}

std::string cToolsForLua::msg_unpack2(const std::string & msgBuff)
{
	char aes_key_buf[AES_KEY_SIZE] = { 0 };
	for (int i = 0; i < AES_KEY_SIZE; i++)
	{
		if (i < 8)
			aes_key_buf[i] = ((unsigned char)(aes_key_mask[i])) ^ 18;
		else if (i < 16)
			aes_key_buf[i] = ((unsigned char)(LHSDrawNodeToLua::sdfsdafcxvxcv()[i - 8])) ^ 21;
		else
			aes_key_buf[i] = ((unsigned char)(cxvxzcdsfrhgfhgdfgsdf[i - 16])) ^ 25;
	}

	std::string ret = "";

	if (msgBuff.size() == 0)
		return ret;

	//std::string base64Buff = urlDecodeForUrlBase64(msgBuff);

	unsigned char * decodedData = nullptr;
	int decodedDataLen = cocos2d::base64Decode((unsigned char*)msgBuff.c_str(), (unsigned int)(msgBuff.size()), &decodedData);

	if (decodedDataLen > 0)
	{
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
		do 
		{
			int originDataLength = 0;
			memcpy(&originDataLength, decodedData, HEAD_SIZE);
			originDataLength = g_ConvertByteOrder(originDataLength);
			if (originDataLength <= 0 || originDataLength > decodedDataLen)
			{
				std::string originData(msgBuff.c_str(), msgBuff.size());
				originData.append("\0", 1);
				CCLOG("Maybe unpack msg error : %s", originData.c_str());
			}
		} while (false);
#endif
		unsigned char * outBuffer = nullptr;
		int outLength = 0;
		de_sdfsxcvxcv(aes_key_buf, AES_KEY_SIZE, decodedData, decodedDataLen, &outBuffer, &outLength);
		
		if (decodedData)
			free(decodedData);

		if (outBuffer == nullptr || outLength <= 0)
		{
			if (outBuffer)
				delete[] outBuffer;
			std::string originData(msgBuff.c_str(), msgBuff.size());
			originData.append("\0", 1);
			CCLOG("decrypt error : %s", originData.c_str());
		}
		else
		{
			unsigned char* unpackedData = nullptr;

			ssize_t unpackedLen = cocos2d::ZipUtils::inflateMemoryWithHint(outBuffer, (ssize_t)outLength, &unpackedData, ((outLength < 2000) ? (65536) : (131072)));

			if (outBuffer)
				delete[] outBuffer;

			if (unpackedLen > 0)
			{
				ret.append((const char *)unpackedData, (std::string::size_type)unpackedLen);
			}
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
			else
			{
				std::string originData(msgBuff.c_str(), msgBuff.size());
				originData.append("\0", 1);
				CCLOG("uncompress length zero : %s", originData.c_str());
			}
#endif
			if (unpackedData)
				free(unpackedData);
		}
	}
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
	else
	{
		if (decodedData)
			free(decodedData);
		std::string originData(msgBuff.c_str(), msgBuff.size());
		originData.append("\0", 1);
		CCLOG("base64Decode length zero : %s", originData.c_str());
	}
#endif

	return ret;
}


std::string cToolsForLua::msg_unpack2_new(const std::string & msgBuff, int * sss)
{
	char aes_key_buf[AES_KEY_SIZE] = { 0 };
	for (int i = 0; i < AES_KEY_SIZE; i++)
	{
		if (i < 8)
			aes_key_buf[i] = ((unsigned char)(aes_key_mask[i])) ^ 18;
		else if (i < 16)
			aes_key_buf[i] = ((unsigned char)(LHSDrawNodeToLua::sdfsdafcxvxcv()[i - 8])) ^ 21;
		else
			aes_key_buf[i] = ((unsigned char)(cxvxzcdsfrhgfhgdfgsdf[i - 16])) ^ 25;
	}

	std::string ret = "";

	if (msgBuff.size() == 0)
	{
		*sss = 0;
		return ret;
	}

	//std::string base64Buff = urlDecodeForUrlBase64(msgBuff);

	unsigned char * decodedData = nullptr;
	int decodedDataLen = cocos2d::base64Decode((unsigned char*)msgBuff.c_str(), (unsigned int)(msgBuff.size()), &decodedData);

	if (decodedDataLen > 0)
	{
		do
		{
			int originDataLength = 0;
			memcpy(&originDataLength, decodedData, HEAD_SIZE);
			originDataLength = g_ConvertByteOrder(originDataLength);
			if (originDataLength <= 0 || originDataLength > decodedDataLen - HEAD_SIZE)
			{
				//由于服务器包装错误，造成客户端内存越界崩溃
				*sss = -1;
				std::string originData(msgBuff.c_str(), msgBuff.size());
				originData.append("\0", 1);
				CCLOG("server pack error : %s", originData.c_str());
				return ret;
			}
		} while (false);

		unsigned char * outBuffer = nullptr;
		int outLength = 0;
		de_sdfsxcvxcv(aes_key_buf, AES_KEY_SIZE, decodedData, decodedDataLen, &outBuffer, &outLength);

		if (decodedData)
			free(decodedData);

		if (outBuffer == nullptr || outLength <= 0)
		{
			if (outBuffer)
				delete[] outBuffer;
			*sss = 0;
			std::string originData(msgBuff.c_str(), msgBuff.size());
			originData.append("\0", 1);
			CCLOG("decrypt error : %s", originData.c_str());
		}
		else
		{
			unsigned char* unpackedData = nullptr;

			ssize_t unpackedLen = cocos2d::ZipUtils::inflateMemoryWithHint(outBuffer, (ssize_t)outLength, &unpackedData, ((outLength < 2000) ? (65536) : (131072)));

			if (outBuffer)
				delete[] outBuffer;

			if (unpackedLen > 0)
			{
				*sss = 1;
				ret.append((const char *)unpackedData, (std::string::size_type)unpackedLen);
			}
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
			else
			{
				*sss = 0;
				std::string originData(msgBuff.c_str(), msgBuff.size());
				originData.append("\0", 1);
				CCLOG("uncompress length zero : %s", originData.c_str());
			}
#endif
			if (unpackedData)
				free(unpackedData);
		}
	}
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
	else
	{
		if (decodedData)
			free(decodedData);
		*sss = 0;
		std::string originData(msgBuff.c_str(), msgBuff.size());
		originData.append("\0", 1);
		CCLOG("base64Decode length zero : %s", originData.c_str());
	}
#endif

	return ret;
}

void cToolsForLua::reStartGame()
{
	if (s_application)
		((AppDelegate*)s_application)->reStartGame();
}

void cToolsForLua::removeSearchPaths(const std::vector<std::string> & removePaths)
{
	auto searchPaths = FileUtils::getInstance()->getSearchPaths();
	bool isChanged = false;
	for (auto it = removePaths.begin(); it != removePaths.end(); it++)
	{
		std::string prefix;
		if (!FileUtils::getInstance()->isAbsolutePath(*it))
			prefix = FileUtils::getInstance()->getDefaultResourceRootPath();
		std::string path = prefix + (*it);
		if (path.length() > 0 && path[path.length() - 1] != '/')
			path += "/";
		auto find_it = std::find(searchPaths.begin(), searchPaths.end(), path);
		if (find_it != searchPaths.end())
		{
			searchPaths.erase(find_it);
			isChanged = true;
		}
	}
	if (isChanged)
		FileUtils::getInstance()->setSearchPaths(searchPaths);
}

void cToolsForLua::setBadge(int var)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	if (var > 0)
	{
		[GeTuiSdk setBadge:var];
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:var];
	}
	else
	{
		[GeTuiSdk resetBadge];
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	}
#endif
}

EventListenerTouchOneByOne * s_TouchListener = nullptr;
void cToolsForLua::showAsynchronousBox()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lib/Cocos2dxHelper", "progressDialogShow", "()V")) 
	{
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	asynchronousBox_ios::showAsynchronousBox();
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	asynchronousBox_Win32::showAsynchronousBox();
#endif
	Director::getInstance()->getEventDispatcher()->setDiscardAllTouchEndEventToCancelled();
	if (s_TouchListener)
	{
		Director::getInstance()->getEventDispatcher()->removeEventListener(s_TouchListener);
		s_TouchListener->release();
		s_TouchListener = nullptr;
	}
	s_TouchListener = EventListenerTouchOneByOne::create();
	s_TouchListener->retain();
	s_TouchListener->setSwallowTouches(true);
	s_TouchListener->onTouchBegan = [](Touch*touch, Event* event)->bool{ return true; };
	Director::getInstance()->getEventDispatcher()->addEventListenerWithFixedPriority(s_TouchListener, INT_MIN);
}

void cToolsForLua::hideAsynchronousBox()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JniMethodInfo t;
	if (JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lib/Cocos2dxHelper", "progressDialogDismiss", "()V")) 
	{
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	asynchronousBox_ios::hideAsynchronousBox();
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	asynchronousBox_Win32::hideAsynchronousBox();
#endif
	if (s_TouchListener)
	{
		Director::getInstance()->getEventDispatcher()->removeEventListener(s_TouchListener);
		s_TouchListener->release();
		s_TouchListener = nullptr;
	}
}