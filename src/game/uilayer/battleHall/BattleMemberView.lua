
--region BattleMemberView.lua
--Author : luqingqing
--Date   : 2015/12/4
--此文件由[BabeLua]插件自动生成

local BattleMemberView = class("BattleMemberView", require("game.uilayer.base.BaseWidget"))

function BattleMemberView:ctor(cancleSelect)
    self.cancelSelect = cancleSelect

    self.layout = self:LoadUI("alliance_Members01_02.csb")
    self.root = self.layout:getChildByName("scale_node")

    for i=1, 2 do
        self["scale_"..i] = self.root:getChildByName("scale_"..i)
        self["scale_"..i.."Text_1"] = self["scale_"..i]:getChildByName("Text_1")
        --在线
        self["scale_"..i.."Text_2"] = self["scale_"..i]:getChildByName("Text_2")
        --离线
        self["scale_"..i.."Text_2_0"] = self["scale_"..i]:getChildByName("Text_2_0")
        self["scale_"..i.."Text_3"] = self["scale_"..i]:getChildByName("Text_3")
        self["scale_"..i.."Image_10"] = self["scale_"..i]:getChildByName("Image_10")
        self["scale_"..i.."Text_4"] = self["scale_"..i]:getChildByName("Text_4")
        self["scale_"..i.."Image_k1"] = self["scale_"..i]:getChildByName("Image_k1")
        self["scale_"..i.."Image_k2"] = self["scale_"..i]:getChildByName("Image_k2")
    end

    self:addEvent()
end

function BattleMemberView:show(data1, data2)
    self.data1 = data1
    self.data2 = data2

    self.sel1 = false
    self.sel2 = false

    if self.data1 == nil then
        self.scale_1:setVisible(false)
    else
        self:setUI("scale_1", self.data1)
    end

    if self.data2 == nil then
        self.scale_2:setVisible(false)
    else
        self:setUI("scale_2", self.data2)
    end
end

function BattleMemberView:setUI(ui, data)
    self[ui.."Text_1"]:setString(g_tr("Power"))
    self[ui.."Text_3"]:setString(data.nick)
    self[ui.."Text_4"]:setString(data.power.."")
    self[ui.."Image_k2"]:setVisible(false)

    local head = g_data.res_head[data.avatar_id].head_icon
    self[ui.."Image_10"]:loadTexture( g_resManager.getResPath(head))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self[ui.."Image_10"]:addChild(imgFrame)
    imgFrame:setPosition(cc.p(self[ui.."Image_10"]:getContentSize().width/2, self[ui.."Image_10"]:getContentSize().height/2))

    if g_AllianceMode.isAllianceManager() then
        if  require("game.gametools.online").operateIsOnline(g_clock.getCurServerTime(), data.last_online_time) then
            self[ui.."Text_2"]:setString(g_tr("online"))
            self[ui.."Text_2_0"]:setString("")
        else
            self[ui.."Text_2"]:setString("")
            self[ui.."Text_2_0"]:setString(g_tr("offline"))
        end
    else
        self[ui.."Text_2"]:setString("")
        self[ui.."Text_2_0"]:setString("")
    end
    
end

function BattleMemberView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
            if sender == self.scale_1 then
                if self.sel1 == false then
                    self.sel1 = true
                    self["scale_1Image_k2"]:setVisible(true)
                else
                    self.sel1 = false
                    self["scale_1Image_k2"]:setVisible(false)
                    self.cancelSelect()
                end
            elseif sender == self.scale_2 then
                if self.sel2 == false then
                    self.sel2 = true
                    self["scale_2Image_k2"]:setVisible(true)
                else
                    self.sel2 = false
                    self["scale_2Image_k2"]:setVisible(false)
                    self.cancelSelect()
                end
            end
        end
    end

    self.scale_1:addTouchEventListener(proClick)
    self.scale_2:addTouchEventListener(proClick)
end

function BattleMemberView:getData1()
    return self.data1
end

function BattleMemberView:getData2()
    return self.data2
end

function BattleMemberView:getSel1()
    return self.sel1
end

function BattleMemberView:getSel2()
    return self.sel2
end

function BattleMemberView:setSel1(value)
    self.sel1 = value
    if self.sel1 == false then
        self["scale_1Image_k2"]:setVisible(false)
    else
        self["scale_1Image_k2"]:setVisible(true)
    end
end

function BattleMemberView:setSel2(value)
    self.sel2 = value
    if self.sel2 == false then
        self["scale_2Image_k2"]:setVisible(false)
    else
        self["scale_2Image_k2"]:setVisible(true)
    end
end

return BattleMemberView

--endregion
