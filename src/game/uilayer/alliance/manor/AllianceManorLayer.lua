local AllianceManorLayer = class("AllianceManorLayer",function()
    return cc.Layer:create()
end)

local baseNode = nil
function AllianceManorLayer:ctor(inputHandler,indexPage)
    
    self._inputHandler = inputHandler
    
    local m_indexPage = indexPage or 1
    
    local node = g_gameTools.LoadCocosUI("alliance_manage_index.csb",5)
    self:addChild(node)
    baseNode = node:getChildByName("scale_node")

    baseNode:getChildByName("Text_1"):setString(g_tr("allianceField"))

     --关闭本页
    local btnClose = baseNode:getChildByName("close_btn")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    --添加左侧按钮列表
    local menusTexts = {
        g_tr("allianceFortress"),--联盟堡垒
        g_tr("allianceTower"),--联盟箭塔
        g_tr("allianceRecourse"),--联盟资源
        g_tr("allianceWarehouse"),--联盟仓库
    }
    
    self._isFormWorldMap = (self._inputHandler ~= nil)

    self._menusTexts = menusTexts
    local leftListView = baseNode:getChildByName("ListView_left")
    self._leftListView = leftListView
    local itemModel = cc.CSLoader:createNode("alliance_manage_left_menu.csb")
    itemModel:setContentSize(itemModel:getChildByName("pic_select"):getContentSize())
    itemModel:getChildByName("pic_selected"):setVisible(true)
    leftListView:setItemModel(itemModel)
    --leftListView:setItemsMargin(1.0)
    for key, text in pairs(menusTexts) do
       leftListView:pushBackDefaultItem()
    end
    
    local items = leftListView:getItems()
    for i =1, #items do
      local str = menusTexts[i]
      local item = leftListView:getItem(i - 1)
      if item then
          item:getChildByName("text"):setString(str)
      end
    end
    
    --切换列表
    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            print("touched:",sender:getCurSelectedIndex())
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self:changePage(sender:getCurSelectedIndex() + 1)
        end
    end
    leftListView:addEventListener(listViewEvent)

--    local function memberListViewEvent(sender, eventType)
--        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
--            print("touched:",sender:getCurSelectedIndex())
--        end
--    end
    
    local memberListView = cc.CSLoader:createNode("alliance_building_scroll.csb")
    local container = baseNode:getChildByName("container")
    container:addChild(memberListView)
    self._memberListViewModel = memberListView:getChildByName("ListView_3")
    --self._memberListView:addEventListener(memberListViewEvent)
    local memberItemModel = cc.CSLoader:createNode("alliance_building_baolei.csb")
    self._memberListViewModel:setItemModel(memberItemModel)
    self._memberListViewModel:setItemsMargin(4.0)
    
    self._memberListViewModel:setVisible(false)
    
    self._canCreateGuildBuilds = {}
    self._allServerBuilds = {}
    
    local onEnter = function()
        local resultHandler = function(result, msgData)
            g_busyTip.hide_1()
            if result then
                
                self._allServerBuilds = msgData.GuildBuild
                
                --联盟建筑可建造信息
                self._canCreateGuildBuilds = msgData.CanCreate or {}
                if g_AllianceMode.isAllianceManager() then
                    for key, var in ipairs(self._canCreateGuildBuilds) do
                      if var.map_element_id == 101 or var.map_element_id == 0 then --红点仅提示堡垒和矿场
                        	if var.current < var.max then
                        	   local menu = self._leftListView:getItem(key - 1)
                        	   menu:getChildByName("Button_place_hongdian_0"):setVisible(true)
                        	end
                    	end
                    end
                end
                
                g_guideManager.execute()
                self:changePage(m_indexPage)
                
                --Button_place_hongdian_0
            else
                self:removeFromParent()
            end
        end
        g_busyTip.show_1()
        g_allianceManorData.RequestDataAsync(resultHandler)
        
    end
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          onEnter()
      elseif eventType == "exit" then
      end 
    end )
    
    
end

