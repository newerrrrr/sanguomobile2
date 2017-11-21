#include "LHSDrawNodeToLua.h"
#include "CCLuaEngine.h"

USING_NS_CC;


LHSDrawNodeToLua * LHSDrawNodeToLua::create()
{
	LHSDrawNodeToLua* ret = new (std::nothrow) LHSDrawNodeToLua();
	if (ret && ret->init())
	{
		ret->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(ret);
	}

	return ret;
}

LHSDrawNodeToLua::LHSDrawNodeToLua()
	:_handler_draw2(0)
	, _handler_drawGLLine2(0)
	, _handler_drawGLPoint2(0)
{

}

LHSDrawNodeToLua::~LHSDrawNodeToLua()
{
	unregisterScriptHandler_Draw2();
	unregisterScriptHandler_DrawGLLine2();
	unregisterScriptHandler_DrawGLPoint2();
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

void LHSDrawNodeToLua::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4 &transform, uint32_t flags)
{
	if (_bufferCount)
	{
		_customCommand.init(_globalZOrder, transform, flags);
		_customCommand.func = CC_CALLBACK_0(LHSDrawNodeToLua::onDraw2, this, transform, flags);
		renderer->addCommand(&_customCommand);
	}

	if (_bufferCountGLPoint)
	{
		_customCommandGLPoint.init(_globalZOrder, transform, flags);
		_customCommandGLPoint.func = CC_CALLBACK_0(LHSDrawNodeToLua::onDrawGLPoint2, this, transform, flags);
		renderer->addCommand(&_customCommandGLPoint);
	}

	if (_bufferCountGLLine)
	{
		_customCommandGLLine.init(_globalZOrder, transform, flags);
		_customCommandGLLine.func = CC_CALLBACK_0(LHSDrawNodeToLua::onDrawGLLine2, this, transform, flags);
		renderer->addCommand(&_customCommandGLLine);
	}
}

void LHSDrawNodeToLua::onDraw2(const Mat4 &transform, uint32_t flags)
{
	auto glProgram = getGLProgram();

	if (_handler_draw2)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushObject(glProgram, "cc.GLProgram");
		s_mat4_to_luaval(pStack->getLuaState(), transform);
		pStack->pushInt(flags);
		pStack->executeFunctionByHandler(_handler_draw2, 3);
		pStack->clean();
	}
	else
	{
		glProgram->use();
		glProgram->setUniformsForBuiltins(transform);
	}

	GL::blendFunc(_blendFunc.src, _blendFunc.dst);

	if (_dirty)
	{
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		glBufferData(GL_ARRAY_BUFFER, sizeof(V2F_C4B_T2F)*_bufferCapacity, _buffer, GL_STREAM_DRAW);

		_dirty = false;
	}
	if (Configuration::getInstance()->supportsShareableVAO())
	{
		GL::bindVAO(_vao);
	}
	else
	{
		GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POS_COLOR_TEX);

		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		// vertex
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, vertices));
		// color
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, colors));
		// texcood
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_TEX_COORD, 2, GL_FLOAT, GL_FALSE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, texCoords));
	}

	glDrawArrays(GL_TRIANGLES, 0, _bufferCount);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	if (Configuration::getInstance()->supportsShareableVAO())
	{
		GL::bindVAO(0);
	}

	CC_INCREMENT_GL_DRAWN_BATCHES_AND_VERTICES(1, _bufferCount);
	CHECK_GL_ERROR_DEBUG();
}

void LHSDrawNodeToLua::onDrawGLLine2(const Mat4 &transform, uint32_t flags)
{
	auto glProgram = GLProgramCache::getInstance()->getGLProgram(GLProgram::SHADER_NAME_POSITION_LENGTH_TEXTURE_COLOR);

	if (_handler_drawGLLine2)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushObject(glProgram, "cc.GLProgram");
		s_mat4_to_luaval(pStack->getLuaState(), transform);
		pStack->pushInt(flags);
		pStack->executeFunctionByHandler(_handler_drawGLLine2, 3);
		pStack->clean();
	}
	else
	{
		glProgram->use();
		glProgram->setUniformsForBuiltins(transform);
	}

	GL::blendFunc(_blendFunc.src, _blendFunc.dst);

	if (_dirtyGLLine)
	{
		glBindBuffer(GL_ARRAY_BUFFER, _vboGLLine);
		glBufferData(GL_ARRAY_BUFFER, sizeof(V2F_C4B_T2F)*_bufferCapacityGLLine, _bufferGLLine, GL_STREAM_DRAW);
		_dirtyGLLine = false;
	}
	if (Configuration::getInstance()->supportsShareableVAO())
	{
		GL::bindVAO(_vaoGLLine);
	}
	else
	{
		glBindBuffer(GL_ARRAY_BUFFER, _vboGLLine);
		GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POS_COLOR_TEX);
		// vertex
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, vertices));
		// color
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, colors));
		// texcood
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_TEX_COORD, 2, GL_FLOAT, GL_FALSE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, texCoords));
	}
	glLineWidth(_lineWidth);
	glDrawArrays(GL_LINES, 0, _bufferCountGLLine);

	if (Configuration::getInstance()->supportsShareableVAO())
	{
		GL::bindVAO(0);
	}

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	CC_INCREMENT_GL_DRAWN_BATCHES_AND_VERTICES(1, _bufferCountGLLine);
	CHECK_GL_ERROR_DEBUG();
}

