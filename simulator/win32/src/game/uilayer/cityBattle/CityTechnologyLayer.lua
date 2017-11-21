local CityTechnologyLayer = class("CityTechnologyLayer", require("game.uilayer.base.BaseLayer"))
local CityBattleMode = require("game.uilayer.cityBattle.CityBattleMode"):GetInstance()

local mRoot = nil

function CityTechnologyLayer:ctor()
    
    CityTechnologyLayer.super.ctor(self)
    self.nData = {}
    self.sel = nil
    mRoot = nil
    mRoot = self
end

function CityTechnologyLayer:_InitUI()
    self.layer = self:loadUI("citybattle_technology.csb")
    g_resourcesInterface.installResources(self.layer)
    self.root = self.layer:getChildByName("scale_node")

    self.root:getChildByName("Text_1"):setString(g_tr("city_battle_map_menu1"))
    self.root:getChildByName("Text_2"):setString(g_tr("city_battle_honor"))

    local backBtn = self.root:getChildByName("close_btn")

    backBtn:addClickEventListener( function ( sender )
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
    end)

    self.root:getChildByName("Image_3_0"):loadTexture(g_resManager.getResPath(g_data.item[12300].res_icon))
    self.hunziTx = self.root:getChildByName("Text_3")
    self:_UpdateJunZi()

    self.content = self:_CreateContent()
    local content = self.root:getChildByName("bg_content")
    content:addChild(self.content)

    self.root:getChildByName("Image_4"):addClickEventListener(function ()
        require("game.uilayer.common.HelpInfoBox"):show( 56 )
    end)

end
    
function CityTechnologyLayer:_CreateContent()
    local layer = cc.CSLoader:createNode("citybattle_tech_content.csb")
    local content = layer:getChildByName("content")
    self.list = content:getChildByName("ListView")
    local rightContent = content:getChildByName("bg_right_content")
    
    self.rightLayer = require("game.uilayer.cityBattle.CityContentRight"):create()
    rightContent:addChild(self.rightLayer)
    
    self:_LoadList()

    return layer
end


function CityTechnologyLayer:_LoadList()
    local cListData = CityBattleMode:GetFilterScienceConfig()
    local row = table.nums(cListData)
    local itemMode = cc.CSLoader:createNode("citybattle_tech_list_item.csb")
    local isLoad = true

    for i = 1,row do
        local key = tostring(10 + i)
        local var = cListData[ key ]
    --for key, var in pairs(cListData) do
        local item = itemMode:clone()
        local panel = item:getChildByName("tech_item")

        panel.update = function ()
            self.nData = CityBattleMode:GetServerData()
            local nData = self.nData[tostring(key)]
            local lv = nData and nData.science_level or 0
            if lv == 0 then lv = 1 end
            local data = var[lv]
            local nameTx = panel:getChildByName("name")
            local pic = panel:getChildByName("pic")
            local picpath = g_resManager.getResPath(data.icon_img) 
            local lvTx = panel:getChildByName("level"):getChildByName("Text_1")
            local dscTx = panel:getChildByName("name_br")
            local value = data.num_value
            
            panel:getChildByName("Image_29"):setVisible(lv == data.max_level)

            if data.num_type == 1 then
                value = value / 100
            end
            
            dscTx:setString(g_tr(data.description,{ num = value }))

            if dscTx.dscRich then
                dscTx.dscRich:removeFromParent()
                dscTx.dscRich = nil
            end
            if dscTx.dscRich == nil then
                dscTx.dscRich = g_gameTools.createRichText( dscTx , g_tr(data.description,{ num = value }))
            end

            nameTx:setString(g_tr(data.name))
            lvTx:setString("Lv".. tostring( nData and nData.science_level or 0 ) )
            pic:loadTexture(picpath)
            
            panel.data = data
            panel.nData = nData
        end

        panel.update()

        panel:getChildByName("Image_28_0"):setVisible(false)
        panel:addClickEventListener(function (sender)
            if sender ~= self.sel then
                --print("data.id",data.id)
                self.sel:getChildByName("Image_28_0"):setVisible(false)
                self.rightLayer:Show(panel.nData,panel.data.science_type)
                self.sel = sender
                self.sel:getChildByName("Image_28_0"):setVisible(true)
            end
        end)

        if isLoad then
            self.sel = panel
            self.sel:getChildByName("Image_28_0"):setVisible(true)
            self.rightLayer:Show(self.sel.nData,self.sel.data.science_type)
            isLoad = false
        end

        self.list:pushBackCustomItem(item)
    end
end


function CityTechnologyLayer:onEnter()
    --[[self.nData = CityBattleMode:GetServerData()
    if self.nData then
        self:_InitUI()
    else
        self:close()
    end]]
    CityBattleMode:Req(true, function ()
        self.nData = CityBattleMode:GetServerData()
        if self.nData then
            self:_InitUI()
        else
            self:close()
        end
    end )

end

function CityTechnologyLayer.UpdateNode()
    if mRoot and mRoot.sel then
        mRoot.sel.update()
        mRoot:_UpdateJunZi()
    end
end

function CityTechnologyLayer:_UpdateJunZi()
    self.hunziTx:setString(tostring(g_PlayerMode.GetData().junzi or 0))
end

function CityTechnologyLayer:onExit()
    mRoot = nil
end



return CityTechnologyLayer