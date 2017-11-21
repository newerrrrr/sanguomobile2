local GodGeneralMode = class("GodGeneralMode")

local levelUpMats --升级材料

local _fixOffset = function(offset)
	return math.round(offset*100)/100
end

function GodGeneralMode:instance()
    if nil == GodGeneralMode._instance then 
        GodGeneralMode._instance = GodGeneralMode.new()
        GodGeneralMode:initGodGeneralConfig()
    end 

    return GodGeneralMode 
end

--初始化配置表
function GodGeneralMode:initGodGeneralConfig()
    if self.configData == nil or self.godConfigData == nil then
        self.configData = {}
        self.godConfigData = {}
        --关联神武将的root配置信息
        self.rootKeyVecForGod = {}
        self.rootKeyVec = {}
        local generalConfig = g_data.general 
        for _ , config in pairs(generalConfig) do
            if config.condition ~= 0 then
                --神武将的配置数据
                if config.general_quality == g_GeneralMode.godQuality then
                    self.godConfigData[config.id] = config
                    self.rootKeyVecForGod[config.root_id] = config
                else--可化神的武将
                    self.configData[config.id] = config
                    self.rootKeyVec[config.root_id] = config
                end
            end
        end
    end
end

--获取武将的装备属性
--oldServerData 没有特殊需要不用传 这个是用没有更新的数据和新数据做对比 来计算升级或者升星星后新的属性的加值
function GodGeneralMode:initEquiptSx(originalId,oldServerData)

    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    local general = nil
    if mapStatus == changeMapScene.m_MapEnum.guildwar then
        general = g_crossGeneral.getOwnedGeneralByOriginalId(originalId)
    elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
        general = g_cityBattleGeneral.getOwnedGeneralByOriginalId(originalId)
    else
        general = g_GeneralMode.getOwnedGeneralByOriginalId(originalId)
    end

    local generalData = oldServerData or general
    
    if originalId == nil then
        print("originalId is nil")
        return
    end
    
    local generalSx = g_GeneralMode.getGeneralPropertyByGeneralId(originalId)
    local allGeneralSx = g_GeneralMode.getAllGeneralPropertyByGeneralId(originalId)

    local equipAttr = 
    {
        ["force"] = { sv = generalSx[1], av = allGeneralSx[1] - generalSx[1]  },
        ["intelligence"] = { sv = generalSx[2], av = allGeneralSx[2] - generalSx[2]},
        ["governing"] = { sv = generalSx[3], av = allGeneralSx[3] - generalSx[3]},
        ["charm"] = { sv = generalSx[4], av = allGeneralSx[4] - generalSx[4]},
        ["political"] = { sv = generalSx[5],av = allGeneralSx[5] - generalSx[5] },
    }

    --[[local generalData = oldServerData or g_GeneralMode.getOwnedGeneralByOriginalId(originalId)
    --g_GeneralMode.getGeneralById(originalId)
    local gid = tonumber(originalId .. "01")

    local config = g_data.general[gid]
    

    local equipAttr = 
    {
        ["force"] = { sv = config.general_force, av = 0 },
        ["intelligence"] = { sv = config.general_intelligence, av = 0},
        ["political"] = { sv = config.general_political,av = 0 },
        ["governing"] = { sv = config.general_governing, av = 0},
        ["charm"] = { sv = config.general_charm, av = 0},
    }
    
    if generalData then
        
        local level = generalData.lv

        equipAttr.force.sv = equipAttr.force.sv + generalData.force_rate * (level - 1)
        equipAttr.intelligence.sv = equipAttr.intelligence.sv + generalData.intelligence_rate * (level - 1)
        equipAttr.political.sv = equipAttr.political.sv + generalData.political_rate * (level - 1)
        equipAttr.governing.sv = equipAttr.governing.sv + generalData.governing_rate * (level - 1)
        equipAttr.charm.sv =  equipAttr.charm.sv + generalData.charm_rate * (level - 1)

        local equipId = {generalData.weapon_id, generalData.armor_id, generalData.horse_id, generalData.zuoji_id}
        for k, id in pairs(equipId) do 
            if id > 0 then 
                local item  = g_data.equipment[id]
                if item then
                    equipAttr.force.av = equipAttr.force.av + item.force 
                    equipAttr.intelligence.av = equipAttr.intelligence.av + item.intelligence 
                    equipAttr.political.av = equipAttr.political.av + item.political 
                    equipAttr.governing.av = equipAttr.governing.av + item.governing 
                    equipAttr.charm.av = equipAttr.charm.av + item.charm 
                else 
                    print("invalid equipment:", id)
                end 
            end 
        end
    end]]

    --dump(equipAttr)

    return equipAttr
end


function GodGeneralMode:getGeneralConfig()
    return self.configData
end

function GodGeneralMode:getGodGeneralConfig()
    return self.godConfigData
end

function GodGeneralMode:getGodGeneralConfigByRootId(rootId)
    return self.rootKeyVecForGod[rootId]
end

function GodGeneralMode:getGeneralConfigByRootId(rootId)
    return self.rootKeyVec[rootId]
