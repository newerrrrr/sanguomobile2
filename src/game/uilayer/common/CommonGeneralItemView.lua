--region CommonGeneralItemView.lua
--Author : luqingqing
--Date   : 2015/11/11
--此文件由[BabeLua]插件自动生成

--region CommonGeneralItemView.lua
--Author : luqingqing
--Date   : 2015/10/28
--此文件由[BabeLua]插件自动生成

local CommonGeneralItemView = class("CommonGeneralItemView",  function() 
    return ccui.Widget:create()
end)

local _data = nil

local property = {g_tr("wu"), g_tr("zhi"), g_tr("zheng"), g_tr("tong"), g_tr("mei")}

function CommonGeneralItemView:ctor()
    local layout = cc.CSLoader:createNode("xuanzhewujiangtongyong.csb")
    self.root = layout:getChildByName("scale_node")
    self:addChild(layout)

    self:setContentSize(cc.size(layout:getContentSize().width, layout:getContentSize().height + 5))
    
    self.Image_3 = self.root:getChildByName("Image_3")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1_0 = self.root:getChildByName("Text_1_0")
    self.Text_zhuangtai01 = self.root:getChildByName("Text_zhuangtai01")
    self.Text_Text_zhuangtai02 = self.root:getChildByName("Text_Text_zhuangtai02")

    self.Text_zhuangtai01:setString(g_tr_original("status"))
    self.Text_Text_zhuangtai02:setString(g_tr_original("freeStatus"))

    for i=1, 3 do
        self["Image_jiche0"..i] = self.root:getChildByName("Image_jiche0"..i)
        self["Image_jiche0"..i.."Text_6"] = self["Image_jiche0"..i]:getChildByName("Text_6")
        self["Image_jiche0"..i]:setVisible(false)
    end

    self.Image_4 = self.root:getChildByName("Image_4")
    self.LoadingBar_1 = self.Image_4:getChildByName("LoadingBar_1")
    self.Image_4_Text_3 = self.Image_4:getChildByName("Text_3")

    self.Panel_yanse = self.root:getChildByName("Panel_yanse")
    for i=1, 5 do
        self["Panel_yanse"..i] = self.Panel_yanse:getChildByName("Panel_yanse"..i)
        self["Panel_yanse"..i.."Text_9"] = self["Panel_yanse"..i]:getChildByName("Text_9")
        self["Panel_yanse"..i.."Text_9"]:setString(property[i])
        self["Panel_yanse"..i.."Text_10"] = self["Panel_yanse"..i]:getChildByName("Text_10")
    end
end

function CommonGeneralItemView:show(data, clickBack)

    _data = data
    self.data = data
    self.click = clickBack

    self.Text_1:setString("")
    self.Text_1_0:setString("")
    self.LoadingBar_1:setPercent(100)
    self.Image_4_Text_3:setString("0/0")
    self["Panel_yanse1Text_10"]:setString("--")
    self["Panel_yanse2Text_10"]:setString("--")
    self["Panel_yanse3Text_10"]:setString("--")
    self["Panel_yanse4Text_10"]:setString("--")
    self["Panel_yanse5Text_10"]:setString("--")

    if _data ~= nil then
        local gData = g_GeneralMode.GetBasicInfo(_data.general_id,  1)
        self.Text_1:setString(g_tr(gData.general_name))
        self.Text_1_0:setString("lv".._data.lv)

        if tonumber(_data.exp) < g_data.general_exp[tonumber(_data.lv)].general_exp then
            local tem = tonumber(_data.exp)/g_data.general_exp[tonumber(_data.lv)].general_exp * 100
            tem = tem - tem%1
            self.Image_4_Text_3:setString(tem.."%")
            self.LoadingBar_1:setPercent(tem)
        else
            self.Image_4_Text_3:setString("100%")
            self.LoadingBar_1:setPercent(100)
        end

        self["Panel_yanse1Text_10"]:setString(gData.general_force.."")
        self["Panel_yanse2Text_10"]:setString(gData.general_intelligence.."")
        self["Panel_yanse3Text_10"]:setString(gData.general_political.."")
        self["Panel_yanse4Text_10"]:setString(gData.general_governing.."")
        self["Panel_yanse5Text_10"]:setString(gData.general_charm.."")
    
        self["Image_jiche01"]:setVisible(false)
        self["Image_jiche02"]:setVisible(false)
        self["Image_jiche03"]:setVisible(false)
    end

    self:addEvent()
end

function CommonGeneralItemView:addEvent()

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Image_3 then
                if self.click ~= nil then
                    g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
                    self.click(self.data)
                end
            end
        end
    end

    self.Image_3:addTouchEventListener(proClick)
end

return CommonGeneralItemView

--endregion


--endregion
