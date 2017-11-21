--region BagItemNoButtonView.lua
--Author : luqingqing
--Date   : 2016/2/1
--此文件由[BabeLua]插件自动生成

local BagItemNoButtonView = class("BagItemNoButtonView", require("game.uilayer.base.BaseLayer"))

function BagItemNoButtonView:ctor(data)
    BagItemNoButtonView.super.ctor(self)

    self.data = data

    self.layout = self:loadUI("Useprops_message_popup_1.csb")
    self.mask = self.layout:getChildByName("mask")
    self.root = self.layout:getChildByName("scale_node")
    self.content_popup = self.root:getChildByName("content_popup")
    self.txtTitle = self.content_popup:getChildByName("bg_title"):getChildByName("Text_2")
    self.Image_2 = self.content_popup:getChildByName("Image_2")
    self.txtItemName = self.content_popup:getChildByName("Text_6")
    self.txtItemInfo = self.content_popup:getChildByName("goods_info")
    
    local item = require("game.uilayer.common.DropItemView").new(self.data.item_type, self.data.item_id, self.data.num)
    self.Image_2:addChild(item)
    item:setPosition(self.Image_2:getContentSize().width/2, self.Image_2:getContentSize().height/2)
    --item:setCountEnabled(false)

    self.txtTitle:setString(g_tr("bagItemDetail"))
    self.txtItemName:setString(item:getName())
    self.txtItemInfo:setString(item:getDesc())

    self:addEvent()
end

function BagItemNoButtonView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.mask then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            end
        end
    end

    self.mask:addTouchEventListener(proClick)
end

return BagItemNoButtonView

--endregion