end

--由神武将返回对应的普通武将
function GodGeneralMode:getCommonGenByGodId(godGenId)

end 

--获取化神的第三个条件 
function GodGeneralMode:getGodConditionInfo3(cdata)

    if nil == cdata then return end 
    
    --条件配置数据
    local conditionConfig = g_data.general_condition_type[cdata.condition]
    
    --条件
    local isCom = false --是否完成目标
    local comStr = "" --完成进度, 如 "6/9"
    local comDsc = g_tr(conditionConfig.desc) --描述
    local comPic = conditionConfig.condition_icon --对应的icon

    local build = conditionConfig.get_path

    --武器星级是否达到目标
    if conditionConfig.type == 1 then
        local weaponLv = 0
        --目前对应的普通武器信息
        local generalConfig = g_GeneralMode.getGeneralConfigByRootId(cdata.root_id)--获取普通武将的配置表
        local serverData = g_GeneralMode.getOwnedGeneralByOriginalId(generalConfig.general_original_id)
        
        if serverData then            
            weaponLv = g_data.equipment[serverData.weapon_id].star_level
        end
        --是否完成目标
        isCom = (weaponLv >= conditionConfig.para1)
        --完成进度
        comStr = string.format("%d/%d",weaponLv,conditionConfig.para1)

    --武将数量是否满足条件
    elseif conditionConfig.type == 2 then
        local wjNum = table.nums(g_GeneralMode.GetData())
        isCom = (wjNum >= conditionConfig.para1)
        comStr = string.format("%d/%d",wjNum,conditionConfig.para1)

    --建筑等级是否满足条件
    elseif conditionConfig.type == 3 then
        local buildConfigData = g_data.build[conditionConfig.para1]
        local originId = buildConfigData.origin_build_id 

        local buildLv = 0 
        --根据原型ID找到匹配的建筑数据中等级最高的一个（条件可能出现某个资源建筑）
        local buildServerData = g_PlayerBuildMode.FindBuild_high_OriginID(originId)       
        if buildServerData then
            buildLv = tonumber(buildServerData.build_level)
            isCom = ( buildLv >= buildConfigData.build_level)
        end
        comStr = string.format("%d/%d",buildLv,buildConfigData.build_level)

    --科技等级是否满足条件
    elseif conditionConfig.type == 4 then
        --科技条件配置数据
        local ScienceConfigData = g_data.science[conditionConfig.para1]
        --玩家当前科技的服务器数据
        local ScienceServerData = g_ScienceMode.GetScienceByOriginID(ScienceConfigData.science_type_id)

        local scienceLv = 0
        if ScienceServerData then
            --获取玩家当前科技配置信息获取等级
            local ScienceConfig1 = g_data.science[ScienceServerData.science_id]
            scienceLv = ScienceConfig1.level_id
            isCom = (scienceLv >= ScienceConfigData.level_id)            
        end
        comStr = string.format("%d/%d",scienceLv,ScienceConfigData.level_id)
    end
    
    local highMenu1Id = conditionConfig.menu_1
    local highMenu2Id = conditionConfig.menu_2
    
    return {isCom = isCom,comStr = comStr,comDsc = comDsc,comPic = comPic,build = build,hmenu1 = highMenu1Id,hmenu2 = highMenu2Id }
end

function GodGeneralMode:getBattleSkillFormula(data,skillIdx)
    local nData = data.ndata
    local cData = data.cdata
    
    --没有化神的武将 获取对应神武将的数据
    if cData.general_quality < g_GeneralMode.godQuality then
        cData = self:getGodGeneralConfigByRootId(cData.root_id)
        nData = nil
    end
    
    local skillId = 0
    if nData then
    	skillId = tonumber(nData["cross_skill_id_"..skillIdx])
    end
    
    if skillId == 0 then --返回nil 意味着该栏位没有任何技能
    	return nil
    end
    
    local battleSkillCfg = g_data.battle_skill[skillId]
    local skilllevel = 0
    local skillNextLevel = 1
    local level = 0
    
    --不包含装备加成的等级
    local skillOrginalLv = 0
    local skillNextOrginalLv = 1

    local allSxVar = {
        ["force"] = 0,
        ["intelligence"] = 0,
        ["political"] = 0,
        ["governing"] = 0,
        ["charm"] = 0,
    }
    
    local sx = self:initEquiptSx(cData.general_original_id)

    if sx then
        for key, var in pairs(sx) do
            allSxVar[key] = var.sv + var.av
        end
    end

    if nData then
        --sx = self:initEquiptSx(nData.general_id)
        if tonumber(nData.lv) > 0 then
            level = tonumber(nData.lv)
        end
        
        --城战技能实际等级受装备影响
        skilllevel = g_GeneralMode.getGenBattleSkillLv(nData, skillIdx) 
        if tonumber(nData["cross_skill_lv_"..skillIdx]) > 0 then
            skillOrginalLv = tonumber(nData["cross_skill_lv_"..skillIdx])
        end
        
        skillNextLevel = skilllevel + 1
        skillNextOrginalLv = skillOrginalLv + 1
    end
    
    local v1 = clone(allSxVar)
    v1.lv = level
    v1.skill_lv = skilllevel
    
    local nv1 = clone(allSxVar)
    nv1.lv = level
    nv1.skill_lv = skillNextLevel
    
