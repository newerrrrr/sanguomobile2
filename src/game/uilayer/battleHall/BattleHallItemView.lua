--region BattleHallItemView.lua
--Author : luqingqing
--Date   : 2015/12/3
--此文件由[BabeLua]插件自动生成

local BattleHallItemView = class("BattleHallItemView", require("game.uilayer.base.BaseWidget"))

function BattleHallItemView:ctor(callback, inviteBack,gotoPos, enterCallback, finishBack, closeWin)
    self.clickCallback = callback
    self.inviteCallback = inviteBack
    self.gotoPos = gotoPos
    self.enterCallback = enterCallback
    self.finishBack = finishBack
    self.closeWin = closeWin

    self.layout = self:LoadUI("alliance_WarRecord01.csb")
    self.root = self.layout:getChildByName("scale_node")

    for i=1, 2 do
        self["scale_"..i] = self.root:getChildByName("scale_"..i)
        self["scale_"..i.."_Text_1"] = self["scale_"..i]:getChildByName("Text_1")
        self["scale_"..i.."_Text_2"] = self["scale_"..i]:getChildByName("Text_2")
        self["scale_"..i.."_Text_3"] = self["scale_"..i]:getChildByName("Text_3")
        self["scale_"..i.."_Image_4"] = self["scale_"..i]:getChildByName("Image_4")
        self["scale_"..i.."_Text_1"] = self["scale_"..i]:getChildByName("Text_1")
        self["scale_"..i.."_Image_liang"] = self["scale_"..i]:getChildByName("Image_liang")
        self["scale_"..i.."_Panel_dianjiquyu"] = self["scale_"..i]:getChildByName("Panel_dianjiquyu")

        self["scale_"..i.."_Panel_2"] = self["scale_"..i]:getChildByName("Panel_2")
        self["scale_"..i.."_Panel_2_Text_1"] = self["scale_"..i.."_Panel_2"]:getChildByName("Text_1")
        self["scale_"..i.."_Panel_2_Text_2"] = self["scale_"..i.."_Panel_2"]:getChildByName("Text_2")

        self["scale_"..i.."_Panel_3"] = self["scale_"..i]:getChildByName("Panel_3")
        self["scale_"..i.."_Panel_3_Text_1"] = self["scale_"..i.."_Panel_3"]:getChildByName("Text_1")
        self["scale_"..i.."_Panel_3_Text_2"] = self["scale_"..i.."_Panel_3"]:getChildByName("Text_2")
        self["scale_"..i.."_Panel_3_Text_8"] = self["scale_"..i.."_Panel_3"]:getChildByName("Text_8")
        self["scale_"..i.."_Panel_3_Image_2"] = self["scale_"..i.."_Panel_3"]:getChildByName("Image_2")
        self["scale_"..i.."_Panel_3_Image_3"] = self["scale_"..i.."_Panel_3"]:getChildByName("Image_3")
        self["scale_"..i.."_Panel_3_Image_4"] = self["scale_"..i.."_Panel_3"]:getChildByName("Image_4")
        self["scale_"..i.."_Panel_3_Text_4"] = self["scale_"..i.."_Panel_3"]:getChildByName("Text_4")
        self["scale_"..i.."_Panel_3_Text_4_0"] = self["scale_"..i.."_Panel_3"]:getChildByName("Text_4_0")
        self["scale_"..i.."_Panel_3_Text_4_1"] = self["scale_"..i.."_Panel_3"]:getChildByName("Text_4_1")
        self["scale_"..i.."_Panel_3_Text_4_2"] = self["scale_"..i.."_Panel_3"]:getChildByName("Text_4_2")
        self["scale_"..i.."_Panel_3_Button_2"] = self["scale_"..i.."_Panel_3"]:getChildByName("Button_2")
        self["scale_"..i.."_Panel_3_Button_2_txt"] = self["scale_"..i.."_Panel_3_Button_2"]:getChildByName("Text_5")
        self["scale_"..i.."_Panel_3_Button_2_txt"]:setString(g_tr("mainAllianceJoint"))

        self["scale_"..i.."_Panel_4"] = self["scale_"..i]:getChildByName("Panel_4")
        self["scale_"..i.."_Panel_4_Text_1"] = self["scale_"..i.."_Panel_4"]:getChildByName("Text_1")
        self["scale_"..i.."_Panel_4_Text_2"] = self["scale_"..i.."_Panel_4"]:getChildByName("Text_2")
        self["scale_"..i.."_Panel_4_Image_2"] = self["scale_"..i.."_Panel_4"]:getChildByName("Image_2")
        self["scale_"..i.."_Panel_4_Button_1"] = self["scale_"..i.."_Panel_4"]:getChildByName("Button_1")
        self["scale_"..i.."_Panel_4_Text_15"] = self["scale_"..i.."_Panel_4_Button_1"]:getChildByName("Text_15")

        self["scale_"..i.."_Panel_4_Text_15"]:setString(g_tr("battleInvite"))
        self["scale_"..i.."_Panel_3_Text_4"]:setString("")
        self["scale_"..i.."_Panel_3_Text_4_0"]:setString("")
        self["scale_"..i.."_Panel_3_Text_4_1"]:setString("")
        --self["scale_"..i.."_Panel_3_Text_4_2"]:setString("")
    end

    self:addEvent()
