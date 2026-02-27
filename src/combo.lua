local Combo = {}

local BASE_POINTS = 10
local MONO_BONUS = 10
local RAINBOW_BONUS = 5

local lastColor = nil
local comboType = nil   -- "mono" or "rainbow"
local comboCount = 0

function Combo.reset()
    lastColor = nil
    comboType = nil
    comboCount = 0
end

function Combo.onPop(color)
    local points = BASE_POINTS
    local resultType = nil
    local resultCount = 0

    if lastColor == nil then
        -- First pop: no combo
        lastColor = color
        comboType = nil
        comboCount = 0
        return { points = points, comboType = nil, comboCount = 0 }
    end

    if color == "rainbow" then
        -- Rainbow bubble: keep current combo going +1
        comboCount = comboCount + 1
        resultType = comboType
        resultCount = comboCount
        if comboType == "mono" then
            points = points + MONO_BONUS * comboCount
        elseif comboType == "rainbow" then
            points = points + RAINBOW_BONUS * comboCount
        end
        -- Don't change lastColor so next non-rainbow compares to original
        return { points = points, comboType = resultType, comboCount = resultCount }
    end

    if color == lastColor then
        -- Same color: mono combo
        if comboType == "mono" then
            comboCount = comboCount + 1
        else
            comboType = "mono"
            comboCount = 1
        end
        points = points + MONO_BONUS * comboCount
        resultType = "mono"
        resultCount = comboCount
    else
        -- Different color: rainbow combo
        if comboType == "rainbow" then
            comboCount = comboCount + 1
        else
            comboType = "rainbow"
            comboCount = 1
        end
        points = points + RAINBOW_BONUS * comboCount
        resultType = "rainbow"
        resultCount = comboCount
        lastColor = color
    end

    return { points = points, comboType = resultType, comboCount = resultCount }
end

function Combo.getState()
    return { comboType = comboType, comboCount = comboCount }
end

return Combo
