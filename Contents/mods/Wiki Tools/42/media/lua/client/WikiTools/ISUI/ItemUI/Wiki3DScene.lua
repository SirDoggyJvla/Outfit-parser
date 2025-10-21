-- needed libs
require "Vehicles/ISUI/ISUI3DScene"

---@class Wiki3DScene : ISUI3DScene
---@field javaObject UI3DScene
---@field parent ItemUI
---@field currentModel string
local Wiki3DScene = ISUI3DScene:derive("Wiki3DScene")

--- fromLua HELPERS (the number is the number of arguments)

function Wiki3DScene:fromLua0(methodName)
    self.javaObject:fromLua0(methodName)
end

function Wiki3DScene:fromLua1(methodName, arg1)
    self.javaObject:fromLua1(methodName, arg1)
end

function Wiki3DScene:fromLua2(methodName, arg1, arg2)
    self.javaObject:fromLua2(methodName, arg1, arg2)
end

function Wiki3DScene:fromLua3(methodName, arg1, arg2, arg3)
    self.javaObject:fromLua3(methodName, arg1, arg2, arg3)
end

function Wiki3DScene:fromLua4(methodName, arg1, arg2, arg3, arg4)
    self.javaObject:fromLua4(methodName, arg1, arg2, arg3, arg4)
end

--- SCENE MODIFICATIONS

---Create a model in the 3D scene.
---```lua
---JAVA.createModel(id, modelScriptName)
---```
---@param id string
---@param scriptName string
function Wiki3DScene:setModel(id, scriptName)
    if not self.currentModel or self.currentModel ~= scriptName then
        self:removeModel(id) -- remove first the model if already exists

        -- add new model
        self.currentModel = scriptName
        self:fromLua2("createModel", id, scriptName)

        if self.parent.comboAddModelLabel then
            self.parent.comboAddModelLabel:setName(scriptName)
        end
    end
end

---Remove the model from the 3D scene.
---@param id string
function Wiki3DScene:removeModel(id)
    if self.currentModel then
        self.currentModel = nil
        self:fromLua1("removeModel", id)
    end
end


--- ACTION REACTIONS

---Add the model on combo box selection in parent UI.
function Wiki3DScene:onComboAddModel()
    local combo = self.parent.comboAddModel
	local scriptName = combo:getOptionText(combo.selected)
	combo.selected = 0 -- the default option is "ADD MODEL"
    if not scriptName then return end

	self:setModel("worldModel", scriptName)
end

function Wiki3DScene:onTickFromLua(bool, method)
    self:fromLua1(method, bool)
end

--- INSTANCE SETUP

function Wiki3DScene:setBackgroundColor(color)
    self.backgroundColor = color
end

---Setup the default 3D view.
function Wiki3DScene:setupScene()
    self:setView("UserDefined")
    self:fromLua1("setMaxZoom", 20)
	self:fromLua1("setZoom", 10)
	-- self:fromLua1("setGizmoScale", 1.0 / 5.0)

    self:fromLua3("setViewRotation", 30.0, 45.0 + 90.0, 0.0)

    self:setModel("worldModel", "Base.FireAxe")
	self:fromLua2("setModelUseWorldAttachment", "worldModel", true)
    self:fromLua2("setModelWeaponRotationHack", "worldModel", true)

    self:fromLua1("setDrawGrid", false)
	self:fromLua1("setGridPlane", "XZ")

    self:fromLua0("clearAABBs")
    self:fromLua0("clearAxes")
end


function Wiki3DScene:new(x, y, width, height)
	local o = ISUI3DScene.new(self, x, y, width, height) --[[@as Wiki3DScene]]
	o.background = true
	o.backgroundColor = {r=0, g=1, b=0, a=1}
    -- o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	return o
end


return Wiki3DScene