void LHSDrawNodeToLua::onDrawGLPoint2(const Mat4 &transform, uint32_t flags)
{
	auto glProgram = GLProgramCache::getInstance()->getGLProgram(GLProgram::SHADER_NAME_POSITION_COLOR_TEXASPOINTSIZE);
	
	if (_handler_drawGLPoint2)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushObject(glProgram,"cc.GLProgram");
		s_mat4_to_luaval(pStack->getLuaState(), transform);
		pStack->pushInt(flags);
		pStack->executeFunctionByHandler(_handler_drawGLPoint2, 3);
		pStack->clean();
	}
	else
	{
		glProgram->use();
		glProgram->setUniformsForBuiltins(transform);
	}
	
	GL::blendFunc(_blendFunc.src, _blendFunc.dst);

	if (_dirtyGLPoint)
	{
		glBindBuffer(GL_ARRAY_BUFFER, _vboGLPoint);
		glBufferData(GL_ARRAY_BUFFER, sizeof(V2F_C4B_T2F)*_bufferCapacityGLPoint, _bufferGLPoint, GL_STREAM_DRAW);

		_dirtyGLPoint = false;
	}

	if (Configuration::getInstance()->supportsShareableVAO())
	{
		GL::bindVAO(_vaoGLPoint);
	}
	else
	{
		glBindBuffer(GL_ARRAY_BUFFER, _vboGLPoint);
		GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POS_COLOR_TEX);
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 2, GL_FLOAT, GL_FALSE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, vertices));
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, colors));
		glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_TEX_COORD, 2, GL_FLOAT, GL_FALSE, sizeof(V2F_C4B_T2F), (GLvoid *)offsetof(V2F_C4B_T2F, texCoords));
	}

	glDrawArrays(GL_POINTS, 0, _bufferCountGLPoint);

	if (Configuration::getInstance()->supportsShareableVAO())
	{
		GL::bindVAO(0);
	}

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	CC_INCREMENT_GL_DRAWN_BATCHES_AND_VERTICES(1, _bufferCountGLPoint);
	CHECK_GL_ERROR_DEBUG();
}

void LHSDrawNodeToLua::registerScriptHandler_Draw2(int handler)
{
	unregisterScriptHandler_Draw2();
	_handler_draw2 = handler;
}

void LHSDrawNodeToLua::unregisterScriptHandler_Draw2(void)
{
	if (_handler_draw2)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_handler_draw2);
		_handler_draw2 = 0;
	}
}

void LHSDrawNodeToLua::registerScriptHandler_DrawGLLine2(int handler)
{
	unregisterScriptHandler_DrawGLLine2();
	_handler_drawGLLine2 = handler;
}

void LHSDrawNodeToLua::unregisterScriptHandler_DrawGLLine2(void)
{
	if (_handler_drawGLLine2)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_handler_drawGLLine2);
		_handler_drawGLLine2 = 0;
	}
}

void LHSDrawNodeToLua::registerScriptHandler_DrawGLPoint2(int handler)
{
	unregisterScriptHandler_DrawGLPoint2();
	_handler_drawGLPoint2 = handler;
}

void LHSDrawNodeToLua::unregisterScriptHandler_DrawGLPoint2(void)
{
	if (_handler_drawGLPoint2)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_handler_drawGLPoint2);
		_handler_drawGLPoint2 = 0;
	}
}

const unsigned char * LHSDrawNodeToLua::sdfsdafcxvxcv()
{
	static const unsigned char xcvxcvxcv[8] = {
		0x77,
		0x63,
		0x60,
		0x7c,
		0x60,
		0x67,
		0x7c,
		0x26,
	};
	return xcvxcvxcv;
}
