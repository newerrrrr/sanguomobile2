
local SmithyData = class("SmithyData")

SmithyData.viewType = g_gameTools.enum({"None", "Advance", "Recast", "Decompose", "Compose"})
SmithyData.listSelectType = g_gameTools.enum({"Single", "Mulitiple"})


function SmithyData:instance()
  if nil == SmithyData._instance then 
    SmithyData._instance = SmithyData.new()
  end 

  return SmithyData._instance 
end 

--返回所有相同系列的道具
function SmithyData:getSameSeriesItems(itemId)
  local tbl = {}
  if itemId and g_data.item[itemId] then 
    local rootId = g_data.item[itemId].item_original_id 
    for k, v in pairs(g_data.item) do 
      if v.item_original_id == rootId then 
        table.insert(tbl, v)
      end 
    end 
  end 

  if #tbl > 1 then 
    table.sort(tbl, function(a, b) return a.id < b.id end)
  end 

  local index 
  for k, v in pairs(tbl) do 
    if v.id == itemId then 
      index = k 
    end 
  end 

  return tbl, index 
end 


function SmithyData:sort(tbl, idx_s, idx_e, sortFunc)
  if idx_e - idx_s < 1 then
    return 
  end 

  for i = idx_s, idx_e-1 do 
    local k = i 
    for j=i+1, idx_e do 
      if sortFunc(tbl[k], tbl[j]) then 
        k = j 
      end 
    end 

    if k > i then
      local tmp = tbl[k]
      tbl[k] = tbl[i]
      tbl[i] = tmp
    end 
  end 
end 

--排序武将
function SmithyData:sortGenerals(tbl)
  --1.按是否可进阶排序
  table.sort(tbl, function(a, b) return a._canAdvanced and not b._canAdvanced end)

  --2.按品质排序
  local function sortFuncByQuality(a, b)
    return g_data.general[a.general_id*100+1].general_quality < g_data.general[b.general_id*100+1].general_quality
  end 

  local idx_s = 1
  local idx_e = #tbl  
  if idx_e < idx_s + 1 then 
    return 
  end 
  local preType = tbl[idx_s]._canAdvanced
  for i=idx_s+1, idx_e do
    local curType = tbl[i]._canAdvanced
    if i < idx_e then
      if curType ~= preType then
        self:sort(tbl, idx_s, i-1, sortFuncByQuality)
        idx_s = i
        preType = curType
      end 
    else 
      if curType ~= preType then
        self:sort(tbl, idx_s, i-1, sortFuncByQuality)
      else
        self:sort(tbl, idx_s, i, sortFuncByQuality)
      end
    end
  end
end 

--带装备的武将
function SmithyData:getGeneralWithEquip()
  local generals = {}  

  local data = g_GeneralMode.GetData()
  for k, v in pairs(data) do 
    if v.weapon_id > 0 or v.armor_id > 0 or v.horse_id > 0 or v.zuoji_id > 0 then
      --判断佩戴的装备是否可进阶
      v._canAdvanced = false 
      v._canTupo = false 
      local equips = {v.weapon_id, v.armor_id, v.horse_id, v.zuoji_id} 
      for k, id in pairs(equips) do 
        if self:canEquipmentAdvanced(id) then
          v._canAdvanced = true 
          if self:isEquipCanTupo(id) then 
            v._canTupo = true 
          end 
          break 
        end 
      end 

      table.insert(generals, v)
    end 
  end 
  
  self:sortGenerals(generals)

  return generals 
end 

--所有空闲装备
function SmithyData:getIdleEquip(disableSort) 
  local tbl = {}
  local tbl = g_EquipmentlMode.GetData()

  if nil == tbl then return {} end 

  --reset
  SmithyData:resetEquipFlag(tbl)

  --sort 
  if not disableSort and #tbl > 0 then 
    table.sort(tbl, function(a, b) return a.item_id < b.item_id end)
  end 

  return tbl 
end 

function SmithyData:resetEquipFlag(equArray)
  for k, v in pairs(equArray) do 
    v._isSelected = false 
    v._canAdvanced = false 
    v._selNum = 0 --已选择的数量
  end 
