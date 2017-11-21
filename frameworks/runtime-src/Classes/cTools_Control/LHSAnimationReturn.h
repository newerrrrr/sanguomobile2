#ifndef __LHSANIMATIONRETURN_H__
#define __LHSANIMATIONRETURN_H__

#include "cocos2d.h"

/********
fps动画返回
********/
class LHSAnimationReturn : public cocos2d::Ref
{
	friend class LHSAnimation;
public:
	LHSAnimationReturn();
	~LHSAnimationReturn();

	static LHSAnimationReturn * create();

	//总帧数
	int GetTotalFrameNum(){return m_TotalFrameNum;}

	//总时间
	float GetTotalTime(){return m_TotalTime;}

	//帧率
	float GetFps(){return m_Fps;}

private:
	int m_TotalFrameNum;
	float m_TotalTime;
	float m_Fps;
};



#endif  // __LHSANIMATIONRETURN_H__