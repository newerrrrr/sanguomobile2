local worldMapLayer_teamRole = {}
setmetatable(worldMapLayer_teamRole,{__index = _G})
setfenv(1,worldMapLayer_teamRole)

local HelperMD = require "game.mapcitybattle.worldMapLayer_helper"

local c_move_speed = 120

local c_max_back_operate_basic = 80

local c_max_back_distance_scale = 0.55


--播放
local function _play(self, aniName, flippedX, startCallback)
	for k , v in pairs(self.lua_animation_table) do
		v:setVisible(false)
		v:stopAllActions()
	end
	local keyName = "lua_"..aniName
	local spr = self.lua_animation_table[keyName]
	if spr == nil then
		spr = cc.Sprite:createWithSpriteFrameName(self.lua_preName..aniName.."_1.png")
		self:addChild(spr, 1)
		self.lua_animation_table[keyName] = spr
	end
	spr:setVisible(true)
	spr:setFlippedX(flippedX)
	if startCallback then
		spr:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.CallFunc:create(function() startCallback() end), g_gameTools.LoadFPSAni(self.lua_preName..aniName.."_")) ))
	else	
		spr:runAction(cc.RepeatForever:create( g_gameTools.LoadFPSAni(self.lua_preName..aniName.."_")))
	end
end


--播放移动 传入起始点与目标点之间的距离向量 
local function _play_run(self, directionVector, startCallback)
	local angle = cToolsForLua:calc2VecAngle(1, 0, directionVector.x, directionVector.y)
	angle = ((angle < 0) and (360 + angle) or (angle))
	angle = math.floor(angle + 22.5)
	angle = angle % 360
	local direction = math.floor((angle) / 45)
	if direction == 0 then
		_play(self, "run_Ce", false, startCallback)
	elseif direction == 1 then
		_play(self, "run_Bei45", false, startCallback)
	elseif direction == 2 then
		_play(self, "run_Bei", false, startCallback)
	elseif direction == 3 then
		_play(self, "run_Bei45", true, startCallback)
	elseif direction == 4 then
		_play(self, "run_Ce", true, startCallback)
	elseif direction == 5 then
		_play(self, "run_Zheng45", true, startCallback)
	elseif direction == 6 then
		_play(self, "run_Zheng", false, startCallback)
	elseif direction == 7 then
		_play(self, "run_Zheng45", false, startCallback)
	end
	return direction
end


--播放攻击 传入攻击方向向量
local function _play_attack(self, directionVector, startCallback)
	local angle = cToolsForLua:calc2VecAngle(1, 0, directionVector.x, directionVector.y)
	angle = ((angle < 0) and (360 + angle) or (angle))
	angle = math.floor(angle + 22.5)
	angle = angle % 360
	local direction = math.floor((angle) / 45)
	if direction == 0 then
		_play(self, "atk_Ce", false, startCallback)
	elseif direction == 1 then
		_play(self, "atk_Bei45", false, startCallback)
	elseif direction == 2 then
		_play(self, "atk_Bei", false, startCallback)
	elseif direction == 3 then
		_play(self, "atk_Bei45", true, startCallback)
	elseif direction == 4 then
		_play(self, "atk_Ce", true, startCallback)
	elseif direction == 5 then
		_play(self, "atk_Zheng45", true, startCallback)
	elseif direction == 6 then
		_play(self, "atk_Zheng", false, startCallback)
	elseif direction == 7 then
		_play(self, "atk_Zheng45", false, startCallback)
	end
	return direction
end


--计算头像位置
local function _operate_general_place(direction, place_type)
	local angle = 0
	local position = cc.p(0, 0)
	if direction == 0 then
		if place_type == 0 then
			position.x = -20.0
			position.y = -5.0
			angle = -115.0
		elseif place_type == 1 then
			position.x = -20.0
			position.y = 5.0
			angle = -115.0
		end
	elseif direction == 1 then
		if place_type == 0 then
			position.x = 0.0
			position.y = -10.0
			angle = -115.0
		elseif place_type == 1 then
			position.x = 0.0
			position.y = 10.0
			angle = -115.0
		end
	elseif direction == 2 then
		if place_type == 0 then
			position.x = 15.0
			position.y = -20.0
			angle = -115.0
		elseif place_type == 1 then
			position.x = -15.0
			position.y = -20.0
			angle = -115.0
		end
	elseif direction == 3 then
		if place_type == 0 then
			position.x = 0.0
			position.y = 10.0
			angle = -65.0
		elseif place_type == 1 then
			position.x = 0.0
			position.y = -10.0
			angle = -65.0
		end
	elseif direction == 4 then
		if place_type == 0 then
			position.x = 20.0
			position.y = 5.0
			angle = -65.0
		elseif place_type == 1 then
			position.x = 20.0
			position.y = -5.0
			angle = -65.0
		end
	elseif direction == 5 then
		if place_type == 0 then
			position.x = 0.0
			position.y = 10.0
			angle = -65.0
		elseif place_type == 1 then
			position.x = 0.0
			position.y = -10.0
			angle = -65.0
		end
	elseif direction == 6 then
		if place_type == 0 then
			position.x = -15.0
			position.y = -20.0
			angle = -115.0
		elseif place_type == 1 then
			position.x = 15.0
			position.y = -20.0
			angle = -115.0
		end
	elseif direction == 7 then
		if place_type == 0 then
			position.x = 0.0
			position.y = -10.0
			angle = -115.0
		elseif place_type == 1 then
			position.x = 0.0
			position.y = 10.0
			angle = -115.0
		end
	end
	
	return angle , position
