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
local lastCombo = nil
local comboDisplayTimer = 0

-- Countdown before round starts
local countdown = 3
local countdownActive = true

-- Win overlay
local winActive = false
local winTimer = 0
local WIN_DISPLAY_TIME = 3

function Round.enter()
    GameState.round = GameState.round + 1
    targetScore = GameState.getTargetScore()
    timer = 30
    score = 0
    roundDelay = 0
    popupPhase = false
    lastCombo = nil
    comboDisplayTimer = 0

    countdown = 3
    countdownActive = true
    winActive = false
    winTimer = 0

    Board.init()
    Board.refill(GameState.getDeckAsList())
    Combo.reset()
end

function Round.update(dt)
    -- Pre-round countdown
    if countdownActive then
        countdown = countdown - dt
        if countdown <= 0 then
            countdownActive = false
        end
        return
    end

    -- Win overlay timer
    if winActive then
        winTimer = winTimer - dt
        if winTimer <= 0 then
            if GameState.round >= #GameState.targetScores then
                SceneManager.switch("victory")
            else
                SceneManager.switch("shop")
            end
        end
        return
    end

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
        winActive = true
        winTimer = WIN_DISPLAY_TIME
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
    if countdownActive or winActive then return end
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

    -- Apply screen shake offset
    local sx, sy = Board.getShakeOffset()
    love.graphics.push()
    love.graphics.translate(sx, sy)

    -- Pre-round countdown overlay
    if countdownActive then
        Board.draw()

        -- Dim overlay
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, sw, sh)

        love.graphics.setFont(Fonts.bold)
        love.graphics.setColor(1, 1, 1)
        local countNum = math.ceil(countdown)
        if countNum <= 0 then countNum = 1 end
        local countText = tostring(countNum)
        local cw = Fonts.bold:getWidth(countText)
        love.graphics.print(countText, (sw - cw) / 2, sh * 0.35)

        love.graphics.setFont(Fonts.regular)
        love.graphics.setColor(0.8, 0.8, 0.85)
        local readyText = "게임을 시작합니다"
        local rw = Fonts.regular:getWidth(readyText)
        love.graphics.print(readyText, (sw - rw) / 2, sh * 0.45)
        love.graphics.pop()
        return
    end

    -- Timer (moved down from top)
    love.graphics.setFont(Fonts.bold)
    local timerColor = timer <= 5 and {1, 0.3, 0.3} or {1, 1, 1}
    love.graphics.setColor(timerColor)
    local timerText = string.format("%d", math.ceil(timer))
    local timerW = Fonts.bold:getWidth(timerText)
    love.graphics.print(timerText, (sw - timerW) / 2, 60)

    -- Score / Target
    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(1, 0.85, 0.3)
    local scoreText = string.format("%d / %d", score, targetScore)
    local scoreW = Fonts.regular:getWidth(scoreText)
    love.graphics.print(scoreText, (sw - scoreW) / 2, 95)

    -- Round indicator
    love.graphics.setColor(0.6, 0.6, 0.65)
    local roundText = string.format("라운드 %d", GameState.round)
    love.graphics.print(roundText, 20, 60)

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
        love.graphics.print(comboText, (sw - cw) / 2, 130)
    end

    -- Board
    Board.draw()
    Board.drawParticlesAndFlashes()

    -- Turn clear text
    if Board.countLit() == 0 and (roundDelay > 0 or popupPhase) then
        love.graphics.setFont(Fonts.regular)
        love.graphics.setColor(0.3, 1, 0.5)
        local clearText = "Clear!"
        local clearW = Fonts.regular:getWidth(clearText)
        love.graphics.print(clearText, (sw - clearW) / 2, 160)
    end

    -- Win overlay
    if winActive then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, sw, sh)

        love.graphics.setFont(Fonts.bold)
        love.graphics.setColor(0.3, 1, 0.5)
        local winText = "승리!"
        local ww = Fonts.bold:getWidth(winText)
        love.graphics.print(winText, (sw - ww) / 2, sh * 0.35)

        love.graphics.setFont(Fonts.regular)
        love.graphics.setColor(1, 1, 1)
        local sText = string.format("획득 점수: %d", score)
        local sw2 = Fonts.regular:getWidth(sText)
        love.graphics.print(sText, (sw - sw2) / 2, sh * 0.45)
    end

    love.graphics.pop()
end

function Round.resize(w, h)
    Board.updateLayout()
end

return Round
