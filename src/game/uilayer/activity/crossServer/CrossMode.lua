local CrossMode = class("CrossMode")

function CrossMode:ctor()

end

function CrossMode:basicInfo(fun)
	local function callback(result, data)
        g_busyTip.hide_1()

        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
    end

    g_busyTip.show_1()

    g_netCommand.send("cross/basicInfo", {}, callback, true)
end

function CrossMode:joinBattle(fun)
	local function callback(result, data)
        if result == true then
            if fun ~= nil then
                self:basicInfo(fun)
            end
        end
    end

    g_netCommand.send("cross/joinBattle", {}, callback, false)
end

function CrossMode:commitBattleMemberList(playerList, fun)
	local tbl = 
	{
		["List"] = playerList,
	}

	local function callback(result, data)
        if result == true then
            if fun ~= nil then
                fun(data)
            end
        end
    end

    g_netCommand.send("cross/commitBattleMemberList", tbl, callback, false)
end

function CrossMode:applyToJoinBattle(fun)
	local function callback(result, data)
        if result == true then
            g_airBox.show(g_tr("appSucc"))
            if fun ~= nil then
                fun()
            end
        end
    end

    g_netCommand.send("cross/applyToJoinBattle", {}, callback, false)
end


return CrossMode