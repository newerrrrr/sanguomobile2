local helpModel = {}
setmetatable(helpModel,{__index = _G})
setfenv(1,helpModel)

local schedulerModelMD = require("game.uilayer.tournament.schedulerModel")

m_DesignSize = cc.size(1280.0, 960.0)

m_Center = cc.p(m_DesignSize.width * 0.5, m_DesignSize.height * 0.5)

m_MoveSinDivCos = 1.0

m_RoleRadius = 25.0

--张辽技能ID
ZHANGLIAO_SKILL	= 10093
XIAHOUDUN_SKILL = 10065

BESE_SCALE_TIME = 1.4


function playSound(id)
	if id and id ~= 0 then
		g_musicManager.playEffect(g_data.sounds[id].sounds_path)
	end
end

function createAttackRange(min, max, angle)
	assert(angle >= 2 and max >= 1 and max > min)
	
	local drawNode = cc.DrawNode:create()
	drawNode:setContentSize(cc.size(1.0, 1.0))
	drawNode:setAnchorPoint(cc.p(0.0, 0.0))
	
	local col = cc.c4f(255 / 255, 252 / 255, 0 / 255, 0.25)
	local col2 = cc.c4f(0.0, 0.0, 0.0, 0.0)
	local lineCol = cc.c4f(255 / 255, 252 / 255, 0 / 255, 0.65)
	local lineCol2 = cc.c4f(255 / 255, 252 / 255, 0 / 255, 0.45)
	local av = math.ceil(math.ceil(angle > 360 and 360 or angle) / 2)
	local step = av <= 60 and 2 or (av < 180 and 3 or 6)
	
	for i = -av , av - 1 , step do
		local cos1 = math.cos(i * math.pi / 180.0)
		local sin1 = math.sin(i * math.pi / 180.0)
		local cos2 = math.cos((i + step) * math.pi / 180.0)
		local sin2 = math.sin((i + step) * math.pi / 180.0)
		
		local p1 = cc.p(cos1 * min, sin1 * min)
		local p2 = cc.p(cos1 * max, sin1 * max)
		local p3 = cc.p(cos2 * max, sin2 * max)
		local p4 = cc.p(cos2 * min, sin2 * min)
		drawNode:drawPolygon({[1] = p1, [2] = p2, [3] = p3, [4] = p4},
			4,
			col,
			0,
			col2)
		
		--local p5 = cc.p(cos1 * (max - 1), sin1 * (max - 1))
		--local p6 = cc.p(cos2 * (max - 1), sin2 * (max - 1))
		local p7 = cc.p(cos1 * (max + 1), sin1 * (max + 1))
		local p8 = cc.p(cos2 * (max + 1), sin2 * (max + 1))
		--drawNode:drawLine(p5, p6, lineCol2)
		drawNode:drawLine(p2, p3, lineCol)
		drawNode:drawLine(p7, p8, lineCol2)
		
		if min > 20 then
			local p9 = cc.p(cos1 * min - 1, sin1 * min - 1)
			local p10 = cc.p(cos2 * min - 1, sin2 * min - 1)
			drawNode:drawLine(p9, p10, lineCol2)
			drawNode:drawLine(p1, p4, lineCol)
		end
	end	
	
	if angle < 359 then
		local cos1 = math.cos(-av * math.pi / 180.0)
		local sin1 = math.sin(-av * math.pi / 180.0)
		local cos2 = math.cos(av * math.pi / 180.0)
		local sin2 = math.sin(av * math.pi / 180.0)
		local p1 = cc.p(cos1 * min, sin1 * min)
		local p2 = cc.p(cos1 * max, sin1 * max)
		--local p3 = cc.p(cos1 * (min - 1), sin1 * (min - 1))
		--local p4 = cc.p(cos1 * (max - 1), sin1 * (max - 1))
		local p5 = cc.p(cos1 * (min + 1), sin1 * (min + 1))
		local p6 = cc.p(cos1 * (max + 1), sin1 * (max + 1))
		drawNode:drawLine(p1, p2, lineCol)
		--drawNode:drawLine(p3, p4, lineCol2)
		drawNode:drawLine(p5, p6, lineCol2)
		
		local p7 = cc.p(cos2 * min, sin2 * min)
		local p8 = cc.p(cos2 * max, sin2 * max)
		--local p9 = cc.p(cos2 * (min - 1), sin2 * (min - 1))
		--local p10 = cc.p(cos2 * (max - 1), sin2 * (max - 1))
		local p11 = cc.p(cos2 * (min + 1), sin2 * (min + 1))
		local p12 = cc.p(cos2 * (max + 1), sin2 * (max + 1))
		drawNode:drawLine(p7, p8, lineCol)
		--drawNode:drawLine(p9, p10, lineCol2)
		drawNode:drawLine(p11, p12, lineCol2)
	end
	
	local setRotation = drawNode.setRotation
	drawNode.setRotation = nil
	function drawNode.lua_setRotation(angle)
		setRotation(drawNode, -angle)
	end
	
	local setPosition = drawNode.setPosition
	drawNode.setPosition = nil
	function drawNode.lua_setPosition(p)
		setPosition(drawNode, p)
	end
	
	
	return drawNode
