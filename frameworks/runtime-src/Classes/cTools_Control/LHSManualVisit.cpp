#include "LHSManualVisit.h"

USING_NS_CC;

LHSManualVisitNode::LHSManualVisitNode()
	: _manualVisible(true)
{

}

LHSManualVisitNode::~LHSManualVisitNode()
{

}

LHSManualVisitNode * LHSManualVisitNode::create()
{
	LHSManualVisitNode * ret = new (std::nothrow) LHSManualVisitNode();
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

void LHSManualVisitNode::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
{
	if (!_manualVisible)
	{
		return;
	}
	Node::visit(renderer, parentTransform, parentFlags);
}

void LHSManualVisitNode::setManualVisible(bool v)
{
	_manualVisible = v;
}

bool LHSManualVisitNode::isManualVisible()
{
	return _manualVisible;
}




//////////////////////////////////////////////////////////////////////////

LHSManualVisitLayer::LHSManualVisitLayer()
	: _manualVisible(true)
{

}

LHSManualVisitLayer::~LHSManualVisitLayer()
{

}

LHSManualVisitLayer * LHSManualVisitLayer::create()
{
	LHSManualVisitLayer *ret = new (std::nothrow) LHSManualVisitLayer();
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

void LHSManualVisitLayer::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
{
	if (!_manualVisible)
	{
		return;
	}
	Layer::visit(renderer, parentTransform, parentFlags);
}

void LHSManualVisitLayer::setManualVisible(bool v)
{
	_manualVisible = v;
}

bool LHSManualVisitLayer::isManualVisible()
{
	return _manualVisible;
}