--     local v1 = {
--        hero_wu = allSxVar.force,
--        hero_zhi = allSxVar.intelligence,
--        hero_zheng = allSxVar.political,
--        hero_tong = allSxVar.governing,
--        hero_mei = allSxVar.charm,
--        hero_lv = level,
--        skill_lv = skilllevel,
--    }
--
--    local nv1 = {
--        hero_wu = allSxVar.force,
--        hero_zhi = allSxVar.intelligence,
--        hero_zheng = allSxVar.political,
--        hero_tong = allSxVar.governing,
--        hero_mei = allSxVar.charm,
--        hero_lv = level,
--        skill_lv = skillNextLevel,
--    }

    g_custom_loadFunc("OperateAttackForce", "(v1,v2)", " return "..battleSkillCfg.client_formula)
    local num = externFunctionOperateAttackForce(v1)
    local num1 = externFunctionOperateAttackForce(nv1)
    
    local numValue = num
    dump(v1)
    local skillUpConfig = g_data.battle_skill_levelup
    local addNumStr = ""
    if skillUpConfig[skillNextOrginalLv] then
        local offset =  num1 - num
        if offset >= 0 then
            addNumStr = "(+".._fixOffset(offset)..")"
        else
            addNumStr = "(".._fixOffset(offset)..")"
        end
    end

    g_custom_loadFunc("FormulaBuff", "(v1)", " return "..battleSkillCfg.client_formula_2)
    local bnum = externFunctionFormulaBuff(v1)
    local bnum1 = externFunctionFormulaBuff(nv1)
    
    local buffNumValue = bnum
    
    local addBuffStr = ""
    if skillUpConfig[skillNextOrginalLv] and bnum1 and bnum then
        local offset =  bnum1 - bnum
        if offset >= 0 then
            addBuffStr = "(+".._fixOffset(offset)..")"
        else
            addBuffStr = "(".._fixOffset(offset)..")"
        end
    end
    
    if bnum then
        bnum = string.format("%.2f",bnum)
    end

    if bnum1 then
        bnum1 = string.format("%.2f",bnum1)
    end
    
    local rddsc1 = g_tr( battleSkillCfg.skill_description,{ num = num,buff = bnum } )
    local rddsc2 = g_tr( battleSkillCfg.skill_description,{ num = num1,buff = bnum1 } )
    
    rddsc1 = g_tr( battleSkillCfg.skill_description,{ num = num, numnext = addNumStr,buff = bnum,buffnext = addBuffStr} )
        
    local rddsc_org = g_tr( battleSkillCfg.skill_description,{ num = num, numnext = "",buff = bnum,buffnext = ""} )

    --描述skill_desc
    --技能名称 title
    --技能等级 level

    return { 
    skill_desc_org = rddsc_org,
    skill_desc = rddsc1,
    title = g_tr(battleSkillCfg.skill_name),
    level = skilllevel,
    v1 = numValue, --第一个值
    v2 = buffNumValue --第二个值
    }
end

--ndata 服务器数据
--cdata 配置表数据
function GodGeneralMode:getLevelFormula(data)
    
    local nData = data.ndata
    local cData = data.cdata
    --没有化神的武将 获取对应神武将的数据
    if cData.general_quality < g_GeneralMode.godQuality then
        cData = self:getGodGeneralConfigByRootId(cData.root_id)
        nData = nil
    end


    local zdxgCfg = g_data.combat_skill[cData.general_combat_skill]
    local wdxgCfg = g_data.duel_skill[cData.general_duel_skill]

    local skilllevel = 0
    local skillNextLevel = 1
    local level = 0
    
    --不包含装备加成的等级
    local skillOrginalLv = 0
    local skillNextOrginalLv = 1


    local allSxVar = {
        ["force"] = 0,
        ["intelligence"] = 0,
        ["political"] = 0,
        ["governing"] = 0,
        ["charm"] = 0,
    }
    
    local sx = self:initEquiptSx(cData.general_original_id)

    if sx then
        for key, var in pairs(sx) do
            allSxVar[key] = var.sv + var.av
        end
    end

    if nData then
        --sx = self:initEquiptSx(nData.general_id)
        if tonumber(nData.lv) > 0 then
            level = tonumber(nData.lv)
        end
        
        --技能实际等级受装备影响
        skilllevel = g_GeneralMode.getGenSkillLv(nData)
        
        if tonumber(nData.skill_lv) > 0 then
            skillOrginalLv = tonumber(nData.skill_lv)
        end
				
        skillNextLevel = skilllevel + 1
        skillNextOrginalLv = skillOrginalLv + 1
        
    end
    
    local base = zdxgCfg.base

    local duelFormula1 = function (lv)
        local var = wdxgCfg.base + lv * wdxgCfg.para1 + math.max(str,int) * wdxgCfg.para2
        return var
    end

    local duelFormula2 = function (lv)
        local var = wdxgCfg.base + lv * wdxgCfg.para1 + math.max(str,int) * wdxgCfg.para2
        return var
    end

    local duel_skill_type = 
    {
        [1] = duelFormula1,
        [2] = duelFormula2,
    } 

    --local typeVer = (zdxgCfg.num_type == 1) and 100 or 1

    g_custom_loadFunc( "formula","(lv,allSxVar)"," return " .. zdxgCfg.client_formula )

    local nowXg = externFunctionformula( skilllevel ,allSxVar )
    local nextXg = externFunctionformula( skillNextLevel ,allSxVar )

    
    --local dsc1 = g_tr(zdxgCfg.skill_description,{ num = zdxgCfg.num_type == 1 and string.format("%.2f",nowXg) .. "%%" or tostring(nowXg)})
    --local dsc2 = g_tr(zdxgCfg.skill_description,{ num = zdxgCfg.num_type == 1 and string.format("%.2f",nextXg) .. "%%" or tostring(nowXg)})
    
