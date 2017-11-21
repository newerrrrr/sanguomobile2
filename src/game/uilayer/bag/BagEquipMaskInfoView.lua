--region BagEquipMaskInfoView.lua
--Author : luqingqing
--Date   : 2015/12/29
--此文件由[BabeLua]插件自动生成

local BagEquipMaskInfoView = class("BagEquipMaskInfoView", require("game.uilayer.base.BaseLayer"))

function BagEquipMaskInfoView:ctor(value, callback, saleCallback)
    BagEquipMaskInfoView.super.ctor(self)

    self.data = value
    self.clickBack = callback
    self.saleBack = saleCallback

    self.layout = self:loadUI("Useprops__info.csb")
    self.root = self.layout:getChildByName("scale_node")
    self.Panel_equip = self.root:getChildByName("Panel_equip")
    self.skill_desc = self.root:getChildByName("skill_desc")
    self.skill_desc_1 = self.root:getChildByName("skill_desc_1")
    self.skill_desc_2 = self.root:getChildByName("skill_desc_2")

    self.Button_2 = self.root:getChildByName("Button_2")
    self.Text_27 = self.root:getChildByName("Text_27")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_3 = self.root:getChildByName("Button_3")
    self.Text_28 = self.root:getChildByName("Text_28")

    self.Text_nz = self.root:getChildByName("Text_nz")

    self.Text_27:setString(g_tr("equipChange"))
    self.Text_1:setString(g_tr("titleTip"))
    self.Text_28:setString(g_tr("bagSale"))

    self:setData()
    self:addEvent()
end

function BagEquipMaskInfoView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close()
            elseif sender == self.Button_2 then
                if self.clickBack ~= nil then
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    self.clickBack()
                    self:close()
                end
            elseif sender == self.Button_3 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                dump(self.data)
                if self.saleBack ~= nil then
                    self.saleBack(self.data)
                end
                self:close()
            end
        end
    end

    self.Button_1:addTouchEventListener(proClick)
    self.Button_2:addTouchEventListener(proClick)
    self.Button_3:addTouchEventListener(proClick)
end

function BagEquipMaskInfoView:setData()
    --图片
    local data = g_data.equip_master[self.data.equip_master_id]

    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.MasterEquipment, self.data.equip_master_id, 1)
    self.Panel_equip:addChild(item)
    item:setPosition(self.Panel_equip:getContentSize().width/2, self.Panel_equip:getContentSize().height/2)
    item:setCountEnabled(false)
    self.Text_nz:setString(item:getName())

    local skillInfo =  g_MasterEquipMode.GetEquipSkillListById(self.data.id) 

    if #data.equip_skill_id == 0 then
        self.skill_desc:setString("")
        self.skill_desc_1:setString("")
        self.skill_desc_2:setString("")
    elseif #data.equip_skill_id == 1 then
        self.skill_desc:setString(skillInfo[1])
        self.skill_desc_1:setString("")
        self.skill_desc_2:setString("")
    elseif #data.equip_skill_id == 2 then
        self.skill_desc:setString(skillInfo[1])
        self.skill_desc_1:setString(skillInfo[2])
        self.skill_desc_2:setString("")
    end
end

return BagEquipMaskInfoView

--endregion
