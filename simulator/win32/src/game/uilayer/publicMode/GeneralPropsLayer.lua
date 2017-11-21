local GeneralPropsLayer = class("GeneralPropsLayer", require("game.uilayer.base.BaseLayer"))

--测试加速时间
--ispddj --是否判断道具数量直接关闭界面
function GeneralPropsLayer:ctor(pos,itemType,callback,ispddj)
    GeneralPropsLayer.super.ctor(self)
    self.buildPos = pos
    self.itemType = itemType
    self.callback = callback
    self.filterData = {}
    self.items = {}
    self.ispddj = ispddj
    self.send = nil
end

function GeneralPropsLayer:InitUI()
    self.layer = self:loadUI("PropsAccelerated_main.csb")
    self.root = self.layer:getChildByName("scale_node")
    local closeBtn = self.root:getChildByName("Button_xhao")
    self:regBtnCallback(closeBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
    
    if self.itemType == g_Consts.UseItemType.Build then
        self.root:getChildByName("Text_1_2"):setString(g_tr("buildAccelerate"))
    elseif self.itemType == g_Consts.UseItemType.Soldier then
        self.root:getChildByName("Text_1_2"):setString(g_tr("soldierAccelerate"))
    elseif self.itemType == g_Consts.UseItemType.Trap then
        self.root:getChildByName("Text_1_2"):setString(g_tr("trapAccelerate"))
    elseif self.itemType == g_Consts.UseItemType.Study then
        self.root:getChildByName("Text_1_2"):setString(g_tr("studyAccelerate"))
    elseif self.itemType == g_Consts.UseItemType.Health then
        self.root:getChildByName("Text_1_2"):setString(g_tr("healthAccelerate"))
    else
        self.root:getChildByName("Text_1_2"):setString(g_tr("ItemModeTitle"))
    end
    
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
            if var > 0 then
                send[tostring(key)] = var
                isEmpty = false
            end
        end
        
        if isEmpty then
            g_airBox.show(g_tr("noUseItem"))
        else
            local res = false
            --建筑加速
            if self.itemType == g_Consts.UseItemType.Build then
                res = require("game.uilayer.publicMode.UseActions"):useBuildItem(send ,self.buildPos )
            end
            --士兵加速
            if self.itemType == g_Consts.UseItemType.Soldier then
                --print("士兵加速,posId",self.buildPos)
                res = require("game.uilayer.publicMode.UseActions"):useSoldierItem(send ,self.buildPos )
            end
            --陷阱加速
            if self.itemType == g_Consts.UseItemType.Trap then
                --print("陷阱加速,posId",self.buildPos)
                res = require("game.uilayer.publicMode.UseActions"):useTrapItem(send ,self.buildPos )
            end
            --科技加速
            if self.itemType == g_Consts.UseItemType.Study then
                local config = g_data.science[tonumber(self.buildData.work_content)]
                local typeId
                if config then
                    typeId = config.science_type_id
                    res = require("game.uilayer.publicMode.UseActions"):useStudyItem(send ,typeId )
                end
            end
            --治疗加速
            if self.itemType == g_Consts.UseItemType.Health then
                res = require("game.uilayer.publicMode.UseActions"):useHealthItem(send)
                --res = require("game.uilayer.publicMode.UseActions"):useStudyItem( send ,self.buildPos )
            end
            
            if res then
                if self.callback and type(self.callback) == "function" then
                    self.callback()
                end
            end

            self:close()
        end

	end)

    self.root:getChildByName("Panel_2_0"):getChildByName("Text_1"):setString(g_tr("quickDesc"))

    --self:GetFilterProps()
    self:SetSendData()
    self:LoadList()
    self:TimeUpdate()
    
end

function GeneralPropsLayer:onEnter()
    
    if g_guideManager.getLastShowStep() then
      self:close()
      return
    end
    
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

    if self.itemType == nil then
        print("self.itemType is nil")
        self:close()
        return
    end

    if self.itemType == g_Consts.UseItemType.Build then
        local sTime = self:getStartTime()--开始时间  
        local fTime = self:getFinishTime()--完成时间   
        if (fTime - sTime) <= g_PlayerMode.getReduceBuildTime() then
            self:close()
        end
    end
    
    --判断是否有道具没有则直接关闭界面
    self:GetFilterProps()
    local isNoProp = true

    for key, prop in ipairs(self.filterData) do
        local propId = prop.id
        if g_BagMode.findItemNumberById(propId) > 0 then
            isNoProp = false
            break
        end
    end
    
    if isNoProp then
        if self.ispddj then
            g_airBox.show(g_tr("noAccelerateItem"))
        end
        self:close()
    else
        self:InitUI()
        self.timer = self:schedule( handler(self,self.TimeUpdate),0)
    end
