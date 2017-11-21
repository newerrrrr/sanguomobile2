
local MasterView = class("MasterView", require("game.uilayer.base.BaseLayer"))
local m_Root = nil
local MODE = require("game.uilayer.master.MasterMode").new()

function MasterView:createLayer()
    self:clearGlobal()
    self.master_data = MODE:getMasterInfo()
    g_sceneManager.addNodeForUI(MasterView:create())
    return true
end

function MasterView:ctor()
	MasterView.super.ctor(self)
    g_guideManager.registGameFeature(self,g_guideManager.gameFeatures.MASTER_DETAIL)
    m_Root = nil
    m_Root = self
    self.sel_e_panel = nil --选中的主公宝物槽节点
    self.equiped = nil --主公身上已经装备的宝物 用来检索是否有相同宝物
    self:initUI()
end

function MasterView:initUI()
	self.layer = self:loadUI("zhugong_bg.csb")
	self.root = self.layer:getChildByName("scale_node")
    g_resourcesInterface.installResources(self.layer)
    local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
	

    self.root:getChildByName("left_siderbar"):setLocalZOrder(1)

	 --天赋按钮
    local talent_btn = self.root:getChildByName("left_siderbar"):getChildByName("Image_4")
    g_guideManager.registComponent(9999602,talent_btn)
    
	--zhcn 主公layer title
	self.root:getChildByName("Text_zg"):setString( g_tr("MasterTitle") )
    --主公展示
    self.show_panel = self.root:getChildByName("general")
    self:showPanelUI()
    --主公装备
    --异步获取最新的装备信息
    self.equip_panel = self.root:getChildByName("equipment")
    self:showEquipUI()

    if g_guideManager.execute() then
        local sche = nil
        local scheduler = cc.Director:getInstance():getScheduler()
        local  function callback()
            if g_MasterEquipMode.RequestData() then
                scheduler:unscheduleScriptEntry(sche) 
            end
        end
        --确保新手引导的主公装备成功
        sche = scheduler:scheduleScriptFunc(callback, 0.25, false)
    end
    
    --主公属性
    self.info_panel = cc.CSLoader:createNode("zhugong_player_info_1.csb")
    self.root:getChildByName("Panel_3"):addChild(self.info_panel)
    self:masterInfoView()
    --宝物列表
    self.equip_list_panel = cc.CSLoader:createNode("zhugong_player_info.csb")
    self.equip_list_panel:setVisible(false)
    self.root:getChildByName("Panel_3"):addChild(self.equip_list_panel)
    --self:showEquipListUI()

    --详情按钮
    local info_btn = self.root:getChildByName("left_siderbar"):getChildByName("Image_3_0")
    self:regBtnCallback(info_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local MasterInfoView = require("game.uilayer.master.MasterInfoView")
        MasterInfoView:createLayer()
	end)

    --zhcn
    self.root:getChildByName("left_siderbar"):getChildByName("Text_1"):setString(g_tr("MasterInfo"))

    local help_btn = self.root:getChildByName("left_siderbar"):getChildByName("Image_bz")
    self:regBtnCallback(help_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require("game.uilayer.power.FaqView").new())
    end)
    
    local help_tx = self.root:getChildByName("left_siderbar"):getChildByName("Text_bz")
    help_tx:setString(g_tr("tuoHelp"))
   
    local gzTx = self.root:getChildByName("Text_gzmc")
    local jobId = self.master_data.job

    if jobId == nil or jobId == 0 then
        gzTx:setVisible(false)
    else
        gzTx:setString( g_tr(g_data.king_appoint[jobId].position_name))
    end
    
    self.talentRedP = g_gameTools.addRedPoint(talent_btn,self.master_data.talent_num_remain)
    --天赋红点
    --self:talentRedPointUpdate()

    self:regBtnCallback(talent_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_guideManager.execute()
        --g_sceneManager.addNodeForUI( require("game.uilayer.master.MasterTalentView"):create() )
		require("game.uilayer.master.MasterTalentView"):createLayer()
        
	end)
    self.root:getChildByName("left_siderbar"):getChildByName("Text_1_0"):setString(g_tr("MasterTalent"))

    --zhcn
    local gameSet_btn = self.root:getChildByName("left_siderbar"):getChildByName("Text_sz"):setString(g_tr("MasterGameSetStr"))
    local gameSet_btn = self.root:getChildByName("left_siderbar"):getChildByName("Image_sz")
    self:regBtnCallback(gameSet_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_sceneManager.addNodeForUI(require "game.uilayer.setting.settingLayer".create())
    end)


    local guildName = g_tr("MasterGuildName")

    if g_AllianceMode.getSelfHaveAlliance() then
        local guildInfo = g_AllianceMode.getBaseData()
        guildName = guildName .. guildInfo.name
    else
        guildName = guildName .. g_tr("MasterNoGuild")
    end

    self.info_panel:getChildByName("Panel_3"):getChildByName("general_lianm"):setString(guildName)

