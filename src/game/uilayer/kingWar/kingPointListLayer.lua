
local kingPointListLayer = class("kingPointListLayer", require("game.uilayer.base.BaseLayer"))


function kingPointListLayer:ctor(data)
    
    kingPointListLayer.super.ctor(self)

    self.data = self:getData(data)
    
    self:initUI()

end

function kingPointListLayer:initUI()
    
    local layout = g_gameTools.LoadCocosUI("KingOfWar_integral_main.csb", 5)
    g_sceneManager.addNodeForUI(layout)

    local root = layout:getChildByName("scale_node")

    local close_btn = root:getChildByName("Button_x")
    close_btn:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            layout:removeFromParent()
        end
    end)

    root:getChildByName("Text_c2"):setString( g_tr("kwar_pointtitle") )
    root:getChildByName("Text_c3"):setString( g_tr("kwar_pointrank") )
    root:getChildByName("Text_c4"):setString( g_tr("kwar_pointguildname") )
    root:getChildByName("Text_c5"):setString( g_tr("kwar_pointguildpow") )
    root:getChildByName("Text_c5_0"):setString(  g_tr("kwar_pointstr") )


    local guildPointSortData = self.data

    --dump(guildPointSortData)

    local list = root:getChildByName("ListView_1")
    list:setItemsMargin(10)
    local itemMode = cc.CSLoader:createNode("KingOfWar_integral_list.csb")
    
    for index, value in ipairs(guildPointSortData) do
        local item = itemMode:clone()
        local panel = item:getChildByName("Panel_integral")
        panel:getChildByName("Text_1"):setString( tostring( index ) )
        panel:getChildByName("Text_6"):setString( tostring( value.guild_name or "") )
        panel:getChildByName("Text_7"):setString( tostring( value.guild_power or 0 ) )
        panel:getChildByName("Text_7_0"):setString( tostring( value.point or 0 ) )

        local currentIcon = g_AllianceMode.getAllianceIconId( value.guild_icon )
        local iconInfo = g_data.alliance_flag[currentIcon]

        panel:getChildByName("Image_6_1"):loadTexture( g_resManager.getResPath(iconInfo.res_flag) )

        if index == 1 then
            panel:getChildByName("Image_3_0"):setVisible(false)
            panel:getChildByName("Image_3_1"):setVisible(false)
        end

        if index == 2 then
            panel:getChildByName("Image_3"):setVisible(false)
            panel:getChildByName("Image_3_1"):setVisible(false)
        end

        if index == 3 then
            panel:getChildByName("Image_3"):setVisible(false)
            panel:getChildByName("Image_3_0"):setVisible(false)
        end

        if index > 3 then
            panel:getChildByName("Image_2"):setVisible(false)
            panel:getChildByName("Image_3"):setVisible(false)
            panel:getChildByName("Image_3_0"):setVisible(false)
            panel:getChildByName("Image_3_1"):setVisible(false)
        end

        list:pushBackCustomItem(item)

    end
end

function kingPointListLayer:getData(data)
    
    local sortData = data
    sortOKData = {}
     for _, var in pairs(sortData.GuildKingPoint) do
        table.insert( sortOKData,var )
    end

    table.sort( sortOKData,function (a,b)
        return a.point > b.point
    end )

    return sortOKData

end






return kingPointListLayer

