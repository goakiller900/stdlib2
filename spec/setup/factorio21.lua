-- Adapt the historical stdlib test harness to Factorio 2.1 runtime globals.
local direction = defines.direction
direction.north = 0
direction.northeast = 2
direction.east = 4
direction.southeast = 6
direction.south = 8
direction.southwest = 10
direction.west = 12
direction.northwest = 14

_G.helpers = _G.helpers or {}
_G.helpers.write_file = _G.helpers.write_file or function(...)
    return _G.game.write_file(...)
end

return true
