local UI = {}

-- Button component
local Button = {}
Button.__index = Button

function Button.new(text, x, y, w, h, onClick)
    local self = setmetatable({}, Button)
    self.text = text
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.onClick = onClick
    self.cornerRadius = 12
    return self
end

function Button:draw()
    -- Button background
    love.graphics.setColor(0.3, 0.5, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.cornerRadius, self.cornerRadius)

    -- Button border
    love.graphics.setColor(0.4, 0.6, 1.0)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.cornerRadius, self.cornerRadius)

    -- Button text
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local tw = font:getWidth(self.text)
    local th = font:getHeight()
    love.graphics.print(self.text, self.x + (self.w - tw) / 2, self.y + (self.h - th) / 2)
end

function Button:hitTest(sx, sy)
    return sx >= self.x and sx <= self.x + self.w
       and sy >= self.y and sy <= self.y + self.h
end

function Button:handlePress(sx, sy)
    if self:hitTest(sx, sy) then
        if self.onClick then
            self.onClick()
        end
        return true
    end
    return false
end

UI.Button = Button

return UI
