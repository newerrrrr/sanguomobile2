local AreaSelectLayer = class("AreaSelectLayer",function()
    return cc.Layer:create()
end)

function AreaSelectLayer:ctor(selectedCallBack,mserverList)
    local uiLayer =  g_gameTools.LoadCocosUI("login_select_area.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    
    local background = uiLayer:getChildByName("mask")
    background:setTouchEnabled(true)
    background:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
           self:removeFromParent()
        end
    end)
    
    --[[local bg_right_top = baseNode:getChildByName("bg_right_top")
    bg_right_top:setTouchEnabled(true)
    bg_right_top:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
           if selectedCallBack then
              selectedCallBack(g_Account.getUserConfig().lastServerId or 1)
           end
           self:removeFromParent()
        end
    end)]]
    
    local listViewLeft = baseNode:getChildByName("ListView_left")
    local listViewRight = baseNode:getChildByName("ListView_right")
    
    local list = mserverList or g_gameServerList
   
    local getArenaInfoById = function(serverId)
        local info = nil
        for key, var in pairs(list) do
            if tonumber(var.id) == serverId then
               info = var
               break
            end
        end
        return info
    end
    
    local showHostoryServerList = function()
        listViewRight:removeAllChildren()
        local items = listViewLeft:getItems()
        for key, item in ipairs(items) do
            item:getChildByName("Image_6"):setVisible(false)
        end
        items[1]:getChildByName("Image_6"):setVisible(true)
            
        local historyServerInfo = g_Account.getHistoryServerList()
        if historyServerInfo then
            local itemOrginal = cc.CSLoader:createNode("login_select_area_right_item1.csb")
            for key, var in pairs(historyServerInfo.list) do
                local item = itemOrginal:clone()
                item:setTouchEnabled(true)
                
                local avatarId = tonumber(var.avatar_id)
                local iconId = g_data.res_head[avatarId].head_icon
                item:getChildByName("Image_2"):loadTexture(g_resManager.getResPath(iconId))
                item:getChildByName("Image_2_0"):loadTexture(g_resManager.getResPath(1010007)) --boader
                --item:getChildByName("Text_name1"):setString()
                local nameStr = "Lv."..var.level.."  "..var.nick
                item:getChildByName("Text_lv"):setString(nameStr)
                local serverInfo = getArenaInfoById(tonumber(var.server_id))
                local arenaStr = ""
                if serverInfo then
                    arenaStr = serverInfo.areaName.."  "..serverInfo.name
                end
                item:getChildByName("Text_name1"):setString(arenaStr)
                item.historyInfo = var
                listViewRight:pushBackCustomItem(item)
            end
        end 
    end
    
    local currentSelectedServerId = g_Account.getUserConfig().lastServerId or 1
    
    local historyServerInfo = g_Account.getHistoryServerList()
    if historyServerInfo and historyServerInfo.last.last_server_id then
        currentSelectedServerId = tonumber(historyServerInfo.last.last_server_id)
    else
        local gameUuid = g_sgHttp.getUUID()
        g_Account.requestPlayerServerList(gameUuid,function()
             historyServerInfo = g_Account.getHistoryServerList()
             currentSelectedServerId = tonumber(historyServerInfo.last.last_server_id)
             local currentAreaInfo = getArenaInfoById(currentSelectedServerId)
             if currentAreaInfo then
                 baseNode:getChildByName("Text_area"):setString(currentAreaInfo.areaName)
                 baseNode:getChildByName("Text_server"):setString(currentAreaInfo.name)
                 --baseNode:getChildByName("Text_state_1"):setString("")
                 showHostoryServerList()
             end
        end)
    end
    
    baseNode:getChildByName("bg_title"):getChildByName("Text"):setString(g_tr("serverAreaSelect"))
    baseNode:getChildByName("Text_last_login"):setString(g_tr("currentLoginServer"))
    baseNode:getChildByName("Text_state_1"):setString(g_tr("serverMaintain"))
    
    
    baseNode:getChildByName("Text_area"):setString("")
    baseNode:getChildByName("Text_server"):setString("")
    baseNode:getChildByName("Text_state_1"):setString("")
    
    local currentAreaInfo = getArenaInfoById(currentSelectedServerId)
    if currentAreaInfo then
        baseNode:getChildByName("Text_area"):setString(currentAreaInfo.areaName)
        baseNode:getChildByName("Text_server"):setString(currentAreaInfo.name)
        --baseNode:getChildByName("Text_state_1"):setString("")
    end
    
    local function reloadGameAndGotoArear(areaId)
         g_msgBox.show(g_tr("accountChangeArea"),nil,nil,function(event)
            if event == 0 then
                local targetAreaTag = g_Account.getTargetAreaTag()
                g_saveCache[targetAreaTag] = tonumber(areaId)
                local action = cc.Sequence:create(cc.DelayTime:create(0.15),cc.CallFunc:create(function()
                    self:removeFromParent()
                    g_gameManager.reStartGame()
                end))
                self:runAction(action)
            end
         end,1)
    end
   
    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("touched:",sender:getCurSelectedIndex())
            
            local items = listViewRight:getItems()
            local listInfo = items[sender:getCurSelectedIndex() + 1].listInfo
            if listInfo then
                if currentSelectedServerId == tonumber(listInfo.id) then
                    g_airBox.show(g_tr("accountSameAreaTip"))
                else
                    --fb賬號限制
                    if g_Account.getChannel() == g_sdkManager.SdkLoginChannel.facebook and tonumber(listInfo.id) > g_facebookAcountEnableMax then
                        g_msgBox.show(g_tr("accountFbDisableTip",{area_name = listInfo.name}),nil,nil,function(event)
                            if event == 0 then
 
                            end
                        end)
                        return
                    end
                       
                    local targetServerHost = listInfo.gameServerHost
                    local function onResult(result, data, responseCode)
                        g_busyTip.hide_1()
                        if result then
                            if selectedCallBack then
                                selectedCallBack(listInfo.id)
                            end
                            reloadGameAndGotoArear(listInfo.id)
                        else
                            print("~~~~~~")
                            if listInfo.status and tonumber(listInfo.status) > 0 then
                                local str = listInfo.maintain_notice or ""
                                if str == "" then
                                    str = g_tr("serverMaintainDefaultTip")
                                end
                                --g_msgBox.show(str)
                                g_sceneManager.addNodeForUI(require("game.uilayer.regist.MaintainAlertLayer"):create(str))
                            end
                        end
                    end
                    g_busyTip.show_1()
                    httpNet:getInstance():Post(targetServerHost.."/detect_encrypt.php","",string.len(""),onResult,10,10,true,false)
                end
            else
                local historyInfo = items[sender:getCurSelectedIndex() + 1].historyInfo
                if historyInfo then
                    if currentSelectedServerId == tonumber(historyInfo.server_id) then
                        g_airBox.show(g_tr("accountSamePlayerTip"))
                    else
                        if selectedCallBack then
                            selectedCallBack(historyInfo.server_id)
                        end
                        reloadGameAndGotoArear(historyInfo.server_id)
                    end
                end
            end
            
            --[[local action = cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(function()
                self:removeFromParent()
            end))
            self:runAction(action)]]
        end
    end
    listViewRight:addEventListener(listViewEvent)

    local function leftListViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            print("touched:",sender:getCurSelectedIndex())
            
            local items = listViewLeft:getItems()
            for key, item in ipairs(items) do
            	item:getChildByName("Image_6"):setVisible(false)
            end
            items[sender:getCurSelectedIndex() + 1]:getChildByName("Image_6"):setVisible(true)
            
            listViewRight:removeAllChildren()
            
            local currentIdx = sender:getCurSelectedIndex() + 1
            if currentIdx == 1 then
                showHostoryServerList()
            elseif currentIdx == 2 then --最新服务器
                local currentAreaInfo = nil
                for key, var in pairs(list) do
                   if var.default_enter == 1 then
                       currentAreaInfo = var
                       break
                   end
                end
                
                if currentAreaInfo then
                    local item = cc.CSLoader:createNode("login_select_area_right_item.csb")
                    self:updateItem(item,currentAreaInfo)
                    item:setTouchEnabled(true)
                    listViewRight:pushBackCustomItem(item)
                end
            else
                   local group = self._leftList[currentIdx - 2]
                   local listItem = cc.CSLoader:createNode("login_select_area_right_item.csb")
                   for i = 1, #group do
                        local listinfo = group[i]
                        local item = listItem:clone()
                        self:updateItem(item,listinfo)
                        item:setTouchEnabled(true)
                        if listinfo.status == 2 then 
                            if g_Account.isTestUser == 1 then
                               listViewRight:pushBackCustomItem(item)
                            end
                        else
                            listViewRight:pushBackCustomItem(item)
                        end
                   end
             end
        end
    end
    listViewLeft:addEventListener(leftListViewEvent)
    
    local leftListItem = cc.CSLoader:createNode("login_select_area_left_item.csb")
    
    --历史角色列表
    do
        local item = leftListItem:clone()
        item:setTouchEnabled(true)
        item:getChildByName("Text_1"):setString(g_tr("accountHistoryPlayer"))
        item:getChildByName("Image_6"):setVisible(false)
        listViewLeft:pushBackCustomItem(item)
    end
    
    --推荐（最新服务器）
    do
        local item = leftListItem:clone()
        item:setTouchEnabled(true)
        item:getChildByName("Text_1"):setString(g_tr("accountAreaRecommend"))
        item:getChildByName("Image_6"):setVisible(false)
        listViewLeft:pushBackCustomItem(item)
    end
    
    --for test
