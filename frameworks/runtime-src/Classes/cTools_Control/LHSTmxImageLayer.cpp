#include "LHSTmxImageLayer.h"

USING_NS_CC;

LHSTmxImageLayer::LHSTmxImageLayer()
	: _isVisibleOperat(false)
	, _offsetSizeVO(Size::ZERO)
{
}

LHSTmxImageLayer::~LHSTmxImageLayer()
{
}

LHSTmxImageLayer* LHSTmxImageLayer::create()
{
	LHSTmxImageLayer * imageLayer = new (std::nothrow) LHSTmxImageLayer();
	if (imageLayer && imageLayer->init())
	{
		imageLayer->autorelease();
		return imageLayer;
	}
	CC_SAFE_DELETE(imageLayer);
	return nullptr;
}

LHSTmxImageLayer* LHSTmxImageLayer::createWithTexture(Texture2D *texture)
{
	LHSTmxImageLayer * imageLayer = new (std::nothrow) LHSTmxImageLayer();
	if (imageLayer && imageLayer->initWithTexture(texture))
	{
		imageLayer->autorelease();
		return imageLayer;
	}
	CC_SAFE_DELETE(imageLayer);
	return nullptr;
}

void LHSTmxImageLayer::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
{
	if (!_visible)
	{
		return;
	}
	if (_isVisibleOperat)
	{
		const Camera * camera = Camera::getVisitingCamera();
		if (camera)
		{
			Size contentSize = this->getContentSize();
			Vec2 wlt = camera->projectGL(this->convertToWorldSpace3D(Vec3(0, contentSize.height, 0)));
			Vec2 wlb = camera->projectGL(this->convertToWorldSpace3D(Vec3::ZERO));
			Vec2 wrt = camera->projectGL(this->convertToWorldSpace3D(Vec3(contentSize.width, contentSize.height, 0)));
			Vec2 wrb = camera->projectGL(this->convertToWorldSpace3D(Vec3(contentSize.width, 0, 0)));
			Director * director = Director::getInstance();
			Rect(Vec2(_offsetSizeVO.width*-1.0f, _offsetSizeVO.height*-1.0f), director->getWinSize() + _offsetSizeVO * 2);
			float x = MIN(MIN(wlt.x, wlb.x), MIN(wrt.x, wrb.x));
			float y = MIN(MIN(wlt.y, wlb.y), MIN(wrt.y, wrb.y));
			float w = MAX(MAX(wlt.x, wlb.x), MAX(wrt.x, wrb.x)) - x;
			float h = MAX(MAX(wlt.y, wlb.y), MAX(wrt.y, wrb.y)) - y;
			if (!Rect(Vec2(_offsetSizeVO.width*-1.0f, _offsetSizeVO.height*-1.0f), director->getWinSize() + _offsetSizeVO * 2).intersectsRect(Rect(x, y, w, h)))
				return;
		}
	}
	Sprite::visit(renderer, parentTransform, parentFlags);
}

void LHSTmxImageLayer::setVisibleOperat(bool isOpen, cocos2d::Size offsetSize /*= Size::ZERO*/)
{
	_isVisibleOperat = isOpen;
	_offsetSizeVO = offsetSize;
}
