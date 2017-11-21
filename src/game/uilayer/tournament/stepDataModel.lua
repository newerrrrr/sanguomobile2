local stepDataModel = {}
setmetatable(stepDataModel,{__index = _G})
setfenv(1,stepDataModel)

local buffsModelMD = require("game.uilayer.tournament.buffsModel")

--武斗回合数据(一旦上版本便不可随意更改，否则回放数据将无法使用)


local function _createHero(serverData)
	
	local hero_configId = serverData.hero_configId
	
	local hero_configData = g_data.general[hero_configId]								--武将配置数据	
	
	local attack_configData = g_data.duel_skill[hero_configData.general_duel_atk]		--攻击配置数据
	
    local skill_id = hero_configData.general_duel_skill

    local change_skill_hero = serverData.change_skill_hero

    if change_skill_hero then
        local hero_configId = change_skill_hero.hero_configId
        skill_id = g_data.general[hero_configId].general_duel_skill
    end


	local skill_configData = g_data.duel_skill[skill_id]		--技能配置数据
	
	local ret = {}
	
	--转换技能英雄的数据-------------
    --这个为什么不直接拿技能ID的原因是因为界面要显示转换技能的图标而技能图标配在武将表里
    ret.change_skill_hero = serverData.change_skill_hero

	--服务器发送-----------------
	
	ret.hero_configId = hero_configId						--武将配置ID
	
	ret.hero_wu = serverData.hero_wu						--五属性
	ret.hero_zhi = serverData.hero_zhi
	ret.hero_zheng = serverData.hero_zheng
	ret.hero_tong = serverData.hero_tong
	ret.hero_mei = serverData.hero_mei
	
	ret.hero_lv = serverData.hero_lv						--武将等级
	ret.skill_lv = serverData.skill_lv						--武将技能等级
	
	
	--配置数据记录-----------------
	
	ret.model_res_id = hero_configData.cocos_res				--武将模型ID	
	
	ret.weapon_type = hero_configData.weapon_type				--武器类型
	
	ret.move_range = hero_configData.general_duel_move 			--武将距离半径r,w
	
	ret.attack_configId = hero_configData.general_duel_atk		--普通攻击ID
	
	ret.skill_configId = skill_id
    --hero_configData.general_duel_skill		--技能攻击ID (可能是0)
	
	ret.attack_min_range = attack_configData.short_distance		--普通攻击最小距离
	
	ret.attack_max_range = attack_configData.long_distance		--普通攻击最大距离
	
	ret.attack_angle_range = attack_configData.range			--普通攻击角度范围
	
	ret.attack_buffs_before_self = {}							--普通攻击buff列表
	for k , v in pairs(attack_configData.duel_buff_self_1) do
		ret.attack_buffs_before_self[tostring(v)] = true
	end
	ret.attack_buffs_before_target = {}							--普通攻击buff列表
	for k , v in pairs(attack_configData.duel_buff_enemy_1) do
		ret.attack_buffs_before_target[tostring(v)] = true
	end
	ret.attack_buffs_after_self = {}							--普通攻击buff列表
	for k , v in pairs(attack_configData.duel_buff_self_2) do
		ret.attack_buffs_after_self[tostring(v)] = true
	end
	ret.attack_buffs_after_target = {}							--普通攻击buff列表
	for k , v in pairs(attack_configData.duel_buff_enemy_2) do
		ret.attack_buffs_after_target[tostring(v)] = true
	end
	
	ret.skill_min_range = skill_configData and skill_configData.short_distance or 0		--技能攻击最小距离
	
	ret.skill_max_range = skill_configData and skill_configData.long_distance or 0		--技能攻击最大距离
	
	ret.skill_angle_range = skill_configData and skill_configData.range or 0			--技能攻击角度范围
	
	ret.skill_buffs_before_self = {}							--技能攻击buff列表
	ret.skill_buffs_before_target = {}							--技能攻击buff列表
	ret.skill_buffs_after_self = {}								--技能攻击buff列表
	ret.skill_buffs_after_target = {}							--技能攻击buff列表
	
	if skill_configData then
		for k , v in pairs(skill_configData.duel_buff_self_1) do
			ret.skill_buffs_before_self[tostring(v)] = true
		end
		for k , v in pairs(skill_configData.duel_buff_enemy_1) do
			ret.skill_buffs_before_target[tostring(v)] = true
		end
		for k , v in pairs(skill_configData.duel_buff_self_2) do
			ret.skill_buffs_after_self[tostring(v)] = true
		end
		for k , v in pairs(skill_configData.duel_buff_enemy_2) do
			ret.skill_buffs_after_target[tostring(v)] = true
		end
	end
	
	
	--初始化计算-----------------
	
	g_custom_loadFunc("OperateMaxHP", "(v)", " return "..hero_configData.duel_hit_point)
	ret.hero_max_hp = math.ceil(externFunctionOperateMaxHP(ret))	--武将最大HP(务必取整)
	ret.hero_current_hp = ret.hero_max_hp							--武将当前HP(务必取整)
	
	ret.hero_max_sp = hero_configData.duel_hero_max_sp				--武将最大SP(务必取整)
	ret.hero_current_sp = hero_configData.duel_hero_start_sp		--武将当前SP(务必取整)
	
	ret.hero_restore_sp = hero_configData.duel_hero_restore_sp		--每回合SP恢复量(务必取整)
	
	ret.skill_need_sp = skill_configData and skill_configData.skill_need_sp or 0 	--释放技能需要SP(务必取整)
	
	ret.buffs = {	--已被挂上的buff
		--[tostring(buffId)] = {
		--	typeId = 0,
		--	buffId = 0,
		--	count = 0,
		--}
	}

	return ret
