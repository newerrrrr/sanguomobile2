#include "LHSTools.h"

USING_NS_CC;


bool LHSTools::checkInSceneOrder(cocos2d::Node * node)
{
	Node * runScene = Director::getInstance()->getRunningScene();
	if (runScene)
	{
		for (Node * p = node; p; p = p->getParent())
			if (runScene == p)
				return true;
	}
	return false;
}

bool LHSTools::checkAncestorsVisible(cocos2d::Node * node)
{
	if (nullptr == node)
		return true;
	Node* parent = node->getParent();
	if (parent && !parent->isVisible())
		return false;
	return LHSTools::checkAncestorsVisible(parent);
}


bool LHSTools::checkTouchInSelf(cocos2d::Node * node, cocos2d::Touch * touch)
{
	Rect rect(Vec2::ZERO, node->getContentSize());
	return rect.containsPoint(node->convertToNodeSpace(touch->getLocation()));
}

bool LHSTools::checkTouchInSelf_3D(cocos2d::Node * node, cocos2d::Touch * touch)
{
	Vec2 nodeSpacePos = Vec2(FLT_MAX, FLT_MAX);
	const Camera * camera = Camera::getVisitingCamera();
	if (camera == nullptr)
		camera = Camera::getDefaultCamera();
	const Mat4 w2n = node->getWorldToNodeTransform();
	Rect rect(Vec2::ZERO, node->getContentSize());
	if (camera == nullptr || rect.size.width <= 0 || rect.size.height <= 0)
	{
		return false;
	}
	else
	{
		Vec2 position = touch->getLocation();
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
			return false;
		}
		else
		{
			auto t = (BxC.dot(A) - BxC.dot(nearPos)) / BxCdotE;
			Vec3 P = nearPos + t * E;
			nodeSpacePos.setPoint(P.x, P.y);
		}
	}
	return rect.containsPoint(nodeSpacePos);
}
