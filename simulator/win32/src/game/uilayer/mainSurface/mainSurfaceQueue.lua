local mainSurfaceQueue = {}
setmetatable(mainSurfaceQueue,{__index = _G})
setfenv(1,mainSurfaceQueue)


local c_chargeQueue_time = 172800 	--收费队列买一次多长时间
local c_chargeQueue_day = c_chargeQueue_time / 86400
local c_chargeQueue_price = 200 	--买一个多少元宝


local c_tag_chargeQueueTips_show_action = 15164473
local c_tag_chargeQueue_NotHave_effect = 15164474
local c_tag_ZZZ_Free_effect = 15164475
local c_tag_ZZZ_Charge_effect = 15164476
local c_tag_Free_Free_effect = 15164477
local c_tag_Free_Charge_effect = 15164478


local m_Root = nil
local m_Widget = nil
local m_Scale_node = nil
local m_ChargeTips = nil
local m_FreeBuild = {}
local m_ChargeBuild = {}

local function clearGlobal()
	m_Root = nil
	m_Widget = nil
	m_Scale_node = nil
	m_ChargeTips = nil
	m_FreeBuild = {}
	m_ChargeBuild = {}
end


function create()
	
	clearGlobal()
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateQueue, 1.0 , false)
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
	
	
	m_Widget = g_gameTools.LoadCocosUI("cuizi.csb",4)
	rootLayer:addChild(m_Widget)
	
	m_Scale_node = m_Widget:getChildByName("scale_node")
	--m_Scale_node:setScale(1.0)--这个UI较为特别,或许可以不用缩放
	
	m_ChargeTips = m_Scale_node:getChildByName("Image_3")
	m_ChargeTips:getChildByName("Text_2"):setString(g_tr("queue_subtime"))
	m_ChargeTips:setVisible(false)
	m_ChargeTips:setCascadeOpacityEnabled(true)
	m_ChargeTips:setOpacity(0)
	m_ChargeTips:getChildByName("Text_2_0"):setString("")
	
	m_Scale_node:getChildByName("Text_m1"):setString(g_tr("queue_free"))
	m_Scale_node:getChildByName("Text_m2"):setString(g_tr("queue_free"))
	
	do--没购买时的特效
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_AnNiuXunHuanOne/Effect_AnNiuXunHuanOne.ExportJson", "Effect_AnNiuXunHuanOne")
		local pos = cc.p(m_Scale_node:getChildByName("Image_2"):getPositionX(),m_Scale_node:getChildByName("Image_2"):getPositionY())
		m_Scale_node:addChild(armature,1,c_tag_chargeQueue_NotHave_effect)
		armature:setPosition(pos)
		animation:play("Animation1")
		armature:setScale(0.8)
		armature:setVisible(haveChargeQueue() == false)
	end
	
	do--免费空闲时的特效
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian")
		local pos = cc.p(m_Scale_node:getChildByName("Image_2_0"):getPositionX(),m_Scale_node:getChildByName("Image_2_0"):getPositionY())
		m_Scale_node:addChild(armature,1,c_tag_ZZZ_Free_effect)
		armature:setPosition(pos)
		animation:play("Animation2")
		armature:setVisible(g_PlayerBuildMode.FindBuild_InFree() == nil and true or false)
	end
	
	do--收费空闲时的特效
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_JianZhuKongXian/Effect_JianZhuKongXian.ExportJson", "Effect_JianZhuKongXian")
		local pos = cc.p(m_Scale_node:getChildByName("Image_2"):getPositionX(),m_Scale_node:getChildByName("Image_2"):getPositionY())
		m_Scale_node:addChild(armature,1,c_tag_ZZZ_Charge_effect)
		armature:setPosition(pos)
		animation:play("Animation2")
		armature:setVisible( (haveChargeQueue() and g_PlayerBuildMode.FindBuild_InCharge() == nil) and true or false )
	end
	
	do--免费秒掉的特效
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_AnNiuXunHuanOne/Effect_AnNiuXunHuanOne.ExportJson", "Effect_AnNiuXunHuanOne")
		local pos = cc.p(m_Scale_node:getChildByName("Image_2_0"):getPositionX(),m_Scale_node:getChildByName("Image_2_0"):getPositionY())
		m_Scale_node:addChild(armature,1,c_tag_Free_Free_effect)
		armature:setPosition(pos)
		animation:play("Animation1")
		armature:setScale(0.8)
		armature:setVisible(true)
	end
	
	do--收费秒掉的特效
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_AnNiuXunHuanOne/Effect_AnNiuXunHuanOne.ExportJson", "Effect_AnNiuXunHuanOne")
		local pos = cc.p(m_Scale_node:getChildByName("Image_2"):getPositionX(),m_Scale_node:getChildByName("Image_2"):getPositionY())
		m_Scale_node:addChild(armature,1,c_tag_Free_Charge_effect)
		armature:setPosition(pos)
		animation:play("Animation1")
		armature:setScale(0.8)
		armature:setVisible(true)
	end
	
	
	--点击免费
	local function onButton1(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			local freeBuild = g_PlayerBuildMode.FindBuild_InFree()
			if freeBuild then
				require("game.maplayer.homeMapLayer").moveToCenterForGuide(freeBuild.position)
			else
				g_TaskMode.guideToBuildMainTask()
			end
		end
	end
	m_Scale_node:getChildByName("Image_2_0"):addTouchEventListener(onButton1)
	
	
	--点击收费
	local function onButton2(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if haveChargeQueue() then
				showChargeQueueTips()
				local chargeBuild = g_PlayerBuildMode.FindBuild_InCharge()
				if chargeBuild then
					require("game.maplayer.homeMapLayer").moveToCenterForGuide(chargeBuild.position)
				else
					g_TaskMode.guideToBuildMainTask()
				end
			else
				local function onBuySucceedCallback()
					showChargeQueueTips()
				end
				showBuyInterface_with_needCount(1, onBuySucceedCallback )
			end
		end
	end
	m_Scale_node:getChildByName("Image_2"):addTouchEventListener(onButton2)
    
	updateQueue(0.0166)

	
	viewChangeShow()

	return rootLayer
end


function viewChangeShow()
	if m_Root then
		local changeMapScene = require("game.maplayer.changeMapScene")
		local mapStatus = changeMapScene.getCurrentMapStatus()
		if mapStatus == changeMapScene.m_MapEnum.home then
			m_Root:setVisible(true)
		elseif mapStatus == changeMapScene.m_MapEnum.world then
			m_Root:setVisible(false)
		elseif mapStatus == changeMapScene.m_MapEnum.guildwar then
			m_Root:setVisible(false)
		elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
		  m_Root:setVisible(false)
		end
	end
end


function updateQueue(dt)
	if(m_Root == nil)then
		return
	end
	if m_Root:isVisible() == false then
		return
	end
	
	local freeBuild = g_PlayerBuildMode.FindBuild_InFree()
	if(m_FreeBuild ~= freeBuild)then
		m_FreeBuild = freeBuild
		if(m_FreeBuild)then
			m_Scale_node:getChildByName("Image_1_0"):loadTexture(g_data.sprite[g_data.build[tonumber(m_FreeBuild.build_id)].hammer_img].path)
			m_Scale_node:getChildByName("Text_1_0"):setString("")
		else
			m_Scale_node:getChildByName("Image_1_0"):loadTexture(g_data.sprite[1004001].path)
			m_Scale_node:getChildByName("Text_1_0"):setString("")
		end
	elseif(m_FreeBuild)then
		--更新时间
		local t = tonumber(m_FreeBuild.build_finish_time) - g_clock.getCurServerTime()
		if(t > 0)then
			m_Scale_node:getChildByName("Text_1_0"):setString(g_gameTools.convertSecondToString(t))
		else
			m_Scale_node:getChildByName("Text_1_0"):setString("")
		end
	end

	local chargeBuild = g_PlayerBuildMode.FindBuild_InCharge()
	if(m_ChargeBuild ~= chargeBuild)then
		m_ChargeBuild = chargeBuild
		if(m_ChargeBuild)then
			m_Scale_node:getChildByName("Image_1"):loadTexture(g_data.sprite[g_data.build[tonumber(m_ChargeBuild.build_id)].hammer_img].path)
			m_Scale_node:getChildByName("Text_1"):setString("")
			
			
			
		else
			m_Scale_node:getChildByName("Image_1"):loadTexture(g_data.sprite[1004002].path)
			m_Scale_node:getChildByName("Text_1"):setString("")
		end
	elseif(m_ChargeBuild)then
		--更新时间
		local t = tonumber(m_ChargeBuild.build_finish_time) - g_clock.getCurServerTime()
		if(t > 0)then
			m_Scale_node:getChildByName("Text_1"):setString(g_gameTools.convertSecondToString(t))
		else
			m_Scale_node:getChildByName("Text_1"):setString("")
		end
	end
	
	m_Scale_node:getChildByTag(c_tag_chargeQueue_NotHave_effect):setVisible(haveChargeQueue() == false)
	
	m_Scale_node:getChildByTag(c_tag_ZZZ_Free_effect):setVisible(m_FreeBuild == nil and true or false)
	
	m_Scale_node:getChildByTag(c_tag_ZZZ_Charge_effect):setVisible( (haveChargeQueue() and m_ChargeBuild == nil) and true or false )
	
	if m_FreeBuild and g_PlayerBuildMode.CheckFreeBuildEnd_ID(m_FreeBuild.id) then
		m_Scale_node:getChildByTag(c_tag_Free_Free_effect):setVisible(true)
		m_Scale_node:getChildByName("Text_m1"):setVisible(true)
	else	
		m_Scale_node:getChildByTag(c_tag_Free_Free_effect):setVisible(false)
		m_Scale_node:getChildByName("Text_m1"):setVisible(false)
	end
	
	if m_ChargeBuild and g_PlayerBuildMode.CheckFreeBuildEnd_ID(m_ChargeBuild.id) then
		m_Scale_node:getChildByTag(c_tag_Free_Charge_effect):setVisible(true)
		m_Scale_node:getChildByName("Text_m2"):setVisible(true)
	else	
		m_Scale_node:getChildByTag(c_tag_Free_Charge_effect):setVisible(false)
		m_Scale_node:getChildByName("Text_m2"):setVisible(false)
	end
	
end


--显示一段时间的收费tips
function showChargeQueueTips()
	if(m_Root == nil)then
		return
	end
	local timeStr = g_gameTools.convertSecondToString(chargeQueueResidualTime())
	m_ChargeTips:getChildByName("Text_2_0"):setString(timeStr)
	m_ChargeTips:stopActionByTag(c_tag_chargeQueueTips_show_action)
	local action = cc.Sequence:create( 
		cc.Show:create() 
		, cc.FadeTo:create(0.4,255) 
		, cc.DelayTime:create(2.2)
		, cc.FadeTo:create(0.4,0)
		, cc.Hide:create()
		)
	action:setTag(c_tag_chargeQueueTips_show_action)
	m_ChargeTips:runAction(action)
end



--是否有收费队列
function haveChargeQueue()
	return chargeQueueResidualTime() > 0
end


--收费队列结束时间戳
function chargeQueueEndTime()
	local tab = g_BuffMode.GetData().build_queue
	return tonumber(tab.v) == 1 and tonumber(tab.tmp[1].expire_time) or 0
end


--收费队列剩余时间
function chargeQueueResidualTime()
	return math.max(0, chargeQueueEndTime() - g_clock.getCurServerTime())
end


--传入需要时间
--如果收费队列剩余时间足够将返回true
--否则返回false并且弹出让玩家购买提示
function checkAndTipsChargeQueue( needTime , buySucceedCallback )
	if chargeQueueResidualTime() > needTime then
		return true
	else
		showBuyInterface_with_needTime(needTime , buySucceedCallback)
		return false
	end
end


--显示购买界面 需要时间
function showBuyInterface_with_needTime(needTime , buySucceedCallback)
	local residualTime = chargeQueueResidualTime()
	showBuyInterface_with_needCount(math.ceil( (needTime - residualTime) / c_chargeQueue_time ), buySucceedCallback)
end



--显示购买界面 需要购买的个数
function showBuyInterface_with_needCount(needCount , buySucceedCallback)
	
	local needGem = c_chargeQueue_price * needCount
	
	local function onOK()
		local function onRecv(result, msgData)
			if result==true then
				g_BuffMode.RequestData()
				if buySucceedCallback then
					buySucceedCallback()
				end
			end
		end
		g_sgHttp.postData("player/buyExtraBuildQueue",{itemNum = needCount},onRecv)
	end
	
	g_msgBox.showConsume(
		needGem
		, g_tr("queue_msg",{price = needGem , time = c_chargeQueue_day * needCount})
		, nil
		, g_tr("queue_buy")
		, onOK
		)
end




return mainSurfaceQueue