function AllianceManorLayer:cleanRightListView()
    if self._memberListView then
        self._memberListView:removeFromParent()
    end
    self._memberListView = self._memberListViewModel:clone()
    self._memberListViewModel:getParent():addChild(self._memberListView)
    self._memberListView:setVisible(true)
end

function AllianceManorLayer.getIndexByMapElementId(mapElementId)
    local mapElementInfo = g_data.map_element[mapElementId]
    assert(mapElementInfo)
    local originId = mapElementInfo.origin_id
    local idx = 1
    if originId == 1 then
       idx = 1
    elseif originId == 2 then
       idx = 2
    elseif originId == 3 
    or originId == 4 
    or originId == 5 
    or originId == 6
    or originId == 7 then
       idx = 3
    elseif originId == 8 then
       idx = 4
    end
    return idx
end

function AllianceManorLayer:changePage(idx)
    if self._changePageIdx == idx then
        return 
    end
    print("pageChanged")
    self._changePageIdx = idx
    self:cleanRightListView()

    if self._lastMenu then
        self._lastMenu:getChildByName("pic_selected"):setVisible(true)
    end
    
    self._lastMenu = self._leftListView:getItem(idx - 1)
    self._lastMenu:getChildByName("pic_selected"):setVisible(false)
    
    --所有要显示的
    local allCurrentTypeBuilds = {}
    for key, var in pairs(clone(g_data.alliance_build_description)) do
        if allCurrentTypeBuilds[idx] == nil then
            allCurrentTypeBuilds[idx] = {}
        end
        
        local mapElementId = var.element_id
        local m_idx = AllianceManorLayer.getIndexByMapElementId(mapElementId)
        if m_idx == idx then
            table.insert(allCurrentTypeBuilds[idx],var)
        end
        
        
        --[[local mapElementInfo = g_data.map_element[mapElementId]
        assert(mapElementInfo)
        local originId = mapElementInfo.origin_id
        if idx == 1 then
            if originId == 1 then
               table.insert(allCurrentTypeBuilds[idx],var)
            end
        elseif idx == 2 then
            if originId == 2 then
               table.insert(allCurrentTypeBuilds[idx],var)
            end
        elseif idx == 3 then
            if originId == 3 
            or originId == 4 
            or originId == 5 
            or originId == 6
            or originId == 7 then
               table.insert(allCurrentTypeBuilds[idx],var)
            end
        elseif idx == 4 then
            if originId == 8 then
               table.insert(allCurrentTypeBuilds[idx],var)
            end
        end]]
        
    end
    
    local currentShowBuilds = allCurrentTypeBuilds[idx]
    self._currentShowBuilds = currentShowBuilds
    
    local sortFunc = function(a,b)
        return a.count < b.count
    end
    table.sort(currentShowBuilds,sortFunc)

    local serverBuilds = self._allServerBuilds[idx] or {}
    
    for key, var in pairs(serverBuilds) do
      local mapElementInfo = g_data.map_element[var.map_element_id]
      assert(mapElementInfo)
      --if mapElementInfo.element_id == 
      for _key, _var in pairs(currentShowBuilds) do
        if _var.element_id == mapElementInfo.id and _var.count == key then
           _var.serverData = var
        end
      end
    end
    
--     --从服务器拿数据，已经造好的
--    local serverBuilds = {}
--    local resultHandler = function(result, msgData)
--        if result then
--          print("success")
--          --[{"id":18,"x":106,"y":375,"block_id":3170,"map_element_id":101,"map_element_element_id":1,"topography":0,"guild_id":17,"player_id":0,"update_time":1449640066,"create_time":1449640066}]
--          serverBuilds = msgData
--          for key, var in pairs(serverBuilds) do
--              local mapElementInfo = g_data.map_element[var.map_element_id]
--              assert(mapElementInfo)
--              --if mapElementInfo.element_id == 
--              for _key, _var in pairs(currentShowBuilds) do
--              	if _var.element_id == mapElementInfo.id and _var.count == key then
--              	   _var.serverData = var
--              	end
--              end
--          end
--        end
--    end
--    
--    g_sgHttp.postData("guild/viewGuildBuild",{type = idx},resultHandler)

    for i = 1, #currentShowBuilds do
    	 self._memberListView:pushBackDefaultItem()
    end

