local Filter = require(script.Filter)

type Dict<K, V> = {[K]: V}
type FilterDict = Dict<Humanoid, {any}?>
export type Data = Dict<any, any>
export type PredicateFn = (number, Data) -> boolean

local damageFilters: FilterDict = {}
local healFilters: FilterDict = {}

local Hearty = {}


function Hearty.Damage(hum: Humanoid, amount: number, data: Data?)
    data = data or {}

    for _, filter in damageFilters[hum] or {} do
        if not filter._PredicateFn(amount, data) then
            return
        end
    end

    hum:TakeDamage(amount)
end


function Hearty.Heal(hum: Humanoid, amount: number, data: Data?)
    data = data or {}

    for _, filter in healFilters[hum] or {} do
        if not filter._PredicateFn(amount, data) then
            return
        end
    end

    hum.Health += amount
end


function Hearty.AddDamageFilter(hum: Humanoid, predicateFn: PredicateFn)
    return Filter.new(hum, predicateFn, damageFilters)
end


function Hearty.AddHealFilter(hum: Humanoid, predicateFn: PredicateFn)
    return Filter.new(hum, predicateFn, healFilters)
end


return Hearty
