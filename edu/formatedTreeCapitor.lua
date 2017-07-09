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
local f = sides.south        -- ロボットの向いている方角の初期値は南とする
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

-- 本プログラムを起動しているのがタートルでなければ異常終了
if not component.isAvailable("robot") then
    io.stderr:write("can only run on robots")
    return
end

if not component.isAvailable("tractor_beam") then
    io.stderr:write("can only run on robots with tractor_beam")
    return
end


---------------- Main Process ----------------
-- 各植林ポイントを巡回し、木が成長していれば伐採・植林
for i=1,nPlantingPoints do
    for x, y, z in pairs(plantingPoints[i]) do
        -- 植林ポイントに接する座標まで移動
        local b, faceSide = MoveToFacePoint(x, y, z)
        if not b then
            io.stderr:write("failed move to point")
            break
        end

        -- 木が成長していれば伐採・植林
        if TreeChopAndPlant(faceSide) then
            -- 周囲に落ちた苗木を回収
            while component.tractor_beam.suck() do
            end
            if not IsHaveSpace() then
                StoreToChest()
            end
        end
    end
end

-- 初期配置へ戻る
StoreToChest()
ReturnToHome()


---------------- Sub Procedure ----------------
function MoveToFacePoint(x, y, z)
    -- 変数の準備
    local moved = false

    -- かなり適当な移動アルゴリズム
    while true do
        moved = false
        if dx ~= x then
            if r.move(sides.posx) then
                dx = dx + 1
                moved = true
            end
        end
        if dy ~= y then
            if r.move(sides.posy) then
                dy = dy + 1
                moved = true
            end
        end
        if dz ~= z then
            if r.move(sides.posz) then
                dz = dz + 1
                moved = true
            end
        end

        -- 動けないor指定座標の上に立っていたら終了
        if not moved then
            break
        end
    end

    -- 指定座標の上に立っていたら後退
    if dx == x and dy == y and dz == z then
        r.move(sides.negz)
        z = z - 1
    end

    -- 指定座標に面しているかチェック
    local diff = math.abs(dx - x) + math.abs(dy - y) + math.abs(dz - z)
    if diff ~= 1 then
        return false
    end

    -- 指定座標に面している面を導出してリターン
    local diffs = {dy - y, dz - z, dx - x}
    for i, d in ipairs(diffs) do
        -- cf. http://ocdoc.cil.li/api:sides
        if d > 0 then
            return true, (i - 1) * 2
        end
        if d < 0 then
            return true, (i - 1) * 2 + 1
        end
    end
end

function TreeChopAndPlant(faceSide)
    -- 固体ブロック(原木)でなければfalseをリターン
    if not r.detect(faceSide) then
        return false, "not solid"
    end

    -- その個体ブロックを破壊
    if not r.swing(faceSide) then
        return false, "can not break"
    end

    -- 植林
    r.select(1)
    r.place(faceSide)

    -- 破壊したブロックの座標に移動
    if not r.move(faceSide) then
        return false, "failed move. item of slot 1 maybe solid"
    end

    -- 上方向に伐採(TODO:Exception Check)
    local y = 0
    while r.detec(sides.up) do
        r.swing(sides.up)
        r.move(sides.up)
        y = y + 1
    end

    -- 元の座標へ移動
    while y ~= 0 do
        r.move(sides.down)
        y = y - 1
    end

    if faceSide % 2 == 0 then
        r.move(faceSide + 1)
    else            
        r.move(faceSide - 1)
    end
end

function IsHaveSpace()
    for slotIdx=2, r.inventorySize() do
        if not r.space(slotIdx) then
            return true
        end
    end
    return false
end

function StoreToChest()
    -- 各チェストを巡回
    for i=1, nChestPoint do
        for x, y, z in pairs(chestPoints) do
            -- チェストまで移動
            local b, faceSide = MoveToFacePoint(x, y, z)
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
    end

    -- 全チェストが一杯で格納できなかった場合falseリターン
    return false
end

function ReturnToHome()
    -- 初期座標へ移動
    local b, faceSide = MoveToFacePoint(0, 0, 0)
    if not b then
        return false
    end
    r.move(faceSide)
    return true
end