--    do
--       g_Account.isTestUser = 0
--       for key, var in pairs(list) do
--       	if var.id == 1 then
--       	    var.status = 2
--       	end
--       end
--    end
    
    --服务器列表
    do
        local maxRow = math.ceil(#list/5)
        local allIdx = 1
        local leftList = {}
        for j = 1, maxRow do
        	local group = {}
        	local startArea = ""
        	local toArea = ""
        	for i = 1, 5 do
        	    if list[allIdx] then
        	        if i == 1 then
        	           if list[allIdx].status == 2 then 
                        if g_Account.isTestUser == 1 then
                           startArea = list[allIdx].id
                        end
                     else
                        startArea = list[allIdx].id
                     end
        	        else
        	           if list[allIdx].status == 2 then 
                        if g_Account.isTestUser == 1 then
                           toArea = list[allIdx].id
                        end
                     else
        	              toArea = list[allIdx].id
        	           end
        	           
        	           if startArea == "" then
                         startArea = toArea
                     end
        	        end
            		  table.insert(group,list[allIdx])
            		  allIdx = allIdx + 1
        		end
        	end
        	table.insert(leftList,group)
        	
        	local item = leftListItem:clone()
        	item:setTouchEnabled(true)
        	local numStr = startArea
        	if toArea ~= "" then
        	   numStr = startArea.."-"..toArea
        	end
        	
        	local areaTitle = numStr..g_tr("accountAreaMonad")
        	item:getChildByName("Text_1"):setString(areaTitle)
        	if j ~= 1 then
        	   item:getChildByName("Image_6"):setVisible(false)
        	end
        	
        	if startArea ~= "" and toArea ~= "" then
              listViewLeft:pushBackCustomItem(item)
          end
          
          self._leftList = leftList
        end
    end
    
    showHostoryServerList()
end

function AreaSelectLayer:updateItem(item,listinfo)
    item:getChildByName("Text_new"):setString(g_tr("serverNew"))
    item:getChildByName("Text_new"):setVisible(tonumber(listinfo.isNew) > 0)
    item:getChildByName("Text_area"):setString(listinfo.areaName)
    item:getChildByName("Text_server"):setString(listinfo.name)
    item:getChildByName("Text_state_1"):setString(g_tr("serverMaintain"))
    item:getChildByName("Text_state_1"):setVisible(tonumber(listinfo.status) > 0)
    item.listInfo = listinfo
end

return AreaSelectLayer