end 

function SmithyData:resetSelectedNum(equArray)
  for k, v in pairs(equArray) do 
    v._isSelected = false 
    v._selNum = 0 --已选择的数量
  end 
end 

--筛选指定类型装备
--equipType: 1:武器 2：防具 3：饰品
function SmithyData:getEquipByType(dataArray, equipType)
  local tbl = {}
  if dataArray then 
    for k, v in pairs(dataArray) do 
      if g_data.equipment[v.item_id].equip_type == equipType then 
        table.insert(tbl, v)
      end 
    end 
  end 

  if #tbl > 0 then 
    table.sort(tbl, function(a, b) return a.item_id > b.item_id end)
  end 

  return tbl 
end 

function SmithyData:getEquipByQuality(dataArray, quality, exclusiveId)
  local tbl = {}
  local count = 0 

  print("getEquipByQuality:",quality, exclusiveId)
  if dataArray then 
    for k, v in pairs(dataArray) do 
      if g_data.equipment[v.item_id].quality_id == quality then 
        if exclusiveId == v.item_id then 
          count = count + 1
          if count > 1 then --不包括自己
            table.insert(tbl, v)
          end 
        else 
          table.insert(tbl, v) 
        end 
      end 
    end 
  end 

  return tbl 
end 

--将装备按品质从高到低/ID从小到大排序
function SmithyData:sortEquipByQualityAndId(servEquips)

  if nil == servEquips then return end 

  local function sortByPriority(a, b)
    return g_data.equipment[a.item_id].quality_id > g_data.equipment[b.item_id].quality_id 
  end 
  table.sort(servEquips, sortByPriority)


  local function sortById(a, b)
    return a.item_id > b.item_id 
  end  

  local idx_s = 1
  local idx_e = #servEquips 

  if idx_e <= idx_s then return end 
  
  local preType = g_data.equipment[servEquips[idx_s].item_id].quality_id
  for i=idx_s+1, idx_e do
    local curType = g_data.equipment[servEquips[i].item_id].quality_id
    if i < idx_e then
      if curType ~= preType then
        SmithyData:sort(servEquips, idx_s, i-1, sortById)
        idx_s = i
        preType = curType
      end 
    else 
      if curType ~= preType then
        SmithyData:sort(servEquips, idx_s, i-1, sortById)
      else
        SmithyData:sort(servEquips, idx_s, i, sortById)
      end
    end
  end
end 

