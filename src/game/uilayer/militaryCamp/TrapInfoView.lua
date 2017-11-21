--region TrapResDesc.lua  --陷阱描述
--Author : liuyi
--Date   : 2016/3/1
local TrapInfoView = class("TrapInfoView", require("game.uilayer.base.BaseLayer"))


function TrapInfoView:ctor(id,callBackFun)
    TrapInfoView.super.ctor(self)
    self._callback = callBackFun
    self:initUI(id)
end


function TrapInfoView:initUI(id)
    self.layer = self:loadUI("trap_details.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.layer:getChildByName("mask")
	self:regBtnCallback(close_btn,function ()
		self:close()
	end)

    local data_Config = g_data.trap[id]    

    --dump(data_Config)
    --标题
    self.root:getChildByName("Text_1"):setString(g_tr("trapinfotitle"))
    --名称
    self.root:getChildByName("Text_3"):setString(g_tr(data_Config.trap_name))
    --trap_name
    local level_img = self.root:getChildByName("Text_3_0")

    local lvImg = ccui.ImageView:create( g_resManager.getResPath(data_Config.img_level))
    lvImg:setPosition(level_img:getPosition())
    lvImg:setAnchorPoint(level_img:getAnchorPoint())
    level_img:getParent():addChild(lvImg)

    level_img:setVisible(false)

    self.root:getChildByName("Text_4"):setString(g_tr("armyattack"))
    self.root:getChildByName("Text_5"):setString(g_tr("attRange"))
    self.root:getChildByName("Text_6"):setString(g_tr("armyFightForce"))
    self.root:getChildByName("Text_7"):setString(g_tr("haveNum"))
    self.root:getChildByName("Text_8"):setString(g_tr("trapfired"))
    self.root:getChildByName("Text_ms1"):setString(g_tr("trapdesc"))
    self.root:getChildByName("Text_ms2"):setString(g_tr(data_Config.description))


    self.root:getChildByName("Text_4_0"):setString( string.format("%.2f",data_Config.atk) )
    self.root:getChildByName("Text_5_0"):setString( string.format("%.2f",data_Config.distance) )
    self.root:getChildByName("Text_6_0"):setString( string.format("%.2f",data_Config.power) )
    self.root:getChildByName("Text_4_0_0"):setVisible(false)
    
    local data = g_TrapMode.GetData()
    local curNum = 0 
    for k, v in pairs(data) do 
        if v.trap_id == id then
            curNum = v.num 
            break
        end
    end

    self.root:getChildByName("Text_7_0"):setString( tostring(curNum) )

    local btn = self.root:getChildByName("Button_2")
    self:regBtnCallback(btn,function ()
		 if curNum <= 0 then
            g_airBox.show( g_tr("TrapFiredNotEnougt") ,3)
            return
         end

        g_msgBox.show( g_tr("TrapFiredStr"),nil,2,
        function ( eventtype )
            --确定
            if eventtype == 0 then 
                local function callback( result , data )
                    if true == result then
                        --dump(data)
                        g_airBox.show( g_tr("TrapFiredS") ,1)
                        curNum = 0
                        self.root:getChildByName("Text_7_0"):setString( tostring(curNum) )
                        if self._callback then
                            self._callback()
                        end
                        self:close()
                    end
                end
                g_sgHttp.postData("trap/removeTrap", { trapId = id,num = curNum }, callback )
            end
        end , 1)
	end)
end


return TrapInfoView


--endregion
