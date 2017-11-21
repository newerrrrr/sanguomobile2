local playerDataMode = {}
setmetatable(playerDataMode,{__index = _G})
setfenv(1,playerDataMode)

local baseData = nil
local oldBaseData = nil --备份等级信息
local donateData = nil --国战捐献数据


--与玩家基本信息关联的模块,显示更新可以放这里
function NotificationUpdateShow()
    local mainSurfacePlayer = require("game.uilayer.mainSurface.mainSurfacePlayer")
	mainSurfacePlayer.updateShowWithData_All()
	g_resourcesInterface.updateAllResShow()
	
	--主公升级界面
	require("game.uilayer.master.MasterLevelUpView"):createLayer()
   --主公界面刷新天赋小红点
  require("game.uilayer.master.MasterView"):talentRedPointUpdate()

  if baseData.power - oldBaseData.power > 0 then
      mainSurfacePlayer.showPowerUpView(baseData.power - oldBaseData.power)
  elseif baseData.power - oldBaseData.power < 0 then
      mainSurfacePlayer.updatePower()
  end

  if baseData.current_exp - oldBaseData.current_exp > 0 then
      mainSurfacePlayer.showExpUpView(baseData.current_exp - oldBaseData.current_exp)
  end

	require("game.uilayer.recast.recastView").checkShowForPlayerDataChange()

  if baseData.vip_level > oldBaseData.vip_level then 
      mainSurfacePlayer.updateShowWithData_Vip()
  end
  
	--升级
  if baseData.level ~= oldBaseData.level then
      --判断主动技能图标是否显示触发
		local isShow = require("game.uilayer.mainSurface.mainSurfaceChat").isSkillBtnShow()
    require("game.uilayer.mainSurface.mainSurfacePlayer").viewChangeShow()
    
    do --sdk登录角色信息 数据类型，1 为进入游戏，2 为创建角色，3 为角色升级，4 为退出
			g_sdkManager.addPlayerInfo(3)
		end
  end
    
	--联盟战界面元宝更新
	require("game.mapguildwar.worldMapLayer_uiLayer").updatePlayerInfo()
	require("game.mapcitybattle.worldMapLayer_uiLayer").updatePlayerInfo()
end

--城池站捐献调用
function NotificationUpdateDonateShow()
    require("game.uilayer.cityBattle.CityMenu").UpdateRP()
end

function SetData(data)
	oldBaseData = clone(baseData) or clone(data)
	baseData = data
end



--请求数据
function RequestData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetData(msgData.Player)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"Player",}},onRecv)
	return ret
end


--异步请求数据
function RequestData_Async()
	local function onRecv(result, msgData)
		if(result==true)then
			SetData(msgData.Player)
			NotificationUpdateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"Player",}},onRecv,true)
end


--public



--得到基本信息,只可使用不可修改
function GetData()
	if baseData == nil then
		RequestData()
	end
	return baseData
end

--获取刷新前玩家信息,只可使用不可修改
function GetOldData()
    if oldBaseData == nil then
        oldBaseData = clone(GetData())
	end
	return oldBaseData
end


--得到总砖石数量
function getDiamonds()
	local playerData = GetData()
	if(playerData == nil)then
		return 0
	end
	return tonumber(playerData.rmb_gem) + tonumber(playerData.gift_gem)
end

function getXuanTie()
    local playerData = GetData()
	if(playerData == nil)then
		return 0
	end
	return tonumber(playerData.xuantie)
