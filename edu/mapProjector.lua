local component = require("componet")
local holo = component.hologram
local geo = component.geolyzer

local b = false
local w = 8
local d = 8
local h = 1

holo.clear()

-- Holo Projecterのサイズは48x32x48
for x = 0, 40, 8 do
    for z = 0, 40, 8 do
        for y = 1, 32, 1 do
            local t = geo.scan(x, z, y - 2, w, d, h)

            for dx = 1, 8, 1 do
                for dz = 1, 8, 1 do
                    holo.set(x+dx, y, z+dz, t[(dx-1)*8 + dz] + 1)
                end
            end
        end
    end
end