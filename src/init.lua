--[[
    TODO: Finish the documentation.
    DONE: Create a Types module for shared types.
    TODO: Add damage and heal signals so we can also get the data.
    TODO: Try adding Hearty.GetHumanoidDamaged(hum), which returns a signal that is fired when hum is damaged (replicate stuff for heal too).
]]

local Filter = require(script.Filter)
local Types = require(script.Types)

type FilterDict = Types.Dict<Humanoid, {any}?>
--[=[
    @type Data {[any]: any}
    @within Hearty
]=]
export type Data = Types.Data

local damageFilters: FilterDict = {}
local healFilters: FilterDict = {}

--[=[
    @class Hearty
]=]
local Hearty = {}


--[=[
    @param target Humanoid
    @param amount number
    @param data Data?
]=]
function Hearty.Damage(target: Humanoid, amount: number, data: Data?)
    data = data or {}

    for _, filter in damageFilters[target] or {} do
        if not filter._PredicateFn(amount, data) then
            return
        end
    end

    target:TakeDamage(amount)
end


--[=[
    @param target Humanoid
    @param amount number
    @param data Data?
]=]
function Hearty.Heal(target: Humanoid, amount: number, data: Data?)
    data = data or {}

    for _, filter in healFilters[target] or {} do
        if not filter._PredicateFn(amount, data) then
            return
        end
    end

    target.Health += amount
end


--[=[
    @param to Humanoid
    @param predicateFn PredicateFn
    @return Filter
]=]
function Hearty.AddDamageFilter(to: Humanoid, predicateFn: Types.PredicateFn): any
    return Filter.new(to, predicateFn, damageFilters)
end


--[=[
    @param to Humanoid
    @param predicateFn PredicateFn
    @return Filter
]=]
function Hearty.AddHealFilter(to: Humanoid, predicateFn: Types.PredicateFn): any
    return Filter.new(to, predicateFn, healFilters)
end


return Hearty
