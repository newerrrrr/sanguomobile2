local worldMapLayer_buildEffect = {}
setmetatable(worldMapLayer_buildEffect,{__index = _G})
setfenv(1,worldMapLayer_buildEffect)

local HelperMD = require "game.mapcitybattle.worldMapLayer_helper"
local QueueHelperMD = require "game.mapcitybattle.worldMapLayer_queueHelper"
local RequestTimeMD = require "game.mapcitybattle.worldMapLayer_requestTime"

local c_range_active_image_size = nil
local c_range_active_width = nil

local c_range_active_speed = 150.0

local c_range_color_self = cc.c3b(0, 0, 255)
local c_range_color_other = cc.c3b(255, 0, 0)

local c_anchor_left = cc.p(0.0, 0.5)
local c_anchor_right = cc.p(1.0, 0.5)

local c_build_attack_stay = 2.5



local c_tag_fire_effect = 19554681
local c_tag_avoid_effect = 19554682
local c_tag_king_avoid_effect = 19554683
local c_tag_heshibi_effect = 19554684
local c_tag_repair_effect = 19554685
local c_tag_job_effect = 19554686
local c_tag_avoid_time = 19554687
local c_tag_camp_avoid_time = 19554688

local c_job_anis = {
	[1] = { n1 = "anime/Effect_HuangDi/Effect_HuangDi.ExportJson", n2 = "Effect_HuangDi", n3 = "Animation1" } ,
	[2] = { n1 = "anime/Effect_GuoWangZhanWenGuangXuLie/Effect_GuoWangZhanWenGuangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWenGuangXuLie", n3 = "ChengXiang" } ,
	[3] = { n1 = "anime/Effect_GuoWangZhanWenGuangXuLie/Effect_GuoWangZhanWenGuangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWenGuangXuLie", n3 = "SiTu" } ,
	[4] = { n1 = "anime/Effect_GuoWangZhanWenGuangXuLie/Effect_GuoWangZhanWenGuangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWenGuangXuLie", n3 = "SiKong" } ,
	[5] = { n1 = "anime/Effect_GuoWangZhanWenGuangXuLie/Effect_GuoWangZhanWenGuangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWenGuangXuLie", n3 = "SiMa" } ,
	[6] = { n1 = "anime/Effect_GuoWangZhanWuJiangXuLie/Effect_GuoWangZhanWuJiangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWuJiangXuLie", n3 = "DaJiangJun" } ,
	[7] = { n1 = "anime/Effect_GuoWangZhanWuJiangXuLie/Effect_GuoWangZhanWuJiangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWuJiangXuLie", n3 = "BiaoQiJiangJun" } ,
	[8] = { n1 = "anime/Effect_GuoWangZhanWuJiangXuLie/Effect_GuoWangZhanWuJiangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWuJiangXuLie", n3 = "CheQiJiangJun" } ,
	[9] = { n1 = "anime/Effect_GuoWangZhanWuJiangXuLie/Effect_GuoWangZhanWuJiangXuLie.ExportJson", n2 = "Effect_GuoWangZhanWuJiangXuLie", n3 = "WeiJiangJun" } ,
	[10] = { n1 = "anime/Effect_DeBuffTongYong/Effect_DeBuffTongYong.ExportJson", n2 = "Effect_DeBuffTongYong", n3 = "MaFu" } ,
	[11] = { n1 = "anime/Effect_DeBuffTongYong/Effect_DeBuffTongYong.ExportJson", n2 = "Effect_DeBuffTongYong", n3 = "ShanZei" } ,
	[12] = { n1 = "anime/Effect_DeBuffTongYong/Effect_DeBuffTongYong.ExportJson", n2 = "Effect_DeBuffTongYong", n3 = "PingMing" } ,
	[13] = { n1 = "anime/Effect_DeBuffTongYong/Effect_DeBuffTongYong.ExportJson", n2 = "Effect_DeBuffTongYong", n3 = "TaoBin" } ,
	[14] = { n1 = "anime/Effect_DeBuffTongYong/Effect_DeBuffTongYong.ExportJson", n2 = "Effect_DeBuffTongYong", n3 = "LuanDang" } ,
	[15] = { n1 = "anime/Effect_DeBuffTongYong/Effect_DeBuffTongYong.ExportJson", n2 = "Effect_DeBuffTongYong", n3 = "QiuFan" } ,
}





--是否有任何队列正在这个建筑里做queueType类型的事情
local function isHaveQueueDoing(buildServerData, queueType)
	local bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	local currentQueueDatas = bigMap.getCurrentQueueDatas()
	for k , v in pairs(currentQueueDatas.Queue) do
		assert(v.to_map_id ~= 0, "error : to_map_id == 0 ")
		if buildServerData.id == v.to_map_id then
			if v.type == queueType then
				return v
			end
		end
	end
	return nil
end


--创建资源占领旗帜
local function _createResFlag(serverData, configData, originBigTileIndex)
	local filename = nil
	if serverData.player_id == g_cityBattlePlayerData.GetData().player_id then
		--自己
		filename = "worldmap_image_flag_self.png"
	elseif serverData.camp_id ~= 0 and serverData.camp_id == g_cityBattlePlayerData.getCampId() then
		--盟友
		filename = "worldmap_image_flag_friend.png"
	else
		--其他人
		filename = "worldmap_image_flag_enemy.png"
	end
	local ret = cc.Sprite:createWithSpriteFrameName(filename)
	ret:setAnchorPoint(cc.p(0.5,0.0))
	ret:setPosition(cc.p(0.0,0.0))
	return ret
end


