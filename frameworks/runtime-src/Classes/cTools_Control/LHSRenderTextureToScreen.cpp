#include "LHSRenderTextureToScreen.h"

USING_NS_CC;


LHSRenderTextureToScreen::LHSRenderTextureToScreen()
	:_texture(nullptr)
{
	_vVertices[0] = 0.0f;
	_vVertices[1] = _contentSize.height;
	_vVertices[2] = 0.0f;

	_vVertices[3] = 0.0f;
	_vVertices[4] = 0.0f;
	_vVertices[5] = 0.0f;

	_vVertices[6] = _contentSize.width;
	_vVertices[7] = _contentSize.height;
	_vVertices[8] = 0.0f;

	_vVertices[9] = _contentSize.width;
	_vVertices[10] = 0.0f;
	_vVertices[11] = 0.0f;

	_fvTexture[0] = 0.0f;
	_fvTexture[1] = 1.0f;

	_fvTexture[2] = 0.0f;
	_fvTexture[3] = 0.0f;

	_fvTexture[4] = 1.0f;
	_fvTexture[5] = 1.0f;

	_fvTexture[6] = 1.0f;
	_fvTexture[7] = 0.0f;
}


LHSRenderTextureToScreen::~LHSRenderTextureToScreen()
{
	CC_SAFE_RELEASE_NULL(_texture);
}


LHSRenderTextureToScreen * LHSRenderTextureToScreen::create(cocos2d::RenderTexture * rt)
{
	LHSRenderTextureToScreen * ret = new (std::nothrow) LHSRenderTextureToScreen();
	if (ret && ret->initWithRenderTexture(rt))
	{
		ret->autorelease();
		return ret;
	}
	if (ret)
		delete ret;
	return nullptr;
}

bool LHSRenderTextureToScreen::initWithRenderTexture(cocos2d::RenderTexture * rt)
{
	if (!Node::init())
		return false;

	this->setGLProgramState(GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR));
	this->ignoreAnchorPointForPosition(false);
	this->setAnchorPoint(Vec2::ZERO);
	this->setPosition(Vec2::ZERO);
	cocos2d::Texture2D * texture = rt->getSprite()->getTexture();
	Node::setContentSize(texture->getContentSize());

	CC_SAFE_RETAIN(texture);
	CC_SAFE_RELEASE(_texture);
	_texture = texture;

	_vVertices[0] = 0.0f;
	_vVertices[1] = _contentSize.height;
	_vVertices[2] = 0.0f;

	_vVertices[3] = 0.0f;
	_vVertices[4] = 0.0f;
	_vVertices[5] = 0.0f;

	_vVertices[6] = _contentSize.width;
	_vVertices[7] = _contentSize.height;
	_vVertices[8] = 0.0f;

	_vVertices[9] = _contentSize.width;
	_vVertices[10] = 0.0f;
	_vVertices[11] = 0.0f;

	return true;
}


void LHSRenderTextureToScreen::setContentSize(const Size& contentSize)
{
	CCAssert(false, "");
}


void LHSRenderTextureToScreen::draw(Renderer *renderer, const Mat4& transform, uint32_t flags)
{
	_customCommand.init(_globalZOrder, Mat4::IDENTITY, flags);
	_customCommand.func = CC_CALLBACK_0(LHSRenderTextureToScreen::onDraw, this, Mat4::IDENTITY, flags);
	renderer->addCommand(&_customCommand);
}

void LHSRenderTextureToScreen::onDraw(const Mat4 &transform, uint32_t flags)
{
	if (_texture == nullptr)
		return;

	GL::blendFunc(GL_ONE, GL_ZERO);

	GL::bindTexture2D(_texture->getName());

	auto glProgram = getGLProgram();
	glProgram->use();
	glProgram->setUniformsForBuiltins(transform);

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


void LHSRenderTextureToScreen::setFlippedY(bool flippedY)
{
	if (flippedY)
	{
		_fvTexture[0] = 0.0f;
		_fvTexture[1] = 1.0f;

		_fvTexture[2] = 0.0f;
		_fvTexture[3] = 0.0f;

		_fvTexture[4] = 1.0f;
		_fvTexture[5] = 1.0f;

		_fvTexture[6] = 1.0f;
		_fvTexture[7] = 0.0f;
	}
	else
	{
		_fvTexture[0] = 0.0f;
		_fvTexture[1] = 0.0f;

		_fvTexture[2] = 0.0f;
		_fvTexture[3] = 1.0f;

		_fvTexture[4] = 1.0f;
		_fvTexture[5] = 0.0f;

		_fvTexture[6] = 1.0f;
		_fvTexture[7] = 1.0f;
	}
}