--    self._canCreateGuildBuilds = {}
--    local canCreateGuildBuildReslut = function(result, msgData)
--        if result then
--          --{"code":0,"data":[{"map_element_id":101,"current":1,"max":1},{"map_element_id":201,"current":1,"max":1},{"map_element_id":0,"current":0,"max":1},{"map_element_id":801,"current":0,"max":1}],"basic":[]}
--          print("success")
--          self._canCreateGuildBuilds = msgData
--        end
--    end
--    
--    
--    --联盟建筑可建造信息
--    g_sgHttp.postData("guild/canCreateGuildBuild",{},canCreateGuildBuildReslut)
    
    local items = self._memberListView:getItems()
    for i = 1, #items do
      local item = self._memberListView:getItem(i - 1)
      if item then
          item.idxType = idx
          item.descInfo = currentShowBuilds[i]
          item:getChildByName("Panel_baolei"):getChildByName("btn_put"):addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
               print("btn clicked")
               if self._inputHandler then
                  local map_element_id =  item.descInfo.element_id
                  print(map_element_id,self._changePageIdx)
                  self._inputHandler(map_element_id,self._changePageIdx)
               else
                   local map_element_id =  item.descInfo.element_id
                   local type = self._changePageIdx
                   local pos = cc.p(g_PlayerMode.GetData().x,g_PlayerMode.GetData().y)
                   g_guideManager.removeGameFeature(g_guideManager.gameFeatures.ALLIANCE)
                   require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(pos,function()
                        local successHandler = function(bigTileIndexSelected)
                            g_allianceManorData.RequestCreateGuildBuild(bigTileIndexSelected.x,bigTileIndexSelected.y,map_element_id,type)
                        end
                        local cancleHandler = function()
                            
                        end
                        
                        require("game.maplayer.worldMapLayer_bigMap").openInputMenu_build(map_element_id, pos,successHandler, cancleHandler)
                   end)
               end
               
               self:removeFromParent()
            end
          end)
          
          local positionLabel = item:getChildByName("Panel_baolei"):getChildByName("build_position"):getChildByName("text_1")
          positionLabel:setTouchEnabled(true)
          positionLabel.idx = i
          positionLabel:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
               if self._isFormWorldMap then
                  return
               end
            
               print("position clicked")
               local serverData = currentShowBuilds[sender.idx].serverData
               self:removeFromParent()
               if g_AllianceMode.getMainView() then
                   g_AllianceMode.getMainView():removeFromParent()
               end
               require("game.maplayer.changeMapScene").gotoWorldAndOpenInterface_BigTileIndex( {x = serverData.x,y = serverData.y} )
               
            end
          end)
          
          local canCreateGuildBuildInfo = self._canCreateGuildBuilds[idx] --{"map_element_id":101,"current":1,"max":1}
          if canCreateGuildBuildInfo then
              item.canCreateGuildBuildInfo = canCreateGuildBuildInfo
              item.currentIndex = i
          end
          
          self:updateMemberItem(item,currentShowBuilds[i])
      end
    end

end

