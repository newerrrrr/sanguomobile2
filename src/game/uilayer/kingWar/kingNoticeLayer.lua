--region NewFile_1.lua
--Author : admin
--Date   : 2016/10/10
--此文件由[BabeLua]插件自动生成
local kingNoticeLayer = class("kingNoticeLayer", require("game.uilayer.base.BaseLayer"))


function kingNoticeLayer.createLayer(data)
    g_sceneManager.addNodeForUI( require("game.uilayer.kingWar.kingNoticeLayer"):create(data))
end

function kingNoticeLayer:ctor(data)
    
    --更新皇帝BUFF
    dump(data)
    if tonumber(data.king_player_id) == tonumber(g_PlayerMode.GetData().id) then
        g_BuffMode.RequestDataAsync()
    end
    
    kingNoticeLayer.super.ctor(self)
    
    self.layer = self:loadUI("zhuchengjiemian_06.csb")

    self.root = self.layer:getChildByName("scale_node")
    
    local showStr = data.king_nick
    
    local panel = self.root:getChildByName("Panel_1")

    local showTxt1 = panel:getChildByName("Text_1")
    local showTxt2 = panel:getChildByName("Text_2")
    local showTxt3 = panel:getChildByName("Text_3")
    local showTxt4 = panel:getChildByName("Text_4")

    showTxt1:setString( g_tr("kwar_appiontKing1") )
    showTxt2:setString(data.king_nick)
    showTxt3:setString( g_tr("kwar_appiontKing2") )
    showTxt4:setString( g_tr("kwar_appiontKing3") )

    panel:setScale(0.3)

    local run = cc.ScaleTo:create(0.3,1)
    local run1 = cc.FadeOut:create( 0.5 )
    --cc.ScaleTo:create(0.5,0.7)
    local fun = cc.CallFunc:create( function ()
        self:close()
    end )

    panel:runAction(   cc.Sequence:create( run, cc.DelayTime:create(4),run1,  fun ))
    
    local armature , animation = g_gameTools.LoadCocosAni("anime/Effect_QuanPingYanHua/Effect_QuanPingYanHua.ExportJson","Effect_QuanPingYanHua")
    armature:setPosition( cc.p(self.root:getContentSize().width/2,self.root:getContentSize().height/2) )
    self.root:addChild(armature)
    animation:play("Animation1")
end




function kingNoticeLayer:onEnter()
    
end


function kingNoticeLayer:onExit()

end

--关闭





return kingNoticeLayer

--endregion