--创建据点占领旗帜
local function _createStrongholdFlag(serverData, configData, originBigTileIndex)
	local filename = nil
	if serverData.player_id == g_cityBattlePlayerData.GetData().player_id then
		--自己
		filename = "worldmap_image_flag_self.png"
	elseif serverData.camp_id ~= 0 and serverData.camp_id == g_cityBattlePlayerData.getCampId() then
		--盟友
		filename = "worldmap_image_flag_friend.png"
	else
		--其他人
		filename = "worldmap_image_flag_enemy.png"
	end
	local ret = cc.Sprite:createWithSpriteFrameName(filename)
	ret:setAnchorPoint(cc.p(0.5,0.0))
	ret:setPosition(cc.p(0.0,0.0))
	return ret
end

--创建聯盟戰佔領旗幟
local function _createGuildWarHoldFlag(serverData, configData, originBigTileIndex)
	local filename = nil
	if serverData.player_id == g_cityBattlePlayerData.GetData().player_id then
		--自己
		filename = "worldmap_image_flag_self1.png"
	elseif serverData.camp_id ~= 0 and serverData.camp_id == g_cityBattlePlayerData.getCampId() then
		--盟友
		filename = "worldmap_image_flag_friend1.png"
	else
		--其他人
		filename = "worldmap_image_flag_enemy1.png"
	end
	local ret = cc.Sprite:createWithSpriteFrameName(filename)
	ret:setAnchorPoint(cc.p(0.5,0.0))
	ret:setPosition(cc.p(0.0,0.0))
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu then
		ret:setPositionX(ret:getPositionX() + 50)
	end
	return ret
end


--创建范围扩散特效
function create_fort_range(serverData, configData, tp)
	local ret = cc.Node:create()
	ret:setCascadeOpacityEnabled(true)
	ret:runAction(cc.RepeatForever:create(cc.Sequence:create( cc.FadeTo:create(1.0, 32), cc.FadeTo:create(1.0, 192) )))
	
	if c_range_active_image_size == nil then
		c_range_active_image_size = cc.Director:getInstance():getTextureCache():addImage("worldmap/notPlist/range_active.png"):getContentSize()
		c_range_active_width = c_range_active_image_size.width * HelperMD.m_CosVar
	end
	
	local col = ((serverData.camp_id ~= 0 and serverData.camp_id == g_cityBattlePlayerData.getCampId()) and c_range_color_self or c_range_color_other)
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then
		col = g_cityBattleInfoData.IsSelfOccupationArea(tonumber(serverData.area)) and c_range_color_self or c_range_color_other
	end
	
	local active_time = HelperMD.m_SingleSizeHalf.width * configData.range / c_range_active_speed
	
	local min_SideLength = 0
	local max_SideLength = 0
	
	local count = #(configData.x_y) --此版本建筑物只有占1,4,9,16格的而已
	if count == 4 then
		min_SideLength = HelperMD.m_SingleHypotenuseLength * 2
		max_SideLength = HelperMD.m_SingleHypotenuseLength * (configData.range * 2 + 2)
	elseif count == 9 then
		min_SideLength = HelperMD.m_SingleHypotenuseLength * 3
		max_SideLength = HelperMD.m_SingleHypotenuseLength * (configData.range * 2 + 3)
	elseif count == 16 then
		min_SideLength = HelperMD.m_SingleHypotenuseLength * 4
		max_SideLength = HelperMD.m_SingleHypotenuseLength * (configData.range * 2 + 4)
	else
		min_SideLength = HelperMD.m_SingleHypotenuseLength
		max_SideLength = HelperMD.m_SingleHypotenuseLength * (configData.range * 2 + 1)
	end
	
	local min_scale = min_SideLength / c_range_active_image_size.width
	local max_scale = max_SideLength / c_range_active_image_size.width
	
	local min_arc_scale = 1.0 / min_scale
	local max_arc_scale = 1.0 / max_scale
	
	local left_top_img = cc.Sprite:create("worldmap/notPlist/range_active.png")
	left_top_img:setAnchorPoint(c_anchor_left)
	left_top_img:setPosition(cc.p(c_range_active_width * -1.0, 0.0))
	left_top_img:setRotation(HelperMD.m_HypotenuseAngle * -1.0)
	left_top_img:setColor(col)
	ret:addChild(left_top_img)
	
	local left_bottom_img = cc.Sprite:create("worldmap/notPlist/range_active.png")
	left_bottom_img:setAnchorPoint(c_anchor_left)
	left_bottom_img:setPosition(cc.p(c_range_active_width * -1.0, 0.0))
	left_bottom_img:setRotation(HelperMD.m_HypotenuseAngle)
	left_bottom_img:setColor(col)
	ret:addChild(left_bottom_img)

	local right_top_img = cc.Sprite:create("worldmap/notPlist/range_active.png")
	right_top_img:setAnchorPoint(c_anchor_right)
	right_top_img:setPosition(cc.p(c_range_active_width * 1.0, 0.0))
	right_top_img:setRotation(HelperMD.m_HypotenuseAngle)
	right_top_img:setColor(col)
	ret:addChild(right_top_img)
	
	local right_bottom_img = cc.Sprite:create("worldmap/notPlist/range_active.png")
	right_bottom_img:setAnchorPoint(c_anchor_right)
	right_bottom_img:setPosition(cc.p(c_range_active_width * 1.0, 0.0))
	right_bottom_img:setRotation(HelperMD.m_HypotenuseAngle * -1.0)
	right_bottom_img:setColor(col)
	ret:addChild(right_bottom_img)
	
	ret:setScale(min_scale)
	left_top_img:setScaleY(min_arc_scale)
	left_bottom_img:setScaleY(min_arc_scale)
	right_top_img:setScaleY(min_arc_scale)
	right_bottom_img:setScaleY(min_arc_scale)
	
	local function playOneTime()
		ret:setVisible(true)
		ret:setScale(min_scale)
		left_top_img:setScaleY(min_arc_scale)
		left_bottom_img:setScaleY(min_arc_scale)
		right_top_img:setScaleY(min_arc_scale)
		right_bottom_img:setScaleY(min_arc_scale)
		ret:runAction(cc.ScaleTo:create(active_time,max_scale))
		left_top_img:runAction(cc.ScaleTo:create(active_time,1.0,max_arc_scale))
		left_bottom_img:runAction(cc.ScaleTo:create(active_time,1.0,max_arc_scale))
		right_top_img:runAction(cc.ScaleTo:create(active_time,1.0,max_arc_scale))
		right_bottom_img:runAction(cc.ScaleTo:create(active_time,1.0,max_arc_scale))
	end
	
	if tp == 1 then
		--自动循环
		ret:setVisible(false)
		local function startAction()
			ret:runAction(cc.RepeatForever:create( cc.Sequence:create( cc.CallFunc:create(playOneTime), cc.DelayTime:create(active_time + 1.0), cc.Hide:create(), cc.DelayTime:create(30.0) ) ))
		end
		ret:runAction( cc.Sequence:create(cc.DelayTime:create(math.random(2,10)), cc.CallFunc:create(startAction)) )
	elseif tp == 2 then
		--手动一次一次的播放
		ret:setVisible(false)
		ret.lua_playRange = playOneTime
		ret.lua_hideRange = function ()
			ret:setVisible(false)
		end
	end
	
	return ret
