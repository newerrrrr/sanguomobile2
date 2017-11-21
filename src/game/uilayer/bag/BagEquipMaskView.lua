--region BagEquipMaskView.lua
--Author : luqingqing
--Date   : 2015/11/27
--此文件由[BabeLua]插件自动生成

--g_MasterEquipMode.GetData()
local BagEquipMaskView = class("BagEquipMaskView", require("game.uilayer.bag.BagBaseView"))

function BagEquipMaskView:ctor(callback)
    
    self.count = 7
    self.uilist = {}
    self.data = {}
    self.sortList = {}
    self.callback = callback

    self.layer = cc.CSLoader:createNode("Useprops_Panel01.csb")
    self:addChild(self.layer)

    self.root = self.layer:getChildByName("scale_node")
    self.ListView_1 = self.root:getChildByName("ListView_1")

    self.mode = require("game.uilayer.bag.BagMode").new()

    self:initFun()
    self:refresh()
end

function BagEquipMaskView:initFun()
    self.funBack = function()
        if self.callback ~= nil then
            self.callback()
        end
    end

    self.saleSuc = function()
        g_airBox.show(g_tr("bagSaleSuc"))
        self:refresh()
    end

    self.saleMask = function(data)

        local masterData = g_data.equip_master[data.equip_master_id]

        g_msgBox.show(g_tr("bagSaleInfo", {name=g_tr(masterData.equip_name), num=masterData.selldrop}), nil, 2, 
            function(event) 
                if event == 0 then --确认
                    self.mode:saleItem(data.id, self.saleSuc)
                end 
            end, 
        1)
    end

    self.clickBack  = function(itemData)
        local view = require("game.uilayer.bag.BagEquipMaskInfoView").new(itemData, self.funBack, self.saleMask)
        g_sceneManager.addNodeForUI(view)
    end
end

function BagEquipMaskView:initData()
    self.data = g_MasterEquipMode.GetData()

    if self.data == nil then
        return
    end

    self.result = {}

    for i=1, #self.data do
        if self.data[i].status == 0 then
            table.insert(self.result, self.data[i])
        end
    end

    if #self.result >= 2 then
         self.sortList = self:sortTable(self.result)
    else
        self.sortList = self.result
    end
end

function BagEquipMaskView:refresh()
    local dataList = {}
    local data = {}

    self:initData()

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

    self:loadItem(dataList, 3, self.uilist, self.clickBack)
end

----------------------------------------tool
function BagEquipMaskView:sortTable(array)
    table.sort(array, function(a, b)
        local ad = g_data.equip_master[a.equip_master_id].priority
        local bd = g_data.equip_master[b.equip_master_id].priority

        return ad < bd
    end)

    return array
end

return BagEquipMaskView

--endregion