end
--计算攻击力
function operateAttackForceWithServerData(heroData_1, heroData_2)
	local configData = g_data.duel_skill[heroData_1.attack_configId]
	g_custom_loadFunc("OperateAttackForce", "(v1, v2)", " return "..configData.client_formula)
	return math.ceil(externFunctionOperateAttackForce(heroData_1, heroData_2)) --普通攻击伤害力(务必取整)
end
--计算技能攻击力
function operateSkillForceWithServerData(heroData_1, heroData_2)
	local configData = g_data.duel_skill[heroData_1.skill_configId]
	g_custom_loadFunc("OperateSkillForce", "(v1, v2)", " return "..configData.client_formula)
	return math.ceil(externFunctionOperateSkillForce(heroData_1, heroData_2)) --技能攻击伤害力(务必取整)
end

function checkHasBuffWithTypeId(heroData, typeId)
	for k , v in pairs(heroData.buffs) do
		if v.typeId == typeId then
			return true
		end
	end
	return false
end
function findBuffWithTypeId(heroData, typeId)
	for k , v in pairs(heroData.buffs) do
		if v.typeId == typeId then
			return clone(v)
		end
	end
	return nil
end

--直接消除BUFF
function subEndWithTypeIds(heroData, typeIds)
    local ret = {}
	if typeIds and table.total(typeIds) > 0 then
		for k , v in pairs(heroData.buffs) do
			if typeIds[v.typeId] then
				v.count = 0
				if v.count <= 0 then
					ret[k] = true
					heroData.buffs[k] = nil
				end
			end
		end
	end
	return ret
end
    
--减少BUFF计数器,并且返回完全删除的BUFF列表
function subCountWithTypeIds(heroData, typeIds) --ID以数字类型放在Key中
	local ret = {}
	if typeIds and table.total(typeIds) > 0 then
		for k , v in pairs(heroData.buffs) do
			if typeIds[v.typeId] then
				v.count = v.count - 1
				if v.count <= 0 then
					ret[k] = true
					heroData.buffs[k] = nil
				end
			end
		end
	end
	return ret
end

--概率BUUF
--heroData BUFF发起方的的英雄数据
function randomHeroBuff(heroData,buffId)
    local configData = g_data.duel_buff[tonumber(buffId)]
    local skillType = configData.type
    
    print("=========",skillType)

    if 
    skillType == buffsModelMD.m_BuffType.fixed or 
    skillType == buffsModelMD.m_BuffType.silence or
    skillType == buffsModelMD.m_BuffType.dizzy
    then
        g_custom_loadFunc("OperateBuff", "(v1)", " return "..configData.client_formula)
        local value = externFunctionOperateBuff(heroData) * 100
        local rvalue = math.random(1,100)
        return rvalue <= value
    end

    return true

