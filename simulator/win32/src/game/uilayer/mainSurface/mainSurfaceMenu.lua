local mainSurfaceMenu = {}
setmetatable(mainSurfaceMenu,{__index = _G})
setfenv(1,mainSurfaceMenu)

--主界面菜单

local m_Root = nil
local m_Widget = nil
local m_tower = 0
local pop = nil
local gTime = 30
local curTime = 0
local timeAction = nil

local function clearGlobal()
	m_Root = nil
    m_Widget = nil
    pop = nil
    timeAction = nil
end

function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_visible, 0 , false)
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_tower, 60.0 , false)
			update_tower(0.0167)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
    local widget = g_gameTools.LoadCocosUI("zhuchengjiemian_02.csb",9)
    m_Widget = widget
    rootLayer:addChild(widget)

    widget:getChildByName("scale_node"):setTouchEnabled(false)

    local toOutBtn = widget:getChildByName("scale_node"):getChildByName("Button_dituanniu")
    toOutBtn:getChildByName("Text_16"):setString(g_tr("menu_outcity"))
    toOutBtn:addTouchEventListener(onBottonMap)

    local tiInBtn = widget:getChildByName("scale_node"):getChildByName("Button_dituanniu1")
    tiInBtn:getChildByName("Text_16"):setString(g_tr("menu_incity"))
    tiInBtn:addTouchEventListener(onBottonMap)

    g_guideManager.registComponent(1000301,widget:getChildByName("scale_node"):getChildByName("Button_dituanniu"))

    local unionBtn = widget:getChildByName("scale_node"):getChildByName("Button_1")
    unionBtn:addTouchEventListener(onBottonUnion)
    unionBtn:getChildByName("Text_17"):setString(g_tr("mainUnionBtn"))

    local itemBtn = widget:getChildByName("scale_node"):getChildByName("Button_2")
    itemBtn:addTouchEventListener(onBottonItem)
    itemBtn:getChildByName("Text_17"):setString(g_tr("mainBagBtn"))


    local mailBtn = widget:getChildByName("scale_node"):getChildByName("Button_3")
    mailBtn:addTouchEventListener(onBottonMail)
    mailBtn:getChildByName("Text_17"):setString(g_tr("mainMailBtn"))


    local missionBtn = widget:getChildByName("scale_node"):getChildByName("Button_4")
    missionBtn:addTouchEventListener(onBottonMission)
    missionBtn:getChildByName("Text_17"):setString(g_tr("mainTaskBtn"))
    --widget:getChildByName("scale_node"):getChildByName("Image_2"):addTouchEventListener(onBottonCollect)

    local gatherBtn = widget:getChildByName("scale_node"):getChildByName("Button_jj")
    gatherBtn:addTouchEventListener(onBottonGather)
    gatherBtn:getChildByName("Text_17"):setString(g_tr("collectionBattle"))
    gatherBtn:setVisible(false)

    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_JiJieAnNiu/Effect_JiJieAnNiu.ExportJson", "Effect_JiJieAnNiu")
    armature:setPosition(cc.p( gatherBtn:getContentSize().width/2,gatherBtn:getContentSize().height/2 ))
    gatherBtn:addChild(armature)
    animation:play("Animation1")
    --showGatherIcon()

    local img = m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames")
    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_FengHuoTai/Effect_FengHuoTai.ExportJson", "Effect_FengHuoTai")
    img:addChild(armature)
    armature:setPosition(cc.p(img:getContentSize().width / 2, img:getContentSize().height * 0.5))
    animation:play("Animation1")
    img:setVisible(false)
    img:addTouchEventListener(onBottonTower)
    
    m_Widget:getChildByName("scale_node"):getChildByName("Image_3"):getChildByName("Text_3"):setString(g_tr("allianceJoinHomeTip"))

    --初始化当前场景显示和隐藏的UI
    viewChangeShow()

    menuTipsUpdate()

    addEvent()

	return rootLayer
end

function addEvent()
    local function showBag()
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_3"):setVisible(true)
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_3"):getChildByName("Text_1"):setVisible(false)
    end

    local function showTower()
        local img = m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames")
        img:setVisible(true)
        require("game.effectlayer.screenFire").show()
        require("game.mapguildwar.worldMapLayer_uiLayer").fenghuotai_show()
        m_tower = m_tower + 1
    end

    local function closeTower()
        m_tower = m_tower - 1
        if m_tower <= 0 then
            local img = m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames")
            img:setVisible(false)
            require("game.effectlayer.screenFire").hide()
            require("game.mapguildwar.worldMapLayer_uiLayer").fenghuotai_hide()
        end
    end

    g_gameCommon.addEventHandler(g_Consts.CustomEvent.Item, showBag, self)
    g_gameCommon.addEventHandler(g_Consts.CustomEvent.Attacked, showTower, self)
    g_gameCommon.addEventHandler(g_Consts.CustomEvent.CloseTower, closeTower, self)
    --
end


