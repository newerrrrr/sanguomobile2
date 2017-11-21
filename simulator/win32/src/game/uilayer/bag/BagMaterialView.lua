--region BagMaterialView.lua
--Author : luqingqing
--Date   : 2015/12/1
--此文件由[BabeLua]插件自动生成

--背包材料

local BagMaterialView = class("BagMaterialView", require("game.uilayer.bag.BagBaseView"))

--srcType:来源: 1:铁匠铺合成, 2:其他..
function BagMaterialView:ctor(callback, srcType)
    self.callback = callback
    self.srcType = srcType 
    self.count = 7

    self.uilist = {}
    self.sortList = {}
    self.bagData = {}

    self.layer = cc.CSLoader:createNode("Useprops_Panel01.csb")
    self:addChild(self.layer)

    self.root = self.layer:getChildByName("scale_node")

    self.ListView_1 = self.root:getChildByName("ListView_1")

    self:setData()
end

function BagMaterialView:setData()
    self.clickBack  = function(itemData)
        if self.callback ~= nil then
            self.callback(itemData.item_id)
        end
    end

    self:refresh()
end

function BagMaterialView:refresh()
    self:initData()

    local dataList = {}
    local data = {}


    for i=1, #self.sortList do
        table.insert(data, self.tab[self.sortList[i]])
        if #data >= self.count then
            table.insert(dataList, data)
            data = {}
        end
    end

    if #data ~=0 and #data < self.count then
        table.insert(dataList, data)
    end

    self:loadItem(dataList, 1, self.uilist, self.clickBack)
end

function BagMaterialView:initData()
    self.tab = {}

    self.bagData = g_BagMode.GetData()
    if self.bagData == nil then
        return
    end
    self:analyzeData()
    self.sortList = self:sortTable(self.tab)

end

----------------------------------------tool
function BagMaterialView:analyzeData()
    for key, value in pairs(self.bagData) do 
        local iData = g_data.item[value.item_id]
        if iData then 
            if self.srcType == 1 then --来自铁匠铺合成,不包含红装碎片和御龙装备材料
                if iData.item_type == 3 and (iData.id < 51001 or iData.id > 51006) then 
                    self.tab[value.item_id] = value 
                end 
            else 
                if (iData.item_type == 3 or iData.item_type == 6) then --材料和红装碎片
                    self.tab[value.item_id] = value 
                end 
            end 
        else 
            print(" invalid item id: ", value.item_id)
        end
    end
end

function BagMaterialView:sortTable(array)
    local key_test = {}
    for key, value in pairs(array) do
        table.insert(key_test, key)
    end
    table.sort(key_test)
    return key_test
end

return BagMaterialView
--endregion
