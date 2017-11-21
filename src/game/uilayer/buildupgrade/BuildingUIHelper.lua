local BuildingUIHelper = {}

local function updatePreBuildResItem(preBuildItem,prebuildId)
   
    local prebuildInfo = g_data.build[prebuildId]
    local label = preBuildItem:getChildByName("Panel"):getChildByName("Text_16")
    if prebuildInfo then
        local name = g_tr(prebuildInfo.build_name)
        label:setString(g_tr("buildCondition",{name = name,level = prebuildInfo.build_level}))
        preBuildItem:getChildByName("Panel"):getChildByName("Image_30"):loadTexture(g_resManager.getResPath(prebuildInfo.img))
    end

    local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(prebuildId)
    
    local isEnough = enoughCount >  0
    
    if isEnough then
        label:setTextColor(g_Consts.ColorType.Normal)
    else
        label:setTextColor(g_Consts.ColorType.Red)
    end
    
    preBuildItem:getChildByName("Panel"):getChildByName("Button_huode")
    :setVisible(not isEnough)
    
    preBuildItem:getChildByName("Panel"):getChildByName("Image_34"):setVisible(isEnough)
    preBuildItem:getChildByName("Panel"):getChildByName("Image_35"):setVisible(not isEnough)
   
    return isEnough
end

--item helper
local function updateCostItem(costItem,costInfo,position)
    local playerData = require("game.gamedata.playerData").GetData()
    local haveRes = 0
    local type = costInfo[1]
    haveRes = g_gameTools.getPlayerCurrencyCount(type)
    local icon = costItem:getChildByName("Panel"):getChildByName("Image_28")
    icon:loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + type))
    
    local valueLabel = costItem:getChildByName("Panel"):getChildByName("Text_16")
    local costValue = costInfo[2]
    
    local buffId = 373
    local buffKeyName = g_data.buff[buffId].name
    assert( buffKeyName == "build_cost_reduce" ,"build_cost_reduce")--建筑建造消耗减少
    local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,position)
    if buffType == 1 then --万分比
       costValue = costValue * (10000 - buffValue)/10000
    elseif buffType == 2 then --固定值
       costValue = costValue - buffValue
    end
    
    --buff 效果
--    local allbuffs = g_BuffMode.GetData()
--    local buffValue = 0
--    local buffId = 373
--    local buffKeyName = g_data.buff[buffId].name
--    assert( buffKeyName == "build_cost_reduce" ,"build_cost_reduce")--建筑建造消耗减少
--    if allbuffs and allbuffs[buffKeyName] then
--        if tonumber(allbuffs[buffKeyName].v) > 0 then
--           buffValue = allbuffs[buffKeyName].v
--        end
--        
--        local buffType = g_data.buff[buffId].buff_type
--        if buffType == 1 then --万分比
--           costValue = costValue * (10000 - buffValue)/10000
--        elseif buffType == 2 then --固定值
--           costValue = costValue - buffValue
--        end
--    end
    
    valueLabel:setString(string.formatnumberthousands(costValue))
    
    local getMoreBtn = costItem:getChildByName("Panel"):getChildByName("Button_huode")
    getMoreBtn.costType = costInfo[1]
    
    local isEnough = (haveRes >= costValue)
    
    if isEnough then
        valueLabel:setTextColor(g_Consts.ColorType.Normal)
    else
        valueLabel:setTextColor(g_Consts.ColorType.Red)
    end
    
    costItem:getChildByName("Panel"):getChildByName("Image_34"):setVisible(isEnough)
    costItem:getChildByName("Panel"):getChildByName("Image_35"):setVisible(not isEnough)
    
    costItem:getChildByName("Panel"):getChildByName("Button_huode"):setVisible(not isEnough)
    
    return isEnough
end

local function updateIconInfoItem(item,type,value)
    local iconImage =  item:getChildByName("scale_node"):getChildByName("Image_1")
    local size = iconImage:getContentSize()
    iconImage:removeAllChildren()
    
    local img = nil
    local imgExtr = nil
    local str = ""
    if type == 1 then
        img = g_data.soldier[value].img_head
        str = g_tr(g_data.soldier[value].soldier_name)
        imgExtr = g_resManager.getRes(g_data.soldier[value].img_level)
    elseif type == 2 then
        img = g_data.trap[value].img_head
        str = g_tr(g_data.trap[value].trap_name)
        imgExtr = g_resManager.getRes(g_data.trap[value].img_level)
    elseif type == 3 then
        img = g_data.science[value].img
        str = g_tr(g_data.science[value].name)
    elseif type == 4 then
        --学习栏位 学院取消了，所以这个忽略
    end
    
    if img then
        iconImage:loadTexture(g_resManager.getResPath(img))
        if imgExtr then
            imgExtr:setPosition(cc.p(size.width/2,25))
            iconImage:addChild(imgExtr)
        end
    end
    
    item:getChildByName("scale_node"):getChildByName("Text_1")
    :setString(str)
    
