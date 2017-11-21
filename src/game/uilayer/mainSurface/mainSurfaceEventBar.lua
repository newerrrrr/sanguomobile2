local mainSurfaceEventBar = {}
setmetatable(mainSurfaceEventBar,{__index = _G})
setfenv(1,mainSurfaceEventBar)

--主界面事件条
local m_Root = nil
local m_Widget = nil
local m_eventType = nil
local m_helpData = nil 
local m_openEnable = false --是否开启事件条功能
local m_isUIRendering = false 
local m_lastTrainingStatus = {}
local m_listItemCallback = nil 
local m_campPara ={
    {g_PlayerBuildMode.m_BuildOriginType.infantry, "camp_infantry", 1, "soldier/finishRecruit", 129},
    {g_PlayerBuildMode.m_BuildOriginType.cavalry, "camp_cavalry", 2, "soldier/finishRecruit", 131},
    {g_PlayerBuildMode.m_BuildOriginType.archers, "camp_archer", 3, "soldier/finishRecruit", 133},
    {g_PlayerBuildMode.m_BuildOriginType.car, "camp_catapults", 4, "soldier/finishRecruit", 135},
    {g_PlayerBuildMode.m_BuildOriginType.workshop, "warFactory", 99999, "trap/finishProduce", 137}
    }

local EventType = {
    Training = 1, --训练士兵 (显示详情)
    Science  = 2, --研究科技 
    Help     = 3, --帮助 (显示详情)
    Treat    = 4, --治疗
    }

local function clearGlobal()
    m_Root = nil
    m_Widget = nil
    m_eventType = nil 
    m_helpData = nil 
    m_listItemCallback = nil 
end 


function create()
    
    clearGlobal()
    
    local rootLayer = cc.Layer:create()
    m_Root = rootLayer
    local schedulers = {}
    local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
            schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_visible, 0 , false)
            schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateEventBarStatus, 6.0, false)
        elseif eventType == "exit" then
            for k , v in ipairs(schedulers) do
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
            end
        elseif eventType == "enterTransitionFinish" then
        elseif eventType == "exitTransitionStart" then
        elseif eventType == "cleanup" then
            if(rootLayer == m_Root)then
                clearGlobal()
                g_gameCommon.removeAllEventHandlers(mainSurfaceEventBar)
            end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
    local widget = g_gameTools.LoadCocosUI("RightButton.csb",6)
    local x, y = widget:getPosition()
    widget:setPosition(cc.p(x, y-50))
    widget:setVisible(true)
    rootLayer:addChild(widget)
    m_Widget = widget

    --详情节点
    local scaleNode = widget:getChildByName("scale_node")
    local contentNode = scaleNode:getChildByName("Panel_2")
    contentNode:setVisible(false)
    contentNode:getChildByName("Button_b1"):setHighlighted(true)

    --点击区域外关闭
    local function onTouchBegan(touch, event)
        if contentNode:isVisible() then 
            local pos = cTools_worldToNodeSpace_position(contentNode, touch:getLocation())
            local size = contentNode:getContentSize()
            if pos.x < 0 or pos.y < 0 or pos.y > size.height then --区域外
                setContentNodeVisible(false, true) 
                return true 
            end 
            return false 
        end 
        return false  
    end
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:setSwallowTouches(true)
    touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener,contentNode)


    --右边事件按钮
    local btnStr = {"eventBarTraining", "eventBarScience", "eventBarHelp", "eventBarTreatment"}
    local btn 
    for i=1, 4 do 
        btn = scaleNode:getChildByName("Button_"..i)
        btn:getChildByName("Text_1"):setString(g_tr(btnStr[i]))
        btn:setTag(i)
        btn:addTouchEventListener(onEventButton)
    end 

    --注册联盟帮助消息推送
    local function updateGuildHlep(obj, tcpData)
        dump(tcpData, "==tcpData")
        if nil == m_helpData then 
            m_helpData = {}
        end 
        table.insert(m_helpData, 1, tcpData)
    end
    g_gameCommon.addEventHandler(g_Consts.CustomEvent.Guild_Help, updateGuildHlep, mainSurfaceEventBar)


    --防止listview多次被调用 addEventListener 注册
    local function onSelectItem(sender, _type)
        if m_listItemCallback then 
            m_listItemCallback(sender, _type)
        end 
    end 
    local listView = m_Widget:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("ListView_1")
    listView:setScrollBarEnabled(false)
    listView:addEventListener(onSelectItem)


    updateEventBarStatus()

    return rootLayer
