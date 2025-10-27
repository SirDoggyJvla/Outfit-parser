require "ISUI/ISComboBox"

---@class ISComboBoxModels : ISComboBox
---@field listingType string
local ISComboBoxModels = ISComboBox:derive("ISComboBoxModels")



---Get the list of models available in the script manager.
---@return table
function ISComboBoxModels:getModelList()
    -- parse model scripts
    local scripts = getScriptManager():getAllModelScripts()
    local sorted = {}
	for i=0,scripts:size()-1 do repeat
        local script = scripts:get(i)
        local fullType = script:getFullType()

        -- ignore body models
        if fullType == "Base.FemaleBody" or fullType == "Base.MaleBody" then
            break
        end
        table.insert(sorted, fullType)
    until true end
    table.sort(sorted)
    return sorted
end

function ISComboBoxModels:getItemList()
    local items = getScriptManager():getAllItems()
    local sorted = {}
    for i=0,items:size()-1 do
        local item = items:get(i)
        local fullType = item:getModuleName() .. "." .. item:getName()
        table.insert(sorted, fullType)
    end
    table.sort(sorted)
    return sorted
end

function ISComboBoxModels:getItemModel(item)
    local model = item:getWorldStaticModel()
    if model then return model end

    model = item:getStaticModel()
    if model then return model end

    return nil
end

function ISComboBoxModels:getModel(fullType)
    local item = self.listedItems[fullType]
    local type = item.type

    -- try to fetch the proper model based on the listing type
    local model
    if type == "modelScript" then
        model = fullType
    elseif type == "itemScript" then
        model = self:getItemModel(item.object)
    end

    return model
end


function ISComboBoxModels:updateListing(listingType)
    self:clear()

    self.listingType = listingType
    self:populateList()

end

function ISComboBoxModels:populateList()
    local listingType = self.listingType
    if listingType == "All models" then
        local sorted = self:getModelList()

        -- add to combo
        local listedItems = {}
        for i = 1,#sorted do
            local scriptName = sorted[i]
            self:addOption(scriptName)
            listedItems[scriptName] = {type="modelScript"}
        end
        self.listedItems = listedItems
        self.noSelectionText = "Select model"
    elseif listingType == "All items" then
        -- parse items
        local items = self:getItemList()

        local listedItems = {}
        for i = 1,#items do
            local fullType = items[i]
            local item = getScriptManager():getItem(fullType)
            self:addOption(fullType)
            listedItems[fullType] = {type="itemScript", object=item}
        end
        self.listedItems = listedItems
        self.noSelectionText = "Select item"
    end

    self.selected = 0 -- default option
end

---Needed for typings to not go insane.
function ISComboBoxModels:new(...)
    local o = ISComboBox.new(self, ...) --[[@as ISComboBoxModels]]
    return o
end

return ISComboBoxModels