--获取可允许进阶的装备
function SmithyData:getEquipForAdvanced()
  local tbl = {}
  local data = self:getIdleEquip(true)
  local item 

  for k, v in pairs(data) do 
    item = g_data.equipment[v.item_id]
    if item and item.target_equip > 0 then 
      v._canAdvanced = self:canEquipmentAdvanced(v.item_id)
      v.quality_id = item.quality_id
      table.insert(tbl, v)
    end 
  end 

  if #tbl > 1 then 
    --1.按可进阶排序
    local function sortByCanAdvanced(a, b)
      return not a._canAdvanced and b._canAdvanced
    end 
    self:sort(tbl, 1, #tbl, sortByCanAdvanced)

    --2.按品质
    local function sortByPriority(a, b)
      return a.quality_id < b.quality_id 
    end    
    local idx_s = 1
    local idx_e = #tbl

    local preType = tbl[idx_s]._canAdvanced
    for i=idx_s+1, idx_e do
      local curType = tbl[i]._canAdvanced
      if i < idx_e then
        if curType ~= preType then
          self:sort(tbl, idx_s, i-1, sortByPriority)
          idx_s = i
          preType = curType
        end 
      else 
        if curType ~= preType then
          self:sort(tbl, idx_s, i-1, sortByPriority)
        else
          self:sort(tbl, idx_s, i, sortByPriority)
        end
      end
    end

    --3.按id从大-->小排序
    local function sortById(a, b)
      return a.item_id > b.item_id 
    end  

    idx_s = 1
    idx_e = #tbl  
    local preType = tbl[idx_s].quality_id
    for i=idx_s+1, idx_e do
      local curType = tbl[i].quality_id
      if i < idx_e then
        if curType ~= preType then
          self:sort(tbl, idx_s, i-1, sortById)
          idx_s = i
          preType = curType
        end 
      else 
        if curType ~= preType then
          self:sort(tbl, idx_s, i-1, sortById)
        else
          self:sort(tbl, idx_s, i, sortById)
        end
      end
    end
  end 

  return tbl 
end 

--获取可允许重铸的装备
function SmithyData:getEquipForRecast()
  local tbl = {}
  local item 
  local data = self:getIdleEquip()
  for k, v in pairs(data) do 
    item = g_data.equipment[v.item_id] 
    if item and item.star_level > 0 and item.quality_id <= 5 then --红色装备不能分解
      table.insert(tbl, v)
    end 
  end 
  
  return tbl 
end 

--sort: 品质 > 类型 > id 
--idDirDown: 从高往下排
function SmithyData:sortEquipByQualityAndType(tbl, idDirDown)
  --1)按品质
  table.sort(tbl, function(a, b) 
    if idDirDown then 
      return a.quality_id > b.quality_id 
    end 
    return a.quality_id < b.quality_id 
    end)

  --2) 按类型: 武器 > 防具 > 饰品 
  local function sortByType(a, b)
    if idDirDown then 
      return a.equip_type < b.equip_type 
    end 
    return a.equip_type > b.equip_type 
  end 

  local idx_s = 1
  local idx_e = #tbl  
  if idx_e < idx_s + 1 then 
    return 
  end 
  local preType = tbl[idx_s].quality_id
  for i=idx_s+1, idx_e do
    local curType = tbl[i].quality_id
    if i < idx_e then
      if curType ~= preType then
        self:sort(tbl, idx_s, i-1, sortByType)
        idx_s = i
        preType = curType
      end 
    else 
      if curType ~= preType then
        self:sort(tbl, idx_s, i-1, sortByType)
      else
        self:sort(tbl, idx_s, i, sortByType)
      end
    end
  end

  --3)按id
  local function sortById(a, b)
    return a.item_id > b.item_id 
  end 
  idx_s = 1
  idx_e = #tbl  
  preType = tbl[idx_s].equip_type
  for i=idx_s+1, idx_e do
    local curType = tbl[i].equip_type
    if i < idx_e then
      if curType ~= preType then
        self:sort(tbl, idx_s, i-1, sortById)
        idx_s = i
        preType = curType
      end 
    else 
      if curType ~= preType then
        self:sort(tbl, idx_s, i-1, sortById)
      else
        self:sort(tbl, idx_s, i, sortById)
      end
    end      
  end 
end 

--获取可允许分解的装备(万能装备排在最后分解,其他放前面)
function SmithyData:getEquipForDecompose()
  local tmp1 = {} --白色/绿色装备
  local tmp2 = {} --白色/绿色万能装备
  local tmp3 = {} --其他装备
  local tmp4 = {} --其他万能装备

  local data = self:getIdleEquip(true)
  local item
  for k, v in pairs(data) do 
    item = g_data.equipment[v.item_id]
    if item then 
      v.quality_id = item.quality_id --供排序用
      v.equip_type = item.equip_type
      if item.equip_type == 0 then --万能装备
        if item.quality_id <= 2 then 
          table.insert(tmp2, v)
        else 
          table.insert(tmp4, v)
        end 
        
      elseif item.star_level == 0 then --带星的装备不能分解 
        if item.quality_id <= 2 then 
          table.insert(tmp1, v)
        elseif item.quality_id <= 5 then --红色装备不能分解
          table.insert(tmp3, v)
        end 
      end 
    end 
  end 



  self:sortEquipByQualityAndType(tmp1)
  self:sortEquipByQualityAndType(tmp2)
  self:sortEquipByQualityAndType(tmp3)
  self:sortEquipByQualityAndType(tmp4)

  for k, v in pairs(tmp2) do 
    table.insert(tmp1, v)
  end 
  for k, v in pairs(tmp3) do 
    table.insert(tmp1, v)
  end 
  for k, v in pairs(tmp4) do 
    table.insert(tmp1, v)
  end 

  return tmp1 
