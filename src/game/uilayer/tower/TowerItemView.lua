--region TowerItemView.lua
--Author : luqingqing
--Date   : 2015/11/12
--此文件由[BabeLua]插件自动生成

local TowerItemView = class("TowerItemView", require("game.uilayer.base.BaseWidget"))

function TowerItemView:ctor(data, clickBack)
    self.data = data[1]

    self.clickBack = clickBack

    self.layer = self:LoadUI("tower_popup_msg_item.csb")
    self.root = self.layer:getChildByName("scale_node")

    self.Image_3_0 = self.root:getChildByName("Image_3_0")
    self.btn = self.root:getChildByName("btn")
    self.pic = self.root:getChildByName("pic")
    self.attack_text = self.root:getChildByName("attack_text")

    self.Image_3_0:setVisible(false)
    self:initUi()
    self:addEvent()
end

function TowerItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.btn or self.root then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.clickBack ~= nil then
                    self.clickBack(self)
                end
            end
        end
    end

    self.btn:addTouchEventListener(proClick)
    self.root:addTouchEventListener(proClick)
end

function TowerItemView:initUi()
    
    local showStr = "towerTitle"

    if self.data.isZhenCha then
        showStr = "towerTitleZC"
    end

    self.attack_text:setString(g_tr( showStr, {player_name = self.data.player_nick}))
    local iconid = g_data.res_head[self.data.avatar_id].head_icon
    self.pic:loadTexture( g_resManager.getResPath(iconid) )
end

function TowerItemView:updateSelect()
    self.Image_3_0:setVisible(true)
end

function TowerItemView:clearSelect()
    self.Image_3_0:setVisible(false)
end

return TowerItemView
--endregion
