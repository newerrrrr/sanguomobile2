local BuildingGrarrisonLayer = class("BuildingGrarrisonLayer",function()
  return cc.Layer:create()
end)

local baseNode = nil
local cdLong = 0
function BuildingGrarrisonLayer:ctor(buildingId,serverData)
    
    self._serverData = serverData
    --dump(serverData)
    self._currentEffectItem = nil
    --load cocos studio ui
    local node = g_gameTools.LoadCocosUI("zhushouwujiang.csb",5)
    self:addChild(node)
    g_resourcesInterface.installResources(node)
    baseNode = node:getChildByName("scale_node")
    
    self:registerScriptHandler(function(eventType)
      if eventType == "enter" then
          g_guideManager.execute()
      elseif eventType == "exit" then
      end 
    end )
    
    
    --关闭本页
    local btnClose = baseNode:getChildByName("Button_xhao")
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
            self:removeFromParent()
        end
    end)
    
    baseNode:getChildByName("Text_wenz"):setString(g_tr("grarrisGeneralsEmpty"))
    baseNode:getChildByName("Text_26"):setString(g_tr("confirm"))
    
    --建筑属性列表
    local buildAttrListView = baseNode:getChildByName("Panel_1"):getChildByName("ListView_2")
    self._buildAttrListView = buildAttrListView
    local propertyItem = cc.CSLoader:createNode("Garrison_Part.csb")
    local listSize = propertyItem:getChildByName("scale_node"):getContentSize()
    propertyItem:setContentSize(listSize)
    buildAttrListView:setItemModel(propertyItem)
    buildAttrListView:setItemsMargin(2.0)

    --general list 
    local listView = baseNode:getChildByName("ListView_1")
    self._listView = listView
    local listItem = cc.CSLoader:createNode("zhushouwujiang01.csb")
    listItem:getChildByName("scale_node"):getChildByName("Image_1_0"):setVisible(false)
    listView:setItemModel(listItem)
    
    local function listViewEvent(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)

            print("touched:",sender:getCurSelectedIndex())
            
            local item = listView:getItem(sender:getCurSelectedIndex())
            if self._lastSelectedItem ~= nil then
                self:highLightItem(self._lastSelectedItem,false)
            end
            
            local allbuffs = self._allbuffs
            local plusValues = g_GeneralMode.getPlayerBuffValue(buildingId,item.serverGeneralInfo)
            print("local general and equip buffs")
            dump(plusValues)
            for _outputId, var in pairs(plusValues) do
            	for outputId, item in pairs(self._plusList) do
            	  if _outputId == outputId then
            	  --if g_data.output_type[outputId].buff_id == buffId then
            	    local buffId = g_data.output_type[outputId].buff_id
            	    if buffId > 0 then
                        local buffKeyName = g_data.buff[buffId].name
                        local buffValue = 0
                        local plusType = g_data.output_type[outputId].plus_type
                        if allbuffs and allbuffs[buffKeyName] then
                            if tonumber(allbuffs[buffKeyName].v) > 0 then
                               buffValue = allbuffs[buffKeyName].v
                            end
                        end
    
                        local outputGroup = item.outputGroup
                        local type = outputGroup[1]
                        assert(type == outputId)
                        local value = outputGroup[2]
                        
                        if plusType == 1 then
                            buffValue = value * buffValue / 10000
                        elseif plusType == 2 then
                            --百分比
                            buffValue = buffValue/10000
                        elseif plusType == 3 then
                            --直接固定值
                        end
                	    
                	    local numType = g_data.output_type[outputId].num_type
                	    local plusStr = ""
                	    print("type:"..type,"general +"..var,"buff +"..buffValue)
                	    local total = var + buffValue
                	    if numType == 1 then
                	       plusStr = "+"..(total*100).."%"
                	    elseif numType == 2 then
                	       plusStr = "+"..math.ceil(total)
                	    end
                	    
                	    if buffKeyName == "protect_plus" and value == 0 then --如果仓库基础属性值是0 则不显示加成
                	       plusStr = ""
                	    --[[elseif buffKeyName == "wall_defense_limit_plus" then --城墙防御值不显示加成
                           plusStr = ""]]
                	    end
                	    
                        item:getChildByName("scale_node"):getChildByName("Text_03")
                        :setString(plusStr)
                  end
                  --break --注释掉break 因为建筑（比如仓库）有可能多个output type 对应同一个buff id
                end
              end 
            end
            
            self._lastSelectedItem = item
            
            self:updateSetBtnStatus()
            
            self:highLightItem(self._lastSelectedItem,true)
            
            g_guideManager.execute()
        end
    end
    listView:addEventListener(listViewEvent)
    listView:setItemsMargin(1.5)

    --reset ui text
    baseNode:getChildByName("Text_1"):setString(g_tr("garrisonGenerals")) --驻守武将
    --baseNode:getChildByName("Panel_1"):getChildByName("Text_5"):setString(g_tr("stunt")) --特技
  
    local doSetGeneral = function(isRemove)
            local item = self._lastSelectedItem
            local resultHandler = function(result, msgData)
                if result then
                     print("success")
                     
                     --dump(msgData)
                     self:setGrarrisonStatus(item,true)
                     
                     if isRemove == true then
                         g_airBox.show(g_tr("removeSuccess"))
                     else
                         g_airBox.show(g_tr("grarrisSuccess"))
                         if g_guideManager.execute() then
                            self:removeFromParent()
                            return
                         end
                     end
                     
                     self._serverData = msgData
					
                     g_PlayerBuildMode.updateSingleBuildData(msgData,msgData.position)
					 require("game.maplayer.homeMapLayer").updateBuildingWithMsgDataAndPlace(msgData,msgData.position)
					 
                     self:updateView()
                     
                     if not isRemove then
                        self._listView:scrollToTop(0.5,true)
                     end
                     self:updateSetBtnStatus()
                     
                else
                    --g_airBox.show("grarrisFail")
                end
            end
            
            local generalId = item.serverGeneralInfo.general_id
            if isRemove == true then
                generalId = 0
            end
            
            g_BuffMode.clearGeneralBuffByPosition(serverData.position)
            --请求武将驻守
            g_sgHttp.postData("build/setGeneral",{generalId = generalId,position = serverData.position,steps = g_guideManager.getToSaveStepId()},resultHandler)
    end
    
    local makeSureBtnHandler = function()
        local item = self._lastSelectedItem
        if item == nil then
            g_airBox.show(g_tr("generalGarrisonSelectTip"))
            return
        end
        if item.serverGeneralInfo.build_id 
        and item.serverGeneralInfo.build_id > 0 
        and self._isCancleModle == true
        then
            --if self._serverData.build_id > 0 and item.serverGeneralInfo.build_id ~= self._serverData.id then
                local buildServerInfo = g_PlayerBuildMode.FindBuild_ID(item.serverGeneralInfo.build_id)
                local buildConfigId = buildServerInfo.build_id
                local buildName = g_tr(g_data.build[buildConfigId].build_name)
                g_msgBox.show(g_tr("generalGarrisonTip"),nil,nil,function(event)
                    if event == 0 then
                        doSetGeneral(true)
                    end
                end,1)
            --end
        else
            doSetGeneral()
        end
    end
    
    local btnMakeSure = baseNode:getChildByName("Button_1")
    btnMakeSure:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            makeSureBtnHandler()
        end
    end)
    
    g_guideManager.registComponent(9999997,btnMakeSure)
    
    --g_BuffMode.RequestData()
    self._allbuffs = g_BuffMode.GetData() or {}
    
    self:changeBuilding(buildingId)
