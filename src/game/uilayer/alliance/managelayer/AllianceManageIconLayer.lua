local AllianceManageIconLayer = class("AllianceManageIconLayer",function()
    return cc.Layer:create()
end)

function AllianceManageIconLayer:ctor()
    local uiLayer = cc.CSLoader:createNode("alliance_manage_icon.csb")
    self:addChild(uiLayer)
    uiLayer:getChildByName("text_1"):setString(g_tr("currentAllianceIcon"))--当前联盟图标
    uiLayer:getChildByName("text_2"):setString(g_tr("newAllianceIcon"))--选择新图标
		
	local currentIcon = g_AllianceMode.getAllianceIconId()
	local iconInfo = g_data.alliance_flag[currentIcon]
	uiLayer:getChildByName("pic_current"):loadTexture(g_resManager.getResPath(iconInfo.res_flag))
    
    self._listView = uiLayer:getChildByName("ListView_1")

    local icons = {}
    for key, var in pairs(g_data.alliance_flag) do
        if var.type == 1 then
           table.insert(icons,var)
        end
    end

    local updateListItem = function(item,itemData)
        print(g_resManager.getResPath(itemData.res_flag))
        item:getChildByName("ico_1"):loadTexture(g_resManager.getResPath(itemData.res_flag))
    end
            
    local touchedHandler =  function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("clicked")
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            local item = sender
            local itemData = item.data
            uiLayer:getChildByName("pic_current"):loadTexture(g_resManager.getResPath(itemData.res_flag))
            self._currentSelectedItemData = itemData
        end
    end
       
    local iconItem = cc.CSLoader:createNode("alliance_manage_icon_item.csb")
    local itemCapacity = 5
    local count = 1
    local maxRow = math.ceil(#icons/itemCapacity)
    local widthDistance = 5
    local heightDistance = 5
    local itemSize = iconItem:getChildByName("ico_1"):getContentSize()
    local rowSize = cc.size((itemSize.width + widthDistance) * itemCapacity,itemSize.height)
    self._listView:setItemsMargin(heightDistance)
    
    for i = 1, maxRow do
        local rowContainer = ccui.Widget:create()
        rowContainer:setContentSize(rowSize)
        for j = 1, itemCapacity do
            if count <= #icons then
                local item = iconItem:clone()
                rowContainer:addChild(item)
                updateListItem(item,icons[count])
                item:getChildByName("ico_1").data = icons[count]
                item:getChildByName("ico_1"):addTouchEventListener(touchedHandler)
                item:setPositionX((itemSize.width + widthDistance) * (j-1) + 5)
                count = count + 1
            end
        end
        self._listView:pushBackCustomItem(rowContainer)
    end

    local costNum = 0
    local costType = 0
    local costId = 107
    for key, var in pairs(g_data.cost) do
      if costId == var.cost_id then
         costNum = var.cost_num
         costType = var.cost_type
         break
      end
    end
    assert(costType > 0)
    uiLayer:getChildByName("text_price"):setString(string.formatnumberthousands(costNum))--price
    uiLayer:getChildByName("ico_gold"):loadTexture(g_resManager.getResPath(g_Consts.CurrencyDefaultId + costType))
    
	local saveBtn = uiLayer:getChildByName("btn_save")
	saveBtn:getChildByName("Text"):setString(g_tr("modification")) --修改
	saveBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if self._currentSelectedItemData == nil then
                g_airBox.show(g_tr("selectIconTip"))
                return
            end
            local resultHandler = function(result, msgData)
                if result then
                    print("success")
                    g_AllianceMode.setBaseData(msgData)
                    g_airBox.show(g_tr("changeSuccess"))
                    --self:updateView()
                else
                    --g_airBox.show(g_tr("changeFail"))
                end
            end
            
            local data = {}
            data.type = 4
            data.icon_id = self._currentSelectedItemData.id
    
            g_AllianceMode.reqAlterGuild(data,resultHandler)
            self._currentSelectedItemData = nil
        end
    end)
		
end

return AllianceManageIconLayer