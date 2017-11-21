--region ActivitySurplusShow.lua
--Author : liuyi
--Date   : 2016/6/28
--翻牌剩余

local ActivitySurplusShow = class("ActivitySurplusShow", require("game.uilayer.base.BaseLayer"))

function ActivitySurplusShow:ctor(chestId,drawData)
    ActivitySurplusShow.super.ctor(self)
    local chestConfig = g_data.chest
    self.sortConfig = {}
    self.drawData = {}
    --drawData
    for key, var in pairs(chestConfig) do
        if var.chest_id == chestId then
            table.insert( self.sortConfig,var)
        end
    end
            
    table.sort( self.sortConfig,function (a,b)
        return a.id < b.id
    end )

    dump(drawData)

    for _, value in pairs(drawData) do
        self.drawData[value] = true
    end

    dump(self.drawData)


    self:initUI()
end


function ActivitySurplusShow:initUI()
    self.layer = self:loadUI("turntable_main3_list.csb")
    self.root = self.layer:getChildByName("scale_node")

    local mask = self.layer:getChildByName("mask")
    mask:setTouchEnabled(true)
	self:regBtnCallback(mask,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    self.root:getChildByName("Text_2_0"):setString(g_tr("clickhereclose"))
    self.root:getChildByName("Text_c2"):setString(g_tr("zhuanpanCk"))


    local itemVec = {}
    local index = 1
    while true do
        local item = self.root:getChildByName( string.format("Panel_%d",index))
        if item then
            table.insert(itemVec,item)
            index = index + 1
        else
            break
        end
    end

    local rankBorderId = {1005201,1005202,1005203,1005204,1005205}

    for index, item in ipairs(itemVec) do
        local cData = self.sortConfig[index]
        dump(cData)
        item:getChildByName("Image_21"):setVisible(self.drawData[cData.id] == true )
        
        if cData.type == 1 then
            local dropData = g_data.drop[cData.value].drop_data[1]
            local iItemType = dropData[1]
            local iItemId = dropData[2]
            local iItemNum = dropData[3]
            --print("=======================",iItemType,iItemId,iItemNum)
            local itemMode = require("game.uilayer.common.DropItemView").new(iItemType, iItemId,iItemNum)
            local rank = item:getChildByName("Image_1_0")
            rank:loadTexture(g_resManager.getResPath(rankBorderId[itemMode:getRank()]))
            item:getChildByName("Image_22"):loadTexture(itemMode:getIconPath())
            
            item:getChildByName("name"):setString(itemMode:getName())

            local numText = ccui.Text:create( tostring(itemMode:getCount()), "cocos/cocostudio_res/simhei.TTF", 22)
            numText:setAnchorPoint(cc.p(1,0.5))
            numText:setPosition( cc.p( rank:getContentSize().width - 58, 22) )
            numText:enableOutline(cc.c4b(0, 0, 0,255),2)
            item:addChild(numText)


            --icon = self:createItem(iconMode)
        else
            --暴击图标
            local baojiImgId= { [2] = 1019016, [3] = 1019017,[5] = 1019018,[8] = 1019019,[10] = 1019020 }
            item:getChildByName("Image_1_0"):loadTexture(g_resManager.getResPath(1005205))
            item:getChildByName("Image_22"):loadTexture(g_resManager.getResPath(baojiImgId[cData.value]))
            item:getChildByName("name"):setVisible(false)
            --icon = self:createItem()
            --local iconPic = ccui.ImageView:create( g_resManager.getResPath(baojiImgId[cData.value]) )
            --iconPic:setPosition( cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2) )
            --icon:addChild(iconPic)
        end
    end


    --[[local rankBorderId = {1005201,1005202,1005203,1005204,1005205}
    
    if itemMode == nil then
        return ccui.ImageView:create( g_resManager.getResPath(1005205) )
    end
    
    local rank = itemMode:getRank()

    local rank = ccui.ImageView:create( g_resManager.getResPath(rankBorderId[rank]))
    local icon = ccui.ImageView:create( itemMode:getIconPath())
    icon:setPosition( cc.p(rank:getContentSize().width/2,rank:getContentSize().height/2) )
    rank:addChild(icon)
    return rank]]


end





return ActivitySurplusShow
--endregion
