-- needed libs
require "ISUI/ISPanel"
require "ISUI/ISUI3DModel"

---CharacterOutfit3D is used to render a 3D model of a character outfit with a green screen background.
---@class CharacterOutfit3D : ISPanel
---@field modelView ISUI3DModel
local CharacterOutfit3D = ISPanel:derive("CharacterOutfit3D")

function CharacterOutfit3D:initialise()
    ISPanel.initialise(self)
    self:create()
end

---Set the outfit of the model 3D.
---@param outfitName string
---@param female boolean
function CharacterOutfit3D:setOutfitName(outfitName, female)
    self.modelView:setOutfitName(outfitName, female, false)
end

function CharacterOutfit3D:setBackgroundColor(color)
    self.backgroundColor = color
end

function CharacterOutfit3D:create()
    --- create model view
    local modelView = ISUI3DModel:new(0,0,400,400)
    modelView:setVisible(true)
    self:addChild(modelView)

    modelView:setOutfitName("Foreman", false, false)
	modelView:setState("idle")
	modelView:setDirection(IsoDirections.S)
	modelView:setIsometric(false)

    modelView:setCharacter(getPlayer())

    self.modelView = modelView
end

---Creates a new instance of CharacterOutfit3D
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@return CharacterOutfit3D
function CharacterOutfit3D:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height) --[[@as CharacterOutfit3D]]
    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = {r=0, g=1, b=0, a=1}
    o.borderColor = {r=1, g=0, b=0, a=1}

    return o
end

return CharacterOutfit3D