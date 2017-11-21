--g_GeneralMode
local GeneralDataMode = {}
setmetatable(GeneralDataMode,{__index = _G})
setfenv(1, GeneralDataMode)

--神武将
godQuality = 6
--local general_quality

local baseData = nil
local keyOwnGenerals = {} --以general_original_id为key的服务器武将数据列表
local generalConfigs = {} --配置表数据
local godGeneralConfigs = {}--配置表数据
local orginalGroupConfigs = {} --配置表数据

--装备
local function _getAllEquipProperty(equipmentDatas)
	local result = {0,0,0,0,0}
	for key, equipData in pairs(equipmentDatas) do
		result[1] = result[1] + equipData.force
		result[2] = result[2] + equipData.intelligence
		result[3] = result[3] + equipData.governing
		result[4] = result[4] + equipData.charm
		result[5] = result[5] + equipData.political
	end
	return result
end

for key, var in pairs(g_data.general) do
	if var.general_quality == godQuality then
	   godGeneralConfigs[var.root_id] = var
	else
	   generalConfigs[var.root_id] = var
	end
	
	orginalGroupConfigs[var.general_original_id] = var
end

--更新显示
function NotificationUpdateShow()
	
end

function getGeneralConfigByRootId(rootId)
  return generalConfigs[rootId]
end

function getGodGeneralConfigByRootId(rootId)
  return godGeneralConfigs[rootId]
end

function getOwnedGeneralByOriginalId(originalId)
	return keyOwnGenerals[originalId]
end

function getGeneralByOriginalId(originalId)
	return orginalGroupConfigs[originalId]
end

function getOwnedGenerals()
  return keyOwnGenerals
end

function SetData(data)
	baseData = data
	
	keyOwnGenerals = {}
	for key, generalInfo in pairs(baseData) do
	  keyOwnGenerals[generalInfo.general_id] = generalInfo --服务器发送的generalInfo.general_id 为general_original_id
  end
  
  g_PlayerPubMode.checkHaveStarReward()
end

--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.PlayerGeneral)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerGeneral",}},onRecv)
	return ret
end

--得到武将所有信息,只可使用不可修改
function GetData()
	if(baseData == nil)then
		RequestData()
	end
	return baseData
end

function getGeneralById(gid)
	local data = GetData()

	for k, v in pairs(data) do 
		if v.general_id == gid then 
			return v
		end 
	end 

	return nil
end

function GetBasicInfo(gid, lv)
	local l = lv
	if tonumber(lv) < 10 then
		l = "0"..lv
	end
	local index = tonumber(gid..l)
	assert(g_data.general[index],index)
	return g_data.general[index]
end

function getSameGenerals(generalId)
	local tbl = {}
	local data = GetData()
	for k, v in pairs(data) do 
		if v.general_id == generalId then 
			table.insert(tbl, v)
		end 
	end 

	return tbl 
end



--[id] => Integer (25959)
--[general_id] => Integer (20022)
--[exp] => Integer (0)
--[lv] => Integer (1)
--[star_lv] => Integer (0)
--[weapon_id] => Integer (1008400)
--[armor_id] => Integer (0)
--[horse_id] => Integer (0)
--[zuoji_id] => Integer (0)
--[skill_lv] => Integer (0)
--[build_id] => Integer (0)
--[army_id] => Integer (0)
--[force_rate] => Integer (0)
--[intelligence_rate] => Integer (0)
--[governing_rate] => Integer (0)
--[charm_rate] => Integer (0)
--[political_rate] => Integer (0)
--[stay_start_time] => Integer (0)
--[cross_skill_id_1] => Integer (0)
--[cross_skill_lv_1] => Integer (0)
--[cross_skill_id_2] => Integer (0)
--[cross_skill_lv_2] => Integer (0)
--[cross_skill_id_3] => Integer (0)
--[cross_skill_lv_3] => Integer (0)
--[status] => Integer (0)

local function _createDefaultServerData(generalId)
	local serverData = {}
	
	serverData["id"] = 0
	serverData["general_id"] = generalId
	serverData["exp"] = 0
	serverData["lv"] = 1
	serverData["star_lv"] = 1
	serverData["weapon_id"] = 0
	serverData["armor_id"] = 0
	serverData["horse_id"] = 0
	serverData["zuoji_id"] = 0
	serverData["skill_lv"] = 0
	serverData["build_id"] = 0
	serverData["army_id"] = 0
	serverData["force_rate"] = 0
	serverData["intelligence_rate"] = 0
	serverData["governing_rate"] = 0
	serverData["charm_rate"] = 0
	serverData["political_rate"] = 0
	serverData["stay_start_time"] = 0
	serverData["cross_skill_id_1"] = 0
	serverData["cross_skill_lv_1"] = 0
	serverData["cross_skill_id_2"] = 0
	serverData["cross_skill_lv_2"] = 0
	serverData["cross_skill_id_3"] = 0
	serverData["cross_skill_lv_3"] = 0
	serverData["status"] = 0
	
	return serverData
end

