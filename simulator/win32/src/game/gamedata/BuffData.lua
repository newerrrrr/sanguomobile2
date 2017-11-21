--g_BuffMode
local BuffDataMode = {}
setmetatable(BuffDataMode,{__index = _G})
setfenv(1, BuffDataMode)

local baseData = nil
local generalBuffs = {}
local timeBasedBuffs = {}

local localBuffConfigs = {}
for key, var in pairs(g_data.buff) do
	localBuffConfigs[var.name] = clone(var)
end

--根据buff keyname获取本地配置表数据
function getBuffConfigByKeyName(kename)
    return localBuffConfigs[kename]
end

--更新显示
function NotificationUpdateShow()
	require("game.uilayer.mainSurface.mainSurfacePlayer").updateShowWithData_All()
end


function SetData(data)
	baseData = data
	timeBasedBuffs = {}
	for key, var in pairs(baseData) do
      if var.v ~= 0 and var.tmp and table.nums(var.tmp) > 0 then
          table.insert(timeBasedBuffs,var)
      end
	end
end

--更新时效性的buff
function updateTimeBaseBuffs()
  local needUpdate = false
  for buffkey, buffData in pairs(timeBasedBuffs) do
      for key, var in pairs(buffData.tmp) do
          if var.expire_time < g_clock.getCurServerTime() then
              needUpdate = true
              break
          end
      end
  end
  if needUpdate then
      RequestDataAsync()
  end
end

--请求数据
function RequestDataAsync(dt)
    
    local needRequrest = true
    if dt and dt < 20 then
        needRequrest = false
    end
    
    if not needRequrest then
        return
    end
    
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.PlayerBuff)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("Player/getBuff",{},onRecv,true)
end

function RequestData()
    local ret = false
    local function onRecv(result, msgData)
        if(result==true)then
            ret = true
            SetData(msgData.PlayerBuff)
            NotificationUpdateShow()
        end
    end
    g_sgHttp.postData("Player/getBuff",{},onRecv)
    return ret
end

function GetData()
    if baseData == nil then
        RequestData()
        g_gameCommon.addEventHandler(g_Consts.CustomEvent.GuildScience, function(_,data)
            print("guild buff changed~~~~~~~~~~~~~~~~~~~~")
            g_BuffMode.RequestDataAsync()
        end)
    end

	return baseData
end


--请求所有建筑的武将驻守buff
function RequestAllGeneralBuffData(isAsync)
    local positions = {}
    local allBuilds = g_PlayerBuildMode.GetData()
    for key, buildServerData in pairs(allBuilds) do
        if buildServerData and buildServerData.general_id_1 and buildServerData.general_id_1 ~= 0 then
           table.insert(positions,buildServerData.position)
        end
    end
    
    RequestGeneralBuffDataByPositions(positions,isAsync)
end

function RequestGeneralBuffDataByPositions(positions,isAsync)
    
    if isAsync == nil then
        isAsync = false
    end
    
    if table.nums(positions) <= 0 then
        return
    end
    
    local vaildPositions = {}
    --只有有武將駐守的建築才請求武將buff
    for key, pos in pairs(positions) do
    	local buildServerData = g_PlayerBuildMode.FindBuild_Place(pos)
    	if buildServerData and buildServerData.general_id_1 and buildServerData.general_id_1 ~= 0 then
    	   table.insert(vaildPositions,pos)
    	else
    	   clearGeneralBuffByPosition(pos)
    	end
    end
    
    local function onRecv(result, msgData)
        if(result==true)then
            --generalBuffs[position] = msgData.generalBuff.general
            
            for buildPos, generalBuffData in pairs(msgData.generalBuff) do
                --武将和装备的buff
                local allBuffs = {}
                local currentGeneralBuffs = generalBuffData.general or {}
                local equipBuffs = generalBuffData.equip or {}
                
                -- print("~~~~~~~~~currentGeneralBuffs:")
                -- dump(currentGeneralBuffs)
                
                -- print("~~~~~~~~~equipBuffs:")
                -- dump(equipBuffs)
                
                --服务器给个的万分比是除过10000的
                do
                    for key, var in pairs(currentGeneralBuffs) do
                        if allBuffs[key] == nil then
                           allBuffs[key] = 0
                        end
                        
                        local buffVar = var
                        if localBuffConfigs[key].buff_type == 1 then
                            buffVar = buffVar * 10000
                        end
                        
                        allBuffs[key] = allBuffs[key] + buffVar
                    end
                end
                
                
                --服务器给个的万分比是除过10000的
                do
                    for key, var in pairs(equipBuffs) do
                        if allBuffs[key] == nil then
                           allBuffs[key] = 0
                        end
                        
                        local buffVar = var
                        if localBuffConfigs[key].buff_type == 1 then
                            buffVar = buffVar * 10000
                        end
                        
                        allBuffs[key] = allBuffs[key] + buffVar
                    end
                end
                
                generalBuffs[tonumber(buildPos)] = allBuffs
                
            end
            
            NotificationUpdateShow()
        end
    end
    
    if #vaildPositions > 0 then
        g_sgHttp.postData("player/getGeneralBuffByBuild",{position = vaildPositions},onRecv,isAsync)
    end
