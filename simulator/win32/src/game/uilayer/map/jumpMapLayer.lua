local jumpMapLayer = class("jumpMapLayer", require("game.uilayer.base.BaseLayer"))
local MapHelper = require "game.maplayer.worldMapLayer_helper"
local BigMap = require("game.maplayer.worldMapLayer_bigMap")

local _requireMapHelper = function()
	local mapHelper = require "game.maplayer.worldMapLayer_helper"
	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
			mapHelper = require "game.mapguildwar.worldMapLayer_helper"
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
			mapHelper = require "game.mapcitybattle.worldMapLayer_helper"
	end
	return mapHelper
end

local _requireBigMap = function()
	local bigMap = require("game.maplayer.worldMapLayer_bigMap")
	local changeMapScene = require("game.maplayer.changeMapScene")
	local mapStatus = changeMapScene.getCurrentMapStatus()
	if mapStatus == changeMapScene.m_MapEnum.guildwar then
			bigMap = require("game.mapguildwar.worldMapLayer_bigMap")
	elseif mapStatus == changeMapScene.m_MapEnum.citybattle then
			bigMap = require("game.mapcitybattle.worldMapLayer_bigMap")
	end
	return bigMap
end

function jumpMapLayer:ctor()
    jumpMapLayer.super.ctor(self)
    self:InitUI()
end

function jumpMapLayer:InitUI()
    local layout = self:loadUI("favorites_popup_input.csb")
    local root = layout:getChildByName("scale_node")
    local close_btn = root:getChildByName("Button_x")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
	
    root:getChildByName("bg_title"):getChildByName("Text_2"):setString(g_tr("MapJumpTitle"))
    root:getChildByName("Text_5"):setString(g_tr("MapJumpStr"))
	root:getChildByName("Text_3"):setString("")

    local editXmode = root:getChildByName("TextField_1")
    local editYmode = root:getChildByName("TextField_1_0")

    local editX = g_gameTools.convertTextFieldToEditBox(editXmode)
    local editY = g_gameTools.convertTextFieldToEditBox(editYmode)

    local jump_btn = root:getChildByName("btn_1")

    local function isOk(str)
        local num = tonumber(str)

        if num == nil then
            print("不是纯数字")

            g_airBox.show(g_tr("MapPosErrorNum"))

            return false
        end

        num = math.floor(num)

        if num < 0 then
            print("不能为负数")

            g_airBox.show(g_tr("MapPosErrorNum"))
            return false
        end
        
        return num
    end

    self:regBtnCallback(jump_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        
        local x = isOk( editX:getString() )
        if x == false then
            return
        end

        local y = isOk( editY:getString() )
        if y == false then
            return
        end
        
        MapHelper = _requireMapHelper()
        BigMap = _requireBigMap()
        
        print("MAX",MapHelper.m_TileTotalCount.width,MapHelper.m_TileTotalCount.height)

        local maxX = MapHelper.m_TileTotalCount.width - 1
        local maxY = MapHelper.m_TileTotalCount.height - 1

        if x > maxX then
            print("超X上限")
            g_airBox.show(g_tr("MapJumpXYError",{pos = "x",num = maxX }))
            return
        end

        if y > maxY then
            print("超Y上限")
            g_airBox.show(g_tr("MapJumpXYError",{pos = "x",num = maxY }))
            return
        end

        --print("gogogo",x,y)

        BigMap.closeSmallMenu()
        BigMap.closeInputMenu()
        BigMap.changeBigTileIndex_Manual(cc.p( x,y ),true)
        self:close()

        --print("跳跳跳")
	end)


end

function jumpMapLayer:onEnter()
    print("jumpMapLayer onEnter")
end

function jumpMapLayer:onExit()
    print("jumpMapLayer onExit")
end 

return jumpMapLayer