end

function GeneralPropsLayer:SetSendData(pid,num)
    
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
    --local addCount1 = 0
    local fTime = self:getFinishTime()
    --self.buildData.build_finish_time          --完成时间
    local overTime = fTime - g_clock.getCurServerTime() - ( self.itemType == g_Consts.UseItemType.Build and g_PlayerMode.getReduceBuildTime() or 0)    --剩余时间

    overTime = math.max(overTime,0)
    sendTemp[pid] = _num

    for propId, num in pairs(self.send) do
        addCount = addCount + self:GetPropVar(propId) * num
    end

    --[[
    for propId, num in pairs(sendTemp) do
        addCount1 = addCount1 + self:GetPropVar(propId) * num
    end

    
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
    v = math.max(0,math.ceil(v))
    self.send[pid] = math.min(v,_num)
    _num = self.send[pid] > 0 and self.send[pid] or 0

    print("_num",_num)

    self:TimeUpdate()

    return _num



end

function GeneralPropsLayer:LoadList()
    local mode = cc.CSLoader:createNode("PropsAccelerated_list1.csb")
    self.list = self.root:getChildByName("ListView_1")
    
    local rows = math.ceil( #self.filterData / 2 )
    local idx = 1
    for i = 1, rows do
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
                        if tonumber(editNum) > 0 then
                            item.input:setFontColor(cc.c3b(30,230,30))
                        else
                            item.input:setFontColor(cc.c3b(255,255,255))
                        end
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

                        if _pCount > 0 then
                            item.input:setFontColor(cc.c3b(30,230,30))
                        else
                            item.input:setFontColor(cc.c3b(255,255,255))
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
                        if _count > 0 then
                            item.input:setFontColor(cc.c3b(30,230,30))
                        else
                            item.input:setFontColor(cc.c3b(255,255,255))
                        end
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
                        if _count > 0 then
                            item.input:setFontColor(cc.c3b(30,230,30))
                        else
                            item.input:setFontColor(cc.c3b(255,255,255))
                        end
                    end
                end )

                item.update = function ()
                    local hasNum = g_BagMode.findItemNumberById(item.config.id)
                    local num = self.send[item.config.id] or 0
                    item.bar:setPercent( num / hasNum  * 100 )
                    item.input:setString( tostring(num or 0) )
                     if num > 0 then
                        item.input:setFontColor(cc.c3b(30,230,30))
                    else
                        item.input:setFontColor(cc.c3b(255,255,255))
                    end
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
end

--获取道具的配置表
function GeneralPropsLayer:GetFilterProps()
    local propsConfig = g_data.item
    for _ , prop in pairs(propsConfig) do
        if prop.item_original_id == self.itemType or prop.item_original_id == g_Consts.UseItemType.Common then
            table.insert( self.filterData,prop )
        end
    end
    table.sort( self.filterData,function (a,b)
        return  a.priority <  b.priority
    end)
end

--倒计时
function GeneralPropsLayer:TimeUpdate()
    local sTime = self:getStartTime()--开始时间
    --self.buildData.build_begin_time           
    local fTime = self:getFinishTime()--完成时间
    --self.buildData.build_finish_time          
    local overTime = fTime - g_clock.getCurServerTime()--剩余时间
    
    local countTime = fTime - sTime--全部时间

    if overTime <= 0 then
        if self.timer then
            self:unschedule(self.timer)
            self.timer = nil
            self:close()
            return
        end    
    end
    
    local addCount = 0
    
    --dump(self.send)
    
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

function GeneralPropsLayer:GetPropsPlan()
    local sTime = self:getStartTime()
    --self.buildData.build_begin_time           --开始时间
    local fTime = self:getFinishTime()
    --self.buildData.build_finish_time          --完成时间
    local overTime = fTime - g_clock.getCurServerTime() - (self.itemType == g_Consts.UseItemType.Build and g_PlayerMode.getReduceBuildTime() or 0)    --剩余时间

    overTime = math.max(overTime,0)
    
    local s = overTime % 3600

    local h = math.floor(overTime / 3600)
    
    local _8h = math.floor(h / 8)

    local _1h = h - 8 * _8h

    local _5m = math.ceil( s / 300 )
    
    local needUse =
    {
        { var = 300,need = _5m,diff = 0,count = 0 },
        { var = 3600 ,need =_1h,diff = 0,count = 0 },
        { var = 28800,need =_8h,diff = 0,count = 0 },
    }

    for _, need in ipairs(needUse) do
        for _, prop in ipairs(self.filterData) do
            local propId = prop.id
            if self:GetPropVar(propId) == need.var then
                need.count = need.count + g_BagMode.findItemNumberById(propId)
            end
        end
    end
    
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
    dump(needUse)
    for i = #needUse, 1, -1 do
        if needUse[i] and needUse[i].diff > 0 then
            local alreadTime = 0
            --local syTime = 0
            --local need = 0
            for j = 1, #needUse do
                alreadTime = alreadTime + ( needUse[j].need - needUse[j].diff ) * needUse[j].var
            end

            local syTime = overTime - alreadTime
            local need = 0
            for j = i - 1, 1, -1 do
                need = math.ceil( syTime / needUse[j].var )
                if syTime > 0 then
                    if (need + needUse[j].need) <= needUse[j].count then
                        needUse[j].diff = 0
                        needUse[j].need = need + needUse[j].need
                    else
                        needUse[j].diff = (need + needUse[j].need) - needUse[j].count
                        needUse[j].need = need + needUse[j].need
                    end
                    syTime = syTime - need * needUse[j].var
                else
                    needUse[j].need = math.max(need + needUse[j].need,0)
                end
            end
        end
    end
    dump(needUse)
    asdasd()
    

    --[[

    local isNeed = false

    asdasd()
    dump(needUse)
    for i = 1, #needUse do
        if needUse[i] and needUse[i].diff > 0 then
            if needUse[i + 1] then
                needUse[i].diff = 0
                needUse[i].need = 0
                needUse[i + 1].need = needUse[i + 1].need + 1
                isNeed = true
            end
        end
    end
    asdasd()
    dump(needUse)
    for i = #needUse, 1, -1 do
        if needUse[i] and needUse[i].diff > 0 then
            if needUse[ i - 1 ] then
                needUse[ i - 1 ].need = needUse[i - 1].need + ( needUse[i].diff * needUse[i].var / needUse[i - 1].var)
                needUse[ i ].need = needUse[ i ].need - needUse[ i ].diff
                needUse[ i ].diff = 0
                
            end
        end
    end
    asdasd()
    --dump(needUse)
    if isNeed then
        local syTime = overTime - needUse[#needUse].need * needUse[#needUse].var
        for i = #needUse - 1, 1, -1 do
            local count = 0
            if syTime > 0 then
                count = math.min( needUse[i].count,math.ceil( syTime / needUse[i].var))
            end
            syTime = syTime - count * needUse[i].var
            needUse[i].need = count
        end
        asdasd()
    end
    ]]
    return usePropCount

end

function GeneralPropsLayer:GetPropVar(propId)
    local addv = 0
    local acceleration = g_data.item_acceleration[ tonumber(g_data.item[tonumber( propId )].item_acceleration)]
    if acceleration then
        addv = acceleration.item_num
    end
    return addv
end


function GeneralPropsLayer:getStartTime()
    local startTime = 0
    if self.itemType == g_Consts.UseItemType.Build then --建筑升级
        startTime = self.buildData.build_begin_time          
    elseif 
        self.itemType == g_Consts.UseItemType.Soldier or 
        self.itemType == g_Consts.UseItemType.Trap or 
        self.itemType == g_Consts.UseItemType.Study or 
        self.itemType == g_Consts.UseItemType.Health
        then --兵营/陷阱
        startTime = self.buildData.work_begin_time
    end

    return startTime
end

function GeneralPropsLayer:getFinishTime()
    local finishTime = 0
    if self.itemType == g_Consts.UseItemType.Build then  --建筑升级
        finishTime = self.buildData.build_finish_time
    elseif 
        self.itemType == g_Consts.UseItemType.Soldier or 
        self.itemType == g_Consts.UseItemType.Trap or 
        self.itemType == g_Consts.UseItemType.Study or 
        self.itemType == g_Consts.UseItemType.Health
        then --兵营/陷阱
        finishTime = self.buildData.work_finish_time
    end

    return finishTime
end


function GeneralPropsLayer:onExit()

end


return GeneralPropsLayer
