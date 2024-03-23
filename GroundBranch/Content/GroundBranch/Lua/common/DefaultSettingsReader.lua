local DefaultSettingsReader = {
}

DefaultSettingsReader.__index = DefaultSettingsReader

---Creates a new base agent object.
function DefaultSettingsReader:Create()
    local self = setmetatable({}, DefaultSettingsReader)
    self.Limits = {}
    print('Reading default settings actor...')
    local Actors = gameplaystatics.GetAllActorsWithTag('DefaultSettings')
    if #Actors > 1 then
        print('  Found more than one actor with tag "DefaultSettings", this is not allowed!')
        return
    elseif #Actors < 1 then
        print('  Found no actor with tag "DefaultSettings"')
        return
    end
    for _, Actor in ipairs(Actors) do
        print('  Settings:')
        for _, Tag in ipairs(actor.GetTags(Actor)) do
            local key
            local value
            _, _, key, value = string.find(Tag, "(%a+)%s*=%s*(.+)")
            if key ~= nil then
                print('    ' .. Tag)
                local Setting = gamemode.script.Settings[key]
                if Setting == nil then
                    print('      Setting ' .. key .. ' is unknown!')
                else
                    local Min = Setting.Min
                    local Max = Setting.Max
                    self.Limits[key] = {Min=Min, Max=Max}
                    Setting.Min = tonumber(value)
                    Setting.Max = tonumber(value)
                    Setting.Value = tonumber(value)
                end
            end
        end
    end

    return self
end

function DefaultSettingsReader:RestoreLimits()
    for key, limits in pairs(self.Limits) do
        local Setting = gamemode.script.Settings[key]
        Setting.Min = limits.Min
        Setting.Max = limits.Max
    end
end

return DefaultSettingsReader
