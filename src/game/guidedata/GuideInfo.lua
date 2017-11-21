local GuideInfo = class("GuideInfo")

function GuideInfo:ctor(guideId,isOutOfOrderType)
    self._guideId = guideId
    if isOutOfOrderType == nil then
        isOutOfOrderType = false
    end
    self._isOutOfOrderType = isOutOfOrderType
    self:init()
    self:setIsFinished(false)
    self:setCurrentStepIdx(1)
    self:setIsOutOfOrderType(isOutOfOrderType)
end

function GuideInfo:init()
    local steps = {}
    local stepIds = {}
    if self._isOutOfOrderType then
        stepIds = g_data.guide_tigger[self._guideId].steps
    else
        stepIds = g_data.guide[self._guideId].steps
    end
    
    for i=1, #stepIds do
         local stepId = stepIds[i]
         local guideStep = clone(g_guideData.getAllGuideSteps()[stepId])
         assert(guideStep ~= nil,"guideStep "..stepId.." error")
         guideStep:setGuideInfo(self)
         guideStep:setIsLastOneStep(i == #stepIds)
         table.insert(steps,guideStep)
    end
    self:setGuideSteps(steps)
end

function GuideInfo:getConfig()
    local config = nil 
    if self._IsOutOfOrderType then
        config = g_data.guide_tigger[self._guideId]
    else
        config = g_data.guide[self._guideId]
    end
    return config 
end

function GuideInfo:getGuideId()
    return self._guideId
end

------
--  Getter & Setter for
--      GuideInfo._IsOutOfOrderType
-----
function GuideInfo:setIsOutOfOrderType(IsOutOfOrderType)
    self._IsOutOfOrderType = IsOutOfOrderType
end

function GuideInfo:getIsOutOfOrderType()
    return self._IsOutOfOrderType
end

function GuideInfo:goNextStep()
   print("GuideInfo:goNextStep()")
   local guideId = self._guideId
   local currentStepIdx = self:getCurrentStepIdx() + 1
   if currentStepIdx > #self:getGuideSteps() then
      self:setIsFinished(true)
      if not self._IsOutOfOrderType then
          g_guideData.jumpToNextGuideInfo()
      end
   else
      self:setCurrentStepIdx(currentStepIdx)
   end
   
end

------
--  Getter & Setter for
--      GuideInfo._GuideSteps 
-----
function GuideInfo:setGuideSteps(GuideSteps)
    self._GuideSteps = GuideSteps
end

function GuideInfo:getGuideSteps()
    return self._GuideSteps
end

------
--  Getter & Setter for
--      GuideInfo._CurrentStepIdx 
-----
function GuideInfo:setCurrentStepIdx(CurrentStepIdx)
    self._CurrentStepIdx = CurrentStepIdx
    self:setCurrentStep(self:getGuideSteps()[CurrentStepIdx])
end

function GuideInfo:getCurrentStepIdx()
    return self._CurrentStepIdx
end

------
--  Getter & Setter for
--      GuideInfo._CurrentStep 
-----
function GuideInfo:setCurrentStep(CurrentStep)
    self._CurrentStep = CurrentStep
end

function GuideInfo:getCurrentStep()
    return self._CurrentStep
end

------
--  Getter & Setter for
--      GuideInfo._IsFinished 
-----
function GuideInfo:setIsFinished(IsFinished)
    self._IsFinished = IsFinished
end

function GuideInfo:getIsFinished()
    return self._IsFinished
end

return GuideInfo