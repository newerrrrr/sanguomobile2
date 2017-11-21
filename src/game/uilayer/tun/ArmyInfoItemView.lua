--region ArmyInfoItemView.lua
--Author : luqingqing
--Date   : 2015/12/30
--此文件由[BabeLua]插件自动生成

local ArmyInfoItemView = class("ArmyInfoItemView", require("game.uilayer.base.BaseWidget"))

function ArmyInfoItemView:ctor(data)
    self.data = data

    self.layout = self:LoadUI("tunsuo_panel01.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.Image_22 = self.root:getChildByName("Image_22")
    self.Image_22_0 = self.root:getChildByName("Image_22_0")
    self.Image_22_0:setVisible(false)
    self.Text_1 = self.root:getChildByName("Text_1")

    self.Image_3_0 = self.root:getChildByName("Image_3_0")
    self.Text_shibingmingc_0 = self.root:getChildByName("Text_shibingmingc_0")
    self.Text_4 = self.root:getChildByName("Text_4")
    self.Text_shibingmingc = self.root:getChildByName("Text_shibingmingc")
    self.Image_2 = self.root:getChildByName("Image_2")

    self:setData()
end

function ArmyInfoItemView:setData()

    local gData = g_GeneralMode.GetBasicInfo(self.data.general_id, 1)
    local sData = g_data.soldier[self.data.soldier_id]

    self.Text_1:setString(g_tr(gData.general_name))

    self.Image_22:removeAllChildren()
    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, self.data.general_id*100+1, 1)
    item:setCountEnabled(false)
    item:setPosition(self.Image_22:getContentSize().width/2, self.Image_22:getContentSize().height/2)

    self.Image_22:addChild(item)
    if self.data.soldier_id ~= 0 then
        self.Image_3_0:loadTexture(g_resManager.getResPath(sData.img_head))  
        self.Text_shibingmingc:setString(g_tr(sData.soldier_name))
        self.Image_2:loadTexture(g_resManager.getResPath(sData.img_type))
    else
        self.Text_shibingmingc:setString("")
    end

     self.Text_4:setString(self.data.soldier_num.."")
     self.Text_shibingmingc_0:setString(g_tr("armyEnterNumber"))
    
end

return ArmyInfoItemView

--endregion
