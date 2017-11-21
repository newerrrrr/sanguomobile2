--region NewFile_1.lua
--Author : luqingqing
--Date   : 2015/11/3
--此文件由[BabeLua]插件自动生成

local BagContentView = class("BagContentView", require("game.uilayer.bag.BagBaseView"))

function BagContentView:ctor(callback)
    self.callback = callback

    self.count = 7
    self.uilist = {}
    self.sortList = {}
    self.bagData = {}

    self.mode = require("game.uilayer.bag.BagMode").new()

    self.layer = cc.CSLoader:createNode("Useprops_Panel01.csb")
    self:addChild(self.layer)
    self.root = self.layer:getChildByName("scale_node")
    self.ListView_1 = self.root:getChildByName("ListView_1")

    self:setData()
    self:initFun()
    self:addEvent()
end

function BagContentView:setData()
    self.clickBack  = function(itemData, dropItem)

        self.selectItemData = itemData
        self.dropItem = dropItem
        itemData.item_type = g_Consts.DropType.Resource

        local data = g_data.item[tonumber(self.selectItemData.item_id)]
        if self.selectItemData.item_id ==22203 or data.button_type == 0 then
            local itemView = require("game.uilayer.bag.BagItemNoButtonView").new(itemData)
            g_sceneManager.addNodeForUI(itemView)
        elseif data.button_type == 1 then
            local itemView = require("game.uilayer.bag.BabItemInfoView").new(itemData, self.useItem)
            g_sceneManager.addNodeForUI(itemView)
        end
    end

    self:refresh()
end

function BagContentView:initFun()
    self.closeWin = function()

        self:close()
    end

    self.updateList = function(data)
        local itemData= g_data.item[self.selectItemData.item_id]
        if itemData.item_show_type == 1 then
            --有掉落
            local result = {}
            for i=1, #data.dropItems do
                table.insert(result, {data.dropItems[i].type, data.dropItems[i].id, data.dropItems[i].num})
            end
            local view = require("game.uilayer.task.TaskAwardAlertLayer").new(result)
            g_sceneManager.addNodeForUI(view)
        elseif itemData.item_show_type == 2 then
            if self.selectNumber == 1 then
                g_airBox.show(g_tr("bagUseType2")..g_tr(itemData.item_name))
            else
                g_airBox.show(g_tr("bagUseType2")..g_tr(itemData.item_name).."x"..self.selectNumber)
            end
        elseif itemData.item_show_type == 3 then
            g_airBox.show(g_tr("bagUseType3")..g_tr(itemData.item_name)..g_tr("bagUseSucc"))
        elseif itemData.item_show_type == 4 then
            g_airBox.show(g_tr("bagUseType4")..g_tr(itemData.item_name))
        end

        --宝箱
        if self.selectItemData.item_id == 23400 then
            self:refresh()
        else
            self:update()
        end
    end

    self.useItem = function(itemId, number)
        self.selectNumber = number
        self.selectItem = g_data.item[itemId]

        if itemId == 21200 then
            self.mode:changePosition(self.callback)
        elseif itemId == 21400 then
            if g_AllianceMode.getSelfHaveAlliance() then
                local leader = g_AllianceMode.getLeaderInfo()

                local function callback()
                    local BigMap = require("game.maplayer.worldMapLayer_bigMap")        
                    BigMap.closeSmallMenu()
                    BigMap.closeInputMenu()
                    BigMap.changeBigTileIndex_Manual(cc.p(tonumber(leader.Player.x), tonumber(leader.Player.y)),true)
                end
                require("game.maplayer.changeMapScene").changeToWorld(false, callback)

                if self.callback ~= nil then
                    self.callback()
                end
            else
                g_airBox.show(g_tr("noAllianceTip"))
            end
        else
            self.mode:itemUse(itemId, self.selectNumber, self.updateList)
        end
    end
end

function BagContentView:getDropNum(dropId)
    local num = 0
    local drop = g_data.drop[dropId].drop_data
    for j = 1, #drop do
        num = num + drop[j][3]
    end

    return num
end

function BagContentView:addEvent()
    local function onSelectItem(sender, eventType)
        if eventType == 1 then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            self.index = sender:getCurSelectedIndex()
        end 
    end

    self.ListView_1:addEventListener(onSelectItem)
end

function BagContentView:update()
     self:refresh()
end

function BagContentView:refresh()
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

function BagContentView:initData()
    self.tab = {}

    self.bagData = g_BagMode.GetData()
    if self.bagData == nil then
        return
    end
    self:analyzeData()
    self.sortList = self:sortTable(self.tab)
end

----------------------------------------tool
function BagContentView:analyzeData()
    for key, value in pairs(self.bagData) do
        local iData = g_data.item[tonumber(value.item_id)]
        if iData and iData.item_type == 2 then
            self.tab[tonumber(value.item_id)] = value
        else 
            print(" invalid item id: ", value.item_id)
        end
    end
end

function BagContentView:sortTable(array)
    local key_test = {}
    for key, value in pairs(array) do
        table.insert(key_test, key)
    end
    table.sort(key_test)
    return key_test
end

function BagContentView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function BagContentView:unschedule(action)
  self:stopAction(action)
end

return BagContentView

--endregion