end

--设置详情是否显示
function setContentNodeVisible(isVisible, bAnim)
    if m_Root and m_Widget then
        local contentNode = m_Widget:getChildByName("scale_node"):getChildByName("Panel_2")

        if not isVisible then 
            if contentNode:isVisible() then 
                if bAnim then 
                    local scaleto = cc.ScaleTo:create(0.2, 0.1, 1.0)
                    local endFunc = function() 
                        contentNode:setVisible(false) 
                    end 
                    contentNode:runAction(cc.Sequence:create(scaleto, cc.CallFunc:create(endFunc)))
                else 
                    contentNode:setVisible(false) 
                end 
            end 
            m_eventType = nil 
        else 
            if not contentNode:isVisible() then 
                contentNode:setVisible(true)
                if bAnim then                 
                    contentNode:setScaleX(0.1)
                    contentNode:setScaleY(1.0)
                    contentNode:runAction(cc.ScaleTo:create(0.3, 1.0, 1.0))
                end 
            end 
        end 
    end 
end 

function update_visible(dt)
    if m_Root == nil then
        return
    end
    if g_resourcesInterface.getResInterfaceShowCount() > 0 then
        m_Root:setVisible(false)
    else
        m_Root:setVisible(true)
    end
end

function onEventButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then        
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        showEventContent(sender:getTag())
    end
end

function showEventContent(eventType)
    if m_Root and m_Widget then
        print("showEventContent", eventType, m_eventType)

        --防止重复点击
        local scaleNode = m_Widget:getChildByName("scale_node") 
        local node = scaleNode:getChildByName("Panel_2")  
        if m_eventType == eventType then 
            return 
        end 

        setContentNodeVisible(false, false)

        local ret = false 
        if eventType == EventType.Training then --训练士兵 (显示详情)
            ret = showTrainingInfo()

        elseif eventType == EventType.Science then --研究科技
            ret = onTouchScience() 

        elseif eventType == EventType.Help then --帮助
            ret = showHelpInfo()

        elseif eventType == EventType.Treat then --治疗
            ret = onTouchTreat()
        end 

        if not ret then return end 

        m_eventType = eventType 

        --更新左边标题
        local tabStr = {"eventBarTraining", "eventBarScience", "eventBarInfo", "eventBarTreatment"}
        node:getChildByName("Button_b1"):getChildByName("Text_5"):setString(g_tr(tabStr[m_eventType]))
        node:getChildByName("Button_b1"):setHighlighted(true)

        --滑动动画
        setContentNodeVisible(true, true)
    end    
end 

--士兵训练
function getTrainingNameCount(info)
    local count = 0             
    local name = ""

    if info and info.work_content then
        local sid = info.work_content.soldierId
        local tid = info.work_content.trapId
        local snum = info.work_content.num or 0
        
        if sid then
            local item = g_data.soldier[tonumber(sid)] 
            name = g_tr("levelNum", {lv = item.soldier_level}) .. g_tr(item.soldier_name)
        end
        if tid then
            name = g_tr( g_data.trap[tonumber(tid)].trap_name )
        end
        count = tonumber(snum) 
    end 

    return count, name
end 

--status: -1:not build 0:idle  1:working 2: canReqHelp 3:finish 
function getTrainingStatusByIndex(index)
    local status = -1 
    local count = 0 
    local name = ""

    local serverData = g_PlayerBuildMode.FindBuild_OriginID(m_campPara[index][1]) 
    if serverData then 
        local trainingInfo = require("game.uilayer.militaryCamp.MilitaryCampData"):getCampBuildInfoByType(m_campPara[index][3])
        count, name = getTrainingNameCount(trainingInfo)
        if count > 0 then 
            if g_clock.getCurServerTime() >= serverData.work_finish_time then --训练结束 
                status = 3 
            else --训练中 
                status = 1 
            end 
        else 
            status = 0 
        end 
    else 
        status = -1 
    end 

    return status, count, name 
end 