end



--加入BUFF
function addHeroBuffWithBuffId(heroData, buffId)
	local configData = g_data.duel_buff[tonumber(buffId)]
	heroData.buffs[tostring(buffId)] = {
		typeId = configData.type,
		buffId = tonumber(buffId),
		count = configData.round_formula,
	}
end
--计算基础BUFF并修改基础属性
function operateChangeBaseBuff(heroData)
	local originBase = {
		hero_wu = heroData.hero_wu,
		hero_zhi = heroData.hero_zhi,
		hero_zheng = heroData.hero_zheng,
		hero_tong = heroData.hero_tong,
		hero_mei = heroData.hero_mei,
	}
	
	--武力减少
	local wuli_sub_buff = findBuffWithTypeId(heroData, buffsModelMD.m_BuffType.wuliSub)
	if wuli_sub_buff then
		local configData = g_data.duel_buff[wuli_sub_buff.buffId]
		g_custom_loadFunc("OperateBuff", "(v1, v2)", " return "..configData.client_formula)
		local v = externFunctionOperateBuff(heroData, nil)
		heroData.hero_wu = heroData.hero_wu * (1.0 - v)
	end
	
	return originBase
end
--恢复基础属性
function resumeChangeBaseBuff(heroData, v)
	heroData.hero_wu = v.hero_wu
	heroData.hero_zhi = v.hero_zhi
	heroData.hero_zheng = v.hero_zheng
	heroData.hero_tong = v.hero_tong
	heroData.hero_mei = v.hero_mei
end


--攻击计算结果，拷贝使用，用以播放
c_atk_play_data = {
	
	action_attack = false,	--是否普通攻击
	
	action_skill = false,	--是否用技能
	
	action_hit = false,		--攻击是否命中
	
	action_death = false,	--是否死亡
	
	action_hit_death = false,	--命中对手后自己是否死亡(比如中了对手的反伤BUFF)
	
	action_hit_change_hp = false,	--命中对手后自己是否有血量改变
    
    action_back_hp = false,   --命中对手后自己是否加血
    action_back_hit_hp = false, --命中对手后对手是否加血
    action_move_back_hp = false,

	before_max_hp = 0,		--攻击前的最大血量
	before_cur_hp = 0,		--攻击前的当前血量
	back_hp = 0,            --恢复的血量
    hit_hp =0,
	after_hit_cur_hp = 0,	--攻击命中后的当前血量(必然在命中对方时才有实际改变,比如中了对手的反伤BUFF)
	
	after_blow_cur_hp = 0,	--被击后的当前血量(必然在对方命中时才有实际改变)
	
	before_max_sp = 0,		--攻击前的最大SP
	before_cur_sp = 0,		--攻击前的当前SP
	
	after_usedSkill_cur_sp = 0,  --使用技能后的当前SP
	
	attack_min_range = 0,
	attack_max_range = 0,
	
	skill_min_range = 0,
	skill_max_range = 0,

    action_move_change_hp = false,
    before_move_end_hp = 0, --移动结束后的掉血血量
	move_blow_cur_hp = 0,--移动过后的剩余血量
    action_diaoxue_death = false,  --是否是流血死亡
	
	addBuffs_before_self = {	--自己攻击前给自己增加的buff
		--[tostring(buffId)] = true
	},
	
	addBuffs_after_self = {		--自己攻击后给自己增加的buff
		--[tostring(buffId)] = true
	},
	
	subBuffs_before_self = {	--自己攻击前给自己减少的buff
		--[tostring(buffId)] = true
	},
	
	subBuffs_after_self = {		--自己攻击后给自己减少的buff
		--[tostring(buffId)] = true
	},
	
	addBuffs_before_target = {	--对方攻击前给我增加的buff
		--[tostring(buffId)] = true
	},
	
	addBuffs_after_target = {	--对方攻击后给我增加的buff
		--[tostring(buffId)] = true
	},
	
	subBuffs_before_target = {	--对方攻击前给我减少的buff
		--[tostring(buffId)] = true
	},
	
	subBuffs_after_target = {	--对方攻击后给我减少的buff
		--[tostring(buffId)] = true
	},
	
	
	move_pos = cc.p(0, 0),		--移动点
	atk_angle = 0,				--攻击角度
	
	atk_teleporting_pos = cc.p(0, 0),	--张辽瞬移
	atk_teleporting_angle = 0,			--张辽瞬移
}