end

--更新天赋
function MasterView:talentRedPointUpdate()


    if m_Root then
        local talent_btn = m_Root.root:getChildByName("left_siderbar"):getChildByName("Image_4")
        m_Root.master_data = MODE:getMasterInfo()
        if m_Root.talentRedP then
            m_Root.talentRedP:setString(m_Root.master_data.talent_num_remain)
            --主公战力
            m_Root.info_panel:getChildByName("Text_20_1"):setString( tostring(m_Root.master_data.power))
        end

        --m_Root:masterInfoView()
    end
end

--主公展示图
function MasterView:showPanelUI( )
    self.master_data = MODE:getMasterInfo()
	
    --[[
    local border_id = g_data.res_head[master_data.avatar_id].outline_icon
    local show_border = self.show_panel:getChildByName("border")
    show_border:loadTexture( g_resManager.getResPath(border_id) )
    local show_img = self.show_panel:getChildByName("pic")
    local iconid = g_data.res_head[master_data.avatar_id].bust_icon
    show_img:loadTexture( g_resManager.getResPath(iconid) )
    ]]

    self.show_panel:getChildByName("border"):setVisible(false)
    self.show_panel:getChildByName("pic"):setVisible(false)

    if self.showIcon ~= nil then
        self.showIcon:removeFromParent()
        self.showIcon = nil
    end

    if self.showIcon == nil then

        local avatar_id = self.master_data.avatar_id
        
        local bgid = g_data.res_head[avatar_id].bust_icon
        self.showIcon = ccui.ImageView:create(g_resManager.getResPath(bgid))
        self.showIcon:setPosition( cc.p(self.show_panel:getContentSize().width/2,self.show_panel:getContentSize().height/2) )
        self.show_panel:addChild( self.showIcon )
        self.showIcon:setScale(0.8)

        --[[local iconid = g_data.res_head[avatar_id].bust_icon
        local iconimg = ccui.ImageView:create(g_resManager.getResPath(iconid))
        iconimg:setPosition( cc.p(self.showIcon:getContentSize().width/2,self.showIcon:getContentSize().height/2) )
        self.showIcon:addChild(iconimg)


        local borderid = g_data.res_head[avatar_id].outline_icon
        local birderimg = ccui.ImageView:create(g_resManager.getResPath(borderid))
        birderimg:setPosition( cc.p(self.showIcon:getContentSize().width/2,self.showIcon:getContentSize().height/2) )
        self.showIcon:addChild(birderimg)]]

        --[[
        local borderid = g_data.res_head[avatar_id].outline_icon
        self.showIcon = ccui.ImageView:create(g_resManager.getResPath(borderid))
        self.showIcon:setPosition( cc.p(self.show_panel:getContentSize().width/2,self.show_panel:getContentSize().height/2) )
        self.show_panel:addChild( self.showIcon )
        self.showIcon:setScale(0.9)

        local bgid = g_data.res_head[avatar_id].back_icon
        local bgimg = ccui.ImageView:create(g_resManager.getResPath(bgid))
        bgimg:setPosition( cc.p(self.showIcon:getContentSize().width/2,self.showIcon:getContentSize().height/2) )
        self.showIcon:addChild(bgimg)

        local iconid = g_data.res_head[avatar_id].bust_icon
        local iconimg = ccui.ImageView:create(g_resManager.getResPath(iconid))
        iconimg:setPosition( cc.p(self.showIcon:getContentSize().width/2,self.showIcon:getContentSize().height/2) )
        self.showIcon:addChild(iconimg)
        ]]

    end

    