function getTrainingStatus()
    --计算训练状态
    local trainingSatusFinish = false 
    local trainingSatusWorking = false 
    local trainingCanReqHelp = false 
    local isSubStatusChanged = false 
    for i = 1, #m_campPara do 
        --status: -1:not build 0:idle  1:working 2: canReqHelp 3:finish
        local status = getTrainingStatusByIndex(i) 
        if status == 3 then 
            trainingSatusFinish = true 
        elseif status == 2 then 
            trainingCanReqHelp = true 
        elseif status == 1 then 
            trainingSatusWorking = true 
        end

        if m_lastTrainingStatus[i] ~= status then 
            isSubStatusChanged = true 
            m_lastTrainingStatus[i] = status 
        end 
    end 

    --status convert 
    local status_training = 0 
    if trainingSatusFinish then 
        status_training = 3 
    elseif trainingSatusWorking then 
        status_training = 1 
    elseif trainingCanReqHelp then 
        status_training = 2 
    end

    return status_training, isSubStatusChanged 
end 


--显示士兵训练状态列表
function showTrainingInfo()
    if m_Root and m_Widget then

        if m_isUIRendering then 
            print("m_isUIRendering == true")
            return 
        end 
        m_isUIRendering = true 

        local node = m_Widget:getChildByName("scale_node"):getChildByName("Panel_2") 
        local listView = node:getChildByName("ListView_1")
        listView:removeAllChildren()


        --需要显示详情
        local function initItem(item, idx)
            if nil == item then return end 

            local text1 = item:getChildByName("Text_1")
            local text2 = item:getChildByName("Text_2")            
            text1:setString(g_tr(m_campPara[idx][2]))
            text1:setTextColor(cc.c3b(255, 255, 255))
            
            local status, count, name = getTrainingStatusByIndex(idx) 
            m_lastTrainingStatus[idx] = status 
            if status == -1 then --未建造
                item:getChildByName("Image_1"):setVisible(false)
                item:getChildByName("Image_2"):setVisible(false)
                item:getChildByName("Image_3"):setVisible(true)
                item:getChildByName("Image_4"):setVisible(false)
                text2:setString(g_tr("eventBarBuildNotExist"))
                text2:setTextColor(cc.c3b(255, 40, 50))  

            elseif status == 0 then --空闲 
                item:getChildByName("Image_1"):setVisible(false)
                item:getChildByName("Image_2"):setVisible(true)
                item:getChildByName("Image_3"):setVisible(false) 
                item:getChildByName("Image_4"):setVisible(false)
                text2:setString(g_tr("eventBarStateIdle"))
                text2:setTextColor(cc.c3b(22, 155, 209))  

            elseif status == 1 then --训练中
                item:getChildByName("Image_1"):setVisible(false)
                item:getChildByName("Image_2"):setVisible(false)
                item:getChildByName("Image_3"):setVisible(false)
                item:getChildByName("Image_4"):setVisible(true)
                text2:setString(name .. "  ".. count) 
                text2:setTextColor(cc.c3b(255, 176, 64))  

            elseif status == 2 then 
            elseif status == 3 then ----训练结束
                item:getChildByName("Image_1"):setVisible(true)
                item:getChildByName("Image_2"):setVisible(false)
                item:getChildByName("Image_3"):setVisible(false)
                item:getChildByName("Image_4"):setVisible(false)
                text2:setString(g_tr("eventBarFetch", {num = count}))
                text2:setTextColor(cc.c3b(72, 255, 98)) 
            end 

            if text1:getPositionX() + text1:getContentSize().width > text2:getPositionX()  then 
                text2:setPositionX(text1:getPositionX() + text1:getContentSize().width + 10)
            end                
        end 

        m_listItemCallback = function(sender, _type)
            if _type == ccui.ListViewEventType.ONSELECTEDITEM_END then                 
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

                local idx = sender:getCurSelectedIndex()
                local serverData = g_PlayerBuildMode.FindBuild_OriginID(m_campPara[idx+1][1]) 
                local status, count, name = getTrainingStatusByIndex(idx+1) 
                if status == -1 then --未建造

                elseif status == 0 then --空闲 
                    if serverData and serverData.status ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then --兵营升级过程中不允许进入
                        require("game.maplayer.changeMapScene").gotoHome_Place(serverData.position)
                        local SoldierTraningLayer = require("game.uilayer.militaryCamp.SoldierTraningLayer")
                        SoldierTraningLayer:createLayer(serverData.build_id)
                        setContentNodeVisible(false, false)
                    end 

                elseif status == 1 then --训练中,可加速                
                    local function gotoSuccessHandler()                   
                        if serverData.status == g_PlayerBuildMode.m_BuildStatus.working then 
                            require("game.maplayer.smallBuildMenu").setTipMenuID(m_campPara[idx+1][5])                        
                        end
                        setContentNodeVisible(false, false)
                    end
                    require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(serverData.position, gotoSuccessHandler)                 

                elseif status == 2 then --可请求帮助
                elseif status == 3 then ----训练结束
                    local onResult = function(result,msgData)
                        if result then 
                            g_airBox.show(g_tr("eventBarTrainedCount", {num = count, name = name}))
                            --更新item项                                    
                            initItem(listView:getItem(idx), idx+1) 
                            updateEventBtnAnim(EventType.Training)    
                        end
                    end
                    g_sgHttp.postData(m_campPara[idx+1][4], {position = serverData.position}, onResult, false) 
                end 
            end 
        end 

        -- listView:setScrollBarEnabled(false)
        -- listView:addEventListener(onSelectItem) --这里会导致重复注册

        local item = cc.CSLoader:createNode("RightButton_list.csb") 
        item:setTouchEnabled(true)
        local itemNew 
        for i = 1, #m_campPara do 
            itemNew = item:clone()
            initItem(itemNew, i)
            listView:pushBackCustomItem(itemNew) 
        end 

        m_isUIRendering = false 
    end 

    return true 
