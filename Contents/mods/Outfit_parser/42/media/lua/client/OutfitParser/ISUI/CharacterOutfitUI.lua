-- needed libs
require "ISUI/ISPanel"
local CharacterOutfit3D = require "OutfitParser/ISUI/CharacterOutfit3D"
local ColorSelector = require "OutfitParser/ISUI/ColorSelector"
local NumberSlider = require "OutfitParser/ISUI/NumberSlider"
local ProgressBar = require "OutfitParser/ISUI/ProgressBar"

---CACHE
local buttonWidth, buttonHeight = 100, 25
local borderX, borderY = 25, 25


---@class CharacterOutfitUI : ISPanel
---@field filenamePattern string
---@field screenshotDelay number
---@field lastScreenshotTime number
---@field outfits table<number, table<string, string>>
---@field model_x integer
---@field model_y integer
---@field model_w integer
---@field model_h integer
---@field renderOutfits table<number, table<string, string>>
---@field iteration integer
---@field maxIterations integer
---@field model3D CharacterOutfit3D
---@field closeButton ISButton
---@field logPanel ISRichTextPanel
---@field parse_outfits ISButton
local CharacterOutfitUI = ISPanel:derive("CharacterOutfitUI")


function CharacterOutfitUI:initialise()
    ISPanel.initialise(self)
    self:create()
end

function CharacterOutfitUI:close()
	self:setVisible(false)
    self:removeFromUIManager()
end

function CharacterOutfitUI:prerender()
    ISPanel.prerender(self)

    local bgColor = self.colorSelector:getColor()
    bgColor.a = 1
    self.model3D:setBackgroundColor(bgColor)

    if not self.renderOutfits then
        return
    end

    --- RENDER NEXT OUTFIT
    local i = self.iteration
    local outfit = self.renderOutfits[i]
    if not outfit then
        self.renderOutfits = nil
        self.lastScreenshotTime = nil
        return
    end

    local filename = self:getFilename(outfit)

    -- verify that the time delta was reached before screenshot
    local currentTime = getTimestampMs() / 1000
    if not self.lastScreenshotTime then
        -- set outfit to model view
        local female = outfit.gender == "female"
        self.model3D:setOutfitName(outfit.outfit, female)

        self:log(filename)
        self.progressBar:setValue(i)

        self.lastScreenshotTime = currentTime
    elseif (currentTime - self.lastScreenshotTime) > self.deltaSelector:getValue() then
        -- take screenshot
        self:takeScreenshot(filename)

        -- increase iteration counter
        self.iteration = self.iteration + 1
        self.lastScreenshotTime = nil
        if i >= self.maxIterations then
            self.renderOutfits = nil
            return
        end
    end
end

function CharacterOutfitUI:formatTemplate(template, params)
    return template:gsub("{(%w+)}", params)
end

function CharacterOutfitUI:getFilename(params)
    return self:formatTemplate(self.filenamePattern, params)
end

function CharacterOutfitUI:takeScreenshot(filename)
    getCore():TakeFullScreenshot(filename)
end


function CharacterOutfitUI:getOutfits()
    local maleOutfits = getAllOutfits(false)
    local femaleOutfits = getAllOutfits(true)

    -- store outfits in a single list
    local outfits = {}
    for i = 0, maleOutfits:size() - 1 do
        local outfit = maleOutfits:get(i)
        table.insert(outfits, {outfit = outfit, gender = "male"})
    end
    for i = 0, femaleOutfits:size() - 1 do
        local outfit = femaleOutfits:get(i)
        table.insert(outfits, {outfit = outfit, gender = "female"})
    end

    return outfits
end

function CharacterOutfitUI:parseOutfits()
    -- intialize rendering
    self.renderOutfits = self.outfits
    self.iteration = 1
end



function CharacterOutfitUI:log(message)
    self.logPanel.text = message .. "\n" .. self.logPanel.text
    self.logPanel:paginate()
end


