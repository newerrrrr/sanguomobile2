local MasterTalentView = class("MasterTalentView", require("game.uilayer.base.BaseLayer"))

--local MODE = nil
--local masterdata = nil
--local talentdatalist = {}
--local talentdatakv = {}
local DISUP = 1
local CANUP = 2
local MAXUP = 3
local RESETITEMID = 23601

function MasterTalentView:createLayer( jumpID )
 
    self:clearGlobal()
        
    self.masterdata = g_PlayerMode.GetData()

    --if g_MasterTalentMode.RequestData() then
    self.talentdatalist = g_MasterTalentMode.GetData()
    --end

    if self.masterdata and self.talentdatalist then
        g_sceneManager.addNodeForUI( MasterTalentView:create( jumpID ) )
    end
    
end


function MasterTalentView:ctor(  jumpID )
	MasterTalentView.super.ctor(self)

    self.mapList = {}
    self.jumpId = jumpID  --需要跳转的ID
    self.jump2X = 0       --需要跳转的位置
    self.jumpNode = nil
    self:initUI()
end

function MasterTalentView:initUI()
    
	self.layer = self:loadUI("skill_tree_main.csb")
	self.root = self.layer:getChildByName("scale_node")
    g_resourcesInterface.installResources(self.layer)
	local close_btn = self.root:getChildByName("close_btn")
	self:regBtnCallback(close_btn,function ()
        g_musicManager.playEffect(g_SOUNDS_CANCLE_PATH)
		self:close()
	end)

	--local sel_tab = nil

    self.root:getChildByName("Text_bt"):setString(g_tr("MasterTalent"))
    self.root:getChildByName("Text_12"):setString(g_tr("TalentPoint"))
	local function tabTouchListener( sender,eventType )
		if eventType == ccui.TouchEventType.ended then
			--print("touch")
            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
			sender:setEnabled(false)
			--sender.title:setVisible(true)
			sender.map:setVisible(true)
			sender.map.setviewsizefun()

			self.sel_tab:setEnabled(true)
			--sel_tab.title:setVisible(false)
			self.sel_tab.map:setVisible(false)
			self.sel_tab = sender
		end
	end

	local attack_tab_btn = self.root:getChildByName("Button_1")  --进攻
	attack_tab_btn:addTouchEventListener(tabTouchListener)
    attack_tab_btn:getChildByName("Text"):setString(g_tr("TalentAttack"))

	local build_tab_btn = self.root:getChildByName("Button_2")   --建设
	build_tab_btn:addTouchEventListener(tabTouchListener)
	build_tab_btn:getChildByName("Text"):setString(g_tr("TalentInter"))

	local grow_tab_btn = self.root:getChildByName("Button_3")    --发展
	grow_tab_btn:addTouchEventListener(tabTouchListener)
    grow_tab_btn:getChildByName("Text"):setString(g_tr("TalentDevelop"))
    
    local reTalnetBtn = self.root:getChildByName("Button_cz")
    reTalnetBtn:addTouchEventListener( handler(self,self.resetTalentPoint) )
    self.root:getChildByName("Text_cz"):setString(g_tr("ReTalentPointStr"))

	self.sview = self.root:getChildByName("ScrollView_1")

	attack_tab_btn.map,jump1 = self:talentAttack()
	build_tab_btn.map,jump2 = self:talentBuild()
	grow_tab_btn.map,jump3 = self:talentGrow()
    
    table.insert(self.mapList,attack_tab_btn.map)
    table.insert(self.mapList,build_tab_btn.map)
    table.insert(self.mapList,grow_tab_btn.map)
	--初始化显示第一个
    self.sel_tab = attack_tab_btn

    if jump1 then
        self.sel_tab = attack_tab_btn
    end

    if jump2 then
        self.sel_tab = build_tab_btn
    end

    if jump3 then
        self.sel_tab = grow_tab_btn
    end
    
    self.sel_tab:setEnabled(false)
	self.sel_tab.map:setVisible(true)
	self.sel_tab.map.setviewsizefun()

    self.root:getChildByName("Text_12_0"):setString( g_tr("TalentPoint") )
    self.pnum_tx = self.root:getChildByName("Text_12_0")
    self.pnum_tx:setString( tostring(self.masterdata.talent_num_remain)  )
end


