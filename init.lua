function startReadingMpu()
    tmr.create():alarm(1500, tmr.ALARM_AUTO, function()
        local a = readMpu()
        print(sjson.encode(a))
    end)
end

function startup()
    print("startup!!!")

    dofile("mpu.lua")
    dofile("bluetooth.lua")

    setupMpu()
    openBluetooth2()
    startReadingMpu()
end

print("Startup will resume momentarily, you have 5 seconds to abort.")
print("Waiting...")
tmr.create():alarm(5000, tmr.ALARM_SINGLE, startup)
