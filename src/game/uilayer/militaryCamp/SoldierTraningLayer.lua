require "socket"

local MilitaryCampData = require("game.uilayer.militaryCamp.MilitaryCampData"):instance()
local SoldierTypeEnum = nil
local SoldierTraningLayer = class("SoldierTraningLayer",require("game.uilayer.base.BaseLayer"))
local m_Root = nil
--[[local soldierInfo = {
  ["Infantry"] = 1,   --步兵
  ["Cavalry"] = 2,    --骑兵
  ["Archer"] = 3,     --弓兵
  ["Catapults"] = 4,  --投石车
  ["Trap"] = 5,       --陷阱
}]]

--兵营的子兵种分类详情
local SoldierChildType = {
    {1,2},
    {3,4},
    {5,6},
    {7,8},
 }

--taskNum 任务用数量
function SoldierTraningLayer:createLayer(build_id,taskNum)
    
    local buildData = g_PlayerBuildMode.FindBuild_origin_ConfigID(build_id)

    if buildData == nil then
        return
    end
    
    --建筑正在升级当中
    if buildData and buildData.status == g_PlayerBuildMode.m_BuildStatus.levelUpIng then
        return
    end

    self.position = buildData.position

    --获取当前BUFF
    MilitaryCampData:getNumPlusBuff(self.position)    
    return g_sceneManager.addNodeForUI(SoldierTraningLayer:create(build_id,taskNum))
end


function SoldierTraningLayer:ctor(buildId,taskNum)
    
    SoldierTraningLayer.super.ctor(self)
    
    SoldierTypeEnum = MilitaryCampData:getSoldierTypeEnum()

    self.curIdx = 0 --列表选中项
    
    self.taskNum = taskNum --新手引导

    self.soldierType = MilitaryCampData:getSolierTypeByBuildId(buildId)
    
    --获取当前解锁最新的士兵
    self.newSoldierId = MilitaryCampData:getNewLockSoldierID(self.soldierType)
    
    --士兵已经显示过NEW了 将存档中的ID设置为0
    if self.newSoldierId ~= 0 and self.newSoldierId ~= nil then
        MilitaryCampData:setNewLockSoldierID( self.soldierType )
    end

    --初始化BUILDBUFF
    --MilitaryCampData:initBuildBuff(buildId)
end 

function SoldierTraningLayer:onEnter() 

    local layer = g_gameTools.LoadCocosUI("shibingxunlian.csb",5)
    g_resourcesInterface.installResources(layer)

    if layer then
        self:addChild(layer)
        local root = layer:getChildByName("scale_node")
        self:initBinding(root)
        local function showUI()
            self:setBtnSelected(self.soldierType)
            self:updateNormalInfo(self.taskNum)
            self:hideAllTabBtn()
            self:initWidget()
            root:getChildByName("showPanel"):setVisible(true)
            --新手引导
            g_guideManager.execute()
        end
        
        root:getChildByName("showPanel"):setVisible(false)
        if self.soldierType == SoldierTypeEnum.Trap then
            g_busyTip.show_1()
            g_TrapMode.RequestSycData( function (result,data)
                g_busyTip.hide_1()
                if result == true then
                    showUI()
                else
                    self:close()
                end
            end)
        else
            showUI()
        end
    end
    
end 

function SoldierTraningLayer:onExit() 
    print("SoldierTraningLayer:onExit") 
    if self.buildTimer then 
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
    end 
    -- self:stopAllActions()
end 

