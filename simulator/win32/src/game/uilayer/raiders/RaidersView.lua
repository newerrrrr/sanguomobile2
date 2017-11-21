local RaidersView = class("RaidersView", require("game.uilayer.base.BaseLayer"))

local titleType = 
{
    [1] = g_tr("raiders_js_title_str1"),
    [2] = g_tr("raiders_js_title_str2"),
    [3] = g_tr("raiders_js_title_str3"),
    [4] = g_tr("raiders_nz_title_str4"),
    [5] = g_tr("raiders_nz_title_str5"),
}

local getType = 
{
    [1] = "getScienceSoldier",
    [2] = "getSoldierCount",
    [3] = "getArmyPower",
    [4] = "getArmyLoad",
    [5] = "getFoodYield",
}

local btnType =
{
    [1] = g_tr("raiders_jz_str"),
    [2] = g_tr("raiders_xl_str"),
    [3] = g_tr("raiders_zm_str"),
    [4] = g_tr("raiders_sj_str"),
    [5] = g_tr("raiders_dz_str"),
    [6] = g_tr("raiders_ky_str"),
    [7] = g_tr("raiders_tf_str"),
    [8] = g_tr("raiders_bw_str"),
}

function RaidersView:ctor( type )
    RaidersView.super.ctor(self)
    self.pLv = g_PlayerBuildMode.FindBuild_high_OriginID(1).build_level
    self.type = type or 1
    self.minPer = 100
end

function RaidersView:onEnter()
    self:initUI()
    self:initList()

    --0 50 70

    local pfAImg = self.root:getChildByName("Image_z1")
    pfAImg:setVisible(false)

    local pfBImg = self.root:getChildByName("Image_z2")
    pfBImg:setVisible(false)

    local pfCImg = self.root:getChildByName("Image_z3")
    pfCImg:setVisible(false)
    

    local old = g_saveCache["first_pj_save"]
    local new = self.minPer
    local function getPjPath(pj)
        
        local img = nil
        local pjIdx = nil
        
        if pj <= 50 then
            img = pfCImg
            pjIdx = 3
        elseif pj > 50 and pj < 70 then
            img = pfBImg
            pjIdx = 2
        else
            img = pfAImg
            pjIdx = 1
        end

        return pjIdx,img
    end
    
    local oldIdx,oldImg = getPjPath(old)
    local newIdx,newImg = getPjPath(new)
    
    if oldIdx ~= newIdx then
        local border = self.root:getChildByName("Image_10")
        self:setPjXsFx(border,oldIdx,function ()
            self:setPjCxFx(border,newIdx,function () 
                newImg:setVisible(true)
            end)
        end)
        g_saveCache["first_pj_save"] = new
    else
       oldImg:setVisible(true) 
    end

    local rwImg = self.root:getChildByName("Image_renw")
    local path = ""
    local ms = self.root:getChildByName("Image_9")
    local cj = self.root:getChildByName("Image_9m")

    ms:setVisible(false)
    cj:setVisible(false)

    if self.type == 1 then
        cj:setVisible(true)
        path = g_resManager.getResPath(1030018)
    elseif self.type == 2 then
        ms:setVisible(true)
        path = g_resManager.getResPath(1030061)
    end
    rwImg:loadTexture(path)

    local cg1,cg2 = self:getCgRs()

    local cgrsTx = self.root:getChildByName("Text_9")
    cgrsTx:setString( g_tr("raiders_cgrs_str",{ num = cg1 .. "%%" }) )
    local rich1 = g_gameTools.createRichText(cgrsTx,cgrsTx:getString())
    self:setCgrsFx(rich1)

    local sdcgrsTx = self.root:getChildByName("Text_9_0")
    sdcgrsTx:setString(g_tr("raiders_sdcgrs_str",{ num = cg2.. "%%" })  )

    local rich2 = g_gameTools.createRichText(sdcgrsTx,sdcgrsTx:getString())
    self:setCgrsFx(rich2)
    
end

