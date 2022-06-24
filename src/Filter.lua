local Types = require(script.Parent.Types)

--[=[
    @class Filter
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