function atkInitSetting(data, max_hp, cur_hp, max_sp, cur_sp, operate_pos, operate_angle, final_pos, final_angle, a_min_r, a_max_r, s_min_r, s_max_r)
	data.before_max_hp = max_hp
	data.before_cur_hp = cur_hp
	data.before_max_sp = max_sp
	data.before_cur_sp = cur_sp
	
	data.after_hit_cur_hp = cur_hp
	data.after_blow_cur_hp = cur_hp
    data.move_blow_cur_hp = cur_hp
	data.after_usedSkill_cur_sp = cur_sp
	
	data.attack_min_range = a_min_r
	data.attack_max_range = a_max_r
	
	data.skill_min_range = s_min_r
	data.skill_max_range = s_max_r
	
	data.move_pos = cc.p(operate_pos.x, operate_pos.y)			--移动点
	data.atk_angle = operate_angle								--攻击角度
	
	data.atk_teleporting_pos = cc.p(final_pos.x, final_pos.y)	--攻击时瞬移,张辽瞬移准备
	data.atk_teleporting_angle = final_angle					--攻击时瞬移,张辽瞬移准备
end



--回合末结果，拷贝使用，用以播放
c_roundEnd_play_data = {
	
	action_death = false,	--是否死亡
	
	before_max_hp = 0,		--回合末前的最大血量
	before_cur_hp = 0,		--回合末前的当前血量
	
	before_max_sp = 0,		--回合末前的最大SP
	before_cur_sp = 0,		--回合末前的当前SP
	
	after_restore_cur_sp = 0,	--每回合末恢复SP后的当前SP
	
	subBuffs = {			--减少的buff
		--[tostring(buffId)] = true
	},
}
function roundEndInitSetting(data, max_hp, cur_hp, max_sp, cur_sp)
	data.before_max_hp = max_hp
	data.before_cur_hp = cur_hp
	data.before_max_sp = max_sp
	data.before_cur_sp = cur_sp
	data.back_hp = 0
    data.hit_hp = 0
    before_move_end_hp = 0
	data.after_restore_cur_sp = cur_sp
end


--获取荀彧需要转换的技能（规则是将不是与荀彧相同回合的英雄的最高武力英雄的技能转换给荀彧）
function setXunYuSkill(server_A,server_B)
        
    local seasonA = nil
    local seasonB = nil
    for i = 1, 3 do
        if tonumber(server_A[tostring(i)].general_id) == 10072 then
            seasonA = i
        end

        if tonumber(server_B[tostring(i)].general_id) == 10072 then
            seasonB = i
        end
    end

    local function _getSkillId(Z,season)
        local cSkillHero = nil
        local wuli = 0
        local heros = (Z == "A" and server_B or server_A )
        for i = 1, 3 do
            if i ~= tonumber(season) then
                local hero = heros[ tostring(i) ]
                if hero.hero_wu >= wuli then
                    wuli = hero.hero_wu
                    cSkillHero = clone(hero)
                    --local hero_configId = hero.hero_configId
                    --cSkillId = g_data.general[hero_configId].general_duel_skill
                end
            end
        end
        return cSkillHero
    end

    if seasonA then
        server_A[tostring(seasonA)].change_skill_hero = _getSkillId("A",seasonA)
    end

    if seasonB then
        server_B[tostring(seasonB)].change_skill_hero = _getSkillId("B",seasonB)
    end

end


