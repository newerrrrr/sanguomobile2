local mainSurfaceQueueWorld = {}
setmetatable(mainSurfaceQueueWorld,{__index = _G})
setfenv(1,mainSurfaceQueueWorld)

--local QueueHelperMD = require "game.maplayer.worldMapLayer_queueHelper"

--野外队列

local c_offset_distance = 5

local m_Root = nil
local m_QueuePanel = nil
local m_ArrowPanel = nil
local m_MyPlayerData = nil
local m_CurrentShowQueue = {} --{ data = {} , display = widget }
local m_SortShowQueue = {}
local m_IsShowAll = false

local function clearGlobal()
	m_Root = nil
	m_QueuePanel = nil
	m_ArrowPanel = nil
	m_MyPlayerData = nil
	m_CurrentShowQueue = {}
	m_SortShowQueue = {}
	m_IsShowAll = false
end

local _requireBigMap = function()
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
			bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
			bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	end
	return bigMap
end

local _requireQueueHelperMD = function()
	local queueHelperMD = require "game.maplayer.worldMapLayer_queueHelper"
	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
			queueHelperMD = require "game.mapguildwar.worldMapLayer_queueHelper"
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
			queueHelperMD = require "game.mapcitybattle.worldMapLayer_queueHelper"
	end
	return queueHelperMD
end

local _getArmyPosition = function(armyId)

	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		return g_crossArmy.GetArmyPosition(armyId)
	else
		return g_ArmyMode.GetArmyPosition(armyId)
	end
end