function CharacterOutfitUI:create()
    --- create 3D model
    local model_x, model_y = self.model_x, self.model_y
    local model_w, model_h = self.model_w, self.model_h
    local model3D = CharacterOutfit3D:new(model_x, model_y, model_w, model_h)
    model3D:initialise()
    self:addChild(model3D)
    self.model3D = model3D

    -- close button
    local closeButton = ISButton:new(self.width - buttonWidth, 0, buttonWidth, buttonHeight, "Close", self, self.close)
    closeButton:initialise()
    self:addChild(closeButton)
    self.closeButton = closeButton

    -- log panel
    local log_x, log_y = model_x + model_w + borderX, borderY
    local log_w, log_h = 200, self.height - borderY*2
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

    -- parse outfits button
    local parse_outfits = ISButton:new(log_x + log_w + borderX, log_y, buttonWidth, buttonHeight, "Parse outfits", self, self.parseOutfits)
    parse_outfits:initialise()
    self:addChild(parse_outfits)
    self.parse_outfits = parse_outfits

    -- stop button
    local stop_x, stop_y = log_x + log_w + borderX, log_y + buttonHeight + borderY
    local stop_button = ISButton:new(stop_x, stop_y, buttonWidth, buttonHeight, "Stop", self, function(self) self.renderOutfits = nil; self.lastScreenshotTime = nil end)
    stop_button:initialise()
    self:addChild(stop_button)
    self.stop_button = stop_button

    -- color background selector
    local color_x, color_y = log_x + log_w + borderX, stop_y + buttonHeight + borderY
    local color_w, color_h = 400, 150
    local colorSelector = ColorSelector:new(color_x, color_y, color_w, color_h, {r=0, g=1, b=0, a=1}, false)
    colorSelector:initialise()
    self:addChild(colorSelector)
    self.colorSelector = colorSelector

    -- time delta selector label
    local deltaLabel = ISLabel:new(color_x, color_y + color_h + borderY - 20, 20, "Delay (s):", 1, 1, 1, 1, UIFont.Small, true)
    deltaLabel:initialise()
    self:addChild(deltaLabel)
    self.deltaLabel = deltaLabel

     -- time delta selector
    local delta_x, delta_y = color_x, color_y + color_h + borderY
    local delta_w, delta_h = color_w, 25
    local deltaSelector = NumberSlider:new(delta_x, delta_y, delta_w, delta_h, self.screenshotDelay, 0, 20, 0.1, 1)
    deltaSelector:initialise()
    self:addChild(deltaSelector)
    self.deltaSelector = deltaSelector

    -- progress bar
    local progress_x, progress_y = delta_x, delta_y + delta_h + borderY
    local progress_w, progress_h = color_w, 25
    local progressBar = ProgressBar:new(progress_x, progress_y, progress_w, progress_h, 1)
    progressBar:initialise()
    self:addChild(progressBar)
    self.progressBar = progressBar
    progressBar:setMaxValue(#self.outfits)

    -- filename text box
    local filename_x, filename_y = progress_x, progress_y + progress_h + borderY
    local filename_w, filename_h = color_w, 25
    local filenameBox = ISTextEntryBox:new(self.filenamePattern, filename_x, filename_y, filename_w, filename_h)
    filenameBox:initialise()
    self:addChild(filenameBox)
    self.filenameBox = filenameBox
end

function CharacterOutfitUI:new()
    local o = {}
    o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight()) --[[@as CharacterOutfitUI]]
    setmetatable(o, self)
    self.__index = self

    o.filenamePattern = "OutfitParser/Outfit {outfit} {gender}.png"
    o.model_x, o.model_y = borderX, borderY
    o.model_w, o.model_h = getCore():getScreenHeight() - borderY*2, getCore():getScreenHeight() - borderY*2

    o.screenshotDelay = 1 -- seconds

    o.outfits = o:getOutfits()
    o.maxIterations = #o.outfits

    o.backgroundColor.a = 0.8

    return o
end


return CharacterOutfitUI