end 

function SmithyData:getSizeOfEqus(equipArray) 
  local num = 0 
  for k, v in pairs(equipArray) do 
    num = num + v.num 
  end 
  return num 
end   

function SmithyData:setPreSelectedState(equipArray, selectedArray)
  if nil == equipArray or nil == selectedArray then return end 
  if type(equipArray) ~= "table" or type(selectedArray) ~= "table" then return end 

  for k, v in pairs(selectedArray) do 
    for key, val in pairs(equipArray) do 
      if v.item_id == val.item_id then 
        equipArray[k]._isSelected = true 
      end 
    end 
  end 
end 

--获取装备重铸返回的材料
function SmithyData:getEquipRecastMat(equipId)
  local tbl = {}
  local dropId = g_data.equipment[equipId].recast 
  if dropId > 0 then 
    local group = g_data.drop[dropId].drop_data 
    if group then 
      print("dropId", dropId)
      for k, v in pairs(group) do 
        local found = false 
        for key, val in pairs(tbl) do 
          if val and val[1] == v[1] and val[2] == v[2] then --相同材料则叠加
            found = true 
            tbl[key][3] = tbl[key][3] + v[3] 
            break 
          end 
        end 
        
        if not found then 
          table.insert(tbl, {v[1], v[2], v[3]})
        end 
      end 
    end 
  end  

  return tbl  
end 

--获取装备分解后返还的材料
function SmithyData:getMatAfterDecomposed(equipArray)
  local tbl = {}

  --buff效果:分解装备白银获得增加
  local plus1 = 0 
  local plus2 = 0 
  local allbuffs = g_BuffMode.GetData()
  if allbuffs and allbuffs["decomposition_equipment_silver_plus"] then
    plus1 = tonumber(allbuffs["decomposition_equipment_silver_plus"].v)/10000
  end  

  --建筑输出buff
  local allBuilds = g_PlayerBuildMode.GetData()
  for k, v in pairs(allBuilds) do 
    if v.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.smithy then 
      for i, item in pairs(g_data.build[v.build_id].output) do 
        if item[1] == 18 then --分解
          -- if g_data.output_type[18].num_type == 1 then --万分比
          plus2 = item[2]/10000  
        end 
      end 
      break 
    end 
  end 

  print("buff silver: plus1, plus2=", plus1, plus2)

  for k, v in pairs(equipArray) do 
    local dropId = g_data.equipment[v.item_id].decomposition 
    if dropId > 0 then 
      print("item_id, dropId", v.item_id,dropId)
      local group = g_data.drop[dropId].drop_data 
      if group then 
        for k, item in pairs(group) do 
          local found = false 

          local num = item[3] * v._selNum 
          if item[2] == 10600 then --白银数量添加buff
            num = math.floor(num * (1 + plus1 + plus2))
          end 

          for key, val in pairs(tbl) do 
            if val[1] == item[1] and val[2] == item[2] then --叠加
              found = true 
              tbl[key][3] = tbl[key][3] + num 
              break 
            end 
          end 
          
          if not found then 
            table.insert(tbl, {item[1], item[2], num})
          end 
        end 
      end 
    end 
  end 
  

  return tbl 
end

--装备进阶消耗 (类型比较特殊)
function SmithyData:getOwnMaterialCount(itype, itemId)
  local ownCount = 0 
  if itype == 1 then --材料
    ownCount = g_BagMode.findItemNumberById(itemId)
  elseif itype == 2 then --装备 
    local equp = g_EquipmentlMode.getSameEquips(itemId)
    ownCount = equp and equp.num or 0 
  elseif itype == 3 then --白银
    ownCount = g_PlayerMode.GetData().silver 
  end 
  
  return ownCount 
end 