end


--创建指引复活点动画
function create_area_guide(serverData, configData, originBigTileIndex)
	
	local effectNode = nil
	
	effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
				
	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_KuaFuJiaoZhanZhanDouQuYu/Effect_KuaFuJiaoZhanZhanDouQuYu.ExportJson", "Effect_KuaFuJiaoZhanZhanDouQuYu")
	effectNode:addChild(armature)
	animation:play("Animation1")
	
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(5.0), cc.RemoveSelf:create()))
	
	return effectNode
end


--创建指引箭头动画
function create_arrow(serverData, configData, originBigTileIndex)
	
	local effectNode = nil
	
	effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
				
	local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZhanCheZhiYingJianTou/Effect_ZhanCheZhiYingJianTou.ExportJson", "Effect_ZhanCheZhiYingJianTou")
	effectNode:addChild(armature)
	animation:play("Animation1")
	
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(5.0), cc.RemoveSelf:create()))
	
	return effectNode
end

--创建低级特效
function create_low(serverData, configData, originBigTileIndex)
	
	local effectNode = nil
	
	
	if serverData.player_id ~= 0 then
		--属于某一个玩家
		if serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_gold
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_food
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_wood
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_stone
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.world_iron
				then
			--资源占领旗帜
			if effectNode == nil then
				effectNode = cc.Node:create()
				effectNode:setContentSize(cc.size(1.0,1.0))
				effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
			end
			effectNode:addChild(_createResFlag(serverData, configData, originBigTileIndex))
		end
		if serverData.map_element_origin_id == HelperMD.m_MapOriginType.stronghold then
			--据点占领旗帜
			if effectNode == nil then
				effectNode = cc.Node:create()
				effectNode:setContentSize(cc.size(1.0,1.0))
				effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
			end
			effectNode:addChild(_createStrongholdFlag(serverData, configData, originBigTileIndex))
		end
		
		if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche 
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_yunti 
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_chuangnu 
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_gongchengchui 
		then
			--占领旗帜
			if effectNode == nil then
				effectNode = cc.Node:create()
				effectNode:setContentSize(cc.size(1.0,1.0))
				effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
			end
			effectNode:addChild(_createGuildWarHoldFlag(serverData, configData, originBigTileIndex))
		end
	end
	
	if serverData.status == HelperMD.m_MapBuildStatus.build then
		--建造中
		if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_tower
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_gold
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_food
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_wood
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_stone
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_iron
			or serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_cache
				then
			if effectNode == nil then
				effectNode = cc.Node:create()
				effectNode:setContentSize(cc.size(1.0,1.0))
				effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
			end
			local armature , animation = g_gameTools.LoadCocosAni("anime/anime_build/anime_build.ExportJson", "anime_build")
			effectNode:addChild(armature)
			animation:play("jianzhushengji")
			armature:setScale(tonumber(configData.build_zoom))
		end
	end
	
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.stronghold then
		--据点循环特效
		if effectNode == nil then
			effectNode = cc.Node:create()
			effectNode:setContentSize(cc.size(1.0,1.0))
			effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
		end
		local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_WuRenZhanLin/Effect_WuRenZhanLin.ExportJson", "Effect_WuRenZhanLin")
		effectNode:addChild(armature)
		animation:play("Animation1")
		armature:setScale(tonumber(configData.build_zoom))
	end
	
	return effectNode
end

--堡垒修理特效
function create_low_guild_fort_repair(serverData, configData, originBigTileIndex)
	local effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local scaleVar = tonumber(configData.build_zoom)
	local function update_effect(dt)
		if serverData.status == HelperMD.m_MapBuildStatus.normal
			and serverData.durability < serverData.max_durability 
			and isHaveQueueDoing(serverData, QueueHelperMD.QueueTypes.TYPE_GUILDBASE_REPAIR)
				then
			--修理中
			local repair_effect = effectNode:getChildByTag(c_tag_repair_effect)
			if repair_effect then
				repair_effect:setVisible(true)
			else
				local armature , animation = g_gameTools.LoadCocosAni("anime/anime_build/anime_build.ExportJson", "anime_build")
				effectNode:addChild(armature, 1, c_tag_repair_effect)
				animation:play("jianzhushengji")
				armature:setScale(scaleVar)
				repair_effect = armature
			end
		else
			local repair_effect = effectNode:getChildByTag(c_tag_repair_effect)
			if repair_effect then
				repair_effect:setVisible(false)
			end
		end
	end
	local schedulers = {}
	local function nodeEventHandler(eventType)
				if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 6 , false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
				end
		end
		effectNode:registerScriptHandler(nodeEventHandler)
	local function firstUpdate()
		update_effect(0.0166)
	end
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2, 10) * 0.2), cc.CallFunc:create(firstUpdate)))
	return effectNode
