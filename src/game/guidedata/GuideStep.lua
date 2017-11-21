local GuideStep = class("GuideStep")

function GuideStep:ctor(stepId)
    local config = g_data.guidesteps[stepId]
    self:setConfig(config)
end

--大步的id，即GuideInfo的configId
function GuideStep:getId()
    return self:getGuideInfo():getConfig().id
end

------
--  Getter & Setter for
--      GuideStep._Config
-----
function GuideStep:setConfig(Config)
    self._Config = Config
end

function GuideStep:getConfig()
    return self._Config
end

------
--  Getter & Setter for
--      GuideStep._GuideInfo
-----
function GuideStep:setGuideInfo(GuideInfo)
    self._GuideInfo = GuideInfo
end

function GuideStep:getGuideInfo()
    return self._GuideInfo
end

------
--  Getter & Setter for
--      GuideStep._IsLastOneStep
-----
function GuideStep:setIsLastOneStep(IsLastOneStep)
    self._IsLastOneStep = IsLastOneStep
end

function GuideStep:getIsLastOneStep()
    return self._IsLastOneStep
end



return GuideStep