--根据武将orginal_id 数据获得武将当前星级的5属性（不包含装备属性）
--generalId为orginal_id
--isIncludedBuff是否计算buff加成部分
function getGeneralPropertyByGeneralId(generalId,isIncludedBuff)
	if isIncludedBuff == nil then
		isIncludedBuff = true
	end

	local serverData = getGeneralById(generalId)
	if serverData == nil then
		serverData = _createDefaultServerData(generalId)
	end
	return getGeneralPropertyByServerData(serverData,isIncludedBuff)
end

--根据服务器武将数据获得武将当前星级的5属性（不包含装备属性）
--generalData为服务器武将数据
--isIncludedBuff是否计算buff加成部分
function getGeneralPropertyByServerData(generalData,isIncludedBuff)
	
	if isIncludedBuff == nil then
		isIncludedBuff = true
	end
	
	local config = getGeneralByOriginalId(generalData.general_id)
	local force = config.general_force
	local intelligence = config.general_intelligence
	local governing = config.general_governing
	local charm = config.general_charm
	local political = config.general_political
	
	--原始值+general_force_growth*(武将等级-1）
	local final_force = force + generalData.force_rate *(generalData.lv - 1)
	local final_intelligence = intelligence + generalData.intelligence_rate *(generalData.lv - 1)
	local final_governing = governing + generalData.governing_rate *(generalData.lv - 1)
	local final_charm = charm + generalData.charm_rate *(generalData.lv - 1)
	local final_political = political + generalData.political_rate *(generalData.lv - 1)
	
	if isIncludedBuff == true then
		local buildPosition = nil
		final_force = g_BuffMode.calculateFinalValueByBuffKeyName(final_force,"general_force_inc",buildPosition)
		final_intelligence = g_BuffMode.calculateFinalValueByBuffKeyName(final_intelligence,"general_intelligence_inc",buildPosition)
		final_governing = g_BuffMode.calculateFinalValueByBuffKeyName(final_governing,"general_governing_inc",buildPosition)
		final_charm = g_BuffMode.calculateFinalValueByBuffKeyName(final_charm,"general_charm_inc",buildPosition)
		final_political = g_BuffMode.calculateFinalValueByBuffKeyName(final_political,"general_political_inc",buildPosition)
	end
	
	return {final_force,final_intelligence,final_governing,final_charm,final_political}
end

--根据武将orginal_id 数据获得武将当前星级的5属性（包含装备属性）
function getAllGeneralPropertyByGeneralId(generalId)
	local serverData = getGeneralById(generalId)
	if serverData == nil then
		serverData = _createDefaultServerData(generalId)
	end
	return getAllGeneralPropertyByServerData(serverData)
end

--根据武将ServerData获得武将所有装备和武将本身的5属性(包含装备属性)
function getAllGeneralPropertyByServerData(generalData)
	local equipProps = getAllEquipmentProperty(generalData)
	local generalProps = getGeneralPropertyByServerData(generalData)
	local ret = {}
	for i = 1, 5 do
		ret[i] = equipProps[i] + generalProps[i]
	end
	return ret
end

--获得武将所有装备的5属性，传服务器的generalData
function getAllEquipmentProperty(generalData)

	local equipData = g_data.equipment[generalData.weapon_id]
	local horseData = g_data.equipment[generalData.horse_id]
	local armorData = g_data.equipment[generalData.armor_id]
	local zuoJiData = g_data.equipment[generalData.zuoji_id]

	local proList = _getAllEquipProperty({equipData, horseData, armorData,zuoJiData})
	return proList
end



--获取武将buff,generalData为服务器数据
function getPlayerBuffValue(buildId, generalData)

	local result = {}
	--武将信息
	local gData = getGeneralByOriginalId(generalData.general_id)
	--建筑信息
	local bData = g_data.build[buildId]
	local equipmentDatas = {
		g_data.equipment[generalData.weapon_id],
		g_data.equipment[generalData.horse_id],
		g_data.equipment[generalData.armor_id],
		g_data.equipment[generalData.zuoji_id],
	  }

	--计算当前建筑的主属性
	local proList = _getAllEquipProperty(equipmentDatas)
	local generalProList = getGeneralPropertyByServerData(generalData)
	local property = generalProList[bData.need_general_attribute] + proList[bData.need_general_attribute]
--	if bData.need_general_attribute == 1 then
--		property = gData.general_force + proList[1]
--	elseif bData.need_general_attribute == 2 then
--		property = gData.general_intelligence + proList[2]
--	elseif bData.need_general_attribute == 3 then
--		property = gData.general_governing + proList[3]
--	elseif bData.need_general_attribute == 4 then
--		property = gData.general_charm + proList[4]
--	elseif bData.need_general_attribute == 5 then
--		property = gData.general_political + proList[5]
--	end

	for i=1, #bData.output do
		if bData.output_buff_id == g_data.output_type[bData.output[i][1]].buff_id then
			local buffData = g_data.buff[bData.output_buff_id]
			result[bData.output[i][1]] = property * bData.ratio
			if buffData.buff_type == 1 or buffData.buff_type == 2  then
				result[bData.output[i][1]] = result[bData.output[i][1]]/10000
			end

			--装备加成值
			for key, equipData in pairs(equipmentDatas) do
				  for j=1, #equipData.equip_skill_id do
					for k=1, #g_data.equip_skill[equipData.equip_skill_id[j]].skill_buff_id do
						if g_data.equip_skill[equipData.equip_skill_id[j]].skill_buff_id[k] == g_data.output_type[bData.output[i][1]].buff_id then
							if g_data.output_type[bData.output[i][1]].plus_type == 1 then
								result[bData.output[i][1]] = result[bData.output[i][1]] + g_data.equip_skill[equipData.equip_skill_id[j]].num/10000
							elseif g_data.output_type[bData.output[i][1]].plus_type == 2 then
							  result[bData.output[i][1]] = result[bData.output[i][1]] + g_data.equip_skill[equipData.equip_skill_id[j]].num/10000
							elseif g_data.output_type[bData.output[i][1]].plus_type == 3 then
								result[bData.output[i][1]] = result[bData.output[i][1]] + g_data.equip_skill[equipData.equip_skill_id[j]].num
							end
						end
					end
				end
			end

			if result[bData.output[i][1]] ~= nil and g_data.output_type[bData.output[i][1]].plus_type == 1 then
				result[bData.output[i][1]] = result[bData.output[i][1]] * bData.output[i][2]
			end
		end
	end

	--这里不需要取整操作 会影响最终的值
--	for key, value in pairs(result) do
--		value = math.floor(value)
--	end

	return result
end

--未驻守的武将数
function getIdleResidenceGenCount()
	local count = 0 
	local data = GetData()
	if data then 
		for k, v in pairs(data) do 
			if v.build_id == 0 then 
				count = count + 1
			end 
		end 
	end 

	return count 
end 

--当前是否有武将可允许佩带装备
function canEquipForGeneral()
	local gen = GetData()
	if nil == gen then 
		return false 
	end 

	local equip = g_EquipmentlMode.GetData()
	if nil == equip then 
		return false 
	end 
  
	local noArmy = false 
	local noAccessory = false 
	local noZuoji = false 
	local genId1, genId2, genId3 
	local general 
	for k, v in pairs(gen) do 
		if v.armor_id == 0 then 
			noArmy = true 
			genId1 = 100*v.general_id + 1 
		end 

		if v.horse_id == 0 then 
			noAccessory = true 
			genId2 = 100*v.general_id + 1
		end 

		general = g_data.general[100*v.general_id+1] 
		if v.zuoji_id == 0 and general and general.general_quality == g_GeneralMode.godQuality then 
			noZuoji = true 
			genId3 = 100*v.general_id + 1 
		end 

		if noArmy and noAccessory and noZuoji then 
		  break 
		end 
	end 

	local hasIdleArmy = false 
	local hasIdleAccessory = false 
	local hasIdleZuoji = false 
	local item 
	for k, v in pairs(equip) do 
		item = g_data.equipment[v.item_id]
		if item then 
			if item.equip_type == 2 then 
				hasIdleArmy = true 
			elseif item.equip_type == 3 then 
				hasIdleAccessory = true 
			elseif item.equip_type == 4 then 
				hasIdleZuoji = true 
			end 

			if hasIdleArmy and hasIdleAccessory and hasIdleZuoji then 
				break 
			end 
		end 
	end 

	if noArmy and hasIdleArmy then 
		return true, genId1 
	end 

	if noAccessory and hasIdleAccessory then 
		return true, genId2 
	end 

	if noZuoji and hasIdleZuoji then 
		return true, genId3
	end 

	return false 
end 

--根据武将数据,返回真实的(神)技能等级
function getGenSkillLv(serverGenData) 
	local skillLv = serverGenData.skill_lv 

	if serverGenData.weapon_id and serverGenData.weapon_id > 0 then 
		local item = g_data.equipment[serverGenData.weapon_id]  
		if item and item.combat_skill_id > 0 then 
			skillLv = skillLv + item.skill_level 
		end 
	end 
	

	return skillLv 
end 

--根据武将数据,返回真实的城战技能等级, index 对应第几个槽位
function getGenBattleSkillLv(serverGenData, index) 
  local tbl_id = {serverGenData.cross_skill_id_1, serverGenData.cross_skill_id_2, serverGenData.cross_skill_id_3}
  local tbl_lv = {serverGenData.cross_skill_lv_1, serverGenData.cross_skill_lv_2, serverGenData.cross_skill_lv_3}

  local level = tbl_lv[index] or 1 
	local equId = {serverGenData.armor_id, serverGenData.horse_id, serverGenData.zuoji_id}	
	for k, id in pairs(equId) do 
		if id > 0 then 
			local item = g_data.equipment[id]
			if item and item.battle_skill_id > 0 and item.battle_skill_id == tbl_id[index] then --加成的城战技能等级
				level = level + item.skill_level 
			end 
		end 
	end 

	return level 
end 

return GeneralDataMode
