--region BattleHallInfoView.lua
--Author : luqingqing
--Date   : 2015/12/3
--此文件由[BabeLua]插件自动生成

local BattleHallInfoView = class("BattleHallInfoView", require("game.uilayer.base.BaseLayer"))

function BattleHallInfoView:ctor(data, cancelGather, quitGather, enterCallback, updateList, gotoPos)
    BattleHallInfoView.super.ctor(self)

    self.mode = require("game.uilayer.battleHall.BattleHallMode").new()

    self.data = data
    self.cancelGathe = cancelGather
    self.quitGathe = quitGather
    self.enterCallback = enterCallback
    self.updateList = updateList
    self.gotoPos = gotoPos

    self:initUI()
    self:setData()
end

function BattleHallInfoView:initUI()

    self.layout = self:loadUI("alliance_WarDetails1.csb")
    self.root = self.layout:getChildByName("scale_node")
    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_2 = self.root:getChildByName("Text_2")
    self.Text_3 = self.root:getChildByName("Text_3")
    self.Text_4 = self.root:getChildByName("Text_4")
    self.Text_5 = self.root:getChildByName("Text_5")
    self.Text_6 = self.root:getChildByName("Text_6")
    self.Image_5 = self.root:getChildByName("Image_5")
    self.LoadingBar_1 = self.root:getChildByName("LoadingBar_1")
    self.Text_7 = self.root:getChildByName("Text_7")
    self.Text_8 = self.root:getChildByName("Text_8")
    self.Text_9 = self.root:getChildByName("Text_9")
    self.Text_10 = self.root:getChildByName("Text_10")
    self.Text_11 = self.root:getChildByName("Text_11")
    self.Text_12 = self.root:getChildByName("Text_12")
    self.ListView_2 = self.root:getChildByName("ListView_2")

    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_txt = self.Button_1:getChildByName("Text_12")

    self.Text_1:setString(g_tr("collectionInfo"))
    --self.Text_2:setString(g_tr("collectTarget"))
    self.Text_5:setString(g_tr("collectionBattle"))
    self.Text_7:setString(g_tr("collectLeader"))
    self.Text_9:setString(g_tr("collectArmyNum"))
    self.Button_txt:setString(g_tr("collectionDissolution"))

    self.isCancel = false

    self:initFun()
    self:addEvent()
end

function BattleHallInfoView:initFun()
    self.gotoGather = function()
        self.enterGather(self.data)
    end

    self.updateParent = function()
        if self.updateList ~= nil  then
            self.updateList()
        end
    end

    self.removeItem = function(item)

        if item:getData().arrived == 0 then
            g_airBox.show(g_tr("cannotArrvite"))
            return
        end

        self.mode:kickGather(item:getData().player_id, self.data[1].id, self.updateParent)
        self.ListView_2:removeItem(self.ListView_2:getIndex(item))
    end
    
    --去集结
    self.enterGather = function(data)
        if g_PlayerMode.hasAvoid() and self.data[1].target_info.type ~= "attackBoss"then
            g_msgBox.show( g_tr("battleMissAegis"),nil,2,
            function ( eventType )
                --确定
                if eventType == 0 then 
                    local function gotoCollection(ArmyId,PlaySound,isUseMove)
            
            if self.enterCallback ~= nil then
                self.enterCallback(self.data[1].end_time - g_clock.getCurServerTime(), data, ArmyId,isUseMove)
            end

            self:close()
        end
        
        local setLayer = require("game.uilayer.battleSet.battleSettingView")
        setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostNpcTeamAid)
        setLayer:createLayer(gotoCollection, {x=self.data[1].from_x,y=self.data[1].from_y},g_Consts.FightType.Expedition)
                end
            end , 1)
        else
            local function gotoCollection(ArmyId,PlaySound,isUseMove)
            
            if self.enterCallback ~= nil then
                self.enterCallback(self.data[1].end_time - g_clock.getCurServerTime(), data, ArmyId,isUseMove)
            end

            self:close()
        end

        local setLayer = require("game.uilayer.battleSet.battleSettingView")
        setLayer:setUsePowerType(g_Consts.FightCostPowerType.CostNpcTeamAid)
        setLayer:createLayer(gotoCollection, {x=self.data[1].from_x,y=self.data[1].from_y},g_Consts.FightType.Expedition)
        end


        
    end
end