function SoldierTraningLayer:initBinding(scaleNode)
    local btnClose = scaleNode:getChildByName("Button_xhao")
    local btnInfantry = scaleNode:getChildByName("Button_1")
    local lbInfantry = btnInfantry:getChildByName("Text_1")
    local btnCavalry = scaleNode:getChildByName("Button_2")
    local lbCavalry = btnCavalry:getChildByName("Text_1")
    local btnArcher = scaleNode:getChildByName("Button_3")
    local lbArcher = btnArcher:getChildByName("Text_1")
    local btnCatapults = scaleNode:getChildByName("Button_4")
    local lbCatapults = btnCatapults:getChildByName("Text_1")
    local btnTrap = scaleNode:getChildByName("Button_5") 
    local lbTrap = btnTrap:getChildByName("Text_1") 
    local buildTitle = scaleNode:getChildByName("Text_biaoti") 
    buildTitle:setString(MilitaryCampData:getBuildName(self.soldierType) )

    local showPanel = scaleNode:getChildByName("showPanel")
    local Panel_yiyongyou = showPanel:getChildByName("Panel_yiyongyou")
    self.imgSoldier = showPanel:getChildByName("Image_12") 
    local lbPreOwnNum = Panel_yiyongyou:getChildByName("Text_1") 
    self.lbOwnNum = Panel_yiyongyou:getChildByName("Text_2")
    
    local lbPreOutput = Panel_yiyongyou:getChildByName("Text_3")  
    self.lbOutput = Panel_yiyongyou:getChildByName("Text_4")  
    
    --士兵升级按钮
    self.soldierUpBtn = Panel_yiyongyou:getChildByName("Button_6")
    self.soldierUpBtn:getChildByName("Text_5"):setString(g_tr("SoldierLvUp"))
    
    self.pageView = showPanel:getChildByName("Panel_1"):getChildByName("PageView")
    self.pageView:setDirection(ccui.PageViewDirection.VERTICAL)
    self.lbPreTitle = showPanel:getChildByName("Text_total")
    self.lbTitle = showPanel:getChildByName("Text_total_1")

    self.nodeNormal = showPanel:getChildByName("Panel_4")
    --设置多语言文字中 使用道具还是道具时的抬头
    --useDec:setString(g_tr("CampNeedUse"))

    self.unLockPanel = showPanel:getChildByName("PanelNoOpen")

    local lbMat1 = self.nodeNormal:getChildByName("Panel_ziyuan01"):getChildByName("Text_4_0") 
    local lbMat2 = self.nodeNormal:getChildByName("Panel_ziyuan02"):getChildByName("Text_4_0") 
    local lbMat3 = self.nodeNormal:getChildByName("Panel_ziyuan03"):getChildByName("Text_4_0")  
    local lbMat4 = self.nodeNormal:getChildByName("Panel_ziyuan04"):getChildByName("Text_4_0")  
    local lbMat5 = self.nodeNormal:getChildByName("Panel_ziyuan05"):getChildByName("Text_4_0")

    local picMat1 = self.nodeNormal:getChildByName("Panel_ziyuan01"):getChildByName("Image_3") 
    local picMat2 = self.nodeNormal:getChildByName("Panel_ziyuan02"):getChildByName("Image_3") 
    local picMat3 = self.nodeNormal:getChildByName("Panel_ziyuan03"):getChildByName("Image_3")  
    local picMat4 = self.nodeNormal:getChildByName("Panel_ziyuan04"):getChildByName("Image_3")  
    local picMat5 = self.nodeNormal:getChildByName("Panel_ziyuan05"):getChildByName("Image_3")

    local Panel_huangdongtiao = self.nodeNormal:getChildByName("Panel_huangdongtiao")
    self.lbDec = Panel_huangdongtiao:getChildByName("Text_10_1")
    self.lbInc = Panel_huangdongtiao:getChildByName("Text_10_1_0") 
    self.slider = Panel_huangdongtiao:getChildByName("Slider_1")
    self.sliderBg = Panel_huangdongtiao:getChildByName("SliderTouchPanel")
    local editmode = Panel_huangdongtiao:getChildByName("TextField_1")
    self.lbInputNum = g_gameTools.convertTextFieldToEditBox(editmode)
    self.lbInputNum:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)


    local btnBuyFinish = self.nodeNormal:getChildByName("Button_9_0") 
    local lbBuyFinish = btnBuyFinish:getChildByName("Text_1_0") 
    local btnBuild = self.nodeNormal:getChildByName("Button_9_01")
    
    --新手引导
    g_guideManager.registComponent(9999995,btnBuild)

    local lbBuild = btnBuild:getChildByName("Text_1_0")   
    
    self.lbMoneyCost = self.nodeNormal:getChildByName("Panel_dixiaxinxi"):getChildByName("Text_11")
    local gemCostIcon = self.nodeNormal:getChildByName("Panel_dixiaxinxi"):getChildByName("Image_14") 
    local count , icon = g_gameTools.getPlayerCurrencyCount( g_Consts.AllCurrencyType.Gem )
    gemCostIcon:loadTexture(icon)

    self.lbTimeLeft = self.nodeNormal:getChildByName("Panel_dixiaxinxi_0"):getChildByName("Text_11")
    lbPreOutput:setString(g_tr("canstudy"))

    --正在训练节点
    self.nodeTraning = showPanel:getChildByName("Training")  
    self.loadingBar = self.nodeTraning:getChildByName("Panel_01"):getChildByName("LoadingBar_1") 
    self.lbLeftTime = self.nodeTraning:getChildByName("Panel_01"):getChildByName("Text_11") 
    self.btnAccelerate = self.nodeTraning:getChildByName("Button_jiasu") 
    local lbAccelerate = self.btnAccelerate:getChildByName("Text_01") 
    self.lbAccelerateCost = self.btnAccelerate:getChildByName("Text_11")
    self.btnFetch = self.nodeTraning:getChildByName("Button_lingqu")
    local lbFetch = self.btnFetch:getChildByName("Text_01")
    self.resOutDesc_btn = showPanel:getChildByName("Image_46_0")
    --士兵详情按钮
    self.soldierInfo_btn = showPanel:getChildByName("Image_46")
    
    lbInfantry:setString(g_tr("infantry"))
    lbCavalry:setString(g_tr("cavalry"))
    lbArcher:setString(g_tr("archer"))
    lbCatapults:setString(g_tr("catapults"))
    lbTrap:setString(g_tr("trapNum"))
    lbBuyFinish:setString(g_tr("completeImmediately"))
    lbBuild:setString(g_tr("camp_study"))
    lbPreOwnNum:setString(g_tr("alreadyOwn")) 
    lbAccelerate:setString(g_tr("accelerate")) 
    lbFetch:setString(g_tr("fetch"))



    --陷阱隐藏产量显示
    if self.soldierType == SoldierTypeEnum.Trap then
        lbPreOutput:setVisible(false)
        self.lbOutput:setVisible(false)
        lbBuild:setString(g_tr("camp_build"))
        self.resOutDesc_btn:setVisible(false)
        self.soldierUpBtn:setVisible(false)
    end
    --g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
    self:regBtnCallback(btnClose, function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
        self:close()
    end)
    self:regBtnCallback(btnInfantry, handler(self, self.onInfantry))
    self:regBtnCallback(btnCavalry, handler(self, self.onCavalry))
    self:regBtnCallback(btnArcher, handler(self, self.onArcher))
    self:regBtnCallback(btnCatapults, handler(self, self.onCatapults))
    self:regBtnCallback(btnTrap, handler(self, self.onTrap))
    self:regBtnCallback(btnBuyFinish, handler(self, self.onBuyFinish))
    self:regBtnCallback(btnBuild, handler(self, self.onStartBuild))
    self:regBtnCallback(self.btnAccelerate, handler(self, self.onAccelerate))
    self:regBtnCallback(self.btnFetch, handler(self, self.notifyToFetch))
    self:regBtnCallback(self.resOutDesc_btn,handler(self, self.resOutDescShow))
    self:regBtnCallback(self.soldierInfo_btn,handler(self, self.soldierInfoShow))
    self:regBtnCallback(self.soldierUpBtn,handler(self, self.soldierUpgrade))

    self.campBtnArray = {btnInfantry, btnCavalry, btnArcher, btnCatapults, btnTrap}
    self.lbMatArray = { 
                        { pic = picMat1,num = lbMat1 }, 
                        { pic = picMat2,num = lbMat2 }, 
                        { pic = picMat3,num = lbMat3 }, 
                        { pic = picMat4,num = lbMat4 }, 
                        { pic = picMat5,num = lbMat5 },
                      }

    self.jian_btn = Panel_huangdongtiao:getChildByName("Text_10_1")
    self.jia_btn = Panel_huangdongtiao:getChildByName("Text_10_1_0")
    

    self:regBtnCallback(self.jian_btn, handler(self, self.TouchLess))
    self:regBtnCallback(self.jia_btn, handler(self, self.TouchPlus))

    self.name_lb = showPanel:getChildByName("Text_32")
    self.descName_lb = showPanel:getChildByName("Text_32_0")
    
