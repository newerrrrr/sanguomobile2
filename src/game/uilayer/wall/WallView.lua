--region WallView.lua
--Author : luqingqing
--Date   : 2015/11/2
--此文件由[BabeLua]插件自动生成

local WallView = class("WallView", require("game.uilayer.base.BaseLayer"))

function WallView:ctor()

    WallView.super.ctor(self)

    self.perAlert = 18 --18秒1点

    self.mode = require("game.uilayer.wall.WallMode").new()

    self.mode:refreshWall()

    self.player = g_PlayerMode.GetData()

    self.layer = self:loadUI("chengfang_layer.csb")

    self.root = self.layer:getChildByName("scale_node")
    self.Button_1 = self.root:getChildByName("Button_1")
    self.Image_9 = self.root:getChildByName("Image_9")

    self.Panel_2 = self.root:getChildByName("Panel_2")
    self.Panel_2_Text_1 = self.Panel_2:getChildByName("Text_1")

    self.Panel_3 = self.Panel_2:getChildByName("Panel_3")
    self.Panel_3_LoadingBar_1 = self.Panel_3:getChildByName("LoadingBar_1")
    self.Panel_3_Text_2 = self.Panel_3:getChildByName("Text_2")
    self.Panel_3_Text_2_0 = self.Panel_3:getChildByName("Text_2_0")

    self.Panel_4 = self.Panel_2:getChildByName("Panel_4")
    self.Panel_4_Text_3 = self.Panel_4:getChildByName("Text_3")
    self.Panel_4_Text_4 = self.Panel_4:getChildByName("Text_4")
    self.Panel_4_Button_3 = self.Panel_4:getChildByName("Button_3")
    self.Panel_4_Button_3_Text_7 = self.Panel_4_Button_3:getChildByName("Text_7")
    self.Panel_4_Button_3_Text_8 = self.Panel_4_Button_3:getChildByName("Text_8")
    

    self.Panel_4_Text_3:setString(g_tr("addDefend"))
    self.Panel_4_Button_3_Text_7:setString(g_tr("addDefend"))
    self.Panel_4_Button_3_Text_8:setString(g_data.starting[26].data.."")

    self.Panel_4_0 = self.Panel_2:getChildByName("Panel_4_0")
    self.Panel_4_0_Text_3 = self.Panel_4_0:getChildByName("Text_3")
    self.Panel_4_0_Text_4 = self.Panel_4_0:getChildByName("Text_4")
    self.Panel_4_Button_jiah = self.Panel_4_0:getChildByName("Button_jiah")
    self.Panel_t_Button_jiah_Text_11 = self.Panel_4_Button_jiah:getChildByName("Text_11")
    self.Panel_t_Button_jiah_Text_7_0 = self.Panel_4_Button_jiah:getChildByName("Text_7_0")
    self.Panel_t_Button_jiah_Text_7_0:setString(g_tr("addDefend"))
    for key, value in pairs(g_data.cost) do
        if value.cost_id == 2063 then
            self.Panel_t_Button_jiah_Text_11:setString(value.cost_num.."")
            break
        end
    end
    
    
    self.Panel_4_0_Button_3_0 = self.Panel_4_0:getChildByName("Button_3_0")
    self.Panel_4_0_Button_3_0_Text_7 = self.Panel_4_0_Button_3_0:getChildByName("Text_7")
    self.Panel_4_0_Button_3_0_Text_11 = self.Panel_4_0_Button_3_0:getChildByName("Text_11")

    self.Panel_4_0_Text_3:setString(g_tr("fireTime", {time=self.perAlert}))
    self.Panel_4_0_Button_3_0_Text_7:setString(g_tr("outFire"))
    self.Panel_4_0_Button_3_0_Text_11:setString(g_data.cost[10301].cost_num.."")

    self.Panel_4_1 = self.Panel_2:getChildByName("Panel_4_1")
    self.Panel_4_1_Text_4 = self.Panel_4_1:getChildByName("Text_4")
    self.Panel_4_1_Text_4_0 = self.Panel_4_1:getChildByName("Text_4_0")

    self.Panel_4_1_Text_4:setString(g_tr("wallPerfect"))
    self.Panel_4_1_Text_4_0:setString(g_tr("wallBuffInfo"))

    self.max_wall_durability = tonumber(self.player.wall_durability_max)

    self:initFun()
    self:initUi()
    self:addEvent()
end

function WallView:initFun()
    self.reqaire = function()
        self.player = g_PlayerMode.GetData()
        self.Panel_3_Text_2:setString(g_tr("addDefend"))
        self.Panel_3_Text_2_0:setString(self:countWallValue().."/"..self.max_wall_durability)
        local index = self.player.wall_durability*100/self.max_wall_durability
        index = index - index%1
        self.Panel_3_LoadingBar_1:setPercent(index)

        if g_clock.getCurServerTime() < self.player.fire_end_time then
            self:repaireState()
            self:fireState()
        else
            if self.player.wall_durability < self.max_wall_durability then
                self:repaireState()
        else
            self:wholeState()
        end
    end
    end

    self.fire = function()
        if self.player.wall_durability < self.max_wall_durability then
            self:repaireState()
        else
            self:wholeState()
        end
    end
end

