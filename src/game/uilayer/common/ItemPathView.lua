--region ItemPathView.lua
--Author : luqingqing
--Date   : 2016/3/7
--此文件由[BabeLua]插件自动生成

local ItemPathView = class("ItemPathView", require("game.uilayer.base.BaseLayer"))

function ItemPathView:onExit()
    if self.closeCallback then
        self.closeCallback()
    end
end

--itemType:g_Consts.DropType
function ItemPathView:ctor(itemType, itemid, callback)
    ItemPathView.super.ctor(self)
    self.itemType = itemType
    self.item = tonumber(itemid)
    self.activity_id = nil
    self.clickCallback = callback

    self.layer = self:loadUI("Smithrecast_resources_main.csb")
    self.mask = self.layer:getChildByName("mask")

    self.root = self.layer:getChildByName("scale_node")
    self.Text_c2 = self.root:getChildByName("Text_c2")
    self.Text_c2:setString(g_tr("getPathTitle"))

    self.ListView_1 = self.root:getChildByName("ListView_1")
    self.Text_2_0 = self.root:getChildByName("Text_2_0")

    self.Text_2_0:setString(g_tr_original("getPathTitle"))
    self.Text_2_0:setString(g_tr_original("clickhereclose"))

    self:initFun()
    self:initUI()
end

--如果设置closeCallback 则点击前往并不会自动关闭该面板；界面最终关闭的时候调用closeCallback
function ItemPathView:keepShowByCloseCallback(closeCallback)
    self.closeCallback = closeCallback
end

function ItemPathView:initUI()
    local itemData = nil
    if self.itemType == g_Consts.DropType.Resource  or self.itemType == g_Consts.DropType.Props then
        itemData = g_data.item[self.item]
        if itemData.item_type == 4 then
            for key, value in pairs(g_data.general) do
                if value.piece_item_id == self.item then
                    itemData = value
                    self:getGeneralView(itemData)
                    break
                end
            end
        else
            self:getItemPath(itemData)
        end
    elseif self.itemType == g_Consts.DropType.Equipment then
        itemData = g_data.equipment[self.item]
        self:getItemPath(itemData)
    elseif self.itemType == g_Consts.DropType.General then
        itemData = g_data.general[self.item]
        self:getGeneralView(itemData)
    elseif self.itemType == g_Consts.DropType.MasterEquipment then
        local item = require("game.uilayer.common.ItemPathItemView").new(self.silkShop, g_tr("getPath103"), 1018035)
        self.ListView_1:pushBackCustomItem(item)
    end
end

function ItemPathView:getGeneralView(itemData)
    local item = nil
    for i=1, #itemData.drop_show do
        if itemData.drop_show[i][1] == 1 then
            item = require("game.uilayer.common.ItemPathItemView").new(self.killBlame, g_tr("getPath100"), 1018002)
            self.ListView_1:pushBackCustomItem(item)
        elseif itemData.drop_show[i][1] == 2 then
            item = require("game.uilayer.common.ItemPathItemView").new(self.allianceShop, g_tr("getPath101"), 1018027)
            self.ListView_1:pushBackCustomItem(item)
        elseif itemData.drop_show[i][1] == 3 then
            item = require("game.uilayer.common.ItemPathItemView").new(self.silkShop, g_tr("getPath103"), 1018035)
            self.ListView_1:pushBackCustomItem(item)
        elseif itemData.drop_show[i][1] == 4 then
            item = require("game.uilayer.common.ItemPathItemView").new(self.activity, g_tr("getPath102"), 1018028)
            self.ListView_1:pushBackCustomItem(item)
            self.activity_id = itemData.drop_show[i][2]
        elseif itemData.drop_show[i][1] == 5 then
            item = require("game.uilayer.common.ItemPathItemView").new(self.cornucopia, g_tr("getPath8"), 1018040)
            self.ListView_1:pushBackCustomItem(item)
        elseif itemData.drop_show[i][1] == 6 then
            item = require("game.uilayer.common.ItemPathItemView").new(self.dayfall, g_tr("getPath9"), 1018041)
            self.ListView_1:pushBackCustomItem(item)
         elseif itemData.drop_show[i][1] == 7 then
            item = require("game.uilayer.common.ItemPathItemView").new(self.godCombine, g_tr("getPath10"), 1018053)
            self.ListView_1:pushBackCustomItem(item)
        end
    end
