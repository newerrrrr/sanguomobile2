
local MapHelper = require "game.mapguildwar.worldMapLayer_helper"

local guildmap = class("guildmap",function ()
    return cc.CSLoader:createNode("guildmap.csb")
end)

function guildmap:ctor()
    self.guidData = g_guildWarGuildPlayersData.GetData()
    self:initUI()
    dump(self.guidData)
end

function guildmap:initUI()
    local map = self:getChildByName("Panel_1"):getChildByName("Image_3")
    local mode = self:getChildByName("Panel_1"):getChildByName("Image_1")
    local size = map:getContentSize()
    if self.guidData then
        for key, var in pairs(self.guidData) do
            local pos = cc.p( tonumber(var.x),tonumber(var.y))
            local m_pos = MapHelper.out_bigTileIndex_2_position(pos,size)
            local sp = mode:clone()
            sp:setPosition(m_pos)
            map:addChild(sp)
        end
    end

    mode:setVisible(false)

end

return guildmap

--guildmap.csb
