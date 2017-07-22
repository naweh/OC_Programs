-----------------------木こりプログラム-------------------------------
-- 予め定められた特定の場所に植えられた木を伐採・植林する
-- ※Slot1に苗木を必要数持たせておく
-- ※南を向かせておく
-- require upgrade : tractor_beam
--------------------------------------------------------------------

local component = require("component")
local robot = require("robot")
local sides = require("sides")
local shell = require("shell")

-- 変数の準備
local r = component.robot
local dx, dy, dz = 0, 0, 0   -- (dx, dy, dz)は初期座標を(0, 0, 0)としてロボットの現在座標を相対座標で記録する
local f = 0                       -- ロボットの向いている方角の初期値は南とする
local plantingPoints = {    -- 木が植えられる場所の相対座標の配列
    {2, 0, 2}, {5, 0, 2}, {8, 0, 2}, {11, 0, 2},
    {11, 0, 5}, {8, 0, 5}, {5, 0, 5}, {2, 0, 5},
    {2, 0, 8}, {5, 0, 8}, {8, 0, 8}, {11, 0, 8},
    {11, 0, 11}, {8, 0, 11}, {5, 0, 11}, {3, 0, 11}
}
local nPlantingPoints = #plantingPoints
local chestPoints = {       -- チェストの相対座標の配列
    {1, 0, 0}
}
local nChestPoint = #chestPoints

-- 本プログラムを起動しているのがタートルでなければ終了
if not component.isAvailable("robot") then
    io.stderr:write("can only run on robots")
    return
end

-- タートルにtractor_beamのアップグレードがないなら終了
if not component.isAvailable("tractor_beam") then
    io.stderr:write("can only run on robots with tractor_beam")
    return
end

---------------- Sub Procedure ----------------
function TurnToLeft()
    r.turn(false)
    f = (f + 3) % 4
end

function TurnToRight()
    r.turn(true)
    f = (f + 1) % 4
end

function TurnToSouth()
    while f ~= 0 do
        TurnToRight()
    end
end

function MoveToFront()
    if f == 0 then
        if r.move(sides.front) then
            dz = dz + 1
            return true
        end
    elseif f == 1 then
        if r.move(sides.front) then
            dx = dx - 1
            return true
        end
    elseif f == 2 then
        if r.move(sides.front) then
            dz = dz - 1
            return true
        end
    elseif f == 3 then
        if r.move(sides.front) then
            dx = dx + 1
            return true
        end
    end

    return false
end

function MoveToPosX()
    if f == 0 then
        TurnToLeft()
        if r.move(sides.front) then
            dx = dx + 1
            return true
        end
    elseif f == 1 then
        TurnToRight()
        TurnToRight()
        if r.move(sides.front) then
            dx = dx + 1
            return true
        end
    elseif f == 2 then
        TurnToRight()
        if r.move(sides.front) then
            dx = dx + 1
            return true
        end
    elseif f == 3 then
        if r.move(sides.front) then
            dx = dx + 1
            return true
        end
    end
    return false
end

function MoveToNegX()
    if f == 0 then
        TurnToRight()
        if r.move(sides.front) then
            dx = dx - 1
            return true
        end
    elseif f == 1 then
        if r.move(sides.front) then
            dx = dx - 1
            return true
        end
    elseif f == 2 then
        TurnToLeft()
        if r.move(sides.front) then
            dx = dx - 1
            return true
        end
    elseif f == 3 then
        if r.move(sides.front) then
            TurnToLeft()
            TurnToLeft()
            dx = dx - 1
            return true
        end
    end
    return false
end

function MoveToPosZ()
    if f == 0 then
        if r.move(sides.front) then
            dz = dz + 1
            return true
        end
    elseif f == 1 then
        TurnToLeft()
        if r.move(sides.front) then
            dz = dz + 1
            return true
        end
    elseif f == 2 then
        TurnToRight()
        TurnToRight()
        if r.move(sides.front) then
            dz = dz + 1
            return true
        end
    elseif f == 3 then
        TurnToRight()
        if r.move(sides.front) then
            dz = dz + 1
            return true
        end
    end
    return false
end

function MoveToNegZ()
    if f == 0 then
        TurnToRight()
        TurnToRight()
        if r.move(sides.front) then
            dz = dz - 1
            return true
        end
    elseif f == 1 then
        TurnToRight()
        if r.move(sides.front) then
            dz = dz - 1
            return true
        end
    elseif f == 2 then
        if r.move(sides.front) then
            dz = dz - 1
            return true
        end
    elseif f == 3 then
        TurnToLeft()
        if r.move(sides.front) then
            dz = dz - 1
            return true
        end
    end
    return false
end

function MoveToPosY()
    if r.move(sides.up) then
        dy = dy + 1
        return true
    end
    return false
end

function MoveToNegY()
    if r.move(sides.down) then
        dy = dy - 1
        return true
    end
    return false
end