end 

--减
function SoldierTraningLayer:TouchLess()
    print("TouchLess")
    
    --[[if self.canBuildMax == nil then
        return
    end]]

    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local count = tonumber(self.lbInputNum:getString()) or 0
    count = count - 1
    if count <= 0 then
        count = 0
    end
    self:updateNormalInfo(count)
end

--加
function SoldierTraningLayer:TouchPlus()
    print("TouchPlus")

    --[[if self.canBuildMax == nil then
        return
    end]]


    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local count = tonumber(self.lbInputNum:getString()) or 0
    count = count + 1
    if count >= self.canBuildMax then
        count = self.canBuildMax
    end
    self:updateNormalInfo(count)
end


function SoldierTraningLayer:initWidget()
    
    local isShowTips = true
    local mode = nil
    
    local _ = nil
    local canBuild = nil
     
    
    local function sliderEvent(sender, eventType)
        print("eventType",eventType)
        if eventType == 1 then
            mode = self.dataArray[self.curIdx]
            _,canBuild = MilitaryCampData:getBuildCountMax(mode)
        end
        
        if eventType == ccui.SliderEventType.percentChanged then
            
            --[[if self.canBuildMax == nil then
                return
            end]]


            if isShowTips then
                print("主公，已经没有可训练士兵数量，请提升粮食产量来提高训练士兵数量上限")
                isShowTips = false
            end

            local count = math.floor(self.canBuildMax*sender:getPercent()/100)
            self:updateNormalInfo(count)
        end

        if eventType == ccui.SliderEventType.slideBallUp then
            isShowTips = true
        end

    end 
    --文本框检测
    local function textFieldEvent(eventType)
        if eventType == "customEnd" then
            --[[if self.canBuildMax == nil then
                return
            end]]


            local editnum = tonumber( self.lbInputNum:getString() ) or 0
            if editnum >= self.canBuildMax then
                editnum = self.canBuildMax
            end
            if editnum < 0 then
                editnum = 0
            end
            self.lbInputNum:setString( tostring(editnum) )
            self:updateNormalInfo(editnum) 
        end
    end


    --[[local function sliderBgEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local endPos = sender:convertToNodeSpace( sender:getTouchEndPosition() )
            local jump2x = math.floor( 100 * endPos.x / sender:getContentSize().width )
            self.slider:setPercent( jump2x )
            local count = math.floor(self.canBuildMax * jump2x / 100)
            self:updateNormalInfo(count)
        end
    end]]

    self.slider:addEventListener(sliderEvent)
    self.lbInputNum:setPlaceHolder("")
    --self.lbInputNum:setMaxLengthEnabled(true)
    self.lbInputNum:setMaxLength(5)
    self.lbInputNum:registerScriptEditBoxHandler(textFieldEvent)
    --self.sliderBg:addTouchEventListener(sliderBgEvent)

end 

function SoldierTraningLayer:setBtnSelected(soldierType)

    self.soldierType = soldierType

    --高亮兵种按钮
    for i=1, #self.campBtnArray do 
        self.campBtnArray[i]:setHighlighted(i==soldierType)
    end 
    
    --显示兵种列表
    self.dataArray, self._maxValidIdx = MilitaryCampData:getDataByType(soldierType)
    self.curIdx = self._maxValidIdx

    --根据建筑的工作状态显示不同信息
    local campBuildInfo = MilitaryCampData:getCampBuildInfoByType(soldierType)
    --dump(campBuildInfo, "campBuildInfo")
    
    if campBuildInfo.status == g_PlayerBuildMode.m_BuildStatus.default then --未训练状态
        
        --默认选中当前可以训练的最高等级士兵并且显示
        self.curIdx = self._maxValidIdx
        self:showSoldierList(self.dataArray)

        --self:updateNormalInfo()

    elseif campBuildInfo.status == g_PlayerBuildMode.m_BuildStatus.working then --可训练状态
        --获取当前选中训练士兵并且显示
        for key, var in ipairs(self.dataArray) do
            if tonumber(var:getId()) == tonumber(campBuildInfo.work_content.soldierId) then
                self.curIdx = key
                break
            end
        end

        self:showSoldierList(self.dataArray) 
        self:updateBuildingInfo(campBuildInfo)
    end

end

function SoldierTraningLayer:onInfantry()
    print("onInfantry")
    self:setBtnSelected(SoldierTypeEnum.Infantry)
end 

function SoldierTraningLayer:onCavalry()
    print("onCavalry")
    self:setBtnSelected(SoldierTypeEnum.Cavalry)
end 

function SoldierTraningLayer:onArcher()
    print("onArcher")
    self:setBtnSelected(SoldierTypeEnum.Archer)
end 

function SoldierTraningLayer:onCatapults()
    print("onCatapults")
    self:setBtnSelected(SoldierTypeEnum.Catapults)
end 

function SoldierTraningLayer:onTrap()
    print("onTrap")
    self:setBtnSelected(SoldierTypeEnum.Trap)
end 