function BattleHallInfoView:setData()
    local player = g_PlayerMode.GetData()

    local node = g_gameTools.getWorldMapElementDisplay(self.data[1].target_info.element_id)
    node:setScale(0.7)
    self.Image_5:addChild(node)

    if self.data[1].target_info.type == "attackBoss" then
        self.Text_2:setString(g_tr(g_data.map_element[tonumber(self.data[1].target_info.element_id)].name))
    else
        self.Text_2:setString(self.data[1].target_info.to_player_nick)
    end
    
    self.Text_3:setString("x:"..self.data[1].target_info.to_x)
    self.Text_4:setString("y:"..self.data[1].target_info.to_y)
    self.Text_8:setString("("..self.data[1].guild_name..")"..self.data[1].player_nick)
    self.Text_10:setString(#self.data.."")

    local isEnter = false
    local isArrival = false
    for i=1, #self.data do
        local item = require("game.uilayer.battleHall.BattleInfoItemView").new(self.data[1], self.data[i], self.removeItem)

        self.ListView_2:pushBackCustomItem(item)

        if player.id ~= self.data[1].player_id and self.data[i].player_id == player.id then
            isEnter = true
            isArrival = self.data[i].arrived
        end
    end

    if isEnter==false and self.data[1].player_id ~= player.id then
        for i=(#self.data)+1, self.data[1].maxGatherNum do
            local item = require("game.uilayer.battleHall.BattleInfoNoItemView").new(self.gotoGather)

            self.ListView_2:pushBackCustomItem(item)
        end
    end

    if player.id == self.data[1].player_id then
        self.Button_1:setVisible(true)
    else
        if isEnter == false or  isArrival == false then
            self.Button_1:setVisible(false)
        else
            self.Button_txt:setString(g_tr_original("collectQuit"))
            self.Button_1:setVisible(true)
        end
    end
    

    self:setTime()
end

function BattleHallInfoView:addEvent()
    local player = g_PlayerMode.GetData()

    local data = nil
    for i=1, #self.data do
        if player.id == self.data[i].player_id then
            data = self.data[i]
            break
        end
    end

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.Image_5 then
                self.gotoPos(self.data[1].target_info.to_x, self.data[1].target_info.to_y)
                self:close()
            elseif sender == self.Button_1 then
                if self.isCancel == true then
                    return
                end
                self.isCancel = true

                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.data[1].player_id == player.id then
                    g_msgBox.show( g_tr("cancelBattle"),nil,2,
                        function (eventtype)
                            --确定
                            if eventtype == 0 then 
                                if self.cancelGathe ~= nil then
                                    self.cancelGathe(self.data[1].id)
                                end
                                self:close()
                            else
                                self.isCancel = false
                            end
                        end , 1)
                else
                    local tag = false
                    for i=1, #self.data do
                        if self.data[i].arrived == 1 and self.data[i].player_id == player.id then
                            tag = true
                            break
                        end
                    end
                    if tag == true then
                        if self.quitGathe ~= nil then
                            self.quitGathe(data.id)
                        end

                        if self.buildTimer ~= nil then
                            self:unschedule(self.buildTimer)

                            self.buildTimer = nil
                        end
                        self:close()
                    else
                        g_airBox.show(g_tr("cannotArrvite"))
                    end
                end
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
    self.Button_1:addTouchEventListener(proClick)
    self.Image_5:addTouchEventListener(proClick)
end

function BattleHallInfoView:setTime()
    local function updateTime()
        local dt = self.data[1].end_time - g_clock.getCurServerTime()
        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.buildTimer1)
            self.buildTimer1 = nil

            if self.finishBack ~= nil  then
                self.finishBack(self)
            end
        end

        self.LoadingBar_1:setPercent(dt*100/(self.data[1].end_time - self.data[1].create_time))

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self.Text_6:setString(string.format("%02d:%02d:%02d", hour, min, sec))      
    end 

    if self.buildTimer then       
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
    end

    self.needTime = self.data[1].end_time - self.data[1].create_time + g_clock.getCurServerTime()

    if self.needTime > g_clock.getCurServerTime() then 
        self.buildTimer = self:schedule(updateTime, 1.0)
        updateTime()
    end 
end

function BattleHallInfoView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function BattleHallInfoView:unschedule(action)
  self:stopAction(action)
end

return BattleHallInfoView

--endregion
