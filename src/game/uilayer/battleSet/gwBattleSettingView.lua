local gwBattleSettingView = class("gwBattleSettingView",require("game.uilayer.base.BaseLayer"))

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

--正常出行
local OUT_USEDEF = 0

--fun:回调方法，
--post:目的地的XY
--fightType:计算时间战斗类型
function gwBattleSettingView:createLayer( fun,postb,fightType)
    
    self:clearGlobal()
    
    self.postb = postb

    self.fightType = fightType

    self.playerData = g_guildWarPlayerData.GetData()

    g_sceneManager.addNodeForUI(gwBattleSettingView:create( fun ))

    return true
end

function gwBattleSettingView:ctor(fun)
    gwBattleSettingView.super.ctor(self)

    self.callback = fun
    self.armyList = {}
    g_groundData.RequestSycCrossBattleData( function (result,data)
        if result == true then
            self.playerArmyData = g_crossArmy.GetData()
            self.playerArmyUnitData = g_crossArmyUnit.GetData()
            
            if self.playerArmyData == nil or  self.playerArmyUnitData == nil then
                return
            end

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

function gwBattleSettingView:onEnter()
    self.layout = self:loadUI("battle_select_army.csb")
    --g_topTipRes.installRes(self.layout, {g_Consts.AllCurrencyType.Gem, g_Consts.AllCurrencyType.PlayerHonor})
    --g_resourcesInterface.installResources(self.layout)
    self.topRes = require("game.gametools.TopTitleRes").new(self.layout, {g_Consts.AllCurrencyType.Gem, g_Consts.AllCurrencyType.PlayerHonor})

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

function gwBattleSettingView:filterData(callback)
    
    local function update()
        self.playerArmyData = g_crossArmy.GetData()
        self.playerArmyUnitData = g_crossArmyUnit.GetData()
        self.playerBuffData = g_BuffMode.GetData()
        self.gorpsort = {} --排序使用
        self.group = {} --数据

        if self.playerArmyData == nil or  self.playerArmyUnitData == nil then
            return
        end

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
    g_sgHttp.postData("cross/getGotoTime", { x = self.postb.x,y = self.postb.y,type = self.fightType }, callback,true)

end


function gwBattleSettingView:itemInitUI(item,data)
    
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
    
    xdlTx:setVisible(false)
    xdlTx:setString( g_tr("battleMove",{ move = self.usePower or 0 } ) )
    resImg:setVisible(false)
        
    resTx:setString(g_tr("armyLeft"))
    
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
    local isAllMax = true

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
                local general = g_crossGeneral.getOwnedGeneralByOriginalId(t.general_original_id)
                local item = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.General,t.id, 1)
                item:setPosition( cc.p( pic:getContentSize().width/2,pic:getContentSize().height/2) )
                item:setCountEnabled(false)
                item:showGeneralServerStarLv(general.star_lv)
                pic:addChild(item)
                pic.icon = item
            end
            

            name:setString( g_tr( t.general_name ) )

            local max_soldier = g_crossArmy.GetMaxArmyNum(d.general_id)
            
            print("soldier_num,max_soldier",d.soldier_num,max_soldier)

            if d.soldier_num < max_soldier then
                isAllMax = false
            end

            if st then
                ico:setVisible(true)
                num:setVisible(true)
                s_type[st.soldier_type] = s_type[st.soldier_type] + d.soldier_num
                ico:loadTexture(g_resManager.getResPath( st.img_type ))
                num:setString( tostring(d.soldier_num) )
                soldierCount = soldierCount + d.soldier_num
                print("soldierCount",soldierCount)

                local sValue = d.soldier_num / max_soldier * 100

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
        g_sceneManager.addNodeForUI(require("game.uilayer.drill.CrossDrillView").new(callback,tabType))
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
        
        require("game.mapguildwar.changeMapScene").changeToWorld( false, function ()
            local queueServerData = require("game.mapguildwar.worldMapLayer_bigMap").getQueueServerData_armyId(ArmyID)
            if queueServerData then
                require ("game.uilayer.mainSurface.mainSurfaceQueueWorld").simulationTouchQueue(queueServerData)
            end
        end )
        
    end )
    
    resNumTx:setString( tostring(g_crossSoldier.GetAllSoldierNumber()) )

    local btn_supplement =  panel:getChildByName("btn_supplement")
    btn_supplement:getChildByName("Text"):setString(g_tr("quickAdd"))
    
    local function oneKey(isShow)
        local function callback(result, data)
            g_busyTip.hide_1()
            if result == true then
                self.topRes:update()
                self:filterData( function ()
                    if isShow then
                        g_airBox.show(g_tr("fullSuc"))
                    end
                end )
            end
        end
        g_busyTip.show_1()
        g_netCommand.send("Cross/fullfillSoldier", { ["armyPosition"] = data.position }, callback,true)
    end

    self:regBtnCallback( btn_supplement,function ()
        oneKey(true)
    end)
    
    --贡献买兵
    local addRyBtn = panel:getChildByName("btn_supplement_0")
    addRyBtn:getChildByName("Image_5_0"):loadTexture(g_data.sprite[1999008].path)
    addRyBtn:getChildByName("Text"):setString(g_tr("buySoldier"))
    local cost = g_data.cost[tonumber(g_data.warfare_service_config[29].data) + 10000].cost_num
    addRyBtn:getChildByName("Text_0"):setString(tostring(cost))
    self:regBtnCallback( addRyBtn,function ()
        if isAllMax then
            g_airBox.show(g_tr("soldier_full"))
            return
        end

        --print("贡献买兵")
        local mode = require("game.uilayer.drill.DrillMode").new()
        mode:buySoldier(2,oneKey)--贡献
        resNumTx:setString( tostring(g_crossSoldier.GetAllSoldierNumber()) )
    end)

    --元宝买兵
    local addYbBtn = panel:getChildByName("btn_supplement_1")
    addYbBtn:getChildByName("Text"):setString(g_tr("buySoldier"))
    local cost = g_data.cost[tonumber(g_data.warfare_service_config[41].data) + 10000].cost_num
    addYbBtn:getChildByName("Text_0"):setString(tostring(cost))
    self:regBtnCallback( addYbBtn,function ()
        --print("元宝买兵")
         if isAllMax then
             g_airBox.show(g_tr("soldier_full"))
            return
        end

        local mode = require("game.uilayer.drill.DrillMode").new()
        mode:buySoldier(1,oneKey)--元宝
        resNumTx:setString( tostring(g_crossSoldier.GetAllSoldierNumber()) )
    end)

    
    
    local status = data.status or 0
    btn_battle:setVisible( not (status == 1) )
    btn_edit:setTouchEnabled( not (status == 1) )
    edit_Txt:setVisible( not (status == 1) )

    btn_supplement:setVisible( not (status == 1) )
    
    addRyBtn:setEnabled( not (status == 1))
    addYbBtn:setEnabled( not (status == 1))
    
    xdlTx:setVisible( not (status == 1) )

    status_img:setVisible( status == 1 )
    status_str:setVisible( status == 1 )
    view_btn:setVisible( status == 1 )

    moveToBtn:setVisible( false )
    moveToBtn:getChildByName("Text"):setString(g_tr("battleMoveTitle"))

