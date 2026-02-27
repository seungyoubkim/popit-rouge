local SceneManager = require("src.scene_manager")

-- Global fonts (accessible from all scenes)
Fonts = {
    regular = nil,
    bold = nil,
}

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

    -- Load Pretendard fonts
    Fonts.regular = love.graphics.newFont("assets/fonts/Pretendard-Regular.otf", 18)
    Fonts.bold = love.graphics.newFont("assets/fonts/Pretendard-Bold.otf", 28)
    love.graphics.setFont(Fonts.regular)

    -- Register all scenes
    SceneManager.register("home", require("src.scenes.home"))
    SceneManager.register("lobby", require("src.scenes.lobby"))
    SceneManager.register("round", require("src.scenes.round"))
    SceneManager.register("result", require("src.scenes.result"))
    SceneManager.register("shop", require("src.scenes.shop"))
    SceneManager.register("victory", require("src.scenes.victory"))

    -- Start at home screen
    SceneManager.switch("home")
end

function love.resize(w, h)
    SceneManager.resize(w, h)
end

function love.update(dt)
    SceneManager.update(dt)
end

function love.draw()
    SceneManager.draw()
end

function love.mousepressed(x, y, button)
    SceneManager.mousepressed(x, y, button)
end

function love.touchpressed(id, x, y)
    SceneManager.touchpressed(id, x, y)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
