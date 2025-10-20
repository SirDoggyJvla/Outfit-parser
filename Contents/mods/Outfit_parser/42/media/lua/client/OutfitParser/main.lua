---CACHE
local module = require "OutfitParser/module"
local CharacterOutfitUI = require "OutfitParser/ISUI/CharacterOutfitUI"


module.OnKeyPressed = function(key)
    if key == Keyboard.KEY_X then
        module.main()
    end
end


module.main = function()
    local instance = module.UIinstance
    if instance then
        instance:close()
        module.UIinstance = nil
    else
        instance = module.createUIinstance()
        module.UIinstance = instance
    end
end


module.createUIinstance = function()
    local instance = CharacterOutfitUI:new()
    instance:initialise()
    instance:setVisible(true)
    instance:addToUIManager()

    return instance
end
