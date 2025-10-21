---@alias WikiToolsUI CharacterOutfitUI|ItemUI

---CACHE
local module = require "WikiTools/module"
local CharacterOutfitUI = require "WikiTools/ISUI/CharacterOutfitUI/CharacterOutfitUI"
local ItemUI = require "WikiTools/ISUI/ItemUI/ItemUI"


module.OnKeyPressed = function(key)
    -- CharacterOutfitUI
    if key == Keyboard.KEY_X then
        module.openOrCloseUI(CharacterOutfitUI)
    elseif key == Keyboard.KEY_U then
        module.openOrCloseUI(ItemUI)
    end
end


---Used to create a UI instance of the given class.
---@param class WikiToolsUI
module.openOrCloseUI = function(class)
    local instance = module.UIinstance
    if instance then
        instance:close()
        module.UIinstance = nil
    else
        module.UIinstance = module.createUIinstance(class)
    end
end

---Create a UI instance of the given class. Needs to have normalized constructors.
---@param class WikiToolsUI
module.createUIinstance = function(class)
    local instance = class:new()
    instance:initialise()
    instance:setVisible(true)
    instance:addToUIManager()

    return instance
end
