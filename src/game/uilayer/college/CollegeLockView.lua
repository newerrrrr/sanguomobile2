--region CollegeLockView.lua
--Author : luqingqing
--Date   : 2015/11/5
--此文件由[BabeLua]插件自动生成

local CollegeLockView = class("CollegeLockView", function() 
    return ccui.Widget:create()
end)

function CollegeLockView:ctor(data)
    self.data = data

    self.layout = cc.CSLoader:createNode("college_List_unlock.csb")
    self:addChild(self.layout)

    self:setContentSize(cc.size(self.layout:getContentSize().width, self.layout:getContentSize().height))

    self.root = self.layout:getChildByName("scale_node")
    
    self.Panel_8 = self.root:getChildByName("Panel_8")
    self.Panel_8_Text_8 = self.Panel_8:getChildByName("Text_8")
    self.Panel_8_Text_8:setString(g_tr_original("studyLock"))

    self.Text_unlock = self.root:getChildByName("Text_unlock")
    self.Text_unlock:setString(g_tr("studyUnlock", {level = self.data}))
end

return CollegeLockView

--endregion