--不消耗材料和时间,直接使用元宝完成士兵建造
function SoldierTraningLayer:onBuyFinish()
    --g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local campBuild = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
    if nil == campBuild then 
        g_airBox.show(g_tr("pls_build_%{name}_first", {name=MilitaryCampData:getBuildName(self.soldierType)}))
        return
    end 

    if campBuild.status ~= g_PlayerBuildMode.m_BuildStatus.default then 
        print("error build status !!")
        return 
    end 
    
    if self.buildCount <= 0 then 
        --g_airBox.show(g_tr("plsSelectBuildCount"))
        local farmOutput = MilitaryCampData:getLeftFarmOutput()
        if farmOutput <= 0 and self.soldierType ~= SoldierTypeEnum.Trap then 
            g_airBox.show(g_tr("noEnoughFood"),3)
        else 
            g_airBox.show(g_tr("plsSelectBuildCount"))
        end

        return 
    end 
    
    local mode = self.dataArray[self.curIdx]
    local cost = math.ceil( (mode:getCostGem() * self.buildCount)/10000 )
    local myMoney = g_PlayerMode.getDiamonds()

    --print(" myMoney,cost ",myMoney,cost,self.dataArray[self.curIdx]:getCostGem(),self.buildCount)
    
    if myMoney < cost then
        
        g_airBox.show(g_tr("no_enough_money"),2)
        return 
    end 

    --send msg
    local function buyResult(result, data)
        print("buyResult:", result)
        if result then
            local buildInfo = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
            --g_airBox.show(g_tr("CampComplete"),1)
            self:updateNormalInfo()
            if self.soldierType ~= SoldierTypeEnum.Trap then
                local homeMapArmyShow = require("game.maplayer.homeMapArmyShow")
                homeMapArmyShow.pushArmy( self.soldierType )
                g_airBox.show(g_tr("SoldierCom"),1)
            else
                g_airBox.show(g_tr("TrapCom"),1)
            end

            local getSoundID = MilitaryCampData:getCompleteSoundType(self.soldierType)
            g_musicManager.playEffect(g_data.sounds[getSoundID].sounds_path,false)

        end 
    end 
    
    --[[g_msgBox.show( g_tr("QuickBuildNeedDiamonds",{num = cost}),nil,2,
        function ( eventtype )
            --确定
            if eventtype == 0 then 
                local id = self.dataArray[self.curIdx]:getId() 
                if self.soldierType == SoldierTypeEnum.Trap then 
                    g_sgHttp.postData("trap/produce", {trapId=id, position=campBuild.position, num=self.buildCount, useGem=1}, buyResult)
                else 
                    g_sgHttp.postData("Soldier/recruit", {soldierId=id, position=campBuild.position, num=self.buildCount,useGem=1}, buyResult)
                end
            end
        end , 
        1
    )]]

    g_msgBox.showConsume(cost, g_tr("QuickBuildNeedDiamonds"), nil, g_tr("completeImmediately"), function ()
        local id = mode:getId() 
        if self.soldierType == SoldierTypeEnum.Trap then 
            g_sgHttp.postData("trap/produce", {trapId=id, position=campBuild.position, num=self.buildCount, useGem=1}, buyResult)
        else 
            g_sgHttp.postData("Soldier/recruit", {soldierId=id, position=campBuild.position, num=self.buildCount,useGem=1}, buyResult)
        end
    end)



end 

--快速完成
function SoldierTraningLayer:quickBuild(buildData,url,callback)
    

    --dump(buildData)
    --dump( g_data.soldier[buildData.work_content.soldierId] )
    
    local sDataConfig = g_data.soldier[buildData.work_content.soldierId]

    local finishTime = buildData.work_finish_time
    local leftTime = buildData.work_finish_time - g_clock.getCurServerTime()
    local cost = math.ceil( math.pow( leftTime,0.911) * 0.085)
    local myMoney = g_PlayerMode.getDiamonds()

    if leftTime <= 0 then
        print("build complete")
        return
    end
    
    local function doSpeedUpHandler()

        if myMoney < cost then
            g_airBox.show(g_tr("no_enough_money"),3)
            return
        end

        local function accelerateResult(result, data)
            if result == true then
                if callback then
                    callback()
                end
            end
        end

         g_sgHttp.postData(url, { position = buildData.position , type = 1 }, accelerateResult)
         
    end
    g_msgBox.showSpeedUp(finishTime, g_tr("speedUpTrainingCD"), nil, nil, doSpeedUpHandler)
end


--建造工程中使用元宝加速完成
function SoldierTraningLayer:onAccelerate()
    print("onAccelerate")
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local campBuild = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
    if campBuild.status ~= g_PlayerBuildMode.m_BuildStatus.working then 
        print("now is not building...")
        return
    end
    
    local function updatedata()
        
        if self.buildTimer then       
            self:unschedule(self.buildTimer)
            self.buildTimer = nil 
        end 
        self.loadingBar:setPercent(0)
        self.lbLeftTime:setString("00:00:00")

        --显示领取按钮
        self.btnAccelerate:setVisible(false)
        self.btnFetch:setVisible(true)
    end


    local url = (self.soldierType == SoldierTypeEnum.Trap) and "trap/accelerateProduce" or "Soldier/accelerateRecruit"
    self:quickBuild(campBuild,url,updatedata)

end 

