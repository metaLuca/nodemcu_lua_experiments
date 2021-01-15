PULSE_PERIOD = 400
pwmValue = 0
pwmAdd = true

function initPwm2()
    local frequencyAsHz = 100
    local initialDuty = 1
    pwm2.setup_pin_hz(1, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO5 d1
    pwm2.setup_pin_hz(4, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO2 d4
    pwm2.setup_pin_hz(5, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO14 d5
    pwm2.setup_pin_hz(8, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO15 d8
    pwm2.setup_pin_hz(12, frequencyAsHz, PULSE_PERIOD, initialDuty) --GPIO10 sdd3 ()

    pwm2.start()

    print('start pwm')
end

function writePwm2(pin, value)
    pwm2.set_duty(pin, value)
end

function writePwm2Test(value)
    pwm2.set_duty(1, value)
    pwm2.set_duty(4, value)
    pwm2.set_duty(5, value)
    pwm2.set_duty(8, value)
--    pwm2.set_duty(11, value)
    pwm2.set_duty(12, value)
    print('pwm value: '..value)
end

function stopPwm2Test()
    pwm2.stop()
end

function loopPwm2Test()
    if pwmValue == PULSE_PERIOD then
        pwmAdd = false
    elseif pwmValue == 0 then
        pwmAdd = true
    end

    if pwmAdd then
        pwmValue = pwmValue + 1
    else
        pwmValue = pwmValue - 1
    end
    writePwm2Test(pwmValue)
end

function startPwm2Test()
    initPwm2()

    tmr.create():alarm(10, tmr.ALARM_AUTO, loopPwm2Test)
end