-- needed libs
require "ISUI/ISPanel"
require "ISUI/ISComboBox"
require "DebugUIs/AttachmentEditorUI"
local Wiki3DScene = require "WikiTools/ISUI/ItemUI/Wiki3DScene"

---@class ItemUI : ISPanel
---@field scene Wiki3DScene
local ItemUI = ISPanel:derive("ItemUI")

---CACHE
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6



function ItemUI:initialise()
    ISPanel.initialise(self)
    self:create()
end

function ItemUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
end




function ItemUI:onComboAddModel()
	local scriptName = self.comboAddModel:getOptionText(self.comboAddModel.selected)
	self.comboAddModel.selected = 0 -- ADD MODEL
	self.scene:fromLua2("createModel", scriptName, scriptName)
	-- self:toUI()
end

function ItemUI:create()
    -- Create UI elements here
    local scripts = getScriptManager():getAllModelScripts()
    local sorted = {}
	for i=0,scripts:size()-1 do repeat
        local script = scripts:get(i)
        local fullType = script:getFullType()
        if fullType == "Base.FemaleBody" or fullType == "Base.MaleBody" then
            break
        end
        table.insert(sorted, fullType)
    until true end

    -- combo box selection
    local combo = ISComboBox:new(0, 0, self.width, LABEL_HGT, self, self.onComboAddModel)
	combo.noSelectionText = getText("IGUI_AttachmentEditor_AddModel")
	combo:setEditable(true)
	self:addChild(combo)
	self.comboAddModel = combo

    table.sort(sorted)
	for _,scriptName in ipairs(sorted) do
		combo:addOption(scriptName)
	end
    combo.selected = 0 -- ADD MODEL


    -- 3D scene
    self.scene = Wiki3DScene:new(0, 0, 500, 500)
    self.scene:initialise()
	self.scene:instantiate()
    self:addChild(self.scene)



    -- self.scene = Scene:new(0, 0, self.width, self.height)

	-- self.scene:setAnchorRight(true)
	-- self.scene:setAnchorBottom(true)
	

    self.scene.javaObject:fromLua1("setMaxZoom", 20)
	self.scene.javaObject:fromLua1("setZoom", 10)
	-- self.scene.javaObject:fromLua1("setGizmoScale", 1.0 / 5.0)
end

function ItemUI:new()
    local o = {}
    o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight()) --[[@as ItemUI]]
    setmetatable(o, self)
    self.__index = self

    return o
end

return ItemUI