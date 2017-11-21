local CityBattleReward = class("CityBattleReward",require("game.uilayer.base.BaseLayer"))

local GetStatus = 
{
    NoCanGet = 0,
    CanGet = 1,
    AlreadGet = 2,
}


function CityBattleReward:ctor()
    CityBattleReward.super.ctor(self)
    --self.occupyData = CityBattleMode:getOccupyInfo()
    --dump(self.occupyData)
end

function CityBattleReward:onEnter()
    local function onRecv(result,msgData)
        g_busyTip.hide_1() 
        if result == true then
            self.nData = {}
            for key, var in ipairs(msgData.award_id_status) do
                self.nData[tostring(var.award_id)] = var
            end

            self:initUI()
        end
    end
    g_busyTip.show_1() 
    g_sgHttp.postData("City_Battle/playerCampScoreAward", {}, onRecv) 

end

function CityBattleReward:initUI()
    self.layer = self:loadUI("CityBattle_popup05.csb")
    self.root = self.layer:getChildByName("scale_node")

    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addClickEventListener( function ()
         g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
         self:close()
    end )
    
    self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("taskAwardTitle"))
    
    self.list = self.root:getChildByName("Panel_h2"):getChildByName("ListView_1")
    self.panel = self.root:getChildByName("Panel_h2"):getChildByName("Panel_2")
    self:loadList()
    self:loadPanel()
    local tab1 = self.root:getChildByName("Button_1")
    tab1:getChildByName("Text_1"):setString(g_tr("city_battle_reward_tab1"))
    local tab2 = self.root:getChildByName("Button_2")
    tab2:getChildByName("Text_1"):setString(g_tr("city_battle_reward_tab2"))
    tab1:addClickEventListener( function ()
        tab1:setEnabled(false)
        tab2:setEnabled(true)
        self.list:setVisible(true)
        self.panel:setVisible(false)
    end )

    tab2:addClickEventListener( function ()
        tab1:setEnabled(true)
        tab2:setEnabled(false)
        self.list:setVisible(false)
        self.panel:setVisible(true)
    end )

    tab1:setEnabled(false)
    tab2:setEnabled(true)
    self.list:setVisible(true)
    self.panel:setVisible(false)
    

end

function CityBattleReward:loadPanel()
    local config = self:getConfig(8)
    local list = self.panel:getChildByName("ListView_3")
    local _width = 0
    for _, c in ipairs(config) do
        local dropConfig = g_data.drop[ tonumber(c.drop)].drop_data
        for _, dc in ipairs(dropConfig) do
            local itype = dc[1]
            local iid = dc[2]
            local inum = dc[3]
            local item = require("game.uilayer.common.DropItemView").new(itype,iid,inum)
            _width = _width + item:getContentSize().width + 15
            item:enableTip()
            list:pushBackCustomItem(item)
        end
    end

    list:setContentSize( cc.size( _width , list:getContentSize().height) )

    self.panel:getChildByName("Text_4_0"):setString(g_tr("city_battle_to_email"))
    self.panel:getChildByName("Text_4"):setString(g_tr("city_battle_season_reward"))


end


function CityBattleReward:loadList()
    local mode = cc.CSLoader:createNode("CityBattle_popup05_list1.csb")
    local config = self:getConfig(7)
    for _, c in ipairs(config) do
        local node = mode:clone()
        local tx = node:getChildByName("Text_")
        tx:setString( g_tr("city_battle_integral",{ num = c.rank_min }) )
        local list = node:getChildByName("ListView_1")
        list:setTouchEnabled(false)
        local dropConfig = g_data.drop[ tonumber(c.drop)].drop_data
        for _, dc in ipairs(dropConfig) do
            local itype = dc[1]
            local iid = dc[2]
            local inum = dc[3]
            local item = require("game.uilayer.common.DropItemView").new(itype,iid,inum)
            item:enableTip()
            item:setScale(0.8)
            list:pushBackCustomItem(item)
        end
        
        local rich = g_gameTools.createRichText(tx,g_tr("city_battle_integral",{ num = c.rank_min }))

        node:getChildByName("Image_j1"):setVisible(false)
        node:getChildByName("Image_j2"):setVisible(false)

        local rewardBtn = node:getChildByName("Button_1")
        local rewardTx = rewardBtn:getChildByName("Text_6")
        --:setString( g_tr("LimitedRewardGetOk") )

        local data = self.nData[tostring(c.id)]

        --未达成
        if data.award_flag == GetStatus.NoCanGet then
            rewardTx:setString(g_tr("city_battle_nocan_get"))
            rewardBtn:setEnabled(false)
        end
        --可领取
        if data.award_flag == GetStatus.CanGet then
            rewardTx:setString(g_tr("LimitedRewardGetOk"))
        end
         --已领取
        if data.award_flag == GetStatus.AlreadGet then
             rewardTx:setString(g_tr("isFetched"))
             rewardBtn:setEnabled(false)
        end
        
        rewardBtn:addClickEventListener( function (sender)
            local function onRecv(result,msgData)
                g_busyTip.hide_1() 
                if result == true then
                    rewardTx:setString(g_tr("isFetched"))
                    rewardBtn:setEnabled(false)
                    g_airBox.show(g_tr("fetchSucess"))
                end
            end
            g_busyTip.show_1() 
            g_sgHttp.postData("City_Battle/playerCampScoreAward", { country_battle_drop_id = c.id }, onRecv) 
        end )


        self.list:pushBackCustomItem(node)
    end
end

function CityBattleReward:getConfig( ctype )
    local config = {}
    for key, var in pairs(g_data.country_battle_drop) do
        if var.type == ctype then
            table.insert( config,var )
        end
    end

    table.sort( config , function (a,b)
        return a.id < b.id
    end )

    return config

end





return CityBattleReward
