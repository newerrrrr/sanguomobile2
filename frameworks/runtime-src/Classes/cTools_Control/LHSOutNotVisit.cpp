#include "LHSOutNotVisit.h"

USING_NS_CC;

LHSOutNotVisitNode::LHSOutNotVisitNode()
	: _isVisibleOperat(true)
	, _offsetSizeVO(Size::ZERO)
{

}

LHSOutNotVisitNode::~LHSOutNotVisitNode()
{

}

LHSOutNotVisitNode * LHSOutNotVisitNode::create()
{
	LHSOutNotVisitNode * ret = new (std::nothrow) LHSOutNotVisitNode();
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

void LHSOutNotVisitNode::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
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
	Node::visit(renderer, parentTransform, parentFlags);
}

void LHSOutNotVisitNode::setVisibleOperat(bool isOpen, cocos2d::Size offsetSize /*= Size::ZERO*/)
{
	_isVisibleOperat = isOpen;
	_offsetSizeVO = offsetSize;
}




//////////////////////////////////////////////////////////////////////////

LHSOutNotVisitLayer::LHSOutNotVisitLayer()
	: _isVisibleOperat(true)
	, _offsetSizeVO(Size::ZERO)
{

}

LHSOutNotVisitLayer::~LHSOutNotVisitLayer()
{

}

LHSOutNotVisitLayer * LHSOutNotVisitLayer::create()
{
	LHSOutNotVisitLayer *ret = new (std::nothrow) LHSOutNotVisitLayer();
	if (ret && ret->init())
	{
		ret->autorelease();
		return ret;
	}
	else
	{
		CC_SAFE_DELETE(ret);
		return nullptr;
	}
}

void LHSOutNotVisitLayer::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
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
	Layer::visit(renderer, parentTransform, parentFlags);
}

void LHSOutNotVisitLayer::setVisibleOperat(bool isOpen, cocos2d::Size offsetSize /*= Size::ZERO*/)
{
	_isVisibleOperat = isOpen;
	_offsetSizeVO = offsetSize;
}
