-- ポート2412で待機
local modem = component.proxy(component.list("modem")())
modem.open(2412)

-- クライアントからのメッセージに受信応答
local function respond(...)
    local args = table.pack(...)
    pcall(
        function()
            modem.broadcast(2412, table.unpack(args))
        end
    )
end

-- クライアントからのメッセージを受信
local function receive()
    while (true) do
        local evt, _, _, _, _, cmd = computer.pullSignal()
        if (evt == "modem_message") then
            -- 受信したシグナルがクライアントからのメッセージなら、
            -- 受信メッセージを解釈して、その結果を返す
            return load(cmd)
        end
    end
end

---------- Main Process ----------
while (true) do
    local result, reason = pcall(
        function()
            -- メッセージを受信
            local result, reason = receive()
            if (not result) then
                -- 解釈可能なメッセージだったらば、その結果を応答する
                return respond(reason)
            end
        respond(result())
        end
    )

    if (not result) then
        respond(reason)
    end
end