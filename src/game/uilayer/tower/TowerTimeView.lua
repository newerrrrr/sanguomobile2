--region NewFile_1.lua
--Author : luqingqing
--Date   : 2016/3/24
--此文件由[BabeLua]插件自动生成

local TowerTimeView = class("TowerTimeView", require("game.uilayer.base.BaseWidget"))

function TowerTimeView:ctor(data)
    self.data = data

    self.layer = self:LoadUI("tower_popup_army_row_2.csb")
    self.root  = self.layer:getChildByName("scale_node")

    self.Text_2 = self.root:getChildByName("Text_2")

    self:setTime()
end

function TowerTimeView:setTime()
    
    local function updateTime()
        local dt = self.data.end_time - g_clock.getCurServerTime()
        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.buildTimer)
            self.buildTimer = nil
        end 

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        local showStr = "towerAtt"
        if self.data.isZhenCha then
            showStr = "towerDec"
        end

        self.Text_2:setString(g_tr( showStr, {tower_time=string.format("%02d:%02d:%02d", hour, min, sec)}))
    end 

    if self.buildTimer then       
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
    end

    --dump(self.data)

    self.needTime = self.data.end_time - g_clock.getCurServerTime() + g_clock.getCurServerTime()

    print(self.needTime, "@@@@@@@")

    if self.needTime > g_clock.getCurServerTime() then 
        self.buildTimer = self:schedule(updateTime, 1.0)
        updateTime()
    end 
end

function TowerTimeView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function TowerTimeView:unschedule(action)
  self:stopAction(action)
end

return TowerTimeView

--endregion
