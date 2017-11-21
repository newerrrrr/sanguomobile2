#include "MapScrollViewPerspective.h"
#include "CCLuaEngine.h"
USING_NS_CC;
USING_NS_CC_EXT;

#define MOVE_INCH            7.0f/160.0f
#define BOUNCE_BACK_FACTOR   0.35f

static float convertDistanceFromPointToInch(float pointDis)
{
	auto glview = Director::getInstance()->getOpenGLView();
	float factor = (glview->getScaleX() + glview->getScaleY()) / 2;
	return pointDis * factor / Device::getDPI();
}

inline static Vec2 s_convertTouchToNodeSpace(const Node * node, const Touch * touch, const Camera * camera)
{
	Vec2 position = touch->getLocation();
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


MapScrollViewPerspective::MapScrollViewPerspective()
{
}

MapScrollViewPerspective::~MapScrollViewPerspective()
{
}

MapScrollViewPerspective* MapScrollViewPerspective::create(Size size, Node* container /*= NULL*/)
{
	MapScrollViewPerspective* pRet = new (std::nothrow) MapScrollViewPerspective();
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

MapScrollViewPerspective* MapScrollViewPerspective::create()
{
	MapScrollViewPerspective* pRet = new (std::nothrow) MapScrollViewPerspective();
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


bool MapScrollViewPerspective::onTouchBegan(Touch* touch, Event* event)
{
	if (!this->isVisible() || !this->hasVisibleParents())
	{
		return false;
	}

	//dispatcher does not know about clipping. reject touches outside visible bounds.
	if (_touches.size() > 2 ||
		_touchMoved)
	{
		return false;
	}

	if (!_isFullScreenTouch)
	{
		Rect rect(Vec2::ZERO, _viewSize);
		Vec2 pos = s_convertTouchToNodeSpace(this, touch, Camera::getVisitingCamera());
		if (!rect.containsPoint(pos))
			return false;
	}

	if (std::find(_touches.begin(), _touches.end(), touch) == _touches.end())
	{
		_touches.push_back(touch);
	}

	if (_touches.size() == 1)
	{ // scrolling
		_touchPoint = s_convertTouchToNodeSpace(this, touch, Camera::getVisitingCamera());
		_touchMoved = false;
		_dragging = true; //dragging started
		_scrollDistance.setZero();
		_touchLength = 0.0f;
	}
	else if (_touches.size() == 2)
	{
		_touchPoint = (s_convertTouchToNodeSpace(this, _touches[0], Camera::getVisitingCamera()).getMidpoint(
			s_convertTouchToNodeSpace(this, _touches[1], Camera::getVisitingCamera())));

		_touchLength = s_convertTouchToNodeSpace(_container, _touches[0], Camera::getVisitingCamera()).getDistance(
			s_convertTouchToNodeSpace(_container, _touches[1], Camera::getVisitingCamera()));

		_dragging = false;
	}
	return true;
}

void MapScrollViewPerspective::onTouchMoved(Touch* touch, Event* event)
{
	if (!this->isVisible())
	{
		return;
	}

	if (std::find(_touches.begin(), _touches.end(), touch) != _touches.end())
	{
		if (_touches.size() == 1 && _dragging)
		{ // scrolling
			Vec2 moveDistance, newPoint;
			//Rect  frame;
			float newX, newY;

			//frame = getViewRect();

			newPoint = s_convertTouchToNodeSpace(this, _touches[0], Camera::getVisitingCamera());
			moveDistance = newPoint - _touchPoint;

			float dis = 0.0f;
			if (_direction == Direction::VERTICAL)
			{
				dis = moveDistance.y;
				float pos = _container->getPosition().y;
				if (!(minContainerOffset().y <= pos && pos <= maxContainerOffset().y)) {
					moveDistance.y *= BOUNCE_BACK_FACTOR;
				}
			}
			else if (_direction == Direction::HORIZONTAL)
			{
				dis = moveDistance.x;
				float pos = _container->getPosition().x;
				if (!(minContainerOffset().x <= pos && pos <= maxContainerOffset().x)) {
					moveDistance.x *= BOUNCE_BACK_FACTOR;
				}
			}
			else
			{
				dis = sqrtf(moveDistance.x*moveDistance.x + moveDistance.y*moveDistance.y);

				float pos = _container->getPosition().y;
				if (!(minContainerOffset().y <= pos && pos <= maxContainerOffset().y)) {
					moveDistance.y *= BOUNCE_BACK_FACTOR;
				}

				pos = _container->getPosition().x;
				if (!(minContainerOffset().x <= pos && pos <= maxContainerOffset().x)) {
					moveDistance.x *= BOUNCE_BACK_FACTOR;
				}
			}

			if (!_touchMoved && fabs(convertDistanceFromPointToInch(dis)) < MOVE_INCH)
			{
				//CCLOG("Invalid movement, distance = [%f, %f], disInch = %f", moveDistance.x, moveDistance.y);
				return;
			}

			if (!_touchMoved)
			{
				moveDistance.setZero();
			}

			_touchPoint = newPoint;
			_touchMoved = true;

			if (_dragging)
			{
				switch (_direction)
				{
				case Direction::VERTICAL:
					moveDistance.set(0.0f, moveDistance.y);
					break;
				case Direction::HORIZONTAL:
					moveDistance.set(moveDistance.x, 0.0f);
					break;
				default:
					break;
				}

				newX = _container->getPosition().x + moveDistance.x;
				newY = _container->getPosition().y + moveDistance.y;

				_scrollDistance = moveDistance;
				this->setContentOffset(Vec2(newX, newY));
			}
		}
		else if (_touches.size() == 2 && !_dragging)
		{
			const float len = s_convertTouchToNodeSpace(_container, _touches[0], Camera::getVisitingCamera()).getDistance(
				s_convertTouchToNodeSpace(_container, _touches[1], Camera::getVisitingCamera()));
			this->setZoomScale(this->getZoomScale()*len / _touchLength);
		}
	}
}

void MapScrollViewPerspective::onTouchEnded(Touch* touch, Event* event)
{
	if (!this->isVisible())
	{
		return;
	}

	auto touchIter = std::find(_touches.begin(), _touches.end(), touch);

	if (touchIter != _touches.end())
	{
		if (_touches.size() == 1 && _touchMoved)
		{
			this->schedule(CC_SCHEDULE_SELECTOR(MapScrollViewPerspective::deaccelerateScrolling));
		}
		_touches.erase(touchIter);
	}

	if (_touches.size() == 0)
	{
		_dragging = false;
		_touchMoved = false;
	}
}

void MapScrollViewPerspective::onTouchCancelled(Touch* touch, Event* event)
{
	if (!this->isVisible())
	{
		return;
	}

	auto touchIter = std::find(_touches.begin(), _touches.end(), touch);
	_touches.erase(touchIter);

	if (_touches.size() == 0)
	{
		_dragging = false;
		_touchMoved = false;
	}
}

void MapScrollViewPerspective::setZoomScale(float s)
{
	if (!_isCanZoomScale)
		return;

	if (_container->getScale() != s)
	{
		const Camera * camera = Camera::getDefaultCamera();

		if (!camera)
			return;

		Vec2 center;

		if (_touchLength == 0.0f)
		{
			center.set(_viewSize.width*0.5f, _viewSize.height*0.5f);
			center = camera->projectGL(this->convertToWorldSpace3D(Vec3(center.x, center.y, 0)));
		}
		else
		{
			center = _touchPoint;
			center = camera->projectGL(this->convertToWorldSpace3D(Vec3(center.x, center.y, 0)));
		}

		Vec2 oldCenter = s_convertPointToNodeSpace(_container, center, camera);
		_container->setScale(MAX(_minScale, MIN(_maxScale, s)));
		Vec2 newCenter = s_convertPointToNodeSpace(_container, center, camera);

		const Vec2 offset = newCenter - oldCenter;

		if (_delegate != nullptr)
		{
			_delegate->scrollViewDidZoom(this);
		}

		this->setContentOffset(_container->getPosition() + offset * _container->getScale());
	}
}