end

function BuildingGrarrisonLayer:updateSetBtnStatus()

    local currentTime = g_clock.getCurServerTime()
    local targetTime = self._serverData.last_change_general_time + cdLong
    if self._serverData.last_change_general_time > 0 
    and targetTime > currentTime then --时间没到
        baseNode:getChildByName("Button_1"):setVisible(false)
        
        --cd
        local timeLabel = baseNode:getChildByName("Text_26")
        timeLabel:stopAllActions()
        local updateTimeStr = function()
            local currentTime = g_clock.getCurServerTime()
            local secondsLeft = targetTime - currentTime
            if secondsLeft < 0 then
                secondsLeft = 0
                timeLabel:stopAllActions()
                self:updateSetBtnStatus()
            else
                timeLabel:setString(g_tr("grarrisGeneralsCDTip",{cdtime = g_gameTools.convertSecondToString(secondsLeft)}))
            end
        end
        
        local seq = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(updateTimeStr))
        local action = cc.RepeatForever:create(seq)
        timeLabel:runAction(action)
        updateTimeStr()
    
        return
    else --时间到了
        baseNode:getChildByName("Button_1"):setVisible(true)
    end

    if not self._lastSelectedItem then
        return
    end
    
    baseNode:getChildByName("Text_26"):setString(g_tr("confirm"))
    self._isCancleModle = false
    if self._lastSelectedItem.serverGeneralInfo.build_id == self._serverData.id then
       self._isCancleModle = true
       baseNode:getChildByName("Text_26"):setString(g_tr("remove"))
    end