--开始建造
function SoldierTraningLayer:onStartBuild() 
    print("onStartBuild, count=", self.buildCount)
    --g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local campBuild = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
    if nil == campBuild then 
        g_airBox.show(g_tr("pls_build_%{name}_first", {name=MilitaryCampData:getBuildName(self.soldierType)}))
        return
    end 


    if campBuild.status ~= g_PlayerBuildMode.m_BuildStatus.default then 
        print("wrong build status !") 
        return 
    end 

    if self.buildCount <= 0 then 
        local farmOutput = MilitaryCampData:getLeftFarmOutput()
        if farmOutput <= 0 and self.soldierType ~= SoldierTypeEnum.Trap then 
            g_airBox.show(g_tr("noEnoughFood"),3)
        else 
            g_airBox.show(g_tr("plsSelectBuildCount"))
        end
        return 
    end

    --资源不足 跳转到购买界面
    for currencyType, var in pairs(self.enoughMat) do
        --print("self.enoughMat",currencyType,var,g_Consts.AllCurrencyType.Food)
        if not var then
            --print("hahahahahahahaha")
            require("game.uilayer.shop.UseResourceView").show(currencyType,function ()
                self:updateNormalInfo( self.buildCount )
            end )
            return
        end
    end
    
    --[[if not self.enoughMat then 
        --g_airBox.show(g_tr("no_enough_material"),3)

        local useResource = require("game.uilayer.shop.UseResourceView").new(g_Consts.AllCurrencyType.Food)
        g_sceneManager.addNodeForUI(useResource)

        return 
    end ]]


    local mode = self.dataArray[self.curIdx]
    if mode then
        if self.soldierType == SoldierTypeEnum.Trap then
            local curNum, maxNum,upNum = MilitaryCampData:getCurMaxCount(mode)
            if (maxNum +  self.buildCount) > upNum then
                return
            end
        end

        
        local function buildResult(result, data)
            print("buildResult:", result)
            if result then
                if self.soldierType == SoldierTypeEnum.Trap then
                    local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(self.position,g_Consts.UseItemType.Trap)
				    g_sceneManager.addNodeForUI(view)
                else
                    local view = require("game.uilayer.publicMode.GeneralPropsLayer"):create(self.position,g_Consts.UseItemType.Soldier)
				    g_sceneManager.addNodeForUI(view)
                end
                --g_musicManager.playEffect(g_data.sounds[5000039].sounds_path,true)
                local soundId = MilitaryCampData:getSoundType(self.soldierType)
                g_musicManager.playEffect(g_data.sounds[soundId].sounds_path,false)
                
                local buildInfo = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
                self:updateBuildingInfo(buildInfo)
                self:close()
                g_guideManager.execute()
            end 
        end

        local id = mode:getId()
        if self.soldierType == SoldierTypeEnum.Trap then 
            g_sgHttp.postData("trap/produce",{trapId = id, position = campBuild.position, num = self.buildCount, useGem=0}, buildResult)
        else
            --内附新手引导
            g_sgHttp.postData("Soldier/recruit",{soldierId = id, position = campBuild.position, num = self.buildCount,steps = g_guideManager.getToSaveStepId()}, buildResult)
        end
    else
        print("no found the mode")    
    end

    --send msg 
    
end 


--士兵/陷阱列表
function SoldierTraningLayer:showSoldierList(dataArray)
    --选择兵种进行跳转与界面信息更新
    local function onSelectItem(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then

            --print("self.curIdx,sender.index",self.curIdx,sender.index)

            --是否解锁

            if self.curIdx == sender.index then
                return
            end

            
            self.curIdx = sender.index
            self.pageView:scrollToPage(self.curIdx - 1)
            
            local campBuildInfo = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
            if campBuildInfo.status == g_PlayerBuildMode.m_BuildStatus.working then --可训练状态
                self.nodeNormal:setVisible(false)
                self.unLockPanel:setVisible(false)
                self.nodeTraning:setVisible(true)
            end
        end
    end

    local soldierItem = cc.CSLoader:createNode("huandongzhans.csb")

    for i, var in ipairs(dataArray) do
        local layout = ccui.Layout:create()
        layout:setContentSize(self.pageView:getContentSize())
        local item = soldierItem:clone()
        item:setName("item")
        item:setAnchorPoint(cc.p(0.5,0.5))
        item:setPosition(cc.p( layout:getContentSize().width/3,layout:getContentSize().height/2 ))
        layout:addChild(item)
        self.pageView:addPage(layout)

        local scale_node = item:getChildByName("scale_node") 
        local imgCircle = scale_node:getChildByName("Image_1") 
        local imgSoldier = scale_node:getChildByName("Image_3") 
        local imgNameBg = scale_node:getChildByName("Image_2")
        local lbName = scale_node:getChildByName("Text_1") 

        imgSoldier:loadTexture( g_resManager.getResPath(dataArray[i]:getIconId()) )

        local newImg = scale_node:getChildByName("Image_2")
        newImg:setVisible(false)
        if tonumber(self.newSoldierId) == tonumber(var:getId()) then
            newImg:setVisible(true)
        end
        
        --是否拥有否则置灰
        if i > self._maxValidIdx then
            imgCircle:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
            imgSoldier:getVirtualRenderer():setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(g_shaders.shaderMode.shader_gray))
            lbName:setTextColor(cc.c4b(150,150,150,255))
        end

        lbName:setString(g_tr(dataArray[i]:getName()))
        lbName:setVisible(false)
        --创建等级图片
        if dataArray[i]:getLvIconId() then
            local lvImg = ccui.ImageView:create( g_resManager.getResPath(dataArray[i]:getLvIconId()) )
            lvImg:setPosition(lbName:getPosition())
            lvImg:setAnchorPoint(lbName:getAnchorPoint())
            lbName:getParent():addChild(lvImg)
        end
        
        scale_node:setTouchEnabled(true)
        scale_node.index = i
        scale_node.data = dataArray[i]
        scale_node:addTouchEventListener(onSelectItem)
    end

    --self.pageView:setIsTouchFull(true)
    self.pageView:setIsContinuous(true)
    --self:updateNormalInfo()
    self.pageView:scrollToPage(self.curIdx - 1)
   
    local function pageViewEvent(sender, eventType)
        --print("pageViewEvent",eventType)
        if eventType == ccui.PageViewEventType.turning then
            
            local pageView = sender

            --[[if pageView:getCurPageIndex() == (self.curIdx - 1) then
                return
            end]]

            local nowitem = pageView:getPage( pageView:getCurPageIndex() )
            local item = nowitem:getChildByName("item"):getChildByName("scale_node")
            
            self.curIdx = pageView:getCurPageIndex() + 1
            --初始化显示在这里
            self:updateNormalInfo(self.taskNum)

            local campBuildInfo = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
            if campBuildInfo.status == g_PlayerBuildMode.m_BuildStatus.working then --可训练状态
                self.nodeNormal:setVisible(false)
                self.unLockPanel:setVisible(false)
                self.nodeTraning:setVisible(true)
            end
        end

    end   
    
    self.pageView:addEventListener(pageViewEvent)

    --左箭头按钮切换兵种
    --[[self.left_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local jumpIndex = self.pageView:getCurPageIndex() - 1
            if jumpIndex >= 0 then
                self.pageView:scrollToPage(jumpIndex)
            end
        end
    end)
    --右箭头按钮切换兵种
    self.right_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local jumpIndex = self.pageView:getCurPageIndex() + 1
            if jumpIndex < #self.pageView:getPages() then
                self.pageView:scrollToPage(jumpIndex)
            end
        end
    end)]]


