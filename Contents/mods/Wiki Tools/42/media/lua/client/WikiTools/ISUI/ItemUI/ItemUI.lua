-- needed libs
require "ISUI/ISPanel"
require "ISUI/ISComboBox"
require "DebugUIs/AttachmentEditorUI"
local Wiki3DScene = require "WikiTools/ISUI/ItemUI/Wiki3DScene"
local ColorSelector = require "WikiTools/ISUI/ColorSelector"

local module = require "WikiTools/module"

---@class ItemUI : ISPanel
---@field scene Wiki3DScene
local ItemUI = ISPanel:derive("ItemUI")

---CACHE
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
-- local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
-- local UI_BORDER_SPACING = 10
-- local BUTTON_HGT = FONT_HGT_SMALL + 6
-- local LABEL_HGT = FONT_HGT_MEDIUM + 6

local BUTTON_WIDTH, BUTTON_HEIGHT = 100, 25
local BORDER_X, BORDER_Y = 25, 25



function ItemUI:initialise()
    ISPanel.initialise(self)
    self:create()
end

function ItemUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    module.UIinstance = nil
end


function ItemUI:prerender()
    ISPanel.prerender(self)

    local bgColor = self.colorSelector:getColor()
    bgColor.a = 1
    self.scene:setBackgroundColor(bgColor)
end


function ItemUI:onTickBox(index, selected)
    local data = self.tickBox:getOptionData(index)
    if not data then return end

    local target = data.target
    local func = data.func
    if target and func then
        func(target, selected, unpack(data.args))
    end
end

function ItemUI:populateModelList(combo)
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

    -- sort and add to combo
    table.sort(sorted)
	for _,scriptName in ipairs(sorted) do
		combo:addOption(scriptName)
	end
    combo.selected = 0 -- the default option is "ADD MODEL"
end

function ItemUI:create()
    -- close button
    local closeButton = ISButton:new(self.width - BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT, "Close", self, self.close)
    closeButton:initialise()
    self:addChild(closeButton)
    self.closeButton = closeButton

    -- 3D scene
    local scene_x, scene_y = BORDER_X, BORDER_Y
    local scene_h = self.height - BORDER_Y * 2
    local scene_w = scene_h
    local scene = Wiki3DScene:new(scene_x, scene_y, scene_w, scene_h)
    scene:initialise()
	scene:instantiate()
    self:addChild(scene)
    scene:setupScene()
    self.scene = scene

    -- combo box selection
    local combo_x, combo_y = scene_x + scene_w + BORDER_X, scene_y
    local combo_w, combo_h = 200, BUTTON_HEIGHT
    local comboAddModel = ISComboBox:new(combo_x, combo_y, combo_w, combo_h, self.scene, self.scene.onComboAddModel)
	comboAddModel.noSelectionText = getText("IGUI_AttachmentEditor_AddModel")
	comboAddModel:setEditable(true)
	self:addChild(comboAddModel)
	self.comboAddModel = comboAddModel
    self:populateModelList(comboAddModel)

    -- current combo box selection
    local label_x, label_y = combo_x, combo_y + combo_h + 2
    local label_h = FONT_HGT_SMALL + 2 * 2
    local comboAddModelLabel = ISLabel:new(label_x, label_y, label_h, self.scene.currentModel, 1, 1, 1, 1, UIFont.Small, true)
    comboAddModelLabel:initialise()
    self:addChild(comboAddModelLabel)
    self.comboAddModelLabel = comboAddModelLabel

    -- tick boxes
    local tick_x, tick_y = combo_x + combo_w + BORDER_X, combo_y
    local tick_w, tick_h = 100, FONT_HGT_SMALL + 2 * 2
    local tickBox = ISTickBox:new(tick_x, tick_y, tick_w, tick_h, "Ticks", self, self.onTickBox)
    tickBox:initialise()
    self:addChild(tickBox)
    self.tickBox = tickBox

    -- tick options
    tickBox:addOption("Show grid", {target=self.scene, func=self.scene.onTickFromLua, args={"setDrawGrid"}})
    tickBox:addOption("Show axes", {target=self.scene, func=self.scene.onTickFromLua, args={"setDrawGridAxes"}})
    -- tickBox:addOption("Show plane", {target=self.scene, func=self.scene.onTickFromLua, args={"setDrawGridPlane"}}) -- some items are below the planes

    tickBox:setSelected(1, false)

    -- color background selector on the bottom
    local color_w, color_h = 400, 150
    local color_x, color_y = combo_x, self.height - BORDER_Y - color_h
    local colorSelector = ColorSelector:new(color_x, color_y, color_w, color_h, {r=0, g=1, b=0, a=1}, false)
    colorSelector:initialise()
    self:addChild(colorSelector)
    self.colorSelector = colorSelector
end

function ItemUI:new()
    local o = {}
    o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight()) --[[@as ItemUI]]
    setmetatable(o, self)
    self.__index = self

    o.backgroundColor.a = 0.8

    return o
end

return ItemUI