function RaidersView:initUI()

    self.layer = self:loadUI("Raiders_main3.csb")
    
    self.root = self.layer:getChildByName("scale_node")

    local closeBtn = self.layer:getChildByName("mask")
    self:regBtnCallback(closeBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
	end)

    local closeTx = self.root:getChildByName("Text_gb")
    closeTx:setString(g_tr("clickhereclose"))

    self.list = self.root:getChildByName("ListView_1")
    self.list:setItemsMargin(5)

    local djTx = self.root:getChildByName("Text_lj2")
    djTx:setString(tostring(self.pLv))

    local pjTx = self.root:getChildByName("Text_13")
    pjTx:setString(g_tr("raiders_pj_str"))

    local trunOffBtn = self.root:getChildByName("Button_1")
    trunOffBtn:getChildByName("Text_4"):setString( g_tr("raiders_close_str4"))
    
    self:regBtnCallback(trunOffBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        require("game.uilayer.raiders.RaidersMainView").trunOffThis(function (eventType)
            if eventType == 1 then
                self:close()
            end
        end)
	end)

    trunOffBtn:setVisible(false)

    local smImg = self.root:getChildByName("Image_10")
    g_itemTips.tipStr(smImg,g_tr_original("raiders_sm_title_str"),g_tr_original("raiders_sm_str"))

end


function RaidersView:getNowShowConfig(cfg)
    local _cfg = nil
    for key, var in ipairs(cfg) do
        if not var.isCom then
            _cfg = var
            break
        end
    end
    return _cfg
end

