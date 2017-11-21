--region BattleInfoNoItemView.lua
--Author : luqingqing
--Date   : 2015/12/3
--此文件由[BabeLua]插件自动生成

local BattleInfoNoItemView = class("BattleInfoNoItemView", require("game.uilayer.base.BaseWidget"))

function BattleInfoNoItemView:ctor(enterGather)
    self.enterGather = enterGather

    self.layout = self:LoadUI("alliance_WarDetails3.csb")
    self.root = self.layout:getChildByName("scale_node")
    
    self.Text_1 = self.root:getChildByName("Text_1")

    self.Text_1:setString(g_tr_original("collectUnCollect"))

    self:addEvent()
end

function BattleInfoNoItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.root then
                if self.enterGather ~= nil then
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    self.enterGather()
                end
            end
        end
    end

    self.root:addTouchEventListener(proClick)
end

return BattleInfoNoItemView

--endregion
