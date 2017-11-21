local worldMapLayer_buildDisplay = {}
setmetatable(worldMapLayer_buildDisplay,{__index = _G})
setfenv(1,worldMapLayer_buildDisplay)

local HelperMD = require "game.mapcitybattle.worldMapLayer_helper"

m_DisplayType = {
	static = 1,
	dynamic = 2,
}

m_BackType = {
	standby = 1,
	death = 2,
}


local c_tag_playStandby = 88447356
local c_tag_playAttack = 88447357
local c_tag_playDeath = 88447358

local c_tag_playAttack_effect = 88447359



function create_static(index, configData, serverData)
	
	local image = nil
	
	if configData.origin_id == HelperMD.m_MapOriginType.guild_fort 
		and serverData.status == HelperMD.m_MapBuildStatus.normal
		and serverData.durability < serverData.max_durability
		then
		--破损状态的联盟堡垒
		image = cc.Sprite:createWithSpriteFrameName(g_data.sprite[configData.alliance_death[index]].path)
	elseif configData.origin_id == HelperMD.m_MapOriginType.player_home then--联盟战玩家显示
		 if serverData.camp_id == g_cityBattlePlayerData.GetData().camp_id then
		 	image = cc.Sprite:createWithSpriteFrameName(g_data.sprite[configData.img_self[index]].path)
		 else
		 	image = cc.Sprite:createWithSpriteFrameName(g_data.sprite[configData.img_enemy[index]].path)
		 end
	else
		image = cc.Sprite:createWithSpriteFrameName(g_data.sprite[configData.img[index]].path)
	end
	
	image.lua_displayType = m_DisplayType.static
	
	return image
end



function create_dynamic(configData, serverData)
	
	local standbyPrefix = g_data.sprite[configData.img[1]].path
	local attackPrefix = g_data.sprite[configData.img_atk].path
	local deathPrefix = g_data.sprite[configData.img_death].path
	
	local image = cc.Sprite:createWithSpriteFrameName(standbyPrefix.."1.png")
	
	image.lua_displayType = m_DisplayType.dynamic
	
	function image:lua_playStandby()
		self:stopActionByTag(c_tag_playAttack)
		self:stopActionByTag(c_tag_playDeath)
		local action = cc.RepeatForever:create(g_gameTools.LoadFPSAni(standbyPrefix))
		action:setTag(c_tag_playStandby)
		self:runAction(action)
	end
	
	function image:lua_playAttack(backType)
		self:stopActionByTag(c_tag_playStandby)
		self:stopActionByTag(c_tag_playDeath)
		local count = configData.anim_time and configData.anim_time or 2
		local function onAttackEnd()
			local bt = backType and backType or m_BackType.standby
			if bt == m_BackType.standby then
				self:lua_playStandby()
			elseif bt == m_BackType.death then
				self:lua_playDeath()
			else
				self:lua_playStandby()
			end
		end
		local action = cc.Sequence:create(cc.Repeat:create(g_gameTools.LoadFPSAni(attackPrefix),count), cc.CallFunc:create(onAttackEnd))
		action:setTag(c_tag_playAttack)
		self:runAction(action)
	end
	
	function image:lua_playDeath()
		self:stopActionByTag(c_tag_playStandby)
		self:stopActionByTag(c_tag_playAttack)
		local action = g_gameTools.LoadFPSAni(deathPrefix, nil, false)
		action:setTag(c_tag_playDeath)
		self:runAction(action)
	end
	
	image:lua_playStandby()
	
	return image
end



function create_smallMonster(configData, serverData)
	local ret = create_dynamic(configData, serverData)
	return ret
end



function create_bossMonster(configData, serverData)
	local ret = create_dynamic(configData, serverData)
	
	function ret:lua_playAttackEffect(vec_back_attack)
		local count = configData.anim_time and configData.anim_time or 2
		if count > 0 then
			self:removeChildByTag(c_tag_playAttack_effect)
			local function onMovementEventCallFunc(armature , eventType , name)
				if ccs.MovementEventType.start == eventType then
				elseif ccs.MovementEventType.complete == eventType then
					count = count - 1
					if count <= 0 then
						armature:removeFromParent()
					end
				elseif ccs.MovementEventType.loopComplete == eventType then
					count = count - 1
					if count <= 0 then
						armature:removeFromParent()
					end
				end
			end
			local armature , animation = g_gameTools.LoadCocosAni("anime/WJQF/WJQF.ExportJson", "WJQF", onMovementEventCallFunc)
			local size = self:getContentSize()
			armature:setPosition(cc.p(size.width / 2, size.height / 2))
			self:addChild(armature, 0, c_tag_playAttack_effect)
			local animationName = nil
			local scaleX = 1.0
			local angle = cToolsForLua:calc2VecAngle(1, 0, vec_back_attack.x, vec_back_attack.y)
			angle = ((angle < 0) and (360 + angle) or (angle))
			angle = math.floor(angle + 22.5)
			angle = angle % 360
			local direction = math.floor((angle) / 45)
			if direction == 0 then
				animationName = "Ce"
				scaleX = 1.0
			elseif direction == 1 then
				animationName = "Bei45"
				scaleX = 1.0
			elseif direction == 2 then
				animationName = "Bei"
				scaleX = 1.0
			elseif direction == 3 then
				animationName = "Bei45"
				scaleX = -1.0
			elseif direction == 4 then
				animationName = "Ce"
				scaleX = -1.0
			elseif direction == 5 then
				animationName = "Zheng45"
				scaleX = -1.0
			elseif direction == 6 then
				animationName = "Zheng"
				scaleX = 1.0
			elseif direction == 7 then
				animationName = "Zheng45"
				scaleX = 1.0
			end
			armature:setScaleX(scaleX)
			animation:play(animationName , -1 , 1)
		end
	end
	
	return ret
end


function create_heshibi(configData, serverData)
	local ret = create_dynamic(configData, serverData)
	return ret
end


return worldMapLayer_buildDisplay