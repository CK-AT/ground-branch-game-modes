local ActorState = require('common.ActorState')

local DynamicMeshGroup = {
}

DynamicMeshGroup.__index = DynamicMeshGroup

function DynamicMeshGroup:Create(Parent, Actor)
    local self = setmetatable({}, DynamicMeshGroup)
    self.Parent = Parent
    self.Meshes = {}
    self.Name = nil
    self.Min = nil
    self.Max = nil
    table.insert(self.Meshes, ActorState:Create(Actor))
    print('  ' .. 'DynamicMesh ' .. actor.GetName(Actor) .. ' found.')
    print('    Parameters:')
    for _, Tag in ipairs(actor.GetTags(Actor)) do
        local key
        local value
        _, _, key, value = string.find(Tag, "(%a+)%s*=%s*(.+)")
        if key ~= nil then
            print('      ' .. Tag)
            if key == 'Group' then
                self.Name = value
            else
                self[key] = tonumber(value)
            end
        end
    end
    return self
end

function DynamicMeshGroup:merge(other)
    for _, mesh in ipairs(other.Meshes) do
        table.insert(self.Meshes, mesh)
    end
    if other.Min ~= nil then
        self.Min = other.Min
    end
    if other.Max ~= nil then
        self.Max = other.Max
    end
end

function DynamicMeshGroup:SyncState()
    for _, mesh in ipairs(self.Meshes) do
        mesh:SyncState()
    end
end

function DynamicMeshGroup:GetName()
    return self.Name
end

function DynamicMeshGroup:Randomize()
    for _, mesh in ipairs(self.Meshes) do
        mesh:SetVisible(false)
        mesh:SetActive(false)
    end
    local min = self.Min or 1
    local max = self.Max or #self.Meshes
    min = math.min(min, #self.Meshes)
    max = math.min(max, #self.Meshes)
    local num_meshes = math.random(min, max)
    print('  ' .. 'Randomizing dynamic mesh group ' .. self.Name .. ' by selecting ' .. num_meshes .. ' meshes (Min=' .. min .. '; Max=' .. max .. ')...')
    local selected = {}
    while num_meshes > 0 do
        local idx_mesh = math.random(1, #self.Meshes)
        if selected[idx_mesh] == nil then
            selected[idx_mesh] = true
            self.Meshes[idx_mesh]:SetVisible(true)
            self.Meshes[idx_mesh]:SetActive(true)
            print('      ' .. 'Mesh ' .. self.Meshes[idx_mesh]:GetName() .. ' selected')
            num_meshes = num_meshes - 1
        end
    end
    for _, mesh in ipairs(self.Meshes) do
        mesh:Sync()
    end
end

return DynamicMeshGroup
