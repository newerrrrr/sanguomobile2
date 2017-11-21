local GeneralIllustratedLayer = class("GeneralIllustratedLayer",function()
    return cc.Layer:create()
end)

local currentPageIdx = 0
function GeneralIllustratedLayer:ctor(generals) --generals info array
    local uiLayer =  g_gameTools.LoadCocosUI("Pub_generals_list.csb",5)
    self:addChild(uiLayer)
    local baseNode = uiLayer:getChildByName("scale_node")
    self._baseNode = baseNode
    
    local closeBtn = baseNode:getChildByName("Button_1")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent(true)
        end
    end)
    
    currentPageIdx = 0
    
    --切换标签按钮
    local tabBtns = {}
    table.insert(tabBtns,baseNode:getChildByName("Button_juntuan01"))
    table.insert(tabBtns,baseNode:getChildByName("Button_juntuan02"))
    table.insert(tabBtns,baseNode:getChildByName("Button_juntuan03"))
    table.insert(tabBtns,baseNode:getChildByName("Button_juntuan04"))
    
    self._tabBtns = tabBtns
    for key, btn in ipairs(tabBtns) do
        btn.idx = key
        btn:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self:tabPageHandler(sender.idx)
            end
        end)
        
        --reset buttuon text
        btn:getChildByName("Text_1"):setString(g_tr("country"..key))
    end

    self._generals = generals or {}
    self:tabPageHandler(1)
    
    
end

function GeneralIllustratedLayer:tabPageHandler(idx,forceRefresh)
    if currentPageIdx == idx and not forceRefresh then
        return
    end
    currentPageIdx = idx
    
    local tabBtns = self._tabBtns
    --切换按钮高亮状态
    for key, btn in pairs(tabBtns) do
        btn:setEnabled(true)
    end
    if tabBtns[currentPageIdx] then
        tabBtns[currentPageIdx]:setEnabled(false)
    end
    
    local listView = self._baseNode:getChildByName("ListView_1")
    listView:removeAllChildren()
    
    local currentCountryGenerals = {}
    for key, generalInfo in pairs(self._generals) do
        if generalInfo.general_country == idx then
            table.insert(currentCountryGenerals,generalInfo)
        end
    end
    
    --创建武将头像列表
    if #currentCountryGenerals > 0 then
        local itemCapacity = 7
        local count = 1
        local maxRow = math.ceil(#currentCountryGenerals/itemCapacity)
        local widthDistance = 60
        local heightDistance = 5
        
        listView:setItemsMargin(heightDistance)
        
        for i = 1, maxRow do
            local rowContainer = ccui.Widget:create()
            --rowContainer:setContentSize(rowSize)
            local itemSize = cc.size(103,103)
            for j = 1, itemCapacity do
                 if count <= #currentCountryGenerals then
                      local item = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.General,currentCountryGenerals[count].id,0)
                      item:setNameVisible(true)
                      item:setCountEnabled(false)
                      itemSize = item:getContentSize()
                      rowContainer:addChild(item)
                      item:setPositionX((itemSize.width + widthDistance) * (j-1) + itemSize.width/2 + 35)
                      item:setPositionY(itemSize.height/2 + 40)
                      
                      if currentCountryGenerals[count].lockInfo ~= nil then
                          item:getIconRender():getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
                          local buildInfo = currentCountryGenerals[count].lockInfo
                          local str = g_tr(buildInfo.build_name)..buildInfo.build_level.."级解锁"
                          local size = item:getIconRender():getContentSize()
                          local fontSize = 24
                          local color = cc.c3b(255, 255, 255)
                          local text = ccui.Text:create(str, "cocos/cocostudio_res/simhei.ttf", fontSize)
                          text:setTextAreaSize(cc.size(size.width - 10, 0))
                          text:ignoreContentAdaptWithSize(false)
                          text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                          text:enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,1),2)
                          --text:setAnchorPoint(cc.p(0.5, 0.5))
                          text:setPosition(cc.p(size.width/2, size.height/2))
                          
                          text:setTextColor(color) 
                          item:getIconRender():addChild(text)
                          text:setString(str)
                      end

                      item.id = currentCountryGenerals[count].id
                      item:setTouchEnabled(true)
                      item:addTouchEventListener(function(sender,eventType)
                          if eventType == ccui.TouchEventType.ended then
                              print("clicked",sender.id)
                              g_sceneManager.addNodeForUI(require("game.uilayer.common.GeneralInfoLayer"):create(sender.id))
                          end
                      end)
                      count = count + 1
                 end
            end
            local rowSize = cc.size((itemSize.width + widthDistance) * itemCapacity,itemSize.height + 45)
            rowContainer:setContentSize(rowSize)
            listView:pushBackCustomItem(rowContainer)
        end
        listView:jumpToTop()
    end
    
end

return GeneralIllustratedLayer