--region SevenDayItemView.lua
--Author : luqingqing
--Date   : 2016/5/3
--此文件由[BabeLua]插件自动生成

local SevenDayItemView = class("SevenDayItemView")

function SevenDayItemView:ctor(mc, gotoView, getReward, autoFresh, showInfo)
    self.gotoView = gotoView
    self.getReward = getReward
    self.autoFresh = autoFresh
    self.showInfo = showInfo

    self.mc = mc
    self.Text_5 = self.mc:getChildByName("Text_5")
    self.Image_4 = self.mc:getChildByName("Image_4")
    self.Text_6 = self.mc:getChildByName("Text_6")
    self.Button_1 = self.mc:getChildByName("Button_1")
    self.b1_Text_7 = self.Button_1:getChildByName("Text_7")
    self.Button_2 = self.mc:getChildByName("Button_2")
    self.b2_Text_7 = self.Button_2:getChildByName("Text_7")
    self.Text_8 = self.mc:getChildByName("Text_8")
    self.Image_15 = self.mc:getChildByName("Image_15")

    self:addEvent()
end

function SevenDayItemView:show(data)
    self.data = data
    local playerInfo = g_playerInfoData.GetData()

    if self.data == nil then
        local t = playerInfo.sub_day
        if t >= g_data.target[(#g_data.target)].open_time then
            self.mc:setVisible(false)
        else
            self.mc:setVisible(true)
            self.Text_6:setString("")
            self.Text_8:setString("")

            self.Button_1:setVisible(false)
            self.Button_2:setVisible(false)
            self.Image_15:setVisible(false)

            local imgFrame = ccui.ImageView:create(g_data.sprite[1018050].path)
            self.Image_4:addChild(imgFrame)
            imgFrame:setPosition(self.Image_4:getContentSize().width/2, self.Image_4:getContentSize().height/2)

            self.Text_5:setString(g_tr("noTaskInfo"))
        end
        return
    end

    self.mc:setVisible(true)
    self.Button_1:setVisible(true)
    self.Button_2:setVisible(true)
    self.Image_15:setVisible(true)

    self.value = g_data.target[self.data.target_id]
    if playerInfo.sub_day == 1 then
        self.drop = g_data.drop[self.value.drop[1]]
    elseif playerInfo.sub_day == 2 then
        self.drop = g_data.drop[self.value.drop_2]
    elseif playerInfo.sub_day == 3 then
        self.drop = g_data.drop[self.value.drop_3]
    elseif playerInfo.sub_day == 4 then
        self.drop = g_data.drop[self.value.drop_4]
    elseif playerInfo.sub_day == 5 then
        self.drop = g_data.drop[self.value.drop_5]
    elseif playerInfo.sub_day == 6 then
        self.drop = g_data.drop[self.value.drop_6]
    elseif playerInfo.sub_day >= 7 then
        self.drop = g_data.drop[self.value.drop_7]
    end

    self.Text_5:setString(g_tr(self.value.target_desc))

    dump(playerInfo)
    dump(self.drop)

    local item = require("game.uilayer.common.DropItemView").new(self.drop.drop_data[1][1], self.drop.drop_data[1][2], self.drop.drop_data[1][3])
    self.Image_4:addChild(item)
    item:setPosition(self.Image_4:getContentSize().width/2, self.Image_4:getContentSize().height/2)

    self.Text_6:setString(self.data.current_value.."/"..self.data.target_value)

    if self.data.current_value >= self.data.target_value then
        if self.data.award_status == 0 then
            self.Image_15:setVisible(true)
            self.Button_2:setVisible(true)
            self.Button_1:setVisible(false)
        else
            self.Image_15:setVisible(false)
            self.Button_2:setVisible(false)
            self.Button_1:setVisible(false)
        end
    else
        self.Image_15:setVisible(false)
        self.Button_2:setVisible(false)
        self.Button_1:setVisible(true)
    end
end

function SevenDayItemView:addEvent()
    local function proClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self.Button_1 then
                if self.gotoView ~= nil then
                    self.gotoView(self.value)
                end
            elseif sender == self.Button_2 then
                if self.getReward ~= nil then
                    self.getReward(self)
                end
            elseif sender == self.Image_4 then
                if self.data == nil  then
                    return
                end
                local tb = {[ 'item_type' ] = self.drop.drop_data[1][1], [ 'item_id' ] = self.drop.drop_data[1][2], ['num']=self.drop.drop_data[1][3]}
                if self.showInfo ~= nil then
                    self.showInfo(tb)
                end
            end
        end
    end

    --前往
    self.Button_1:addTouchEventListener(proClick)
    --领取
    self.Button_2:addTouchEventListener(proClick)
    --点击图片
    self.Image_4:addTouchEventListener(proClick)
end

function SevenDayItemView:showTime()
    if self.data ~= nil then
        local dt = self.data.date_end -  g_clock.getCurServerTime()
        if dt <= 0 then 
            dt = 0 

            if self.autoFresh ~= nil then
                self.autoFresh()
            end
        end 

        local hour = math.floor(dt/3600)
        local min = math.floor((dt%3600)/60)
        local sec = math.floor(dt%60)

        self.Text_8:setString(string.format("%02d:%02d:%02d", hour, min, sec))    
    end 
end

function SevenDayItemView:getData()
    return self.data
end

function SevenDayItemView:formatCount(count)
    return string.formatnumberlogogram(count)
end 

function SevenDayItemView:getBtn()
    return self.Button_2
end

function SevenDayItemView:getMc()
    return self.mc
end

return SevenDayItemView
--endregion
