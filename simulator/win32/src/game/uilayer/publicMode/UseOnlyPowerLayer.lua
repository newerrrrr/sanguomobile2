--region 单人出征调用的加速界面
--Author : admin
--Date   : 2016/12/1
--此文件由[BabeLua]插件自动生成

local UseOnlyPowerLayer = class("UseOnlyPowerLayer", require("game.uilayer.base.BaseLayer"))

function UseOnlyPowerLayer:ctor(queueServerData)
    UseOnlyPowerLayer.super.ctor(self)
    self.rundata = queueServerData
    dump(self.queueServerData)
    self:initUI()
end

function UseOnlyPowerLayer:initUI()
    self.layout = self:loadUI("CityGain_main1.csb")
    self.root = self.layout:getChildByName("scale_node")

    --zhcn
    self.root:getChildByName("Text_b1"):setString(g_tr("RunQuickTitle"))
    self.root:getChildByName("Text_jl"):setString(g_tr("RunQuickModLength"))
    self.root:getChildByName("Text_xj"):setString(g_tr("RunQuickModTime"))


    local close_btn = self.layout:getChildByName("mask")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)
    
    self.useMoveBtn = self.root:getChildByName("Button_1")
    self.useMoveBtn:getChildByName("Text_1"):setString(g_tr("RunQuickMoveFinish"))


    local function useMove(queueServerDataID)
        local res = false
        local function onRecv(result, msgData)
		    if(result==true)then
			    require "game.maplayer.worldMapLayer_bigMap".requestMapAllData_Manual()
                res = true
		    end
	    end
        g_sgHttp.postData("map/acceQueue",{ queueId = queueServerDataID , itemId = -1 },onRecv)
        return res
    end

    
    self:regBtnCallback(self.useMoveBtn,function ()
        g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
		local needMove = self:updateRunLength()
        local playerMove = g_PlayerMode.getMove() or 0
        local useOverMove = playerMove - needMove
        --不够
        if useOverMove < 0 then
            local needGem = math.abs(useOverMove) * 2
            g_msgBox.showConsume(needGem, g_tr("RunQuickUseGemIsTrue"), nil, nil, function ()
                if self.rundata == nil then
                    g_airBox.show(g_tr("RunQuickComplete"),1)
                    return
                end

                if g_PlayerMode.getDiamonds() < needGem then
                    g_airBox.show(g_tr("no_enough_money"),3)
                    return
                end

                if useMove(self.rundata.id) then
                    self:close()
                    return
                end

            end)
        else --足够
            local function msgBoxCallBack(event)
                if event == 0 then
                    if self.rundata == nil then
                        return
                    end

                    if useMove(self.rundata.id) then
                        self:close()
                        return
                    end
                end
            end

            --大于十五分钟加以提示
            if needMove >= 15 then
                g_msgBox.show(g_tr("RunQuickUseMoveIsTrue",{num = needMove}),nil,nil,msgBoxCallBack,1)
            else
                local ss = useMove(self.rundata.id)
                print("=============================",ss)
                if ss then
                    self:close()
                    return
                end
            end
        end
	end)



    if self.rundata then
        --测试代码注释
        self:scheduleUpdateWithPriorityLua( handler( self,self.updateRunLength), 1)
    else
        self:close()
        return
    end

end

function UseOnlyPowerLayer:updateRunLength()
    
    local end_pos = cc.p( self.rundata.to_x,self.rundata.to_y )
    local now_pos = cc.p(0,0)
    local queueDisplay = require("game.maplayer.worldMapLayer_bigMap").getTeamInterface(self.rundata)

    if queueDisplay then
        now_pos = require("game.maplayer.worldMapLayer_helper").position_2_bigTileIndex(cc.p(queueDisplay:getPositionX(),queueDisplay:getPositionY())) or cc.p(0,0)
    end

    if self.rundata == nil or now_pos == nil or end_pos == nil then
        self:unscheduleUpdate()
        self:close()
        return
    end

     --剩余距离
    local runLength = cc.pGetDistance(now_pos,end_pos)
    --使用体力
    local moveNum = math.max(  math.floor(math.pow(runLength,0.911) * 0.45),5)

    if self.rundata.type == require("game.maplayer.worldMapLayer_queueHelper").QueueTypes.TYPE_CITYBATTLE_GOTO then
        moveNum = moveNum * ( tonumber( g_data.starting[104].data) or 1)
    end
    
    self.root:getChildByName("Text_sz"):setString( tostring(math.floor(runLength)) .. g_tr("worldmap_KM") )
    self.root:getChildByName("Text_xh"):setString( g_tr("RunQuickMoveUse") ..  tostring(moveNum) )
    
    local timebar = self.root:getChildByName("LoadingBar_1")
    local timetxt = self.root:getChildByName("Text_t1")
    local all_time = self.rundata.end_time - self.rundata.create_time
    
    --剩余时间
    local mod_time = self.rundata.end_time - g_clock.getCurServerTime() 
    
    timebar:setPercent( 100 - ( mod_time / all_time * 100 ) )
    timetxt:setString( string.format( "%02d:%02d:%02d",g_clock.formatTimeHMS( mod_time )) )

    if mod_time <= 10 then
        self.useMoveBtn:setEnabled(false)
    else
        self.useMoveBtn:setEnabled(true)
    end

    if mod_time == nil or mod_time <= 0 then
        self:unscheduleUpdate()
        self:close()
        return
    end
    return moveNum
end


return UseOnlyPowerLayer


--endregion
