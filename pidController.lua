PidController = { k_p = 0 , k_i = 0, k_d = 0, E= 0, D = 0, I = 0 }

function PidController:new (k_p, k_i, k_d)
    obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.k_p = k_p or 0 -- proportional constant
    self.k_i = k_i or 0 -- integral constant
    self.k_d = k_d or 0 -- derivative constant
    return obj
end

function PidController:update (setPoint, processValue)
    local Error = setPoint - processValue
    local D = Error - self.E
    local A = math.abs(D - self.D)
    self.E = Error
    self.D = D
    self.I = A < Error and self.I + Error * self.k_i or self.I * 0.5
    return Error * self.k_p + (A < Error and self.I or 0) + D * self.k_d
end