end


function createSkillRange(min, max, angle)
	assert(angle >= 2 and max >= 1 and max > min)
	
	local drawNode = cc.DrawNode:create()
	drawNode:setContentSize(cc.size(1.0, 1.0))
	drawNode:setAnchorPoint(cc.p(0.0, 0.0))
	
	local col = cc.c4f(0 / 255, 255 / 255, 255 / 255, 0.25)
	local col2 = cc.c4f(0.0, 0.0, 0.0, 0.0)
	local lineCol = cc.c4f(0 / 255, 255 / 255, 255 / 255, 0.65)
	local lineCol2 = cc.c4f(0 / 255, 255 / 255, 255 / 255, 0.45)
	local av = math.ceil(math.ceil(angle > 360 and 360 or angle) / 2)
	local step = av <= 60 and 2 or (av < 180 and 3 or 6)
	
	for i = -av , av - 1 , step do
		local cos1 = math.cos(i * math.pi / 180.0)
		local sin1 = math.sin(i * math.pi / 180.0)
		local cos2 = math.cos((i + step) * math.pi / 180.0)
		local sin2 = math.sin((i + step) * math.pi / 180.0)
		local p1 = cc.p(cos1 * min, sin1 * min)
		local p2 = cc.p(cos1 * max, sin1 * max)
		local p3 = cc.p(cos2 * max, sin2 * max)
		local p4 = cc.p(cos2 * min, sin2 * min)
		drawNode:drawPolygon({[1] = p1, [2] = p2, [3] = p3, [4] = p4},
			4,
			col,
			0,
			col2)
			
		--local p5 = cc.p(cos1 * (max - 1), sin1 * (max - 1))
		--local p6 = cc.p(cos2 * (max - 1), sin2 * (max - 1))
		local p7 = cc.p(cos1 * (max + 1), sin1 * (max + 1))
		local p8 = cc.p(cos2 * (max + 1), sin2 * (max + 1))
		--drawNode:drawLine(p5, p6, lineCol2)
		drawNode:drawLine(p2, p3, lineCol)
		drawNode:drawLine(p7, p8, lineCol2)
		
		if min > 20 then
			local p9 = cc.p(cos1 * min - 1, sin1 * min - 1)
			local p10 = cc.p(cos2 * min - 1, sin2 * min - 1)
			drawNode:drawLine(p9, p10, lineCol2)
			drawNode:drawLine(p1, p4, lineCol)
		end
	end
	
	if angle < 359 then
		local cos1 = math.cos(-av * math.pi / 180.0)
		local sin1 = math.sin(-av * math.pi / 180.0)
		local cos2 = math.cos(av * math.pi / 180.0)
		local sin2 = math.sin(av * math.pi / 180.0)
		local p1 = cc.p(cos1 * min, sin1 * min)
		local p2 = cc.p(cos1 * max, sin1 * max)
		--local p3 = cc.p(cos1 * (min - 1), sin1 * (min - 1))
		--local p4 = cc.p(cos1 * (max - 1), sin1 * (max - 1))
		local p5 = cc.p(cos1 * (min + 1), sin1 * (min + 1))
		local p6 = cc.p(cos1 * (max + 1), sin1 * (max + 1))
		drawNode:drawLine(p1, p2, lineCol)
		--drawNode:drawLine(p3, p4, lineCol2)
		drawNode:drawLine(p5, p6, lineCol2)
		
		local p7 = cc.p(cos2 * min, sin2 * min)
		local p8 = cc.p(cos2 * max, sin2 * max)
		--local p9 = cc.p(cos2 * (min - 1), sin2 * (min - 1))
		--local p10 = cc.p(cos2 * (max - 1), sin2 * (max - 1))
		local p11 = cc.p(cos2 * (min + 1), sin2 * (min + 1))
		local p12 = cc.p(cos2 * (max + 1), sin2 * (max + 1))
		drawNode:drawLine(p7, p8, lineCol)
		--drawNode:drawLine(p9, p10, lineCol2)
		drawNode:drawLine(p11, p12, lineCol2)
	end
	
	local setRotation = drawNode.setRotation
	drawNode.setRotation = nil
	function drawNode.lua_setRotation(angle)
		setRotation(drawNode, -angle)
	end
	
	local setPosition = drawNode.setPosition
	drawNode.setPosition = nil
	function drawNode.lua_setPosition(p)
		setPosition(drawNode, p)
	end
	
	
	return drawNode
end


function createMoveRange(rangeRadius)
	local image = cc.Sprite:create("tournament/move_range.png")
	local size = image:getContentSize()
	image:setScale(rangeRadius * 2 / size.width)
	
	m_MoveSinDivCos = (size.height / size.width)
	
	local setPosition = image.setPosition
	image.setPosition = nil
	function image.lua_setPosition(p)
		setPosition(image, p)
	end
	
	return image
end