end

--list item helper
function BuildingGrarrisonLayer:setGrarrisonStatus(item,isSelected)
    if not item then
        return 
    end
    
    item:getChildByName("scale_node"):getChildByName("Panel_zhushou"):setVisible(isSelected)
    item:getChildByName("scale_node"):getChildByName("Image_1_0_0"):setVisible(isSelected)
end

function BuildingGrarrisonLayer:highLightItem(item,isSelected)
    if not item then
        return 
    end
    item:getChildByName("scale_node"):getChildByName("Image_1_0"):setVisible(isSelected)
end

function BuildingGrarrisonLayer:updateItemByGeneralServerInfo(item,generalInfo)
    --Info sample
    --{"id":36,"general_id":1003,"exp":0,"lv":1,"weapon_id":0,"armor_id":0,"horse_id":0,"build_id":0,"army_id":0,"stay_start_time":0,"status":0},
    if not item then
        return 
    end
    
    local general = g_GeneralMode.GetBasicInfo(generalInfo.general_id,1)
    assert(general)
    
    local atBuildId = generalInfo.build_id or 0
    --标记当前建筑正在驻守的武将
    local isAtCurrentBuild = false
    if atBuildId > 0 then
        local buildServerInfo = g_PlayerBuildMode.FindBuild_ID(atBuildId)
        local buildConfigId = buildServerInfo.build_id
        if buildConfigId == self._serverData.build_id then
            isAtCurrentBuild = true
        end
    end

    self:setGrarrisonStatus(item, isAtCurrentBuild)
    item.serverGeneralInfo = generalInfo
  
    local node = item:getChildByName("scale_node")
    node:getChildByName("Text_zhuangt01"):setString(g_tr("general")) --武将
    node:getChildByName("Text_zhuangt01"):setVisible(false)
    node:getChildByName("Text_zhuangt02"):setVisible(false)
    
    node:getChildByName("Text_5_0"):setString(g_tr(general.general_name)) --武将名称
--    node:getChildByName("Text_5_0_0"):setString("Lv"..generalInfo.lv) --武将等级
    node:getChildByName("Text_zhuangt01"):setString(g_tr("state")) --状态
    if atBuildId > 0 then
        node:getChildByName("Text_zhuangt02"):setString(g_tr("generalGarrison")) --状态描述
    else
        node:getChildByName("Text_zhuangt02"):setString("")
    end
    
    node:getChildByName("Text_teji"):setVisible(false)
    node:getChildByName("Text_teji"):setString(g_tr("equipStunt")) --特技

    --node:getChildByName("Image_touxiang"):loadTexture(g_resManager.getResPath(general.general_icon))
    node:getChildByName("Image_touxiang"):removeAllChildren()
    
    local size = node:getChildByName("Image_touxiang"):getContentSize()
    local item = require("game.uilayer.common.DropItemView"):create(g_Consts.DropType.General,general.id,generalInfo.lv)
    --item:setCountEnabled(false)
    item:showGeneralServerStarLv(generalInfo.star_lv)
    node:getChildByName("Image_touxiang"):addChild(item)
    item:setPosition(cc.p(size.width/2,size.height/2))

