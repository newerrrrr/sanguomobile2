--region BattlePlayerItemVIew.lua
--Author : luqingqing
--Date   : 2016/4/13
--此文件由[BabeLua]插件自动生成

local BattlePlayerItemVIew = class("BattlePlayerItemVIew", require("game.uilayer.base.BaseWidget"))

function BattlePlayerItemVIew:ctor(data, callback)
    self.data = data
    self.callback = callback

    if self.data.isAttacker then
        self.layer = self:LoadUI("alliance_atk1.csb")
    else
        self.layer = self:LoadUI("alliance_atk2.csb")
    end

    self.root = self.layer:getChildByName("scale_node")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.LoadingBar_2 = self.root:getChildByName("LoadingBar_2")
    self.Text_18 = self.root:getChildByName("Text_18")

    for i=1, 2 do
        self["Panel_r"..i] = self.root:getChildByName("Panel_r"..i)
        self["Panel_r"..i.."_Image_k2"] = self["Panel_r"..i]:getChildByName("Image_k2")
        self["Panel_r"..i.."_Text_wj1"] = self["Panel_r"..i]:getChildByName("Text_wj1")
        self["Panel_r"..i.."_Text_wj2"] = self["Panel_r"..i]:getChildByName("Text_wj2")
        self["Panel_r"..i.."_Text_zb"] = self["Panel_r"..i]:getChildByName("Text_zb")
    end

    if self.data.isAttacker then
        self.Text_1:setString(g_tr("attack"))
    else
        self.Text_1:setString(g_tr("defend"))
    end

    --进攻
    if self.data.attackerGuild == "" then
        self.Panel_r1_Text_wj1:setString("")
    else
        self.Panel_r1_Text_wj1:setString("("..self.data.attackerGuild..")")
    end
    self.Panel_r1_Text_wj2:setString(self.data.attackerNick)
    self.Panel_r1_Text_zb:setString("x:"..self.data.attackerX.." y:"..self.data.attackerY)

    local iconid = g_data.res_head[self.data.attackerAvatar].head_icon
    self.Panel_r1_Image_k2:loadTexture( g_resManager.getResPath(iconid))

    --防守
    if self.data.defenderGuild == "" then
        self.Panel_r2_Text_wj1:setString("")
    else
        self.Panel_r2_Text_wj1:setString("("..self.data.defenderGuild..")")
    end
    self.Panel_r2_Text_wj2:setString(self.data.defenderNick)
    self.Panel_r2_Text_zb:setString("x:"..self.data.defenderX.." y:"..self.data.defenderY)

    if self.data.defenderAvatar ~= 0 then
        local iconid = g_data.res_head[self.data.defenderAvatar].head_icon
        self.Panel_r2_Image_k2:loadTexture( g_resManager.getResPath(iconid))
    else
        if self.data.type == "base" then
            self.Panel_r2_Image_k2:loadTexture( g_resManager.getResPath(g_data.map_element[101].img_mail))
        end
    end

    self:addEvent()
    self:addTime()
end

function BattlePlayerItemVIew:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Panel_r1_Text_zb then
                if self.callback ~= nil then
                    self.callback(self.data.attackerX, self.data.attackerY)
                end
            elseif sender == self.Panel_r2_Text_zb then
                if self.callback ~= nil then
                    self.callback(self.data.defenderX, self.data.defenderY)
                end
            end
        end
    end

    self.Panel_r1_Text_zb:addTouchEventListener(proClick)
    self.Panel_r2_Text_zb:addTouchEventListener(proClick)
end

function BattlePlayerItemVIew:addTime()

    local function updateTime()
        local dt = self.data.end_time - g_clock.getCurServerTime()

        if dt <= 0 then 
            dt = 0 
            self.needTime = 0 
            self:unschedule(self.buildTimer)
            self.buildTimer = nil
        end

        self.LoadingBar_2:setPercent(dt*100/(self.data.end_time - self.data.create_time))

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self.Text_18:setString(g_tr("battleStateGo")..string.format("%02d:%02d:%02d", hour, min, sec))      
    end

    if self.buildTimer then       
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
    end

    if self.data.end_time > g_clock.getCurServerTime() then 
        self.buildTimer = self:schedule(updateTime, 1.0)
        updateTime()
    end 
end

function BattlePlayerItemVIew:getSize()
    return self.root:getContentSize()
end

function BattlePlayerItemVIew:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function BattlePlayerItemVIew:unschedule(action)
  self:stopAction(action)
end

return BattlePlayerItemVIew

--endregion