--    local ddsc1 = g_tr(wdxgCfg.skill_description)
--    local ddsc2 = g_tr(wdxgCfg.skill_description)

    local oDesc = g_tr(zdxgCfg.skill_description2)
    local oDuelDesco = g_tr(wdxgCfg.skill_description_preview)
        
        
        
        
    local function getSxRichStr(str)
        --if skilllevel > 0 then
            local richstr = (zdxgCfg.num_type == 1) and string.format( "|<#30,230,30#>%.2f%s|",str,"%%") or string.format( "|<#30,230,30#>%d|",str)
            return g_tr(zdxgCfg.skill_description,{ num = richstr })
        --else
            --return g_tr(zdxgCfg.skill_description2)
        --end
    end

    local rdsc1 = getSxRichStr(nowXg)
    local rdsc2 = getSxRichStr(nextXg)
    
    local skillUpConfig = g_data.general_skill_levelup
    local addStr = ""
    if skillUpConfig[skillNextOrginalLv] then
        local offset = nextXg - nowXg
        if offset >= 0 then
            addStr = "(+".._fixOffset(offset)..")"
        else
            addStr = "(".._fixOffset(offset)..")"
        end
    end
    --新的版本只用当前描述
    rdsc1 =  g_tr(zdxgCfg.skill_description,{ num = nowXg,numnext = addStr  })
    
    local rdsc1_org =  g_tr(zdxgCfg.skill_description,{ num = nowXg,numnext = ""  })


    --["force"] = 0,
    --["intelligence"] = 0,
    --["political"] = 0,
    --["governing"] = 0,
    --["charm"] = 0,

    local v1 = {
        hero_wu = allSxVar.force,
        hero_zhi = allSxVar.intelligence,
        hero_zheng = allSxVar.political,
        hero_tong = allSxVar.governing,
        hero_mei = allSxVar.charm,
        hero_lv = level,
        skill_lv = skilllevel,
    }

    local nv1 = {
        hero_wu = allSxVar.force,
        hero_zhi = allSxVar.intelligence,
        hero_zheng = allSxVar.political,
        hero_tong = allSxVar.governing,
        hero_mei = allSxVar.charm,
        hero_lv = level,
        skill_lv = skillNextLevel,
    }

    g_custom_loadFunc("OperateAttackForce", "(v1,v2)", " return "..wdxgCfg.client_formula)
    local num = math.ceil(externFunctionOperateAttackForce(v1))
    local num1 = math.ceil(externFunctionOperateAttackForce(nv1))
    
    local numValue = num

    dump(v1)
    local skillUpConfig = g_data.general_skill_levelup
    local addNumStr = ""
    if skillUpConfig[skillNextOrginalLv] then
        local offset =  num1 - num
        if offset >= 0 then
            addNumStr = "(+".._fixOffset(offset)..")"
        else
            addNumStr = "(".._fixOffset(offset)..")"
        end
    end

    g_custom_loadFunc("FormulaBuff", "(v1)", " return "..wdxgCfg.client_buff_formula)
    local bnum = externFunctionFormulaBuff(v1)
    local bnum1 = externFunctionFormulaBuff(nv1)
    
    local buffNumValue = bnum
    
    local addBuffStr = ""
    if skillUpConfig[skillNextOrginalLv] and bnum1 and bnum then
        local offset =  bnum1 - bnum
        if offset >= 0 then
            addBuffStr = "(+".._fixOffset(offset)..")"
        else
            addBuffStr = "(".._fixOffset(offset)..")"
        end
    end
    
    if bnum then
        bnum = string.format("%.2f",bnum)
    end
    
    

    if bnum1 then
        bnum1 = string.format("%.2f",bnum1)
    end
    
    local rddsc1 = g_tr( wdxgCfg.skill_description,{ num = num,buff = bnum } )
    local rddsc2 = g_tr( wdxgCfg.skill_description,{ num = num1,buff = bnum1 } )
    
    rddsc1 = g_tr( wdxgCfg.skill_description,{ num = num, numnext = addNumStr,buff = bnum,buffnext = addBuffStr} )
    
    local rddsc1_org = g_tr( wdxgCfg.skill_description,{ num = num, numnext = "",buff = bnum,buffnext = ""} )

    --g_custom_loadFunc("OperateAttackForce", "(v1, v2)", " return "..configData.client_formula)
    --return math.ceil(externFunctionOperateAttackForce(heroData_1, heroData_2)) --普通攻击伤害力(务必取整)


    --出征描述dsc1 dsc2
    --武斗描述ddsc1 ddsc2
    --效果rich显示文本  rdsc1 rddsc1
    --技能名称 title
    --技能等级 level

    dump(oDuelDesco)

    return { 
   	rdsc1_org = rdsc1_org,
    rdsc1 = rdsc1,
    rdsc2 = rdsc2,
    rddsc1_org = rddsc1_org,
    rddsc1 = rddsc1,
    rddsc2 = rddsc2,
    title = g_tr(zdxgCfg.skill_name),
    level = skilllevel,
    odesc = oDesc,
    odesc1 = oDuelDesco,--主动技能没有等级的时候的描述
    v1 = numValue,--第一个值
    v2 = buffNumValue --第二个值
    }