end

--城门着火
function create_mid_gate_fire(serverData, configData, originBigTileIndex)
	
	local percent = serverData.durability/serverData.max_durability*100
	if serverData.durability >= 0 and percent < 60 then
		local effectNode = cc.Node:create()
		effectNode:setContentSize(cc.size(1.0,1.0))
		effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
		local armature , animation = g_gameTools.LoadCocosAni("anime/TongYongChengNeiHuo/TongYongChengNeiHuo.ExportJson", "TongYongChengNeiHuo")
		effectNode:addChild(armature, 1, c_tag_fire_effect)
		animation:play("ChengChiHuo")
		return effectNode
	end
	return nil
end

--主城着火
function create_mid_player_home_fire(serverData, configData, originBigTileIndex)
	local effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local function update_effect(dt)
		local playerData = require "game.mapcitybattle.worldMapLayer_bigMap".getCurrentAreaDatas().Player[tostring(serverData.player_id)]
		if playerData and playerData.fire_end_time then
			local current_time = g_clock.getCurServerTime()
			local subTime = playerData.fire_end_time - current_time
			if subTime > 5 then
				local fire_effect = effectNode:getChildByTag(c_tag_fire_effect)
				if fire_effect then
					fire_effect:setVisible(true)
				else
					local armature , animation = g_gameTools.LoadCocosAni("anime/TongYongChengNeiHuo/TongYongChengNeiHuo.ExportJson", "TongYongChengNeiHuo")
					effectNode:addChild(armature, 1, c_tag_fire_effect)
					animation:play("ChengChiHuo")
					fire_effect = armature
				end
			else
				local fire_effect = effectNode:getChildByTag(c_tag_fire_effect)
				if fire_effect then
					fire_effect:setVisible(false)
				end
			end
		end
	end
	local schedulers = {}
	local function nodeEventHandler(eventType)
				if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 7 , false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
				end
		end
		effectNode:registerScriptHandler(nodeEventHandler)
	local function firstUpdate()
		update_effect(0.0166)
	end
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2, 10) * 0.2), cc.CallFunc:create(firstUpdate)))
	return effectNode
end

--主城保护罩
function create_mid_player_home_avoid(serverData, configData, originBigTileIndex)
	local effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local scaleVar = tonumber(configData.build_zoom)
	local function update_effect(dt)
		local playerData = require "game.mapcitybattle.worldMapLayer_bigMap".getCurrentAreaDatas().Player[tostring(serverData.player_id)]
		if playerData and playerData.avoid_battle_time and playerData.avoid_battle then
			local current_time = g_clock.getCurServerTime()
			local subTime = playerData.avoid_battle_time - current_time
			if playerData.avoid_battle == 1 or subTime > 2 then
				local avoid_effect = effectNode:getChildByTag(c_tag_avoid_effect)
				if avoid_effect then
					avoid_effect:setVisible(true)
				else
					local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuChengHuZhao/Effect_ZhuChengHuZhao.ExportJson", "Effect_ZhuChengHuZhao")
					effectNode:addChild(armature, 1, c_tag_avoid_effect)
					animation:play("Animation1")
					armature:setScale(scaleVar)
					avoid_effect = armature
				end
			else
				local avoid_effect = effectNode:getChildByTag(c_tag_avoid_effect)
				if avoid_effect then
					avoid_effect:setVisible(false)
				end
			end
		end
	end
	local schedulers = {}
	local function nodeEventHandler(eventType)
				if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 6 , false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
				end
		end
		effectNode:registerScriptHandler(nodeEventHandler)
	local function firstUpdate()
		update_effect(0.0166)
	end
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2, 10) * 0.2), cc.CallFunc:create(firstUpdate)))
	return effectNode
end

--主城和氏璧
function create_mid_player_home_hsb(serverData, configData, originBigTileIndex)
	local effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local scaleVar = tonumber(configData.build_zoom)
	local function update_effect(dt)
		local playerData = require "game.mapcitybattle.worldMapLayer_bigMap".getCurrentAreaDatas().Player[tostring(serverData.player_id)]
		if playerData then
			if playerData.hsb and playerData.hsb > 0 then
				local heshibi_effect = effectNode:getChildByTag(c_tag_heshibi_effect)
				if heshibi_effect then
					heshibi_effect:setVisible(true)
				else
					local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_WorldMapBuildYuXiSmoken/Effect_WorldMapBuildYuXiSmoken.ExportJson", "Effect_WorldMapBuildYuXiSmoken")
					effectNode:addChild(armature,1,c_tag_heshibi_effect)
					animation:play("Animation1")
					armature:setScale(scaleVar)
					heshibi_effect = armature
					heshibi_effect.lua_show_heshibi_count = 0
				end
				if heshibi_effect.lua_show_heshibi_count ~= playerData.hsb then
					heshibi_effect.lua_show_heshibi_count = playerData.hsb
					local iconBone = heshibi_effect:getBone("Layer2")
					if iconBone then
						local image_path = nil
						local lvTab = string.split(g_data.starting[59].data, ",")
						local count = (#lvTab) / 3
						for i = 1 , count , 1 do
							local index = (i - 1) * 3 + 1
							local min = lvTab[index]
							local max = lvTab[index + 1]
							local imgId = lvTab[index + 2]
							if tonumber(min) <= heshibi_effect.lua_show_heshibi_count and heshibi_effect.lua_show_heshibi_count <= tonumber(max) then
								image_path = g_data.sprite[tonumber(imgId)].path
								break
							end
						end
						if image_path then
							local node = cc.Node:create()
							node:setAnchorPoint(cc.p(0.5, 0.5))
							node:addChild(cc.Sprite:create(image_path))
							iconBone:addDisplay(node, 0)
						end
					end
				end
			else
				local heshibi_effect = effectNode:getChildByTag(c_tag_heshibi_effect)
				if heshibi_effect then
					heshibi_effect:setVisible(false)
				end
			end
		end
	end
	local schedulers = {}
	local function nodeEventHandler(eventType)
				if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 10 , false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
				end
		end
		effectNode:registerScriptHandler(nodeEventHandler)
	local function firstUpdate()
		update_effect(0.0166)
	end
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2, 10) * 0.2), cc.CallFunc:create(firstUpdate)))
	return effectNode