end

--同一类型的资源建筑的总产量
--build_original_id:原始id
--is_calculate_double:返回的数值是否包括资源提速，默认为true
function BuildingUIHelper.getResourceBuildOutPut(build_original_id,is_calculate_double)
    assert(build_original_id and 
       ( build_original_id == 21 
         or build_original_id == 26
         or build_original_id == 31
         or build_original_id == 36
         or build_original_id == 16),"not a resource build id")

    if is_calculate_double == nil then
        is_calculate_double = true
    end
    
    local output = 0
    local originalOutPut = 0 --不带buff加成部分的数量

    local allBuilds = g_PlayerBuildMode.GetData()
    for key, serverData in pairs(allBuilds) do
        if serverData.origin_build_id == build_original_id then
            local buildInfo = g_data.build[serverData.build_id]
            for key, outputGroup in pairs(buildInfo.output) do
                local type = outputGroup[1]
                local value = outputGroup[2]
                output = output + value
                originalOutPut = originalOutPut + value
                
                --buff 效果
                local buffId = g_data.output_type[type].buff_id
                local plusType = g_data.output_type[type].plus_type
                local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,serverData.position)
                if plusType == 1 then
                    buffValue = value * buffValue / 10000
                elseif plusType == 2 then
                    --百分比
                    buffValue = buffValue/10000
                elseif plusType == 3 then
                    --直接固定值
                end
                
                --根据策划的需求，不需要显示提速的加成，所以注释掉了
                --资源建筑提速
--                local currentTime = g_clock.getCurServerTime()
--                if is_calculate_double and serverData.ex_addition_end_time - currentTime > 0 then
--                    buffValue = buffValue + value
--                end
                
                if buffValue > 0 then
                   output = output + buffValue
                end
            end
        end
    end
    
    return output,originalOutPut
end

--府衙总览面板
local function createGovernmentHousePanle()
    local container = cc.Node:create()
    
    local propertyItem = cc.CSLoader:createNode("building_upgrade_tiao_0.csb")
    local listSize = propertyItem:getChildByName("Panel_tiao3_0"):getContentSize()
    propertyItem:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0_0")
    :setString("")
                
    
    local row = 0
    
    --各资源建筑总产量
    do
        --铁矿厂 ，石料厂，伐木场，农田，金矿
        local buildStartIds = {36001,31001,21001,26001,16001}
        
        for key, buildConfigId in ipairs(buildStartIds) do
            local buildInfo = g_data.build[buildConfigId]
        	local totalOutPutCnt,originalOutPutCnt = BuildingUIHelper.getResourceBuildOutPut(buildInfo.origin_build_id)
        	local item = propertyItem:clone()
            container:addChild(item)
            
            local buildName = g_tr_original(buildInfo.build_name)
            
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
            :setString(g_tr("overviewResourceBuild",{build_name = buildName}))
            
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
            :setString(math.floor(originalOutPutCnt).."/h")
            
            local buffOutPut = totalOutPutCnt - originalOutPutCnt
            if buffOutPut > 0 then
                item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0_0")
                :setString("+"..math.floor(buffOutPut).."/h")
            end
            
        	item:setPositionY((listSize.height) * row)
        	
        	row = row + 1
        end
    end
    
    --预备役士兵数
    do
        local item = propertyItem:clone()
        container:addChild(item)
        item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
        :setString(g_tr("overviewIdleArmy"))
        item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
        :setString(g_SoldierMode.GetAllSoldierNumber().."")
        
        item:setPositionY((listSize.height) * row)
        row = row + 1
    end
    
    --各军团士兵数
    do
        local armys = g_ArmyUnitMode.GetArmyAllSoldier()
        local armyCnt = #armys
        for i = 1, armyCnt do
        	local item = propertyItem:clone()
            container:addChild(item)
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
            :setString(g_tr("overviewArmy",{idx = armyCnt - i + 1}))
            
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
            :setString(armys[armyCnt - i + 1].."")
            
            item:setPositionY((listSize.height) * row)
            
            row = row + 1
        end
    end
    
    --可招募武将数量
    do
        local playerPubData = require("game.gamedata.PlayerPub")
        local max,originalMax = playerPubData.getMaxGeneralToRecruit()
        
        local item = propertyItem:clone()
        container:addChild(item)
        item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
        :setString(g_tr("overviewGeneralNum"))
        item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
        :setString(originalMax.."")
        
        local buffMax = max - originalMax
        if buffMax > 0 then
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0_0")
            :setString("+"..buffMax)
        end
        
        item:setPositionY((listSize.height) * row)
        row = row + 1
    end
    
    container:setContentSize(cc.size(listSize.width,listSize.height*row))
    return container