end

--神技能是否可升级红点
function GodGeneralMode:isGodSkillNeedTip(currentGeneral)
	local haveTip = false
	if currentGeneral.ndata == nil then
    return haveTip
	end
	
	if currentGeneral.ndata then
    local skillLv = 1
    skillLv = tonumber(currentGeneral.ndata.skill_lv)
    local iType = g_Consts.DropType.Props
    local iId = 51011
    local iNum = 0
    local count,needCount,isMaxLv = GodGeneralMode:getNeedSkillUpItemCount(skillLv)
    if not isMaxLv and count >= needCount and skillLv < currentGeneral.ndata.lv then
    	haveTip = true
    end
	end
	
	return haveTip
	
end

function GodGeneralMode:isBattleSkillNeedTip(currentGeneral)
	local haveTip = false
	if currentGeneral.ndata == nil then
    return haveTip
	end
	
	local tipIdxList = {}
	
	if currentGeneral.ndata then
    for i=1, 3 do
    	local battleSkillId = tonumber(currentGeneral.ndata["cross_skill_id_"..i])
	    if battleSkillId > 0 then --该栏位有技能
	      local skillLv = 1
	      skillLv = tonumber(currentGeneral.ndata["cross_skill_lv_"..i])
	      local count,needCount,isMaxLv,itemDropInfo = GodGeneralMode:getNeedBattleSkillUpItemCount(skillLv)
	      if not isMaxLv and count >= needCount --[[and skillLv < currentGeneral.ndata.lv]] then --新需求城战技能不再有武将等级限制
	      	haveTip = true
	      	tipIdxList[#tipIdxList + 1] = i
	      end
    	end
    end
	end
	
	return haveTip,tipIdxList
end


--武将技能是否可升
function GodGeneralMode:getNeedSkillUpItemCount(skillLv)
    local skillUpConfig = g_data.general_skill_levelup
    --达到最高登基
    if skillUpConfig[tonumber(skillLv) + 1] == nil then return -1,-1,true end

    local nextSkillLv = skillLv + 1
    local itemId = 51011
    local itemCount = g_BagMode.findItemNumberById(itemId)
    local itemNeedCount = skillUpConfig[nextSkillLv].general_skill_exp
    return itemCount,itemNeedCount,false
end

--武将城战技能是否可升
function GodGeneralMode:getNeedBattleSkillUpItemCount(skillLv)
    local skillUpConfig = g_data.battle_skill_levelup
    --达到最高登基
    if skillUpConfig[tonumber(skillLv) + 1] == nil then
    	local itemNeedCfg = skillUpConfig[skillLv].consume
    	local itemId = itemNeedCfg[1][2]
    	local itemDropInfo = itemNeedCfg[1]
      return -1,-1,true,itemDropInfo 
    end

    local nextSkillLv = skillLv + 1
    local itemNeedCfg = skillUpConfig[nextSkillLv].consume
    local itemId = itemNeedCfg[1][2]
    local itemCount = g_BagMode.findItemNumberById(itemId)
    local itemNeedCount = itemNeedCfg[1][3]
    local itemDropInfo = itemNeedCfg[1]
    return itemCount,itemNeedCount,false,itemDropInfo
end


--获取升星消耗材料
function GodGeneralMode:getStarUpConsume(serverData) 
    local mat_s --下一等级消耗, 0--15级
    local mat_b --下一星级消耗, 1--4星
    local mat_info --材料信息 --供满级时显示用
    for k, v in pairs(g_data.general_star) do 
        if v.general_original_id == serverData.general_id and v.star == serverData.star_lv then 
            if v.star < 15 then 
                mat_s = g_data.general_star[k+1].consume[1]

                local endIdx = k + 5*(math.floor(v.star/5)+1) - v.star 
                local needCount = 0 
                for i = k+1, endIdx do 
                    needCount = needCount + g_data.general_star[i].consume[1][3]
                end 
                mat_b = {mat_s[1], mat_s[2], needCount} 
                
                mat_info = mat_s 
            else 
                mat_info = g_data.general_star[k].consume[1]
            end 
            break 
        end 
    end 

    return mat_s, mat_b, mat_info
end 


--是否可化神
function GodGeneralMode:canToGod(data)

    if nil == data or nil == data.cdata then 
        return false 
    end 

    local cdata = data.cdata 
    if cdata.general_quality < g_GeneralMode.godQuality then --如果是普通武将,需要找到对应神武将配置
        cdata = g_GeneralMode.getGodGeneralConfigByRootId(cdata.root_id) 
    end 

    if cdata then 
        --信物条件
        local xw_id = cdata.consume[1][2]
        local xw_need = cdata.consume[1][3]
        local xw_own = g_BagMode.findItemNumberById(xw_id) 
        if xw_own < xw_need then 
            return false 
        end 

        --武将条件
        local common_gen = GodGeneralMode:getGeneralConfigByRootId(cdata.root_id ) --对应的普通武将
        local common_own = g_GeneralMode.getOwnedGeneralByOriginalId(common_gen.general_original_id)
        if nil == common_own then 
            return false 
        end 
        
        --其他条件
        local comTb = GodGeneralMode:getGodConditionInfo3(cdata) 

        return comTb.isCom 
    end 
end 

--是否可升级
function GodGeneralMode:canLevelup(serverData)
    if nil == levelUpMats then 
        levelUpMats = {}
        for _, v in pairs(g_data.item) do
            if v.item_original_id == g_Consts.UseItemType.GodGenerralExp then 
                table.insert(levelUpMats, v)
            end 
        end
    end 

    local canAddExp = false 
    local totleExpMax = g_data.general_exp[table.nums(g_data.general_exp)].general_exp --最大等级对应经验
    if serverData and serverData.exp < totleExpMax then 

        local needExp = 0 
        local curLv = GodGeneralMode:getGenLevelByExp(serverData.exp) 
        local cfg2 = g_data.general_exp[curLv+1]  
        if cfg2 then 
            needExp = cfg2.general_exp - serverData.exp 
        end 

        local hasExp = 0 
        for k, v in pairs(levelUpMats) do 
            local count = g_BagMode.findItemNumberById(v.id) 
            if count > 0 then 
                local dropId = g_data.item[v.id].drop[1]
                local dropConfig = g_data.drop[dropId].drop_data[1]
                local perExp = dropConfig[3]
                hasExp = hasExp + perExp * count

                if hasExp >= needExp then 
                    canAddExp = true 
                    break 
                end 
            end 
        end 
    end 

    return canAddExp 
end 

--是否可升星
function GodGeneralMode:canStarup(serverData)
    --府衙等级>12级时开放升星功能
    local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
    if mainCityLevel >= tonumber(g_data.starting[106].data) then 
        if serverData then 
            local mat_s, _ = GodGeneralMode:getStarUpConsume(serverData) 
            if mat_s then 
                local ownCount = g_BagMode.findItemNumberById(mat_s[2]) 
                return ownCount >= mat_s[3] 
            end 
        end 
    end 
    
    return false 
end 


function GodGeneralMode:canXiLian(serverData)
    if serverData == nil then return end
    local openEmptySkill = false --是否存在解锁的空技能槽
    local clientStar = math.floor(tonumber(serverData.star_lv)/5) + 1
    for i = 1, 3 do
        local needStar = (i + 1)
        if clientStar >= needStar then --栏位已解锁
            local battleSkillId = tonumber(serverData["cross_skill_id_"..i])
            if battleSkillId <= 0 then
                openEmptySkill = true
                break
            end
        end
    end


    local timeTb = string.split(g_playerInfoData.GetData().skill_wash_date,"-")
    local time = os.time({ day = tonumber(timeTb[3]), month = tonumber(timeTb[2]), year = tonumber(timeTb[1]), hour = 0, minute = 0, second = 0}) or 0
    local isFree = not g_clock.isSameDay(time,g_clock.getCurServerTime())
    local isItem = g_PlayerMode.getXuanTie() >= g_data.cost[10026].cost_num

    local openLv = tonumber(g_data.starting[111].data)
    local mainCityLevel = g_PlayerBuildMode.getMainCityBuilding_lv()
    local isOpen = (mainCityLevel >= openLv)


    return ( isItem or isFree ) and openEmptySkill and isOpen

end


--当前拥有的武将是否可化神/升级/升星/升技能
function GodGeneralMode:isShowRP(data)
    
    if nil == data.cdata then return false end

    if data.cdata.general_quality >= g_GeneralMode.godQuality then --是神武将
        if data.ndata then --拥有
            if GodGeneralMode:canLevelup(data.ndata) 
                or GodGeneralMode:canStarup(data.ndata)
                or GodGeneralMode:isGodSkillNeedTip(data)
                or GodGeneralMode:isBattleSkillNeedTip(data)
                or GodGeneralMode:canXiLian(data.ndata) then
                return true 
            else 
                return false 
            end 
        else --未拥有,则检测是否可化神
            return GodGeneralMode:canToGod(data)
        end 

    else --普通武将,检测是否可化神
        return GodGeneralMode:canToGod(data)
    end 
end 


--气泡:可化神/升级/升星/技能
function GodGeneralMode:isShowBubble()

    local generals = g_GeneralMode.getOwnedGenerals()
    local tb = {}

    for key, var in pairs(generals) do
        local config = g_data.general[tonumber(var.general_id .. "01")]
        --查找神武将或者可以化神的当前武将
        if config.condition > 0 then
            table.insert( tb,{ ndata = var,cdata = config } )
        end
    end

    for k, v in ipairs(tb) do 
        if self:isShowRP(v) then 
            return true
        end 
    end

    return false
   
end

function GodGeneralMode:getSkillBorderRes(skillLv)
    local skillBorderRes = 
    {
        1010013, -- 1 - 10
        1010014, -- 11 - 20
        1010015, -- 21 - 30
        1010016, -- 31 - 40
        1010017, -- 41 - 50
    }

    local resPath = ""

    if skillLv < 10 then
        resPath = g_resManager.getResPath(skillBorderRes[1])
    elseif skillLv >= 10 and skillLv < 20 then
        resPath = g_resManager.getResPath(skillBorderRes[2])
    elseif skillLv >= 20 and skillLv < 30 then
        resPath = g_resManager.getResPath(skillBorderRes[3])
    elseif skillLv >= 30 and skillLv < 40 then
        resPath = g_resManager.getResPath(skillBorderRes[4])
    elseif skillLv >= 40 and skillLv <= 50 then
        resPath = g_resManager.getResPath(skillBorderRes[5])
    end

    return resPath
end





function GodGeneralMode:getGodGenListData()
    local data = {}
    local godGeneralConfig = self:getGodGeneralConfig() --所有已开放神武将
    for key, var in pairs(godGeneralConfig) do
        local ndata = g_GeneralMode.getOwnedGeneralByOriginalId(var.general_original_id) --玩家拥有
        --if ndata then
        table.insert(data,{cdata = var,ndata = ndata})
        --end
    end

    table.sort( data,function (a,b)
        local Anum = tonumber(a.cdata.id) + (a.ndata and 10000000 or 0)
        local Bnum = tonumber(b.cdata.id) + (b.ndata and 10000000 or 0)

        return Anum > Bnum
    end )

    return data 
end 

--满足条件则添加动画
function GodGeneralMode:addToGodAnim(node, isSatisfied) 
    node:removeChildByTag(123)
    if isSatisfied then 
        local armature, animation = g_gameTools.LoadCocosAni(
            "anime/Effect_HuaShenNewAnNiu/Effect_HuaShenNewAnNiu.ExportJson"
            , "Effect_HuaShenNewAnNiu"
        )
        armature:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
        armature:setTag(123)
        node:addChild(armature)
        animation:play("Animation1")
    end 
end 

--可升级箭头动画
function GodGeneralMode:addCanLevelupAnim(node)
    if nil == node:getChildByTag(100) then 
        local armature, animation = g_gameTools.LoadCocosAni(
            "anime/Effect_JingYanTiaoJianTou/Effect_JingYanTiaoJianTou.ExportJson"
            , "Effect_JingYanTiaoJianTou"
        )
        armature:setPosition(cc.p(0, 0))
        armature:setTag(100)
        node:addChild(armature)
        animation:play("Animation1") 
    end 
end 

--升级动画
function GodGeneralMode:addLevelupSuccessAnim(node, pos)
    local armature , animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            armature:removeFromParent()
        end
    end 
  
    armature, animation = g_gameTools.LoadCocosAni(
        "anime/Effect_HuaShenKaPaiShengJi/Effect_HuaShenKaPaiShengJi.ExportJson"
        , "Effect_HuaShenKaPaiShengJi"
        , onMovementEventCallFunc
    )

    armature:setPosition(pos or cc.p(0, 0))
    node:addChild(armature)
    animation:play("XuLie")
end 

function GodGeneralMode:addCanStarEnhanceAnim(node, canEnhance)
    if node:getChildByTag(100) then 
        node:removeChildByTag(100) 
    end 

    if canEnhance then 
        local armature, animation = g_gameTools.LoadCocosAni(
            "anime/Effect_TiShengNewAnNiu/Effect_TiShengNewAnNiu.ExportJson"
            , "Effect_TiShengNewAnNiu"
        )
        armature:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
        armature:setTag(100)
        node:addChild(armature)
        animation:play("Animation1") 
    end 
end 

--升星成功武将后面动画
function GodGeneralMode:addGenBgAnim(node) 
    node:removeChildByTag(123)

    local armature, animation = g_gameTools.LoadCocosAni(
        "anime/Effect_JiuGuangBeiJing/Effect_JiuGuangBeiJing.ExportJson"
        , "Effect_JiuGuangBeiJing"
    )
    armature:setPosition(cc.p(0, 0))
    armature:setTag(123)
    node:addChild(armature)
    animation:play("Animation1")
end 

--星级小提升文字动画
function GodGeneralMode:addStarLvupTextAnim(node, pos) 
    if nil == node then return end 

    local armature , animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            armature:removeFromParent()
        end
    end 
  
    armature, animation = g_gameTools.LoadCocosAni(
        "anime/Effect_ShenWuJianUiText/Effect_ShenWuJianUiText.ExportJson"
        , "Effect_ShenWuJianUiText"
        , onMovementEventCallFunc
    )

    armature:setPosition(pos or cc.p(0, 0))
    node:addChild(armature)
    animation:play("Effect_TiShengChengGongText") 
end 


function GodGeneralMode:addToGodSuccessMaskAnim(node) 

    local size = node:getContentSize()

    --遮挡层
    local lyout = ccui.Layout:create()
    lyout:setSize( size )
    lyout:setTouchEnabled(true)

    local armature , animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            lyout:removeFromParent()
            armature:removeFromParent()
        end
    end 
  
    armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_WuJiangHuaShenMask/Effect_WuJiangHuaShenMask.ExportJson"
        , "Effect_WuJiangHuaShenMask"
        , onMovementEventCallFunc
    )
    armature:setPosition(cc.p(size.width/2, size.height/2 + 9))
    node:addChild(armature)
    node:addChild(lyout)
    animation:play("Animation1") 
