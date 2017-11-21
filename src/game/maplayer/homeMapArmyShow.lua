local homeMapArmyShow = {}
setmetatable(homeMapArmyShow,{__index = _G})
setfenv(1,homeMapArmyShow)


local m_Root = nil
local m_AnimationNode = nil
local m_CurrentHasAniPlaying = false
local m_WaitAniQueue = {}

local function clearGlobal()
	m_Root = nil
	m_AnimationNode = nil
	m_CurrentHasAniPlaying = false
	m_WaitAniQueue = {}
end


local c_ArmyShowRange = nil

local c_tag_show_army = 55546122


--创建
function create()

	if c_ArmyShowRange == nil then
		--根据配置初始化 3档
		c_ArmyShowRange = { [1] = {} , [2] = {} , [3] = {}}
		local s = string.split(g_data.starting[38].name, ",")
		c_ArmyShowRange[1].min = tonumber(s[1])
		c_ArmyShowRange[1].max = tonumber(s[2])
		s = string.split(g_data.starting[39].name, ",")
		c_ArmyShowRange[2].min = tonumber(s[1])
		c_ArmyShowRange[2].max = tonumber(s[2])
		s = string.split(g_data.starting[40].name, ",")
		c_ArmyShowRange[3].min = tonumber(s[1])
		c_ArmyShowRange[3].max = tonumber(s[2])
	end

	clearGlobal()
	
	local rootLayer = lhs.LHSManualVisitLayer:create()
	m_Root = rootLayer
	
	local schedulers = {}
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_armyShow, 0.5 , false)
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

	rootLayer:ignoreAnchorPointForPosition(false)
	rootLayer:setAnchorPoint(cc.p(0.0,0.0))
	rootLayer:setPosition(cc.p(0.0,0.0))

	local clipNode = cc.ClippingNode:create()
	clipNode:ignoreAnchorPointForPosition(false)
	clipNode:setAnchorPoint(cc.p(0.0,0.0))
	clipNode:setPosition(cc.p(0.0,0.0))
	clipNode:setContentSize(cc.size(0.0,0.0))
	clipNode:setInverted(false)
	rootLayer:addChild(clipNode,2)
	
	local stencil = cc.DrawNode:create()
	stencil:ignoreAnchorPointForPosition(false)
	stencil:setAnchorPoint(cc.p(0.0,0.0))
	stencil:setPosition(cc.p(1858.0,557.0))
	stencil:setContentSize(cc.size(0.0,0.0))
	local vet = {
		[1] = cc.p(0.0 , -400 ),
		[2] = cc.p(400.0 , -400 ),
		[3] = cc.p(400.0 , 195.0 ),
		[4] = cc.p(0.0 , 0.0 ),
	}
	stencil:drawSolidPoly(vet, 4,cc.c4f(0.0,0.0,0.0,1.0))
	clipNode:setStencil(stencil)
	
	
	m_AnimationNode = cc.Node:create()
	m_AnimationNode:ignoreAnchorPointForPosition(false)
	m_AnimationNode:setAnchorPoint(cc.p(0.0,0.0))
	m_AnimationNode:setPosition(cc.p(0.0,0.0))
	m_AnimationNode:setContentSize(cc.size(0.0,0.0))
	clipNode:addChild(m_AnimationNode)
	
	
--[[	do --测试裁减位置节点
		local testNode = cc.DrawNode:create()
		testNode:ignoreAnchorPointForPosition(false)
		testNode:setAnchorPoint(cc.p(0.0,0.0))
		testNode:setPosition(cc.p(0.0,0.0))
		testNode:setContentSize(cc.size(0.0,0.0))
		testNode:drawSolidRect(cc.p(0.0,0.0), cc.p(6000.0,3000.0),cc.c4f(1.0,0.0,0.0,1.0))
		clipNode:addChild(testNode)
	end--]]
	
	
	--先删除所有
	local childs = require("game.maplayer.homeMapLayer").getShowArmyRootNode():getChildren()
	for k , v in pairs(childs) do
		v:removeAllChildren()
	end
	
	reviewShowWithServerData()

	return rootLayer
end


--计算区间使用图片ID
local function _opUseImageID(count)
	local ret = {0,0,0,0,0,0}	--有6个 0为没有
	if count > 0 then
		local max_count = 0
		local mid_count = 0
		local min_count = 0
		local max_count_1 = math.floor( count / c_ArmyShowRange[3].max )
		local max_count_2 = ( count % c_ArmyShowRange[3].max >= c_ArmyShowRange[3].min ) and 1 or 0
		max_count = max_count_1 + max_count_2
		count = count - max_count * c_ArmyShowRange[3].max
		if count > 0 then
			local mid_count_1 = math.floor( count / c_ArmyShowRange[2].max )
			local mid_count_2 = ( count % c_ArmyShowRange[2].max >= c_ArmyShowRange[2].min ) and 1 or 0
			mid_count = mid_count_1 + mid_count_2
			count = count - mid_count * c_ArmyShowRange[2].max
			if count > 0 then
				local min_count_1 = math.floor( count / c_ArmyShowRange[1].max )
				local min_count_2 = ( count % c_ArmyShowRange[1].max >= c_ArmyShowRange[1].min ) and 1 or 0
				min_count = min_count_1 + min_count_2
				count = count - min_count * c_ArmyShowRange[1].max
			end
		end
		for k , v in ipairs(ret) do
			if max_count > 0 then
				max_count = max_count - 1
				ret[k] = 3
			elseif mid_count > 0 then
				mid_count = mid_count - 1
				ret[k] = 2
			elseif min_count > 0 then
				min_count = min_count - 1
				ret[k] = 1
			end
		end
	end
	return ret
