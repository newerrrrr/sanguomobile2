#include "MapScrollView.h"
#include "CCLuaEngine.h"
USING_NS_CC;
USING_NS_CC_EXT;

#define DEF_OFFSET_ACTION_TAG	(88451173)

#define BOUNCE_DURATION      0.15f

inline static Vec2 s_convertPointToNodeSpace(const Node * node, const Vec2 & position, const Camera * camera)
{
	const Mat4 w2n = node->getWorldToNodeTransform();
	Rect rect(Vec2::ZERO, node->getContentSize());
	if (camera == nullptr || rect.size.width <= 0 || rect.size.height <= 0)
		return Vec2(FLT_MAX, FLT_MAX);
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
		return Vec2(FLT_MAX, FLT_MAX);
	auto t = (BxC.dot(A) - BxC.dot(nearPos)) / BxCdotE;
	Vec3 P = nearPos + t * E;
	return Vec2(P.x, P.y);
}

MapScrollView::MapScrollView()
	:_isOpenParallelogramClamp(false)
	, _isCanZoomScale(true)
	, _boundaryHandler(0)
	, _isFullScreenTouch(false)
{
}

MapScrollView::~MapScrollView()
{
	unregisterScriptBoundaryHandler();
}

MapScrollView* MapScrollView::create(Size size, Node* container /*= NULL*/)
{
	MapScrollView* pRet = new (std::nothrow) MapScrollView();
	if (pRet && pRet->initWithViewSize(size, container))
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}

MapScrollView* MapScrollView::create()
{
	MapScrollView* pRet = new (std::nothrow) MapScrollView();
	if (pRet && pRet->init())
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}

void MapScrollView::addChild(Node * child, int zOrder, int tag)
{
	if (_container != child) {
		_container->addChild(child, zOrder, tag);
	}
	else {
		Layer::addChild(child, -1 , tag);
	}
}

void MapScrollView::addChild(Node * child, int zOrder, const std::string &name)
{
	if (_container != child)
	{
		_container->addChild(child, zOrder, name);
	}
	else
	{
		Layer::addChild(child, -1 , name);
	}
}

cocos2d::Vec2 MapScrollView::_testParallelogramClamp(const cocos2d::Vec2 & offset)
{
	const Camera * camera = Camera::getDefaultCamera();
	if (camera)
	{
		Vec2 center = camera->projectGL(this->convertToWorldSpace3D(Vec3(_viewSize.width / 2, _viewSize.height / 2, 0)));
		Vec2 oc = s_convertPointToNodeSpace(_container, center, camera);

		if (_parallelogramClamp.containsPoint(oc)) //如果已经出了边界就放弃处理了,使用时绝对避免这种情况发生
		{
			Vec2 originOffset = _container->getPosition();
			_container->setPosition(offset);
			Vec2 nc = s_convertPointToNodeSpace(_container, center, camera);
			_container->setPosition(originOffset);
			return (_parallelogramClamp.containsPoint(nc)) ? (offset) : (originOffset);
		}
	}
	return offset;
}

void MapScrollView::setContentOffset(Vec2 offset, bool animated /*= false*/)
{
	if (animated)
	{ //animate scrolling
		this->setContentOffsetInDuration(offset, BOUNCE_DURATION);
	}
	else
	{ //set the container position directly

		Vec2 wantOffset = offset;

		if (!_bounceable)
		{
			const Vec2 minOffset = this->minContainerOffset();
			const Vec2 maxOffset = this->maxContainerOffset();

			offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
			offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
		}

		if (_isOpenParallelogramClamp)
		{
			offset = _testParallelogramClamp(offset);
		}

		_container->setPosition(offset);

		if (_boundaryHandler && (wantOffset.x != offset.x || wantOffset.y != offset.y))
		{
			auto engine = LuaEngine::getInstance();
			auto pStack = engine->getLuaStack();
			pStack->pushInt(klhsManual);
			pStack->executeFunctionByHandler(_boundaryHandler, 1);
			pStack->clean();
		}

		if (_delegate != nullptr)
		{
			_delegate->scrollViewDidScroll(this);
		}
	}
}

void MapScrollView::setContentOffsetInDuration(cocos2d::Vec2 offset, float dt)
{
	Vec2 wantOffset = offset;

	if (_isOpenParallelogramClamp)
	{
		offset = _testParallelogramClamp(offset);
	}

	if (_boundaryHandler && (wantOffset.x != offset.x || wantOffset.y != offset.y))
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushInt(klhsDuration);
		pStack->executeFunctionByHandler(_boundaryHandler, 1);
		pStack->clean();
	}

	FiniteTimeAction *scroll, *expire;
	
	scroll = MoveTo::create(dt, offset);
	expire = CallFuncN::create(CC_CALLBACK_1(MapScrollView::stoppedAnimatedScroll, this));
	Action * action = Sequence::create(scroll, expire, nullptr);
	action->setTag(DEF_OFFSET_ACTION_TAG);
	_container->stopActionByTag(DEF_OFFSET_ACTION_TAG);
	_container->runAction(action);
	this->schedule(CC_SCHEDULE_SELECTOR(MapScrollView::performedAnimatedScroll));
}