function createNewData(server_A, server_B, a_point, a_angle, b_point, b_angle)
	local ret = {}
	
    setXunYuSkill(server_A, server_B)

	ret.stepData = { 
	
		A = {
			["hero_1"] = _createHero(server_A["1"]),
			
			["hero_2"] = _createHero(server_A["2"]),
			
			["hero_3"] = _createHero(server_A["3"]),
			
			startPoint = cc.p(a_point.x, a_point.y),
			
			startAngle = a_angle,
		},
		
		B = {
			["hero_1"] = _createHero(server_B["1"]),
			
			["hero_2"] = _createHero(server_B["2"]),
			
			["hero_3"] = _createHero(server_B["3"]),
			
			startPoint = cc.p(b_point.x, b_point.y),
			
			startAngle = b_angle,
		},
		
		map = 1,
		
		step = {
			["season_1"] = {
				first = math.random(1, 2),
				
				outcome = false,	--是否已分胜负
				
				win = 0,			--胜利方,0为平手,1为A方,2为B方（战斗结束才后此值才有意义）
			},
			
			["season_2"] = {
				first = math.random(1, 2),
				
				outcome = false,	--是否已分胜负
				
				win = 0,
			},
			
			["season_3"] = {
				first = math.random(1, 2),
				
				outcome = false,	--是否已分胜负
				
				win = 0,
			},
		},
	}
	
	
	function ret.newRound(season, round)
		if round == 1 then
			
			local a_hero = ret.stepData.A["hero_"..tostring(season)]
			
			local b_hero = ret.stepData.B["hero_"..tostring(season)]
			
			ret.stepData.step["season_"..tostring(season)]["round_1"] = {
				a = {
					
					origin_heroPart = clone(a_hero),
					
					results_heroPart = {		--结果状态武将部分数据
					},
					
					atk_play_data = {			--攻击数据(播放动画用)
					},
					
					roundEnd_play_data = {	--回合末数据(播放动画用)
					},
					
					origin = {			--当前
						position = cc.p(ret.stepData.A.startPoint.x, ret.stepData.A.startPoint.y),
						angle = ret.stepData.A.startAngle,
					},
					
					operate = {			--操作
					},
					
					final = {			--回合结束后最终
					},
					
				},
				
				b = {
					
					origin_heroPart = clone(b_hero),
					
					results_heroPart = {		--结果状态武将部分数据
					},
					
					atk_play_data = {		--计算攻击后的状态改变数据(播放动画用)
					},
					
					roundEnd_play_data = {	--回合末的状态改变数据(播放动画用)
					},
					
					origin = {			--当前
						position = cc.p(ret.stepData.B.startPoint.x, ret.stepData.B.startPoint.y),
						angle = ret.stepData.B.startAngle,
					},
					
					operate = {			--操作			
					},
					
					final = {			--回合结束后最终
					},
				},
			}
			
		else
			local lastRoundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round - 1)]
			
			ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)] = {
				a = {
					
					origin_heroPart = clone(lastRoundData.a.results_heroPart),
					
					results_heroPart = {		--结果状态武将部分数据
					},
					
					atk_play_data = {		--计算攻击后的状态改变数据(播放动画用)
					},
					
					roundEnd_play_data = {	--回合末的状态改变数据(播放动画用)
					},
					
					origin = {			--当前
						position = cc.p(lastRoundData.a.final.position.x, lastRoundData.a.final.position.y),
						angle = lastRoundData.a.final.angle
					},
					
					operate = {			--操作
					},
					
					final = {			--回合结束后最终
					},
					
				},
				
				b = {
					
					origin_heroPart = clone(lastRoundData.b.results_heroPart),
					
					results_heroPart = {		--结果状态武将部分数据
					},
					
					atk_play_data = {		--计算攻击后的状态改变数据(播放动画用)
					},
					
					roundEnd_play_data = {	--回合末的状态改变数据(播放动画用)
					},
					
					origin = {			--当前
						position = cc.p(lastRoundData.b.final.position.x, lastRoundData.b.final.position.y),
						angle = lastRoundData.b.final.angle,
					},
					
					operate = {			--操作	
					},
					
					final = {			--回合结束后最终
					},
					
				},
			}
			
		end
	end
	
	function ret.getHeroAllIconSprite(Z, season)
		local k = (Z == "A" and "A" or "B")
		local hero = ret.stepData[k]["hero_"..tostring(season)]
		local headImage = cc.Sprite:create(g_data.sprite[g_data.general[hero.hero_configId].general_big_icon].path)
		return headImage
	end
	
	function ret.getHeroInitData(Z, season)
		local k = (Z == "A" and "A" or "B")
		return ret.stepData[k]["hero_"..tostring(season)]
	end
	
	function ret.getHeroCurrentData(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].origin_heroPart
	end
	
	function ret.getFirst(season)
		return ret.stepData.step["season_"..tostring(season)].first
	end
	
	function ret.getOriginPoint(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return cc.p(roundData[k].origin.position.x, roundData[k].origin.position.y)
	end
	
	function ret.getOriginAngle(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].origin.angle
	end
	
	function ret.setOperatePoint(Z, season, round, point)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].operate.position = cc.p(point.x, point.y)
	end
	
	function ret.setOperateAngle(Z, season, round, angle)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].operate.angle = angle
	end
	
	function ret.setOperateSkill(Z, season, round, skill)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].operate.skill = skill
	end
	
	function ret.getOperatePoint(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return cc.p(roundData[k].operate.position.x, roundData[k].operate.position.y)
	end
	
	function ret.getOperateAngle(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].operate.angle
	end
	
	function ret.getOperateSkill(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].operate.skill
	end
	
	function ret.setFinalPoint(Z, season, round, point)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].final.position = cc.p(point.x, point.y)
	end
	
	function ret.setFinalAngle(Z, season, round, angle)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].final.angle = angle
	end
	
	function ret.getFinalPoint(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return cc.p(roundData[k].final.position.x, roundData[k].final.position.y)
	end
	
	function ret.getFinalAngle(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].final.angle
	end
	
	function ret.setResultsHeroPart(Z, season, round, hero)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].results_heroPart = hero
	end
	
	function ret.getResultsHeroPart(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].results_heroPart
	end
	
	function ret.setAtkPlayData(Z, season, round, atk_data)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].atk_play_data = atk_data
	end
	
	function ret.getAtkPlayData(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].atk_play_data
	end
	
	function ret.setRoundEndPlayData(Z, season, round, roundEnd_data)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		roundData[k].roundEnd_play_data = roundEnd_data
	end
	
	function ret.getRoundEndPlayData(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].roundEnd_play_data
	end
	
	function ret.setWin(season, win)
		local t = ret.stepData.step["season_"..tostring(season)]
		t.outcome = true
		t.win = win
	end
	
	function ret.getWin(season)
		return ret.stepData.step["season_"..tostring(season)].win
	end
	
	function ret.getOutcome(season)
		return ret.stepData.step["season_"..tostring(season)].outcome
	end
	
	
	return ret
