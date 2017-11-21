--g_guideData
local guideData = {}
setmetatable(guideData,{__index = _G})
setfenv(1,guideData)


local m_allGuideSteps = {}
local m_lastGuideInfo = nil
local m_currentGuideInfo = nil --当前大步骤
local m_currentServerStepId = 0
local m_currentServerOutOfStepIds = {}
local m_guides = {}
local m_outOfOrderGuides = {}

local triggeredOutOfOrderSteps = {}

local function initLocalSteps()
    m_allGuideSteps = {}
    local guideSteps = {}
    assert(g_data.guide ~= nil,"guide config Error")
    for key, step in pairs(g_data.guidesteps) do
        local guideStep = require("game.guidedata.GuideStep").new(key)
        m_allGuideSteps[key] = guideStep
    end
end

local function initGuides()
  m_guides = {}
  
  local function sortTables(a, b)
     return a < b
  end
  
  local guideIds = {}
  for guideId, guide in pairs(g_data.guide) do
      table.insert(guideIds,guideId)
  end
  table.sort(guideIds,sortTables)
  
  for key , guideId in ipairs(guideIds) do
      local guideInfo = require("game.guidedata.GuideInfo").new(guideId)
      table.insert(m_guides,guideInfo)
  end
end

local function initOutOfOrderGuides()
  m_outOfOrderGuides = {}
  
  local function sortTables(a, b)
     return a.priority < b.priority
  end
  
  local tmpGuides = {}
  for guideId, guide in pairs(g_data.guide_tigger) do
      table.insert(tmpGuides,guide)
  end
  table.sort(tmpGuides,sortTables)
  
  for key , guide in ipairs(tmpGuides) do
      local guideInfo = require("game.guidedata.GuideInfo").new(guide.id,true)
      table.insert(m_outOfOrderGuides,guideInfo)
  end
  
end

function init()
    initLocalSteps()
    initGuides()
    initOutOfOrderGuides()
    return true
end

function getFinalStepId()
    local idx = #m_guides
    return m_guides[idx]:getGuideId() or 0
end

function getAllGuideSteps()
    return m_allGuideSteps
end

function getGuides()
    return m_guides
end

function getOutOfOrderGuides()
    return m_outOfOrderGuides
end

--function setLastGuideInfo(guideInfo)
--    m_lastGuideInfo = guideInfo
--end

function setCurrentGuideInfo(guideInfo)
    m_currentGuideInfo = guideInfo
end

function getCurrentGuideInfo()
    return m_currentGuideInfo
end

function jumpToNextGuideInfo() -- when a guideInfo was finished get an new guideInfo
  --setLastGuideInfo(m_currentGuideInfo)
  
    local currentGuideInfo = nil
    for i = 1, #getGuides() do
        local guide = getGuides()[i]
        if guide:getIsFinished() == false then
           currentGuideInfo = guide
           break
        end
    end
    setCurrentGuideInfo(currentGuideInfo) -- set current guideInfo
    
    if currentGuideInfo == nil then -- the last step
        
    end
  
end

function getGuideInfoByGuideId(guideId)
  local  guide = nil 
   for i = 1, #getGuides() do
      if getGuides()[i]:getGuideId() == guideId then
         guide = getGuides()[i]
         break
      end
   end
  return guide
end

