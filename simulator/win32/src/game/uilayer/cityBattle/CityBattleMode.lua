local CityBattleMode = class("CityBattleMode")

local ServerData = nil
local OccupyData --城市占领信息
local RankListData --称号排行榜
local ShopData = nil
local PrepareInfo = nil
local SignData = nil
local OpenTime = nil
local GiftData = nil


function CityBattleMode:GetInstance()
    if nil == CityBattleMode._instance then 
        CityBattleMode._instance = CityBattleMode.new()
    end 

    return CityBattleMode 
end

function CityBattleMode:_InitScience()
    if self.filter == nil then self.filter = {} end
    if self.filterVec == nil then self.filterVec = {} end
    local ScienceConfig = g_data.country_science
    for key, var in pairs(ScienceConfig) do
        if self.filter[tostring(var.science_type)] == nil then self.filter[tostring(var.science_type)] = {} end
        self.filter[tostring(var.science_type)][tonumber(var.level)] = var
        self.filterVec[tostring(var.id)] = var
    end
end

function CityBattleMode:GetFilterScienceConfig()
    if self.filter == nil then
        self:_InitScience()
    end
    return self.filter
end

function CityBattleMode:GetScienceById(id)
    if self.filterVec == nil then
        self:_InitScience()
    end
    return self.filterVec[tostring(id)]
end

function CityBattleMode:GetServerData()
    if ServerData == nil then
        self:Req()
    end
    return ServerData
end

function CityBattleMode:Req(isAsysnc , fun )
    local flag = isAsysnc or false
    ServerData = {}
    local function callback(result,msgData)
        if isAsysnc then
            g_busyTip.hide_1()
        end
        if true == result then
            for key, var in pairs(msgData.CityBattleScience) do
                ServerData[ tostring(var.science_type)] = var 
            end
            if fun then
                fun()
            end
        end
    end
    if isAsysnc then
        g_busyTip.show_1()
    end
    g_sgHttp.postData("data/index",{name ={ "CityBattleScience" }}, callback,flag)
end

function CityBattleMode:UpdateServerData( data )
    if ServerData == nil then
        return
    end

    ServerData[tostring(data.science_type)] = data
     
end

function CityBattleMode:GetCityMapConfig( campId )
    local config = g_data.country_city_map
    for key, var in pairs(config) do
        if campId == var.default_belong then
            return var
        end
    end
end

function CityBattleMode:getOccupyInfo()
    -- if nil == OccupyData then 
    --     self:RequestOccupyInfo(false)
    -- end 
    return OccupyData 
end 

--isAsysnc:是否为异步请求
--updateUIFunc:数据返回时更新UI回调
--两个参数可不传
function CityBattleMode:RequestOccupyInfo(isAsysnc, updateUIFunc)
    local flag = true == isAsysnc 

    print("RequestOccupyInfo: isAsysnc=", flag)

    local function onRecv(result, data)
        if isAsysnc then 
            g_busyTip.hide_1() 
        end 
        if result then 
            OccupyData = data 
            OccupyData.lastReqTime = os.time() 

            if updateUIFunc then 
                updateUIFunc(data)
            end 
        end 
    end 
    if isAsysnc then 
        g_busyTip.show_1() 
    end 
    g_sgHttp.postData("city_battle/occupyInfo", {}, onRecv, flag) 
end 

--称号排行榜数据
function CityBattleMode:getRankListData() 
    return RankListData 
end 

function CityBattleMode:RequestRankList(isAsysnc, updateUIFunc)
    local flag = true == isAsysnc 

    print("RequestRankList: isAsysnc=", flag)

    local function onRecv(result, data)
        if isAsysnc then 
            g_busyTip.hide_1()
        end 
        if result then 
            RankListData = data 
            if data and type(data) == "table" then 
                RankListData.lastReqTime = os.time() 
            end 
            if updateUIFunc then 
                updateUIFunc()
            end 
        end 
    end 
    if isAsysnc then 
        g_busyTip.show_1() 
    end 
    g_sgHttp.postData("city_battle/getCityBattleRank", {}, onRecv, flag) 
end 

function CityBattleMode:GetCityCamp(cityId)
    if cityId == nil then return end

    if OccupyData == nil then
        self:RequestOccupyInfo(false)
    end

    local cityData = self:getOccupyInfo()

    if cityData and cityData.camp_data then
        for _, camp in ipairs(cityData.camp_data) do
            if camp.city_ids then
                for __, city_id in ipairs(camp.city_ids) do
                    print("city_id,cityId",city_id,cityId)
                    if city_id == cityId then
                        return camp.camp_id
                    end
                end
            end
        end
    end
    return
end


