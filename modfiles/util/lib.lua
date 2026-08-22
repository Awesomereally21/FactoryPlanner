---@class FPLib
local _lib = {
    flib = require("util.flib"),
    translator = require("util.dictionary"),
    globals = require("util.globals"),
    context = require("util.context"),
    clipboard = require("util.clipboard"),
    cursor = require("util.cursor"),
    gui = require("util.gui"),
    format = require("util.format"),
    nth_tick = require("util.nth_tick"),
    porter = require("util.porter"),
    actions = require("util.actions"),
    availability = require("util.availability"),
    effects = require("util.effects"),
    temperature = require("util.temperature"),
    preferences = require("util.preferences")
}


-- Still can't believe this is not a thing in Lua
-- This has the added feature of turning any number strings into actual numbers
---@param str string
---@param separator string
---@return string[]
function _lib.split_string(str, separator)
    local result = {}
    for token in string.gmatch(str, "[^" .. separator .. "]+") do
        table.insert(result, (tonumber(token) or token))
    end
    return result
end


---@alias FactoriopediaIDType "item" | "fluid" | "recipe" | "entity" | "tile" | "space-location" | "ammo-category" | "space-connection" | "asteroid-chunk" | "virtual-signal" | "surface"
---@alias FPFactoriopediaID {type: FactoriopediaIDType, name: string}

-- Custom items and recipes need an explicit mapping; normal entries use their own prototype.
---@param proto FPPrototype | FPPackedPrototype
---@return FactoriopediaID?
function _lib.get_factoriopedia_proto(proto)
    if proto.simplified then return nil end
    ---@cast proto FPPrototype
    local fp_id = proto.factoriopedia_id
    if fp_id then return prototypes[fp_id.type][fp_id.name] end

    if proto.data_type == "items" then
        ---@cast proto FPItemPrototype
        if proto.type == "entity" then return nil end
        return prototypes[proto.type][proto.base_name or proto.name]
    elseif proto.data_type == "recipes" then
        ---@cast proto FPRecipePrototype
        if proto.custom then return nil end
        return prototypes.recipe[proto.name]
    elseif proto.data_type == "fuels" then
        ---@cast proto FPFuelPrototype
        return prototypes[proto.type][proto.name]
    elseif proto.data_type == "modules" then
        return prototypes.item[proto.name]
    elseif proto.data_type == "machines" or proto.data_type == "beacons" then
        return prototypes.entity[proto.name]
    end
    return nil
end


---@param name string
---@return boolean
function _lib.is_special_power_item(name)
    return (name == "custom-electric-power" or name == "custom-heat-power" or name == "custom-heating-power")
end


-- This function returns its placeable item based on an entity
---@param entity LuaEntityPrototype
---@return string
function _lib.get_placeable_item_from_entity(entity)
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
function _lib.open_in_factorysearch(player, type, name)
    remote.call("factory-search", "search", player, {type=type, name=name})
end

return _lib
