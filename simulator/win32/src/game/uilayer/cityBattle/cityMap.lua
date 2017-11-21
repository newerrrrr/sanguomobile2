local CityMap = class("CityMap",require("game.uilayer.base.BaseLayer"))
local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()
local m_Root = nil

function CityMap:ctor()
    CityMap.super.ctor(self)
    m_Root = self
    self.camp_id = g_PlayerMode.GetData().camp_id
    self.cityNodes = {}
    self.giftData = {}
end

function CityMap:onEnter()

     local function _Load()
        if m_Root == nil then
            return
        end
        
        --local prepareData = CityBattleMode:GetPrepareInfo()
        --if prepareData then
            --if prepareData.status ~= g_Consts.CityBattleStatus.FINISH then
                local function _ShowSignCity(r,d)
                    if r == true then
                        if m_Root == nil then
                            return
                        end
                        self:SetSign()
                    end
                end
                CityBattleMode:AsyncGetSignInfo(_ShowSignCity)
            --end
            --[[if prepareData.status == g_Consts.CityBattleStatus.DOING then
                --g_msgBox.show()
                g_msgBox.show( g_tr("city_battle_battle_doing"),nil,2,
                function ( eventtype )
                    --确定
                    if eventtype == 0 then 
                        CityBattleMode:GoToBattleWorld()
                    end
                end , 1)
            end]]
       --end
    end

    CityBattleMode:AsyncGetRoundData(_Load)
    
    local function onRecv(r,d)
        if r == true then
            if m_Root == nil then
                return
            end
            self.giftData = d
            local m_city = CityBattleMode:GetCityMapConfig(self.camp_id)
            self.giftData[ tostring(m_city.id) ] = nil
            self:_UpdateGift()
        end
    end

    g_sgHttp.postData("city_battle/output", { is_get_time = 1 }, onRecv, true)

    if self.camp_id and self.camp_id > 0 then
        self:_InitUI()
    else
        if not g_AllianceMode.isAllianceManager() then
            g_airBox.show(g_tr("city_battle_battle_nocamp"))
        end

        require("game.uilayer.alliance.managelayer.AllianceManageCamp").show()
        self:close()
    end
    
end


function CityMap:_InitUI()
    self.layer = self:loadUI("CityBattle_panel_03.csb")
    self.root = self.layer:getChildByName("scale_node")

    local cityPanel = self.root:getChildByName("Panel_an")

    local config = g_data.country_city_map
    
    local mainCity = CityBattleMode:GetCityMapConfig(self.camp_id)
    --不可操作城池
    for i = 1, 3 do
        local str = string.format( "10%02d",i )
        local c = config[  tonumber(str) ]
        local cityBtn = cityPanel:getChildByName("Button_" ..str  )
        if cityBtn then
            cityBtn:getChildByName("Text_12"):setString(g_tr(c.ctiy_name))
            cityBtn:loadTextureNormal( g_resManager.getResPath(c.city_pic) )
        end
    end
    --可操作的城池
    for i = 1, 4 do
        local str = string.format( "20%02d",i )
        local c = config[  tonumber(str) ]
        local cityBtn = cityPanel:getChildByName("Button_" ..str  )
        if cityBtn then
            local name = g_tr(c.ctiy_name)
            cityBtn:getChildByName("Text_12"):setString(name)
            cityBtn:loadTextureNormal( g_resManager.getResPath(c.city_pic) )
            cityBtn:addClickEventListener(handler(self,self.TouchCity))
            cityBtn.cityId = tonumber(str)
            cityBtn.name = name
            self.cityNodes[tostring( str )] = { city = cityBtn }
        end
    end
    
    local menu = require("game.uilayer.cityBattle.CityMenu"):create()
    self:addChild(menu)

    local top = g_gameTools.LoadCocosUI("CityBattle_panel_top.csb",1)
    local res = g_resourcesInterface.installResources(top)
    res:setPositionY(0)
    self:addChild(top)
    self.top = top
    local btnRank = top:getChildByName("scale_node"):getChildByName("Image_6")
    btnRank:getChildByName("Text_10"):setString(g_tr("rankTitleStr"))
    btnRank:addClickEventListener(function()
            local view = require("game.uilayer.cityBattle.CityBattleRankList"):create()
            g_sceneManager.addNodeForUI(view)    
        end)

    self:initOccupyInfo() 
    self:_UpdateStatus()

    self.top:getChildByName("scale_node"):getChildByName("Panel_status"):setVisible(false)
    top:getChildByName("scale_node"):getChildByName("Image_wenh"):addClickEventListener(function ()
        require("game.uilayer.common.HelpInfoBox"):show( 54 )
    end)

    local btnChangeTeam = self.top:getChildByName("scale_node"):getChildByName("Image_3") 
    btnChangeTeam:getChildByName("Text_5"):setString(g_tr("city_battle_reward_title"))
    btnChangeTeam:addClickEventListener( function ( sender )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local view = require("game.uilayer.cityBattle.CityBattleReward"):create()
        g_sceneManager.addNodeForUI(view)
    end)
    

