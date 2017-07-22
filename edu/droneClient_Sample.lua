local component = require("component")
local event = require("event")
local modem = component.modem

-- ポート2412でサーバに接続
modem.open(2412)
modem.broadcast(2412, "drone = component.proxy(component.list('drone')())")

while (true) do
    local cmd = io.read()
    if (not cmd) then
        return
    end
    
    --入力された文字がnullでないならサーバに送信
    modem.broadcast(2412, cmd)
    print(select(6, event.pull(5, "modem_message")))
end