--    for i=1, #general.general_skill do
--    	node:getChildByName("Panel_tj0"..i):setVisible(true)
--    	local skillInfo =  g_data.general_skill[general.general_skill[i]]
--    	assert(skillInfo)
--    	node:getChildByName("Panel_tj0"..i):getChildByName("Text_tj"):setString(g_tr(skillInfo.general_skill_name))
--    end

    local panles = {}
    local panlesPositions = {}
    for i = 1, 4  do
      local panleNode = node:getChildByName("Panel_tj0"..i)
      panleNode:setVisible(false)
    	table.insert(panles,panleNode)
    	table.insert(panlesPositions,cc.p(panleNode:getPosition()))
    end
    
    local listView = node:getChildByName("ListView_1")
    listView:setTouchEnabled(false)
    listView:setItemsMargin(-6.0)
    listView:removeAllItems()
    
    local weaponId = generalInfo.weapon_id
    local armorId = generalInfo.armor_id
    local horseId = generalInfo.horse_id
    local zuoJiId = generalInfo.zuoji_id
    
    local equipmentIds = {weaponId,armorId,horseId,zuoJiId}
    for key, equipmentId in ipairs(equipmentIds) do
         local equipmentInfo =  g_data.equipment[equipmentId]
         if equipmentInfo then
             for key, equip_skill_id in pairs(equipmentInfo.equip_skill_id) do
                 local equipSkillInfo = g_data.equip_skill[equip_skill_id]
                 if equipSkillInfo.equip_arm_type == 5 then
                    local num = equipSkillInfo.num
                    local buffId = equipSkillInfo.skill_buff_id[1]
                    local numberType = g_data.buff[buffId].buff_type
                    local plusStr = ""
                    if numberType == 1 then --万分比
                        plusStr = ""..(num/10000*100).."%%"
                    elseif numberType ==2  then --具体值
                        plusStr = ""..num
                    end
                    
                    local descStr = g_tr(equipSkillInfo.skill_description,{num = plusStr})
                    local item = nil
                    if equipmentId == weaponId then
                        item = node:getChildByName("Panel_tj01"):clone()
                    elseif equipmentId == armorId then
                        item = node:getChildByName("Panel_tj02"):clone()
                    elseif equipmentId == horseId then
                        item = node:getChildByName("Panel_tj03"):clone()
                    elseif equipmentId == zuoJiId then
                        item = node:getChildByName("Panel_tj04"):clone()
                    end
                    item:setVisible(true)
                    item:getChildByName("Text_tj"):setString(descStr)
                    

                    local build = g_data.build[self._buildingId]  
                    local isTakeEffect = false
                    for _, build_root in ipairs(equipSkillInfo.equipment_active_on_build) do
                    	if build_root == build.origin_build_id then
                    	   isTakeEffect = true
                    	   break
                    	end
                    end
                    
                    if isTakeEffect then
                        item:getChildByName("Text_tj"):setTextColor(g_Consts.ColorType.Green)
                    end
                    
                    listView:pushBackCustomItem(item)
                 end
             end
         end
    end
    
--    local equipAttrs = {0,0,0,0,0}
--    for key, equipmentId in ipairs(equipmentIds) do
--        local equipmentInfo = g_data.equipment[equipmentId]
--        if equipmentInfo then
--            equipAttrs[1] = equipAttrs[1] + equipmentInfo.force
--            equipAttrs[2] = equipAttrs[2] + equipmentInfo.intelligence
--            equipAttrs[3] = equipAttrs[3] + equipmentInfo.governing
--            equipAttrs[4] = equipAttrs[4] + equipmentInfo.charm
--            equipAttrs[5] = equipAttrs[5] + equipmentInfo.political
--        end
--    end
    local equipAttrs = self:getEquipAttrs(generalInfo)
    
    local build = g_data.build[self._buildingId]    
    local attrType = build.need_general_attribute
    local value = 0
    node:getChildByName("Text_yanse1"):setString(g_tr("attr"..attrType))
--    if attrType == 1 then
--        value = general.general_force
--    elseif attrType == 2 then
--        value = general.general_intelligence
--    elseif attrType == 3 then
--        value = general.general_governing
--    elseif attrType == 4 then
--        value = general.general_charm
--    elseif attrType == 5 then
--        value = general.general_political
--    end
		local generalPropertyList = g_GeneralMode.getGeneralPropertyByServerData(generalInfo)
		value = generalPropertyList[attrType]
    
    value = value + equipAttrs[attrType] --加上装备的属性
    
    node:getChildByName("Text_5_0_0_0"):setString(value.."")
end

