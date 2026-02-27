-- 가상 해상도 (기준 해상도)
local VIRTUAL_WIDTH = 450
local VIRTUAL_HEIGHT = 800

-- 스케일링 변수
local scale = 1
local offsetX = 0
local offsetY = 0

-- 보드 설정
local GRID_COLS = 5
local GRID_ROWS = 8
local BUBBLE_RADIUS = 30
local BUBBLE_SPACING = 10
local BUBBLE_SIZE = BUBBLE_RADIUS * 2 + BUBBLE_SPACING
local BOARD_START_X = (VIRTUAL_WIDTH - (GRID_COLS * BUBBLE_SIZE - BUBBLE_SPACING)) / 2
local BOARD_START_Y = 150

-- 게임 상태
local grid = {}
local round = 0
local roundDelay = 0        -- 라운드 전환 딜레이 타이머
local ROUND_DELAY_TIME = 0.5
local popupPhase = false     -- 팝업(리셋) 애니메이션 중인지
local PRESS_ANIM_SPEED = 1 / 0.15   -- 0.15초에 0→1
local POPUP_ANIM_SPEED = 1 / 0.2    -- 0.2초에 1→0

local function updateScale()
    local windowW, windowH = love.graphics.getDimensions()
    local scaleX = windowW / VIRTUAL_WIDTH
    local scaleY = windowH / VIRTUAL_HEIGHT
    scale = math.min(scaleX, scaleY)
    offsetX = (windowW - VIRTUAL_WIDTH * scale) / 2
    offsetY = (windowH - VIRTUAL_HEIGHT * scale) / 2
end

local function initGrid()
    grid = {}
    for row = 1, GRID_ROWS do
        grid[row] = {}
        for col = 1, GRID_COLS do
            grid[row][col] = { lit = false, pressed = false, pressAnim = 0 }
        end
    end
end

local function resetBubbles()
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            local b = grid[row][col]
            b.lit = false
            b.pressed = false
            b.pressAnim = 0
        end
    end
end

local function startRound()
    resetBubbles()
    round = round + 1

    -- 랜덤 3~8개 버블을 lit
    local count = love.math.random(3, 8)
    local candidates = {}
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            table.insert(candidates, grid[row][col])
        end
    end
    -- Fisher-Yates 셔플
    for i = #candidates, 2, -1 do
        local j = love.math.random(i)
        candidates[i], candidates[j] = candidates[j], candidates[i]
    end
    for i = 1, count do
        candidates[i].lit = true
    end
end

local function getBubbleCenter(row, col)
    local cx = BOARD_START_X + (col - 1) * BUBBLE_SIZE + BUBBLE_RADIUS
    local cy = BOARD_START_Y + (row - 1) * BUBBLE_SIZE + BUBBLE_RADIUS
    return cx, cy
end

local function countLit()
    local n = 0
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            if grid[row][col].lit then n = n + 1 end
        end
    end
    return n
end

local function allPoppedUp()
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            if grid[row][col].pressAnim > 0 then return false end
        end
    end
    return true
end

function love.load()
    love.graphics.setBackgroundColor(0.15, 0.15, 0.2)
    updateScale()
    initGrid()
    startRound()
end

function love.resize(w, h)
    updateScale()
end

function love.update(dt)
    -- 눌림/팝업 애니메이션 업데이트
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            local b = grid[row][col]
            if b.pressed then
                -- 눌림: pressAnim → 1
                if b.pressAnim < 1 then
                    b.pressAnim = math.min(1, b.pressAnim + dt * PRESS_ANIM_SPEED)
                end
            elseif popupPhase then
                -- 팝업: pressAnim → 0
                if b.pressAnim > 0 then
                    b.pressAnim = math.max(0, b.pressAnim - dt * POPUP_ANIM_SPEED)
                end
            end
        end
    end

    -- 라운드 전환 딜레이
    if roundDelay > 0 then
        roundDelay = roundDelay - dt
        if roundDelay <= 0 then
            -- 팝업 애니메이션 시작
            popupPhase = true
        end
        return
    end

    -- 팝업 완료 체크
    if popupPhase then
        if allPoppedUp() then
            popupPhase = false
            startRound()
        end
        return
    end

    -- 라운드 완료 판정
    if countLit() == 0 and round > 0 then
        -- pressed 상태인 버블이 있으면 딜레이 후 리셋
        local hasPressed = false
        for row = 1, GRID_ROWS do
            for col = 1, GRID_COLS do
                if grid[row][col].pressed then hasPressed = true end
            end
        end
        if hasPressed then
            roundDelay = ROUND_DELAY_TIME
        end
    end
end

