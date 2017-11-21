local AllianceMemberCleanup = class("AllianceMemberCleanup",function()
    return cc.Layer:create()
end)

function AllianceMemberCleanup:ctor()
    local uiLayer = g_gameTools.LoadCocosUI("alliance_member_cleanup.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node"):getChildByName("content_popup")
    self._baseNode = baseNode
    
    self._baseNode:getChildByName("close_btn"):addClickEventListener(function()
      self:removeFromParent()
    end)
    
    self._baseNode:getChildByName("btn_tic"):addClickEventListener(function()
        local targetPlayers = {}
        local items = self._listView:getItems()
        for i =1, #items do
           local item = self._listView:getItem(i - 1)
           if item and item:getChildByName("army_item"):getChildByName("CheckBox"):isSelected() then
              table.insert(targetPlayers,item.data.player_id)
           end
        end
        if #targetPlayers > 0 then
            local doFire = function()
                local function onRecv(result, msgData)
                  g_busyTip.hide_1()
                  if result == true then
                      self._baseNode:getChildByName("CheckBox"):setSelected(false)
                      g_busyTip.show_1()
                      g_AllianceMode.reqAllAllianceDataAsync(function(result, msgData)
                         g_busyTip.hide_1()
                         if result then
                            self:updateView()
                         else
                            self:removeFromParent()
                         end
                         g_airBox.show(g_tr("guildMemberFireSuccessTip"))
                      end)
                  end
    
                end
                g_busyTip.show_1()
                g_sgHttp.postData("guild/expelPlayerBat",{targetPlayerId = targetPlayers},onRecv,true)
            end
            
            g_msgBox.show(g_tr("guildMemberDoFireTip",{cnt = #targetPlayers}),nil,3,function(event)
                if event == 0 then
                    doFire()
                end
            end,1)
        else
            g_airBox.show(g_tr("guildMemberSelectTip"))
        end
    end)
    
    self._selectedCnt = 0
    
    
    local selectAllSwitchHandler = function()
        --全选
        self._baseNode:getChildByName("CheckBox"):setSelected(not self._baseNode:getChildByName("CheckBox"):isSelected())
        
        local items = self._listView:getItems()
        for i =1, #items do
          local item = self._listView:getItem(i - 1)
          if item then
              item:getChildByName("army_item"):getChildByName("CheckBox"):setSelected(self._baseNode:getChildByName("CheckBox"):isSelected())
          end
        end
        
        if self._baseNode:getChildByName("CheckBox"):isSelected() then
           self._selectedCnt = #items
        else
           self._selectedCnt = 0
        end
        self._baseNode:getChildByName("text_rs"):setString(g_tr("guildMemberCleanCntTip",{cnt = self._selectedCnt,max_cnt = #items}))
    
    end
    
    self._listView = self._baseNode:getChildByName("ListView_1")
    self._baseNode:getChildByName("btn_tic"):getChildByName("Text"):setString(g_tr("allianceMemberManager4"))
    self._baseNode:getChildByName("bg_title"):getChildByName("Text"):setString(g_tr("allianceMembers"))
    self._baseNode:getChildByName("text_nr"):setString(g_tr("selectAll"))
    self._baseNode:getChildByName("Panel_4"):setTouchEnabled(true)
    self._baseNode:getChildByName("Panel_4"):addClickEventListener(function()
       selectAllSwitchHandler()
    end)
    
    self:updateView()
    selectAllSwitchHandler()
    
end
    
function AllianceMemberCleanup:updateView()
    self._listView:removeAllChildren()
    
    local currentTime = g_clock.getCurServerTime()
    local allMembers = g_AllianceMode.getGuildPlayers()
    local offsetSec =  60*60*48
    local list = {}
    for key, member in pairs(allMembers) do
    	if currentTime - member.Player.last_online_time > offsetSec then
    	    if member.rank < 5 then
    	        table.insert(list,member)
    	    end
    	end
    end
    
    self._baseNode:getChildByName("text_nr_0"):setString(g_tr("guildMemberCleanTip",{cnt = #list}))
    self._baseNode:getChildByName("text_rs"):setString(g_tr("guildMemberCleanCntTip",{cnt = 0,max_cnt = #list}))

    if #list > 0 then
      table.sort(list,function(a,b)
         if a.rank == b.rank then 
            return a.Player.fuya_build_level > b.Player.fuya_build_level
         end
         return a.rank > b.rank
      end)
      
      local guildBaseData = g_AllianceMode.getBaseData()
      local nowTime = g_clock.getCurServerTime()
      --local itemModel = cc.CSLoader:createNode("alliance_member_cleanup_list1.csb")
      for key, data in ipairs(list) do
          --local item = itemModel:clone()
          local item = cc.CSLoader:createNode("alliance_member_cleanup_list1.csb")
          item:getChildByName("army_item"):getChildByName("Text_dj"):setString(g_tr("prePlayerPower"))
          item:getChildByName("army_item"):getChildByName("Text_dj_0"):setString(string.formatnumberthousands(data.Player.power))
          item:getChildByName("army_item"):getChildByName("Text_fy1"):setString(g_tr("prePlayerName"))
          item:getChildByName("army_item"):getChildByName("Text_fy2"):setString(data.Player.nick)
          item:getChildByName("army_item"):getChildByName("label_lv"):setString("Lv"..data.Player.level)
          local rankName = guildBaseData.GuildRankName[tonumber(data.rank)]
          if rankName == nil or rankName == "" then
            rankName = g_tr("allianceRankName"..data.rank)
          end
          item:getChildByName("army_item"):getChildByName("name1"):setString(g_tr("preAlliancePlayerJob")..rankName)
          
          local iconId = g_data.res_head[data.Player.avatar_id].head_icon
          item:getChildByName("army_item"):getChildByName("pic_0"):loadTexture(g_resManager.getResPath(iconId))
          item:getChildByName("army_item"):getChildByName("pic"):loadTexture(g_resManager.getResPath(1010007)) --boader
          
          item.data = data
          
          local function selectedEvent(sender,eventType)
              if eventType == ccui.CheckBoxEventType.selected then
                  self._selectedCnt = self._selectedCnt + 1
                  if self._selectedCnt >= #list then
                      self._baseNode:getChildByName("CheckBox"):setSelected(true)
                  end
                  self._baseNode:getChildByName("text_rs"):setString(g_tr("guildMemberCleanCntTip",{cnt = self._selectedCnt,max_cnt = #list}))
              elseif eventType == ccui.CheckBoxEventType.unselected then
                  self._selectedCnt = self._selectedCnt - 1
                  if self._selectedCnt < 0 then
                      self._selectedCnt = 0
                  end
                  self._baseNode:getChildByName("CheckBox"):setSelected(false)
                  self._baseNode:getChildByName("text_rs"):setString(g_tr("guildMemberCleanCntTip",{cnt = self._selectedCnt,max_cnt = #list}))
              end
          end   
          item:getChildByName("army_item"):getChildByName("CheckBox"):setTouchEnabled(true)
          item:getChildByName("army_item"):getChildByName("CheckBox"):addEventListenerCheckBox(selectedEvent) 

          item:getChildByName("army_item"):getChildByName("Text_zl1"):setString(g_tr("prePlayerFuYaLv"))
          item:getChildByName("army_item"):getChildByName("Text_zl2"):setString(data.Player.fuya_build_level.."")
          
          self._listView:pushBackCustomItem(item)

          local lastTime = data.Player.last_online_time
          local timeShowStr = ""
          if lastTime > 0 then 
             local miniutes = math.ceil((nowTime - lastTime)/60)             
             if miniutes < 60 then
                 timeShowStr = g_tr("miniuteago",{value = miniutes})
             elseif miniutes >= 60 and miniutes < 1440 then
                 timeShowStr =  g_tr("hourago",{value = math.floor(miniutes/60)})
             else
                 timeShowStr = g_tr("dayago",{value = math.min(7, math.floor(miniutes/1440))})
             end
          else 
             timeShowStr = g_tr("dayago",{value = 7})
          end 
          
          local stateStr = g_tr("lastOnlineTime")..timeShowStr

          item:getChildByName("army_item"):getChildByName("Text_zl2_0"):setString(stateStr)
          
          
      end
    end
    
end

return AllianceMemberCleanup