function BuildingGrarrisonLayer:updateBuildAttrItem(item,outputGroup)
    local type = outputGroup[1]
    local value = outputGroup[2]
    
    self._plusList[type] = item
    item.outputGroup = outputGroup

    item:getChildByName("scale_node"):getChildByName("Text_1")
    :setString(g_tr(g_data.output_type[type].desc))
    
    if type == 12 then --屯所要加上初始援军数量
        value = value + tonumber(g_data.starting[57].data) 
    end
    
    local valStr = ""
    --local buffId = g_data.output_type[type].buff_id
    --if buffId > 0 then
        --local numType = g_data.buff[buffId].buff_type
        local numType = g_data.output_type[type].num_type
        if numType == 1 then
            valStr = (value / 10000 * 100).."%"
        else
            valStr = value..""
        end
    --end
    
        
    item:getChildByName("scale_node"):getChildByName("Text_02")
    :setString(valStr)
    
    --这里是未选中武将时的其他player buff ，这里不需要加武将buff
    local buffId = g_data.output_type[type].buff_id
    local plusType = g_data.output_type[type].plus_type
    local buffValue = 0
    if buffId > 0 then
        local buffKeyName = g_data.buff[buffId].name
        
        local allbuffs = self._allbuffs
        if allbuffs and allbuffs[buffKeyName] then
            if tonumber(allbuffs[buffKeyName].v) > 0 then
               buffValue = allbuffs[buffKeyName].v
            end
        end
        
        if plusType == 1 then
            buffValue = math.ceil(value * buffValue / 10000)
        elseif plusType == 2 then
            --百分比
            buffValue = buffValue/10000
        elseif plusType == 3 then
            --直接固定值
        end
    end

    
    local plusVal = ""
    if buffValue > 0 then
        if plusType == 1 then
            plusVal = "+"..buffValue
        elseif plusType == 2 then
            plusVal = "+"..(buffValue*100).."%"
        else
            plusVal = "+"..buffValue
        end
    end
    
    item:getChildByName("scale_node"):getChildByName("Text_03")
    :setString(plusVal)
end