end 

--显示造兵/造陷阱需要的材料等信息, 参数count不传则默认选最大值
function SoldierTraningLayer:updateNormalInfo(count) 
    --print("updateNormalInfo, count=", count)

    self.nodeNormal:setVisible(true)
    self.unLockPanel:setVisible(false)
    self.nodeTraning:setVisible(false)
    
    local mode = self.dataArray[self.curIdx]
    
    if mode then
        
        --创建特效
        local trapType = mode:getTrapType()
        
        --更新参数
        self.canBuildMax,resCanCreateCount = MilitaryCampData:getBuildCountMax(mode)
        local curNum = MilitaryCampData:getCurMaxCount(mode)
        if trapType and self.trapType ~= trapType then
            
            local fxArray =
            {
                {path = "anime/XianJingGunMu/XianJingGunMu.ExportJson", name = "XianJingGunMu"},
                {path = "anime/XianJingHuoJian/XianJingHuoJian.ExportJson", name = "XianJingHuoJian"},
                {path = "anime/XianJingLuoShi/XianJingLuoShi.ExportJson", name = "XianJingLuoShi"} ,
            }

            --清空特效
            if self.fxNode ~= nil and self.fxAni ~= nil then
                self.fxNode:removeFromParent()
                self.fxAni = nil
                self.fxNode = nil
            end
            --重新创建特效
            if self.fxNode == nil and self.fxAni == nil then
                local fx = fxArray[trapType]
                local armature , animation = g_gameTools.LoadCocosAni(fx.path, fx.name)
                self.fxNode = armature
                self.fxAni = animation
                self.imgSoldier:addChild(self.fxNode )
                self.fxNode:setPosition( cc.p(self.imgSoldier:getContentSize().width/2,self.imgSoldier:getContentSize().height/2) )
                self.fxAni:play("Animation1")
            end
            self.trapType = trapType
        end

        
        --print("maxId1 ,maxId2",maxId1 ,maxId2)

        --是否已经解锁
        if self.curIdx > self._maxValidIdx then
            --当前选中的兵种节点
            local nowSel = self.pageView:getPage( self.pageView:getCurPageIndex() )
            local item = nowSel:getChildByName("item"):getChildByName("scale_node")
            self:unLockShow(item)
            --return
        end

        --[[if trapType == nil then
            
        end]]
        
        if self.soldierType == SoldierTypeEnum.Trap then
            self.soldierUpBtn:setVisible( false )
        else
            local upSoldierIsLock = (MilitaryCampData:getUpSoldierIsLock(mode:getId()) and curNum > 0) or false
            self.soldierUpBtn:setVisible( upSoldierIsLock )

            local maxId1 ,maxId2 = self:isCanTraining()
            if mode:getId() ~= maxId1 and mode:getId() ~= maxId2 and self.curIdx <= self._maxValidIdx  then
                local nowSel = self.pageView:getPage( self.pageView:getCurPageIndex() )
                local item = nowSel:getChildByName("item"):getChildByName("scale_node")
                self:unLockShow(item,true)
            end

        end
        
        --更新显示名称
        self.name_lb:setString(g_tr(mode:getName()))
        local introStr = mode:getSoldierIntro()

        if introStr then
            self.descName_lb:setVisible(true)
            self.descName_lb:setString(g_tr(introStr))
        else
            self.descName_lb:setVisible(false)
        end

        --判断资源不足界面并且存放是那种资源不足
        self.enoughMat = {}
        
        --如果当前选择的数量大于上限
        if count and (count > self.canBuildMax) then
            count = self.canBuildMax
        end

        self.buildCount = count or self.canBuildMax --默认选择最大上限
        resCanCreateCount = (resCanCreateCount or 0) - self.buildCount
        --print("canBuildMax",self.canBuildMax)

        --更新士兵数量
        self:updateCurMaxCount(mode)

        --滑动条
        self.slider:setPercent(100*self.buildCount/self.canBuildMax)
        self.lbInputNum:setString(string.format("%d", self.buildCount))  

        --产量
        
        --local farmOutput = MilitaryCampData:getLeftFarmOutput()
        --local leftOutput = math.max(0, math.floor(farmOutput-self.buildCount*mode:getFoodCost()/10000))
        --resCanCreateCount = 0

        self.lbOutput:setString(string.format("%d", resCanCreateCount))
        if resCanCreateCount <= 0 then
            self.lbOutput:setTextColor( cc.c3b(230,30,30) )
        else
            self.lbOutput:setTextColor( cc.c3b(255,255,255) )
        end

        --self.lbOutput:setVisible(false)

        --所需材料
        local matCost = mode:getMatCost()
        local matType, costNum, ownNum, color, str, pic
        local showNeedResVec = {}
        for i = 1, #self.lbMatArray do 
            ownNum = 0 
            costNum = 0 
            if matCost[i] then
                matType = matCost[i][1] 
                costNum = matCost[i][2] * self.buildCount
                ownNum,pic = g_gameTools.getPlayerCurrencyCount(matType)

                --print("matType,costNum,ownNum",matType,costNum,ownNum,pic)

                --print("costNum,ownNum",costNum,ownNum)

                if ownNum < costNum then
                    self.enoughMat[matType] = false
                    color = cc.c4b(255,0,0,255)
                else 
                    color = cc.c4b(255,255,255,255)
                end

                if matCost[i][2] > 0 or costNum > 0 then
                    table.insert(showNeedResVec,{matType = matType , matcost = costNum , matpic = pic , matcolor = color })
                end

            end
            
            --str = string.formatnumberlogogram(tonumber( costNum ) or 0)

            --self.lbMatArray[i].num:setString(str)
            --self.lbMatArray[i].num:setTextColor(color)
            --加载图片
            --self.lbMatArray[i].pic:loadTexture( tostring(pic) )

            --if costNum == 0 then
                --self.lbMatArray[i].num:setVisible(false)
                --self.lbMatArray[i].pic:setVisible(false)
            --else
                --self.lbMatArray[i].num:setVisible(true)
                --self.lbMatArray[i].pic:setVisible(true)
            --end
        end 

        table.sort(showNeedResVec,function (a,b)
            return a.matType < b.matType
        end)

        for index, item in ipairs(self.lbMatArray) do
            local resData = showNeedResVec[index]
            if resData then
                item.num:setVisible(true)
                item.pic:setVisible(true)
                local costStr = string.formatnumberlogogram(tonumber( resData.matcost ) or 0)
                item.num:setString( costStr )
                item.num:setTextColor( resData.matcolor )
                item.pic:loadTexture( tostring(resData.matpic) )
            else
                item.num:setVisible(false)
                item.pic:setVisible(false)
            end
        end
        
        
        --需要的建造时间
        local needTime = mode:getTrainTime( self.position ) * self.buildCount
        self.lbTimeLeft:setString(string.format("%02d:%02d:%02d", g_clock.formatTimeHMS( needTime )))

        --立即完成所需元宝数
        --元宝加速价格=int(时间(秒)^0.911*0.085)
        --local needCost = math.ceil( math.pow( needTime,0.911) * 0.085)
        --self.lbMoneyCost:setString( tostring(needCost) )
         self.lbMoneyCost:setString(string.format("%d", math.ceil(mode:getCostGem()*self.buildCount/10000)))

    else 
        self.slider:setPercent(0)
        self.lbInputNum:setString("0")
        self.lbMoneyCost:setString("0")
        self.lbOutput:setString("")
    end 