function RaidersView:initList()
    --local playerLv = 9
    local mode = cc.CSLoader:createNode("Raiders_main3_list1.csb")
    local config = self:getNowConfig()
    --dump(config)

    local function touch1(sender,eventType)
        if eventType == ccui.TouchEventType.ended then

            local cfg = sender.cfg
            local _cfg = self:getNowShowConfig(cfg)
            local _callback
            
            --跳转建筑
            if _cfg then
                --建筑
                if _cfg.type == 1 then
                    _callback = function ()
                        local buildOrginId = _cfg.condition
                        local buildLv = _cfg.condition_level
                        self:jumpToBuild(buildOrginId)
                        self:close()
                    end
                end

                --士兵
                if _cfg.type == 2 then
                    _callback = function ()
                        local soldierId = _cfg.condition
                        local scfg = g_data.soldier[soldierId]
                        local sNeedBuildId = scfg.need_build_id
                        local buildOrginId = g_data.build[sNeedBuildId].origin_build_id
                        self:jumpToBuild(buildOrginId)
                        self:close()
                    end
                end

                local layer = require("game.uilayer.common.DialogueLayer"):create(g_tr(_cfg.hint_text),_callback,nil,nil,1030061)
                g_sceneManager.addNodeForGuideDisplay(layer)

            end
        end
    end

    local function touch2(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local cfg = sender.cfg
            local _cfg = self:getNowShowConfig(cfg)
            local _callback
            
            --跳转
            if _cfg then
                --招募武将
                if _cfg.type == 3 then
                    _callback = function ()
                        local buildOrginId = 14
                        self:jumpToBuild(buildOrginId)
                        self:close()
                    end
                    
                end

                if _cfg.type == 4 then
                    _callback = function ()
                        require("game.maplayer.changeMapScene").changeToWorld()
                        require("game.uilayer.mainSurface.mainSurfaceChat").createFindMosterHand()
                        self:close()
                    end
                end

                if _cfg.type == 5 then
                    _callback = function ()
                        local buildOrginId = 9
                        self:jumpToBuild(buildOrginId)
                        self:close()
                    end
                end
                
                local layer = require("game.uilayer.common.DialogueLayer"):create(g_tr(_cfg.hint_text),_callback,nil,nil,1030061)
                g_sceneManager.addNodeForGuideDisplay(layer)
            end
        end
    end

    local function touch3(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local cfg = sender.cfg

            local _cfg = self:getNowShowConfig(cfg)
            local _callback

            dump(_cfg)

            --科研
            if _cfg.type == 6 then
                 _callback = function ()
                    local buildOrginId = 10
                    self:jumpToBuild(buildOrginId)
                    self:close()
                end
            end
            --天赋
            if _cfg.type == 7 then
                _callback = function ()
                    require("game.uilayer.master.MasterTalentView"):createLayer()
                    self:close()
                end
            end

            local layer = require("game.uilayer.common.DialogueLayer"):create(g_tr(_cfg.hint_text),_callback,nil,nil,1030061)
            g_sceneManager.addNodeForGuideDisplay(layer)

        end
    end
    
    --for idx = 1, table.nums(config) do
    for key, var in pairs(config) do
        
        local node = mode:clone()
        local title = node:getChildByName("Text_lj1")
        local bar = node:getChildByName("LoadingBar_1")
        local barTx = node:getChildByName("Text_1")

        local jdNum = self[getType[key]]()

        local maxjdNum = self.getScoreMax(key,self.pLv)
         
        local jdPer = math.floor(jdNum / maxjdNum * 100)

        jdPer = (jdPer >= 100) and 100 or jdPer

        title:setString(titleType[key])
        barTx:setString(string.format("%d/%d(%d%%)",jdNum,maxjdNum,jdPer))
        bar:setPercent( jdPer )

        self.minPer = math.min( self.minPer,jdPer )
        
        local btn1 = node:getChildByName("Button_1")
        btn1.cfg = config[key][1]
        local isCom = self:isAllCom(btn1.cfg)
        local nowcfg = self:getNowShowConfig(btn1.cfg)
        btn1:getChildByName("Text_6"):setString( isCom and g_tr("raiders_wc_str") or btnType[nowcfg.type] )
        --没有完成按钮亮
        btn1:setVisible( not isCom )
        node:getChildByName("Button_1")
        btn1:addTouchEventListener(touch1)
        node:getChildByName("wc_1"):setVisible(isCom)

        local btn2 = node:getChildByName("Button_2")
        btn2.cfg = config[key][2]
        local isCom = self:isAllCom(btn2.cfg)
        local nowcfg = self:getNowShowConfig(btn2.cfg)
        btn2:getChildByName("Text_6"):setString( isCom and g_tr("raiders_wc_str") or btnType[nowcfg.type] )
        --没有完成按钮亮
        btn2:setVisible( not isCom )
        btn2:addTouchEventListener(touch2)
        node:getChildByName("wc_2"):setVisible(isCom)

        local btn3 = node:getChildByName("Button_3")
        btn3.cfg = config[key][3]
        local isCom = self:isAllCom(btn3.cfg)
        local nowcfg = self:getNowShowConfig(btn3.cfg)
        btn3:getChildByName("Text_6"):setString( isCom and g_tr("raiders_wc_str") or btnType[nowcfg.type] )
        --没有完成按钮亮
        btn3:setVisible( not isCom )
        node:getChildByName("wc_3"):setVisible(isCom)
        btn3:addTouchEventListener(touch3)
        
        self.list:pushBackCustomItem( node )
    end
    
        
    --end
end

--获取引导进度最大值
function RaidersView.getScoreMax(target_group,level)
     local scoreConfig = g_data.score
     for key, var in ipairs(scoreConfig) do
        if var.target_group == target_group and var.level == level then
            return var.score
        end
     end
     return 0
end



--获取所有需要引导的条件并且判断是否已经完成
function RaidersView:getNowConfig()
    --g_data.secretary
    local nLvCfg = {}
    local config = {}

    
    for _, var in pairs(g_data.secretary) do
        if self.type == 1 then
            if var.target_group == 1 or var.target_group == 2 or var.target_group == 3 then
                table.insert(config,var)
            end
        elseif self.type == 2 then
            if var.target_group == 1 or var.target_group == 4 or var.target_group == 5 then
                table.insert(config,var)
            end
        end
    end
    
    for idx, var in pairs(config) do
        if var.level == self.pLv then
            local target_group = var.target_group
            --var.target_group
            if nLvCfg[target_group] == nil then nLvCfg[target_group] = {} end
            --dump(var)
            local isCom = false
            local condition = var.condition
            if condition ~= 0 then
                if var.type == 1 or var.type == 2 then
                    
                    --dump(var)
                    --建筑
                    if var.type == 1 then
                        local buildOrginId = condition
                        local buildLv = var.condition_level
                        isCom = self:isBuildLvCom(buildOrginId,buildLv)
                    --士兵
                    elseif var.type == 2 then
                        local soldierId = condition
                        local soldierNum = var.condition_level
                        isCom = self:isSoldierCom(soldierId,soldierNum)
                    end

                    if nLvCfg[target_group][1] == nil then nLvCfg[target_group][1] = {} end
                    local cfg = clone(var)
                    cfg.isCom = isCom
                    table.insert( nLvCfg[target_group][1],cfg )
                end

                if var.type == 3 or var.type == 4 or var.type == 5 then
                    
                    --拥有武将
                    if var.type == 3 then
                        local rootId = condition
                        isCom = self:isGeneralCom(rootId)
                    end

                    --拥有装备
                    if var.type == 4 then
                        local equmentId = condition
                        isCom = self:isEqumentCom(equmentId)
                    end

                    --锻造装备
                    if var.type == 5 then 
                        local equmentId = condition
                        local equmentLv = var.condition_level
                        isCom = self:isEqumentUpCom(equmentId,equmentLv)
                    end

                    if nLvCfg[target_group][2] == nil then nLvCfg[target_group][2] = {} end
                    local cfg = clone(var)
                    cfg.isCom = isCom
                    table.insert( nLvCfg[target_group][2],cfg) 
                end

                if var.type == 6 or var.type == 7 or var.type == 8 then
                    
                    --科研
                    if var.type == 6 then
                        local scienceId = condition
                        local scienceLv = var.condition_level
                        isCom = self:isScienceCom(scienceId,scienceLv)
                    end
                    
                    --天赋
                    if var.type == 7 then
                        local talentId = condition
                        local talentLv = var.condition_level
                        isCom = self:isTalentCom(talentId,talentLv)
                    end

                    if var.type == 8 then
                        
                    end

                    if nLvCfg[target_group][3] == nil then nLvCfg[target_group][3] = {} end
                    local cfg = clone(var)
                    cfg.isCom = isCom
                    table.insert( nLvCfg[target_group][3],cfg ) 
                end
            end
        end
    end

    for _, var in pairs(nLvCfg) do
        for __, _var in pairs(var) do
            table.sort( _var ,function (a,b)
                return a.id < b.id
            end )
        end
    end
    --dump(nLvCfg)
    return nLvCfg
end


--判断建筑等级是否达成
function RaidersView:isBuildLvCom(bid,blv)
    local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(bid)
    if buildData then
        return buildData.build_level >= blv
    else
        --print("建筑不存在")
    end
    return false
end

--判断士兵是否达成
function RaidersView:isSoldierCom(sid,num)
    --print("sid,num",sid,num)
    local sdata = g_SoldierMode:GetData() 
    for k, v in pairs(sdata) do
        if v.soldier_id == sid and v.num >= num then
            return true
        end
    end
    return false
end

--判断招募是否达成
function RaidersView:isGeneralCom(rid)
    local generals = g_GeneralMode.GetData()
    for key, var in ipairs(generals) do
        if g_data.general[ tonumber(var.general_id .. "01")].root_id == rid then
            return true
        end
    end
   return false
end

--判断是否拥有装备
function RaidersView:isEqumentCom(eid)
    local generals = g_GeneralMode.GetData()
    for key, var in ipairs(generals) do
        local weapon = g_data.equipment[var.weapon_id]
        local horse = g_data.equipment[var.horse_id]
        local armor = g_data.equipment[var.armor_id]
        local zuoji = g_data.equipment[var.zuoji_id]

        if weapon.item_original_id  == eid then
             return true
        end

        if horse and horse.item_original_id == eid then
            return true
        end

        if armor and armor.item_original_id == eid then
            return true
        end

        if zuoji and zuoji.item_original_id == eid then
            return true
        end
    end
    
    local equips = g_EquipmentlMode.GetData()
    for key, var in ipairs(equips) do
        if g_data.equipment[var.item_id].item_original_id == eid then
            return true
        end 
    end
    
    return false
end

--判断武器星级
function RaidersView:isEqumentUpCom(eid,lv)
    
    local generals = g_GeneralMode.GetData()
    for key, var in ipairs(generals) do
        
        local weapon = g_data.equipment[var.weapon_id]
        local horse = g_data.equipment[var.horse_id]
        local armor = g_data.equipment[var.armor_id]
        local zuoji = g_data.equipment[var.zuoji_id]

        if weapon.item_original_id == eid and weapon.star_level >= lv then
            return true
        end

        if horse and  horse.item_original_id == eid and horse.star_level >= lv then
            return true
        end

        if armor and armor.item_original_id == eid and armor.star_level >= lv then
            return true
        end

        if zuoji and zuoji.item_original_id == eid and zuoji.star_level >= lv then
            return true
        end
    end

    local equips = g_EquipmentlMode.GetData()
    for key, var in ipairs(equips) do
        local equipCfg = g_data.equipment[var.item_id]
        if equipCfg.item_original_id == eid and equipCfg.star_level >= lv then
            return true
        end 
    end
    
    return false
end

--判断研究技能等级
function RaidersView:isScienceCom(sid,lv)
    local science = g_ScienceMode.GetScienceByOriginID(sid)
    if science then
        return g_data.science[science.science_id].level_id >= lv
    end
    return false
end

--判断研究技能等级
function RaidersView:isTalentCom(tid,lv)

    local talent = g_MasterTalentMode.GetTalentByOriginID(tid)
    if talent then
       return g_data.talent[ talent.talent_id ].level_id >= lv
    end

    return false
    
end

function RaidersView:jumpToBuild(bid)
    local buildData = g_PlayerBuildMode.FindBuild_high_OriginID(bid)
    if buildData then
        local pos = buildData.position
        local function gotoSuccessHandler()
            --升级中
            if buildData.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
            
            end
        end
        require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(pos,gotoSuccessHandler)
    else
        local build_id = bid * 1000 + 1
        local needBuildID = g_PlayerBuildMode.FindBuildConfig_firstBuilding_ConfigID(build_id)
        local canBuildPlace = require("game.maplayer.homeMapLayer").getClearingWithBuildID(needBuildID.id)
        if(canBuildPlace)then
            require("game.maplayer.changeMapScene").gotoHomeAndOpenInterface_Place(canBuildPlace) --打开空地位置
            require("game.uilayer.buildSelect.buildSelect").setWantConfigID(needBuildID.id) --定位到指定的建筑
        end
    end
end

function RaidersView:isAllCom(configList)
    
    for key, var in ipairs(configList) do
        if not var.isCom then
            return false
        end
    end
    
    return true
end

--武将带兵数量加层
function RaidersView.getScienceSoldier()
    local maxSoldier = 0
    local armyData = g_ArmyUnitMode.GetCurentData()
    for k, v in pairs(armyData) do
        if v.soldier_id and tonumber(v.soldier_id) ~= 0 then
            maxSoldier = math.max( maxSoldier , v.soldier_num )
        end
    end

    local finalList,addList = require("game.uilayer.buildupgrade.BuildingUIHelper").getJiaoChangInfo()
    
    return finalList[14]
end

--士兵总数量
function RaidersView.getSoldierCount()
    local sCount = require("game.uilayer.buildupgrade.BuildingUIHelper").getResourceBuildOutPut(g_PlayerBuildMode.m_BuildOriginType.food,false)
    --[[local data = g_SoldierMode:GetData() 
    for k, v in pairs(data) do
        if v.soldier_id and tonumber(v.soldier_id) ~= 0 then
            sCount = sCount + v.num
        end
    end

    --当前军团里士兵的
    local armyData = g_ArmyUnitMode.GetCurentData()
    for k, v in pairs(armyData) do
        if v.soldier_id and tonumber(v.soldier_id) ~= 0 then
            sCount = sCount + v.soldier_num
        end
    end]]
    return sCount
end

--军团战力
function RaidersView.getArmyPower()
    local armys = g_ArmyMode.GetData()
    local armyUnits = g_ArmyUnitMode.GetData()
    local armyGroup = {}
    local maxPower = 0

    for _, var in pairs(armys) do
        if armyGroup[var.id] == nil then armyGroup[var.id] = {} end
        local power = 0
        for __, data in ipairs(armyUnits) do
            if var.id == data.army_id then
                power = power + data.power
                table.insert(armyGroup[var.id],data)
            end
        end
        maxPower = math.max(maxPower,power)
    end
    
    return maxPower
end

--军团负重
function RaidersView.getArmyLoad()
    local armys = g_ArmyMode.GetData()
    local weight = 0
    if armys and table.nums(armys) > 0 then
        for key, var in pairs(armys) do
            if var.leader_general_id ~= 0 then
                weight = math.max(var.weight,weight)
            end
        end
    end
    return weight
end

--农田产量
function RaidersView.getFoodYield()
    local foodOutByHour = require("game.uilayer.buildupgrade.BuildingUIHelper").getResourceBuildOutPut(g_PlayerBuildMode.m_BuildOriginType.food,false)
    return foodOutByHour 
end

function RaidersView:setCgrsFx(node)
    local armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_TiaoDongShuZi/Effect_TiaoDongShuZi.ExportJson"
        , "Effect_TiaoDongShuZi"
    )
    armature:setPosition(cc.p(node:getContentSize().width, node:getContentSize().height/2))
    node:addChild(armature)
    animation:play("Animation1")
end

function RaidersView:setPjCxFx(node,_type,_callback)

    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            if _callback then
                _callback()
            end
            armature:removeFromParent()
        end
    end 

    local armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_PingJiaZiTiChuXian/Effect_PingJiaZiTiChuXian.ExportJson"
        , "Effect_PingJiaZiTiChuXian"
        , onMovementEventCallFunc
    )
    armature:setPosition(cc.p(node:getContentSize().width/2 + 6, node:getContentSize().height/2 + 3.5))
    node:addChild(armature)
    animation:play("Animation" .. _type)