end

function BattleHallItemView:show(data1, data2)
    self.data1 = data1
    self.data2 = data2

    dump(self.data1)

    if self.buildTimer1 then       
        self:unschedule(self.buildTimer1)
        self.buildTimer1 = nil 
    end

    if self.buildTimer2 then       
        self:unschedule(self.buildTimer2)
        self.buildTimer2 = nil 
    end

    if self.data1 == nil then
        self.scale_1:setVisible(false)
    else
        self:initLeft()
        self:setTime1()
    end

    if self.data2 == nil then
        self.scale_2:setVisible(false)
    else
        self:initRight()
        self:setTime2()
    end
end

function BattleHallItemView:initLeft()
    self:setUI("scale_1", self.data1)
end

function BattleHallItemView:initRight()
    self:setUI("scale_2", self.data2)
end

function BattleHallItemView:setUI(ui, data)
    local player = g_PlayerMode.GetData()
    local gatherNum = data[1].maxGatherNum
    for i=1, #data do
        self[ui.."_Image_liang"]:setVisible(false)
        if data[i].player_id == player.id then
            self[ui.."_Panel_3_Button_2"]:setVisible(false)
            --self[ui.."_Image_liang"]:setVisible(true)
            break
        else
            if data[1].arrived == 2 then
                self[ui.."_Panel_3_Button_2"]:setVisible(false)
                break
            end
            self[ui.."_Panel_3_Button_2"]:setVisible(true)
        end
    end

    local node = g_gameTools.getWorldMapElementDisplay(data[1].target_info.element_id)
    node:setScale(0.7)
    self[ui.."_Image_4"]:addChild(node)
    self[ui.."_Panel_2_Text_1"]:setString("x:"..data[1].target_info.to_x)
    self[ui.."_Panel_2_Text_2"]:setString("y:"..data[1].target_info.to_y)
    self[ui.."_Panel_3_Text_1"]:setString("("..data[1].guild_name..")")
    self[ui.."_Panel_3_Text_2"]:setString(data[1].player_nick)
    self[ui.."_Panel_3_Text_8"]:setString((#data).."/"..gatherNum)
    self[ui.."_Panel_3_Text_4"]:setString(g_tr("collectHasCollect"))

    for i=1, 3 do
        if data[i] == nil then
            self[ui.."_Panel_3_Image_"..(i+1)]:setVisible(false)
            self[ui.."_Panel_3_Text_4_"..(i-2)]:setString("")
        else
            local head = g_data.res_head[data[i].player_avatar].head_icon
            self[ui.."_Panel_3_Image_"..(i+1)]:loadTexture( g_resManager.getResPath(head))
            self[ui.."_Panel_3_Image_"..(i+1)]:setVisible(true)

            local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
            self[ui.."_Panel_3_Image_"..(i+1)]:addChild(imgFrame)
            imgFrame:setPosition(cc.p(self[ui.."_Panel_3_Image_"..(i+1)]:getContentSize().width/2, self[ui.."_Panel_3_Image_"..(i+1)]:getContentSize().height/2))

            if i > 1 then
                if data[i].arrived == 1 then
                    self[ui.."_Panel_3_Text_4_"..(i-2)]:setString(g_tr("collectHasCollect"))
                else
                    self[ui.."_Panel_3_Text_4_"..(i-2)]:setString(g_tr("collectArmyMove"))
                end
            end

            if self[ui.."txtRich"] == nil then
                self[ui.."txtRich"] = g_gameTools.createRichText(self[ui.."_Text_1"], "")
            end

            if data[i].arrived == 2 then
                self[ui.."txtRich"]:setRichText(g_tr("battleArmyGo"))
            else
                self[ui.."txtRich"]:setRichText(g_tr("battleCollection"))
            end

            local iconid
            if data[1].target_info.type == "attackBoss" or data[1].target_info.type == "attackTown" then
                local mapData = g_data.map_element[tonumber(data[1].target_info.element_id)]
                iconid = mapData.img_mail
                self[ui.."_Panel_4_Text_1"]:setString("")
                self[ui.."_Panel_4_Text_2"]:setString("Lv"..mapData.level..g_tr(mapData.name))
                self[ui.."_Text_3"]:setString(g_tr(mapData.name))
            else
                iconid = g_data.res_head[data[1].target_info.to_player_avatar].head_icon
                self[ui.."_Panel_4_Text_1"]:setString("("..data[1].target_info.guild_name..")")
                self[ui.."_Panel_4_Text_2"]:setString(data[1].target_info.to_player_nick)
                self[ui.."_Text_3"]:setString(data[1].target_info.to_player_nick)
            end
            self[ui.."_Panel_4_Image_2"]:loadTexture( g_resManager.getResPath(iconid))

            local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
            self[ui.."_Panel_4_Image_2"]:addChild(imgFrame)
            imgFrame:setPosition(cc.p(self[ui.."_Panel_4_Image_2"]:getContentSize().width/2, self[ui.."_Panel_4_Image_2"]:getContentSize().height/2))
            if data[1].arrived == 1 then
                if data[1].player_id ~= player.id or #data == data[1].maxGatherNum then
                    self[ui.."_Panel_4_Button_1"]:setVisible(false)
                else
                    self[ui.."_Panel_4_Button_1"]:setVisible(true)
                end
            else
                self[ui.."_Panel_4_Button_1"]:setVisible(false)
            end
        end
    end
end

function BattleHallItemView:addEvent()
    local player = g_PlayerMode.GetData()

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if sender == self.scale_1 then
                if self.data1[1].arrived == 2 then
                    local fightingInfoLayer = require("game.uilayer.map.fightingInfoLayer")
                    fightingInfoLayer:createLayer(self.data1[1].id)
                    return
                end
                if self.clickCallback ~= nil then
                    self.clickCallback(self.data1)
                end
            elseif sender == self.scale_2 then
                if self.data2[1].arrived == 2 then
                    local fightingInfoLayer = require("game.uilayer.map.fightingInfoLayer")
                    fightingInfoLayer:createLayer(self.data2[1].id)
                    return
                end
                if self.clickCallback ~= nil then
                    self.clickCallback(self.data2)
                end
            elseif sender == self.scale_1_Panel_4_Button_1 then
                if self.inviteCallback ~= nil then
                    self.inviteCallback(self.data1)
                end
            elseif sender == self.scale_2_Panel_4_Button_1 then
                if self.inviteCallback ~= nil then
                    self.inviteCallback(self.data2)
                end
            elseif sender == self.scale_1_Panel_dianjiquyu then
                if self.gotoPos ~= nil then
                    self.gotoPos(self.data1[1].target_info.to_x, self.data1[1].target_info.to_y)
                end
            elseif sender == self.scale_2_Panel_dianjiquyu then
                if self.gotoPos ~= nil then
                    self.gotoPos(self.data2[1].target_info.to_x, self.data2[1].target_info.to_y)
                end
            elseif sender == self["scale_1_Panel_3_Button_2"] then
                if g_PlayerMode.hasAvoid() and self.data1[1].target_info.type ~= "attackBoss" then
                    g_msgBox.show( g_tr("battleMissAegis"),nil,2,
                    function ( eventType )
                    --确定
                        if eventType == 0 then 
                            local function gotoCollection(ArmyId,PlaySound,isUseMove)
                    if self.enterCallback ~= nil then
                        self.enterCallback(self.data1[1].end_time - g_clock.getCurServerTime(), self.data1, ArmyId,isUseMove)
                    end
                end

                local setLayer = require("game.uilayer.battleSet.battleSettingView")
                setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostNpcTeamAid)
                setLayer:createLayer(gotoCollection, {x=self.data1[1].from_x,y=self.data1[1].from_y},g_Consts.FightType.Expedition)

                if self.closeWin ~= nil then
                    setLayer:addCallBack(self.closeWin)
                end
                        end
                    end , 1)
                else
                    local function gotoCollection(ArmyId,PlaySound,isUseMove)
                    if self.enterCallback ~= nil then
                        self.enterCallback(self.data1[1].end_time - g_clock.getCurServerTime(), self.data1, ArmyId,isUseMove)
                    end
                end

                local setLayer = require("game.uilayer.battleSet.battleSettingView")
                setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostNpcTeamAid)
                setLayer:createLayer(gotoCollection, {x=self.data1[1].from_x,y=self.data1[1].from_y},g_Consts.FightType.Expedition)

                if self.closeWin ~= nil then
                    setLayer:addCallBack(self.closeWin)
                end
                end
                
            elseif sender == self["scale_2_Panel_3_Button_2"] then
                if g_PlayerMode.hasAvoid() and self.data2[1].target_info.type ~= "attackBoss" then
                    g_msgBox.show( g_tr("battleMissAegis"),nil,2,
                    function ( eventType )
                    --确定
                        if eventType == 0 then 
                            local function gotoCollection(ArmyId,PlaySound,isUseMove)
                    if self.enterCallback ~= nil then
                        self.enterCallback(self.data2[1].end_time - g_clock.getCurServerTime(), self.data2, ArmyId,isUseMove)
                    end
                end

                local setLayer = require("game.uilayer.battleSet.battleSettingView")
                setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostNpcTeamAid)
                setLayer:createLayer(gotoCollection, {x=self.data2[1].from_x,y=self.data2[1].from_y},g_Consts.FightType.Expedition)
                if self.closeWin ~= nil then
                    setLayer:addCallBack(self.closeWin)
                end
                        end
                    end , 1)
                else
                    local function gotoCollection(ArmyId,PlaySound,isUseMove)
                    if self.enterCallback ~= nil then
                        self.enterCallback(self.data2[1].end_time - g_clock.getCurServerTime(), self.data2, ArmyId,isUseMove)
                    end
                end

                local setLayer = require("game.uilayer.battleSet.battleSettingView")
                setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostNpcTeamAid)
                setLayer:createLayer(gotoCollection, {x=self.data2[1].from_x,y=self.data2[1].from_y},g_Consts.FightType.Expedition)
                if self.closeWin ~= nil then
                    setLayer:addCallBack(self.closeWin)
                end
                end

                
            end
        end
    end

    self.scale_1:addTouchEventListener(proClick)
    self.scale_2:addTouchEventListener(proClick)
    self.scale_1_Panel_4_Button_1:addTouchEventListener(proClick)
    self.scale_2_Panel_4_Button_1:addTouchEventListener(proClick)
    self.scale_1_Panel_dianjiquyu:addTouchEventListener(proClick)
    self.scale_2_Panel_dianjiquyu:addTouchEventListener(proClick)
    self["scale_1_Panel_3_Button_2"]:addTouchEventListener(proClick)
    self["scale_2_Panel_3_Button_2"]:addTouchEventListener(proClick)