end


--右边的宝物
function MasterView:showEquipUI(  )
    
    self.master_equip_data = g_MasterEquipMode.GetData()

	local equip_tb = {}
	local index = 1 

	--获取主公装备的UI节点
	while(index) do
		local e_panel = self.equip_panel:getChildByName(string.format( "item_%d", index ))

		if e_panel then

            --新手引导
            if index == 1 then
                g_guideManager.registComponent(9999990,e_panel)
            end 

			local e_node = e_panel:getChildByName("Panel_2")
			e_node:setVisible(false)
			e_node:setTouchEnabled(false)
			table.insert( equip_tb, e_panel)
			index = index + 1
		else
			break
		end
	end
    
	local function panelTouchListener( sender,eventType )
		if eventType == ccui.TouchEventType.ended then
            local function ShowMasterEquipView()
                g_sceneManager.addNodeForUI(require("game.uilayer.master.MasterEquipView"):create( 
                    sender.data,
                    sender.index,
                    function ()
                        self:showEquipUI()
                    end )
                )
            end 

            if g_guideManager.getLastShowStep() then --如果存在新手引导 强制将主公宝物更新
                local timer
                local function refData()
                    if g_MasterEquipMode.RequestData() then
                        if timer then 
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
                        end
                        ShowMasterEquipView()
                    end
                end
                timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(refData, 0.25, false)
            else
                ShowMasterEquipView()
            end
		end
	end

	--在装备列表里筛选存放主公身上的宝物
	self.equiped = {}
	for i,data in ipairs(self.master_equip_data) do
		if tonumber(data.status) == 1 then
            self.equiped[data.position] = data
		end
	end

	for i,e_panel in ipairs(equip_tb) do
		local data = self.equiped[i]
		local e_node = e_panel:getChildByName("Panel_2")
        e_node:removeAllChildren()
        e_panel:getChildByName("Image_1"):setVisible(false)
        
		if data then
            e_node:setVisible(true)
            local equipType = g_Consts.DropType.MasterEquipment
            local equipID = tonumber(data.equip_master_id)
            local equipCount = 1
            local item = require("game.uilayer.common.DropItemView").new(equipType, equipID,equipCount)

            --ICON
            item:setPosition(cc.p( e_node:getContentSize().width/2,e_node:getContentSize().height/2 ))
            item:setCountEnabled(false)
            e_node:addChild(item)
            item:setNameVisible(true)
            --e_panel.selid = data.id
            e_panel.data = data
			--[[e_node:setVisible(true)
			local ctd = g_data.equip_master[ tonumber( data.equip_master_id ) ]
            print("data.equip_master_id",data.equip_master_id)
            local iconid = ctd.equip_icon
			e_node:getChildByName("pic"):loadTexture( g_resManager.getResPath(iconid) )
			e_node:getChildByName("level_bg"):getChildByName("level_num"):setString( string.format( "lv.%d",ctd.min_master_level ) )
            e_node:getChildByName("Text_3"):setString( g_tr(ctd.equip_name) )
			e_panel.selid = data.id]]
		else
			e_node:setVisible(false)
			--e_panel.selid = 0
            e_panel.data = nil
		end
        --默认选中宝物位置
        if self.sel_e_panel == nil then
            self.sel_e_panel = e_panel
        end

        e_panel.index = i
		e_panel:addTouchEventListener( panelTouchListener )
	end
    
end