end 

--显示正在造兵/陷阱信息
function SoldierTraningLayer:updateBuildingInfo(buildInfo) 
    print("updateBuildingInfo",buildInfo.work_content.soldierId)
     --dump(buildInfo)
    if buildInfo.status ~= g_PlayerBuildMode.m_BuildStatus.working then 
        print("wrong build status !!!")
        return 
    end

    self.nodeNormal:setVisible(false)
    self.unLockPanel:setVisible(false)
    self.nodeTraning:setVisible(true)
    
    --更新士兵数量
    local soldier = self.dataArray[self.curIdx]
    self:updateCurMaxCount(soldier)

    --更新建造进度倒计时
    local function updateBuildProgress(buildInfo) 
        local needTime 
        --dump(buildInfo, "buildInfo")
        if self.soldierType == SoldierTypeEnum.Trap then 
            needTime = g_data.trap[buildInfo.work_content.trapId].train_time * buildInfo.work_content.num 
        else 
            needTime = g_data.soldier[buildInfo.work_content.soldierId].train_time * buildInfo.work_content.num 
        end 
        local leftTime = buildInfo.work_finish_time - g_clock.getCurServerTime()
        local preTicks = socket.gettime() --精确到毫秒

        local function updatePercent()
            local curTicks = socket.gettime() 
            leftTime = leftTime - (curTicks - preTicks)
            preTicks = curTicks

            if leftTime <= 0 then 
                leftTime = 0 
                self:unschedule(self.buildTimer)
                self.buildTimer = nil 

                self.btnAccelerate:setVisible(false)
                self.btnFetch:setVisible(true)
            end 
            
            self.lbLeftTime:setString(string.format("%02d:%02d:%02d", g_clock.formatTimeHMS( leftTime ))) 

            local money = math.ceil( math.pow( leftTime,0.911) * 0.085)

            self.loadingBar:setPercent(100*leftTime/needTime)
            self.lbAccelerateCost:setString(string.format("%d", money))
        end 

        if self.buildTimer then       
            self:unschedule(self.buildTimer)
            self.buildTimer = nil 
        end 
    
        if leftTime > 0 then 
            updatePercent()
            self.buildTimer = self:schedule(updatePercent, 0) 
        else 
            self.btnAccelerate:setVisible(false)
            self.btnFetch:setVisible(true)      
        end 
    end 

    if self.buildTimer then       
        self:unschedule(self.buildTimer)
        self.buildTimer = nil 
    end 

    if buildInfo.work_finish_time > 0 and buildInfo.work_finish_time > g_clock.getCurServerTime() then 
        self.btnAccelerate:setVisible(true)
        self.btnFetch:setVisible(false)
        updateBuildProgress(buildInfo)
    else 
        self.loadingBar:setPercent(0)
        self.lbLeftTime:setString("00:00:00")
        self.btnAccelerate:setVisible(false)
        self.btnFetch:setVisible(true)
    end 
end 

--通知服务器建造队列已执行完,请求收兵
function SoldierTraningLayer:notifyToFetch() 
    --g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local function fetchResult(result, data) 
        --print("fetchResult:", result) 
        if (result == true) then
            --播放动画
            if self.soldierType ~= SoldierTypeEnum.Trap then             
                local homeMapArmyShow = require("game.maplayer.homeMapArmyShow")
                homeMapArmyShow.pushArmy( self.soldierType )
                g_airBox.show(g_tr("SoldierCom"),1)
            else
                g_airBox.show(g_tr("TrapCom"),1)
            end

            self:updateNormalInfo()
            local getSoundID = MilitaryCampData:getCompleteSoundType(self.soldierType)
            g_musicManager.playEffect(g_data.sounds[getSoundID].sounds_path,false)
        end 
    end 

    local campBuild = MilitaryCampData:getCampBuildInfoByType(self.soldierType) 
    --print("onBuyFinish: build status=", campBuild.status)
    if campBuild.status ~= g_PlayerBuildMode.m_BuildStatus.working then 
        --print("wrong status:"..campBuild.status..", except: 3")
        return 
    end 

    local url = (self.soldierType == SoldierTypeEnum.Trap) and "trap/finishProduce" or "Soldier/finishRecruit"
    g_sgHttp.postData(url, {position = campBuild.position}, fetchResult)     
end 


