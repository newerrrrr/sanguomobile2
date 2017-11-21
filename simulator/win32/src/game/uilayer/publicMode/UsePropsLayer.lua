local UsePropsLayer = class("UsePropsLayer", require("game.uilayer.base.BaseLayer"))
local itemdata = nil
local masterdata = nil
local CAN_USE_TYPE = 1
local MODE = nil

--[[
getdatafun 调用所返回一些必要的数据
格式 
{
    bid = 建筑id 或者一些主要ID 比如行军速度的  queueServerData.id      (消耗普通药水不填)
    stime = 开始时间    (消耗普通药水不填)
    ftime = 完成时间    (消耗普通药水不填)
    itype = 道具类型    (消耗道具在Consts.lua 定义，作为消耗道具的筛选条件，也用于经验药水和行动力药水区分) 
    callback = 回调方法 
}
]]

--使用之前确保UI数据是完整使用 UsePropsLayer:createLayer() 方法创建


function UsePropsLayer:createLayer( fun )
    MODE = require("game.uilayer.publicMode.UseActions").new()
    masterdata = g_PlayerMode.GetData()
    itemdata = g_BagMode.GetData()

    if masterdata and itemdata then
         g_sceneManager.addNodeForUI( UsePropsLayer:create( fun ) )
         return true
    end

    return false

end


function UsePropsLayer:ctor( getdatafun )
    UsePropsLayer.super.ctor(self)
    self.getdatafun = getdatafun
    self.showtime_tx = nil
    self.showtime_mode = nil
    self.selitemid = nil
    --self.selNorId = nil
    self.canTouch = true
    self:setData()
end

--获取所需要的数据
--newdata带回新的建筑数据刷新界面
function UsePropsLayer:setData( newdata )
    
    local getdata = self.getdatafun(newdata)
    self.bid = getdata.bid
    self.stime = tonumber(getdata.stime)
    self.ftime = tonumber(getdata.ftime)
    self.itype = tonumber(getdata.itype)
    self.callbcak = getdata.callback

    --print("self.callbcak",self.callbcak)

    --当前玩家可秒掉建筑的时间 计算中去掉这个时间
    self.rbTime = 0
    if self.itype == g_Consts.UseItemType.Build then
        --local ReduceBuildTime = g_PlayerMode.getReduceBuildTime()
        --self.ftime = self.ftime - ReduceBuildTime
        self.rbTime = g_PlayerMode.getReduceBuildTime()
    end

    --getReduceBuildTime

    --print("bid,ftime,itype,callback",self.bid,getdata.stime,self.ftime,self.itype,self.callbcak)

    if --[[self.bid and]] self.stime and self.ftime then
        local nowtime = self.ftime - self.rbTime - g_clock.getCurServerTime()
        if nowtime > 0 then
            --定时器开启
            self.timer = self:schedule( handler(self,self.steptime),1 )
        else
            self:close()
            return
        end
    elseif self.itype == g_Consts.UseItemType.EXP or self.itype == g_Consts.UseItemType.MOVE then
        masterdata = g_PlayerMode.GetData()
    else
        print("data error")
    end
    
    self:initUI()

end