end
--by:liuyi
--获取主公当前体力
function getMove()
    
    local playerData = GetData()
    if playerData == nil then
        print(" get playerdata error ")
        return 0
    end

    --[[测试代码
    if true then
        return playerData.move
    end
    --]]

    local npow = playerData.move --当前体力
    local mpow = getLimitMove() --体力上限
    local powbacktime = playerData.move_in_time --恢复时间
    local buff_add = 0
    local buff_data = g_BuffMode.GetData()

    if buff_data then
        buff_add = buff_data["move_restore_speed"] and buff_data["move_restore_speed"].v or 0
        --配置表当中的buff_type 是1 万份比
        buff_add = buff_add / 10000
    end

    local backtime = g_data.starting[14].data / (1 + buff_add)

    if powbacktime <= 0 then
        return npow,backtime
    end

    local ntime = g_clock.getCurServerTime()

    --增加恢复时间BUFF
    
    --move_restore_speed

    
    local ntimepow = math.max( math.ceil( ( ntime - powbacktime ) / backtime  ) + npow,npow)  --加上回复时间的体力

    --print("ntime,powbacktime,backtime,npow,ntimepow",ntime,powbacktime,backtime,npow,ntimepow)

    if ntimepow > mpow then
        ntimepow = mpow
    end

    if ntimepow < 0 then
        ntimepow = 0
    end

    -- print("ntimepow",ntimepow,backtime)

    return ntimepow,backtime
end

--by:liuyi
--获取主公体力上限
function getLimitMove()
    local playerData = GetData()
    
    if playerData == nil then
        print(" get playerdata error ")
        return g_data.staring[7].data or 100
    end

    local max = playerData.move_max
    local buffAddValue = 0
    local buff_data = g_BuffMode.GetData()
    --增加BUFF 所提高的上限
    if buff_data then
        --配置表当中的buff_type 是2
        buffAddValue = buff_data["move_limit_plus_exact_value"] and buff_data["move_limit_plus_exact_value"].v or 0
    end

    max = max + buffAddValue

    return max
end

--获取玩家可以缩减建造的时间暂时使用5分钟
function getReduceBuildTime()
    
    local defultTime = 60 * 5
    local vipMode = require("game.uilayer.vip.VIPMode")
    local vipLeftTime = vipMode.getVipLeftTime()

    --判断VIP是否失效 如果没有失效加上VIP 缩减建造速度的BUFF 如果VIP消失则默认拥有五分钟的加速时间
    if vipLeftTime > 0 then
        defultTime = g_BuffMode.getFinalBuffValueByBuffKeyName("instant_building") 
    end
    
    return defultTime
end


--判断某一种基本资源够不够,根据配置表ID
function EnoughResWithConfig(t,v)
	local tp = tonumber(t)
	local vr = tonumber(v)
	if(vr <= 0)then
		return true
	end
	local count , image = g_gameTools.getPlayerCurrencyCount(tp)
	return count >= vr
end


--当前是否有保护罩
function hasAvoid()
	local playerData = GetData()
	if playerData then
		return (playerData.avoid_battle == 1 or ((playerData.avoid_battle_time - g_clock.getCurServerTime()) > 0))
	end
	return false
end

--当前是否有新手保护罩
function hasNewPlayerAvoid()
    local haveAvoid = false
    local playerData = GetData()
    if playerData then
        haveAvoid = playerData.fresh_avoid_battle_time > g_clock.getCurServerTime()
    end
    return haveAvoid
end


function SetDonateData(data)
    donateData = clone(data)
end

--请求数据
function RequestDonateData()
	local ret = false
	local function onRecv(result, msgData)
		if(result==true)then
			ret = true
			SetDonateData(msgData.PlayerCitybattleDonate)
            NotificationUpdateDonateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerCitybattleDonate",}},onRecv)
	return ret
end


--请求数据
function RequestDonateData_Async(fun)
	local function onRecv(result, msgData)
		if(result==true)then
			SetDonateData(msgData.PlayerCitybattleDonate)
            if fun then
                fun()
            end
            NotificationUpdateDonateShow()
		end
	end
	g_sgHttp.postData("data/index",{name = {"PlayerCitybattleDonate",}},onRecv,true)
end


--获取国战捐献数据
function GetDonateData()
    if donateData == nil then
        RequestDonateData()
    end
    return donateData
end


return playerDataMode