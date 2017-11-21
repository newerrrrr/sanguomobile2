local cityBufferLayer = class("cityBufferLayer", require("game.uilayer.base.BaseLayer"))

local item_buffer_data = nil


local reqItemBuff = function()
    local function reultHandler( result , data )
        if true == result then
            item_buffer_data = data.PlayerItemBuff
        end
    end

    g_sgHttp.postData("player/getItemBuff", {}, reultHandler)
    
end

local _reqItemBuffAsync = function(callback)
    local function reultHandler( result , data )
        if true == result then
            item_buffer_data = data.PlayerItemBuff
        end
        if callback then
            callback(result,data)
        end
    end
    g_sgHttp.postData("player/getItemBuff", {}, reultHandler,true)
    
end

local _getSeverBuffInfo = function(buffTempInfo)

    local serverBuffInfo = nil
    if buffTempInfo.buff_id[1] == 9 then --免战保护要从player信息中读取
        serverBuffInfo = {}
        serverBuffInfo.expire_time = g_PlayerMode.GetData().avoid_battle_time
        serverBuffInfo.begin_time = g_clock.getCurServerTime()
        serverBuffInfo.num = 0
      
    else
        if item_buffer_data then
            for key, var in pairs(item_buffer_data) do
                for _, buffId in ipairs(buffTempInfo.buff_id) do
                    if tonumber(key) == buffId then
                       serverBuffInfo = var
                       break
                    end
                end
                if serverBuffInfo then
                    break
                end
            end
        end
    end
    return serverBuffInfo
end
    
    
cityBufferLayer.getSeverBuffInfo = function(buffTempInfo,isGet)
    if item_buffer_data == nil or isGet then
         reqItemBuff()
    end
    
    return _getSeverBuffInfo(buffTempInfo)
end

cityBufferLayer.getSeverBuffInfoAsync = function(buffTempInfo,callback)
    assert(callback ~= nil,"expect an function param at param 2")
    local resultHandler = function(result,msgData)
        local data = nil
        if result == true then
            data = _getSeverBuffInfo(buffTempInfo)
        end
        callback(result,data)
    end
    _reqItemBuffAsync(resultHandler)
end


function cityBufferLayer:createLayer()
    reqItemBuff()
	if item_buffer_data then
	   g_sceneManager.addNodeForUI( cityBufferLayer:create())
    end
end

function cityBufferLayer:ctor()
    cityBufferLayer.super.ctor(self)
    self:InitUI()
end

