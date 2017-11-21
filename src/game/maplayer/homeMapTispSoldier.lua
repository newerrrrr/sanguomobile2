local homeMapTispSoldier = {}
setmetatable(homeMapTispSoldier,{__index = _G})
setfenv(1,homeMapTispSoldier)

local c_move_speed = 25


local m_Root = nil

local function clearGlobal()
	m_Root = nil
end

local s_Current_Index = 1
local function getIndex()
	local ret = s_Current_Index
	s_Current_Index = s_Current_Index + 1
	if s_Current_Index > #(g_data.city_tips) then
		s_Current_Index = 1
	end
	return ret
end

local function createRole(posBegin, posEnd, rand_max, duration_time, offset_speed)
	local role = cc.Node:create()
	
	local dv = cc.pSub(posEnd, posBegin)
	local angle = cToolsForLua:calc2VecAngle(1, 0, dv.x, dv.y)
	local mv = cc.pMul(dv, math.random(2, 8) * 0.1)
	local cp = cc.pAdd(posBegin, mv)
	role:setPosition(cp)
	
	local b_2_n = (angle <= 0 and angle >= -90) and 1 or 2	--起点到终点的方向 1为右下方 2为左上方
	
	local sp_m_z = cc.Sprite:createWithSpriteFrameName("city_soldier_move_Zheng45_1.png")
	sp_m_z:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_soldier_move_Zheng45_", nil, false)))
	sp_m_z:setVisible(false)
	role:addChild(sp_m_z)
	
	local sp_size = sp_m_z:getContentSize()
	
	local sp_m_b = cc.Sprite:createWithSpriteFrameName("city_soldier_move_Bei45_1.png")
	sp_m_b:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_soldier_move_Bei45_", nil, false)))
	sp_m_b:setVisible(false)
	role:addChild(sp_m_b)
	
	local sp_s_z = cc.Sprite:createWithSpriteFrameName("city_soldier_sit_Zheng45_1.png")
	sp_s_z:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_soldier_sit_Zheng45_", nil, false)))
	sp_s_z:setVisible(false)
	role:addChild(sp_s_z)
	
	local sp_s_b = cc.Sprite:createWithSpriteFrameName("city_soldier_sit_Bei45_1.png")
	sp_s_b:runAction(cc.RepeatForever:create(g_gameTools.LoadFPSAni("city_soldier_sit_Bei45_", nil, false)))
	sp_s_b:setVisible(false)
	role:addChild(sp_s_b)
	
	
	local bp, ep = nil, nil
	local bvt = 1
	local mt = math.sqrt(cc.pDistanceSQ(posEnd, posBegin)) / (c_move_speed + offset_speed)
	local function onForeverGo()
		local function onInitPlay()
			sp_m_z:setVisible(false)
			sp_m_b:setVisible(false)
			sp_s_z:setVisible(false)
			sp_s_b:setVisible(false)
		end
		local function onPlayMove1()
			onInitPlay()
			if bvt == 1 then
				sp_m_z:setVisible(true)
			else
				sp_m_b:setVisible(true)
			end
		end
		local function onPlayMove2()
			onInitPlay()
			if bvt == 1 then
				sp_m_b:setVisible(true)
			else
				sp_m_z:setVisible(true)
			end
		end
		local function onPlaySay1()
			onInitPlay()
			require("game.maplayer.homeMapLayer").showCitySoldierTips(cc.p(role:getPositionX() + 46, role:getPositionY() + 30), getIndex(), duration_time)
			if bvt == 1 then
				sp_s_z:setVisible(true)
			else
				sp_s_b:setVisible(true)
			end
		end
		local function onPlaySay2()
			onInitPlay()
			require("game.maplayer.homeMapLayer").showCitySoldierTips(cc.p(role:getPositionX() + 46, role:getPositionY() + 30), getIndex(), duration_time)
			if bvt == 1 then
				sp_s_b:setVisible(true)
			else
				sp_s_z:setVisible(true)
			end
		end
		local last_move_t = 2
		local onMoveEnd1 = nil
		local onMoveEnd2 = nil
		local onSayEnd = nil
		onSayEnd = function ()
			if last_move_t == 1 then
				onMoveEnd1(nil, true)
			else
				onMoveEnd2(nil, true)
			end
		end
		onMoveEnd2 = function(d, v)
			if v == nil and math.random(0, rand_max) == 0 then
				role:runAction(cc.Sequence:create(cc.CallFunc:create(onPlaySay2), cc.DelayTime:create(duration_time), cc.CallFunc:create(onSayEnd)))
			else
				last_move_t = 1
				role:runAction(cc.Sequence:create(cc.CallFunc:create(onPlayMove1), cc.MoveTo:create(mt, ep), cc.CallFunc:create(onMoveEnd1)))
			end
		end
		onMoveEnd1 = function(d, v)
			if v == nil and math.random(0, rand_max) == 0 then
				role:runAction(cc.Sequence:create(cc.CallFunc:create(onPlaySay1), cc.DelayTime:create(duration_time), cc.CallFunc:create(onSayEnd)))
			else
				last_move_t = 2
				role:runAction(cc.Sequence:create(cc.CallFunc:create(onPlayMove2), cc.MoveTo:create(mt, bp), cc.CallFunc:create(onMoveEnd2)))
			end
		end
		onMoveEnd2()
	end
	
	if math.random(0, 1) == 1 then
		bp = posBegin
		ep = posEnd
		local t = math.sqrt(cc.pDistanceSQ(cp, posBegin)) / (c_move_speed + offset_speed)
		role:runAction(cc.Sequence:create(cc.MoveTo:create(t, posBegin), cc.CallFunc:create(onForeverGo)))
		if b_2_n == 1 then
			bvt = 1
			sp_m_b:setVisible(true)
		else
			bvt = 2
			sp_m_z:setVisible(true)
		end
	else
		bp = posEnd
		ep = posBegin
		local t = math.sqrt(cc.pDistanceSQ(cp, posEnd)) / (c_move_speed + offset_speed)
		role:runAction(cc.Sequence:create(cc.MoveTo:create(t, posEnd), cc.CallFunc:create(onForeverGo)))
		if b_2_n == 1 then
			bvt = 2
			sp_m_z:setVisible(true)
		else
			bvt = 1
			sp_m_b:setVisible(true)
		end
	end
	
	
	return role
end


function create()
	
	clearGlobal()
	
	cc.SpriteFrameCache:getInstance():addSpriteFrames("animeFps/city/city_move.plist","animeFps/city/city_move.png")
	
	local rootLayer = cc.Layer:create()
	m_Root = rootLayer
	
	local function rootLayerEventHandler(eventType)
        if eventType == "enter" then
		elseif eventType == "exit" then
		elseif eventType == "enterTransitionFinish" then
		elseif eventType == "exitTransitionStart" then
		elseif eventType == "cleanup" then
			if(rootLayer == m_Root)then
				clearGlobal()
			end
        end
    end
    rootLayer:registerScriptHandler(rootLayerEventHandler)
	
	--rootLayer:addChild(createRole(cc.p(1150, 515), cc.p(1035, 570), 4, 6, 0))
	
	rootLayer:addChild(createRole(cc.p(1780, 890), cc.p(1720, 922), 6, 6, -5))
	
	rootLayer:addChild(createRole(cc.p(2800, 716), cc.p(2460, 878), 3, 6, 5))
	
	return rootLayer
end








return homeMapTispSoldier