end

--创建一个建筑信息详情面板
function BuildingUIHelper.createInfoPanle(buildInfo,jumpToHandler,delegate,isUpgrade)
    assert(buildInfo)
    local isUpgradeOrBuild = (jumpToHandler ~= nil)
    local con = cc.Node:create()
    local sonContainers = {}
    local innerHeight = 0
    local isMeetConditions = true --match condition 前置条件
    local isResourceEnough = true  --资源
    local isQueueMeet = true  --队列
    
    --local allbuffs = {}
    --if not isUpgradeOrBuild then --注释掉了 因为升级也要用到buff（资源减少等）
         --请求buff数据
        --g_BuffMode.RequestData()
        --allbuffs = g_BuffMode.GetData()
    --end
    
    --驻守武将的buff
    --local allGeneralBuffs = {}
    --if not isUpgradeOrBuild and buildInfo.serverData then
        --g_BuffMode.RequestGeneralBuffData(buildInfo.serverData.position)
        --allGeneralBuffs = g_BuffMode.getGeneralBuffData(buildInfo.serverData.position)
    --end
    
    local updateView = function()
        if delegate then
            delegate:updateView()
        end
    end
    
    local currentBuildInfo = buildInfo --用于显示解锁信息，（升级页面显示的信息除了解锁信息，都是建筑下级的信息）
    if isUpgrade then
        buildInfo = g_PlayerBuildMode.FindBuildConfig_lv_Next_ConfigID(buildInfo.id) --升级页面显示的信息除了解锁信息，都是建筑下级的信息
    end

    if jumpToHandler then
        --升级条件title
        local upgradeTitle = cc.CSLoader:createNode("building_upgrade_item_3.csb")
        con:addChild(upgradeTitle)
        table.insert(sonContainers,upgradeTitle)
        
        upgradeTitle:getChildByName("Panel_tiao1"):getChildByName("Text_2"):setString("")
        local strConditionTitle = g_tr("buildConditionTitle")
        if isUpgrade then
            strConditionTitle = g_tr("upgradeConditionTitle")
        end
        upgradeTitle:getChildByName("Panel_tiao1"):getChildByName("Text_1"):setString(strConditionTitle)
        upgradeTitle:setContentSize(upgradeTitle:getChildByName("Panel_tiao1"):getContentSize())
        
        innerHeight = innerHeight + upgradeTitle:getContentSize().height - 5
        
        --前置建筑条件
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setContentSize(cc.size(640, 130))
        listView:setClippingEnabled(false)
        listView:setTouchEnabled(false)
        
        con:addChild(listView)
        
        local listHeight = 0
        local preBuildItem = cc.CSLoader:createNode("building_upgrade_item_2.csb")
        preBuildItem:setContentSize(preBuildItem:getChildByName("Panel"):getContentSize())
        preBuildItem:getChildByName("Panel"):getChildByName("Button_huode"):getChildByName("Text_26")
        :setString(g_tr("jumpTo"))
        
        local touchedHandler = function(sender,eventType)
             if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                jumpToHandler(sender.buildId)
             end
        end
        
        local preBuilds = buildInfo.pre_build_id
        for key, buildId in pairs(preBuilds) do
           local item = preBuildItem:clone()
           listView:pushBackCustomItem(item)
           if updatePreBuildResItem(item,buildId) == false then
              isMeetConditions = false
           end
           
           item:getChildByName("Panel"):getChildByName("Button_huode")
           :addTouchEventListener(touchedHandler)
           
           item:getChildByName("Panel"):getChildByName("Button_huode").buildId = buildId
           listHeight = listHeight + item:getContentSize().height
        end
        
        --队列条件
        local freeBuild = g_PlayerBuildMode.FindBuild_InFree()
        local currentTime = g_clock.getCurServerTime()
        
        --local timeRemain = require("game.uilayer.mainSurface.mainSurfaceQueue").chargeQueueResidualTime() --收费队列剩余时间
        local isChargeEnabled,isHaveBuyQueue = BuildingUIHelper.checkChargeQueue(buildInfo,delegate._serverData)

        if freeBuild ~= nil and freeBuild.build_finish_time - currentTime > 0 and not isChargeEnabled then
            local buildInfo = g_data.build[tonumber(freeBuild.build_id)]
            assert(buildInfo)
            isQueueMeet = false
            local speedUpHandler = function(sender,eventType)
                 if eventType == ccui.TouchEventType.ended then
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    local freeBuild = g_PlayerBuildMode.FindBuild_InFree()
                    if freeBuild ~= nil and freeBuild.build_finish_time then
                        local doSpeedUpHandler = function(costGem)
                             local function onRecv(result, msgData)
                                if(result==true)then
                                  --dump(msgData)
                                  g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
								  require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
								  
                                  updateView()
                                end
                              end
                             g_sgHttp.postData("build/accelerate",{position = freeBuild.position,type = 1},onRecv)
                        end
                        local finishTime = freeBuild.build_finish_time
                        g_msgBox.showSpeedUp(finishTime, g_tr("speedUpBuildingCD"), nil, nil, doSpeedUpHandler)
                        
                    end
                 end
            end
        
            local item = preBuildItem:clone()
            listView:pushBackCustomItem(item)
            local label = item:getChildByName("Panel"):getChildByName("Text_16")
            local color = cc.c4b(255,0,0,255)
            label:setTextColor(color)
            item:getChildByName("Panel"):getChildByName("Button_huode")
            :addTouchEventListener(speedUpHandler)
            
            local secondsLeft = freeBuild.build_finish_time - currentTime
            local updateTimeStr = function()
                currentTime = g_clock.getCurServerTime()
                secondsLeft = freeBuild.build_finish_time - currentTime
                --secondsLeft = secondsLeft - 1
                if secondsLeft < 0 then
                    secondsLeft = 0
                    label:stopAllActions()
                else
                    local timeStr = g_gameTools.convertSecondToString(secondsLeft)
                    local str = g_tr("buildingNow",{buildname = g_tr(buildInfo.build_name),time = timeStr})
                    label:setString(str)
                end
            end
            
            local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
            local action = cc.RepeatForever:create(seq)
            label:runAction(action)
            
            updateTimeStr()
            
            item:getChildByName("Panel"):getChildByName("Button_huode"):getChildByName("Text_26")
            :setString(g_tr("speedUp"))--加速
            
            item:getChildByName("Panel"):getChildByName("Image_30"):loadTexture(g_resManager.getResPath(buildInfo.img))
 
            local isEnough = secondsLeft <= 0
            
            item:getChildByName("Panel"):getChildByName("Button_huode")
            :setVisible(not isEnough)
            
            item:getChildByName("Panel"):getChildByName("Image_34"):setVisible(isEnough)
            item:getChildByName("Panel"):getChildByName("Image_35"):setVisible(not isEnough)
            listHeight = listHeight + item:getContentSize().height
        end
        
        --资源条件
        local costItem = cc.CSLoader:createNode("building_upgrade_item_1.csb")
        costItem:setContentSize(costItem:getChildByName("Panel"):getContentSize())
        costItem:getChildByName("Panel"):getChildByName("Button_huode"):getChildByName("Text_26")
        :setString(g_tr("getMore"))
        
        local getMoreHandler = function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                local costType = sender.costType
                require("game.uilayer.shop.UseResourceView").show(costType, updateView)
            end
        end
        
        local costGroup = buildInfo.cost
        for key, costInfo in pairs(costGroup) do
            local item = costItem:clone()
            listView:pushBackCustomItem(item)
            
            local position = nil
            if buildInfo.serverData then
                position = buildInfo.serverData.position
            end
            
            if updateCostItem(item,costInfo,position) == false then
                isResourceEnough = false
            end
            local getMoreBtn = item:getChildByName("Panel"):getChildByName("Button_huode")
            getMoreBtn:addTouchEventListener(getMoreHandler)
            listHeight = listHeight + item:getContentSize().height
        end
        
        if buildInfo.cost_item_id > 0 then --消耗道具
            local item = costItem:clone()
            listView:pushBackCustomItem(item)
            
            local valueLabel = item:getChildByName("Panel"):getChildByName("Text_16")
           
            local costValue = buildInfo.cost_item_num
            
            local itemData = g_BagMode.FindItemByID(buildInfo.cost_item_id)
            local haveNum = 0
            if itemData then
                haveNum = itemData.num or 0
            end
            
            local icon = item:getChildByName("Panel"):getChildByName("Image_28")
            icon:loadTexture(g_resManager.getResPath(g_data.item[buildInfo.cost_item_id].res_icon))
            
            valueLabel:setString(string.formatnumberthousands(costValue))
            
            local isEnough = (haveNum >= costValue)
            if isEnough then
                valueLabel:setTextColor(g_Consts.ColorType.Normal)
            else
                valueLabel:setTextColor(g_Consts.ColorType.Red)
                valueLabel:setString(string.formatnumberthousands(haveNum).."/"..string.formatnumberthousands(costValue))
                isResourceEnough = false
            end
            
            local getMoreItemHandler = function(sender)
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                local callback = function()
                    if delegate then
                        if delegate.callbacks then
                            if delegate.callbacks.onClose then
                                delegate.callbacks.onClose()
                            end
                        end
                        delegate:removeFromParent()
                    end
                end
                local view = require("game.uilayer.common.ItemPathView").new(g_Consts.DropType.Props,sender.costType, callback)
                g_sceneManager.addNodeForUI(view)
            end
            
            local getMoreBtn = item:getChildByName("Panel"):getChildByName("Button_huode")
            getMoreBtn.costType = buildInfo.cost_item_id
            getMoreBtn:addClickEventListener(getMoreItemHandler)
           
            item:getChildByName("Panel"):getChildByName("Image_34"):setVisible(isEnough)
            item:getChildByName("Panel"):getChildByName("Image_35"):setVisible(not isEnough)
            item:getChildByName("Panel"):getChildByName("Button_huode"):setVisible(not isEnough)
            
            listHeight = listHeight + item:getContentSize().height
        end
        
        listView:setContentSize(listView:getContentSize().width,listHeight)
        listView:jumpToBottom()
        
        --print("listView:getInnerContainer():getContentSize().height:",listHeight)
        innerHeight = innerHeight + listHeight
        
        table.insert(sonContainers,listView)
    end
    
    
    --属性信息
    if #buildInfo.output > 0 or buildInfo.storage_max > 0 then
        local infoContainer = cc.Node:create()
        local propertyItem = cc.CSLoader:createNode("building_upgrade_tiao_0.csb")
        local listSize = propertyItem:getChildByName("Panel_tiao3_0"):getContentSize()
        
        local widthDistance = 20
        local heightDistance = 0
        
        local row = 0
        local maxRow = #buildInfo.output
        
        if buildInfo.storage_max > 0 then
            maxRow = maxRow + 1
        end
        
        for key, outputGroup in pairs(buildInfo.output) do
            local type = outputGroup[1]
            local value = outputGroup[2]
            if type == 12 then --屯所要加上初始援军数量
                value = value + tonumber(g_data.starting[57].data) 
            end
            
            if value > 0 then
                local valStr = ""
                --local buffId = g_data.output_type[type].buff_id
                local buffId = 99999
                if buffId > 0 then
                    --local numType = g_data.buff[buffId].buff_type
                    local numType = g_data.output_type[type].num_type
                    if numType == 1 then
                        valStr = (value / 10000 * 100).."%"
                    else
                        valStr = string.formatnumberthousands(value)
                    end
                    
                    local item = propertyItem:clone()
                    infoContainer:addChild(item)
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
                    :setString(g_tr(g_data.output_type[type].desc))
                    
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
                    :setString(valStr)
                    
                    local valStrAdd = ""
                    if isUpgradeOrBuild then
                       local preLevelInfo = g_data.build[buildInfo.id - 1]
                       if preLevelInfo then
                          local preValStr = ""
                          local preLevelNum = preLevelInfo.output[key][2]
                          if type == 12 then --屯所要加上初始援军数量
                            preLevelNum = preLevelNum + tonumber(g_data.starting[57].data) 
                          end
                          if numType == 1 then
                              preValStr = ((preLevelNum / 10000)*100).."%"
                          else
                              preValStr = string.formatnumberthousands(preLevelNum)
                          end
                          
                          local targetLevelNum = value
                          local addNum = targetLevelNum - preLevelNum
                          item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
                          :setString(preValStr)
                          
                          if numType == 1 then
                              valStrAdd = "+ "..((addNum / 10000)*100).."%"
                          else
                              valStrAdd = "+ "..string.formatnumberthousands(addNum)
                          end
                       end
                    else
                        --buff 效果
                        local buffId = g_data.output_type[type].buff_id
                        local plusType = g_data.output_type[type].plus_type
                        local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,buildInfo.serverData.position)
                        if plusType == 1 then
                            buffValue = math.ceil(value * buffValue / 10000)
                        elseif plusType == 2 then
                            --百分比
                            buffValue = buffValue/10000
                        elseif plusType == 3 then
                            --直接固定值
                        end
                        
                        --根据策划的需求，不需要显示提速的加成，所以注释掉了