end


--创建基础,只有移动动画
local function create_role_basic(preName)
	local ret = cc.Node:create()
	ret:ignoreAnchorPointForPosition(false)
	ret:setAnchorPoint(cc.p(0.5,0.5))
	ret:setContentSize(cc.size(1,1))
	
	ret.lua_preName = preName
	ret.lua_animation_table = {}
	
	--播放行走
	ret.lua_play_run = _play_run
	
	return ret
end


--创建会攻击的角色
local function create_role_canAttack(preName, atkDistance, atkRandVar, attackStartCallback_in, general_original_id, place_type)
	local ret = create_role_basic(preName)
	
	if general_original_id then
		for k , v in pairs(g_data.general) do
			if v.general_original_id == general_original_id then
				if v.general_quality == g_GeneralMode.godQuality then
					--神武将
					armature , animation = g_gameTools.LoadCocosAni(
						"anime/Effect_ShenWuJianBuDuiBuff/Effect_ShenWuJianBuDuiBuff.ExportJson"
						, "Effect_ShenWuJianBuDuiBuff"
						, nil
						, nil
						)
					ret:addChild(armature, -1)
					animation:play("Animation1", -1, 1)
				end
				if place_type then
					ret.lua_place_type = place_type	--右队 (队伍编号123456 , %2==0)	--左队 (队伍编号123456 , %2~=0)
					local general_line = cc.Sprite:createWithSpriteFrameName("worldmap_image_head_line.png")
					general_line:setAnchorPoint(cc.p(0.0, 0.5))
					general_line:setCascadeOpacityEnabled(true)
					ret:addChild(general_line, 2)
					ret.lua_general_line = general_line
					
					local line_size = general_line:getContentSize()
					
					local general_image = cc.Sprite:create(g_data.sprite[v.general_icon_min].path)
					general_image:setAnchorPoint(cc.p(0.5, 0.0))
					general_image:setPosition(cc.p(line_size.width - 10, line_size.height * 0.5))
					general_line:addChild(general_image)
					ret.lua_general_image = general_image
				end
				break
			end
		end
	end


	--重写播放移动
	local origin_play_run = ret.lua_play_run
	ret.lua_play_run = function (self, directionVector, startCallback)
		local direction = origin_play_run(self, directionVector, startCallback)
		if self.lua_place_type and self.lua_general_line and self.lua_general_image then
			local angle , position = _operate_general_place(direction, self.lua_place_type)
			self.lua_general_line:setPosition(position)
			self.lua_general_line:setRotation(angle)
			self.lua_general_image:setRotation3D(cc.vec3(HelperMD.m_Angle * -1.0, 0.0, angle * -1.0))
		end
	end
	
	
	--播放原地攻击
	ret.lua_play_attack_origin = function (self, directionVector, targetBuildServerData)
		local attackStartCallback = nil
		if attackStartCallback_in then
			attackStartCallback = function()
				attackStartCallback_in(targetBuildServerData)
			end
		end
		_play_attack(self, directionVector, attackStartCallback)
		if self.lua_general_line then
			self.lua_general_line:setVisible(false)
		end
	end
	
	
	--播放移动攻击
	ret.lua_play_attack_move = function (self, targetPosition, targetBuildServerData, place_few, basic_angle)
		local attackStartCallback = nil
		if attackStartCallback_in then
			attackStartCallback = function()
				attackStartCallback_in(targetBuildServerData)
			end
		end
		
		local place_angle = basic_angle
		if place_few > 1 then
			place_angle = ( basic_angle + math.ceil((place_few - 1) / 2 - 0.00001) * (((place_few - 1) % 2 == 0) and 60.0 or -60.0) )
		end
		
		local currentPosition = cc.p(ret:getPositionX(), ret:getPositionY())
		
		local new_distance = atkDistance + math.random(atkRandVar * -1, atkRandVar)
		
		local new_targetPosition = cc.p(targetPosition.x + math.cos(place_angle * 0.01745329252) * new_distance ,
			targetPosition.y + math.sin(place_angle * 0.01745329252) * new_distance)
		
		local new_move_vector = cc.p(new_targetPosition.x - currentPosition.x, new_targetPosition.y - currentPosition.y)
		
		if math.sqrt(new_move_vector.x * new_move_vector.x + new_move_vector.y * new_move_vector.y) < 10.0 then
			_play_attack(self, cc.p(targetPosition.x - currentPosition.x, targetPosition.y - currentPosition.y), attackStartCallback)
			if self.lua_general_line then
				self.lua_general_line:setVisible(false)
			end
		else
			local function onPlayAttack()
				_play_attack(self, cc.p(targetPosition.x - new_targetPosition.x, targetPosition.y - new_targetPosition.y), attackStartCallback)
				if self.lua_general_line then
					self.lua_general_line:setVisible(false)
				end
			end
			if self.lua_general_line then
				self.lua_general_line:setVisible(false)
			end
			self:lua_play_run(new_move_vector)
			self:runAction(cc.Sequence:create(cc.MoveTo:create(math.min(1.618, cc.pGetLength(new_move_vector) / c_move_speed), new_targetPosition), cc.CallFunc:create(onPlayAttack)))
		end
	end


	return ret
