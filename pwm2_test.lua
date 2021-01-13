PULSE_PERIOD = 1023

function initPwm2()
    local frequencyAsHz = 1000
    local initialDuty = 0
    pwm2.setup_pin_hz(1, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO5 d1
    pwm2.setup_pin_hz(4, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO2 d4
    pwm2.setup_pin_hz(5, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO14 d5
    pwm2.setup_pin_hz(8, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO15 d8
    pwm2.setup_pin_hz(11, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO9 sdd2
    pwm2.setup_pin_hz(12, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO10 sdd3
    pwm2.start()
end

function writePwm2(pin, value)
    pwm2.set_duty(pin, value)
end

function writePwm2Test(value)
    pwm2.set_duty(1, value)
    pwm2.set_duty(4, value)
    pwm2.set_duty(5, value)
    pwm2.set_duty(8, value)
    pwm2.set_duty(11, value)
    pwm2.set_duty(12, value)
end

function starPwm2Test()
    pwm2.stop()
end

function starPwm2Test()
    local value = 0
    local add = true
    initPwm2()

    tmr.alarm(0, 1, tmr.ALARM_AUTO, function()
        if value == PULSE_PERIOD then
            add = false
        elseif value == 0 then
            add = true
        end

        if add then
            value = value + 1
        else
            value = value - 1
        end
        writePwm2Test(value)
    end)
end