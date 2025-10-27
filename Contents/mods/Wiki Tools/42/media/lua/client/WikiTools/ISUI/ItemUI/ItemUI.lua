-- needed libs
require "ISUI/ISPanel"
require "ISUI/ISComboBox"
require "DebugUIs/AttachmentEditorUI"
local Wiki3DScene = require "WikiTools/ISUI/ItemUI/Wiki3DScene"
local ColorSelector = require "WikiTools/ISUI/ColorSelector"
local ISComboBoxModels = require "WikiTools/ISUI/ItemUI/ISComboBoxModels"

local module = require "WikiTools/module"

---@class ItemUI : ISPanel
---@field scene Wiki3DScene
local ItemUI = ISPanel:derive("ItemUI")

---CACHE
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
-- local UI_BORDER_SPACING = 10
-- local BUTTON_HGT = FONT_HGT_SMALL + 6
-- local LABEL_HGT = FONT_HGT_MEDIUM + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

local BUTTON_WIDTH, BUTTON_HEIGHT = 100, 25
local BORDER_X, BORDER_Y = 25, 25



---[[=====================================]]
--- RENDERING
---[[=====================================]]

function ItemUI:prerender()
    ISPanel.prerender(self)

    local bgColor = self.colorSelector:getColor()
    bgColor.a = 1
    self.scene:setBackgroundColor(bgColor)
end



---[[=====================================]]
--- PARSER
---[[=====================================]]





---[[=====================================]]
--- UTILS
---[[=====================================]]

---Format a template parameters written as `{param}` into a string. 
---@param template string
---@param params table
---@return string
---@return integer
function ItemUI:formatTemplate(template, params)
    return template:gsub("{(%w+)}", params)
end

---Get the filename from the provided params.
---@param params table
---@return string
---@return integer
function ItemUI:getFilename(params)
    return self:formatTemplate(self.filenamePattern, params)
end

---Take a screenshot which saves inside the cache folder `Zomboid/Screenshots` with the filename.
---@param filename string
function ItemUI:takeScreenshot(filename)
    getCore():TakeFullScreenshot(filename)
end

function ItemUI:getItemModel(item)
    local model = item:getWorldStaticModel()
    if model then return model end

    model = item:getStaticModel()
    if model then return model end

    return nil
end


---[[=====================================]]
--- BUTTONS AND UI ELEMENTS REACTIONS
---[[=====================================]]

function ItemUI:onComboAddModel()
    local combo = self.comboAddModel
    local selected = combo:getOptionText(combo.selected)
	combo.selected = 0 -- default option
    if not selected then
        self:log("UNEXPECTED: No model selected.")
        return
    end

    -- try to get the model
    local model = self.comboAddModel:getModel(selected)
    if not model then
        self:log("Couldn't find the model for item "..selected)
        return
    end

    self:log("Setting model: " .. selected)
	self.scene:setModel("worldModel", model)

    -- update label
    if self.comboAddModelLabel then
        self.comboAddModelLabel:setName(selected)
    end
end

function ItemUI:onComboChangeType()
    local combo = self.comboType
    local listingType = combo:getOptionText(combo.selected)
    if not listingType then
        self:log("UNEXPECTED: No type selected.")
        return
    end
    self:log("Listing: "..listingType)

    local modData = ModData.getOrCreate("WikiTools")
    modData.modelListingType = listingType
    self.listingType = listingType

    -- repopulate model list
    self.comboAddModel:updateListing(listingType)
end

---Handle tick box selection.
---@param index integer
---@param selected boolean
function ItemUI:onTickBox(index, selected)
    local data = self.tickBox:getOptionData(index)
    if not data then return end

    local target = data.target
    local func = data.func
    if target and func then
        func(target, selected, unpack(data.args))
    end
end

---Close the UI.
function ItemUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    module.UIinstance = nil
end

---Log a message to the log panel.
---@param message string
function ItemUI:log(message)
    self.logPanel.text = "> " .. message .. "\n" .. self.logPanel.text
    self.logPanel:paginate()
end



---[[=====================================]]
--- INSTANCE SETUP
---[[=====================================]]

function ItemUI:initialise()
    ISPanel.initialise(self)
    self:create()
end

