local MasterCNameView = class("MasterCNameView", require("game.uilayer.base.BaseLayer"))
local MODE = nil
--local master_data = nil
local NAME_CARD_ID_TYPE = 22700
local NAME_RNAME_COST_ID_TYPE = 10800
local NAME_RNAME_NO_FIRST = 1
local NAME_RNAME_FIRST = 0

function MasterCNameView:createLayer( fun )
    MODE = nil
    MODE = require("game.uilayer.master.MasterMode").new()
    self.master_data = MODE:getMasterInfo()

    local playerInfoData = nil

    --if g_playerInfoData.RequestData() then
    playerInfoData = g_playerInfoData.GetData()
    --else
        --return
    --end

    self.firstCN = NAME_RNAME_NO_FIRST
    --dump(playerInfoData)

    if playerInfoData then
        self.firstCN = playerInfoData.first_nick
    end

    --dump (self.playerInfoData)

    if self.master_data then
        g_sceneManager.addNodeForUI( MasterCNameView:create( fun ) )
        return true  
    end

    return false
end

function MasterCNameView:ctor( callback )
    MasterCNameView.super.ctor(self)
    self.callback = callback
    self:initUI()
end

function MasterCNameView:initUI()
    self.layer = self:loadUI("zhugong_changeName_popup.csb")
    self.root = self.layer:getChildByName("scale_node")
    local close_btn = self.root:getChildByName("close_btn")
    self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

    --zhcn
    self.root:getChildByName("bg_title"):getChildByName("text"):setString( g_tr("MasterCNTitle") )
    self.root:getChildByName("Text_tips"):setString( g_tr("MasterCNP") )
    self.root:getChildByName("Text_1_0"):setString( g_tr("NickCostStr") )
    local name_edit = self.root:getChildByName("TextField_1")
    local gold_icon = self.root:getChildByName("ico_gold_1")
    local gemCount, gemIcon = g_gameTools.getPlayerCurrencyCount( g_Consts.AllCurrencyType.Gem )
    gold_icon:loadTexture(gemIcon)

    local gold_tx = self.root:getChildByName("Text_1")

    local name_editbox = g_gameTools.convertTextFieldToEditBox(name_edit)
    --name_editbox:setMaxLength(7)
    
    
    
    local save_btn = self.root:getChildByName("btn_save")
    self:regBtnCallback(save_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
        --去除收尾空格
        local namestr = string.trim( name_editbox:getText() )
        if namestr ~= "" and tostring(self.master_data.nick) ~= tostring(namestr) then
            if string.utf8len(namestr) > 7 then
                g_airBox.show(g_tr("MasterNameLenMax"))
                return
            end
            --免费
            if self.firstCN == NAME_RNAME_FIRST then
                
                if MODE:masterRenameAction( namestr ) then
                    g_airBox.show( g_tr("changeSuccess") ,1)
                    self.callback()
                    self:close()
                end
                
                return
            end

            local count = g_BagMode.findItemNumberById( NAME_CARD_ID_TYPE )
            if count > 0 then
                g_msgBox.show( g_tr("SureRename"),nil,2,
                function ( eventtype )
                    --确定
                    if eventtype == 0 then 
                        if MODE:masterRenameAction( namestr ) then
                            g_airBox.show( g_tr("changeSuccess") ,1)
                            self.callback()
                            self:close()
                        end
                    end
                end , 1)
            else
                local cost = g_data.cost[NAME_RNAME_COST_ID_TYPE].cost_num
                g_msgBox.showConsume(cost, g_tr("SureRename"), nil, g_tr("save"), function ()
                    if MODE:masterRenameAction( namestr ) then
                        g_airBox.show( g_tr("changeSuccess") ,1)
                        self.callback()
                        self:close()
                    end
                end)
            end
        else
            if namestr == "" then
                g_airBox.show( g_tr( "NickEmptyError" ),3 )
                --print("主公名称不能为空") 
            end

            if tostring(self.master_data.nick) == tostring(namestr) then
                g_airBox.show( g_tr( "NickSameError" ),3 )
                --print("主公名称不能与当前昵称相同") 
            end
        end
	end)

    local saveTx = save_btn:getChildByName("Text_3")
    saveTx:setString(g_tr( "save" ))

    --不是免费
    if self.firstCN == NAME_RNAME_NO_FIRST then
        if g_BagMode.findItemNumberById(NAME_CARD_ID_TYPE) > 0 then
            self.root:getChildByName("Text_1_0"):setVisible(false)
            gold_icon:setVisible(false)
            gold_tx:setVisible(false)
            saveTx:setPositionY( saveTx:getPositionY() - 12 )
        else
            gold_tx:setString( tostring( g_data.cost[NAME_RNAME_COST_ID_TYPE].cost_num ) )
        end
    elseif self.firstCN == NAME_RNAME_FIRST then
         gold_tx:setString( g_tr("battleMoveFree") )
    end

    
end

function MasterCNameView:onEnter( )
	print("MasterCNameView onEnter")
end

function MasterCNameView:onExit( )
    MODE = nil
	print("MasterCNameView onExit")
end


return MasterCNameView