end 


--status: 0:idle  1:working 2: canReqHelp 3:finish 
function getScienceStatus()
    local status = 0 
    local serverData =  g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.institute) 
    if serverData then 
        local name = require("game.uilayer.science.Science"):instance():getLearningScience() 
        if name == "" then --空闲时
            status = 0 
        elseif g_PlayerBuildMode.CheckInstituteNeedHelp() then --可请求帮助 
            status = 2 
        else 
            status = 1 
        end 
    end 

    return status 
end 

--status: 0:idle  1:working 2: canReqHelp 3:finish 
function getTreatStatus()
    local status = 0 

    local function getTreatCount(serverData)
        local count = 0             
        if serverData then 
            if serverData.work_content and serverData.work_content.soldier then
                for k , v in pairs(serverData.work_content.soldier) do
                    count = count + v.num 
                end
            end
        end 
        return count 
    end 

    local serverData = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.hospital) 
    local count = getTreatCount(serverData)
    if count > 0 then 
        if g_clock.getCurServerTime() >= serverData.work_finish_time then --治疗结束
            status = 3 

        else --治疗中
            if g_PlayerBuildMode.CheckHospitalNeedHelp() then --可请求帮助 
                status = 2 
            else 
                status = 1 
            end 
        end 
    end 

    return status, count 
end 

function updateHelpReqNum()
    if m_Root and m_Widget then

        --帮助红点
        local num = g_PlayerHelpMode.GetHelpNum() 
        local helpTip = m_Widget:getChildByName("scale_node"):getChildByName("Panel_hongdian")
        helpTip:setVisible(num > 0)
        helpTip:getChildByName("Text_1"):setString(""..num)

        local btnHelp = m_Widget:getChildByName("scale_node"):getChildByName("Button_3") 
        -- btnHelp:setBright(num > 0)  
        setBrightDelay(btnHelp, num > 0, 0.2)
    end 
end 

