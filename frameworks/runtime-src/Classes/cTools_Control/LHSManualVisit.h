#ifndef __LHSMANUALVISIT_H__
#define __LHSMANUALVISIT_H__

#include "cocos2d.h"

class LHSManualVisitNode : public cocos2d::Node
{
public:
	LHSManualVisitNode();
	~LHSManualVisitNode();

	static LHSManualVisitNode * create();

	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)override;

public:
	void setManualVisible(bool v);
	bool isManualVisible();

protected:
	bool _manualVisible;
};


class LHSManualVisitLayer : public cocos2d::Layer
{
public:
	LHSManualVisitLayer();
	~LHSManualVisitLayer();

	static LHSManualVisitLayer *create();

	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)override;

public:
	void setManualVisible(bool v);
	bool isManualVisible();

protected:
	bool _manualVisible;
};


#endif //__LHSMANUALVISIT_H__