end 

--化神成功动画
function GodGeneralMode:addToGodSuccessAnim(node, commonCdata, godCdata) 
    --背景
    GodGeneralMode:addToGodSuccessMaskAnim(node)

    --化神动画
    local armature, animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            armature:removeFromParent()
            g_guideManager.execute()
        end
    end

    local function onFrameEventCallFunc(bone , frameEventName , originFrameIndex , currentFrameIndex)
        if frameEventName == "ChuXian" then
            local bone = armature:getBone("ShenWuJian")
            armature:getBone("Wujian"):setVisible(false)
            bone:setVisible(true)
            local bone = armature:getBone("Wujian")
            local image = ccui.ImageView:create(g_resManager.getResPath(godCdata.general_big_icon))
            image:setPosition(cc.p(0, 30))
            bone:addDisplay( image,0 )
        end
    end

    armature, animation = g_gameTools.LoadCocosAni("anime/Effect_WuJiangHuaShen/Effect_WuJiangHuaShen.ExportJson", 
                                                    "Effect_WuJiangHuaShen", 
                                                    onMovementEventCallFunc,
                                                    onFrameEventCallFunc)
    armature:setPosition(cc.p(680, 325))
    node:addChild(armature)

    local bone = armature:getBone("Wujian")
    local image = ccui.ImageView:create(g_resManager.getResPath(commonCdata.general_big_icon))
    image:setPosition(cc.p(0, 0))
    bone:addDisplay( image,0 )

    animation:play("Animation1")    
