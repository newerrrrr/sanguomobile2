--region BagEquipView.lua
--Author : luqingqing
--Date   : 2015/11/27
--此文件由[BabeLua]插件自动生成
local SmithyData = require("game.uilayer.smithy.SmithyData")

local BagEquipView = class("BagEquipView", require("game.uilayer.bag.BagBaseView"))

function BagEquipView:ctor(callback)
    
    self.funBack = function()
        if callback ~= nil then
            callback()
        end
    end

    self.count = 7
    self.uilist = {}
    self.sortList = {}
    self.equipData = {}

    self.layer = cc.CSLoader:createNode("Useprops_Panel01.csb")
    self:addChild(self.layer)

    self.root = self.layer:getChildByName("scale_node")
    self.ListView_1 = self.root:getChildByName("ListView_1")

    self:initData()
    self:setData()
    self:addEvent()
end

function BagEquipView:initData()
    self.equipData = g_EquipmentlMode.GetData()
    
    local tbl = {}

    for i=1, #self.equipData do
        if self.equipData[i].num > 1  then
            local item = g_data.equipment[self.equipData[i].item_id]
            if item then 
                if item.equip_type == 0 then --万能装备保持叠加,其他装备展开
                    table.insert(tbl, self.equipData[i])
                else 
                    for j=1, self.equipData[i].num do
                        table.insert(tbl, self.equipData[i])
                    end
                end 
            end 
        else
            table.insert(tbl, self.equipData[i])
        end
    end

    -- local result = {}
    -- for key, value in pairs(tbl) do
    --     table.insert(result, value)
    -- end

    if self.equipData == nil then
        return
    end

    local item 
    for k, v in pairs(tbl) do 
        item = g_data.equipment[v.item_id]
        if item then 
          tbl[k].quality_id = item.quality_id --供排序用
          tbl[k].equip_type = item.equip_type 
        end 
    end 

    self.sortList = tbl 
    SmithyData:instance():sortEquipByQualityAndType(self.sortList, true)
end

function BagEquipView:setData()
    self.clickBack  = function(itemData)
        if itemData.item_id == 90100 or itemData.item_id == 90200 or itemData.item_id == 90300 or itemData.item_id == 90400 or itemData.item_id == 90500 then

        else
            local info = require("game.uilayer.bag.BagEquipInfoView").new(itemData, self.funBack)
            g_sceneManager.addNodeForUI(info)
        end
    end

    self:refresh()
end

function BagEquipView:refresh()
    local dataList = {}
    local data = {}

    for i=1, #self.sortList do
        table.insert(data, self.sortList[i])
        if #data >= self.count then
            table.insert(dataList, data)
            data = {}
        end
    end

    if #data ~=0 and #data < self.count then
        table.insert(dataList, data)
    end

    self:loadItem(dataList, 2, self.uilist, self.clickBack)
end

function BagEquipView:addEvent()
    local function onSelectItem(sender, eventType)
        if eventType == 1 then
            self.index = sender:getCurSelectedIndex()
        end 
    end

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_shiyong then
                g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                if self.callback ~= nil then
                    self.callback()
                end                
	            g_sceneManager.addNodeForUI(require("game.uilayer.smithy.SmithyBaseLayer").new(SmithyData.viewType.Decompose)) 
            end
        end
    end

    self.ListView_1:addEventListener(onSelectItem)
end

-- ----------------------------------------tool
-- function BagEquipView:sortTable(array)
--     table.sort(array, function(a, b) 
--         local ad = g_data.equipment[a.item_id].priority
--         local bd = g_data.equipment[b.item_id].priority

--         return ad < bd
--     end)

--     return array
-- end

return BagEquipView
--endregion
