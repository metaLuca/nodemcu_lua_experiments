su = softuart.setup(9600, 2, 3)

function onReceive(data)
    local txt = string.gsub(data, "[\r\n]", "")
    if (txt == "1") then
        su:write("1 on\n")
    elseif (txt == "2") then
        su:write("2 off\n")
    else
        su:write("--> " .. txt .. "\n")
    end
end

function openBluetooth2()
    su:on("data", "\n", onReceive)
    su:write("-- bluetooth START --\n")
end
