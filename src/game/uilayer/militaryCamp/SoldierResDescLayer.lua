local SoldierResDescLayer = class("SoldierResDescLayer", require("game.uilayer.base.BaseLayer"))

--local m_MaxCount = nil
--local buff_data = nil

function SoldierResDescLayer:ctor()
    SoldierResDescLayer.super.ctor(self)
    self:initUI()
end

function SoldierResDescLayer:initUI()
    
    self.layer = self:loadUI("shibingxunlian_res.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.layer:getChildByName("mask")
	self:regBtnCallback(close_btn,function ()
		self:close()
	end)
    
    local border = self.root:getChildByName("Image_equip")
    local pic = self.root:getChildByName("Panel_equip")
    local item_type = g_Consts.DropType.Resource
    local item_id = 10200
    local item_num = 0

    local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)
    item:setCountEnabled(false)
    item:setPosition(pic:getPosition())
    self.root:addChild(item)

    local h_food = require("game.uilayer.militaryCamp.MilitaryCampData"):getAllFarmlandsOutPut()
    self.root:getChildByName("Text_3_0"):setString( math.ceil(h_food) .. "/h" )
    --self.root:getChildByName("Text_3_0"):setVisible(false)

    self.root:getChildByName("Text_1"):setString(g_tr("SoldierTrainExplan"))

    local soldierConfig = g_data.soldier
    local consume = 0
    --consumption

    local data = g_SoldierMode:GetData() 
    for k, v in pairs(data) do 
        if tonumber(v.soldier_id) ~= nil and tonumber(v.soldier_id) ~= 0 then 
            consume = consume + v.num * ( soldierConfig[tonumber( v.soldier_id )].consumption / 10000 )
        end
    end

    local armyData = g_ArmyUnitMode.GetData()
    for k, v in pairs(armyData) do
        if tonumber(v.soldier_id) ~= nil and tonumber(v.soldier_id) ~= 0 then 
            consume = consume + v.soldier_num * soldierConfig[ tonumber(v.soldier_id) ].consumption/10000
        end
    end

    local food_out_debuff,food_out_debuffType = g_BuffMode.getFinalBuffValueByBuffKeyName("food_out_debuff")
    local buff_num = (food_out_debuffType == 1 and food_out_debuff / 10000 or food_out_debuff)
    consume = consume / (1 + buff_num)


    self.root:getChildByName("Text_3"):setString(g_tr("CampfoodOutPut"))
    self.root:getChildByName("Text_4"):setString(g_tr("CampfoodCost"))

    if consume > math.ceil(h_food) then
        self.root:getChildByName("Text_4_0"):setTextColor(cc.c3b(230,30,30))
    else
        self.root:getChildByName("Text_4_0"):setTextColor(cc.c3b(30,230,30))
    end

    self.root:getChildByName("Text_4_0"):setString( string.format("-%.2f/h",consume))
    --self.root:getChildByName("Text_4_0"):setVisible(false)
    self.root:getChildByName("skill_desc_1"):setString( string.format("%s\n\n%s\n\n%s",g_tr("CampDesc1"),g_tr("CampDesc2"),g_tr("CampDesc3")) )
    self.root:getChildByName("Button_1"):setString(g_tr("clickhereclose"))

    local gotoBtn = self.root:getChildByName("Button_3")
    gotoBtn:getChildByName("Text_5"):setString(g_tr("gotoPathBtn"))
    --gotoPathBtn
    self:regBtnCallback(gotoBtn,function ()
	    
        local pos = nil
        local buildData = g_PlayerBuildMode.GetData()
        if buildData == nil then
            return
        end

        for k, v in pairs(buildData) do
            if v.origin_build_id == g_PlayerBuildMode.m_BuildOriginType.food then
                pos = v.position
                break
            end
        end

        if pos == nil then
            return
        else
            
            if self.closeParFun then
                self.closeParFun()
            end

            self:close()

            require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(pos--[[,gotoSuccessHandler]])
        end

	end)

    
end

function SoldierResDescLayer:onEnter()

end

function SoldierResDescLayer:onExit()
    
end

function SoldierResDescLayer:addParClose(fun)
    self.closeParFun = fun
end

return SoldierResDescLayer