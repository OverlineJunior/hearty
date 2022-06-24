--[[
    TODO: Finish the documentation.
    DONE: Create a Types module for shared types.
    DONE: Add damage and heal signals so we can also get the data.
    TODO: Try adding Hearty.GetHumanoidDamaged(hum), which returns a signal that is fired when hum is damaged (replicate stuff for heal too).
]]

local Filter = require(script.Filter)
local Types = require(script.Types)
local Signal = require(script.Signal)

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
    @prop HumanoidDamaged Signal<Humanoid, number, Data>
    @within Hearty
    @tag Event
]=]
Hearty.HumanoidDamaged = Signal.new()
--[=[
    @prop HumanoidHealed Signal<Humanoid, number, Data>
    @within Hearty
    @tag Event
]=]
Hearty.HumanoidHealed = Signal.new()


--[=[
    @param target Humanoid
    @param amount number
    @param data Data?

    Damages the *target*, but only if there are no filters for it that deny the damage, that is, that return *false*.
]=]
function Hearty.Damage(target: Humanoid, amount: number, data: Data?)
    data = data or {}

    for _, filter in damageFilters[target] or {} do
        if not filter._PredicateFn(amount, data) then
            return
        end
    end

    target:TakeDamage(amount)
    Hearty.HumanoidDamaged:Fire(target, amount, data)
end


--[=[
    @param target Humanoid
    @param amount number
    @param data Data?

    Heals the *target*, but only if there are no filters for it that deny the heal, that is, that return *false*.
]=]
function Hearty.Heal(target: Humanoid, amount: number, data: Data?)
    data = data or {}

    for _, filter in healFilters[target] or {} do
        if not filter._PredicateFn(amount, data) then
            return
        end
    end

    target.Health += amount
    Hearty.HumanoidHealed:Fire(target, amount, data)
end


--[=[
    @param target Humanoid
    @param predicateFn (number, Data) -> boolean
    @return Filter

    Adds a function that will be tested everytime [Hearty.Damage] is called for the same *target* - if it returns *true*, the damage request
    will be allowed, and if it returns *false*, it will be denied.

    ```lua
    -- Only allows damage when it is not letal.
    Hearty.AddDamageFilter(targetHumanoid, function(damage: number)
        return targetHumanoid.Health - damage > 0
    end)

    -- Allowed, 100 - 50 = 50.
    Hearty.Damage(targetHumanoid, 50)
    -- Denied because damage is letal, 50 - 50 = 0.
    Hearty.Damage(targetHumanoid, 50)
    ```
]=]
function Hearty.AddDamageFilter(target: Humanoid, predicateFn: Types.PredicateFn): any
    return Filter.new(target, predicateFn, damageFilters)
end


--[=[
    @param target Humanoid
    @param predicateFn (number, Data) -> boolean
    @return Filter

    Adds a function that will be tested everytime [Hearty.Heal] is called for the same *target* - if it returns *true*, the heal request
    will be allowed, and if it returns *false*, it will be denied.

    ```lua
    -- You can use filters to make sure data is sent the way you expect.
    Hearty.AddHealFilter(targetHumanoid, function(heal: number, data: Hearty.Data)
        assert(data.Source, 'Heal source not specified')
        return true
    end)

    -- All good, data.Source is defined.
    Hearty.Heal(targetHumanoid, 10, {
        Source = myHumanoid,
    })

    -- Errors because data.Source is not defined.
    Hearty.Heal(targetHumanoid, 10)
    ```
]=]
function Hearty.AddHealFilter(target: Humanoid, predicateFn: Types.PredicateFn): any
    return Filter.new(target, predicateFn, healFilters)
end


return Hearty
