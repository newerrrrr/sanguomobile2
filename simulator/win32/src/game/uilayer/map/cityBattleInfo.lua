local cityBattleInfo = class("cityBattleInfo", require("game.uilayer.base.BaseLayer"))

function cityBattleInfo:ctor(x,y)
    cityBattleInfo.super.ctor(self)
    self._x = x
    self._y = y
    self.warInfo = nil
end

function cityBattleInfo:InitUI()
    self.layer = self:loadUI("guildwar_fuhuodian03.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.root:getChildByName("Panel_3"):setVisible(false)
    local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
        return
	end)
    
    local mode = cc.CSLoader:createNode("guildwar_fuhuodian03_list1.csb")

    local battle_army = self.warInfo.battle_army
    for i, army in ipairs(battle_army) do
        local panel = self.root:getChildByName(string.format("Panel_%d",i))

        panel:setVisible(true)

        panel:getChildByName("Text_7"):setString(g_tr("information_def",{num = g_tr("num" .. i) }))
        
        local _panel = panel:getChildByName("Panel")

        if _panel == nil then
            break
        end

        for j, var in ipairs(army) do
            dump(var)
            local general_id = var.general_id
            if general_id and general_id > 0 then
                general_id = tonumber(general_id .. "01")
                local item = mode:clone()
                local general = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General,general_id,1)
                general:showGeneralServerStarLv(var.general_star)
                general:setScale(0.85)
                general:setCountEnabled(false)
                local generalPanel = item:getChildByName("Panel_dw")
                general:setPosition( cc.p(generalPanel:getContentSize().width/2,generalPanel:getContentSize().height/2) )
                
                local soldier_id = tonumber(var.soldier_id)
                if soldier_id ~= 0 then
                    local sConfig = g_data.soldier[soldier_id]
                    item:getChildByName("Image_2_0"):loadTexture(g_resManager.getResPath(sConfig.img_type))
                end

                item:getChildByName("Text_1"):setString(tostring(var.soldier_num or 0))

                generalPanel:addChild(general)
                item:setPositionX( item:getContentSize().width * (j - 1) )
                _panel:addChild(item)
            end
        end
    end

    if self.warInfo.reserve_army then
        local reserve_army = self.warInfo.reserve_army[1]
        local nameTx = self.root:getChildByName("Panel_3"):getChildByName("Text_9")
        local typeImg = self.root:getChildByName("Panel_3"):getChildByName("Image_2_0")
        local numTx = self.root:getChildByName("Panel_3"):getChildByName("Text_sz")
        numTx:setString("0")
        if reserve_army then
            if reserve_army.soldier_id > 0 then
                local soldier_id = tonumber(reserve_army.soldier_id)
                local sConfig = g_data.soldier[soldier_id]
                typeImg:loadTexture(g_resManager.getResPath(sConfig.img_type))
            end
            numTx:setString( tostring(reserve_army.num) )
        end
    else
        self.root:getChildByName("Panel_3"):setVisible(false)
        self.root:getChildByName("Text_3_0"):setVisible(false)
        self.root:getChildByName("Text_4_0"):setVisible(false)
    end

    self.root:getChildByName("bg_goods_name"):getChildByName("text"):setString(g_tr("information_title"))
    self.root:getChildByName("Text_1"):setString(g_tr("information_name"))
    self.root:getChildByName("Text_2"):setString(tostring(self.warInfo.nick))
    self.root:getChildByName("Text_3"):setString(g_tr("information_pos"))
    self.root:getChildByName("Text_4"):setString(string.format("X:%d,Y:%d",self._x,self._y))
    self.root:getChildByName("Text_3_0"):setString(g_tr("information_dur"))
    self.root:getChildByName("Text_4_0"):setString(tostring(self.warInfo.durability or 0))
    self.root:getChildByName("Panel_3"):getChildByName("Text_9"):setString(g_tr("information_rdef"))
end


function cityBattleInfo:onEnter()
    
    local guildWarStatus = g_cityBattleInfoData.getRealStatus()

    print("guildWarStatus",guildWarStatus)

    if guildWarStatus ~= g_cityBattleInfoData.StatusType.STATUS_SEIGE
    and guildWarStatus ~= g_cityBattleInfoData.StatusType.STATUS_MELEE

    then
        g_airBox.show(g_tr("guild_war_no_battle"))
        self:close()
        return 
    end
    
    local function onRecv(result, msgData)
        if(true == result)then
            dump(msgData)
            self.warInfo = msgData
            if self.warInfo == nil then
                self:close()
                return
            end

            if type(self.warInfo) == "table" and  next(self.warInfo) == nil then
                self:close()
                return
            end
            
            self:InitUI()
        else
            self:close()
        end
    end
    g_sgHttp.postData("City_Battle/spy",{ x = self._x , y = self._y },onRecv)
end


function cityBattleInfo:onExit()

end

return cityBattleInfo