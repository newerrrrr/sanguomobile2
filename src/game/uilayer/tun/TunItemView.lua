--region TunItemView.lua
--Author : luqingqing
--Date   : 2015/11/14
--此文件由[BabeLua]插件自动生成

local TunItemView = class("TunItemView", function() 
    return ccui.Widget:create()
end)

function TunItemView:ctor(data)
    self.data = data

    self.layout = cc.CSLoader:createNode("tunsuo_list_item.csb")
    self:addChild(self.layout)

    self.root = self.layout:getChildByName("scale_node")
    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))

    self.pic = self.root:getChildByName("pic")
    self.title = self.root:getChildByName("title")
    self.text_info = self.root:getChildByName("text_info")
    self.text_1 = self.root:getChildByName("text_1")
    self.text_num_1 = self.root:getChildByName("text_num_1")
    self.text_num_2 = self.root:getChildByName("text_num_2")

    self.text_1:setString(g_tr("tuoHelp"))

    self:initUi()
end

function TunItemView:initUi()
    self.title:setString(g_tr("tuoTitle"..self.data.help_type))
    self.text_num_1:setString(self.data.help_num.."")
    self.text_num_2:setString("/"..self.data.help_num_max)

    local iconid = g_data.res_head[self.data.player_avatar_id].head_icon
    self.pic:loadTexture( g_resManager.getResPath(iconid))

    local temData = nil
    if self.data.help_type == 1 then
        temData = g_data.build[self.data.help_resource_id]
        self.text_info:setString(g_tr("tuoType1", {player_name=self.data.player_nick, build_level = (temData.build_level + 1), build_name = g_tr(temData.build_name)}))
    elseif self.data.help_type == 2 then
        temData = g_data.science[self.data.help_resource_id]
        self.text_info:setString(g_tr("tuoType2", {player_name=self.data.player_nick, science_name = g_tr(temData.name)}))
    else
        self.text_info:setString(g_tr("tuoType3", {player_name=self.data.player_nick}))
    end
end

return TunItemView

--endregion