function MasterTalentView:talentMap( namepath ,map_type)
	local map = cc.CSLoader:createNode( namepath )
    local isjump = false
	if map then
		self.sview:addChild( map )
		map:setPositionY( map:getPositionY() + 18 )
        local node = cc.CSLoader:createNode("skill_item.csb")
		local nodePanel =  map:getChildByName("scoll_content")
		local ctd = g_data.talent
        --天赋技能配置表数据
		local mapdata = {}
        --将天赋技能配置进行分类 设施，内政，发展
		for k,v in pairs(ctd) do
			if v.type == map_type then
                
                if v.id == self.jumpId then
                    isjump = true
                end

				if mapdata[ tostring(v.talent_type_id)] == nil then
					mapdata[ tostring(v.talent_type_id)] = {}
				end
				table.insert( mapdata[ tostring(v.talent_type_id)],v )
			end
		end
        --将其按照等级排序
		for k,v in pairs(mapdata) do
			table.sort( v, function (a,b)
				return a.level_id < b.level_id
			end )
		end
        
        --updateUI start 公共刷新界面方法
        local updateUI = nil
        updateUI = function()
            self.talentdatalist = {}
            self.talentdatalist = g_MasterTalentMode.GetData()
            
            local keyValueData = {}

            if self.talentdatalist == nil then
                return
            end

            for _, talentdata in ipairs(self.talentdatalist) do
                --sprint("talentdata.talent_id",talentdata.talent_id,type(talentdata.talent_id))
                keyValueData[  talentdata.talent_id ] = talentdata
            end
            


            --dump(keyValueData)

            --for start
		    for k,mapinfo in pairs(mapdata) do
                
			    local tnode = nodePanel:getChildByName("item_" .. k)
                g_guideManager.registComponent(8000000 + tonumber(k),tnode)
                
                local item = tnode:getChildByTag(1000)
                
                --是否已经创建
                if item == nil then
			        item = node:clone()
                    item:setTag(1000)
                    item:setAnchorPoint(cc.p(0.5,0.5))
			        tnode:addChild(item)
                end

                local node = item:getChildByName("item")

                --默认选中第一个
			    local nowdata = nil

			    local nowindex = 0
			    local nowlevel = 0

			    local pic = node:getChildByName("pic")
			    local name = node:getChildByName("name")
			    local lv = node:getChildByName("level")
                local isopen = false
                
                --[[for _,data in ipairs(mapinfo) do
                    for __, value in ipairs(self.talentdatalist) do
                        --print("value.talent_id,data.id",value.talent_id,data.id)
                        if value.talent_id == data.id then
                            nowdata = data
                            break
                        end
                    end

                    if nowdata then
                        nowlevel = nowdata.level_id
                        break
                    end
                end]]

                for _,data in ipairs(mapinfo) do
                    
                    --print("data.id",data.id,type(data.id),keyValueData[data.id])

                    if keyValueData[data.id] then
                        nowdata = data
                        nowlevel = nowdata.level_id
                        break
                    end
                end
                
                --dump(nowdata)

                --如果没有等级 初始化等级为0，显示一级的信息
				if nowdata == nil then
					nowdata = mapinfo[1]
                    nowlevel = 0
				end

                if self.jumpId == nowdata.id then
                    self.jump2X = tnode:getPositionX()
                    self.jumpNode = item
                    --print("self.jump2X",self.jump2X)
                end

                if item.fx == nil then
                    MasterTalentView:createSkillFx( item,nowdata.id )
                end
                
                --g_data.master_skill
                --检索当前天赋的前置天赋是否存已经点亮
				for i,v in ipairs(nowdata.condition_talent) do
                    --前置天赋为0的代表不需要前置天赋一般出现在天赋树的第一个天赋 
					if keyValueData[v] or v == 0 then
						isopen = true
						break
					end 
				end

                local iconid = nowdata.img
				pic:loadTexture( g_resManager.getResPath(iconid) )

				if nowlevel == 0 and not isopen then
					pic:getVirtualRenderer():setGLProgramState( cc.GLProgramState:getOrCreateWithGLProgramName( g_shaders.shaderMode.shader_gray ) )
				end

				name:setString(  g_tr( nowdata.talent_name ) )
				lv:setString(string.format( "%d/%d",nowlevel,nowdata.max_level ))
                if nowlevel == nowdata.max_level then
                    lv:setColor(  cc.c3b(72,255,99) )
                end

                g_guideManager.registComponent(8000000 + tonumber(k),pic)
                
                
                node.nowdata = nowdata
                node.nowlevel = nowlevel
                node.isopen = isopen


                local MasterTalentUpgrade = require("game.uilayer.master.MasterTalentUpgrade")

                --start 这个地方要修改 重复监听
                if node.isTouch == nil then
                    --print("我在这里监听了")
			        node:addTouchEventListener(function ( sender,eventType )
				        if eventType == ccui.TouchEventType.ended then
                            g_musicManager.playEffect(g_SOUNDS_SURE_PATH)
					        if node.nowlevel == 0 then
						        --已经满足条件 天赋开启
						        if node.isopen then
							        local upgradelayer = MasterTalentUpgrade:create(CANUP,node.nowdata.id)
							        upgradelayer:setcallback( function (  )
                                    
                                        --新手引导
                                        if g_guideManager.getLastShowStep() then
                                            self:close()
                                            g_guideManager.execute()
                                            return
                                        end

								        --更新UI
                                        if map.update then
                                            map.update()
                                        end
                                        --更新天赋点
                                        self.masterdata = g_PlayerMode.GetData()
                                        self.pnum_tx:setString(  tostring( self.masterdata.talent_num_remain ) )

							        end )
							        g_sceneManager.addNodeForUI( upgradelayer )
                                    
						        else
						        --没有满足条件
							        g_sceneManager.addNodeForUI(MasterTalentUpgrade:create(DISUP,node.nowdata.id ))
						        end
					        else
						        --天赋升至满级
						        if node.nowdata.next_talent == -1 then
							        g_sceneManager.addNodeForUI(MasterTalentUpgrade:create(MAXUP,node.nowdata.id))
						        else
						        --正常升级条件
							        local upgradelayer = MasterTalentUpgrade:create(CANUP,node.nowdata.id)
							        upgradelayer:setcallback( function (  )
                                    
                                        --新手引导
                                        if g_guideManager.getLastShowStep() then
                                            self:close()
                                            g_guideManager.execute()
                                            return
                                        end

                                        --更新UI
                                        if map.update then
                                            map.update()
                                        end
                                        --updateUI()
                                        --更新天赋点
                                        self.masterdata = g_PlayerMode.GetData()
                                        self.pnum_tx:setString( tostring(self.masterdata.talent_num_remain ) )
							        end )
							        g_sceneManager.addNodeForUI( upgradelayer )
						        end
					        end
				        end
			        end)--end
                end
                node.isTouch = true
            end--for end
		end--updateUI end

        map.update = updateUI

        if map.update then
            map.update()
        end

	else
		print("load cocos error")
	end

	map:setVisible(false)
	map.setviewsizefun = function (  )
		self.sview:setInnerContainerSize(cc.size(map:getContentSize().width,self.sview:getContentSize().height))
	end


	return  map,isjump
