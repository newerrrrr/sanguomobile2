local MasterTalentUpgrade = class("MasterTalentUpgrade", require("game.uilayer.base.BaseLayer"))
--local MODE = nil
--local skillid = nil
--local masterdata = nil
--local talentdatakv = {}
--local talentdatalist = {}
local DISUP = 1
local CANUP = 2
local MAXUP = 3


function MasterTalentUpgrade:ctor( showtype,id,isShowFx)
    
	MasterTalentUpgrade.super.ctor(self)
	self:clearGlobal()
    self.MODE = require("game.uilayer.master.MasterMode").new()
	self.skillid = id
    self.talentdatalist = self.MODE:getTalent()
	self.masterdata = self.MODE:getMasterInfo()
    self.rich = nil
    if self.talentdatalist then
	    for i,v in ipairs( self.talentdatalist ) do
		    self.talentdatakv[ v.talent_id ] = v
	    end
    end
    self.isShowFx = isShowFx or false
	self:initUI(showtype)
end

function MasterTalentUpgrade:initUI( showtype )
    
	local switch = 
	{	
		{ path = "skill_popup_1.csb", viewfun = self.disUpgrade },
		{ path = "skill_popup_2.csb", viewfun = self.Upgrade },
		{ path = "skill_popup_3.csb", viewfun = self.maxUpgrade },
	}

	local sel_switch = switch[showtype]
	self.layer = self:loadUI( sel_switch.path )
	self.root = self.layer:getChildByName("scale_node")
	sel_switch.viewfun(self)

	local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

end

