import ConfigParser, datetime, os, psycopg2, secrets, smbus, time
import Adafruit_BMP.BMP085 as BMP085


bmp_sensor = None
bus = smbus.SMBus(1)
sensor_cfg = ConfigParser.ConfigParser()


def init_db():
    conn = psycopg2.connect(user="admin", password="XXX", host="aws-us-east-1-portal.8.dblayer.com", port="10013", database="compose")
#    server['smart_building_development']
    return conn


def init_sensors():

    for sensor_name in sensor_cfg.sections():
        if sensor_cfg.has_option(sensor_name, 'power_signal_required'):
            address = int(sensor_cfg.get(sensor_name, 'address'), 16)
            ctrl_reg_address = int(sensor_cfg.get(sensor_name, 'ctrl_reg'), 16)
            ctrl_reg_power_mask = int(sensor_cfg.get(sensor_name, 'ctrl_power_on'), 16)
            bus.write_byte_data(address, ctrl_reg_address, ctrl_reg_power_mask)

        if sensor_cfg.has_option(sensor_name, 'custom_init_func'):
            init_func = sensor_cfg.get(sensor_name, 'custom_init_func')
            globals()[init_func](sensor_name)


def init_bp(sensor_name):
    global bmp_sensor
    bmp_sensor = BMP085.BMP085()


def init_gest(sensor_name):
    address = int(sensor_cfg.get(sensor_name, 'address'), 16)
    gesture_ctrl_reg_address = int("0xAB", 16)
    gesture_mode_mask = int("0x01", 16)
    bus.write_byte_data(address, gesture_ctrl_reg_address, gesture_mode_mask)

    gesture_conf2_reg_address = int("0xA3", 16)
    gesture_conf2_mask = int("0x07", 16)
    bus.write_byte_data(address, gesture_conf2_reg_address, gesture_conf2_mask)

    gesture_dim_address = int("0xAA", 16)
    gesture_dim_mask = int("0x02", 16)
    bus.write_byte_data(address, gesture_dim_address, gesture_dim_mask)

    gesture_exit_thresh_address = int("0xA1", 16)
    gesture_exit_thresh_mask = int("0x00", 16)
    bus.write_byte_data(address, gesture_exit_thresh_address, gesture_exit_thresh_mask)

#    gesture_ctrl_reg2_address = int("0x8F", 16)
#    gesture_ctrl_reg2_mask = int("0xC0", 16)
#    bus.write_byte_data(address, gesture_ctrl_reg2_address, gesture_ctrl_reg2_mask)

    gesture_conf_reg_address = int("0x90", 16)
    gesture_conf_reg_mask = int("0x30", 16)
    bus.write_byte_data(address, gesture_conf_reg_address, gesture_conf_reg_mask)

    gesture_enable_address = int("0x80", 16)
    gesture_enable_mask = int("0x45", 16)
    bus.write_byte_data(address, gesture_enable_address, gesture_enable_mask)


def capture_data(conn):

    for sensor_name in sensor_cfg.sections():
        sensor_id = sensor_cfg.get(sensor_name, 'pk')
        data = None
        if sensor_cfg.has_option(sensor_name, 'custom_capture_func'):
            capture_func = sensor_cfg.get(sensor_name, 'custom_capture_func')
            data = globals()[capture_func](sensor_name)
        else:
            address = int(sensor_cfg.get(sensor_name, 'address'), 16)
            data_reg_address = 0x00
            if sensor_cfg.has_option(sensor_name, 'data_reg'):
                data_reg_address = int(sensor_cfg.get(sensor_name, 'data_reg'), 16)
            data = bus.read_byte_data(address, data_reg_address)

        if sensor_cfg.has_option(sensor_name, 'callback'):
            func_name = sensor_cfg.get(sensor_name, 'callback')
            data = globals()[func_name](data)

        cur = conn.cursor()
        cur.execute("INSERT INTO data_points (timestamp, sensor_id, data) VALUES (%s, %s, %s)", (datetime.datetime.now(), sensor_id, data))
        conn.commit()
        print("{}: {}".format(sensor_name, data))


def capture_bp(sensor_name):
    return float(bmp_sensor.read_pressure())


def capture_gest(sensor_name):
    address = int(sensor_cfg.get(sensor_name, 'address'), 16)
    up_data_reg_address = int("0xFC", 16)
    down_data_reg_address = int("0xFD", 16)
    left_data_reg_address = int("0xFE", 16)
    right_data_reg_address = int("0xFF", 16)
    valid_data_reg_address = int("0xAE", 16)

    left_count = 0
    right_count = 0

    valid_data_count = bus.read_byte_data(address, valid_data_reg_address)
    for i in range(valid_data_count):
        bus.read_byte_data(address, up_data_reg_address)
        bus.read_byte_data(address, down_data_reg_address)

        left_data = bus.read_byte_data(address, left_data_reg_address)
        left_count = left_count + left_data

        right_data = bus.read_byte_data(address, right_data_reg_address)
        right_count = right_count + right_data

    return left_count - right_count


def count_people(sensor_name):

    if os.path.isfile("count.txt"):
        f = open("count.txt", "r")
        line = f.readline()
        f.close()
        if line != "":
            return float(line)
    return 0.0


def convert_temp(cels):

    return float((float(cels) * float(9.0 / 5.0)) + 32.0)


def convert_lux(second_byte):

    first_byte = bus.read_byte_data(0x29, 0x8D)
    return ((first_byte << 8) + second_byte) / 1000.0


def convert_bp(pascals):

    return pascals / 1000.0


if __name__ == '__main__':
    conn = init_db()

    sensor_cfg.read('/home/pi/scm-scripts/conf/sensors.ini')
    init_sensors()

    while True:
        capture_data(conn)
        time.sleep(2)