function SmithyData:canEquipmentAdvanced(equipId)

  if nil == equipId or equipId == 0 then 
    return false 
  end 

  local equipItem = g_data.equipment[equipId]  

  if nil == equipItem or equipItem.target_unlock == 0 or equipItem.target_equip <= 0 then 
    return false 
  end 

  for k, v in pairs(equipItem.consume) do 
    if v[1] == 1 or v[1] == 2 then --材料/装备
      if self:getOwnMaterialCount(v[1], v[2]) < v[3] then 
        return false 
      end 
    end 
  end 

  return true 
end 

--装备是否允许突破(即使材料不足)
function SmithyData:isEquipCanTupo(equipId)
    local item1 = g_data.equipment[equipId]
    if item1 and (item1.quality_id == 5 and item1.star_level == 5 and item1.target_equip > 0 and item1.target_unlock > 0) then 
      return true 
    end 

    return false 
end 

--红色装备新增的技能描述
function SmithyData:getRedEquipNewSkillDesc(equpId)
  local item2 = g_data.equipment[equpId]
  if item2 and item2.quality_id >= 6 then 
    local skillName = ""
    if item2.equip_type == 1 then 
      if g_data.combat_skill[item2.combat_skill_id] then 
        skillName = g_tr(g_data.combat_skill[item2.combat_skill_id].skill_name)
      end 
    else 
      if g_data.battle_skill[item2.battle_skill_id] then 
        skillName = g_tr(g_data.battle_skill[item2.battle_skill_id].skill_name)
      end 
    end 

    return g_tr("skillLvIncrease", {name = skillName, num = item2.skill_level})
  end 

  return ""
end 

function SmithyData:setBaseView(view)
  self._baseView = view 
end 

function SmithyData:getBaseView()
  return self._baseView  
end 


--铁匠铺模块内跳转,返回
function SmithyData:setBackView(viewType, para)
  self._backView = viewType
  self._backViewPara = para 
end 

function SmithyData:getBackView()
  return self._backView, self._backViewPara
end 

function SmithyData:setDataIsDurty(isDurty)
  self._isDurty = isDurty  
end 

function SmithyData:getDataIsDurty()
  return self._isDurty  
end 

function SmithyData:setOnPreExit(callback)
  self._onPreExit = callback 
end 

function SmithyData:getOnPreExit()
  return self._onPreExit 
end 

--军团编制里的武将是否有空闲装备可佩戴
function SmithyData:canEquipForArmyGen()
  local gen = g_GeneralMode.GetData()
  if nil == gen then 
    return false 
  end 

  local equip = g_EquipmentlMode.GetData()
  if nil == equip then 
    return false 
  end 
  
  local noArmy = false 
  local noAccessory = false 
  for k, v in pairs(gen) do 
    if v.army_id > 0 then 
      if v.armor_id == 0 then 
        noArmy = true 
      end 
      if v.horse_id == 0 then 
        noAccessory = true 
      end 
    end

    if noArmy and noAccessory then 
      break 
    end 
  end 

  local hasIdleArmy = false 
  local hasIdleAccessory = false 
  local item 
  for k, v in pairs(equip) do 
    item = g_data.equipment[v.item_id]
    if item then 
      if item.equip_type == 2 then 
        hasIdleArmy = true 
      elseif item.equip_type == 3 then 
        hasIdleAccessory = true 
      end 

      if hasIdleArmy and hasIdleAccessory then 
        break 
      end 
    end 
  end 

  if (noArmy and hasIdleArmy) or (noAccessory and hasIdleAccessory) then 
    return true 
  end 

  return false 
end 

--驻守武将装备有变动时更新武将buff
function SmithyData:updateGenBuff(genId)
  if nil == genId or genId == 0 then return end 

  local data = g_GeneralMode.GetData()
  for k, v in pairs(data) do 
    if genId == v.general_id then 
      if v.build_id > 0 then 
        local buildServerInfo = g_PlayerBuildMode.FindBuild_ID(v.build_id)
        if buildServerInfo then 
          g_BuffMode.RequestGeneralBuffAsync(buildServerInfo.position)
        end       
      end 
      break 
    end 
  end 
end 

return SmithyData 