function SoldierTraningLayer:updateCurMaxCount(mode)
    --更新士兵数量
    local curNum,maxNum,upNum = MilitaryCampData:getCurMaxCount(mode)
    if mode:getType() == SoldierTypeEnum.Trap then 
        self.lbPreTitle:setString(g_tr("trap"))
        self.lbTitle:setString(string.format(" %d/%d", maxNum, upNum))

        if maxNum > upNum then
            self.lbTitle:setColor(cc.c3b(230,20,20))
        else
            self.lbTitle:setColor(cc.c3b(255,255,255))
        end

    else 
        self.lbPreTitle:setString(g_tr("armyAllNumber"))
        self.lbTitle:setString(string.format("%d", maxNum))
    end 
    self.lbOwnNum:setString(string.format("%d", curNum))
    self.imgSoldier:loadTexture(g_resManager.getResPath(mode:getPortrait()))  
end

--显示未解锁提示
function SoldierTraningLayer:unLockShow(item,isLowLv)
    
    self.nodeNormal:setVisible(false)
    self.unLockPanel:setVisible(true)
    local tx = self.unLockPanel:getChildByName("Text_10_1_0")
    if isLowLv then
        tx:setTextColor( cc.c3b(255,255,255) )
        tx:setString(g_tr("SelLvUpStr"))
        return
    end

    tx:setTextColor( cc.c3b(230,30,30) )
    local needBuildId = item.data:getNeedBuildId()
    local buildName = g_tr(g_data.build[needBuildId].build_name)
    local buildLevel = g_data.build[needBuildId].build_level 
    tx:setString(g_tr("soldierCondition",{name = buildName, lv = buildLevel}))
end


function SoldierTraningLayer:resOutDescShow()
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local SoldierResDescLayer = require("game.uilayer.militaryCamp.SoldierResDescLayer"):create()
    SoldierResDescLayer:addParClose(
        function ()
            self:close()    
        end
    )
    g_sceneManager.addNodeForUI(SoldierResDescLayer)
end

function SoldierTraningLayer:soldierInfoShow()
    --print("soldierInfoShow",self.dataArray[self.curIdx]:getId())
    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
    local mode = self.dataArray[self.curIdx]
    local sid = mode:getId()
    if sid then
        --local item = require("game.uilayer.common.ArmyInfoView").new(sid)
        if mode:getType() == SoldierTypeEnum.Trap then
            --print("sid",sid)
            g_sceneManager.addNodeForUI(require("game.uilayer.militaryCamp.TrapInfoView"):create(sid,function ()
                    self:updateNormalInfo()
                    local buildInfo = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
                    self:updateBuildingInfo(buildInfo)
                end)
            )
        else
            g_sceneManager.addNodeForUI(require("game.uilayer.common.ArmyInfoView"):create(sid,function ()
                    self:updateNormalInfo()
                    local buildInfo = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
                    self:updateBuildingInfo(buildInfo)
                end)
            )
        end
    end
    --ArmyInfoView
    --local item = require("game.uilayer.tun.ArmyInfoView").new()
end

--隐藏所有tab分页按钮
function SoldierTraningLayer:hideAllTabBtn()
    for k, v in pairs(self.campBtnArray) do 
        v:setVisible(false)
    end 
end 

--外部接口，返回训练士兵名称与数量
local function getNameAndNum(info)
    local name = ""
    local num = 0
    if info and info.work_content then
        local sid = info.work_content.soldierId
        local tid = info.work_content.trapId
        local snum = info.work_content.num or 0
        
        if sid then
            name = g_tr( g_data.soldier[ tonumber(sid) ].soldier_name )
        end

        if tid then
            name = g_tr( g_data.trap[ tonumber(tid) ].trap_name )
        end

        if tonumber(snum) > 0 then
            num = tonumber(snum)
        end
    end
    return { name = name,num = num }
end

--步兵
function SoldierTraningLayer.getInfantryInfo()
    local info = MilitaryCampData:getCampBuildInfoByType(1)
    return getNameAndNum(info)
end
--骑兵
function SoldierTraningLayer.getCavalryInfo()
    local info = MilitaryCampData:getCampBuildInfoByType(2)
    return getNameAndNum(info)
end
--弓兵
function SoldierTraningLayer.getArcherInfo()
    local info = MilitaryCampData:getCampBuildInfoByType(3)
    return getNameAndNum(info)
end
--投石车
function SoldierTraningLayer.getCatapultsInfo()
    local info = MilitaryCampData:getCampBuildInfoByType(4)
    return getNameAndNum(info)
end
--陷阱
function SoldierTraningLayer.getTrapInfo()
    local info = MilitaryCampData:getCampBuildInfoByType(99999)
    return getNameAndNum(info)
end

function SoldierTraningLayer:soldierUpgrade()
    local mode = self.dataArray[self.curIdx]
    if mode then
        local sid = mode:getId()
        local SoldierUpgrade = require("game.uilayer.militaryCamp.SoldierUpgrade")
        SoldierUpgrade:createLayer(sid,function ()
            self:updateNormalInfo()
            local buildInfo = MilitaryCampData:getCampBuildInfoByType(self.soldierType)
            self:updateBuildingInfo(buildInfo)
        end)
    end
end


--[[function SoldierTraningLayer:onEnterTransitionFinish()
    if self.taskNum and self.taskNum > 0 then
        self:updateNormalInfo(self.taskNum)
    end
end]]

function SoldierTraningLayer:isCanTraining()
    --print("self.soldierType",self.soldierType)
    local cType = SoldierChildType[self.soldierType]
    local id1 = 0
    local id2 = 0
    for idx, mode in ipairs(self.dataArray) do
        if idx <= self._maxValidIdx then
            print("===========",mode:getArmyType())
            if mode:getArmyType() == cType[1] then
               if mode:getId() > id1 then
                    id1 = mode:getId()
               end
            end

            if mode:getArmyType() == cType[2] then
                if mode:getId() > id2 then
                    id2 = mode:getId()
               end 
            end
        else
            break
        end
    end
    
    return id1,id2

    --dump(self.dataArray)
end



return SoldierTraningLayer 
