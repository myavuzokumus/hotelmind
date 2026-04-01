import logging
import platform
import random
import time
if platform.system() != 'Windows':
    import smbus2

class TemperatureSensor:
    """Class for BMP280 sensor - integrated with legacy code"""

    def __init__(self, config):
        """
        Initializes the temperature sensor

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.TemperatureSensor")
        self.config = config
        self.has_hardware = config.has_hardware
        self.i2c_bus = None

        # BMP280 calibration parameters
        self.bmp280_calibration = {}
        self.t_fine = 0

        # Calibration offset (difference between measured and known temperature)
        self.CALIBRATION_OFFSET = 22.7 - 26.86

    def setup(self):
        """Configures the sensor"""
        if not self.has_hardware:
            self.logger.info("Simulation: Temperature sensor in simulation mode")
            return True

        try:
            # Initialize I2C bus for BMP280 sensor
            self.i2c_bus = smbus2.SMBus(1)  # I2C bus 1 for Raspberry Pi 3/4

            # Initialize BMP280 sensor
            if not self._init_bmp280():
                self.logger.error("Failed to initialize BMP280 sensor")
                return False

            return True

        except Exception as e:
            self.logger.error(f"Temperature sensor initialization error: {e}")
            return False

    def _init_bmp280(self):
        """Initializes BMP280 sensor and reads calibration parameters"""
        try:
            bmp280 = self.config.bmp280

            # Read calibration data
            self._read_calibration_data()

            # Configure sensor for normal mode, 16x oversample
            self.i2c_bus.write_byte_data(bmp280["ADDRESS"], bmp280["REG_CONTROL"], 0x3F)  # 0x3F = 0b00111111

            self.logger.info("BMP280 sensor initialized successfully")
            return True

        except Exception as e:
            self.logger.error(f"BMP280 initialization error: {e}")
            return False

    def _read_calibration_data(self):
        """Reads BMP280 calibration data"""
        try:
            bmp280 = self.config.bmp280
            calib = self.i2c_bus.read_i2c_block_data(bmp280["ADDRESS"], bmp280["REG_DIG_T1"], 24)

            # Temperature calibration data
            dig_T1 = (calib[1] << 8) | calib[0]
            dig_T2 = (calib[3] << 8) | calib[2]
            if (dig_T2 > 32767):
                dig_T2 -= 65536
            dig_T3 = (calib[5] << 8) | calib[4]
            if (dig_T3 > 32767):
                dig_T3 -= 65536

            # Pressure calibration data
            dig_P1 = (calib[7] << 8) | calib[6]
            dig_P2 = (calib[9] << 8) | calib[8]
            if (dig_P2 > 32767):
                dig_P2 -= 65536
            dig_P3 = (calib[11] << 8) | calib[10]
            if (dig_P3 > 32767):
                dig_P3 -= 65536
            dig_P4 = (calib[13] << 8) | calib[12]
            if (dig_P4 > 32767):
                dig_P4 -= 65536
            dig_P5 = (calib[15] << 8) | calib[14]
            if (dig_P5 > 32767):
                dig_P5 -= 65536
            dig_P6 = (calib[17] << 8) | calib[16]
            if (dig_P6 > 32767):
                dig_P6 -= 65536
            dig_P7 = (calib[19] << 8) | calib[18]
            if (dig_P7 > 32767):
                dig_P7 -= 65536
            dig_P8 = (calib[21] << 8) | calib[20]
            if (dig_P8 > 32767):
                dig_P8 -= 65536
            dig_P9 = (calib[23] << 8) | calib[22]
            if (dig_P9 > 32767):
                dig_P9 -= 65536

            self.bmp280_calibration = {
                "dig_T1": dig_T1,
                "dig_T2": dig_T2,
                "dig_T3": dig_T3,
                "dig_P1": dig_P1,
                "dig_P2": dig_P2,
                "dig_P3": dig_P3,
                "dig_P4": dig_P4,
                "dig_P5": dig_P5,
                "dig_P6": dig_P6,
                "dig_P7": dig_P7,
                "dig_P8": dig_P8,
                "dig_P9": dig_P9
            }

            self.logger.debug("BMP280 calibration data read successfully")

        except Exception as e:
            self.logger.error(f"Calibration data read error: {e}")

    def _compensate_temperature(self, adc_T):
        """Converts raw temperature value to calibrated value"""
        var1 = (((adc_T >> 3) - (self.bmp280_calibration["dig_T1"] << 1)) * self.bmp280_calibration["dig_T2"]) >> 11
        var2 = (((((adc_T >> 4) - self.bmp280_calibration["dig_T1"]) *
                  ((adc_T >> 4) - self.bmp280_calibration["dig_T1"])) >> 12) *
                self.bmp280_calibration["dig_T3"]) >> 14

        self.t_fine = var1 + var2
        temperature = (self.t_fine * 5 + 128) >> 8
        return temperature / 100.0 + self.CALIBRATION_OFFSET

    def _compensate_pressure(self, adc_P):
        """Converts raw pressure value to calibrated value"""
        var1 = self.t_fine - 128000
        var2 = var1 * var1 * self.bmp280_calibration["dig_P6"]
        var2 = var2 + ((var1 * self.bmp280_calibration["dig_P5"]) << 17)
        var2 = var2 + (self.bmp280_calibration["dig_P4"] << 35)
        var1 = ((var1 * var1 * self.bmp280_calibration["dig_P3"]) >> 8) + (
                    (var1 * self.bmp280_calibration["dig_P2"]) << 12)
        var1 = (((1 << 47) + var1) * self.bmp280_calibration["dig_P1"]) >> 33

        if var1 == 0:
            return 0

        pressure = 1048576 - adc_P
        pressure = (((pressure << 31) - var2) * 3125) // var1
        var1 = (self.bmp280_calibration["dig_P9"] * (pressure >> 13) * (pressure >> 13)) >> 25
        var2 = (self.bmp280_calibration["dig_P8"] * pressure) >> 19
        pressure = ((pressure + var1 + var2) >> 8) + (self.bmp280_calibration["dig_P7"] << 4)

        return pressure / 25600.0

    def read_sensor(self):
        """Reads temperature and pressure data from BMP280"""
        if not self.has_hardware:
            # Simulate realistic values for temperature and pressure
            temp = 20.0 + random.uniform(-1.0, 3.0)  # between 19-23°C
            pressure = 1013.25 + random.uniform(-5.0, 5.0)  # between 1008-1018 hPa
            return (temp, pressure)

        try:
            bmp280 = self.config.bmp280

            # Allow time for sampling before reading sensor data
            self.i2c_bus.write_byte_data(bmp280["ADDRESS"], bmp280["REG_CONTROL"], 0x3F)
            time.sleep(0.05)

            # Read raw data
            data = self.i2c_bus.read_i2c_block_data(bmp280["ADDRESS"], bmp280["REG_PRESS_MSB"], 6)

            # Separate temperature and pressure data
            adc_P = (data[0] << 12) | (data[1] << 4) | (data[2] >> 4)
            adc_T = (data[3] << 12) | (data[4] << 4) | (data[5] >> 4)

            # Calculate values
            temperature = self._compensate_temperature(adc_T)
            pressure = self._compensate_pressure(adc_P)

            if temperature is not None and pressure is not None:
                return (temperature, pressure)
            else:
                self.logger.warning("Could not read data from BMP280 sensor!")
                return (None, None)

        except Exception as e:
            self.logger.error(f"BMP280 sensor read error: {e}")
            return (None, None)