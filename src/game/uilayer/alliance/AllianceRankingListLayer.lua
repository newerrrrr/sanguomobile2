local AllianceRankingListLayer = class("AllianceRankingListLayer",function()
    return cc.Layer:create()
end)


local isOnShow = false

function AllianceRankingListLayer:ctor()
    local uiLayer = cc.CSLoader:createNode("alliance_contribution_rank.csb")
    self:addChild(uiLayer)
    self._uiLayer = uiLayer
    
    self._uiLayer:getChildByName("btn_menu_1"):getChildByName("Text"):setString(g_tr("allianceTechRankListDay"))
    self._uiLayer:getChildByName("btn_menu_2"):getChildByName("Text"):setString(g_tr("allianceTechRankListWeek"))
    self._uiLayer:getChildByName("btn_menu_3"):getChildByName("Text"):setString(g_tr("allianceTechRankListAll"))
    
    self._uiLayer:getChildByName("bg_th"):getChildByName("text_1"):setString(g_tr("allianceRankListPlayerName"))
    self._uiLayer:getChildByName("bg_th"):getChildByName("text_2"):setString(g_tr("allianceRankListCoin"))
    self._uiLayer:getChildByName("bg_th"):getChildByName("text_1_1"):setString(g_tr("allianceRankListExp"))
    
    local btnDay = self._uiLayer:getChildByName("btn_menu_1")
    btnDay:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenu(1)
        end
    end)
    
    local btnWeek = self._uiLayer:getChildByName("btn_menu_2")
    btnWeek:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:tabMenu(2)
        end
    end)
    
    local btnMonth = self._uiLayer:getChildByName("btn_menu_3")
    btnMonth:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:tabMenu(3)
        end
    end)
    
    self._listView = self._uiLayer:getChildByName("ListView_2")
    local listItem = cc.CSLoader:createNode("alliance_contribution_rank_item.csb")
    self._listView:setItemModel(listItem)
    
    self._tabMenus = {btnDay,btnWeek,btnMonth}
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          isOnShow = true
          self:tabMenu(1)
      elseif eventType == "exit" then
          isOnShow = false
      end 
    end )
    
end



function AllianceRankingListLayer:tabMenu(idx)
    if self._changePageIdx == idx then
        return
    end
    
    local doTab = function()
        self._changePageIdx = idx
    
        for key, btn in pairs(self._tabMenus) do
            btn:setEnabled(true)
        end
        if self._tabMenus[idx] then
            self._tabMenus[idx]:setEnabled(false)
        end
        self._listView:removeAllChildren()

        local list = {}
        for key, var in pairs(self._list) do
           self._listView:pushBackDefaultItem()
           list[tonumber(key)] = var
        end
        
        local items = self._listView:getItems()
        for i =1, #items do
          local item = self._listView:getItem(i - 1)
          if item then
              self:updateListItem(item,list[i])
          end
        end
        
    end
    
    local type = 2 - idx + 1
    local resultHandler = function(result, msgData)
      g_busyTip.hide_1()
      if not isOnShow then
         return
      end
        
      if result then
         --{"code":0,"data":{"rank":{"1":{"player_id":"100017","nick":"nick-561e4cb642267","rank":4,"exp":"530","coin":"2500"}}},"basic":[]}
         self._list = msgData.rank
         doTab()
      end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("Guild/donateRank",{type = type},resultHandler,true)
    
end

function AllianceRankingListLayer:updateListItem(item,data)
    local base = item:getChildByName("rank_item")
    base:getChildByName("name"):setString(data.nick)
    
    base:getChildByName("Image_1"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + g_Consts.AllCurrencyType.AllianceTechExp))
    base:getChildByName("text_contribution"):setString(string.formatnumberthousands(data.exp))
    
    base:getChildByName("Image_1_0"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + g_Consts.AllCurrencyType.PlayerHonor))
    base:getChildByName("text_honor"):setString(string.formatnumberthousands(data.coin))
end

return AllianceRankingListLayer