end

--主城皇城战job
function create_mid_player_home_job(serverData, configData, originBigTileIndex)
	local effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local scaleVar = tonumber(configData.build_zoom)
	local function update_effect(dt)
		local playerData = require "game.mapcitybattle.worldMapLayer_bigMap".getCurrentAreaDatas().Player[tostring(serverData.player_id)]
		if playerData then
			if playerData.job ~= 0 and playerData.hsb == 0 then
				local job_effect = effectNode:getChildByTag(c_tag_job_effect)
				if job_effect and job_effect.lua_job == playerData.job then
					job_effect:setVisible(true)
				else
					effectNode:removeChildByTag(c_tag_job_effect)
					local job_ani = c_job_anis[playerData.job]
					if job_ani then
						local armature , animation = g_gameTools.LoadCocosAni(job_ani.n1, job_ani.n2)
						effectNode:addChild(armature,1,c_tag_job_effect)
						animation:play(job_ani.n3)
						armature:setScale(scaleVar)
						job_effect = armature
						job_effect.lua_job = playerData.job
					end
				end
			else
				local job_effect = effectNode:getChildByTag(c_tag_job_effect)
				if job_effect then
					job_effect:setVisible(false)
				end
			end
		end
	end
	local schedulers = {}
	local function nodeEventHandler(eventType)
				if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 5 , false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
				end
		end
		effectNode:registerScriptHandler(nodeEventHandler)
	local function firstUpdate()
		update_effect(0.0166)
	end
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2, 10) * 0.2), cc.CallFunc:create(firstUpdate)))
	return effectNode
end

--营寨保护罩
function create_mid_camp_avoid(serverData, configData, originBigTileIndex)
	local effectNode = cc.Node:create()
	effectNode:setContentSize(cc.size(1.0,1.0))
	effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local scaleVar = tonumber(configData.build_zoom)
	local function update_effect(dt)
		if not g_kingInfo.isKingBattleStarted() then
			local avoid_effect = effectNode:getChildByTag(c_tag_king_avoid_effect)
			if avoid_effect then
				avoid_effect:setVisible(true)
			else
				local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_ZhuChengHuZhao/Effect_ZhuChengHuZhao.ExportJson", "Effect_ZhuChengHuZhao")
				effectNode:addChild(armature,1,c_tag_king_avoid_effect)
				animation:play("Animation1")
				armature:setScale(scaleVar)
			end
		else
			local avoid_effect = effectNode:getChildByTag(c_tag_king_avoid_effect)
			if avoid_effect then
				avoid_effect:setVisible(false)
			end
		end
	end
	local schedulers = {}
	local function nodeEventHandler(eventType)
				if eventType == "enter" then
			schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 7 , false)
		elseif eventType == "exit" then
			for k , v in ipairs(schedulers) do
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
			end
				end
		end
		effectNode:registerScriptHandler(nodeEventHandler)
	local function firstUpdate()
		update_effect(0.0166)
	end
	effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2, 10) * 0.2), cc.CallFunc:create(firstUpdate)))
	return effectNode
end

