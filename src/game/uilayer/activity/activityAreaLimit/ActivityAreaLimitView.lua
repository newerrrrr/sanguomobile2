
--限定活动(日本通活动)

local ActivityAreaLimitView = class("ActivityAreaLimitView", require("game.uilayer.base.BaseLayer"))

function ActivityAreaLimitView:ctor() 
  ActivityAreaLimitView.super.ctor(self) 

  local layer = cc.CSLoader:createNode("activity4_mian8.csb") 
  if layer then 
    self:addChild(layer)
  end   
end

function ActivityAreaLimitView:onEnter()
  print("ActivityAreaLimitView:onEnter")
end 

function ActivityAreaLimitView:onExit() 
  print("ActivityAreaLimitView:onExit") 
end 

return ActivityAreaLimitView 
