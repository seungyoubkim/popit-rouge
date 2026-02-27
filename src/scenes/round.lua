local SceneManager = require("src.scene_manager")
local GameState = require("src.game_state")
local Board = require("src.board")
local Combo = require("src.combo")

local Round = {}

local timer = 30
local score = 0
local targetScore = 0
local roundDelay = 0
local ROUND_DELAY_TIME = 0.5
local popupPhase = false
local lastCombo = nil  -- {comboType, comboCount, points}
local comboDisplayTimer = 0

function Round.enter()
    GameState.round = GameState.round + 1
    targetScore = GameState.getTargetScore()
    timer = 30
    score = 0
    roundDelay = 0
    popupPhase = false
    lastCombo = nil
    comboDisplayTimer = 0

    Board.init()
    Board.refill(GameState.getDeckAsList())
    Combo.reset()
end

function Round.update(dt)
    -- Timer countdown
    if timer > 0 and not popupPhase and roundDelay <= 0 then
        timer = timer - dt
        if timer <= 0 then
            timer = 0
            SceneManager.switch("result", false, score)
            return
        end
    end

    -- Win check
    if score >= targetScore then
        SceneManager.switch("result", true, score)
        return
    end

    -- Board animation
    Board.update(dt, popupPhase)

    -- Round transition delay
    if roundDelay > 0 then
        roundDelay = roundDelay - dt
        if roundDelay <= 0 then
            popupPhase = true
            Board.clearPressed()
        end
        return
    end

    -- Popup completion check
    if popupPhase then
        if Board.isAllPopped() then
            popupPhase = false
            Board.refill(GameState.getDeckAsList())
        end
        return
    end

    -- Turn completion check
    if Board.countLit() == 0 and Board.hasPressed() then
        roundDelay = ROUND_DELAY_TIME
    end

    -- Combo display timer
    if comboDisplayTimer > 0 then
        comboDisplayTimer = comboDisplayTimer - dt
    end
end

local function handlePress(sx, sy)
    if roundDelay > 0 or popupPhase then return end
    if timer <= 0 then return end

    local color = Board.handlePress(sx, sy)
    if color then
        local result = Combo.onPop(color)
        score = score + result.points
        if result.comboType then
            lastCombo = result
            comboDisplayTimer = 1.5
        end
    end
end

function Round.mousepressed(x, y, button)
    if button ~= 1 then return end
    handlePress(x, y)
end

function Round.touchpressed(id, x, y)
    handlePress(x, y)
end

function Round.draw()
    local sw, sh = love.graphics.getDimensions()

    -- Timer
    love.graphics.setFont(Fonts.bold)
    local timerColor = timer <= 5 and {1, 0.3, 0.3} or {1, 1, 1}
    love.graphics.setColor(timerColor)
    local timerText = string.format("%d", math.ceil(timer))
    local timerW = Fonts.bold:getWidth(timerText)
    love.graphics.print(timerText, (sw - timerW) / 2, 30)

    -- Score / Target
    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(1, 0.85, 0.3)
    local scoreText = string.format("%d / %d", score, targetScore)
    local scoreW = Fonts.regular:getWidth(scoreText)
    love.graphics.print(scoreText, (sw - scoreW) / 2, 65)

    -- Round indicator
    love.graphics.setColor(0.6, 0.6, 0.65)
    local roundText = string.format("라운드 %d", GameState.round)
    love.graphics.print(roundText, 20, 30)

    -- Combo display
    if comboDisplayTimer > 0 and lastCombo then
        love.graphics.setFont(Fonts.bold)
        local comboText = ""
        if lastCombo.comboType == "mono" then
            love.graphics.setColor(1, 0.5, 0.2)
            comboText = string.format("모노컬러 콤보 x%d! +%d", lastCombo.comboCount, lastCombo.points)
        elseif lastCombo.comboType == "rainbow" then
            love.graphics.setColor(0.4, 0.8, 1)
            comboText = string.format("레인보우 콤보 x%d! +%d", lastCombo.comboCount, lastCombo.points)
        end
        local cw = Fonts.bold:getWidth(comboText)
        love.graphics.print(comboText, (sw - cw) / 2, 100)
    end

    -- Board
    Board.draw()

    -- Turn clear text
    if Board.countLit() == 0 and (roundDelay > 0 or popupPhase) then
        love.graphics.setFont(Fonts.regular)
        love.graphics.setColor(0.3, 1, 0.5)
        local clearText = "Clear!"
        local clearW = Fonts.regular:getWidth(clearText)
        love.graphics.print(clearText, (sw - clearW) / 2, 130)
    end
end

function Round.resize(w, h)
    Board.updateLayout()
end

return Round
