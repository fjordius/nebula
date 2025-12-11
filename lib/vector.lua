--[[
    Vector2D Mathematics Library
    Fast, lightweight 2D vector operations
]]

local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0
    }, Vector)
end

function Vector:clone()
    return Vector.new(self.x, self.y)
end

function Vector.__add(a, b)
    return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector.__sub(a, b)
    return Vector.new(a.x - b.x, a.y - b.y)
end

function Vector.__mul(a, b)
    if type(b) == "number" then
        return Vector.new(a.x * b, a.y * b)
    end
    return Vector.new(a.x * b.x, a.y * b.y)
end

function Vector.__div(a, b)
    if type(b) == "number" then
        return Vector.new(a.x / b, a.y / b)
    end
    return Vector.new(a.x / b.x, a.y / b.y)
end

function Vector:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:normalize()
    local mag = self:magnitude()
    if mag > 0 then
        return self / mag
    end
    return Vector.new(0, 0)
end

function Vector:distance(other)
    return (self - other):magnitude()
end

function Vector:angle()
    return math.atan2(self.y, self.x)
end

function Vector.fromAngle(angle, magnitude)
    magnitude = magnitude or 1
    return Vector.new(
        math.cos(angle) * magnitude,
        math.sin(angle) * magnitude
    )
end

function Vector:rotate(angle)
    local cos, sin = math.cos(angle), math.sin(angle)
    return Vector.new(
        self.x * cos - self.y * sin,
        self.x * sin + self.y * cos
    )
end

function Vector:limit(max)
    local mag = self:magnitude()
    if mag > max then
        return self:normalize() * max
    end
    return self:clone()
end

function Vector:lerp(target, t)
    return self + (target - self) * t
end

return Vector