function ItemUI:setupDefaultValues()
    local modData = ModData.getOrCreate("WikiTools")

    -- last opened model
    modData.lastOpenedModel = modData.lastOpenedModel or "Base.FireAxe"

    if self.comboAddModelLabel then
        self.comboAddModelLabel:setName(modData.lastOpenedModel)
    end

    -- weapon rotation hack
    if modData.weaponRotationHack == nil then
        modData.weaponRotationHack = true
    end
    self.scene.weaponRotationHack = modData.weaponRotationHack

    local tickBox = self.tickBox
    tickBox:setSelected(3, modData.weaponRotationHack)

    -- model listing type
    modData.modelListingType = modData.modelListingType or "Items"
    self.listingType = modData.modelListingType

    -- setup model
    self.scene:setModel("worldModel", modData.lastOpenedModel)
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

    -- color background selector on the bottom
    local color_w, color_h = 400, 150
    local color_x, color_y = scene_x + scene_w + BORDER_X, self.height - BORDER_Y - color_h
    local colorSelector = ColorSelector:new(color_x, color_y, color_w, color_h, {r=0, g=1, b=0, a=1}, false)
    colorSelector:initialise()
    self:addChild(colorSelector)
    self.colorSelector = colorSelector

    -- log panel
    local log_x, log_y = color_x, scene_y
    local log_w, log_h = 300, self.height - BORDER_Y*3 - color_h
    local logPanel = ISRichTextPanel:new(log_x, log_y, log_w, log_h)
    logPanel:initialise()

    logPanel.backgroundColor = {r=0, g=0, b=0, a=1}
    logPanel.autosetheight = false
    logPanel.clip = true
    logPanel:addScrollBars()

    self.clearText = "Logs"
    logPanel.text = self.clearText
    logPanel:paginate()

    self:addChild(logPanel)
    self.logPanel = logPanel


    -- combo box listing type
    local comboType_x, comboType_y = log_x + log_w + BORDER_X, log_y
    local comboType_w, comboType_h = 200, BUTTON_HEIGHT
    local comboType = ISComboBox:new(comboType_x, comboType_y, comboType_w, comboType_h, self, self.onComboChangeType)
    comboType.noSelectionText = "Select model listing method"
    comboType:setEditable(true)
    self:addChild(comboType)
    self.comboType = comboType

    -- combo box selection
    local comboModel_x, comboModel_y = comboType_x, comboType_y + comboType_h + BORDER_Y
    local comboModel_w, comboModel_h = comboType_w, comboType_h
    local comboAddModel = ISComboBoxModels:new(comboModel_x, comboModel_y, comboModel_w, comboModel_h, self, self.onComboAddModel)
	comboAddModel.noSelectionText = "Select listing method"
	comboAddModel:setEditable(true)
	self:addChild(comboAddModel)
	self.comboAddModel = comboAddModel

    -- current combo box selection label
    local label_x, label_y = comboModel_x, comboModel_y + comboModel_h + 2
    local comboAddModelLabel = ISLabel:new(label_x, label_y, LABEL_HGT, self.scene.currentModel, 1, 1, 1, 1, UIFont.Small, true)
    comboAddModelLabel:initialise()
    self:addChild(comboAddModelLabel)
    self.comboAddModelLabel = comboAddModelLabel

    -- tick boxes
    local tick_x, tick_y = comboType_x + comboType_w + BORDER_X, comboType_y
    local tick_w, tick_h = 100, FONT_HGT_SMALL + 2 * 2
    local tickBox = ISTickBox:new(tick_x, tick_y, tick_w, tick_h, "Ticks", self, self.onTickBox)
    tickBox:initialise()
    self:addChild(tickBox)
    self.tickBox = tickBox

    -- tick options
    tickBox:addOption("Show grid", {target=self.scene, func=self.scene.onTickFromLua1, args={"setDrawGrid"}})
    tickBox:addOption("Show axes", {target=self.scene, func=self.scene.onTickFromLua1, args={"setDrawGridAxes"}})
    tickBox:addOption("Weapon rotation hack", {target=self.scene, func=self.scene.setModelWeaponRotationHack, args={"worldModel"}})
    -- tickBox:addOption("Show plane", {target=self.scene, func=self.scene.onTickFromLua, args={"setDrawGridPlane"}}) -- some items are below the planes

    -- -- attachment button
    -- local attachment_x, attachment_y = combo_x, combo_y + combo_h + LABEL_HGT + BORDER_Y
    -- local attachment_w, attachment_h = combo_w, BUTTON_HEIGHT
    -- local attachmentButton = ISButton:new(attachment_x, attachment_y, attachment_w, attachment_h, "Edit Attachments", self.scene, Wiki3DScene.setAttach)
    -- attachmentButton:initialise()
    -- self:addChild(attachmentButton)
    -- self.attachmentButton = attachmentButton


    -- init model
    self:setupDefaultValues()

    -- populate combo box
    comboType:addOption("All models")
    comboType:addOption("All items")

    -- update selection
    comboType:select(self.listingType)
    self.comboAddModel:updateListing(self.listingType)
end

function ItemUI:new()
    local o = {}
    o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight()) --[[@as ItemUI]]
    setmetatable(o, self)
    self.__index = self

    o.filenamePattern = "ItemUI/Screenshot {model}.png"

    o.backgroundColor.a = 0.8

    return o
end

return ItemUI