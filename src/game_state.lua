local GameState = {}

GameState.deck = { red = 1, blue = 1, yellow = 1, rainbow = 0 }
GameState.round = 0
GameState.score = 0
GameState.targetScores = { 50, 150, 300, 500, 750, 1000, 1500, 2000, 3500, 5000 }

function GameState.reset()
    GameState.deck = { red = 1, blue = 1, yellow = 1, rainbow = 0 }
    GameState.round = 0
    GameState.score = 0
end

function GameState.getTotalBubbles()
    local total = 0
    for _, count in pairs(GameState.deck) do
        total = total + count
    end
    return total
end

function GameState.getDeckAsList()
    local list = {}
    for color, count in pairs(GameState.deck) do
        for i = 1, count do
            table.insert(list, color)
        end
    end
    return list
end

function GameState.getTargetScore()
    local r = GameState.round
    if r >= 1 and r <= #GameState.targetScores then
        return GameState.targetScores[r]
    end
    return 9999
end

return GameState