function AllianceManorLayer:updateMemberItem(item,buildDescInfo)
    local configId =  buildDescInfo.element_id
    configId = tonumber(configId)
    if buildDescInfo.serverData then
        configId = buildDescInfo.serverData.map_element_id
    end
    local buildInfo = g_data.map_element[configId]
    assert(buildInfo,configId.."")
    
    local serverData = buildDescInfo.serverData
    
    item:getChildByName("Panel_baolei"):getChildByName("label_requirement"):setString(g_tr("allianceManorBuildCondition"))
    item:getChildByName("Panel_baolei"):getChildByName("label_2"):setString(g_tr("allianceManorBuildEffect"))

    item:getChildByName("Panel_baolei"):getChildByName("build_position"):getChildByName("text_1"):setVisible(serverData ~= nil)
    --item:getChildByName("Panel_baolei"):getChildByName("build_position"):getChildByName("text_2"):setVisible(serverData == nil)--暂未开启/未驻防
    item:getChildByName("Panel_baolei"):getChildByName("build_position"):getChildByName("Image_8_0"):setVisible(false)
    
    item:getChildByName("Panel_baolei"):getChildByName("pic"):loadTexture(g_resManager.getResPath(buildInfo.alliance_img))
    
    local btnBuild = item:getChildByName("Panel_baolei"):getChildByName("btn_put")
    btnBuild:setVisible(false)
    
    if serverData == nil and g_AllianceMode.isAllianceManager() and item.currentIndex <= item.canCreateGuildBuildInfo.max then
        btnBuild:setVisible(true)
    end

    if item.canCreateGuildBuildInfo then
       local statusLabel = item:getChildByName("Panel_baolei"):getChildByName("build_position"):getChildByName("text_2")
       local statusStr = ""
       local color = g_Consts.ColorType.Red
       if item.currentIndex > item.canCreateGuildBuildInfo.max then
          statusStr = g_tr("allianceBuildLocked")
       else
          if serverData then
              if serverData.status == 0 then
                  statusStr = g_tr("allianceBuildConstructing")
                  color = g_Consts.ColorType.Blue
              else
                  --TODO:判断是否已驻防
                  statusStr = g_tr("allianceBuildConstructed")
                  color = g_Consts.ColorType.Green
              end
          else
              statusStr = g_tr("allianceBuildUnLocked")
          end
       end
       if item.idxType == 3 then --联盟资源
            local haveAnResourceBuilded = false
--            for key, var in pairs(self._currentShowBuilds) do
--               if var.serverData then
--                   haveAnResourceBuilded = true
--                   break
--               end
--            end
--            
--            btnBuild:setVisible(not haveAnResourceBuilded and self._isFormWorldMap)
            if item.canCreateGuildBuildInfo.max > 0 then
                if item.canCreateGuildBuildInfo.current > 0 then
                    haveAnResourceBuilded = true
                end
            end
            
            if haveAnResourceBuilded then
                if serverData then
                    if serverData.status == 0 then
                      statusStr = g_tr("allianceBuildConstructing")
                      color = g_Consts.ColorType.Blue
                    else
                        --TODO:判断是否已驻防/采集
                        statusStr = g_tr("allianceBuildConstructed")
                        color = g_Consts.ColorType.Green
                    end
                else
                    statusStr = g_tr("allianceBuildCannotInput")
                end
                btnBuild:setVisible(false)
            else
                if item.canCreateGuildBuildInfo.max > 0 then
                    statusStr = g_tr("allianceBuildUnLocked")
--                    if self._isFormWorldMap then
--                        if serverData == nil and g_AllianceMode.isAllianceManager() then
--                            btnBuild:setVisible(true)
--                        end
--                    end
                    if serverData == nil and g_AllianceMode.isAllianceManager() then
                        btnBuild:setVisible(true)
                    end
                end
            end
       end
       
       statusLabel:setTextColor(color)  
       statusLabel:setString(statusStr)
    end
    
    --item:getChildByName("Panel_baolei"):getChildByName("build_position"):setVisible(serverData ~= nil)
    if buildDescInfo.serverData ~= nil then
        item:getChildByName("Panel_baolei"):getChildByName("build_position"):getChildByName("text_1")
        :setString("X:"..string.formatnumberthousands(serverData.x)..",Y:"..string.formatnumberthousands(serverData.y))
    end
    
    item:getChildByName("Panel_baolei"):getChildByName("text_jianzhum"):setString(g_tr(buildInfo.name))
    item:getChildByName("Panel_baolei"):getChildByName("name"):setVisible(false)
    item:getChildByName("Panel_baolei"):getChildByName("name_0"):setVisible(false)
    item:getChildByName("Panel_baolei"):getChildByName("text_requirement"):setString(g_tr(buildDescInfo.open_condition))
    item:getChildByName("Panel_baolei"):getChildByName("text_effect"):setString(g_tr(buildDescInfo.description))
end

return AllianceManorLayer