function cityBufferLayer:InitUI()
    self.layout = self:loadUI("fCityGain_main.csb")
    g_resourcesInterface.installResources(self.layout)
    self.root = self.layout:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
    --关闭按钮
	self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    --标题
    self.root:getChildByName("Text_1"):setString(g_tr( "city_buffer_title" ))
    self.list = self.root:getChildByName("ListView_1")

   
    print("Build_buff_typeConfig",#g_data.build_buff_type)

    self:rebuildList()

end
--初始化列表
function cityBufferLayer:rebuildList()
    --道具BUFF配置表
    local data_config = g_data.build_buff_type
    if data_config == nil then
        return
    end
    
    self.list:removeAllChildren()
    self.list:setItemsMargin(10)

    local itemCount = math.ceil( table.nums(data_config) / 2 )
    local modItem = cc.CSLoader:createNode("fCityGain_list.csb")
    local index = 1
    
    --print("need create buffer_num",itemCount)
    
    for i = 1, itemCount do
        local layout = ccui.Layout:create()
        layout:setContentSize( cc.size( self.list:getContentSize().width,modItem:getContentSize().height ))
        for j = 1, 2 do
            local cdt = clone(data_config[index])
            if cdt then
               
                local item = modItem:clone()
                local itemroot = item:getChildByName("scale_node")
                item:setPosition( cc.p( (j - 1) * item:getContentSize().width,0 ) )
                layout:addChild(item)

                local name = itemroot:getChildByName("Text_1")
                name:setString(g_tr( cdt.name ))

                local dec = itemroot:getChildByName("Text_0")
                dec:setString(g_tr( cdt.dec ))
                
                itemroot:getChildByName("Image_3"):loadTexture(g_resManager.getResPath(cdt.res_down))
                
                local pic = itemroot:getChildByName("Image_3_0")
                pic:loadTexture(g_resManager.getResPath(cdt.res))
                
                itemroot:getChildByName("Image_3_1"):loadTexture(g_resManager.getResPath(cdt.res_up))
                
                local serverBuffInfo = cityBufferLayer.getSeverBuffInfo(cdt)
                dump(serverBuffInfo)

                itemroot:getChildByName("Image_2"):setVisible(false)

                local buffIsWorking = false
                local currentTime = g_clock.getCurServerTime()
                if serverBuffInfo then
                    local secondsLeft = serverBuffInfo.expire_time - currentTime
                    buffIsWorking = secondsLeft > 0
                end
                
                itemroot:getChildByName("LoadingBar_1"):setVisible(buffIsWorking and cdt.buff_id[1] ~= 9)
                itemroot:getChildByName("Text_15"):setVisible(buffIsWorking)
                if buffIsWorking then
                    
                    if cdt.buff_id[1] ~= 9 then
                        local addStr = ""
                        if g_data.buff_temp[cdt.buff_id[1]] then
                            local buff_id = g_data.buff_temp[cdt.buff_id[1]].buff_id
                            local buff_type = g_data.buff[buff_id].buff_type
                            if buff_type == 1 then
                                addStr = ((serverBuffInfo.num/10000)*100).."%%"
                            elseif buff_type == 2 then
                                addStr = serverBuffInfo.num..""
                            end
                            dec:setString(g_tr(cdt.dec_start,{buff_value = addStr}))
                        end
                    end
                    
                    local projName = "Effect_ZhuChengZengYiKuang"
                    local armature , animation = g_gameTools.LoadCocosAni("anime/"..projName.."/"..projName..".ExportJson", projName)
                    pic:addChild(armature)
                    animation:play("Animation1")
                    armature:setPosition(cc.p(pic:getContentSize().width/2,pic:getContentSize().height/2))
                
                    local percent = (currentTime - serverBuffInfo.begin_time)/(serverBuffInfo.expire_time - serverBuffInfo.begin_time)*100
                    itemroot:getChildByName("LoadingBar_1"):setPercent(100-percent)
                    itemroot:getChildByName("Text_15"):setString(g_gameTools.convertSecondToString(serverBuffInfo.expire_time - currentTime))
                    
                    local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                          local currentTime = g_clock.getCurServerTime()
                          local secondsLeft = serverBuffInfo.expire_time - currentTime
                          if secondsLeft < 0 then
                              secondsLeft = 0
                              item:stopAllActions()
                              itemroot:getChildByName("LoadingBar_1"):setVisible(false)
                              itemroot:getChildByName("Text_15"):setVisible(false)
                          else
                              local percent = (currentTime - serverBuffInfo.begin_time)/(serverBuffInfo.expire_time - serverBuffInfo.begin_time)*100
                              itemroot:getChildByName("LoadingBar_1"):setPercent(100-percent)
                              itemroot:getChildByName("Text_15"):setString(g_gameTools.convertSecondToString(secondsLeft))
                          end
                    end))
                    local action = cc.RepeatForever:create(seq)
                    item:runAction(action)
                end
                
                itemroot:getChildByName("Image_6"):setVisible(itemroot:getChildByName("LoadingBar_1"):isVisible())
                
                itemroot:addClickEventListener(function()
                    self:openBuffLayer(cdt,serverBuffInfo)
                end)

            end
            index = index + 1
        end
        
        
        self.list:pushBackCustomItem(layout)
    end
end

function cityBufferLayer:openBuffLayer(data,serverBuffInfo)
    local updateHandler = function(item_buffer_sdata)
        item_buffer_data = item_buffer_sdata
        self:rebuildList()
    end
    local cityGainAlertLayer = require("game.uilayer.map.cityGainLayer"):create(data,serverBuffInfo,updateHandler)
    g_sceneManager.addNodeForUI(cityGainAlertLayer)
end


function cityBufferLayer:onEnter()
    print("cityBufferLayer onEnter")
end

function cityBufferLayer:onExit()
    print("cityBufferLayer onExit")
    item_buffer_data = nil
end 

return cityBufferLayer