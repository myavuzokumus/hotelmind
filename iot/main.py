import argparse
import logging
import sys
import time
import tkinter as tk
from pathlib import Path

# Add project root to Python path
sys.path.append(str(Path(__file__).parent.parent))

# Import our modules
from utils.config import Config
from utils.logger import setup_logger, setup_aws_iot_logger
from sensors.sensor_manager import SensorManager
from actuators.actuator_manager import ActuatorManager
from cloud.iot_client import IoTClient
from cloud.preference import PreferenceManager
from utils.qrcode_generator import QRCodeGenerator

# Global variables
running = True
logger = None
qr_generator = None


def parse_args():
    parser = argparse.ArgumentParser(description="Smart Room Control System")
    parser.add_argument("-m", "--mock", action="store_true", dest="mock_sensors",
                        help="Simulate sensors (when Raspberry Pi hardware is not available)")
    parser.add_argument("-v", "--verbose", action="store_true", dest="verbose",
                        help="Verbose log output")
    parser.add_argument("-q", "--qrcode", action="store_true", dest="show_qrcode",
                        help="Show QR code generator on startup")
    return parser.parse_args()


def command_handler(topic, message):
    """Processes commands from AWS"""
    global preference_manager, actuator_manager, qr_generator, iot_client

    try:
        logger.info(f"Command received: {message}")

        # Check for RoomControl model changes
        if topic.endswith('/control/response') and "roomControl" in message:
            control_type = message["roomControl"].get("controlType")
            control_name = message["roomControl"].get("controlName")
            status = message["roomControl"].get("status", False)

            logger.info(f"Room control received: {control_type} - {control_name} - {status}")

            # If it's device control, use IR controller
            if control_type == "device" and control_name in ["tv", "ac"]:
                actuator_manager.ir_controller.control_device(control_name, "power", status)

                # Report device statuses to AWS IoT
                if iot_client:
                    device_statuses = actuator_manager.ir_controller.get_device_status()
                    iot_client.publish_device_status(device_statuses)

            # If it's light control (can be added in the future)
            elif control_type == "light":
                # Only control LEDs, do not use IR device control
                led_name = control_name.upper() if control_name == "main" else control_name
                actuator_manager.ir_controller.set_led_status(led_name, status)
                logger.info(f"Light control: {control_name} - {'on' if status else 'off'}")

                # Report light statuses to AWS IoT
                if iot_client:
                    device_statuses = {}
                    device_statuses[control_name] = status
                    iot_client.publish_device_status(device_statuses)

        # Action commands
        if "actions" in message:
            actuator_manager.process_actions(message["actions"])

        # User preferences response
        if "userPreference" in message:
            preference_manager.update_preferences(message["userPreference"])

        # QR code secret key response
        if topic.endswith('/secret/response') and "secretKey" in message:
            if qr_generator:
                qr_generator.handle_secret_response(message)

        # Sensor history response
        if topic.endswith('/sensors/history/response') and "payload" in message:
            logger.info("Sensor history received")
            if isinstance(message["payload"], list) and iot_client:
                iot_client.sensor_history = message["payload"]

        # Event history response
        if topic.endswith('/events/history/response') and "payload" in message:
            logger.info("Event history received")
            if isinstance(message["payload"], list) and iot_client:
                iot_client.event_history = message["payload"]

    except Exception as e:
        logger.error(f"Command processing error: {e}")


def check_dangerous_conditions(sensor_data, iot_client):
    """Checks for dangerous conditions and logs events if necessary"""

    # Gas level check
    if sensor_data["gasLevel"] > 5:
        logger.warning("High gas level detected!")
        actuator_manager.alert.play_warning_sound()

    # Motion/presence check
    if sensor_data["distance"] < 50 and not sensor_data["occupied"]:
        iot_client.publish_room_event("SECURITY_WARNING", "Suspicious movement detected")


def apply_preferences(sensor_data, preferences, actuator_manager):
    """Applies user preferences"""

    # Transfer preferences to climate controller
    actuator_manager.climate.update_preferences(preferences.user_preferences)

    # Temperature control
    if preferences.user_preferences.get("autoClimate", True):
        current_temp = sensor_data["temperature"]
        actuator_manager.climate.adjust_for_temperature(current_temp)

    # Humidity control - now an actual function call
    if preferences.user_preferences.get("autoClimate", True):
        current_humidity = sensor_data["humidity"]
        actuator_manager.climate.adjust_for_humidity(current_humidity)

