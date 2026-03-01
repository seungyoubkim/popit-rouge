local Board = {}

local GRID_COLS = 5
local GRID_ROWS = 5
local BOARD_PADDING = 40
local BUBBLE_SPACING_RATIO = 0.14
local PRESS_ANIM_SPEED = 1 / 0.15
local POPUP_ANIM_SPEED = 1 / 0.2

local grid = {}
local bubbleRadius = 0
local bubbleSize = 0
local boardStartX = 0
local boardStartY = 0
local screenW = 0
local screenH = 0

-- Color definitions for drawing
local BUBBLE_COLORS = {
    red     = { main = { 0.9, 0.25, 0.2 }, highlight = { 1.0, 0.5, 0.45 }, shadow = { 0.7, 0.15, 0.1 } },
    blue    = { main = { 0.2, 0.45, 0.9 }, highlight = { 0.45, 0.65, 1.0 }, shadow = { 0.1, 0.3, 0.7 } },
    yellow  = { main = { 1.0, 0.75, 0.2 }, highlight = { 1.0, 0.9, 0.5 }, shadow = { 0.8, 0.55, 0.1 } },
    rainbow = nil, -- handled specially
}

function Board.updateLayout()
    screenW, screenH = love.graphics.getDimensions()

    local availableW = screenW - BOARD_PADDING * 2
    local diameter = availableW / (GRID_COLS + (GRID_COLS - 1) * BUBBLE_SPACING_RATIO)
    bubbleRadius = diameter / 2
    local spacing = diameter * BUBBLE_SPACING_RATIO
    bubbleSize = diameter + spacing

    local boardW = GRID_COLS * diameter + (GRID_COLS - 1) * spacing
    local boardH = GRID_ROWS * diameter + (GRID_ROWS - 1) * spacing

    boardStartX = (screenW - boardW) / 2
    local bottomMargin = screenH * 0.12
    boardStartY = screenH - bottomMargin - boardH
end

function Board.init()
    grid = {}
    for row = 1, GRID_ROWS do
        grid[row] = {}
        for col = 1, GRID_COLS do
            grid[row][col] = { lit = false, pressed = false, pressAnim = 0, color = nil }
        end
    end
    Board.updateLayout()
end

function Board.refill(deckList)
    -- Reset all bubbles
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            local b = grid[row][col]
            b.lit = false
            b.pressed = false
            b.pressAnim = 0
            b.color = nil
        end
    end

    local totalSlots = GRID_COLS * GRID_ROWS
    local bubbles = {}

    if #deckList <= totalSlots then
        -- All bubbles fit: assign to random positions
        for _, color in ipairs(deckList) do
            table.insert(bubbles, color)
        end
    else
        -- More than 25: randomly select 25
        local shuffled = {}
        for i, color in ipairs(deckList) do
            shuffled[i] = color
        end
        for i = #shuffled, 2, -1 do
            local j = love.math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        for i = 1, totalSlots do
            table.insert(bubbles, shuffled[i])
        end
    end

    -- Get random positions
    local positions = {}
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            table.insert(positions, { row = row, col = col })
        end
    end
    -- Shuffle positions
    for i = #positions, 2, -1 do
        local j = love.math.random(i)
        positions[i], positions[j] = positions[j], positions[i]
    end

    -- Assign bubbles to positions
    for i, color in ipairs(bubbles) do
        local pos = positions[i]
        local b = grid[pos.row][pos.col]
        b.lit = true
        b.color = color
    end
end

local function getBubbleCenter(row, col)
    local cx = boardStartX + (col - 1) * bubbleSize + bubbleRadius
    local cy = boardStartY + (row - 1) * bubbleSize + bubbleRadius
    return cx, cy
end

function Board.handlePress(sx, sy)
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            local b = grid[row][col]
            if b.lit then
                local cx, cy = getBubbleCenter(row, col)
                local dist = math.sqrt((sx - cx) ^ 2 + (sy - cy) ^ 2)
                if dist <= bubbleRadius then
                    b.lit = false
                    b.pressed = true
                    love.system.vibrate(0.05)
                    return b.color
                end
            end
        end
    end
    return nil
end

function Board.update(dt, popupPhase)
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            local b = grid[row][col]
            if b.pressed then
                if b.pressAnim < 1 then
                    b.pressAnim = math.min(1, b.pressAnim + dt * PRESS_ANIM_SPEED)
                end
            elseif popupPhase then
                if b.pressAnim > 0 then
                    b.pressAnim = math.max(0, b.pressAnim - dt * POPUP_ANIM_SPEED)
                end
            end
        end
    end