function setCurrentGuideInfoById(guideId)
--  if getGuideStepIdWhenOffLine() ~= nil then
--     setGuideStepIdWhenOffLine(nil)
--     return
--  end
  
  init() --reload
  
  if guideId == 0 then
     local firstGuideInfo = getGuides()[1]
     setCurrentGuideInfo(firstGuideInfo) -- set current guideInfo
     return
  end
  
  local guideInfo = nil
  for i = 1, #getGuides() do
      guideInfo = getGuides()[i]
      if guideInfo:getGuideId() <= guideId then
         guideInfo:setIsFinished(true)
      else
         break
      end
  end
  
  -- force skip guide with an enough large guide id
  if guideId >= getGuides()[#getGuides()]:getGuideId() then
--     local maxlength = #getGuides()[#getGuides()]:getGuideSteps()
--     getGuides()[#getGuides()]:setCurrentStep(getGuides()[#getGuides()]:getGuideSteps()[maxlength])
--     setCurrentGuideInfo(getGuides()[#getGuides()])
     setCurrentGuideInfo(nil)
     return
  end
  
  
  local currentGuideInfo = getGuideInfoByGuideId(guideId)
  --assert(currentGuideInfo ~= nil,"Invaild guide info :"..guideId)
  setCurrentGuideInfo(currentGuideInfo) -- set current guideInfo
  if currentGuideInfo == nil then --如果上线找不到引导配置 关闭引导
      g_guideEnabled = false
      return
  end
  
  jumpToNextGuideInfo()
  
end

--根据服务器信息初始化等级触发引导
function setServerOutOfOrderGuideInfo(stepIds)
  for _, setpId in ipairs(stepIds) do
  	for key, guideInfo in pairs(m_outOfOrderGuides) do
  		if setpId == guideInfo:getGuideId() then
  		    guideInfo:setIsFinished(true)
  		end
  	end
  end
end

function setSavedOutOfOrderStepIds(stepIds)
    m_currentServerOutOfStepIds = stepIds
end

function getSavedOutOfOrderStepIds()
    return m_currentServerOutOfStepIds
end

function setCurrentServerStepId(step)
    m_currentServerStepId = step
end

function getCurrentServerStepId()
    return m_currentServerStepId
end

function saveIdOnStepClose(guideStep)
    if guideStep and guideStep:getIsLastOneStep() then --最后小步关闭时存储id
        local guideInfo = guideStep:getGuideInfo()
        --g_airBox.show("m_currentServerStep:"..m_currentServerStepId..",id:"..guideInfo:getConfig().id)
        
        if guideInfo:getIsOutOfOrderType() then
            local resultHandler = function(result,msgData)
                if result then
                    --g_airBox.show("test:save guide success")
                end
            end
            g_sgHttp.postData("data/index",{steps = {step_set = guideInfo:getConfig().id}},resultHandler)
            
        else
            if m_currentServerStepId == guideInfo:getConfig().id or guideInfo:getConfig().close_type == 1 then
                return
            end
            
            --g_airBox.show("test:saving guide")
            
            local resultHandler = function(result,msgData)
                if result then
                    --g_airBox.show("test:save guide success")
                end
            end
            
            if g_guideData.getFinalStepId() == guideInfo:getConfig().id then
                --appsflyer追踪强制新手引导自然结束事件（如果GM关闭新手 改事件可能无法追踪）
                g_sdkManager.trackTutorialCompletionEvent()
            end
            g_sgHttp.postData("data/index",{steps = {step = guideInfo:getConfig().id}},resultHandler)
        end
    end
end

function saveIdOnStepShow(guideStep)
    if guideStep then
        local guideInfo = guideStep:getGuideInfo()
        if guideInfo:getConfig().close_type ~= 1 then
            return
        end
        
        if guideInfo:getIsOutOfOrderType() then
            local resultHandler = function(result,msgData)
                if result then
                    --g_airBox.show("test:save guide success")
                end
            end
            g_sgHttp.postData("data/index",{steps = {step_set = guideInfo:getConfig().id}},resultHandler)
        else
             --g_airBox.show("m_currentServerStep:"..m_currentServerStepId..",id:"..guideInfo:getConfig().id)
            if m_currentServerStepId == guideInfo:getConfig().id then
                return
            end
            
            --g_airBox.show("test:saving guide")
            
            local resultHandler = function(result,msgData)
                if result then
                    --g_airBox.show("test:save guide success")
                end
            end
            
            if g_guideData.getFinalStepId() == guideInfo:getConfig().id then
                --appsflyer追踪强制新手引导自然结束事件（如果GM关闭新手 改事件可能无法追踪）
                g_sdkManager.trackTutorialCompletionEvent()
            end
            g_sgHttp.postData("data/index",{steps = {step = guideInfo:getConfig().id}},resultHandler)
        end
        
    end
end

return guideData