def sensor_callback(data):
    """Processes sensor data"""
    global iot_client, preference_manager, actuator_manager

    # Print sensor data
    print("\n" + "=" * 50)
    print(f"Temperature: {data['temperature']:.1f}°C, Humidity: {data['humidity']:.1f}%")
    print(f"Pressure: {data['pressure']:.2f} hPa")  # Pressure data added
    print(f"Occupancy: {'Occupied' if data['occupied'] else 'Empty'}, Distance: {data['distance']:.1f} cm")
    print(f"Gas Level: {data['gasLevel']}/10, Card: {'Inserted' if data['cardInserted'] else 'Not Inserted'}")
    print("=" * 50)

    # Send data to cloud
    iot_client.publish_sensor_data(data)

    # Check dangerous conditions
    check_dangerous_conditions(data, iot_client)

    # Update and apply user preferences
    #preferences = preference_manager.fetch_preferences()
    apply_preferences(data, preference_manager, actuator_manager)


def cleanup_resources():
    """Cleans up resources"""
    global running, logger, iot_client, qr_generator

    logger.info("Cleaning up resources...")
    running = False

    # Close AWS IoT connection
    if iot_client:
        iot_client.disconnect()

    # Close QR code generator window if exists
    if qr_generator and qr_generator.root:
        qr_generator.root.destroy()

    # GPIO resources cleanup (RPi.GPIO is a Python module)
    try:
        import RPi.GPIO as GPIO
        GPIO.cleanup()
        logger.info("GPIO resources cleaned up")
    except:
        pass

    logger.info("All resources cleaned up")


def show_qr_code():
    """Shows the QR code generator"""
    global qr_generator
    if qr_generator:
        qr_generator.show()


def create_control_ui():
    """Creates the main control interface"""
    global qr_generator

    # Simple control interface
    root = tk.Tk()
    root.title("Smart Room Control")
    root.geometry("300x200")
    root.configure(bg="#f8f9fa")

    # Main frame
    frame = tk.Frame(root, bg="#f8f9fa", padx=20, pady=20)
    frame.pack(fill=tk.BOTH, expand=True)

    # Title
    title = tk.Label(
        frame,
        text="Smart Room Control",
        font=("Segoe UI", 16, "bold"),
        fg="#4361ee",
        bg="#f8f9fa"
    )
    title.pack(pady=(0, 20))

    # QR Code button
    qr_button = tk.Button(
        frame,
        text="Generate QR Code",
        font=("Segoe UI", 12),
        bg="#4361ee",
        fg="white",
        activebackground="#3a56d4",
        activeforeground="white",
        relief="flat",
        padx=10,
        pady=8,
        command=show_qr_code
    )
    qr_button.pack(fill=tk.X, pady=10)

    # Exit button
    exit_button = tk.Button(
        frame,
        text="Exit Program",
        font=("Segoe UI", 12),
        bg="#e63946",
        fg="white",
        activebackground="#c62f39",
        activeforeground="white",
        relief="flat",
        padx=10,
        pady=8,
        command=lambda: (root.destroy(), cleanup_resources(), sys.exit(0))
    )
    exit_button.pack(fill=tk.X, pady=10)

    return root


def main():
    global running, logger, iot_client, preference_manager, actuator_manager, qr_generator

    try:
        # Get command line arguments
        args = parse_args()

        # Configure logger
        log_level = logging.DEBUG if args.verbose else logging.INFO
        logger = setup_logger(level=log_level)
        #aws_logger = setup_aws_iot_logger()

        # Load configuration
        config = Config()

        # Set simulation mode
        if args.mock_sensors:
            config.has_hardware = False

        # Check certificate files
        if not config.check_certificates():
            print(f"ERROR: Certificate files not found. Please check certs/ directory.")
            return 1

        # Create IoT client and connect
        iot_client = IoTClient(config)
        if not iot_client.connect():
            logger.error("Failed to establish AWS IoT connection. Exiting.")
            return 1

        # Set command handler and subscribe to required topics
        iot_client.set_command_handler(command_handler)
        iot_client.subscribe_to_commands()

        # User preferences manager
        preference_manager = PreferenceManager(iot_client)

        # Sensor manager
        sensor_manager = SensorManager(config)
        if not sensor_manager.setup_sensors():
            logger.error("Sensor configuration failed. Exiting.")
            cleanup_resources()
            return 1

        # Output devices manager
        actuator_manager = ActuatorManager(config)
        if not actuator_manager.setup():
            logger.error("Actuator configuration failed. Exiting.")
            cleanup_resources()
            return 1

        actuator_manager.set_iot_client(iot_client, preference_manager)

        # Cooldown time
        time.sleep(5)

        # QR code generator
        qr_generator = QRCodeGenerator(config, iot_client)

        # Start sensor monitoring (at 10-second intervals)
        #monitor_thread = sensor_manager.start_monitoring(sensor_callback, interval=10)

        # Fetch initial user preferences
        #preference_manager.fetch_preferences(force=True)

        # If show QR code initially option is active
        if args.show_qrcode:
            qr_generator.show()

        # Create and start control interface
        root = create_control_ui()
        root.mainloop()

        return 0

    except KeyboardInterrupt:
        logger.info("Terminated by user.")
    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        return 1
    finally:
        cleanup_resources()
        return 0


if __name__ == "__main__":
    sys.exit(main())
