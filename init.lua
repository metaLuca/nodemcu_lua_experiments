local ROLL_CONTROL
local PITCH_CONTROL
local YAW_CONTROL
lastRedThrottle = 0

function printMotorOutput(throttle, roll, pitch, yaw)
    local motorA = throttle + roll - yaw;
    local motorB = throttle + pitch + yaw;
    local motorC = throttle - roll - yaw;
    local motorD = throttle - pitch + yaw

    print("------------------")
    print("throttle: "..throttle..", roll: "..roll..", pitch: "..pitch..", yaw: "..yaw)
    print("M_A: "..motorA..", M_B"..motorB..", M_C"..motorC..", M_D"..motorD)
    print("------------------")
end

function getRPYOut(roll, pitch, yaw)
    --todo use pid
    return roll, pitch, yaw
end

function startReadingMpu()
    tmr.create():alarm(1500, tmr.ALARM_AUTO, function()
        local mpu = readMpu() -- {Accel: {y, x, z}, Gyro: {y, x, z}, Temperature}
        --print(sjson.encode(mpu))
        local roll, pitch, yaw = getRollPitchYaw(mpu.Accel, mpu.Gyro)
        local rollOut, pitchOut, yawOut = getRPYOut(roll, pitch, yaw)
        printMotorOutput(lastRedThrottle, rollOut, pitchOut, yawOut)
    end)
end

function setupPidControllers()
    ROLL_CONTROL = PidController:new(0.1, 10, 1)
    PITCH_CONTROL = PidController:new(0.1, 10, 1)
    YAW_CONTROL = PidController:new(0.1, 10, 1)
end

function startup()
    print("startup!!!")

-- (probably doesnt matter now but..) consider switching to require
    dofile("mpu.lua")
    dofile("bluetooth.lua")
    dofile("pidController.lua")

    setupMpu()
    openBluetooth2()
    startReadingMpu()
    setupPidControllers()
end

print("Startup will resume momentarily, you have 5 seconds to abort.")
print("Waiting...")
tmr.create():alarm(5000, tmr.ALARM_SINGLE, startup)