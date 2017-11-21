local battleSettingView = class("battleSettingView",require("game.uilayer.base.BaseLayer"))

--local playerArmyUnitData = nil  --军团详情详情
--local playerArmyData = nil      --军团信息
--local playerData = nil          --玩家数据
--local gotoTimeList = nil        --获取的行军时间的列表
--local playerBuffData = nil      --当前buff数据
--local _postb = nil              --行军目的地的坐标
--local _fightType = nil          --行军类型

local cnNumStr = {
    g_tr("num1"),
    g_tr("num2"),
    g_tr("num3"),
    g_tr("num4"),
    g_tr("num5"),
    g_tr("num6"),
    g_tr("num7"),
    g_tr("num8"),
    g_tr("num9"),
    g_tr("num10"),
}


--出行使用体力
local OUT_USEMOVE = 1
--正常出行
local OUT_USEDEF = 0

function battleSettingView:getUINeedData()
    
    --每次获取最新的军团信息
    --[[if g_ArmyMode.RequestData() then
        self.playerArmyData = g_ArmyMode.GetData() 
    end
    
    if g_ArmyUnitMode.RequestData() then
        self.playerArmyUnitData = g_ArmyUnitMode.GetData()
    end]]
    
    --[[if g_BuffMode.RequestData() then
        self.playerBuffData = g_BuffMode.GetData()
    end]]
    
    --获取需要行军时间
    --[[local function callback( result , msgData )
        if result == true then
            self.gotoTimeList = msgData
        end
    end

    g_sgHttp.postData("map/getGotoTime", { x = self.postb.x,y = self.postb.y,type = self.fightType }, callback)]]
end

--fun:回调方法，
--post:目的地的XY
--fightType:计算时间战斗类型
---isJiJie:是否是集结
function battleSettingView:createLayer( fun,postb,fightType,isJiJie)
    
    self:clearGlobal()
    
    self.isJiJie = isJiJie

    self.postb = postb

    self.fightType = fightType

    self.playerData = g_PlayerMode.GetData()

    g_sceneManager.addNodeForUI(battleSettingView:create( fun ))
    
    return true
end

function battleSettingView:ctor(fun)
    battleSettingView.super.ctor(self)
    self.callback = fun
    self.armyList = {}
    g_busyTip.show_1()
    g_groundData.RequestSycData( function (result,data)
        g_busyTip.hide_1()
        if result == true then
            self.playerArmyData = g_ArmyMode.GetData()
            self.playerArmyUnitData = g_ArmyUnitMode.GetData()
            --判断所有存在没有出征的军团
            self.isAllOut = true
            for key, var in pairs(self.playerArmyData) do
                --发现没有出征
                if var.status == 0 then
                    self.isAllOut = false
                    break
                end
            end

            --没有剩余部队
            if self.isAllOut then
                self:noArmyConfirm()
                self:close()
            else
                self:filterData()
            end
        else
            self:close()
        end
    end )
    
    --self.armyList = {}
    --self:filterData()
    --self:initUI()
end

function battleSettingView:onEnter()
    
    self.layout = self:loadUI("battle_select_army.csb")
    g_resourcesInterface.installResources(self.layout)
    
    self.root = self.layout:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    --zhcn
    self.root:getChildByName("title"):getChildByName("text"):setString(g_tr( "battleSetTitle" ))
    self.root:getChildByName("Text_1"):setString(g_tr("campaignTitle"))
end

function battleSettingView:filterData(callback)
    
    local function update()
        self.playerArmyData = g_ArmyMode.GetData()
        self.playerArmyUnitData = g_ArmyUnitMode.GetData()
        self.playerBuffData = g_BuffMode.GetData()
        self.gorpsort = {} --排序使用
        self.group = {} --数据
        --获取数据筛选
        for _, var in pairs( self.playerArmyData ) do
            if self.group[var.id] == nil then self.group[var.id] = {} end
            table.insert(self.gorpsort,var)
            for _, data in ipairs(self.playerArmyUnitData) do
                if data.army_id == var.id then
                    table.insert(self.group[var.id],data)
                end
            end
        end
    
        table.sort(self.gorpsort,function (a,b)
            if a.status < b.status then
                return a.status < b.status
            end

            if a.status == b.status then
                return a.position < b.position
            end
        end)
        self:initUI()
        if callback then
            callback()
        end
        g_guideManager.execute()
    end

    
    --获取需要行军时间
    local function callback( result , msgData )
        g_busyTip.hide_1()
        if result == true then
            self.gotoTimeList = msgData
            update()
        end
    end
    g_busyTip.show_1()
    g_sgHttp.postData("map/getGotoTime", { x = self.postb.x,y = self.postb.y,type = self.fightType }, callback,true)

