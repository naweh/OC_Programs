-----------------------木こりプログラム-------------------------------
-- 予め定められた特定の場所に植えられた木を伐採・植林する
-- ※Slot1に苗木を必要数持たせておく
-- ※南を向かせておく
-- require upgrade : tractor_beam
--------------------------------------------------------------------

local component = require("component")
local robot = require("robot")
local sides = require("sides")

-- 変数の準備
local r = component.robot
local dx, dy, dz = 0, 0, 0   -- (dx, dy, dz)は初期座標を(0, 0, 0)としてロボットの現在座標を相対座標で記録する
local f = 0                       -- ロボットの向いている方角の初期値は南とする
local plantingPoints = {    -- 木が植えられる場所の相対座標の配列
    {2, 0, 2}, {4, 0, 2}, {6, 0, 2}, {8, 0, 2},
    {8, 0, 4}, {6, 0, 4}, {4, 0, 4}, {2, 0, 4},
    {2, 0, 6}, {4, 0, 6}, {6, 0, 6}, {8, 0, 6},
    {8, 0, 8}, {8, 0, 6}, {8, 0, 4}, {8, 0, 2}
}
local nPlantingPoints = #plantingPoints
local chestPoints = {       -- チェストの相対座標の配列
    {0, 1, 0}
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
    while f == 0 do
        TurnToRight()
    end
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
end

function MoveToNegY()
    if r.move(sides.down) then
        dy = dy - 1
        return true
    end
end

function MoveToFacePoint(x, y, z)
    -- 変数の準備
    local moved = false

    -- かなり適当な移動アルゴリズム
    while true do
        moved = false

        -- 指定座標に面しているかチェック
        local diff = math.abs(dx - x) + math.abs(dz - z)
        if diff == 1 and dy == y then
            break
        end

        if dy ~= y then
            if dy < y then
                if MoveToPosY() then
                    moved = true
                end
            else
                if MoveToNegY() then
                    moved = true
                end
            end
        end

        if dz ~= z then
            if dz < z then
                if MoveToPosZ() then
                    moved = true
                end
            else
                if MoveToNegZ() then
                    moved = true
                end
            end
        end

        if dx ~= x then
            if dx < x then
                if MoveToPosX() then
                    moved = true
                end
            else
                if MoveToNegX() then
                    moved = true
                end
            end
        end

        -- 動けないなら終了
        if not moved then
            break
        end
    end

    -- 南を向く
    TurnToSouth()

    -- 指定座標の上に立っていたら後退
    if dx == x and dy == y and dz == z then
        MoveToNegZ()
    end

    -- 指定座標に面しているかチェック
    local diff = math.abs(dx - x) + math.abs(dz - z)
    if diff ~= 1 or dy ~= y then
        return false
    end

    -- 指定座標の方を向く
    if dx == x then
        if dz < z then
            -- already set
        else
            TurnToRight()
            TurnToRight()
        end
    else
        if dx < x then
            TurnToLeft()
        else
            TurnToRight()
        end
    end

    return true
end

function TreeChopAndPlant()
    -- 固体ブロック(原木)でなければfalseをリターン
    if not r.detect(sides.front) then
        return false, "not solid"
    end

    -- その個体ブロックを破壊
    if not r.swing(sides.front) then
        return false, "can not break"
    end

    -- 植林
    r.select(1)
    r.place(sides.front)

    -- 破壊したブロックの座標に移動
    if not r.move(sides.front) then
        return false, "failed move. item of slot 1 maybe solid"
    end

    -- 上方向に伐採(TODO:Exception Check)
    local y = 0
    while r.detect(sides.up) do
        r.swing(sides.up)
        MoveToPosY()
    end

    -- 元の座標へ移動
    while y ~= 0 do
        MoveToNegY()
    end

    r.move(sides.back)
    return true, "success"
end

function IsHaveSpace()
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
            io.stderr:write("failed move to point")
            break
        end

        -- アイテムを格納
        for slotIdx = 2, r.inventorySize() do
            r.select(slotIdx)
            if not r.drop(faceSide) then
                break
            end
        end

        -- 全アイテムを格納していれば終了
        if slotIdx == r.inventorySize() then
            return true
        end
    end

    -- 全チェストが一杯で格納できなかった場合falseリターン
    return false
end

function ReturnToHome()
    -- 初期座標へ移動
    local b = MoveToFacePoint(0, 0, 0)
    if not b then
        return false
    end
    r.move(sides.front)
    return true
end


---------------- Main Process ----------------
-- 各植林ポイントを巡回し、木が成長していれば伐採・植林
print("--- formated Tree Capitor Program ---")
for i=1, nPlantingPoints do
    local x = plantingPoints[i][1]
    local y = plantingPoints[i][2]
    local z = plantingPoints[i][3]

    print("move to point")
    local b = MoveToFacePoint(x, y, z)
    if not b then
        io.stderr:write("failed move to point")
        break
    end

    -- 木が成長していれば伐採・植林
    print("tree chop")
    if TreeChopAndPlant() then
        -- 周囲に落ちた苗木を回収
        print("suck around")
        while component.tractor_beam.suck() do
        end

        if not IsHaveSpace() then
            StoreToChest()
        end
    end
end

-- 初期配置へ戻る
StoreToChest()
ReturnToHome()