--帮助
function showHelpInfo()
    if m_Root and m_Widget then
        local scaleNode = m_Widget:getChildByName("scale_node")

        --1.如果有可帮助项,则先发送帮助
        local num = g_PlayerHelpMode.GetHelpNum() 
        if num > 0 then 
            g_airBox.show(g_tr("eventBarHelpAll"))

            local helpTip = scaleNode:getChildByName("Panel_hongdian")
            g_PlayerHelpMode.HelpAll_Async()            
            helpTip:setVisible(false)             
            -- g_PlayerHelpMode.RequestSycData()
            return false 
        end 

        --2.显示帮助详情(最新30条)
        local node = scaleNode:getChildByName("Panel_2")
        local listView = node:getChildByName("ListView_1")
        local widthMax = listView:getContentSize().width 
        listView:removeAllChildren()

        if m_helpData then 
            -- dump(m_helpData, "====m_helpData")
            for k, v in pairs(m_helpData) do 
                if k >= 30 then 
                    break 
                end 

                local str = ""                
                if v.help_type == 1 then --建造建筑帮助
                    local buildName = g_tr(g_data.build[v.help_resource_id].build_name)
                    str = g_tr("eventBarBuildHelp", {player = v.from_player_nick, name = buildName, num = v.second})
                elseif v.help_type == 2 then --研究科技帮助
                    local sciName = g_tr(g_data.science[v.help_resource_id].name)
                    str = g_tr("eventBarLearningHelp", {player = v.from_player_nick, name = sciName, num = v.second})
                elseif v.help_type == 3 then --治疗帮助
                    str = g_tr("eventBarTreatHelp", {player = v.from_player_nick, num = v.second})
                end 

                if str ~= "" then 
                    local node = ccui.Widget:create() 
                    local richText = g_gameTools.createNoModeRichText(str, {fontSize = 24, width = widthMax , height = 0})
                    richText:setAnchorPoint(cc.p(0.5, 0.5)) 
                    local size = richText:getRichSize()
                    local newSize = cc.size(size.width, size.height+16)
                    richText:setPosition(cc.p(newSize.width/2, newSize.height))                    
                    node:setContentSize(newSize)
                    node:addChild(richText)
                    listView:pushBackCustomItem(node) 
                end                 
            end 
        end 
        
        --我帮助过别人的次数(有可能帮助某个人多次)
        local data = g_PlayerHelpMode.GetData() 
        if data then 
            local myHelpNum = 0 
            local helpArray = {}
            local myPlayerId = g_PlayerMode.GetData().id 
            for k, v in pairs(data) do 
                if v.player_id ~= myPlayerId then 
                    for i, id in pairs(v.helper_ids) do 
                        if id == myPlayerId then 
                            myHelpNum = myHelpNum + 1 
                            helpArray[v.player_id] = true 
                            break 
                        end 
                    end 
                end 
            end 

            if myHelpNum > 0 then 
                local players = 0 
                for k, v in pairs(helpArray) do 
                    if v then 
                        players = players + 1 
                    end 
                end 

                local node = ccui.Widget:create() 
                local richText = g_gameTools.createNoModeRichText(g_tr("eventBarYouHelpInfo", {playerCount = players, num = myHelpNum}), {fontSize = 24, width = widthMax , height = 0})
                richText:setAnchorPoint(cc.p(0.5, 0.5)) 
                local size = richText:getRichSize()
                local newSize = cc.size(size.width, size.height+16)
                richText:setPosition(cc.p(newSize.width/2, newSize.height))                    
                node:setContentSize(newSize)
                node:addChild(richText)
                listView:pushBackCustomItem(node) 
            end             
        end 
    end 

    return true 
end 

--科技研究(不显示详情界面)
function onTouchScience()
    if m_Root and m_Widget then        

        local node = m_Widget:getChildByName("scale_node"):getChildByName("Panel_2")   
        node:setVisible(false) 

        local serverData =  g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.institute) 
        if nil == serverData then 
            g_airBox.show(g_tr("eventBarNoScienceBuild"))
            return false 
        end 
        local status = getScienceStatus() 
        print("onTouchScience, status ", status)
        local name = require("game.uilayer.science.Science"):instance():getLearningScience() 
        if status == 0 then --空闲时直接打开研究所界面 
            if serverData then 
                require("game.maplayer.changeMapScene").gotoHome_Place(serverData.position)
                if serverData.status ~= g_PlayerBuildMode.m_BuildStatus.levelUpIng then 
                    g_sceneManager.addNodeForUI(require("game.uilayer.science.ScienceLayer").new())
                end 
            end 

        elseif status == 2 then --可请求帮助 
            g_PlayerHelpMode.SendHelpAction(serverData.position, function() updateEventBtnAnim(EventType.Help) end ) 

        elseif status == 1 then--可加速 
            local function gotoSuccessHandler() 
                if serverData.status == g_PlayerBuildMode.m_BuildStatus.working then 
                    require("game.maplayer.smallBuildMenu").setTipMenuID(139)
                end
            end
            require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(serverData.position, gotoSuccessHandler) 
        end 
    end 

    return false 