end

function gwBattleSettingView:initUI()
    self.list = self.root:getChildByName("ListView_1")
    self.list:setItemsMargin(25)
    local itemmode = cc.CSLoader:createNode("battle_select_item_3.csb")
    
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
            local btnBattle = item:getChildByName("item"):getChildByName("btn_battle")
        end
    end

    if #self.armyList > showIndex then
        for index = #self.armyList -1, showIndex, -1 do
            self.list:removeLastItem()
            table.remove(self.armyList,#self.armyList)
        end
    end
end

function gwBattleSettingView:onExit()
    self:clearGlobal()
end


function gwBattleSettingView:clearGlobal()
    self.playerArmyUnitData = nil
    self.playerArmyData = nil
    self.gotoTimeList = nil
    self.playerData = nil
    self.postb = nil
    self.callback = nil
    self.parCallBack = nil
    self.armyList = nil
    self.usePower = nil
end

--武将所带的兵数量未达到最高 提示
function gwBattleSettingView:confirm(ArmyID,tabType,_callback)
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
        g_sceneManager.addNodeForUI(require("game.uilayer.drill.CrossDrillView").new(callback ,tabType))

	end)

    btn_edit:getChildByName("Text"):setString(g_tr("campaignSet"))

    g_sceneManager.addNodeForUI(confirm)

end

function gwBattleSettingView:noArmyConfirm()
    --g_msgBox.show( g_tr("battleOutIsEmpty"))
    g_airBox.show(g_tr("battleGuildAir"))
end

function gwBattleSettingView:addCallBack(fun)
    self.parCallBack = fun
end

function gwBattleSettingView:goOut(ArmyID,outType)
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

function gwBattleSettingView:setUsePowerType(type)
    self.usePower = 0
    if type == g_Consts.FightCostPowerType.CostFree then
        self.usePower = 0
    else
        self.usePower = g_data.starting[type].data
    end
end



return gwBattleSettingView