end

function MasterTalentView:talentAttack(  )
	return self:talentMap( "skill_tree_1.csb",1 )
end

function MasterTalentView:talentBuild(  )
	return self:talentMap( "skill_tree_2.csb",2 )
	
end

function MasterTalentView:talentGrow(  )
	return self:talentMap( "skill_tree_3.csb",3 )
end

function MasterTalentView:onEnterTransitionFinish()
    
    g_guideManager.execute()
    if self.sview == nil then
        return
    end

    local junptox = math.ceil( (self.jump2X / self.sview:getInnerContainerSize().width) * 100 )
    self.sview:jumpToPercentHorizontal(junptox)

    print("jumpNode",self.jumpNode)


    if self.jumpNode ~= nil then
        --local scale = cc.ScaleTo:create(1,1.5)
        --self.jumpNode:runAction( scale )

        --播放特效
    end
end

--创建主动技能特效
function MasterTalentView:createSkillFx( target,skillid )
    
    local skill_config = g_data.master_skill[skillid]
    if skill_config then
        local armature , animation
        armature , animation = g_gameTools.LoadCocosAni(
            "anime/YanJiouSuo_KeJiXuanWo/YanJiouSuo_KeJiXuanWo.ExportJson"
            , "YanJiouSuo_KeJiXuanWo"
        )

        armature:setPosition( cc.p(target:getPositionX(),target:getPositionY()+ 13) )
        target:getParent():addChild(armature,-1)
        animation:play("Animation1") 
        target.fx = animation
    end
end

--重置天赋点
function MasterTalentView:resetTalentPoint(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        --print("读cost表获取重置价格")
        if self.masterdata.talent_num_total == self.masterdata.talent_num_remain then
            g_airBox.show(g_tr("ReTalentNoNeed"),2)
            return
        end

        local function send()
            g_sgHttp.postData("Player/talentReset",nil,function (result, data)
                if result == true then
                    self.masterdata = g_PlayerMode.GetData()
                    for key, tree in ipairs(self.mapList) do
                        if tree.update then
                            tree.update()
                        end
                    end
                    self.pnum_tx:setString(  tostring( self.masterdata.talent_num_remain ) )
                    g_airBox.show( g_tr("ReTalentPointS"),1)
                end
            end )
        end

        local itemNum = g_BagMode.findItemNumberById(RESETITEMID)

        if itemNum > 0 then
            g_msgBox.show( g_tr("ReTalentPoint"),nil,2,
            function ( eventtype )
                --确定
                if eventtype == 0 then 
                    send()
                end
            end , 1)
        else
            local cost = g_data.cost[30601].cost_num
            g_msgBox.showConsume(cost, g_tr("ReTalentPoint"), nil, nil, function ()
                send()
            end)
        end
    end
end

function MasterTalentView:onEnter( )
	print("MasterTalentView onEnter")
end


function MasterTalentView:onExit( )
	print("MasterTalentView onExit")
    require("game.uilayer.master.MasterView"):talentRedPointUpdate()
    self:clearGlobal()
end

function MasterTalentView:clearGlobal()
    self.masterdata = nil
    self.talentdatalist = {}
end

return MasterTalentView