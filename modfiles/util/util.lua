local _util = {
    globals = require("util.globals"),
    context = require("util.context"),
    clipboard = require("util.clipboard"),
    messages = require("util.messages"),
    cursor = require("util.cursor"),
    gui = require("util.gui"),
    format = require("util.format"),
    nth_tick = require("util.nth_tick"),
    porter = require("util.porter"),
    actions = require("util.actions"),
    effects = require("util.effects"),
    temperature = require("util.temperature")
}


-- Still can't believe this is not a thing in Lua
-- This has the added feature of turning any number strings into actual numbers
---@param str string
---@param separator string
---@return string[]
function _util.split_string(str, separator)
    local result = {}
    for token in string.gmatch(str, "[^" .. separator .. "]+") do
        table.insert(result, (tonumber(token) or token))
    end
    return result
end


-- Fills up the localised table in a smart way to avoid the limit of 20 strings per level
-- To make it stateless, it needs its return values passed back as arguments
-- Uses state to avoid needing to call table_size() because that function is slow
---@param string_to_insert LocalisedString
---@param current_table LocalisedString
---@param next_index integer
---@return LocalisedString, integer
function _util.build_localised_string(string_to_insert, current_table, next_index)
    current_table = current_table or {""}
    next_index = next_index or 2

    if next_index == 20 then  -- go a level deeper if this one is almost full
        local new_table = {""}
        current_table[next_index] = new_table
        current_table = new_table
        next_index = 2
    end
    current_table[next_index] = string_to_insert
    next_index = next_index + 1

    return current_table, next_index
end


---@param a boolean
---@param b boolean
---@return boolean
function _util.xor(a, b)
    return not a ~= not b
end


---@param force LuaForce
---@param recipe_name string
---@return EffectValue productivity_bonus
function _util.get_recipe_productivity(force, recipe_name)
    local bonus = nil
    if recipe_name == "custom-mining" then
        bonus = force.mining_drill_productivity_bonus
    else
        bonus = force.recipes[recipe_name].productivity_bonus
    end
    return math.floor(bonus * MAGIC_NUMBERS.effect_precision + 1e-4)
end

-- This function is only called when Factory Search is active, so no need to check for the mod
---@param player LuaPlayer
---@param prototype LuaEntityPrototype|LuaEquipmentPrototype|LuaFluidPrototype|LuaItemPrototype|LuaRecipePrototype|LuaTilePrototype
function _util.open_recipebook_gui(player, prototype)
    remote.call("RecipeBook", "open_page", player.index, prototype)
end

-- This function returns its placeable item based on an entity
---@param entity LuaEntityPrototype
---@return string
function _util.get_placeable_item_from_entity(entity)
    local items_to_place_this = entity.items_to_place_this
    if items_to_place_this and items_to_place_this[1] then
        return items_to_place_this[1].name
    else
        return entity.name
    end
end

-- This function is only called when Factory Search is active, so no need to check for the mod
---@param player LuaPlayer
---@param type string
---@param name string
function _util.open_in_factorysearch(player, type, name)
    remote.call("factory-search", "search", player, {type=type, name=name})
end

return _util