function CityBattleMode:GetSignOverTime()
    if PrepareInfo == nil then
        self:GetPrepareInfo()
    end
    local startTime = nil
    --PrepareInfo.signStart
    local endTime = nil
    --PrepareInfo.signEnd
    local status = PrepareInfo.status
    local stepStartTime = nil
    local stepEndTime = nil
    local weekType = 
    {
        [1] = 0,
        [2] = 1,
        [3] = 2,
        [4] = 3,
        [5] = 4,
        [6] = 5,
        [7] = 6,
    }
    local open = string.split(g_data.country_basic_setting[6].data,",")
    local open1 = tonumber(open[1])
    local open2 = tonumber(open[2])
    
    local function getTime(time)
        local serverNow = time
        --g_clock.getCurServerTime()
        local days = g_clock.getCurServerTimeWithTimezone(serverNow,true)
        local w = weekType[g_clock.getCurServerTimeWithTimezone(serverNow,true).wday]
        local lessDay = 0
        while true do
            local dd = w + lessDay
            dd = dd % 7 
            if dd == open1 or dd == open2 then
                break
            end
            lessDay = lessDay + 1
        end
        
        local s = string.split(g_data.country_basic_setting[7].data,":")
        local e = string.split(g_data.country_basic_setting[9].data,":")
        startTime = os.time( { day = days.day + lessDay, month = days.month, year = days.year, hour = tonumber(s[1]), minute = tonumber(s[2]), second = tonumber(s[3]) })
        endTime = os.time( { day = days.day + lessDay, month = days.month, year = days.year, hour = tonumber(e[1]), minute = tonumber(e[2]), second = tonumber(e[3]) })
        status = status or -1
        PrepareInfo = { status = status }
        --未报名
        if g_clock.getCurServerTime() < startTime then
            print("未报名")
            stepStartTime = startTime
            stepEndTime = nil
        --报名中
        elseif g_clock.getCurServerTime() >= startTime and g_clock.getCurServerTime() <= endTime then
            print("报名中")
            stepStartTime = nil
            stepEndTime = endTime
        --报名结束显示下一次的报名时间
        elseif g_clock.getCurServerTime() > endTime then
            getTime( g_clock.getCurServerTime() + 24 * 3600 )
        end
    end

    getTime(g_clock.getCurServerTime())

        --[[else
        if endTime < g_clock.getCurServerTime() then  --报名已经结束了 找下一次报名时间
            local week = weekType[g_clock.getCurServerTimeWithTimezone(endTime,true).wday]
            local stepDay = 0
            local open2Temp = (open2 == 0 and 7 or open2)
            if tonumber(week) == open1 then
                stepDay = open2Temp - open1
            elseif tonumber(week) == open2 then
                stepDay = 7 - open2Temp + open1
            end
            local week = weekType[g_clock.getCurServerTimeWithTimezone(startTime + stepDay * 24 * 3600,true).wday]
            stepStartTime = ( startTime + stepDay * 24 * 3600 ) --八点时间
            stepEndTime = nil
        else --报名没有结束
            stepStartTime = nil
            stepEndTime = endTime
        end
        
    end]]

    --print("stepStartTime,stepEndTime,status",stepStartTime,stepEndTime,status)

    return stepStartTime,stepEndTime,status
end


function CityBattleMode:AsyncGetRoundData(fun)

    local function onRecv(result, msgData)
        if result == true then
            PrepareInfo = msgData
            if fun then
                fun()
            end
            require("game.uilayer.cityBattle.CityMap").UpdateStatus()
        end
    end
    g_sgHttp.postData("City_Battle/getRoundInfo", {}, onRecv,true)
end 


function CityBattleMode:GetRoundData()
    local function onRecv(result, msgData)
        if result == true then
            PrepareInfo = msgData
            require("game.uilayer.cityBattle.CityMap").UpdateStatus()
        end
    end
    g_sgHttp.postData("City_Battle/getRoundInfo", {}, onRecv)
end

function CityBattleMode:GetShopConfig(cityId)
    
    if cityId == nil then return end

    local data = {}
    local shop = g_data.shop
    if ShopData == nil then
        ShopData = {}
        for key, var in pairs(shop) do
            if var.shop_type == 3 then
                table.insert(ShopData,var)
            end
        end

        table.sort(ShopData,function (a1,a2)
            return a1.id < a2.id
        end)
    end

    for key, var in ipairs(ShopData) do
        if var.city_id == cityId then
            table.insert(data,var)
        end
    end
    
    return data
    
end


function CityBattleMode:GetPrepareInfo()
    if PrepareInfo == nil then
        self:GetRoundData()
    end
    return PrepareInfo
end

