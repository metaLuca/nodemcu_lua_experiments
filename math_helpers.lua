-- const
local PI24 = 0.50 * math.pi
local SQRT3 = 1.73205081
local ATAN1 = 1.40878120
local ATAN2 = 0.55913709
local ATAN3 = 0.60310579
local ATAN4 = 0.05160454

local math_helpers = {}

function math_helpers.atan(x)
    local sign, inv, sp = false, false, 0
    if x < 0 then
        x = -x
        sign = true
    end
    if x > 1 then
        x = 1 / x
        inv = true
    end
    while x > (math.pi / 12) do
        x = ((x * SQRT3) - 1) * (1 / (x + SQRT3))
        sp = sp + 1
    end
    local X2 = x ^ 2
    local at = ((ATAN2 / (X2 + ATAN1)) + ATAN3 - (ATAN4 * X2)) * x
    while sp > 0 do
        at = at + (math.pi / 6)
        sp = sp - 1
    end
    if inv then
        at = PI24 - at
    end
    if sign then
        at = -at
    end
    return at
end

function math_helpers.atan2(y, x)
    if y == 0 then
        return y
    elseif x == 0 then
        if y < 0 then
            return -PI24
        else
            return PI24
        end
    elseif x == 1 then
        return math_helpers.atan(y)
    else
        if x > 0 then
            if y > 0 then
                return math_helpers.atan(y / x)
            else
                return (-1) * math_helpers.atan(-y / x)
            end
        else
            if y > 0 then
                return math.pi - math_helpers.atan(y / -x)
            else
                return math_helpers.atan(-y / -x) - math.pi
            end
        end
    end
end

return math_helpers