--                        --资源建筑提速
--                        local currentTime = g_clock.getCurServerTime()
--                        if buildInfo.serverData.ex_addition_end_time - currentTime > 0 then
--                            buffValue = buffValue + value
--                        end
                        
                        if buffValue > 0 then
                            if plusType == 1 then
                                valStrAdd = "+ "..string.formatnumberthousands(buffValue)
                            elseif plusType == 2 then
                                valStrAdd = "+ "..(buffValue*100).."%"
                            else
                                valStrAdd = "+ "..string.formatnumberthousands(buffValue)
                            end
                        end
                    end
                    
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0_0")
                    :setString(valStrAdd)
                    
                    item:setPositionY((listSize.height + heightDistance) * (maxRow - row - 1))
                    
                    row = row + 1
                else
                    maxRow = maxRow - 1
                end
            end
            
        end
        --资源最大存储信息
        if buildInfo.storage_max > 0 then
            local value = buildInfo.storage_max
            local valStr = string.formatnumberthousands(value)
            
            local item = propertyItem:clone()
            infoContainer:addChild(item)
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
            :setString(g_tr("recourseBuildMaxStore"))
            
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
            :setString(valStr)
            
            local valStrAdd = ""
            local preLevelInfo = g_data.build[buildInfo.id - 1]
            if isUpgradeOrBuild then
                if preLevelInfo then
                    local preLevelNum = preLevelInfo.storage_max
                    local preValStr = string.formatnumberthousands(preLevelNum)
               
                    local targetLevelNum = value
                    local addNum = targetLevelNum - preLevelNum
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
                    :setString(preValStr)
                    valStrAdd = "+ "..string.formatnumberthousands(addNum)
                end
            else
                local currentTime = g_clock.getCurServerTime()
                if buildInfo.serverData.ex_addition_end_time - currentTime > 0 then
                    local num = tonumber(g_data.starting[98].data)
                    local addNum = value * num - value
                    if addNum > 0 then
                        valStrAdd = "+ "..string.formatnumberthousands(addNum)
                    end
                end
            end
       
            item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0_0")
            :setString(valStrAdd)
            
            item:setPositionY((listSize.height + heightDistance) * (maxRow - row - 1))
            
            row = row + 1
        end
        
        
        if row > 0 then
            --建筑属性title
            local nextLevelTitle = cc.CSLoader:createNode("building_upgrade_item_3.csb")
            con:addChild(nextLevelTitle)
            table.insert(sonContainers,nextLevelTitle)
            
            nextLevelTitle:getChildByName("Panel_tiao1"):getChildByName("Text_2"):setString("")
            local str = g_tr("buildProperty")
            if isUpgrade then
                str = g_tr("buildNextLvProperty")
            end
            nextLevelTitle:getChildByName("Panel_tiao1"):getChildByName("Text_1"):setString(str)
            nextLevelTitle:setContentSize(nextLevelTitle:getChildByName("Panel_tiao1"):getContentSize())
            
            innerHeight = innerHeight + nextLevelTitle:getContentSize().height - 5
        end
    
        con:addChild(infoContainer)
        table.insert(sonContainers,infoContainer)
        infoContainer:setContentSize(cc.size(listSize.width,(listSize.height + heightDistance) * maxRow))
        
        innerHeight = innerHeight + ((listSize.height + heightDistance) * maxRow)
    end
    
    --解锁信息
    if #currentBuildInfo.unlock > 0 then
    
        local unlockContainer = cc.Node:create()
        
        local propertyItem = cc.CSLoader:createNode("building_upgrade_tiao_0.csb")
        local listSize = propertyItem:getChildByName("Panel_tiao3_0"):getContentSize()

        local heightDistance = 0
        local row = 0
        local maxRow = math.ceil(#currentBuildInfo.unlock/2)
        
        local iconUnlockShow = nil
        local lastShowType = nil
        local iconTotalWidth = 0
        local labelTextShow = nil
        for key, outputGroup in pairs(currentBuildInfo.unlock) do
            local type = outputGroup[1]
            local showType = outputGroup[2]
            local value = outputGroup[3]
            
            if lastShowType then
                assert(lastShowType == showType,"showType must same as lastShowType")
            end
            
            --local item = propertyItem:clone()
            local item = nil
            if showType == 0 then
                if type == 5 then --纯文字提示信息
                    if isUpgradeOrBuild then
                        if labelTextShow == nil then
                            
                            --升级效果文字描述title
                            local nextLevelTitle = cc.CSLoader:createNode("building_upgrade_item_3.csb")
                            con:addChild(nextLevelTitle)
                            table.insert(sonContainers,nextLevelTitle)
                            
                            nextLevelTitle:getChildByName("Panel_tiao1"):getChildByName("Text_2"):setString("")
                            local str = g_tr("upgradeEffect")
                            nextLevelTitle:getChildByName("Panel_tiao1"):getChildByName("Text_1"):setString(str)
                            nextLevelTitle:setContentSize(nextLevelTitle:getChildByName("Panel_tiao1"):getContentSize())
                            
                            innerHeight = innerHeight + nextLevelTitle:getContentSize().height

                        
                            local str = g_tr(value)
                            --哨塔的升级效果特殊处理
                            if buildInfo.origin_build_id == 12 then
                                str = g_tr("towerBuildEffectDesc")
                            end
                            
                            local tmpUIText = propertyItem:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
                            labelTextShow = cc.Label:createWithTTF(str,tmpUIText:getFontName(),tmpUIText:getFontSize(),
                              cc.size(600,0))
                            labelTextShow:setAnchorPoint(cc.p(0,0))
                            labelTextShow:setPositionX(105)
                            
                            unlockContainer:addChild(labelTextShow)
                        else
                            print("warning: [unlock] type 5 仅支持一个文本信息显示，已忽略出第一个以外的文本,请联系数值策划")
                        end
                    else
                        maxRow = 0
                    end
                else
                    item = cc.CSLoader:createNode("building_upgrade_tiao_0.csb")
                    unlockContainer:addChild(item)
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
                    :setString("")
                    
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0_0")
                    :setString("")
                    
                    --for test value
                    local desc = g_tr("openInfo",{level = 1,name = "undefine_"})
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1")
                    :setString(desc)
                    
                    item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0")
                    :setString("")
                    
                     item:getChildByName("Panel_tiao3_0"):getChildByName("Text_1_0_0")
                    :setString("")
                    
                    item:setPositionY((listSize.height + heightDistance) * (maxRow - row - 1))
                  
                    row = row + 1
                end
                
            elseif showType == 1 then
                if iconUnlockShow == nil then
                    iconUnlockShow = cc.CSLoader:createNode("building_infomation_panel_01.csb")
                    unlockContainer:addChild(iconUnlockShow)
                    unlockContainer:setContentSize(iconUnlockShow:getChildByName("scale_node"):getContentSize())
                    local listView = iconUnlockShow:getChildByName("scale_node"):getChildByName("ListView_1")
                    listView.viewSize = iconUnlockShow:getChildByName("scale_node"):getContentSize()
                    listView:setTouchEnabled(true)
                    
                    local level = 0
                    local buindConfigId = 0
                    if type == 1 then
                        buindConfigId = g_data.soldier[value].need_build_id
                    elseif type == 2 then
                        buindConfigId = g_data.trap[value].need_build_id
                    elseif type == 3 then
                        buindConfigId = g_data.science[value].need_build_id
                    elseif type == 4 then
                        --学习栏位 学院取消了，所以这个忽略
                    end
                    
                    if buindConfigId > 0 then
                        local buildInfo = g_data.build[buindConfigId]
                        assert(buildInfo)
                        level = buildInfo.build_level
                    end
                    
                    iconUnlockShow:getChildByName("scale_node"):getChildByName("Panel_tiao2"):getChildByName("Text_1")
                    :setString(g_tr("openInfoTitle",{level = level}))
                end
                local listView = iconUnlockShow:getChildByName("scale_node"):getChildByName("ListView_1")
                item = cc.CSLoader:createNode("building_upgrade_Unlock.csb")
                item:setContentSize(item:getChildByName("scale_node"):getContentSize())
                iconTotalWidth = iconTotalWidth + item:getContentSize().width
                listView:pushBackCustomItem(item)
                updateIconInfoItem(item,type,value)
            end
            
            lastShowType = showType
        end
        
        con:addChild(unlockContainer)
        table.insert(sonContainers,unlockContainer)
        
        if iconUnlockShow then
            local listView = iconUnlockShow:getChildByName("scale_node"):getChildByName("ListView_1")
            if listView.viewSize.width > iconTotalWidth then
                listView:setTouchEnabled(false)
            end
        else
            if labelTextShow then
                unlockContainer:setContentSize(labelTextShow:getContentSize())
            else
                unlockContainer:setContentSize(cc.size(listSize.width,(listSize.height + heightDistance) * maxRow))
            end
        end
        
        print("height:",unlockContainer:getContentSize().height)
        innerHeight = innerHeight + unlockContainer:getContentSize().height
    end
    
    --府衙总览信息
    if not isUpgradeOrBuild and buildInfo.origin_build_id == 1 then
        --总览title
        do
            local nextLevelTitle = cc.CSLoader:createNode("building_upgrade_item_3.csb")
            con:addChild(nextLevelTitle)
            table.insert(sonContainers,nextLevelTitle)
            
            nextLevelTitle:getChildByName("Panel_tiao1"):getChildByName("Text_2"):setString("")
            local str = g_tr("总览:")
    
            nextLevelTitle:getChildByName("Panel_tiao1"):getChildByName("Text_1"):setString(str)
            nextLevelTitle:setContentSize(nextLevelTitle:getChildByName("Panel_tiao1"):getContentSize())
            
            innerHeight = innerHeight + nextLevelTitle:getContentSize().height - 5    
        end
        
        --总览列表
        local vContainer = createGovernmentHousePanle()
        con:addChild(vContainer)
        table.insert(sonContainers,vContainer)
        innerHeight = innerHeight + vContainer:getContentSize().height
        
       
    end

    --调整各部分的位置
    local conDistanceHeight = 10
    local targetPosY = 0
    for i = #sonContainers, 1,-1 do
        sonContainers[i]:setPositionY(targetPosY)
        targetPosY = targetPosY + sonContainers[i]:getContentSize().height + conDistanceHeight
    end
    
    innerHeight = innerHeight + conDistanceHeight*#sonContainers
    con:setContentSize(cc.size(640,innerHeight))
    
    --print("innerHeight:",innerHeight)
    
    return con,isMeetConditions,isResourceEnough,isQueueMeet
end

function BuildingUIHelper.calculateCostTime(orginalTime,position)
    local costTime = orginalTime
     --buff 效果
    local buffId = 106
    local buffKeyName = g_data.buff[buffId].name
    assert(buffKeyName == "build_speed","buffKeyName: not is build_speed")
    local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,position)
    if buffType == 1 then --万分比
        buffValue = buffValue/10000
        costTime = costTime /(1 + buffValue)
    elseif buffType == 2 then --固定值
        costTime = costTime - buffValue
    end
    
    return costTime
