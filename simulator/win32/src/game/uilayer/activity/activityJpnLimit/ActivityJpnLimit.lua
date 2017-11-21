
--限定活动(日本通活动)

local ActivityJpnLimit = class("ActivityJpnLimit", require("game.uilayer.base.BaseLayer"))

function ActivityJpnLimit:ctor() 
  ActivityJpnLimit.super.ctor(self) 

  local layer = cc.CSLoader:createNode("activity4_mian8.csb") 
  if layer then 
    self:addChild(layer)
  end   
end

function ActivityJpnLimit:onEnter()
  print("ActivityJpnLimit:onEnter")
end 

function ActivityJpnLimit:onExit() 
  print("ActivityJpnLimit:onExit") 
end 

return ActivityJpnLimit 
