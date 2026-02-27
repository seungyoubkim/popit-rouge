local SceneManager = {}

local currentScene = nil
local scenes = {}

function SceneManager.register(name, scene)
    scenes[name] = scene
end

function SceneManager.switch(name, ...)
    if scenes[name] then
        currentScene = scenes[name]
        if currentScene.enter then
            currentScene.enter(...)
        end
    end
end

function SceneManager.update(dt)
    if currentScene and currentScene.update then
        currentScene.update(dt)
    end
end

function SceneManager.draw()
    if currentScene and currentScene.draw then
        currentScene.draw()
    end
end

function SceneManager.mousepressed(x, y, button)
    if currentScene and currentScene.mousepressed then
        currentScene.mousepressed(x, y, button)
    end
end

function SceneManager.touchpressed(id, x, y)
    if currentScene and currentScene.touchpressed then
        currentScene.touchpressed(id, x, y)
    end
end

function SceneManager.resize(w, h)
    if currentScene and currentScene.resize then
        currentScene.resize(w, h)
    end
end

return SceneManager