end 

function GodGeneralMode:getGenLevelByExp(exp) 
    local len = #g_data.general_exp
    for i = 1, len do 
        if g_data.general_exp[i].general_exp > exp then 
            return math.max(1, g_data.general_exp[i].general_level - 1)
        elseif g_data.general_exp[i].general_exp == exp then
            return g_data.general_exp[i].general_level 
        end 
    end 

    return g_data.general_exp[len].general_level  
end 

--依次上浮多行文字,默认绿色
function GodGeneralMode:toastStrArray(node, strArray, color, position)
    if nil == node or nil == strArray or #strArray == 0 then 
        return 
    end 

    local lbText, move, action 
    local pos = position or cc.p(640, 400) 
    local strColor = color or cc.c3b( 30,230,30 )
    local count = 0 
    local countMax = #strArray 
    for k, str in pairs(strArray) do        
        lbText = ccui.Text:create(str, "cocostudio_res/simhei.ttf", 32) 
        node:addChild(lbText)
        lbText:setPosition(cc.p(pos.x, pos.y-count*36-70))
        lbText:setTextColor(strColor)
        lbText:setOpacity(0)
        move = cc.Spawn:create(cc.FadeTo:create(0.2*count, 255), cc.MoveBy:create(0.2,cc.p(0, 70)))
        action = cc.Sequence:create(cc.DelayTime:create(count*0.1), move, cc.DelayTime:create(0.5),cc.FadeOut:create(1.0+(countMax-count)*0.1), cc.RemoveSelf:create())        
        lbText:runAction(action) 
        count = count + 1 
    end 
end 

function GodGeneralMode:toastGenBaseAttrChanged(node, pos, baseAttrOld, baseAttrNew)
    local strArray = {}
    local val 
    for i=1, 5 do 
        val = baseAttrNew[i] - baseAttrOld[i]
        if val > 0 then 
            table.insert(strArray, g_tr("attr"..i).." +"..val)
        end 
    end 
    GodGeneralMode:toastStrArray(node, strArray, nil, pos)
end 


return GodGeneralMode
