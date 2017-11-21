local VIPMode = {}
setmetatable(VIPMode,{__index = _G})
setfenv(1, VIPMode)

local vipLevelMax = 12 

--返回左右列表数据
function getPrivalegePageData(vipLevel)

  local Lv1 = vipLevel 
  local Lv2 = vipLevel + 1 
  if Lv1 >= vipLevelMax then 
    Lv1 = vipLevelMax - 1 
    Lv2 = vipLevelMax  
  end 

  local data1 = {}
  local data2 = {}
  for k, v in pairs(g_data.vip_privilege) do 
    if v.vip_lv == Lv1 then 
      table.insert(data1, v)

    elseif v.vip_lv == Lv2 then 
      table.insert(data2, v)
    end 
  end 
  
  local function sortByType(a, b)
    return a.privilege_type > b.privilege_type 
  end 
  table.sort(data1, sortByType)
  table.sort(data2, sortByType)

  return data1, data2
end 

function getPrivalegeData(vipLevel)
  local data = {}
  for k, v in pairs(g_data.vip_privilege) do 
    if v.vip_lv == vipLevel then 
      table.insert(data, v)
    end 
  end 

  return data 
end 

--VIP剩余有效时间 
function getVipLeftTime()
  local left = 0 
  local allbuffs = g_BuffMode.GetData()
  if allbuffs and allbuffs.vip_active.v > 0 then --vip已激活
    local tmp = allbuffs.vip_active.tmp 
    if tmp and #tmp > 0 then 
      left = tmp[1].expire_time - g_clock.getCurServerTime() 
    end 
  end 

  return left 
end 

function getVipLevelMax()
  return vipLevelMax 
end 

return VIPMode 
