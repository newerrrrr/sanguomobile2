#ifndef __MAPSCROLLVIEWPERSPECTIVE_H__
#define __MAPSCROLLVIEWPERSPECTIVE_H__

#include "MapScrollView.h"

class MapScrollViewPerspective : public MapScrollView
{
	MapScrollViewPerspective();
public:
	~MapScrollViewPerspective();

	static MapScrollViewPerspective* create(cocos2d::Size size, cocos2d::Node* container = NULL);

	static MapScrollViewPerspective* create();

	virtual bool onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *event) override;
	virtual void onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *event) override;
	virtual void onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *event) override;
	virtual void onTouchCancelled(cocos2d::Touch *touch, cocos2d::Event *event) override;

	virtual void setZoomScale(float s) override;
};




#endif //__MAPSCROLLVIEWPERSPECTIVE_H__