local HospitalAlertLayer = class("HospitalAlertLayer",function()
  return cc.Layer:create()
end)

local m_layoffCount = 0
local m_resultCallBack = nil
local m_soldierInfo = nil
function HospitalAlertLayer:ctor(soldierInfo,resultCallBack)
    
    m_soldierInfo = soldierInfo
    m_resultCallBack = resultCallBack

	local alertLayer =  g_gameTools.LoadCocosUI("TheMedicalCenter_List01.csb",5)
	self:addChild(alertLayer)
	local baseNode = alertLayer:getChildByName("scale_node")
	
	--close this layer
	local closeBtn = baseNode:getChildByName("Button_1")
	closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    local updateView = function(isFromSlider)
        self._inputEditBoxRender:setString(m_layoffCount.."")
        baseNode:getChildByName("Button_2"):setEnabled(m_layoffCount > 0)
        if not isFromSlider then
            baseNode:getChildByName("Panel_2"):getChildByName("Slider_1"):setPercent(m_layoffCount)
        end
    end
    
    --reset ui text
    baseNode:getChildByName("Text_1"):setString(g_tr("titleTip"))
    
    baseNode:getChildByName("Text_1_0")
    :setString(g_tr("makeSureLayoff"))
    
    baseNode:getChildByName("Button_2"):getChildByName("Text_6")
    :setString(g_tr("layoff"))
    
    --layoff
    baseNode:getChildByName("Button_2"):addTouchEventListener(function(sender,eventType)
    
      if eventType == ccui.TouchEventType.ended then
          g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
          self:layOffhander()
          self:removeFromParent()
      end
      
    end)
    
    local reduceHandler = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("reducehandler")
            m_layoffCount = m_layoffCount - 1
            if m_layoffCount < 0 then
                m_layoffCount = 0
            end
            updateView()
        end
    end
    
    local addHandler = function(sender,eventType)
        
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("addhandler")
            m_layoffCount = m_layoffCount + 1
            if m_layoffCount > m_soldierInfo:getHurtedCount() then
                m_layoffCount = m_soldierInfo:getHurtedCount()
            end
            updateView()
        end
    end
    
    local btnReduce =  baseNode:getChildByName("Panel_2"):getChildByName("Text_3")
    btnReduce:addTouchEventListener(reduceHandler)
   
    local addReduce =  baseNode:getChildByName("Panel_2"):getChildByName("Text_3_0")
    addReduce:addTouchEventListener(addHandler)
    
    --slider
    local slider = baseNode:getChildByName("Panel_2"):getChildByName("Slider_1")
    slider:setMaxPercent(m_soldierInfo:getHurtedCount())
    
    slider:setPercent(m_soldierInfo:getHurtedCount())
    
    baseNode:getChildByName("Panel_2"):getChildByName("Text_5")
    :setString("/"..m_soldierInfo:getHurtedCount())
    
    self._inputEditBox = g_gameTools.convertTextFieldToEditBox(baseNode:getChildByName("Panel_2"):getChildByName("TextField_1"))
    self._inputEditBoxRender = baseNode:getChildByName("Panel_2"):getChildByName("Text_5_0")
    self._inputEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    
    self._inputEditBoxRender:setString(""..m_soldierInfo:getHurtedCount())
    self._inputEditBox:setString("")
    
    local flagCnt = ""
    local editBoxHandler = function(eventType)
        if eventType == "began" then
            flagCnt = self._inputEditBoxRender:getString()
            --self._inputEditBox:setText(flagCnt)
            self._inputEditBox:setText("")
            self._inputEditBoxRender:setString("")
            self._inputEditBoxRender:setVisible(false)
        elseif eventType == "customEnd" then
            local numStr = string.gsub(self._inputEditBox:getText(), ",","")
            if tonumber(numStr) == nil then
                --self._inputEditBox:setText(flagCnt)
                self._inputEditBoxRender:setString(flagCnt)
            else
                m_layoffCount = tonumber(numStr)
                if m_layoffCount > m_soldierInfo:getHurtedCount() then
                    m_layoffCount = m_soldierInfo:getHurtedCount()
                elseif m_layoffCount < 0 then
                    m_layoffCount = 0
                end
                updateView()
            end
            self._inputEditBox:setText("")
            self._inputEditBoxRender:setVisible(true)
        end
    end
    self._inputEditBox:registerScriptEditBoxHandler(editBoxHandler)
        
    
    m_layoffCount = m_soldierInfo:getHurtedCount()
    
    local function percentChangedEvent(sender,eventType)
        print(eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            m_layoffCount = slider:getPercent()
            updateView()
        elseif eventType == ccui.SliderEventType.slideBallUp then
            
        elseif eventType == ccui.SliderEventType.slideBallDown then
           
        elseif eventType == ccui.SliderEventType.slideBallCancel then
            
        end
    end
    slider:addEventListener(percentChangedEvent)
end


--do layoff 
function HospitalAlertLayer:layOffhander()

    if m_layoffCount <= 0 then
        return
    end

    --TODO:connect to server to update soldier info
     local resultHandler = function(result, msgData)
        if result then
            g_airBox.show(g_tr("fireSuccess"))
            if m_resultCallBack then
                m_resultCallBack()
            end
        end
     end

    local soldierData = {}
    local id = m_soldierInfo:getId()
    local count = m_layoffCount
    print("id:",id,"count:",count)
    local config = {}
    config.id = id
    config.soldier_id = m_soldierInfo:getConfig().id
    config.num = count
    if count > 0 then
        table.insert(soldierData,config)
    end
      
     if #soldierData > 0 then
        local data = {}
        data.soldier_injured = soldierData
        g_sgHttp.postData("soldier/fireInjuredSoldier",data,resultHandler)
     end
end

return HospitalAlertLayer