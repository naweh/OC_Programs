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
            if (string.find(cmd, "create")) then
                local firstSep = string.find(cmd, " ")
                local secondSep = string.find(string.sub(cmd, firstSep + 1))
                local orderNumber = string.sub(cmd, firstSep, secondSep)
                if (string.find(cmd, "fire")) then return CreateFireRune(orderNumber) end
                if (string.find(cmd, "water")) then return CreateWaterRune(orderNumber) end
                if (string.find(cmd, "wind")) then return CreateWindRune(orderNumber) end
                if (string.find(cmd, "earth")) then return CreateEarthRune(orderNumber) end
                return "Usage: create [orderNumber] [runeType]\ne.g. create 10 rune of fire"
            end
        end
    end
end

-- ルーンのクラフト
function CreateFireRune(num)
    return "fire " .. num .. "create"
end

function CreateWaterRune(num)
    return "water " .. num .. "create"
end

function CreateWindRune(num)
    return "wind " .. num .. "create"
end

function CreateEarthRune(num)
    return "earth " .. num .. "create"
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