end 

--(不显示详情界面)
function onTouchTreat()
    if m_Root and m_Widget then 
        local serverData = g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.hospital) 
        local status, count = getTreatStatus() 
        print("onTouchTreat: status", status)
        if status == 3 then --治疗结束
            local onResult = function(result,msgData)
                if result then
                    g_airBox.show(g_tr("eventBarTreatedCount", {num = count}))  
                    updateEventBtnAnim(EventType.Treat) 
                end
            end
            g_sgHttp.postData("soldier/doCureInjuredSoldier", {}, onResult, false) 
                       
        elseif status == 2 then --可请求帮助
            g_PlayerHelpMode.SendHelpAction(serverData.position, function() updateEventBtnAnim(EventType.Treat) end ) 

        elseif status == 1 then --可加速 
            local function gotoSuccessHandler()                   
                if serverData.status == g_PlayerBuildMode.m_BuildStatus.working then 
                    require("game.maplayer.smallBuildMenu").setTipMenuID(102)
                end
            end
            require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(serverData.position, gotoSuccessHandler)              

        else --空闲
            --打开医馆界面
            local serverData =  g_PlayerBuildMode.FindBuild_OriginID(g_PlayerBuildMode.m_BuildOriginType.hospital)
            if serverData then
                require("game.maplayer.changeMapScene").gotoHome_Place(serverData.position)
                g_sceneManager.addNodeForUI(require("game.uilayer.hospital.HospitalLayer"):create(serverData.build_id,serverData))
            end 
        end 
    end 
end 

local function updateAnimByStatus(target, status, callback)
    if m_Root and m_Widget then 

        local armature = target:getChildByTag(100)
        if nil == armature then 
            local size = target:getContentSize()
            local ar, anim = g_gameTools.LoadCocosAni(
                "anime/Effect_ShiJianTiaoHeJi/Effect_ShiJianTiaoHeJi.ExportJson"
                , "Effect_ShiJianTiaoHeJi"
                -- , onMovementEventCallFunc
                --, onFrameEventCallFunc
                )
            ar:setPosition(cc.p(size.width/2, size.height/2))
            ar:setTag(100)
            target:addChild(ar)
          -- anim:play("Animation1") 

          armature = ar
        end 

        local movementId = armature:getAnimation():getCurrentMovementID()
        -- print("getMovement", movementId)
        if status == 3 then --已结束
            armature:setVisible(true)
            if movementId ~= "Effect_ShiJianTiaoOver" then 
                armature:getAnimation():play("Effect_ShiJianTiaoOver") 
                if callback then 
                    callback()
                end 
            end 

        elseif status == 2 then --可请求帮助
            armature:setVisible(true)
            if movementId ~= "Effect_ShiJianTiaoHelp" then 
                armature:getAnimation():play("Effect_ShiJianTiaoHelp") 
                if callback then 
                    callback()
                end 
            end             
            
        elseif status == 1 then --工作中
            armature:setVisible(true)
            if movementId ~= "Effect_ShiJianTiaoLoading" then 
                armature:getAnimation():play("Effect_ShiJianTiaoLoading") 
                if callback then 
                    callback()
                end                 
            end 

        else 
            armature:removeFromParent()
        end  
    end 
end 

--更新训练、研究、治疗的按钮状态
function updateEventBtnAnim(eventType)
    if m_Root and m_Widget then 
        local scaleNode = m_Widget:getChildByName("scale_node") 
        if nil == eventType or eventType == EventType.Training then --士兵训练状态
            local status_training, subStatusChanged = getTrainingStatus() 
            updateAnimByStatus(scaleNode:getChildByName("Button_1"), status_training) 
            if subStatusChanged then 
                print("subStatusChanged")
                local node = m_Widget:getChildByName("scale_node"):getChildByName("Panel_2") 
                if node:isVisible() then 
                    showTrainingInfo()
                end 
            end 
        end 

        if nil == eventType or eventType == EventType.Science then --研究科技状态
            local status_science = getScienceStatus() 
            updateAnimByStatus(scaleNode:getChildByName("Button_2"), status_science)
        end 

        if nil == eventType or eventType == EventType.Treat then --治疗状态 
            local status_treat = getTreatStatus() --治疗状态
            local woundedCount = table.total(g_PlayerSoldierInjuredMode.getData())  --伤兵个数
            updateAnimByStatus(scaleNode:getChildByName("Button_4"), status_treat)
            local btnTreat = scaleNode:getChildByName("Button_4")
            local isBright = (status_treat ~= 0 or woundedCount > 0)
            setBrightDelay(btnTreat, isBright, 0.2)             
        end 
    end 
