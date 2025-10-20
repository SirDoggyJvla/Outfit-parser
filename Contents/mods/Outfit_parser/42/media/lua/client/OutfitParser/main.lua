local module = require "OutfitParser/module"

module.OnKeyPressed = function(key)
    if key == Keyboard.KEY_X then
        module.main()
    end
end


module.main = function()
    local instance = module.UIinstance
    if instance then
        instance:removeFromUIManager()
        module.UIinstance = nil
    else
        instance = module.createUIinstance()
        module.UIinstance = instance
    end
end


module.createUIinstance = function()
    local instance = ISUI3DModel:new(0,0,400,400)
    instance:setVisible(true)
    instance:addToUIManager()

    instance:setOutfitName("Foreman", false, false)
	instance:setState("idle")
	instance:setDirection(IsoDirections.S)
	instance:setIsometric(false)

    instance:setCharacter(getPlayer())

    return instance
end


module.takeScreenshot = function(filename)
    getCore():TakeFullScreenshot(filename)
end