end

function ItemPathView:getItemPath(itemData)
    local item = nil
    
    for i=1, #itemData.get_path do
        if itemData.get_path[i] == g_Consts.ItemPathType.world then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoWolrd, g_tr("getPath"..itemData.get_path[i]), 1018002)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.compose then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoCompse, g_tr("getPath"..itemData.get_path[i]), 1018003)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.shop then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoShop, g_tr("getPath"..itemData.get_path[i]), 1018003)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.decompose then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoDecompse, g_tr("getPath"..itemData.get_path[i]), 1018003)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.recast then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoRecast, g_tr("getPath"..itemData.get_path[i]), 1018003)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.mofang then
            item = require("game.uilayer.common.ItemPathItemView").new(self.mofang, g_tr("getPath"..itemData.get_path[i]), 1018004)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.cornucopia then
            item = require("game.uilayer.common.ItemPathItemView").new(self.cornucopia, g_tr("getPath"..itemData.get_path[i]), 1018040)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.dayfall then
            item = require("game.uilayer.common.ItemPathItemView").new(self.dayfall, g_tr("getPath"..itemData.get_path[i]), 1018041)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.godCombine then
            item = require("game.uilayer.common.ItemPathItemView").new(self.godCombine, g_tr("getPath"..itemData.get_path[i]), 1018040)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.drink then
            item = require("game.uilayer.common.ItemPathItemView").new(self.drink, g_tr("getPath"..itemData.get_path[i]), 1018042)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.allianceShop then
            item = require("game.uilayer.common.ItemPathItemView").new(self.allianceShop, g_tr("getPath101"), 1018027)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.silkShop then
            item = require("game.uilayer.common.ItemPathItemView").new(self.silkShop, g_tr("getPath103"), 1018035)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.meritorious then
            item = require("game.uilayer.common.ItemPathItemView").new(self.meritoriousShop, g_tr("getPath"..itemData.get_path[i]), 1018035)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.warShop then
            item = require("game.uilayer.common.ItemPathItemView").new(self.warShop, g_tr("getPath104"), 1018035)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.jitian then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoCorGod, g_tr("getPath"..itemData.get_path[i]), 1018052)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.rongLian then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoRongLian, g_tr("getPath"..itemData.get_path[i]), 1018054)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.cbShopLuoyang then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoCbShopLuoyang, g_tr("getPath"..itemData.get_path[i]), 1018055)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.cbShopChengdu then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoCbShopChengdu, g_tr("getPath"..itemData.get_path[i]), 1018035)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.cbShopJianye then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoCbShopJianye, g_tr("getPath"..itemData.get_path[i]), 1018035)
        elseif itemData.get_path[i] == g_Consts.ItemPathType.cbShopXiangyang then
            item = require("game.uilayer.common.ItemPathItemView").new(self.gotoCbShopXiangyang, g_tr("getPath"..itemData.get_path[i]), 1018035)
        end

        if item ~= nil then
            self.ListView_1:pushBackCustomItem(item)
        end
    end
end

function ItemPathView:close(isforceClose)
     if self.closeCallback == nil or isforceClose == true then
         self.super.close(self)
     end
end

