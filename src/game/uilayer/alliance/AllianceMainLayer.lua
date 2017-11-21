local AllianceMainLayer = class("AllianceMainLayer", require("game.uilayer.base.BaseLayer"))

local selfHaveAlliance = nil
function AllianceMainLayer:ctor()
  self:registerScriptHandler(function(eventType)
  if eventType == "enter" then
        g_AllianceMode.addUpdateView(self)
        g_AllianceMode.setMainView(self)
        require("game.uilayer.mainSurface.mainSurfaceMenu").hideJoinGuildTip()
    elseif eventType == "exit" then
        g_AllianceMode.removeAllUpdateView()
        g_AllianceMode.setMainView(nil)
    end 
  end )
  
  g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.ALLIANCE)
  
  local uiLayer =  g_gameTools.LoadCocosUI("alliance_index.csb",5)
  self:addChild(uiLayer)
  local baseNode = uiLayer:getChildByName("scale_node")
  self._baseNode = baseNode
  local closeBtn = baseNode:getChildByName("close_btn")
  closeBtn:setTouchEnabled(true)
  closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
  end)
  
  baseNode:getChildByName("Text_1"):setString(g_tr("allianceTitle"))
  
  local btn1 = baseNode:getChildByName("btn_menu_1")
  local btn2 = baseNode:getChildByName("btn_menu_2")
  btn1:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:updateView(1)
        end
  end)
  
  btn2:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:updateView(2)
        end
  end)
  
  self._tabBtns = {}
  table.insert(self._tabBtns,btn1)
  table.insert(self._tabBtns,btn2)

  self:reload()
end

function AllianceMainLayer:reload()
  self._currentIdx = 0
  
  selfHaveAlliance = g_AllianceMode.getSelfHaveAlliance()
  if selfHaveAlliance then
      self:updateView(2)
  else
      self:updateView(1)
  end
end

function AllianceMainLayer:updateView(idx)
    print("updateView")
    
    selfHaveAlliance = g_AllianceMode.getSelfHaveAlliance()
    
    if idx == nil then
        idx = self._currentIdx
    else
        self._currentIdx = idx
    end
    
    for key, btn in pairs(self._tabBtns) do
    	   btn:setEnabled(true)
    end
    if self._tabBtns[idx] then
         self._tabBtns[idx]:setEnabled(false)
    end
    
    local container = self._baseNode:getChildByName("container")
    --container:removeAllChildren()
    
    self._baseNode:getChildByName("btn_menu_1"):getChildByName("Text")
    :setString(g_tr("allianceFind"))
    
    if selfHaveAlliance then
        self._baseNode:getChildByName("btn_menu_2"):getChildByName("Text")
        :setString(g_tr("allianceMine"))
    else
        self._baseNode:getChildByName("btn_menu_2"):getChildByName("Text")
        :setString(g_tr("allianceCreate"))
    end
        
    local currentPage = nil
    if self._searchLayer then
        self._searchLayer:setVisible(false)
    end
    if self._mineLayer then
        self._mineLayer:setVisible(false)
    end
    if self._createLayer then
        self._createLayer:setVisible(false)
    end
    
    if idx == 1 then
        if self._searchLayer == nil then
            self._searchLayer = require("game.uilayer.alliance.AllianceSearchLayer"):create()
            container:addChild(self._searchLayer)
        end
        currentPage = self._searchLayer
    elseif idx == 2 then
        if selfHaveAlliance then
            if self._mineLayer == nil then
                self._mineLayer = require("game.uilayer.alliance.AllianceMineLayer"):create()
                container:addChild(self._mineLayer)
            end
            currentPage = self._mineLayer
            self._mineLayer:updateView()
        else
            if self._createLayer == nil then
                self._createLayer = require("game.uilayer.alliance.AllianceCreateLayer"):create(handler(self,self.reload))
                container:addChild(self._createLayer)
            end
            currentPage = self._createLayer
        end
    end
    
    if currentPage then
        currentPage:setVisible(true)
    end
end


return AllianceMainLayer