--主公基本信息
function MasterView:masterInfoView()
    --zhcn
    self.info_panel:getChildByName("Text_20"):setString( g_tr("MasterTitle1") )
    self.info_panel:getChildByName("Panel_3"):getChildByName("Text_14"):setString(g_tr("MasterCN"))
    self.info_panel:getChildByName("Panel_3"):getChildByName("Text_15"):setString(g_tr("MasterCHTitle"))
    self.info_panel:getChildByName("level"):getChildByName("level_num"):setString(g_tr("MasterLevel"))
    self.info_panel:getChildByName("action"):getChildByName("Text_10"):setString(g_tr("MasterMove"))
    self.info_panel:getChildByName("Text_20_0"):setString(g_tr("MasterPowNum"))
    self.info_panel:getChildByName("Text_xm"):setString(g_tr("MasterKillNum"))
    self.info_panel:getChildByName("Text_12"):setString(g_tr("MasterEquipList"))
    
    --宝物界面变动隐藏
    self.info_panel:getChildByName("Text_12"):setVisible(false)

    self.master_data = MODE:getMasterInfo()
    
    --测试显示
    local playerIDTx = self.info_panel:getChildByName("Panel_3"):getChildByName("general_name_0")
    playerIDTx:setString( g_tr("PlayerCode") .. self.master_data.user_code )

    local zhStr = ""
    local rmb = self.master_data.total_rmb or 0
    
    if tonumber(rmb) >= tonumber(g_data.country_basic_setting[17].data) then
        zhStr = string.format( "(%s)",g_tr("city_battle_zhuhou") )
    end
    --昵称
    local name = self.info_panel:getChildByName("Panel_3"):getChildByName("general_name")
    name:setString( zhStr .. self.master_data.nick )


    local countyPic = self.info_panel:getChildByName("Image_11")
    countyPic:setVisible(false)
    local campId = self.master_data.camp_id
    if campId and campId ~= 0 then
        countyPic:setVisible(true)
        local camp_config = g_data.country_camp_list[campId]
        local camp_path = g_resManager.getResPath(camp_config.camp_pic)
        countyPic:loadTexture(camp_path)
    end

    --local camp_config = g_data.country_camp_list[camp_id]
    --local camp_path = g_resManager.getResPath(camp_config.camp_pic)

    --city_battle_zhuhou
    --[[
    local campId = self.master_data.camp_id
    if campId and campId ~= 0 then
        local campConfig = g_data.country_camp_list[tonumber(campId)]
        local campName = g_tr(campConfig.camp_name)
        local campTx = name:clone()
        campTx:setString( "【"..campName.."】" )
        name:getParent():addChild(campTx)
        campTx:setPositionX(campTx:getPositionX() + name:getContentSize().width + 5)
    end
    ]]
    --头像
    local head = self.info_panel:getChildByName("Panel_3"):getChildByName("Image_15_2")
    local iconid = g_data.res_head[self.master_data.avatar_id].head_icon
    
    --[[if self.clipper ~= nil then
        self.clipper:removeFromParent()
        self.clipper = nil
    end

    if self.clipper == nil then
        self.clipper = MODE.createCircleHead(g_resManager.getResPath( iconid ))
        self.clipper:setPosition( cc.p( head:getContentSize().width/2,head:getContentSize().height/2 ) )
        head:addChild(self.clipper)


        --边框
        --local border = ccui.ImageView:create("freeImage/line.png")
        --border:setPosition( cc.p( head:getContentSize().width/2,head:getContentSize().height/2 ) )
        --head:addChild(border)

    end]]

    --self.info_panel:getChildByName("Panel_3"):getChildByName("Image_15_2"):setVisible(false)

    head:loadTexture( g_resManager.getResPath(iconid) )
    head:setScale(0.85)
    --head:setVisible(false)
    
    --经验值
    --local level = self.info_panel:getChildByName("level"):getChildByName("AtlasLabel_1")
    --level:setString( tostring( master_data.level ) )

    local exp_bar = self.info_panel:getChildByName("level"):getChildByName("LoadingBar_1")
    local exp_tx = self.info_panel:getChildByName("level"):getChildByName("Text_13")

    local nv = self.master_data.current_exp - g_data.master[ self.master_data.level ].exp --升下一等级的剩余经验
    local tv = self.master_data.next_exp - g_data.master[ self.master_data.level ].exp

	exp_bar:setPercent( ( nv / tv ) * 100  )
	exp_tx:setString( string.format( "%d/%d",nv,tv ) )

    local TipsPanel = self.info_panel:getChildByName("action")
    
    --行动力
    local move,backtime = g_PlayerMode.getMove()

    print("move,backtime",move,backtime)

    local act_bar = TipsPanel:getChildByName("LoadingBar_2")

    local h,m,s = g_clock.formatTimeHMS( math.ceil(backtime))

    g_itemTips.tipStr(act_bar,g_tr("MasterMoveBackTipsTitle"),g_tr("MasterMoveBackTipsStr",{m=m,s=s}))

	local act_tx = TipsPanel:getChildByName("Text_16")
	act_bar:setPercent( ( move / g_PlayerMode.getLimitMove() ) * 100  )
	act_tx:setString( string.format( "%d/%d",move,g_PlayerMode.getLimitMove() ) )
    
    --主公战力
    self.info_panel:getChildByName("Text_20_1"):setString( tostring(self.master_data.power))
    --主公杀敌数
    self.info_panel:getChildByName("Text_xm1"):setString( tostring( self.master_data.kill_soldier_num or 0 ))
    
    --改名按钮
    local rn_btn = self.info_panel:getChildByName("Panel_3"):getChildByName("Button_1")

    --新手引导
    g_guideManager.registComponent(9999989,rn_btn)


	self:regBtnCallback( rn_btn,function (  )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        g_guideManager.execute()
        require("game.uilayer.master.MasterCNameView"):createLayer( function ()
            self:masterInfoView()
        end )
	end 
    )
    
    --改头像按钮
    local rh_btn = self.info_panel:getChildByName("Panel_3"):getChildByName("Button_2")
    self:regBtnCallback( rh_btn,function (  )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.master.MasterCHeadView"):createLayer( function ()
            self:masterInfoView() --更新头像
            self:showPanelUI() --更新展示图
        end )
    end
    )

    --通用道具框
    local UsePropsLayer = require("game.uilayer.publicMode.UsePropsLayer")
    --加经验
    local exp_btn = self.info_panel:getChildByName("level"):getChildByName("btn_add")
    self:regBtnCallback( exp_btn,function (  )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        UsePropsLayer:createLayer( 
            function ()
                return { itype = g_Consts.UseItemType.EXP , callback = function () self:masterInfoView() end }
            end 
        )
    end)

    --加体力
    local pow_btn = TipsPanel:getChildByName("btn_add")
    self:regBtnCallback( pow_btn,function (  )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        UsePropsLayer:createLayer(
            function ()
                return { itype = g_Consts.UseItemType.MOVE , callback = function () self:masterInfoView() end }
            end 
        )
    end)

    local change_btn = self.info_panel:getChildByName("Image_5")
    --宝物界面变动隐藏
    change_btn:setVisible(false)
    --详细信息
    self:regBtnCallback( change_btn,function (  )
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        self.info_panel:setVisible(false)
        self.equip_list_panel:setVisible(true)
    end)
end

function MasterView:onEnter( )
	print("MasterView onEnter")
	--g_guideManager.execute()
end

function MasterView:onEnterTransitionFinish()
    print("MasterView onEnterTransitionFinish")
    --g_guideManager.execute()
end

function MasterView:onExit( )
	print("MasterView onExit")
    --MODE = nil
    --master_equip_data = nil  --宝物
    --master_data = nil        --主公的基本信息
    --m_Root = nil
    self:clearGlobal()
end

function MasterView:clearGlobal()
    m_Root = nil
    self.master_data = nil
    self.master_equip_data = nil
end


return MasterView