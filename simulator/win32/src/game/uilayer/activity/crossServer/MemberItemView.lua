local MemberItemView = class("MemberItemView", require("game.uilayer.base.BaseWidget"))

function MemberItemView:ctor(callback)
	self.layout = self:LoadUI("activity3_Members01_02.csb")
    self.root = self.layout:getChildByName("scale_node")

    self["scale_1_sel"] = false
    self["scale_2_sel"] = false

    self.callback = callback

    for i=1, 2 do
        self["scale_"..i] = self.root:getChildByName("scale_"..i)
        self["scale_"..i.."Text_1"] = self["scale_"..i]:getChildByName("Text_1")
        self["scale_"..i.."Text_1"]:setString(g_tr("prePlayerPower"))
        --在线
        self["scale_"..i.."Text_2"] = self["scale_"..i]:getChildByName("Text_2")
        --离线
        self["scale_"..i.."Text_2_0"] = self["scale_"..i]:getChildByName("Text_2_0")
        self["scale_"..i.."Text_3"] = self["scale_"..i]:getChildByName("Text_3")
        self["scale_"..i.."Image_10"] = self["scale_"..i]:getChildByName("Image_10")
        self["scale_"..i.."Text_4"] = self["scale_"..i]:getChildByName("Text_4")
        self["scale_"..i.."Image_k1"] = self["scale_"..i]:getChildByName("Image_k1")
        self["scale_"..i.."Image_k2"] = self["scale_"..i]:getChildByName("Image_k2")

        self["scale_"..i.."Image_tt"] = self["scale_"..i]:getChildByName("Image_tt")
        self["scale_"..i.."Text_4_0"] = self["scale_"..i.."Image_tt"]:getChildByName("Text_4_0")
        self["scale_"..i.."Text_4_0"]:setString(g_tr("applyed"))
    end

    if g_AllianceMode.isAllianceManager() then
        self:addEvent()
    end
end

function MemberItemView:show(data1, data2)
    self.data1 = data1
    self.data2 = data2

    self:setData("scale_1", self.data1)
    self:setData("scale_2", self.data2)
end

function MemberItemView:setData(ui, data)
    if data == nil then
        self[ui]:setVisible(false)
        return
    end

    self[ui.."Text_3"]:setString(data.nick)
    self[ui.."Text_4"]:setString(data.power.."")
        
        if g_AllianceMode.isAllianceManager() then
        if require("game.gametools.online").operateIsOnline(g_clock.getCurServerTime(), data.last_online_time) then
           self[ui.."Text_2"]:setString(g_tr("online"))
           self[ui.."Text_2_0"]:setString("")
        else
           self[ui.."Text_2"]:setString("")
           local stateStr = ""
           local nowTime = g_clock.getCurServerTime()
           local lastTime = data.last_online_time
           local timeShowStr = ""
           if lastTime > 0 then 
             local miniutes = math.ceil((nowTime - lastTime)/60)             
             if miniutes < 60 then
                 timeShowStr = g_tr("miniuteago",{value = miniutes})
             elseif miniutes >= 60 and miniutes < 1440 then
                 timeShowStr =  g_tr("hourago",{value = math.floor(miniutes/60)})
             else
                 timeShowStr = g_tr("dayago",{value = math.min(7, math.floor(miniutes/1440))})
             end
           else 
             timeShowStr = g_tr("dayago",{value = 7})
           end 
           stateStr = g_tr("lastOnlineTime").."\n"..timeShowStr
           self[ui.."Text_2_0"]:setString(stateStr)
        end
      else
        self[ui.."Text_2"]:setString("")
        self[ui.."Text_2_0"]:setString("")
    end

    local head = g_data.res_head[data.avatar_id].head_icon
    self[ui.."Image_10"]:loadTexture( g_resManager.getResPath(head))

    local imgFrame = ccui.ImageView:create(g_data.sprite[1010007].path)
    self[ui.."Image_10"]:addChild(imgFrame)
    imgFrame:setPosition(cc.p(self[ui.."Image_10"]:getContentSize().width/2, self[ui.."Image_10"]:getContentSize().height/2))

    if data.application_flag == 1 then
        self[ui.."Image_tt"]:setVisible(true)
    else
        self[ui.."Image_tt"]:setVisible(false)
    end

    if data.read2join_flag == 1 then
        self[ui.."Image_k2"]:setVisible(true)
        self[ui.."_sel"] = true
    else
        self[ui.."Image_k2"]:setVisible(false)
        self[ui.."_sel"] = false
    end
end

function MemberItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.scale_1 then
                if self.callback ~= nil then
                    self.callback(self, self["scale_1_sel"], "scale_1")
                end
            elseif sender == self.scale_2 then
                if self.callback ~= nil then
                    self.callback(self, self["scale_2_sel"], "scale_2")
                end
            end
        end    
    end

    self.scale_1:addTouchEventListener(proClick)
    self.scale_2:addTouchEventListener(proClick)
end

function MemberItemView:setSel(value, ui)
    self[ui.."_sel"] = value
    self[ui.."Image_k2"]:setVisible(value)
end

function MemberItemView:getSel(ui)
    return self[ui.."_sel"]
end

function MemberItemView:getSel()
    return self["scale_1_sel"], self.data1, self["scale_2_sel"], self.data2
end

return MemberItemView