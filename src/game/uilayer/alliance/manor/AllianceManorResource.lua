local AllianceManorResource = class("AllianceManorResource",function()
    return cc.Layer:create()
end)

local formatNumberAuto = function(cnt)
    local str = string.formatnumberthousands(cnt)
    if cnt >= 100000 then
        str = string.formatnumberlogogram(cnt)
    end
    return str
end

local allianceManorHelper = require("game.uilayer.alliance.manor.AllianceManorHelper")
function AllianceManorResource:ctor(pagetype,serverData)
    self._type = pagetype  --1存储 2取出
    if pagetype == nil then
        self._type = 1
    end
    
    local timeCost = 0
    local guildInfo = {}
    local serverResourceKeys =  {
        "store_gold",
        "store_food",
        "store_wood",
        "store_stone",
        "store_iron",
        }
    
    local level = g_PlayerMode.GetData().level
    local todayMax = g_data.master[level].day_storage
    local allMax = g_data.master[level].max_warehouse
    local todaySavedResource = 0
    
    
    
--    g_BuffMode.RequestData()
--
--    --buff 效果
--    local buffId = 450
--    local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId)
--    if buffType == 1 then --万分比
--        todayMax = math.ceil(todayMax * (10000 + buffValue)/10000)
--    elseif buffType == 2 then --固定值
--        todayMax = todayMax + buffValue
--    end
    
    local buffId = 450
    todayMax = g_BuffMode.calculateFinalValueByBuffId(todayMax,buffId)
   