function update_visible(dt)
	if m_Root == nil then
		return
	end
	if g_resourcesInterface.getResInterfaceShowCount() > 0 then
		m_Widget:setVisible(false)
	else
		m_Widget:setVisible(true)
	end
end



function update_tower(dt)
	local function onRecv(result, msgData)
		if result == true then
			if m_Root then
                local img = m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames")
				if msgData == nil or #msgData == 0 then
                    img:setVisible(false)
                    require("game.effectlayer.screenFire").hide()
                else
                    img:setVisible(true)
                    require("game.effectlayer.screenFire").show()
                end
                m_tower = #msgData
			end
		end
	end
    g_netCommand.send("Player/viewAttackArmy", {}, onRecv, true)
end

function onBottonGather(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local btn = m_Widget:getChildByName("scale_node"):getChildByName("Button_jj")
        btn:setVisible(false)
        local view = require("game.uilayer.common.GatherView").new()
        g_sceneManager.addNodeForUI(view)
    end
end

function onBottonTower(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local view = require("game.uilayer.tower.TowerView").new()
        g_sceneManager.addNodeForUI(view)
    end
end

function onBottonMap(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--print("onBottonMap")
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		require("game.maplayer.changeMapScene").changeToChange()
	end
end


function onBottonUnion(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		print("onBottonUnion")
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
	    g_sceneManager.addNodeForUI(require("game.uilayer.alliance.AllianceMainLayer"):create())

	end
end


function onBottonItem(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_3"):setVisible(false)
		local bag = require("game.uilayer.bag.BagView").new()
        g_sceneManager.addNodeForUI(bag)
        bag:show()
	end
end

function onBottonMail(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		print("onBottonMail")
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		g_sceneManager.addNodeForUI(require("game.uilayer.mail.MailBaseLayer").new())   
	end
end

function hideJoinGuildTip()
    if m_Root == nil then
        return
    end
    m_Widget:getChildByName("scale_node"):getChildByName("Image_3"):stopAllActions()
    m_Widget:getChildByName("scale_node"):getChildByName("Image_3"):setVisible(false)
end

--如果当前没有加入联盟，每次进入主城后提示加入
function showJoinGuildTip()
    if m_Root == nil then
        return
    end
    local needShow = not g_AllianceMode.getSelfHaveAlliance() and not g_guideManager.getLastShowStep() and not require("game.uilayer.mainSurface.mainSurfaceAllianceInvite").isViewShowing()
    local tipNode = m_Widget:getChildByName("scale_node"):getChildByName("Image_3")
    tipNode:setVisible(needShow)
    if needShow then
          local seq = cc.Sequence:create(cc.DelayTime:create(20),cc.CallFunc:create(function()
             tipNode:setVisible(false)
          end))
          tipNode:runAction(seq)
    end
    
end

function doGuildTipUpdate(haveTip)
    if m_Widget then
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_1"):setVisible(haveTip)
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_1"):getChildByName("Text_1"):setString("")
    end
end

function onGuildTipUpdate(finishCallback)
    local updateTipShow = function()
        local haveTip = false
        if not g_battleHallData.showTip() then
            if g_AllianceMode.getRequestNum() > 0 then
               haveTip = true
            end
        else
            haveTip = true
        end
        
        doGuildTipUpdate(haveTip)
        
        if finishCallback then
            finishCallback()
        end
        
    end
    g_battleHallData.RequestSycData(updateTipShow)
end

function onTaskUpdate()
    if m_Widget then
        local completeCount = 0
        
        local mainTaskData = g_TaskMode.getGuideMainTask()
        if mainTaskData and mainTaskData:getServerData().status == g_TaskMode.TaskStatusType.COMPLETE then
            completeCount = completeCount + 1
        end
        
        local dailyTasksData = g_TaskMode.getAllDailyTasks()
        for key, taskData in pairs(dailyTasksData) do
        	if taskData:getServerData().status == g_TaskMode.TaskStatusType.COMPLETE then
        	   completeCount = completeCount + 1
        	end
        end
        
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_4"):setVisible(completeCount > 0)
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_4"):getChildByName("Text_1"):setString(completeCount.."")
    end
end

--菜单栏tips更新
function menuTipsUpdate()
  --邮件
  g_MailMode.updateNewMailTips()

end 


function updateMailTips(mailCounts) 
    if m_Root and m_Widget then 
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_2"):setVisible(mailCounts > 0)
        m_Widget:getChildByName("scale_node"):getChildByName("Panel_2"):getChildByName("Text_1"):setString(mailCounts.."")
    end 
end 


function onBottonMission(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		print("onBottonMission")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    g_sceneManager.addNodeForUI(require("game.uilayer.task.TaskMainLayer").create())
--    if require("game.mapcitybattle.worldMapLayer_bigMap").isMapTest == true then
--    	require("game.mapcitybattle.changeMapScene").changeToWorld()
--    else
--    	g_sceneManager.addNodeForUI(require("game.uilayer.task.TaskMainLayer").create())
--    end
	end
end

function getBagBtnPos()
    if m_Root == nil or m_Widget == nil then 
        return
    end

    local bagBtn = m_Widget:getChildByName("scale_node"):getChildByName("Button_2")
    local size = bagBtn:getContentSize()
    local pos = bagBtn:convertToWorldSpace(cc.p(size.width/2,size.height/2))
    return pos

end

--[[
function onBottonCollect(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        require("game.uilayer.map.collectLayer"):createLayer()
    end
end
]]

--城内外切换UI变更
function viewChangeShow()
    if m_Root then
        m_Root:setVisible(true)
        local changeMapScene = require("game.maplayer.changeMapScene")
        local mapStatus = changeMapScene.getCurrentMapStatus()
        if mapStatus == changeMapScene.m_MapEnum.home then
            --隐藏收藏夹图标
            m_Widget:getChildByName("scale_node"):getChildByName("Button_dituanniu"):setVisible(true)
            m_Widget:getChildByName("scale_node"):getChildByName("Button_dituanniu1"):setVisible(false)
            --m_Widget:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(false)
            
        elseif mapStatus == changeMapScene.m_MapEnum.world then
            --显示收藏夹图标
            m_Widget:getChildByName("scale_node"):getChildByName("Button_dituanniu1"):setVisible(true)
            m_Widget:getChildByName("scale_node"):getChildByName("Button_dituanniu"):setVisible(false)
            --m_Widget:getChildByName("scale_node"):getChildByName("Image_2"):setVisible(true)
        elseif mapStatus == changeMapScene.m_MapEnum.guildwar then
        		m_Root:setVisible(false)
        elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
            m_Root:setVisible(false)
        end

       -- m_Widget:getChildByName("scale_node"):getChildByName("Image_TheFlames"):setVisible(false)
    end
end

--显示集结icon
function showGatherIcon(data)
    if m_Widget == nil or m_Root == nil then
        return
    end

    local btn = m_Widget:getChildByName("scale_node"):getChildByName("Button_jj")
    btn:setVisible(true)

    local info = ""
    if data.Data == nil then
        info = g_tr("haveGather")
    else
        if data.Data.info.type == "attackPlayer" then
            info = g_tr("gatherAttackPlayer", {player=data.Data.info.nick, target=data.Data.info.target_player_nick})
        elseif data.Data.info.type == "attackBase" then
            info = g_tr("gatherAttackPlayer", {player=data.Data.info.nick, target="["..data.Data.info.target_guild_short_name.."]"..g_tr("SmallMapAllianceTower")})
        elseif data.Data.info.type == "attackTown" or data.Data.info.type == "attackBoss" then
            local mapData = g_data.map_element[tonumber(data.Data.info.map_element_id)]
            info = g_tr("gatherAttackPlayer", {player=data.Data.info.nick, target=g_tr(mapData.name)})
        end
    end

    local textLabel = cc.Label:createWithTTF(info, "cocostudio_res/simhei.ttf", 20, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    local text_size = textLabel:getContentSize()
    if text_size.width > 260 then
        textLabel:setDimensions(260, 0)
        textLabel:setString(info)
        text_size = textLabel:getContentSize()
    end

    if pop == nil then
        pop = ccui.Scale9Sprite:create("freeImage/city_tips.png")
        btn:addChild(pop)
    else
        pop:removeAllChildren()
    end

    pop:setVisible(true)

    local texture_size = pop:getContentSize()
    local sp_size = cc.size(text_size.width > texture_size.width - 30 and text_size.width + 30 or texture_size.width, text_size.height > texture_size.height - 30 and text_size.height + 30 or texture_size.height)
    pop:setContentSize(sp_size)

    local pro = {}
    pro.fontSize = 20
    pro.width = text_size.width
    pro.height = text_size.height
    local richText = g_gameTools.createNoModeRichText(info, pro)
    richText:setAnchorPoint(cc.p(0.5, 0.5))
    richText:setPosition(cc.p(pop:getContentSize().width/2, pop:getContentSize().height/2))

    
    textLabel:setPosition(cc.p(sp_size.width * 0.5, sp_size.height * 0.5 + 6))
    pop:setAnchorPoint(cc.p(0.5, 0.0))
    pop:addChild(richText)
    pop:setPosition(cc.p(btn:getContentSize().width/2, btn:getContentSize().height/2))

    gatherTime()
end

function closeGatherIcon()
    if m_Widget == nil or m_Root == nil then
        return
    end
    
    local btn = m_Widget:getChildByName("scale_node"):getChildByName("Button_jj")
    btn:setVisible(false)
end

function gatherTime()
    if m_Widget == nil or m_Root == nil or pop == nil then
        return
    end

    curTime = 0

    local function update()
        if curTime >= gTime then
            unschedule(pop, timeAction)
            timeAction = nil
            pop:setVisible(false)
        else
            curTime = curTime + 1
        end
    end

    if timeAction ~= nil then
        unschedule(pop, timeAction)
        timeAction = nil
    end
    timeAction =  schedule(pop, update, 1.0)
end

function schedule(target, callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  target:runAction(action)
  return action
end 

function unschedule(target, action)
  target:stopAction(action)
end

return mainSurfaceMenu