end



function createBackPlayData(saveStepData)
	local ret = {}
	
	ret.stepData = clone(saveStepData)
	
	function ret.getHeroAllIconSprite(Z, season)
		local k = (Z == "A" and "A" or "B")
		local hero = ret.stepData[k]["hero_"..tostring(season)]
		local headImage = cc.Sprite:create(g_data.sprite[g_data.general[hero.hero_configId].general_big_icon].path)
		return headImage
	end
	
	function ret.getHeroInitData(Z, season)
		local k = (Z == "A" and "A" or "B")
		return ret.stepData[k]["hero_"..tostring(season)]
	end
	
	function ret.getHeroCurrentData(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].origin_heroPart
	end
	
	function ret.getFirst(season)
		return ret.stepData.step["season_"..tostring(season)].first
	end
	
	function ret.getOriginPoint(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return cc.p(roundData[k].origin.position.x, roundData[k].origin.position.y)
	end
	
	function ret.getOriginAngle(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].origin.angle
	end
	
	function ret.getOperatePoint(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return cc.p(roundData[k].operate.position.x, roundData[k].operate.position.y)
	end
	
	function ret.getOperateAngle(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].operate.angle
	end
	
	function ret.getOperateSkill(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].operate.skill
	end
	
	function ret.getResultsHeroPart(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].results_heroPart
	end
	
	function ret.getAtkPlayData(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].atk_play_data
	end
	
	function ret.getRoundEndPlayData(Z, season, round)
		local roundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round)]
		local k = (Z == "A" and "a" or "b")
		return roundData[k].roundEnd_play_data
	end
	
	function ret.getWin(season)
		return ret.stepData.step["season_"..tostring(season)].win
	end
	
	--function ret.getOutcome(season)
	--	return ret.stepData.step["season_"..tostring(season)].outcome
	--end
	
	function ret.testNextRound(season, round)
		local nextRoundData = ret.stepData.step["season_"..tostring(season)]["round_"..tostring(round + 1)]
		return nextRoundData and true or false
	end
	
	function ret.testNextSeason(season)
		local nextSeasonData = ret.stepData.step["season_"..tostring(season + 1)]
		return nextSeasonData and nextSeasonData["round_1"] or false
	end
	
	return ret