end


function battleSettingView:itemInitUI(item,data)
    
    local panel = item:getChildByName("item")
    local title = panel:getChildByName("title")
    local mbtime = panel:getChildByName("Text_15")
    local xdlTx = panel:getChildByName("Text_xdl")
    local resNumTx = panel:getChildByName("Text_cjzy1")
    local resImg = panel:getChildByName("Image_5")
    local resTx = panel:getChildByName("Text_cjzy")

    local ArmyID = data.id 
    local timeNum = self.gotoTimeList.time[tostring(ArmyID)] or 0
    mbtime:setString(string.format("%02d:%02d:%02d",g_clock.formatTimeHMS( timeNum )))
    
    xdlTx:setString( g_tr("battleMove",{ move = self.usePower or 0 } ) )

    if table.nums( self.gotoTimeList.collection) <= 0 or self.gotoTimeList.collectionType == 0 then
        resNumTx:setVisible(false)
        resImg:setVisible(false)
        resTx:setVisible(false)
    else
        local getResNum = self.gotoTimeList.collection[tostring(ArmyID)] or 0
        resNumTx:setString( tostring(getResNum) )

        local count, icon = g_gameTools.getPlayerCurrencyCount( self.gotoTimeList.collectionType )
        resImg:loadTexture(icon)
    
        resTx:setString(g_tr("battleGetRes"))
    end


    --标签位置
    local tabType = data.position

    title:setString( g_tr( "battleSetCorp",{index = cnNumStr[tabType] } ) )
    
    local gen_tb = {} --武将节点
    local s_type = {0,0,0,0} --兵种分类数量
    local leader_general_info = nil  --团长信息
    local index = 1
    local power = 0

    while true do
        local gem_item = panel:getChildByName("generals_list"):getChildByName( string.format( "item_%d",index) )
        if gem_item then
            table.insert(gen_tb,gem_item)
        else
            break
        end
        index = index + 1
    end

    local soldierCount = 0
    
    for i , gen_item in ipairs(gen_tb) do
        
        local d = self.group[data.id][i]

        if d and d ~= 0 then
            gen_item:setVisible(true)
            local t = g_GeneralMode.GetBasicInfo( d.general_id, 1 )
            local st = g_data.soldier[ d.soldier_id ]  --兵种数据表
            --查找武将专属带兵属性
            local equipConifg = g_data.equipment[tonumber(t.general_item_id .. "00")] 
            local isSpecial = false

            if equipConifg and st then
                local equip_skill_id_list = equipConifg.equip_skill_id
                --print("equip_skill_id_list count",#equip_skill_id_list)

                for _, skillid in ipairs(equip_skill_id_list) do
                    local skillConfig = g_data.equip_skill[skillid]
                    if skillConfig then
                        --print("equip_arm_type",skillConfig.equip_arm_type,st.soldier_type)
                        if tonumber(skillConfig.equip_arm_type) == tonumber(st.soldier_type) then
                            isSpecial = true
                        end
                    end
                end
            end

            gen_item:getChildByName("Image_2"):setVisible(isSpecial)
            gen_item:getChildByName("Text_2"):setString(g_tr("battleLeader"))
            --print("general_item_id",t.general_item_id)
            --计算每一个武将所携带的士兵的总战力
            power = power + d.power
            
            if data.leader_general_id == d.general_id then
                leader_general_info = t
            else
                gen_item:getChildByName("Image_4"):setVisible(false)
                gen_item:getChildByName("Text_2"):setVisible(false)
            end
            
            local pic = gen_item:getChildByName("pic")
            if pic.icon then
                pic.icon:removeFromParent()
                pic.icon = nil
            end
            local name = gen_item:getChildByName("text_name")
            local ico = gen_item:getChildByName("ico")  --兵种图标
            local num = gen_item:getChildByName("text_num")

            local loadgreen = gen_item:getChildByName("LoadingBar_1")
            local loadred = gen_item:getChildByName("LoadingBar_2")
            local loadyellow = gen_item:getChildByName("LoadingBar_3")
            

            gen_item:getChildByName("Image_1"):setVisible(false)

            loadred:setVisible(false)
            loadyellow:setVisible(false)
            loadgreen:setVisible(false)
            
            if pic.icon == nil then
                local general = g_GeneralMode.getOwnedGeneralByOriginalId(t.general_original_id)
                local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General,t.id, 1)
                item:setPosition( cc.p( pic:getContentSize().width/2,pic:getContentSize().height/2) )
                item:setCountEnabled(false)
                item:showGeneralServerStarLv(general.star_lv)
                pic:addChild(item)
                pic.icon = item
            end

            name:setString( g_tr( t.general_name ) )

            local max_soldier = g_ArmyMode.GetMaxArmyNum(d.general_id)

            --print("max_soldier",max_soldier)

            if st then
                ico:setVisible(true)
                num:setVisible(true)
                s_type[st.soldier_type] = s_type[st.soldier_type] + d.soldier_num
                ico:loadTexture(g_resManager.getResPath( st.img_type ))
                num:setString( tostring(d.soldier_num) )
                soldierCount = soldierCount + d.soldier_num
                print("soldierCount",soldierCount)

                local sValue = d.soldier_num / max_soldier * 100

                --print("sValue",sValue,d.soldier_num)

                if  sValue > 0 and sValue <= 30 then
                    loadred:setVisible(true)
                    loadred:setPercent(sValue)
                elseif sValue > 30 and sValue <= 80 then
                    loadyellow:setVisible(true)
                    loadyellow:setPercent(sValue)
                elseif sValue > 80 then
                    loadgreen:setVisible(true)
                    loadgreen:setPercent(sValue)
                end

            else
                ico:setVisible(false)
                num:setVisible(false)
            end
        else
            gen_item:setVisible(false)
        end
    end

    
    --zhcn
    panel:getChildByName("label_leader"):setString( g_tr("battleSoldierCountZhcn") )
    panel:getChildByName("label_generals"):setString( g_tr("armyEnter") )
    panel:getChildByName("label_battle_capability"):setString( g_tr("armyFightForce") )
    panel:getChildByName("label_soldiers"):setString( g_tr("armyNumber") )

    local soldier_num = panel:getChildByName("leader_name")
    local generals_num = panel:getChildByName("generals_num")
    local capability_num = panel:getChildByName("capability_num")

    --print("id,leader_general_id,num", data.id,data.leader_general_id,#self.group[data.id] )
    

    soldier_num:setString( tostring(soldierCount or 0) )
    soldier_num:setPositionX(generals_num:getPositionX())
    --capability_num:setPositionX(generals_num:getPositionX())
    
    local maxArmyNum = g_BuffMode.calculateFinalValueByBuffKeyName(tonumber(g_data.starting[19].data),"deputy_per_corp")
    generals_num:setString(  string.format("%d/%d",#self.group[data.id],maxArmyNum ) )
    
    capability_num:setString(  tostring(power) )

    panel:getChildByName("soldier_infantry"):getChildByName("num"):setString( tostring(s_type[1]) )
    panel:getChildByName("soldier_cavalry"):getChildByName("num"):setString( tostring(s_type[2]) )
    panel:getChildByName("soldier_archer"):getChildByName("num"):setString( tostring(s_type[3]) )
    panel:getChildByName("soldier_ chariot"):getChildByName("num"):setString( tostring(s_type[4]) )

    

    --print("gotoTimeList",gotoTimeList[tostring(ArmyID)])
    
    local btn_battle = panel:getChildByName("btn_battle")
    btn_battle:getChildByName("Text"):setString(g_tr("campaign"))
    btn_battle:setTouchEnabled( #self.group[data.id] > 0 )

    --出征方法
    local function touchFight(callback)
        
        --print("group count",#self.group)
        --判断是否所有武将带兵数都为空
        local isSoldierAllEmpty = true
        for _, var in ipairs(self.group[data.id]) do
            if var.soldier_num > 0 then
                isSoldierAllEmpty = false
                break
            end
        end
        --全部武将都为空
        if isSoldierAllEmpty then
            g_airBox.show(g_tr("nosoldierstr"),3)
            return
        end


        if callback then
            callback()
        end

        --获取最新的buff数据计算当前武将的带兵上限
        --[[if not g_BuffMode.RequestData() then
            print("get BuffMode is false")
            return
        end]]

        --[[for _, var in ipairs(self.group[data.id]) do
            if var.general_id ~= 0 then
                --print("soldier_id,soldier_num",var.soldier_id,var.soldier_num,not g_guideManager.getLastShowStep())
                --判断武将带兵的是否都达到最大数量
                local max_soldier = g_ArmyMode.GetMaxArmyNum(var.general_id)
                --print("max_soldier",max_soldier)
                --g_GeneralMode.GetBasicInfo( var.general_id, 1 )
                if var.soldier_num < max_soldier 
                and not g_guideManager.getLastShowStep()--如果进行新手引导则不提示士兵未带满
                then
                    
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    self:confirm(ArmyID,tabType, function ()
                        if callback then
                            callback()
                        end
                    end )

                    return
                end
            else
                print("find general_id is 0")
            end
         end]]


         --return true
         --[[if self.callback then
            self.callback( ArmyID,function ()
                local function onPlaySound()
                    g_musicManager.playEffect(g_data.sounds[5000039].sounds_path,false)
                end
                g_autoCallback.addCocosList( onPlaySound , 2.0 )
            end,OUT_USEDEF )
            self:close()
            return
         end]]
         --OUT_USEDEF)
    end
    
    self:regBtnCallback(btn_battle,function()
        
        touchFight(function ()
            self:goOut(ArmyID,OUT_USEDEF)
        end)

    end )
        
    local btn_edit = panel:getChildByName("generals_list")
    local edit_Txt = panel:getChildByName("editText")

    self:regBtnCallback(btn_edit,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        --更新UI
        local function callback()
            self:setVisible(true)
            self:filterData()
        end

        self:setVisible(false)
        g_sceneManager.addNodeForUI(require("game.uilayer.drill.DrillView").new( callback,tabType))
	end)
    
    edit_Txt:setString(g_tr("campaignSet"))
    
    edit_Txt:runAction( cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1),cc.FadeOut:create(1))) )

    local status_img = panel:getChildByName("Image_3")
    status_img:setVisible(false)

    local status_str = panel:getChildByName("Text_1")
    status_str:setVisible(false)

    local view_btn = panel:getChildByName("view_btn")
    view_btn:getChildByName("Text"):setString(g_tr("campaignView"))

    local moveToBtn = panel:getChildByName("Button_1")
    
    --查看定位数据
    self:regBtnCallback( view_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        
        if self.parCallBack then
            self.parCallBack()
        end

        self:close()


        require("game.maplayer.changeMapScene").changeToWorld( false, function ()
            
            local queueServerData = require("game.maplayer.worldMapLayer_bigMap").getQueueServerData_armyId(ArmyID)

            if queueServerData then
                require ("game.uilayer.mainSurface.mainSurfaceQueueWorld").simulationTouchQueue(queueServerData)
                --集结不对但没有出征
                if require("game.maplayer.worldMapLayer_queueHelper").isGatherWaitType(queueServerData) then
                    --打开战争大厅
                    g_sceneManager.addNodeForUI(require("game.uilayer.battleHall.BattleHallView").new())
                else
                    g_guideManager.removeGameFeature(g_guideManager.gameFeatures.ALLIANCE)
                end
            end
        end )
        
    end )
    

    local btn_supplement =  panel:getChildByName("btn_supplement")
    btn_supplement:getChildByName("Text"):setString(g_tr("quickAdd"))
    
    self:regBtnCallback( btn_supplement,function ()
        local function callback(result, data)
            g_busyTip.hide_1()
            if result == true then
                self:filterData( function ()
                    g_airBox.show(g_tr("fullSuc"))
                end )
            end
        end
        g_busyTip.show_1()
        g_netCommand.send("Army/fullfillSoldier", {["armyPosition"] = data.position}, callback,true)
    end)

    local status = data.status or 0


    btn_battle:setVisible( not (status == 1) )
    btn_edit:setTouchEnabled( not (status == 1) )
    edit_Txt:setVisible( not (status == 1) )
    mbtime:setVisible( not (status == 1) )
    moveToBtn:setVisible( not (status == 1) )
    btn_supplement:setVisible( not (status == 1) )
    xdlTx:setVisible( not (status == 1) )

    status_img:setVisible( status == 1 )
    status_str:setVisible( status == 1 )
    view_btn:setVisible( status == 1 )


    --先隐藏一键补兵
    --btn_supplement:setVisible(false)


    --[[
    if status == 1 then
        btn_battle:setVisible(false)
        btn_edit:setTouchEnabled(false)
        edit_Txt:setVisible(false)
        mbtime:setVisible(false)
        moveToBtn:setVisible(false)
        btn_supplement:setVisible(false)

        status_img:setVisible(true)
        status_str:setVisible(true)
        view_btn:setVisible(true)
    else
        status_img:setVisible(false)
        status_str:setVisible(false)
        view_btn:setVisible(false)

        btn_battle:setVisible(true)
        btn_edit:setTouchEnabled(true)
        edit_Txt:setVisible(true)
        mbtime:setVisible(true)
        moveToBtn:setVisible(true)
        btn_supplement:setVisible(true)
    end
    ]]
    --self.postb
    --local runLength = cc.pGetDistance( cc.p(self.playerData.x,self.playerData.y),self.postb )
    local moveNum = self.gotoTimeList.needMove + (self.usePower or 0)
    --math.max(  math.floor(math.pow(runLength,0.911) * 0.45),5)
    --zhcn
    moveToBtn:getChildByName("Text"):setString(g_tr("battleMoveTitle"))
    
    --免费
    if self.gotoTimeList.freeMove == 1 then
        moveNum = 0
    end

    moveToBtn:getChildByName("Text_16"):setString(g_tr("battleMove",{ move = (moveNum > 0 and moveNum or g_tr("battleMoveFree") ) }))
    
    self:regBtnCallback( moveToBtn,function ()
        
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

        g_guideManager.execute()

        --if touchFight(OUT_USEDEF) then
        local function moveFun()
            local needMove = moveNum
            --玩家剩余的体力
            local playerMove = g_PlayerMode.getMove() or 0
            --是否体力足够不够使用元宝购买
            local useOverMove = playerMove - needMove
            --不够
            if useOverMove < 0 then
                local needGem = math.abs(useOverMove) * 2
                g_msgBox.showConsume(needGem, g_tr("RunQuickUseGemIsTrue"), nil, nil, function ()
                
                    if g_PlayerMode.getDiamonds() < needGem then
                        g_airBox.show(g_tr("no_enough_money"),3)
                        return
                    end
                    self:goOut(ArmyID,OUT_USEMOVE)
                end)
            else --足够
            
                --免费不需要弹出提示
                if self.gotoTimeList.freeMove == 1 then
                    self:goOut(ArmyID,OUT_USEMOVE)
                    return
                end

                local function msgBoxCallBack(event)
                    if event == 0 then
                        self:goOut(ArmyID,OUT_USEMOVE)
                        return
                    end
                end

                if needMove >= 15 then
                    g_msgBox.show(g_tr("RunQuickUseMoveIsTrue",{num = needMove}),nil,nil,msgBoxCallBack,1)
                else
                    self:goOut(ArmyID,OUT_USEMOVE)
                end

            end
        end

        touchFight(moveFun)

    end)
    

    if self.isJiJie == true then
        moveToBtn:setTouchEnabled(false)
        moveToBtn:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
        moveToBtn:getChildByName("Text_16"):setVisible(false)
        moveToBtn:getChildByName("Text"):setPositionY(moveToBtn:getContentSize().height/2)
    end


    if soldierCount <= 0 then
        
        --moveToBtn:setTouchEnabled(false)
        --moveToBtn:getChildByName("Text_16"):setVisible(false)
        --moveToBtn:getChildByName("Text"):setPositionY(moveToBtn:getChildByName("Text"):getPositionY() - 7)
        moveToBtn:getChildByName("Text_16"):setString(g_tr("battleNoSoldier"))
        
        --btn_battle:setTouchEnabled(false)
        --btn_battle:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
        mbtime:setString(g_tr("battleNoSoldier"))
    end

     



end

function battleSettingView:initUI()
    

    self.list = self.root:getChildByName("ListView_1")
    self.list:setItemsMargin(25)
    local itemmode = cc.CSLoader:createNode("battle_select_item_1.csb")
    
    local showIndex = 0
    for idx,data in ipairs(self.gorpsort) do
        if #self.group[data.id] > 0 then
            showIndex = showIndex + 1
            local item = self.armyList[showIndex]
            if item then
                self:itemInitUI( self.armyList[showIndex] , data)
            else
                item = itemmode:clone()
                self.list:pushBackCustomItem(item)
                self:itemInitUI( item , data)
                table.insert(self.armyList,item)
            end
            local btn_quickBattle = item:getChildByName("item"):getChildByName("Button_1")
            g_guideManager.registComponent(2000100 + showIndex,btn_quickBattle)

            local btnBattle = item:getChildByName("item"):getChildByName("btn_battle")
            g_guideManager.registComponent(2000200 + showIndex,btnBattle)
        end
    end

    if #self.armyList > showIndex then
        for index = #self.armyList -1, showIndex, -1 do
            self.list:removeLastItem()
            table.remove(self.armyList,#self.armyList)
        end
    end


    --[[
    local showIndex = 0
    local idx = 1
    local function loadItem()
        local data = self.gorpsort[idx]

        if data == nil then
            if #self.armyList > showIndex then
                for index = #self.armyList -1, showIndex, -1 do
                    self.list:removeLastItem()
                    table.remove(self.armyList,#self.armyList)
                end
            end
            self:unscheduleUpdate()
            return
        end

        if #self.group[data.id] > 0 then
            showIndex = showIndex + 1
            local item = self.armyList[showIndex]
            if item then
                self:itemInitUI( self.armyList[showIndex] , data)
            else
                item = cc.CSLoader:createNode("battle_select_item_1.csb")
                self.list:pushBackCustomItem(item)
                self:itemInitUI( item , data)
                table.insert(self.armyList,item)
            end
            local btn_quickBattle = item:getChildByName("item"):getChildByName("Button_1")
            g_guideManager.registComponent(2000100 + showIndex,btn_quickBattle)

            local btnBattle = item:getChildByName("item"):getChildByName("btn_battle")
            g_guideManager.registComponent(2000200 + showIndex,btnBattle)
        end

        idx = idx + 1

    end

    self:scheduleUpdateWithPriorityLua( loadItem , 0)
    ]]
    
    
    --[[if #self.armyList <= 0 then
        for idx,data in ipairs(self.gorpsort) do
            --别忘记了做没有士兵的军团处理
            --if #self.group[data.id] > 0 then
            local item = itemmode:clone()
            self.list:pushBackCustomItem(item)
            self:itemInitUI( item , data)
            table.insert(self.armyList,item)
            local btn_quickBattle = item:getChildByName("item"):getChildByName("Button_1")
            g_guideManager.registComponent(2000100 + idx,btn_quickBattle)
            
            local btnBattle = item:getChildByName("item"):getChildByName("btn_battle")
            g_guideManager.registComponent(2000200 + idx,btnBattle)
            --end
        end
    else
        for idx,data in ipairs(self.gorpsort) do
            if self.armyList[idx] then
                self:itemInitUI( self.armyList[idx] , data)
            end
        end
    end]]
end

function battleSettingView:onExit()
    self:clearGlobal()
    self.usePower = nil
end


function battleSettingView:clearGlobal()
    self.playerArmyUnitData = nil
    self.playerArmyData = nil
    self.gotoTimeList = nil
    self.playerData = nil
    self.postb = nil
    self.isJiJie = nil
    self.callback = nil
    self.parCallBack = nil
    self.armyList = nil
end

--武将所带的兵数量未达到最高 提示
function battleSettingView:confirm(ArmyID,tabType,_callback)
    --local confirm = self:loadUI("battle_select_confirm.csb")
    local confirm = g_gameTools.LoadCocosUI("battle_select_confirm.csb", 5)

    local root = confirm:getChildByName("scale_node")
    local panel = root:getChildByName("content_popup")
    local close_btn = panel:getChildByName("close_btn")
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		confirm:removeFromParent()
	end)
    
    local title = panel:getChildByName("bg_title"):getChildByName("Text")
    title:setString(g_tr("nomaxtitle"))

    local desc = panel:getChildByName("Text")
    desc:setString(g_tr("nomaxstr"))

    local btn_battle = panel:getChildByName("btn_battle")
    self:regBtnCallback(btn_battle,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        if _callback then
            _callback()
        end
        confirm:removeFromParent()
        --self:goOut(ArmyID,OUT_USEDEF)
	end)
    btn_battle:getChildByName("Text"):setString(g_tr("campaign"))

    local btn_edit = panel:getChildByName("btn_edit")
    self:regBtnCallback(btn_edit,function ()
		--print("EDIT")
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        local function callback()
            self:setVisible(true)
            confirm:removeFromParent()
            self:filterData()
            self:initUI()
        end

        self:setVisible(false)
        g_sceneManager.addNodeForUI(require("game.uilayer.drill.DrillView").new( callback ,tabType))

	end)

    btn_edit:getChildByName("Text"):setString(g_tr("campaignSet"))

    g_sceneManager.addNodeForUI(confirm)

end

function battleSettingView:noArmyConfirm( callback1,callback2 )
    
    local confirm = g_gameTools.LoadCocosUI("battle_select_confirm.csb", 5)

    local root = confirm:getChildByName("scale_node")
    local panel = root:getChildByName("content_popup")
    local close_btn = panel:getChildByName("close_btn")
    close_btn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            if confirm then
                confirm:removeFromParent()
                confirm = nil
            end
        end
    end)

    --self:regBtnCallback(close_btn,function ()
        --g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
	    --confirm:removeFromParent()
    --end)

    local title = panel:getChildByName("bg_title"):getChildByName("Text")
    title:setString(g_tr("nomaxtitle"))

    local desc = panel:getChildByName("Text")
    desc:setString(g_tr("battleOutIsEmpty"))

    local btn_battle = panel:getChildByName("btn_battle")
    btn_battle:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            g_sceneManager.addNodeForUI(require("game.uilayer.science.ScienceLayer").new())

            if callback1 then
                callback1()
            end

            if confirm then
                confirm:removeFromParent()
                confirm = nil
            end

        end
    end)

    --self:regBtnCallback(btn_battle,function ()
    --    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    --    g_sceneManager.addNodeForUI(require("game.uilayer.science.ScienceLayer").new())
	--end)

    btn_battle:getChildByName("Text"):setString(g_tr("battleGotoKeji"))

    local btn_edit = panel:getChildByName("btn_edit")
    btn_edit:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            g_sceneManager.addNodeForUI(require("game.uilayer.vip.VIPMainLayer").new())

            if callback2 then
                callback2()
            end

            if confirm then
                confirm:removeFromParent()
                confirm = nil
            end
        end
    end)
    
    --self:regBtnCallback(btn_edit,function ()
    --    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    --    g_sceneManager.addNodeForUI(require("game.uilayer.vip.VIPMainLayer").new())
	--end)

    btn_edit:getChildByName("Text"):setString(g_tr("battleGotoVip"))
    g_sceneManager.addNodeForUI(confirm)

end

function battleSettingView:addCallBack(fun)
    self.parCallBack = fun
end

function battleSettingView:goOut(ArmyID,outType)
    if self.callback then
        self.callback( ArmyID,function ()
            local function onPlaySound()
                g_musicManager.playEffect(g_data.sounds[5000039].sounds_path,false)
            end
            g_autoCallback.addCocosList( onPlaySound , 2.0 )
        end,outType)
        self:close()
    end
end

function battleSettingView:setUsePowerType(type)
    self.usePower = 0
    if type == g_Consts.FightCostPowerType.CostFree then
        self.usePower = 0
    else
        self.usePower = g_data.starting[type].data
    end
end



return battleSettingView