local fightingInfoLayer = class("fightingInfoLayer", require("game.uilayer.base.BaseLayer"))

local fight_list_data = nil

function fightingInfoLayer:createLayer(queue_id)
    g_sceneManager.addNodeForUI( fightingInfoLayer:create(queue_id) )

    --print("queue_id",queue_id)
    --[[fight_list_data = nil

    local function callback( result , data )
        if true == result then
            fight_list_data = data.armyInfo
            if fight_list_data then
                g_sceneManager.addNodeForUI( fightingInfoLayer:create() )
            end
        end
    end

    g_sgHttp.postData("map/getQueueInfo", {queueId = queue_id }, callback)]]
end

function fightingInfoLayer:ctor(queue_id)
    fightingInfoLayer.super.ctor(self)
    self.queueId = queue_id
end

function fightingInfoLayer:onEnter()
    self.layout = self:loadUI("troops_main_details.csb")
    self.root = self.layout:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("Button_x")
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
    end)

     --zhcn
    self.root:getChildByName("Text_c2"):setString(g_tr("force_details_title"))

    self.fight_list_data = nil

    local function callback( result , data )
        g_busyTip.hide_1()
        if true == result then
            self.fight_list_data = data.armyInfo
            self:InitUI()
        else
            self:close()
        end
    end
    g_busyTip.show_1()
    local changeMapScene = require("game.maplayer.changeMapScene")
    local mapStatus = changeMapScene.getCurrentMapStatus()
    if mapStatus == changeMapScene.m_MapEnum.guildwar then
    	g_sgHttp.postData("cross/getQueueInfo", {queueId = self.queueId }, callback,true)
   	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
   		g_sgHttp.postData("City_Battle/getQueueInfo", {queueId = self.queueId }, callback,true)
		else
			g_sgHttp.postData("map/getQueueInfo", {queueId = self.queueId }, callback,true)
    end
end


function fightingInfoLayer:InitUI()
    --troops_main_details
    
    
    

   

    local list = self.root:getChildByName("ListView_1")

    local titlemode = cc.CSLoader:createNode("troops_main_details_list.csb")
    local itemmode = cc.CSLoader:createNode("troops_main_details_list_1.csb")

    for key, var in ipairs(self.fight_list_data) do
        local title = titlemode:clone()
        list:pushBackCustomItem(title)

        title:getChildByName("scale_node"):getChildByName("Text_1"):setString(var.player_nick)
        local rows = math.ceil(#var.army / 2)

        local index = 1
        local s_num = 0 --士兵数量  

        for i = 1, rows do
            
            local item = itemmode:clone()
            list:pushBackCustomItem(item)

            local item_root = item:getChildByName("scale_node")
            
            --UI与数据关联循环 一个是武将一个是士兵
            for j = 1, 2 do
                local n_data = var.army[index]
                local panel = item_root:getChildByName( string.format("Panel_%d",j))
                if n_data then
                    

                    local general_id = n_data.general_id
                    local soldier_id = n_data.soldier_id
                    local g_cdt = g_GeneralMode.GetBasicInfo(general_id,1) --武将配置信息
                    

                    print("general_id",general_id)

                    local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General, g_cdt.id, 1)
                    item:setCountEnabled(false)
                    item:setPosition( cc.p( panel:getChildByName("Image_1"):getContentSize().width/2,panel:getChildByName("Image_1"):getContentSize().height/2) )
                    
                    item:setNameVisible(true)
                    
                    --����
                    local name = panel:getChildByName("Text_1")
                    name:setString( g_tr(g_cdt.general_name) )
                    name:setVisible(false)
                    --[[ͷ��
                    local pic = panel:getChildByName("Image_1"):getChildByName("icon")
                    pic:loadTexture( g_resManager.getResPath(g_cdt.general_icon) )
                    ]]
                    panel:getChildByName("Image_1"):addChild(item)


                    local s_cdt = g_data.soldier[ tonumber(soldier_id) ]  --士兵配置表
                    local s_name = panel:getChildByName("Text_1_0")
                    local s_count = panel:getChildByName("Text_2")
                    local s_pic = panel:getChildByName("Image_1_0"):getChildByName("icon")
                    local s_lv = panel:getChildByName("Text_4")
                    s_lv:setVisible(false)
                    --print("img_level",s_cdt.img_level)

                    --imgSoldier:loadTexture( g_resManager.getResPath(dataArray[i]:getIconId()) )

                    if s_cdt then
                        --�����ȼ�ͼƬ
                        local s_lvImg = ccui.ImageView:create( g_resManager.getResPath(s_cdt.img_level) )
                        s_lvImg:setPosition(s_lv:getPosition())
                        s_lv:getParent():addChild(s_lvImg)
                        s_name:setString(g_tr( s_cdt.soldier_name ))
                        s_count:setString( tostring( n_data.soldier_num ) )
                        s_pic:loadTexture( g_resManager.getResPath(s_cdt.img_head) )
                    else
                        s_name:setVisible(false)
                        s_count:setString( "0" )
                        s_pic:setVisible(false)
                    end
                
                    s_num = s_num + n_data.soldier_num
                    index = index + 1
                else
                    panel:setVisible(false)
                    break
                end
            end
            
            title:getChildByName("scale_node"):getChildByName("Text_2"):setString( g_tr("force_details_num",{num = s_num }) )

        end
        
    end
   
end



function fightingInfoLayer:onExit()
    fight_list_data = nil
end 


return fightingInfoLayer