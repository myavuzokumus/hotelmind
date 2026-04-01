import logging
import random


class CardReader:
    """Class for card reader"""

    def __init__(self, config):
        """
        Initializes the card reader

        Args:
            config: System configuration
        """
        self.logger = logging.getLogger("SmartRoom.CardReader")
        self.config = config
        self.has_hardware = config.has_hardware
        self.card_inserted = False

    def setup(self):
        """Configures the card reader"""
        if not self.has_hardware:
            self.logger.info("Simulation: Card reader in simulation mode")
            return True

        try:
            # Real card reader code can be added here
            self.logger.info("Card reader configured successfully")
            return True

        except Exception as e:
            self.logger.error(f"Card reader initialization error: {e}")
            return False

    def read_sensor(self):
        """Reads the card reader status"""
        if not self.has_hardware:
            # 10% chance to change status
            if random.randint(1, 100) > 90:
                self.card_inserted = not self.card_inserted
            return self.card_inserted

        try:
            # Real RFID reader code can be added here
            # Let's return a random value for this example
            return self.card_inserted

        except Exception as e:
            self.logger.error(f"Card reader read error: {e}")
            return False