end

function CityMap:TouchCity(sender)
    local view = require("game.uilayer.cityBattle.CityShow"):create(sender.cityId)
    --local view = require("game.uilayer.cityBattle.CityShop"):create(sender.cityId)
    g_sceneManager.addNodeForUI(view)
end

function CityMap:initOccupyInfo()
    if nil == self.top then return end 

    local Panel_ss = self.top:getChildByName("scale_node"):getChildByName("Panel_ss")
    Panel_ss:getChildByName("Button_1"):getChildByName("Text_6"):setString(g_tr("short_country3"))
    Panel_ss:getChildByName("Button_2"):getChildByName("Text_6"):setString(g_tr("short_country2"))
    Panel_ss:getChildByName("Button_3"):getChildByName("Text_6"):setString(g_tr("short_country1"))

    Panel_ss:getChildByName("Text_z1"):setString(g_tr("city_battle_occupy_num"))
    Panel_ss:getChildByName("Text_s1"):setString("") 
    Panel_ss:getChildByName("Text_s2"):setString("") 
    Panel_ss:getChildByName("Text_s3"):setString("") 
    Panel_ss:getChildByName("Text_sy1"):setString(g_tr("city_battle_cur_round"))
    Panel_ss:getChildByName("Text_sy1_0"):setString("") 
    Panel_ss:addClickEventListener(function()
        local view = require("game.uilayer.cityBattle.CityBattleOccupyInfo"):create()
        g_sceneManager.addNodeForUI(view)                
        end)

    local data = CityBattleMode:getOccupyInfo()
    if nil == data or (os.time() > data.lastReqTime + 30) then 
        -- g_busyTip.show_1()
        CityBattleMode:RequestOccupyInfo(true, handler(self, self.updateOccupyUI)) 
    else 
        self:updateOccupyUI()
    end 
end

function CityMap:updateOccupyUI()
    -- g_busyTip.hide_1()

    if nil == self.root then return end 

    local data = CityBattleMode:getOccupyInfo() 
    if nil == data then return end 
    
    local Panel_ss = self.top:getChildByName("scale_node"):getChildByName("Panel_ss")
    if data.camp_data then 
        for i=1, 3 do 
            local label = Panel_ss:getChildByName("Text_s"..i)
            for k, v in pairs(data.camp_data) do 
                if v.camp_id == i then 
                    label:setString(""..v.city_number)
                    break 
                end 
            end 
        end 
    end 
    
    local lbRounds = Panel_ss:getChildByName("Text_sy1_0") 
    if data.remain_round and tonumber(data.remain_round) > 0 then 
        local maxRound = tonumber(g_data.country_basic_setting[5].data)
        lbRounds:setString(string.format("%d/%d", maxRound-data.remain_round,maxRound))
    else 
        lbRounds:setString(g_tr("city_battle_season_reset"))
    end 

    self:UpdateCityPanel()

end 


