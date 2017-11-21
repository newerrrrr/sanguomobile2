local QuickPropsLayer = class("QuickPropsLayer", require("game.uilayer.base.BaseLayer"))

--测试加速时间

--isPD 是否要判断道具是空
function QuickPropsLayer:ctor(pos,isPD)
    QuickPropsLayer.super.ctor(self)
    self.buildPos = pos
    self.isPD = isPD
    self.filterData = {}
    self.items = {}
    self.send = nil
end

function QuickPropsLayer:InitUI()
    self.layer = self:loadUI("PropsAccelerated_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("Button_xhao")
    self:regBtnCallback(closeBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    self.bar = self.root:getChildByName("LoadingBar_1")
    self.barTxMode = self.root:getChildByName("Text_8")
    
    self.barTx = g_gameTools.createRichText(self.barTxMode,nil)
    local nameTx = self.root:getChildByName("Text_1_1")
    nameTx:setString(g_tr(self.buildConfig.build_name))

    local lvTx = self.root:getChildByName("Panel_2"):getChildByName("Text_1_0")
    lvTx:setString(string.format("lv.%d",self.buildConfig.build_level))

    local lvTitleTx = self.root:getChildByName("Panel_2"):getChildByName("Text_1")
    lvTitleTx:setString(g_tr("level")) 

    local iconP = self.root:getChildByName("Image_9")
    local node = g_resManager.getRes(self.buildConfig.img)
    node:setPosition( cc.p(iconP:getPositionX(),iconP:getPositionY()))
    node:setScale(0.7)
    self.root:addChild(node)

    local backBtn = self.root:getChildByName("Button_a1")
    backBtn:getChildByName("Text_26_0"):setString(g_tr("noUseStr"))
    self:regBtnCallback(backBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    local useBtn = self.root:getChildByName("Button_a2")
    useBtn:getChildByName("Text_26_0"):setString(g_tr("confirm"))
    self:regBtnCallback(useBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        dump(self.send)
        local isEmpty = true
        local send = {}
        for key, var in pairs(self.send) do
            send[tostring(key)] = var
            if var > 0 then
                isEmpty = false
            end
        end
        
        if isEmpty then
            g_airBox.show(g_tr("noUseItem"))
        end

        if not isEmpty then
            require("game.uilayer.publicMode.UseActions"):useBuildItem( send ,self.buildPos )
            self:close()
        end

	end)

    self.root:getChildByName("Panel_2_0"):getChildByName("Text_1"):setString(g_tr("quickDesc"))

    --self:GetFilterProps()
    self:SetSendData()
    self:LoadList()
    self:TimeUpdate()
    
end

function QuickPropsLayer:onEnter()
    
    if self.buildPos == nil then
        print("buildPos is nil") 
        self:close()
        return
    end

    self.buildData = g_PlayerBuildMode.FindBuild_Place(self.buildPos)
    if self.buildData == nil then
        print("buildData is nil")
        self:close()
        return
    end

    self.buildConfig = g_data.build[tonumber(self.buildData.build_id)]
    if self.buildConfig == nil then
        print("buildConfig is nil")
        self:close()
        return
    end

    self:GetFilterProps()
    --判断是否有道具没有则直接关闭界面
    if self.isPD then
        local isNoProp = true
        for key, prop in ipairs(self.filterData) do
            local propId = prop.id
            local count = g_BagMode.findItemNumberById(propId)
            print("count",count)
            if count > 0 then
                isNoProp = false
            end
        end
        if isNoProp then
            self:close()
        else
            self:InitUI()
            self.timer = self:schedule( handler(self,self.TimeUpdate),0)
        end
    else
        self:InitUI()
        self.timer = self:schedule( handler(self,self.TimeUpdate),0)
    end

    print("jhasjkdghashdkjasd",#self.filterData)

end

function QuickPropsLayer:SetSendData(pid,num)
    
    if self.send == nil then
        self.send = {}
        for key, var in pairs( self:GetPropsPlan() ) do
            self.send[tonumber(key)] = var.num
        end
        return
    end

    if pid == nil then
        return
    end
    
    local _num = num
    local sendTemp = clone(self.send)
    local addCount = 0
    local addCount1 = 0
    local fTime = self.buildData.build_finish_time          --完成时间
    local overTime = fTime - g_clock.getCurServerTime() - (g_PlayerMode.getReduceBuildTime() or 0)    --剩余时间
    overTime = math.max(overTime,0)
    sendTemp[pid] = _num

    for propId, num in pairs(self.send) do
        addCount = addCount + self:GetPropVar(propId) * num
    end

    for propId, num in pairs(sendTemp) do
        addCount1 = addCount1 + self:GetPropVar(propId) * num
    end

    --[[
    if  addCount > overTime and addCount1 > overTime then
        print("11111111111111111111111111111")
        self.send[pid] = self.send[pid] or 0
        if self.send[pid] > _num then
            self.send[pid] = _num or 0
        end
        _num = self.send[pid] or 0
    else
        print("222222222222222222222222222222")
        addCount = addCount - self.send[pid] * self:GetPropVar(pid)
        self.send[pid] = 0
        local v = (overTime - addCount)/self:GetPropVar(pid)
        v = math.ceil(v)
        self.send[pid] = math.min(v,_num)
        _num = self.send[pid]
    end
    ]]

    addCount = addCount - (self.send[pid] or 0) * self:GetPropVar(pid)
    self.send[pid] = 0
    local v = (overTime - addCount)/self:GetPropVar(pid)
    v = math.ceil(v)
    self.send[pid] = math.min(v,_num)
    _num = self.send[pid] > 0 and self.send[pid] or 0

    self:TimeUpdate()

    return _num



end

function QuickPropsLayer:LoadList()
    local mode = cc.CSLoader:createNode("PropsAccelerated_list1.csb")
    self.list = self.root:getChildByName("ListView_1")
    
    local rows = math.ceil( #self.filterData / 2 )
    local idx = 1
    for i = 1, rows do
    --for _, prop in ipairs(self.filterData) do
        local layout = ccui.Layout:create()
        layout:setContentSize( cc.size( self.list:getContentSize().width,mode:getContentSize().height))
        for j = 1, 2 do
            local prop = self.filterData[idx]
            if prop then
                local item = mode:clone()
                local iconPanel = item:getChildByName("Panel_1")
                local num = g_BagMode.findItemNumberById(prop.id)
                local icon = require("game.uilayer.common.DropItemView").new(g_Consts.DropType.Props,prop.id,num)
                icon:setScale(0.75)
                --icon:setCountEnabled(false)
                icon:setPosition( cc.p(iconPanel:getContentSize().width/2,iconPanel:getContentSize().height/2) )
                iconPanel:addChild( icon )
                local name = item:getChildByName("Text_1")
                name:setString(icon:getName())
                local bar = item:getChildByName("Slider_1")
                local edit = item:getChildByName("TextField_1")
                local input = g_gameTools.convertTextFieldToEditBox(edit)
                item.config = prop
                item.input = input
                item.bar = bar
                input:registerScriptEditBoxHandler(function (eventType)
                    if eventType == "customEnd" then
                        local propId = item.config.id
                        local hasNum = g_BagMode.findItemNumberById(propId)
                        local editNum = tonumber( item.input:getString() ) or 0
                        editNum = math.floor(editNum)
                        if editNum > hasNum then
                            editNum = hasNum
                        end
                        editNum = self:SetSendData(propId,editNum)
                        item.input:setString( tostring(editNum) )
                        item.bar:setPercent( ( editNum / hasNum) * 100  )
                    end
                end)

                bar:addEventListenerSlider( function ( sender,eventType )
                    if eventType == ccui.SliderEventType.percentChanged then
                        local propId = item.config.id
                        local hasNum = g_BagMode.findItemNumberById(propId)
                        local pCount = math.floor( ( item.bar:getPercent() / 100 ) * hasNum )
                
                        if hasNum <= 0 then
                            item.bar:setPercent( 0 )
                            return
                        end

                        if pCount == tonumber( item.input:getString() ) then
                            return
                        end
                
                        local _pCount = self:SetSendData(propId,pCount)
                        item.input:setString( tostring(_pCount) )
                        if _pCount < pCount then
                            item.bar:setPercent( ( _pCount / hasNum) * 100  )
                        end
                    end
                end )

                --减
                local less = item:getChildByName("Image_j1")
                less:addTouchEventListener( function (sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        local propId = item.config.id
                        local hasNum = g_BagMode.findItemNumberById(propId)
                        local count = tonumber(item.input:getString())
                        count = math.max(count - 1,0)
                        local _count = self:SetSendData(propId,count)
                        item.bar:setPercent( ( _count / hasNum) * 100  )
                        item.input:setString( tostring(_count) )
                    end
                end )
                --加
                local plus = item:getChildByName("Image_j2")
                plus:addTouchEventListener( function (sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        local propId = item.config.id
                        local hasNum = g_BagMode.findItemNumberById(propId)
                        local count = tonumber(item.input:getString())
                        count = math.min(count + 1,hasNum)
                        local _count = self:SetSendData(propId,count)
                        item.bar:setPercent( ( _count / hasNum) * 100  )
                        item.input:setString( tostring(_count) )
                    end
                end )

                item.update = function ()
                    local hasNum = g_BagMode.findItemNumberById(item.config.id)
                    local num = self.send[item.config.id] or 0
                    item.bar:setPercent( num / hasNum  * 100 )
                    item.input:setString( tostring(num or 0) )
                end
                item.update()
                table.insert(self.items,item)
                item:setPositionX( item:getContentSize().width * (j - 1) )
                layout:addChild(item)
                idx = idx + 1
            end
        end
        self.list:pushBackCustomItem(layout)
    end
    --end
end

--获取道具的配置表
function QuickPropsLayer:GetFilterProps()
    local propsConfig = g_data.item
    for _ , prop in pairs(propsConfig) do
        if prop.item_original_id == g_Consts.UseItemType.Build or prop.item_original_id == g_Consts.UseItemType.Common then
            table.insert( self.filterData,prop )
        end
    end
    table.sort( self.filterData,function (a,b)
        return  a.priority <  b.priority
    end)
end

--倒计时
function QuickPropsLayer:TimeUpdate()
    local sTime = self.buildData.build_begin_time           --开始时间
    local fTime = self.buildData.build_finish_time          --完成时间
    local overTime = fTime - g_clock.getCurServerTime()     --剩余时间
    local countTime = fTime - sTime
    --local buffTime = g_PlayerMode.getReduceBuildTime() or 0 --VIP缩减时间

    if overTime <= 0 then
        if self.timer then
            self:unschedule(self.timer)
            self.timer = nil
            self:close()
            return
        end    
    end
    
    local addCount = 0
    for propId, num in pairs(self.send) do
        addCount = addCount + self:GetPropVar(propId) * num
    end
    
    if addCount > 0 then
        self.barTxMode:setString(g_gameTools.convertSecondToString(overTime) ..
        string.format("(-%s)",g_gameTools.convertSecondToString(addCount)))

        self.barTx:setRichText(g_gameTools.convertSecondToString(overTime) .. 
        string.format("|(-<#0,255,0#>%s)|",g_gameTools.convertSecondToString(addCount)) 
        )
    else
        self.barTxMode:setString(g_gameTools.convertSecondToString(overTime))
        self.barTx:setRichText(self.barTxMode:getString())
    end

    self.bar:setPercent( 100 - overTime / countTime * 100 )

    --[[for _, item in ipairs(self.items) do
        item.update()
    end]]
    
end

function QuickPropsLayer:GetPropsPlan()
    local sTime = self.buildData.build_begin_time           --开始时间
    local fTime = self.buildData.build_finish_time          --完成时间
    --local overTime = 125412
    local overTime = fTime - g_clock.getCurServerTime() - (g_PlayerMode.getReduceBuildTime() or 0)    --剩余时间

    overTime = math.max(overTime,0)

    --3610
    --一个小时十秒
    local s = overTime % 3600

    local h = math.floor(overTime / 3600)
    
    local _8h = math.floor(h / 8)

    local _1h = h - 8 * _8h

    local _5m = math.ceil( s / 300 )

    local needUse =
    {
        { var = 300,need = _5m,diff = 0 },
        { var = 3600 ,need =_1h,diff = 0 },
        { var = 28800,need =_8h,diff = 0 },
    }

    dump(needUse)

    local usePropCount = {}

    local function asdasd()
        
        local porpList = {}
        local propCommonList = {}

        for _, prop in ipairs(self.filterData) do
            local propId = prop.id
            if prop.item_original_id == g_Consts.UseItemType.Common then
                if propCommonList[tostring(propId)] == nil then propCommonList[ tostring(propId)] = {} end
                propCommonList[tostring(propId)] = { config = prop,num = g_BagMode.findItemNumberById(propId) or 0,var = self:GetPropVar(propId) }
            else
                if porpList[tostring(propId)] == nil then porpList[ tostring(propId)] = {} end
                porpList[tostring(propId)] = { config = prop,num = g_BagMode.findItemNumberById(propId) or 0,var = self:GetPropVar(propId) } 
            end
        end

        usePropCount = {}

        local function getCommonProp(min,count)
            for _, prop in pairs(propCommonList) do
                print("==================",prop.var)
                if prop.var == min then
                    return prop.config.id,math.min( prop.num,count)
                end
            end
        end
    
        for _, prop in pairs(porpList) do
            for idx, use in ipairs(needUse) do
                if prop.var == use.var then
                    --usePropCount[prop.id] = math.min(prop.num,count)
                    local nProp = math.min(prop.num,use.need)
                    local ncPropId = nil
                    local ncProp = 0

                    if prop.num < use.need then
                        --去找通用道具
                        --dump(prop.config)
                        --print("prop.var,use.var",prop.var,use.var)
                        ncPropId,ncProp = getCommonProp(use.var,(use.need - nProp))
                        if ncPropId and ncProp then
                            usePropCount[tostring(ncPropId)] = { num = ncProp,var = use.var }
                        end
                    end

                    ncProp = ncProp or 0
                    usePropCount[tostring(prop.config.id)] = { num = nProp,var = use.var }
                    if (nProp + ncProp) < use.need then
                        needUse[idx].diff = use.need - (nProp + ncProp)
                    end
                end
            end
        end
    end
    
    asdasd()
    for i = 1, #needUse do
        if needUse[i] and needUse[i].diff > 0 then
            if needUse[i + 1] then
                needUse[i].diff = 0
                needUse[i].need = 0
                needUse[i + 1].need = needUse[i + 1].need + 1
                asdasd()
            end
        end
    end

    dump(needUse)
    for i = #needUse, 1, -1 do
        if needUse[i] and needUse[i].diff > 0 then
            if needUse[ i - 1 ] then
                needUse[ i - 1 ].need = needUse[i - 1].need + ( needUse[i].diff * needUse[i].var / needUse[i - 1].var)
                needUse[ i ].need = needUse[ i ].need - needUse[ i ].diff
                needUse[ i ].diff = 0
                asdasd()
            end
        end
    end
    dump(needUse)

    return usePropCount

end

function QuickPropsLayer:GetPropVar(propId)
    local addv = 0
    local acceleration = g_data.item_acceleration[ tonumber(g_data.item[tonumber( propId )].item_acceleration)]
    if acceleration then
        addv = acceleration.item_num
    end
    return addv
end


function QuickPropsLayer:onExit()

end






return QuickPropsLayer
