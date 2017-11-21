#ifndef __LHSSchedulerActionManager_H__
#define __LHSSchedulerActionManager_H__

#include "cocos2d.h"
/*************
Author: 李寒松
*************/
/****************************
独立的时间步以及动作管理
方便独立模块的加速减速暂停
此对象必须释放
****************************/

class LHSSchedulerActionManager
{
public:
	LHSSchedulerActionManager();
	~LHSSchedulerActionManager();

	static LHSSchedulerActionManager * newSchedulerActionManage();

	void deleteSchedulerActionManage();

	cocos2d::Scheduler * getScheduler();

	void resetNodeSchedulerAndActionManage(cocos2d::Node * node);

	void setScaleTime(float s);

	float getScaleTime();

	void pause();

	void resume();

private:
	cocos2d::Scheduler * m_Scheduler;
	cocos2d::ActionManager * m_ActionManager;
};

#endif //__LHSSchedulerActionManager_H__