function BuildingGrarrisonLayer:changeBuilding(buildingId)

    self._buildingId = buildingId
    
    local build = g_data.build[buildingId]    
    assert(build,"cannot found build,id:"..buildingId)
    --baseNode:getChildByName("Panel_1"):getChildByName("Text_5"):setString(g_tr("stunt")) 
    
    baseNode:getChildByName("Panel_1"):getChildByName("Text_14_0"):setString(g_tr("grarrisTitle"))
    baseNode:getChildByName("Panel_1"):getChildByName("Text_14"):setString(g_tr(build.build_name).." Lv"..build.build_level)
    baseNode:getChildByName("Panel_1"):getChildByName("Text_15"):setString("")
    --baseNode:getChildByName("Panel_1"):getChildByName("Image_5"):loadTexture()
    
    local imageView = baseNode:getChildByName("Panel_1"):getChildByName("Image_5")
    local icon = g_resManager.getRes(build.img)
    if icon then
        imageView:getParent():addChild(icon)
        icon:setPosition(imageView:getPosition())
        local size = imageView:getContentSize()
        if icon:getContentSize().width > size.width then
            local scale = (size.width - 30)/icon:getContentSize().width
            icon:setScale(scale)
        end
    end
    imageView:setVisible(false)
    
    --建筑属性列表
    local buildAttrListView = self._buildAttrListView
    buildAttrListView:removeAllItems()
    --属性信息
    if #build.output > 0 then
        for key, outputGroup in pairs(build.output) do
            buildAttrListView:pushBackDefaultItem()
        end
    end

    self._plusList = {}
    --更新建筑属性列表
    for key, outputGroup in ipairs(build.output) do
        local item = self._buildAttrListView:getItem(key - 1)
        if item then
            self:updateBuildAttrItem(item,outputGroup)
        end
    end
    
    if build.origin_build_id == 2 then --城墙
        buildAttrListView:pushBackDefaultItem()
        local item = self._buildAttrListView:getItem(#build.output)
        item:getChildByName("scale_node"):getChildByName("Image_6"):setVisible(false)
        
        item:getChildByName("scale_node"):getChildByName("Text_1"):setTextColor(cc.c4b(255,255,255,255))
        
        item:getChildByName("scale_node"):getChildByName("Text_1")
        :setString(g_tr("grarrisGeneralsWallEffect"))
        
        item:getChildByName("scale_node"):getChildByName("Text_02")
        :setString("")
    
        item:getChildByName("scale_node"):getChildByName("Text_03")
        :setString("")
    end
    
    
    --武将选择列表
    local listView = self._listView
    listView:removeAllItems()
        
    local generals = self:getGeneralList()
    for i = 1, #generals do
        listView:pushBackDefaultItem()
    end
    
    self:updateView()
end

function BuildingGrarrisonLayer:getEquipAttrs(generalServerData)
    local weaponId = generalServerData.weapon_id
    local armorId = generalServerData.armor_id
    local horseId = generalServerData.horse_id
    local zuojiId = generalServerData.zuoji_id
    
    local equipmentIds = {weaponId,armorId,horseId,zuojiId}
    local equipAttrs = {0,0,0,0,0}
    for key, equipmentId in ipairs(equipmentIds) do
        local equipmentInfo = g_data.equipment[equipmentId]
        if equipmentInfo then
            equipAttrs[1] = equipAttrs[1] + equipmentInfo.force
            equipAttrs[2] = equipAttrs[2] + equipmentInfo.intelligence
            equipAttrs[3] = equipAttrs[3] + equipmentInfo.governing
            equipAttrs[4] = equipAttrs[4] + equipmentInfo.charm
            equipAttrs[5] = equipAttrs[5] + equipmentInfo.political
        end
    end
    return equipAttrs
end

function BuildingGrarrisonLayer:getGeneralList()
    local allGenerals =  g_GeneralMode.GetData() or {}
    local generals = {}
    local garrisonGeneral = nil
    for key, generalInfo in pairs(allGenerals) do
        if generalInfo.build_id == nil
        or generalInfo.build_id <= 0
        then
            table.insert(generals,generalInfo)
        end
        if generalInfo.build_id == self._serverData.id then
            garrisonGeneral = generalInfo
        end
    end
    
--    local build = g_data.build[self._buildingId]    
--    local attrType = build.need_general_attribute
    
--    --按照当前建筑所需的武将属性排序 
--    local sortGeneral = function(a,b)
--        local generalA = g_GeneralMode.GetBasicInfo(a.general_id,a.lv)
--        local generalB = g_GeneralMode.GetBasicInfo(b.general_id,b.lv)
--        
--        local equipAttrsA = self:getEquipAttrs(a)
--        local equipAttrsB = self:getEquipAttrs(b)
--        
--        if attrType == 1 then
--            return generalA.general_force + equipAttrsA[attrType] > generalB.general_force + equipAttrsB[attrType]
--        elseif attrType == 2 then
--            return generalA.general_intelligence + equipAttrsA[attrType] > generalB.general_intelligence + equipAttrsB[attrType]
--        elseif attrType == 3 then
--            return generalA.general_governing  + equipAttrsA[attrType]> generalB.general_governing + equipAttrsB[attrType]
--        elseif attrType == 4 then
--            return generalA.general_charm + equipAttrsA[attrType] > generalB.general_charm + equipAttrsB[attrType]
--        elseif attrType == 5 then
--            return generalA.general_political  + equipAttrsA[attrType]> generalB.general_political + equipAttrsB[attrType]
--        end
--    end
--    

    --按照最终加成总和排序
     local sortGeneral = function(a,b)
        local plusA = 0
        for buffId, var in pairs(g_GeneralMode.getPlayerBuffValue(self._buildingId,a)) do
            plusA = plusA + var
        end
        
        local plusB = 0
        for buffId, var in pairs(g_GeneralMode.getPlayerBuffValue(self._buildingId,b)) do
            plusB = plusB + var
        end
        
        return plusA > plusB
        
     end
     table.sort(generals,sortGeneral)
    
    if garrisonGeneral ~= nil then
        table.insert(generals,1,garrisonGeneral)--将已驻守的武将置顶
    end
    return generals
end

--更新列表显示
function BuildingGrarrisonLayer:updateView()
    print("BuildingGrarrisonLayer:updateView()")
    self._currentEffectItem = nil
    self:updateSetBtnStatus()
    
    --更新武将列表
    local generals = self:getGeneralList()
    local haveGeneral = table.nums(generals) > 0
    baseNode:getChildByName("Text_wenz"):setVisible(not haveGeneral)
    baseNode:getChildByName("Button_1"):setVisible(haveGeneral)
    baseNode:getChildByName("Text_26"):setVisible(haveGeneral)
    
    local items = self._listView:getItems()
    for i =1, #items do
        local generalServerInfo = generals[i]
        local item = self._listView:getItem(i - 1)
        g_guideManager.registComponent(9999601 + (i - 1),item)
        
        if item then
            self:updateItemByGeneralServerInfo(item,generalServerInfo)
            
            if i == 1 and self._lastSelectedItem ~= nil then
                self:highLightItem(self._lastSelectedItem,false)
                self._lastSelectedItem = item
                self:highLightItem(self._lastSelectedItem,true)
            end 
        end
    end
end

return BuildingGrarrisonLayer