function MoveToPoint(x, y, z)
    -- 変数の準備
    local moved = false
    local noMoveCnt = 0

    -- かなり適当な移動アルゴリズム
    while dz ~= z do
        moved = false
        if dz < z then
            if MoveToPosZ() then
                moved = true
            else
                MoveToPosY()
            end
        else
            if MoveToNegZ() then
                moved = true
            else
                MoveToPosY()
            end
        end

        if not moved and (dz ~= z - 1 or dz ~= z + 1) then
            MoveToFront()
            break
        end
    end

    while dx ~= x do
        moved = false
        if dx < x then
            if MoveToPosX() then
                moved = true
            else
                MoveToPosY()
            end
        else
            if MoveToNegX() then
                moved = true
            else
                MoveToPosY()
            end
        end

        if not moved and (dx ~= x - 1 or dx ~= x + 1) then
            MoveToFront()
            break
        end
    end

    while dy ~= y do
        if dy < y then
            if MoveToPosY() then
                moved = true
            else
                break
            end
        else
            if MoveToNegY() then
                moved = true
            else
                break
            end
        end
    end

    if y ~= dz then
        return -1
    end

    if math.abs(dx - x) + math.abs(dz - z) ~= 1 then
        return 0
    end

    return 1
end

function MoveToFacePoint(x, y, z)
    MoveToPoint(x, y, z)

    -- 指定座標の上に立っていたらfalseリターン
    if dx == x and dy == y and dz == z then
        return false
    end

    -- 指定座標に面していないならfalseリターン
    local diff = math.abs(dx - x) + math.abs(dz - z)
    if diff ~= 1 or dy ~= y then
        return false
    end

    -- 指定座標の方を向く
    local face = 0
    if dx == x then
        if dz < z then
            face = 0
        else
            face = 2
        end
    else
        if dx < x then
            face = 3
        else
            face = 1
        end
    end

    while f ~= face do
        TurnToRight()
    end

    return true
end

function TreeChopAndPlant()
    -- 固体ブロック(原木)でなければfalseをリターン
    local b, str = r.detect(sides.front)
    if str ~= "solid" then
        return false, "not solid"
    end

    -- その個体ブロックを破壊
    b = r.swing(sides.front)
    if not b then
        return false, "can not break"
    end

    -- 破壊したブロックの座標に移動
    MoveToFront()

    -- 上方向に伐採(TODO:Exception Check)
    local y = 0
    while r.detect(sides.up) do
        r.swing(sides.up)
        MoveToPosY()
        y = y + 1
    end

    -- 元の座標へ移動
    while y ~= 0 do
        MoveToNegY()
        y = y - 1
    end

    -- 植林
    MoveToFront()
    robot.turnAround()
    r.select(1)
    r.place(sides.front)
    robot.turnAround()

    return true, "success"
end

function IsHaveSpace()
    local slotIdx = 2
    for slotIdx=2, r.inventorySize() do
        if 0 < r.space(slotIdx) then
            return true
        end
    end
    return false
end

function StoreToChest()
    -- 各チェストを巡回
    for i=1, nChestPoint do
        local x = chestPoints[i][1]
        local y = chestPoints[i][2]
        local z = chestPoints[i][3]

        -- チェストまで移動
        local b = MoveToFacePoint(x, y, z)
        if not b then
            io.stderr:write("Failed to chest point (%s, %s, %s)", x, y, z)
            break
        end

        -- アイテムを格納
        local slotIdx = 2
        for slotIdx = 2, r.inventorySize() do
            r.select(slotIdx)
            r.drop(sides.front)
        end
    end
    return true
end

function ReturnToHome()
    -- 初期座標へ移動
    if not MoveToPoint(0, 0, 0) then
        return false
    end
    
    TurnToSouth()
    return true
end


---------------- Main Process ----------------
while true do
    -- 各植林ポイントを巡回し、木が成長していれば伐採・植林
    print("--- formated Tree Capitor Program ---")
    for i=1, nPlantingPoints do
        local x = plantingPoints[i][1]
        local y = plantingPoints[i][2]
        local z = plantingPoints[i][3]

        print(string.format( "[%s] Moving to (%s, %s, %s)", i, x, y, z ))
        local b = MoveToFacePoint(x, y, z)
        if not b then
            io.stderr:write(string.format( "[%s] Failed moving", i ))
        end

        -- 木が成長していれば伐採・植林
        print(string.format( "[%s] Trying to Chop", i ))
        if TreeChopAndPlant() then
            -- 周囲に落ちた苗木を回収
            print(string.format( "[%s] Suck around", i ))
            while component.tractor_beam.suck() do
            end

            if not IsHaveSpace() then
                print(string.format( "[%s] No Space, Go to chest for store", i ))
                StoreToChest()
            end
        end
    end

    -- 初期配置へ戻る
    StoreToChest()
    ReturnToHome()

    -- 180sec待機
    shell.execute("sleep 180")

end