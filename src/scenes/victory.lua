local SceneManager = require("src.scene_manager")
local UI = require("src.ui")

local Victory = {}

local homeButton = nil

function Victory.enter()
    Victory.buildUI()
end

function Victory.buildUI()
    local sw, sh = love.graphics.getDimensions()
    local bw, bh = 200, 60
    homeButton = UI.Button.new("홈으로", (sw - bw) / 2, sh * 0.65, bw, bh, function()
        SceneManager.switch("home")
    end)
end

function Victory.update(dt)
end

function Victory.draw()
    local sw, sh = love.graphics.getDimensions()

    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(1, 0.85, 0.3)
    local title = "게임 승리!"
    local tw = Fonts.bold:getWidth(title)
    love.graphics.print(title, (sw - tw) / 2, sh * 0.3)

    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(0.8, 0.8, 0.85)
    local sub = "10라운드를 모두 클리어했습니다!"
    local subW = Fonts.regular:getWidth(sub)
    love.graphics.print(sub, (sw - subW) / 2, sh * 0.42)

    love.graphics.setFont(Fonts.bold)
    if homeButton then homeButton:draw() end
end

function Victory.mousepressed(x, y, button)
    if button ~= 1 then return end
    if homeButton then homeButton:handlePress(x, y) end
end

function Victory.touchpressed(id, x, y)
    if homeButton then homeButton:handlePress(x, y) end
end

function Victory.resize(w, h)
    Victory.buildUI()
end

return Victory
