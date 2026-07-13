--------------------------------------------------------------------------------
-- [Spread] -- Wrapper for stdlib's spread-across-ticks scheduler
--------------------------------------------------------------------------------

--- Each spread group shares stdlib's global on_tick budget while retaining its
--- own callback, interval, and optional per-tick limit
---
--- Basic setup:
--- local Spread = require("__kry_stdlib__/stdlib/scripts/spread-on-tick")
--- local spread = Spread("my-spread-group")
---
--- spread:register{
---     interface = script.mod_name,
---     callback = "my_spread_check",
---     interval_ticks = 30,
---     max_checks_per_tick = 5
--- }
---
--- spread:add(entity, payload, 1)
---
--- The callback receives an array of 'SpreadEntry' values, the current tick,
--- and the group name. Return '{[unit_number] = true}' to remove selected
--- entities from tracking. The callback must be exposed through the remote
--- interface named by 'definition.interface'

--- all the info a modder might ever need to know

---@alias SpreadRemovalReason "callback"|"invalid"|"invalid-delayed"

---@class SpreadDefinition
---@field interface string Remote interface containing this group's callbacks
---@field callback string Batch callback called as callback(entries, tick, group_name)
---@field remove_callback? string Optional callback called as callback(unit_number, group_name, reason) after automatic removal
---@field interval_ticks? uint Minimum ticks between the start of full group cycles, defaults to 1
---@field max_checks_per_tick? uint Optional limit for this group within stdlib's shared per-tick budget
---@field enabled? boolean Whether the group begins enabled, defaults to true

---@class SpreadEntry
---@field entity LuaEntity
---@field payload? any Source-mod data stored alongside the entity

---@class SpreadGroupState
---@field interface string
---@field callback string
---@field remove_callback? string
---@field enabled boolean
---@field interval_ticks uint
---@field max_checks_per_tick? uint
---@field count uint
---@field delayed_count uint
---@field previous_key? uint
---@field pending_key? uint

---@class SpreadGroupSummary
---@field exists boolean
---@field interface? string
---@field callback? string
---@field remove_callback? string
---@field enabled? boolean
---@field interval_ticks? uint
---@field max_checks_per_tick? uint
---@field count? uint
---@field delayed_count? uint
---@field previous_key? uint
---@field pending_key? uint

---@class SpreadSchedulerSummary
---@field groups table<string, SpreadGroupState>
---@field group_order string[]
---@field group_cursor uint
---@field entity_count uint
---@field delayed_count uint

---@class Spread
---@field name string
---@overload fun(group_name: string): Spread

local Spread = {}
Spread.__index = Spread

local INTERFACE_NAME = "kry-stdlib-spread-on-tick"

--------------------------------------------------------------------------------
-- Remote call helper
--------------------------------------------------------------------------------

local function call(function_name, ...)
	if not remote.interfaces[INTERFACE_NAME] then
		error(
			"\nMissing required remote interface: " .. INTERFACE_NAME ..
			"\nPlease ensure kry-stdlib is loaded before using Spread."
		)
	end

	return remote.call(INTERFACE_NAME, function_name, ...)
end

--------------------------------------------------------------------------------
-- Group object
--------------------------------------------------------------------------------

--- Creates a wrapper bound to one spread group
---@param group_name string Unique scheduler group name
---@return Spread
function Spread.new(group_name)
	assert(type(group_name) == "string", "Spread group name must be a string")

	return setmetatable({
		name = group_name
	}, Spread)
end

--- Registers this group or updates its callback and scheduling options
--- Existing tracked entities remain registered
---@param definition SpreadDefinition
function Spread:register(definition)
	assert(type(definition) == "table", "Spread.register expects a table")

	definition.name = self.name
	return call("register_group", definition)
end

--- Unregisters this group and discards every tracked entity
function Spread:unregister()
	return call("unregister_group", self.name)
end

--- Adds or updates an entity in this group
---@param entity LuaEntity
---@param payload? any Source-mod data passed back with the entity
---@param delay_ticks? uint Number of ticks before the entity becomes active, defaults to 0
function Spread:add(entity, payload, delay_ticks)
	return call("add_entity", self.name, entity, payload, delay_ticks)
end

--- Removes an active or delayed entity from this group
---@param entity_or_unit_number LuaEntity|uint
function Spread:remove(entity_or_unit_number)
	return call("remove_entity", self.name, entity_or_unit_number)
end

--- Removes every tracked entity while keeping the group registered
function Spread:clear()
	return call("clear_group", self.name)
end

--- Restarts this group's iteration cycle without removing tracked entities
function Spread:reset()
	return call("reset_group", self.name)
end

--- Enables or disables processing for this group without removing its entities
---@param enabled boolean
function Spread:set_enabled(enabled)
	return call("set_group_enabled", self.name, enabled)
end

--- Returns summary information for this group
--- Calling `Spread.get_summary()` without an instance returns the full scheduler
--- summary for compatibility with the original static helper
---@param self? Spread
---@return SpreadGroupSummary|SpreadSchedulerSummary
function Spread:get_summary()
	if not self or self == Spread then return call("get_summary") end
	return call("get_group_summary", self.name)
end

--------------------------------------------------------------------------------
-- Static helpers
--------------------------------------------------------------------------------

--- Returns summary information for the entire scheduler
---@return SpreadSchedulerSummary
function Spread.get_scheduler_summary()
	return call("get_summary")
end

--------------------------------------------------------------------------------
-- Constructor shorthand
--------------------------------------------------------------------------------

return setmetatable(Spread, {
	__call = function(_, group_name)
		return Spread.new(group_name)
	end
})