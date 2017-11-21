#include "LHSCustomShaderSprite.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"

USING_NS_CC;

LHSCustomShaderSprite::LHSCustomShaderSprite()
	:_beforeDrawHandler(0)
{

}

LHSCustomShaderSprite::~LHSCustomShaderSprite()
{
	unregisterScriptBeforeDrawHandler();
}


LHSCustomShaderSprite* LHSCustomShaderSprite::createWithTexture(Texture2D *texture)
{
	LHSCustomShaderSprite *sprite = new (std::nothrow) LHSCustomShaderSprite();
	if (sprite && sprite->initWithTexture(texture))
	{
		sprite->autorelease();
		return sprite;
	}
	CC_SAFE_DELETE(sprite);
	return nullptr;
}

LHSCustomShaderSprite* LHSCustomShaderSprite::createWithTexture(Texture2D *texture, const Rect& rect, bool rotated)
{
	LHSCustomShaderSprite *sprite = new (std::nothrow) LHSCustomShaderSprite();
	if (sprite && sprite->initWithTexture(texture, rect, rotated))
	{
		sprite->autorelease();
		return sprite;
	}
	CC_SAFE_DELETE(sprite);
	return nullptr;
}

LHSCustomShaderSprite* LHSCustomShaderSprite::create(const std::string& filename)
{
	LHSCustomShaderSprite *sprite = new (std::nothrow) LHSCustomShaderSprite();
	if (sprite && sprite->initWithFile(filename))
	{
		sprite->autorelease();
		return sprite;
	}
	CC_SAFE_DELETE(sprite);
	return nullptr;
}

LHSCustomShaderSprite* LHSCustomShaderSprite::create(const std::string& filename, const Rect& rect)
{
	LHSCustomShaderSprite *sprite = new (std::nothrow) LHSCustomShaderSprite();
	if (sprite && sprite->initWithFile(filename, rect))
	{
		sprite->autorelease();
		return sprite;
	}
	CC_SAFE_DELETE(sprite);
	return nullptr;
}

LHSCustomShaderSprite* LHSCustomShaderSprite::createWithSpriteFrame(SpriteFrame *spriteFrame)
{
	LHSCustomShaderSprite *sprite = new (std::nothrow) LHSCustomShaderSprite();
	if (sprite && spriteFrame && sprite->initWithSpriteFrame(spriteFrame))
	{
		sprite->autorelease();
		return sprite;
	}
	CC_SAFE_DELETE(sprite);
	return nullptr;
}

LHSCustomShaderSprite* LHSCustomShaderSprite::createWithSpriteFrameName(const std::string& spriteFrameName)
{
	SpriteFrame *frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(spriteFrameName);

#if COCOS2D_DEBUG > 0
	char msg[256] = { 0 };
	sprintf(msg, "Invalid spriteFrameName: %s", spriteFrameName.c_str());
	CCASSERT(frame != nullptr, msg);
#endif

	return createWithSpriteFrame(frame);
}

LHSCustomShaderSprite* LHSCustomShaderSprite::create()
{
	LHSCustomShaderSprite *sprite = new (std::nothrow) LHSCustomShaderSprite();
	if (sprite && sprite->init())
	{
		sprite->autorelease();
		return sprite;
	}
	CC_SAFE_DELETE(sprite);
	return nullptr;
}

void LHSCustomShaderSprite::registerScriptBeforeDrawHandler(int handler)
{
	unregisterScriptBeforeDrawHandler();
	_beforeDrawHandler = handler;
}

void LHSCustomShaderSprite::unregisterScriptBeforeDrawHandler(void)
{
	if (_beforeDrawHandler)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_beforeDrawHandler);
		_beforeDrawHandler = 0;
	}
}

void LHSCustomShaderSprite::draw(Renderer *renderer, const Mat4 &transform, uint32_t flags)
{
	if (_texture == nullptr)
		return;

	if (_polyInfo.triangles.vertCount != 4)
		return;

	GLProgramState * glProgramState = getGLProgramState();

	if (glProgramState == nullptr)
		return;

	_beforeDrawCommand.init(_globalZOrder, transform, flags);
	_beforeDrawCommand.func = CC_CALLBACK_0(LHSCustomShaderSprite::onBeforeDraw, this, glProgramState);
	renderer->addCommand(&_beforeDrawCommand);

	_trianglesCommand.init(_globalZOrder, _texture->getName(), getGLProgramState(), _blendFunc, _polyInfo.triangles, transform, flags);
	renderer->addCommand(&_trianglesCommand);
}


void LHSCustomShaderSprite::onBeforeDraw(GLProgramState * glProgramState)
{
	if (_beforeDrawHandler)
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushObject(glProgramState, "cc.GLProgramState");
		pStack->executeFunctionByHandler(_beforeDrawHandler, 1);
		pStack->clean();
	}
	
	//auto glProgram = glProgramState->getGLProgram();
	//glProgram->use();
	//glProgram->setUniformsForBuiltins(transform);

	//GL::blendFunc(blendFunc.src, blendFunc.dst);

	//GL::bindTexture2D(textureName);

	//GL::enableVertexAttribs(GL::VERTEX_ATTRIB_FLAG_POS_COLOR_TEX);

	//glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, sizeof(V3F_C4B_T2F), (GLvoid*)(&(_polyInfo.triangles.verts[0].vertices)) );

	//glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(V3F_C4B_T2F), (GLvoid*)(&(_polyInfo.triangles.verts[0].colors)) );

	//glVertexAttribPointer(GLProgram::VERTEX_ATTRIB_TEX_COORD, 2, GL_FLOAT, GL_FALSE, sizeof(V3F_C4B_T2F), (GLvoid*)(&(_polyInfo.triangles.verts[0].texCoords)) );

	//glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	//CC_INCREMENT_GL_DRAWN_BATCHES_AND_VERTICES(1, 4);
}
