--region DropShowView.lua
--Author : liuyi
--Date   : 2016/7/20
local DropShowView = class("DropShowView", require("game.uilayer.base.BaseLayer"))


function DropShowView:ctor(dropID)
    self.super.ctor(self)
    self.dropConfig = g_data.drop[dropID].drop_data
    --dump(self.dropConfig)
    self:initUI()
end

function DropShowView:initUI()

    self.layer = self:loadUI("turntable_resources_main2.csb")
    self.root = self.layer:getChildByName("scale_node")

    local mask = self.layer:getChildByName("mask")
    mask:setTouchEnabled(true)
	self:regBtnCallback(mask,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    self.root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
    self.root:getChildByName("Text_c2"):setString( g_tr("zhuanpanDropShowTitle") )
    self.root:getChildByName("Text_5"):setString( g_tr("zhuanpanDropShowDsc") )
    
    local list = self.root:getChildByName("ListView_1")
    --175
    local cell = 4
    local row = math.ceil( table.nums(self.dropConfig) / cell)
    local index = 1

    for i = 1, row do
        local layout = ccui.Layout:create()
        layout:setSize(cc.size( list:getContentSize().width,list:getContentSize().height/2 ))
        for j = 1, cell do
            local data = self.dropConfig[index]
            if data then
                local t = data[1]
                local d = data[2]
                local b = data[3]
                local item = require("game.uilayer.common.DropItemView").new(t,d,b)
                local posx = layout:getContentSize().width/cell
                item:setPositionX( posx * (j - 1) + item:getContentSize().width/2 + 15 )
                item:setPositionY( layout:getContentSize().height/2 )
                --item:setNameVisible(true)
                g_itemTips.tip(item,t,d)
                layout:addChild(item)
            end
            index = index + 1
        end
        list:pushBackCustomItem(layout)
    end

end

return DropShowView