--未达成
function MasterTalentUpgrade:disUpgrade(  )
		
	local bctd =  g_data.talent
	local ctd = bctd[ tonumber( self.skillid ) ]
	local max_count = 0
	local nowlevel = 0
	if self.talentdatakv[ self.skillid ] then
		nowlevel = ctd.level_id
	end

    --zhcn
    self.root:getChildByName("Panel_2"):getChildByName("text_tips"):setString(g_tr("MasterTalentConditionStr"))

	local title_tx = self.root:getChildByName("Panel_2"):getChildByName("title"):getChildByName("Text_1")
	title_tx:setString( g_tr( ctd.talent_name ) )
	local skill_info_panel = self.root:getChildByName("Panel_2"):getChildByName("skill_info")
	local icon_info_panel = skill_info_panel:getChildByName("skill_item")
    local iconid = ctd.img
	icon_info_panel:getChildByName("pic"):loadTexture( g_resManager.getResPath(iconid) )
	icon_info_panel:getChildByName("level"):setString( string.format("%d/%d",nowlevel,ctd.max_level) )
	icon_info_panel:getChildByName("name"):setString( g_tr(ctd.talent_name) )

	--解锁条件

	local unlock_node = {}
	local unlock_index = 1
	
	while ( unlock_index ) do
		local item = self.root:getChildByName("Panel_2"):getChildByName( string.format( "skill_item_%d",unlock_index))
		if item then
			table.insert(unlock_node,item)
			unlock_index = unlock_index + 1
		else
			break
		end
	end

    --自适应位置调整
    if #ctd.condition_talent < 4 then
        
        local width = (self.root:getChildByName("Panel_2"):getContentSize().width / #ctd.condition_talent)

        for var = 1, #ctd.condition_talent do
            if unlock_node[var] then
                unlock_node[var]:setPositionX( width * (var - 1) + (width / 2) )
            end
        end
    end

	for i,item in ipairs(unlock_node) do
		local unlock_data = bctd[ tonumber( ctd.condition_talent[i] ) ]
		if unlock_data then
			local pic = item:getChildByName("pic")
			local level = item:getChildByName("level")
			local name = item:getChildByName("name")
            local iconid = unlock_data.img
			pic:loadTexture( g_resManager.getResPath(iconid) )
			level:setString( string.format("%d/%d",unlock_data.level_id,unlock_data.max_level) )
			name:setString( g_tr(unlock_data.talent_name) )
		else
			item:setVisible(false)
		end
	end


    local desc_tx =  skill_info_panel:getChildByName("Text_3")

    local nctd = ctd
    
    local buffnum
    if nowlevel > 0 then
        buffnum = ctd.max_buff_num
    else
        buffnum = 0
    end
    --local buffidtype = g_data.buff[ctd.buff_id].buff_type
    if tonumber(ctd.buff_num_type) == 1 then
		buffnum = ( buffnum / 100 ) .. "%%"
	end
    
    local nextbuffnum = nctd.buff_num
    --local buffidtype = g_data.buff[ctd.buff_id].buff_type
	if tonumber(ctd.buff_num_type) == 1 then
		nextbuffnum = ( ( nctd.max_buff_num or 0 ) / 100 ) .. "%%"
	end
    
    print("ctd.talent_text",ctd.buff_num_type,ctd.talent_text,buffnum,nextbuffnum)

    local richtxt = g_tr( ctd.talent_text,{ max_num = buffnum,next_max_num = nextbuffnum } )
    
    desc_tx:setString( richtxt )
    desc_tx:setVisible(false)

    if self.rich == nil then
        self.rich = g_gameTools.createRichText( desc_tx , richtxt)
    else
        --self.rich:removeAllProtectedChildrenWithCleanup(true)
        self.rich:setRichText( richtxt )
    end



end

--升级界面
function MasterTalentUpgrade:Upgrade( )
	print("skillid",self.skillid)
	local bctd = g_data.talent
	local ctd = bctd[ tonumber( self.skillid ) ]

	local nowlevel = 0
	if self.talentdatakv[ self.skillid ] then
		nowlevel = ctd.level_id
	end
    
	local title_tx = self.root:getChildByName("Panel_2"):getChildByName("title"):getChildByName("Text_1")
	title_tx:setString( g_tr( ctd.talent_name ) )
	local skill_info_panel = self.root:getChildByName("Panel_2"):getChildByName("skill_info")

    --zhcn
    skill_info_panel:getChildByName("Text_8"):setString(g_tr("MasterTalentNowLvStr"))
    skill_info_panel:getChildByName("Text_8_0"):setString(g_tr("MasterTalentNextLvStr"))
    self.root:getChildByName("Panel_2"):getChildByName("text_tips"):setString(g_tr("MasterTalentUseStr"))
    --text_tips MasterTalentUseStr

	local icon_info_panel = skill_info_panel:getChildByName("skill_item")
    local iconid = ctd.img
	icon_info_panel:getChildByName("pic"):loadTexture( g_resManager.getResPath(iconid) )
	icon_info_panel:getChildByName("level"):setString( string.format("%d/%d",nowlevel,ctd.max_level) )
	icon_info_panel:getChildByName("name"):setString( g_tr(ctd.talent_name) )

	local left_panel = skill_info_panel:getChildByName("text")
	local right_panel = skill_info_panel:getChildByName("text1")
    local desc_tx =  skill_info_panel:getChildByName("Text_3")

    local nctd = nil
    
	if nowlevel == 0 then
        nctd = ctd
		left_panel:setString( string.format("lv.%d",nowlevel) )
		right_panel:setString( string.format("lv.%d",ctd.level_id) )
	else
		if ctd.next_talent ~= -1 then
			--local nctd = bctd[ tonumber( ctd.next_talent ) ]
            nctd = bctd[ tonumber( ctd.next_talent ) ]
			left_panel:setString( string.format("lv.%d",nowlevel) )
			right_panel:setString( string.format("lv.%d",nctd.level_id) )
		end
	end

    local buffnum
    if nowlevel > 0 then
        buffnum = ctd.max_buff_num
    else
        buffnum = 0
    end
    --local buffidtype = g_data.buff[ctd.buff_id].buff_type
    if tonumber(ctd.buff_num_type) == 1 then
		buffnum = ( buffnum / 100 ) .. "%%"
	end
    
    local nextbuffnum = nctd.max_buff_num
    --local buffidtype = g_data.buff[ctd.buff_id].buff_type
	if tonumber(ctd.buff_num_type) == 1 then
		nextbuffnum = ( ( nctd.max_buff_num or 0 ) / 100 ) .. "%%"
	end
    
    print("ctd.talent_text",ctd.buff_num_type,ctd.talent_text,buffnum,nextbuffnum)

    local richtxt = g_tr( ctd.talent_text,{ max_num = buffnum,next_max_num = nextbuffnum } )
    
    desc_tx:setString( richtxt )
    desc_tx:setVisible(false)

    if self.rich == nil then
        self.rich = g_gameTools.createRichText( desc_tx , richtxt)
    else
        --self.rich:removeAllProtectedChildrenWithCleanup(true)
        self.rich:setRichText( richtxt )
    end
    
	local upgrade_btn = self.root:getChildByName("Panel_2"):getChildByName("learn_btn")
    --zhcn
    upgrade_btn:getChildByName("text"):setString(g_tr("TalentStudy"))
    

    --新手引导
    g_guideManager.registComponent(9999992, upgrade_btn)

	self:regBtnCallback(upgrade_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

		if tonumber( self.masterdata.level ) < tonumber( ctd.master_level ) then
			g_airBox.show(g_tr("LowLv"),3)
		elseif tonumber( self.masterdata.talent_num_remain ) < tonumber( ctd.cost ) then
			g_airBox.show(g_tr("LowTP"),3)
		else
			local data = self.MODE:upgradeTalent(ctd.talent_type_id)
			if data --[[and self.callback]] then
                --新手引导
                if g_guideManager.getLastShowStep() then
                    if self.callback then
                        self.callback()
                    end
                    self:close()
                    return    
                end
                --新手引导提交
                
				if self.callback then
                    self.callback()
                end
                self.masterdata = self.MODE:getMasterInfo()

                local temptalentdatalist = clone(self.talentdatalist)
                self.talentdatalist = clone(self.MODE:getTalent())

                --[[for index, value in ipairs(temptalentdatalist) do
                    if self.talentdatalist[index].id 
                end]]
                
                self.talentdatakv = {}
	            for i,v in ipairs( self.talentdatalist ) do
		            self.talentdatakv[ v.talent_id ] = v
	            end 
                


                
                if nctd.next_talent ~= -1 then
                    if nowlevel ~= 0 then  --没有升过级 但是用第一等级来做为默认显示
                        self.skillid = nctd.id                        
                    end
                    self:Upgrade()
                    self:createUpdateFx(icon_info_panel:getChildByName("pic"))
                else
                    g_sceneManager.addNodeForUI(MasterTalentUpgrade:create(MAXUP,nctd.id,true))
                    self:close()
                end
			end
		end
	end)
end

--满级界面
function MasterTalentUpgrade:maxUpgrade(  )


    --zhcn 
    self.root:getChildByName("Panel_2"):getChildByName("text_tips"):setString(g_tr("MasterTalentNextLvMaxStr"))
	local bctd =  g_data.talent
	local ctd = bctd[ tonumber( self.skillid ) ]

	local title_tx = self.root:getChildByName("Panel_2"):getChildByName("title"):getChildByName("Text_1")
	title_tx:setString( g_tr( ctd.talent_name ) )
	local skill_info_panel = self.root:getChildByName("Panel_2"):getChildByName("skill_info")
	local icon_info_panel = skill_info_panel:getChildByName("skill_item")
    local iconid = ctd.img
	icon_info_panel:getChildByName("pic"):loadTexture( g_resManager.getResPath(iconid) )
	icon_info_panel:getChildByName("level"):setString( string.format("%d/%d",ctd.level_id,ctd.max_level) )
	icon_info_panel:getChildByName("name"):setString( g_tr(ctd.talent_name) )

	local buffnum = ctd.max_buff_num
    --local buffidtype =  g_data.buff[ctd.buff_id].buff_type
	if tonumber( ctd.buff_num_type ) == 1 then
		buffnum = ( buffnum / 100 ) .. "%%"
	end
    
	local desc_tx =  skill_info_panel:getChildByName("Text_3")
    desc_tx:setString( g_tr(ctd.talent_text,{ max_num = buffnum }) )

    
    local rich = g_gameTools.createRichText( desc_tx , desc_tx:getString())
    desc_tx:setVisible(false)


    if self.isShowFx then
        self:createUpdateFx(icon_info_panel:getChildByName("pic"))
    end
end
function MasterTalentUpgrade:createUpdateFx( target )
    local size = target:getContentSize()

    local armature , animation
    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            print("armature remove")
            armature:removeFromParent()
        end
    end 
  
    armature , animation = g_gameTools.LoadCocosAni(
        "anime/YanJiouSuo_KeJiKaiQi/YanJiouSuo_KeJiKaiQi.ExportJson"
        , "YanJiouSuo_KeJiKaiQi"
        , onMovementEventCallFunc
        --, onFrameEventCallFunc
    )

    armature:setPosition(cc.p(size.width/2, size.height/2 + 9))
    target:addChild(armature)
    animation:play("Animation1") 
end


function MasterTalentUpgrade:setcallback( fun )
	self.callback = fun
end

function MasterTalentUpgrade:clearGlobal()
    self.MODE = nil
    self.skillid = nil
    self.masterdata = nil
    self.talentdatakv = {}
    self.talentdatalist = {}
    self.callback = nil
end

function MasterTalentUpgrade:onEnter( )
    --新手引导提交
    g_guideManager.execute()
    print("MasterTalentUpgrade onEnter")
end

function MasterTalentUpgrade:onExit( )
	print("MasterTalentUpgrade onExit")
    self:clearGlobal()
    --MODE = nil
    --skillid = nil
    --masterdata = nil
end




return MasterTalentUpgrade