--    local allbuffs = g_BuffMode.GetData()   
--    local buffValue = 0
--    local buffId = 450
--    local buffKeyName = g_data.buff[buffId].name
--
--    if allbuffs and allbuffs[buffKeyName] then
--        if tonumber(allbuffs[buffKeyName].v) > 0 then
--           buffValue = allbuffs[buffKeyName].v
--        end
--    end
--    
--    local buffType = g_data.buff[buffId].buff_type
--    if buffType == 1 then --万分比
--        todayMax = math.ceil(todayMax * (10000 + buffValue)/10000)
--    elseif buffType == 2 then --固定值
--        todayMax = todayMax + buffValue
--    end
    
    
    local function onRecv(result, msgData)
      if(result==true)then
          --dump(msgData)
          guildInfo = msgData.PlayerGuild
      end
    end
    g_sgHttp.postData("data/index",{name = {"PlayerGuild",}},onRecv)
    
    local callback = function(result, msgData)
        if result == true then
           for key, var in pairs(msgData.time) do
           	   timeCost = var
           	   break
           end
        end
    end
    g_sgHttp.postData("map/getGotoTime", { x = serverData.x,y = serverData.y,type = 5 }, callback)

    todaySavedResource = guildInfo.last_day_store or 0
    local lastStoreTime = guildInfo.last_store_time
    local currentTime = g_clock.getCurServerTime()
    if not g_clock.isSameDay(currentTime,lastStoreTime) then
        todaySavedResource = 0
    end
    
    local totalSavedResource = 0
    local saveCnt = todaySavedResource
    local saveCntTotal = totalSavedResource
    
	local uiLayer =  g_gameTools.LoadCocosUI("alliance_resource.csb",5)
	g_resourcesInterface.installResources(uiLayer)
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
    
    baseNode:getChildByName("text_tips_rule"):setString(g_tr("resourceSizeRule"))
    baseNode:getChildByName("Text_7"):setString(g_gameTools.convertSecondToString(timeCost))
    
    --不包含type类型的当前已经选择的总数
    local function getTotalWarehouseSizeButType(type)
        assert(type == 1 or type == 2 or type == 3 or type == 4 or type == 5)
        
        local m_cnt = 0
        for i = 1, 5 do
          if i ~= type then
              local cnt = baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider"):getPercent()
              cnt = allianceManorHelper.convertToWarehouseSize(i,cnt)
              m_cnt = m_cnt + cnt
          end
        end
        
        return m_cnt
    end
    
    --type类型可选的最大数(最大容量考虑进去)
    local function getMaxReourceSizeByType(type)
        assert(type == 1 or type == 2 or type == 3 or type == 4 or type == 5)
        local m_saveCnt = todaySavedResource
        local m_saveCntTotal = totalSavedResource

        m_saveCnt = m_saveCnt + getTotalWarehouseSizeButType(type)
        m_saveCntTotal = m_saveCntTotal + getTotalWarehouseSizeButType(type)
        
        local wareHouseRemain = math.min(allMax - m_saveCntTotal,todayMax - m_saveCnt)
        local recourceRemain = allianceManorHelper.convertToResourceSize(type,wareHouseRemain)
        return recourceRemain
    end
    
  
    local function percentChangedEvent(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            
            saveCnt = todaySavedResource
            saveCntTotal = totalSavedResource
            
            for i = 1, 5 do
              local cnt = baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider"):getPercent()
              cnt = allianceManorHelper.convertToWarehouseSize(i,cnt)
              saveCnt = saveCnt + tonumber(cnt)
              saveCntTotal = saveCntTotal + tonumber(cnt)
            end
            
            local type = 1
            if slider == baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_1"):getChildByName("Slider") then
                type = 1
            elseif slider == baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_2"):getChildByName("Slider") then
                type = 2
            elseif slider == baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_3"):getChildByName("Slider") then
                type = 3
            elseif slider == baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_4"):getChildByName("Slider") then
                type = 4
            elseif slider == baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_5"):getChildByName("Slider") then
                type = 5
            end

            if self._type == 1 then
                baseNode:getChildByName("daily_limit"):getChildByName("text"):setTextColor(g_Consts.ColorType.Green)
                if saveCnt > todayMax then
                    local max = getMaxReourceSizeByType(type)
                    slider:setPercent(max)
                    saveCnt = todayMax
                    baseNode:getChildByName("daily_limit"):getChildByName("text"):setTextColor(g_Consts.ColorType.Red)
                    
                    local otherSize = getTotalWarehouseSizeButType(type)
                    local csize = allianceManorHelper.convertToWarehouseSize(type,max)
                    saveCntTotal = totalSavedResource + otherSize + csize
                elseif saveCntTotal > allMax then
                    saveCntTotal = allMax
                    baseNode:getChildByName("total_limit"):getChildByName("text"):setTextColor(g_Consts.ColorType.Red)
                    local max = getMaxReourceSizeByType(type)
                    slider:setPercent(max)
                end
                
                baseNode:getChildByName("daily_limit"):getChildByName("text")
                :setString(g_tr("allianceWarehouseTodayMax")..string.formatnumberlogogram(saveCnt).."/"..string.formatnumberlogogram(todayMax))
                
                baseNode:getChildByName("total_limit"):getChildByName("text")
                :setString(g_tr("allianceWarehouseAllMax")..string.formatnumberlogogram(saveCntTotal).."/"..string.formatnumberlogogram(allMax))
            end
            
            local percentStr = formatNumberAuto(slider:getPercent())
            self._inputEditBoxs[type]:setString(percentStr)
            
            baseNode:getChildByName("resource_item_"..type):getChildByName("text_2")
            :setString("+"..slider:getPercent())
            
        elseif eventType == ccui.SliderEventType.slideBallUp then
           
        elseif eventType == ccui.SliderEventType.slideBallDown then
           
        elseif eventType == ccui.SliderEventType.slideBallCancel then
           
        end
    end
    
    --初始化editBox
    self._inputEditBoxs = {}
    for i = 1, 5 do
        local editBox = baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("TextField")
        editBox = g_gameTools.convertTextFieldToEditBox(editBox)
        local slider = baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider")
        local flagCnt = ""
        local editBoxHandler = function(eventType)
            if eventType == "began" then
                flagCnt = editBox:getText()
            elseif eventType == "customEnd" then
                local numStr = string.gsub(editBox:getText(), ",","")
                if tonumber(numStr) == nil then
                  editBox:setText(flagCnt)
                else
                   slider:setPercent(tonumber(numStr))
                   percentChangedEvent(slider,ccui.SliderEventType.percentChanged)
                end
            end
        end
        editBox:registerScriptEditBoxHandler(editBoxHandler)
        table.insert(self._inputEditBoxs,editBox)
    end
    
    
    if self._type == 1 then
        baseNode:getChildByName("text_tips_1"):setString(g_tr("allianceWarehouseStored"))
        baseNode:getChildByName("bg_resource"):getChildByName("text_tips_2"):setString(g_tr("allianceWarehouseMyResource"))
        
    else
        baseNode:getChildByName("text_tips_1"):setString(g_tr("allianceWarehouseMyResource"))
        baseNode:getChildByName("bg_resource"):getChildByName("text_tips_2"):setString(g_tr("allianceWarehouseStored"))
    end
    
    for i = 1, 5 do
      local cnt,resIconPath = g_gameTools.getPlayerCurrencyCount(i)
      baseNode:getChildByName("resource_item_"..i):getChildByName("ico"):loadTexture(resIconPath)
      baseNode:getChildByName("bg_resource"):getChildByName("ico_"..i):loadTexture(resIconPath)
      
      local cntStr = "0"
      if self._type == 1 then
          baseNode:getChildByName("resource_item_"..i):getChildByName("text_1"):setString(guildInfo[serverResourceKeys[i]].."")
          cntStr =  formatNumberAuto(g_gameTools.getPlayerCurrencyCount(i))
          baseNode:getChildByName("bg_resource"):getChildByName("num_"..i):setString(cntStr)
          
          --仓库容量限制
          local todayMaxSmSize = todayMax - todaySavedResource
          cnt = math.min(allianceManorHelper.convertToResourceSize(i,todayMaxSmSize),cnt)
          
          --总容量
          totalSavedResource = allianceManorHelper.convertToWarehouseSize(i,guildInfo[serverResourceKeys[i]]) + totalSavedResource
      else
          local myCntStr =  formatNumberAuto(g_gameTools.getPlayerCurrencyCount(i))
          baseNode:getChildByName("resource_item_"..i):getChildByName("text_1"):setString(myCntStr)
          cnt = guildInfo[serverResourceKeys[i]]
          cntStr =  formatNumberAuto(cnt)
          baseNode:getChildByName("bg_resource"):getChildByName("num_"..i):setString(cntStr)
      end
      
      
      baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Image_8"):loadTexture(resIconPath)
      --baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("TextField"):setString("0")
      self._inputEditBoxs[i]:setString("0")
      baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider"):setPercent(0)
      baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider"):setMaxPercent(cnt)
      baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider"):addEventListener(percentChangedEvent)
      
      baseNode:getChildByName("resource_item_"..i):getChildByName("text_2")
      :setString("+"..baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider"):getPercent())
      
    end
    
    if self._type == 1 then
        
        saveCntTotal = totalSavedResource
        
        baseNode:getChildByName("daily_limit"):getChildByName("text")
        :setString(g_tr("allianceWarehouseTodayMax")..string.formatnumberlogogram(saveCnt).."/"..string.formatnumberlogogram(todayMax))
        
        baseNode:getChildByName("total_limit"):getChildByName("text")
        :setString(g_tr("allianceWarehouseAllMax")..string.formatnumberlogogram(saveCntTotal).."/"..string.formatnumberlogogram(allMax))
    else
        baseNode:getChildByName("daily_limit"):getChildByName("text"):setString("")
        baseNode:getChildByName("total_limit"):getChildByName("text"):setString("")
    end
    
    baseNode:getChildByName("btn_save"):addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local resArr = {}
            local gold = 0
            local food = 0
            local wood = 0
            local stone = 0
            local iron = 0
            for i = 1, 5 do
                local cnt = baseNode:getChildByName("bg_resource_select"):getChildByName("select_row_"..i):getChildByName("Slider"):getPercent()
                if i == 1 then
                    gold = cnt
                elseif i == 2 then
                    food = cnt
                elseif i == 3 then
                    wood = cnt
                elseif i == 4 then
                    stone = cnt
                elseif i == 5 then
                    iron = cnt
                end
            end
            
            resArr = {["1"] = gold,["2"] = food,["3"] = wood, ["4"] = stone,["5"] = iron}
            --1金 2粮 3木 4石 5铁
            local total = 0
            for key, var in pairs(resArr) do
            	total = total + var
            end
            
            if total <= 0 then
               g_airBox.show(g_tr("allianceWarehouseSelectTip"))
               return
            end
                
            print("click handler")
            if self._type == 1 then
               local resultHandler = function(result, msgData)
                  print("result:",result)
                  if result then
                      require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                      self:removeFromParent()
                  end
                end
                g_sgHttp.postData("guild/storeResource",{resourceArr = resArr},resultHandler)
            else
                local resultHandler = function(result, msgData)
                  print("result:",result)
                  if result then
                      require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                      self:removeFromParent()
                  end
                end
                g_sgHttp.postData("guild/takeOutResource",{resourceArr = resArr},resultHandler)
            end
        end
    end)
    
    if self._type == 1 then
        baseNode:getChildByName("btn_save"):getChildByName("Text"):setString(g_tr("allianceWarehouseInTip"))
        baseNode:getChildByName("bg_resource_select"):getChildByName("text"):setString(g_tr("allianceWarehouseSelectInTip"))
    else
        baseNode:getChildByName("btn_save"):getChildByName("Text"):setString(g_tr("allianceWarehouseOutTip"))
        baseNode:getChildByName("bg_resource_select"):getChildByName("text"):setString(g_tr("allianceWarehouseSelectOutTip"))
    end
    
end


function AllianceManorResource:updateView()
    
end

return AllianceManorResource