function love.mousepressed(screenX, screenY, button)
    if button ~= 1 then return end
    if roundDelay > 0 or popupPhase then return end

    -- 스크린 좌표 → 가상 좌표
    local vx = (screenX - offsetX) / scale
    local vy = (screenY - offsetY) / scale

    -- 어떤 버블 위인지 판별
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            local b = grid[row][col]
            if b.lit then
                local cx, cy = getBubbleCenter(row, col)
                local dist = math.sqrt((vx - cx)^2 + (vy - cy)^2)
                if dist <= BUBBLE_RADIUS then
                    b.lit = false
                    b.pressed = true
                    return
                end
            end
        end
    end
end

local function drawBubble(row, col)
    local b = grid[row][col]
    local cx, cy = getBubbleCenter(row, col)
    local anim = b.pressAnim

    -- 눌림 정도에 따른 스케일 (1.0 → 0.85)
    local s = 1 - anim * 0.15
    local r = BUBBLE_RADIUS * s

    if b.lit then
        -- 불 켜진 버블: 밝은 노란색/주황색
        -- 외곽 그림자
        love.graphics.setColor(0.8, 0.5, 0.1, 0.6)
        love.graphics.circle("fill", cx, cy + 2, r + 2)
        -- 본체
        love.graphics.setColor(1.0, 0.75, 0.2)
        love.graphics.circle("fill", cx, cy, r)
        -- 하이라이트
        love.graphics.setColor(1.0, 0.95, 0.6, 0.7)
        love.graphics.circle("fill", cx - r * 0.25, cy - r * 0.25, r * 0.4)
    elseif b.pressed or anim > 0 then
        -- 눌린 버블: 안쪽 그림자 효과
        -- 오목한 느낌을 위한 어두운 원
        love.graphics.setColor(0.18, 0.18, 0.25)
        love.graphics.circle("fill", cx, cy, r)
        -- 안쪽 그림자 (위쪽이 어둡고 아래가 밝은 느낌)
        love.graphics.setColor(0.12, 0.12, 0.18, anim * 0.8)
        love.graphics.circle("fill", cx, cy - r * 0.1, r * 0.9)
        -- 안쪽 하이라이트 (아래쪽)
        love.graphics.setColor(0.25, 0.25, 0.35, anim * 0.5)
        love.graphics.circle("fill", cx, cy + r * 0.15, r * 0.6)
    else
        -- 기본 버블: 올라온 상태 (연한 회색, 볼록한 느낌)
        -- 외곽 그림자
        love.graphics.setColor(0.2, 0.2, 0.28, 0.5)
        love.graphics.circle("fill", cx, cy + 3, r + 1)
        -- 본체
        love.graphics.setColor(0.55, 0.55, 0.62)
        love.graphics.circle("fill", cx, cy, r)
        -- 하이라이트 (볼록 효과)
        love.graphics.setColor(0.7, 0.7, 0.77, 0.6)
        love.graphics.circle("fill", cx - r * 0.2, cy - r * 0.2, r * 0.45)
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale)

    -- 게임 영역 배경
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    -- 보드 배경 (실리콘 느낌의 둥근 사각형)
    local boardW = GRID_COLS * BUBBLE_SIZE - BUBBLE_SPACING + 40
    local boardH = GRID_ROWS * BUBBLE_SIZE - BUBBLE_SPACING + 40
    local boardX = BOARD_START_X - 20
    local boardY = BOARD_START_Y - 20
    love.graphics.setColor(0.22, 0.22, 0.3)
    love.graphics.rectangle("fill", boardX, boardY, boardW, boardH, 20, 20)

    -- 버블 그리기
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            drawBubble(row, col)
        end
    end

    -- UI: 라운드 표시
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local roundText = string.format("Round %d", round)
    local tw = font:getWidth(roundText)
    love.graphics.print(roundText, (VIRTUAL_WIDTH - tw) / 2, 50)

    -- UI: 남은 버블 수
    local litCount = countLit()
    if litCount > 0 then
        love.graphics.setColor(1, 0.85, 0.3)
        local litText = string.format("남은 버블: %d", litCount)
        local lw = font:getWidth(litText)
        love.graphics.print(litText, (VIRTUAL_WIDTH - lw) / 2, 80)
    elseif roundDelay > 0 or popupPhase then
        love.graphics.setColor(0.3, 1, 0.5)
        local clearText = "Clear!"
        local cw = font:getWidth(clearText)
        love.graphics.print(clearText, (VIRTUAL_WIDTH - cw) / 2, 80)
    end

    -- 디버그 정보
    love.graphics.setColor(0.5, 0.5, 0.5)
    local w, h = love.graphics.getDimensions()
    love.graphics.print(string.format("Window: %dx%d | Scale: %.2f", w, h, scale), 10, VIRTUAL_HEIGHT - 30)

    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
