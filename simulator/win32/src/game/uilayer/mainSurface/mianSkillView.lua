
local mianSkillView = class("mianSkillView", require("game.uilayer.base.BaseLayer"))
--local skill_data = nil

function mianSkillView:createLayer()
    g_sceneManager.addNodeForUI( require("game.uilayer.mainSurface.mianSkillView"):create())
end

function mianSkillView:ctor()
    mianSkillView.super.ctor(self)
    self.playerData = g_PlayerMode.GetData()
    self.skill_data = nil
    g_busyTip.show_1()
    g_MasterSkillMode.RequestSynData(function (result,msgData)
        g_busyTip.hide_1()
        if true == result then
            self.skill_data = g_MasterSkillMode.GetData()
            self:initUI()
        end
    end)

    if self.skill_data == nil then
        self:close()
    end
end

function mianSkillView:initUI()
    self.layer = self:loadUI("skill_ActiveSkills.csb")
    self.root = self.layer:getChildByName("scale_node")
    self.list = self.root:getChildByName("Panel_3"):getChildByName("ListView_2")
    local mask = self.layer:getChildByName("mask")
    self:regBtnCallback(mask,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    --zhcn
    local titlename = self.root:getChildByName("Panel_3"):getChildByName("Text_1_0")
    titlename:setString(g_tr("SkillName"))

    self.root:getChildByName("Panel_anniuquy"):setTouchEnabled(false)
    self.root:getChildByName("Panel_anniuquy"):getChildByName("Text_3"):setString(g_tr("clickhereclose"))

    self:initList()
end

function mianSkillView:initList()
    local sdataable = g_data.master_skill
    --local skill_panel = m_Widget:getChildByName("scale_node"):getChildByName("Panel_1")
    --local list = skill_panel:getChildByName("ListView_1")
    self.list:setItemsMargin(20)

    --创建技能图标节点
    for key, var in pairs(sdataable) do
        local item = cc.CSLoader:createNode("skill_item.csb")
        self.list:pushBackCustomItem(item)
    end

    self:skillLeftUpdate()
    self:showFxUpdate()
end

--更新的界面方法
function mianSkillView:skillLeftUpdate()
    self.skill_data = g_MasterSkillMode.GetData()
    self.unlockskill = {}
    
    for key, var in ipairs(self.skill_data) do
        self.unlockskill[ tonumber(var.talent_id) ] = var
    end
    
    local sdataable = clone(g_data.master_skill) --主动技能配置表
    local skilldatalist = {}
    
    for key, var in pairs( sdataable ) do
        -- var.w排序权重 如果相等 按照 talent_id 排序
        local nData = self.unlockskill[ tonumber(var.talent_id) ]
        if nData and nData.enable == 1 then
            var.w = tonumber(var.talent_id) * 100000
        else
            var.w = tonumber(var.talent_id)
        end

        table.insert( skilldatalist,var)
    end

    --排序
    table.sort( skilldatalist , function (a,b)
        return  a.w > b.w
    end )

    --local skill_panel = m_Widget:getChildByName("scale_node"):getChildByName("Panel_1")
    --local list = skill_panel:getChildByName("ListView_1")
    local items = self.list:getItems()
    
    local function itemTouchListener(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.selTalentId ~= sender.talent_id then
                self:skillRightUpdate(sender.talent_id)
                self.selTalentId = sender.talent_id
            end
        end
    end


    for index , item in ipairs(items) do
        local icon = item:getChildByName("item")
        local pic = icon:getChildByName("pic")
	    local name = icon:getChildByName("name")
		local time = icon:getChildByName("level")
        
        local data = skilldatalist[index]
        local talent_id = data.talent_id

        --print("talent_id",talent_id)

        name:setString(  g_tr( g_data.talent[talent_id].talent_name ) )
		pic:loadTexture( g_resManager.getResPath(g_data.talent[talent_id].img))

        local netdata = self.unlockskill[talent_id]
        icon.talent_id = talent_id
        icon:addTouchEventListener(itemTouchListener)

        if index == 1 then
            self:skillRightUpdate(talent_id)
        end


        if netdata and netdata.enable == 1 then
            icon.startCD = function ()
                local cd = netdata.next_time - g_clock.getCurServerTime()
                if cd > 0 then
                    time:setString(g_gameTools.convertSecondToString( cd ))
                    local action = nil
                    local function CDstepfun( leftitem )
                        cd = netdata.next_time - g_clock.getCurServerTime()
                        if cd >= 0 then
                            time:setString(g_gameTools.convertSecondToString( cd ))
                        else
                            item:stopAction(action)
                            time:setString(g_tr("bagUse"))
                        end
                    end

                    local delay = cc.DelayTime:create(1)
                    local sequence = cc.Sequence:create(delay, cc.CallFunc:create( CDstepfun ))
                    action = cc.RepeatForever:create( sequence )
                    item:runAction(action)
                else
                    time:setString(g_tr("bagUse"))
                end
            end
        else
            pic:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
            time:setString( g_tr("SkillLess") )
        end

        if icon.startCD then
            icon.startCD()
        end
    end
end

--创建/显示 持续特效
function mianSkillView:showFxUpdate()
    local items = self.list:getItems()
    for key, var in ipairs(items) do
        local icon = var:getChildByName("item")
        local nData = self.unlockskill[icon.talent_id]
        if nData and nData.enable == 1 then
            local effectTime = nData.effect_time
            local showTime = effectTime - g_clock.getCurServerTime()
            if showTime > 0 then
                
                local armature , animation
                armature , animation = g_gameTools.LoadCocosAni(
                    "anime/Effect_ZhuDongJiNengXuanWo/Effect_ZhuDongJiNengXuanWo.ExportJson"
                    , "Effect_ZhuDongJiNengXuanWo"
                )
                armature:setPosition( cc.p(icon:getPositionX()+1,icon:getPositionY() + 17) )
                icon:addChild(armature)
                animation:play("Animation1")
            end
        end
    end
end


function mianSkillView:skillRightUpdate(skill_id)
    
    if skill_id == nil then return end
    
    local title = self.root:getChildByName("Text_1")
    local rightPanel = self.root:getChildByName("Panel_dingwei")
    local pic = rightPanel:getChildByName("skill_item"):getChildByName("pic")
    local name = rightPanel:getChildByName("skill_item"):getChildByName("name")
    local level = rightPanel:getChildByName("skill_item"):getChildByName("level")
    level:setVisible(false)
    name:setPositionY( level:getPositionY() )
    local des = rightPanel:getChildByName("Text_3")
    local time = rightPanel:getChildByName("Text_9")
    local timebg = rightPanel:getChildByName("Image_9")
    local usebtn = rightPanel:getChildByName("Button_1")
    local usebtntx = rightPanel:getChildByName("Text_10")
    local send_btn = rightPanel:getChildByName("Button_1")

    local ctd = g_data.talent[ tonumber(skill_id) ]

    if self.cdtimer ~= nil then
        --print("change cdtimer stop")
        self:unschedule(self.cdtimer)
        self.cdtimer = nil
    end 

    title:setString( g_tr( ctd.talent_name ) )
    name:setString( g_tr( ctd.talent_name ) )
    pic:loadTexture( g_resManager.getResPath(ctd.img) )
    des:setString( g_tr(ctd.talent_text) )
    --des:setVisible(false)
    if self.rich == nil then
        self.rich = g_gameTools.createRichText(des,des:getString())
    else
        --self.rich:setRichSize()
        self.rich:setRichText(des:getString())
    end
    
    local data = self.unlockskill[tonumber(skill_id)]
    --拥有此技能
    if data and data.enable == 1 then
        level:setString( g_tr("SkillActivate"))
        local cd = data.next_time - g_clock.getCurServerTime()
        local durationCd = data.effect_time - g_clock.getCurServerTime()
        local isNotUse = data.effect_time > data.next_time
        --定时器倒计时方法
        local function CDstepfun()
            cd = data.next_time - g_clock.getCurServerTime()
            durationCd = data.effect_time - g_clock.getCurServerTime()
            if cd >= 0 then
                if durationCd >= 0 then
                    time:setTextColor(cc.c3b(50,250,50))
                    time:setString( g_tr("CDduration") .. g_gameTools.convertSecondToString(durationCd))
                else
                    time:setTextColor(cc.c3b(250,50,50))
                    time:setString( g_tr("CDtime") .. g_gameTools.convertSecondToString( cd ))
                end
            else
                self:unschedule(self.cdtimer)
                self.cdtimer = nil
                self:skillRightUpdate(skill_id)
            end
        end
        
        if isNotUse then
            time:setTextColor(cc.c3b(50,250,50))
            time:setVisible(true)
            timebg:setVisible(true)
            send_btn:setVisible(false)
            usebtntx:setVisible(false)
            time:setString( g_tr("SkillIng"))
            return
        end

        send_btn:setVisible(true)
        usebtntx:setVisible(true)

        if cd > 0 then
            time:setVisible(true)
            timebg:setVisible(true)
            
            if self.cdtimer == nil then
                self.cdtimer = self:schedule(CDstepfun,1)
            end
            
            if durationCd > 0 then
                --持续时间
                time:setTextColor(cc.c3b(50,250,50))
                time:setString( g_tr("CDduration") .. g_gameTools.convertSecondToString( durationCd ))
            else
                time:setTextColor(cc.c3b(250,50,50))
                time:setString( g_tr("CDtime") .. g_gameTools.convertSecondToString( cd ))
            end
            
            usebtntx:setString( g_tr("bagUse"))

        else
            time:setVisible(false)
            timebg:setVisible(false)
            usebtntx:setString( g_tr("bagUse"))
        end
    else
        time:setVisible(true)
        time:setString( g_tr("noGetSkill") )
        timebg:setVisible(true)
        usebtntx:setString(g_tr("gotoStudySkill"))
        level:setString(g_tr("SkillLess"))
    end

    self:regBtnCallback(send_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if data and data.enable == 1 then
            
            local cd = data.next_time - g_clock.getCurServerTime()
        
            if cd > 0 then
                g_airBox.show(g_tr("CDing"),3)
            else
                local function onChangeEnd()
					self:talentUse(skill_id)
					self:close()
				end

                if skill_id == 203301 then
                    require("game.maplayer.changeMapScene").changeToHome(false,onChangeEnd)
                elseif skill_id == 305501 then

                    local playerArmyData = nil
                    if g_ArmyMode.RequestData() then
                        playerArmyData = g_ArmyMode.GetData() 
                    end

                    if playerArmyData == nil then
                        print("get playerArmyData error")
                        return
                    end

                    --判断是否当前有没有军团出征了
                    local isOut = false
                    if playerArmyData then
                        for key, var in pairs(playerArmyData) do
                            if var.status == 1 then
                                isOut = true
                                break
                            end
                        end
                    end

                    if isOut then
                        require("game.maplayer.changeMapScene").gotoWorld_BigTileIndex(cc.p(self.playerData.x, self.playerData.y) , onChangeEnd)
                    else
                        g_airBox.show(g_tr("noOutArmy"),2)
                    end
                elseif skill_id == 306301 then
                    local move = g_PlayerMode.getMove()
                    local limitMove =  g_PlayerMode.getLimitMove()
                    if move >= limitMove then
                        g_airBox.show(g_tr("noNeedAddMove"),2)
                    else
                        self:talentUse(skill_id)
                    end
                else
                    self:talentUse(skill_id)
                end
            end
            --require("game.maplayer.changeMapScene").gotoHome_Place(5005,g_autoCallback.addCocosList( jumpTest , 0.5 ))
        else
            require("game.uilayer.master.MasterTalentView"):createLayer( skill_id )
            self:close()
        end
        --self[string.format("f_%d",skill_id)](msgData)
	end)
end

function mianSkillView:talentUse(skill_id)
    local function onRecv(result, msgData)
		if(result==true)then
			self:skillLeftUpdate()
            self:skillRightUpdate(skill_id)
            self:showFxUpdate()
            local callback = self[string.format("f_%d",skill_id)]
            if callback then
                callback(msgData)
            end
		end
	end        
    g_sgHttp.postData("Player/talentUse",{ talentId = skill_id },onRecv)
end

function mianSkillView:onExit( )
	print("mianSkillView onExit")
    --skill_data = nil
end

--获取三个小时的粮食产量
function mianSkillView.f_203301(msgData)
	if msgData then
		local taxData = msgData["203301"]
		if taxData then
			require("game.effectlayer.taxEffect").show(taxData.food, taxData.gold, taxData.iron, taxData.stone, taxData.wood)
		end
	end
end

--战术机动 召回所有部队
function mianSkillView.f_305501(msgData)
	
end

--306301

return mianSkillView