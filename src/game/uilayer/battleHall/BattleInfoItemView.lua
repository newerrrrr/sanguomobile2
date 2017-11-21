--region BattleInfoItemView.lua
--Author : luqingqing
--Date   : 2015/12/3
--此文件由[BabeLua]插件自动生成

local BattleInfoItemView = class("BattleInfoItemView", require("game.uilayer.base.BaseWidget"))

function BattleInfoItemView:ctor(gatherData, data, removeItem)

    self.gatherData = gatherData
    self.data = data
    self.removeItem = removeItem

    self.layout = self:LoadUI("alliance_WarDetails2.csb")

    self.root = self.layout:getChildByName("scale_node")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_2 = self.root:getChildByName("Text_2")
    self.Text_3 = self.root:getChildByName("Text_3")
    self.Image_10 = self.root:getChildByName("Image_10")
    self.Image_13 = self.root:getChildByName("Image_13")

    self:setData()
    self:addEvent()
end

function BattleInfoItemView:setData()
    local player = g_PlayerMode.GetData()

    local head = g_data.res_head[self.data.player_avatar].head_icon
    self.Image_10:loadTexture( g_resManager.getResPath(head))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self.Image_10:addChild(imgFrame)
    imgFrame:setPosition(cc.p(self.Image_10:getContentSize().width/2, self.Image_10:getContentSize().height/2))

    self.Text_1:setString(self.data.guild_name)
    self.Text_3:setString(self.data.player_nick)
    if self.data.arrived == true then
        self.Text_2:setString(g_tr_original("collectHasCollect"))
    else
        self.Text_2:setString(g_tr_original("collectArmyMove"))
    end
    
    if self.gatherData.player_id == player.id then
        if player.id == self.data.player_id then
            self.Image_13:setVisible(false)
        else
            self.Image_13:setVisible(true)
        end 
    else
        self.Image_13:setVisible(false) 
    end

end

function BattleInfoItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Image_13 then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                g_msgBox.show(g_tr("kitCollectMember",{player_name = self.data.player_nick}),nil,nil,
                    function ( eventtype )
                        --确定
                        if eventtype == 0 then 
                            if self.removeItem ~= nil then
                                self.removeItem(self)
                            end
                        end
                    end , 1)
            elseif sender == self.Image_10 then
                local fightingInfoLayer = require("game.uilayer.map.fightingInfoLayer")
                fightingInfoLayer:createLayer(self.data.id)
            end
        end
    end

    self.Image_10:addTouchEventListener(proClick)
    self.Image_13:addTouchEventListener(proClick)
end

function BattleInfoItemView:getData()
    return self.data
end

return BattleInfoItemView

--endregion