function WallView:initUi()
    if self.player == nil then
        self:close()
        return
    end
    self.Panel_3_Text_2:setString(g_tr("addDefend"))
    self.Panel_3_Text_2_0:setString(self:countWallValue().."/"..self.max_wall_durability)
    local index = self.player.wall_durability*100/self.max_wall_durability
    index = index - index%1
    self.Panel_3_LoadingBar_1:setPercent(index)

    if g_clock.getCurServerTime() < self.player.fire_end_time then
        self:repaireState()
        self:fireState()
    else
        if self.player.wall_durability < self.max_wall_durability then
            self:repaireState()
        else
            self:wholeState()
        end
    end
end

function WallView:fireState()
    self.Panel_2_Text_1:setString(g_tr("fireStatus"))
    if (g_PlayerMode.GetData().rmb_gem + g_PlayerMode.GetData().gift_gem) >= 50 then
        self.Panel_4_0_Button_3_0:setEnabled(true)
    else
        self.Panel_4_0_Button_3_0:setEnabled(false)
    end
    
    local time = self.player.fire_end_time - g_clock.getCurServerTime()

    
    local result = ""
    if math.floor(time/3600) > 0 then
        result = math.floor(time/3600)..g_tr("hour")
    elseif math.floor(time/60) > 0 then
        result = math.floor(time/60)..g_tr("minute")
    else
        result = math.floor(time)..g_tr("second")
    end
    self.Panel_4_0_Text_4:setString(g_tr("inFireInfo", {time=result}))
end

function WallView:repaireState()
    self.Panel_4_1:setVisible(false)
    self.Panel_4:setVisible(true)
    self.Panel_4_0:setVisible(true)

    self.Panel_4_Text_4:setString(g_tr("addDefendInfo", {time=g_data.starting[27].data/60}))
    --self.Panel_4_0_Text_4_0:setString("1")
    --self.Panel_4_0_Text_4_0_0:setString((g_data.starting[27].data/60).."")

    if g_clock.getCurServerTime() - tonumber(self.player.last_repair_time) < tonumber(g_data.starting[27].data)  then
        self:setTime()
    end

    self.Panel_2_Text_1:setString(g_tr("bloodStatus"))
    self.Panel_4_0_Button_3_0:setEnabled(false)
    self.Panel_4_0_Text_4:setString(g_tr("noFireInfo"))
end

function WallView:wholeState()
    self.Panel_4_1:setVisible(true)
    self.Panel_4:setVisible(true)
    self.Panel_4_0:setVisible(true)

    self.Panel_2_Text_1:setString(g_tr("wallTitle"))
end

function WallView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                if self.buildTimer then       
                    self:unschedule(self.buildTimer)
                    self.buildTimer = nil 
                end
                self:close()
            elseif sender == self.Panel_4_Button_3 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.mode:restoreWallDurabilityAction(self.reqaire)
            elseif sender == self.Panel_4_0_Button_3_0 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                self.mode:clearFireAction(self.fire)
            elseif sender == self.Image_9 then
                local view = require("game.uilayer.common.HelpInfoBox").new()
                view:show(8)
                g_sceneManager.addNodeForUI(view)
            elseif sender == self.Panel_4_Button_jiah then
                local function buyEnd()
                    g_airBox.show(g_tr("bagUseItemSuc"))
                    self.reqaire()
                end
               g_msgBox.show( g_tr("wallItemUse",{item_name = g_tr(g_data.item[22203].item_name)}),nil,nil,
                    function ( eventtype )
                        --确定
                        if eventtype == 0 then
                            local mode = require("game.uilayer.bag.BagMode").new()
                            if g_BagMode.findItemNumberById(22203) > 0 then
                                mode:itemUse(22203, 1, buyEnd)
                            else
                                mode:shopBuy(2063, buyEnd)
                            end
                        end
                    end , 1)
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
    self.Panel_4_Button_3:addTouchEventListener(proClick)
    self.Panel_4_0_Button_3_0:addTouchEventListener(proClick)
    self.Image_9:addTouchEventListener(proClick)
    self.Panel_4_Button_jiah:addTouchEventListener(proClick)
end

function WallView:setTime()
    local function updateTime()
        local dt = self.player.last_repair_time - g_clock.getCurServerTime() + g_data.starting[27].data
        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.buildTimer)
            self.buildTimer = nil

            self.Panel_4_Button_3:setEnabled(true)
            if self.player.wall_durability < self.max_wall_durability then
                self:repaireState()
        
                if g_clock.getCurServerTime() < self.player.fire_end_time then
                    self:fireState()
                end
            else
                self:wholeState()
             end
        end 

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self.Panel_4_Text_4:setString(g_tr("wallLeftTime")..string.format("%02d:%02d:%02d", hour, min, sec))
    end

    if self.buildTimer then       
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
    end

    self.Panel_4_Button_3:setEnabled(false)
    self.buildTimer = self:schedule(updateTime, 1.0)
    updateTime()
end

--计算当前城墙值
function WallView:countWallValue()
    if self.player.fire_end_time <= g_clock.getCurServerTime() then
        return self.player.wall_durability
    end

    local needTime = g_clock.getCurServerTime() - self.player.durability_last_update_time
    local damage = needTime/self.perAlert
    damage = damage - damage%1

    if self.player.wall_durability - damage > self.max_wall_durability then
        return self.max_wall_durability
    elseif self.player.wall_durability - damage < 0 then
        return 0
    else
        return self.player.wall_durability - damage
    end
end

return WallView

--endregion
