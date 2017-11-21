#include "LHSSchedulerActionManager.h"

using namespace cocos2d;

LHSSchedulerActionManager::LHSSchedulerActionManager()
{
	m_Scheduler = new Scheduler();
	Director::getInstance()->getScheduler()->scheduleUpdate(m_Scheduler, 0, false);
	m_ActionManager = new ActionManager();
	m_Scheduler->scheduleUpdate(m_ActionManager, 0, false);
}

LHSSchedulerActionManager::~LHSSchedulerActionManager()
{
	m_Scheduler->unscheduleUpdate(m_ActionManager);
	m_ActionManager->release();
	CCDirector::getInstance()->getScheduler()->unscheduleAllForTarget(m_Scheduler);
	m_Scheduler->release();
}

LHSSchedulerActionManager * LHSSchedulerActionManager::newSchedulerActionManage()
{
	LHSSchedulerActionManager * ret = new LHSSchedulerActionManager();
	return ret;
}

void LHSSchedulerActionManager::deleteSchedulerActionManage()
{
	delete this;
}

Scheduler * LHSSchedulerActionManager::getScheduler()
{
	return m_Scheduler;
}

void LHSSchedulerActionManager::resetNodeSchedulerAndActionManage(Node * node)
{
	if(node)
	{
		node->setScheduler(m_Scheduler);
		node->setActionManager(m_ActionManager);
	}
}

void LHSSchedulerActionManager::setScaleTime(float s)
{
	m_Scheduler->setTimeScale(s);
}

float LHSSchedulerActionManager::getScaleTime()
{
	return m_Scheduler->getTimeScale();
}

void LHSSchedulerActionManager::pause()
{
	Director::getInstance()->getScheduler()->pauseTarget(m_Scheduler);
}

void LHSSchedulerActionManager::resume()
{
	Director::getInstance()->getScheduler()->resumeTarget(m_Scheduler);
}
