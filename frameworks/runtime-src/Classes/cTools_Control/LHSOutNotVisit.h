#ifndef __LHSOUTNOTVISIT_H__
#define __LHSOUTNOTVISIT_H__

#include "cocos2d.h"

class LHSOutNotVisitNode : public cocos2d::Node
{
public:
	LHSOutNotVisitNode();
	~LHSOutNotVisitNode();

	static LHSOutNotVisitNode * create();

	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)override;

public:
	virtual void setVisibleOperat(bool isOpen, cocos2d::Size offsetSize = cocos2d::Size::ZERO);

protected:
	bool _isVisibleOperat;
	cocos2d::Size _offsetSizeVO;
};


class LHSOutNotVisitLayer : public cocos2d::Layer
{
public:
	LHSOutNotVisitLayer();
	~LHSOutNotVisitLayer();

	static LHSOutNotVisitLayer *create();

	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)override;

public:
	virtual void setVisibleOperat(bool isOpen, cocos2d::Size offsetSize = cocos2d::Size::ZERO);

protected:
	bool _isVisibleOperat;
	cocos2d::Size _offsetSizeVO;
};


#endif //__LHSOUTNOTVISIT_H__