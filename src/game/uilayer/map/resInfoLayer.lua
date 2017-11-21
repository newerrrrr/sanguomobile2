local resInfoLayer = class("resInfoLayer", require("game.uilayer.base.BaseLayer"))

local data_config = nil

function resInfoLayer:createLayer(mapid)
    data_config = g_data.map_element[tonumber(mapid)]
    if data_config then
        g_sceneManager.addNodeForUI(resInfoLayer:create(mapid))
    else
        print("create error no find id:",mapid)
    end
end


function resInfoLayer:ctor(mapid)
    resInfoLayer.super.ctor(self)
    self:initUI(mapid)
end

function resInfoLayer:initUI(mapid)
    self.layer = self:loadUI("CollectionDescription_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("Button_x")
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
	    self:close()
    end)

    self.Title_tx = self.root:getChildByName("Text_c2")

    --print("data_config",data_config)

    local panel_1 = self.root:getChildByName("Panel_1")
    local img_1 = self.root:getChildByName("Panel_dingwei1")
    local txt_1 = panel_1:getChildByName("Text")
    
    local panel_2 = self.root:getChildByName("Panel_2")
    local img_2 = self.root:getChildByName("Panel_dingwei2")
    local txt_2 = panel_2:getChildByName("Text")

    local img_help = data_config.imy_help
    local desc_help = data_config.desc_help


    if img_help and desc_help then
        --print("asdasdasdasdasd",img_help[1],img_help[2])
        local str1 = g_resManager.getResPath(tonumber(img_help[1]))
        local str2 = g_resManager.getResPath(tonumber(img_help[2]))
        
        --img_1:loadTexture( str1 )
        --img_2:loadTexture( str2 )

        local img = ccui.ImageView:create(str1)
        img_1:addChild(img)
        img:setPosition(cc.p(img_1:getContentSize().width/2,img_1:getContentSize().height/2))

        local img = ccui.ImageView:create(str2)
        img_2:addChild(img)
        img:setPosition(cc.p(img_2:getContentSize().width/2,img_2:getContentSize().height/2))

        local descStr1 = desc_help[1]
        local descStr2 = desc_help[2]

        txt_1:setString( g_tr(descStr1) )
        txt_2:setString( g_tr(descStr2) )
        txt_1:setLocalZOrder(1)
        txt_2:setLocalZOrder(1)

    end


    self:setTitle()

end

function resInfoLayer:setTitle( str )
    str = str or g_tr("MapBuildDesc")
    self.Title_tx:setString(str)
end

function resInfoLayer:onEnter( )

end

function resInfoLayer:onExit( )
    data_config = nil
end

return resInfoLayer