end

function RaidersView:setPjXsFx(node,_type,_callback)

    local function onMovementEventCallFunc(armature , eventType , name)
        if ccs.MovementEventType.complete == eventType or ccs.MovementEventType.loopComplete == eventType then
            if _callback then
                _callback()
            end
            armature:removeFromParent()
        end
    end 


    local armature , animation = g_gameTools.LoadCocosAni(
        "anime/Effect_PingJiaZiTiXiaoSan/Effect_PingJiaZiTiXiaoSan.ExportJson"
        , "Effect_PingJiaZiTiXiaoSan"
        , onMovementEventCallFunc
    )
    armature:setPosition(cc.p(node:getContentSize().width/2 + 6 , node:getContentSize().height/2 + 3.5))
    node:addChild(armature)
    animation:play("Animation" .._type )

end

--超过人数
function RaidersView:getCgRs()
    --playerpower/power/2*100%
    local cgConfig = g_data.power
    local cfg
    local index
    for idx, var in ipairs(cgConfig) do
        if var.level == self.pLv then
            cfg = var
            index = idx
        end
    end
    
    local cg1 = ( g_PlayerMode.GetData().power / cfg.power / 2)
    local upLvPower = cgConfig[index - 1] and cgConfig[index - 1].power or 250000
    local powerAdd = ( g_PlayerMode.GetData().power - g_saveCache["first_power_save"]  )
    powerAdd = math.max( 1, powerAdd)
    local cg2 = ( powerAdd / ( cfg.power -  upLvPower ))
    
    cg1 = cg1 * 100
    if cg1 >= 99 then
        cg1 = 99
    elseif cg1 <= 1 then
        cg1 = 1
    end

    cg2 = cg2 * 100
    if cg2 >= 99 then
        cg2 = 99
    elseif cg2 <= 1 then
        cg2 = 1
    end
    
    cg1 = string.format( "%d",cg1) 
    cg2 = string.format( "%d",cg2)
    
    return cg1,cg2

end



return RaidersView