--创建顶级特效
function create_top(serverData, configData, originBigTileIndex)
	local effectNode = nil
	if serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_fort then
		if serverData.status ~= HelperMD.m_MapBuildStatus.build then
			effectNode = cc.Node:create()
			effectNode:setContentSize(cc.size(1.0,1.0))
			effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
			effectNode:addChild(create_fort_range(serverData, configData, 1))
		end
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_tower then
		effectNode = cc.Node:create()
		effectNode:setContentSize(cc.size(1.0,1.0))
		effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
		local range_node = create_fort_range(serverData, configData, 2)
		effectNode.lua_playRange = range_node.lua_playRange	--箭塔特有
		effectNode.lua_hideRange = range_node.lua_hideRange	--箭塔特有
		effectNode:addChild(range_node)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.guild_war_toushiche then
		effectNode = cc.Node:create()
		effectNode:setContentSize(cc.size(1.0,1.0))
		effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
		local range_node = create_fort_range(serverData, configData, 2)
		effectNode.lua_playRange = range_node.lua_playRange	--投石车特有
		effectNode.lua_hideRange = range_node.lua_hideRange	--投石车特有
		effectNode:addChild(range_node)
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.player_home then
		if serverData.player_id == g_cityBattlePlayerData.GetData().player_id then
			--自己主城
			effectNode = cc.Node:create()
			effectNode:setContentSize(cc.size(1.0,1.0))
			effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
			local function update_effect(dt)
				local playerData = g_cityBattlePlayerData.GetData()
				if playerData.avoid_battle_time then
					local subTime = playerData.avoid_battle_time - g_clock.getCurServerTime()
					if subTime > 2 then
						--主城保护罩时间面板
						local avoid_time = effectNode:getChildByTag(c_tag_avoid_time)
						if avoid_time then
							avoid_time:setVisible(true)
							avoid_time:getChildByName("Text_1_0"):setString(g_gameTools.convertSecondToString(subTime))
						else
							avoid_time = cc.CSLoader:createNode("baohutime.csb")
							avoid_time:setPosition(cc.p(70.0,75.0))
							avoid_time:setRotation3D( cc.vec3(HelperMD.m_Angle * -1, 0.0, 0.0) )
							avoid_time:getChildByName("Text_1"):setString(g_tr("worldmap_avoid_time"))
							avoid_time:getChildByName("Text_1_0"):setString(g_gameTools.convertSecondToString(subTime))
							effectNode:addChild(avoid_time, 1, c_tag_avoid_time)
						end
					else
						local avoid_time = effectNode:getChildByTag(c_tag_avoid_time)
						if avoid_time then
							avoid_time:setVisible(false)
						end
					end
				end
			end
			local schedulers = {}
			local function nodeEventHandler(eventType)
				if eventType == "enter" then
					schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 0.5 , false)
				elseif eventType == "exit" then
					for k , v in ipairs(schedulers) do
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
					end
				end
			end
			effectNode:registerScriptHandler(nodeEventHandler)
			local function firstUpdate()
				update_effect(0.0166)
			end
			effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(5, 10) * 0.1), cc.CallFunc:create(firstUpdate)))
		end
	elseif serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_middle 
		or serverData.map_element_origin_id == HelperMD.m_MapOriginType.camp_low 
			then
		--营寨保护罩时间面板
		effectNode = cc.Node:create()
		effectNode:setContentSize(cc.size(1.0,1.0))
		effectNode:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
		local function update_effect(dt)
			local t = g_kingInfo.kingBattleSoonTime()
			if t > 0 then
				local avoid_time = effectNode:getChildByTag(c_tag_camp_avoid_time)
				if avoid_time then
					avoid_time:setVisible(true)
					avoid_time:getChildByName("Text_1_0"):setString(g_gameTools.convertSecondToString(t))
				else
					avoid_time = cc.CSLoader:createNode("baohutime.csb")
					avoid_time:setPosition(cc.p(70.0,75.0))
					avoid_time:setRotation3D( cc.vec3(HelperMD.m_Angle * -1, 0.0, 0.0) )
					avoid_time:getChildByName("Text_1"):setString(g_tr("worldmap_camp_avoid_time"))
					avoid_time:getChildByName("Text_1_0"):setString(g_gameTools.convertSecondToString(t))
					effectNode:addChild(avoid_time, 1, c_tag_camp_avoid_time)
				end
			else
				local avoid_time = effectNode:getChildByTag(c_tag_camp_avoid_time)
				if avoid_time then
					avoid_time:setVisible(false)
				end
			end
		end
		local schedulers = {}
		local function nodeEventHandler(eventType)
			if eventType == "enter" then
				schedulers[(#schedulers) + 1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update_effect, 0.5 , false)
			elseif eventType == "exit" then
				for k , v in ipairs(schedulers) do
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
				end
			end
		end
		effectNode:registerScriptHandler(nodeEventHandler)
		local function firstUpdate()
			update_effect(0.0166)
		end
		effectNode:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(5, 10) * 0.1), cc.CallFunc:create(firstUpdate)))
	end
	
	return effectNode
end

function create_gongchengchui(serverData, configData, originBigTileIndex)
	local ret = cc.Node:create()
	ret:setContentSize(cc.size(1.0,1.0))
	ret:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local armature , animation = nil,nil
	
	
	local spBuildData = g_cityBattleMapSpBuildData.getLocalSpBuildDataBy_xy(serverData.x,serverData.y)
	
	local function updateLoadingBar()

	end
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
			
		elseif ccs.MovementEventType.complete == eventType then
			if spBuildData.build_display.attackFunc then
				spBuildData.build_display.attackFunc()
			end
		elseif ccs.MovementEventType.loopComplete == eventType then
			
		end
	end
	
	local scaleX = 1
	local aninaName = "chongche"
	if spBuildData then
		local mapConfigData = g_data.map_element[spBuildData.city_battle_map_element_id]
		if mapConfigData then
			if mapConfigData.anim_reversal == 2 then --翻转
				scaleX = -1
			elseif mapConfigData.anim_reversal == 3 then --新名称
				aninaName = mapConfigData.anim_reversal_name
			elseif mapConfigData.anim_reversal == 4 then --新名称 翻转
				aninaName = mapConfigData.anim_reversal_name
				scaleX = -1
			end
		end
	end
						
	armature , animation = g_gameTools.LoadCocosAni(string.format("anime/%s/%s.ExportJson",aninaName,aninaName), aninaName, onMovementEventCallFunc)
--	local size = self:getContentSize()
--	armature:setPosition(cc.p(size.width / 2, size.height / 2))
	ret:addChild(armature)
	armature:setScaleX(scaleX)
	
