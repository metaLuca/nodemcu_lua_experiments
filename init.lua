function startup()
  print("startup!!!")

  dofile("mpu.lua")
  dofile("bluetooth.lua")
  openBluetooth2()
--  while true than do
--    read()
--    tmr.delay(100000)   -- 100ms timer delay
--  end
  if file.open("lucapilot.lua") == nil then
    print("lucapilot.lua missing")
  else
    print("Running lucapilot.lua")
    file.close("lucapilot.lua")
--    open main
  end
end

print("Startup will resume momentarily, you have 5 seconds to abort.")
print("Waiting...")
tmr.create():alarm(5000, tmr.ALARM_SINGLE, startup)