end

function BattleHallItemView:setTime1()
    
    local function updateTime()
        local dt = self.data1[1].end_time - g_clock.getCurServerTime()
        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.buildTimer1)
            self.buildTimer1 = nil

            if self.finishBack ~= nil  then
                self.finishBack(self)
            end
        end 

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self["scale_1_Text_2"]:setString(string.format("%02d:%02d:%02d", hour, min, sec))      
    end 

    if self.buildTimer1 then       
        self:unschedule(self.buildTimer1)
        self.buildTimer1 = nil 
    end

    self.needTime = self.data1[1].end_time

    if self.needTime > g_clock.getCurServerTime() then 
        self.buildTimer1 = self:schedule(updateTime, 1.0)
        updateTime()
    end 
end

function BattleHallItemView:setTime2()
    
    local function updateTime()
        local dt = self.data2[1].end_time - g_clock.getCurServerTime()
        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.buildTimer2)
            self.buildTimer2 = nil

            if self.finishBack ~= nil  then
                self.finishBack(self)
            end
        end 

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self["scale_2_Text_2"]:setString(string.format("%02d:%02d:%02d", hour, min, sec))      
    end 

    if self.buildTimer2 then       
        self:unschedule(self.buildTimer2)
        self.buildTimer2 = nil 
    end

    self.needTime = self.data2[1].end_time

    if self.needTime > g_clock.getCurServerTime() then 
        self.buildTimer2 = self:schedule(updateTime, 1.0)
        updateTime()
    end 
end

function BattleHallItemView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function BattleHallItemView:unschedule(action)
  self:stopAction(action)
end

return BattleHallItemView
--endregion
