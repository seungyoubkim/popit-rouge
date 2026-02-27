local SceneManager = require("src.scene_manager")
local GameState = require("src.game_state")
local UI = require("src.ui")

local Shop = {}

local SHOP_POOL = {
    {
        id = "add_red", name = "빨강 버블 추가",
        desc = "빨강 버블을 1개 추가합니다",
        apply = function(deck) deck.red = deck.red + 1 end,
        canShow = function(deck) return true end
    },
    {
        id = "add_blue", name = "파랑 버블 추가",
        desc = "파랑 버블을 1개 추가합니다",
        apply = function(deck) deck.blue = deck.blue + 1 end,
        canShow = function(deck) return true end
    },
    {
        id = "add_yellow", name = "노랑 버블 추가",
        desc = "노랑 버블을 1개 추가합니다",
        apply = function(deck) deck.yellow = deck.yellow + 1 end,
        canShow = function(deck) return true end
    },
    {
        id = "remove_red", name = "빨강 버블 삭제",
        desc = "빨강 버블을 1개 삭제합니다",
        apply = function(deck) deck.red = deck.red - 1 end,
        canShow = function(deck) return deck.red >= 1 end
    },
    {
        id = "remove_blue", name = "파랑 버블 삭제",
        desc = "파랑 버블을 1개 삭제합니다",
        apply = function(deck) deck.blue = deck.blue - 1 end,
        canShow = function(deck) return deck.blue >= 1 end
    },
    {
        id = "remove_yellow", name = "노랑 버블 삭제",
        desc = "노랑 버블을 1개 삭제합니다",
        apply = function(deck) deck.yellow = deck.yellow - 1 end,
        canShow = function(deck) return deck.yellow >= 1 end
    },
    {
        id = "add_rainbow", name = "무지개 버블 추가",
        desc = "무지개 버블을 1개 추가합니다",
        apply = function(deck) deck.rainbow = deck.rainbow + 1 end,
        canShow = function(deck) return true end
    },
}

local choices = {}
local cardButtons = {}

local function selectChoices()
    -- Filter valid options
    local valid = {}
    for _, item in ipairs(SHOP_POOL) do
        if item.canShow(GameState.deck) then
            table.insert(valid, item)
        end
    end

    -- Shuffle
    for i = #valid, 2, -1 do
        local j = love.math.random(i)
        valid[i], valid[j] = valid[j], valid[i]
    end

    -- Pick 3
    choices = {}
    for i = 1, math.min(3, #valid) do
        table.insert(choices, valid[i])
    end
end

function Shop.enter()
    selectChoices()
    Shop.buildUI()
end

function Shop.buildUI()
    local sw, sh = love.graphics.getDimensions()
    cardButtons = {}

    local cardW = sw * 0.7
    local cardH = 80
    local gap = 20
    local totalH = #choices * cardH + (#choices - 1) * gap
    local startY = (sh - totalH) / 2 + 40

    for i, choice in ipairs(choices) do
        local y = startY + (i - 1) * (cardH + gap)
        local btn = UI.Button.new(choice.name, (sw - cardW) / 2, y, cardW, cardH, function()
            choice.apply(GameState.deck)
            SceneManager.switch("lobby")
        end)
        table.insert(cardButtons, { button = btn, choice = choice })
    end
end

function Shop.update(dt)
end

function Shop.draw()
    local sw, sh = love.graphics.getDimensions()

    -- Title
    love.graphics.setFont(Fonts.bold)
    love.graphics.setColor(1, 0.85, 0.3)
    local title = "쇼핑"
    local tw = Fonts.bold:getWidth(title)
    love.graphics.print(title, (sw - tw) / 2, sh * 0.1)

    love.graphics.setFont(Fonts.regular)
    love.graphics.setColor(0.7, 0.7, 0.75)
    local sub = "하나를 선택하세요"
    local subW = Fonts.regular:getWidth(sub)
    love.graphics.print(sub, (sw - subW) / 2, sh * 0.18)

    -- Cards
    love.graphics.setFont(Fonts.bold)
    for _, card in ipairs(cardButtons) do
        card.button:draw()

        -- Description below button
        love.graphics.setFont(Fonts.regular)
        love.graphics.setColor(0.6, 0.6, 0.65)
        local descW = Fonts.regular:getWidth(card.choice.desc)
        love.graphics.print(card.choice.desc,
            (sw - descW) / 2,
            card.button.y + card.button.h + 4)
        love.graphics.setFont(Fonts.bold)
    end
end

function Shop.mousepressed(x, y, button)
    if button ~= 1 then return end
    for _, card in ipairs(cardButtons) do
        if card.button:handlePress(x, y) then return end
    end
end

function Shop.touchpressed(id, x, y)
    for _, card in ipairs(cardButtons) do
        if card.button:handlePress(x, y) then return end
    end
end

function Shop.resize(w, h)
    Shop.buildUI()
end

return Shop
