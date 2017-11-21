#include "LHSRenderTextureToScreenToLua.h"
#include "CCLuaEngine.h"

USING_NS_CC;



LHSRenderTextureToScreenToLua::LHSRenderTextureToScreenToLua()
	:_drawHandler(0)
{

}

LHSRenderTextureToScreenToLua::~LHSRenderTextureToScreenToLua()
{
	unregisterScriptDrawHandler();
}

LHSRenderTextureToScreenToLua * LHSRenderTextureToScreenToLua::create(cocos2d::RenderTexture * rt)
{
	LHSRenderTextureToScreenToLua * ret = new (std::nothrow) LHSRenderTextureToScreenToLua();
	if (ret && ret->initWithRenderTexture(rt))
	{
		ret->autorelease();
		return ret;
	}
	if (ret)
		delete ret;
	return nullptr;
}

void LHSRenderTextureToScreenToLua::registerScriptDrawHandler(int handler)
{
	unregisterScriptDrawHandler();
	_drawHandler = handler;
}

void LHSRenderTextureToScreenToLua::unregisterScriptDrawHandler(void)
{
	if (_drawHandler)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_drawHandler);
		_drawHandler = 0;
	}
}

static void s_mat4_to_luaval(lua_State* L, const cocos2d::Mat4& mat)
{
	if (nullptr == L)
		return;

	lua_newtable(L);
	int indexTable = 1;

	for (int i = 0; i < 16; i++)
	{
		lua_pushnumber(L, (lua_Number)indexTable);
		lua_pushnumber(L, (lua_Number)mat.m[i]);
		lua_rawset(L, -3);
		++indexTable;
	}
}

void LHSRenderTextureToScreenToLua::onDraw(const cocos2d::Mat4 &transform, uint32_t flags)
{
	if (_texture == nullptr)
		return;

	GL::blendFunc(GL_ONE, GL_ZERO);

	GL::bindTexture2D(_texture->getName());

	if (_drawHandler)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		s_mat4_to_luaval(pStack->getLuaState(), transform);
		pStack->pushInt(flags);
		pStack->executeFunctionByHandler(_drawHandler, 2);
		pStack->clean();
	}
	else
	{
		auto glProgram = getGLProgram();
		glProgram->use();
		glProgram->setUniformsForBuiltins(transform);
	}

	GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POS_COLOR_TEX);

	glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 0, _vVertices);

	GLubyte fColor[] = {
		_displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity,
		_displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity,
		_displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity,
		_displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity,
	};
	glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, fColor);

	glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_TEX_COORD, 2, GL_FLOAT, GL_FALSE, 0, _fvTexture);

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	CC_INCREMENT_GL_DRAWN_BATCHES_AND_VERTICES(1, 4);
}