function UsePropsLayer:initUI()

    if self.layer == nil then
        self.layer = self:loadUI("kuaishudaojulan.csb")
    end

	self.root = self.layer:getChildByName("scale_node")
    --设置标题
    self:setTitle(g_tr("ItemModeTitle"))

    self.root:getChildByName("Text_dianji"):setString(g_tr("ItemModeUse"))
    --进度条节点
    self.loading_bar = self.root:getChildByName("LoadingBar_1")
    --符文本框模版节点
    self.showtime_mode = self.root:getChildByName("Text_8")
    --富文本框节点
    if self.showtime_tx == nil then
        self.showtime_tx = g_gameTools.createRichText(self.showtime_mode,nil)
    end
    --隐藏模版
    --self.showtime_mode:setVisible(false)
    --使用数量调节节点
    self.slider = self.root:getChildByName("Panel_2"):getChildByName("Slider_1")
    --输入框道具数量节点
    local editmode = self.root:getChildByName("Panel_2"):getChildByName("TextField_1")
    editmode:setVisible(false)
    --替换控件 只是用一次
    if self.edit == nil then
        self.edit = g_gameTools.convertTextFieldToEditBox(editmode,editboxEventHandler)
        self.edit:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    end
    --self.root:getChildByName("Panel_2"):getChildByName("TextField_1")
    
    self.lessBtn = self.root:getChildByName("Panel_2"):getChildByName("Image_97")

    self.plusBtn = self.root:getChildByName("Panel_2"):getChildByName("Image_97_0")

    --初始化
    self.slider:setPercent(0)
    self.edit:setPlaceHolder("0")

    

    --加速时间显示节点
    --self.addstr =  self.root:getChildByName("Text_4_0_1")
    --self.addstr:setString(g_tr("ItemShow"))
    self.addtime = self.root:getChildByName("Text_4_0_1")
    self.addtime:setString( string.format( "%s%02d:%02d:%02d", g_tr("ItemShow"),0, 0, 0 ) )

    --行军加速 隐藏选择数量节点
    --[[if self.itype == g_Consts.UseItemType.Quick then
        self.root:getChildByName("Panel_2"):setVisible(false)
        --self.addstr:setString(g_tr("QuickItemShow"))
    end]]

    if --[[self.bid and]] self.stime and self.ftime then
        --多加五个像素 保证富文本框 显示完整
        --self.showtime_tx:setRichSize( self.showtime_mode:getContentSize().width + 10 )
        --初始化倒计时时间
        self:steptime()
    else
        --初始化进度条
        self:setLoadingBar()
        --self.addstr:setVisible(false)
        self.addtime:setVisible(false)
        
    end

	local close_btn = self.root:getChildByName("Button_2")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    local list = self.root:getChildByName("ListView_1")
    local itemmode = cc.CSLoader:createNode("Time.csb")
    
    list:setItemsMargin( 15 )
    local selitem = nil
    
    --道具选择
    local function touchItemListener(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender ~= selitem then
                selitem:getChildByName("Image_2"):setVisible(false)
                selitem = sender
                selitem:getChildByName("Image_2"):setVisible(true)
                self.selitemid = selitem.item_id
                self:setUseCount()
            end
        end
    end
    
    list:removeAllItems()

    local filterdata = {}

    local item1 = nil

    local item2 = nil

    local sel = nil

    local selPar = 0

    for key , t_data in pairs(g_data.item) do
        if self.itype == t_data.item_original_id then
            --dump(t_data)
            if item1 == nil then
                local norItemCount = g_BagMode.findItemNumberById( t_data.id )
                if norItemCount > 0 then
                    item1 = t_data.id
                end
            end
            --print("item count",g_BagMode.findItemNumberById( t_data.id ))
            table.insert( filterdata,t_data )
        end

        --如果是建筑升级 加入通用道具经验与体力去掉
        if g_Consts.UseItemType.Common == t_data.item_original_id 
        and self.itype ~= g_Consts.UseItemType.EXP 
        and self.itype ~= g_Consts.UseItemType.MOVE
        then
            --[[if item2 == nil then
                local norItemCount = g_BagMode.findItemNumberById( t_data.id )
                if norItemCount > 0 then
                    item2 = t_data.id
                end
            end]]
            table.insert( filterdata,t_data )
        end
    end
    
    table.sort(filterdata,function (a,b)
        return  a.priority <  b.priority
    end)

    sel = item1 or item2

    if sel then
        for index, var in ipairs(filterdata) do
            if var.id == sel then
                selPar = index
            end
        end
        if selPar then
            selPar =  selPar / table.nums(filterdata) * 100
        end
        --selIndex = table.keyof(filterdata,sel)
    end
    

    if sel and self.selitemid == nil then
        self.selitemid = sel
    end

    --初始化道具列表
    for i,data in pairs(filterdata) do
        

        local itemPanel = itemmode:clone()

        local item_type = g_Consts.DropType.Props

        local item_id = data.id

        local item_num = g_BagMode.findItemNumberById( data.id )
        
        
        list:pushBackCustomItem(itemPanel)
        
        local itemroot = itemPanel:getChildByName("scale_node")
        local item_border = itemroot:getChildByName("Image_1_0")
        local item = require("game.uilayer.common.DropItemView").new(item_type, item_id,item_num)
        --g_itemTips.tip(item,item_type,item_id)
        --itemPanel:setContentSize( item:getContentSize() )
        item:setPosition(cc.p( item_border:getContentSize().width/2,item_border:getContentSize().height/2 ))
        item:setNameVisible(true)

        item._nameLabel:setFontSize(22)

        item_border:addChild(item)
        
        --local itempic = itemroot:getChildByName("Image_1")
        --local itemname = itemroot:getChildByName("Text_1")
        --local itemnum = itemroot:getChildByName("Text_2")

        --图标
        --itempic:loadTexture( g_resManager.getResPath( data.res_icon) )
        --名字
        --itemname:setString( g_tr(data.item_name)  )
        --数量
        --itemnum:setString( "x" .. g_BagMode.findItemNumberById( data.id ) )

        itemroot:setTouchEnabled(true)

        itemroot:addTouchEventListener(touchItemListener)

        itemroot:getChildByName("Image_2"):setVisible(false)

        itemroot.item_id = data.id

        if self.selitemid == nil or self.selitemid == data.id then
            self.selitemid = data.id
            selitem = itemroot
            self:setUseCount()
            itemroot:getChildByName("Image_2"):setVisible(true)
        end
    end

    --添加4
    local send_btn = self.root:getChildByName("Button_1")
    send_btn:getChildByName("Text_4"):setString( g_tr("bagUse") )

    self:regBtnCallback(send_btn,function ()
        
        if not self.canTouch then
            return
        end

        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

        --print("itemid",self.selitemid)

        --加速行军速度道具（特殊）
        --[[if self.itype == g_Consts.UseItemType.Quick then
            local itemNum = g_BagMode.findItemNumberById( self.selitemid )
            if itemNum > 0 then
                local rdata = MODE:useQuickItem( self.bid,self.selitemid )
                if rdata then
                    self:close()
                    return
                end
                --print("bid",self.bid)
                return
            end
        end]]

        

        
        if g_BagMode.findItemNumberById( self.selitemid ) <= 0 then
            g_airBox.show(g_tr("ItemUseNotEnough"),3)
            return
            --print("道具不足")
        end

        local useitemcount = tonumber( self.edit:getString() ) or 0
        
        --经验药水或者体力药水使用
        if self.itype == g_Consts.UseItemType.MOVE then
            if g_PlayerMode.getMove() >= g_PlayerMode.getLimitMove() then
                --print("状态已满")
                g_airBox.show(g_tr("MasterMoveMax"),3)
                return
            end
        end

        if self.itype == g_Consts.UseItemType.EXP or self.itype == g_Consts.UseItemType.MOVE then
            if self.selitemid and useitemcount > 0  then
                local rdata = MODE:useItem( self.selitemid,useitemcount )
                if rdata then
                    --更新UI
                    self:setData()
                    if self.callbcak then
                        self.callbcak()
                    end
                    return
                end
            end
            return
        end


        --[[if useitemcount <= 0 then
            local hasItemNum = g_BagMode.findItemNumberById( self.selitemid )

            if hasItemNum > 0 then
                self:close()
            else
                g_airBox.show(g_tr("ItemUseNotEnough"),3)
                --g_airBox.show(g_tr("ItemUseNotEnough"),3)
            end

            return
        end]]

        --超出数量 30分钟提示
        local excNum =  30 * 60
        
        local function useItem()
            --建筑升级
            if self.itype == g_Consts.UseItemType.Build then
                if self.selitemid and useitemcount > 0 and self.bid then 
                    self:returnDataUpdateUI(function ()
                        return MODE:useBuildItem( { [tostring(self.selitemid)] = useitemcount },self.bid )
                    end)
                    --[[     
                    local function _fun(eventType)
                            if eventType == 0 then
                                self:returnDataUpdateUI(function ()
                                    return MODE:useBuildItem( self.selitemid,useitemcount,self.bid )
                                end)
                            end
                        end
                        g_msgBox.show( g_tr("itemUseTips"),nil,nil,_fun,1)
                    end
                    ]]
                end

                return
            end
        
            --造兵加速
            if self.itype == g_Consts.UseItemType.Soldier then
                if self.selitemid and useitemcount > 0 and self.bid then
                    self:returnDataUpdateUI(function ()
                        return MODE:useSoldierItem( self.selitemid,useitemcount,self.bid )
                    end)
                end
                return
            end
        
            --医院
            if self.itype == g_Consts.UseItemType.Health then
                if self.selitemid and useitemcount > 0 then
                    self:returnDataUpdateUI(function ()
                        return MODE:useHealthItem( self.selitemid,useitemcount )
                    end)
                end
                return
            end

            --研究
            if self.itype == g_Consts.UseItemType.Study then
                if self.selitemid and useitemcount > 0 then
                    self:returnDataUpdateUI(function ()
                        return MODE:useStudyItem(self.bid,self.selitemid,useitemcount)
                    end)
                end
                return
            end

            --陷阱
            if self.itype == g_Consts.UseItemType.Trap then
                if self.selitemid and useitemcount > 0 and self.bid then
                    self:returnDataUpdateUI(function ()
                        return MODE:useTrapItem( self.selitemid,useitemcount,self.bid )
                    end)
                end
                return
            end

        end
        
        --测试使用
        local nowtime = self.ftime - self.rbTime - g_clock.getCurServerTime() + excNum
        local addtime = self:addvalue(useitemcount) 
        if addtime <= nowtime then
            useItem()
        else
            local function _fun(eventType)
                if eventType == 0 then
                    useItem()
                end
            end
            g_msgBox.show( g_tr("itemUseTips"),nil,nil,_fun,1)     
        end
	end)
    
    print("selParselParselPar",selPar)

    local dtime = cc.DelayTime:create(0)
    local dfun = cc.CallFunc:create(function ()
        list:jumpToPercentHorizontal(selPar)
    end)

    list:runAction( cc.Sequence:create(dtime,dfun) )
    

end

--计算选中道具的单一加值
--添加1
function UsePropsLayer:oneaddvalue()
    
    local addv = 0
    --经验值与行动力道具使用
    if self.itype == g_Consts.UseItemType.EXP or self.itype == g_Consts.UseItemType.MOVE then
        local drop = g_data.item[tonumber( self.selitemid )].drop
        for _, drop_id in ipairs(drop) do
            local drop_data = g_data.drop[ tonumber(drop_id) ].drop_data
            for _, drop_info in ipairs(drop_data) do
                addv = addv + drop_info[3]
            end 
        end
    elseif self.itype == g_Consts.UseItemType.Build or   --建筑升级道具使用
           self.itype == g_Consts.UseItemType.Health or  --医院治疗加速 
           self.itype == g_Consts.UseItemType.Soldier or --士兵制造加速
           self.itype == g_Consts.UseItemType.Study or   --科技研究加速
           self.itype == g_Consts.UseItemType.Trap       --陷阱制造加速
    then
        local acceleration = g_data.item_acceleration[ tonumber(g_data.item[tonumber( self.selitemid )].item_acceleration)]
        if acceleration then
            addv = acceleration.item_num
        end
    end

    return addv
end

--计算使用道具数量所加的值
function UsePropsLayer:addvalue(itemcount)
    return itemcount * self:oneaddvalue()
end

--添加2
function UsePropsLayer:setLoadingBar( icount )

    --icount 当前道具的使用数量
    icount = icount or 0
    --经验值或者体力值显示方法
    local function ExpOrPowerShow(nv,tv)
        --local nv = 0           --当前值
        --local tv = 0           --上限值
        local rtxt
        local modestr = ""
        if icount > 0 then
            local addcount = self:addvalue(icount)    
            rtxt = nv .. "|<#0,255,0#>" .. string.format("+%d",addcount) .. "|/"..tv
            modestr = nv .. string.format("+%d",addcount) .. "/"..tv
        else
            rtxt = nv .."/" .. tv
            modestr = nv .."/" .. tv
        end

        self.showtime_mode:setString(  modestr   )
        self.showtime_tx:setRichText( rtxt )
        --self.showtime_tx:setRichSize( self.showtime_mode:getContentSize().width + 10)
        self.loading_bar:setPercent( nv / tv * 100  )
    end
    --经验初始化
    if self.itype == g_Consts.UseItemType.EXP then
        local nv = masterdata.current_exp - g_data.master[ masterdata.level ].exp --升下一等级的剩余经验
        local tv = masterdata.next_exp - g_data.master[ masterdata.level ].exp
        ExpOrPowerShow(nv,tv)
    end
    --行动力初始化
    if self.itype == g_Consts.UseItemType.MOVE then
        nv = g_PlayerMode.getMove()
        tv = g_PlayerMode.getLimitMove()
        ExpOrPowerShow(nv,tv)
    end
    
    --行军加速道具
    --[[if self.itype == g_Consts.UseItemType.Quick then
        self.addtime:setString( g_tr(g_data.item[tonumber( self.selitemid )].item_introduction) )
    end]]

    
    if self.itype == g_Consts.UseItemType.Build    --建筑升级
    or self.itype == g_Consts.UseItemType.Health   --治疗加速道具
    or self.itype == g_Consts.UseItemType.Soldier  --造兵加速
    or self.itype == g_Consts.UseItemType.Study    --研究加速
    or self.itype == g_Consts.UseItemType.Trap     --陷阱加速
    then
        self.addtime:setString( string.format( "%s%02d:%02d:%02d", g_tr("ItemShow"),g_clock.formatTimeHMS( self:addvalue(icount) ) ) )
    end
    
end


--初始化使用数量
--添加3
function UsePropsLayer:setUseCount()
    
    print("setUseCount")

    local itemcount = g_BagMode.findItemNumberById( self.selitemid )--拥有道具的数量
    local itemnowcount = 0 --实际需要使用道具数量
    
    --计算经验值的最大值
    if self.itype == g_Consts.UseItemType.EXP then
        local max_level = table.nums(g_data.master) --获取最高等级
        if masterdata.level < max_level then --等级已经最高
            local usemaxnum = -1 * ( masterdata.current_exp - g_data.master[masterdata.level].exp )  --总共需要多少经验达到等级上线(初始化为负的当前等级的余下经验)
            --累加计算出经验值总和
            for key, var in pairs(g_data.master) do
                if var.level > masterdata.level then
                    usemaxnum = usemaxnum + g_data.master[var.level].exp - g_data.master[ var.level - 1 ].exp or 0
                end
            end
            
            --计算实际需要使用道具的数量
            --所加的数值有溢出 算出溢出道具数量
            if self:addvalue(itemcount) >= usemaxnum then
                local s = self:addvalue(itemcount) - usemaxnum --经验溢出
                itemnowcount = itemcount - math.floor( s / self:oneaddvalue() )
            else
                itemnowcount = itemcount
            end
        end
    end

    --计算行动力的最大值
    if self.itype == g_Consts.UseItemType.MOVE then
        local nowmove = g_PlayerMode.getMove()
        if nowmove < g_PlayerMode.getLimitMove() then
            local nvalue = g_PlayerMode.getLimitMove() - nowmove
            if self:addvalue(itemcount) >= nvalue then
                local s = self:addvalue(itemcount) - nvalue
                itemnowcount = itemcount - math.floor( s / self:oneaddvalue() )
            else
                itemnowcount = itemcount
            end
        end
    end

    
    if self.itype == g_Consts.UseItemType.Build    --建筑升级
    or self.itype == g_Consts.UseItemType.Health   --医疗升级
    or self.itype == g_Consts.UseItemType.Soldier  --造兵加速
    or self.itype == g_Consts.UseItemType.Study    --研究加速
    or self.itype == g_Consts.UseItemType.Trap     --陷阱加速
    then
        --剩余时间
        local nowtime = self.ftime - self.rbTime - g_clock.getCurServerTime() 
        if nowtime > 0 then
            if self:addvalue(itemcount) >= nowtime then
                local s = self:addvalue(itemcount) - nowtime
                itemnowcount = itemcount - math.floor( s / self:oneaddvalue() )
            else
                itemnowcount = itemcount
            end
        end
    end
    
    self.edit:setString( tostring(itemnowcount) )
    self:setLoadingBar( itemnowcount )

    if itemnowcount <= 0 then
        self.slider:setPercent( 0 )
        self.slider:setTouchEnabled(false)
    else
        self.slider:setPercent( 100 )
        self.slider:setTouchEnabled(true)
    end
    

    self.slider:addEventListenerSlider( function ( sender,eventType )
        if eventType == ccui.SliderEventType.percentChanged then
            local icount = math.floor( ( self.slider:getPercent() / 100 ) * itemnowcount )
            self.edit:setString( tostring(icount) )
            self:setLoadingBar(icount)
        end
    end )

    self.edit:registerScriptEditBoxHandler( function (eventType)
        if eventType == "customEnd" then
            local editnum = tonumber( self.edit:getString() ) or 0
            editnum = math.floor(editnum)
            if editnum > itemnowcount then
                editnum = itemnowcount
            end

            if editnum < 0 then
                editnum = 0
            end
            
            self:setLoadingBar(editnum)
            self.edit:setString( tostring(editnum) )
            self.slider:setPercent( ( editnum / itemnowcount) * 100  )
        end
        
    end )

    --减按钮
    local function  TouchLess(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --print("TouchLess",itemnowcount)
            local num = self.edit:getString()
            num = num - 1
            if num <= 0 then
                num = 0
            end

            self:setLoadingBar(num)
            self.edit:setString( tostring(num) )
            self.slider:setPercent( ( num / itemnowcount) * 100  )

        end
    end
    --加按钮
    local function TouchPlus(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --print("TouchPlus",itemnowcount)
            local num = self.edit:getString()
            num = num + 1
            if num >= itemnowcount then
                num = itemnowcount
            end

            self:setLoadingBar(num)
            self.edit:setString( tostring(num) )
            self.slider:setPercent( ( num / itemnowcount) * 100  )
        end
    end

    self.lessBtn:addTouchEventListener(TouchLess)
    self.plusBtn:addTouchEventListener(TouchPlus)


end

--倒计时方法
function UsePropsLayer:steptime()
    --总共需要的时间
    local alltime = self.ftime - self.stime
    --剩余时间
    local nowtime = self.ftime - g_clock.getCurServerTime()
    local ReduceBuildTime = g_PlayerMode.getReduceBuildTime() or 0

    if ( nowtime - self.rbTime ) < 0 then
        if self.timer then
            self:unschedule(self.timer)
            self.timer = nil
            --self.loading_bar:setPercent( 100 - nowtime / alltime * 100 )
            --self.showtime_tx:setRichText( string.format( "%02d:%02d:%02d",g_clock.formatTimeHMS( nowtime ) ) )
            self:close()
        end
    else
        self.loading_bar:setPercent( 100 - nowtime / alltime * 100 )
        self.showtime_tx:setRichText( string.format( "%02d:%02d:%02d",g_clock.formatTimeHMS( nowtime ) ) )
    end
end

function UsePropsLayer:returnDataUpdateUI(fun)
    self.canTouch = false
    if fun then
        local rdata = fun()
        if rdata then
            self.canTouch = true
            if self.callbcak then
                self.callbcak()
            end
            self:setData( rdata )
        end
    end
end

--设置title
function UsePropsLayer:setTitle(titlestr)
    if titlestr then
       local title = self.root:getChildByName("Image_2"):getChildByName("Text_dianji_0")
       title:setString(  tostring(titlestr) )
    end
end



function UsePropsLayer:onEnter( )
	print("UsePropsLayer onEnter")
end

function UsePropsLayer:onExit( )
	print("UsePropsLayer onExit")
    itemdata = nil
    masterData = nil
end
    
return UsePropsLayer