void MapScrollView::setContentOffsetInDuration_EaseExponentialOut(Vec2 offset, float dt)
{
	Vec2 wantOffset = offset;

	if (_isOpenParallelogramClamp)
	{
		offset = _testParallelogramClamp(offset);
	}

	if (_boundaryHandler && (wantOffset.x != offset.x || wantOffset.y != offset.y))
	{
		auto engine = LuaEngine::getInstance();
		auto pStack = engine->getLuaStack();
		pStack->pushInt(klhsDuration);
		pStack->executeFunctionByHandler(_boundaryHandler, 1);
		pStack->clean();
	}

	FiniteTimeAction *scroll, *expire;

	scroll = EaseExponentialOut::create(MoveTo::create(dt, offset));
	expire = CallFuncN::create(CC_CALLBACK_1(MapScrollView::stoppedAnimatedScroll_2, this));
	Action * action = Sequence::create(scroll, expire, nullptr);
	action->setTag(DEF_OFFSET_ACTION_TAG);
	_container->stopActionByTag(DEF_OFFSET_ACTION_TAG);
	_container->runAction(action);
	this->schedule(CC_SCHEDULE_SELECTOR(MapScrollView::performedAnimatedScroll_2));
}

void MapScrollView::performedAnimatedScroll_2(float dt)
{
	if (_dragging)
	{
		this->unschedule(CC_SCHEDULE_SELECTOR(MapScrollView::performedAnimatedScroll_2));
		return;
	}

	if (_delegate != nullptr)
	{
		_delegate->scrollViewDidScroll(this);
	}
}

void MapScrollView::stoppedAnimatedScroll_2(Node * node)
{
	this->unschedule(CC_SCHEDULE_SELECTOR(MapScrollView::performedAnimatedScroll_2));
	if (_delegate != nullptr)
	{
		_delegate->scrollViewDidScroll(this);
	}
}

void MapScrollView::openParallelogramClamp(const cocos2d::Vec2 & posT, const cocos2d::Vec2 & posL, const cocos2d::Vec2 & posB, const cocos2d::Vec2 & posR)
{
	_isOpenParallelogramClamp = true;
	_parallelogramClamp._posT = posT;
	_parallelogramClamp._posL = posL;
	_parallelogramClamp._posB = posB;
	_parallelogramClamp._posR = posR;
}

void MapScrollView::closeParallelogramClamp()
{
	_isOpenParallelogramClamp = false;
}

void MapScrollView::registerScriptBoundaryHandler(int handler)
{
	unregisterScriptBoundaryHandler();
	_boundaryHandler = handler;
}

void MapScrollView::unregisterScriptBoundaryHandler(void)
{
	if (_boundaryHandler)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_boundaryHandler);
		_boundaryHandler = 0;
	}
}

void MapScrollView::setZoomScale(float s)
{
	if (_isCanZoomScale)
		ScrollView::setZoomScale(s);
}

bool MapScrollView::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *event)
{
	if (!this->isVisible() || !this->hasVisibleParents())
	{
		return false;
	}

	Rect frame = getViewRect();

	//dispatcher does not know about clipping. reject touches outside visible bounds.
	if (_touches.size() > 2 ||
		_touchMoved ||
		(!_isFullScreenTouch && !frame.containsPoint(touch->getLocation()))
		)
	{
		return false;
	}

	if (std::find(_touches.begin(), _touches.end(), touch) == _touches.end())
	{
		_touches.push_back(touch);
	}

	if (_touches.size() == 1)
	{ // scrolling
		_touchPoint = this->convertTouchToNodeSpace(touch);
		_touchMoved = false;
		_dragging = true; //dragging started
		_scrollDistance.setZero();
		_touchLength = 0.0f;
	}
	else if (_touches.size() == 2)
	{
		_touchPoint = (this->convertTouchToNodeSpace(_touches[0]).getMidpoint(
			this->convertTouchToNodeSpace(_touches[1])));

		_touchLength = _container->convertTouchToNodeSpace(_touches[0]).getDistance(
			_container->convertTouchToNodeSpace(_touches[1]));

		_dragging = false;
	}
	return true;
}
