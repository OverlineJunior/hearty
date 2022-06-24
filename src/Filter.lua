local Types = require(script.Parent.Types)

--[=[
    @class Filter

    Class used by Hearty to allow or deny damage/heal requests, constructed by calling either [Hearty.AddDamageFilter] or [Hearty.AddHealFilter].
]=]
local Filter = {}
Filter.__index = Filter


function Filter.new(hum: Humanoid, predicateFn: Types.PredicateFn, storage: Types.Dict<any, any>): any
    local self = setmetatable({}, Filter)

    if not storage[hum] then
        storage[hum] = {}
    end

    table.insert(storage[hum], self)

    self._Humanoid = hum
    self._PredicateFn = predicateFn
    self._Storage = storage
    self._Index = #storage[hum]

    self._DestroyingCon = hum.Destroying:Connect(function()
        self:Destroy()
    end)

    return self
end


--[=[
    Deattaches the object from the humanoid it was attached to. Called automatically when the humanoid it is attached to is destroyed.
]=]
function Filter:Destroy()
    table.remove(self._Storage[self._Humanoid], self._Index)

    if #self._Storage[self._Humanoid] == 0 then
        self._Storage[self._Humanoid] = nil
    end

    self._DestroyingCon:Disconnect()
    setmetatable(self, {})
    table.clear(self)
end


return Filter