function checkMovePoint(originPoint, wantPoint, rangeRadius)
	local dv = cc.pSub(wantPoint, originPoint)
	local angle = cToolsForLua:calc2VecAngle(1.0, 0.0, dv.x, dv.y)
	local max_x = math.cos(angle * math.pi / 180.0) * rangeRadius
	local max_y = math.sin(angle * math.pi / 180.0) * rangeRadius * m_MoveSinDivCos
	if dv.x * dv.x + dv.y * dv.y > max_x * max_x + max_y * max_y then
		return cc.p(max_x + originPoint.x, max_y + originPoint.y)
	else
		return wantPoint
	end
end



function createSubHpText(num, targetPos, atkPos)
	local text = "/"..tostring(math.ceil(math.abs(num)))
	local label = cc.LabelAtlas:create(text, "tournament/num/num_reduce.png", 36, 50, 47)
	schedulerModelMD.resetNodeSchedulerAndActionManage(label)
	label:setScale(0.2)
	label:setAnchorPoint(cc.p(0.5, 0.5))
	label:setPosition(cc.p(targetPos.x, targetPos.y + 110))
	local dv = cc.pSub(targetPos, atkPos)
	local dv_len = math.sqrt(dv.x * dv.x + dv.y * dv.y)
	local cos = cc.clampf(dv.x / dv_len, -1.0, 1.0)
	local act_bi = cc.Spawn:create(
		cc.MoveBy:create(0.45, cc.p(math.random(60, 80) * cos, math.random(60, 80)))
		, cc.FadeTo:create(0.45, 0)
	)
	local act = cc.Sequence:create(
		cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 1.0, 1.0, 1.0))
		, cc.DelayTime:create(0.1618)
		, act_bi
		, cc.RemoveSelf:create()
	)
	label:runAction(act)
	return label
end


function createPlusHpText(num, targetPos, atkPos)
	local text = "/"..tostring(math.ceil(math.abs(num)))
	local label = cc.LabelAtlas:create(text, "tournament/num/num_plus.png", 36, 50, 47)
	schedulerModelMD.resetNodeSchedulerAndActionManage(label)
	label:setScale(0.2)
	label:setAnchorPoint(cc.p(0.5, 0.5))
	label:setPosition(cc.p(targetPos.x, targetPos.y + 210))
	local dv = cc.pSub(targetPos, atkPos)
	local dv_len = math.sqrt(dv.x * dv.x + dv.y * dv.y)
	local cos = cc.clampf(dv.x / dv_len, -1.0, 1.0)
	local act_bi = cc.Spawn:create(
		cc.MoveBy:create(0.45, cc.p(math.random(60, 80) * cos, math.random(60, 80)))
		, cc.FadeTo:create(0.45, 0)
	)
	local act = cc.Sequence:create(
		cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 1.0, 1.0, 1.0))
		, cc.DelayTime:create(0.1618)
		, act_bi
		, cc.RemoveSelf:create()
	)
	label:runAction(act)
	return label
end


function createSkillNameAirImage(skillConfigData, pos)
	if skillConfigData.skill_word_res and skillConfigData.skill_word_res ~= 0 then
		local bitmap = cc.Sprite:create(g_data.sprite[skillConfigData.skill_word_res].path)
		schedulerModelMD.resetNodeSchedulerAndActionManage(bitmap)
		bitmap:setScale(0.5)
		bitmap:setPosition(cc.p(pos.x, pos.y + 120))
		local act_bi = cc.Spawn:create(
			cc.MoveBy:create(0.45, cc.p(0, math.random(60, 80)))
			, cc.FadeTo:create(0.45, 0)
		)
		local act = cc.Sequence:create(
			cc.EaseBackOut:create(cc.ScaleTo:create(0.15, 1.0, 1.0, 1.0))
			, cc.DelayTime:create(0.1618)
			, act_bi
			, cc.RemoveSelf:create()
		)
		bitmap:runAction(act)
		return bitmap
	end
	return nil
end


function preLoadHeroSkillRes(heroData)
	if heroData then
		local skillsModelMD = require("game.uilayer.tournament.skillsModel")
		local hero_configData = g_data.general[heroData.hero_configId]	
		if hero_configData then
			local attack_configData = g_data.duel_skill[hero_configData.general_duel_atk]		--攻击配置数据
			if attack_configData then
				if attack_configData.skill_src_res ~= 0 then
					skillsModelMD.preSkill(attack_configData.skill_src_res)
				end
				if attack_configData.skill_orbit_res ~= 0 then
					skillsModelMD.preSkill(attack_configData.skill_orbit_res)
				end
				if attack_configData.skill_dst_res ~= 0 then
					skillsModelMD.preSkill(attack_configData.skill_dst_res)
				end
			end
			local skill_configData = g_data.duel_skill[hero_configData.general_duel_skill]		--技能配置数据
			if skill_configData then
				if skill_configData.skill_src_res ~= 0 then
					skillsModelMD.preSkill(skill_configData.skill_src_res)
				end
				if skill_configData.skill_orbit_res ~= 0 then
					skillsModelMD.preSkill(skill_configData.skill_orbit_res)
				end
				if skill_configData.skill_dst_res ~= 0 then
					skillsModelMD.preSkill(skill_configData.skill_dst_res)
				end
			end
		end
	end
end





return helpModel