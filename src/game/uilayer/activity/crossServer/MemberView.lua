local MemberView = class("MemberView", require("game.uilayer.base.BaseLayer"))

function MemberView:ctor(data, num, updateData)
	MemberView.super.ctor(self)

    self.mode = require("game.uilayer.activity.crossServer.CrossMode").new()

    self.originData = data
    self.num = num
    self.maxNum = tonumber(g_data.warfare_service_config[35].data)
    self.uiList = {}
    self.updateData = updateData

    self.layout = self:loadUI("activity3_Members01_01.csb")
    self.root = self.layout:getChildByName("scale_node")

    self.close_btn = self.root:getChildByName("close_btn")
    self.Text_1 = self.root:getChildByName("Text_1")
    self.Text_1:setString(g_tr("collectMember"))
    self.Text_2_0 = self.root:getChildByName("Text_2_0")

    self.Text_2_0:setString(g_tr("guildMemberCleanCntTip", {cnt=self.num, max_cnt=self.maxNum}))

    self.Button_1 = self.root:getChildByName("Button_1")
    self.Button_1:setVisible(false)
    self.Text_12 = self.Button_1:getChildByName("Text_12")
    self.Text_12:setString(g_tr("collectSend"))
    self.Text_ss1 = self.root:getChildByName("Text_ss1")
    self.Text_ss1:setString(g_tr("managerInfo"))

    self.ListView_1 = self.root:getChildByName("ListView_1")

    local sel = {}
    local app = {}
    local nor = {}
    self.data = {}
    for key, value in pairs(self.originData) do
        if value.read2join_flag == 1 then
            table.insert(sel, value)
        elseif value.application_flag == 1 then
            table.insert(app, value)
        else
            table.insert(nor, value)
        end
    end

    for key, value in pairs(sel) do
        table.insert(self.data, value)
    end

    for key, value in pairs(app) do
        table.insert(self.data, value)
    end

    for key, value in pairs(nor) do
        table.insert(self.data, value)
    end

    self:initFun()

    if g_AllianceMode.isAllianceManager() then
        self:addEvent()
        self.Button_1:setVisible(true)
        self.Text_ss1:setString("")
    end

    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                if self.newData ~= nil and self.updateData ~= nil then
                    self.updateData(self.newData)
                end
                self:close()
            end
        end
    end

    self.close_btn:addTouchEventListener(proClick)
    
    self:init()
end

function MemberView:initFun()
    self.updateMemebers = function(layer,result,ui)

        if result == true then
            self.num = self.num - 1
            layer:setSel(false, ui)
        else
            if self.num < 10 then
                self.num = self.num + 1
                layer:setSel(true, ui)
            end
        end
        self.Text_2_0:setString(g_tr("guildMemberCleanCntTip", {cnt=self.num, max_cnt=self.maxNum}))
    end

    self.commitMember = function(data)
        g_airBox.show(g_tr("commitMember"))
        if self.updateData ~= nil then
            self.updateData(data)
        end

        self:close()
    end
end

function MemberView:init()
    local len = math.ceil((#self.data)/2)

    local sel = true
    if self.num == self.maxNum  then
        sel = false
    end

    for i=1, len do
        local item = require("game.uilayer.activity.crossServer.MemberItemView").new(self.updateMemebers)
        item:show(self.data[i*2-1], self.data[i*2])

        self.ListView_1:pushBackCustomItem(item)

        table.insert(self.uiList, item)
    end
end

function MemberView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.close_btn then
                if self.newData ~= nil and self.updateData ~= nil then
                    self.updateData(self.newData)
                end
                self:close()
            elseif sender == self.Button_1 then
                local result = {}
                for key, value in pairs(self.uiList) do
                    local v1,d1,v2,d2 = value:getSel()
                    if v1 == true then
                        table.insert(result, d1.player_id)
                    end

                    if v2 == true then
                        table.insert(result, d2.player_id)
                    end

                    if (#result) >= 10 then
                        break
                    end
                end

                local function callback(data)
                    if data == nil then
                        return
                    end
                    self.newData = data
                    local tag = false
                    for i=1, #self.data do
                        for j=1, #data.members do
                            if self.data[i].player_id == data.members[j].player_id then
                                if self.data[i].read2join_flag ~= data.members[j].read2join_flag then
                                    tag = true
                                    break
                                end
                            end
                        end

                        if tag == true then
                            break
                        end
                    end

                    if tag == true then
                        g_airBox.show(g_tr("reGetMembers"))
                    else
                        self.mode:commitBattleMemberList(result, self.commitMember)
                    end
                end

                self.mode:basicInfo(callback)
            end
        end
    end
    
    self.Button_1:addTouchEventListener(proClick)
end

return MemberView