--	local seq = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(updateLoadingBar))
--	local action = cc.RepeatForever:create(seq)
--	ret:runAction(action)
	
	local function nodeEventHandler(eventType)
		if eventType == "enter" then
			g_gameCommon.addEventHandler(g_Consts.CustomEvent.CityBattleMapEvent, function(_,data)
				print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~msg")
				dump(data)
				if data.Data.type == "hammerAttackDoor" then
					if spBuildData and spBuildData.build_display then
						local targetX = tonumber(data.Data.to_x)
						local targetY = tonumber(data.Data.to_y)
						local targetSpBuildData = g_cityBattleMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
						local mapConfigData = nil
						if targetSpBuildData then
							print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",targetSpBuildData.city_battle_map_element_id)
							mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
						end
						local num = data.Data.reduce or 0
						
						spBuildData.build_display.attackFunc = function()
							require "game.mapcitybattle.worldMapLayer_bigMap".play_reduce_effect(num,mapConfigData,cc.p(targetX,targetY))
						end
						local armature = spBuildData.build_display.armature 
						local animation = spBuildData.build_display.animation 
						if animation then
							animation:play("gongji")
							RequestTimeMD.CanNotRequestSecondsWithin(c_build_attack_stay, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
						end
					end
				end
				
      end,ret)
		
			if spBuildData then
				if spBuildData.build_display == nil then
					spBuildData.build_display = {}
				end
				spBuildData.build_display.armature = armature 
				spBuildData.build_display.animation = animation
			end
		elseif eventType == "exit" then
			g_gameCommon.removeEventHandler(g_Consts.CustomEvent.CityBattleMapEvent,ret)
			if spBuildData then
				spBuildData.build_display.armature = nil 
				spBuildData.build_display.animation = nil
			end
			
		end
	end
	ret:registerScriptHandler(nodeEventHandler)
	
	return ret
end

function create_chuangnu(serverData, configData, originBigTileIndex)
	local ret = cc.Node:create()
	ret:setContentSize(cc.size(1.0,1.0))
	ret:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local armature , animation = nil,nil
	
	
	local spBuildData = g_cityBattleMapSpBuildData.getLocalSpBuildDataBy_xy(serverData.x,serverData.y)
	
	local function updateLoadingBar()

	end
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
			
		elseif ccs.MovementEventType.complete == eventType then
			if spBuildData.build_display.attackFunc then
				spBuildData.build_display.attackFunc()
			end
		elseif ccs.MovementEventType.loopComplete == eventType then
			
		end
	end
	
	local scaleX = 1
	local aninaName = "nuche"
	if spBuildData then
		local mapConfigData = g_data.map_element[spBuildData.city_battle_map_element_id]
		if mapConfigData then
			if mapConfigData.anim_reversal == 2 then --翻转
				scaleX = -1
			elseif mapConfigData.anim_reversal == 3 then --新名称
				aninaName = mapConfigData.anim_reversal_name
			elseif mapConfigData.anim_reversal == 4 then --新名称 翻转
				aninaName = mapConfigData.anim_reversal_name
				scaleX = -1
			end
		end
	end
						
	armature , animation = g_gameTools.LoadCocosAni(string.format("anime/%s/%s.ExportJson",aninaName,aninaName), aninaName, onMovementEventCallFunc)
--	local size = self:getContentSize()
--	armature:setPosition(cc.p(size.width / 2, size.height / 2))
	ret:addChild(armature)
	armature:setScaleX(scaleX)
	
--	local seq = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(updateLoadingBar))
--	local action = cc.RepeatForever:create(seq)
--	ret:runAction(action)
	
	local function nodeEventHandler(eventType)
		if eventType == "enter" then
			g_gameCommon.addEventHandler(g_Consts.CustomEvent.CityBattleMapEvent, function(_,data)
				if data.Data.type == "crossbowAttackHammer" or data.Data.type == "crossbowAttackLadder" then
					if spBuildData and spBuildData.build_display then
						local fromX = tonumber(data.Data.from_x)
						local fromY = tonumber(data.Data.from_y)
						
						if spBuildData.x == fromX and spBuildData.y == fromY then
							local targetX = tonumber(data.Data.to_x)
							local targetY = tonumber(data.Data.to_y)
							local targetSpBuildData = g_cityBattleMapSpBuildData.getLocalSpBuildDataBy_xy(targetX,targetY)
							local mapConfigData = nil
							if targetSpBuildData then
								mapConfigData = g_data.map_element[targetSpBuildData.city_battle_map_element_id]
							end
							
							local num = data.Data.reduce or 0
							
							spBuildData.build_display.attackFunc = function()
								require "game.mapcitybattle.worldMapLayer_bigMap".play_reduce_effect(num,mapConfigData,cc.p(targetX,targetY))
							end
							local armature = spBuildData.build_display.armature 
							local animation = spBuildData.build_display.animation 
							if animation then
								animation:play("gongji")
								RequestTimeMD.CanNotRequestSecondsWithin(c_build_attack_stay, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
							end
						end
					end
				end

      end,ret)
		
			if spBuildData then
				if spBuildData.build_display == nil then
					spBuildData.build_display = {}
				end
				spBuildData.build_display.armature = armature 
				spBuildData.build_display.animation = animation
			end
		elseif eventType == "exit" then
			g_gameCommon.removeEventHandler(g_Consts.CustomEvent.CityBattleMapEvent,ret)
			if spBuildData then
				spBuildData.build_display.armature = nil 
				spBuildData.build_display.animation = nil
			end
			
		end
	end
	ret:registerScriptHandler(nodeEventHandler)
	
	return ret
end

function create_yunti(serverData, configData, originBigTileIndex)
	local ret = cc.Node:create()
	ret:setContentSize(cc.size(1.0,1.0))
	ret:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	
	local spBuildData = g_cityBattleMapSpBuildData.getLocalSpBuildDataBy_xy(serverData.x,serverData.y)
	
	local armature , animation = nil,nil

	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
		elseif ccs.MovementEventType.complete == eventType then
			
		elseif ccs.MovementEventType.loopComplete == eventType then
			
		end
	end

	local scaleX = 1
	local aninaName = "yunche"
	if spBuildData then
		local mapConfigData = g_data.map_element[spBuildData.city_battle_map_element_id]
		if mapConfigData then
			if mapConfigData.anim_reversal == 2 then --翻转
				scaleX = -1
			elseif mapConfigData.anim_reversal == 3 then --新名称
				aninaName = mapConfigData.anim_reversal_name
			elseif mapConfigData.anim_reversal == 4 then --新名称 翻转
				aninaName = mapConfigData.anim_reversal_name
				scaleX = -1
			end
		end
	end
						
	armature , animation = g_gameTools.LoadCocosAni(string.format("anime/%s/%s.ExportJson",aninaName,aninaName), aninaName, onMovementEventCallFunc)
--	local size = self:getContentSize()
--	armature:setPosition(cc.p(size.width / 2, size.height / 2))
	ret:addChild(armature)
	armature:setScaleX(scaleX)
	
	local function nodeEventHandler(eventType)
		if eventType == "enter" then
			g_gameCommon.addEventHandler(g_Consts.CustomEvent.CityBattleMapEvent, function(_,data)
				if data.Data.type == "ladderDone" then
					local fromX = tonumber(data.Data.x)
					local fromY = tonumber(data.Data.y)
					if spBuildData.x == fromX and spBuildData.y == fromY then
						if animation then
							animation:play("gongji")
							RequestTimeMD.CanNotRequestSecondsWithin(c_build_attack_stay, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
						end
					end
				end
      end,ret)
		elseif eventType == "exit" then
			g_gameCommon.removeEventHandler(g_Consts.CustomEvent.CityBattleMapEvent,ret)
		end
	end
	ret:registerScriptHandler(nodeEventHandler)
	
	local maxValue = tonumber(g_data.country_basic_setting[42].data)
  if serverData.resource >= maxValue then
  local r_animtion = armature:getAnimation()
  	r_animtion:play("gongji")
  	r_animtion:gotoAndPlay(34)
  end
	
	return ret
end

function create_toushiche(serverData, configData, originBigTileIndex)
	local ret = cc.Node:create()
	ret:setContentSize(cc.size(1.0,1.0))
	ret:setPosition(HelperMD.bigTileIndex_2_buildCenterPosition(originBigTileIndex, configData))
	local armature , animation = nil,nil
	
	
	local spBuildData = g_cityBattleMapSpBuildData.getLocalSpBuildDataBy_xy(serverData.x,serverData.y)
	
	local function updateLoadingBar()

	end
	
	local function onMovementEventCallFunc(armature , eventType , name)
		if ccs.MovementEventType.start == eventType then
			
		elseif ccs.MovementEventType.complete == eventType then
			if spBuildData.build_display.attackFunc then
				spBuildData.build_display.attackFunc()
			end
		elseif ccs.MovementEventType.loopComplete == eventType then
			
		end
	end
	
	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
		
		if spBuildData.build_num == 1 or spBuildData.build_num == 2 then
			armature , animation = g_gameTools.LoadCocosAni("anime/toushicheB/toushicheB.ExportJson", "toushicheB", onMovementEventCallFunc)
		else
			armature , animation = g_gameTools.LoadCocosAni("anime/toushiche/toushiche.ExportJson", "toushiche", onMovementEventCallFunc)
		end
		
		
	--	local size = self:getContentSize()
	--	armature:setPosition(cc.p(size.width / 2, size.height / 2))
		ret:addChild(armature)
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
		local scaleX = 1
		local aninaName = "toushiche"
		if spBuildData then
			local mapConfigData = g_data.map_element[spBuildData.city_battle_map_element_id]
			if mapConfigData then
				if mapConfigData.anim_reversal == 2 then --翻转
					scaleX = -1
				elseif mapConfigData.anim_reversal == 3 then --新名称
					aninaName = mapConfigData.anim_reversal_name
				elseif mapConfigData.anim_reversal == 4 then --新名称 翻转
					aninaName = mapConfigData.anim_reversal_name
					scaleX = -1
				end
			end
		end
							
		armature , animation = g_gameTools.LoadCocosAni(string.format("anime/%s/%s.ExportJson",aninaName,aninaName), aninaName, onMovementEventCallFunc)
	--	local size = self:getContentSize()
	--	armature:setPosition(cc.p(size.width / 2, size.height / 2))
		ret:addChild(armature)
		armature:setScaleX(scaleX)
	
	end
	
	
	
	
--	local seq = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(updateLoadingBar))
--	local action = cc.RepeatForever:create(seq)
--	ret:runAction(action)
	
	local function nodeEventHandler(eventType)
		if eventType == "enter" then
			g_gameCommon.addEventHandler(g_Consts.CustomEvent.CityBattleMapEvent, function(_,data)
				if data.Data.type == "catapultAttack" or data.Data.type == "catapultCounterAttack" then
					if spBuildData and spBuildData.build_display then
						local fromX = tonumber(data.Data.from_x)
						local fromY = tonumber(data.Data.from_y)
						
						if spBuildData.x == fromX and spBuildData.y == fromY then
							local targetX = tonumber(data.Data.to_x)
							local targetY = tonumber(data.Data.to_y)
	
							local mapConfigData = g_data.map_element[1501] --投石车目标固定是玩家
							
							local num = data.Data.reduce or 0
							
							spBuildData.build_display.attackFunc = function()
								require "game.mapcitybattle.worldMapLayer_bigMap".play_reduce_effect(num,mapConfigData,cc.p(targetX,targetY),configData)
							end
							local armature = spBuildData.build_display.armature 
							local animation = spBuildData.build_display.animation 
							if animation then
								animation:play("gongji")
								RequestTimeMD.CanNotRequestSecondsWithin(c_build_attack_stay, RequestTimeMD.m_Event_not.aboutMyPlayAttack)
							end
						end
					end
				end

      end,ret)
		
			if spBuildData then
				if spBuildData.build_display == nil then
					spBuildData.build_display = {}
				end
				spBuildData.build_display.armature = armature 
				spBuildData.build_display.animation = animation
			end
		elseif eventType == "exit" then
			g_gameCommon.removeEventHandler(g_Consts.CustomEvent.CityBattleMapEvent,ret)
			if spBuildData then
				spBuildData.build_display.armature = nil 
				spBuildData.build_display.animation = nil
			end
			
		end
	end
	ret:registerScriptHandler(nodeEventHandler)
	
	return ret
end


return worldMapLayer_buildEffect