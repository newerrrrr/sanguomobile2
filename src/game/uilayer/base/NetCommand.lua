--region NetCommand.lua
--Author : luqingqing
--Date   : 2015/10/26
--此文件由[BabeLua]插件自动生成

local NetCommand = {}
setmetatable(NetCommand,{__index = _G})
setfenv(1,NetCommand)

function send(url, table, fun, isAsync)
    isAsync = isAsync or false
    g_sgHttp.postData(url, table, fun, isAsync)
end

return NetCommand

--endregion