--跳转到战斗界面
function CityBattleMode:GoToBattleWorld()
    
    local signData = self:GetSignData()

    --玩家没有报名
    if signData == nil or signData == false then
        g_airBox.show(g_tr("city_battle_sign_nosign"))
        return
    end
    
    local gotoMap = function()
    		local doGogoMap = function(result,msgData)
    			g_busyTip.hide_1()
    			if result then
		        if not g_cityBattleInfoData.IsDoorMap() then --城门战失败方不能进入内城战
		            if g_cityBattleInfoData.CanEnterMeleeRound() then
		                require("game.mapcitybattle.changeMapScene").changeToWorld()
		            else
		                g_airBox.show( g_tr("city_battle_lose") )
		            end
		        else
		            require("game.mapcitybattle.changeMapScene").changeToWorld()
		        end
	        end
        end
        g_busyTip.show_1()
        g_cityBattleInfoData.RequestDataAsync(doGogoMap)
    end

    local function goto2()
        local cityPlayerData = g_cityBattlePlayerData.GetData()
        if cityPlayerData then
            local status = cityPlayerData.status
            if tonumber(status) ~= 1 then
                local function callback(result, data)
                    g_busyTip.hide_1()
                    if result == true then
                        gotoMap()
                    end
                end
                g_busyTip.show_1()
                g_sgHttp.postData("City_Battle/enterBattlefield", {}, callback,true)
            else
                gotoMap()
            end
        end
    end
    
    local function goto1(r,d)
        if r == true then
            local player = d.player
            if player then
                if tonumber( player.status ) == 1 then
                    g_cityBattlePlayerData.RequestDataAsync(goto2,true)
                elseif tonumber( player.status ) == 2 then
                    g_airBox.show(g_tr("city_battle_sign_full"))
                end
            end
        end
    end

    CityBattleMode:AsyncGetSignInfo(goto1,nil,true)
end

--获取可攻击的城池
function CityBattleMode:GetCanSignCity(cityId)
    local m_battle_city = {}
    local canBattle = false
    local cityConfig = g_data.country_city_map[ tonumber(cityId) ]
    local campId = g_PlayerMode.GetData().camp_id

    if cityConfig then
        --初始城池的ID
        local m_city = self:GetCityMapConfig(campId)
        m_battle_city[tostring(m_city.id)] = true
        --已经占领城池的ID
        if OccupyData then
            local campData = OccupyData.camp_data[tonumber(campId)]
            if campData and campData.city_ids then
                for key, var in ipairs(campData.city_ids) do
                    m_battle_city[tostring(var)] = true
                end
            end
        end

        for key, var in ipairs(cityConfig.link) do
            if m_battle_city[tostring(var)] then
                canBattle = true
                break
            end
        end
    end
    
    return canBattle

end

function CityBattleMode:GetCanSignCityCondition(cityId)
    local conditionStr = {}
    local cityConfig = g_data.country_city_map[tonumber(cityId)]
    if cityConfig then
        for i, linkCityId in ipairs(cityConfig.link) do
            local city = g_data.country_city_map[tonumber(linkCityId)]
            if city and city.city_type ~= 1 then
                table.insert(conditionStr,g_tr(city.ctiy_name))
                --conditionStr = conditionStr .. g_tr(city.ctiy_name)  .. ( i ~= #cityConfig.link and  "," or "" )
            end
        end
    end

    conditionStr = "【" .. table.concat(conditionStr,"，") .. "】"

    return conditionStr
end


function CityBattleMode:GetSignData()
    if SignData == nil then
        self:GetSignInfo()
    end
    return SignData
end

function CityBattleMode:SetSignData(data)
    SignData = data
end


function CityBattleMode:GetSignInfo(cityId)
    local cityId = cityId or 2001
    local campId = g_PlayerMode.GetData().camp_id
    if campId and campId ~= 0 then
        local function onRecv(r,d)
            if r == true then
                self:SetSignData(d.player)
            end
        end
        g_sgHttp.postData("city_battle/getSignInfo", { cityId = cityId ,campId = campId }, onRecv)
    else
        self:SetSignData(false)
    end
end

function CityBattleMode:AsyncGetSignInfo(fun,cityId,isShow)
    isShow = isShow or false
    local campId = g_PlayerMode.GetData().camp_id
    local cityId = cityId or 2001
    if campId and campId ~= 0 then
        local function onRecv(r,d)
            if isShow then
                g_busyTip.hide_1()
            end
           
            if r == true then
                self:SetSignData(d.player)
            end
            
            if fun then
                fun(r,d)
            end
        end
        
        if isShow then
            g_busyTip.show_1()
        end

        g_sgHttp.postData("city_battle/getSignInfo", { cityId = cityId ,campId = campId }, onRecv, true)
    else
        self:SetSignData(false)
    end
end

--入口函数
function CityBattleMode.isOpen( node )
    if node == nil then
        return
    end

    local function vis()
        if OpenTime <= g_clock.getCurServerTime() then
            node:setVisible(true)
        else
            node:setVisible(false)
        end
    end
    
    if OpenTime == nil then
        node:setVisible(false)
        local function onRecv(r,d)
            if r == true then
                OpenTime = d.date
                --vis()
            end
        end
        g_sgHttp.postData("city_battle/getFirstCityBattleDate",{},onRecv,true)
    else
        vis()
    end
end

--是否报名或者报名但是没有筛选
function CityBattleMode:isSign()

    local data = self:GetSignData()

    if data  == nil or data  == false then
        return false
    end

    if data then
        if tonumber(data.status) == 2 then
            return false
        elseif tonumber(data.status) == 1 then
            return true
        end
    end

    return false

end


function CityBattleMode:GetPrepareStatus()
    local data = self:GetPrepareInfo()
    if data then
        return data.status
    end
end


function CityBattleMode:GetOpenTime()
    return OpenTime
end

return CityBattleMode
