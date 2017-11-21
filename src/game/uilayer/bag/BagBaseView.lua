--region BagBaseView.lua
--Author : luqingqing
--Date   : 2016/4/11
--此文件由[BabeLua]插件自动生成

local BagBaseView = class("BagBaseView", function() 
    return cc.Layer:create()
end)

function BagBaseView:ctor()
    
end

function BagBaseView:loadItem(data, type, list, callback)
    local index = 0
    local idx_s = 1 
    local idx_e = #data
    local item = nil
    local function loadItem()
        if idx_s <= idx_e then
            if list[idx_s] == nil then
                item = require("game.uilayer.bag.BagItemView").new(type, callback)
                self.ListView_1:pushBackCustomItem(item)
                list[idx_s] = item
            else
                item = self.uilist[idx_s]
            end
            item:show(data[idx_s])
            idx_s = idx_s + 1 
            index = index + 1
        else
            if index < #list then
                for i=index+1, #list do
                    self.ListView_1:removeItem(self.ListView_1:getIndex(list[i]))
                    list[i] = nil
                end
            end

            --加载完成
            if self.frameLoadTimer then 
                self:unschedule(self.frameLoadTimer) 
                self.frameLoadTimer = nil  
            end 
        end
    end

    --分侦加载
    if self.frameLoadTimer then 
        self:unschedule(self.frameLoadTimer) 
        self.frameLoadTimer = nil  
    end 
    self.frameLoadTimer = self:schedule(loadItem, 0) 
end

function BagBaseView:schedule(callback, delay)
  local delay = cc.DelayTime:create(delay)
  local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
  local action = cc.RepeatForever:create(sequence)
  self:runAction(action)
  return action
end 

function BagBaseView:unschedule(action)
  self:stopAction(action)
end

return BagBaseView

--endregion