function CityMap:UpdateCityPanel()
    local data = CityBattleMode:getOccupyInfo()
    --dump(data)
    if data == nil then
        return 
    end

    for key, node in pairs(self.cityNodes) do
        node.city:getChildByName("Image_zl"):setVisible(false)
    end
    
    if data.camp_data then
        for _, camp in ipairs(data.camp_data) do
            local camp_id = camp.camp_id
            local camp_config = g_data.country_camp_list[camp_id]
            local camp_path = g_resManager.getResPath(camp_config.camp_pic)
            if camp.city_ids then
                for __, city_id in ipairs(camp.city_ids) do
                    local node = self.cityNodes[tostring(city_id)]
                    if node then
                        node.city:getChildByName("Image_zl"):setVisible(true)
                        node.city:getChildByName("Image_zl"):loadTexture(camp_path)
                    end
                end
            end
        end
    end
end


function CityMap:SetSign()
    
    local data = CityBattleMode:GetSignData()
    if data == nil then
        return
    end
    
    local prepareData = CityBattleMode:GetPrepareInfo()

    if prepareData.status == g_Consts.CityBattleStatus.FINISH or prepareData.status == g_Consts.CityBattleStatus.CLAC_REWARD then
        return
    end
    
    if data ~= nil and data ~= false then
        if self.cityNodes and table.nums(self.cityNodes) > 0 then
            for key, btn in pairs(self.cityNodes) do
                local tx = btn.city:getChildByName("Text_12")
                local name = btn.city.name
                tx:setString(name)
                if tonumber(data.city_id) == tonumber(key) then
                    tx:setString( string.format("%s(%s)",name,g_tr("city_battle_alread_sign")))
                end
            end
        end
    end

end


function CityMap:_UpdateStatus()
    local prepareData = CityBattleMode:GetPrepareInfo()
    self.top:getChildByName("scale_node"):getChildByName("Panel_status"):setVisible(true)
    local tx = self.top:getChildByName("scale_node"):getChildByName("Panel_status"):getChildByName("Text")
    local str = 
    {
        [g_Consts.CityBattleStatus.NOT_START] = g_tr("city_battle_status1"),
        [g_Consts.CityBattleStatus.SIGN_FIRST] = g_tr("city_battle_status2"),
        [g_Consts.CityBattleStatus.SIGN_NORMAL] = g_tr("city_battle_status3"),
        [g_Consts.CityBattleStatus.SELECT_PLAYER] = g_tr("city_battle_status4"),
        [g_Consts.CityBattleStatus.SELECT_PLAYER_FINISH] = g_tr("city_battle_status5"),
        [g_Consts.CityBattleStatus.DOING] = g_tr("city_battle_status6"),
        [g_Consts.CityBattleStatus.CLAC_REWARD] = g_tr("city_battle_status7"),
        [g_Consts.CityBattleStatus.FINISH] = g_tr("city_battle_status8"),
    }
    if prepareData then
        dump(prepareData)
        if prepareData.status then
            tx:setString( g_tr("city_battle_status_str") .. tostring(str[prepareData.status]))
        else
            tx:setString( g_tr("city_battle_status_str") .. g_tr("none"))
        end
    end
end


function CityMap:_UpdateGift()
    if self.giftData then
        for key, btn in pairs(self.cityNodes) do
            local time = self.giftData[tostring(btn.city.cityId)]
            local tx = btn.city:getChildByName("Text")
            tx:setVisible(false)
            if time and not g_clock.isSameDay( time , g_clock.getCurServerTime() ) then
               tx:setVisible(true)
            end 
        end
    end
end

function CityMap.GetGiftData()
    if m_Root then
        return m_Root.giftData
    end
end

function CityMap.UpdateGift()
    if m_Root then
        m_Root:_UpdateGift()
    end
end

function CityMap.UpdateStatus()
    if m_Root then
        m_Root:_UpdateStatus()
    end
end

function CityMap.Remove()
    if m_Root then
        m_Root:close()
    end
end

function CityMap.UpdateSign()
    if m_Root then
        m_Root:SetSign()
    end
end


function CityMap:onExit()
    m_Root = nil
end




return CityMap