function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateQueueWold, 1.0 , false)
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
	
	m_MyPlayerData = g_PlayerMode.GetData()
	
	local widget = g_gameTools.LoadCocosUI("worldmap_02_collection.csb",4)
	rootLayer:addChild(widget)
	
	m_QueuePanel = widget:getChildByName("scale_node"):getChildByName("Panel_1")
	
	m_ArrowPanel = cc.CSLoader:createNode("worldmap_02_collection_arrow.csb")
	m_ArrowPanel:setAnchorPoint(cc.p(0.0,1.0))
	m_ArrowPanel:setPosition(cc.p(0.0,0.0))
	m_QueuePanel:addChild(m_ArrowPanel)
	local function onChangeShowAll(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if m_IsShowAll then
				showAllClose()
			else
				showAllOpen()
			end
		end
	end
	m_ArrowPanel:getChildByName("Panel_6"):addTouchEventListener(onChangeShowAll)
	
	updateQueueWold(0.0166)
	
	showAllClose()
	
	viewChangeShow()
	
	return rootLayer
end


function viewChangeShow()
	if m_Root then
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if mapStatus == changeMapScene.m_MapEnum.home then
			m_Root:setVisible(false)
		elseif mapStatus == changeMapScene.m_MapEnum.world then
			m_Root:setVisible(true)
		elseif mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then
			m_Root:setVisible(true)
		end
	end
end


function _updateArrow()
	local total_count = table.total(m_SortShowQueue)
	if total_count <= 2 then
		for k , v in ipairs(m_SortShowQueue) do
			v.display:setVisible(true)
		end
		m_ArrowPanel:setVisible(false)
	else
		m_ArrowPanel:setVisible(true)
		if m_IsShowAll then
			local size = m_QueuePanel:getContentSize()
			local pos = cc.p(0.0,size.height)
			for k , v in ipairs(m_SortShowQueue) do
				pos.y = pos.y - v.display:getContentSize().height - c_offset_distance
				v.display:setVisible(true)
			end
			m_ArrowPanel:setPosition(pos)
		else
			local size = m_QueuePanel:getContentSize()
			local pos = cc.p(0.0,size.height)
			local num = 0
			for k , v in ipairs(m_SortShowQueue) do
				num = num + 1
				if num <= 2 then
					pos.y = pos.y - v.display:getContentSize().height - c_offset_distance
					v.display:setVisible(true)
				else
					v.display:setVisible(false)
				end
			end
			m_ArrowPanel:setPosition(pos)
		end
	end
end


function showAllClose()
	if(m_Root == nil)then
		return
	end
	m_IsShowAll = false
	local panel = m_ArrowPanel:getChildByName("Panel_6")
	panel:getChildByName("Text_13"):setString(g_tr("queue_showAll_close"))
	panel:getChildByName("Image_18"):setVisible(true)
	panel:getChildByName("Image_19"):setVisible(false)
	_updateArrow()
end


function showAllOpen()
	if(m_Root == nil)then
		return
	end
	m_IsShowAll = true
	local panel = m_ArrowPanel:getChildByName("Panel_6")
	panel:getChildByName("Text_13"):setString(g_tr("queue_showAll_open"))
	panel:getChildByName("Image_18"):setVisible(false)
	panel:getChildByName("Image_19"):setVisible(true)
	_updateArrow()
end

function updateQueueCostIcons()
	if(m_Root == nil)then
		return
	end
	if m_Root:isVisible() == false then
		return
	end
	
	--更新cost icon
	for k , v in pairs(m_CurrentShowQueue) do
		if v.display and v.display.updateCostIcon then
			v.display:updateCostIcon()
		end
	end
end

function updateQueueWold(dt)
	if(m_Root == nil)then
		return
	end
	if m_Root:isVisible() == false then
		return
	end
	
	local bigMap = _requireBigMap()
	local queueDatas = bigMap.getCurrentQueueDatas()
	
	local selfQueues = {}
	for k , v in pairs(queueDatas.Queue) do
		if v.player_id ~= 0 and v.player_id == m_MyPlayerData.id then
			selfQueues[tostring(v.id)] = v
		end
	end
	
	local haveChange = false
	
	--优先处理删除
	for k , v in pairs(m_CurrentShowQueue) do
		if selfQueues[k] == nil then
			--remove
			removeSingleQueueUI(v)
			m_CurrentShowQueue[k] = nil	
			haveChange = true
		end
	end
	
	--再处理更新和增加
	for k1 , v1 in pairs(selfQueues) do
		if m_CurrentShowQueue[k1] then
			if m_CurrentShowQueue[k1].data.rowversion < v1.rowversion then
				--update
				m_CurrentShowQueue[k1].data = v1
				removeSingleQueueUI(m_CurrentShowQueue[k1])
				addSingleQueueUI(m_CurrentShowQueue[k1])
				haveChange = true
			end
		else
			--add
			local newTab = {data = v1}
			m_CurrentShowQueue[k1] = newTab
			addSingleQueueUI(m_CurrentShowQueue[k1])
			haveChange = true
		end
	end
	
	--排序
	if haveChange then
		m_SortShowQueue = {}
		for k , v in pairs(m_CurrentShowQueue) do
			m_SortShowQueue[(#m_SortShowQueue) + 1] = v
		end
		table.sort(m_SortShowQueue,function (a,b)
			return a.data.create_time < b.data.create_time
		end)
		local size = m_QueuePanel:getContentSize()
		local pos = cc.p(0.0,size.height)
		for k , v in ipairs(m_SortShowQueue) do
			v.display:setPosition(pos)
			pos.y = pos.y - v.display:getContentSize().height - c_offset_distance
		end
	end
	
	--更新时间显示
	for k , v in pairs(m_CurrentShowQueue) do
		v.display:lua_update_show_time()
	end
	
	if haveChange then
		_updateArrow()
	end
	
end


function removeSingleQueueUI(var)
	var.display:removeFromParent()
	var.display = nil
end

function getGuildWarSpeedCost()
	local quickConfigData = g_data.quick_bug
  local quickData
  local filter = {}
	
	local shopId = 0
	local retShopId = 0 --给刘毅用的，如果没有道具，返回shopId，如果有返回0	
   --从quick_bug配置中获取使用道具对应在shop表中的数据
  for _, value in ipairs(quickConfigData) do
		if value.type == g_Consts.UseItemType.GuildQuick then
		    shopId = value.shop_id[1]
		    break
		end
  end
  
  assert(shopId > 0)
  
  local shopItemData = require("game.gamedata.ShopItemData").new(shopId,g_Consts.ShopType.NORMAL)

  
  local costNum = shopItemData:getPrice()
  local costType = shopItemData:getCostType()
  local configId = shopItemData:getItemConfigId()
  local type = shopItemData:getType()
  
  local bagData = g_BagMode.FindItemByID(configId)
  local icon = nil
  local num = 0
  if bagData and bagData.num > 0 then
    icon = require("game.uilayer.common.DropItemView").new(type, configId, bagData.num)
    icon:setCountEnabled(false)
    num = bagData.num
    
    num = 1 --花费一个
  else
  	local cnt,iconPath = g_gameTools.getPlayerCurrencyCount(costType)
  	icon = cc.Sprite:create(iconPath)
  	num = costNum
  	retShopId = shopId
  end
  
  return icon,num,retShopId
end


--创建集结
local function _createGather(queueServerData)
	local ret = cc.CSLoader:createNode("worldmap_02_collection_1.csb")
	local panel = ret:getChildByName("Panel_c")
	
	local QueueHelperMD = _requireQueueHelperMD()
	
	panel:getChildByName("Text_2"):setString(QueueHelperMD.getQueueDesText(queueServerData))
	
	local showSpeedUp = queueServerData.parent_queue_id == 0 and QueueHelperMD.isGatherGotoType(queueServerData) and queueServerData.player_id == m_MyPlayerData.id
	if showSpeedUp then
		panel:getChildByName("Text_1"):setString(g_tr("queue_btn_speedUp"))
	else
		panel:getChildByName("Text_1"):setString(g_tr("queue_btn_look"))
	end
	
	if QueueHelperMD.isGatherGotoType(queueServerData) then
		panel:getChildByName("Image_4"):loadTexture("worldmap_image_mass.png", ccui.TextureResType.plistType)
	else
		local army_position = _getArmyPosition(queueServerData.army_id)
		if army_position == 0 then
			panel:getChildByName("Image_4"):loadTexture("worldmap_image_queue_other.png", ccui.TextureResType.plistType)
		else
			panel:getChildByName("Image_4"):loadTexture(string.format("worldmap_image_queue_%d.png",army_position), ccui.TextureResType.plistType)
		end
	end
	
	function ret:lua_update_show_time()
		if queueServerData.end_time == 0 then
			panel:getChildByName("LoadingBar_1"):setPercent(0)
			panel:getChildByName("Text_3"):setString(string.format("x:%d,y:%d", queueServerData.to_x, queueServerData.to_y))
		else
			local cur = g_clock.getCurServerTime()
			panel:getChildByName("LoadingBar_1"):setPercent(math.clampf(math.max(0,cur - queueServerData.create_time) / math.max(queueServerData.end_time - queueServerData.create_time, 1) * 100 , 0, 100))
			panel:getChildByName("Text_3"):setString(g_gameTools.convertSecondToString(math.max(0, queueServerData.end_time - cur)))
		end
	end

	local function onPanel(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			onTouchQueue(queueServerData)
		end
	end
	panel:addTouchEventListener(onPanel)
	
	local function onBotton(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if queueServerData.parent_queue_id == 0 and QueueHelperMD.isGatherGotoType(queueServerData) and queueServerData.player_id == m_MyPlayerData.id then
				local battleManager = require("game.uilayer.battleSet.battleManager")
				battleManager.speedDialog( { queueServerData = queueServerData} )
				--local UseBuffItemLayer = require("game.uilayer.publicMode.UseBuffItemLayer")
				--UseBuffItemLayer:createLayer(1,queueServerData)
			else
				if g_AllianceMode.getSelfHaveAlliance() == false then
					g_airBox.show(g_tr_original("battleHallNoAlliance"))
				else
					g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHallView").new())
				end
			end
		end
	end
	
	local function onBottonSpeedUp(sender)
		local battleManager = require("game.uilayer.battleSet.battleManager")
		battleManager.speedDialog( { queueServerData = queueServerData} )
	end
	panel:getChildByName("Image_3"):addTouchEventListener(onBotton)
	panel:getChildByName("Button_1"):addClickEventListener(onBottonSpeedUp)
	panel:getChildByName("Button_1"):getChildByName("Text_1"):setString(g_tr("queue_btn_speedUp"))
	
	function ret:updateCostIcon()
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()
		local isVaildMap = (mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle)
		if showSpeedUp and isVaildMap then
			panel:getChildByName("Button_1"):setVisible(true)
			local con = panel:getChildByName("Button_1"):getChildByName("Image_1")
			con:removeAllChildren()
			local icon,num = getGuildWarSpeedCost()
			if icon then
				con:addChild(icon)
				panel:getChildByName("Button_1"):getChildByName("Text_1_0"):setString(num.."")
				icon:setPosition(cc.p(con:getContentSize().width/2,con:getContentSize().height/2))
				local scale = con:getContentSize().width/icon:getContentSize().width
				icon:setScale(scale)
			end
		else
			panel:getChildByName("Button_1"):setVisible(false)
		end
	end
	
	ret:updateCostIcon()

	return ret
end


--创建集结正常返回
local function _createGatherNormalReturn(queueServerData)
	local ret = cc.CSLoader:createNode("worldmap_02_collection_1.csb")
	local panel = ret:getChildByName("Panel_c")
	
	local QueueHelperMD = _requireQueueHelperMD()
	
	panel:getChildByName("Text_2"):setString(QueueHelperMD.getQueueDesText(queueServerData))
	
	panel:getChildByName("Text_1"):setString(g_tr("queue_btn_speedUp"))
	
	if QueueHelperMD.isGatherGotoType(queueServerData) then
		panel:getChildByName("Image_4"):loadTexture("worldmap_image_mass.png", ccui.TextureResType.plistType)
	else
		local army_position = _getArmyPosition(queueServerData.army_id)
		if army_position == 0 then
			panel:getChildByName("Image_4"):loadTexture("worldmap_image_queue_other.png", ccui.TextureResType.plistType)
		else
			panel:getChildByName("Image_4"):loadTexture(string.format("worldmap_image_queue_%d.png",army_position), ccui.TextureResType.plistType)
		end
	end
	
	function ret:lua_update_show_time()
		if queueServerData.end_time == 0 then
			panel:getChildByName("LoadingBar_1"):setPercent(0)
			panel:getChildByName("Text_3"):setString(string.format("x:%d,y:%d", queueServerData.to_x, queueServerData.to_y))
		else
			local cur = g_clock.getCurServerTime()
			panel:getChildByName("LoadingBar_1"):setPercent(math.clampf(math.max(0,cur - queueServerData.create_time) / math.max(queueServerData.end_time - queueServerData.create_time, 1) * 100 , 0, 100))
			panel:getChildByName("Text_3"):setString(g_gameTools.convertSecondToString(math.max(0, queueServerData.end_time - cur)))
		end
	end

	local function onPanel(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			onTouchQueue(queueServerData)
		end
	end
	panel:addTouchEventListener(onPanel)
	
	local function onBotton(sender)
		local battleManager = require("game.uilayer.battleSet.battleManager")
		battleManager.speedDialog( { queueServerData = queueServerData} )
	end
	panel:getChildByName("Image_3"):addClickEventListener(onBotton)
	panel:getChildByName("Button_1"):addClickEventListener(onBotton)
	panel:getChildByName("Button_1"):getChildByName("Text_1"):setString(g_tr("queue_btn_speedUp"))
	function ret:updateCostIcon()
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then
			panel:getChildByName("Button_1"):setVisible(true)
			local con = panel:getChildByName("Button_1"):getChildByName("Image_1")
			con:removeAllChildren()
			local icon,num = getGuildWarSpeedCost()
			if icon then
				con:addChild(icon)
				panel:getChildByName("Button_1"):getChildByName("Text_1_0"):setString(num.."")
				icon:setPosition(cc.p(con:getContentSize().width/2,con:getContentSize().height/2))
				local scale = con:getContentSize().width/icon:getContentSize().width
				icon:setScale(scale)
			end
		else
			panel:getChildByName("Button_1"):setVisible(false)
		end 
	end
	ret:updateCostIcon()

	return ret
end

--创建定点
local function _createFixedPoint(queueServerData)
	local ret = cc.CSLoader:createNode("worldmap_02_collection_2.csb")
	local panel = ret:getChildByName("Panel_c")
	
	local QueueHelperMD = _requireQueueHelperMD()
	
	panel:getChildByName("Text_2"):setString(QueueHelperMD.getQueueDesText(queueServerData))
	
	panel:getChildByName("Text_1"):setString(g_tr("queue_btn_back"))
	
	local army_position = _getArmyPosition(queueServerData.army_id)
	if army_position == 0 then
		panel:getChildByName("Image_4"):loadTexture("worldmap_image_queue_other.png", ccui.TextureResType.plistType)
	else
		panel:getChildByName("Image_4"):loadTexture(string.format("worldmap_image_queue_%d.png",army_position), ccui.TextureResType.plistType)
	end
	
	function ret:lua_update_show_time()
		if queueServerData.end_time == 0 then
			panel:getChildByName("LoadingBar_1"):setPercent(0)
			panel:getChildByName("Text_3"):setString(string.format("x:%d,y:%d", queueServerData.to_x, queueServerData.to_y))
		else
			local cur = g_clock.getCurServerTime()
			panel:getChildByName("LoadingBar_1"):setPercent(math.clampf(math.max(0,cur - queueServerData.create_time) / math.max(queueServerData.end_time - queueServerData.create_time, 1) * 100 , 0, 100))
			panel:getChildByName("Text_3"):setString(g_gameTools.convertSecondToString(math.max(0, queueServerData.end_time - cur)))
		end
	end
	
	local function onPanel(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			onTouchQueue(queueServerData)
		end
	end
	panel:addTouchEventListener(onPanel)
	
	local function onBotton(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			local function msgBoxCallbcak(tp)
				if tp == 0 then
					local function onRecv(result, msgData)
						if(result==true)then
							local bigMap = _requireBigMap()
							bigMap.requestMapAllData_Manual()
						end
					end
					
					local changeMapScene = require("game.maplayer.changeMapScene")
					local mapStatus = changeMapScene.getCurrentMapStatus()
					if mapStatus == changeMapScene.m_MapEnum.guildwar then
						g_sgHttp.postData("Cross/callbackStayQueue",{ queueId = queueServerData.id },onRecv)
					elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
						g_sgHttp.postData("City_Battle/callbackStayQueue",{ queueId = queueServerData.id },onRecv)
					else
						g_sgHttp.postData("map/callbackStayQueue",{ queueId = queueServerData.id },onRecv)
					end
					
				end
			end
			g_msgBox.show(g_tr("queue_back_tips"), nil, nil, msgBoxCallbcak , 1)
		end
	end
	panel:getChildByName("Image_3"):addTouchEventListener(onBotton)
	
	return ret
end


--创建移动
local function _createMoveing(queueServerData)
	local ret = cc.CSLoader:createNode("worldmap_02_collection_3.csb")
	local panel = ret:getChildByName("Panel_c")
	
	local QueueHelperMD = _requireQueueHelperMD()
	
	panel:getChildByName("Text_2"):setString(QueueHelperMD.getQueueDesText(queueServerData))
	
	panel:getChildByName("Text_1"):setString(g_tr("queue_btn_speedUp"))
	
	if QueueHelperMD.isDetectType(queueServerData) then
		panel:getChildByName("Image_4"):loadTexture("worldmap_image_queue_spy.png", ccui.TextureResType.plistType)
	elseif QueueHelperMD.isFetchItemType(queueServerData) then
		panel:getChildByName("Image_4"):loadTexture("worldmap_image_queue_spy.png", ccui.TextureResType.plistType)
	else
		local army_position = _getArmyPosition(queueServerData.army_id)
		if army_position == 0 then
			panel:getChildByName("Image_4"):loadTexture("worldmap_image_queue_other.png", ccui.TextureResType.plistType)
		else
			panel:getChildByName("Image_4"):loadTexture(string.format("worldmap_image_queue_%d.png",army_position), ccui.TextureResType.plistType)
		end
	end
	
	function ret:lua_update_show_time()
		if queueServerData.end_time == 0 then
			panel:getChildByName("LoadingBar_1"):setPercent(0)
			panel:getChildByName("Text_3"):setString(string.format("x:%d,y:%d", queueServerData.to_x, queueServerData.to_y))
		else
			local cur = g_clock.getCurServerTime()
			panel:getChildByName("LoadingBar_1"):setPercent(math.clampf(math.max(0,cur - queueServerData.create_time) / math.max(queueServerData.end_time - queueServerData.create_time, 1) * 100 , 0, 100))
			panel:getChildByName("Text_3"):setString(g_gameTools.convertSecondToString(math.max(0, queueServerData.end_time - cur)))
		end
	end
	
	local function onPanel(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			onTouchQueue(queueServerData)
		end
	end
	panel:addTouchEventListener(onPanel)
	
	local function onBotton(sender)
		local battleManager = require("game.uilayer.battleSet.battleManager")
		battleManager.speedDialog( { queueServerData = queueServerData} )
	end
	panel:getChildByName("Image_3"):addClickEventListener(onBotton)
	panel:getChildByName("Button_1"):addClickEventListener(onBotton)
	panel:getChildByName("Button_1"):getChildByName("Text_1"):setString(g_tr("queue_btn_speedUp"))
	
	function ret:updateCostIcon()
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if mapStatus == changeMapScene.m_MapEnum.guildwar or mapStatus == changeMapScene.m_MapEnum.citybattle then
			panel:getChildByName("Button_1"):setVisible(true)
			local con = panel:getChildByName("Button_1"):getChildByName("Image_1")
			con:removeAllChildren()
			local icon,num = getGuildWarSpeedCost()
			if icon then
				con:addChild(icon)
				panel:getChildByName("Button_1"):getChildByName("Text_1_0"):setString(num.."")
				icon:setPosition(cc.p(con:getContentSize().width/2,con:getContentSize().height/2))
				local scale = con:getContentSize().width/icon:getContentSize().width
				icon:setScale(scale)
			end
		else
			panel:getChildByName("Button_1"):setVisible(false)
		end 
	end
	
	ret:updateCostIcon()
	
	return ret
end


function addSingleQueueUI(var)
	
	local QueueHelperMD = _requireQueueHelperMD()

	if QueueHelperMD.isGatherType(var.data) then
		if QueueHelperMD.isGatherNormalReturnType(var.data) then
			--集结正常返回
			var.display = _createGatherNormalReturn(var.data)
		elseif QueueHelperMD.isGatherShowBack(var.data) then
			--定点
			var.display = _createFixedPoint(var.data)
		else
			--集结
			var.display = _createGather(var.data)
		end
	else
		if QueueHelperMD.isFixedPoint(var.data) then
			--定点
			var.display = _createFixedPoint(var.data)
		else
			--移动
			var.display = _createMoveing(var.data)
		end
	end
	var.display:ignoreAnchorPointForPosition(false)
	var.display:setAnchorPoint(cc.p(0.0,1.0))
	m_QueuePanel:addChild(var.display)
end


--点击到队列
function onTouchQueue(queueServerData)
	
	local QueueHelperMD = _requireQueueHelperMD()
	
	if QueueHelperMD.isGatherType(queueServerData) then
		--集结
		local bigMap = _requireBigMap()
		if QueueHelperMD.isGatherGotoType(queueServerData) then
			--集结已经合体出发
			if queueServerData.parent_queue_id == 0 then
				--自己就是主集结
				if bigMap.getTeamInterface(queueServerData) ~= nil then
					--有部队显示就锁定部队
					bigMap.changePositionToQueue_Manual(queueServerData)
					bigMap.onClickTeam_queueServerData_Simulation(queueServerData)
				else
					--没有部队显示就锁定目标点
					bigMap.closeSmallMenu()
					bigMap.closeInputMenu()
					bigMap.changeBigTileIndex_Manual(cc.p(queueServerData.to_x, queueServerData.to_y),true)
				end
			else
				--自己不是主集结,就去找主集结
				local mainQueue = bigMap.getCurrentQueueDatas().Queue[tostring(queueServerData.parent_queue_id)]
				if mainQueue then
					--找到主集结
					bigMap.changePositionToQueue_Manual(mainQueue)
					bigMap.onClickTeam_queueServerData_Simulation(mainQueue)
				end
			end
		elseif QueueHelperMD.isGatherReturnType(queueServerData) then	
			--集结返回
			if bigMap.getTeamInterface(queueServerData) ~= nil then
				--有部队显示就锁定部队
				bigMap.changePositionToQueue_Manual(queueServerData)
				bigMap.onClickTeam_queueServerData_Simulation(queueServerData)
			else
				--没有部队显示就锁定目标点
				bigMap.closeSmallMenu()
				bigMap.closeInputMenu()
				bigMap.changeBigTileIndex_Manual(cc.p(queueServerData.to_x, queueServerData.to_y),true)
			end
		else
			--还在集结中
			if bigMap.getTeamInterface(queueServerData) ~= nil then
				--有部队显示就锁定部队
				bigMap.changePositionToQueue_Manual(queueServerData)
				bigMap.onClickTeam_queueServerData_Simulation(queueServerData)
			else
				--没有部队显示就锁定目标点
				bigMap.closeSmallMenu()
				bigMap.closeInputMenu()
				bigMap.changeBigTileIndex_Manual(cc.p(queueServerData.to_x, queueServerData.to_y),true)
			end
		end
	else
		if QueueHelperMD.isFixedPoint(queueServerData) then
			--定点
			local bigMap = _requireBigMap()
			bigMap.closeSmallMenu()
			bigMap.closeInputMenu()
			bigMap.changeBigTileIndex_Manual(cc.p(queueServerData.to_x, queueServerData.to_y),true)
		else
			--移动
			local bigMap = _requireBigMap()
			if bigMap.getTeamInterface(queueServerData) ~= nil then
				--有部队显示就锁定部队
				bigMap.changePositionToQueue_Manual(queueServerData)
				bigMap.onClickTeam_queueServerData_Simulation(queueServerData)
			else
				--没有部队显示就锁定目标点
				bigMap.closeSmallMenu()
				bigMap.closeInputMenu()
				bigMap.changeBigTileIndex_Manual(cc.p(queueServerData.to_x, queueServerData.to_y),true)
			end
		end
	end
end


--模拟点击查找队列
function simulationTouchQueue(queueServerData)
	onTouchQueue(queueServerData)
end


return mainSurfaceQueueWorld