end


--根据服务器数据缓存重新排版
function reviewShowWithServerData()
	if(m_Root == nil)then
		return
	end

	local army_count_new = g_ArmyUnitMode.GetAllSodier()
	
	local showArmyRootNode = require("game.maplayer.homeMapLayer").getShowArmyRootNode()
	
	--每种兵
	for k , v in pairs(g_ArmyUnitMode.m_SoldierOriginType) do
		local count = army_count_new[v]
		local perName1 = nil
		local perName2 = nil
		if v == g_ArmyUnitMode.m_SoldierOriginType.infantry then--步兵
			perName1 = "infantry_"
			perName2 = "infantry"
		elseif v == g_ArmyUnitMode.m_SoldierOriginType.cavalry then--骑兵
			perName1 = "cavalry_"
			perName2 = "cavalry"
		elseif v == g_ArmyUnitMode.m_SoldierOriginType.archer then--弓兵
			perName1 = "archer_"
			perName2 = "archer"
		elseif v == g_ArmyUnitMode.m_SoldierOriginType.vehicles then--车兵
			perName1 = "vehicles_"
			perName2 = "car"
		else
			assert(false,"error : unknow soldier origin type")
		end
		
		local imageIDTable = _opUseImageID(count) --计算显示图片表
		
		for k , v in ipairs(imageIDTable) do
			
			local showParent = showArmyRootNode:getChildByName(perName1..tostring(k))
			
			local originDisplay = showParent:getChildByTag(c_tag_show_army)
			
			if originDisplay then
				--原来有显示
				if v == 0 then
					if originDisplay.lua_flag ~= v then
						--删除
						originDisplay.lua_flag = v
						originDisplay:stopAllActions()
						originDisplay:runAction(cc.Sequence:create(cc.FadeTo:create(0.4,0),cc.RemoveSelf:create()))
					end
				else
					if originDisplay.lua_flag ~= v then
						--变化
						originDisplay.lua_flag = v
						originDisplay:stopAllActions()
						local function onChangeImage()
							originDisplay:setSpriteFrame(string.format("homeImage_%s_pose_%d.png", perName2, v))
						end
						originDisplay:runAction(cc.Sequence:create(cc.FadeTo:create(0.4,0), cc.CallFunc:create(onChangeImage), cc.FadeTo:create(0.4,255)))
					end
				end
			else
				--原来没显示
				if v ~= 0 then
					--需要加入显示
					local newDisplay = cc.Sprite:createWithSpriteFrameName(string.format("homeImage_%s_pose_%d.png", perName2, v))
					newDisplay.lua_flag = v
					newDisplay:setOpacity(0)
					newDisplay:runAction(cc.FadeTo:create(0.4,255))
					showParent:addChild(newDisplay, 0, c_tag_show_army)
				end
			end
			
		end
		
	end

end


--播放
local function _playRunAnimation(tp)
	local display = nil
	if tp == tonumber(g_ArmyUnitMode.m_SoldierOriginType.infantry) then--步兵
		display = cc.Sprite:createWithSpriteFrameName("city_infantry_walk_1.png")
		display:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_infantry_walk_")))
	elseif tp == tonumber(g_ArmyUnitMode.m_SoldierOriginType.cavalry) then--骑兵
		display = cc.Sprite:createWithSpriteFrameName("city_cavalry_walk_1.png")
		display:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_cavalry_walk_")))
	elseif tp == tonumber(g_ArmyUnitMode.m_SoldierOriginType.archer) then--弓兵
		display = cc.Sprite:createWithSpriteFrameName("city_archer_walk_1.png")
		display:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_archer_walk_")))
	elseif tp == tonumber(g_ArmyUnitMode.m_SoldierOriginType.vehicles) then--车兵
		display = cc.Sprite:createWithSpriteFrameName("city_car_walk_1.png")
		display:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_car_walk_")))
	else
		assert(false,"error : unknow soldier origin type")
	end
	
	m_AnimationNode:addChild(display)
	
	local c_move_tiem = 7.0
	local c_delay_time = c_move_tiem * 0.78
	local c_hide_time = c_move_tiem * 0.22
	
	local size = display:getContentSize()
	
	display:setPosition(cc.p(1850.0 - size.width / 2.0, 542.0 + size.height / 2.0))
	display:runAction(cc.MoveTo:create(c_move_tiem, cc.p(2200.0, 332.0)))
	display:runAction(cc.Sequence:create(
		cc.DelayTime:create(c_delay_time * 0.55)
		, cc.CallFunc:create(function() m_CurrentHasAniPlaying = false end)
		, cc.DelayTime:create(c_delay_time * 0.45)
		, cc.FadeTo:create(c_hide_time,0)
		, cc.CallFunc:create(function() reviewShowWithServerData() end)
		, cc.RemoveSelf:create()
		))
end


--循环更新
function update_armyShow(dt)
	if(m_Root == nil)then
		return
	end
	
	if m_CurrentHasAniPlaying == false then
		for k , v in pairs(m_WaitAniQueue) do
			m_CurrentHasAniPlaying = true
			_playRunAnimation(v)
			table.remove(m_WaitAniQueue,k)
			break
		end
	end

end


--收获时压入显示队列
function pushArmy(tp)
	if(m_Root == nil)then
		return
	end
	m_WaitAniQueue[(#m_WaitAniQueue) + 1] = tonumber(tp)
end



return homeMapArmyShow