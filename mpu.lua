id = 0 -- always 0
scl = 6 -- set pin as scl
sda = 7 -- set pin as sda
MPU6050SlaveAddress = 0x68

AccelScaleFactor = 16384; -- sensitivity scale factor respective to full scale setting provided in datasheet
GyroScaleFactor = 131;


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
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER)) -- set slave address and transmit direction then
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
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER)) -- set slave address and transmit direction then
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
    -- if num > 32768 then
    --     num = num - 65536
    -- end
    -- return num
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

    local Accel = {
        x = getNumber(data, 1, AccelScaleFactor),
        y = getNumber(data, 3, AccelScaleFactor),
        z = getNumber(data, 5, AccelScaleFactor)
    }
    local Temperature = getTemperature(data, 7)
    local Gyro = {
        x = getNumber(data, 9, GyroScaleFactor),
        y = getNumber(data, 11, GyroScaleFactor),
        z = getNumber(data, 13, GyroScaleFactor)
    }
    local mpu = { Accel, Temperature, Gyro }

    print(sjson.encode(mpu))
    return mpu
end



i2c.setup(id, sda, scl, i2c.SLOW) -- initialize i2c
MPU6050_Init()

readMpu()