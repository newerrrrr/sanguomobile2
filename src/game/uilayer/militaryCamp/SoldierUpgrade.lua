--region SoldierUpgrade.lua
--Author : liuyi
--Date   : 2016/3/28
local SoldierUpgrade = class("SoldierUpgrade", require("game.uilayer.base.BaseLayer"))
--local BuffData = nil

function SoldierUpgrade:createLayer(sid,callBackFun)
    self:clearGlobal()
    g_sceneManager.addNodeForUI(SoldierUpgrade:create(sid,callBackFun))    
end

function SoldierUpgrade:ctor(sid,callBackFun)
    SoldierUpgrade.super.ctor(self)
    self.soldierId = sid
    self._callback = callBackFun
    self:initUI()
end

function SoldierUpgrade:initUI()
    self.layer = self:loadUI("Troop1_main.csb")
    g_resourcesInterface.installResources(self.layer)
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("Button_x")
	self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    --zhcn
    self.root:getChildByName("Text_c2"):setString(g_tr("SoldierUpgrade"))

    self.nowSoldierConfig = g_data.soldier[tonumber(self.soldierId)]
    self.upSoldierConfig = g_data.soldier[tonumber(self.nowSoldierConfig.upgrade_id)]

    local panelList = {}
    table.insert(panelList,{ panel = self.root:getChildByName("Panel_3"),config = self.nowSoldierConfig })
    table.insert(panelList,{ panel = self.root:getChildByName("Panel_4"),config = self.upSoldierConfig })

    for _, var in ipairs(panelList) do
        local panel = var.panel
        local config = var.config
        local showNowImg = panel:getChildByName("Image_b1")
        showNowImg:loadTexture(g_resManager.getResPath(config.img_portrait) )

        local showNowName = panel:getChildByName("Text_m1")
        showNowName:setString(g_tr( config.soldier_name ))

        local showNowLv = panel:getChildByName("Image_suizi1") 
        showNowLv:loadTexture(g_resManager.getResPath(config.img_level))
        
        panel:getChildByName("Text_1"):setString(g_tr("armyattack"))
        panel:getChildByName("Text_2"):setString(g_tr("armydefense"))
        panel:getChildByName("Text_3"):setString(g_tr("armylife"))

        panel:getChildByName("Text_1_0"):setString( config.attack .. "" )
        panel:getChildByName("Text_2_0"):setString( config.defense .. "" )
        panel:getChildByName("Text_3_0"):setString( config.life .. "" )
    end

    --消耗资源
    local costResConfig = clone(self.nowSoldierConfig.upgrade_cost)

    --dump(costResConfig)
    --[[
    Panel_xinx01
    Panel_xinx02
    Panel_xinx02
    Panel_xinx01
    Panel_xinx01
    ]]

    local matArray = {}
    local index = 1
    local matEnoughType = nil

    while index do
        local node = self.root:getChildByName( string.format("Panel_xinx0%d",index) )
        if node then
            table.insert( matArray ,node)
            index = index + 1
        else
            break
        end
    end
    

    local function updateMat(count)
        matEnoughType = nil
        count = count or 0
        local isEnough = false
        for i, panel in ipairs(matArray) do
            local cfg = costResConfig[i]
            if cfg then
                local matType = cfg[1]
                local matNum = cfg[2]
                local ownNum,pic = g_gameTools.getPlayerCurrencyCount(matType)


                panel:getChildByName("Image_36"):loadTexture(pic)
                local NumTx = panel:getChildByName("Text_1")
                local matCount = matNum * count
                
                print("matNum,count,matCount",matNum,count,matCount)

                NumTx:setString( tostring( matCount  ) )
                if ownNum >= matCount then
                    NumTx:setTextColor( cc.c3b( 255,255,255 ) )
                else
                    matEnoughType = matType
                    NumTx:setTextColor( cc.c3b( 230,50,50 ) )
                end
            end
        end
    end
    
    local inputMode = self.root:getChildByName("TextField_1")
    self.input = g_gameTools.convertTextFieldToEditBox(inputMode)
    self.slider = self.root:getChildByName("Slider_1")

    local canChangeNum,isFoodOutputEnoughMat = self:getFoodOutput()
    print("isFoodOutputEnoughMat",isFoodOutputEnoughMat)

    self.num = canChangeNum
    local function textFieldEvent(eventType)
        if eventType == "customEnd" then
            --print("string", self.input:getString())
            local cNum = tonumber(self.input:getString()) or 1
            cNum = cNum <= canChangeNum and cNum or canChangeNum
            cNum = (cNum <= 0 and canChangeNum > 0) and 1 or cNum

            if cNum then
                self.num = cNum
                self.input:setString( tostring(cNum) )
                self.slider:setPercent( cNum / canChangeNum * 100)
                updateMat(cNum)
            end
        end
    end

    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            --self.slider:setPercent( 100 * self.buildCount / self.canBuildMax )
            local cNum = math.floor(canChangeNum * self.slider:getPercent() / 100)
            cNum = cNum > 0 and cNum or 1
            self.num = cNum
            self.input:setString( tostring( cNum) )
            updateMat(cNum)
        end
    end
    
    self.input:setString( tostring(self.num) )
    updateMat(self.num)
    self.input:registerScriptEditBoxHandler(textFieldEvent)
    if canChangeNum > 0 then
        self.slider:addEventListener(sliderEvent)
        self.slider:setPercent(100)
    else
        self.slider:setTouchEnabled(false)
        self.slider:setPercent(0)
    end
    

    local lvUpBtn = self.root:getChildByName("Button_1")
    lvUpBtn:setEnabled(true)
    lvUpBtn:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --print("cNumcNumcNumcNum",self.num)
            
            if self.num <= 0 then
                g_airBox.show(g_tr("SoldierLvUpNoNum"),2)
                return
            end

            if matEnoughType ~= nil then
                require("game.uilayer.shop.UseResourceView").show(matEnoughType,function ()
                    updateMat(self.num)
                end )
                return
            end 

            local function callback(result , data)
                if true == result then
                    if self._callback then
                        self._callback()
                    end

                    g_airBox.show(g_tr("SoldierLvUpCom"),1)
                    self:close()
                end
            end

            g_sgHttp.postData("soldier/lvUpSoldier", { soldierId = self.soldierId,num = self.num }, callback)

        end
    end )
    
    local lvUpTx = self.root:getChildByName("Text_16")
    lvUpTx:setString(g_tr("SoldierLvPromptlyUp"))
    if isFoodOutputEnoughMat then
        lvUpTx:setString(g_tr("FoodOututNotEnough"))
        lvUpBtn:setEnabled(false)
        lvUpBtn:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ))
    end
    
    local LessBtn = self.root:getChildByName("Image_6")
    LessBtn:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then

            local cNum = tonumber(self.input:getString()) or 0
            cNum = cNum - 1
            
            if canChangeNum > 0 then
                if cNum <= 1 then
                    cNum = 1
                end
            else
                if cNum <= 0 then
                    cNum = 0
                end
            end

            self.input:setString( tostring( cNum) )
            self.slider:setPercent( cNum / canChangeNum * 100)
            self.num = cNum
            updateMat(cNum)
            --print("Less",canChangeNum)
            
        end
    end )

    local PlusBtn = self.root:getChildByName("Image_6_0")
    PlusBtn:addTouchEventListener( function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("Plus",canChangeNum)
            local cNum = tonumber(self.input:getString()) or 0
            cNum = cNum + 1
            if cNum >= canChangeNum then
                cNum = canChangeNum
            end

            self.input:setString( tostring( cNum) )
            self.slider:setPercent( cNum / canChangeNum * 100)
            self.num = cNum
            updateMat(cNum)

        end
    end )

