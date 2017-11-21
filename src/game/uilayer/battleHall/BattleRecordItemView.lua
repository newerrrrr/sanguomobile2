--region BattleRecordItemView.lua
--Author : luqingqing
--Date   : 2015/12/4
--此文件由[BabeLua]插件自动生成

local BattleRecordItemView = class("BattleRecordItemView", require("game.uilayer.base.BaseWidget"))

function BattleRecordItemView:ctor(data, gotoPos)
    self.data = data
    self.gotoPos = gotoPos

    self.layer = self:LoadUI("HistoryReport1_02.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.Image_3 = self.root:getChildByName("Image_3")
    self.Image_1_0 = self.root:getChildByName("Image_1_0")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1_0 = self.root:getChildByName("Text_1_0")
    --胜利
    self.Image_4 = self.root:getChildByName("Image_4")
    --失败
    self.Image_5 = self.root:getChildByName("Image_5")
    
    self.Text_3 = self.root:getChildByName("Text_3")
    self.Image_3_0 = self.root:getChildByName("Image_3_0")
    self.Text_1_1 = self.root:getChildByName("Text_1_1")
    self.Text_1_0_0 = self.root:getChildByName("Text_1_0_0")

    self:setData()
    self:addEvent()
end

function BattleRecordItemView:setData()
    if tonumber(self.data.attack_player_id) == g_PlayerMode.GetData().id or tonumber(self.data.defend_player_id) == g_PlayerMode.GetData().id then
        self.Image_1_0:setVisible(true)
    else
        self.Image_1_0:setVisible(false)
    end


    --攻击者
    local iconid = nil
    if self.data.type == 10 then
        local tem = g_data.huangjin_attack_mob[tonumber(self.data.a_list)]
        iconid = g_data.soldier[tem.type_and_count[1][1]].img_head
    else
        iconid = g_data.res_head[self.data.attack_avatar_id].head_icon
    end
    self.Image_3:loadTexture( g_resManager.getResPath(iconid))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self.Image_3:addChild(imgFrame)
    imgFrame:setPosition(cc.p(self.Image_3:getContentSize().width/2, self.Image_3:getContentSize().height/2))

    if self.data.type == 10 then
        self.Text_1:setString(g_tr("waveNum", {num=self.data.a_list}))
    else
        if self.data.attack_guild_id == 0 then
            self.Text_1:setString(self.data.attack_player_name)
        else
            self.Text_1:setString("["..self.data.attack_guild_name.."]"..self.data.attack_player_name)
        end
    end
    

    self.Text_1_0:setString("x:"..self.data.attack_x.." y:"..self.data.attack_y)
    --防守者
    if self.data.type == 3 then
        self.Image_3_0:loadTexture( g_resManager.getResPath(1018001))
        self.Text_1_1:setString(g_tr("allianceFortress"))
    elseif self.data.type == 10 then
        self.Image_3_0:loadTexture( g_resManager.getResPath(1018001))
        self.Text_1_1:setString("["..self.data.defend_guild_name.."]"..g_tr("allianceFortress"))
    else
        local iconid = g_data.res_head[self.data.defend_avatar_id].head_icon
        self.Image_3_0:loadTexture( g_resManager.getResPath(iconid))

        local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
        self.Image_3_0:addChild(imgFrame)
        imgFrame:setPosition(cc.p(self.Image_3_0:getContentSize().width/2, self.Image_3_0:getContentSize().height/2))

        if self.data.defend_guild_id == 0 then
            self.Text_1_1:setString(self.data.defend_player_name)
        else
            self.Text_1_1:setString("["..self.data.defend_guild_name.."]"..self.data.defend_player_name)
        end
    end

    self.Text_1_0_0:setString("x:"..self.data.defend_x.." y:"..self.data.defend_y)

    if self.data.is_win == 0 then
        self.Image_4:setVisible(false)
        self.Image_5:setVisible(true)
    else
        self.Image_4:setVisible(true)
        self.Image_5:setVisible(false)
    end

    self:processTime()
end

function BattleRecordItemView:processTime()
    local time = g_clock.getCurServerTime() - self.data.create_time
     
     if time/3600/24 >= 1 then
        time = (time/3600/24)
        time = (time - time%1)..g_tr("day")
     elseif time/3600 >= 1 then
        time = (time/3600)
        time = (time - time%1)..g_tr("hour")
     elseif time/60 >= 1 then
        time = (time/60)
        time = (time - time%1)..g_tr("minute")
     else
        time = time
        time = (time - time%1)..g_tr("second")
     end
     
     self.Text_3:setString(time..g_tr("collectBefore"))
end

function BattleRecordItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.root then
                g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleRecordInfoView").new(self.data.id, self.gotoPos))
            end
        end
    end

    self.root:addTouchEventListener(proClick)
end

return BattleRecordItemView

--endregion
