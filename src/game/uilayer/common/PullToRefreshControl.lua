
--ListView 下拉/上拉更新控件


local PullToRefreshControl = class("PullToRefreshControl", function() return ccui.Widget:create() end )


function PullToRefreshControl:ctor()

end 

function PullToRefreshControl:initLoadingBar(target)
  self.minY = nil 
  self.isMoving = false   

  local size = target:getContentSize()
  self.imgBg = ccui.ImageView:create("freeImage/bg_pull_refresh.png")
  if self.imgBg then 
    self:addChild(self.imgBg)
    self:setVisible(false)

    local listSize = target:getContentSize()
    local bgSize = cc.size(listSize.width, self.imgBg:getContentSize().height)
    self.imgBg:ignoreContentAdaptWithSize(false)
    self.imgBg:setScale9Enabled(true)
    self.imgBg:setContentSize(bgSize)

    self.imgLoading = ccui.ImageView:create("cocos/cocostudio_res/common/pic_loading.png")
    if self.imgLoading then 
      self.imgLoading:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
      self.imgLoading:setPosition(cc.p(bgSize.width/2-100, bgSize.height/2))
      self.imgBg:addChild(self.imgLoading)
    end 

    self.textTips = ccui.Text:create(g_tr_original("pullToRefresh"), "Arial", 26)
    self.textTips:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self.textTips:setPosition(cc.p(self.imgLoading:getPositionX() + 100, self.imgLoading:getPositionY()))
    self.imgBg:addChild(self.textTips)
  end 
end 

--拖动列表向上/向下刷新
function PullToRefreshControl:addListner(target, upRefreshCb, downRefreshCb)
  if nil == target then return end 

  -- target:setBounceEnabled(true)
  self:initLoadingBar(target)


  -- ccui.ScrollviewEventType = {
  --     scrollToTop =  0,
  --     scrollToBottom =  1,
  --     scrollToLeft = 2,
  --     scrollToRight = 3,
  --     scrolling = 4,
  --     bounceTop = 5,
  --     bounceBottom = 6,
  --     bounceLeft = 7,
  --     bounceRight = 8,
  --     containerMoved = 9,
  -- }
  local function onScrollViewEvent(sender, eventType) 
    if eventType == 9 then return end  --containerMoved
    
    if nil == self.imgBg then return end 
    
    -- print("eventType:", eventType) 

    --计算拉动的幅度
    local listSize = sender:getContentSize()    
    if nil == self.minY then --记录处于顶部时Y的坐标
      self.minY = listSize.height - sender:getInnerContainerSize().height
    end 
    local list_y = sender:getInnerContainerPosition().y 
    local deltaH = self.minY - list_y
    local tipSize = self.imgBg:getContentSize() 
    local pos_y 
    if list_y < 0 then --往下拉
      pos_y = sender:getInnerContainerSize().height + tipSize.height
    else  --往上拉
      pos_y = - tipSize.height
    end 
    self:setPosition(cc.p(listSize.width/2, pos_y))


    if eventType == ccui.ScrollviewEventType.scrolling then --按着移动
      self.isMoving = true 

      self.needToTips = false 
      --根据拉动幅度, 显示/隐藏tips 
      if list_y < 0 then --下拉  
        if upRefreshCb then 
          if deltaH > 3*tipSize.height then --提示释放刷新
            self:setVisible(true)
            self.imgLoading:setVisible(false)
            self.textTips:setVisible(true)
            self.textTips:setString(g_tr_original("releaseToRefresh"))

            self.needToTips = true 

          elseif deltaH > 0.5*tipSize.height then  --提示向下刷新tips
            self:setVisible(true)
            self.imgLoading:setVisible(false)
            self.textTips:setVisible(true)
            self.textTips:setString(g_tr_original("pullToRefresh")) 
          end 
        end 

      else --上拉
        if downRefreshCb then 
          if list_y > 3*tipSize.height then --提示释放刷新
            self:setVisible(true)
            self.imgLoading:setVisible(false)
            self.textTips:setVisible(true)
            self.textTips:setString(g_tr_original("releaseToRefresh"))
            self.needToTips = true 

          elseif list_y > tipSize.height then --提示向上获取更多
            self:setVisible(true)
            self.imgLoading:setVisible(false)
            self.textTips:setVisible(true)
            self.textTips:setString(g_tr_original("pullToGetMore")) 
          end 
        end 
      end 

    elseif eventType == ccui.ScrollviewEventType.bounceTop then --松开手后往顶部回弹 
      if self.isMoving and self.needToTips then --上一状态为按着移动
        self:setVisible(false) 

        if upRefreshCb then 
          upRefreshCb()
        end 
        self.isMoving = false 
        self.needToTips = false 
      end 

    elseif eventType == ccui.ScrollviewEventType.bounceBottom then --松开手后往底部回弹 
      if self.isMoving and self.needToTips then --上一状态为按着移动
        self:setVisible(false) 

        if downRefreshCb then 
          downRefreshCb()
        end 
        self.isMoving = false 
        self.needToTips = false 
      end       
    end 
    
    --如果没有对应的刷新回调函数, 则不显示提示 
    if (list_y < 0 and nil == upRefreshCb) or (list_y >= 0 and nil == downRefreshCb) then 
      self:setVisible(false) 
    end 
  end 

  target:addScrollViewEventListener(onScrollViewEvent) 
end 


return PullToRefreshControl 