end

--有使用士兵训练减少粮食消耗的buff
function SoldierUpgrade:getFoodOutput()
    
    local food_out_debuff,food_out_debuffType = g_BuffMode.getFinalBuffValueByBuffKeyName("food_out_debuff")
    local foodOutDebuff = (food_out_debuffType == 1 and food_out_debuff / 10000 or food_out_debuff)
    --( self.BuffData.food_out_debuff and self.BuffData.food_out_debuff.v or 0 ) / 10000

    local output = require("game.uilayer.buildupgrade.BuildingUIHelper").getResourceBuildOutPut(g_PlayerBuildMode.m_BuildOriginType.food,false)
    --当前所有士兵消耗的粮食，却掉当前士兵的消耗，计算这个粮食消耗数量可以训练升级兵种的数量
    local consume = 0 
    local soldierNum = 0
    local data = g_SoldierMode:GetData() 
    for k, v in pairs(data) do
        if v.soldier_id and tonumber(v.soldier_id) ~= 0 then
            local configCost = ( g_data.soldier[v.soldier_id].consumption/10000 )
            local foodCost = configCost - configCost * foodOutDebuff
            consume = consume + v.num * foodCost
            if v.soldier_id == self.soldierId then
                soldierNum = v.num
            end
        end
    end

    --当前军团里士兵的
    local armyData = g_ArmyUnitMode.GetCurentData()
    for k, v in pairs(armyData) do
        if v.soldier_id and tonumber(v.soldier_id) ~= 0 then
            local configCost = ( g_data.soldier[v.soldier_id].consumption/10000 )
            local foodCost = configCost - configCost * foodOutDebuff
            consume = consume + v.soldier_num * foodCost
        end
    end


    local farmOutput = math.max(0, output - consume )

    --print("nowSoldierConfig,upSoldierConfig",self.nowSoldierConfig.consumption,self.upSoldierConfig.consumption)

    local nowConsume = (self.nowSoldierConfig.consumption/10000) - (self.nowSoldierConfig.consumption/10000) * foodOutDebuff
    local perConsume = (self.upSoldierConfig.consumption/10000) - (self.upSoldierConfig.consumption/10000) * foodOutDebuff

    --print("nowConsume,perConsume",nowConsume,perConsume)

    --print("farmOutput,perConsume,nowConsume",farmOutput,perConsume,nowConsume)

    local canChangeNum = 0
    --local isNotEnough = false 

    print("farmOutput,perConsume",farmOutput,perConsume,nowConsume)

    if perConsume <= nowConsume then
        canChangeNum =  math.min( math.floor(farmOutput/perConsume),soldierNum)
    else
        canChangeNum = math.floor( farmOutput / (perConsume - nowConsume) )
    end

    local isNotEnough = canChangeNum <= 0 --是否粮产不足 默认为不是

    --print("farmOutput",farmOutput,perConsume,nowConsume,perConsume - nowConsume)

    return math.min(soldierNum,canChangeNum),isNotEnough

end

function SoldierUpgrade:setExitCallBack(fun, tab)
    self.exitCall = fun
    self.curTab = tab
end

function SoldierUpgrade:onEnter()

end

function SoldierUpgrade:onExit()
    if self.exitCall then
        self.exitCall(self.curTab)
    end
    self:clearGlobal()
end

function SoldierUpgrade:clearGlobal()
    self.soldierId = nil
    self._callback = nil
    self.exitCall = nil
end

return SoldierUpgrade