end

function Board.countLit()
    local n = 0
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            if grid[row][col].lit then n = n + 1 end
        end
    end
    return n
end

function Board.isAllPopped()
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            if grid[row][col].pressAnim > 0 then return false end
        end
    end
    return true
end

function Board.hasPressed()
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            if grid[row][col].pressed then return true end
        end
    end
    return false
end

function Board.clearPressed()
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            grid[row][col].pressed = false
        end
    end
end

local function getRainbowColor(t)
    local r = math.sin(t * math.pi * 2) * 0.5 + 0.5
    local g = math.sin(t * math.pi * 2 + math.pi * 2 / 3) * 0.5 + 0.5
    local b = math.sin(t * math.pi * 2 + math.pi * 4 / 3) * 0.5 + 0.5
    return r, g, b
end

local rainbowTime = 0

function Board.draw()
    rainbowTime = rainbowTime + love.timer.getDelta()

    -- Board background
    local spacing = bubbleRadius * 2 * BUBBLE_SPACING_RATIO
    local boardW = GRID_COLS * bubbleRadius * 2 + (GRID_COLS - 1) * spacing + 40
    local boardH = GRID_ROWS * bubbleRadius * 2 + (GRID_ROWS - 1) * spacing + 40
    local boardX = boardStartX - 20
    local boardY = boardStartY - 20
    love.graphics.setColor(0.16, 0.16, 0.22)
    love.graphics.rectangle("fill", boardX, boardY, boardW, boardH, 20, 20)

    -- Draw bubbles
    for row = 1, GRID_ROWS do
        for col = 1, GRID_COLS do
            Board.drawBubble(row, col)
        end
    end
end

function Board.drawBubble(row, col)
    local b = grid[row][col]
    local cx, cy = getBubbleCenter(row, col)
    local anim = b.pressAnim
    local s = 1 - anim * 0.15
    local r = bubbleRadius * s

    if b.lit then
        local color = b.color or "red"
        if color == "rainbow" then
            -- Rainbow shimmer
            local rr, gg, bb = getRainbowColor(rainbowTime + row * 0.3 + col * 0.2)
            love.graphics.setColor(rr * 0.6, gg * 0.6, bb * 0.6, 0.6)
            love.graphics.circle("fill", cx, cy + 2, r + 2)
            love.graphics.setColor(rr, gg, bb)
            love.graphics.circle("fill", cx, cy, r)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.circle("fill", cx - r * 0.25, cy - r * 0.25, r * 0.4)
        else
            local c = BUBBLE_COLORS[color]
            if c then
                -- Shadow
                love.graphics.setColor(c.shadow[1], c.shadow[2], c.shadow[3], 0.6)
                love.graphics.circle("fill", cx, cy + 2, r + 2)
                -- Main
                love.graphics.setColor(c.main[1], c.main[2], c.main[3])
                love.graphics.circle("fill", cx, cy, r)
                -- Highlight
                love.graphics.setColor(c.highlight[1], c.highlight[2], c.highlight[3], 0.7)
                love.graphics.circle("fill", cx - r * 0.25, cy - r * 0.25, r * 0.4)
            end
        end
    elseif b.pressed or anim > 0 then
        -- Pressed bubble
        love.graphics.setColor(0.18, 0.18, 0.25)
        love.graphics.circle("fill", cx, cy, r)
        love.graphics.setColor(0.12, 0.12, 0.18, anim * 0.8)
        love.graphics.circle("fill", cx, cy - r * 0.1, r * 0.9)
        love.graphics.setColor(0.25, 0.25, 0.35, anim * 0.5)
        love.graphics.circle("fill", cx, cy + r * 0.15, r * 0.6)
    else
        -- Default bubble (up state)
        love.graphics.setColor(0.2, 0.2, 0.28, 0.5)
        love.graphics.circle("fill", cx, cy + 3, r + 1)
        love.graphics.setColor(0.55, 0.55, 0.62)
        love.graphics.circle("fill", cx, cy, r)
        love.graphics.setColor(0.7, 0.7, 0.77, 0.6)
        love.graphics.circle("fill", cx - r * 0.2, cy - r * 0.2, r * 0.45)
    end
end

return Board
