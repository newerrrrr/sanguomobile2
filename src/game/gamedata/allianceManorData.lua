local allianceManorData = {}
setmetatable(allianceManorData,{__index = _G})
setfenv(1,allianceManorData)

local canCreateData = nil
local buildData = nil
function RequestData()
    local ret = false
    local function onRecv(result, msgData)
      if result then
        ret = true
        SetBuildData(msgData.GuildBuild)
        SetCanCreateData(msgData.CanCreate)
      end
    end

    g_sgHttp.postData("Guild/comboGuildBuild",{},onRecv)
    return ret
end

function RequestDataAsync(callback,showLoading)
    local function onRecv(result, msgData)
      if showLoading == true then
        g_busyTip.hide_1()
      end
      if result then
        SetBuildData(msgData.GuildBuild)
        SetCanCreateData(msgData.CanCreate)
      end
      
      if callback then
          callback(result, msgData)
      end
    end
    if showLoading == true then
        g_busyTip.show_1()
    end
    g_sgHttp.postData("Guild/comboGuildBuild",{},onRecv,true)
end

function SetBuildData(data) 
    buildData = data
end

function GetBuildData() 
    if buildData == nil then
        RequestData()
    end
    return buildData
end

function SetCanCreateData(data) 
    canCreateData = data
end

function GetCanCreateData() 
    if canCreateData == nil then
        RequestData()
    end
    return canCreateData
end

function RequestCreateGuildBuild(_x,_y,map_element_id,type) 

      local resultHandler = function(result, msgData)
          if result then
            print("success")
            require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
            g_allianceManorData.RequestDataAsync() --更新联盟建筑可建造的状态列表
          else
            --g_airBox.show("create failed")
          end
      end
      
      if type == 3 then
          
          local resource = 0
          if map_element_id == 301 then
              resource = 1
          elseif map_element_id == 401 then
              resource = 2
          elseif map_element_id == 501 then
              resource = 3
          elseif map_element_id == 601 then
              resource = 4
          elseif map_element_id == 701 then
              resource = 5
          end
          assert(resource > 0)
          g_sgHttp.postData("guild/createGuildBuild",{type = type,x = _x,y = _y,resource = resource},resultHandler)
      else
          g_sgHttp.postData("guild/createGuildBuild",{type = type,x = _x,y = _y},resultHandler)
      end
 
end

return allianceManorData
