#ifndef __MAPSCROLLVIEW_H__
#define __MAPSCROLLVIEW_H__

#include "cocos2d.h"
#include "cocos-ext.h"

#include "LHSTmxBaseLayer.h" //暂时这样引用一下,懒得定义类型了


class MapScrollView : public cocos2d::extension::ScrollView
{
protected:
	MapScrollView();
public:

	enum BoundaryType
	{
		klhsManual = 0,
		klhsDuration,
	};

	~MapScrollView();

	static MapScrollView* create(cocos2d::Size size, cocos2d::Node* container = NULL);

	static MapScrollView* create();

	virtual bool onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *event) override;

	virtual void addChild(cocos2d::Node * child, int zOrder, int tag) override;
	virtual void addChild(cocos2d::Node * child, int zOrder, const std::string &name) override;

	virtual void setContentOffset(cocos2d::Vec2 offset, bool animated = false) override;

	virtual void setContentOffsetInDuration(cocos2d::Vec2 offset, float dt)override;

	void setContentOffsetInDuration_EaseExponentialOut(cocos2d::Vec2 offset, float dt);

	void performedAnimatedScroll_2(float dt);

	void stoppedAnimatedScroll_2(cocos2d::Node* node);

	void openParallelogramClamp(const cocos2d::Vec2 & posT, const cocos2d::Vec2 & posL, const cocos2d::Vec2 & posB, const cocos2d::Vec2 & posR);

	void closeParallelogramClamp();

	void registerScriptBoundaryHandler(int handler);

	void unregisterScriptBoundaryHandler(void);

	void setCanZoomScale(bool var){ _isCanZoomScale = var; };

	virtual void setZoomScale(float s) override;

	void setIsFullScreenTouch(bool var){ _isFullScreenTouch = var; };

protected:
	cocos2d::Vec2 _testParallelogramClamp(const cocos2d::Vec2 & offset);

protected:
	bool _isCanZoomScale;
	bool _isFullScreenTouch;

private:
	bool _isOpenParallelogramClamp;
	LHSParallelogram _parallelogramClamp;
	int _boundaryHandler;
};




#endif //__MAPSCROLLVIEW_H__