end

  --判断收费队列是否可用
function BuildingUIHelper.checkChargeQueue(buildInfo,serverData)
    local isChargeEnabled = true
    local isHaveBuyQueue = false

    local needTime = buildInfo.construction_time
    needTime = BuildingUIHelper.calculateCostTime(needTime,serverData.position)
    local timeRemain = require("game.uilayer.mainSurface.mainSurfaceQueue").chargeQueueResidualTime() - needTime --收费队列剩余时间
    if timeRemain <= 0 then --如果收费队列没有购买或失效
        isChargeEnabled = false
    else
        isHaveBuyQueue = true
        local build = g_PlayerBuildMode.FindBuild_InCharge() --如果收费队列有建筑正在使用
        local currentTime = g_clock.getCurServerTime()
        if build ~= nil and build.build_finish_time - currentTime > 0 then
            isChargeEnabled = false
        end
    end
    return isChargeEnabled,isHaveBuyQueue
end

function BuildingUIHelper.getBuindInfoByOriginID(m_BuildOriginType)
   local serverData =  g_PlayerBuildMode.FindBuild_OriginID(m_BuildOriginType)
   local buildInfo = g_data.build[tonumber(serverData.build_id)]
   
   local buildOutPutFinalValue = {}
   local buildOutPutPlusValue = {}
    --属性信息
   for key, outputGroup in pairs(buildInfo.output) do
      local type = outputGroup[1]
      local value = outputGroup[2]
      
      local valuePlus = 0
      if value > 0 then
          local valStr = ""
          local numType = g_data.output_type[type].num_type
          if numType == 1 then
              value = value / 10000
          else
          end
          local outPutName = g_tr(g_data.output_type[type].desc)
          local valStrAdd = ""
          --buff 效果
          local buffId = g_data.output_type[type].buff_id
          local plusType = g_data.output_type[type].plus_type
          local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,serverData.position)
          if plusType == 1 then
              buffValue = math.ceil(value * buffValue / 10000)
          elseif plusType == 2 then
              --百分比
              buffValue = buffValue/10000
          elseif plusType == 3 then
              --直接固定值
          end
          valuePlus = buffValue
          
      end
      buildOutPutFinalValue[type] = value + valuePlus
      buildOutPutPlusValue[type] = valuePlus
   end
   
   --dump(buildOutPutFinalValue)
   return buildOutPutFinalValue,buildOutPutPlusValue
end

function BuildingUIHelper.getJiaoChangInfo()
   return BuildingUIHelper.getBuindInfoByOriginID(g_PlayerBuildMode.m_BuildOriginType.spectacular)
end

function BuildingUIHelper.getWarehouseInfo()
   return BuildingUIHelper.getBuindInfoByOriginID(g_PlayerBuildMode.m_BuildOriginType.cache)
end
    

return BuildingUIHelper