function ItemPathView:initFun()
    self.gotoNpcId = function()
        require("game.maplayer.changeMapScene").changeToWorld()
        require("game.uilayer.mainSurface.mainSurfaceChat").createFindMosterHand()
    end

    self.gotoCompse = function()
        local SmithyData = require("game.uilayer.smithy.SmithyData")
        local baseView = SmithyData:instance():getBaseView()
        if baseView then 
            baseView:showView(SmithyData.viewType.Compose, self.item)
        else 
            if self.clickCallback ~= nil then
                self.clickCallback()
            end
            g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SMITHY, {type=SmithyData.viewType.Compose, val=self.item})
        end 
        self:close()
    end

    self.gotoDecompse = function()
        local SmithyData = require("game.uilayer.smithy.SmithyData")
        local baseView = SmithyData:instance():getBaseView()
        if baseView then 
            baseView:showView(SmithyData.viewType.Decompose, self.item)
        else 
            if self.clickCallback ~= nil then
                self.clickCallback()
            end
            g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SMITHY, {type=SmithyData.viewType.Decompose, val=self.item})
        end 
        self:close()
    end

    self.gotoRecast = function()
        local SmithyData = require("game.uilayer.smithy.SmithyData")
        local baseView = SmithyData:instance():getBaseView()
        if baseView then 
            baseView:showView(SmithyData.viewType.Recast, self.item)
        else 
            if self.clickCallback ~= nil then
                self.clickCallback()
            end
            g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SMITHY, {type=SmithyData.viewType.Recast, val=self.item})
        end 
        self:close()
    end

    self.gotoWolrd = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.WORLD_MAP)
        self:close()
    end

    self.gotoShop = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SHOP)
        self:close()
    end

    self.killBlame = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        require("game.maplayer.changeMapScene").changeToWorld()
        require("game.uilayer.mainSurface.mainSurfaceChat").createFindMosterHand()
        self:close()
    end

    self.mofang = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.MOFANG)
        self:close()
    end

    self.allianceShop = function()
        if g_AllianceMode.getSelfHaveAlliance() == false then
            g_airBox.show(g_tr("battleHallNoAlliance"))
            return
        end

        if self.clickCallback ~= nil then
            self.clickCallback()
        end

        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.ALLIANCE_SHOP)
        self:close()
    end

    self.activity = function()
        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.ACTIVITY,{activity_id = self.activity_id})
    end

    self.silkShop = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SHOP,{tag = 6})
        self:close()
    end

    self.cornucopia = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(1))

        self:close()
    end

    self.dayfall = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(2))
        self:close()
    end

    self.godCombine = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(3))
        self:close()
    end

    self.drink = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        require("game.uilayer.pub.PubLayer").openPubAndPositonGeneral(self.item)
        self:close()
    end

    self.meritoriousShop = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SHOP,{tag = 5})
        self:close()
    end

    self.warShop = function()
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_guideManager.gotoGameFeature(g_guideManager.gameFeatures.SHOP,{tag = 2})
        self:close()
    end

    self.gotoCorGod = function()
        if g_PlayerBuildMode.getMainCityBuilding_lv() < tonumber(g_data.starting[106].data) then
            g_airBox.show(g_tr("leffOfficeLevel", {level=g_data.starting[106].data}))
            return
        end
        
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(4))
        self:close()
    end

    self.gotoRongLian = function ()
        print("gotoRongLian")
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cornucopia.CornucopiaView").new(5))
        self:close()
    end

    self.gotoCbShopLuoyang = function () --洛阳商铺
        print("gotoCbShopLuoyang")
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cityBattle.CityShop"):create(2001))
        self:close()
    end

    self.gotoCbShopChengdu = function () --成都商铺
        print("gotoCbShopChengdu")
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cityBattle.CityShop"):create(2002))
        self:close()
    end

    self.gotoCbShopJianye = function () --建业商铺
        print("gotoCbShopJianye")
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cityBattle.CityShop"):create(2003))
        self:close()
    end

    self.gotoCbShopXiangyang = function () --襄阳商铺
        print("gotoCbShopXiangyang")
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
        g_sceneManager.addNodeForUI(require("game.uilayer.cityBattle.CityShop"):create(2004))
        self:close()
    end

    local function proClick(sender, evenType)
        if evenType == ccui.TouchEventType.ended then
            if sender ==  self.mask then
                g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
                self:close(true)
            end
        end
    end

    self.mask:addTouchEventListener(proClick)
end

return ItemPathView

--endregion