end


--创建侦查马
function create_Horse()
	return create_role_basic("battle_spy_")
end


--创建资源车
function create_ResourceCar()
	local ret = create_role_canAttack("battle_carriage_", 55, 10, nil, nil, nil)
	--ret.lua_AttackType = "near"
	return ret
end


--创建步兵
function create_Infantry(general_original_id, place_type)
	local ret = create_role_canAttack("battle_infantry_", 110, 10, nil, general_original_id, place_type)
	ret.lua_AttackType = "near"
	return ret
end


--创建弓兵
function create_Arrow(general_original_id, place_type)
	local ret = create_role_canAttack("battle_arrow_", 175, 10, nil, general_original_id, place_type)
	ret.lua_AttackType = "far"
	return ret
end


--创建骑兵
function create_Cavalry(general_original_id, place_type)
	local ret = create_role_canAttack("battle_cavalry_", 110, 10, nil, general_original_id, place_type)
	ret.lua_AttackType = "near"
	return ret
end


--创建车兵
function create_Throw(general_original_id, place_type)
	local function onAttackStart(targetBuildServerData)
		local position = HelperMD.buildServerData_2_buildCenterPosition(targetBuildServerData)
		position.x = position.x + math.random(-50, 50)
		position.y = position.y + math.random(-25, 30)
		local sp = cc.Sprite:createWithSpriteFrameName("battle_throw_atk_stone_1.png")
		sp:setPosition(cc.p(position.x, position.y + 100))
		sp:setOpacity(0)
		sp:runAction(cc.Sequence:create( cc.DelayTime:create(0.95), cc.Spawn:create(cc.MoveTo:create(0.3,position),cc.FadeTo:create(0.3,255)), g_gameTools.LoadFPSAni("battle_throw_atk_stone_"), cc.RemoveSelf:create() ))
		require("game.mapcitybattle.worldMapLayer_bigMap").addAutoEffect(sp, HelperMD.bigTileIndex_2_tileZOrder(cc.p(targetBuildServerData.x,targetBuildServerData.y)))
	end
	local ret = create_role_canAttack("battle_throw_", 200, 20, onAttackStart, general_original_id, place_type)
	ret.lua_AttackType = "far"
	return ret
end


--创建资源车前面的 枪兵
function create_Spear()
	local ret = create_role_canAttack("battle_spear_", 30, 5, nil, nil, nil)
	--ret.lua_AttackType = "near"
	return ret
end


--创建国王战王城发出的NPC
function create_KingCityOutNPC()
	local ret = create_role_canAttack("battle_kingdom_", 30, 5, nil, nil, nil)
	--ret.lua_AttackType = "near"
	return ret
end


--创建黄巾起义的NPC
function create_HJNPC()
	local ret = create_role_canAttack("battle_huangjin_", 30, 5, nil, nil, nil)
	--ret.lua_AttackType = "near"
	return ret
end


--创建城战的部队
function create_CityBattle()
	local ret = create_role_canAttack("battle_all_", 30, 5, nil, nil, nil)
	--ret.lua_AttackType = "near"
	return ret
end


return worldMapLayer_teamRole