end

function getBuffValue(selfData,data1,data2,buffId)
    local value = 0
    local buffData = findBuffWithTypeId(selfData,buffId)
    if buffData then
        local configData = g_data.duel_buff[buffData.buffId]
        g_custom_loadFunc("OperateBuff", "(v1,v2)", " return "..configData.client_formula)
        value = math.ceil(externFunctionOperateBuff(data1,data2))
    end
    return value
end

function getWuLiMaxData()
    
end



--[[

local stepData = { 

	A = { 					--左边方基本数据,{["1"],["2"],["3"]}出战顺序
		["hero_1"] = heroData,
		["hero_2"] = heroData,
		["hero_3"] = heroData,
		
		startPoint = cc.p(?, ?)，	--起始点
		startAngle = 0，			--起始角度
	},
	
	B = { 					--右边方基本数据,{["1"],["2"],["3"]}出战顺序
		["hero_1"] = heroData,
		["hero_2"] = heroData,
		["hero_3"] = heroData,
		
		startPoint = cc.p(?, ?)，	--起始点
		startAngle = 0，			--起始角度
	},
	
	map = 1,	--地图ID
	
	step = {				--回合数据,{["1"],["2"],...}每回合
	
		["season_1"] = {			--第一场次
			
			first = 1,		--随机先手方,1为A方,2为B方（每次进入武斗时随机初始化）
			
			outcome = false,	--是否已分胜负
			
			win = 1,		--胜利方,0为平手,1为A方,2为B方（战斗结束才后此值才有意义）
			
			["round_1"] = {			--第一回合
			
				a = {			--A方信息
					
					origin_heroPart = { --当前状态武将部分数据
					
						hero_max_hp = 999,
						hero_current_hp = 999,
						hero_max_sp = 999,
						hero_current_sp = 999,
						
						move_range = 999,
						
						attack_min_range = 20,
						attack_max_range = 60,
						attack_angle_range = 60,
						
						skill_min_range = 80,
						skill_max_range = 180,
						skill_angle_range = 240,
							
						buffs = {
							[buffID] = roundCount,
						},
					},
					
					results_heroPart = {		--结果状态武将部分数据
						...和 origin_heroPart 一样
					},
					
					atk_play_data = {			--攻击数据(播放动画用)
						和 c_atk_play_data 一样
					},
					
					roundEnd_play_data = {	--回合末数据(播放动画用)
						和 c_roundEnd_play_data 一样
					},
					
					origin = {			--当前
						position = cc.p(?, ?),	--原点
						angle = 0,				--攻击角度（技能角度也是它）
					},
					
					operate = {			--操作
						position = cc.p(?, ?)，	--移动目标点
						angle = 0，				--攻击角度（技能角度也是它）
						skill = 0,				--是否技能 0：否， 1：是
					},
					
					final = {			--回合结束后最终
						position = cc.p(?, ?),	--回合结束后最终点(并不一定与操作目标点相等)
						angle = 0,				--回合结束后最终朝向角度（技能角度也是它）
					},
					
				}
				
				b = {
					...
				}
			
			},
			
			["..."] = {...},	--第二回合同上
		
		},
		
		["..."] = {...},	--第二场次同上
		
	},
}

--]]

return stepDataModel