end 

--轮询更新事件条按钮状态
function updateEventBarStatus(needReq) 
    if m_Root and m_Widget then 
        updateEventBarVisible(false)

        if m_Widget:isVisible() then 
            updateHelpReqNum()
            updateEventBtnAnim()

            -- if nil == needReq or needReq then 
            --     g_PlayerHelpMode.RequestSycData()
            -- end 
        end 
    end 
end 

--更新事件条的显示或隐藏, bAnim 是否以动画方式从渐入屏幕显示
function updateEventBarVisible(bAnim)
    local function playRoundLightAnim()
        local armature, animation
        local count = 0 
        local function onMovementEventCallFunc(armature , eventType , name)
            if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
                count = count + 1 
                if count >= 3 then 
                    armature:removeFromParent()
                end 
            end 
        end 

        local target = m_Widget:getChildByName("scale_node"):getChildByName("Image_1_0")
        target:removeAllChildren()
        local size = target:getContentSize()
        armature, animation = g_gameTools.LoadCocosAni(
        "anime/Effect_ShiJianTiaoBianKuangXunHuan/Effect_ShiJianTiaoBianKuangXunHuan.ExportJson"
        , "Effect_ShiJianTiaoBianKuangXunHuan"
        , onMovementEventCallFunc
        --, onFrameEventCallFunc
        )
        armature:setPosition(cc.p(size.width/2, size.height/2))
        target:addChild(armature)
        animation:play("Animation1") 
    end 

    if m_Root and m_Widget then 
        local enoughCount = g_PlayerBuildMode.FindBuildCount_lv_more_ConfigID(tonumber(g_data.starting[78].data))
        m_openEnable = enoughCount > 0

        if m_openEnable then 
            local changeMapScene = require("game.maplayer.changeMapScene")
            local mapStatus = changeMapScene.getCurrentMapStatus()
            if mapStatus == changeMapScene.m_MapEnum.home then--城内
                m_Widget:setVisible(true) 
                if bAnim then 
                    local x = m_Widget:getPositionX()
                    m_Widget:setPositionX(x+100)

                    m_Widget:getChildByName("scale_node"):getChildByName("Image_1_0"):removeAllChildren()
                    local delay = cc.DelayTime:create(0.5)
                    local act = cc.Sequence:create(cc.MoveBy:create(1.0, cc.p(-100, 0)), delay, cc.CallFunc:create(playRoundLightAnim))
                    m_Widget:runAction(act)
                end 
            else 
                m_Widget:setVisible(false)
            end             
        else 
            m_Widget:setVisible(false)
        end 
    end     
end 

function setEventBarVisible(bVisible)
    if m_Root and m_Widget then 
        m_Widget:setVisible(bVisible) 
    end 
end 

--城内外切换UI变更
function viewChangeShow()
    if m_Root and m_Widget then 
        local changeMapScene = require("game.maplayer.changeMapScene")
        local mapStatus = changeMapScene.getCurrentMapStatus()
        if mapStatus == changeMapScene.m_MapEnum.home then--城内
            m_Widget:setVisible(m_openEnable) 
        elseif mapStatus == changeMapScene.m_MapEnum.world then--城外
            m_Widget:setVisible(false) 
        elseif mapStatus == changeMapScene.m_MapEnum.guildwar then--联盟战
            m_Widget:setVisible(false) 
        elseif mapStatus == changeMapScene.m_MapEnum.citybattle then--城战
            m_Widget:setVisible(false) 
        end 

        setContentNodeVisible(false, false)
    end 
end 

--widget在堵塞情况下 setBright 可能导致该widget消失
function setBrightDelay(obj, isBright, delay)
    local function callback()
        -- print("setBrightDelay")
        obj:setBright(isBright)
    end 
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    obj:stopAllActions()
    obj:runAction(sequence)
end 

return mainSurfaceEventBar