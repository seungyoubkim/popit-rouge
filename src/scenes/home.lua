local SceneManager = require("src.scene_manager")
local GameState = require("src.game_state")
local UI = require("src.ui")

local Home = {}

local startButton = nil

function Home.enter()
    Home.buildUI()
end

function Home.buildUI()
    local sw, sh = love.graphics.getDimensions()
    local bw, bh = 200, 60
    startButton = UI.Button.new("게임 시작", (sw - bw) / 2, sh * 0.55, bw, bh, function()
        GameState.reset()
        SceneManager.switch("lobby")
    end)
end

function Home.update(dt)
end

function Home.draw()
    local sw, sh = love.graphics.getDimensions()

    -- Title
    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(1, 0.85, 0.3)
    local title = "Pop It Rouge"
    local tw = Fonts.bold:getWidth(title)
    love.graphics.print(title, (sw - tw) / 2, sh * 0.3)

    -- Subtitle
    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(0.7, 0.7, 0.75)
    local sub = "팝잇 + 로그라이크 덱빌딩"
    local subw = Fonts.regular:getWidth(sub)
    love.graphics.print(sub, (sw - subw) / 2, sh * 0.38)

    -- Button
    love.graphics.setFont(Fonts.bold)
    if startButton then startButton:draw() end
end

function Home.mousepressed(x, y, button)
    if button ~= 1 then return end
    if startButton then startButton:handlePress(x, y) end
end

function Home.touchpressed(id, x, y)
    if startButton then startButton:handlePress(x, y) end
end

function Home.resize(w, h)
    Home.buildUI()
end

return Home
