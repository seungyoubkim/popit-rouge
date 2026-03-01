local SceneManager = require("src.scene_manager")
local GameState = require("src.game_state")
local UI = require("src.ui")

local Result = {}

local finalScore = 0
local actionButton = nil

function Result.enter(isWin, resultScore)
    finalScore = resultScore or 0
    Result.buildUI()
end

function Result.buildUI()
    local sw, sh = love.graphics.getDimensions()
    local bw, bh = 200, 60

    actionButton = UI.Button.new("홈으로", (sw - bw) / 2, sh * 0.65, bw, bh, function()
        SceneManager.switch("home")
    end)
end

function Result.update(dt)
end

function Result.draw()
    local sw, sh = love.graphics.getDimensions()

    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(1, 0.3, 0.3)
    local title = "게임 오버"
    local tw = Fonts.bold:getWidth(title)
    love.graphics.print(title, (sw - tw) / 2, sh * 0.3)

    -- Score display
    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(1, 1, 1)
    local scoreText = string.format("획득 점수: %d", finalScore)
    local sw2 = Fonts.regular:getWidth(scoreText)
    love.graphics.print(scoreText, (sw - sw2) / 2, sh * 0.42)

    -- Round info
    love.graphics.setColor(0.7, 0.7, 0.75)
    local roundText = string.format("라운드 %d", GameState.round)
    local rw = Fonts.regular:getWidth(roundText)
    love.graphics.print(roundText, (sw - rw) / 2, sh * 0.50)

    -- Button
    love.graphics.setFont(Fonts.bold)
    if actionButton then actionButton:draw() end
end

function Result.mousepressed(x, y, button)
    if button ~= 1 then return end
    if actionButton then actionButton:handlePress(x, y) end
end

function Result.touchpressed(id, x, y)
    if actionButton then actionButton:handlePress(x, y) end
end

function Result.resize(w, h)
    Result.buildUI()
end

return Result
