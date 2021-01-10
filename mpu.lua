local math_helpers = require("math_helpers")

id = 0 -- always 0
scl = 6 -- set pin as scl
sda = 7 -- set pin as sda
MPU6050SlaveAddress = 0x68

AccelScaleFactor = 16384; -- sensitivity scale factor respective to full scale setting provided in datasheet
GyroScaleFactor = 131;
ACCEL_GYRO_ERROR = {}


MPU6050_REGISTER_SMPLRT_DIV = 0x19
MPU6050_REGISTER_USER_CTRL = 0x6A
MPU6050_REGISTER_PWR_MGMT_1 = 0x6B
MPU6050_REGISTER_PWR_MGMT_2 = 0x6C
MPU6050_REGISTER_CONFIG = 0x1A
MPU6050_REGISTER_GYRO_CONFIG = 0x1B
MPU6050_REGISTER_ACCEL_CONFIG = 0x1C
MPU6050_REGISTER_FIFO_EN = 0x23
MPU6050_REGISTER_INT_ENABLE = 0x38
MPU6050_REGISTER_ACCEL_XOUT_H = 0x3B
MPU6050_REGISTER_SIGNAL_PATH_RESET = 0x68

function I2C_Write(deviceAddress, regAddress, data)
    i2c.start(id) -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER)) then -- set slave address and transmit direction
        i2c.write(id, regAddress) -- write address to slave
        i2c.write(id, data) -- write data to slave
        i2c.stop(id) -- send stop condition
    else
        print("I2C_Write fails")
    end
end

function I2C_Read(deviceAddress, regAddress, SizeOfDataToRead)
    response = 0;
    i2c.start(id) -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER)) then -- set slave address and transmit direction
        i2c.write(id, regAddress) -- write address to slave
        i2c.stop(id) -- send stop condition
        i2c.start(id) -- send start condition
        i2c.address(id, deviceAddress, i2c.RECEIVER) -- set slave address and receive direction
        response = i2c.read(id, SizeOfDataToRead) -- read defined length response from slave
        i2c.stop(id) -- send stop condition
        return response
    else
        print("I2C_Read fails")
    end
    return response
end

function MPU6050_Init() --configure MPU6050
    tmr.delay(150000)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SMPLRT_DIV, 0x07)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_1, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_2, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_CONFIG, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_GYRO_CONFIG, 0x00) -- set +/-250 degree/second full scale
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_CONFIG, 0x00) -- set +/- 2g full scale
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_FIFO_EN, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_INT_ENABLE, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SIGNAL_PATH_RESET, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_USER_CTRL, 0x00)
end

function unsignToSigned16bit(num) -- convert unsigned 16-bit no. to signed 16-bit no.
    return num > 32768 and
            num - 65536 or num
end

function extractRawNumber(rawData, index)
    local firstByte = string.byte(rawData, index)
    local secondByte = string.byte(rawData, index + 1)
    return unsignToSigned16bit(bit.bor(bit.lshift(firstByte, 8), secondByte))
end

function getTemperature(rawData, index)
    local temperature = extractRawNumber(rawData, index)
    return temperature / 340 + 36.53
end

function getNumber(rawData, index, scaleFactor)
    local number = extractRawNumber(rawData, index)
    return number / scaleFactor
end

function readMpu() --read and print accelero, gyro and temperature value
    local data = I2C_Read(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_XOUT_H, 14)

    local Acc = {
        x = getNumber(data, 1, AccelScaleFactor) - ACCEL_GYRO_ERROR.Accel.x,
        y = getNumber(data, 3, AccelScaleFactor) - ACCEL_GYRO_ERROR.Accel.y,
        z = getNumber(data, 5, AccelScaleFactor) - ACCEL_GYRO_ERROR.Accel.z
    }
    local Tmp = getTemperature(data, 7)
    local Gy = {
        x = getNumber(data, 9,  GyroScaleFactor) - ACCEL_GYRO_ERROR.Gyro.x,
        y = getNumber(data, 11, GyroScaleFactor) - ACCEL_GYRO_ERROR.Gyro.y,
        z = getNumber(data, 13, GyroScaleFactor) - ACCEL_GYRO_ERROR.Gyro.z
    }

    --    print(sjson.encode({ Accel = Acc, Temperature = Tmp, Gyro = Gy }))
    return { Accel = Acc, Gyro = Gy, Temperature = Tmp }
end

function getRollPitchYaw(Accel, Gyro)
    local pitch = -180 * math_helpers.atan2(Accel.x, math.sqrt(Accel.y * Accel.y + Accel.z * Accel.z)) / math.pi
    local roll = 180 * math_helpers.atan2(Accel.y, Accel.z) / math.pi
    local yaw = 180 * math_helpers.atan(Accel.z / math.sqrt(Accel.x * Accel.x + Accel.z * Accel.z)) / math.pi

    return roll, pitch, yaw
end

function normalizeValue(min, max, value)
    --todo
end

function setAccelGyroError()
    local ax, ay, az, gx, gy, gz
    ACCEL_GYRO_ERROR = { Accel = { x = 0, y = 0, z = 0 }, Gyro = { x = 0, y = 0, z = 0 } }
    for i = 0, 1, 200 do
        local reading = readMpu()
        ax = ax + reading.Acc.x
        ay = ay + reading.Acc.y
        az = az + reading.Acc.z
        gx = gx + reading.Gy.x
        gy = gy + reading.Gy.y
        gz = gz + reading.Gy.z
    end
    ACCEL_GYRO_ERROR = {
        Accel = { x = ax / 200, y = ay / 200, z = az / 200 },
        Gyro = { x = gx / 200, y = gy / 200, z = gz / 200 }
    }
end

function setupMpu()
    i2c.setup(id, sda, scl, i2c.SLOW) -- initialize i2c
    MPU6050_Init()
    setAccelGyroError()
end