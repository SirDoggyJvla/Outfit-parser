-- needed libs
require "Vehicles/ISUI/ISUI3DScene"

---@class Wiki3DScene : ISUI3DScene
local Wiki3DScene = ISUI3DScene:derive("Wiki3DScene")


function Wiki3DScene:new(x, y, width, height)
	local o = ISUI3DScene.new(self, x, y, width, height) --[[@as Wiki3DScene]]
	o.background = true
	o.backgroundColor = {r=0, g=1, b=0, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	return o
end


return Wiki3DScene