local mapPlayerInfoView = class("mapPlayerInfoView", require("game.uilayer.base.BaseLayer"))



function mapPlayerInfoView:ctor(playerId)
    mapPlayerInfoView.super.ctor(self)
    self.playerId = playerId
    self.my_player_data = g_PlayerMode.GetData()
end

function mapPlayerInfoView:onEnter( )
	--print("mapPlayerInfoView onEnter")
    
    self.layer = self:loadUI("zhugong_bg.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
    self.root:getChildByName("Text_zg"):setString( g_tr("MasterPlayerInfoStr") )
    --详情按钮全部隐藏
    self.root:getChildByName("left_siderbar"):setVisible(false)
    self.show_panel = self.root:getChildByName("general")
    self.equip_panel = self.root:getChildByName("equipment")
    self.gzTx = self.root:getChildByName("Text_gzmc")
    self.show_panel:setVisible(false)
    self.equip_panel:setVisible(false)
    self.gzTx:setVisible(false)
    local function onRecv( result, msgData )
        g_busyTip.hide_1()
        if result == true then
            self.player_data = msgData
            self.show_panel:setVisible(true)
            self.equip_panel:setVisible(true)
            self.gzTx:setVisible(true)
            self:initUI()
        else
            self:close()
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("player/viewTargetPlayerInfo",{ target_player_id = self.playerId },onRecv,true)
    
end

function mapPlayerInfoView:initUI()
    
    --展示图
    
    self.show_panel:getChildByName("border"):setVisible(false)
    self.show_panel:getChildByName("pic"):setVisible(false)

    local avatar_id = self.player_data.Player.avatar_id
   
    local bgid = g_data.res_head[avatar_id].bust_icon
    self.showIcon = ccui.ImageView:create(g_resManager.getResPath(bgid))
    self.showIcon:setPosition( cc.p(self.show_panel:getContentSize().width/2,self.show_panel:getContentSize().height/2) )
    self.show_panel:addChild( self.showIcon )
    self.showIcon:setScale(0.8)

    self.info_panel = cc.CSLoader:createNode("zhugong_player_info_2.csb")
    self.root:getChildByName("Panel_3"):addChild(self.info_panel)
    self:masterInfoView()
    
    local info_btn = self.root:getChildByName("left_siderbar"):getChildByName("Image_3_0")
    self:regBtnCallback(info_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local MasterInfoView = require("game.uilayer.master.MasterInfoView")
        MasterInfoView:createLayer( self.player_data.Player.id )
	end)

    --隐藏天赋按钮
    --self.root:getChildByName("left_siderbar"):getChildByName("Image_4_0"):setVisible(false)
    self.root:getChildByName("left_siderbar"):getChildByName("Image_4"):setVisible(false)
    self.root:getChildByName("left_siderbar"):getChildByName("Text_1_0"):setVisible(false)

    --{"code":0,"data":{"Player":{"id":100131,"server_id":1,"uuid":"fish-56723196644be","nick":"nick-56723196648ab","avatar_id":1,"level":1,"current_exp":0,"next_exp":100,"talent_num_total":5,"talent_num_remain":0,"general_num_total":20,"general_num_remain":20,"army_num":1,"army_general_num":2,"queue_num":1,"move":100,"move_max":100,"wall_durability":0,"wall_durability_max":0,"durability_last_update_time":0,"last_repair_time":0,"fire_end_time":0,"gold":200000,"food":200000,"wood":200000,"stone":200000,"iron":200000,"silver":0,"protected_gold":0,"protected_food":0,"protected_wood":0,"protected_stone":0,"protected_iron":0,"food_out":0,"move_in_time":0,"food_out_time":0,"rmb_gem":0,"gift_gem":0,"create_time":0,"login_time":0,"power":0,"study_pay_num":0,"guild_id":0,"guild_coin":0,"is_online":0,"map_id":29,"x":605,"y":123}},"basic":[]}
    --zhcn 玩家layer title
	--self.root:getChildByName("title"):getChildByName("Text_3"):setString( g_tr("playerInfo") )
    self.info_panel:getChildByName("Text_20"):setString(g_tr("MasterPlayerInfoStr"))
    
    --宝物信息
    self.player_data.PlayerEquipMaster = self.player_data.PlayerEquipMaster or {}

    
    local jobId = self.player_data.Player.job
    if jobId == nil or jobId == 0 then
        self.gzTx:setVisible(false)
    else
        self.gzTx:setString(g_tr(g_data.king_appoint[jobId].position_name))
    end

    self:showEquipUI()
end


function mapPlayerInfoView:showEquipUI(  )
    
	local equip_tb = {}
	local index = 1 

	--获取主公装备的UI节点
	while(index) do
		local e_panel = self.equip_panel:getChildByName(string.format( "item_%d", index ))
		if e_panel then
			local e_node = e_panel:getChildByName("Panel_2")
			e_node:setVisible(false)
			e_node:setTouchEnabled(false)
			table.insert( equip_tb, e_panel)
			index = index + 1
		else
			break
		end
	end

	--在装备列表里筛选存放主公身上的宝物
	self.equiped = {}
	for i,data in ipairs(self.player_data.PlayerEquipMaster) do
        if data.position > 0 then
            self.equiped[data.position] = data
        end
	end

	for i,e_panel in ipairs(equip_tb) do
		local data = self.equiped[i]
		local e_node = e_panel:getChildByName("Panel_2")
        e_panel:getChildByName("Image_1"):setVisible(false)
		if data then
            --dump(data)
			--[[local ctd = g_data.equip_master[ tonumber( data.equip_master_id ) ]
            local iconid = ctd.equip_icon
			e_node:getChildByName("pic"):loadTexture( g_resManager.getResPath(iconid) )
			e_node:getChildByName("level_bg"):getChildByName("level_num"):setString( string.format( "lv.%d",ctd.min_master_level ) )
            e_node:getChildByName("Text_3"):setString( g_tr(ctd.equip_name) )
			e_panel.selid = data.id
            ]]
            e_node:setVisible(true)
            e_node:getChildByName("Text_3"):setVisible(false)
            local equipType = g_Consts.DropType.MasterEquipment
            local equipID = tonumber(data.equip_master_id)
            local equipCount = 1
            local item = require("game.uilayer.common.DropItemView").new(equipType, equipID,equipCount)

            g_itemTips.tipMasterEquipmentByServerData(item,data)

            --ICON
            item:setPosition(cc.p( e_node:getContentSize().width/2,e_node:getContentSize().height/2 ))
            item:setCountEnabled(false)
            e_node:addChild(item)
            item:setNameVisible(true)
		else
			e_node:setVisible(false)
			e_panel.selid = 0
		end
	end
    
end

function mapPlayerInfoView:masterInfoView()
    
    --测试显示
    local playerIDTx = self.info_panel:getChildByName("Panel_3"):getChildByName("general_name_0")
    playerIDTx:setString(g_tr("PlayerCode") .. self.player_data.Player.user_code)
    
    local zhStr = ""
    local rmb =  self.player_data.Player.total_rmb or 0
    
    if tonumber(rmb) >= tonumber(g_data.country_basic_setting[17].data) then
        zhStr = string.format( "(%s)",g_tr("city_battle_zhuhou") )
    end

    --昵称
    local name = self.info_panel:getChildByName("Panel_3"):getChildByName("general_name")
    name:setString( zhStr .. self.player_data.Player.nick )
    --头像
    
    local head = self.info_panel:getChildByName("Panel_3"):getChildByName("Image_15_0")
    local iconid = g_data.res_head[self.player_data.Player.avatar_id].head_icon

    head:loadTexture( g_resManager.getResPath(iconid) )
    head:setScale(0.85)


    local countyPic = self.info_panel:getChildByName("Image_11")
    countyPic:setVisible(false)
    local campId = self.player_data.Player.camp_id
    if campId and campId ~= 0 then
        countyPic:setVisible(true)
        local camp_config = g_data.country_camp_list[campId]
        local camp_path = g_resManager.getResPath(camp_config.camp_pic)
        countyPic:loadTexture(camp_path)
    end


    --公会
    local guildTx = self.info_panel:getChildByName("Panel_3"):getChildByName("general_lianm")
    local guildName = g_tr("MasterGuildName")

    if self.player_data.Guild and  self.player_data.Guild.name then
        guildTx:setString(guildName .. self.player_data.Guild.name)
    else
        guildTx:setString(guildName .. g_tr(g_tr("MasterNoGuild")))
    end

    --head:loadTexture( g_resManager.getResPath(iconid) )

    --设置圆形剪切头像
    --[[local clipper = require("game.uilayer.master.MasterMode").createCircleHead(g_resManager.getResPath( iconid ))
    clipper:setPosition( cc.p( head:getContentSize().width/2,head:getContentSize().height/2 ) )
    head:addChild(clipper)]]

    --边框
    --local border = ccui.ImageView:create("freeImage/line.png")
    --border:setPosition( cc.p( head:getContentSize().width/2,head:getContentSize().height/2 ) )
    --head:addChild(border)


    --self.info_panel:getChildByName("Panel_3"):getChildByName("Image_15_0"):setVisible(false)


    --经验值
    --zhcn
    local levelStr = self.info_panel:getChildByName("level"):getChildByName("level_num"):setString( g_tr("level") .. ":")
    self.info_panel:getChildByName("Text_20_0"):setString(g_tr("MasterPowNum"))
    self.info_panel:getChildByName("Text_xm"):setString(g_tr("MasterKillNum"))
    local level = self.info_panel:getChildByName("level"):getChildByName("AtlasLabel_1")
    level:setString( tostring( self.player_data.Player.level ) )

    local exp_bar = self.info_panel:getChildByName("level"):getChildByName("LoadingBar_1")
    --local exp_tx = self.info_panel:getChildByName("level"):getChildByName("Text_11")

    local nv = self.player_data.Player.current_exp - g_data.master[ self.player_data.Player.level ].exp --升下一等级的剩余经验
    local tv = self.player_data.Player.next_exp - g_data.master[ self.player_data.Player.level ].exp

	exp_bar:setPercent( ( nv / tv ) * 100  )
	--exp_tx:setString( string.format( "%d/%d",nv,tv ) )

    --主公战力
    self.info_panel:getChildByName("Text_20_1"):setString( tostring(self.player_data.Player.power))
    --主公杀敌数
    self.info_panel:getChildByName("Text_xm1"):setString( tostring(self.player_data.Player.kill_soldier_num or 0))

    local send_email_btn = self.info_panel:getChildByName("Panel_3"):getChildByName("Button_2")
    self.info_panel:getChildByName("Panel_3"):getChildByName("Text_15"):setString(g_tr("sendMail"))
    --判断是不是自己
    if tostring(self.player_data.Player.id) == tostring(self.my_player_data.id) then
        send_email_btn:setVisible(false)
        self.info_panel:getChildByName("Panel_3"):getChildByName("Text_15"):setVisible(false)
    end

    self:regBtnCallback(send_email_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		--print("发送邮件")
        local pop = require("game.uilayer.mail.MailContentWritePop").new(false, self.player_data.Player.nick) 
        g_sceneManager.addNodeForMsgBox(pop)  

	end)
end


function mapPlayerInfoView:onExit( )
	print("mapPlayerInfoView onExit")
end


return mapPlayerInfoView