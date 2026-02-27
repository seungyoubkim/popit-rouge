local SceneManager = require("src.scene_manager")
local GameState = require("src.game_state")
local UI = require("src.ui")

local Lobby = {}

local startButton = nil

function Lobby.enter()
    Lobby.buildUI()
end

function Lobby.buildUI()
    local sw, sh = love.graphics.getDimensions()
    local bw, bh = 200, 60
    startButton = UI.Button.new("라운드 시작", (sw - bw) / 2, sh * 0.7, bw, bh, function()
        SceneManager.switch("round")
    end)
end

function Lobby.update(dt)
end

function Lobby.draw()
    local sw, sh = love.graphics.getDimensions()

    -- Round number
    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(1, 1, 1)
    local roundText = string.format("라운드 %d", GameState.round + 1)
    local tw = Fonts.bold:getWidth(roundText)
    love.graphics.print(roundText, (sw - tw) / 2, sh * 0.15)

    -- Deck display
    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(0.8, 0.8, 0.85)
    local deckTitle = "보유 버블"
    local dtw = Fonts.regular:getWidth(deckTitle)
    love.graphics.print(deckTitle, (sw - dtw) / 2, sh * 0.28)

    local colorNames = {
        { key = "red",     name = "빨강",  color = {0.9, 0.25, 0.2} },
        { key = "blue",    name = "파랑",  color = {0.2, 0.45, 0.9} },
        { key = "yellow",  name = "노랑",  color = {1.0, 0.75, 0.2} },
        { key = "rainbow", name = "무지개", color = {0.8, 0.5, 0.9} },
    }

    local y = sh * 0.35
    for _, c in ipairs(colorNames) do
        local count = GameState.deck[c.key] or 0
        if count > 0 then
            -- Color indicator circle
            love.graphics.setColor(c.color[1], c.color[2], c.color[3])
            love.graphics.circle("fill", sw * 0.3, y + 10, 10)

            -- Text
            love.graphics.setColor(1, 1, 1)
            local text = string.format("%s x%d", c.name, count)
            love.graphics.print(text, sw * 0.3 + 20, y)
            y = y + 35
        end
    end

    -- Total
    love.graphics.setColor(0.6, 0.6, 0.65)
    local total = string.format("총 %d개", GameState.getTotalBubbles())
    local totalW = Fonts.regular:getWidth(total)
    love.graphics.print(total, (sw - totalW) / 2, y + 10)

    -- Target score
    love.graphics.setColor(1, 0.85, 0.3)
    local target = string.format("목표 점수: %d", GameState.targetScores[GameState.round + 1] or 0)
    local targetW = Fonts.regular:getWidth(target)
    love.graphics.print(target, (sw - targetW) / 2, y + 45)

    -- Button
    love.graphics.setFont(Fonts.bold)
    if startButton then startButton:draw() end
end

function Lobby.mousepressed(x, y, button)
    if button ~= 1 then return end
    if startButton then startButton:handlePress(x, y) end
end

function Lobby.touchpressed(id, x, y)
    if startButton then startButton:handlePress(x, y) end
end

function Lobby.resize(w, h)
    Lobby.buildUI()
end

return Lobby
