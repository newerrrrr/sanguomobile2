#include "LHSAnimation.h"

using namespace cocos2d;

LHSAnimation::LHSAnimation()
{
}

LHSAnimation::~LHSAnimation()
{
}

cocos2d::Animate* LHSAnimation::createFrameAnimationWithIdOrder(const char * prefixionName, float fps /*= 0.0666666666666667f*/, bool isOriginalFrame /*= true*/, LHSAnimationReturn * out_data /*= nullptr*/, int startID /*= 1*/)
{
	Vector<SpriteFrame *> ArrayFrames;
	char filename[260] = { 0 };
	int i = startID;
	for (; true; i++)
	{
		sprintf(filename, "%s%d.png", prefixionName, i);
		SpriteFrame * pSpriteFrame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName(filename);
		if (!pSpriteFrame)
			break;
		ArrayFrames.pushBack(pSpriteFrame);
	}
	Animation* animation = Animation::createWithSpriteFrames(ArrayFrames, fps);
	animation->setRestoreOriginalFrame(isOriginalFrame);
	if (out_data)
	{
		out_data->m_Fps = fps;
		out_data->m_TotalFrameNum = i - 1;
		out_data->m_TotalTime = ((float)out_data->m_TotalFrameNum) * out_data->m_Fps;
	}
	return Animate::create(animation);
}