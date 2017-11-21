#include "LHSArmatureAnimation.h"
#include "CCLuaEngine.h"

USING_NS_CC;

LHSArmatureAnimation *LHSArmatureAnimation::create(cocostudio::Armature *armature)
{
	LHSArmatureAnimation *pArmatureAnimation = new (std::nothrow) LHSArmatureAnimation();
	if (pArmatureAnimation && pArmatureAnimation->init(armature))
	{
		pArmatureAnimation->autorelease();
		return pArmatureAnimation;
	}
	CC_SAFE_DELETE(pArmatureAnimation);
	return nullptr;
}


LHSArmatureAnimation::LHSArmatureAnimation()
	:m_ScriptMovemenHander(0)
	, m_ScriptFrameHander(0)
{

}


LHSArmatureAnimation::~LHSArmatureAnimation()
{
	unregisterScriptMovementHandler();
	unregisterScriptFrameHandler();
}


bool LHSArmatureAnimation::init(cocostudio::Armature *armature)
{
	return cocostudio::ArmatureAnimation::init(armature);
}


void LHSArmatureAnimation::registerScriptMovementHandler(int nHandler)
{
	unregisterScriptMovementHandler();
	m_ScriptMovemenHander = nHandler;
	if (m_ScriptMovemenHander)
	{
		this->setMovementEventCallFunc([=](cocostudio::Armature *armature, cocostudio::MovementEventType movementType, const std::string& movementID){
			if (0 != m_ScriptMovemenHander)
			{
				auto engine = LuaEngine::getInstance();
				auto pStack = engine->getLuaStack();
				pStack->pushObject(armature, "ccs.Armature");
				pStack->pushInt(movementType);
				pStack->pushString(movementID.c_str());
				pStack->executeFunctionByHandler(m_ScriptMovemenHander, 3);
				pStack->clean();
			}
		});
	}
}


void LHSArmatureAnimation::unregisterScriptMovementHandler(void)
{
	if (m_ScriptMovemenHander)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(m_ScriptMovemenHander);
		m_ScriptMovemenHander = 0;
	}
	this->setMovementEventCallFunc(nullptr);
}


void LHSArmatureAnimation::registerScriptFrameHandler(int nHandler)
{
	unregisterScriptFrameHandler();
	m_ScriptFrameHander = nHandler;
	if (m_ScriptFrameHander)
	{
		this->setFrameEventCallFunc([=](cocostudio::Bone *bone, const std::string& frameEventName, int originFrameIndex, int currentFrameIndex){
			if (0 != m_ScriptFrameHander)
			{
				auto engine = LuaEngine::getInstance();
				auto pStack = engine->getLuaStack();
				pStack->pushObject(bone, "ccs.Bone");
				pStack->pushString(frameEventName.c_str());
				pStack->pushInt(originFrameIndex);
				pStack->pushInt(currentFrameIndex);
				pStack->executeFunctionByHandler(m_ScriptFrameHander, 4);
				pStack->clean();
			}
		});
	}
}


void LHSArmatureAnimation::unregisterScriptFrameHandler(void)
{
	if (m_ScriptFrameHander)
	{
		cocos2d::ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(m_ScriptFrameHander);
		m_ScriptFrameHander = 0;
	}
	this->setFrameEventCallFunc(nullptr);
}