end

--根据一个建筑位置请求对应的武将驻守buff 异步接口
function RequestGeneralBuffAsync(position)
    if tonumber(position) > 0 then
        RequestGeneralBuffData(tonumber(position),true)
    end
end

--根据一个建筑位置请求对应的武将驻守buff
function RequestGeneralBuffData(position,isAsync)
    if isAsync == nil then
        isAsync = false
    end
    RequestGeneralBuffDataByPositions({position},isAsync)
end

function clearGeneralBuffByPosition(position)
    generalBuffs[position] = nil
end

function clearAllGeneralBuff()
    generalBuffs = {}
end
       
function getGeneralBuffData(position)
    if generalBuffs[position] == nil then
        RequestGeneralBuffData(position)
    end

    return generalBuffs[position]
end 

--通过buffKey 获取buff值
function getFinalBuffValueByBuffKeyName(keyname,position)
    local buffConfig = getBuffConfigByKeyName(keyname)
    return getFinalBuffValueByBuffId(buffConfig.id,position)
end

--通过buffId 获取Buff值
function getFinalBuffValueByBuffId(buffId,position)
    local allbuffs = GetData()
    
    --buff 效果
    local buffValue = 0
    
    local buffKeyName = g_data.buff[buffId].name
    --player buff
    if allbuffs and allbuffs[buffKeyName] then
        -- print("~~~~~~~~~player buff value ["..buffKeyName.."]:",allbuffs[buffKeyName].v)
        if tonumber(allbuffs[buffKeyName].v) > 0 then
           buffValue = allbuffs[buffKeyName].v
        end
    end
    
    if position then
        --驻守武将的buff
        local allGeneralBuffs = getGeneralBuffData(position)
        if allGeneralBuffs and allGeneralBuffs[buffKeyName] then
            -- print("~~~~~~~~~general buff value ["..buffKeyName.."]:",allGeneralBuffs[buffKeyName])
            buffValue = buffValue + allGeneralBuffs[buffKeyName]
        end
    end
    
    local buffType = g_data.buff[buffId].buff_type
    
    return buffValue,buffType
end

--根据 orginalValue（原始值）,buffid 和buildPosition 计算buff加成后的值
function calculateFinalValueByBuffId(orginalValue,buffId,buildPosition)
    local finalValue = orginalValue
    local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,buildPosition)
    if buffType == 1 then --万分比
        finalValue = math.ceil(orginalValue * (10000 + buffValue)/10000)
    elseif buffType == 2 then --固定值
        finalValue = orginalValue + buffValue
    end
    return finalValue
end

--根据 orginalValue（原始值）,buffKeyName 和buildPosition 计算buff加成后的值
function calculateFinalValueByBuffKeyName(orginalValue,buffKeyName,buildPosition)
    local finalValue = orginalValue
    local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffKeyName(buffKeyName,buildPosition)
    if buffType == 1 then --万分比
        finalValue = math.ceil(orginalValue * (10000 + buffValue)/10000)
    elseif buffType == 2 then --固定值
        finalValue = orginalValue + buffValue
    end
    return finalValue
end

--判断一个buff是否有值或者在生效期间
function IsBuffWorkingByKeyName(keyname,position)
    local buffConfig = getBuffConfigByKeyName(keyname)
    return IsBuffWorkingByBuffId(buffConfig.id,position)
end

--判断一个buff是否有值或者在生效期间
function IsBuffWorkingByBuffId(buffId,position)
   
   local isWorking = false

   local allbuffs = GetData()
   local endTime = 0
   local buffKeyName = g_data.buff[buffId].name
   if allbuffs and allbuffs[buffKeyName] then
      local buffData = allbuffs[buffKeyName]
      local buffValue,buffType = g_BuffMode.getFinalBuffValueByBuffId(buffId,position)
      if buffValue ~= 0 then
          isWorking = true
      else
          if buffData.tmp and table.nums(buffData.tmp) > 0 then
              for key, var in pairs(buffData.tmp) do
                  endTime = math.max(var.expire_time,endTime)
              end
          end
          
          if endTime > g_clock.getCurServerTime() then
              isWorking = true
          end
      end
   end
   
   return isWorking
end

--返回buff时效加成部分的结束时间，但不能用于判断buff是否有加成
function getBuffEndTimeByKeyName(keyname)
   local buffConfig = getBuffConfigByKeyName(keyname)
   return getBuffEndTimeByBuffId(buffConfig.id)
end

function getBuffEndTimeByBuffId(buffId)
   local allbuffs = GetData()
   local endTime = 0
   local buffKeyName = g_data.buff[buffId].name
   if allbuffs and allbuffs[buffKeyName] then
      local buffData = allbuffs[buffKeyName]
      if buffData.tmp and table.nums(buffData.tmp) > 0 then
          for key, var in pairs(buffData.tmp) do
              endTime = math.max(var.expire_time,endTime)
          end
      end
   end
   return endTime
end

return BuffDataMode