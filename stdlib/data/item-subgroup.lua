local Data = require('__kry_stdlib__/stdlib/data/data') --[[@as StdLib.Data]]
local Table = require('__kry_stdlib__/stdlib/utils/table')

--- ItemSubgroup
--- @class StdLib.Data.ItemSubgroup : StdLib.Data
local ItemSubgroup = {
    __class = 'ItemSubgroup',
    __index = Data,
}

function ItemSubgroup:__call(item_subgroup)
    return self:get(item_subgroup, 'item-subgroup')
end
setmetatable(ItemSubgroup, ItemSubgroup)

-- ----------------------------
-- Internal helpers
-- ----------------------------

-- list of all valid item prototypes (most of these will be discarded, but need to include them)
local item_types = {
    'ammo',
    'armor',
    'blueprint',
    'blueprint-book',
    'capsule',
    'copy-paste-tool',
    'deconstruction-item',
    'gun',
    'item',
    'item-with-entity-data',
    'item-with-inventory',
    'item-with-label',
    'item-with-tags',
    'module',
    'rail-planner',
    'repair-tool',
    'selection-tool',
    'space-platform-starter-pack',
    'spidertron-remote',
    'tool',
    'upgrade-item',
}

-- list of all valid entity prototypes (same note as above)
local entity_types = {
    'accumulator',
    'agricultural-tower',
    'ammo-turret',
    'arithmetic-combinator',
    'arrow',
    'artillery-flare',
    'artillery-projectile',
    'artillery-turret',
    'artillery-wagon',
    'assembling-machine',
    'asteroid',
    'asteroid-collector',
    'beacon',
    'beam',
    'boiler',
    'burner-generator',
    'capture-robot',
    'car',
    'cargo-bay',
    'cargo-landing-pad',
    'cargo-pod',
    'cargo-wagon',
    'character',
    'character-corpse',
    'cliff',
    'combat-robot',
    'constant-combinator',
    'construction-robot',
    'container',
    'corpse',
    'curved-rail-a',
    'curved-rail-b',
    'decider-combinator',
    'deconstructible-tile-proxy',
    'display-panel',
    'electric-energy-interface',
    'electric-pole',
    'electric-turret',
    'elevated-curved-rail-a',
    'elevated-curved-rail-b',
    'elevated-half-diagonal-rail',
    'elevated-straight-rail',
    'entity-ghost',
    'explosion',
    'fire',
    'fish',
    'fluid-stream',
    'fluid-turret',
    'fluid-wagon',
    'furnace',
    'fusion-generator',
    'fusion-reactor',
    'gate',
    'generator',
    'half-diagonal-rail',
    'heat-interface',
    'heat-pipe',
    'highlight-box',
    'infinity-cargo-wagon',
    'infinity-container',
    'infinity-pipe',
    'inserter',
    'item-entity',
    'item-request-proxy',
    'lab',
    'lamp',
    'land-mine',
    'lane-splitter',
    'legacy-curved-rail',
    'legacy-straight-rail',
    'lightning',
    'lightning-attractor',
    'linked-belt',
    'linked-container',
    'loader',
    'loader-1x1',
    'locomotive',
    'logistic-container',
    'logistic-robot',
    'market',
    'mining-drill',
    'offshore-pump',
    'particle-source',
    'pipe',
    'pipe-to-ground',
    'plant',
    'player-port',
    'power-switch',
    'programmable-speaker',
    'projectile',
    'proxy-container',
    'pump',
    'radar',
    'rail-chain-signal',
    'rail-ramp',
    'rail-remnants',
    'rail-signal',
    'rail-support',
    'reactor',
    'resource',
    'roboport',
    'rocket-silo',
    'rocket-silo-rocket',
    'rocket-silo-rocket-shadow',
    'segment',
    'segmented-unit',
    'selector-combinator',
    'simple-entity',
    'simple-entity-with-force',
    'simple-entity-with-owner',
    'smoke-with-trigger',
    'solar-panel',
    'space-platform-hub',
    'speech-bubble',
    'spider-leg',
    'spider-unit',
    'spider-vehicle',
    'splitter',
    'sticker',
    'storage-tank',
    'straight-rail',
    'stream',
    'temporary-container',
    'thruster',
    'tile-ghost',
    'train-stop',
    'transport-belt',
    'tree',
    'turret',
    'underground-belt',
    'unit',
    'unit-spawner',
    'valve',
    'wall',
}

-- then merge all entries into one table for subgroup counting
local prototype_types = {}
Table.merge(prototype_types, item_types, true)
Table.merge(prototype_types, entity_types, true)
table.insert(prototype_types, 'recipe')

--- Returns whether the prototype should not be included in the row count.
--- @param prototype table
--- @return boolean
local function is_hidden(prototype)
    return prototype.hidden or prototype.hidden_in_factoriopedia
end

--- Counts visible prototypes assigned to the given subgroup.
--- Entries with the same internal name are only counted once.
--- @param subgroup_name string
--- @return integer
local function count_visible_subgroup_entries(subgroup_name)
    local count = 0
    local counted_names = {}

    for _, type_name in pairs(prototype_types) do
        for name, prototype in pairs(data.raw[type_name] or {}) do
            if prototype.subgroup == subgroup_name and not is_hidden(prototype) and not counted_names[name] then
                counted_names[name] = true
                count = count + 1
            end
        end
    end

    return count
end

--- Count the number of visible entries in this subgroup.
--- Hidden prototypes and Factoriopedia-hidden prototypes are ignored.
--- Prototypes with duplicate internal names are only counted once.
--- @return integer? count
function ItemSubgroup:count_visible_entries()
    if self:is_valid('item-subgroup') then
        return count_visible_subgroup_entries(self.name)
    end
end
ItemSubgroup.get_visible_entry_count = ItemSubgroup.count_visible_entries

--- Count the number of visible rows used by this subgroup.
--- Returns zero if the subgroup contains no visible entries.
--- Returns one for 1-10 visible entries, two for 11-20 visible entries, etc.
--- @return integer? rows
function ItemSubgroup:count_rows()
    if self:is_valid('item-subgroup') then
        local count = self:count_visible_entries()

        if count <= 0 then
            return 0
        end

        return math.ceil(count / 10)
    end
end
ItemSubgroup.get_row_count = ItemSubgroup.count_rows
ItemSubgroup.count_subgroup_rows = ItemSubgroup.count_rows

return ItemSubgroup